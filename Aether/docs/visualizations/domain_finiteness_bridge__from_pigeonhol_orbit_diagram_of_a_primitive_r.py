import numpy as np
import matplotlib.pyplot as plt

def primitive_root(p: int) -> int:
    def order(a):
        k, cur = 1, a % p
        while cur != 1:
            cur = (cur * a) % p; k += 1
        return k
    return next(g for g in range(2, p) if order(g) == p - 1)

def plot_primitive_root_orbit(p: int) -> None:
    g = primitive_root(p)
    powers, cur = [], 1
    for _ in range(p - 1):
        cur = (cur * g) % p; powers.append(cur)
    angles = [2 * np.pi * k / (p - 1) for k in range(p - 1)]
    xs = [np.cos(a) for a in angles]; ys = [np.sin(a) for a in angles]
    fig, ax = plt.subplots(figsize=(6, 6))
    ax.plot(xs + [xs[0]], ys + [ys[0]], "-o", color="crimson")
    for x, y, v in zip(xs, ys, powers):
        ax.text(1.12 * x, 1.12 * y, str(v), ha="center", va="center")
    ax.set_title(f"Orbit of primitive root g={g} mod {p}")
    ax.set_aspect("equal"); ax.axis("off")
    plt.tight_layout()
    plt.savefig(f"primitive_root_orbit_{p}.png", dpi=150)
    print(f"saved primitive_root_orbit_{p}.png")

if __name__ == "__main__":
    plot_primitive_root_orbit(13)
