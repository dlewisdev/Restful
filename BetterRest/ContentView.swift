//
//  ContentView.swift
//  BetterRest
//
//  Created by Danielle Lewis on 7/8/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    func calculateBedtime() {
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
        
    }
    
    struct Title: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.title2)
                .foregroundColor(.black)
        }
    }

    
    
    var body: some View {
        NavigationView {
                
            VStack(spacing: 30) {
                    Image("img")
                        .resizable()
                        .scaledToFit()
                    VStack {
                        Text("When do you want to wake up?")
                            .modifier(Title())
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    Section {
                        VStack {
                            Text("Desired amount of sleep")
                                .modifier(Title())
                            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                                .fixedSize()
                        }
                    }
                    
                    
                    Section {
                        VStack {
                            Text("Today's coffee intake")
                                .modifier(Title())
                            Stepper("Cups: \(coffeeAmount) ", value: $coffeeAmount, in: 0...10)
                                .fixedSize()
                        
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LinearGradient(colors: [.blue, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                .navigationTitle("BetterRest")
                .toolbar {
                    Button("Calculate", action: calculateBedtime)
                        .foregroundColor(.white)
                }
                .alert(alertTitle, isPresented: $showingAlert) {
                    Button("OK") { }
                } message: {
                    Text(alertMessage)
                }
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




