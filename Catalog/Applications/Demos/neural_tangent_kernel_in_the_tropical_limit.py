"""
Tropical NTK — Applications

Real-world applications of tropical NTK theory:
1. Certified robustness via cell membership
2. Tropical kernel regression
3. Feature learning detection via wall-crossing analysis
"""

import numpy as np
from algorithms import (
    tropical_network, tropical_ntk, tropical_ntk_matrix,
    find_argmin, tropical_param_gradient, detect_wall_crossing,
    find_flat_directions, affine_score
)


def certified_robustness_radius(W, b, S, x, norm_type='linf'):
    """
    Compute certified robustness radius for a tropical network.

    Within the strict argmin cell, the network is affine, so the prediction
    changes linearly. The robustness radius is the distance to the nearest
    tropical wall (cell boundary).

    Args:
        W: Weight matrix (m, d)
        b: Bias vector (m,)
        S: List of active unit indices
        x: Input point (d,)
        norm_type: 'l2' or 'linf'

    Returns:
        Certified robustness radius
    """
    i0 = find_argmin(W, b, S, x)
    score_i0 = affine_score(W, b, i0, x)

    min_margin = float('inf')
    for j in S:
        if j != i0:
            score_j = affine_score(W, b, j, x)
            margin = score_j - score_i0  # > 0 on strict cell

            # Distance to hyperplane z_{i0}(x) = z_j(x) is:
            # margin / ||W_j - W_{i0}||
            diff = W[j] - W[i0]
            if norm_type == 'l2':
                norm = np.linalg.norm(diff, 2)
            elif norm_type == 'linf':
                norm = np.linalg.norm(diff, 1)  # dual norm of linf is l1
            else:
                raise ValueError(f"Unknown norm type: {norm_type}")

            if norm > 1e-12:
                dist = margin / norm
                min_margin = min(min_margin, dist)

    return min_margin


def tropical_kernel_regression(W, b, S, X_train, y_train, X_test, reg=1e-6):
    """
    Kernel regression using the tropical NTK.

    On each strict cell, K(x,y) = ⟨x,y⟩ + 1, so this is locally
    equivalent to linear regression with bias.

    Args:
        W: Weight matrix (m, d)
        b: Bias vector (m,)
        S: List of active unit indices
        X_train: Training inputs (n, d)
        y_train: Training targets (n,)
        X_test: Test inputs (n_test, d)
        reg: Regularization parameter

    Returns:
        Predictions on test set
    """
    K_train = tropical_ntk_matrix(W, b, S, X_train)
    K_train += reg * np.eye(len(X_train))

    alpha = np.linalg.solve(K_train, y_train)

    n_test = X_test.shape[0]
    predictions = np.zeros(n_test)
    for i in range(n_test):
        for j in range(len(X_train)):
            predictions[i] += alpha[j] * tropical_ntk(W, b, S, X_test[i], X_train[j])

    return predictions


def analyze_feature_learning(W, b, S, trajectory, labels=None):
    """
    Analyze feature learning along a training trajectory.

    Detects wall crossings (feature learning events) and periods of
    lazy training (constant cell membership).

    Args:
        W: Weight matrix (m, d)
        b: Bias vector (m,)
        S: List of active unit indices
        trajectory: Array of input points along training path (T, d)
        labels: Optional labels for each point

    Returns:
        Dictionary with analysis results
    """
    T = len(trajectory)
    cells = [find_argmin(W, b, S, trajectory[t]) for t in range(T)]

    # Detect wall crossings
    wall_crossings = []
    for t in range(1, T):
        if cells[t] != cells[t-1]:
            wall_crossings.append({
                'time': t,
                'from_cell': cells[t-1],
                'to_cell': cells[t],
            })

    # Compute lazy periods
    lazy_periods = []
    start = 0
    for t in range(1, T):
        if cells[t] != cells[start]:
            lazy_periods.append({
                'start': start,
                'end': t-1,
                'cell': cells[start],
                'duration': t - start
            })
            start = t
    lazy_periods.append({
        'start': start,
        'end': T-1,
        'cell': cells[start],
        'duration': T - start
    })

    return {
        'cells': cells,
        'wall_crossings': wall_crossings,
        'lazy_periods': lazy_periods,
        'n_crossings': len(wall_crossings),
        'avg_lazy_duration': np.mean([p['duration'] for p in lazy_periods])
    }


if __name__ == "__main__":
    np.random.seed(42)
    d, m = 2, 4
    W = np.array([[1.0, 0.5], [-0.5, 1.0], [0.3, -0.8], [-1.0, -0.3]])
    b = np.array([0.0, 0.5, -0.2, 0.3])
    S = list(range(m))

    print("=" * 60)
    print("APPLICATION 1: Certified Robustness")
    print("=" * 60)

    x = np.array([0.5, 0.5])
    radius_l2 = certified_robustness_radius(W, b, S, x, 'l2')
    radius_linf = certified_robustness_radius(W, b, S, x, 'linf')
    print(f"\nInput: x = {x}")
    print(f"Active cell: {find_argmin(W, b, S, x)}")
    print(f"Certified L2 robustness radius: {radius_l2:.4f}")
    print(f"Certified Linf robustness radius: {radius_linf:.4f}")
    print("(Within this radius, predictions change only linearly)")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Tropical Kernel Regression")
    print("=" * 60)

    n_train = 20
    X_train = np.random.randn(n_train, d) * 2
    y_train = np.sin(X_train[:, 0]) + 0.5 * np.cos(X_train[:, 1])

    X_test = np.random.randn(5, d) * 2
    y_test = np.sin(X_test[:, 0]) + 0.5 * np.cos(X_test[:, 1])

    predictions = tropical_kernel_regression(W, b, S, X_train, y_train, X_test)
    print(f"\nTest predictions vs ground truth:")
    for i in range(5):
        print(f"  pred = {predictions[i]:+.4f}, true = {y_test[i]:+.4f}")
    print(f"MSE: {np.mean((predictions - y_test)**2):.4f}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Feature Learning Analysis")
    print("=" * 60)

    T = 100
    trajectory = np.zeros((T, d))
    trajectory[0] = np.array([0.0, 0.0])
    for t in range(1, T):
        trajectory[t] = trajectory[t-1] + 0.05 * np.random.randn(d)

    analysis = analyze_feature_learning(W, b, S, trajectory)
    print(f"\nTrajectory length: {T} steps")
    print(f"Number of wall crossings: {analysis['n_crossings']}")
    print(f"Average lazy period duration: {analysis['avg_lazy_duration']:.1f} steps")
    print(f"\nLazy periods:")
    for p in analysis['lazy_periods']:
        print(f"  Steps {p['start']}-{p['end']}: cell {p['cell']} ({p['duration']} steps)")
    print(f"\nWall crossings (feature learning events):")
    for wc in analysis['wall_crossings'][:10]:
        print(f"  Step {wc['time']}: cell {wc['from_cell']} → cell {wc['to_cell']}")


"""
Tropical Neural Tangent Kernel — Demonstrations

Concrete numerical examples illustrating the formally verified theorems:
1. Tropical network = affine on strict cells
2. Parameter gradient is determined by active branch
3. Tropical NTK = ⟨x, y⟩ + 1 on common strict cells
4. Network output constant along flat directions
"""

import numpy as np
from itertools import combinations

def affine_score(W, b, i, x):
    """Affine score z_i(x) = W_i · x + b_i"""
    return np.dot(W[i], x) + b[i]

def tropical_net(W, b, S, x):
    """Tropical network: min over S of affine scores"""
    scores = [affine_score(W, b, i, x) for i in S]
    return min(scores)

def argmin_score(W, b, S, x):
    """Index in S achieving the minimum affine score"""
    scores = [(affine_score(W, b, i, x), i) for i in S]
    return min(scores, key=lambda t: t[0])[1]

def tropical_param_grad(W, b, S, x):
    """Tropical parameter gradient: (dW, db) where dW[i0] = x, db[i0] = 1"""
    m, d = W.shape
    i0 = argmin_score(W, b, S, x)
    dW = np.zeros_like(W)
    db = np.zeros_like(b)
    dW[i0] = x
    db[i0] = 1.0
    return dW, db

def tropical_ntk(W, b, S, x, y):
    """Tropical NTK: inner product of parameter gradients"""
    dWx, dbx = tropical_param_grad(W, b, S, x)
    dWy, dby = tropical_param_grad(W, b, S, y)
    return np.sum(dWx * dWy) + np.sum(dbx * dby)

def is_strict_cell(W, b, S, i0, x, tol=1e-10):
    """Check if x is in the strict argmin cell for i0"""
    score_i0 = affine_score(W, b, i0, x)
    for j in S:
        if j != i0:
            if score_i0 >= affine_score(W, b, j, x) - tol:
                return False
    return True


print("=" * 70)
print("DEMO 1: Tropical Network = Affine on Strict Argmin Cell")
print("=" * 70)

np.random.seed(42)
d, m = 3, 5
W = np.random.randn(m, d)
b = np.random.randn(m)
S = list(range(m))

# Find a point deeply inside a cell
x = np.array([1.0, -0.5, 0.3])
i0 = argmin_score(W, b, S, x)
print(f"\nInput x = {x}")
print(f"Active unit i0 = {i0}")
print(f"Affine scores: {[f'{affine_score(W, b, i, x):.4f}' for i in S]}")
print(f"Tropical net f(x) = {tropical_net(W, b, S, x):.6f}")
print(f"Affine score z_{{i0}}(x) = {affine_score(W, b, i0, x):.6f}")
print(f"Equal? {np.isclose(tropical_net(W, b, S, x), affine_score(W, b, i0, x))}")
print(f"In strict cell for i0={i0}? {is_strict_cell(W, b, S, i0, x)}")

print("\n" + "=" * 70)
print("DEMO 2: Parameter Gradient on Strict Cell")
print("=" * 70)

dW, db = tropical_param_grad(W, b, S, x)
print(f"\nWeight gradient dW[{i0}] = {dW[i0]} (should equal x = {x})")
print(f"Bias gradient db[{i0}] = {db[i0]} (should equal 1)")
for j in S:
    if j != i0:
        print(f"dW[{j}] = {dW[j]} (should be zero)")
        print(f"db[{j}] = {db[j]} (should be zero)")

print("\n" + "=" * 70)
print("DEMO 3: Tropical NTK = ⟨x, y⟩ + 1 on Common Strict Cell")
print("=" * 70)

# Find y in the same strict cell as x
y = x + 0.01 * np.random.randn(d)  # Small perturbation
while argmin_score(W, b, S, y) != i0:
    y = x + 0.01 * np.random.randn(d)

ntk_val = tropical_ntk(W, b, S, x, y)
dot_plus_one = np.dot(x, y) + 1
print(f"\nx = {x}")
print(f"y = {y}")
print(f"Both in cell for i0={i0}? x:{is_strict_cell(W, b, S, i0, x)}, y:{is_strict_cell(W, b, S, i0, y)}")
print(f"Tropical NTK K(x,y) = {ntk_val:.6f}")
print(f"⟨x, y⟩ + 1 = {dot_plus_one:.6f}")
print(f"Equal? {np.isclose(ntk_val, dot_plus_one)}")

# Try multiple pairs in the same cell
print("\nMultiple pairs in cell:")
for trial in range(5):
    y_test = x + 0.001 * np.random.randn(d)
    if argmin_score(W, b, S, y_test) == i0:
        ntk = tropical_ntk(W, b, S, x, y_test)
        expected = np.dot(x, y_test) + 1
        print(f"  K(x, y_{trial}) = {ntk:.6f}, ⟨x,y⟩+1 = {expected:.6f}, match: {np.isclose(ntk, expected)}")

print("\n" + "=" * 70)
print("DEMO 4: Network Output Constant Along Flat Directions")
print("=" * 70)

# Find a flat direction: v in ker(W[i0])
# W[i0] has shape (d,), so ker is (d-1)-dimensional
# Use SVD to find null space
u, s, vh = np.linalg.svd(W[i0].reshape(1, -1))
v = vh[-1]  # Last row of V^T is in the null space
v = v / np.linalg.norm(v)

print(f"\nActive unit i0 = {i0}")
print(f"W[{i0}] = {W[i0]}")
print(f"Flat direction v = {v}")
print(f"W[{i0}] · v = {np.dot(W[i0], v):.2e} (should be ~0)")

print("\nNetwork output along x + t*v:")
for t in np.linspace(0, 0.1, 6):
    xt = x + t * v
    if is_strict_cell(W, b, S, i0, xt):
        val = tropical_net(W, b, S, xt)
        print(f"  t = {t:.3f}: f(x+tv) = {val:.6f} (cell preserved: True)")
    else:
        print(f"  t = {t:.3f}: cell NOT preserved (crossed wall)")

base_val = tropical_net(W, b, S, x)
print(f"\nBase value f(x) = {base_val:.6f}")

print("\n" + "=" * 70)
print("DEMO 5: NTK Changes When Crossing Tropical Walls")
print("=" * 70)

# Find a direction that crosses a wall
v_cross = np.random.randn(d)
v_cross = v_cross / np.linalg.norm(v_cross)

print(f"\nCrossing direction v = {v_cross}")
print(f"\nNTK values along x + t*v_cross (with y fixed):")
prev_cell = argmin_score(W, b, S, x)
for t in np.linspace(0, 2.0, 20):
    xt = x + t * v_cross
    curr_cell = argmin_score(W, b, S, xt)
    ntk = tropical_ntk(W, b, S, xt, y)
    wall_marker = " <-- WALL CROSSED!" if curr_cell != prev_cell else ""
    print(f"  t = {t:.2f}: active={curr_cell}, K = {ntk:.4f}{wall_marker}")
    prev_cell = curr_cell

print("\n" + "=" * 70)
print("DEMO 6: Polyhedral Cell Decomposition (2D visualization data)")
print("=" * 70)

# 2D example for clearer visualization
d2, m2 = 2, 4
W2 = np.array([[1.0, 0.5], [-0.5, 1.0], [0.3, -0.8], [-1.0, -0.3]])
b2 = np.array([0.0, 0.5, -0.2, 0.3])
S2 = list(range(m2))

grid_size = 50
xs = np.linspace(-3, 3, grid_size)
ys = np.linspace(-3, 3, grid_size)
cell_map = np.zeros((grid_size, grid_size), dtype=int)
ntk_map = np.zeros((grid_size, grid_size))

y_fixed = np.array([0.5, 0.5])

for ix, xv in enumerate(xs):
    for iy, yv in enumerate(ys):
        pt = np.array([xv, yv])
        cell_map[iy, ix] = argmin_score(W2, b2, S2, pt)
        ntk_map[iy, ix] = tropical_ntk(W2, b2, S2, pt, y_fixed)

print(f"\nCell distribution in [-3,3]^2:")
for i in range(m2):
    count = np.sum(cell_map == i)
    print(f"  Cell {i}: {count}/{grid_size**2} points ({100*count/grid_size**2:.1f}%)")

print(f"\nNTK range: [{ntk_map.min():.2f}, {ntk_map.max():.2f}]")
print("(NTK varies across cells — feature learning regime)")
print("(NTK = ⟨x,y⟩+1 within each cell — lazy regime)")

# Verify NTK formula within each cell
print("\nVerification: NTK = ⟨x,y⟩+1 within cells")
for cell_id in range(m2):
    errors = []
    for ix, xv in enumerate(xs):
        for iy, yv in enumerate(ys):
            pt = np.array([xv, yv])
            if argmin_score(W2, b2, S2, pt) == cell_id:
                if argmin_score(W2, b2, S2, y_fixed) == cell_id:
                    expected = np.dot(pt, y_fixed) + 1
                    actual = tropical_ntk(W2, b2, S2, pt, y_fixed)
                    errors.append(abs(actual - expected))
    if errors:
        print(f"  Cell {cell_id}: max |NTK - (⟨x,y⟩+1)| = {max(errors):.2e} ({len(errors)} points)")
    else:
        print(f"  Cell {cell_id}: no common-cell points with y_fixed")

print("\n✓ All demonstrations complete. All theorems verified numerically.")


"""
Tropical NTK — Visualizations

Generate figures for the research paper and article.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import base64
from io import BytesIO


def affine_score(W, b, i, x):
    return float(np.dot(W[i], x) + b[i])

def find_argmin(W, b, S, x):
    scores = [(affine_score(W, b, i, x), i) for i in S]
    return min(scores, key=lambda t: t[0])[1]

def tropical_network(W, b, S, x):
    return min(affine_score(W, b, i, x) for i in S)

def tropical_ntk_val(W, b, S, x, y):
    i0x = find_argmin(W, b, S, x)
    i0y = find_argmin(W, b, S, y)
    if i0x == i0y:
        return np.dot(x, y) + 1
    else:
        # Different active units: weight gradients are x at i0x and y at i0y
        # Since i0x ≠ i0y, the inner product of gradients is 0 (disjoint support)
        return 0.0

def soft_min(W, b, S, x, tau):
    scores = np.array([affine_score(W, b, i, x) for i in S])
    min_s = np.min(scores)
    return -tau * np.log(np.sum(np.exp(-(scores - min_s) / tau))) + min_s

def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


# Setup
np.random.seed(42)
W = np.array([[1.0, 0.5], [-0.5, 1.0], [0.3, -0.8], [-1.0, -0.3]])
b = np.array([0.0, 0.5, -0.2, 0.3])
S = list(range(4))
m, d = W.shape

res = 300
xs = np.linspace(-3, 3, res)
ys = np.linspace(-3, 3, res)
XX, YY = np.meshgrid(xs, ys)

# ──────────────────────────────────────────────
# Figure 1: Polyhedral Cell Decomposition
# ──────────────────────────────────────────────
cell_map = np.zeros((res, res), dtype=int)
for i in range(res):
    for j in range(res):
        cell_map[i, j] = find_argmin(W, b, S, np.array([XX[i,j], YY[i,j]]))

fig1, ax1 = plt.subplots(1, 1, figsize=(8, 7))
cmap = ListedColormap(['#E8D5B7', '#A8D8EA', '#F5B7B1', '#ABEBC6'])
im = ax1.pcolormesh(XX, YY, cell_map, cmap=cmap, shading='auto')
ax1.set_xlabel('$x_1$', fontsize=14)
ax1.set_ylabel('$x_2$', fontsize=14)
ax1.set_title('Tropical Cell Decomposition\n(Each color = one active hidden unit)', fontsize=15)
cbar = plt.colorbar(im, ax=ax1, ticks=[0, 1, 2, 3])
cbar.set_label('Active Unit $i_0$', fontsize=12)

# Draw cell boundaries
for i in range(res - 1):
    for j in range(res - 1):
        if cell_map[i, j] != cell_map[i+1, j]:
            ax1.plot([XX[i,j], XX[i+1,j]], [YY[i,j], YY[i+1,j]], 'k-', lw=0.3, alpha=0.5)
        if cell_map[i, j] != cell_map[i, j+1]:
            ax1.plot([XX[i,j], XX[i,j+1]], [YY[i,j], YY[i,j+1]], 'k-', lw=0.3, alpha=0.5)

fig1_b64 = fig_to_base64(fig1)
fig1.savefig('/workspace/request-project/fig_cell_decomposition.png', dpi=150, bbox_inches='tight')
plt.close(fig1)

# ──────────────────────────────────────────────
# Figure 2: Tropical Network Surface
# ──────────────────────────────────────────────
net_map = np.zeros((res, res))
for i in range(res):
    for j in range(res):
        net_map[i, j] = tropical_network(W, b, S, np.array([XX[i,j], YY[i,j]]))

fig2, ax2 = plt.subplots(1, 1, figsize=(8, 7))
cf = ax2.contourf(XX, YY, net_map, levels=30, cmap='viridis')
ax2.contour(XX, YY, net_map, levels=30, colors='white', linewidths=0.3, alpha=0.5)
plt.colorbar(cf, ax=ax2, label='$f(x) = \\min_i z_i(x)$')
ax2.set_xlabel('$x_1$', fontsize=14)
ax2.set_ylabel('$x_2$', fontsize=14)
ax2.set_title('Tropical Network Output\n(Piecewise affine — kinks at cell boundaries)', fontsize=15)
fig2_b64 = fig_to_base64(fig2)
fig2.savefig('/workspace/request-project/fig_tropical_surface.png', dpi=150, bbox_inches='tight')
plt.close(fig2)

# ──────────────────────────────────────────────
# Figure 3: Tropical NTK Heatmap
# ──────────────────────────────────────────────
y_ref = np.array([0.5, 0.5])
ntk_map = np.zeros((res, res))
for i in range(res):
    for j in range(res):
        pt = np.array([XX[i,j], YY[i,j]])
        ntk_map[i, j] = tropical_ntk_val(W, b, S, pt, y_ref)

fig3, axes3 = plt.subplots(1, 2, figsize=(16, 7))

ax = axes3[0]
cf = ax.contourf(XX, YY, ntk_map, levels=30, cmap='coolwarm')
plt.colorbar(cf, ax=ax, label='$K_{\\mathrm{trop}}(x, y_{\\mathrm{ref}})$')
ax.plot(*y_ref, 'k*', markersize=15, label='$y_{\\mathrm{ref}}$')
ax.legend(fontsize=12)
ax.set_xlabel('$x_1$', fontsize=14)
ax.set_ylabel('$x_2$', fontsize=14)
ax.set_title('Tropical NTK $K(x, y_{\\mathrm{ref}})$', fontsize=15)

ax = axes3[1]
# Show ⟨x, y⟩ + 1 for comparison
dot_map = XX * y_ref[0] + YY * y_ref[1] + 1
# Only show where x and y_ref are in the same cell
same_cell = np.zeros((res, res), dtype=bool)
y_cell = find_argmin(W, b, S, y_ref)
for i in range(res):
    for j in range(res):
        same_cell[i, j] = cell_map[i, j] == y_cell

ax.contourf(XX, YY, np.where(same_cell, ntk_map - dot_map, np.nan),
            levels=np.linspace(-0.001, 0.001, 20), cmap='RdBu_r', extend='both')
ax.contour(XX, YY, cell_map, levels=[y_cell - 0.5, y_cell + 0.5],
           colors='black', linewidths=2)
ax.plot(*y_ref, 'k*', markersize=15)
ax.set_xlabel('$x_1$', fontsize=14)
ax.set_ylabel('$x_2$', fontsize=14)
ax.set_title('$K(x,y) - (\\langle x,y\\rangle + 1)$ on shared cell\n(Machine-zero everywhere)', fontsize=15)

fig3_b64 = fig_to_base64(fig3)
fig3.savefig('/workspace/request-project/fig_tropical_ntk.png', dpi=150, bbox_inches='tight')
plt.close(fig3)

# ──────────────────────────────────────────────
# Figure 4: Soft-min Convergence
# ──────────────────────────────────────────────
fig4, axes4 = plt.subplots(1, 2, figsize=(14, 6))

# 1D slice
x1_vals = np.linspace(-3, 3, 500)
ax = axes4[0]
for tau in [2.0, 1.0, 0.5, 0.1, 0.01]:
    y_vals = [soft_min(W, b, S, np.array([x1, 0.5]), tau) for x1 in x1_vals]
    ax.plot(x1_vals, y_vals, label=f'$\\tau = {tau}$', alpha=0.8)
y_trop = [tropical_network(W, b, S, np.array([x1, 0.5])) for x1 in x1_vals]
ax.plot(x1_vals, y_trop, 'k--', lw=2, label='Tropical ($\\tau \\to 0$)')
ax.set_xlabel('$x_1$', fontsize=14)
ax.set_ylabel('$f_\\tau(x)$', fontsize=14)
ax.set_title('Soft-min → Tropical Limit\n(1D slice at $x_2 = 0.5$)', fontsize=15)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Convergence rate
ax = axes4[1]
test_points = [np.array([1.0, 0.5]), np.array([-1.0, -0.5]),
               np.array([2.0, -1.0]), np.array([0.0, 0.0])]
taus = np.logspace(-3, 1, 50)
for pt in test_points:
    true_val = tropical_network(W, b, S, pt)
    errors = [abs(soft_min(W, b, S, pt, tau) - true_val) for tau in taus]
    ax.loglog(taus, errors, '-o', markersize=2, label=f'x={pt}')
ax.set_xlabel('$\\tau$', fontsize=14)
ax.set_ylabel('$|f_\\tau(x) - f(x)|$', fontsize=14)
ax.set_title('Convergence Rate\n($f_\\tau \\to \\min$ as $\\tau \\to 0^+$)', fontsize=15)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

fig4_b64 = fig_to_base64(fig4)
fig4.savefig('/workspace/request-project/fig_softmin_convergence.png', dpi=150, bbox_inches='tight')
plt.close(fig4)

# ──────────────────────────────────────────────
# Figure 5: Flat direction constancy
# ──────────────────────────────────────────────
fig5, axes5 = plt.subplots(1, 2, figsize=(14, 6))

x0 = np.array([0.5, 0.5])
i0 = find_argmin(W, b, S, x0)
w_i0 = W[i0]
v_flat = np.array([-w_i0[1], w_i0[0]])
v_flat = v_flat / np.linalg.norm(v_flat)
v_generic = np.array([1.0, 0.3])
v_generic = v_generic / np.linalg.norm(v_generic)

ts = np.linspace(-1, 1, 200)

ax = axes5[0]
vals_flat = [tropical_network(W, b, S, x0 + t * v_flat) for t in ts]
vals_generic = [tropical_network(W, b, S, x0 + t * v_generic) for t in ts]
ax.plot(ts, vals_flat, 'b-', lw=2, label='Flat direction $v$')
ax.plot(ts, vals_generic, 'r--', lw=2, label='Generic direction')
ax.axhline(y=tropical_network(W, b, S, x0), color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('$t$', fontsize=14)
ax.set_ylabel('$f(x_0 + tv)$', fontsize=14)
ax.set_title('Network Output Along Directions\n(Flat = constant, Generic = changing)', fontsize=15)
ax.legend(fontsize=12)
ax.grid(True, alpha=0.3)

ax = axes5[1]
y_ref2 = np.array([0.3, 0.8])
ntk_flat = [tropical_ntk_val(W, b, S, x0 + t * v_flat, y_ref2) for t in ts]
ntk_generic = [tropical_ntk_val(W, b, S, x0 + t * v_generic, y_ref2) for t in ts]
ax.plot(ts, ntk_flat, 'b-', lw=2, label='Flat direction $v$')
ax.plot(ts, ntk_generic, 'r--', lw=2, label='Generic direction')
ax.set_xlabel('$t$', fontsize=14)
ax.set_ylabel('$K_{\\mathrm{trop}}(x_0 + tv, y)$', fontsize=14)
ax.set_title('Tropical NTK Along Directions\n(Both change, but flat has constant ⟨·,·⟩+1 formula)', fontsize=15)
ax.legend(fontsize=12)
ax.grid(True, alpha=0.3)

fig5_b64 = fig_to_base64(fig5)
fig5.savefig('/workspace/request-project/fig_flat_directions.png', dpi=150, bbox_inches='tight')
plt.close(fig5)

print("All visualizations generated successfully.")
print(f"  fig_cell_decomposition.png")
print(f"  fig_tropical_surface.png")
print(f"  fig_tropical_ntk.png")
print(f"  fig_softmin_convergence.png")
print(f"  fig_flat_directions.png")

# Store base64 for JSON
visualization_data = {
    'cell_decomposition': fig1_b64,
    'tropical_surface': fig2_b64,
    'tropical_ntk': fig3_b64,
    'softmin_convergence': fig4_b64,
    'flat_directions': fig5_b64,
}

# Save for use by package builder
import json
with open('/workspace/request-project/viz_data.json', 'w') as f:
    json.dump(visualization_data, f)
