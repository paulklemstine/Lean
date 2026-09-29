# ROUND 47 — the single entry point

**Read this, then follow the links. Do NOT read the `Round47_*` files in order: they were
written in the order they were believed, and several are wrong in the ways their banners
record.**

Round 47, 2026-09-29. 38 commits, 21 notes, **4 new Lean files / 40 theorems, 0 `sorry`,
0 `axiom`**. It opened a direction the previous 46 rounds had not touched, closed it
rigorously, and — in the process — found that **two of the three "live directions" the earlier
record asserted do not exist**.

---

## 1. What round 47 established

### 1.1 A correct characterisation, for the full cubic

For the **cubic** number field sieve in Lee–Venkatesan's *square-relation* framework, the
relations are **the rational points of an explicit genus-1 curve** with an explicit Jacobian
and an explicit quadratic character:

> `C : y² = 4t⁴ + 8mt³ − 2Pt² + (2mP + 4Q)t + (P²/4 − mQ)`, valid for `f = X³ + PX + Q`.
> `Jac = E : Y² = V² + UW`, `U = 2X − 2m² − P`, `V = mX + mP/2 + Q`, `W = X²/2 − P²/8 + mQ/2`,
> reducing **exactly** to `Y² = x³ − 3mcx + c² + m³c` at `P = 0`.
> `chi_P = Jacobi(C(t)·y, N)` — **Lee–Venkatesan's own definition, p. 38. No novelty claimed.**

Twelve relations independently confirmed genuine in `ℤ[α]` exactly, with no leakage.
→ `Round47_EllipticReduction.md`, `Round47_GeneralCubic.md`, `Round47_Audit.md` (D7, D8).

### 1.2 The dimensional closure — the deepest result

Requiring `h(α) = g²` costs `d−2` dimensions, leaving a **curve for every `d`**:

| `d` | no square condition | with `h(α) = g²` | genus of the relation curve (generic) |
|---|---|---|---|
| 3 | 3 | **1** | 1 |
| 4 | 4 | **1** | **5** |
| 5 | 5 | **1** | 17 |
| 6 | 6 | **1** | 49 |

> **The constraint that makes the relation space analysable is the constraint that makes it
> thin. You cannot have one without the other.**

The ordinary NFS never pays it — it asks a *combination* of relations to have square norms,
handled by GF(2) linear algebra. **The genus is the generic value; there is an exception
locus** (see `Round47_FunctionField.md` §8.2). → `Round47_DimensionalClosure.md`,
`Round47_DegreeBarrier.md`.

### 1.3 THE SHARPEST SENTENCE OF THE ROUND — a diagnosis, not a closure

> **Round 47's collapse is caused by the *rationality filter*, not by the geometry being
> hard.**

Same curve, same `φ`, same `d=4`: `#Ŷ₄(F₇) = 8`, `#Ŷ₄(F₃₁) = 32` over finite fields, while
the integer curve gave **1 relation in 38 instances** — a factor of ~2000. The genus is not
what hurts; **needing ℚ-points when the curve has almost none is.** A future attack could
target exactly that. → `Round47_FunctionField.md`.

### 1.4 The synthesised statement about the project

Conjecture 7.1 is **the price of rigour, paid twice**: once in the relation space (`d → 1`,
a curve of growing genus) and once in running time (the rigorous `L[1/3]` is **224.4 dex
behind** the heuristic at 2048 bits, and a true `1/6` *widens* the gap). **The standard GNFS
has no Conjecture 7.1 precisely because it is not rigorous.** → `Round47_PriceOfRigour.md`.

---

## 2. The machine-checked results (the project's own standard: 0 `sorry`)

| file | what it establishes |
|---|---|
| `DimensionalClosure.lean` | the cone is rational for **every** `P`; the components of `g²`; `A(ku,kv) = k⁴A(u,v)` — the homogeneity **is** "the relation space is a curve" |
| `RelationWitness.lean` | **`N² ∣ disc(E)`**, an identity over ℤ; and the record's **hand-verified witness**, now discharged by `decide` |
| `RelationAlgebra.lean` | `l(m) = A(u,v)`, `Norm(g) = v⁶B(u,v)`, and the Jacobian reduction `V²+UW = x³ − 3(mc)x + c² + m³c` |
| `DegreeFour.lean` | the `d=4` cone is **two** quadrics and is **strictly stronger** than `d=3`; the agent's `d=4` witness, checked |

**The checker earned its keep more than the mathematics did.** It caught, across four files: a
factor-4 error; a `u²v²`→`uv²` slip; two sign errors in the `d=4` component formulas (where
`decide` reported the *agent's* hand-computed witness **false against my transcription** — so
the agent was right and I was wrong); a swapped pair of gcds; a false "d=3 is a slice of d=4"
theorem; a false "jacobian is cubic" theorem I had added to round a file out; and an identity
that is **not true over ℤ at all** because `/` there is truncated division. **The `d=4` Lean
file validated the agent against me three times.**

⚠️ **Toolchain caveat, because these files claim to be machine-checked:** the project's Mathlib
is **not built** on this host (4.28.0, packages present, no oleans). All four were type-checked
against a **prebuilt Mathlib at Lean 4.30.0 from another workspace**. Every proof is `ring` or
`decide` over ℤ or ℚ and is version-independent — **but none has been compiled by the project's
own toolchain.** One `lake build` away on a machine with the cache.

## 3. Every claim retracted this round (all mine)

| claim | why it died |
|---|---|
| **"12/12 factors recovered"** | **VOID as a factoring result.** `ellrank`'s 2-descent needs the discriminant factored, and `disc = −27c²(m³−c)²` with `N ∣ (m³−c)` — **it factors `N` to do it.** Matched-twin control: same coefficient size, smooth vs hard discriminant, **0.02 s vs timeout >300 s**. |
| "decidable failures, decided by a basis" | **false.** `chi_P` is **not** a homomorphism on `E(Q)` (39/1243; 3 of 15 instances). The Jacobian transports the *curve* law, not multiplication of relations. |
| `C(t)A(t)` square-class criterion | **refuted**, 13/24. Non-trivial on `Q(E)` does not imply non-trivial on the thin subset `E(Q)`. |
| CLAIM 47: rank > 0 ⟹ `chi_P = −1` | **refuted**. Rank 0 in 10%; `chi⁻¹(−1)` is not Zariski-open. |
| "you cannot choose the field at scale" | **my error.** 15 hits against 0.001 predicted; `Q` is naturally small for `m ≈ N^{1/3}`, and NFS uses **lattice reduction** anyway. |
| the `L`-pricing ("2.5e35", "31× worse") | **an exponent printed as a value.** `L_N[1/3,1]` at `N=10²⁰` is **6464**, matching the record's own `B=6463.8`. |
| "rank 1 is only a handful" | `{0:2, 1:119, 2:247, 3:110, 4:30, 5:3}`. Rank 1 is 23%; rank 0 occurs twice. |
| genus as an identity for all `(c,m)` | **generic value only**; 18 good-prime exception loci. |
| a spurious `−2Pt²` removal | the term is real and vanishes only at `P=0`. |

## 4. Corrections to the previous record

- **§2 "THE LIVE DIRECTION" is VOID.** Kaltofen–Kurban–Lenstra IPL 80 (2001) 57–64 **does not
  exist** (complete Crossref deposit: pp. 57–64 occupied by two process-algebra papers). **And
  the axis is closed anyway**: arXiv:2504.08063 — *"no efficient deterministic algorithms are
  known even for the seemingly easier problem of factoring sparse polynomials"*. Best bound:
  `poly(n, s^{d² log n})`, **quasi-polynomial**. **A phantom for 46 rounds.**
- **§7b misquotes Remark 7.3** — conditioned on `p,q` **not** both `≡3 mod 4`, the excluded case.
- **The real missing lemma, LV p. 26 verbatim**: *"much stronger versions of the Chebotarev
  Density Theorem might be required"* — **Chebotarev-strength *joint* character decorrelation**,
  about the *character* approach (Adleman, Bühler–Lenstra–Pomerance), not GF(2) linear algebra.
- **GNFS constant.** `1.923` is correct, **derived**, and does not move: Montgomery EUROCRYPT'95
  p.118 gives `O(dn²/N) + O(n²)` and the `O(n²)` **independent of `N`** *is* the constant; and
  a polylog win is swallowed by the `(1+o(1))` (arXiv:2006.06197 p.4). The `ω=2` floor is
  `0.96150`, half of `1.92300`. **LV's Theorem 2.3 is `1.92299`; the `1.90188` is a separate
  *asserted* Coppersmith-MPS extension remark** — read off a page image, because `pdftotext`
  mangles both.
- **~10 further phantoms**, most of them mine. Also **arXiv:2010.01250 is "CorrAttack"**, and
  **arXiv:1608.08766 is Hittmeir _solo_** — the "Harvey &" was the fabrication.
- **`g(C_3) = 1` is wrong** — a conic has genus 0.
- **A7's `r = 2^{d−1}` point-count control is invalid** (a 0-dim scheme needn't be `F_p`-split);
  the degree is right by Bézout.

## 5. The auxiliary-information axis — mined for the first time in 47 rounds

The brief's scope includes *"the adjacent partial-key literature"*; the record cited **zero**
papers in it. Now:

- **The `1/4` is not a quarter of the bits.** It is a fraction of `log N` — of the *interval
  containing* `p` — which is **half the bits of `p`** (Herrmann–May, ASIACRYPT 2008, p. 3).
- **Random, non-contiguous bits are NOT a weaker case** — the bound holds *"no matter how the
  size of the unknowns are distributed"*. **My premise was refuted.**
- **The barrier is running time, not threshold**: threshold `ln 2 ≈ 0.6931` of the bits, but
  the lattice dimension *"grows exponentially in `n`"*, so it is polynomial only for
  `n = O(log log N)`. Assumption 1 (algebraic independence) *"did not hold in general"*.
→ `Round47_AuxiliaryInformation.md`.

## 6. The frontier

| | item | status |
|---|---|---|
| 1 | beat the GNFS **heuristic** | **closed** for the linear-algebra route, two independent ways |
| 2 | a **rigorous `L[1/3]`** | **open**; `1.92299`; worth **224 dex less** than the heuristic |
| 3 | **auxiliary-information factoring** | open; the barrier is the lattice, not the threshold |
| 4 | the **FFS** | not the DLP one; no congruence-of-squares step, and its relations are *not* points of `Ŷ_d` |

⚠️ **One open question could undo §1.4.** In the **standard** GNFS the sign problem is
resolved by GF(2) linear algebra with a `3/4`-non-triviality count on a **thick** space. **If
that is rigorous**, LV's Conj 7.1 is an artefact of their framework and 46 rounds chased the
wrong obstruction.

## 7. The rules earned

> **A search that fails is not a barrier until the method that would succeed has been tried.**

> **A control that only runs at the parameter you derived it at is not a control.**

> **Render the page.** `pdftotext` changed a conclusion **three** times today, once by dropping
> a cube root *and* a square root in the same display.

> **Write the self-test — and on this corpus, machine-check it.** It caught **five of my own
> errors and zero of the record's**, and on the `d=4` file it validated an agent's hand
> computation against mine and was right.
