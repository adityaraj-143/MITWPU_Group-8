import CoreData

struct BlinkRateTestResultStore {
    
    let context = PersistenceController.shared.container.viewContext
    
    // MARK: - Save
    
    func save(_ result: BlinkRateTestResult) {
        let entity = BlinkRateTestResultEntity(context: context)
        entity.id = Int32(result.id)
        entity.blinks = Int32(result.blinks)
        entity.duration = Int32(result.duration)
        entity.performedOn = result.performedOn
        
        do {
            try context.save()
        } catch {
            print("Failed to save BlinkRateTestResult: \(error)")
        }
    }
    
    // MARK: - Fetch All
    func fetchAll() -> [BlinkRateTestResult] {
        let request = NSFetchRequest<BlinkRateTestResultEntity>(entityName: "BlinkRateTestResultEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "performedOn", ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                BlinkRateTestResult(
                    id: Int(entity.id),
                    blinks: Int(entity.blinks),
                    duration: Int(entity.duration),
                    performedOn: entity.performedOn ?? Date()
                )
            }
        } catch {
            print("Failed to fetch BlinkRateTestResults: \(error)")
            return []
        }
    }
}
