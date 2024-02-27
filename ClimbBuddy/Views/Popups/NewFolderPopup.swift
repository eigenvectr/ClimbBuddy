//
//  NewFolderPopup.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/23/24.
//

import Foundation
import SwiftUI

struct NewFolderPopup: View {
    
    @EnvironmentObject var vm: TimerViewModel
    
    @Binding var show: Bool
    @State var folderName:String = ""
    
    var body: some View{
        ZStack{
            
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack{
                VStack(spacing: 25){
                    
                    HStack{
                        Button(action: {  self.show = false  }, label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 20,height: 20)
                        })
                        
                        Spacer()
                        
                        Text("Create Folder")
                            .font(.custom(CustomFont.semiBold, size: 18))
                        Spacer()
                    }
                    
                    HStack{
                        Text("Name")
                            .font(.custom(CustomFont.semiBold, size: 15))
                            .padding(.leading)
                        
                        TextField("Enter Name", text: $folderName)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing)
                    }
                    .frame(height: 45)
                    .background(color.appBGColor)
                    .cornerRadius(15)
                    
                    HStack{
                        Button(action: { self.show = false }, label: {
                            ZStack{
                                color.appBGColor
                                    .cornerRadius(15)
                                Text("Cancel")
                                    .font(.custom(CustomFont.semiBold, size: 15))
                            }.frame(width: 166,height: 40)
                        })
                        
                        Button(action: {
                            
                            vm.saveFolderDataCD(Folder(isExpand: false,folderName: folderName))
                            show = false
                            vm.getFolderRecords()
                            
                        }, label: {
                            ZStack{
                                color.appThemeColor
                                    .cornerRadius(15)
                                Text("Create")
                                    .font(.custom(CustomFont.semiBold, size: 15))
                            }.frame(width: 166,height: 40)
                        })
                    }
                }.padding(.horizontal)
            }
            .frame(maxWidth: .infinity,minHeight: 200)
            .background(color.appCardColor)
            .shadow(color: .black.opacity(0.2), radius: 5,x: 1,y: 1)
            .cornerRadius(15)
            .padding()
        }
        .foregroundColor(.white)
        .navigationBarHidden(true)
    }
}
