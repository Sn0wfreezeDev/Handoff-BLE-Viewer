//
//  HandoffActivity.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 26.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Foundation

enum HandoffActivity: CaseIterable {
    case notesEditNote
    case mailViewMailbox
    case mailViewMessage
    case mailComposeMessage
    case applePodcast
    case keynoteEditPresentation
    case pagesEditDocument
    case numbersEditDocument
    case twodoSelecedList
    case twodoEditTask
    case viewWebpage
    
    case calendarDateSelection
    case calendarEventSelection
    
    case messages
    
    case home
    
    case unknown
    
    init(withHash hash: Data) {
        for activity in HandoffActivity.allCases {
            if activity.hash() == hash {
                self = activity
                return
            }
        }
        self = .unknown
    }
    
    func hash() -> Data {
        switch self {
        case .notesEditNote:
            return "88085c342dc9ed".hexadecimal!
        case .mailViewMailbox:
            return "9d98584545c05e".hexadecimal!
        case .mailViewMessage:
            return "86f6a0732b418e".hexadecimal!
        case .mailComposeMessage:
            return "a564c399758208".hexadecimal!
        case .applePodcast:
            return "a37b6b65fc4f5f".hexadecimal!
        case .keynoteEditPresentation:
            return "90ec0d1c7a00f7".hexadecimal!
        case .pagesEditDocument:
            return "a2f08c1c87dc98".hexadecimal!
        case .numbersEditDocument:
            return "855912d27f7828".hexadecimal!
        case .twodoSelecedList:
            return "99bee8c360dd13".hexadecimal!
        case .twodoEditTask:
            return "b2a2abdd925ef5".hexadecimal!
        case .viewWebpage:
            return "58c3379233c70b".hexadecimal!
        case .calendarDateSelection:
            return "b64729d1a4296b".hexadecimal!
        case .calendarEventSelection:
            return "88acfe99cad770".hexadecimal!
        case .messages:
            return "a32a9f48308fdc".hexadecimal!
        case .home:
            return "00000000000000".hexadecimal!
        case .unknown:
            return Data()
        }
    }
    
    func activityName() -> String {
        switch self {
        case .notesEditNote:
            return "com.apple.notes.activity.edit-note"
        case .mailViewMailbox:
            return "com.apple.mail.mailbox"
        case .mailViewMessage:
            return "com.apple.mail.message"
        case .mailComposeMessage:
            return "com.apple.mail.compose"
        case .applePodcast:
            //TODO: Check in Catalina with Podcasts app
            return "unknown"
        case .keynoteEditPresentation:
            return "com.apple.keynote.documentEditing"
        case .pagesEditDocument:
            return "com.apple.pages.documentEditing"
        case .numbersEditDocument:
            return "com.apple.numbers.documentEditing"
        case .twodoSelecedList:
            return "com.guidedways.2Do.SelectedList"
        case .twodoEditTask:
            return "com.guidedways.2Do.TaskEditing"
        case .viewWebpage:
            return "NSUserActivityTypeBrowsingWeb"
        case .calendarDateSelection:
            return "com.apple.calendar.continuity.date_selection"
        case .calendarEventSelection:
            return "com.apple.calendar.continuity.event_selection"
        case .messages:
            return "com.apple.Messages"
        case .home:
            return "Clear last Activity state"
        case .unknown:
            return "unkown"
        }
    }
    
    func appBundleId() -> String {
        switch self {
        case .notesEditNote:
            return "com.apple.Notes"
        case .mailViewMailbox, .mailViewMessage, .mailComposeMessage:
            return "com.apple.mail"
        case .applePodcast:
            return "com.apple.podcasts"
        case .keynoteEditPresentation:
            return "com.apple.iWork.Keynote"
        case .pagesEditDocument:
            return "com.apple.iWork.Pages"
        case .numbersEditDocument:
            return "com.apple.iWork.Numbers"
        case .twodoSelecedList, .twodoEditTask:
            return "com.guidedways.TodoMac"
        case .viewWebpage:
            return "com.apple.Safari"
        case .calendarDateSelection, .calendarEventSelection:
            return "com.apple.iCal"
        case .messages:
            return "com.apple.iChat"
        case .home:
            return "No app"
        case .unknown:
            return "Unkown"
        }
    }
}
