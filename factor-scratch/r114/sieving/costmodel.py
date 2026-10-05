#!/usr/bin/env python3
"""
r114 / sieving axis -- NFS sieving cost model.

Fits L_N[1/3, c] forms to cado-nfs's OWN shipped parameter model
(parameters/factor/params.c*), which is a real, checked-in, tuned artifact --
not a number recalled from a textbook.

The point of this file is to answer: what is the sieving exponent, and is the
SIEVE or the LINEAR ALGEBRA the cost driver at RSA-2048 scale?
"""
import math
import re
import glob
import os

CADO = "/home/raver1975/factor47/V11/cado/cado-nfs/parameters/factor"


def load_params():
    rows = []
    for f in glob.glob(os.path.join(CADO, "params.c*")):
        m = re.search(r"c(\d+)$", f)
        if not m:
            continue
        n = int(m.group(1))
        t = open(f).read()

        def g(k, cast=int):
            mm = re.search(r"^%s = (\d+)\s*$" % k, t, re.M)
            return cast(mm.group(1)) if mm else None

        deg = g("tasks.polyselect.degree")
        lim0, lim1 = g("tasks.lim0"), g("tasks.lim1")
        lpb0, lpb1 = g("tasks.lpb0"), g("tasks.lpb1")
        mfb0, mfb1 = g("tasks.sieve.mfb0"), g("tasks.sieve.mfb1")
        I = g("tasks.I")
        if lim0 is None or lpb0 is None or deg is None:
            continue
        rows.append(dict(ndig=n, deg=deg, lim0=lim0, lim1=lim1,
                         lpb0=lpb0, lpb1=lpb1, mfb0=mfb0, mfb1=mfb1, I=I))
    rows.sort(key=lambda r: r["ndig"])
    return rows


def Lform(lnN, alpha):
    """the (lnN)^alpha (lnlnN)^(1-alpha) factor in L_N[alpha, c]"""
    return (lnN ** alpha) * (math.log(lnN) ** (1 - alpha))


def fit(rows, key, alpha, lo, hi):
    """least-squares fit of  ln(key) = ln(k0) + c*Lform(lnN,alpha)  on ndig in [lo,hi].

    Returns (k0, c, r2, n).
    """
    xs, ys = [], []
    for r in rows:
        if not (lo <= r["ndig"] <= hi):
            continue
        v = r[key]
        if not v or v <= 0:
            continue
        lnN = r["ndig"] * math.log(10)
        xs.append(Lform(lnN, alpha))
        ys.append(math.log(v))
    n = len(xs)
    if n < 4:
        return None
    mx = sum(xs) / n
    my = sum(ys) / n
    sxx = sum((x - mx) ** 2 for x in xs)
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    c = sxy / sxx
    k0 = my - c * mx
    resid = [y - (k0 + c * x) for x, y in zip(xs, ys)]
    ssr = sum(e * e for e in resid)
    sst = sum((y - my) ** 2 for y in ys)
    r2 = 1 - ssr / sst if sst > 0 else float("nan")
    return math.exp(k0), c, r2, n


def main():
    rows = load_params()
    print("=== cado-nfs shipped parameter model: sieve bounds vs digit length ===")
    print(f"{'ndig':>5}{'deg':>4}{'lim0':>14}{'lim1':>14}{'lpb0':>5}{'mfb0':>6}"
          f"{'I':>4}{'lnN':>8}{'c(lim0,1/3)':>12}")
    for r in rows:
        if not (100 <= r["ndig"] <= 270):
            continue
        lnN = r["ndig"] * math.log(10)
        f = Lform(lnN, 1.0 / 3.0)
        g2 = lambda v, w: (str(v) if v else "-").rjust(w)
        print(f"{r['ndig']:>5}{str(r['deg']):>4}{g2(r['lim0'],14)}{g2(r['lim1'],14)}"
              f"{g2(r['lpb0'],5)}{g2(r['mfb0'],6)}{g2(r['I'],4)}{lnN:>8.2f}"
              f"{math.log(r['lim0'])/f:>12.4f}")

    print()
    print("=== FITS over ndig in [100,270] ===")
    for key, alpha in [("lim0", 1/3), ("lim1", 1/3),
                       ("lim0", 1/2), ("lim0", 1/4),
                       ("lpb0", 1/3), ("mfb0", 1/3)]:
        fitr = fit(rows, key, alpha, 100, 270)
        if fitr is None:
            print(f"  {key:>6} alpha={alpha:.4f}: insufficient data")
            continue
        k0, c, r2, n = fitr
        print(f"  {key:>6} alpha={alpha:.4f}:  ln({key}) = ln({k0:.4g}) + "
              f"{c:.4f}*Lform   r^2={r2:.4f}  n={n}")

    print()
    print("=== WHAT THIS IMPLIES AT RSA-2048 (n = 2^2048) ===")
    lnN = 2048 * math.log(2)
    print(f"  ln N = {lnN:.4f},  ln ln N = {math.log(lnN):.4f}")
    for key in ("lim0", "lim1"):
        for lo, hi in ((100, 270), (150, 270)):
            fitr = fit(rows, key, 1/3, lo, hi)
            if fitr is None:
                continue
            k0, c, r2, n = fitr
            pred = math.exp(k0) * math.exp(c * Lform(lnN, 1/3))
            print(f"  {key} predicted from fit[{lo},{hi}] (c={c:.4f}, r2={r2:.4f})"
                  f": {pred:.4g}   = 2^{math.log2(pred):.2f}")
    # what cado's own nearest shipped entry says
    for r in rows:
        if r["ndig"] == 270:
            print(f"  cado c270 (621.7 lnN) shipped: lim0={r['lim0']:d} "
                  f"({math.log2(r['lim0']):.2f} bits), lpb0={r['lpb0']} "
                  f"(2^{r['lpb0']} base bound)")
    print(f"  RSA-2048 = {math.log10(2**2048):.1f} decimal digits -> "
          f"BEYOND every shipped cado parameter file (max c320).")


if __name__ == "__main__":
    main()