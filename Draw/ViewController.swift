//
//  ViewController.swift
//  Draw
//
//  Created by Julian Wong on 13/09/2020.
//  Copyright © 2020 Julian Wong. All rights reserved.
//

import UIKit
import PencilKit

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var manualUndoButton: UIBarButtonItem!
    @IBOutlet weak var manualRedoButton: UIBarButtonItem!
    
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHeight: CGFloat = 500
    
    var drawing = PKDrawing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        
        if let window = parent?.view.window, let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            
            canvasView.becomeFirstResponder()
        }
        
        resetManualUndoRedoButtons()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    @IBAction func activateEraser(_ sender: Any) {
        canvasView.tool = PKEraserTool(.vector)
    }
    
    @IBAction func undoLastActionManually(_ sender: Any) {
        // self.undoManager?.undo()
        resetManualUndoRedoButtons()
    }
    
    @IBAction func redoLastActionManually(_ sender: Any) {
        // self.undoManager?.redo()
        resetManualUndoRedoButtons()
    }
    
    func resetManualUndoRedoButtons() {
        self.manualUndoButton.isEnabled = self.undoManager?.canUndo ?? false
        self.manualRedoButton.isEnabled = self.undoManager?.canRedo ?? false
    }
    
}

