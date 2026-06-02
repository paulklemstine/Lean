def gradient_flow(alpha, r0, dt=0.001, n_steps=10000):
    trajectory = [r0]
    r = r0
    for _ in range(n_steps):
        dr = 1.0 - 2.0*alpha*r + 3.0*alpha*r**2
        r = max(0.0, min(1.0, r + dt * dr))
        trajectory.append(r)
    return trajectory