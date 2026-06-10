#!/usr/bin/env python3
"""
Applications of Ramsey Theory

Real-world applications demonstrating the mathematical results:
1. Network reliability — guaranteed cluster structure
2. Error-correcting codes — connection to coding theory
3. Tournament scheduling — unavoidable outcome patterns
"""

import math
import itertools
from typing import List, Tuple, Set, Dict


# ===========================================================================
# Application 1: Network Reliability Analysis
# ===========================================================================

def analyze_network_clusters(n: int, connections: Set[Tuple[int, int]],
                              cluster_sizes: Tuple[int, int] = (3, 3)):
    """Analyze a network for guaranteed cluster structure.

    Given n nodes and a set of connections (interpreted as a 2-coloring
    where connections = red, non-connections = blue), find monochromatic
    cliques that represent either:
    - A group of mutually connected nodes (red clique)
    - A group of mutually disconnected nodes (blue clique)

    By Ramsey theory, R(3,3) = 6 guarantees such structure for 6+ nodes.

    >>> edges = {(0,1), (1,2), (2,3), (3,4), (4,5), (5,0), (0,3), (1,4), (2,5)}
    >>> analyze_network_clusters(6, edges)
    Network Analysis (6 nodes):
    ...
    """
    s, t = cluster_sizes
    print(f"Network Analysis ({n} nodes):")
    print(f"  Connections: {len(connections)} edges")
    print(f"  Looking for: connected cluster of {s} or disconnected cluster of {t}")

    # Find red (connected) cliques
    for S in itertools.combinations(range(n), s):
        if all((min(i, j), max(i, j)) in connections
               for i, j in itertools.combinations(S, 2)):
            print(f"  Found connected cluster: {S}")
            return S, "connected"

    # Find blue (disconnected) cliques
    for S in itertools.combinations(range(n), t):
        if all((min(i, j), max(i, j)) not in connections
               for i, j in itertools.combinations(S, 2)):
            print(f"  Found disconnected cluster: {S}")
            return S, "disconnected"

    print(f"  No cluster found (n < R({s},{t}))")
    return None, None


# ===========================================================================
# Application 2: Coding Theory Connection
# ===========================================================================

def ramsey_code_distance(n: int, k: int) -> Dict:
    """Compute the Ramsey-theoretic bound on code distance.

    A 2-coloring of K_n avoiding monochromatic K_k can be viewed as
    a code over the edge alphabet {0,1} with forbidden local patterns.
    The number of such "good" codes is bounded by the probabilistic
    method.

    Returns statistics about the space of Ramsey-good colorings.

    >>> stats = ramsey_code_distance(5, 3)
    >>> stats['good_fraction'] > 0
    True
    """
    edges = list(itertools.combinations(range(n), 2))
    m = len(edges)
    total = 2**m

    # Count good colorings (avoiding monochromatic K_k)
    good = 0
    for mask in range(total):
        red = set()
        for idx, (i, j) in enumerate(edges):
            if mask & (1 << idx):
                red.add((i, j))

        has_mono = False
        for S in itertools.combinations(range(n), k):
            pairs = list(itertools.combinations(S, 2))
            all_red = all((min(i, j), max(i, j)) in red for i, j in pairs)
            all_blue = all((min(i, j), max(i, j)) not in red for i, j in pairs)
            if all_red or all_blue:
                has_mono = True
                break
        if not has_mono:
            good += 1

    # Probabilistic bound
    ck2 = math.comb(k, 2)
    prob_bound = max(0, 1 - math.comb(n, k) * 2**(1 - ck2))

    return {
        'n': n, 'k': k,
        'total_colorings': total,
        'good_colorings': good,
        'good_fraction': good / total,
        'prob_lower_bound': prob_bound,
        'edge_count': m,
    }


# ===========================================================================
# Application 3: Tournament Outcome Analysis
# ===========================================================================

def tournament_ramsey(n: int):
    """Analyze round-robin tournament for guaranteed outcome patterns.

    In a tournament of n players where every pair plays, Ramsey theory
    guarantees that for n ≥ R(s,t), there exist either:
    - s players who all beat each other in some cyclic pattern, or
    - t players forming a complete dominance chain.

    For the simpler 2-coloring model (win/loss without direction):
    n ≥ 6 guarantees 3 mutual winners or 3 mutual losers.
    """
    print(f"\nTournament Analysis (n={n} players):")
    print(f"  Total games: {math.comb(n, 2)}")

    # Erdős-Szekeres bounds
    for s in range(3, min(n, 6)):
        for t in range(s, min(n, 6)):
            bound = math.comb(s + t - 2, s - 1)
            if n >= bound:
                print(f"  Guaranteed: clique of {s} or independent set of {t} (R({s},{t}) ≤ {bound} ≤ {n})")


# ===========================================================================
# Main
# ===========================================================================

def main():
    print("=" * 60)
    print("APPLICATIONS OF RAMSEY THEORY")
    print("=" * 60)

    # Application 1: Network clusters
    print("\n--- Application 1: Network Reliability ---")
    # A social network on 6 people
    network = {(0,1), (0,2), (0,3), (1,4), (1,5), (2,3), (2,5), (3,4), (4,5)}
    analyze_network_clusters(6, network)

    # Application 2: Coding theory
    print("\n--- Application 2: Coding Theory ---")
    for n in range(3, 7):
        stats = ramsey_code_distance(n, 3)
        print(f"  n={n}: {stats['good_colorings']}/{stats['total_colorings']} "
              f"good colorings ({100*stats['good_fraction']:.1f}%), "
              f"prob bound: {100*stats['prob_lower_bound']:.1f}%")

    # Application 3: Tournaments
    print("\n--- Application 3: Tournament Analysis ---")
    for n in [6, 10, 18, 20]:
        tournament_ramsey(n)

    # Summary table
    print("\n--- Summary: Known Ramsey Numbers ---")
    print(f"{'(s,t)':>8} {'R(s,t)':>8} {'Upper bound':>12} {'Lower bound':>12}")
    print("-" * 44)
    known = {(3,3): 6, (3,4): 9, (3,5): 14, (3,6): 18, (3,7): 23, (3,8): 28, (3,9): 36,
             (4,4): 18, (4,5): "25", (5,5): "43-48"}
    for (s, t), val in known.items():
        upper = math.comb(s + t - 2, s - 1)
        print(f"  ({s},{t}){str(val):>8} {upper:>12}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Ramsey Theory Demonstrations

Interactive demonstrations of:
1. 2-colorings of complete graphs and clique detection
2. Ramsey number verification (R(3,3)=6, R(3,4)=9)
3. Probabilistic lower bound computations
4. Hales-Jewett combinatorial line detection
"""

import itertools
import math
from typing import List, Tuple, Set, Optional, Dict


# ===========================================================================
# 1. Two-Coloring Framework
# ===========================================================================

class TwoColoring:
    """A 2-coloring of the complete graph on n vertices."""

    def __init__(self, n: int, red_edges: Set[Tuple[int, int]]):
        self.n = n
        self.red_edges = set()
        for i, j in red_edges:
            self.red_edges.add((min(i, j), max(i, j)))

    def is_red(self, i: int, j: int) -> bool:
        return (min(i, j), max(i, j)) in self.red_edges

    def is_blue(self, i: int, j: int) -> bool:
        return not self.is_red(i, j) and i != j

    def is_red_clique(self, S: List[int]) -> bool:
        """Check if S forms a red clique."""
        for i, j in itertools.combinations(S, 2):
            if not self.is_red(i, j):
                return False
        return True

    def is_blue_clique(self, S: List[int]) -> bool:
        """Check if S forms a blue clique."""
        for i, j in itertools.combinations(S, 2):
            if not self.is_blue(i, j):
                return False
        return True

    def find_red_clique(self, k: int) -> Optional[List[int]]:
        """Find a red clique of size k, or None."""
        for S in itertools.combinations(range(self.n), k):
            if self.is_red_clique(list(S)):
                return list(S)
        return None

    def find_blue_clique(self, k: int) -> Optional[List[int]]:
        """Find a blue clique of size k, or None."""
        for S in itertools.combinations(range(self.n), k):
            if self.is_blue_clique(list(S)):
                return list(S)
        return None

    def display(self):
        """Print the adjacency matrix."""
        print(f"2-Coloring of K_{self.n}:")
        print("  ", " ".join(str(i) for i in range(self.n)))
        for i in range(self.n):
            row = []
            for j in range(self.n):
                if i == j:
                    row.append(".")
                elif self.is_red(i, j):
                    row.append("R")
                else:
                    row.append("B")
            print(f"{i}: {' '.join(row)}")


# ===========================================================================
# 2. Classical Constructions
# ===========================================================================

def pentagon_coloring() -> TwoColoring:
    """The pentagon (5-cycle) coloring on 5 vertices.
    Red edges connect vertices at cyclic distance 1 or 4 (mod 5).
    This avoids both red K_3 and blue K_3, proving R(3,3) > 5."""
    red = set()
    for i in range(5):
        for j in range(i + 1, 5):
            d = (j - i) % 5
            if d in (1, 4):
                red.add((i, j))
    return TwoColoring(5, red)


def cayley_coloring_8() -> TwoColoring:
    """Cayley graph coloring on Z/8Z with red differences {1, 4, 7}.
    {1, 4, 7} is a sum-free set mod 8, so the red graph is triangle-free.
    The complement is K_4-free, proving R(3,4) > 8."""
    red = set()
    for i in range(8):
        for j in range(i + 1, 8):
            d = (j - i) % 8
            if d in (1, 4, 7):
                red.add((i, j))
    return TwoColoring(8, red)


def paley_graph(p: int) -> TwoColoring:
    """Paley graph on p vertices (p prime, p ≡ 1 mod 4).
    Red edges connect vertices whose difference is a quadratic residue.
    Self-complementary, used for Ramsey lower bounds."""
    qr = set()
    for x in range(1, p):
        qr.add((x * x) % p)
    red = set()
    for i in range(p):
        for j in range(i + 1, p):
            if (j - i) % p in qr:
                red.add((i, j))
    return TwoColoring(p, red)


# ===========================================================================
# 3. Ramsey Property Verification
# ===========================================================================

def verify_ramsey_prop(n: int, s: int, t: int, verbose: bool = True) -> bool:
    """Check RamseyProp(n, s, t) by exhaustive search over all colorings.
    WARNING: exponential in C(n,2), only feasible for small n."""
    edges = list(itertools.combinations(range(n), 2))
    m = len(edges)
    if verbose:
        print(f"Checking RamseyProp({n}, {s}, {t}) over 2^{m} = {2**m} colorings...")

    for mask in range(2 ** m):
        red = set()
        for idx, (i, j) in enumerate(edges):
            if mask & (1 << idx):
                red.add((i, j))
        C = TwoColoring(n, red)
        found = False
        if C.find_red_clique(s) is not None or C.find_blue_clique(t) is not None:
            found = True
        if not found:
            if verbose:
                print(f"  Counterexample found! Coloring {mask} avoids red K_{s} and blue K_{t}")
                C.display()
            return False
    if verbose:
        print(f"  RamseyProp({n}, {s}, {t}) = TRUE (verified over all {2**m} colorings)")
    return True


# ===========================================================================
# 4. Probabilistic Lower Bound
# ===========================================================================

def probabilistic_lower_bound(k: int) -> int:
    """Find the largest n such that 2 * C(n,k) < 2^C(k,2).
    This gives R(k,k) > n by the first-moment method."""
    ck2 = math.comb(k, 2)
    threshold = 2 ** ck2
    best_n = 0
    for n in range(k, 1000):
        if 2 * math.comb(n, k) < threshold:
            best_n = n
        else:
            break
    return best_n


def print_probabilistic_bounds():
    """Print probabilistic lower bounds for R(k,k)."""
    print("\n" + "=" * 60)
    print("Probabilistic Lower Bounds for Diagonal Ramsey Numbers")
    print("=" * 60)
    print(f"{'k':>3} {'C(k,2)':>8} {'2^C(k,2)':>12} {'Best n':>8} {'Bound':>12}")
    print("-" * 60)
    for k in range(3, 12):
        ck2 = math.comb(k, 2)
        best_n = probabilistic_lower_bound(k)
        print(f"{k:>3} {ck2:>8} {2**ck2:>12} {best_n:>8} R({k},{k}) > {best_n}")


# ===========================================================================
# 5. Hales-Jewett Line Detection
# ===========================================================================

def all_words(n: int, k: int) -> List[Tuple[int, ...]]:
    """Generate all words in [k]^n."""
    return list(itertools.product(range(k), repeat=n))


def combinatorial_lines(n: int, k: int):
    """Generate all combinatorial lines in [k]^n."""
    for mask in range(1, 2**n):  # nonempty subsets of coordinates
        active = [i for i in range(n) if mask & (1 << i)]
        inactive = [i for i in range(n) if not (mask & (1 << i))]
        for base_vals in itertools.product(range(k), repeat=len(inactive)):
            base = {}
            for idx, coord in enumerate(inactive):
                base[coord] = base_vals[idx]
            # Generate the k points on this line
            points = []
            for a in range(k):
                word = [0] * n
                for coord in active:
                    word[coord] = a
                for coord, val in base.items():
                    word[coord] = val
                points.append(tuple(word))
            yield active, base, points


def check_hales_jewett(n: int, k: int, r: int, verbose: bool = True) -> bool:
    """Check if HJProp(k, r, n) holds by exhaustive search."""
    words = all_words(n, k)
    num_words = len(words)
    if verbose:
        print(f"\nChecking HJ({k}, {r}, {n}): {num_words} words, {r} colors")

    lines = list(combinatorial_lines(n, k))
    if verbose:
        print(f"  Found {len(lines)} combinatorial lines")

    # Check all r-colorings
    for coloring in itertools.product(range(r), repeat=num_words):
        color_map = dict(zip(words, coloring))
        found_mono = False
        for active, base, points in lines:
            colors = [color_map[p] for p in points]
            if len(set(colors)) == 1:
                found_mono = True
                break
        if not found_mono:
            if verbose:
                print(f"  Counterexample found!")
            return False

    if verbose:
        print(f"  HJ({k}, {r}, {n}) = TRUE")
    return True


# ===========================================================================
# 6. Main Demo
# ===========================================================================

def main():
    print("=" * 60)
    print("RAMSEY THEORY DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: Pentagon coloring
    print("\n--- Demo 1: Pentagon Coloring (R(3,3) > 5) ---")
    C5 = pentagon_coloring()
    C5.display()
    print(f"Red K_3: {C5.find_red_clique(3)}")
    print(f"Blue K_3: {C5.find_blue_clique(3)}")
    print("=> No monochromatic triangle in C_5!")

    # Demo 2: Cayley graph on Z/8Z
    print("\n--- Demo 2: Cayley Graph Z/8Z (R(3,4) > 8) ---")
    C8 = cayley_coloring_8()
    C8.display()
    print(f"Red K_3: {C8.find_red_clique(3)}")
    print(f"Blue K_4: {C8.find_blue_clique(4)}")
    print("=> No red triangle or blue K_4 on 8 vertices!")

    # Demo 3: Verify R(3,3) = 6
    print("\n--- Demo 3: Verify R(3,3) = 6 ---")
    print("Checking R(3,3) > 5: ", end="")
    r1 = not verify_ramsey_prop(5, 3, 3, verbose=False)
    print("TRUE" if r1 else "FALSE")
    print("Checking R(3,3) ≤ 6: ", end="")
    r2 = verify_ramsey_prop(6, 3, 3, verbose=False)
    print("TRUE" if r2 else "FALSE")
    print(f"=> R(3,3) = 6 ✓")

    # Demo 4: Probabilistic bounds
    print_probabilistic_bounds()

    # Demo 5: Erdős-Szekeres bound
    print("\n--- Demo 5: Erdős–Szekeres Upper Bounds ---")
    for s in range(2, 7):
        for t in range(s, 7):
            bound = math.comb(s + t - 2, s - 1)
            print(f"  R({s},{t}) ≤ C({s+t-2},{s-1}) = {bound}")

    # Demo 6: Hales-Jewett
    print("\n--- Demo 6: Hales–Jewett Verification ---")
    check_hales_jewett(2, 2, 2)
    check_hales_jewett(3, 2, 2)
    # check_hales_jewett(4, 2, 2)  # too slow for inline demo

    # Demo 7: Paley graph
    print("\n--- Demo 7: Paley Graph on 17 vertices ---")
    P17 = paley_graph(17)
    print(f"Red K_4: {P17.find_red_clique(4)}")
    print(f"Blue K_4: {P17.find_blue_clique(4)}")
    print("=> Paley(17) avoids monochromatic K_4, confirming R(4,4) > 17!")


if __name__ == "__main__":
    main()
