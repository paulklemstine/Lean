import Cryptography.ChebotarevPrecision.MasterTable
import Cryptography.ChebotarevPrecision.FineDial

/-!
# Paper 134 — Chebotarev precision IV: simultaneous measurement and coprime dials

Experiment 463 measured all fields *simultaneously* — one protocol, one seed, one prime
range.  For linearly disjoint fields the Chebotarev law of the joint Frobenius is the
product law on `S_A × S_B`.  Two facts make the simultaneous protocol equivalent to the
field-by-field one, and they are proved here in general.

* `simultaneous_measurement_invariance` — inside the joint population every field's own
  channel is *unchanged* (thickening), and every cross-field channel is *exactly zero*
  (coprime flatness).  Instantiated on the `S₃ × D₄` pair (`S3_D4_simultaneous`) and on
  the `F₂₀ × A₄` pair (`F20_A4_simultaneous`).
* `coprimeDial_adds_nothing` — appending to an Artin dial `r` a residue `q` modulo a
  conductor coprime to the field (a dial independent of Frobenius) leaves the channel
  exactly at the coset law: `I((r, q) ; T) = I(coset ; T)`.  This is the "coprime
  flatness" control in its strongest form: coprime residues are not merely uninformative
  on their own, they add nothing on top of the informative dial.
-/

namespace TypeChannel

open Finset Real

set_option maxRecDepth 4000000

section Simultaneous

variable {Ω ρ α β γ δ : Type*} [DecidableEq Ω] [DecidableEq ρ] [DecidableEq α] [DecidableEq β]
  [DecidableEq γ] [DecidableEq δ]

/-- **Simultaneous measurement invariance.**  For two linearly disjoint fields with Galois
populations `S` and `R` (both nonempty), measured jointly on `S ×ˢ R`:
1. field A's channel is its own law;
2. field B's channel is its own law;
3. the cross channel (A's dial against B's type) is exactly zero;
4. so is the other cross channel. -/
theorem simultaneous_measurement_invariance {S : Finset Ω} {R : Finset ρ}
    (hS : S.Nonempty) (hR : R.Nonempty)
    (cA : Ω → α) (TA : Ω → β) (cB : ρ → γ) (TB : ρ → δ) :
    mutualInfo (S ×ˢ R) (fun w => cA w.1) (fun w => TA w.1) = mutualInfo S cA TA ∧
      mutualInfo (S ×ˢ R) (fun w => cB w.2) (fun w => TB w.2) = mutualInfo R cB TB ∧
      mutualInfo (S ×ˢ R) (fun w => cA w.1) (fun w => TB w.2) = 0 ∧
      mutualInfo (S ×ˢ R) (fun w => cB w.2) (fun w => TA w.1) = 0 := by
  refine ⟨mutualInfo_thicken hR cA TA, ?_, mutualInfo_prod_eq_zero S R cA TB, ?_⟩
  · have hswap : (R ×ˢ S).image Prod.swap = S ×ˢ R := Finset.image_swap_product S R
    have hinj : Set.InjOn (Prod.swap : ρ × Ω → Ω × ρ) (R ×ˢ S : Finset (ρ × Ω)) :=
      fun x _ y _ h => Prod.swap_injective h
    rw [← hswap, mutualInfo_image_of_injOn hinj]
    exact mutualInfo_thicken hS cB TB
  · rw [mutualInfo_comm]
    exact mutualInfo_prod_eq_zero S R TA cB

end Simultaneous

/-- **`S₃` and `D₄` measured together.**  In the joint population of `x³ + x + 1` and
`x⁴ − 2`, the two channels are `1` and `9/4 − (3/8) log₂ 3`, and neither field's residue
dial says anything about the other field's splitting. -/
theorem S3_D4_simultaneous :
    mutualInfo (S3 ×ˢ D4) (fun w => signIdx w.1) (fun w => splitType w.1) = 1 ∧
      mutualInfo (S3 ×ˢ D4) (fun w => d4Idx w.2) (fun w => splitType w.2) =
        9/4 - 3/8 * logb 2 3 ∧
      mutualInfo (S3 ×ˢ D4) (fun w => signIdx w.1) (fun w => splitType w.2) = 0 ∧
      mutualInfo (S3 ×ˢ D4) (fun w => d4Idx w.2) (fun w => splitType w.1) = 0 := by
  obtain ⟨h1, h2, h3, h4⟩ := simultaneous_measurement_invariance (S := S3) (R := D4)
    ⟨1, by decide⟩ ⟨1, by decide⟩ signIdx splitType d4Idx splitType
  exact ⟨h1.trans S3_channel, h2.trans D4_channel, h3, h4⟩

/-- **`F₂₀` and `A₄` measured together**: `3/2` and `log₂ 3 − 2/3`, with zero crosstalk. -/
theorem F20_A4_simultaneous :
    mutualInfo (F20 ×ˢ A4) (fun w => f20Idx w.1) (fun w => splitType w.1) = 3/2 ∧
      mutualInfo (F20 ×ˢ A4) (fun w => pairIdx w.2) (fun w => splitType w.2) =
        logb 2 3 - 2/3 ∧
      mutualInfo (F20 ×ˢ A4) (fun w => f20Idx w.1) (fun w => splitType w.2) = 0 ∧
      mutualInfo (F20 ×ˢ A4) (fun w => pairIdx w.2) (fun w => splitType w.1) = 0 := by
  obtain ⟨h1, h2, h3, h4⟩ := simultaneous_measurement_invariance (S := F20) (R := A4)
    ⟨1, F20_isSubgroup.one_mem⟩ ⟨1, by decide⟩ f20Idx splitType pairIdx splitType
  exact ⟨h1.trans F20_channel, h2.trans A4_channel, h3, h4⟩

section CoprimeDial

variable {Ω ρ θ κ τ : Type*} [DecidableEq Ω] [DecidableEq ρ] [DecidableEq θ] [DecidableEq κ]
  [DecidableEq τ] {S : Finset Ω} {R : Finset ρ} {c : Ω → κ} {φ : ρ → κ} {m : ℕ}

omit [DecidableEq Ω] [DecidableEq ρ] [DecidableEq θ] in
/-- Appending an independent residue `q ∈ Q` to a uniform Artin dial keeps it uniform. -/
lemma uniformDial_append {Q : Finset θ} (hQ : Q.Nonempty) (hd : UniformDial S R c φ m) :
    UniformDial S (R ×ˢ Q) c (fun x => φ x.1) (m * Q.card) := by
  refine ⟨Nat.mul_pos hd.1 (card_pos.mpr hQ), fun k hk => ?_⟩
  have : (R ×ˢ Q).filter (fun x => φ x.1 = k) = R.filter (fun r => φ r = k) ×ˢ Q := by
    ext x
    simp only [mem_filter, mem_product]
    tauto
  rw [this, card_product, hd.2 k hk]

/-- **Coprime residues add nothing.**  The combined dial `(r, q)` — an Artin residue `r`
together with a residue `q` modulo a coprime conductor — has exactly the coset law. -/
theorem coprimeDial_adds_nothing {Q : Finset θ} (hQ : Q.Nonempty) (hd : UniformDial S R c φ m)
    (T : Ω → τ) :
    mutualInfo (fibreProduct S (R ×ˢ Q) c (fun x => φ x.1)) (fun w => w.2) (fun w => T w.1) =
      mutualInfo S c T :=
  fineDial_reduction (uniformDial_append hQ hd) T

/-- The coprime-augmented dial and the bare Artin dial read the same channel. -/
theorem coprimeDial_eq_artinDial {Q : Finset θ} (hQ : Q.Nonempty) (hd : UniformDial S R c φ m)
    (T : Ω → τ) :
    mutualInfo (fibreProduct S (R ×ˢ Q) c (fun x => φ x.1)) (fun w => w.2) (fun w => T w.1) =
      mutualInfo (fibreProduct S R c φ) (fun w => w.2) (fun w => T w.1) := by
  rw [coprimeDial_adds_nothing hQ hd, fineDial_reduction hd]

end CoprimeDial

end TypeChannel