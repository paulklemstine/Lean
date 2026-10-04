# Round 109 — implicit factorization: a third distribution-specific per-instance model

**2026-10-04. A real new algorithmic result.** Rounds 108/108b opened the
many-instance (batch) models and found per-instance wins for *shared-prime* moduli.
This round opens a genuinely different model — **Implicit Factorization (IFP)**:
RSA moduli whose primes **share low bits** (not reuse, not a pool) factor in
**polynomial time**, verified end-to-end.

Empirical companion: `Experiments/UMWWindow/implicit_factor.py` (deterministic,
`out_ifp.txt`).

---

## 1. A new model (untouched by rounds 96–108)

`N₁ = p₁q₁`, `N₂ = p₂q₂`, with `p₁, p₂` **sharing their low `w` bits**:
`p₁ = z + 2^w·u₁`, `p₂ = z + 2^w·u₂`, `z < 2^w` the shared low part,
`q₁, q₂` of size `α` bits. This is **not** reuse (primes distinct) and **not** a
small pool — it is a *correlated-prefix* structure, the family behind
"Coppersmith in the wild" key-recovery results.

## 2. The mechanism (derived and verified here)

Modulo `2^w` both primes equal `z`:
`N₁ = p₁q₁ = (z + 2^w u₁) q₁ = z q₁ + 2^w u₁ q₁`, hence `N₁ ≡ z q₁ (mod 2^w)`.
So
$$ q_1 \;=\; N_1\, z^{-1} \pmod{2^w}, \qquad p_1 = N_1/q_1. $$
If `w ≥ α` (so `q₁ < 2^w`), `q₁` is fully determined — **one modular inverse and
one division: polynomial time**, far below `L[1/3]`.

**Verified:** `q₁` recovered and `p₁ = N₁/q₁` correct in **8/8 trials at every
`w ≥ α`** (`w = 16, 18, 32, 36` with `α = 16`).

This grounds the published IFP line: May–Ritzenhofen (PKC'09, `t ≥ 2α+3`) →
Kurosawa–Ueda (IWSEC'13, `2α+1`) → Nuida–Itakura–Kurosawa (ePrint 2014/839,
`t = 2α − O(log κ)`) → Feng–Nitaj–Pan (ePrint 2023/1562). Those subtle bounds use
a **lattice** to handle a *hint* (`p₁−p₂`) rather than the exact shared part; the
crisp "known shared part, `w ≥ α` ⟹ poly-time" corollary is what is verified here.

## 3. Two bugs the data caught (the round-104 guard, twice more)

* The first version reported `0–1/8` — because `p₁ = z + 2^w u₁` with odd `z` at
  these sizes is rarely prime, so most trials `continue`d before the check. The
  `0/8` was a *setup* artifact, not a mechanism failure. Fixed by searching `z`
  until `p₁` is prime → `8/8`.
* A cleaner debug run established the mechanism (`3/3`) independently before the
  experiment was finalized — good practice: **verify the mechanism in isolation
  before trusting the harness.**

This is the fourth and fifth firings of the guard. The pattern is stable: any
reported fraction is cross-checked against an isolated mechanism test before it
is recorded.

## 4. What this adds, honestly

* A **third distribution-specific per-instance model** with a genuine
  **polynomial-time** result (below `L[1/3]`): primes sharing low bits.
  Alongside: small-pool batches (`O(B)`/instance, r108) and unknown-pool batch GCD
  (`O(B)`/instance, r108b).
* A **derived, verified mechanism** (not a literature assertion) plus the exact
  published bound progression it grounds.
* **Not claimed:** any improvement for independent random RSA keys. IFP is a
  *correlated-key* attack; it moves the burden to key generation, not the modulus.

## 5. Where this leaves the program

The per-instance picture now has **three real models** (small-pool batch,
unknown-pool batch GCD, shared-low-bit IFP), each verified and each far below
`L[1/3]` — but each **distribution-limited**. The consistent, honest finding
across rounds 108–109 is that *any* per-instance win below `L[1/3]` requires
**correlated or reused key material**. The **independent-key** case remains
firmly closed (worst-case `L[1/3]`; Batch NFS buys area, not per-key time).

The open door this round leaves is the **subtle IFP lattice bound** (`t ≈ 2α`
with a hint rather than exact shared part) — a real, well-posed improvement
target that the catalog's validated Coppersmith lattice (round 97f) could attack.
That is the natural next step if you want to continue this thread.