import math
import matplotlib.pyplot as plt

a, C = 2.0, 1.0; thr = a/C
def rk4(f, y0, t1, n):
    h = t1/n; ts, ys, t, y = [0.0], [y0], 0.0, y0
    for _ in range(n):
        k1=f(y); k2=f(y+0.5*h*k1); k3=f(y+0.5*h*k2); k4=f(y+h*k3)
        y += (h/6.0)*(k1+2*k2+2*k3+k4); t += h
        if y > 1e6: break
        ts.append(t); ys.append(y)
    return ts, ys

plt.figure(figsize=(8,5))
for z0 in [0.5, 1.0, 1.8, 2.0, 2.2, 2.6]:
    ts, ys = rk4(lambda z: -a*z + C*z*z, z0, 6.0, 6000)
    plt.plot(ts, ys, label=f'Z0={z0}')
plt.axhline(thr, color='k', ls='--', label=f'threshold a/C={thr}')
plt.ylim(0, 5); plt.xlabel('t'); plt.ylabel('Z(t)')
plt.title('3D competition: threshold a/C separates decay from blow-up')
plt.legend(); plt.tight_layout(); plt.savefig('threshold_phase.png', dpi=150)
print('saved threshold_phase.png')
