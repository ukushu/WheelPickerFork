//import SwiftUI
//
//#if os(macOS)
//
///// How the view passes events back to the representable view.
//protocol ScrollViewDelegateProtocol {
//    /// Informs the receiver that the mouse’s scroll wheel has moved.
//    func scrollWheel(with event: NSEvent);
//}
//
///// The AppKit view that captures scroll wheel events
//class ScrollView: NSView {
//    /// Connection to the SwiftUI view that serves as the interface to our AppKit view.
//    var delegate: ScrollViewDelegateProtocol!
//    /// Let the responder chain know we will respond to events.
//    override var acceptsFirstResponder: Bool { true }
//    /// Informs the receiver that the mouse’s scroll wheel has moved.
//    override func scrollWheel(with event: NSEvent) {
//        // pass the event on to the delegate
//        delegate.scrollWheel(with: event)
//    }
//}
//
///// The SwiftUI view that serves as the interface to our AppKit view.
//struct RepresentableScrollView: NSViewRepresentable, ScrollViewDelegateProtocol {
//    /// The AppKit view our SwiftUI view manages.
//    typealias NSViewType = ScrollView
//    
//    /// What the SwiftUI content wants us to do when the mouse's scroll wheel is moved.
//    private var scrollAction: ((NSEvent) -> Void)?
//    
//    /// Creates the view object and configures its initial state.
//    func makeNSView(context: Context) -> ScrollView {
//        // Make a scroll view and become its delegate
//        let view = ScrollView()
//        view.delegate = self;
//        return view
//    }
//    
//    /// Updates the state of the specified view with new information from SwiftUI.
//    func updateNSView(_ nsView: NSViewType, context: Context) {
//    }
//    
//    /// Informs the representable view  that the mouse’s scroll wheel has moved.
//    func scrollWheel(with event: NSEvent) {
//        // Do whatever the content view wants
//        // us to do when the scroll wheel moved
//        if let scrollAction = scrollAction {
//            scrollAction(event)
//        }
//    }
//    
//    /// Modifier that allows the content view to set an action in its context.
//    func onScroll(_ action: @escaping (NSEvent) -> Void) -> Self {
//        var newSelf = self
//        newSelf.scrollAction = action
//        return newSelf
//    }
//}
//
//struct ScrollWheelModifier: ViewModifier {
//    /// The scroll offset -- when this value changes the view will be redrawn.
//    @State var offset: CGSize = CGSize(width: 0.0, height: 0.0)
//    
//    let action: (NSEvent) -> ()
//    
//    /// The SwiftUI view that detects the scroll wheel movement.
//    var scrollView: some View {
//        // A view that will update the offset state variable
//        // when the scroll wheel moves
//        RepresentableScrollView()
//            .onScroll(action)
//    }
//    
//    func body(content: Content) -> some View {
//        content
//            .overlay(scrollView)
//    }
//}
//
//
//extension View {
//    func onScrollWheel(action: @escaping (NSEvent) -> () ) -> some View {
//        modifier(ScrollWheelModifier(action: action) )
//    }
//}
//#endif
//
//
//import AppKit
//import SwiftUI
//
//struct CaptureVerticalScrollWheelModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .background(ScrollWheelHandlerView())
//    }
//
//    struct ScrollWheelHandlerView: NSViewRepresentable {
//        func makeNSView(context _: Context) -> NSView {
//            let view = ScrollWheelReceivingView()
//            return view
//        }
//
//        func updateNSView(_: NSView, context _: Context) {}
//    }
//
//    class ScrollWheelReceivingView: NSView {
//        private var scrollVelocity: CGFloat = 0
//        private var decelerationTimer: Timer?
//
//        override var acceptsFirstResponder: Bool { true }
//
//        override func viewDidMoveToWindow() {
//            super.viewDidMoveToWindow()
//            window?.makeFirstResponder(self)
//        }
//        // Don't capture vertical scroll for precise scrolling (e.g. magic mouse/trackpad), and don't capture if we are already scrolling horizontally (e.g. shift + scroll). If we don't do this, we get very unpredictable behavior
//        override func scrollWheel(with event: NSEvent) {
//            if event.hasPreciseScrollingDeltas || abs(event.scrollingDeltaX) > 0.000001 || abs(event.deltaX) > 0.000001 {
//                super.scrollWheel(with: event)
//                return
//            }
//
//            if let cgEvent = event.cgEvent?.copy() {
//                cgEvent.setDoubleValueField(.scrollWheelEventDeltaAxis2, value: Double(event.scrollingDeltaY / 10))
//                cgEvent.setDoubleValueField(.scrollWheelEventDeltaAxis1, value: Double(0))
//                cgEvent.setDoubleValueField(.scrollWheelEventDeltaAxis3, value: Double(0))
//                cgEvent.setDoubleValueField(.mouseEventDeltaX, value: Double(0))
//                cgEvent.setDoubleValueField(.mouseEventDeltaY, value: Double(0))
//
//               // Once we flip the scrolling axis to X and set the rest to 0, we can just send the event the same as before. All the deceleration and such will get handled natively by the system!
//                if let nsEvent = NSEvent(cgEvent: cgEvent) {
//                    super.scrollWheel(with: nsEvent)
//                } else {
//                    super.scrollWheel(with: event)
//                }
//            } else {
//                super.scrollWheel(with: event)
//            }
//        }
//    }
//}
//
//extension View {
//    func captureVerticalScrollWheel() -> some View {
//        modifier(CaptureVerticalScrollWheelModifier())
//    }
//}
