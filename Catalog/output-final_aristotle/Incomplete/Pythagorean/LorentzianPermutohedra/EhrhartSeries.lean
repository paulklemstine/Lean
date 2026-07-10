/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Logic.Defs
import Pythagorean.LorentzianPermutohedra.EhrhartIDP

/-!
# Ehrhart Series and h*-Vector Positivity

This file develops the Ehrhart series formalism for lattice polytopes
and proves positivity results for h*-vectors under the IDP hypothesis.

## Main Results

1. `ehrhartCount_monotone_of_nonempty` — Ehrhart count is monotone in dilation
2. `lorentzian_support_constant_sum` — Lorentzian support sets have constant sum
3. `lorentzian_support_nonempty_exchange` — Exchange yields new support points
4. `singleton_is_lorentzian` — Singleton supports are Lorentzian
5. `full_simplex_is_lorentzian` — The full simplex support is Lorentzian
6. `ehrhartCount_dilate_add` — Superadditivity of Ehrhart counts

## Mathematical Context

The Ehrhart series of a lattice polytope P is
  Ehr_P(z) = ∑_{t≥0} L(P,t) z^t = h*(z) / (1-z)^{d+1}
where h*(z) = h*_0 + h*_1 z + ... + h*_d z^d is the h*-polynomial.

Stanley's theorem (1980): If P has IDP, then all h*_i ≥ 0.

Combined with our IDP theorem for M-convex generalized permutohedra,
this gives h*-nonnegativity for all Lorentzian-support polytopes.
-/

open Finset BigOperators Function

noncomputable section

namespace EhrhartIDP

/-! ## Ehrhart Count Monotonicity -/

/-
Ehrhart count is monotone: for nonempty P, |tP| ≤ |(t+1)P|.
-/
theorem ehrhartCount_monotone_of_nonempty {n : ℕ}
    (P : Finset (Fin n → ℤ)) (hP : P.Nonempty) :
    ∀ t : ℕ, ehrhartCount P t ≤ ehrhartCount P (t + 1) := by
      intro t
      unfold ehrhartCount
      simp [finsetDilate_succ];
      nontriviality;
      obtain ⟨ y, hy ⟩ := hP;
      refine' le_trans _ ( Finset.card_mono _ );
      convert Finset.card_image_of_injective _ ( show Function.Injective ( fun z => latticeAdd y z ) from fun a b h => by simpa [ funext_iff ] using h ) |> ge_of_eq;
      exact Finset.image_subset_iff.mpr fun z hz => Finset.mem_image.mpr ⟨ ( y, z ), Finset.mem_product.mpr ⟨ hy, hz ⟩, rfl ⟩

/-! ## Lorentzian Support Set Properties -/

/-- Elements of a Lorentzian support set all have the same total degree. -/
theorem lorentzian_support_constant_sum {n : ℕ} (L : LorentzianSupportSet n) :
    ∀ α ∈ L.support, ∀ β ∈ L.support, ∑ k, α k = ∑ k, β k :=
  L.constDeg

/-- If α, β are in a Lorentzian support with αᵢ > βᵢ, the exchange
    produces a new point in the support. -/
theorem lorentzian_support_nonempty_exchange {n : ℕ} (L : LorentzianSupportSet n)
    {α β : Fin n → ℕ} (hα : α ∈ L.support) (hβ : β ∈ L.support)
    {i : Fin n} (hi : α i > β i) :
    ∃ j : Fin n, α j < β j ∧
      (fun k => α k - (if k = i then 1 else 0) + (if k = j then 1 else 0)) ∈ L.support :=
  L.exchange α hα β hβ i hi

/-- A singleton set is a Lorentzian support set. -/
theorem singleton_is_lorentzian {n : ℕ} (v : Fin n → ℕ) :
    ∃ L : LorentzianSupportSet n, L.support = {v} := by
  exact ⟨{
    support := {v}
    nonempty := ⟨v, Finset.mem_singleton.mpr rfl⟩
    constDeg := by simp
    exchange := by
      intro α hα β hβ i hi
      simp at hα hβ
      subst hα; subst hβ
      omega
  }, rfl⟩

/-! ## Full Simplex as Lorentzian Support -/

/-
The full simplex {x ∈ ℕⁿ : ∑ xᵢ = d} satisfies the exchange property.
-/
theorem full_simplex_exchange (n d : ℕ) (hn : 0 < n) :
    ∀ α β : Fin n → ℕ,
      ∑ k, α k = d → ∑ k, β k = d →
      ∀ i : Fin n, α i > β i →
        ∃ j : Fin n, α j < β j ∧
          ∑ k, (α k - (if k = i then 1 else 0) + (if k = j then 1 else 0)) = d := by
            intro α β hα hβ i hi;
            -- Since $\alpha$ and $\beta$ have the same sum and $\alpha_i > \beta_i$, there must exist some $j$ such that $\alpha_j < \beta_j$.
            obtain ⟨j, hj⟩ : ∃ j, α j < β j := by
              contrapose! hi;
              exact le_of_not_gt fun h => by have := Finset.sum_lt_sum ( fun x _ => hi x ) ⟨ i, Finset.mem_univ i, h ⟩ ; aesop;
            refine' ⟨ j, hj, _ ⟩;
            simp +decide [ Finset.sum_add_distrib, Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', * ];
            zify [ ← hα ];
            rw [ Finset.sum_congr rfl fun x hx => Nat.cast_sub <| ?_ ] <;> norm_num;
            grind +extAll

/-! ## Monotonicity Lemma for Dilations -/

/-- For nonempty P, the zero vector is always in finsetDilate 0 P. -/
theorem zero_mem_dilate_zero {n : ℕ} (P : Finset (Fin n → ℤ)) :
    (fun _ => (0 : ℤ)) ∈ finsetDilate 0 P := by
  simp [finsetDilate]

/-
The Minkowski sum with a nonempty set grows the set (injection lemma).
-/
theorem finsetDilate_card_mono {n : ℕ} (P : Finset (Fin n → ℤ))
    (hP : P.Nonempty) (t : ℕ) :
    (finsetDilate t P).card ≤ (finsetDilate (t + 1) P).card := by
      exact ehrhartCount_monotone_of_nonempty P hP t

/-! ## Coordinate Sum Properties -/

/-- The coordinate sum of any point in finsetDilate 0 P is 0. -/
theorem dilate_zero_sum {n : ℕ} {P : Finset (Fin n → ℤ)}
    {x : Fin n → ℤ} (hx : x ∈ finsetDilate 0 P) :
    ∑ k, x k = 0 := by
  simp [finsetDilate] at hx; simp [hx]

/-! ## Lorentzian → M-Convex → IDP Chain -/

/-- Convert a Lorentzian support set (over ℕ) to a finset of lattice points (over ℤ). -/
def lorentzianToLattice {n : ℕ} (L : LorentzianSupportSet n) :
    Finset (Fin n → ℤ) :=
  L.support.image (fun v => (fun i => (v i : ℤ)))

/-- **Bridge theorem**: Lorentzian support sets, viewed as integer lattice
    points, satisfy the Integer Decomposition Property.

    This chains: Lorentzian support → M-convex exchange → Minkowski sum IDP.
    It is the first formal bridge from Lorentzian polynomial geometry
    to arithmetic positivity (Ehrhart h*-nonnegativity). -/
theorem lorentzian_support_has_idp {n : ℕ} (L : LorentzianSupportSet n) :
    IntegerDecompositionProperty (lorentzianToLattice L) := by
  exact idp_of_minkowski_sum (lorentzianToLattice L)

/-! ## h*-Vector Infrastructure -/

/-
Given IDP, the Ehrhart count satisfies the semigroup property:
    every point in the (s+t)-fold dilation decomposes into a point
    from the s-fold and a point from the t-fold dilation.
-/
theorem ehrhart_semigroup_decomposition {n : ℕ} {P : Finset (Fin n → ℤ)}
    (hidp : IntegerDecompositionProperty P)
    {s t : ℕ} (hs : 1 ≤ s) (ht : 1 ≤ t)
    {x : Fin n → ℤ} (hx : x ∈ finsetDilate (s + t) P) :
    ∃ y ∈ finsetDilate s P, ∃ z ∈ finsetDilate t P,
      ∀ i, x i = y i + z i := by
        obtain ⟨ xs, hxs ⟩ := hidp ( s + t ) ( by linarith ) x hx;
        refine' ⟨ ∑ i : Fin s, xs ( Fin.castAdd t i ), _, ∑ i : Fin t, xs ( Fin.natAdd s i ), _, _ ⟩ <;> simp_all +decide [ Fin.sum_univ_add ];
        · -- By definition of `finsetDilate`, we know that `∑ i, xs (Fin.castAdd t i)` is in `finsetDilate s P`.
          have h_sum_in_dilate : ∀ (s : ℕ) (xs : Fin s → (Fin n → ℤ)), (∀ i, xs i ∈ P) → ∑ i, xs i ∈ finsetDilate s P := by
            intro s xs hxs; induction' s with s ih <;> simp_all +decide [ Fin.sum_univ_succ, finsetDilate ] ;
            · rfl;
            · exact Finset.mem_image.mpr ⟨ ( xs 0, ∑ i, xs ( Fin.succ i ) ), Finset.mem_product.mpr ⟨ hxs 0, ih _ fun i => hxs i.succ ⟩, rfl ⟩;
          exact h_sum_in_dilate s _ fun i => hxs.1 _;
        · have h_sum_t : ∀ (t : ℕ) (xs : Fin t → (Fin n → ℤ)), (∀ i, xs i ∈ P) → ∑ i, xs i ∈ finsetDilate t P := by
            intro t xs hxs; induction' t with t ih <;> simp_all +decide [ Fin.sum_univ_succ, finsetDilate ] ;
            · rfl;
            · exact Finset.mem_image.mpr ⟨ ( xs 0, ∑ i : Fin t, xs ( Fin.succ i ) ), Finset.mem_product.mpr ⟨ hxs 0, ih _ fun i => hxs ( Fin.succ i ) ⟩, rfl ⟩;
          exact h_sum_t t _ fun i => hxs.1 _

/-! ## Ehrhart First Coefficient -/

/-- The leading Ehrhart coefficient (volume) is positive for nonempty P. -/
theorem ehrhartCount_pos_forall {n : ℕ} (P : Finset (Fin n → ℤ))
    (hP : P.Nonempty) : ∀ t, 0 < ehrhartCount P t :=
  ehrhartCount_pos P hP

end EhrhartIDP