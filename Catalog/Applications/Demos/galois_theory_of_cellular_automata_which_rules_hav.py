#!/usr/bin/env python3
"""
Demo: Galois Theory of Cellular Automata — Reversible Dynamics

Demonstrates the key results from the research:
1. Classification of the 6 reversible elementary CAs
2. Group structure (Z/nZ × Z/2Z)
3. Garden of Eden analysis
4. Rule 150 reversibility spectrum conjecture test
"""

from algorithms import (
    wolfram_rule_function,
    global_rule,
    find_reversible_ecas,
    is_reversible_on_period,
    reversibility_spectrum,
    garden_of_eden_count,
    reversible_eca_group_structure,
    rule150_reversibility_test,
    compute_goe_spectrum,
)


def demo_reversible_classification():
    """Demo 1: Classify reversible elementary CAs."""
    print("=" * 70)
    print("DEMO 1: Classification of Reversible Elementary CAs")
    print("=" * 70)

    # Find reversible ECAs by testing on multiple periods
    for period in [3, 4, 5, 6, 7]:
        rev = find_reversible_ecas(period)
        print(f"  Period {period}: {len(rev)} reversible rules: {rev}")

    print("\n  The 6 always-reversible ECAs and their operations:")
    descriptions = {
        204: "Identity:              c(i) ↦ c(i)",
        170: "Left shift:            c(i) ↦ c(i+1)",
        240: "Right shift:           c(i) ↦ c(i−1)",
        51:  "Complement:            c(i) ↦ ¬c(i)",
        85:  "Complement+left shift: c(i) ↦ ¬c(i+1)",
        15:  "Complement+right shift:c(i) ↦ ¬c(i−1)",
    }
    for rule, desc in descriptions.items():
        print(f"    Rule {rule:3d}: {desc}")

    # Verify on a concrete configuration
    config = [1, 0, 1, 1, 0, 0, 1, 0]
    print(f"\n  Example config: {config}")
    for rule in [204, 170, 240, 51, 85, 15]:
        result = global_rule(rule, config)
        print(f"    Rule {rule:3d}: {result}")


def demo_group_structure():
    """Demo 2: Group structure of reversible ECAs."""
    print("\n" + "=" * 70)
    print("DEMO 2: Group Structure of Reversible ECAs")
    print("=" * 70)

    for period in [3, 4, 5, 6, 7, 8]:
        info = reversible_eca_group_structure(period)
        print(f"  Period {period}:")
        print(f"    Shift order: {info['shift_order']}")
        print(f"    Complement order: {info['complement_order']}")
        print(f"    σ·ν = ν·σ (commute): {info['shift_compl_commute']}")
        print(f"    Group: {info['group_structure']} (order {info['group_order']})")
        print(f"    Direct product: {info['is_direct_product']}")


def demo_garden_of_eden():
    """Demo 3: Garden of Eden analysis."""
    print("\n" + "=" * 70)
    print("DEMO 3: Garden of Eden (Irreversibility) Analysis")
    print("=" * 70)

    rules_to_test = [30, 90, 110, 150, 170, 204]
    print("\n  GoE count (configs with no preimage) for selected rules:\n")
    print(f"  {'Rule':>6} | " + " | ".join(f"n={n}" for n in range(1, 9)))
    print("  " + "-" * 60)
    for rule in rules_to_test:
        goe_vals = [garden_of_eden_count(rule, n) for n in range(1, 9)]
        print(f"  {rule:>6} | " + " | ".join(f"{g:>4}" for g in goe_vals))

    print("\n  GoE ratio (GoE / total configs):\n")
    print(f"  {'Rule':>6} | " + " | ".join(f"n={n:>5}" for n in range(1, 9)))
    print("  " + "-" * 70)
    for rule in rules_to_test:
        ratios = compute_goe_spectrum(rule, 8)
        print(f"  {rule:>6} | " + " | ".join(f"{ratios[n]:>6.3f}" for n in range(1, 9)))


def demo_rule150_conjecture():
    """Demo 4: Test the Rule 150 reversibility spectrum conjecture."""
    print("\n" + "=" * 70)
    print("DEMO 4: Rule 150 Reversibility Spectrum Conjecture")
    print("=" * 70)
    print("  Conjecture: Rule 150 (XOR-3) is reversible on period n iff 3 ∤ n")
    print()

    results = rule150_reversibility_test(18)
    all_match = True
    for n, info in results.items():
        status = "✓" if info["conjecture_holds"] else "✗"
        rev_str = "reversible" if info["is_reversible"] else "irreversible"
        exp_str = "reversible" if info["expected"] else "irreversible"
        if not info["conjecture_holds"]:
            all_match = False
        div3 = "3|n" if n % 3 == 0 else "3∤n"
        print(f"    n={n:2d} ({div3}): {rev_str:12s} (expected: {exp_str:12s}) [{status}]")

    print(f"\n  Conjecture status: {'CONFIRMED' if all_match else 'REFUTED'} "
          f"for n = 1..{max(results.keys())}")


def demo_reversibility_spectrum():
    """Demo 5: Reversibility spectra of various rules."""
    print("\n" + "=" * 70)
    print("DEMO 5: Reversibility Spectra of Selected Rules")
    print("=" * 70)

    rules = [30, 45, 90, 105, 150, 170, 204]
    for rule in rules:
        spec = reversibility_spectrum(rule, 12)
        rev_periods = [n for n, is_rev in spec.items() if is_rev]
        irr_periods = [n for n, is_rev in spec.items() if not is_rev]
        print(f"  Rule {rule:3d}: reversible on n ∈ {rev_periods}")
        if irr_periods:
            print(f"           irreversible on n ∈ {irr_periods}")


if __name__ == "__main__":
    demo_reversible_classification()
    demo_group_structure()
    demo_garden_of_eden()
    demo_rule150_conjecture()
    demo_reversibility_spectrum()


#!/usr/bin/env python3
"""
Visualization: Reversibility Spectrum Heatmap

Displays which elementary CA rules are reversible at which lattice sizes,
revealing the number-theoretic structure underlying reversible dynamics.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product as iproduct


def wolfram_rule_function(rule_number, neighborhood):
    index = neighborhood[0] * 4 + neighborhood[1] * 2 + neighborhood[2]
    return (rule_number >> index) & 1


def global_rule(rule_number, config):
    n = len(config)
    return [wolfram_rule_function(rule_number, (config[(i-1) % n], config[i], config[(i+1) % n]))
            for i in range(n)]


def is_reversible_on_period(rule_number, period):
    configs = list(iproduct([0, 1], repeat=period))
    images = set()
    for c in configs:
        img = tuple(global_rule(rule_number, list(c)))
        if img in images:
            return False
        images.add(img)
    return True


def garden_of_eden_ratio(rule_number, period):
    configs = list(iproduct([0, 1], repeat=period))
    images = set()
    for c in configs:
        images.add(tuple(global_rule(rule_number, list(c))))
    return 1 - len(images) / len(configs)


# Compute reversibility spectrum for interesting rules
interesting_rules = [15, 30, 45, 51, 85, 90, 105, 110, 150, 170, 204, 240]
max_period = 12

fig, axes = plt.subplots(2, 1, figsize=(14, 10))

# Plot 1: Reversibility spectrum heatmap
data = np.zeros((len(interesting_rules), max_period))
for i, rule in enumerate(interesting_rules):
    for n in range(1, max_period + 1):
        data[i, n-1] = 1 if is_reversible_on_period(rule, n) else 0

ax = axes[0]
im = ax.imshow(data, cmap='RdYlGn', aspect='auto', interpolation='nearest')
ax.set_yticks(range(len(interesting_rules)))
ax.set_yticklabels([f'Rule {r}' for r in interesting_rules])
ax.set_xticks(range(max_period))
ax.set_xticklabels(range(1, max_period + 1))
ax.set_xlabel('Lattice Period n')
ax.set_title('Reversibility Spectrum of Elementary Cellular Automata\n'
             '(Green = Reversible, Red = Irreversible)')
plt.colorbar(im, ax=ax, label='Reversible (1) / Irreversible (0)')

# Plot 2: Garden of Eden ratio
goe_rules = [30, 90, 110, 150]
ax2 = axes[1]
for rule in goe_rules:
    goe_data = [garden_of_eden_ratio(rule, n) for n in range(1, max_period + 1)]
    ax2.plot(range(1, max_period + 1), goe_data, 'o-', label=f'Rule {rule}', linewidth=2)

ax2.set_xlabel('Lattice Period n')
ax2.set_ylabel('Garden of Eden Ratio')
ax2.set_title('Irreversibility Index: Garden of Eden Ratio by Period')
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_xticks(range(1, max_period + 1))

plt.tight_layout()
plt.savefig('reversibility_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved: reversibility_spectrum.png")
