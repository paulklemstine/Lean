import matplotlib.pyplot as plt
from math import comb

def ball_volume(n: int, q: int, t: int) -> int:
    t = min(t, n)
    return sum(comb(n, i) * (q - 1) ** i for i in range(t + 1))

n = 12
plt.figure(figsize=(8, 5))
for q in (2, 3, 4):
    ts = list(range(n + 1))
    vs = [ball_volume(n, q, t) for t in ts]
    plt.semilogy(ts, vs, marker="o", label=f"q={q}, V(t)")
    plt.axhline(q ** n, linestyle="--", alpha=0.4)
plt.xlabel("ball radius t")
plt.ylabel("ball volume V(t)  (log scale)")
plt.title(f"Hamming ball volume vs radius (n={n})")
plt.legend()
plt.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("ball_volume_growth.png", dpi=150)
print("saved ball_volume_growth.png")
