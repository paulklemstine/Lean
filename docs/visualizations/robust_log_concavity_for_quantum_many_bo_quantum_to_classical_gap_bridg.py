#!/usr/bin/env python3
"""
Visualization: Quantum-to-Classical Gap Bridge

Plots the quantum spectral gap, surrogate Lorentzian gap, and classical
conductance estimate for the transverse-field Ising model as a function
of the transverse field strength h. This visualizes the core conjecture
that all three gaps are polynomially related.
"""

import numpy as np
import matplotlib.pyplot as plt

# ── Hamiltonian construction (self-contained) ─────────────────────────

def kron_chain(ops):
    result = ops[0]
    for op in ops[1:]:
        result = np.kron(result, op)
    return result

def tfim_hamiltonian(n, J, h):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    I2 = np.eye(2, dtype=complex)
    Zop = np.array([[1,0],[0,-1]], dtype=complex)
    Xop = np.array([[0,1],[1,0]], dtype=complex)
    for i in range(n - 1):
        ops = [I2]*n; ops[i] = Zop; ops[i+1] = Zop
        H -= J * kron_chain(ops)
    for i in range(n):
        ops = [I2]*n; ops[i] = Xop
        H -= h * kron_chain(ops)
    return H

def analyze(H, n):
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    gap = float(evals[idx[1]] - evals[idx[0]])
    psi = evecs[:, idx[0]]
    probs = np.abs(psi)**2
    dim = 2**n

    # Lorentzian surrogate: LC_ratio * min_mass * dim
    mm = np.min(probs)
    mx = np.max(probs)
    lc = (mm/mx)**2 if mx > 0 else 0
    lor_gap = lc * mm * dim

    # Classical conductance
    best_cond = float('inf')
    sp = np.sort(probs)[::-1]
    for k in range(1, dim):
        A = set(i for i in range(dim) if probs[i] >= sp[k-1])
        mu_A = sum(probs[i] for i in A)
        if mu_A <= 1e-15 or mu_A >= 1-1e-15:
            continue
        bdry = 0.0
        for x in A:
            for bit in range(n):
                y = x ^ (1 << bit)
                if y not in A:
                    bdry += probs[x]
                    break
        cond = bdry / (mu_A * (1 - mu_A))
        best_cond = min(best_cond, cond)
    cl_gap = best_cond if best_cond < float('inf') else 0.0

    return gap, lor_gap, cl_gap

# ── Main plot ─────────────────────────────────────────────────────────

n = 6
J = 1.0
h_vals = np.linspace(0.1, 3.0, 40)

quantum_gaps = []
lor_gaps = []
cl_gaps = []

for h in h_vals:
    H = tfim_hamiltonian(n, J, h)
    qg, lg, cg = analyze(H, n)
    quantum_gaps.append(qg)
    lor_gaps.append(lg)
    cl_gaps.append(cg)

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

# Top panel: all three gaps
ax1.plot(h_vals, quantum_gaps, 'b-o', markersize=3, label='Quantum gap Δ(H)', linewidth=2)
ax1.plot(h_vals, lor_gaps, 'r-s', markersize=3, label='Lorentzian surrogate', linewidth=2)
ax1.plot(h_vals, cl_gaps, 'g-^', markersize=3, label='Classical conductance Φ', linewidth=2)
ax1.axvline(x=1.0, color='gray', linestyle='--', alpha=0.7, label='Critical point h/J=1')
ax1.set_ylabel('Gap value', fontsize=12)
ax1.set_title(f'Quantum-to-Classical Gap Bridge ({n}-site TFIM)', fontsize=14)
ax1.legend(fontsize=10)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Bottom panel: gap ratios
qg = np.array(quantum_gaps)
lg = np.array(lor_gaps)
cg = np.array(cl_gaps)
with np.errstate(divide='ignore', invalid='ignore'):
    ratio_ql = np.where(lg > 1e-15, qg / lg, np.nan)
    ratio_qc = np.where(cg > 1e-15, qg / cg, np.nan)

ax2.plot(h_vals, ratio_ql, 'purple', marker='o', markersize=3,
         label='Δ_quantum / Δ_Lorentzian', linewidth=2)
ax2.plot(h_vals, ratio_qc, 'orange', marker='s', markersize=3,
         label='Δ_quantum / Δ_classical', linewidth=2)
ax2.axvline(x=1.0, color='gray', linestyle='--', alpha=0.7)
ax2.set_xlabel('Transverse field h/J', fontsize=12)
ax2.set_ylabel('Gap ratio', fontsize=12)
ax2.set_title('Gap Ratios (should be ≤ poly(n) if conjecture holds)', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('gap_bridge.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved gap_bridge.png")
