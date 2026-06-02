def estimate_alpha(data):
    num = sum((r-t)*r**2*(1-r) for r,t in data)
    den = sum((r**2*(1-r))**2 for r,t in data)
    return max(0, num/den) if den > 0 else 0