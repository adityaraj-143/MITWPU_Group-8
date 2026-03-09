import CoreData

struct AcuityTestResultStore {
    
    let context = PersistenceController.shared.container.viewContext
    
    // MARK: - Save
    
    func save(_ result: AcuityTestResult) {
        let entity = AcuityTestResultEntity(context: context)
        entity.id = Int32(result.id)
        entity.testType = result.testType == .distantVision ? "DistantVision" : "NearVision"
        entity.testDate = result.testDate
        entity.healthyScore = result.healthyScore
        entity.leftEyeScore = result.leftEyeScore
        entity.rightEyeScore = result.rightEyeScore
        entity.comment = result.comment
        
        do {
            try context.save()
        } catch {
            print("Failed to save AcuityTestResult: \(error)")
        }
    }
    
    // MARK: - Fetch All
    
    func fetchAll() -> [AcuityTestResult] {
        let request = NSFetchRequest<AcuityTestResultEntity>(entityName: "AcuityTestResultEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "testDate", ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                AcuityTestResult(
                    id: Int(entity.id),
                    testType: entity.testType == "DistantVision" ? .distantVision : .nearVision,
                    testDate: entity.testDate ?? Date(),
                    healthyScore: entity.healthyScore ?? "",
                    leftEyeScore: entity.leftEyeScore ?? "",
                    rightEyeScore: entity.rightEyeScore ?? "",
                    comment: entity.comment ?? ""
                )
            }
        } catch {
            print("Failed to fetch AcuityTestResults: \(error)")
            return []
        }
    }
}
