# GLITCH CITY

> *"Anything that is not being observed can change."*  
> *"If nobody observes something, the system is free to redefine it."*

**GLITCH CITY** is a complete, playable 3D cyberpunk mystery/puzzle prototype built in **Godot 4.x**. Reality in District 07 is not stable—it is governed by **WATCHER**, an omnipresent AI surveillance nexus that conserves memory by only rendering that which is directly under observation.

---

## 🎮 Controls

| Action | Control |
|---|---|
| **Move** | `W` / `A` / `S` / `D` |
| **Look** | Mouse (Smooth 3D first-person look) |
| **Sprint** | `Shift` |
| **Interact / Pilot CCTV** | `E` |
| **Pan / Tilt CCTV Feed** | `W` / `A` / `S` / `D` or Mouse |
| **Disengage CCTV Feed** | `E` or `Space` |
| **Pause / Resume** | `Esc` |

---

## 🧩 Gameplay & Puzzle Walkthrough

1. **Plaza & Holographic Billboards**:
   - Explore the neon-drenched streets of Sector 07. Notice the electronic billboards whose messages rewrite themselves when you turn away.
2. **The Quantum Fracture**:
   - Approach the chasm splitting the district. A quantum lattice bridge spans the gap.
   - When you look at the bridge, it holds a solid cyan grid. But when you look away, reality de-materializes and the bridge dissolves!
3. **Surveillance Camera (CAM-01)**:
   - Walk up to the CCTV console station overlooking the chasm and press `[E]` to access the live camera feed.
   - Use `W/A/S/D` to pan and tilt CAM-01 toward the bridge until the telemetry locks:
     `[TARGET ACQUIRED: QUANTUM LATTICE BRIDGE - REALITY STABILIZED]`
   - Press `[E]` or `[Space]` to disengage. The camera spotlight remains trained on the bridge, anchoring its reality matrix even when you turn your back!
4. **Maintenance Terminal Override**:
   - Safely cross the locked bridge to the North Gateway.
   - Interface with Sub-Terminal 04. It initiates an override for Security Gate 07, but with an anomaly:
     *"DIRECT OBSERVATION INHIBITS STATE TRANSITION. LOOK AWAY TO ALLOW PASSAGE."*
5. **The Unobserved Gate**:
   - Turn your back to Gate 07. Unobserved, the security protocol re-manifests the gateway. Turn back to see the open corridor!
6. **WATCHER Server Core**:
   - Step into the inner server room and access the central WATCHER terminal to unveil the story revelation.

---

## 🛠️ Architecture & Systems

- **`ObservationManager`** (`scripts/observation_manager.gd`):
  - Field-of-view, frustum, and raycast occlusion manager tracking observation by player and active security cameras.
  - Dynamically computes district reality coherence and triggers screen-space glitch effects.
- **`ObservableObject`** (`scripts/observable_object.gd`):
  - State machine base class (`NORMAL`, `OBSERVED`, `UNOBSERVED`, `GLITCHED`, `CHANGED`).
- **`ObservableBridge`** (`scripts/observable_bridge.gd`):
  - Procedural collision & hologram dissolve shader that materializes when observed and dissolves into digital noise when unobserved.
- **`SecurityCamera`** (`scripts/security_camera.gd`):
  - Remote-steered CCTV camera with pan/tilt servos, spotlight cone, target locking, and continuous observation beam.
- **`ObservableDoor` & `ObservableSign`**:
  - Reality-shifting gateway and billboard that reconfigure specifically when not observed.
- **`AudioManager`** (`scripts/audio_manager.gd`):
  - Procedurally generated 16-bit audio synthesizers (ambient cyber drone, glitch static bursts, terminal clicks, camera servo hum, footstep taps, and victory fanfare) with zero external asset dependencies.
- **Post-Process Glitch Shader** (`shaders/glitch_screen.gdshader`):
  - Screen-space horizontal slices, chromatic aberration, scanlines, and digital static.

---

## 🚀 Running the Game

Double-click `Run_Game.bat` in the root folder, or run:
```powershell
godot --path .
```
