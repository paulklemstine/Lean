"""
Tropical Cryptocurrency: Applications

Real-world applications of tropical hash-based cryptographic primitives:
1. Tropical blockchain simulation
2. Mining pool coordination
3. Difficulty adjustment algorithm
4. Tropical key exchange
"""

import random
import time
import hashlib
from typing import List, Tuple, Dict, Optional


def tsha(m: List[int], h: List[int]) -> int:
    """Tropical Secure Hash: TSHA(m, h) = min_i(m_i + h_i)"""
    return min(m[i] + h[i] for i in range(len(m)))


def tsha2(m: List[int], h1: List[int], h2: List[int]) -> Tuple[int, int]:
    """Double tropical hash."""
    return (tsha(m, h1), tsha(m, h2))


class TropicalBlock:
    """A block in the tropical blockchain."""
    
    def __init__(self, index: int, prev_hash: int, data: str,
                 nonce: List[int], key: List[int], target: int):
        self.index = index
        self.prev_hash = prev_hash
        self.data = data
        self.nonce = nonce
        self.key = key
        self.target = target
        self.timestamp = time.time()
        
        # Encode data as integer vector
        data_bytes = data.encode('utf-8')
        self.header = [b for b in data_bytes[:8]]  # First 8 bytes as header
        while len(self.header) < 8:
            self.header.append(0)
        self.header.append(prev_hash % 256)
        self.header.append(index)
        
        self.full_msg = self.header + self.nonce
        self.hash = tsha(self.full_msg, self.key)
    
    def is_valid(self) -> bool:
        return self.hash <= self.target
    
    def __repr__(self):
        return (f"Block(idx={self.index}, hash={self.hash}, "
                f"target={self.target}, valid={self.is_valid()})")


class TropicalBlockchain:
    """A simple tropical blockchain simulation."""
    
    def __init__(self, k_nonce: int = 6, initial_target: int = 30):
        self.k_header = 10  # fixed header size
        self.k_nonce = k_nonce
        self.k_total = self.k_header + k_nonce
        self.target = initial_target
        self.key = [random.randint(-20, 20) for _ in range(self.k_total)]
        self.chain: List[TropicalBlock] = []
        self.block_times: List[float] = []
        
        # Create genesis block
        genesis_nonce = [0] * k_nonce
        genesis = TropicalBlock(0, 0, "genesis", genesis_nonce, self.key, 10000)
        self.chain.append(genesis)
    
    def mine_block(self, data: str, max_attempts: int = 50000) -> Optional[TropicalBlock]:
        """Mine a new block by finding a valid nonce."""
        prev_hash = self.chain[-1].hash
        index = len(self.chain)
        start_time = time.time()
        
        for _ in range(max_attempts):
            nonce = [random.randint(-200, 200) for _ in range(self.k_nonce)]
            block = TropicalBlock(index, prev_hash, data, nonce, self.key, self.target)
            if block.is_valid():
                elapsed = time.time() - start_time
                self.chain.append(block)
                self.block_times.append(elapsed)
                return block
        return None
    
    def adjust_difficulty(self, target_time: float = 0.1):
        """Adjust mining difficulty based on recent block times."""
        if len(self.block_times) < 3:
            return
        avg_time = sum(self.block_times[-3:]) / 3
        if avg_time < target_time * 0.5:
            self.target -= 2  # Harder
        elif avg_time > target_time * 2:
            self.target += 2  # Easier


def run_blockchain_simulation():
    """Run a full tropical blockchain simulation."""
    print("=" * 60)
    print("APPLICATION 1: Tropical Blockchain Simulation")
    print("=" * 60)
    
    chain = TropicalBlockchain(k_nonce=6, initial_target=10)
    transactions = [
        "Alice->Bob:10",
        "Bob->Carol:5",
        "Carol->Dave:3",
        "Dave->Alice:7",
        "Alice->Eve:2",
    ]
    
    for tx in transactions:
        block = chain.mine_block(tx)
        if block:
            print(f"  Mined: {block} | data='{tx}' | time={chain.block_times[-1]:.4f}s")
            chain.adjust_difficulty()
        else:
            print(f"  Failed to mine block for '{tx}'")
    
    print(f"\nChain length: {len(chain.chain)}")
    print(f"Current target: {chain.target}")
    if chain.block_times:
        print(f"Average mining time: {sum(chain.block_times)/len(chain.block_times):.4f}s")


def run_collision_analysis():
    """Analyze collision resistance of TSHA vs TSHA2."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Collision Resistance Analysis")
    print("=" * 60)
    
    random.seed(123)
    
    for k in [8, 16, 32, 64, 128]:
        h1 = [random.randint(-50, 50) for _ in range(k)]
        h2 = [random.randint(-50, 50) for _ in range(k)]
        
        n_trials = 10000
        tsha_collisions = 0
        tsha2_collisions = 0
        
        for _ in range(n_trials):
            m1 = [random.randint(-100, 100) for _ in range(k)]
            m2 = [random.randint(-100, 100) for _ in range(k)]
            
            if tsha(m1, h1) == tsha(m2, h1):
                tsha_collisions += 1
                if tsha(m1, h2) == tsha(m2, h2):
                    tsha2_collisions += 1
        
        reduction = 1 - tsha2_collisions / max(tsha_collisions, 1)
        print(f"  k={k:3d}: TSHA collisions={tsha_collisions:4d}, "
              f"TSHA2={tsha2_collisions:3d}, "
              f"reduction={reduction:.1%}, "
              f"pred(1-1/k)={1-1/k:.1%}")


def run_mining_comparison():
    """Compare mining difficulty across different parameters."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Mining Difficulty Comparison")
    print("=" * 60)
    
    random.seed(456)
    
    print(f"\n  {'k':>4} {'target':>8} {'success%':>10} {'E[attempts]':>12}")
    print("  " + "-" * 40)
    
    for k in [8, 16, 32]:
        for target in [-50, -30, -10, 0]:
            h = [random.randint(-20, 20) for _ in range(k)]
            successes = 0
            n = 10000
            for _ in range(n):
                m = [random.randint(-50, 50) for _ in range(k)]
                if tsha(m, h) <= target:
                    successes += 1
            prob = successes / n
            exp_att = 1.0 / prob if prob > 0 else float('inf')
            print(f"  {k:4d} {target:8d} {100*prob:9.2f}% {exp_att:12.0f}")


if __name__ == "__main__":
    run_blockchain_simulation()
    run_collision_analysis()
    run_mining_comparison()


"""
Tropical Cryptocurrency: Mining on the Min-Plus Semiring — Demo

Demonstrates the core concepts:
1. TSHA and TSHA2 hash computation
2. Collision construction (proving they're easy for TSHA)
3. Preimage construction
4. Tropical mining simulation
5. Collision resistance comparison: TSHA vs TSHA2
"""

import random
import time
from typing import List, Tuple

def tsha(m: List[int], h: List[int]) -> int:
    """Tropical Secure Hash Algorithm: TSHA(m, h) = min_i(m_i + h_i)"""
    assert len(m) == len(h), "Message and key must have same length"
    return min(m_i + h_i for m_i, h_i in zip(m, h))

def tsha2(m: List[int], h: List[int], h_prime: List[int]) -> Tuple[int, int]:
    """Double Tropical Hash: TSHA2(m, h, h') = (TSHA(m,h), TSHA(m,h'))"""
    return (tsha(m, h), tsha(m, h_prime))

def tsha_argmin(m: List[int], h: List[int]) -> int:
    """Index achieving the TSHA minimum."""
    return min(range(len(m)), key=lambda i: m[i] + h[i])

def construct_preimage(y: int, h: List[int]) -> List[int]:
    """Construct the canonical preimage: m_i = y - h_i."""
    return [y - h_i for h_i in h]

def construct_collision(m: List[int], h: List[int]) -> List[int]:
    """Construct a collision for TSHA by modifying a non-minimum index."""
    k = len(m)
    j = tsha_argmin(m, h)  # Index achieving the min
    # Pick a different index
    i = (j + 1) % k
    m_prime = m.copy()
    m_prime[i] = m[i] + 1  # Increase non-minimum component
    return m_prime


def main():
    print("=" * 60)
    print("TROPICAL CRYPTOCURRENCY: Mining on the Min-Plus Semiring")
    print("=" * 60)
    
    # --- Demo 1: Basic TSHA computation ---
    print("\n--- Demo 1: TSHA Hash Computation ---")
    h = [3, 7, 1, 5, 2]
    m = [10, 4, 8, 6, 9]
    result = tsha(m, h)
    print(f"Key h     = {h}")
    print(f"Message m = {m}")
    print(f"m + h     = {[mi + hi for mi, hi in zip(m, h)]}")
    print(f"TSHA(m,h) = min(m_i + h_i) = {result}")
    print(f"Minimum at index {tsha_argmin(m, h)}")
    
    # --- Demo 2: Key-Message Symmetry ---
    print("\n--- Demo 2: Key-Message Symmetry (Proven in Lean) ---")
    print(f"TSHA(m, h) = {tsha(m, h)}")
    print(f"TSHA(h, m) = {tsha(h, m)}")
    print(f"Symmetric: {tsha(m, h) == tsha(h, m)} ✓")
    
    # --- Demo 3: Preimage Construction ---
    print("\n--- Demo 3: Constructive Preimage (Proven in Lean) ---")
    target_y = 42
    preimage = construct_preimage(target_y, h)
    print(f"Target y = {target_y}")
    print(f"Key h    = {h}")
    print(f"Preimage m_i = y - h_i = {preimage}")
    print(f"TSHA(preimage, h) = {tsha(preimage, h)}")
    print(f"Matches target: {tsha(preimage, h) == target_y} ✓")
    
    # --- Demo 4: Collision Construction ---
    print("\n--- Demo 4: Easy Collisions for TSHA (Proven in Lean) ---")
    m_collision = construct_collision(m, h)
    print(f"Original  m  = {m},  TSHA = {tsha(m, h)}")
    print(f"Collision m' = {m_collision}, TSHA = {tsha(m_collision, h)}")
    print(f"m ≠ m': {m != m_collision}, same hash: {tsha(m, h) == tsha(m_collision, h)} ✓")
    
    # --- Demo 5: Shift Equivariance ---
    print("\n--- Demo 5: Shift Equivariance (Proven in Lean) ---")
    c = 10
    m_shifted = [mi + c for mi in m]
    print(f"TSHA(m, h)     = {tsha(m, h)}")
    print(f"TSHA(m+{c}, h) = {tsha(m_shifted, h)}")
    print(f"TSHA(m,h) + {c} = {tsha(m, h) + c}")
    print(f"Equivariant: {tsha(m_shifted, h) == tsha(m, h) + c} ✓")
    
    # --- Demo 6: TSHA2 Double Hash ---
    print("\n--- Demo 6: TSHA2 Double Hash ---")
    h_prime = [8, 2, 6, 1, 4]
    hash2 = tsha2(m, h, h_prime)
    print(f"Key h  = {h}")
    print(f"Key h' = {h_prime}")
    print(f"TSHA2(m, h, h') = {hash2}")
    
    # Check if the TSHA collision is also a TSHA2 collision
    hash2_collision = tsha2(m_collision, h, h_prime)
    print(f"\nTSHA collision m' = {m_collision}")
    print(f"TSHA2(m', h, h') = {hash2_collision}")
    print(f"TSHA2 collision too? {hash2 == hash2_collision}")
    
    # --- Demo 7: Tropical Mining Simulation ---
    print("\n--- Demo 7: Tropical Mining Simulation ---")
    random.seed(42)
    k_header = 4
    k_nonce = 4
    k_total = k_header + k_nonce
    header = [random.randint(0, 100) for _ in range(k_header)]
    key = [random.randint(0, 50) for _ in range(k_total)]
    target = 20
    
    print(f"Header: {header}")
    print(f"Key:    {key}")
    print(f"Target: ≤ {target}")
    
    solutions_found = 0
    attempts = 0
    start = time.time()
    for _ in range(10000):
        nonce = [random.randint(-100, 100) for _ in range(k_nonce)]
        full_msg = header + nonce
        h_val = tsha(full_msg, key)
        attempts += 1
        if h_val <= target:
            solutions_found += 1
            if solutions_found <= 3:
                print(f"  Solution #{solutions_found}: nonce={nonce}, hash={h_val}")
    elapsed = time.time() - start
    print(f"Found {solutions_found}/{attempts} solutions ({100*solutions_found/attempts:.1f}%) in {elapsed:.3f}s")
    
    # --- Demo 8: Collision Resistance Comparison ---
    print("\n--- Demo 8: TSHA vs TSHA2 Collision Resistance ---")
    for k in [8, 16, 32, 64]:
        h_key = [random.randint(-50, 50) for _ in range(k)]
        h_key2 = [random.randint(-50, 50) for _ in range(k)]
        
        n_pairs = 5000
        tsha_collisions = 0
        tsha2_collisions = 0
        
        for _ in range(n_pairs):
            m1 = [random.randint(-100, 100) for _ in range(k)]
            m2 = [random.randint(-100, 100) for _ in range(k)]
            if tsha(m1, h_key) == tsha(m2, h_key):
                tsha_collisions += 1
                if tsha(m1, h_key2) == tsha(m2, h_key2):
                    tsha2_collisions += 1
        
        print(f"  k={k:3d}: TSHA collisions={tsha_collisions:4d}, "
              f"TSHA2 collisions={tsha2_collisions:3d}, "
              f"reduction={1-tsha2_collisions/max(tsha_collisions,1):.1%}")
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")


if __name__ == "__main__":
    main()


"""
Visualization: TSHA vs TSHA2 Collision Resistance

Compares collision rates between single tropical hash (TSHA) and double
tropical hash (TSHA2) as a function of key dimension k.

Key insight from the Lean proof (tsha2_collision_reduction_witness):
When two messages achieve their TSHA minimum at different indices,
a generic second key will break the collision. This means TSHA2
eliminates approximately (1 - 1/k) of TSHA collisions.
"""

import numpy as np
import matplotlib.pyplot as plt
import random


def tsha(m, h):
    """Tropical hash: min_i(m_i + h_i)"""
    return min(m[i] + h[i] for i in range(len(m)))


def measure_collision_rates(k, n_pairs=20000):
    """Measure TSHA and TSHA2 collision rates for dimension k."""
    h1 = [random.randint(-50, 50) for _ in range(k)]
    h2 = [random.randint(-50, 50) for _ in range(k)]
    
    tsha_cols = 0
    tsha2_cols = 0
    
    for _ in range(n_pairs):
        m1 = [random.randint(-100, 100) for _ in range(k)]
        m2 = [random.randint(-100, 100) for _ in range(k)]
        
        if tsha(m1, h1) == tsha(m2, h1):
            tsha_cols += 1
            if tsha(m1, h2) == tsha(m2, h2):
                tsha2_cols += 1
    
    tsha_rate = tsha_cols / n_pairs
    tsha2_rate = tsha2_cols / n_pairs
    reduction = 1 - tsha2_cols / max(tsha_cols, 1)
    return tsha_rate, tsha2_rate, reduction


random.seed(42)
dims = [4, 8, 12, 16, 24, 32, 48, 64]
tsha_rates = []
tsha2_rates = []
reductions = []

for k in dims:
    tr, t2r, red = measure_collision_rates(k, n_pairs=15000)
    tsha_rates.append(tr)
    tsha2_rates.append(t2r)
    reductions.append(red)
    print(f"k={k:3d}: TSHA rate={tr:.4f}, TSHA2 rate={t2r:.4f}, reduction={red:.3f}")

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# Panel 1: Collision rates
ax1.semilogy(dims, tsha_rates, 'ro-', markersize=8, linewidth=2, label='TSHA (single key)')
ax1.semilogy(dims, tsha2_rates, 'bs-', markersize=8, linewidth=2, label='TSHA2 (double key)')
ax1.set_xlabel('Key dimension k', fontsize=12)
ax1.set_ylabel('Collision rate (log scale)', fontsize=12)
ax1.set_title('Collision Rates: TSHA vs TSHA2', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_xticks(dims)

# Panel 2: Reduction factor vs theoretical prediction
ax2.plot(dims, reductions, 'go-', markersize=8, linewidth=2, 
         label='Observed reduction')
theoretical = [1 - 1/k for k in dims]
ax2.plot(dims, theoretical, 'k--', linewidth=2, alpha=0.7,
         label='Predicted: 1 - 1/k')
ax2.set_xlabel('Key dimension k', fontsize=12)
ax2.set_ylabel('Collision reduction fraction', fontsize=12)
ax2.set_title('TSHA2 Collision Elimination Rate', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(dims)
ax2.set_ylim(0, 1.05)

# Add conjecture annotation
ax2.annotate('Conjecture: TSHA2 eliminates\n≥ (1-1/k) of TSHA collisions',
             xy=(32, 1-1/32), xytext=(20, 0.5),
             arrowprops=dict(arrowstyle='->', color='gray'),
             fontsize=10, fontstyle='italic',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

plt.suptitle('Tropical Hash Collision Analysis', fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_collision_resistance.png', dpi=150, bbox_inches='tight')
print("Saved viz_collision_resistance.png")


"""
Visualization: Tropical Mining Landscape

Visualizes the 2D tropical hash landscape for k=2 (two message components).
Shows how TSHA(m, h) = min(m_1 + h_1, m_2 + h_2) creates a piecewise-linear
landscape, and how the mining target defines a feasibility region.

The key insight: the hash landscape is divided by a diagonal line where
m_1 + h_1 = m_2 + h_2, creating two linear regions. Mining solutions
(where hash ≤ target) form a wedge-shaped region — a tropical halfspace.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def tsha_2d(m1: np.ndarray, m2: np.ndarray, h1: float, h2: float) -> np.ndarray:
    """TSHA for k=2: min(m1+h1, m2+h2)"""
    return np.minimum(m1 + h1, m2 + h2)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Parameters
h1, h2 = 3.0, 7.0
target = 5.0

m1_range = np.linspace(-15, 15, 300)
m2_range = np.linspace(-15, 15, 300)
M1, M2 = np.meshgrid(m1_range, m2_range)

# Hash landscape
Z = tsha_2d(M1, M2, h1, h2)

# Panel 1: Hash landscape as heatmap
ax1 = axes[0]
im = ax1.contourf(M1, M2, Z, levels=30, cmap='viridis')
plt.colorbar(im, ax=ax1, label='TSHA(m, h)')
# Diagonal boundary where m1+h1 = m2+h2
ax1.plot(m1_range, m1_range + (h1 - h2), 'w--', linewidth=2, 
         label=f'm₁+{h1}=m₂+{h2}')
ax1.set_xlabel('m₁')
ax1.set_ylabel('m₂')
ax1.set_title('Tropical Hash Landscape')
ax1.legend(loc='upper left', fontsize=8)

# Panel 2: Mining feasibility region
ax2 = axes[1]
feasible = Z <= target
ax2.contourf(M1, M2, feasible.astype(float), levels=[0, 0.5, 1],
             colors=['#ffcccc', '#66cc66'], alpha=0.7)
ax2.contour(M1, M2, Z, levels=[target], colors='red', linewidths=2)
ax2.plot(m1_range, m1_range + (h1 - h2), 'k--', linewidth=1, alpha=0.5)
ax2.set_xlabel('m₁')
ax2.set_ylabel('m₂')
ax2.set_title(f'Mining Region (target ≤ {target})')
ax2.text(-12, 12, 'Valid\nnonces', fontsize=12, color='darkgreen', fontweight='bold')
ax2.text(8, -8, 'Invalid', fontsize=12, color='darkred', fontweight='bold')

# Panel 3: Multiple difficulty levels
ax3 = axes[2]
targets = [-5, 0, 5, 10]
colors = ['#d62728', '#ff7f0e', '#2ca02c', '#1f77b4']
for t, c in zip(targets, colors):
    ax3.contour(M1, M2, Z, levels=[t], colors=[c], linewidths=2)
    ax3.contourf(M1, M2, (Z <= t).astype(float), levels=[0.5, 1],
                 colors=[c], alpha=0.15)

ax3.set_xlabel('m₁')
ax3.set_ylabel('m₂')
ax3.set_title('Difficulty Levels')
# Custom legend
from matplotlib.lines import Line2D
legend_elements = [Line2D([0], [0], color=c, linewidth=2, label=f'target={t}')
                   for t, c in zip(targets, colors)]
ax3.legend(handles=legend_elements, loc='upper left', fontsize=8)

plt.suptitle('Tropical Cryptocurrency: Mining on the Min-Plus Semiring', 
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_mining_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_mining_landscape.png")


"""
Visualization: TSHA as Shortest Path in a Bipartite Graph

Illustrates the proven theorem tsha_eq_shortest_weighted_path:
TSHA(m, h) equals the minimum weight edge in the bipartite graph K_{1,k}
where edge i has weight m_i + h_i.

This connects tropical hashing to combinatorial optimization —
mining becomes a shortest-path search.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def tsha_with_witness(m, h):
    """Returns (hash_value, argmin_index)"""
    vals = [m[i] + h[i] for i in range(len(m))]
    best = min(range(len(vals)), key=lambda i: vals[i])
    return vals[best], best


fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# Example data
m = [10, 4, 8, 6, 9, 3, 7]
h = [3, 7, 1, 5, 2, 8, 4]
k = len(m)
weights = [m[i] + h[i] for i in range(k)]
hash_val, argmin = tsha_with_witness(m, h)

# Panel 1: Bipartite graph visualization
ax1 = axes[0]
ax1.set_xlim(-1, 11)
ax1.set_ylim(-1, k + 0.5)

# Source node
source_x, source_y = 1, k / 2
ax1.add_patch(plt.Circle((source_x, source_y), 0.4, color='#2196F3', zorder=5))
ax1.text(source_x, source_y, 'S', ha='center', va='center', 
         fontsize=14, fontweight='bold', color='white', zorder=6)

# Destination nodes and edges
for i in range(k):
    dest_x, dest_y = 9, i + 0.25
    
    # Edge
    is_shortest = (i == argmin)
    edge_color = '#E53935' if is_shortest else '#BDBDBD'
    edge_width = 3 if is_shortest else 1
    edge_alpha = 1.0 if is_shortest else 0.5
    
    ax1.plot([source_x + 0.4, dest_x - 0.35], [source_y, dest_y],
             color=edge_color, linewidth=edge_width, alpha=edge_alpha, zorder=3)
    
    # Weight label
    mid_x = (source_x + dest_x) / 2
    mid_y = (source_y + dest_y) / 2
    weight_color = '#E53935' if is_shortest else '#616161'
    ax1.text(mid_x + 0.3, mid_y, f'w={weights[i]}',
             fontsize=9, color=weight_color,
             fontweight='bold' if is_shortest else 'normal',
             bbox=dict(boxstyle='round,pad=0.2', facecolor='white', 
                      edgecolor=weight_color, alpha=0.8))
    
    # Destination node
    node_color = '#E53935' if is_shortest else '#4CAF50'
    ax1.add_patch(plt.Circle((dest_x, dest_y), 0.35, color=node_color, zorder=5))
    ax1.text(dest_x, dest_y, f'{i}', ha='center', va='center',
             fontsize=11, fontweight='bold', color='white', zorder=6)
    
    # Component info
    ax1.text(10.2, dest_y, f'm={m[i]}, h={h[i]}',
             fontsize=8, va='center', color='#616161')

ax1.set_title(f'TSHA as Shortest Path: K_{{1,{k}}}', fontsize=13, fontweight='bold')
ax1.text(5, -0.5, f'TSHA = min weight = {hash_val} (at index {argmin})',
         fontsize=11, ha='center', color='#E53935', fontweight='bold',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFEBEE'))
ax1.axis('off')

# Panel 2: Bar chart of edge weights
ax2 = axes[1]
colors = ['#E53935' if i == argmin else '#42A5F5' for i in range(k)]
bars = ax2.bar(range(k), weights, color=colors, edgecolor='white', linewidth=1.5)

# Horizontal line at hash value
ax2.axhline(y=hash_val, color='#E53935', linestyle='--', linewidth=2,
            label=f'TSHA = {hash_val}')

# Labels
ax2.set_xlabel('Index i', fontsize=12)
ax2.set_ylabel('Weight (m_i + h_i)', fontsize=12)
ax2.set_title('Edge Weights = Message + Key', fontsize=13, fontweight='bold')
ax2.set_xticks(range(k))

# Annotate minimum
ax2.annotate(f'min = {hash_val}', xy=(argmin, hash_val),
             xytext=(argmin + 1.5, hash_val - 1.5),
             arrowprops=dict(arrowstyle='->', color='#E53935', linewidth=2),
             fontsize=12, color='#E53935', fontweight='bold')

# Add component breakdown on each bar
for i in range(k):
    ax2.text(i, weights[i] + 0.3, f'{m[i]}+{h[i]}',
             ha='center', fontsize=8, color='#424242')

ax2.legend(fontsize=11)
ax2.grid(axis='y', alpha=0.3)

plt.suptitle('Tropical Hash ↔ Shortest Path Correspondence\n(Proven: tsha_eq_shortest_weighted_path)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_shortest_path.png', dpi=150, bbox_inches='tight')
print("Saved viz_shortest_path.png")
