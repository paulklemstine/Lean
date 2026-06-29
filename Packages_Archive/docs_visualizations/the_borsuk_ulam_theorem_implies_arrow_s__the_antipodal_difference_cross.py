"""Visualization: antipodal difference and the forced social tie.

Generates a figure showing a continuous reversal-respecting SWF (sin + 0.5 sin 3x)
on the preference circle, the antipodal difference g(theta) = swf(theta) -
swf(theta+pi), and the guaranteed zero (forced tie). Saves to borsuk_ulam_tie.png.
"""
import math
import numpy as np
import matplotlib.pyplot as plt

PI = math.pi

def swf(t: np.ndarray) -> np.ndarray:
    return np.sin(t) + 0.5 * np.sin(3.0 * t)

theta = np.linspace(0.0, 2.0 * PI, 1000)
g = swf(theta) - swf(theta + PI)

fig, ax = plt.subplots(2, 1, figsize=(9, 7), sharex=True)
ax[0].plot(theta, swf(theta), color="#1f77b4", lw=2, label="swf(theta)")
ax[0].plot(theta, swf(theta + PI), color="#ff7f0e", lw=2, ls="--",
           label="swf(theta + pi)")
ax[0].axhline(0, color="gray", lw=0.8)
ax[0].set_title("Continuous reversal-respecting SWF and its antipode")
ax[0].legend(); ax[0].set_ylabel("social margin")

ax[1].plot(theta, g, color="#2ca02c", lw=2, label="g = swf(t) - swf(t+pi)")
ax[1].axhline(0, color="gray", lw=0.8)
# mark zeros (forced ties / coincidences)
sign = np.sign(g)
zeros = theta[:-1][np.diff(sign) != 0]
ax[1].scatter(zeros, np.zeros_like(zeros), color="red", zorder=5,
              label="antipodal coincidence (forced tie)")
ax[1].set_title("Antipodal difference must cross zero (1-D Borsuk-Ulam)")
ax[1].set_xlabel("preference angle theta"); ax[1].set_ylabel("g(theta)")
ax[1].legend()

plt.tight_layout()
plt.savefig("borsuk_ulam_tie.png", dpi=150)
print("Saved borsuk_ulam_tie.png")
