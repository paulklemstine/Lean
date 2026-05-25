#!/usr/bin/env python3
"""
Visualization 1: Contraction Bilinearity Heatmap

Visualizes the bilinearity of tensor contraction by showing how
contract(αA + βB, v) decomposes as α·contract(A,v) + β·contract(B,v).
The heatmap shows the error (which should be zero) across a grid of
(α, β) values, confirming bilinearity for tensors of various orders.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

d = 4  # dimension
fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

orders = [(2, 1, "Matrix × Vector → Vector"),
          (3, 1, "Order-3 × Vector → Matrix"),
          (3, 2, "Order-3 × Matrix → Vector")]

for ax, (jk, k, title) in zip(axes, orders):
    T1 = np.random.randn(*(d,)*jk)
    T2 = np.random.randn(*(d,)*jk)
    v = np.random.randn(*(d,)*k)

    j = jk - k
    all_idx = ''.join(chr(ord('a') + i) for i in range(jk))
    v_idx = ''.join(chr(ord('a') + i) for i in range(j, jk))
    o_idx = ''.join(chr(ord('a') + i) for i in range(j))
    sub = f"{all_idx},{v_idx}->{o_idx}" if j > 0 else f"{all_idx},{v_idx}->"

    alphas = np.linspace(-2, 2, 50)
    betas = np.linspace(-2, 2, 50)
    errors = np.zeros((50, 50))

    c1 = np.einsum(sub, T1, v)
    c2 = np.einsum(sub, T2, v)

    for i, a in enumerate(alphas):
        for jj, b in enumerate(betas):
            combined = np.einsum(sub, a * T1 + b * T2, v)
            linear = a * c1 + b * c2
            errors[i, jj] = np.max(np.abs(combined - linear))

    im = ax.imshow(errors, extent=[-2, 2, -2, 2], origin='lower',
                   cmap='RdYlGn_r', vmin=0, vmax=1e-13, aspect='auto')
    ax.set_xlabel('β', fontsize=12)
    ax.set_ylabel('α', fontsize=12)
    ax.set_title(title, fontsize=11)
    plt.colorbar(im, ax=ax, label='Max |error|')

fig.suptitle('Bilinearity of Tensor Contraction: |contract(αA+βB, v) - α·contract(A,v) - β·contract(B,v)|',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('viz_bilinearity.png', dpi=150, bbox_inches='tight')
print("Saved viz_bilinearity.png")
