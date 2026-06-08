#!/usr/bin/env python3
"""
Demonstration of the Dynamical Core and Reversibility Group for Cellular Automata.

This script illustrates the key mathematical concepts:
1. The six reversible elementary CAs (Rules 15, 51, 85, 170, 204, 240)
2. The dynamical core computation for arbitrary CAs
3. The image tower and core depth
4. Rule 150's reversibility spectrum
"""

import numpy as np
from typing import List, Tuple, Set, Dict, Callable
from itertools import product


# --- Configuration Space ---

def binary_configs(n: int) -> List[Tuple[int, ...]]:
    """All binary configurations on Z/nZ."""
    return list(product([0, 1], repeat=n))


def shift_config(config: Tuple[int, ...], k: int = 1) -> Tuple[int, ...]:
    """Left-shift a configuration by k positions."""
    n = len(config)
    return tuple(config[(i + k) % n] for i in range(n))


def complement_config(config: Tuple[int, ...]) -> Tuple[int, ...]:
    """Complement (flip) every cell."""
    return tuple(1 - c for c in config)


# --- Elementary CA Rules ---

def apply_elementary_rule(rule_number: int, config: Tuple[int, ...]) -> Tuple[int, ...]:
    """Apply an elementary CA rule (radius 1) to a configuration on Z/nZ."""
    n = len(config)
    rule_bits = [(rule_number >> i) & 1 for i in range(8)]
    result = []
    for i in range(n):
        neighborhood = (config[(i - 1) % n], config[i], config[(i + 1) % n])
        index = neighborhood[0] * 4 + neighborhood[1] * 2 + neighborhood[2]
        result.append(rule_bits[index])
    return tuple(result)


def is_reversible_rule(rule_number: int, n: int) -> bool:
    """Check if a rule is reversible (bijective) on Z/nZ configurations."""
    configs = binary_configs(n)
    images = [apply_elementary_rule(rule_number, c) for c in configs]
    return len(set(images)) == len(configs)


# --- Dynamical Core Computation ---

def compute_image_tower(f: Callable, configs: List[Tuple[int, ...]]) -> List[Set[Tuple[int, ...]]]:
    """Compute the image tower until stabilization."""
    tower = [set(configs)]
    current = set(configs)
    while True:
        next_image = {f(c) for c in current}
        if next_image == current:
            break
        tower.append(next_image)
        current = next_image
    return tower


def compute_core(f: Callable, configs: List[Tuple[int, ...]]) -> Set[Tuple[int, ...]]:
    """Compute the dynamical core (eventual image)."""
    tower = compute_image_tower(f, configs)
    return tower[-1]


def core_depth(f: Callable, configs: List[Tuple[int, ...]]) -> int:
    """Compute the core depth (stabilization step)."""
    return len(compute_image_tower(f, configs)) - 1


# --- Rule 150 (XOR-3 CA) ---

def rule150(config: Tuple[int, ...]) -> Tuple[int, ...]:
    """Rule 150: XOR of left neighbor, self, and right neighbor."""
    n = len(config)
    return tuple(
        config[(i - 1) % n] ^ config[i] ^ config[(i + 1) % n]
        for i in range(n)
    )


# --- Main Demonstrations ---

def demo_reversible_rules():
    """Demonstrate the six reversible elementary CAs."""
    print("=" * 60)
    print("DEMO 1: Identifying Reversible Elementary CAs")
    print("=" * 60)
    
    n = 5  # Test on Z/5Z
    reversible = []
    for rule in range(256):
        if is_reversible_rule(rule, n):
            reversible.append(rule)
    
    print(f"\nReversible rules on Z/{n}Z configurations:")
    print(f"  Rules: {reversible}")
    print(f"  Count: {len(reversible)} out of 256")
    
    print("\nRule descriptions:")
    descriptions = {
        204: "Identity: c(i) -> c(i)",
        170: "Left shift: c(i) -> c(i+1)",
        240: "Right shift: c(i) -> c(i-1)",
        51:  "Complement: c(i) -> NOT c(i)",
        85:  "Complement + left shift: c(i) -> NOT c(i+1)",
        15:  "Complement + right shift: c(i) -> NOT c(i-1)",
    }
    for rule in reversible:
        desc = descriptions.get(rule, "Unknown")
        print(f"  Rule {rule:3d}: {desc}")


def demo_dynamical_core():
    """Demonstrate the dynamical core computation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Dynamical Core of Cellular Automata")
    print("=" * 60)
    
    n = 4
    configs = binary_configs(n)
    
    # Rule 110: a classic irreversible rule
    f = lambda c: apply_elementary_rule(110, c)
    tower = compute_image_tower(f, configs)
    core = compute_core(f, configs)
    depth = core_depth(f, configs)
    
    print(f"\nRule 110 on Z/{n}Z (|configs| = {len(configs)}):")
    for k, level in enumerate(tower):
        print(f"  Im^{k}: {len(level)} configs")
    print(f"  Core depth: {depth}")
    print(f"  Core size: {len(core)}")
    print(f"  Information loss: {len(configs) - len(core)}")
    
    # Verify core bijectivity
    core_images = {f(c) for c in core}
    print(f"  Core bijectivity check: f(core) = core? {core_images == core}")
    
    # Reversible rule for comparison
    f_rev = lambda c: apply_elementary_rule(170, c)
    core_rev = compute_core(f_rev, configs)
    print(f"\nRule 170 (shift) on Z/{n}Z:")
    print(f"  Core size: {len(core_rev)} (= total configs: {len(core_rev) == len(configs)})")
    print(f"  Core depth: {core_depth(f_rev, configs)}")


def demo_commutativity():
    """Demonstrate commutativity of the reversible ECA group."""
    print("\n" + "=" * 60)
    print("DEMO 3: Commutativity of Reversible ECAs")
    print("=" * 60)
    
    n = 5
    configs = binary_configs(n)
    
    # Check: shift ∘ complement = complement ∘ shift
    for c in configs:
        sc = shift_config(complement_config(c))
        cs = complement_config(shift_config(c))
        assert sc == cs, f"Commutativity failed for {c}"
    
    print(f"\nVerified: shift ∘ complement = complement ∘ shift on Z/{n}Z")
    print(f"  Tested all {len(configs)} configurations")
    
    # Show group table
    ops = {
        "id": lambda c: c,
        "σ": lambda c: shift_config(c),
        "σ⁻¹": lambda c: shift_config(c, -1),
        "ν": complement_config,
        "νσ": lambda c: complement_config(shift_config(c)),
        "νσ⁻¹": lambda c: complement_config(shift_config(c, -1)),
    }
    
    print(f"\n  Composition table (applied to config (0,0,1,0,1)):")
    test_config = (0, 0, 1, 0, 1)
    for name, op in ops.items():
        result = op(test_config)
        print(f"    {name:6s}({test_config}) = {result}")


def demo_rule150_spectrum():
    """Demonstrate the Rule 150 reversibility spectrum."""
    print("\n" + "=" * 60)
    print("DEMO 4: Rule 150 Reversibility Spectrum")
    print("=" * 60)
    
    print("\n  n  | Reversible? | 3 divides n?")
    print("  ---+-------------+-------------")
    
    for n in range(1, 21):
        configs = binary_configs(n)
        f = lambda c, n=n: rule150(c)
        images = {f(c) for c in configs}
        is_rev = len(images) == len(configs)
        div3 = (n % 3 == 0)
        
        match_emoji = "✓" if is_rev != div3 else "✗"
        print(f"  {n:2d} | {'Yes':11s} | {'Yes' if div3 else 'No':12s} | {match_emoji}" 
              if is_rev else
              f"  {n:2d} | {'No':11s} | {'Yes' if div3 else 'No':12s} | {match_emoji}")
    
    print("\n  Conjecture: Rule 150 is reversible iff 3 does not divide n")
    print("  All entries should show ✓ if the conjecture is correct")


def demo_core_depth_statistics():
    """Compute core depth statistics for various rules."""
    print("\n" + "=" * 60)
    print("DEMO 5: Core Depth Statistics Across Rules")
    print("=" * 60)
    
    n = 5
    configs = binary_configs(n)
    
    depth_counts: Dict[int, int] = {}
    for rule in range(256):
        f = lambda c, r=rule: apply_elementary_rule(r, c)
        d = core_depth(f, configs)
        depth_counts[d] = depth_counts.get(d, 0) + 1
    
    print(f"\nCore depth distribution for 256 elementary CAs on Z/{n}Z:")
    for d in sorted(depth_counts.keys()):
        bar = "█" * depth_counts[d]
        print(f"  Depth {d}: {depth_counts[d]:3d} rules  {bar}")
    
    print(f"\n  Depth 0 = reversible rules: {depth_counts.get(0, 0)}")
    print(f"  Max depth: {max(depth_counts.keys())}")


if __name__ == "__main__":
    demo_reversible_rules()
    demo_dynamical_core()
    demo_commutativity()
    demo_rule150_spectrum()
    demo_core_depth_statistics()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Image Tower Decay for Elementary CAs.

Shows how the image tower (iterated images) shrinks for different CA rules,
illustrating the dynamical core concept.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product
from typing import Tuple, List, Set, Callable

Config = Tuple[int, ...]


def apply_elementary_rule(rule_number: int, config: Config) -> Config:
    n = len(config)
    rule_bits = [(rule_number >> i) & 1 for i in range(8)]
    return tuple(
        rule_bits[config[(i-1) % n] * 4 + config[i] * 2 + config[(i+1) % n]]
        for i in range(n)
    )


def image_tower_sizes(rule_number: int, n: int) -> List[int]:
    configs = list(product([0, 1], repeat=n))
    f: Callable[[Config], Config] = lambda c: apply_elementary_rule(rule_number, c)
    
    current: Set[Config] = set(configs)
    sizes: List[int] = [len(current)]
    
    for _ in range(20):
        next_img = {f(c) for c in current}
        if next_img == current:
            break
        current = next_img
        sizes.append(len(current))
    
    return sizes


def main():
    n = 6
    total_configs = 2 ** n
    
    rules_to_plot = [
        (170, "Rule 170 (shift, reversible)", "tab:blue"),
        (110, "Rule 110 (universal, irreversible)", "tab:orange"),
        (30, "Rule 30 (chaotic, irreversible)", "tab:green"),
        (90, "Rule 90 (XOR, irreversible)", "tab:red"),
        (150, "Rule 150 (XOR-3)", "tab:purple"),
        (0, "Rule 0 (all → 0)", "tab:brown"),
    ]
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    for rule, label, color in rules_to_plot:
        sizes = image_tower_sizes(rule, n)
        steps = list(range(len(sizes)))
        ax.plot(steps, [s / total_configs for s in sizes], 
                'o-', label=label, color=color, linewidth=2, markersize=6)
    
    ax.set_xlabel("Iteration k (Image Tower Level)", fontsize=12)
    ax.set_ylabel(f"|Im^k(f)| / |Config Space| (n={n})", fontsize=12)
    ax.set_title("Image Tower Decay: The Dynamical Core", fontsize=14)
    ax.legend(loc='upper right', fontsize=9)
    ax.set_ylim(-0.05, 1.1)
    ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.3)
    ax.grid(True, alpha=0.3)
    
    # Annotate
    ax.annotate("Reversible CAs stay at 1.0\n(core = full space)",
                xy=(0, 1.0), xytext=(2, 0.85),
                arrowprops=dict(arrowstyle="->", color="gray"),
                fontsize=9, color="gray")
    
    plt.tight_layout()
    plt.savefig("viz_image_tower.png", dpi=150, bbox_inches='tight')
    print("Saved viz_image_tower.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Rule 150 Reversibility Spectrum.

Shows for which lattice sizes n the XOR-3 CA (Rule 150) is reversible,
confirming the conjecture that reversibility holds iff 3 does not divide n.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List, Optional


def rule150_circulant_det_gf2(n: int) -> int:
    """Compute det of Rule 150's circulant matrix over GF(2)."""
    matrix: List[List[int]] = []
    for i in range(n):
        row = [0] * n
        row[i] = 1
        row[(i - 1) % n] ^= 1
        row[(i + 1) % n] ^= 1
        matrix.append(row)
    
    for col in range(n):
        pivot_row: Optional[int] = None
        for row in range(col, n):
            if matrix[row][col] == 1:
                pivot_row = row
                break
        if pivot_row is None:
            return 0
        if pivot_row != col:
            matrix[col], matrix[pivot_row] = matrix[pivot_row], matrix[col]
        for row in range(n):
            if row != col and matrix[row][col] == 1:
                matrix[row] = [matrix[row][j] ^ matrix[col][j] for j in range(n)]
    
    return 1


def main():
    max_n = 60
    ns = list(range(1, max_n + 1))
    reversible = [rule150_circulant_det_gf2(n) == 1 for n in ns]
    
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), 
                                     gridspec_kw={'height_ratios': [3, 1]})
    
    # Top: scatter plot of reversibility
    colors = ['#2ecc71' if r else '#e74c3c' for r in reversible]
    ax1.scatter(ns, [1 if r else 0 for r in reversible], 
                c=colors, s=80, zorder=5)
    
    # Highlight multiples of 3
    for n in ns:
        if n % 3 == 0:
            ax1.axvline(x=n, color='#e74c3c', alpha=0.15, linewidth=8)
    
    ax1.set_yticks([0, 1])
    ax1.set_yticklabels(['Irreversible', 'Reversible'])
    ax1.set_xlabel('Lattice size n', fontsize=12)
    ax1.set_title('Rule 150 Reversibility Spectrum: Reversible iff 3 ∤ n', fontsize=14)
    ax1.grid(True, alpha=0.3, axis='x')
    
    # Bottom: nullity (dimension of kernel)
    nullities = []
    for n in ns:
        matrix = []
        for i in range(n):
            row = [0] * n
            row[i] = 1
            row[(i - 1) % n] ^= 1
            row[(i + 1) % n] ^= 1
            matrix.append(row)
        
        # Compute rank via Gaussian elimination
        rank = 0
        mat = [row[:] for row in matrix]
        for col in range(n):
            pivot = None
            for row in range(rank, n):
                if mat[row][col] == 1:
                    pivot = row
                    break
            if pivot is None:
                continue
            mat[rank], mat[pivot] = mat[pivot], mat[rank]
            for row in range(n):
                if row != rank and mat[row][col] == 1:
                    mat[row] = [mat[row][j] ^ mat[rank][j] for j in range(n)]
            rank += 1
        
        nullities.append(n - rank)
    
    ax2.bar(ns, nullities, color=['#e74c3c' if nu > 0 else '#2ecc71' for nu in nullities],
            alpha=0.8)
    ax2.set_xlabel('Lattice size n', fontsize=12)
    ax2.set_ylabel('Nullity (dim kernel)', fontsize=12)
    ax2.set_title('Kernel dimension of Rule 150 over GF(2)', fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig("viz_rule150_spectrum.png", dpi=150, bbox_inches='tight')
    print("Saved viz_rule150_spectrum.png")


if __name__ == "__main__":
    main()
