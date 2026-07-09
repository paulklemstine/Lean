"""
Visualise the even-diagonal Ramsey sandwich 2^(m-1) < R(2m,2m) <= 4^(2m-1)
on a logarithmic scale, making the exponential gap explicit.
Requires matplotlib.  Run: python sandwich_plot.py
"""
from typing import List
import matplotlib.pyplot as plt

def sandwich_plot(m_min: int = 4, m_max: int = 12) -> None:
    ms: List[int] = list(range(m_min, m_max + 1))
    ks: List[int] = [2 * m for m in ms]
    lower: List[int] = [2 ** (m - 1) for m in ms]
    upper: List[int] = [4 ** (2 * m - 1) for m in ms]

    fig, ax = plt.subplots(figsize=(9, 6))
    ax.fill_between(ks, lower, upper, alpha=0.2, color="tab:blue",
                    label="possible region for R(2m,2m)")
    ax.plot(ks, lower, "o-", color="tab:green", label=r"lower $2^{m-1}$")
    ax.plot(ks, upper, "s-", color="tab:red", label=r"upper $4^{2m-1}$")
    ax.set_yscale("log")
    ax.set_xlabel("clique size  k = 2m")
    ax.set_ylabel("number of vertices (log scale)")
    ax.set_title("The two-sided exponential sandwich for diagonal Ramsey numbers")
    ax.legend()
    ax.grid(True, which="both", ls=":", alpha=0.5)
    fig.tight_layout()
    fig.savefig("sandwich_plot.png", dpi=150)
    print("wrote sandwich_plot.png")

if __name__ == "__main__":
    sandwich_plot()
