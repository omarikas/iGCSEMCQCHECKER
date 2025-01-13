import SwiftUI
struct select: View {
    @State var code: String = ""
    @State var year: String = ""
    @State var variant: String = ""
    @State var exams: Set<exam> = []
    var friuts = ["may/june", "oct/nov"]
    @State var selectedFruit = "may/june"
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField("code", text: $code, axis: .horizontal)
                        .keyboardType(.numberPad)
                    Picker("session", selection: $selectedFruit) {
                        ForEach(friuts, id: \.self) { fruit in
                            Text(fruit)
                        }
                    }
                    TextField("last two number in the year eg 19", text: $year, axis: .horizontal)
                        .keyboardType(.numberPad)
                    
                    TextField("variant eg 22", text: $variant, axis: .horizontal)
                        .keyboardType(.numberPad)
                    
                    if selectedFruit == "may/june" {
                        NavigationLink(destination: ContentView(examurl: "https://dynamicpapers.com/wp-content/uploads/2015/09/\(code)_s\(year)_qp_\(variant).pdf")) {
                            Text("GO TO EXAM")
                        }
                    } else {
                        NavigationLink(destination: ContentView(examurl: "https://dynamicpapers.com/wp-content/uploads/2015/09/\(code)_w\(year)_qp_\(variant).pdf")) {
                            Text("GO TO EXAM")
                        }
                    }
                    
                        let groupedExams = Dictionary(grouping: Array($exams.wrappedValue)) { exam in
                            exam.url.split(separator: "/").last?.split(separator: "_").first ?? "Unknown"
                        }

                        ForEach(groupedExams.keys.sorted(), id: \.self) { code in
                            VStack(alignment: .leading) {
                                Text("Code: \(code)") // Display the code as the section header
                                    .font(.headline)
                                    .padding(.leading)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(groupedExams[code] ?? [], id: \.id) { exam in
                                            VStack {
                                                PieChart(data: getpercent(exam: exam), colors: [.green, .red])
                                                    .frame(width: 300, height: 300)
                                                    .padding()
                                                Text("You got \(Int(round(getpercent(exam: exam)[0] * 40)))")
                                                Text(exam.url.split(separator: "/").last ?? "invalidexam")
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom)
                            }
                        }

                    
                    .containerRelativeFrame(.horizontal)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                }
            }
            .onAppear {
                fetchExams()
            }
            .refreshable {
                fetchExams()
            }
        }
    }
    
    func fetchExams() {
        if let savedData = UserDefaults.standard.data(forKey: "savedUser") {
            if let decodedExams = try? JSONDecoder().decode(Set<exam>.self, from: savedData) {
                exams = decodedExams
            }
        }
    }
    
    func getpercent(exam: exam) -> [Double] {
        var correct = 0.0
        for i in 0...39 {
            if exam.questions[i] == exam.correct[i] {
                if exam.questions[i] != "" {
                    correct += 1
                }
            }
        }
        return [correct / 40, 1 - (correct / 40)]
    }
}

#Preview {
    select()
}
