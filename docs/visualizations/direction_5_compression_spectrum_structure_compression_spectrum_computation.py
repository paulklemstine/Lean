"""
algorithms.py — Core algorithms for compression spectrum analysis.

Implements enumeration, computation, and structural analysis of
probe-separating families in finite presheaf-like models.

A model (F, r) consists of:
  - F: a dictionary mapping object names to lists of "sections" (elements)
  - r: a dictionary mapping (Y, Z) pairs to functions F[Y] -> F[Z]

A probe family P is a subset of the objects. P separates if for every
object Y, the "signature" map s -> (r(Y,Z)(s) for Z in P) is injective
on F[Y].
"""

from itertools import combinations, product
from typing import Dict, List, Tuple, Set, Callable, Optional, Any


# ─── Model type aliases ───────────────────────────────────────────────
Model = Tuple[
    Dict[str, List[Any]],                       # F: fibers
    Dict[Tuple[str, str], Callable[[Any], Any]]  # r: restriction maps
]


def probe_signature(model: Model, P: Set[str], Y: str, s: Any) -> tuple:
    """Compute the probe signature of section s in F[Y] w.r.t. probe family P."""
    F, r = model
    return tuple(r[(Y, Z)](s) for Z in sorted(P))


def probe_separates_at(model: Model, P: Set[str], Y: str) -> bool:
    """Check if P separates sections of F[Y] (signature map is injective)."""
    F, r = model
    sigs = [probe_signature(model, P, Y, s) for s in F[Y]]
    return len(sigs) == len(set(sigs))


def probe_separates(model: Model, P: Set[str]) -> bool:
    """Check if probe family P separates the entire model."""
    F, r = model
    return all(probe_separates_at(model, P, Y) for Y in F)


def all_probe_families(model: Model) -> List[Set[str]]:
    """Enumerate all probe families (subsets of objects)."""
    F, _ = model
    objects = sorted(F.keys())
    families = []
    for k in range(len(objects) + 1):
        for combo in combinations(objects, k):
            families.append(set(combo))
    return families


def compression_spectrum(model: Model) -> Set[int]:
    """
    Compute CompSpec(F, r) = {n | ∃ P, |P| = n and P separates}.

    Returns:
        Set of integers — cardinalities of separating families.
    """
    spec = set()
    for P in all_probe_families(model):
        if probe_separates(model, P):
            spec.add(len(P))
    return spec


def compression_number(model: Model) -> Optional[int]:
    """
    Compute κ(F, r) = min {|P| : P separates}.

    Returns:
        Minimum cardinality, or None if no separating family exists.
    """
    spec = compression_spectrum(model)
    return min(spec) if spec else None


def all_separating_families(model: Model) -> List[Set[str]]:
    """Return all separating probe families."""
    return [P for P in all_probe_families(model) if probe_separates(model, P)]


def minimal_separating_families(model: Model) -> List[Set[str]]:
    """
    Return all inclusion-minimal separating families.

    A family P is inclusion-minimal if no proper subset of P separates.
    """
    seps = all_separating_families(model)
    minimals = []
    for P in seps:
        if not any(Q < P for Q in seps if Q != P):
            minimals.append(P)
    return minimals


def is_essential(model: Model, P: Set[str], p: str) -> bool:
    """Check if probe p is essential in separating family P."""
    if p not in P:
        return False
    return not probe_separates(model, P - {p})


def essential_probes(model: Model, P: Set[str]) -> Set[str]:
    """Return the set of essential probes in P."""
    return {p for p in P if is_essential(model, P, p)}


def compression_defect(model: Model) -> int:
    """
    Compute δ(F, r) = max(|P|) - min(|P|) over inclusion-minimal separating families.

    Returns 0 if all minimal families have the same size (matroid-like).
    """
    mins = minimal_separating_families(model)
    if not mins:
        return 0
    cards = [len(P) for P in mins]
    return max(cards) - min(cards)


def distinguishing_set(model: Model, Y: str, s: Any, t: Any) -> Set[str]:
    """
    Return {Z ∈ Ob | r(Y,Z)(s) ≠ r(Y,Z)(t)}.

    This is the set of probes that distinguish sections s and t.
    """
    F, r = model
    return {Z for Z in F if r[(Y, Z)](s) != r[(Y, Z)](t)}


def obstruction_family(model: Model) -> List[Set[str]]:
    """
    Return the family of all distinguishing sets for distinct section pairs.

    A probe family separates iff it intersects every obstruction.
    """
    F, r = model
    obstructions = []
    for Y in F:
        sections = F[Y]
        for i, s in enumerate(sections):
            for j, t in enumerate(sections):
                if i < j:
                    ds = distinguishing_set(model, Y, s, t)
                    if ds:  # only add non-empty
                        obstructions.append(ds)
    return obstructions


def check_exchange_property(model: Model) -> Tuple[bool, Optional[Tuple]]:
    """
    Check if the matroid exchange property holds for minimal separating families.

    Exchange property: for minimal P, Q with |P| < |Q|,
    ∃ q ∈ Q \\ P such that P ∪ {q} separates.

    Returns:
        (True, None) if exchange holds,
        (False, (P, Q)) — a counterexample pair.
    """
    mins = minimal_separating_families(model)
    for P in mins:
        for Q in mins:
            if len(P) < len(Q):
                # Check if ∃ q ∈ Q \ P such that P ∪ {q} separates
                found = False
                for q in Q - P:
                    if probe_separates(model, P | {q}):
                        found = True
                        break
                if not found:
                    return False, (P, Q)
    return True, None


def check_basis_exchange(model: Model) -> Tuple[bool, Optional[Tuple]]:
    """
    Check if the basis exchange property holds among minimum-cardinality
    separating families.

    Basis exchange: for min-card P, Q and p ∈ P \\ Q,
    ∃ q ∈ Q \\ P such that (P \\ {p}) ∪ {q} separates.

    Returns:
        (True, None) if exchange holds,
        (False, (P, Q, p)) — a counterexample.
    """
    seps = all_separating_families(model)
    kappa = compression_number(model)
    if kappa is None:
        return True, None
    min_fams = [P for P in seps if len(P) == kappa]
    for P in min_fams:
        for Q in min_fams:
            if P != Q:
                for p in P - Q:
                    found = False
                    for q in Q - P:
                        candidate = (P - {p}) | {q}
                        if probe_separates(model, candidate):
                            found = True
                            break
                    if not found:
                        return False, (P, Q, p)
    return True, None


# ─── Example model constructors ──────────────────────────────────────

def make_identity_model(n: int) -> Model:
    """
    Create a model on n objects where r(Y, Z) is the identity when Y = Z
    and a constant map otherwise. Each fiber has 2 elements.
    """
    objects = [f"o{i}" for i in range(n)]
    F = {obj: [0, 1] for obj in objects}
    r = {}
    for Y in objects:
        for Z in objects:
            if Y == Z:
                r[(Y, Z)] = lambda x: x
            else:
                r[(Y, Z)] = lambda x: 0
    return F, r


def make_full_model(n: int, fiber_size: int = 2) -> Model:
    """
    Create a model on n objects with full distinguishing power.
    r(Y, Z)(s) = s for all Y, Z (identity restriction maps).
    """
    objects = [f"o{i}" for i in range(n)]
    F = {obj: list(range(fiber_size)) for obj in objects}
    r = {}
    for Y in objects:
        for Z in objects:
            r[(Y, Z)] = lambda x: x
    return F, r


def make_projection_model(n: int) -> Model:
    """
    Create a model where F[Y] = {0,...,n-1} and r(Y, Z) projects to
    coordinate Z. Sections are distinguished by their value at each object.
    """
    objects = [f"o{i}" for i in range(n)]
    # Each fiber has n elements, sections are "vectors"
    F = {obj: list(range(n)) for obj in objects}
    r = {}
    for Y in objects:
        for Z in objects:
            # r(Y,Z)(s) returns s (identity)
            r[(Y, Z)] = lambda x: x
    return F, r


if __name__ == "__main__":
    print("=== Testing algorithms on full model (3 objects, fiber size 2) ===")
    model = make_full_model(3, 2)
    print(f"Objects: {sorted(model[0].keys())}")
    print(f"Compression spectrum: {sorted(compression_spectrum(model))}")
    print(f"Compression number: {compression_number(model)}")
    mins = minimal_separating_families(model)
    print(f"Minimal separating families ({len(mins)}): {[sorted(m) for m in mins]}")
    print(f"Compression defect: {compression_defect(model)}")

    exchange_ok, counter = check_exchange_property(model)
    print(f"Exchange property holds: {exchange_ok}")
    if counter:
        print(f"  Counterexample: P={sorted(counter[0])}, Q={sorted(counter[1])}")

    print()
    print("=== Obstruction family ===")
    obs = obstruction_family(model)
    print(f"Number of obstructions: {len(obs)}")
    for o in obs[:5]:
        print(f"  {sorted(o)}")
