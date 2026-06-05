def compute_recurrence_spectrum(f, x0, max_period, tol=1e-10, transient=1000):
    x = x0
    for _ in range(transient): x = f(x)
    orbit = [x]
    for _ in range(max_period * 50):
        x = f(x); orbit.append(x)
    spectrum = {}
    for n in range(1, max_period + 1):
        points = []
        for i in range(len(orbit) - n):
            if abs(orbit[i+n] - orbit[i]) < tol:
                is_min = all(abs(orbit[i+d] - orbit[i]) >= tol for d in range(1,n) if n%d==0)
                if is_min and not any(abs(p-orbit[i]) < tol*100 for p in points):
                    points.append(orbit[i])
        if points: spectrum[n] = points
    return spectrum