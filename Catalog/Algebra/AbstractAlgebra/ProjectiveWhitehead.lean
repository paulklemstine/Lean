/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Projective abelian groups are Whitehead groups

An abelian group `A` is a **Whitehead group** when every extension of `A` by `ℤ`
splits, i.e. for every short exact sequence
  `0 → ℤ →ⁱ G →ᵖ A → 0`
of abelian groups there is a section `s : A → G` of `p` (`p ∘ s = id`).
Equivalently `Ext¹(A, ℤ) = 0`.

The classical *easy half* of the Whitehead problem says that free abelian groups
are Whitehead groups.  Here we prove the slightly more conceptual statement that
every **projective** abelian group is a Whitehead group, and crucially we do so
*without* invoking the structure theorem (projective `ℤ`-module ⟹ free).  Instead
we use the **lifting property** that characterises projectivity: any surjection
onto a projective module admits a section.  Specializing the surjection to the
extension map `p` yields the required splitting directly.

To keep the development free of circular dependencies on freeness, the supporting
facts are organized around *torsion* rather than bases:

* `Module.IsTorsionFree.of_projective_int` — a projective `ℤ`-module is
  torsion-free.  This is the "torsion-free argument" replacing freeness; it is
  proved by exhibiting the projective module as a submodule of the free module
  `A →₀ ℤ` (which is torsion-free) via the splitting of the projective
  presentation.
* `not_isWhiteheadGroup_zmod` — the **torsion obstruction**: for `n ≥ 2` the
  torsion group `ZMod n` is *not* a Whitehead group, witnessed by the explicit
  non-split extension `0 → ℤ →ˣⁿ ℤ → ZMod n → 0`.  This mirrors the catalog
  torsion-obstruction results (cf. `Catalog/Pythagorean/SNFObstruction/Basic.lean`
  and `Catalog/Pythagorean/PrimewiseTorsionStability.lean`), where torsion in the
  cokernel is exactly what obstructs splitting, and shows torsion-freeness is a
  genuine necessary condition.

## Main results

* `isWhiteheadGroup_of_projective` — projective abelian groups are Whitehead groups.
* `Module.IsTorsionFree.of_projective_int` — projective `ℤ`-modules are torsion-free.
* `not_isWhiteheadGroup_zmod` — `ZMod n` (`n ≥ 2`) is not a Whitehead group.
-/
import Mathlib

namespace ProjectiveWhitehead

open Module LinearMap

/-- A `ℤ`-module (abelian group) `A` is a **Whitehead group** if every extension
of `A` by `ℤ` splits: for every abelian group `G` together with an injection
`i : ℤ → G` and a surjection `p : G → A` whose range/kernel make
`0 → ℤ → G → A → 0` exact, the projection `p` admits a `ℤ`-linear section. -/
def IsWhiteheadGroup (A : Type u) [AddCommGroup A] : Prop :=
  ∀ {G : Type u} [AddCommGroup G] (i : ℤ →ₗ[ℤ] G) (p : G →ₗ[ℤ] A),
    Function.Injective i → Function.Surjective p →
    LinearMap.range i = LinearMap.ker p →
    ∃ s : A →ₗ[ℤ] G, p ∘ₗ s = LinearMap.id

/-- A projective `ℤ`-module is torsion-free.  Proved without the structure theorem:
the projective presentation splits, embedding `A` `ℤ`-linearly into the torsion-free
free module `A →₀ ℤ`. -/
theorem Module.IsTorsionFree.of_projective_int
    (A : Type*) [AddCommGroup A] [Module.Projective ℤ A] :
    Module.IsTorsionFree ℤ A := by
  obtain ⟨s, hs⟩ := (Module.projective_def (R := ℤ) (P := A)).mp inferInstance
  exact Function.Injective.moduleIsTorsionFree (N := A →₀ ℤ) s hs.injective
    (by intro r m; simp)

/-
**Projective abelian groups are Whitehead groups.**

Given an extension `0 → ℤ →ⁱ G →ᵖ A → 0` with `A` projective, the projection `p`
is a surjection onto a projective module, so the lifting property of projectivity
(`Module.projective_lifting_property`) produces a section `s : A → G` with
`p ∘ s = id`.  No appeal to freeness of `A` is made.
-/
theorem isWhiteheadGroup_of_projective
    (A : Type u) [AddCommGroup A] [Module.Projective ℤ A] :
    IsWhiteheadGroup A := by
  intro G _ i p _hi hp _he
  exact Module.projective_lifting_property p LinearMap.id hp

/-
**Torsion obstruction.**  For `n ≥ 2`, the torsion group `ZMod n` is not a
Whitehead group: the extension `0 → ℤ →ˣⁿ ℤ → ZMod n → 0` (multiplication by `n`
followed by reduction mod `n`) does not split, because every `ℤ`-linear map
`ZMod n → ℤ` is zero (as `ℤ` is torsion-free).  This shows torsion-freeness is a
genuine necessary condition for being a Whitehead group.
-/
theorem not_isWhiteheadGroup_zmod (n : ℕ) (hn : 2 ≤ n) :
    ¬ IsWhiteheadGroup (ZMod n) := by
  by_contra h;
  obtain ⟨ s, hs ⟩ := h ( LinearMap.mulLeft ℤ ( n : ℤ ) ) ( AddMonoidHom.toIntLinearMap ( Int.castAddHom ( ZMod n ) ) ) ( by
    exact fun x y hxy => mul_left_cancel₀ ( by positivity ) hxy ) ( by
    exact ZMod.intCast_surjective ) ( by
    ext x;
    simp +decide [ AddSubgroup.toIntSubmodule ];
    rw [ ZMod.intCast_zmod_eq_zero_iff_dvd ];
    exact ⟨ fun ⟨ y, hy ⟩ => ⟨ y, hy ▸ by ring ⟩, fun ⟨ y, hy ⟩ => ⟨ y, hy ▸ by ring ⟩ ⟩ );
  -- Since $s$ is a linear map from $ZMod n$ to $\mathbb{Z}$, and $ZMod n$ is torsion, $s$ must be the zero map.
  have hs_zero : s = 0 := by
    ext x;
    have := s.map_smul ( n : ℤ ) x; simp_all +decide;
    exact this.resolve_left ( by positivity );
  replace hs := congr_arg ( fun f => f 1 ) hs ; simp_all +decide;
  rcases n with ( _ | _ | n ) <;> cases hs ; contradiction

end ProjectiveWhitehead