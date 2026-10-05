# R55 KERNEL — the 2-adic digit, and the obstruction that was never real

**Scope: classical factoring of RSA-scale integers. Not a cryptographic break.**
No modulus of cryptographic interest was factored; all moduli are locally
generated and below 2^40. The true NFS regime (π(B*) ~ 10^15–10^33) is
uninstantiable here and I do not extrapolate into it.

---

## 0. VERDICT UP FRONT

**Three results, in decreasing order of how much I trust them.**

> ### 1. CLOSURE. `GAIN > 1` does **not** exist in the 2-power relation family,
> ### and the reason is a *law*, not a heuristic. Higher 2-adic digits of
> ### `lam_p` **are** read by the relation condition — I proved the exact law
> ### and verified it on 246 360 exhaustive triples — but reading digit `e`
> ### pays *exactly* the root multiplicity `2^e` that digit was worth.
> ### `GAIN = 1` for every `e`, identically, not on average.

> ### 2. CHARACTERISATION — and a correction to the inherited one.
> ### **The symmetry obstruction is vacuous.** Round 53's stated reason for
> ### excluding higher characters ("the product is symmetric under p↔q so it
> ### can be read off n alone", and its converse) is **false in the direction
> ### it is used**. Every character of `(Z/nZ)*` is exchange-invariant, at
> ### every order. The real obstruction is *computational*, not structural.
> ### This invalidates the **stated ground** of the r48/r53 closures.

> ### 3. The research question, answered precisely: higher 2-adic digits enter
> ### the relation condition **only as one-sided thresholds** `lam_p >= e`.
> ### A threshold is a filter, never a conditioning, so it can never raise a
> ### rate — which is the mechanism behind result 1.

**Does `GAIN > 1` exist?** Not in this family. See §2 for the precise class in
which the closure holds and — importantly — **which part of it is a
mathematical theorem and which part is a limitation of this host.**

---

## 1. THE THREE THEOREMS

### Theorem B (the threshold law) — **PROVED + EXHAUSTIVELY VERIFIED**

Let `p` odd prime, `b` a unit mod `p`, `k >= 1`, `e >= 0`, `A = v2(p-1)`,
`lam_p = v2(p-1) - v2(ord_p b)`.

```
b^k is a 2^e-th power mod p   <=>   lam_p >= min(e, A) - v2(k)
```

*Proof.* `ord_p(b^k) = ord_p(b)/gcd(ord_p(b), k)`, so writing
`s = v2(ord_p(b^k)) = v2(ord_p b) - min(v2(ord_p b), v2(k))`. The `2^e`-th
powers form the subgroup of index `2^min(e,A)`, and a unit `t` lies in a
subgroup of index `g` iff `t^((p-1)/g) = 1`, i.e. iff `ord_p(b^k) | (p-1)/2^min(e,A)`,
i.e. iff `s <= A - min(e,A)`. Substituting and rearranging gives the claim.
∎

**Verified:** all primes `p <= 300`, all `b in (Z/p)*`, `k in 1..6`,
`e in 0..4` → **0 mismatches in 246 360 triples**, per-cell, reported
per-`(A, e, v2(k))` in `results/e1_threshold.json`.

`e = 1, k` odd recovers round 53's law `NOT(lam_p = 0)` exactly, as it must.

**Companion closed form (also verified):** for uniform `b`,
`P(lam_p >= t) = 2^-t` **independently of `A`**, for every `t <= A`. Checked
on every prime `<= 300`, every `t <= A`, agreement to 1e-9. This is *not*
the uniform distribution I first assumed (§5, error 2) — `P(lam_p = 0) = 1/2`
always, and the rest is geometric.

### Theorem C (e-neutrality) — **PROVED + EXHAUSTIVELY VERIFIED, CORRECTED FORM**

With `a = min(e, A)` and `t = v2(k)`, for `b` uniform over `(Z/p)*`:

```
E_b[ #{x in (Z/p)* : x^(2^e) = b^k} ]  =  2^t   if t < a
                                        =  2^a   if t >= a
```

*Proof.* `#x-solutions = 2^a * [lam_p >= a - t]` (the map `x -> x^(2^e)` has
image of size `(p-1)/2^a` with every image point hit exactly `2^a` times). If
`t >= a` the bracket is identically true, mean `2^a`. Otherwise
`P(lam_p >= a-t) = 2^{-(a-t)}`, giving `2^a * 2^{-(a-t)} = 2^t`. ∎

By CRT the local counts multiply and `b mod p`, `b mod q` are independent, so
for `n = pq` the joint mean is the product of the two local means.

**Verified:** 72 cells over 6 moduli, `k in {1,2,3}`, `e in 0..3`:
**max |mean − predicted| = 0.0 exactly.**

**THE `e`-INDEPENDENCE IS THE POINT.** For fixed `k`, the mean does not depend
on `e` whenever `v2(k) < min(e,A)` on both sides. A search that reads digit
`e` instead of digit 1 gains `2^e` roots per solution and pays `2^e` in
annihilated bases, **exactly**. `GAIN = 1` identically, for all `e`.

### Theorem D (corrected) — **the symmetry obstruction is VACUOUS**

**The inherited claim is false.** Round 53 (`core.py`) writes:

> "the quadratic character escapes only because it is the product, and the
> product is symmetric under p↔q so it can be read off n alone"

applied to exclude higher characters. But let `chi_p`, `chi_q` be **any**
characters of the local groups, `M` **any** order. Then
`chi(b) = chi_p(b mod p) · chi_q(b mod q)` is a character of `(Z/nZ)*` and is
exchange-invariant because `mu_M` is **abelian**:

```
chi under the swap = chi_q(b mod q) · chi_p(b mod p) = chi(b)
```

**This holds for every pair and every `M`. There is no order cutoff at 2.**

**Verified:** E12 enumerates every character of `(Z/n)*` with image in `mu_6`
for five moduli (36 characters each) and checks exchange-invariance on every
unit: **0 mismatches in 40 176 (character, base) checks.**

The cubic-Jacobi-type product `psi_3(b) = (b/p)_3 (b/q)_3` therefore **exists,
is symmetric, and is a well-defined function of `(n, b)` alone**. Symmetry does
not kill it. E14 confirms 8 non-trivial symmetric characters of order 3 and 24
of order 6 exist per modulus — the invariant space is strictly richer than
`{1, Jacobi}`.

**The correct obstruction is computational:**

> **(H)** can `F(n, b)` be evaluated in `poly(log n)` time *without factoring* `n`?

`Jacobi` satisfies (H) — Euclidean descent in `O(log n)` steps, using the
supplementary law `(2/n) = (-1)^{(n²-1)/8}` and quadratic reciprocity, which
let it be computed without ever naming `p` or `q`. Higher symbols have no
comparable descent; their reciprocity is genuine high algebraic number theory.

**Scope of the correction (E13, negative control).** Symmetry is vacuous *for
multiplicative characters*, **not** for all functions of the local data.
E13 exhibits, for each of the five moduli, two bases whose unordered pair of
local cube-membership bits is identical but whose order differs — e.g. `n = 91`
bases `5` and `6` — so asymmetry **does** exist elsewhere. Without this control
my claim would have been the overclaim "symmetry is vacuous, full stop".

> **CONSEQUENCE FOR PRIOR ROUNDS.** Every closure in r48/r53 resting on the
> symmetry argument is **un-grounded as stated**. Most will still die — on (H),
> or on the round-51 GAIN law, which is *measured* and independent of symmetry
> — but a closure resting on a false reason is not a closure. **`NN_synth.md`
> §5's condition (i), "is a quadratic character, so it is controllable from `n`
> alone", silently uses symmetry as the justification, and that justification
> is not what makes Jacobi work.**

---

## 2. THE PRECISE CLASS OF THE CLOSURE

The class is **power-type relation conditions**, i.e. `x^(2^e) = b^k`. Within
it, `GAIN = 1` **exactly** — this is a theorem, not a measurement.

Deliberately **not** claimed:

- conditions outside the power family (`a² + a = b^k`, `a² = b^k + c`,
  Jacobi-of-derived-quantity `Jacobi(b²-c/n)`, order-based conditions);
- non-power-residue mechanisms (small-index subgroups, elliptic-curve
  order tricks);
- anything requiring `p`, `q`, or `v2(ord_p b)` to be *known* rather than
  averaged — Theorems B and C are stated as means over `b`, and a construction
  that could *identify* a good base without knowing `lam_p` would sidestep the
  whole argument. **That is the gap the next round should attack**, and §4
  sharpens it.

---

## 3. EXPERIMENTS

All predictions written before measuring. All exhaustive — **no sampling
anywhere**, so no z-scores are quoted and no row is UNDERPOWERED.

### `e1_threshold.py` — Theorems B and the `lam_p` distribution

| ID | Prediction | Result |
|---|---|---|
| E0 | group test ≡ brute-force enumeration, **and** non-vacuous | 31 020 checked, **0 disagreements**, 68.5% true → **PASS** |
| **P1** | (*) holds on every triple | **0 / 246 360 mismatches → PASS** |
| **P2** | detector fires: rate 0 in `lam=0` cell, 1 elsewhere | **{0:0.0000, 1:1.0, 2:1.0, 3:1.0, 4:1.0, 5:1.0, 6:1.0, 7:1.0, 8:1.0}, 4106 bases → PASS** |
| P3 | rate monotone decreasing in `e` | 1.0, 0.500, 0.376, 0.349, 0.342 → monotone → PASS |
| **P4** | *wrong* statistic (`v2(ord)` not `lam`) must fail | **438 / 16 424 = 2.67% mismatches → PASS** (fires) |
| **P5** | same harness at prime 3 must fire too | fires, 0 mismatches → PASS |

**Honest scope:** `p <= 300`, i.e. 10–18 bit primes. This is a **structural**
law (a proof plus a check), so small moduli are appropriate — but the *rates*
in P3 are not RSA-regime rates and must not be extrapolated.

### `e6_gain.py` — Theorem C and the GAIN decision

| ID | Prediction | Result |
|---|---|---|
| E11 | root-count formula ≡ enumeration, non-vacuous | 12 408 checked, **0 disagreements** → PASS |
| **P6** | mean = closed form, all cells | **max abs dev = 0.0 over 72 cells → PASS** |
| **P7** | root count must **vary** (else P6 vacuous) | 34/72 cells non-constant, both values >= 20 → PASS |
| **P8** | *wrong* law ("always `2^min(e,A)` roots") must fail | **31.25% mismatch → PASS** (fires) |
| P9 | `k`-even saturation law | all cells agree → PASS |

**Per-cell, never pooled-only** — the pooled number alone would hide the
even-`k` saturation that cost me two wrong theorems (§5).

### `e12_symmetry.py` — the characterisation

| ID | Prediction | Result |
|---|---|---|
| E0 | `_is_cube` ≡ literal `{x³}` enumeration | 2028 checked, 0 disagreements → PASS |
| **E12** | **every** character is exchange-invariant | **0 mismatches / 40 176 checks → PASS** |
| **E13** | asymmetric functions exist (scoping control) | witnesses at all 5 moduli → PASS |
| **E14** | higher-order symmetric chars exist | 8 of order 3, 24 of order 6 per modulus → PASS |

### Reproducibility

`SEED` declared at the top of every file. **Both `e1_threshold.py` and
`e6_gain.py` run twice and compared: stdout and JSON bit-identical.**
`e12_symmetry.py` likewise. Both files are **exhaustive with no RNG**, so the
agreement is structural, not lucky — but the check is run and reported anyway,
because the adjacent round's uncitable defect was exactly a silent unseeded
count.

---

## 4. A PRECISE REFORMULATION FOR THE NEXT ATTEMPT

The problem statement asks for the advantage to live "in the kernel of what
the sieve index can see". Theorems B and C show that inside the power family
the kernel is **exactly** the one-sided thresholds `lam_p >= e`, and thresholds
are anti-gains by construction. So:

> **KERNEL REFORMULATION.** For a relation condition on `b`, let `K` be the set
> of functions of `b` that the condition's success event is **constant on**.
> For power-type conditions, `K` = {functions of `lam_p` below every
> threshold}, and the *gradient* of `K` — the part that distinguishes `lam_p`
> from `lam_p + 4` — is empty. Any construction with `GAIN > 1` must therefore
> have a success event that is **not monotone in `lam_p`**, i.e. must have a
> cell where *more* 2-adic structure in the base yields *more* survivors.

That is a sharper target than "read a higher digit": **non-monotonicity in
`lam_p`**, which no threshold can provide at any order.

**Candidates that could break it, none ruled out here:** relations whose
success depends on `lam_p` through the *odd* part of `ord_p b` as well (so the
event is no longer a function of `lam_p` alone); conditions on the base's
order rather than its residuacity; `Jacobi(b²-c/n)` for fixed small `c`,
whose local roots are governed by `1+4c`-type discriminants and not by the
power structure at all. Each is outside the class Theorem C covers, and each
must clear **(H)** — computability from `n` alone — which is the obstruction
that is real.

---

## 5. MY ERRORS, PROMINENTLY

Six substantive errors, all caught by controls rather than by inspection.

1. **`min(e,A)` missing from the Theorem B predicate — 37 588 spurious
   mismatches.** I wrote "if `e > A` then vacuously true", reasoning that
   `2^e ∤ p-1`. False: the image of `x ↦ x^(2^e)` has index
   `2^min(e,A)`, a **proper** subgroup even when `e > A`. Every failing
   triple was in the `e > A` cell. Caught by P1 returning 37 588.

2. **"`lam_p` is uniform on `{0..A}`" — my predicted pooled rate was 0.75,
   measured 0.500061.** Wrong premise; the true law is `P(lam >= t) = 2^-t`,
   independent of `A`, with `P(lam=0) = 1/2` always. I first "corrected" it to
   `A/(A+1)` (predicted 0.611) — *still wrong*, and I caught myself by
   computing the empirical distribution instead of reasoning harder.

3. **Test primes chosen without `3 | (p-1)`** — both E13 and E14 failed for
   this reason alone. The controls were right; my *inputs* were bad. This is
   the "vacuous test that prints FAIL" hazard in its mirror image.

4. **`_is_cube` — three wrong versions, the first two vacuously `True`.**
   v1 used base 3 in place of a primitive root. v2 tested
   `a^((p-1)/3) ∈ {1, w, w²}`, which is constant-true because that set *is*
   the image of the map. v3 (`a^((p-1)/3) == 1`) is correct.
   **The lesson that matters:** my first "ground truth" validation of v1
   recomputed the cube set as `{x³ mod p}` but compared it *through the same
   broken expression*, so it reported **0 disagreements on a function that
   returned `True` for every input**. A control that reuses the logic under
   test is not a control. The independent enumeration (2028 checks) caught v2
   with 1352 disagreements.

5. **Denominator `n-1` where the loop skipped non-units** — put `0.845`
   where the truth is `1.000`, because φ(143) = 120 ≠ 142.

6. **Two wrong forms of Theorem C's mean** — "always 1" (true for `k` odd,
   false for even `k`, where it is `2^a`) and then "`2^v2(k)`" (true only when
   `v2(k) < min(e,A)`). Both caught by the 72-cell grid. **The `e`-independence
   survived both, which is why the result stands.**

Two of my *predictions* were wrong rather than my code (P2's 0.75, and P7's
">= 3 distinct values" — with `e>=1` each local count is `0` or `2^a`, so only
2 values exist; the requirement that actually tests non-vacuity is
non-constancy with both sides populated). Both are recorded above.

---

## 6. WHAT IS NOT DETERMINABLE FROM HERE

- **The hardness direction of Theorem D.** I proved symmetry is vacuous. I did
  **not** prove that no `poly(log n)` algorithm computes `psi_3(n,b)` without
  factoring. That is the correct open obstruction, and it is a hardness
  statement — not settleable by the exhaustive small-modulus work here.
- **Anything requiring moduli at NFS scale.** `p <= 300` throughout. Theorem C
  is a law, so it transfers; the *rates* do not.
- **The non-power family** listed in §2 — untouched, not refuted.
- **Whether Theorem C extends to `a^(m^e) = b^k` for odd `m`.** The argument
  uses `2`-adic valuations throughout; the odd-`m` analogue is not written.
- **arXiv and zbMATH were unreachable this session** (see §7), so I could not
  survey whether a higher-residue NFS variant exists in the literature. I did
  not want to assert absence.

---

## 7. PROVENANCE

**Fetched and verified this session, via Crossref (`api.crossref.org`), which
was live:**

1. Don Coppersmith, *"Small Solutions to Polynomial Equations, and Low Exponent
   RSA Vulnerabilities"*, **Journal of Cryptology 10 (1997) 233–260**,
   DOI `10.1007/s001459900030`. Author, title, journal, volume, pages
   confirmed via Crossref. *(Cited as the origin of the small-root framework
   this round sits beside; **I did not read the paper's text this session** and
   make no claim about its contents beyond the bibliographic record.)*
2. M. R. Mills, *"The m-th Power Residue Symbol"*, **American Journal of
   Mathematics 73(1) (1951) 59**, DOI `10.2307/2372160`.
3. M. Furuta, *"A reciprocity law of the power residue symbol"*, **Journal of
   the Mathematical Society of Japan 10 (1958)**, DOI `10.2969/jmsj/01010046`.
   *(2) and (3) are cited only as evidence that higher power residue symbols
   and their reciprocity laws are classical, standard objects. I did not read
   either paper; **no claim about their contents is made.** They are not used
   in any proof above — Theorems B, C, D are self-contained.*

**Local context read in full:** `r48/notes/NN_synth.md` (§3.2, §4.3, §5),
`r48/notes/MM_design.md` §4, `r53exp/synth/core.py`, `r53exp/synth/selftest.py`
structure.

**UNVERIFIED / unreachable this session:**

- **arXiv API returned 14 bytes (empty) on two query forms** — the full-text
  search for "higher power residues" / "power residue symbol + factoring"
  could not be run. **No arXiv identifier is cited anywhere in this note**, by
  deliberate policy: this programme has 18 recorded fabricated identifiers.
- **zbMATH Open API** reachable (returned a well-formed 404 JSON with
  `status_code 404`) but the record I probed for was not found; I did not
  obtain a usable zbMATH confirmation of any of the three references above.
- **No WebSearch was used** — it fabricates citations on this host.
- The hardness direction of Theorem D (§6) is **UNVERIFIED** and is the main
  open item this round hands forward.

**Files:** `e1_threshold.py`, `e6_gain.py`, `e12_symmetry.py`, `results/*.json`.
All in `/home/raver1975/lean/factor-scratch/r55exp/kernel/`. Nothing outside
this directory was modified; no commit, no issue, nothing written to `Papers/`
or `Catalog/`.