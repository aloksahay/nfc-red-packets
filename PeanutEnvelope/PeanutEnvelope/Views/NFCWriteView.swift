import SwiftUI
import CoreNFC

struct NFCWriteView: UIViewControllerRepresentable {
    let claimLink: String
    
    func makeUIViewController(context: Context) -> NFCWriteViewController {
        return NFCWriteViewController(claimLink: claimLink)
    }
    
    func updateUIViewController(_ uiViewController: NFCWriteViewController, context: Context) {}
}

class NFCWriteViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    private var session: NFCNDEFReaderSession?
    private let claimLink: String
    
    init(claimLink: String) {
        self.claimLink = claimLink
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        beginScanning()
    }
    
    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            // Handle device not supporting NFC
            return
        }
        
        session = NFCNDEFReaderSession(delegate: self,
                                     queue: DispatchQueue.main,
                                     invalidateAfterFirstRead: false)
        session?.begin()
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Handle error
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Handle reading existing messages
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // Optional: Handle session becoming active
    }
} 