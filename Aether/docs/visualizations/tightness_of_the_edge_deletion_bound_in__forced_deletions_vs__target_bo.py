import matplotlib.pyplot as plt

def deletion_vs_t(c: int = 1, d: int = 3, tmax: int = 40) -> None:
    """Plot forced deletions t^2 - (1+c)d n vs the target c d n; show crossing."""
    ts = list(range(1, tmax + 1))
    forced = [t*t - (1 + c) * d * (2 * t) for t in ts]
    target = [c * d * (2 * t) for t in ts]
    t_star = 2 * (1 + 2 * c) * d
    plt.plot(ts, forced, label="forced deletions  t^2-(1+c)d n")
    plt.plot(ts, target, label="target  c d n")
    plt.axvline(t_star, color="gray", ls="--", label=f"threshold t=2(1+2c)d={t_star}")
    plt.xlabel("t"); plt.ylabel("edges"); plt.legend()
    plt.title(f"Equality at threshold (c={c}, d={d})")
    plt.tight_layout(); plt.savefig("deletion_vs_t.png", dpi=150)

if __name__ == "__main__":
    deletion_vs_t()
