                # MATHEMATICAL RESEARCH MISSION: Functorial tropical valuation profiles of topological CSS codes via Smooth Poincaré intersection primitives

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
                - Existing Catalog References: Applications/SmoothPoincare/TopologicalCodes.lean, Applications/SmoothPoincare/IntersectionForms.lean, Applications/SmoothPoincare/TropicalWeightEnumerator.lean, Applications/SmoothPoincare/CodeDirectSum.lean, Bridges/CategoricalTropicalUltrametric.lean

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

@Applications/SmoothPoincare/IntersectionForms.lean
```lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Intersection Forms, Donaldson's Obstruction, and the Smooth 4D Poincaré Story

The smooth 4-dimensional Poincaré conjecture — *is every smooth 4-manifold homotopy
equivalent to `S⁴` diffeomorphic to `S⁴`?* — remains open.  The entire subject is
governed by **Donaldson's diagonalization theorem**: the intersection form of a
smooth, closed, simply-connected, positive-definite 4-manifold is *standard*, i.e.
diagonalizable over `ℤ` to `⟨1⟩ⁿ`.  This places a sharp gauge-theoretic restriction
that topology alone (Freedman's classification) does not see, and is exactly the
mechanism that distinguishes smooth from topological 4-manifolds.

This file formalizes the **algebraic heart** of that mechanism in a fully verified,
`sorry`-free way:

* `IntersectionForm n` — a symmetric integral Gram matrix (the cup-product pairing on
  `H²`), with predicates `Unimodular` (Poincaré duality), `IsEven` (spin), and
  `StdDiagonalizable` (Donaldson's conclusion).

* `even_not_stdDiagonalizable` — **the obstruction**: a positive-rank *even* form can
  never be diagonalizable to the standard form `⟨1⟩ⁿ`.  This is the algebraic engine
  behind Donaldson's theorem: it forces a smooth definite manifold's form to be odd.

* The `E8` form — even, unimodular, positive-definite, rank `8` — and the corollary
  `E8_not_stdDiagonalizable`.  Combined with Donaldson's theorem (the deep analytic
  input), this says **`E8` is not the intersection form of any smooth closed
  simply-connected 4-manifold**, even though Freedman realizes it *topologically*.
  This is the cleanest known witness of the smooth/topological gap in dimension 4.

* `stdForm_not_even` — boundary case showing evenness is essential.

* `sphereForm` — the trivial (rank-`0`) form of `S⁴`, unimodular, even, and standard,
  illustrating that homological data alone cannot distinguish smooth structures.

## References
* S. K. Donaldson, *An application of gauge theory to four-dimensional topology* (1983).
* M. Freedman, *The topology of four-dimensional manifolds* (1982).
-/

import Mathlib

open Matrix
open scoped BigOperators

noncomputable section

namespace SmoothPoincare

/-- The intersection form of a closed oriented 4-manifold, modeled as the Gram matrix
of the cup-product pairing on `H²(M;ℤ)/torsion`: a symmetric integer matrix. -/
structure IntersectionForm (n : ℕ) where
  /-- The Gram matrix of the symmetric bilinear pairing. -/
  gram : Matrix (Fin n) (Fin n) ℤ
  /-- The cup-product pairing is symmetric. -/
  isSymm : gram.IsSymm

namespace IntersectionForm

-- ... (truncated, full file has 226 lines)
```

@Applications/SmoothPoincare/TropicalWeightEnumerator.lean
```lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tropical weight enumerator profiles for binary linear codes

This file develops the **tropical shadow** of the classical weight enumerator that the
catalog's `SmoothPoincare` code files (`TopologicalCodes`, `CodeDirectSum`,
`MinimumDistance`, `GleasonLength`) study over `ℂ`.

The classical (Hamming) weight enumerator of a binary code `C ⊆ (ZMod 2)ⁿ` is the
two-variable polynomial `W_C(x,y) = ∑_{c∈C} x^{n−wt c} y^{wt c}`.  Its single most
important structural property, used implicitly all over `CodeDirectSum`, is that it is
**multiplicative** under the direct sum (coordinate concatenation) of codes:
`W_{C⊕D} = W_C · W_D`.

Tropicalizing — replacing the semiring `(ℝ, +, ×)` by the **min-plus tropical
semiring** `(ℝ, min, +)` of `Bridges/CategoricalTropicalUltrametric` — turns the
generating *sum* `∑` into a *minimum* and the *product* `×` into a *sum* `+`.  The
tropical weight enumerator is therefore the piecewise-linear function

  `twe C t = min_{c ∈ C} (wt c · t)`,

and the multiplicativity `W_{C⊕D} = W_C · W_D` becomes the **tropical additivity**
`twe (C ⊕ D) = twe C + twe D` (`twe_append`), the headline of this file: it is the
exact tropical mirror of `CodeDirectSum.wt_append` (`wt (a ++ b) = wt a + wt b`).

Alongside this, the **minimum distance** of a code is itself a tropical quantity: under
direct sum it behaves like tropical *addition* (a `min`):
`minDist (C ⊕ D) = min (minDist C) (minDist D)` (`minDist_append`), reflecting that the
shortest nonzero codeword of a concatenation lives entirely in one block.

The two together give a clean "tropical dictionary" for the direct-sum operation:

  | classical invariant            | direct-sum law      | tropical reading      |
  |--------------------------------|---------------------|-----------------------|
  | length `n`                     | `n_C + n_D`         | additive              |
  | `|C|`                          | `|C|·|D|`           | log-additive          |
  | weight enumerator `W_C`        | `W_C · W_D`         | `twe` additive        |
  | minimum distance `d`           | `min(d_C, d_D)`     | tropical `min`        |

Finally, instantiating on the catalog's extended Hamming `[8,4,4]` code reveals a
genuine *information-loss* phenomenon: although the classical enumerator is
`1 + 14x⁴ + x⁸` (`MinimumDistance.hamming_weightEnum_*`), the tropical enumerator is
just `twe hamming t = min(0, 8·t)` (`hamming_twe`) — the weight-`4` stratum, i.e. the
minimum distance itself, is **invisible** to the tropical enumerator because `4` is not
a vertex of the convex hull of the weight spectrum `{0,4,8}`.  This is exactly why the
minimum distance must be recorded by the *separate* tropical-min invariant `minDist`.

-- !-- Lab Notes -- !--
Hypothesis: the multiplicativity of the weight enumerator under direct sum
  (`W_{C⊕D}=W_C·W_D`, the engine behind `CodeDirectSum.appendCode_*`) tropicalizes to a
  clean additive law `twe (C⊕D)=twe C+twe D`, and the minimum distance tropicalizes to a
  `min` law `minDist (C⊕D)=min (minDist C) (minDist D)`.
Result: both laws proved `sorry`-free for arbitrary lengths via `Finset.inf'`
  antisymmetry arguments resting only on `wt_append`. Instantiated on `hamming` and
  `hamming16`: `twe hamming = min(0, 8t)` and `minDist hamming = minDist hamming16 = 4`.
Insight 1: `min_{a,b}(f a + g b) = min_a f a + min_b g b` holds for ALL real slopes `t`
  (no sign hypothesis), because the two blocks are independent — this is the tropical
  fingerprint of the factorisation `W_{C⊕D}=W_C·W_D`.
-- ... (truncated, full file has 372 lines)
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

