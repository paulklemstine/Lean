def ackermann_encode(elements):
    return sum(1 << m for m in elements)

def ackermann_decode(n):
    members = set()
    i = 0
    while n > 0:
        if n & 1: members.add(i)
        n >>= 1; i += 1
    return members

def ackermann_membership(m, n):
    return bool((n >> m) & 1)

def ackermann_union(a, b): return a | b
def ackermann_intersection(a, b): return a & b