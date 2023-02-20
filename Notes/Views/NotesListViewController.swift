//
//  NotesListViewController.swift
//  Notes
//
//  Created by Anton Vorozhischev on 16.02.2023.
//

import UIKit

class NotesListViewController: UIViewController {
    private lazy var notesTableView: UITableView = {
        let table = UITableView()
        return table
    }()

    private lazy var notesCountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "0 Notes"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var notesCountView = UIView(frame: .zero)

    private var allNotes: [Note] = [] {
        didSet {
            notesCountLabel.text = "\(allNotes.count) \(allNotes.count == 1 ? "Note" : "Notes")"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        notesCountView.addSubview(notesCountLabel)
        view.addSubview(notesCountView)
        configureNotesCountViewConstraints()
        configureNotesCountLabelConstraints()
        
        view.addSubview(notesTableView)
        configureNotesTableViewConstraints()
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        allNotes = CoreDataManager.shared.fetchNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar()
    }

    func configureNotesCountLabelConstraints() {
        notesCountLabel.bottomAnchor.constraint(equalTo: notesCountView.bottomAnchor, constant: 0).isActive = true
        notesCountLabel.topAnchor.constraint(equalTo: notesCountView.topAnchor, constant: 0).isActive = true
        notesCountLabel.leftAnchor.constraint(equalTo: notesCountView.leftAnchor, constant: 0).isActive = true
        notesCountLabel.rightAnchor.constraint(equalTo: notesCountView.rightAnchor, constant: 0).isActive = true
        notesCountLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func configureNotesTableViewConstraints() {
        notesTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        notesTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        notesTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        notesTableView.bottomAnchor.constraint(equalTo: notesCountView.topAnchor, constant: 0).isActive = true
        notesTableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureNotesCountViewConstraints() {
        notesCountView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        notesCountView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        notesCountView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        notesCountView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        notesCountView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        notesCountView.translatesAutoresizingMaskIntoConstraints = false
    }

    func configureNavigationBar() {
        self.title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = true
        
        let rightButtonIcon = UIImage(systemName: "square.and.pencil")
        
        let rightButton = UIButton()
        rightButton.setImage(rightButtonIcon, for: .normal)
        rightButton.addTarget(self, action: #selector(createNoteButtonTapped), for: .touchUpInside)
        rightButton.tag = 1

        navigationController?.navigationBar.addSubview(rightButton)

        let navigationBarView: UINavigationBar! = navigationController?.navigationBar
        rightButton.bottomAnchor.constraint(equalTo: navigationBarView.bottomAnchor, constant: -15).isActive = true
        rightButton.trailingAnchor.constraint(equalTo: navigationBarView.trailingAnchor, constant: -20).isActive = true
        rightButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func createNoteButtonTapped() {
        let note = CoreDataManager.shared.createNoteInViewContext()
        allNotes.insert(note, at: 0)
        notesTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)

        let noteDetailViewController = NoteDetailViewController()
        noteDetailViewController.note = note
        noteDetailViewController.delegate = self
        navigationController?.pushViewController(noteDetailViewController, animated: true)
    }
    
    func getIndexPath(by noteId: UUID) -> IndexPath {
        let row = Int(allNotes.firstIndex(where: { $0.id == noteId }) ?? 0)
        return IndexPath(row: row, section: 0)
    }
}

// MARK: - UITableViewDelegate
extension NotesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteDetailViewController = NoteDetailViewController()
        noteDetailViewController.delegate = self
        noteDetailViewController.note = allNotes[indexPath.row]
        navigationController?.pushViewController(noteDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = allNotes[indexPath.row]
            deleteNote(note.id)
            CoreDataManager.shared.deleteNoteFromStorage(note)
        }
    }
}

// MARK: - UITableViewDataSource
extension NotesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var content: UIListContentConfiguration = cell.defaultContentConfiguration()
        content.text = allNotes[indexPath.row].title
        content.secondaryText = allNotes[indexPath.row].content
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - NoteDetailViewControllerDelegate
extension NotesListViewController: NoteDetailViewControllerDelegate {
    func deleteNote(_ id: UUID) {
        let indexPath = getIndexPath(by: id)
        allNotes.remove(at: indexPath.row)
        notesTableView.deleteRows(at: [indexPath], with: .automatic)
    }

    func updateNote() {
        allNotes = allNotes.sorted { $0.lastUpdated > $1.lastUpdated }
        notesTableView.reloadData()
    }
}


