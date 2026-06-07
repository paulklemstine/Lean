import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def simulate_gap(n=200):
    dc, df = 17/81, 30/81
    d = np.linspace(0, 1, n)
    g = np.zeros_like(d)
    for i in range(n):
        if d[i] < dc:
            g[i] = 0.8 * np.exp(-2*(d[i]/dc)**2)
        elif d[i] < df:
            t = (d[i]-dc)/(df-dc)
            g[i] = 0.8*np.exp(-2)*(1-t)**2
    return d, g

d, g = simulate_gap()
fig, ax = plt.subplots(figsize=(10,6))
ax.plot(d, g, 'b-', lw=2)
ax.axvline(17/81, color='r', ls='--', label='d_c=17/81')
ax.axvline(30/81, color='orange', ls='--', label='d_f=30/81')
ax.set_xlabel('Density'); ax.set_ylabel('Gap')
ax.set_title('Spectral Gap Phase Transition')
ax.legend()
plt.savefig('phase_transition.png', dpi=150)
print('Saved phase_transition.png')