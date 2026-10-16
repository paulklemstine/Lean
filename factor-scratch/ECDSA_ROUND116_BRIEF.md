# ECDSA brainstorm, round 116 — axes BEYOND the round-115 brief

Companion to `factor-scratch/ECDSA_BRIEF.md` (axes A–L). Round 115 already
completed axes A, D, F and I-baseline; I1/I2/I6 and K are still running.

> **ROUND 116 UPDATE — Axis M/N is COMPLETED and its headline claim is REFUTED.**
> See `r116/mn-threshold-surface/RESULT.md`. The counting argument
> (`#lattice points in box → t·ℓ > b`) is *true but not binding*: the measured
> threshold is `t·ℓ ≈ (1.03, 1.125, 1.25) × log₂ n` for `t = (2, 4, 8)`, and it is
> **exactly independent of the key entropy `b`** (`l*` = 72 for `b` from 16 to 256).
> Reason: the scaled nonce coordinates `K_i·2^ℓ ≤ 2^{nbits}` dominate the target
> vector's norm, so the Gaussian-heuristic condition `‖v*‖ ≲ det^{1/(t+2)}` contains
> no `b`. Consequence: a `b`-bit key is a *kangaroo* problem (`2^{b/2}`), and its small
> entropy does **not** reduce the lattice attack's leakage requirement. Read Axis M/N
> below as the reasoning that was tested and killed, not as an open direction.

This file is for the axes that are not in that brief at all — plus, at the end, a
*pre-screened closed* list, because "we considered X and it is inapplicable for
reason Y" is worth a table in a paper and saves a round of work.

The yardstick set by round 115, which everything here must beat:
**plain HNP lattice attack needs total nonce leakage `t·ℓ ≈ (1.03 … 1.50) × log₂ n`**,
and the *information-theoretic floor* is `t·ℓ ≥ log₂ n` (measured in
`r115/hnp-baseline/RESULT.md`). Beating the floor is impossible; beating the
1.03–1.5× overhead is the only game.

---

## Axis M — the threshold *surface*, not the threshold *curve*
**Math.** Round 115 measured one slice: how much *nonce* leakage `ℓ` is needed, with
the key assumed uniform in `[0, n)`. The real object is 2-dimensional. Write the HNP
instance with unknown `d ∈ [0, 2^b)` and unknown `K_i ∈ [0, 2^m)`, `m = nbits − ℓ`.
The number of lattice points in the box is `≈ 2^b · 2^{tm} / n^t`, so uniqueness runs
out along the curve `b + t·m = t·nbits`, i.e. **`t·ℓ = b`**. The 1-parameter slice
round 115 measured is the ray `b = nbits`.
**Why it is not in the brief:** the brief treats "small key" (Axis K, kangaroo) and
"nonce leakage" (Axis I, lattice) as separate axes. They are one 2-parameter problem,
and the boundary's *shape* is the deliverable.
**Status: OPEN as a measurement. The counting argument itself is classical HNP theory
(Boneh–Venkatesan already stated the hidden number's bound as the parameter); the
measured LLL overhead *as a function of b and t* is not published in this form.**
**Falsifier:** if the measured boundary is not `t·ℓ ≈ b + O(dimension overhead)` — in
particular if the boundary is *flat* in `b` — the whole combination idea dies.
**Experiment:** extend `r115/hnp-baseline/hnp_baseline_lib.sage`'s `build_instance`
with a `dbits` parameter (`d < 2^dbits`), sweep `(b, t, ℓ)` on the grid
`b ∈ {64, 96, 128, 192, 256}`, `t ∈ {2,4,8}`, `ℓ = 0 … b`, 12 seeds/point, report the
rate at every point and the fitted boundary line. Expected answer: boundary
`t·ℓ ≈ 1.03–1.5 × b`.
**Trap:** the harness must verify `d` was actually drawn from `[0,2^b)` — a generator
that ignores `dbits` silently measures the old curve. Also: `b = nbits` must reproduce
round 115's numbers exactly, or the new harness is broken.
**Lean target:** none for the measurement; but the *additive* form
`t·(nbits − m) + (nbits − b) ≥ t·nbits` is a one-line arithmetic statement, and the
box-volume argument is the same shape as Axis D's counting floor. Low priority.

---

## Axis N — deployment consequence: a key with `b` bits of entropy needs `b` bits of nonce leakage
**Math.** Specialising Axis M to `b < nbits`: **if the public key `d` is known to come
from a small set (≤ `2^b` possibilities), the nonce-leakage requirement drops from
`log₂ n` to `b`.** For a `2^128` brainwallet on secp256k1, that halves the required
leakage (256 → 128 bits). Note this is *not* the kangaroo attack (Axis K, cost
`2^{b/2}` group ops, algebraic-free); it is the algebraic attack becoming available
with half the side channel.
**Status: the arithmetic is classical; the *deployment statement* — "low-entropy keys
are lattice-attackable with proportionally less nonce leakage, on top of being
kangaroo-attackable" — is not in the brief and is worth a measured table.**
**Falsifier:** measure the threshold at `b = 128` and `b = 64`; if it stays at
`≈ log₂ n` rather than dropping to `≈ b`, the claim is refuted.
**Experiment:** same harness as Axis M; deliverable is a 4-row table
(key-entropy `b` → required total leakage) plus the honest note that kangaroo at
`2^{b/2}` and the lattice at `t·ℓ ≈ b` are *alternative* cost models for the same
population, not composable ones.
**Trap:** a "brainwallet" experiment where the message hash is not in the signature
equation, or where `d` is drawn uniform and merely asserted small. Ground truth:
assert `d < 2^b` at generation time.
**Lean target:** none.

---

## Axis O — cross-key RNG correlation (many keys, one RNG)
**Math.** Every lattice result so far is per-key: one unknown `d`, `t` signatures from
that key. Real services sign for *many* keys out of one DRBG stream, so nonce
`k_{i,j}` (key `i`, signature `j`) is correlated *across* keys. Build one lattice over
`(d_1, …, d_L, k_{i,j})`: dimension `L + Σt_i`, equations `L·t`. Question: does the
cross-key structure recover *several* keys with less total leakage than `L` separate
instances?
**Status: OPEN. The within-key version is Axis I2 (running); the cross-key version is
not in the brief. This is the axis most likely to produce an amortisation surprise,
and it is the one that matters for a service rather than an individual.**
**Falsifier:** show that the joint lattice never beats `L` independent instances at
equal total leakage — i.e. no amortisation. A clean negative is a real result.
**Experiment:** generate `L ∈ {2,4}` keys whose nonces come from one LCG/DRBG stream;
build the joint lattice; compare against `L` runs of the round-115 baseline with the
same per-signature leakage. Report the leakage needed per key recovered.
**Trap:** counting *keys recovered*, not *dimension reduced*; and positive control —
the case where all keys share the *same* nonce must recover all of them (that is the
known degenerate case and it must fire before any null is reported).
**Lean target:** none.

---

## Axis P — re-measure the published *digit-representation* techniques against our own baseline
**Math.** Nonces leak through their *representation*, not only their bits: the
double-and-add chain (Minerva/LadderLeak), the wNAF digits (De Micheli–Piau–Pierrot,
*A tale of three signatures: practical attack of ECDSA with wNAF*), and the width-`w`
digit distribution. These build lattices that are *not* the plain MSB/LSB embedding,
and they are exactly the "new geometry" the brief's I1/I2/I6 ask to invent.
**Status: the techniques are published; the measurement against a controlled baseline
is not.** Per the campaign's own standing rule, an axis that re-measures a standing
result with a proper control is worth more than a tenth new mechanism.
**Falsifier / deliverable:** for each technique, the leakage it needs vs. our measured
`1.03–1.5 × log₂ n`. If a published technique does not beat our baseline in our
harness, that is a finding about the technique, not about our harness — report both.
**Experiment:** implement the wNAF-digit embedding (3-signature "tale of three") and
the double-and-add-chain embedding in the round-115 harness, at `t·ℓ` values around
the measured boundary.
**Trap:** blog-post numbers. The FHG/DS/ch-loss papers give per-signature bit counts
at specific curves; re-derive the *equivalent* `t·ℓ` before comparing, or the
comparison is meaningless.
**Lean target:** none.

---

## Axis Q — the algebraic acceptance set of ECDSA verification (Lean formalization)
**Math.** Verification computes `w = s^{-1}`, `u_1 = z·w`, `u_2 = r·w`, `R = u_1·G + u_2·Q`,
accepts iff `x(R) ≡ r (mod n)`. Because `x(−P) = x(P)`, the acceptance set has exact
structure:
- **Malleability:** `(r, s)` and `(r, n − s)` both verify for the *same* `(Q, z)`.
- **Related-key forgery:** for *any* public key `Q' = Q + λG` and message
  `z' = z − λ·r`, the *same* `(r, s)` verifies. Proof:
  `u_1'G + u_2'Q' = ((z−λr)/s)G + (r/s)(Q+λG) = (z/s)G + (r/s)Q = R`.
So the full acceptance set is the affine line `{(Q + λG, z − λr) : λ ∈ ℤ_n}` — a
*complete characterisation*, not a folklore remark.
**Why it is not in the brief:** the brief only asks for the malleability fact as I8.
The complete line, plus the "why" (`x(−P)=x(P)`), is a stronger and cleaner statement.
**Status: OPEN as a formalisation; the underlying facts are classical.**
**Falsifier:** if Lean finds a counterexample to the affine-line claim (i.e. an
accepted `(Q', z')` off the line), the characterisation is incomplete — that would be
the interesting outcome.
**Experiment / Lean target:** state and prove, in the catalog's elliptic-curve model,
`verify (Q,z) r s = true → ∃ λ, Q' = Q + λG ∧ z' = z − λr` in the *generic* group
model (where `x(−P)=x(P)` is the only hypothesis). The repo already has the group-law
and stereographic secp256k1 machinery (`Geometry/InverseStereoSecp256k1.lean`), so the
crux hypothesis `x(−P) = x(P)` is either already there or one line away. Deliverable:
a Lean theorem + a note on what the theorem says about protocols that let an attacker
pick the public key (pay-to-pubkey, certificate-less, key-substitution settings).
**Trap:** "ECDSA is forgeable" is true only *under key substitution*; say so
explicitly, or the result reads as a claim about standard usage.

---

## Axis R — adaptive chosen-message nonce steering *(SCREENED CLOSED)*
**Idea:** if an attacker can choose the message after seeing it signed, can they steer
the nonce `k` into a known small interval, converting unknown `K_i` into known ones?
**Closed by the order of operations.** In ECDSA the nonce is generated *before* (or
independently of) the message hash — `r_i = x(k_i G)` does not depend on `z_i`, and
the attacker's choice of `z_i` only moves `k_i` through `k_i = s_i^{-1}(z_i + r_i d)`,
which requires knowing `d` to control. In RFC 6979 the nonce is `HMAC(d, z)`: choosing
`z` gives no control over an unpredictable PRF output. **Do not open this axis.**
(Counter-setting: multi-signature / "sign-then-decide" protocols where nonce and
message ordering IS attacker-controlled are a different problem, and are not ECDSA.)

## Axis S — the negation map as a "free bit" of nonce leakage *(SCREENED CLOSED)*
**Idea:** `k` and `−k` give the same `r` and opposite `s`, so the signature determines
the nonce only up to sign — apparently 1 free bit per signature.
**Closed.** Knowing that the nonce lies in `{k_0, −k_0}` is not usable leakage unless
`k_0` is known. Under MSB/LSB leakage of `k`, the sign ambiguity does not shrink the
unknown interval (it maps `k` to `n − k`, a *different* set of ± intervals). It does
give a free *detector* for nonce reuse (see I7), and it is the source of the
malleability in Axis Q — but it is not a bit of HNP leakage.

## Axis T — the `2^b`-key cost model, kangaroo vs lattice vs neither *(deployment table)*
**Math.** For a population of `b`-bit keys: the interval attack costs `2^{b/2}` group
ops (Axis K, measurable, running); the lattice attack needs `t·ℓ ≈ b` bits of side
channel (Axes M/N). For the same target population the two are *substitutes*, and the
deliverable is a cost table that says which threat dominates at which `b`.
**Status: OPEN as a table; both halves exist.**
**Falsifier:** if the measured lattice threshold at `b = 128` is not `≈ 128` (Axis M),
this table's left column is wrong and the comparison is meaningless.
**Experiment:** combine the Axis M numbers with the Axis K measured op-rate; present
"bits of side channel" and "group operations" side by side for `b ∈ {96,112,128,160,192}`.
**Trap:** wall-clock numbers without a measured op rate, and extrapolations presented
as predictions (the campaign's own rule).

---

## Screened-and-closed summary (carry this into any paper)

| Looked promising | Closed by |
|---|---|
| Chosen-message nonce steering | `r` independent of `z`; nonce chosen first (Axis R) |
| Negation map = free leakage bit | sign ambiguity without knowing `k` (Axis S) |
| Offset-type faults in scalar mult as new lattice rows | they shift `z`, i.e. they reproduce the *same* HNP instance with modified `z`; bit-zeroing faults *are* MSB leakage (I1) |
| Weil descent / GHS / summation polynomials | needs `n ≥ 2` fields (brief §1) |
| p-adic log on small non-zero trace | Lean obstruction theorem, round 115 Axis F |
| MOV/small embedding degree | no standardized curve has it |
| Pohlig–Hellman on group order | the three deployed orders are *prime* (round 115 Axis A) |

## Suggested round-116 priority

1. **M then N** (the 2-parameter threshold and the small-key deployment statement) —
   one harness change, the highest information gain, and it subsumes Axis K's threat
   model into one table.
2. **Q** (Lean acceptance-set theorem) — cheap, formalizable, and gives the repo an
   ECDSA-specific result rather than another generic EC lemma.
3. **O** (cross-key RNG) — the only axis with real amortisation potential; run it as a
   *negative* if it comes out negative, with the same-nonce positive control.
4. **P** (re-measure wNAF/chain techniques) — low novelty, high verification value.
5. **R, S** — do not run; they are closed above.
