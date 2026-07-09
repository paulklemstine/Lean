import matplotlib.pyplot as plt

def powers_of_two(k):
    return [2 ** i for i in range(k)]

k = 5
s = powers_of_two(k)
sums = {}
for i, a in enumerate(s):
    for j, b in enumerate(s):
        if i <= j:
            sums.setdefault(a + b, []).append((a, b))

fig, ax = plt.subplots(figsize=(9, 5))
xs = sorted(sums)
ys = [len(sums[x]) for x in xs]
ax.stem(xs, ys)
ax.set_xlabel("sum value a + b"); ax.set_ylabel("number of representations")
ax.set_title(f"Powers of two P_{k}={s}: every sum has a unique representation")
ax.set_ylim(0, 2)
plt.tight_layout(); plt.savefig("powers_of_two_sums.png", dpi=150)
