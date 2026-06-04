"""
Holographic Code Tower — Numerical Demonstrations

Demonstrates the key results from the formal verification:
1. MDS tower construction and parameter verification
2. Curvature-Distance Correspondence (κ_n = 2κ_d)
3. Complementary recovery thresholds
4. Singleton entropy = Bekenstein-Hawking entropy
"""

def singleton_bound_check(n: int, k: int, d: int) -> bool:
    """Check if code [[n,k,d]] satisfies the quantum Singleton bound."""
    return k + 2 * d <= n + 2


def is_mds(n: int, k: int, d: int) -> bool:
    """Check if code [[n,k,d]] is MDS (saturates Singleton)."""
    return k + 2 * d == n + 2


def singleton_entropy(n: int, k: int) -> float:
    """Singleton entropy S = (n - k) / 2."""
    return (n - k) / 2


def bekenstein_hawking(area: float) -> float:
    """Bekenstein-Hawking entropy S = A/4 (in natural units where 4G = 1)."""
    return area / 4


def construct_mds_tower(k: int, d_sequence: list[int]) -> list[tuple[int, int, int]]:
    """Construct an MDS holographic code tower from a distance sequence."""
    tower = []
    for d in d_sequence:
        n = k + 2 * d - 2  # MDS condition
        tower.append((n, k, d))
    return tower


def tower_curvature(tower: list[tuple[int, int, int]], l: int) -> int:
    """Compute discrete curvature at interior layer l."""
    n_prev = tower[l - 1][0]
    n_curr = tower[l][0]
    n_next = tower[l + 1][0]
    return n_next - 2 * n_curr + n_prev


def distance_curvature(tower: list[tuple[int, int, int]], l: int) -> int:
    """Compute discrete curvature of the distance sequence at layer l."""
    d_prev = tower[l - 1][2]
    d_curr = tower[l][2]
    d_next = tower[l + 1][2]
    return d_next - 2 * d_curr + d_prev


def recon_threshold(n: int, d: int) -> int:
    """Minimum qubits needed for reconstruction: n - d + 1."""
    return n - d + 1


# === Demo 1: MDS Tower Construction ===
print("=" * 60)
print("Demo 1: MDS Tower Construction")
print("=" * 60)

k = 1  # 1 logical qubit
distances = [3, 4, 5, 6, 7, 8, 9, 10]
tower = construct_mds_tower(k, distances)

print(f"\nLogical qubits k = {k}")
print(f"{'Layer':>5} | {'n':>4} | {'k':>3} | {'d':>3} | {'MDS?':>5} | {'S_singleton':>12} | {'S_BH(2(n-k))':>14}")
print("-" * 60)
for i, (n, k_i, d) in enumerate(tower):
    s = singleton_entropy(n, k_i)
    s_bh = bekenstein_hawking(2 * (n - k_i))
    print(f"{i:>5} | {n:>4} | {k_i:>3} | {d:>3} | {is_mds(n, k_i, d)!s:>5} | {s:>12.1f} | {s_bh:>14.1f}")

# === Demo 2: Curvature-Distance Correspondence ===
print("\n" + "=" * 60)
print("Demo 2: Curvature-Distance Correspondence (κ_n = 2κ_d)")
print("=" * 60)

# Uniform tower (d increases by 1 each layer)
print("\n--- Uniform tower (d = 3,4,5,6,7,8): should have κ = 0 ---")
uniform_tower = construct_mds_tower(1, [3, 4, 5, 6, 7, 8])
for l in range(1, len(uniform_tower) - 1):
    kn = tower_curvature(uniform_tower, l)
    kd = distance_curvature(uniform_tower, l)
    print(f"  Layer {l}: κ_n = {kn}, 2·κ_d = {2*kd}, κ_n == 2·κ_d? {kn == 2*kd}")

# Non-uniform tower (d increases unevenly)
print("\n--- Non-uniform tower (d = 2,3,5,8,12): non-zero curvature ---")
nonuniform_tower = construct_mds_tower(1, [2, 3, 5, 8, 12])
for l in range(1, len(nonuniform_tower) - 1):
    kn = tower_curvature(nonuniform_tower, l)
    kd = distance_curvature(nonuniform_tower, l)
    print(f"  Layer {l}: κ_n = {kn}, 2·κ_d = {2*kd}, κ_n == 2·κ_d? {kn == 2*kd}")

# === Demo 3: Complementary Recovery ===
print("\n" + "=" * 60)
print("Demo 3: Complementary Recovery Thresholds")
print("=" * 60)

codes = [(5, 1, 3), (7, 1, 4), (9, 1, 5), (11, 1, 6)]
for n, k, d in codes:
    thresh = recon_threshold(n, d)
    compl = n - thresh
    print(f"  [[{n},{k},{d}]]: need ≥ {thresh} qubits to reconstruct, "
          f"complement has {compl} (< {d} = d) ✓")

# === Demo 4: Singleton = Bekenstein-Hawking ===
print("\n" + "=" * 60)
print("Demo 4: Singleton Entropy = Bekenstein-Hawking Entropy")
print("=" * 60)

for n, k, d in [(5, 1, 3), (7, 1, 4), (9, 1, 5), (15, 3, 7)]:
    s = singleton_entropy(n, k)
    area = 2 * (n - k)
    s_bh = bekenstein_hawking(area)
    print(f"  [[{n},{k},{d}]]: S_singleton = {s}, S_BH(area={area}) = {s_bh}, "
          f"d-1 = {d-1}, MDS? {is_mds(n, k, d)}")
    if is_mds(n, k, d):
        assert abs(s - (d - 1)) < 1e-10, "RT formula violated!"
        print(f"    → RT formula verified: S = d - 1 = {d-1} ✓")

# === Demo 5: Tower with positive curvature (accelerating growth) ===
print("\n" + "=" * 60)
print("Demo 5: Toric Code as a Code Tower")
print("=" * 60)

print("\nToric code family [[2L², 2, L]]:")
toric_tower = [(2*L**2, 2, L) for L in range(2, 8)]
print(f"{'L':>3} | {'n=2L²':>6} | {'k':>3} | {'d=L':>4} | {'Singleton?':>10}")
for n, k, d in toric_tower:
    print(f"{d:>3} | {n:>6} | {k:>3} | {d:>4} | {singleton_bound_check(n, k, d)!s:>10}")

print("\nToric tower curvature:")
for l in range(1, len(toric_tower) - 1):
    kn = tower_curvature(toric_tower, l)
    kd = distance_curvature(toric_tower, l)
    L = l + 2  # L starts at 2
    print(f"  L={L}: κ_n = {kn}, κ_d = {kd}, NOT MDS so κ_n ≠ 2κ_d in general")
    # For toric: n = 2L², so κ_n = 2(L+1)² - 2·2L² + 2(L-1)² = 4
    expected = 2*(L+1)**2 - 2*2*L**2 + 2*(L-1)**2
    print(f"    Direct: 2({L+1})² - 2·2·{L}² + 2({L-1})² = {expected}")

print("\n✅ All demos completed successfully!")


"""
Visualization: Holographic Code Tower Structure

Standalone script showing the tower parameters, curvature, and
the Bekenstein-Singleton correspondence.
"""

import matplotlib.pyplot as plt
import numpy as np


def construct_mds_tower(k, distances):
    """Construct MDS tower: n = k + 2d - 2."""
    return [(k + 2*d - 2, k, d) for d in distances]


def tower_curvature(tower, l):
    return tower[l+1][0] - 2*tower[l][0] + tower[l-1][0]


def distance_curvature(tower, l):
    return tower[l+1][2] - 2*tower[l][2] + tower[l-1][2]


# Build towers
k = 1
uniform_d = list(range(2, 12))
uniform_tower = construct_mds_tower(k, uniform_d)

accel_d = [2, 3, 5, 8, 12, 17, 23, 30]
accel_tower = construct_mds_tower(k, accel_d)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Block length vs depth for uniform and accelerating towers
ax = axes[0, 0]
layers_u = range(len(uniform_tower))
layers_a = range(len(accel_tower))
ax.plot(list(layers_u), [t[0] for t in uniform_tower], 'b-o', label='Uniform (κ=0)', linewidth=2)
ax.plot(list(layers_a), [t[0] for t in accel_tower], 'r-s', label='Accelerating (κ>0)', linewidth=2)
ax.set_xlabel('Layer depth l', fontsize=12)
ax.set_ylabel('Block length n(l)', fontsize=12)
ax.set_title('MDS Tower: Block Length vs Depth', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Plot 2: Curvature at each layer
ax = axes[0, 1]
curv_u = [tower_curvature(uniform_tower, l) for l in range(1, len(uniform_tower)-1)]
curv_a = [tower_curvature(accel_tower, l) for l in range(1, len(accel_tower)-1)]
dcurv_a = [2*distance_curvature(accel_tower, l) for l in range(1, len(accel_tower)-1)]

ax.bar([l-0.15 for l in range(1, len(uniform_tower)-1)], curv_u, 0.3,
       label='Uniform tower κ_n', color='blue', alpha=0.7)
ax.bar([l+0.15 for l in range(1, len(accel_tower)-1)], curv_a, 0.3,
       label='Accel tower κ_n', color='red', alpha=0.7)
ax.scatter(range(1, len(accel_tower)-1), dcurv_a, color='green', s=80,
           zorder=5, marker='D', label='2·κ_d (should equal κ_n)')
ax.axhline(y=0, color='black', linewidth=0.5)
ax.set_xlabel('Layer l', fontsize=12)
ax.set_ylabel('Curvature κ(l)', fontsize=12)
ax.set_title('Curvature-Distance Correspondence: κ_n = 2κ_d', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: Singleton entropy vs d-1 (RT formula)
ax = axes[1, 0]
ds = range(2, 15)
ns = [k + 2*d - 2 for d in ds]
s_singleton = [(n - k)/2 for n in ns]
s_rt = [d - 1 for d in ds]
ax.plot(list(ds), s_singleton, 'bo-', label='Singleton entropy (n-k)/2', linewidth=2, markersize=8)
ax.plot(list(ds), s_rt, 'r--', label='RT formula: d - 1', linewidth=2)
ax.set_xlabel('Code distance d', fontsize=12)
ax.set_ylabel('Entropy', fontsize=12)
ax.set_title('RT = Singleton for MDS Codes', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Plot 4: Page curve for the [[11, 1, 6]] code
ax = axes[1, 1]
n, k, d = 11, 1, 6
s_max = (n - k) / 2
sizes = range(0, n + 1)
page = [min(s, min(n - s, s_max)) for s in sizes]
ax.plot(list(sizes), page, 'g-o', linewidth=2, markersize=6, label='Page curve')
ax.axhline(y=s_max, color='red', linestyle='--', label=f'S_max = {s_max}')
ax.axvline(x=n/2, color='blue', linestyle=':', alpha=0.5, label=f'n/2 = {n/2}')
ax.fill_between(list(sizes), page, alpha=0.1, color='green')
ax.set_xlabel('Subregion size s', fontsize=12)
ax.set_ylabel('Entropy S(s)', fontsize=12)
ax.set_title(f'Page Curve for [[{n},{k},{d}]] Code', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('holographic_tower_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: holographic_tower_analysis.png")
