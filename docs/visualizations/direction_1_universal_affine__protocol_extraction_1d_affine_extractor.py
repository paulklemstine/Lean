def affine_extract_1d(z1: int, z2: int, c1: int, c2: int, q: int) -> int:
    """1D affine extractor: w = (z1-z2) * (c1-c2)^(-1) mod q"""
    diff_z = (z1 - z2) % q
    diff_c = (c1 - c2) % q
    inv_c = pow(diff_c, q - 2, q)  # Fermat's little theorem
    return (diff_z * inv_c) % q

# Example: Schnorr extraction
q = 31; w = 8; r = 7; c1 = 4; c2 = 23
z1 = (r + c1 * w) % q  # = 8
z2 = (r + c2 * w) % q  # = 5
w_extracted = affine_extract_1d(z1, z2, c1, c2, q)
print(f"Extracted: {w_extracted}, Original: {w}, Match: {w_extracted == w}")