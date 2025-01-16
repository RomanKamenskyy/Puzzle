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
    private let loadImageButton = UIButton(type: .system)
    
    private var selectedImage: UIImage?
    private var previewImageViewWidthConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        previewImageView.contentMode = .scaleAspectFit
        setupUI()
    }
    
    private func setupUI() {
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.layer.borderColor = UIColor.lightGray.cgColor
        previewImageView.layer.cornerRadius = 10
        previewImageView.clipsToBounds = true
    
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
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            previewImageView.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            previewImageView.widthAnchor.constraint(equalToConstant: 200),
            previewImageView.heightAnchor.constraint(equalToConstant: 200),
         
            photoSourceSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoSourceSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            photoSourceSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            
            loadImageButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            loadImageButton.topAnchor.constraint(equalTo: photoSourceSegmentedControl.bottomAnchor, constant: 20),
            loadImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            loadImageButton.heightAnchor.constraint(equalToConstant: 50),
   
            startButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -22),
            startButton.topAnchor.constraint(equalTo: photoSourceSegmentedControl.bottomAnchor, constant: 20),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            startButton.heightAnchor.constraint(equalToConstant: 50)
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
        if selectedImage == nil {
            let alert = UIAlertController(title: "Error", message: "Please select an image to play with.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        let gameVC = GameViewController()
        gameVC.imageToUse = selectedImage
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
