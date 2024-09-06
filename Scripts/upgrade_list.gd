class_name PlayerUpgrades

var __upgrades = {
    "Reinforced Nozzle": {
        "purchased": false,
        "count": 0,
        "desc": "Stronger nozzle allows flames to fly further, and longer.",
        "benefit": {
            "flamer_particle_birth_force_magnitude": 1.2,
            "flamer_particle_spread_range": 0.05,
            "flamer_particle_enflame_tick_damage": 1.2,
        },
        "cost": {
            "charcoal": 2
        },
    },

    "New Boots": {
        "purchased": false,
        "count": 0,
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
        "count": 0,
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
        "count": 0,
        "desc": "Increase fuel reserves.",
        "benefit": {
            "max_fuel": 1.6
        },
        "cost": {
            "charcoal": 5,
        }
    },

    "Faster Medichines": {
        "purchased": false,
        "count": 0,
        "desc": "Better transport methods optimize morphine delivery.",
        "benefit": {
            "health_pad_regen_per_tick": 2,
        },
        "cost": {
            "charcoal": 8,
            "oil seed": 1,
        }
    },

    "Pump Aggregation": {
        "purchased": false,
        "count": 0,
        "desc": "Unified pipelines increase rate of fuel delivery.",
        "benefit": {
            "fuel_regen_per_tick": 2,
        },
        "cost": {
            "charcoal": 8,
            "oil seed": 1,
        }
    }
}

func all() -> Array:
    return __upgrades.keys()

func is_purchased(name: String) -> bool:
    var u = __upgrades.get(name)
    if u and u.get("purchased"):
        return u.get("purchased")
    return false

func has_prerequisites(name: String) -> bool:
    var u = __upgrades.get(name)
    if u and u.get("prerequisites"):
        var has_prereqs = true
        for prereq in u.get("prerequisites"):
            if not is_purchased(prereq):
                has_prereqs = false
            print("    Pre: %s=%s" % [prereq, is_purchased(prereq)])
        return has_prereqs
    return true

func cost(name: String) -> Dictionary:
    var costings = __upgrades.get(name).get("cost")
    var ret_costs = {}
    for key in costings:
        ret_costs[key] = clamp(costings[key] + clamp(count(name) - 1, 0, 99), 0, 99)
    return ret_costs

func benefits(name: String) -> Dictionary:
    var u = __upgrades.get(name)
    return u.get("benefit", {})

func desc(name: String) -> String:
    var u = __upgrades.get(name)
    return u.get("desc", "")

func count(name: String) -> int:
    var u = __upgrades.get(name)
    return u.get("count", 0)

func can_buy(name: String, resources: Dictionary) -> bool:
    var costs = cost(name)
    var has_funds = true
    for key in costs.keys():
        var wants = costs.get(key)
        var has = resources.get(key, 0)

        print("    %s - Has: %s Wants: %s" % [key, has, wants])

        if wants > has:
            has_funds = false
    return has_funds

func mark_purchased(name: String):
    var u = __upgrades.get(name)
    u["count"] += 1
    if u["count"] >= 10:
        u["purchased"] = true