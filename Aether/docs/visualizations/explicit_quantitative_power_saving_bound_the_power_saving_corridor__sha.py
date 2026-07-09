"""Visualize the corridor |A|/k <= |f(A)| <= |A|^(k-1/k^2)."""
import matplotlib.pyplot as plt


def image_size(coeffs, A):
    def ev(x):
        acc = 0
        for c in coeffs:
            acc = acc * x + c
        return acc
    return len({ev(a) for a in A})


k = 2
coeffs = [1, 0, 0]  # x^2
Ns = list(range(2, 60))
actual, lower, upper = [], [], []
for N in Ns:
    A = range(-N, N + 1)
    n = 2 * N + 1
    actual.append(image_size(coeffs, A))
    lower.append(n / k)
    upper.append(n ** (k - 1.0 / (k * k)))

plt.figure(figsize=(8, 5))
plt.fill_between(Ns, lower, upper, alpha=0.2, label="corridor")
plt.plot(Ns, actual, "o-", ms=3, label=r"$|f(A)|$")
plt.plot(Ns, lower, "--", label=r"lower $|A|/k$")
plt.plot(Ns, upper, ":", label=r"upper $|A|^{k-1/k^2}$")
plt.yscale("log")
plt.xlabel("N  (window {-N,...,N})")
plt.ylabel("cardinality (log scale)")
plt.title("The power-saving corridor for f = x^2")
plt.legend()
plt.tight_layout()
plt.savefig("corridor.png", dpi=150)
print("saved corridor.png")
