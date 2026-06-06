import math
def ultrapower_gcd(f, g):
    return lambda i: math.gcd(f(i), g(i))