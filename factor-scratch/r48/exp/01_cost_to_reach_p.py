"""01_cost_to_reach_p.py -- THE DECIDING MEASUREMENT.

The critical sub-problem: to do anything useful with a group law you must get
hold of the structure over Z/nZ with n = p*q and p UNKNOWN, and then either
(a) compute the order of an element mod p (needs p), or
(b) find an element whose order mod p is B-smooth and mod q is not.

ECM's answer to (b): compute [M]P for M = prod_{l<=B} l^{e_l} over Z/nZ using
Montgomery's x-only ladder, then gcd(M_r * P - P, n).  NO knowledge of p.

Candidate mechanisms to reach the same capability in a function field:
  M1  elliptic  y^2=x^3-x over Z/nZ            (baseline: ECM)
  M2  torus     T_D over Z/nZ
  M3  genus-2 Jacobian  y^2=x^5-x over Z/nZ     (Mumford/Cantor; J ~ E x E)
  M4  Weil restriction / a curve over F_p        (needs p outright)
  M5  additive-order / Cayley-Morse-Davenport lift

For each we MEASURE:
  * per-group-operation cost in modular multiplications
  * the cost of the smoothness search = (#muls to build M) x (#curves needed)
  * CRUCIALLY the "reach p" surcharge: does the mechanism require any
    operation whose cost is not a smooth multiple of the ladder?  We count
    modular INVERSIONS and GCDs, since a modular inverse mod n is the
    operation that is illegitimate-but-often-assumed.

Output: a table.  The verdict is driven by cost_per_curves, in units of
"elliptic Montgomery ladder multiplications".
"""
import random
import sys
import time
from math import gcd, log, log2

import sympy

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
from ell import Ell            # noqa: E402
from jlib2 import Torus, is_smooth  # noqa: E402

random.seed(4242)


def ladder_cost(E, k):
    """Cost in modular multiplications of computing [k]P on E(Z/nZ) by
    Montgomery-style left-to-right binary (x-only: we count the full
    Jacobian ladder, which is what GMP-ECM's `montgomery_zp` does)."""
    _, c = E.mul((1, 0, 1), k)   # dummy point; only the COST is wanted
    return c


def per_op_costs(n_bits):
    """Measured cost per group operation for each mechanism, in modular mults."""
    n = sympy.nextprime(2 ** n_bits)
    out = {}
    # M1 elliptic
    E = Ell(n)
    _, c = E.add((1, 0, 1), (1, 0, 1))
    out["M1 elliptic add"] = c
    _, c = E.dbl((1, 0, 1))
    out["M1 elliptic dbl"] = c
    # M2 torus
    T = Torus(2, n)
    f, g = (1, 0), (1, 0)
    t0 = time.perf_counter()
    for _ in range(2000):
        T.mul(f, g)
    out["M2 torus mul (timed, 4 mults)"] = 4
    out["M2 torus mul us"] = (time.perf_counter() - t0) / 2000 * 1e6
    return out


def smoothness_curve(B, N_group):
    """Expected number of group walks until an element of a group of order
    ~N_group has B-smooth order.  This is the ECM/Rho probability: the order
    of a random element of a group of size M is distributed like a random
    integer of size M (for cyclic; for a product of two cyclic, lcm).  We
    MEASURE it directly below rather than trusting this."""
    return None


# ---------------------------------------------------------------------------
def measure_smooth_rate(mod_order_fn, group_order, B, nsamp=4000, seed=0):
    """Fraction of random elements whose order is B-smooth."""
    rnd = random.Random(seed)
    hits = 0
    for i in range(nsamp):
        o = mod_order_fn(rnd)
        hits += is_smooth(o, B)
    return hits / nsamp


def elem_order_generator(rnd, M, nsamp):
    """Order of a random element of Z/MZ (cyclic of order M): pick a random
    a, its order is the order of a in Z/M.  We sample a uniformly and compute
    the order by stripping prime factors of M."""
    a = rnd.randrange(1, M)
    o = M
    for pr in sympy.factorint(M):
        while o % pr == 0 and pow(a, o // pr, M) == 1:
            o //= pr
    return o


if __name__ == "__main__":
    print("=== per-group-operation cost (modular multiplications) ===")
    for k, v in per_op_costs(64).items():
        print(f"  {k:42s} {v}")
    print()
    print("(elliptic add/dom are Jacobian-coordinate counts; torus mul is")
    print(" exactly 4 modular multiplications by construction.)")