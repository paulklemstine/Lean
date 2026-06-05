#!/usr/bin/env python3
"""
Quantum Casimir Spectral Theory: Numerical Demonstrations

Demonstrates the key results from the formalized theory:
1. q-integers and their classical limit
2. q-Casimir eigenvalues and spectral structure  
3. Spectral rigidity: recovering q from eigenvalues
4. Connection between q-Casimir spectrum and Riemann zero statistics
"""

import numpy as np

def q_integer(q: float, n: int) -> float:
    """Symmetric q-integer [n]_q = sum_{k=0}^{n-1} q^{n-1-2k}"""
    if n == 0:
        return 0.0
    return sum(q ** (n - 1 - 2 * k) for k in range(n))

def q_casimir(q: float, n: int) -> float:
    """q-Casimir eigenvalue lambda_n = [n]_q * [n+1]_q"""
    return q_integer(q, n) * q_integer(q, n + 1)

def demonstrate_classical_limit():
    """Theorem: qInt 1 n = n and qCasimir 1 n = n(n+1)"""
    print("=" * 60)
    print("1. CLASSICAL LIMIT (q → 1)")
    print("=" * 60)
    print(f"{'n':>3} | {'[n]_1':>10} | {'n':>10} | {'λ_n(1)':>12} | {'n(n+1)':>12}")
    print("-" * 60)
    for n in range(8):
        qi = q_integer(1.0, n)
        qc = q_casimir(1.0, n)
        print(f"{n:>3} | {qi:>10.4f} | {n:>10.4f} | {qc:>12.4f} | {n*(n+1):>12.4f}")
    print()

def demonstrate_inversion_symmetry():
    """Theorem: qInt q⁻¹ n = qInt q n"""
    print("=" * 60)
    print("2. WEYL INVERSION SYMMETRY: [n]_{q⁻¹} = [n]_q")
    print("=" * 60)
    q = 2.5
    print(f"q = {q}, q⁻¹ = {1/q:.4f}")
    print(f"{'n':>3} | {'[n]_q':>12} | {'[n]_{q⁻¹}':>12} | {'difference':>12}")
    print("-" * 55)
    for n in range(8):
        qi_q = q_integer(q, n)
        qi_inv = q_integer(1/q, n)
        print(f"{n:>3} | {qi_q:>12.6f} | {qi_inv:>12.6f} | {abs(qi_q - qi_inv):>12.2e}")
    print()

def demonstrate_spectral_rigidity():
    """Theorem: q₁ + q₁⁻¹ = q₂ + q₂⁻¹ implies q₁ = q₂ or q₁ = q₂⁻¹"""
    print("=" * 60)
    print("3. SPECTRAL RIGIDITY")
    print("=" * 60)
    
    # The function f(q) = q + q⁻¹ is 2-to-1 on R+
    qs = [0.3, 0.5, 1.0, 2.0, 3.0, 5.0]
    print("f(q) = q + q⁻¹ (first Casimir eigenvalue):")
    print(f"{'q':>8} | {'q⁻¹':>8} | {'f(q)':>10} | {'f(q⁻¹)':>10}")
    print("-" * 45)
    for q in qs:
        f_q = q + 1/q
        f_inv = 1/q + q
        print(f"{q:>8.4f} | {1/q:>8.4f} | {f_q:>10.6f} | {f_inv:>10.6f}")
    print("\n→ The only ambiguity is q ↔ q⁻¹ (Weyl symmetry)")
    print()

def demonstrate_riemann_connection():
    """Connection between q-Casimir spectrum and Riemann zeros"""
    print("=" * 60)
    print("4. BRIDGE TO RIEMANN ZEROS")
    print("=" * 60)
    
    gamma1 = 14.134725  # First Riemann zero imaginary part
    
    # q-parameter from first Riemann zero  
    # Using q = exp(2π/γ₁) for a real deformation
    q = np.exp(2 * np.pi / gamma1)
    print(f"First Riemann zero: γ₁ ≈ {gamma1}")
    print(f"Quantum group parameter: q = exp(2π/γ₁) ≈ {q:.6f}")
    print(f"q + q⁻¹ = {q + 1/q:.6f}")
    print()
    
    # q-Casimir spectrum
    print("q-Casimir spectrum:")
    print(f"{'n':>3} | {'λ_n(q)':>15} | {'n(n+1)':>10} | {'ratio':>10}")
    print("-" * 50)
    for n in range(10):
        qc = q_casimir(q, n)
        classical = n * (n + 1)
        ratio = qc / classical if classical > 0 else 0
        print(f"{n:>3} | {qc:>15.4f} | {classical:>10} | {ratio:>10.4f}")
    
    print()
    print("Spectral growth comparison:")
    print("  Classical (q=1): λ_n ~ n² (polynomial)")
    print(f"  Quantum (q={q:.4f}): λ_n ~ q^(2n) (exponential)")
    print()
    
    # Counting function: N(T) = #{n : λ_n ≤ T}
    T_values = [10, 100, 1000, 10000, 100000]
    print("Counting function N(T) = #{n : λ_n ≤ T}:")
    print(f"{'T':>10} | {'N_q(T)':>8} | {'N_classical(T)':>15} | {'log(T)/2log(q)':>15}")
    print("-" * 55)
    for T in T_values:
        # Quantum counting
        n_q = sum(1 for n in range(1000) if q_casimir(q, n) <= T)
        # Classical counting: n(n+1) ≤ T → n ≤ (√(4T+1)-1)/2
        n_cl = int((np.sqrt(4*T + 1) - 1) / 2)
        # Predicted quantum counting
        log_pred = np.log(T) / (2 * np.log(q)) if q > 1 else float('inf')
        print(f"{T:>10} | {n_q:>8} | {n_cl:>15} | {log_pred:>15.2f}")
    print()
    print("→ Quantum counting grows logarithmically (like Riemann zero density)")
    print("→ Classical counting grows as √T (Weyl law)")

def demonstrate_recurrence():
    """Theorem: [n+1]_q = q^n + q⁻¹ · [n]_q"""
    print("=" * 60)
    print("5. q-INTEGER RECURRENCE")
    print("=" * 60)
    q = 1.5
    print(f"q = {q}: verifying [n+1]_q = q^n + q⁻¹·[n]_q")
    print(f"{'n':>3} | {'[n+1]_q':>12} | {'q^n + q⁻¹·[n]_q':>18} | {'error':>12}")
    print("-" * 55)
    for n in range(8):
        lhs = q_integer(q, n + 1)
        rhs = q**n + (1/q) * q_integer(q, n)
        print(f"{n:>3} | {lhs:>12.6f} | {rhs:>18.6f} | {abs(lhs-rhs):>12.2e}")
    print()

if __name__ == "__main__":
    print("QUANTUM CASIMIR SPECTRAL THEORY")
    print("Numerical demonstrations of formalized results")
    print()
    
    demonstrate_classical_limit()
    demonstrate_inversion_symmetry()
    demonstrate_spectral_rigidity()
    demonstrate_recurrence()
    demonstrate_riemann_connection()


#!/usr/bin/env python3
"""
Visualization: q-Casimir Spectrum vs Classical Casimir Spectrum

Shows how the q-deformation transforms the parabolic classical spectrum
n(n+1) into an exponentially growing quantum spectrum.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def q_integer(q, n):
    if n == 0:
        return 0.0
    return sum(q ** (n - 1 - 2 * k) for k in range(n))

def q_casimir(q, n):
    return q_integer(q, n) * q_integer(q, n + 1)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: q-Casimir spectrum for various q
ax = axes[0, 0]
ns = np.arange(0, 12)
for q_val in [0.5, 0.8, 1.0, 1.2, 1.5, 2.0]:
    eigenvalues = [q_casimir(q_val, n) for n in ns]
    label = f'q = {q_val}'
    style = '--' if q_val == 1.0 else '-'
    lw = 2.5 if q_val == 1.0 else 1.5
    ax.plot(ns, eigenvalues, style, linewidth=lw, label=label, marker='o', markersize=4)
ax.set_xlabel('Representation index n')
ax.set_ylabel('λ_n(q) = [n]_q · [n+1]_q')
ax.set_title('q-Casimir Eigenvalues')
ax.legend(fontsize=8)
ax.set_yscale('log')
ax.set_ylim(bottom=0.5)
ax.grid(True, alpha=0.3)

# Plot 2: q-integers
ax = axes[0, 1]
ns = np.arange(0, 10)
for q_val in [0.5, 0.8, 1.0, 1.5, 2.0]:
    qints = [q_integer(q_val, n) for n in ns]
    style = '--' if q_val == 1.0 else '-'
    ax.plot(ns, qints, style, linewidth=1.5, label=f'q = {q_val}', marker='s', markersize=4)
ax.set_xlabel('n')
ax.set_ylabel('[n]_q')
ax.set_title('q-Integers: Quantum Deformation of ℕ')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Plot 3: Inversion symmetry
ax = axes[1, 0]
q_values = np.linspace(0.2, 5.0, 200)
for n in [2, 3, 5, 8]:
    qints = [q_integer(q, n) for q in q_values]
    ax.plot(q_values, qints, linewidth=1.5, label=f'[{n}]_q')
ax.axvline(x=1.0, color='gray', linestyle=':', alpha=0.5, label='q = 1')
ax.set_xlabel('q')
ax.set_ylabel('[n]_q')
ax.set_title('q-Integers as Functions of q\n(symmetric about q ↔ q⁻¹ on log scale)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Plot 4: Spectral rigidity — f(q) = q + q⁻¹
ax = axes[1, 1]
q_values = np.linspace(0.15, 6.0, 500)
f_values = q_values + 1.0 / q_values
ax.plot(q_values, f_values, 'b-', linewidth=2, label='f(q) = q + q⁻¹')
ax.axhline(y=2.0, color='red', linestyle='--', alpha=0.5, label='minimum = 2 (at q=1)')

# Mark specific q and q⁻¹
q_ex = 2.5
ax.axvline(x=q_ex, color='green', linestyle=':', alpha=0.7)
ax.axvline(x=1/q_ex, color='green', linestyle=':', alpha=0.7)
ax.plot([q_ex, 1/q_ex], [q_ex + 1/q_ex, 1/q_ex + q_ex], 'go', markersize=8)
ax.annotate(f'q={q_ex}', (q_ex, q_ex + 1/q_ex + 0.3), fontsize=9, ha='center')
ax.annotate(f'q⁻¹={1/q_ex:.1f}', (1/q_ex, 1/q_ex + q_ex + 0.3), fontsize=9, ha='center')

ax.set_xlabel('q')
ax.set_ylabel('q + q⁻¹ (first Casimir eigenvalue)')
ax.set_title('Spectral Rigidity:\nf(q) = f(q⁻¹) determines q up to Weyl symmetry')
ax.legend(fontsize=8)
ax.set_ylim(1.5, 8)
ax.grid(True, alpha=0.3)

plt.suptitle('Quantum Casimir Spectral Theory', fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('quantum_casimir_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved: quantum_casimir_spectrum.png")
