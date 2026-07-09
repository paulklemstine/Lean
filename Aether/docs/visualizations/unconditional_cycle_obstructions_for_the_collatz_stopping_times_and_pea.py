"""Visualization: Collatz stopping times and peak altitudes for n = 1..10000."""
import matplotlib.pyplot as plt

def T(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1

def profile(n: int):
    steps, peak, m = 0, n, n
    while m != 1:
        m = T(m); peak = max(peak, m); steps += 1
    return steps, peak

N = 10000
xs = list(range(1, N + 1))
steps = []
peaks = []
for n in xs:
    s, p = profile(n)
    steps.append(s); peaks.append(p)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
ax1.scatter(xs, steps, s=1, alpha=0.4, color="navy")
ax1.set_title("Collatz total stopping time"); ax1.set_xlabel("n"); ax1.set_ylabel("steps to reach 1")
ax2.scatter(xs, peaks, s=1, alpha=0.4, color="crimson")
ax2.set_yscale("log")
ax2.set_title("Peak altitude of orbit"); ax2.set_xlabel("n"); ax2.set_ylabel("max value (log scale)")
plt.tight_layout()
plt.savefig("collatz_profiles.png", dpi=120)
print("saved collatz_profiles.png")
