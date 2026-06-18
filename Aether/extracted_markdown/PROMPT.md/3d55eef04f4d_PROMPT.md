            # Phase A Research Mission v17: Weight–Inner-Product Identities for Binary Self-Dual Codes via Smooth Poincaré Infrastructure

            ## Concept
            **Domain**: Applications
            **Research mode**: sorry_fill
            **Title**: Weight–Inner-Product Identities for Binary Self-Dual Codes via Smooth Poincaré Infrastructure
            **Description**: The key insight is that the unfinished Smooth Poincaré code files already contain the exact algebraic primitives needed to turn the code-theoretic notions of weight, overlap, and binary inner product into a small certified theorem package, and that this package can serve as a genuine bridge from the Applications domain to the catalog’s broader metric-and-structure programs rather than being a mere local cleanup. Why now: the catalog has recently succeeded by shrinking ambitious programs to single self-contained theorem kernels, and the current cold-start guidance explicitly prioritizes sorry-filling on high-value targets; moreover, the recent persistence and tropical bridge work shows that compact monotonicity/certificate lemmas are the most reusable outputs. The proposed direction is to complete the core binary-code identities in `Applications/SmoothPoincare/TopologicalCodes.lean`, `MinimumDistance.lean`, and nearby files: prove that the combinatorial overlap controls weight addition, identify the mod-2 inner product with overlap parity, and derive concrete minimum-distance consequences for self-orthogonal or doubly-even structures already encoded in the Smooth Poincaré stack. The mathematical target should be a falsifiable chain of theorems, not definitions: first establish exact identities such as `wt_add_overlap` and `ip_eq_overlap`; then show that these identities imply computable lower-bound criteria for minimum distance and compatibility with direct sums or self-duality hypotheses from the adjacent files. This matters because it closes a real open proof gap in a domain with many remaining sorries, yields a reusable algebraic certificate layer for later bridges to topological-code or metric-filtration applications, and creates a clean standalone theorem core that Aristotle can extend without reopening foundational combinatorial arguments.
            **Mathematical framing**: 

            ### Attached Catalog References (read these first)
- `Applications/SmoothPoincare/TopologicalCodes.lean`
- `Applications/SmoothPoincare/MinimumDistance.lean`
- `Applications/SmoothPoincare/SelfDualLength.lean`
- `Applications/SmoothPoincare/DirectSum.lean`
- `Applications/SmoothPoincare/IntersectionForms.lean`


### Broader Catalog Context
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

@Applications/SmoothPoincare/DirectSum.lean
```lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Orthogonal (connected-sum) direct sums of intersection forms

This file extends `IntersectionForms.lean` with the **orthogonal direct sum**
`Q ⊕ R` of intersection forms, the algebraic model of the connected sum `M # N`
of 4-manifolds (whose intersection form is the orthogonal sum of the summands').

We prove that the three structural predicates of the theory are *closed* under `⊕`:

* `directSum_unimodular` — unimodularity (Poincaré duality) is additive;
* `directSum_isEven`     — evenness (spin) is additive;
* `directSum_stdDiagonalizable` — the standard form `⟨1⟩ⁿ` is closed under `⊕`.

The headline application is the rank-`16` form `E8form ⊕ E8form`: it is even,
unimodular, and **not** standard-diagonalizable (`E8E8_not_stdDiagonalizable`).
This is the smallest even unimodular form of signature `16`; it clears Rokhlin's
`ℤ/16` signature hurdle yet still fails Donaldson's diagonalization, pinpointing
where the analytic and characteristic-class obstructions diverge.

Builds on: `SmoothPoincare.IntersectionForm` and `even_not_stdDiagonalizable`,
`isEven_of_even_diag`, `E8form`, `E8_even`, `E8_unimodular` from `IntersectionForms`.

-- !-- Lab Notebook -- !--
Hypothesis: the predicates `Unimodular`, `IsEven`, `StdDiagonalizable` should be
  monoidal under the orthogonal block-diagonal sum, so the `E8` obstruction is
  *stable* under connected sum with itself.
Result: all three closure theorems proved `sorry`-free, plus the sharp corollary
  `E8E8_not_stdDiagonalizable` for the rank-16 signature-16 form.
Insight: evenness is governed entirely by the *diagonal* (`isEven_of_even_diag`
  and its converse `even_diag_of_isEven`), so it is transparently additive; the
  obstruction `even_not_stdDiagonalizable` then transfers verbatim to any sum of
  even forms, giving the stable comparison E8 (fails Donaldson) vs E8⊕E8 (passes
  Rokhlin, still fails Donaldson).
Failure analysis: the `Fin (m+n)` vs `Fin m ⊕ Fin n` indexing requires reindexing
  through `finSumFinEquiv`; the clean route is `submatrix_mul_equiv` /
  `transpose_submatrix` / `submatrix_one_equiv`, avoiding any explicit index
  arithmetic.
-/

import Mathlib
import Catalog.Applications.SmoothPoincare.IntersectionForms

open Matrix
open scoped BigOperators

noncomputable section

namespace SmoothPoincare

namespace IntersectionForm

variable {m n : ℕ}

/-- The reindexing equivalence `Fin m ⊕ Fin n ≃ Fin (m + n)`. -/
abbrev sumEquiv (m n : ℕ) : Fin m ⊕ Fin n ≃ Fin (m + n) := finSumFinEquiv

-- !-- The diagonal computes the quadratic value on a basis vector,
-- ... (truncated, full file has 146 lines)
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


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


            ## v17 Research Core Methodology — Concise Scientific Loop

Lead a 4-role team: Hypothesizer, Experimenter, Analyst, Critic.
Loop: Hypothesize → Experiment → Analyze → Critique → Synthesize.

1. **Hypothesize**: 5–7 falsifiable conjectures; ≥2 surprising.
2. **Experiment**: Prove or disprove in Lean 4; prioritize surprise.
3. **Analyze**: Document what survived, failed, and why.
4. **Critique**: Check for triviality, missing sorries, weak assumptions.
5. **Synthesize**: Clean Lean files + FUTURE_DIRECTIONS.md (3–5 testable
   conjectures, each with "The key insight is..." and "Why now?").


            ### Anti-Trivial Guardrails (non-negotiable)
The following are NOT acceptable as main results:
- Theorems of the form `theorem name {X : Type*} [Inhabited X] : True := by trivial`.
- Definition-only theorems or definitional equalities proved by `rfl`.
- Results whose entire proof is `simp`, `norm_num`, `decide`, or `native_decide`.
- Wrapper types that rename existing definitions.
- Re-proving existing catalog theorems with minor notation changes.

Every main theorem must use at least one insight-bearing tactic or
technique such as `induction`, `by_contra`, `field_simp`, `ring_nf`,
`omega`, `linarith`, `rcases`, or a custom helper lemma.


            ### Deliverables & Acceptance Criteria
1. **Lean 4 files** (2–4 files in the appropriate `Catalog/<domain>/` subtree).
   - Main theorems must be fully proved (0 sorries).
   - Each file must contain `-- !-- Lab Notes -- !--` blocks documenting
     the team loop: Hypothesis, Experiment, Analysis, Critique, Synthesis.
2. **FUTURE_DIRECTIONS.md** with 3–5 bold, falsifiable conjectures derived
   from the cycle's findings. Each must have a "The key insight is..."
   sentence and a "Why now?" justification.

### Strictly Forbidden in Phase A
- `ARTICLE.md`, `RESEARCH_PAPER.md`, `demo.py`, HTML widgets, `PACKAGE.json`.
- Prose for human readers other than Lab Notes and FUTURE_DIRECTIONS.md.


            ## Self-Critique Checklist (perform before final output)
            Review your candidate output and answer each item. If the answer is
            unsatisfactory, revise the output before returning it.

            - [ ] No theorem is trivial (True, Inhabited-only, native_decide-only, etc.).
            - [ ] Every main theorem has 0 sorries.
            - [ ] At least one theorem imports or uses results from the attached catalog.
            - [ ] Lab Notes blocks contain real hypotheses, results, insights, and failure analysis.
            - [ ] FUTURE_DIRECTIONS.md conjectures are derived from this cycle's findings.
            - [ ] Every future direction includes a "The key insight is..." sentence and a "Why now?" justification.

            ## Output Format Reminder
            Return `.lean` files and `FUTURE_DIRECTIONS.md` only. Focus all compute
            on the mathematics.
