"""
Visualization: log-log convergence of the uniform error ||f - N||_inf.
Generates `relu_error_decay.png` comparing measured error, the certified
bound L/n, and the sharp bound L/(2n). Requires matplotlib.
"""
import math
import matplotlib.pyplot as plt

def relu(x: float) -> float:
    return max(0.0, x)

def net(f, n: int, x: float) -> float:
    val = f(0.0)
    for k in range(n):
        w = n * (f((k + 1) / n) - f(k / n))
        val += w * (relu(x - k / n) - relu(x - (k + 1) / n))
    return val

def sup_err(f, n: int, m: int = 4000) -> float:
    return max(abs(f(i / m) - net(f, n, i / m)) for i in range(m + 1))

f = lambda x: math.sin(3.0 * x)
L = 3.0
ns = [2, 4, 8, 16, 32, 64, 128, 256]
meas = [sup_err(f, n) for n in ns]

plt.figure(figsize=(7, 5.5))
plt.loglog(ns, meas, "o-", label="measured ||f - N||_inf")
plt.loglog(ns, [L / n for n in ns], "--", label="certified bound L/n")
plt.loglog(ns, [L / (2 * n) for n in ns], ":", label="sharp bound L/(2n)")
plt.loglog(ns, [L / (8 * n * n) * 9 for n in ns], "-.",
           label="C² regime ~ M/(8n²)")
plt.xlabel("resolution n (width = 2n)")
plt.ylabel("uniform error")
plt.title("Convergence of certified ReLU approximation, f(x)=sin(3x)")
plt.legend(); plt.grid(alpha=0.3, which="both")
plt.tight_layout()
plt.savefig("relu_error_decay.png", dpi=140)
print("wrote relu_error_decay.png")
