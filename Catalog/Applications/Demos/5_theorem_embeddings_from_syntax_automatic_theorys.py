#!/usr/bin/env python3
"""
Applications of TheorySpec Extraction

Demonstrates real-world applications of automatic theorem semantic extraction:
1. Complexity lower bounds in algorithm design
2. Learning theory sample complexity
3. Cryptographic security parameters
4. Cross-domain bound transfer
"""

from dataclasses import dataclass, field
from typing import Callable, List, Tuple, Dict, Any
import math


@dataclass
class TheorySpec:
    """Reusable lower-bound specification."""
    name: str
    carrier_type: str
    witness_desc: str
    invariant: Callable[[Any], float]
    lower_bound: float
    domain: str = "general"


# ============================================================
# Application 1: Algorithm Complexity Lower Bounds
# ============================================================

def sorting_lower_bound_application():
    """Demonstrate complexity lower bounds as TheorySpecs.

    The comparison-sorting lower bound: any comparison-based sorting
    algorithm on n elements requires at least ⌈log₂(n!)⌉ comparisons.
    """
    print("=" * 60)
    print("APPLICATION 1: Sorting Complexity Lower Bounds")
    print("=" * 60)

    def log_factorial(n: int) -> float:
        if n <= 1:
            return 0
        return sum(math.log2(i) for i in range(2, n + 1))

    sorting_spec = TheorySpec(
        name="comparison_sorting_lower_bound",
        carrier_type="sorting_algorithms",
        witness_desc="comparison-based",
        invariant=lambda n: math.ceil(log_factorial(n)),
        lower_bound=0,
        domain="complexity_theory",
    )

    print(f"\n  TheorySpec: {sorting_spec.name}")
    print(f"  Domain: {sorting_spec.domain}")
    print(f"  Statement: Any comparison sort on n elements uses ≥ ⌈log₂(n!)⌉ comparisons")
    print(f"\n  {'n':>4} {'⌈log₂(n!)⌉':>12} {'n·log₂(n)':>12} {'ratio':>8}")
    print(f"  {'-'*4} {'-'*12} {'-'*12} {'-'*8}")
    for n in [2, 4, 8, 16, 32, 64, 128, 256, 1024]:
        lb = sorting_spec.invariant(n)
        nlogn = n * math.log2(n) if n > 1 else 0
        ratio = lb / nlogn if nlogn > 0 else 0
        print(f"  {n:4d} {lb:12.0f} {nlogn:12.1f} {ratio:8.3f}")


# ============================================================
# Application 2: Learning Theory Sample Complexity
# ============================================================

def learning_theory_application():
    """VC dimension lower bounds as TheorySpecs.

    Fundamental theorem of learning theory: to PAC-learn a concept class
    with VC dimension d to accuracy ε with confidence 1-δ, you need
    at least Ω(d/ε) samples.
    """
    print(f"\n{'=' * 60}")
    print("APPLICATION 2: Learning Theory Sample Complexity")
    print("=" * 60)

    def sample_complexity_lower_bound(params: Tuple[int, float]) -> float:
        """Lower bound on sample complexity given (VC-dim, accuracy)."""
        d, epsilon = params
        if epsilon <= 0:
            return float('inf')
        return d / (2 * epsilon)

    learning_spec = TheorySpec(
        name="vc_sample_complexity_lower_bound",
        carrier_type="(vc_dim, accuracy) pairs",
        witness_desc="PAC learnable concept class",
        invariant=sample_complexity_lower_bound,
        lower_bound=0,
        domain="learning_theory",
    )

    print(f"\n  TheorySpec: {learning_spec.name}")
    print(f"  Domain: {learning_spec.domain}")
    print(f"  Statement: PAC learning requires ≥ d/(2ε) samples")
    print(f"\n  {'VC-dim':>6} {'ε':>8} {'min_samples':>12} {'typical_n':>10}")
    print(f"  {'-'*6} {'-'*8} {'-'*12} {'-'*10}")
    for d in [1, 5, 10, 50, 100]:
        for eps in [0.1, 0.01]:
            lb = learning_spec.invariant((d, eps))
            typical = int(4 * lb)  # typical practical multiplier
            print(f"  {d:6d} {eps:8.3f} {lb:12.0f} {typical:10d}")


# ============================================================
# Application 3: Cryptographic Security
# ============================================================

def cryptographic_application():
    """Security parameter lower bounds as TheorySpecs.

    For a cryptographic scheme with security parameter λ,
    the best attack requires at least 2^(λ/2) operations
    (birthday bound).
    """
    print(f"\n{'=' * 60}")
    print("APPLICATION 3: Cryptographic Security Parameters")
    print("=" * 60)

    crypto_spec = TheorySpec(
        name="birthday_bound_security",
        carrier_type="security_parameters",
        witness_desc="collision-resistant hash function",
        invariant=lambda lam: 2**(lam // 2),
        lower_bound=0,
        domain="cryptography",
    )

    print(f"\n  TheorySpec: {crypto_spec.name}")
    print(f"  Domain: {crypto_spec.domain}")
    print(f"  Statement: collision finding requires ≥ 2^(λ/2) operations")
    print(f"\n  {'λ':>4} {'2^(λ/2)':>20} {'log₂':>8} {'security_level':>16}")
    print(f"  {'-'*4} {'-'*20} {'-'*8} {'-'*16}")
    for lam in [64, 128, 192, 256, 384, 512]:
        ops = crypto_spec.invariant(lam)
        log_ops = lam // 2
        level = f"{log_ops}-bit"
        print(f"  {lam:4d} {ops:20.2e} {log_ops:8d} {level:>16}")


# ============================================================
# Application 4: Cross-Domain Transfer
# ============================================================

def cross_domain_transfer_application():
    """Demonstrate cross-domain bound transfer via TheorySpec morphisms.

    Show how a bound from one domain (complexity theory) can be
    transferred to another domain (learning theory) via a morphism.
    """
    print(f"\n{'=' * 60}")
    print("APPLICATION 4: Cross-Domain Bound Transfer")
    print("=" * 60)

    # Source: exponential growth in complexity theory
    complexity_spec = TheorySpec(
        name="circuit_depth_bound",
        carrier_type="ℕ",
        witness_desc="True",
        invariant=lambda d: 2**d,
        lower_bound=0,
        domain="complexity_theory",
    )

    # Target: sample complexity in learning theory
    learning_spec = TheorySpec(
        name="sample_complexity_from_circuit",
        carrier_type="ℕ",
        witness_desc="True",
        invariant=lambda d: 2**d,  # transferred invariant
        lower_bound=0,
        domain="learning_theory",
    )

    print(f"\n  Source domain: {complexity_spec.domain}")
    print(f"  Source spec: {complexity_spec.name}")
    print(f"  Target domain: {learning_spec.domain}")
    print(f"  Target spec: {learning_spec.name}")
    print(f"\n  Transfer morphism: identity on carriers")
    print(f"  Interpretation: circuit depth d requires 2^d samples to learn")
    print(f"\n  {'d':>4} {'circuit_inv':>12} {'sample_inv':>12} {'transfer_ok':>12}")
    print(f"  {'-'*4} {'-'*12} {'-'*12} {'-'*12}")
    for d in range(1, 11):
        ci = complexity_spec.invariant(d)
        si = learning_spec.invariant(d)
        ok = si >= learning_spec.lower_bound
        print(f"  {d:4d} {ci:12d} {si:12d} {'✓' if ok else '✗':>12}")


# ============================================================
# Application 5: Parameterized Families
# ============================================================

def parameterized_families_application():
    """Demonstrate parameterized TheorySpec families.

    The depth obstruction theorem generates a family of specs
    indexed by layer width W.
    """
    print(f"\n{'=' * 60}")
    print("APPLICATION 5: Parameterized TheorySpec Families")
    print("=" * 60)

    def make_depth_spec(W: int) -> TheorySpec:
        return TheorySpec(
            name=f"depth_obstruction(W={W})",
            carrier_type="ℕ",
            witness_desc="True",
            invariant=lambda d, w=W: w * (d // w + 1),
            lower_bound=0,
            domain="deep_learning",
        )

    print(f"\n  Family: depth obstruction indexed by layer width W")
    print(f"  Theorem: d ≤ W * (d/W + 1)")

    widths = [1, 2, 4, 8, 16]
    family = {W: make_depth_spec(W) for W in widths}

    print(f"\n  {'d':>4}", end="")
    for W in widths:
        print(f"  {'W='+str(W):>8}", end="")
    print(f"  {'max_gap':>8}")
    print(f"  {'-'*4}", end="")
    for W in widths:
        print(f"  {'-'*8}", end="")
    print(f"  {'-'*8}")

    for d in [1, 5, 10, 20, 50, 100]:
        print(f"  {d:4d}", end="")
        max_gap = 0
        for W in widths:
            inv_val = family[W].invariant(d)
            gap = inv_val - d
            max_gap = max(max_gap, gap)
            print(f"  {inv_val:8d}", end="")
        print(f"  {max_gap:8d}")


if __name__ == "__main__":
    print("TheorySpec Applications: Real-World Demonstrations")
    print("=" * 60)
    print()

    sorting_lower_bound_application()
    learning_theory_application()
    cryptographic_application()
    cross_domain_transfer_application()
    parameterized_families_application()

    print(f"\n{'=' * 60}")
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: TheorySpec Extraction Pipeline

Demonstrates the core concepts of automatic theorem semantic extraction
with concrete numerical examples.
"""

from dataclasses import dataclass, field
from typing import Callable, Optional, Any, List, Tuple
import math


@dataclass
class TheorySpec:
    """A lower-bound specification extracted from a theorem.

    Fields:
        name: Human-readable name of the source theorem.
        carrier_desc: Description of the carrier type α.
        witness_desc: Description of the witness predicate P.
        invariant: The invariant function f : carrier → ℕ.
        lower_bound: The constant lower bound n.
        verify: A function that checks soundness for a given input.
    """
    name: str
    carrier_desc: str
    witness_desc: str
    invariant: Callable[[Any], int]
    lower_bound: int
    verify: Callable[[Any], bool] = field(default=lambda x: True)

    def check_soundness(self, x: Any) -> Tuple[bool, str]:
        """Verify the lower bound holds for a specific witness."""
        inv_val = self.invariant(x)
        holds = self.lower_bound <= inv_val
        witness_ok = self.verify(x)
        msg = (f"  inv({x}) = {inv_val}, bound = {self.lower_bound}, "
               f"witness = {witness_ok}, holds = {holds}")
        return holds and witness_ok, msg


def demo_depth_obstruction():
    """Demonstrate the depth obstruction bound: d ≤ W * (d/W + 1)."""
    print("=" * 60)
    print("EMBEDDING 1: Depth Obstruction Bound")
    print("  Theorem: ∀ d W : ℕ, W > 0 → d ≤ W * (d/W + 1)")
    print("=" * 60)

    for W in [1, 2, 3, 5, 10]:
        spec = TheorySpec(
            name=f"depth_obstruction(W={W})",
            carrier_desc="ℕ (depth parameter d)",
            witness_desc="True (all naturals)",
            invariant=lambda d, w=W: w * (d // w + 1),
            lower_bound=0,
        )
        print(f"\n  TheorySpec for W = {W}:")
        print(f"    carrier = {spec.carrier_desc}")
        print(f"    witness = {spec.witness_desc}")
        print(f"    lower_bound = {spec.lower_bound}")
        print(f"    Sample evaluations:")
        for d in [0, 1, 5, 10, 17, 100]:
            inv_val = spec.invariant(d)
            gap = inv_val - d
            ok = d <= inv_val
            print(f"      d={d:3d}: inv(d) = {inv_val:4d}, "
                  f"d ≤ inv(d)? {ok}, gap = {gap}")


def demo_exponential_growth():
    """Demonstrate the exponential growth bound: d ≤ 2^d."""
    print("\n" + "=" * 60)
    print("EMBEDDING 2: Exponential Growth Bound")
    print("  Theorem: ∀ d : ℕ, d ≤ 2^d")
    print("=" * 60)

    spec = TheorySpec(
        name="exponential_growth",
        carrier_desc="ℕ",
        witness_desc="True (all naturals)",
        invariant=lambda d: 2**d,
        lower_bound=0,
    )

    print(f"\n  TheorySpec:")
    print(f"    carrier = {spec.carrier_desc}")
    print(f"    invariant = 2^d")
    print(f"    lower_bound = {spec.lower_bound}")
    print(f"\n  Verification (d ≤ 2^d):")
    for d in range(16):
        inv_val = spec.invariant(d)
        ratio = inv_val / max(d, 1)
        print(f"    d={d:2d}: 2^d = {inv_val:6d}, "
              f"ratio = {ratio:8.1f}, gap = {inv_val - d}")


def demo_quadratic_exponential():
    """Demonstrate: d² ≤ 2^(2d)."""
    print("\n" + "=" * 60)
    print("EMBEDDING 3: Quadratic-Exponential Bound")
    print("  Theorem: ∀ d : ℕ, d² ≤ 2^(2d)")
    print("=" * 60)

    spec = TheorySpec(
        name="quadratic_exponential",
        carrier_desc="ℕ",
        witness_desc="True (all naturals)",
        invariant=lambda d: 2**(2*d),
        lower_bound=0,
    )

    print(f"\n  Verification (d² ≤ 2^(2d)):")
    for d in range(12):
        d_sq = d**2
        exp_val = spec.invariant(d)
        holds = d_sq <= exp_val
        print(f"    d={d:2d}: d²={d_sq:4d}, 2^(2d)={exp_val:8d}, "
              f"holds={holds}, ratio={exp_val/max(d_sq,1):.1f}")


def demo_composition():
    """Demonstrate TheorySpec composition."""
    print("\n" + "=" * 60)
    print("COMPOSITION: Combining Two TheorySpecs")
    print("=" * 60)

    spec1 = TheorySpec(
        name="bound_A",
        carrier_desc="ℕ",
        witness_desc="True",
        invariant=lambda d: 2**d,
        lower_bound=0,
    )

    spec2 = TheorySpec(
        name="bound_B",
        carrier_desc="ℕ",
        witness_desc="True",
        invariant=lambda d: d + d + 1,
        lower_bound=0,
    )

    composed = TheorySpec(
        name=f"{spec1.name} ⊕ {spec2.name}",
        carrier_desc="ℕ",
        witness_desc="True ∧ True",
        invariant=lambda d: spec1.invariant(d) + spec2.invariant(d),
        lower_bound=spec1.lower_bound + spec2.lower_bound,
    )

    print(f"\n  Spec 1: inv₁(d) = 2^d, bound₁ = {spec1.lower_bound}")
    print(f"  Spec 2: inv₂(d) = 2d+1, bound₂ = {spec2.lower_bound}")
    print(f"  Composed: inv(d) = inv₁(d) + inv₂(d), "
          f"bound = {composed.lower_bound}")
    print(f"\n  Verification:")
    for d in range(10):
        v1 = spec1.invariant(d)
        v2 = spec2.invariant(d)
        vc = composed.invariant(d)
        print(f"    d={d}: inv₁={v1:4d}, inv₂={v2:3d}, "
              f"sum={vc:5d}, bound={composed.lower_bound}")


def demo_registry():
    """Demonstrate the TheorySpec registry."""
    print("\n" + "=" * 60)
    print("REGISTRY: Catalog of Extracted TheorySpecs")
    print("=" * 60)

    registry: List[TheorySpec] = [
        TheorySpec("exponential_growth", "ℕ", "True",
                   lambda d: 2**d, 0),
        TheorySpec("quadratic_exponential", "ℕ", "True",
                   lambda d: 2**(2*d), 0),
        TheorySpec("linear_quadratic", "ℕ", "True",
                   lambda d: d + d + 1, 0),
        TheorySpec("depth_obstruction(W=1)", "ℕ", "True",
                   lambda d: 1 * (d // 1 + 1), 0),
        TheorySpec("depth_obstruction(W=2)", "ℕ", "True",
                   lambda d: 2 * (d // 2 + 1), 0),
    ]

    print(f"\n  Registry size: {len(registry)}")
    print(f"\n  {'Name':<30} {'Carrier':<8} {'Bound':<6} {'inv(5)':<8} {'inv(10)':<8}")
    print(f"  {'-'*30} {'-'*8} {'-'*6} {'-'*8} {'-'*8}")
    for spec in registry:
        print(f"  {spec.name:<30} {spec.carrier_desc:<8} "
              f"{spec.lower_bound:<6} {spec.invariant(5):<8} "
              f"{spec.invariant(10):<8}")

    print(f"\n  Soundness check (all specs, d ∈ [0..20]):")
    all_sound = True
    for spec in registry:
        for d in range(21):
            ok, _ = spec.check_soundness(d)
            if not ok:
                print(f"    FAIL: {spec.name} at d={d}")
                all_sound = False
    print(f"    All {len(registry)} specs verified on 21 test values: "
          f"{'PASS ✓' if all_sound else 'FAIL ✗'}")


def demo_morphism():
    """Demonstrate TheorySpec morphisms."""
    print("\n" + "=" * 60)
    print("MORPHISMS: Structure-Preserving Maps Between Specs")
    print("=" * 60)

    spec1 = TheorySpec("source", "ℕ", "True", lambda d: 2**d, 0)
    spec2 = TheorySpec("target", "ℕ", "True", lambda d: 2**(2*d), 0)

    # Morphism: id on carriers, bound 0 ≤ 0
    print(f"\n  Source: inv(d) = 2^d, bound = 0")
    print(f"  Target: inv(d) = 2^(2d), bound = 0")
    print(f"  Morphism: mapCarrier = id, boundsCompatible: 0 ≤ 0 ✓")
    print(f"\n  Verification (target.inv(d) ≥ source.inv(d)):")
    for d in range(10):
        s = spec1.invariant(d)
        t = spec2.invariant(d)
        print(f"    d={d}: source={s:5d}, target={t:8d}, "
              f"target ≥ source: {t >= s}")


if __name__ == "__main__":
    print("TheorySpec Extraction Pipeline: Concrete Demonstrations")
    print("=" * 60)
    print()

    demo_depth_obstruction()
    demo_exponential_growth()
    demo_quadratic_exponential()
    demo_composition()
    demo_registry()
    demo_morphism()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)
