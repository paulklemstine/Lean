/-
# Perfect Galois groups: total congruence blindness

The fork-pinning criterion has an extreme end.  If the Galois group of the closure is **perfect**
(`G = [G,G]`, e.g. `A₅`), then it has no non-trivial abelian character at all, so *no* fork of the
corresponding field carries a single bit of congruence information — the splitting behaviour is
completely invisible to Dirichlet characters.

* `ForkPinning.hom_trivial_of_commutator_top` — a perfect group has only the trivial character.
* `ForkPinning.perfect_all_flat` — every fork is flat for every abelian character.
* `ForkPinning.perfect_pinned_imp_entropy_zero` — a pinned fork must have zero entropy.
* `ForkPinning.commutator_alternating_five_top` / `ForkPinning.A5_all_forks_flat` — the
  instantiation to `A₅`, the Galois group of a generic quintic with square discriminant.
-/

import Probability.ForkPinningCore

namespace ForkPinning

open Finset Real

section Perfect

variable {G : Type*} [Group G] [Fintype G] [Nonempty G]
variable {A β : Type*} [CommGroup A] [Fintype A] [DecidableEq A] [Fintype β] [DecidableEq β]

omit [Fintype G] [Nonempty G] [Fintype A] [DecidableEq A] [Fintype β] [DecidableEq β] in
/-- A perfect group has no non-trivial abelian character. -/
theorem hom_trivial_of_commutator_top (hG : commutator G = ⊤) (f : G →* A) (g : G) : f g = 1 := by
  have hmem : g ∈ commutator G := by rw [hG]; exact Subgroup.mem_top g
  simpa using Abelianization.commutator_subset_ker f hmem

/-- **Perfect closure ⇒ total flatness.**  If the Galois group is perfect, every fork is
independent of every abelian character: no congruence condition sees the splitting at all. -/
theorem perfect_all_flat (hG : commutator G = ⊤) (f : G →* A) (Y : G → β) :
    mutualInfo (fun g => f g) Y = 0 := by
  have hconst : (fun g => f g) = fun _ => (1 : A) :=
    funext (fun g => hom_trivial_of_commutator_top hG f g)
  rw [hconst]
  exact mutualInfo_const_left 1 Y

/-- In a perfect group only entropy-free forks can be pinned. -/
theorem perfect_pinned_imp_entropy_zero (hG : commutator G = ⊤) (f : G →* A) (Y : G → β)
    (hpin : mutualInfo (fun g => f g) Y = H Y) : H Y = 0 := by
  rw [← hpin, perfect_all_flat hG f Y]

end Perfect

/-! ## The instantiation: `A₅` -/

/-- `A₅` is perfect: being simple and non-abelian, its commutator subgroup is everything. -/
theorem commutator_alternating_five_top : commutator (alternatingGroup (Fin 5)) = ⊤ := by
  rcases IsSimpleGroup.eq_bot_or_eq_top_of_normal (commutator (alternatingGroup (Fin 5)))
      inferInstance with hb | ht
  · exfalso
    have hcomm : ∀ a b : alternatingGroup (Fin 5), a * b = b * a := by
      intro a b
      have hmem : ⁅a, b⁆ ∈ commutator (alternatingGroup (Fin 5)) := by
        rw [commutator_def]
        exact Subgroup.commutator_mem_commutator (Subgroup.mem_top _) (Subgroup.mem_top _)
      rw [hb, Subgroup.mem_bot, commutatorElement_def, mul_inv_eq_one] at hmem
      calc a * b = (a * b * a⁻¹) * a := by group
        _ = b * a := by rw [hmem]
    have ha : Equiv.swap (0 : Fin 5) 1 * Equiv.swap (1 : Fin 5) 2 ∈ alternatingGroup (Fin 5) := by
      rw [Equiv.Perm.mem_alternatingGroup]; decide
    have hb2 : Equiv.swap (2 : Fin 5) 3 * Equiv.swap (3 : Fin 5) 4 ∈ alternatingGroup (Fin 5) := by
      rw [Equiv.Perm.mem_alternatingGroup]; decide
    have hkey := hcomm ⟨_, ha⟩ ⟨_, hb2⟩
    rw [Subtype.ext_iff] at hkey
    simp only [Subgroup.coe_mul] at hkey
    have hne : (Equiv.swap (0 : Fin 5) 1 * Equiv.swap (1 : Fin 5) 2) *
        (Equiv.swap (2 : Fin 5) 3 * Equiv.swap (3 : Fin 5) 4)
        ≠ (Equiv.swap (2 : Fin 5) 3 * Equiv.swap (3 : Fin 5) 4) *
          (Equiv.swap (0 : Fin 5) 1 * Equiv.swap (1 : Fin 5) 2) := by decide
    exact hne hkey
  · exact ht

/-- **A quintic with `A₅` closure is completely congruence-blind**: every fork is flat for every
Dirichlet character. -/
theorem A5_all_forks_flat {A β : Type*} [CommGroup A] [Fintype A] [DecidableEq A]
    [Fintype β] [DecidableEq β] (f : alternatingGroup (Fin 5) →* A)
    (Y : alternatingGroup (Fin 5) → β) :
    mutualInfo (fun g => f g) Y = 0 :=
  perfect_all_flat commutator_alternating_five_top f Y

end ForkPinning