/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Logic.CubicalSemantics.Basic

/-!
# Path Space Cardinality Invariants for Infinite Types

This file establishes infinite-cardinal cubical path-space invariants,
extending finite path-counting to cardinal arithmetic over `ℝ`.

## Main definitions

- `CubicalInterval ℝ` — The real line as a cubical interval
- `EndpointZeroFun` — Functions `ℝ → ℝ` vanishing at `0` and `1`
- `perturbAffine` — Affine-perturbation embedding
- `pathCardinalProfile` — Cardinal invariant of a path space
- `CubicalEquiv` — Cubical equivalences between types
- `translationPathEquiv` — Translation equivalence on path spaces

## Main results

- `perturbAffine_injective` — Affine-perturbation is injective
- `mk_real_le_mk_pathOver_real` — Continuum lower bound
- `mk_pathOver_le_mk_fun` — Function-space upper bound
- `pathOverEquivEndpointZeroFun` — Path space ≃ endpoint-zero function space
- `pathOver_cardinal_invariant_general` — Cardinality invariance under cubical equivalence
- `translation_preserves_pathCardinal` — Translation preserves cardinality

## Keywords

infinite cardinal arithmetic, cubical path spaces, continuum cardinality,
function-space semantics, Brownian bridge, path integrals
-/

noncomputable section

open Cardinal CubicalSemantics

namespace CubicalSemantics

/-! ### Real line as a cubical interval -/

instance realCubicalInterval : CubicalInterval ℝ where
  i0 := 0
  i1 := 1
  rev := fun t => 1 - t
  rev_i0 := by norm_num
  rev_i1 := by norm_num

/-! ### Endpoint-zero functions and affine perturbation -/

/-- Functions `ℝ → ℝ` that vanish at `0` and `1` — perturbation degrees of freedom
    for paths, and the algebraic precursor of Brownian bridge sample spaces. -/
def EndpointZeroFun : Type :=
  { f : ℝ → ℝ // f 0 = 0 ∧ f 1 = 0 }

/-- The affine-perturbation embedding: `t ↦ a + (b - a) * t + f(t)`. -/
def perturbAffine (a b : ℝ) (f : EndpointZeroFun) :
    PathOver (I := ℝ) ℝ a b :=
  ⟨fun t => a + (b - a) * t + f.1 t,
   ⟨by show a + (b - a) * 0 + f.1 0 = a; rw [f.2.1]; ring,
    by show a + (b - a) * 1 + f.1 1 = b; rw [f.2.2]; ring⟩⟩

/-- The affine-perturbation map is injective. -/
theorem perturbAffine_injective (a b : ℝ) :
    Function.Injective (perturbAffine a b) := by
  intro f g h
  have hfg : (perturbAffine a b f).1 = (perturbAffine a b g).1 :=
    congrArg Subtype.val h
  apply Subtype.ext
  funext t
  have := congr_fun hfg t
  simp only [perturbAffine] at this
  linarith

/-- Two affine perturbations are equal iff the underlying functions agree. -/
theorem perturbAffine_eq_iff (a b : ℝ) (f g : EndpointZeroFun) :
    perturbAffine a b f = perturbAffine a b g ↔ f = g :=
  ⟨fun h => perturbAffine_injective a b h, fun h => h ▸ rfl⟩

/-! ### Cardinal lower bound -/

/-- Embed `ℝ` into endpoint-zero functions via `c ↦ (t ↦ c * t * (1 - t))`. -/
def realToEndpointZeroFun : ℝ → EndpointZeroFun :=
  fun c => ⟨fun t => c * t * (1 - t), by constructor <;> ring⟩

/-- The embedding `ℝ → EndpointZeroFun` is injective. -/
theorem realToEndpointZeroFun_injective : Function.Injective realToEndpointZeroFun := by
  intro c d h
  have hv : (realToEndpointZeroFun c).1 = (realToEndpointZeroFun d).1 :=
    congrArg Subtype.val h
  have h12 := congr_fun hv (1/2 : ℝ)
  simp only [realToEndpointZeroFun] at h12
  nlinarith

/-- Continuum lower bound: `#ℝ ≤ #PathOver ℝ a b`. -/
theorem mk_real_le_mk_pathOver_real (a b : ℝ) :
    Cardinal.mk ℝ ≤ Cardinal.mk (PathOver (I := ℝ) ℝ a b) :=
  le_trans
    (Cardinal.mk_le_of_injective realToEndpointZeroFun_injective)
    (Cardinal.mk_le_of_injective (perturbAffine_injective a b))

/-! ### Cardinal upper bound -/

/-- The path space embeds into the function space by forgetting endpoint constraints. -/
theorem mk_pathOver_le_mk_fun (a b : ℝ) :
    Cardinal.mk (PathOver (I := ℝ) ℝ a b) ≤ Cardinal.mk (ℝ → ℝ) :=
  Cardinal.mk_le_of_injective (f := fun p => p.1)
    (fun _ _ h => Subtype.ext h)

/-! ### Exact equivalence: path space ≃ endpoint-zero functions -/

/-- Extract the perturbation part of a path: `t ↦ p(t) - a - (b-a)*t`. -/
def pathToEndpointZeroFun (a b : ℝ) (p : PathOver (I := ℝ) ℝ a b) : EndpointZeroFun :=
  ⟨fun t => p.1 t - a - (b - a) * t,
   ⟨by have h : p.1 0 = a := p.2.1; linarith,
    by have h : p.1 1 = b := p.2.2; linarith⟩⟩

/-- Perturbation and extraction are mutually inverse (left). -/
theorem perturbAffine_leftInv (a b : ℝ) (f : EndpointZeroFun) :
    pathToEndpointZeroFun a b (perturbAffine a b f) = f := by
  apply Subtype.ext; funext t
  simp only [pathToEndpointZeroFun, perturbAffine]
  ring

/-- Perturbation and extraction are mutually inverse (right). -/
theorem perturbAffine_rightInv (a b : ℝ) (p : PathOver (I := ℝ) ℝ a b) :
    perturbAffine a b (pathToEndpointZeroFun a b p) = p := by
  apply Subtype.ext; funext t
  simp only [perturbAffine, pathToEndpointZeroFun]
  ring

/-- **The path space is equivalent to the endpoint-zero function space.**
    Every path is uniquely an affine path plus a perturbation. -/
def pathOverEquivEndpointZeroFun (a b : ℝ) :
    PathOver (I := ℝ) ℝ a b ≃ EndpointZeroFun where
  toFun := pathToEndpointZeroFun a b
  invFun := perturbAffine a b
  left_inv := perturbAffine_rightInv a b
  right_inv := perturbAffine_leftInv a b

/-- Path space and endpoint-zero function space have equal cardinality. -/
theorem mk_pathOver_eq_mk_endpointZeroFun (a b : ℝ) :
    Cardinal.mk (PathOver (I := ℝ) ℝ a b) = Cardinal.mk EndpointZeroFun :=
  Cardinal.mk_congr (pathOverEquivEndpointZeroFun a b)

/-! ### Cubical equivalences and cardinality invariance -/

/-- A cubical equivalence between types `X` and `Y`. -/
structure CubicalEquiv (X : Type u) (Y : Type u) where
  toFun : X → Y
  invFun : Y → X
  left_inv : ∀ x, invFun (toFun x) = x
  right_inv : ∀ y, toFun (invFun y) = y

/-- A cubical equivalence gives a type equivalence. -/
def CubicalEquiv.toEquiv {X Y : Type u} (e : CubicalEquiv X Y) : X ≃ Y where
  toFun := e.toFun
  invFun := e.invFun
  left_inv := e.left_inv
  right_inv := e.right_inv

/-- Transport a path along a cubical equivalence. -/
def CubicalEquiv.mapPath {I : Type*} [CubicalInterval I]
    {X Y : Type u} (e : CubicalEquiv X Y) {a b : X}
    (p : PathOver (I := I) X a b) : PathOver (I := I) Y (e.toFun a) (e.toFun b) :=
  ⟨e.toFun ∘ p.1,
   ⟨by simp [Function.comp, p.2.1], by simp [Function.comp, p.2.2]⟩⟩

/-- A cubical equivalence induces a bijection on path spaces. -/
def CubicalEquiv.pathEquiv {I : Type*} [CubicalInterval I]
    {X Y : Type u} (e : CubicalEquiv X Y) (a b : X) :
    PathOver (I := I) X a b ≃ PathOver (I := I) Y (e.toFun a) (e.toFun b) where
  toFun := e.mapPath
  invFun := fun p => by
    refine ⟨e.invFun ∘ p.1, ?_, ?_⟩
    · simp [Function.comp, p.2.1, e.left_inv]
    · simp [Function.comp, p.2.2, e.left_inv]
  left_inv := by
    intro p; apply Subtype.ext; funext i
    simp [mapPath, Function.comp, e.left_inv]
  right_inv := by
    intro p; apply Subtype.ext; funext i
    simp [mapPath, Function.comp, e.right_inv]

/-- **Cardinality invariance under cubical equivalence** — the infinite-cardinal
    generalization of `pathCount_invariant`. -/
theorem pathOver_cardinal_invariant_general
    {I : Type*} [CubicalInterval I]
    {X Y : Type u} (e : CubicalEquiv X Y) (a b : X) :
    Cardinal.mk (PathOver (I := I) X a b) =
      Cardinal.mk (PathOver (I := I) Y (e.toFun a) (e.toFun b)) :=
  Cardinal.mk_congr (e.pathEquiv a b)

/-! ### Path cardinal profile -/

/-- The path cardinal profile: cardinal-valued invariant of a path space. -/
def pathCardinalProfile (I : Type*) [CubicalInterval I] (X : Type u) (a b : X) : Cardinal :=
  Cardinal.mk (PathOver (I := I) X a b)

/-- The path cardinal profile is invariant under cubical equivalence. -/
theorem pathCardinalProfile_invariant
    {I : Type*} [CubicalInterval I]
    {X Y : Type u} (e : CubicalEquiv X Y) (a b : X) :
    pathCardinalProfile I X a b =
      pathCardinalProfile I Y (e.toFun a) (e.toFun b) :=
  pathOver_cardinal_invariant_general e a b

/-! ### Translation equivalence -/

/-- Translation by `c` as a cubical equivalence on `ℝ`. -/
def translationEquiv (c : ℝ) : CubicalEquiv ℝ ℝ where
  toFun := (· + c)
  invFun := (· - c)
  left_inv := fun x => by ring
  right_inv := fun y => by ring

/-- Direct equivalence of path spaces under translation. -/
def translationPathEquiv (c a b : ℝ) :
    PathOver (I := ℝ) ℝ a b ≃ PathOver (I := ℝ) ℝ (a + c) (b + c) :=
  (translationEquiv c).pathEquiv a b

/-- Translation preserves the cardinality of path spaces. -/
theorem translation_preserves_pathCardinal (c a b : ℝ) :
    Cardinal.mk (PathOver (I := ℝ) ℝ a b) =
      Cardinal.mk (PathOver (I := ℝ) ℝ (a + c) (b + c)) :=
  Cardinal.mk_congr (translationPathEquiv c a b)

/-- Translation on paths is injective. -/
theorem translatePath_injective (c a b : ℝ) :
    Function.Injective (fun p : PathOver (I := ℝ) ℝ a b =>
      (translationPathEquiv c a b) p) :=
  (translationPathEquiv c a b).injective

/-! ### Scaling equivalence -/

/-- Scaling by a nonzero constant as a cubical equivalence on `ℝ`. -/
def scalingEquiv (c : ℝ) (hc : c ≠ 0) : CubicalEquiv ℝ ℝ where
  toFun := (· * c)
  invFun := (· / c)
  left_inv := fun x => by field_simp
  right_inv := fun y => by field_simp

/-- Scaling preserves path space cardinality. -/
theorem scaling_preserves_pathCardinal (c : ℝ) (hc : c ≠ 0) (a b : ℝ) :
    Cardinal.mk (PathOver (I := ℝ) ℝ a b) =
      Cardinal.mk (PathOver (I := ℝ) ℝ (a * c) (b * c)) :=
  Cardinal.mk_congr ((scalingEquiv c hc).pathEquiv a b)

end CubicalSemantics
end