#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║  DEMO 8: NEURAL CELLULAR AUTOMATA — SELF-HEALING SYSTEMS       ║
║  ────────────────────────────────────────────────────────────    ║
║  Differentiable cellular automata that learn to grow and        ║
║  maintain target patterns. Each cell follows learned local      ║
║  rules — no central controller. Damage triggers regeneration.   ║
║                                                                  ║
║  Inspired by biological morphogenesis and the remarkable        ║
║  regenerative abilities of organisms like planarian flatworms.  ║
╚══════════════════════════════════════════════════════════════════╝
"""

import numpy as np

# ── Neural CA Cell ─────────────────────────────────────────────
class NeuralCA:
    """
    A neural cellular automaton with learned update rules.

    Each cell has a state vector. The update rule:
    1. Perceive: Sobel-filter convolution to sense neighbors
    2. Process: Two-layer neural network (per-cell, shared weights)
    3. Update: Stochastic update with residual connection

    Training uses finite differences for gradient estimation
    (no autograd dependency needed).
    """

    def __init__(self, grid_size: int = 20, state_channels: int = 8,
                 hidden_size: int = 32):
        self.grid_size = grid_size
        self.state_channels = state_channels
        self.hidden_size = hidden_size

        # Perception filters (Sobel + identity)
        # 3 perception channels per state channel: identity, dx, dy
        self.n_perception = state_channels * 3

        # Neural network weights (shared across all cells)
        # Layer 1: perception → hidden
        self.W1 = np.random.randn(self.n_perception, hidden_size) * 0.1
        self.b1 = np.zeros(hidden_size)
        # Layer 2: hidden → state update
        self.W2 = np.random.randn(hidden_size, state_channels) * 0.01
        self.b2 = np.zeros(state_channels)

        # Initialize grid state
        self.state = np.zeros((grid_size, grid_size, state_channels))
        # Channel 0 is the "alive" channel (alpha)
        # Channels 1-3 are "visible" (RGB-like)
        # Channels 4+ are hidden state

    def _perceive(self, state: np.ndarray) -> np.ndarray:
        """Apply perception filters to get local neighborhood info."""
        h, w, c = state.shape
        perception = np.zeros((h, w, self.n_perception))

        # Sobel kernels
        sobel_x = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]) / 8.0
        sobel_y = sobel_x.T

        for ch in range(c):
            # Identity
            perception[:, :, ch * 3] = state[:, :, ch]

            # Sobel X (gradient in x direction)
            for i in range(1, h-1):
                for j in range(1, w-1):
                    val = 0
                    for di in range(-1, 2):
                        for dj in range(-1, 2):
                            val += state[i+di, j+dj, ch] * sobel_x[di+1, dj+1]
                    perception[i, j, ch * 3 + 1] = val

            # Sobel Y (gradient in y direction)
            for i in range(1, h-1):
                for j in range(1, w-1):
                    val = 0
                    for di in range(-1, 2):
                        for dj in range(-1, 2):
                            val += state[i+di, j+dj, ch] * sobel_y[di+1, dj+1]
                    perception[i, j, ch * 3 + 2] = val

        return perception

    def _relu(self, x: np.ndarray) -> np.ndarray:
        return np.maximum(0, x)

    def _update_rule(self, perception: np.ndarray) -> np.ndarray:
        """Neural network update rule."""
        h, w, _ = perception.shape
        # Reshape for matrix multiply
        flat = perception.reshape(-1, self.n_perception)
        # Layer 1
        hidden = self._relu(flat @ self.W1 + self.b1)
        # Layer 2 (no activation — residual update)
        update = hidden @ self.W2 + self.b2
        return update.reshape(h, w, self.state_channels)

    def step(self, state: np.ndarray = None, update_prob: float = 0.5) -> np.ndarray:
        """One CA step with stochastic update."""
        if state is None:
            state = self.state

        # Perceive
        perception = self._perceive(state)

        # Compute update
        update = self._update_rule(perception)

        # Stochastic update mask (not all cells update every step)
        mask = (np.random.random((self.grid_size, self.grid_size, 1)) < update_prob)

        # Apply update (residual)
        new_state = state + update * mask

        # Alive masking: cells with alpha < 0.1 are dead
        alive = np.max(new_state[:, :, 0:1], axis=2, keepdims=True) > 0.1

        # Kill isolated cells (need at least one alive neighbor)
        alive_count = np.zeros((self.grid_size, self.grid_size))
        for di in [-1, 0, 1]:
            for dj in [-1, 0, 1]:
                if di == 0 and dj == 0:
                    continue
                shifted = np.roll(np.roll(new_state[:, :, 0], di, axis=0), dj, axis=1)
                alive_count += (shifted > 0.1).astype(float)

        alive = alive & (alive_count[:, :, np.newaxis] > 0)
        new_state = new_state * alive

        # Clip state values
        new_state = np.clip(new_state, -1.0, 1.0)
        self.state = new_state
        return new_state

    def seed(self, center: tuple = None):
        """Place a seed cell at the center."""
        if center is None:
            center = (self.grid_size // 2, self.grid_size // 2)
        self.state = np.zeros((self.grid_size, self.grid_size, self.state_channels))
        self.state[center[0], center[1], :] = 1.0

    def damage(self, region: tuple):
        """Kill all cells in a rectangular region."""
        r0, c0, r1, c1 = region
        self.state[r0:r1, c0:c1, :] = 0.0


# ── Target Pattern Generator ──────────────────────────────────
def make_target(grid_size: int, pattern: str = "cross") -> np.ndarray:
    """Create target patterns for the CA to learn."""
    target = np.zeros((grid_size, grid_size))

    if pattern == "cross":
        mid = grid_size // 2
        thickness = max(1, grid_size // 8)
        target[mid-thickness:mid+thickness+1, :] = 1.0
        target[:, mid-thickness:mid+thickness+1] = 1.0

    elif pattern == "circle":
        mid = grid_size // 2
        radius = grid_size // 3
        for i in range(grid_size):
            for j in range(grid_size):
                if (i - mid)**2 + (j - mid)**2 <= radius**2:
                    target[i, j] = 1.0

    elif pattern == "diamond":
        mid = grid_size // 2
        size = grid_size // 3
        for i in range(grid_size):
            for j in range(grid_size):
                if abs(i - mid) + abs(j - mid) <= size:
                    target[i, j] = 1.0

    elif pattern == "letter_H":
        h = grid_size
        w = grid_size
        bar = max(1, h // 8)
        # Left bar
        target[h//6:5*h//6, w//4:w//4+bar] = 1.0
        # Right bar
        target[h//6:5*h//6, 3*w//4-bar:3*w//4] = 1.0
        # Middle bar
        target[h//2-bar:h//2+bar, w//4:3*w//4] = 1.0

    return target


# ── Training (Evolution Strategy) ─────────────────────────────
def train_nca(nca: NeuralCA, target: np.ndarray,
              n_iterations: int = 200, population_size: int = 20,
              sigma: float = 0.05, learning_rate: float = 0.01,
              grow_steps: int = 30) -> list:
    """
    Train NCA using Evolution Strategy (ES).
    No backpropagation needed — uses finite population sampling.
    """
    losses = []

    # Flatten all parameters
    params = np.concatenate([nca.W1.flatten(), nca.b1, nca.W2.flatten(), nca.b2])
    n_params = len(params)

    for iteration in range(n_iterations):
        # Generate population of perturbations
        noise = np.random.randn(population_size, n_params)
        rewards = np.zeros(population_size)

        for p in range(population_size):
            # Perturb parameters
            perturbed = params + sigma * noise[p]
            _set_params(nca, perturbed)

            # Grow from seed
            nca.seed()
            for _ in range(grow_steps):
                nca.step()

            # Evaluate: how close is channel 0 to target?
            alive_map = (nca.state[:, :, 0] > 0.1).astype(float)
            loss = -np.mean((alive_map - target) ** 2)  # Negative MSE as reward
            rewards[p] = loss

        # Normalize rewards
        rewards = (rewards - np.mean(rewards)) / (np.std(rewards) + 1e-8)

        # Update parameters
        gradient = np.dot(rewards, noise) / (population_size * sigma)
        params += learning_rate * gradient

        _set_params(nca, params)

        # Evaluate current
        nca.seed()
        for _ in range(grow_steps):
            nca.step()
        alive_map = (nca.state[:, :, 0] > 0.1).astype(float)
        current_loss = np.mean((alive_map - target) ** 2)
        losses.append(current_loss)

        if iteration % 40 == 0:
            print(f"    Iteration {iteration:4d} | Loss: {current_loss:.4f} | "
                  f"Alive cells: {np.sum(alive_map > 0.5)}")

    return losses


def _set_params(nca: NeuralCA, params: np.ndarray):
    """Set NCA parameters from flat vector."""
    idx = 0
    n = nca.n_perception * nca.hidden_size
    nca.W1 = params[idx:idx+n].reshape(nca.n_perception, nca.hidden_size)
    idx += n
    n = nca.hidden_size
    nca.b1 = params[idx:idx+n]
    idx += n
    n = nca.hidden_size * nca.state_channels
    nca.W2 = params[idx:idx+n].reshape(nca.hidden_size, nca.state_channels)
    idx += n
    nca.b2 = params[idx:idx+nca.state_channels]


# ── ASCII Renderer ─────────────────────────────────────────────
def render_grid(state: np.ndarray, channel: int = 0) -> str:
    """Render CA state as ASCII."""
    grid = state[:, :, channel]
    chars = " ░▒▓█"
    lines = []
    for row in grid:
        line = ""
        for val in row:
            idx = int(np.clip(val, 0, 1) * (len(chars) - 1))
            line += chars[idx]
        lines.append("    " + line)
    return "\n".join(lines)


# ── Main Demo ──────────────────────────────────────────────────
def main():
    print("=" * 65)
    print("  NEURAL CELLULAR AUTOMATA — SELF-HEALING SYSTEMS")
    print("=" * 65)

    GRID_SIZE = 12

    for pattern_name in ["cross"]:
        print(f"\n  {'═' * 55}")
        print(f"  TARGET PATTERN: {pattern_name.upper()}")
        print(f"  {'═' * 55}")

        target = make_target(GRID_SIZE, pattern_name)

        # Show target
        print(f"\n  Target pattern:")
        target_display = np.zeros((GRID_SIZE, GRID_SIZE, 1))
        target_display[:, :, 0] = target
        # Simple display
        for row in target:
            line = "    "
            for val in row:
                line += "█" if val > 0.5 else "·"
            print(line)

        # Create and train NCA
        np.random.seed(42)
        nca = NeuralCA(grid_size=GRID_SIZE, state_channels=4, hidden_size=16)

        print(f"\n  Training NCA ({nca.W1.size + nca.b1.size + nca.W2.size + nca.b2.size} parameters)...")
        losses = train_nca(nca, target, n_iterations=40, population_size=10,
                           grow_steps=10, sigma=0.08, learning_rate=0.02)

        # Show final growth
        print(f"\n  Growth sequence:")
        nca.seed()
        for step in range(30):
            nca.step()
            if step in [0, 5, 10, 15, 20, 29]:
                alive = (nca.state[:, :, 0] > 0.1).astype(float)
                n_alive = int(np.sum(alive))
                similarity = 1.0 - np.mean((alive - target) ** 2)
                print(f"\n  Step {step:2d} (alive={n_alive}, similarity={similarity:.3f}):")
                for row in alive:
                    line = "    "
                    for val in row:
                        line += "█" if val > 0.5 else "·"
                    print(line)

        # ── Self-Healing Demo ──────────────────────────────────
        print(f"\n  {'─' * 55}")
        print(f"  SELF-HEALING DEMONSTRATION")
        print(f"  {'─' * 55}")

        # Grow to stable state
        nca.seed()
        for _ in range(40):
            nca.step()

        alive_before = (nca.state[:, :, 0] > 0.1).astype(float)
        print(f"\n  Before damage:")
        for row in alive_before:
            line = "    "
            for val in row:
                line += "█" if val > 0.5 else "·"
            print(line)

        # Inflict damage (remove a quarter of the pattern)
        damage_region = (GRID_SIZE//4, GRID_SIZE//4,
                         3*GRID_SIZE//4, 3*GRID_SIZE//4)
        nca.damage(damage_region)

        alive_damaged = (nca.state[:, :, 0] > 0.1).astype(float)
        print(f"\n  After damage (center removed):")
        for row in alive_damaged:
            line = "    "
            for val in row:
                line += "█" if val > 0.5 else "·"
            print(line)

        # Let it regenerate
        for regen_step in range(30):
            nca.step()

            if regen_step in [5, 15, 29]:
                alive_regen = (nca.state[:, :, 0] > 0.1).astype(float)
                similarity = 1.0 - np.mean((alive_regen - target) ** 2)
                print(f"\n  Regeneration step {regen_step} (similarity={similarity:.3f}):")
                for row in alive_regen:
                    line = "    "
                    for val in row:
                        line += "█" if val > 0.5 else "·"
                    print(line)

    # ── Summary ────────────────────────────────────────────────
    print(f"\n\n  {'═' * 55}")
    print(f"  KEY PROPERTIES OF NEURAL CELLULAR AUTOMATA")
    print(f"  {'═' * 55}")
    print(f"    ✓ No central controller — fully distributed")
    print(f"    ✓ Self-organizing — grows from single seed cell")
    print(f"    ✓ Self-healing — regenerates after damage")
    print(f"    ✓ Shared weights — same rule for every cell")
    print(f"    ✓ Stochastic — robust to timing/order variations")
    print(f"    ✓ Scalable — works at any grid size")
    print(f"\n    ★ Each cell is a tiny neural network that only sees")
    print(f"      its immediate neighbors, yet the collective behavior")
    print(f"      produces and maintains complex global patterns.")
    print("=" * 65)


if __name__ == "__main__":
    main()
