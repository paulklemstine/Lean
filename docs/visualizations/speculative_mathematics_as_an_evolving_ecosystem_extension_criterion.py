def should_extend(a: int, t: int, c: int, da: int, dt: int, dc: int) -> bool:
    return (c + dc) * (t + dt) * a > c * t * (a + da)