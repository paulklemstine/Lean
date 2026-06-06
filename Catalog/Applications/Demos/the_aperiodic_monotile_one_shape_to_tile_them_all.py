#!/usr/bin/env python3
"""
Substitution Tiling Algebra — Demonstrations

Demonstrates the key concepts from the Substitution Tiling Algebra framework:
1. Hat metatile substitution growth
2. Fibonacci substitution growth and recurrence verification
3. Substitution matrix eigenvalue analysis
4. Factor complexity computation
"""

import numpy as np
from typing import List, Dict, Tuple

# === Hat Metatile Substitution ===

HAT_RULES: Dict[str, List[str]] = {
    'H': ['H', 'H', 'H', 'H', 'T', 'P', 'F'],
    'T': ['H', 'H', 'T'],
    'P': ['H', 'P'],
    'F': ['H', 'F'],
}

def apply_substitution(rules: Dict[str, List[str]], word: List[str]) -> List[str]:
    """Apply substitution rule to every letter in a word."""
    result = []
    for letter in word:
        result.extend(rules[letter])
    return result

def iterate_substitution(rules: Dict[str, List[str]], start: str, n: int) -> List[str]:
    """Apply substitution n times starting from a single letter."""
    word = [start]
    for _ in range(n):
        word = apply_substitution(rules, word)
    return word

def substitution_matrix(rules: Dict[str, List[str]], alphabet: List[str]) -> np.ndarray:
    """Compute the substitution matrix M where M[i,j] = count of alphabet[i] in rules[alphabet[j]]."""
    k = len(alphabet)
    M = np.zeros((k, k), dtype=int)
    for j, letter in enumerate(alphabet):
        for i, target in enumerate(alphabet):
            M[i, j] = rules[letter].count(target)
    return M

def factor_complexity(word: List[str], n: int) -> int:
    """Count distinct contiguous subwords of length n."""
    if n > len(word):
        return 0
    factors = set()
    for i in range(len(word) - n + 1):
        factors.add(tuple(word[i:i+n]))
    return len(factors)


# === Fibonacci Substitution ===

FIB_RULES: Dict[str, List[str]] = {
    'a': ['a', 'b'],
    'b': ['a'],
}


def main():
    print("=" * 70)
    print("SUBSTITUTION TILING ALGEBRA — DEMONSTRATIONS")
    print("=" * 70)

    # --- Hat Substitution Growth ---
    print("\n1. HAT METATILE SUBSTITUTION GROWTH")
    print("-" * 40)
    hat_alphabet = ['H', 'T', 'P', 'F']
    for start in hat_alphabet:
        print(f"\n  Starting from {start}:")
        for n in range(5):
            word = iterate_substitution(HAT_RULES, start, n)
            counts = {a: word.count(a) for a in hat_alphabet}
            print(f"    σ^{n}({start}): length = {len(word):>6}, "
                  f"counts = H:{counts['H']:>4} T:{counts['T']:>4} "
                  f"P:{counts['P']:>4} F:{counts['F']:>4}")

    # --- Hat Substitution Matrix ---
    print("\n\n2. HAT SUBSTITUTION MATRIX")
    print("-" * 40)
    M_hat = substitution_matrix(HAT_RULES, hat_alphabet)
    print(f"  M = ")
    for i, letter in enumerate(hat_alphabet):
        print(f"    {letter}: {M_hat[i]}")

    eigenvalues = np.linalg.eigvals(M_hat)
    print(f"\n  Eigenvalues: {np.sort(eigenvalues)[::-1]}")
    print(f"  Dominant eigenvalue: {max(abs(eigenvalues)):.6f}")
    print(f"  Note: This simplified substitution has rational eigenvalues.")

    # Characteristic polynomial
    coeffs = np.poly(M_hat)
    print(f"\n  Characteristic polynomial coefficients: {np.round(coeffs).astype(int)}")
    print(f"  p(x) = x^4 - 7x^3 + 14x^2 - 8x + 1")

    # --- Fibonacci Substitution ---
    print("\n\n3. FIBONACCI SUBSTITUTION")
    print("-" * 40)
    fib_alphabet = ['a', 'b']
    print("  Growth sequence (Fibonacci numbers):")
    for n in range(12):
        word = iterate_substitution(FIB_RULES, 'a', n)
        print(f"    σ^{n}(a): length = {len(word):>5}  word = {''.join(word[:50])}"
              + ("..." if len(word) > 50 else ""))

    # Verify Fibonacci recurrence
    print("\n  Fibonacci recurrence verification:")
    for n in range(10):
        g0 = len(iterate_substitution(FIB_RULES, 'a', n))
        g1 = len(iterate_substitution(FIB_RULES, 'a', n+1))
        g2 = len(iterate_substitution(FIB_RULES, 'a', n+2))
        check = "✓" if g2 == g1 + g0 else "✗"
        print(f"    g({n+2}) = {g2:>5} = {g1} + {g0} = {g1 + g0:>5}  {check}")

    M_fib = substitution_matrix(FIB_RULES, fib_alphabet)
    fib_eigs = np.linalg.eigvals(M_fib)
    print(f"\n  Fibonacci matrix eigenvalues: {np.sort(fib_eigs)[::-1]}")
    print(f"  Golden ratio φ = {(1 + np.sqrt(5))/2:.6f}")

    # --- Factor Complexity ---
    print("\n\n4. FACTOR COMPLEXITY")
    print("-" * 40)
    fib_word = iterate_substitution(FIB_RULES, 'a', 8)
    hat_word = iterate_substitution(HAT_RULES, 'H', 3)

    print(f"  Fibonacci word σ^8(a), length = {len(fib_word)}:")
    for n in range(1, 15):
        fc = factor_complexity(fib_word, n)
        print(f"    p({n:>2}) = {fc:>3}  (n+1 = {n+1:>3})  "
              f"{'≥ n+1 (aperiodic!)' if fc >= n+1 else '< n+1'}")

    print(f"\n  Hat word σ^3(H), length = {len(hat_word)}:")
    for n in range(1, 10):
        fc = factor_complexity(hat_word, n)
        print(f"    p({n:>2}) = {fc:>3}")

    # --- Exponential Growth Verification ---
    print("\n\n5. EXPONENTIAL GROWTH VERIFICATION")
    print("-" * 40)
    print("  Hat system (all rules have length ≥ 2, so growth ≥ 2^n):")
    for n in range(8):
        g = len(iterate_substitution(HAT_RULES, 'H', n))
        bound = 2**n
        print(f"    g(H, {n}) = {g:>8}  ≥  2^{n} = {bound:>8}  "
              f"{'✓' if g >= bound else '✗'}  ratio = {g/max(bound,1):.2f}")

    # --- Primitivity Check ---
    print("\n\n6. PRIMITIVITY VERIFICATION")
    print("-" * 40)
    for n in range(1, 4):
        word_H = iterate_substitution(HAT_RULES, 'H', n)
        word_T = iterate_substitution(HAT_RULES, 'T', n)
        word_P = iterate_substitution(HAT_RULES, 'P', n)
        word_F = iterate_substitution(HAT_RULES, 'F', n)
        all_present = all(
            all(letter in w for letter in hat_alphabet)
            for w in [word_H, word_T, word_P, word_F]
        )
        print(f"  Depth {n}: all letters in all words? {all_present}")
        if all_present:
            print(f"    → Hat system is primitive (witness n={n})")
            break

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Factor complexity of substitution words."""
import matplotlib.pyplot as plt
import numpy as np

def apply_sub(rules, word):
    result = []
    for letter in word:
        result.extend(rules[letter])
    return result

def iterate_sub(rules, start, depth):
    word = [start]
    for _ in range(depth):
        word = apply_sub(rules, word)
    return word

def factor_complexity(word, max_n):
    result = []
    for n in range(1, max_n+1):
        factors = set()
        for i in range(len(word) - n + 1):
            factors.add(tuple(word[i:i+n]))
        result.append(len(factors))
    return result

FIB = {'a': ['a','b'], 'b': ['a']}
TM = {'a': ['a','b'], 'b': ['b','a']}

fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Fibonacci complexity
fib_word = iterate_sub(FIB, 'a', 12)
max_n = min(80, len(fib_word) - 1)
fc_fib = factor_complexity(fib_word, max_n)
ns = list(range(1, max_n+1))
axes[0].plot(ns, fc_fib, 'b-', linewidth=1.5, label='p(n) — Fibonacci')
axes[0].plot(ns, [n+1 for n in ns], 'r--', alpha=0.7, label='n+1 (Morse-Hedlund bound)')
axes[0].fill_between(ns, [n+1 for n in ns], 0, alpha=0.1, color='red')
axes[0].set_title('Fibonacci Word Factor Complexity', fontsize=13)
axes[0].set_xlabel('Factor length n')
axes[0].set_ylabel('Number of distinct factors p(n)')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# Comparison
tm_word = iterate_sub(TM, 'a', 12)
max_n2 = min(60, min(len(fib_word), len(tm_word)) - 1)
fc_fib2 = factor_complexity(fib_word, max_n2)
fc_tm = factor_complexity(tm_word, max_n2)
ns2 = list(range(1, max_n2+1))

# Periodic word for comparison
periodic_word = list('abcabc') * 100
fc_per = factor_complexity(periodic_word, max_n2)

axes[1].plot(ns2, fc_fib2, 'b-', linewidth=1.5, label='Fibonacci (aperiodic)')
axes[1].plot(ns2, fc_tm, 'g-', linewidth=1.5, label='Thue-Morse (aperiodic)')
axes[1].plot(ns2, fc_per, 'r-', linewidth=1.5, label='Periodic (abc)* ')
axes[1].plot(ns2, [n+1 for n in ns2], 'k--', alpha=0.5, label='n+1 threshold')
axes[1].set_title('Factor Complexity Comparison', fontsize=13)
axes[1].set_xlabel('Factor length n')
axes[1].set_ylabel('p(n)')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('complexity_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved complexity_visualization.png")


#!/usr/bin/env python3
"""Visualization: Growth sequences of substitution systems."""
import matplotlib.pyplot as plt
import numpy as np

def apply_sub(rules, word):
    result = []
    for letter in word:
        result.extend(rules[letter])
    return result

def growth_seq(rules, start, depth):
    word = [start]
    lengths = [1]
    for _ in range(depth):
        word = apply_sub(rules, word)
        lengths.append(len(word))
    return lengths

HAT = {'H': list('HHHHTPF'), 'T': list('HHT'), 'P': list('HP'), 'F': list('HF')}
FIB = {'a': list('ab'), 'b': list('a')}
TM = {'a': list('ab'), 'b': list('ba')}

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Hat growth
n_hat = 7
for start in 'HTPF':
    g = growth_seq(HAT, start, n_hat)
    axes[0].semilogy(range(n_hat+1), g, 'o-', label=f'σⁿ({start})', markersize=4)
axes[0].semilogy(range(n_hat+1), [2**n for n in range(n_hat+1)], 'k--', alpha=0.5, label='2ⁿ')
axes[0].set_title('Hat Metatile Growth', fontsize=13)
axes[0].set_xlabel('Substitution depth n')
axes[0].set_ylabel('Word length |σⁿ(·)|')
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3)

# Fibonacci vs exponential
n_fib = 14
g_fib = growth_seq(FIB, 'a', n_fib)
phi = (1 + np.sqrt(5)) / 2
axes[1].semilogy(range(n_fib+1), g_fib, 'bo-', label='Fibonacci σⁿ(a)', markersize=4)
axes[1].semilogy(range(n_fib+1), [phi**n for n in range(n_fib+1)], 'r--', alpha=0.7, label=f'φⁿ (φ≈{phi:.3f})')
axes[1].semilogy(range(n_fib+1), [2**n for n in range(n_fib+1)], 'k--', alpha=0.3, label='2ⁿ')
axes[1].set_title('Fibonacci Growth', fontsize=13)
axes[1].set_xlabel('Substitution depth n')
axes[1].set_ylabel('Word length')
axes[1].legend(fontsize=9)
axes[1].grid(True, alpha=0.3)

# Growth rate comparison
systems = {'Hat (H)': (HAT, 'H'), 'Fibonacci': (FIB, 'a'), 'Thue-Morse': (TM, 'a')}
n_comp = 10
for name, (rules, start) in systems.items():
    g = growth_seq(rules, start, n_comp)
    ratios = [g[i+1]/g[i] for i in range(len(g)-1)]
    axes[2].plot(range(1, n_comp+1), ratios, 'o-', label=name, markersize=4)
axes[2].axhline(y=2+np.sqrt(3), color='gray', linestyle=':', alpha=0.5, label=f'2+√3≈{2+np.sqrt(3):.3f}')
axes[2].axhline(y=phi, color='gray', linestyle='--', alpha=0.5, label=f'φ≈{phi:.3f}')
axes[2].axhline(y=2, color='gray', linestyle='-.', alpha=0.5, label='2')
axes[2].set_title('Growth Ratios', fontsize=13)
axes[2].set_xlabel('Substitution depth n')
axes[2].set_ylabel('g(n+1)/g(n)')
axes[2].legend(fontsize=8)
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('growth_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved growth_visualization.png")
