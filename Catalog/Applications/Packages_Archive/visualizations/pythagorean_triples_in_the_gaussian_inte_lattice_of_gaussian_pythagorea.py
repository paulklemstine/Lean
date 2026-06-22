import matplotlib.pyplot as plt


def mul(s, t):
    return (s[0] * t[0] - s[1] * t[1], s[0] * t[1] + s[1] * t[0])


def add(s, t):
    return (s[0] + t[0], s[1] + t[1])


def sub(s, t):
    return (s[0] - t[0], s[1] - t[1])


pts_x, pts_y, norms = [], [], []
B = 3
for sr in range(-B, B + 1):
    for si in range(-B, B + 1):
        for tr in range(-B, B + 1):
            for ti in range(-B, B + 1):
                s, t = (sr, si), (tr, ti)
                if t == (0, 0):
                    continue
                z = add(mul(s, s), mul(t, t))  # z = s^2 + t^2
                pts_x.append(z[0]); pts_y.append(z[1])
                norms.append(z[0] ** 2 + z[1] ** 2)

plt.figure(figsize=(7, 7))
sc = plt.scatter(pts_x, pts_y, c=norms, cmap="viridis", s=12, alpha=0.7)
plt.colorbar(sc, label=r"$N(z)=\mathrm{Re}(z)^2+\mathrm{Im}(z)^2$")
plt.title("Hypotenuses z = s^2 + t^2 of Gaussian Pythagorean triples")
plt.xlabel("Re(z)"); plt.ylabel("Im(z)")
plt.axhline(0, color="gray", lw=0.5); plt.axvline(0, color="gray", lw=0.5)
plt.gca().set_aspect("equal"); plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig("gaussian_hypotenuse_lattice.png", dpi=150)
print("wrote gaussian_hypotenuse_lattice.png")
