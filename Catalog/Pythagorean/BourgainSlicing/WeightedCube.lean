import Pythagorean.BourgainSlicing.DiscreteCube

/-!
# Bourgain's Slicing Problem: weighted cubes (boxes) and a thick-section bound

Boxes (rectangular parallelepipeds) are the affine images of the cube, and a basic theme of
the slicing problem is that affine images of a body share the same (normalized) section
behaviour.  Here we model a box by the **weighted discrete cube**: the point `x ∈ {-1,1}ⁿ`
carries coordinate values `aₖ·xₖ` for a weight vector `a : Fin n → ℝ`.

We prove the weighted second-moment (isotropy) formula
`E[(∑ₖ θₖ·aₖ·xₖ)²] = ∑ₖ aₖ²·θₖ²`,
which exhibits the covariance of the box as the diagonal matrix `diag(a₁², …, aₙ²)`, and a
genuine **thick-section existence** statement: some coordinate direction realises a second
moment at least the *average* of the `aₖ²`.  This is the discrete analogue of "there is a
hyperplane section that is not too thin" — the existence half of the slicing problem.

## Main results

* `BourgainSlicing.E_weighted_sq` — `E[(∑ₖ θₖ·aₖ·xₖ)²] = ∑ₖ aₖ²·θₖ²` (diagonal covariance).
* `BourgainSlicing.E_weighted_coord_sq` — the `k`-th coordinate direction has second moment `aₖ²`.
* `BourgainSlicing.exists_thick_section` — for `n > 0` there is a coordinate `k` with
  `n · aₖ² ≥ ∑ⱼ aⱼ²`, i.e. a direction whose second moment is at least the average.

-- !-- Lab Notes -- !--
-- HYPOTHESIS: replacing the ±1 cube by a ±aₖ box only rescales each coordinate, so the
--   second-moment formula should pick up the factor aₖ² coordinate-wise, with the cross
--   terms still annihilated by the same sign-flip involution.
-- EXPERIMENT/INSIGHT: the weighted identity follows from `E_inner_sq` by the substitution
--   θ ↦ (k ↦ θ k * a k); no new combinatorics needed.  This is the discrete shadow of the
--   affine invariance of the isotropic constant (every box has the cube's isotropic constant).
-- INSIGHT: the thick-section bound is the pigeonhole "max ≥ average" — for the slicing problem
--   this is the easy existence direction; the hard direction (a uniform LOWER bound on the
--   THINNEST section) is exactly Bourgain's conjecture and is recorded in FUTURE_DIRECTIONS.
-/

namespace BourgainSlicing

open Finset

variable {n : ℕ}

/-- **Weighted isotropy.** For weights `a` and coefficients `θ`, the second moment of the
linear functional `∑ₖ θₖ·aₖ·xₖ` over the box equals `∑ₖ aₖ²·θₖ²`.  Hence the covariance of
the box is the diagonal matrix `diag(a₁², …, aₙ²)`. -/
theorem E_weighted_sq (a θ : Fin n → ℝ) :
    E (fun x => (∑ k, θ k * (a k * coord x k)) ^ 2) = ∑ k, (a k) ^ 2 * (θ k) ^ 2 := by
  have hrw : (fun x => (∑ k, θ k * (a k * coord x k)) ^ 2)
      = (fun x => (∑ k, (θ k * a k) * coord x k) ^ 2) := by
    funext x
    refine congrArg (· ^ 2) (Finset.sum_congr rfl (fun k _ => by ring))
  rw [hrw, E_inner_sq]
  exact Finset.sum_congr rfl (fun k _ => by ring)

/-- Uniform expectation of a constant function is that constant. -/
theorem E_const (c : ℝ) : E (fun _ : Fin n → Bool => c) = c := by
  rw [E, Finset.sum_const, card_cube, nsmul_eq_mul]
  have h2 : (2 : ℝ) ^ n ≠ 0 := by positivity
  push_cast
  field_simp

/-- The `k`-th coordinate direction of the box has second moment exactly `aₖ²`. -/
theorem E_weighted_coord_sq (a : Fin n → ℝ) (k : Fin n) :
    E (fun x => (a k * coord x k) ^ 2) = (a k) ^ 2 := by
  have hconst : (fun x => (a k * coord x k) ^ 2) = (fun _ : Fin n → Bool => (a k) ^ 2) := by
    funext x
    have h1 : coord x k * coord x k = 1 := sgn_mul_self (x k)
    have : (a k * coord x k) ^ 2 = (a k) ^ 2 * (coord x k * coord x k) := by ring
    rw [this, h1, mul_one]
  rw [hconst, E_const]

/-- **A thick section exists.** For a nonempty set of directions there is a coordinate `k`
whose second moment `aₖ²` is at least the average `(∑ⱼ aⱼ²)/n`; equivalently `n·aₖ² ≥ ∑ⱼ aⱼ²`.
This is the (easy) existence half of the slicing problem: some hyperplane section is not thin. -/
theorem exists_thick_section (a : Fin n → ℝ) (hn : 0 < n) :
    ∃ k : Fin n, (n : ℝ) * (a k) ^ 2 ≥ ∑ j, (a j) ^ 2 := by
  have hne : (Finset.univ : Finset (Fin n)).Nonempty := by
    simpa [Finset.univ_nonempty_iff] using (Fin.pos_iff_nonempty.mp hn)
  obtain ⟨k, _, hk⟩ := Finset.exists_max_image Finset.univ (fun j => (a j) ^ 2) hne
  refine ⟨k, ?_⟩
  calc ∑ j, (a j) ^ 2 ≤ ∑ _j : Fin n, (a k) ^ 2 :=
        Finset.sum_le_sum (fun j _ => hk j (Finset.mem_univ j))
    _ = (n : ℝ) * (a k) ^ 2 := by
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin]; ring

end BourgainSlicing