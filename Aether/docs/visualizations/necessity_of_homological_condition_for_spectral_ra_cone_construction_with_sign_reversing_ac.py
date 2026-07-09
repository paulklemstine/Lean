from typing import FrozenSet, Set, Tuple

Face = FrozenSet[int]
Complex = Set[Face]


def is_fresh(faces: Complex, v: int) -> bool:
    """The apex v is fresh if it appears in no face of the complex."""
    return all(v not in F for F in faces)


def cone(faces: Complex, v: int) -> Complex:
    """Cone over the complex with apex v: K together with {F u {v} : F in K}."""
    apex_free: Complex = set(faces)
    apex_containing: Complex = {F | {v} for F in faces}
    return apex_free | apex_containing


def reduced_euler(faces: Complex) -> int:
    return sum((-1) ** (len(F) + 1) for F in faces)


def cone_acyclicity_certificate(faces: Complex, v: int) -> Tuple[Complex, bool]:
    """Construct the cone and certify reducedEuler = 0 (Theorem reducedEuler_cone)."""
    assert is_fresh(faces, v), "apex must be fresh"
    apex_free: Complex = set(faces)
    apex_containing: Complex = {F | {v} for F in faces}
    assert apex_free.isdisjoint(apex_containing), "strata must be disjoint"
    C = apex_free | apex_containing
    return C, reduced_euler(C) == 0
