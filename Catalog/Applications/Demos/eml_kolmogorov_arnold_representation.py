#!/usr/bin/env python3
"""
EML Spectral Algebra — Numerical Demonstrations

This script demonstrates the key results from the EML Spectral Algebra theory,
showing how EML chains (compositions of exp, log, and affine maps) decompose
multivariate functions into sums of univariate channel evaluations.
"""
import math

# ── EML Chain Evaluation ──────────────────────────────────────────────
def eval_chain(chain, x):
    """Evaluate an EML chain (list of ops) at x, right-to-left."""
    result = x
    for op in reversed(chain):
        if op[0] == 'exp':
            result = math.exp(result)
        elif op[0] == 'log':
            result = math.log(result)
        elif op[0] == 'affine':
            a, b = op[1], op[2]
            result = a * result + b
    return result

def eval_channel(channel, x, y):
    """Evaluate an EML channel at (x, y)."""
    psi1_x = eval_chain(channel['psi1'], x)
    psi2_y = eval_chain(channel['psi2'], y)
    return eval_chain(channel['Phi'], psi1_x + psi2_y)

def eval_spectrum(channels, x, y):
    """Evaluate an EML spectrum (sum of channels) at (x, y)."""
    return sum(eval_channel(ch, x, y) for ch in channels)

# ── Demo 1: Multiplication Channel ───────────────────────────────────
print("=" * 60)
print("Demo 1: Multiplication Channel")
print("  x·y = exp(log(x) + log(y))")
print("=" * 60)

mul_channel = {
    'psi1': [('log',)],
    'psi2': [('log',)],
    'Phi': [('exp',)]
}

test_pairs = [(2, 3), (0.5, 4), (math.pi, math.e), (7, 11)]
for x, y in test_pairs:
    result = eval_channel(mul_channel, x, y)
    exact = x * y
    print(f"  x={x:.4f}, y={y:.4f}: channel={result:.10f}, exact={exact:.10f}, err={abs(result-exact):.2e}")

# ── Demo 2: Monomial Channel ─────────────────────────────────────────
print("\n" + "=" * 60)
print("Demo 2: Monomial Channel  x^a · y^b")
print("=" * 60)

def monomial_channel(a, b):
    return {
        'psi1': [('affine', a, 0), ('log',)],
        'psi2': [('affine', b, 0), ('log',)],
        'Phi': [('exp',)]
    }

for a, b in [(2, 3), (1, 1), (3, 0), (0, 5)]:
    ch = monomial_channel(a, b)
    x, y = 2.0, 3.0
    result = eval_channel(ch, x, y)
    exact = x**a * y**b
    print(f"  x^{a}·y^{b} at (2,3): channel={result:.6f}, exact={exact:.6f}, err={abs(result-exact):.2e}")

# ── Demo 3: Addition via 2-Channel Spectrum ──────────────────────────
print("\n" + "=" * 60)
print("Demo 3: Addition via 2-Channel Spectrum")
print("  x+y = exp(log(x)+0) + exp(0+log(y))")
print("=" * 60)

add_channels = [
    {'psi1': [('log',)], 'psi2': [('affine', 0, 0)], 'Phi': [('exp',)]},
    {'psi1': [('affine', 0, 0)], 'psi2': [('log',)], 'Phi': [('exp',)]},
]

for x, y in [(1, 1), (2, 3), (0.1, 99.9), (math.pi, math.e)]:
    result = eval_spectrum(add_channels, x, y)
    exact = x + y
    print(f"  x={x:.4f}, y={y:.4f}: spectrum={result:.10f}, exact={exact:.10f}, err={abs(result-exact):.2e}")

# ── Demo 4: Polynomial Spectral Decomposition ────────────────────────
print("\n" + "=" * 60)
print("Demo 4: Polynomial Spectral Decomposition")
print("  p(x,y) = 3x²y + 2xy³ - x²y²")
print("=" * 60)

poly_channels = [
    {'psi1': [('affine', 2, 0), ('log',)], 'psi2': [('affine', 1, 0), ('log',)],
     'Phi': [('affine', 3, 0), ('exp',)]},
    {'psi1': [('affine', 1, 0), ('log',)], 'psi2': [('affine', 3, 0), ('log',)],
     'Phi': [('affine', 2, 0), ('exp',)]},
    {'psi1': [('affine', 2, 0), ('log',)], 'psi2': [('affine', 2, 0), ('log',)],
     'Phi': [('affine', -1, 0), ('exp',)]},
]

for x, y in [(1, 1), (2, 1), (1, 2), (2, 3)]:
    result = eval_spectrum(poly_channels, x, y)
    exact = 3*x**2*y + 2*x*y**3 - x**2*y**2
    print(f"  p({x},{y}): spectrum={result:.6f}, exact={exact:.6f}, err={abs(result-exact):.2e}")

# ── Demo 5: Tropical Degeneration ────────────────────────────────────
print("\n" + "=" * 60)
print("Demo 5: Tropical Degeneration")
print("  lim_{t→∞} (1/t)·log(exp(ta) + exp(tb)) = max(a,b)")
print("=" * 60)

a, b = 2.0, 5.0
print(f"  a={a}, b={b}, max={max(a,b)}")
def log_sum_exp_scaled(t, a, b):
    m = max(t*a, t*b)
    return (m + math.log(math.exp(t*a - m) + math.exp(t*b - m))) / t

for t in [1, 2, 5, 10, 50, 100, 1000]:    
    val = log_sum_exp_scaled(t, a, b)
    err = abs(val - max(a, b))
    bound = math.log(2) / t
    print(f"  t={t:5d}: (1/t)·log(exp(ta)+exp(tb))={val:.10f}, |err|={err:.2e}, bound={bound:.2e}, OK={err<=bound+1e-15}")

# ── Demo 6: AM-GM Spectral Gap ───────────────────────────────────────
print("\n" + "=" * 60)
print("Demo 6: AM-GM Spectral Gap")
print("  (x+y)/2 - √(xy) = (√x - √y)²/2")
print("=" * 60)

for x, y in [(1, 9), (4, 16), (0.01, 100), (3, 3)]:
    am = (x + y) / 2
    gm = math.sqrt(x * y)
    gap_direct = am - gm
    gap_formula = (math.sqrt(x) - math.sqrt(y))**2 / 2
    print(f"  x={x}, y={y}: AM={am:.6f}, GM={gm:.6f}, gap={gap_direct:.6f}, formula={gap_formula:.6f}")

# ── Demo 7: Fenchel-Young Inequality ─────────────────────────────────
print("\n" + "=" * 60)
print("Demo 7: Fenchel-Young Inequality")
print("  x·s ≤ exp(x) + s·log(s) - s")
print("=" * 60)

for x in [-2, 0, 1, 3]:
    for s in [0.1, 1, 2, 10]:
        lhs = x * s
        rhs = math.exp(x) + s * math.log(s) - s
        tight_x = math.log(s)
        gap = rhs - lhs
        print(f"  x={x:5.1f}, s={s:5.1f}: x·s={lhs:8.3f}, bound={rhs:8.3f}, gap={gap:8.4f}, tight at x=log(s)={tight_x:.3f}")

# ── Demo 8: Geometric Mean Channel ───────────────────────────────────
print("\n" + "=" * 60)
print("Demo 8: Geometric Mean Channel")
print("  √(xy) = exp(½(log x + log y))")
print("=" * 60)

geom_channel = {
    'psi1': [('affine', 0.5, 0), ('log',)],
    'psi2': [('affine', 0.5, 0), ('log',)],
    'Phi': [('exp',)]
}

for x, y in [(4, 9), (1, 100), (2, 8), (3, 3)]:
    result = eval_channel(geom_channel, x, y)
    exact = math.sqrt(x * y)
    print(f"  √({x}·{y}): channel={result:.10f}, exact={exact:.10f}, err={abs(result-exact):.2e}")

# ── Demo 9: Power Sum Spectrum ────────────────────────────────────────
print("\n" + "=" * 60)
print("Demo 9: Power Sum Spectrum  x^r + y^r")
print("=" * 60)

def power_sum_spectrum(r):
    return [
        {'psi1': [('affine', r, 0), ('log',)], 'psi2': [('affine', 0, 0)], 'Phi': [('exp',)]},
        {'psi1': [('affine', 0, 0)], 'psi2': [('affine', r, 0), ('log',)], 'Phi': [('exp',)]},
    ]

for r in [0.5, 1, 2, 3]:
    channels = power_sum_spectrum(r)
    x, y = 2.0, 3.0
    result = eval_spectrum(channels, x, y)
    exact = x**r + y**r
    print(f"  r={r:.1f}: x^r+y^r at (2,3): spectrum={result:.6f}, exact={exact:.6f}, err={abs(result-exact):.2e}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: EML Spectral Width Landscape

Shows the spectral decomposition of various functions and the
tropical degeneration behavior.
"""
import math

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.gridspec as gridspec

    def eval_chain(chain, x):
        result = x
        for op in reversed(chain):
            if op[0] == 'exp':
                result = math.exp(result)
            elif op[0] == 'log':
                result = math.log(result) if result > 0 else float('-inf')
            elif op[0] == 'affine':
                result = op[1] * result + op[2]
        return result

    def log_sum_exp(a, b):
        m = max(a, b)
        return m + math.log(math.exp(a - m) + math.exp(b - m))

    # Create figure
    fig = plt.figure(figsize=(16, 12))
    gs = gridspec.GridSpec(2, 2, hspace=0.3, wspace=0.3)

    # Panel 1: Multiplication channel accuracy
    ax1 = fig.add_subplot(gs[0, 0])
    xs = [0.1 + 0.1*i for i in range(50)]
    ys_exact = [x * 3.0 for x in xs]
    ys_channel = [math.exp(math.log(x) + math.log(3.0)) for x in xs]
    ax1.plot(xs, ys_exact, 'b-', label='exact: x·3', linewidth=2)
    ax1.plot(xs, ys_channel, 'r--', label='EML: exp(log x + log 3)', linewidth=2)
    ax1.set_xlabel('x')
    ax1.set_ylabel('f(x, 3)')
    ax1.set_title('Multiplication Channel (Width 1)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Panel 2: Tropical degeneration
    ax2 = fig.add_subplot(gs[0, 1])
    a_val, b_val = 2.0, 5.0
    ts = [0.5 + 0.1*i for i in range(100)]
    approxs = [log_sum_exp(t*a_val, t*b_val)/t for t in ts]
    ax2.plot(ts, approxs, 'b-', linewidth=2, label='(1/t)·log(e^{ta}+e^{tb})')
    ax2.axhline(y=max(a_val, b_val), color='r', linestyle='--', label=f'max(a,b) = {max(a_val,b_val)}')
    bounds_upper = [max(a_val, b_val) + math.log(2)/t for t in ts]
    ax2.plot(ts, bounds_upper, 'g:', linewidth=1, label='max + log(2)/t')
    ax2.set_xlabel('t')
    ax2.set_ylabel('Value')
    ax2.set_title('Tropical Degeneration')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    # Panel 3: AM-GM spectral gap
    ax3 = fig.add_subplot(gs[1, 0])
    ratios = [0.1 + 0.05*i for i in range(80)]
    y_fixed = 4.0
    ams = [(r*y_fixed + y_fixed)/2 for r in ratios]
    gms = [math.sqrt(r*y_fixed * y_fixed) for r in ratios]
    gaps = [am - gm for am, gm in zip(ams, gms)]
    ax3.plot(ratios, ams, 'b-', label='AM = (x+y)/2', linewidth=2)
    ax3.plot(ratios, gms, 'r-', label='GM = √(xy)', linewidth=2)
    ax3.fill_between(ratios, gms, ams, alpha=0.2, color='orange', label='Spectral gap')
    ax3.set_xlabel('x/y ratio')
    ax3.set_ylabel('Value (y=4)')
    ax3.set_title('AM-GM Spectral Gap')
    ax3.legend()
    ax3.grid(True, alpha=0.3)

    # Panel 4: Fenchel-Young gap
    ax4 = fig.add_subplot(gs[1, 1])
    x_vals = [-3 + 0.1*i for i in range(80)]
    for s in [0.5, 1.0, 2.0, 5.0]:
        fy_gaps = [math.exp(x) + s*math.log(s) - s - x*s for x in x_vals]
        ax4.plot(x_vals, fy_gaps, label=f's={s}', linewidth=1.5)
        tight_x = math.log(s)
        ax4.plot(tight_x, 0, 'ko', markersize=5)
    ax4.set_xlabel('x')
    ax4.set_ylabel('Fenchel-Young gap')
    ax4.set_title('EML Fenchel-Young Inequality (gap ≥ 0)')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    ax4.set_ylim(-1, 20)

    plt.savefig('spectral_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_landscape.png")

except ImportError:
    print("matplotlib not available; skipping visualization")
