//
//  MainMenuViewControllerViewController.swift
//  Puzzle
//
//  Created by roman on 1/10/25.
//
import UIKit
class MainMenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let startButton = UIButton(type: .system)
    private let photoSourceSegmentedControl = UISegmentedControl(items: ["Choose from library", "https://picsum.photos/1024"])
    private let previewImageView = UIImageView()
    private let difficultySegmentedControl = UISegmentedControl(items: ["3×3", "6×6", "9×9"])
    private let loadImageButton = UIButton(type: .system)
    private var selectedImage: UIImage?
    private var previewImageViewWidthConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.layer.borderColor = UIColor.lightGray.cgColor
        previewImageView.layer.cornerRadius = 10
        previewImageView.clipsToBounds = true
        previewImageView.contentMode = .scaleAspectFit
        view.addSubview(previewImageView)
        
        loadImageButton.setTitle("Choose a photo", for: .normal)
        loadImageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        loadImageButton.backgroundColor = .systemGreen
        loadImageButton.setTitleColor(.white, for: .normal)
        loadImageButton.layer.cornerRadius = 10
        loadImageButton.addTarget(self, action: #selector(loadImageButtonTapped), for: .touchUpInside)
        view.addSubview(loadImageButton)
        
        photoSourceSegmentedControl.selectedSegmentIndex = 1
        photoSourceSegmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        view.addSubview(photoSourceSegmentedControl)
        
        difficultySegmentedControl.selectedSegmentIndex = 0
        difficultySegmentedControl.selectedSegmentTintColor = UIColor.systemOrange
        view.addSubview(difficultySegmentedControl)
        
        startButton.setTitle("Start", for: .normal)
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 10
        startButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)
        
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        loadImageButton.translatesAutoresizingMaskIntoConstraints = false
        photoSourceSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        difficultySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            previewImageView.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            previewImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            previewImageView.heightAnchor.constraint(lessThanOrEqualTo: previewImageView.widthAnchor),
            previewImageView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
            photoSourceSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoSourceSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            photoSourceSegmentedControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            photoSourceSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            
            difficultySegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            difficultySegmentedControl.topAnchor.constraint(equalTo: photoSourceSegmentedControl.bottomAnchor, constant: 20),
            difficultySegmentedControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            difficultySegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            
            loadImageButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            loadImageButton.topAnchor.constraint(equalTo: difficultySegmentedControl.bottomAnchor, constant: 20),
            loadImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            loadImageButton.heightAnchor.constraint(equalToConstant: 44),
            
            startButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -22),
            startButton.topAnchor.constraint(equalTo: difficultySegmentedControl.bottomAnchor, constant: 20),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            startButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func loadImageButtonTapped() {
        if photoSourceSegmentedControl.selectedSegmentIndex == 0 {
            presentImagePicker()
        } else {
            loadImageFromAPI()
        }
    }
    
    private func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func loadImageFromAPI() {
        let url = URL(string: "https://picsum.photos/1024")!
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Image loading error:", error ?? "No data")
                return
            }
            DispatchQueue.main.async {
                self?.previewImageView.image = image
                self?.selectedImage = image
            }
        }
        task.resume()
    }
    
    @objc private func startGameButtonTapped() {
        let selectedDifficultyIndex = difficultySegmentedControl.selectedSegmentIndex
        let difficulty: Int
        switch selectedDifficultyIndex {
        case 0: difficulty = 3
        case 1: difficulty = 6
        case 2: difficulty = 9
        default: difficulty = 3
        }
        
        if selectedImage == nil {
            let alert = UIAlertController(title: "Error", message: "Please select an image to play with.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
    
        let gameVC = GameViewController()
        gameVC.imageToUse = selectedImage
        gameVC.difficulty = difficulty
        navigationController?.pushViewController(gameVC, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        dismiss(animated: true, completion: nil)
        previewImageView.image = selectedImage
        self.selectedImage = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
