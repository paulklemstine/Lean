#!/usr/bin/env python3
"""
Applications of the Berggren Symplectic Bridge

Demonstrates practical applications of the arithmetic-to-symplectic connection:
1. Qutrit stabilizer state labeling via Pythagorean triples
2. Arithmetic circuit compiler for stabilizer transport
3. Binary classification of Pythagorean triples by symplectic orbit
"""

from itertools import product
from collections import deque
from typing import Tuple, List, Dict, Optional


# ============================================================
# Application 1: Qutrit Stabilizer State Labeling
# ============================================================

class QutritStabilizerLabeler:
    """Label qutrit stabilizer states using Pythagorean triple arithmetic.

    Each primitive Pythagorean triple (a,b,c) with Euclidean parameters (m,n)
    maps to a stabilizer state label (m mod 3, n mod 3) in F_3^2 \\ {0}.

    The 8 nonzero vectors in F_3^2 correspond to the 8 distinct stabilizer
    states of a single qutrit (dimension 3).

    Usage:
        labeler = QutritStabilizerLabeler()
        label = labeler.label_triple(3, 4, 5)  # Returns (2, 1)
        name = labeler.state_name(label)        # Returns human-readable name
    """

    STABILIZER_NAMES = {
        (1, 0): "|0⟩ basis",
        (2, 0): "|0⟩ basis (conjugate)",
        (0, 1): "|+⟩ basis",
        (0, 2): "|+⟩ basis (conjugate)",
        (1, 1): "|+i⟩ basis",
        (2, 2): "|+i⟩ basis (conjugate)",
        (1, 2): "|ω⟩ basis",
        (2, 1): "|ω⟩ basis (conjugate)",
    }

    def label_triple(self, a: int, b: int, c: int) -> Tuple[int, int]:
        """Extract the qutrit stabilizer label from a primitive Pythagorean triple.

        Args:
            a, b, c: primitive Pythagorean triple with a odd, b even

        Returns:
            (m mod 3, n mod 3) where a = m²-n², b = 2mn, c = m²+n²
        """
        m_sq = (a + c) // 2
        n_sq = (c - a) // 2
        m = int(round(m_sq ** 0.5))
        n = int(round(n_sq ** 0.5))
        assert m * m == m_sq and n * n == n_sq, f"Invalid triple ({a},{b},{c})"
        return (m % 3, n % 3)

    def state_name(self, label: Tuple[int, int]) -> str:
        """Get the human-readable stabilizer state name."""
        return self.STABILIZER_NAMES.get(label, "Unknown")

    def classify_tree(self, depth: int) -> Dict[Tuple[int, int], List[Tuple[int, int, int]]]:
        """Classify Berggren tree triples by their stabilizer label.

        Returns dict mapping stabilizer label -> list of triples
        """
        import numpy as np

        B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
        B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
        B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

        classified = {k: [] for k in self.STABILIZER_NAMES}
        root = np.array([3, 4, 5])
        queue = deque([(root, 0)])

        while queue:
            triple, d = queue.popleft()
            a, b, c = int(triple[0]), int(triple[1]), int(triple[2])
            label = self.label_triple(a, b, c)
            if label in classified:
                classified[label].append((a, b, c))
            if d < depth:
                for B in [B1, B2, B3]:
                    queue.append((B @ triple, d + 1))

        return classified


# ============================================================
# Application 2: Arithmetic Circuit Compiler
# ============================================================

class ArithmeticCircuitCompiler:
    """Compile stabilizer state transitions into Berggren word sequences.

    Given a source and target stabilizer state (as F_3^2 vectors), finds the
    shortest Berggren generator word that realizes the transition.

    This is the "circuit compiler" interpretation: Berggren arithmetic provides
    a deterministic, optimal protocol for navigating between stabilizer states.

    Usage:
        compiler = ArithmeticCircuitCompiler()
        circuit = compiler.compile((2, 1), (1, 0))
        print(circuit)  # e.g., ['E1^2']
    """

    E1_MOD3 = [[2, 2], [1, 0]]
    E3_MOD3 = [[1, 2], [0, 1]]

    def __init__(self):
        # Precompute all shortest paths
        self._precompute()

    def _mat_mul(self, A, B, p=3):
        return [
            [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % p,
             (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % p],
            [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % p,
             (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % p]
        ]

    def _mat_pow(self, M, k, p=3):
        result = [[1, 0], [0, 1]]
        for _ in range(k):
            result = self._mat_mul(result, M, p)
        return result

    def _mat_vec(self, M, v, p=3):
        return (
            (M[0][0]*v[0] + M[0][1]*v[1]) % p,
            (M[1][0]*v[0] + M[1][1]*v[1]) % p,
        )

    def _precompute(self):
        """Build the shortest-path table for all source-target pairs."""
        gens = {
            "E₁": self.E1_MOD3,
            "E₁⁻¹": self._mat_pow(self.E1_MOD3, 2),
            "E₃": self.E3_MOD3,
            "E₃⁻¹": self._mat_pow(self.E3_MOD3, 2),
        }

        nonzero = [(a, b) for a in range(3) for b in range(3) if (a, b) != (0, 0)]

        self.shortest_paths: Dict[Tuple[Tuple[int,int], Tuple[int,int]], List[str]] = {}

        for source in nonzero:
            visited = {source: []}
            queue = deque([(source, [])])
            while queue:
                current, path = queue.popleft()
                for name, gen in gens.items():
                    new_vec = self._mat_vec(gen, current)
                    if new_vec not in visited:
                        new_path = path + [name]
                        visited[new_vec] = new_path
                        queue.append((new_vec, new_path))
            for target in nonzero:
                self.shortest_paths[(source, target)] = visited.get(target, [])

    def compile(self, source: Tuple[int, int], target: Tuple[int, int]) -> List[str]:
        """Compile the shortest circuit from source to target.

        Args:
            source: starting stabilizer label in F_3^2
            target: target stabilizer label in F_3^2

        Returns:
            List of generator names forming the shortest word
        """
        return self.shortest_paths.get((source, target), [])

    def cost(self, source: Tuple[int, int], target: Tuple[int, int]) -> int:
        """Get the minimum cost of transport."""
        return len(self.compile(source, target))

    def cost_matrix(self) -> Dict[Tuple[Tuple[int,int], Tuple[int,int]], int]:
        """Return the full 8x8 cost matrix."""
        return {k: len(v) for k, v in self.shortest_paths.items()}


# ============================================================
# Application 3: Triple Classification by Symplectic Orbit
# ============================================================

def classify_triples_by_orbit(max_hypotenuse: int = 1000) -> Dict[Tuple[int, int], List[Tuple[int, int, int]]]:
    """Classify all primitive Pythagorean triples by their symplectic orbit label.

    For each primitive triple (a, b, c) with a odd, b even, computes
    the Euclidean parameters (m, n) and the label (m mod 3, n mod 3).

    Args:
        max_hypotenuse: maximum hypotenuse value

    Returns:
        Dict mapping F_3^2 label to list of triples
    """
    from math import gcd, isqrt

    classified: Dict[Tuple[int, int], List[Tuple[int, int, int]]] = {
        (a, b): [] for a in range(3) for b in range(3) if (a, b) != (0, 0)
    }

    for m in range(2, isqrt(max_hypotenuse) + 1):
        for n in range(1, m):
            if (m - n) % 2 == 0:
                continue
            if gcd(m, n) != 1:
                continue
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            if c > max_hypotenuse:
                continue
            label = (m % 3, n % 3)
            classified[label].append((a, b, c))

    return classified


if __name__ == "__main__":
    print("=" * 60)
    print("Application 1: Qutrit Stabilizer State Labeling")
    print("=" * 60)

    labeler = QutritStabilizerLabeler()

    test_triples = [
        (3, 4, 5), (5, 12, 13), (7, 24, 25),
        (21, 20, 29), (15, 8, 17), (35, 12, 37), (45, 28, 53),
        (55, 48, 73), (39, 80, 89),
    ]

    for a, b, c in test_triples:
        label = labeler.label_triple(a, b, c)
        name = labeler.state_name(label)
        print(f"  ({a:3d}, {b:3d}, {c:3d}) -> label {label} -> {name}")

    print("\n  Classification of first 3 levels:")
    classified = labeler.classify_tree(3)
    for label, triples in sorted(classified.items()):
        name = labeler.state_name(label)
        print(f"  {label} ({name}): {len(triples)} triples")
        for t in triples[:3]:
            print(f"    ({t[0]}, {t[1]}, {t[2]})")
        if len(triples) > 3:
            print(f"    ... and {len(triples) - 3} more")

    print()
    print("=" * 60)
    print("Application 2: Arithmetic Circuit Compiler")
    print("=" * 60)

    compiler = ArithmeticCircuitCompiler()

    print("  Transport costs from root (2,1):")
    for target in [(0,1), (0,2), (1,0), (1,1), (1,2), (2,0), (2,1), (2,2)]:
        circuit = compiler.compile((2, 1), target)
        cost = compiler.cost((2, 1), target)
        name = labeler.state_name(target)
        circuit_str = " → ".join(circuit) if circuit else "identity"
        print(f"  (2,1) -> {target}: cost {cost}, circuit: {circuit_str}")
        print(f"          [{name}]")

    print("\n  Full 8×8 cost matrix (rows=source, cols=target):")
    nonzero = [(a, b) for a in range(3) for b in range(3) if (a, b) != (0, 0)]
    header = "      " + "  ".join(f"{v}" for v in nonzero)
    print(f"  {header}")
    for src in nonzero:
        row = "  ".join(f"{compiler.cost(src, tgt):5d}" for tgt in nonzero)
        print(f"  {src} {row}")

    print()
    print("=" * 60)
    print("Application 3: Triple Classification (c ≤ 500)")
    print("=" * 60)

    classified = classify_triples_by_orbit(500)
    for label in sorted(classified.keys()):
        triples = classified[label]
        name = labeler.state_name(label)
        print(f"  {label} ({name}): {len(triples)} primitive triples")
        for t in triples[:5]:
            print(f"    ({t[0]}, {t[1]}, {t[2]})")
        if len(triples) > 5:
            print(f"    ... and {len(triples) - 5} more")


#!/usr/bin/env python3
"""
Berggren Symplectic Bridge — Computational Demonstrations

Demonstrates the connection between the Berggren tree of primitive Pythagorean
triples and finite symplectic group actions over F_3.

Key results demonstrated:
1. Berggren matrices act on Euclidean parameters via 2x2 integer matrices
2. Mod-3 reduction generates all of SL(2, F_3) (24 elements)
3. The orbit covers all 8 nonzero vectors in F_3^2
4. The mod-2 reduction is trivially identity (correcting naive claims)
"""

import numpy as np
from itertools import product

# ============================================================
# Berggren matrices (3x3 over Z)
# ============================================================
B1 = np.array([[1, -2, 2],
               [2, -1, 2],
               [2, -2, 3]])

B2 = np.array([[1, 2, 2],
               [2, 1, 2],
               [2, 2, 3]])

B3 = np.array([[-1, 2, 2],
               [-2, 1, 2],
               [-2, 2, 3]])

# ============================================================
# Euclidean parameter matrices (2x2 over Z)
# ============================================================
E1 = np.array([[2, -1],
               [1,  0]])

E2 = np.array([[2, 1],
               [1, 0]])

E3 = np.array([[1, 2],
               [0, 1]])

def euclid_param(m, n):
    """Euclid parametrization: (m,n) -> (m^2-n^2, 2mn, m^2+n^2)"""
    return np.array([m**2 - n**2, 2*m*n, m**2 + n**2])

# ============================================================
# Demo 1: Verify Berggren-Euclid correspondence
# ============================================================
print("=" * 60)
print("DEMO 1: Berggren-Euclid Correspondence")
print("=" * 60)

m, n = 2, 1  # Root parameters giving (3, 4, 5)
triple = euclid_param(m, n)
print(f"Root: (m,n) = ({m},{n}) -> triple = {triple}")
print()

for name, B, E in [("B1", B1, E1), ("B2", B2, E2), ("B3", B3, E3)]:
    # Apply 3x3 Berggren
    new_triple_3x3 = B @ triple

    # Apply 2x2 Euclidean
    new_params = E @ np.array([m, n])
    new_triple_2x2 = euclid_param(new_params[0], new_params[1])

    match = np.array_equal(new_triple_3x3, new_triple_2x2)
    print(f"{name}: 3x3 gives {new_triple_3x3}, 2x2 gives {new_triple_2x2}, match={match}")
    print(f"  New Euclid params: (M,N) = ({new_params[0]}, {new_params[1]})")

# ============================================================
# Demo 2: Mod-2 triviality
# ============================================================
print()
print("=" * 60)
print("DEMO 2: Mod-2 Triviality (All Berggren ≡ I mod 2)")
print("=" * 60)

for name, B in [("B1", B1), ("B2", B2), ("B3", B3)]:
    mod2 = B % 2
    is_identity = np.array_equal(mod2, np.eye(3, dtype=int))
    print(f"{name} mod 2 = identity: {is_identity}")
    print(f"  {mod2.tolist()}")

print("\nConclusion: Naive mod-2 approach gives ONLY identity.")
print("Cannot generate SL(2, F_2). The original proposal is corrected.")

# ============================================================
# Demo 3: Mod-3 generation of SL(2, F_3)
# ============================================================
print()
print("=" * 60)
print("DEMO 3: Mod-3 Generation of SL(2, F_3)")
print("=" * 60)

def mat_mod(M, p):
    return M % p

E1_mod3 = mat_mod(E1, 3)
E3_mod3 = mat_mod(E3, 3)
print(f"E1 mod 3 = {E1_mod3.tolist()}")
print(f"E3 mod 3 = {E3_mod3.tolist()}")
print(f"det(E1 mod 3) = {int(round(np.linalg.det(E1_mod3))) % 3}")
print(f"det(E3 mod 3) = {int(round(np.linalg.det(E3_mod3))) % 3}")

def mat_mul_mod(A, B, p):
    return (A @ B) % p

def mat_pow_mod(M, k, p):
    n = M.shape[0]
    result = np.eye(n, dtype=int)
    for _ in range(k):
        result = mat_mul_mod(result, M, p)
    return result

# Check orders
for name, M in [("E1", E1_mod3), ("E3", E3_mod3)]:
    for k in range(1, 10):
        if np.array_equal(mat_pow_mod(M, k, 3), np.eye(2, dtype=int)):
            print(f"Order of {name} mod 3: {k}")
            break

prod_E1E3 = mat_mul_mod(E1_mod3, E3_mod3, 3)
for k in range(1, 20):
    if np.array_equal(mat_pow_mod(prod_E1E3, k, 3), np.eye(2, dtype=int)):
        print(f"Order of E1*E3 mod 3: {k}")
        break

# Generate all products E1^a * E3^b * E1^c * E3^d * E1^e
generated = set()
for a, b, c, d, e in product(range(3), repeat=5):
    M = np.eye(2, dtype=int)
    M = mat_mul_mod(M, mat_pow_mod(E1_mod3, a, 3), 3)
    M = mat_mul_mod(M, mat_pow_mod(E3_mod3, b, 3), 3)
    M = mat_mul_mod(M, mat_pow_mod(E1_mod3, c, 3), 3)
    M = mat_mul_mod(M, mat_pow_mod(E3_mod3, d, 3), 3)
    M = mat_mul_mod(M, mat_pow_mod(E1_mod3, e, 3), 3)
    generated.add(tuple(M.flatten()))

print(f"\nNumber of distinct products: {len(generated)}")

# Count SL(2, F_3) elements
sl2_count = 0
for a, b, c, d in product(range(3), repeat=4):
    if (a * d - b * c) % 3 == 1:
        sl2_count += 1
print(f"|SL(2, F_3)| = {sl2_count}")
print(f"Generated == SL(2, F_3): {len(generated) == sl2_count}")

# ============================================================
# Demo 4: Orbit surjectivity on F_3^2
# ============================================================
print()
print("=" * 60)
print("DEMO 4: Orbit Surjectivity on F_3^2 \\ {0}")
print("=" * 60)

root_vec = np.array([2, 1])  # (m, n) = (2, 1) mod 3

orbit = set()
for mat_tuple in generated:
    M = np.array(mat_tuple, dtype=int).reshape(2, 2)
    v = (M @ root_vec) % 3
    orbit.add(tuple(v))

nonzero_vecs = set()
for a, b in product(range(3), repeat=2):
    if (a, b) != (0, 0):
        nonzero_vecs.add((a, b))

print(f"Root vector mod 3: {tuple(root_vec)}")
print(f"Orbit size: {len(orbit)}")
print(f"|F_3^2 \\ {{0}}| = {len(nonzero_vecs)}")
print(f"Orbit = F_3^2 \\ {{0}}: {orbit == nonzero_vecs}")
print(f"Orbit vectors: {sorted(orbit)}")

# ============================================================
# Demo 5: Berggren tree — first few levels
# ============================================================
print()
print("=" * 60)
print("DEMO 5: Berggren Tree (First 3 Levels)")
print("=" * 60)

def berggren_children(triple):
    return [B @ triple for B in [B1, B2, B3]]

root = np.array([3, 4, 5])
print(f"Level 0: {root.tolist()}")

level1 = berggren_children(root)
print(f"Level 1: {[t.tolist() for t in level1]}")

level2 = []
for t in level1:
    level2.extend(berggren_children(t))
print(f"Level 2: {[t.tolist() for t in level2]}")

# Show Euclidean parameters for each
print("\nEuclidean parameters:")
print(f"  (3,4,5) <- (m,n) = (2,1)")
for t in level1:
    a, b, c = t
    # Recover m, n from a = m^2 - n^2, c = m^2 + n^2
    m_sq = (a + c) // 2
    n_sq = (c - a) // 2
    m_val = int(round(m_sq ** 0.5))
    n_val = int(round(n_sq ** 0.5))
    if m_val**2 == m_sq and n_val**2 == n_sq:
        print(f"  {t.tolist()} <- (m,n) = ({m_val},{n_val}), mod 3: ({m_val%3},{n_val%3})")
    else:
        print(f"  {t.tolist()} <- complex Euclid params")

# ============================================================
# Demo 6: Standard generators of SL(2, F_3)
# ============================================================
print()
print("=" * 60)
print("DEMO 6: Identifying Standard Generators of SL(2, F_3)")
print("=" * 60)

T = mat_pow_mod(E3_mod3, 2, 3)  # [[1,1],[0,1]]
S = mat_mul_mod(T, E1_mod3, 3)   # T * E1 = [[0,2],[1,0]]

print(f"T = E3^2 mod 3 = {T.tolist()}")
print(f"S = T * E1 mod 3 = {S.tolist()}")
print(f"T is the standard upper triangular generator: {T.tolist() == [[1,1],[0,1]]}")
print(f"S is the standard swap generator [[0,2],[1,0]]: {S.tolist() == [[0,2],[1,0]]}")
print(f"\nS and T are the classical generators of SL(2, F_3).")
print(f"This confirms E1, E3 generate the full group.")

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for the Berggren Symplectic Bridge

Generates publication-quality figures showing:
1. The Berggren tree with mod-3 Euclidean parameter coloring
2. The Cayley graph of SL(2, F_3) with Berggren generators
3. The orbit diagram on F_3^2
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product as iterproduct
from collections import deque
import base64
import io


# ============================================================
# Color scheme for F_3^2 vectors
# ============================================================
PARITY_COLORS = {
    (0, 1): '#e74c3c',  # red
    (0, 2): '#e67e22',  # orange
    (1, 0): '#2ecc71',  # green
    (1, 1): '#3498db',  # blue
    (1, 2): '#9b59b6',  # purple
    (2, 0): '#1abc9c',  # teal
    (2, 1): '#f39c12',  # yellow
    (2, 2): '#e91e63',  # pink
    (0, 0): '#95a5a6',  # gray (should not appear)
}

PARITY_LABELS = {
    (0, 1): '(0,1)',
    (0, 2): '(0,2)',
    (1, 0): '(1,0)',
    (1, 1): '(1,1)',
    (1, 2): '(1,2)',
    (2, 0): '(2,0)',
    (2, 1): '(2,1)',
    (2, 2): '(2,2)',
}

# Berggren matrices
B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])


def get_euclid_params(a, b, c):
    """Extract Euclidean parameters from a primitive triple."""
    m_sq = (a + c) // 2
    n_sq = (c - a) // 2
    m = int(round(m_sq ** 0.5))
    n = int(round(n_sq ** 0.5))
    if m*m == m_sq and n*n == n_sq:
        return m, n
    return None, None


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


# ============================================================
# Figure 1: Berggren Tree with Mod-3 Coloring
# ============================================================
def make_berggren_tree_figure():
    """Generate the Berggren tree colored by mod-3 Euclidean parameters."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))

    # Generate tree
    root = np.array([3, 4, 5])
    nodes = [(root, 0, 0, None)]  # (triple, depth, position, parent_pos)
    positions = {}
    colors_list = []

    # BFS
    queue = deque([(root, 0, 0)])
    depth_counts = {0: 1, 1: 3, 2: 9, 3: 27}
    depth_index = {0: 0, 1: 0, 2: 0, 3: 0}

    all_nodes = []
    edges = []

    def add_node(triple, depth, parent_idx):
        idx = len(all_nodes)
        m, n = get_euclid_params(int(triple[0]), int(triple[1]), int(triple[2]))
        mod3 = (m % 3, n % 3) if m is not None else (0, 0)
        x_spacing = 12.0 / max(1, depth_counts.get(depth, 1))
        x = depth_index[depth] * x_spacing - 6.0 + x_spacing / 2
        y = -depth * 2.0
        depth_index[depth] += 1
        all_nodes.append({
            'triple': triple,
            'depth': depth,
            'x': x, 'y': y,
            'mod3': mod3,
            'm': m, 'n': n,
            'parent': parent_idx
        })
        if parent_idx is not None:
            edges.append((parent_idx, idx))
        return idx

    root_idx = add_node(root, 0, None)

    queue = deque([(root, 0, root_idx)])
    max_depth = 2

    while queue:
        triple, d, parent_idx = queue.popleft()
        if d >= max_depth:
            continue
        for B in [B1, B2, B3]:
            child = B @ triple
            child_idx = add_node(child, d + 1, parent_idx)
            queue.append((child, d + 1, child_idx))

    # Draw edges
    for p_idx, c_idx in edges:
        p = all_nodes[p_idx]
        c = all_nodes[c_idx]
        ax.plot([p['x'], c['x']], [p['y'], c['y']],
                color='#bdc3c7', linewidth=1.5, zorder=1)

    # Draw nodes
    for node in all_nodes:
        color = PARITY_COLORS[node['mod3']]
        circle = plt.Circle((node['x'], node['y']), 0.35,
                           facecolor=color, edgecolor='black',
                           linewidth=1.5, zorder=2)
        ax.add_patch(circle)
        a, b, c = node['triple']
        label = f"({int(a)},{int(b)},{int(c)})"
        ax.text(node['x'], node['y'] - 0.6, label,
                ha='center', va='top', fontsize=7, fontweight='bold')
        if node['m'] is not None:
            mod_label = f"({node['m']%3},{node['n']%3})"
            ax.text(node['x'], node['y'] + 0.05, mod_label,
                    ha='center', va='center', fontsize=6, color='white',
                    fontweight='bold')

    # Legend
    legend_patches = [mpatches.Patch(color=PARITY_COLORS[k], label=f'mod 3: {PARITY_LABELS[k]}')
                     for k in sorted(PARITY_LABELS.keys()) if k != (0, 0)]
    ax.legend(handles=legend_patches, loc='upper right', fontsize=8, ncol=2)

    ax.set_xlim(-7, 7)
    ax.set_ylim(-5.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title('Berggren Tree with Mod-3 Euclidean Parameter Coloring',
                fontsize=14, fontweight='bold')
    ax.text(0, 1.0, 'Each node is a primitive Pythagorean triple; colors show (m mod 3, n mod 3)',
            ha='center', fontsize=9, style='italic')
    ax.axis('off')

    return fig


# ============================================================
# Figure 2: Orbit on F_3^2
# ============================================================
def make_orbit_figure():
    """Generate the orbit diagram on F_3^2."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    E1_mod3 = np.array([[2, 2], [1, 0]])
    E3_mod3 = np.array([[1, 2], [0, 1]])

    # Draw all 9 points of F_3^2
    for a, b in iterproduct(range(3), repeat=2):
        color = PARITY_COLORS.get((a, b), '#95a5a6')
        size = 800 if (a, b) != (0, 0) else 200
        alpha = 1.0 if (a, b) != (0, 0) else 0.3
        ax.scatter(a, b, c=color, s=size, zorder=3, alpha=alpha,
                  edgecolors='black', linewidth=2)
        ax.text(a, b - 0.25, f'({a},{b})', ha='center', va='top',
                fontsize=10, fontweight='bold')

    # Draw arrows for E1 action
    for a, b in iterproduct(range(3), repeat=2):
        if (a, b) == (0, 0):
            continue
        v = np.array([a, b])
        w_e1 = (E1_mod3 @ v) % 3
        w_e3 = (E3_mod3 @ v) % 3

        if not np.array_equal(v, w_e1):
            dx, dy = w_e1[0] - a, w_e1[1] - b
            ax.annotate('', xy=(w_e1[0] - dx*0.15, w_e1[1] - dy*0.15),
                        xytext=(a + dx*0.15, b + dy*0.15),
                        arrowprops=dict(arrowstyle='->', color='#e74c3c',
                                       lw=2, connectionstyle='arc3,rad=0.2'))

        if not np.array_equal(v, w_e3):
            dx, dy = w_e3[0] - a, w_e3[1] - b
            ax.annotate('', xy=(w_e3[0] - dx*0.15, w_e3[1] - dy*0.15),
                        xytext=(a + dx*0.15, b + dy*0.15),
                        arrowprops=dict(arrowstyle='->', color='#3498db',
                                       lw=2, connectionstyle='arc3,rad=-0.2'))

    # Mark root
    ax.scatter(2, 1, c='gold', s=1200, zorder=2, marker='*',
              edgecolors='black', linewidth=1)
    ax.text(2, 1.4, 'Root\n(2,1)', ha='center', fontsize=9, color='#f39c12',
            fontweight='bold')

    # Legend
    e1_line = mpatches.Patch(color='#e74c3c', label='E₁ action')
    e3_line = mpatches.Patch(color='#3498db', label='E₃ action')
    ax.legend(handles=[e1_line, e3_line], loc='upper left', fontsize=11)

    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.5, 2.5)
    ax.set_title('Berggren Orbit on F₃² \\ {0}', fontsize=14, fontweight='bold')
    ax.set_xlabel('First coordinate (mod 3)', fontsize=12)
    ax.set_ylabel('Second coordinate (mod 3)', fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xticks([0, 1, 2])
    ax.set_yticks([0, 1, 2])

    return fig


# ============================================================
# Figure 3: Word length distribution
# ============================================================
def make_word_length_figure():
    """Generate the word length distribution for SL(2, F_3) elements."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Compute word lengths via BFS
    E1_mod3 = [[2, 2], [1, 0]]
    E3_mod3 = [[1, 2], [0, 1]]

    def mat_mul(A, B, p=3):
        return [
            [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % p,
             (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % p],
            [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % p,
             (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % p]
        ]

    def mat_pow(M, k, p=3):
        result = [[1, 0], [0, 1]]
        for _ in range(k):
            result = mat_mul(result, M, p)
        return result

    gens = {
        "E₁": E1_mod3,
        "E₁⁻¹": mat_pow(E1_mod3, 2),
        "E₃": E3_mod3,
        "E₃⁻¹": mat_pow(E3_mod3, 2),
    }

    visited = {(1, 0, 0, 1): 0}
    queue = deque([([[1, 0], [0, 1]], 0)])

    while queue:
        current, dist = queue.popleft()
        for name, gen in gens.items():
            prod = mat_mul(current, gen)
            key = (prod[0][0], prod[0][1], prod[1][0], prod[1][1])
            if key not in visited:
                visited[key] = dist + 1
                queue.append((prod, dist + 1))

    # Word length histogram
    lengths = list(visited.values())
    counts = {}
    for l in lengths:
        counts[l] = counts.get(l, 0) + 1

    bars = ax1.bar(sorted(counts.keys()), [counts[k] for k in sorted(counts.keys())],
                  color=['#2ecc71', '#3498db', '#e74c3c', '#9b59b6', '#f39c12'],
                  edgecolor='black', linewidth=1.5)

    for bar, count in zip(bars, [counts[k] for k in sorted(counts.keys())]):
        ax1.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.3,
                str(count), ha='center', fontsize=12, fontweight='bold')

    ax1.set_xlabel('Word Length', fontsize=12)
    ax1.set_ylabel('Number of Elements', fontsize=12)
    ax1.set_title('Word Length Distribution in SL(2, F₃)\nwith Berggren Generators',
                 fontsize=13, fontweight='bold')
    ax1.set_xticks(sorted(counts.keys()))

    # Transport costs from root (2,1)
    root = (2, 1)
    targets = [(a, b) for a in range(3) for b in range(3) if (a, b) != (0, 0)]

    transport_costs = {}
    visited_vec = {root: 0}
    queue_vec = deque([(root, 0)])

    while queue_vec:
        current, dist = queue_vec.popleft()
        for name, gen in gens.items():
            new_vec = (
                (gen[0][0]*current[0] + gen[0][1]*current[1]) % 3,
                (gen[1][0]*current[0] + gen[1][1]*current[1]) % 3,
            )
            if new_vec not in visited_vec:
                visited_vec[new_vec] = dist + 1
                queue_vec.append((new_vec, dist + 1))

    labels = [f'({t[0]},{t[1]})' for t in targets]
    costs = [visited_vec.get(t, -1) for t in targets]
    colors = [PARITY_COLORS[t] for t in targets]

    bars2 = ax2.bar(range(len(targets)), costs, color=colors,
                   edgecolor='black', linewidth=1.5)

    for bar, cost in zip(bars2, costs):
        ax2.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.05,
                str(cost), ha='center', fontsize=11, fontweight='bold')

    ax2.set_xticks(range(len(targets)))
    ax2.set_xticklabels(labels, fontsize=9)
    ax2.set_xlabel('Target Vector in F₃²', fontsize=12)
    ax2.set_ylabel('Minimum Transport Cost', fontsize=12)
    ax2.set_title('Shortest Transport Cost from Root (2,1)\nvia Berggren Generators',
                 fontsize=13, fontweight='bold')

    plt.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = make_berggren_tree_figure()
    fig1.savefig('berggren_tree.png', dpi=150, bbox_inches='tight')
    print("  Saved berggren_tree.png")

    fig2 = make_orbit_figure()
    fig2.savefig('orbit_f3.png', dpi=150, bbox_inches='tight')
    print("  Saved orbit_f3.png")

    fig3 = make_word_length_figure()
    fig3.savefig('word_lengths.png', dpi=150, bbox_inches='tight')
    print("  Saved word_lengths.png")

    print("All visualizations generated.")
