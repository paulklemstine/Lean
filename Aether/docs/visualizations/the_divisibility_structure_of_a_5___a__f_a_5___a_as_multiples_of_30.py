import matplotlib.pyplot as plt

def defect(a: int) -> int:
    return a ** 5 - a

xs = list(range(0, 9))
ys = [defect(a) // 30 for a in xs]

fig, ax = plt.subplots(figsize=(8, 5))
ax.bar(xs, ys, color="#3b7dd8")
for x, y in zip(xs, ys):
    ax.text(x, y + 0.3, str(defect(x)), ha="center", fontsize=8)
ax.set_xlabel("a")
ax.set_ylabel("(a^5 - a) / 30")
ax.set_title("a^5 - a is always a multiple of 30")
plt.tight_layout()
plt.savefig("defect_multiples_of_30.png", dpi=150)
print("saved defect_multiples_of_30.png")
