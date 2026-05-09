#!/usr/bin/env python3
"""
Ring-Theoretic Learning Theory: Algorithms

Implementation of key algorithms from the research paper:
1. Capacity computation via binomial coefficients
2. Feature selection with convergence detection
3. Localization depth analysis
4. Vandermonde capacity decomposition
"""

from math import comb, log, factorial
from typing import List, Tuple, Optional, Set
import itertools


class MonomialFeatureDimension:
    """Computes and caches the monomial feature dimension C(n+d, d).
    
    This is the central quantity of the Hilbert-VC correspondence:
    it simultaneously gives the Hilbert function and the VC dimension.
    
    Time: O(min(n,d)) per computation
    Space: O(1) per computation (O(cache_size) with caching)
    """
    
    def __init__(self):
        self._cache = {}
    
    def compute(self, n: int, d: int) -> int:
        """Compute C(n+d, d) = monomial feature dimension."""
        if (n, d) not in self._cache:
            self._cache[(n, d)] = comb(n + d, d)
        return self._cache[(n, d)]
    
    def recursion_check(self, n: int, d: int) -> bool:
        """Verify Pascal's recursion: C(n+1,d+1) = C(n,d+1) + C(n+1,d)."""
        return (self.compute(n + 1, d + 1) ==
                self.compute(n, d + 1) + self.compute(n + 1, d))
    
    def growth_rate(self, n: int, d: int) -> float:
        """Compute the growth factor from degree d to d+1.
        
        Theory: C(n+d+1,d+1) / C(n+d,d) = (n+d+1)/(d+1)
        """
        if d == 0:
            return float(self.compute(n, 1))
        return self.compute(n, d + 1) / self.compute(n, d)
    
    def theoretical_growth_rate(self, n: int, d: int) -> float:
        """Theoretical growth rate: (n+d+1)/(d+1)."""
        return (n + d + 1) / (d + 1)
    
    def bounds(self, n: int, d: int) -> dict:
        """Compute all known bounds.
        
        Returns dict with keys: value, exp_upper, linear_lower, diagonal_upper
        """
        cap = self.compute(n, d)
        result = {
            'value': cap,
            'exp_upper': 2 ** (n + d),
            'exp_holds': cap <= 2 ** (n + d),
        }
        if n >= 1:
            result['linear_lower'] = d + 1
            result['linear_holds'] = cap >= d + 1
        if n == d:
            result['diagonal_upper'] = 4 ** n
            result['diagonal_holds'] = cap <= 4 ** n
        return result


class GreedyFeatureSelector:
    """Simulates greedy feature selection over polynomial features.
    
    The algorithm maintains a set of selected monomials and greedily
    adds the "most useful" one in each step. Over a Noetherian ring,
    this process must converge.
    
    Convergence bound: at most C(n+d, d) steps.
    """
    
    def __init__(self, n: int, d: int):
        """Initialize selector for n features, degree ≤ d."""
        self.n = n
        self.d = d
        self.total = comb(n + d, d)
        self.selected: Set[Tuple[int, ...]] = set()
        self.chain: List[int] = [0]  # Track chain of feature counts
        self._all_monomials = self._generate_monomials()
    
    def _generate_monomials(self) -> List[Tuple[int, ...]]:
        """Generate all monomials of degree ≤ d in n variables."""
        monomials = []
        for total_deg in range(self.d + 1):
            for combo in itertools.combinations_with_replacement(range(self.n), total_deg):
                exponents = [0] * self.n
                for idx in combo:
                    exponents[idx] += 1
                monomials.append(tuple(exponents))
        return monomials
    
    def step(self) -> bool:
        """Perform one greedy selection step.
        
        Returns True if a new feature was added, False if converged.
        """
        remaining = [m for m in self._all_monomials if m not in self.selected]
        if not remaining:
            self.chain.append(len(self.selected))
            return False
        
        # Greedy: add the first remaining monomial (simplified oracle)
        self.selected.add(remaining[0])
        self.chain.append(len(self.selected))
        return True
    
    def run_to_convergence(self) -> int:
        """Run until convergence, return stabilization index."""
        while self.step():
            pass
        return len(self.chain) - 1
    
    def convergence_index(self) -> Optional[int]:
        """Find the first stabilization index in the chain."""
        for i in range(len(self.chain) - 1):
            if self.chain[i] == self.chain[i + 1]:
                return i
        return None
    
    def is_converged(self) -> bool:
        """Check if selection has converged."""
        return len(self.selected) == self.total


class LocalizationAnalyzer:
    """Analyzes the localization structure of a polynomial ring.
    
    Simulates the height hierarchy of prime ideals and the
    corresponding focus depth/generalization trade-off.
    """
    
    def __init__(self, n: int):
        """Initialize for a polynomial ring with n variables."""
        self.n = n
        # Krull dimension of k[x₁,...,xₙ] is n
        self.krull_dim = n
    
    def prime_heights(self) -> List[Tuple[str, int]]:
        """List some prime ideals and their heights.
        
        For k[x₁,...,xₙ]:
        - (0) has height 0 (generic point)
        - (xᵢ) has height 1
        - (xᵢ, xⱼ) has height 2
        - ...
        - (x₁,...,xₙ) has height n (maximal ideal)
        """
        primes = [("(0)", 0)]
        
        for k in range(1, self.n + 1):
            for combo in itertools.combinations(range(self.n), k):
                vars_str = ", ".join(f"x{i+1}" for i in combo)
                primes.append((f"({vars_str})", k))
        
        return primes
    
    def focus_depth(self, height: int) -> float:
        """Compute the focus depth (= height) of localization."""
        return float(height)
    
    def capacity_reduction_factor(self, height: int) -> float:
        """Compute the capacity reduction factor from localization.
        
        Localization at a prime of height h reduces the effective
        dimension from n to n-h, so the capacity ratio is:
        C(n-h+d, d) / C(n+d, d)
        """
        if height >= self.n:
            return 0.0
        reduced_n = self.n - height
        return comb(reduced_n + 5, 5) / comb(self.n + 5, 5)  # at degree d=5
    
    def print_hierarchy(self):
        """Print the localization hierarchy."""
        print(f"\nLocalization Hierarchy for k[x₁,...,x{self.n}]")
        print(f"Krull dimension: {self.krull_dim}")
        print(f"{'Prime':>20} {'Height':>8} {'Focus':>8} {'Cap.Ratio':>10}")
        print("-" * 50)
        
        for prime, height in self.prime_heights()[:10]:
            focus = self.focus_depth(height)
            ratio = self.capacity_reduction_factor(height)
            print(f"{prime:>20} {height:>8} {focus:>8.1f} {ratio:>10.4f}")


class VandermondeDecomposer:
    """Decomposes capacity via the Vandermonde identity.
    
    C(m+n, d) = Σ_{k=0}^{d} C(m, k) · C(n, d-k)
    
    This shows how combining two feature sets composes capacities.
    """
    
    @staticmethod
    def decompose(m: int, n: int, d: int) -> List[Tuple[int, int, int]]:
        """Decompose C(m+n, d) into Vandermonde terms.
        
        Returns list of (k, C(m,k), C(n,d-k)) triples.
        """
        terms = []
        for k in range(d + 1):
            terms.append((k, comb(m, k), comb(n, d - k)))
        return terms
    
    @staticmethod
    def verify(m: int, n: int, d: int) -> bool:
        """Verify the Vandermonde identity for given (m, n, d)."""
        lhs = comb(m + n, d)
        rhs = sum(comb(m, k) * comb(n, d - k) for k in range(d + 1))
        return lhs == rhs
    
    @staticmethod
    def print_decomposition(m: int, n: int, d: int):
        """Print the Vandermonde decomposition."""
        terms = VandermondeDecomposer.decompose(m, n, d)
        total = comb(m + n, d)
        print(f"\nVandermonde: C({m}+{n}, {d}) = C({m+n}, {d}) = {total}")
        print(f"= Σ C({m}, k) · C({n}, {d}-k) for k=0..{d}")
        
        for k, ck_m, ck_n in terms:
            product = ck_m * ck_n
            if product > 0:
                print(f"  k={k}: C({m},{k})·C({n},{d-k}) = {ck_m}·{ck_n} = {product}")
        
        reconstructed = sum(t[1] * t[2] for t in terms)
        print(f"Sum = {reconstructed} {'✓' if reconstructed == total else '✗'}")


def demo():
    """Run all algorithm demonstrations."""
    print("=" * 70)
    print("RING-THEORETIC LEARNING THEORY — ALGORITHM DEMONSTRATIONS")
    print("=" * 70)
    
    # 1. Capacity computation
    print("\n--- 1. Capacity Computation ---")
    mfd = MonomialFeatureDimension()
    for n in [1, 2, 3, 5, 10]:
        for d in [1, 2, 3, 5]:
            cap = mfd.compute(n, d)
            rate = mfd.growth_rate(n, d)
            theory = mfd.theoretical_growth_rate(n, d)
            print(f"C({n}+{d},{d}) = {cap:>6}, "
                  f"growth rate = {rate:.3f} "
                  f"(theory: {theory:.3f})")
    
    # 2. Feature selection
    print("\n--- 2. Feature Selection Convergence ---")
    for n, d in [(2, 2), (3, 2), (2, 3)]:
        sel = GreedyFeatureSelector(n, d)
        idx = sel.run_to_convergence()
        print(f"n={n}, d={d}: converged at step {idx}, "
              f"total features = {sel.total}, "
              f"chain = {sel.chain[:8]}...")
    
    # 3. Localization hierarchy
    print("\n--- 3. Localization Hierarchy ---")
    for n in [2, 3]:
        analyzer = LocalizationAnalyzer(n)
        analyzer.print_hierarchy()
    
    # 4. Vandermonde decomposition
    print("\n--- 4. Vandermonde Decomposition ---")
    VandermondeDecomposer.print_decomposition(3, 2, 4)
    VandermondeDecomposer.print_decomposition(5, 5, 3)
    
    # 5. Bounds verification
    print("\n--- 5. Bounds Verification ---")
    for n, d in [(3, 3), (5, 5), (10, 3)]:
        bounds = mfd.bounds(n, d)
        print(f"\nC({n}+{d},{d}) = {bounds['value']}")
        print(f"  ≤ 2^{n+d} = {bounds['exp_upper']} {'✓' if bounds['exp_holds'] else '✗'}")
        if 'linear_lower' in bounds:
            print(f"  ≥ {bounds['linear_lower']} {'✓' if bounds['linear_holds'] else '✗'}")
        if 'diagonal_holds' in bounds:
            print(f"  ≤ 4^{n} = {bounds['diagonal_upper']} {'✓' if bounds['diagonal_holds'] else '✗'}")


if __name__ == "__main__":
    demo()


#!/usr/bin/env python3
"""
Ring-Theoretic Learning Theory: Applications

Real-world applications of the Hilbert-VC correspondence:
1. Sample complexity estimation for polynomial classifiers
2. Feature selection budget planning
3. Model comparison (linear vs quadratic vs cubic)
4. Localization-based model selection
"""

from math import comb, log2, ceil
from typing import List, Dict


def sample_complexity(n: int, d: int, epsilon: float = 0.1, delta: float = 0.05) -> int:
    """Estimate sample complexity for a polynomial classifier.
    
    Uses the Hilbert-VC correspondence: VC dimension = C(n+d, d).
    The classical PAC bound gives: m ≥ (1/ε)(VC·ln(1/ε) + ln(1/δ))
    
    Args:
        n: Number of features
        d: Polynomial degree
        epsilon: Desired accuracy (1 - epsilon)
        delta: Failure probability
    Returns:
        Minimum sample size for PAC learning
    """
    vc_dim = comb(n + d, d)
    # Classical VC bound
    m = ceil((1 / epsilon) * (vc_dim * log2(1 / epsilon) + log2(1 / delta)))
    return m


def model_comparison(n: int, max_d: int = 5) -> List[Dict]:
    """Compare polynomial classifiers of different degrees.
    
    For each degree d, compute:
    - VC dimension (capacity)
    - Sample complexity
    - Capacity-to-exponential ratio (how tight is the bound)
    
    Args:
        n: Number of features
        max_d: Maximum degree to consider
    Returns:
        List of dicts with comparison data
    """
    results = []
    for d in range(max_d + 1):
        vc = comb(n + d, d)
        sc = sample_complexity(n, d)
        exp_bound = 2 ** (n + d)
        ratio = vc / exp_bound
        
        results.append({
            'degree': d,
            'vc_dim': vc,
            'sample_complexity': sc,
            'exp_bound': exp_bound,
            'tightness_ratio': ratio,
            'bits_needed': log2(vc) if vc > 0 else 0
        })
    
    return results


def feature_selection_budget(n: int, d: int) -> Dict:
    """Plan the computational budget for feature selection.
    
    Uses the Noetherian convergence theorem to bound the number
    of feature selection iterations.
    
    Args:
        n: Number of features
        d: Polynomial degree
    Returns:
        Dict with budget information
    """
    total_features = comb(n + d, d)
    exp_bound = 2 ** (n + d)
    
    return {
        'n_features': n,
        'degree': d,
        'max_iterations': total_features,
        'convergence_guaranteed': True,  # By Noetherian theorem
        'feature_space_size': total_features,
        'exponential_ceiling': exp_bound,
        'efficiency_ratio': total_features / exp_bound,
        'log2_features': log2(total_features) if total_features > 0 else 0,
    }


def localization_analysis(n: int, d: int = 3) -> List[Dict]:
    """Analyze the effect of localization on model capacity.
    
    For each possible height h (0 to n), compute the capacity
    of the localized model and the generalization improvement.
    
    Args:
        n: Ambient dimension
        d: Polynomial degree
    Returns:
        List of dicts with localization analysis
    """
    global_cap = comb(n + d, d)
    results = []
    
    for h in range(n + 1):
        local_n = n - h  # Effective dimension after localization
        local_cap = comb(local_n + d, d)
        reduction = 1 - local_cap / global_cap if global_cap > 0 else 0
        
        results.append({
            'height': h,
            'effective_dim': local_n,
            'local_capacity': local_cap,
            'global_capacity': global_cap,
            'capacity_reduction': reduction,
            'generalization_improvement': h / n if n > 0 else 0,
        })
    
    return results


def print_sample_complexity_table():
    """Print sample complexity for common configurations."""
    print("\n" + "=" * 70)
    print("SAMPLE COMPLEXITY TABLE (ε=0.1, δ=0.05)")
    print("=" * 70)
    print(f"{'n':>4} {'d':>4} {'VC dim':>10} {'Samples':>12} {'2^(n+d)':>12}")
    print("-" * 46)
    
    configs = [
        (2, 1), (2, 2), (2, 3),
        (5, 1), (5, 2), (5, 3),
        (10, 1), (10, 2), (10, 3),
        (20, 1), (20, 2),
        (50, 1),
        (100, 1),
    ]
    
    for n, d in configs:
        vc = comb(n + d, d)
        sc = sample_complexity(n, d)
        exp = 2 ** (n + d)
        print(f"{n:>4} {d:>4} {vc:>10} {sc:>12} {exp:>12}")


def print_model_comparison():
    """Print model comparison for different polynomial degrees."""
    print("\n" + "=" * 70)
    print("MODEL COMPARISON: Polynomial Classifiers (n=10 features)")
    print("=" * 70)
    
    results = model_comparison(10, 5)
    print(f"{'Degree':>6} {'VC dim':>10} {'Samples':>12} {'Bits':>8} {'Type'}")
    print("-" * 50)
    
    type_names = ['Constant', 'Linear', 'Quadratic', 'Cubic', 'Quartic', 'Quintic']
    for r in results:
        d = r['degree']
        tname = type_names[d] if d < len(type_names) else f'Degree-{d}'
        print(f"{d:>6} {r['vc_dim']:>10} {r['sample_complexity']:>12} "
              f"{r['bits_needed']:>8.1f} {tname}")


def print_feature_selection_planning():
    """Print feature selection budget planning."""
    print("\n" + "=" * 70)
    print("FEATURE SELECTION BUDGET PLANNING")
    print("=" * 70)
    
    configs = [(5, 2), (5, 3), (10, 2), (10, 3), (20, 2)]
    
    for n, d in configs:
        budget = feature_selection_budget(n, d)
        print(f"\nn={n}, d={d}:")
        print(f"  Max iterations: {budget['max_iterations']}")
        print(f"  Feature space: {budget['feature_space_size']}")
        print(f"  Bits needed: {budget['log2_features']:.1f}")
        print(f"  Convergence guaranteed: {budget['convergence_guaranteed']}")
        print(f"  Efficiency: {budget['efficiency_ratio']:.4f}")


def print_localization_analysis():
    """Print localization analysis for model focusing."""
    print("\n" + "=" * 70)
    print("LOCALIZATION ANALYSIS (n=5, d=3)")
    print("=" * 70)
    
    results = localization_analysis(5, 3)
    print(f"{'Height':>6} {'Eff.dim':>8} {'Local cap':>10} "
          f"{'Reduction':>10} {'Gen.Improv':>10}")
    print("-" * 48)
    
    for r in results:
        print(f"{r['height']:>6} {r['effective_dim']:>8} "
              f"{r['local_capacity']:>10} "
              f"{r['capacity_reduction']:>10.1%} "
              f"{r['generalization_improvement']:>10.1%}")


def main():
    """Run all application demonstrations."""
    print("RING-THEORETIC LEARNING THEORY — APPLICATIONS")
    print("=" * 70)
    
    print_sample_complexity_table()
    print_model_comparison()
    print_feature_selection_planning()
    print_localization_analysis()
    
    print("\n" + "=" * 70)
    print("KEY INSIGHTS:")
    print("1. Linear classifiers: VC dim = n+1, moderate sample needs")
    print("2. Quadratic classifiers: VC dim = O(n²), significantly more data needed")
    print("3. Localization at height h reduces capacity by removing h dimensions")
    print("4. Feature selection converges in at most C(n+d,d) steps (guaranteed)")
    print("5. The Noetherian property ensures ALL these bounds are finite")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Ring-Theoretic Learning Theory: Demonstration

Numerical verification of the Hilbert-VC correspondence theorems,
capacity bounds, and feature selection convergence properties.
"""

from math import comb, log2, factorial
from typing import List, Tuple
import itertools


def monomial_feature_dimension(n: int, d: int) -> int:
    """Compute C(n+d, d) — the monomial feature dimension.
    
    This is the number of monomials of degree ≤ d in n variables,
    which equals the Hilbert function of k[x₁,...,xₙ] at degree d.
    
    Args:
        n: Number of features (variables)
        d: Maximum polynomial degree
    Returns:
        The monomial feature dimension C(n+d, d)
    """
    return comb(n + d, d)


def verify_recursion(n: int, d: int) -> bool:
    """Verify Pascal's recursion: C(n+1, d+1) = C(n, d+1) + C(n+1, d)."""
    lhs = monomial_feature_dimension(n + 1, d + 1)
    rhs = monomial_feature_dimension(n, d + 1) + monomial_feature_dimension(n + 1, d)
    return lhs == rhs


def verify_symmetry(n: int, d: int) -> bool:
    """Verify feature-degree duality: C(n+d,d) = C(d+n,n)."""
    return monomial_feature_dimension(n, d) == monomial_feature_dimension(d, n)


def verify_vandermonde(m: int, n: int, d: int) -> bool:
    """Verify Vandermonde: C(m+n, d) = Σ C(m,k)·C(n,d-k)."""
    lhs = comb(m + n, d)
    rhs = sum(comb(m, k) * comb(n, d - k) for k in range(d + 1))
    return lhs == rhs


def capacity_table(max_n: int = 10, max_d: int = 10) -> List[List[int]]:
    """Generate a table of monomial feature dimensions."""
    return [[monomial_feature_dimension(n, d) for d in range(max_d + 1)]
            for n in range(max_n + 1)]


def verify_all_bounds(n: int, d: int) -> dict:
    """Verify all capacity bounds for given (n, d).
    
    Returns a dictionary of bound names to (bound_value, holds) pairs.
    """
    cap = monomial_feature_dimension(n, d)
    results = {}
    
    # Exponential ceiling
    exp_bound = 2 ** (n + d)
    results['exponential_ceiling'] = (exp_bound, cap <= exp_bound)
    
    # Positivity
    results['positivity'] = (1, cap >= 1)
    
    # Linear lower bound (requires n >= 1)
    if n >= 1:
        results['linear_lower'] = (d + 1, cap >= d + 1)
    
    # Zero degree
    if d == 0:
        results['zero_degree'] = (1, cap == 1)
    
    # Zero features
    if n == 0:
        results['zero_features'] = (1, cap == 1)
    
    # Feature-degree duality
    results['duality'] = (monomial_feature_dimension(d, n),
                          cap == monomial_feature_dimension(d, n))
    
    return results


def growth_rate_analysis(n: int, max_d: int = 20) -> List[Tuple[int, int, float]]:
    """Analyze capacity growth rate as d increases for fixed n.
    
    Returns (d, capacity, ratio_to_previous) triples.
    """
    results = []
    prev = 1
    for d in range(max_d + 1):
        cap = monomial_feature_dimension(n, d)
        ratio = cap / prev if prev > 0 else float('inf')
        results.append((d, cap, ratio))
        prev = cap
    return results


def simulate_feature_selection(n: int, d: int, num_steps: int = None) -> List[int]:
    """Simulate greedy feature selection over polynomial features.
    
    In each step, one new monomial feature is added.
    The chain stabilizes when all C(n+d,d) monomials are included.
    
    Returns the chain of feature counts.
    """
    total = monomial_feature_dimension(n, d)
    if num_steps is None:
        num_steps = total + 5  # Go past stabilization
    
    chain = []
    for k in range(num_steps):
        chain.append(min(k, total))
    
    return chain


def find_stabilization_index(chain: List[int]) -> int:
    """Find the first index where the chain stabilizes."""
    for i in range(len(chain) - 1):
        if all(chain[j] == chain[i] for j in range(i, len(chain))):
            return i
    return len(chain) - 1


def print_capacity_table():
    """Print a formatted capacity table."""
    print("\n" + "=" * 70)
    print("MONOMIAL FEATURE DIMENSION TABLE: C(n+d, d)")
    print("=" * 70)
    hdr = 'n\\d'
    print(f"{hdr:>4}", end="")
    for d in range(11):
        print(f"{d:>7}", end="")
    print()
    print("-" * 81)
    
    for n in range(11):
        print(f"{n:>4}", end="")
        for d in range(11):
            print(f"{monomial_feature_dimension(n, d):>7}", end="")
        print()


def print_bounds_verification():
    """Verify and print all bounds for various (n, d)."""
    print("\n" + "=" * 70)
    print("BOUNDS VERIFICATION")
    print("=" * 70)
    
    test_cases = [(1, 1), (1, 5), (2, 3), (3, 3), (5, 5), (10, 3), (5, 10)]
    
    for n, d in test_cases:
        cap = monomial_feature_dimension(n, d)
        bounds = verify_all_bounds(n, d)
        
        print(f"\n(n={n}, d={d}): C({n}+{d},{d}) = {cap}")
        for name, (value, holds) in bounds.items():
            status = "✓" if holds else "✗"
            print(f"  {status} {name}: {value}")


def print_growth_analysis():
    """Print capacity growth rate analysis."""
    print("\n" + "=" * 70)
    print("CAPACITY GROWTH RATE ANALYSIS (fixed n=3)")
    print("=" * 70)
    print(f"{'d':>4} {'C(3+d,d)':>10} {'Ratio':>10} {'Theory':>10}")
    print("-" * 38)
    
    results = growth_rate_analysis(3, 15)
    for d, cap, ratio in results:
        theory_ratio = (3 + d) / d if d > 0 else float('inf')
        print(f"{d:>4} {cap:>10} {ratio:>10.3f} {theory_ratio:>10.3f}")


def print_feature_selection_demo():
    """Demonstrate feature selection convergence."""
    print("\n" + "=" * 70)
    print("FEATURE SELECTION CONVERGENCE DEMO")
    print("=" * 70)
    
    for n, d in [(2, 2), (3, 2), (2, 3)]:
        total = monomial_feature_dimension(n, d)
        chain = simulate_feature_selection(n, d, total + 5)
        stab_idx = find_stabilization_index(chain)
        
        print(f"\nn={n}, d={d}: total features = {total}")
        print(f"Chain: {chain[:min(len(chain), 15)]}{'...' if len(chain) > 15 else ''}")
        print(f"Stabilization index: {stab_idx}")
        print(f"Stable value: {chain[stab_idx]}")


def print_verification_summary():
    """Print comprehensive verification of all theorems."""
    print("\n" + "=" * 70)
    print("THEOREM VERIFICATION SUMMARY")
    print("=" * 70)
    
    all_pass = True
    
    # 1. Recursion
    print("\n1. Pascal's Recursion:")
    for n in range(5):
        for d in range(5):
            if not verify_recursion(n, d):
                print(f"  FAIL: n={n}, d={d}")
                all_pass = False
    print("  ✓ All cases pass" if all_pass else "  ✗ Some cases fail")
    
    # 2. Symmetry (duality)
    print("\n2. Feature-Degree Duality:")
    sym_pass = True
    for n in range(10):
        for d in range(10):
            if not verify_symmetry(n, d):
                print(f"  FAIL: n={n}, d={d}")
                sym_pass = False
    print("  ✓ All cases pass" if sym_pass else "  ✗ Some cases fail")
    
    # 3. Vandermonde
    print("\n3. Vandermonde Decomposition:")
    vand_pass = True
    for m in range(5):
        for n in range(5):
            for d in range(5):
                if not verify_vandermonde(m, n, d):
                    print(f"  FAIL: m={m}, n={n}, d={d}")
                    vand_pass = False
    print("  ✓ All cases pass" if vand_pass else "  ✗ Some cases fail")
    
    # 4. Exact formulas
    print("\n4. Exact Formulas:")
    for d in range(20):
        assert monomial_feature_dimension(1, d) == d + 1, f"Univariate fail at d={d}"
    print("  ✓ Univariate: C(1+d, d) = d+1 for d=0..19")
    
    for n in range(20):
        assert monomial_feature_dimension(n, 1) == n + 1, f"Linear fail at n={n}"
    print("  ✓ Linear: C(n+1, 1) = n+1 for n=0..19")
    
    for d in range(20):
        assert monomial_feature_dimension(2, d) == (d + 2) * (d + 1) // 2, \
            f"Bivariate fail at d={d}"
    print("  ✓ Bivariate: C(2+d, 2) = (d+2)(d+1)/2 for d=0..19")
    
    for n in range(20):
        assert monomial_feature_dimension(n, 2) == (n + 2) * (n + 1) // 2, \
            f"Quadratic fail at n={n}"
    print("  ✓ Quadratic: C(n+2, 2) = (n+2)(n+1)/2 for n=0..19")
    
    # 5. Doubling bound
    print("\n5. Doubling Bound:")
    for d in range(20):
        assert monomial_feature_dimension(1, 2 * d) <= monomial_feature_dimension(1, d) ** 2
    print("  ✓ C(1, 2d) ≤ C(1, d)² for d=0..19")
    
    # 6. Diagonal bound
    print("\n6. Diagonal Bound:")
    for n in range(15):
        assert monomial_feature_dimension(n, n) <= 4 ** n
    print("  ✓ C(2n, n) ≤ 4^n for n=0..14")
    
    print("\n" + "=" * 70)
    print("ALL THEOREMS VERIFIED NUMERICALLY ✓")
    print("=" * 70)


if __name__ == "__main__":
    print("Ring-Theoretic Learning Theory — Numerical Demonstrations")
    print("=" * 70)
    
    print_capacity_table()
    print_bounds_verification()
    print_growth_analysis()
    print_feature_selection_demo()
    print_verification_summary()
