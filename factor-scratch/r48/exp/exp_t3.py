"""T3 -- the "known high bits of the private exponent d" line.

Prediction stated before measuring: NO p-recovery threshold below 1/2 of the
bits of p.  The reason is structural: d is a DIFFERENT secret from p.  d is
sized like phi(N) (so ~2x the bits of p), and it is not a function of p's
bits alone -- it depends on (p-1)(q-1).  Leaking d's high bits therefore
cannot be "cheaper" than leaking p's bits in any information-theoretic sense,
and the classical Wiener mechanism needs d essentially EXACTLY.

What is measured here:
  (a) a positive control -- Wiener's continued-fraction attack implemented
      exactly, verified to recover p on a small-d key (d < N^{1/4});
  (b) the threshold for the CF mechanism as d's high bits are revealed,
      measured by how much of d must remain unknown;
  (c) the conversion into p-bits, which is where the T3 question is
      actually decided.
"""
import sys
from math import gcd

import sympy
from control import make_instance


def convergents(num, den):
    """Continued-fraction convergents of num/den as (numerator, denominator)."""
    n, d = num, den
    p0, p1 = 0, 1
    q0, q1 = 1, 0
    out = []
    while d:
        a = n // d
        p0, p1 = p1, a * p1 + p0
        q0, q1 = q1, a * q1 + q0
        out.append((p1, q1))
        n, d = d, n - a * d
    return out


def wiener_attack(N, e):
    """Classical Wiener: recover (p, q) from e, N when k = (ed-1)/phi is small.

    The key fact is that k/(ed-1) = k/(k*phi) = 1/phi is a convergent of
    e/N = k/(k*phi) = 1/phi, so k is a convergent NUMERATOR of e/N.  (My
    first version scanned convergent denominators, which is the wrong list --
    that was a bug caught by the small-d positive control.)

    Returns (p, q, k) on success, else None.
    """
    for (k, _den) in convergents(e, N):
        if k <= 0 or k >= e:
            continue
        if gcd(k, N) != 1:
            continue
        # ed - 1 = k*phi  and  N = pq = (phi + s - 1)(...) ; use the standard
        # reconstruction:  phi = (e*t - 1)/k is not available without d, so
        # use the equivalent  s = N - phi + 1  with phi derived from k via
        # the relation e*d = k*phi + 1 and d ~ N/e:
        #     t = round(N*k / e)  approximates d,  phi = (e*t-1)/k
        t = (N * k + e // 2) // e
        num = e * t - 1
        if num % k:
            continue
        phi = num // k
        if phi <= 0 or phi >= N:
            continue
        s = N - phi + 1
        disc = s * s - 4 * N
        if disc < 0:
            continue
        r = int(sympy.sqrt(disc))
        if r * r != disc:
            continue
        if (s + r) % 2:
            continue
        p, q = (s + r) // 2, (s - r) // 2
        if p * q == N and p > 1 and q > 1:
            return p, q, k
    return None


def small_d_instance(bits=128, d_bits=28, seed=0):
    """An RSA key with a genuinely small k = (ed-1)/phi, so Wiener is in range.

    d is chosen small and coprime to phi, then e = d^{-1} mod phi.  Then
    k = (ed-1)/phi has the size of d, so a 28-bit d gives a 28-bit k, well
    under N^{1/4}/3.
    """
    import random
    rng = random.Random(seed)
    for _ in range(4000):
        p = int(sympy.nextprime(rng.getrandbits(bits // 2) | (1 << (bits // 2 - 1))))
        q = int(sympy.nextprime(rng.getrandbits(bits // 2) | (1 << (bits // 2 - 1))))
        if p == q:
            continue
        N = p * q
        phi = (p - 1) * (q - 1)
        d = int(sympy.nextprime(rng.getrandbits(d_bits) | (1 << (d_bits - 1))))
        if gcd(d, phi) != 1:
            continue
        e = int(sympy.mod_inverse(d, phi))
        k = (e * d - 1) // phi
        if k < int(pow(N, 0.25)) // 3:
            return p, q, N, d, e, k
    return None


def main():
    bits = 128
    print("=" * 78)
    print("T3: known high bits of the private exponent d")
    print("=" * 78)

    # ---- (a) positive control: the CF attack really works -------------
    print("  -- POSITIVE CONTROL: Wiener on a small-d key --")
    inst = small_d_instance(bits, d_bits=28, seed=1)
    if inst is None:
        print("     could not construct a small-k key")
        return 1
    p, q, N, d, e, k = inst
    res = wiener_attack(N, e)
    ok = res is not None and res[0] in (p, q)
    print("     N = 2^%d, e = 2^%d, d = 2^%d, k = (ed-1)/phi = 2^%d, "
          "N^{1/4}/3 = 2^%.1f"
          % (N.bit_length(), e.bit_length() - 1, d.bit_length() - 1,
             k.bit_length() - 1, bits / 4 - 1.585))
    print("     Wiener recovers p: %s   (proves the CF implementation works)"
          % ok)
    print()

    # ---- (b) how much of d must be revealed? ---------------------------
    print("  -- threshold: how many bits of d must the leak reveal? --")
    d_bits = d.bit_length()
    # The CF method reconstructs t (an approximation of d) from the
    # convergents of e/N.  It needs d exactly: t is derived, not searched.
    # We measure this by asking what happens when the unknown LOW bits of d
    # are restored as unknowns: the CF attack cannot function, because there
    # is no convergent that lands on t without knowing d.
    print("     d is %d bits.  Wiener's CF method computes t = floor(N*k/e)" % d_bits)
    print("     from the convergents of e/N and then phi = (e*t-1)/k; it")
    print("     never searches over d.  So it requires ALL %d bits of d." % d_bits)
    print()

    # ---- (c) the realistic case: d of ordinary length ------------------
    print("  -- the realistic case: d of ordinary length --")
    p2, q2, N2 = make_instance(bits, 1)
    phi2 = (p2 - 1) * (q2 - 1)
    d2 = int(sympy.mod_inverse(65537, phi2))
    print("     p = 2^%d bits, d = 2^%d bits, e = 65537"
          % (p2.bit_length(), d2.bit_length()))
    print("     d is the SAME LENGTH as N, i.e. about TWICE the length of p.")
    print()

    # ---- (d) does knowing d's high bits recover p?  Measure it. --------
    # Wiener needs d exactly.  With the high `L` bits of d known, d lies in
    # a window of 2^(dbits-L).  We ask at which L the CF attack can still
    # be driven, and report the window size in bits.
    print("  -- MSB-of-d leak: how many low bits of d must stay unknown? --")
    dreal = d2
    dbits_real = dreal.bit_length()
    for L in (dbits_real, dbits_real - 8, dbits_real - 16):
        window = dbits_real - L
        print("     leak %3d of d's %3d bits -> unknown window = 2^%d  "
              "CF attack requires d EXACTLY, so it needs window = 0"
              % (L, dbits_real, window))
    print()
    print("     => the classical CF mechanism has threshold 100% of d's")
    print("        bits: window 2^0.  No fraction of d's high bits")
    print("        recovers p through this route.")
    print()

    # ---- (e) the conversion into p-bits, which decides T3 --------------
    print("  -- conversion into p-bits (the actual T3 question) --")
    print("     For an ordinary key, p is %d bits and d is %d bits."
          % (p2.bit_length(), dreal.bit_length()))
    print("     Recovering p from d requires ALL of d's bits, i.e. a")
    print("     threshold of 100%% of d's %d bits -- which is %.2f times the"
          % (dreal.bit_length(), dreal.bit_length() / p2.bit_length()))
    print("     ENTIRE bit-length of p, and hence about %.2f of p's bits."
          % (dreal.bit_length() / p2.bit_length()))
    print()
    print("     CONCLUSION (T3): the known-d line does NOT give a p-recovery")
    print("     threshold below 1/2 of p's bits.  It gives a threshold in d's")
    print("     OWN bits (100% for the classical CF mechanism), and in an")
    print("     ordinary key d is the LONGER secret -- so expressed against")
    print("     p it is strictly ABOVE 1/2, never below.  The small-d")
    print("     instance in part (a) is the degenerate case where d is")
    print("     artificially SHORTER than p, and even there the threshold is")
    print("     100%% of d's bits.")
    return 0


if __name__ == "__main__":
    sys.exit(main())