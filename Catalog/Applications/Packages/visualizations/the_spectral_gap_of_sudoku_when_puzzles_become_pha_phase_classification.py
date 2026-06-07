def classify_phase(d):
    if d < 17/81: return 'underconstrained'
    elif d < 30/81: return 'critical'
    else: return 'overconstrained'