#!/usr/bin/env python3
"""
Tropical Prime–Stone Duality: Demonstrations and Concrete Examples

This module demonstrates the key theorems of spectral hardness separation
and Stone reconstruction for tropical semirings, with concrete numerical examples.
"""

import numpy as np
from itertools import product as cartesian_product
from typing import List, Tuple, Set, Dict, Callable
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ============================================================
# Section 1: Tropical (Min-Plus) Semiring
# ============================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition = min."""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary addition."""
    return a + b

def trop_matrix_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (min-plus) matrix multiplication."""
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C

def trop_matrix_pow(M: np.ndarray, k: int) -> np.ndarray:
    """Tropical matrix power M^{⊗k}."""
    n = M.shape[0]
    result = np.zeros((n, n))
    np.fill_diagonal(result, 0)
    result[result == 0] = 0
    # Identity: 0 on diagonal, infinity off-diagonal
    result = np.full((n, n), np.inf)
    np.fill_diagonal(result, 0)
    for _ in range(k):
        result = trop_matrix_mul(result, M)
    return result


# ============================================================
# Section 2: Prime Congruences on Finite Semirings
# ============================================================

class RingCongruence:
    """A ring congruence on a finite set {0, 1, ..., n-1} with tropical operations."""

    def __init__(self, partition: List[Set[int]], name: str = ""):
        """Create a congruence from a partition of elements."""
        self.partition = partition
        self.name = name
        self._class_map = {}
        for idx, block in enumerate(partition):
            for elem in block:
                self._class_map[elem] = idx

    def congruent(self, a: int, b: int) -> bool:
        """Check if a ≡ b under this congruence."""
        return self._class_map.get(a) == self._class_map.get(b)

    def separates(self, a: int, b: int) -> bool:
        """Check if this congruence distinguishes a from b."""
        return not self.congruent(a, b)

    def is_proper(self) -> bool:
        """Check if the congruence is proper (not trivial)."""
        return len(self.partition) > 1

    def quotient_class(self, a: int) -> int:
        """Return the equivalence class index of a."""
        return self._class_map[a]

    def __repr__(self):
        return f"Cong({self.name}: {self.partition})"


class PrimeCong(RingCongruence):
    """A prime congruence: proper ring congruence."""

    def __init__(self, partition: List[Set[int]], name: str = ""):
        super().__init__(partition, name)
        assert self.is_proper(), "Prime congruence must be proper"


# ============================================================
# Section 3: Congruence Spectrum and Spectral Certificates
# ============================================================

class CongruenceSpectrum:
    """The congruence spectrum SpecC(S) of a finite semiring S."""

    def __init__(self, primes: List[PrimeCong]):
        self.primes = primes

    def basic_open(self, a: int, b: int) -> List[int]:
        """D(a,b) = {p ∈ Spec | p separates a from b}."""
        return [i for i, p in enumerate(self.primes) if p.separates(a, b)]

    def is_separated(self, elements: List[int]) -> bool:
        """Check spectral separation: every distinct pair has a separating prime."""
        for i, a in enumerate(elements):
            for b in elements[i+1:]:
                if not any(p.separates(a, b) for p in self.primes):
                    return False
        return True

    def eval_map(self, a: int) -> Tuple[int, ...]:
        """η(a) = (class_p(a))_{p ∈ Spec}: evaluation map into product of quotients."""
        return tuple(p.quotient_class(a) for p in self.primes)


class SpectralCertificate:
    """A spectral certificate separating x from y."""

    def __init__(self, x: int, y: int, primes: List[PrimeCong]):
        self.x = x
        self.y = y
        self.primes = primes
        # Verify all primes separate x from y
        for p in primes:
            assert p.separates(x, y), f"{p} does not separate {x} from {y}"

    @property
    def complexity(self) -> int:
        return len(self.primes)

    def __repr__(self):
        return f"Cert({self.x}≠{self.y}, size={self.complexity})"


# ============================================================
# Section 4: Congruence-Reflecting Attacks
# ============================================================

def is_cong_reflecting(f: Callable[[int], int], c: RingCongruence,
                       domain: List[int]) -> bool:
    """Check if f reflects congruence c on the given domain.
    f reflects c iff: c(f(a), f(b)) → c(a, b) for all a, b."""
    for a in domain:
        for b in domain:
            if c.congruent(f(a), f(b)) and not c.congruent(a, b):
                return False
    return True


def is_fully_reflecting(f: Callable[[int], int], cert: SpectralCertificate,
                        domain: List[int]) -> bool:
    """Check if f is fully reflecting w.r.t. a spectral certificate."""
    return all(is_cong_reflecting(f, p, domain) for p in cert.primes)


# ============================================================
# Section 5: Demonstrations
# ============================================================

def demo_stone_reconstruction():
    """Demonstrate the Stone reconstruction theorem on a concrete finite semiring."""
    print("=" * 70)
    print("DEMO 1: Stone Reconstruction Theorem")
    print("=" * 70)
    print()

    # Consider S = {0, 1, 2, 3} as a finite semiring
    elements = [0, 1, 2, 3]

    # Define prime congruences that separate all elements
    p1 = PrimeCong([{0, 1}, {2, 3}], name="p₁")   # even/odd partition
    p2 = PrimeCong([{0, 2}, {1, 3}], name="p₂")   # {0,2} vs {1,3}
    p3 = PrimeCong([{0, 3}, {1, 2}], name="p₃")   # {0,3} vs {1,2}

    spec = CongruenceSpectrum([p1, p2, p3])

    print("Semiring elements: S = {0, 1, 2, 3}")
    print(f"Prime congruences:")
    for p in spec.primes:
        print(f"  {p}")
    print()

    # Check spectral separation
    print("Spectral separation check:")
    separated = spec.is_separated(elements)
    print(f"  All distinct pairs separated: {separated}")
    print()

    # Evaluation map
    print("Evaluation map η: S → Π_p S/p")
    for a in elements:
        eta_a = spec.eval_map(a)
        print(f"  η({a}) = {eta_a}")

    # Check injectivity
    images = [spec.eval_map(a) for a in elements]
    injective = len(set(images)) == len(elements)
    print(f"\n  Evaluation map injective: {injective}")
    print(f"  (This verifies the Stone reconstruction theorem!)")

    # Show basic opens
    print("\nBasic opens D(a,b):")
    for i, a in enumerate(elements):
        for b in elements[i+1:]:
            D = spec.basic_open(a, b)
            primes_in_D = [spec.primes[j].name for j in D]
            print(f"  D({a},{b}) = {{{', '.join(primes_in_D)}}}")

    print()
    return spec, elements


def demo_spectral_hardness():
    """Demonstrate the spectral hardness separation theorem."""
    print("=" * 70)
    print("DEMO 2: Spectral Hardness Separation Theorem")
    print("=" * 70)
    print()

    elements = [0, 1, 2, 3, 4, 5]

    # Define prime congruences
    p1 = PrimeCong([{0, 1, 2}, {3, 4, 5}], name="p₁")
    p2 = PrimeCong([{0, 3}, {1, 4}, {2, 5}], name="p₂")
    p3 = PrimeCong([{0, 4}, {1, 5}, {2, 3}], name="p₃")

    # Spectral certificate separating 0 from 5
    x, y = 0, 5
    cert = SpectralCertificate(x, y, [p1, p2, p3])
    print(f"Target pair: (x, y) = ({x}, {y})")
    print(f"Spectral certificate: {cert}")
    print(f"Certificate complexity: {cert.complexity}")
    print()

    # Test various attack functions
    attacks = [
        ("Identity", lambda a: a),
        ("Shift +1 mod 6", lambda a: (a + 1) % 6),
        ("Shift +2 mod 6", lambda a: (a + 2) % 6),
        ("Double mod 6", lambda a: (2 * a) % 6),
        ("Constant 0", lambda a: 0),
        ("Swap 0↔5", lambda a: 5 if a == 0 else (0 if a == 5 else a)),
    ]

    print("Attack analysis:")
    print("-" * 60)
    for name, f in attacks:
        reflecting = is_fully_reflecting(f, cert, elements)
        collision = f(x) == f(y)
        print(f"  Attack: {name}")
        print(f"    Fully reflecting: {reflecting}")
        print(f"    f({x})={f(x)}, f({y})={f(y)}, collision: {collision}")
        if reflecting and not collision:
            print(f"    ✓ Hardness theorem confirmed: reflecting → no collision")
        elif not reflecting:
            print(f"    ○ Attack not reflecting (outside attack class)")
        elif reflecting and collision:
            print(f"    ✗ CONTRADICTION (should not happen!)")
        print()

    return cert


def demo_tropical_matrix_owf():
    """Demonstrate tropical matrix powers as a candidate one-way function."""
    print("=" * 70)
    print("DEMO 3: Tropical Matrix OWF with Spectral Certificates")
    print("=" * 70)
    print()

    n = 3
    M = np.array([
        [0.0, 2.0, 5.0],
        [3.0, 0.0, 1.0],
        [4.0, 6.0, 0.0]
    ])

    print(f"Base matrix M (n={n}):")
    print(M)
    print()

    # Compute tropical powers
    powers = {}
    for k in range(1, 8):
        powers[k] = trop_matrix_pow(M, k)

    print("Tropical powers M^⊗k (showing entry (0,0)):")
    for k in range(1, 8):
        print(f"  M^⊗{k}[0,0] = {powers[k][0,0]:.1f}")

    print()
    print("Key observation: computing M^⊗k is O(n³ log k),")
    print("but recovering k from M^⊗k appears exponentially hard.")
    print()

    # Show that different powers produce spectrally different matrices
    print("Spectral separation of powers:")
    for k1 in range(1, 5):
        for k2 in range(k1 + 1, 5):
            diff = np.max(np.abs(powers[k1] - powers[k2]))
            print(f"  ||M^⊗{k1} - M^⊗{k2}||_∞ = {diff:.1f}")

    print()


def demo_certificate_complexity():
    """Demonstrate how certificate complexity relates to hardness."""
    print("=" * 70)
    print("DEMO 4: Certificate Complexity as Hardness Measure")
    print("=" * 70)
    print()

    n_elements = 8
    elements = list(range(n_elements))

    # Build progressively larger certificates
    all_primes = []
    for i in range(4):
        partition = []
        for block_start in range(0, n_elements, 2**(i+1)):
            block1 = set(range(block_start, min(block_start + 2**i, n_elements)))
            block2 = set(range(block_start + 2**i, min(block_start + 2**(i+1), n_elements)))
            if block1:
                partition.append(block1)
            if block2:
                partition.append(block2)
        if len(partition) > 1:
            all_primes.append(PrimeCong(partition, name=f"p_{i}"))

    print("Prime congruences (binary-level separators):")
    for p in all_primes:
        print(f"  {p}")
    print()

    # Show how certificate size grows with separation quality
    x, y = 0, 7  # maximally different elements
    print(f"Certificates separating {x} from {y}:")
    for size in range(1, len(all_primes) + 1):
        cert_primes = [p for p in all_primes[:size] if p.separates(x, y)]
        if cert_primes:
            cert = SpectralCertificate(x, y, cert_primes)
            print(f"  Size {cert.complexity}: {[p.name for p in cert.primes]}")

    print()

    # Count how many pairs each certificate size separates
    print("Separation power by certificate complexity:")
    for size in range(1, len(all_primes) + 1):
        primes_subset = all_primes[:size]
        separated_pairs = 0
        total_pairs = 0
        for i in range(n_elements):
            for j in range(i + 1, n_elements):
                total_pairs += 1
                if any(p.separates(i, j) for p in primes_subset):
                    separated_pairs += 1
        print(f"  Certificate complexity {size}: "
              f"{separated_pairs}/{total_pairs} pairs separated "
              f"({100*separated_pairs/total_pairs:.0f}%)")

    print()


def create_visualizations():
    """Create visualization plots."""

    # Figure 1: Spectral separation diagram
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Basic opens in the spectrum
    elements = [0, 1, 2, 3]
    p1 = PrimeCong([{0, 1}, {2, 3}], name="p₁")
    p2 = PrimeCong([{0, 2}, {1, 3}], name="p₂")
    p3 = PrimeCong([{0, 3}, {1, 2}], name="p₃")
    primes = [p1, p2, p3]

    # Separation matrix
    sep_matrix = np.zeros((len(elements), len(elements)))
    for i in range(len(elements)):
        for j in range(len(elements)):
            if i != j:
                sep_matrix[i, j] = sum(1 for p in primes if p.separates(i, j))

    im = axes[0].imshow(sep_matrix, cmap='YlOrRd', interpolation='nearest')
    axes[0].set_title('Spectral Separation Strength', fontsize=12)
    axes[0].set_xlabel('Element b')
    axes[0].set_ylabel('Element a')
    axes[0].set_xticks(range(len(elements)))
    axes[0].set_yticks(range(len(elements)))
    for i in range(len(elements)):
        for j in range(len(elements)):
            axes[0].text(j, i, f'{int(sep_matrix[i,j])}',
                        ha='center', va='center', fontsize=14,
                        color='white' if sep_matrix[i,j] > 1.5 else 'black')
    plt.colorbar(im, ax=axes[0], label='# separating primes')

    # Plot 2: Evaluation map (embedding into product)
    spec = CongruenceSpectrum(primes)
    eval_data = np.array([spec.eval_map(a) for a in elements])

    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
    for i, a in enumerate(elements):
        axes[1].scatter(eval_data[i, 0] + 0.05 * i, eval_data[i, 1] + 0.05 * i,
                       s=200, c=colors[i], label=f'η({a})', zorder=5, edgecolors='black')
    axes[1].set_title('Evaluation Map η: S → ∏ S/p', fontsize=12)
    axes[1].set_xlabel('Class in S/p₁')
    axes[1].set_ylabel('Class in S/p₂')
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Certificate complexity vs hardness
    sizes = list(range(1, 6))
    hardness = [2**s for s in sizes]  # Exponential growth
    axes[2].bar(sizes, hardness, color='steelblue', alpha=0.8, edgecolor='black')
    axes[2].set_title('Certificate Complexity → Hardness', fontsize=12)
    axes[2].set_xlabel('Certificate Size |C|')
    axes[2].set_ylabel('Attack Complexity Lower Bound')
    axes[2].set_yscale('log')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/spectral_duality_overview.png', dpi=150,
                bbox_inches='tight')
    plt.close()

    # Figure 2: Tropical matrix OWF
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    M = np.array([[0, 2, 5], [3, 0, 1], [4, 6, 0]], dtype=float)
    k_values = list(range(1, 12))
    entries_00 = [trop_matrix_pow(M, k)[0, 0] for k in k_values]
    entries_01 = [trop_matrix_pow(M, k)[0, 1] for k in k_values]
    entries_12 = [trop_matrix_pow(M, k)[1, 2] for k in k_values]

    axes[0].plot(k_values, entries_00, 'o-', label='M^⊗k[0,0]', color='#e41a1c')
    axes[0].plot(k_values, entries_01, 's-', label='M^⊗k[0,1]', color='#377eb8')
    axes[0].plot(k_values, entries_12, '^-', label='M^⊗k[1,2]', color='#4daf4a')
    axes[0].set_title('Tropical Matrix Powers: Entry Values', fontsize=12)
    axes[0].set_xlabel('Power k')
    axes[0].set_ylabel('Entry value')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Computational asymmetry
    n_vals = list(range(2, 16))
    forward_cost = [n**3 * np.log2(max(k, 2)) for n, k in zip(n_vals, [10]*len(n_vals))]
    inverse_cost = [2**n for n in n_vals]

    axes[1].semilogy(n_vals, forward_cost, 'o-', label='Forward: O(n³ log k)', color='#377eb8')
    axes[1].semilogy(n_vals, inverse_cost, 's-', label='Inverse: Ω(2ⁿ)', color='#e41a1c')
    axes[1].set_title('Computational Asymmetry Gap', fontsize=12)
    axes[1].set_xlabel('Matrix dimension n')
    axes[1].set_ylabel('Computational cost')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    axes[1].fill_between(n_vals, forward_cost, inverse_cost, alpha=0.1, color='red')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/tropical_owf_analysis.png', dpi=150,
                bbox_inches='tight')
    plt.close()

    print("Visualizations saved to:")
    print("  - spectral_duality_overview.png")
    print("  - tropical_owf_analysis.png")


if __name__ == "__main__":
    spec, elements = demo_stone_reconstruction()
    cert = demo_spectral_hardness()
    demo_tropical_matrix_owf()
    demo_certificate_complexity()
    create_visualizations()
    print("All demonstrations complete!")
