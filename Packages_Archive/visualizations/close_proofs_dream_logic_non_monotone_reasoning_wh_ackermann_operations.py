def ack_mem(m, n):       # membership = bit test
    return (n >> m) & 1 == 1
def ack_union(a, b):     return a | b          # union  = bitwise OR
def ack_inter(a, b):     return a & b          # inter. = bitwise AND
def ack_singleton(m):    return 1 << m         # {m}    = 2^m
def ack_pairing(a, b):   return (1 << a) | (1 << b)   # {a,b}
