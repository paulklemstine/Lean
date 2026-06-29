from typing import Dict, Hashable, Sequence, TypeVar

A = TypeVar("A", bound=Hashable)


def identity_codes(carrier: Sequence[A], base: A) -> Dict[A, int]:
    """Canonical code family C(x) = 1 if x == base else 0."""
    return {x: (1 if x == base else 0) for x in carrier}


def total_space_size(codes: Dict[A, int]) -> int:
    """|Sigma_x C(x)|."""
    return sum(codes.values())


def manufacture_identity_types(
    carrier: Sequence[A], base: A, codes: Dict[A, int]
) -> Dict[A, int]:
    """Encode-decode via fundamental_theorem_id (manufacturing direction).

    Precondition: the total space Sigma_x C(x) is contractible (size 1).
    Then the theorem manufactures, for free, |Path(base, x)| == C(x).
    Returns the manufactured identity-type sizes, raising if the
    contractibility precondition fails.
    """
    if total_space_size(codes) != 1:
        raise ValueError("total space not contractible; theorem does not apply")
    return {x: codes.get(x, 0) for x in carrier}
