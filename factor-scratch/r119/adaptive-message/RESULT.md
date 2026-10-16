# RESULT — adaptive / chosen-message nonces: `t* = D+2` still, and adaptivity buys nothing

Round 119, `factor-scratch/r119/adaptive-message/`.
**Status: SUPPORTED.** The strongest threat model in this family — the attacker
*chooses* the messages, hence the signals, and may choose them *adaptively*
(sign, observe `(r_i,s_i)`, then pick the next hash) — does **not** reduce the
signature threshold. `t* = D + 2` exactly, with `D+2` distinct messages, one
linear solve, no elliptic-curve work. Additionally this round found and fixed a
**model defect in the base measurement** (r118's rank law is only correct for a
signer that re-randomizes `r` per signature; see §5).

## The claim under test

```
k_i = Σ_{j=1..D} a_j z_i^(j+1) + Δ      (a_j, Δ, d secret; z_i = H(m_i))
row_i = [ s_i z_i^2, …, s_i z_i^(D+1), s_i, −r_i ],   row_i · (a_1..a_D, Δ, d)^T = z_i
```

Hypothesis: an attacker who controls the messages controls the signals and can
therefore *design* the system — in particular push the requirement below the
passive `D+2`.

**Verdict: refuted as an improvement, confirmed as a non-improvement.** Choosing
messages changes *which* equations are available, never *how many*:

> `rank ≤ min(t, m)` where `t` = signatures collected, `m` = distinct messages,
> so `rank = D+2` needs `t ≥ D+2` queries **and** `m ≥ D+2` distinct messages.
> One signing query yields exactly one equation, so an adaptive attacker cannot
> get there faster — the best any strategy measured is exactly `D+2` queries.

## Reproduce

```
cd /home/raver1975/lean/factor-scratch/r119/adaptive-message
/home/raver1975/sage_mamba/envs/sage/bin/sage attack_adaptive.sage    # Parts A–G
/home/raver1975/sage_mamba/envs/sage/bin/sage two_sig_infotheory.sage # (P2) exact accounting
/home/raver1975/sage_mamba/envs/sage/bin/sage toycurve.sage           # exhaustive coset enumeration
/home/raver1975/sage_mamba/envs/sage/bin/sage extra_controls.sage     # (C1)(C2)(C3)
```
All seeds are fixed; all outputs are in `run_*.log`. 12 trials per cell
throughout (≥12 as required). Success is **`d·G == Q` on real secp256k1**,
never membership in a coset; the secret constants `(a_j, Δ)` are recovered and
checked too.

Two signer models are run everywhere, because it turns out to matter (§5):
`sim` = r118's simulation (fresh random `r` per signature) and `faithful` =
real ECDSA (`r = x(k·G) mod n`, so the whole signature is a function of the
hash). The `sim` column reproduces r118 exactly; `faithful` is the physical one.

## (P1) Chosen messages: attack still works — SUPPORTED (as a non-improvement)

| model | D | chosen messages | `d·G==Q` | rank |
|---|---|---|---|---|
| sim | 1 | t=2 {1,2} | 0/12 | 2 |
| sim | 1 | t=3 {1,2,3}, {0,1,n−1}, {0,2^64,2^128} | **12/12** each | 3 |
| sim | 2 | t=3 {1,2,3} | 0/12 | 3 |
| sim | 2 | t=4 {1,2,3,4}, {0,1,n−1,2^64} | **12/12** each | 4 |
| sim | 3 | t=4 {1,2,3,4} | 0/12 | 4 |
| sim | 3 | t=5 {1,…,5}, {0,1,n−1,2^64,2^128} | **12/12** each | 5 |
| faithful | 1,2,3 | same sets | identical | identical |

Adversarially structured message sets (containing `0`, `n−1`, `2^64`, `2^128`)
behave exactly like random ones. **`D+2` chosen-message signatures break the key.**

## (P2) Can an adaptive attacker do it in 2 signatures? — NO, and it is not close

Three independent measurements, because this is the claim that must not be
merely asserted.

**(a) The adaptive attacker, in practice.** For D=1, seven strategies choose
`z_1`, sign, observe `(r_1,s_1)`, choose `z_2`, … and stop the instant
`rank = D+2`; 12 trials each, both models:

| strategy | recovered | queries used | rank if stuck |
|---|---|---|---|
| fresh-random | 12/12 | **always 3** | – |
| zero-first (`z_1=0`) | 12/12 | **always 3** | – |
| sequential `0,1,2,…` | 12/12 | **always 3** | – |
| structured `{0,1,n−1,2^64,2^128,…}` | 12/12 | **always 3** | – |
| chase `z_{i+1} = z_i + r_i` (aims at `s=0`) | 12/12 | **always 3** | – |
| chase2 `z_{i+1} = z_i s_i / r_i` (aims at row proportionality) | 12/12 | **always 3** | – |
| repeat the same message | 0/12 | never (budget 8) | 2 (sim) / **1** (faithful) |

D=2 → always 4 queries, D=3 → always 5 queries, all 12/12, both models. No
strategy ever finished in fewer than `D+2` queries, in 12 × 7 × 3 trials.

**(b) Exact counting on secp256k1** (`two_sig_infotheory.sage`). With 2
signatures and D=1 the system is 2 equations in 3 unknowns, so the solution set
is a 1-dimensional affine coset of `n` elements. Measured over 48 cells
(12 trials × 4 schedules, including `z_1 = 0` and an `z_2` computed from the
observed `(r_1,s_1)`):

```
kernel 1-dim with unit d-coordinate  : 48/48   => coset = n points and
   t -> d(t) is a bijection of Z_n:   exactly n candidate KEYS, one true
true (a,Delta,d) inside the coset    : 48/48   (harness consistency)
uniform coset samples with d*G==Q    : 0/9600  (expected ~9600/n = 0)
naive solve_right on 2 rows recovers : 0/48
```

Same at `t = D+1` for D=2,3: 12/12 cells each have rank `D+1`, 1-dim kernel,
unit key-coordinate, true key inside the coset, 0/600 wrong samples. The bound
is `n^(D+2−t)` and no choice of messages moves it.

**(c) Exhaustive enumeration on a 21-bit toy curve** (`toycurve.sage`,
`N = 1050337`, prime, `p < N` so "same `r`" is unambiguous). The *entire*
coset was walked, element by element, 9 times (3 trials × 3 schedules,
including an adaptive `z_2`). Every scan reported identically:

```
coset size 1050337 | #with d*G==Q = 1 | #passing r-check of sig 1 = 2
                   | #passing BOTH r-checks = 1        (scan: ~28–34 s each)
```

The harness is validated on the same curve: `D=1, t=2 → 0/12`, `t=3 → 12/12`;
`D=2, t=3 → 0/12`, `t=4 → 12/12`.

**The one subtlety, resolved honestly.** A real signature also obeys
`r_i = x(k_i·G)` with `k_i = a z_i + Δ`; inside the coset `k_i(t)` is *affine*
in `t`, so this constraint does reduce `n` candidates to ~1 (exactly the "1"
above). But *using* it means inverting `x(·)`, i.e. a discrete log. Measured on
the toy curve: scanning the coset costs `n` EC additions (~29 s); taking the two
dlogs costs `2√n ≈ 2·1025` steps (0.052 s) — which is **the same problem that
protects the public key**: `dlog(Q)` alone takes 0.024 s and is the standard
attack. So the residual ambiguity after `D+1` signatures is not "almost
broken", it *is* ECDLP. Cost table (toy curve):

| route | cost | recovers key? |
|---|---|---|
| honest `D+2` linear solve | solve = 0 EC ops, 0.4 ms incl. making the 3 signatures | yes, always |
| 2 signatures + coset scan | `n` additions (~29 s) | yes (1 of n found) |
| 2 signatures + 2 dlogs | `2√n` (0.052 s) | yes |
| just `dlog(Q)` | `√n` (0.024 s) | yes |

The last two rows are the same attack. The gap between the honest solve and the
2-signature route is `~130×` on a 21-bit group and grows as `n/√n` (≈1025 here,
≈2^128 for secp256k1): the ranking never reverses.

**Conclusion for (P2): the 2-signature attack is information-theoretically
impossible by counting (n candidate keys) and its only known escape is an ECDLP
of the same size as the one that already protects the key.** Not a harness
artifact: the toy-curve enumeration is exhaustive and was cross-checked three
ways.

## (P3) `z_i = 0` — SUPPORTED: a wasted query, not a shortcut

`z=0` zeroes the entire signal block of the row, and (D=1) `k = Δ` for *every*
such message, so `(r,s)` are byte-identical and `s/r = d/Δ` is constant: **all**
`z=0` rows are multiples of `[0,1,−Δ/d]` and together contribute exactly one
rank unit, no matter how many are collected.

| model | D | schedule | t | m | `d·G==Q` | rank |
|---|---|---|---|---|---|---|
| faithful | 1 | 0,5 | 2 | 2 | 0/12 | 2 |
| faithful | 1 | 0,0,5 | 3 | 2 | 0/12 | 2 |
| faithful | 1 | 0,5,7 | 3 | 3 | **12/12** | 3 |
| faithful | 1 | 0,0,0,5 | 4 | 2 | 0/12 | 2 |
| faithful | 1 | 0,5,5 | 3 | 2 | 0/12 | 2 |
| faithful | 1 | 0×5 | 5 | 1 | 0/12 | 1 |
| faithful | 2 | 0,0,1,2 | 4 | 3 | 0/12 | 3 |
| faithful | 2 | 0,1,2,3 | 4 | 4 | **12/12** | 4 |
| faithful | 3 | 0,1,2,3,4 | 5 | 5 | **12/12** | 5 |
| sim | 1 | 0,5,7 | 3 | 3 | 12/12 | 3 |
| sim | 1 | 0,0,5 | 3 | 2 | 0/12 | 2 |

A *mixed* strategy helps only insofar as it supplies distinct messages: one
`z=0` signature is a perfectly usable row (it pins `d/Δ`), a second is free of
information. Note also that in a real signer `z = H(m)`, so landing on `z=0` is
a preimage (`~n/2` hashes) — measured: 20000 random messages give 20000
distinct, uniform hashes (χ² = 244.2 vs 255 ± 22.6).

## (P4) D=2,3 — SUPPORTED: adaptive threshold = passive threshold = D+2

Adaptive runs (both models, all strategies): D=2 → 12/12 in exactly 4 queries;
D=3 → 12/12 in exactly 5 queries. Same as passive (Part A) and same as chosen
in advance (Part B).

## Negative control — CONFIRMED

Attacker makes all messages equal: D=1 (`t=4`), D=2 (`t=5`), D=3 (`t=6`) →
**0/12 recovered**, rank 2 (sim) / 1 (faithful). The failure is a *detectable*
rank drop, not a silent one: the attacker computes the rank before solving.

## 5. Bonus finding: r118's rank law is model-dependent (correction)

r118 reported `rank = (#distinct messages) + 1` and concluded "3 signatures on
2 distinct messages" suffice for D=1. That holds **only** because their harness
drew `r` freshly at random for every signature. In real ECDSA `r = x(k·G)`, and
when the nonce is a function of the message hash the *entire* signature is a
function of the hash: repeated messages give **byte-identical** signatures
(measured 10/10). Measured rank laws, `t = D+2`:

```
sim      : rank = min(t, m+1)     (reproduces r118 exactly; m = D+1 suffices)
faithful : rank = min(t, m)       (m = D+2 distinct messages required)
```

Both give the same *signature* threshold `t* = D+2` — the quantity this round is
about — but the faithful law is the tighter and physically correct one, and the
r118 statement "m ≥ D+1" is not. Two further controls support the faithful
picture: (C1) `z ↦ k(z)` is a bijection (512 distinct messages → 512 distinct
nonces, 0 collisions, for D=1,2,3), so chosen messages can never manufacture the
nonce reuse that actually breaks ECDSA; and (C3) the deterministic consequence
shows up at `z=0`, where `k = Δ` and every such signature is a multiple of one
fixed row direction — impossible if `r` were re-randomized per signature.

**Campaign implication:** any result that signs a *deterministic-function-of-
message* nonce while drawing `r` at random inherits this defect; the fix is one
line (`r = x(k·G) mod n`) and it only ever *weakens* the attack, never
strengthens it. r118's threshold `t* = D+2` survives; its distinctness bound
does not.

## Falsifier

This result is wrong if any of the following is produced:
1. an adaptive schedule that recovers `d` (verified `d·G == Q`) from fewer than
   `D+2` signatures, for any D, in either signer model;
2. a 2-signature (D=1) method whose cost is below the ECDLP cost `√n` — e.g. a
   way to exploit the `r = x(k·G)` constraint without a discrete log;
3. a chosen-message set at `t = D+2` where the matrix is singular more often
   than `O(1/n)` (the determinant is
   `s_1 s_2 r_3 (z_2−z_1) + s_2 s_3 r_1 (z_3−z_2) + s_3 s_1 r_2 (z_1−z_3)`,
   which depends on `s_3, r_3` — not known when `z_3` is chosen; measured
   `det ≠ 0` in 12/12 trials).

## Verdict

**SUPPORTED.** The adaptive/chosen-message threat model is strictly stronger
for the attacker than the passive one and it changes nothing: `t* = D+2`
signatures on `D+2` distinct messages, by one linear solve, with no EC work.
The reason is structural and exact — one signing query produces one equation —
so the attacker can select which equations to collect but cannot collect more
of them. The single genuine improvement this round found is in the *base
result*, not the attack: r118's `m ≥ D+1` distinctness requirement should be
`m ≥ D+2` for a faithful ECDSA signer.
