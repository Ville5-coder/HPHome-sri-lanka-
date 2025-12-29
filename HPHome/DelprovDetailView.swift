import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }
}

struct DelprovDetailView: View {
    let delprov: DelprovLink
    @State private var showMissingURLAlert = false
    @State private var presentSafari = false
    @State private var safariURL: URL?

    var body: some View {
        List {
            Section("Beskrivning") {
                Text(delprov.summary)
            }
            Section("Övning") {
                Button {
                    if let urlString = delprov.urlString, let url = URL(string: urlString) {
                        safariURL = url
                        presentSafari = true
                    } else {
                        showMissingURLAlert = true
                    }
                } label: {
                    Label("Starta övning", systemImage: "play.circle.fill")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(delprov.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $presentSafari) {
            if let url = safariURL {
                SafariView(url: url)
            }
        }
        .alert("URL saknas", isPresented: $showMissingURLAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Vi lägger till länkarna senare. Skicka gärna URL:erna när du är redo.")
        }
    }
}

#Preview {
    NavigationStack {
        DelprovDetailView(delprov: DelprovSeed.all.first!)
    }
}
