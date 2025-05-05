//
//  FriendsManager.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 5/4/25.
//
import Contacts
import Foundation

public class FriendsManager: ObservableObject {
    private let store = CNContactStore()
    
    @Published public var contacts: [CNContact] = []

    public init() { }

    public func requestAccessAndFetchContacts() async {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        if status == .notDetermined {
            do {
                let granted = try await store.requestAccess(for: .contacts)
                if granted {
                    await fetchContacts()
                } else {
                    print("Access denied")
                }
            } catch {
                print("Error requesting contact access: \(error)")
            }
        } else if status == .authorized {
            await fetchContacts()
        } else {
            print("Access not authorized: \(status.rawValue)")
        }
    }

    @MainActor
    private func fetchContacts() async {
        let keysToFetch = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [CNKeyDescriptor]

        let request = CNContactFetchRequest(keysToFetch: keysToFetch)

        var fetchedContacts: [CNContact] = []

        do {
            try store.enumerateContacts(with: request) { (contact, _) in
                fetchedContacts.append(contact)
            }
            self.contacts = fetchedContacts.sorted {
                $0.givenName.localizedCaseInsensitiveCompare($1.givenName) == .orderedAscending
            }
            for contact in contacts {
                print(contact.givenName)
            }
        } catch {
            print("Failed to fetch contacts: \(error)")
        }
    }
}
