#!/usr/bin/env python3
"""
Coherence Theory — Basic Computations
======================================
Demonstrates the core definitions: Fourier transform on the Boolean hypercube,
spectral distribution, coherence, and basic properties.

Run: python demo_coherence_basics.py
"""

import numpy as np
from itertools import product
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt


# ── Core Definitions ──────────────────────────────────────────────────────────

def truth_table_to_pm(tt):
    """Convert {0,1}-valued truth table to {-1,+1}-valued (f(x) → (-1)^f(x))."""
    return 1 - 2 * np.array(tt, dtype=float)


def walsh_hadamard_transform(f_pm):
    """
    Compute all 2^n Fourier coefficients of f: {0,1}^n → {-1,+1}.
    Uses the fast Walsh-Hadamard transform.
    Returns f̂(S) for each S ⊆ [n], indexed by the integer whose binary
    representation encodes S.
    """
    n = int(np.log2(len(f_pm)))
    assert 2**n == len(f_pm), "Input length must be a power of 2"
    
    a = np.array(f_pm, dtype=float)
    N = len(a)
    
    # Fast Walsh-Hadamard transform
    h = 1
    while h < N:
        for i in range(0, N, h * 2):
            for j in range(i, i + h):
                x = a[j]
                y = a[j + h]
                a[j] = x + y
                a[j + h] = x - y
        h *= 2
    
    return a / N  # Normalize


def spectral_distribution(fhat):
    """Compute the spectral distribution p(S) = f̂(S)² / Σ f̂(T)²."""
    sq = fhat ** 2
    total = sq.sum()
    if total == 0:
        return np.ones_like(sq) / len(sq)  # Uniform if zero function
    return sq / total


def spectral_entropy(p):
    """Shannon entropy H(p) = -Σ p_i log₂ p_i."""
    mask = p > 1e-15
    return -np.sum(p[mask] * np.log2(p[mask]))


def coherence(f_tt, as_pm=False):
    """
    Compute the coherence C(f) = 1 - H(spectral distribution) / n.
    
    Parameters:
        f_tt: truth table of f, either {0,1}-valued or {-1,+1}-valued
        as_pm: if True, f_tt is already in ±1 form
    
    Returns:
        C(f) ∈ [0, 1]
    """
    if not as_pm:
        f_pm = truth_table_to_pm(f_tt)
    else:
        f_pm = np.array(f_tt, dtype=float)
    
    n = int(np.log2(len(f_pm)))
    if n == 0:
        return 1.0
    
    fhat = walsh_hadamard_transform(f_pm)
    p = spectral_distribution(fhat)
    H = spectral_entropy(p)
    
    return max(0.0, 1.0 - H / n)


# ── Example Functions ─────────────────────────────────────────────────────────

def make_dictator(n, i=0):
    """Dictator function: f(x) = x_i."""
    return [int(format(x, f'0{n}b')[i]) for x in range(2**n)]


def make_parity(n):
    """Parity function: f(x) = x_1 ⊕ x_2 ⊕ ... ⊕ x_n."""
    return [bin(x).count('1') % 2 for x in range(2**n)]


def make_majority(n):
    """Majority function: f(x) = 1 iff more than n/2 bits are 1."""
    return [int(bin(x).count('1') > n / 2) for x in range(2**n)]


def make_threshold(n, k):
    """Threshold function: f(x) = 1 iff at least k bits are 1."""
    return [int(bin(x).count('1') >= k) for x in range(2**n)]


def make_and(n):
    """AND function: f(x) = x_1 ∧ x_2 ∧ ... ∧ x_n."""
    return [int(x == 2**n - 1) for x in range(2**n)]


def make_or(n):
    """OR function: f(x) = x_1 ∨ x_2 ∨ ... ∨ x_n."""
    return [int(x > 0) for x in range(2**n)]


def make_random(n, seed=None):
    """Uniformly random Boolean function."""
    rng = np.random.RandomState(seed)
    return list(rng.randint(0, 2, size=2**n))


# ── Demonstrations ────────────────────────────────────────────────────────────

def demo_basic_coherence():
    """Compute coherence for standard functions."""
    print("=" * 60)
    print("DEMO 1: Coherence of Standard Boolean Functions")
    print("=" * 60)
    
    for n in [4, 6, 8, 10]:
        print(f"\n--- n = {n} ---")
        
        functions = {
            "Dictator (x_0)": make_dictator(n),
            "Parity":         make_parity(n),
            "Majority":       make_majority(n),
            "AND":            make_and(n),
            "OR":             make_or(n),
            f"Threshold(k={n//2})": make_threshold(n, n//2),
        }
        
        # Add random functions
        for seed in range(3):
            functions[f"Random (seed={seed})"] = make_random(n, seed)
        
        for name, tt in functions.items():
            c = coherence(tt)
            sat_count = sum(tt)
            density = sat_count / len(tt)
            print(f"  {name:30s}: C = {c:.4f}  |  density = {density:.4f}")


def demo_coherence_spectrum():
    """Visualize the Fourier spectrum and coherence for different functions."""
    print("\n" + "=" * 60)
    print("DEMO 2: Fourier Spectrum Visualization")
    print("=" * 60)
    
    n = 8
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle(f'Fourier Spectra of Boolean Functions (n={n})', fontsize=16)
    
    functions = {
        "Dictator": make_dictator(n),
        "Parity": make_parity(n),
        "Majority": make_majority(n),
        "AND": make_and(n),
        "OR": make_or(n),
        "Random": make_random(n, seed=42),
    }
    
    for ax, (name, tt) in zip(axes.flat, functions.items()):
        f_pm = truth_table_to_pm(tt)
        fhat = walsh_hadamard_transform(f_pm)
        p = spectral_distribution(fhat)
        c = coherence(tt)
        
        # Sort by magnitude for visibility
        sorted_p = np.sort(p)[::-1]
        ax.bar(range(min(50, len(sorted_p))), sorted_p[:50], color='steelblue', alpha=0.8)
        ax.set_title(f'{name}\nC = {c:.4f}')
        ax.set_xlabel('Coefficient rank')
        ax.set_ylabel('Spectral weight')
        ax.set_ylim(0, max(sorted_p) * 1.2)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/CoherenceFramework/demos/fourier_spectra.png', dpi=150)
    print("  Saved: fourier_spectra.png")


def demo_scaling():
    """How coherence scales with n for different function families."""
    print("\n" + "=" * 60)
    print("DEMO 3: Coherence Scaling with Problem Size")
    print("=" * 60)
    
    ns = list(range(3, 15))
    results = {name: [] for name in ["Dictator", "Parity", "Majority", "AND", "Random"]}
    
    for n in ns:
        results["Dictator"].append(coherence(make_dictator(n)))
        results["Parity"].append(coherence(make_parity(n)))
        results["Majority"].append(coherence(make_majority(n)))
        results["AND"].append(coherence(make_and(n)))
        
        # Average over random functions
        rand_cs = [coherence(make_random(n, seed=s)) for s in range(20)]
        results["Random"].append(np.mean(rand_cs))
    
    fig, ax = plt.subplots(figsize=(10, 6))
    for name, cs in results.items():
        ax.plot(ns, cs, 'o-', label=name, markersize=5)
    
    ax.set_xlabel('n (input dimension)', fontsize=12)
    ax.set_ylabel('Coherence C(f)', fontsize=12)
    ax.set_title('Coherence Scaling with Problem Size', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.05)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/CoherenceFramework/demos/coherence_scaling.png', dpi=150)
    print("  Saved: coherence_scaling.png")
    
    print("\n  Summary:")
    for name, cs in results.items():
        print(f"    {name:15s}: C(n=14) = {cs[-1]:.4f}")


def demo_entropy_duality():
    """Test the C(f) + L(f) = 1 identity."""
    print("\n" + "=" * 60)
    print("DEMO 4: Coherence-Entropy Duality Check")
    print("=" * 60)
    
    n = 10
    print(f"\n  Testing C(f) + H_spectral(f)/n = 1 for n = {n}")
    print(f"  (This is definitionally true for spectral entropy)")
    
    functions = {
        "Dictator": make_dictator(n),
        "Parity": make_parity(n),
        "Majority": make_majority(n),
        "AND": make_and(n),
        "OR": make_or(n),
        "Random_0": make_random(n, seed=0),
        "Random_1": make_random(n, seed=1),
        "Random_2": make_random(n, seed=2),
    }
    
    for name, tt in functions.items():
        f_pm = truth_table_to_pm(tt)
        fhat = walsh_hadamard_transform(f_pm)
        p = spectral_distribution(fhat)
        H = spectral_entropy(p)
        c = coherence(tt)
        L = H / n
        
        sat_frac = sum(tt) / len(tt)
        if 0 < sat_frac < 1:
            H_bin = -sat_frac * np.log2(sat_frac) - (1 - sat_frac) * np.log2(1 - sat_frac)
        else:
            H_bin = 0
        
        print(f"  {name:15s}: C = {c:.4f}, L = {L:.4f}, C+L = {c+L:.4f}, H_binary = {H_bin:.4f}")
    
    print("\n  Note: C + L = 1 always (by definition). The non-trivial question")
    print("  is whether L correlates with the solution entropy H_sol.")


if __name__ == "__main__":
    demo_basic_coherence()
    demo_coherence_spectrum()
    demo_scaling()
    demo_entropy_duality()
    print("\n" + "=" * 60)
    print("All demos complete!")
    print("=" * 60)
