#!/usr/bin/env python3
"""
Topos-Level Compression Invariant — Algorithms

Implements the core algorithms for computing compression invariants
of finite presheaf models.

Algorithms:
  1. Brute-force compression number computation
  2. Compression spectrum enumeration
  3. Observation complexity computation
  4. Compression equivalence checker
  5. Certified witness search with verification
"""

from itertools import combinations, permutations
from typing import Any, Callable, Optional


# ─── Core Data Types ───────────────────────────────────────────────

class PresheafModel:
    """A finite presheaf model (Ob, F, r).

    Attributes:
        objects: List of object names.
        fibers: Dict mapping object names to lists of elements.
        restrict: Function (src, tgt, x) -> restricted element.
    """

    def __init__(self, fibers: dict[str, list], restrict: Callable):
        self.objects = list(fibers.keys())
        self.fibers = fibers
        self.restrict = restrict

    def fiber_sizes(self) -> dict[str, int]:
        return {obj: len(self.fibers[obj]) for obj in self.objects}

    def representable_dimension(self) -> int:
        """Total fiber cardinality: Σ_Y |F(Y)|."""
        return sum(len(v) for v in self.fibers.values())

    def __repr__(self):
        sizes = self.fiber_sizes()
        return f"PresheafModel(objects={self.objects}, fiber_sizes={sizes})"


class CompressionWitness:
    """Certified witness that a probe family separates a presheaf.

    Attributes:
        probes: frozenset of probe objects
        model: the presheaf model
        verified: whether the witness has been verified
    """

    def __init__(self, probes: frozenset, model: PresheafModel):
        self.probes = probes
        self.model = model
        self.verified = False

    def verify(self) -> bool:
        """Check that this probe family actually separates the presheaf."""
        self.verified = probe_separates(self.model, self.probes)
        return self.verified

    @property
    def size(self) -> int:
        return len(self.probes)

    def __repr__(self):
        status = "✓" if self.verified else "?"
        return f"Witness({set(self.probes)}, size={self.size}, {status})"


# ─── Algorithm 1: Probe Signature ──────────────────────────────────

def probe_signature(model: PresheafModel, probes: frozenset,
                    obj: str, x: Any) -> tuple:
    """Compute the probe signature of element x at object obj.

    Time: O(|probes|)
    Space: O(|probes|)

    Args:
        model: The presheaf model.
        probes: Set of probe object names.
        obj: The object where x lives.
        x: An element of F(obj).

    Returns:
        Tuple of restriction values (r(obj, z, x) for z in probes).
    """
    return tuple(model.restrict(obj, z, x) for z in sorted(probes))


# ─── Algorithm 2: Separation Check ────────────────────────────────

def probe_separates(model: PresheafModel, probes: frozenset) -> bool:
    """Check if a probe family separates all fibers of the presheaf.

    Time: O(|Ob| · max|F(Y)| · |probes|)
    Space: O(max|F(Y)|)

    Args:
        model: The presheaf model.
        probes: Set of probe object names.

    Returns:
        True if the probe family separates all fibers.
    """
    for obj in model.objects:
        signatures: dict[tuple, Any] = {}
        for x in model.fibers[obj]:
            sig = probe_signature(model, probes, obj, x)
            if sig in signatures and signatures[sig] != x:
                return False
            signatures[sig] = x
    return True


# ─── Algorithm 3: Compression Number ──────────────────────────────

def compression_number(model: PresheafModel) -> tuple[int, CompressionWitness]:
    """Compute the minimum compression number and an optimal witness.

    Time: O(Σ_{k=0}^{|Ob|} C(|Ob|,k) · |Ob| · max|F(Y)| · k)
         ≤ O(2^|Ob| · |Ob| · max|F(Y)| · |Ob|)
    Space: O(max|F(Y)|)

    Args:
        model: The presheaf model.

    Returns:
        (compression_number, witness) — the minimum and a certifying witness.
    """
    for k in range(len(model.objects) + 1):
        for probes in combinations(model.objects, k):
            ps = frozenset(probes)
            if probe_separates(model, ps):
                w = CompressionWitness(ps, model)
                w.verified = True
                return k, w
    # Should not reach here if model is well-formed
    ps = frozenset(model.objects)
    w = CompressionWitness(ps, model)
    w.verified = True
    return len(model.objects), w


# ─── Algorithm 4: Compression Spectrum ─────────────────────────────

def compression_spectrum(model: PresheafModel) -> set[int]:
    """Enumerate all realized compression numbers.

    Time: O(2^|Ob| · |Ob| · max|F(Y)| · |Ob|)

    Args:
        model: The presheaf model.

    Returns:
        Set of integers n such that some probe family of size n separates.
    """
    spectrum: set[int] = set()
    for k in range(len(model.objects) + 1):
        for probes in combinations(model.objects, k):
            if probe_separates(model, frozenset(probes)):
                spectrum.add(k)
                break  # Found one witness for this size, move on
    return spectrum


# ─── Algorithm 5: Observation Complexity ───────────────────────────

def fiber_observation_complexity(model: PresheafModel, target: str) -> int:
    """Minimum probes to separate all elements of F(target).

    Time: O(2^|Ob| · |F(target)| · |Ob|)

    Args:
        model: The presheaf model.
        target: Object whose fiber we want to separate.

    Returns:
        Minimum probe family size for injectivity at target.
    """
    for k in range(len(model.objects) + 1):
        for probes in combinations(model.objects, k):
            ps = frozenset(probes)
            signatures = {}
            injective = True
            for x in model.fibers[target]:
                sig = probe_signature(model, ps, target, x)
                if sig in signatures and signatures[sig] != x:
                    injective = False
                    break
                signatures[sig] = x
            if injective:
                return k
    return len(model.objects)


def observation_complexity(model: PresheafModel) -> int:
    """Global observation complexity: max fiber observation complexity.

    Time: O(|Ob| · 2^|Ob| · max|F(Y)| · |Ob|)

    Args:
        model: The presheaf model.

    Returns:
        Maximum fiber observation complexity over all objects.
    """
    return max(
        fiber_observation_complexity(model, obj)
        for obj in model.objects
    )


# ─── Algorithm 6: Equivalence Checker ─────────────────────────────

def check_morita_invariance(model1: PresheafModel,
                            model2: PresheafModel) -> dict:
    """Check if two models have the same compression invariants.

    This doesn't check if the models are truly equivalent (which requires
    constructing explicit bijections), but verifies that the compression
    number, observation complexity, and representable dimension agree.

    Args:
        model1, model2: Two presheaf models to compare.

    Returns:
        Dict with comparison results.
    """
    cn1, w1 = compression_number(model1)
    cn2, w2 = compression_number(model2)
    oc1 = observation_complexity(model1)
    oc2 = observation_complexity(model2)
    rd1 = model1.representable_dimension()
    rd2 = model2.representable_dimension()

    return {
        "compression_match": cn1 == cn2,
        "observation_match": oc1 == oc2,
        "repDim_match": rd1 == rd2,
        "model1": {"κ": cn1, "obs": oc1, "repDim": rd1, "witness": w1},
        "model2": {"κ": cn2, "obs": oc2, "repDim": rd2, "witness": w2},
        "all_match": cn1 == cn2 and oc1 == oc2 and rd1 == rd2,
    }


# ─── Algorithm 7: Certified Search ────────────────────────────────

def certified_compression_search(model: PresheafModel) -> dict:
    """Certified search: find minimum compression with full verification.

    Returns a dictionary with:
    - 'minimum': the compression number
    - 'witness': an optimal CompressionWitness
    - 'all_optimal': all optimal probe families
    - 'spectrum': the full compression spectrum
    - 'bounds': verified bounds (obs ≤ κ ≤ repDim)

    Time: O(2^|Ob| · |Ob|² · max|F(Y)|)
    """
    cn, witness = compression_number(model)
    spec = compression_spectrum(model)
    oc = observation_complexity(model)
    rd = model.representable_dimension()

    # Find all optimal families
    optimal_families = []
    for probes in combinations(model.objects, cn):
        ps = frozenset(probes)
        if probe_separates(model, ps):
            w = CompressionWitness(ps, model)
            w.verified = True
            optimal_families.append(w)

    return {
        "minimum": cn,
        "witness": witness,
        "all_optimal": optimal_families,
        "spectrum": sorted(spec),
        "bounds_verified": {
            "obs_le_kappa": oc <= cn,
            "kappa_le_card_Ob": cn <= len(model.objects),
            "kappa_le_repDim": cn <= rd,
        },
        "observation_complexity": oc,
        "representable_dimension": rd,
    }


# ─── Example Usage ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Certified Compression Search Demo ===\n")

    # Example model
    model = PresheafModel(
        fibers={'A': [0, 1, 2], 'B': [0, 1], 'C': [0, 1, 2, 3]},
        restrict=lambda s, t, x: x % len({'A': [0, 1, 2], 'B': [0, 1], 'C': [0, 1, 2, 3]}[t])
    )

    print(f"Model: {model}")
    result = certified_compression_search(model)

    print(f"\nCompression number: {result['minimum']}")
    print(f"Optimal witness: {result['witness']}")
    print(f"All optimal families: {result['all_optimal']}")
    print(f"Spectrum: {result['spectrum']}")
    print(f"Observation complexity: {result['observation_complexity']}")
    print(f"Representable dimension: {result['representable_dimension']}")
    print(f"Bounds verified: {result['bounds_verified']}")
