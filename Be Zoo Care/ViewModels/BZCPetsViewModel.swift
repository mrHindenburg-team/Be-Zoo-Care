import SwiftData
import SwiftUI
import Observation

@Observable
final class BZCPetsViewModel {

    var searchText: String = ""
    var selectedSpecies: BZCSpecies?
    var isAddingPet: Bool = false
    var selectedPet: BZCPet?

    // MARK: - Add Pet Form State

    var newPetName: String = ""
    var newPetSpecies: BZCSpecies = .dog
    var newPetBreed: String = ""
    var newPetGender: BZCGender = .unknown
    var newPetWeight: Double = 0
    var newPetDateOfBirth: Date = .now
    var newPetHasDOB: Bool = false
    var newPetNotes: String = ""
    var newPetPhoto: UIImage?

    var isFormValid: Bool {
        !newPetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func filteredPets(_ all: [BZCPet]) -> [BZCPet] {
        var pets = all.filter { !$0.isArchived }

        if let species = selectedSpecies {
            pets = pets.filter { $0.species == species }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            pets = pets.filter {
                $0.name.localizedStandardContains(query) ||
                $0.breed.localizedStandardContains(query) ||
                $0.species.rawValue.localizedStandardContains(query)
            }
        }

        return pets.sorted { $0.name < $1.name }
    }

    func createPet(in context: ModelContext, progress: BZCGuardianProgress) -> BZCPet {
        let pet = BZCPet(
            name: newPetName.trimmingCharacters(in: .whitespacesAndNewlines),
            species: newPetSpecies,
            breed: newPetBreed,
            gender: newPetGender,
            weightKg: newPetWeight
        )
        if newPetHasDOB {
            pet.dateOfBirth = newPetDateOfBirth
        }
        if !newPetNotes.isEmpty {
            pet.notes = newPetNotes
        }
        if let image = newPetPhoto, let data = image.jpegData(compressionQuality: 0.8) {
            pet.photoData = data
        }
        context.insert(pet)
        progress.recordPetAdded()
        resetForm()
        return pet
    }

    func logCareActivity(
        _ type: BZCCareType,
        for pet: BZCPet,
        notes: String = "",
        in context: ModelContext,
        progress: BZCGuardianProgress
    ) {
        let activity = BZCCareActivity(type: type, notes: notes)
        pet.careActivities.append(activity)
        progress.recordCareActivity()
    }

    func archivePet(_ pet: BZCPet) {
        pet.isArchived = true
    }

    private func resetForm() {
        newPetName = ""
        newPetSpecies = .dog
        newPetBreed = ""
        newPetGender = .unknown
        newPetWeight = 0
        newPetHasDOB = false
        newPetNotes = ""
        newPetPhoto = nil
        isAddingPet = false
    }
}
