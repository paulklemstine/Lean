"""Visualize the density/discreteness dichotomy of the phantom number."""
import matplotlib.pyplot as plt

def main() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(10, 3))
    # discrete chain: integers, forward interval [n, n+1) = {n}
    axes[0].scatter(range(-3, 4), [0]*7, s=80, color="tab:red")
    axes[0].set_title("Discrete chain (Z): [n, n+1)={n}\\nforward observer = order topology (number 1)")
    axes[0].set_yticks([]); axes[0].set_xlim(-3.5, 3.5)
    # dense chain: rationals sample, ray [0, inf) open for forward but not order-open at 0
    xs = [i/10 for i in range(-30, 31)]
    axes[1].scatter(xs, [0]*len(xs), s=8, color="tab:blue")
    axes[1].axvline(0, color="black", ls="--")
    axes[1].set_title("Dense chain (Q, R): a ray stays half-open\\nboth observers strict (number 2)")
    axes[1].set_yticks([]); axes[1].set_xlim(-3.2, 3.2)
    plt.tight_layout(); plt.savefig("density.png", dpi=150)

if __name__ == "__main__":
    main()
