import SwiftUI

struct ResultBox: View {
    let title: String
    let content: String
    let color: Color
    let onCopy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(content)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                
                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(color)
                        .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    ResultBox(
        title: "Test",
        content: "02151410152118",
        color: .green,
        onCopy: {}
    )
    .padding()
}
