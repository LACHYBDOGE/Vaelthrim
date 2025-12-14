class_name EventBusClass
extends Node

## Global signal bus for decoupled communication between systems.
## All cross-system events should be emitted through here.

# Player signals
signal player_spawned(player_id: String)
signal player_died(player_id: String)
signal player_respawned(player_id: String)

# Quest signals
signal quest_started(quest_id: String)
signal quest_updated(quest_id: String, stage_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)

# World signals
signal world_event(event_type: String, data: Dictionary)
signal area_entered(area_id: String, player_id: String)
signal area_exited(area_id: String, player_id: String)

# Combat signals
signal combat_started(combatants: Array)
signal combat_ended(result: Dictionary)
signal entity_damaged(entity_id: String, damage: int, source_id: String)
signal entity_died(entity_id: String, killer_id: String)

# Dialogue signals
signal dialogue_started(npc_id: String)
signal dialogue_ended(npc_id: String)
signal dialogue_choice_made(npc_id: String, choice_id: String)

# Economy signals
signal currency_changed(player_id: String, amount: int, new_total: int)
signal item_acquired(player_id: String, item_id: String, quantity: int)
signal item_removed(player_id: String, item_id: String, quantity: int)

# Magic signals
signal spell_cast(caster_id: String, spell_id: String, target: Variant)
signal tradition_learned(player_id: String, tradition_id: String)
signal spell_learned(player_id: String, spell_id: String)

# Time signals
signal time_changed(world_time: float)
signal day_started(day: int)
signal night_started(day: int)

# Save/Load signals
signal save_requested(slot: String)
signal load_requested(slot: String)
signal save_completed(slot: String, success: bool)
signal load_completed(slot: String, success: bool)
