def collision_reduction(compress, iv, m1, m2):
    _, t1 = md_chain_trace(compress, iv, m1)
    _, t2 = md_chain_trace(compress, iv, m2)
    for i in range(len(m1)-1, -1, -1):
        if (t1[i],m1[i]) != (t2[i],m2[i]) and compress(t1[i],m1[i]) == compress(t2[i],m2[i]):
            return (t1[i],m1[i],t2[i],m2[i])
    return None