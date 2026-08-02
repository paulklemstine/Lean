import Cryptography.ShamirSecretSharing

/-!
# Error-correcting reconstruction for Shamir shares

This file builds on the catalog's Shamir polynomial and reconstruction results.
It proves the uniqueness half of Reed–Solomon decoding: two degree-at-most-`d`
polynomials cannot both lie within `e` errors of the same received word at
`n ≥ d + 2e + 1` distinct evaluation locations.
-/

namespace ShamirErrorCorrection

open Polynomial

variable {F : Type*} [Field F]

/-- Locations where a polynomial disagrees with a received share vector. -/
def disagreementSet [DecidableEq F] (locations : Finset F) (received : F → F)
    (p : F[X]) : Finset F :=
  locations.filter fun x => p.eval x ≠ received x

/-- Outside the union of the two error sets, two candidate polynomials agree. -/
lemma agree_outside_disagreements [DecidableEq F]
    (locations : Finset F) (received : F → F) (p q : F[X])
    (x : F) (hx : x ∈ locations)
    (hxp : x ∉ disagreementSet locations received p)
    (hxq : x ∉ disagreementSet locations received q) :
    p.eval x = q.eval x := by
  have hp : p.eval x = received x := by
    simpa [disagreementSet, hx] using hxp
  have hq : q.eval x = received x := by
    simpa [disagreementSet, hx] using hxq
  exact hp.trans hq.symm

/-- **Unique error-correcting reconstruction.** If at least `d + 2e + 1`
distinct shares are supplied, there is at most one degree-at-most-`d`
polynomial disagreeing with at most `e` of them. In particular, its constant
coefficient (the Shamir secret) is uniquely determined. -/
theorem unique_reconstruction_with_errors [DecidableEq F]
    (locations : Finset F) (received : F → F) (d e : ℕ)
    (hsize : d + 2 * e + 1 ≤ locations.card)
    (p q : F[X])
    (hpdeg : p.degree ≤ (d : WithBot ℕ))
    (hqdeg : q.degree ≤ (d : WithBot ℕ))
    (hp_errors : (disagreementSet locations received p).card ≤ e)
    (hq_errors : (disagreementSet locations received q).card ≤ e) :
    p = q := by
  let bad : Finset F := disagreementSet locations received p ∪
    disagreementSet locations received q
  let good : Finset F := locations \ bad
  have hp_subset : disagreementSet locations received p ⊆ locations := by
    exact Finset.filter_subset _ _
  have hq_subset : disagreementSet locations received q ⊆ locations := by
    exact Finset.filter_subset _ _
  have hbad_subset : bad ⊆ locations := by
    intro x hx
    rcases Finset.mem_union.mp hx with hx | hx
    · exact hp_subset hx
    · exact hq_subset hx
  have hbad_card : bad.card ≤ 2 * e := by
    calc
      bad.card ≤ (disagreementSet locations received p).card +
          (disagreementSet locations received q).card :=
        Finset.card_union_le _ _
      _ ≤ e + e := Nat.add_le_add hp_errors hq_errors
      _ = 2 * e := by omega
  have hgood_card : good.card = locations.card - bad.card := by
    exact Finset.card_sdiff_of_subset hbad_subset
  have hdgood : d + 1 ≤ good.card := by
    rw [hgood_card]
    omega
  obtain ⟨enough, henough, henough_card⟩ :=
    Finset.exists_subset_card_eq hdgood
  apply ShamirSecretSharing.reconstruct_from_degree_plus_one enough d henough_card p q
      hpdeg hqdeg
  intro x hx
  have hxgood : x ∈ good := henough hx
  have hxloc : x ∈ locations := (Finset.mem_sdiff.mp hxgood).1
  have hxnotbad : x ∉ bad := (Finset.mem_sdiff.mp hxgood).2
  apply agree_outside_disagreements locations received p q x hxloc
  · intro hxp
    exact hxnotbad (Finset.mem_union_left _ hxp)
  · intro hxq
    exact hxnotbad (Finset.mem_union_right _ hxq)

/-- The same decoding theorem stated directly as uniqueness of the recovered
Shamir secret. -/
theorem secret_unique_with_errors [DecidableEq F]
    (locations : Finset F) (received : F → F) (d e : ℕ)
    (hsize : d + 2 * e + 1 ≤ locations.card)
    (p q : F[X])
    (hpdeg : p.degree ≤ (d : WithBot ℕ))
    (hqdeg : q.degree ≤ (d : WithBot ℕ))
    (hp_errors : (disagreementSet locations received p).card ≤ e)
    (hq_errors : (disagreementSet locations received q).card ≤ e) :
    p.eval 0 = q.eval 0 := by
  rw [unique_reconstruction_with_errors locations received d e hsize p q hpdeg hqdeg
    hp_errors hq_errors]

end ShamirErrorCorrection