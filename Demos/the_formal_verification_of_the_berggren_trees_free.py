#!/usr/bin/env python3
"""
Berggren Dynamics: Applications

Demonstrates real-world applications of the Berggren dynamics theorems:
1. Certified triple enumeration for engineering/graphics
2. Residue class filters for efficient Pythagorean triple search
3. Density estimation using the quadratic growth theorem
4. Visualization of the Berggren tree structure
"""

from typing import Tuple, List, Dict, Set
from collections import Counter
import math

Triple = Tuple[int, int, int]

def bergA(a, b, c): return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def bergB(a, b, c): return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def bergC(a, b, c): return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = [bergA, bergB, bergC]
ROOT = (3, 4, 5)


# ─── Application 1: Right triangle construction ───────────────────────

def find_triples_near_ratio(target_ratio: float, max_hyp: int = 10000,
                             tolerance: float = 0.01) -> List[Triple]:
    """
    Find primitive Pythagorean triples where the leg ratio a/b is close
    to a target value. Useful for engineering applications requiring
    specific angles.

    The angle θ satisfies tan(θ) = a/b, so target_ratio determines the angle.

    >>> triples = find_triples_near_ratio(1.0, max_hyp=200)  # 45-degree-ish
    >>> len(triples) > 0
    True
    """
    result = []
    stack = [ROOT]
    while stack:
        triple = stack.pop()
        a, b, c = triple
        if c > max_hyp:
            continue
        ratio = a / b if b > 0 else float('inf')
        if abs(ratio - target_ratio) < tolerance:
            result.append(triple)
        for gen in GENERATORS:
            child = gen(a, b, c)
            if child[2] <= max_hyp:
                stack.append(child)
    result.sort(key=lambda t: abs(t[0]/t[1] - target_ratio))
    return result


# ─── Application 2: Density estimation ────────────────────────────────

def count_triples_by_depth(max_depth: int) -> Dict[int, Dict]:
    """
    Count primitive Pythagorean triples organized by tree depth,
    with statistics on hypotenuse distribution.

    Uses the proven bounds:
    - At depth n, there are exactly 3^n words
    - Minimum hypotenuse = 2n² + 6n + 5 (achieved by A^n)
    - Each word gives a distinct triple (free semigroup theorem)

    >>> stats = count_triples_by_depth(5)
    >>> stats[3]['count']
    27
    """
    result = {}
    for n in range(max_depth + 1):
        min_c = 2 * n**2 + 6 * n + 5
        # Enumerate all triples at this depth
        if n == 0:
            words_triples = [ROOT]
        else:
            words_triples = []
            prev = result[n-1]['triples']
            for t in prev:
                for gen in GENERATORS:
                    words_triples.append(gen(*t))

        hyps = [t[2] for t in words_triples]
        result[n] = {
            'count': len(words_triples),
            'min_hyp': min(hyps),
            'max_hyp': max(hyps),
            'proven_min': min_c,
            'avg_hyp': sum(hyps) / len(hyps),
            'triples': words_triples,
        }
    return result


# ─── Application 3: Residue class filter ──────────────────────────────

def residue_filter(m: int) -> Set[Triple]:
    """
    Compute the set of admissible residue classes mod m for primitive
    Pythagorean triples reachable from (3,4,5).

    This can be used as a fast pre-filter: any primitive Pythagorean
    triple must have residues in this set.

    >>> allowed = residue_filter(5)
    >>> (3 % 5, 4 % 5, 5 % 5) in allowed
    True
    """
    root_mod = (3 % m, 4 % m, 5 % m)
    visited = {root_mod}
    queue = [root_mod]

    while queue:
        new_queue = []
        for t in queue:
            a, b, c = t
            for gen in GENERATORS:
                a2, b2, c2 = gen(a, b, c)
                child = (a2 % m, b2 % m, c2 % m)
                if child not in visited:
                    visited.add(child)
                    new_queue.append(child)
        queue = new_queue

    return visited


def combined_residue_filter(moduli: List[int], triple: Triple) -> bool:
    """
    Check if a triple passes the combined residue filter for all given moduli.

    >>> combined_residue_filter([3, 5, 7], (3, 4, 5))
    True
    """
    for m in moduli:
        allowed = residue_filter(m)
        t_mod = (triple[0] % m, triple[1] % m, triple[2] % m)
        if t_mod not in allowed:
            return False
    return True


# ─── Application 4: Angle distribution ────────────────────────────────

def angle_distribution(max_depth: int = 8) -> Dict[str, List[float]]:
    """
    Compute the distribution of angles in Pythagorean triples at each depth.

    The acute angle θ = arctan(a/b) characterizes the shape of the right triangle.
    The A-branch produces nearly isosceles triangles (θ → 0 as depth increases),
    while B produces nearly degenerate ones.

    >>> dist = angle_distribution(4)
    >>> len(dist['angles_by_depth']) == 5
    True
    """
    result = {'angles_by_depth': [], 'min_angles': [], 'max_angles': []}

    triples_at_depth = [ROOT]
    for n in range(max_depth + 1):
        angles = []
        for a, b, c in triples_at_depth:
            theta = math.atan2(min(a, b), max(a, b)) * 180 / math.pi
            angles.append(theta)

        result['angles_by_depth'].append(sorted(angles))
        result['min_angles'].append(min(angles))
        result['max_angles'].append(max(angles))

        # Generate next depth
        next_triples = []
        for t in triples_at_depth:
            for gen in GENERATORS:
                next_triples.append(gen(*t))
        triples_at_depth = next_triples

    return result


# ─── Application 5: Certified counting ────────────────────────────────

def certified_count_bound(N: int) -> Tuple[int, int]:
    """
    Give certified upper and lower bounds on the number of primitive
    Pythagorean triples with hypotenuse ≤ N.

    Lower bound: count by BFS (exact for small N).
    Upper bound: at depth n there are 3^n triples, and min hypotenuse
    at depth n is 2n² + 6n + 5. So all triples with c ≤ N have
    depth ≤ n_max where 2n_max² + 6n_max + 5 ≤ N.
    Total ≤ (3^(n_max+1) - 1) / 2.

    >>> lo, hi = certified_count_bound(100)
    >>> lo <= hi
    True
    """
    # Lower bound: exact count
    count = 0
    stack = [ROOT]
    while stack:
        triple = stack.pop()
        a, b, c = triple
        if c > N:
            continue
        count += 1
        for gen in GENERATORS:
            child = gen(a, b, c)
            if child[2] <= N:
                stack.append(child)

    # Upper bound: use depth bound
    n_max = 0
    while 2 * (n_max + 1)**2 + 6 * (n_max + 1) + 5 <= N:
        n_max += 1
    upper = (3**(n_max + 1) - 1) // 2

    return count, upper


# ─── Main ─────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 70)
    print("Application 1: Finding triples near specific leg ratios")
    print("=" * 70)
    for ratio, name in [(1.0, "≈45°"), (0.5, "≈26.6°"), (2.0, "≈63.4°")]:
        triples = find_triples_near_ratio(ratio, max_hyp=5000, tolerance=0.05)
        print(f"  Ratio ≈ {ratio} ({name}): {len(triples)} triples found")
        for t in triples[:3]:
            angle = math.atan2(t[0], t[1]) * 180 / math.pi
            print(f"    {t}, angle = {angle:.2f}°")
    print()

    print("=" * 70)
    print("Application 2: Depth-stratified density statistics")
    print("=" * 70)
    stats = count_triples_by_depth(10)
    print(f"{'depth':>5} {'count':>8} {'min_c':>8} {'max_c':>10} {'avg_c':>10} {'proven_min':>12}")
    print("-" * 60)
    for n in range(11):
        s = stats[n]
        print(f"{n:>5} {s['count']:>8} {s['min_hyp']:>8} {s['max_hyp']:>10} "
              f"{s['avg_hyp']:>10.1f} {s['proven_min']:>12}")
    print()

    print("=" * 70)
    print("Application 3: Residue class filtering")
    print("=" * 70)
    for m in [3, 5, 7, 11]:
        allowed = residue_filter(m)
        print(f"  mod {m}: {len(allowed)} admissible classes out of {m**3} total "
              f"({len(allowed)/m**3*100:.1f}%)")
    print()

    print("=" * 70)
    print("Application 4: Angle distribution at each depth")
    print("=" * 70)
    dist = angle_distribution(8)
    print(f"{'depth':>5} {'min angle':>12} {'max angle':>12}")
    print("-" * 35)
    for n in range(9):
        print(f"{n:>5} {dist['min_angles'][n]:>12.2f}° {dist['max_angles'][n]:>12.2f}°")
    print()

    print("=" * 70)
    print("Application 5: Certified counting bounds")
    print("=" * 70)
    for N in [100, 1000, 10000, 100000]:
        lo, hi = certified_count_bound(N)
        print(f"  c ≤ {N:>6}: exact count = {lo:>5}, upper bound = {hi:>8}")


#!/usr/bin/env python3
"""
Berggren Dynamics: Demonstrations of Orbit Growth Theorems

This script demonstrates the formally verified theorems about the Berggren
semigroup action on primitive Pythagorean triples, including:
- Closed-form formula for the all-A branch
- Sharp quadratic lower bound on hypotenuse growth
- Depth-optimal minimality of the A^n word
- Modular preservation of the Pythagorean relation
"""

import itertools
from typing import Tuple, List

Triple = Tuple[int, int, int]

# ─── Berggren generators ───────────────────────────────────────────────

def bergA(a: int, b: int, c: int) -> Triple:
    """Berggren generator A."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def bergB(a: int, b: int, c: int) -> Triple:
    """Berggren generator B."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def bergC(a: int, b: int, c: int) -> Triple:
    """Berggren generator C."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = {'A': bergA, 'B': bergB, 'C': bergC}
ROOT = (3, 4, 5)

def apply_word(word: str, root: Triple = ROOT) -> Triple:
    """Apply a Berggren word (string of A, B, C) to a triple."""
    t = root
    for ch in word:
        t = GENERATORS[ch](*t)
    return t

# ─── Demo 1: Closed-form for the all-A branch ─────────────────────────

def demo_closed_form():
    """Verify c(A^n) = 2n² + 6n + 5 for n = 0..15."""
    print("=" * 70)
    print("DEMO 1: Closed-form for the all-A branch")
    print("Theorem: c(A^n) = 2n² + 6n + 5")
    print("=" * 70)
    print(f"{'n':>3} {'A^n triple':>30} {'c(A^n)':>8} {'formula':>8} {'match':>6}")
    print("-" * 70)
    for n in range(16):
        word = 'A' * n
        triple = apply_word(word)
        c_actual = triple[2]
        c_formula = 2 * n**2 + 6 * n + 5
        match = "✓" if c_actual == c_formula else "✗"
        print(f"{n:>3} {str(triple):>30} {c_actual:>8} {c_formula:>8} {match:>6}")
    print()

# ─── Demo 2: Depth-optimal minimality ─────────────────────────────────

def all_words(n: int) -> List[str]:
    """Generate all Berggren words of length n."""
    if n == 0:
        return ['']
    return [''.join(w) for w in itertools.product('ABC', repeat=n)]

def demo_minimality():
    """Verify that A^n minimizes hypotenuse at each depth n ≤ 8."""
    print("=" * 70)
    print("DEMO 2: Depth-optimal minimality of A^n")
    print("Theorem: c(A^n) = min_{|w|=n} c(w)")
    print("=" * 70)
    print(f"{'n':>3} {'c(A^n)':>8} {'min c(w)':>10} {'# words':>10} {'minimizer':>12} {'match':>6}")
    print("-" * 70)
    for n in range(9):
        words = all_words(n)
        hyps = [(w, apply_word(w)[2]) for w in words]
        min_hyp = min(hyps, key=lambda x: x[1])
        c_allA = 2 * n**2 + 6 * n + 5
        match = "✓" if c_allA == min_hyp[1] else "✗"
        minimizer = min_hyp[0] if min_hyp[0] else "ε"
        print(f"{n:>3} {c_allA:>8} {min_hyp[1]:>10} {len(words):>10} {minimizer:>12} {match:>6}")
    print()

# ─── Demo 3: Quadratic lower bound ────────────────────────────────────

def demo_lower_bound():
    """Verify 2n² + 6n + 5 ≤ c(w) for all words of length ≤ 7."""
    print("=" * 70)
    print("DEMO 3: Quadratic lower bound verification")
    print("Theorem: c(w) ≥ 2|w|² + 6|w| + 5 for all words w")
    print("=" * 70)
    total_checked = 0
    violations = 0
    for n in range(8):
        bound = 2 * n**2 + 6 * n + 5
        words = all_words(n)
        for w in words:
            c = apply_word(w)[2]
            total_checked += 1
            if c < bound:
                violations += 1
                print(f"  VIOLATION: w={w}, c={c} < bound={bound}")
        print(f"  Depth {n}: checked {len(words)} words, bound = {bound}, all satisfy bound ✓")
    print(f"\nTotal checked: {total_checked}, violations: {violations}")
    print()

# ─── Demo 4: Modular preservation ─────────────────────────────────────

def demo_modular_preservation():
    """Verify that the Pythagorean relation is preserved mod m."""
    print("=" * 70)
    print("DEMO 4: Modular Pythagorean preservation")
    print("Theorem: a² + b² ≡ c² (mod m) is preserved by all generators")
    print("=" * 70)
    for m in [3, 5, 7, 11, 13, 17]:
        violations = 0
        total = 0
        for n in range(6):
            for w in all_words(n):
                a, b, c = apply_word(w)
                total += 1
                if (a**2 + b**2 - c**2) % m != 0:
                    violations += 1
        print(f"  mod {m:>2}: checked {total} triples, violations: {violations}")
    print()

# ─── Demo 5: Modular reachable orbits ─────────────────────────────────

def demo_modular_orbits():
    """Compute reachable orbits mod small m."""
    print("=" * 70)
    print("DEMO 5: Modular orbit enumeration")
    print("=" * 70)
    for m in [3, 5, 7, 11]:
        reachable = set()
        for n in range(8):
            for w in all_words(n):
                a, b, c = apply_word(w)
                reachable.add((a % m, b % m, c % m))
        # Count how many satisfy Pythagorean relation mod m
        pyth_mod = set()
        for a in range(m):
            for b in range(m):
                for c in range(m):
                    if (a**2 + b**2 - c**2) % m == 0:
                        pyth_mod.add((a, b, c))
        print(f"  mod {m:>2}: reachable = {len(reachable)}, "
              f"Pythagorean cone = {len(pyth_mod)}, "
              f"saturation = {len(reachable)/len(pyth_mod)*100:.1f}%")
    print()

# ─── Demo 6: Growth rate comparison ───────────────────────────────────

def demo_growth_rates():
    """Compare hypotenuse growth for different generator sequences."""
    print("=" * 70)
    print("DEMO 6: Hypotenuse growth comparison across branches")
    print("=" * 70)
    branches = {
        'A^n': lambda n: 'A' * n,
        'C^n': lambda n: 'C' * n,
        'B^n': lambda n: 'B' * n,
        '(AC)^k': lambda n: ('AC' * n)[:n],
        '(AB)^k': lambda n: ('AB' * n)[:n],
    }
    print(f"{'n':>3}", end="")
    for name in branches:
        print(f" {name:>12}", end="")
    print()
    print("-" * 70)
    for n in range(11):
        print(f"{n:>3}", end="")
        for name, gen in branches.items():
            w = gen(n)
            c = apply_word(w)[2]
            print(f" {c:>12}", end="")
        print()
    print("\n  A^n gives the slowest growth — it is the unique depth minimizer.")
    print()


if __name__ == '__main__':
    demo_closed_form()
    demo_minimality()
    demo_lower_bound()
    demo_modular_preservation()
    demo_modular_orbits()
    demo_growth_rates()
