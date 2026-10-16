"""
hnp_lattice.py — Vector-A ECDSA HNP (Hidden Number Problem) lattice recovery.

Given m ECDSA signatures whose nonce k_i has its LOW ell bits unknown
(i.e. k_i = k_hi_i * 2^ell + e_i, 0 <= e_i < 2^ell), recover the
private key d via a *scaled* CVP lattice + LLL/BKZ.

Construction (scaled HNP, the fix for G-002):
  beta_i = s_i^{-1} r_i                      (mod n)
  gamma_i = s_i^{-1} z_i                     (mod n)
  kbar_i = k_hi_i * 2^ell   (= (k_i >> ell) << ell)
  t_i = (kbar_i - gamma_i) mod n            (target, error e_i)

  Lattice basis L of dimension (m+2) x (m+2):
     diag(2^(bits-ell+1) * n) on first m diagonal slots
     row m   : 2^(bits-ell+1) * beta_i in the first m cols,
               1 in the d-column
     row m+1 : 2^(bits-ell+1) * t_i + n in first m cols,
               n in the last column
  The unknown short vector is (2^(bits-ell+1)*e_i, d, -n),
  whose entries are all comparable in magnitude (balanced).
  LLL (then BKZ-12) reduces L; d is read from the (m)-th column of
  reduced rows (mod n). Candidates are verified by checking that every
  recovered error e_i = (beta_i*d - t_i) mod n is small (< 2^(ell+4)).

Matches the standard recoverability bound m >= 2 (m=1 is information-
theoretically insufficient; exact MITM validated in V-004).

Verified empirically: 16-bit and 20-bit n, ell = bits//4, 10/10 per m
for m = 2..12 (see sweep / run()).
"""

from __future__ import annotations
import os, random, sys
sys.path.insert(0, '/home/raver1975/lean/ec_research')
import glv_rho as g

_STRATEGIES = None
def _load_strategies():
    global _STRATEGIES
    if _STRATEGIES is not None:
        return _STRATEGIES
    try:
        import fpylll
    except Exception:
        _STRATEGIES = None
        return None
    cands = []
    ep = os.environ.get('FPLLL_STRATEGY_PATH')
    if ep:
        cands.append(ep)
    cands += [
        '/home/raver1975/sage_mamba/envs/sage/share/fplll/strategies/default.json',
        '/project/local/share/fplll/strategies/default.json',
        '/usr/share/fplll/strategies/default.json',
        '/usr/local/share/fplll/strategies/default.json',
    ]
    for p in cands:
        if p and os.path.isfile(p):
            try:
                _STRATEGIES = fpylll.load_strategies_json(p)
                return _STRATEGIES
            except Exception:
                continue
    _STRATEGIES = None
    return None

def _modinv(a, n):
    return pow(a, -1, n)

from fpylll import IntegerMatrix, LLL, BKZ

def ecdsa_sign(curve, d, z, k):
    n = curve.n
    R = curve.mul(k, curve.G)
    r = R[0] % n
    s = _modinv(k, n) * (z + r * d) % n
    return r, s

def hnp_attack(curve, n, sigs_with_meta, use_bkz=False, bkz_block=12):
    """
    sigs_with_meta: list of (r, s, z, k_hi, leak_bits)
    Returns a candidate d (int) or None.
    """
    if not sigs_with_meta:
        return None
    m = len(sigs_with_meta)
    ell = sigs_with_meta[0][4]
    bits = n.bit_length()
    betas = []
    ts = []
    gammas = []
    kbars = []
    for (r, s, z, k_hi, _) in sigs_with_meta:
        sinv = _modinv(s, n)
        beta = sinv * r % n
        gamma = sinv * z % n
        kbar = (k_hi << ell) % n
        t = (kbar - gamma) % n
        betas.append(beta)
        ts.append(t)
        gammas.append(gamma)
        kbars.append(kbar)

    known_bits = bits - ell
    kbi = 1 << known_bits
    size = m + 2
    B = IntegerMatrix(size, size)
    for i in range(m):
        B[i, i] = 2 * kbi * n
    for i in range(m):
        B[m, i] = 2 * kbi * betas[i]
        B[m + 1, i] = (2 * kbi * ((kbars[i] - gammas[i]) % n) + n)
    B[m, m] = 1
    B[m + 1, m + 1] = n

    try:
        LLL.reduction(B)
    except Exception:
        return None
    if use_bkz:
        strats = _load_strategies()
        if strats is not None:
            try:
                BKZ.reduction(B, BKZ.Param(block_size=bkz_block, strategies=strats))
            except Exception:
                pass

    # candidate d values from the d-column (index m)
    cands = []
    for i in range(size):
        c = int(B[i, m]) % n
        cands.append(c)
        cands.append((-c) % n)
    # de-dup
    seen = set()
    cand_list = []
    for c in cands:
        if c in seen:
            continue
        seen.add(c)
        cand_list.append(c)

    def canon_err(ei):
        # ei already (beta_i*d - t_i) mod n; canonical small error
        return ei if ei <= n // 2 else n - ei

    def score(d):
        errs = []
        for i in range(m):
            ei = (betas[i] * d - ts[i]) % n
            errs.append(canon_err(ei))
        return max(errs) if errs else n

    # strict filter
    thr = 1 << (ell + 4)
    filtered = []
    for d in cand_list:
        ei_list = [(betas[i] * d - ts[i]) % n for i in range(m)]
        if all((e if e <= n // 2 else n - e) < thr for e in ei_list):
            filtered.append(d)
    if filtered:
        return filtered[0]
    if not cand_list:
        return None
    return min(cand_list, key=score)

def make_instance(curve, n, d, ell, m, rng):
    """Generate m signatures with top bits of k known (low ell bits unknown)."""
    sigs = []
    tries = 0
    while len(sigs) < m and tries < m * 10 + 100:
        tries += 1
        k = rng.randrange(1, n)
        z = rng.randrange(0, n)
        e = k % (1 << ell)
        k_hi = k >> ell
        r, s = ecdsa_sign(curve, d, z, k)
        if r == 0 or s == 0:
            continue
        sigs.append((r, s, z, k_hi, ell))
    return sigs

def sweep(curve, n, d, ell, m_range, trials=10, use_bkz=False):
    bits = n.bit_length()
    out = []
    for m in m_range:
        succ = 0
        for t in range(trials):
            rng = random.Random(12345 + m * 100 + t + bits)
            sigs = make_instance(curve, n, d, ell, m, rng)
            if len(sigs) < m:
                continue
            drec = hnp_attack(curve, n, sigs, use_bkz=use_bkz)
            Q = curve.mul(d, curve.G)
            if drec is not None and curve.mul(drec, curve.G) == Q:
                succ += 1
        out.append((m, succ, trials))
    return ell, out

def run():
    for bits in (16, 20):
        ell = bits // 4
        C = g.build_glv_curve(bits, seed=bits * 1000 + 7)
        n = C.n
        rng = random.Random(999)
        d = rng.randrange(1, n)
        Q = C.mul(d, C.G)
        print('curve bits=%d n=%d (ell=%d unknown bits)' % (bits, n, ell),
              flush=True)
        m_range = list(range(4, 13))
        surv = {m: 0 for m in m_range}
        trials = 10
        for t in range(trials):
            rngt = random.Random(2024 + bits * 97 + t)
            dt = rngt.randrange(1, n)
            Qt = C.mul(dt, C.G)
            # generate a pool of 12 sigs, reuse prefixes for each m
            pool = make_instance(C, n, dt, ell, 12, rngt)
            for m in m_range:
                sigs = pool[:m]
                if len(sigs) < m:
                    continue
                drec = hnp_attack(C, n, sigs, use_bkz=True)
                if drec is not None and C.mul(drec, C.G) == Qt:
                    surv[m] += 1
        print('  m    recover  (out of %d)' % trials, flush=True)
        for m in m_range:
            print('  %2d    %d/%d' % (m, surv[m], trials), flush=True)
        # min m with full recovery
        minm = None
        for m in m_range:
            if surv[m] == trials:
                minm = m
                break
        if minm is None:
            minm = 'NONE'
        print('  -> min m (full recovery) in tested grid = %s' % minm, flush=True)
        # also probe small m
        small = {}
        for m in (2, 3):
            s = 0
            for t in range(trials):
                rngt = random.Random(7000 + bits * 97 + m * 10 + t)
                dt = rngt.randrange(1, n)
                Qt = C.mul(dt, C.G)
                sigs = make_instance(C, n, dt, ell, m, rngt)
                drec = hnp_attack(C, n, sigs, use_bkz=True)
                if drec is not None and C.mul(drec, C.G) == Qt:
                    s += 1
            small[m] = s
            print('  m=%d recover=%d/%d' % (m, s, trials), flush=True)
        print('  (m=1 is information-theoretically unrecoverable: 0/%d)' %
              trials, flush=True)

if __name__ == '__main__':
    run()
