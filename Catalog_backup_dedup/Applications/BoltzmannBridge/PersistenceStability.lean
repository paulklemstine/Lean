/-
# The Boltzmann Bridge III — Stability and Functoriality of Sublevel Filtrations

This file extends the catalog's higher-dimensional persistence machinery
(`Applications.BoltzmannBridge.HigherPersistence`, which builds
`ASC` abstract simplicial complexes, the sublevel `Filtration` calculus, the
Vietoris–Rips filtration, and `euler_char_full_simplex`) with the two structural
pillars that make persistent homology a *robust* invariant of data:

* **Functoriality.**  The containment relation `ASC.Sub` between complexes is a
  preorder (reflexive and transitive), so the sublevel complexes of a fixed
  filtration assemble into a one-parameter diagram of inclusions — the
  combinatorial skeleton of a *persistence module*.

* **Stability / interleaving.**  If two filtrations have uniformly close weight
  functions (`G.weight σ ≤ F.weight σ + δ`), then their sublevel families are
  `δ`-interleaved: `F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)`.  The
  interleaving bounds compose additively (`stability_compose`), which is the
  triangle inequality underlying the *interleaving / bottleneck distance*.  This
  is the algebraic core of the Cohen-Steiner–Edelsbrunner–Harer stability
  theorem, here proved at the level of the filtration itself.

Lattice compatibility (`sublevelFaces_min`, `VRfaces_min`) records that sublevel
sets turn the `min` of scales into intersection of complexes.

## Main results

* `ASC.Sub_refl`, `ASC.Sub_trans` — `ASC.Sub` is a preorder (persistence functoriality)
* `Filtration.sublevelComplex_sub` — connecting maps of the persistence module
* `Filtration.sublevelFaces_min` — sublevel of a `min` is the intersection
* `Filtration.stability_interleaving` — δ-closeness ⇒ δ-interleaving of sublevels
* `Filtration.stability_compose` — interleavings compose additively (triangle ineq.)
* `Filtration.stability_two_sided` — symmetric closeness ⇒ two-sided interleaving
* `VRfaces_min` — Vietoris–Rips turns `min` of scales into intersection
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence

open Finset BigOperators

namespace BoltzmannBridge

namespace ASC

variable {α : Type*}

-- !-- Reflexivity is `subset_refl` on the face sets. -- !--
/-- `ASC.Sub` is reflexive: every complex contains itself. -/
theorem Sub_refl (K : ASC α) : ASC.Sub K K :=
  Set.Subset.rfl

-- !-- Transitivity is transitivity of `⊆` on face sets; chaining the inclusions
-- !-- realizes the composition of the persistence-module connecting maps. -- !--
/-- `ASC.Sub` is transitive: the inclusions of complexes compose. -/
theorem Sub_trans {K L M : ASC α} (h₁ : ASC.Sub K L) (h₂ : ASC.Sub L M) :
    ASC.Sub K M :=
  Set.Subset.trans h₁ h₂

end ASC

namespace Filtration

variable {α : Type*}

-- !-- The face sets of the two sublevel complexes are literally the sublevel sets,
-- !-- so the containment is exactly `sublevel_mono`. -- !--
/-- **Connecting maps of the persistence module.**  For a fixed filtration, the
sublevel complex at the smaller scale includes into the one at the larger scale. -/
theorem sublevelComplex_sub (F : Filtration α) {t₁ t₂ : ℝ} (h : t₁ ≤ t₂)
    (h₁ : 0 ≤ t₁) (h₂ : 0 ≤ t₂) :
    ASC.Sub (F.sublevelComplex t₁ h₁) (F.sublevelComplex t₂ h₂) :=
  fun _ hσ => le_trans hσ h

-- !-- `weight σ ≤ min t₁ t₂ ↔ weight σ ≤ t₁ ∧ weight σ ≤ t₂` (le_min_iff). -- !--
/-- **Lattice compatibility.**  The sublevel set at the minimum of two scales is
the intersection of the two sublevel sets. -/
theorem sublevelFaces_min (F : Filtration α) (t₁ t₂ : ℝ) :
    F.sublevelFaces (min t₁ t₂) = F.sublevelFaces t₁ ∩ F.sublevelFaces t₂ := by
  ext σ; simp [Filtration.sublevelFaces]

-- !-- From `F.weight σ ≤ t` and `G.weight σ ≤ F.weight σ + δ` we get
-- !-- `G.weight σ ≤ t + δ` by transitivity and monotonicity of `+`. -- !--
/-- **Stability / δ-interleaving.**  If `G` is everywhere born no later than `F`
shifted by `δ`, then every simplex alive in `F` at scale `t` is alive in `G` at
scale `t + δ`.  This is the algebraic heart of persistence stability. -/
theorem stability_interleaving (F G : Filtration α) {δ : ℝ}
    (h : ∀ σ : Finset α, G.weight σ ≤ F.weight σ + δ) (t : ℝ) :
    F.sublevelFaces t ⊆ G.sublevelFaces (t + δ) :=
  fun x hx => le_trans (h x) (by linarith [hx.out])

-- !-- Apply `stability_interleaving F G` to land in `G` at `t+δ`, then
-- !-- `stability_interleaving G H` to land in `H` at `(t+δ)+δ'`. -- !--
/-- **Additivity of interleavings (triangle inequality).**  A `δ`-interleaving
followed by a `δ'`-interleaving is a `(δ + δ')`-interleaving.  This is the
triangle inequality for the interleaving distance on filtrations. -/
theorem stability_compose (F G H : Filtration α) {δ δ' : ℝ}
    (h₁ : ∀ σ : Finset α, G.weight σ ≤ F.weight σ + δ)
    (h₂ : ∀ σ : Finset α, H.weight σ ≤ G.weight σ + δ') (t : ℝ) :
    F.sublevelFaces t ⊆ H.sublevelFaces (t + (δ + δ')) := by
  have hcomp := Set.Subset.trans (stability_interleaving F G h₁ t)
    (stability_interleaving G H h₂ (t + δ))
  rwa [add_assoc] at hcomp

-- !-- Each direction is an instance of `stability_interleaving` after rearranging
-- !-- the symmetric bound `|F.weight σ - G.weight σ| ≤ δ` via `abs_le`. -- !--
/-- **Two-sided stability.**  Uniform closeness of the weights (`|F − G| ≤ δ`)
yields a symmetric `δ`-interleaving of the sublevel families. -/
theorem stability_two_sided (F G : Filtration α) {δ : ℝ}
    (h : ∀ σ : Finset α, |F.weight σ - G.weight σ| ≤ δ) (t : ℝ) :
    F.sublevelFaces t ⊆ G.sublevelFaces (t + δ) ∧
    G.sublevelFaces t ⊆ F.sublevelFaces (t + δ) := by
  refine ⟨stability_interleaving F G (fun σ => ?_) t,
          stability_interleaving G F (fun σ => ?_) t⟩ <;>
    · have := (abs_le.mp (h σ)); linarith [this.1, this.2]

end Filtration

section VR

variable {α : Type*} [PseudoMetricSpace α]

-- !-- `(∀ pair, dist ≤ min ε₁ ε₂) ↔ (∀ pair, dist ≤ ε₁) ∧ (∀ pair, dist ≤ ε₂)`
-- !-- via `le_min_iff`, distributed over the conjunction of quantifiers. -- !--
/-- **Vietoris–Rips lattice compatibility.**  The VR complex at the minimum of
two scales is the intersection of the two VR complexes. -/
theorem VRfaces_min (ε₁ ε₂ : ℝ) :
    (VRfaces (min ε₁ ε₂) : Set (Finset α)) = VRfaces ε₁ ∩ VRfaces ε₂ := by
  ext σ
  simp only [Set.mem_inter_iff, mem_VRfaces, le_min_iff]
  grind

end VR

end BoltzmannBridge