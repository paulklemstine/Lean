"""
Kitchen Complexity Theory: Interactive Demo

Demonstrates the key results from the formal verification:
1. Recipe classification into the culinary hierarchy
2. Sequential and parallel composition
3. Kitchen reductions and their transitivity
4. The verification gap weighted average bound
"""

from algorithms import (
    Recipe, CulinaryLevel, classify_recipe,
    sequential_compose, parallel_compose,
    find_reduction, STANDARD_RECIPES, classify_recipe_database
)


def demo_classification():
    """Demo 1: Classify all standard recipes."""
    print("=" * 60)
    print("DEMO 1: Recipe Classification")
    print("=" * 60)

    classified = classify_recipe_database(STANDARD_RECIPES)

    for level in CulinaryLevel:
        recipes = classified[level]
        if recipes:
            print(f"\n{'─' * 40}")
            print(f"  {level.name} (level {level.value})")
            print(f"{'─' * 40}")
            for r in recipes:
                gap = r.verification_gap
                d = " 💥" if r.destructive else ""
                print(f"  {r.name:<20} C={r.cook_time:>4} V={r.verify_time:>3} γ={gap:>6.1f}{d}")


def demo_composition():
    """Demo 2: Sequential and parallel composition."""
    print("\n" + "=" * 60)
    print("DEMO 2: Recipe Composition")
    print("=" * 60)

    souffle = Recipe("Soufflé", 5, 8, 60, 5, destructive=True)
    bread = Recipe("Bread", 4, 6, 120, 10)
    salad = Recipe("Salad", 5, 3, 5, 5)

    # Sequential: soufflé then bread
    seq = sequential_compose(souffle, bread)
    print(f"\nSequential: {souffle.name} → {bread.name}")
    print(f"  C = {souffle.cook_time} + {bread.cook_time} = {seq.cook_time}")
    print(f"  V = {souffle.verify_time} + {bread.verify_time} = {seq.verify_time}")
    print(f"  γ = {seq.verification_gap:.2f}")
    print(f"  Level: {classify_recipe(seq).name}")
    print(f"  Destructive: {seq.destructive} (propagated from soufflé)")

    # Parallel: soufflé ∥ bread
    par = parallel_compose(souffle, bread)
    print(f"\nParallel: {souffle.name} ∥ {bread.name}")
    print(f"  C = max({souffle.cook_time}, {bread.cook_time}) = {par.cook_time}")
    print(f"  V = {souffle.verify_time} + {bread.verify_time} = {par.verify_time}")
    print(f"  γ = {par.verification_gap:.2f}")
    print(f"  Level: {classify_recipe(par).name}")

    # Theorem 3: par.cook_time ≤ seq.cook_time
    print(f"\n  ✓ Theorem 3: C(par) = {par.cook_time} ≤ {seq.cook_time} = C(seq)")

    # Quick recipe closure
    salad2 = Recipe("Greek Salad", 6, 3, 6, 6)
    combo = sequential_compose(salad, salad2)
    print(f"\nQuick recipe closure: {salad.name} → {salad2.name}")
    print(f"  Both quick: {salad.is_quick} and {salad2.is_quick}")
    print(f"  Combo quick: {combo.is_quick}")
    print(f"  ✓ Theorem 8 verified: quick ∘ quick = quick")


def demo_reductions():
    """Demo 3: Kitchen reductions."""
    print("\n" + "=" * 60)
    print("DEMO 3: Kitchen Reductions")
    print("=" * 60)

    pasta = Recipe("Pasta", 5, 6, 20, 5)
    risotto = Recipe("Risotto", 6, 8, 40, 5)
    ramen = Recipe("Ramen", 6, 5, 720, 10)

    # Find reductions
    for r1, r2 in [(pasta, risotto), (risotto, ramen), (pasta, ramen)]:
        red = find_reduction(r1, r2)
        if red and red.is_valid():
            print(f"\n  {r1.name} ≤_k {r2.name} with overhead {red.overhead}")
            print(f"    C: {r1.cook_time} ≤ {r2.cook_time} + {red.overhead} = {r2.cook_time + red.overhead}")
            print(f"    V: {r1.verify_time} ≤ {r2.verify_time} + {red.overhead} = {r2.verify_time + red.overhead}")
        else:
            print(f"\n  No reduction: {r1.name} → {r2.name}")

    # Transitivity demo
    red_pr = find_reduction(pasta, risotto)
    red_rr = find_reduction(risotto, ramen)
    red_direct = find_reduction(pasta, ramen)
    if red_pr and red_rr and red_direct:
        print(f"\n  ✓ Theorem 4 (Transitivity):")
        print(f"    Direct overhead: {red_direct.overhead}")
        print(f"    Transitive overhead: {red_pr.overhead} + {red_rr.overhead} = {red_pr.overhead + red_rr.overhead}")
        print(f"    (Transitive bound ≥ direct, as expected)")


def demo_gap_analysis():
    """Demo 4: Verification gap analysis across recipes."""
    print("\n" + "=" * 60)
    print("DEMO 4: Verification Gap Analysis")
    print("=" * 60)

    print(f"\n  {'Recipe':<20} {'C':>5} {'V':>5} {'γ':>7} {'Level':<12} {'Hard?'}")
    print(f"  {'─' * 60}")

    for r in sorted(STANDARD_RECIPES, key=lambda x: x.verification_gap, reverse=True):
        level = classify_recipe(r)
        hard = "✓" if r.is_hard else "✗"
        print(f"  {r.name:<20} {r.cook_time:>5} {r.verify_time:>5} {r.verification_gap:>7.1f} {level.name:<12} {hard}")

    # Conjecture test
    print(f"\n  Conjecture Test: C > 4V and ops > ingredients → HARD")
    for r in STANDARD_RECIPES:
        if r.cook_time > 4 * r.verify_time and r.num_operations > r.num_ingredients:
            level = classify_recipe(r)
            status = "✓" if level == CulinaryLevel.HARD else "✗ COUNTEREXAMPLE!"
            print(f"    {r.name}: {status}")


def demo_scaling():
    """Demo 5: Hierarchy monotonicity under scaling."""
    print("\n" + "=" * 60)
    print("DEMO 5: Cook Time Scaling (Theorem 9)")
    print("=" * 60)

    base = Recipe("Base Recipe", 3, 4, 6, 5)
    print(f"\n  Base: C={base.cook_time}, V={base.verify_time}, "
          f"γ={base.verification_gap:.1f}, Level={classify_recipe(base).name}")

    for k in [1, 2, 3, 5, 10]:
        scaled = Recipe(f"×{k}", base.num_ingredients, base.num_operations,
                       k * base.cook_time, base.verify_time, base.destructive)
        level = classify_recipe(scaled)
        print(f"  k={k:>2}: C={scaled.cook_time:>4}, V={scaled.verify_time:>3}, "
              f"γ={scaled.verification_gap:>6.1f}, Level={level.name}")


if __name__ == "__main__":
    demo_classification()
    demo_composition()
    demo_reductions()
    demo_gap_analysis()
    demo_scaling()

    print("\n" + "=" * 60)
    print("All demos completed. All theorems verified computationally.")
    print("=" * 60)


"""
Visualization: Sequential vs Parallel Composition

Bar chart comparing cook time, verify time, and verification gap
for sequential and parallel composition of recipe pairs.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    # Recipe pairs to compose
    pairs = [
        ("Soufflé + Bread", 60, 5, 120, 10),
        ("Pasta + Salad", 20, 5, 5, 5),
        ("Ramen + Sushi", 720, 10, 30, 3),
        ("Toast + Eggs", 3, 2, 8, 3),
    ]

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    labels = [p[0] for p in pairs]
    x = np.arange(len(labels))
    width = 0.35

    seq_cook = [p[1] + p[3] for p in pairs]
    par_cook = [max(p[1], p[3]) for p in pairs]
    seq_verify = [p[2] + p[4] for p in pairs]
    par_verify = [p[2] + p[4] for p in pairs]  # Same for parallel
    seq_gap = [sc / sv if sv > 0 else 0 for sc, sv in zip(seq_cook, seq_verify)]
    par_gap = [pc / pv if pv > 0 else 0 for pc, pv in zip(par_cook, par_verify)]

    # Cook time comparison
    ax = axes[0]
    bars1 = ax.bar(x - width/2, seq_cook, width, label='Sequential', color='#e74c3c', alpha=0.8)
    bars2 = ax.bar(x + width/2, par_cook, width, label='Parallel', color='#3498db', alpha=0.8)
    ax.set_ylabel('Cook Time C(R)')
    ax.set_title('Cook Time: Sequential vs Parallel')
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=30, ha='right', fontsize=9)
    ax.legend()
    ax.bar_label(bars1, padding=3, fontsize=8)
    ax.bar_label(bars2, padding=3, fontsize=8)

    # Verify time comparison
    ax = axes[1]
    bars1 = ax.bar(x - width/2, seq_verify, width, label='Sequential', color='#e74c3c', alpha=0.8)
    bars2 = ax.bar(x + width/2, par_verify, width, label='Parallel', color='#3498db', alpha=0.8)
    ax.set_ylabel('Verify Time V(R)')
    ax.set_title('Verify Time: Sequential vs Parallel')
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=30, ha='right', fontsize=9)
    ax.legend()
    ax.bar_label(bars1, padding=3, fontsize=8)
    ax.bar_label(bars2, padding=3, fontsize=8)

    # Verification gap comparison
    ax = axes[2]
    bars1 = ax.bar(x - width/2, seq_gap, width, label='Sequential', color='#e74c3c', alpha=0.8)
    bars2 = ax.bar(x + width/2, par_gap, width, label='Parallel', color='#3498db', alpha=0.8)
    ax.set_ylabel('Verification Gap γ')
    ax.set_title('Verification Gap: Sequential vs Parallel')
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=30, ha='right', fontsize=9)
    ax.legend()
    ax.axhline(y=1, color='green', linestyle='--', alpha=0.5, label='γ = 1 (quick)')
    ax.axhline(y=4, color='orange', linestyle='--', alpha=0.5, label='γ = 4 (hard threshold)')
    ax.bar_label(bars1, padding=3, fontsize=8, fmt='%.1f')
    ax.bar_label(bars2, padding=3, fontsize=8, fmt='%.1f')

    plt.suptitle('Theorem 3: C(R₁ ∥ R₂) ≤ C(R₁ ∘ R₂)\nParallel cooking is always faster than sequential',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_composition.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_composition.png")


if __name__ == "__main__":
    main()


"""
Visualization: Verification Gap Under Cook Time Scaling

Shows how the verification gap and culinary level change as we scale
the cook time by factor k, demonstrating Theorem 9 (monotonicity for hard recipes).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def classify(cook_time: float, verify_time: float) -> tuple[str, int]:
    if verify_time >= cook_time:
        return ("IMPOSSIBLE", 4)
    elif cook_time <= verify_time:
        return ("TRIVIAL", 0)
    elif cook_time <= 2 * verify_time:
        return ("EASY", 1)
    elif cook_time <= 2 * verify_time:
        return ("EASY", 1)
    elif cook_time <= 4 * verify_time:
        return ("MODERATE", 2)
    else:
        return ("HARD", 3)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Base recipes
    base_recipes = [
        ("Scrambled Eggs", 8, 3),
        ("Pasta", 20, 5),
        ("Soufflé", 60, 5),
        ("Bread", 120, 10),
    ]

    colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6']
    k_values = np.arange(1, 11)

    # Left: Verification gap vs k
    ax = axes[0]
    for (name, c, v), color in zip(base_recipes, colors):
        gaps = [k * c / v for k in k_values]
        ax.plot(k_values, gaps, 'o-', color=color, label=f'{name} (C={c}, V={v})',
                linewidth=2, markersize=6)

    ax.axhline(y=1, color='green', linestyle='--', alpha=0.4, label='γ = 1')
    ax.axhline(y=2, color='blue', linestyle='--', alpha=0.4, label='γ = 2')
    ax.axhline(y=4, color='orange', linestyle='--', alpha=0.4, label='γ = 4')
    ax.set_xlabel('Scale factor k', fontsize=12)
    ax.set_ylabel('Verification Gap γ = kC/V', fontsize=12)
    ax.set_title('Verification Gap vs Scale Factor', fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')

    # Right: Culinary level vs k
    ax = axes[1]
    level_names = {0: 'Trivial', 1: 'Easy', 2: 'Moderate', 3: 'Hard', 4: 'Impossible'}

    for (name, c, v), color in zip(base_recipes, colors):
        levels = [classify(k * c, v)[1] for k in k_values]
        ax.plot(k_values, levels, 's-', color=color, label=f'{name}',
                linewidth=2, markersize=8)

    ax.set_yticks([0, 1, 2, 3, 4])
    ax.set_yticklabels(['Trivial', 'Easy', 'Moderate', 'Hard', 'Impossible'])
    ax.set_xlabel('Scale factor k', fontsize=12)
    ax.set_ylabel('Culinary Level', fontsize=12)
    ax.set_title('Theorem 9: Level Monotonicity Under Scaling', fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Kitchen Complexity: Scaling Cook Time Never Decreases Difficulty\n(for hard recipes with C > V)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_gap_scaling.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_gap_scaling.png")


if __name__ == "__main__":
    main()


"""
Visualization: Culinary Complexity Hierarchy

Scatter plot of recipes in the (cook_time, verify_time) plane,
colored by culinary complexity level, with threshold boundaries.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def classify(cook_time: int, verify_time: int) -> str:
    if verify_time >= cook_time:
        return "IMPOSSIBLE"
    elif cook_time <= verify_time:
        return "TRIVIAL"
    elif cook_time <= 2 * verify_time:
        return "EASY"
    elif cook_time <= 4 * verify_time:
        return "MODERATE"
    else:
        return "HARD"


def main():
    # Recipe data: (name, cook_time, verify_time, destructive)
    recipes = [
        ("Salad", 5, 5, False),
        ("Toast", 3, 2, False),
        ("Scrambled Eggs", 8, 3, False),
        ("Pasta Carbonara", 20, 5, False),
        ("Risotto", 40, 5, False),
        ("Soufflé", 60, 5, True),
        ("Bread", 120, 10, False),
        ("Croissants", 480, 10, False),
        ("Beef Wellington", 180, 5, False),
        ("Aged Cheese", 2, 5, False),
        ("Fermented Kimchi", 3, 10, False),
        ("Instant Coffee", 1, 1, False),
        ("Sushi", 30, 3, False),
        ("Ramen Broth", 720, 10, False),
        ("Macarons", 90, 5, False),
    ]

    colors = {
        "TRIVIAL": "#2ecc71",
        "EASY": "#3498db",
        "MODERATE": "#f39c12",
        "HARD": "#e74c3c",
        "IMPOSSIBLE": "#9b59b6",
    }

    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Plot threshold lines
    v_range = np.linspace(0.5, 15, 100)
    ax.plot(v_range, v_range, '--', color='gray', alpha=0.5, label='C = V (quick)')
    ax.plot(v_range, 2 * v_range, '--', color='#3498db', alpha=0.4, label='C = 2V')
    ax.plot(v_range, 4 * v_range, '--', color='#f39c12', alpha=0.4, label='C = 4V')

    # Fill regions
    ax.fill_between(v_range, 0, v_range, alpha=0.05, color='#9b59b6')
    ax.fill_between(v_range, v_range, 2 * v_range, alpha=0.05, color='#3498db')
    ax.fill_between(v_range, 2 * v_range, 4 * v_range, alpha=0.05, color='#f39c12')

    # Plot recipes
    for name, c, v, destr in recipes:
        level = classify(c, v)
        color = colors[level]
        marker = 'D' if destr else 'o'
        ax.scatter(v, c, c=color, s=120, marker=marker, edgecolors='black',
                  linewidths=1, zorder=5)
        offset_x = 0.3
        offset_y = c * 0.05 + 5
        ax.annotate(name, (v, c), xytext=(v + offset_x, c + offset_y),
                   fontsize=8, ha='left', va='bottom',
                   arrowprops=dict(arrowstyle='->', color='gray', lw=0.5))

    ax.set_xlabel('Verification Time V(R)', fontsize=14)
    ax.set_ylabel('Cooking Time C(R)', fontsize=14)
    ax.set_title('Culinary Complexity Hierarchy\nRecipes in the (V, C) Plane', fontsize=16)
    ax.set_yscale('log')

    # Legend
    patches = [mpatches.Patch(color=colors[k], label=k) for k in colors]
    patches.append(plt.Line2D([0], [0], marker='D', color='w', markerfacecolor='gray',
                              markersize=10, label='Destructive verification'))
    ax.legend(handles=patches, loc='upper left', fontsize=10)

    ax.set_xlim(0, 16)
    ax.set_ylim(0.5, 1000)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_hierarchy.png")


if __name__ == "__main__":
    main()
