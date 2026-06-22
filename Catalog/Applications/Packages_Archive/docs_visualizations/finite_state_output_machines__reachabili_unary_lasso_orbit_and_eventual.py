"""Visualise the unary 'lasso' orbit and its eventual periodicity (Theorem 15).
Produces unary_lasso_orbit.png."""
from __future__ import annotations
from typing import Dict, List
import matplotlib.pyplot as plt

def main() -> None:
    nxt: Dict[int, int] = {0: 1, 1: 2, 2: 3, 3: 4, 4: 2}
    q, stream = 0, []
    for _ in range(16):
        stream.append(q)
        q = nxt[q]
    n0, p = 2, 3  # preperiod, period of this lasso
    xs = list(range(len(stream)))
    fig, ax = plt.subplots(figsize=(9, 4))
    ax.plot(xs, stream, "-o", color="#2b6cb0")
    ax.axvspan(-0.5, n0 - 0.5, color="#fed7d7", alpha=0.6, label=f"preperiod (n0={n0})")
    ax.axvspan(n0 - 0.5, len(stream) - 0.5, color="#c6f6d5", alpha=0.5,
               label=f"periodic, p={p}")
    ax.set_xlabel("n"); ax.set_ylabel("out(next^[n](q0))")
    ax.set_title("Unary DFAO output stream is eventually periodic")
    ax.legend(); fig.tight_layout()
    fig.savefig("unary_lasso_orbit.png", dpi=140)
    print("wrote unary_lasso_orbit.png")

if __name__ == "__main__":
    main()
