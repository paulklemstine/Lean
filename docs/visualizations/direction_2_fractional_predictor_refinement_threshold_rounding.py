def threshold_rounding(x, d):
    """Round fractional transversal to integer via thresholding.
    
    Args:
        x: dict or array mapping vertices to fractional values
        d: maximum edge size bound
    Returns:
        Set of vertices forming an integer transversal
    """
    threshold = 1.0 / d
    return {v for v, val in enumerate(x) if val >= threshold - 1e-10}