//
//  ViewController.swift
//  iQuiz
//
//  Created by Quinton Baebler on 5/5/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var TableView: UITableView!
    
    var quizTopics: [QuizTopic] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
        TableView.register(UINib(nibName: "QuizTableViewCell", bundle: nil), forCellReuseIdentifier: "QuizTableViewCell")
        NetworkManager.shared
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetch()
    }
    
    func fetch() {
        //spinner.isHidden = false
       // spinner.startAnimating()
        
        if !NetworkManager.shared.isConnected {
                    let alertController = UIAlertController(title: "No Internet Connection", message: "Please check your network settings and try again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
        
        DispatchQueue.global().async {
            NSLog("Inside global().async")
            
            
            let userDefaults = UserDefaults.standard
                    let defaultURLString = "https://tednewardsandbox.site44.com/questions.json"
                    let urlString = userDefaults.string(forKey: "quiz_url") ?? defaultURLString
            // Issue a GET request to fetch JSON from the specified URL
            guard let url = URL(string: urlString) else {
                NSLog("Invalid URL")
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    NSLog("Error! \(error)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                    NSLog("Error! \(response)")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let quizDataArray = try decoder.decode([QuizTopic].self, from: data!)
                    
            

                    DispatchQueue.main.async {
                        NSLog("Inside main.async")
                        self.quizTopics = quizDataArray
                                           // Reload table view or update UI as needed
                        self.TableView.reloadData()
                        
                    }
                } catch {
                    NSLog("Error decoding JSON: \(error)")
                }
                
                NSLog("After main.async")
            }
            task.resume()
            NSLog("Task resumed")
        }
    }
    @IBAction func unwindToViewController(_ segue: UIStoryboardSegue) {
        // Any cleanup code you may need
    }

    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizTopics.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuizTableViewCell", for: indexPath) as? QuizTableViewCell else {
            fatalError("Could not dequeue cell with identifier QuizCell")
        }
        let qTopic = quizTopics[indexPath.row]
        cell.topicTitle.text = qTopic.title
        cell.topicDesc.text = qTopic.desc
        cell.topicImage.image = UIImage(named: "sheroicon")!//qTopic.icon
        
        return cell
     
    }

    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Settings", message: "Settings go here", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected topic
        let selectedTopic = quizTopics[indexPath.row]
        
        // Perform the segue to the question view controller
        performSegue(withIdentifier: "showQuestion", sender: selectedTopic)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQuestion" {
            // Get the destination view controller
            guard let questionVC = segue.destination as? QuestionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // Pass the selected topic to the question view controller
            if let selectedTopic = sender as? QuizTopic {
                questionVC.selectedTopic = selectedTopic
                questionVC.currentQuestionIndex = 0
                questionVC.numberOfCorrectAnswers = 0
            }
        }
    }

}

class SettingsViewController: UIViewController {
    
    //@IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var customUrl: UITextField!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var btnFetch: UIButton!

    override func viewDidLoad() {
         super.viewDidLoad()
        
        lblResult.text = "(Nothing fetched yet)"
    }
    @IBAction func fetchPressed(_ sender: Any) {
           fetch()
       }
       
       
       func fetch() {
           
           self.lblResult.text = "Fetching..."
           btnFetch.setTitle("Busy...", for: .normal)
           btnFetch.isEnabled = false
           DispatchQueue.global().async { [self] in
               NSLog("Inside global().async")
               
               guard let urlString = self.customUrl.text, let url = URL(string: urlString) else {
                           NSLog("Invalid URL")
                           return
               }
               
               let task = URLSession.shared.dataTask(with: url) { data, response, error in
                   if let error = error {
                       NSLog("Error! \(error)")
                       return
                   }
                   guard let httpResponse = response as? HTTPURLResponse,
                       (200...299).contains(httpResponse.statusCode) else {
                       NSLog("Error! \(response)")
                       return
                   }

                   do {
                       let decoder = JSONDecoder()
                       let quizDataArray = try decoder.decode([QuizTopic].self, from: data!)
                       
            

                       DispatchQueue.main.async {
                           NSLog("Inside main.async")
                           self.btnFetch.setTitle("Fetch", for: .normal)
                           self.btnFetch.isEnabled = true
                           //self.quizTopics = quizDataArray
                                              // Reload table view or update UI as needed
                           //self.TableView.reloadData()
                               
                           }
                       
                   } catch {
                       NSLog("Error decoding JSON: \(error)")
                   }
                   
                   NSLog("After main.async")
               }
               task.resume()
               NSLog("Task resumed")
           }
       }
    
}


struct QuizTopic: Codable {
    let title: String
    let desc: String
    let questions: [Question]
}

struct Question: Codable {
    let text: String
    let answer: String
    let answers: [String]
}

class QuestionViewController: UIViewController {
    
    var selectedTopic: QuizTopic?
    var selectedAnswerIndex: Int? // Property to store selected answer index
    var currentQuestionIndex: Int? 
    var numberOfCorrectAnswers: Int?// To track the index of the current question
    
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet var answerButtons: [UIButton]! // Outlet for answer buttons
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Load the first question
        loadQuestion()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(submitButtonSwipe(_:)))
           swipeRight.direction = .right
           view.addGestureRecognizer(swipeRight)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
               swipeGesture.direction = .left
               view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
            if gesture.direction == .left {
                performSegue(withIdentifier: "returnHome", sender: self)
            }
        }
    
    @objc func submitButtonSwipe(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "showAnswer", sender: nil)
    }
    
    func loadQuestion() {
        // Check if there are questions and if the current question index is valid
        guard let questions = selectedTopic?.questions, currentQuestionIndex! < questions.count else {
            return
        }
        
        // Get the current question
        let currentQuestion = questions[currentQuestionIndex!]
        // Set question text
        questionLabel.text = currentQuestion.text
        
        // Set answer choices for buttons
        for (index, answer) in currentQuestion.answers.enumerated() {
            answerButtons[index].setTitle(answer, for: .normal)
        }
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {

        if sender.isSelected {
                // If the tapped button is already selected, deselect it and return
                sender.isSelected = false
                sender.backgroundColor = UIColor.clear // Reset background color
                selectedAnswerIndex = nil // Clear selected answer index
                return
            }
            
            // Set the background color of the tapped button to blue to indicate selection
            sender.backgroundColor = UIColor.blue
            
            // Deselect all other buttons
            for button in answerButtons {
                if button != sender {
                    button.isSelected = false
                    button.backgroundColor = UIColor.clear // Reset background color of other buttons
                }
            }
            
            // Set the selected answer index
            selectedAnswerIndex = answerButtons.firstIndex(of: sender)
    }
        // Get the selected answer index
    @IBAction func submitButtonTapped(_ sender: UIButton) {
                // Perform segue to answer view controller
        performSegue(withIdentifier: "showAnswer", sender: nil)
    }
            
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAnswer" {
            guard let answerVC = segue.destination as? AnswerViewController else {
                return
            }
                    
                    // Pass necessary information to answer view controller
            answerVC.selectedTopic = selectedTopic
            answerVC.selectedAnswerIndex = selectedAnswerIndex
            answerVC.currentQuestionIndex = currentQuestionIndex
            answerVC.numberOfCorrectAnswers = numberOfCorrectAnswers
        }
    }
}

class AnswerViewController: UIViewController {
    var selectedTopic: QuizTopic?
    var selectedAnswerIndex: Int?
    var currentQuestionIndex: Int?
    var numberOfCorrectAnswers: Int?
    
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
            super.viewDidLoad()
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(nextButtonSwiped(_:)))
            swipeRight.direction = .right
            view.addGestureRecognizer(swipeRight)
        
            guard let selectedTopic = selectedTopic,
                  let currentQuestionIndex = currentQuestionIndex,
                  let selectedAnswerIndex = selectedAnswerIndex else {
                return
            }
            
            // Get the current question
            let currentQuestion = selectedTopic.questions[currentQuestionIndex]
            
            // Display the question
            questionLabel.text = currentQuestion.text
            
            // Display the selected answer
        
        answerLabel.text = "Correct Answer: \(currentQuestion.answers[Int(currentQuestion.answer)!-1])"
            
            // Compare selected answer index with correct answer index
            if selectedAnswerIndex + 1 == Int(currentQuestion.answer) {
                numberOfCorrectAnswers! += 1
                resultLabel.text = "Correct!"
            } else {
                resultLabel.text = "Incorrect"
            }
            
            // Update next button text based on whether there are more questions
            if currentQuestionIndex + 1 < selectedTopic.questions.count {
                nextButton.setTitle("Next Question", for: .normal)
            } else {
                nextButton.setTitle("Finish", for: .normal)
            }
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
               swipeGesture.direction = .left
               view.addGestureRecognizer(swipeGesture)
        }
    
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
            if gesture.direction == .left {
                performSegue(withIdentifier: "returnHome", sender: self)
            }
        }
    
    
    
    @objc func nextButtonSwiped(_ sender: UISwipeGestureRecognizer) {
        if let currentQuestionIndex = currentQuestionIndex,
               currentQuestionIndex + 1 < selectedTopic?.questions.count ?? 3 {
            performSegue(withIdentifier: "showQuestion", sender: nil)
        } else {
            performSegue(withIdentifier: "showResult", sender: nil)
        }
    }
    @IBAction func nextButtonTapped(_ sender: UIButton) {
            // Check if there are more questions
        if let currentQuestionIndex = currentQuestionIndex,
               currentQuestionIndex + 1 < selectedTopic?.questions.count ?? 3 {
                performSegue(withIdentifier: "showQuestion", sender: nil)
            } else {
                // Finish quiz
                performSegue(withIdentifier: "showResult", sender: nil)
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "showResult" {
               guard let finishedVC = segue.destination as? FinishedViewController else {
                   return
               }
               
               // Pass necessary information to FinishedViewController
               finishedVC.numberOfCorrectAnswers = numberOfCorrectAnswers!
               if let totalQuestions = selectedTopic?.questions.count {
                   finishedVC.totalNumberOfQuestions = totalQuestions
               }
           } else if segue.identifier == "showQuestion" {
               guard let questionVC = segue.destination as? QuestionViewController else {
                   return
               }
               questionVC.currentQuestionIndex = currentQuestionIndex! + 1
               questionVC.selectedTopic = selectedTopic
               questionVC.numberOfCorrectAnswers = numberOfCorrectAnswers
           }
       }
}

class FinishedViewController: UIViewController {
    var numberOfCorrectAnswers: Int = 0
    var totalNumberOfQuestions: Int = 0
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Calculate the percentage of correct answers
        let percentage = Int((Double(numberOfCorrectAnswers) / Double(totalNumberOfQuestions)) * 100)
        
        // Display descriptive text based on performance
        if percentage == 100 {
            resultLabel.text = "Perfect!"
        } else if percentage >= 75 {
            resultLabel.text = "Great job!"
        } else if percentage >= 50 {
            resultLabel.text = "Not bad!"
        } else {
            resultLabel.text = "Keep practicing!"
        }
        
        // Display user's score
        scoreLabel.text = "\(numberOfCorrectAnswers) of \(totalNumberOfQuestions) correct"
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        // Navigate to the next screen or perform any other action as needed
    }
}





