#!/usr/bin/env python3
"""
Applications of Arrow-Depth Complexity Theory.

Demonstrates practical applications of the structural complexity analysis
of simple types to program analysis, compiler optimization, and semantic
model reduction.
"""

import math
from typing import List, Tuple, Dict, Optional


# ---------- Type definitions (self-contained) ----------

class Ty:
    pass

class Base(Ty):
    def __repr__(self): return "o"

class Arrow(Ty):
    def __init__(self, domain, codomain):
        self.domain = domain
        self.codomain = codomain
    def __repr__(self):
        d = repr(self.domain)
        c = repr(self.codomain)
        if isinstance(self.domain, Arrow): d = f"({d})"
        return f"{d} → {c}"


def depth(ty): return 0 if isinstance(ty, Base) else 1 + max(depth(ty.domain), depth(ty.codomain))
def size(ty): return 1 if isinstance(ty, Base) else 1 + size(ty.domain) + size(ty.codomain)
def tsb(ty): return 1 if isinstance(ty, Base) else (tsb(ty.domain)+1)*(tsb(ty.codomain)+1)
def aw(ty): return 0 if isinstance(ty, Base) else 1 + aw(ty.domain) + aw(ty.codomain)
def is_chain(ty): return True if isinstance(ty, Base) else isinstance(ty.domain, Base) and is_chain(ty.codomain)


# ---------- Application 1: Compiler State Budget Estimation ----------

def estimate_state_budget(ty: Ty) -> Dict[str, any]:
    """Estimate the state budget needed for semantic analysis of a typed program.

    In compiler optimization, knowing the state space size determines which
    analysis techniques are feasible:
    - < 1000 states: exhaustive enumeration
    - 1000-10^6: BDD-based symbolic analysis
    - 10^6-10^9: abstract interpretation needed
    - > 10^9: must use approximation/sampling

    This function uses the verified bounds to predict the analysis budget
    without computing the exact state space.

    >>> result = estimate_state_budget(Arrow(Base(), Arrow(Base(), Base())))
    >>> result['technique']
    'exhaustive'
    """
    d = depth(ty)
    s = size(ty)
    exact = tsb(ty)
    upper = 2**s - 1
    chain_bound = 3**(d+1) if is_chain(ty) else None

    if exact < 1000:
        technique = "exhaustive"
    elif exact < 10**6:
        technique = "symbolic (BDD)"
    elif exact < 10**9:
        technique = "abstract interpretation"
    else:
        technique = "approximation/sampling"

    return {
        "type": repr(ty),
        "exact_states": exact,
        "upper_bound": upper,
        "chain_bound": chain_bound,
        "depth": d,
        "size": s,
        "arrow_width": aw(ty),
        "is_chain": is_chain(ty),
        "technique": technique,
        "log2_states": math.log2(exact) if exact > 0 else 0,
    }


# ---------- Application 2: Type Simplification Advisor ----------

def suggest_simplification(ty: Ty) -> str:
    """Suggest type simplification strategies based on structural analysis.

    If a type has high arrow width relative to depth, it's "bushy" and
    may benefit from defunctionalization or type-directed partial evaluation.
    If it's chain-like, standard CPS transformation suffices.

    >>> suggest_simplification(Arrow(Base(), Arrow(Base(), Base())))
    'Chain type: CPS transformation preserves complexity class.'
    """
    d = depth(ty)
    w = aw(ty)
    s = size(ty)

    if isinstance(ty, Base):
        return "Base type: no simplification needed."

    if is_chain(ty):
        return "Chain type: CPS transformation preserves complexity class."

    # Check bushy-ness: w close to 2^d - 1
    max_width = 2**d - 1
    bushiness = w / max_width if max_width > 0 else 0

    if bushiness > 0.8:
        return (f"Highly bushy (width={w}, max={max_width}): "
                f"defunctionalize to reduce state explosion. "
                f"Expected reduction: from 2^({s}) to polynomial in domain size.")
    elif bushiness > 0.4:
        return (f"Moderately bushy (width={w}): "
                f"partial defunctionalization recommended. "
                f"Target chain-like substructure for CPS.")
    else:
        return (f"Near-chain (width={w}): "
                f"lightweight CPS sufficient. "
                f"State complexity ~ 3^{d+1} = {3**(d+1)}.")


# ---------- Application 3: Fixed-Parameter Tractability Analysis ----------

def fpt_analysis(types: List[Ty]) -> Dict[str, any]:
    """Analyze a collection of types for fixed-parameter tractability.

    Determines whether bisimulation minimization is tractable
    when parameterized by (depth, width).

    The key insight: if depth and width are bounded, then typeStateBound
    is bounded by a computable function of the parameters alone,
    making minimization FPT.

    >>> types = [Arrow(Base(), Base()), Arrow(Base(), Arrow(Base(), Base()))]
    >>> result = fpt_analysis(types)
    >>> result['max_depth']
    2
    """
    if not types:
        return {"error": "empty type list"}

    analyses = [estimate_state_budget(ty) for ty in types]
    max_d = max(a["depth"] for a in analyses)
    max_w = max(a["arrow_width"] for a in analyses)
    max_s = max(a["size"] for a in analyses)
    max_tsb = max(a["exact_states"] for a in analyses)

    # FPT bound: f(d,w) * n^O(1)
    # where f(d,w) = 2^(2^(d+1)-1) (worst case) or 3^(d+1) if all chain-like
    all_chain = all(a["is_chain"] for a in analyses)

    if all_chain:
        param_bound = 3**(max_d + 1)
        regime = "chain"
    else:
        param_bound = 2**(2**(max_d + 1) - 1)
        regime = "general"

    return {
        "num_types": len(types),
        "max_depth": max_d,
        "max_width": max_w,
        "max_size": max_s,
        "max_tsb": max_tsb,
        "all_chain": all_chain,
        "regime": regime,
        "parameter_bound": param_bound,
        "fpt_feasible": param_bound < 10**9,
    }


# ---------- Application 4: Semantic Compression Ratio ----------

def compression_analysis(ty: Ty) -> Dict[str, any]:
    """Analyze the semantic compression achievable through bisimulation quotient.

    Compares the naive state space (exponential in term size) against
    the type-bounded quotient size.

    >>> result = compression_analysis(Arrow(Base(), Arrow(Base(), Base())))
    >>> result['compression_ratio'] > 1
    True
    """
    d = depth(ty)
    s = size(ty)
    state_bound = tsb(ty)

    # Naive bound: for a term of size k with type of complexity c,
    # the reduction graph has at most c^k states
    # Here we just compare structural bounds
    naive_bound = 2**s  # exponential in type size
    quotient_bound = state_bound

    ratio = naive_bound / quotient_bound if quotient_bound > 0 else float('inf')

    return {
        "type": repr(ty),
        "depth": d,
        "size": s,
        "naive_bound": naive_bound,
        "quotient_bound": quotient_bound,
        "compression_ratio": ratio,
        "log2_saving": math.log2(ratio) if ratio > 1 else 0,
    }


# ---------- Main Demo ----------

def main():
    print("=" * 70)
    print("  APPLICATIONS OF ARROW-DEPTH COMPLEXITY THEORY")
    print("=" * 70)

    # App 1: State budget estimation
    print("\n--- Application 1: Compiler State Budget Estimation ---\n")
    test_types = [
        Base(),
        Arrow(Base(), Base()),
        Arrow(Base(), Arrow(Base(), Base())),
        Arrow(Arrow(Base(), Base()), Arrow(Base(), Base())),
    ]
    # Add bushy types
    def bushy(n):
        if n == 0: return Base()
        s = bushy(n-1)
        return Arrow(s, s)

    test_types.extend([bushy(n) for n in range(2, 5)])

    for ty in test_types:
        result = estimate_state_budget(ty)
        print(f"  Type: {result['type'][:40]}")
        print(f"    States: {result['exact_states']}, Technique: {result['technique']}")
        print(f"    Depth={result['depth']}, Width={result['arrow_width']}, Chain={result['is_chain']}")
        print()

    # App 2: Simplification advice
    print("--- Application 2: Type Simplification Advisor ---\n")
    for ty in test_types[1:]:
        advice = suggest_simplification(ty)
        print(f"  {repr(ty)[:35]}: {advice}")
    print()

    # App 3: FPT analysis
    print("--- Application 3: Fixed-Parameter Tractability ---\n")
    chain_types = [Arrow(Base(), Base()), Arrow(Base(), Arrow(Base(), Base())),
                   Arrow(Base(), Arrow(Base(), Arrow(Base(), Base())))]
    mixed_types = chain_types + [Arrow(Arrow(Base(), Base()), Base())]

    for label, types in [("Chain family", chain_types), ("Mixed family", mixed_types)]:
        result = fpt_analysis(types)
        print(f"  {label}:")
        print(f"    Max depth={result['max_depth']}, Max width={result['max_width']}")
        print(f"    Regime: {result['regime']}, FPT feasible: {result['fpt_feasible']}")
        print(f"    Parameter bound: {result['parameter_bound']}")
        print()

    # App 4: Compression analysis
    print("--- Application 4: Semantic Compression Ratios ---\n")
    for ty in test_types[1:]:
        result = compression_analysis(ty)
        print(f"  {result['type'][:35]}: "
              f"compression={result['compression_ratio']:.1f}x "
              f"(saving {result['log2_saving']:.1f} bits)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Interactive demonstration of Arrow-Depth Exponential Complexity.

Shows that arrow depth alone cannot control semantic state complexity
(typeStateBound) for simple types, but type size provides a clean bound.

Key findings:
1. Chain types: singly exponential in depth (typeStateBound ≤ 3^(depth+1))
2. Bushy types: doubly exponential in depth (typeStateBound ≥ 2^(2^depth) - 1)
3. No uniform c^(depth+1) bound exists
4. Universal bound: typeStateBound + 1 ≤ 2^size

Usage:
    python demo.py [--max-depth N] [--search-c C]
"""

import sys
import math

# ---------- Inline type definitions (self-contained) ----------

class Ty:
    pass

class Base(Ty):
    def __repr__(self):
        return "o"

class Arrow(Ty):
    def __init__(self, domain, codomain):
        self.domain = domain
        self.codomain = codomain
    def __repr__(self):
        d = repr(self.domain)
        c = repr(self.codomain)
        if isinstance(self.domain, Arrow):
            d = f"({d})"
        return f"{d} → {c}"


def depth(ty):
    if isinstance(ty, Base): return 0
    return 1 + max(depth(ty.domain), depth(ty.codomain))

def size(ty):
    if isinstance(ty, Base): return 1
    return 1 + size(ty.domain) + size(ty.codomain)

def type_state_bound(ty):
    if isinstance(ty, Base): return 1
    return (type_state_bound(ty.domain) + 1) * (type_state_bound(ty.codomain) + 1)

def arrow_width(ty):
    if isinstance(ty, Base): return 0
    return 1 + arrow_width(ty.domain) + arrow_width(ty.codomain)

def is_chain(ty):
    if isinstance(ty, Base): return True
    return isinstance(ty.domain, Base) and is_chain(ty.codomain)

def bushy(n):
    if n == 0: return Base()
    sub = bushy(n - 1)
    return Arrow(sub, sub)

def chain(n):
    if n == 0: return Base()
    return Arrow(Base(), chain(n - 1))


def print_header(title):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")


def demo_bushy_growth(max_n=7):
    """Demonstrate doubly-exponential growth of bushy types."""
    print_header("BUSHY TYPES: Doubly-Exponential Growth")
    print("  bushy(n) = balanced binary arrow tree of depth n")
    print("  bushy(0) = o, bushy(1) = o→o, bushy(2) = (o→o)→(o→o), ...")
    print()

    fmt = "{:>3} {:>5} {:>6} {:>5} {:>18} {:>18} {:>8}"
    print(fmt.format("n", "depth", "size", "width", "typeStateBound", "2^(2^n)-1", "ratio"))
    print("-" * 70)

    for n in range(max_n):
        ty = bushy(n)
        d = depth(ty)
        s = size(ty)
        w = arrow_width(ty)
        tsb = type_state_bound(ty)
        lower = 2**(2**n) - 1

        ratio = tsb / lower if lower > 0 else float('inf')
        tsb_str = str(tsb) if tsb < 10**15 else f"{tsb:.3e}"
        lower_str = str(lower) if lower < 10**15 else f"{lower:.3e}"
        print(fmt.format(n, d, s, w, tsb_str, lower_str, f"{ratio:.4f}"))

    print()
    print("  ✓ Theorem: typeStateBound(bushy n) + 1 ≥ 2^(2^n)")
    print("  ✓ Growth is DOUBLY exponential in depth")


def demo_chain_growth(max_n=10):
    """Demonstrate singly-exponential growth of chain types."""
    print_header("CHAIN TYPES: Singly-Exponential Growth")
    print("  chain(n) = o → o → ... → o (n arrows)")
    print()

    fmt = "{:>3} {:>5} {:>6} {:>5} {:>12} {:>12} {:>12}"
    print(fmt.format("n", "depth", "size", "width", "tsb", "3*2^n-2", "3^(d+1)"))
    print("-" * 70)

    for n in range(max_n):
        ty = chain(n)
        d = depth(ty)
        s = size(ty)
        w = arrow_width(ty)
        tsb = type_state_bound(ty)
        exact = 3 * 2**n - 2
        bound = 3**(d + 1)

        print(fmt.format(n, d, s, w, tsb, exact, bound))

    print()
    print("  ✓ Exact formula: typeStateBound(chain n) = 3·2^n - 2")
    print("  ✓ Theorem: typeStateBound ≤ 3^(depth+1) for chain types")
    print("  ✓ Chain types are in the SINGLY exponential regime")


def demo_counterexample_search(max_c=50):
    """Search for counterexamples to depth-only bounds."""
    print_header("IMPOSSIBILITY: No Uniform Depth-Only Bound Exists")
    print("  For each proposed constant c, we find bushy(n) violating")
    print("  typeStateBound(bushy n) ≤ c^(depth+1)")
    print()

    fmt = "{:>6} {:>8} {:>18} {:>18} {:>8}"
    print(fmt.format("c", "bushy(n)", "tsb", "c^(n+1)", "violated"))
    print("-" * 65)

    for c in list(range(2, 11)) + [20, 50, 100, 1000]:
        if c > max_c and c < 100:
            continue
        for n in range(30):
            ty = bushy(n)
            tsb = type_state_bound(ty)
            bound = c ** (n + 1)
            if tsb > bound:
                tsb_str = str(tsb) if tsb < 10**15 else f"{tsb:.3e}"
                bound_str = str(bound) if bound < 10**15 else f"{bound:.3e}"
                print(fmt.format(c, f"bushy({n})", tsb_str, bound_str, "YES"))
                break

    print()
    print("  ✓ Theorem: ¬ ∃ c, ∀ A, typeStateBound A ≤ c^(depth A + 1)")
    print("  ✓ Bushy types provide counterexamples for EVERY constant c")


def demo_size_bound(max_depth=3):
    """Demonstrate the universal size-exponential bound."""
    print_header("UNIVERSAL BOUND: typeStateBound + 1 ≤ 2^size")
    print("  This bound holds for ALL types, not just special families")
    print()

    # Enumerate small types
    types = [Base()]
    for d in range(max_depth):
        new_types = []
        for a in types:
            for b in types:
                new_types.append(Arrow(a, b))
        types = types + new_types

    fmt = "{:>25} {:>5} {:>5} {:>10} {:>10} {:>8}"
    print(fmt.format("type", "depth", "size", "tsb+1", "2^size", "slack"))
    print("-" * 70)

    # Sort by typeStateBound for nice display
    types_info = [(ty, depth(ty), size(ty), type_state_bound(ty)) for ty in types]
    types_info.sort(key=lambda x: x[3])

    for ty, d, s, tsb in types_info[:20]:
        two_pow = 2**s
        slack = two_pow - (tsb + 1)
        ty_str = repr(ty)[:25]
        print(fmt.format(ty_str, d, s, tsb + 1, two_pow, slack))

    total = len(types_info)
    verified = sum(1 for _, _, s, tsb in types_info if tsb + 1 <= 2**s)
    print(f"\n  Verified {verified}/{total} types: all satisfy tsb + 1 ≤ 2^size  ✓")


def demo_depth_width_comparison():
    """Compare types of equal depth but different width."""
    print_header("DEPTH vs WIDTH: Same Depth, Different Complexity")
    print("  Types with the same depth can have vastly different state complexity")
    print("  Width (arrowWidth) is the missing parameter")
    print()

    fmt = "{:>30} {:>5} {:>5} {:>12} {:>10}"
    print(fmt.format("type", "depth", "width", "tsb", "chain?"))
    print("-" * 70)

    for n in range(1, 6):
        c_ty = chain(n)
        b_ty = bushy(n)
        c_tsb = type_state_bound(c_ty)
        b_tsb = type_state_bound(b_ty)
        c_w = arrow_width(c_ty)
        b_w = arrow_width(b_ty)

        c_str = repr(c_ty)[:30]
        b_str = repr(b_ty)[:30]
        print(fmt.format(c_str, n, c_w, c_tsb, "yes"))
        print(fmt.format(b_str, n, b_w, b_tsb, "no"))
        if n < 5:
            ratio = b_tsb / c_tsb if c_tsb > 0 else float('inf')
            print(f"{'':>30} ratio bushy/chain: {ratio:.1f}x")
        print()

    print("  ✓ At depth 4: chain has tsb=46, bushy has tsb=458,329")
    print("  ✓ The gap grows EXPONENTIALLY with depth")
    print("  ✓ Arrow width captures this difference")


def demo_growth_fit():
    """Fit exponential growth curves to the data."""
    print_header("GROWTH REGIME CLASSIFICATION")
    print("  Chain types: tsb ~ 3·2^depth (singly exponential)")
    print("  Bushy types: tsb ~ 2^(2^depth) (doubly exponential)")
    print("  General:     tsb ≤ 2^size (exponential in size)")
    print()

    fmt = "{:>12} {:>5} {:>5} {:>15} {:>12} {:>12}"
    print(fmt.format("family", "depth", "size", "tsb", "log₂(tsb)", "log₂log₂"))
    print("-" * 70)

    for n in range(1, 7):
        tsb_c = type_state_bound(chain(n))
        tsb_b = type_state_bound(bushy(n))
        s_c = size(chain(n))
        s_b = size(bushy(n))

        log_c = math.log2(tsb_c) if tsb_c > 0 else 0
        log_b = math.log2(tsb_b) if tsb_b > 0 else 0
        loglog_b = math.log2(log_b) if log_b > 1 else 0

        print(fmt.format(f"chain({n})", n, s_c, tsb_c,
                         f"{log_c:.2f}", "-"))
        print(fmt.format(f"bushy({n})", n, s_b, f"{tsb_b:.3e}" if tsb_b > 10**9 else str(tsb_b),
                         f"{log_b:.2f}", f"{loglog_b:.2f}"))
        print()

    print("  For chains:  log₂(tsb) ≈ depth (linear) → singly exponential")
    print("  For bushy:   log₂(log₂(tsb)) ≈ depth (linear) → doubly exponential")


def main():
    import argparse
    parser = argparse.ArgumentParser(
        description="Arrow-Depth Exponential Complexity Demo")
    parser.add_argument("--max-depth", type=int, default=3,
                        help="Max depth for type enumeration (default: 3)")
    parser.add_argument("--search-c", type=int, default=50,
                        help="Max c for counterexample search (default: 50)")
    args = parser.parse_args()

    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║    ARROW-DEPTH EXPONENTIAL COMPLEXITY FOR SIMPLE TYPES         ║")
    print("║    Formally Verified in Lean 4                                 ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_bushy_growth()
    demo_chain_growth()
    demo_counterexample_search(max_c=args.search_c)
    demo_size_bound(max_depth=args.max_depth)
    demo_depth_width_comparison()
    demo_growth_fit()

    print_header("SUMMARY OF VERIFIED THEOREMS")
    print("  1. typeStateBound = Ty.complexity (identical functions)")
    print("  2. depth ≤ complexity (depth is always bounded)")
    print("  3. Chain types: typeStateBound ≤ 3^(depth+1)")
    print("  4. Bushy types: typeStateBound+1 ≥ 2^(2^depth)")
    print("  5. IMPOSSIBILITY: ¬∃c, ∀A, typeStateBound A ≤ c^(depth A + 1)")
    print("  6. UNIVERSAL: typeStateBound+1 ≤ 2^size for ALL types")
    print("  7. Combined: typeStateBound+1 ≤ 2^(2^(depth+1)-1)")
    print()
    print("  Conclusion: Depth is NECESSARY but INSUFFICIENT.")
    print("  Arrow width (or equivalently size) is the missing parameter.")


if __name__ == "__main__":
    main()
