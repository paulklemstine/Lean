import cmath, math
import numpy as np
import matplotlib.pyplot as plt

def fib_F():
    t = 1.0 / ((1.0 + math.sqrt(5.0)) / 2.0); s = math.sqrt(t)
    return np.array([[t, s], [s, -t]], dtype=complex)

def fib_R():
    return np.array([[cmath.exp(-4j*math.pi/5), 0], [0, cmath.exp(3j*math.pi/5)]], dtype=complex)

F, R = fib_F(), fib_R()
B1, B2 = R, F @ R @ F
lhs, rhs = B1 @ B2 @ B1, B2 @ B1 @ B2

theta = np.linspace(0, 2*np.pi, 400)
fig, ax = plt.subplots(figsize=(6, 6))
ax.plot(np.cos(theta), np.sin(theta), 'k--', lw=0.8, label='unit circle')
for M, mk, lbl in [(R, 'o', 'R phases'),
                   (lhs, 'x', 'eig(B1 B2 B1)'),
                   (rhs, '+', 'eig(B2 B1 B2)')]:
    ev = np.linalg.eigvals(M)
    ax.scatter(ev.real, ev.imag, marker=mk, s=120, label=lbl)
ax.set_aspect('equal'); ax.legend(); ax.set_title('Fibonacci braiding: eigenphases on the unit circle')
ax.set_xlabel('Re'); ax.set_ylabel('Im')
plt.tight_layout(); plt.savefig('braid_relation_eigenphases.png', dpi=150)
print('saved braid_relation_eigenphases.png')
