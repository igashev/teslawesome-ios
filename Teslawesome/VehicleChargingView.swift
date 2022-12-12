//
//  VehicleChargingView.swift
//  Teslawesome
//
//  Created by Ivaylo Gashev on 18.10.22.
//

import SwiftUI
import ComposableArchitecture

struct VehicleCharging: ReducerProtocol {
    struct State: Equatable {
        
    }
    
    enum Action {
        
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        
    }
}

struct VehicleChargingView: View {
    @State private var speed = 50.0
    
    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Button("Open charge port") {
                    
                }
                
                Spacer()
                
                Button("Close charge port") {
                    
                }
            }
            
            HStack {
                Button("Start charging") {
                    
                }
                
                Spacer()
                
                Button("Stop charging") {
                    
                }
            }
            
            Slider(value: $speed, in: 0...100)
        }
        .padding()
    }
}

struct VehicleChargingView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleChargingView()
    }
}
