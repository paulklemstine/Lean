# Ground-truth check for the Axis A kill argument: are the group orders of the
# standardized ECDSA curves actually prime (so that PH is inapplicable)?
# Primality of these constants is asserted (not verified) everywhere else; Sage's
# is_prime is a provable primality test (PARI-based), so this is a real check.
import time

t0 = time.time()

curves = {
    "P-256  n  = FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551":
        0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551,
    "P-256  p  = FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF":
        0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF,
    "secp256k1 n = FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141":
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141,
    "secp256k1 p = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE FFFFFC2F":
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F,
    "Ed25519  L = 2^252 + 27742317777372353535851937790883648493":
        (1 << 252) + 27742317777372353535851937790883648493,
    "Ed25519  p = 2^255 - 19":
        (1 << 255) - 19,
}

for name, v in curves.items():
    bits = v.nbits() if hasattr(v, "nbits") else v.bit_length()
    pr = is_prime(v)
    print("%-78s bits=%3d  is_prime=%s" % (name, bits, pr), flush=True)

print()
print("elapsed %.2f s" % (time.time() - t0))
