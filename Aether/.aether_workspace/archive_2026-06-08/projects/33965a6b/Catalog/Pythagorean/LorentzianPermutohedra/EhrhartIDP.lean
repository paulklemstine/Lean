/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.LorentzianPermutohedra.Defs

/-!
# Ehrhart Theory of Lorentzian Permutohedra — IDP Theorems

This file proves the Integer Decomposition Property (IDP) for the
Minkowski sum dilation model and derives structural consequences.

## Main Results

1. `idp_of_minkowski_sum` — The Minkowski sum dilation model satisfies IDP
2. `peel_off_of_minkowski_sum` — Peel-off lemma: extract one point from a sum
3. `ehrhartCount_pos` — Ehrhart count is positive for nonempty P
4. `dilate_sum_eq` — Coordinate sum scales linearly under dilation
5. `mconvex_exists_decrease` — Exchange property yields opposing coordinate
6. `minkowski_sum_card_lower_bound` — |P + Q| ≥ max(|P|, |Q|)

## Proof Architecture

The IDP proof follows Strategy A (exchange-peeling induction via M-convexity):
1. A point in finsetDilate (t+1) P decomposes as y + z with y ∈ P, z ∈ finsetDilate t P
2. By induction on t, z decomposes into t points from P
3. Concatenating via Fin.cons gives the full (t+1) decomposition
-/

open Finset BigOperators Function

noncomputable section

namespace EhrhartIDP

/-! ## Peel-Off Lemma -/

/-- **Peel-off lemma**: every point in the (t+1)-fold Minkowski sum
    can be written as y + z where y ∈ P and z is in the t-fold sum.
    This is the inductive engine for the IDP proof. -/
theorem peel_off_of_minkowski_sum {n : ℕ} {t : ℕ}
    {P : Finset (Fin n → ℤ)} {x : Fin n → ℤ}
    (hx : x ∈ finsetDilate (t + 1) P) :
    ∃ y ∈ P, ∃ z ∈ finsetDilate t P, ∀ i, x i = y i + z i := by
  rw [mem_finsetDilate_succ] at hx
  obtain ⟨y, hy, z, hz, rfl⟩ := hx
  exact ⟨y, hy, z, hz, fun i => rfl⟩

/-! ## IDP for Minkowski Sum Dilation -/

/-
**IDP Theorem**: The Minkowski sum dilation model satisfies the
    Integer Decomposition Property. Every point in `finsetDilate t P`
    decomposes as a sum of exactly t points from P.

    **Proof sketch**: By induction on t.
    - Base t=1: x ∈ finsetDilate 1 P = P + {0}, so x = y + 0 for y ∈ P.
    - Step t+1: x ∈ finsetDilate (t+1) P means x = y + z with y ∈ P, z ∈ finsetDilate t P.
      By IH, z = ∑ᵢ xsᵢ. Then x = y + ∑ᵢ xsᵢ = ∑ⱼ (Fin.cons y xs)ⱼ.
-/
theorem idp_of_minkowski_sum {n : ℕ} (P : Finset (Fin n → ℤ)) :
    IntegerDecompositionProperty P := by
      intro t ht;
      induction' ht with t ht ih;
      · intro x hx
        rw [mem_finsetDilate_succ] at hx
        obtain ⟨y, hy, z, hz, hx_eq⟩ := hx;
        use fun _ => y; simp_all +decide [ Finset.mem_singleton ] ;
        exact funext fun i => by simp +decide [ latticeAdd ] ;
      · intro x hx
        obtain ⟨y, hyP, z, hzDilate, hx_eq⟩ := mem_finsetDilate_succ.mp hx
        obtain ⟨xs, hxsP, hxs_sum⟩ := ih z hzDilate
        use Fin.cons y xs
        simp [hx_eq, hxs_sum];
        exact ⟨ fun i => by cases i using Fin.inductionOn <;> simp +decide [ * ], rfl ⟩

/-
**Corollary**: For any t ≥ 1, every point in finsetDilate t P
    can be peeled: one point from P plus a point in the (t-1)-fold dilation.
-/
theorem exists_peeloff {n : ℕ} {t : ℕ} (ht : 1 ≤ t)
    {P : Finset (Fin n → ℤ)} {x : Fin n → ℤ}
    (hx : x ∈ finsetDilate t P) :
    ∃ y ∈ P, ∃ z ∈ finsetDilate (t - 1) P, ∀ i, x i = y i + z i := by
      convert peel_off_of_minkowski_sum ( show x ∈ finsetDilate ( t - 1 + 1 ) P from ?_ ) using 1;
      rwa [ Nat.sub_add_cancel ht ]

/-! ## Ehrhart Count Properties -/

/-
Ehrhart count is positive for nonempty P at any dilation.
-/
theorem ehrhartCount_pos {n : ℕ} (P : Finset (Fin n → ℤ))
    (hP : P.Nonempty) (t : ℕ) : 0 < ehrhartCount P t := by
      induction' t with t ih;
      · exact Finset.card_pos.mpr ⟨ fun _ => 0, by simp +decide [ ehrhartCount ] ⟩;
      · obtain ⟨ x, hx ⟩ := hP; obtain ⟨ y, hy ⟩ := Finset.card_pos.mp ih; use Finset.card_pos.mpr ⟨ _, Finset.mem_image.mpr ⟨ ( x, y ), Finset.mem_product.mpr ⟨ hx, hy ⟩, rfl ⟩ ⟩ ;

/-
Ehrhart count at t=1 equals the cardinality of P.
-/
theorem ehrhartCount_one_eq {n : ℕ} (P : Finset (Fin n → ℤ))
    (hP : P.Nonempty) :
    ehrhartCount P 1 = (P.image id).card := by
      -- By definition of `finsetDilate`, we know that `finsetDilate 1 P` is the Minkowski sum of `P` and `{0}`.
      have h_dilate_one : finsetDilate 1 P = P.image (fun x => x) := by
        -- By definition of `finsetDilate`, we have `finsetDilate 1 P = P + {0}`. Since adding the zero vector doesn't change the set, this simplifies to `P`.
        ext; simp [finsetDilate, finsetMinkowskiSum];
        simp +decide [ latticeAdd, funext_iff ];
        exact ⟨ fun ⟨ a, ha, h ⟩ => by simpa [ funext h ] using ha, fun ha => ⟨ _, ha, fun _ => rfl ⟩ ⟩;
      exact congr_arg Finset.card h_dilate_one

/-! ## M-Convex Structural Theorems -/

/-
In an M-convex set, if αᵢ > βᵢ for some i, then there exists j
    with αⱼ < βⱼ. Follows directly from the exchange property.
-/
theorem mconvex_exists_decrease {n : ℕ} {S : Finset (Fin n → ℤ)}
    (hS : IsMConvex S)
    {α β : Fin n → ℤ} (hα : α ∈ S) (hβ : β ∈ S)
    {i : Fin n} (hi : α i > β i) :
    ∃ j : Fin n, α j < β j := by
      exact hS α hα β hβ i hi |> fun ⟨ j, hj₁, hj₂ ⟩ => ⟨ j, hj₁ ⟩

/-
The edge direction vector eᵢ - eⱼ sums to zero.
-/
theorem edgeDir_sum_zero {n : ℕ} (i j : Fin n) (hij : i ≠ j) :
    ∑ k, edgeDir i j k = 0 := by
      unfold edgeDir; simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', hij ] ;
      grind

/-
M-convex exchange preserves coordinate sum: if α ∈ S and we perform
    an exchange step α - eᵢ + eⱼ, the result has the same coordinate sum.
-/
theorem exchange_preserves_sum {n : ℕ} {α : Fin n → ℤ} (i j : Fin n) (hij : i ≠ j) :
    ∑ k, (fun k => α k - edgeDir i j k) k = ∑ k, α k := by
      unfold edgeDir; simp +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', * ] ;
      grind

/-! ## Coordinate Sum Under Dilation -/

/-
The coordinate sum of a point in finsetDilate t P equals t times the
    common coordinate sum of P, when P has constant sum.
-/
theorem dilate_sum_eq {n : ℕ} {P : Finset (Fin n → ℤ)}
    (hcs : HasConstantSum P) (hne : P.Nonempty)
    {d : ℤ} (hd : ∀ α ∈ P, ∑ k, α k = d)
    {t : ℕ} {x : Fin n → ℤ} (hx : x ∈ finsetDilate t P) :
    ∑ k, x k = t * d := by
      induction' t with t ih generalizing x;
      · unfold finsetDilate at hx; aesop;
      · obtain ⟨ y, hy, z, hz, hx ⟩ := peel_off_of_minkowski_sum hx;
        simp_all +decide [ Finset.sum_add_distrib, add_mul ];
        ring

/-
For an IDP decomposition, the component sums are consistent.
-/
theorem idp_sum_consistency {n : ℕ}
    {t : ℕ} {x : Fin n → ℤ}
    {xs : Fin t → (Fin n → ℤ)}
    (hsum : x = ∑ i, xs i) :
    ∑ k, x k = ∑ i : Fin t, ∑ k, xs i k := by
      simp +decide only [hsum, sum_apply];
      exact Finset.sum_comm

/-! ## Minkowski Sum Cardinality Bound -/

/-
The Minkowski sum contains at least as many points as each summand
    (via translation).
-/
theorem minkowski_sum_card_lower_bound {n : ℕ}
    (A B : Finset (Fin n → ℤ)) (hA : A.Nonempty) (hB : B.Nonempty) :
    A.card ≤ (finsetMinkowskiSum A B).card := by
      refine' le_trans _ ( Finset.card_le_card _ );
      swap;
      exact Finset.image ( fun a => a + fun _ => hB.choose ‹_› ) A;
      · rw [ Finset.card_image_of_injective _ fun x y hxy => by simpa using hxy ];
      · exact Finset.image_subset_iff.mpr fun x hx => Finset.mem_image.mpr ⟨ ( x, hB.choose ), Finset.mem_product.mpr ⟨ hx, hB.choose_spec ⟩, by aesop ⟩

/-! ## Bridge Theorem: M-Convex ↔ Generalized Permutohedron -/

/-
M-convex sets with constant sum form generalized permutohedra.
    This is the bridge theorem from discrete convex analysis to polyhedral
    combinatorics: the exchange property gives edge-direction structure.
-/
theorem mconvex_is_gen_permutohedron {n : ℕ} {S : Finset (Fin n → ℤ)}
    (hS_mc : IsMConvex S) (hS_cs : HasConstantSum S) (hS_ne : S.Nonempty) :
    IsGenPermutohedronLattice S where
  constSum := hS_cs
  nonempty := hS_ne
  edgeDirs := by
    intro α hα β hβ
    by_cases heq : α = β
    · exact ⟨0, Fin.elim0, by simp [heq]⟩
    ·
      -- Define a function that counts the number of steps needed to transform α into β.
      set dist : (Fin n → ℤ) → ℕ := fun x => ∑ k, Int.natAbs (x k - β k);
      -- By induction on the distance, we can show that there exists a sequence of steps transforming α into β.
      have h_ind : ∀ x ∈ S, dist x > 0 → ∃ y ∈ S, dist y < dist x ∧ ∃ i j : Fin n, i ≠ j ∧ y = fun k => x k - edgeDir i j k := by
        intro x hx hdist_pos
        obtain ⟨i, hi⟩ : ∃ i : Fin n, x i > β i := by
          simp +zetaDelta at *;
          contrapose! hdist_pos;
          have := hS_cs x hx β hβ;
          exact le_of_eq ( by rw [ Finset.sum_eq_zero fun i _ => by rw [ Int.natAbs_eq_zero.mpr ] ; linarith [ hdist_pos i, show x i = β i from le_antisymm ( hdist_pos i ) ( by exact le_of_not_gt fun hi => by have := Finset.sum_lt_sum ( fun a _ => hdist_pos a ) ( show ∃ a, a ∈ Finset.univ ∧ x a < β a from ⟨ i, Finset.mem_univ _, hi ⟩ ) ; aesop ) ] ] );
        obtain ⟨ j, hj₁, hj₂ ⟩ := hS_mc x hx β hβ i hi;
        refine' ⟨ _, hj₂, _, i, j, _, rfl ⟩;
        · refine' Finset.sum_lt_sum _ _;
          · intro k hk; unfold edgeDir; by_cases hi : k = i <;> by_cases hj : k = j <;> simp +decide [ hi, hj ] ;
            · grind;
            · omega;
            · grind;
          · use i; simp [edgeDir];
            omega;
        · grind;
      -- By induction on the distance, we can show that there exists a sequence of steps transforming α into β. Use strong induction on the distance.
      have h_induction : ∀ d : ℕ, ∀ x ∈ S, dist x = d → ∃ m : ℕ, ∃ steps : Fin m → Fin n × Fin n, (∀ k, β k = x k + ∑ t, edgeDir (steps t).1 (steps t).2 k) := by
        intro d x hx hd; induction' d using Nat.strong_induction_on with d ih generalizing x; rcases d with ( _ | d ) <;> simp_all +decide ;
        · use 0; simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, Int.natAbs_eq_zero ] ;
          simp +zetaDelta at *;
          grind;
        · obtain ⟨ i, j, hx', hd', hij ⟩ := h_ind x hx ( by linarith );
          obtain ⟨ m, steps, h ⟩ := ih _ ( by linarith ) _ hx' ( by linarith );
          refine' ⟨ m + 1, Fin.cons ( j, i ) steps, fun k => _ ⟩ ; simp +decide [ Fin.sum_univ_succ, h ];
          unfold edgeDir; simp +decide [ hij, eq_comm ] ; ring;
          grind;
      exact h_induction _ _ hα rfl

end EhrhartIDP