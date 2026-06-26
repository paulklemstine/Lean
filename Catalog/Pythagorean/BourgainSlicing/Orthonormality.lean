import Pythagorean.BourgainSlicing.DiscreteCube

/-!
# Bourgain's Slicing Problem: isotropy as a Pythagorean identity

Building on `Pythagorean.BourgainSlicing.DiscreteCube`, this file recasts the dimension-free
isotropy of the discrete cube `{-1,1}ⁿ` as an **orthonormality / Pythagorean** statement, the
natural bridge to the *Pythagorean* domain of the catalog.

Equip the space of real functions on the cube with the `L²` inner product
`⟨f, g⟩ = E[f · g]`.  The `n` coordinate functions `x ↦ xₖ` then form an **orthonormal system**,
and the second moment of a linear functional `⟨θ, x⟩` is computed by the **Pythagorean theorem**:
`‖∑ₖ θₖ · coordₖ‖² = ∑ₖ θₖ²`.  This is exactly the isotropy identity `E[⟨θ, x⟩²] = ∑ₖ θₖ²`
underlying the dimension-free isotropic constant of the cube, now exhibited as Parseval's identity
for a finite orthonormal family.

## Main results

* `BourgainSlicing.inner_coord` — the coordinate functions are orthonormal:
  `⟨coordₖ, coordₗ⟩ = if k = l then 1 else 0`.
* `BourgainSlicing.normSq_coord` — each coordinate function is a unit vector: `⟨coordₖ, coordₖ⟩ = 1`.
* `BourgainSlicing.pythagoras_inner` — Pythagorean/Parseval identity for the cube:
  `⟨∑ₖ θₖ·coordₖ, ∑ₖ θₖ·coordₖ⟩ = ∑ₖ θₖ²`.

-- !-- Lab Notes -- !--
-- HYPOTHESIS: the "dimension-free isotropic constant" of the cube is, structurally, the
--   statement that its coordinate functions are an orthonormal basis of directions — the
--   slicing second moment is then just Parseval/Pythagoras, with NO cross terms surviving.
-- EXPERIMENT/INSIGHT: defining ⟨f,g⟩ := E[f·g] and reusing `covariance` from DiscreteCube,
--   orthonormality `⟨coordₖ,coordₗ⟩ = δₖₗ` is immediate (`T k l / 2ⁿ`).  The Pythagorean
--   identity then reduces *verbatim* to `E_inner_sq`, confirming that the two viewpoints
--   (probabilistic second moment vs. geometric orthonormality) are the same theorem.
-- INSIGHT: this is the cleanest possible "Pythagorean" footprint of the slicing problem —
--   the inequality direction of the conjecture is, for the cube, an equality of norms.
-/

namespace BourgainSlicing

open Finset

variable {n : ℕ}

/-- The `L²(uniform cube)` inner product `⟨f, g⟩ = E[f · g]`. -/
noncomputable def inner (f g : (Fin n → Bool) → ℝ) : ℝ := E (fun x => f x * g x)

/-- The squared `L²` norm of a function on the cube. -/
noncomputable def normSq (f : (Fin n → Bool) → ℝ) : ℝ := inner f f

/-- **Orthonormality of coordinate functions.** `⟨coordₖ, coordₗ⟩ = δₖₗ`. -/
theorem inner_coord (k l : Fin n) :
    inner (fun x => coord x k) (fun x => coord x l) = if k = l then 1 else 0 := by
  rw [inner, E]
  have hT : (∑ x : Fin n → Bool, coord x k * coord x l) = T k l := rfl
  rw [hT, covariance]
  have h2 : (2 : ℝ) ^ n ≠ 0 := by positivity
  by_cases h : k = l
  · simp [h, h2]
  · simp [h]

/-- Each coordinate function is a unit vector of the inner-product space. -/
theorem normSq_coord (k : Fin n) : normSq (fun x => coord x k) = 1 := by
  rw [normSq, inner_coord]; simp

/-- **Pythagorean / Parseval identity.** For the orthonormal coordinate system, the squared
norm of the linear functional `⟨θ, x⟩ = ∑ₖ θₖ·xₖ` is `∑ₖ θₖ²`.  This is the isotropy identity
behind the dimension-free isotropic constant of the discrete cube. -/
theorem pythagoras_inner (θ : Fin n → ℝ) :
    normSq (fun x => ∑ k, θ k * coord x k) = ∑ k, (θ k) ^ 2 := by
  rw [normSq, inner]
  have : (fun x => (∑ k, θ k * coord x k) * ∑ k, θ k * coord x k)
      = (fun x => (∑ k, θ k * coord x k) ^ 2) := by
    funext x; rw [sq]
  rw [this, E_inner_sq]

/-- The Pythagorean identity, stated directly through the inner product. -/
theorem pythagoras_inner' (θ : Fin n → ℝ) :
    inner (fun x => ∑ k, θ k * coord x k) (fun x => ∑ k, θ k * coord x k)
      = ∑ k, (θ k) ^ 2 :=
  pythagoras_inner θ

end BourgainSlicing