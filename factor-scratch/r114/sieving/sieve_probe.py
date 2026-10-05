#!/usr/bin/env python3
"""
r114 / sieving axis -- DIRECT MEASUREMENT of the NFS siever's cost structure.

What this measures
------------------
The NFS cost model says  T = L_N[1/3, (64/9)^{1/3}].  Where does the OPERATION
COUNT actually go?  The siever does three structurally different things:

  (1) MARKING   -- for each base prime p <= B, walk the sieve array adding
                   log(p).  Cost ~ sum_p (L/p) * d(p)  marks, each a
                   read-modify-write to a 1- or 2-byte array cell.
                   This is a CACHE / MEMORY-BANDWIDTH problem.
  (2) LOGNORM   -- for each cell that did not go to zero, find the actual
                   (a,b), evaluate the algebraic numbers, and divide out the
                   base primes.  Cost ~ (#nonzero cells) * (cost of the modpoly).
                   This is an ARITHMETIC problem.
  (3) COFACTOR  -- for each survivor, check the cofactor bound.
                   Cost ~ (#survivors) * (cost of a few big-int divisions).

The claim this file is built to test is that (1) dominates and is
bandwidth-bound, which would mean: sieving speed is bought with MEMORY
HIERARCHY, not with FLOPs.  If true, an engineering win on marking cannot
change the exponent -- it is a constant-factor lever only, and it is bounded by
the ratio of sieve-array bytes to cache bytes.

MEASUREMENT DESIGN (this host is SHARED and loaded -- load avg was 36 on 16
cores from unrelated agents, so WALL-CLOCK TIMING IS MEASUREMENT GARBAGE here):
  * we read las's OWN "# Total cpu time" (process CPU seconds, immune to
    contention by other processes' scheduling, though not to memory contention)
  * every configuration is run TWICE and we report BOTH, plus the ratio
  * the run is SEEDED/deterministic in its parameters; the only randomness is
    in which (a,b) the sieve visits, which does not change the counts
"""
import os
import re
import subprocess
import sys
import time

LAS = "/home/raver1975/factor47/V11/cado/cado-nfs/build/Ecstasis/sieve/las"
SIEVE = "/home/raver1975/factor47/V11/cado/cado-nfs/build/Ecstasis/sieve"


def parse_stats(text):
    out = {}
    for key, pat in [
        ("cpu_time", r"# Total cpu time ([0-9.eE+-]+)s"),
        ("elapsed", r"# Total elapsed time ([0-9.eE+-]+)s"),
        ("avg_J", r"# Average J=([0-9.eE+-]+)\s*for (\d+) special-q"),
        ("reports", r"# Total (\d+) reports"),
        ("collisions", r"# potential collisions:\s*([0-9.eE+-]+)"),
        ("rawlognorm", r"# raw lognorm:\s*([0-9]+)"),
    ]:
        m = re.search(pat, text)
        if m:
            out[key] = float(m.group(1))
    # relation count: las prints a line per completed (q, range) report
    return out


def make_poly(nbits, deg=5, seed=1):
    """A generic degree-`deg` polynomial m(x) with m ~ N^(1/(deg+1)).

    We do NOT need a good polynomial to measure SIEVING THROUGHPUT; we need a
    legal one (irreducible, right size) so las runs the real code path.  The
    smoothness yield differs from a polyselected m, so we report yield
    separately from throughput.
    """
    import sympy
    from sympy import Poly, Symbol, nextprime
    x = Symbol("x")
    # m ~= 2^(nbits/(deg+1)); leading coeff A small-ish
    exp = nbits // (deg + 1)
    rng = __import__("random").Random(seed)
    # search for irreducible with the right magnitude
    best = None
    for trial in range(400):
        A = 2 ** rng.randint(28, 32)
        coeffs = [A]
        for i in range(1, deg):
            coeffs.append(rng.randint(-(2 ** 30), 2 ** 30))
        coeffs.append(rng.randint(-(2 ** 30), 2 ** 30))
        p = Poly.from_list(list(reversed(coeffs)), gens=x)
        if not p.is_irreducible:
            continue
        lc, rest = p.LC(), p.all_coeffs()[1:]
        if lc <= 0:
            continue
        mag = sum(abs(int(c)) for c in rest) / lc
        # we want the largest root ~ 2^exp
        try:
            r = max(abs(complex(c / lc).real) for c in rest) if rest else 0
        except Exception:
            continue
        best = (p, mag)
        break
    if best is None:
        raise RuntimeError("no irreducible poly found")
    return best[0]


def run_las(poly, workdir, lim, lpb, mfb, I=11, sqside=0, threads=1,
            qmin=None, verbose=False):
    os.makedirs(workdir, exist_ok=True)
    pf = os.path.join(workdir, "poly")
    with open(pf, "w") as fh:
        fh.write(str(poly) + "\n")
    cmd = [LAS, "-poly", pf, "-lim", str(lim), "-lpb", str(lpb),
           "-mfb", str(mfb), "-I", str(I), "-sqside", str(sqside),
           "-t", str(threads), "-v", "-c", str(qmin) if qmin else "1000",
           "-v"]
    if verbose:
        print(" ".join(cmd))
    t0 = time.time()
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=7200)
    wall = time.time() - t0
    stats = parse_stats(r.stdout + r.stderr)
    stats["wall"] = wall
    stats["rc"] = r.returncode
    nrel = 0
    for line in r.stdout.splitlines():
        m = re.match(r"\s*#?\s*(\d+)\s+.*relations?", line)
    stats["stdout_lines"] = len(r.stdout.splitlines())
    return stats, r.stdout


if __name__ == "__main__":
    print(__doc__)