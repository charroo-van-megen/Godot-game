---

## Class Diagram & Script Architecture

The following class diagram provides an overview of the game's current script architecture, illustrating the relationships between the main gameplay components and how they interact with one another.

The project uses a modular structure in which the Player and Boss handle their own behaviour, while supporting systems manage combat interactions and the overall boss encounter.

### Main Classes

- **Player:** Controls player movement, jumping, dodging, attacking, health, damage reactions, and animations.
- **Boss:** Controls boss behaviour, movement, attack patterns, health, damage reactions, and combat decisions.
- **AttackHitbox:** Handles attack activation and damage detection for both the player and the boss.
- **BossFightManager:** Coordinates the boss encounter, including player death, boss defeat, and damage tracking.
- **AnimatedSprite2D:** Handles the visual animations of the player and boss.

### Class Relationships

Both Player and Boss inherit from Godot's `CharacterBody2D` class, allowing them to use built-in physics and collision functionality.

The Player and Boss each use an `AttackHitbox` to handle their attacks and an `AnimatedSprite2D` to control their animations.

The Boss tracks the Player during combat and communicates with the BossFightManager to report damage and encounter outcomes. The Player also communicates with the manager when defeated.

This structure keeps the main gameplay responsibilities separated, making the project easier to maintain, expand, and develop further.

*Note: The diagram represents the current documented architecture. Additional systems, such as permanent stat progression, are planned for future development.*
<img width="1880" height="3614" alt="mermaid-diagram" src="https://github.com/user-attachments/assets/0fef03b3-7240-412e-9668-011202d2086e" />
