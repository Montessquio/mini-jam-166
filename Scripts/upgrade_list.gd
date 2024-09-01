class_name PlayerUpgrades

var __upgrades = {
    "Reinforced Nozzle": {
        "purchased": false,
        "desc": "Stronger nozzle allows flames to fly further, and longer.",
        "benefit": {
            "flamer_particle_birth_force_magnitude": 1.2,
        },
        "cost": {
            "charcoal": 2
        },
    },

    "New Boots": {
        "purchased": false,
        "desc": "Ruggedized all-terrain boots allow for faster running.",
        "benefit": {
            "move_speed": 1.2
        },
        "cost": {
            "charcoal": 5,
        }
    },

    "Double-Rubber Suit": {
        "purchased": false,
        "desc": "Double up on suit thickness to increase durability.",
        "benefit": {
            "max_health": 1.2
        },
        "cost": {
            "charcoal": 5,
        }
    },

    "Expanded Tanks": {
        "purchased": false,
        "desc": "Increase fuel reserves.",
        "benefit": {
            "max_fuel": 1.6
        },
        "cost": {
            "charcoal": 5
        }
    },

    "Faster Medichines": {
        "purchased": false,
        "desc": "Better transport methods optimize morphine delivery.",
        "benefit": {
            "health_pad_regen_per_tick": 2,
        },
        "cost": {
            "charcoal": 8
        }
    },

    "Pump Aggregation": {
        "purchased": false,
        "desc": "Unified pipelines increase rate of fuel delivery.",
        "benefit": {
            "fuel_regen_per_tick": 2,
        },
        "cost": {
            "charcoal": 8,
        }
    }
}
