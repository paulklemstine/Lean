from typing import FrozenSet, Set

Face = FrozenSet[int]
Complex = Set[Face]


def link(faces: Complex, sigma: Face) -> Complex:
    """Link of a face sigma: faces disjoint from sigma whose union with sigma is a face."""
    assert sigma in faces, "the link is defined only for a face sigma of the complex"
    return {F for F in faces if F.isdisjoint(sigma) and (F | sigma) in faces}
