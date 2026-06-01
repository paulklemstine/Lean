#!/usr/bin/env python3
"""
Digital Immortality: Information-Theoretic Bounds on Mind Uploading
Numerical demonstrations of the key results.
"""
import math

def connectome_count(n: int, k: int) -> int:
    """Number of distinct connectomes with n neurons and k weight levels."""
    return k ** (n * n)

def bekenstein_bound(R: float, E: float) -> float:
    """Maximum bits in a sphere of radius R (m) with energy E (J).
    In natural units (hbar=1): 2*pi*R*E / ln(2)."""
    return 2 * math.pi * R * E / math.log(2)

def neural_info_defect(n: int, k: int, k_prime: int) -> float:
    """Bits lost when coarsening from k to k_prime weight levels."""
    if k <= 0 or k_prime <= 0:
        return float('inf')
    return n * n * (math.log2(k) - math.log2(k_prime))

def min_description_length(n: int, k: int) -> float:
    """Minimum bits to describe a connectome: n^2 * log2(k)."""
    return n * n * math.log2(k)

# === Demo 1: Connectome space sizes ===
print("=" * 60)
print("DEMO 1: Connectome Space Cardinality")
print("=" * 60)
for n in [2, 3, 5, 10]:
    for k in [2, 4, 8]:
        count = connectome_count(n, k)
        bits = min_description_length(n, k)
        print(f"  n={n:3d}, k={k}: |ConnectomeSpace| = {count:>20,}, min bits = {bits:.1f}")

# === Demo 2: Human brain parameters ===
print("\n" + "=" * 60)
print("DEMO 2: Human Brain Information Content")
print("=" * 60)
n_human = 86_000_000_000  # 86 billion neurons
k_human = 256  # 8-bit weight precision

bits_human = min_description_length(n_human, k_human)
print(f"  Neurons:           {n_human:,}")
print(f"  Weight levels:     {k_human}")
print(f"  Min description:   {bits_human:.2e} bits")
print(f"                   = {bits_human / 8:.2e} bytes")
print(f"                   = {bits_human / 8 / 1e18:.2e} exabytes")

# === Demo 3: Bekenstein bound ===
print("\n" + "=" * 60)
print("DEMO 3: Bekenstein Bound for the Brain")
print("=" * 60)
R_brain = 0.1  # meters
M_brain = 1.4  # kg
c = 3e8  # speed of light, m/s
E_brain = M_brain * c**2  # mass-energy in joules
hbar = 1.054571817e-34  # reduced Planck constant, J·s

# Physical Bekenstein bound (with hbar)
bek_physical = 2 * math.pi * R_brain * E_brain / (hbar * math.log(2))
print(f"  Brain radius:      {R_brain} m")
print(f"  Brain mass:        {M_brain} kg")
print(f"  Brain energy:      {E_brain:.2e} J")
print(f"  Bekenstein bound:  {bek_physical:.2e} bits")
print(f"  Connectome needs:  {bits_human:.2e} bits")
print(f"  Ratio (Bek/Conn):  {bek_physical / bits_human:.2e}")

if bek_physical > bits_human:
    print("  → Physics PERMITS lossless upload (Bekenstein > Connectome)")
else:
    print("  → Physics FORBIDS lossless upload (Bekenstein < Connectome)")

# === Demo 4: Neural Information Defect ===
print("\n" + "=" * 60)
print("DEMO 4: Neural Information Defect (NID)")
print("=" * 60)
print("  Coarsening synaptic weights from k to k' levels:")
for k, kp in [(256, 128), (256, 64), (256, 16), (256, 4), (256, 2)]:
    nid_per_synapse = math.log2(k) - math.log2(kp)
    nid_total = neural_info_defect(n_human, k, kp)
    print(f"  k={k} → k'={kp:3d}: NID/synapse = {nid_per_synapse:.1f} bits, "
          f"total NID = {nid_total:.2e} bits")

# Verify additivity
print("\n  Additivity check: NID(256→16) = NID(256→64) + NID(64→16)?")
nid_direct = neural_info_defect(100, 256, 16)
nid_step1 = neural_info_defect(100, 256, 64)
nid_step2 = neural_info_defect(100, 64, 16)
print(f"    Direct:   {nid_direct:.6f}")
print(f"    Two-step: {nid_step1 + nid_step2:.6f}")
print(f"    Match:    {abs(nid_direct - (nid_step1 + nid_step2)) < 1e-10}")

# === Demo 5: Incompressibility ===
print("\n" + "=" * 60)
print("DEMO 5: Incompressibility of Small Connectomes")
print("=" * 60)
for n in [2, 3, 4, 5]:
    total = connectome_count(n, 2)
    compressible = 2 ** (n * n // 2)  # those describable in half the bits
    pct = 100 * compressible / total
    print(f"  n={n}: total={total:>12,}, compressible(< {n*n//2} bits)={compressible:>8,}, "
          f"fraction={pct:.4f}%")

# === Demo 6: Scaling comparison ===
print("\n" + "=" * 60)
print("DEMO 6: Quadratic vs Linear Scaling")
print("=" * 60)
print(f"  {'n':>8} {'n (linear)':>14} {'n² (quadratic)':>16} {'2^(n²)':>20}")
for n in [2, 5, 10, 20, 50, 100]:
    print(f"  {n:>8} {n:>14,} {n*n:>16,} {'2^' + str(n*n):>20}")

print("\n✓ All demonstrations completed successfully.")


#!/usr/bin/env python3
"""Visualization: Quadratic scaling of connectome description length."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def min_description_length(n, k):
    return n * n * math.log2(k)

def bekenstein_bound_bits(R, M, hbar=1.054571817e-34, c=2.998e8):
    E = M * c**2
    return 2 * math.pi * R * E / (hbar * math.log(2))

neurons = np.logspace(1, 11, 200)
k_values = [2, 8, 64, 256]
colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Description length vs neuron count
ax1 = axes[0]
for k, color in zip(k_values, colors):
    bits = [n**2 * math.log2(k) for n in neurons]
    ax1.loglog(neurons, bits, color=color, linewidth=2, label=f'k={k}')

bek = bekenstein_bound_bits(0.1, 1.4)
ax1.axhline(y=bek, color='purple', linestyle='--', linewidth=2,
            label=f'Bekenstein bound\n(brain-sized)')
ax1.set_xlabel('Number of Neurons (n)', fontsize=12)
ax1.set_ylabel('Minimum Description Length (bits)', fontsize=12)
ax1.set_title('Connectome Information Requirement\nvs. Neuron Count', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(10, 1e11)

# Plot 2: Compression ratio
ax2 = axes[1]
n_vals = range(2, 12)
for k, color in zip([2, 4, 8], colors[:3]):
    ratios = []
    for n in n_vals:
        total_bits = n * n * math.log2(k)
        half_bits = total_bits / 2
        ratio = 2**half_bits / k**(n*n)
        ratios.append(ratio)
    ax2.semilogy(list(n_vals), ratios, 'o-', color=color, linewidth=2,
                 markersize=6, label=f'k={k}')

ax2.set_xlabel('Number of Neurons (n)', fontsize=12)
ax2.set_ylabel('Fraction Compressible to Half Length', fontsize=12)
ax2.set_title('Incompressibility: Fraction of\nCompressible Connectomes', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('connectome_scaling.png', dpi=150, bbox_inches='tight')
print("Saved connectome_scaling.png")


#!/usr/bin/env python3
"""Visualization: Neural Information Defect heatmap."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def neural_info_defect(n, k, k_prime):
    if k <= 0 or k_prime <= 0:
        return 0
    return n * n * (math.log2(k) - math.log2(k_prime))

k_values = [2, 4, 8, 16, 32, 64, 128, 256]
n_neurons = [10, 50, 100, 500, 1000, 5000, 10000]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

# Heatmap: NID per synapse for different k → k' transitions
k_from = 256
nid_matrix = np.zeros((len(k_values), len(k_values)))
for i, k1 in enumerate(k_values):
    for j, k2 in enumerate(k_values):
        if k2 <= k1:
            nid_matrix[i, j] = math.log2(k1) - math.log2(k2)
        else:
            nid_matrix[i, j] = np.nan

im = ax1.imshow(nid_matrix, cmap='YlOrRd', aspect='auto', origin='lower')
ax1.set_xticks(range(len(k_values)))
ax1.set_xticklabels(k_values)
ax1.set_yticks(range(len(k_values)))
ax1.set_yticklabels(k_values)
ax1.set_xlabel("Target precision k'", fontsize=12)
ax1.set_ylabel("Source precision k", fontsize=12)
ax1.set_title("NID per Synapse (bits)\nk → k' coarsening", fontsize=14)
plt.colorbar(im, ax=ax1, label='Bits lost per synapse')

for i in range(len(k_values)):
    for j in range(len(k_values)):
        if not np.isnan(nid_matrix[i, j]):
            ax1.text(j, i, f'{nid_matrix[i,j]:.0f}',
                    ha='center', va='center', fontsize=8,
                    color='white' if nid_matrix[i,j] > 4 else 'black')

# Bar chart: Total NID for different brain sizes
k_original = 256
k_target = 16
nids = [neural_info_defect(n, k_original, k_target) for n in n_neurons]

bars = ax2.bar(range(len(n_neurons)), nids, color='#F44336', alpha=0.8)
ax2.set_xticks(range(len(n_neurons)))
ax2.set_xticklabels([str(n) for n in n_neurons], rotation=45)
ax2.set_xlabel('Number of Neurons', fontsize=12)
ax2.set_ylabel('Total NID (bits)', fontsize=12)
ax2.set_title(f'Total Information Lost\nCoarsening {k_original}→{k_target} levels', fontsize=14)
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('nid_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved nid_heatmap.png")
