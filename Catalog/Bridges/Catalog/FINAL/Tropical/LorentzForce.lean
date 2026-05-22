/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license.

# Discrete Magnetic Perturbation for Tropical Shortest-Path Geometry

This module formalizes a graph-theoretic analogue of Lorentz-force deflection in the
tropical (min-plus) metric setting. The core result is that adding an antisymmetric
"vector potential" `A` to edge weights perturbs tropical path length by at most the
total flux budget seen along a path.

## Main results

* `pathWeight_charged_eq` — exact algebraic identity decomposing charged path weight
* `magneticSum_abs_le` — magnetic sum bounded by path length times max field strength
* `pathWeight_charged_sub_le` — main pathwise Lorentz bound
* `finset_min_perturbation_le` — finite-minimum tropical stability lemma
* `tropicalDistance_charged_sub_le` — distance-level Lorentz-force bound
* `magneticSum_exact` — gauge invariance: exact potentials telescope
* `magneticSum_exact_cycle_zero` — exact potentials have zero cycle flux

## Keywords

tropical geometry, shortest paths, min-plus algebra, discrete gauge theory,
magnetic perturbation, Lorentz force analogue, Hamilton–Jacobi, robust optimization,
graph transport, Aharonov–Bohm, tropical metric stability, certified bounds
-/

import Mathlib

open Finset

/-! ## Core Definitions -/

/-- The charged weight function: original weight plus charge times vector potential. -/
def chargedWeight {V : Type*} (W A : V → V → ℝ) (q : ℝ) : V → V → ℝ :=
  fun u v => W u v + q * A u v

/-- The number of edges in a path represented as a list of vertices. -/
def pathLength {V : Type*} (p : List V) : ℕ :=
  p.length - 1

/-- The total weight of a path under a given weight function. -/
def pathWeight {V : Type*} (W : V → V → ℝ) : List V → ℝ
  | [] => 0
  | [_] => 0
  | u :: v :: xs => W u v + pathWeight W (v :: xs)

/-- The magnetic sum (total vector potential flux) along a path. -/
def magneticSum {V : Type*} (A : V → V → ℝ) : List V → ℝ
  | [] => 0
  | [_] => 0
  | u :: v :: xs => A u v + magneticSum A (v :: xs)

/-- Consecutive edge pairs in a path. -/
def pathEdges {V : Type*} : List V → List (V × V)
  | [] => []
  | [_] => []
  | u :: v :: xs => (u, v) :: pathEdges (v :: xs)

/-! ## Algebraic Identity: Charged Weight Decomposition -/

/-
The charged path weight decomposes as the original weight plus charge times magnetic sum.
-/
theorem pathWeight_charged_eq
    {V : Type*} (W A : V → V → ℝ) (q : ℝ) :
    ∀ p : List V,
      pathWeight (chargedWeight W A q) p = pathWeight W p + q * magneticSum A p := by
  intro p
  induction' p with u p ih;
  · unfold chargedWeight magneticSum; aesop;
  · rcases p with ( _ | ⟨ v, p ⟩ ) <;> simp_all +decide [ pathWeight, magneticSum ];
    unfold chargedWeight; ring;

/-! ## Magnetic Sum Bound -/

/-
The absolute value of the magnetic sum is bounded by maxA times the path length.
-/
theorem magneticSum_abs_le
    {V : Type*} (A : V → V → ℝ) (maxA : ℝ) :
    ∀ p : List V,
      (∀ e ∈ pathEdges p, |A e.1 e.2| ≤ maxA) →
      |magneticSum A p| ≤ maxA * (pathLength p : ℝ) := by
  intro p hp
  induction' p with u p ih;
  · -- The base case is when the path is empty. In this case, the magnetic sum is 0 and the path length is 0.
    simp [pathLength, magneticSum];
  · rcases p with ( _ | ⟨ v, p ⟩ ) <;> simp_all +decide [ pathLength ];
    · rfl;
    · -- By definition of magnetic sum, we have:
      have h_magnetic_sum : magneticSum A (u :: v :: p) = A u v + magneticSum A (v :: p) := by
        rfl;
      rw [ h_magnetic_sum, abs_le ];
      constructor <;> nlinarith [ abs_le.mp ( hp u v ( by exact List.mem_cons_self ) ), abs_le.mp ( ih fun a b hab => hp a b ( by exact List.mem_cons_of_mem _ hab ) ) ]

/-! ## Main Pathwise Lorentz Bound -/

/-
**Main Theorem (Pathwise Magnetic Perturbation Bound).**
For every path `p`, if the vector potential `A` is bounded by `maxA` on edges of `p`,
then the charged path weight differs from the original by at most `|q| * maxA * pathLength p`.
This is the discrete analogue of the Lorentz-force deflection bound.
-/
theorem pathWeight_charged_sub_le
    {V : Type*} (W A : V → V → ℝ) (q maxA : ℝ) :
    ∀ p : List V,
      (∀ e ∈ pathEdges p, |A e.1 e.2| ≤ maxA) →
      |pathWeight (chargedWeight W A q) p - pathWeight W p|
        ≤ |q| * maxA * (pathLength p : ℝ) := by
  intro p hp;
  -- Rewrite the left-hand side using the decomposition from `pathWeight_charged_eq`.
  rw [pathWeight_charged_eq W A q p]
  simp;
  simpa only [ mul_assoc ] using mul_le_mul_of_nonneg_left ( magneticSum_abs_le A maxA p hp ) ( abs_nonneg q )

/-! ## Finite-Minimum Tropical Stability Lemma -/

/-
**Finite-minimum perturbation lemma.** If two real-valued functions on a finite
nonempty set differ by at most `B` pointwise, then their minima differ by at most `B`.
This is the key lemma lifting pathwise bounds to distance-level bounds.
-/
theorem finset_min_perturbation_le
    {ι : Type*}
    (s : Finset ι) (hs : s.Nonempty)
    (f g : ι → ℝ) (B : ℝ) (_hB : 0 ≤ B) :
    (∀ i ∈ s, |f i - g i| ≤ B) →
    |s.inf' hs f - s.inf' hs g| ≤ B := by
  intro h
  have h_le : s.inf' hs f ≤ B + s.inf' hs g := by
    obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' hs g;
    exact le_trans ( Finset.inf'_le _ hi.1 ) ( by linarith [ abs_le.mp ( h i hi.1 ) ] );
  have h_ge : s.inf' hs g ≤ B + s.inf' hs f := by
    obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' hs f;
    exact le_trans ( Finset.inf'_le _ hi.1 ) ( by linarith [ abs_le.mp ( h i hi.1 ) ] );
  exact abs_sub_le_iff.mpr ⟨ by linarith, by linarith ⟩

/-! ## Distance-Level Lorentz-Force Bound -/

/-- A tropical distance defined as the minimum path weight over a finite family of paths. -/
noncomputable def tropicalDistanceOver {V ι : Type*} [Fintype ι] [Nonempty ι]
    (W : V → V → ℝ) (paths : ι → List V) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (fun i => pathWeight W (paths i))

/-
**Distance-Level Lorentz-Force Bound.**
If every path in a finite family has length at most `L` and the vector potential is
uniformly bounded by `maxA`, then the tropical distance under charged weights differs
from the original by at most `|q| * maxA * L`.
-/
theorem tropicalDistance_charged_sub_le
    {V ι : Type*} [Fintype ι] [Nonempty ι]
    (W A : V → V → ℝ) (q maxA : ℝ) (L : ℕ)
    (paths : ι → List V)
    (hA : ∀ i : ι, ∀ e ∈ pathEdges (paths i), |A e.1 e.2| ≤ maxA)
    (hL : ∀ i : ι, pathLength (paths i) ≤ L)
    (hB : 0 ≤ |q| * maxA * (L : ℝ)) :
    |tropicalDistanceOver (chargedWeight W A q) paths -
     tropicalDistanceOver W paths| ≤ |q| * maxA * (L : ℝ) := by
  convert finset_min_perturbation_le Finset.univ Finset.univ_nonempty _ _ _ hB _;
  · exact inferInstance;
  · intro i hi
    have h_bound : |pathWeight (chargedWeight W A q) (paths i) - pathWeight W (paths i)| ≤ |q| * maxA * (pathLength (paths i) : ℝ) := by
      exact pathWeight_charged_sub_le W A q maxA ( paths i ) ( hA i );
    by_cases hq : q = 0;
    · simp_all +decide;
    · by_cases hmaxA : maxA ≥ 0;
      · exact h_bound.trans ( mul_le_mul_of_nonneg_left ( mod_cast hL i ) ( by positivity ) );
      · contrapose! hB;
        rcases L with ( _ | L ) <;> simp_all +decide;
        exact mul_neg_of_neg_of_pos ( mul_neg_of_pos_of_neg ( abs_pos.mpr hq ) hmaxA ) ( by positivity )

/-! ## Gauge Invariance -/

/-
**Gauge invariance for exact potentials.** If the vector potential is an exact
differential `A u v = φ v - φ u`, then the magnetic sum telescopes to
`φ (last vertex) - φ (first vertex)`.
-/
theorem magneticSum_exact
    {V : Type*} (φ : V → ℝ) :
    ∀ (a b : V) (rest : List V),
      magneticSum (fun u v => φ v - φ u) (a :: b :: rest)
        = φ ((a :: b :: rest).getLast (by simp)) - φ a := by
  intro a b rest;
  induction' rest with c rest ih generalizing a b;
  · grind +locals;
  · -- By definition of magneticSum, we can split the sum into the first term and the rest.
    have h_split : magneticSum (fun u v => φ v - φ u) (a :: b :: c :: rest) = (φ b - φ a) + magneticSum (fun u v => φ v - φ u) (b :: c :: rest) := by
      rfl;
    grind +qlia

/-
**Discrete Aharonov–Bohm principle.** For exact potentials, the magnetic flux
around any closed loop is zero. Only the "curl" (non-exact) part of the potential
contributes to cycle flux.
-/
theorem magneticSum_exact_cycle_zero
    {V : Type*} (φ : V → ℝ)
    (a : V) (mid : List V) (hlast : (a :: mid ++ [a]).getLast (by simp) = a) :
    magneticSum (fun u v => φ v - φ u) (a :: mid ++ [a]) = 0 := by
  have h_sum_zero : ∀ (a b : V) (rest : List V),
      magneticSum (fun u v => φ v - φ u) (a :: b :: rest) = φ ((a :: b :: rest).getLast (by simp)) - φ a := by
        exact fun a b rest => magneticSum_exact φ a b rest;
  cases mid <;> simp_all +decide