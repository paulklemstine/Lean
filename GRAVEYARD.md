# GRAVEYARD.md — Failed Hypotheses & Post-Mortems

## G-001 — Distinguished-point density tuning causing missed collisions (F-001 first iteration)
- **Attempt:** "negation map & GLV with distinguished-point predicate (x mod 2^dp =0),
  dp ~ bits/2."
- **Failure:** 10/30 success even with 40√n max_ops; mean inflated by timeouts.
  Many walks never encountered a 2nd DP in the same class; the birthday effect was
  destroyed by the implicit requirement "second member must itself be a DP."
- **Root cause:** Distinguished-point method as implemented conflates the birthday
  collision-space N with N/2^dp; too few DPs => no collision signal.
- **Fix used:** drop DP filtering, hash EVERY step on canon_key (birthday hashing)
  -> Pure O(√N) memory/time with no tuning. Correct and matches √πN/2 asymptotic.
- **Lesson:** Don't mix DP sparsity with quotient classes without carefully deriving
  the required walk length; birthday hashing is the robust baseline.

## G-002 — HNP LLL embedding without scaling did not isolate short vector
- **Hypothesis (H-006):** HNP construction (beta_i=s_i^{-1}r_i, t_i=k_hi-gamma_i)
  allows recover d as closest CVP vector.
- **Attempt:** ran LLL / BKZ(block 8,10) on the embedded lattice with C scales
  (1, 32, 1024, √n, n) and exhaustive row-based d verification.
- **Failure:** No scale isolated the embedded (e_1..e_m, -C) short vector in any
  of 40 m-size-8 (bits=20, ell=bits/4) trials; LLL surface rows carried
  hundreds-to-thousands in the last coordinate, and no extracted d verified.
- **Root cause (diag):** The ill-conditioned basis (determinant n^m ≈ 2^100)
  combined with the un-rewritten target row lets the reduction spread the embedded
  difference across many dimensions; CVP/shortest path was not constructively found
  by block-8/10 BKZ given the conditioning.
- **Next required fix (queued, H-007):** column/row scaling (weighted HNP) and
  per-dimension BKZ (2.0) with calibrated scale; alternatively use
  fplll's embedded CVP with dimensional balancing. The *theory* of the HNP
  construction (small errors e_i=2^ell and recoverability when 2^ell ≪ n and
  m ≥ bits/(bits-ell)) is standard; empirical measurement is pending that fix.
- **Lesson:** an algebraically derived lattice attack is not "validated" until
  the scaled reduction actually isolates the secret; verifying each candidate
  against Q = dG is mandatory.

## G-003 — Shanks-Mestre with modular reduction during inner loop (silent wrong orders)
- **Symptom:** `build_glv_curve` returned n values where no point had n*P=O, and
  random curves never passed `phi(G)=lam*G`.
- **Root cause:** `Curve.mul` reduced k mod a placeholder "n = p+1", so internal SM
  multiplications `mul(m, P)` gave residues in Z_{p+1}, corrupting the trace
  computation (e.g. p=7 -> n=8 instead of 13).
- **Fix:** `Curve.mul` only reduces when `n>1` is the *true* order (0 in SM);
  set `tc2.n = 0` during point counting; verified point counting matches
  brute-force on p=7 (N=13 vs 8) after fix. (Caught by cross-check at 16-bit.)

## G-004 — Concurrent churn of `benchmarks/curve_ladder.py`
- A separate process rebuilt `benchmarks/curve_ladder.py` (importing the missing
  `_curve_data`) mid-session, discarding the in-session harness edits.
- **Mitigation used:** primary working artifact moved to self-contained
  `ec_research/glv_rho.py`; all experiments rerun from there and verified.

## G-005 — Python `gmpy2` dependency considered; chosen pure Python
- Used pure-Python affine arithmetic (Fermat inversion) for simplicity; tuned bit
  sizes to ≤28-bit for the main comparison, enough to fit the asymptotic
  constants with bounded runtime.

## G-002 — RESOLUTION (V-006, 2026-10-16)
Scaled HNP basis fixes the conditioning issue: balance every coordinate by
2^(bits-ell+1) and fold `+n` into the target row. LLL alone now isolates d
at m >= 2, 16-bit and 20-bit, 10/10 per m (m=4..12 reported). The original
failure remains instructive (never ship an unscaled embedded lattice), but the
hypothesis is no longer dead: use `ec_research/hnp_lattice.py`.

## G-009 — Smart attack fixed-Hensel-lift precision / valuation (H-009, 2026-10-16)
- **Attempt:** Hensel-lift each F_p point by keeping x fixed and lifting y mod p^n
  (n=5), p-multiply in p-adic (affine formulas on a `Padic` residue ring of
  precision n), and take phi = normalised leading term of t = -x/y.
- **What worked:** For random anomalous curves with v_p(t(p*lift(P))) = 1,
  recovery is exact and polynomial-time: 12-bit (3 trials), 16-bit (2 trials),
  and one 20-bit non-CM curve all gave d_rec = d_true with phi(G) != 0, and
  smart wall time ~1-2 ms vs BSGS ~0.1-2.6 ms at those sizes.
- **Failure:** For j=0 CM anomalous curves (e.g. y^2 = x^3 + 3 over F_p with
  trace 1) p*lift(P) lands in E_2: v_p(t) = 2, so the naive normalisation
  t/p is divisible by p and phi(G) ≡ 0 mod p (uninvertible). Dividing by p^2
  instead produced unit residues but broke the group homomorphism
  (phi(2G) != 2 phi(G) mod p), so no recovery; canonical lifts are required.
- **Root cause:** The fixed-Hensel "horizontal" lift x=x0 is not a group
  homomorphism; the lift error for points can land at valuation 2, and the first
  nonzero term of the formal logarithm then requires higher/canonical lifting.
- **Lesson:** Smart's attack is conditionally linear-time: validate valuation
  v_p(t) = 1 (and phi(G) != 0 mod p) per curve; otherwise fall back to BSGS or
  implement canonical lifting (not done here).

## G-009 — RESOLUTION (V-007, 2026-10-16, partial)
- **What remains dead:** The fixed-Hensel horizontal lift `x = x_0 (mod p^n)`
  used in `ec_research/smart.py` (`smart_phi_full`) is **not** valid for CM
  (j=0, `#E=p`) curves: empirical `v_p(t(p*lift(P))) = 2`,
  `phi(G) ≡ 0 (mod p)`, and the `phi(2G) = 2 phi(G)` homomorphism test
  fails.  `smart.py` is left untouched; on CM inputs it still raises
  `u not unit ... (v=2)` and must be treated as fail/bsgs-fallback there.
- **What works now:** `ec_research/smart_cm.py` randomises the curve lift
  `a4 = p*alpha`, `a6 = b + p*beta (mod p^3)` (non-canonical, same reduction)
  and recovers d for 10/10 CM instances, bits 12-16 (p = 2791..60919), with
  `v_G = v_Q = 1` and verified `d*G == Q` plus BSGS cross-check; 0 bad draws
  in 10 tries.
- **Not yet tested / not proved:** canonical CM lifting; p=2,p=3 (excluded
  throughout); larger p where generation cost dominates; behaviour of bad draws
  at probability ~1/p (none observed for these 10 small primes).
- **Exact failing mechanism (root cause):** horizontal Hensel lift lands the
  lift in `E_2`, so the first nonzero term of the formal-group logarithm is at
  `p^2`, not `p`; naively dividing by `p` zeroes it, and dividing by `p^2`
  desynchronises the group law (`phi` no longer homomorphism).
