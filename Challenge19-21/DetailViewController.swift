import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    var currentNote: String?
    var currentNoteKey: String?
    var notesCopy = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        navigationController?.navigationBar.tintColor = UIColor.systemYellow
        textView.tintColor = UIColor.systemYellow
        
        if let currentNote = self.currentNote {
            textView.text = currentNote
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "TableView") as? ViewController {
            if let currentNoteKey = self.currentNoteKey {
                notesCopy[currentNoteKey] = textView.text
                vc.notes = notesCopy
                vc.saveNotes()
                navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    @objc func shareTapped() {
        if let note = textView.text {
            let vc = UIActivityViewController(activityItems: [note], applicationActivities: [])
            present(vc, animated: true)
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        textView.scrollIndicatorInsets = textView.contentInset

        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
}
