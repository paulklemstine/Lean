import Mathlib

/-!
# The sharp entropy-power / Euclidean-radius bridge

This file isolates the analytic core of the entropy power inequality (EPI).  If `h`
is a differential entropy in dimension `n`, its entropy radius and entropy power are

`r(h) = exp(h/n) / sqrt(2 π e)` and `N(h) = r(h)^2`.

Consequently the sharp EPI is exactly a Pythagorean (Euclidean `ℓ₂`) addition law
for entropy radii.  This is the exponent-two counterpart of the radius formulation
of Brunn--Minkowski.  We prove the equivalence, its exact equality condition, the
sharp isotropic-Gaussian case in every positive dimension, and an exact stability
identity measuring entropy excess above the sharp boundary.
-/

open Real

namespace EntropyPowerInequality

/-- Differential entropy of a centered isotropic Gaussian with scalar variance `v`
in dimension `n`. -/
noncomputable def gaussianEntropy (n : ℕ) (v : ℝ) : ℝ :=
  ((n : ℝ) / 2) * Real.log (2 * Real.pi * Real.exp 1 * v)

/-- Entropy radius. Its normalization makes the radius of an isotropic Gaussian
with variance `v` equal to `sqrt v`. -/
noncomputable def entropyRadius (n : ℕ) (h : ℝ) : ℝ :=
  Real.exp (h / (n : ℝ)) / Real.sqrt (2 * Real.pi * Real.exp 1)

/-- Shannon's entropy power in dimension `n`. -/
noncomputable def entropyPower (n : ℕ) (h : ℝ) : ℝ :=
  Real.exp (2 * h / (n : ℝ)) / (2 * Real.pi * Real.exp 1)

/-- The sharp entropy lower boundary corresponding to two input entropies. -/
noncomputable def sharpEntropyBoundary (n : ℕ) (hX hY : ℝ) : ℝ :=
  ((n : ℝ) / 2) * Real.log
    (Real.exp (2 * hX / (n : ℝ)) + Real.exp (2 * hY / (n : ℝ)))

/-- Entropy-power deficit. EPI says this is nonnegative. -/
noncomputable def epiDeficit (n : ℕ) (hX hY hSum : ℝ) : ℝ :=
  entropyPower n hSum - entropyPower n hX - entropyPower n hY

/-- The geometric `ℓ₂` radius-addition assertion. -/
def PythagoreanRadiusGrowth (rX rY rSum : ℝ) : Prop :=
  rX ^ 2 + rY ^ 2 ≤ rSum ^ 2

lemma normalization_pos : 0 < 2 * Real.pi * Real.exp 1 := by
  positivity

/-- Entropy power really is the square of entropy radius. -/
theorem entropyPower_eq_radius_sq {n : ℕ} (_hn : 0 < n) (h : ℝ) :
    entropyPower n h = entropyRadius n h ^ 2 := by
  unfold entropyPower entropyRadius
  have hnorm : 0 ≤ 2 * Real.pi * Real.exp 1 := by positivity
  rw [div_pow, Real.sq_sqrt hnorm]
  rw [show 2 * h / (n : ℝ) = h / (n : ℝ) + h / (n : ℝ) by ring]
  rw [Real.exp_add]
  ring

/-- **Connector theorem.** The sharp entropy-power inequality is equivalent to a
Pythagorean growth law for entropy radii. This connects information theory to
Euclidean geometry (and, via radius growth, to the geometric language of
Brunn--Minkowski). -/
theorem epi_iff_pythagorean_radius {n : ℕ} (hn : 0 < n) (hX hY hSum : ℝ) :
    entropyPower n hX + entropyPower n hY ≤ entropyPower n hSum ↔
      PythagoreanRadiusGrowth (entropyRadius n hX) (entropyRadius n hY)
        (entropyRadius n hSum) := by
  rw [entropyPower_eq_radius_sq hn, entropyPower_eq_radius_sq hn,
    entropyPower_eq_radius_sq hn]
  rfl

/-- EPI is equivalently nonnegativity of its deficit. -/
theorem epi_iff_deficit_nonnegative (n : ℕ) (hX hY hSum : ℝ) :
    entropyPower n hX + entropyPower n hY ≤ entropyPower n hSum ↔
      0 ≤ epiDeficit n hX hY hSum := by
  unfold epiDeficit
  constructor <;> intro h <;> linarith

/-- Entropy power is strictly increasing in entropy in every positive dimension. -/
theorem entropyPower_strictMono {n : ℕ} (hn : 0 < n) :
    StrictMono (entropyPower n) := by
  intro a b hab
  unfold entropyPower
  apply div_lt_div_of_pos_right _ normalization_pos
  apply Real.exp_lt_exp.mpr
  have hnR : 0 < (n : ℝ) := by exact_mod_cast hn
  exact (div_lt_div_iff_of_pos_right hnR).2 (by linarith)

/-- The exact equality case: the output entropy power is the sum of input powers
if and only if output entropy lies on the sharp logarithmic boundary. -/
theorem epi_equality_iff_entropy_boundary {n : ℕ} (hn : 0 < n)
    (hX hY hSum : ℝ) :
    entropyPower n hSum = entropyPower n hX + entropyPower n hY ↔
      hSum = sharpEntropyBoundary n hX hY := by
  have h_bound : entropyPower n (sharpEntropyBoundary n hX hY) = entropyPower n hX + entropyPower n hY := by
    unfold entropyPower sharpEntropyBoundary
    have h1 : 2 * ((n : ℝ) / 2 * Real.log (Real.exp (2 * hX / n) + Real.exp (2 * hY / n))) / n =
              Real.log (Real.exp (2 * hX / n) + Real.exp (2 * hY / n)) := by
      field_simp
    rw [h1]
    rw [Real.exp_log (by positivity : Real.exp (2 * hX / n) + Real.exp (2 * hY / n) > 0)]
    ring
  constructor
  · intro h
    exact (entropyPower_strictMono hn).injective (h.trans h_bound.symm)
  · intro h
    rw [h, h_bound]

/-- The inequality itself is exactly the sharp entropy lower bound. -/
theorem epi_iff_entropy_lower_bound {n : ℕ} (hn : 0 < n)
    (hX hY hSum : ℝ) :
    entropyPower n hX + entropyPower n hY ≤ entropyPower n hSum ↔
      sharpEntropyBoundary n hX hY ≤ hSum := by
  have hb : entropyPower n (sharpEntropyBoundary n hX hY) =
      entropyPower n hX + entropyPower n hY :=
    (epi_equality_iff_entropy_boundary hn hX hY
      (sharpEntropyBoundary n hX hY)).2 rfl
  rw [← hb]
  exact (entropyPower_strictMono hn).le_iff_le

/-- The entropy power of an isotropic Gaussian is exactly its scalar variance. -/
theorem gaussian_entropy_power {n : ℕ} (hn : 0 < n) {v : ℝ} (hv : 0 < v) :
    entropyPower n (gaussianEntropy n v) = v := by
  unfold entropyPower gaussianEntropy
  have h1 : 2 * ((n : ℝ) / 2 * Real.log (2 * Real.pi * Real.exp 1 * v)) /
      (n : ℝ) = Real.log (2 * Real.pi * Real.exp 1 * v) := by
    field_simp
  rw [h1, Real.exp_log (by positivity : 0 < 2 * Real.pi * Real.exp 1 * v)]
  field_simp

/-- The entropy radius of an isotropic Gaussian is exactly the standard deviation. -/
theorem gaussian_entropy_radius {n : ℕ} (hn : 0 < n) {v : ℝ} (hv : 0 < v) :
    entropyRadius n (gaussianEntropy n v) = Real.sqrt v := by
  have h1 := gaussian_entropy_power hn hv
  rw [entropyPower_eq_radius_sq hn] at h1
  have hnonneg : 0 ≤ entropyRadius n (gaussianEntropy n v) := by
    unfold entropyRadius
    positivity
  apply (sq_eq_sq₀ hnonneg (Real.sqrt_nonneg v)).mp
  rw [h1, Real.sq_sqrt hv.le]

/-- **Sharp EPI in every dimension for isotropic Gaussians.** Variances add under
independent Gaussian convolution, and entropy powers therefore add with equality.
The positivity assumptions are precisely the nondegenerate Gaussian regime. -/
theorem sharp_epi_isotropic_gaussians {n : ℕ} (hn : 0 < n)
    {vX vY : ℝ} (hvX : 0 < vX) (hvY : 0 < vY) :
    entropyPower n (gaussianEntropy n (vX + vY)) =
      entropyPower n (gaussianEntropy n vX) +
        entropyPower n (gaussianEntropy n vY) := by
  rw [gaussian_entropy_power hn (by positivity : 0 < vX + vY),
    gaussian_entropy_power hn hvX, gaussian_entropy_power hn hvY]

/-- Equality for isotropic Gaussians is literally the Pythagorean theorem for their
entropy radii (standard deviations). -/
theorem gaussian_pythagorean_bridge {n : ℕ} (hn : 0 < n)
    {vX vY : ℝ} (hvX : 0 < vX) (hvY : 0 < vY) :
    entropyRadius n (gaussianEntropy n (vX + vY)) ^ 2 =
      entropyRadius n (gaussianEntropy n vX) ^ 2 +
        entropyRadius n (gaussianEntropy n vY) ^ 2 := by
  rw [← entropyPower_eq_radius_sq hn, ← entropyPower_eq_radius_sq hn,
    ← entropyPower_eq_radius_sq hn]
  exact sharp_epi_isotropic_gaussians hn hvX hvY

/-- Exact multiplicative stability: an entropy excess `δ` above the sharp boundary
multiplies the boundary entropy power by `exp (2δ/n)`. -/
theorem entropy_excess_power_identity {n : ℕ} (hn : 0 < n)
    (hX hY δ : ℝ) :
    entropyPower n (sharpEntropyBoundary n hX hY + δ) =
      Real.exp (2 * δ / (n : ℝ)) *
        (entropyPower n hX + entropyPower n hY) := by
  have hb : entropyPower n (sharpEntropyBoundary n hX hY) =
      entropyPower n hX + entropyPower n hY :=
    (epi_equality_iff_entropy_boundary hn hX hY
      (sharpEntropyBoundary n hX hY)).2 rfl
  rw [← hb]
  unfold entropyPower
  rw [show 2 * (sharpEntropyBoundary n hX hY + δ) / (n : ℝ) =
      2 * δ / (n : ℝ) + 2 * sharpEntropyBoundary n hX hY / (n : ℝ) by ring]
  rw [Real.exp_add]
  ring

/-- Exact additive stability formula for the EPI deficit. In particular, positive
entropy excess creates a quantitatively positive power deficit. -/
theorem entropy_excess_deficit_identity {n : ℕ} (hn : 0 < n)
    (hX hY δ : ℝ) :
    epiDeficit n hX hY (sharpEntropyBoundary n hX hY + δ) =
      (Real.exp (2 * δ / (n : ℝ)) - 1) *
        (entropyPower n hX + entropyPower n hY) := by
  unfold epiDeficit
  rw [entropy_excess_power_identity hn]
  ring

/-- A genuine stability consequence: strict entropy excess implies strict EPI
slack. -/
theorem entropy_excess_gives_strict_epi {n : ℕ} (hn : 0 < n)
    (hX hY : ℝ) {δ : ℝ} (hδ : 0 < δ) :
    0 < epiDeficit n hX hY (sharpEntropyBoundary n hX hY + δ) := by
  rw [entropy_excess_deficit_identity hn]
  have hnR : 0 < (n : ℝ) := by exact_mod_cast hn
  have hexp : 1 < Real.exp (2 * δ / (n : ℝ)) := by
    rw [← Real.exp_zero]
    exact Real.exp_lt_exp.mpr (by positivity)
  have hpX : 0 < entropyPower n hX := by unfold entropyPower; positivity
  have hpY : 0 < entropyPower n hY := by unfold entropyPower; positivity
  exact mul_pos (sub_pos.mpr hexp) (add_pos hpX hpY)

end EntropyPowerInequality