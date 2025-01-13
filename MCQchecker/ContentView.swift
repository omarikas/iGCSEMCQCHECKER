import SwiftUI
import Foundation
import PDFKit

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
}

// Networking Manager
class NetworkingManager {
    static func getMcq(pdfURL: String) async throws -> [String] {
        let endpoint = "https://jovial-lokum-6bdadd.netlify.app/.netlify/functions/index?fileUrl=\(pdfURL)"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode([String].self, from: data)
    }
    
    static func loadPDF(from url: String) async throws -> PDFDocument {
        guard let pdfURL = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: pdfURL)
        guard let pdfDocument = PDFDocument(data: data) else {
            throw APIError.noData
        }
        
        return pdfDocument
    }
}

// Question Model
class Question: ObservableObject, Identifiable {
    let id = UUID()
    @Published var number: Int
    @Published var ans: [Bool]
    @Published var correct: Int
    
    init(number: Int,correct:Int ,ans: [Bool] = [false, false, false, false]) {
        self.number = number
        self.ans = ans
        self.correct=correct
    }
    
    func toggleAnswer(at index: Int) {
        for i in 0..<ans.count {
            ans[i] = (i == index)
        }
        print(ans)
    }
}

// App ViewModel
class AppViewModel: ObservableObject {
    @Published var pdfDocument: PDFDocument?
    @Published var questions: [Question] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    var examurl = ""
    
    func loadPDF(pdfURL:String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                pdfDocument = try await NetworkingManager.loadPDF(from: pdfURL)
            } catch {
                errorMessage = "Failed to load PDF: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func loadMCQs(pdfURL:String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let mcqItems = try await NetworkingManager.getMcq(pdfURL: pdfURL)
                var i=0
                for ans in mcqItems{
                    i+=1
                    var correct = 0
                    switch ans {
                    case "A":
                        correct=1
                        break
                    case "B":
                        correct=2
                        break
                    case "C":
                        correct=3
                        break
                    case "D":
                        correct=4
                        break
                    default:
                        correct = -1
                    }
                    questions.append(Question(number: i, correct: correct))
                    
                }
               
               
            } catch {
                errorMessage = "Failed to fetch MCQ items: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    init(examurl: String = "") {
        self.examurl = examurl
    }
}

// PDF Viewer
struct PDFViewer: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = pdfDocument
    }
}

// Content View
struct ContentView: View {
    let examurl:String
    @StateObject private var viewModel = AppViewModel()
    @State var solve=false

    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        TabView {
            // PDF Viewer Tab
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading PDF...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if let pdfDocument = viewModel.pdfDocument {
                    PDFViewer(pdfDocument: pdfDocument)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .tabItem {
                Label("PDF", systemImage: "book.fill")
            }
            
            // MCQ Tab
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Questions...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    List($viewModel.questions) { question in
            
                        VStack(alignment: .leading) {
                            Text("Question \(question.wrappedValue.number)")
                                .font(.headline)
                            if solve {
                                CustomAnswerButton2(label:"test",
                                                   correct: question.wrappedValue.correct ,
                                                   isASelected:question.ans[0],isBSelected:question.ans[1],isCSelected:question.ans[2],isDSelected:question.ans[3]
                                              )
                            }
                            
                            else{
                                CustomAnswerButton(label:"test",
                                                   correct: question.wrappedValue.correct ,
                                                   isASelected:question.ans[0],isBSelected:question.ans[1],isCSelected:question.ans[2],isDSelected:question.ans[3]
                                                   
                                                   
                                )
                            }
                        }
                        .frame(alignment: .center)
                        
                        
                        .background(!solve ? Color.clear :
                                question.ans[question.wrappedValue.correct-1].wrappedValue ? .green : Color.red)
                    }
                }
                if( solve){
                    
                    
                    
                    Text("YOU GOT \(resukt(questions: viewModel.questions)) OUT OF 40")
                    
                    
                    
                    
                }
                Button( "CHECK"){
                    solve.toggle()
                    var answers :[String]=[]
                    var correctans:[String]=[]
                    
                    for ans in viewModel.questions{
                        
                        var correct:String ;
                           
                        var corans :String;
                                switch ans.ans.firstIndex(of: true)   {
                                case 0:
                                    correct="A"
                                    break
                                case 1:
                                    correct="B"
                                    break
                                case 2:
                                    correct="C"
                                    break
                                case 3:
                                    correct="D"
                                    break
                                default:
                                    correct = ""
                                }
                                
                        switch ans.ans.firstIndex(of: true)   {
                        case 0:
                            corans="A"
                            break
                        case 1:
                            corans="B"
                            break
                        case 2:
                            corans="C"
                            break
                        case 3:
                            corans="D"
                            break
                        default:
                            corans = ""
                        }
                            
                        answers.append(correct)
                        correctans.append(corans)
                            
                            
                            
                        
                        
                    }
                  
                    
                    
                    
                    
                    
                    
                    
                    
                    let ex = exam(url: examurl, questions: answers,correct: correctans)
                
                    var exams: Set<exam> = []
                    if let savedData = UserDefaults.standard.data(forKey: "savedUser") {
                        
                        if let decodedUser = try? JSONDecoder().decode((Set<exam>).self, from: savedData) {
                            exams=decodedUser
                        }
                    }
                    if let existingExam = exams.first(where: { $0.url == ex.url }) {
                        exams.remove(existingExam)
                    }
                    exams.insert(ex)
                    if let encoded = try? JSONEncoder().encode(exams) {
                    
                          UserDefaults.standard.set(encoded, forKey: "savedUser")
                      }
                    
                }
            }
            .tabItem {
                Label("MCQs", systemImage: "questionmark.circle.fill")
            }
        }
        .onAppear {
            viewModel.loadPDF(pdfURL: examurl)
            viewModel.loadMCQs(pdfURL:examurl.replacingOccurrences(of: "qp", with: "ms"))
        }
    }
    
    func resukt(questions : [Question]) ->Int {
        var correctanswers = 0
        for question in viewModel.questions {
            
            if question.ans[question.correct-1] {
                correctanswers += 1
                
            }
            
            
        }
        return correctanswers
    }
    
    
    
    
    
}
struct exam: Codable, Hashable ,Identifiable{
    let id=UUID();
    let url: String
    let questions: [String]
    let correct: [String]

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

    static func == (lhs: exam, rhs: exam) -> Bool {
        return lhs.url == rhs.url
    }
}

#Preview {
    ContentView(examurl: "https://dynamicpapers.com/wp-content/uploads/2015/09/0620_w18_qp_22.pdf"
    )
}
import SwiftUI

struct CustomAnswerButton: View {
    let label: String
    let correct: Int
    @Binding var isASelected: Bool ;
    @Binding var isBSelected: Bool ;
    @Binding var isCSelected: Bool ;
    
    @Binding var isDSelected: Bool;
   
    var body: some View {
        VStack{
            Button("A") {
                isASelected=true
                isBSelected=false
                isCSelected=false
                isDSelected=false
           
            }
            .buttonStyle(BorderlessButtonStyle()) // Remove default button styles
            .padding()
            .background(isASelected ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            Button("B") {
                isASelected=false
                isBSelected=true
                isCSelected=false
                isDSelected=false
            }
            .buttonStyle(BorderlessButtonStyle()) // Remove default button styles
            .padding()
            .background(isBSelected ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            Button("C") {
                isASelected=false
                isBSelected=false
                isCSelected=true
                isDSelected=false
            }
            .buttonStyle(BorderlessButtonStyle()) // Remove default button styles
            .padding()
            .background(isCSelected ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            Button("D") {
                isASelected=false
                isBSelected=false
                isCSelected=false
                isDSelected=true
            }
            .buttonStyle(BorderlessButtonStyle()) // Remove default button styles
            .padding()
            .background(isDSelected ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            
            
            
        }
        
        
    }
}

struct CustomAnswerButton2: View {
    let label: String
    let correct: Int
    @Binding var isASelected: Bool ;
    @Binding var isBSelected: Bool ;
    @Binding var isCSelected: Bool ;
    
    @Binding var isDSelected: Bool;
   
    var body: some View {
        VStack{
            Button("A") {
                isASelected=true
                isBSelected=false
                isCSelected=false
                isDSelected=false
           
            }
            .buttonStyle(BorderlessButtonStyle()) // Remove default button styles
            .padding()
            .background(correct == 1 ? .green : isASelected ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            Button("B") {
                isASelected=false
                isBSelected=true
                isCSelected=false
                isDSelected=false
            }
            .buttonStyle(BorderlessButtonStyle()) // Remove default button styles
            .padding()
            .background(correct == 2 ? .green  : isBSelected ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            Button("c") {
                isASelected=false
                isBSelected=false
                isCSelected=true
                isDSelected=false
            }
            .buttonStyle(BorderlessButtonStyle()) // Remove default button styles
            .padding()
            .background(correct == 3 ? .green  :   isCSelected ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            Button("D") {
                isASelected=false
                isBSelected=false
                isCSelected=false
                isDSelected=true
            }
            .buttonStyle(BorderlessButtonStyle()) // Remove default button styles
            .padding()
            .background( correct == 4 ? .green  :  isDSelected ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(5)
            
            
            
        }
        
        
    }
}
