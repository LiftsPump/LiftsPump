//
//  FriendsManager.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 5/4/25.
//
import Contacts
import Supabase
import Foundation

public class FriendsManager: ObservableObject {
    private let store = CNContactStore()
    
    @Published public var contacts: [CNContact] = []
    @Published public var friendsSearch: [Friend] = []
    @Published public var friendRequests: [FriendRequest] = []

    public init() { }
    
    public func getFR() async {
        do {
            guard let creatorId = supabase.auth.currentUser?.id else {
                print("No logged-in user found")
                return
            }
            let response = try await supabase
                .from("friends")
                .select("*")
                .eq("requestee", value: creatorId)
                .execute()
            do {
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                decoder.dateDecodingStrategy = .formatted(formatter)
                friendRequests = try decoder.decode([FriendRequest].self, from: response.data)
            } catch {
                print("Decoding failed: \(error)")
                print(String(data: response.data, encoding: .utf8) ?? "No response string")
            }
        } catch {
            print("Failed to sync: \(error)")
        }
    }
    public func getUsername(profileToFind: UUID) async -> String? {
        do {
            let response = try await supabase
                .from("profile")
                .select("username")
                .eq("creator_id", value: profileToFind)
                .single()
                .execute()

            struct UsernameResponse: Codable {
                let username: String
            }

            let decoded = try JSONDecoder().decode(UsernameResponse.self, from: response.data)
            return decoded.username

        } catch {
            print("Failed to receive username: \(error)")
            return nil
        }
    }
    
    public func addFriend(friendToAdd: Friend) async {
        do {
            guard let creatorId = supabase.auth.currentUser?.id else {
                print("No logged-in user found")
                return
            }
            let requesteeId = friendToAdd.creator_id
            let payload = FriendsPayload(creatorId: creatorId, requesteeId: requesteeId, action: "request")
            let options = FunctionInvokeOptions(body: payload)
            try await supabase.functions
                .invoke(
                  "create-friend-request-log",
                  options: options
                )
            print("Friend added")
        } catch {
            print("Failed to add friend: \(error)")
        }
    }
    public func acceptFriend(friendToAdd: FriendRequest) async {
        do {
            let payload = FriendsPayload(creatorId: friendToAdd.creator_id, requesteeId: friendToAdd.requestee, action: "accept")
            let options = FunctionInvokeOptions(body: payload)
            try await supabase.functions
                .invoke(
                  "create-friend-request-log",
                  options: options
                )
            print("Friend accepted")
        } catch {
            print("Failed to add friend: \(error)")
        }
    }
    
    public func searchFriends(searchText: String) async {
            do {
                let response = try await supabase
                    .from("profile")
                    .select("*")
                    .filter("username", operator: "ilike", value: "%\(searchText)%")
                    .execute()
                try? friendsSearch = JSONDecoder().decode([Friend].self, from: response.data)
                print(friendsSearch)
            } catch {
                print("Failed to search friends: \(error)")
            }
        }

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
