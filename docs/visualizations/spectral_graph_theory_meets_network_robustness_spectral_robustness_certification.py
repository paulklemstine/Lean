def spectral_robustness_radius(alg_conn, max_deg, margin, base_lip, k):
    c = 1.0 - alg_conn / max_deg
    eff_lip = (c ** k) * base_lip
    return margin / eff_lip if eff_lip > 0 else float('inf')