def tropical_stereo(p: float, t: float) -> float:
    return max(t, 0.0) - max(t, p)