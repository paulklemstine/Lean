import Mathlib

/-!
# The isometry group of a rhythm line (the 1-dimensional crystallographic group)

The full symmetry group of a rhythm `f : ℤ → Bool` is not just its translations:
it also includes **reflections** (palindromes) and, in general, the isometries of
the integer time-line that preserve the onset pattern.  The isometries of `ℤ`
form the **infinite dihedral group** `Dih∞`, the 1-dimensional analogue of a
wallpaper group.

We realise isometries concretely as permutations of `ℤ` of the affine form
`x ↦ ±x + t`.

* `isomGroup : Subgroup (Equiv.Perm ℤ)` — the isometry group of the line.
* `transl`, `refl` — the two basic families of isometries (translations and the
  reflection through the origin), both shown to be isometries.
* `sign` — the orientation homomorphism `isomGroup → {±1}`, giving the extension
  `1 → ℤ (translations) → Dih∞ → ℤ/2 → 1`.
* `refl_mul_refl_eq_transl` — **the product of two reflections is a translation**,
  the defining relation of the infinite dihedral group.
* `symmGroup f` — the isometries preserving a rhythm `f`, a subgroup; and
  `crystalGroup f` — its intersection with the isometries: the rhythm's genuine
  crystallographic symmetry group.
* `refl_mem_symmGroup_iff` — a rhythm is a **palindrome** exactly when the origin
  reflection preserves it; `transl_mem_symmGroup_iff` — a translation preserves it
  exactly when it is a period.
-/

namespace WallpaperRhythm

open Equiv

/-- A rhythm: a Boolean onset function on the integer time-line. -/
abbrev Rhythm := ℤ → Bool

/-! ## The isometry group of the line -/

/-- The isometry group of `ℤ`: permutations of the form `x ↦ ±x + t`.
This is a concrete model of the infinite dihedral group `Dih∞`. -/
def isomGroup : Subgroup (Equiv.Perm ℤ) where
  carrier := {e | ∃ (s : Bool) (t : ℤ), ∀ x, e x = (if s then -x else x) + t}
  one_mem' := ⟨false, 0, fun x => by simp⟩
  mul_mem' := by
    rintro e1 e2 ⟨s1, t1, h1⟩ ⟨s2, t2, h2⟩
    refine ⟨xor s1 s2, (if s1 then -t2 else t2) + t1, fun x => ?_⟩
    rw [Equiv.Perm.mul_apply, h1 (e2 x), h2 x]
    cases s1 <;> cases s2 <;> simp <;> ring
  inv_mem' := by
    rintro e ⟨s, t, h⟩
    refine ⟨s, if s then t else -t, fun x => ?_⟩
    apply e.injective
    have hcoe : (e⁻¹ : Equiv.Perm ℤ) x = e.symm x := rfl
    rw [hcoe, Equiv.apply_symm_apply, h]
    cases s <;> simp

/-- A translation `x ↦ x + t` as an isometry. -/
def transl (t : ℤ) : Equiv.Perm ℤ := Equiv.addRight t

/-- The reflection `x ↦ -x` through the origin. -/
def refl : Equiv.Perm ℤ := Equiv.neg ℤ

@[simp] lemma transl_apply (t x : ℤ) : transl t x = x + t := rfl
@[simp] lemma refl_apply (x : ℤ) : refl x = -x := rfl

lemma transl_mem (t : ℤ) : transl t ∈ isomGroup := ⟨false, t, fun x => by simp⟩

lemma refl_mem : refl ∈ isomGroup := ⟨true, 0, fun x => by simp⟩

/-- A reflection through the point `t/2`: `x ↦ -x + t`. -/
def reflAt (t : ℤ) : Equiv.Perm ℤ := refl.trans (transl t)

@[simp] lemma reflAt_apply (t x : ℤ) : reflAt t x = -x + t := rfl

lemma reflAt_mem (t : ℤ) : reflAt t ∈ isomGroup := ⟨true, t, fun x => by simp⟩

/-! ## The orientation homomorphism -/

/-- The orientation ("sign") of an isometry, `+1` for translations and `-1` for
reflections.  Read off as `e 1 - e 0`. -/
def sign (e : Equiv.Perm ℤ) : ℤ := e 1 - e 0

@[simp] lemma sign_transl (t : ℤ) : sign (transl t) = 1 := by simp [sign]

@[simp] lemma sign_refl : sign refl = -1 := by simp [sign]

/-- On an isometry, the sign is exactly `±1` determined by orientation, read off
from its affine form. -/
lemma sign_of_affine {e : Equiv.Perm ℤ} {s : Bool} {t : ℤ}
    (h : ∀ x, e x = (if s then -x else x) + t) :
    sign e = if s then -1 else 1 := by
  simp only [sign, h]; cases s <;> simp

/-- **The sign is multiplicative** on the isometry group: the orientation map is a
group homomorphism, exhibiting `Dih∞` as an extension of `ℤ/2`. -/
lemma sign_mul {e1 e2 : Equiv.Perm ℤ} (h1 : e1 ∈ isomGroup) (h2 : e2 ∈ isomGroup) :
    sign (e1 * e2) = sign e1 * sign e2 := by
  obtain ⟨s1, t1, H1⟩ := h1
  obtain ⟨s2, t2, H2⟩ := h2
  simp only [sign, Equiv.Perm.mul_apply, H1, H2]
  cases s1 <;> cases s2 <;> simp

/-- **Product of two reflections is a translation** — the fundamental relation of
the infinite dihedral group.  `reflAt t1 ∘ reflAt t2 = translation by (t1 - t2)`. -/
lemma reflAt_mul_reflAt (t1 t2 : ℤ) : reflAt t1 * reflAt t2 = transl (t1 - t2) := by
  ext x
  simp only [Equiv.Perm.mul_apply, reflAt_apply, transl_apply]
  ring

/-- Every orientation-reversing isometry of the line is an **involution**
(reflections and 1-D glide reflections both square to the identity). -/
lemma reflAt_sq (t : ℤ) : reflAt t * reflAt t = 1 := by
  ext x; simp [Equiv.Perm.mul_apply]

/-! ## The symmetry group of a rhythm -/

/-- The isometries preserving a rhythm `f` (`f (e n) = f n` for all `n`) form a
subgroup of `Perm ℤ`. -/
def symmGroup (f : Rhythm) : Subgroup (Equiv.Perm ℤ) where
  carrier := {e | ∀ n, f (e n) = f n}
  one_mem' := by intro n; simp
  mul_mem' := by
    intro a b ha hb n
    rw [Equiv.Perm.mul_apply, ha (b n), hb n]
  inv_mem' := by
    intro a ha n
    have hcoe : (a⁻¹ : Equiv.Perm ℤ) n = a.symm n := rfl
    have := ha (a.symm n)
    rw [Equiv.apply_symm_apply] at this
    rw [hcoe, this]

@[simp] lemma mem_symmGroup {f : Rhythm} {e : Equiv.Perm ℤ} :
    e ∈ symmGroup f ↔ ∀ n, f (e n) = f n := Iff.rfl

/-- **The crystallographic symmetry group of a rhythm**: the isometries of the
line that preserve its onset pattern.  This is the object the wallpaper-group
programme classifies. -/
def crystalGroup (f : Rhythm) : Subgroup (Equiv.Perm ℤ) := isomGroup ⊓ symmGroup f

/-- A translation preserves the rhythm exactly when it is a period. -/
@[simp] lemma transl_mem_symmGroup_iff {f : Rhythm} {t : ℤ} :
    transl t ∈ symmGroup f ↔ Function.Periodic f t := by
  simp only [mem_symmGroup, transl_apply]; rfl

/-- The origin reflection preserves the rhythm exactly when it is a **palindrome**
about `0`. -/
@[simp] lemma refl_mem_symmGroup_iff {f : Rhythm} :
    refl ∈ symmGroup f ↔ ∀ n, f (-n) = f n := by
  simp only [mem_symmGroup, refl_apply]

/-- Every translation that is a period lies in the crystal group. -/
lemma transl_mem_crystalGroup {f : Rhythm} {t : ℤ} (h : Function.Periodic f t) :
    transl t ∈ crystalGroup f :=
  ⟨transl_mem t, transl_mem_symmGroup_iff.mpr h⟩

/-- A palindromic rhythm has the origin reflection in its crystal group. -/
lemma refl_mem_crystalGroup {f : Rhythm} (h : ∀ n, f (-n) = f n) :
    refl ∈ crystalGroup f :=
  ⟨refl_mem, refl_mem_symmGroup_iff.mpr h⟩

end WallpaperRhythm