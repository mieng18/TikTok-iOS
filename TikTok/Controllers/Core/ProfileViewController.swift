//
//  ProfileViewController.swift
//  TikTok
//
//  Created by mai ng on 7/25/21.
//

import UIKit
import ProgressHUD

class ProfileViewController: UIViewController {
    
    var isCurrentUserProfile: Bool {
        if let username = UserDefaults.standard.string(forKey: "username") {
            return user.username.lowercased() == username.lowercased()
        }
        return false
    }
    
    enum PicturePickerType {
        case camera
        case photoLibrary
    }
    
    var user: User
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero
                                          , collectionViewLayout: layout)
        collection.backgroundColor = .systemBackground
        collection.showsVerticalScrollIndicator  = false
        collection.register(ProfileHeaderCollectionReusableView.self,
                            forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader ,
                            withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier)
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collection
    }()
    
    private var posts = [PostModel]()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    // MARK - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username.uppercased()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource =  self
        
        let username = UserDefaults.standard.string(forKey: "username")?.uppercased() ?? "Me"
        if title == username  {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "gear"),
                style: .done,
                target: self,
                action:#selector(didTapSettings))
        }
        fetchPost()
    }
    
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func fetchPost() {
        DatabaseManager.shared.getPosts(for: user) { [weak self] postModels in
            DispatchQueue.main.async {
                self?.posts = postModels
                self?.collectionView.reloadData()
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}


extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postModel = posts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemBlue
        
    return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // Open Post
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (view.width - 12)/3
        return CGSize(width: width, height: width * 1.5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind  == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier,
                for: indexPath) as? ProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        header.delegate = self
        print(user.profilePictureURL)
        
        let viewModel = ProfileHeaderViewModel(
            avatarImageURL: user.profilePictureURL,
            followerCount: 120,
            followingCount: 200,
            isFollowing: isCurrentUserProfile ? nil : false)
        header.configure(with: viewModel)
       
        return header
              
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 300)
    }
}
extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate{
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapPrimaryButtonWith viewModel: ProfileHeaderViewModel) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
           return
        }
        if self.user.username == currentUsername {
            // Edit Profile
        } else {
            // Follow or unfollow current users profile that we are viewing
        }
    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapFollowersButtonWith viewModel: ProfileHeaderViewModel) {
        
    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapFollowingButtonWith viewModel: ProfileHeaderViewModel) {
        
    }
    
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapAvatarFor viewModel: ProfileHeaderViewModel) {
        guard isCurrentUserProfile else {
            return
        }
        let actionSheet = UIAlertController(title: "Profile Picture", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {_ in
            DispatchQueue.main.async {
                self.presentProfilePicturePicker(type: .camera)
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {_  in
            DispatchQueue.main.async {
                self.presentProfilePicturePicker(type: .photoLibrary)

            }

        }))
        
        present(actionSheet,animated: true)
    }
    
    func presentProfilePicturePicker(type: PicturePickerType) {
        let picker = UIImagePickerController()
        picker.sourceType = type == .camera ? .camera :.photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
}


extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        ProgressHUD.show("Uploading")
        //upload an update UI
        StorageManager.shared.uploadProfilePicture(wiith: image) {[weak self] result in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let downloadURL):
                    UserDefaults.standard.setValue(downloadURL.absoluteString, forKey: "profile_picture_url")
                    strongSelf.user = User(
                        username: strongSelf.user.username,
                        profilePictureURL:downloadURL,
                        identifier: strongSelf.user.username)
                    ProgressHUD.showSuccess("Updated!")
                    strongSelf.collectionView.reloadData()

                case .failure:
                    ProgressHUD.showError("Failed to upload profile picture.")
                }
            }
            
        }
    }
    
}
