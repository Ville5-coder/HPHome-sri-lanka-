import SwiftUI

struct HomeView: View {
    let delprov: [DelprovLink] = DelprovSeed.all

    var body: some View {
        NavigationStack {
            List {
                ForEach(delprov) { dp in
                    NavigationLink(value: dp) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dp.title).font(.headline)
                            Text(dp.summary).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("HPHome")
            .navigationDestination(for: DelprovLink.self) { dp in
                DelprovDetailView(delprov: dp)
            }
        }
    }
}

#Preview {
    HomeView()
}
