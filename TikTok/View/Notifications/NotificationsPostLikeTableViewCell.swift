//
//  NotificationsPostLikeTableViewCell.swift
//  TikTok
//
//  Created by mai nguyen on 12/14/21.
//

import UIKit

protocol NotificationPostLikeTableViewCellDelegate: AnyObject {
    func notificationPostLikeTableViewCell(_ cell: NotificationPostLikeTableViewCell,
                                           didTapPostWith identifier:String)
}

class NotificationPostLikeTableViewCell: UITableViewCell {
    static let identifier = "NotificationPostLikeTableViewCell"
    
    weak var delegate: NotificationPostLikeTableViewCellDelegate?
    var postID: String?
    
    private let postThumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .label
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(postThumbnailImageView)
        contentView.addSubview(label)
        contentView.addSubview(dateLabel)
        selectionStyle = .none
        postThumbnailImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPost))
        postThumbnailImageView.addGestureRecognizer(tap)
    }
    
    
    @objc func didTapPost() {
        guard let id = postID else {
            return
        }
        delegate?.notificationPostLikeTableViewCell(self, didTapPostWith: id)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconSize:CGFloat = 50
        postThumbnailImageView.frame = CGRect(
            x: contentView.width - 50,
            y: 3,
            width: 50,
            height: contentView.height - 6
        )


       
        label.sizeToFit()
        dateLabel.sizeToFit()
        let labelSize = label.sizeThatFits(CGSize(
                                            width: contentView.width - 10 - postThumbnailImageView.width - 5,
                                            height: contentView.height - 40))
        label.frame = CGRect(
            x:  10,
            y: 0,
            width: label.width,
            height: label.height
        )
        dateLabel.frame = CGRect(
            x: 10,
            y: label.bottom + 3,
            width:contentView.width - postThumbnailImageView.width ,
            height:40
        )

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postThumbnailImageView.image = nil
        label.text = nil
        dateLabel.text = nil
    }
    
    func configure(with postFileName: String, model: Notification) {
        postThumbnailImageView.image = UIImage(named: "test")
        label.text = model.text
        dateLabel.text = .date(with: model.date)
        postID = postFileName
    }
}