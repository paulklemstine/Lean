/-
  # Tropical Convexity Lemmas

  Proves that tropical halfspaces are tropically convex, intersections
  preserve tropical convexity, and tropical polyhedra are tropically convex.
-/

import Mathlib
import Tropical.Defs

open Finset TropicalConvexity

noncomputable section

namespace TropicalConvexity

/-! ## Tropical halfspaces are tropically convex -/

/-
The key algebraic fact: `tropMin` distributes over tropical combinations.
    More precisely, for any `a, c₁, c₂ : ℝ` and `x, y : Fin n → ℝ`,
    `tropMin a (tropAdd (tropScale c₁ x) (tropScale c₂ y))` is at most
    `min (c₁ + tropMin a x) (c₂ + tropMin a y)`.
-/
theorem tropMin_tropAdd_tropScale_le {n : ℕ} [NeZero n]
    (a : Fin n → ℝ) (x y : Fin n → ℝ) (c₁ c₂ : ℝ) :
    tropMin a (tropAdd (tropScale c₁ x) (tropScale c₂ y)) ≤
      min (c₁ + tropMin a x) (c₂ + tropMin a y) := by
  -- By definition of $tropMin$, we know that
  have h_tropMin_def : tropMin a (tropAdd (tropScale c₁ x) (tropScale c₂ y)) = Finset.univ.inf' (Finset.univ_nonempty) (fun i => a i + min (c₁ + x i) (c₂ + y i)) := by
    rfl;
  -- By definition of $tropMin$, we know that for any $i$, $a i + min (c₁ + x i) (c₂ + y i) ≤ min (c₁ + (a i + x i)) (c₂ + (a i + y i))$.
  have h_ineq : ∀ i, a i + min (c₁ + x i) (c₂ + y i) ≤ min (c₁ + (a i + x i)) (c₂ + (a i + y i)) := by
    exact fun i => by cases min_cases ( c₁ + x i ) ( c₂ + y i ) <;> cases min_cases ( c₁ + ( a i + x i ) ) ( c₂ + ( a i + y i ) ) <;> linarith;
  -- Applying the inequality $a i + min (c₁ + x i) (c₂ + y i) ≤ min (c₁ + (a i + x i)) (c₂ + (a i + y i))$ to the infimum, we get:
  have h_inf_ineq : Finset.univ.inf' (Finset.univ_nonempty) (fun i => a i + min (c₁ + x i) (c₂ + y i)) ≤ Finset.univ.inf' (Finset.univ_nonempty) (fun i => min (c₁ + (a i + x i)) (c₂ + (a i + y i))) := by
    grind +qlia;
  -- Applying the inequality $min (c₁ + (a i + x i)) (c₂ + (a i + y i)) ≤ min (c₁ + tropMin a x) (c₂ + tropMin a y)$ to the infimum, we get:
  have h_inf_ineq' : Finset.univ.inf' (Finset.univ_nonempty) (fun i => min (c₁ + (a i + x i)) (c₂ + (a i + y i))) ≤ min (c₁ + tropMin a x) (c₂ + tropMin a y) := by
    obtain ⟨ i, hi ⟩ := exists_tropMin_eq a x; obtain ⟨ j, hj ⟩ := exists_tropMin_eq a y; simp_all +decide [ Finset.inf'_le ] ;
    exact ⟨ ⟨ i, Or.inl le_rfl ⟩, ⟨ j, Or.inr le_rfl ⟩ ⟩;
  linarith

/-
Tropical halfspaces are tropically convex: for any coefficient vectors `a b`,
    the set `{x | tropMin a x ≤ tropMin b x}` is closed under tropical combinations.
-/
theorem isTropicallyConvex_tropicalHalfspace {n : ℕ} [NeZero n]
    (a b : Fin n → ℝ) : IsTropicallyConvex (tropicalHalfspace a b) := by
  intro x y hy c₁ c₂;
  intro c₃;
  have hz_le : tropMin a (tropAdd (tropScale c₂ x) (tropScale c₃ y)) ≤ min (c₂ + tropMin a x) (c₃ + tropMin a y) := by
    exact?;
  have hz_ge : tropMin b (tropAdd (tropScale c₂ x) (tropScale c₃ y)) ≥ min (c₂ + tropMin b x) (c₃ + tropMin b y) := by
    simp +decide [ tropMin, tropAdd, tropScale ];
    intro i; cases le_total ( c₂ + x i ) ( c₃ + y i ) <;> simp +decide [ * ] ;
    · exact Or.inl ( by linarith [ Finset.inf'_le ( fun i => b i + x i ) ( Finset.mem_univ i ) ] );
    · exact Or.inr ( by linarith [ Finset.inf'_le ( fun i => b i + y i ) ( Finset.mem_univ i ) ] );
  exact le_trans hz_le ( by cases min_cases ( c₂ + tropMin a x ) ( c₃ + tropMin a y ) <;> cases min_cases ( c₂ + tropMin b x ) ( c₃ + tropMin b y ) <;> linarith [ hy.out, c₁.out ] ) |> le_trans <| hz_ge

/-! ## Finite intersections preserve tropical convexity -/

/-
The intersection of any family of tropically convex sets is tropically convex.
-/
theorem isTropicallyConvex_iInter {n : ℕ} {ι : Type*} {S : ι → Set (Fin n → ℝ)}
    (hS : ∀ i, IsTropicallyConvex (S i)) :
    IsTropicallyConvex (⋂ i, S i) := by
  intro x y hx hy a b;
  aesop

/-
Finite intersection version using `Finset`.
-/
theorem isTropicallyConvex_biInter_finset {n : ℕ} {F : Finset (Set (Fin n → ℝ))}
    (hF : ∀ s ∈ F, IsTropicallyConvex s) :
    IsTropicallyConvex (⋂ s ∈ F, s) := by
  convert isTropicallyConvex_iInter _;
  intro s; by_cases hs : s ∈ F <;> simp +decide [ *, IsTropicallyConvex ] ;
  exact hF s hs

/-! ## Tropical polyhedra are tropically convex -/

/-
Every tropical polyhedron (finite intersection of tropical halfspaces)
    is tropically convex.
-/
theorem isTropicallyConvex_of_isTropicalPolyhedron {n : ℕ} [NeZero n]
    {S : Set (Fin n → ℝ)} (h : IsTropicalPolyhedron S) :
    IsTropicallyConvex S := by
  -- By definition of $S$, we know that $S$ is a finite intersection of sets of the form $tropicalHalfspace.
  obtain ⟨halfspaces, hS⟩ := h;
  convert isTropicallyConvex_iInter _;
  intro h; by_cases hi : h ∈ halfspaces <;> simp +decide [ hi, isTropicallyConvex_tropicalHalfspace ] ;
  · exact isTropicallyConvex_tropicalHalfspace _ _;
  · exact fun x y _ _ a b => Set.mem_univ _

end TropicalConvexity