import numpy as np
import matplotlib.pyplot as plt

t = np.linspace(-3, 3, 400)
for k, (slope, offset) in enumerate([(1.0, 0.0), (0.6, 1.0)]):
    line1 = offset + slope * t      # monomial A
    line2 = 0.5 * np.ones_like(t)   # monomial B (constant)
    env = np.minimum(line1, line2)  # tropical sum = min
    plt.figure(figsize=(6, 4))
    plt.plot(t, line1, '--', label='monomial A')
    plt.plot(t, line2, '--', label='monomial B')
    plt.plot(t, env, 'k', lw=2, label='tropical poly = min')
    idx = int(np.argmin(np.abs(line1 - line2)))
    plt.scatter([t[idx]], [env[idx]], color='red', zorder=5, label='corner (tie)')
    plt.legend(); plt.title('Corner = where the minimum is attained twice')
    plt.xlabel('t'); plt.ylabel('value')
    plt.tight_layout(); plt.savefig(f'corner_{k}.png', dpi=130)
    print(f'wrote corner_{k}.png')
