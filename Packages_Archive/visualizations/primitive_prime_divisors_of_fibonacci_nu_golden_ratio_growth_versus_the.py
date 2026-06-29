import numpy as np
import matplotlib.pyplot as plt

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

# Growth vs imprimitive cap: log10(F_n) (exponential, slope ~ log10(phi))
# against the lower bound 2^floor((n-2)/2) and the size of the index n.
ns = list(range(2, 41))
logF = [np.log10(fib(n)) for n in ns]
logBound = [((n - 2) // 2) * np.log10(2) for n in ns]
logN = [np.log10(n) for n in ns]

plt.figure(figsize=(10, 6))
plt.plot(ns, logF, "o-", label="log10 F_n  (golden-ratio growth)")
plt.plot(ns, logBound, "s--", label="log10 2^floor((n-2)/2)  (lower bound)")
plt.plot(ns, logN, "^:", label="log10 n  (index size / imprimitive scale)")
plt.xlabel("index n")
plt.ylabel("log10 value")
plt.title("Exponential growth of F_n outpaces the logarithmic imprimitive cap")
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("fib_growth_vs_cap.png", dpi=150)
print("saved fib_growth_vs_cap.png")
