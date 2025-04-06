//
//  Theme.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/21/24.
//

import SwiftUI

struct Theme {
    struct Fonts {
        static let Heading1 = Font.custom("Play-Bold", size: 50)
        static let Heading2 = Font.custom("Play-Bold", size: 44)
        static let Heading3 = Font.custom("Play-Bold", size: 40)
        static let Heading4 = Font.custom("Play-Bold", size: 46)
        static let Heading5 = Font.custom("Play-Bold", size: 32)
        static let Heading6 = Font.custom("Play-Bold", size: 28)
        static let SubHeading1 = Font.custom("SourceSans3-SemiBold", size: 32)
        static let SubHeading2 = Font.custom("SourceSans3-SemiBold", size: 24)
        static let SubHeading3 = Font.custom("SourceSans3-Regular", size: 20)
        static let SubHeading4 = Font.custom("SourceSans3-SemiBold", size: 26)
        static let SubHeading5 = Font.custom("SourceSans3-SemiBold", size: 16)
        static let SubHeading6 = Font.custom("SourceSans3-SemiBold", size: 18)
        static let SubHeading7 = Font.custom("SourceSans3-SemiBold", size: 20)
        static let SubHeading8 = Font.custom("SourceSans3-Regular", size: 22)
        static let Body1 = Font.custom("SourceSans3-Regular", size: 16)
        static let Body2 = Font.custom("SourceSans3-Light", size: 16)
        static let Body3 = Font.custom("SourceSans3-Regular", size: 15)
        static let Body4 = Font.custom("SourceSans3-Light", size: 15)
        static let Body5 = Font.custom("SourceSans3-SemiBold", size: 14)
        static let Body6 = Font.custom("SourceSans3-Light", size: 13)
        static let Body7 = Font.custom("SourceSans3-Light", size: 6)

    }
    struct Colors {
        static let Primary1 = Color.init(red: 0.10196078431372549, green: 0.8784313725490196, blue: 0.4980392156862745)
        static let Primary2 = Color.init(red: 0.14901960784313725, green: 0.7215686274509804, blue: 0.44313725490196076)
        static let Secondary = Color.init(red: 0.12549019607843137, green: 0.2196078431372549, blue: 0.23921568627450981)
        static let NeutralDark = Color.init(red: 0.11372549019, green: 0.10196078431, blue: 0.12549019607)
        static let NeutralDark2 = Color.init(red: 0.1804, green: 0.1686, blue: 0.1922)
        static let NeutralDarkGray1 = Color.init(red: 0.38039215686, green: 0.38039215686, blue: 0.38039215686)
        static let NeutralGray1 = Color.init(red: 0.73333333333, green: 0.73333333333, blue: 0.73333333333)
        static let NeutralLight1 = Color.init(red: 1, green: 1, blue: 1)
        static let NeutralLight2 = Color.init(red: 0.9607843137254902, green: 0.9607843137254902, blue: 0.9607843137254902)
        static let NeutralLight3 = Color.init(red: 0.8745098039215686, green: 0.8745098039215686, blue: 0.8745098039215686)
        static let PurpleGradient = Color.init(red: 0.38823529411, green: 0.35294117647, blue: 0.43529411764)
        static let Red = Color.init(red: 0.925, green: 0, blue: 0)
    }
}
