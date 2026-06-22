from dataclasses import dataclass
from typing import Tuple, Union


@dataclass(frozen=True)
class Atom:
    label: int


@dataclass(frozen=True)
class Compose:
    left: "ResearchObject"
    right: "ResearchObject"


@dataclass(frozen=True)
class Bootstrap:
    inner: "ResearchObject"


@dataclass(frozen=True)
class OracleNode:
    deps: Tuple["ResearchObject", ...]


ResearchObject = Union[Atom, Compose, Bootstrap, OracleNode]


def nat_depth(obj: ResearchObject) -> int:
    """Computable depth = ordinal researchDepth for finitely branching trees.

    Atoms have depth 1; compose adds; bootstrap takes the successor; an
    oracle node takes the max over children of (child depth + 1), with the
    empty node having depth 0.  Because the tree is finite, the result is a
    natural number, witnessing the Finite Branching Collapse Theorem
    (researchDepth A < omega).
    """
    if isinstance(obj, Atom):
        return 1
    if isinstance(obj, Compose):
        return nat_depth(obj.left) + nat_depth(obj.right)
    if isinstance(obj, Bootstrap):
        return nat_depth(obj.inner) + 1
    if isinstance(obj, OracleNode):
        if not obj.deps:
            return 0
        return max(nat_depth(child) + 1 for child in obj.deps)
    raise TypeError(f"unknown ResearchObject: {obj!r}")
