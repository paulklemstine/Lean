import cmath
import matplotlib.pyplot as plt

def legendre_symbol(a: int, p: int) -> int:
    a_mod = a % p
    if a_mod == 0:
        return 0
    r = pow(a_mod, (p - 1) // 2, p)
    return -1 if r == p - 1 else r

def plot_gauss_sum_path(p: int = 13) -> None:
    pts = [0 + 0j]
    for x in range(p):
        pts.append(pts[-1] + legendre_symbol(x, p) * cmath.exp(2j * cmath.pi * x / p))
    xs = [z.real for z in pts]; ys = [z.imag for z in pts]
    plt.figure(figsize=(6, 6))
    plt.plot(xs, ys, '-o', ms=3)
    plt.scatter([xs[-1]], [ys[-1]], c='crimson', zorder=5, label=f'g, |g|={abs(pts[-1]):.3f}')
    plt.title(f'Gauss sum path, p={p}, sqrt(p)={p**0.5:.3f}')
    plt.axhline(0, color='gray', lw=0.5); plt.axvline(0, color='gray', lw=0.5)
    plt.legend(); plt.gca().set_aspect('equal'); plt.grid(True, alpha=0.3)
    plt.tight_layout(); plt.savefig('gauss_sum_path.png', dpi=150)

if __name__ == '__main__':
    plot_gauss_sum_path()