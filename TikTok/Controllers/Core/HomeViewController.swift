//
//  HomeViewController.swift
//  TikTok
//
//  Created by mai ng on 7/25/21.
//

import UIKit


class HomeViewController: UIViewController {
    
    private let  horizontialScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
         scrollView.isPagingEnabled = true
        return scrollView
        
    }()
    
    
     let control: UISegmentedControl = {
        let title = ["Following", "For You"]
        let control = UISegmentedControl(items:  title)
        control.selectedSegmentIndex = 1
        control.backgroundColor = nil
        control.selectedSegmentTintColor = .white
        return control
    }()
    
    let forYouPageViewController = UIPageViewController(transitionStyle: .scroll,
                                                navigationOrientation: .vertical,
                                                options: [:])
    let followingPageViewController = UIPageViewController(transitionStyle: .scroll,
                                                navigationOrientation: .vertical,
                                                options: [:])
    
    private var forYouPosts = PostModel.mockModels()
    private var followingPosts = PostModel.mockModels()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(horizontialScrollView)
        
        setUpFeed()
        horizontialScrollView.contentInsetAdjustmentBehavior = .never
        horizontialScrollView.delegate = self
        horizontialScrollView.contentOffset = CGPoint(x: view.width, y: 0)
        setUpHeaderButtons()
    }

    // Where we go ahead and give the scroll view a frame horizontal scroll view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        horizontialScrollView.frame = view.bounds
    }
    
    private func setUpFeed() {
        horizontialScrollView.contentSize = CGSize(width: view.width*2, height: view.height)
        setUpFollowingFeed()
        setUpForYouFeed()
      
        
    }
    
    func setUpFollowingFeed() {
        guard let model = followingPosts.first else {return }

        let vc = PostViewController(model: model)
        vc.delegate = self
        followingPageViewController.setViewControllers([vc],
                                            direction: .forward,
                                            animated: false,
                                            completion: nil)
        
        followingPageViewController.dataSource = self
        
        horizontialScrollView.addSubview(followingPageViewController.view)
        followingPageViewController.view.frame = CGRect(x: 0,
                                             y: 0,
                                             width: horizontialScrollView.width,
                                             height: horizontialScrollView.height)
        addChild(followingPageViewController)
        followingPageViewController.didMove(toParent: self)
        
    }
    
    func setUpForYouFeed() {
        guard let model = forYouPosts.first else {return }

        let vc = PostViewController(model: model)
                                    vc.delegate  = self
        forYouPageViewController.setViewControllers([vc],
                                            direction: .forward,
                                            animated: false,
                                            completion: nil)
        
        forYouPageViewController.dataSource = self
        
        horizontialScrollView.addSubview(forYouPageViewController.view)
        forYouPageViewController.view.frame = CGRect(x: view.width,
                                             y: 0,
                                             width: horizontialScrollView.width,
                                             height: horizontialScrollView.height)
        addChild(forYouPageViewController)
        forYouPageViewController.didMove(toParent: self)
    }
    
    func setUpHeaderButtons() {

        control.addTarget(self, action: #selector(didChangeSegmentControl(_:)), for: .valueChanged)
        navigationItem.titleView = control
        
    }
    @objc private func didChangeSegmentControl(_ sender: UISegmentedControl){
        horizontialScrollView.setContentOffset(CGPoint(x: view.width * CGFloat(sender.selectedSegmentIndex),
                                                       y: 0),
                                               animated: true)
    }

}


extension HomeViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let fromPost = (viewController as? PostViewController)?.model else {
            return nil
        }
        guard let index = currentPosts.firstIndex(where: {$0.identifier == fromPost.identifier}) else {
            return nil
        }
        
        if index == 0 {
            return nil
        }
        let priorIndex = index - 1
        let model = currentPosts[priorIndex]
        let vc = PostViewController(model: model)
        vc.delegate = self

        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let fromPost = (viewController as? PostViewController)?.model else {
            return nil
        }
        guard let index = currentPosts.firstIndex(where: {$0.identifier == fromPost.identifier}) else {
            return nil
        }
        
        // Need to be less than the last element in the actual array
        guard  index < (currentPosts.count - 1) else {
            return nil
        }
        
        let nextIndex = index + 1
        let model = currentPosts[nextIndex]
        let vc = PostViewController(model: model)
        vc.delegate = self
        return vc
    }
    
    var currentPosts: [PostModel] {
        if horizontialScrollView.contentOffset.x == 0 {
            // We on following page , which mean we all the way the left
            return followingPosts
        }
        
        return followingPosts
    }
    
}


extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 || scrollView.contentOffset.x <= (view.width/2){
            control.selectedSegmentIndex = 0
            
        } else if scrollView.contentOffset.x > (view.width/2) {
            control.selectedSegmentIndex = 1
        }
    }
}

extension HomeViewController: PostViewControllerDelegate {
    func postViewController(_ vc: PostViewController, didTapCommentButtonFor post: PostModel) {
        horizontialScrollView.isScrollEnabled = false
        if horizontialScrollView.contentOffset.x == 0 {
            // following feed
            followingPageViewController.dataSource = nil
        } else {
            forYouPageViewController.dataSource = nil
        }
        
        HapticsManager.shared.vibrateForSelection()
        
        let vc = CommentsViewController(post: post)
        vc.delegate = self
        
        addChild(vc)
        vc.didMove(toParent: self)
        view.addSubview(vc.view)
        
        let frame : CGRect = CGRect(x: 0, y: view.height, width: view.width, height: view.height*0.76)
        vc.view.frame = frame
        UIView.animate(withDuration: 0.2) {
            vc.view.frame = CGRect(x: 0, y: self.view.height - frame.height, width: frame.width, height: frame.height)
        }
    }
    
    func postViewController(_ vc: PostViewController, didTapProfileButtonFor post: PostModel){
        let user = post.user
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
        
    }
}


extension HomeViewController: CommentsViewControllerDelegate {
    func didTapCloseForComments(with viewController: CommentsViewController) {
        // close comments with animation
    
        
        let frame = viewController.view.frame
        UIView.animate(withDuration: 0.2) {
            viewController.view.frame = CGRect(x: 0, y: self.view.height, width: frame.width, height: frame.height)
        
        } completion: { [weak self] done in
            if done {
                DispatchQueue.main.async {
                    // remove commentvc as child

                    viewController.view.removeFromSuperview()
                    viewController.removeFromParent()
                    // allow horizontal and vertival scroll
                    self?.horizontialScrollView.isScrollEnabled = true
                    self?.forYouPageViewController.dataSource = self
                    self?.followingPageViewController.dataSource = self

                }
            }
        }
    } 
}


