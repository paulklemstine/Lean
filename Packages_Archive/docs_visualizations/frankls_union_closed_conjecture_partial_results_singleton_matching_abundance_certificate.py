from typing import FrozenSet, List, Set, Tuple

Family = Set[FrozenSet[int]]


def singleton_abundance_certificate(
    family: Family, a: int
) -> Tuple[bool, List[Tuple[FrozenSet[int], FrozenSet[int]]]]:
    """Given a union-closed family containing {a}, build the injection
       phi(A) = A u {a} from a-avoiding to a-containing members and certify
       that 'a' is abundant.  Returns (is_abundant, matching)."""
    assert frozenset({a}) in family
    avoid: List[FrozenSet[int]] = [A for A in family if a not in A]
    matching: List[Tuple[FrozenSet[int], FrozenSet[int]]] = []
    seen: Set[FrozenSet[int]] = set()
    for A in avoid:
        img = A | {a}
        if img not in family or img in seen:
            return False, matching          # union-closure / injectivity failed
        seen.add(img)
        matching.append((A, img))
    contain = sum(1 for A in family if a in A)
    return (2 * contain >= len(family)), matching
