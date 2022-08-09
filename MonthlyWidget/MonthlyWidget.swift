//
//  MonthlyWidget.swift
//  MonthlyWidget
//
//  Created by Oscar Cristaldo on 2022-08-08.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry] = []

        // Generate a timeline consisting of seven entries a day apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: startOfDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DayEntry: TimelineEntry {
    let date: Date
}

struct MonthlyWidgetEntryView : View {
    var entry: DayEntry
    var config: MonthConfig
    
    init(entry: DayEntry) {
        self.entry = entry
        self.config = MonthConfig.determineConfig(from: entry.date)
    }

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(config.backgroundColor)
            
            VStack {
                HStack(spacing: 4) {
                    Text(config.emojiText)
                        .font(.title)
                    Text(entry.date.weekdayFormatDisplay)
                        .font(.title3)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.6)
                        .foregroundColor(config.weekdayTextColor)
                    Spacer()
                }
                Text(entry.date.dayFormatDisplay)
                    .font(.system(size: 80, weight: .heavy))
                    .foregroundColor(config.dayTextColor)
            }
            .padding()
        }
    }
}

@main
struct MonthlyWidget: Widget {
    let kind: String = "MonthlyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MonthlyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Monthly Style Widget")
        .description("The theme of the widget changes based on month.")
        .supportedFamilies([.systemSmall])
    }
}

struct MonthlyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyWidgetEntryView(entry: DayEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        MonthlyWidgetEntryView(entry: DayEntry(date: dateToDisplay(month: 12, day: 15)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
    
    static func dateToDisplay(month: Int, day: Int) -> Date {
        let components = DateComponents(calendar: Calendar.current,
                                        year: 2022,
                                        month: month,
                                        day: day)
        
        return Calendar.current.date(from: components)!
    }
}

extension Date {
    var weekdayFormatDisplay: String {
        self.formatted(.dateTime.weekday(.wide))
    }
    
    var dayFormatDisplay: String {
        self.formatted(.dateTime.day())
    }
}
