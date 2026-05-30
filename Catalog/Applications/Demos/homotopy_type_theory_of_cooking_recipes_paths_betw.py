"""
Applications of Culinary Homotopy Theory
=========================================

Real-world applications of the recipe-as-Hamming-graph framework:

1. Recipe Optimization: Find the recipe closest to a target flavor.
2. Ingredient Substitution Planner: Find paths in the substitution graph.
3. Cuisine Classification: Cluster recipes by flavor profile.
4. Recipe Diversity Metric: Measure how diverse a recipe collection is.
"""

import numpy as np
from itertools import product
from collections import defaultdict


# ============================================================
# FLAVOR DIMENSIONS (simplified 5-dimensional taste space)
# ============================================================
FLAVOR_DIMS = ["sweet", "salty", "sour", "bitter", "umami"]

# Example ingredient flavor profiles (each ingredient maps to R^5)
INGREDIENT_DB = {
    # Sweeteners
    "sugar": np.array([1.0, 0.0, 0.0, 0.0, 0.0]),
    "honey": np.array([0.9, 0.0, 0.1, 0.0, 0.0]),
    "maple_syrup": np.array([0.85, 0.05, 0.0, 0.0, 0.1]),
    # Fats
    "butter": np.array([0.1, 0.2, 0.0, 0.0, 0.3]),
    "coconut_oil": np.array([0.1, 0.0, 0.0, 0.0, 0.1]),
    "olive_oil": np.array([0.0, 0.0, 0.0, 0.2, 0.1]),
    # Proteins
    "egg": np.array([0.0, 0.1, 0.0, 0.0, 0.4]),
    "flax_egg": np.array([0.0, 0.0, 0.0, 0.1, 0.1]),
    # Flour
    "wheat_flour": np.array([0.1, 0.0, 0.0, 0.1, 0.1]),
    "almond_flour": np.array([0.1, 0.0, 0.0, 0.1, 0.2]),
    "oat_flour": np.array([0.15, 0.0, 0.0, 0.0, 0.1]),
    # Chocolate
    "milk_choc": np.array([0.7, 0.1, 0.0, 0.3, 0.1]),
    "dark_choc": np.array([0.3, 0.0, 0.0, 0.7, 0.1]),
    "white_choc": np.array([0.8, 0.1, 0.1, 0.0, 0.1]),
}


def hamming_distance(r1, r2):
    return int(np.sum(np.array(r1) != np.array(r2)))


# ============================================================
# APPLICATION 1: Recipe Optimization
# ============================================================
def optimize_recipe(
    slot_options: list,
    ingredient_db: dict,
    target_flavor: np.ndarray,
    weights: np.ndarray = None,
):
    """
    Find the recipe (combination of ingredients) closest to a target flavor.

    slot_options: list of lists, where slot_options[i] = available ingredients for slot i
    target_flavor: desired flavor profile
    weights: importance weights for each flavor dimension

    Returns the best recipe and its flavor distance.
    """
    if weights is None:
        weights = np.ones(len(target_flavor))

    best_recipe = None
    best_dist = float("inf")

    for combo in product(*slot_options):
        flavor = sum(ingredient_db[ing] for ing in combo)
        dist = np.sqrt(np.sum(weights * (flavor - target_flavor) ** 2))
        if dist < best_dist:
            best_dist = dist
            best_recipe = combo

    return best_recipe, best_dist


# ============================================================
# APPLICATION 2: Substitution Path Planner
# ============================================================
def find_substitution_path(recipe1: tuple, recipe2: tuple):
    """
    Find a shortest path of single-ingredient substitutions
    from recipe1 to recipe2.

    Returns list of (slot_index, old_ingredient, new_ingredient) steps.
    """
    steps = []
    current = list(recipe1)
    for i in range(len(recipe1)):
        if current[i] != recipe2[i]:
            old = current[i]
            current[i] = recipe2[i]
            steps.append((i, old, recipe2[i]))
    return steps


# ============================================================
# APPLICATION 3: Recipe Diversity Metric
# ============================================================
def recipe_diversity(recipes: list, ingredient_db: dict):
    """
    Compute diversity metrics for a collection of recipes.

    Returns:
    - hamming_diversity: average pairwise Hamming distance
    - flavor_diversity: average pairwise flavor distance
    - flavor_coverage: volume of convex hull in flavor space (approx)
    """
    n = len(recipes)
    if n <= 1:
        return 0.0, 0.0, 0.0

    # Hamming diversity
    total_hamming = 0
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            total_hamming += hamming_distance(recipes[i], recipes[j])
            count += 1
    hamming_div = total_hamming / count

    # Flavor diversity
    flavors = [sum(ingredient_db[ing] for ing in r) for r in recipes]
    total_flavor = 0
    for i in range(n):
        for j in range(i + 1, n):
            total_flavor += np.linalg.norm(flavors[i] - flavors[j])
    flavor_div = total_flavor / count

    # Flavor coverage (variance-based approximation)
    flavor_matrix = np.array(flavors)
    coverage = np.sqrt(np.sum(np.var(flavor_matrix, axis=0)))

    return hamming_div, flavor_div, coverage


# ============================================================
# DEMO
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Cookie Recipe Optimization")
    print("=" * 60)

    cookie_slots = [
        ["wheat_flour", "almond_flour", "oat_flour"],  # flour
        ["butter", "coconut_oil"],  # fat
        ["sugar", "honey", "maple_syrup"],  # sweetener
        ["egg", "flax_egg"],  # binder
        ["milk_choc", "dark_choc", "white_choc"],  # chocolate
    ]

    # Target: balanced chocolate chip cookie
    target = np.array([0.5, 0.1, 0.0, 0.3, 0.3])

    best, dist = optimize_recipe(cookie_slots, INGREDIENT_DB, target)
    best_flavor = sum(INGREDIENT_DB[ing] for ing in best)
    print(f"Target flavor: {dict(zip(FLAVOR_DIMS, target))}")
    print(f"Best recipe: {best}")
    print(f"Best flavor:  {dict(zip(FLAVOR_DIMS, np.round(best_flavor, 2)))}")
    print(f"Distance: {dist:.4f}")

    total_recipes = 1
    for slot in cookie_slots:
        total_recipes *= len(slot)
    print(f"Searched {total_recipes} recipes (= product of slot sizes)")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Substitution Path Planner")
    print("=" * 60)

    recipe1 = ("wheat_flour", "butter", "sugar", "egg", "milk_choc")
    recipe2 = ("almond_flour", "coconut_oil", "honey", "flax_egg", "dark_choc")

    steps = find_substitution_path(recipe1, recipe2)
    slot_names = ["flour", "fat", "sweetener", "binder", "chocolate"]
    print(f"From: {recipe1}")
    print(f"To:   {recipe2}")
    print(f"Substitution path ({len(steps)} steps):")
    for slot_idx, old, new in steps:
        print(f"  Step: {slot_names[slot_idx]}: {old} → {new}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Recipe Collection Diversity")
    print("=" * 60)

    collection1 = [
        ("wheat_flour", "butter", "sugar", "egg", "milk_choc"),
        ("wheat_flour", "butter", "sugar", "egg", "dark_choc"),
    ]

    collection2 = [
        ("wheat_flour", "butter", "sugar", "egg", "milk_choc"),
        ("almond_flour", "coconut_oil", "honey", "flax_egg", "dark_choc"),
    ]

    h1, f1, c1 = recipe_diversity(collection1, INGREDIENT_DB)
    h2, f2, c2 = recipe_diversity(collection2, INGREDIENT_DB)

    print("Collection 1 (similar recipes):")
    print(f"  Hamming diversity: {h1:.2f}, Flavor diversity: {f1:.4f}, Coverage: {c1:.4f}")
    print("Collection 2 (diverse recipes):")
    print(f"  Hamming diversity: {h2:.2f}, Flavor diversity: {f2:.4f}, Coverage: {c2:.4f}")


"""
Homotopy Type Theory of Cooking Recipes: Paths Between Dishes
=============================================================

Demonstrates the mathematical model connecting recipes to Hamming graphs,
flavor spaces, and coding theory.

Key concepts:
- Recipes as points in a discrete product space (Fin n → Fin m)
- Hamming distance as substitution distance
- Flavor maps from recipe space to R^d
- Fiber structure of flavor maps
"""

import numpy as np
from itertools import product

def hamming_distance(r1, r2):
    """Compute Hamming distance between two recipes (integer arrays)."""
    return int(np.sum(r1 != r2))

def all_recipes(n, m):
    """Generate all recipes with n slots and m choices per slot."""
    return np.array(list(product(range(m), repeat=n)))

def substitution_neighbors(recipe, m):
    """Find all recipes adjacent to `recipe` (differ in exactly one slot)."""
    n = len(recipe)
    nbrs = []
    for i in range(n):
        for v in range(m):
            if v != recipe[i]:
                nbr = recipe.copy()
                nbr[i] = v
                nbrs.append(nbr)
    return nbrs

def flavor_map_linear(recipe, W, b):
    """A linear flavor map: F(r) = W @ r + b, where r is treated as real vector."""
    return W @ recipe.astype(float) + b

def compute_fibers(recipes, flavor_fn, tolerance=1e-8):
    """Group recipes by their flavor profile (up to tolerance)."""
    fibers = {}
    for r in recipes:
        fp = tuple(np.round(flavor_fn(r) / tolerance) * tolerance)
        if fp not in fibers:
            fibers[fp] = []
        fibers[fp].append(r.tolist())
    return fibers

# --- DEMO 1: Recipe Space Structure ---
print("=" * 60)
print("DEMO 1: Recipe Space Structure (n=3, m=2)")
print("=" * 60)
n, m = 3, 2
recipes = all_recipes(n, m)
print(f"Total recipes: {len(recipes)} (expected: {m}**{n} = {m**n})")
print(f"Sample recipes: {recipes[:4].tolist()}")

# Hamming distances
r0 = recipes[0]  # [0,0,0]
r7 = recipes[-1]  # [1,1,1]
print(f"\nHamming distance from {r0} to {r7}: {hamming_distance(r0, r7)}")
print(f"Maximum possible (= n = {n}): {n}")

# Triangle inequality demo
r_mid = np.array([1, 0, 0])
d12 = hamming_distance(r0, r_mid)
d23 = hamming_distance(r_mid, r7)
d13 = hamming_distance(r0, r7)
print(f"\nTriangle inequality: d(r1,r3) = {d13} ≤ d(r1,r2) + d(r2,r3) = {d12} + {d23} = {d12+d23} ✓")

# Neighbor count
nbrs = substitution_neighbors(r0, m)
print(f"\nNeighbors of {r0}: {len(nbrs)} (expected: n*(m-1) = {n*(m-1)})")

# --- DEMO 2: Flavor Maps and Fibers ---
print("\n" + "=" * 60)
print("DEMO 2: Flavor Maps and Fibers (n=4, m=3, d=2)")
print("=" * 60)
n, m, d = 4, 3, 2
np.random.seed(42)
W = np.random.randn(d, n)
b = np.random.randn(d)

recipes = all_recipes(n, m)
print(f"Total recipes: {len(recipes)} (= {m}^{n} = {m**n})")

fibers = compute_fibers(recipes, lambda r: flavor_map_linear(r, W, b))
print(f"Number of distinct flavor profiles: {len(fibers)}")
max_fiber = max(len(v) for v in fibers.values())
print(f"Maximum fiber size: {max_fiber}")
print(f"Conjecture bound (m^(n-d) = {m**(n-d)}): {'HOLDS' if max_fiber <= m**(n-d) else 'VIOLATED'}")

# --- DEMO 3: Lipschitz Continuity ---
print("\n" + "=" * 60)
print("DEMO 3: Lipschitz Continuity of Flavor Maps")
print("=" * 60)
n, m, d = 3, 3, 2
W = np.random.randn(d, n)
b = np.zeros(d)

# Compute Lipschitz constant
max_ratio = 0
recipes = all_recipes(n, m)
for i in range(len(recipes)):
    for j in range(i+1, len(recipes)):
        r1, r2 = recipes[i], recipes[j]
        hd = hamming_distance(r1, r2)
        if hd > 0:
            fd = np.linalg.norm(flavor_map_linear(r1, W, b) - flavor_map_linear(r2, W, b))
            ratio = fd / hd
            max_ratio = max(max_ratio, ratio)

K = max_ratio
print(f"Empirical Lipschitz constant K = {K:.4f}")
print(f"Diameter bound: K * n = {K * n:.4f}")

# Verify all pairs satisfy Lipschitz
violations = 0
for i in range(len(recipes)):
    for j in range(i+1, len(recipes)):
        r1, r2 = recipes[i], recipes[j]
        hd = hamming_distance(r1, r2)
        fd = np.linalg.norm(flavor_map_linear(r1, W, b) - flavor_map_linear(r2, W, b))
        if fd > K * hd + 1e-10:
            violations += 1
print(f"Lipschitz violations: {violations}")

# --- DEMO 4: Hamming Ball Sizes ---
print("\n" + "=" * 60)
print("DEMO 4: Hamming Ball Sizes (binary recipes, m=2)")
print("=" * 60)
for n in [3, 4, 5, 6]:
    recipes = all_recipes(n, 2)
    center = np.zeros(n, dtype=int)
    for r_val in range(n+1):
        ball = [rec for rec in recipes if hamming_distance(center, rec) <= r_val]
        print(f"  n={n}, radius={r_val}: |B(0,{r_val})| = {len(ball)}", end="")
        if r_val == 0:
            print("  (singleton)", end="")
        elif r_val == n:
            print(f"  (full space = 2^{n} = {2**n})", end="")
        print()

# --- DEMO 5: Conjecture Test ---
print("\n" + "=" * 60)
print("DEMO 5: Fiber Size Conjecture Test")
print("=" * 60)
print("Testing: for generic linear F: R^n -> R^d, max |fiber(p)| ≤ m^(n-d)")
n, m, d = 4, 3, 2
bound = m ** (n - d)
num_tests = 100
violations = 0
max_seen = 0

for trial in range(num_tests):
    W = np.random.randn(d, n)
    b = np.random.randn(d)
    recipes = all_recipes(n, m)
    fibers = compute_fibers(recipes, lambda r: flavor_map_linear(r, W, b), tolerance=1e-6)
    trial_max = max(len(v) for v in fibers.values())
    max_seen = max(max_seen, trial_max)
    if trial_max > bound:
        violations += 1

print(f"Parameters: n={n}, m={m}, d={d}")
print(f"Conjectured bound: m^(n-d) = {bound}")
print(f"Maximum fiber size seen: {max_seen}")
print(f"Violations in {num_tests} trials: {violations}")
print(f"Conjecture status: {'SUPPORTED' if violations == 0 else 'REFUTED'}")

print("\n" + "=" * 60)
print("All demos complete.")
print("=" * 60)


"""
Visualization 2: Flavor Fibers — Preimages of the Flavor Map
=============================================================
Shows how a linear flavor map F: Recipe(4,3) → R^2 partitions
the 81-recipe space into fibers. Each fiber is a set of recipes
that produce the same flavor profile. Recipes are plotted in
flavor space (R^2) and colored by fiber size.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product
from collections import defaultdict

def hamming_distance(r1, r2):
    return int(np.sum(np.array(r1) != np.array(r2)))

# Parameters
n, m, d = 4, 3, 2
np.random.seed(42)

# Generate all recipes
recipes = np.array(list(product(range(m), repeat=n)))

# Linear flavor map
W = np.array([[1.2, -0.5, 0.8, -0.3],
              [0.4, 0.9, -0.6, 1.1]])
b = np.array([0.5, -0.2])

# Compute flavor profiles
flavors = np.array([W @ r.astype(float) + b for r in recipes])

# Group into fibers
tolerance = 1e-6
fibers = defaultdict(list)
for i, f in enumerate(flavors):
    key = tuple(np.round(f / tolerance) * tolerance)
    fibers[key].append(i)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: scatter plot colored by fiber size
ax = axes[0]
fiber_sizes = []
for i in range(len(recipes)):
    f = flavors[i]
    key = tuple(np.round(f / tolerance) * tolerance)
    fiber_sizes.append(len(fibers[key]))

scatter = ax.scatter(flavors[:, 0], flavors[:, 1],
                     c=fiber_sizes, cmap='viridis', s=50,
                     edgecolors='black', linewidth=0.5, alpha=0.8)
cbar = plt.colorbar(scatter, ax=ax)
cbar.set_label('Fiber size (recipes with same flavor)', fontsize=10)
ax.set_xlabel('Flavor dimension 1 (sweet–savory axis)', fontsize=11)
ax.set_ylabel('Flavor dimension 2 (mild–spicy axis)', fontsize=11)
ax.set_title(f'Flavor Map: {m}^{n} = {m**n} Recipes → R²\n'
             f'{len(fibers)} distinct flavor profiles', fontsize=12)
ax.grid(True, alpha=0.3)

# Right: histogram of fiber sizes
ax2 = axes[1]
sizes = [len(v) for v in fibers.values()]
ax2.hist(sizes, bins=range(1, max(sizes)+2), edgecolor='black',
         color='steelblue', alpha=0.8, align='left')
ax2.set_xlabel('Fiber size', fontsize=11)
ax2.set_ylabel('Number of fibers', fontsize=11)
ax2.set_title(f'Distribution of Fiber Sizes\n'
              f'Max fiber size = {max(sizes)}, '
              f'Conjectured bound = m^(n-d) = {m**(n-d)}', fontsize=12)
ax2.axvline(x=m**(n-d), color='red', linestyle='--', linewidth=2,
            label=f'Conjectured bound = {m**(n-d)}')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

plt.suptitle('Culinary Homotopy: Fiber Structure of the Flavor Map',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_flavor_fibers.png', dpi=150, bbox_inches='tight')
print("Saved viz_flavor_fibers.png")


"""
Visualization 3: Hamming Ball Growth
=====================================
Shows how the size of Hamming balls grows with radius for different
recipe space parameters. Connects to sphere-packing bounds in coding theory.
The Hamming ball B(center, r) contains all recipes reachable by at most
r single-ingredient substitutions.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def hamming_ball_size_exact(n, m, r):
    """Exact size of Hamming ball B(center, r) in H(n,m)."""
    total = 0
    for k in range(min(r, n) + 1):
        total += comb(n, k) * (m - 1) ** k
    return total

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left plot: Ball size vs radius for different (n, m)
ax = axes[0]
configs = [
    (5, 2, 'Binary (m=2), n=5', 'o-'),
    (5, 3, 'Ternary (m=3), n=5', 's-'),
    (5, 4, 'Quaternary (m=4), n=5', '^-'),
    (8, 2, 'Binary (m=2), n=8', 'D--'),
    (8, 3, 'Ternary (m=3), n=8', 'v--'),
]

for n, m, label, fmt in configs:
    radii = list(range(n + 1))
    sizes = [hamming_ball_size_exact(n, m, r) for r in radii]
    total = m ** n
    fractions = [s / total for s in sizes]
    ax.plot(radii, fractions, fmt, label=label, linewidth=2, markersize=6)

ax.set_xlabel('Hamming Ball Radius r', fontsize=12)
ax.set_ylabel('Fraction of Recipe Space Covered', fontsize=12)
ax.set_title('Hamming Ball Growth\n'
             '(fraction of all recipes within r substitutions)', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.05)

# Right plot: Ball size (absolute) for n=6, m=3
ax2 = axes[1]
n, m = 6, 3
radii = list(range(n + 1))
sizes = [hamming_ball_size_exact(n, m, r) for r in radii]

bars = ax2.bar(radii, sizes, color='coral', edgecolor='black', alpha=0.8)
ax2.axhline(y=m**n, color='red', linestyle='--', linewidth=2,
            label=f'Total space = {m}^{n} = {m**n}')

# Annotate bars
for i, (r_val, s) in enumerate(zip(radii, sizes)):
    ax2.text(r_val, s + m**n * 0.02, str(s), ha='center', fontsize=9, fontweight='bold')

ax2.set_xlabel('Hamming Ball Radius r', fontsize=12)
ax2.set_ylabel('Number of Recipes in Ball', fontsize=12)
ax2.set_title(f'Hamming Ball Sizes for H({n},{m})\n'
              f'n={n} slots, m={m} choices/slot, {m**n} total recipes', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

plt.suptitle('Coding Theory Meets Cooking: Hamming Ball Structure',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_hamming_balls.png', dpi=150, bbox_inches='tight')
print("Saved viz_hamming_balls.png")


"""
Visualization 1: Substitution Graph for Binary Recipes
=======================================================
Visualizes the Hamming graph H(n,2) for n=3 (a 3-dimensional hypercube).
Each vertex is a recipe (binary choice in each of 3 slots),
and edges connect recipes differing in exactly one slot.
Colored by Hamming distance from the origin recipe [0,0,0].
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from itertools import product

def hamming_distance(r1, r2):
    return int(np.sum(np.array(r1) != np.array(r2)))

# Generate all binary recipes with n=3 slots
n = 3
recipes = list(product(range(2), repeat=n))
origin = (0, 0, 0)

# 3D coordinates for the hypercube
coords = {r: np.array(r, dtype=float) for r in recipes}

# Compute edges (adjacent = Hamming distance 1)
edges = []
for i, r1 in enumerate(recipes):
    for j, r2 in enumerate(recipes):
        if i < j and hamming_distance(r1, r2) == 1:
            edges.append((r1, r2))

# Color by Hamming distance from origin
colors = [hamming_distance(r, origin) for r in recipes]
cmap = plt.cm.RdYlGn_r

fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')

# Draw edges
for r1, r2 in edges:
    c1, c2 = coords[r1], coords[r2]
    ax.plot([c1[0], c2[0]], [c1[1], c2[1]], [c1[2], c2[2]],
            'k-', alpha=0.3, linewidth=1)

# Draw vertices
for r in recipes:
    c = coords[r]
    d = hamming_distance(r, origin)
    color = cmap(d / n)
    ax.scatter(*c, s=200, c=[color], edgecolors='black', linewidth=1.5, zorder=5)
    label = ''.join(str(x) for x in r)
    ax.text(c[0]+0.08, c[1]+0.08, c[2]+0.08, label, fontsize=9, fontweight='bold')

ax.set_xlabel('Slot 1 (flour type)')
ax.set_ylabel('Slot 2 (fat type)')
ax.set_zlabel('Slot 3 (sweetener)')
ax.set_title('Substitution Graph H(3,2): The Cookie Hypercube\n'
             'Each vertex is a recipe, edges = single-ingredient substitutions\n'
             'Color = Hamming distance from origin recipe [0,0,0]',
             fontsize=11)

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor=cmap(0/n), edgecolor='black', label='Distance 0'),
    Patch(facecolor=cmap(1/n), edgecolor='black', label='Distance 1'),
    Patch(facecolor=cmap(2/n), edgecolor='black', label='Distance 2'),
    Patch(facecolor=cmap(3/n), edgecolor='black', label='Distance 3'),
]
ax.legend(handles=legend_elements, loc='upper left', fontsize=9)

plt.tight_layout()
plt.savefig('viz_substitution_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_substitution_graph.png")
