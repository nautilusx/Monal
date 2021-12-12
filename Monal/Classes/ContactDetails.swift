//
//  ContactDetails.swift
//  Monal
//
//  Created by Jan on 22.10.21.
//  Copyright © 2021 Monal.im. All rights reserved.
//

import UIKit
import SwiftUI
import monalxmpp

struct ContactDetails: View {
    var delegate: SheetDismisserProtocol
    @StateObject var contact: ObservableKVOWrapper<MLContact>
    @State private var showingCannotBlockAlert = false
    @State private var showingRemoveContactConfirmation = false
    @State private var showingAddContactConfirmation = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                //header
                ContactDetailsHeader(contact: contact)
                
                //editables
                Group {
                    Spacer()
                        .frame(height: 20)
                    TextField("Nickname", text: $contact.nickNameView)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .modifier(ClearButton(text: $contact.nickNameView))
                }
                
                //buttons
                Group {
                    Spacer()
                        .frame(height: 20)
                    NavigationLink(destination: Resources(contact: contact)) {
                        Text("Resources")
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    NavigationLink(destination: KeysTable(contact: contact)) {
                        Text("OMEMO Keys")
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    Button(contact.isPinned ? "Unpin Chat" : "Pin Chat") {
                        contact.obj.togglePinnedChat(!contact.isPinned);
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    Button(contact.isBlocked ? "Unblock Contact" : "Block Contact") {
                        showingCannotBlockAlert = !contact.obj.toggleBlocked(!contact.isBlocked)
                    }
                    .alert(isPresented: $showingCannotBlockAlert) {
                        Alert(title: Text("Blocking Not Supported"), message: Text("The server does not support blocking (XEP-0191)."), dismissButton: .default(Text("Close")))
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    Group {
                        if(contact.isInRoster) {
                            Button(action: {
                                showingRemoveContactConfirmation = true
                            }) {
                                if(contact.isGroup) {
                                    Text(contact.mucType == "group" ? "Leave Group" : "Leave Channel")
                                } else {
                                    Text("Remove from contacts")
                                }
                            }
                            .actionSheet(isPresented: $showingRemoveContactConfirmation) {
                                ActionSheet(
                                    title: Text(contact.isGroup ? NSLocalizedString("Leave this conversation", comment: "") : String(format: NSLocalizedString("Remove %@ from contacts?", comment: ""), contact.contactJid)),
                                    message: Text(contact.isGroup ? NSLocalizedString("You will no longer receive messages from this conversation", comment: "") : NSLocalizedString("They will no longer see when you are online. They may not be able to send you encrypted messages.", comment: "")),
                                    buttons: [
                                        .cancel(),
                                        .destructive(
                                            Text("Yes"),
                                            action: {
                                                contact.obj.removeFromRoster()
                                                self.delegate.dismiss()
                                            }
                                        )
                                    ]
                                )
                            }
                        } else {
                            Button(action: {
                                showingAddContactConfirmation = true
                            }) {
                                Text("Add to contacts")
                            }
                            .actionSheet(isPresented: $showingAddContactConfirmation) {
                                ActionSheet(
                                    title: Text(String(format: NSLocalizedString("Add %@ to your contacts?", comment: ""), contact.contactJid)),
                                    message: Text("They will see when you are online. They will be able to send you encrypted messages."),
                                    buttons: [
                                        .cancel(),
                                        .default(
                                            Text("Yes"),
                                            action: {
                                                contact.obj.addToRoster()
                                            }
                                        ),
                                    ]
                                )
                            }
                        }
                    }
                }
                
                //make sure everything is aligned to the top of our view instead of vertically centered
                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)                   // will not be shown because swiftui does not know we navigated here from UIKit
            .navigationBarItems(leading: Button(action : {
                self.delegate.dismiss()
            }){
                Image(systemName: "arrow.backward")
            })
            .navigationTitle(contact.contactDisplayName as String)
        }
    }
}

struct KeysTable: UIViewControllerRepresentable {
    @ObservedObject var contact: ObservableKVOWrapper<MLContact>
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = MLKeysTableViewController()
        controller.contact = self.contact.obj
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

struct Resources: UIViewControllerRepresentable {
    @ObservedObject var contact: ObservableKVOWrapper<MLContact>
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = MLResourcesTableViewController()
        controller.contact = self.contact.obj
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

/*
struct BasicNavigationPhotoView : View {
    @ObservedObject var contact: ObservableKVOWrapper<MLContact>
    var body: some View {
        Image(systemName: "clock")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .navigationBarTitle(Text("Here we are now"))
    }
}
*/

struct ContactDetails_Previews: PreviewProvider {
    static var delegate = SheetDismisserProtocol()
    static var previews: some View {
        ContactDetails(delegate:delegate, contact:ObservableKVOWrapper<MLContact>(MLContact.makeDummyContact(0)))
        ContactDetails(delegate:delegate, contact:ObservableKVOWrapper<MLContact>(MLContact.makeDummyContact(1)))
        ContactDetails(delegate:delegate, contact:ObservableKVOWrapper<MLContact>(MLContact.makeDummyContact(2)))
        ContactDetails(delegate:delegate, contact:ObservableKVOWrapper<MLContact>(MLContact.makeDummyContact(3)))
        ContactDetails(delegate:delegate, contact:ObservableKVOWrapper<MLContact>(MLContact.makeDummyContact(4)))
    }
}
