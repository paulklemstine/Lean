def classify_density(d):
    if d < 17/81: return 'fast'
    elif d < 30/81: return 'critical'
    else: return 'frozen'