/-
Copyright (c) 2025. Released under Apache 2.0 license.

# The Baker–Norine rank of a divisor

This file defines the (Baker–Norine) rank of a divisor and proves its basic
properties, culminating in a closed formula for the rank when *every* pair of
equal-degree divisors is linearly equivalent (the "genus-0" / tree situation).

## Main definitions

* `LinEquivEffective D` — `D` is linearly equivalent to an effective divisor.
* `SatisfiesRank D n`   — every effective divisor of degree `n` can be subtracted
                          from `D` while staying in the effective-equivalent locus.
* `rank D`              — the Baker–Norine rank: `-1` if `D` is not equivalent to an
                          effective divisor, otherwise the largest `n` with
                          `SatisfiesRank D n`.

## Main results

* `deg_nonneg_of_effective`           — effective divisors have non-negative degree.
* `rank_neg_of_deg_neg`               — negative-degree divisors have rank `-1`.
* `rank_of_complete_equiv`            — if all equal-degree divisors are equivalent,
                                        then `rank D = deg D` for `deg D ≥ 0` and `-1`
                                        otherwise.

-- !-- Lab Notes -- !--
Hypothesis: the rank of a divisor is governed entirely by its degree once linear
equivalence collapses to degree (the tree case).  Experiment: define `rank` via
`sSup` over the satisfiability set and compute it.  Analysis: the only subtle
point is that the satisfiability set is bounded above by `deg D`, which makes
`sSup` well-behaved (`IsGreatest.csSup_eq`); without that bound `Nat.sSup` would
silently return `0`.  Critique: the construction of effective divisors of a given
degree requires `Nonempty G.V`; we make that explicit.
-/

import Tropical.RiemannRoch.Basic

open Finset BigOperators

namespace BakerNorine

variable {G : FinGraph}

/-- `D` is linearly equivalent to some effective divisor. -/
def LinEquivEffective (D : Divisor G) : Prop := ∃ F : Divisor G, Effective F ∧ LinEquiv D F

/-- Pointwise subtraction of divisors. -/
def subDiv (D E : Divisor G) : Divisor G := fun v => D v - E v

/-- `D` "satisfies rank `n`": every effective divisor of degree `n`, when removed
from `D`, leaves something equivalent to an effective divisor. -/
def SatisfiesRank (D : Divisor G) (n : ℕ) : Prop :=
  ∀ E : Divisor G, Effective E → deg E = (n : ℤ) → LinEquivEffective (subDiv D E)

open scoped Classical in
/-- The Baker–Norine rank of a divisor. -/
noncomputable def rank (D : Divisor G) : ℤ :=
  if LinEquivEffective D then ((sSup {n : ℕ | SatisfiesRank D n} : ℕ) : ℤ) else -1

/-
Effective divisors have non-negative degree.
-/
theorem deg_nonneg_of_effective {F : Divisor G} (h : Effective F) : 0 ≤ deg F := by
  exact Finset.sum_nonneg fun v _ => h v

/-
A divisor equivalent to an effective one has non-negative degree.
-/
theorem LinEquivEffective.deg_nonneg {D : Divisor G} (h : LinEquivEffective D) : 0 ≤ deg D := by
  obtain ⟨ F, hF, hD ⟩ := h; exact hD.deg_eq.symm ▸ deg_nonneg_of_effective hF;

/-
Negative-degree divisors are not equivalent to any effective divisor.
-/
theorem not_linEquivEffective_of_deg_neg {D : Divisor G} (h : deg D < 0) :
    ¬ LinEquivEffective D := by
  exact fun h' => h.not_ge <| h'.deg_nonneg

/-
The rank of a divisor not equivalent to an effective one is `-1`.
-/
theorem rank_eq_neg_one_of_not {D : Divisor G} (h : ¬ LinEquivEffective D) : rank D = -1 := by
  unfold rank; aesop;

/-
Negative-degree divisors have rank `-1`.
-/
theorem rank_neg_of_deg_neg {D : Divisor G} (h : deg D < 0) : rank D = -1 := by
  exact rank_eq_neg_one_of_not ( not_linEquivEffective_of_deg_neg h )

/-
For any non-negative `k` there is an effective divisor of degree `k`
(put all chips on a single vertex).
-/
theorem exists_effective_deg [Nonempty G.V] (k : ℕ) :
    ∃ F : Divisor G, Effective F ∧ deg F = (k : ℤ) := by
  obtain ⟨ v ⟩ := ‹Nonempty G.V›;
  use fun w => if w = v then (k : ℤ) else 0;
  exact ⟨ fun w => by positivity, by unfold deg; simp ⟩

/-
**Rank in the genus-0 (complete-equivalence) situation.**
If every two divisors of equal degree are linearly equivalent, then the rank is
`deg D` when `deg D ≥ 0` and `-1` otherwise.
-/
theorem rank_of_complete_equiv [Nonempty G.V]
    (hsurj : ∀ D D' : Divisor G, deg D = deg D' → LinEquiv D D') (D : Divisor G) :
    rank D = if 0 ≤ deg D then deg D else -1 := by
  by_cases hD : 0 ≤ deg D;
  · -- Since $0 \leq \deg D$, we can apply the result from the previous step to conclude that $\text{rank } D = \deg D$.
    have h_rank_eq_deg : ∀ n : ℕ, n ≤ deg D → SatisfiesRank D n := by
      intro n hn
      intro E hE hE_deg
      have h_deg_sub : deg (subDiv D E) = deg D - n := by
        simp +decide [ ← hE_deg, subDiv, deg ];
      obtain ⟨F, hF⟩ : ∃ F : Divisor G, Effective F ∧ deg F = deg D - n := by
        convert exists_effective_deg ( Int.toNat ( deg D - n ) ) using 1;
        · rw [ Int.toNat_of_nonneg ( sub_nonneg_of_le hn ) ];
        · infer_instance;
      exact ⟨ F, hF.1, hsurj _ _ ( by linarith ) ⟩;
    have h_rank_eq_deg : ∀ n : ℕ, SatisfiesRank D n → n ≤ deg D := by
      intro n hn
      obtain ⟨E, hE_eff, hE_deg⟩ : ∃ E : Divisor G, Effective E ∧ deg E = n := by
        exact exists_effective_deg n;
      have := hn E hE_eff hE_deg;
      have := this.deg_nonneg; simp_all +decide [ subDiv ] ;
      unfold subDiv at this; simp_all +decide [ deg ] ;
    rw [ if_pos hD ];
    rw [ rank, if_pos ];
    · rw [ eq_comm, csSup_eq_of_forall_le_of_forall_lt_exists_gt ];
      rw [ Int.toNat_of_nonneg hD ];
      · exact ⟨ 0, by aesop ⟩;
      · exact fun n hn => by linarith [ h_rank_eq_deg n hn, Int.toNat_of_nonneg hD ] ;
      · exact fun w hw => ⟨ Int.toNat ( deg D ), by aesop, hw ⟩;
    · obtain ⟨F, hF⟩ : ∃ F : Divisor G, Effective F ∧ deg F = deg D := by
        convert exists_effective_deg ( Int.toNat ( deg D ) ) using 1;
        · rw [ Int.toNat_of_nonneg hD ];
        · infer_instance;
      exact ⟨ F, hF.1, hsurj _ _ hF.2.symm ⟩;
  · rw [ if_neg hD, rank_neg_of_deg_neg ] ; linarith

end BakerNorine