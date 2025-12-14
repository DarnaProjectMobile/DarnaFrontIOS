import Foundation
import Combine

class VisitListViewModel: ObservableObject {
    @Published var visits: [Visit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let visitService = VisitService()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchVisits(userId: String, userType: UserType) {
        isLoading = true
        errorMessage = nil
        
        visitService.fetchVisits(userId: userId, userType: userType) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let visits):
                    self?.visits = visits
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error fetching visits: \(error)")
                }
            }
        }
    }
    
    func createVisit(_ visit: CreateVisitRequest, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        visitService.createVisit(visit) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let newVisit):
                    self?.visits.append(newVisit)
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error creating visit: \(error)")
                    completion(false)
                }
            }
        }
    }
    
    func updateVisit(_ id: String, with updateData: UpdateVisitRequest, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        visitService.updateVisit(id: id, with: updateData) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let updatedVisit):
                    if let index = self?.visits.firstIndex(where: { $0.id == id }) {
                        self?.visits[index] = updatedVisit
                    }
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error updating visit: \(error)")
                    completion(false)
                }
            }
        }
    }
    
    func deleteVisit(_ id: String) {
        isLoading = true
        errorMessage = nil
        
        visitService.deleteVisit(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(_):
                    self?.visits.removeAll { $0.id == id }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error deleting visit: \(error)")
                }
            }
        }
    }
}
