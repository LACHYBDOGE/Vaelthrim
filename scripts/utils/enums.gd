class_name Enums
extends RefCounted

## Global enumerations for Living Universe.
## All game-wide enums should be defined here.

# --- Damage Types ---
enum DamageType {
	PHYSICAL,
	FIRE,
	FROST,
	NATURE,
	TEMPORAL,
	VOID,
	SONIC,
	PRESSURE,
	GRAVITY,
}

# --- Entity Types ---
enum EntityType {
	PLAYER,
	NPC,
	ENEMY,
	CREATURE,
	INTERACTABLE,
	PROJECTILE,
}

# --- Magic Traditions ---
enum MagicTradition {
	PRESCIENCE,         # Scorched Expanse - temporal perception
	FLESH_SHAPING,      # Symbiotic Garden - biological manipulation
	TECHNO_ARCANA,      # Eternal Lattice - ancient system activation
	VOID_WALKING,       # Void Born - spatial perception/folding
	PRESSURE_SONG,      # Abyssal Deep - sonic force manipulation
	SPORE_COMMUNION,    # Mycorrhizal Web - network consciousness
	HARMONIC_WEAVING,   # Resonant Spires - true names as frequencies
	FORGE_BINDING,      # Molten Crucible - transmutation, thermal control
	CRYO_STASIS,        # Frozen Veil - preservation, time slowing
	GROWTH_SPEAKING,    # Verdant Maelstrom - vitality, directed evolution
	DUALITY_MASTERY,    # Threshold Zone - paradox, contradictory states
	LIFT_SINGING,       # Drifting Archipelago - gravity manipulation
}

# --- Magic Compatibility ---
enum MagicCompatibility {
	SYNERGISTIC,    # +++ Combined effects exceed sum of parts
	COMPATIBLE,     # ++  Work well together, minor enhancement
	NEUTRAL,        # +   Operate independently
	CHALLENGING,    # -   Extra effort required to combine
	OPPOSING,       # --  One must be suppressed for other to work
	PARADOXICAL,    # --- Unstable but potentially powerful
}

# --- Spell Targeting ---
enum SpellTargeting {
	SELF,
	SINGLE_TARGET,
	AREA,
	DIRECTION,
	LINE,
	CONE,
}

# --- Ecosystems ---
enum Ecosystem {
	SCORCHED_EXPANSE,
	SYMBIOTIC_GARDEN,
	ETERNAL_LATTICE,
	VOID_BORN,
	ABYSSAL_DEEP,
	MYCORRHIZAL_WEB,
	RESONANT_SPIRES,
	MOLTEN_CRUCIBLE,
	FROZEN_VEIL,
	VERDANT_MAELSTROM,
	THRESHOLD_ZONE,
	DRIFTING_ARCHIPELAGO,
	VAELTHRIM,  # Starting world
}

# --- Species (Vaelthrim) ---
enum Species {
	HUMAN,
	AEL_THIR,    # Elves
	DHURGAN,     # Dwarves
	VETH_KAI,    # Beastfolk
	SYL_VANI,    # Fae
	KORVATHI,    # Dragon-kin
	THAL_MORI,   # Deep Ones
}

# --- Item Rarity ---
enum ItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
	ARTIFACT,
}

# --- Item Slot ---
enum EquipmentSlot {
	NONE,
	HEAD,
	CHEST,
	LEGS,
	FEET,
	HANDS,
	MAIN_HAND,
	OFF_HAND,
	ACCESSORY_1,
	ACCESSORY_2,
}

# --- AI States ---
enum AIState {
	IDLE,
	PATROL,
	ALERT,
	CHASE,
	ATTACK,
	FLEE,
	DEAD,
	INTERACT,
}

# --- Weather Types ---
enum WeatherType {
	CLEAR,
	CLOUDY,
	RAIN,
	STORM,
	SNOW,
	FOG,
	SANDSTORM,
	MAGICAL,
}

# --- Time of Day ---
enum TimeOfDay {
	DAWN,
	MORNING,
	NOON,
	AFTERNOON,
	DUSK,
	EVENING,
	NIGHT,
	MIDNIGHT,
}

# --- Faction Disposition ---
enum FactionDisposition {
	HOSTILE,
	UNFRIENDLY,
	NEUTRAL,
	FRIENDLY,
	ALLIED,
	DEVOTED,
}

# --- Quest Status ---
enum QuestStatus {
	UNAVAILABLE,
	AVAILABLE,
	ACTIVE,
	COMPLETED,
	FAILED,
}

# --- Interaction Type ---
enum InteractionType {
	TALK,
	EXAMINE,
	PICKUP,
	USE,
	OPEN,
	ATTACK,
}
