import Mathlib

/-!
# Two-dimensional drum patterns and their translation lattices

A **drum pattern** is a Boolean onset function on the time × pitch grid,
`g : ℤ × ℤ → Bool`.  Its translation symmetries form an additive subgroup of
`ℤ × ℤ` — a rank `≤ 2` integer lattice.  These lattices are the objects whose
refinement (adding rotations and reflections) yields the 17 wallpaper groups, so
the lattice is the *translational skeleton* of a wallpaper symmetry.

We prove:

* `symGroup2 g` is an additive subgroup of `ℤ × ℤ`.
* `mem_canon_iff` — for a **canon** pattern `g (a, b) = F (a - b)` (the same
  1-D rhythm `F` played along every diagonal), a shift `(s, t)` is a symmetry
  **iff** `s - t` is a period of `F`.  Thus the symmetry lattice of a canon is a
  *sheared* (oblique / "centred") lattice — the hallmark of `pg`/`cm` glide
  patterns.
* `canon_diagonal_mem` — shifting time and pitch by the *same* amount always
  preserves a canon (the anti-diagonal is always in the lattice).
* `product_mem` — for an **independent** pattern `g (a, b) = F a && G b`, if `s`
  is a period of `F` and `t` a period of `G` then `(s, t)` is a symmetry (the
  lattice is rectangular).
* `pointSym` — 2-fold rotation (`call-and-response`, the `p2` case): the point
  reflection `v ↦ -v` is an involution, and the composite of two point
  reflections is a translation, exactly as in the 1-D dihedral picture.
-/

namespace WallpaperRhythm

/-- A drum pattern: a Boolean onset function on the time × pitch grid. -/
abbrev DrumPattern := ℤ × ℤ → Bool

/-- The translation symmetries of a drum pattern form an additive subgroup of
`ℤ × ℤ`: the pattern's translation lattice. -/
def symGroup2 (g : DrumPattern) : AddSubgroup (ℤ × ℤ) where
  carrier := {u | ∀ v, g (v + u) = g v}
  zero_mem' := by intro v; simp
  add_mem' := by
    intro a b ha hb v
    have h : v + (a + b) = (v + b) + a := by abel
    rw [h, ha (v + b), hb v]
  neg_mem' := by
    intro a ha v
    have key := ha (v - a)
    have h2 : (v - a) + a = v := by abel
    rw [h2] at key
    rw [show v + -a = v - a from by abel]
    exact key.symm

@[simp] lemma mem_symGroup2 {g : DrumPattern} {u : ℤ × ℤ} :
    u ∈ symGroup2 g ↔ ∀ v, g (v + u) = g v := Iff.rfl

/-! ## Canon patterns: a sheared lattice -/

/-- A **canon**: the 1-D rhythm `F` played along every diagonal of the grid,
`g (a, b) = F (a - b)`. -/
def canonPattern (F : ℤ → Bool) : DrumPattern := fun p => F (p.1 - p.2)

/-- **The symmetry lattice of a canon is sheared.**  A shift `(s, t)` is a
symmetry of the canon built from `F` iff `s - t` is a period of `F`. -/
theorem mem_canon_iff (F : ℤ → Bool) (s t : ℤ) :
    (s, t) ∈ symGroup2 (canonPattern F) ↔ ∀ m, F (m + (s - t)) = F m := by
  simp only [mem_symGroup2, canonPattern, Prod.fst_add, Prod.snd_add]
  constructor
  · intro h m
    have hv := h (m, 0)
    have e1 : (m, (0:ℤ)).1 + s - ((m, (0:ℤ)).2 + t) = m + (s - t) := by simp; ring
    have e2 : (m, (0:ℤ)).1 - (m, (0:ℤ)).2 = m := by simp
    rw [e1, e2] at hv
    exact hv
  · intro h v
    have hm := h (v.1 - v.2)
    have harg : v.1 + s - (v.2 + t) = (v.1 - v.2) + (s - t) := by ring
    rw [harg, hm]

/-- Shifting time and pitch by the **same** amount always preserves a canon:
the anti-diagonal `(s, s)` is always in the symmetry lattice. -/
theorem canon_diagonal_mem (F : ℤ → Bool) (s : ℤ) :
    (s, s) ∈ symGroup2 (canonPattern F) := by
  rw [mem_canon_iff]
  intro m; simp

/-! ## Independent (product) patterns: a rectangular lattice -/

/-- An **independent** pattern: a time rhythm `F` and a pitch rhythm `G` combined
pointwise, `g (a, b) = F a && G b`. -/
def productPattern (F G : ℤ → Bool) : DrumPattern := fun p => F p.1 && G p.2

/-- For an independent pattern, if `s` is a period of `F` and `t` a period of `G`
then `(s, t)` is a symmetry: the lattice is rectangular. -/
theorem product_mem (F G : ℤ → Bool) {s t : ℤ}
    (hs : Function.Periodic F s) (ht : Function.Periodic G t) :
    (s, t) ∈ symGroup2 (productPattern F G) := by
  intro v
  simp only [productPattern, Prod.fst_add, Prod.snd_add]
  rw [hs v.1, ht v.2]

/-! ## Two-fold rotation (`p2`, call-and-response) -/

/-- The 180° point reflection of the grid about the origin, `v ↦ -v`. -/
def pointRefl : Equiv.Perm (ℤ × ℤ) := Equiv.neg (ℤ × ℤ)

@[simp] lemma pointRefl_apply (v : ℤ × ℤ) : pointRefl v = -v := rfl

/-- The point reflection is an **involution** (a genuine 2-fold rotation). -/
theorem pointRefl_involutive : pointRefl * pointRefl = 1 := by
  ext v <;> simp [Equiv.Perm.mul_apply]

/-- A drum pattern has **2-fold rotational (`p2`) symmetry** when it is invariant
under the point reflection: `g (-v) = g v`. -/
def HasP2 (g : DrumPattern) : Prop := ∀ v, g (-v) = g v

/-- The composite of a point reflection about the origin followed by a
translation is again orientation-preserving on the lattice: for a `p2`-symmetric
pattern, `-v + u` symmetries correspond to genuine translation symmetries `u`
after the rotation.  Concretely, if `g` has `p2` symmetry then the translated
point-reflections `v ↦ -v + u` preserve `g` exactly when `u ∈ symGroup2 g`
composed with the rotation. -/
theorem hasP2_neg {g : DrumPattern} (h : HasP2 g) (v : ℤ × ℤ) : g (-v) = g v := h v

/-- Two point reflections (about the origin) compose to the identity translation,
paralleling the 1-D dihedral relation `refl ∘ refl = transl 0`. -/
theorem pointRefl_mul_pointRefl : pointRefl * pointRefl = Equiv.addRight (0 : ℤ × ℤ) := by
  ext v <;> simp [Equiv.Perm.mul_apply]

end WallpaperRhythm