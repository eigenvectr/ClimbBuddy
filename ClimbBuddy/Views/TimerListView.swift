//
//  TimerListView.swift
//  ClimbBuddy
//
//  Created by Edward Laurence on 2/14/24.
//
import SwiftUI
import MobileCoreServices
struct TimerListView: View{
    
    @StateObject var vm = TimerViewModel()
    @State var showFolderpopup:Bool = false
    @State var isEditing: Bool = false
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = UIColor(color.appBGColor)
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some View {
        ZStack{
            color.appBGColor
                .ignoresSafeArea()
            VStack(spacing: 0){
                ScrollView(.vertical,showsIndicators: false){
                    VStack(spacing:15){
                        
                        ForEach(vm.folderArray){ i in
                            folderCard(i)
                                .onDrop(of: [kUTTypePlainText as String], delegate: DragAndDropDelegate(item: i, vm: vm))
                        }
                        
                        ForEach (vm.myTimers) { i in
                            HStack{
                                if isEditing {
                                    Button(action: {}, label: {
                                        Image("ic_circlefill")
                                            .resizable()
                                            .frame(width: 20,height: 20)
                                            .foregroundColor(color.appThemeColor)
                                    }).padding(.leading)
                                }
                                
                                NavigationLink {
                                    WorkoutTimerView(myTimer: i).environmentObject(vm)
                                } label: {
                                    timerCard(i)
                                        .onDrag {
                                            let itemProvider = NSItemProvider(object: NSString(string: i.id))
                                            return itemProvider
                                        }
                                }
                            }
                        }
                    }.padding(.top,10)
                }
            }
            .background(color.appBGColor)
            .navigationTitle("My Timers")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing:
                    HStack(spacing:15){
                        Button(action: {showFolderpopup.toggle()}, label: {
                            Image("ic_folderplus")
                                .resizable()
                                .frame(width: 25,height: 25)
                        })
                        
                        NavigationLink {
                            AddEditTimerView(comeFrom: .addNew).environmentObject(vm)
                        } label: {
                            ZStack{
                                color.appThemeColor
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 13,height: 13)
                                    .font(.system(size: 13,weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 25,height: 25)
                            .cornerRadius(12.5)
                            .foregroundColor(.white)
                        }
                    }
            )
        }
        .fullScreenCover(isPresented: $showFolderpopup){
            NewFolderPopup(show: $showFolderpopup).environmentObject(vm)
        }
    }
    
    func timerCard(_ item: MyTimer) -> some View {
        ZStack{
            color.appCardColor
                .cornerRadius(15)
            HStack(spacing:10){
                Circle()
                    .fill(color.appThemeColor)
                    .frame(width: 50, height: 50)
                    .overlay{
                        Image("ic_dum")
                            .resizable()
                            .frame(width: 30,height: 21)
                    }
                
                VStack(alignment: .leading,spacing: 10){
                    
                    Text(item.name)
                        .font(.custom(CustomFont.semiBold, size: 17))
                    
                    Text("Custom Timer (\(item.duration))")
                        .font(.custom(CustomFont.light, size: 14))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                Spacer()
                NavigationLink {
                    AddEditTimerView(myTimer: item, comeFrom: .edit).environmentObject(vm)
                } label: {
                    Image("ic_pen")
                        .resizable()
                        .frame(width: 25,height: 25)
                }.padding(15)
            }.padding(10)
        }
        .frame(height: 100)
        .padding(.horizontal)
        .foregroundColor(Color.white)
        .onDelete(
            callFrom: "",
            style: .init(radius: 10, corners: [.topRight, .bottomRight]),
            deleteAction: {
                withAnimation {
                    vm.myTimers.removeAll(where: { $0.id == item.id })
                    vm.deleteItem(item)
                }
            },
            editAction: {},
            copyAction: {},
            cutAction: {})
    }
    
    func folderCard(_ item: Folder) -> some View {
        ZStack{
            color.appCardColor
                .cornerRadius(15)
            VStack {
                HStack(spacing:10){
                    Circle()
                        .fill(color.appThemeColor)
                        .frame(width: 50, height: 50)
                        .overlay{
                            Image("ic_folder")
                                .resizable()
                                .frame(width: 25,height: 25)
                        }
                    
                    VStack(alignment: .leading,spacing: 10){
                        
                        Text(item.folderName)
                            .font(.custom(CustomFont.semiBold, size: 17))
                    }
                    Spacer()
                    
                    
                    ZStack{
                        color.appThemeColor
                        Image(systemName: item.isExpand ? "chevron.down" : "chevron.forward")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 13,height: 13)
                            .font(.system(size: 13,weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 25,height: 25)
                    .cornerRadius(12.5)
                    .foregroundColor(.white)
                    .padding(15)
                }
                .padding(10)
                .onTapGesture {
                    if let index = vm.folderArray.firstIndex(where: { $0.id == item.id }) {
                        vm.folderArray[index].isExpand.toggle()
                    }
                }
                
                if  item.isExpand {
                    
                    ScrollView(.vertical,showsIndicators: false) {
                        VStack{
                            if let index = vm.folderArray.firstIndex(where: { $0.id == item.id }) {
                                
                                ForEach(vm.folderArray[index].myTimers) { timer in
                                    
                                    NavigationLink {
                                        WorkoutTimerView(myTimer: timer).environmentObject(vm)
                                    } label: {
                                        folderTimerCard(timer,fIdx: index)
                                    }
                                }
                            }
                        }
                    }.padding(.bottom)
                }
            }
        }
        .frame(minHeight: 90)
        .padding(.horizontal)
        .foregroundColor(Color.white)
        .onDelete(
            callFrom: "",
            style: .init(radius: 10, corners: [.topRight, .bottomRight]),
            deleteAction: {
                withAnimation {
                    vm.folderArray.removeAll(where: { $0.id == item.id })
                    vm.deleteFolderItem(item)
                }
            },
            editAction: {},
            copyAction: {},
            cutAction: {})
    }
    
    func folderTimerCard(_ item: MyTimer,fIdx: Int) -> some View {
        
        ZStack{
            color.appBGColor
                .cornerRadius(15)
            HStack(spacing:10){
                Circle()
                    .fill(color.appThemeColor)
                    .frame(width: 50, height: 50)
                    .overlay{
                        Image("ic_dum")
                            .resizable()
                            .frame(width: 30,height: 21)
                    }
                
                VStack(alignment: .leading,spacing: 10){
                    
                    Text(item.name)
                        .font(.custom(CustomFont.semiBold, size: 17))
                    
                    Text("Custom Timer (\(item.duration))")
                        .font(.custom(CustomFont.light, size: 14))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                Spacer()
                NavigationLink {
                    AddEditTimerView(myTimer: item, comeFrom: .edit).environmentObject(vm)
                } label: {
                    Image("ic_pen")
                        .resizable()
                        .frame(width: 25,height: 25)
                }.padding(15)
            }.padding(10)
        }
        .frame(height: 90)
        .padding(.horizontal)
        .foregroundColor(Color.white)
        .onDelete(
            callFrom: "",
            style: .init(radius: 10, corners: [.topRight, .bottomRight]),
            deleteAction: {
                withAnimation {
                    if let idx = vm.folderArray[fIdx].myTimers.firstIndex(where: { $0.id == item.id }) {
                        vm.folderArray[fIdx].myTimers.remove(at: idx)
                        vm.deleteItem(item)
                    }
                }
            },
            editAction: {},
            copyAction: {},
            cutAction: {})
    }

    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    struct TimerListView_Previews: PreviewProvider {
        static var previews: some View {
            TimerListView()
        }
    }
}
