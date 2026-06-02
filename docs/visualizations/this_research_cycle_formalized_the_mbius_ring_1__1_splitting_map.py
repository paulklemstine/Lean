def split(a, b):
    return (a+b, a-b)

def split_inverse(x, y):
    if x % 2 != y % 2: return None
    return ((x+y)//2, (x-y)//2)