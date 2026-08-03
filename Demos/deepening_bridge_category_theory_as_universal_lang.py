#!/usr/bin/env python3
"""Finite demonstrations of Yoneda-style reconstruction and isomorphism tests.

Only the Python standard library is required.  The script illustrates:
1. postcomposition on hom-sets in the category of finite sets;
2. reconstruction of a presheaf on the two-object poset 0 <= 1 from
   representable pieces indexed by its category of elements;
3. object-isomorphism reflection using permutation-induced maps.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)


def all_functions(domain: Sequence[A], codomain: Sequence[B]) -> List[Tuple[B, ...]]:
    """Encode every function domain -> codomain by its tuple of output values."""
    return list(product(codomain, repeat=len(domain)))


def postcompose(encoded_map: Tuple[A, ...], f: Dict[A, B]) -> Tuple[B, ...]:
    """Postcompose a tuple-encoded function with the lookup-table function f."""
    return tuple(f[value] for value in encoded_map)


def is_bijection_on_hom(
    test: Sequence[Hashable], source: Sequence[A], target: Sequence[B], f: Dict[A, B]
) -> bool:
    """Check whether Hom(test, source) -> Hom(test, target) is bijective."""
    source_hom = all_functions(test, source)
    target_hom = all_functions(test, target)
    image = {postcompose(g, f) for g in source_hom}
    return len(image) == len(source_hom) == len(target_hom)


def represented_hom_test(
    source: Sequence[A], target: Sequence[B], f: Dict[A, B], max_test_size: int = 3
) -> List[Tuple[int, int, int, bool]]:
    """Return test size, two hom-set cardinalities, and induced bijectivity."""
    rows: List[Tuple[int, int, int, bool]] = []
    for size in range(max_test_size + 1):
        test = tuple(range(size))
        rows.append(
            (
                size,
                len(all_functions(test, source)),
                len(all_functions(test, target)),
                is_bijection_on_hom(test, source, target, f),
            )
        )
    return rows


class DisjointSet:
    """Union-find structure for computing a finite colimit quotient."""

    def __init__(self, items: Iterable[Hashable]) -> None:
        self.parent: Dict[Hashable, Hashable] = {item: item for item in items}
        self.rank: Dict[Hashable, int] = {item: 0 for item in items}

    def find(self, item: Hashable) -> Hashable:
        parent = self.parent[item]
        if parent != item:
            self.parent[item] = self.find(parent)
        return self.parent[item]

    def union(self, left: Hashable, right: Hashable) -> None:
        a, b = self.find(left), self.find(right)
        if a == b:
            return
        if self.rank[a] < self.rank[b]:
            a, b = b, a
        self.parent[b] = a
        if self.rank[a] == self.rank[b]:
            self.rank[a] += 1

    def classes(self) -> List[List[Hashable]]:
        groups: Dict[Hashable, List[Hashable]] = {}
        for item in self.parent:
            groups.setdefault(self.find(item), []).append(item)
        return list(groups.values())


@dataclass(frozen=True)
class TwoStagePresheaf:
    """A finite presheaf on the poset category 0 <= 1.

    Contravariance supplies one restriction map P(1) -> P(0).
    """

    at_zero: Tuple[str, ...]
    at_one: Tuple[str, ...]
    restrict: Dict[str, str]

    def validate(self) -> None:
        if set(self.restrict) != set(self.at_one):
            raise ValueError("Restriction must be defined on every element of P(1).")
        if not set(self.restrict.values()).issubset(set(self.at_zero)):
            raise ValueError("Restriction values must lie in P(0).")

    def elements(self) -> List[Tuple[int, str]]:
        return [(0, x) for x in self.at_zero] + [(1, y) for y in self.at_one]


def reconstruct_at(presheaf: TwoStagePresheaf, test_object: int) -> Dict[str, object]:
    """Compute the density colimit at test_object (0 or 1).

    In the poset 0 <= 1, Hom(T, X) is a singleton exactly when T <= X.
    A representative is therefore a category-of-elements pair (X, x) with T <= X.
    Relations identify (0, restrict(y)) with (1, y) when T = 0.
    """
    presheaf.validate()
    if test_object not in (0, 1):
        raise ValueError("The test object must be 0 or 1.")

    representatives = [
        (stage, value) for stage, value in presheaf.elements() if test_object <= stage
    ]
    quotient = DisjointSet(representatives)
    if test_object == 0:
        for y in presheaf.at_one:
            quotient.union((0, presheaf.restrict[y]), (1, y))

    classes = quotient.classes()

    def evaluation(rep: Tuple[int, str]) -> str:
        stage, value = rep
        return value if stage == test_object else presheaf.restrict[value]

    class_values = [sorted({evaluation(rep) for rep in group}) for group in classes]
    expected = presheaf.at_zero if test_object == 0 else presheaf.at_one
    successful = (
        all(len(values) == 1 for values in class_values)
        and {values[0] for values in class_values} == set(expected)
        and len(classes) == len(expected)
    )
    return {
        "test_object": test_object,
        "representatives": representatives,
        "equivalence_classes": classes,
        "class_values": class_values,
        "expected_sections": expected,
        "reconstruction_successful": successful,
    }


def permutation_matrix(permutation: Sequence[int]) -> List[List[int]]:
    """Return the matrix of a finite-set isomorphism in standard bases."""
    n = len(permutation)
    if sorted(permutation) != list(range(n)):
        raise ValueError("Input must be a permutation of 0, ..., n-1.")
    return [[int(permutation[column] == row) for column in range(n)] for row in range(n)]


def transpose(matrix: Sequence[Sequence[int]]) -> List[List[int]]:
    return [list(column) for column in zip(*matrix)]


def multiply(left: Sequence[Sequence[int]], right: Sequence[Sequence[int]]) -> List[List[int]]:
    return [
        [sum(left[i][k] * right[k][j] for k in range(len(right))) for j in range(len(right[0]))]
        for i in range(len(left))
    ]


def run_demo() -> None:
    print("=== Represented hom-set isomorphism tests in Finite Sets ===")
    source = ("a", "b", "c")
    target = (10, 20, 30)
    bijection = {"a": 20, "b": 30, "c": 10}
    collapse = {"a": 10, "b": 10, "c": 20}
    for label, function in (("bijection", bijection), ("non-bijection", collapse)):
        print(f"\n{label}:")
        print(" |T|   |Hom(T,X)|   |Hom(T,Y)|   induced map bijective")
        for size, left, right, result in represented_hom_test(source, target, function):
            print(f" {size:>3}   {left:>10}   {right:>10}   {str(result):>22}")

    print("\n=== Density reconstruction on the site 0 <= 1 ===")
    presheaf = TwoStagePresheaf(
        at_zero=("red", "blue"),
        at_one=("circle", "square", "triangle"),
        restrict={"circle": "red", "square": "red", "triangle": "blue"},
    )
    for stage in (0, 1):
        report = reconstruct_at(presheaf, stage)
        print(f"\nAt test object {stage}:")
        print(f"  raw representable representatives: {len(report['representatives'])}")
        print(f"  quotient classes: {report['equivalence_classes']}")
        print(f"  recovered values: {report['class_values']}")
        print(f"  target sections: {report['expected_sections']}")
        print(f"  successful: {report['reconstruction_successful']}")

    print("\n=== A represented isomorphism as a permutation matrix ===")
    matrix = permutation_matrix((1, 2, 0))
    inverse = transpose(matrix)
    print("matrix:", matrix)
    print("inverse:", inverse)
    print("inverse * matrix:", multiply(inverse, matrix))


if __name__ == "__main__":
    run_demo()
