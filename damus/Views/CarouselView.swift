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

let createDID_items = [
    CarouselItem(image: Image("Feeds-logo-signin"), text: Text("欢迎来到我的第一个身份.", comment: "注释")),
    CarouselItem(image: Image("Feeds-logo-signin"),
                 text: Text("此应用程序使用去中心身份（DID）。 使用去中心身份，您拥有自己的身份和数据。\n \n 因此，您似乎还不知道这是什么，或者您从未创建自己的身份？ 我们在这里为您提供帮助，以下步骤将自动为您创建和发布全新的Elastos身份和存储空间。", comment: "").font(.system(size: 18))),
    CarouselItem(image: Image("Feeds-logo-signin"),
                 text: Text("将来，如果您想更好地控制或在其他支持DID的应用程序中使用此身份，可以将其导出到第三方钱包应用程序，例如Elastos Essential.", comment: "Explanation of what is done to keep personally identifiable information private. There is a heading that precedes this explanation which is a variable to this string.").font(.system(size: 18))),
]

struct CarouselView: View {
        
    var body: some View {
        
        TabView() {
            ForEach(carousel_items) { item in
                CarouselItemView(item: item)
                    .tabItem {
                        Text(item.id)
                    }
            }
        }.tabViewStyle(PageTabViewStyle())

    }
}

struct CarouselNewView: View {
    
    @Binding var selectedIndex: Int
    
    var body: some View {
        
        TabView(selection: $selectedIndex) {
            ForEach(0..<createDID_items.count) { i in
                CarouselItemView(item: createDID_items[i])
                    .tabItem {
                        Text(createDID_items[i].id)
                    }.tag(i)
            }
        }.tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))

    }
}

func CarouselText(_ txt: String) -> some View {
    return Text(txt)
}

struct CarouselItemView: View {
    let item: CarouselItem
    
    var body: some View {
        VStack(spacing: 70) {
            item.image
                .resizable()
                .frame(width: 200, height: 133)
            item.text
                .multilineTextAlignment(.leading)
                .font(.system(size: 18))
                .foregroundColor(Color.white)
                .padding([.leading,.trailing], 50.0)
                .minimumScaleFactor(0.5)
            Spacer()
        }
    }
}
