def tropical_mobius_eval(a: float, b: float, c: float, d: float, t: float) -> float:
    return max(a + t, b) - max(c + t, d)