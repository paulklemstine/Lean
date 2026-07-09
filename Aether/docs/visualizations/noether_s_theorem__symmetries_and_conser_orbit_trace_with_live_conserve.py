import math
import matplotlib.pyplot as plt

def acceleration(s, k):
    x, y, _, _ = s
    r = math.hypot(x, y)
    f = -k / r**3
    return f*x, f*y

def integrate(s0, k, dt, steps):
    x, y, vx, vy = s0
    xs, ys, lz, en, am = [], [], [], [], []
    ax, ay = acceleration((x,y,vx,vy), k)
    for _ in range(steps):
        vx += 0.5*dt*ax; vy += 0.5*dt*ay
        x += dt*vx; y += dt*vy
        ax, ay = acceleration((x,y,vx,vy), k)
        vx += 0.5*dt*ax; vy += 0.5*dt*ay
        r = math.hypot(x, y)
        L = x*vy - y*vx
        xs.append(x); ys.append(y)
        lz.append(L)
        en.append(0.5*(vx*vx+vy*vy) - k/r)
        Ax = L*vy - k*x/r; Ay = -L*vx - k*y/r
        am.append(math.hypot(Ax, Ay))
    return xs, ys, lz, en, am

k = 1.0; e = 0.6; a = 1.0
rp = a*(1-e); vp = math.sqrt(k*(2/rp - 1/a))
xs, ys, lz, en, am = integrate((rp,0,0,vp), k, 1e-4, 120000)

fig, axs = plt.subplots(2, 2, figsize=(11, 9))
axs[0,0].plot(xs, ys, lw=0.6); axs[0,0].plot(0,0,'o',color='orange')
axs[0,0].set_title("Kepler orbit"); axs[0,0].set_aspect('equal')
axs[0,1].plot(lz); axs[0,1].set_title("Angular momentum L_z")
axs[1,0].plot(en, color='green'); axs[1,0].set_title("Energy E")
axs[1,1].plot(am, color='red'); axs[1,1].set_title("|LRL vector|")
plt.tight_layout(); plt.savefig("kepler_conservation.png", dpi=130)
print("saved kepler_conservation.png")
