"""Visualization: E_p^+ vs p for small connected graphs on 4 vertices."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

def path_spectrum(n: int) -> list[float]:
    return [2.0 * math.cos((k + 1) * math.pi / (n + 1)) for k in range(n)]

def pe(spec: list[float], p: float) -> float:
    return float(sum(x ** p for x in spec if x > 0.0))

def main() -> None:
    ps = np.linspace(2.0, 6.0, 200)
    graphs = {"$P_4$": path_spectrum(4), "$C_4$": [2, 0, 0, -2],
              "$K_{1,3}$": [math.sqrt(3), 0, 0, -math.sqrt(3)]}
    fig, ax = plt.subplots(figsize=(9, 5))
    for name, spec in graphs.items():
        ax.plot(ps, [pe(spec, p) for p in ps], label=name)
    ax.set_title("Positive $p$-energy of 4-vertex connected graphs; the path stays lowest")
    ax.set_xlabel("$p$"); ax.set_ylabel("$E_p^+$"); ax.legend(); ax.grid(alpha=0.3)
    fig.tight_layout(); fig.savefig("p_energy_curves.png", dpi=150)
    print("saved p_energy_curves.png")

if __name__ == "__main__":
    main()
