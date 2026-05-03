/-
# Stone–Weierstrass via Lattice–Algebra Closure

This file formalizes a concrete Stone–Weierstrass theorem for a set `A` of
continuous real-valued functions on a compact Hausdorff space `X`, assuming:
  • closure under addition, negation, and multiplication (subalgebra axioms),
  • closure under pointwise `sup` and `inf` (sublattice axioms),
  • membership of all real constant functions,
  • separation of points.

The key results are:
  1. `stoneWeierstrass_sublattice_subalgebra_real` — ε-approximation in sup norm.
  2. `stoneWeierstrass_sublattice_subalgebra_real_eps` — pointwise ε-approximation.
  3. `stoneWeierstrass_sublattice_subalgebra_real_dense` — density of `A`.

The proof reduces to the classical Stone–Weierstrass theorem already in Mathlib
(`ContinuousMap.subalgebra_topologicalClosure_eq_top_of_separatesPoints`)
by constructing a `Subalgebra ℝ C(X, ℝ)` from the closure hypotheses and
verifying point separation. The lattice axioms (`hsup`, `hinf`) are carried
along as extra structure useful for downstream EML applications.

## Significance for EML

This theorem is the abstract universal approximation principle for the EML
program. Once an EML architecture's function class is shown to satisfy the
six closure axioms plus point separation, uniform density in `C(X, ℝ)` follows
immediately from this meta-theorem.
-/

import Mathlib

noncomputable section

open ContinuousMap Set

variable {X : Type*} [TopologicalSpace X]

/-! ### Constructing a Subalgebra from closure hypotheses -/

omit [TopologicalSpace X] in
/-- The `algebraMap ℝ C(X, ℝ)` sends `r` to the constant function `ContinuousMap.const X r`. -/
lemma algebraMap_eq_const [TopologicalSpace X] (r : ℝ) :
    algebraMap ℝ C(X, ℝ) r = ContinuousMap.const X r := by
  ext x; simp [Algebra.algebraMap_eq_smul_one]

/-- From closure under constants, addition, and multiplication, build a `Subalgebra ℝ C(X, ℝ)`
    with carrier `A`. -/
def setToSubalgebra
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A) :
    Subalgebra ℝ C(X, ℝ) where
  carrier := A
  mul_mem' ha hb := hmul ha hb
  add_mem' ha hb := hadd ha hb
  zero_mem' := by simpa [← ContinuousMap.coe_const] using hconst 0
  one_mem' := by simpa [← ContinuousMap.coe_const] using hconst 1
  algebraMap_mem' r := by rw [algebraMap_eq_const]; exact hconst r

/-- Point separation for the constructed subalgebra follows from the set-level separation. -/
lemma subalgebra_separatesPoints
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    (setToSubalgebra A hconst hadd hmul).SeparatesPoints := by
  intro x y; by_cases hxy : x = y <;> simp_all +decide;
  exact hsep x y hxy

/-! ### Two-point interpolation -/

/-- Closure of `A` under scalar multiplication (derived from constants and multiplication). -/
lemma smul_mem_of_const_mul
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (c : ℝ) ⦃f : C(X, ℝ)⦄ (hf : f ∈ A) : c • f ∈ A := by
  convert hmul (hconst c) hf using 1

/-- Closure of `A` under subtraction (derived from addition and negation). -/
lemma sub_mem_of_add_neg
    (A : Set C(X, ℝ))
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    ⦃f g : C(X, ℝ)⦄ (hf : f ∈ A) (hg : g ∈ A) : f - g ∈ A := by
  simpa only [sub_eq_add_neg] using hadd hf (hneg hg)

/-- **Two-point interpolation**: given `x ≠ y` and target values `a, b : ℝ`,
    there exists `g ∈ A` with `g x = a` and `g y = b`. This is the algebraic
    engine of the Stone–Weierstrass proof. -/
theorem exists_mem_A_eq_of_ne
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (_hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y)
    {x y : X} (hxy : x ≠ y) (a b : ℝ) :
    ∃ g ∈ A, g x = a ∧ g y = b := by
  obtain ⟨f, hf₁, hf₂⟩ := hsep x y hxy
  set α : ℝ := (a - b) / (f x - f y)
  set β : ℝ := a - α * f x
  refine ⟨ContinuousMap.const X β + ContinuousMap.const X α * f, ?_, ?_, ?_⟩
  · exact hadd (hconst _) (hmul (hconst _) hf₁)
  · simp +zetaDelta
  · simp +zetaDelta
    linarith [mul_div_cancel₀ (a - b) (sub_ne_zero_of_ne hf₂)]

/-! ### Finite sup/inf closure -/

/-- Closure of `A` under `Finset.sup'` (non-empty finite suprema). -/
lemma sup_mem_finset
    (A : Set C(X, ℝ))
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (s : Finset C(X, ℝ)) (hs : ∀ f ∈ s, f ∈ A) (hne : s.Nonempty) :
    s.sup' hne id ∈ A := by
  induction hne using Finset.Nonempty.cons_induction <;> aesop

/-- Closure of `A` under `Finset.inf'` (non-empty finite infima). -/
lemma inf_mem_finset
    (A : Set C(X, ℝ))
    (hinf : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (s : Finset C(X, ℝ)) (hs : ∀ f ∈ s, f ∈ A) (hne : s.Nonempty) :
    s.inf' hne id ∈ A := by
  induction hne using Finset.Nonempty.cons_induction <;> aesop

/-! ### Main Stone–Weierstrass theorems -/

variable [CompactSpace X] [T2Space X]

/-- **Stone–Weierstrass (lattice–algebra, density version)**: a sublattice subalgebra of
    `C(X, ℝ)` containing all constants and separating points is dense. -/
theorem stoneWeierstrass_sublattice_subalgebra_real_dense
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (_hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (_hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (_hinf : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    Dense A := by
  intro f
  have h_subalgebra : (setToSubalgebra A hconst hadd hmul).topologicalClosure = ⊤ :=
    ContinuousMap.subalgebra_topologicalClosure_eq_top_of_separatesPoints _
      (subalgebra_separatesPoints A hconst hadd hmul hsep)
  have h_closure : f ∈ closure (A : Set C(X, ℝ)) := by
    have := congr_arg (fun s => f ∈ s) h_subalgebra; norm_num at this; exact this
  exact h_closure

/-- **Stone–Weierstrass (lattice–algebra, sup-norm ε-approximation version)**:
    every continuous function can be uniformly approximated to within `ε` by a member of `A`. -/
theorem stoneWeierstrass_sublattice_subalgebra_real
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hinf : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    ∀ (f : C(X, ℝ)) (ε : ℝ), 0 < ε → ∃ g ∈ A, ‖f - g‖ < ε := by
  intro f ε hε
  have hf_closure : f ∈ closure A :=
    stoneWeierstrass_sublattice_subalgebra_real_dense A hconst hadd hneg hmul hsup hinf hsep f
  rw [Metric.mem_closure_iff] at hf_closure
  simpa only [dist_eq_norm] using hf_closure ε hε

/-- **Stone–Weierstrass (lattice–algebra, pointwise ε-approximation version)**:
    every continuous function can be pointwise approximated to within `ε` by a member of `A`. -/
theorem stoneWeierstrass_sublattice_subalgebra_real_eps
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hinf : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    ∀ (f : C(X, ℝ)) (ε : ℝ), 0 < ε → ∃ g ∈ A, ∀ x : X, |f x - g x| < ε := by
  intro f ε hε
  obtain ⟨g, hg, hfg⟩ :=
    stoneWeierstrass_sublattice_subalgebra_real A hconst hadd hneg hmul hsup hinf hsep f ε hε
  exact ⟨g, hg, fun x => lt_of_le_of_lt (ContinuousMap.norm_coe_le_norm (f - g) x) hfg⟩

end