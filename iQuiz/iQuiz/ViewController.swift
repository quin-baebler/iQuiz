//
//  ViewController.swift
//  iQuiz
//
//  Created by Quinton Baebler on 5/5/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var TableView: UITableView!
    
    let quizTopics = [
        QuizTopic(title: "Mathematics", description: "Test your math skills", icon: UIImage(named: "mathicon")!),
        QuizTopic(title: "Marvel Super Heroes", description: "Discover your superhero knowledge", icon: UIImage(named: "sheroicon")!),
        QuizTopic(title: "Science", description: "Explore scientific wonders", icon: UIImage(named: "science")!)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
        TableView.register(UINib(nibName: "QuizTableViewCell", bundle: nil), forCellReuseIdentifier: "QuizTableViewCell")
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizTopics.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Return the desired height for cells
        return 160 // For example, set a fixed height of 100 points
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuizTableViewCell", for: indexPath) as? QuizTableViewCell else {
            fatalError("Could not dequeue cell with identifier QuizCell")
        }
        let qTopic = quizTopics[indexPath.row]
//        print("Debugging Cell \(indexPath.row):")
//            print("Title: \(qTopic.title)")
//            print("Description: \(qTopic.description)")
        cell.topicTitle.text = qTopic.title
        cell.topicDesc.text = qTopic.description
        cell.topicImage.image = qTopic.icon
        
       
    
        return cell
     
    }

    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Settings", message: "Settings go here", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

struct QuizTopic {
    let title: String
    let description: String
    let icon: UIImage
}




