#!/usr/bin/env python3
"""Numerical demonstrations for category-theoretic neural architectures.

The script uses only the Python standard library.  It demonstrates:
1. the two projections and additive readout of a residual product lift;
2. the (1 + K)-Lipschitz certificate for a linear residual branch;
3. commutation of two-head swapping with componentwise feature transport;
4. exhaustive minimization over a finite architecture candidate set.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import sqrt
from typing import Callable, Iterable, Sequence, TypeVar

Vector = tuple[float, ...]
Matrix = tuple[tuple[float, ...], ...]
T = TypeVar("T")


def add(x: Vector, y: Vector) -> Vector:
    """Return the componentwise sum of equally sized vectors."""
    if len(x) != len(y):
        raise ValueError("vectors must have equal dimension")
    return tuple(a + b for a, b in zip(x, y))


def sub(x: Vector, y: Vector) -> Vector:
    """Return the componentwise difference of equally sized vectors."""
    if len(x) != len(y):
        raise ValueError("vectors must have equal dimension")
    return tuple(a - b for a, b in zip(x, y))


def norm(x: Vector) -> float:
    """Return the Euclidean norm."""
    return sqrt(sum(a * a for a in x))


def matvec(matrix: Matrix, x: Vector) -> Vector:
    """Multiply a rectangular matrix by a compatible vector."""
    if any(len(row) != len(x) for row in matrix):
        raise ValueError("matrix and vector dimensions are incompatible")
    return tuple(sum(a * b for a, b in zip(row, x)) for row in matrix)


def residual_lift(x: Vector, residual: Callable[[Vector], Vector]) -> tuple[Vector, Vector]:
    """The product pairing x |-> (x, residual(x))."""
    return x, residual(x)


def residual_block(x: Vector, residual: Callable[[Vector], Vector]) -> Vector:
    """Apply additive readout to the identity and residual branches."""
    identity_branch, learned_branch = residual_lift(x, residual)
    return add(identity_branch, learned_branch)


def swap_heads(heads: tuple[Vector, Vector]) -> tuple[Vector, Vector]:
    """Exchange two feature heads."""
    return heads[1], heads[0]


def transport_heads(matrix: Matrix, heads: tuple[Vector, Vector]) -> tuple[Vector, Vector]:
    """Transport both heads by the same linear representation map."""
    return matvec(matrix, heads[0]), matvec(matrix, heads[1])


@dataclass(frozen=True)
class Candidate:
    """A named finite-search candidate with a precomputed illustrative loss."""

    name: str
    topology: str
    loss: float


def finite_argmin(items: Sequence[T], loss: Callable[[T], float]) -> tuple[T, float]:
    """Return the first minimum of a nonempty finite sequence.

    The function performs n loss evaluations and n - 1 comparisons, uses O(1)
    auxiliary storage, and preserves first-occurrence tie-breaking.
    """
    if not items:
        raise ValueError("finite_argmin requires a nonempty candidate sequence")
    best = items[0]
    best_loss = loss(best)
    for candidate in items[1:]:
        candidate_loss = loss(candidate)
        if candidate_loss < best_loss:
            best, best_loss = candidate, candidate_loss
    return best, best_loss


def demonstrate_residual() -> None:
    """Print projection identities and a sampled Lipschitz ratio."""
    matrix: Matrix = ((0.3, 0.0), (0.0, -0.2))
    residual = lambda z: matvec(matrix, z)
    x: Vector = (1.0, -2.0)
    y: Vector = (-1.0, 1.0)
    lifted = residual_lift(x, residual)
    assert lifted[0] == x
    assert lifted[1] == residual(x)

    bx, by = residual_block(x, residual), residual_block(y, residual)
    ratio = norm(sub(bx, by)) / norm(sub(x, y))
    k = 0.3  # Euclidean operator norm of the diagonal residual matrix.
    assert ratio <= 1.0 + k + 1e-12

    print("Residual product lift")
    print(f"  input x:                    {x}")
    print(f"  first projection (skip):   {lifted[0]}")
    print(f"  second projection:         {lifted[1]}")
    print(f"  additive block B(x):       {bx}")
    print(f"  sampled Lipschitz ratio:   {ratio:.6f}")
    print(f"  certified upper bound:     {1.0 + k:.6f}\n")


def demonstrate_naturality() -> None:
    """Check the commuting square for head exchange exactly in floating arithmetic."""
    matrix: Matrix = ((2.0, 1.0), (0.0, -1.0))
    heads: tuple[Vector, Vector] = ((1.0, 2.0), (-1.0, 3.0))
    swap_then_transport = transport_heads(matrix, swap_heads(heads))
    transport_then_swap = swap_heads(transport_heads(matrix, heads))
    assert swap_then_transport == transport_then_swap

    print("Two-head attention naturality")
    print(f"  swap then transport:       {swap_then_transport}")
    print(f"  transport then swap:       {transport_then_swap}")
    print("  commuting square:          verified\n")


def demonstrate_search() -> None:
    """Run topology-aware finite minimization with deterministic tie-breaking."""
    candidates = (
        Candidate("shallow residual", "input -> residual -> output", 0.42),
        Candidate("two-head natural", "input -> two heads -> swap -> output", 0.31),
        Candidate("deep residual", "input -> residual -> residual -> output", 0.37),
        Candidate("parallel hybrid", "input -> parallel branches -> output", 0.31),
    )
    best, value = finite_argmin(candidates, lambda candidate: candidate.loss)
    assert value == min(candidate.loss for candidate in candidates)

    print("Finite architecture search")
    for candidate in candidates:
        print(f"  {candidate.name:20s} loss = {candidate.loss:.2f}")
    print(f"  selected first minimizer:  {best.name} (loss {value:.2f})")


def main() -> None:
    """Run all demonstrations."""
    demonstrate_residual()
    demonstrate_naturality()
    demonstrate_search()


if __name__ == "__main__":
    main()
