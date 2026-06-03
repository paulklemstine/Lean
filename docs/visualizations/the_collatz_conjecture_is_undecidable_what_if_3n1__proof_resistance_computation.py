def proof_resistance(n: int) -> int:
    orbit = [n]
    while n != 1 and len(orbit) < 100000:
        n = n // 2 if n % 2 == 0 else 3 * n + 1
        orbit.append(n)
    st = len(orbit) - 1
    peak = max(orbit)
    return st * peak.bit_length()