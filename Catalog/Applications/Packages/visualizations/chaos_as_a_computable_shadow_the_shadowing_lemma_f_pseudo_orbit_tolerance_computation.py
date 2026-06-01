def pseudo_orbit_tolerance(f, orbit):
    return max(abs(orbit[i+1] - f(orbit[i])) for i in range(len(orbit)-1))