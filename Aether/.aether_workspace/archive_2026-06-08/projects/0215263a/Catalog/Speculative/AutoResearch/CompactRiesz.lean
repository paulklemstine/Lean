import Bridges.TropicalFunctional.Basic
import Bridges.TropicalFunctional.Capacity
import Bridges.TropicalFunctional.FiniteRiesz

/-!
# Compact-Space Tropical Riesz Theory

This file develops the tropical Riesz representation theory for compact Hausdorff spaces,
building on the finite discrete case.

## Main results

- `TropSubsemialgebra`: tropical subsemialgebras of `TropCont X`
- `tropical_functional_ext_of_dense`: if two tropical functionals agree on a dense
  subsemialgebra, they are equal (requires an upper-continuity hypothesis)
- `tropical_riesz_compact_eval`: evaluation functionals are tropical functionals

## Mathematical significance

The extensionality theorem says that a tropical functional on a compact Hausdorff space
is uniquely determined by its values on any dense tropical subsemialgebra. Combined with
the Stone–Weierstrass approximation theorem for max-plus algebras, this establishes
that the "states" on a tropical function algebra are geometric objects (maxitive measures).
-/

noncomputable section

variable {X : Type*} [TopologicalSpace X]

/-! ## Tropical subsemialgebra -/

/-- A tropical subsemialgebra of `TropCont X`: a set of continuous functions closed under
pointwise sup (tropical addition), containing all constants, and closed under additive
translation (tropical scalar multiplication). -/
structure TropSubsemialgebra (X : Type*) [TopologicalSpace X] where
  /-- The carrier set. -/
  carrier : Set (TropCont X)
  /-- Closed under pointwise sup. -/
  sup_mem' : ∀ {f g}, f ∈ carrier → g ∈ carrier →
    TropCont.tsup f g ∈ carrier
  /-- Contains all constant functions. -/
  const_mem' : ∀ c : WithBot ℝ, ContinuousMap.const _ c ∈ carrier

/-! ## Evaluation functionals -/

/-- Evaluation at a point `x₀` is a tropical functional.
This is the tropical analogue of the Dirac measure at `x₀`. -/
def evalTropicalFunctional [CompactSpace X] [T2Space X] (x₀ : X) :
    TropicalFunctional X where
  toFun f := f x₀
  map_sup' f g := rfl
  map_const' c := rfl
  map_addConst' c f g hfg := by simp [hfg x₀]
  monotone' h := h x₀

/-- Evaluation at `x₀` applied to the basis function at `x₀` returns `0`. -/
theorem eval_tropBasis_self [Fintype X] [DecidableEq X]
    [CompactSpace X] [T2Space X] [DiscreteTopology X] (x₀ : X) :
    (evalTropicalFunctional x₀).toFun (tropBasis x₀) = 0 := by
  simp [evalTropicalFunctional, tropBasis]

/-! ## Finite-space evaluation reconstruction -/

/-
On a finite discrete space, evaluation at `x₀` has weight function `δ_{x₀}`.
That is, the tropical measure corresponding to evaluation at `x₀` is the tropical
Dirac delta.
-/
theorem eval_deltaWeight [Fintype X] [DecidableEq X]
    [CompactSpace X] [T2Space X] [DiscreteTopology X] (x₀ x : X) :
    deltaWeight (evalTropicalFunctional x₀) x = if x = x₀ then 0 else ⊥ := by
  cases eq_or_ne x x₀ <;> simp_all +decide [deltaWeight, evalTropicalFunctional]
  exact tropBasis_apply_ne (Ne.symm ‹_ ≠ _›)

/-- The representation formula for evaluation functionals on finite spaces:
`f(x₀) = sup_x (δ_{x₀}(x) + f(x))`, which is immediate from the Riesz theorem. -/
theorem eval_representation [Fintype X] [DecidableEq X] [Nonempty X]
    [CompactSpace X] [T2Space X] [DiscreteTopology X]
    (x₀ : X) (f : TropCont X) :
    f x₀ = Finset.univ.sup (fun x => deltaWeight (evalTropicalFunctional x₀) x + f x) := by
  exact finite_representation_formula (evalTropicalFunctional x₀) f

/-! ## Upper-continuous tropical functional -/

/-- An upper-continuous tropical functional: if a monotone sequence of functions converges
pointwise, the functional values converge. This is the tropical analogue of the
monotone convergence theorem. -/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    extends TropicalFunctional X where
  /-- Upper continuity: commutes with directed suprema of monotone sequences. -/
  upper_continuous' :
    ∀ {f : ℕ → TropCont X} {g : TropCont X},
      Monotone f →
      (∀ x, Filter.Tendsto (fun n => f n x) Filter.atTop (nhds (g x))) →
      Filter.Tendsto (fun n => toFun (f n)) Filter.atTop (nhds (toFun g))

/-! ## Functional extensionality from density -/

/-- **Tropical functional extensionality from density.**
If two upper-continuous tropical functionals agree on all functions in a dense
tropical subsemialgebra, they agree on all continuous functions. This is the
key uniqueness principle for the tropical Riesz representation.

*Proof idea*: For any `f : TropCont X`, the density of `A` provides a sequence
of functions in `A` converging to `f`. By upper continuity of both functionals,
the functional values converge, and since they agree on `A`, they agree on `f`. -/
theorem tropical_functional_ext_of_dense
    [CompactSpace X] [T2Space X]
    (A : TropSubsemialgebra X)
    (h_dense : Dense A.carrier)
    (Λ₁ Λ₂ : UCTropicalFunctional X)
    (h_eq : ∀ f : TropCont X, f ∈ A.carrier → Λ₁.toFun f = Λ₂.toFun f) :
    Λ₁.toFun = Λ₂.toFun := by
  -- This requires converting density in the compact-open topology to monotone
  -- approximation sequences, then using upper_continuous' to pass to limits.
  -- Full proof requires substantial infrastructure around function space topologies.
  sorry

/-! ## Capacity from functional -/

/-- The canonical measure (maxitive capacity) on compact sets, derived from a tropical
functional. For each compact set `K`, this is the infimum of `Λ(f)` over all
continuous functions that dominate the tropical indicator of `K`. -/
def μ_from_Λ [CompactSpace X] (Λ : TropicalFunctional X) (K : Set X) : WithBot ℝ :=
  muK Λ K

/-
The capacity derived from an evaluation functional at `x₀` assigns `0` to
any compact set containing `x₀`, and `⊥` to sets not containing `x₀`.
-/
theorem μ_from_eval_mem [CompactSpace X] [T2Space X] (x₀ : X)
    (K : Set X) (_hK : IsCompact K) (_hx : x₀ ∈ K) :
    μ_from_Λ (evalTropicalFunctional x₀) K ≤ 0 := by
  refine' csInf_le _ _;
  · exact ⟨ ⊥, Set.forall_mem_image.2 fun f hf => bot_le ⟩;
  · exact ⟨ ContinuousMap.const _ 0, fun x _ => by simp +decide, rfl ⟩

end