import Mathlib

/-!
# A modular orbit in the Poincaré disk

We study the orbit obtained by translating `i` by integers in the upper half-plane and
then applying the Cayley transform `w ↦ (w-i)/(w+i)`.  Its `n`th point is
`n/(n+2i)`.  The results below give exact arithmetic control of this orbit: it lies in
the open disk, is a faithful copy of the integers, and escapes every smaller concentric
disk, converging radially to the ideal boundary.
-/

namespace HyperbolicNumberTheory

open Complex Filter Topology

/-- The Cayley image of `n + i`, where translation by `n` is an element of the modular
translation subgroup. -/
noncomputable def modularOrbit (n : ℤ) : ℂ :=
  (n : ℂ) / ((n : ℂ) + 2 * I)

/-
Exact squared Euclidean radius of a modular orbit point.
-/
theorem normSq_modularOrbit (n : ℤ) :
    normSq (modularOrbit n) = (n : ℝ) ^ 2 / ((n : ℝ) ^ 2 + 4) := by
  unfold modularOrbit;
  norm_num [ Complex.normSq, sq ]

/-
Every translated integer point maps strictly inside the Poincaré disk.
-/
theorem modularOrbit_mem_disk (n : ℤ) : ‖modularOrbit n‖ < 1 := by
  convert Real.sqrt_lt' ?_ |>.2 ?_;
  · norm_num;
  · rw [ normSq_modularOrbit ] ; rw [ div_lt_iff₀ ] <;> nlinarith

/-
The Cayley-transformed modular orbit remembers the integer index faithfully.
-/
theorem modularOrbit_injective : Function.Injective modularOrbit := by
  intro m n hmn
  unfold modularOrbit at hmn
  have h_eq : (m * ((n : ℂ) + 2 * I)) = (n * ((m : ℂ) + 2 * I)) := by
    rwa [ div_eq_div_iff ] at hmn <;> norm_num [ Complex.ext_iff ];
  norm_num [ Complex.ext_iff ] at h_eq ; norm_cast at h_eq ; linarith

/-
The exact deficit of the squared radius from the ideal boundary.
-/
theorem boundary_defect (n : ℤ) :
    1 - normSq (modularOrbit n) = 4 / ((n : ℝ) ^ 2 + 4) := by
  rw [ normSq_modularOrbit, one_sub_div ] <;> ring ; positivity

/-
Along the positive translation ray, the squared radius tends to the boundary value `1`.
-/
theorem normSq_modularOrbit_tendsto :
    Tendsto (fun n : ℕ => normSq (modularOrbit (n : ℤ))) atTop (𝓝 1) := by
  norm_num [ Complex.normSq, modularOrbit ];
  convert tendsto_natCast_div_add_atTop ( 4 : ℝ ) |> Filter.Tendsto.comp <| Filter.tendsto_pow_atTop ( show 2 ≠ 0 by norm_num ) using 2 ; norm_num ; ring

/-
Consequently, the Euclidean norms themselves tend to the ideal boundary.
-/
theorem norm_modularOrbit_tendsto :
    Tendsto (fun n : ℕ => ‖modularOrbit (n : ℤ)‖) atTop (𝓝 1) := by
  convert Tendsto.sqrt ( normSq_modularOrbit_tendsto ) using 2;
  norm_num

/-
Radial order on the orbit is exactly order by the square of the integer index.
-/
theorem normSq_modularOrbit_le_iff (m n : ℤ) :
    normSq (modularOrbit m) ≤ normSq (modularOrbit n) ↔
      (m : ℝ) ^ 2 ≤ (n : ℝ) ^ 2 := by
  rw [ normSq_modularOrbit, normSq_modularOrbit ];
  rw [ div_le_div_iff₀ ] <;> try positivity;
  constructor <;> intro h <;> linarith

/-
Thus a symmetric finite interval of integers is exactly the part of the orbit cut
out by the Euclidean radius of its endpoint.
-/
theorem orbit_closed_disk_iff (n : ℤ) (N : ℕ) :
    normSq (modularOrbit n) ≤ normSq (modularOrbit (N : ℤ)) ↔
      n.natAbs ≤ N := by
  -- Apply the radial-order lemma to rewrite the inequality.
  rw [normSq_modularOrbit_le_iff];
  norm_cast ; norm_num [ ← sq, Int.natAbs_pow ];
  exact ⟨ fun h => by nlinarith [ abs_mul_abs_self n ], fun h => by nlinarith [ abs_le.mp ( show |n| ≤ N by linarith ) ] ⟩

/-
The modular orbit is symmetric under reflection across the real axis.
-/
theorem modularOrbit_neg (n : ℤ) :
    modularOrbit (-n) = star (modularOrbit n) := by
  unfold modularOrbit;
  simp +zetaDelta at *;
  rw [ ← neg_div_neg_eq ] ; ring

/-
Exact lattice-point count in the orbit disk cut out by the `N`th point.  This is
the elementary counting law underlying this one-dimensional modular cusp orbit.
-/
theorem card_orbit_closed_disk (N : ℕ) :
    Finset.card (Finset.Icc (-(N : ℤ)) (N : ℤ)) = 2 * N + 1 := by
  norm_num [ two_mul, add_assoc ];
  grind

/-
The index interval in the counting theorem is precisely the radial cutoff set.
-/
theorem mem_index_interval_iff_disk (n : ℤ) (N : ℕ) :
    n ∈ Finset.Icc (-(N : ℤ)) (N : ℤ) ↔
      normSq (modularOrbit n) ≤ normSq (modularOrbit (N : ℤ)) := by
  convert orbit_closed_disk_iff n N |> Iff.symm using 1;
  grind +qlia

/-
There are infinitely many distinct modular-orbit points in the open disk.
-/
theorem infinite_modularOrbit_range : Set.Infinite (Set.range modularOrbit) := by
  exact Set.infinite_range_of_injective modularOrbit_injective

/-
The exact index count is also the exact count of distinct geometric orbit points.
-/
theorem card_orbit_points (N : ℕ) :
    Finset.card ((Finset.Icc (-(N : ℤ)) (N : ℤ)).image modularOrbit) = 2 * N + 1 := by
  rw [ Finset.card_image_of_injective _ ( modularOrbit_injective ) ] ; norm_num [ two_mul, add_assoc ] ;
  grind

/-
Kernel-checked small cases used in `ComputationalEvidence.md`.
-/
theorem first_radii :
    normSq (modularOrbit 0) = 0 ∧
    normSq (modularOrbit 1) = (1 : ℝ) / 5 ∧
    normSq (modularOrbit 2) = (1 : ℝ) / 2 ∧
    normSq (modularOrbit 3) = (9 : ℝ) / 13 := by
  norm_num [ Complex.normSq, Complex.div_re, Complex.div_im, modularOrbit ]

end HyperbolicNumberTheory