"""Worker process for baseline.py.  Run as `sage _baseline_worker.py BACKEND N JSONEXTRA`.

Kept as a FILE, not a -c string, because this Sage build has no `-python` flag
(only `-c` and `file`), and because a here-string of 60 lines is a quoting
liability.  Note `sage file.py` does NOT run the preparser (verified: `type(7/2)`
is float), so this is ordinary Python -- which is what we want.
"""
import json
import sys
import time

backend = sys.argv[1]
N = int(sys.argv[2])
extra = json.loads(sys.argv[3])
out = {}
t0 = time.time()
try:
    if backend == "trial":
        g = 2
        found = None
        bound = extra.get("bound", 10**6)
        while g <= bound and g * g <= N:
            if N % g == 0:
                found = g
                break
            g += 1 if g == 2 else 2
        out["factor"] = found
    elif backend == "rho":
        from gmpy2 import gcd
        c = 1
        y = extra.get("seed", 12345) % N
        r = 1
        q = 1
        gg = 1
        ys = 0
        while gg == 1:
            x = y
            for _ in range(r):
                y = (y * y + c) % N
            k = 0
            while k < r and gg == 1:
                ys = y
                for _ in range(min(128, r - k)):
                    y = (y * y + c) % N
                    q = q * abs(x - y) % N
                gg = int(gcd(q, N))
                k += 128
            r *= 2
        if gg == N:
            while True:
                ys = (ys * ys + c) % N
                gg = int(gcd(abs(x - ys), N))
                if gg > 1:
                    break
        out["factor"] = gg if (1 < gg < N and N % gg == 0) else None
    elif backend == "sympy":
        from sympy import factorint
        out["factors"] = [int(x) for x in factorint(N, limit=extra.get("limit", 10**7))]
    elif backend == "ecm":
        # sage.libs.libecm.ecmfactor(number, B1, verbose=False, sigma=0)
        #
        # TRAP 1 (r113 bug, reproduced here): the DOCSTRING promises
        #   (True, f) on success / (False, None) on failure,
        # but the implementation returns a 3-TUPLE
        #   (True, f, sigma) on success, (False, None) on failure.
        # r113's baseline.sage, ecm1.sage and ecmesc.sage all write
        #   ok, fct = ecmfactor(N, 11000)
        # which raises ValueError("too many values to unpack (expected 2, got 3)")
        # on every SUCCESS.  It only appears to work in the failure case, where
        # the return is the 2-tuple (False, None).  So those harnesses record a
        # spurious ECM failure on exactly the instances ECM cracks.
        # VERIFIED on this box: ecmfactor(10403*10429, 11000) -> (True, 108492887, 712645761)
        #
        # TRAP 2: on an ALREADY-EASY number it returns N itself:
        #   ecmfactor(15, 2000) -> (True, 15, 657125637)
        # i.e. "success" with f == N is NOT a factorization.  The 1 < f < N and
        # N % f == 0 guard below is what catches it.
        #
        # NOTE: there is no ncurves and no seed parameter -- it runs ONE curve.
        # We loop over sigma values ourselves to get `ncurves` attempts.
        from sage.libs.libecm import ecmfactor
        B1 = extra.get("B1", 11000)
        ncurves = extra.get("ncurves", 30)
        sigma0 = extra.get("sigma", 0)
        found = None
        for i in range(ncurves):
            r = ecmfactor(N, B1, False, sigma0 + i)
            if not r or not r[0]:
                continue
            f = int(r[1])
            if f and 1 < f < N and N % f == 0:
                found = f
                break
        out["factor"] = found
    elif backend == "pari":
        # TRAP 3: PARI's factor() returns an IntegerFactorization object whose
        # list() gives (prime, exponent) PAIRS, not bare primes:
        #   list(factor(1000003*1000033)) == [(1000003, 1), (1000033, 1)]
        # Iterating the object directly does not even work (no __iter__).
        # r113-style `[int(x) for x in f]` therefore raises
        #   TypeError: int() argument must be ... not 'tuple'
        f = factor(N)
        out["factors"] = [int(prime) ** int(exp) for prime, exp in f]
    else:
        out["error"] = "unknown backend %r" % backend
except Exception as e:
    out["error"] = "%s: %s" % (type(e).__name__, e)
out["work_s"] = time.time() - t0
print(json.dumps(out))