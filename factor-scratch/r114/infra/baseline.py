"""
baseline.py -- THE NON-VACUITY INSTRUMENT.

Every factoring claim in this campaign must be accompanied by: "what does the
trivial baseline do on THIS instance?"  This module answers that question with a
hard wall-clock timeout and an explicit status.  It never hangs, and it never
reports success it did not verify.

    from baseline import baseline_factor
    st = baseline_factor(N, T=60.0)
    st["status"]  # 'factored' | 'gave_up' | 'error'
    st["time_s"]  # float
    st["factors"] # list of ints (verified: their product == N)
    st["backend"] # which method did it

WHY A SUBPROCESS
----------------
sympy.factorint and PARI factor() on a 2048-bit RSA modulus do not return, they
do not raise, and they do not print.  A `timeout=` on the *parent* Bash call is
not enough because the child keeps the CPU.  So every backend runs in its own
process group and is SIGKILLed at T seconds.  This is the whole point of the
module: a timeout that does not actually stop the work is not a timeout.

HONESTY NOTES (read before quoting a number from here)
-----------------------------------------------------
* 'gave_up' means "this backend did not finish in T seconds".  It does NOT mean
  "this number is hard".  A longer T or a bigger ECM bound may well factor it.
  Never write "unsuccessful" where you mean "not within T".
* These are GENERIC backends (rho / p-1 / QS / ECM / PARI).  A special-form
  modulus (small p-1, a smooth p+1, Fermat-close p,q) can be trivially factored
  by them; that is a fact about the instance, not about the attack under test.
* PARI 2.17's factor() has NO ECM stage (measured in r113/adversarial-audit).
  For a known-small-factor instance, ECM is the correct generic baseline and
  PARI is a strawman.  Use backend='ecm' for that comparison.
"""
from __future__ import annotations

import json
import os
import signal
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
SAGE = "/home/raver1975/sage_mamba/envs/sage/bin/sage"

# Backends and the interpreter each needs.
BACKENDS = {
    "trial": "python",     # trial division to a bound -- sanity floor, never a real baseline
    "rho": "python",       # Brent rho, gmpy2
    "sympy": "python",     # sympy.factorint: rho + p-1 + Pollard p-1 + SIQS/PMQS
    "ecm": "sage",         # sage.libs.libecm.ecmfactor -- THE generic baseline for small factors
    "pari": "sage",        # PARI factor() -- no ECM stage, strawman for small factors
}


WORKER = os.path.join(HERE, "_baseline_worker.py")


def _kill_tree(proc):
    """SIGKILL the child's whole process group.  A SIGKILLed parent is the only
    timeout that actually reclaims the CPU -- TERM lets PARI/Sage flush and
    sometimes continue."""
    try:
        os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
    except Exception:
        try:
            proc.kill()
        except Exception:
            pass


def baseline_factor(N, T=60.0, backend="ecm", startup_grace=None, **extra):
    """Try to factor N with `backend`, giving up hard at T seconds.

    Returns a dict:
      status   'factored' | 'gave_up' | 'error'
      time_s   wall seconds consumed INCLUDING interpreter startup
      work_s   seconds the backend itself spent (time_s minus startup)
      factors  list of ints, ONLY present if their product was verified == N
      small_factor_bits  bit length of min(factors), if factored
      backend  str
      timeout  the T that was used

    `startup_grace` (default 3.0 s) is subtracted from T before the child is
    killed, because `sage file.py` pays ~0.5-1.5 s of start-up that is not the
    backend's work.  Without it a T=2 run reports 'gave_up' on a backend that
    never got to start.  The value actually used is reported as `effective_T`.
    """
    if backend not in BACKENDS:
        raise ValueError("unknown backend %r; known: %s" % (backend, sorted(BACKENDS)))
    if startup_grace is None:
        startup_grace = 3.0 if BACKENDS[backend] == "sage" else 0.0
    T_eff = max(0.5, T - startup_grace)
    interp = BACKENDS[backend]
    cmd = ([SAGE, WORKER] if interp == "sage" else [sys.executable, WORKER]) + \
          [backend, str(int(N)), json.dumps(extra)]
    t0 = time.time()
    try:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                start_new_session=True)
    except Exception as e:
        return dict(status="error", error="spawn failed: %s" % e, time_s=0.0,
                    work_s=0.0, factors=None, backend=backend, timeout=T,
                    effective_T=T_eff)
    try:
        so, se = proc.communicate(timeout=T_eff)
    except subprocess.TimeoutExpired:
        _kill_tree(proc)
        try:
            proc.communicate(timeout=5)
        except Exception:
            pass
        return dict(status="gave_up", time_s=time.time() - t0, work_s=T_eff,
                    factors=None, backend=backend, timeout=T, effective_T=T_eff,
                    note="did not finish within T; says nothing about hardness")
    el = time.time() - t0
    if not so.strip():
        return dict(status="error", error="no output; stderr=%s" % se.decode()[-400:],
                    time_s=el, work_s=el, factors=None, backend=backend,
                    timeout=T, effective_T=T_eff)
    try:
        r = json.loads(so.decode().strip().splitlines()[-1])
    except Exception as e:
        return dict(status="error", error="unparseable worker output: %r (%s)" % (so[-300:], e),
                    time_s=el, work_s=el, factors=None, backend=backend,
                    timeout=T, effective_T=T_eff)
    if "error" in r:
        return dict(status="error", error=r["error"], time_s=el, work_s=r.get("work_s", el),
                    factors=None, backend=backend, timeout=T, effective_T=T_eff)
    if "factors" in r:
        fs = [f for f in r["factors"] if f > 1]
    else:
        f = r.get("factor")
        fs = [f, N // f] if (f and 1 < f < N and N % f == 0) else []
    if not fs:
        # The backend RAN TO COMPLETION and found nothing.  This is a real,
        # distinct outcome from 'gave_up' (killed at T) and from 'error'
        # (crashed).  Do not conflate: 'ran and found nothing at these
        # parameters' is a much weaker statement than 'gave up at T'.
        return dict(status="no_factor", time_s=el, work_s=r.get("work_s", el),
                    factors=None, backend=backend, timeout=T, effective_T=T_eff,
                    note="backend completed its budget and found no factor")
    # THE ONLY GATE: multiply back.  A library's word is not evidence.
    prod = 1
    for f in fs:
        prod *= f
    if prod != N:
        return dict(status="error", error="backend output failed multiply-back",
                    time_s=el, work_s=r.get("work_s", el), factors=None,
                    backend=backend, timeout=T, effective_T=T_eff)
    return dict(status="factored", time_s=el, work_s=r.get("work_s", el), factors=fs,
                small_factor_bits=min(f.bit_length() for f in fs),
                backend=backend, timeout=T, effective_T=T_eff)


def baseline_many(N, T=60.0, backends=("ecm", "pari")):
    """Run several backends on N.  Returns {backend: result}.  Never raises."""
    return {b: baseline_factor(N, T=T, backend=b) for b in backends}


def fmt(st):
    """One-line human-readable form of a baseline result."""
    if st["status"] == "factored":
        bits = st["small_factor_bits"]
        vac = " VACUOUS(<2^40)" if bits <= 40 else ""
        return "factored in %.3fs (work %.3fs), small factor %d bits%s" % (
            st["time_s"], st.get("work_s", float("nan")), bits, vac)
    if st["status"] == "gave_up":
        return "gave up at T=%.1fs (eff %.1fs)" % (st["timeout"], st.get("effective_T", st["timeout"]))
    if st["status"] == "no_factor":
        return "ran to completion, no factor found (%.3fs)" % st["time_s"]
    return "error: %s" % st.get("error")


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("N", type=int)
    ap.add_argument("-T", type=float, default=60.0)
    ap.add_argument("-b", default="ecm")
    ap.add_argument("--B1", type=int, default=11000)
    ap.add_argument("--ncurves", type=int, default=30)
    a = ap.parse_args()
    st = baseline_factor(a.N, T=a.T, backend=a.b, B1=a.B1, ncurves=a.ncurves)
    print(json.dumps(st, default=str))
    print(fmt(st))