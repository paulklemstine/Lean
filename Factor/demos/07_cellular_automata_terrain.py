#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║  DEMO 7: CELLULAR AUTOMATA TERRAIN WARFARE SIMULATION          ║
║  ────────────────────────────────────────────────────────────    ║
║  Uses cellular automata rules to generate terrain, simulate     ║
║  weather, model fire spread, and compute tactical advantages.   ║
║                                                                  ║
║  Rule 110 class automata produce Turing-complete complexity     ║
║  from minimal seeds. We use 2D totalistic rules for terrain     ║
║  generation and dynamic battlefield simulation.                  ║
╚══════════════════════════════════════════════════════════════════╝
"""

import numpy as np

# ── 2D Cellular Automata Engine ────────────────────────────────
class CellularAutomata2D:
    """Flexible 2D cellular automata with custom rules."""

    def __init__(self, width: int, height: int):
        self.width = width
        self.height = height
        self.grid = np.zeros((height, width), dtype=np.int8)

    def set_random(self, density: float = 0.5):
        self.grid = (np.random.random((self.height, self.width)) < density).astype(np.int8)

    def count_neighbors(self, i: int, j: int) -> int:
        """Count Moore neighborhood (8 neighbors)."""
        count = 0
        for di in [-1, 0, 1]:
            for dj in [-1, 0, 1]:
                if di == 0 and dj == 0:
                    continue
                ni, nj = (i + di) % self.height, (j + dj) % self.width
                count += self.grid[ni, nj]
        return count

    def step_cave(self):
        """Cave generation rule: creates natural-looking terrain."""
        new_grid = np.zeros_like(self.grid)
        for i in range(self.height):
            for j in range(self.width):
                n = self.count_neighbors(i, j)
                if self.grid[i, j] == 1:
                    new_grid[i, j] = 1 if n >= 4 else 0
                else:
                    new_grid[i, j] = 1 if n >= 5 else 0
        self.grid = new_grid

    def step_fire(self, terrain: np.ndarray, wind_dir: tuple = (0, 1),
                  wind_strength: float = 0.3):
        """Fire spread simulation with wind."""
        new_grid = self.grid.copy()
        for i in range(self.height):
            for j in range(self.width):
                if self.grid[i, j] == 0:  # Unburned
                    # Check if any neighbor is burning
                    for di in [-1, 0, 1]:
                        for dj in [-1, 0, 1]:
                            if di == 0 and dj == 0:
                                continue
                            ni = (i + di) % self.height
                            nj = (j + dj) % self.width
                            if self.grid[ni, nj] == 1:  # Burning neighbor
                                # Base probability
                                prob = 0.3
                                # Wind bonus
                                wind_bonus = (di * wind_dir[0] + dj * wind_dir[1]) * wind_strength
                                prob += max(0, wind_bonus)
                                # Terrain modifier (higher = harder to burn)
                                prob *= max(0.1, 1.0 - terrain[i, j] / 255.0 * 0.5)
                                if np.random.random() < prob:
                                    new_grid[i, j] = 1
                                    break
                        if new_grid[i, j] == 1:
                            break
                elif self.grid[i, j] == 1:  # Burning → burned out
                    if np.random.random() < 0.2:
                        new_grid[i, j] = 2  # Burned out
        self.grid = new_grid


# ── Terrain Generator ─────────────────────────────────────────
class TerrainGenerator:
    """Generate tactical terrain using cellular automata."""

    def __init__(self, width: int, height: int):
        self.width = width
        self.height = height

    def generate_caves(self, density: float = 0.45, iterations: int = 5) -> np.ndarray:
        """Generate cave-like terrain (walls = cover, open = movement)."""
        ca = CellularAutomata2D(self.width, self.height)
        ca.set_random(density)
        for _ in range(iterations):
            ca.step_cave()
        return ca.grid

    def generate_elevation(self) -> np.ndarray:
        """Generate elevation map using diamond-square algorithm."""
        size = max(self.width, self.height)
        # Pad to power of 2 + 1
        n = 1
        while n + 1 < size:
            n *= 2
        n += 1

        grid = np.zeros((n, n))
        grid[0, 0] = np.random.random()
        grid[0, n-1] = np.random.random()
        grid[n-1, 0] = np.random.random()
        grid[n-1, n-1] = np.random.random()

        step = n - 1
        roughness = 0.5
        while step > 1:
            half = step // 2
            # Diamond
            for i in range(half, n-1, step):
                for j in range(half, n-1, step):
                    avg = (grid[i-half, j-half] + grid[i-half, j+half] +
                           grid[i+half, j-half] + grid[i+half, j+half]) / 4
                    grid[i, j] = avg + np.random.uniform(-roughness, roughness)
            # Square
            for i in range(0, n, half):
                for j in range((i + half) % step, n, step):
                    vals = []
                    for di, dj in [(-half,0),(half,0),(0,-half),(0,half)]:
                        ni, nj = i+di, j+dj
                        if 0 <= ni < n and 0 <= nj < n:
                            vals.append(grid[ni, nj])
                    if vals:
                        grid[i, j] = np.mean(vals) + np.random.uniform(-roughness, roughness)
            step = half
            roughness *= 0.55

        # Normalize and crop
        grid = (grid - grid.min()) / (grid.max() - grid.min() + 1e-10) * 255
        return grid[:self.height, :self.width]


# ── Tactical Analysis ─────────────────────────────────────────
class TacticalAnalyzer:
    """Compute tactical metrics from terrain."""

    @staticmethod
    def compute_cover_map(terrain: np.ndarray, elevation: np.ndarray) -> np.ndarray:
        """Combine terrain features for cover scoring."""
        h, w = terrain.shape
        cover = np.zeros((h, w))
        for i in range(h):
            for j in range(w):
                # Cover from terrain features (walls)
                if terrain[i, j] == 1:
                    cover[i, j] = 1.0
                else:
                    # Partial cover from nearby walls
                    for di in range(-2, 3):
                        for dj in range(-2, 3):
                            ni, nj = i + di, j + dj
                            if 0 <= ni < h and 0 <= nj < w:
                                if terrain[ni, nj] == 1:
                                    dist = max(abs(di), abs(dj))
                                    cover[i, j] = max(cover[i, j], 0.5 / dist)

                    # Elevation advantage
                    local_elevation = elevation[i, j]
                    neighbors_lower = 0
                    total_neighbors = 0
                    for di in range(-3, 4):
                        for dj in range(-3, 4):
                            ni, nj = i + di, j + dj
                            if 0 <= ni < h and 0 <= nj < w and (di != 0 or dj != 0):
                                total_neighbors += 1
                                if elevation[ni, nj] < local_elevation - 10:
                                    neighbors_lower += 1
                    if total_neighbors > 0:
                        cover[i, j] += 0.3 * neighbors_lower / total_neighbors
        return np.clip(cover, 0, 1)

    @staticmethod
    def compute_line_of_sight(terrain: np.ndarray, elevation: np.ndarray,
                               observer: tuple) -> np.ndarray:
        """Compute visibility from observer position using ray casting."""
        h, w = terrain.shape
        visibility = np.zeros((h, w))
        oi, oj = observer
        obs_height = elevation[oi, oj] + 2  # Observer height

        n_rays = 360
        for angle_idx in range(n_rays):
            angle = 2 * np.pi * angle_idx / n_rays
            dx, dy = np.cos(angle), np.sin(angle)
            max_slope = -float('inf')

            for step in range(1, max(h, w)):
                ni = int(oi + dy * step)
                nj = int(oj + dx * step)
                if not (0 <= ni < h and 0 <= nj < w):
                    break
                if terrain[ni, nj] == 1:  # Wall blocks
                    break

                dist = np.sqrt((ni - oi)**2 + (nj - oj)**2)
                slope = (elevation[ni, nj] - obs_height) / max(dist, 0.1)

                if slope >= max_slope:
                    visibility[ni, nj] = 1.0
                    max_slope = slope

        return visibility

    @staticmethod
    def find_optimal_positions(cover_map: np.ndarray, visibility_map: np.ndarray,
                                n_positions: int = 5) -> list:
        """Find positions maximizing cover + visibility."""
        h, w = cover_map.shape
        score_map = cover_map * 0.6 + visibility_map * 0.4

        # Find top N positions (greedy with minimum spacing)
        positions = []
        min_spacing = max(h, w) // 6

        score_flat = score_map.copy()
        for _ in range(n_positions):
            idx = np.unravel_index(np.argmax(score_flat), score_flat.shape)
            positions.append((idx[0], idx[1], score_map[idx]))
            # Zero out nearby region
            for di in range(-min_spacing, min_spacing + 1):
                for dj in range(-min_spacing, min_spacing + 1):
                    ni, nj = idx[0] + di, idx[1] + dj
                    if 0 <= ni < h and 0 <= nj < w:
                        score_flat[ni, nj] = 0

        return positions


# ── ASCII Renderer ─────────────────────────────────────────────
def render_battlefield(terrain: np.ndarray, elevation: np.ndarray,
                        positions: list = None, fire_grid: np.ndarray = None,
                        width: int = 60) -> str:
    """Render tactical map as ASCII."""
    h, w = terrain.shape
    aspect = h / w
    render_h = max(1, int(width * aspect * 0.5))

    elev_chars = " .,:;+=▒▓█"
    lines = []

    for ri in range(render_h):
        row = ""
        for rj in range(width):
            si = min(int(ri / render_h * h), h - 1)
            sj = min(int(rj / width * w), w - 1)

            # Check for fire
            if fire_grid is not None and fire_grid[si, sj] == 1:
                row += "🔥"[0]  # Use * for fire
                continue
            if fire_grid is not None and fire_grid[si, sj] == 2:
                row += "░"
                continue

            # Check for tactical positions
            is_position = False
            if positions:
                for pi, pj, score in positions:
                    if abs(si - pi) <= 1 and abs(sj - pj) <= 1:
                        row += "◆"
                        is_position = True
                        break

            if not is_position:
                if terrain[si, sj] == 1:
                    row += "█"
                else:
                    elev_idx = int(elevation[si, sj] / 255.0 * (len(elev_chars) - 1))
                    elev_idx = max(0, min(len(elev_chars) - 1, elev_idx))
                    row += elev_chars[elev_idx]

        lines.append("    " + row)

    return "\n".join(lines)


# ── Main Demo ──────────────────────────────────────────────────
def main():
    print("=" * 65)
    print("  CELLULAR AUTOMATA TERRAIN WARFARE SIMULATION")
    print("=" * 65)
    np.random.seed(42)

    WIDTH, HEIGHT = 50, 35

    # ── Generate Terrain ───────────────────────────────────────
    print("\n  Phase 1: TERRAIN GENERATION")
    print("  " + "─" * 55)

    gen = TerrainGenerator(WIDTH, HEIGHT)
    terrain = gen.generate_caves(density=0.42, iterations=4)
    elevation = gen.generate_elevation()

    print(f"\n  Generated terrain ({WIDTH}×{HEIGHT}):")
    print(f"    Wall coverage: {np.mean(terrain)*100:.1f}%")
    print(f"    Elevation range: {elevation.min():.0f} - {elevation.max():.0f}")
    print(f"\n  Terrain Map (█=wall, .=low ground, #=high ground):")
    print(render_battlefield(terrain, elevation, width=55))

    # ── Tactical Analysis ──────────────────────────────────────
    print(f"\n\n  Phase 2: TACTICAL ANALYSIS")
    print("  " + "─" * 55)

    analyzer = TacticalAnalyzer()

    # Cover map
    cover = analyzer.compute_cover_map(terrain, elevation)
    print(f"\n  Cover Analysis:")
    print(f"    Mean cover score:   {np.mean(cover):.3f}")
    print(f"    High cover cells:   {np.sum(cover > 0.5)} ({np.sum(cover > 0.5)/(WIDTH*HEIGHT)*100:.1f}%)")

    # Line of sight from center
    center = (HEIGHT // 2, WIDTH // 2)
    # Find a non-wall position near center
    for di in range(10):
        for dj in range(10):
            if terrain[center[0]+di, center[1]+dj] == 0:
                center = (center[0]+di, center[1]+dj)
                break
        else:
            continue
        break

    los = analyzer.compute_line_of_sight(terrain, elevation, center)
    visible_cells = np.sum(los > 0)
    total_open = np.sum(terrain == 0)
    print(f"\n  Line of Sight from ({center[0]}, {center[1]}):")
    print(f"    Visible cells:      {visible_cells} of {total_open} open cells "
          f"({visible_cells/max(total_open,1)*100:.1f}%)")

    # Optimal positions
    positions = analyzer.find_optimal_positions(cover, los, n_positions=5)
    print(f"\n  Optimal Tactical Positions (◆):")
    for i, (pi, pj, score) in enumerate(positions):
        print(f"    Position {i+1}: ({pi:2d}, {pj:2d}) | Score: {score:.3f} | "
              f"Cover: {cover[pi, pj]:.3f}")

    print(f"\n  Tactical Map (◆ = optimal positions):")
    print(render_battlefield(terrain, elevation, positions=positions, width=55))

    # ── Fire Simulation ────────────────────────────────────────
    print(f"\n\n  Phase 3: FIRE SPREAD SIMULATION")
    print("  " + "─" * 55)

    fire_ca = CellularAutomata2D(WIDTH, HEIGHT)
    # Ignite fire at a random open position
    for attempt in range(100):
        fi = np.random.randint(HEIGHT)
        fj = np.random.randint(WIDTH)
        if terrain[fi, fj] == 0:
            fire_ca.grid[fi, fj] = 1
            print(f"  Ignition point: ({fi}, {fj})")
            break

    wind_dir = (0, 1)  # Wind blowing east
    print(f"  Wind direction: East (0, 1)")

    for step in range(20):
        fire_ca.step_fire(elevation, wind_dir=wind_dir, wind_strength=0.4)
        burning = np.sum(fire_ca.grid == 1)
        burned = np.sum(fire_ca.grid == 2)
        if step % 5 == 0:
            print(f"\n  Step {step:2d}: Burning={burning}, Burned out={burned}")
            print(render_battlefield(terrain, elevation,
                                     fire_grid=fire_ca.grid, width=55))
        if burning == 0 and step > 0:
            print(f"  Fire extinguished at step {step}")
            break

    total_burned = np.sum(fire_ca.grid >= 1)
    print(f"\n  Final fire damage: {total_burned} cells "
          f"({total_burned/(WIDTH*HEIGHT)*100:.1f}% of map)")

    # ── 1D Rule 110 (Bonus) ───────────────────────────────────
    print(f"\n\n  Phase 4: RULE 110 EVOLUTION (Turing-complete CA)")
    print("  " + "─" * 55)

    width_1d = 70
    rule110 = np.zeros(width_1d, dtype=int)
    rule110[width_1d - 2] = 1  # Single seed

    rule_table = {
        (1,1,1): 0, (1,1,0): 1, (1,0,1): 1, (1,0,0): 0,
        (0,1,1): 1, (0,1,0): 1, (0,0,1): 1, (0,0,0): 0,
    }

    print(f"  Rule 110 (first 30 generations):")
    for gen in range(30):
        row = "".join("█" if c else " " for c in rule110)
        print(f"    {row}")
        new = np.zeros_like(rule110)
        for j in range(width_1d):
            left = rule110[(j-1) % width_1d]
            center = rule110[j]
            right = rule110[(j+1) % width_1d]
            new[j] = rule_table[(left, center, right)]
        rule110 = new

    print(f"\n    ★ Rule 110 is proven Turing-complete (Cook, 2004)")
    print(f"      Any computation can be encoded in this simple rule!")
    print("=" * 65)


if __name__ == "__main__":
    main()
