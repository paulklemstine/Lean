def certified_radius(margin, lipschitz_const):
    '''Compute certified robustness radius.
    
    Args:
        margin: Classification margin y * f(x)
        lipschitz_const: Lipschitz constant L of f
    
    Returns:
        Certified radius r = max(0, margin) / L
    '''
    assert lipschitz_const > 0
    return max(0.0, margin) / lipschitz_const
