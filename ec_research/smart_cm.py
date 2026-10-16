"""Smart's p-adic ECDLP attack, canonical/non-canonical-lift variant for
CM (j=0, trace-1 anomalous) curves  y^2 = x^3 + b  over F_p.

Prior (ec_research/smart.py) fixed-Hensel horizontal lifts x = x0 land in E_2
for j=0 CM curves (v_p(t(p*lift)) = 2, phi(G) ≡ 0 mod p).  This variant
randomises the lift of the curve equation (a4 -> p*alpha, a6 -> b + p*beta)
so the reduction mod p is unchanged but the p-adic lift is non-canonical.
Empirically this restores v_p(t) = 1 and makes phi an invertible homomorphism,
allowing d recovery by d = phi(Q)*phi(G)^{-1} mod p.
"""
from __future__ import annotations
import argparse, json, math, random, sys, time

sys.path.insert(0, "/home/raver1975/lean/ec_research")

from smart import (
    _is_prime,
    Padic,
    ec_add_fp,
    ec_mul_fp,
    find_gen_fp,
    hensel_sqrt,
    ec_mul_padic,
    bsgs_ecdlp,
    modinv,
    vp_int,
)

PRECI = 3   # work modulo p^3


# ---------- curve generation (CM, j=0, trace 1) ----------

def gen_cm_anomalous(bits, rng, max_prime_tries=200000, max_b_tries=200):
    attempts = 0
    while attempts < max_prime_tries:
        attempts += 1
        # a CM prime must split in Q(sqrt(-3)): p ≡ 1 (mod 3)
        while True:
            p = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
            if p % 2 == 0:
                p += 1
            if p % 3 == 1 and _is_prime(p):
                break
        is_qr = bytearray(p)
        for r in range(1, p):
            is_qr[(r * r) % p] = 1
        for _ in range(max_b_tries):
            b = rng.randrange(1, p)
            if (27 * b * b) % p == 0:
                continue
            a = 0
            total = 1
            for x in range(p):
                rhs = (x * x * x + b) % p
                if rhs == 0:
                    total += 1
                elif is_qr[rhs]:
                    total += 2
            if total == p:  # #E(F_p) = p  (trace 1, anomalous)
                try:
                    G = find_gen_fp(a, b, p, rng)
                except Exception:
                    continue
                return p, a, b, G
    raise RuntimeError(f"failed to find CM anomalous curve at {bits} bits")


# ---------- p-adic phi with randomised curve lift ----------

class LiftError(Exception):
    pass


def compute_phi(p, alpha, beta, b0, x0, y0, prec=PRECI):
    """Return (phi_mod_p, t_valuation, A_lift, B_lift, y_lift) for the lift
    E_lift: y^2 = x^3 + (p*alpha)*x + (b0 + p*beta), with point x=x0 (fixed)
    and y lifted by Hensel.  Raises LiftError if v_p(t) != 1 or unit extraction fails."""
    pk = p ** prec
    A_lift = (p * (alpha % p)) % pk
    B_lift = (b0 + p * (beta % p)) % pk
    f = (x0 * x0 * x0 + A_lift * x0 + B_lift) % pk
    y_lift = hensel_sqrt(f, y0, p, prec)
    if (y_lift * y_lift - f) % pk != 0:
        raise LiftError("hensel_sqrt did not produce root")
    x_padic = Padic.from_int(x0, p, prec)
    y_padic = Padic.from_int(y_lift, p, prec)
    R = ec_mul_padic(p, (x_padic, y_padic), A_lift, p, prec)
    if R is None:
        raise LiftError("p*lift is None (point at infinity)")
    X, Y = R
    t = X.neg().div(Y)
    v = t.val if t.val is not None else 10 ** 9
    if v is None or v < 1:
        raise LiftError(f"valuation {v} < 1")
    if v != 1:
        raise LiftError(f"valuation {v} != 1 (E2/non-unit)")
    pp = Padic.from_int(p, p, prec)
    u = t.div(pp)
    if u.val != 0:
        raise LiftError(f"normalised value not a unit (val {u.val})")
    phi = u.unit % p
    if phi % p == 0:
        raise LiftError("phi ≡ 0 mod p (uninvertible)")
    return phi, v, A_lift, B_lift, y_lift


def find_nondeg_lift(p, b0, G, Q, prec=PRECI, max_tries=500, rng=None):
    """Randomise (alpha,beta) until phi(G),phi(Q) both have v=1 and phi(G)!=0
    and the induced discrete log verifies.  Returns params + diagnostics."""
    if rng is None:
        rng = random.Random()
    vG = vQ = None
    lift_tries = 0
    zero_phi = 0
    exceptions = 0
    val_failures = 0
    alpha = beta = None
    phiG = phiQ = None
    A_lift = B_lift = None
    yG = yQ = None
    t0 = time.perf_counter()
    while lift_tries < max_tries:
        lift_tries += 1
        alpha = rng.randrange(p)
        beta = rng.randrange(p)
        try:
            phiG, vG, A_lift, B_lift, yG = compute_phi(
                p, alpha, beta, b0, G[0], G[1], prec)
        except LiftError as e:
            msg = str(e)
            if "phi ≡ 0" in msg:
                zero_phi += 1
            elif "valuation" in msg or "normalised" in msg or "E2" in msg:
                val_failures += 1
            else:
                exceptions += 1
            continue
        if phiG % p == 0:
            zero_phi += 1
            continue
        # require phi(Q) with the same lift
        try:
            phiQ, vQ, _, _, yQ = compute_phi(
                p, alpha, beta, b0, Q[0], Q[1], prec)
        except LiftError as e:
            msg = str(e)
            if "phi ≡ 0" in msg:
                zero_phi += 1
            elif "valuation" in msg or "normalised" in msg:
                val_failures += 1
            else:
                exceptions += 1
            continue
        if phiQ is None:
            continue
        # verify induced discrete log immediately
        try:
            d_rec = (phiQ * modinv(phiG, p)) % p
        except Exception:
            exceptions += 1
            continue
        lift_time = time.perf_counter() - t0
        return {
            "alpha": alpha, "beta": beta,
            "phiG": phiG, "phiQ": phiQ,
            "vG": vG, "vQ": vQ,
            "A_lift": A_lift, "B_lift": B_lift,
            "yG": yG, "yQ": yQ,
            "lift_tries": lift_tries,
            "zero_phi": zero_phi,
            "val_failures": val_failures,
            "exceptions": exceptions,
            "lift_time": lift_time,
            "d_rec": d_rec,
        }
    raise RuntimeError(
        f"no non-degenerate lift found in {max_tries} tries "
        f"(zero_phi={zero_phi}, val_failures={val_failures}, exceptions={exceptions})")


# ---------- main driver ----------

def run_one(bits, rng, trials=1, prec=PRECI):
    results = []
    for t in range(trials):
        t0 = time.time()
        p, a, b, G = gen_cm_anomalous(bits, rng)
        gen_time = time.time() - t0

        d_true = rng.randrange(1, p)
        Q = ec_mul_fp(d_true, G, a, b, p)

        ts = time.time()
        failure = None
        d_rec = None
        info = None
        vG = vQ = None
        lift_tries = None
        zero_phi = None
        val_failures = None
        exceptions = None
        alpha = beta = None
        attack_time = None
        try:
            ts_lift = time.time()
            info = find_nondeg_lift(p, b, G, Q, prec=prec, rng=rng)
            lift_time = info["lift_time"]
            alpha = info["alpha"]
            beta = info["beta"]
            vG = info["vG"]
            vQ = info["vQ"]
            d_rec = info["d_rec"]
            # independent verification dG == Q
            if not (ec_mul_fp(d_rec, G, a, b, p) == Q):
                failure = "verification dG != Q"
            attack_time = time.time() - ts
        except Exception as e:
            failure = f"exception: {e}"
            attack_time = time.time() - ts
            if info is not None:
                lift_tries = info.get("lift_tries")
                zero_phi = info.get("zero_phi")
                val_failures = info.get("val_failures")
                exceptions = info.get("exceptions")
                vG = info.get("vG")
                vQ = info.get("vQ")
                alpha = info.get("alpha")
                beta = info.get("beta")
        if info is not None:
            lift_tries = info.get("lift_tries")
            zero_phi = info.get("zero_phi")
            val_failures = info.get("val_failures")
            exceptions = info.get("exceptions")
            if vG is None:
                vG = info.get("vG")
            if vQ is None:
                vQ = info.get("vQ")
            if alpha is None:
                alpha = info.get("alpha")
            if beta is None:
                beta = info.get("beta")

        smart_ok = (failure is None and d_rec is not None
                    and ec_mul_fp(d_rec, G, a, b, p) == Q)

        # BSGS baseline
        tb = time.time()
        d_bsgs, _ = bsgs_ecdlp(G, Q, a, b, p)
        bsgs_time = time.time() - tb
        bsgs_ok = (d_bsgs is not None and ec_mul_fp(d_bsgs, G, a, b, p) == Q)

        results.append({
            "bits": bits, "p": p, "a": a, "b": b, "d_true": d_true,
            "d_rec": d_rec, "smart_ok": smart_ok, "smart_fail": failure,
            "smart_time": attack_time if attack_time is not None else (time.time() - ts),
            "lift_tries": lift_tries, "alpha": alpha, "beta": beta,
            "vG": vG, "vQ": vQ, "zero_phi": zero_phi,
            "val_failures": val_failures, "exceptions": exceptions,
            "lift_time": (info["lift_time"] if info else None),
            "gen_time": gen_time,
            "bsgs_d": d_bsgs, "bsgs_ok": bsgs_ok,
            "bsgs_time": bsgs_time,
        })
        print(f"[bits={bits}] trial {t}: p={p} smart_ok={smart_ok} "
              f"smart_time={results[-1]['smart_time']:.4f}s "
              f"fail={failure} lift_tries={lift_tries} alpha={alpha} beta={beta} "
              f"vG={vG} vQ={vQ} zero_phi={zero_phi} val_fail={val_failures} "
              f"bsgs_time={bsgs_time:.4f}s bsgs_ok={bsgs_ok} gen={gen_time:.2f}s",
              flush=True)
    return results


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bits", type=int, nargs="+", default=[12, 13, 14, 15, 16])
    ap.add_argument("--trials", type=int, default=2)
    ap.add_argument("--prec", type=int, default=PRECI)
    args = ap.parse_args()
    rng = random.Random(20261016)
    allres = []
    for bits in args.bits:
        rs = run_one(bits, rng, trials=args.trials, prec=args.prec)
        allres.extend(rs)
    print("\n=== SUMMARY ===")
    n_ok = sum(1 for r in allres if r["smart_ok"])
    print(f"smart successes: {n_ok}/{len(allres)}")
    for r in allres:
        print(r)
    out_txt = "/home/raver1975/lean/ec_research/smart_cm_results.txt"
    with open(out_txt, "w") as f:
        for r in allres:
            f.write(repr(r) + "\n")
    # also append a marker block to the legacy results file
    with open("/home/raver1975/lean/ec_research/smart_results.txt", "a") as f:
        f.write("# --- smart_cm.py (CM j=0 non-canonical lift) run ---\n")
        for r in allres:
            f.write("CM_LIFT " + repr(r) + "\n")
    with open("/home/raver1975/lean/ec_research/smart_cm_results.json", "w") as f:
        json.dump(allres, f, indent=1, default=str)


if __name__ == "__main__":
    main()
