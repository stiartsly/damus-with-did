//
//  CarouselView.swift
//  damus
//
//  Created by William Casarin on 2022-05-20.
//

import SwiftUI

struct CarouselItem: Identifiable {
    let image: Image
    let text: Text
    
    let id = UUID().uuidString
}

let carousel_items = [
    CarouselItem(image: Image("logo"), text: Text("Welcome to the social network \(Text("you", comment: "You, in this context, is the person who controls their own social network. You is used in the context of a larger sentence that welcomes the reader to the social network that they control themself.").italic()) control.", comment: "Welcoming message to the reader. The variable is 'you', the reader.")),
    CarouselItem(image: Image("encrypted-message"),
                 text: Text("\(Text("数据自主", comment: "您的秘钥方能解锁您的数据.").bold()). 您的秘钥方能解锁您的数据.", comment: "Explanation of what is done to keep private data encrypted. There is a heading that precedes this explanation which is a variable to this string.")),
    CarouselItem(image: Image("undercover"),
                 text: Text("\(Text("去中心化", comment: "没有中心服务器&免审查.").bold()). 没有中心服务器&免审查.", comment: "Explanation of what is done to keep personally identifiable information private. There is a heading that precedes this explanation which is a variable to this string.")),
    CarouselItem(image: Image("bitcoin-p2p"),
                 text: Text("\(Text("安全", comment: "您的数据受到高度保护.").bold()). 您的数据受到高度保护.", comment: "Explanation of what can be done by users to earn money. There is a heading that precedes this explanation which is a variable to this string."))
]

struct CarouselView: View {
    var body: some View {
        TabView {
            ForEach(carousel_items) { item in
                CarouselItemView(item: item)
                    .tabItem {
                        Text(item.id)
                    }
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

func CarouselText(_ txt: String) -> some View {
    return Text(txt)
}

struct CarouselItemView: View {
    let item: CarouselItem
    
    var body: some View {
        VStack(spacing: 30) {
            item.image
                .resizable()
                .frame(width: 120, height: 120)
            item.text
                .multilineTextAlignment(.center)
                .font(.title2)
                .foregroundColor(Color.white)
                .padding([.leading,.trailing], 50.0)
                .minimumScaleFactor(0.5)
        }
    }
}
