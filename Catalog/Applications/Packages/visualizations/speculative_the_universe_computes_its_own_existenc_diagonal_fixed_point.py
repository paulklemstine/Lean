def diagonal_fixed_point(phi, bot=0.0, tol=1e-12):
    def diagonal(x):
        return phi(x, x)
    return kleene_iterate(diagonal, bot, tol)