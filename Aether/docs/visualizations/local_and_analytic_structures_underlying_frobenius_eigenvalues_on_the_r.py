"""Visualize the Frobenius eigenvalues on the circle |z| = sqrt(p) and the
Sato-Tate angle, illustrating frobenius_normSq_eq_iff and exists_satoTate_angle."""
import cmath, math
import matplotlib.pyplot as plt

def plot_frobenius_circle(a: float, p: float) -> None:
    disc = cmath.sqrt(complex(a * a - 4 * p))
    alpha, beta = (a + disc) / 2, (a - disc) / 2
    theta = math.acos(a / (2 * math.sqrt(p)))
    fig, ax = plt.subplots(figsize=(6, 6))
    ts = [i * 2 * math.pi / 400 for i in range(401)]
    ax.plot([math.sqrt(p) * math.cos(t) for t in ts],
            [math.sqrt(p) * math.sin(t) for t in ts], 'b--', label=f"|z|=sqrt(p)={math.sqrt(p):.3f}")
    ax.scatter([alpha.real, beta.real], [alpha.imag, beta.imag], c='red', zorder=5,
               label=f"alpha, beta  (a={a}, p={p})")
    ax.annotate(f"theta={theta:.3f}", (alpha.real, alpha.imag))
    ax.set_aspect('equal'); ax.axhline(0, color='gray', lw=0.5); ax.axvline(0, color='gray', lw=0.5)
    ax.set_title("Frobenius eigenvalues on the RH circle and the Sato-Tate angle")
    ax.legend(); plt.tight_layout(); plt.savefig("frobenius_circle.png", dpi=150)

if __name__ == "__main__":
    plot_frobenius_circle(3.0, 5.0)
