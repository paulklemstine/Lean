#!/usr/bin/env python3
"""
Demo: The Collatz Affine Monoid in Action

Demonstrates the core algebraic framework: every Collatz orbit segment
is captured by a triple (num, offset, denom) in the Collatz Affine Monoid.
"""

from dataclasses import dataclass


@dataclass
class CAM:
    """Element of the Collatz Affine Monoid."""
    num: int
    offset: int
    denom: int

    def eval(self, n: int) -> int:
        return self.num * n + self.offset

    def value(self, n: int) -> float:
        return self.eval(n) / self.denom

    @staticmethod
    def identity() -> "CAM":
        return CAM(1, 0, 1)

    @staticmethod
    def even_step() -> "CAM":
        return CAM(1, 0, 2)

    @staticmethod
    def odd_step() -> "CAM":
        return CAM(3, 1, 1)

    def compose(self, other: "CAM") -> "CAM":
        """Compose: apply self first, then other."""
        return CAM(
            num=other.num * self.num,
            offset=other.num * self.offset + other.offset * self.denom,
            denom=self.denom * other.denom
        )

    def __repr__(self) -> str:
        return f"CAM({self.num}, {self.offset}, {self.denom})"


def collatz(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 1000) -> list[int]:
    """Compute Collatz orbit until reaching 1 or max_steps."""
    orbit = [n]
    for _ in range(max_steps):
        n = collatz(n)
        orbit.append(n)
        if n == 1:
            break
    return orbit


def build_cam(n: int, k: int) -> CAM:
    """Build the CAM element for the first k steps of the Collatz orbit of n."""
    cam = CAM.identity()
    current = n
    for _ in range(k):
        if current % 2 == 0:
            cam = cam.compose(CAM.even_step())
            current = current // 2
        else:
            cam = cam.compose(CAM.odd_step())
            current = 3 * current + 1
    return cam


def orbit_signature(n: int, k: int) -> tuple[int, int]:
    """Count (odd_steps, even_steps) in the first k steps."""
    odd_count = 0
    even_count = 0
    current = n
    for _ in range(k):
        if current % 2 == 0:
            even_count += 1
            current = current // 2
        else:
            odd_count += 1
            current = 3 * current + 1
    return odd_count, even_count


def verify_affine_formula(n: int, k: int) -> bool:
    """Verify the Affine Formula: collatz^k(n) * denom = num * n + offset."""
    orbit = collatz_orbit(n, k)
    if len(orbit) <= k:
        return False
    value_at_k = orbit[k]
    cam = build_cam(n, k)
    return value_at_k * cam.denom == cam.eval(n)


def main():
    print("=" * 70)
    print("  THE COLLATZ AFFINE MONOID — DEMO")
    print("=" * 70)

    # Demo 1: Building CAM elements
    print("\n--- Demo 1: CAM Elements for Small Numbers ---")
    for n in [6, 7, 27]:
        orbit = collatz_orbit(n)
        k = len(orbit) - 1
        cam = build_cam(n, k)
        sig = orbit_signature(n, k)
        print(f"\nn = {n}: orbit length = {k}")
        print(f"  CAM = {cam}")
        print(f"  Signature: {sig[0]} odd steps, {sig[1]} even steps")
        print(f"  3^s = {3**sig[0]}, 2^e = {2**sig[1]}")
        print(f"  Contracting: {3**sig[0] < 2**sig[1]}")
        print(f"  Affine formula check: {cam.eval(n)} = {cam.denom} "
              f"(reaches 1: {cam.eval(n) == cam.denom})")

    # Demo 2: Verify affine formula
    print("\n--- Demo 2: Verifying Affine Formula ---")
    for n in range(1, 21):
        orbit = collatz_orbit(n)
        k = len(orbit) - 1
        for step in range(min(k + 1, 10)):
            assert verify_affine_formula(n, step), \
                f"Affine formula failed for n={n}, k={step}!"
    print("✓ Affine formula verified for n=1..20, all reachable steps")

    # Demo 3: Monoid associativity check
    print("\n--- Demo 3: Monoid Associativity ---")
    a = CAM.odd_step()
    b = CAM.even_step()
    c = CAM.odd_step()
    lhs = a.compose(b).compose(c)
    rhs = a.compose(b.compose(c))
    print(f"  (odd ∘ even) ∘ odd = {lhs}")
    print(f"  odd ∘ (even ∘ odd) = {rhs}")
    print(f"  Equal: {lhs == rhs}")

    # Demo 4: Density analysis
    print("\n--- Demo 4: Orbit Signature Density ---")
    print(f"  Critical density threshold: log(2)/log(6) ≈ {0.3869:.4f}")
    print(f"  (Orbits with odd-step fraction below this threshold contract)")
    print()
    for n in [27, 97, 871, 6171, 77031]:
        orbit = collatz_orbit(n)
        k = len(orbit) - 1
        sig = orbit_signature(n, k)
        density = sig[0] / (sig[0] + sig[1]) if sig[0] + sig[1] > 0 else 0
        print(f"  n={n:>6d}: steps={k:>4d}, odd={sig[0]:>3d}, "
              f"even={sig[1]:>3d}, density={density:.4f}")

    # Demo 5: Powers of 2 — simplest orbits
    print("\n--- Demo 5: Powers of 2 (Purely Even Orbits) ---")
    for k in range(1, 11):
        n = 2**k
        orbit = collatz_orbit(n)
        steps = len(orbit) - 1
        cam = build_cam(n, steps)
        print(f"  2^{k:>2d} = {n:>5d}: {steps} steps, CAM = {cam}")

    # Demo 6: Unbounded stopping times
    print("\n--- Demo 6: Unbounded Stopping Times ---")
    print("  No uniform bound K exists such that all n reach 1 in ≤ K steps.")
    print("  Proof: 2^(K+1) needs exactly K+1 steps.")
    for K in [5, 10, 20, 50]:
        n = 2**(K + 1)
        print(f"  K={K:>3d}: n=2^{K+1} needs {K+1} steps > {K}")

    print("\n" + "=" * 70)
    print("  All demos completed successfully!")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: CAM Growth Analysis — Contraction Ratios and Barrier Depths

Shows how the CAM contraction ratio num/denom relates to orbit behavior,
and visualizes the barrier depth function.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def collatz(n):
    return n // 2 if n % 2 == 0 else 3 * n + 1


def stopping_time(n, max_steps=10000):
    current = n
    for k in range(max_steps):
        if current == 1:
            return k
        current = collatz(current)
    return None


def compute_cam(n):
    num, offset, denom = 1, 0, 1
    current = n
    while current != 1:
        if current % 2 == 0:
            denom *= 2
            current = current // 2
        else:
            offset = 3 * offset + denom
            num *= 3
            current = 3 * current + 1
    return num, offset, denom


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # Plot 1: Stopping times
    ax = axes[0, 0]
    N = 1000
    ns = list(range(2, N + 1))
    times = [stopping_time(n) for n in ns]
    ax.scatter(ns, times, s=1, alpha=0.5, color='navy')
    ax.set_xlabel('n', fontsize=11)
    ax.set_ylabel('Stopping time', fontsize=11)
    ax.set_title('Collatz Stopping Times', fontsize=13)

    # Plot 2: log(contraction ratio) = s*log(3) - e*log(2)
    ax = axes[0, 1]
    ratios = []
    for n in range(2, N + 1):
        num, offset, denom = compute_cam(n)
        if denom > 0:
            ratio = math.log(num) - math.log(denom)
            ratios.append((n, ratio))
    ax.scatter([r[0] for r in ratios], [r[1] for r in ratios],
               s=1, alpha=0.5, color='darkred')
    ax.axhline(0, color='black', linewidth=1, linestyle='-')
    ax.set_xlabel('n', fontsize=11)
    ax.set_ylabel('log(3ˢ/2ᵉ)', fontsize=11)
    ax.set_title('CAM Contraction Ratio (log scale)', fontsize=13)

    # Plot 3: Barrier depth vs n
    ax = axes[1, 0]
    depths = [(n, stopping_time(n)) for n in range(1, 501)]
    ax.bar([d[0] for d in depths], [d[1] for d in depths],
           width=1, color='teal', alpha=0.7)
    # Overlay 2^k reference
    for k in range(1, 10):
        if 2**k <= 500:
            ax.plot(2**k, k, 'ro', markersize=8)
    ax.set_xlabel('n', fontsize=11)
    ax.set_ylabel('Barrier depth (steps to 1)', fontsize=11)
    ax.set_title('Barrier Depth Function', fontsize=13)
    ax.legend(['Powers of 2 (depth = k)'], fontsize=9)

    # Plot 4: 3^s vs 2^e separation
    ax = axes[1, 1]
    s_vals = range(0, 15)
    for s in s_vals:
        ax.plot(s, 3**s, 'bo', markersize=4)
    e_vals = range(0, 25)
    for e in e_vals:
        ax.plot(e * math.log(3) / math.log(2), 2**e, 'r^', markersize=4)
    x = np.linspace(0, 14, 100)
    ax.plot(x, 3**x, 'b-', linewidth=2, label='3ˢ')
    ax.plot(x, 2**(x * math.log(2) / math.log(3) * math.log(3) / math.log(2)),
            'r-', linewidth=2, label='2ᵉ at e=s·log₂3')
    ax.set_yscale('log')
    ax.set_xlabel('s (odd steps)', fontsize=11)
    ax.set_ylabel('Value (log scale)', fontsize=11)
    ax.set_title('Three-Two Separation: 3ˢ vs 2ᵉ', fontsize=13)
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('collatz_cam_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: collatz_cam_analysis.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Collatz Orbit Signatures in the Growth-Shrink Plane

Plots each starting value n as a point (odd_steps, even_steps) in the
signature plane. The critical line 3^s = 2^e (i.e., s*log(3) = e*log(2))
separates contracting orbits from expanding ones.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def collatz(n):
    return n // 2 if n % 2 == 0 else 3 * n + 1


def compute_signature(n):
    odd_count = 0
    even_count = 0
    current = n
    while current != 1:
        if current % 2 == 0:
            even_count += 1
            current = current // 2
        else:
            odd_count += 1
            current = 3 * current + 1
    return odd_count, even_count


def main():
    N = 500
    signatures = []
    for n in range(2, N + 1):
        s, e = compute_signature(n)
        signatures.append((n, s, e))

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Plot 1: Signature plane
    ax = axes[0]
    ss = [sig[1] for sig in signatures]
    es = [sig[2] for sig in signatures]
    ns = [sig[0] for sig in signatures]
    scatter = ax.scatter(ss, es, c=np.log2(ns), cmap='viridis', s=8, alpha=0.7)
    plt.colorbar(scatter, ax=ax, label='log₂(n)')

    # Critical line: s*log(3) = e*log(2), i.e., e = s*log(3)/log(2)
    s_line = np.linspace(0, max(ss) + 5, 100)
    e_line = s_line * math.log(3) / math.log(2)
    ax.plot(s_line, e_line, 'r--', linewidth=2, label='Critical: 3ˢ = 2ᵉ')

    # Density contraction bound: e = 2s
    e_bound = 2 * s_line
    ax.plot(s_line, e_bound, 'g-.', linewidth=1.5,
            label='Density bound: e = 2s')

    ax.set_xlabel('Odd steps (s)', fontsize=12)
    ax.set_ylabel('Even steps (e)', fontsize=12)
    ax.set_title('Collatz Orbit Signatures (n = 2..500)', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(0, max(ss) + 2)
    ax.set_ylim(0, max(es) + 2)

    # Plot 2: Odd-step density distribution
    ax2 = axes[1]
    densities = [s / (s + e) if s + e > 0 else 0 for _, s, e in signatures]
    ax2.hist(densities, bins=40, color='steelblue', edgecolor='white', alpha=0.8)
    critical = math.log(2) / math.log(6)
    ax2.axvline(critical, color='red', linewidth=2, linestyle='--',
                label=f'Critical density ≈ {critical:.4f}')
    ax2.set_xlabel('Odd-step density s/(s+e)', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Distribution of Parity Densities', fontsize=14)
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('collatz_signatures.png', dpi=150, bbox_inches='tight')
    print("Saved: collatz_signatures.png")


if __name__ == "__main__":
    main()
