def trop_defect(line, point):
    v = line + point
    s = v.min()
    L = v.max()
    return (v.sum() - s - L) - s