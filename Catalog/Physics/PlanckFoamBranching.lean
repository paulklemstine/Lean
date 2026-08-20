import Physics.PlanckFoamStochastic

/-!
# Branching limits in the Planck foam over the line

This file exhibits the physical signature of Wheeler foam concretely: a single
sequence of ordinary spacetime points approaching a Planck site converges to
**two different limit points** of the foam.  Thus "where the fluctuation is
heading" is not determined by the trajectory: the limit geometry bifurcates.

## Main results

* `PlanckFoam.Stochastic.notMem_siteSet_of_lt` — points strictly between two
  Planck sites are not branch points (a spacing estimate for the lattice).
* `PlanckFoam.Stochastic.exists_seq_two_limits` — over an excited Planck site
  there is a sequence in the foam with two distinct limits.  This gives a second,
  constructive proof that the foam is not Hausdorff.
* `PlanckFoam.Stochastic.lineFoam_pathConnectedSpace` — the foam is nevertheless
  path connected: the branching does not disconnect spacetime.
-/

open Set Filter Topology

namespace PlanckFoam
namespace Stochastic

variable {N : ℕ}

/-- A point strictly between the Planck site `ℓ * k` and the next site is never
a branch point. -/
theorem notMem_siteSet_of_lt {ℓ : ℝ} (hℓ : 0 < ℓ) (A : Finset (Fin N)) (k : ℕ) {t : ℝ}
    (ht0 : 0 < t) (ht1 : t < ℓ) : ℓ * k + t ∉ siteSet ℓ A := by
  rintro ⟨m, -, hm⟩
  have hmk : ℓ * (m : ℕ) - ℓ * k = t := by linarith [hm]
  have hlt : ((k : ℝ)) < (m : ℕ) := by
    nlinarith [hmk, ht0]
  have hlt' : ((m : ℕ) : ℝ) < (k : ℝ) + 1 := by
    nlinarith [hmk, ht1]
  have h1 : k < (m : ℕ) := by exact_mod_cast hlt
  have h2 : ((m : ℕ) : ℕ) < k + 1 := by exact_mod_cast hlt'
  omega

/-- **Two limits for one sequence.**  Over an excited Planck site, the sequence
of foam points obtained by approaching the site from the right converges both to
the point on sheet `false` and to the point on sheet `true`; these are distinct.
Wheeler's foam therefore has genuinely ambiguous limit geometries. -/
theorem exists_seq_two_limits {ℓ : ℝ} (hℓ : 0 < ℓ) {A : Finset (Fin N)} {k : Fin N}
    (hk : k ∈ A) :
    ∃ u : ℕ → LineFoam ℓ A,
      Tendsto u atTop (𝓝 (sheet (siteSet ℓ A) false (ℓ * (k : ℕ)))) ∧
      Tendsto u atTop (𝓝 (sheet (siteSet ℓ A) true (ℓ * (k : ℕ)))) ∧
      sheet (siteSet ℓ A) false (ℓ * (k : ℕ)) ≠ sheet (siteSet ℓ A) true (ℓ * (k : ℕ)) := by
  set S := siteSet ℓ A with hS
  set x : ℝ := ℓ * (k : ℕ) with hx
  -- the approaching points of the base line
  set y : ℕ → ℝ := fun n => x + ℓ / (n + 2) with hy
  have hstep : ∀ n : ℕ, y n ∉ S := by
    intro n
    have hpos : 0 < ℓ / ((n : ℝ) + 2) := by positivity
    have hlt : ℓ / ((n : ℝ) + 2) < ℓ := by
      rw [div_lt_iff₀ (by positivity)]
      nlinarith [Nat.cast_nonneg (α := ℝ) n]
    exact notMem_siteSet_of_lt hℓ A (k : ℕ) hpos hlt
  have hyx : Tendsto y atTop (𝓝 x) := by
    have h2 : Tendsto (fun n : ℕ => ((n : ℝ) + 2)) atTop atTop :=
      tendsto_atTop_add_const_right _ 2 tendsto_natCast_atTop_atTop
    have h3 : Tendsto (fun n : ℕ => ((n : ℝ) + 2)⁻¹) atTop (𝓝 0) := h2.inv_tendsto_atTop
    have h4 : Tendsto (fun n : ℕ => ℓ * ((n : ℝ) + 2)⁻¹) atTop (𝓝 0) := by
      simpa using h3.const_mul ℓ
    have := h4.const_add x
    simpa [hy, div_eq_mul_inv] using this
  refine ⟨fun n => sheet S false (y n), ?_, ?_, ?_⟩
  · exact ((continuous_sheet (S := S) false).tendsto x).comp hyx
  · have hEq : (fun n => sheet S false (y n)) = fun n => sheet S true (y n) := by
      funext n
      exact sheet_eq_sheet_of_notMem (hstep n)
    rw [hEq]
    exact ((continuous_sheet (S := S) true).tendsto x).comp hyx
  · refine sheet_ne_sheet (by simp) ?_
    exact ⟨k, hk, rfl⟩

/-- A second, constructive proof that the Planck foam over the line is not
Hausdorff as soon as one Planck cell is excited. -/
theorem not_t2Space_of_nonempty {ℓ : ℝ} (hℓ : 0 < ℓ) {A : Finset (Fin N)} (hA : A.Nonempty) :
    ¬ T2Space (LineFoam ℓ A) := by
  obtain ⟨k, hk⟩ := hA
  intro h
  obtain ⟨u, h1, h2, hne⟩ := exists_seq_two_limits hℓ hk
  exact hne (tendsto_nhds_unique h1 h2)

/-- Branching does not tear spacetime apart: the foam is path connected. -/
theorem lineFoam_pathConnectedSpace (ℓ : ℝ) (A : Finset (Fin N)) :
    PathConnectedSpace (LineFoam ℓ A) := by
  obtain ⟨x₀, hx₀⟩ := ((siteSet_finite ℓ A).infinite_compl).nonempty
  rw [pathConnectedSpace_iff_univ]
  have hcover : (univ : Set (LineFoam ℓ A))
      = range (sheet (siteSet ℓ A) false) ∪ range (sheet (siteSet ℓ A) true) := by
    ext u
    obtain ⟨b, x, rfl⟩ := exists_sheet u
    cases b
    · exact iff_of_true (mem_univ _) (Or.inl ⟨x, rfl⟩)
    · exact iff_of_true (mem_univ _) (Or.inr ⟨x, rfl⟩)
  rw [hcover]
  refine IsPathConnected.union (isPathConnected_range (continuous_sheet _))
    (isPathConnected_range (continuous_sheet _)) ⟨sheet (siteSet ℓ A) false x₀, ⟨x₀, rfl⟩, ?_⟩
  exact ⟨x₀, (sheet_eq_sheet_of_notMem hx₀).symm⟩

end Stochastic
end PlanckFoam