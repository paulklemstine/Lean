def pro_spectrum(base, levels):
    return [base.suspend_iter(n) for n in range(levels)]