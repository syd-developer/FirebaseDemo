//
// Copyright (c) 2018 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Firebase

//-------------------------------------------------------------------------------------------------------------------------------------------------
class TestView: UIViewController {

	@IBOutlet var tableView: UITableView!

	private var listener: ListenerRegistration?

	private var objectIds: [String] = []
	private var items: [String: Any] = [:]

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Test"

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAdd))

		tableView.tableFooterView = UIView()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		createObserver()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)
		removeObserver()
	}

	// MARK: - Backend methods (observer)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func createObserver() {

		listener = Firestore.firestore().collection("Items").addSnapshotListener { querySnapshot, error in
			if let snapshot = querySnapshot {
				for documentChange in snapshot.documentChanges {
					self.addItem(documentChange.document.data())
				}
				self.tableView.reloadData()
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func addItem(_ item: [String: Any]) {

		guard let objectId = item["objectId"] as? String else { return }

		if (objectIds.contains(objectId) == false) {
			objectIds.insert(objectId, at: 0)
		}

		items[objectId] = item
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func removeObserver() {

		listener?.remove()
		listener = nil
	}

	// MARK: - Backend methods (create, update)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func createItem() {

		let objectId = UUID().uuidString

		var item: [String: Any] = [:]

		item["objectId"] = objectId

		item["text"] = randomText()
		item["number"] = randomInt()
		item["boolean"] = randomBool()

		item["createdAt"] = FieldValue.serverTimestamp()
		item["updatedAt"] = FieldValue.serverTimestamp()

		Firestore.firestore().collection("Items").document(objectId).setData(item) { error in
			if (error != nil) {
				print(error!.localizedDescription)
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateItem(_ item: [String: Any]) {

		guard let objectId = item["objectId"] as? String else { return }

		var item = item

		item["text"] = randomText()
		item["number"] = randomInt()
		item["boolean"] = randomBool()

		item["updatedAt"] = FieldValue.serverTimestamp()

		Firestore.firestore().collection("Items").document(objectId).updateData(item) { error in
			if (error != nil) {
				print(error!.localizedDescription)
			}
		}
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionAdd() {

		createItem()
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func randomText() -> String {

		return String((0..<20).map { _ in "abcde".randomElement()! })
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func randomInt() -> Int {

		return Int.random(in: 1000..<5000)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func randomBool() -> Bool {

		return Bool.random()
	}
}

// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension TestView: UITableViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return objectIds.count
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell") }

		let objectId = objectIds[indexPath.row]

		cell.textLabel?.text = objectId
		cell.textLabel?.font = UIFont.systemFont(ofSize: 13)

		cell.detailTextLabel?.text = ""
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)

		if let item = items[objectId] as? [String: Any] {
			if let text = item["text"] as? String, let number = item["number"] as? Int, let boolean = item["boolean"] as? Bool {
				cell.detailTextLabel?.text = "\(text) - \(number) - \(boolean)"
			}
		}

		return cell
	}
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension TestView: UITableViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let objectId = objectIds[indexPath.row]

		if let item = items[objectId] as? [String: Any] {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
				self.updateItem(item)
			}
		}
	}
}
