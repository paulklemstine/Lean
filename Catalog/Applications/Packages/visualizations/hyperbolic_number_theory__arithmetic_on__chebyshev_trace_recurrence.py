"""
Visualization: Chebyshev-Trace Recurrence and Growth
=====================================================

Shows how traces of powers of SL(2,R) elements follow the Chebyshev
recurrence, exhibiting exponential growth for hyperbolic elements.
This connects hyperbolic geometry to classical approximation theory.
"""

import math
import matplotlib.pyplot as plt


def chebyshev_traces(trace_M, n_terms):
    """Compute traces via Chebyshev recurrence."""
    if n_terms <= 0:
        return []
    traces = [2.0]
    if n_terms == 1:
        return traces
    traces.append(trace_M)
    for k in range(2, n_terms):
        traces.append(trace_M * traces[k-1] - traces[k-2])
    return traces


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Trace growth for different element types
    ax = axes[0, 0]
    n = 20
    ns = list(range(n))

    # Hyperbolic: tr = 3
    traces_hyp = chebyshev_traces(3.0, n)
    ax.semilogy(ns, [abs(t) for t in traces_hyp], 'r-o', markersize=3,
                label='Hyperbolic (tr=3)')

    # Barely hyperbolic: tr = 2.1
    traces_bh = chebyshev_traces(2.1, n)
    ax.semilogy(ns, [abs(t) for t in traces_bh], 'orange', marker='s',
                markersize=3, label='Hyperbolic (tr=2.1)')

    # Parabolic: tr = 2
    traces_par = chebyshev_traces(2.0, n)
    ax.plot(ns, [abs(t) for t in traces_par], 'g-^', markersize=3,
            label='Parabolic (tr=2)')

    # Elliptic: tr = 1
    traces_ell = chebyshev_traces(1.0, n)
    ax.plot(ns, [max(abs(t), 0.01) for t in traces_ell], 'b-v', markersize=3,
            label='Elliptic (tr=1)')

    ax.set_xlabel('Power n')
    ax.set_ylabel('|tr(M^n)|')
    ax.set_title('Trace Growth by Element Type')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 2: Chebyshev polynomial connection
    ax = axes[0, 1]
    # tr(M^n) = 2*T_n(tr(M)/2) where T_n is Chebyshev polynomial
    x = [i * 0.01 for i in range(-300, 301)]
    for n_val in [2, 3, 5, 8]:
        y = [chebyshev_traces(2*xi, n_val+1)[-1] / 2 for xi in x]
        ax.plot(x, y, label=f'T_{n_val}(x)')
    ax.set_xlabel('x = tr(M)/2')
    ax.set_ylabel('T_n(x) = tr(M^n)/2')
    ax.set_title('Chebyshev Polynomials from SL(2) Traces')
    ax.set_ylim(-3, 3)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

    # Panel 3: Displacement spectrum
    ax = axes[1, 0]

    # Generate SL(2,Z) elements by direct enumeration
    traces_set = set()
    for a in range(-8, 9):
        for b in range(-8, 9):
            for c in range(-8, 9):
                if a == 0:
                    continue
                rem = 1 + b * c
                if rem % a == 0:
                    d = rem // a
                    if a * d - b * c == 1:
                        t = abs(a + d)
                        if t > 2:
                            traces_set.add(t)

    displacements = sorted(t - 2 for t in traces_set)[:80]
    ax.bar(range(len(displacements)), displacements, color='steelblue', alpha=0.7)
    ax.set_xlabel('Index')
    ax.set_ylabel('Displacement |tr(M)| - 2')
    ax.set_title('Displacement Spectrum of PSL(2,ℤ)')
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 4: Partial zeta function
    ax = axes[1, 1]
    if displacements:
        s_vals = [i * 0.05 for i in range(10, 80)]
        zeta_vals = []
        for s in s_vals:
            z = sum(1.0 / d**(2*s) for d in displacements if d > 0.01)
            zeta_vals.append(z)
        ax.plot(s_vals, zeta_vals, 'darkred', linewidth=2)
        ax.set_xlabel('s')
        ax.set_ylabel('ζ_H(s)')
        ax.set_title('Partial Hyperbolic Zeta Function')
        ax.grid(True, alpha=0.3)
        ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='y=1')
        ax.legend()

    fig.suptitle('Hyperbolic Number Theory: Chebyshev Connection & Spectral Data',
                 fontsize=15, fontweight='bold', y=1.01)
    plt.tight_layout()
    plt.savefig('chebyshev_traces.png', dpi=150, bbox_inches='tight')
    print("Saved chebyshev_traces.png")


if __name__ == "__main__":
    main()
