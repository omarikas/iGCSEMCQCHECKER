//
//  PieChartSlice.swift
//  MCQchecker
//
//  Created by Omarrhazem Khattab  on 29/12/2024.
//


import SwiftUI

struct PieChartSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()

        return path
    }
}

struct PieChart: View {
    let data: [Double]
    let colors: [Color]

    private var total: Double {
        data.reduce(0, +)
    }

    private func angles() -> [Angle] {
        var angles: [Angle] = []
        var currentAngle: Double = 0

        for value in data {
            let proportion = value / total
            angles.append(.degrees(currentAngle))
            currentAngle += 360 * proportion
        }

        angles.append(.degrees(currentAngle)) // Close the loop
        return angles
    }

    var body: some View {
        let angles = self.angles()

        ZStack {
            ForEach(0..<data.count, id: \.self) { index in
                PieChartSlice(
                    startAngle: angles[index],
                    endAngle: angles[index + 1]
                )
                .fill(colors[index % colors.count])
                .scrollTransition { content, phase in
                    return  content
                    .offset(x:phase.value * -50)
                    .scaleEffect(phase.isIdentity ? 1.0 : 0.7)
                .opacity(phase.isIdentity ? 1.0 : 0.5)}
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
struct test: View {
    let data = [0.90,0.10] // Your data
    let colors: [Color] = [ .green, .red] // Segment colors

    var body: some View {
        VStack {
            PieChart(data: data, colors: colors)
                .frame(width: 300, height: 300)
                .padding()

            Text("Pie Chart Example")
                .font(.headline)
        }
    }
}
#Preview{
    test()
}






