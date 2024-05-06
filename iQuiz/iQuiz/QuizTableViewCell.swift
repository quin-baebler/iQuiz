//
//  QuizTableViewCell.swift
//  iQuiz
//
//  Created by Quinton Baebler on 5/5/24.
//

import UIKit

class QuizTableViewCell: UITableViewCell {

    static let identifier = "QuizTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "QuizTableViewCell", bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var topicImage: UIImageView!
    @IBOutlet weak var topicTitle: UILabel!
    @IBOutlet weak var topicDesc: UILabel!
}
