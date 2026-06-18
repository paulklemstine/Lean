                # MATHEMATICAL RESEARCH MISSION: Tropical weight enumerator profiles for binary linear codes via Smooth Poincaré primitives

                ## Objective / Task Brief:
                Create a team to research this mathematical direction. Brainstorm new hypotheses, run experiments, analyze results, take notes, iterate. Combine all the researchers' findings into clean, verified Lean 4 files, and then brainstorm a list of the next research directions.

                ## Deliverables & Acceptance Criteria:
                1. **Lean 4 Proofs**: Fully verified, compiling Lean 4 files under the appropriate Catalog directory. Main theorems must be fully proved (0 sorries).
                2. **Lab Notes**: Include inline comment blocks (`-- !-- Lab Notes -- !--`) in the Lean files detailing your hypotheses, experimental outcomes, insights, and failure analysis.
                3. **FUTURE_DIRECTIONS.md**: Outlining 3-5 bold, testable mathematical conjectures for follow-up cycles based on your combined findings.

                ## Constraints (Strictly Enforced):
                - **NO prose or documentation articles**: Do NOT output ARTICLE.md, RESEARCH_PAPER.md, python algorithms, HTML widgets, or PACKAGE.json. Focus 100% of your compute on standard Lean 4 code and proofs.

                ## Context & Resources:
                - Domain: Applications
                - Existing Catalog References: Applications/SmoothPoincare/TopologicalCodes.lean, Applications/SmoothPoincare/CodeDirectSum.lean, Applications/SmoothPoincare/MinimumDistance.lean, Applications/SmoothPoincare/SelfDualLength.lean, Applications/SmoothPoincare/GleasonLength.lean, Bridges/CategoricalTropicalUltrametric.lean

### Catalog Context
@Applications/SmoothPoincare/TopologicalCodes.lean
```lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Topological error-correcting codes: the mod-2 shadow of even unimodular forms

The catalog's `SmoothPoincare` files build the *lattice* side of the smooth/topological
gap in dimension 4: the **even unimodular** intersection form `E8` (rank `8`), its
self-sum `E8 ⊕ E8` (rank `16`), and the Donaldson obstruction
`even_not_stdDiagonalizable`.  A recurring miracle there is the number **8**: even
unimodular *definite* lattices exist only in rank divisible by `8`, with `E8` the
minimal witness.

This file develops the **coding-theory shadow** of exactly that phenomenon.  Reducing
a unimodular even lattice modulo `2` (Construction A in reverse) produces a *binary
self-dual code*; the evenness of the form becomes the **doubly-even** condition (all
codeword weights divisible by `4`).  The combinatorial analogue of "rank divisible by
`8`" is "length divisible by `8`", and the minimal witness — the shadow of `E8` — is
the **extended Hamming code** `[8,4,4]`, the Reed–Muller code `RM(1,3)`.

We prove, fully `sorry`-free:

* `wt_add_overlap` — the Hamming inclusion–exclusion identity
  `wt(x+y) + 2·overlap(x,y) = wt x + wt y`, the combinatorial heart everything rests on.
* `doublyEven_selfOrthogonal` — **the bridge theorem**: any two codewords of weight
  divisible by `4` are orthogonal.  This is the binary mirror of "an even form has even
  diagonal" (`even_diag_of_isEven` / `isEven_of_even_diag` in `IntersectionForms`): a
  doubly-even code is automatically self-orthogonal.
* `hamming_doublyEven` — the extended Hamming code has all weights divisible by `4`
  (the code-side analogue of `E8_even`).
* `hamming_add_closed` / `hamming_selfOrthogonal` — closure under `+` and, via the
  bridge theorem, self-orthogonality (the analogue of `E8`'s self-duality / Donaldson
  evenness obstruction), obtained *without* a brute-force pairwise check.
* `hamming_length_div_four` — every codeword length-`8` constraint: the all-ones word
  lies in the code and has weight `8`, divisible by `4` (the code-side echo of the
  signature divisibility behind Rokhlin/Donaldson).

## References
* J. H. Conway, N. J. A. Sloane, *Sphere Packings, Lattices and Groups* (Construction A,
  Chapter 7): even unimodular lattices ↔ doubly-even self-dual codes.
* F. J. MacWilliams, N. J. A. Sloane, *The Theory of Error-Correcting Codes*.

-- !-- Lab Notebook -- !--
Hypothesis: the rank-divisible-by-8 obstruction governing even unimodular lattices
  (catalog `E8form`, `E8_even`, `even_not_stdDiagonalizable`) has a verbatim
  coding-theory shadow: doubly-even ⟹ self-orthogonal, with the extended Hamming
  `[8,4,4]` code as the mod-2 image of `E8`.
Result: all five headline theorems proved `sorry`-free.  `doublyEven_selfOrthogonal`
  is the load-bearing bridge; the explicit Hamming code's properties then follow by a
  cheap `decide` on its 16-element generator image plus the bridge theorem.
Insight: evenness/double-evenness is governed by a single divisibility identity
  (`wt_add_overlap`), exactly as form-evenness is governed by the diagonal
  (`isEven_of_even_diag`).  Self-orthogonality is then *derived*, never checked
  pairwise, mirroring how `E8`'s obstruction is derived from `E8_even`.
Failure analysis: the only subtlety is ℕ-subtraction in inclusion–exclusion; stating
  the identity additively (`wt(x+y) + 2·overlap = wt x + wt y`) and passing to ℤ for
  the divisibility step avoids it entirely.
-/

import Mathlib
-- ... (truncated, full file has 202 lines)
```

@Applications/SmoothPoincare/CodeDirectSum.lean
```lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Direct sums (concatenation) of binary self-dual codes

This file is the **coding-theory mirror** of
`Catalog.Applications.SmoothPoincare.DirectSum`, where the orthogonal direct sum
`Q ⊕ R` of intersection forms is shown to be *closed* under the three structural
predicates (`Unimodular`, `IsEven`, `StdDiagonalizable`), with headline `E8 ⊕ E8`.

Under Construction A the orthogonal direct sum of even unimodular lattices reduces,
modulo `2`, to the **direct sum (coordinate concatenation)** of binary self-dual
codes.  This file develops that operation `C ⊕ D ⊆ (ZMod 2)^{m+n}` and proves the
exact code-side analogues of the lattice closure theorems:

* `wt_append` / `ip_append` — weight is *additive* and the binary inner product is
  *block-diagonal* under concatenation (the combinatorial shadow of the block-diagonal
  Gram matrix `diag(G_Q, G_R)`).
* `appendCode_card` — `|C ⊕ D| = |C|·|D|` (the code shadow of `det` multiplicativity
  used in `directSum_unimodular`).
* `appendCode_doublyEven` — double-evenness is closed under `⊕` (shadow of
  `directSum_isEven`).
* `appendCode_selfDual` — **the headline closure theorem**: self-duality is closed
  under `⊕` (the code shadow of `directSum_unimodular`, Poincaré self-duality being
  preserved by connected sum).
* `appendCode_length_div_eight` — Gleason length divisibility is *additive*: the direct
  sum of two doubly-even self-dual codes again has length divisible by `8`.

The headline application is `hamming ⊕ hamming`, the length-`16` direct sum of two
copies of the extended Hamming `[8,4,4]` code — the precise mod-2 shadow of the
rank-`16` lattice `E8 ⊕ E8` (`DirectSum.E8E8form`).  It is self-dual, doubly even, has
`256 = 16·16` codewords, and length `16` divisible by `8`, all *derived* from the
general closure theorems rather than by a brute-force `decide` over `2^16` vectors.

## References
* J. H. Conway, N. J. A. Sloane, *Sphere Packings, Lattices and Groups* (Construction A).
* F. J. MacWilliams, N. J. A. Sloane, *The Theory of Error-Correcting Codes*.

-- !-- Lab Notebook -- !--
Hypothesis: the lattice direct-sum closure theorems of `DirectSum.lean` (Unimodular,
  IsEven, StdDiagonalizable closed under `⊕`) have verbatim coding-theory shadows under
  coordinate concatenation, with `hamming ⊕ hamming` the mod-2 image of `E8 ⊕ E8`.
Result: all closure theorems (`appendCode_selfDual`, `appendCode_doublyEven`,
  `appendCode_card`) proved `sorry`-free for arbitrary lengths; `hamming ⊕ hamming`
  shown self-dual + doubly-even of length 16 with 256 codewords, with `8 ∣ 16` recovered
  via Gleason rather than by `native_decide` over `2^16` vectors.
Insight: concatenation makes weight additive and the inner product block-diagonal, so
  self-orthogonality is transparent; the only content of the *backward* self-duality
  direction is that a self-dual code contains `0`, letting one probe each block
  independently via `append a 0` and `append 0 b`. This is the exact mirror of the
  block-diagonal `Tᵀ G T` argument in `directSum_stdDiagonalizable`.
Failure analysis: the `Fin (m+n)` index split is handled entirely by
  `Fin.sum_univ_add`, `Fin.append_left/right`, and `Fin.append_castAdd_natAdd`, with no
  explicit index arithmetic — the code analogue of routing the lattice proof through
  `finSumFinEquiv` / `submatrix_mul_equiv`.
-/

import Mathlib
import Catalog.Applications.SmoothPoincare.GleasonLength
-- ... (truncated, full file has 241 lines)
```

@Applications/SmoothPoincare/MinimumDistance.lean
```lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Minimum distance, the weight enumerator of `[8,4,4]`, and self-dual ⟹ even weights

Companion to `Catalog.Applications.SmoothPoincare.SelfDualLength`.  Where that file
extracts a *global length* invariant from the local bridge theorem, this file extracts
the *distance spectrum* — the combinatorial avatar of the "fine arithmetic" that
distinguishes smooth structures (catalog Research Direction 3).

Contents (all `sorry`-free):

* `selfDual_even_weight` — **general theorem**: in any binary *self-dual* code every
  codeword has *even* weight.  This is the unconditional companion of the doubly-even
  hypothesis used in `SelfDualLength`: `ip x x = (wt x mod 2)`, and self-duality makes
  `ip x x = 0`.  (Lattice shadow: a unimodular *even* form has even diagonal.)
* `hamming_minDist_lower` / `hamming_minDist_attained` — the **minimum distance is 4**:
  every nonzero codeword has weight `≥ 4`, and weight `4` is attained.  Together these
  pin the parameters `[n=8, k=4, d=4]` of the extended Hamming code.
* `hamming_weightEnum_0/4/8` — the **complete weight enumerator** `1 + 14·x⁴ + x⁸`:
  exactly `1` word of weight `0`, `14` of weight `4`, `1` of weight `8`, accounting for
  all `16` codewords.  This is the explicit MacWilliams-self-dual weight polynomial of
  the mod-2 shadow of `E8`.

-- !-- Lab Notebook -- !--
Hypothesis: the catalog's `hamming` code, being the mod-2 shadow of `E8`, should carry
  a sharp `[8,4,4]` distance spectrum whose weight enumerator is the order-8
  Gleason-invariant polynomial `1 + 14x⁴ + x⁸`; and self-duality alone (no double
  evenness) should already force even weights.
Result: `selfDual_even_weight` proved generally; the `[8,4,4]` parameters and the full
  weight enumerator `1 + 14x⁴ + x⁸` proved by `native_decide`, accounting for all 16
  codewords (`1 + 14 + 1 = 16`).
Insight: the diagonal pairing `ip x x` collapses to `wt x mod 2` because `t² = t` in
  `ZMod 2`; self-duality then *is* the statement that this diagonal vanishes — the exact
  code-side mirror of "even diagonal" on the lattice side.  The weight enumerator being
  supported only on `{0,4,8}` is the finite fingerprint that the next cycle should test
  against rank-16 lattice pairs (`E8⊕E8` vs `D16⁺`).
Failure analysis: `Finset.min'`/`inf'` definitions of minimum distance drag in
  nonemptiness side-goals; stating the spectrum as a lower bound + attainment pair sides
  steps this entirely and is strictly more informative.
-/

import Mathlib

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {n : ℕ}

/-! ## Core definitions (self-contained mirror of `TopologicalCodes`) -/

/-- **Hamming weight**: the number of nonzero coordinates of a binary vector. -/
def wt (v : Fin n → ZMod 2) : ℕ := (Finset.univ.filter (fun i => v i = 1)).card

/-- **Overlap**: the number of coordinates where both vectors equal `1`. -/
def overlap (x y : Fin n → ZMod 2) : ℕ :=
  (Finset.univ.filter (fun i => x i = 1 ∧ y i = 1)).card
-- ... (truncated, full file has 193 lines)
```

@Applications/SmoothPoincare/SelfDualLength.lean
```lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Self-dual doubly-even codes have length divisible by 4 (and the all-ones glue)

This file is the *local-to-global* sequel to
`Catalog.Applications.SmoothPoincare.TopologicalCodes`.  There, the headline
`doublyEven_selfOrthogonal` shows that double-evenness *forces* pairwise
orthogonality — the coding-theory shadow of "an even form has even diagonal"
(`SmoothPoincare.IntersectionForm.even_diag_of_isEven`).  Here we turn that *local*
(per-pair) datum into a *global* divisibility constraint on the whole code.

The lattice-side miracle is the integer `8`: positive-definite even unimodular
lattices exist only in rank divisible by `8` (`E8` minimal).  Its code shadow is the
length divisibility of doubly-even self-dual codes.  We prove, fully `sorry`-free, the
clean **mod-4** half of that story for *arbitrary* `n`:

* `selfDual_doublyEven_length_div_four` — **the global theorem**: any binary code
  `C ⊆ (ZMod 2)ⁿ` that is *self-dual* (`x ∈ C ↔ x ⟂ C`) and *doubly even*
  (`4 ∣ wt v` for all `v ∈ C`) has length `4 ∣ n`.

The proof is a textbook *local-to-global* / "glue at the all-ones section" argument:
double-evenness makes every codeword have *even* weight, so the constant all-ones
vector `𝟙` is orthogonal to every codeword (`ip_ones`), hence lies in the dual = `C`;
being a codeword it is itself doubly even, and `wt 𝟙 = n`, giving `4 ∣ n`.

We then *instantiate* this on the extended Hamming code `[8,4,4]` (the mod-2 shadow of
`E8`), proving it is genuinely self-dual (`hamming_selfDual`) and recovering
`4 ∣ 8` as a corollary of the general theorem rather than by direct computation —
mirroring how `E8`'s obstruction is *derived* from `E8_even`, not checked by hand.

-- !-- Lab Notebook -- !--
Hypothesis: the per-pair bridge `doublyEven_selfOrthogonal` (a *local* statement)
  should upgrade to a *global* length-divisibility theorem by evaluating the dual at
  the canonical all-ones "global section", exactly as even unimodular lattices force
  rank divisibility through their distinguished vectors.
Result: `selfDual_doublyEven_length_div_four` proved for arbitrary `n`, `sorry`-free,
  and the extended Hamming code shown self-dual (`hamming_selfDual`) so that `4 ∣ 8`
  drops out as `hamming_length_div_four_general`.
Insight: self-duality is the local-to-global glue.  "Doubly even" is a *local* (weight)
  predicate; "self-dual" says the dual sheaf of orthogonality conditions has a global
  section through every point of `C`; the all-ones vector is the obstruction class whose
  membership forces `4 ∣ n`.  The mod-8 (Gleason) refinement is the genuinely harder,
  weight-enumerator/invariant-theory step left to FUTURE_DIRECTIONS.
Failure analysis: the only friction is the ℕ→ZMod 2 cast of `wt`; routing the parity
  through `ZMod.natCast_eq_zero_iff` and `dvd_trans (by norm_num : (2:ℕ) ∣ 4)` keeps the
  whole argument linear.
-/

import Mathlib

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {n : ℕ}

/-! ## Core definitions (self-contained mirror of `TopologicalCodes`) -/
-- ... (truncated, full file has 194 lines)
```

@Applications/SmoothPoincare/GleasonLength.lean
```lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Gleason's length theorem: doubly-even self-dual codes have length divisible by 8

This file proves the **mod-8 refinement** that the catalog's
`Catalog.Applications.SmoothPoincare.SelfDualLength` explicitly leaves as the
"genuinely harder, weight-enumerator/invariant-theory step":

* `SelfDualLength.selfDual_doublyEven_length_div_four` shows a binary doubly-even
  self-dual code has length divisible by **4**.
* Here, `doublyEven_selfDual_length_div_eight` upgrades this to divisibility by **8**
  — the sharp constant, mirroring the lattice-side miracle that positive-definite even
  unimodular lattices exist only in rank divisible by `8` (`IntersectionForms.E8form`,
  `E8_even`, `even_not_stdDiagonalizable`).

The proof is the classical **Gauss-sum / MacWilliams** argument, formalized from
scratch over `ℂ`:

1. `csgn` is the multiplicative character `a ↦ (-1)^a` of `(ZMod 2, +)`, and
   `bchar x c = ∏ⱼ (-1)^(xⱼ·cⱼ) = (-1)^⟨x,c⟩`.
2. `char_orthogonality` — for a self-dual (hence linear) code `C`,
   `∑_{c∈C} (-1)^{⟨x,c⟩} = |C|` if `x ∈ C` and `0` otherwise (the standard
   "non-trivial character sums to zero" argument via the involution `c ↦ c + c₀`).
3. `fourier_iwt` — the per-coordinate factorization of the discrete Fourier transform
   of `x ↦ Iᵂᵗ⁽ˣ⁾` gives `∑ₓ Iᵂᵗ⁽ˣ⁾ (-1)^{⟨x,y⟩} = (1+I)^{n-wt y}(1-I)^{wt y}`,
   which collapses to `(1+I)ⁿ` when `y` is doubly even (since `1-I = -I·(1+I)` and
   `(-I)^{wt y} = 1`).
4. Evaluating the double sum `∑ₓ Iᵂᵗ⁽ˣ⁾ ∑_{c∈C} (-1)^{⟨x,c⟩}` two ways yields the
   master identity `(|C| : ℂ) = (1+I)ⁿ`.
5. Since `|C|` is a positive **real** number while `(1+I)⁴ = -4` and `(1+I)⁸ = 16`,
   positivity forces `n ≡ 0 (mod 8)`.

-- !-- Lab Notebook -- !--
Hypothesis: the mod-4 length theorem of `SelfDualLength` is not sharp; the true
  obstruction is mod 8 (Gleason), and it should follow from a self-contained Gauss-sum
  evaluation of `∑_{c∈C} I^{wt c}` rather than from full invariant theory.
Result: `doublyEven_selfDual_length_div_eight` proved `sorry`-free for arbitrary `n`,
  via the master identity `(|C| : ℂ) = (1+I)ⁿ` and the sign analysis `(1+I)⁴ = -4`.
Insight: self-duality is exactly the hypothesis that makes the code a *linear* subgroup
  on which character orthogonality holds; double-evenness is exactly what makes the
  MacWilliams transform value collapse from `(1+I)^{n-w}(1-I)^w` to `(1+I)ⁿ`. The two
  catalog predicates conspire to pin the complex number `|C|` onto the positive real
  axis of the `(1+I)`-tower, whose period is `8`.
Failure analysis: ℕ-subtraction in the exponent `n - wt y` is tamed by the algebraic
  identity `1 - I = (-I)·(1+I)`, turning `(1+I)^{n-w}(1-I)^w` into `(1+I)ⁿ·(-I)^w`
  with no truncated subtraction surviving into the final step.
-/

import Mathlib
import Catalog.Applications.SmoothPoincare.SelfDualLength

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {n : ℕ}

-- ... (truncated, full file has 303 lines)
```

@Bridges/CategoricalTropicalUltrametric.lean
```lean
/-
  # Categorical Tropical–Ultrametric Equivalence
  ## via Valuation Reconstruction and Functorial Bound Transfer

  Bridge: connects tropical algebra ↔ ultrametric analysis ↔ certified robustness ↔
  post-quantum lattice-style metrics.

  **Core principle**: tropical valuation data on an ordered idempotent semiring can be
  reconstructed into an ultrametric seminorm, and quantitative bounds proven in the
  tropical world transfer functorially to ultrametric certified bounds relevant to
  quantum/cryptographic/ML settings.

  The most important mathematical message: **valuation reconstruction is not just a
  dictionary — it is a quantitative functor**.
-/

import Mathlib

open Function

noncomputable section

namespace CategoricalTropicalUltrametric

/-! ## §1. Tropical Valuation Objects

Bridge: connects tropical algebra to ultrametric geometry and certified robustness. -/

/-- A tropical valuation object: a linearly ordered additive-idempotent commutative monoid
    with a compatible multiplicative structure. The key axiom `add_eq_max'` encodes the
    tropical "addition = max" principle. -/
structure TropicalValuationObject (R : Type u) where
  le : R → R → Prop
  le_refl : ∀ a, le a a
  le_antisymm : ∀ {a b}, le a b → le b a → a = b
  le_trans : ∀ {a b c}, le a b → le b c → le a c
  le_total : ∀ a b, le a b ∨ le b a
  zero : R
  one : R
  add : R → R → R
  mul : R → R → R
  max_op : R → R → R
  add_eq_max' : ∀ a b, add a b = max_op a b
  max_comm : ∀ a b, max_op a b = max_op b a
  max_assoc : ∀ a b c, max_op (max_op a b) c = max_op a (max_op b c)
  max_idem : ∀ a, max_op a a = a
  max_le_left : ∀ a b, le a (max_op a b)
  max_le_right : ∀ a b, le b (max_op a b)
  max_least : ∀ {a b c}, le a c → le b c → le (max_op a b) c
  mul_comm : ∀ a b, mul a b = mul b a
  mul_assoc : ∀ a b c, mul (mul a b) c = mul a (mul b c)
  mul_one : ∀ a, mul a one = a
  mul_zero : ∀ a, mul a zero = zero
  add_zero : ∀ a, add a zero = a

/-- Bundled tropical valuation object. -/
structure TropObj where
  α : Type u
  trop : TropicalValuationObject α

-- ... (truncated, full file has 890 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


                ## RESEARCH CORE METHODOLOGY:
1. **Catalog Leverage**: Examine existing catalog theorems carefully. Your theorems should extend, generalize, or connect catalog results.
2. **Pure Math Focus**: Focus 100% of your compute on standard Lean 4 definitions, lemmas, and theorems. Prove non-trivial math that represents genuine progress.
3. **Falsifiable Conjectures**: Formulate precise conjectures in FUTURE_DIRECTIONS.md to guide future research cycles.

### Perpetual Scientific Iteration (do not stop at first synthesis)
When the research team comes together with results, do not stop. Treat the synthesized findings as the next problem statement and immediately run the full scientific-method loop again: hypothesize, experiment, review, synthesize, critique. Repeat this cycle continuously within the available context window, refining, deepening, and cross-checking until forced to emit output. Use Aristotle to its fullest.

