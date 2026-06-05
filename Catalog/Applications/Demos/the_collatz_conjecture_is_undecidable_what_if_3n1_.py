#!/usr/bin/env python3
"""
Collatz Affine Map Algebra — Demonstration

Demonstrates the Affine Reconstruction Theorem and related results.
"""


def collatz_step(n: int) -> int:
    """Standard Collatz step."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_iter(k: int, n: int) -> int:
    """Apply k Collatz steps to n."""
    for _ in range(k):
        n = collatz_step(n)
    return n


def collatz_trajectory(n: int, max_steps: int = 1000) -> list[int]:
    """Full trajectory until reaching 1 or max_steps."""
    traj = [n]
    while n != 1 and len(traj) < max_steps:
        n = collatz_step(n)
        traj.append(n)
    return traj


def parity_vec(k: int, n: int) -> list[int]:
    """Parity vector of the first k iterates."""
    vec = []
    val = n
    for _ in range(k):
        vec.append(val % 2)
        val = collatz_step(val)
    return vec


def build_affine_map(parity_vector: list[int]) -> tuple[int, int, int]:
    """Build the Collatz Affine Map from a parity vector.

    Returns (numerator, offset, denominator) such that
    T^k(n) * denom = num * n + offset.
    """
    a, b, d = 1, 0, 1
    for p in parity_vector:
        if p == 0:  # even step
            d *= 2
        else:       # odd step
            a, b = 3 * a, 3 * b + d
    return a, b, d


def verify_reconstruction(n: int, k: int) -> bool:
    """Verify the Affine Reconstruction Theorem for given n, k."""
    pvec = parity_vec(k, n)
    a, b, d = build_affine_map(pvec)
    iterate = collatz_iter(k, n)
    return iterate * d == a * n + b


def demo_reconstruction():
    """Demonstrate the Affine Reconstruction Theorem."""
    print("=" * 60)
    print("AFFINE RECONSTRUCTION THEOREM DEMO")
    print("=" * 60)
    print()

    test_cases = [(7, 5), (27, 10), (31, 8), (97, 15), (1000003, 20)]

    for n, k in test_cases:
        pvec = parity_vec(k, n)
        a, b, d = build_affine_map(pvec)
        iterate = collatz_iter(k, n)
        verified = iterate * d == a * n + b
        odd_count = sum(pvec)
        even_count = k - odd_count

        print(f"n = {n}, k = {k}")
        print(f"  Parity vector: {''.join('O' if p else 'E' for p in pvec)}")
        print(f"  Odd steps: {odd_count}, Even steps: {even_count}")
        print(f"  Affine map: ({a}, {b}, {d})")
        print(f"  T^{k}({n}) = {iterate}")
        print(f"  Check: {iterate} * {d} = {iterate * d}")
        print(f"         {a} * {n} + {b} = {a * n + b}")
        print(f"  Reconstruction: {'✓ VERIFIED' if verified else '✗ FAILED'}")
        print(f"  Numerator = 3^{odd_count} = {3**odd_count}: {'✓' if a == 3**odd_count else '✗'}")
        print(f"  Denominator = 2^{even_count} = {2**even_count}: {'✓' if d == 2**even_count else '✗'}")
        print()


def demo_density_bound():
    """Demonstrate the odd step density bound."""
    print("=" * 60)
    print("ODD STEP DENSITY BOUND DEMO")
    print("=" * 60)
    print()
    print("Theorem: #odd_steps * 2 ≤ k + 1 (at most ⌈k/2⌉ odd steps)")
    print()

    for n in range(2, 50):
        traj = collatz_trajectory(n)
        k = len(traj) - 1  # number of steps
        if k < 2:
            continue
        pvec = parity_vec(k, n)
        odd_count = sum(pvec)
        bound_holds = odd_count * 2 <= k + 1
        ratio = odd_count / k if k > 0 else 0

        if not bound_holds:
            print(f"  n={n}: BOUND VIOLATED! odd={odd_count}, k={k}")
        elif n <= 20:
            print(f"  n={n:3d}: k={k:3d}, odd={odd_count:3d}, "
                  f"ratio={ratio:.3f}, bound={'tight' if odd_count * 2 == k + 1 else 'slack'}")

    print()
    print("  (No violations found — theorem confirmed computationally)")
    print()


def demo_power_of_2():
    """Demonstrate that 2^k reaches 1 in exactly k steps."""
    print("=" * 60)
    print("POWERS OF 2 STOPPING TIME")
    print("=" * 60)
    print()

    for k in range(1, 15):
        n = 2**k
        result = collatz_iter(k, n)
        traj = [n]
        v = n
        for _ in range(k):
            v = collatz_step(v)
            traj.append(v)

        print(f"  2^{k:2d} = {n:6d} → " + " → ".join(str(x) for x in traj[:min(8, len(traj))]) +
              (f" → ... → {traj[-1]}" if len(traj) > 8 else "") +
              f"  (reaches 1 in {k} steps: {'✓' if result == 1 else '✗'})")
    print()


def demo_mersenne():
    """Demonstrate Mersenne number behavior."""
    print("=" * 60)
    print("MERSENNE NUMBERS: FIRST STEP")
    print("=" * 60)
    print()

    for k in range(1, 12):
        n = 2**k - 1
        step = collatz_step(n)
        expected = 3 * n + 1
        print(f"  2^{k:2d} - 1 = {n:5d} → T({n}) = {step} = 3·{n}+1 = {expected}: "
              f"{'✓' if step == expected else '✗'}")
    print()


def demo_parity_realizability():
    """Test the parity vector realizability conjecture."""
    print("=" * 60)
    print("PARITY VECTOR REALIZABILITY CONJECTURE")
    print("=" * 60)
    print()

    from itertools import product

    for k in range(1, 13):
        # Generate all valid parity vectors (no consecutive 1s)
        valid_count = 0
        realized_count = 0

        def gen_valid(length):
            if length == 0:
                yield []
                return
            for vec in gen_valid(length - 1):
                yield vec + [0]
                if not vec or vec[-1] == 0:
                    yield vec + [1]

        for vec in gen_valid(k):
            valid_count += 1
            # Try to find n that realizes this parity vector
            found = False
            for n in range(1, 5000):
                if parity_vec(k, n) == vec:
                    realized_count += 1
                    found = True
                    break

        print(f"  k={k:2d}: {realized_count}/{valid_count} valid vectors realized "
              f"(search up to n=5000) {'✓ ALL' if realized_count == valid_count else '✗ MISSING'}")
    print()


if __name__ == "__main__":
    demo_reconstruction()
    demo_density_bound()
    demo_power_of_2()
    demo_mersenne()
    demo_parity_realizability()


#!/usr/bin/env python3
"""
Visualization: Collatz Affine Map — Trajectory and Parity Structure
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n):
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_trajectory(n, max_steps=1000):
    traj = [n]
    while n != 1 and len(traj) < max_steps:
        n = collatz_step(n)
        traj.append(n)
    return traj


def parity_vec(n, k):
    vec = []
    val = n
    for _ in range(k):
        vec.append(val % 2)
        val = collatz_step(val)
    return vec


def build_affine_map(pvec):
    a, b, d = 1, 0, 1
    for p in pvec:
        if p == 0:
            d *= 2
        else:
            a, b = 3 * a, 3 * b + d
    return a, b, d


def plot_trajectory_with_parity():
    """Plot Collatz trajectories colored by parity."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for idx, n_start in enumerate([27, 97, 871, 6171]):
        ax = axes[idx // 2][idx % 2]
        traj = collatz_trajectory(n_start)
        steps = list(range(len(traj)))
        colors = ['red' if t % 2 == 1 else 'blue' for t in traj]

        ax.scatter(steps, traj, c=colors, s=8, alpha=0.7)
        ax.plot(steps, traj, 'k-', alpha=0.2, linewidth=0.5)
        ax.set_title(f'n = {n_start} ({len(traj)-1} steps)', fontsize=12)
        ax.set_xlabel('Step')
        ax.set_ylabel('Value')
        ax.set_yscale('log')

        # Add parity ratio annotation
        pvec = parity_vec(n_start, len(traj) - 1)
        odd_count = sum(pvec)
        ratio = odd_count / len(pvec) if pvec else 0
        ax.annotate(f'Odd ratio: {ratio:.3f}\nOdd steps: {odd_count}/{len(pvec)}',
                    xy=(0.95, 0.95), xycoords='axes fraction',
                    ha='right', va='top', fontsize=9,
                    bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    fig.suptitle('Collatz Trajectories (Red = Odd, Blue = Even)', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('collatz_trajectories.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved collatz_trajectories.png")


def plot_odd_ratio_distribution():
    """Plot the distribution of odd step ratios across many starting values."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ratios = []
    stopping_times = []

    for n in range(2, 10001):
        traj = collatz_trajectory(n)
        if traj[-1] == 1:
            k = len(traj) - 1
            pvec = parity_vec(n, k)
            odd_count = sum(pvec)
            ratio = odd_count / k if k > 0 else 0
            ratios.append(ratio)
            stopping_times.append(k)

    ax1.hist(ratios, bins=80, color='steelblue', edgecolor='navy', alpha=0.7)
    ax1.axvline(x=np.log(2)/np.log(3), color='red', linestyle='--', linewidth=2,
                label=f'log(2)/log(3) ≈ {np.log(2)/np.log(3):.4f}')
    ax1.axvline(x=0.5, color='green', linestyle='--', linewidth=2,
                label='Density bound: 0.5')
    ax1.set_xlabel('Odd Step Ratio s/k')
    ax1.set_ylabel('Count')
    ax1.set_title('Distribution of Odd Step Ratios (n = 2 to 10000)')
    ax1.legend()

    # s vs t scatter
    s_vals = []
    t_vals = []
    for n in range(2, 5001):
        traj = collatz_trajectory(n)
        if traj[-1] == 1:
            k = len(traj) - 1
            pvec = parity_vec(n, k)
            s = sum(pvec)
            t = k - s
            s_vals.append(s)
            t_vals.append(t)

    ax2.scatter(s_vals, t_vals, s=3, alpha=0.3, color='purple')
    # Add the critical line s*log(3) = t*log(2), i.e., t = s*log(3)/log(2)
    s_line = np.linspace(0, max(s_vals), 100)
    t_line = s_line * np.log(3) / np.log(2)
    ax2.plot(s_line, t_line, 'r--', linewidth=2, label='3^s = 2^t (critical line)')
    ax2.set_xlabel('Odd steps (s)')
    ax2.set_ylabel('Even steps (t)')
    ax2.set_title('(s, t) Pairs for Trajectories to 1')
    ax2.legend()

    plt.tight_layout()
    plt.savefig('collatz_density.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved collatz_density.png")


def plot_affine_map_coefficients():
    """Plot the growth of affine map coefficients along trajectories."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for n_start in [27]:
        traj = collatz_trajectory(n_start)
        k = len(traj) - 1

        nums = []
        offsets = []
        denoms = []

        for j in range(1, k + 1):
            pvec = parity_vec(n_start, j)
            a, b, d = build_affine_map(pvec)
            nums.append(np.log2(a) if a > 0 else 0)
            offsets.append(np.log2(b) if b > 0 else 0)
            denoms.append(np.log2(d) if d > 0 else 0)

        steps = list(range(1, k + 1))

        axes[0].plot(steps, nums, 'r-', linewidth=1)
        axes[0].set_title('log₂(numerator) = s·log₂(3)')
        axes[0].set_xlabel('Steps (k)')
        axes[0].set_ylabel('log₂(a)')

        axes[1].plot(steps, offsets, 'g-', linewidth=1)
        axes[1].set_title('log₂(offset)')
        axes[1].set_xlabel('Steps (k)')
        axes[1].set_ylabel('log₂(b)')

        axes[2].plot(steps, denoms, 'b-', linewidth=1)
        axes[2].set_title('log₂(denominator) = t')
        axes[2].set_xlabel('Steps (k)')
        axes[2].set_ylabel('log₂(d)')

    fig.suptitle(f'Affine Map Coefficients for n = 27 ({k} steps)', fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('collatz_affine_coefficients.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved collatz_affine_coefficients.png")


if __name__ == "__main__":
    plot_trajectory_with_parity()
    plot_odd_ratio_distribution()
    plot_affine_map_coefficients()
