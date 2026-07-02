/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Exact Finite Interpolation by Point-Separating Subalgebras

A core piece of infrastructure for the *NeuralProofMining* programme: a
point-separating unital subalgebra of `C(X, ℝ)` is not merely *dense* (the
Stone–Weierstrass conclusion) — it already **exactly interpolates every finite
dataset**.  Concretely, if `A ⊆ C(X, ℝ)` separates points then for any finite
family of *distinct* inputs `x : Fin n → X` and *arbitrary* target values
`t : Fin n → ℝ`, there is a single element `f ∈ A` with `f (x i) = t i` for all
`i`.

This upgrades the qualitative "separating ⇒ dense" statement to a quantitative,
constructive interpolation principle by building Lagrange-type indicator
functions inside `A`.  It is the exactness backbone behind the network
realizability results in `NetworkRealizability.lean`.

## Main results

* `exists_indicator_of_separatesPoints` — Lagrange indicator: for each index `i`
  a function in `A` that is `1` at `x i` and `0` at every other `x j`.
* `exists_mem_interp_of_separatesPoints` — exact finite interpolation by `A`.

-- !-- Lab Notes -- !--
HYPOTHESIS (I1). Point separation is strong enough to force *exact* finite
interpolation, not only uniform approximation.  The Stone–Weierstrass theorem
throws away the algebraic content (finite products / sums stay inside `A`) by
passing to the topological closure; that content alone already yields exact
interpolation on finite sets.

EXPERIMENT. Build Lagrange indicators `e i = ∏_{j ≠ i} k_{i,j}` where each
`k_{i,j} = (g - g(x j))/(g(x i) - g(x j))` uses a separating witness `g ∈ A`
for the pair `(x i, x j)`.  Each `k_{i,j}` lies in `A` because subalgebras are
closed under constants, subtraction and scalar multiplication; the product lies
in `A` by `Subalgebra.prod_mem`.  Then `f = ∑ i, t i • e i`.
OUTCOME: I1 confirmed — no compactness needed, only that `A` is a subalgebra.

INSIGHT. The construction never touches topology: interpolation is an *algebraic*
consequence of separation.  Compactness only re-enters for density (approximating
functions that are not fixed on a finite set).
-/
import Mathlib

open scoped BigOperators

namespace NeuralProofMining

variable {X : Type*} [TopologicalSpace X]

/-
**Lagrange indicator inside a separating subalgebra.**
If `A ⊆ C(X, ℝ)` separates points and `x : Fin n → X` are distinct, then for each
index `i` there is a function `e ∈ A` with `e (x i) = 1` and `e (x j) = 0` for
`j ≠ i`.
-/
theorem exists_indicator_of_separatesPoints
    (A : Subalgebra ℝ C(X, ℝ)) (hA : A.SeparatesPoints)
    {n : ℕ} (x : Fin n → X) (hx : Function.Injective x) (i : Fin n) :
    ∃ e ∈ A, e (x i) = 1 ∧ ∀ j, j ≠ i → e (x j) = 0 := by
  -- By assumption, $A$ separates points, so for each $j \ne i$, there exists $g_j \in A$ such that $g_j(x_i) \ne g_j(x_j)$.
  obtain ⟨g, hg⟩ : ∃ g : Fin n → C(X, ℝ), (∀ j ≠ i, g j ∈ A ∧ (g j) (x i) ≠ (g j) (x j)) ∧ (∀ j ≠ i, (g j) (x i) = 1) := by
    have h_sep : ∀ j ≠ i, ∃ g : C(X, ℝ), g ∈ A ∧ g (x i) ≠ g (x j) := by
      intro j hj;
      simpa using hA ( hx.ne hj.symm );
    choose! g hg using h_sep;
    refine' ⟨ fun j ↦ if h : j = i then 1 else ( 1 / ( g j ( x i ) - g j ( x j ) ) ) • ( g j - ( g j ( x j ) ) • 1 ), _, _ ⟩ <;> simp_all +decide [ sub_ne_zero ];
    exact fun j hj => A.smul_mem ( A.sub_mem ( hg j hj |>.1 ) ( A.smul_mem ( A.one_mem ) _ ) ) _;
  refine' ⟨ ∏ j ∈ Finset.univ.erase i, ( g j - ContinuousMap.const X ( g j ( x j ) ) ) * ( ContinuousMap.const X ( ( g j ( x i ) - g j ( x j ) ) ⁻¹ ) ), _, _, _ ⟩ <;> simp_all +decide;
  · exact A.prod_mem fun j hj => A.mul_mem ( A.sub_mem ( hg.1 j ( Finset.ne_of_mem_erase hj ) |>.1 ) ( A.algebraMap_mem _ ) ) ( A.algebraMap_mem _ );
  · exact Finset.prod_eq_one fun j hj => mul_inv_cancel₀ ( sub_ne_zero_of_ne ( hg.1 j ( Finset.ne_of_mem_erase hj ) |>.2 ) );
  · exact fun j hj => Finset.prod_eq_zero ( Finset.mem_erase_of_ne_of_mem hj ( Finset.mem_univ j ) ) ( by simp +decide [ hg.2 j hj ] )

/-
**Exact finite interpolation by a point-separating subalgebra.**
If `A ⊆ C(X, ℝ)` separates points, then for any finite family of *distinct*
inputs `x : Fin n → X` and *arbitrary* targets `t : Fin n → ℝ`, some single
element `f ∈ A` satisfies `f (x i) = t i` for every `i`.
-/
theorem exists_mem_interp_of_separatesPoints
    (A : Subalgebra ℝ C(X, ℝ)) (hA : A.SeparatesPoints)
    {n : ℕ} (x : Fin n → X) (hx : Function.Injective x) (t : Fin n → ℝ) :
    ∃ f ∈ A, ∀ i, f (x i) = t i := by
  obtain ⟨e, he⟩ : ∃ e : Fin n → C(X, ℝ), (∀ i, e i ∈ A) ∧ (∀ i, e i (x i) = 1) ∧ (∀ i j, i ≠ j → e i (x j) = 0) := by
    exact ⟨ fun i => Classical.choose ( exists_indicator_of_separatesPoints A hA x hx i ), fun i => Classical.choose_spec ( exists_indicator_of_separatesPoints A hA x hx i ) |>.1, fun i => Classical.choose_spec ( exists_indicator_of_separatesPoints A hA x hx i ) |>.2.1, fun i j hij => Classical.choose_spec ( exists_indicator_of_separatesPoints A hA x hx i ) |>.2.2 j ( Ne.symm hij ) ⟩;
  refine' ⟨ ∑ i, t i • e i, _, _ ⟩ <;> simp_all +decide [ Finset.sum_apply ];
  · exact A.sum_mem fun i _ => A.smul_mem ( he.1 i ) _;
  · intro i; rw [ Finset.sum_eq_single i ] <;> aesop;

end NeuralProofMining