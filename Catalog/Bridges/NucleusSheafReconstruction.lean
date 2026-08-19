/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic
-/
import Mathlib

/-!
# Nucleus-Sheaf Reconstruction for Coherent Idempotent Semirings

This file builds a concrete sheaf-of-local-quotients model over the nucleus spectrum
of a coherent commutative idempotent semiring and proves:

1. **Global-sections reconstruction** — elements of the semiring are determined by their
   evaluations at all nucleus points (prime congruences).
2. **Binary gluing / patching** — compatible local sections over two compact opens
   can be glued to a section over their union.
3. **Local-to-global elimination** — equality in the semiring is equivalent to
   pointwise equality at all nucleus points.

## Mathematical overview

An **idempotent commutative semiring** is a commutative semiring where `a + a = a`.
A **nucleus point** on `S` is a prime ring congruence: `θ(a·b, 0) → θ(a,0) ∨ θ(b,0)`.

For each set `U` of nucleus points, the **section congruence** `sectionCongr S U` is
defined by `a ~ b ↔ ∀ x ∈ U, x.con a b`. The **local quotient**
`LocalQuotient S U = S / sectionCongr S U` represents "local sections over U".

The main reconstruction theorem says that under prime separation, two elements are equal
iff they agree at all nucleus points.

## Main results

* `congruence_eq_iff_locally` — `a = b ↔ ∀ x, evalAt x a = evalAt x b`
* `toGlobalSections_injective_of_prime_separation` — injectivity of global sections
* `sections_glue_binary` — binary gluing of compatible local sections
* `sectionCongr_mono` — monotonicity of section congruences
* `restrict_id`, `restrict_comp` — presheaf laws
* `globalSectionsIso` — the reconstruction isomorphism
-/

set_option maxHeartbeats 800000

universe u

namespace NucleusSheafReconstruction

/-! ## 1. Core Algebraic Structures -/

/-- A **coherent idempotent commutative semiring**: a commutative semiring where addition
is idempotent (`a + a = a`). This makes `(S, +)` a join-semilattice. -/
class CoherentIdemCommSemiring (S : Type u) extends CommSemiring S where
  idem_add : ∀ a : S, a + a = a

/-- A **nucleus point** on a commutative semiring `S` is a ring congruence that is
prime: if the product `a * b` is congruent to `0`, then `a` or `b` is congruent to `0`. -/
structure NucleusPoint (S : Type u) [CommSemiring S] where
  /-- The underlying ring congruence. -/
  con : RingCon S
  /-- Primality: `θ(a·b, 0) → θ(a, 0) ∨ θ(b, 0)`. -/
  prime : ∀ a b : S, con (a * b) 0 → con a 0 ∨ con b 0

variable {S : Type u} [CommSemiring S]

/-- Evaluate an element of `S` at a nucleus point, obtaining its equivalence class
in the quotient by that point's congruence. -/
noncomputable def evalAt (x : NucleusPoint S) (a : S) : x.con.Quotient :=
  x.con.toQuotient a

@[simp]
theorem evalAt_def (x : NucleusPoint S) (a : S) :
    evalAt x a = x.con.toQuotient a := rfl

/-- Two elements have equal evaluations at a point iff they are congruent at that point. -/
theorem evalAt_eq_iff (x : NucleusPoint S) (a b : S) :
    evalAt x a = evalAt x b ↔ x.con a b := by
  simp [evalAt, RingCon.eq]

/-! ## 2. Section Congruences and Local Quotients -/

/-- The **section congruence** attached to a set `U` of nucleus points.
Two elements are related iff they are congruent at every point in `U`.
This is the algebraic incarnation of "agreement on all stalks in `U`". -/
noncomputable def sectionCongr (S : Type u) [CommSemiring S]
    (U : Set (NucleusPoint S)) : RingCon S where
  r a b := ∀ x ∈ U, x.con a b
  iseqv := {
    refl := fun a x _ => x.con.refl a
    symm := fun h x hx => x.con.symm (h x hx)
    trans := fun h1 h2 x hx => x.con.trans (h1 x hx) (h2 x hx)
  }
  add' := fun h1 h2 x hx => x.con.add (h1 x hx) (h2 x hx)
  mul' := fun h1 h2 x hx => x.con.mul (h1 x hx) (h2 x hx)

/-- Characterization of the section congruence. -/
theorem sectionCongr_iff {U : Set (NucleusPoint S)} {a b : S} :
    sectionCongr S U a b ↔ ∀ x ∈ U, x.con a b :=
  Iff.rfl

/-- The section congruence is antitone: larger sets of points give finer congruences. -/
theorem sectionCongr_mono {U V : Set (NucleusPoint S)} (h : V ⊆ U) :
    sectionCongr S U ≤ sectionCongr S V :=
  fun _ _ hab => fun x hx => hab x (h hx)

/-- The section congruence on the empty set identifies everything. -/
theorem sectionCongr_empty (a b : S) :
    sectionCongr S (∅ : Set (NucleusPoint S)) a b := by
  intro x hx; simp at hx

/-- The **local quotient** of `S` at a set `U` of nucleus points. -/
def LocalQuotient (S : Type u) [CommSemiring S] (U : Set (NucleusPoint S)) : Type u :=
  (sectionCongr S U).Quotient

noncomputable instance instCommSemiringLocalQuotient (U : Set (NucleusPoint S)) :
    CommSemiring (LocalQuotient S U) :=
  inferInstanceAs (CommSemiring (sectionCongr S U).Quotient)

/-- The canonical projection from `S` to the local quotient on `U`. -/
noncomputable def toLocalQuotient (U : Set (NucleusPoint S)) :
    S →+* LocalQuotient S U :=
  (sectionCongr S U).mk'

/-- Two elements have the same local quotient image iff they agree at all points in `U`. -/
theorem toLocalQuotient_eq_iff {U : Set (NucleusPoint S)} {a b : S} :
    toLocalQuotient U a = toLocalQuotient U b ↔ ∀ x ∈ U, x.con a b := by
  show (sectionCongr S U).toQuotient a = (sectionCongr S U).toQuotient b ↔ _
  rw [RingCon.eq]
  exact sectionCongr_iff

/-- Every element of the local quotient has a representative. -/
theorem LocalQuotient.exists_rep {U : Set (NucleusPoint S)} (q : LocalQuotient S U) :
    ∃ a : S, toLocalQuotient U a = q := ⟨q.out, Quotient.out_eq q⟩

/-! ## 3. Restriction Maps -/

/-- The **restriction map** from the local quotient on `U` to the local quotient on `V`,
defined when `V ⊆ U`. -/
noncomputable def LocalQuotient.restrict
    {U V : Set (NucleusPoint S)} (h : V ⊆ U) :
    LocalQuotient S U →+* LocalQuotient S V :=
  (sectionCongr S U).lift (toLocalQuotient V) (fun _ _ hab =>
    (sectionCongr S V).eq.mpr (sectionCongr_mono h hab))

@[simp]
theorem restrict_toLocalQuotient {U V : Set (NucleusPoint S)} (h : V ⊆ U) (a : S) :
    LocalQuotient.restrict h (toLocalQuotient U a) = toLocalQuotient V a :=
  rfl

/-- Restriction along the identity inclusion is the identity. -/
theorem restrict_id (U : Set (NucleusPoint S)) :
    LocalQuotient.restrict (Set.Subset.refl U) = RingHom.id (LocalQuotient S U) := by
  ext ⟨⟩; rfl

/-- Restriction is functorial. -/
theorem restrict_comp {U V W : Set (NucleusPoint S)}
    (hUV : V ⊆ U) (hVW : W ⊆ V) :
    (LocalQuotient.restrict hVW).comp (LocalQuotient.restrict hUV) =
      LocalQuotient.restrict (Set.Subset.trans hVW hUV) := by
  ext ⟨⟩; rfl

/-! ## 4. Global Sections and Reconstruction -/

/-- The **global section map**: `S →+* LocalQuotient S Set.univ`. -/
noncomputable def toGlobalSections :
    S →+* LocalQuotient S (Set.univ : Set (NucleusPoint S)) :=
  toLocalQuotient Set.univ

/-- **Prime separation**: any two distinct elements are distinguished by some nucleus point. -/
def PrimeSeparation (S : Type u) [CommSemiring S] : Prop :=
  ∀ {a b : S}, a ≠ b → ∃ x : NucleusPoint S, ¬ x.con a b

/-- **Injectivity of global sections under prime separation**. -/
theorem toGlobalSections_injective_of_prime_separation
    (hsep : PrimeSeparation S) :
    Function.Injective (toGlobalSections (S := S)) := by
  intro a b hab
  by_contra hne
  obtain ⟨x, hx⟩ := hsep hne
  exact hx ((toLocalQuotient_eq_iff.mp hab) x (Set.mem_univ x))

/-- The global section map is always surjective (quotient map). -/
theorem toGlobalSections_surjective :
    Function.Surjective (toGlobalSections (S := S)) :=
  fun q => ⟨q.out, Quotient.out_eq q⟩

/-- Under prime separation, the global section map is bijective. -/
theorem toGlobalSections_bijective
    (hsep : PrimeSeparation S) :
    Function.Bijective (toGlobalSections (S := S)) :=
  ⟨toGlobalSections_injective_of_prime_separation hsep, toGlobalSections_surjective⟩

/-- **Global sections reconstruction isomorphism**. -/
noncomputable def globalSectionsIso
    (hsep : PrimeSeparation S) :
    S ≃+* LocalQuotient S (Set.univ : Set (NucleusPoint S)) :=
  RingEquiv.ofBijective toGlobalSections (toGlobalSections_bijective hsep)

/-- **Local-to-global elimination principle**: equality is equivalent to
pointwise equality at all nucleus points (under prime separation). -/
theorem congruence_eq_iff_locally
    (hsep : PrimeSeparation S)
    (a b : S) :
    a = b ↔ ∀ x : NucleusPoint S, evalAt x a = evalAt x b := by
  constructor
  · intro h _; rw [h]
  · intro h
    by_contra hne
    obtain ⟨x, hx⟩ := hsep hne
    exact hx ((evalAt_eq_iff x a b).mp (h x))

/-! ## 5. Section Congruence Lattice Properties -/

/-- The section congruence on a union characterization. -/
theorem sectionCongr_union_iff {U V : Set (NucleusPoint S)} {a b : S} :
    sectionCongr S (U ∪ V) a b ↔ sectionCongr S U a b ∧ sectionCongr S V a b := by
  constructor
  · intro h
    exact ⟨fun x hx => h x (Set.mem_union_left V hx),
           fun x hx => h x (Set.mem_union_right U hx)⟩
  · rintro ⟨hU, hV⟩ x (hx | hx)
    · exact hU x hx
    · exact hV x hx

/-- The section congruence on the full spectrum characterization. -/
theorem sectionCongr_univ_iff {a b : S} :
    sectionCongr S (Set.univ : Set (NucleusPoint S)) a b ↔
      ∀ x : NucleusPoint S, x.con a b := by
  simp [sectionCongr_iff]

/-! ## 6. Binary Gluing / Patching -/

/-- The **congruence Chinese Remainder property** for sets of nucleus points:
for any elements `a, b` that agree at all points in `U ∩ V`, there exists
a "patching element" `c` that agrees with `a` on `U` and with `b` on `V`. -/
def CongruenceCRT (S : Type u) [CommSemiring S]
    (U V : Set (NucleusPoint S)) : Prop :=
  ∀ a b : S, (∀ x ∈ U ∩ V, x.con a b) →
    ∃ c : S, (∀ x ∈ U, x.con c a) ∧ (∀ x ∈ V, x.con c b)

/-- **Binary gluing theorem**: if local sections over `U` and `V` are compatible
on the overlap `U ∩ V`, and the congruence CRT property holds, then they can be
glued to a section over `U ∪ V`.

Given `sU : LocalQuotient S U` and `sV : LocalQuotient S V` that agree on `U ∩ V`,
there exists `s : LocalQuotient S (U ∪ V)` restricting to `sU` on `U` and `sV` on `V`. -/
theorem sections_glue_binary
    (U V : Set (NucleusPoint S))
    (hCRT : CongruenceCRT S U V)
    (sU : LocalQuotient S U)
    (sV : LocalQuotient S V)
    (hcompat :
      LocalQuotient.restrict Set.inter_subset_left sU =
      LocalQuotient.restrict Set.inter_subset_right sV) :
    ∃ s : LocalQuotient S (U ∪ V),
      LocalQuotient.restrict Set.subset_union_left s = sU ∧
      LocalQuotient.restrict Set.subset_union_right s = sV := by
  obtain ⟨a, rfl⟩ := LocalQuotient.exists_rep sU
  obtain ⟨b, rfl⟩ := LocalQuotient.exists_rep sV
  -- Compatibility means a and b agree on U ∩ V
  have hcompat' : ∀ x ∈ U ∩ V, x.con a b := by
    rwa [show LocalQuotient.restrict Set.inter_subset_left (toLocalQuotient U a) =
           toLocalQuotient (U ∩ V) a from rfl,
         show LocalQuotient.restrict Set.inter_subset_right (toLocalQuotient V b) =
           toLocalQuotient (U ∩ V) b from rfl,
         toLocalQuotient_eq_iff] at hcompat
  -- Apply CRT to get patching element
  obtain ⟨c, hcU, hcV⟩ := hCRT a b hcompat'
  -- c works as our section over U ∪ V
  exact ⟨toLocalQuotient (U ∪ V) c,
    toLocalQuotient_eq_iff.mpr (fun x hx => hcU x hx),
    toLocalQuotient_eq_iff.mpr (fun x hx => hcV x hx)⟩

/-- Binary gluing without CRT for a single representative: if one element `a`
represents compatible sections on both `U` and `V`, it represents a section on `U ∪ V`. -/
theorem sections_glue_binary_from_element
    (U V : Set (NucleusPoint S))
    (a : S) :
    LocalQuotient.restrict Set.subset_union_left (toLocalQuotient (U ∪ V) a) =
      toLocalQuotient U a ∧
    LocalQuotient.restrict Set.subset_union_right (toLocalQuotient (U ∪ V) a) =
      toLocalQuotient V a :=
  ⟨rfl, rfl⟩

/-! ## 7. Stalk Product -/

/-- The **stalk product**: `∏_x S/x.con`. -/
def StalkProduct (S : Type u) [CommSemiring S] : Type u :=
  (x : NucleusPoint S) → x.con.Quotient

noncomputable instance : CommSemiring (StalkProduct S) := Pi.commSemiring

/-- The canonical evaluation map into the stalk product. -/
noncomputable def toStalkProduct : S →+* StalkProduct S :=
  Pi.ringHom (fun x => x.con.mk')

@[simp]
theorem toStalkProduct_apply (a : S) (x : NucleusPoint S) :
    toStalkProduct a x = x.con.toQuotient a := rfl

/-- Pointwise characterization of equality in the stalk product. -/
theorem toStalkProduct_eq_iff {a b : S} :
    toStalkProduct a = toStalkProduct b ↔ ∀ x : NucleusPoint S, x.con a b := by
  constructor
  · intro h x; exact x.con.eq.mp (congr_fun h x)
  · intro h; funext x; exact x.con.eq.mpr (h x)

/-- Stalk product injectivity under prime separation. -/
theorem toStalkProduct_injective
    (hsep : PrimeSeparation S) :
    Function.Injective (toStalkProduct (S := S)) := by
  intro a b hab
  by_contra hne
  obtain ⟨x, hx⟩ := hsep hne
  exact hx (toStalkProduct_eq_iff.mp hab x)

/-! ## 8. Separated Reflection -/

/-- The **nucleus-separated reflection** of `S`. -/
def NucleusSeparatedReflection (S : Type u) [CommSemiring S] : Type u :=
  LocalQuotient S (Set.univ : Set (NucleusPoint S))

noncomputable instance : CommSemiring (NucleusSeparatedReflection S) :=
  instCommSemiringLocalQuotient _

/-- The canonical map from `S` to its separated reflection. -/
noncomputable def toSeparatedReflection (S : Type u) [CommSemiring S] :
    S →+* NucleusSeparatedReflection S :=
  toGlobalSections

/-- The separated reflection is isomorphic to global sections. -/
noncomputable def global_sections_recovers_separated_reflection :
    NucleusSeparatedReflection S ≃+* LocalQuotient S (Set.univ : Set (NucleusPoint S)) :=
  RingEquiv.refl _

/-- Injectivity via evalAt formulation. -/
theorem toGlobalSections_injective_of_nucleus_separated
    (hsep : ∀ {a b : S}, a ≠ b →
      ∃ x : NucleusPoint S, evalAt x a ≠ evalAt x b) :
    Function.Injective (toGlobalSections (S := S)) := by
  apply toGlobalSections_injective_of_prime_separation
  intro a b hab
  obtain ⟨x, hx⟩ := hsep hab
  exact ⟨x, fun h => hx ((evalAt_eq_iff x a b).mpr h)⟩

/-! ## 9. Presheaf Laws -/

/-- Presheaf identity law. -/
theorem NucleusStructurePresheaf_map_id (U : Set (NucleusPoint S)) :
    LocalQuotient.restrict (Set.Subset.refl U) = RingHom.id (LocalQuotient S U) :=
  restrict_id U

/-- Presheaf composition law. -/
theorem NucleusStructurePresheaf_map_comp
    {U V W : Set (NucleusPoint S)} (hUV : V ⊆ U) (hVW : W ⊆ V) :
    LocalQuotient.restrict (Set.Subset.trans hVW hUV) =
      (LocalQuotient.restrict hVW).comp (LocalQuotient.restrict hUV) := by
  symm; exact restrict_comp hUV hVW

end NucleusSheafReconstruction

/-  The lines below are corrupted leftovers of a text edit: each is the tail of a
    statement whose head was lost, and every one of them duplicates a theorem that
    already appears in full earlier in this file.  They are kept, commented out, for
    the record; without the comment the file does not parse.

    end Congr S (Set.univ : Set (NucleusPoint S)) a b ↔
    end Congr S (U ∪ V) a b ↔ sectionCongr S U a b ∧ sectionCongr S V a b := by
    end Congr S (∅ : Set (NucleusPoint S)) a b := by
    end Congr S U ≤ sectionCongr S V :=
    end Congr S U a b ↔ ∀ x ∈ U, x.con a b :=
-/