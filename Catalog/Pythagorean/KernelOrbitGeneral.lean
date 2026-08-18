import Pythagorean.KernelOrbitCount
import Pythagorean.KernelFibreCount

/-!
# Orbit counting over an arbitrary alphabet

`KernelPattern.nat_card_orbits_eq_bell` counts the orbits of `Equiv.Perm β` on `Fin n → β`
when the alphabet is large (`n ≤ card β`): there are `Nat.bell n` of them.  Here we remove
that hypothesis.  A pattern is realised by a tuple over `β` exactly when it has at most
`card β` blocks (`KernelPattern.exists_canon_eq` for the hard direction), so the orbit count
is the truncated row sum of the Stirling triangle:

`KernelPattern.nat_card_orbits_eq_sum_stirling2`:
`Nat.card (orbits of Equiv.Perm β on Fin n → β) = ∑_{k ≤ card β} S(n,k)`.

For `n ≤ card β` this recovers the Bell number, and for `card β < n` it is strictly smaller
(`KernelPattern.nat_card_orbits_lt_bell`), quantifying the failure of surjectivity of the
pattern map.
-/

open Finset

namespace KernelPattern

variable {n : ℕ} {β : Type*} [Fintype β] [DecidableEq β]

/-- The patterns realised over an alphabet of size `m`: those with at most `m` blocks. -/
def PatternsLe (n m : ℕ) : Finset (Fin n → Fin n) :=
  (Patterns n).filter (fun p => nblocks p ≤ m)

theorem mem_patternsLe {n m : ℕ} {p : Fin n → Fin n} :
    p ∈ PatternsLe n m ↔ p ∈ Patterns n ∧ nblocks p ≤ m := Finset.mem_filter

/-- The realised patterns are counted by a truncated row of the Stirling triangle. -/
theorem card_patternsLe (n m : ℕ) :
    (PatternsLe n m).card = ∑ k ∈ range (m + 1), stirling2 n k := by
  classical
  rw [Finset.card_eq_sum_card_fiberwise
    (f := fun p : Fin n → Fin n => nblocks p) (t := range (m + 1))
    (fun p hp => Finset.mem_range.2 (Nat.lt_succ_of_le (mem_patternsLe.1 hp).2))]
  refine Finset.sum_congr rfl fun k hk => ?_
  have hk' : k ≤ m := Nat.lt_succ_iff.1 (Finset.mem_range.1 hk)
  congr 1
  ext p
  simp only [PatternsLe, Finset.mem_filter]
  constructor
  · rintro ⟨⟨hp, -⟩, hnk⟩
    exact ⟨hp, hnk⟩
  · rintro ⟨hp, hnk⟩
    exact ⟨⟨hp, hnk ▸ hk'⟩, hnk⟩

/-- Sending a tuple to its kernel pattern is a bijection from the set of orbits onto the set
of patterns with at most `card β` blocks. -/
noncomputable def orbitPatternLeEquiv (n : ℕ) (β : Type*) [Fintype β] [DecidableEq β] :
    MulAction.orbitRel.Quotient (Equiv.Perm β) (Fin n → β) ≃
      {p : Fin n → Fin n // p ∈ PatternsLe n (Fintype.card β)} := by
  classical
  refine Equiv.ofBijective
    (Quotient.lift (fun f : Fin n → β =>
        (⟨canon f, mem_patternsLe.2 ⟨canon_mem_patterns f, by
          simpa [nblocks] using card_image_canon_le f⟩⟩ :
        {p : Fin n → Fin n // p ∈ PatternsLe n (Fintype.card β)}))
      (fun f g h => Subtype.ext (canon_eq_of_orbitRel h))) ⟨?_, ?_⟩
  · refine fun x y => Quotient.inductionOn₂ x y ?_
    intro f g hfg
    have hcan : canon f = canon g := congrArg Subtype.val hfg
    refine Quotient.sound ?_
    obtain ⟨σ, hσ⟩ := (exists_perm_iff_canon_eq g f).2 hcan.symm
    exact ⟨σ, hσ⟩
  · rintro ⟨p, hp⟩
    obtain ⟨hpat, hle⟩ := mem_patternsLe.1 hp
    obtain ⟨f, hf⟩ := exists_canon_eq (β := β) hpat hle
    exact ⟨Quotient.mk _ f, Subtype.ext hf⟩

/-- **Orbit count over an arbitrary alphabet.** -/
theorem nat_card_orbits_eq_sum_stirling2 (n : ℕ) (β : Type*) [Fintype β] [DecidableEq β] :
    Nat.card (MulAction.orbitRel.Quotient (Equiv.Perm β) (Fin n → β))
      = ∑ k ∈ range (Fintype.card β + 1), stirling2 n k := by
  rw [Nat.card_congr (orbitPatternLeEquiv n β), Nat.card_eq_fintype_card, Fintype.card_coe,
    card_patternsLe]

/-- Consistency with the large-alphabet count: for `n ≤ card β` the truncated sum is the full
row, i.e. the Bell number. -/
theorem sum_stirling2_truncated_eq_bell {m : ℕ} (hn : n ≤ m) :
    ∑ k ∈ range (m + 1), stirling2 n k = Nat.bell n := by
  rw [← sum_stirling2_eq_bell n]
  refine (Finset.sum_subset (s₁ := range (n + 1)) (s₂ := range (m + 1))
    (fun x hx => by simp only [Finset.mem_range] at hx ⊢; omega) ?_).symm
  intro k _ hk
  rw [Finset.mem_range, Nat.lt_succ_iff, not_le] at hk
  exact stirling2_eq_zero_of_lt hk

/-- When the alphabet is too small the orbit count is strictly below `Nat.bell n`: the
missing orbits are exactly the patterns with more than `card β` blocks. -/
theorem nat_card_orbits_lt_bell (hβ : Fintype.card β < n) :
    Nat.card (MulAction.orbitRel.Quotient (Equiv.Perm β) (Fin n → β)) < Nat.bell n := by
  rw [nat_card_orbits_eq_sum_stirling2 n β, ← sum_stirling2_eq_bell n]
  refine Finset.sum_lt_sum_of_subset (by
      simpa using Nat.succ_le_succ hβ.le) (i := n) (by simp) (by simp [hβ]) ?_ (by
      intro j _ _
      exact Nat.zero_le _)
  rw [stirling2_self]
  exact Nat.one_pos

end KernelPattern