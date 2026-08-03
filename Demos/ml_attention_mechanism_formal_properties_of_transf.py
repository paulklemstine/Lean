"""Numerical demonstrations of finite scaled dot-product attention.

The script uses only Python's standard library.  It demonstrates positive and
row-stochastic softmax weights, exact token-relabeling behavior up to floating-
point roundoff, preservation of constant values, and closure under stacking.
"""

from __future__ import annotations

from math import exp, sqrt
from random import Random
from typing import Callable, List, Sequence, Tuple

Matrix = List[List[float]]


def validate_rectangular(x: Sequence[Sequence[float]], name: str) -> None:
    if not x or not x[0]:
        raise ValueError(f"{name} must be a nonempty rectangular matrix")
    width = len(x[0])
    if any(len(row) != width for row in x):
        raise ValueError(f"{name} must be rectangular")


def matmul(a: Sequence[Sequence[float]], b: Sequence[Sequence[float]]) -> Matrix:
    validate_rectangular(a, "left matrix")
    validate_rectangular(b, "right matrix")
    if len(a[0]) != len(b):
        raise ValueError("incompatible matrix dimensions")
    return [
        [sum(a[i][k] * b[k][j] for k in range(len(b))) for j in range(len(b[0]))]
        for i in range(len(a))
    ]


def transpose(x: Sequence[Sequence[float]]) -> Matrix:
    validate_rectangular(x, "matrix")
    return [[x[i][j] for i in range(len(x))] for j in range(len(x[0]))]


def stable_softmax_rows(scores: Sequence[Sequence[float]]) -> Matrix:
    """Return row-wise softmax, stabilized by subtracting each row maximum."""
    validate_rectangular(scores, "scores")
    result: Matrix = []
    for row in scores:
        maximum = max(row)
        numerators = [exp(value - maximum) for value in row]
        denominator = sum(numerators)
        result.append([value / denominator for value in numerators])
    return result


def attention(
    queries: Sequence[Sequence[float]],
    keys: Sequence[Sequence[float]],
    values: Sequence[Sequence[float]],
    scale: float | None = None,
) -> Tuple[Matrix, Matrix]:
    """Compute stable scaled dot-product attention and return (output, weights)."""
    validate_rectangular(queries, "queries")
    validate_rectangular(keys, "keys")
    validate_rectangular(values, "values")
    token_count = len(queries)
    feature_count = len(queries[0])
    if len(keys) != token_count or len(values) != token_count:
        raise ValueError("queries, keys, and values need the same token count")
    if len(keys[0]) != feature_count:
        raise ValueError("queries and keys need the same feature dimension")
    divisor = sqrt(feature_count) if scale is None else scale
    if divisor == 0.0:
        raise ValueError("scale must be nonzero")
    raw_scores = matmul(queries, transpose(keys))
    scores = [[entry / divisor for entry in row] for row in raw_scores]
    weights = stable_softmax_rows(scores)
    return matmul(weights, values), weights


def permute_rows(x: Sequence[Sequence[float]], order: Sequence[int]) -> Matrix:
    """Place old rows into the displayed order; order[r] is the old row at new row r."""
    if sorted(order) != list(range(len(x))):
        raise ValueError("order must be a permutation of row indices")
    return [list(x[index]) for index in order]


def max_abs_difference(a: Sequence[Sequence[float]], b: Sequence[Sequence[float]]) -> float:
    if len(a) != len(b) or any(len(x) != len(y) for x, y in zip(a, b)):
        raise ValueError("matrices must have equal shapes")
    return max(abs(x - y) for row_a, row_b in zip(a, b) for x, y in zip(row_a, row_b))


def random_matrix(rng: Random, rows: int, columns: int) -> Matrix:
    return [[rng.uniform(-2.0, 2.0) for _ in range(columns)] for _ in range(rows)]


def equivariance_residual(
    queries: Matrix, keys: Matrix, values: Matrix, order: Sequence[int]
) -> float:
    original, _ = attention(queries, keys, values)
    moved, _ = attention(
        permute_rows(queries, order),
        permute_rows(keys, order),
        permute_rows(values, order),
    )
    return max_abs_difference(moved, permute_rows(original, order))


def stacked_attention(x: Matrix) -> Matrix:
    """Two self-attention layers, used to illustrate compositional closure."""
    first, _ = attention(x, x, x)
    second, _ = attention(first, first, first)
    return second


def main() -> None:
    rng = Random(20260803)
    token_count, feature_count, value_count = 5, 4, 3
    q = random_matrix(rng, token_count, feature_count)
    k = random_matrix(rng, token_count, feature_count)
    v = random_matrix(rng, token_count, value_count)
    output, weights = attention(q, k, v)

    print("Scaled dot-product attention diagnostics")
    print("-" * 48)
    print(f"smallest weight:              {min(map(min, weights)):.12g}")
    print(f"largest row-sum error:        {max(abs(sum(row) - 1.0) for row in weights):.3e}")

    order = [2, 4, 0, 3, 1]
    print(f"equivariance residual:        {equivariance_residual(q, k, v, order):.3e}")

    constant = [1.25, -0.5, 3.0]
    constant_values = [constant[:] for _ in range(token_count)]
    constant_output, _ = attention(q, k, constant_values)
    print(f"constant-preservation error:  {max_abs_difference(constant_output, constant_values):.3e}")

    x = random_matrix(rng, token_count, feature_count)
    stacked_original = stacked_attention(x)
    stacked_moved = stacked_attention(permute_rows(x, order))
    stack_error = max_abs_difference(stacked_moved, permute_rows(stacked_original, order))
    print(f"two-layer equivariance error: {stack_error:.3e}")

    coordinate = 0
    low = min(row[coordinate] for row in v)
    high = max(row[coordinate] for row in v)
    inside = all(low - 1e-12 <= row[coordinate] <= high + 1e-12 for row in output)
    print(f"first output coordinate lies in [{low:.4f}, {high:.4f}]: {inside}")


if __name__ == "__main__":
    main()
