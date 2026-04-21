/-! # CatalogBuild.Computation.Oracles.OracleFixedPoint

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Computation.Oracles.OracleFixedPoint
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem oracle_contraction_on_range {X : Type*} [MetricSpace X]
    (O : X → X) (hO : ∀ x, O (O x) = O x) (y : X) (hy : y ∈ range O) :
    dist (O y) y = 0 := by
      cases hy ; aesop




/-- [Section: # CatalogBuild.Computation.Oracles.OracleFixedPoint
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem banach_unique_fixed_point {X : Type*} [MetricSpace X] [CompleteSpace X]
    [Nonempty X] (f : X → X) (hf : ContractingWith (⟨1/2, by norm_num⟩ : NNReal) f) :
    ∃! x, f x = x := by
      obtain ⟨x, hx⟩ : ∃ x : X, f x = x := by
        have := hf.exists_fixedPoint;
        exact Exists.elim ( this ( Classical.arbitrary X ) ( ne_of_lt ( edist_lt_top _ _ ) ) ) fun x hx => ⟨ x, hx.1.eq ⟩;
      refine' ⟨ x, hx, fun y hy => _ ⟩;
      have := hf.dist_le_mul y x;
      exact dist_le_zero.mp ( by norm_num [ hx, hy ] at this; linarith )




theorem knaster_tarski_fixed_point {α : Type*} [CompleteLattice α] (f : α → α)
    (hf : Monotone f) : ∃ x : α, f x = x := by
      -- By the Knaster-Tarski theorem, since $f$ is monotone, the set of fixed points of $f$ is nonempty.
      have h_nonempty_fixed_points : ∃ x, f x = x := by
        have h_least_fixed_point : ∃ x, f x ≤ x ∧ ∀ y, f y ≤ y → x ≤ y := by
          use sInf { y | f y ≤ y };
          refine' ⟨ le_sInf _, fun y hy => sInf_le hy ⟩;
          exact fun y hy => le_trans ( hf <| sInf_le hy ) hy
        obtain ⟨ x, hx₁, hx₂ ⟩ := h_least_fixed_point; exact ⟨ x, le_antisymm hx₁ ( hx₂ _ ( hf hx₁ ) ) ⟩ ;
      generalize_proofs at *;
      exact h_nonempty_fixed_points




theorem greatest_fixedPoint_char {α : Type*} [CompleteLattice α] (f : α → α)
    (hf : Monotone f) : f (sSup {x | x ≤ f x}) ≤ sSup {x | x ≤ f x} := by
      refine' le_sSup _;
      refine' hf _;
      exact sSup_le fun x hx => hx.trans ( hf <| le_sSup hx )




theorem kleene_iteration_monotone {α : Type*} [CompleteLattice α] (f : α → α)
    (hf : Monotone f) : f ⊥ ≤ f (f ⊥) := by
      exact hf bot_le




theorem diagonal_no_fixpoint (f : ℕ → (ℕ → Prop)) :
    ∃ g : ℕ → Prop, ∀ n, g ≠ f n := by
      exact ⟨ fun n => ¬f n n, fun n hn => by simpa using congr_fun hn n ⟩




theorem russell_paradox_analog : ¬ ∃ (f : Set ℕ → Prop), ∀ S : Set ℕ, f S ↔ ¬f S := by
  exact fun ⟨ f, hf ⟩ => by simpa using hf Set.univ;




theorem y_combinator_prop {X : Type*} (f : X → X) (y : X) (hy : f y = y) :
    f y = y := by
      bv_omega




theorem idempotent_gives_fixedpoint {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (x : X) : O x ∈ {y | O y = y} := by
      grind +locals




theorem fixedPoints_nonempty_iff {X : Type*} [Nonempty X] (O : X → X)
    (hO : ∀ x, O (O x) = O x) :
    (Set.univ : Set {x : X | O x = x}).Nonempty := by
      -- Since X is nonempty, the universal set is also nonempty.
      simp [Set.Nonempty];
      exact ⟨ _, hO ( Classical.arbitrary X ) ⟩




theorem idempotent_orbit_small {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (x : X) : O^[2] x = O^[1] x := by
      exact hO x




theorem idempotent_fixedpoint_count {n : ℕ} (O : Fin n → Fin n) (hO : ∀ x, O (O x) = O x) :
    Finset.card (Finset.filter (fun x => O x = x) Finset.univ) =
    Finset.card (Finset.image O Finset.univ) := by
      refine' Finset.card_bij ( fun x _ => x ) _ _ _ <;> aesop




end
