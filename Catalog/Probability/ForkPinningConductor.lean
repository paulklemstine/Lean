/-
# The conductor of a fork: equality in data processing detects the character's kernel

`ForkPinningDataProcessing` proves that no abelian character `f : G →* A` of the Galois group
can carry more information about a fork than the abelianization map `G → G^ab`, and that an
*injective* induced map `φ = Abelianization.lift f` loses nothing.  This file closes the
converse — conjecture **C8** of `FUTURE_DIRECTIONS.md` — and thereby characterises the
*conductor* of the abelian congruence data:

> a character `f` is as informative as the full abelianization **for every fork** exactly when
> `ker f = [G,G]`, i.e. exactly when `φ` is injective; otherwise there is an explicit fork
> (the indicator of a single commutator coset) on which `f` is *strictly* worse.

Main results:

* `ForkPinning.injective_lift_iff_ker_eq_commutator` : `φ` is injective iff the kernel of the
  character is exactly the commutator subgroup.
* `ForkPinning.exists_fork_lt_of_not_injective` : if `φ` is **not** injective there is a fork
  (a coset indicator) with `I(f ; Y) < I(G^ab ; Y)`; in fact `I(G^ab ; Y) = H Y`, so the loss
  is the whole of the fork's entropy.
* `ForkPinning.mutualInfo_eq_abelianization_forall_iff` : the two-sided criterion
  `(∀ Y, I(f ; Y) = I(G^ab ; Y)) ↔ Function.Injective φ`.
* `ForkPinning.sign_conductor_S3` : the sign character of `S₃` has kernel exactly the
  commutator subgroup, hence is a *minimal-conductor* observable: it already extracts all the
  abelian information of every fork of the `S₃` closure.  This is the exact formal counterpart
  of the measured statement "the congruence content of the `x³+x+1` fork is entirely the
  Jacobi sign".
-/

import Probability.ForkPinningDataProcessing

namespace ForkPinning

open Finset Real

/-- Every element of the abelianization is the class of a group element. -/
lemma exists_abelianization_of {G : Type*} [Group G] (x : Abelianization G) :
    ∃ g : G, Abelianization.of g = x := by
  induction x using QuotientGroup.induction_on with
  | H g => exact ⟨g, rfl⟩

section Conductor

variable {G : Type*} [Group G] [Fintype G] [Nonempty G] [DecidableEq G]
variable {A : Type*} [CommGroup A] [Fintype A] [DecidableEq A]
variable [Fintype (Abelianization G)] [DecidableEq (Abelianization G)]

omit [Fintype G] [Nonempty G] [DecidableEq G] [Fintype A] [DecidableEq A]
  [Fintype (Abelianization G)] [DecidableEq (Abelianization G)] in
/-- **The conductor condition.**  The map induced by a character on the abelianization is
injective exactly when the kernel of the character is the commutator subgroup. -/
theorem injective_lift_iff_ker_eq_commutator (f : G →* A) :
    Function.Injective (Abelianization.lift f) ↔ ∀ g : G, f g = 1 → g ∈ commutator G := by
  constructor
  · intro h g hg
    have hx : Abelianization.lift f (Abelianization.of g) = Abelianization.lift f 1 := by
      simpa using hg
    exact (QuotientGroup.eq_one_iff g).mp (h hx)
  · intro h
    rw [← MonoidHom.ker_eq_bot_iff, eq_bot_iff]
    intro x hx
    obtain ⟨g, rfl⟩ := exists_abelianization_of x
    have hg : f g = 1 := by
      simpa using hx
    rw [Subgroup.mem_bot]
    exact (QuotientGroup.eq_one_iff g).mpr (h g hg)

omit [DecidableEq G] in
/-- **Failure of injectivity is detected by a single coset fork.**  If the induced map on the
abelianization is not injective, the indicator fork of one of the merged commutator cosets is
fully pinned by the abelianization but only partially by the character. -/
theorem exists_fork_lt_of_not_injective (f : G →* A)
    (hinj : ¬ Function.Injective (Abelianization.lift f)) :
    ∃ Y : G → Bool,
      mutualInfo (fun g : G => Abelianization.of g) Y = H Y ∧
      mutualInfo (fun g : G => f g) Y < mutualInfo (fun g : G => Abelianization.of g) Y := by
  simp only [Function.Injective, not_forall] at hinj
  obtain ⟨a, b, hab, hne⟩ := hinj
  obtain ⟨ga, hga⟩ := exists_abelianization_of a
  obtain ⟨gb, hgb⟩ := exists_abelianization_of b
  refine ⟨fun g => decide (Abelianization.of g = a), ?_, ?_⟩
  · -- the abelianization determines the coset indicator, hence pins it completely
    refine (pinned_iff_determines _ _).mpr ?_
    intro w w' hw
    simp [hw]
  · -- but the character cannot distinguish the two merged cosets
    have hdet : ¬ Determines (fun g : G => f g) (fun g => decide (Abelianization.of g = a)) := by
      intro hdet
      have hfa : f ga = f gb := by
        have h1 : Abelianization.lift f (Abelianization.of ga) = f ga :=
          Abelianization.lift_apply_of f ga
        have h2 : Abelianization.lift f (Abelianization.of gb) = f gb :=
          Abelianization.lift_apply_of f gb
        rw [← h1, ← h2, hga, hgb, hab]
      have h := hdet ga gb hfa
      simp only [hga, hgb, decide_eq_decide] at h
      exact hne (h.mp trivial).symm
    have hpin : mutualInfo (fun g : G => Abelianization.of g)
        (fun g => decide (Abelianization.of g = a)) = H (fun g : G => decide
          (Abelianization.of g = a)) := by
      refine (pinned_iff_determines _ _).mpr ?_
      intro w w' hw
      simp [hw]
    rw [hpin]
    exact mutualInfo_lt_entropy_of_not_determines _ _ hdet

omit [DecidableEq G] in
/-- **C8, closed.**  A character is as informative as the whole abelianization on *every* fork
exactly when its kernel is the commutator subgroup: the minimal conductor of the abelian
congruence data is a well-defined quotient of `G^ab`. -/
theorem mutualInfo_eq_abelianization_forall_iff (f : G →* A) :
    (∀ Y : G → Bool,
        mutualInfo (fun g : G => f g) Y = mutualInfo (fun g : G => Abelianization.of g) Y)
      ↔ Function.Injective (Abelianization.lift f) := by
  constructor
  · intro hall
    by_contra hinj
    obtain ⟨Y, _, hlt⟩ := exists_fork_lt_of_not_injective f hinj
    exact absurd (hall Y) (ne_of_lt hlt)
  · intro hinj Y
    exact mutualInfo_eq_abelianization_of_injective f Y hinj

end Conductor

/-! ## The Jacobi sign is a minimal conductor for the `S₃` closure -/

/-- The sign character of `S₃` has kernel exactly the commutator subgroup `A₃`; consequently
(by `mutualInfo_eq_abelianization_forall_iff`) it extracts *all* of the abelian congruence
information of every fork of an `S₃` cubic — the measured identity
`I(p mod 31 ; fork) = I(sign ; fork)` is forced. -/
theorem sign_conductor_S3 :
    ∀ σ : Equiv.Perm (Fin 3), Equiv.Perm.sign σ = 1 → σ ∈ commutator (Equiv.Perm (Fin 3)) := by
  have hc : ⁅Equiv.swap (0 : Fin 3) 1, Equiv.swap (1 : Fin 3) 2⁆ ∈
      commutator (Equiv.Perm (Fin 3)) := by
    rw [commutator_def]
    exact Subgroup.commutator_mem_commutator (Subgroup.mem_top _) (Subgroup.mem_top _)
  have henum : ∀ σ : Equiv.Perm (Fin 3), Equiv.Perm.sign σ = 1 →
      σ = 1 ∨ σ = ⁅Equiv.swap (0 : Fin 3) 1, Equiv.swap (1 : Fin 3) 2⁆ ∨
        σ = ⁅Equiv.swap (0 : Fin 3) 1, Equiv.swap (1 : Fin 3) 2⁆ *
          ⁅Equiv.swap (0 : Fin 3) 1, Equiv.swap (1 : Fin 3) 2⁆ := by decide
  intro σ hσ
  rcases henum σ hσ with h | h | h
  · rw [h]; exact one_mem _
  · rw [h]; exact hc
  · rw [h]; exact mul_mem hc hc

end ForkPinning