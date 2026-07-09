"""Bar chart: number of bipartite partial duals = 2^(dim ker) as the
kernel dimension grows."""
import matplotlib.pyplot as plt

dims = list(range(0, 8))
counts = [2 ** k for k in dims]
plt.figure(figsize=(8, 5))
bars = plt.bar([str(k) for k in dims], counts, color="#2ca02c")
for b, c in zip(bars, counts):
    plt.text(b.get_x() + b.get_width() / 2, c, str(c), ha="center", va="bottom")
plt.yscale("log", base=2)
plt.xlabel("dim ker(cross_J)")
plt.ylabel("number of bipartite partial duals (log scale)")
plt.title("Bipartite partial duals: a power of two")
plt.tight_layout(); plt.savefig("count_power_of_two.png", dpi=150)
print("wrote count_power_of_two.png")
