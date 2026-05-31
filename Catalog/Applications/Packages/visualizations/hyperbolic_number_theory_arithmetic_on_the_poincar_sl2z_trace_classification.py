def classify_trace(t: int) -> str:
    if abs(t) < 2: return 'elliptic'
    elif abs(t) == 2: return 'parabolic'
    else: return 'hyperbolic'