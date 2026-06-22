"""Bar chart: total Betti number 2^{w1}*2^{wL}*mid vs architecture."""
import matplotlib.pyplot as plt

def total_betti(w1: int, wL: int, mid: int) -> int:
    return (2 ** w1) * (2 ** wL) * mid

archs = [
    ("(2,2)|mid=1", 2, 2, 1),
    ("(3,2)|mid=20", 3, 2, 20),
    ("(4,3)|mid=2", 4, 3, 2),
    ("(1,5)|mid=27", 1, 5, 27),
    ("(5,5)|mid=1", 5, 5, 1),
]
labels = [a[0] for a in archs]
values = [total_betti(a[1], a[2], a[3]) for a in archs]

fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.bar(labels, values, color="#4c72b0")
ax.set_yscale("log")
ax.set_ylabel("total Betti number B(f)  (log scale)")
ax.set_title("Extremal total Betti number  B(f) = 2^{w1} * 2^{wL} * mid")
for b, v in zip(bars, values):
    ax.text(b.get_x() + b.get_width() / 2, v, str(v),
            ha="center", va="bottom")
plt.xticks(rotation=20)
plt.tight_layout()
plt.savefig("total_betti_bars.png", dpi=150)
print("saved total_betti_bars.png")
