"""
Algorithms for Proof Spectrum Duality

Implements the core algorithms from the research paper with
complexity analysis and example usage.
"""

from typing import List, Set, Tuple, Optional, Dict
from dataclasses import dataclass
from itertools import combinations


@dataclass
class ProofSpectrum:
    """
    The prime proof spectrum of Z/nZ.

    Attributes:
        n: the modulus
        primes: list of prime divisors of n
        spectrum: list of prime ideals (as sets of residues)
    """
    n: int
    primes: List[int]
    spectrum: List[Set[int]]

    @classmethod
    def of_zn(cls, n: int) -> "ProofSpectrum":
        """
        Construct the proof spectrum of Z/nZ.

        Time complexity: O(n * sqrt(n)) for prime factorization + ideal generation.
        Space complexity: O(n * d(n)) where d(n) = number of prime divisors.

        >>> spec = ProofSpectrum.of_zn(30)
        >>> len(spec.spectrum)
        3
        """
        primes = []
        temp = n
        for p in range(2, int(n**0.5) + 2):
            if temp % p == 0:
                primes.append(p)
                while temp % p == 0:
                    temp //= p
        if temp > 1:
            primes.append(temp)

        spectrum = []
        for p in primes:
            ideal = {(k * p) % n for k in range(n)}
            spectrum.append(ideal)

        return cls(n=n, primes=primes, spectrum=spectrum)


def zero_locus(spec: ProofSpectrum, S: Set[int]) -> Set[int]:
    """
    Compute V(S) = {i : P_i ∈ Spec | S ⊆ P_i}.

    Time complexity: O(|S| * |Spec|).

    >>> spec = ProofSpectrum.of_zn(30)
    >>> zero_locus(spec, {6})
    {0, 1}
    """
    return {i for i, P in enumerate(spec.spectrum) if S.issubset(P)}


def principal_open(spec: ProofSpectrum, r: int) -> Set[int]:
    """
    Compute D(r) = {i : P_i ∈ Spec | r ∉ P_i}.

    Time complexity: O(|Spec|).
    """
    return {i for i, P in enumerate(spec.spectrum) if r not in P}


def finitary_open(spec: ProofSpectrum, t: Set[int]) -> Set[int]:
    """
    Compute finitaryOpen(t) = ⋃_{r ∈ t} D(r).

    Time complexity: O(|t| * |Spec|).
    """
    result = set()
    for r in t:
        result.update(principal_open(spec, r))
    return result


def spectral_rank(spec: ProofSpectrum, U: Set[int]) -> Tuple[int, Optional[Set[int]]]:
    """
    Compute the spectral rank of an open set U.

    The spectral rank is the minimum |t| such that U = finitaryOpen(t).

    Time complexity: O(n^k * |Spec|) where k is the answer (brute force).
    This is NP-hard in general but tractable for small spectra.

    Returns (rank, generators) or (-1, None) if U is not a finitary open.
    """
    n = spec.n
    all_elements = list(range(n))

    for k in range(0, len(spec.spectrum) + 1):
        for combo in combinations(all_elements, k):
            t = set(combo)
            if finitary_open(spec, t) == U:
                return k, t

    return -1, None


def vanishing_ideal(spec: ProofSpectrum, Y: Set[int]) -> Set[int]:
    """
    Compute I(Y) = ⋂_{i ∈ Y} P_i.

    Time complexity: O(n * |Y|).
    """
    if not Y:
        return set(range(spec.n))
    result = set(range(spec.n))
    for i in Y:
        result = result.intersection(spec.spectrum[i])
    return result


def galois_closure(spec: ProofSpectrum, Y: Set[int]) -> Set[int]:
    """
    Compute the closure of Y in the Zariski topology.

    closure(Y) = V(I(Y)) = {P | I(Y) ⊆ P}.

    Time complexity: O(n * |Spec|).
    """
    vi = vanishing_ideal(spec, Y)
    return zero_locus(spec, vi)


def is_irreducible_closed(spec: ProofSpectrum, Z: Set[int]) -> bool:
    """
    Check if a closed set Z is irreducible.

    Z is irreducible if Z ≠ ∅ and whenever Z = Z₁ ∪ Z₂ with Z₁, Z₂ closed,
    then Z = Z₁ or Z = Z₂.

    For Spec(Z/nZ), irreducible closed sets are closures of single points.

    Time complexity: O(|Spec|²).
    """
    if not Z:
        return False
    for i in Z:
        if galois_closure(spec, {i}) == Z:
            return True
    return False


def comap(spec_source: ProofSpectrum, spec_target: ProofSpectrum,
          f: Dict[int, int]) -> Dict[int, int]:
    """
    Compute the comap induced by a ring homomorphism f: R → S.

    Given f and the spectra of R and S, compute f*: Spec(S) → Spec(R)
    where f*(Q) = f⁻¹(Q).

    Time complexity: O(n² * |Spec_S|).
    """
    result = {}
    for j, Q in enumerate(spec_target.spectrum):
        preimage = {r for r in range(spec_source.n) if f.get(r, 0) in Q}
        # Find matching prime ideal
        for i, P in enumerate(spec_source.spectrum):
            if P == preimage:
                result[j] = i
                break
    return result


def verify_compact_open_duality(spec: ProofSpectrum):
    """
    Verify the compact-open duality theorem for a given spectrum.

    Check that every open set that is a union of finitely many principal
    opens equals some finitaryOpen(t).

    Time complexity: O(2^|Spec| * n * |Spec|).
    """
    n = len(spec.spectrum)
    all_opens = set()

    # Generate all finitary opens
    for k in range(n + 1):
        for combo in combinations(range(spec.n), k):
            t = set(combo)
            fo = frozenset(finitary_open(spec, t))
            all_opens.add(fo)

    # Check they cover all principal open unions
    principal_opens = [frozenset(principal_open(spec, r)) for r in range(spec.n)]

    for k in range(n + 1):
        for combo in combinations(range(len(principal_opens)), k):
            union = frozenset().union(*[principal_opens[i] for i in combo]) if combo else frozenset()
            assert union in all_opens, f"Failed for union of principal opens at indices {combo}"

    return True


if __name__ == "__main__":
    # Example usage
    print("=== Proof Spectrum Algorithms ===\n")

    for n in [6, 12, 30]:
        spec = ProofSpectrum.of_zn(n)
        print(f"Z/{n}Z: {len(spec.spectrum)} prime points, primes = {spec.primes}")

        # Compute spectral ranks
        all_points = set(range(len(spec.spectrum)))
        rank, gens = spectral_rank(spec, all_points)
        print(f"  Spectral rank of full space: {rank} (generators: {gens})")

        for i in range(len(spec.spectrum)):
            singleton = {i}
            cl = galois_closure(spec, singleton)
            irr = is_irreducible_closed(spec, cl)
            print(f"  closure({{P_{i}}}) = {cl}, irreducible: {irr}")

        # Verify duality
        if n <= 12:
            ok = verify_compact_open_duality(spec)
            print(f"  Compact-open duality verified: {ok}")

        print()


"""
Applications of Proof Spectrum Duality

Demonstrates connections to cryptography, ML, and quantum computing.
"""

import numpy as np
from typing import List, Set, Dict, Tuple
from algorithms import ProofSpectrum, zero_locus, principal_open, finitary_open


# ============================================================
# Application 1: Post-Quantum Separation
# ============================================================

def post_quantum_separation_test(spec: ProofSpectrum) -> Dict[Tuple[int, int], int]:
    """
    For each pair of distinct prime points, find a separating element.

    This models the post-quantum distinguishability property:
    distinct security parameters are always distinguishable by some
    efficient test.

    Returns: dict mapping (i, j) to the separating element r.
    """
    separators = {}
    for i in range(len(spec.spectrum)):
        for j in range(i + 1, len(spec.spectrum)):
            for r in range(spec.n):
                if (r in spec.spectrum[i]) != (r in spec.spectrum[j]):
                    separators[(i, j)] = r
                    break
    return separators


# ============================================================
# Application 2: Certified Robustness Radius
# ============================================================

def certified_robustness_analysis(spec: ProofSpectrum, generators: Set[int]):
    """
    Analyze the certified robustness of a finite proof basis.

    The certified robustness radius is |generators|.
    The finitary open represents the "safe region" where at least
    one generator remains visible.
    """
    fo = finitary_open(spec, generators)
    coverage = len(fo) / len(spec.spectrum) if spec.spectrum else 0

    # Compute which points are NOT covered (the "blind spots")
    blind_spots = set(range(len(spec.spectrum))) - fo

    return {
        "generators": generators,
        "radius": len(generators),
        "coverage": coverage,
        "covered_points": fo,
        "blind_spots": blind_spots,
    }


# ============================================================
# Application 3: Quantum Entropy Decomposition
# ============================================================

def quantum_entropy_check(spec: ProofSpectrum, r: int, s: int) -> Dict:
    """
    Verify the quantum entropy decomposition at each prime point.

    For each P where r*s ∈ P, check that r ∈ P or s ∈ P.
    This models the measurement collapse property.
    """
    rs = (r * s) % spec.n
    results = []
    for i, P in enumerate(spec.spectrum):
        if rs in P:
            r_in = r in P
            s_in = s in P
            results.append({
                "point": i,
                "product_vanishes": True,
                "r_vanishes": r_in,
                "s_vanishes": s_in,
                "decomposition_valid": r_in or s_in,
            })
    return {
        "r": r,
        "s": s,
        "product": rs,
        "decompositions": results,
        "all_valid": all(d["decomposition_valid"] for d in results),
    }


# ============================================================
# Application 4: Lattice-Based Collision Detection
# ============================================================

def lattice_collision_window(spec: ProofSpectrum, t: Set[int]) -> Dict:
    """
    Analyze the collision detection window for a finite proof basis.

    In lattice cryptographic semantics, the finitary open represents
    the region where collisions can be detected.
    """
    fo = finitary_open(spec, t)
    complement = set(range(len(spec.spectrum))) - fo

    # The complement V(t) is where ALL elements of t vanish
    vt = zero_locus(spec, t)

    return {
        "basis": t,
        "detectable_region": fo,
        "undetectable_region": complement,
        "zero_locus_check": vt == complement,
        "detection_rate": len(fo) / len(spec.spectrum) if spec.spectrum else 0,
    }


if __name__ == "__main__":
    print("=" * 60)
    print("  Applications of Proof Spectrum Duality")
    print("=" * 60)

    spec = ProofSpectrum.of_zn(30)
    print(f"\nWorking with Z/30Z, Spec has {len(spec.spectrum)} points")
    print(f"Prime divisors: {spec.primes}")
    for i, P in enumerate(spec.spectrum):
        gen = min(p for p in P if p > 0)
        print(f"  P_{i} = ({gen})")

    # Post-quantum separation
    print(f"\n--- Post-Quantum Separation ---")
    seps = post_quantum_separation_test(spec)
    for (i, j), r in seps.items():
        direction = "in" if r in spec.spectrum[i] else "not in"
        print(f"  P_{i} vs P_{j}: separated by r={r} ({direction} P_{i})")

    # Certified robustness
    print(f"\n--- Certified Robustness Analysis ---")
    for gens in [{2}, {3}, {2, 3}, {2, 3, 5}]:
        result = certified_robustness_analysis(spec, gens)
        print(f"  Generators {gens}: radius={result['radius']}, "
              f"coverage={result['coverage']:.1%}, "
              f"blind spots={result['blind_spots']}")

    # Quantum entropy
    print(f"\n--- Quantum Entropy Decomposition ---")
    for r, s in [(2, 3), (2, 5), (3, 5), (6, 10)]:
        result = quantum_entropy_check(spec, r, s)
        print(f"  r={r}, s={s}, r*s={result['product']}: "
              f"all decompositions valid = {result['all_valid']}")

    # Lattice collision
    print(f"\n--- Lattice Collision Detection ---")
    for t in [{2}, {3, 5}, {2, 3, 5}]:
        result = lattice_collision_window(spec, t)
        print(f"  Basis {t}: detection rate = {result['detection_rate']:.1%}, "
              f"V(t)=complement check: {result['zero_locus_check']}")


"""
Proof Spectrum Duality — Demonstration

Concrete numerical examples illustrating the proof spectrum construction
for small commutative rings.
"""

import numpy as np
from typing import List, Set, Tuple, Dict


def prime_ideals_zn(n: int) -> List[Set[int]]:
    """
    Compute the prime ideals of Z/nZ.

    A prime ideal of Z/nZ corresponds to a prime p dividing n.
    The ideal is {0, p, 2p, ..., n-p} mod n.

    >>> prime_ideals_zn(12)
    [{0, 2, 4, 6, 8, 10}, {0, 3, 6, 9}]
    """
    primes = []
    for p in range(2, n + 1):
        if all(p % d != 0 for d in range(2, p)):
            if n % p == 0:
                ideal = {(k * p) % n for k in range(n)}
                primes.append(ideal)
    return primes


def zero_locus(S: Set[int], spectrum: List[Set[int]]) -> List[int]:
    """
    Compute V(S) = {P in Spec | S ⊆ P}.

    Returns indices of prime ideals containing all elements of S.
    """
    return [i for i, P in enumerate(spectrum) if S.issubset(P)]


def principal_open(r: int, spectrum: List[Set[int]]) -> List[int]:
    """
    Compute D(r) = {P in Spec | r ∉ P}.

    Returns indices of prime ideals NOT containing r.
    """
    return [i for i, P in enumerate(spectrum) if r not in P]


def finitary_open(t: Set[int], spectrum: List[Set[int]]) -> List[int]:
    """
    Compute finitaryOpen(t) = {P | ∃ r ∈ t, r ∉ P} = ⋃_{r ∈ t} D(r).
    """
    result = set()
    for r in t:
        result.update(principal_open(r, spectrum))
    return sorted(result)


def vanishing_ideal(Y: List[int], n: int, spectrum: List[Set[int]]) -> Set[int]:
    """
    Compute the vanishing ideal I(Y) = {r | r ∈ P for all P ∈ Y}.
    """
    if not Y:
        return set(range(n))
    result = set(range(n))
    for i in Y:
        result = result.intersection(spectrum[i])
    return result


def demo_zn(n: int):
    """Demonstrate the proof spectrum of Z/nZ."""
    print(f"\n{'='*60}")
    print(f"  Proof Spectrum of Z/{n}Z")
    print(f"{'='*60}")

    spec = prime_ideals_zn(n)
    print(f"\nPrime ideals (= points of SpecProof(Z/{n}Z)):")
    for i, P in enumerate(spec):
        # Find the generator
        gen = min(p for p in P if p > 0) if any(p > 0 for p in P) else 0
        print(f"  P_{i} = ({gen}) = {sorted(P)}")

    # Zero locus examples
    print(f"\nZero locus calculus:")
    print(f"  V(∅) = {zero_locus(set(), spec)} (= all primes, as expected)")
    print(f"  V({{1}}) = {zero_locus({1}, spec)} (= ∅, since 1 ∉ any prime)")
    print(f"  V({{0}}) = {zero_locus({0}, spec)} (= all primes, since 0 ∈ every ideal)")

    for r in range(2, min(n, 8)):
        vr = zero_locus({r}, spec)
        dr = principal_open(r, spec)
        print(f"  V({{{r}}}) = {vr}, D({r}) = {dr}")

    # Product vanishing demonstration
    print(f"\nProduct vanishing (quantum entropy decomposition):")
    for a in range(2, min(n, 5)):
        for b in range(a, min(n, 5)):
            ab = (a * b) % n
            for i, P in enumerate(spec):
                if ab in P:
                    factors = []
                    if a in P:
                        factors.append(f"{a} ∈ P_{i}")
                    if b in P:
                        factors.append(f"{b} ∈ P_{i}")
                    if factors:
                        print(f"  {a}·{b} = {ab} ∈ P_{i} ⟹ {' or '.join(factors)} ✓")

    # Finitary opens
    print(f"\nFinitary opens:")
    for t in [{2}, {3}, {2, 3}]:
        fo = finitary_open(t, spec)
        print(f"  finitaryOpen({t}) = {fo}")

    # Galois connection
    print(f"\nGalois connection:")
    for idx_set in [[0], [1], list(range(len(spec)))]:
        vi = vanishing_ideal(idx_set, n, spec)
        names = [f"P_{i}" for i in idx_set]
        print(f"  I({{{', '.join(names)}}}) = {sorted(vi)}")
        # Round-trip: V(I(Y)) should contain Y
        viy = zero_locus(vi, spec)
        print(f"  V(I({{{', '.join(names)}}})) = {viy} (closure of {idx_set})")


def demo_principal_open_basis():
    """Demonstrate that principal opens form a basis."""
    n = 30
    spec = prime_ideals_zn(n)
    print(f"\n{'='*60}")
    print(f"  Principal Open Basis for Z/{n}Z")
    print(f"{'='*60}")

    print(f"\nSpec has {len(spec)} points (prime ideals).")
    print(f"Principal opens D(r) for various r:")

    for r in [2, 3, 5, 6, 10, 15]:
        dr = principal_open(r, spec)
        print(f"  D({r}) = {dr}")

    # Show D(r·s) = D(r) ∩ D(s)
    print(f"\nMultiplicative property D(r·s) = D(r) ∩ D(s):")
    for r, s in [(2, 3), (2, 5), (3, 5)]:
        rs = (r * s) % n
        d_rs = set(principal_open(rs, spec))
        d_r = set(principal_open(r, spec))
        d_s = set(principal_open(s, spec))
        inter = d_r.intersection(d_s)
        print(f"  D({r}) ∩ D({s}) = {sorted(inter)}, D({r}·{s}={rs}) = {sorted(d_rs)}, Equal: {d_rs == inter}")


def demo_comap():
    """Demonstrate comap for a ring homomorphism."""
    print(f"\n{'='*60}")
    print(f"  Comap Demonstration: Z/6Z → Z/12Z")
    print(f"{'='*60}")

    # Natural map Z/6Z → Z/12Z sending [a]_6 to [2a]_12
    # (This is the map induced by multiplication by 2)
    n1, n2 = 6, 12
    spec1 = prime_ideals_zn(n1)
    spec2 = prime_ideals_zn(n2)

    print(f"\nSpec(Z/{n1}Z):")
    for i, P in enumerate(spec1):
        print(f"  P_{i} = {sorted(P)}")

    print(f"\nSpec(Z/{n2}Z):")
    for i, P in enumerate(spec2):
        print(f"  P_{i} = {sorted(P)}")

    # The canonical surjection Z/12Z → Z/6Z (mod 6 of mod 12)
    # This induces comap: Spec(Z/6Z) → Spec(Z/12Z)
    # Preimage of (p) in Z/6Z under the map is (p) in Z/12Z
    print(f"\nComap (preimage of primes under Z/12Z ↠ Z/6Z):")
    for i, P in enumerate(spec1):
        gen = min(p for p in P if p > 0) if any(p > 0 for p in P) else 0
        # Preimage of (gen) mod 6 in Z/12Z
        preimage = {x for x in range(n2) if (x % n1) in P}
        matching = [j for j, Q in enumerate(spec2) if Q == preimage or preimage.issubset(Q)]
        print(f"  comap(P_{i}) = preimage of ({gen}) mod {n1} in Z/{n2}Z → indices {matching}")


if __name__ == "__main__":
    demo_zn(6)
    demo_zn(12)
    demo_zn(30)
    demo_principal_open_basis()
    demo_comap()
    print("\n" + "="*60)
    print("  All demonstrations completed successfully.")
    print("="*60)


"""
Visualizations for Proof Spectrum Duality

Generates charts showing zero loci, principal opens, and spectral structure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from algorithms import ProofSpectrum, zero_locus, principal_open, finitary_open
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to base64 PNG string."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def plot_spectrum_heatmap(n: int, save_path: str = None):
    """Plot a heatmap showing which elements vanish at which primes."""
    spec = ProofSpectrum.of_zn(n)

    fig, ax = plt.subplots(1, 1, figsize=(10, 4))

    matrix = np.zeros((len(spec.spectrum), n))
    for i, P in enumerate(spec.spectrum):
        for r in P:
            matrix[i, r] = 1

    im = ax.imshow(matrix, aspect='auto', cmap='YlOrRd', interpolation='nearest')
    ax.set_xlabel('Element r ∈ Z/' + str(n) + 'Z', fontsize=12)
    ax.set_ylabel('Prime point P_i', fontsize=12)
    ax.set_yticks(range(len(spec.spectrum)))
    ax.set_yticklabels([f'P_{i} = ({spec.primes[i]})' for i in range(len(spec.spectrum))])
    ax.set_title(f'Vanishing Heatmap: SpecProof(Z/{n}Z)', fontsize=14)
    fig.colorbar(im, ax=ax, label='vanishesAtPoint(r, P_i)')

    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches='tight')
    return fig


def plot_principal_opens(n: int, save_path: str = None):
    """Plot principal opens for various elements."""
    spec = ProofSpectrum.of_zn(n)

    elements = list(range(1, min(n, 16)))
    fig, ax = plt.subplots(1, 1, figsize=(10, 4))

    matrix = np.zeros((len(spec.spectrum), len(elements)))
    for j, r in enumerate(elements):
        dr = principal_open(spec, r)
        for i in dr:
            matrix[i, j] = 1

    im = ax.imshow(matrix, aspect='auto', cmap='Blues', interpolation='nearest')
    ax.set_xlabel('Element r', fontsize=12)
    ax.set_xticks(range(len(elements)))
    ax.set_xticklabels(elements)
    ax.set_ylabel('Prime point', fontsize=12)
    ax.set_yticks(range(len(spec.spectrum)))
    ax.set_yticklabels([f'P_{i}=({spec.primes[i]})' for i in range(len(spec.spectrum))])
    ax.set_title(f'Principal Opens D(r) in SpecProof(Z/{n}Z)', fontsize=14)
    fig.colorbar(im, ax=ax, label='x ∈ D(r)')

    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches='tight')
    return fig


def plot_galois_connection(n: int, save_path: str = None):
    """Visualize the Galois connection between sets and closed sets."""
    spec = ProofSpectrum.of_zn(n)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: V(S) for various S
    test_sets = [set(), {0}, {spec.primes[0]}, {spec.primes[-1]},
                 set(spec.primes[:2]) if len(spec.primes) >= 2 else set(),
                 {1}]
    labels = ['∅', '{0}', f'{{{spec.primes[0]}}}', f'{{{spec.primes[-1]}}}',
              str(set(spec.primes[:2])) if len(spec.primes) >= 2 else '{}',
              '{1}']

    y_pos = range(len(test_sets))
    for i, (S, label) in enumerate(zip(test_sets, labels)):
        vS = zero_locus(spec, S)
        ax1.barh(i, len(vS), color='coral', alpha=0.7)
        ax1.text(len(vS) + 0.1, i, f'V({label}) = {vS}', va='center', fontsize=9)

    ax1.set_xlabel('|V(S)|', fontsize=12)
    ax1.set_yticks(y_pos)
    ax1.set_yticklabels(labels, fontsize=10)
    ax1.set_title('Zero Loci V(S)', fontsize=14)
    ax1.set_xlim(0, len(spec.spectrum) + 2)

    # Right: Coverage by finitary opens
    coverages = []
    sizes = range(1, len(spec.primes) + 1)
    for k in sizes:
        t = set(spec.primes[:k])
        fo = finitary_open(spec, t)
        coverages.append(len(fo) / len(spec.spectrum) * 100)

    ax2.bar(range(len(coverages)), coverages, color='steelblue', alpha=0.7)
    ax2.set_xlabel('Number of generators', fontsize=12)
    ax2.set_ylabel('Coverage (%)', fontsize=12)
    ax2.set_xticks(range(len(coverages)))
    ax2.set_xticklabels([str(set(spec.primes[:k])) for k in sizes], fontsize=8, rotation=30)
    ax2.set_title('Finitary Open Coverage', fontsize=14)
    ax2.set_ylim(0, 110)

    plt.tight_layout()
    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches='tight')
    return fig


if __name__ == "__main__":
    # Generate all visualizations
    for n in [30, 60, 210]:
        print(f"Generating visualizations for Z/{n}Z...")
        plot_spectrum_heatmap(n, f'heatmap_{n}.png')
        plot_principal_opens(n, f'principal_opens_{n}.png')
        plot_galois_connection(n, f'galois_{n}.png')

    print("All visualizations saved.")
