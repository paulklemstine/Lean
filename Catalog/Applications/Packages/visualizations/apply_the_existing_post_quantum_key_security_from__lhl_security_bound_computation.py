def security_bound(orbit_size, output_size):
    import math
    cp = 1.0 / orbit_size
    adv = 0.5 * math.sqrt(output_size * cp)
    return -math.log2(adv) if adv > 0 else float("inf")

# Example: orbit=2^20, keys=2^16
print(f"{security_bound(2**20, 2**16):.1f} bits of security")