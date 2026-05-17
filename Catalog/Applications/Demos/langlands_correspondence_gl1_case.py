#!/usr/bin/env python3
"""
GL(1) Langlands Correspondence — Applications

Real-world applications of the GL(1) Langlands correspondence:

1. Cryptography: Dirichlet characters in primality testing
2. Signal processing: Character-based Fourier analysis on finite groups
3. Error-correcting codes: Quadratic residue codes via Legendre symbol
4. Random number generation: Character sums and pseudorandomness
"""

import numpy as np
from math import gcd, isqrt
from typing import List, Tuple
from algorithms import (
    DirichletCharacter, enumerate_characters,
    padic_val, frobenius, artin_map
)


# ============================================================
# Application 1: Character Sums and Prime Distribution
# ============================================================

def character_sum_primes(n: int, bound: int) -> dict:
    """
    Use character sums to study prime distribution in residue classes.
    
    By the orthogonality of Dirichlet characters (the automorphic side
    of GL(1) Langlands), we can count primes in arithmetic progressions.
    
    The number of primes p ≤ X with p ≡ a (mod n) is approximately:
    π(X; n, a) ≈ Li(X) / φ(n)
    
    Character sums detect deviations from this equidistribution.
    """
    from sympy import isprime
    
    units = [a for a in range(1, n) if gcd(a, n) == 1]
    phi_n = len(units)
    
    # Count primes in each residue class
    counts = {a: 0 for a in units}
    total_primes = 0
    for p in range(2, bound + 1):
        if isprime(p) and gcd(p, n) == 1:
            counts[p % n] += 1
            total_primes += 1
    
    # Compute character sums L(1, χ) approximations
    chars = enumerate_characters(n)
    char_sums = []
    for chi in chars:
        s = sum(chi(p % n) / p for p in range(2, bound + 1) 
                if isprime(p) and gcd(p, n) == 1)
        char_sums.append(s)
    
    return {
        'residue_counts': counts,
        'total_primes': total_primes,
        'expected_per_class': total_primes / phi_n,
        'char_sums': char_sums,
    }


# ============================================================
# Application 2: Fourier Analysis on (ℤ/nℤ)ˣ
# ============================================================

def fourier_transform_on_units(n: int, f: dict) -> dict:
    """
    Compute the Fourier transform of f : (ℤ/nℤ)ˣ → ℂ using
    the Dirichlet character basis.
    
    f̂(χ) = Σ_{a ∈ (ℤ/nℤ)ˣ} f(a) · χ(a)⁻¹
    
    This is the automorphic decomposition in the GL(1) case:
    every function on the idèle class group decomposes into
    characters = automorphic forms for GL(1).
    """
    chars = enumerate_characters(n)
    units = [a for a in range(1, n) if gcd(a, n) == 1]
    phi_n = len(units)
    
    coefficients = {}
    for k, chi in enumerate(chars):
        coeff = sum(f.get(a, 0) * np.conj(chi(a)) for a in units)
        coefficients[k] = coeff / phi_n
    
    return coefficients


def inverse_fourier_on_units(n: int, coefficients: dict) -> dict:
    """
    Inverse Fourier transform: reconstruct f from its character decomposition.
    
    f(a) = Σ_χ f̂(χ) · χ(a)
    """
    chars = enumerate_characters(n)
    units = [a for a in range(1, n) if gcd(a, n) == 1]
    
    f = {}
    for a in units:
        val = sum(coefficients.get(k, 0) * chi(a) 
                  for k, chi in enumerate(chars))
        f[a] = val
    
    return f


# ============================================================
# Application 3: Quadratic Residue Codes
# ============================================================

def legendre_symbol(a: int, p: int) -> int:
    """
    Compute the Legendre symbol (a/p) for odd prime p.
    
    This is the simplest nontrivial Dirichlet character: the unique
    character of order 2 of (ℤ/pℤ)ˣ. Under GL(1) Langlands, it
    corresponds to the quadratic Galois character of ℚ(√p*)/ℚ.
    """
    if a % p == 0:
        return 0
    result = pow(a, (p - 1) // 2, p)
    return result if result == 1 else -1


def quadratic_residue_code(p: int) -> Tuple[List[int], List[int]]:
    """
    Construct a quadratic residue (QR) code of length p.
    
    QR codes are cyclic codes whose generator polynomial has roots
    at the quadratic residues mod p. They achieve excellent minimum
    distance and are connected to the Legendre character.
    
    The quadratic residues form a subgroup of (ℤ/pℤ)ˣ of index 2,
    which is exactly the kernel of the Legendre character (a GL(1)
    automorphic object).
    
    Returns (quadratic_residues, non_residues).
    """
    qr = [a for a in range(1, p) if legendre_symbol(a, p) == 1]
    nr = [a for a in range(1, p) if legendre_symbol(a, p) == -1]
    return qr, nr


# ============================================================
# Application 4: Gauss Sums and Root Number Computation
# ============================================================

def gauss_sum(chi: DirichletCharacter) -> complex:
    """
    Compute the Gauss sum τ(χ) = Σ_{a=1}^{n-1} χ(a) · e^{2πia/n}.
    
    The Gauss sum is the fundamental analytic invariant of a
    Dirichlet character. It appears in:
    - The functional equation of L(s, χ)
    - The root number W(χ) = τ(χ) / |τ(χ)|
    - Explicit formulas for character sums
    
    Under GL(1) Langlands, |τ(χ)|² = n for primitive χ,
    which is a shadow of the local Langlands normalization.
    """
    n = chi.n
    units = [a for a in range(1, n) if gcd(a, n) == 1]
    
    tau = sum(chi(a) * np.exp(2j * np.pi * a / n) for a in units)
    return tau


def root_number(chi: DirichletCharacter) -> complex:
    """
    Compute the root number W(χ) = τ(χ) / √n.
    
    For primitive characters, |W(χ)| = 1.
    """
    tau = gauss_sum(chi)
    return tau / np.sqrt(chi.n)


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Prime Distribution via Character Sums")
    print("=" * 60)
    
    n = 5
    result = character_sum_primes(n, 1000)
    print(f"\nPrimes up to 1000 in residue classes mod {n}:")
    for a, count in sorted(result['residue_counts'].items()):
        print(f"  Primes ≡ {a} (mod {n}): {count}")
    print(f"  Expected per class: {result['expected_per_class']:.1f}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 2: Fourier Analysis on (ℤ/7ℤ)ˣ")
    print("=" * 60)
    
    # Define a function on (ℤ/7ℤ)ˣ
    f = {1: 1.0, 2: 0.5, 3: -0.3, 4: 0.7, 5: -0.2, 6: 0.1}
    print(f"\nOriginal function f: {f}")
    
    coeffs = fourier_transform_on_units(7, f)
    print(f"Fourier coefficients: ", end="")
    for k, c in coeffs.items():
        if abs(c.imag) < 1e-10:
            print(f"f̂(χ_{k}) = {c.real:.4f}", end="  ")
        else:
            print(f"f̂(χ_{k}) = {c:.4f}", end="  ")
    print()
    
    # Verify inverse transform
    f_reconstructed = inverse_fourier_on_units(7, coeffs)
    print("Reconstructed: ", end="")
    for a in sorted(f_reconstructed.keys()):
        print(f"f({a}) = {f_reconstructed[a].real:.4f}", end="  ")
    print()
    
    print("\n" + "=" * 60)
    print("APPLICATION 3: Quadratic Residue Codes")
    print("=" * 60)
    
    for p in [7, 11, 23]:
        qr, nr = quadratic_residue_code(p)
        print(f"\nQR code of length {p}:")
        print(f"  Quadratic residues: {qr}")
        print(f"  Non-residues: {nr}")
        print(f"  Code dimension: {(p+1)//2}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 4: Gauss Sums and Root Numbers")
    print("=" * 60)
    
    for n in [5, 7, 11]:
        chars = enumerate_characters(n)
        print(f"\nGauss sums for characters mod {n}:")
        for k, chi in enumerate(chars):
            tau = gauss_sum(chi)
            w = root_number(chi)
            print(f"  τ(χ_{k}) = {tau.real:>+8.4f} {tau.imag:>+8.4f}i  "
                  f"|τ|² = {abs(tau)**2:>6.2f}  W(χ_{k}) = {w.real:>+6.3f} {w.imag:>+6.3f}i")


#!/usr/bin/env python3
"""
GL(1) Langlands Correspondence over ℚ — Demonstrations

Concrete numerical examples illustrating the Artin reciprocity map,
Dirichlet characters, Frobenius elements, and the GL(1) Langlands
correspondence at finite level.
"""

import numpy as np
from math import gcd
from sympy import isprime, primerange, factorint, totient
from typing import Dict, List, Tuple


def coprime_units(n: int) -> List[int]:
    """Return the elements of (ℤ/nℤ)ˣ as integers coprime to n."""
    return [a for a in range(1, n) if gcd(a, n) == 1]


def frobenius_element(p: int, n: int) -> int:
    """
    Compute the Frobenius element Frob_p in Gal(ℚ(ζ_n)/ℚ) ≅ (ℤ/nℤ)ˣ.
    
    For a prime p not dividing n, the Frobenius at p is simply p mod n.
    This is the automorphism σ_p : ζ_n ↦ ζ_n^p.
    """
    assert gcd(p, n) == 1, f"p={p} must be coprime to n={n}"
    return p % n


def artin_map(a: int, n: int) -> int:
    """
    The Artin reciprocity map at level n.
    
    Sends a ∈ (ℤ/nℤ)ˣ to the corresponding element of Gal(ℚ(ζ_n)/ℚ).
    Since Gal(ℚ(ζ_n)/ℚ) ≅ (ℤ/nℤ)ˣ canonically, this is the identity.
    """
    assert gcd(a, n) == 1
    return a % n


def dirichlet_character(n: int, target_gen: int = None) -> Dict[int, complex]:
    """
    Compute a Dirichlet character mod n.
    
    Returns a dictionary mapping (ℤ/nℤ)ˣ → ℂˣ.
    Uses the canonical generator to construct a primitive character.
    """
    units = coprime_units(n)
    phi_n = len(units)
    omega = np.exp(2j * np.pi / phi_n)
    
    # Build character by mapping generator → ω
    # Find a generator (primitive root) if possible
    if target_gen is None:
        for g in units:
            powers = set()
            val = 1
            for _ in range(phi_n):
                val = (val * g) % n
                powers.add(val)
            if len(powers) == phi_n:
                target_gen = g
                break
    
    if target_gen is None:
        # No primitive root; use trivial character
        return {a: 1+0j for a in units}
    
    # Build discrete log table
    char = {}
    val = 1
    for k in range(phi_n):
        char[val] = omega ** k
        val = (val * target_gen) % n
    
    return char


def verify_character_homomorphism(char: Dict[int, complex], n: int) -> bool:
    """Verify that a character is a group homomorphism."""
    units = coprime_units(n)
    for a in units:
        for b in units:
            ab = (a * b) % n
            if abs(char[ab] - char[a] * char[b]) > 1e-10:
                return False
    return True


def padic_valuation(x_num: int, x_den: int, p: int) -> int:
    """
    Compute the p-adic valuation v_p(x) where x = x_num/x_den.
    """
    if x_num == 0:
        return float('inf')
    
    v_num = 0
    n = abs(x_num)
    while n % p == 0:
        v_num += 1
        n //= p
    
    v_den = 0
    d = x_den
    while d % p == 0:
        v_den += 1
        d //= p
    
    return v_num - v_den


def verify_product_formula(num: int, den: int) -> bool:
    """
    Verify the product formula: for x = num/den,
    the p-adic valuations have finite support and
    ∏_p p^{v_p(x)} = |x| (as a ratio).
    
    More precisely: ∏_p p^{v_p(num)} / ∏_p p^{v_p(den)} = num/den
    """
    if num == 0:
        return True
    
    # Collect all primes dividing num or den
    factors_num = factorint(abs(num))
    factors_den = factorint(den)
    all_primes = set(factors_num.keys()) | set(factors_den.keys())
    
    # Verify finite support
    for p in all_primes:
        v = padic_valuation(num, den, p)
        if v != 0:
            pass  # nonzero valuation at p
    
    # Verify the product formula: ∏ p^v_p = |num/den|
    product = 1
    for p in all_primes:
        v = padic_valuation(num, den, p)
        if v > 0:
            product *= p ** v
        elif v < 0:
            product /= p ** (-v)
    
    return abs(product - abs(num) / den) < 1e-10


def demonstrate_langlands_gl1(n: int):
    """
    Demonstrate the GL(1) Langlands correspondence at level n.
    
    Shows:
    1. The Galois group Gal(ℚ(ζ_n)/ℚ) ≅ (ℤ/nℤ)ˣ
    2. Frobenius elements for small primes
    3. A Dirichlet character and its Langlands dual
    4. Verification of the Frobenius compatibility
    """
    print(f"\n{'='*60}")
    print(f"GL(1) LANGLANDS CORRESPONDENCE AT LEVEL n = {n}")
    print(f"{'='*60}")
    
    units = coprime_units(n)
    print(f"\n(ℤ/{n}ℤ)ˣ = {units}")
    print(f"|Gal(ℚ(ζ_{n})/ℚ)| = φ({n}) = {len(units)}")
    
    # Frobenius elements
    print(f"\nFrobenius elements (primes p ∤ {n}):")
    for p in primerange(2, 50):
        if gcd(p, n) == 1:
            frob = frobenius_element(p, n)
            print(f"  Frob_{p} = {frob} mod {n}  (σ_{frob}: ζ_{n} ↦ ζ_{n}^{p})")
            if p > 20:
                break
    
    # Dirichlet character
    char = dirichlet_character(n)
    is_hom = verify_character_homomorphism(char, n)
    print(f"\nDirichlet character χ mod {n}:")
    for a in units:
        val = char[a]
        if abs(val.imag) < 1e-10:
            print(f"  χ({a}) = {val.real:.4f}")
        else:
            print(f"  χ({a}) = {val.real:.4f} + {val.imag:.4f}i")
    print(f"  Is group homomorphism: {is_hom}")
    
    # Langlands correspondence
    print(f"\nGL(1) Langlands: χ ↔ ρ where ρ(Frob_p) = χ(p mod {n})")
    print("Verification (Frobenius compatibility):")
    for p in primerange(2, 30):
        if gcd(p, n) == 1:
            frob = frobenius_element(p, n)
            chi_val = char[frob]
            if abs(chi_val.imag) < 1e-10:
                print(f"  χ(Frob_{p}) = χ({frob}) = {chi_val.real:.4f}")
            else:
                print(f"  χ(Frob_{p}) = χ({frob}) = {chi_val.real:.4f} + {chi_val.imag:.4f}i")


def demonstrate_product_formula():
    """Demonstrate the product formula for several rationals."""
    print(f"\n{'='*60}")
    print("PRODUCT FORMULA FOR ℚ")
    print(f"{'='*60}")
    
    test_cases = [
        (12, 1, "12/1"),
        (7, 3, "7/3"),
        (100, 63, "100/63"),
        (1, 6, "1/6"),
        (360, 1, "360"),
        (-30, 7, "-30/7"),
    ]
    
    for num, den, label in test_cases:
        print(f"\nx = {label}")
        if num == 0:
            continue
        
        factors_num = factorint(abs(num))
        factors_den = factorint(den) if den > 1 else {}
        all_primes = sorted(set(factors_num.keys()) | set(factors_den.keys()))
        
        vals = []
        for p in all_primes:
            v = padic_valuation(num, den, p)
            if v != 0:
                vals.append((p, v))
                print(f"  v_{p}({label}) = {v}")
        
        verified = verify_product_formula(num, den)
        print(f"  Product formula verified: {verified}")
        
        # Show the balance: ∏ p^v_p = |x|
        if vals:
            terms = " × ".join(f"{p}^{v}" for p, v in vals)
            product = 1.0
            for p, v in vals:
                product *= p ** v
            print(f"  ∏ p^v_p = {terms} = {product:.4f} = |{label}|")


def demonstrate_level_raising():
    """Demonstrate the change-of-level functoriality."""
    print(f"\n{'='*60}")
    print("LEVEL RAISING: CHARACTERS MOD m → CHARACTERS MOD n (m | n)")
    print(f"{'='*60}")
    
    m, n = 3, 12
    print(f"\nLevel raising from mod {m} to mod {n}:")
    
    units_m = coprime_units(m)
    units_n = coprime_units(n)
    print(f"  (ℤ/{m}ℤ)ˣ = {units_m}")
    print(f"  (ℤ/{n}ℤ)ˣ = {units_n}")
    
    # Character mod 3
    char_m = dirichlet_character(m)
    print(f"\n  χ mod {m}:")
    for a in units_m:
        val = char_m[a]
        print(f"    χ({a}) = {val.real:.4f} + {val.imag:.4f}i")
    
    # Level-raise to mod 12
    print(f"\n  Level-raised χ' mod {n}:")
    for a in units_n:
        a_mod_m = a % m
        if a_mod_m in char_m:
            val = char_m[a_mod_m]
            print(f"    χ'({a}) = χ({a} mod {m}) = χ({a_mod_m}) = {val.real:.4f} + {val.imag:.4f}i")


if __name__ == "__main__":
    print("GL(1) LANGLANDS CORRESPONDENCE OVER ℚ — DEMONSTRATIONS")
    print("=" * 60)
    
    # Demo 1: Product formula
    demonstrate_product_formula()
    
    # Demo 2: GL(1) Langlands at various levels
    for n in [5, 7, 12]:
        demonstrate_langlands_gl1(n)
    
    # Demo 3: Level raising
    demonstrate_level_raising()
    
    print(f"\n{'='*60}")
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
GL(1) Langlands Correspondence — Visualizations

Generates publication-quality figures illustrating the key structures
of the GL(1) Langlands correspondence.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from math import gcd
import base64
import io


def save_fig_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_character_table(n: int, filename: str = None):
    """
    Visualize the character table of (ℤ/nℤ)ˣ as a heatmap.
    
    Each row is a Dirichlet character, each column is a group element.
    Colors encode the phase of the character value.
    """
    units = [a for a in range(1, n) if gcd(a, n) == 1]
    phi_n = len(units)
    
    # Find generator
    gen = None
    for g in units:
        powers = set()
        val = 1
        for _ in range(phi_n):
            val = (val * g) % n
            powers.add(val)
        if len(powers) == phi_n:
            gen = g
            break
    
    if gen is None:
        return None
    
    # Build character table
    table = np.zeros((phi_n, phi_n), dtype=complex)
    for k in range(phi_n):
        omega_k = np.exp(2j * np.pi * k / phi_n)
        val = 1
        for j in range(phi_n):
            idx = units.index(val)
            table[k, idx] = omega_k ** j
            val = (val * gen) % n
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Phase plot
    phases = np.angle(table) / (2 * np.pi)
    im1 = ax1.imshow(phases, cmap='hsv', aspect='auto', vmin=-0.5, vmax=0.5)
    ax1.set_xticks(range(phi_n))
    ax1.set_xticklabels(units)
    ax1.set_yticks(range(phi_n))
    ax1.set_yticklabels([f'χ_{k}' for k in range(phi_n)])
    ax1.set_xlabel('Group element a ∈ (ℤ/nℤ)ˣ')
    ax1.set_ylabel('Character')
    ax1.set_title(f'Character Table Phases — (ℤ/{n}ℤ)ˣ')
    plt.colorbar(im1, ax=ax1, label='Phase / 2π')
    
    # Magnitude plot (should all be 1)
    magnitudes = np.abs(table)
    im2 = ax2.imshow(magnitudes, cmap='viridis', aspect='auto', vmin=0, vmax=1.5)
    ax2.set_xticks(range(phi_n))
    ax2.set_xticklabels(units)
    ax2.set_yticks(range(phi_n))
    ax2.set_yticklabels([f'χ_{k}' for k in range(phi_n)])
    ax2.set_xlabel('Group element a ∈ (ℤ/nℤ)ˣ')
    ax2.set_ylabel('Character')
    ax2.set_title(f'Character Magnitudes (all = 1)')
    plt.colorbar(im2, ax=ax2, label='|χ(a)|')
    
    fig.suptitle(f'GL(1) Langlands: Character Table of (ℤ/{n}ℤ)ˣ ≅ Gal(ℚ(ζ_{n})/ℚ)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    
    if filename:
        fig.savefig(filename, dpi=150, bbox_inches='tight')
    
    return save_fig_base64(fig)


def plot_frobenius_map(n: int, filename: str = None):
    """
    Visualize the Frobenius map: for each prime p, show where
    Frob_p lands in the Galois group (ℤ/nℤ)ˣ.
    """
    from sympy import primerange
    
    units = [a for a in range(1, n) if gcd(a, n) == 1]
    primes = [p for p in primerange(2, 100) if gcd(p, n) == 1]
    
    fig, ax = plt.subplots(figsize=(12, 6))
    
    # For each prime, plot its Frobenius element
    frob_values = [p % n for p in primes]
    
    colors = plt.cm.Set1(np.linspace(0, 1, len(units)))
    color_map = {a: colors[i] for i, a in enumerate(units)}
    
    bar_colors = [color_map[f] for f in frob_values]
    
    ax.bar(range(len(primes)), frob_values, color=bar_colors, edgecolor='black', linewidth=0.5)
    ax.set_xticks(range(len(primes)))
    ax.set_xticklabels([str(p) for p in primes], rotation=45, fontsize=8)
    ax.set_xlabel('Prime p')
    ax.set_ylabel(f'Frob_p ∈ (ℤ/{n}ℤ)ˣ')
    ax.set_title(f'Frobenius Elements in Gal(ℚ(ζ_{n})/ℚ)\n'
                 f'Each color = a residue class mod {n}')
    
    # Add horizontal lines for each unit
    for a in units:
        ax.axhline(y=a, color=color_map[a], alpha=0.3, linestyle='--')
    
    ax.set_ylim(0, n)
    plt.tight_layout()
    
    if filename:
        fig.savefig(filename, dpi=150, bbox_inches='tight')
    
    return save_fig_base64(fig)


def plot_gauss_sums(max_n: int = 30, filename: str = None):
    """
    Visualize Gauss sums τ(χ) for primitive characters mod p (primes).
    Shows that |τ(χ)|² = p for primitive characters.
    """
    from sympy import isprime
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Collect Gauss sum data
    primes_data = []
    for p in range(3, max_n + 1):
        if not isprime(p):
            continue
        
        units = [a for a in range(1, p) if gcd(a, p) == 1]
        phi_p = len(units)
        
        gen = None
        for g in units:
            powers = set()
            val = 1
            for _ in range(phi_p):
                val = (val * g) % p
                powers.add(val)
            if len(powers) == phi_p:
                gen = g
                break
        
        if gen is None:
            continue
        
        for k in range(phi_p):
            omega_k = np.exp(2j * np.pi * k / phi_p)
            # Build character
            char_vals = {}
            val = 1
            img = 1+0j
            for _ in range(phi_p):
                char_vals[val] = img
                val = (val * gen) % p
                img *= omega_k
            
            # Gauss sum
            tau = sum(char_vals[a] * np.exp(2j * np.pi * a / p) for a in units)
            primes_data.append((p, k, tau, abs(tau)**2))
    
    # Plot |τ|² vs p
    for p, k, tau, tau_sq in primes_data:
        color = 'blue' if k == 0 else 'red'
        marker = 'o' if k == 0 else '.'
        ax1.scatter(p, tau_sq, c=color, s=20 if k > 0 else 50, alpha=0.6, marker=marker)
    
    # Reference line y = p
    ps = sorted(set(d[0] for d in primes_data))
    ax1.plot(ps, ps, 'g--', linewidth=2, label='y = p')
    ax1.set_xlabel('Prime p')
    ax1.set_ylabel('|τ(χ)|²')
    ax1.set_title('Gauss Sum Magnitudes')
    ax1.legend()
    
    # Plot τ(χ) in complex plane for p = 7
    p = 7
    p_data = [(k, tau) for p2, k, tau, _ in primes_data if p2 == p]
    
    theta = np.linspace(0, 2*np.pi, 100)
    ax2.plot(np.sqrt(p) * np.cos(theta), np.sqrt(p) * np.sin(theta), 
             'g--', alpha=0.5, label=f'|z| = √{p}')
    
    for k, tau in p_data:
        ax2.plot(tau.real, tau.imag, 'ro', markersize=8)
        ax2.annotate(f'χ_{k}', (tau.real, tau.imag), 
                     textcoords="offset points", xytext=(5, 5), fontsize=8)
    
    ax2.set_xlabel('Re(τ)')
    ax2.set_ylabel('Im(τ)')
    ax2.set_title(f'Gauss Sums τ(χ) for Characters mod {p}')
    ax2.set_aspect('equal')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    fig.suptitle('Gauss Sums: The Analytic Shadow of GL(1) Langlands',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    
    if filename:
        fig.savefig(filename, dpi=150, bbox_inches='tight')
    
    return save_fig_base64(fig)


def plot_langlands_diagram(filename: str = None):
    """
    Create a conceptual diagram of the GL(1) Langlands correspondence.
    """
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.axis('off')
    
    # Automorphic side (left)
    rect1 = plt.Rectangle((0.5, 5.5), 4, 2.5, fill=True, 
                           facecolor='#E8F4FD', edgecolor='#2196F3', linewidth=2)
    ax.add_patch(rect1)
    ax.text(2.5, 7.3, 'AUTOMORPHIC SIDE', ha='center', fontsize=12, fontweight='bold',
            color='#1565C0')
    ax.text(2.5, 6.7, 'Hecke Characters', ha='center', fontsize=11)
    ax.text(2.5, 6.2, 'χ : (ℤ/nℤ)ˣ → Aˣ', ha='center', fontsize=10, 
            fontstyle='italic', color='#666')
    
    # Galois side (right)
    rect2 = plt.Rectangle((6.5, 5.5), 4, 2.5, fill=True,
                           facecolor='#FFF3E0', edgecolor='#FF9800', linewidth=2)
    ax.add_patch(rect2)
    ax.text(8.5, 7.3, 'GALOIS SIDE', ha='center', fontsize=12, fontweight='bold',
            color='#E65100')
    ax.text(8.5, 6.7, 'Galois Representations', ha='center', fontsize=11)
    ax.text(8.5, 6.2, 'ρ : Gal(ℚ(ζₙ)/ℚ) → Aˣ', ha='center', fontsize=10,
            fontstyle='italic', color='#666')
    
    # Arrow (Langlands correspondence)
    ax.annotate('', xy=(6.3, 6.75), xytext=(4.7, 6.75),
                arrowprops=dict(arrowstyle='<->', color='#4CAF50', lw=3))
    ax.text(5.5, 7.1, 'GL(1) Langlands', ha='center', fontsize=11, 
            fontweight='bold', color='#2E7D32')
    
    # Artin map (bottom center)
    rect3 = plt.Rectangle((3, 2.5), 5, 2, fill=True,
                           facecolor='#F3E5F5', edgecolor='#9C27B0', linewidth=2)
    ax.add_patch(rect3)
    ax.text(5.5, 3.9, 'ARTIN RECIPROCITY MAP', ha='center', fontsize=11, fontweight='bold',
            color='#6A1B9A')
    ax.text(5.5, 3.3, '(ℤ/nℤ)ˣ ≅ Gal(ℚ(ζₙ)/ℚ)', ha='center', fontsize=11,
            fontstyle='italic')
    ax.text(5.5, 2.8, 'Frob_p ↦ (ζₙ ↦ ζₙᵖ)', ha='center', fontsize=10, color='#666')
    
    # Arrows from Artin to both sides
    ax.annotate('', xy=(2.5, 5.3), xytext=(4, 4.6),
                arrowprops=dict(arrowstyle='->', color='#7B1FA2', lw=2))
    ax.annotate('', xy=(8.5, 5.3), xytext=(7, 4.6),
                arrowprops=dict(arrowstyle='->', color='#7B1FA2', lw=2))
    
    # Bottom: Idèle class group
    rect4 = plt.Rectangle((1.5, 0), 8, 1.8, fill=True,
                           facecolor='#E8F5E9', edgecolor='#4CAF50', linewidth=2)
    ax.add_patch(rect4)
    ax.text(5.5, 1.3, 'IDÈLE CLASS GROUP', ha='center', fontsize=11, fontweight='bold',
            color='#1B5E20')
    ax.text(5.5, 0.7, '𝕀_f(ℚ) / ℚˣ·U(n) ≅ (ℤ/nℤ)ˣ', ha='center', fontsize=10,
            fontstyle='italic')
    ax.text(5.5, 0.2, 'Product formula: ∏ |x|ᵥ = 1', ha='center', fontsize=9, color='#666')
    
    ax.annotate('', xy=(5.5, 2.3), xytext=(5.5, 1.9),
                arrowprops=dict(arrowstyle='->', color='#388E3C', lw=2))
    
    fig.suptitle('The GL(1) Langlands Correspondence over ℚ',
                 fontsize=16, fontweight='bold', y=0.98)
    
    plt.tight_layout()
    
    if filename:
        fig.savefig(filename, dpi=150, bbox_inches='tight')
    
    return save_fig_base64(fig)


def plot_product_formula(filename: str = None):
    """
    Visualize the product formula for several rationals.
    """
    from sympy import factorint
    
    rationals = [
        (360, 1, "360"),
        (12, 35, "12/35"),
        (100, 63, "100/63"),
        (7, 15, "7/15"),
    ]
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    for idx, (num, den, label) in enumerate(rationals):
        ax = axes[idx // 2][idx % 2]
        
        num_factors = factorint(abs(num))
        den_factors = factorint(den) if den > 1 else {}
        all_primes = sorted(set(num_factors.keys()) | set(den_factors.keys()))
        
        vals_num = [num_factors.get(p, 0) for p in all_primes]
        vals_den = [-den_factors.get(p, 0) for p in all_primes]
        vals_total = [vals_num[i] + vals_den[i] for i in range(len(all_primes))]
        
        x_pos = np.arange(len(all_primes))
        width = 0.25
        
        ax.bar(x_pos - width, vals_num, width, label='v_p(num)', color='#2196F3', alpha=0.8)
        ax.bar(x_pos, vals_den, width, label='-v_p(den)', color='#F44336', alpha=0.8)
        ax.bar(x_pos + width, vals_total, width, label='v_p(x)', color='#4CAF50', alpha=0.8)
        
        ax.set_xticks(x_pos)
        ax.set_xticklabels([str(p) for p in all_primes])
        ax.set_xlabel('Prime p')
        ax.set_ylabel('Valuation')
        ax.set_title(f'x = {label}')
        ax.legend(fontsize=8)
        ax.axhline(y=0, color='black', linewidth=0.5)
        ax.grid(True, alpha=0.3, axis='y')
    
    fig.suptitle('Product Formula: p-adic Valuations of Rationals\n'
                 'v_p(a/b) = v_p(a) - v_p(b), with ∏ p^{v_p(x)} = |x|',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    
    if filename:
        fig.savefig(filename, dpi=150, bbox_inches='tight')
    
    return save_fig_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    uri1 = plot_character_table(7, "character_table_7.png")
    print("✓ Character table (mod 7)")
    
    uri2 = plot_frobenius_map(7, "frobenius_map_7.png")
    print("✓ Frobenius map (mod 7)")
    
    uri3 = plot_gauss_sums(30, "gauss_sums.png")
    print("✓ Gauss sums")
    
    uri4 = plot_langlands_diagram("langlands_diagram.png")
    print("✓ Langlands diagram")
    
    uri5 = plot_product_formula("product_formula.png")
    print("✓ Product formula")
    
    print("\nAll visualizations saved.")
