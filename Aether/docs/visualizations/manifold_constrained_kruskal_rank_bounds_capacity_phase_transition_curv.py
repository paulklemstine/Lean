import numpy as np
import matplotlib.pyplot as plt
from math import comb

def cover_count(N: int, d: int) -> int:
    return 2 * sum(comb(N - 1, k) for k in range(d))

plt.figure(figsize=(8, 5))
for p in (3, 5, 8):
    Ns = list(range(1, 4*p + 1))
    frac = [cover_count(N, p) / 2**N for N in Ns]
    plt.plot([N/p for N in Ns], frac, marker="o", ms=3, label=f"budget p={p}")
plt.axvline(2, color="k", ls="--", label="conjectured threshold N=2p")
plt.xlabel("normalized sample size  N / p")
plt.ylabel("realizable fraction  C(N,p) / 2^N")
plt.title("Capacity phase transition near N = 2p")
plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig("cover_transition.png", dpi=150)
print("saved cover_transition.png")
