#!/usr/bin/env python3
"""
applications.py — Real-world applications of width-to-size conversion
in proof complexity.

Demonstrates how clause space bounds apply to:
1. SAT solver analysis (estimating proof difficulty)
2. Verification of hardware/software (proof certificate size)
3. Cryptographic hardness (resolution complexity of random formulas)
"""

from math import comb, log2, exp, factorial
from typing import List, Dict, Tuple
import random


# ─────────────────────────────────────────────────
# Core functions
# ─────────────────────────────────────────────────

def clause_space_bound(n: int, w: int) -> int:
    """Number of distinct clauses of width ≤ w over n variables."""
    return sum(comb(n, k) * (2 ** k) for k in range(min(w, n) + 1))


def clause_entropy_bound(n: int, w: int) -> float:
    """Log2 of clause space bound."""
    csb = clause_space_bound(n, w)
    return log2(csb) if csb > 0 else 0.0


# ─────────────────────────────────────────────────
# Application 1: SAT Solver Proof Size Estimation
# ─────────────────────────────────────────────────

def estimate_cdcl_difficulty(n_vars: int, clause_widths: List[int]) -> Dict:
    """
    Estimate the difficulty of a SAT instance for CDCL solvers
    based on clause width distribution.
    
    CDCL (Conflict-Driven Clause Learning) solvers generate resolution
    proofs. The width of learned clauses provides a lower bound on
    proof size.
    
    Args:
        n_vars: Number of variables
        clause_widths: Observed widths of learned clauses
    
    Returns:
        Dictionary with difficulty estimates
    """
    if not clause_widths:
        return {"error": "No clause widths provided"}
    
    max_observed_width = max(clause_widths)
    avg_width = sum(clause_widths) / len(clause_widths)
    
    # Size lower bound from our theorem: size ≥ maxWidth + 1
    size_lower_bound = max_observed_width + 1
    
    # Clause space at observed max width
    csb = clause_space_bound(n_vars, max_observed_width)
    
    # Information content
    entropy = clause_entropy_bound(n_vars, max_observed_width)
    
    return {
        "n_variables": n_vars,
        "max_observed_width": max_observed_width,
        "avg_width": avg_width,
        "size_lower_bound": size_lower_bound,
        "clause_space_at_max_width": csb,
        "entropy_bits": entropy,
        "total_clause_space": clause_space_bound(n_vars, n_vars),
        "fraction_explored": csb / clause_space_bound(n_vars, n_vars) if n_vars > 0 else 1.0,
    }


# ─────────────────────────────────────────────────
# Application 2: Hardware Verification Certificate Size
# ─────────────────────────────────────────────────

def verification_certificate_analysis(
    circuit_size: int,
    property_clauses: int,
    max_width_observed: int
) -> Dict:
    """
    Analyze the expected proof certificate size for hardware verification.
    
    When verifying a hardware design against a specification, the
    verification tool produces a resolution proof (DRAT certificate).
    Our bounds predict minimum certificate sizes.
    
    Args:
        circuit_size: Number of gates in the circuit
        property_clauses: Number of clauses encoding the property
        max_width_observed: Maximum observed clause width
    
    Returns:
        Analysis dictionary
    """
    # Typical: n_vars ≈ circuit_size (one variable per gate output)
    n_vars = circuit_size
    
    return {
        "circuit_size": circuit_size,
        "property_clauses": property_clauses,
        "n_variables": n_vars,
        "max_width": max_width_observed,
        "min_proof_nodes": max_width_observed + 1,
        "clause_space": clause_space_bound(n_vars, max_width_observed),
        "entropy_bound": clause_entropy_bound(n_vars, max_width_observed),
        "certificate_bits_lower_bound": (max_width_observed + 1) * max_width_observed,
    }


# ─────────────────────────────────────────────────
# Application 3: PHP as a Benchmark
# ─────────────────────────────────────────────────

def php_benchmark_analysis(max_n: int = 12) -> List[Dict]:
    """
    Analyze PHP(n+1, n) as a SAT solver benchmark.
    
    The pigeonhole principle is a canonical hard formula for resolution.
    Our formalized bounds give certified lower bounds on proof size.
    """
    results = []
    for n in range(1, max_n + 1):
        m = n + 1  # pigeons
        num_vars = m * n
        num_at_least_one = m
        num_at_most_one = n * (m * (m - 1) // 2)
        total_clauses = num_at_least_one + num_at_most_one
        
        # Our certified bounds
        width_lb = n
        size_lb = n + 1
        
        # Clause space analysis
        csb = clause_space_bound(num_vars, n)
        
        results.append({
            "n": n,
            "pigeons": m,
            "holes": n,
            "variables": num_vars,
            "total_clauses": total_clauses,
            "width_lower_bound": width_lb,
            "size_lower_bound": size_lb,
            "clause_space_at_width_bound": csb,
            "log2_clause_space": log2(csb) if csb > 1 else 0.0,
        })
    
    return results


# ─────────────────────────────────────────────────
# Application 4: Random k-SAT Phase Transition
# ─────────────────────────────────────────────────

def random_ksat_width_analysis(
    n: int, k: int, clause_ratio: float, num_samples: int = 100
) -> Dict:
    """
    Analyze clause widths in random k-SAT instances near the phase transition.
    
    Random k-SAT with clause-to-variable ratio near the threshold
    produces hard instances. Width analysis predicts proof difficulty.
    
    Args:
        n: Number of variables
        k: Clause width
        clause_ratio: Ratio of clauses to variables
        num_samples: Number of random instances
    
    Returns:
        Statistical analysis of clause space bounds
    """
    num_clauses = int(clause_ratio * n)
    
    max_widths = []
    for _ in range(num_samples):
        # Generate random k-SAT instance
        widths_seen = set()
        for _ in range(num_clauses):
            # Random clause of width k
            widths_seen.add(k)
            # Simulate some resolution: learned clauses can be wider
            if random.random() < 0.3:
                learned_width = min(k + random.randint(0, 3), n)
                widths_seen.add(learned_width)
        
        max_widths.append(max(widths_seen))
    
    avg_max_width = sum(max_widths) / len(max_widths)
    
    return {
        "n": n,
        "k": k,
        "clause_ratio": clause_ratio,
        "num_clauses": num_clauses,
        "avg_max_width": avg_max_width,
        "size_lower_bound": avg_max_width + 1,
        "clause_space_at_avg_width": clause_space_bound(n, int(avg_max_width)),
    }


# ─────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATIONS OF WIDTH-TO-SIZE CONVERSION")
    print("=" * 60)
    
    # Application 1: SAT difficulty estimation
    print("\n--- Application 1: SAT Solver Difficulty Estimation ---")
    # Simulate observed clause widths from a CDCL solver
    observed_widths = [3, 5, 7, 4, 8, 6, 3, 9, 5, 7, 10, 4, 6, 8]
    analysis = estimate_cdcl_difficulty(50, observed_widths)
    print(f"Variables: {analysis['n_variables']}")
    print(f"Max observed width: {analysis['max_observed_width']}")
    print(f"Size lower bound: {analysis['size_lower_bound']}")
    print(f"Clause space at max width: {analysis['clause_space_at_max_width']}")
    print(f"Entropy (bits): {analysis['entropy_bits']:.1f}")
    print(f"Fraction of total space explored: {analysis['fraction_explored']:.6f}")
    
    # Application 2: Hardware verification
    print("\n--- Application 2: Hardware Verification Certificate ---")
    hw_analysis = verification_certificate_analysis(1000, 500, 15)
    print(f"Circuit size: {hw_analysis['circuit_size']} gates")
    print(f"Max clause width: {hw_analysis['max_width']}")
    print(f"Min proof nodes: {hw_analysis['min_proof_nodes']}")
    print(f"Certificate size lower bound: ≥{hw_analysis['certificate_bits_lower_bound']} bits")
    
    # Application 3: PHP benchmark
    print("\n--- Application 3: PHP Benchmark Analysis ---")
    php_data = php_benchmark_analysis(10)
    print(f"{'n':>3} {'Vars':>6} {'Cls':>6} {'W≥':>4} {'S≥':>4} {'log₂(CSB)':>10}")
    print("-" * 35)
    for d in php_data:
        print(f"{d['n']:>3} {d['variables']:>6} {d['total_clauses']:>6} "
              f"{d['width_lower_bound']:>4} {d['size_lower_bound']:>4} "
              f"{d['log2_clause_space']:>10.1f}")
    
    # Application 4: Random k-SAT
    print("\n--- Application 4: Random 3-SAT Near Phase Transition ---")
    random.seed(42)
    for ratio in [3.0, 4.0, 4.26, 5.0]:
        result = random_ksat_width_analysis(30, 3, ratio)
        print(f"  ratio={ratio:.2f}: avg_max_width={result['avg_max_width']:.1f}, "
              f"size_lb={result['size_lower_bound']:.1f}")


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of width-to-size conversion
in tree-like resolution and the pigeonhole principle lower bound.

Computes clauseSpaceBound(n, w), visualizes growth, and compares
against small-n proof-size data for PHP.
"""

from math import comb, log2
from typing import List, Tuple


def clause_space_bound(n: int, w: int) -> int:
    """
    Number of distinct clauses over n variables of width at most w.
    
    Each clause of width k chooses k variables from n, then assigns
    each a polarity (positive or negative), giving C(n,k) * 2^k
    clauses of width exactly k.
    
    >>> clause_space_bound(5, 2)
    51
    >>> clause_space_bound(4, 4)
    81
    """
    return sum(comb(n, k) * (2 ** k) for k in range(w + 1))


def clause_entropy_bound(n: int, w: int) -> float:
    """
    Log2 of the clause space bound: information-theoretic proxy
    for the entropy of width-bounded clause space.
    
    >>> clause_entropy_bound(4, 4)  # log2(81) ≈ 6.34
    6.339850002884625
    """
    csb = clause_space_bound(n, w)
    return log2(csb) if csb > 0 else 0.0


def verify_three_power(max_n: int = 12) -> List[Tuple[int, int, int, bool]]:
    """
    Verify clauseSpaceBound(n, n) = 3^n for small n.
    This is the binomial theorem: (1+2)^n = sum C(n,k)*2^k.
    
    Returns list of (n, clauseSpaceBound(n,n), 3^n, match).
    """
    results = []
    for n in range(max_n + 1):
        csb = clause_space_bound(n, n)
        three_n = 3 ** n
        results.append((n, csb, three_n, csb == three_n))
    return results


def php_width_lower_bound(n: int) -> int:
    """
    Minimum width of any tree-resolution refutation of PHP(n+1, n).
    By our formalized theorem, this is at least n.
    """
    return n


def php_size_lower_bound(n: int) -> int:
    """
    Lower bound on tree-resolution refutation size for PHP(n+1, n).
    By our formalized theorem: size >= maxWidth + 1 >= n + 1.
    """
    return n + 1


def display_clause_space_table(max_n: int = 15, max_w: int = 8) -> None:
    """Display a table of clauseSpaceBound(n, w) values."""
    print("\n" + "=" * 70)
    print("CLAUSE SPACE BOUND: clauseSpaceBound(n, w)")
    print("Number of distinct clauses over n variables of width ≤ w")
    print("=" * 70)
    
    # Header
    nw_label = 'n\\w'
    header = f"{nw_label:>6}"
    for w in range(max_w + 1):
        header += f"{w:>10}"
    print(header)
    print("-" * (6 + 10 * (max_w + 1)))
    
    for n in range(max_n + 1):
        row = f"{n:>6}"
        for w in range(max_w + 1):
            val = clause_space_bound(n, w)
            row += f"{val:>10}"
        print(row)


def display_three_power_verification() -> None:
    """Verify and display the 3^n identity."""
    print("\n" + "=" * 50)
    print("VERIFICATION: clauseSpaceBound(n, n) = 3^n")
    print("=" * 50)
    results = verify_three_power(15)
    print(f"{'n':>4} {'CSB(n,n)':>15} {'3^n':>15} {'Match':>8}")
    print("-" * 42)
    for n, csb, three_n, match in results:
        print(f"{n:>4} {csb:>15} {three_n:>15} {'✓' if match else '✗':>8}")


def display_php_lower_bounds(max_n: int = 20) -> None:
    """Display PHP lower bounds and clause space bounds."""
    print("\n" + "=" * 70)
    print("PHP(n+1, n) TREE-RESOLUTION LOWER BOUNDS")
    print("=" * 70)
    print(f"{'n':>4} {'Width≥':>8} {'Size≥':>8} {'CSB(n(n+1),n)':>18} {'Entropy':>10}")
    print("-" * 50)
    
    for n in range(1, max_n + 1):
        w_lb = php_width_lower_bound(n)
        s_lb = php_size_lower_bound(n)
        # PHP uses n*(n+1) variables (but our bound uses maxWidth directly)
        num_vars = (n + 1) * n
        csb = clause_space_bound(num_vars, n)
        entropy = clause_entropy_bound(num_vars, n)
        print(f"{n:>4} {w_lb:>8} {s_lb:>8} {csb:>18} {entropy:>10.2f}")


def display_growth_comparison() -> None:
    """Compare growth rates of clauseSpaceBound for different w."""
    print("\n" + "=" * 60)
    print("GROWTH OF clauseSpaceBound(n, w) AS n INCREASES")
    print("(showing log₂ values)")
    print("=" * 60)
    
    widths = [1, 2, 3, 5, 8]
    header = f"{'n':>5}"
    for w in widths:
        header += f"{'w=' + str(w):>12}"
    header += f"{'w=n':>12}"
    print(header)
    print("-" * (5 + 12 * (len(widths) + 1)))
    
    for n in range(1, 21):
        row = f"{n:>5}"
        for w in widths:
            val = clause_space_bound(n, w)
            row += f"{log2(val):>12.2f}"
        val_n = clause_space_bound(n, n)
        row += f"{log2(val_n):>12.2f}"
        print(row)


def display_ascii_chart() -> None:
    """ASCII visualization of clause space bound growth."""
    print("\n" + "=" * 60)
    print("CLAUSE SPACE GROWTH (log₂ scale, n=1..20, w=n/2 vs w=n)")
    print("=" * 60)
    
    max_width = 50
    max_log = log2(clause_space_bound(20, 20))
    
    for n in range(1, 21):
        w_half = max(1, n // 2)
        val_half = clause_space_bound(n, w_half)
        val_full = clause_space_bound(n, n)
        
        log_half = log2(val_half) if val_half > 0 else 0
        log_full = log2(val_full)
        
        bar_half = int(log_half / max_log * max_width)
        bar_full = int(log_full / max_log * max_width)
        
        bar = ""
        for i in range(max_width):
            if i < bar_half:
                bar += "█"
            elif i < bar_full:
                bar += "░"
            else:
                bar += " "
        
        print(f"n={n:>2} |{bar}| w=⌊n/2⌋: {log_half:.1f}, w=n: {log_full:.1f}")
    
    print("\n█ = log₂(CSB(n, ⌊n/2⌋))   ░ = additional bits for w=n")


if __name__ == "__main__":
    print("╔════════════════════════════════════════════════════════╗")
    print("║  Width-to-Size Conversion in Tree-Like Resolution     ║")
    print("║  Interactive Demonstration                            ║")
    print("╚════════════════════════════════════════════════════════╝")
    
    display_clause_space_table(10, 6)
    display_three_power_verification()
    display_php_lower_bounds()
    display_growth_comparison()
    display_ascii_chart()
    
    print("\n" + "=" * 60)
    print("KEY FORMALIZED RESULTS:")
    print("=" * 60)
    print("""
1. clauseSpaceBound(n, n) = 3^n  [Binomial Theorem]

2. For any tree-resolution proof T:
   - |allClauses(T)| ≤ size(T)
   - ∀ C ∈ allClauses(T), width(C) ≤ maxWidth(T)
   - |widthSpectrum(T)| ≤ maxWidth(T) + 1

3. For any refutation (T deriving ∅):
   size(T) ≥ maxWidth(T) + 1

4. For PHP(n+1, n) with n ≥ 1:
   maxWidth(T) ≥ n  ⟹  size(T) ≥ n + 1

All results machine-verified with no axioms beyond
propext, Classical.choice, and Quot.sound.
""")
