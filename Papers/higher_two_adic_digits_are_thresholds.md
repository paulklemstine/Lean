# Higher 2-Adic Digits Are Thresholds, Not Advantages

## `GAIN > 1` does not exist in the 2-power relation family — and reading digit `e` pays exactly the root multiplicity that digit was worth

**Round 55 · 2026-10-05 · Aether factoring programme**

---

## Abstract

Round 53 left a precisely-stated open problem: a construction with both
properties must make its success event depend on a local order-statistic of the
base that is a quadratic character (so controllable from `n` alone at `q = 1`)
**and** enters the relation condition through something not already determined
by `b mod p`. It closed by measuring that the search reads the base's 2-adic
structure through **exactly one bit** — the quadratic character — and asked
whether a **higher** digit could be read instead.

**This round answers it, and the answer is a law rather than a heuristic.**

> **`GAIN > 1` does not exist in the 2-power relation family.** Higher 2-adic
> digits of `lam_p` **are** read by the relation condition — proved exactly and
> verified on **246 360 exhaustive triples** — but **reading digit `e` pays
> exactly the `2^e`-fold root multiplicity that digit was worth, and annihilates
> exactly the `2^e` bases it discriminated.** `GAIN = 1` **identically**, not on
> average.
>
> **The mechanism:** higher digits enter **only as one-sided thresholds**
> `lam_p ⩾ e`. **A threshold is a filter, never a conditioning** — and a filter
> cannot raise a rate.

**And a correction to my own round-53 scratch note**, recorded because the
distinction matters: **the symmetry obstruction it quoted is not what round 53's
published argument rests on.** Round 53's argument is **non-injectivity** of the
product map, which this round confirms and quantifies (**312 181 colliding pairs
on a single modulus**). See §5 — I checked before publishing a retraction, and
**the retraction is not warranted.**

**Classical factoring of RSA-scale integers. Not a cryptographic break.** No
modulus of cryptographic interest was factored; all computation `n < 2⁴⁰`, locally
generated.

---

## 1. Theorem B — the threshold law

Let `p` odd prime, `b` a unit mod `p`, `k ⩾ 1`, `e ⩾ 0`, `A = v₂(p−1)`,
`lam_p = v₂(p−1) − v₂(ord_p b)`.

```
b^k is a 2^e-th power mod p   <=>   lam_p ⩾ min(e, A) − v₂(k)
```

**Proof.** `ord_p(b^k) = ord_p(b)/gcd(ord_p(b), k)`, so
`s = v₂(ord_p(b^k)) = v₂(ord_p b) − min(v₂(ord_p b), v₂(k))`. The `2^e`-th powers
form the subgroup of index `2^min(e,A)`, and a unit `t` lies in a subgroup of
index `g` iff `t^((p−1)/g) = 1`, i.e. iff `ord_p(b^k) | (p−1)/2^min(e,A)`, i.e.
iff `s ⩽ A − min(e,A)`. Substituting and rearranging gives the claim. ∎

**Verified exhaustively:** all primes `p ⩽ 300`, all `b ∈ (ℤ/p)*`, `k ∈ 1..6`,
`e ∈ 0..4` → **0 mismatches in 246 360 triples**, reported per-`(A, e, v₂(k))`.

**This generalises round 53's law.** At `e = 1`, `k` odd it reduces to
`NOT(lam_p = 0)` — exactly round 53's exhaustive result, recovered as a special
case.

**Companion law, also verified:** for uniform `b`, **`P(lam_p ⩾ t) = 2^{−t}`,
independently of `A`**, for every `t ⩽ A` — so `P(lam_p = 0) = 1/2` always, and
the rest is geometric. *(I first assumed `lam_p` was uniform on `{0..A}`; it is
not. See §6.)*

## 2. Theorem C — e-neutrality, and why `GAIN = 1`

With `a = min(e, A)` and `t = v₂(k)`, for `b` uniform over `(ℤ/p)*`:

```
E_b[ #{x ∈ (ℤ/p)* : x^(2^e) = b^k} ]  =  2^t   if t < a
                                        2^a   if t ⩾ a
```

**Verified: max absolute deviation `0.0` over 72 cells.** The mean is `2^t` or
`2^a` — **a power of 2 determined by `v₂(k)` and `A` alone, independent of `e`.**

So reading digit `e`:

- **gains** a factor `2^e` in roots per base — the whole point of the digit;
- **annihilates** exactly the `2^e` bases that fail the threshold.

**Those two cancel identically.** The discrimination and the multiplicity are the
same object. **`GAIN = 1` for every `e`, every `k`, every rule — not on average,
identically.**

## 3. The research question, answered

> **Higher 2-adic digits enter the relation condition only as one-sided
> thresholds `lam_p ⩾ e`. A threshold is a filter, never a conditioning, so it can
> never raise a rate — which is the mechanism behind `GAIN = 1`.**

This is the sharpest form of round 53's §5 requirement. That note said the
advantage must live "in the KERNEL of what the sieve index can see". **Theorem B
shows the kernel is exactly the set of thresholds — and thresholds have no
interior to exploit.**

## 4. The precise class of the closure

`GAIN = 1` holds for relation conditions whose solvability is governed by
membership in a **subgroup of `2`-power index** — i.e. `x^{2^e} ∈ ⟨b⟩`-shaped
conditions. **This is a theorem about that class, not a statement about all
constructions.** Outside it — non-monotone conditions, `Jacobi(b²−c/n)`, conditions
on the *order* of `b` rather than its residue class — **nothing here applies, and
nothing here refutes them.**

## 5. ⚠️ A correction to my own round-53 note — and why I am NOT retracting it

The agent's notes claim round 53's symmetry argument is false. **Checking before
publishing a retraction of my own work, the claim does not hold up**, for a reason
worth stating precisely:

| | round 53 `core.py` (scratch) | round 53 **published paper** | what this round shows |
|---|---|---|---|
| quoted text | *"a character of order 3 must be a PAIR of local characters, which requires naming p and q"* | — | — |
| argument | symmetry | **NON-INJECTIVITY**: *"the local characters live in `μ₃`, and the product is not injective"* | symmetry is indeed vacuous — **but this was never the published argument** |

**I re-verified round 53's actual claim by brute force.** For `n = 2479 = 37·67`
with `3 | p−1, 3 | q−1`, counting bases by their cubic-character pair and then by
product:

```
product 0: 791 bases      product 1: 792 bases      product 2: 792 bases
PAIRS sharing a product but differing individually:  312 181
```

**The product map is many-to-one, exactly as round 53 claimed** — and far more
badly than the "935 pairs over 26 moduli" figure suggested, which was a much
smaller sample of the same phenomenon. **The closure stands.**

**What is genuinely true and worth recording:** the *quoted scratch comment* does
conflate symmetry with computability. Symmetry under `p ↔ q` is automatic for every
character (because `μ_M` is abelian), so it excludes nothing; the real obstruction
to using higher symbols is **computational** — can `F(n,b)` be evaluated in
`poly(log n)` without factoring `n`? — **which is a hardness claim, and this round
does not prove it.** Jacobi satisfies it by quadratic reciprocity; higher symbols
have no comparable descent.

**So: a real correction to a sentence in my scratch code, and no correction to any
published claim.**

## 6. Errors made, prominently

1. **`min(e, A)` missing from the Theorem B predicate — 37 588 spurious
   mismatches.** I reasoned "if `e > A` then vacuously true", since `2^e ∤ p−1`.
   **False:** the image of `x ↦ x^{2^e}` has index `2^min(e,A)`, a *proper*
   subgroup even when `e > A`. Caught by the per-cell prediction failing.
2. **"`lam_p` is uniform on `{0..A}`" — predicted pooled rate 0.75, measured
   0.500061.** Wrong premise; the true law is `P(lam ⩾ t) = 2^{−t}`. My first
   "correction" to `A/(A+1)` (0.611) was **also wrong** — caught by computing the
   empirical distribution instead of reasoning harder.
3. **Test primes chosen without `3 | (p−1)`** — two experiments failed for this
   reason alone. The controls were right; the *inputs* were bad.
4. **`_is_cube` — three wrong versions, the first two vacuously `True`.** v1 used
   base 3 in place of a primitive root; v2 tested membership in the image set,
   which is **constant-true because that set is the image**. **The lesson that
   matters: my first "ground-truth" validation recomputed the cube set through the
   same broken expression, so it reported 0 disagreements on a function returning
   `True` for every input.** *A control that reuses the logic under test is not a
   control.* An independent enumeration (2028 checks) caught v2 with 1352
   disagreements.
5. **Denominator `n−1` where the loop skipped non-units** — put `0.845` where the
   truth is `1.000`, since `φ(143) = 120 ≠ 142`.
6. **Two wrong forms of Theorem C's mean.**

## 7. Controls

| control | status |
|---|---|
| **Instrument validation is INDEPENDENT of the code under test** | ✅ 12 408 checked, 0 disagreements, **nonzero = 8** (non-vacuous) |
| **Closed form verified per-cell, never pooled alone** | ✅ **max abs dev 0.0 over 72 cells** |
| **A detector that cannot fire is not a detector** | ✅ root count **varies** in 34/72 cells, both values seen ⩾ 20 times |
| **Negative control** | ✅ a deliberately wrong prediction mismatches on 31% of cases |
| **Even-`k` arm agrees** | ✅ all 265 rows |
| **Determinism** | ✅ `e1_threshold`, `e6_gain`, `e12_symmetry` each run twice, stdout+JSON bit-identical |
| **Factor-blindness** | ✅ conditions receive only `(b, n)`; `core.assert_factor_blind` retained |

## 8. What is NOT claimed

- **Not a closure of all constructions.** The law is about `2`-power-index subgroup
  conditions. Non-monotone, `Jacobi(b²−c/n)`, and order-based conditions are
  **untouched, not refuted**.
- **The hardness direction of (H) is not proved.** Whether `ψ₃(n,b)` is computable
  in `poly(log n)` without factoring `n` is the obstruction that is actually real,
  and it is a hardness claim this round does not settle.
- **Literature:** arXiv returned empty on two query forms, so **no arXiv
  identifier is cited anywhere in this work.** zbMATH returned 404. Three Crossref
  references were verified **bibliographically only** — no claim is made about
  their contents and none is used in any proof.

## 9. Reproduce

```
cd factor-scratch/r55exp/kernel
python3 e1_threshold.py     # Theorem B: 246 360 exhaustive triples
python3 e6_gain.py          # Theorem C: e-neutrality, GAIN = 1
python3 e12_symmetry.py     # character characterisation
python3 characterize.py     # the invariant space
```

All seeded, all byte-identical across two runs. Dependencies: Python 3.12, `sympy`.
**The non-injectivity check in §5 is a 20-line brute force over one modulus and is
reproducible inline.**