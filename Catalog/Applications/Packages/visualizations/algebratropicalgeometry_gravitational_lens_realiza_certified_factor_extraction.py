def extract_factors(path_mult, cost_in=None, cost_out=None):
    """Extract factors from a tropical lens network."""
    n = len(path_mult)
    if cost_in is None:
        cost_in = [0] * n
    if cost_out is None:
        cost_out = [0] * n
    
    # Compute caustic set
    total_costs = [cost_in[i] + cost_out[i] for i in range(n)]
    min_cost = min(total_costs)
    caustic = [i for i in range(n) if total_costs[i] == min_cost]
    
    if len(caustic) <= 1:
        return ("RIGID", "Too few caustic strata")
    if any(path_mult[i] <= 1 for i in caustic):
        return ("RIGID", "Some multiplicity <= 1")
    
    a = path_mult[caustic[0]]
    b = 1
    for i in caustic[1:]:
        b *= path_mult[i]
    return ("FACTORS", (a, b))

# Examples
print(extract_factors([7, 13]))      # 91 = 7 × 13
print(extract_factors([3, 5, 7]))    # 105 = 3 × 35
print(extract_factors([5, 5, 5]))    # 125 = 5 × 25