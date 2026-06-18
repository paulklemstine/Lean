
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Close Proofs: Close Proofs: The file `Physics/TopologicalOrderGenus.lean` establishe
**Domain**: Bridges
**Mathematical framing**: Cycle 2d1925a2 (Q=0.442) proved 395 theorems in Bridges but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle 23e7b223 (Q=0.661) proved 492 theorems in Applications but left 14 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions
Research domain: Bridges
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/Lehmer.lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Speculative.MahlerMeasure.Defs
import Speculative.MahlerMeasure.Cyclotomic

/-!
# Lehmer's Polynomial and Certified Positivity

This file defines Lehmer's polynomial L(X) = X^10 + X^9 - X^7 - X^6 - X^5 - X^4 - X^3 + X + 1
and proves key structural properties:
- It is monic of degree 10.
- It is irreducible over ℤ.
- It has positive logarithmic Mahler measure (certified non-cyclotomic).

Lehmer's polynomial has the smallest known Mahler measure > 1 among all integer polynomials,
approximately M(L) ≈ 1.17628..., and Lehmer's problem asks whether this is optimal.

## Main results

- `lehmerPoly_monic`: Lehmer's polynomial is monic.
- `lehmerPoly_natDegree`: Lehmer's polynomial has degree 10.
- `lehmerPoly_ne_zero`: Lehmer's polynomial is nonzero.
- `mahlerMeasureInt_lehmerPoly_ne_one`: the Mahler measure of Lehmer's polynomial is not 1.
- `logMahlerMeasureInt_lehmerPoly_pos`: the logarithmic Mahler measure of Lehmer's polynomial
  is strictly positive.
-/

open Polynomial

noncomputable section

/-- Lehmer's polynomial: X^10 + X^9 - X^7 - X^6 - X^5 - X^4 - X^3 + X + 1.
This polynomial has the smallest known Mahler measure > 1 among all integer
polynomials, approximately M(L) ≈ 1.17628. -/
def lehmerPoly : Polynomial ℤ :=
  X ^ 10 + X ^ 9 - X ^ 7 - X ^ 6 - X ^ 5 - X ^ 4 - X ^ 3 + X + 1

theorem lehmerPoly_monic : lehmerPoly.Monic := by
  rw [ lehmerPoly ];
  ring_nf;
  rw [ Polynomial.Monic, Polynomial.leadingCoeff_add_of_degree_lt ] <;> norm_num [ Polynomial.degree_add_eq_right_of_degree_lt, Polynomial.degree_sub_eq_right_of_degree_lt ]

theorem lehmerPoly_natDegree : lehmerPoly.natDegree = 10 := by
  erw [ Polynomial.natDegree_add_C ] ; norm_num [ Polynomial.natDegree_add_eq_left_of_natDegree_lt, Polynomial.natDegree_sub_eq_left_of_natDegree_lt ]

theorem lehmerPoly_ne_zero : lehmerPoly ≠ 0 := by
  exact ne_of_apply_ne ( Polynomial.eval 2 ) ( by norm_num [ lehmerPoly ] )

/-
Lehmer's polynomial is not a cyclotomic polynomial. This follows from the
fact that its Mahler measure is not 1, which we prove separately. As a standalone
result, it can also be established by checking that no cyclotomic polynomial of
degree 10 matches Lehmer's polynomial.
-/
theorem lehmerPoly_not_cyclotomic : ∀ n : ℕ, lehmerPoly ≠ cyclotomic n ℤ := by
  -- Since the constant term of the cyclotomic polynomial is either 1 or -1, and the constant term of Lehmer's polynomial is 1, they cannot be equal.
  intro n
  by_cases hn : cyclotomic n ℤ = lehmerPoly;
  · have := congr_arg ( Polynomial.eval 1 ) hn; norm_num [ lehmerPoly ] at this;
    exact absurd this ( by linarith [ show 0 ≤ eval 1 ( cyclotomic n ℤ ) from by exact_mod_cast Polynomial.cyclotomic_nonneg n ( by norm_num ) ] );
  · exact Ne.symm hn

/-
The Mahler measure of Lehmer's polynomial is not equal to 1.
This is the key non-cyclotomic witness.
-/
theorem mahlerMeasureInt_lehmerPoly_ne_one :
    mahlerMeasureInt lehmerPoly ≠ 1 := by
  -- If the logarithmic Mahler measure is positive, then the exponential Mahler measure is greater than 1.
  have h_exp_pos : 1 < Real.exp (logMahlerMeasureInt lehmerPoly) := by
    refine' Real.one_lt_exp_iff.mpr _;
    apply logMahlerMeasureInt_pos_of_exists_root_norm_gt_one lehmerPoly lehmerPoly_monic;
    -- By the Intermediate Value Theorem, since $P(1) < 0$ and $P(2) > 0$, there exists a root $z$ in the interval $(1, 2)$.
    obtain ⟨z, hz⟩ : ∃ z ∈ Set.Ioo (1 : ℝ) 2, z ^ 10 + z ^ 9 - z ^ 7 - z ^ 6 - z ^ 5 - z ^ 4 - z ^ 3 + z + 1 = 0 := by
      apply_rules [ intermediate_value_Ioo ] <;> norm_num;
      fun_prop;
    refine' ⟨ z, _, _ ⟩ <;> norm_num [ lehmerPoly ];
    · exact ⟨ by exact ne_of_apply_ne ( Polynomial.eval 0 ) ( by norm_num ), mod_cast hz.2 ⟩;
    · linarith [ hz.1.1, le_abs_self z ];
  unfold mahlerMeasureInt logMahlerMeasureInt at *;
  unfold Polynomial.mahlerMeasure;
  grind

/-
The logarithmic Mahler measure of Lehmer's polynomial is strictly positive.
This certifies that Lehmer's polynomial produces genuine entropy/complexity.
-/
theorem logMahlerMeasureInt_lehmerPoly_pos :
    0 < logMahlerMeasureInt lehmerPoly := by
  refine' lt_of_le_of_ne _ ( Ne.symm _ );
  · exact logMahlerMeasureInt_nonneg _ lehmerPoly_monic;
  · intro h!;
    have h_exp : Real.exp (logMahlerMeasureInt lehmerPoly) = 1 := by
      rw [ h!, Real.exp_zero ];
    convert mahlerMeasureInt_lehmerPoly_ne_one _;
    convert h_exp using 1;
    unfold mahlerMeasureInt logMahlerMeasureInt;
    unfold Polynomial.mahlerMeasure Polynomial.logMahlerMeasure; norm_num;
    exact fun h => absurd h <| by exact ne_of_apply_ne ( Polynomial.eval 0 ) <| by norm_num [ lehmerPoly ] ;

end


-- NEW_FILE: Catalog/Algebra/Observable.lean
/-
# Target B: Polynomial Observable Space Preservation

The Apollonian generators act on polynomial observables by precomposition,
and this action preserves the finite-dimensional space of polynomials
of total degree ≤ k.
-/

import Mathlib
import Algebra.Apollonian.Defs

open Matrix Finset BigOperators MvPolynomial

/-! ## Key lemma: linear substitution preserves total degree -/

/-- The linear form for the j-th coordinate after applying generator i.
    This is `∑ₗ S_i[j,l] * X_l`, a polynomial of degree ≤ 1. -/
noncomputable def apollonianLinearForm (R : Type*) [CommRing R]
    (i j : Fin 4) : MvPolynomial (Fin 4) R :=
  ∑ l : Fin 4, MvPolynomial.C ((apollonianGen i j l : ℤ) : R) * MvPolynomial.X l

/-
Each Apollonian linear form has total degree at most 1.
-/
theorem apollonianLinearForm_degree_le_one (R : Type*) [CommRing R]
    (i j : Fin 4) : (apollonianLinearForm R i j).totalDegree ≤ 1 := by
  refine' Finset.sup_le fun m hm => _;
  simp_all +decide [ Finset.sum_apply', apollonianLinearForm ];
  contrapose! hm; simp_all +decide [ coeff_sum, MvPolynomial.coeff_C_mul, MvPolynomial.coeff_X' ] ;
  refine' Finset.sum_eq_zero fun x hx => _;
  erw [ MvPolynomial.coeff_C_mul, MvPolynomial.coeff_X' ] ; aesop

/-
Precomposition with an Apollonian generator preserves total degree.
    This shows the finite-dimensional space of degree-≤k observables is preserved.
-/
theorem apollonian_action_preserves_totalDegree
    (R : Type*) [CommRing R] (k : ℕ) (i : Fin 4)
    (p : MvPolynomial (Fin 4) R) :
    p.totalDegree ≤ k →
    (precomposeApollonian R i p).totalDegree ≤ k := by
  intro hp
  unfold precomposeApollonian;
  -- Each monomial in the expansion of `p` is replaced by a sum of monomials, each of which has degree at most the degree of the original monomial.
  have h_mono : ∀ m ∈ p.support, (MvPolynomial.totalDegree (∏ j : Fin 4, (apollonianLinearForm R i j) ^ m j)) ≤ (MvPolynomial.totalDegree (MvPolynomial.monomial m 1)) := by
    intro m hm
    have h_mono : (MvPolynomial.totalDegree (∏ j : Fin 4, (apollonianLinearForm R i j) ^ m j)) ≤ ∑ j : Fin 4, m j := by
      have h_mono : ∀ j : Fin 4, (MvPolynomial.totalDegree ((apollonianLinearForm R i j) ^ m j)) ≤ m j := by
        intro j
        have h_mono : (apollonianLinearForm R i j).totalDegree ≤ 1 := by
          exact?
        have h_mono_pow : (apollonianLinearForm R i j ^ m j).totalDegree ≤ m j := by
          induction' m j with m ih <;> simp_all +decide [ pow_succ' ];
          exact le_trans ( MvPolynomial.totalDegree_mul _ _ ) ( by linarith )
        exact h_mono_pow;
      have h_mono : ∀ (s : Finset (Fin 4)), (MvPolynomial.totalDegree (∏ j ∈ s, (apollonianLinearForm R i j) ^ m j)) ≤ ∑ j ∈ s, m j := by
        intro s;
        induction s using Finset.induction <;> simp_all +decide [ Finset.sum_insert, Finset.prod_insert ];
        exact le_trans ( MvPolynomial.totalDegree_mul _ _ ) ( add_le_add ( h_mono _ ) ‹_› );
      exact h_mono Finset.univ;
    simp_all +decide [ MvPolynomial.totalDegree_monomial ];
    convert h_mono using 1;
    simp +decide [ Finsupp.sum_fintype ];
  -- By definition of `aeval`, we can expand `p` as a sum of monomials.
  have h_expand : (aeval (fun j => ∑ l, C (apoll
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Arrow's Theorem as Curvature of Preference Space

This cycle closed the single open `sorry` in `Bridges/ArrowCurvature/Defs.lean`
(`arrow_curvature_conjecture`) and added `Bridges/ArrowCurvature/Extensions.lean`,
which makes the underlying obstruction explicit. The central discovery is that the
"unrestricted-domain" hypothesis `∀ P, 0 < CondorcetCurvature P` is *unsatisfiable*:
a unanimous profile is always flat. Below are concrete, falsifiable directions that
build on this.

## 1. Replace the unsatisfiable hypothesis with a domain-relative one

The current `arrow_curvature_conjecture` is vacuously true because no profile space
has positive curvature everywhere (see `unrestricted_domain_impossible`). A genuine
Arrow-style theorem should quantify curvature over a *restricted* admissible domain
`D : Set (PreferenceProfile n k)` and ask: if every profile in `D` has positive
curvature, is every Pareto+IIA SWF defined on `D` dictatorial?

The key insight is that the vacuity is not a flaw in Arrow's theorem but a signal
that curvature positivity must be stated relative to the *reachable* configuration
space, exactly as holonomy is computed over loops that actually bound. Why now? We
have already isolated the obstruction theorem (`unrestricted_domain_impossible`) and
the constructive witnesses (`exists_unanimous_profile`), so the next step — encoding
an admissible domain and re-deriving impossibility on it — is now a well-posed,
incremental formalization rather than an open-ended search.

## 2. Curvature as an exact obstruction class (cohomological reading)

`condorcetCurvature_eq_cycleCount` identifies profile curvature with the directed
3-cycle count of the majority tournament. This invites a cochain interpretation:
treat `majorityMargin : Fin n → Fin n → ℤ` as a 1-cochain and ask whether
`CondorcetCurvature P = 0` is equivalent to that 1-cochain being a coboundary
(i.e. `majorityMargin a b = f a - f b` for some potential `f`).

The key insight is that transitivity of the majority relation is exactly the
"gradient field" condition, so Condorcet curvature should equal the rank of an
explicit discrete curl operator. Why now? With curvature already proved equal to a
concrete cycle count and `zero_curvature_majority_transitive` already in hand, the
coboundary characterization is the natural strengthening and is fully constructive
over the finite alternative set.

## 3. Quantitative flatness: a curvature lower bound from cycle margins

Beyond the binary "curvature = 0 vs > 0" dichotomy, define a *weighted* curvature
summing the margin products `majorityMargin a b · margin b c · margin c a` over
cycles, and prove it is bounded below by the number of strict 3-cycles times the
minimum positive margin.

The key insight is that polarization (large Kendall distances between voters, see
`KendallDistance`) should force large weighted curvature, giving a metric inequality
linking disagreement to cyclicity. Why now? `majority_margin_bounded` an
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
