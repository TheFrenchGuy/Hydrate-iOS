//
//  HydrateWidget.swift
//  HydrateWidget
//
//  Created by Noe De La Croix on 28/01/2021.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct HydrateWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        //Text(entry.date, style: .time)
        ZStack {
            if widgetFamily == .systemSmall {
                Image("HydrateIcon").resizable()
                Text("52%")
            }
            
            if widgetFamily == .systemMedium {
                HStack {
                    ZStack {
                        Image("HydrateIcon").resizable().aspectRatio(contentMode: .fit)
                        Text("52%")
                    }
                    Button(action: {
                        //To be added later
                    }) {
                        Image(systemName: "plus.app")
                    }
                }
            }
        }.background(Color.white)
    }
}

@main
struct HydrateWidget: Widget {
    let kind: String = "HydrateWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            HydrateWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hydrate")
        .description("Don't forget to Hydrate yourself")
        .supportedFamilies([.systemMedium, .systemSmall])
    }
}

struct HydrateWidget_Previews: PreviewProvider {
    static var previews: some View {
        HydrateWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        HydrateWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        //HydrateWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
