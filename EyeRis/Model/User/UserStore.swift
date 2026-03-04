//
//  UserStore.swift
//  EyeRis
//
//  Created by SDC-USER on 04/03/26.
//

import CoreData

struct UserStore {
    
    let context = PersistenceController.shared.container.viewContext
    
    // MARK: - Save (creates or overwrites)
    
    func save(_ user: User) {
        // Always one user — delete existing before saving
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        _ = try? context.execute(deleteRequest)
        
        let entity = UserEntity(context: context)
        entity.firstName = user.firstName
        entity.lastName = user.lastName
        entity.gender = user.gender
        entity.dob = user.dob
        entity.conditions = user.eyeHealthData.condition
            .map { $0.rawValue }
            .joined(separator: ",")
        
        do {
            try context.save()
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    // MARK: - Fetch
    
    func fetchUser() -> User? {
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        
        do {
            guard let entity = try context.fetch(request).first else {
                return nil  // nil means no user saved yet → show onboarding
            }
            
            let conditions = (entity.conditions ?? "")
                .split(separator: ",")
                .compactMap { Conditions(rawValue: String($0)) }
            
            return User(
                firstName: entity.firstName ?? "",
                lastName: entity.lastName ?? "",
                gender: entity.gender ?? "",
                dob: entity.dob ?? Date(),
                eyeHealthData: UserEyeHealthData(condition: conditions)
            )
        } catch {
            print("Failed to fetch user: \(error)")
            return nil
        }
    }
    
    // MARK: - Exists check (for onboarding gate)
    
    func userExists() -> Bool {
        fetchUser() != nil
    }
}
