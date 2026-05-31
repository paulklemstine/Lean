def modular_sieve(x, y, z):
    evens = sum(1 for e in [x,y,z] if e%2==0)
    if evens < 2: return False
    s = x*x+y*y+z*z
    if s%4 in (2,3): return False
    if not any(e%3==0 for e in [x,y,z]): return False
    return True