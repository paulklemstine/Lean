import math
import numpy as np
import matplotlib.pyplot as plt

def qform(h, x):
    hx = h @ x
    return np.vdot(x, hx).real

H_Z = np.array([[0, 0], [0, 1]], dtype=complex)
H_X = 0.5 * np.array([[1, -1], [-1, 1]], dtype=complex)
H = H_Z + H_X

thetas = np.linspace(0, np.pi, 400)
eZ, eX, eH = [], [], []
for t in thetas:
    x = np.array([math.cos(t / 2), math.sin(t / 2)], dtype=complex)
    eZ.append(qform(H_Z, x)); eX.append(qform(H_X, x)); eH.append(qform(H, x))

plt.figure(figsize=(8, 5))
plt.plot(thetas, eZ, label="qform(H_Z, x)")
plt.plot(thetas, eX, label="qform(H_X, x)")
plt.plot(thetas, eH, label="qform(H_Z + H_X, x)", linewidth=2.5)
plt.axhline((2 - math.sqrt(2)) / 2, ls="--", color="gray",
            label="(2 - sqrt 2)/2 ~ 0.293")
plt.xlabel("Bloch angle theta"); plt.ylabel("energy")
plt.title("Frustration: the sum's minimum is lifted above 0")
plt.legend(); plt.tight_layout(); plt.savefig("frustration_landscape.png", dpi=150)
print("saved frustration_landscape.png")
