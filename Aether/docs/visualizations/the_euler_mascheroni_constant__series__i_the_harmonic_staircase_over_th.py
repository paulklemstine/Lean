import math
import numpy as np
import matplotlib.pyplot as plt

xs = np.linspace(1, 8, 2000)
hyp = 1.0 / xs
stair = 1.0 / np.floor(xs)
plt.figure(figsize=(8, 5))
plt.plot(xs, hyp, color="navy", lw=2, label=r"$1/x$")
plt.step(xs, stair, where="post", color="crimson", lw=1.5,
         label=r"$1/\lfloor x\rfloor$ (harmonic staircase)")
plt.fill_between(xs, hyp, stair, step="post", alpha=0.25, color="orange",
                 label=r"area $= \gamma$ as $N\to\infty$")
plt.xlabel("x"); plt.ylabel("height")
plt.title(r"$\gamma = \int_1^\infty (1/\lfloor x\rfloor - 1/x)\,dx$")
plt.legend(); plt.tight_layout()
plt.savefig("staircase.png", dpi=150)
print("saved staircase.png")
