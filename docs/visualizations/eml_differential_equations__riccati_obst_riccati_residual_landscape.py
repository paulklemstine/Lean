import numpy as np
try:
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False

def plot():
    if not HAS_MPL:
        print('matplotlib not available')
        return
    fig, ax = plt.subplots(figsize=(8,6))
    x = np.linspace(-3, 3, 300)
    for a, b, label in [(0,0,'0'), (1,0,'x'), (0,1,'1'), (1,1,'x+1'), (-1,0,'-x')]:
        omega = a*x + b
        res = np.abs(a + omega**2 - x)
        ax.plot(x, res, label=f'ω = {label}', linewidth=1.5)
    ax.set_xlabel('x'); ax.set_ylabel('|ω\' + ω² - x|')
    ax.set_title('Riccati Residual for Airy: No Linear ω Works')
    ax.legend(); ax.set_ylim(0, 15); ax.grid(True, alpha=0.3)
    plt.savefig('riccati_residual.png', dpi=150); plt.close()

if __name__ == '__main__': plot()