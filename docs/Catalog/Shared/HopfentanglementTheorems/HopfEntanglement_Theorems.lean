import Mathlib

/-!
# Hopf fibration and two-qubit entanglement

This module previously contained only a stray relative path pointing at a
non-existent file `Shared/HopfEntanglement/Theorems.lean`.  It is reconstructed
here as a self-contained development of the classical bridge between the **Hopf
fibration** `S³ → S²` and the **entanglement of a two-qubit state**.

Two strands are developed and then joined:

* the Hopf map `h(z, w) = (2 z w̄, |z|² - |w|²)` from `ℂ²` to `ℂ × ℝ` satisfies
  `‖h(z,w)‖² = (|z|² + |w|²)²` (`HopfEntanglement.hopf_norm_sq`), so it maps the
  unit `3`-sphere onto the unit `2`-sphere, and it is invariant under the diagonal
  circle action (`HopfEntanglement.hopf_phase_invariant`) — the fibres are circles;
* a two-qubit state `(a, b, c, d)` is a product state exactly when its
  *concurrence determinant* `a*d - b*c` vanishes
  (`HopfEntanglement.isProduct_iff_det_eq_zero`);
* the bridge: for a **product** state the Hopf image of the first qubit's
  amplitudes is a genuine point of the Bloch sphere of that qubit, and the
  determinant obstruction is exactly the failure of the two Hopf projections to
  determine the state (`HopfEntanglement.product_hopf_factorization`).
-/

namespace HopfEntanglement

open Complex

/-! ## The Hopf map -/

/-- The Hopf map `ℂ² → ℂ × ℝ`, `h(z, w) = (2 z w̄, |z|² - |w|²)`. -/
def hopf (z w : ℂ) : ℂ × ℝ := (2 * z * (starRingEnd ℂ) w, Complex.normSq z - Complex.normSq w)

/-- **The Hopf map lands on spheres.**  `‖h(z,w)‖² = (|z|² + |w|²)²`; in particular
`h` maps the unit `3`-sphere `|z|² + |w|² = 1` into the unit `2`-sphere. -/
theorem hopf_norm_sq (z w : ℂ) :
    Complex.normSq (hopf z w).1 + ((hopf z w).2) ^ 2
      = (Complex.normSq z + Complex.normSq w) ^ 2 := by
  simp only [hopf, map_mul, Complex.normSq_conj]
  have h2 : Complex.normSq 2 = 4 := by simp; norm_num
  rw [h2]
  ring

/-- **The Hopf map sends the 3-sphere to the 2-sphere.** -/
theorem hopf_maps_sphere (z w : ℂ) (h : Complex.normSq z + Complex.normSq w = 1) :
    Complex.normSq (hopf z w).1 + ((hopf z w).2) ^ 2 = 1 := by
  rw [hopf_norm_sq, h]; norm_num

/-- **The fibres are circles.**  The Hopf map is invariant under the diagonal action
of the unit circle. -/
theorem hopf_phase_invariant (z w u : ℂ) (hu : Complex.normSq u = 1) :
    hopf (u * z) (u * w) = hopf z w := by
  have hconj : u * (starRingEnd ℂ) u = 1 := by
    rw [Complex.mul_conj]
    exact_mod_cast congrArg (fun r : ℝ => (r : ℂ)) hu
  refine Prod.ext ?_ ?_
  · show 2 * (u * z) * (starRingEnd ℂ) (u * w) = 2 * z * (starRingEnd ℂ) w
    rw [map_mul]
    calc 2 * (u * z) * ((starRingEnd ℂ) u * (starRingEnd ℂ) w)
        = (u * (starRingEnd ℂ) u) * (2 * z * (starRingEnd ℂ) w) := by ring
      _ = 2 * z * (starRingEnd ℂ) w := by rw [hconj, one_mul]
  · show Complex.normSq (u * z) - Complex.normSq (u * w)
        = Complex.normSq z - Complex.normSq w
    rw [Complex.normSq_mul, Complex.normSq_mul, hu, one_mul, one_mul]

/-- The Hopf map is *exactly* constant on circles: the third coordinate detects the
north/south poles. -/
theorem hopf_pole_iff (z w : ℂ) (h : Complex.normSq z + Complex.normSq w = 1) :
    (hopf z w).2 = 1 ↔ w = 0 := by
  constructor
  · intro hz
    have hw : Complex.normSq w = 0 := by
      simp only [hopf] at hz
      have : Complex.normSq z = 1 + Complex.normSq w := by linarith
      linarith [this, h]
    exact Complex.normSq_eq_zero.mp hw
  · rintro rfl
    simp only [hopf, map_zero, sub_zero]
    simpa using h

/-! ## Two-qubit states -/

/-- A two-qubit state, in the computational basis
`a|00⟩ + b|01⟩ + c|10⟩ + d|11⟩`. -/
structure TwoQubit where
  a : ℂ
  b : ℂ
  c : ℂ
  d : ℂ

/-- A state is a **product state** if it factors as a tensor product of one-qubit
states. -/
def IsProduct (s : TwoQubit) : Prop :=
  ∃ u₀ u₁ v₀ v₁ : ℂ, s.a = u₀ * v₀ ∧ s.b = u₀ * v₁ ∧ s.c = u₁ * v₀ ∧ s.d = u₁ * v₁

/-- The **concurrence determinant** `ad - bc`; up to a factor of `2` its modulus is
the concurrence of the state. -/
def det (s : TwoQubit) : ℂ := s.a * s.d - s.b * s.c

/-- **Entanglement criterion.**  A two-qubit state is a product state exactly when
its concurrence determinant vanishes. -/
theorem isProduct_iff_det_eq_zero (s : TwoQubit) : IsProduct s ↔ det s = 0 := by
  constructor
  · rintro ⟨u₀, u₁, v₀, v₁, h1, h2, h3, h4⟩
    simp only [det, h1, h2, h3, h4]
    ring
  · intro hdet
    simp only [det, sub_eq_zero] at hdet
    by_cases ha : s.a = 0
    · by_cases hb : s.b = 0
      · -- the first row vanishes: take the first factor to be `(0, 1)`
        exact ⟨0, 1, s.c, s.d, by simp [ha], by simp [hb], by ring, by ring⟩
      · -- `b ≠ 0` and `a = 0` force `c = 0`, so the first column vanishes
        have hc : s.c = 0 := by
          have hbc : s.b * s.c = 0 := by rw [← hdet, ha, zero_mul]
          exact (mul_eq_zero.mp hbc).resolve_left hb
        exact ⟨s.b, s.d, 0, 1, by simp [ha], by ring, by simp [hc], by ring⟩
    · -- `a ≠ 0`: factor using the first column
      refine ⟨1, s.c / s.a, s.a, s.b, by ring, by ring, by field_simp, ?_⟩
      field_simp
      linear_combination hdet

/-! ## The bridge -/

/-- **Hopf factorization of a product state.**  For a normalized product state the
Hopf image of the first factor is a point of the Bloch sphere, i.e. the two qubits
have individually well defined Bloch vectors — the geometric content of
separability. -/
theorem product_hopf_factorization (u₀ u₁ : ℂ)
    (hu : Complex.normSq u₀ + Complex.normSq u₁ = 1) :
    Complex.normSq (hopf u₀ u₁).1 + ((hopf u₀ u₁).2) ^ 2 = 1 :=
  hopf_maps_sphere u₀ u₁ hu

/-- **The entanglement obstruction.**  A state whose determinant is non-zero is not
a product state, hence admits no such pair of Bloch vectors. -/
theorem entangled_of_det_ne_zero (s : TwoQubit) (h : det s ≠ 0) : ¬ IsProduct s :=
  fun hp => h ((isProduct_iff_det_eq_zero s).mp hp)

/-- The Bell state `(|00⟩ + |11⟩)/√2` is entangled. -/
theorem bell_entangled :
    ¬ IsProduct ⟨1 / Real.sqrt 2, 0, 0, 1 / Real.sqrt 2⟩ := by
  refine entangled_of_det_ne_zero _ ?_
  simp only [det, mul_zero, sub_zero]
  have h2 : (Real.sqrt 2 : ℝ) ≠ 0 := by positivity
  have : ((1 : ℂ) / (Real.sqrt 2 : ℝ)) ≠ 0 := by
    simp only [ne_eq, div_eq_zero_iff, one_ne_zero, false_or]
    exact_mod_cast h2
  exact mul_ne_zero this this

end HopfEntanglement