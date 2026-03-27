#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║  DEMO 1: ADVERSARIAL SWARM INTELLIGENCE                        ║
║  ────────────────────────────────────────────────────────────    ║
║  Emergent collective behavior from simple local rules creates   ║
║  attack/defense patterns that are computationally unpredictable ║
║  to adversaries. Each agent follows 3 rules (separation,        ║
║  alignment, cohesion) plus a chaotic perturbation term.         ║
║                                                                  ║
║  The macro-behavior is computationally irreducible: the only    ║
║  way to predict the swarm is to simulate it.                    ║
╚══════════════════════════════════════════════════════════════════╝
"""

import numpy as np
import json
import sys

# ── Configuration ──────────────────────────────────────────────
N_AGENTS = 40          # Number of swarm agents
N_ADVERSARIES = 5      # Number of adversary agents
ARENA_SIZE = 100.0
DT = 0.1
STEPS = 300
SEPARATION_RADIUS = 5.0
ALIGNMENT_RADIUS = 15.0
COHESION_RADIUS = 25.0
ADVERSARY_DETECT_RADIUS = 30.0
MAX_SPEED = 3.0
CHAOS_STRENGTH = 0.3   # Lorenz perturbation strength

# ── Lorenz System (chaotic perturbation source) ────────────────
class LorenzPerturbation:
    """Each agent has its own Lorenz oscillator for unpredictable jitter."""
    def __init__(self, sigma=10.0, rho=28.0, beta=8/3):
        self.state = np.random.randn(3) * 0.1
        self.sigma, self.rho, self.beta = sigma, rho, beta

    def step(self, dt=0.01):
        x, y, z = self.state
        dx = self.sigma * (y - x)
        dy = x * (self.rho - z) - y
        dz = x * y - self.beta * z
        self.state += np.array([dx, dy, dz]) * dt
        # Return normalized 2D perturbation from x,y components
        v = self.state[:2]
        norm = np.linalg.norm(v)
        return v / (norm + 1e-8)


# ── Swarm Agent ────────────────────────────────────────────────
class SwarmAgent:
    def __init__(self, pos, vel):
        self.pos = np.array(pos, dtype=float)
        self.vel = np.array(vel, dtype=float)
        self.chaos = LorenzPerturbation()
        self.alive = True

    def compute_forces(self, neighbors, adversaries):
        """Reynolds flocking rules + adversary evasion + chaos."""
        separation = np.zeros(2)
        alignment = np.zeros(2)
        cohesion_center = np.zeros(2)
        n_align = 0
        n_cohesion = 0

        for other in neighbors:
            if other is self or not other.alive:
                continue
            diff = self.pos - other.pos
            dist = np.linalg.norm(diff)

            if dist < SEPARATION_RADIUS and dist > 0:
                separation += diff / (dist ** 2)

            if dist < ALIGNMENT_RADIUS:
                alignment += other.vel
                n_align += 1

            if dist < COHESION_RADIUS:
                cohesion_center += other.pos
                n_cohesion += 1

        if n_align > 0:
            alignment = alignment / n_align - self.vel

        if n_cohesion > 0:
            cohesion_center = cohesion_center / n_cohesion
            cohesion = (cohesion_center - self.pos) * 0.01
        else:
            cohesion = np.zeros(2)

        # Adversary evasion
        evasion = np.zeros(2)
        for adv in adversaries:
            diff = self.pos - adv.pos
            dist = np.linalg.norm(diff)
            if dist < ADVERSARY_DETECT_RADIUS and dist > 0:
                evasion += diff / (dist ** 2) * 5.0  # Strong repulsion

        # Chaotic perturbation (makes swarm unpredictable)
        chaos_vec = self.chaos.step() * CHAOS_STRENGTH

        # Combine forces
        force = separation * 2.0 + alignment * 1.0 + cohesion + evasion + chaos_vec
        return force

    def update(self, force, dt):
        self.vel += force * dt
        speed = np.linalg.norm(self.vel)
        if speed > MAX_SPEED:
            self.vel = self.vel / speed * MAX_SPEED
        self.pos += self.vel * dt
        # Wrap around arena
        self.pos = self.pos % ARENA_SIZE


# ── Adversary (simple pursuer) ─────────────────────────────────
class Adversary:
    def __init__(self, pos):
        self.pos = np.array(pos, dtype=float)
        self.vel = np.zeros(2)
        self.kills = 0

    def pursue(self, swarm, dt):
        """Chase nearest swarm agent (predictable strategy)."""
        nearest = None
        min_dist = float('inf')
        for agent in swarm:
            if not agent.alive:
                continue
            dist = np.linalg.norm(self.pos - agent.pos)
            if dist < min_dist:
                min_dist = dist
                nearest = agent

        if nearest is not None:
            direction = nearest.pos - self.pos
            dist = np.linalg.norm(direction)
            if dist > 0:
                self.vel = direction / dist * MAX_SPEED * 0.8  # Slightly slower
            self.pos += self.vel * dt
            self.pos = self.pos % ARENA_SIZE

            # Check for kill
            if min_dist < 2.0:
                nearest.alive = False
                self.kills += 1


# ── Simulation ─────────────────────────────────────────────────
def run_simulation():
    print("=" * 65)
    print("  ADVERSARIAL SWARM INTELLIGENCE SIMULATION")
    print("  Swarm agents: %d | Adversaries: %d | Steps: %d" % (N_AGENTS, N_ADVERSARIES, STEPS))
    print("=" * 65)

    # Initialize swarm in center cluster
    swarm = []
    for _ in range(N_AGENTS):
        pos = np.random.randn(2) * 10 + ARENA_SIZE / 2
        vel = np.random.randn(2) * 0.5
        swarm.append(SwarmAgent(pos, vel))

    # Initialize adversaries at edges
    adversaries = []
    for i in range(N_ADVERSARIES):
        angle = 2 * np.pi * i / N_ADVERSARIES
        pos = np.array([ARENA_SIZE/2 + 40*np.cos(angle),
                        ARENA_SIZE/2 + 40*np.sin(angle)])
        adversaries.append(Adversary(pos))

    # Run simulation
    history = {"swarm_alive": [], "swarm_centroid": [], "swarm_spread": [],
               "adversary_kills": [], "entropy": []}

    for step in range(STEPS):
        # Update swarm
        forces = []
        for agent in swarm:
            if agent.alive:
                force = agent.compute_forces(swarm, adversaries)
                forces.append(force)
            else:
                forces.append(np.zeros(2))

        for agent, force in zip(swarm, forces):
            if agent.alive:
                agent.update(force, DT)

        # Update adversaries
        for adv in adversaries:
            adv.pursue(swarm, DT)

        # Compute metrics
        alive_positions = [a.pos for a in swarm if a.alive]
        n_alive = len(alive_positions)

        if n_alive > 0:
            centroid = np.mean(alive_positions, axis=0)
            spread = np.mean([np.linalg.norm(p - centroid) for p in alive_positions])
        else:
            centroid = np.array([0, 0])
            spread = 0

        total_kills = sum(a.kills for a in adversaries)

        # Positional entropy (discretize arena into grid)
        grid_size = 10
        grid = np.zeros((grid_size, grid_size))
        for pos in alive_positions:
            gx = min(int(pos[0] / ARENA_SIZE * grid_size), grid_size - 1)
            gy = min(int(pos[1] / ARENA_SIZE * grid_size), grid_size - 1)
            grid[gx, gy] += 1
        if n_alive > 0:
            probs = grid.flatten() / n_alive
            probs = probs[probs > 0]
            entropy = -np.sum(probs * np.log2(probs + 1e-10))
        else:
            entropy = 0

        history["swarm_alive"].append(n_alive)
        history["swarm_spread"].append(float(spread))
        history["adversary_kills"].append(total_kills)
        history["entropy"].append(float(entropy))

        if step % 50 == 0:
            print(f"  Step {step:4d} | Alive: {n_alive:3d}/{N_AGENTS} | "
                  f"Spread: {spread:6.2f} | Kills: {total_kills} | "
                  f"Entropy: {entropy:.2f} bits")

    # Final report
    print("\n" + "─" * 65)
    print("  FINAL RESULTS")
    print("─" * 65)
    survival_rate = history["swarm_alive"][-1] / N_AGENTS * 100
    print(f"  Survival rate:      {survival_rate:.1f}%")
    print(f"  Total kills:        {history['adversary_kills'][-1]}")
    print(f"  Final spread:       {history['swarm_spread'][-1]:.2f}")
    print(f"  Final entropy:      {history['entropy'][-1]:.2f} bits")
    print(f"  Mean entropy:       {np.mean(history['entropy']):.2f} bits")
    print()

    # Emergent behavior analysis
    spread_series = np.array(history["swarm_spread"])
    if len(spread_series) > 10:
        spread_changes = np.diff(spread_series)
        expansions = np.sum(spread_changes > 1.0)
        contractions = np.sum(spread_changes < -1.0)
        print(f"  Emergent maneuvers detected:")
        print(f"    Expansions (scatter):     {expansions}")
        print(f"    Contractions (regroup):   {contractions}")
        print(f"    Oscillation frequency:    {(expansions + contractions) / STEPS:.3f} /step")

    # Compare with non-chaotic swarm
    print("\n" + "─" * 65)
    print("  CONTROL: Same simulation WITHOUT chaotic perturbation")
    print("─" * 65)

    # Re-run without chaos
    swarm2 = [SwarmAgent(np.random.randn(2)*10 + ARENA_SIZE/2,
                          np.random.randn(2)*0.5) for _ in range(N_AGENTS)]
    adversaries2 = [Adversary(np.array([ARENA_SIZE/2 + 40*np.cos(2*np.pi*i/N_ADVERSARIES),
                                         ARENA_SIZE/2 + 40*np.sin(2*np.pi*i/N_ADVERSARIES)]))
                     for i in range(N_ADVERSARIES)]

    # Disable chaos
    for agent in swarm2:
        agent.chaos = type('', (), {'step': lambda self: np.zeros(2)})()

    for step in range(STEPS):
        forces = []
        for agent in swarm2:
            if agent.alive:
                force = agent.compute_forces(swarm2, adversaries2)
                forces.append(force)
            else:
                forces.append(np.zeros(2))
        for agent, force in zip(swarm2, forces):
            if agent.alive:
                agent.update(force, DT)
        for adv in adversaries2:
            adv.pursue(swarm2, DT)

    control_alive = sum(1 for a in swarm2 if a.alive)
    control_kills = sum(a.kills for a in adversaries2)
    print(f"  Control survival:   {control_alive/N_AGENTS*100:.1f}%")
    print(f"  Control kills:      {control_kills}")
    print(f"\n  ★ Chaos advantage:  {(history['swarm_alive'][-1] - control_alive)} more survivors")
    print("=" * 65)

    return history


if __name__ == "__main__":
    np.random.seed(42)
    run_simulation()
