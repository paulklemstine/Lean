#!/usr/bin/env python3
"""
Demo: Multiplicative Independence Hierarchy in Counterfactual Number Theory.

This script demonstrates the key results:
1. The k-product-free hierarchy is strict (with witnesses).
2. The {4, 8} counterexample: all-k-product-free but no UFD.
3. Cramér random models and their rapid failure.
4. The power-independence condition.
"""

from itertools import combinations_with_replacement
from math import log, prod
import random


def is_k_product_free(S: set, k: int) -> bool:
    """Check if S is k-product-free."""
    for combo in combinations_with_replacement(sorted(S), k):
        if prod(combo) in S:
            return False
    return True


def find_violation(S: set, k: int) -> tuple | None:
    """Find a k-product violation."""
    for combo in combinations_with_replacement(sorted(S), k):
        if prod(combo) in S:
            return combo
    return None


def count_factorizations(S: set, n: int) -> list:
    """Find all S-factorizations of n."""
    S_sorted = sorted(s for s in S if s >= 2)
    results = []

    def backtrack(target, min_elem, current):
        if target == 1:
            results.append(tuple(current))
            return
        for s in S_sorted:
            if s < min_elem or s > target:
                continue
            if target % s == 0:
                current.append(s)
                backtrack(target // s, s, current)
                current.pop()

    backtrack(n, min(S_sorted) if S_sorted else 2, [])
    return results


def main():
    print("=" * 60)
    print("  MULTIPLICATIVE INDEPENDENCE HIERARCHY")
    print("  Counterfactual Number Theory Demo")
    print("=" * 60)

    # 1. Strict Hierarchy
    print("\n--- 1. THE HIERARCHY IS STRICT ---\n")
    for k in range(2, 7):
        S = {2, 3, 2 ** (k - 1) * 3}
        print(f"Level k={k}: S = {sorted(S)}")

        all_pass = True
        for j in range(2, k):
            pf = is_k_product_free(S, j)
            print(f"  {j}-product-free: {'✓' if pf else '✗'}")
            if not pf:
                all_pass = False

        pf_k = is_k_product_free(S, k)
        print(f"  {k}-product-free: {'✓' if pf_k else '✗'}")
        if not pf_k:
            v = find_violation(S, k)
            print(f"  Violation: {' × '.join(map(str, v))} = {prod(v)}")
        print()

    # 2. The {4, 8} Counterexample
    print("\n--- 2. THE {4, 8} COUNTEREXAMPLE ---\n")
    S = {4, 8}
    print(f"Set S = {sorted(S)}")
    print(f"\nMultiplicative independence spectrum:")
    for k in range(2, 12):
        pf = is_k_product_free(S, k)
        print(f"  {k}-product-free: {'✓' if pf else '✗'}")
    print(f"\nAll levels pass! But UFD fails:")
    facts = count_factorizations(S, 64)
    for f in facts:
        print(f"  64 = {' × '.join(map(str, f))}")
    print(f"\n  → {len(facts)} distinct factorizations of 64!")

    # Check more numbers
    print(f"\nNumbers with multiple {'{4,8}'}-factorizations:")
    for n in range(2, 300):
        facts = count_factorizations(S, n)
        if len(facts) > 1:
            print(f"  {n}: {len(facts)} factorizations")
            for f in facts:
                print(f"    {' × '.join(map(str, f))}")

    # 3. The {4, 6, 9} example (product-free but no UFD)
    print("\n\n--- 3. PRODUCT-FREE ≠ UFD: {4, 6, 9} ---\n")
    S2 = {4, 6, 9}
    print(f"Set S = {sorted(S2)}")
    print(f"2-product-free: {'✓' if is_k_product_free(S2, 2) else '✗'}")
    facts36 = count_factorizations(S2, 36)
    print(f"Factorizations of 36 over S:")
    for f in facts36:
        print(f"  36 = {' × '.join(map(str, f))}")
    print(f"→ {len(facts36)} distinct factorizations!")

    # 4. Primes have no violations
    print("\n\n--- 4. PRIMES: PERFECT STRUCTURE ---\n")
    primes = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47}
    print(f"Primes up to 47: {sorted(primes)}")
    for k in range(2, 8):
        pf = is_k_product_free(primes, k)
        print(f"  {k}-product-free: {'✓' if pf else '✗'}")

    # 5. Cramér random models fail fast
    print("\n\n--- 5. CRAMÉR RANDOM MODELS FAIL FAST ---\n")
    random.seed(42)
    for N in [50, 100, 500, 1000]:
        failures = 0
        trials = 200
        for _ in range(trials):
            model = set()
            for n in range(2, N + 1):
                if random.random() < 1.0 / log(n):
                    model.add(n)
            if not is_k_product_free(model, 2):
                failures += 1
        print(
            f"N={N:>5}: {failures}/{trials} ({100*failures/trials:.0f}%) "
            f"models fail 2-product-freeness"
        )

    # 6. Product shadow
    print("\n\n--- 6. PRODUCT SHADOW SEPARATION ---\n")
    for S_test in [{2, 3, 5, 7}, {4, 6, 9}, {2, 3, 12}]:
        shadow = set()
        for a in S_test:
            for b in S_test:
                shadow.add(a * b)
        overlap = S_test & shadow
        pf = is_k_product_free(S_test, 2)
        print(f"S = {sorted(S_test)}")
        print(f"  Shadow = {sorted(shadow)}")
        print(f"  S ∩ Shadow = {sorted(overlap) if overlap else '∅'}")
        print(f"  Product-free: {'✓' if pf else '✗'}")
        print()

    # 7. Power independence check
    print("\n--- 7. POWER INDEPENDENCE ---\n")
    test_sets = [
        ({4, 8}, "4=2², 8=2³ → dependent"),
        ({4, 9}, "4=2², 9=3² → independent"),
        ({2, 3, 5}, "all prime → independent"),
        ({8, 27}, "8=2³, 27=3³ → independent"),
        ({4, 32}, "4=2², 32=2⁵ → dependent"),
        ({9, 27}, "9=3², 27=3³ → dependent"),
    ]
    for S_test, desc in test_sets:
        # Check power independence
        def base_exp(n):
            for e in range(63, 0, -1):
                b = round(n ** (1.0 / e))
                for c in [b - 1, b, b + 1]:
                    if c >= 2 and c**e == n:
                        return (c, e)
            return (n, 1)

        bases = {s: base_exp(s) for s in S_test}
        base_vals = [b for b, _ in bases.values()]
        indep = len(set(base_vals)) == len(base_vals)

        facts_check = []
        for n in range(2, 1000):
            fs = count_factorizations(S_test, n)
            if len(fs) > 1:
                facts_check.append((n, fs))

        has_ufd = len(facts_check) == 0
        print(f"S = {sorted(S_test)}: {desc}")
        print(f"  Power-independent: {'✓' if indep else '✗'}")
        print(f"  Has UFD (up to 999): {'✓' if has_ufd else '✗'}")
        if facts_check:
            n, fs = facts_check[0]
            print(f"  First UFD failure: {n}")
            for f in fs:
                print(f"    {' × '.join(map(str, f))}")
        print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Cramér Model Product Violations.

Shows how rapidly random dense sets acquire product violations
compared to actual primes.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, prod
from itertools import combinations_with_replacement
import random


def count_product_violations(S: set, N: int) -> int:
    """Count pairs (a, b) in S with a*b in S and a*b <= N."""
    S_list = sorted(s for s in S if s >= 2)
    count = 0
    for i, a in enumerate(S_list):
        for b in S_list[i:]:
            p = a * b
            if p > N:
                break
            if p in S:
                count += 1
    return count


def main():
    random.seed(42)
    Ns = [50, 100, 200, 500, 1000, 2000]
    trials = 100

    avg_violations = []
    avg_sizes = []
    predicted = []

    for N in Ns:
        violations = []
        sizes = []
        for _ in range(trials):
            S = set()
            for n in range(2, N + 1):
                if random.random() < 1.0 / log(n):
                    S.add(n)
            violations.append(count_product_violations(S, N))
            sizes.append(len(S))
        avg_violations.append(np.mean(violations))
        avg_sizes.append(np.mean(sizes))
        predicted.append(N / log(N)**3)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Product violations vs N
    ax1.loglog(Ns, avg_violations, 'ro-', markersize=8, linewidth=2,
               label='Empirical (avg)')
    ax1.loglog(Ns, predicted, 'b--', linewidth=2,
               label=r'$N / (\ln N)^3$ prediction')
    ax1.set_xlabel("N", fontsize=12)
    ax1.set_ylabel("Average Product Violations", fontsize=12)
    ax1.set_title("Cramér Model: Product Violations", fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Model size vs N
    prime_counts = []
    for N in Ns:
        count = sum(1 for n in range(2, N+1) if all(n % d != 0
                    for d in range(2, int(n**0.5)+1)) and n >= 2)
        prime_counts.append(count)

    ax2.plot(Ns, avg_sizes, 'ro-', markersize=8, linewidth=2,
             label='Cramér model (avg)')
    ax2.plot(Ns, prime_counts, 'g^-', markersize=8, linewidth=2,
             label='Actual primes')
    ax2.plot(Ns, [N/log(N) for N in Ns], 'b--', linewidth=2,
             label=r'$N/\ln N$')
    ax2.set_xlabel("N", fontsize=12)
    ax2.set_ylabel("Set Size", fontsize=12)
    ax2.set_title("Density Comparison", fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("cramer_violations.png", dpi=150, bbox_inches='tight')
    print("Saved cramer_violations.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Multiplicative Independence Hierarchy.

Produces a heatmap showing which sets pass/fail at each level of the hierarchy.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations_with_replacement
from math import prod


def is_k_product_free(S: set, k: int) -> bool:
    """Check if S is k-product-free."""
    for combo in combinations_with_replacement(sorted(S), k):
        if prod(combo) in S:
            return False
    return True


def main():
    # Sets to analyze
    sets_info = [
        ("Primes ≤ 23", {2, 3, 5, 7, 11, 13, 17, 19, 23}),
        ("{4, 8}", {4, 8}),
        ("{2, 3, 6}", {2, 3, 6}),
        ("{2, 3, 12}", {2, 3, 12}),
        ("{2, 3, 24}", {2, 3, 24}),
        ("{2, 3, 48}", {2, 3, 48}),
        ("{2, 3, 96}", {2, 3, 96}),
        ("{4, 6, 9}", {4, 6, 9}),
        ("{4, 9}", {4, 9}),
        ("{6, 10, 15}", {6, 10, 15}),
    ]

    max_k = 8
    names = [s[0] for s in sets_info]
    data = np.zeros((len(sets_info), max_k - 1))

    for i, (name, S) in enumerate(sets_info):
        for k in range(2, max_k + 1):
            data[i, k - 2] = 1 if is_k_product_free(S, k) else 0

    fig, ax = plt.subplots(figsize=(10, 6))

    cmap = plt.cm.colors.ListedColormap(['#FF6B6B', '#4ECDC4'])
    im = ax.imshow(data, cmap=cmap, aspect='auto', interpolation='nearest')

    ax.set_xticks(range(max_k - 1))
    ax.set_xticklabels([f"k={k}" for k in range(2, max_k + 1)])
    ax.set_yticks(range(len(names)))
    ax.set_yticklabels(names)

    ax.set_xlabel("Product-Freeness Level", fontsize=12)
    ax.set_title("Multiplicative Independence Spectrum\n"
                 "(green = k-product-free, red = fails)", fontsize=14)

    for i in range(data.shape[0]):
        for j in range(data.shape[1]):
            text = "✓" if data[i, j] == 1 else "✗"
            ax.text(j, i, text, ha="center", va="center",
                    color="white", fontsize=14, fontweight="bold")

    plt.tight_layout()
    plt.savefig("hierarchy_spectrum.png", dpi=150, bbox_inches='tight')
    print("Saved hierarchy_spectrum.png")

    # Second plot: failure level vs set size
    fig2, ax2 = plt.subplots(figsize=(8, 5))
    ks = list(range(2, 12))
    witness_sizes = []
    for k in ks:
        S = {2, 3, 2**(k-1) * 3}
        witness_sizes.append(max(S))

    ax2.semilogy(ks, witness_sizes, 'bo-', markersize=8, linewidth=2)
    ax2.set_xlabel("Failure Level k", fontsize=12)
    ax2.set_ylabel("Max Element in Witness Set S_k", fontsize=12)
    ax2.set_title("Hierarchy Witnesses: S_k = {2, 3, 2^(k-1)·3}", fontsize=14)
    ax2.grid(True, alpha=0.3)

    for k, sz in zip(ks, witness_sizes):
        ax2.annotate(f"S_{k}", (k, sz), textcoords="offset points",
                     xytext=(10, 5), fontsize=9)

    plt.tight_layout()
    plt.savefig("witness_growth.png", dpi=150, bbox_inches='tight')
    print("Saved witness_growth.png")


if __name__ == "__main__":
    main()
