def compare_growth_levels(g1, g2):
    if g1[0] != g2[0]:
        return -1 if g1[0] < g2[0] else 1
    if g1[1] != g2[1]:
        return -1 if g1[1] < g2[1] else 1
    return 0