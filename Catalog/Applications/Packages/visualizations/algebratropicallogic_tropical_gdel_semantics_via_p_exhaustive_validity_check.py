def validity_check(semiring, gamma, sigma, variables, domain):
    """Check if sigma is valid given gamma in a finite semiring."""
    import itertools
    for vals in itertools.product(domain, repeat=len(variables)):
        interp = dict(zip(variables, vals))
        # Check all premises
        all_sat = all(
            semiring.nat_le(
                eval_formula(tau.lhs, interp, semiring),
                eval_formula(tau.rhs, interp, semiring)
            ) for tau in gamma
        )
        if all_sat:
            if not semiring.nat_le(
                eval_formula(sigma.lhs, interp, semiring),
                eval_formula(sigma.rhs, interp, semiring)
            ):
                return False, interp
    return True, None
