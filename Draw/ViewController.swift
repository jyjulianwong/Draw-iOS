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
    
    // let canvasWidth: CGFloat = 768
    // let canvasOverscrollHeight: CGFloat = 500
    
    var manualUndoManager = UndoManager()
    var canvasHistory = [PKDrawing]()
    var canvasHistoryIndex = 0
    var isCanvasResetting = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        canvasView.delegate = self
        canvasHistory.append(PKDrawing())
        canvasView.drawing = canvasHistory.first!
        
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
    
    // MARK: - Undo and redo buttons
    
    @IBAction func undoLastActionManually(_ sender: Any) {
        // Overrides the undo button on PKToolPicker
        manualUndoManager.undo()
        resetManualUndoRedoButtons()
    }
    
    @IBAction func redoLastActionManually(_ sender: Any) {
        // Overrides the redo button on PKToolPicker
        manualUndoManager.redo()
        resetManualUndoRedoButtons()
    }
    
    func resetManualUndoRedoButtons() {
        // Enables the buttons if there is a undo / redo action available
        self.manualUndoButton.isEnabled = manualUndoManager.canUndo
        self.manualRedoButton.isEnabled = manualUndoManager.canRedo
    }
    
    // MARK: - Register actions
    
    func addToCanvasHistory(_ drawing: PKDrawing) {
        // Overwrites actions that were not redone by resetting canvasHistoryIndex
        canvasHistoryIndex += 1
        if (canvasHistoryIndex < canvasHistory.count) {
            // TODO: canvasView is unable to be completely replaced when redoing
            // TODO: Changes made by erasers are not yet supported
            canvasHistory[canvasHistoryIndex] = drawing
        } else {
            canvasHistory.append(drawing)
        }
    }
    
    func resetToLastDrawing() {
        // Resets canvasView to the last drawing or action in history
        canvasHistoryIndex -= 1
        isCanvasResetting = true
        canvasView.drawing = canvasHistory[canvasHistoryIndex]
    }
    
    func resetToNextDrawing() {
        // Resets canvasView to the next drawing or action in history
        canvasHistoryIndex += 1
        isCanvasResetting = true
        canvasView.drawing = canvasHistory[canvasHistoryIndex]
    }
    
    func registerResetToLastDrawingAction() {
        manualUndoManager.registerUndo(withTarget: self, handler: {
            $0.resetToNextDrawing()
            $0.registerResetToNextDrawingAction()
        })
    }
    
    func registerResetToNextDrawingAction() {
        manualUndoManager.registerUndo(withTarget: self, handler: {
            $0.resetToLastDrawing()
            $0.registerResetToLastDrawingAction()
        })
    }
    
    // MARK: - Detect canvas changes
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        // canvasView should no longer be resetting when user begins drawing
        isCanvasResetting = false
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        // Avoids repeatedly registering an action as the canvas is automatically resetting
        guard !isCanvasResetting else { return }
        
        addToCanvasHistory(canvasView.drawing)
        registerResetToNextDrawingAction()
        resetManualUndoRedoButtons()
    }
    
}

