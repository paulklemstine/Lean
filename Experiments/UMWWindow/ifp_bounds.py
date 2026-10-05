#!/usr/bin/env python3
"""
The GIFP / IFP bound progression (round 109d), verified against the primary source
(Feng-Nitaj-Pan, arXiv:2304.08718v3, Table 1 + Sec 1). Source code: github.com/fffmath/gifp.

THE PROGRESSION (lower bound on gamma = shared_bits/n, alpha = cofactor_bits/n).
These are the sharpest known requirements on the SHARED-BIT FRACTION needed to
factor two RSA moduli in polynomial time.

  LSBs / MSBs / both (same position):
    May-Ritzenhofen PKC'09    : gamma > 2 alpha
    Sarkar-Maitra  E'09/108   : gamma > 2 alpha - alpha^2
    Lu et al.     2016        : gamma > 2 alpha - 2 alpha^2      <-- best for LSB
  middle bits / GIFP (arbitrary positions):
    Faugere et al. PKC'10     : gamma > 4 alpha
    Peng et al.    2015       : gamma > 4 alpha - 3 alpha^2
    Wang et al.    2018       : gamma > 4 alpha - 4 alpha sqrt(alpha)
    Feng-Nitaj-Pan 2023 (this): gamma > 4 alpha (1 - sqrt(alpha))
  The paper's OWN OPEN PROBLEM: can GIFP's 4 alpha (1-sqrt alpha) be improved
  to 2 alpha - 2 alpha^2 (the best LSB bound) or better? "not easy".

This script tabulates the progression and computes the concrete shared-bit
requirement for a 2048-bit RSA pair, and marks the open gap.
"""
import math

def bits_for(n_bits, alpha, gamma):
    """shared bits needed to factor a pair of n_bits-bit RSA moduli."""
    return gamma * n_bits

def main():
    n=2048
    print("IFP/GIFP bound progression (gamma = shared bits / n, alpha = cofactor bits / n)")
    print("  NOTE: alpha + gamma <= 1 (the p-prime needs enough unshared bits).")
    print("  A factorable configuration needs the two p's to SHARE gamma*n bits\n")
    for alpha in [0.25, 0.30, 0.35]:
        print(f"  alpha = {alpha}  (q = {alpha*n:.0f} bits, p = {(1-alpha)*n:.0f} bits)")
        rows = [
            ("May-Ritzenhofen (LSB)", 2*alpha),
            ("Sarkar-Maitra (LSB)",   2*alpha - alpha**2),
            ("Lu et al. (LSB) BEST",   2*alpha - 2*alpha**2),
            ("Peng (middle)",          4*alpha - 3*alpha**2),
            ("Wang (middle)",          4*alpha - 4*alpha**0.5*alpha),
            ("Feng-Nitaj-Pan GIFP",    4*alpha*(1-math.sqrt(alpha))),
        ]
        for name, thr in rows:
            gb = thr*n
            print(f"    {name:26s} gamma>{thr:.4f}  => share {gb:6.1f} bits of p")
        # the open gap: GIFP vs best LSB
        gifp = 4*alpha*(1-math.sqrt(alpha))
        lsb_best = 2*alpha - 2*alpha**2
        print(f"    -> GIFP needs {gifp:.4f}, best LSB {lsb_best:.4f}; "
              f"gap = {gifp-lsb_best:+.4f}  (OPEN: paper's stated problem)")
        print()

if __name__ == "__main__":
    main()
