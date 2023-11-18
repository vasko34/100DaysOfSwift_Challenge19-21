import UIKit

class ViewController: UITableViewController {
    var notes = [String: String]()
    var selectedNotes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(loadNotes), with: nil)
        
        tableView.allowsMultipleSelectionDuringEditing = true
        navigationController?.navigationBar.tintColor = UIColor.systemYellow
        title = "Notes"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        let delButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        doneButton.isHidden = true
        navigationItem.rightBarButtonItems = [doneButton, addButton, delButton]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem?.isHidden = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.keys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var keysArray = Array(notes.keys)
        keysArray.sort()
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        cell.textLabel?.text = keysArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var keysArray = Array(notes.keys)
        keysArray.sort()
        
        if tableView.isEditing == true {
            selectedNotes.append(keysArray[indexPath.row])
        } else {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
                vc.currentNoteKey = keysArray[indexPath.row]
                vc.currentNote = notes[keysArray[indexPath.row]]
                vc.notesCopy = notes
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var keysArray = Array(notes.keys)
        keysArray.sort()
        
        if tableView.isEditing == true {
            for (index, note) in selectedNotes.enumerated().reversed() {
                if note == keysArray[indexPath.row] {
                    selectedNotes.remove(at: index)
                }
            }
        }
    }
    
    @objc func addButtonTapped() {
        let ac = UIAlertController(title: "Enter name:", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            if let textField = ac?.textFields?[0].text {
                self?.notes[textField] = ""
                self?.saveNotes()
                self?.tableView.reloadData()
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func deleteButtonTapped() {
        navigationItem.leftBarButtonItem?.isHidden = false
        if let rightBarButtonItems = navigationItem.rightBarButtonItems {
            for item in rightBarButtonItems {
                item.isHidden.toggle()
            }
        }
        tableView.setEditing(true, animated: true)
    }
    
    @objc func doneButtonTapped() {
        if !selectedNotes.isEmpty {
            let ac = UIAlertController(title: "Are you sure you want to delete these notes?", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                if let selectedNotes = self?.selectedNotes {
                    for note in selectedNotes {
                        self?.notes.removeValue(forKey: note)
                    }
                    self?.saveNotes()
                    self?.tableView.reloadData()
                }
                self?.cancelButtonTapped()
            })
            ac.addAction(UIAlertAction(title: "No", style: .cancel))
            present(ac, animated: true)
        } else {
            cancelButtonTapped()
        }
    }
    
    @objc func cancelButtonTapped() {
        navigationItem.leftBarButtonItem?.isHidden = true
        if let rightBarButtonItems = navigationItem.rightBarButtonItems {
            for item in rightBarButtonItems {
                item.isHidden.toggle()
            }
        }
        selectedNotes.removeAll()
        tableView.setEditing(false, animated: true)
    }
    
    func saveNotes() {
        let defaults = UserDefaults.standard
        let jsonEncoder = JSONEncoder()
        if let savedNotes = try? jsonEncoder.encode(notes) {
            defaults.setValue(savedNotes, forKey: "notes")
        }
    }
    
    @objc func loadNotes() {
        let defaults = UserDefaults.standard
        let jsonDecoder = JSONDecoder()
        if let notesToLoad = defaults.object(forKey: "notes") as? Data {
            do {
                notes = try jsonDecoder.decode([String: String].self, from: notesToLoad)
            } catch {
                print("Failed to load notes.")
            }
        }
    }
}

