def is_beneficial(a, t, c, k, dt, dc):
    return (c+dc)*(t+dt)*a**2 > c*t*(a+k)**2