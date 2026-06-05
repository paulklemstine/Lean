def recovery_analysis(n, k, d):
    threshold = n - d + 1
    is_mds = (k + 2*d == n + 2)
    critical = (n + k) // 2 + 1 if is_mds else None
    return {'threshold': threshold, 'mds': is_mds, 'critical': critical}