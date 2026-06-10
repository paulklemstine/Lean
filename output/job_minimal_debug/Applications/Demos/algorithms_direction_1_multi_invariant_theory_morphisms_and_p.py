#!/usr/bin/env python3
"""
Algorithms for Multi-Invariant Certificate Management

Implements the core algorithms from the multi-invariant theory morphism framework:
1. Certificate bundling: combining k scalar certificates into one vector certificate
2. Pipeline composition: composing morphisms along a chain
3. Dominance checking: verifying minimum dominance bounds
4. Certificate extraction: projecting individual guarantees from bundled certificates
"""

import numpy as np
from dataclasses import dataclass, field
from typing import Callable, List, Optional, Tuple, Dict


# ─────────────────────────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class InvariantSpec:
    """Specification of a single invariant function."""
    name: str
    func: Callable[[int], int]

    def __call__(self, x: int) -> int:
        return self.func(x)


@dataclass
class RichTheory:
    """A theory with k named invariants.

    Attributes:
        name: Human-readable name for the theory.
        invariants: List of k invariant specifications.
    """
    name: str
    invariants: List[InvariantSpec]

    @property
    def k(self) -> int:
        return len(self.invariants)

    def inv_vec(self, x: int) -> np.ndarray:
        """Compute the full invariant vector at element x.

        Time complexity: O(k) where k is the number of invariants.
        """
        return np.array([inv(x) for inv in self.invariants])

    def inv_at(self, x: int, i: int) -> int:
        """Compute the i-th invariant at element x.

        Time complexity: O(1).
        """
        return self.invariants[i](x)


@dataclass
class RichHom:
    """A morphism between rich theories with verified coordinatewise monotonicity.

    Attributes:
        source: Source theory.
        target: Target theory.
        to_fun: Underlying function on carriers.
        verified_points: Set of points where monotonicity has been checked.
    """
    source: RichTheory
    target: RichTheory
    to_fun: Callable[[int], int]
    verified_points: set = field(default_factory=set)

    def check_mono_at(self, x: int) -> Tuple[bool, Optional[int]]:
        """Check monotonicity at point x.

        Returns (True, None) if monotone at x, or (False, i) where i is the
        first coordinate that violates monotonicity.

        Time complexity: O(k).
        """
        for i in range(self.source.k):
            if self.target.inv_at(self.to_fun(x), i) > self.source.inv_at(x, i):
                return False, i
        self.verified_points.add(x)
        return True, None


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 1: Certificate Bundling
# ─────────────────────────────────────────────────────────────────────────────

def bundle_certificates(
    source_carrier_name: str,
    target_carrier_name: str,
    f: Callable[[int], int],
    source_invariants: List[InvariantSpec],
    target_invariants: List[InvariantSpec],
    test_points: Optional[List[int]] = None
) -> RichHom:
    """Bundle k independent scalar certificate-transfer pairs into one rich morphism.

    Given:
      - k source invariants I_1, ..., I_k on type α
      - k target invariants J_1, ..., J_k on type β
      - A function f : α → β
      - Evidence that ∀ i, ∀ x, J_i(f(x)) ≤ I_i(x)

    Produces a RichHom from the bundled source theory to the bundled target theory.

    Pseudocode:
        BUNDLE(f, I[1..k], J[1..k]):
            T_src := RichTheory(invariants = I[1..k])
            T_tgt := RichTheory(invariants = J[1..k])
            return RichHom(source=T_src, target=T_tgt, to_fun=f)

    Time complexity: O(1) for construction, O(k * |test_points|) for verification.
    Space complexity: O(k) for the theory structures.

    Args:
        source_carrier_name: Name for the source type.
        target_carrier_name: Name for the target type.
        f: The underlying function.
        source_invariants: List of source invariant specs.
        target_invariants: List of target invariant specs (same length).
        test_points: Optional points to verify monotonicity.

    Returns:
        A RichHom bundling all certificates.

    Raises:
        ValueError: If invariant lists have different lengths.
        AssertionError: If monotonicity fails at any test point.
    """
    if len(source_invariants) != len(target_invariants):
        raise ValueError(
            f"Invariant count mismatch: {len(source_invariants)} source vs "
            f"{len(target_invariants)} target"
        )

    k = len(source_invariants)
    T_src = RichTheory(source_carrier_name, source_invariants)
    T_tgt = RichTheory(target_carrier_name, target_invariants)
    hom = RichHom(T_src, T_tgt, f)

    if test_points is not None:
        for x in test_points:
            ok, bad_coord = hom.check_mono_at(x)
            if not ok:
                raise AssertionError(
                    f"Monotonicity failed at x={x}, coordinate {bad_coord}: "
                    f"target.inv[{bad_coord}](f({x})) = {T_tgt.inv_at(f(x), bad_coord)} > "
                    f"{T_src.inv_at(x, bad_coord)} = source.inv[{bad_coord}]({x})"
                )

    return hom


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 2: Pipeline Composition
# ─────────────────────────────────────────────────────────────────────────────

def compose_pipeline(morphisms: List[RichHom]) -> RichHom:
    """Compose a list of morphisms into a single pipeline morphism.

    Given morphisms [f₁, f₂, ..., fₙ] where fᵢ : Tᵢ → Tᵢ₊₁,
    produces the composite fₙ ∘ ... ∘ f₂ ∘ f₁ : T₁ → Tₙ₊₁.

    Pseudocode:
        COMPOSE_PIPELINE(morphisms[1..n]):
            result := morphisms[1]
            for i := 2 to n:
                result := COMPOSE(morphisms[i], result)
            return result

    Time complexity: O(n) for construction, where n is the pipeline length.
    Space complexity: O(n) due to closure chain.

    Args:
        morphisms: List of composable morphisms [f₁, f₂, ..., fₙ].

    Returns:
        The composite morphism fₙ ∘ ... ∘ f₁.

    Raises:
        ValueError: If the morphism list is empty.
    """
    if not morphisms:
        raise ValueError("Cannot compose empty pipeline")

    result = morphisms[0]
    for i in range(1, len(morphisms)):
        prev_fun = result.to_fun
        next_fun = morphisms[i].to_fun
        result = RichHom(
            source=result.source,
            target=morphisms[i].target,
            to_fun=lambda x, pf=prev_fun, nf=next_fun: nf(pf(x))
        )

    return result


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 3: Dominance Checking
# ─────────────────────────────────────────────────────────────────────────────

def check_minimum_dominance(
    f: RichHom,
    g: RichHom,
    test_points: List[int]
) -> Dict[str, object]:
    """Verify the minimum dominance theorem numerically.

    For morphisms f : T₁ → T₂ and g : T₂ → T₃, checks that:
        ∀ x i, T₃.Inv(g(f(x)), i) ≤ min(T₂.Inv(f(x), i), T₁.Inv(x, i))

    Pseudocode:
        CHECK_MIN_DOMINANCE(f, g, test_points):
            for x in test_points:
                v1 := T1.inv_vec(x)
                v2 := T2.inv_vec(f(x))
                v3 := T3.inv_vec(g(f(x)))
                m := min(v1, v2)  // coordinatewise
                if any(v3[i] > m[i]):
                    return FAIL(x, i)
            return SUCCESS

    Time complexity: O(|test_points| * k).

    Args:
        f: First morphism T₁ → T₂.
        g: Second morphism T₂ → T₃.
        test_points: Points at which to check dominance.

    Returns:
        Dictionary with 'passed', 'details', and 'violations' fields.
    """
    k = f.source.k
    details = []
    violations = []

    for x in test_points:
        v1 = f.source.inv_vec(x)
        v2 = f.target.inv_vec(f.to_fun(x))
        v3 = g.target.inv_vec(g.to_fun(f.to_fun(x)))
        m = np.minimum(v1, v2)

        entry = {
            'x': x,
            'source': v1.tolist(),
            'intermediate': v2.tolist(),
            'composite': v3.tolist(),
            'min_bound': m.tolist(),
            'dominated': all(v3[i] <= m[i] for i in range(k))
        }
        details.append(entry)

        if not entry['dominated']:
            for i in range(k):
                if v3[i] > m[i]:
                    violations.append({'x': x, 'coord': i, 'value': int(v3[i]), 'bound': int(m[i])})

    return {
        'passed': len(violations) == 0,
        'num_tests': len(test_points),
        'details': details,
        'violations': violations
    }


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 4: Certificate Extraction
# ─────────────────────────────────────────────────────────────────────────────

def extract_certificate(
    hom: RichHom,
    coordinate: int,
    x: int
) -> Tuple[int, int, bool]:
    """Extract a single scalar certificate from a rich morphism.

    Given a rich morphism f : T₁ → T₂ and a coordinate i, extracts:
        (T₁.Inv(x, i), T₂.Inv(f(x), i), T₂.Inv(f(x), i) ≤ T₁.Inv(x, i))

    Time complexity: O(1).

    Args:
        hom: The rich morphism.
        coordinate: Which coordinate to extract (0-indexed).
        x: The element to evaluate at.

    Returns:
        Tuple of (source_value, target_value, is_monotone).
    """
    src_val = hom.source.inv_at(x, coordinate)
    tgt_val = hom.target.inv_at(hom.to_fun(x), coordinate)
    return src_val, tgt_val, tgt_val <= src_val


# ─────────────────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Algorithm 1: Bundle 3 scalar certificates
    print("\n--- Algorithm 1: Certificate Bundling ---")
    hom = bundle_certificates(
        "Source", "Target",
        f=lambda n: n // 2,
        source_invariants=[
            InvariantSpec("height", lambda n: n),
            InvariantSpec("rank", lambda n: 2 * n),
            InvariantSpec("entropy", lambda n: n * n),
        ],
        target_invariants=[
            InvariantSpec("height", lambda n: n),
            InvariantSpec("rank", lambda n: 2 * n),
            InvariantSpec("entropy", lambda n: n * n),
        ],
        test_points=list(range(20))
    )
    print(f"Bundled {hom.source.k} certificates into one rich morphism.")
    print(f"Verified at {len(hom.verified_points)} points.")

    # Algorithm 2: Pipeline composition
    print("\n--- Algorithm 2: Pipeline Composition ---")
    T1 = RichTheory("T1", [InvariantSpec("h", lambda n: n), InvariantSpec("r", lambda n: 3*n)])
    T2 = RichTheory("T2", [InvariantSpec("h", lambda n: n//2), InvariantSpec("r", lambda n: n)])
    T3 = RichTheory("T3", [InvariantSpec("h", lambda n: n//4), InvariantSpec("r", lambda n: n//2)])

    pipeline = compose_pipeline([
        RichHom(T1, T2, lambda n: n),
        RichHom(T2, T3, lambda n: n),
    ])
    print(f"Composed pipeline: {pipeline.source.name} → {pipeline.target.name}")
    ok, bad = pipeline.check_mono_at(10)
    print(f"Mono check at x=10: {'✓' if ok else f'✗ (coord {bad})'}")

    # Algorithm 3: Dominance checking
    print("\n--- Algorithm 3: Dominance Checking ---")
    f = RichHom(T1, T2, lambda n: n)
    g = RichHom(T2, T3, lambda n: n)
    result = check_minimum_dominance(f, g, list(range(1, 15)))
    print(f"Min dominance: {'PASSED' if result['passed'] else 'FAILED'} ({result['num_tests']} tests)")

    # Algorithm 4: Certificate extraction
    print("\n--- Algorithm 4: Certificate Extraction ---")
    for i in range(pipeline.source.k):
        src, tgt, mono = extract_certificate(pipeline, i, 20)
        inv_name = pipeline.source.invariants[i].name
        print(f"  Coordinate {i} ({inv_name}): {src} → {tgt}, monotone: {mono}")

    print("\n✓ All algorithms demonstrated successfully.")
