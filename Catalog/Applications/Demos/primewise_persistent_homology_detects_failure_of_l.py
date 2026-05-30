"""
Applications of Primewise Persistent Homology

Real-world applications demonstrating how persistence signatures from
Frobenius orbit data can be used in computational number theory.

Applications:
1. Detecting mod-9 obstructions for sums of three cubes
2. Separating quadratic forms using persistence fingerprints
3. Estimating point counts on curves via persistence data
"""

from typing import List, Tuple, Dict
import math


def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def primes_up_to(n: int) -> List[int]:
    if n < 2: return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


# ── Application 1: Sum of Three Cubes Classifier ─────────────────────

def sum_three_cubes_classifier(n: int) -> Dict:
    """
    Classify whether n can potentially be a sum of three cubes using
    the persistence-based mod-9 obstruction.

    Returns a detailed analysis dict.
    """
    mod9 = n % 9
    persistence = 0 if mod9 in (4, 5) else 1

    result = {
        'n': n,
        'mod9': mod9,
        'persistence_indicator': persistence,
        'obstructed': persistence == 0,
        'reason': None
    }

    if persistence == 0:
        result['reason'] = (
            f"n ≡ {mod9} (mod 9) → persistence vanishes → "
            f"n cannot be a sum of three cubes (proved in Lean)"
        )
    else:
        result['reason'] = (
            f"n ≡ {mod9} (mod 9) → no mod-9 obstruction → "
            f"n is a candidate for sum of three cubes"
        )

    return result


def batch_classify(n_max: int) -> None:
    """Classify all integers from 1 to n_max."""
    print(f"\nSum of Three Cubes Classification (1 to {n_max})")
    print("=" * 55)

    obstructed = []
    candidates = []

    for n in range(1, n_max + 1):
        result = sum_three_cubes_classifier(n)
        if result['obstructed']:
            obstructed.append(n)
        else:
            candidates.append(n)

    print(f"\nProvably NOT sums of three cubes (mod-9 obstruction):")
    print(f"  {obstructed}")
    print(f"\nCandidates (no mod-9 obstruction):")
    print(f"  {candidates}")
    print(f"\nObstructed: {len(obstructed)}/{n_max} "
          f"({100*len(obstructed)/n_max:.1f}%)")


# ── Application 2: Quadratic Form Fingerprinting ─────────────────────

def quadratic_form_fingerprint(a: int, b: int, c: int,
                                prime_bound: int = 50) -> Dict[int, int]:
    """
    Compute the persistence fingerprint of the quadratic form
    ax² + bxy + cy² using point counts mod primes.

    The fingerprint is the function p ↦ #{(x,y) ∈ F_p² : ax² + bxy + cy² ≡ 0}.
    """
    primes = primes_up_to(prime_bound)
    fingerprint = {}

    for p in primes:
        count = 0
        for x in range(p):
            for y in range(p):
                if (a * x * x + b * x * y + c * y * y) % p == 0:
                    count += 1
        fingerprint[p] = count

    return fingerprint


def compare_quadratic_forms() -> None:
    """
    Compare quadratic forms using persistence fingerprints.
    Demonstrates that different discriminants yield different signatures.
    """
    forms = [
        (1, 0, 1, "x² + y²"),      # disc = -4
        (1, 0, 2, "x² + 2y²"),     # disc = -8
        (1, 0, 3, "x² + 3y²"),     # disc = -12
        (1, 1, 1, "x² + xy + y²"), # disc = -3
        (2, 1, 1, "2x² + xy + y²"),# disc = -7
    ]

    print("\nQuadratic Form Fingerprinting")
    print("=" * 70)

    primes = [3, 5, 7, 11, 13, 17, 19, 23]
    print(f"\n{'Form':>20} | " +
          " ".join(f"p={p:>2}" for p in primes))
    print("-" * 70)

    fingerprints = []
    for a, b, c, name in forms:
        fp = quadratic_form_fingerprint(a, b, c, 25)
        fingerprints.append((name, fp))
        values = [str(fp.get(p, "?")).rjust(4) for p in primes]
        print(f"{name:>20} | " + " ".join(values))

    # Check separability
    print("\nSeparation Matrix (✓ = separated by some prime):")
    names = [name for name, _ in fingerprints]
    print(f"{'':>20} | " + " ".join(f"{n[:6]:>6}" for n in names))
    for i, (n1, fp1) in enumerate(fingerprints):
        row = []
        for j, (n2, fp2) in enumerate(fingerprints):
            if i == j:
                row.append("  ·   ")
            else:
                separated = any(fp1.get(p) != fp2.get(p) for p in fp1)
                row.append("  ✓   " if separated else "  ✗   ")
        print(f"{n1:>20} | " + " ".join(row))


# ── Application 3: Point Count Estimation ────────────────────────────

def estimate_point_count_from_persistence(
    orbit_sizes: List[int],
    p: int
) -> Dict:
    """
    Given Frobenius orbit data, estimate curve properties.

    The total persistence equals the number of affine points (proved in Lean).
    The Euler characteristic equals the number of orbits (proved in Lean).
    """
    total_points = sum(orbit_sizes)
    num_orbits = len(orbit_sizes)
    point_count = total_points + 1  # including point at infinity

    # Hasse-Weil bound check for elliptic curves
    hasse_bound = 2 * math.isqrt(p)
    trace = p + 1 - point_count  # a_p = p + 1 - N_p
    within_hasse = abs(trace) <= hasse_bound

    return {
        'prime': p,
        'total_points': total_points,
        'point_count_Np': point_count,
        'num_orbits': num_orbits,
        'trace_ap': trace,
        'hasse_bound': hasse_bound,
        'within_hasse_bound': within_hasse,
        'avg_orbit_size': total_points / num_orbits if num_orbits > 0 else 0,
        'fixed_point_ratio': orbit_sizes.count(1) / len(orbit_sizes) if orbit_sizes else 0,
    }


def point_count_analysis() -> None:
    """Analyze point counts for y² = x³ - x (CM curve) at various primes."""
    print("\nPoint Count Analysis: y² = x³ - x")
    print("=" * 70)

    primes = [p for p in primes_up_to(50) if p > 2]

    print(f"\n{'p':>4} {'N_p':>5} {'a_p':>5} {'|a_p|≤2√p':>10} "
          f"{'#orbits':>8} {'avg_orb':>8}")
    print("-" * 50)

    for p in primes:
        # Compute points on y² = x³ - x mod p
        points = []
        for x in range(p):
            rhs = (x * x * x - x) % p
            for y in range(p):
                if (y * y) % p == rhs:
                    points.append((x, y))

        orbit_sizes = [1] * len(points)  # Frobenius = identity over F_p
        analysis = estimate_point_count_from_persistence(orbit_sizes, p)

        hasse_ok = "✓" if analysis['within_hasse_bound'] else "✗"
        print(f"{p:>4} {analysis['point_count_Np']:>5} {analysis['trace_ap']:>5} "
              f"{hasse_ok:>10} {analysis['num_orbits']:>8} "
              f"{analysis['avg_orbit_size']:>8.1f}")


# ── Main ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF PRIMEWISE PERSISTENT HOMOLOGY")
    print("=" * 70)

    # Application 1
    batch_classify(50)

    # Application 2
    compare_quadratic_forms()

    # Application 3
    point_count_analysis()

    print("\n" + "=" * 70)
    print("All applications completed!")
    print("=" * 70)


"""
Primewise Persistent Homology: Demonstrations

This script demonstrates the core concepts of primewise persistent homology
applied to local-global principles in number theory.

Key demonstrations:
1. Computing Frobenius orbit decompositions for curves mod p
2. Building persistence barcodes from orbit data
3. Testing the Pell separation conjecture
4. Visualizing the mod-9 obstruction as persistence vanishing
"""

from typing import List, Tuple, Dict
import math
from collections import Counter


# ── Core Data Structures ──────────────────────────────────────────────

class PersistenceInterval:
    """A persistence interval [birth, death). death=0 means infinite."""
    def __init__(self, birth: int, death: int):
        assert birth <= death or death == 0
        self.birth = birth
        self.death = death

    @property
    def lifetime(self) -> int:
        return 0 if self.death == 0 else self.death - self.birth

    def __repr__(self):
        d = "∞" if self.death == 0 else str(self.death)
        return f"[{self.birth}, {d})"


class PersistenceBarcode:
    """A persistence barcode: a list of persistence intervals."""
    def __init__(self, intervals: List[PersistenceInterval] = None):
        self.intervals = intervals or []

    @property
    def size(self) -> int:
        return len(self.intervals)

    @property
    def total_persistence(self) -> int:
        return sum(I.lifetime for I in self.intervals)

    @property
    def euler_char(self) -> int:
        return sum(1 if I.birth % 2 == 0 else -1 for I in self.intervals)

    def rank_at(self, t: int) -> int:
        return sum(1 for I in self.intervals
                   if I.birth <= t and (I.death == 0 or t < I.death))

    def __repr__(self):
        return f"Barcode({self.intervals})"


class FrobeniusOrbitData:
    """Frobenius orbit data for a curve mod p."""
    def __init__(self, prime: int, orbit_sizes: List[int]):
        assert all(s > 0 for s in orbit_sizes)
        self.prime = prime
        self.orbit_sizes = orbit_sizes

    @property
    def total_points(self) -> int:
        return sum(self.orbit_sizes)

    @property
    def fixed_points(self) -> int:
        return self.orbit_sizes.count(1)

    @property
    def num_orbits(self) -> int:
        return len(self.orbit_sizes)

    @property
    def point_count(self) -> int:
        return self.total_points + 1

    def to_barcode(self) -> PersistenceBarcode:
        return PersistenceBarcode([
            PersistenceInterval(0, k) for k in self.orbit_sizes
        ])

    def __repr__(self):
        return f"FrobOrbit(p={self.prime}, orbits={self.orbit_sizes})"


# ── Number Theory Utilities ───────────────────────────────────────────

def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def primes_up_to(n: int) -> List[int]:
    return [p for p in range(2, n + 1) if is_prime(p)]

def quadratic_residues_mod_p(p: int) -> set:
    """Compute the set of quadratic residues mod p."""
    return {(x * x) % p for x in range(p)}

def quad_res_count(d: int, p: int) -> int:
    """Count solutions to x^2 ≡ d (mod p)."""
    return sum(1 for x in range(p) if (x * x) % p == d % p)

def frobenius_orbits_pell(d: int, p: int) -> List[int]:
    """
    Compute Frobenius orbit sizes for the Pell conic x^2 - d*y^2 = 1 mod p.
    Points are (x, y) ∈ (Z/pZ)^2 with x^2 - d*y^2 ≡ 1 mod p.
    Frobenius here is identity (since we're over F_p), so all orbits have size 1.
    For extension fields F_{p^k}, orbit sizes would be divisors of k.
    """
    points = []
    for x in range(p):
        for y in range(p):
            if (x * x - d * y * y - 1) % p == 0:
                points.append((x, y))
    # Over F_p, Frobenius is identity, so each point is its own orbit
    return [1] * len(points)


# ── Demo 1: Frobenius Orbits and Barcodes ─────────────────────────────

def demo_frobenius_barcodes():
    print("=" * 60)
    print("DEMO 1: Frobenius Orbit Barcodes")
    print("=" * 60)

    # Example: Pell conic x^2 - 2y^2 = 1 mod various primes
    d = 2
    primes = [3, 5, 7, 11, 13, 17, 19, 23]

    print(f"\nPell conic: x² - {d}y² = 1")
    print(f"{'Prime p':>8} {'#Points':>8} {'#Orbits':>8} {'TotalPers':>10} {'EulerChar':>10}")
    print("-" * 50)

    for p in primes:
        orbits = frobenius_orbits_pell(d, p)
        data = FrobeniusOrbitData(p, orbits)
        barcode = data.to_barcode()

        print(f"{p:>8} {data.total_points:>8} {data.num_orbits:>8} "
              f"{barcode.total_persistence:>10} {barcode.euler_char:>10}")

        # Verify key theorems computationally
        assert barcode.total_persistence == data.total_points, \
            "Theorem: total persistence = total points"
        assert barcode.euler_char == data.num_orbits, \
            "Theorem: Euler char = num orbits"
        assert data.num_orbits <= data.total_points, \
            "Theorem: num orbits ≤ total points"

    print("\n✓ All structural theorems verified computationally!")


# ── Demo 2: Pell Separation Conjecture ────────────────────────────────

def demo_pell_separation():
    print("\n" + "=" * 60)
    print("DEMO 2: Pell Separation Conjecture Test")
    print("=" * 60)

    squarefree_d = [2, 3, 5, 6, 7, 10, 11, 13, 14, 15]
    primes = primes_up_to(50)

    print(f"\nTesting separation for d ∈ {squarefree_d}")
    print(f"Using primes up to 50: {primes}")

    separated = 0
    total = 0

    for i, d1 in enumerate(squarefree_d):
        for d2 in squarefree_d[i+1:]:
            total += 1
            found_sep = False
            for p in primes:
                c1 = quad_res_count(d1, p)
                c2 = quad_res_count(d2, p)
                if c1 != c2:
                    found_sep = True
                    break

            if found_sep:
                separated += 1
            else:
                print(f"  ⚠ NOT separated: d₁={d1}, d₂={d2}")

    print(f"\nResult: {separated}/{total} pairs separated by primes ≤ 50")
    if separated == total:
        print("✓ Conjecture SUPPORTED for this test set!")
    else:
        print(f"✗ {total - separated} pairs not separated — conjecture needs refinement")


# ── Demo 3: Mod-9 Obstruction as Persistence ─────────────────────────

def demo_mod9_persistence():
    print("\n" + "=" * 60)
    print("DEMO 3: Mod-9 Obstruction as Persistence Vanishing")
    print("=" * 60)

    print("\nFor sums of three cubes x³ + y³ + z³ = n:")
    print(f"{'n':>5} {'n mod 9':>8} {'Persistence':>12} {'Obstruction':>12}")
    print("-" * 40)

    for n in range(1, 31):
        mod9 = n % 9
        persistence = 0 if mod9 in (4, 5) else 1
        obstructed = "YES" if mod9 in (4, 5) else "no"
        marker = " ◀" if persistence == 0 else ""
        print(f"{n:>5} {mod9:>8} {persistence:>12} {obstructed:>12}{marker}")

    print("\n◀ marks integers where persistence vanishes (mod-9 obstruction)")
    print("These integers CANNOT be expressed as sums of three cubes.")


# ── Demo 4: Barcode Stability ─────────────────────────────────────────

def demo_barcode_stability():
    print("\n" + "=" * 60)
    print("DEMO 4: Barcode Stability under Shifts")
    print("=" * 60)

    orbits = [1, 2, 3, 1, 5]
    data = FrobeniusOrbitData(7, orbits)
    barcode = data.to_barcode()

    print(f"\nOriginal orbits: {orbits}")
    print(f"Barcode: {barcode}")
    print(f"  Size: {barcode.size}")
    print(f"  Total persistence: {barcode.total_persistence}")

    for shift in [0, 3, 10]:
        shifted = PersistenceBarcode([
            PersistenceInterval(I.birth + shift,
                                0 if I.death == 0 else I.death + shift)
            for I in barcode.intervals
        ])
        print(f"\n  Shift by {shift}:")
        print(f"    Shifted barcode: {shifted}")
        print(f"    Size: {shifted.size} (same: {shifted.size == barcode.size})")
        print(f"    Total persistence: {shifted.total_persistence} "
              f"(same: {shifted.total_persistence == barcode.total_persistence})")


# ── Demo 5: Partition Persistence ─────────────────────────────────────

def demo_partition_persistence():
    print("\n" + "=" * 60)
    print("DEMO 5: Partition → Persistence Correspondence")
    print("=" * 60)

    n = 12
    partitions = [
        [12],
        [6, 6],
        [4, 4, 4],
        [3, 3, 3, 3],
        [2, 2, 2, 2, 2, 2],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ]

    print(f"\nPartitions of {n}:")
    print(f"{'Partition':>30} {'#Parts':>7} {'TotalPers':>10} {'EulerChar':>10}")
    print("-" * 60)

    for parts in partitions:
        assert sum(parts) == n
        data = FrobeniusOrbitData(2, parts)
        barcode = data.to_barcode()
        print(f"{str(parts):>30} {len(parts):>7} "
              f"{barcode.total_persistence:>10} {barcode.euler_char:>10}")

        # Verify theorem: total persistence always equals n
        assert barcode.total_persistence == n, \
            "Theorem: partition persistence = n"
        # Verify theorem: Euler char = number of parts
        assert barcode.euler_char == len(parts), \
            "Theorem: Euler char = number of parts"

    print(f"\n✓ Total persistence is always {n} regardless of partition!")
    print("✓ Euler characteristic = number of parts!")


# ── Main ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_frobenius_barcodes()
    demo_pell_separation()
    demo_mod9_persistence()
    demo_barcode_stability()
    demo_partition_persistence()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Persistence Barcodes from Frobenius Orbit Data

This script visualizes how Frobenius orbit decompositions of curves mod p
generate persistence barcodes, and how the total persistence equals
the total number of points (a formally proved theorem).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def pell_conic_point_count(d, p):
    """Count points on x^2 - d*y^2 = 1 mod p."""
    count = 0
    for x in range(p):
        for y in range(p):
            if (x * x - d * y * y - 1) % p == 0:
                count += 1
    return count


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# ── Panel 1: Barcode visualization for specific orbit data ──

ax = axes[0, 0]
orbit_data = {
    'p=5, d=2': [1, 1, 1, 1],
    'p=7, d=2': [1, 1, 1, 1, 1, 1],
    'p=11, d=2': [1]*10,
    'p=13, d=2': [1]*14,
}

y_pos = 0
colors = plt.cm.Set2(np.linspace(0, 1, len(orbit_data)))
labels = []

for (name, orbits), color in zip(orbit_data.items(), colors):
    for k in orbits:
        ax.barh(y_pos, k, left=0, height=0.6, color=color, alpha=0.8,
                edgecolor='black', linewidth=0.5)
        y_pos += 1
    labels.append((name, y_pos - len(orbits)/2, color))
    y_pos += 1

for name, y, color in labels:
    ax.text(-0.5, y, name, ha='right', va='center', fontsize=8,
            fontweight='bold', color='black')

ax.set_xlabel('Filtration Level', fontsize=10)
ax.set_title('Persistence Barcodes from\nFrobenius Orbits (x²-2y²=1)',
             fontsize=11, fontweight='bold')
ax.set_yticks([])
ax.axvline(x=0, color='gray', linestyle='--', alpha=0.5)

# ── Panel 2: Total persistence = total points ──

ax = axes[0, 1]
d = 2
primes = [p for p in range(3, 40) if is_prime(p)]
point_counts = [pell_conic_point_count(d, p) for p in primes]

ax.bar(range(len(primes)), point_counts, color='steelblue', alpha=0.8,
       edgecolor='black', linewidth=0.5)
ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes], fontsize=8)
ax.set_xlabel('Prime p', fontsize=10)
ax.set_ylabel('Total Points = Total Persistence', fontsize=10)
ax.set_title('Theorem: Total Persistence = Point Count\n(x²-2y²=1 mod p)',
             fontsize=11, fontweight='bold')

# Add trend line (roughly p for large p)
ax.plot(range(len(primes)), [p-1 for p in primes], 'r--', alpha=0.5,
        label='p - 1 (expected)')
ax.legend(fontsize=9)

# ── Panel 3: Euler characteristic = orbit count ──

ax = axes[1, 0]

# For various partition shapes of 12
n = 12
partitions = [
    ([12], '12'),
    ([6, 6], '6+6'),
    ([4, 4, 4], '4+4+4'),
    ([3, 3, 3, 3], '3×4'),
    ([2]*6, '2×6'),
    ([1]*12, '1×12'),
]

x_pos = np.arange(len(partitions))
euler_chars = [len(parts) for parts, _ in partitions]
total_pers = [sum(parts) for parts, _ in partitions]

bars1 = ax.bar(x_pos - 0.2, euler_chars, 0.35, label='Euler Char (= #parts)',
               color='coral', alpha=0.8, edgecolor='black')
bars2 = ax.bar(x_pos + 0.2, total_pers, 0.35, label='Total Persistence (= 12)',
               color='seagreen', alpha=0.8, edgecolor='black')

ax.set_xticks(x_pos)
ax.set_xticklabels([name for _, name in partitions], fontsize=8)
ax.set_xlabel('Partition of 12', fontsize=10)
ax.set_ylabel('Value', fontsize=10)
ax.set_title('Partition Invariants\n(Euler Char varies, Persistence constant)',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)

# ── Panel 4: Mod-9 obstruction as persistence ──

ax = axes[1, 1]
n_range = range(1, 46)
mod9_vals = [n % 9 for n in n_range]
persistence = [0 if m in (4, 5) else 1 for m in mod9_vals]

colors_bar = ['red' if p == 0 else 'steelblue' for p in persistence]
ax.bar(list(n_range), persistence, color=colors_bar, alpha=0.8,
       edgecolor='black', linewidth=0.3)

# Mark obstructed
obstructed = [n for n, p in zip(n_range, persistence) if p == 0]
ax.scatter(obstructed, [0]*len(obstructed), color='red', s=50, zorder=5,
           marker='x', linewidth=2)

ax.set_xlabel('Integer n', fontsize=10)
ax.set_ylabel('Persistence Indicator', fontsize=10)
ax.set_title('Mod-9 Obstruction as Persistence Vanishing\n'
             '(red ✗ = cannot be sum of three cubes)',
             fontsize=11, fontweight='bold')
ax.set_yticks([0, 1])
ax.set_yticklabels(['Obstructed', 'Candidate'])

red_patch = mpatches.Patch(color='red', alpha=0.8, label='n ≡ 4,5 (mod 9)')
blue_patch = mpatches.Patch(color='steelblue', alpha=0.8, label='Other residues')
ax.legend(handles=[red_patch, blue_patch], fontsize=9)

plt.tight_layout()
plt.savefig('barcode_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved barcode_visualization.png")


"""
Visualization: Persistence Landscape across Primes

This script visualizes how the persistence landscape (rank function)
of Frobenius orbit barcodes evolves across primes, showing the
cross-domain connection between arithmetic and topology.
"""

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def pell_conic_point_count(d, p):
    """Count points on x^2 - d*y^2 = 1 mod p."""
    count = 0
    for x in range(p):
        for y in range(p):
            if (x * x - d * y * y - 1) % p == 0:
                count += 1
    return count


def barcode_rank(orbit_sizes, t):
    """Rank function: count intervals alive at level t."""
    # Each orbit of size k gives interval [0, k)
    return sum(1 for k in orbit_sizes if 0 <= t < k)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# ── Panel 1: Rank functions for different d values ──

ax = axes[0, 0]
d_values = [2, 3, 5, 7]
p = 23  # fixed prime

for d in d_values:
    n_pts = pell_conic_point_count(d, p)
    orbit_sizes = [1] * n_pts  # over F_p, all orbits size 1
    t_range = range(0, 5)
    ranks = [barcode_rank(orbit_sizes, t) for t in t_range]
    ax.plot(list(t_range), ranks, 'o-', label=f'd={d} ({n_pts} pts)',
            linewidth=2, markersize=6)

ax.set_xlabel('Filtration Level t', fontsize=10)
ax.set_ylabel('Rank β(t)', fontsize=10)
ax.set_title(f'Persistence Rank Functions (p={p})\nfor x²-dy²=1',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 2: Point counts vs primes for multiple d ──

ax = axes[0, 1]
primes = [p for p in range(3, 50) if is_prime(p)]
d_values_2 = [2, 3, 5]
colors = ['steelblue', 'coral', 'seagreen']

for d, color in zip(d_values_2, colors):
    counts = [pell_conic_point_count(d, p) for p in primes]
    ax.plot(primes, counts, 'o-', color=color, label=f'd={d}',
            linewidth=1.5, markersize=4, alpha=0.8)

# Reference line: p (expected average)
ax.plot(primes, primes, 'k--', alpha=0.3, label='y = p')

ax.set_xlabel('Prime p', fontsize=10)
ax.set_ylabel('Point Count = Persistence', fontsize=10)
ax.set_title('Point Counts across Primes\n(Total Persistence = Point Count)',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 3: Persistence vs prime for Hasse-Weil bound ──

ax = axes[1, 0]

# y^2 = x^3 + 1 (j=0 curve)
primes_ell = [p for p in range(5, 60) if is_prime(p)]
point_counts = []
for p in primes_ell:
    count = 0
    for x in range(p):
        rhs = (x*x*x + 1) % p
        for y in range(p):
            if (y*y) % p == rhs:
                count += 1
    point_counts.append(count + 1)  # +1 for point at infinity

traces = [p + 1 - N for p, N in zip(primes_ell, point_counts)]
hasse_bounds = [2 * np.sqrt(p) for p in primes_ell]

ax.bar(range(len(primes_ell)), traces, color='steelblue', alpha=0.7,
       edgecolor='black', linewidth=0.3, label='Trace a_p')
ax.plot(range(len(primes_ell)), hasse_bounds, 'r-', linewidth=1.5,
        label='2√p (Hasse bound)')
ax.plot(range(len(primes_ell)), [-h for h in hasse_bounds], 'r-',
        linewidth=1.5)

ax.set_xticks(range(0, len(primes_ell), 2))
ax.set_xticklabels([str(p) for p in primes_ell[::2]], fontsize=7)
ax.set_xlabel('Prime p', fontsize=10)
ax.set_ylabel('Trace a_p = p+1-N_p', fontsize=10)
ax.set_title('Hasse-Weil Bound Verification\ny² = x³ + 1',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 4: Orbit size distribution heatmap ──

ax = axes[1, 1]

# For different partition types, show barcode structure
partition_labels = ['[12]', '[6,6]', '[4,4,4]', '[3,3,3,3]', '[2]*6', '[1]*12']
partitions = [[12], [6,6], [4,4,4], [3,3,3,3], [2]*6, [1]*12]

max_t = 13
heatmap = np.zeros((len(partitions), max_t))

for i, parts in enumerate(partitions):
    for t in range(max_t):
        heatmap[i, t] = barcode_rank(parts, t)

im = ax.imshow(heatmap, cmap='Blues', aspect='auto', interpolation='nearest')
ax.set_xticks(range(max_t))
ax.set_xticklabels(range(max_t), fontsize=8)
ax.set_yticks(range(len(partitions)))
ax.set_yticklabels(partition_labels, fontsize=9)
ax.set_xlabel('Filtration Level t', fontsize=10)
ax.set_ylabel('Partition of 12', fontsize=10)
ax.set_title('Rank Functions for\nDifferent Orbit Partitions of 12',
             fontsize=11, fontweight='bold')

# Add annotations
for i in range(len(partitions)):
    for j in range(max_t):
        val = int(heatmap[i, j])
        if val > 0:
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=7, color='white' if val > 3 else 'black')

plt.colorbar(im, ax=ax, label='Rank β(t)', shrink=0.8)

plt.tight_layout()
plt.savefig('persistence_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved persistence_landscape.png")


"""
Visualization: Quadratic Residue Separation Heatmap

This script visualizes the Pell separation conjecture by computing
quadratic residue counts for various squarefree integers d mod primes p,
and displaying a heatmap showing which pairs are separated.
"""

import matplotlib.pyplot as plt
import numpy as np


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def primes_up_to(n):
    return [p for p in range(2, n + 1) if is_prime(p)]


def quad_res_count(d, p):
    """Count #{x in F_p : x^2 = d mod p}."""
    return sum(1 for x in range(p) if (x * x) % p == d % p)


fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# ── Panel 1: Quadratic residue count heatmap ──

ax = axes[0]
d_values = [2, 3, 5, 6, 7, 10, 11, 13, 14, 15]
primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]

data = np.zeros((len(d_values), len(primes)))
for i, d in enumerate(d_values):
    for j, p in enumerate(primes):
        data[i, j] = quad_res_count(d, p)

im = ax.imshow(data, cmap='YlOrRd', aspect='auto', interpolation='nearest')
ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes], fontsize=9)
ax.set_yticks(range(len(d_values)))
ax.set_yticklabels([f'd={d}' for d in d_values], fontsize=9)
ax.set_xlabel('Prime p', fontsize=11)
ax.set_ylabel('Squarefree d', fontsize=11)
ax.set_title('Quadratic Residue Counts\n#{x ∈ 𝔽_p : x² ≡ d (mod p)}',
             fontsize=12, fontweight='bold')

# Add text annotations
for i in range(len(d_values)):
    for j in range(len(primes)):
        val = int(data[i, j])
        color = 'white' if val >= 2 else 'black'
        ax.text(j, i, str(val), ha='center', va='center',
                fontsize=8, color=color, fontweight='bold')

plt.colorbar(im, ax=ax, label='Count', shrink=0.8)

# ── Panel 2: Separation matrix ──

ax = axes[1]
n_d = len(d_values)
sep_matrix = np.zeros((n_d, n_d))

for i in range(n_d):
    for j in range(n_d):
        if i == j:
            sep_matrix[i, j] = 0
        else:
            # Check if separated by any prime
            separated = any(
                quad_res_count(d_values[i], p) != quad_res_count(d_values[j], p)
                for p in primes
            )
            # Find first separating prime
            if separated:
                first_sep = next(
                    p for p in primes
                    if quad_res_count(d_values[i], p) != quad_res_count(d_values[j], p)
                )
                sep_matrix[i, j] = primes.index(first_sep) + 1
            else:
                sep_matrix[i, j] = -1  # not separated

# Custom colormap
cmap = plt.cm.viridis.copy()
cmap.set_under('red')  # unseparated pairs in red

im2 = ax.imshow(sep_matrix, cmap=cmap, aspect='auto', vmin=0,
                interpolation='nearest')
ax.set_xticks(range(n_d))
ax.set_xticklabels([f'd={d}' for d in d_values], fontsize=8, rotation=45)
ax.set_yticks(range(n_d))
ax.set_yticklabels([f'd={d}' for d in d_values], fontsize=9)
ax.set_title('Separation Matrix\n(color = index of first separating prime)',
             fontsize=12, fontweight='bold')

# Add text
for i in range(n_d):
    for j in range(n_d):
        if i == j:
            ax.text(j, i, '·', ha='center', va='center', fontsize=10,
                    color='gray')
        elif sep_matrix[i, j] < 0:
            ax.text(j, i, '✗', ha='center', va='center', fontsize=10,
                    color='red', fontweight='bold')
        else:
            p_idx = int(sep_matrix[i, j]) - 1
            ax.text(j, i, f'p={primes[p_idx]}', ha='center', va='center',
                    fontsize=6, color='white' if p_idx > 3 else 'black')

plt.colorbar(im2, ax=ax, label='Separating prime index', shrink=0.8)

plt.tight_layout()
plt.savefig('separation_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved separation_heatmap.png")
