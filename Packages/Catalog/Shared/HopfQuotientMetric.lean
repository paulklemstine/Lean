import Mathlib
import Shared.HopfFibreQuantitativeRigidity

/-!
# The circle-quotient metric on the unit sphere of a complex inner product space

The sharp stability results of `Shared.HopfFibreQuantitativeRigidity` are special
to `ℂ²` only in their *statement*: the quantity that controls them,

  `phaseDist p q = √(2 - 2‖⟪p, q⟫‖)`  (`= min_{|u| = 1} ‖p - u • q‖`),

makes sense on the unit sphere of any complex inner product space, where it is the
distance in the quotient by the diagonal circle action — the chordal
Fubini–Study distance of the corresponding complex projective space.

This file develops that general theory:

* `phaseDist_le_norm_sub` / `exists_phase_norm_sub_eq`: `phaseDist` is exactly the
  minimum of `‖p - u • q‖` over unit phases, and the minimum is attained;
* `phaseDist_triangle`: it satisfies the triangle inequality, so the quotient is a
  genuine metric space (equality-case rigidity is `phaseDist_eq_zero_iff`);
* `phaseDistSq_mul_identity`: the exact identity
  `m (4 - m) = 2 (2 - 2‖⟪p,q⟫‖²)` with `m = phaseDist²`, which in `ℂ²` is the
  Hopf identity `hopfDistSq = m (4 - m)`;
* `phaseDist_sq_eq_fibreDistSq`: the general theory really does specialize to the
  concrete `ℂ²` computations of the previous file.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):
The `ℂ²` identity should be an artefact of a dimension-free statement about the
Hermitian pairing, and the phase-minimized distance should be a metric on the
projective quotient in any dimension.

Experiment (Experimenter):
Expanding `‖p - u • q‖² = 2 - 2 Re(u ⟪p,q⟫)` and optimizing over the unit circle
gives `min = 2 - 2‖⟪p,q⟫‖`, attained at `u = conj⟪p,q⟫/‖⟪p,q⟫‖` (any `u` when the
pairing vanishes).  Composing optimal phases for `(p,q)` and `(q,r)` gives the
triangle inequality with the *product* phase.

Analysis (Analyst):
Nothing in the argument uses the dimension, so the `ℂ²` results are the two-
dimensional shadow of a general fact; what is genuinely two-dimensional is only
the identification of the quotient with the round two-sphere via the Hopf map.
The identity `m (4 - m) = 2 (2 - 2 t²)`, `t = ‖⟪p,q⟫‖`, is the dimension-free
core.

Critique (Critic):
`phaseDist` is defined by a closed formula rather than as an infimum, so the two
theorems `phaseDist_le_norm_sub` and `exists_phase_norm_sub_eq` are exactly what
justifies calling it a distance to the circle orbit; without them the definition
would be unmotivated.  The triangle inequality is proved from those two, not
assumed.  All statements carry the unit-vector hypotheses they need.

Synthesis (Principal Investigator):
The Hopf stability phenomenon is a statement about the Cauchy–Schwarz defect of a
Hermitian pairing; the `ℂ²` geometry only supplies a concrete model of the
quotient.
-- !-- Lab Notes -- !--
-/

open ComplexConjugate RCLike

namespace HopfQuotient

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- The distance from `p` to the circle orbit of `q`, for unit vectors. -/
noncomputable def phaseDist (p q : E) : ℝ := Real.sqrt (2 - 2 * ‖(inner ℂ p q : ℂ)‖)

/-- Basic expansion of the distance to a phase rotation of `q`. -/
theorem norm_sub_smul_sq (p q : E) (u : ℂ) (hp : ‖p‖ = 1) (hq : ‖q‖ = 1) (hu : ‖u‖ = 1) :
    ‖p - u • q‖ ^ 2 = 2 - 2 * (u * (inner ℂ p q : ℂ)).re := by
  rw [@norm_sub_sq ℂ, inner_smul_right, norm_smul, hp, hq, hu]
  norm_num
  ring

theorem inner_norm_le_one (p q : E) (hp : ‖p‖ = 1) (hq : ‖q‖ = 1) :
    ‖(inner ℂ p q : ℂ)‖ ≤ 1 := by
  have := norm_inner_le_norm (𝕜 := ℂ) p q
  rwa [hp, hq, mul_one] at this

theorem phaseDist_nonneg (p q : E) : 0 ≤ phaseDist p q := Real.sqrt_nonneg _

theorem phaseDist_sq (p q : E) (hp : ‖p‖ = 1) (hq : ‖q‖ = 1) :
    phaseDist p q ^ 2 = 2 - 2 * ‖(inner ℂ p q : ℂ)‖ :=
  Real.sq_sqrt (by linarith [inner_norm_le_one p q hp hq])

/-- **Lower bound**: every phase rotation is at least `phaseDist` away. -/
theorem phaseDist_le_norm_sub (p q : E) (u : ℂ) (hp : ‖p‖ = 1) (hq : ‖q‖ = 1) (hu : ‖u‖ = 1) :
    phaseDist p q ≤ ‖p - u • q‖ := by
  have hexp := norm_sub_smul_sq p q u hp hq hu
  have hre : (u * (inner ℂ p q : ℂ)).re ≤ ‖(inner ℂ p q : ℂ)‖ := by
    calc (u * (inner ℂ p q : ℂ)).re ≤ ‖u * (inner ℂ p q : ℂ)‖ := Complex.re_le_norm _
      _ = ‖(inner ℂ p q : ℂ)‖ := by rw [norm_mul, hu, one_mul]
  have hle : 2 - 2 * ‖(inner ℂ p q : ℂ)‖ ≤ ‖p - u • q‖ ^ 2 := by rw [hexp]; linarith
  calc phaseDist p q = Real.sqrt (2 - 2 * ‖(inner ℂ p q : ℂ)‖) := rfl
    _ ≤ Real.sqrt (‖p - u • q‖ ^ 2) := Real.sqrt_le_sqrt hle
    _ = ‖p - u • q‖ := Real.sqrt_sq (norm_nonneg _)

/-- **Attainment**: the minimum over phases is realized. -/
theorem exists_phase_norm_sub_eq (p q : E) (hp : ‖p‖ = 1) (hq : ‖q‖ = 1) :
    ∃ u : ℂ, ‖u‖ = 1 ∧ ‖p - u • q‖ = phaseDist p q := by
  classical
  by_cases hz : (inner ℂ p q : ℂ) = 0
  · refine ⟨1, by norm_num, ?_⟩
    have hexp := norm_sub_smul_sq p q 1 hp hq (by norm_num)
    have h1 : ‖p - (1:ℂ) • q‖ ^ 2 = 2 - 2 * ‖(inner ℂ p q : ℂ)‖ := by
      rw [hexp, hz]; simp
    have h2 : phaseDist p q ^ 2 = 2 - 2 * ‖(inner ℂ p q : ℂ)‖ := phaseDist_sq p q hp hq
    have := phaseDist_nonneg p q
    nlinarith [norm_nonneg (p - (1:ℂ) • q)]
  · set s : ℂ := inner ℂ p q with hs
    have hns : ‖s‖ ≠ 0 := norm_ne_zero_iff.mpr hz
    refine ⟨conj s / (‖s‖ : ℂ), ?_, ?_⟩
    · rw [norm_div]
      simp [hns]
    · have hu : ‖conj s / (‖s‖ : ℂ)‖ = 1 := by rw [norm_div]; simp [hns]
      have hexp := norm_sub_smul_sq p q _ hp hq hu
      have hval : ((conj s / (‖s‖ : ℂ)) * s).re = ‖s‖ := by
        rw [div_mul_eq_mul_div, mul_comm, Complex.mul_conj]
        rw [show (Complex.normSq s : ℂ) = ((‖s‖ : ℝ) : ℂ) ^ 2 by
          push_cast [Complex.normSq_eq_norm_sq]; ring]
        rw [show (((‖s‖ : ℝ) : ℂ) ^ 2 / ((‖s‖ : ℝ) : ℂ)) = ((‖s‖ : ℝ) : ℂ) by
          field_simp]
        simp
      rw [hval] at hexp
      have h2 : phaseDist p q ^ 2 = 2 - 2 * ‖s‖ := phaseDist_sq p q hp hq
      have := phaseDist_nonneg p q
      nlinarith [norm_nonneg (p - (conj s / (‖s‖ : ℂ)) • q)]

/-- **The circle quotient is a metric space**: the triangle inequality for the
phase-minimized distance. -/
theorem phaseDist_triangle (p q r : E) (hp : ‖p‖ = 1) (hq : ‖q‖ = 1) (hr : ‖r‖ = 1) :
    phaseDist p r ≤ phaseDist p q + phaseDist q r := by
  obtain ⟨u, hu, hueq⟩ := exists_phase_norm_sub_eq p q hp hq
  obtain ⟨v, hv, hveq⟩ := exists_phase_norm_sub_eq q r hq hr
  have huv : ‖u * v‖ = 1 := by rw [norm_mul, hu, hv, one_mul]
  have hsplit : ‖p - (u * v) • r‖ ≤ ‖p - u • q‖ + ‖u • q - (u * v) • r‖ := by
    have : p - (u * v) • r = (p - u • q) + (u • q - (u * v) • r) := by abel
    rw [this]
    exact norm_add_le _ _
  have hsecond : ‖u • q - (u * v) • r‖ = ‖q - v • r‖ := by
    have : u • q - (u * v) • r = u • (q - v • r) := by
      rw [smul_sub, mul_smul]
    rw [this, norm_smul, hu, one_mul]
  calc phaseDist p r ≤ ‖p - (u * v) • r‖ := phaseDist_le_norm_sub p r (u * v) hp hr huv
    _ ≤ ‖p - u • q‖ + ‖u • q - (u * v) • r‖ := hsplit
    _ = phaseDist p q + phaseDist q r := by rw [hueq, hsecond, hveq]

/-- **Rigidity / equality case**: vanishing distance means the two unit vectors lie
on one circle orbit. -/
theorem phaseDist_eq_zero_iff (p q : E) (hp : ‖p‖ = 1) (hq : ‖q‖ = 1) :
    phaseDist p q = 0 ↔ ∃ u : ℂ, ‖u‖ = 1 ∧ p = u • q := by
  constructor
  · intro h
    obtain ⟨u, hu, hueq⟩ := exists_phase_norm_sub_eq p q hp hq
    refine ⟨u, hu, ?_⟩
    have hzero : ‖p - u • q‖ = 0 := by rw [hueq, h]
    exact sub_eq_zero.mp (norm_eq_zero.mp hzero)
  · rintro ⟨u, hu, rfl⟩
    simp [phaseDist, hq, hu]

/-- **The dimension-free identity** behind the sharp Hopf stability constant: with
`m = phaseDist²`, one has `m (4 - m) = 2 (2 - 2‖⟪p,q⟫‖²)`, the right-hand side
being the squared chordal Fubini–Study distance of the two lines. -/
theorem phaseDistSq_mul_identity (p q : E) (hp : ‖p‖ = 1) (hq : ‖q‖ = 1) :
    phaseDist p q ^ 2 * (4 - phaseDist p q ^ 2) = 2 * (2 - 2 * ‖(inner ℂ p q : ℂ)‖ ^ 2) := by
  rw [phaseDist_sq p q hp hq]
  ring

/-- **Sharp linear stability in any dimension.**  If the projective (chordal)
distance is at most `ε`, then some phase rotation brings `q` within `ε/√2` of `p`. -/
theorem phaseDist_le_of_proj_le (p q : E) (ε : ℝ) (hp : ‖p‖ = 1) (hq : ‖q‖ = 1)
    (hε : 2 * (2 - 2 * ‖(inner ℂ p q : ℂ)‖ ^ 2) ≤ ε ^ 2) :
    phaseDist p q ^ 2 ≤ ε ^ 2 / 2 := by
  have hid := phaseDistSq_mul_identity p q hp hq
  have h0 : 0 ≤ phaseDist p q ^ 2 := sq_nonneg _
  have h2 : phaseDist p q ^ 2 ≤ 2 := by
    rw [phaseDist_sq p q hp hq]
    have := norm_nonneg (inner ℂ p q : ℂ)
    linarith
  nlinarith

/-! ### Specialization to `ℂ²`: the general theory subsumes the Hopf computations -/

/-- The `ℂ²` fibre distance of `Shared.HopfFibreQuantitativeRigidity` is the square
of the general phase distance on `EuclideanSpace ℂ (Fin 2)`. -/
theorem phaseDist_sq_eq_fibreDistSq (z w z' w' : ℂ)
    (hp : HopfRigidity.IsUnitPair z w) (hq : HopfRigidity.IsUnitPair z' w') :
    phaseDist (!₂[z, w] : EuclideanSpace ℂ (Fin 2)) !₂[z', w'] ^ 2
      = HopfRigidity.fibreDistSq z w z' w' := by
  have hnp : ‖(!₂[z, w] : EuclideanSpace ℂ (Fin 2))‖ = 1 := by
    have hsq : ‖(!₂[z, w] : EuclideanSpace ℂ (Fin 2))‖ ^ 2 = ‖z‖ ^ 2 + ‖w‖ ^ 2 := by
      rw [EuclideanSpace.norm_eq, Real.sq_sqrt (by positivity)]
      simp [Fin.sum_univ_two]
    rw [HopfRigidity.IsUnitPair] at hp
    nlinarith [norm_nonneg (!₂[z, w] : EuclideanSpace ℂ (Fin 2)), hsq, hp]
  have hnq : ‖(!₂[z', w'] : EuclideanSpace ℂ (Fin 2))‖ = 1 := by
    have hsq : ‖(!₂[z', w'] : EuclideanSpace ℂ (Fin 2))‖ ^ 2 = ‖z'‖ ^ 2 + ‖w'‖ ^ 2 := by
      rw [EuclideanSpace.norm_eq, Real.sq_sqrt (by positivity)]
      simp [Fin.sum_univ_two]
    rw [HopfRigidity.IsUnitPair] at hq
    nlinarith [norm_nonneg (!₂[z', w'] : EuclideanSpace ℂ (Fin 2)), hsq, hq]
  have hinner : (inner ℂ (!₂[z, w] : EuclideanSpace ℂ (Fin 2)) !₂[z', w'] : ℂ)
      = conj z * z' + conj w * w' := by
    simp [PiLp.inner_apply, Fin.sum_univ_two, mul_comm]
  have hnorm : ‖(inner ℂ (!₂[z, w] : EuclideanSpace ℂ (Fin 2)) !₂[z', w'] : ℂ)‖
      = ‖HopfRigidity.pairing z w z' w'‖ := by
    rw [hinner, HopfRigidity.pairing]
    rw [show conj z * z' + conj w * w' = conj (z * conj z' + w * conj w') by
      simp [map_add, map_mul]]
    exact RCLike.norm_conj _
  rw [phaseDist_sq _ _ hnp hnq, hnorm, HopfRigidity.fibreDistSq]

end HopfQuotient