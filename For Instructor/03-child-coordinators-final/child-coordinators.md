# Screencast Metadata

## Screencast Title

[TODO. Example: What’s New in Foundation: Parsing JSON in Swift 4]

## Screencast Description

[TODO. Example: In the past working with JSON meant using either NSJSONSerialization class or a third party library. Now it's a matter of implementing a simple protocol.]

## Language, Editor and Platform versions used in this screencast:

* **Language:** [TODO. Example: Swift 4]
* **Platform:** [TODO. Example: iOS 11]
* **Editor**: [TODO. Example: Xcode 9]

# Child Coordinators

### Introduction -- Talking Head

Hey everyone, this is Brian. In the last video I showed you how to use a Coordinator class to drive the presentation of screens in your iOS app. Today I'll show you how to use multiple coordinators. As your app gets bigger you may have a section of screnes that it makes sense to break off into its own part. My suggestion is that when you make a seperate storyboard for on section, that you also make a seperate coordinator to handle that section of the app.

In our app, we have two storyboards. One for the login and user registration, and one for showing articles. We'll break the coordinator into two parts, one for each of these sections. Lets get started

### Starting Project -- Demo

This is the project as we left it last time. The ApplicationCoordinator does all the work of presenting new screens. Each View Controller has a delegate protocol, with methods for each of the outcomes that will cause a screen transition away from it. The Coordinator conforms to these protocols, and fetches scenes from the storyboard and presents them.

The nice thing about these changes is that we don't have to change anything in the View Controller level. All we're doing is rearranging at the coordinator level.

Lets take a look at ApplicationCoordinator. Since there will be several Coordinators, it will help if we have a protocol for them, defining the start method.

```
protocol Coordinator: class {
  func start()
}
```

I'll move the start method to an extension now

```
extension ApplicationCoordinator: Coordinator {
  func start() {
    let loggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    
    if !loggedIn {
      showLogin()
    } else {
      showContent()
    }
  }
}
```

The other change here is to add a property to hold the child coordinators. This is where it helps to have them conform to a protocol.

```
var childCoordinators: [Coordinator] = []
```

Now I'll create a new swift file and name it LoginCoordinator. I'll add a property for the navigation controller, and the init method

```
class LoginCoordinator {
  var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
}
```

I'll also move the contents of `ShowLogin` here from Application Coordinator, only now I'll call it `start` for this coordinator.

```
func showLogin() {

}
```

```
extension LoginCoordinator: Coordinator {
  func start() {
    let storyboard = UIStoryboard(name: "Login", bundle: nil)
    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    loginVC.delegate = self
    navigationController.setViewControllers([loginVC], animated: false)
  }
}
```

Back to ApplicationCoordinator. The `showLogin` method needs to start up the child coordinator. I'll create it, passing in the main navigation controller, add that coordinator to the list of child coordinators, and call the start method.

```
func showLogin() {
    let loginCoordinator = LoginCoordinator(navigationController: navigationController)
    childCoordinators.append(loginCoordinator)
    loginCoordinator.start()
}
```

### Delegates, Again? -- Talking Head

In the last video, I talked about how each View Controller needs to have a delegate defined that lists the ways that that screen will need to transition to another screen. With child coordinators, you need to do the same thing again, but this time in the context of when the child coordinator needs to give up control to another coordinator. The child coordinator will define a delegate protocol, and have a delegate property. When its time for the child to pass control to another object, it will call one of these delegate methods, and the main coordinator will take over. It is a bit more work to get setup, and is some extra boilerplat code you have to write, but thinking through what responsibilites this coordinater is in charge of, and what it will respond to, will help in the long run.

### Coordinator delegate

For the login coordinator - the only situation where it will give up control is when a user has successfully logged in to the app. I'll define a protocol for this coordinator and add a method for that.

```
protocol LoginCoordinatorDelegate: class {
  func didLogIn()
}
```

and add a property for the delegate

```
weak var delegate: LoginCoordinatorDelegate?
```

ApplicationCoordinator needs to conform to this protocol. Once the user is logged in, I don't need the Login Coordinator any more, so I'll remove it from the array of child coordinators. They also get to see the articles, so I'll just call `showContent()`.

```
extension ApplicationCoordinator: LoginCoordinatorDelegate {
  func didLogIn() {
    _ = childCoordinators.popLast()
    showContent()
  }
}
```

Finally, I need to set the Application Coordinator as the delegate for the Login Coordinator in `showLogin()`

```
loginCoordinator.delegate = self
```

### New User Registration -- Demo

You can build and run the app at this point, and everything still works. Now we can add the screens for new user registration. I'll add these to the Login Coordinator. A new user needs a username and a password, so lets start with those.

In LoginViewController, add the delegate method to handle the new account signup

```
func signUpNewAccount()
```

and call it in the button handler

```
self.delegate?.signUpNewAccount()
```

In LoginCoordinator, you will need a property to keep track of the new user object. You'll keep that here, instead of passing it along to each view controllers. They don't need it, they only need to do their particular part of the setup.

```
var user: User?
```

Then , implement the new delegate method in the LoginViewControllerDelegate extension. Create a new blank user object, grab the storyboard and instatiate the username view controller, set the coordinator as the delegate, and push it onto the navigation stack.

```
  func signUpNewAccount() {
    user = User()
    let storyboard = UIStoryboard(name: "Login", bundle: nil)
    let usernameVC = storyboard.instantiateViewController(withIdentifier: "SignupUsernameViewController") as! SignupUsernameViewController
    usernameVC.delegate = self
    navigationController.pushViewController(usernameVC, animated: true)
  }
```

Switching to SignupUsernameViewController, it needs a delegate protocol. For this screen, we'll transition when the user sets their username.

```
protocol SignupUsernameViewControllerDelegate: class {
  func set(username: String)
}
```

Add a property for the delegate

```
weak var delegate: SignupUsernameViewControllerDelegate?
```

and call the delegate method in the button handler. I'll make sure to only do this if the textfield has text in it.

```
  @IBAction func didTapNextButton(_ sender: Any) {
    if usernameField.hasText {
      delegate?.set(username: usernameField.text!)
    } 
  }
```

Then add the protocol conformance in LoginCoordinator. I'll set the username of the new user object, and instantiate the next storyboard in the chain, the one for the password. This also gets pushed onto the navigation controller.

```
extension LoginCoordinator: SignupUsernameViewControllerDelegate {
  
  func set(username: String) {
    user?.username = username
    let storyboard = UIStoryboard(name: "Login", bundle: nil)
    let passwordVC = storyboard.instantiateViewController(withIdentifier: "SignupPasswordViewController") as! SignupPasswordViewController
    passwordVC.delegate = self
    navigationController.pushViewController(passwordVC, animated: true)
  }
}
```

Last screen for now. In SignupPasswordViewController, the protocol here covers setting of the password by the user.

protocol SignupPasswordViewControllerDelegate: class {
  func set(password: String)
}

and the view controller need a delegate property

```
weak var delegate: SignupPasswordViewControllerDelegate?
```

and call the delegate method in the button handler. I'll make sure both password fields have something entered, and that the values are the same.

```
  @IBAction func didTapRegisterButton(_ sender: Any) {
    guard passwordField.hasText, passwordConfirmField.hasText, passwordField.text == passwordConfirmField.text else {
      return
    }
    delegate?.set(password: passwordField.text!)
  }
```

Then implement the delegate method in the coordinator. Set the password value on the new user object. Once the user object is setup, it could be sent to your login server. Here I'll just pop back to the main login screen so the user can log into their new account.

```
extension LoginCoordinator: SignupPasswordViewControllerDelegate {
  func set(password: String) {
    user?.password = password
    navigationController.popToRootViewController(animated: true)
  }
}
```

And thats it. You can build and run the app and go through the new user screens. 

## Conclusion

At this point you know how to implement Coordinators in your apps, including how to break out specific parts into a coordinator to specificly handle that section of the app. I think its a big improvement over using segues and `prepareFor(segue:)` to setup application flow and pass values around. If you're up for a challenge, here are two additional things you can implement.

### Challenge 1 - what region is the user in?

Your app may need to know what part of the world the user is in. Maybe for language settings, or to pick a server closer to them. Using the coorinator setup you can use the screen included in the login storyboard to set this value. You can add it to any part of the login flow, I'd suggest having that be the first screen in the new user flow. If you have trouble, check out the code in the finished project.

### Challenge 2 - Child Coordinator for articles

There are only two screens here in the app, but you can split those off into an ArticleCoordinator to take responsibility for those transitions. See if you can implement this change, and again, check the finished project if you need a hint.

Hopefully this will make your transitions less clumsy, and your whole app more (ahem) coordinated.