import Mathlib
import Logic.BasicMonotoneCircuit.Basic

/-!
# Discrete Tropical Riesz Representation Theorem

This file proves the tropical Riesz representation theorem for finite discrete spaces:
every max-plus linear functional on `TropCont X` (for finite `X`) is uniquely represented
as a tropical integral against a weight function `w : X → WithBot ℝ`:

  `Λ(f) = sup_{x ∈ X} (w(x) + f(x))`

This is the idempotent analogue of the classical fact that every positive linear functional
on `C(X)` for finite `X` is integration against a measure `μ`:

  `Λ(f) = Σ_x μ(x) · f(x)`

## Main results

- `deltaWeight`: extraction of point weights from a functional
- `tropical_basis_decomp`: decomposition of functions into tropical basis functions
- `finite_representation_formula`: the representation `Λ(f) = sup_x (w(x) + f(x))`
- `tropical_riesz_finite`: existence and uniqueness of the representing weight

## Mathematical significance

This is the discrete tropical Riesz theorem: the "states" on the tropical function algebra
over a finite set are exactly the tropical measures (= weight functions). This theorem
gives an algorithmic normal form for every max-plus linear functional and establishes the
foundation for the continuous extension to compact Hausdorff spaces.
-/

noncomputable section

open Finset

variable {X : Type*} [Fintype X] [DecidableEq X] [TopologicalSpace X] [DiscreteTopology X]

/-! ## Tropical basis functions -/

/-- The tropical basis function (tropical Dirac delta) at a point `x₀`:
`δ_{x₀}(y) = 0` if `y = x₀`, `⊥` (= -∞) otherwise.

This is the tropical analogue of the indicator function of a singleton. -/
def tropBasis (x₀ : X) : TropCont X :=
  ⟨fun y => if y = x₀ then 0 else ⊥, continuous_of_discreteTopology⟩

omit [Fintype X] in
@[simp]
theorem tropBasis_apply_self (x : X) : tropBasis x x = 0 := by simp [tropBasis]

omit [Fintype X] in
@[simp]
theorem tropBasis_apply_ne {x y : X} (h : y ≠ x) : tropBasis x y = ⊥ := by
  simp [tropBasis, h]

/-! ## Point weights -/

/-- The weight (tropical mass) that a functional assigns to a point `x`.
Defined as `Λ(δ_x)` where `δ_x` is the tropical basis function at `x`. -/
def deltaWeight (Λ : TropicalFunctional X) (x : X) : WithBot ℝ :=
  Λ.toFun (tropBasis x)

/-! ## Decomposition into basis functions -/

omit [TopologicalSpace X] [DiscreteTopology X] in
/-- Any function `f : X → WithBot ℝ` on a finite set equals the supremum of
`f(x) + δ_x(y)` over all `x`. This is the tropical analogue of writing a function
as a linear combination of indicator functions. -/
theorem tropical_basis_decomp (f : X → WithBot ℝ) (y : X) :
    f y = Finset.univ.sup (fun x => if y = x then f x else ⊥) := by
  apply le_antisymm
  · have h1 : (if y = y then f y else (⊥ : WithBot ℝ)) = f y := by simp
    calc f y = if y = y then f y else ⊥ := h1.symm
    _ ≤ Finset.univ.sup (fun x => if y = x then f x else ⊥) :=
        @Finset.le_sup _ _ _ _ Finset.univ (fun x => if y = x then f x else ⊥)
          y (Finset.mem_univ y)
  · apply Finset.sup_le
    intro x _
    by_cases h : y = x
    · simp [h]
    · simp [h]

/-- Shifted tropical basis: the function `y ↦ c + δ_{x₀}(y)`, which equals
`c` at `x₀` and `⊥` elsewhere. -/
def shiftedBasis (c : WithBot ℝ) (x₀ : X) : TropCont X :=
  ⟨fun y => if y = x₀ then c else ⊥, continuous_of_discreteTopology⟩

omit [Fintype X] in
@[simp]
theorem shiftedBasis_apply_self (c : WithBot ℝ) (x : X) :
    shiftedBasis c x x = c := by simp [shiftedBasis]

omit [Fintype X] in
@[simp]
theorem shiftedBasis_apply_ne (c : WithBot ℝ) {x y : X} (h : y ≠ x) :
    shiftedBasis c x y = ⊥ := by simp [shiftedBasis, h]

omit [Fintype X] in
/-- The shifted basis function equals `c + δ_{x₀}` pointwise. -/
theorem shiftedBasis_eq_add (c : WithBot ℝ) (x₀ : X) (y : X) :
    shiftedBasis c x₀ y = c + tropBasis x₀ y := by
  simp [shiftedBasis, tropBasis]; split_ifs <;> simp

omit [Fintype X] in
/-- The value of a functional on a shifted basis function. -/
theorem map_shiftedBasis (Λ : TropicalFunctional X) (c : WithBot ℝ) (x₀ : X) :
    Λ.toFun (shiftedBasis c x₀) = c + deltaWeight Λ x₀ :=
  Λ.map_addConst' c (tropBasis x₀) (shiftedBasis c x₀) (shiftedBasis_eq_add c x₀)

/-! ## Finite sup preservation -/

/-- An arbitrary function on a discrete space, lifted to `TropCont`. -/
def mkTropCont (f : X → WithBot ℝ) : TropCont X :=
  ⟨f, continuous_of_discreteTopology⟩

/-- Pointwise sup of a finite family of continuous functions. -/
def finsetTropSup (s : Finset ι) (f : ι → TropCont X) : TropCont X :=
  ⟨fun x => s.sup (fun i => f i x), continuous_of_discreteTopology⟩

omit [Fintype X] [DecidableEq X] in
@[simp]
theorem finsetTropSup_apply (s : Finset ι) (f : ι → TropCont X) (x : X) :
    finsetTropSup s f x = s.sup (fun i => f i x) := rfl

omit [Fintype X] [DecidableEq X] in
/-- A tropical functional preserves finite suprema (induction on `Finset`). -/
theorem TropicalFunctional.map_finsetSup (Λ : TropicalFunctional X) (s : Finset ι)
    (hs : s.Nonempty) (f : ι → TropCont X) :
    Λ.toFun (finsetTropSup s f) = s.sup (fun i => Λ.toFun (f i)) := by
  induction' hs using Finset.Nonempty.cons_induction with i s hi ih
  · unfold finsetTropSup; aesop
  · convert Λ.map_sup (f s) (finsetTropSup hi f) using 1
    · congr! 1; ext x; simp +decide [Finset.sup_cons, TropCont.tsup]
    · aesop

omit [Fintype X] in
/-- Lower bound: each shifted basis value is at most the functional value. -/
theorem deltaWeight_add_le (Λ : TropicalFunctional X) (f : TropCont X) (x : X) :
    deltaWeight Λ x + f x ≤ Λ.toFun f := by
  have h_shifted_le : ∀ y, shiftedBasis (f x) x y ≤ f y := by unfold shiftedBasis; aesop
  exact Λ.monotone' h_shifted_le |> le_trans (by simp +decide [add_comm, map_shiftedBasis])

/-- **Representation formula**: the functional value equals the sup of shifted basis values. -/
theorem finite_representation_formula [Nonempty X]
    (Λ : TropicalFunctional X) (f : TropCont X) :
    Λ.toFun f = Finset.univ.sup (fun x => deltaWeight Λ x + f x) := by
  convert TropicalFunctional.map_finsetSup Λ Finset.univ Finset.univ_nonempty
    (fun x => shiftedBasis (f x) x) using 1
  · congr! 1; ext x; convert tropical_basis_decomp (fun y => f y) x using 1
  · simp +decide only [map_shiftedBasis, add_comm]

/-! ## The discrete tropical Riesz representation theorem -/

/-- **Discrete Tropical Riesz Representation Theorem.**
Every max-plus linear functional on `TropCont X` for a finite discrete space `X`
is uniquely represented by a weight function `w : X → WithBot ℝ`:

  `Λ(f) = sup_{x ∈ X} (w(x) + f(x))`

This is the tropical/idempotent analogue of the classical Riesz representation theorem,
which states that positive linear functionals on `C(X)` correspond to measures.

The unique representing weight is `w(x) = Λ(δ_x)`, where `δ_x` is the tropical
basis function (= 0 at x, -∞ elsewhere). -/
theorem tropical_riesz_finite [Nonempty X]
    (Λ : TropicalFunctional X) :
    ∃! w : X → WithBot ℝ,
      ∀ f : TropCont X,
        Λ.toFun f = Finset.univ.sup (fun x => w x + f x) := by
  refine ⟨fun x => deltaWeight Λ x, fun f => finite_representation_formula Λ f, ?_⟩
  intro w hw
  funext x
  have := hw (tropBasis x)
  refine le_antisymm ?_ ?_
  · exact this.symm ▸ Finset.le_sup (f := fun x₁ => w x₁ + (tropBasis x) x₁)
      (Finset.mem_univ x) |> le_trans (by simp +decide [tropBasis])
  · exact this.le.trans (Finset.sup_le fun y _ => by
      by_cases hy : y = x <;> simp +decide [hy, tropBasis])

end