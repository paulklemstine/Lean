def validate_qecc(n, k, d):
    return {'singleton': 2*d+k <= n+2, 'bpt': k*d**2 <= n, 'mds': 2*d+k == n+2}