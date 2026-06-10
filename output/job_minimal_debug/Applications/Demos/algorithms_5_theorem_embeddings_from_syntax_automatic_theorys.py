#!/usr/bin/env python3
"""
Algorithms for TheorySpec Extraction and Analysis

Implements the core algorithms from the research paper:
1. TheorySpec extraction from theorem components
2. Registry construction and querying
3. Spec composition and transformation
4. Clustering by invariant structure
"""

from dataclasses import dataclass, field
from typing import Callable, List, Optional, Tuple, Dict, Any
import math
from collections import defaultdict


# ============================================================
# Algorithm 1: TheorySpec Extraction
# ============================================================

@dataclass
class TheorySpec:
    """Semantic lower-bound specification.

    Corresponds to the Lean structure:
        structure TheorySpec where
          α : Type
          Witness : α → Prop
          inv : α → ℕ
          lowerBound : ℕ
          sound : ∀ x, Witness x → lowerBound ≤ inv x

    Complexity: O(1) construction.
    """
    name: str
    carrier_type: str
    witness_desc: str
    invariant: Callable[[Any], float]
    lower_bound: float
    witness_check: Callable[[Any], bool] = field(default=lambda x: True)
    tags: Dict[str, str] = field(default_factory=dict)

    def is_sound_at(self, x: Any) -> bool:
        """Check soundness at a specific point. O(1)."""
        if not self.witness_check(x):
            return True  # vacuously true
        return self.lower_bound <= self.invariant(x)

    def verify_on_range(self, values: List[Any]) -> Tuple[bool, List[Any]]:
        """Verify soundness on a list of test values.

        Returns (all_sound, list_of_counterexamples).
        Complexity: O(n) where n = len(values).
        """
        counterexamples = []
        for v in values:
            if not self.is_sound_at(v):
                counterexamples.append(v)
        return len(counterexamples) == 0, counterexamples


def extract_lower_bound_spec(
    name: str,
    carrier_type: str,
    witness_desc: str,
    invariant: Callable[[Any], float],
    lower_bound: float,
    witness_check: Callable[[Any], bool] = lambda x: True,
) -> TheorySpec:
    """Extract a TheorySpec from theorem components.

    This is the Python analogue of mkTheorySpecOfLowerBoundTheorem.

    Algorithm:
        1. Package components into a TheorySpec record.
        2. (In the formal version, verify soundness proof.)

    Complexity: O(1)

    Args:
        name: Name of the source theorem.
        carrier_type: Description of the carrier type.
        witness_desc: Description of the witness predicate.
        invariant: The invariant function.
        lower_bound: The guaranteed lower bound.
        witness_check: Optional witness predicate checker.

    Returns:
        A TheorySpec object.
    """
    return TheorySpec(
        name=name,
        carrier_type=carrier_type,
        witness_desc=witness_desc,
        invariant=invariant,
        lower_bound=lower_bound,
        witness_check=witness_check,
    )


# ============================================================
# Algorithm 2: TheorySpec Registry
# ============================================================

class TheorySpecRegistry:
    """A searchable registry of TheorySpecs.

    Supports insertion, querying by bound, and soundness verification.

    Space complexity: O(n) where n = number of specs.
    """

    def __init__(self):
        self.specs: List[TheorySpec] = []
        self._by_carrier: Dict[str, List[TheorySpec]] = defaultdict(list)

    def add(self, spec: TheorySpec) -> None:
        """Add a spec to the registry. O(1)."""
        self.specs.append(spec)
        self._by_carrier[spec.carrier_type].append(spec)

    def query_by_carrier(self, carrier: str) -> List[TheorySpec]:
        """Find all specs with a given carrier type. O(1) amortized."""
        return self._by_carrier.get(carrier, [])

    def query_by_bound(self, min_bound: float) -> List[TheorySpec]:
        """Find all specs with lower_bound ≥ min_bound. O(n)."""
        return [s for s in self.specs if s.lower_bound >= min_bound]

    def query_by_tag(self, key: str, value: str) -> List[TheorySpec]:
        """Find specs with a specific tag. O(n)."""
        return [s for s in self.specs
                if s.tags.get(key) == value]

    def verify_all(self, test_values: List[Any]) -> Dict[str, bool]:
        """Verify all specs on test values. O(n * m)."""
        results = {}
        for spec in self.specs:
            sound, _ = spec.verify_on_range(test_values)
            results[spec.name] = sound
        return results

    def __len__(self) -> int:
        return len(self.specs)


# ============================================================
# Algorithm 3: TheorySpec Composition
# ============================================================

def compose_specs(spec1: TheorySpec, spec2: TheorySpec,
                  name: Optional[str] = None) -> TheorySpec:
    """Compose two TheorySpecs over the same carrier.

    Corresponds to TheorySpec.compose in the Lean formalization.
    The composed spec has:
    - invariant(x) = spec1.invariant(x) + spec2.invariant(x)
    - lower_bound = spec1.lower_bound + spec2.lower_bound
    - witness(x) = spec1.witness(x) ∧ spec2.witness(x)

    Complexity: O(1) construction; O(1) per evaluation.
    """
    return TheorySpec(
        name=name or f"{spec1.name} ⊕ {spec2.name}",
        carrier_type=spec1.carrier_type,
        witness_desc=f"({spec1.witness_desc}) ∧ ({spec2.witness_desc})",
        invariant=lambda x: spec1.invariant(x) + spec2.invariant(x),
        lower_bound=spec1.lower_bound + spec2.lower_bound,
        witness_check=lambda x: spec1.witness_check(x) and spec2.witness_check(x),
    )


def weaken_spec(spec: TheorySpec, new_bound: float,
                name: Optional[str] = None) -> TheorySpec:
    """Weaken a TheorySpec by lowering the bound.

    Requires: new_bound ≤ spec.lower_bound.
    Complexity: O(1).
    """
    assert new_bound <= spec.lower_bound, \
        f"Cannot weaken: {new_bound} > {spec.lower_bound}"
    return TheorySpec(
        name=name or f"{spec.name}[weakened]",
        carrier_type=spec.carrier_type,
        witness_desc=spec.witness_desc,
        invariant=spec.invariant,
        lower_bound=new_bound,
        witness_check=spec.witness_check,
    )


def strengthen_spec(spec: TheorySpec,
                    new_witness: Callable[[Any], bool],
                    new_witness_desc: str,
                    name: Optional[str] = None) -> TheorySpec:
    """Strengthen a TheorySpec by narrowing the witness predicate.

    Requires: new_witness(x) → spec.witness_check(x) for all x.
    Complexity: O(1).
    """
    return TheorySpec(
        name=name or f"{spec.name}[strengthened]",
        carrier_type=spec.carrier_type,
        witness_desc=new_witness_desc,
        invariant=spec.invariant,
        lower_bound=spec.lower_bound,
        witness_check=lambda x: new_witness(x) and spec.witness_check(x),
    )


def pullback_spec(spec: TheorySpec, f: Callable[[Any], Any],
                  new_carrier: str,
                  name: Optional[str] = None) -> TheorySpec:
    """Pull back a TheorySpec along a function.

    Complexity: O(1) construction; O(f) per evaluation.
    """
    return TheorySpec(
        name=name or f"{spec.name}[pullback]",
        carrier_type=new_carrier,
        witness_desc=f"x ↦ ({spec.witness_desc})(f(x))",
        invariant=lambda x: spec.invariant(f(x)),
        lower_bound=spec.lower_bound,
        witness_check=lambda x: spec.witness_check(f(x)),
    )


# ============================================================
# Algorithm 4: Spec Morphism
# ============================================================

@dataclass
class TheorySpecMorphism:
    """A morphism between TheorySpecs.

    Corresponds to the Lean structure:
        structure TheorySpecMorphism (T₁ T₂ : TheorySpec) where
          mapCarrier : T₁.α → T₂.α
          preservesWitness : ∀ x, T₁.Witness x → T₂.Witness (mapCarrier x)
          boundsCompatible : T₁.lowerBound ≤ T₂.lowerBound
    """
    source: TheorySpec
    target: TheorySpec
    map_carrier: Callable[[Any], Any]

    def verify_bounds_compatible(self) -> bool:
        """Check boundsCompatible: source.lower_bound ≤ target.lower_bound."""
        return self.source.lower_bound <= self.target.lower_bound

    def verify_witness_preservation(self, test_values: List[Any]) -> bool:
        """Check witness preservation on test values."""
        for x in test_values:
            if self.source.witness_check(x):
                mapped = self.map_carrier(x)
                if not self.target.witness_check(mapped):
                    return False
        return True


def identity_morphism(spec: TheorySpec) -> TheorySpecMorphism:
    """Identity morphism. O(1)."""
    return TheorySpecMorphism(spec, spec, lambda x: x)


def compose_morphisms(f: TheorySpecMorphism,
                      g: TheorySpecMorphism) -> TheorySpecMorphism:
    """Compose morphisms: f ∘ g. O(1)."""
    return TheorySpecMorphism(
        source=g.source,
        target=f.target,
        map_carrier=lambda x: f.map_carrier(g.map_carrier(x)),
    )


# ============================================================
# Algorithm 5: Invariant Structure Clustering
# ============================================================

def classify_invariant_growth(spec: TheorySpec,
                              test_range: range = range(1, 20)) -> str:
    """Classify the growth rate of an invariant.

    Returns one of: 'constant', 'logarithmic', 'linear',
    'polynomial', 'exponential', 'super-exponential'.

    Complexity: O(|test_range|).
    """
    values = [(x, spec.invariant(x)) for x in test_range if x > 0]
    if len(values) < 3:
        return 'unknown'

    # Check for constant
    vals = [v for _, v in values]
    if max(vals) - min(vals) < 1e-9:
        return 'constant'

    # Compute growth ratios
    ratios = []
    for i in range(1, len(values)):
        x1, y1 = values[i-1]
        x2, y2 = values[i]
        if y1 > 0 and y2 > 0:
            ratios.append(math.log(y2 / y1) / max(math.log(x2 / x1), 1e-9))

    if not ratios:
        return 'unknown'

    avg_ratio = sum(ratios) / len(ratios)

    if avg_ratio < 0.1:
        return 'logarithmic'
    elif avg_ratio < 1.5:
        return 'linear'
    elif avg_ratio < 3.0:
        return 'polynomial'
    elif avg_ratio < 10.0:
        return 'exponential'
    else:
        return 'super-exponential'


def cluster_specs(specs: List[TheorySpec],
                  n_clusters: int = 3) -> Dict[str, List[TheorySpec]]:
    """Cluster specs by invariant growth rate.

    Simple clustering based on growth classification.
    Complexity: O(n * |test_range|).
    """
    clusters: Dict[str, List[TheorySpec]] = defaultdict(list)
    for spec in specs:
        growth = classify_invariant_growth(spec)
        clusters[growth].append(spec)
    return dict(clusters)


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("TheorySpec Algorithms: Examples")
    print("=" * 50)

    # Build registry
    registry = TheorySpecRegistry()

    specs = [
        extract_lower_bound_spec(
            "exponential_growth", "ℕ", "True",
            lambda d: 2**d, 0),
        extract_lower_bound_spec(
            "quadratic_exponential", "ℕ", "True",
            lambda d: 2**(2*d), 0),
        extract_lower_bound_spec(
            "linear_quadratic", "ℕ", "True",
            lambda d: d + d + 1, 0),
        extract_lower_bound_spec(
            "depth_obstruction_W1", "ℕ", "True",
            lambda d: 1 * (d // 1 + 1), 0),
        extract_lower_bound_spec(
            "depth_obstruction_W2", "ℕ", "True",
            lambda d: 2 * (d // 2 + 1), 0),
    ]

    for spec in specs:
        registry.add(spec)

    print(f"\nRegistry size: {len(registry)}")

    # Verify all
    test_vals = list(range(100))
    results = registry.verify_all(test_vals)
    print(f"\nSoundness verification (d ∈ [0..99]):")
    for name, sound in results.items():
        print(f"  {name}: {'PASS ✓' if sound else 'FAIL ✗'}")

    # Composition
    print(f"\nComposition example:")
    composed = compose_specs(specs[0], specs[2])
    print(f"  {composed.name}")
    print(f"  bound = {composed.lower_bound}")
    for d in [0, 5, 10]:
        print(f"  inv({d}) = {composed.invariant(d)}")

    # Clustering
    print(f"\nGrowth classification:")
    for spec in specs:
        growth = classify_invariant_growth(spec)
        print(f"  {spec.name}: {growth}")

    clusters = cluster_specs(specs)
    print(f"\nClusters:")
    for growth, cluster in clusters.items():
        names = [s.name for s in cluster]
        print(f"  {growth}: {names}")

    # Morphism
    print(f"\nMorphism example:")
    m = identity_morphism(specs[0])
    print(f"  id morphism on {m.source.name}")
    print(f"  bounds compatible: {m.verify_bounds_compatible()}")
    print(f"  witness preserved: {m.verify_witness_preservation(test_vals[:10])}")
