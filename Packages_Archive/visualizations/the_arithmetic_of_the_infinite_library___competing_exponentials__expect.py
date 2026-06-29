"""Visualize the two competing exponentials of the Library of Babel:
expected occurrences (L - k + 1) * b**(-k) versus pattern length k,
for several alphabet sizes b. Requires matplotlib."""
import matplotlib.pyplot as plt

def expected(b: int, L: int, k: int) -> float:
    return (L - k + 1) * b ** (-k)

L = 1000
ks = list(range(1, 13))
plt.figure(figsize=(8, 5))
for b in (2, 4, 25, 256):
    ys = [expected(b, L, k) for k in ks]
    plt.semilogy(ks, ys, marker="o", label=f"b = {b}")
plt.axhline(1.0, color="grey", linestyle="--", linewidth=1, label="E = 1")
plt.xlabel("pattern length k")
plt.ylabel("expected occurrences  (L - k + 1) * b^(-k)   [log scale]")
plt.title(f"Expected pattern occurrences in a random volume (L = {L})")
plt.legend()
plt.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("babel_expected_occurrences.png", dpi=150)
print("wrote babel_expected_occurrences.png")
