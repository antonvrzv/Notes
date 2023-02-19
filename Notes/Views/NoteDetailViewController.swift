//
//  NoteDetailViewController.swift
//  Notes
//
//  Created by Anton Vorozhischev on 16.02.2023.
//

import UIKit

protocol NoteDetailViewControllerDelegate: AnyObject {
    func deleteNote(_ id: UUID)
    func updateNote()
}

class NoteDetailViewController: UIViewController {
    private lazy var noteTextView: UITextView = UITextView()

    var note: Note!
    var delegate: NoteDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noteTextView)
        configureTextViewConstraints()
        noteTextView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeRightButtonFromNavigationBar()
        noteTextView.text = note?.text
    }
    
    override func viewDidAppear(_ animated: Bool) {
        noteTextView.becomeFirstResponder()
    }
    
    func removeRightButtonFromNavigationBar() {
        guard let navigationBarItems = navigationController?.navigationBar.subviews else { return }
        for navigationBarItem in navigationBarItems {
            if navigationBarItem.tag != 0 {
                navigationBarItem.removeFromSuperview()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func configureTextViewConstraints() {
        noteTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        noteTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        noteTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        noteTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - UITextViewDelegate
extension NoteDetailViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        note.text = textView.text

        if note.text.isEmpty {
            delegate?.deleteNote(note.id)
            CoreDataManager.shared.deleteNoteFromStorage(note)
        }
        else {
            note.lastUpdated = Date()
            CoreDataManager.shared.saveContextToStore()
            delegate?.updateNote()
        }
    }
}
