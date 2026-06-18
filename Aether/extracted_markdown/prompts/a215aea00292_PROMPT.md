                # MATHEMATICAL RESEARCH MISSION: Tropical weight enumerator as a max-plus norm on binary code direct sums

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
                - Existing Catalog References: Applications/SmoothPoincare/TropicalWeightEnumerator.lean, Applications/SmoothPoincare/CodeDirectSum.lean, Applications/SmoothPoincare/SelfDualLength.lean, Applications/SmoothPoincare/TopologicalCodes.lean, Applications/SmoothPoincare/GleasonLength.lean

### Catalog Context
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


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


                ## RESEARCH CORE METHODOLOGY:
1. **Catalog Leverage**: Examine existing catalog theorems carefully. Your theorems should extend, generalize, or connect catalog results.
2. **Pure Math Focus**: Focus 100% of your compute on standard Lean 4 definitions, lemmas, and theorems. Prove non-trivial math that represents genuine progress.
3. **Falsifiable Conjectures**: Formulate precise conjectures in FUTURE_DIRECTIONS.md to guide future research cycles.

### Perpetual Scientific Iteration (do not stop at first synthesis)
When the research team comes together with results, do not stop. Treat the synthesized findings as the next problem statement and immediately run the full scientific-method loop again: hypothesize, experiment, review, synthesize, critique. Repeat this cycle continuously within the available context window, refining, deepening, and cross-checking until forced to emit output. Use Aristotle to its fullest.

