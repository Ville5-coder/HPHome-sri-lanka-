import Foundation

struct DelprovLink: Identifiable, Hashable, Codable {
    let id: UUID
    let code: String
    let title: String
    let summary: String
    var urlString: String? // To be filled later

    init(id: UUID = UUID(), code: String, title: String, summary: String, urlString: String? = nil) {
        self.id = id
        self.code = code
        self.title = title
        self.summary = summary
        self.urlString = urlString
    }
}

enum DelprovSeed {
    static let all: [DelprovLink] = [
        .init(code: "ORD", title: "Ordförståelse", summary: "Träna ordförståelse och synonymer."),
        .init(code: "LÄS", title: "Läsförståelse", summary: "Läs texter och svara på frågor."),
        .init(code: "MEK", title: "Meningskomplettering", summary: "Komplettera meningar med rätt alternativ."),
        .init(code: "XYZ", title: "XYZ", summary: "Matematikuppgifter av blandad karaktär."),
        .init(code: "KVA", title: "Kvantitativa jämförelser", summary: "Jämför kvantiteter och resonera logiskt."),
        .init(code: "NOG", title: "NOG", summary: "Nödvändig information – logiskt resonerande."),
        .init(code: "DTK", title: "Diagram, tabeller, kartor", summary: "Tolka och analysera data i olika format."),
        .init(code: "ENG", title: "Engelska/Läsförståelse", summary: "Engelsk läsförståelse.")
    ]
}
