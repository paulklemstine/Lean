"""Visualization: Landauer heat of proof normalization vs proof length.

Generates a bar chart of the exact cost k*T*n*ln2 (room temperature) and an
overlay showing the incompressibility gap (2^n length-n proofs vs 2^n-1 shorter).
"""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

K = 1.380649e-23
T = 300.0

def main() -> None:
    ns = list(range(1, 13))
    heat = [K * T * n * math.log(2) for n in ns]
    length_n = [2 ** n for n in ns]
    shorter = [2 ** n - 1 for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.bar(ns, heat, color="#c0392b")
    ax1.set_title("Landauer heat of proof normalization\n(cost = k*T*n*ln2 at 300 K)")
    ax1.set_xlabel("proof length n")
    ax1.set_ylabel("heat dissipated (J)")

    ax2.plot(ns, length_n, "o-", label="length-n proofs (2^n)", color="#2980b9")
    ax2.plot(ns, shorter, "s--", label="all shorter proofs (2^n - 1)", color="#27ae60")
    ax2.set_yscale("log")
    ax2.set_title("Incompressibility gap: 2^n - 1 < 2^n")
    ax2.set_xlabel("proof length n")
    ax2.set_ylabel("count (log scale)")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("landauer_proof_erasure.png", dpi=150)
    print("saved landauer_proof_erasure.png")

if __name__ == "__main__":
    main()
