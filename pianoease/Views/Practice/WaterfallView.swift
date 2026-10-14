import SwiftUI
import SpriteKit

struct WaterfallView: View {
    @Bindable var engine: PracticeEngine
    
    @State private var scene: WaterfallScene? = nil
    
    var body: some View {
        GeometryReader { geo in
            SpriteView(scene: getScene(size: geo.size))
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: engine.currentGroupIndex) { _, _ in
                    scene?.updateNotes()
                }
                .onChange(of: engine.state) { _, _ in
                    scene?.updateNotes()
                }
                .onAppear {
                    scene?.updateNotes()
                }
        }
        .background(Color(hex: "#18181b").opacity(0.95)) // sleek dark background
        .cornerRadius(AppTheme.CornerRadius.lg)
    }
    
    private func getScene(size: CGSize) -> WaterfallScene {
        if let scene = scene {
            if scene.size != size {
                scene.size = size
            }
            return scene
        }
        let newScene = WaterfallScene()
        newScene.size = size
        newScene.scaleMode = .resizeFill
        newScene.engine = engine
        self.scene = newScene
        return newScene
    }
}
