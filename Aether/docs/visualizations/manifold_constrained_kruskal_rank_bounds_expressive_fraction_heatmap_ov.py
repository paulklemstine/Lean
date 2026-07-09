import numpy as np
import matplotlib.pyplot as plt
from math import comb

def cover_count(N: int, d: int) -> int:
    return 2 * sum(comb(N - 1, k) for k in range(d))

max_N, max_d = 16, 12
ratio = np.array([[cover_count(N, d) / 2**N for d in range(1, max_d+1)]
                  for N in range(1, max_N+1)])
plt.figure(figsize=(7, 6))
plt.imshow(ratio, origin="lower", aspect="auto", cmap="viridis",
           extent=[1, max_d, 1, max_N])
plt.colorbar(label="C(N,d) / 2^N  (realizable fraction)")
plt.plot([1, max_d], [1, max_d], "w--", label="N = d (saturation boundary)")
plt.xlabel("parameter budget d"); plt.ylabel("sample size N")
plt.title("Expressive fraction: saturation below N=d, collapse above")
plt.legend(); plt.tight_layout(); plt.savefig("cover_heatmap.png", dpi=150)
print("saved cover_heatmap.png")
