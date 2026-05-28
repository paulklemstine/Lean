#!/usr/bin/env python3
"""
Visualization: Coset Control Complexity Across Finite Fields

Visualizes the number of cosets of standard subgroups needed to cover
each definable family, as a function of field size. The transfer
conjecture predicts this count remains bounded for polynomially
definable families — a key structural invariant.

Produces a heatmap showing coset counts for different subgroup types
and field sizes.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cart_product


def mat_mul_p(A, B, p):
    return [
        [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % p,
         (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % p],
        [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % p,
         (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % p],
    ]


def mat_tuple(A):
    return (A[0][0], A[0][1], A[1][0], A[1][1])


def coset_cover(A_set, H_set, p):
    uncovered = A_set.copy()
    count = 0
    while uncovered:
        rep_t = next(iter(uncovered))
        rep = [[rep_t[0], rep_t[1]], [rep_t[2], rep_t[3]]]
        coset = set()
        for h_t in H_set:
            h = [[h_t[0], h_t[1]], [h_t[2], h_t[3]]]
            prod = mat_mul_p(rep, h, p)
            coset.add(mat_tuple(prod))
        uncovered -= coset
        count += 1
    return count


def get_subgroups(p):
    borel = set()
    for a, b, d in cart_product(range(p), repeat=3):
        if (a * d) % p != 0:
            borel.add((a, b, 0, d))

    unipotent = set((1, b, 0, 1) for b in range(p))

    diagonal = set()
    for a, d in cart_product(range(p), repeat=2):
        if (a * d) % p != 0:
            diagonal.add((a, 0, 0, d))

    scalar = set((a, 0, 0, a) for a in range(1, p))

    return {'Borel': borel, 'Unipotent': unipotent,
            'Diagonal': diagonal, 'Scalar': scalar}


def family_unipotent_square(p):
    squares = set((t * t) % p for t in range(p))
    return [[[1, s], [0, 1]] for s in squares]


def family_circle(p):
    members = []
    for a in range(1, p):
        for t in range(p):
            if (a * a + t * t) % p == 1:
                members.append([[a, (a * t) % p], [0, a]])
    return members


def family_det_one_upper(p):
    members = []
    for a in range(1, p):
        d = pow(a, p - 2, p)
        for b in range(p):
            members.append([[a, b], [0, d]])
    return members


primes = [3, 5, 7, 11, 13]
families = [
    ("Unipotent (square entry)", family_unipotent_square),
    ("Scalar×unipotent (circle)", family_circle),
    ("Det-1 upper triangular", family_det_one_upper),
]
subgroup_names = ['Borel', 'Unipotent', 'Diagonal', 'Scalar']

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle("Coset Cover Counts: Standard Subgroups × Finite Fields\n"
             "Low, stable counts ⟹ uniform control (transfer conjecture)",
             fontsize=13, fontweight='bold')

for fam_idx, (fam_name, fam_func) in enumerate(families):
    ax = axes[fam_idx]

    # Compute coset data
    data = []
    valid_primes = []
    for p in primes:
        A = fam_func(p)
        if not A:
            continue
        valid_primes.append(p)
        A_set = set(mat_tuple(m) for m in A)
        subgroups = get_subgroups(p)
        row = []
        for sg_name in subgroup_names:
            c = coset_cover(A_set, subgroups[sg_name], p)
            row.append(c)
        data.append(row)

    if not data:
        ax.text(0.5, 0.5, 'No data', ha='center', va='center',
                transform=ax.transAxes)
        continue

    import numpy as np
    data_arr = np.array(data, dtype=float)

    im = ax.imshow(data_arr.T, aspect='auto', cmap='YlOrRd',
                   vmin=0, vmax=max(5, data_arr.max()))

    # Labels
    ax.set_xticks(range(len(valid_primes)))
    ax.set_xticklabels([str(p) for p in valid_primes])
    ax.set_yticks(range(len(subgroup_names)))
    ax.set_yticklabels(subgroup_names)
    ax.set_xlabel('Field size p')
    ax.set_title(fam_name, fontsize=10)

    # Annotate cells
    for i in range(len(valid_primes)):
        for j in range(len(subgroup_names)):
            ax.text(i, j, f'{int(data_arr[i, j])}',
                    ha='center', va='center', fontsize=10,
                    color='white' if data_arr[i, j] > 3 else 'black')

fig.colorbar(im, ax=axes, label='Cosets needed', shrink=0.8)
plt.tight_layout()
plt.savefig('coset_control.png', dpi=150, bbox_inches='tight')
print("Saved coset_control.png")
