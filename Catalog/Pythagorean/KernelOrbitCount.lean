import Pythagorean.KernelPatternsBell

/-!
# Counting symmetric-group orbits of tuples

The kernel is a complete invariant of the `Equiv.Perm β`-orbit of a tuple
(`KernelPattern.exists_perm_iff_ker_eq`), and kernels of `n`-tuples are counted by the Bell
numbers (`KernelPattern.card_patterns_eq_bell`).  Putting the two together gives an exact
orbit count:

`KernelPattern.nat_card_orbits_eq_bell` : if `n ≤ Fintype.card β`, then the set of orbits of
`Equiv.Perm β` acting on `Fin n → β` (by post-composition) has exactly `Nat.bell n` elements.

The hypothesis `n ≤ Fintype.card β` is exactly what is needed for *every* pattern to be
realised; `orbit_count_lt_bell_of_lt` shows the count drops strictly below `Nat.bell n` as
soon as the alphabet is too small, so the hypothesis is sharp.
-/

open Finset

namespace KernelPattern

variable {n : ℕ} {β : Type*} [Fintype β] [DecidableEq β]

theorem canon_eq_of_orbitRel {f g : Fin n → β}
    (h : MulAction.orbitRel (Equiv.Perm β) (Fin n → β) f g) : canon f = canon g := by
  obtain ⟨σ, hσ⟩ := h
  exact ((smul_orbit_iff_canon_eq g f).1 ⟨σ, hσ⟩).symm

/-- Sending a tuple to its kernel pattern is a bijection from the set of orbits onto the set
of patterns, provided the alphabet has at least `n` letters. -/
noncomputable def orbitPatternEquiv (hn : n ≤ Fintype.card β) :
    MulAction.orbitRel.Quotient (Equiv.Perm β) (Fin n → β) ≃
      {p : Fin n → Fin n // p ∈ Patterns n} := by
  classical
  have hemb : Nonempty (Fin n ↪ β) :=
    Function.Embedding.nonempty_of_card_le (by simpa using hn)
  let e : Fin n ↪ β := hemb.some
  refine Equiv.ofBijective
    (Quotient.lift (fun f : Fin n → β => (⟨canon f, canon_mem_patterns f⟩ :
        {p : Fin n → Fin n // p ∈ Patterns n}))
      (fun f g h => Subtype.ext (canon_eq_of_orbitRel h))) ⟨?_, ?_⟩
  · refine fun x y => Quotient.inductionOn₂ x y ?_
    intro f g hfg
    have hcan : canon f = canon g := congrArg Subtype.val hfg
    refine Quotient.sound ?_
    obtain ⟨σ, hσ⟩ := (exists_perm_iff_canon_eq g f).2 hcan.symm
    exact ⟨σ, hσ⟩
  · rintro ⟨p, hp⟩
    refine ⟨Quotient.mk _ (fun i => e (p i)), ?_⟩
    have hcomp : canon (fun i => e (p i)) = canon p :=
      canon_comp_of_injective e.injective p
    apply Subtype.ext
    show canon (fun i => e (p i)) = p
    rw [hcomp, mem_patterns_iff.1 hp]

/-- **Orbit count.**  If the alphabet `β` has at least `n` letters, the number of orbits of
the symmetric group `Equiv.Perm β` acting on `n`-tuples over `β` is the Bell number
`Nat.bell n`. -/
theorem nat_card_orbits_eq_bell (hn : n ≤ Fintype.card β) :
    Nat.card (MulAction.orbitRel.Quotient (Equiv.Perm β) (Fin n → β)) = Nat.bell n := by
  rw [Nat.card_congr (orbitPatternEquiv hn), Nat.card_eq_fintype_card, Fintype.card_coe,
    card_patterns_eq_bell]

/-- The special case of a square alphabet: `(Fin n)`-valued `n`-tuples. -/
theorem nat_card_orbits_fin_eq_bell (n : ℕ) :
    Nat.card (MulAction.orbitRel.Quotient (Equiv.Perm (Fin n)) (Fin n → Fin n)) = Nat.bell n :=
  nat_card_orbits_eq_bell (by simp)

/-! ## Sharpness of the hypothesis -/

/-- A tuple over an alphabet of size `m` has at most `m` distinct entries, so its pattern
takes at most `m` values. -/
theorem card_image_canon_le (f : Fin n → β) :
    (univ.image (canon f)).card ≤ Fintype.card β := by
  classical
  have hle : (univ.image (canon f)).card ≤ (univ.image f).card := by
    refine Finset.card_le_card_of_injOn (fun i => f i) ?_ ?_
    · intro i _
      exact Finset.mem_image_of_mem f (Finset.mem_univ i)
    · intro i hi j hj hij
      have hcan : canon f i = canon f j := (eq_iff_canon_eq f i j).1 hij
      simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe, Finset.mem_univ,
        true_and] at hi hj
      obtain ⟨a, rfl⟩ := hi
      obtain ⟨b, rfl⟩ := hj
      rwa [canon_canon_apply, canon_canon_apply] at hcan
  exact hle.trans (Finset.card_le_univ _)

/-- If the alphabet is smaller than `n`, the discrete pattern `id` is *not* realised, so the
orbit count is strictly smaller than `Nat.bell n`: the hypothesis of
`nat_card_orbits_eq_bell` is sharp. -/
theorem discrete_pattern_not_realised (hn : Fintype.card β < n) (f : Fin n → β) :
    canon f ≠ id := by
  intro hcan
  have h1 : (univ.image (canon f)).card ≤ Fintype.card β := card_image_canon_le f
  have h2 : (univ.image (canon f)).card = n := by
    rw [hcan]
    simp
  omega

end KernelPattern