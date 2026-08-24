# Computational evidence — NET-76 domain-factor round

All numbers below were produced with a short Lean script (`Float` arithmetic) that
implements exactly the definitions used in the formal files:
`headMass`, `retained`, `kstar` (`AttentionBudget`), `dilate`, `contract`
(`Catalog.Probability.NET76DomainDilation`, `…RationalDilation`).
They are *exploratory* evidence gathered before the proofs; every claim that
appears in the `.lean` files is proved there, not asserted from these tables.

Profiles used: Zipf `w i = (i+1)^(-1.2)` and geometric `w i = 0.8^i`; gate `τ = 0.98`
(the gate of the reported experiment).

## 1. The dilation window `(c·(k*−1), c·k*]`

| base profile | base ctx `n` | base knee `k*` | `c` | dilated ctx | dilated knee | window |
|---|---|---|---|---|---|---|
| Zipf 1.2 | 512  | 387 | 2 | 1024 | **773** | (772, 774] |
| Zipf 1.2 | 512  | 387 | 3 | 1536 | **1159** | (1158, 1161] |
| Zipf 1.2 | 1024 | 732 | 2 | 2048 | **1464** | (1462, 1464] |
| geo 0.8  | 512  | 18  | 2 | 1024 | **36**  | (34, 36] |
| geo 0.8  | 512  | 18  | 4 | 2048 | **71**  | (68, 72] |

Every measurement lands inside the window, and three of the five land *strictly*
below the multiplicative prediction `c·k*`.  So the multiplicative law is a genuine
one-sided bound, not an identity — which is what `kstar_dilate_lt_mul_example` proves
(with an exact rational witness) and what `dilation_relative_error` quantifies.

## 2. The exact ceiling law for key merging

`k*(contract q w, n)` versus `⌈k*(w, q·n) / q⌉`, Zipf 1.2, τ = 0.98:

| `q` | `n` | measured | predicted `⌈k*/q⌉` | agree |
|---|---|---|---|---|
| 4 | 128 | 97  | 97  | ✓ |
| 5 | 100 | 76  | 76  | ✓ |
| 3 | 200 | 150 | 150 | ✓ |

Exact agreement in every case — merging is the one operation with a closed-form knee.
Formalised and proved as `kstar_contract_eq`.

## 3. A rational factor 5/4

Zipf 1.2, `n = 128`, base knee at merged context `4·128 = 512` is 387, so
`t = ⌈387/4⌉ = 97` and the predicted window is `(5·96, 5·97] = (480, 485]`.
Measured knee of `dilate 5 (contract 4 w)` at context `5·128`: **483** ∈ (480, 485] ✓.

## 4. Cross-ratio audit of the reported five-domain table

A single factor `c` with `k*@512 = 16c` and `k*@1024 = 20c` exists **iff**
`k*@512 · 20 = k*@1024 · 16`.

| domain | (k*@512, k*@1024) | `k*@512·20` | `k*@1024·16` | multiplicative? |
|---|---|---|---|---|
| code     | (12, 12) | 240 | 192 | **no** |
| prose-EN | (16, 20) | 320 | 320 | yes (c = 1) |
| math     | (16, 20) | 320 | 320 | yes (c = 1) |
| prose-DE | (20, 24) | 400 | 384 | **no** |
| prose-FR | (32, 40) | 640 | 640 | yes (c = 2) |

Two of the five rows fail.  This computation is the seed of the formal results
`code_no_factor`, `de_no_factor`, `net76_verdict_refuted` and
`net76_multiplicative_classification`.

## 5. Counterexample hunt

Searching small `(p, q)` for a rational factor reproducing the *flat* code row from a
base `{16, 20}` (i.e. equal knees at both contexts): the windows
`(p(⌈16/q⌉−1), p⌈16/q⌉]` and `(p(⌈20/q⌉−1), p⌈20/q⌉]` are disjoint for
`q = 1, 2, 3, 4` (ceilings `16<20`, `8<10`, `6<7`, `4<5`) and first overlap at `q = 5`
(ceilings `4 = 4`), where `p = 3` gives the window `(9, 12] ∋ 12` at both contexts.
Formalised as `equal_knees_forces_coarse_merging` (impossibility for `q ≤ 4`, proved
for all profiles/contexts/gates) and `code_row_rational_window` (the `q = 5, p = 3`
consistency statement).

No OEIS sequence is involved: the objects here are knee windows, not integer
sequences.

## 6. Cycle 3 — the token-matched arithmetic

Every row of the reported table is measured at the *same* token count (512, then
1024), so the mechanism must be evaluated with the base curve read at the reported
context, not at the dilated one.  Reading the English `+4` law backwards gives the
chain `k*@256 = 12`, `k*@512 = 16`, `k*@1024 = 20`, `k*@2048 = 24`.

| quantity | naive factor prediction | mechanism, token-matched | source |
|---|---|---|---|
| two-fold dilation, ctx 512 | `2·16 = 32` | window `(2·11, 2·12] = (22, 24]` | `french_row_token_matched_refuted` |
| implied French factor | `2.0` | `(11/8, 3/2]` | `french_token_matched_factor_bound` |
| pair merging, ctx 512 | `16/2 = 8` | exactly `⌈20/2⌉ = 10` | `code_row_token_matched_exact` |
| pair merging, ctx 1024 | `20/2 = 10` | exactly `⌈24/2⌉ = 12` | `code_row_flatness_refuted` |
| merged doubling increment | `+0` (reported) | `+2` | `code_row_flatness_refuted` |

The dilation entries are windows because the dilation knee law is a window; the
merging entries are exact because `kstar_contract_eq` is an identity.  Every number in
the table above appears as the conclusion of a proved theorem in
`Catalog/Probability/NET76TokenMatched.lean`; the measured values enter only as
hypotheses.

Sanity check of the reconciliation law `token_matched_window` on these numbers: the gap
between the naive prediction `c·k*(w, c·n)` and the true window is `c·D = 2·4 = 8`,
and `32 − 8 = 24`, the upper end of the measured window — as the theorem asserts.

## 7. Cycle 4 — the flatness certificate and its witness

The cycle-3 criterion ("a token-matched factor exists iff the base knee is flat across
the ratio") needs a decision procedure.  For a profile with geometric decay ratio `r`
and gate `τ`, the tail beyond a budget `k` is at most `r^k/(1−r)`, so the certificate
is the single inequality `r^k*/(1−r) ≤ 1−τ`.

Explicit dyadic witness used to show the audited hypotheses are consistent
(`w i = 2^{-i}`, gate `τ = (2^32 − 5000)/(2^32 − 1) ≈ 1 − 1.164·10^{-6}`):

| context `n` | budget `k` | retained mass (exact) | verdict |
|---|---|---|---|
| 16 | 15 | `(2^16 − 2)/(2^16 − 1) ≈ 1 − 1.526·10^{-5}` | fail |
| 16 | 16 | `1` | pass ⇒ `k*(16) = 16` |
| 32 | 19 | `(2^32 − 2^13)/(2^32 − 1) ≈ 1 − 1.907·10^{-6}` | fail |
| 32 | 20 | `(2^32 − 2^12)/(2^32 − 1) ≈ 1 − 9.537·10^{-7}` | pass ⇒ `k*(32) = 20` |

So a geometric profile can reproduce the reported English pair `(16, 20)` across a
doubling; the certificate then necessarily fails at that context, which is exactly the
content of `net76_english_row_has_no_certificate`.  Both knee values are proved in
Lean (`rising_geometric_witness`) by the razor bracket, with the four retained masses
evaluated in exact rational arithmetic — no floating point enters the proof.

## 8. Cycle 5 — the limit knee and the stabilisation locus

Write `S = ∑' i, w i` for the total mass of the profile and `ε = 1 − τ` for the gate
slack.  The **limit knee** is the least `k` with `τ·S ≤ headMass w k`; it is a property
of the profile alone.  For the dyadic witness (`w i = 2^{-i}`, so `S = 2` and
`headMass w k = 2 − 2^{1−k}`, gate `τ = (2^32 − 5000)/(2^32 − 1)`, `ε = 4999/(2^32 − 1)
≈ 1.16393·10^{-6}`) the membership condition `τ·2 ≤ 2 − 2^{1−k}` reduces to the clean
inequality `2^{−k} ≤ ε`:

| `k` | `2^{−k}` | `2^{−k} ≤ ε ≈ 1.16393·10^{-6}` |
|---|---|---|
| 18 | `3.8147·10^{-6}` | no |
| 19 | `1.9073·10^{-6}` | no |
| **20** | `9.5367·10^{-7}` | **yes** |
| 21 | `4.7684·10^{-7}` | yes |

so `kinf = 20` — proved exactly in Lean as `kinf_wGeo`.  The reported `20` at the longer
context is therefore the asymptotic budget, while the reported `16` at the shorter one
is a pre-asymptotic under-report, as `kstar_le_kinf` requires in general.

Locating the freezing context.  The sufficient criterion is
`headMass w (kinf − 1) < τ·headMass w m`, i.e. here `2 − 2^{−18} < τ·(2 − 2^{1−m})`:

| `m` | `τ·(2 − 2^{1−m}) − (2 − 2^{−18})` | criterion |
|---|---|---|
| 19 | `≈ −2.33·10^{-6}` | fails |
| 20 | `≈ −4.21·10^{-7}` | fails |
| **21** | `≈ +5.33·10^{-7}` | **fires** |
| 22 | `≈ +1.01·10^{-6}` | fires |

and the criterion is *tight* on this witness: at context `20` the knee is genuinely
still at most `19`, because `retained w 20 19 = (2 − 2^{−18})/(2 − 2^{−19}) ≈ 1 −
9.537·10^{-7} ≥ τ`.  Both halves are proved (`wGeo_stabilises`, `wGeo_locus_exact`), so
the stabilisation locus of the witness is exactly `21`.

Exploratory (not formalised): the closed-form uniform budget of the earlier catalog
theory evaluates on this witness to `geometricBudget (1/2) τ =
⌈log((1−τ)/2)/log(1/2)⌉ = ⌈20.71⌉ = 21`, coinciding with the exact locus.  This numeric
coincidence is the motivation for Direction 2 in `FUTURE_DIRECTIONS.md`; it is a
floating-point observation only, and nothing in the Lean files depends on it.
