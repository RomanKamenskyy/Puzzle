//
//  GameViewController.swift
//  Puzzle
//
//  Created by roman on 1/10/25.
//

import UIKit

struct Tile {
    let id: Int
    var currentFrame: CGRect
    let correctFrame: CGRect
    let correctIndex: Int
    let image: UIImage
    var isLocked: Bool = false
    var name: String
    var associatedButton: UIButton?
}

class GameViewController: UIViewController {
    var puzzleImageView: UIImageView!
    var puzzleGrid: UIView!
    var tiles: [Tile] = []
    var tileButtons: [UIButton] = []
    var tileSize: CGSize!
    var firstSelectedTile: UIButton?
    var draggedTile: UIButton?
    var draggedTileOriginalPosition: CGRect?
    var imageToUse: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPuzzleGrid()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        loadImage()
        
        UIView.animate(withDuration: 1.5) {
            self.shufflePuzzle()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.puzzleGrid.layoutIfNeeded()
            self.updateTileLayout()
            self.updateTileButtons()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateTileLayout()
    }
    
    func loadImage() {
        if let image = imageToUse {
                print("The image has been successfully uploaded: \(image)")
                splitImageIntoTiles(image: image)
            } else {
                print("There is no image to play")
            }
    }
    
    func setupPuzzleGrid() {
        puzzleGrid = UIView()
        puzzleGrid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(puzzleGrid)

        NSLayoutConstraint.activate([
                puzzleGrid.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                puzzleGrid.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                puzzleGrid.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                puzzleGrid.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
    }
    
    func splitImageIntoTiles(image: UIImage) {
        let gridSize = 3
        let tileWidth = puzzleGrid.bounds.width / CGFloat(gridSize)
        let tileHeight = puzzleGrid.bounds.height / CGFloat(gridSize)
        tileSize = CGSize(width: tileWidth, height: tileHeight)
        var tempTiles: [Tile] = []
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let correctFrame = CGRect(x: CGFloat(col) * tileWidth,
                                          y: CGFloat(row) * tileHeight,
                                          width: tileWidth,
                                          height: tileHeight)
                let tileImage = cropImage(image: image, rect: CGRect(
                    x: CGFloat(col) * (image.size.width / CGFloat(gridSize)),
                    y: CGFloat(row) * (image.size.height / CGFloat(gridSize)),
                    width: image.size.width / CGFloat(gridSize),
                    height: image.size.height / CGFloat(gridSize)
                ))
                let tile = Tile(
                    id: row * gridSize + col,
                    currentFrame: correctFrame,
                    correctFrame: correctFrame,
                    correctIndex: row * gridSize + col,
                    image: tileImage ?? UIImage(),
                    name: "\(row).\(col)",
                    associatedButton: nil
                )
                tempTiles.append(tile)
            }
        }
        tiles = tempTiles
        setupTileButtons()
        updateTileLayout()
    }
   
    func updateTileLayout() {
        guard !tiles.isEmpty else { return }

        let puzzleGridWidth = puzzleGrid.bounds.width
        let puzzleGridHeight = puzzleGrid.bounds.height
        let gridSize = Int(sqrt(Double(tiles.count)))
        let tileWidth = puzzleGridWidth / CGFloat(gridSize)
        let tileHeight = puzzleGridHeight / CGFloat(gridSize)
    
        let scaleFactor: CGFloat = min(view.bounds.width / puzzleGridWidth,
                                       view.bounds.height / puzzleGridHeight) * 0.7
        tileSize = CGSize(width: tileWidth, height: tileHeight)
  
        for (index, tile) in tiles.enumerated() {
            let row = index / gridSize
            let col = index % gridSize

            let newFrame = CGRect(x: CGFloat(col) * tileWidth,
                                  y: CGFloat(row) * tileHeight,
                                  width: tileWidth,
                                  height: tileHeight)
     
            tiles[index].currentFrame = newFrame
            if let button = tile.associatedButton {
                UIView.animate(withDuration: 0.3) {
                    button.frame = newFrame
                    button.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                }
            }
        }
    }
    
    func setupTileButtons() {
        for (index, tile) in tiles.enumerated() {
            let tileButton = UIButton(frame: tile.currentFrame)
            tileButton.setBackgroundImage(tile.image, for: .normal)
            tileButton.layer.borderWidth = 3
            tileButton.layer.borderColor = UIColor.black.cgColor
            tileButton.addTarget(self, action: #selector(tileTapped(_:)), for: .touchUpInside)
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            tileButton.addGestureRecognizer(panGesture)
            tileButton.tag = tile.id
            tiles[index].associatedButton = tileButton
            
            tileButtons.append(tileButton)
            puzzleGrid.addSubview(tileButton)
        }
    }
    
    func updateTileButtons() {
        print(tileButtons.count , tiles.count)
        
        guard tileButtons.count == tiles.count else {
            print("Error: tileButtons and tiles arrays are not synchronized")
            return
        }
        for (index, tileButton) in tileButtons.enumerated() {
            if index < tiles.count {
                
                UIView.animate(withDuration: 0.3) {
                    tileButton.frame = self.tiles[index].currentFrame
                }
            }
        }
    }

    func cropImage(image: UIImage, rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    @objc func tileTapped(_ sender: UIButton) {
        if let firstTile = firstSelectedTile {
            if firstTile != sender {
                swapTiles(firstTile, sender)
                firstTile.layer.borderColor = UIColor.black.cgColor
                sender.layer.borderColor = UIColor.black.cgColor
                lockCorrectTiles()
                firstSelectedTile = nil
            }
        } else {
            firstSelectedTile = sender
            sender.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let draggedTile = gesture.view as? UIButton,
              let draggedIndex = tileButtons.firstIndex(of: draggedTile),
              !tiles[draggedIndex].isLocked else { return }
        
        switch gesture.state {
        case .began:
            draggedTileOriginalPosition = draggedTile.frame
            draggedTile.superview?.bringSubviewToFront(draggedTile)
        case .changed:
            let translation = gesture.translation(in: puzzleGrid)
            draggedTile.center = CGPoint(x: draggedTile.center.x + translation.x,
                                         y: draggedTile.center.y + translation.y)
            gesture.setTranslation(.zero, in: puzzleGrid)
        case .ended:
            let draggedCenter = draggedTile.center
            guard let targetTile = tileButtons.first(where: { $0 != draggedTile && $0.frame.contains(draggedCenter) }),
                  let targetIndex = tileButtons.firstIndex(of: targetTile) else {
                UIView.animate(withDuration: 0.3) {
                    draggedTile.frame = self.draggedTileOriginalPosition ?? draggedTile.frame
                }
                return
            }

            if tiles[draggedIndex].isLocked || tiles[targetIndex].isLocked {
                UIView.animate(withDuration: 0.3) {
                    draggedTile.frame = self.draggedTileOriginalPosition ?? draggedTile.frame
                }
                return
            }
            swapTiles(draggedTile, targetTile)
            lockCorrectTiles()
            
        default:
            break
        }
    }
    
    func swapTiles(_ firstTile: UIButton, _ secondTile: UIButton) {
        guard let firstIndex = tileButtons.firstIndex(of: firstTile),
              let secondIndex = tileButtons.firstIndex(of: secondTile) else { return }

        if tiles[firstIndex].isLocked || tiles[secondIndex].isLocked {
            return
        }
        
        tiles.swapAt(firstIndex, secondIndex)
  
        UIView.animate(withDuration: 0.3) {
            firstTile.frame = self.tiles[firstIndex].currentFrame
            secondTile.frame = self.tiles[secondIndex].currentFrame
        }
        checkCompletion()
    }
    
    func checkCompletion() {
        var isCompleted = true

        for (index, tile) in tiles.enumerated() {
            if index != tile.correctIndex {
                isCompleted = false
                break
            }
        }
        if isCompleted {
            UIView.animate(withDuration: 1, animations: {
                    for button in self.tileButtons {
                        button.layer.borderWidth = 0
                    }
                }) { _ in
                    let alert = UIAlertController(title: "Congratulations!", message: "You have successfully completed the puzzle!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
    }
    
    @objc func shufflePuzzle() {
        tiles.shuffle()
        for (index, _) in tiles.enumerated() {
            tiles[index].isLocked = false
        }
        updateTileButtons()
    }
    
    func lockCorrectTiles() {
        for (index, tile) in tiles.enumerated() {
            if index == tile.correctIndex && !tile.isLocked {
                tiles[index].isLocked = true
            }
        }
    }
}
