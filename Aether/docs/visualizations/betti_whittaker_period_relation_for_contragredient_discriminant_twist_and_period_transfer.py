def discriminant_twist(eps_disc: int, b: int) -> int:
    """Compute the period twist eps(disc(k))**b in {+1,-1}.

    eps_disc is a quadratic character value (+1 or -1); b is the bottom degree.
    Reduces to a single parity test once eps_disc is known.
    """
    assert eps_disc in (1, -1), "quadratic character value must be +1 or -1"
    if eps_disc == 1:
        return 1
    return -1 if (b % 2 == 1) else 1

def period_dual(period_pi: complex, eps_disc: int, b: int) -> complex:
    """P^b(pi_dual) = eps(disc)**b * P^b(pi)."""
    return discriminant_twist(eps_disc, b) * period_pi
