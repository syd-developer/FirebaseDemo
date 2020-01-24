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

//-------------------------------------------------------------------------------------------------------------------------------------------------
class TestView: UIViewController {

	@IBOutlet var labelDetails: UILabel!
	
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Test"

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Password", style: .plain, target: self, action: #selector(actionPassword))
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(actionLogout))
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		if (AuthUser.userId() != "") {
			updateDetails()
		} else {
			actionWelcome()
		}
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionPassword() {

		let passwordView = PasswordView()
		let navController = UINavigationController(rootViewController: passwordView)
		if #available(iOS 13.0, *) {
			navController.isModalInPresentation = true
			navController.modalPresentationStyle = .fullScreen
		}
		self.present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionLogout() {

		AuthUser.logOut()
		updateDetails()
		actionWelcome()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionWelcome() {
		
		let welcomeView = WelcomeView()
		if #available(iOS 13.0, *) {
			welcomeView.isModalInPresentation = true
			welcomeView.modalPresentationStyle = .fullScreen
		}
		self.present(welcomeView, animated: true)
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails() {

		labelDetails.text = AuthUser.userId()
	}
}
