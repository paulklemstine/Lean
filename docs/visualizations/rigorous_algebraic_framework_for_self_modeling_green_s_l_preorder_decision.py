def green_L_leq(a, b):
    seen = {}
    for x in range(len(a)):
        if b[x] in seen:
            if seen[b[x]] != a[x]: return False
        else: seen[b[x]] = a[x]
    return True