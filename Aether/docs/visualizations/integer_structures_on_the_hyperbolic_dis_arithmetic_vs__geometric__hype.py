import math
import numpy as np
import matplotlib.pyplot as plt

h_mid = lambda s, t: math.sqrt(s * t)
s, t = 1.0, 1.0
us = np.linspace(1, 40, 200)
left  = [h_mid(h_mid(s, t), u) for u in us]
right = [h_mid(s, h_mid(t, u)) for u in us]
fig, ax = plt.subplots(figsize=(7, 5))
ax.plot(us, left,  label="m(m(s,t),u)")
ax.plot(us, right, label="m(s,m(t,u))")
ax.fill_between(us, left, right, alpha=0.2, color='orange',
                label="associativity gap")
ax.set_xlabel("u"); ax.set_ylabel("midpoint"); ax.legend()
ax.set_title("Hyperbolic midpoint is not associative (s=t=1)")
plt.savefig("midpoint_gap.png", dpi=150); print("saved midpoint_gap.png")
