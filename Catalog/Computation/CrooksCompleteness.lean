import Mathlib
import Computation.FluctuationRobustDemon

/-!
# Crooks-completeness of the finite fluctuation model

`Catalog/Computation/FluctuationRobustDemon.lean` introduced the finite work systems
`FluctDemon.WorkSystem`, the Jarzynski equality `FluctDemon.Jarzynski` and the discrete
detailed fluctuation relation `FluctDemon.CrooksPair`, and proved the easy implication
`FluctDemon.jarzynski_of_crooks` : a Crooks pair obeys Jarzynski.

This file settles the **converse**, which was Conjecture 4 of `FUTURE_DIRECTIONS.md`
("Crooks-completeness of the finite model"): *every* finite work system obeying the
Jarzynski equality at cost `ΔF` is the forward half of a Crooks pair at the same
`(β, ΔF)` — and this holds on the *same* outcome space, for an arbitrarily prescribed
time reversal `flip`.  The reverse protocol is moreover unique, so the Crooks partner is
not an extra datum but a function of the forward protocol and the chosen reversal.

Consequently the conjecture's second clause ("a system admitting no Crooks partner must
have an outcome of zero forward and nonzero reverse probability") is **vacuous**: there
are no Jarzynski-compliant systems without a Crooks partner
(`FluctDemon.no_jarzynski_system_lacks_crooks_partner`).

Beyond the equivalence, the Crooks structure is used to *sharpen* the one-shot Chernoff
bound `FluctDemon.single_deficit_bound`: the deficit probability is bounded by
`e^{-β(ΔF - w)}` multiplied by the reverse-protocol mass of the time-reversed deficit
event (`FluctDemon.crooks_deficit_le_rev`).  For the catalog's `coinDemon` this sharpened
bound is *exactly attained* (`FluctDemon.coinCrooks_sharpened_bound_eq`, value `1/2`),
whereas the unsharpened bound only gives `2/3`.

## Main definitions

* `FluctDemon.reverseSystem` — the reverse protocol forced by a forward protocol, a time
  reversal and the Jarzynski equality.
* `FluctDemon.crooksCompletion` — the resulting `CrooksPair` with prescribed forward half.
* `FluctDemon.CrooksPair.reverse` — the time-reversed pair, a `CrooksPair` at `(β, -ΔF)`.
* `FluctDemon.revDeficitMass` — reverse mass of the time reverse of the deficit event.

## Main results

* `FluctDemon.jarzynski_iff_exists_crooks` — **Crooks-completeness**:
  `Jarzynski β ΔF S ↔ ∃ C : CrooksPair β ΔF Ω, C.fwd = S`.
* `FluctDemon.crooks_rev_unique` — the reverse protocol is determined by `(fwd, flip)`.
* `FluctDemon.crooks_rev_jarzynski` — the reverse half of any Crooks pair obeys Jarzynski
  at `-ΔF`; hence `FluctDemon.CrooksPair.reverse` is again a Crooks pair.
* `FluctDemon.crooks_deficit_le_rev`, `FluctDemon.crooks_deficit_strict` — the sharpened
  one-shot bound and its strict form.
* `FluctDemon.coinCrooks_rev_prob_true`, `…_false`, `FluctDemon.coinCrooks_deficit_eq`,
  `FluctDemon.coinCrooks_sharpened_bound_eq` — an explicit non-vacuity witness in which
  the sharpened bound is attained with equality.
-/

open Finset Real

noncomputable section

namespace FluctDemon

variable {Ω : Type*} [Fintype Ω]

/-! ## The reverse protocol forced by Jarzynski -/

/-- The **reverse protocol** attached to a Jarzynski-compliant forward protocol `S` and a
prescribed time reversal `flip`.  Its probabilities are the unique solution of the Crooks
detailed fluctuation relation, and the Jarzynski equality is exactly what makes them sum
to one. -/
def reverseSystem (β ΔF : ℝ) (S : WorkSystem Ω) (flip : Ω ≃ Ω)
    (hJ : Jarzynski β ΔF S) : WorkSystem Ω where
  prob := fun σ => S.prob (flip.symm σ) * Real.exp (-β * (S.work (flip.symm σ) - ΔF))
  work := fun σ => -S.work (flip.symm σ)
  prob_nonneg := fun σ => mul_nonneg (S.prob_nonneg _) (Real.exp_nonneg _)
  prob_sum := by
    have hre : (∑ σ, S.prob (flip.symm σ) * Real.exp (-β * (S.work (flip.symm σ) - ΔF)))
        = ∑ ω, S.prob ω * Real.exp (-β * (S.work ω - ΔF)) :=
      Fintype.sum_equiv flip.symm _ _ (fun _ => rfl)
    have hterm : ∀ ω : Ω, S.prob ω * Real.exp (-β * (S.work ω - ΔF))
        = Real.exp (β * ΔF) * (S.prob ω * Real.exp (-β * S.work ω)) := by
      intro ω
      have hx : -β * (S.work ω - ΔF) = β * ΔF + -β * S.work ω := by ring
      rw [hx, Real.exp_add]
      ring
    rw [hre, Finset.sum_congr rfl (fun ω _ => hterm ω), ← Finset.mul_sum]
    have : ∑ ω, S.prob ω * Real.exp (-β * S.work ω) = Real.exp (-β * ΔF) := hJ
    rw [this, ← Real.exp_add]
    have : β * ΔF + -β * ΔF = 0 := by ring
    rw [this, Real.exp_zero]

@[simp] lemma reverseSystem_prob {β ΔF : ℝ} {S : WorkSystem Ω} {flip : Ω ≃ Ω}
    (hJ : Jarzynski β ΔF S) (σ : Ω) :
    (reverseSystem β ΔF S flip hJ).prob σ
      = S.prob (flip.symm σ) * Real.exp (-β * (S.work (flip.symm σ) - ΔF)) := rfl

@[simp] lemma reverseSystem_work {β ΔF : ℝ} {S : WorkSystem Ω} {flip : Ω ≃ Ω}
    (hJ : Jarzynski β ΔF S) (σ : Ω) :
    (reverseSystem β ΔF S flip hJ).work σ = -S.work (flip.symm σ) := rfl

/-- The reverse protocol charges every time-reversed outcome that the forward protocol
charges: no information is lost in passing to the Crooks partner. -/
theorem reverseSystem_prob_pos {β ΔF : ℝ} {S : WorkSystem Ω} {flip : Ω ≃ Ω}
    (hJ : Jarzynski β ΔF S) {ω : Ω} (hω : 0 < S.prob ω) :
    0 < (reverseSystem β ΔF S flip hJ).prob (flip ω) := by
  simp only [reverseSystem_prob, Equiv.symm_apply_apply]
  exact mul_pos hω (Real.exp_pos _)

/-- The **Crooks completion** of a Jarzynski-compliant protocol: a Crooks pair whose
forward half is the given protocol and whose time reversal is the prescribed `flip`. -/
def crooksCompletion (β ΔF : ℝ) (S : WorkSystem Ω) (flip : Ω ≃ Ω)
    (hJ : Jarzynski β ΔF S) : CrooksPair β ΔF Ω where
  fwd := S
  rev := reverseSystem β ΔF S flip hJ
  flip := flip
  work_odd := by
    intro ω
    simp [Equiv.symm_apply_apply]
  crooks := by
    intro ω
    simp only [reverseSystem_prob, Equiv.symm_apply_apply]
    rw [← mul_assoc, mul_comm (Real.exp (β * (S.work ω - ΔF))) (S.prob ω), mul_assoc,
      ← Real.exp_add]
    have : β * (S.work ω - ΔF) + -β * (S.work ω - ΔF) = 0 := by ring
    rw [this, Real.exp_zero, mul_one]

@[simp] lemma crooksCompletion_fwd (β ΔF : ℝ) (S : WorkSystem Ω) (flip : Ω ≃ Ω)
    (hJ : Jarzynski β ΔF S) : (crooksCompletion β ΔF S flip hJ).fwd = S := rfl

/-- **Crooks-completeness of the finite model.**  A finite work system obeys the Jarzynski
equality at `(β, ΔF)` *if and only if* it is the forward half of a discrete Crooks pair at
the same `(β, ΔF)`.  The forward implication is the content of this file; the backward one
is the catalog's `jarzynski_of_crooks`. -/
theorem jarzynski_iff_exists_crooks {β ΔF : ℝ} (S : WorkSystem Ω) :
    Jarzynski β ΔF S ↔ ∃ C : CrooksPair β ΔF Ω, C.fwd = S := by
  constructor
  · intro hJ
    exact ⟨crooksCompletion β ΔF S (Equiv.refl Ω) hJ, rfl⟩
  · rintro ⟨C, rfl⟩
    exact jarzynski_of_crooks C

/-- The conjectured obstruction is **vacuous**: no Jarzynski-compliant finite system fails
to admit a Crooks partner, whatever its support. -/
theorem no_jarzynski_system_lacks_crooks_partner {β ΔF : ℝ} (S : WorkSystem Ω)
    (hJ : Jarzynski β ΔF S) : ∃ C : CrooksPair β ΔF Ω, C.fwd = S :=
  (jarzynski_iff_exists_crooks S).mp hJ

/-! ## Rigidity: the reverse protocol is unique -/

/-- The reverse probabilities of a Crooks pair are determined by the forward protocol and
the time reversal. -/
theorem crooks_rev_prob_eq {β ΔF : ℝ} (C : CrooksPair β ΔF Ω) (ω : Ω) :
    C.rev.prob (C.flip ω)
      = Real.exp (-β * (C.fwd.work ω - ΔF)) * C.fwd.prob ω := by
  rw [C.crooks ω, ← mul_assoc, ← Real.exp_add]
  have : -β * (C.fwd.work ω - ΔF) + β * (C.fwd.work ω - ΔF) = 0 := by ring
  rw [this, Real.exp_zero, one_mul]

/-- **Uniqueness of the Crooks partner.**  Two Crooks pairs with the same forward protocol
and the same time reversal have the same reverse protocol (both probabilities and work). -/
theorem crooks_rev_unique {β ΔF : ℝ} (C C' : CrooksPair β ΔF Ω)
    (hfwd : C.fwd = C'.fwd) (hflip : C.flip = C'.flip) :
    (∀ σ, C.rev.prob σ = C'.rev.prob σ) ∧ (∀ σ, C.rev.work σ = C'.rev.work σ) := by
  constructor
  · intro σ
    have h1 := crooks_rev_prob_eq C (C.flip.symm σ)
    have h2 := crooks_rev_prob_eq C' (C'.flip.symm σ)
    rw [Equiv.apply_symm_apply] at h1 h2
    rw [h1, h2, hfwd, hflip]
  · intro σ
    have h1 := C.work_odd (C.flip.symm σ)
    have h2 := C'.work_odd (C'.flip.symm σ)
    rw [Equiv.apply_symm_apply] at h1 h2
    rw [h1, h2, hfwd, hflip]

/-! ## The reverse pair -/

/-- The reverse half of a Crooks pair obeys the Jarzynski equality at the *opposite*
free-energy difference.  Note that no hypothesis on the forward half is needed: it follows
from the detailed fluctuation relation alone. -/
theorem crooks_rev_jarzynski {β ΔF : ℝ} (C : CrooksPair β ΔF Ω) :
    Jarzynski β (-ΔF) C.rev := by
  unfold Jarzynski expAvg
  have hre : (∑ ω : Ω, C.rev.prob (C.flip ω) * Real.exp (-β * C.rev.work (C.flip ω)))
      = ∑ σ : Ω, C.rev.prob σ * Real.exp (-β * C.rev.work σ) :=
    Fintype.sum_equiv C.flip _ _ (fun _ => rfl)
  have hterm : ∀ ω : Ω, C.rev.prob (C.flip ω) * Real.exp (-β * C.rev.work (C.flip ω))
      = Real.exp (β * ΔF) * C.fwd.prob ω := by
    intro ω
    rw [crooks_rev_prob_eq C ω, C.work_odd ω, mul_comm (Real.exp (-β * (C.fwd.work ω - ΔF)))
      (C.fwd.prob ω), mul_assoc, ← Real.exp_add, mul_comm (Real.exp (β * ΔF)) (C.fwd.prob ω)]
    congr 2
    ring
  rw [← hre, Finset.sum_congr rfl (fun ω _ => hterm ω), ← Finset.mul_sum, C.fwd.prob_sum,
    mul_one]
  congr 1
  ring

/-- **The time-reversed Crooks pair.**  Swapping forward and reverse protocols and
inverting the time reversal produces a Crooks pair at `(β, -ΔF)`: the detailed fluctuation
relation is symmetric under reversal. -/
def CrooksPair.reverse {β ΔF : ℝ} (C : CrooksPair β ΔF Ω) : CrooksPair β (-ΔF) Ω where
  fwd := C.rev
  rev := C.fwd
  flip := C.flip.symm
  work_odd := by
    intro σ
    have h := C.work_odd (C.flip.symm σ)
    rw [Equiv.apply_symm_apply] at h
    rw [h, neg_neg]
  crooks := by
    intro σ
    have hw : C.fwd.work (C.flip.symm σ) = -C.rev.work σ := by
      have h := C.work_odd (C.flip.symm σ)
      rw [Equiv.apply_symm_apply] at h
      linarith
    have h := crooks_rev_prob_eq C (C.flip.symm σ)
    rw [Equiv.apply_symm_apply, hw] at h
    have hx : -β * (-C.rev.work σ - ΔF) = β * (C.rev.work σ - -ΔF) := by ring
    rw [h, hx]

@[simp] lemma CrooksPair.reverse_fwd {β ΔF : ℝ} (C : CrooksPair β ΔF Ω) :
    C.reverse.fwd = C.rev := rfl

@[simp] lemma CrooksPair.reverse_rev {β ΔF : ℝ} (C : CrooksPair β ΔF Ω) :
    C.reverse.rev = C.fwd := rfl

/-- Reversal is an involution on Crooks pairs (stated componentwise, since the free-energy
index changes from `ΔF` to `- -ΔF`). -/
theorem CrooksPair.reverse_reverse {β ΔF : ℝ} (C : CrooksPair β ΔF Ω) :
    C.reverse.reverse.fwd = C.fwd ∧ C.reverse.reverse.rev = C.rev ∧
      C.reverse.reverse.flip = C.flip :=
  ⟨rfl, rfl, rfl⟩

/-! ## The Crooks-sharpened one-shot bound -/

/-- The reverse-protocol mass of the time reverse of the deficit event `{W ≤ w}`. -/
def revDeficitMass (w : ℝ) {β ΔF : ℝ} (C : CrooksPair β ΔF Ω) : ℝ := by
  classical
  exact ∑ ω ∈ univ.filter (fun ω => C.fwd.work ω ≤ w), C.rev.prob (C.flip ω)

lemma revDeficitMass_nonneg (w : ℝ) {β ΔF : ℝ} (C : CrooksPair β ΔF Ω) :
    0 ≤ revDeficitMass w C := by
  classical
  unfold revDeficitMass
  exact Finset.sum_nonneg fun ω _ => C.rev.prob_nonneg _

/-- The reverse mass of an event is at most one. -/
theorem revDeficitMass_le_one (w : ℝ) {β ΔF : ℝ} (C : CrooksPair β ΔF Ω) :
    revDeficitMass w C ≤ 1 := by
  classical
  unfold revDeficitMass
  set A : Finset Ω := univ.filter (fun ω => C.fwd.work ω ≤ w) with hA
  have himg : ∑ ω ∈ A, C.rev.prob (C.flip ω) = ∑ σ ∈ A.image C.flip, C.rev.prob σ := by
    rw [Finset.sum_image]
    intro x _ y _ h
    exact C.flip.injective h
  rw [himg]
  have hsub : A.image C.flip ⊆ (univ : Finset Ω) := Finset.subset_univ _
  have := Finset.sum_le_sum_of_subset_of_nonneg hsub
    (fun σ _ _ => C.rev.prob_nonneg σ)
  rw [C.rev.prob_sum] at this
  exact this

/-- **Crooks-sharpened one-shot fluctuation bound.**  The probability that the forward
protocol spends work at most `w` is bounded by `e^{-β(ΔF - w)}` *times the reverse mass of
the time-reversed deficit event*.  This strictly refines `single_deficit_bound`, which is
the special case in which the reverse mass is estimated by `1`. -/
theorem crooks_deficit_le_rev {β ΔF w : ℝ} (hβ : 0 ≤ β) (C : CrooksPair β ΔF Ω) :
    singleDeficitProb w C.fwd ≤ Real.exp (-β * (ΔF - w)) * revDeficitMass w C := by
  classical
  unfold singleDeficitProb revDeficitMass
  rw [Finset.mul_sum]
  refine Finset.sum_le_sum fun ω hω => ?_
  have hw : C.fwd.work ω ≤ w := (Finset.mem_filter.mp hω).2
  rw [C.crooks ω]
  have hle : Real.exp (β * (C.fwd.work ω - ΔF)) ≤ Real.exp (-β * (ΔF - w)) := by
    apply Real.exp_le_exp.mpr
    nlinarith
  exact mul_le_mul_of_nonneg_right hle (C.rev.prob_nonneg _)

/-- Recovering the unsharpened bound from the Crooks relation alone. -/
theorem crooks_single_deficit_bound {β ΔF w : ℝ} (hβ : 0 ≤ β) (C : CrooksPair β ΔF Ω) :
    singleDeficitProb w C.fwd ≤ Real.exp (-β * (ΔF - w)) := by
  have h := crooks_deficit_le_rev (w := w) hβ C
  have h2 : Real.exp (-β * (ΔF - w)) * revDeficitMass w C
      ≤ Real.exp (-β * (ΔF - w)) * 1 :=
    mul_le_mul_of_nonneg_left (revDeficitMass_le_one w C) (Real.exp_nonneg _)
  rw [mul_one] at h2
  exact le_trans h h2

/-- **Strict improvement.**  Whenever the time-reversed deficit event is not almost sure
under the reverse protocol, the one-shot Chernoff bound is strictly slack. -/
theorem crooks_deficit_strict {β ΔF w : ℝ} (hβ : 0 ≤ β) (C : CrooksPair β ΔF Ω)
    (hlt : revDeficitMass w C < 1) :
    singleDeficitProb w C.fwd < Real.exp (-β * (ΔF - w)) := by
  have h := crooks_deficit_le_rev (w := w) hβ C
  have h2 : Real.exp (-β * (ΔF - w)) * revDeficitMass w C < Real.exp (-β * (ΔF - w)) := by
    have := mul_lt_mul_of_pos_left hlt (Real.exp_pos (-β * (ΔF - w)))
    rwa [mul_one] at this
  exact lt_of_le_of_lt h h2

/-! ## A witness where the sharpened bound is exactly attained -/

section CoinWitness

variable {β ΔF : ℝ}

/-- The Crooks partner of the catalog's `coinDemon`, with trivial time reversal. -/
def coinCrooks (hβ : 0 < β) : CrooksPair β ΔF Bool :=
  crooksCompletion β ΔF (coinDemon β ΔF) (Equiv.refl Bool) (coinDemon_jarzynski hβ)

/-- The reverse protocol of the coin demon assigns probability `1/4` to the expensive
outcome. -/
theorem coinCrooks_rev_prob_true (hβ : 0 < β) :
    (coinCrooks (β := β) (ΔF := ΔF) hβ).rev.prob true = 1 / 4 := by
  have hβ' : β ≠ 0 := ne_of_gt hβ
  show (coinDemon β ΔF).prob true *
      Real.exp (-β * ((coinDemon β ΔF).work true - ΔF)) = 1 / 4
  have hw : (coinDemon β ΔF).work true = ΔF + Real.log 2 / β := rfl
  have hp : (coinDemon β ΔF).prob true = 1 / 2 := rfl
  rw [hw, hp]
  have : -β * (ΔF + Real.log 2 / β - ΔF) = -Real.log 2 := by field_simp; ring
  rw [this, ← Real.log_inv, Real.exp_log (by norm_num : (0:ℝ) < (2:ℝ)⁻¹)]
  norm_num

/-- The reverse protocol of the coin demon assigns probability `3/4` to the cheap
outcome. -/
theorem coinCrooks_rev_prob_false (hβ : 0 < β) :
    (coinCrooks (β := β) (ΔF := ΔF) hβ).rev.prob false = 3 / 4 := by
  have hβ' : β ≠ 0 := ne_of_gt hβ
  show (coinDemon β ΔF).prob false *
      Real.exp (-β * ((coinDemon β ΔF).work false - ΔF)) = 3 / 4
  have hw : (coinDemon β ΔF).work false = ΔF - Real.log (3 / 2) / β := rfl
  have hp : (coinDemon β ΔF).prob false = 1 / 2 := rfl
  rw [hw, hp]
  have : -β * (ΔF - Real.log (3 / 2) / β - ΔF) = Real.log (3 / 2) := by field_simp; ring
  rw [this, Real.exp_log (by norm_num : (0:ℝ) < (3:ℝ) / 2)]
  norm_num

/-- At the sub-threshold level `w = ΔF - log(3/2)/β` only the cheap outcome is a deficit
outcome. -/
theorem coinDemon_deficit_filter (hβ : 0 < β) :
    (univ.filter (fun b : Bool => (coinDemon β ΔF).work b ≤ ΔF - Real.log (3 / 2) / β))
      = {false} := by
  classical
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hlog32 : 0 < Real.log (3 / 2) := Real.log_pos (by norm_num)
  have h1 : 0 < Real.log 2 / β := div_pos hlog2 hβ
  have h2 : 0 < Real.log (3 / 2) / β := div_pos hlog32 hβ
  ext b
  cases b with
  | false =>
      simp [coinDemon]
  | true =>
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton,
        coinDemon]
      constructor
      · intro h
        exfalso
        simp only [Bool.cond_true] at h
        linarith
      · intro h
        exact absurd h (by simp)

/-- The coin demon's exact sub-threshold probability is `1/2`. -/
theorem coinCrooks_deficit_eq (hβ : 0 < β) :
    singleDeficitProb (ΔF - Real.log (3 / 2) / β) (coinDemon β ΔF) = 1 / 2 := by
  classical
  unfold singleDeficitProb
  rw [coinDemon_deficit_filter hβ]
  simp [coinDemon]

/-- The reverse mass of the time-reversed deficit event is `3/4`. -/
theorem coinCrooks_revDeficitMass (hβ : 0 < β) :
    revDeficitMass (ΔF - Real.log (3 / 2) / β) (coinCrooks (β := β) (ΔF := ΔF) hβ)
      = 3 / 4 := by
  classical
  unfold revDeficitMass
  have hfwd : (coinCrooks (β := β) (ΔF := ΔF) hβ).fwd = coinDemon β ΔF := rfl
  rw [hfwd, coinDemon_deficit_filter hβ]
  rw [Finset.sum_singleton]
  show (coinCrooks (β := β) (ΔF := ΔF) hβ).rev.prob false = 3 / 4
  exact coinCrooks_rev_prob_false hβ

/-- **The sharpened bound is attained.**  For the coin demon the Crooks-sharpened one-shot
bound equals the true sub-threshold probability `1/2`, while the unsharpened Chernoff bound
only gives `2/3`.  So the reverse-mass factor of `crooks_deficit_le_rev` is exactly the
missing quantity in `single_deficit_bound`. -/
theorem coinCrooks_sharpened_bound_eq (hβ : 0 < β) :
    Real.exp (-β * (ΔF - (ΔF - Real.log (3 / 2) / β)))
        * revDeficitMass (ΔF - Real.log (3 / 2) / β) (coinCrooks (β := β) (ΔF := ΔF) hβ)
      = singleDeficitProb (ΔF - Real.log (3 / 2) / β) (coinDemon β ΔF) := by
  have hβ' : β ≠ 0 := ne_of_gt hβ
  rw [coinCrooks_revDeficitMass hβ, coinCrooks_deficit_eq hβ]
  have hx : -β * (ΔF - (ΔF - Real.log (3 / 2) / β)) = -Real.log (3 / 2) := by field_simp; ring
  rw [hx, ← Real.log_inv,
    Real.exp_log (by norm_num : (0:ℝ) < ((3:ℝ) / 2)⁻¹)]
  norm_num

/-- The unsharpened Chernoff bound for the same data is `2/3`, strictly worse than the true
value `1/2`; hence the strict-improvement lemma is not vacuous either. -/
theorem coinCrooks_unsharpened_bound (hβ : 0 < β) :
    Real.exp (-β * (ΔF - (ΔF - Real.log (3 / 2) / β))) = 2 / 3 := by
  have hβ' : β ≠ 0 := ne_of_gt hβ
  have hx : -β * (ΔF - (ΔF - Real.log (3 / 2) / β)) = -Real.log (3 / 2) := by field_simp; ring
  rw [hx, ← Real.log_inv, Real.exp_log (by norm_num : (0:ℝ) < ((3:ℝ) / 2)⁻¹)]
  norm_num

/-- Consequently the Crooks-sharpened bound is strictly stronger than the Chernoff bound
for the coin demon. -/
theorem coinCrooks_sharpened_lt_unsharpened (hβ : 0 < β) :
    Real.exp (-β * (ΔF - (ΔF - Real.log (3 / 2) / β)))
        * revDeficitMass (ΔF - Real.log (3 / 2) / β) (coinCrooks (β := β) (ΔF := ΔF) hβ)
      < Real.exp (-β * (ΔF - (ΔF - Real.log (3 / 2) / β))) := by
  rw [coinCrooks_sharpened_bound_eq hβ, coinCrooks_unsharpened_bound hβ,
    coinCrooks_deficit_eq hβ]
  norm_num

end CoinWitness

end FluctDemon

end