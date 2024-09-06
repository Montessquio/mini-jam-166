extends CanvasLayer

@export var purchaseable_container: NodePath
@export var purchased_container: NodePath
@export var current_resources_container: NodePath

@export var charcoal_image: Resource
@export var oil_seed_image: Resource
@export var volatile_amber_image: Resource
@export var fuel_image: Resource
@export var damage_image: Resource
@export var defense_image: Resource
@export var speed_image: Resource
@export var tank_up_image: Resource
@export var health_image: Resource

@export var upgrade_prefab: Resource

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    clear_window()
    populate_window()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    var cr = get_node(current_resources_container)
    cr.get_node("CharcoalAmount").text = "%d" % player.resources["charcoal"]
    cr.get_node("OilSeedAmount").text = "%d" % player.resources["oil seed"]
    cr.get_node("VolatileAmberAmount").text = "%d" % player.resources["volatile amber"]

    if visible:
        if Input.is_action_pressed("escape"):
            player.exit_shop()

func redraw():
    clear_window()
    populate_window()

func clear_window():
    for node in get_node(purchased_container).get_children():
        node.queue_free()
    for node in get_node(purchaseable_container).get_children():
        node.queue_free()

func populate_window():
    $"Control/ScrollContainer/VBoxContainer/PurchasedLabel".visible = false
    for upgrade in player.upgrades.all():
        print("Upgrade: %s" % upgrade)
        var vsep = VSeparator.new()
        vsep.custom_minimum_size.x = 48

        if player.upgrades.is_purchased(upgrade):
            get_node(purchased_container).add_child(instance_upgrade(upgrade))
            get_node(purchased_container).add_child(vsep)
            continue

        if player.upgrades.has_prerequisites(upgrade):
            $"Control/ScrollContainer/VBoxContainer/PurchasedLabel".visible = true
            get_node(purchaseable_container).add_child(instance_upgrade(upgrade))
            get_node(purchaseable_container).add_child(vsep)

func instance_upgrade(upgrade_name: String) -> Panel:
    var pane = upgrade_prefab.instantiate()

    if player.upgrades.count(upgrade_name) == 0:
        pane.display_name = upgrade_name
    else:
        pane.display_name = "%s %d" % [upgrade_name, player.upgrades.count(upgrade_name)]

    pane.desc = "%s\n" % [player.upgrades.desc(upgrade_name)]
    pane.desc_addl = func(rtf: RichTextLabel):
        var benefits = player.upgrades.benefits(upgrade_name)
        for b in benefits:
            match b:
                "flamer_particle_birth_force_magnitude":
                    rtf.append_text("+%d%%" % [(benefits[b] - 1) * 100])
                    rtf.add_image(damage_image, 16, 24)
                "move_speed":
                    rtf.append_text("+%d%%" % [(benefits[b] - 1) * 100])
                    rtf.add_image(speed_image, 24, 24)
                "max_health":
                    rtf.append_text("+%d%%" % [(benefits[b] - 1) * 100])
                    rtf.add_image(defense_image, 24, 24)
                "max_fuel":
                    rtf.append_text("+%d%%" % [(benefits[b] - 1) * 100])
                    rtf.add_image(tank_up_image, 24, 24)
                "health_pad_regen_per_tick":
                    rtf.append_text("+%d%%" % [(benefits[b] - 1) * 100])
                    rtf.add_image(health_image, 24, 24)
                "fuel_regen_per_tick":
                    rtf.append_text("+%d%%" % [(benefits[b] - 1) * 100])
                    rtf.add_image(fuel_image, 24, 24)
                _:
                    pass
        return

    pane.cost = []
    var costs = player.upgrades.cost(upgrade_name)
    for res in costs.keys():
        match res:
            "charcoal":
                var label = Label.new()
                if player.resources.get("charcoal") < costs.get("charcoal"):
                    label.add_theme_color_override("font_color", Color.MEDIUM_VIOLET_RED)
                label.text = "%d" % costs.get(res)
                pane.cost.append(label)

                var sprite = TextureRect.new()
                sprite.texture = charcoal_image
                sprite.stretch_mode = TextureRect.StretchMode.STRETCH_SCALE
                sprite.expand_mode = TextureRect.ExpandMode.EXPAND_FIT_WIDTH_PROPORTIONAL
                pane.cost.append(sprite)
            "oil seed":
                var label = Label.new()
                if player.resources.get("oil seed") < costs.get("oil seed"):
                    label.add_theme_color_override("font_color", Color.MEDIUM_VIOLET_RED)
                label.text = "%d" % costs.get(res)
                pane.cost.append(label)

                var sprite = TextureRect.new()
                sprite.texture = oil_seed_image
                sprite.stretch_mode = TextureRect.StretchMode.STRETCH_SCALE
                sprite.expand_mode = TextureRect.ExpandMode.EXPAND_FIT_WIDTH_PROPORTIONAL
                pane.cost.append(sprite)
            "volatile amber":
                var label = Label.new()
                if player.resources.get("volatile amber") < costs.get("volatile amber"):
                    label.add_theme_color_override("font_color", Color.MEDIUM_VIOLET_RED)
                label.text = "%d" % costs.get(res)
                pane.cost.append(label)

                var sprite = TextureRect.new()
                sprite.texture = charcoal_image
                sprite.stretch_mode = TextureRect.StretchMode.STRETCH_SCALE
                sprite.expand_mode = TextureRect.ExpandMode.EXPAND_FIT_WIDTH_PROPORTIONAL
                pane.cost.append(sprite)
            _:
                pass

    pane.on_click_buy = func():
        print("CLICKBUY %s" % upgrade_name)
        if player.upgrades.can_buy(upgrade_name, player.resources):
            var _this_costs = player.upgrades.cost(upgrade_name)
            for res in _this_costs:
                player.resources[res] -= _this_costs[res]
            apply_to_player(player.upgrades.benefits(upgrade_name))
            player.upgrades.mark_purchased(upgrade_name)
            redraw()
    return pane

func apply_to_player(effects: Dictionary):
    for e in effects:
        var v = effects[e]
        match e:
            "flamer_particle_birth_force_magnitude":
                player.flamer_particle_birth_force_magnitude *= v
            "flamer_particle_spread_range":
                player.flamer_particle_spread_range *= v
            "flamer_particle_enflame_tick_damage":
                player.flamer_particle_enflame_tick_damage *= v
            "move_speed":
                player.move_speed *= v
            "max_health":
                player.max_health *= v
            "max_fuel":
                player.max_fuel *= v
            "health_pad_regen_per_tick":
                player.health_pad_regen_per_tick *= v
            "fuel_regen_per_tick":
                player.fuel_regen_per_tick *= v


func _on_exit_button_pressed() -> void:
    player.exit_shop()
