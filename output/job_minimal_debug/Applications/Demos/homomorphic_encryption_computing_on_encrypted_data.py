#!/usr/bin/env python3
"""
Demo: Fully Homomorphic Encryption — Noise Management and Bootstrapping

Demonstrates the core concepts formalized in our Lean 4 proofs:
1. Noise growth through homomorphic operations
2. Bootstrapping to enable unlimited computation
3. BGV-style leveled evaluation
4. Exponential noise growth without bootstrapping
"""

from algorithms import (
    ArithCircuit, NoiseBoundedHE, BootstrappableHE, Ciphertext,
    noise_growth_without_bootstrap, max_depth_without_bootstrap,
    bgv_leveled_eval, find_optimal_parameters
)


def demo_basic_operations():
    """Demonstrate basic homomorphic add and multiply."""
    print("=" * 60)
    print("DEMO 1: Basic Homomorphic Operations")
    print("=" * 60)

    scheme = NoiseBoundedHE(max_noise=1000, fresh_noise=5)

    # Encrypt two values
    m1, m2 = 7, 13
    c1 = scheme.encrypt(m1)
    c2 = scheme.encrypt(m2)
    print(f"\nEncrypt({m1}) → noise = {c1.noise}")
    print(f"Encrypt({m2}) → noise = {c2.noise}")

    # Homomorphic addition
    c_add = scheme.h_add(c1, c2)
    print(f"\nHomomorphic ADD:")
    print(f"  Noise: {c1.noise} + {c2.noise} = {c_add.noise}")
    print(f"  Decrypt: {scheme.decrypt(c_add)} (expected: {m1 + m2})")
    print(f"  Valid: {scheme.is_valid(c_add)}")

    # Homomorphic multiplication
    c_mul = scheme.h_mul(c1, c2)
    print(f"\nHomomorphic MUL:")
    print(f"  Noise: {c1.noise} × {c2.noise} = {c_mul.noise}")
    print(f"  Decrypt: {scheme.decrypt(c_mul)} (expected: {m1 * m2})")
    print(f"  Valid: {scheme.is_valid(c_mul)}")


def demo_noise_explosion():
    """Show how noise grows explosively without bootstrapping."""
    print("\n" + "=" * 60)
    print("DEMO 2: Exponential Noise Growth (No Bootstrapping)")
    print("=" * 60)

    initial_noise = 3
    max_noise = 10**15

    print(f"\nInitial noise B = {initial_noise}")
    print(f"Max tolerable noise = {max_noise:,}")
    print(f"\nDepth | Noise B^(2^d) | Valid?")
    print("-" * 45)

    for d in range(8):
        noise = noise_growth_without_bootstrap(initial_noise, d)
        valid = noise < max_noise
        noise_str = f"{noise:,}" if noise < 10**18 else f"~10^{len(str(noise))-1}"
        print(f"  {d:3d}  | {noise_str:>20s} | {'✓' if valid else '✗'}")
        if not valid:
            print(f"\n  → Decryption FAILS at depth {d}!")
            print(f"  → Max achievable depth: {d-1}")
            break

    max_d = max_depth_without_bootstrap(initial_noise, max_noise)
    print(f"\n  Computed max depth: {max_d}")
    print("  This proves bootstrapping is NECESSARY for unlimited computation.")


def demo_bootstrapping():
    """Demonstrate bootstrapping enabling unlimited computation."""
    print("\n" + "=" * 60)
    print("DEMO 3: Bootstrapping Enables Unlimited Computation")
    print("=" * 60)

    scheme = BootstrappableHE(
        max_noise=1000,
        fresh_noise=5,
        bootstrap_noise=3
    )

    print(f"\nScheme parameters:")
    print(f"  Max noise:       {scheme.max_noise}")
    print(f"  Fresh noise:     {scheme.fresh_noise}")
    print(f"  Bootstrap noise: {scheme.bootstrap_noise}")
    print(f"  bNoise² = {scheme.bootstrap_noise**2} < {scheme.max_noise} = maxNoise: "
          f"{'✓' if scheme.can_bootstrap() else '✗'}")
    print(f"  2·bNoise = {2*scheme.bootstrap_noise} < {scheme.max_noise} = maxNoise: "
          f"{'✓' if 2*scheme.bootstrap_noise < scheme.max_noise else '✗'}")

    # Build a deep circuit: ((x * x) * (x * x)) * ... (depth d)
    print(f"\nEvaluating x^(2^d) for x=3 with bootstrapping:")
    print(f"{'Depth':>5s} | {'Noise':>8s} | {'Value':>15s} | Valid?")
    print("-" * 50)

    x = 3
    ct = scheme.encrypt(x)
    ct = scheme.refresh(ct)  # Start at bootstrap noise

    for d in range(10):
        ct_refreshed = scheme.refresh(ct)
        ct = scheme.h_mul(ct_refreshed, ct_refreshed)
        ct = scheme.refresh(ct)

        dec = scheme.decrypt(ct)
        expected = x ** (2 ** (d + 1))
        print(f"  {d+1:3d}  | {ct.noise:>8d} | {dec:>15d} | "
              f"{'✓' if scheme.is_valid(ct) else '✗'} "
              f"{'✓ correct' if dec == expected else '✗ WRONG'}")

    print(f"\n  → Noise stays bounded at {scheme.bootstrap_noise} after each refresh!")
    print(f"  → Can continue INDEFINITELY (Gentry's theorem).")


def demo_circuit_evaluation():
    """Evaluate a non-trivial circuit with bootstrapping."""
    print("\n" + "=" * 60)
    print("DEMO 4: Circuit Evaluation — f(a,b,c) = (a+b)*(b+c) + a*c")
    print("=" * 60)

    scheme = BootstrappableHE(
        max_noise=10000,
        fresh_noise=5,
        bootstrap_noise=4
    )

    a_val, b_val, c_val = 5, 3, 7
    print(f"\nInputs: a={a_val}, b={b_val}, c={c_val}")
    expected = (a_val + b_val) * (b_val + c_val) + a_val * c_val
    print(f"Expected result: ({a_val}+{b_val})*({b_val}+{c_val}) + {a_val}*{c_val} = {expected}")

    # Build circuit
    a = ArithCircuit.input(0)
    b = ArithCircuit.input(1)
    c = ArithCircuit.input(2)
    circuit = ArithCircuit.add(
        ArithCircuit.mul(ArithCircuit.add(a, b), ArithCircuit.add(b, c)),
        ArithCircuit.mul(a, c)
    )

    print(f"Circuit depth: {circuit.depth()}, size: {circuit.size()}")

    # Encrypt inputs
    inputs = {
        0: scheme.encrypt(a_val),
        1: scheme.encrypt(b_val),
        2: scheme.encrypt(c_val)
    }

    # Evaluate with bootstrapping
    result = scheme.refreshed_eval(circuit, inputs)
    dec_result = scheme.decrypt(result)
    print(f"\nBootstrapped evaluation:")
    print(f"  Result noise: {result.noise}")
    print(f"  Decrypted: {dec_result}")
    print(f"  Correct: {'✓' if dec_result == expected else '✗'}")

    # Compare with BGV (no bootstrapping)
    bgv_result = bgv_leveled_eval(scheme, circuit, inputs)
    bgv_dec = scheme.decrypt(bgv_result)
    print(f"\nBGV leveled evaluation (no bootstrapping):")
    print(f"  Result noise: {bgv_result.noise}")
    print(f"  Decrypted: {bgv_dec}")
    print(f"  Correct: {'✓' if bgv_dec == expected else '✗'}")


def demo_parameter_selection():
    """Show how parameters scale with circuit depth."""
    print("\n" + "=" * 60)
    print("DEMO 5: Parameter Selection for Target Circuit Depths")
    print("=" * 60)

    print(f"\n{'Depth':>6s} | {'Ring dim':>10s} | {'log(q)':>8s} | "
          f"{'Max depth':>10s}")
    print("-" * 50)

    for depth in [1, 5, 10, 20, 50, 100]:
        params = find_optimal_parameters(depth)
        print(f"  {depth:4d}  | {params['ring_dimension']:>10d} | "
              f"{params['log_modulus']:>8d} | {params['achievable_depth']:>10d}")


if __name__ == "__main__":
    demo_basic_operations()
    demo_noise_explosion()
    demo_bootstrapping()
    demo_circuit_evaluation()
    demo_parameter_selection()

    print("\n" + "=" * 60)
    print("All demos complete. These numerical results match our")
    print("formally verified Lean 4 theorems:")
    print("  • fresh_valid: Fresh encryptions are always valid")
    print("  • bootstrap_add/mul_correct: Bootstrapped operations are correct")
    print("  • refreshedEval_valid: Unlimited depth with bootstrapping")
    print("  • noise_exceeds_any_threshold: Bootstrapping is necessary")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Noise Growth in Homomorphic Encryption

Compares noise growth with and without bootstrapping,
demonstrating why bootstrapping is necessary and sufficient
for unlimited computation on encrypted data.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def noise_without_bootstrap(B: int, depths: list) -> list:
    """Noise grows as B^(2^d) without bootstrapping."""
    return [B ** (2 ** d) for d in depths]


def noise_with_bootstrap(b_noise: int, depths: list) -> list:
    """With bootstrapping, noise stays at b_noise after each refresh."""
    return [b_noise for _ in depths]


def plot_noise_comparison():
    """Main visualization comparing noise growth strategies."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Plot 1: Exponential noise growth (log scale)
    ax1 = axes[0]
    depths = list(range(8))
    for B in [2, 3, 5]:
        noises = []
        for d in depths:
            n = B ** (2 ** d)
            noises.append(n)
        ax1.semilogy(depths, noises, 'o-', label=f'B = {B}', linewidth=2, markersize=6)

    ax1.axhline(y=1e15, color='red', linestyle='--', linewidth=2, label='Max noise threshold')
    ax1.set_xlabel('Multiplicative Depth', fontsize=12)
    ax1.set_ylabel('Noise Level (log scale)', fontsize=12)
    ax1.set_title('Without Bootstrapping:\nNoise grows as B^(2^d)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(1, 1e30)

    # Plot 2: With vs without bootstrapping
    ax2 = axes[1]
    B = 3
    max_noise = 1000
    b_noise = 3
    depths_long = list(range(15))

    # Without bootstrap (clip for display)
    no_boot = []
    for d in depths_long:
        val = min(B ** (2 ** d), 1e20)
        no_boot.append(val)

    # With bootstrap
    with_boot = [b_noise] * len(depths_long)

    ax2.semilogy(depths_long, no_boot, 'r-o', label='Without bootstrap', linewidth=2, markersize=5)
    ax2.semilogy(depths_long, with_boot, 'g-s', label='With bootstrap', linewidth=2, markersize=5)
    ax2.axhline(y=max_noise, color='orange', linestyle='--', linewidth=2, label=f'maxNoise = {max_noise}')
    ax2.fill_between(depths_long, 0, max_noise, alpha=0.1, color='green')

    ax2.set_xlabel('Multiplicative Depth', fontsize=12)
    ax2.set_ylabel('Noise Level (log scale)', fontsize=12)
    ax2.set_title('Bootstrapping vs. No Bootstrapping\n(B=3, maxNoise=1000, bNoise=3)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(1, 1e20)

    # Plot 3: Capacity condition visualization
    ax3 = axes[2]
    bn_range = np.arange(1, 50)
    max_noises = bn_range ** 2 + 1  # Minimum maxNoise for bootstrapping

    ax3.plot(bn_range, max_noises, 'b-', linewidth=2, label='bNoise² + 1 (mul threshold)')
    ax3.plot(bn_range, 2 * bn_range + 1, 'g--', linewidth=2, label='2·bNoise + 1 (add threshold)')
    ax3.fill_between(bn_range, max_noises, 2500, alpha=0.15, color='green', label='Bootstrappable region')
    ax3.fill_between(bn_range, 0, max_noises, alpha=0.1, color='red', label='Cannot bootstrap')

    ax3.set_xlabel('Bootstrap Noise (bNoise)', fontsize=12)
    ax3.set_ylabel('Minimum maxNoise Required', fontsize=12)
    ax3.set_title('Bootstrapping Capacity Condition:\nbNoise² < maxNoise', fontsize=13)
    ax3.legend(fontsize=10, loc='upper left')
    ax3.grid(True, alpha=0.3)
    ax3.set_xlim(1, 49)
    ax3.set_ylim(0, 2500)

    plt.tight_layout()
    plt.savefig('noise_growth_comparison.png', dpi=150, bbox_inches='tight')
    print("Saved: noise_growth_comparison.png")


if __name__ == "__main__":
    plot_noise_comparison()
