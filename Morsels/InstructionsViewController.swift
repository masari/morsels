import UIKit

class InstructionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func setupViews() {
        view.backgroundColor = .systemBackground
        title = "Instructions"

        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let instructionsText = """
        How to Play Morsels

        The Goal:
        Listen to the Morse code and save the falling pigs by tapping them in the correct order before they fall into the grill!

        Gameplay:
        1. Listen Up!
           At the start of each round, a sequence of letters will be played in Morse code. Listen carefully to the pattern of short "dits" (.) and long "dahs" (-).

        2. Save the Pigs!
           After the code is played, pigs with letters on them will begin to fall from the top of the screen.

        3. Tap in Order
           Tap the falling pigs in the exact same sequence as the Morse code you heard.

        Scoring Big:
        • Correct Taps: You earn 10 points for every pig you tap in the correct sequence.
        • Perfect Round Bonus: If you save all the pigs in a round without any mistakes, you'll earn a massive bonus of 50 points per pig!
        • Streak Bonus: String together three perfect rounds to activate a special scoring bonus that grows with your streak!

        Watch Out!
        • Wrong Tap: Tapping a pig out of order will trigger a brief penalty, and you won't be able to tap any other pigs for a moment.
        • Don't Let Them Become Dinner! Any pig that falls into the barbecue grill is lost.
        • Three Strikes: If you don't save any pigs correctly in a round, it counts as a strike. Three strikes and the game is over!

        Become a Morse Master:
        The game is designed to help you learn! You'll start with just a few basic letters. As the game sees you mastering them, it will automatically introduce new letters to learn.
        """
        
        textView.text = instructionsText
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ])
    }
}