# Screencast Metadata

## Screencast Title

[TODO. Example: What’s New in Foundation: Parsing JSON in Swift 4]

## Screencast Description

[TODO. Example: In the past working with JSON meant using either NSJSONSerialization class or a third party library. Now it's a matter of implementing a simple protocol.]

## Language, Editor and Platform versions used in this screencast:

* **Language:** [TODO. Example: Swift 4]
* **Platform:** [TODO. Example: iOS 11]
* **Editor**: [TODO. Example: Xcode 9]

# Introduction to Coordinators

### Introduction -- Talking Head

Hey everyone, this is Brian. In this video I'll show you how to use a Coordinator object to manage the flow between the View Controllers in your iOS apps.

Coordinator is an idea suggested by Soroush Khanlou where you break out the responsibility of presenting screens from the View Controllers and give it to a new class -- the Coordinator.

### Why Coordinators? -- Talking Head

You might ask -- "Isn't this what storyboards and segues do?" The answer is "Yes", but while it can help you setup screens for your app very quickly, they can start to get in the way as your app gets larger. Let me show you.

### Segue Examples -- Demo

Here is a sample project for an app that displays a TableView. If you aren't logged in, a login screen is displayed where you can log in or register for a new account. I've written apps that look very much like this, and you probably have too. So what's wrong?

First -- where does the logic go to determine if you're logged in? In this example, it needs to go in the TableView, but thats not really a TableView's responsibility. 

The Second problem is that segues tie two View Controllers together pretty tightly. Here in the new user flow, each of these segues has a `prepare(for:sender:)` method to pass along data to the next View Controller in the chain. If you need to reorder screens, its a giant pain.

### What to do? -- Talking Head

Like good OO programmers, we're going to solve this by adding a new class to take this responsibility. The Coordinator. Its job will be to manage the presenting of different screens in out app. I like this much better than having little bits of presentation code strewn all throughout my app.

Great! you say. How does it actually work? Lets take a look.

### Starter Project -- Demo

Ok, here is the same starter project, with the segues and Navigation Controllers removed. I've added storyboard identifiers (show) for the scenes, and removed the 'main interface' storyboard (show), since the Coordinator will handle that.

Fair warning -- there is a bit of setup required, but you're not afraid of a little code are you?

First lets create the actual coordinator class. I'll make a new Swift file, import UIKit, and create a class called ApplicationCoordinator. 

```
import UIKit

class ApplicationCoordinator {

}
```

This app is built around a navigation controller, so most of the screen transitions will be pushes onto the Navigation Controller. I'll add a property to hold a refrence to the Navigation Controller so I can easily access it from the coordinator.

```
var navigationController: UINavigationController
```

and write the `init` method. I'll pass in the base navigation controller, and store it in that property.

```
init(navigationController: UINavigationController) {
    self.navigationController = navigationController
}
```

To start off, we will just worry about presenting two screens, the login screen and the article list. I'll start with the login screen. To show this screne, I'll write a method to grab the storyboard, instantiate the scene, and then set it as the root of the navigation controller, since this is the first screen.

```
func showLogin() {
    let storyboard = UIStoryboard(name: "Login", bundle: nil)
    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    navigationController.setViewControllers([loginVC], animated: false)
}
```

Same for the Article List. Grab the storyboard, instantiate the scene. If I'm showing the list, then I don't need the login screen anymore, and I can just reset the root of the navigation controller to that screen.

```
func showContent() {
    let storyboard = UIStoryboard(name: "Articles", bundle: nil)
    let listVC = storyboard.instantiateViewController(withIdentifier: "ArticleListViewController") as! ArticleListViewController
    navigationController.setViewControllers([listVC], animated: true)
}
```

I want the main setup for the coordinator to be in a `start()` method. When `start()` is called, check to see if the user is logged in by checking UserDefaults. You may want to do something different for your app, but make sure it doesn't take too long -- you're holding up the show. Then present the login screen or the article list by calling those methods.

```
func start() {
    let loggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")

    if !loggedIn {
        showLogin()
    } else {
        showContent()
    }
}
```

If you build and run the app at this point (show) you get a dissapointing black screen. Since the Main Interface isn't set to a storyboard, we are responsible for some setup. Just like old times. Switch over to AppDelegate 

The AppDelegate needs to keep a refrence to the Coordinator -- every object needs an owner. Add a property to store the Coordinator. We'll call this 'Application Coordinator', since it will handle the flow for the whole app. I'll show you in a later video how to add additional coordinators where they make sense. 

```
var appCoordinator: ApplicationCoordinator?
```

then in `applicationDidFinishLaunching` method, create a window object and the base navigation controller. Next, I'll set the root view controller for the window to be this navigation controller, and call makeKeyAndVisible to display it. This used to be how apps were written before storyboards, up hill, both ways. Next, I'll create an Application Coordinator object, passing in the navigation controller. Then I'll call our `start()` method to start up the coordinator.

```
window = UIWindow()
let nav = UINavigationController()

window?.rootViewController = nav
window?.makeKeyAndVisible()

appCoordinator = ApplicationCoordinator(navigationController: nav)
appCoordinator?.start()
```

Now if you build and run, you will see the login screen. WooHoo! 

### ViewControllerDelegates - Talking Head

You may have noticed that the login screen doesn't do anything. What it should do is transition to the article screen. We need a way for the login screen to communicate back up to the coordinator that its time to change screens. On iOS, this type of communication is usually done by the *delegate* pattern. This View Controller needs to define a protocol with methods for all of the "flow events" that can happen from this screen. The Coordinator will then conform to that protocol, and set itself as the delegate of the View Controllers to execute the screen transitions.

This helps you to think through this screen's transitions in the context of the overall app. What events cause transitions between screens. Having to encapsulate that in the delegates for the individual ViewControllers helps clarify why the View Controller is there, what they do, and what their role is.

### Setting up the delegate -- Demo

Back in the LoginViewController, I'll add the protocol for this screen. I name them as the View Controller + Delegate to keep things organized. For now, this will have one method called didLogin. This tells the coordinator that the user authenticated and should now go to the list of articles.

```
protocol LoginViewControllerDelegate: class {
  func didLogIn()
}
```

Next, I'll add a property to store the delegate. This needs to be weak to make sure there isn't a retain cycle. 

```
weak var delegate: LoginViewControllerDelegate?
```

Finally, I'll call didLogIn on the delegate.

```
self.delegate?.didLogIn()
```

Then over to ApplicationCoordinator. You need to add conformance to this new protocol -- I use extensions for this.

```
  func didLogIn() {
  }
}
```

Then implment the didLogIn function. What should happen once the user logs in? The app should show the list of articles, right? We already wrote a method for that, so we can just call `showContent()`

```
showContent()
```

Finally, we need to set the coordinator as the delegate of the login screen. Back in showLogin, add that line

```
loginVC.delegate = self
```

If I run the app now, I can login and see the list of articles. If I tap on one of the items, I'd expect to see a detail screen with more information. Lets do that next.

### Detail View -- Demo

In the ArticleListViewController, I don't have the selection segue to automatically do this transition, but there is a TableView Delegate method for cell selection that you may have used before, `didSelectRowAt(indexPath:)`. We can use that to trigger the transition.

Again, the article list needs a delegate protocol, with the didSelect method

```
protocol ArticleListViewControllerDelegate: class {
  func didSelect(article: Article)
}

```

and a property for the delegate

```
weak var delegate: ArticleListViewControllerDelegate?
```

and then call that method in `didSelectRowAt(indexPath:)`

```
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let article = articles[indexPath.row]
    delegate?.didSelect(article: article)
}
```

Notice that I don't even need to know what View Controller this will get passed to. I just say, "Hey, someone tapped on this article, maybe someone should do something about that". The coordinator will handle it, but this class doesn't care what happens.

Back in Application Coordinator, first we need to set the Coordinator as the delegate of the Article List in `showContent()`

```
listVC.delegate = self
```

then conform to the protocol, again, I use extensions for this. Just like before, you grab a refrence to the storyboard, then instantiate the view controller, set the selectedArticle property, and push it onto the Navigation stack.

```
extension ApplicationCoordinator: ArticleListViewControllerDelegate {
  func didSelect(article: Article) {
    let storyboard = UIStoryboard(name: "Articles", bundle: nil)
    let detailVC = storyboard.instantiateViewController(withIdentifier: "ArticleDetailViewController") as! ArticleDetailViewController
    detailVC.selectedArticle = article
    navigationController.pushViewController(detailVC, animated: true)
  }
}
```

Now you can run the app, (show) login, and select an article (show) -- all handled by the coordninator.

### Conclusion -- Talking Head

Ok, thats how to use a Coordinator to manage your screen transitions. Its a bit of work to setup, but once you're done, all the logic for your screen transitions is in one place. This makes the View Controllers more independent, and easier to reuse or move around. At some point there will be too many transitions for one class, and it makes sense to break them into smaller classes that manage one section of your app flow. I'll show you how to set that up in the next video.

## Chalenges -- Talking Head?

Can you implement the logout button on the article list screen? Give it a shot, and if you need a hint, check the implementation in the sample files. You can do it!