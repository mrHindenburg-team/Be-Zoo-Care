import Foundation

struct BZCFallbackCareEngine {

    func respond(to query: String) -> String {
        let lower = query.lowercased()

        if lower.contains("groom") || lower.contains("brush") || lower.contains("coat") {
            return groomingResponse(for: lower)
        } else if lower.contains("feed") || lower.contains("food") || lower.contains("eat") || lower.contains("diet") {
            return feedingResponse(for: lower)
        } else if lower.contains("water") || lower.contains("drink") || lower.contains("hydrat") {
            return hydrationResponse(for: lower)
        } else if lower.contains("train") || lower.contains("behavior") || lower.contains("behaviour") || lower.contains("teach") {
            return trainingResponse(for: lower)
        } else if lower.contains("stress") || lower.contains("anxious") || lower.contains("anxiety") || lower.contains("hide") || lower.contains("scared") {
            return stressResponse(for: lower)
        } else if lower.contains("exercise") || lower.contains("walk") || lower.contains("play") || lower.contains("active") {
            return exerciseResponse(for: lower)
        } else if lower.contains("clean") || lower.contains("enclosure") || lower.contains("cage") || lower.contains("habitat") {
            return cleaningResponse(for: lower)
        } else if lower.contains("vaccin") || lower.contains("vet") || lower.contains("health") || lower.contains("sick") || lower.contains("ill") {
            return healthResponse(for: lower)
        } else if lower.contains("sleep") || lower.contains("rest") || lower.contains("tired") {
            return sleepResponse(for: lower)
        } else if lower.contains("rabbit") {
            return rabbitResponse()
        } else if lower.contains("bird") || lower.contains("parrot") {
            return birdResponse()
        } else if lower.contains("hamster") {
            return hamsterResponse()
        } else if lower.contains("reptile") || lower.contains("lizard") || lower.contains("snake") {
            return reptileResponse()
        } else {
            return generalCareResponse()
        }
    }

    // MARK: - Topic Responses

    private func groomingResponse(for query: String) -> String {
        if query.contains("dog") {
            return """
            **Dog Grooming Guide 🦏 Rex says:**

            • Short-haired breeds: brush once a week
            • Long-haired breeds: brush daily to prevent matting
            • Bathing: every 4–6 weeks, or when visibly dirty
            • Nail trims: every 3–4 weeks
            • Ear cleaning: check weekly, clean as needed

            Tip: Always use dog-specific shampoo — human products disrupt their skin pH. Start grooming sessions young so your dog becomes comfortable with the routine.
            """
        } else if query.contains("cat") {
            return """
            **Cat Grooming Guide 🦏 Rex says:**

            • Short-haired cats: brush 1–2 times per week
            • Long-haired cats: brush daily
            • Bathing: rarely needed — cats are self-grooming
            • Nail trims: every 2–3 weeks
            • Teeth cleaning: ideally 3 times per week

            Tip: Introduce brushing early and make it a positive experience with treats. Watch for hairballs — regular brushing significantly reduces them.
            """
        }
        return """
        **Grooming Basics 🦏 Rex says:**

        Regular grooming is essential for every animal. Key areas include:

        • Coat or fur care (brushing frequency depends on breed/species)
        • Nail or claw maintenance every 2–4 weeks
        • Ear cleaning to prevent infections
        • Dental hygiene — often overlooked but critical
        • Eye cleaning for breeds prone to discharge

        Always use species-appropriate grooming products. Make sessions positive with treats and praise to build trust.
        """
    }

    private func feedingResponse(for query: String) -> String {
        if query.contains("dog") {
            return """
            **Dog Feeding Guide 🦊 Finn says:**

            • Puppies (under 6 months): 3–4 meals per day
            • Adults: 2 meals per day
            • Seniors: 2 smaller meals per day

            Recommended portions depend on weight and activity level. A general rule: 2–3% of body weight in food daily for adults.

            **Avoid:** Chocolate, grapes, raisins, onions, garlic, xylitol, macadamia nuts, and cooked bones.
            """
        } else if query.contains("cat") {
            return """
            **Cat Feeding Guide 🦊 Finn says:**

            • Adult cats: 2 meals per day
            • Kittens: 3–4 meals per day
            • Provide fresh water at all times

            Cats are obligate carnivores — their diet must be meat-based. High-quality wet food supports hydration.

            **Avoid:** Dog food (lacks taurine), raw fish long-term, onions, garlic, and dairy products.
            """
        }
        return """
        **Feeding Fundamentals 🦊 Finn says:**

        Every species has unique nutritional requirements. Key principles:

        • Feed a species-appropriate, high-quality diet
        • Divide daily ration into 2 or more meals
        • Always provide fresh, clean water
        • Avoid human foods unless verified safe
        • Adjust portions based on age, weight, and activity

        Consult a veterinarian to determine the ideal diet for your specific animal's life stage.
        """
    }

    private func hydrationResponse(for query: String) -> String {
        return """
        **Hydration Guide 💧 Finn says:**

        Proper hydration is critical for organ health, digestion, and temperature regulation.

        • Dogs: approximately 30–50 ml of water per kilogram of body weight per day
        • Cats: 50–60 ml per kilogram (wet food helps significantly)
        • Rabbits: 50–100 ml per kilogram daily
        • Birds: always provide fresh water; change twice daily

        **Signs of dehydration:** lethargy, dry gums, skin tent test (skin stays raised when pinched), dark urine.

        Always provide clean, fresh water in bowls cleaned daily. Cats often prefer running water — consider a pet fountain.
        """
    }

    private func trainingResponse(for query: String) -> String {
        return """
        **Training & Behavior 🐺 Storm says:**

        Positive reinforcement is the gold standard for all animal training.

        **Core principles:**
        • Reward desired behavior immediately (within 1–2 seconds)
        • Use high-value treats for new behaviors
        • Keep sessions short: 5–10 minutes, 2–3 times daily
        • End every session on a success
        • Never punish — redirect instead

        **Command sequence:** Lure → Mark (clicker or "yes!") → Reward → Repeat → Phase out lure

        Consistency is everything. Everyone in the household should use the same commands and rules. Most dogs can learn a basic command in 50–100 repetitions.
        """
    }

    private func stressResponse(for query: String) -> String {
        return """
        **Reducing Stress & Anxiety 🐼 Pax says:**

        Animal stress often manifests as hiding, aggression, over-grooming, appetite loss, or destructive behavior.

        **Common causes:** new environment, loud noises, routine changes, lack of enrichment, social isolation.

        **Solutions:**
        • Create a safe, quiet retreat space
        • Maintain consistent daily routines
        • Provide environmental enrichment (toys, puzzles, hiding spots)
        • Use species-appropriate calming aids (pheromone diffusers, calming wraps)
        • Increase positive social interactions gradually
        • Ensure adequate exercise and mental stimulation

        If stress persists or is severe, consult a veterinarian — there may be underlying health causes.
        """
    }

    private func exerciseResponse(for query: String) -> String {
        return """
        **Exercise & Activity Guide 🐺 Storm says:**

        Physical activity is essential for physical health and mental wellbeing.

        **By species:**
        • Dogs: 30–120 minutes of exercise daily depending on breed
        • Cats: 15–30 minutes of interactive play daily
        • Rabbits: minimum 3 hours of free-roam space per day
        • Birds: flight time outside cage for at least 1–2 hours daily
        • Hamsters: a wheel is essential — 5+ km of running nightly is normal

        **Mental exercise matters too:** puzzle feeders, scent games, training sessions, and novel toys all stimulate cognitive health.

        A tired pet is a well-behaved, happy pet.
        """
    }

    private func cleaningResponse(for query: String) -> String {
        return """
        **Habitat & Enclosure Cleaning 🐼 Pax says:**

        A clean environment prevents disease and reduces stress.

        **Daily:** Remove waste, uneaten food, refresh water
        **Weekly:** Spot-clean soiled bedding, wipe surfaces with pet-safe cleaner
        **Monthly:** Full enclosure deep-clean with species-safe disinfectant

        **Bird cages:** Remove droppings daily, full clean weekly
        **Fish tanks:** 10–25% water changes weekly, gravel vacuum monthly
        **Reptile habitats:** Spot-clean daily, full clean every 4–6 weeks

        Always use pet-safe, non-toxic cleaning products. Rinse thoroughly before returning your animal. Avoid aerosol sprays near birds — many are toxic to their sensitive respiratory systems.
        """
    }

    private func healthResponse(for query: String) -> String {
        return """
        **Preventive Health 🦏 Rex says:**

        Preventive care is far better (and cheaper) than treating illness.

        **Annual vet visits** for health checks, vaccinations, parasite control
        **Dental care** — dental disease affects 80% of pets over 3 years old
        **Parasite prevention** — monthly flea, tick, and heartworm treatments
        **Vaccinations** — keep records up to date
        **Spay/neuter** — reduces cancer risk and unwanted behaviors

        **Warning signs requiring prompt vet attention:**
        Loss of appetite, vomiting/diarrhea lasting 24+ hours, lethargy, difficulty breathing, sudden weight loss, blood in urine or stool, seizures.

        Never self-diagnose or use human medications on animals without veterinary guidance.
        """
    }

    private func sleepResponse(for query: String) -> String {
        return """
        **Sleep & Rest 🐼 Pax says:**

        Adequate rest is critical for immune function, growth, and emotional wellbeing.

        **Sleep needs:**
        • Dogs: 12–14 hours per day (puppies and seniors up to 18 hours)
        • Cats: 12–16 hours per day (they are naturally crepuscular)
        • Rabbits: 8 hours, split into multiple naps
        • Hamsters: sleep during the day, active at night

        Provide a comfortable, warm, quiet sleep area away from high-traffic zones. Avoid disturbing your pet during sleep — interrupted rest causes stress and behavioral issues.
        """
    }

    private func rabbitResponse() -> String {
        return """
        **Rabbit Care Essentials 🦉 Sage says:**

        Rabbits are complex, sensitive animals often misunderstood as low-maintenance.

        • **Diet:** Unlimited timothy hay (80% of diet), fresh leafy greens daily, limited pellets
        • **Space:** Minimum 3m² enclosure + 3 hours free-roam daily
        • **Social:** Rabbits are highly social — consider bonded pairs
        • **Health:** Vaccinate for VHD and myxomatosis, annual dental checks
        • **Litter training:** Rabbits can be fully litter-trained
        • **Lifespan:** 8–12 years with proper care

        Never pick a rabbit up by the ears or let children carry them unsupported — they can break their own spine kicking.
        """
    }

    private func birdResponse() -> String {
        return """
        **Bird Care Essentials 🦉 Sage says:**

        Birds are highly intelligent, social, and long-lived companions.

        • **Diet:** Species-appropriate pellets (base), fresh fruits and vegetables, limited seeds
        • **Cage:** As large as possible — birds need to flap their wings fully
        • **Enrichment:** Foraging toys, shredding materials, puzzles, rotation of novel items
        • **Social time:** 2–4 hours of interaction daily
        • **Sleep:** 10–12 hours in a dark, quiet space
        • **Hazards:** Non-stick cookware fumes, scented candles, aerosol sprays, and certain houseplants are toxic

        Parrots especially bond deeply — neglect causes severe psychological distress.
        """
    }

    private func hamsterResponse() -> String {
        return """
        **Hamster Care Essentials 🦉 Sage says:**

        Hamsters have specific needs that are often underestimated.

        • **Cage:** Minimum 100cm × 50cm floor space — bigger is always better
        • **Wheel:** Solid-surface wheel, minimum 25cm diameter for Syrians
        • **Bedding:** Deep substrate (30–40cm) for burrowing
        • **Diet:** High-quality hamster mix, fresh vegetables in small amounts
        • **Handling:** Handle gently and consistently, especially in early weeks
        • **Nocturnal:** Most active at night — avoid disturbing during the day

        Syrian hamsters are solitary and must be housed alone. Dwarf species can sometimes be kept in same-sex pairs.
        """
    }

    private func reptileResponse() -> String {
        return """
        **Reptile Care Essentials 🦏 Rex says:**

        Reptiles require carefully controlled environments to thrive.

        • **Temperature:** A thermal gradient is essential — basking spot + cooler zone
        • **Lighting:** Full-spectrum UVB lighting for most species (8–12 hours/day)
        • **Humidity:** Species-specific — research your animal's natural habitat
        • **Diet:** Live or frozen-thawed prey for snakes; varied insects and greens for lizards
        • **Supplements:** Calcium and D3 dusting for insectivores
        • **Enclosure:** Escape-proof, properly sized, enriched with hides

        Reptiles hide illness well — subtle behavior changes (reduced activity, changes in defecation, loss of appetite) warrant veterinary attention.
        """
    }

    private func generalCareResponse() -> String {
        return """
        **Animal Care Fundamentals 🦊 Finn says:**

        Great pet care rests on five pillars:

        1. **Nutrition** — species-appropriate, high-quality diet with fresh water
        2. **Health** — regular vet visits, vaccinations, parasite control
        3. **Environment** — safe, clean, enriched habitat suited to natural behaviors
        4. **Behavior** — mental stimulation, training, species-appropriate socialization
        5. **Emotional wellbeing** — consistent routine, positive interaction, stress reduction

        Every species is unique. I encourage you to explore our Education hub for detailed guides on your specific animal. You can also ask me more specific questions like "How much should I feed my dog?" or "How do I reduce my cat's anxiety?"
        """
    }
}
