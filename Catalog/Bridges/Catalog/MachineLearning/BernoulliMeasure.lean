/-
# Bernoulli Product Measure on Finite Boolean Configurations

We define the Bernoulli product measure on finite Boolean configurations
and prove that the probability of any increasing event is monotone in the
parameter p. This is the foundational order-theoretic result underpinning
percolation threshold theory.

## Main definitions
- `bernoulliWeight p η`: the Bernoulli product weight of configuration η at parameter p
- `bernoulliProb p A`: the probability of event A under Bernoulli(p) product measure
- `IsIncreasingEvent A`: predicate that A is an increasing (upward-closed) event

## Main theorems
- `bernoulliProb_monotone`: probability of an increasing event is monotone in p
-/

import Mathlib

open Finset BigOperators

noncomputable section

/-- The Bernoulli product weight of a Boolean configuration η on a finite type α
    at parameter p. Each coordinate contributes p if true, (1-p) if false. -/
def bernoulliWeight {α : Type*} [Fintype α] (p : ℝ) (η : α → Bool) : ℝ :=
  ∏ a : α, if η a then p else (1 - p)

/-- A Boolean configuration dominates another if it is pointwise ≥. -/
def BoolDominates {α : Type*} (η ξ : α → Bool) : Prop :=
  ∀ a, η a = true → ξ a = true

/-- An event (set of configurations) is increasing if it is upward-closed
    under pointwise Boolean ordering. -/
def IsIncreasingEvent {α : Type*} (A : Set (α → Bool)) : Prop :=
  ∀ η ξ, BoolDominates η ξ → η ∈ A → ξ ∈ A

/-- The Bernoulli probability of a (decidable) event A at parameter p,
    defined as the sum of weights over all configurations in A. -/
def bernoulliProb {α : Type*} [Fintype α] [DecidableEq α]
    (p : ℝ) (A : Finset (α → Bool)) : ℝ :=
  ∑ η ∈ A, bernoulliWeight p η

/-
The probability of the entire space is the product of 1's,
    i.e., it normalizes to 1 when p ∈ [0,1].
-/
theorem bernoulliWeight_total {α : Type*} [Fintype α] [DecidableEq α]
    (p : ℝ) :
    ∑ η : α → Bool, bernoulliWeight p η = 1 := by
      -- By Fubini's theorem, we can interchange the order of summation.
      have h_fubini : ∑ η : α → Bool, ∏ a : α, (if η a then p else 1 - p) = ∏ a : α, ∑ η : Bool, (if η then p else 1 - p) := by
        exact Eq.symm (Fintype.prod_sum fun i j => if j = true then p else 1 - p);
      convert h_fubini using 1 ; simp +decide

/-
Bernoulli weight is nonneg when p ∈ [0,1].
-/
theorem bernoulliWeight_nonneg {α : Type*} [Fintype α]
    (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (η : α → Bool) :
    0 ≤ bernoulliWeight p η := by
      exact Finset.prod_nonneg fun a _ => by split_ifs <;> linarith;

/-
For the monotonicity proof, we work with a simpler type-level approach.

For a single-variable Boolean function, the Bernoulli expectation is
    affine in p: E_p[f] = f(false)·(1-p) + f(true)·p.
-/
theorem bernoulliWeight_single (p : ℝ) (η : Unit → Bool) :
    bernoulliWeight p η = if η () then p else (1 - p) := by
      unfold bernoulliWeight; aesop;

/-
**Core monotonicity theorem for increasing events on finite Boolean spaces.**

    If A is an increasing event (upward-closed under pointwise Boolean order)
    on a finite type, then the Bernoulli probability of A is monotone in p
    on the interval [0,1].

    This is the fundamental result that enables the definition of percolation
    thresholds: connection and crossing probabilities are increasing events,
    so their probabilities increase with p.
-/
set_option maxHeartbeats 800000 in
set_option linter.unusedSimpArgs false in
theorem increasing_event_prob_monotone
    {α : Type*} [Fintype α] [DecidableEq α]
    (A : Finset (α → Bool))
    (hA : ∀ η ξ : α → Bool, BoolDominates η ξ → η ∈ A → ξ ∈ A) :
    MonotoneOn (fun p => bernoulliProb p A) (Set.Icc 0 1) := by
      -- The proof follows by induction on the number of variables.
      have h_ind : ∀ (n : ℕ) (A : Finset (Fin n → Bool)), (∀ η ξ, BoolDominates η ξ → η ∈ A → ξ ∈ A) → MonotoneOn (fun p : ℝ => ∑ η ∈ A, ∏ i, if η i then p else 1 - p) (Set.Icc 0 1) := by
        intro n
        induction' n with n ih;
        · simp +decide [ MonotoneOn ];
        · intro A hA
          have h_split : ∀ p : ℝ, ∑ η ∈ A, ∏ i, (if η i then p else 1 - p) = p * ∑ η ∈ Finset.filter (fun η => η 0 = true) A, ∏ i, (if η (Fin.succ i) then p else 1 - p) + (1 - p) * ∑ η ∈ Finset.filter (fun η => η 0 = false) A, ∏ i, (if η (Fin.succ i) then p else 1 - p) := by
            intro p
            simp [Finset.sum_filter, Finset.prod_range_succ];
            rw [ Finset.mul_sum _ _ _, Finset.mul_sum _ _ _ ];
            rw [ ← Finset.sum_add_distrib ] ; congr ; ext η ; cases h : η 0 <;> simp +decide [ h, Fin.prod_univ_succ ] ;
          -- By the induction hypothesis, the sums over the two parts are monotone in $p$.
          have h_monotone_parts : MonotoneOn (fun p : ℝ => ∑ η ∈ Finset.filter (fun η => η 0 = true) A, ∏ i, (if η (Fin.succ i) then p else 1 - p)) (Set.Icc 0 1) ∧ MonotoneOn (fun p : ℝ => ∑ η ∈ Finset.filter (fun η => η 0 = false) A, ∏ i, (if η (Fin.succ i) then p else 1 - p)) (Set.Icc 0 1) := by
            apply And.intro;
            · convert ih ( Finset.image ( fun η : Fin ( n + 1 ) → Bool => fun i => η ( Fin.succ i ) ) ( Finset.filter ( fun η => η 0 = true ) A ) ) _ using 1;
              · ext p;
                refine' Finset.sum_bij ( fun η hη => fun i => η ( Fin.succ i ) ) _ _ _ _ <;> simp +decide;
                · exact fun η hη hη' => ⟨ η, ⟨ hη, hη' ⟩, rfl ⟩;
                · simp +contextual [ funext_iff, Fin.forall_fin_succ ];
              · simp +contextual [ BoolDominates ];
                rintro η ξ hη x hx hx' rfl;
                refine' ⟨ Fin.cons true ξ, _, _ ⟩ <;> simp_all +decide [ Fin.forall_fin_succ ];
                convert hA _ _ _ hx using 1;
                intro i; induction i using Fin.inductionOn <;> simp +decide [ * ] ;
                exact hη _;
            · convert ih ( Finset.image ( fun η : Fin ( n + 1 ) → Bool => fun i => η ( Fin.succ i ) ) ( Finset.filter ( fun η => η 0 = false ) A ) ) _ using 1;
              · ext p;
                rw [ Finset.sum_image ];
                intro η hη ξ hξ h_eq;
                ext i; induction i using Fin.inductionOn <;> simp_all +decide [ funext_iff ] ;
              · simp +contextual [ BoolDominates ];
                rintro η ξ hη x hx hx' rfl;
                refine' ⟨ Fin.cons false ξ, _, _ ⟩ <;> simp_all +decide [ Fin.forall_fin_succ ];
                convert hA _ _ _ hx using 1;
                intro i; induction i using Fin.inductionOn <;> simp +decide [ * ] ;
                exact hη _;
          intro p hp q hq hpq;
          have h_monotone_parts : ∑ η ∈ Finset.filter (fun η => η 0 = true) A, ∏ i, (if η (Fin.succ i) then p else 1 - p) ≥ ∑ η ∈ Finset.filter (fun η => η 0 = false) A, ∏ i, (if η (Fin.succ i) then p else 1 - p) := by
            have h_monotone_parts : ∀ η ∈ Finset.filter (fun η => η 0 = false) A, ∃ ξ ∈ Finset.filter (fun η => η 0 = true) A, ∀ i : Fin n, ξ (Fin.succ i) = η (Fin.succ i) := by
              intro η hη
              use fun i => if i = 0 then true else η i;
              simp +zetaDelta at *;
              convert hA _ _ _ hη.1 using 1;
              intro i hi; by_cases hi0 : i = 0 <;> simp +decide [ hi0, hi ] ;
            choose! f hf using h_monotone_parts;
            have h_monotone_parts : ∑ η ∈ Finset.filter (fun η => η 0 = false) A, ∏ i, (if η (Fin.succ i) then p else 1 - p) ≤ ∑ η ∈ Finset.image f (Finset.filter (fun η => η 0 = false) A), ∏ i, (if η (Fin.succ i) then p else 1 - p) := by
              rw [ Finset.sum_image ];
              · exact Finset.sum_le_sum fun x hx => by rw [ Finset.prod_congr rfl ] ; intros i hi; rw [ hf x hx |>.2 i ] ;
              · intro η hη ξ hξ h_eq;
                ext i; induction i using Fin.inductionOn <;> simp_all +decide ;
                grind;
            exact h_monotone_parts.trans ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.image_subset_iff.mpr fun η hη => hf η hη |>.1 ) fun _ _ _ => Finset.prod_nonneg fun _ _ => by split_ifs <;> linarith [ hp.1, hp.2 ] );
          simp +zetaDelta at *;
          rw [ h_split p, h_split q ];
          rename_i h;
          nlinarith [ h.1 hp hq hpq, h.2 hp hq hpq ];
      specialize h_ind ( Fintype.card α ) ( Finset.univ.filter fun η : Fin ( Fintype.card α ) → Bool => ( fun i => η ( Fintype.equivFin α i ) ) ∈ A );
      convert h_ind _ using 2;
      · refine' Finset.sum_bij ( fun η _ => fun i => η ( Fintype.equivFin α |>.symm i ) ) _ _ _ _ <;> simp +decide;
        · exact fun η₁ hη₁ η₂ hη₂ h => funext fun x => by simpa using congr_fun h ( Fintype.equivFin α x ) ;
        · exact fun b hb => ⟨ _, hb, funext fun i => by simp +decide ⟩;
        · exact fun η hη => by rw [ ← Equiv.prod_comp ( Fintype.equivFin α ) ] ; simp +decide [ bernoulliWeight ] ;
      · grind +locals

end