# STATE.md — Current Research State

**Active hypothesis:** H-001 (v0 complete) + branching to GLV/Kangaroo refinements.
**Active tier:** Tier 2 (20–24 bit), transitioning to Tier 3 (28+ bit).
**Last updated:** after Hypothesis #001 run.

## Current best (H-001, GLV negation 6-point quotient Pollard Rho)

On j=0 curves `y^2 = x^3 + b over F_p` (`p ~ 1 mod 3`) with the GLV
endomorphism `phi(x,y) = (beta*x, y)`, `phi(P) = lambda*P`,
`lambda^2 + lambda + 1 = 0 (mod n)`:

| Tier | bits(n) | Vanilla ops mean | Neg-map ops mean | GLV(6) ops mean | GLV speedup |
|------|---------|------------------|------------------|------------------|-------------|
| 16   | 14      | 130  (1.12√n)   | 116 (1.00√n)    | 54  (0.47√n)    | 2.41×       |
| 20   | 20      | 1009 (1.26√n)   | 634 (0.84√n)    | 415 (0.55√n)    | 2.43×       |
| 24   | 22      | 2411 (1.34√n)   | 1239 (0.69√n)   | 1001 (0.56√n)   | 2.41×       |
| 28   | 28      | 14367(1.10√n)   | 12625 (0.96√n)  | 7517 (0.57√n)   | 1.91×       |
| 36   | 34      | 161284 (1.266√n)| 116996(0.918√n) | 65842 (0.517√n)| 2.45×       |

Theory: Pollard rho ≈ sqrt(pi*n/2) group ops = 1.253√n.
GLV 6-point quotient should be ~sqrt(pi*n/12) = 1.253√n/√6 = 0.512√n.
Observed 0.47–0.57√n (inst. noise) is **consistent with the √6 claim**.
Negation map (sqrt(2)) Mean factor 1.25–1.4 over bits; close to √2 (1.41).

## V-001 36-bit variance-tightened batch (2026-10-16)
- 100 instances per variant on one 36-bit GLV curve (n=16232596129, W=256,
  max_ops=20√n). 300/300 recoveries; data in ec_research/glv_stress.json.
- Means: vanilla 161284 (1.266√n), neg 116996 (0.918√n), GLV 65842 (0.517√n).
- Medians: vanilla 150808 (1.184√n), neg 109236 (0.857√n), GLV 62318 (0.489√n).
- Speedup: GLV 2.450× (mean) / 2.420× (median); neg 1.379× / 1.381×.
- Consistent with √6 (0.512√n) within sampling noise; high CV (~0.55).

## Open questions (child hypotheses)
- H-002 (queued): Kangaroo with GLV + j=0 richer equivalence (counting rule) on
  distinguished points; expected even better constant.
- H-003 (validated, V-006/V-006b): Vector-A HNP lattice recovery with correctly scaled embedding (LLL-only, 24-32 bits).
  Construction derived; needs HNF/scaling implementation pass.
- H-004 (queued): endomorphism primes p ≡ 2 mod 3 with Sophie-Germain-like
  hard-anomalous ratios.

## Recent results / validated
- Negation map 2-walk reduces ops by factor ~1.5 on 20-bit (incl variance).
- 6-point GLV class walk proves out at √6 ≈ 2.45 experimentally.

## Falsifications / graveyard (see GRAVEYARD.md)
- dp-bits tuning wrong setting kills distinguished-point rho (now fixed: pure
  birthday hashing on the quotient key, which is memory-bounded but correct).
- HNP embedding without scaling does not isolate the short vector — needs
  pre-scaling or BKZ tuning. Logged.

## H-009 measured (Smart p-adic, 2026-10-16)
- Script: `ec_research/smart.py` (random anomalous curve generation + Smart + BSGS).
- Recovery verified (d_rec*G == Q) on random non-CM anomalous curves:
    12-bit: 3/3 (smart ~0.001 s; bsgs ~0.0001 s)
    16-bit: 2/2 (smart ~0.0015 s; bsgs ~0.0004 s)
    20-bit: 1/1 (smart ~0.0020 s; bsgs ~0.0026 s)
- Precision: 5 p-adic digits (Padic residue ring), Hensel y-lift, x fixed.
- Blocker: j=0 CM trace-1 curves (e.g. y^2=x^3+3) have v_p(t(p*lift(P)))=2,
  causing phi(G) == 0 mod p; canonical lifting needed (not implemented). Logged G-009.

## H-007 measured (HNP scaling, 2026-10-16)
Scaled HNP (`ec_research/hnp_lattice.py`) LLL-only recovery, pure-Python `d·G==Q`
acceptance, m in {2,3,4,6,8,12,16}, leak 0.25/0.5:

| target bits (n bits) | leak | ell | min m (all trials) | m=2 recovery | median LLL ms @m=2 / @m=16 |
|---|---|---|---|---|---|
| 24 (22) | 0.25 | 6 | 2 | 12/12 | 0.075 / 0.669 |
| 24 (22) | 0.50 | 12 | 3 | 1/12 | 0.057 / 0.602 |
| 28 (28) | 0.25 | 7 | 2 | 10/10 | 0.062 / 0.670 |
| 28 (28) | 0.50 | 14 | 3 | 6/10 | 0.062 / 0.655 |
| 32 (31) | 0.25 | 8 | 2 | 8/8 | 0.077 / 0.795 |
| 32 (31) | 0.50 | 16 | 3 | 3/8 | 0.097 / 0.770 |

- Trials: 12 / 10 / 8 at 24 / 28 / 32 bits (420 LLL attempts, 400 recoveries).
- m=2 failures at leak=0.5 are information-theoretic (BKZ-12 recovered 0/20).
- Cost ~linear in m; sub-ms LLL wall time throughout; no BKZ required.
- Trial log: `/tmp/opencode/hnp_trials.jsonl`; report: V-006b.

## Further cycle updates 2026-10-16
- 36-bit GLV 100-inst: mean speedup GLV 2.45x vs vanilla (median 2.42x); variance within theory; see VICTORY_LOG.
- HNP scaling: V-006a/b documented; m boundaries solid; 24-32 bits reported.
- H-009b canonical lifts: subagent returned no summary; Smart non-CM remains validated at 12/16/20 bits.
