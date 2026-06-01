#!/usr/bin/env python3
"""
Boolean Function Sensitivity: Computational Demonstrations

This script demonstrates the key concepts from the sensitivity conjecture
theory, computing sensitivity, influence, and related measures for various
Boolean functions.
"""

from typing import Callable, List, Tuple
import itertools


# Type alias for Boolean functions
BoolFun = Callable[[Tuple[bool, ...]], bool]


def flip_at(x: Tuple[bool, ...], i: int) -> Tuple[bool, ...]:
    """Flip the i-th bit of input x."""
    return x[:i] + (not x[i],) + x[i+1:]


def all_inputs(n: int) -> List[Tuple[bool, ...]]:
    """Generate all 2^n Boolean inputs of length n."""
    return list(itertools.product([False, True], repeat=n))


def local_sensitivity(f: BoolFun, x: Tuple[bool, ...]) -> int:
    """Compute the local sensitivity of f at input x."""
    n = len(x)
    return sum(1 for i in range(n) if f(x) != f(flip_at(x, i)))


def sensitivity(f: BoolFun, n: int) -> int:
    """Compute the sensitivity of f."""
    return max(local_sensitivity(f, x) for x in all_inputs(n))


def influence_at(f: BoolFun, n: int, i: int) -> int:
    """Compute the influence of coordinate i."""
    return sum(1 for x in all_inputs(n) if f(x) != f(flip_at(x, i)))


def total_influence(f: BoolFun, n: int) -> int:
    """Compute the total influence of f."""
    return sum(influence_at(f, n, i) for i in range(n))


def is_certificate(f: BoolFun, x: Tuple[bool, ...], S: set) -> bool:
    """Check if S is a certificate for f at x."""
    n = len(x)
    for y in all_inputs(n):
        if all(y[i] == x[i] for i in S):
            if f(y) != f(x):
                return False
    return True


def min_certificate_size(f: BoolFun, x: Tuple[bool, ...]) -> int:
    """Compute the minimum certificate size for f at x."""
    n = len(x)
    for size in range(n + 1):
        for S in itertools.combinations(range(n), size):
            if is_certificate(f, x, set(S)):
                return size
    return n


def real_degree(f: BoolFun, n: int) -> int:
    """Compute the degree of f as a multilinear polynomial over R.
    Uses Möbius inversion on the Fourier coefficients."""
    # Compute multilinear representation coefficients
    max_deg = 0
    for size in range(n, -1, -1):
        for S in itertools.combinations(range(n), size):
            # Compute coefficient for monomial prod_{i in S} x_i
            coeff = 0
            for T_bits in itertools.product([False, True], repeat=size):
                x = [False] * n
                sign = 1
                for idx, bit in zip(S, T_bits):
                    x[idx] = bit
                    if not bit:
                        sign *= -1
                # Sum over all assignments to non-S variables
                for rest_bits in itertools.product([False, True], repeat=n - size):
                    y = list(x)
                    rest_idx = 0
                    for j in range(n):
                        if j not in S:
                            y[j] = rest_bits[rest_idx]
                            rest_idx += 1
                    coeff += sign * (1 if f(tuple(y)) else 0)
            if coeff != 0:
                max_deg = max(max_deg, size)
                break
        if max_deg == size:
            break
    return max_deg


# === Boolean Function Examples ===

def and_fun(x: Tuple[bool, ...]) -> bool:
    return all(x)

def or_fun(x: Tuple[bool, ...]) -> bool:
    return any(x)

def parity_fun(x: Tuple[bool, ...]) -> bool:
    return sum(x) % 2 == 1

def majority_fun(x: Tuple[bool, ...]) -> bool:
    return sum(x) > len(x) // 2

def threshold_fun(k: int) -> BoolFun:
    def f(x: Tuple[bool, ...]) -> bool:
        return sum(x) >= k
    return f

def tribes_fun(x: Tuple[bool, ...]) -> bool:
    """Tribes function: OR of ANDs of groups of ~log(n) bits."""
    n = len(x)
    if n <= 1:
        return x[0] if n == 1 else False
    group_size = max(1, n.bit_length() - 1)
    for start in range(0, n, group_size):
        group = x[start:min(start + group_size, n)]
        if all(group):
            return True
    return False


def main():
    print("=" * 70)
    print("BOOLEAN FUNCTION SENSITIVITY: COMPUTATIONAL DEMONSTRATIONS")
    print("=" * 70)

    for n in [3, 4, 5]:
        print(f"\n{'='*70}")
        print(f"n = {n}")
        print(f"{'='*70}")

        functions = {
            "AND": and_fun,
            "OR": or_fun,
            "PARITY": parity_fun,
            "MAJORITY": majority_fun,
            f"THRESHOLD({n//2})": threshold_fun(n // 2),
            "TRIBES": tribes_fun,
        }

        print(f"\n{'Function':<20} {'s(f)':<8} {'I(f)':<8} {'deg(f)':<8} {'s≤deg?':<8}")
        print("-" * 52)

        for name, f in functions.items():
            s = sensitivity(f, n)
            inf = total_influence(f, n)
            # Degree computation is expensive; skip for n > 4
            if n <= 4:
                deg = real_degree(f, n)
                check = "✓" if s <= deg else "✗"
                print(f"{name:<20} {s:<8} {inf:<8} {deg:<8} {check:<8}")
            else:
                print(f"{name:<20} {s:<8} {inf:<8} {'—':<8} {'—':<8}")

    # Demonstrate the double counting identity
    print(f"\n{'='*70}")
    print("DOUBLE COUNTING IDENTITY VERIFICATION")
    print("I(f) = Σ_x s(f,x)")
    print(f"{'='*70}")

    n = 4
    for name, f in [("AND", and_fun), ("PARITY", parity_fun), ("MAJORITY", majority_fun)]:
        inf = total_influence(f, n)
        sum_local = sum(local_sensitivity(f, x) for x in all_inputs(n))
        print(f"{name}: I(f) = {inf}, Σ s(f,x) = {sum_local}, equal: {inf == sum_local}")

    # Demonstrate sensitivity-certificate bound
    print(f"\n{'='*70}")
    print("SENSITIVITY ≤ CERTIFICATE COMPLEXITY VERIFICATION")
    print(f"{'='*70}")

    n = 4
    for name, f in [("AND", and_fun), ("PARITY", parity_fun), ("OR", or_fun)]:
        for x in all_inputs(n)[:4]:
            ls = local_sensitivity(f, x)
            mc = min_certificate_size(f, x)
            x_str = ''.join('1' if b else '0' for b in x)
            print(f"{name} at {x_str}: local_sens = {ls}, min_cert = {mc}, s≤C: {ls <= mc}")

    # Demonstrate sensitivity zero ↔ constant
    print(f"\n{'='*70}")
    print("SENSITIVITY ZERO ↔ CONSTANT FUNCTION")
    print(f"{'='*70}")

    n = 3
    const_true = lambda x: True
    const_false = lambda x: False
    print(f"const_true: s = {sensitivity(const_true, n)} (expected 0)")
    print(f"const_false: s = {sensitivity(const_false, n)} (expected 0)")
    print(f"AND: s = {sensitivity(and_fun, n)} (expected > 0)")

    # Conjecture test: s(f) ≤ deg(f) for all functions on n=3
    print(f"\n{'='*70}")
    print("CONJECTURE TEST: s(f) ≤ deg(f) for ALL functions on n=3")
    print(f"{'='*70}")

    n = 3
    inputs = all_inputs(n)
    violations = 0
    total_checked = 0

    for bits in itertools.product([False, True], repeat=2**n):
        f = lambda x, b=bits: b[sum(v * (2**i) for i, v in enumerate(x))]
        s = sensitivity(f, n)
        if s > 0:  # Skip constant functions
            deg = real_degree(f, n)
            total_checked += 1
            if s > deg:
                violations += 1
                print(f"  VIOLATION: s={s} > deg={deg}")

    print(f"Checked {total_checked} non-constant functions, violations: {violations}")
    if violations == 0:
        print("✓ Conjecture holds for all Boolean functions on 3 variables!")

    # Hypercube degree verification
    print(f"\n{'='*70}")
    print("HYPERCUBE DEGREE VERIFICATION: every vertex has degree n")
    print(f"{'='*70}")

    n = 4
    all_correct = True
    for x in all_inputs(n):
        neighbors = [flip_at(x, i) for i in range(n)]
        deg = len(set(neighbors))
        if deg != n:
            print(f"  FAILURE at {x}: degree = {deg}")
            all_correct = False
    print(f"n={n}: All {2**n} vertices have degree {n}: {all_correct}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Boolean Function Sensitivity Landscape

Generates a heatmap of local sensitivity across all inputs for various
Boolean functions, plus a comparison chart of complexity measures.
"""

import itertools
from typing import Callable, List, Tuple

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


BoolInput = Tuple[bool, ...]
BoolFun = Callable[[BoolInput], bool]


def flip_at(x: BoolInput, i: int) -> BoolInput:
    lst = list(x)
    lst[i] = not lst[i]
    return tuple(lst)


def all_inputs(n: int) -> List[BoolInput]:
    return list(itertools.product([False, True], repeat=n))


def local_sensitivity(f: BoolFun, x: BoolInput) -> int:
    n = len(x)
    return sum(1 for i in range(n) if f(x) != f(flip_at(x, i)))


def sensitivity(f: BoolFun, n: int) -> int:
    return max(local_sensitivity(f, x) for x in all_inputs(n))


def total_influence(f: BoolFun, n: int) -> int:
    total = 0
    for i in range(n):
        for x in all_inputs(n):
            if f(x) != f(flip_at(x, i)):
                total += 1
    return total


def and_fun(x: BoolInput) -> bool:
    return all(x)

def or_fun(x: BoolInput) -> bool:
    return any(x)

def parity_fun(x: BoolInput) -> bool:
    return sum(x) % 2 == 1

def majority_fun(x: BoolInput) -> bool:
    return sum(x) > len(x) // 2


def plot_sensitivity_heatmap(n: int = 5) -> None:
    """Plot local sensitivity heatmap for various functions."""
    inputs = all_inputs(n)
    functions = {
        "AND": and_fun,
        "OR": or_fun,
        "PARITY": parity_fun,
        "MAJORITY": majority_fun,
    }

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle(f"Local Sensitivity Heatmaps (n={n})", fontsize=16, fontweight='bold')

    for ax, (name, f) in zip(axes.flatten(), functions.items()):
        sensitivities = [local_sensitivity(f, x) for x in inputs]

        # Reshape into a grid (use Gray code ordering for better visualization)
        side = 2 ** (n // 2)
        other = 2 ** (n - n // 2)
        data = np.array(sensitivities).reshape(other, side)

        im = ax.imshow(data, cmap='YlOrRd', aspect='auto', vmin=0, vmax=n)
        ax.set_title(f"{name}: s(f) = {max(sensitivities)}", fontsize=13)
        ax.set_xlabel("Input (low bits)")
        ax.set_ylabel("Input (high bits)")
        plt.colorbar(im, ax=ax, label="Local sensitivity")

    plt.tight_layout()
    plt.savefig("sensitivity_heatmap.png", dpi=150, bbox_inches='tight')
    print("Saved sensitivity_heatmap.png")


def plot_complexity_comparison() -> None:
    """Compare sensitivity and total influence across dimensions."""
    ns = list(range(1, 8))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Boolean Function Complexity Measures", fontsize=16, fontweight='bold')

    functions = {
        "AND": and_fun,
        "OR": or_fun,
        "PARITY": parity_fun,
        "MAJORITY": majority_fun,
    }
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

    # Plot 1: Sensitivity vs n
    for (name, f), color in zip(functions.items(), colors):
        sens = [sensitivity(f, n) for n in ns]
        ax1.plot(ns, sens, 'o-', color=color, label=name, linewidth=2, markersize=8)

    ax1.plot(ns, ns, 'k--', alpha=0.3, label='n (upper bound)')
    ax1.set_xlabel("Number of variables (n)", fontsize=12)
    ax1.set_ylabel("Sensitivity s(f)", fontsize=12)
    ax1.set_title("Sensitivity vs Dimension", fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Total influence vs n
    for (name, f), color in zip(functions.items(), colors):
        inf = [total_influence(f, n) for n in ns]
        ax2.plot(ns, inf, 's-', color=color, label=name, linewidth=2, markersize=8)

    ax2.set_xlabel("Number of variables (n)", fontsize=12)
    ax2.set_ylabel("Total influence I(f)", fontsize=12)
    ax2.set_title("Total Influence vs Dimension", fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("complexity_comparison.png", dpi=150, bbox_inches='tight')
    print("Saved complexity_comparison.png")


def plot_sensitivity_distribution(n: int = 5) -> None:
    """Plot the distribution of local sensitivities for each function."""
    inputs = all_inputs(n)

    functions = {
        "AND": and_fun,
        "OR": or_fun,
        "PARITY": parity_fun,
        "MAJORITY": majority_fun,
    }

    fig, ax = plt.subplots(figsize=(10, 6))
    fig.suptitle(f"Distribution of Local Sensitivities (n={n})",
                 fontsize=16, fontweight='bold')

    width = 0.2
    x_positions = np.arange(n + 1)
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

    for idx, ((name, f), color) in enumerate(zip(functions.items(), colors)):
        sensitivities = [local_sensitivity(f, x) for x in inputs]
        counts = [sensitivities.count(k) for k in range(n + 1)]
        ax.bar(x_positions + idx * width - 1.5 * width, counts,
               width=width, color=color, alpha=0.8, label=name)

    ax.set_xlabel("Local sensitivity value", fontsize=12)
    ax.set_ylabel("Number of inputs", fontsize=12)
    ax.set_xticks(x_positions)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig("sensitivity_distribution.png", dpi=150, bbox_inches='tight')
    print("Saved sensitivity_distribution.png")


if __name__ == "__main__":
    plot_sensitivity_heatmap(n=5)
    plot_complexity_comparison()
    plot_sensitivity_distribution(n=5)
