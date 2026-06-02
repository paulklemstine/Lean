def classify_spectrum(b: int) -> str:
    d = b*b - 4
    if d < 0: return 'crystalline'
    elif d > 0: return 'metallic'
    else: return 'degenerate'