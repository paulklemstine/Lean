/-
# The which-factor wall for a free cyclic action

The which-factor wall proved earlier (`Bridges/CyclicCubicWhichFactor.lean`) is
the two-element case of a group-action principle: the public data is invariant
under a group acting on the hidden label, and the action permutes the label
transitively, so the conditional distribution of the label is uniform in every
fibre of the public data and no information leaks.

This file proves that principle for a **cyclic** action of arbitrary order, which
is the first step of Direction 4 of `FUTURE_DIRECTIONS.md` (`k = 2` there is the
involution already in the catalog).

Data: a shift `σ` on the sample space with inverse `τ`, an injective permutation
`π` of the value space, and a read-out `g` intertwining them, `g ∘ σ = π ∘ g`.
Transitivity of `π` on the attained values replaces "free orbit".

* `card_fiber_shift`, `card_fiber_iterate`, `card_fiber_const` — every value of
  `g` is attained equally often on any shift-invariant block.
* `uEnt_of_balanced_fibres` — a balanced read-out has the maximal entropy
  `log₂ |support|`.
* `uEnt_eq_logb_card_of_shift` — hence the hidden label carries exactly
  `log₂ k` bits, where `k` is the number of values.
* `mutInfo_eq_zero_of_shift` — **the wall**: any observable invariant under the
  shift carries exactly zero information about the label.
* `whichFactor_wall_via_shift`, `conductor13_which_factor_zero_via_shift` — the
  catalog's semiprime wall and its conductor-13 instance recovered as the
  order-2 case, an independent derivation of `conductor13_which_factor_zero`.
-/

import Bridges.CyclicCubicWhichFactor

namespace WhichFactorWall

open Finset hiding box
open CyclicTypeChannel

/-! ## 1. Balanced fibres from a shift -/

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]

section Shift

variable {s F : Finset α} {σ τ : α → α} {g : α → β} {π : β → β}

/-- One step of the shift matches the fibre over `v` with the fibre over `π v`. -/
theorem card_fiber_shift (hFσ : ∀ x ∈ F, σ x ∈ F) (hFτ : ∀ x ∈ F, τ x ∈ F)
    (hleft : ∀ x ∈ F, τ (σ x) = x) (hright : ∀ x ∈ F, σ (τ x) = x)
    (hshift : ∀ x ∈ F, g (σ x) = π (g x)) (hπ : Function.Injective π) (v : β) :
    #{x ∈ F | g x = v} = #{x ∈ F | g x = π v} := by
  classical
  refine Finset.card_bij' (fun x _ => σ x) (fun y _ => τ y) ?_ ?_ ?_ ?_
  · intro x hx
    simp only [mem_filter] at hx ⊢
    exact ⟨hFσ x hx.1, by rw [hshift x hx.1, hx.2]⟩
  · intro y hy
    simp only [mem_filter] at hy ⊢
    refine ⟨hFτ y hy.1, ?_⟩
    have h1 : g (σ (τ y)) = π (g (τ y)) := hshift _ (hFτ y hy.1)
    rw [hright y hy.1, hy.2] at h1
    exact (hπ h1).symm
  · intro x hx
    exact hleft x (mem_filter.1 hx).1
  · intro y hy
    exact hright y (mem_filter.1 hy).1

/-- Iterating: the fibres over `v` and over `π^[j] v` always have the same size. -/
theorem card_fiber_iterate (hFσ : ∀ x ∈ F, σ x ∈ F) (hFτ : ∀ x ∈ F, τ x ∈ F)
    (hleft : ∀ x ∈ F, τ (σ x) = x) (hright : ∀ x ∈ F, σ (τ x) = x)
    (hshift : ∀ x ∈ F, g (σ x) = π (g x)) (hπ : Function.Injective π) (j : ℕ) (v : β) :
    #{x ∈ F | g x = v} = #{x ∈ F | g x = π^[j] v} := by
  induction j generalizing v with
  | zero => simp
  | succ j ih =>
      rw [card_fiber_shift hFσ hFτ hleft hright hshift hπ v, ih (π v),
        Function.iterate_succ_apply]

/-- Under a transitive shift all fibres in a block have the same size. -/
theorem card_fiber_const (hFσ : ∀ x ∈ F, σ x ∈ F) (hFτ : ∀ x ∈ F, τ x ∈ F)
    (hleft : ∀ x ∈ F, τ (σ x) = x) (hright : ∀ x ∈ F, σ (τ x) = x)
    (hshift : ∀ x ∈ F, g (σ x) = π (g x)) (hπ : Function.Injective π)
    (htrans : ∀ v w : β, ∃ j, π^[j] v = w) (v w : β) :
    #{x ∈ F | g x = v} = #{x ∈ F | g x = w} := by
  obtain ⟨j, hj⟩ := htrans v w
  rw [card_fiber_iterate hFσ hFτ hleft hright hshift hπ j v, hj]

end Shift

/-! ## 2. Balanced read-outs have maximal entropy -/

/-- **A balanced read-out has entropy `log₂` of the number of values it takes.**
This is the equality case of the maximum-entropy bound, isolated combinatorially:
no probability estimate is needed, only that all fibres have a common size. -/
theorem uEnt_of_balanced_fibres {F : Finset α} (hF : F.Nonempty) {g : α → β} {f : ℕ}
    (hf : 0 < f) (hbal : ∀ x ∈ F, #{y ∈ F | g y = g x} = f) :
    uEnt F g = Real.logb 2 ((F.image g).card : ℝ) := by
  classical
  have hcards : f * (F.image g).card = F.card := by
    calc f * (F.image g).card = ∑ _v ∈ F.image g, f := by
          rw [Finset.sum_const, smul_eq_mul, mul_comm]
      _ = ∑ v ∈ F.image g, #{x ∈ F | g x = v} :=
          Finset.sum_congr rfl fun v hv => by
            obtain ⟨x, hx, rfl⟩ := mem_image.1 hv
            exact (hbal x hx).symm
      _ = F.card := sum_fiber_card F g
  have hcpos : 0 < (F.image g).card := Finset.card_pos.2 (hF.image g)
  have hfR : (0 : ℝ) < (f : ℝ) := by exact_mod_cast hf
  have hcR : (0 : ℝ) < ((F.image g).card : ℝ) := by exact_mod_cast hcpos
  have hFR : (F.card : ℝ) = (f : ℝ) * ((F.image g).card : ℝ) := by
    exact_mod_cast congrArg (Nat.cast (R := ℝ)) hcards.symm
  have hFpos : (0 : ℝ) < (F.card : ℝ) := by rw [hFR]; positivity
  have hsum : ∑ x ∈ F, Real.logb 2 (#{y ∈ F | g y = g x} : ℝ)
      = (F.card : ℝ) * Real.logb 2 (f : ℝ) := by
    rw [Finset.sum_congr rfl (fun x hx => by rw [hbal x hx])]
    simp [Finset.sum_const, nsmul_eq_mul]
  have hcancel : ((F.card : ℝ) * Real.logb 2 (f : ℝ)) / (F.card : ℝ)
      = Real.logb 2 (f : ℝ) := mul_div_cancel_left₀ _ (ne_of_gt hFpos)
  rw [uEnt, hsum, hcancel, hFR, Real.logb_mul (ne_of_gt hfR) (ne_of_gt hcR)]
  ring

/-! ## 3. The cyclic wall -/

section Wall

variable {s : Finset α} {σ τ : α → α} {g : α → β} {π : β → β} {obs : α → γ}

/-- **The hidden label carries `log₂ k` bits.**  On any shift-invariant block the
read-out is balanced, hence of maximal entropy. -/
theorem uEnt_eq_logb_card_of_shift {F : Finset α} (hF : F.Nonempty)
    (hFσ : ∀ x ∈ F, σ x ∈ F) (hFτ : ∀ x ∈ F, τ x ∈ F)
    (hleft : ∀ x ∈ F, τ (σ x) = x) (hright : ∀ x ∈ F, σ (τ x) = x)
    (hshift : ∀ x ∈ F, g (σ x) = π (g x)) (hπ : Function.Injective π)
    (htrans : ∀ v w : β, ∃ j, π^[j] v = w) :
    uEnt F g = Real.logb 2 ((F.image g).card : ℝ) := by
  classical
  obtain ⟨x₀, hx₀⟩ := hF
  have hfpos : 0 < #{y ∈ F | g y = g x₀} := Finset.card_pos.2 ⟨x₀, by simp [hx₀]⟩
  refine uEnt_of_balanced_fibres ⟨x₀, hx₀⟩ hfpos (fun x hx => ?_)
  exact card_fiber_const hFσ hFτ hleft hright hshift hπ htrans (g x) (g x₀)

/-- Every fibre of a shift-invariant observable sees all the values of `g`. -/
theorem image_on_fibre_eq (hmaps : ∀ x ∈ s, σ x ∈ s)
    (hshift : ∀ x ∈ s, g (σ x) = π (g x))
    (htrans : ∀ v w : β, ∃ j, π^[j] v = w) (hobs : ∀ x ∈ s, obs (σ x) = obs x)
    {c : γ} (hc : ({x ∈ s | obs x = c}).Nonempty) :
    ({x ∈ s | obs x = c}).image g = s.image g := by
  classical
  set F : Finset α := {x ∈ s | obs x = c} with hFdef
  have hFsub : F ⊆ s := Finset.filter_subset _ _
  have hFσ : ∀ x ∈ F, σ x ∈ F := by
    intro x hx
    simp only [hFdef, mem_filter] at hx ⊢
    exact ⟨hmaps x hx.1, by rw [hobs x hx.1, hx.2]⟩
  -- iterates stay in `F` and shift the value by `π`
  have hiter : ∀ j (x : α), x ∈ F → σ^[j] x ∈ F ∧ g (σ^[j] x) = π^[j] (g x) := by
    intro j
    induction j with
    | zero => intro x hx; simp [hx]
    | succ j ih =>
        intro x hx
        obtain ⟨hmem, hval⟩ := ih x hx
        refine ⟨by rw [Function.iterate_succ_apply']; exact hFσ _ hmem, ?_⟩
        rw [Function.iterate_succ_apply', Function.iterate_succ_apply',
          hshift _ (hFsub hmem), hval]
  apply Finset.Subset.antisymm
  · exact Finset.image_subset_image hFsub
  · intro w hw
    obtain ⟨y, hy, rfl⟩ := mem_image.1 hw
    obtain ⟨x₀, hx₀⟩ := hc
    obtain ⟨j, hj⟩ := htrans (g x₀) (g y)
    obtain ⟨hmem, hval⟩ := hiter j x₀ hx₀
    exact mem_image.2 ⟨σ^[j] x₀, hmem, by rw [hval, hj]⟩

/-- **The cyclic which-factor wall.**  If a shift `σ` permutes the hidden label
transitively through `π` and leaves the observable `obs` fixed, then `obs`
carries exactly zero information about the label — for a cyclic group of any
order, not just an involution. -/
theorem mutInfo_eq_zero_of_shift (hs : s.Nonempty)
    (hmaps : ∀ x ∈ s, σ x ∈ s) (hmapsτ : ∀ x ∈ s, τ x ∈ s)
    (hleft : ∀ x ∈ s, τ (σ x) = x) (hright : ∀ x ∈ s, σ (τ x) = x)
    (hshift : ∀ x ∈ s, g (σ x) = π (g x)) (hπ : Function.Injective π)
    (htrans : ∀ v w : β, ∃ j, π^[j] v = w) (hobs : ∀ x ∈ s, obs (σ x) = obs x) :
    mutInfo s g obs = 0 := by
  classical
  set K : ℝ := Real.logb 2 ((s.image g).card : ℝ) with hK
  have hHs : uEnt s g = K :=
    uEnt_eq_logb_card_of_shift hs hmaps hmapsτ hleft hright hshift hπ htrans
  have hterm : ∀ c ∈ s.image obs,
      ((#{x ∈ s | obs x = c} : ℝ) / s.card) * uEnt {x ∈ s | obs x = c} g
        = ((#{x ∈ s | obs x = c} : ℝ) / s.card) * K := by
    intro c hc
    obtain ⟨y, hy, rfl⟩ := mem_image.1 hc
    set F : Finset α := {x ∈ s | obs x = obs y} with hFdef
    have hFne : F.Nonempty := ⟨y, mem_filter.2 ⟨hy, rfl⟩⟩
    have hFsub : F ⊆ s := Finset.filter_subset _ _
    have hFσ : ∀ x ∈ F, σ x ∈ F := by
      intro x hx
      simp only [hFdef, mem_filter] at hx ⊢
      exact ⟨hmaps x hx.1, by rw [hobs x hx.1, hx.2]⟩
    have hFτ : ∀ x ∈ F, τ x ∈ F := by
      intro x hx
      simp only [hFdef, mem_filter] at hx ⊢
      have hτs : τ x ∈ s := hmapsτ x hx.1
      refine ⟨hτs, ?_⟩
      have : obs (σ (τ x)) = obs (τ x) := hobs _ hτs
      rw [hright x hx.1] at this
      rw [← this, hx.2]
    have hval : uEnt F g = Real.logb 2 ((F.image g).card : ℝ) :=
      uEnt_eq_logb_card_of_shift hFne hFσ hFτ
        (fun x hx => hleft x (hFsub hx)) (fun x hx => hright x (hFsub hx))
        (fun x hx => hshift x (hFsub hx)) hπ htrans
    have himg : F.image g = s.image g :=
      image_on_fibre_eq hmaps hshift htrans hobs hFne
    rw [hval, himg]
  have hsum : condEnt s g obs = K := by
    unfold condEnt
    rw [Finset.sum_congr rfl hterm, ← Finset.sum_mul, ← Finset.sum_div]
    have hcard : ∑ c ∈ s.image obs, ((#{x ∈ s | obs x = c} : ℝ)) = (s.card : ℝ) := by
      exact_mod_cast congrArg (Nat.cast (R := ℝ)) (sum_fiber_card s obs)
    have hNpos : (0 : ℝ) < (s.card : ℝ) := by
      exact_mod_cast Finset.card_pos.2 hs
    rw [hcard, div_self (ne_of_gt hNpos), one_mul]
  rw [mutInfo, hHs, hsum, sub_self]

end Wall

/-! ## 4. The order-two case: the semiprime wall, re-derived -/

/-- `Bool.not` is transitive on the two truth values. -/
theorem not_transitive (v w : Bool) : ∃ j, (Bool.not)^[j] v = w := by
  rcases v with _ | _ <;> rcases w with _ | _
  · exact ⟨0, rfl⟩
  · exact ⟨1, rfl⟩
  · exact ⟨1, rfl⟩
  · exact ⟨0, rfl⟩

/-- **The semiprime which-factor wall as the order-2 cyclic wall.**  Swapping the
two prime factors is the shift, negation of the orientation bit is the value
permutation, and the public data is invariant — so the wall follows from the
general cyclic principle. -/
theorem whichFactor_wall_via_shift {m n : ℕ} (hm : 2 ≤ m) (hn : 2 ≤ n) :
    mutInfo (offDiagSub m n) (orientSub m) (obsSub m) = 0 := by
  refine mutInfo_eq_zero_of_shift (σ := swapPair) (τ := swapPair) (π := Bool.not)
    (offDiagSub_nonempty hm hn) swapPair_maps swapPair_maps
    (fun x _ => swapPair_involutive x) (fun x _ => swapPair_involutive x)
    (fun x hx => ?_) (fun a b hab => by simpa using congrArg Bool.not hab)
    not_transitive obsSub_invariant
  have h := orientSub_flip (m := m) (n := n) x hx
  cases hx1 : orientSub m x <;> cases hx2 : orientSub m (swapPair x) <;> simp_all

/-- The conductor-13 cubic which-factor zero, obtained from the cyclic wall. -/
theorem conductor13_which_factor_zero_via_shift :
    mutInfo (offDiagSub 3 12) (orientSub 3) (obsSub 3) = 0 :=
  whichFactor_wall_via_shift (by norm_num) (by norm_num)

end WhichFactorWall