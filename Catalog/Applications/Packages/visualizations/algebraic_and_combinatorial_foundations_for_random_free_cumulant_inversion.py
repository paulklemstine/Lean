def free_cumulants(moments):
    k = []
    if len(moments) >= 1:
        k.append(moments[0])
    if len(moments) >= 2:
        k.append(moments[1] - k[0]**2)
    if len(moments) >= 3:
        k.append(moments[2] - 3*k[0]*k[1] - k[0]**3)
    if len(moments) >= 4:
        k.append(moments[3] - 4*k[0]*k[2] - 2*k[1]**2 - 6*k[0]**2*k[1] - k[0]**4)
    return k