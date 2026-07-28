#!/usr/bin/env python3
"""Numerical demonstrations of finite bilinear-attention universality.

The program uses only the Python standard library. It checks bilinearity,
positional and affine composition, one-hot equality scores, and exact recovery
of a sequence-to-sequence table by one lookup head per possible input.
"""

from __future__ import annotations

from itertools import product
from math import isclose
from typing import Callable, Dict, Hashable, Iterable, List, Mapping, Sequence, Tuple, TypeVar

T = TypeVar("T", bound=Hashable)
Vector = List[float]
Matrix = List[List[float]]


def add(u: Sequence[float], v: Sequence[float]) -> Vector:
    """Return the coordinatewise sum of equally sized vectors."""
    if len(u) != len(v):
        raise ValueError("vector dimensions must agree")
    return [x + y for x, y in zip(u, v)]


def scale(c: float, u: Sequence[float]) -> Vector:
    """Multiply a vector by a scalar."""
    return [c * x for x in u]


def dot(u: Sequence[float], v: Sequence[float]) -> float:
    """Return the Euclidean dot product."""
    if len(u) != len(v):
        raise ValueError("vector dimensions must agree")
    return sum(x * y for x, y in zip(u, v))


def matvec(matrix: Sequence[Sequence[float]], vector: Sequence[float]) -> Vector:
    """Multiply a dense matrix by a vector."""
    if any(len(row) != len(vector) for row in matrix):
        raise ValueError("matrix and vector dimensions must agree")
    return [dot(row, vector) for row in matrix]


def bilinear_score(matrix: Sequence[Sequence[float]], query: Sequence[float],
                   key: Sequence[float]) -> float:
    """Compute the bilinear attention score q^T W k."""
    return dot(query, matvec(matrix, key))


def positional_encoding(position: Sequence[float], content: Sequence[float]) -> Vector:
    """Add a position vector to a content vector."""
    return add(content, position)


def affine_norm(scale_vector: Sequence[float], bias: Sequence[float],
                vector: Sequence[float]) -> Vector:
    """Apply the learned coordinatewise affine normalization stage."""
    if not (len(scale_vector) == len(bias) == len(vector)):
        raise ValueError("scale, bias, and vector dimensions must agree")
    return [s * x + b for s, b, x in zip(scale_vector, bias, vector)]


def one_hot(items: Sequence[T], item: T) -> Vector:
    """Embed one item as a standard basis vector indexed by items."""
    if item not in items:
        raise ValueError("item is outside the finite universe")
    return [1.0 if candidate == item else 0.0 for candidate in items]


def multi_head_lookup(items: Sequence[T], table: Mapping[T, Sequence[float]],
                      query_item: T) -> Vector:
    """Evaluate one equality-attention lookup head per finite input."""
    if not items:
        raise ValueError("the finite universe must be nonempty")
    if set(items) != set(table):
        raise ValueError("the table must contain exactly the finite universe")
    width = len(table[items[0]])
    query = one_hot(items, query_item)
    result = [0.0] * width
    for address in items:
        value = table[address]
        if len(value) != width:
            raise ValueError("all output vectors must have equal width")
        score = dot(query, one_hot(items, address))
        result = add(result, scale(score, value))
    return result


def vectors_close(u: Sequence[float], v: Sequence[float]) -> bool:
    """Compare vectors with a conservative floating-point tolerance."""
    return len(u) == len(v) and all(isclose(x, y, rel_tol=1e-12, abs_tol=1e-12)
                                    for x, y in zip(u, v))


def demonstrate_bilinearity() -> None:
    """Check all four linearity laws on a nontrivial numerical example."""
    matrix = [[2.0, -1.0, 0.5], [1.0, 3.0, -2.0], [0.0, 4.0, 1.0]]
    q1, q2 = [1.0, 2.0, -1.0], [3.0, -2.0, 0.5]
    k1, k2 = [-1.0, 4.0, 2.0], [2.0, 0.5, -3.0]
    c = -2.5
    checks = [
        isclose(bilinear_score(matrix, add(q1, q2), k1),
                bilinear_score(matrix, q1, k1) + bilinear_score(matrix, q2, k1)),
        isclose(bilinear_score(matrix, scale(c, q1), k1),
                c * bilinear_score(matrix, q1, k1)),
        isclose(bilinear_score(matrix, q1, add(k1, k2)),
                bilinear_score(matrix, q1, k1) + bilinear_score(matrix, q1, k2)),
        isclose(bilinear_score(matrix, q1, scale(c, k1)),
                c * bilinear_score(matrix, q1, k1)),
    ]
    assert all(checks)
    print("Bilinearity: all four superposition laws hold numerically.")


def demonstrate_composition() -> None:
    """Check positional and affine fusion identities."""
    x = [1.5, -2.0, 4.0]
    p1, p2 = [0.1, 0.2, 0.3], [2.0, -1.0, 0.5]
    nested_position = positional_encoding(p2, positional_encoding(p1, x))
    fused_position = positional_encoding(add(p1, p2), x)
    assert vectors_close(nested_position, fused_position)

    s1, b1 = [2.0, -1.0, 0.5], [1.0, 3.0, -2.0]
    s2, b2 = [4.0, 5.0, -3.0], [-2.0, 1.0, 6.0]
    nested_affine = affine_norm(s2, b2, affine_norm(s1, b1, x))
    fused_scale = [a * b for a, b in zip(s2, s1)]
    fused_bias = [a * b + c for a, b, c in zip(s2, b1, b2)]
    fused_affine = affine_norm(fused_scale, fused_bias, x)
    assert vectors_close(nested_affine, fused_affine)
    print("Composition: positional addition and affine fusion are exact.")


def demonstrate_sequence_universality() -> None:
    """Recover an arbitrary table on all length-three binary sequences."""
    sequences: List[Tuple[int, ...]] = list(product((0, 1), repeat=3))
    table: Dict[Tuple[int, ...], Vector] = {
        sequence: [float(sum(sequence) % 2), float(sum(sequence)),
                   float(2 * sequence[0] - sequence[1] + 3 * sequence[2])]
        for sequence in sequences
    }
    gram = [[dot(one_hot(sequences, x), one_hot(sequences, a))
             for a in sequences] for x in sequences]
    assert gram == [[1.0 if i == j else 0.0 for j in range(8)] for i in range(8)]
    for sequence in sequences:
        recovered = multi_head_lookup(sequences, table, sequence)
        assert vectors_close(recovered, table[sequence])
    print("Finite universality: all 8 binary sequences are recovered exactly.")
    print("Example 011 ->", multi_head_lookup(sequences, table, (0, 1, 1)))
    print("Heads required for alphabet size v and length n: v**n = 2**3 = 8.")


def main() -> None:
    """Run every demonstration and fail immediately if an identity is violated."""
    demonstrate_bilinearity()
    demonstrate_composition()
    demonstrate_sequence_universality()


if __name__ == "__main__":
    main()
