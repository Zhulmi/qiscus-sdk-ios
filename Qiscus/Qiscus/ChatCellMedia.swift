//
//  ChatCellMedia.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/24/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

open class ChatCellMedia: UITableViewCell {

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var displayFrame: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var downloadButton: ChatFileButton!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var dateLabelRightMargin: NSLayoutConstraint!
    @IBOutlet weak var progressHeight: NSLayoutConstraint!
    @IBOutlet weak var displayLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var displayWidth: NSLayoutConstraint!
    @IBOutlet weak var displayOverlay: UIView!
    @IBOutlet weak var downloadButtonTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var statusImageTrailing: NSLayoutConstraint!
    
    let defaultDateLeftMargin:CGFloat = -10
    var tapRecognizer: ChatTapRecognizer?
    let maxProgressHeight:CGFloat = 36.0
    var maskImage: UIImage?
    
    var screenWidth:CGFloat{
        get{
            return UIScreen.main.bounds.size.width
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        statusImage.contentMode = .scaleAspectFit
        progressContainer.layer.cornerRadius = 20
        progressContainer.clipsToBounds = true
        progressContainer.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65).cgColor
        progressContainer.layer.borderWidth = 2
        downloadButton.setImage(Qiscus.image(named: "ic_download_chat")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        downloadButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        self.imageDisplay.contentMode = .scaleAspectFill
        self.imageDisplay.clipsToBounds = true
        self.imageDisplay.backgroundColor = UIColor.black
        self.imageDisplay.isUserInteractionEnabled = true
        self.displayFrame.contentMode = .scaleAspectFill
        //let topColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.displayOverlay.verticalGradientColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0), bottomColor: UIColor.black)
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    open func setupCell(_ comment:QiscusComment, last:Bool, position:CellPosition){
        
        let file = QiscusFile.getCommentFileWithComment(comment)
        progressContainer.isHidden = true
        progressView.isHidden = true
        
        if self.tapRecognizer != nil{
            self.imageDisplay.removeGestureRecognizer(self.tapRecognizer!)
            self.tapRecognizer = nil
        }
        
        let thumbLocalPath = file?.fileURL.replacingOccurrences(of: "/upload/", with: "/upload/w_30,c_scale/")
        
        self.imageDisplay.image = nil

        maskImage = UIImage()
        var imagePlaceholder = Qiscus.image(named: "media_balloon")
        statusImageTrailing.constant = -5
        if last {
            displayWidth.constant = 147
            if position == .left{
                maskImage = Qiscus.image(named: "balloon_mask_left")!
                imagePlaceholder = Qiscus.image(named: "media_balloon_left")
                displayLeftMargin.constant = 4
                downloadButtonTrailing.constant = -46
                dateLabelRightMargin.constant = defaultDateLeftMargin
            }else{
                maskImage = Qiscus.image(named: "balloon_mask_right")!
                imagePlaceholder = Qiscus.image(named: "media_balloon_right")
                displayLeftMargin.constant = screenWidth - 166
                downloadButtonTrailing.constant = -61
                dateLabelRightMargin.constant = -41
                statusImageTrailing.constant = -20
            }
        }else{
            
            displayWidth.constant = 132
            maskImage = Qiscus.image(named: "balloon_mask")
            downloadButtonTrailing.constant = -46
            if position == .left{
                displayLeftMargin.constant = 19
                dateLabelRightMargin.constant = defaultDateLeftMargin
            }else{
                displayLeftMargin.constant = screenWidth - 166
                dateLabelRightMargin.constant = -25
            }
        }
        self.displayFrame.image = maskImage
        self.imageDisplay.image = imagePlaceholder
        
        dateLabel.text = comment.commentTime.lowercased()
        progressLabel.isHidden = true
        if position == .left {
            dateLabel.textColor = UIColor.white
            statusImage.isHidden = true
        }else{
            dateLabel.textColor = UIColor.white
            statusImage.isHidden = false
            statusImage.tintColor = UIColor.white
            if comment.commentStatus == QiscusCommentStatus.sending {
                dateLabel.text = QiscusTextConfiguration.sharedInstance.sendingText
                statusImage.image = Qiscus.image(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
            }else if comment.commentStatus == .sent || comment.commentStatus == .delivered {
                statusImage.image = Qiscus.image(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            }else if comment.commentStatus == .failed {
                dateLabel.text = QiscusTextConfiguration.sharedInstance.failedText
                dateLabel.textColor = QiscusColorConfiguration.sharedInstance.failToSendColor
                statusImage.image = Qiscus.image(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
                statusImage.tintColor = QiscusColorConfiguration.sharedInstance.failToSendColor
            }
            
        }
        self.downloadButton.removeTarget(nil, action: nil, for: .allEvents)
        
        if file != nil {
            if !file!.isLocalFileExist() {
                
                print("thumbLocalPath: \(thumbLocalPath)")
                self.imageDisplay.loadAsync(thumbLocalPath!)
                //self.imageDispay.image = UIImageView.maskImage(Qiscus.image(named: "testImage")!, mask: Qiscus.image(named: "balloon_mask_left")!)
                if file!.isDownloading {
                    self.downloadButton.isHidden = true
                    self.progressLabel.text = "\(Int(file!.downloadProgress * 100)) %"
                    self.progressLabel.isHidden = false
                    self.progressContainer.isHidden = false
                    self.progressView.isHidden = false
                    let newHeight = file!.downloadProgress * maxProgressHeight
                    self.progressHeight.constant = newHeight
                    self.progressView.layoutIfNeeded()
                }else{
                    self.downloadButton.comment = comment
                    //self.fileNameLabel.hidden = false
                    //self.fileIcon.hidden = false
                    self.downloadButton.addTarget(self, action: #selector(ChatCellMedia.downloadMedia(_:)), for: .touchUpInside)
                    self.downloadButton.isHidden = false
                }
            }else{
                self.downloadButton.isHidden = true
                //self.mediaDisplay.loadAsync("file://\(file!.fileThumbPath)")
                self.imageDisplay.loadAsync("file://\(file!.fileThumbPath)")
                if file!.isUploading{
                    self.progressContainer.isHidden = false
                    self.progressView.isHidden = false
                    let newHeight = file!.uploadProgress * maxProgressHeight
                    self.progressHeight.constant = newHeight
                    self.progressView.layoutIfNeeded()
                }
            }
        }
        //self.imageDispay.backgroundColor = UIColor.yellowColor()
    }
    
    open func downloadMedia(_ sender: ChatFileButton){
        sender.isHidden = true
        let service = QiscusCommentClient.sharedInstance
        service.downloadMedia(sender.comment!)
    }
    
    
}