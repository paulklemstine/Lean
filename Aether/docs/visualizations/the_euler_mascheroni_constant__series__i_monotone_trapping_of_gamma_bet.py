import math
import matplotlib.pyplot as plt

GAMMA = 0.5772156649015329

def L(n):
    H = sum(1.0 / k for k in range(1, n + 1))
    return H - math.log(n + 1)

def U(n):
    H = sum(1.0 / k for k in range(1, n + 1))
    return H - math.log(n)

ns = list(range(1, 60))
lows = [L(n) for n in ns]
highs = [U(n) for n in ns]
plt.figure(figsize=(8, 5))
plt.fill_between(ns, lows, highs, alpha=0.2, color="purple", label="trapping band")
plt.plot(ns, lows, "o-", ms=3, label=r"$L_n = H_n - \ln(n+1)$ (lower)")
plt.plot(ns, highs, "s-", ms=3, label=r"$U_n = H_n - \ln n$ (upper)")
plt.axhline(GAMMA, color="black", ls="--", label=r"$\gamma$")
plt.xlabel("n"); plt.ylabel("approximant")
plt.title("Monotone trapping of the Euler-Mascheroni constant")
plt.legend(); plt.tight_layout()
plt.savefig("convergence.png", dpi=150)
print("saved convergence.png")
