import Foundation

enum BZCSpecies: String, Codable, CaseIterable {
    case dog      = "Dog"
    case cat      = "Cat"
    case rabbit   = "Rabbit"
    case bird     = "Bird"
    case hamster  = "Hamster"
    case reptile  = "Reptile"
    case fish     = "Fish"
    case other    = "Other"

    var icon: String {
        switch self {
        case .dog:     "🐕"
        case .cat:     "🐈"
        case .rabbit:  "🐇"
        case .bird:    "🦜"
        case .hamster: "🐹"
        case .reptile: "🦎"
        case .fish:    "🐠"
        case .other:   "🐾"
        }
    }

    var symbolName: String {
        switch self {
        case .dog:     "dog.fill"
        case .cat:     "cat.fill"
        case .rabbit:  "hare.fill"
        case .bird:    "bird.fill"
        case .hamster: "pawprint.fill"
        case .reptile: "tortoise.fill"
        case .fish:    "fish.fill"
        case .other:   "pawprint.circle.fill"
        }
    }

    var primaryMascot: BZCMascot {
        switch self {
        case .dog:     .wolf
        case .cat:     .fox
        case .rabbit:  .panda
        case .bird:    .owl
        case .hamster: .panda
        case .reptile: .rhino
        case .fish:    .rhino
        case .other:   .fox
        }
    }

    var commonBreeds: [String] {
        switch self {
        case .dog:
            ["Labrador Retriever", "Golden Retriever", "German Shepherd", "Bulldog",
             "Poodle", "Beagle", "Husky", "Dachshund", "Shih Tzu", "Mixed Breed"]
        case .cat:
            ["Domestic Shorthair", "Maine Coon", "Siamese", "Persian",
             "Ragdoll", "Bengal", "British Shorthair", "Sphynx", "Scottish Fold", "Mixed Breed"]
        case .rabbit:
            ["Holland Lop", "Mini Rex", "Lionhead", "Dutch",
             "Flemish Giant", "Angora", "New Zealand", "Rex", "Mixed Breed"]
        case .bird:
            ["Budgerigar", "Cockatiel", "African Grey", "Macaw",
             "Conure", "Lovebird", "Canary", "Finch", "Amazon Parrot"]
        case .hamster:
            ["Syrian", "Dwarf Campbell", "Dwarf Winter White", "Roborovski",
             "Chinese Hamster"]
        case .reptile:
            ["Bearded Dragon", "Leopard Gecko", "Ball Python", "Corn Snake",
             "Blue-Tongued Skink", "Crested Gecko", "Russian Tortoise", "Red-Eared Slider"]
        case .fish:
            ["Betta", "Goldfish", "Guppy", "Neon Tetra",
             "Angelfish", "Oscar", "Clownfish", "Discus", "Pleco"]
        case .other:
            ["Guinea Pig", "Chinchilla", "Ferret", "Sugar Glider",
             "Hedgehog", "Axolotl", "Tarantula"]
        }
    }
}
