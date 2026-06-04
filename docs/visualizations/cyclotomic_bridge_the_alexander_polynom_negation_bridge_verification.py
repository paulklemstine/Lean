def verify_negation_bridge(p: int) -> bool:
    phi_2p = cyclotomic_polynomial(2*p)
    phi_p = cyclotomic_polynomial(p)
    phi_p_neg = [(-1)**i * c for i, c in enumerate(phi_p)]
    return phi_2p == phi_p_neg