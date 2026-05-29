#!/usr/bin/env python3
"""
Applications of Holographic Prime Theory

Demonstrates real-world applications and connections:
1. Cryptographic key generation analysis via holographic entropy
2. Signal processing via prime-based Fourier analysis
3. Error detection via von Mangoldt codes
4. Statistical mechanics of prime distributions
"""

import math
from typing import List, Tuple


def sieve_of_eratosthenes(n: int) -> List[int]:
    """Generate all primes up to n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


# ============================================================
# Application 1: Cryptographic Entropy Analysis
# ============================================================

def rsa_holographic_entropy(bit_length: int = 2048) -> dict:
    """Analyze the holographic entropy of RSA key generation.

    In RSA, we choose two large primes p, q and compute n = pq.
    The holographic perspective says each prime contributes
    log(p) bits of boundary entropy. The total key entropy
    is bounded by the holographic entropy.

    Args:
        bit_length: RSA key length in bits

    Returns:
        Dictionary with entropy analysis
    """
    # Approximate prime size
    prime_bits = bit_length // 2
    # By PNT, primes near 2^k are spaced about k*ln(2) apart
    prime_size = 2 ** prime_bits
    spacing = prime_bits * math.log(2)

    # Boundary entropy per prime
    boundary_entropy_p = math.log(prime_size)  # ≈ prime_bits * ln(2)
    boundary_entropy_q = boundary_entropy_p

    # Total holographic entropy (two boundary components)
    total_entropy = boundary_entropy_p + boundary_entropy_q

    # Information-theoretic key strength
    key_bits = total_entropy / math.log(2)

    return {
        "bit_length": bit_length,
        "prime_bits": prime_bits,
        "boundary_entropy_per_prime": boundary_entropy_p,
        "total_holographic_entropy_nats": total_entropy,
        "effective_key_bits": key_bits,
        "prime_gap_estimate": spacing,
        "security_margin": key_bits / bit_length,
    }


# ============================================================
# Application 2: Prime-Based Signal Decomposition
# ============================================================

def prime_fourier_decomposition(signal: List[float], num_primes: int = 10) -> dict:
    """Decompose a signal using prime-indexed frequencies.

    Inspired by the Euler product: just as ζ(s) decomposes into
    prime factors, a signal can be analyzed at prime frequencies.
    The "holographic spectrum" shows the contribution of each
    prime frequency to the total signal energy.

    Args:
        signal: Input signal as list of floats
        num_primes: Number of prime frequencies to use

    Returns:
        Dictionary with decomposition data
    """
    n = len(signal)
    primes = sieve_of_eratosthenes(num_primes * 10)[:num_primes]

    # Compute DFT at prime frequencies
    components = {}
    total_energy = sum(x**2 for x in signal)

    for p in primes:
        # Frequency k = p corresponds to period n/p
        cos_sum = sum(signal[t] * math.cos(2 * math.pi * p * t / n) for t in range(n))
        sin_sum = sum(signal[t] * math.sin(2 * math.pi * p * t / n) for t in range(n))
        amplitude = math.sqrt(cos_sum**2 + sin_sum**2) / n
        energy = (cos_sum**2 + sin_sum**2) / n**2
        components[p] = {
            "amplitude": amplitude,
            "energy": energy,
            "energy_fraction": energy / total_energy if total_energy > 0 else 0,
            "boundary_weight": math.log(p),  # von Mangoldt weight
        }

    return {
        "signal_length": n,
        "total_energy": total_energy,
        "prime_components": components,
        "primes_used": primes,
    }


# ============================================================
# Application 3: Multiplicative Error Detection
# ============================================================

def von_mangoldt_checksum(n: int) -> Tuple[float, float, bool]:
    """Use the von Mangoldt reconstruction formula as a checksum.

    For any positive integer n, ∑_{d|n} Λ(d) = log(n).
    This can be used as an integrity check for the factorization of n.

    Returns:
        (computed_sum, expected_log, match)
    """
    def von_mangoldt(k: int) -> float:
        if k <= 1:
            return 0.0
        for p in range(2, k + 1):
            if p * p > k:
                break
            if k % p == 0:
                m = k
                while m % p == 0:
                    m //= p
                return math.log(p) if m == 1 else 0.0
        return math.log(k)

    divs = []
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)

    computed = sum(von_mangoldt(d) for d in divs)
    expected = math.log(n)
    return computed, expected, abs(computed - expected) < 1e-10


# ============================================================
# Application 4: Thermodynamic Analysis of Primes
# ============================================================

def prime_thermodynamics(beta_range: List[float], N: int = 10000) -> List[dict]:
    """Compute thermodynamic quantities of the primon gas.

    The prime partition function Z(β) = ∏_p (1-p^{-β})^{-1} = ζ(β)
    defines a statistical mechanical system. We compute:
    - Free energy: F = -log Z = -log ζ(β)
    - Internal energy: U = -d/dβ log Z
    - Entropy: S = β U - F
    - Heat capacity: C = dU/dβ

    Args:
        beta_range: List of inverse temperatures
        N: Prime bound for computation

    Returns:
        List of thermodynamic data dictionaries
    """
    primes = sieve_of_eratosthenes(N)
    results = []

    for beta in beta_range:
        if beta <= 1:
            results.append({"beta": beta, "status": "divergent"})
            continue

        # Partition function
        log_Z = sum(-math.log(1 - p ** (-beta)) for p in primes)

        # Internal energy: U = ∑_p p^(-β) log(p) / (1 - p^(-β))
        U = sum(p**(-beta) * math.log(p) / (1 - p**(-beta)) for p in primes)

        # Free energy
        F = -log_Z

        # Entropy
        S = beta * U + log_Z

        # Heat capacity (numerical derivative)
        dbeta = 0.001
        log_Z_plus = sum(-math.log(1 - p ** (-(beta + dbeta))) for p in primes)
        U_plus = sum(
            p**(-(beta + dbeta)) * math.log(p) / (1 - p**(-(beta + dbeta)))
            for p in primes
        )
        C = (U_plus - U) / dbeta

        results.append({
            "beta": beta,
            "log_Z": log_Z,
            "free_energy": F,
            "internal_energy": U,
            "entropy": S,
            "heat_capacity": C,
        })

    return results


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    APPLICATIONS OF HOLOGRAPHIC PRIME THEORY            ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Application 1: RSA analysis
    print("\n" + "=" * 60)
    print("APPLICATION 1: RSA Holographic Entropy Analysis")
    print("=" * 60)
    for bits in [1024, 2048, 4096]:
        result = rsa_holographic_entropy(bits)
        print(f"\nRSA-{bits}:")
        print(f"  Boundary entropy per prime: {result['boundary_entropy_per_prime']:.1f} nats")
        print(f"  Effective key strength: {result['effective_key_bits']:.1f} bits")
        print(f"  Security margin: {result['security_margin']:.4f}")

    # Application 2: Signal decomposition
    print("\n" + "=" * 60)
    print("APPLICATION 2: Prime Frequency Decomposition")
    print("=" * 60)
    # Create a test signal: sum of sinusoids at prime frequencies
    n = 256
    signal = [
        math.sin(2 * math.pi * 2 * t / n) + 0.5 * math.sin(2 * math.pi * 5 * t / n)
        for t in range(n)
    ]
    result = prime_fourier_decomposition(signal, 8)
    print(f"\nSignal: sin(2πt·2/256) + 0.5·sin(2πt·5/256)")
    print(f"Prime frequency analysis:")
    for p, data in result["prime_components"].items():
        print(f"  p={p}: amplitude={data['amplitude']:.4f}, "
              f"energy fraction={data['energy_fraction']:.4f}")

    # Application 3: Checksum
    print("\n" + "=" * 60)
    print("APPLICATION 3: Von Mangoldt Integrity Check")
    print("=" * 60)
    for n in [360, 2520, 5040, 10080]:
        computed, expected, match = von_mangoldt_checksum(n)
        print(f"  n={n}: ∑Λ(d|n)={computed:.8f}, log(n)={expected:.8f}, "
              f"integrity={'PASS' if match else 'FAIL'}")

    # Application 4: Thermodynamics
    print("\n" + "=" * 60)
    print("APPLICATION 4: Primon Gas Thermodynamics")
    print("=" * 60)
    betas = [1.1, 1.5, 2.0, 3.0, 5.0, 10.0]
    thermo = prime_thermodynamics(betas, N=5000)
    print(f"\n{'β':>6} {'log Z':>10} {'F':>10} {'U':>10} {'S':>10} {'C':>10}")
    print("-" * 58)
    for r in thermo:
        if "status" in r:
            print(f"{r['beta']:>6.2f}  {'DIVERGENT':>48}")
        else:
            print(f"{r['beta']:>6.2f} {r['log_Z']:>10.4f} {r['free_energy']:>10.4f} "
                  f"{r['internal_energy']:>10.4f} {r['entropy']:>10.4f} "
                  f"{r['heat_capacity']:>10.4f}")


#!/usr/bin/env python3
"""
Holographic Primes: Interactive Demonstration

Demonstrates the prime number AdS/CFT correspondence numerically:
1. Euler product convergence (holographic factorization)
2. Functional equation verification (holographic duality)
3. Tropical-algebraic bound verification
4. Chebyshev function vs bulk volume
5. Von Mangoldt reconstruction
"""

import math
from typing import List, Tuple


def sieve_of_eratosthenes(n: int) -> List[int]:
    """Generate all primes up to n using the Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def local_partition(p: int, beta: float) -> float:
    """Local partition function Z_p(β) = (1 - p^(-β))⁻¹"""
    return 1.0 / (1.0 - p ** (-beta))


def finite_euler_product(N: int, beta: float) -> float:
    """Compute ∏_{p≤N} (1 - p^(-β))⁻¹"""
    primes = sieve_of_eratosthenes(N)
    product = 1.0
    for p in primes:
        product *= local_partition(p, beta)
    return product


def chebyshev_theta(n: int) -> float:
    """Compute θ(n) = ∑_{p≤n} log(p)"""
    primes = sieve_of_eratosthenes(n)
    return sum(math.log(p) for p in primes)


def von_mangoldt(n: int) -> float:
    """Compute Λ(n): log(p) if n = p^k, else 0"""
    if n <= 1:
        return 0.0
    # Check if n is a prime power
    for p in range(2, n + 1):
        if p * p > n:
            break
        if n % p == 0:
            # p divides n; check if n is a power of p
            m = n
            while m % p == 0:
                m //= p
            if m == 1:
                return math.log(p)
            else:
                return 0.0
    # n is prime
    return math.log(n)


def divisors(n: int) -> List[int]:
    """Return all divisors of n."""
    divs = []
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)


def demo_euler_product():
    """Demonstrate the Euler product convergence (Theorem 1)."""
    print("=" * 60)
    print("HOLOGRAPHIC FACTORIZATION: Euler Product Convergence")
    print("ζ(s) = ∏_p (1 - p^(-s))⁻¹")
    print("=" * 60)

    zeta_2 = math.pi**2 / 6  # ζ(2) = π²/6

    print(f"\nTarget: ζ(2) = π²/6 ≈ {zeta_2:.10f}")
    print(f"{'N':>8} {'# primes':>10} {'Product':>15} {'Error':>12}")
    print("-" * 50)

    for N in [10, 50, 100, 500, 1000, 5000, 10000]:
        product = finite_euler_product(N, 2.0)
        primes = sieve_of_eratosthenes(N)
        error = abs(product - zeta_2) / zeta_2 * 100
        print(f"{N:>8} {len(primes):>10} {product:>15.10f} {error:>11.6f}%")

    # Other s values
    print("\n\nConvergence for various s (N = 10000):")
    print(f"{'s':>5} {'Product':>15} {'Known ζ(s)':>15}")
    print("-" * 40)
    known = {
        2: math.pi**2 / 6,
        4: math.pi**4 / 90,
        6: math.pi**6 / 945,
    }
    for s in [2, 3, 4, 5, 6]:
        prod = finite_euler_product(10000, s)
        if s in known:
            print(f"{s:>5} {prod:>15.10f} {known[s]:>15.10f}")
        else:
            print(f"{s:>5} {prod:>15.10f}")


def demo_tropical_bound():
    """Demonstrate the tropical-algebraic bound (Theorem 3)."""
    print("\n" + "=" * 60)
    print("TROPICAL-ALGEBRAIC BRIDGE")
    print("exp(∑ p⁻ᵝ) ≤ ∏(1 - p⁻ᵝ)⁻¹")
    print("=" * 60)

    for beta in [1.5, 2.0, 3.0, 5.0]:
        print(f"\nβ = {beta}:")
        print(f"{'N':>8} {'exp(∑ p⁻ᵝ)':>15} {'∏(1-p⁻ᵝ)⁻¹':>15} {'Ratio':>10} {'Valid':>6}")
        print("-" * 58)

        for N in [10, 100, 1000, 10000]:
            primes = sieve_of_eratosthenes(N)
            prime_sum = sum(p ** (-beta) for p in primes)
            lhs = math.exp(prime_sum)
            rhs = finite_euler_product(N, beta)
            ratio = rhs / lhs
            valid = "✓" if lhs <= rhs + 1e-10 else "✗"
            print(f"{N:>8} {lhs:>15.8f} {rhs:>15.8f} {ratio:>10.6f} {valid:>6}")


def demo_chebyshev():
    """Demonstrate the Chebyshev function (boundary area vs bulk volume)."""
    print("\n" + "=" * 60)
    print("VOLUME-AREA CORRESPONDENCE: Chebyshev θ(x) vs x")
    print("=" * 60)

    print(f"\n{'x':>8} {'θ(x)':>12} {'x':>8} {'θ(x)/x':>10}")
    print("-" * 42)

    for x in [10, 50, 100, 500, 1000, 5000, 10000, 50000, 100000]:
        theta = chebyshev_theta(x)
        ratio = theta / x
        print(f"{x:>8} {theta:>12.2f} {x:>8} {ratio:>10.6f}")

    print("\nPNT prediction: θ(x)/x → 1 as x → ∞")


def demo_von_mangoldt():
    """Demonstrate the von Mangoldt reconstruction formula (Theorem 5)."""
    print("\n" + "=" * 60)
    print("HOLOGRAPHIC RECONSTRUCTION: ∑_{d|n} Λ(d) = log(n)")
    print("=" * 60)

    print(f"\n{'n':>6} {'∑ Λ(d)':>12} {'log(n)':>12} {'Match':>8}")
    print("-" * 42)

    for n in [2, 3, 4, 6, 8, 10, 12, 15, 24, 30, 60, 100, 360, 1000]:
        divs = divisors(n)
        mangoldt_sum = sum(von_mangoldt(d) for d in divs)
        log_n = math.log(n)
        match = "✓" if abs(mangoldt_sum - log_n) < 1e-10 else "✗"
        print(f"{n:>6} {mangoldt_sum:>12.8f} {log_n:>12.8f} {match:>8}")


def demo_entropy():
    """Demonstrate the divergence of prime reciprocals."""
    print("\n" + "=" * 60)
    print("HOLOGRAPHIC ENTROPY: ∑ 1/p → ∞")
    print("=" * 60)

    print(f"\n{'N':>8} {'∑_{p≤N} 1/p':>15} {'log log N':>12} {'Ratio':>10}")
    print("-" * 48)

    for N in [10, 100, 1000, 10000, 100000, 1000000]:
        primes = sieve_of_eratosthenes(N)
        recip_sum = sum(1.0 / p for p in primes)
        loglog = math.log(math.log(N))
        ratio = recip_sum / loglog
        print(f"{N:>8} {recip_sum:>15.8f} {loglog:>12.8f} {ratio:>10.6f}")

    print("\nMertens' theorem: ∑_{p≤N} 1/p ~ log log N + M")
    print(f"where M ≈ 0.2615 (Meissel-Mertens constant)")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║        HOLOGRAPHIC PRIMES: Prime Number AdS/CFT        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_euler_product()
    demo_tropical_bound()
    demo_chebyshev()
    demo_von_mangoldt()
    demo_entropy()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("Key result: The prime number system exhibits holographic")
    print("structure — boundary data (primes) encodes bulk data")
    print("(all integers) via the Euler product factorization.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 3: The Prime Hologram — Boundary Area vs Bulk Volume

Visualizes the Chebyshev function θ(x) = ∑_{p≤x} log(p) (boundary area)
against x (bulk volume), the von Mangoldt reconstruction formula,
and the prime reciprocal divergence (infinite boundary capacity).
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def von_mangoldt(n):
    if n <= 1:
        return 0.0
    for p in range(2, n + 1):
        if p * p > n:
            break
        if n % p == 0:
            m = n
            while m % p == 0:
                m //= p
            return math.log(p) if m == 1 else 0.0
    return math.log(n)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("The Prime Hologram: Boundary-Bulk Correspondence",
             fontsize=16, fontweight='bold')

# Plot 1: Chebyshev θ(x) vs x
ax1 = axes[0, 0]
x_max = 10000
primes = sieve_of_eratosthenes(x_max)

# Compute θ(x) at integer points (using cumulative sum)
theta_vals = np.zeros(x_max + 1)
for p in primes:
    theta_vals[p:] += math.log(p)

x_range = np.arange(1, x_max + 1)
ax1.plot(x_range, theta_vals[1:], 'b-', linewidth=1.5,
         label='θ(x) (boundary area)')
ax1.plot(x_range, x_range, 'r--', linewidth=1.5,
         label='x (bulk volume)')
ax1.fill_between(x_range, theta_vals[1:], x_range, alpha=0.1, color='blue')
ax1.set_xlabel('x', fontsize=11)
ax1.set_ylabel('Value', fontsize=11)
ax1.set_title('θ(x) ∼ x: Boundary Area ≈ Bulk Volume (PNT)', fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: θ(x)/x ratio
ax2 = axes[0, 1]
ratios = theta_vals[1:] / x_range
ax2.plot(x_range[9:], ratios[9:], 'g-', linewidth=1.5)
ax2.axhline(y=1, color='r', linestyle='--', linewidth=1, label='PNT limit')
ax2.set_xlabel('x', fontsize=11)
ax2.set_ylabel('θ(x) / x', fontsize=11)
ax2.set_title('Boundary/Bulk Ratio → 1', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0.7, 1.1)

# Plot 3: Von Mangoldt reconstruction for first 100 integers
ax3 = axes[1, 0]
n_range = range(1, 101)
lambda_vals = [von_mangoldt(n) for n in n_range]

# Color code: primes (red), prime powers (orange), composites (gray)
colors = []
for n in n_range:
    lam = von_mangoldt(n)
    if lam == 0:
        colors.append('#cccccc')
    elif n in primes:
        colors.append('#e74c3c')
    else:
        colors.append('#f39c12')

ax3.bar(list(n_range), lambda_vals, color=colors, width=0.8)
ax3.set_xlabel('n', fontsize=11)
ax3.set_ylabel('Λ(n)', fontsize=11)
ax3.set_title('Von Mangoldt Λ(n): boundary weights', fontsize=12)

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#e74c3c', label='Prime p: Λ(p)=log(p)'),
    Patch(facecolor='#f39c12', label='Prime power pᵏ: Λ(pᵏ)=log(p)'),
    Patch(facecolor='#cccccc', label='Other: Λ(n)=0'),
]
ax3.legend(handles=legend_elements, fontsize=9, loc='upper right')
ax3.grid(True, alpha=0.3, axis='y')

# Plot 4: Prime reciprocal sum divergence
ax4 = axes[1, 1]
N_values = np.logspace(1, 5, 200).astype(int)
N_values = sorted(set(N_values))
all_primes_large = sieve_of_eratosthenes(max(N_values))

recip_sums = []
loglog_vals = []
for N in N_values:
    ps = [p for p in all_primes_large if p <= N]
    recip_sums.append(sum(1.0/p for p in ps) if ps else 0)
    loglog_vals.append(math.log(math.log(N)) if N > 1 else 0)

ax4.plot(N_values, recip_sums, 'b-', linewidth=2,
         label='∑_{p≤N} 1/p (holographic entropy)')
ax4.plot(N_values, loglog_vals, 'r--', linewidth=2,
         label='log log N')
# Mertens constant
M = 0.2615  # Meissel-Mertens constant
mertens_vals = [math.log(math.log(N)) + M if N > 1 else 0 for N in N_values]
ax4.plot(N_values, mertens_vals, 'g:', linewidth=1.5,
         label='log log N + M (Mertens)')
ax4.set_xscale('log')
ax4.set_xlabel('N', fontsize=11)
ax4.set_ylabel('Partial sum', fontsize=11)
ax4.set_title('∑ 1/p → ∞: Infinite Boundary Capacity', fontsize=12)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('prime_hologram.png', dpi=150, bbox_inches='tight')
print("Saved: prime_hologram.png")


#!/usr/bin/env python3
"""
Visualization 1: Euler Product Convergence — Holographic Factorization

Visualizes how the finite Euler product ∏_{p≤N} (1 - p^(-s))^(-1)
converges to ζ(s) as N grows, showing the holographic factorization
in action: the boundary (primes) progressively reconstructs the bulk (ζ).
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def finite_euler_product(primes_list, s):
    product = 1.0
    for p in primes_list:
        product *= 1.0 / (1.0 - p ** (-s))
    return product


# Generate primes
all_primes = sieve_of_eratosthenes(5000)

# Compute convergence for s = 2
zeta_2 = math.pi**2 / 6
N_values = list(range(2, 200))
products = []
for N in N_values:
    primes_up_to_N = [p for p in all_primes if p <= N]
    products.append(finite_euler_product(primes_up_to_N, 2))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Holographic Factorization: Euler Product Convergence",
             fontsize=16, fontweight='bold')

# Plot 1: Convergence to ζ(2)
ax1 = axes[0, 0]
ax1.plot(N_values, products, 'b-', linewidth=1.5, label='∏_{p≤N} (1-p⁻²)⁻¹')
ax1.axhline(y=zeta_2, color='r', linestyle='--', linewidth=1, label=f'ζ(2) = π²/6 ≈ {zeta_2:.4f}')
ax1.set_xlabel('N (boundary cutoff)', fontsize=11)
ax1.set_ylabel('Finite Euler product', fontsize=11)
ax1.set_title('Boundary → Bulk reconstruction', fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Relative error
ax2 = axes[0, 1]
errors = [abs(p - zeta_2) / zeta_2 for p in products]
ax2.semilogy(N_values, errors, 'g-', linewidth=1.5)
# Mark where each new prime is added
prime_positions = [i for i, N in enumerate(N_values) if N in all_primes]
prime_errors = [errors[i] for i in prime_positions]
prime_Ns = [N_values[i] for i in prime_positions]
ax2.scatter(prime_Ns[:30], prime_errors[:30], c='red', s=20, zorder=5,
           label='New prime added')
ax2.set_xlabel('N', fontsize=11)
ax2.set_ylabel('Relative error', fontsize=11)
ax2.set_title('Error drops at each prime', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Individual prime contributions (log scale)
ax3 = axes[1, 0]
contributions = [math.log(1.0 / (1.0 - p ** (-2))) for p in all_primes[:50]]
ax3.bar(range(len(contributions)), contributions, color='steelblue', alpha=0.7)
ax3.set_xlabel('Prime index', fontsize=11)
ax3.set_ylabel('log Z_p(2) = -log(1 - p⁻²)', fontsize=11)
ax3.set_title('Individual boundary contributions (bulk weights)', fontsize=12)
prime_labels = [str(p) for p in all_primes[:50]]
ax3.set_xticks(range(0, 50, 5))
ax3.set_xticklabels([prime_labels[i] for i in range(0, 50, 5)], fontsize=8)
ax3.grid(True, alpha=0.3, axis='y')

# Plot 4: Convergence for multiple s values
ax4 = axes[1, 1]
s_values = [1.5, 2.0, 3.0, 4.0]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
for s, color in zip(s_values, colors):
    prods = []
    Ns = list(range(2, 500, 5))
    for N in Ns:
        ps = [p for p in all_primes if p <= N]
        prods.append(finite_euler_product(ps, s) if ps else 1.0)
    ax4.plot(Ns, prods, color=color, linewidth=1.5, label=f's = {s}')

ax4.set_xlabel('N', fontsize=11)
ax4.set_ylabel('Finite Euler product', fontsize=11)
ax4.set_title('Convergence at different "depths" s', fontsize=12)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('euler_product_convergence.png', dpi=150, bbox_inches='tight')
print("Saved: euler_product_convergence.png")


#!/usr/bin/env python3
"""
Visualization 2: Tropical-Algebraic Bridge

Visualizes the tropical prime bound:
  exp(∑ p⁻ᵝ) ≤ ∏(1 - p⁻ᵝ)⁻¹ = ζ(β)

Shows how the "tropicalized" (additive/logarithmic) partition function
underestimates the true (multiplicative) partition function, and how
the gap between them encodes higher-order prime correlations.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


primes = sieve_of_eratosthenes(50000)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Tropical-Algebraic Bridge: Additive vs Multiplicative Structure",
             fontsize=16, fontweight='bold')

# Plot 1: exp(∑ p⁻ᵝ) vs ζ(β) as function of β
ax1 = axes[0, 0]
betas = np.linspace(1.05, 6.0, 200)
tropical_vals = []
euler_vals = []

for beta in betas:
    prime_sum = sum(p ** (-beta) for p in primes)
    tropical_vals.append(math.exp(prime_sum))
    log_euler = sum(-math.log(1 - p**(-beta)) for p in primes)
    euler_vals.append(math.exp(log_euler))

ax1.plot(betas, euler_vals, 'b-', linewidth=2, label='ζ(β) = ∏(1-p⁻ᵝ)⁻¹')
ax1.plot(betas, tropical_vals, 'r--', linewidth=2, label='exp(∑ p⁻ᵝ)')
ax1.fill_between(betas, tropical_vals, euler_vals, alpha=0.15, color='purple',
                 label='Gap (higher correlations)')
ax1.set_xlabel('β (inverse temperature)', fontsize=11)
ax1.set_ylabel('Partition function', fontsize=11)
ax1.set_title('Tropical underestimates Algebraic', fontsize=12)
ax1.set_ylim(0, 15)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: The ratio ζ(β) / exp(∑ p⁻ᵝ) = exp(∑_{k≥2} P(kβ)/k)
ax2 = axes[0, 1]
ratios = [e / t for e, t in zip(euler_vals, tropical_vals)]
ax2.plot(betas, ratios, 'purple', linewidth=2)
ax2.axhline(y=1, color='gray', linestyle=':', linewidth=1)
ax2.set_xlabel('β', fontsize=11)
ax2.set_ylabel('ζ(β) / exp(∑ p⁻ᵝ)', fontsize=11)
ax2.set_title('Ratio: higher-order prime correlations', fontsize=12)
ax2.grid(True, alpha=0.3)
ax2.annotate('β → 1⁺: ratio grows\n(stronger correlations)',
            xy=(1.2, ratios[5]), fontsize=9,
            xytext=(2.5, ratios[5] + 0.1),
            arrowprops=dict(arrowstyle='->', color='purple'))

# Plot 3: The key inequality exp(x) ≤ 1/(1-x) for individual primes
ax3 = axes[1, 0]
x_vals = np.linspace(0, 0.95, 200)
exp_vals = np.exp(x_vals)
inv_vals = 1.0 / (1.0 - x_vals)

ax3.plot(x_vals, exp_vals, 'r-', linewidth=2, label='exp(x)')
ax3.plot(x_vals, inv_vals, 'b-', linewidth=2, label='(1-x)⁻¹')
ax3.fill_between(x_vals, exp_vals, inv_vals, alpha=0.15, color='green',
                 label='Gap = tropical deficit')

# Mark prime values for β=2
for p in [2, 3, 5, 7, 11]:
    x = p ** (-2)
    ax3.plot(x, math.exp(x), 'ro', markersize=8)
    ax3.plot(x, 1/(1-x), 'bs', markersize=8)
    ax3.annotate(f'p={p}', xy=(x, 1/(1-x)), fontsize=8,
                xytext=(x+0.02, 1/(1-x)+0.1))

ax3.set_xlabel('x = p⁻ᵝ', fontsize=11)
ax3.set_ylabel('Value', fontsize=11)
ax3.set_title('Fundamental inequality (β=2 marked)', fontsize=12)
ax3.legend(fontsize=10)
ax3.set_xlim(-0.02, 0.5)
ax3.set_ylim(0.9, 2.2)
ax3.grid(True, alpha=0.3)

# Plot 4: Cumulative log contributions
ax4 = axes[1, 1]
N_vals = list(range(2, 200))
cum_tropical = []
cum_euler = []

for N in N_vals:
    ps = [p for p in primes if p <= N]
    if not ps:
        cum_tropical.append(0)
        cum_euler.append(0)
        continue
    cum_tropical.append(sum(p**(-2) for p in ps))
    cum_euler.append(sum(-math.log(1 - p**(-2)) for p in ps))

ax4.plot(N_vals, cum_euler, 'b-', linewidth=2,
         label='∑ -log(1-p⁻²) (Euler)')
ax4.plot(N_vals, cum_tropical, 'r--', linewidth=2,
         label='∑ p⁻² (Tropical)')
ax4.fill_between(N_vals, cum_tropical, cum_euler, alpha=0.15, color='orange')
ax4.set_xlabel('N (boundary cutoff)', fontsize=11)
ax4.set_ylabel('Cumulative log-contribution', fontsize=11)
ax4.set_title('Cumulative: Euler vs Tropical (β=2)', fontsize=12)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_algebraic_bridge.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_algebraic_bridge.png")
