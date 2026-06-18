
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
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
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

**Title**: Close Proofs: Poincaré Conjecture Revisited: 4D Smooth
**Domain**: Applications
**Mathematical framing**: Cycle e654db2b (Q=0.430) proved 892 theorems in Novelty but left 4 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: The 3D Poincaré conjecture is proven, but the smooth 4D version remains open: does every smooth 4-manifold homotopy equivalent to S⁴ necessarily diffeomorphic to S⁴? Formalize Donaldson's invariants, 
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/SmoothPoincare/IntersectionForms.lean
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

variable {n : ℕ}

/-- The quadratic value `Q(v) = vᵀ G v` of the form on an integer vector. -/
def value (Q : IntersectionForm n) (v : Fin n → ℤ) : ℤ := v ⬝ᵥ Q.gram *ᵥ v

/-- **Poincaré duality** forces the intersection form to be *unimodular*: its Gram
determinant is a unit in `ℤ` (equivalently `±1`). -/
def Unimodular (Q : IntersectionForm n) : Prop := IsUnit Q.gram.det

/-- An **even** form: `Q(v)` is even for every integer vector `v`.  This holds exactly
when the underlying manifold is spin. -/
def IsEven (Q : IntersectionForm n) : Prop := ∀ v : Fin n → ℤ, Even (Q.value v)

/-- `Q` is **standard-diagonalizable** over `ℤ`: there is a unimodular integral basis
change `T` with `Tᵀ G T = 1`, i.e. `Q` is equivalent to the diagonal form `⟨1⟩ⁿ`.
This is the conclusion of Donaldson's theorem in the positive-definite case. -/
def StdDiagonalizable (Q : IntersectionForm n) : Prop :=
  ∃ T : Matrix (Fin n) (Fin n) ℤ, IsUnit T.det ∧ Tᵀ * Q.gram * T = 1

-- !-- Change of basis on a quadratic form: `Q(Tv) = vᵀ (Tᵀ G T) v`, by the matrix
-- `mulVec`/`dotProduct`/transpose identities. -- !--
/-- A basis change `T` transports the quadratic value: `Q(T v) = (Tᵀ G T)(v)`. -/
theorem value_basisChange (Q : IntersectionForm n) (T : Matrix (Fin n) (Fin n) ℤ)
    (v : Fin n → ℤ) :
    Q.value (T *ᵥ v) = v ⬝ᵥ (Tᵀ * Q.gram * T) *ᵥ v := by
  unfold IntersectionForm.value
  simp +decide [Matrix.vecMul_mulVec, Matrix.dotProduct_mulVec]
  rw [Matrix.mul_assoc]

-- !-- A symmetric integer form with even diagonal is even: off-diagonal terms pair up
-- as `2·vᵢGᵢⱼvⱼ` by symmetry, and the diagonal terms `Gᵢᵢvᵢ²` are even. -- !--
/-- A symmetric integral form whose diagonal entries are all even is an even form. -/
theorem isEven_of_even_diag (Q : IntersectionForm n)
    (h : ∀ i, Even (Q.gram i i)) : Q.IsEven := by
  intro v
  -- `Q.value v = ∑ i, ∑ j, vᵢ Gᵢⱼ vⱼ`.
  have h_def : Q.value v = ∑ i, ∑ j, v i * Q.gram i j * v j := by
    unfold IntersectionForm.value
    simp +decide [Matrix.mulVec, dotProduct, mul_comm, mul_left_comm, Finset.mul_sum _ _ _]
  -- Split into the diagonal `∑ᵢ vᵢ² Gᵢᵢ` and twice the strictly-upper-triangular part.
  have h_symm : ∑ i, ∑ j, v i * Q.gram i j * v j
      = ∑ i, v i ^ 2 * Q.gram i i + 2 * ∑ i, ∑ j ∈ Finset.Ioi i, v i * Q.gram i j * v j := by
    have h_symm : ∀ (n : ℕ) (f : Fin n → Fin n → ℤ), (∀ i j, f i j = f j i) →
        ∑ i, ∑ j, f i j = ∑ i, f i i + 2 * ∑ i, ∑ j ∈ Finset.Ioi i, f i j := by
      intros n f hf_symm; induction' n with n ih <;> simp +decide [ Fin.sum_univ_succ, * ] ; ring;
      simp +decide [ Finset.sum_add_distrib, mul_two, ih _ fun i j => hf_symm _ _ ] ; ring;
    convert h_symm n _ _ using 3 <;> ring!;
    exact fun i j => by rw [ mul_right_comm, Q.isSymm.apply ] ;
  exact h_def ▸ h_symm ▸ even_iff_two_dvd.mpr
    (dvd_add (Finset.dvd_sum fun i _ => dvd_mul_of_dvd_right (even_iff_two_dvd.mp (h i)) _)
      (dvd_mul_right _ _))

/-! ## The Donaldson obstruction -/

-- !-- If `Tᵀ G T = 1`, then for the standard basis vector `eₖ` we get
-- `Q(T eₖ) = eₖᵀ · 1 · eₖ = 1`, which is odd — contradicting evenness. -- !--
/-- **Donaldson's obstruction (algebraic core).** A positive-rank *even* intersection
form is never diagonalizable to the standard form `⟨1⟩ⁿ`.  This is the algebraic
mechanism by which gauge theory forbids even definite forms on smooth 4-manifolds. -/
theorem even_not_stdDiagonalizable (Q : IntersectionForm n) (hn : 0 < n)
    (hev : Q.IsEven) : ¬ Q.StdDiagonalizable := by
  intro h
  obtain ⟨T, hTref, hTeq⟩ := h
  -- The first standard basis vector and its image under `T`.
  set k : Fin n := ⟨0, hn⟩
  set v : Fin n → ℤ := Pi.single k 1
  set w : Fin n → ℤ := T.mulVec v
  -- Transport the value through `T`, then collapse `Tᵀ G T = 1`.
  have hQw : Q.value w = v ⬝ᵥ (Tᵀ * Q.gram * T) *ᵥ v :=
    value_basisChange Q T v
  have hQw_eq : Q.value w = v ⬝ᵥ v := by
    rw [hQw, hTeq, Matrix.one_mulVec]
  -- `v ⬝ᵥ v = 1` since `v` is a standard basis vector.
  have hvdotv : v ⬝ᵥ v = 1 := by
    simp [v, dotProduct, Pi.single_apply, Finset.sum_ite_eq']
  -- Evenness would force `Even (1 : ℤ)`, a contradiction.
  have h_even : Even (1 : ℤ) := hvdotv ▸ hQw_eq ▸ hev w
  exact absurd h_even (by decide)

/-! ## The standard odd form `⟨1⟩ⁿ` (boundary case) -/

/-- The standard positive-definite form `⟨1⟩ⁿ`, the intersection form of `#ⁿ ℂP²`. -/
def stdForm (n : ℕ) : IntersectionForm n := ⟨1, Matrix.isSymm_one⟩

-- !-- `Q(e₀) = e₀ᵀ · 1 · e₀ = 1`, which is odd, so the standard form is not even;
-- this shows evenness is genuinely needed in `even_not_stdDiagonalizable`. -- !--
/-- **Boundary case:** the standard form `⟨1⟩ⁿ` is *not* even for `n ≥ 1`. -/
theorem stdForm_not_even (hn : 0 < n) : ¬ (stdForm n).IsEven := by
  intro h
  convert h (Pi.single ⟨0, hn⟩ 1) using 1
  simp +decide [IntersectionForm.value, stdForm]

/-! ## The `E8` form -/

/-- The `E8` Cartan/Gram matrix: even, unimodular, positive-definite, rank `8`. -/
def E8mat : Matrix (Fin 8) (Fin 8) ℤ :=
  !![2,-1,0,0,0,0,0,0;
     -1,2,-1,0,0,0,0,0;
     0,-1,2,-1,0,0,0,0;
     0,0,-1,2,-1,0,0,0;
     0,0,0,-1,2,-1,0,-1;
     0,0,0,0,-1,2,-1,0;
     0,0,0,0,0,-1,2,0;
     0,0,0,0,-1,0,0,2]

/-- An explicit integral inverse of `E8mat`, witnessing unimodularity. -/
def E8inv : Matrix (Fin 8) (Fin 8) ℤ :=
  !![2,3,4,5
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Intersection Forms and the Smooth 4D Poincaré Frontier

The file `IntersectionForms.lean` formalizes the algebraic core of four-dimensional
gauge theory: symmetric integral intersection forms, their unimodularity (Poincaré
duality), evenness (spin), and standard diagonalizability (Donaldson's conclusion).
Its headline result, `even_not_stdDiagonalizable`, is the algebraic mechanism that
forbids even definite forms on smooth 4-manifolds, instantiated by the `E8` form
(`E8_not_stdDiagonalizable`). The following research directions extend this nucleus
toward a genuinely useful Lean theory of 4-manifold invariants. Each is concrete,
testable, and falsifiable: a precise Lean statement that either compiles or does not.

## 1. The 8-divisibility theorem for even unimodular definite forms

**Conjecture.** Every positive-definite *even* unimodular symmetric integral form has
rank divisible by `8`. In Lean: if `Q : IntersectionForm n` is `Unimodular`, `IsEven`,
and positive-definite (a `PosDef` predicate to be added: `∀ v ≠ 0, 0 < Q.value v`),
then `8 ∣ n`.

The key insight is that evenness plus unimodularity force the form, over `ℝ`, to embed
in the even unimodular lattice tower whose signature is constrained mod 8 by the
`E8`/Milnor classification; the rank `8` of our explicit `E8form` is the minimal
witness, so the obstruction `even_not_stdDiagonalizable` is really the `n < 8` shadow
of a `mod 8` law. Why now? We already have a fully verified even unimodular definite
form of rank `8` (`E8form`, `E8_even`, `E8_unimodular`), so the base case and the
sharpness example are in hand — only the modular bookkeeping remains, and Mathlib's
quadratic-form and lattice libraries have matured enough to host it.

## 2. A formal van der Blij / signature-mod-8 invariant

**Conjecture.** For any unimodular `Q : IntersectionForm n` there is an integer vector
`c` (a *characteristic element*, `Q.value v ≡ c ⬝ᵥ v (mod 2)` for all `v`) and the
quantity `Q.value c` is congruent to the signature of `Q` modulo `8`; for *even* forms
one may take `c = 0`, giving `signature ≡ 0 (mod 8)`.

The key insight is that the characteristic element packages the obstruction
`even_not_stdDiagonalizable` into a single `ℤ/8`-valued invariant: oddness of the
diagonal in the standard form is exactly the statement that `c ≠ 0`, and van der Blij's
lemma turns this parity datum into a signature congruence. Why now? Our `value` and
`IsEven` predicates already isolate the parity pairing `Q.value v mod 2`; defining a
`signature` for diagonalizable forms and proving the congruence on the diagonal case is
a self-contained next step that reuses `value_basisChange` verbatim.

## 3. Connected-sum additivity and a stable cancellation law

**Conjecture.** Define the block-diagonal direct sum `Q ⊕ R` of intersection forms
(modeling the connected sum `M # N`). Then `Unimodular` and `IsEven` are each closed
under `⊕`, signatures add, and a *stable* form of Donaldson holds: if `Q ⊕ ⟨1⟩^k` is
s
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
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
