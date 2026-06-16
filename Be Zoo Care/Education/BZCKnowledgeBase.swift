import Foundation

enum BZCKnowledgeBase {

    static let all: [BZCEducationalArticle] = nutritionArticles
        + healthArticles
        + groomingArticles
        + behaviorArticles
        + trainingArticles
        + safetyArticles
        + seniorCareArticles
        + youngAnimalArticles

    // MARK: - Nutrition

    static let nutritionArticles: [BZCEducationalArticle] = [
        BZCEducationalArticle(
            id: "nut-001",
            title: "Understanding Pet Nutrition Labels",
            summary: "Learn how to decode pet food labels and make the best dietary choices.",
            content: """
            ## Understanding Pet Nutrition Labels

            Reading a pet food label is the first step to providing optimal nutrition. Here's what matters most:

            ### Ingredient Order
            Ingredients are listed by weight before cooking. Whole meat (e.g., "chicken") as the first ingredient indicates a quality protein source. "Chicken meal" is also acceptable — it's concentrated protein after moisture removal.

            ### Guaranteed Analysis
            - **Crude Protein:** Minimum percentage of protein content
            - **Crude Fat:** Minimum fat percentage
            - **Crude Fiber:** Maximum fiber percentage
            - **Moisture:** Maximum water content

            ### Life Stage Labeling
            Foods labeled "All Life Stages" must meet the most demanding nutritional profile (puppies/kittens). Foods labeled for "Adult Maintenance" may be less calorie-dense.

            ### AAFCO Statement
            Look for the Association of American Feed Control Officials statement confirming the food is "complete and balanced" for the stated life stage. This means it meets minimum nutritional requirements.

            ### Avoiding Red Flags
            - Excessive artificial preservatives (BHA, BHT, ethoxyquin)
            - Vague protein sources ("meat by-products")
            - Sugar or corn syrup as an ingredient
            - Colors/dyes serve no nutritional purpose

            **Remember:** The best diet is one your individual animal thrives on. Regular vet check-ups can confirm your pet's nutritional needs are being met.
            """,
            category: .nutrition,
            species: [],
            readTimeMinutes: 5,
            mascot: .owl,
            isPremium: false,
            tags: ["nutrition", "food", "labels", "diet"]
        ),

        BZCEducationalArticle(
            id: "nut-002",
            title: "Dangerous Foods: What Your Pet Should Never Eat",
            summary: "A comprehensive guide to toxic foods for dogs, cats, rabbits, and birds.",
            content: """
            ## Foods That Can Harm Your Pets

            Many foods that are perfectly safe for humans can be toxic or even fatal to animals. This guide covers the most important ones.

            ### Dogs
            **Never feed:**
            - **Chocolate** — contains theobromine; causes vomiting, seizures, cardiac arrest
            - **Grapes & Raisins** — can cause sudden kidney failure
            - **Xylitol** — found in sugar-free gum, peanut butter; causes hypoglycemia and liver failure
            - **Onions & Garlic** — destroy red blood cells, causing anemia
            - **Macadamia Nuts** — weakness, vomiting, hyperthermia
            - **Cooked Bones** — splinter into dangerous shards
            - **Alcohol** — even small amounts cause serious harm
            - **Avocado** — persin causes vomiting and diarrhea

            ### Cats
            All of the above, plus:
            - **Raw Fish (long-term)** — destroys vitamin B1, causing neurological damage
            - **Dairy Products** — most adult cats are lactose intolerant
            - **Dog Food** — lacks taurine, causing heart disease and blindness
            - **Raw Eggs** — risk of salmonella and biotin deficiency

            ### Rabbits
            - **Iceberg Lettuce** — causes digestive upset
            - **Potato, Rhubarb, Tomato Leaves** — toxic
            - **Sugary treats** — disrupt gut bacteria balance
            - **Muesli mixes** — cause selective feeding and obesity

            ### Birds
            - **Avocado** — highly toxic to most birds; fatal
            - **Chocolate** — toxic
            - **Onion & Garlic** — toxic
            - **Non-stick cookware fumes (PTFE)** — can kill a bird within minutes
            - **Salt** — dangerous even in small amounts

            **If in doubt, leave it out.** Contact your veterinarian or poison control immediately if your pet has ingested something potentially toxic.
            """,
            category: .nutrition,
            species: [],
            readTimeMinutes: 7,
            mascot: .owl,
            isPremium: false,
            tags: ["toxic foods", "safety", "nutrition", "emergency"]
        ),

        BZCEducationalArticle(
            id: "nut-003",
            title: "Feeding Schedules for Every Life Stage",
            summary: "How feeding frequency and amounts change from puppy/kitten to senior.",
            content: """
            ## Life Stage Feeding Guide

            Nutritional needs change dramatically throughout a pet's life. Here's how to adapt feeding at every stage:

            ### Young Animals (0–6 months)
            - **Dogs & Cats:** 3–4 small meals per day
            - High protein and fat for growth; use life-stage appropriate food
            - Puppies: start introducing solid food at 3–4 weeks during weaning
            - Kittens: separate food from litter box (instinctual aversion)

            ### Adults (1–7 years for dogs, 1–10 years for cats)
            - **2 meals per day** is optimal — maintains blood sugar, prevents bloat in large dogs
            - Portion control is critical; obesity is the leading preventable disease in pets
            - Use feeding puzzles to slow eating and provide enrichment

            ### Seniors (7+ years for large dogs, 10+ years for cats)
            - Lower calorie density to account for reduced activity
            - Higher quality protein to maintain muscle mass
            - Joint-supporting ingredients (omega-3s, glucosamine)
            - Increased water intake through wet food

            ### Calculating Portions
            General guidelines per day:
            - **Dogs:** 2–3% of ideal body weight in food
            - **Cats:** 4–5% of ideal body weight
            - **Rabbits:** body-sized portion of hay daily + 1 cup greens per kg

            Always adjust for your individual animal's metabolism, activity level, and health status. Your veterinarian can provide precise recommendations.
            """,
            category: .nutrition,
            species: [],
            readTimeMinutes: 6,
            mascot: .fox,
            isPremium: false,
            tags: ["feeding", "life stage", "puppies", "kittens", "senior"]
        )
    ]

    // MARK: - Health

    static let healthArticles: [BZCEducationalArticle] = [
        BZCEducationalArticle(
            id: "hlt-001",
            title: "The Complete Vaccination Guide",
            summary: "Understanding core and non-core vaccines, schedules, and why they matter.",
            content: """
            ## Pet Vaccination Guide

            Vaccines are one of the most powerful tools in preventive medicine. They protect your pet from serious, often fatal diseases.

            ### Core Vaccines (Recommended for all pets)

            **Dogs:**
            - Canine distemper (CDV)
            - Canine parvovirus (CPV)
            - Canine adenovirus (CAV-2)
            - Rabies (legally required in most jurisdictions)

            **Cats:**
            - Feline herpesvirus (FHV-1)
            - Feline calicivirus (FCV)
            - Feline panleukopenia (FPV)
            - Rabies

            **Rabbits:**
            - Myxomatosis
            - Rabbit Hemorrhagic Disease (VHD1 & VHD2)

            ### Non-Core Vaccines (Based on lifestyle)
            - Leptospirosis (dogs who swim or have wildlife exposure)
            - Bordetella (dogs in boarding, daycare, or dog parks)
            - Feline leukemia (FeLV) for outdoor cats

            ### Puppy & Kitten Schedule
            - First vaccines: 6–8 weeks
            - Boosters every 3–4 weeks until 16 weeks
            - First adult booster: 1 year later
            - Then: every 1–3 years depending on vaccine type

            ### Important Notes
            - Keep vaccination records in Be Zoo Care for easy access
            - Vaccinate even indoor-only pets — diseases can enter on shoes and clothing
            - Mild post-vaccine reactions (sleepiness, soreness) are normal
            - Severe reactions (facial swelling, vomiting, collapse) need immediate vet attention
            """,
            category: .health,
            species: [.dog, .cat, .rabbit],
            readTimeMinutes: 8,
            mascot: .rhino,
            isPremium: false,
            tags: ["vaccines", "prevention", "health", "puppies", "kittens"]
        ),

        BZCEducationalArticle(
            id: "hlt-002",
            title: "Parasite Prevention: A Year-Round Priority",
            summary: "Fleas, ticks, heartworm, and intestinal parasites — how to protect your pet.",
            content: """
            ## Parasite Prevention Guide

            Parasites are not just uncomfortable — many transmit serious diseases to both pets and humans.

            ### Fleas
            A single female flea lays 40–50 eggs per day. One flea becomes an infestation within weeks.

            **Prevention:** Monthly topical or oral flea prevention year-round
            **Treat the environment:** 95% of the flea life cycle exists off the pet (eggs, larvae, pupae in carpets/furniture)

            **Natural flea prevention tips:**
            - Regular vacuuming (dispose of bag immediately)
            - Wash bedding weekly in hot water
            - Keep grass trimmed outdoors

            ### Ticks
            Ticks transmit Lyme disease, ehrlichiosis, anaplasmosis, and Rocky Mountain spotted fever.

            **Prevention:** Tick-prevention products applied monthly
            **After outdoor time:** Check entire body, including ears, between toes, under collar
            **Tick removal:** Use fine-tipped tweezers, grasp close to skin, pull straight up — do not twist

            ### Heartworm
            Transmitted by mosquitoes; potentially fatal if untreated.

            - Dogs: Test annually, prevent monthly year-round
            - Cats: No approved treatment — prevention is critical
            - Prevention: monthly oral or topical medication

            ### Intestinal Parasites
            Roundworms, hookworms, whipworms, tapeworms — many transmissible to humans.

            - Deworm puppies/kittens every 2 weeks from 2 to 12 weeks, then monthly to 6 months
            - Annual fecal exam for adult pets
            - Pick up feces promptly — parasite eggs survive in soil for years
            """,
            category: .preventiveCare,
            species: [.dog, .cat],
            readTimeMinutes: 7,
            mascot: .rhino,
            isPremium: false,
            tags: ["parasites", "fleas", "ticks", "heartworm", "prevention"]
        )
    ]

    // MARK: - Grooming

    static let groomingArticles: [BZCEducationalArticle] = [
        BZCEducationalArticle(
            id: "grm-001",
            title: "Nail Care Mastery: Stress-Free Trimming",
            summary: "Step-by-step technique for trimming nails safely at home, plus how to avoid the quick.",
            content: """
            ## Mastering Nail Care at Home

            Long nails cause discomfort, alter gait, and can lead to joint problems over time. Nail trimming every 2–4 weeks keeps your pet comfortable and healthy.

            ### Equipment
            - Guillotine or scissor-style clippers for dogs/cats
            - Small nail file for smoothing edges
            - Styptic powder (to stop bleeding if you cut the quick)

            ### Understanding the Quick
            The quick is the blood vessel inside the nail. Cutting it is painful and causes bleeding — but not dangerous.
            - **Light nails:** The quick appears as a pinkish area inside the nail
            - **Dark nails:** Trim 1–2mm at a time; the center will look chalky white when close to quick, then show a small dark circle when very close

            ### Step-by-Step Process

            1. **Desensitize first.** Touch paws daily from puppyhood/kittenhood. Reward generously.
            2. **Position comfortably.** Cradle small pets; have a helper for large dogs.
            3. **Start with one nail.** Clip the very tip at a 45° angle.
            4. **Look for the quick** before each cut.
            5. **Reward after every nail** — make it a positive experience.
            6. **Gradual sessions** are better than forcing it all at once.

            ### If You Cut the Quick
            - Apply styptic powder and gentle pressure for 30 seconds
            - Don't panic — your pet will sense your anxiety
            - Reassure with calm voice and treats

            **Pro tip:** A tired pet is a calmer patient. Try nail trims after exercise.
            """,
            category: .grooming,
            species: [.dog, .cat, .rabbit],
            readTimeMinutes: 6,
            mascot: .rhino,
            isPremium: false,
            tags: ["nails", "grooming", "trimming", "technique"]
        )
    ]

    // MARK: - Behavior

    static let behaviorArticles: [BZCEducationalArticle] = [
        BZCEducationalArticle(
            id: "bhv-001",
            title: "Reading Your Pet's Body Language",
            summary: "Decode what your animal is communicating through posture, ear position, tail movement, and more.",
            content: """
            ## Understanding Pet Body Language

            Animals communicate primarily through body language. Learning to read these signals deepens your bond and helps you respond appropriately to their needs.

            ### Dogs

            **Happy/Relaxed:**
            - Loose, wiggly body; relaxed mouth; soft eyes
            - Tail wagging at mid-height in broad sweeps

            **Anxious/Stressed:**
            - Yawning, lip-licking, panting without heat
            - Tail tucked; ears back; whale eye (showing whites of eyes)
            - Excessive shedding; shaking; refusing food

            **Fearful/Aggressive Warning:**
            - Stiffening; hard stare; raised hackles
            - Tail straight up or straight down and rigid
            - Growling — never punish growling (it's communication)

            ### Cats

            **Relaxed/Content:**
            - Slow blinking (a sign of trust — blink back slowly)
            - Loaf position or exposed belly (though belly touch often unwelcome)
            - Purring (usually contentment, but can signal pain too)

            **Stressed/Overstimulated:**
            - Tail lashing; skin rippling; dilated pupils
            - Ears flattening; whiskers back; hissing

            **Pain Signals (both species):**
            - Squinting or avoiding light
            - Hunched posture; reluctance to move
            - Vocalizing when touched in one area
            - Changes in elimination habits

            ### The Golden Rule
            When your pet communicates discomfort, listen. Forcing interaction past warning signals damages trust and increases bite risk. Give space and let your pet approach on their own terms.
            """,
            category: .behavior,
            species: [.dog, .cat],
            readTimeMinutes: 7,
            mascot: .panda,
            isPremium: false,
            tags: ["body language", "communication", "behavior", "stress"]
        )
    ]

    // MARK: - Training

    static let trainingArticles: [BZCEducationalArticle] = [
        BZCEducationalArticle(
            id: "trn-001",
            title: "Positive Reinforcement: The Science of Good Training",
            summary: "Why positive reinforcement works, how to time it perfectly, and the 5-step training protocol.",
            content: """
            ## The Science of Positive Reinforcement

            Positive reinforcement is the most humane and effective training method, backed by decades of behavioral science.

            ### How It Works
            When a behavior is followed by something the animal values (a reward), that behavior is more likely to occur again. This is operant conditioning — you're working with the animal's natural learning system.

            ### The Timing Rule
            The reward must come within **1–2 seconds** of the desired behavior. The animal's brain connects the reward to the most recent action. Delayed rewards reward the wrong behavior.

            **Solution: Use a marker signal**
            - A clicker (click = reward coming)
            - A verbal marker ("Yes!" in a bright tone)

            The marker bridges the gap between behavior and reward, allowing you to click precisely when the behavior occurs.

            ### The 5-Step Protocol

            1. **Lure:** Use a treat to guide the animal into position
            2. **Mark:** Click or say "Yes!" the instant the position is achieved
            3. **Reward:** Deliver the treat within 2 seconds
            4. **Repeat:** 5–10 repetitions per session
            5. **Add the cue:** Once the behavior is reliable (80% success), add the word/hand signal

            ### What to Avoid
            - Physical punishment — damages trust, causes fear, can increase aggression
            - Repeated commands — "Sit, sit, SIT" teaches the animal the third repetition means action
            - Pushing or forcing — creates negative associations with training
            - Long sessions — 5–10 minutes 2–3 times daily beats one hour-long session

            ### Shaping Complex Behaviors
            Break complex behaviors into small steps. Reward each step before moving forward. This is how dolphins learn to wave and dogs learn to roll over.
            """,
            category: .training,
            species: [.dog, .cat, .rabbit, .bird],
            readTimeMinutes: 8,
            mascot: .wolf,
            isPremium: false,
            tags: ["training", "positive reinforcement", "clicker", "behavior"]
        )
    ]

    // MARK: - Safety

    static let safetyArticles: [BZCEducationalArticle] = [
        BZCEducationalArticle(
            id: "saf-001",
            title: "Pet-Proofing Your Home",
            summary: "Room-by-room guide to identifying and eliminating hazards for your animals.",
            content: """
            ## Pet-Proofing Your Home

            Your home contains numerous hidden hazards. A thorough pet-proof is essential before bringing any animal home.

            ### Kitchen
            - Secure trash cans with locking lids
            - Store human foods out of reach (especially toxic ones)
            - Keep cleaning products in locked cabinets
            - Never leave stovetop burners unattended with a pet nearby
            - Secure dishwasher — detergent pods are highly toxic

            ### Living Room
            - Secure electrical cords (rabbits especially chew wires)
            - Remove small objects that could be swallowed
            - Secure houseplants (many are toxic: lilies fatal to cats, sago palm to dogs)
            - Ensure blinds cords can't entangle necks

            ### Bathroom
            - Keep toilet lids closed (drowning risk for small animals)
            - Store medications in locked cabinets
            - Non-stick toilet bowl cleaners are toxic
            - Keep razors and other sharp items secure

            ### Garage
            - Antifreeze has a sweet taste — extremely toxic; clean up spills immediately
            - Store chemicals and tools out of reach
            - Check under cars before moving — cats rest in wheel wells

            ### Plants to Remove
            **Toxic to cats:** All lilies (highly lethal), tulips, azalea, oleander, yew, cyclamen
            **Toxic to dogs:** Sago palm, yew, azalea, oleander, daffodil, grapes/raisin vines
            **Safe alternatives:** Spider plants, Boston ferns, Christmas cacti, areca palms
            """,
            category: .petSafety,
            species: [],
            readTimeMinutes: 7,
            mascot: .owl,
            isPremium: false,
            tags: ["safety", "pet-proofing", "hazards", "toxic plants"]
        )
    ]

    // MARK: - Senior Care

    static let seniorCareArticles: [BZCEducationalArticle] = [
        BZCEducationalArticle(
            id: "sen-001",
            title: "Caring for Senior Pets: The Complete Guide",
            summary: "How your approach to care should evolve as your pet enters their golden years.",
            content: """
            ## Caring for Your Senior Pet

            Senior pets are defined differently by species and size, but all benefit from adapted care strategies.

            **When is a pet "senior"?**
            - Small dogs (under 10kg): 10–12 years
            - Large dogs (over 25kg): 7–8 years
            - Cats: 10–12 years
            - Rabbits: 5–6 years (lifespan 8–12 years)

            ### Health Changes to Monitor
            - **Arthritis:** Stiffness after rest, reluctance to climb stairs, slowing on walks
            - **Dental disease:** Bad breath, difficulty eating, pawing at face
            - **Cognitive changes:** Confusion, changes in sleep patterns, vocalization at night
            - **Sensory decline:** Reduced hearing or vision; approach from front, don't startle
            - **Kidney/Liver disease:** Increased thirst, changes in urination
            - **Cancer:** Lumps, unexplained weight loss, decreased appetite

            ### Adapting Care
            - Vet visits: Every 6 months (not just annually)
            - Bloodwork panel: Annually to catch organ changes early
            - Diet: Switch to senior-formula food; increase omega-3s
            - Joint support: Ramps and steps for furniture; raised food bowls
            - Exercise: Shorter, more frequent walks; gentle play
            - Mental stimulation: Puzzle feeders, gentle training; prevents cognitive decline

            ### Quality of Life
            The goal shifts from maximizing lifespan to maximizing quality of life. Regular honest conversations with your vet about comfort, pain management, and quality of life ensure your senior pet's golden years are truly golden.
            """,
            category: .seniorCare,
            species: [.dog, .cat, .rabbit],
            readTimeMinutes: 8,
            mascot: .owl,
            isPremium: true,
            tags: ["senior", "aging", "arthritis", "geriatric care"]
        )
    ]

    // MARK: - Young Animals

    static let youngAnimalArticles: [BZCEducationalArticle] = [
        BZCEducationalArticle(
            id: "yng-001",
            title: "The Critical Socialization Window",
            summary: "Why 3–14 weeks is the most important period in your puppy or kitten's life.",
            content: """
            ## The Socialization Window

            The single most important thing you can do for a puppy or kitten's long-term behavior is proper early socialization.

            ### The Science
            Puppies have a critical socialization period from **3–14 weeks of age**. Kittens: **2–7 weeks**. During this window, the brain is uniquely primed to form positive associations with new experiences.

            Experiences during this window — whether positive or negative — have outsized, lasting effects on behavior.

            ### What to Socialize With
            **People:** Men, women, children, elderly people, people with hats/umbrellas/beards
            **Animals:** Other dogs of all sizes, cats, other species (safely)
            **Environments:** Cars, veterinary offices, different floor types, stairs
            **Sounds:** Traffic, thunder, vacuum cleaners, machinery
            **Handling:** Ears, paws, mouth, tail — simulating grooming and vet exams

            ### How to Socialize Safely
            - **Positive associations only** — pair every new experience with treats and praise
            - **Never force** — let the animal approach on their own terms
            - **Go at their pace** — signs of stress mean you've moved too fast
            - **Before vaccination completion** — use puppy classes, avoid dog parks/unknown dogs

            ### The Lasting Impact
            Research shows that dogs and cats not adequately socialized during this window are significantly more likely to develop fear-based aggression, anxiety disorders, and phobias that require professional behavior modification as adults.

            The time invested in those first 14 weeks pays dividends for 10–15 years.
            """,
            category: .youngAnimals,
            species: [.dog, .cat],
            readTimeMinutes: 7,
            mascot: .fox,
            isPremium: false,
            tags: ["puppies", "kittens", "socialization", "development", "behavior"]
        )
    ]
}
