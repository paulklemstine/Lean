def valley_detect(f, n=1000, a=0.0, b=1.0):
    f_a, f_b = f(a), f(b)
    threshold = min(f_a, f_b)
    for i in range(1, n):
        r = a + (b-a)*i/n
        if f(r) < threshold:
            return r
    return None