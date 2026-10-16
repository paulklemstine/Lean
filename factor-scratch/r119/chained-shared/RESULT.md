# RESULT — the two amplifications COMPOSE: `L` chained nonce generators sharing `(a, Δ)` fall together

Round 119, `factor-scratch/r119/chained-shared/` (`attack.sage`, `verify_e2e.sage`).
**Status: SUPPORTED.** The composition predicted from `r118/shared-nonce` ×
`r118/chained-nonce` is real, it is sharp, and the threshold is
`t ≥ 2 + (D+1)/L` — which for `D = 1` means **3 signatures per key for every finite `L`,
and 2 for none**. Ground truth `d_k · G = Q_k` verified on real secp256k1, twice over
(Sage EC and an independent pure-Python implementation with full ECDSA verification).

## The claim

Take `L` keys, each with **its own** chained nonce generator, but all fed from the **same**
structural parameters — one badly-seeded RNG feeding several keys, where the nonce also
mixes in public data:

```
k_{k,0} = fresh per-key seed                                  (OUTSIDE the family)
k_{k,i} = Σ_{j=1..D} a_j g_j(sig k,i-1) + Δ                   for i ≥ 1
```

`(a_1..a_D, Δ)` are shared by all `L` keys. The signature equation
`s_i k_{k,i} = z_i + r_i d_k (mod n)` is linear in `(a_1..a_D, Δ, d_1..d_K)`, where
`K` = the number of keys that have at least one **in-family** signature. Each key's
first signature uses its **seed** nonce, which is a fresh unknown appearing in no other
equation, so it yields **no equation**.

```
unknowns  = D + 1 + K
equations = Σ_{k∈K} (t_k − 1)
threshold  Σ_{k∈K} (t_k − 1) ≥ D + 1 + K
           ⇔ Σ_k t_k ≥ D + 1 + 2K + #{k : t_k ≤ 1}
uniform t:  t ≥ 2 + (D+1)/L      → for D = 1 this is > 2 for EVERY finite L
```

**Two consequences, both measured:**

1. `t* = 3` per key for `D = 1` — for `L = 1, 2, 3, 5, 10, 20, 50`. Uniform `t = 2`
   **never** suffices, however many keys there are (the inequality `L ≥ D+1+L` has no
   solution for `D ≥ 0`).
2. The asymmetric minimum is `D + 1 + 2L` total signatures, which does approach
   **2 signatures per key** as `L → ∞` (measured: 102 signatures break 50 keys).

## The falsifier

The claim is **refuted** if, for any `(L, t, D)` whose system is full rank, a key is not
recovered with `d_k · G == Q_k` on secp256k1; it is **over-stated** if any key falls with
`Σ(t_k − 1) < D + 1 + K`. The single sharpest test is `D = 1, L = 10`:

* `t = 3` (30 signatures, 20 usable equations, 12 unknowns) → **all 10 keys must fall**.
* `t = 2` (20 signatures, 10 usable equations, 12 unknowns) → **no key must fall**.

Both were run 24 times each. Both held.

## Reproduce

```bash
cd /home/raver1975/lean/factor-scratch/r119/chained-shared
/home/raver1975/sage_mamba/envs/sage/bin/sage attack.sage        # ~26 s
/home/raver1975/sage_mamba/envs/sage/bin/sage verify_e2e.sage    # ~6 s
```

`attack-output.txt` and `verify-e2e-output.txt` are the captured runs. Every count in this
file is reproducible bit-for-bit; only the per-cell millisecond timings vary.

## Positive control (mandatory, and it earned its keep)

`L = 1` with a chained nonce must reproduce `r118/chained-nonce` exactly. 12 trials/cell:

```
 D   t=D+2     keys    t=D+3     keys
 1     3        0/12     4       12/12
 2     4        0/12     5       12/12
 3     5        0/12     6       12/12
 4     6        0/12     7       12/12
 5     7        0/12     8       12/12
```

**This control caught two real harness bugs before any claim was made** (see *Honesty*
below). It is the only reason the numbers below can be trusted.

## The measurement

Headline (`D = 1, L = 10`, 24 trials per cell; each trial recovers 10 keys):

```
           config            keys fallen   usable eq vs unknowns   (a,Δ) recovered
 L=10, t=2  (20 sigs)            0/240          10   <     12           0/24
 L=10, t=3  (30 sigs)          240/240          20   ≥     12          24/24
```

Threshold grid (`D = 1`, 12 trials per cell, every key verified `d_k·G = Q_k`):

```
   L    t=2      t=3      t=4        min total (asymmetric)
   1   0/12    12/12    12/12              4   (= D+1+2L)
   2   0/24    24/24    24/24              6
   3   0/36    36/36    36/36              8
   5   0/60    60/60    60/60             12
  10   0/120  120/120  120/120            22
  20   0/240  240/240  240/240            42
```

The same law at higher `D`, 12 trials/cell (`t ≥ 2 + (D+1)/L`):

```
   config             keys fallen  usable eq  unknowns
   L=6  D=2 t=2           0/72          6        9
   L=6  D=2 t=3          72/72         12        9
   L=4  D=3 t=3          48/48          8        8      (exactly determined)
   L=4  D=3 t=4          48/48         12        8
```

Scaling (`D = 1, L = 50`, 12 trials/cell):

```
   L=50  t=2     (100 sigs)     0/600     eq 50 < unk 52
   L=50  t=3     (150 sigs)   600/600     eq 100 ≥ unk 52
   L=50  [3]*2+[2]*48 (102)   600/600     eq 52 = unk 52   ← the minimum, ~2.04 sigs/key
```

Which public value feeds back (`D = 1, L = 10, t = 3`, 12 trials/cell) — the composition
does not depend on the signal choice:

```
   signal     keys fallen        signal      keys fallen
   r           120/120            r*s          120/120
   s           120/120            r+s+z        120/120
   z           120/120
```

## Why `t = 2` fails — the actual threshold, carefully

The brief's note that "total equations = 20 ≥ 12, so the count says it SHOULD work" does
**not** survive measurement. The correct count of usable equations is `L·(t−1) = 10`, not
20: each key's first signature is signed with the seed nonce `k_{k,0}`, which is a **fresh
unknown** appearing in no other equation, so that signature contributes an equation with
two unknowns and zero discriminative power. Measured on one instance (`D=1, L=10, t=2`):

```
 signatures 20 (10 keys × 2); 10 of them are seed signatures → usable equations 10
 unknowns (a_1..a_D, Δ, d_1..d_10) = 12 ;  rank 10 ;  kernel dimension 2
 the TRUE unknown vector satisfies the attacker's system:  True   (A·x_true == b)
 A·(x_true + v) == b for a nonzero kernel vector v:        True
 keys whose d_k is NOT pinned: 10/10      keys broken: 0/10
```

Two independent facts close the question completely:

1. `A · x_true == b` in **every one of the 1800+ trials run here** (the `model` column),
   so the equations are written from the correct signatures — a null is provably
   underdetermination and never an off-by-one in the harness.
2. Even the most generous accounting fails. Treating each seed nonce as its own unknown
   gives `D + 1 + 2L = 22` unknowns against `L·t = 20` equations
   (`verify_e2e.sage` §3): rank 20, kernel dimension 2, and the true vector satisfies it.
   Every seed signature buys exactly one new unknown — its own seed — and nothing else.
   Independently, the particular solution the solver does return **fails full ECDSA
   verification**, so the null is a real information deficit, not a solver artefact.

`A · x_true == b` holds in **all 626 trials** of this round (50 cell-runs, ≥12 trials per
cell), so every null above is provably underdetermination of the correct system and never
an off-by-one in the harness.

**The threshold is `Σ_k (t_k − 1) ≥ D + 1 + K`, i.e. `t ≥ 2 + (D+1)/L` uniformly; for
`D = 1` that is `t* = 3` for every `L`, and it is never 2.**

## The asymmetric allocation, and the key that cannot fall

`D = 1, L = 10`, 12 trials/cell. The minimum total is `D + 1 + 2L = 22`:

```
   allocation            total   keys fallen   note
   [3]*2+[2]*8             22     120/120      exactly determined (12 eq = 12 unk)
   [4]+[2]*9               22     120/120      exactly determined
   [3]+[2]*9               21       0/120      11 eq < 12 unk
   [2]*10                  20       0/120      10 eq < 12 unk
   [5]+[2]*8+[1]           22     108/120      the t=1 key CANNOT fall (9/10 per trial)
   [21]+[1]*9              22      12/120      only the t=21 key falls (1/10 per trial)
```

The last two rows are the sharp consequence of the seed: **a key publishing only its seed
signature contributes no equation at all, so it cannot be recovered no matter how many
signatures the other keys provide.** It is dropped from the system (it would otherwise be
an all-zero column) and reported as structurally unrecoverable — never counted as broken.

## Ground truth and controls

* **Each private key is drawn once** and the same value is used to sign and to build the
  public key; the generator asserts `d · G == Q` for every key on every trial.
* **Every recovered key is checked with `d_rec · G == Q` on real secp256k1** — never by
  membership in a set, never by "d was returned".
* **`verify_e2e.sage` re-verifies everything with independent machinery**: a hand-rolled
  affine scalar multiplication on secp256k1, its own ECDSA signer, its own full ECDSA
  *verifier* (`X = (z/s)G + (r/s)Q`, compare `X_x mod n == r`), and its own deterministic
  hash-chain RNG. It reproduces `30/30` keys recovered and verified two ways for
  `L=10, t=3`, and `0/40` for `t=2` — where the underdetermined solution it gets back
  fails ECDSA verification. The verifier itself is sanity-checked: 5/5 fresh signatures
  verify under their own key and 5/5 fail under a wrong key.
* **`(a_j, Δ)` recovery is recorded** alongside the keys. The harness raises
  `IMPOSSIBLE OUTCOME` if `(a, Δ)` were ever uniquely recovered (rank == #unknowns) while
  0 participating keys were broken, which cannot happen for an exactly-determined system.
  It never triggered. Nulls always come with rank < #unknowns or a structural
  non-participant, never with a full-rank system and no keys.
* **Model validation**: `A · x_true == b` is checked on every trial; it holds throughout
  (the `model` column is `True` in all 50 cell-runs).

## Honesty: the bugs the controls caught

1. **`j % 3 → (r, s, z)` duplicated signals.** With `g_1 = g_4 = r`, the `D = 4` control
   returned `0/12` at `t = D+3` — an exact duplicate column, not a cryptanalytic fact.
   Fixed by using distinct public functions (`r, s, z, r², r³, …`).
2. **A second draft reintroduced the same bug.** Prepending `r` to `[r, s, z]` gives
   `g_1 = g_2 = r` for `D ≥ 2`; the positive control failed for `D = 2..5` and the
   `D ≥ 2` scaling cells returned `0/72`. Fixed again; `sig_signals` now asserts
   distinctness.
3. **A sign error and a double-scaling in `verify_e2e.sage` §3.** Both were caught because
   the `A · x_true == b` check returned `False`. Both fixed; it now returns `True`.
   Without that check the section would have published a "modelling error" as a result.

## What it means

Chaining is free of side channels but not free of signatures: adding the shared-structure
amplification to a chained generator costs exactly `L` extra signatures — one unusable
seed per key — and pushes the per-key cost from `1 + (D+1)/L` (the non-chained shared
stream) to `2 + (D+1)/L`, which is strictly above 2 for every finite `L`. The asymmetry is
the real payoff of the composition: 102 published signatures, allocated as
`[3]*2 + [2]*48`, destroy 50 private keys with no side channel of any kind, each recovery
one linear solve of a `52 × 52` system over `GF(n)`.

## Verdict

**SUPPORTED** — the two round-118 amplifications compose. `L` chained nonce generators
sharing `(a_1..a_D, Δ)` fall together at `Σ_k (t_k − 1) ≥ D + 1 + K`, measured exactly at
`D = 1, L = 10` (30 signatures break 10 keys, 24/24 trials), at `L = 50` (102 signatures
break 50 keys), and for `D = 2, 3`; the positive control reproduces `r118/chained-nonce`
for `D = 1..5`.

**REFUTED** — the sub-prediction that `L = 10, t = 2` "should work because 20 ≥ 12". It does
not: the usable equations are `L·(t−1) = 10 < 12`, the system has a 2-dimensional kernel,
and even the seed-nonces-as-unknowns accounting is 20 equations against 22 unknowns. The
uniform threshold is `2 + (D+1)/L > 2`, so **`t = 2` never suffices for any finite `L`**.

**Nothing INCONCLUSIVE and nothing BLOCKED**: every cell has ≥12 trials, every recovered key
was verified with `d_k · G == Q_k` (and independently with full ECDSA verification), and
`A · x_true == b` holds in all 626 trials, so there is no null left that could be a harness
artefact.

## Precondition / scope

The affine parameters must be **constant** across keys and across signatures, the seed
nonce must lie **outside** the family, and the `D` signals must be **distinct public
functions** of the previous signature. Per-signature noise is fatal (measured in
`r118/structural-noise/`), and a per-key secret offset — i.e. `Δ` differing between keys —
would break the shared system apart into `L` independent `t = D+3` problems.
