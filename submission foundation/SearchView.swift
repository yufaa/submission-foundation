//
//  ExploreView.swift
//  submission foundation
//
//  Created by Firman Ali on 06/04/23.
//

import SwiftUI

struct SearchView: View {
    @State var searchText = ""
    @State var isSearch = false
    
    var body: some View {
            NavigationStack {
                SearchedView(searchText: $searchText)
                    .navigationBarTitle("Search", displayMode: .large)
                    .searchable(text: $searchText, prompt: "Search your destination")
            }
        }
    }


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

struct SearchedView: View {
    
    @Environment(\.isSearching) private var isSearching
    @Binding var searchText: String
    
    @State var isSearch = false
    @State var showSheet = false
    
    var body: some View {
        VStack {
            if isSearch == false {
                VStack(alignment: .leading) {
                    Divider()
                        .shadow(color: .black, radius: 1)
                    VStack {
                        VStack(alignment: .leading) {
                            Text("Find Nerby")
                                .foregroundColor(Color(hex: 0x666666, opacity: 1))
                                .bold()
                            Divider()
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Find nearby location")
                                    .foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .background()
                            .onTapGesture {
                                let location = "watersport"
                                let url = URL(string: "maps://?q=\(location)")
                                if UIApplication.shared.canOpenURL(url!) {
                                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                                }
                            }
                            Divider()
                        }
                        .padding()
                        VStack(alignment: .leading) {
                            Text("Find By Preference")
                                .foregroundColor(Color(hex: 0x666666, opacity: 1))
                                .bold()
                            Divider()
                            HStack {
                                Image(systemName: "sparkle.magnifyingglass")
                                Text("Find location by preference")
                                    .foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .background()
                            .onTapGesture {
                                showSheet = true
//                                isSearching.toggle()
                                searchText = "watersport"
                            }
                            Divider()
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                }
            } else {
                ResultView()
            }
        }
        .sheet(isPresented: $showSheet) {
            SearchSheetView(showSheetView: self.$showSheet, isSearch: self.$isSearch)
        }
    }
}

struct SearchSheetView: View {
    @Binding var showSheetView: Bool
    @Binding var isSearch: Bool
    
    @State var price: [Preference] = [
        Preference(icon: Image(systemName: "dollarsign.square.fill"), color: .green, text: "Inexpensive"),
        Preference(icon: Image(systemName: "dollarsign.square.fill"), color: .red, text: "Expensive")
    ]
    @State var expLevel: [Preference] = [
        Preference(icon: Image(systemName: "figure.water.fitness"), color: Color( "lightBlue"), text: "Beginner"),
        Preference(icon: Image(systemName: "figure.open.water.swim"), color: .blue, text: "Intermediate"),
        Preference(icon: Image(systemName: "figure.waterpolo"), color: .purple, text: "Professional")
    ]
    @State var age: [Preference] = [
        Preference(icon: Image(systemName: "person.fill"), color: .blue, text: "12 - 16 Years Old"),
        Preference(icon: Image(systemName: "person.fill"), color: .blue, text: "17 - 25 Years Old"),
        Preference(icon: Image(systemName: "person.fill"), color: .blue, text: "26 - 35 Years Old"),
        Preference(icon: Image(systemName: "person.fill"), color: .blue, text: "36 - 50 Years Old")
    ]
    @State var categories: [Preference] = [
        Preference(icon: Image(systemName: "water.waves"), color: .green, text: "Relaxed"),
        Preference(icon: Image(systemName: "flame.fill"), color: .orange, text: "Adrenaline")
    ]
    @State var numPeople: [Preference] = [
        Preference(icon: Image(systemName: "figure.stand"), color: .green, text: "Solo"),
        Preference(icon: Image(systemName: "figure.2.arms.open"), color: .red, text: "Couple"),
        Preference(icon: Image(systemName: "person.3.fill"), color: .orange, text: "Group")
    ]
    @State var selectedPreference: [Preference] = []
    
    @State var showFab = true
    @State var scrollOffset: CGFloat = 0.00
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading){
//                Divider()
                List {
                    Section(header: Text("Pricing")) {
                        ForEach($price, id: \.id) { person in
                            MultipleSelectionRow(content: person, selected: $selectedPreference)
                        }
                    }
                    Section(header: Text("Experience Level")) {
                        ForEach($expLevel, id: \.id) { exp in
                            MultipleSelectionRow(content: exp, selected: $selectedPreference)
                        }
                    }
                    Section(header: Text("Age")) {
                        ForEach($age, id: \.id) { age in
                            MultipleSelectionRow(content: age, selected: $selectedPreference)
                        }
                    }
                    Section(header: Text("Categories")) {
                        ForEach($categories, id: \.id) { categories in
                            MultipleSelectionRow(content: categories, selected: $selectedPreference)
                        }
                    }
                    Section(header: Text("Number of People")) {
                        ForEach($numPeople, id: \.id) { people in
                            MultipleSelectionRow(content: people, selected: $selectedPreference)
                        }
                    }
                }
                .listStyle(.grouped)
                .padding(.bottom, 50)
                .background(GeometryReader {
                    return Color.clear.preference(key: ViewOffsetKey.self, value: -$0.frame(in: .named("scroll")).origin.y)
                    
                })
                .onPreferenceChange(ViewOffsetKey.self) { offset in
                    withAnimation {
                        if offset > 50 {
                            showFab = offset < scrollOffset
                        } else  {
                            showFab = true
                        }
                    }
                    scrollOffset = offset
                }
            }
            .coordinateSpace(name: "scroll")
            .overlay(showFab ? createFab() : nil, alignment: Alignment.bottomTrailing)
            .navigationBarTitle("Search", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                    print("Dismissing sheet view...")
                    self.showSheetView = false
                }) {
                    Text("Cancle").foregroundColor(.blue)
                }
            )
        }
    }
    
    fileprivate func createFab() -> some View {
        return Button {
            if self.selectedPreference.isEmpty != true {
                self.showSheetView = false
                self.isSearch.toggle()
            }
        } label: {
            Text("Search Now")
                .frame(maxWidth: .infinity)
                .padding(5)
        }
        .foregroundColor(.white)
        .tint(self.selectedPreference.isEmpty ? .gray : .blue)
        .padding()
        .buttonStyle(.borderedProminent)
        .shadow(radius: 3, x: 3, y: 3)
        .transition(.scale)
    }
}

struct MultipleSelectionRow<RowContent: SelectableRow>: View {
    var content: Binding<RowContent>
    @Binding var selected: [Preference]

    var body: some View {
        Button(action: {
            self.content.wrappedValue.isSelected.toggle()
            let pref = Preference(icon: content.wrappedValue.icon, color: content.wrappedValue.color, text: content.wrappedValue.text)
            if content.wrappedValue.isSelected {
                selected.append(pref)
            } else {
                selected.removeLast()
            }

        }) {
            HStack {
                content.wrappedValue.icon.foregroundColor(content.wrappedValue.color)
                Text(content.wrappedValue.text)
                Spacer()
                Image(systemName: content.wrappedValue.isSelected ? "checkmark.circle.fill" : "circle")
            }
        }
    }
}

protocol SelectableRow {
    var icon: Image { get }
    var color: Color { get }
    var text: String { get }
    var isSelected: Bool { get set }
}

struct Preference: Identifiable, SelectableRow {
    let id = UUID().uuidString
    let icon: Image
    let color: Color
    let text: String
    var isSelected: Bool = false
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
