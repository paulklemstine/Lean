"""Visualization: a multiplicative-positive expression and its log-affine
normal form coincide. We plot eval(e)(x) and exp(<w,log x>+c) along a ray."""
import math
import numpy as np
import matplotlib.pyplot as plt

# expression  3 * x^1.5 * y^-0.5 ,  normal form w=(1.5,-0.5), c=log 3
w = (1.5, -0.5)
c = math.log(3.0)
ts = np.linspace(0.3, 4.0, 200)
direct = [3.0 * (t ** 1.5) * ((0.5 * t) ** -0.5) for t in ts]   # y = 0.5*x
normal = [math.exp(w[0] * math.log(t) + w[1] * math.log(0.5 * t) + c) for t in ts]

fig, ax = plt.subplots(figsize=(9, 5))
ax.plot(ts, direct, lw=4, alpha=0.4, label="direct eval(e)")
ax.plot(ts, normal, "--", lw=2, color="crimson", label="exp(<w,log x>+c)")
ax.set_xlabel("x  (with y = x/2)")
ax.set_ylabel("value")
ax.set_title("Log-affine normal form matches direct evaluation")
ax.legend()
plt.tight_layout()
plt.savefig("logaffine_match.png", dpi=150)
print("saved logaffine_match.png")
