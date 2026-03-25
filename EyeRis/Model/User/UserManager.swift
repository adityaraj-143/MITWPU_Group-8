//
//  UserManager.swift
//  EyeRis
//
//  Single source of truth for user data.
//  Handles both in-memory access and CoreData persistence.
//

import Foundation
import CoreData

extension Notification.Name {
    static let userProfileDidUpdate = Notification.Name("userProfileDidUpdate")
}

final class UserManager {
    
    static let shared = UserManager()
    
    // MARK: - Private
    private let context = PersistenceController.shared.container.viewContext
    
    // MARK: - Current User (in-memory cache)
    private(set) var currentUser: User
    
    // MARK: - Init
    private init() {
        // Load from CoreData or use defaults for new users
        self.currentUser = Self.makeDefaultUser()
        
        if let savedUser = fetchFromCoreData() {
            self.currentUser = savedUser
        }
        
        ExerciseList.makeOnce(user: currentUser)
    }
    
    // MARK: - Default User (for new users / onboarding)
    private static func makeDefaultUser() -> User {
        User(
            firstName: "",
            lastName: "",
            gender: "",
            dob: Date(),
            eyeHealthData: UserEyeHealthData(condition: [])
        )
    }
    
    // MARK: - Public Update APIs (auto-persists)
    
    func updateFirstName(_ name: String) {
        currentUser.firstName = name
        persist()
    }
    
    func updateLastName(_ name: String) {
        currentUser.lastName = name
        persist()
    }
    
    func updateGender(_ gender: String) {
        currentUser.gender = gender
        persist()
    }
    
    func updateDOB(_ date: Date) {
        currentUser.dob = date
        persist()
    }
    
    func updateEyeConditions(_ conditions: [Conditions]) {
        currentUser.eyeHealthData.condition = conditions
        
        ExerciseList.reset()
        ExerciseList.makeOnce(user: currentUser)
        
        persist()
    }
    
    /// Batch update multiple fields at once (single persist call)
    func updateUser(
        firstName: String? = nil,
        lastName: String? = nil,
        gender: String? = nil,
        dob: Date? = nil,
        conditions: [Conditions]? = nil
    ) {
        if let firstName = firstName { currentUser.firstName = firstName }
        if let lastName = lastName { currentUser.lastName = lastName }
        if let gender = gender { currentUser.gender = gender }
        if let dob = dob { currentUser.dob = dob }
        if let conditions = conditions {
            currentUser.eyeHealthData.condition = conditions
            ExerciseList.reset()
            ExerciseList.makeOnce(user: currentUser)
        }
        
        persist()
    }
    
    // MARK: - Read Helpers
    
    var primaryEyeCondition: String {
        currentUser.eyeHealthData.primaryConditionText
    }
    
    var userExists: Bool {
        fetchFromCoreData() != nil
    }
    
    // MARK: - CoreData Persistence (Private)
    
    private func persist() {
        // Delete existing user (we only store one)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        _ = try? context.execute(deleteRequest)
        
        // Insert new
        guard let entity = NSEntityDescription.insertNewObject(
            forEntityName: "UserEntity",
            into: context
        ) as? UserEntity else { return }
        
        entity.firstName = currentUser.firstName
        entity.lastName = currentUser.lastName
        entity.gender = currentUser.gender
        entity.dob = currentUser.dob
        entity.conditions = currentUser.eyeHealthData.condition
            .map { $0.rawValue }
            .joined(separator: ",")
        
        do {
            try context.save()
            
            // Notify observers that user profile was updated
            NotificationCenter.default.post(name: .userProfileDidUpdate, object: nil)
        } catch {
            print("UserManager: Failed to persist user - \(error)")
        }
    }
    
    private func fetchFromCoreData() -> User? {
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        
        do {
            guard let entity = try context.fetch(request).first else {
                return nil
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
            print("UserManager: Failed to fetch user - \(error)")
            return nil
        }
    }
}
