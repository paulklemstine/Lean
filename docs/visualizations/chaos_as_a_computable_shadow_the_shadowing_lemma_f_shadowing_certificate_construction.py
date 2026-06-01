def make_certificate(f, orbit, L):
    delta = max(abs(orbit[i+1] - f(orbit[i])) for i in range(len(orbit)-1))
    bound = delta / (1.0 - L)
    shadow = [orbit[0]]
    for i in range(len(orbit)-1):
        shadow.append(f(shadow[-1]))
    return {'start': orbit[0], 'bound': bound, 'delta': delta, 'shadow': shadow}