def complement_rule(r):
    result = 0
    for idx in range(8):
        a,b,c = (idx>>2)&1, (idx>>1)&1, idx&1
        comp_idx = 4*(1-a)+2*(1-b)+(1-c)
        result |= ((1-((r>>comp_idx)&1)) << idx)
    return result