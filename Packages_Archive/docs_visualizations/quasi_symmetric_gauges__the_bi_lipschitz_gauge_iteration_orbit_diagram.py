import math
import matplotlib.pyplot as plt

def linear_gauge(L):
    return lambda t: (L**2)*t

N = 12
for L in [0.8, 0.95, 1.0, 1.1, 1.3]:
    eta = linear_gauge(L)
    orbit = [1.0]
    for _ in range(N):
        orbit.append(eta(orbit[-1]))
    plt.plot(range(N+1), orbit, marker='o', label=f'L={L} (slope {L**2:.2f})')
plt.yscale('log')
plt.xlabel('iteration n')
plt.ylabel('eta^[n](1)')
plt.title('Gauge iteration orbits (Theorem 4.4)')
plt.legend()
plt.grid(True, which='both', alpha=0.3)
plt.tight_layout()
plt.savefig('gauge_iteration.png', dpi=150)
print('saved gauge_iteration.png')