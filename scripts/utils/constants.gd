class_name Constants
extends RefCounted

## Global constants for Living Universe.
## All game-wide constants should be defined here.

# --- Physics ---
const GRAVITY: float = 20.0
const TERMINAL_VELOCITY: float = 50.0

# --- Player Movement ---
const PLAYER_WALK_SPEED: float = 5.0
const PLAYER_RUN_SPEED: float = 8.0
const PLAYER_JUMP_VELOCITY: float = 8.0
const PLAYER_ACCELERATION: float = 15.0
const PLAYER_DECELERATION: float = 20.0
const PLAYER_AIR_CONTROL: float = 0.3

# --- Camera ---
const CAMERA_MOUSE_SENSITIVITY: float = 0.002
const CAMERA_CONTROLLER_SENSITIVITY: float = 2.0
const CAMERA_MIN_PITCH: float = -89.0
const CAMERA_MAX_PITCH: float = 89.0
const CAMERA_DEFAULT_DISTANCE: float = 5.0
const CAMERA_MIN_DISTANCE: float = 2.0
const CAMERA_MAX_DISTANCE: float = 15.0

# --- Combat ---
const INVINCIBILITY_DURATION: float = 0.5
const KNOCKBACK_STRENGTH: float = 10.0
const CRIT_MULTIPLIER: float = 2.0

# --- Time ---
const SECONDS_PER_GAME_MINUTE: float = 2.0  # Real seconds per in-game minute
const MINUTES_PER_HOUR: int = 60
const HOURS_PER_DAY: int = 24
const DAWN_HOUR: int = 6
const DUSK_HOUR: int = 18

# --- Magic ---
const BASE_MANA_REGEN: float = 1.0  # Per second
const SPELL_COOLDOWN_REDUCTION_CAP: float = 0.75  # 75% max reduction
const TRADITION_MAX_LEVEL: int = 100

# --- Interaction ---
const INTERACTION_RANGE: float = 2.5
const NPC_DIALOGUE_RANGE: float = 3.0

# --- UI ---
const DAMAGE_NUMBER_DURATION: float = 1.0
const TOOLTIP_DELAY: float = 0.5
const NOTIFICATION_DURATION: float = 3.0

# --- Save System ---
const MAX_SAVE_SLOTS: int = 10
const AUTOSAVE_INTERVAL: float = 300.0  # 5 minutes

# --- Layer Names (must match project settings) ---
const LAYER_WORLD: int = 1
const LAYER_PLAYER: int = 2
const LAYER_ENEMIES: int = 3
const LAYER_INTERACTABLES: int = 4
const LAYER_TRIGGERS: int = 5

# --- Groups ---
const GROUP_PLAYER: String = "player"
const GROUP_ENEMIES: String = "enemies"
const GROUP_NPCS: String = "npcs"
const GROUP_INTERACTABLE: String = "interactable"
const GROUP_SAVE_PERSISTENT: String = "save_persistent"

# --- Animation Names ---
const ANIM_IDLE: String = "idle"
const ANIM_WALK: String = "walk"
const ANIM_RUN: String = "run"
const ANIM_JUMP: String = "jump"
const ANIM_FALL: String = "fall"
const ANIM_LAND: String = "land"
const ANIM_ATTACK: String = "attack"
const ANIM_HURT: String = "hurt"
const ANIM_DIE: String = "die"

# --- Input Actions ---
const INPUT_MOVE_FORWARD: String = "move_forward"
const INPUT_MOVE_BACKWARD: String = "move_backward"
const INPUT_MOVE_LEFT: String = "move_left"
const INPUT_MOVE_RIGHT: String = "move_right"
const INPUT_JUMP: String = "jump"
const INPUT_SPRINT: String = "sprint"
const INPUT_INTERACT: String = "interact"
const INPUT_ATTACK: String = "attack"
const INPUT_MAGIC: String = "magic"
const INPUT_INVENTORY: String = "inventory"
const INPUT_PAUSE: String = "pause"

# --- File Paths ---
const PATH_SAVES: String = "user://saves/"
const PATH_SETTINGS: String = "user://settings.cfg"
const PATH_DIALOGUE: String = "res://data/dialogue/"
const PATH_QUESTS: String = "res://data/quests/"
const PATH_LORE: String = "res://data/lore/"
