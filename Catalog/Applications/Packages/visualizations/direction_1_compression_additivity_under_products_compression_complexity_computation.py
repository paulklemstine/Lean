#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Compression Complexity of Finite Presheaf Models

Implements:
1. Exhaustive computation of compression complexity κ(M)
2. Product model construction
3. Distinguishability analysis
4. Compression defect computation
5. Enumeration of small finite presheaf models

All algorithms operate on finite presheaf models represented as:
- Objects: a finite set
- Fibers: a function from objects to finite sets
- Restriction maps: for each pair (Y,Z), a function F(Y) → F(Z)
"""

from itertools import combinations, product as cartesian
from typing import Dict, List, Tuple, Set, Optional
from dataclasses import dataclass, field
import time


@dataclass
class FinitePresheafModel:
    """
    A finite presheaf model (Ob, Fib, res).

    Attributes:
        name: Human-readable identifier
        objects: List of object names
        fibers: Dictionary mapping each object to its fiber elements
        res: Dictionary mapping (Y, Z) pairs to restriction functions (as dicts)
    """
    name: str
    objects: List[str]
    fibers: Dict[str, List[str]]
    res: Dict[Tuple[str, str], Dict[str, str]]

    def fiber_sizes(self) -> List[int]:
        """Return the list of fiber cardinalities."""
        return [len(self.fibers[o]) for o in self.objects]

    def total_fiber_size(self) -> int:
        """Representable dimension: sum of fiber cardinalities."""
        return sum(self.fiber_sizes())

    def __repr__(self):
        return (f"FinitePresheafModel(name='{self.name}', "
                f"|Ob|={len(self.objects)}, fibers={self.fiber_sizes()})")


def probe_signature(model: FinitePresheafModel, probe_family: List[str],
                    Y: str, s: str) -> Tuple[str, ...]:
    """
    Compute the probe signature of section s ∈ F(Y) under probe family P.

    The signature is the tuple (res(Y,Z₁)(s), res(Y,Z₂)(s), ...) for Z_i ∈ P.

    Time complexity: O(|P|)
    Space complexity: O(|P|)
    """
    return tuple(model.res[(Y, Z)][s] for Z in probe_family)


def is_separating(model: FinitePresheafModel, probe_family: List[str]) -> bool:
    """
    Check whether a probe family separates all fibers of the model.

    A probe family P separates if for every object Y, the signature map
    s ↦ (res(Y,Z)(s))_{Z ∈ P} is injective on F(Y).

    Time complexity: O(|Ob| · max|F(Y)| · |P|)
    Space complexity: O(max|F(Y)| · |P|)
    """
    for Y in model.objects:
        signatures: Set[Tuple[str, ...]] = set()
        for s in model.fibers[Y]:
            sig = probe_signature(model, probe_family, Y, s)
            if sig in signatures:
                return False
            signatures.add(sig)
    return True


def compression_complexity(model: FinitePresheafModel) -> int:
    """
    Compute κ(M) = minimum cardinality of a separating probe family.

    Algorithm: Exhaustive search over all subsets of objects, ordered by size.
    Returns the smallest k such that some k-element subset separates.

    Time complexity: O(Σ_k C(n,k) · |Ob| · max|F(Y)| · k)
                   = O(2^n · n · max|F(Y)|) worst case
    Space complexity: O(max|F(Y)| · n)

    For small models (≤ 10 objects), this is fast.
    """
    n = len(model.objects)
    for k in range(n + 1):
        for combo in combinations(model.objects, k):
            if is_separating(model, list(combo)):
                return k
    return n  # Full set always separates


def optimal_probe_family(model: FinitePresheafModel) -> List[str]:
    """
    Find a minimum-size separating probe family.

    Returns the first optimal family found in lexicographic order.
    """
    n = len(model.objects)
    k = compression_complexity(model)
    for combo in combinations(model.objects, k):
        if is_separating(model, list(combo)):
            return list(combo)
    return model.objects[:]


def product_model(M1: FinitePresheafModel,
                  M2: FinitePresheafModel) -> FinitePresheafModel:
    """
    Construct the categorical product M1 × M2.

    - Objects: M1.Ob × M2.Ob
    - Fibers: F(y1,y2) = F1(y1) × F2(y2)
    - Restriction: res((y1,y2), (z1,z2))(s1,s2) = (res1(y1,z1)(s1), res2(y2,z2)(s2))

    Time complexity: O(|Ob₁|·|Ob₂|·(|Ob₁|·|Ob₂| + max_fib₁·max_fib₂))
    """
    objects = []
    fibers = {}
    res = {}

    for a in M1.objects:
        for b in M2.objects:
            key = f"({a},{b})"
            objects.append(key)
            fibers[key] = [f"({s},{t})"
                          for s in M1.fibers[a]
                          for t in M2.fibers[b]]

    for y1 in M1.objects:
        for y2 in M2.objects:
            ykey = f"({y1},{y2})"
            for z1 in M1.objects:
                for z2 in M2.objects:
                    zkey = f"({z1},{z2})"
                    mapping = {}
                    for s1 in M1.fibers[y1]:
                        for s2 in M2.fibers[y2]:
                            skey = f"({s1},{s2})"
                            r1 = M1.res[(y1, z1)][s1]
                            r2 = M2.res[(y2, z2)][s2]
                            mapping[skey] = f"({r1},{r2})"
                    res[(ykey, zkey)] = mapping

    return FinitePresheafModel(
        name=f"{M1.name}×{M2.name}",
        objects=objects,
        fibers=fibers,
        res=res
    )


def distinguishability_classes(model: FinitePresheafModel,
                                Y: str) -> List[List[str]]:
    """
    Compute the equivalence classes under probe indistinguishability at Y.

    Two sections s,t ∈ F(Y) are indistinguishable if
    res(Y,Z)(s) = res(Y,Z)(t) for all objects Z.

    Returns a partition of F(Y) into equivalence classes.

    Time complexity: O(|F(Y)| · |Ob|)
    """
    sig_to_class: Dict[Tuple[str, ...], List[str]] = {}
    for s in model.fibers[Y]:
        sig = tuple(model.res[(Y, Z)][s] for Z in model.objects)
        if sig not in sig_to_class:
            sig_to_class[sig] = []
        sig_to_class[sig].append(s)
    return list(sig_to_class.values())


def distinguishability_card_at(model: FinitePresheafModel, Y: str) -> int:
    """Number of distinguishability classes at object Y."""
    return len(distinguishability_classes(model, Y))


def compression_defect(M1: FinitePresheafModel,
                       M2: FinitePresheafModel) -> int:
    """
    Compute the compression defect δ(M1, M2) = κ(M1) + κ(M2) - κ(M1 × M2).

    By the sub-additivity theorem, this is always ≥ 0.
    """
    k1 = compression_complexity(M1)
    k2 = compression_complexity(M2)
    k_prod = compression_complexity(product_model(M1, M2))
    return k1 + k2 - k_prod


def is_probe_independent(M1: FinitePresheafModel,
                         M2: FinitePresheafModel) -> bool:
    """
    Check the ProbeIndependent condition: every separating family on
    M1 × M2 has size ≥ κ(M1) + κ(M2).

    This is equivalent to κ(M1 × M2) = κ(M1) + κ(M2).
    """
    return compression_defect(M1, M2) == 0


# ═══════════════════════════════════════
# Model Generators
# ═══════════════════════════════════════

def identity_model(n_obj: int, n_fib: int, name: str = "") -> FinitePresheafModel:
    """
    Create a model where res(Y,Y) = id and res(Y,Z) = const for Y ≠ Z.

    These models have κ = n_obj when n_fib ≥ 2 (each object needs
    its own probe to distinguish its fibers).
    """
    if not name:
        name = f"Id({n_obj},{n_fib})"
    objects = [f"O{i}" for i in range(n_obj)]
    fibers = {o: [f"{o}_f{j}" for j in range(n_fib)] for o in objects}
    res = {}
    for y in objects:
        for z in objects:
            if y == z:
                res[(y, z)] = {s: s for s in fibers[y]}
            else:
                res[(y, z)] = {s: fibers[z][0] for s in fibers[y]}
    return FinitePresheafModel(name=name, objects=objects, fibers=fibers, res=res)


def constant_model(n_obj: int, name: str = "") -> FinitePresheafModel:
    """Model with single-element fibers. Always has κ = 0."""
    if not name:
        name = f"Const({n_obj})"
    objects = [f"O{i}" for i in range(n_obj)]
    fibers = {o: [f"{o}_f0"] for o in objects}
    res = {}
    for y in objects:
        for z in objects:
            res[(y, z)] = {fibers[y][0]: fibers[z][0]}
    return FinitePresheafModel(name=name, objects=objects, fibers=fibers, res=res)


def full_separation_model(n_obj: int, n_fib: int,
                          name: str = "") -> FinitePresheafModel:
    """
    Model where restriction maps are cyclic permutations.
    Has κ = 1 when n_fib ≥ 2 (single probe suffices).
    """
    if not name:
        name = f"Full({n_obj},{n_fib})"
    objects = [f"O{i}" for i in range(n_obj)]
    fibers = {o: [f"{o}_f{j}" for j in range(n_fib)] for o in objects}
    res = {}
    for y in objects:
        for z in objects:
            mapping = {}
            for j, s in enumerate(fibers[y]):
                mapping[s] = fibers[z][j % n_fib]
            res[(y, z)] = mapping
    return FinitePresheafModel(name=name, objects=objects, fibers=fibers, res=res)


def enumerate_models(max_objects: int = 3, max_fiber: int = 3) -> List[FinitePresheafModel]:
    """
    Enumerate a representative set of finite presheaf models.

    Generates identity, constant, and full-separation models
    with varying parameters.
    """
    models = []
    for n_obj in range(1, max_objects + 1):
        models.append(constant_model(n_obj))
        for n_fib in range(2, max_fiber + 1):
            models.append(identity_model(n_obj, n_fib))
            models.append(full_separation_model(n_obj, n_fib))
    return models


# ═══════════════════════════════════════
# Analysis & Reporting
# ═══════════════════════════════════════

def full_analysis(models: List[FinitePresheafModel]) -> Dict:
    """
    Run comprehensive analysis on a collection of models.

    Returns a dictionary with:
    - individual κ values
    - pairwise product analysis
    - defect classification
    - distinguishability verification
    """
    results = {
        'models': {},
        'pairs': [],
        'summary': {}
    }

    # Individual analysis
    for M in models:
        k = compression_complexity(M)
        opt = optimal_probe_family(M)
        dist = {Y: distinguishability_card_at(M, Y) for Y in M.objects}
        results['models'][M.name] = {
            'kappa': k,
            'optimal_family': opt,
            'distinguishability': dist,
            'fiber_sizes': M.fiber_sizes()
        }

    # Pairwise analysis
    n_additive = 0
    n_strict = 0
    max_defect = 0

    for i, M1 in enumerate(models):
        for j, M2 in enumerate(models):
            if j < i:
                continue
            k1 = results['models'][M1.name]['kappa']
            k2 = results['models'][M2.name]['kappa']

            try:
                M_prod = product_model(M1, M2)
                if len(M_prod.objects) > 20:
                    continue  # Skip very large products
                k_prod = compression_complexity(M_prod)
            except Exception:
                continue

            defect = k1 + k2 - k_prod
            pair_result = {
                'M1': M1.name,
                'M2': M2.name,
                'kappa1': k1,
                'kappa2': k2,
                'kappa_prod': k_prod,
                'defect': defect,
                'additive': defect == 0,
                'sub_additive': k_prod <= k1 + k2,
                'lower_bound': max(k1, k2) <= k_prod
            }
            results['pairs'].append(pair_result)

            if defect == 0:
                n_additive += 1
            else:
                n_strict += 1
            max_defect = max(max_defect, defect)

    results['summary'] = {
        'total_pairs': len(results['pairs']),
        'additive_pairs': n_additive,
        'strict_sub_additive': n_strict,
        'max_defect': max_defect,
        'universal_additivity': n_strict == 0
    }

    return results


if __name__ == "__main__":
    print("Compression Complexity Algorithms — Test Suite")
    print("=" * 50)

    models = enumerate_models(max_objects=3, max_fiber=3)
    print(f"\nGenerated {len(models)} test models:")
    for M in models:
        k = compression_complexity(M)
        print(f"  {M.name:20s}  κ = {k}")

    print("\nRunning full pairwise analysis...")
    t0 = time.time()
    results = full_analysis(models)
    elapsed = time.time() - t0

    print(f"\nCompleted in {elapsed:.2f}s")
    print(f"Total pairs analyzed: {results['summary']['total_pairs']}")
    print(f"Additive pairs: {results['summary']['additive_pairs']}")
    print(f"Strict sub-additive: {results['summary']['strict_sub_additive']}")
    print(f"Maximum defect: {results['summary']['max_defect']}")
    print(f"Universal additivity: {results['summary']['universal_additivity']}")
