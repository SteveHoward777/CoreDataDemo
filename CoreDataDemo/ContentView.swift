//
//  ContentView.swift
//  CoreDataDemo
//
//  Created by Steve Howard on 2024/12/1.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var newName = ""
    @State private var newGender = ""
    @State private var newAge: Int64 = 0
    @State private var isShowingAddForm = false

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("""
                            Name: \(item.name ?? "Unknown")
                            Gender: \(item.gender ?? "Unknown")
                            Age: \(item.age)
                            Created at: \(item.timestamp!, formatter: itemFormatter)
                        """)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "Unknown")
                            Text(item.timestamp!, formatter: itemFormatter)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { isShowingAddForm = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddForm) {
                VStack(spacing: 16) {
                    TextField("Name", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Gender", text: $newGender)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Age", value: $newAge, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    Button("Save") {
                        addItem()
                        isShowingAddForm = false
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.name = newName
            newItem.gender = newGender
            newItem.age = newAge

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
