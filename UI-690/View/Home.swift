//
//  Home.swift
//  UI-690
//
//  Created by nyannyan0328 on 2022/10/06.
//

import SwiftUI

struct Home: View {
    @StateObject var model : DynamicProgress = .init()
    @State var sampleProgress : CGFloat = 0
    var body: some View {
        
        Button("\(model.isAdded ? "Stop" : "Start") DownLoaded"){
            
            
            if model.isAdded{
                
                model.removeProgressWithAnimaions()
                
                
                
            }
            else{
                
                let config = ProgressConfig(title: "MLB", progressImage: "arrow.up", expandedImage: "clock.badge.checkmark.fill", tint: .yellow,rotationEnalbled: true)
                
                model.addProgressView(config: config)
                
                
            }
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
        .padding(.top,60)
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            
            
            if model.isAdded{
                
                sampleProgress += 0.9
                
                model.updateProgressView(to: sampleProgress / 100)
            }
            else{
                sampleProgress = 0
            }
            
        }
        .statusBarHidden(model.hideStatuBar)
    
       
       
            
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class DynamicProgress : NSObject,ObservableObject{
    
   
    
    @Published var hideStatuBar : Bool = false
    @Published var isAdded : Bool = false
    
    func addProgressView(config : ProgressConfig){
        
        if rootController().view.viewWithTag(1009) == nil{
            
            
            let swiftUIView = DynamicProgressView(config: config).environmentObject(self)
            
            let hotingView = UIHostingController(rootView: swiftUIView)
            
            hotingView.view.frame = screenSize()
            hotingView.view.backgroundColor = .clear
            hotingView.view.tag = 1009
           
            rootController().view.addSubview(hotingView.view)
            
            isAdded = true
            
            
            
            
        }
        else{
            
            print("Already Added")
            
            
        }
        
    }
    
    func removeProgressWithAnimaions(){
        
        
        NotificationCenter.default.post(name: NSNotification.Name("CLOSE_UPDATE"), object: nil)
    }
    
    func removeProgressView(){
        
        if let view = rootController().view.viewWithTag(1009){
            view.removeFromSuperview()
            isAdded = false
            
            
        }
    }
    
    func updateProgressView(to : CGFloat){
        
        NotificationCenter.default.post(name: NSNotification.Name("UPDATE_PROGRESSS"), object: nil,userInfo: [
        
            "progress" : to
        
        ])
    }
    
    
    func screenSize()->CGRect{
        
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return.zero}
        
        return window.screen.bounds
    }
    
    func rootController()->UIViewController{
        
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return.init()}
        
        guard let root = window.windows.first?.rootViewController else{return .init()}
        
        return root
    }
        
        
        
    
    
}

struct DynamicProgressView : View{
    
    var config : ProgressConfig
    
    @State var showProgressView : Bool = false
    
    @EnvironmentObject var model : DynamicProgress
    
    @State var progress : CGFloat = 0
    
    @State var  showAlertView  : Bool = false
    var body: some View{
        
        Canvas { cxt, size in
            cxt.addFilter(.alphaThreshold(min: 0.5,color: .black))
            cxt.addFilter(.blur(radius: 5.5))
            cxt.drawLayer { context in
             
                for index in [1,2]{
                    
                    if let resovedImage = context.resolveSymbol(id: index){
                        
                        context.draw(resovedImage, at: CGPoint(x: size.width / 2, y: 11 + 18))
                        
                    }
                    
                }
                
            
            }
            
        } symbols: {
            
            ProgreeComponets()
                .tag(1)
            
            ProgreeComponets(isCircle: true)
                .tag(2)
            
        }
        .overlay(alignment: .top) {
            
            
            ProgreesView()
                .offset(y:11)
            
        }
        .overlay(alignment: .top) {
            
            
         customAlertView()
            
        }
        
        .ignoresSafeArea()
     
   
  
    
        .allowsTightening(false)
       
        
     
        .onAppear{
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                
             showProgressView = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CLOSE_UPDATE")), perform: { _ in
            
            showProgressView = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
             
                model.removeProgressView()
                
            }
            
        })
     
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UPDATE_PROGRESSS")), perform: { output in
            
            
            if let info = output.userInfo,let progress = info["progress"] as? CGFloat{
                
                if progress < 1.0{
                    
                    self.progress = progress
                    
                    if (progress * 100).rounded() == 100.0{
                        
                        showProgressView = false
                        showAlertView = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            
                            model.hideStatuBar = true
                            
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){

                            showAlertView = false
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                
                                model.hideStatuBar = false
                                
                            }
                            
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
                                
                                
                                model.removeProgressView()
                                
                            }

                        }
                        
                        
                    }

                  
                }
                
            }
        })
       
    
    
        
        
        

        
    }
    @ViewBuilder
    func customAlertView ()->some View{
        
        
        GeometryReader{
            
            let size = $0.size
            
            Capsule()
                .fill(.black)
                .frame(width: showAlertView ? size.width : 125,height: showAlertView ? size.height : 35)
                .overlay {
                    
                    HStack{
                        
                        Image(systemName: config.expandedImage)
                            .font(.largeTitle)
                            .foregroundStyle(.white,.blue,.red)
                        
                        HStack(spacing: 13) {
                            
                              Text("Downloaded")
                                .font(.system(size: 13))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                       
                            Text(config.title)
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            
                            
                            
                        }
                        .lineLimit(1)
                        .contentTransition(.opacity)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .offset(y:11)
                    }
                    .padding(.horizontal)
                    .blur(radius: showAlertView ? 0 : 5)
                    .opacity(showAlertView ? 1 : 0)
                    
                }
               .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
        }
        .frame(height: 65)
        .padding(.horizontal,18)
        .offset(y:showAlertView ? 11 : 12)
        .animation(.interactiveSpring(response: 0.5,dampingFraction: 0.7,blendDuration: 0.7).delay(showAlertView ? 0.35 : 0), value: showAlertView)
        
        
        
        
    }
    @ViewBuilder
    func ProgreesView ()->some View{
        
        ZStack{
            
            let rotation = (progress > 1 ? 1 : (progress < 0 ? 0 : progress))
            
            
            Image(systemName: config.progressImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .fontWeight(.semibold)
                .frame(width: 12,height: 12)
                .foregroundColor(config.tint)
                .rotationEffect(.init(degrees: config.rotationEnalbled ? Double(rotation * 360) : 0))
            
            ZStack{
                
                Circle()
                    .stroke(.white.opacity(0.3),lineWidth: 4)
                
                Circle()
                    .trim(from: 0,to:progress)

                    .stroke(config.tint, style: StrokeStyle(lineWidth: 4,lineCap: .round,lineJoin: .round))
                    .rotationEffect(.init(degrees: -90))
                
                
            }
             .frame(width: 23,height: 23)
    
            
            
        }
         .frame(width: 37,height: 37)
         .frame(width: 126,alignment: .trailing)
         .opacity(showProgressView ? 1 : 0)
         .offset(x:showProgressView ? 45 : 0)
         .animation(.interactiveSpring(response: 0.5,dampingFraction: 0.5,blendDuration: 0.5), value: showProgressView)
        
     
        
        
    }
    @ViewBuilder
    func ProgreeComponets(isCircle : Bool = false) -> some View{
        
        
        if isCircle{
            
            
            Circle()
            .fill(.black)
             .frame(width: 37,height: 37)
             .frame(width: 126,alignment: .trailing)
             .offset(x:showProgressView ? 45 : 0)
             .scaleEffect(showProgressView ? 1 : 0.55,anchor: .trailing)
             .animation(.interactiveSpring(response: 0.5,dampingFraction: 0.5,blendDuration: 0.5), value: showProgressView)
            
            
    
                
            
            
        }
        else{
            
            Capsule()
             .fill(.black)
             .frame(width: 126,height: 36)
             .offset(y:1)
             
             
        }
        
        
    }
    
 

}

