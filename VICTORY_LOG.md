# VICTORY_LOG.md — Validated Speedups

## V-001 — GLV endomorphism quotient yields √6 Pollard-Rho speedup (H-001)

**Curve family:** j=0 `y^2 = x^3 + b` over F_p, p ≡ 1 mod 3, GLV automorphism
`phi(x,y) = (beta*x, y)`, `beta^3 = 1`, acting as `phi(P) = lambda P`,
`lambda^2 + lambda + 1 = 0 (mod n)` on the prime-order subgroup <G> of order n.

**Algorithm:** Distinguished-point-free birthday hashing on the KEY SPACE:
- Vanilla: keyspace size n (full point identity), table key = (x, y).
- Negation map: keyspace size n/2, key = x (P and -P collide).
- GLV 6-point class: keyspace size n/6, key = min of {±P, ±φ(P), ±φ²(P)}.
On a hash collision the allowed transformations (identity; + negation; negation +
λ, λ² for GLV) are tried and verified against Q = dG before returning d.

### Reproducible benchmark tables

Bit-size | instances | vanilla ops (mean) | neg ops (mean) | GLV ops (mean) | GLV speedup |
|---|---|---|---|---|---|
| 16  | 20 |  130  (1.12√n) |  116 (1.00√n) |   54 (0.47√n) | 2.41× |
| 20  | 40 | 1009  (1.26√n) |  634 (0.84√n) |  415 (0.55√n) | 2.43× |
| 24  | 20 | 2411  (1.34√n) | 1239 (0.69√n) | 1001 (0.56√n) | 2.41× |
| 28  | 20 | 14367 (1.10√n) | 12625 (0.96√n) | 7517 (0.57√n) | 1.91  |
| 36  |  5 | 329566(1.33√n) | 191285(0.77√n) |107409 (0.44√n) | 3.07× |

Theoretical constants: Pollard ρ ≈ √(π n/2) = 1.253√n; GLV ≈ √(π n/12) = 1.253√n/√6 = 0.512√n.
Observed GLV 0.47–0.57√n (inst. variance; 0.51 predicted, 0.51–0.55 median) —
consistent with √6 claim. Negation map 0.69–1.00√n (predicted 0.884√n) —
consistent with √2.

### 20-bit per-instance ratio (40 instances)
- vanilla 1009 mean, neg 634 (1.59×), GLV 415 (2.43×) — 100% success all variants.

### Mathematical proof sketch of correctness
phi is an F_p-endomorphism of j=0 curve (phi^2+phi+1=0). On the prime-order
subgroup <G>, phi(G) = lambda*G, lambda^2+lambda+1 = 0 mod n. Two points P,P'
collide on the class key iff P = s*phi^j(P') for s∈{±1}, j∈{0,1,2}
(6 possibilities), which the solver tries exhaustively and verifies
`dG == Q` before returning. Transform: a+b d = s*lambda^j*(a'+b' d) =>
d = (a - s*lambda^j*a') / (s*lambda^j*b' - b) mod n. Verified by scalar mult
every accepted d, so no false returns.

### Code
- `ec_research/glv_rho.py` (self-contained: curve gen, Shanks-Mestre order
  computation, GLV verification, all 3 rho variants, benchmark driver).

### Variance-tightened 36-bit batch (V-001 consistency)

Re-run of H-001 36-bit tier with a 100-instance batch to tighten the previously
high-variance 5-instance estimate. Uses `ec_research/glv_rho.py` (untouched),
`build_glv_curve(bits=36, seed=1000*36+0)`, then `pollard_rho(...)` for all 3
variants with `W=256`, `max_ops=20√n` (≈2.55M), deterministic per-instance RNG.

- Curve: n = 16232596129 (34-bit order, j=0, p ≡ 1 mod 3); all 300 runs
  recovered d and passed `dG == Q` verification (100% success each variant).
- Trial-wise aggregates: `ec_research/glv_stress.json`.

Results (N = 100 per variant):

| variant   | N   | success     | mean ops | mean/√n | median ops | median/√n | min    | max     |
|-----------|-----|-------------|----------|---------|------------|-----------|--------|---------|
| vanilla   | 100 | 100/100    | 161284   | 1.266   | 150808     | 1.184     | 8059   | 425084  |
| neg       | 100 | 100/100    | 116996   | 0.918   | 109236     | 0.857     | 16975  | 270426  |
| GLV (6)   | 100 | 100/100    | 65842    | 0.517   | 62318      | 0.489     | 1988   | 166859  |

Speedups (vanilla / variant): GLV mean **2.450×** (median **2.420×**); neg
mean **1.379×** (median **1.381×**).

Interpretation / variance notes:
- Theory: Pollard ρ ≈ √(π n/2) = 1.253√n; negation quotient √2 =>
  0.886√n; GLV 6-class quotient √6 => 0.512√n. Observed GLV median 0.489√n
  is ≈4.5% below the point estimate but the mean is 0.517√n, and the
  distribution is right-skewed (CV ≈0.55), so this is sampling noise for
  N=100, not a deviation from the √6 claim. Negation median 0.857 vs
  0.886 (−3.3%) and vanilla median 1.184 vs 1.253 (−5.5%) are likewise within
  sampling uncertainty.
- The `min` columns contain extreme early birthday hits (e.g. 1988 GLV ops,
  0.016√n) that drive the per-instance speedup mean to 4.35×; the **median**
  instance speedup is 2.52×, the appropriate robust figure. No bogus
  "100× speedup" should be quoted without the median caveat.
- The prior 5-instance 36-bit row above (GLV 107409 ops, 3.07×) was an
  optimistic small-sample fluctuation; the 100-instance estimate (2.42–2.45×)
  is the authoritative one and matches the √6 prediction exactly. V-001
  conclusion unchanged: **GLV 6-point quotient achieves a factor ≈√6**.

## V-003 — Anomalous curve generation (infrastructure: Vector D / Smart linear attack)
- Deterministic search in pure Python: Shanks-Mestre #E accept when `#E(F_p) == p`
  (trace `t = 1`, group order p).
- Found ~3 (20-bit) anomalous primes in <5 sec (density ~1/7000). Verified on
  p=698419: `n=p`, prime, cyclic. ECDLP solver scaffold for Smart's p-adic
  linear-time attack pending p-adic-lift + formal-group-logarithm module (H-009).

## V-004 — ECDSA HNP equation verified & exact recovery (Vector A substrate)
- Derived HNP: `β_i = s_i^{-1} r_i mod n`; `β_i d ≡ δ_i + e_i (mod n)` with
  `δ_i = k_hi_i·2^ell − s_i^{-1} z_i (mod n)`, error `e_i ∈ [0,2^ell)`.
- Exact meet-in-the-middle (cost `O(2^ell)` per sig) gives t recovery:
    16-bit n, `ell=4` (high 12 bits leaked info), `m=2` sigs, **10/10 success**
    in ~0.04 ms median — independently proving the HNP equation is correctly
    derived and solvable (the prior LLL-embedding failures (G-002) are purely an
    engineer-reduction issue, **not** a theory issue).
- This validation unblocks H-007: now only correct scaling/HNF of the BKZ reduction
  remains; larger `m,ell` follow once verified.


## V-005 — H-004 batching/normalising optimisations: NOT effective (falsified)

**Hypothesis:** H-004 (Adaptive canonical representative, normalisation without extra inversion,
batching of inversions) would make the j=0 GLV Pollard-rho walk >5% faster in wall-clock at the
24-bit and 28-bit tiers without changing group-op counts or correctness.

**Implementation:** `ec_research/batched_rho.py` — same three variants (`vanilla`, `neg`, `glv`)
as `ec_research/glv_rho.py` (untouched), but walk state kept in Jacobian coordinates and advanced
with mixed (affine+Jacobian) addition; affine conversion of the current point for the canonical
representative / table key is performed once per step via Fermat inverse (with a Montgomery
batched-inversion helper `batch_inv_montgomery` / `batch_jac_to_affine` provided for point-side
multi-point work).  `glv_rho.build_glv_curve` / `make_step_table` reused for curve and step-table
generation (identical instances, seeds and parameters to the affine baseline).

**Method:** paired comparison, identical curve/instance/step-table/RNG for both implementations;
`time.perf_counter` wall-clock; op count = one rho step = one group addition.

### Results (success = 100% all variants/instances, op-count ratio batched/affine = 1.000)

Bit-size | instances | variant | affine ops (mean) | affine wall (mean) | batched wall (mean) | speedup aff/batched |
|---|---|---|---|---|---|---|
| 20 | 40 | vanilla | 1203 | 0.0113 s | 0.0123 s | 0.915x |
| 20 | 40 | neg     | 871  | 0.0101 s | 0.0113 s | 0.892x |
| 20 | 40 | glv     | 493  | 0.0098 s | 0.0103 s | 0.946x |
| 24 | 10  | vanilla | 3151 | 0.0203 s | 0.0236 s | 0.860x |
| 24 | 10  | neg     | 1737 | 0.0155 s | 0.0167 s | 0.933x |
| 24 | 10  | glv     | 1148 | 0.0144 s | 0.0168 s | 0.855x |
| 28 | 5   | vanilla | 10187 | 0.0575 s | 0.0660 s | 0.871x |
| 28 | 5   | neg     | 7426  | 0.0349 s | 0.0425 s | 0.822x |
| 28 | 5   | glv     | 3038  | 0.0251 s | 0.0281 s | 0.895x |
| 36 | 5   | vanilla | 132674 | 1.2037 s | 1.4938 s | 0.806x |
| 36 | 5   | neg     | 68435  | 0.6736 s | 0.8074 s | 0.834x |
| 36 | 5   | glv     | 65862  | 0.6975 s | 0.8163 s | 0.854x |

**Conclusion:** Group-op counts are byte-identical (1.000 ratio) and recovery is 100%, but the batched
Jacobian variant is consistently 5-20% *slower* than the affine baseline (best speedup 0.946x),
because each step still requires one Fermat inverse to obtain canonical affine coordinates for the
table key, plus the higher per-step multiplication count of the Jacobian mixed-addition formulas.
H-004 is therefore **falsified** for the claimed >5% wall-clock improvement on this curve family.

## V-006 — Scaled ECDSA HNP lattice recovery (Vector A H-007) [VALIDATED]

**Fix of G-002.** The ill-conditioned unscaled embedded lattice is replaced by a
balanced (m+2)x(m+2) basis scaled by 2^(bits-ell+1): diagonal slot
`2^(bits-ell+1)*n`, d-row `2^(bits-ell+1)*beta_i`, target row
`2^(bits-ell+1)*t_i + n`, with `1` and `n` in the last two columns.
LLL alone isolates the short vector `(2^(bits-ell+1)*e_i, d, -n)`; d is
read from the d-column (mod n) and verified by checking every error
`e_i = (beta_i*d - t_i) mod n` is small (`< 2^(ell+4)`), and finally by
`d*G == Q` in the acceptance criterion. BKZ-12 (strategies from fplll) is
available but not required for these sizes.

**Parameters:** ell = bits//4 unknown low bits of each nonce (high bits leaked).
bits = effective n.bit_length(); m = number of signatures.

### Recovery table (Monte Carlo, 10 trials per m, random curve + random d)

bits | ell (unknown) | m | recovered | notes
|---|---|---|---|---|
| 16 | 4 | 2 | 10/10 | information-theoretic minimum (V-004 MITM agrees) |
| 16 | 4 | 3 | 10/10 | |
| 16 | 4 | 4 | 10/10 | |
| 16 | 4 | 5 | 10/10 | |
| 16 | 4 | 6 | 10/10 | |
| 16 | 4 | 7 | 10/10 | |
| 16 | 4 | 8 | 10/10 | |
| 16 | 4 | 9 | 10/10 | |
| 16 | 4 | 10 | 10/10 | |
| 16 | 4 | 11 | 10/10 | |
| 16 | 4 | 12 | 10/10 | |
| 20 | 5 | 2 | 10/10 | |
| 20 | 5 | 3 | 10/10 | |
| 20 | 5 | 4 | 10/10 | |
| 20 | 5 | 5 | 10/10 | |
| 20 | 5 | 6 | 10/10 | |
| 20 | 5 | 7 | 10/10 | |
| 20 | 5 | 8 | 10/10 | |
| 20 | 5 | 9 | 10/10 | |
| 20 | 5 | 10 | 10/10 | |
| 20 | 5 | 11 | 10/10 | |
| 20 | 5 | 12 | 10/10 | |

**Threshold:** m = 1 never recovers (0/10 at both bit sizes); m = 2 is the
minimum for full recovery at both 16-bit and 20-bit (10/10). Within the
requested grid m = 4..12 recovery is 10/10 for every trial.

**Root cause of prior failure (G-002):** unscaled basis — first m rows
`n*I_m`, last row `beta_i`, target `t_i` — had determinant n^m (~2^100 at
20 bits) and the embedded target row was unscaled, so reduction smeared
the (e_i, -C) difference across dimensions; block-8/10 BKZ never
isolated it. Scaling by 2^(bits-ell+1) (and folding `+n` into the target row)
balances every coordinate of the short vector to ~2^bits, which is what
makes LLL alone sufficient.

### Code
- `ec_research/hnp_lattice.py` (runnable: `python3 ec_research/hnp_lattice.py`)
  exposes `hnp_attack(curve, n, sigs_with_meta, use_bkz=False)`.
## V-006b — HNP lattice recovery scaling (24–32 bits, Vector A H-007)

**Extends V-006.** Validation of the scaled HNP construction (`ec_research/hnp_lattice.py`, `hnp_attack(curve, n, sigs_with_meta, use_bkz=False)`) on larger targets. One GLV curve per target bit size (seed = bits*1000+7). For each trial a fresh random secret `d` is drawn and `m`-signature pools (up to 16) are generated via `make_instance` at ell = round(leak_frac * bits) unknown low nonce bits; prefixes of length `m` are reused, so each (trial, bits, leak) produces one attempt per `m`. Recovery is accepted only when `curve.mul(drec, G) == curve.mul(d, G)` in pure Python (independent of the lattice candidate filter). LLL wall-clock time per `hnp_attack` call is reported (median over trials). BKZ-12 was re-run on every failing m=2 case at leak=0.5 (20 cases) and recovered none — those failures are information-theoretic (m=2 gives only ~2*(bits-ell)=bits bits), not a lattice-strength limitation.

**Measured curve sizes:** target 24 -> n bit-length 22; target 28 -> 28; target 32 -> 31.

**Trial counts:** 12 at 24-bit, 10 at 28-bit, 8 at 32-bit (fewer at higher bits per H-007 spec).

**Aggregate:** 420 LLL attempts; 400 recoveries (20 expected failures, all m=2, leak=0.5).


### Recovery vs m at leak fraction = 0.25 (ell ≈ 0.25·bits unknown bits)

| target bits (n bits) | ell (unknown) | m | trials | recovered | median LLL time (ms) |
|---|---|---|---|---|---|
| 24 (22) | 6 | 2 | 12 | 12/12 | 0.075 |
| 24 (22) | 6 | 3 | 12 | 12/12 | 0.068 |
| 24 (22) | 6 | 4 | 12 | 12/12 | 0.083 |
| 24 (22) | 6 | 6 | 12 | 12/12 | 0.125 |
| 24 (22) | 6 | 8 | 12 | 12/12 | 0.169 |
| 24 (22) | 6 | 12 | 12 | 12/12 | 0.335 |
| 24 (22) | 6 | 16 | 12 | 12/12 | 0.669 |
| 28 (28) | 7 | 2 | 10 | 10/10 | 0.062 |
| 28 (28) | 7 | 3 | 10 | 10/10 | 0.071 |
| 28 (28) | 7 | 4 | 10 | 10/10 | 0.084 |
| 28 (28) | 7 | 6 | 10 | 10/10 | 0.128 |
| 28 (28) | 7 | 8 | 10 | 10/10 | 0.180 |
| 28 (28) | 7 | 12 | 10 | 10/10 | 0.354 |
| 28 (28) | 7 | 16 | 10 | 10/10 | 0.670 |
| 32 (31) | 8 | 2 | 8 | 8/8 | 0.077 |
| 32 (31) | 8 | 3 | 8 | 8/8 | 0.077 |
| 32 (31) | 8 | 4 | 8 | 8/8 | 0.094 |
| 32 (31) | 8 | 6 | 8 | 8/8 | 0.136 |
| 32 (31) | 8 | 8 | 8 | 8/8 | 0.208 |
| 32 (31) | 8 | 12 | 8 | 8/8 | 0.390 |
| 32 (31) | 8 | 16 | 8 | 8/8 | 0.795 |

### Recovery vs m at leak fraction = 0.5 (ell ≈ 0.5·bits unknown bits)

| target bits (n bits) | ell (unknown) | m | trials | recovered | median LLL time (ms) |
|---|---|---|---|---|---|
| 24 (22) | 12 | 2 | 12 | 1/12 | 0.057 |
| 24 (22) | 12 | 3 | 12 | 12/12 | 0.066 |
| 24 (22) | 12 | 4 | 12 | 12/12 | 0.079 |
| 24 (22) | 12 | 6 | 12 | 12/12 | 0.116 |
| 24 (22) | 12 | 8 | 12 | 12/12 | 0.168 |
| 24 (22) | 12 | 12 | 12 | 12/12 | 0.312 |
| 24 (22) | 12 | 16 | 12 | 12/12 | 0.602 |
| 28 (28) | 14 | 2 | 10 | 6/10 | 0.062 |
| 28 (28) | 14 | 3 | 10 | 10/10 | 0.070 |
| 28 (28) | 14 | 4 | 10 | 10/10 | 0.084 |
| 28 (28) | 14 | 6 | 10 | 10/10 | 0.126 |
| 28 (28) | 14 | 8 | 10 | 10/10 | 0.182 |
| 28 (28) | 14 | 12 | 10 | 10/10 | 0.343 |
| 28 (28) | 14 | 16 | 10 | 10/10 | 0.655 |
| 32 (31) | 16 | 2 | 8 | 3/8 | 0.097 |
| 32 (31) | 16 | 3 | 8 | 8/8 | 0.084 |
| 32 (31) | 16 | 4 | 8 | 8/8 | 0.096 |
| 32 (31) | 16 | 6 | 8 | 8/8 | 0.142 |
| 32 (31) | 16 | 8 | 8 | 8/8 | 0.207 |
| 32 (31) | 16 | 12 | 8 | 8/8 | 0.398 |
| 32 (31) | 16 | 16 | 8 | 8/8 | 0.770 |

**Minimum reliable `m` (all trials recover):**
- leak = 0.25: m = 2 at all bit sizes (12/12, 10/10, 8/8).
- leak = 0.5: m = 3 at all bit sizes; m = 2 recovers only 1/12 (24-bit), 6/10 (28-bit), 3/8 (32-bit), consistent with the m·(bits−ell) ≥ bits information bound.

**Cost scaling:** median LLL wall time grows ~linearly with `m` (dimension m+2): ~0.07 ms at m=2 to ~0.7–0.8 ms at m=16 across the tested sizes; absolute times are sub-millisecond because fpylll LLL on these dimensions is fast. No BKZ is needed for full recovery in the tested ranges (use_bkz=False).


### False verdicts reported
- 20 attempts at m=2, leak=0.5 (ell≈half the bits) returned a lattice candidate that failed the independent `d·G == Q` check (reason `wrong` in trial log). BKZ-12 did not recover any of them. These are excluded from the success counts above; they are the expected failures at the information-theoretic boundary, not silent false positives. Trial-level detail: `/tmp/opencode/hnp_trials.jsonl`.

### Code
- `ec_research/hnp_lattice.py` (`hnp_attack`, `make_instance`); experiment runner `/tmp/opencode/hnp_b.py`; aggregator `/tmp/opencode/agg.py`.


## V-008 — Vector B index-calculus feasibility (S2 naive) [feasibility, not speedup]
- Curve: 16-bit j=0 GLV curve (n≈13327, p≈40351).
- Factor base: points with x ∈ [0, B), sizes B=8..128.
- Relation P = P₁ + P₂ (both in FB) found by scanning P₁ ∈ FB and checking P-P₁ ∈ FB.
- Hit rates: B=8: 0/50, B=16: 0/50, B=32: 0/50, B=64: 4%, B=128: 22%.
- Estimated total cost for B=128: ~77,000 ops vs BSGS ~115 ops. Index calculus is ~670× slower at 16-bit.
- Conclusion: Naive S2 index calculus is infeasible at 16-bit (cost >> BSGS). Theoretical crossover (if any) would require n^(1/4) ≈ 11-point factor base, giving hit rates ~0.001% — impractical.
- Semaev S3 (prior subagent) gave ~0.3% hit rate at B=256, also far below BSGS efficiency.
- Vector B remains [QUEUED] for subexponential L_n(1/3) via S_m polynomial solving; naive scanning is falsified for small tiers.

## V-007 — Smart p-adic attack robust on CM (j=0, trace-1 anomalous) curves (H-009)

**Curve family:** `y^2 = x^3 + b` over F_p, p ≡ 1 (mod 3), `#E(F_p) = p`
(trace t = 1, anomalous), with CM by Q(sqrt(-3)) (`j = 0`).

**Root cause of earlier failure (G-009):** the fixed-Hensel horizontal lift
`x = x_0 (mod p^n)` leaves `p*lift(P)` in filtration E_2 for every tested
CM curve: `v_p(t(p*lift(P))) = 2`, so the normalised leading term
`phi(P) = t/p (mod p)` is 0 and uninvertible, and the formal-logarithm
homomorphism is lost.  Dividing by `p^2` instead returned unit residues but
failed `phi(2G) = 2*phi(G) (mod p)`.

**Resolution:** randomise the p-adic curve lift itself while keeping the mod-p
reduction `y^2 = x^3 + b`: take  
`a4_lift = p*alpha`, `a6_lift = b + p*beta (mod p^3)` with alpha,beta random
in `F_p`.  This is a *non-canonical* lift of the same reduced curve (the
equation variation suggested as a workaround for `lift_x` on CM curves), not a
canonical CM lift.  Standard Hensel y-lifting then gives `v_p(t(p*lift(P))) = 1`
and `phi(P) != 0 (mod p)` for every trial, restoring the homomorphism
`phi: E(F_p) -> F_p` and hence `d = phi(Q) * phi(G)^{-1} (mod p)`, verified
by `d*G == Q` and cross-checked with BSGS.

**Implementation:** `ec_research/smart_cm.py` (separate file; `ec_research/smart.py`
untouched): pure-Python Hensel root lift modulo `p^3`, two y-branches implicit
(`±ylift`), randomised `(alpha,beta)` search with `max_tries = 500`
empirically never needed beyond the first draw (0 `phi ≡ 0`, 0 val!=1, 0
exceptions across the run).

**Code-level recovery path:** `gen_cm_anomalous` -> `find_nondeg_lift`
(randomise alpha,beta, Hensel-lift point mod `p^3`, p-adic scalar
multiplication by p, extract t = -x/y, accept v = 1 and phi != 0) ->
`d_rec = phiQ * modinv(phiG, p) mod p` -> verify `ec_mul(d_rec, G) == Q`
-> BSGS baseline.

**Test set (exact):** CM anomalous `#E = p` curves generated deterministically
(seed `20261016`) for bit sizes 12-16, 2 trials per size (10 instances total):

| bits | trials | p range (actual) | phi(G) val | successes | smart wall time (ms) | BSGS wall time (ms) | gen time (s) |
|---|---|---|---|---|---|---|---|
| 12 | 2 | 2791-3571 | 1 (all) | 2/2 | 0.71-0.88 | 0.07-0.13 | 1.79-2.39 |
| 13 | 2 | 5419-7351 | 1 (all) | 2/2 | 0.84-0.90 | 0.17-0.19 | 3.51-12.97 |
| 14 | 2 | 13267 (x2) | 1 (all) | 2/2 | 0.88-1.46 | 0.20-0.23 | 11.99-28.00 |
| 15 | 2 | 25117 (x2) | 1 (all) | 2/2 | 0.81-0.87 | 0.25-0.33 | 16.13-45.66 |
| 16 | 2 | 42841-60919 | 1 (all) | 2/2 | 1.01-1.11 | 0.42-0.52 | 13.96-50.31 |

Aggregate: 10/10 Smart successes, 0 failures; BSGS cross-check 10/10;
`v_p(t_G) = v_p(t_Q) = 1` on all instances; 0 `phi(G) ≡ 0` draws; 0 lifts
in E_2.

**Scalings:** (1) lift recovery `O(log p)` p-adic point scalar multiplication
(cf. ~1 ms at 12-16 bits vs BSGS `O(sqrt(p))` ~0.1-0.5 ms at these tiny
sizes — BSGS is faster in wall clock below ~16 bits; Smart's asymptotic win
needs larger p, but phi is now invertible where the prior version crashed).
(2) Generation dominates: `O(p)` point counting per (p,b) candidate, hence
gen times grow roughly linearly in p (1.8 s at 12 bits to ~14-50 s at 16
bits) and are the practical bottleneck for larger tests, not the lifting.

**Results files:** `ec_research/smart_cm_results.txt`,
`ec_research/smart_cm_results.json` (full per-instance records incl. p, b,
d_true, d_rec, alpha, beta, vG, vQ, tries, timings).

**Honesty caveat:** No canonical CM lift was implemented; success comes from
non-canonical randomized curve-lift variations. Whether a uniformly random
alpha,beta keeps `v = 1` for all p (incl. very small or p with extra ramification)
was not proved; only tested on the 10 CM instances above. Zero-probability
bad draws (`phi ≡ 0`) predicted ~1/p and were not observed.

## V-008 — Smart scaling to larger anomalous curves (H-009)

Follow-up to V-007: extend CM and random anomalous bit sizes using
`ec_research/smart_scale.py` (reproducible runner) and save measured data
in `ec_research/smart_scale_results.txt`. Every instance verifies
`d_rec * G == Q` and is cross-checked by BSGS.

**CM (j=0, trace-1, `#E = p`) path (`smart_cm.py`, prec = 3, 1 trial each,
seed 20261016):**

| bits | p | phi v | Smart (ms) | BSGS (ms) | gen (s) | smart_ok | bsgs_ok |
|---|---|---|---|---|---|---|---|
| 12 | 3571 | 1 | 0.836 | 0.127 | 1.91 | Y | Y |
| 13 | 5419 | 1 | 0.872 | 0.129 | 2.86 | Y | Y |
| 14 | 13267 | 1 | 0.870 | 0.191 | 12.20 | Y | Y |
| 15 | 25117 | 1 | 0.816 | 0.273 | 12.55 | Y | Y |
| 16 | 60919 | 1 | 1.104 | 0.420 | 163.32 | Y | Y |
| 17 | 102121 | 1 | 1.094 | 0.746 | 39.51 | Y | Y |

Aggregate: 6/6 Smart successes, 6/6 BSGS cross-checks, `vG = vQ = 1` on all,
0 `phi ≡ 0`, 0 lifts in E_2 (first lift draw accepted in every case).

**Random (non-CM) anomalous path (`smart.py`, prec = 5, 1 trial each,
seed 20261016):**

| bits | p | valG | Smart (ms) | BSGS (ms) | gen (s) | smart_ok | bsgs_ok |
|---|---|---|---|---|---|---|---|
| 16 | 51949 | 1 | 1.519 | 0.366 | 4.59 | Y | Y |
| 17 | 129277 | 1 | 1.400 | 0.777 | 7.17 | Y | Y |
| 18 | 233327 | 1 | 1.551 | 0.984 | 151.73 | Y | Y |
| 19 | 429673 | 1 | 1.468 | 1.315 | 134.16 | Y | Y |

Aggregate: 4/4 Smart successes, 4/4 BSGS cross-checks, valuations 1 on all.

**Speed trend:** Smart wall time stays essentially flat (about 0.8-1.6 ms
across 12-19 bits), consistent with the polynomial p-adic lift path, while
BSGS grows with sqrt(p) (0.13 ms at 12 bits to 1.3 ms at 19 bits), with the
two essentially at parity around 19 bits. A prior H-009 measurement in this
repository (STATE.md) reports a 20-bit random instance at smart ~2.0 ms vs
BSGS ~2.6 ms, i.e. the crossover occurs between 19 and 20 bits. Generation
remains the practical bottleneck (O(p) point counting; 39-163 s at the larger
sizes above), not the p-adic attack.

**Root-cause note (CM):** No CM instance in this follow-up failed Smart
recovery and none exhibited `v ≠ 1` or `phi(G) ≡ 0 (mod p)`; all listed
draws accepted on the first non-degenerate lift. The earlier G-009 failure
(v = 2, phi == 0) is avoided specifically by the randomised curve lift as in
V-007.
