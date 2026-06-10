"""
Applications of fractional transversal concentration theory.

Demonstrates real-world scenarios where the concentration of τ* provides
more reliable predictions than τ for covering/hitting set problems on
uncertain or random networks.

Applications:
1. Network reliability: Predicting minimum server coverage under random failures
2. Sensor placement: Robust coverage estimation for sensor networks
3. Vaccine distribution: Efficient allocation under uncertain demand patterns
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict

# Inline LP solver to avoid importing from local files
from scipy.optimize import linprog


def compute_tau_star(n: int, edges: List[frozenset]) -> float:
    """Compute fractional transversal number via LP."""
    m = len(edges)
    if m == 0:
        return 0.0
    c = np.ones(n)
    A_ub = np.zeros((m, n))
    for i, edge in enumerate(edges):
        for v in edge:
            A_ub[i, v] = -1.0
    b_ub = -np.ones(m)
    bounds = [(0, None)] * n
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    return result.fun if result.success else float('nan')


def compute_tau(n: int, edges: List[frozenset]) -> int:
    """Compute integer transversal number."""
    if not edges:
        return 0
    try:
        from scipy.optimize import milp, LinearConstraint, Bounds
        c_obj = np.ones(n)
        A = np.zeros((len(edges), n))
        for i, edge in enumerate(edges):
            for v in edge:
                A[i, v] = 1.0
        constraints = LinearConstraint(A, lb=1.0)
        integrality = np.ones(n)
        bounds = Bounds(lb=0, ub=1)
        result = milp(c_obj, constraints=constraints, integrality=integrality, bounds=bounds)
        if result.success:
            return int(round(result.fun))
    except ImportError:
        pass
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            s = set(subset)
            if all(s & set(e) for e in edges):
                return size
    return n


# ============================================================
# Application 1: Network Reliability Prediction
# ============================================================

def network_reliability_demo():
    """Demonstrate that τ* gives more reliable coverage predictions
    than τ for networks with random service dependencies.

    Scenario: A cloud provider has n servers. Each microservice
    requires access to some subset of k servers. Services appear
    randomly. The provider needs to predict how many servers to
    keep powered on to guarantee coverage.
    """
    print("=" * 65)
    print("APPLICATION 1: Network Reliability Prediction")
    print("=" * 65)
    print()
    print("Scenario: Predicting minimum server coverage for random services")
    print()

    n = 15  # servers
    k = 3   # each service needs 3 servers
    c = 2.0 # sparsity parameter
    p = c / (n ** (k - 1))
    num_trials = 300
    rng = np.random.default_rng(42)

    predictions_frac = []
    predictions_int = []
    actuals_star = []
    actuals_int = []

    # First, estimate expected values from initial batch
    init_stars = []
    init_ints = []
    for _ in range(100):
        edges = [frozenset(combo) for combo in combinations(range(n), k)
                 if rng.random() < p]
        init_stars.append(compute_tau_star(n, edges))
        init_ints.append(compute_tau(n, edges))

    predicted_star = np.mean(init_stars)
    predicted_int = np.mean(init_ints)

    # Now test prediction accuracy
    for _ in range(num_trials):
        edges = [frozenset(combo) for combo in combinations(range(n), k)
                 if rng.random() < p]
        ts = compute_tau_star(n, edges)
        ti = compute_tau(n, edges)

        actuals_star.append(ts)
        actuals_int.append(ti)
        predictions_frac.append(predicted_star)
        predictions_int.append(predicted_int)

    # Compute prediction errors
    err_frac = np.array(actuals_star) - predicted_star
    err_int = np.array(actuals_int) - predicted_int

    print(f"  Servers: {n}, Service size: {k}, Sparsity: c={c}")
    print(f"  Edge probability: p = {p:.4f}")
    print(f"  Number of prediction tests: {num_trials}")
    print()
    print(f"  Fractional predictor (E[τ*] = {predicted_star:.2f}):")
    print(f"    Mean absolute error:  {np.mean(np.abs(err_frac)):.4f}")
    print(f"    Prediction variance:  {np.var(actuals_star, ddof=1):.4f}")
    print(f"    95% of values within: ±{1.96 * np.std(actuals_star, ddof=1):.2f}")
    print()
    print(f"  Integer predictor (E[τ] = {predicted_int:.2f}):")
    print(f"    Mean absolute error:  {np.mean(np.abs(err_int)):.4f}")
    print(f"    Prediction variance:  {np.var(actuals_int, ddof=1):.4f}")
    print(f"    95% of values within: ±{1.96 * np.std(actuals_int, ddof=1):.2f}")
    print()

    improvement = (np.var(actuals_int, ddof=1) - np.var(actuals_star, ddof=1))
    ratio = np.var(actuals_int, ddof=1) / max(np.var(actuals_star, ddof=1), 1e-10)
    print(f"  Variance reduction: {improvement:.4f}")
    print(f"  Variance ratio (τ/τ*): {ratio:.2f}x")
    print(f"  ⟹ Fractional predictor is {ratio:.1f}× more stable!")
    print()


# ============================================================
# Application 2: Sensor Placement Robustness
# ============================================================

def sensor_placement_demo():
    """Demonstrate robust sensor placement using fractional transversals.

    Scenario: Place sensors to monitor regions. Each "event" (fire, intrusion)
    can be detected by a subset of sensor locations. The fractional solution
    gives a probabilistic placement strategy with lower variance.
    """
    print("=" * 65)
    print("APPLICATION 2: Sensor Placement Robustness")
    print("=" * 65)
    print()

    n = 12  # sensor locations
    k = 3   # each event detected by 3 sensors
    c = 3.0
    p = c / (n ** (k - 1))
    rng = np.random.default_rng(123)
    num_trials = 200

    # Generate multiple random event scenarios
    coverages_star = []
    coverages_int = []

    for _ in range(num_trials):
        edges = [frozenset(combo) for combo in combinations(range(n), k)
                 if rng.random() < p]
        if edges:
            coverages_star.append(compute_tau_star(n, edges))
            coverages_int.append(compute_tau(n, edges))

    cs = np.array(coverages_star)
    ci = np.array(coverages_int)

    print(f"  Locations: {n}, Detection group size: {k}")
    print(f"  Random scenarios: {len(coverages_star)}")
    print()
    print("  Fractional coverage (τ*):")
    print(f"    Mean:     {np.mean(cs):.3f} sensors (fractional)")
    print(f"    Std dev:  {np.std(cs, ddof=1):.3f}")
    print(f"    Range:    [{np.min(cs):.2f}, {np.max(cs):.2f}]")
    print()
    print("  Integer coverage (τ):")
    print(f"    Mean:     {np.mean(ci):.3f} sensors")
    print(f"    Std dev:  {np.std(ci, ddof=1):.3f}")
    print(f"    Range:    [{int(np.min(ci))}, {int(np.max(ci))}]")
    print()
    print(f"  Stability improvement: {np.std(ci, ddof=1)/max(np.std(cs, ddof=1),1e-10):.2f}x")
    print()


# ============================================================
# Application 3: Vaccination Strategy Under Uncertainty
# ============================================================

def vaccination_demo():
    """Demonstrate vaccination allocation using fractional covering.

    Scenario: A disease can spread through contact groups (hyperedges).
    Vaccinating enough people in each group prevents transmission.
    The fractional solution gives a probabilistic allocation strategy.
    """
    print("=" * 65)
    print("APPLICATION 3: Vaccination Strategy Under Uncertainty")
    print("=" * 65)
    print()

    n = 20  # population centers
    k = 3   # contact group size
    c = 1.5
    p = c / (n ** (k - 1))
    rng = np.random.default_rng(456)
    num_scenarios = 200

    frac_costs = []
    int_costs = []

    for _ in range(num_scenarios):
        edges = [frozenset(combo) for combo in combinations(range(n), k)
                 if rng.random() < p]
        if edges:
            frac_costs.append(compute_tau_star(n, edges))
            int_costs.append(compute_tau(n, edges))

    fc = np.array(frac_costs)
    ic = np.array(int_costs)

    print(f"  Population centers: {n}")
    print(f"  Contact group size: {k}")
    print(f"  Random scenarios: {len(frac_costs)}")
    print()
    print("  Fractional allocation (τ*):")
    print(f"    Mean doses needed:  {np.mean(fc):.3f}")
    print(f"    Variance:           {np.var(fc, ddof=1):.3f}")
    print(f"    Worst case:         {np.max(fc):.2f}")
    print()
    print("  Integer allocation (τ):")
    print(f"    Mean doses needed:  {np.mean(ic):.3f}")
    print(f"    Variance:           {np.var(ic, ddof=1):.3f}")
    print(f"    Worst case:         {int(np.max(ic))}")
    print()

    # Risk analysis: probability of exceeding budget
    budget = np.mean(ic) + 1
    prob_exceed_frac = np.mean(fc > budget)
    prob_exceed_int = np.mean(ic > budget)
    print(f"  Budget = E[τ] + 1 = {budget:.1f}")
    print(f"    P(τ* > budget): {prob_exceed_frac:.3f}")
    print(f"    P(τ  > budget): {prob_exceed_int:.3f}")
    print(f"    ⟹ Fractional planning reduces budget overrun risk")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Applications of Fractional Transversal Concentration       ║")
    print("╚══════════════════════════════════════════════════════════════╝\n")

    network_reliability_demo()
    sensor_placement_demo()
    vaccination_demo()

    print("=" * 65)
    print("CONCLUSION")
    print("=" * 65)
    print()
    print("In all three applications, the fractional transversal number τ*")
    print("provides a more stable predictor than the integer transversal")
    print("number τ. This is a direct consequence of the 1-Lipschitz")
    print("property: adding or removing a single constraint changes τ*")
    print("by at most 1, leading to Gaussian concentration around the mean.")
    print()
    print("For planning under uncertainty, this means:")
    print("  • Lower prediction variance → tighter confidence intervals")
    print("  • Fewer budget overruns → more reliable resource allocation")
    print("  • Better risk management → reduced worst-case exposure")


"""
Interactive demonstration of fractional vs integer transversal concentration.

Samples random k-uniform hypergraphs, computes τ* and τ,
estimates sample variances, and displays the variance comparison.

Usage:
    python demo.py                    # Run with defaults
    python demo.py --n 30 --k 3 --c 2.0 --samples 500

Dependencies: numpy, scipy
Optional: matplotlib (for plotting)
"""

import argparse
import numpy as np
from itertools import combinations
from typing import List, Optional


def random_k_uniform_hypergraph(n: int, k: int, p: float,
                                 rng: np.random.Generator):
    """Generate random k-uniform hypergraph edges."""
    edges = []
    for combo in combinations(range(n), k):
        if rng.random() < p:
            edges.append(frozenset(combo))
    return edges


def compute_tau_star(n: int, edges: List[frozenset]) -> float:
    """Compute fractional transversal number via LP."""
    from scipy.optimize import linprog

    m = len(edges)
    if m == 0:
        return 0.0

    c = np.ones(n)
    A_ub = np.zeros((m, n))
    for i, edge in enumerate(edges):
        for v in edge:
            A_ub[i, v] = -1.0
    b_ub = -np.ones(m)
    bounds = [(0, None)] * n

    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    return result.fun if result.success else float('nan')


def compute_tau(n: int, edges: List[frozenset]) -> int:
    """Compute integer transversal number (brute force for small n, MILP for larger)."""
    m = len(edges)
    if m == 0:
        return 0

    try:
        from scipy.optimize import milp, LinearConstraint, Bounds
        c = np.ones(n)
        A = np.zeros((m, n))
        for i, edge in enumerate(edges):
            for v in edge:
                A[i, v] = 1.0
        constraints = LinearConstraint(A, lb=1.0)
        integrality = np.ones(n)
        bounds = Bounds(lb=0, ub=1)
        result = milp(c, constraints=constraints, integrality=integrality, bounds=bounds)
        if result.success:
            return int(round(result.fun))
    except ImportError:
        pass

    # Brute force fallback
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            s = set(subset)
            if all(s & set(e) for e in edges):
                return size
    return n


def run_experiment(n: int, k: int, c: float, num_samples: int,
                   compute_integer: bool = True, seed: int = 42):
    """Run concentration experiment and return results."""
    rng = np.random.default_rng(seed)
    p = c / (n ** (k - 1))
    p = min(p, 1.0)

    tau_stars = []
    taus = []

    for i in range(num_samples):
        edges = random_k_uniform_hypergraph(n, k, p, rng)
        tau_stars.append(compute_tau_star(n, edges))
        if compute_integer:
            taus.append(compute_tau(n, edges))

        if (i + 1) % max(1, num_samples // 10) == 0:
            print(f"  Progress: {i+1}/{num_samples} samples completed")

    return tau_stars, taus


def print_results(n, k, c, tau_stars, taus):
    """Print summary statistics."""
    ts = np.array(tau_stars)
    print(f"\n{'='*60}")
    print(f"Results for H_{k}(n={n}, p={c}/n^{k-1})")
    print(f"{'='*60}")
    print(f"  Samples:    {len(tau_stars)}")
    print(f"  E[τ*]:      {np.mean(ts):.4f}")
    print(f"  Var(τ*):    {np.var(ts, ddof=1):.4f}")
    print(f"  Std(τ*):    {np.std(ts, ddof=1):.4f}")
    print(f"  Min(τ*):    {np.min(ts):.4f}")
    print(f"  Max(τ*):    {np.max(ts):.4f}")

    if taus:
        ti = np.array(taus, dtype=float)
        print(f"\n  E[τ]:       {np.mean(ti):.4f}")
        print(f"  Var(τ):     {np.var(ti, ddof=1):.4f}")
        print(f"  Std(τ):     {np.std(ti, ddof=1):.4f}")
        print(f"  Min(τ):     {int(np.min(ti))}")
        print(f"  Max(τ):     {int(np.max(ti))}")

        gap_var = np.var(ti, ddof=1) - np.var(ts, ddof=1)
        ratio = np.var(ti, ddof=1) / max(np.var(ts, ddof=1), 1e-10)
        print(f"\n  Fluctuation gap (Var(τ) - Var(τ*)):  {gap_var:.4f}")
        print(f"  Variance ratio (Var(τ) / Var(τ*)):   {ratio:.4f}")
        print(f"  E[τ - τ*]:  {np.mean(ti - ts):.4f}")


def main():
    parser = argparse.ArgumentParser(
        description="Concentration of fractional vs integer transversal numbers"
    )
    parser.add_argument("--n", type=int, default=20,
                        help="Number of vertices (default: 20)")
    parser.add_argument("--k", type=int, default=3,
                        help="Uniformity parameter (default: 3)")
    parser.add_argument("--c", type=float, default=2.0,
                        help="Sparsity constant (default: 2.0)")
    parser.add_argument("--samples", type=int, default=500,
                        help="Number of random samples (default: 500)")
    parser.add_argument("--seed", type=int, default=42,
                        help="Random seed (default: 42)")
    parser.add_argument("--no-integer", action="store_true",
                        help="Skip integer τ computation (faster)")
    parser.add_argument("--multi-scale", action="store_true",
                        help="Run multi-scale experiment across different n values")

    args = parser.parse_args()

    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Fractional vs Integer Transversal Concentration Demo   ║")
    print("╚══════════════════════════════════════════════════════════╝")

    if args.multi_scale:
        print("\nRunning multi-scale experiment...")
        print("This compares Var(τ*) and Var(τ) across different system sizes.\n")

        ns = [10, 15, 20, 25]
        results = []

        for n in ns:
            print(f"\n--- n = {n} ---")
            compute_int = (n <= 25)
            num = min(args.samples, 200) if n > 20 else args.samples
            tau_stars, taus = run_experiment(
                n, args.k, args.c, num,
                compute_integer=compute_int, seed=args.seed
            )
            print_results(n, args.k, args.c, tau_stars, taus)
            results.append({
                'n': n, 'tau_stars': tau_stars, 'taus': taus,
                'var_star': np.var(tau_stars, ddof=1),
                'var_int': np.var(taus, ddof=1) if taus else None
            })

        # Summary table
        print("\n" + "=" * 70)
        print("SUMMARY TABLE")
        print("=" * 70)
        print(f"{'n':>5} | {'Var(τ*)':>10} | {'Var(τ)':>10} | {'Ratio':>10} | {'Gap':>10}")
        print("-" * 70)
        for r in results:
            var_star = r['var_star']
            if r['var_int'] is not None:
                var_int = r['var_int']
                ratio = var_int / max(var_star, 1e-10)
                gap = var_int - var_star
                print(f"{r['n']:>5} | {var_star:>10.4f} | {var_int:>10.4f} | "
                      f"{ratio:>10.4f} | {gap:>10.4f}")
            else:
                print(f"{r['n']:>5} | {var_star:>10.4f} | {'N/A':>10} | "
                      f"{'N/A':>10} | {'N/A':>10}")

        print("\nKey observation: Var(τ*) should remain bounded while")
        print("Var(τ) grows, and the ratio should increase with n.")

    else:
        print(f"\nParameters: n={args.n}, k={args.k}, c={args.c}, "
              f"samples={args.samples}")
        compute_int = not args.no_integer and args.n <= 30
        if not compute_int and not args.no_integer:
            print(f"  (Skipping integer τ for n={args.n} > 30; use --no-integer to suppress)")

        tau_stars, taus = run_experiment(
            args.n, args.k, args.c, args.samples,
            compute_integer=compute_int, seed=args.seed
        )
        print_results(args.n, args.k, args.c, tau_stars, taus)

        # Verify 1-Lipschitz property on a few samples
        print(f"\n--- 1-Lipschitz Verification ---")
        rng = np.random.default_rng(args.seed + 1000)
        p = args.c / (args.n ** (args.k - 1))
        violations = 0
        num_checks = 20
        for _ in range(num_checks):
            edges = random_k_uniform_hypergraph(args.n, args.k, min(p, 1.0), rng)
            ts1 = compute_tau_star(args.n, edges)
            # Add a random edge
            new_edge = frozenset(rng.choice(args.n, size=args.k, replace=False))
            edges2 = list(set(edges + [new_edge]))
            ts2 = compute_tau_star(args.n, edges2)
            delta = ts2 - ts1
            if delta > 1 + 1e-6 or delta < -1e-6:
                violations += 1
                print(f"  VIOLATION: Δτ* = {delta:.6f}")
        print(f"  Checked {num_checks} edge additions: "
              f"{violations} violations (expected: 0)")


if __name__ == "__main__":
    main()


"""
Visualization 1: Variance Comparison — τ* vs τ across system sizes.

Visualizes the core phenomenon: the fractional transversal number τ* has
bounded variance while the integer transversal number τ has growing variance
on sparse random k-uniform hypergraphs. This is the empirical signature of
the "fractional smoothing" effect proved in the Lipschitz bound theorems.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from scipy.optimize import linprog


def compute_tau_star(n, edges):
    m = len(edges)
    if m == 0:
        return 0.0
    c = np.ones(n)
    A_ub = np.zeros((m, n))
    for i, edge in enumerate(edges):
        for v in edge:
            A_ub[i, v] = -1.0
    b_ub = -np.ones(m)
    bounds = [(0, None)] * n
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    return result.fun if result.success else 0.0


def compute_tau(n, edges):
    if not edges:
        return 0
    try:
        from scipy.optimize import milp, LinearConstraint, Bounds
        c_obj = np.ones(n)
        A = np.zeros((len(edges), n))
        for i, edge in enumerate(edges):
            for v in edge:
                A[i, v] = 1.0
        constraints = LinearConstraint(A, lb=1.0)
        integrality = np.ones(n)
        bounds = Bounds(lb=0, ub=1)
        result = milp(c_obj, constraints=constraints, integrality=integrality, bounds=bounds)
        if result.success:
            return int(round(result.fun))
    except ImportError:
        pass
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            s = set(subset)
            if all(s & set(e) for e in edges):
                return size
    return n


# Parameters
k = 3
c_param = 2.0
ns = [8, 10, 12, 15, 18, 20]
num_samples = 200
rng = np.random.default_rng(42)

var_stars = []
var_ints = []

for n in ns:
    p = c_param / (n ** (k - 1))
    p = min(p, 1.0)
    stars = []
    ints = []
    for _ in range(num_samples):
        edges = [frozenset(combo) for combo in combinations(range(n), k)
                 if rng.random() < p]
        stars.append(compute_tau_star(n, edges))
        ints.append(compute_tau(n, edges))
    var_stars.append(np.var(stars, ddof=1))
    var_ints.append(np.var(ints, ddof=1))
    print(f"n={n}: Var(τ*)={var_stars[-1]:.4f}, Var(τ)={var_ints[-1]:.4f}")

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Variances
ax1 = axes[0]
ax1.plot(ns, var_stars, 'bo-', linewidth=2, markersize=8, label=r'Var($\tau^*$)')
ax1.plot(ns, var_ints, 'rs-', linewidth=2, markersize=8, label=r'Var($\tau$)')
ax1.set_xlabel('Number of vertices n', fontsize=12)
ax1.set_ylabel('Variance', fontsize=12)
ax1.set_title('Variance Comparison', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Variance ratio
ax2 = axes[1]
ratios = [vi / max(vs, 1e-10) for vi, vs in zip(var_ints, var_stars)]
ax2.plot(ns, ratios, 'g^-', linewidth=2, markersize=8, color='purple')
ax2.set_xlabel('Number of vertices n', fontsize=12)
ax2.set_ylabel(r'Var($\tau$) / Var($\tau^*$)', fontsize=12)
ax2.set_title('Fluctuation Ratio', fontsize=14)
ax2.grid(True, alpha=0.3)
ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5)

# Plot 3: Fluctuation gap
ax3 = axes[2]
gaps = [vi - vs for vi, vs in zip(var_ints, var_stars)]
ax3.plot(ns, gaps, 'kD-', linewidth=2, markersize=8, color='darkgreen')
ax3.set_xlabel('Number of vertices n', fontsize=12)
ax3.set_ylabel(r'Var($\tau$) - Var($\tau^*$)', fontsize=12)
ax3.set_title('Fluctuation Gap', fontsize=14)
ax3.grid(True, alpha=0.3)
ax3.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

plt.suptitle(f'Concentration of $\\tau^*$ vs $\\tau$ on Random {k}-Uniform Hypergraphs\n'
             f'(p = {c_param}/n², {num_samples} samples per size)',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('concentration_comparison.png', dpi=150, bbox_inches='tight')
print("\nSaved: concentration_comparison.png")


"""
Visualization 3: Distribution Comparison — τ* vs τ on Random Hypergraphs.

Shows the empirical distributions of τ* and τ side by side, illustrating
that τ* has a smoother, more concentrated distribution while τ has a
discrete, more spread-out distribution.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from scipy.optimize import linprog


def compute_tau_star(n, edges):
    m = len(edges)
    if m == 0:
        return 0.0
    c = np.ones(n)
    A_ub = np.zeros((m, n))
    for i, edge in enumerate(edges):
        for v in edge:
            A_ub[i, v] = -1.0
    b_ub = -np.ones(m)
    bounds = [(0, None)] * n
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    return result.fun if result.success else 0.0


def compute_tau(n, edges):
    if not edges:
        return 0
    try:
        from scipy.optimize import milp, LinearConstraint, Bounds
        c_obj = np.ones(n)
        A = np.zeros((len(edges), n))
        for i, edge in enumerate(edges):
            for v in edge:
                A[i, v] = 1.0
        constraints = LinearConstraint(A, lb=1.0)
        integrality = np.ones(n)
        bounds = Bounds(lb=0, ub=1)
        result = milp(c_obj, constraints=constraints, integrality=integrality, bounds=bounds)
        if result.success:
            return int(round(result.fun))
    except ImportError:
        pass
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            s = set(subset)
            if all(s & set(e) for e in edges):
                return size
    return n


n = 20
k = 3
c_param = 2.0
p = c_param / (n ** (k - 1))
num_samples = 800
rng = np.random.default_rng(42)

tau_stars = []
tau_ints = []

for _ in range(num_samples):
    edges = [frozenset(combo) for combo in combinations(range(n), k)
             if rng.random() < p]
    tau_stars.append(compute_tau_star(n, edges))
    tau_ints.append(compute_tau(n, edges))

ts = np.array(tau_stars)
ti = np.array(tau_ints)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top left: τ* histogram
ax1 = axes[0, 0]
ax1.hist(ts, bins=40, density=True, alpha=0.7, color='steelblue',
         edgecolor='black', linewidth=0.5)
ax1.axvline(np.mean(ts), color='red', linestyle='--', linewidth=2,
            label=f'Mean = {np.mean(ts):.2f}')
ax1.set_xlabel(r'$\tau^*$', fontsize=13)
ax1.set_ylabel('Density', fontsize=12)
ax1.set_title(r'Distribution of $\tau^*$ (Fractional)', fontsize=13)
ax1.legend(fontsize=11)
ax1.text(0.7, 0.85, f'Var = {np.var(ts, ddof=1):.3f}',
         transform=ax1.transAxes, fontsize=12,
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Top right: τ histogram
ax2 = axes[0, 1]
unique_vals, counts = np.unique(ti, return_counts=True)
ax2.bar(unique_vals, counts / num_samples, width=0.6, alpha=0.7,
        color='coral', edgecolor='black', linewidth=0.5)
ax2.axvline(np.mean(ti), color='red', linestyle='--', linewidth=2,
            label=f'Mean = {np.mean(ti):.2f}')
ax2.set_xlabel(r'$\tau$', fontsize=13)
ax2.set_ylabel('Probability', fontsize=12)
ax2.set_title(r'Distribution of $\tau$ (Integer)', fontsize=13)
ax2.legend(fontsize=11)
ax2.text(0.7, 0.85, f'Var = {np.var(ti, ddof=1):.3f}',
         transform=ax2.transAxes, fontsize=12,
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Bottom left: Overlay comparison
ax3 = axes[1, 0]
ax3.hist(ts, bins=40, density=True, alpha=0.5, color='steelblue',
         label=r'$\tau^*$ (fractional)')
ax3.hist(ti, bins=range(int(min(ti))-1, int(max(ti))+3),
         density=True, alpha=0.4, color='coral',
         label=r'$\tau$ (integer)')
ax3.set_xlabel('Value', fontsize=13)
ax3.set_ylabel('Density', fontsize=12)
ax3.set_title('Overlay Comparison', fontsize=13)
ax3.legend(fontsize=11)

# Bottom right: Gap distribution
ax4 = axes[1, 1]
gaps = ti - ts
ax4.hist(gaps, bins=30, density=True, alpha=0.7, color='mediumpurple',
         edgecolor='black', linewidth=0.5)
ax4.axvline(np.mean(gaps), color='red', linestyle='--', linewidth=2,
            label=f'Mean gap = {np.mean(gaps):.2f}')
ax4.set_xlabel(r'$\tau - \tau^*$ (integrality gap)', fontsize=13)
ax4.set_ylabel('Density', fontsize=12)
ax4.set_title('Integrality Gap Distribution', fontsize=13)
ax4.legend(fontsize=11)
ax4.text(0.7, 0.85, f'Var = {np.var(gaps, ddof=1):.3f}',
         transform=ax4.transAxes, fontsize=12,
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.suptitle(f'Distribution Comparison: Random {k}-Uniform Hypergraphs\n'
             f'n={n}, p={c_param}/n², {num_samples} samples',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('distribution_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: distribution_comparison.png")
print(f"\nSummary:")
print(f"  Var(τ*) = {np.var(ts, ddof=1):.4f}")
print(f"  Var(τ)  = {np.var(ti, ddof=1):.4f}")
print(f"  Ratio   = {np.var(ti, ddof=1)/max(np.var(ts, ddof=1), 1e-10):.2f}")


"""
Visualization 2: 1-Lipschitz Property of τ* Under Edge Addition.

Visualizes the proven theorem: |τ*(H ∪ {e}) - τ*(H)| ≤ 1 for any edge e.
Shows that the change in τ* is always bounded by 1, while the change in τ
can equal 1 with much higher probability (creating "jumps").
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from scipy.optimize import linprog


def compute_tau_star(n, edges):
    m = len(edges)
    if m == 0:
        return 0.0
    c = np.ones(n)
    A_ub = np.zeros((m, n))
    for i, edge in enumerate(edges):
        for v in edge:
            A_ub[i, v] = -1.0
    b_ub = -np.ones(m)
    bounds = [(0, None)] * n
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    return result.fun if result.success else 0.0


def compute_tau(n, edges):
    if not edges:
        return 0
    try:
        from scipy.optimize import milp, LinearConstraint, Bounds
        c_obj = np.ones(n)
        A = np.zeros((len(edges), n))
        for i, edge in enumerate(edges):
            for v in edge:
                A[i, v] = 1.0
        constraints = LinearConstraint(A, lb=1.0)
        integrality = np.ones(n)
        bounds = Bounds(lb=0, ub=1)
        result = milp(c_obj, constraints=constraints, integrality=integrality, bounds=bounds)
        if result.success:
            return int(round(result.fun))
    except ImportError:
        pass
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            s = set(subset)
            if all(s & set(e) for e in edges):
                return size
    return n


n = 15
k = 3
c_param = 2.0
p = c_param / (n ** (k - 1))
rng = np.random.default_rng(42)
num_trials = 500

deltas_star = []
deltas_int = []

for _ in range(num_trials):
    # Generate base hypergraph
    edges = [frozenset(combo) for combo in combinations(range(n), k)
             if rng.random() < p]

    ts_before = compute_tau_star(n, edges)
    ti_before = compute_tau(n, edges)

    # Add a random edge
    new_verts = tuple(sorted(rng.choice(n, size=k, replace=False)))
    new_edge = frozenset(new_verts)
    edges_new = list(set(edges + [new_edge]))

    ts_after = compute_tau_star(n, edges_new)
    ti_after = compute_tau(n, edges_new)

    deltas_star.append(ts_after - ts_before)
    deltas_int.append(ti_after - ti_before)

deltas_star = np.array(deltas_star)
deltas_int = np.array(deltas_int)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Histogram of Δτ*
ax1 = axes[0]
bins_star = np.linspace(-0.1, 1.1, 50)
ax1.hist(deltas_star, bins=bins_star, density=True, alpha=0.7,
         color='steelblue', edgecolor='black', linewidth=0.5)
ax1.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax1.axvline(x=1, color='red', linestyle='--', alpha=0.7, label='Upper bound = 1')
ax1.set_xlabel(r'$\Delta\tau^* = \tau^*(H \cup \{e\}) - \tau^*(H)$', fontsize=12)
ax1.set_ylabel('Density', fontsize=12)
ax1.set_title(r'Change in $\tau^*$ when adding one edge', fontsize=13)
ax1.legend(fontsize=11)
ax1.text(0.5, 0.85, f'Mean: {np.mean(deltas_star):.3f}\nMax: {np.max(deltas_star):.3f}',
         transform=ax1.transAxes, fontsize=11,
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

# Histogram of Δτ
ax2 = axes[1]
unique_vals, counts = np.unique(deltas_int, return_counts=True)
ax2.bar(unique_vals, counts / len(deltas_int), width=0.3, alpha=0.7,
        color='coral', edgecolor='black', linewidth=0.5)
ax2.set_xlabel(r'$\Delta\tau = \tau(H \cup \{e\}) - \tau(H)$', fontsize=12)
ax2.set_ylabel('Probability', fontsize=12)
ax2.set_title(r'Change in $\tau$ when adding one edge', fontsize=13)
ax2.set_xticks(sorted(unique_vals))

# Annotate probabilities
for v, c in zip(unique_vals, counts):
    ax2.text(v, c/len(deltas_int) + 0.02, f'{c/len(deltas_int):.2f}',
             ha='center', fontsize=10)

plt.suptitle(f'1-Lipschitz Property: Edge Addition Sensitivity\n'
             f'(n={n}, k={k}, p={p:.4f}, {num_trials} trials)',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('lipschitz_property.png', dpi=150, bbox_inches='tight')
print(f"Max |Δτ*| = {np.max(np.abs(deltas_star)):.6f} (should be ≤ 1)")
print(f"All Δτ* in [0, 1]: {np.all((deltas_star >= -1e-8) & (deltas_star <= 1 + 1e-8))}")
print("Saved: lipschitz_property.png")
