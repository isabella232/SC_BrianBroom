///// Copyright (c) 2017 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

protocol LoginCoordinatorDelegate: class {
  func showContent()
}

class LoginCoordinator {
  
  weak var delegate: LoginCoordinatorDelegate?
  var childCoordinators: [Coordinator] = []
  var navigationController: UINavigationController
  
  var user: User?
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
}

extension LoginCoordinator: Coordinator {
  func start() {
    let sb = UIStoryboard(name: "Login", bundle: nil)
    let loginVC = sb.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    loginVC.delegate = self
    navigationController.setViewControllers([loginVC], animated: false)
  }
}

extension LoginCoordinator: LoginViewControllerDelegate {
  
  func didLogin() {
    UserDefaults.standard.set(true, forKey: "isLoggedIn")
    
    delegate?.showContent()
  }
  
  func signupNewAccount() {
    user = User()
    let sb = UIStoryboard(name: "Login", bundle: nil)
    let usernameVC = sb.instantiateViewController(withIdentifier: "SignupUsernameViewController") as! SignupUsernameViewController
    usernameVC.delegate = self
    navigationController.pushViewController(usernameVC, animated: true)
  }
  
}

extension LoginCoordinator: SignupUsernameViewControllerDelegate {
  
  func set(username: String) {
    user?.username = username
    
    let sb = UIStoryboard(name: "Login", bundle: nil)
    let passwordVC = sb.instantiateViewController(withIdentifier: "SignupPasswordViewController") as! SignupPasswordViewController
    passwordVC.delegate = self
    navigationController.pushViewController(passwordVC, animated: true)
  }
  
}

extension LoginCoordinator: SignupPasswordViewControllerDelegate {
  
  func set(password: String) {
    user?.password = password
    
    let sb = UIStoryboard(name: "Login", bundle: nil)
    let regionVC = sb.instantiateViewController(withIdentifier: "SignupRegionViewController") as! SignupRegionViewController
    regionVC.delegate = self
    navigationController.pushViewController(regionVC, animated: true)
  }
  
}

extension LoginCoordinator: SignupRegionViewControllerDelegate {
  
  func set(region: String) {
    user?.region = region
    // back to login
    navigationController.popToRootViewController(animated: true)
  }
  
}
