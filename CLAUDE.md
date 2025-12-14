# LIVING UNIVERSE — Project Overview for Claude Code

> **Read this entire document before making architectural decisions.**
> This file defines the project vision, technical architecture, and conventions.
> When in doubt, refer back to this document.

-----

## TABLE OF CONTENTS

1. [Project Vision](#project-vision)
1. [Technical Architecture](#technical-architecture)
1. [File Structure](#file-structure)
1. [Coding Conventions](#coding-conventions)
1. [Core Systems Architecture](#core-systems-architecture)
1. [The Twelve Ecosystems](#the-twelve-ecosystems)
1. [Magic System](#magic-system)
1. [Data Formats](#data-formats)
1. [Future-Proofing Guidelines](#future-proofing-guidelines)
1. [What Not To Change](#what-not-to-change)

-----

## PROJECT VISION

### The Game

**Living Universe** is an open-world RPG where players awaken in a pod on a random planet within a galaxy of twelve distinct ecosystems. The universe operates continuously — creatures live, civilizations trade, and events unfold whether players are present or not.

### Core Pillars

1. **Living Simulation**: Neural network-driven creatures (100-200 per ecosystem) with emergent behavior
1. **Interconnected Systems**: Magic, economy, society, and technology interact across civilizations
1. **Player Agency**: Actions have lasting consequences on the persistent world
1. **Emergent Narrative**: Stories emerge from system interactions, not scripted sequences
1. **The Fifth Path**: Ultimate goal — transcend biological limits through mastering all twelve magic traditions

### Visual Style

**3D Pixel Art** — Full 3D environments and movement with a pixelated post-processing aesthetic (reference: Octopath Traveler's HD-2D, but with complete 3D freedom). This is achieved through:

- Standard 3D rendering pipeline
- Post-processing pixelation shader
- Limited color palette (optional, per-biome)
- Subtle edge detection/outlines

### Starting Point

Development begins with **Vaelthrim** — a medieval fantasy world where all twelve magic traditions exist but space travel hasn't been achieved. This serves as:

- Tutorial/awakening area for new players
- Testing ground for magic system interactions
- Proof of concept before scaling to interstellar scope

-----

## TECHNICAL ARCHITECTURE

### Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    SIMULATION SERVER (Future)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ Creature AI  │  │ World State  │  │ LLM Dialogue Service │   │
│  │   (Rust)     │  │ (PostgreSQL) │  │      (Python)        │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │ API (WebSocket/gRPC)
                             │
┌────────────────────────────┴────────────────────────────────────┐
│                      GODOT 4 CLIENT                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │   Rendering  │  │  Game Logic  │  │  Network Sync Layer  │   │
│  │   (Local)    │  │   (Local)    │  │  (Abstracted Now)    │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Current Phase: Local Client

For now, everything runs locally in Godot. However, **all systems must be designed with eventual server extraction in mind**:

- Game logic should be separable from rendering
- State should be serializable
- Network sync layer should be abstracted (local calls now, API calls later)
- AI decisions should be deterministic given same inputs

### Engine: Godot 4.x

- Language: **GDScript** (primary), C# acceptable for performance-critical systems
- Rendering: Forward+ renderer with custom post-processing
- Physics: Godot's built-in (adequate for our needs)

### Future Server Stack (Do Not Implement Yet)

- Simulation: Rust (performance, safety)
- Database: PostgreSQL (world state persistence)
- LLM Integration: Python service (dialogue, NPC reasoning)
- Protocol: gRPC or WebSocket

-----

## FILE STRUCTURE

```
living-universe/
├── CLAUDE.md                    # THIS FILE - Do not modify structure
├── project.godot                # Godot project file
│
├── /autoload/                   # Singleton scripts (loaded globally)
│   ├── game_manager.gd          # Overall game state, scene transitions
│   ├── save_manager.gd          # Save/load system
│   ├── event_bus.gd             # Global signal bus for decoupled communication
│   ├── audio_manager.gd         # Sound and music control
│   ├── dialogue_manager.gd      # Dialogue system controller
│   └── world_state.gd           # Persistent world data (server-ready)
│
├── /scenes/                     # All .tscn scene files
│   ├── /player/
│   │   ├── player.tscn          # Main player scene
│   │   └── player_ui.tscn       # Player HUD
│   │
│   ├── /characters/             # NPCs, enemies, creatures
│   │   ├── /npcs/
│   │   ├── /enemies/
│   │   └── /creatures/          # Neural network creatures (future)
│   │
│   ├── /environments/
│   │   ├── /vaelthrim/          # Medieval starting world
│   │   │   ├── /settlements/
│   │   │   │   ├── thornwick/   # First village
│   │   │   │   └── .../
│   │   │   ├── /wilderness/
│   │   │   └── /dungeons/
│   │   │
│   │   ├── /scorched_expanse/   # Future: Desert ecosystem
│   │   ├── /symbiotic_garden/   # Future: Bio-tech ecosystem
│   │   ├── /eternal_lattice/    # Future: City-planet ecosystem
│   │   └── .../                 # Other ecosystems
│   │
│   ├── /ui/
│   │   ├── main_menu.tscn
│   │   ├── pause_menu.tscn
│   │   ├── inventory_ui.tscn
│   │   ├── dialogue_ui.tscn
│   │   └── magic_ui.tscn
│   │
│   └── /effects/                # VFX scenes (particles, etc.)
│       ├── /magic/
│       └── /environmental/
│
├── /scripts/                    # All .gd script files
│   ├── /player/
│   │   ├── player_controller.gd
│   │   ├── player_state_machine.gd
│   │   ├── player_stats.gd
│   │   └── player_magic.gd
│   │
│   ├── /entities/               # Base classes for game entities
│   │   ├── entity_base.gd       # Root class for all entities
│   │   ├── character_base.gd    # Humanoid characters
│   │   ├── creature_base.gd     # Animals, monsters
│   │   └── npc_base.gd          # NPCs with dialogue
│   │
│   ├── /ai/
│   │   ├── state_machine.gd     # Generic state machine
│   │   ├── behavior_tree.gd     # Behavior tree implementation
│   │   ├── /states/             # Reusable AI states
│   │   └── /behaviors/          # Behavior tree nodes
│   │
│   ├── /systems/                # Core game systems
│   │   ├── /magic/
│   │   │   ├── magic_system.gd
│   │   │   ├── tradition_base.gd
│   │   │   └── spell_base.gd
│   │   ├── /combat/
│   │   │   ├── combat_system.gd
│   │   │   ├── damage_calculator.gd
│   │   │   └── hitbox_manager.gd
│   │   ├── /dialogue/
│   │   │   ├── dialogue_parser.gd
│   │   │   └── dialogue_conditions.gd
│   │   ├── /inventory/
│   │   │   ├── inventory_system.gd
│   │   │   └── item_base.gd
│   │   ├── /economy/            # Trade, currency systems
│   │   ├── /crafting/
│   │   └── /world/
│   │       ├── time_system.gd
│   │       ├── weather_system.gd
│   │       └── chunk_loader.gd
│   │
│   ├── /ui/                     # UI-specific scripts
│   │
│   └── /utils/                  # Utility scripts
│       ├── constants.gd
│       ├── enums.gd
│       └── helpers.gd
│
├── /resources/                  # Godot Resource files (.tres)
│   ├── /characters/
│   │   ├── player_stats_default.tres
│   │   └── /npc_profiles/
│   │
│   ├── /magic/
│   │   ├── /traditions/         # One .tres per tradition
│   │   │   ├── prescience.tres
│   │   │   ├── flesh_shaping.tres
│   │   │   ├── techno_arcana.tres
│   │   │   ├── void_walking.tres
│   │   │   ├── pressure_song.tres
│   │   │   ├── spore_communion.tres
│   │   │   ├── harmonic_weaving.tres
│   │   │   ├── forge_binding.tres
│   │   │   ├── cryo_stasis.tres
│   │   │   ├── growth_speaking.tres
│   │   │   ├── duality_mastery.tres
│   │   │   └── lift_singing.tres
│   │   │
│   │   └── /spells/             # Individual spell definitions
│   │
│   ├── /items/
│   │   ├── /weapons/
│   │   ├── /armor/
│   │   ├── /consumables/
│   │   └── /materials/
│   │
│   ├── /ecosystems/             # Ecosystem configuration data
│   │   └── ecosystem_data.tres  # Contains all 12 ecosystem definitions
│   │
│   └── /loot_tables/
│
├── /assets/                     # Non-Godot-resource assets
│   ├── /models/
│   │   ├── /characters/
│   │   ├── /props/
│   │   ├── /buildings/
│   │   └── /creatures/
│   │
│   ├── /textures/
│   │   ├── /terrain/
│   │   ├── /characters/
│   │   ├── /props/
│   │   └── /ui/
│   │
│   ├── /shaders/
│   │   ├── pixel_art_post.gdshader    # Main visual style shader
│   │   ├── terrain_blend.gdshader
│   │   └── /magic_effects/
│   │
│   ├── /audio/
│   │   ├── /music/
│   │   ├── /sfx/
│   │   └── /ambience/
│   │
│   └── /fonts/
│
├── /data/                       # External data files (JSON, etc.)
│   ├── /dialogue/
│   │   ├── /vaelthrim/
│   │   │   ├── /thornwick/
│   │   │   │   ├── mira_tavern_keeper.json
│   │   │   │   ├── garrett_blacksmith.json
│   │   │   │   └── elder_voss.json
│   │   │   └── .../
│   │   └── .../
│   │
│   ├── /quests/
│   │   └── /vaelthrim/
│   │
│   ├── /lore/                   # Lore database for NPC knowledge
│   │   ├── history.json
│   │   ├── factions.json
│   │   └── /ecosystems/
│   │
│   └── /localization/
│       ├── en.json
│       └── .../
│
├── /addons/                     # Godot plugins
│   └── /world_editor/           # Custom world-building tools (future)
│
└── /docs/                       # Design documents
    ├── GDD.md                   # Game Design Document
    ├── appendix_a_ecosystems.md
    ├── appendix_b_civilizations.md
    ├── appendix_c_magic.md
    └── appendix_d_interactions.md
```

### Structure Rules

1. **Scenes and scripts are separated** — Scripts in `/scripts/`, scenes in `/scenes/`
1. **One script per file** — No multiple classes per file
1. **Resources are data** — Use `.tres` for data that designers might tweak
1. **External data is JSON** — Dialogue, quests, lore stored as JSON for easy editing and future server sync
1. **Ecosystems are modular** — Each ecosystem is a self-contained folder; adding new ones shouldn't touch core systems

-----

## CODING CONVENTIONS

### GDScript Style

```gdscript
class_name ExampleClass
extends Node

## Documentation comment for the class
## Explains what this class does

# Constants at top
const MAX_HEALTH := 100
const DAMAGE_TYPES := {
    "physical": 0,
    "fire": 1,
    "frost": 2,
    "nature": 3,
    "temporal": 4,
    "void": 5,
}

# Signals after constants
signal health_changed(new_health: int, max_health: int)
signal died

# Exported variables (visible in inspector)
@export var base_health: int = 100
@export var damage_resistance: Dictionary = {}

# Public variables
var current_health: int

# Private variables (prefix with underscore)
var _internal_state: int = 0

# Onready variables
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
    current_health = base_health


func _process(delta: float) -> void:
    _update_internal_state(delta)


# Public methods - no underscore prefix
func take_damage(amount: int, type: String) -> void:
    var resistance := damage_resistance.get(type, 0.0)
    var final_damage := int(amount * (1.0 - resistance))

    current_health = max(0, current_health - final_damage)
    health_changed.emit(current_health, base_health)

    if current_health <= 0:
        _die()


func heal(amount: int) -> void:
    current_health = min(base_health, current_health + amount)
    health_changed.emit(current_health, base_health)


# Private methods - underscore prefix
func _die() -> void:
    died.emit()
    queue_free()


func _update_internal_state(delta: float) -> void:
    pass
```

### Naming Conventions

|Type     |Convention                |Example                 |
|---------|--------------------------|------------------------|
|Files    |snake_case                |`player_controller.gd`  |
|Classes  |PascalCase                |`PlayerController`      |
|Functions|snake_case                |`take_damage()`         |
|Variables|snake_case                |`current_health`        |
|Constants|SCREAMING_SNAKE           |`MAX_HEALTH`            |
|Signals  |snake_case (past tense)   |`health_changed`, `died`|
|Private  |_underscore_prefix        |`_internal_state`       |
|Enums    |PascalCase.SCREAMING_SNAKE|`DamageType.FIRE`       |

### Signal-Based Communication

Use signals for decoupled communication. The EventBus autoload provides global signals:

```gdscript
# In event_bus.gd
signal player_died
signal quest_completed(quest_id: String)
signal world_event(event_type: String, data: Dictionary)

# Emitting from anywhere
EventBus.player_died.emit()

# Listening from anywhere
EventBus.player_died.connect(_on_player_died)
```

### State Machines

All complex entities use state machines:

```gdscript
# state_machine.gd pattern
var current_state: State
var states: Dictionary = {}

func change_state(new_state_name: String, data: Dictionary = {}) -> void:
    if current_state:
        current_state.exit()
    current_state = states[new_state_name]
    current_state.enter(data)
```

-----

## CORE SYSTEMS ARCHITECTURE

### Entity Hierarchy

```
entity_base.gd (Node3D)
    ├── character_base.gd
    │   ├── player (scene)
    │   ├── npc_base.gd
    │   │   └── specific NPCs
    │   └── enemy_base.gd
    │       └── specific enemies
    │
    └── creature_base.gd
        └── specific creatures (neural network driven)
```

### Magic System Architecture

```
MagicSystem (autoload)
    │
    ├── Traditions (Resource[])
    │   ├── TraditionResource
    │   │   ├── tradition_id: String
    │   │   ├── tradition_name: String
    │   │   ├── casting_method: CastingMethod
    │   │   ├── environmental_requirements: Dictionary
    │   │   ├── skill_tree: SkillTreeResource
    │   │   └── spells: SpellResource[]
    │   │
    │   └── SpellResource
    │       ├── spell_id: String
    │       ├── spell_name: String
    │       ├── tradition: String (reference)
    │       ├── tier: int (1-5)
    │       ├── cost: Dictionary {energy, materials, etc.}
    │       ├── cast_time: float
    │       ├── cooldown: float
    │       ├── effect_script: Script (the actual behavior)
    │       └── vfx_scene: PackedScene
    │
    └── PlayerMagicState
        ├── known_traditions: Dictionary {tradition_id: skill_level}
        ├── known_spells: String[]
        ├── current_energy: float
        ├── max_energy: float
        ├── active_effects: Effect[]
        └── cooldowns: Dictionary {spell_id: time_remaining}
```

### Tradition Interaction Matrix

Stored in `/resources/magic/tradition_interactions.tres`:

```gdscript
# Structure for magic tradition interactions
@export var interactions: Dictionary = {
    "prescience+void_walking": {
        "compatibility": "synergistic",
        "effect": "prescient_navigation",
        "description": "Navigate space and time simultaneously"
    },
    "flesh_shaping+forge_binding": {
        "compatibility": "opposing",
        "effect": "fire_flesh",
        "description": "Life vs fire - but fire-resistant organisms possible"
    },
    # ... all 66 combinations (12 choose 2)
}
```

### World State System

Designed for eventual server sync:

```gdscript
# world_state.gd
class_name WorldState
extends Node

# All world state that needs to persist/sync
var world_time: float = 0.0
var weather_state: Dictionary = {}
var npc_states: Dictionary = {}  # {npc_id: NPCState}
var creature_states: Dictionary = {}  # {creature_id: CreatureState}
var player_states: Dictionary = {}  # {player_id: PlayerState} - multiplayer ready
var world_events: Array = []  # Events that have occurred
var ecosystem_states: Dictionary = {}  # Per-ecosystem global state

# Serialization for save/load and network sync
func serialize() -> Dictionary:
    return {
        "world_time": world_time,
        "weather_state": weather_state,
        "npc_states": _serialize_npc_states(),
        # ...
    }

func deserialize(data: Dictionary) -> void:
    world_time = data.get("world_time", 0.0)
    # ...

# Called by local systems now, by server later
func update_npc_state(npc_id: String, state: Dictionary) -> void:
    npc_states[npc_id] = state
    # Future: send to server instead of storing locally
```

-----

## THE TWELVE ECOSYSTEMS

Each ecosystem has five interconnected elements. This is the canonical reference.

### 1. Scorched Expanse

- **Magic**: Prescience (temporal perception via Temporal Amber)
- **Economy**: Amber Monopoly Feudalism
- **Society**: Noble Houses & Tribal Confederations
- **Technology**: Bio-Symbiotic Minimalism (Leviathan bonding)
- **Core Resource**: Temporal Amber

### 2. Symbiotic Garden

- **Magic**: Flesh-Shaping (biological manipulation)
- **Economy**: Gift-Symbiosis (no currency)
- **Society**: Synthesis Nodes (spectrum of merged consciousness)
- **Technology**: Living Machines (grown, not built)
- **Core Resource**: Genetic Diversity

### 3. Eternal Lattice

- **Magic**: Techno-Arcana (ancient system activation)
- **Economy**: Corporate Capitalism
- **Society**: Stratified Urbanism (vertical city-planet)
- **Technology**: Ancient Automation (excavated, not invented)
- **Core Resource**: Access Codes

### 4. Void Born

- **Magic**: Void-Walking (spatial perception/folding)
- **Economy**: Trade Network Mercantilism
- **Society**: Clan-Ships
- **Technology**: Modular Mechanical (repairable, standardized)
- **Core Resource**: Salvage & Routes

### 5. Abyssal Deep

- **Magic**: Pressure-Song (sonic force manipulation)
- **Economy**: Harmonic Resonance (no currency)
- **Society**: Choral Collectives (distributed consciousness)
- **Technology**: Pressure-Rated Bio-Mechanical
- **Core Resource**: Resonance Crystals

### 6. Mycorrhizal Web

- **Magic**: Spore-Communion (network consciousness)
- **Economy**: Information Commons
- **Society**: Networked Consensus
- **Technology**: Organic Computing (the Web itself)
- **Core Resource**: Network Access

### 7. Resonant Spires

- **Magic**: Harmonic-Weaving (true names as frequencies)
- **Economy**: Artisan Guilds
- **Society**: Meritocratic Guilds
- **Technology**: Sonic Crystalline
- **Core Resource**: True Names

### 8. Molten Crucible

- **Magic**: Forge-Binding (transmutation, thermal control)
- **Economy**: Industrial Production
- **Society**: Forge-Clans
- **Technology**: Heat-Based Manufacturing
- **Core Resource**: Rare Metals & Thermal Access

### 9. Frozen Veil

- **Magic**: Cryo-Stasis (preservation, time slowing)
- **Economy**: Preservation Economy
- **Society**: Archival Culture
- **Technology**: Cryogenic Systems (superconducting)
- **Core Resource**: Preserved Knowledge

### 10. Verdant Maelstrom

- **Magic**: Growth-Speaking (vitality, directed evolution)
- **Economy**: Abundance Post-Scarcity
- **Society**: Gardener Councils
- **Technology**: Living Architecture
- **Core Resource**: Vitality

### 11. Threshold Zone

- **Magic**: Duality-Mastery (paradox, contradictory states)
- **Economy**: Arbitrage Capitalism
- **Society**: Philosophical Technocracy
- **Technology**: Dual-State Engineering
- **Core Resource**: Extreme Boundaries

### 12. Drifting Archipelago

- **Magic**: Lift-Singing (gravity manipulation via music)
- **Economy**: Transit & Trade
- **Society**: Navigator Clans
- **Technology**: Atmospheric Engineering
- **Core Resource**: Buoyant Materials

### Vaelthrim (Starting World)

Medieval fantasy world where **all twelve traditions exist** but space travel hasn't developed. Contains seven intelligent species:

1. **Ael'thir** (Elves) — Life magic, temporal magic, pursuing Ascension
1. **Dhurgan** (Dwarves) — Forge-Binding, Harmonic-Weaving
1. **Humans** — Moderate in all, exceptional in none
1. **Veth'kai** (Beastfolk) — Flesh-Shaping, Growth-Speaking
1. **Syl'vani** (Fae) — Void-Walking, Duality-Mastery
1. **Korvathi** (Dragon-kin) — Forge-Binding, Prescience
1. **Thal'mori** (Deep Ones) — Pressure-Song, Cryo-Stasis

-----

## MAGIC SYSTEM

### Compatibility Spectrum

When traditions interact:

|Rating           |Effect                                  |
|-----------------|----------------------------------------|
|Synergistic (+++)|Combined effects exceed sum of parts    |
|Compatible (++)  |Work well together, minor enhancement   |
|Neutral (+)      |Operate independently                   |
|Challenging (-)  |Extra effort required to combine        |
|Opposing (–)     |One must be suppressed for other to work|
|Paradoxical (—)  |Unstable but potentially powerful       |

### Key Synergistic Combinations (+++)

- Prescience + Void-Walking = Prescient Navigation
- Prescience + Techno-Arcana = Temporal Authentication
- Prescience + Cryo-Stasis = Frozen Prophecy
- Flesh-Shaping + Growth-Speaking = Complete Biogenesis
- Flesh-Shaping + Pressure-Song = Resonant Biology
- Flesh-Shaping + Spore-Communion = Network Cultivation
- Techno-Arcana + Spore-Communion = **Mycosynth** (Web + Ancient Tech)
- Techno-Arcana + Forge-Binding = Ancient Forging
- Void-Walking + Cryo-Stasis = Void-Stasis
- Void-Walking + Duality-Mastery = Boundary Navigation
- Pressure-Song + Harmonic-Weaving = Complete Sonic Mastery
- Pressure-Song + Lift-Singing = Complete Atmospheric Mastery
- Harmonic-Weaving + Forge-Binding = Complete Material Mastery
- Forge-Binding + Duality-Mastery = True Transmutation

### Key Opposing Combinations (–)

- Flesh-Shaping + Forge-Binding (life vs fire)
- Forge-Binding + Cryo-Stasis (fire vs ice)
- Void-Walking + Growth-Speaking (vacuum vs life)

### The Fifth Path

Ultimate achievement: mastering all twelve traditions to achieve Ascension (survive vacuum, travel between stars without ships). Requires the Seven Transformations — each a major quest line.

-----

## DATA FORMATS

### Dialogue JSON Structure

```json
{
    "npc_id": "mira_tavern_keeper",
    "npc_name": "Mira",
    "location": "thornwick_tavern",
    "personality": {
        "traits": ["friendly", "curious", "gossip"],
        "speech_style": "warm, uses colloquialisms",
        "knowledge_domains": ["local_news", "travelers", "village_history"]
    },
    "conversations": {
        "greeting": {
            "conditions": [],
            "lines": [
                {
                    "speaker": "npc",
                    "text": "Well now, a new face! Don't get many strangers in Thornwick."
                }
            ],
            "choices": [
                {
                    "text": "I'm just passing through.",
                    "next": "passing_through"
                },
                {
                    "text": "What can you tell me about this place?",
                    "next": "about_village"
                }
            ]
        }
    },
    "llm_context": {
        "backstory": "Mira inherited the tavern from her mother...",
        "current_concerns": "Worried about missing travelers on north road",
        "secrets": ["Knows about the old ruins but won't speak of them openly"]
    }
}
```

### Quest JSON Structure

```json
{
    "quest_id": "thornwick_missing_travelers",
    "title": "The Silent Road",
    "description": "Travelers have gone missing on the north road...",
    "quest_giver": "elder_voss",
    "stages": [
        {
            "stage_id": "investigate",
            "objectives": [
                {
                    "type": "talk_to",
                    "target": "mira_tavern_keeper",
                    "topic": "missing_travelers"
                },
                {
                    "type": "go_to",
                    "location": "north_road_crossroads"
                }
            ],
            "on_complete": "next_stage"
        }
    ],
    "rewards": {
        "experience": 100,
        "gold": 50,
        "reputation": {"thornwick": 10}
    },
    "world_effects": [
        {
            "type": "unlock_area",
            "target": "old_ruins"
        }
    ]
}
```

### Spell Resource Structure

```gdscript
# spell_resource.gd
class_name SpellResource
extends Resource

@export var spell_id: String
@export var spell_name: String
@export var tradition: String
@export var tier: int = 1
@export var description: String

@export_group("Costs")
@export var energy_cost: float = 10.0
@export var material_costs: Dictionary = {}
@export var health_cost: float = 0.0

@export_group("Timing")
@export var cast_time: float = 0.5
@export var cooldown: float = 1.0
@export var duration: float = 0.0  # 0 = instant

@export_group("Requirements")
@export var skill_requirement: int = 0
@export var environmental_requirements: Dictionary = {}

@export_group("Effect")
@export var effect_script: Script
@export var vfx_scene: PackedScene
@export var sfx: AudioStream

@export_group("Targeting")
@export var targeting_type: String = "self"  # self, target, area, direction
@export var range: float = 0.0
@export var area_of_effect: float = 0.0
```

-----

## FUTURE-PROOFING GUIDELINES

### Do This Now

1. **Abstract network calls** — All state changes go through WorldState, even locally
1. **Serialize everything** — If it matters, it should have `serialize()`/`deserialize()`
1. **Use IDs, not references** — NPCs reference quest_ids, not Quest objects
1. **Decouple with signals** — Systems communicate through EventBus
1. **Data-driven content** — Spells, items, dialogue as Resources/JSON, not hardcoded
1. **Deterministic logic** — Given same inputs, AI makes same decisions (for server replay)

### Don't Do This

1. **Don't couple rendering to logic** — Game logic shouldn't know about AnimationPlayer
1. **Don't hardcode content** — No spell effects embedded in player script
1. **Don't use global state carelessly** — If it's global, it's in an autoload
1. **Don't assume single player** — Use player_id even when there's only one
1. **Don't block on I/O** — Async for any file/network operations

### Server Extraction Checklist (Future)

When moving to client-server:

- [ ] WorldState becomes server API calls
- [ ] Creature AI runs server-side
- [ ] Client receives state updates, interpolates
- [ ] Dialogue queries go to LLM service
- [ ] Save/load becomes authentication + cloud saves

-----

## WHAT NOT TO CHANGE

These decisions are **locked** unless explicitly revisited:

### Visual Style

- 3D pixel art through post-processing shader
- NOT pre-rendered sprites
- NOT low-poly without pixelation

### Twelve Ecosystems

- The five elements per ecosystem are fixed
- Magic tradition names are fixed
- Interaction compatibility ratings are fixed

### Magic System Core

- Twelve traditions, no more, no fewer
- Fifth Path requires all twelve
- Compatibility spectrum ratings

### File Structure

- Top-level folder organization
- Separation of scenes/scripts
- Autoload pattern for managers

### Data Formats

- JSON for external content (dialogue, quests, lore)
- Resources (.tres) for Godot-native data
- Structure of dialogue/quest JSON

-----

## QUICK REFERENCE

### Autoloads (access anywhere)

- `GameManager` — State, scene transitions
- `SaveManager` — Persistence
- `EventBus` — Global signals
- `AudioManager` — Sound
- `DialogueManager` — Conversations
- `WorldState` — Persistent world data

### Key Paths

- Player scene: `/scenes/player/player.tscn`
- Magic traditions: `/resources/magic/traditions/`
- Dialogue data: `/data/dialogue/`
- Post-process shader: `/assets/shaders/pixel_art_post.gdshader`

### Common Operations

```gdscript
# Change scene
GameManager.change_scene("res://scenes/environments/vaelthrim/settlements/thornwick/thornwick.tscn")

# Emit global event
EventBus.quest_completed.emit("thornwick_missing_travelers")

# Start dialogue
DialogueManager.start_dialogue("mira_tavern_keeper", "greeting")

# Cast spell
player.magic.cast_spell("growth_speaking_bloom", target_position)

# Save game
SaveManager.save_game("slot_1")

# Update world state (server-ready)
WorldState.update_npc_state("mira_tavern_keeper", {"mood": "worried"})
```

-----

*This document is the source of truth. When making architectural decisions, consult this first.*
