import numpy as np
import matplotlib.pyplot as plt

def main() -> None:
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 9))

    # Panel 1: parity of RHS degree vs LHS leading (even) degree.
    ns = np.arange(0, 8)
    dq = 1  # fix deg q = 1 for illustration
    rhs_deg = ns + 2 * dq
    ax1.bar(ns - 0.2, rhs_deg % 2, width=0.4, label='parity of deg(f q^2)')
    ax1.bar(ns + 0.2, np.zeros_like(ns), width=0.4,
            label='parity of 2 deg(p) (always even)')
    ax1.set_xlabel('n  (coefficient f = x^n)')
    ax1.set_ylabel('degree parity (0=even, 1=odd)')
    ax1.set_title('Odd n => parity clash => no rational Riccati solution')
    ax1.legend()

    # Panel 2: residual of v = x for f = x^2 + 1 (exactly zero) vs Airy f = x.
    x = np.linspace(-2, 2, 400)
    v = x                      # candidate solution v = x
    vp = np.ones_like(x)       # v' = 1
    res_even = vp + v**2 - (x**2 + 1)   # identically 0
    res_airy = vp + v**2 - x           # never 0: 1 + x^2 - x
    ax2.plot(x, res_even, label="residual for f=x^2+1 (v=x): identically 0")
    ax2.plot(x, res_airy, label="residual for f=x (Airy, v=x): never 0")
    ax2.axhline(0, color='k', lw=0.5)
    ax2.set_xlabel('x')
    ax2.set_ylabel("v' + v^2 - f")
    ax2.set_title('Even witness solves exactly; Airy has no such solution')
    ax2.legend()

    plt.tight_layout()
    plt.savefig('riccati_parity_landscape.png', dpi=150)
    print('wrote riccati_parity_landscape.png')

if __name__ == '__main__':
    main()
