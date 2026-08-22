/-
# Composing reconciliation rounds: leakage is subadditive

A real protocol runs several rounds, each publishing a block of parity checks.
Concatenating the parity-check matrices models this: the composite transcript is
the pair of the two round transcripts.

* `Scheme.stack` — the composite scheme, with `Scheme.syndrome_stack` describing
  its transcript as the concatenation of the two round transcripts;
* `Scheme.consistent_stack` — the keys consistent with the composite transcript
  are exactly those consistent with both rounds;
* `Scheme.rank_stack_le` — **leakage is subadditive**: `rank (H₁ ∥ H₂) ≤
  rank H₁ + rank H₂`, so `k` rounds leak at most the sum of their individual
  leakages, no matter how the rounds interact;
* `Scheme.card_consistent_stack_ge` — the residual key space shrinks by at most
  the product of the two round factors;
* `Scheme.stack_separating_left` — extra rounds never destroy correctness: a
  composite of a separating scheme with anything still corrects `t` errors.
-/

import Mathlib
import Computation.InformationReconciliation
import Computation.InformationReconciliationLeakage

open Matrix Finset Module

namespace InformationReconciliation

variable {n m m₁ m₂ : ℕ}

/-- The composite of two rounds: stack the parity-check matrices. -/
def Scheme.stack (S₁ : Scheme n m₁) (S₂ : Scheme n m₂) (t : ℕ) : Scheme n (m₁ + m₂) :=
  ⟨Matrix.of (Fin.append S₁.H S₂.H), t⟩

/-- The composite transcript is the concatenation of the round transcripts. -/
theorem Scheme.syndrome_stack (S₁ : Scheme n m₁) (S₂ : Scheme n m₂) (t : ℕ) (x : Key n) :
    (S₁.stack S₂ t).syndrome x = Fin.append (S₁.syndrome x) (S₂.syndrome x) := by
  funext i
  refine Fin.addCases (fun k => ?_) (fun k => ?_) i <;>
    simp [Scheme.stack, Scheme.syndrome, Matrix.mulVec, dotProduct]

/-- A key passes the composite checks iff it passes both rounds' checks. -/
theorem Scheme.syndrome_stack_eq_zero_iff (S₁ : Scheme n m₁) (S₂ : Scheme n m₂) (t : ℕ)
    (x : Key n) :
    (S₁.stack S₂ t).syndrome x = 0 ↔ S₁.syndrome x = 0 ∧ S₂.syndrome x = 0 := by
  rw [Scheme.syndrome_stack]
  constructor
  · intro h
    constructor
    · funext k
      have := congrFun h (Fin.castAdd m₂ k)
      simpa using this
    · funext k
      have := congrFun h (Fin.natAdd m₁ k)
      simpa using this
  · rintro ⟨h1, h2⟩
    funext i
    refine Fin.addCases (fun k => ?_) (fun k => ?_) i
    · simpa using congrFun h1 k
    · simpa using congrFun h2 k

/-- The keys consistent with the composite zero-transcript are exactly those
consistent with both rounds. -/
theorem Scheme.consistent_stack (S₁ : Scheme n m₁) (S₂ : Scheme n m₂) (t : ℕ) :
    (S₁.stack S₂ t).consistent 0 = S₁.consistent 0 ∩ S₂.consistent 0 := by
  ext x
  simp only [Scheme.consistent, Finset.mem_inter, Finset.mem_filter, Finset.mem_univ, true_and]
  exact Scheme.syndrome_stack_eq_zero_iff S₁ S₂ t x

/-- Rank-nullity for the syndrome map, in the form used below. -/
theorem Scheme.rank_add_finrank_ker (S : Scheme n m) :
    S.rank + finrank (ZMod 2) (LinearMap.ker S.H.mulVecLin) = n := by
  have h2 := LinearMap.finrank_range_add_finrank_ker (K := ZMod 2) S.H.mulVecLin
  have h3 : finrank (ZMod 2) (Fin n → ZMod 2) = n := by simp
  simp only [Scheme.rank]
  omega

/-- The kernel of the composite scheme is the intersection of the two kernels. -/
theorem Scheme.ker_stack (S₁ : Scheme n m₁) (S₂ : Scheme n m₂) (t : ℕ) :
    LinearMap.ker (S₁.stack S₂ t).H.mulVecLin
      = LinearMap.ker S₁.H.mulVecLin ⊓ LinearMap.ker S₂.H.mulVecLin := by
  ext x
  simp only [Submodule.mem_inf, LinearMap.mem_ker, Matrix.mulVecLin_apply]
  exact Scheme.syndrome_stack_eq_zero_iff S₁ S₂ t x

/-- **Subadditivity of leakage.**  Composing rounds leaks at most the sum of the
individual leakages. -/
theorem Scheme.rank_stack_le (S₁ : Scheme n m₁) (S₂ : Scheme n m₂) (t : ℕ) :
    (S₁.stack S₂ t).rank ≤ S₁.rank + S₂.rank := by
  have hK := Scheme.ker_stack S₁ S₂ t
  have hsup := Submodule.finrank_sup_add_finrank_inf_eq
    (LinearMap.ker S₁.H.mulVecLin) (LinearMap.ker S₂.H.mulVecLin)
  have hle : finrank (ZMod 2)
      ↥((LinearMap.ker S₁.H.mulVecLin) ⊔ (LinearMap.ker S₂.H.mulVecLin)) ≤ n := by
    have := Submodule.finrank_le
      ((LinearMap.ker S₁.H.mulVecLin) ⊔ (LinearMap.ker S₂.H.mulVecLin))
    simpa using this
  have h1 := S₁.rank_add_finrank_ker
  have h2 := S₂.rank_add_finrank_ker
  have h12 := (S₁.stack S₂ t).rank_add_finrank_ker
  rw [hK] at h12
  omega

/-- The composite transcript can be no longer than the two rounds together, and
its leakage is bounded by the number of published bits. -/
theorem Scheme.rank_stack_le_length (S₁ : Scheme n m₁) (S₂ : Scheme n m₂) (t : ℕ) :
    (S₁.stack S₂ t).rank ≤ m₁ + m₂ :=
  (S₁.stack S₂ t).rank_le_length

/-- **Residual key space under composition.**  The two rounds together cut the
candidate set down by at most the product of their individual factors. -/
theorem Scheme.card_consistent_stack_ge (S₁ : Scheme n m₁) (S₂ : Scheme n m₂) (t : ℕ) :
    (S₁.consistent 0).card * (S₂.consistent 0).card
      ≤ 2 ^ n * ((S₁.stack S₂ t).consistent 0).card := by
  have h1 := S₁.card_consistent_zero
  have h2 := S₂.card_consistent_zero
  have h12 := (S₁.stack S₂ t).card_consistent_zero
  have hsub := Scheme.rank_stack_le S₁ S₂ t
  have hr1 := S₁.rank_le_dim
  have hr2 := S₂.rank_le_dim
  have hr12 := (S₁.stack S₂ t).rank_le_dim
  rw [h1, h2, h12, ← pow_add, ← pow_add]
  exact Nat.pow_le_pow_right (by norm_num) (by omega)

/-- Extra rounds never break correctness: if the first round already separates
error patterns of weight `≤ t`, so does the composite. -/
theorem Scheme.stack_separating_left {S₁ : Scheme n m₁} (S₂ : Scheme n m₂)
    (hS : S₁.Separating) : (S₁.stack S₂ S₁.t).Separating := by
  intro c hc hne
  have h1 : S₁.syndrome c = 0 := ((Scheme.syndrome_stack_eq_zero_iff S₁ S₂ S₁.t c).1 hc).1
  exact hS c h1 hne

/-- Consequently the composite protocol still reconciles every `t`-close pair,
while leaking at most `rank H₁ + rank H₂` bits. -/
theorem Scheme.stack_correct {S₁ : Scheme n m₁} (S₂ : Scheme n m₂) (hS : S₁.Separating)
    {a b : Key n} (hab : hammingNorm (a - b) ≤ S₁.t) :
    (S₁.stack S₂ S₁.t).correct b ((S₁.stack S₂ S₁.t).transcript a) = a :=
  Scheme.correct_transcript (Scheme.stack_separating_left S₂ hS) hab

end InformationReconciliation