"""
Transfinite Cellular Automata Depth Theory — Demonstrations

Numerical experiments illustrating the Convergence Spectrum:
1. OR rule spreading behavior
2. NOT rule oscillation
3. Monotone dominance preservation
4. Classification of all 256 ECA rules
"""

from algorithms import (
    or_rule, not_rule, and_rule, id_rule,
    ca_step, ca_iter, is_fixed_point, detect_period,
    is_monotone_rule, eca_rule, classify_eca_rules,
    measure_spreading_speed, convergence_depth_estimate,
)


def demo_or_spreading():
    """Demonstrate the OR Expansion Lemma: true cells spread at speed 1."""
    print("=" * 60)
    print("DEMO 1: OR Rule Spreading (Expansion Lemma)")
    print("=" * 60)

    size = 41
    cfg = [False] * size
    cfg[size // 2] = True  # Single true cell at center

    print(f"\nInitial config (size {size}, true at center):")
    for step in range(21):
        evolved = ca_iter(or_rule, cfg, step)
        # Find extent of true region
        true_positions = [i for i, v in enumerate(evolved) if v]
        radius = max(true_positions) - size // 2 if true_positions else 0
        bar = ''.join('█' if v else '·' for v in evolved)
        print(f"  t={step:3d}: {bar}  (radius={radius})")

    print("\n→ The true region expands by exactly 1 cell per step (speed = 1).")
    print("→ This confirms the OR Expansion Lemma: |z - z₀| ≤ n → true at step n.")


def demo_not_oscillation():
    """Demonstrate the NOT rule's period-2 oscillation."""
    print("\n" + "=" * 60)
    print("DEMO 2: NOT Rule Oscillation (Period 2)")
    print("=" * 60)

    size = 20
    cfg = [i % 3 == 0 for i in range(size)]  # Some pattern

    print(f"\nInitial config: {''.join('█' if v else '·' for v in cfg)}")
    for step in range(6):
        evolved = ca_iter(not_rule, cfg, step)
        bar = ''.join('█' if v else '·' for v in evolved)
        even_odd = "even" if step % 2 == 0 else "odd"
        print(f"  t={step}: {bar}  ({even_odd})")

    print("\n→ Even steps reproduce the original; odd steps are its negation.")
    print("→ The NOT rule has period exactly 2 with NO fixed points.")

    # Verify no fixed points on small rings
    has_fp = False
    for bits in range(2**size):
        test_cfg = [(bits >> i) & 1 == 1 for i in range(size)]
        if is_fixed_point(not_rule, test_cfg):
            has_fp = True
            break
    print(f"→ Fixed points on ring of size {size}: {'Found' if has_fp else 'NONE'}")


def demo_monotone_dominance():
    """Demonstrate the Monotone Dominance Theorem for the OR rule."""
    print("\n" + "=" * 60)
    print("DEMO 3: Monotone Dominance Theorem")
    print("=" * 60)

    size = 20
    # cfg1 ≤ cfg2 (pointwise)
    cfg1 = [False, True, False, False, False, True, False, False, False, False,
            False, False, False, False, False, False, False, False, False, False]
    cfg2 = [True, True, False, True, False, True, False, True, False, False,
            False, True, False, False, True, False, False, False, False, True]

    # Verify cfg1 ≤ cfg2
    assert all(not c1 or c2 for c1, c2 in zip(cfg1, cfg2)), "cfg1 ≤ cfg2 violated!"

    print("\nOR rule with cfg₁ ≤ cfg₂:")
    for step in range(8):
        e1 = ca_iter(or_rule, cfg1, step)
        e2 = ca_iter(or_rule, cfg2, step)
        bar1 = ''.join('█' if v else '·' for v in e1)
        bar2 = ''.join('█' if v else '·' for v in e2)
        le_holds = all(not c1 or c2 for c1, c2 in zip(e1, e2))
        print(f"  t={step}: cfg₁={bar1}  cfg₂={bar2}  ≤: {'✓' if le_holds else '✗'}")

    print("\n→ The ordering cfg₁ ≤ cfg₂ is preserved at every step.")
    print("→ This is the Monotone Dominance Theorem in action.")


def demo_eca_classification():
    """Classify all 256 ECA rules."""
    print("\n" + "=" * 60)
    print("DEMO 4: ECA Rule Classification")
    print("=" * 60)

    result = classify_eca_rules()

    print(f"\nMonotone rules ({len(result['monotone'])}): {result['monotone']}")
    print(f"Rules with fixed points ({len(result['has_fixed_points'])}): first 20 = {result['has_fixed_points'][:20]}...")
    print(f"Depth-0 candidates ({len(result['depth0_candidate'])}): {result['depth0_candidate']}")
    print(f"Rules with NO fixed points ({len(result['no_fixed_points'])}): {result['no_fixed_points']}")

    # Spreading speed for monotone rules
    print("\nSpreading speeds for monotone rules:")
    for r in result['monotone']:
        rule = eca_rule(r)
        speed = measure_spreading_speed(rule, size=201, steps=50)
        print(f"  Rule {r:3d}: speed = {speed:.2f}")


def demo_depth_spectrum():
    """Demonstrate the Depth Spectrum Theorem computationally."""
    print("\n" + "=" * 60)
    print("DEMO 5: Depth Spectrum Theorem")
    print("=" * 60)

    size = 16
    test_cfg = [i % 5 == 0 for i in range(size)]

    rules = {
        "Identity (depth 0)": id_rule,
        "OR (depth 1)": or_rule,
        "NOT (depth ∞)": not_rule,
        "AND (monotone)": and_rule,
    }

    for name, rule in rules.items():
        is_fp = is_fixed_point(rule, test_cfg)
        behavior, param = detect_period(rule, test_cfg)
        is_mono = is_monotone_rule(rule)
        depth = convergence_depth_estimate(rule, test_cfg)
        print(f"\n  {name}:")
        print(f"    Monotone: {is_mono}")
        print(f"    Is fixed point: {is_fp}")
        print(f"    Behavior: {behavior} (param={param})")
        print(f"    Estimated depth: {depth}")

    print("\n→ The spectrum {0, 1, ∞} is non-degenerate: all three depths are realized.")


if __name__ == "__main__":
    demo_or_spreading()
    demo_not_oscillation()
    demo_monotone_dominance()
    demo_eca_classification()
    demo_depth_spectrum()


"""
Visualization: Space-Time Diagrams for the Convergence Spectrum

Generates space-time plots showing the evolution of cellular automata
under different rules (OR, NOT, AND, Rule 110) to illustrate the
convergence spectrum classification.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def eca_rule_func(rule_number: int):
    """Return ECA rule function for given rule number."""
    def rule(left: bool, center: bool, right: bool) -> bool:
        idx = (4 if left else 0) + (2 if center else 0) + (1 if right else 0)
        return bool((rule_number >> idx) & 1)
    return rule


def ca_step(rule, cfg):
    """Apply one step with periodic boundary."""
    n = len(cfg)
    return [rule(cfg[(i-1) % n], cfg[i], cfg[(i+1) % n]) for i in range(n)]


def ca_evolve(rule, cfg, steps):
    """Return full space-time diagram as 2D array."""
    result = [cfg[:]]
    current = cfg[:]
    for _ in range(steps):
        current = ca_step(rule, current)
        result.append(current[:])
    return result


def main():
    size = 81
    steps = 80

    # Initial config: single true cell at center
    cfg_single = [False] * size
    cfg_single[size // 2] = True

    # Random-ish initial config
    np.random.seed(42)
    cfg_random = [bool(x) for x in np.random.choice([0, 1], size=size)]

    rules = {
        'OR Rule (254) — Depth 1\nSingle seed': (eca_rule_func(254), cfg_single),
        'NOT Rule (51) — Depth ∞\nRandom init': (eca_rule_func(51), cfg_random),
        'AND Rule (128) — Monotone\nRandom init': (eca_rule_func(128), cfg_random),
        'Identity (204) — Depth 0\nRandom init': (eca_rule_func(204), cfg_random),
    }

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Convergence Spectrum: Space-Time Diagrams', fontsize=16, fontweight='bold')

    cmap = mcolors.ListedColormap(['#1a1a2e', '#e94560'])

    for ax, (title, (rule, cfg)) in zip(axes.flat, rules.items()):
        spacetime = ca_evolve(rule, cfg, steps)
        data = np.array(spacetime, dtype=int)

        ax.imshow(data, cmap=cmap, aspect='auto', interpolation='nearest')
        ax.set_title(title, fontsize=11)
        ax.set_xlabel('Cell position')
        ax.set_ylabel('Time step')

    plt.tight_layout()
    plt.savefig('spacetime_diagrams.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved spacetime_diagrams.png")


if __name__ == "__main__":
    main()
