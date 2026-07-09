"""Visualization: path spectra as sign-symmetric fans of cosines."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

def path_spectrum(n: int) -> list[float]:
    return [2.0 * math.cos((k + 1) * math.pi / (n + 1)) for k in range(n)]

def main() -> None:
    fig, ax = plt.subplots(figsize=(9, 5))
    for n in (5, 8, 12, 16):
        ax.plot(range(1, n + 1), path_spectrum(n), "o-", label=f"$P_{{{n}}}$")
    ax.axhline(0.0, color="k", lw=1)
    ax.set_title("Path spectra $\\lambda_k = 2\\cos((k+1)\\pi/(n+1))$: mirror-symmetric about 0")
    ax.set_xlabel("index $k+1$"); ax.set_ylabel("eigenvalue $\\lambda_k$")
    ax.legend(); ax.grid(alpha=0.3); fig.tight_layout()
    fig.savefig("path_spectrum.png", dpi=150)
    print("saved path_spectrum.png")

if __name__ == "__main__":
    main()
