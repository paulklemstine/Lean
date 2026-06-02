def monte_carlo_dimension(branching_factors, success_counts):
    import math
    dims = [math.log(k)/math.log(b) for b,k in zip(branching_factors, success_counts) if b >= 2 and k >= 1]
    return sum(dims) / len(dims)