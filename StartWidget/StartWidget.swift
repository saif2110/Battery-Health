//
//  StartWidget.swift
//  StartWidget
//
//  Created by Junaid Mukadam on 16/04/21.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), percenatge: 90)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, percenatge: 90)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let percentage  = UserDefaults(suiteName: "group.com.Full-Battery.Health.percentage")!.object(forKey: "percentage") as? Int ?? 80
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, percenatge: percentage)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

//group.com.Full-Battery.Health.percentage
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let percenatge : Int
}



struct StartWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack{
            Color.init(#colorLiteral(red: 0.1784194794, green: 0.1792542546, blue: 0.1919928113, alpha: 1)).edgesIgnoringSafeArea(.all)
            VStack{
                HStack{
                    Text("Alarm Set On").fontWeight(.semibold).padding(.leading,15).padding(.top,9).foregroundColor(Color.init(#colorLiteral(red: 0.4682161212, green: 0.7442020774, blue: 0.2786980867, alpha: 1))).font(.system(size: 14))
                    
                    Spacer()
                }
                
                HStack{
                    Text("\(entry.percenatge)%")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .font(.system(size:35))
                        .padding(.leading,15)
                        .padding(.top,1)
                    
                    Spacer()
                }
                
                Spacer(minLength: 0)
                
                VStack{
                    Spacer()
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        HStack{
                            Spacer(minLength: 0)
                            Text("Start Alarm").fontWeight(.semibold).font(.system(size: 16)).foregroundColor(.white).padding(.top,10)
                            Spacer(minLength: 0)
                        }.padding(.bottom,12)
                        .background(Color.init(#colorLiteral(red: 0.4682161212, green: 0.7442020774, blue: 0.2786980867, alpha: 1)))
                    })
                    
                }.widgetURL(URL(string: "BatteryHealth://small"))
            }.widgetURL(URL(string: "BatteryHealth://small"))
        }.widgetURL(URL(string: "BatteryHealth://small"))
    }
}


@main
struct StartWidget: Widget {
    let kind: String = "StartWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            StartWidgetEntryView(entry: entry)
        }
        
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Quick Alarm")
        .description("Start an alarm directly from widget")
    }
}

struct StartWidget_Previews: PreviewProvider {
    static var previews: some View {
        StartWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), percenatge: 100))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
