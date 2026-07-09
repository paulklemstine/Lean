"""Visualization: balance gap |E_p^+ - E_p^-| for bipartite vs non-bipartite spectra."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

def path_spectrum(n: int) -> list[float]:
    return [2.0 * math.cos((k + 1) * math.pi / (n + 1)) for k in range(n)]

def gap(spec: list[float], p: float) -> float:
    pos = sum(x ** p for x in spec if x > 0.0)
    neg = sum((-x) ** p for x in spec if x < 0.0)
    return abs(pos - neg)

def main() -> None:
    ps = np.linspace(1.5, 5.0, 200)
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.plot(ps, [gap(path_spectrum(8), p) for p in ps], label="$P_8$ (bipartite)")
    ax.plot(ps, [gap([2.0, -1.0, -1.0], p) for p in ps], label="$K_3$ (non-bipartite)")
    ax.set_title("Bipartite balance gap $|E_p^+ - E_p^-|$: zero exactly for bipartite spectra")
    ax.set_xlabel("$p$"); ax.set_ylabel("balance gap"); ax.legend(); ax.grid(alpha=0.3)
    fig.tight_layout(); fig.savefig("balance_gap.png", dpi=150)
    print("saved balance_gap.png")

if __name__ == "__main__":
    main()
