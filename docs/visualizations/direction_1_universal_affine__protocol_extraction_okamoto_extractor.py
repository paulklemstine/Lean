def okamoto_extract(z11, z12, z21, z22, c1, c2, q):
    """Okamoto two-generator protocol extractor."""
    inv = pow((c1 - c2) % q, q - 2, q)
    w1 = ((z11 - z21) * inv) % q
    w2 = ((z12 - z22) * inv) % q
    return w1, w2

# Example
import random; random.seed(42)
q = 37; w1, w2 = 7, 35; r1, r2 = 5, 27; c1, c2 = 2, 1
z11 = (r1 + c1*w1) % q; z12 = (r2 + c1*w2) % q
z21 = (r1 + c2*w1) % q; z22 = (r2 + c2*w2) % q
e1, e2 = okamoto_extract(z11, z12, z21, z22, c1, c2, q)
print(f"Extracted: ({e1}, {e2}), Original: ({w1}, {w2}), Match: {(e1,e2)==(w1,w2)}")