def omega_tower(n):
    if n == 0: return CNFOrdinal.nat(1)
    return CNFOrdinal.omega_to(omega_tower(n-1))