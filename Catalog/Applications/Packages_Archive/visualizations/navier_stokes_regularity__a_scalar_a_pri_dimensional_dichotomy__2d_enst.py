import math
import matplotlib.pyplot as plt

def rk4(f, y0, t0, t1, n):
    h = (t1 - t0) / n; ts, ys, t, y = [t0], [y0], t0, y0
    for _ in range(n):
        k1 = f(t, y); k2 = f(t+0.5*h, y+0.5*h*k1)
        k3 = f(t+0.5*h, y+0.5*h*k2); k4 = f(t+h, y+h*k3)
        y += (h/6.0)*(k1+2*k2+2*k3+k4); t += h; ts.append(t); ys.append(y)
    return ts, ys

fig, ax = plt.subplots(1, 2, figsize=(12, 5))
ts2, zs2 = rk4(lambda t, z: -2*0.1*(1+math.sin(t)**2)*z, 5.0, 0.0, 20.0, 4000)
ax[0].plot(ts2, zs2, 'b-'); ax[0].set_title('2D enstrophy: monotone decay')
ax[0].set_xlabel('t'); ax[0].set_ylabel('Z(t)')
C, z0 = 0.5, 2.0; tstar = 1.0/(2*C*z0**2)
ts3, zs3 = rk4(lambda t, z: C*z**3, z0, 0.0, 0.995*tstar, 20000)
env = [1.0/math.sqrt(2*C*(tstar-t)) for t in ts3]
ax[1].plot(ts3, zs3, 'r-', label='Z(t)')
ax[1].plot(ts3, env, 'k--', label='sharp envelope')
ax[1].axvline(tstar, color='gray', ls=':', label='T*')
ax[1].set_title('3D supercritical: finite-time blow-up')
ax[1].set_xlabel('t'); ax[1].set_ylabel('Z(t)'); ax[1].legend()
plt.tight_layout(); plt.savefig('dimensional_dichotomy.png', dpi=150)
print('saved dimensional_dichotomy.png')
