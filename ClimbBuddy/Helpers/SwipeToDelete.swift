//
//  SwipeToDelete.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/16/24.
//

import Foundation
import SwiftUI


public extension View {
    
    func onDelete(callFrom: String,style: Delete.CornerRadiusStyle? = nil,deleteAction: @escaping () -> Void,editAction: @escaping () -> Void,copyAction: @escaping () -> Void,cutAction: @escaping () -> Void) -> some View {
        self.modifier(Delete(action: deleteAction,editAction: editAction, copyAction: copyAction ,cutAction:cutAction, cornerRadiusStyle: style,callFrom: callFrom))
    }
}


import SwiftUI

public struct Delete: ViewModifier {
    public struct CornerRadiusStyle {
        let radius: CGFloat
        let corners: UIRectCorner
    }
    
    //MARK: Constants
    
    private let deletionDistance = CGFloat(200)
    private let halfDeletionDistance = CGFloat(50)
    @State private var tappableDeletionWidth = CGFloat(140)
    
    //MARK: Properties
    
    private var callFrom: String = ""
    private let deleteAction: () -> Void
    private let editAction: () -> Void
    private let copyAction: () -> Void
    private let cutAction: () -> Void
    private let cornerRadiusStyle: CornerRadiusStyle?
    
    @State private var offset: CGSize = .zero
    @State private var initialOffset: CGSize = .zero
    @State private var contentWidth: CGFloat = 0.0
    @State private var willDeleteIfReleased = false
    
    //MARK: Init
    
    init(action: @escaping () -> Void,editAction: @escaping () -> Void,copyAction: @escaping () -> Void,cutAction:@escaping () -> Void, cornerRadiusStyle: CornerRadiusStyle? = nil,callFrom: String) {
        self.deleteAction = action
        self.editAction = editAction
        self.copyAction = copyAction
        self.cutAction = cutAction
        self.cornerRadiusStyle = cornerRadiusStyle
        self.callFrom = callFrom
    }
    
    //MARK: UI
    
    public func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.clear)
                        // .cornerRadius(cornerRadiusStyle?.radius ?? .zero, corners: cornerRadiusStyle?.corners ?? [])
                            .cornerRadius(15)
                        
                        HStack(spacing: 15){
                            
                            Image(systemName: "trash.fill")
                                .foregroundColor(Color.red.opacity(0.70))
                                .font(.title2.bold())
                                .layoutPriority(-1)
                                .opacity(offset.width < -10 ? 1 : 0)
                                .onTapGesture {
                                    delete()
                                }
                            
                            if callFrom == "exe" {
                                
                                Image("ic_pen")
                                    .resizable()
                                    .frame(width: 25,height: 25)
                                    .foregroundStyle(.white, color.appThemeColor)
                                    .font(.title2.bold())
                                    .layoutPriority(-1)
                                    .opacity(offset.width < -10 ? 1 : 0)
                                    .onTapGesture {
                                        editAction()
                                        offset = .zero
                                        initialOffset = .zero
                                    }
                                
                                Image(systemName: "plus.square.fill.on.square.fill")
                                    .foregroundStyle(.white,color.appThemeColor)
                                    .font(.title2.bold())
                                    .layoutPriority(-1)
                                    .opacity(offset.width < -10 ? 1 : 0)
                                    .onTapGesture {
                                        copyAction()
                                        offset = .zero
                                        initialOffset = .zero
                                    }
                                
                                Image(systemName:"scissors")
                                    .resizable()
                                    .foregroundColor(color.appThemeColor)
                                    .scaledToFit()
                                    .frame(width: 25,height: 25)
                                    .font(.title2.bold())
                                    .layoutPriority(-1)
                                    .opacity(offset.width < -10 ? 1 : 0)
                                    .onTapGesture {
                                        cutAction()
                                        offset = .zero
                                        initialOffset = .zero
                                    }
                            }
                        }.padding(.leading,5)
                    }.frame(width: -offset.width)
                        .offset(x: geometry.size.width)
                        .onAppear {
                            contentWidth = geometry.size.width
                        }
                }
            )
            .offset(x: offset.width, y: 0)
            .gesture (
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width + initialOffset.width <= 0 {
                            self.offset.width = gesture.translation.width + initialOffset.width
                        }
                        if self.offset.width < -deletionDistance && !willDeleteIfReleased {
                            hapticFeedback()
                            willDeleteIfReleased.toggle()
                        } else if offset.width > -deletionDistance && willDeleteIfReleased {
                            hapticFeedback()
                            willDeleteIfReleased.toggle()
                        }
                    }
                    .onEnded { _ in
                        if offset.width < -deletionDistance {
                            delete()
                        } else if offset.width < -halfDeletionDistance {
                            offset.width = -tappableDeletionWidth
                            initialOffset.width = -tappableDeletionWidth
                        } else {
                            offset = .zero
                            initialOffset = .zero
                        }
                    }
            )
            .animation(.interactiveSpring(), value: offset)
            .onAppear{
                self.tappableDeletionWidth = self.callFrom == "exe" ? 160 : 60
            }
    }
    
    //MARK: Methods
    
    private func delete() {
        offset.width = -contentWidth
        deleteAction()
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
