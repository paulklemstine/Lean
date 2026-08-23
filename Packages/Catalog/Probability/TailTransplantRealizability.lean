import Probability.TailTransplantGeometry

/-!
# The NET-54 agreement profile is exactly realizable, and the certificate is not vacuous

A referee's first question about the NET-54 table is whether the four measured
numbers are jointly realizable at all, and — if they are — whether the
both-parents-collapse certificate of `Probability.TailTransplantGeometry` is
saying anything beyond arithmetic.  This file answers both.

We build an explicit five-class index set of `10000` positions,

| class | size | parents | hybrid |
|---|---|---|---|
| 0 | 5000 | `A = B` | follows both |
| 1 | 3327 | `A = B` | **novel** |
| 2 | 845 | `A ≠ B` | follows `A` |
| 3 | 443 | `A ≠ B` | follows `B` |
| 4 | 385 | `A ≠ B` | **novel** |

and prove that the resulting three prediction functions reproduce the measured
tail-swap profile *on the nose*:

`agr A B = 0.8327`, `agr H A = 0.5845`, `agr H B = 0.5443`,

with novelty `0.3712`.  So the measurement is consistent
(`net54_profile_realized_*`), the certificate's prediction `≥ 0.2884` holds with
room to spare, and — since `0.3712 > 0.2884 > 0` — the certificate is
non-vacuous on the realized profile (`net54_realized_beats_certificate`).
-/

namespace Catalog.Probability.TailTransplantRealizability

open Finset
open Catalog.Probability.TailTransplantGeometry

/-- The five class sizes of the realization. -/
def classSize : Fin 5 → ℕ := ![5000, 3327, 845, 443, 385]

/-- The index set: `10000` held-out positions split into five behavioural
classes. -/
abbrev Idx : Type := Σ i : Fin 5, Fin (classSize i)

/-- Counting a class-determined event. -/
lemma card_class_filter (P : Fin 5 → Prop) [DecidablePred P] :
    ((Finset.univ.filter (fun x : Idx => P x.1)).card)
      = ∑ i, (if P i then classSize i else 0) := by
  rw [Finset.card_filter, ← Finset.univ_sigma_univ, Finset.sum_sigma]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  by_cases h : P i <;> simp [h]

lemma card_Idx : Fintype.card Idx = 10000 := by
  rw [Fintype.card_sigma]
  simp [classSize, Fin.sum_univ_five]

/-- Parent `A` (the host): a constant baseline behaviour. -/
def parentA : Idx → Fin 3 := fun _ => 0

/-- Parent `B` (the donor): differs from `A` exactly on classes 2, 3, 4. -/
def parentB : Idx → Fin 3 := fun x => ![0, 0, 1, 1, 1] x.1

/-- The hybrid: follows both parents on class 0, is novel on classes 1 and 4,
follows `A` on class 2 and `B` on class 3. -/
def hybrid : Idx → Fin 3 := fun x => ![0, 1, 0, 1, 2] x.1

lemma card_agree_AB : (agreeSet parentA parentB).card = 8327 := by
  have h : agreeSet parentA parentB
      = Finset.univ.filter (fun x : Idx => (![0, 0, 1, 1, 1] : Fin 5 → Fin 3) x.1 = 0) := by
    ext x
    simp [agreeSet, parentA, parentB, eq_comm]
  rw [h, card_class_filter (P := fun i => (![0, 0, 1, 1, 1] : Fin 5 → Fin 3) i = 0)]
  decide

lemma card_agree_HA : (agreeSet hybrid parentA).card = 5845 := by
  have h : agreeSet hybrid parentA
      = Finset.univ.filter (fun x : Idx => (![0, 1, 0, 1, 2] : Fin 5 → Fin 3) x.1 = 0) := by
    ext x
    simp [agreeSet, parentA, hybrid]
  rw [h, card_class_filter (P := fun i => (![0, 1, 0, 1, 2] : Fin 5 → Fin 3) i = 0)]
  decide

lemma card_agree_HB : (agreeSet hybrid parentB).card = 5443 := by
  have h : agreeSet hybrid parentB
      = Finset.univ.filter (fun x : Idx =>
          (![0, 1, 0, 1, 2] : Fin 5 → Fin 3) x.1 = (![0, 0, 1, 1, 1] : Fin 5 → Fin 3) x.1) := by
    ext x
    simp [agreeSet, parentB, hybrid]
  rw [h, card_class_filter (P := fun i => (![0, 1, 0, 1, 2] : Fin 5 → Fin 3) i
      = (![0, 0, 1, 1, 1] : Fin 5 → Fin 3) i)]
  decide

lemma card_novel : (novelSet hybrid parentA parentB).card = 3712 := by
  have h : novelSet hybrid parentA parentB
      = Finset.univ.filter (fun x : Idx =>
          (![0, 1, 0, 1, 2] : Fin 5 → Fin 3) x.1 ≠ 0 ∧
          (![0, 1, 0, 1, 2] : Fin 5 → Fin 3) x.1
            ≠ (![0, 0, 1, 1, 1] : Fin 5 → Fin 3) x.1) := by
    ext x
    simp [novelSet, parentA, parentB, hybrid]
  rw [h, card_class_filter (P := fun i => (![0, 1, 0, 1, 2] : Fin 5 → Fin 3) i ≠ 0 ∧
      (![0, 1, 0, 1, 2] : Fin 5 → Fin 3) i ≠ (![0, 0, 1, 1, 1] : Fin 5 → Fin 3) i)]
  decide

/-- The cross-parent baseline is realized exactly. -/
theorem net54_profile_realized_baseline : agreeFrac parentA parentB = 0.8327 := by
  rw [agreeFrac, card_agree_AB, card_Idx]
  norm_num

/-- The hybrid's host-side agreement is realized exactly. -/
theorem net54_profile_realized_host : agreeFrac hybrid parentA = 0.5845 := by
  rw [agreeFrac, card_agree_HA, card_Idx]
  norm_num

/-- The hybrid's donor-side agreement is realized exactly. -/
theorem net54_profile_realized_donor : agreeFrac hybrid parentB = 0.5443 := by
  rw [agreeFrac, card_agree_HB, card_Idx]
  norm_num

/-- The realized novelty. -/
theorem net54_profile_realized_novelty : novelFrac hybrid parentA parentB = 0.3712 := by
  rw [novelFrac, card_novel, card_Idx]
  norm_num

/-- **The measured profile is consistent, and the certificate is non-vacuous on
it.**  The realization satisfies the measured agreements exactly; the
both-parents-collapse certificate predicts at least `0.2884` novelty, and the
realization delivers `0.3712` — a strictly positive amount of behaviour that
belongs to neither parent, and strictly more than the certificate's floor. -/
theorem net54_realized_beats_certificate :
    agreeFrac parentA parentB
        - min (agreeFrac hybrid parentA) (agreeFrac hybrid parentB)
      ≤ novelFrac hybrid parentA parentB ∧
    (0.2884 : ℝ) ≤ novelFrac hybrid parentA parentB ∧
    novelFrac hybrid parentA parentB ≠
      agreeFrac parentA parentB
        - min (agreeFrac hybrid parentA) (agreeFrac hybrid parentB) := by
  refine ⟨novelFrac_ge_baseline_sub_agree _ _ _, ?_, ?_⟩
  · rw [net54_profile_realized_novelty]; norm_num
  · rw [net54_profile_realized_novelty, net54_profile_realized_baseline,
      net54_profile_realized_host, net54_profile_realized_donor]
    norm_num

end Catalog.Probability.TailTransplantRealizability