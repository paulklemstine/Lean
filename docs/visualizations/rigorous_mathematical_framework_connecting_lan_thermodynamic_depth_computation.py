def thermodynamic_depth(h):
    return sum(max(0.0, h[i] - h[i+1]) for i in range(len(h) - 1))