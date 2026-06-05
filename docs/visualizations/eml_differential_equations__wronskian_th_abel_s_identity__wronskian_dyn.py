import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp

def plot_abel_identity():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Case 1: Damped oscillator y'' + 2y' + y = 0
    xs = np.linspace(0, 4, 200)
    W_damped = np.exp(-2 * xs)
    axes[0].plot(xs, W_damped, 'r-', linewidth=2, label='W(x) = exp(-2x)')
    axes[0].plot(xs, -2 * W_damped, 'b--', linewidth=2, label="W'(x) = -2W(x)")
    axes[0].set_title('Damped: y\'\' + 2y\' + y = 0\nAbel: W\' = -2W', fontsize=12)
    axes[0].set_xlabel('x')
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3)
    
    # Case 2: Airy equation y'' = xy (p=0, so W=const)
    def airy_sys(t, Y):
        y1, y1p, y2, y2p = Y
        return [y1p, t * y1, y2p, t * y2]
    y0 = [0.3550280539, -0.2588194038, 0.6149266274, 0.4482883574]
    sol = solve_ivp(airy_sys, [0, 5], y0, t_eval=np.linspace(0, 5, 200), rtol=1e-12)
    W_airy = sol.y[0] * sol.y[3] - sol.y[1] * sol.y[2]
    axes[1].plot(sol.t, W_airy, 'g-', linewidth=2, label=f'W(x) ≈ 1/π = {1/np.pi:.4f}')
    axes[1].axhline(y=1/np.pi, color='gray', linestyle='--', alpha=0.7, label='1/π')
    axes[1].set_title('Airy: y\'\' = xy\nAbel: W\' = 0 (constant W)', fontsize=12)
    axes[1].set_xlabel('x')
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)
    axes[1].set_ylim([0.3, 0.35])
    
    plt.suptitle("Abel's Identity: W' = -p·W", fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('abel_identity.png', dpi=150, bbox_inches='tight')
    plt.show()

plot_abel_identity()