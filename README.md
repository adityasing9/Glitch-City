# GLITCH CITY

> *"Anything that is not being observed can change."*  
> *"If nobody observes something, the system is free to redefine it."*

**GLITCH CITY** is a complete 3D cyberpunk mystery/puzzle game built in **Godot 4.x**. Reality in District 07 is not stable—it is governed by **WATCHER**, an AI surveillance nexus that conserves memory by only rendering that which is directly under observation.

---

## 🎮 Controls

| Action | Control |
|---|---|
| **Move** | `W` / `A` / `S` / `D` |
| **Look** | Mouse (Smooth 3D first-person look) |
| **Sprint** | `Shift` |
| **Cybernetic Flashlight** | `F` |
| **Interact / Decrypt Datapads** | `E` |
| **Pan / Tilt CCTV Feed** | `W` / `A` / `S` / `D` |
| **Switch Camera Channels** | `Q` / `1` / `2` *(In CCTV mode)* |
| **Disengage CCTV / Close Datapad** | `E` or `Space` or `Esc` |
| **Pause / Resume** | `Esc` |

---

## 🌟 Expanded Gameplay Features

### 1. 📹 Multi-Camera CCTV Grid (`CAM-01` & `CAM-02`)
- Access the multi-channel surveillance station to switch between camera feeds.
- **`CAM-01`**: High-angle chasm view overlooking the quantum bridge.
- **`CAM-02`**: Rooftop surveillance post monitoring the west alley and vertical platforms.
- Active surveillance spotlights lock objects in physical phase space.

### 2. 🛗 Quantum Kinetic Lift
- A vertical platform situated in the west alleyway leading to elevated catwalks.
- **Quantum Observer Effect**: The platform **only ascends or descends when you look away**! If you or any camera observes it, the quantum wave function collapses and it freezes solid.

### 3. 🔍 Diagnostic Cybernetic Reticle Scanner
- Aiming your crosshair at any observable object displays a real-time HUD telemetry readout:
  - Object identification
  - Reality stability state (`STABLE` vs `UNOBSERVED // DECAYING`)
  - Active anchors (`PLAYER OCULAR FEED`, `SURVEILLANCE CAM-01`, etc.)

### 4. 💾 Encrypted Memory Shards (Lore Datapads)
- Three collectible datapads scattered across the district revealing the true lore of WATCHER:
  - **Shard 01**: *The Blink Anomaly* (Dr. A. Vance)
  - **Shard 02**: *Anchoring Wave Functions* (Chief Architect Khalil)
  - **Shard 03**: *Memory Conservation Protocol* (WATCHER Subroutine 00)
- Interactive holographic reader modal with typing audio.

### 5. 🔦 Retinal Illuminator (Flashlight)
- Press `[F]` to toggle a tactical blue-white spotlight with realistic falloff and mechanical sound effects.

### 6. 🎶 Reactive Cyberpunk Audio & Synth Music
- Procedurally generated 16-bit audio engine featuring:
  - Melodic cyberpunk synth bass & arpeggios that intensify in CCTV mode
  - Stepper motor servo whirrs for cameras
  - Reality shift static glitch bursts
  - Tactile terminal key-clicks and UI chimes

---

## 🧩 Complete Puzzle Walkthrough

1. **Sector 07 Plaza**:
   - Explore the neon-drenched district. Pick up **Shard 01** on the curb.
   - Observe the electronic billboard, turn your back, and look back to watch its text rewrite itself in real time.
2. **Quantum Kinetic Lift (Optional Catwalk Exploration)**:
   - Step onto the platform on the west side. Look up at the sky or turn around to let it rise to the elevated catwalk to collect **Shard 02**.
3. **Stabilizing the Chasm Bridge**:
   - Approach the surveillance terminal overlooking the chasm. Press `[E]` to interface with `CAM-01`.
   - Pan and tilt the camera toward the bridge until you hear the confirmation chime and see:
     `>>> TARGET ACQUIRED: QUANTUM LATTICE BRIDGE [REALITY STABILIZED] <<<`
   - Disengage (`[Space]`). The camera maintains permanent line of sight, allowing you to walk across the bridge with your back turned.
4. **Maintenance Terminal Override**:
   - Cross to the North Plaza and collect **Shard 03**.
   - Interface with Sub-Terminal 04. It initiates an override for Gate 07, but announces:
     *"DIRECT OBSERVATION INHIBITS STATE TRANSITION. LOOK AWAY TO ALLOW PASSAGE."*
5. **The Unobserved Gate**:
   - Turn around so Gate 07 is out of your field of view. Unobserved, the security system re-manifests the gateway. Turn back to find the inner corridor open.
6. **WATCHER Server Core**:
   - Enter the server nexus and interface with the final terminal to uncover the revelation:
     *"The city was never malfunctioning. WATCHER is deciding what exists."*

---

## 🌐 Online & Local Play

- **Play Online**: [https://adityasing9.github.io/Glitch-City/](https://adityasing9.github.io/Glitch-City/)
- **Play Locally**: Double-click `Run_Game.bat` or run:
  ```powershell
  godot --path .
  ```
