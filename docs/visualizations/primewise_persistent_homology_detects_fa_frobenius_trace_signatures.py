"""
Visualization: Frobenius Trace Signatures for Elliptic Curves

Shows how different elliptic curves produce distinct "fingerprints"
when viewed through their Frobenius trace data across primes.
The heatmap reveals systematic patterns that distinguish curves
with rational points from potential Hasse counterexamples.
"""

import numpy as np
import matplotlib.pyplot as plt


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def count_points(a, b, p):
    count = 1
    for x in range(p):
        rhs = (x**3 + a * x + b) % p
        if rhs == 0:
            count += 1
        elif pow(rhs, (p - 1) // 2, p) == 1:
            count += 2
    return count


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Primewise Persistence: Frobenius Signatures of Elliptic Curves',
                 fontsize=14, fontweight='bold')

    curves = {
        r'$y^2=x^3-x$': (-1, 0),
        r'$y^2=x^3+1$': (0, 1),
        r'$y^2=x^3-x+1$': (-1, 1),
        r'$y^2=x^3+2x+3$': (2, 3),
    }

    primes = [p for p in range(7, 300) if is_prime(p)]

    # Plot 1: Frobenius traces
    ax = axes[0, 0]
    for name, (a, b) in curves.items():
        disc = -16 * (4 * a**3 + 27 * b**2)
        valid_p = [p for p in primes if disc % p != 0]
        traces = [p + 1 - count_points(a, b, p) for p in valid_p]
        ax.scatter(valid_p[:60], traces[:60], s=15, alpha=0.7, label=name)
    ax.set_xlabel('Prime p')
    ax.set_ylabel('Frobenius trace $a_p$')
    ax.set_title('Frobenius Traces')
    ax.legend(fontsize=8)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)

    # Plot 2: Normalized trace distribution (Sato-Tate)
    ax = axes[0, 1]
    theta = np.linspace(0, np.pi, 100)
    sato_tate = 2 / np.pi * np.sin(theta)**2
    ax.plot(theta, sato_tate, 'k-', linewidth=2, label='Sato-Tate density')

    for name, (a, b) in list(curves.items())[:2]:
        disc = -16 * (4 * a**3 + 27 * b**2)
        valid_p = [p for p in primes if disc % p != 0]
        traces = [p + 1 - count_points(a, b, p) for p in valid_p]
        normalized = [np.arccos(np.clip(t / (2*np.sqrt(p)), -1, 1))
                      for p, t in zip(valid_p, traces)]
        ax.hist(normalized, bins=20, density=True, alpha=0.4, label=name)

    ax.set_xlabel(r'$\theta = \arccos(a_p / 2\sqrt{p})$')
    ax.set_ylabel('Density')
    ax.set_title('Sato-Tate Distribution')
    ax.legend(fontsize=8)

    # Plot 3: Signature heatmap
    ax = axes[1, 0]
    curve_list = list(curves.items())
    n_curves = len(curve_list)
    n_primes = 40
    display_primes = primes[:n_primes]

    data = np.zeros((n_curves, n_primes))
    for i, (name, (a, b)) in enumerate(curve_list):
        for j, p in enumerate(display_primes):
            disc = -16 * (4 * a**3 + 27 * b**2)
            if disc % p != 0:
                data[i, j] = p + 1 - count_points(a, b, p)

    im = ax.imshow(data, aspect='auto', cmap='RdBu_r',
                   interpolation='nearest')
    ax.set_yticks(range(n_curves))
    ax.set_yticklabels([name for name, _ in curve_list], fontsize=8)
    ax.set_xlabel('Prime index')
    ax.set_title('Frobenius Trace Heatmap')
    plt.colorbar(im, ax=ax, label='$a_p$')

    # Plot 4: Euler characteristic
    ax = axes[1, 1]
    for name, (a, b) in curves.items():
        disc = -16 * (4 * a**3 + 27 * b**2)
        valid_p = [p for p in primes if disc % p != 0]
        traces = [p + 1 - count_points(a, b, p) for p in valid_p]

        # Running alternating sum (Euler char of growing complex)
        euler = []
        running = 0
        for i, t in enumerate(traces[:50]):
            running += (-1)**i * t
            euler.append(running)
        ax.plot(range(len(euler)), euler, '-', alpha=0.7, label=name)

    ax.set_xlabel('Depth (number of primes)')
    ax.set_ylabel('Running Euler characteristic')
    ax.set_title('Euler Characteristic Growth')
    ax.legend(fontsize=8)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)

    plt.tight_layout()
    plt.savefig('frobenius_signatures.png', dpi=150, bbox_inches='tight')
    print("Saved frobenius_signatures.png")


if __name__ == "__main__":
    main()
