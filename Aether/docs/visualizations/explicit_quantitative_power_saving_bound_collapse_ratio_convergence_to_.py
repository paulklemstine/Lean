"""Plot the collapse ratio |f(A)|/|A| -> 1/k for the squaring map."""
import matplotlib.pyplot as plt


def image_size(coeffs, A):
    def ev(x):
        acc = 0
        for c in coeffs:
            acc = acc * x + c
        return acc
    return len({ev(a) for a in A})


ns = list(range(1, 300))
ratios = [image_size([1, 0, 0], range(-n, n + 1)) / (2 * n + 1) for n in ns]

plt.figure(figsize=(8, 5))
plt.plot(ns, ratios, label=r"$|f(A)|/|A|$ for $f=x^2$")
plt.axhline(0.5, color="red", ls="--", label=r"limit $1/k = 1/2$")
plt.xlabel("n  (window {-n,...,n})")
plt.ylabel("collapse ratio")
plt.title("Sharpness of the fiber lower bound")
plt.legend()
plt.tight_layout()
plt.savefig("collapse_ratio.png", dpi=150)
print("saved collapse_ratio.png")
