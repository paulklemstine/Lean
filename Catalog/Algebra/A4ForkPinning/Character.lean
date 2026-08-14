/-
# Both sides of the cubic pinning are the same group `C₃`

The pinning statement "`Frob p ∈ V₄` ⟺ `p` is a cube mod `9`" is an identification
of two characters of order three:

* on the Galois side, the character of `A₄^ab = A₄/V₄`;
* on the arithmetic side, the cubic residue character of `(ℤ/9)ˣ` modulo cubes.

This file bundles both as honest group homomorphisms and shows that the two
groups involved are isomorphic — the shape of the Artin reciprocity square that
class field theory provides for the conductor-`9` cyclic cubic field.

* `A4ForkPinning.chiA4Hom` — the cubic character `A₄ →* C₃`, with
  `chiA4Hom_ker` (`ker = V₄`) and `chiA4Hom_surjective`;
* `A4ForkPinning.chi9Hom` — the cubic residue character `(ℤ/9)ˣ →* C₃`, with
  `chi9Hom_ker_eq_cubes` and `chi9Hom_surjective`;
* `A4ForkPinning.card_units_quotient_cubes` — `|(ℤ/9)ˣ / cubes| = 3`;
* `A4ForkPinning.artin_shape` — `A₄^ab ≃* (ℤ/9)ˣ / cubes`: the Galois side and the
  ray-class side of the pinning are the *same* cyclic group of order three.
-/
import Algebra.A4ForkPinning.GroupA4
import Algebra.A4ForkPinning.Resolvent

namespace A4ForkPinning

open Equiv Equiv.Perm Finset

/-! ## The Galois-side character -/

/-- The cubic character of `A₄`, bundled as a homomorphism to `C₃`. -/
def chiA4Hom : alternatingGroup (Fin 4) →* Multiplicative (ZMod 3) where
  toFun g := Multiplicative.ofAdd (chi (g : Equiv.Perm (Fin 4)))
  map_one' := by decide
  map_mul' g h := by
    have := chi_mul (g : Equiv.Perm (Fin 4)) (h : Equiv.Perm (Fin 4))
      (mem_alternatingGroup.1 g.2) (mem_alternatingGroup.1 h.2)
    simpa [Multiplicative.ofAdd] using congrArg Multiplicative.ofAdd this

/-- The kernel of the cubic character of `A₄` is exactly `V₄`. -/
theorem chiA4Hom_ker : chiA4Hom.ker = V4.subgroupOf (alternatingGroup (Fin 4)) := by
  ext g
  simp only [MonoidHom.mem_ker, chiA4Hom, MonoidHom.coe_mk, OneHom.coe_mk,
    Subgroup.mem_subgroupOf]
  rw [show (1 : Multiplicative (ZMod 3)) = Multiplicative.ofAdd (0 : ZMod 3) from rfl]
  constructor
  · intro h
    exact (chi_eq_zero_iff _).1 (Multiplicative.ofAdd.injective h)
  · intro h
    exact congrArg Multiplicative.ofAdd ((chi_eq_zero_iff _).2 h)

theorem chiA4Hom_surjective : Function.Surjective chiA4Hom := by
  intro t
  obtain ⟨σ, hσ, hval⟩ := chi_surjective (Multiplicative.toAdd t)
  exact ⟨⟨σ, mem_alternatingGroup.2 hσ⟩, by
    simp only [chiA4Hom, MonoidHom.coe_mk, OneHom.coe_mk]
    rw [hval]
    rfl⟩

/-! ## The arithmetic-side character -/

/-- The cubic residue character mod `9`, bundled as a homomorphism `(ℤ/9)ˣ →* C₃`. -/
def chi9Hom : (ZMod 9)ˣ →* Multiplicative (ZMod 3) where
  toFun u := Multiplicative.ofAdd (chi9 (u : ZMod 9))
  map_one' := by decide
  map_mul' u v := by
    have := chi9_mul (u : ZMod 9) (v : ZMod 9) u.isUnit v.isUnit
    simpa [Multiplicative.ofAdd] using congrArg Multiplicative.ofAdd this

/-- The subgroup of cubes in `(ℤ/9)ˣ`. -/
def cubes9 : Subgroup (ZMod 9)ˣ := MonoidHom.range (powMonoidHom 3)

theorem mem_cubes9 {x : (ZMod 9)ˣ} : x ∈ cubes9 ↔ ∃ y : (ZMod 9)ˣ, y ^ 3 = x := Iff.rfl

instance : DecidablePred (fun x : (ZMod 9)ˣ => x ∈ cubes9) :=
  fun _ => decidable_of_iff _ mem_cubes9.symm

/-- The kernel of the cubic residue character is the group of cubes. -/
theorem chi9Hom_ker_eq_cubes : chi9Hom.ker = cubes9 := by
  ext x
  simp only [MonoidHom.mem_ker, chi9Hom, MonoidHom.coe_mk, OneHom.coe_mk]
  rw [show (1 : Multiplicative (ZMod 3)) = Multiplicative.ofAdd (0 : ZMod 3) from rfl]
  constructor
  · intro h
    revert h; revert x; decide
  · intro h
    revert h; revert x; decide

theorem chi9Hom_surjective : Function.Surjective chi9Hom := by
  decide

theorem card_cubes9 : Nat.card cubes9 = 2 := by
  rw [Nat.card_eq_fintype_card, Fintype.card_subtype]
  decide

/-- `|(ℤ/9)ˣ / cubes| = 3`: the cubic residue symbol mod `9` has exactly three values. -/
theorem card_units_quotient_cubes : Nat.card ((ZMod 9)ˣ ⧸ cubes9) = 3 := by
  have hcard : Nat.card ((ZMod 9)ˣ) = 6 := by
    rw [Nat.card_eq_fintype_card]; exact card_units_mod_nine
  have h := Subgroup.card_mul_index cubes9
  rw [card_cubes9, hcard] at h
  have : cubes9.index = 3 := by omega
  simpa [Subgroup.index] using this

/-! ## Both sides agree -/

instance : IsCyclic (Abelianization (alternatingGroup (Fin 4))) :=
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  isCyclic_of_prime_card card_abelianization_alternating

instance : IsCyclic ((ZMod 9)ˣ ⧸ cubes9) :=
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  isCyclic_of_prime_card card_units_quotient_cubes

/-- **The shape of the Artin square.**  The abelianisation of the Galois group `A₄`
and the ray-class-type group `(ℤ/9)ˣ / cubes` are isomorphic: both are `C₃`.  This
is the group-theoretic content of "the `V₄`-fork is pinned by the cubic character
mod `9`". -/
noncomputable def artin_shape :
    Abelianization (alternatingGroup (Fin 4)) ≃* ((ZMod 9)ˣ ⧸ cubes9) :=
  mulEquivOfCyclicCardEq
    (card_abelianization_alternating.trans card_units_quotient_cubes.symm)

end A4ForkPinning