def tropical_eval(profile, t):
    return min(profile[i] + i * t for i in range(len(profile)))