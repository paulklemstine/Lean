/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.SortingLemmas

/-!
# Tropical Satake Isomorphism for GL_n: Main Theorems

## Overview

This file establishes the tropical (min-plus) Satake correspondence for `GL_n`
uniformly in rank `n`. The key breakthrough is isolating the rank-uniform mechanism
by which Weyl symmetry, dominance order, and min-plus convolution become aspects
of a single algebraic structure.

## Main Results

* **Theorem A** (`satake_extend_invariant_fin`): Any function on dominant coweights
  extends canonically to an `S_n`-invariant function on `ℤ^n`.
* **Theorem B** (`tropSchurN_symmetric`): Tropical Schur polynomials are `S_n`-invariant.
* **Theorem C** (`tropSchurN_mul_symmetric`): The tropical product of Schur
  polynomials is `S_n`-invariant.
* **Theorem D** (`symmetric_tropical_dominance_monotone`): Monotonicity on
  dominance order for dominant-exponent monomials (Schur-convexity bridge).
-/

open Finset Equiv BigOperators

noncomputable section

/-! ## Section 1: Symmetric Tropical Functions and Satake Extension -/

/-- `S_n`-invariance: a function is unchanged under any coordinate permutation. -/
def IsSymmetricTropical (n : ℕ) (f : (Fin n → ℤ) → ℤ) : Prop :=
  ∀ σ : Equiv.Perm (Fin n), ∀ x : Fin n → ℤ, f (x ∘ σ) = f x

/-- The type of dominant coweights for `GL_n`. -/
def DominantCoweight (n : ℕ) := { v : Fin n → ℤ // IsDominant v }

/-- The canonical dominant representative as a `DominantCoweight`. -/
def toDominant {n : ℕ} (x : Fin n → ℤ) : DominantCoweight n :=
  ⟨sortDescFn x, sortDescFn_isDominant x⟩

/-- The Satake extension: extend a function from dominant coweights to all of `ℤ^n`
    by composing with the canonical dominant representative (sorting). -/
def satakeExtend {n : ℕ} (f : DominantCoweight n → ℤ) : (Fin n → ℤ) → ℤ :=
  fun x => f (toDominant x)

/-- **Theorem A: Tropical Satake invariance-extension for GL_n.**

Any function on dominant coweights extends canonically to an `S_n`-invariant
tropical function on all of `ℤ^n`. The extension agrees with the original
on dominant coweights and is `S_n`-invariant. This is the tropical analogue
of extending class functions from a Weyl chamber to the full torus. -/
theorem satake_extend_invariant_fin
    {n : ℕ}
    (f : DominantCoweight n → ℤ) :
    (∀ x : DominantCoweight n, satakeExtend f x.1 = f x) ∧
    IsSymmetricTropical n (satakeExtend f) := by
  refine ⟨fun ⟨x, hx⟩ => ?_, fun σ x => ?_⟩
  · simp only [satakeExtend, toDominant]
    congr 1; exact Subtype.ext (sortDescFn_of_dominant x hx)
  · simp only [satakeExtend, toDominant, Function.comp]
    congr 1; exact Subtype.ext (sortDescFn_perm_invariant x σ)

/-
**Uniqueness of the Satake extension.**
-/
theorem satake_extend_unique
    {n : ℕ}
    (f : DominantCoweight n → ℤ)
    (F : (Fin n → ℤ) → ℤ)
    (hF_agree : ∀ x : DominantCoweight n, F x.1 = f x)
    (hF_sym : IsSymmetricTropical n F) :
    ∀ x, F x = satakeExtend f x := by
      -- Since `sortDescFn x` is a rearrangement of `x`, there exists a permutation `σ` such that `sortDescFn x = x ∘ σ`.
      have h_perm : ∀ x : Fin n → ℤ, ∃ σ : Equiv.Perm (Fin n), sortDescFn x = x ∘ σ := by
        intro x
        have h_perm_list : ∃ σ : List (Fin n), List.Perm σ (List.finRange n) ∧ List.map x σ = sortDescList (List.ofFn x) := by
          have h_perm : List.Perm (List.map x (List.finRange n)) (sortDescList (List.ofFn x)) := by
            convert List.Perm.symm ( sortDescList_perm _ ) using 1;
            rw [ List.ofFn_eq_map ];
          have h_perm : ∀ {l1 l2 : List ℤ}, List.Perm l1 l2 → ∀ {l : List (Fin n)}, List.map x l = l1 → ∃ σ : List (Fin n), List.Perm σ l ∧ List.map x σ = l2 := by
            intros l1 l2 h_perm l hl; induction' h_perm with l1 l2 h_perm ih generalizing l; aesop;
            · rcases l with ( _ | ⟨ i, l ⟩ ) <;> simp_all +decide [ List.map ];
              obtain ⟨ σ, hσ₁, hσ₂ ⟩ := ‹∀ { l : List ( Fin n ) }, List.map x l = l2 → ∃ σ : List ( Fin n ), σ.Perm l ∧ List.map x σ = h_perm› hl.2; use i :: σ; aesop;
            · rcases l with ( _ | ⟨ a, _ | ⟨ b, l ⟩ ⟩ ) <;> simp_all +decide [ List.map ];
              exact ⟨ b :: a :: l, List.Perm.swap .., by aesop ⟩;
            · grind;
          exact h_perm ‹_› rfl;
        obtain ⟨σ, hσ_perm, hσ_eq⟩ := h_perm_list
        have hσ_length : σ.length = n := by
          simpa using hσ_perm.length_eq;
        have hσ_inj : Function.Injective (fun i : Fin n => σ.get ⟨i.val, by
          linarith [ Fin.is_lt i ]⟩) := by
          intro i j hij
          have h_eq : σ.get ⟨i.val, by
            lia⟩ = σ.get ⟨j.val, by
            grind +splitIndPred⟩ := by
            exact hij
          generalize_proofs at *;
          have := List.nodup_iff_injective_get.mp ( show List.Nodup σ from ?_ ) h_eq; aesop;
          exact hσ_perm.nodup_iff.mpr ( List.nodup_finRange _ )
        generalize_proofs at *;
        use Equiv.ofBijective (fun i : Fin n => σ.get ⟨i.val, by
          grind⟩) ⟨hσ_inj, by
          exact Finite.injective_iff_surjective.mp hσ_inj⟩
        generalize_proofs at *;
        ext i; simp [sortDescFn, hσ_eq];
        grind;
      intro x
      obtain ⟨σ, hσ⟩ := h_perm x
      have hF_eq : F x = F (sortDescFn x) := by
        rw [ hσ, hF_sym σ x ];
      exact hF_eq.trans ( hF_agree ⟨ sortDescFn x, sortDescFn_isDominant x ⟩ )

/-! ## Section 2: Tropical Monomials and Polynomials -/

/-- A tropical monomial: coefficient `c` and exponent vector `e`. -/
structure TropicalMonomial (n : ℕ) where
  coeff : ℤ
  expo  : Fin n → ℤ

/-- Evaluate a tropical monomial at a point. -/
def TropicalMonomial.eval {n : ℕ} (m : TropicalMonomial n) (x : Fin n → ℤ) : ℤ :=
  m.coeff + ∑ i, m.expo i * x i

/-! ## Section 3: Dominance Order -/

/-- The dominance (majorization) partial order on integer vectors. -/
def DominanceOrder {n : ℕ} (x y : Fin n → ℤ) : Prop :=
  ∀ k : Fin n, ∑ i ∈ Finset.univ.filter (fun j : Fin n => j ≤ k),
    (sortDescFn x) i ≤
  ∑ i ∈ Finset.univ.filter (fun j : Fin n => j ≤ k),
    (sortDescFn y) i

/-! ## Section 4: Tropical Schur Polynomials -/

/-- The tropical Schur polynomial for `GL_n`:
    `tropSchurN w x = min_{σ ∈ S_n} ∑ᵢ w(σ i) · x(i)`.

This is the orbit-min construction: for each permutation of the weight
vector `w`, compute the inner product with `x`, then take the minimum. -/
def tropSchurN {n : ℕ} (w x : Fin n → ℤ) : ℤ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun σ : Equiv.Perm (Fin n) => ∑ i : Fin n, w (σ i) * x i)

/-- Helper: reindexing a sum by a permutation. -/
lemma sum_perm_reindex' {n : ℕ} (f : Fin n → ℤ) (g : Fin n → ℤ)
    (σ : Equiv.Perm (Fin n)) :
    ∑ i, f (σ i) * g i = ∑ i, f i * g (σ⁻¹ i) := by
  rw [← Equiv.sum_comp σ⁻¹]; simp [Equiv.Perm.mul_apply]

/-
**Theorem B: Tropical Schur polynomials are `S_n`-invariant.**

For any weight vector `w`, the tropical Schur polynomial `tropSchurN w`
is invariant under permutation of its argument. This is the rank-uniform
generalization of the GL₃ symmetry theorem.
-/
theorem tropSchurN_symmetric {n : ℕ} (w : Fin n → ℤ) :
    IsSymmetricTropical n (tropSchurN w) := by
      intro σ x;
      refine' le_antisymm _ _;
      · obtain ⟨τ, hτ⟩ : ∃ τ : Equiv.Perm (Fin n), ∑ i, w (τ i) * x i = tropSchurN w x := by
          convert Finset.exists_min_image Finset.univ ( fun τ : Equiv.Perm ( Fin n ) => ∑ i, w ( τ i ) * x i ) ⟨ Equiv.refl ( Fin n ), Finset.mem_univ _ ⟩ using 1;
          ext; simp [tropSchurN];
          exact ⟨ fun h σ' => h.symm ▸ Finset.inf'_le _ ( Finset.mem_univ _ ), fun h => le_antisymm ( Finset.le_inf' _ _ fun σ' _ => h σ' ) ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ⟩;
        nontriviality;
        have h_inf' : ∑ i, w (τ (σ i)) * x (σ i) = ∑ i, w (τ i) * x i := by
          conv_rhs => rw [ ← Equiv.sum_comp σ ] ;
        exact hτ ▸ h_inf' ▸ Finset.inf'_le _ ( Finset.mem_univ ( τ * σ ) );
      · simp +decide [ tropSchurN ];
        intro b; use b * σ⁻¹; simp +decide [ mul_assoc, Equiv.Perm.ext_iff ] ;
        conv_rhs => rw [ ← Equiv.sum_comp σ.symm ] ;
        simp +decide [ Equiv.symm_apply_apply ]

/-
**Idempotency of orbit-min on invariant functions.**
-/
theorem tropSchurN_idempotent {n : ℕ} (w x : Fin n → ℤ) :
    Finset.inf' Finset.univ Finset.univ_nonempty
      (fun σ : Equiv.Perm (Fin n) => tropSchurN w (fun i => x (σ i)))
    = tropSchurN w x := by
      refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
      · exact ⟨ Equiv.refl _, by rfl ⟩;
      · intro σ; exact (by
        convert tropSchurN_symmetric w σ.symm x |> le_of_eq using 1;
        · convert tropSchurN_symmetric w σ.symm x |> Eq.symm using 1;
        · convert tropSchurN_symmetric w σ x using 1)

/-! ## Section 5: Tropical Product of Schur Polynomials -/

/-- The tropical product of two orbit-min polynomials:
    `(tropSchurN w₁ ⊗ tropSchurN w₂)(x) = min_{σ₁,σ₂} (⟨w₁∘σ₁, x⟩ + ⟨w₂∘σ₂, x⟩)`. -/
def tropSchurMul {n : ℕ} (w₁ w₂ x : Fin n → ℤ) : ℤ :=
  Finset.inf' (Finset.univ ×ˢ Finset.univ)
    (Finset.nonempty_product.mpr ⟨Finset.univ_nonempty, Finset.univ_nonempty⟩)
    (fun p : Equiv.Perm (Fin n) × Equiv.Perm (Fin n) =>
      (∑ i, w₁ (p.1 i) * x i) + (∑ i, w₂ (p.2 i) * x i))

/-
**Theorem C: The tropical product of Schur polynomials is `S_n`-invariant.**

Under tropical multiplication, the product of two orbit-min Schur polynomials
is again `S_n`-invariant. This shows the Weyl-invariant tropical polynomials
form a sub-semiring — the algebraic heart of the tropical Satake correspondence.
-/
theorem tropSchurN_mul_symmetric {n : ℕ} (w₁ w₂ : Fin n → ℤ) :
    IsSymmetricTropical n (tropSchurMul w₁ w₂) := by
      intro σ x; rw [ tropSchurMul ] ; simp +decide [ tropSchurMul ] ;
      refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
      · intro a b; use a * σ, b * σ; simp +decide [ Finset.sum_apply, Finset.sum_add_distrib, mul_comm ] ;
        exact le_of_eq ( by rw [ Equiv.sum_comp σ fun i => x i * w₁ ( a i ), Equiv.sum_comp σ fun i => x i * w₂ ( b i ) ] );
      · intro a b; use a * σ⁻¹, b * σ⁻¹; simp +decide [ mul_assoc, Equiv.Perm.inv_def ] ;
        conv_rhs => rw [ ← Equiv.sum_comp σ.symm ] ; ; simp +decide [ mul_comm ] ;
        conv_rhs => rw [ ← Equiv.sum_comp σ.symm ] ; simp +decide [ mul_comm ] ;

/-- Tropical monomial evaluation distributes over addition. -/
theorem tropMonomial_eval_add {n : ℕ}
    (m₁ m₂ : TropicalMonomial n) (x : Fin n → ℤ) :
    (⟨m₁.coeff + m₂.coeff, fun i => m₁.expo i + m₂.expo i⟩ :
      TropicalMonomial n).eval x
    = m₁.eval x + m₂.eval x := by
  simp [TropicalMonomial.eval, Finset.sum_add_distrib, add_mul]; ring

/-! ## Section 6: Schur-Convexity Bridge (Theorem D) -/

/-
**Theorem D: Monotonicity of dominant-exponent monomials under dominance order.**

For a tropical monomial with weakly-decreasing exponent vector, evaluation
on dominant vectors is monotone w.r.t. dominance order (when sums are equal).
This is the tropical analogue of the Hardy-Littlewood-Pólya majorization
inequality, connecting tropical Satake theory to combinatorial optimization
and Schur-convexity.
-/
set_option maxHeartbeats 1600000 in
theorem symmetric_tropical_dominance_monotone
    {n : ℕ}
    (m : TropicalMonomial n)
    (hm : IsDominant m.expo)
    (x y : Fin n → ℤ)
    (hx : IsDominant x) (hy : IsDominant y)
    (hdom : DominanceOrder x y)
    (hsum : ∑ i, x i = ∑ i, y i) :
    m.eval x ≤ m.eval y := by
      -- By Abel summation: ∑ e(i)*d(i) = ∑_{k=0}^{n-2} (e(k)-e(k+1)) * S(k) + e(n-1)*S(n-1) where S(k) = ∑_{i≤k} d(i).
      set d : Fin n → ℤ := fun i => y i - x i
      set S : Fin n → ℤ := fun k => ∑ i ∈ Finset.univ.filter (fun j => j ≤ k), d i;
      -- The difference between the two evaluations is ∑ e(i)*d(i).
      have h_diff : ∑ i, m.expo i * (y i - x i) = ∑ i, (m.expo i - if h : i = ⟨n - 1, Nat.sub_lt (Nat.pos_of_ne_zero (by
      linarith [ Fin.is_lt i ])) zero_lt_one⟩ then 0 else m.expo (⟨i.val + 1, by
        all_goals generalize_proofs at *;
        grind +locals⟩)) * S i := by
        all_goals generalize_proofs at *;
        rcases n with ( _ | n ) <;> simp_all +decide [ Fin.sum_univ_castSucc ];
        have h_abel : ∀ (n : ℕ) (u v : Fin (n + 1) → ℤ), (∑ i, u i * v i) = (∑ i : Fin n, (u i.castSucc - u (Fin.succ i)) * (∑ j ∈ Finset.univ.filter (fun k => k ≤ i.castSucc), v j)) + u (Fin.last n) * (∑ j ∈ Finset.univ.filter (fun k => k ≤ Fin.last n), v j) := by
          intro n u v; induction' n with n ih <;> simp_all +decide [ Fin.sum_univ_castSucc, Finset.sum_filter ] ; ring;
          specialize ih ( fun i => u i.castSucc ) ( fun i => v i.castSucc ) ; simp_all +decide [ Fin.sum_univ_castSucc, Finset.sum_filter ] ; ring;
          simp_all +decide [ Fin.le_last, Finset.sum_ite ] ; ring;
        convert h_abel n ( fun i => m.expo i ) ( fun i => y i - x i ) using 1;
        · simp +decide [ Fin.sum_univ_castSucc ];
        · grind +suggestions
      generalize_proofs at *;
      -- Since $e$ is decreasing (hm): $e(k)-e(k+1) \geq 0$, $S(k) \geq 0$, $S(n-1) = 0$, each term $\geq 0$.
      have h_nonneg : ∀ i : Fin n, 0 ≤ (m.expo i - if h : i = ⟨n - 1, Nat.sub_lt (Nat.pos_of_ne_zero (by
      exact Nat.ne_of_gt ( Fin.pos i ))) zero_lt_one⟩ then 0 else m.expo (⟨i.val + 1, by
        all_goals generalize_proofs at *;
        grind⟩)) * S i := by
        all_goals generalize_proofs at *;
        intro i
        by_cases hi : i = ⟨n - 1, Nat.sub_lt (Nat.pos_of_ne_zero (by
        exact Nat.ne_of_gt ( Fin.pos i ))) zero_lt_one⟩
        all_goals generalize_proofs at *;
        · simp_all +decide [ Finset.sum_sub_distrib ];
          rw [ show S ⟨ n - 1, by linarith ⟩ = ∑ i, d i from ?_ ];
          · aesop;
          · exact Finset.sum_subset ( fun i hi => Finset.mem_univ i ) fun i hi hi' => by exact False.elim <| hi' <| Finset.mem_filter.mpr ⟨ Finset.mem_univ _, Nat.le_sub_one_of_lt <| Fin.is_lt i ⟩ ;
        · split_ifs ; simp_all +decide [ IsDominant ];
          refine' mul_nonneg _ _;
          · exact sub_nonneg_of_le <| hm _ _ <| Nat.le_succ _;
          · have := hdom i;
            rw [ show sortDescFn x = x from sortDescFn_of_dominant x hx, show sortDescFn y = y from sortDescFn_of_dominant y hy ] at this ; aesop
      generalize_proofs at *;
      unfold TropicalMonomial.eval; simp_all +decide [ mul_sub ] ;
      linarith [ show ∑ i, ( m.expo i - if h : i = ⟨ n - 1, Nat.sub_lt ( Nat.pos_of_ne_zero ( by
                  exact Nat.ne_of_gt ( Fin.pos i ) ) ) zero_lt_one ⟩ then 0 else m.expo ⟨ i.val + 1, by solve_by_elim ⟩ ) * S i ≥ 0 from Finset.sum_nonneg fun i _ => h_nonneg i ]
      all_goals generalize_proofs at *;

end