#!/usr/bin/env python3
"""Numerical demonstrations of dyadic approximation by width-one ReLU networks.

The script uses Python's standard-library Decimal arithmetic.  It extracts dyadic
prefixes, derives binary layer biases, runs the scalar ReLU recurrence, and checks
both the exact hidden-state identity and the universal 2**(-n) error certificate.
"""

from __future__ import annotations

from dataclasses import dataclass
from decimal import Decimal, getcontext
from typing import Iterable, Sequence

getcontext().prec = 100

PI = Decimal(
    "3.141592653589793238462643383279502884197169399375105820974944592307816406286"
)
E = Decimal(
    "2.718281828459045235360287471352662497757247093699959574966967627724076630353"
)
SQRT2 = Decimal(
    "1.414213562373095048801688724209698078569671875376948073176679737990732478462"
)


@dataclass(frozen=True)
class ApproximationRow:
    """One certified stage of a dyadic ReLU computation."""

    depth: int
    hidden_state: int
    approximation: Decimal
    error: Decimal
    upper_bound: Decimal


def relu_integer(value: int) -> int:
    """Apply ReLU exactly to an integer."""
    return max(value, 0)


def dyadic_prefix(target: Decimal, depth: int) -> int:
    """Return floor(2**depth * target) exactly at the active Decimal precision."""
    if target < 0:
        raise ValueError("This demonstration expects a nonnegative target.")
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    return int(target * (2**depth))


def transition_bits(target: Decimal, depth: int) -> list[int]:
    """Extract b_k = floor(2**(k+1)x) - 2 floor(2**k x)."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    prefixes = [dyadic_prefix(target, k) for k in range(depth + 1)]
    bits = [prefixes[k + 1] - 2 * prefixes[k] for k in range(depth)]
    if any(bit not in (0, 1) for bit in bits):
        raise ArithmeticError("Insufficient precision or an invalid binary transition.")
    return bits


def run_width_one_network(target: Decimal, depth: int) -> int:
    """Run h_(k+1)=ReLU(2 h_k+b_k) and return the depth-n state."""
    hidden = dyadic_prefix(target, 0)
    for bit in transition_bits(target, depth):
        hidden = relu_integer(2 * hidden + bit)
    expected = dyadic_prefix(target, depth)
    if hidden != expected:
        raise AssertionError("The neural state did not equal the dyadic numerator.")
    return hidden


def approximation_row(target: Decimal, depth: int) -> ApproximationRow:
    """Compute one approximation and check 0 <= x-A_n < 2**(-n)."""
    hidden = run_width_one_network(target, depth)
    denominator = Decimal(2) ** depth
    approximation = Decimal(hidden) / denominator
    error = target - approximation
    upper_bound = Decimal(1) / denominator
    if not (Decimal(0) <= error < upper_bound):
        raise AssertionError("The dyadic error certificate failed.")
    return ApproximationRow(depth, hidden, approximation, error, upper_bound)


def approximation_table(
    target: Decimal, depths: Iterable[int]
) -> list[ApproximationRow]:
    """Evaluate and certify a sequence of requested depths."""
    return [approximation_row(target, depth) for depth in depths]


def sufficient_depth(epsilon: Decimal) -> int:
    """Return the least n found by doubling for which 2**(-n) < epsilon."""
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")
    depth = 0
    bound = Decimal(1)
    while bound >= epsilon:
        depth += 1
        bound /= 2
    return depth


def format_bits(bits: Sequence[int], group: int = 4) -> str:
    """Format a binary bias stream in readable groups."""
    text = "".join(str(bit) for bit in bits)
    return " ".join(text[i : i + group] for i in range(0, len(text), group))


def print_demo(name: str, target: Decimal, depths: Sequence[int]) -> None:
    """Print a certified table and the corresponding initial bias stream."""
    max_depth = max(depths, default=0)
    print(f"\n{name}")
    print("-" * len(name))
    print(f"first {max_depth} binary biases: {format_bits(transition_bits(target, max_depth))}")
    print(f"{'n':>4} {'hidden state':>24} {'approximation':>24} {'error':>16} {'2^-n':>16}")
    for row in approximation_table(target, depths):
        print(
            f"{row.depth:4d} {row.hidden_state:24d} "
            f"{str(row.approximation):>24} "
            f"{str(row.error):>16} {str(row.upper_bound):>16}"
        )


def main() -> None:
    """Run demonstrations for pi, e, sqrt(2), and explicit tolerance selection."""
    depths = (0, 4, 8, 12, 20, 32, 50)
    print_demo("Pi: exact dyadic-prefix network", PI, depths)
    print_demo("Euler's number: the same compiler", E, depths)
    print_demo("Square root of two: the same compiler", SQRT2, depths)

    print("\nTolerance-to-depth certificates for pi")
    print("--------------------------------------")
    for epsilon in (Decimal("1e-3"), Decimal("1e-6"), Decimal("1e-12")):
        depth = sufficient_depth(epsilon)
        row = approximation_row(PI, depth)
        print(
            f"epsilon={epsilon}: depth={depth}, error={row.error}, "
            f"guaranteed bound={row.upper_bound}"
        )
        assert row.error < epsilon


if __name__ == "__main__":
    main()
