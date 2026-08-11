import Mathlib
import Tropical.TropicalLinearSpaceElimination

/-!
# Operations on tropical linear spaces, and sharpness of the elimination theorem

Continuing `Catalog/Tropical/TropicalLinearSpaceElimination.lean`, this file
establishes the two basic *minor* operations of valuated matroid theory in the
tropical vector setting, and then shows that the elimination theorem proved there
is sharp.

* `isTropicalLinearSpace_scaleSet` : rescaling all coordinates by a vector of
  finite tropical scalars (a tropical diagonal automorphism) preserves tropical
  linear spaces.
* `isTropicalLinearSpace_deletion` : restricting to a subset of coordinates,
  keeping only the members supported there (matroid *deletion*), preserves
  tropical linear spaces.
* `intersection_not_satisfiesElimination` : **the intersection of two tropical
  hyperplanes need not satisfy elimination.**  Concretely, in `T^4` with
  `c₁ = (0,0,0,0)` and `c₂ = (0,0,0,1)` the intersection is a subsemimodule which
  is *not* a tropical linear space.  This shows that tropical linear spaces are
  not closed under intersection: only *stable* intersection is, and it explains
  why the elimination axiom is genuine extra content rather than a formal
  consequence of the semimodule axioms.
-/

namespace TropicalElimination

variable {E : Type*}

section Arithmetic

/-- Every finite tropical scalar is left-cancellable up to solving `a + t = s`. -/
theorem exists_add_eq {a : TT} (ha : a ≠ ⊤) (s : TT) : ∃ t : TT, a + t = s := by
  obtain ⟨p, hp⟩ : ∃ p : ℚ, a = (p : TT) := ⟨a.untop ha, by simp⟩
  by_cases hs : s = ⊤
  · exact ⟨⊤, by rw [hs, add_top]⟩
  · obtain ⟨r, hr⟩ : ∃ r : ℚ, s = (r : TT) := ⟨s.untop hs, by simp⟩
    exact ⟨((r - p : ℚ) : TT), by rw [hp, ← WithTop.coe_add, hr]; norm_num⟩

theorem add_eq_top_iff_of_ne_top {a t : TT} (ha : a ≠ ⊤) : a + t = ⊤ ↔ t = ⊤ := by
  constructor
  · intro h
    by_contra ht
    obtain ⟨p, hp⟩ : ∃ p : ℚ, a = (p : TT) := ⟨a.untop ha, by simp⟩
    obtain ⟨r, hr⟩ : ∃ r : ℚ, t = (r : TT) := ⟨t.untop ht, by simp⟩
    rw [hp, hr, ← WithTop.coe_add] at h
    exact WithTop.coe_ne_top h
  · intro h; rw [h, add_top]

theorem min_add_left (a x y : TT) : a + min x y = min (a + x) (a + y) := by
  rcases le_total x y with h | h
  · rw [min_eq_left h, min_eq_left (by gcongr)]
  · rw [min_eq_right h, min_eq_right (by gcongr)]

end Arithmetic

section Scaling

variable {V : Set (E → TT)}

/-- Rescaling a set of tropical vectors coordinatewise by `a`. -/
def scaleSet (a : E → TT) (V : Set (E → TT)) : Set (E → TT) :=
  {x | (fun i => a i + x i) ∈ V}

theorem isTropSemimodule_scaleSet {a : E → TT} (hV : IsTropSemimodule V) :
    IsTropSemimodule (scaleSet a V) where
  zero_mem := by
    have : (fun i => a i + tropZero E i) = tropZero E := by
      funext i; simp [tropZero]
    simpa [scaleSet, this] using hV.zero_mem
  add_mem := by
    intro x y hx hy
    have hxy : (fun i => a i + tropAdd x y i) =
        tropAdd (fun i => a i + x i) (fun i => a i + y i) := by
      funext i; simp [tropAdd, min_add_left]
    simpa [scaleSet, hxy] using hV.add_mem hx hy
  smul_mem := by
    intro c x hx
    have hcx : (fun i => a i + tropSMul c x i) = tropSMul c (fun i => a i + x i) := by
      funext i
      simp only [tropSMul]
      rw [add_left_comm]
    simpa [scaleSet, hcx] using hV.smul_mem c hx

/-- **Tropical diagonal automorphisms preserve tropical linear spaces.** -/
theorem isTropicalLinearSpace_scaleSet {a : E → TT} (ha : ∀ i, a i ≠ ⊤)
    (hV : IsTropicalLinearSpace V) : IsTropicalLinearSpace (scaleSet a V) where
  semimodule := isTropSemimodule_scaleSet hV.semimodule
  elimination := by
    intro x hx y hy e hxye hxe
    have hne : (fun i => a i + x i) e ≠ ⊤ := by
      simp only [ne_eq]
      rw [add_eq_top_iff_of_ne_top (ha e)]
      exact hxe
    obtain ⟨z', hz'V, hz'e, hz'ge, hz'eq⟩ :=
      hV.elimination _ hx _ hy e (show a e + x e = a e + y e by rw [hxye]) hne
    -- unscale `z'`
    choose z hz using fun i => exists_add_eq (ha i) (z' i)
    refine ⟨z, ?_, ?_, ?_, ?_⟩
    · show (fun i => a i + z i) ∈ V
      have : (fun i => a i + z i) = z' := funext hz
      rwa [this]
    · have := hz e
      rw [hz'e] at this
      exact (add_eq_top_iff_of_ne_top (ha e)).mp this
    · intro i
      have h1 : a i + min (x i) (y i) ≤ a i + z i := by
        rw [min_add_left, hz i]
        exact hz'ge i
      exact (WithTop.add_le_add_iff_left (ha i)).mp h1
    · intro i hi
      have hi' : a i + x i ≠ a i + y i := fun h => hi (WithTop.add_left_cancel (ha i) h)
      have h1 : a i + z i = a i + min (x i) (y i) := by
        rw [hz i, min_add_left]
        exact hz'eq i hi'
      exact WithTop.add_left_cancel (ha i) h1

end Scaling

section Deletion

variable {V : Set (E → TT)} {S : Set E}

/-- Matroid *deletion*: the members of `V` that vanish outside `S`, restricted to
`S`. -/
def deletion (S : Set E) (V : Set (E → TT)) : Set ({i // i ∈ S} → TT) :=
  {x | ∃ x' ∈ V, (∀ i : {i // i ∈ S}, x' (i : E) = x i) ∧ ∀ i, i ∉ S → x' i = ⊤}

theorem isTropSemimodule_deletion (hV : IsTropSemimodule V) :
    IsTropSemimodule (deletion S V) where
  zero_mem :=
    ⟨tropZero E, hV.zero_mem, fun _ => rfl, fun _ _ => rfl⟩
  add_mem := by
    rintro x y ⟨x', hx'V, hx'S, hx'out⟩ ⟨y', hy'V, hy'S, hy'out⟩
    refine ⟨tropAdd x' y', hV.add_mem hx'V hy'V, ?_, ?_⟩
    · intro i; simp [tropAdd, hx'S i, hy'S i]
    · intro i hi; simp [tropAdd, hx'out i hi, hy'out i hi]
  smul_mem := by
    rintro c x ⟨x', hx'V, hx'S, hx'out⟩
    refine ⟨tropSMul c x', hV.smul_mem c hx'V, ?_, ?_⟩
    · intro i; simp [tropSMul, hx'S i]
    · intro i hi; simp [tropSMul, hx'out i hi]

/-- **Deletion preserves tropical linear spaces**: the minor of a valuated
matroid obtained by deleting coordinates is again a valuated matroid. -/
theorem isTropicalLinearSpace_deletion (hV : IsTropicalLinearSpace V) :
    IsTropicalLinearSpace (deletion S V) where
  semimodule := isTropSemimodule_deletion hV.semimodule
  elimination := by
    rintro x ⟨x', hx'V, hx'S, hx'out⟩ y ⟨y', hy'V, hy'S, hy'out⟩ e hxye hxe
    have hx'e : x' (e : E) = y' (e : E) := by rw [hx'S e, hy'S e, hxye]
    have hx'ne : x' (e : E) ≠ ⊤ := by rw [hx'S e]; exact hxe
    obtain ⟨z', hz'V, hz'e, hz'ge, hz'eq⟩ :=
      hV.elimination x' hx'V y' hy'V (e : E) hx'e hx'ne
    have hz'out : ∀ i, i ∉ S → z' i = ⊤ := by
      intro i hi
      have h := hz'ge i
      rw [hx'out i hi, hy'out i hi, min_self] at h
      exact top_le_iff.mp h
    refine ⟨fun i : {i // i ∈ S} => z' (i : E), ⟨z', hz'V, fun _ => rfl, hz'out⟩, hz'e, ?_, ?_⟩
    · intro i
      have h := hz'ge (i : E)
      rwa [hx'S i, hy'S i] at h
    · intro i hi
      have hi' : x' (i : E) ≠ y' (i : E) := by rw [hx'S i, hy'S i]; exact hi
      have h := hz'eq (i : E) hi'
      rwa [hx'S i, hy'S i] at h

end Deletion

section Sharpness

/-- First coefficient vector of the sharpness example: `(0,0,0,0)`. -/
def c₁ : Fin 4 → TT := fun _ => 0

/-- Second coefficient vector of the sharpness example: `(0,0,0,1)`. -/
def c₂ : Fin 4 → TT := fun i => if i = 3 then 1 else 0

/-- First witness vector: `(0,0,1,0)`. -/
def xw : Fin 4 → TT := fun i => if i = 2 then 1 else 0

/-- Second witness vector: `(0,0,1,1)`. -/
def yw : Fin 4 → TT := fun i => if i = 2 ∨ i = 3 then 1 else 0

theorem xw_mem : xw ∈ tropVanishing c₁ ∩ tropVanishing c₂ := by
  constructor
  · intro i
    fin_cases i
    · exact ⟨1, by decide, by norm_num [c₁, xw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₁, xw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₁, xw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₁, xw, Fin.ext_iff]⟩
  · intro i
    fin_cases i
    · exact ⟨1, by decide, by norm_num [c₂, xw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₂, xw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₂, xw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₂, xw, Fin.ext_iff]⟩

theorem yw_mem : yw ∈ tropVanishing c₁ ∩ tropVanishing c₂ := by
  constructor
  · intro i
    fin_cases i
    · exact ⟨1, by decide, by norm_num [c₁, yw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₁, yw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₁, yw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₁, yw, Fin.ext_iff]⟩
  · intro i
    fin_cases i
    · exact ⟨1, by decide, by norm_num [c₂, yw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₂, yw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₂, yw, Fin.ext_iff]⟩
    · exact ⟨0, by decide, by norm_num [c₂, yw, Fin.ext_iff]⟩

/-- **Sharpness: tropical linear spaces are not closed under intersection.**

The intersection of the two tropical hyperplanes with coefficient vectors
`c₁ = (0,0,0,0)` and `c₂ = (0,0,0,1)` in `T^4` fails the vector elimination
axiom: eliminating the coordinate `0` from the members `(0,0,1,0)` and
`(0,0,1,1)` forces a vector that cannot lie in both hyperplanes.  Hence the
elimination axiom is genuine extra content and only *stable* intersection can
preserve tropical linear spaces. -/
theorem intersection_not_satisfiesElimination :
    ¬ SatisfiesElimination (tropVanishing c₁ ∩ tropVanishing c₂) := by
  intro helim
  obtain ⟨z, ⟨hz1, hz2⟩, hze, hzge, hzeq⟩ :=
    helim xw xw_mem yw yw_mem 0 (by norm_num [xw, yw, Fin.ext_iff])
      (by norm_num [xw, Fin.ext_iff])
  -- the coordinate `3` is forced to `0`; coordinates `1, 2` are bounded below
  have hz3 : z 3 = (0 : TT) := by
    rw [hzeq 3 (by norm_num [xw, yw, Fin.ext_iff])]
    norm_num [xw, yw, Fin.ext_iff]
  have hz1ge : (0 : TT) ≤ z 1 := by
    have h := hzge 1
    rwa [show min (xw 1) (yw 1) = (0 : TT) by norm_num [xw, yw, Fin.ext_iff]] at h
  have hz2ge : (1 : TT) ≤ z 2 := by
    have h := hzge 2
    rwa [show min (xw 2) (yw 2) = (1 : TT) by norm_num [xw, yw, Fin.ext_iff]] at h
  -- membership in the first hyperplane at coordinate `3` forces `z 1 = 0`
  obtain ⟨j, hj, hjle⟩ := hz1 3
  rw [hz3] at hjle
  have hjcases : ∀ m : Fin 4, m ≠ 3 → m = 0 ∨ m = 1 ∨ m = 2 := by decide
  have hz1eq : z 1 = (0 : TT) := by
    rcases hjcases j hj with rfl | rfl | rfl
    · rw [hze] at hjle
      simp [c₁] at hjle
    · exact le_antisymm (by simpa [c₁] using hjle) hz1ge
    · exact absurd (hz2ge.trans (by simpa [c₁] using hjle)) (by norm_num)
  -- membership in the second hyperplane at coordinate `1` is then impossible
  obtain ⟨k, hk, hkle⟩ := hz2 1
  rw [hz1eq] at hkle
  have hkcases : ∀ m : Fin 4, m ≠ 1 → m = 0 ∨ m = 2 ∨ m = 3 := by decide
  rcases hkcases k hk with rfl | rfl | rfl
  · rw [hze] at hkle
    simp [c₂] at hkle
  · exact absurd (hz2ge.trans (by simpa [c₂, Fin.ext_iff] using hkle)) (by norm_num)
  · rw [hz3] at hkle
    norm_num [c₂, Fin.ext_iff] at hkle
    exact absurd hkle (by norm_num)

/-- The intersection in the sharpness example *is* a subsemimodule: the failure
above is genuinely a failure of the elimination axiom, not of tropical
linearity. -/
theorem intersection_isTropSemimodule :
    IsTropSemimodule (tropVanishing c₁ ∩ tropVanishing c₂) where
  zero_mem := ⟨tropZero_mem_tropVanishing c₁, tropZero_mem_tropVanishing c₂⟩
  add_mem := fun hx hy =>
    ⟨tropAdd_mem_tropVanishing c₁ hx.1 hy.1, tropAdd_mem_tropVanishing c₂ hx.2 hy.2⟩
  smul_mem := fun a {_x} hx =>
    ⟨tropSMul_mem_tropVanishing c₁ a hx.1, tropSMul_mem_tropVanishing c₂ a hx.2⟩

end Sharpness

end TropicalElimination