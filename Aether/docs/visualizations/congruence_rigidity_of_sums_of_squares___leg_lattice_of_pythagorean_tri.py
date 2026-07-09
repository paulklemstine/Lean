import matplotlib.pyplot as plt

# Scatter the legs (a, b) of parametrized Pythagorean triples, colored by
# whether the area ab/2 is (always) divisible by 6.
xs, ys = [], []
for m in range(2, 40):
    for n in range(1, m):
        a, b = m * m - n * n, 2 * m * n
        xs.append(a); ys.append(b)

plt.figure(figsize=(7, 7))
plt.scatter(xs, ys, s=8, c="teal", alpha=0.6)
plt.title("Legs (a, b) of Pythagorean triples - area ab/2 is always a multiple of 6")
plt.xlabel("leg a = m^2 - n^2"); plt.ylabel("leg b = 2mn")
plt.tight_layout(); plt.savefig("triple_legs.png", dpi=140)
print("saved triple_legs.png")
