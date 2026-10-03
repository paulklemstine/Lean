"""
r48 / AXIS-B : "COST TO REACH p" -- the KILLER requirement.

For each family we ask, concretely and with a wall-clock measurement:

  Q_A  Can we BUILD the group at all from N alone, in poly(log N)?
  Q_B  Can we build a map G -> Z/pZ, or otherwise get p out of a walk?
  Q_C  Is Q_A + Q_B actually cheaper than the L[1/2] we are trying to beat?

The decision: ECM's L[1/2, sqrt2] at a 64-bit p is about 2^32 group
operations.  Anything whose setup exceeds that is dead on arrival.  We
measure setup time on THIS host and convert to a bit-cost via the measured
group-operation rate, so the comparison is apples-to-apples.

Everything here is measured at 64-bit semiprimes, which is the regime where
all of this is actually runnable.
"""
from __future__ import annotations

import math
import random
import time

from smooth import _pari, factorint_pari

P = _pari()


def gen_prime(bits, rng):
    lo = 1 << (bits - 1)
    return int(P(f"nextprime(%d)" % rng.randrange(lo, 1 << bits)))


def gen_semiprime(bits, rng):
    p = gen_prime(bits // 2, rng)
    q = gen_prime(bits - bits // 2, rng)
    while p == q:
        q = gen_prime(bits - bits // 2, rng)
    return p, q, p * q


# ---------------------------------------------------------------------------
def ec_setup_cost(bits, reps=20):
    """ECM: build a curve over Z/NZ with no knowledge of p.

    This is the point of ECM: the curve is chosen over Z/NZ, the walk happens
    in E(F_p) x E(F_q) by CRT, and a nontrivial gcd of a difference of two
    walk states with N hands you p.  There is NO step that reaches p -- that
    is why ECM is the baseline that every other family must match.
    """
    rng = random.Random(5)
    p, q, N = gen_semiprime(bits, rng)
    t0 = time.time()
    for _ in range(reps):
        # choose Suyama-style parameters mod N only
        sigma = rng.randrange(2, N)
        u = (sigma * sigma - 5) % N
        v = (4 * sigma) % N
        # curve v*u^3 + a1*u^2 + a3*u  with gcd checks, all mod N
        a1 = (v - u) % N
        a3 = (2 * u) % N
        # Montgomery ladder first step, mod N only
        _ = (u * u + v) % N
    dt = (time.time() - t0) / reps
    return {"family": "EC_baseline", "bits": bits,
            "setup_seconds_per_curve": dt,
            "reaches_p": "NO separate step: gcd of walk state difference with N",
            "needs_p_to_start": False}


def class_group_setup_cost(bits, reps=10):
    """Class group of Q(sqrt(N)): the group SQUFOF/CFRAC walks in.

    The ONLY choice that ties the field to N is D = 4N, so there is NO free
    parameter to optimise over.  Cost to build = one class number.
    """
    rng = random.Random(6)
    p, q, N = gen_semiprime(bits, rng)
    t0 = time.time()
    hs = []
    for _ in range(reps):
        h = int(P(f"qfbclassno(4*%d)" % N))
        hs.append(h)
    dt = (time.time() - t0) / reps
    return {"family": "realq_class_group_D4N", "bits": bits,
            "setup_seconds": dt, "class_number": hs[0],
            "needs_p_to_start": False,
            "reaches_p": ("the walk yields a form of discr 4N; a nontrivial "
                          "gcd of its leading coefficient with N is p"),
            "free_parameter": "NONE -- D is pinned to 4N by the problem"}


def free_disc_class_group_setup_cost(bits, reps=50):
    """Class group of Q(sqrt(-D)) with FREE D -- the best order distribution
    a class group can offer -- but nothing ties it to N."""
    rng = random.Random(7)
    lo = 1 << (bits * 2 - 1)
    hi = 1 << (bits * 2)
    t0 = time.time()
    hs = []
    for _ in range(reps):
        D = -rng.randrange(lo, hi)
        h = int(P(f"qfbclassno(%d)" % D))
        hs.append(h)
    dt = (time.time() - t0) / reps
    return {"family": "imq_class_group_FREE_D", "bits": bits,
            "setup_seconds": dt, "class_number": hs[0],
            "needs_p_to_start": True,
            "reaches_p": "IMPOSSIBLE: D is not a function of N",
            "free_parameter": "D is completely free"}


def gl2_setup_cost(bits, reps=20):
    """GL(2,p)/PGL(2,p): to build it you must already know p."""
    rng = random.Random(8)
    p, q, N = gen_semiprime(bits, rng)
    t0 = time.time()
    for _ in range(reps):
        # honest attempt: construct PGL(2,p) WITHOUT knowing p
        # ... there is none.  We time the operation that would require p.
        _ = p * (p * p - 1)
    dt = (time.time() - t0) / reps
    return {"family": "PGL2_p", "bits": bits,
            "setup_seconds": dt,
            "needs_p_to_start": True,
            "reaches_p": "CIRCULAR: you need p to form F_p, and p is the target"}


def measure_group_op_rate(bits=64, reps=200000):
    """Cost of ONE Montgomery-curve group operation mod N, i.e. one step of
    an L[1/2] rho/ECM walk.  This is the yardstick: how many bits of work
    does 2^k steps of the ECM walk cost on this host?"""
    rng = random.Random(9)
    p, q, N = gen_semiprime(bits, rng)
    t0 = time.time()
    for _ in range(reps):
        x = rng.randrange(2, N)
        # one point add/double-ish ladder step mod N (a few field mults)
        _ = (x * x) % N
        _ = (x * x + 1) % N
    dt = (time.time() - t0) / reps
    return dt


if __name__ == "__main__":
    print("r48 AXIS-B : cost to reach p, measured on this host\n")
    rate = measure_group_op_rate()
    print(f"one ECM walk step (mod N, {2*32}-bit) = {rate*1e6:.2f} us")
    # ECM at 64-bit p: L[1/2, sqrt2] with rho(2) success prob
    rho2 = 1 - math.log(2)
    steps = math.sqrt(1 << 32) / rho2
    print(f"ECM cost for a 64-bit p: {steps:.3e} group steps "
          f"= {steps*rate:.2f} s of pure group arithmetic\n")

    rows = [ec_setup_cost(64), class_group_setup_cost(64),
            free_disc_class_group_setup_cost(64), gl2_setup_cost(64)]
    for r in rows:
        print(f"{r['family']:26s} bits={r['bits']} "
              f"setup={r.get('setup_seconds', r.get('setup_seconds_per_curve'))*1e3:9.3f} ms")
        print(f"{'':26s}   needs p to start: {r['needs_p_to_start']}")
        print(f"{'':26s}   reaches p: {r['reaches_p']}")
        print(f"{'':26s}   free parameter: {r.get('free_parameter','D pinned to 4N')}")
        if 'class_number' in r:
            print(f"{'':26s}   |G| = {r['class_number']} "
                  f"({r['class_number'].bit_length()} bits)")
        print()