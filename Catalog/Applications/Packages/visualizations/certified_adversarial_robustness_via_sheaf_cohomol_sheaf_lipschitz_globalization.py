def sheaf_lipschitz_globalization(margins, lipschitz_consts):
    local_radii = [m/L for m, L in zip(margins, lipschitz_consts) if m > 0 and L > 0]
    return min(local_radii) if local_radii else 0.0