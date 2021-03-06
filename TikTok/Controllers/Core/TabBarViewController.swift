//
//  TabBarViewController.swift
//  TikTok
//
//  Created by mai ng on 7/25/21.
//

import UIKit

class TabBarViewController: UITabBarController {

    private var signInPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpController()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !signInPresented {
            presentSignInIfNeeded()

        }
        
    }
    

    private func presentSignInIfNeeded(){
        if !AuthManager.shared.isSignedIn{
            signInPresented = true
            let vc = SignInViewController()
            
          // Once the VC has bsically dismiss itself a.k.a the user has signed in & we got rid of the controller
            vc.completion = { [weak self] in
                
                self?.signInPresented = false
            }
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: false, completion: nil)
//            
        }
    }

    
    private func setUpController() {
        
        let home = HomeViewController()
        let explore = ExploreViewController()
        let camera = CameraViewController()
        let notifications = NotificationsViewController()
        
        var urlString: String?
        if let cachedUrlString = UserDefaults.standard.string(forKey: "profile_picture_url") {
            urlString = cachedUrlString
        }
        
        let profile = ProfileViewController(user: User(username: UserDefaults.standard.string(forKey: "username")?.uppercased() ?? "Me",
                                                       profilePictureURL: URL(string:urlString ?? ""),
                                                       identifier: UserDefaults.standard.string(forKey: "username")?.lowercased() ?? ""))
        
//        home.title = "Home"
//        explore.title = "Explore"
        notifications.title = "Notification"
        profile.title = "Profile"
        
        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: explore)
        let nav3 = UINavigationController(rootViewController:  notifications)
        let nav4 = UINavigationController(rootViewController: profile)
        let cameraNav = UINavigationController(rootViewController:  camera)
        

        
        nav1.navigationBar.backgroundColor = .clear
        nav1.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nav1.navigationBar.shadowImage = UIImage()
        
        cameraNav.navigationBar.backgroundColor = .clear
        cameraNav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        cameraNav.navigationBar.shadowImage = UIImage()
        cameraNav.navigationBar.tintColor = .white
        
        nav3.navigationBar.tintColor = .label
    

        
        nav1.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "safari"), tag: 2)
        camera.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "camera"), tag: 3)
        nav3.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "bell"), tag: 4)
        nav4.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.circle"), tag: 5)
        
        if #available(iOS 14.0, *) {
            nav1.navigationItem.backButtonDisplayMode = .minimal
            nav2.navigationItem.backButtonDisplayMode = .minimal
            nav3.navigationItem.backButtonDisplayMode = .minimal
            nav4.navigationItem.backButtonDisplayMode = .minimal
            cameraNav.navigationItem.backButtonDisplayMode = .minimal

        }
        nav4.navigationBar.tintColor = .label

        setViewControllers([nav1, nav2,cameraNav, nav3, nav4], animated: false)
    }

}
