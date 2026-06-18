
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

**Title**: Quantum Hamiltonian Complexity: QMA-Completeness of the Local Hamiltonian Problem
**Domain**: Shared
**Mathematical framing**: Prove that the k-Local Hamiltonian Problem is QMA-complete for k >= 2. Formalize the Kitaev reduction from quantum circuit satisfiability to the local Hamiltonian problem. Analyze the promise gap and its effect on complexity.
Research domain: Shared
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Physics/LocalHamiltonianQMA.lean
/-
Copyright (c) 2025. All rights reserved.

# Local Hamiltonian Energy Algebra and the Promise Gap

This module formalizes the linear-algebraic core underlying the *k-Local Hamiltonian
Problem*, the canonical QMA-complete problem of quantum Hamiltonian complexity
(Kitaev). A quantum Hamiltonian on a finite-dimensional Hilbert space is a Hermitian
operator; a *local* Hamiltonian is a sum of Hermitian terms each acting on few qubits.
The decision problem asks to estimate the ground-state energy (smallest eigenvalue)
within a promise gap `b - a`.

We make the following pieces rigorous and machine-checked:

* `qform` — the Rayleigh quadratic form `⟨x, H x⟩` of an operator;
* `IsHermitian.qform_self_conj` — for Hermitian `H` the energy `⟨x, H x⟩` is real
  (the spectrum is real), the well-definedness underlying the whole problem;
* `EnergyLB` — the predicate "`λ` is an energy lower bound for `H`" (a certified
  bound on the ground energy);
* `energyLB_add` / `energyLB_sum` — energy lower bounds compose **additively** over
  local terms: a sum of `m` terms each bounded below by `λ i` is bounded below by
  `∑ λ i`. This is the soundness direction of the promise-gap analysis for local
  Hamiltonians.
* `isHermitian_sum` — a sum of local Hermitian terms is Hermitian.
* `promise_gap_consistent` — the promise gap is logically consistent: with `a < b`,
  no instance can be simultaneously a YES instance (a witness of energy `≤ a`) and a
  NO instance (ground energy `≥ b`). This is the abstract soundness/completeness
  separation that makes the QMA promise problem well posed.
* `frustration_no_common_ground_state` — a concrete two-term, single-qubit witness of
  *frustration*: the local terms `(I - Z)/2` and `(I - X)/2` have ground energy `0`
  individually, yet share **no** common zero-energy state. Frustration is precisely
  what makes computing the ground energy of a local Hamiltonian hard (super-additive
  ground energy) rather than a trivial term-by-term minimization.

## Cross-domain bridge

The energy-lower-bound algebra (`EnergyLB`) is an ordered-semiring-flavoured
*certificate calculus*: certificates for individual local terms add to a certificate
for the whole Hamiltonian, exactly as interval bounds compose in
`Physics.CertifiedMassGapBounds`. The frustration witness connects this complexity
theory to the variational principles of `Physics.V12_VariationalPrinciples`: the gap
between `∑ λ i` and the true ground energy is the algebraic signature of
computational hardness.
-/

import Mathlib

open Matrix
open scoped Matrix BigOperators

namespace LocalHamiltonian

variable {m : Type*} [Fintype m]

/-! ## The Rayleigh quadratic form (energy functional) -/

/-- The energy functional (Rayleigh quadratic form) `⟨x, H x⟩` of an operator `H`
on state `x`. -/
noncomputable def qform (H : Matrix m m ℂ) (x : m → ℂ) : ℂ := star x ⬝ᵥ H.mulVec x

-- !-- The energy functional is additive in the operator: `⟨x,(H₁+H₂)x⟩ = ⟨x,H₁x⟩+⟨x,H₂x⟩`,
-- immediate from bilinearity of matrix-vector product and the dot product. -- !--
theorem qform_add (H₁ H₂ : Matrix m m ℂ) (x : m → ℂ) :
    qform (H₁ + H₂) x = qform H₁ x + qform H₂ x := by
  unfold qform
  rw [Matrix.add_mulVec, dotProduct_add]

-- !-- The zero operator has zero energy on every state. -- !--
theorem qform_zero (x : m → ℂ) : qform (0 : Matrix m m ℂ) x = 0 := by
  unfold qform
  rw [Matrix.zero_mulVec, dotProduct_zero]

/-- Helper: complex-conjugation distributes over the dot product (the entry star ring
is commutative). -/
theorem star_dotProduct_distrib (v w : m → ℂ) :
    star (v ⬝ᵥ w) = star v ⬝ᵥ star w := by
  simp only [dotProduct, star_sum, star_mul']
  rfl

-- !-- For Hermitian `H`, the energy `⟨x,Hx⟩` is self-conjugate, hence real: this is
-- the statement that observables (Hermitian operators) have real expectation values
-- and real spectrum, the foundation of the Local Hamiltonian Problem. -- !--
theorem IsHermitian.qform_self_conj {H : Matrix m m ℂ} (hH : H.IsHermitian)
    (x : m → ℂ) : star (qform H x) = qform H x := by
  unfold qform
  rw [star_dotProduct_distrib, star_star, star_mulVec, hH.eq, dotProduct_comm,
    dotProduct_mulVec]

-- !-- Consequently the energy of a Hermitian operator has zero imaginary part. -- !--
theorem IsHermitian.qform_im_zero {H : Matrix m m ℂ} (hH : H.IsHermitian)
    (x : m → ℂ) : (qform H x).im = 0 := by
  have h := IsHermitian.qform_self_conj hH x
  have : (starRingEnd ℂ) (qform H x) = qform H x := h
  rw [Complex.conj_eq_iff_im] at this
  exact this

/-! ## Norms and energy lower bounds -/

/-- The squared norm `⟨x, x⟩ = ∑ |xᵢ|²` of a state, as a real number. -/
noncomputable def normSq2 (x : m → ℂ) : ℝ := (star x ⬝ᵥ x).re

-- !-- `∑|xᵢ|² ≥ 0`: the dot product `star x ⬝ᵥ x` equals `∑ |xᵢ|²` whose real part is a
-- sum of squared moduli. -- !--
theorem normSq2_nonneg (x : m → ℂ) : 0 ≤ normSq2 x := by
  unfold normSq2 dotProduct
  rw [Complex.re_sum]
  apply Finset.sum_nonneg
  intro i _
  simp [Complex.mul_re, Pi.star_apply, Complex.conj_re, Complex.conj_im]
  nlinarith [sq_nonneg (x i).re, sq_nonneg (x i).im]

-- !-- A state has zero squared norm iff it is the zero vector. -- !--
theorem normSq2_eq_zero_iff (x : m → ℂ) : normSq2 x = 0 ↔ x = 0 := by
  unfold normSq2;
  simp +decide [ dotProduct ];
  simp +decide [ Finset.sum_eq_zero_iff_of_nonneg, add_nonneg, mul_self_nonneg, funext_iff ];
  exact forall_congr' fun i => by simp +decide [ Complex.ext_iff, add_eq_zero_iff_of_nonneg, mul_self_nonneg ] ;

/-- `λ` is a certified **energy lower bound** for `H`: every state has Rayleigh
energy at least `λ‖x‖²`. For Hermitian `H` this lower-bounds the ground-state
energy (smallest eigenvalue). -/
def EnergyLB (H : Matrix m m ℂ) (lam : ℝ) : Prop :=
  ∀ x : m → ℂ, lam * normSq2 x ≤ (qform H x).re

-- !-- Energy lower bounds compose additively: this is the soundness of summing local
-- terms. Follows from `qform_add` and additivity of `Complex.re`, then `linarith`. -- !--
theorem energyLB_add {H₁ H₂ : Matrix m m ℂ} {a b : ℝ}
    (h₁ : EnergyLB H₁ a) (h₂ : EnergyLB H₂ b) : EnergyLB (H₁ + H₂) (a + b) := by
  intro x
  have e := qform_add H₁ H₂ x
  have h1 := h₁ x
  have h2 := h₂ x
  rw [e, Complex.add_re]
  have : (a + b) * normSq2 x = a * normSq2 x + b * normSq2 x := by ring
  rw [this]
  linarith

-- !-- The zero Hamiltonian has energy lower bound `0`. -- !--
theorem energyLB_zero : EnergyLB (0 : Matrix m m ℂ) 0 := by
  intro x
  rw [qform_zero]
  simp

-- !-- Energy lower bounds for a finite family of local terms sum to an energy lower
-- bound for the total Hamiltonian. Finset induction on `energyLB_add`/`energyLB_zero`. -- !--
theorem energyLB_sum {ι : Type*} (s : Finset ι) (H : ι → Matrix m m ℂ)
    (lam : ι → ℝ) (h : ∀ i ∈ s, EnergyLB (H i) (lam i)) :
    EnergyLB (∑ i ∈ s, H i) (∑ i ∈ s, lam i) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using (energyLB_zero (m := m))
  | insert i s hi ih =>
    rw [Finset.sum_insert hi, Finset.sum_insert hi]
    exact energyLB_add (h i (Finset.mem_insert_self _ _))
      (ih (fun j hj => h j (Finset.mem_insert_of_mem hj)))

/-! ## Hermiticity of the total local Hamiltonian -/

-- !-- A sum of Hermitian local terms is Hermitian: `(∑ Hᵢ)ᴴ = ∑ Hᵢᴴ = ∑ Hᵢ`. -- !--
omit [Fintype m] in
theorem isHermitian_sum {ι : Type*} (s : Finset ι) (H : ι → Matrix m m ℂ)
    (h : ∀ i ∈ s, (H i).IsHermitian) : (∑ i ∈ s, H i).IsHermitian := by
  classical
  induction s using Finset.induction with
  | empty => simp [Matrix.IsHermitian]
  | insert i s hi ih =>
    rw [Finset.sum_insert hi]
    exact (h i (Finset.mem_insert_self _ _)).add
      (ih (fun j hj => h j (Finset.mem_insert_of_mem hj)))

/-! ## The promise gap is well posed -/

/-- A **YES instance** witness: a normalized state of energy at most `a`. -/
def IsYesWitness (H : Matrix m m ℂ) (a : ℝ) (x : m → ℂ) : Prop :=
  normSq2 x = 1 ∧ (qform H x).re ≤ a

-- !-- Soundness of the promise gap: if `a < b`, an operator 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Local Hamiltonian Complexity in Lean 4

The module `Catalog/Physics/LocalHamiltonianQMA.lean` formalizes the linear-algebraic
backbone of the *k-Local Hamiltonian Problem* — the canonical QMA-complete problem of
quantum Hamiltonian complexity. We made machine-checked the energy functional `qform`,
the reality of Hermitian expectation values (`IsHermitian.qform_self_conj`), the
**additive composition** of certified energy lower bounds over local terms
(`energyLB_add`, `energyLB_sum`), the Hermiticity of the total local Hamiltonian
(`isHermitian_sum`), the logical consistency of the promise gap
(`promise_gap_consistent`), and a concrete *frustration* witness
(`frustration_no_common_ground_state`) showing two single-qubit terms with individual
ground energy `0` that share no common zero-energy state.

Below are five testable, falsifiable research directions that extend this work. Each
builds directly on the catalog: the energy-certificate calculus generalizes the
interval-bound composition of `Physics.CertifiedMassGapBounds`, the variational angle
connects to `Physics.V12_VariationalPrinciples`, and the frustration phenomenon links
to the spectral-gap material throughout the Physics library.

## Direction 1: Quantitative frustration energy (super-additivity made numeric)

Conjecture: for the frustration witness `H = Hz + Hx`, the ground energy is exactly
`(2 - √2)/2 ≈ 0.293`, strictly above the sum `0 + 0 = 0` of the local ground energies.
Formally, `EnergyLB (Hz + Hx) ((2 - Real.sqrt 2)/2)` holds and is tight: there is a
normalized state achieving it.

The key insight is that `frustration_no_common_ground_state` is the *qualitative*
shadow of a *quantitative* spectral gap — proving the exact constant turns a
non-existence statement into a certified, optimal lower bound that the promise-gap
machinery (`promise_gap_consistent`) can then consume directly. Why now? We already
have `qform_Hz` and `qform_Hx` as closed-form perfect squares, so the Rayleigh quotient
`qform (Hz+Hx) x / normSq2 x` is an explicit two-variable real-rational function whose
minimum is a finite optimization Lean's `polyrith`/`nlinarith` can certify.

## Direction 2: Tensor (locality) embedding and the `2`-local structure

Conjecture: an operator `A ⊗ I` on `(Fin d → Fin 2)`-indexed qubit space is Hermitian
iff `A` is, and `EnergyLB A λ → EnergyLB (A ⊗ I) λ` (padding with identity preserves
energy bounds). More generally a genuinely *k-local* term is `A` acting on `k`
coordinates tensored with identity on the rest.

The key insight is that locality is *structurally invisible* to the energy-certificate
calculus — `energyLB_sum` never inspects which qubits a term touches — so k-locality can
be added as a thin `Matrix.kroneckerMap` layer on top of the already-proven additivity
without reproving any energy algebra. Why now? Mathlib's `Matrix.kroneckerMap`,
`Matrix.kronecker_assoc`, and `IsHermitian` API are mature enough to push quadratic
forms through tensor prod
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
