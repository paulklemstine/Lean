import hashlib
def fs_prove(p, q, g, x):
    import secrets
    y = pow(g, x, p)
    r = secrets.randbelow(q)
    a = pow(g, r, p)
    c = int(hashlib.sha256(f'{y}:{a}'.encode()).hexdigest(), 16) % q
    z = (r + c * x) % q
    return a, c, z