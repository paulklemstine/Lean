import Mathlib
import Shared.FourthDimensionPlayground

/-!
# Quantitative rigidity of almost-Hopf fibres

Let `hopf : ℂ² → ℝ³` be the classical quadratic Hopf map of
`Shared.FourthDimensionPlayground`.  Its fibres over the unit two-sphere are the
orbits of the diagonal circle action `u · (z, w) = (u z, u w)`, and
`FourthDimensionPlayground.hopf_eq_iff_phase` records the *exact* rigidity
statement: two unit vectors have the same Hopf image iff they differ by a unit
phase.

This file proves the **quantitative** version of that rigidity, in sharp form.
The central result is an exact algebraic identity between two quantities
attached to a pair of unit vectors `p = (z, w)`, `q = (z', w')`:

* the squared Euclidean distance `hopfDistSq` of their Hopf images in `ℝ³`;
* the squared distance `fibreDistSq` from `p` to the circle orbit of `q`,
  i.e. the minimum of `‖p - u q‖²` over unit phases `u`.

**Exact identity.**  `hopfDistSq = fibreDistSq * (4 - fibreDistSq)`.

Because `fibreDistSq ∈ [0, 2]`, the identity immediately yields the *linear*
modulus of stability `fibreDist ≤ hopfDist / √2` with the optimal constant
`1/√2`, and the optimality of the exponent `1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):
The Phase-A conjecture asserted a Hölder-`1/2` modulus of stability,
`fibreDist ≤ C √ε`, with the square-root exponent claimed to be optimal.  Our
hypothesis was that the Hopf map, being (up to scaling) a Riemannian submersion,
in fact admits a *linear* modulus, so that the conjecture is true but not sharp.

Experiment (Experimenter):
Writing `t = ‖⟪p, q⟫‖` for the Hermitian pairing of two unit vectors we computed
`hopfDistSq = 4(1 - t²)` and `fibreDistSq = 2(1 - t)`; eliminating `t` gives
`hopfDistSq = fibreDistSq (4 - fibreDistSq)`.  Both computations reduce to a
polynomial identity in the eight real coordinates, closed by `ring`, plus the
Cauchy–Schwarz bound `t ≤ 1` and the phase-choice `u = s / ‖s‖`.

Analysis (Analyst):
The conjecture is *true with `C = 1`* (`hopf_sqrt_stability`), but its optimality
clause is *false*: the exponent `1` works (`hopf_linear_stability`), with the
best possible constant `1/√2` (`hopf_linear_constant_sharp`), while no exponent
`α > 1` admits any constant (`no_stability_of_exponent_gt_one`).  The extremal
configuration for the constant is a pair of *orthogonal* unit vectors, whose Hopf
images are antipodal; the small-`ε` regime, by contrast, has asymptotic ratio
`1/2`, so the constant `1/√2` is attained only in the large-distance regime.

Critique (Critic):
None of the statements is definitional: the identity is a genuine elimination
between two different quadratic invariants, and each optimality claim is backed
by an explicit configuration (`z = 1, w = 0` against `z' = 1 - x`,
`w' = √(1 - (1-x)²)`).  The lower bound `phaseDistSq_ge_fibreDistSq` is proved
for *every* phase, so the refutations really rule out all phases, not just a
convenient one.  Degenerate cases (`s = 0`) are covered because the optimal phase
is then arbitrary and both sides equal `2`.

Synthesis (Principal Investigator):
Hopf-fibre rigidity is quantitatively governed by the single exact identity
`hopfDistSq = fibreDistSq (4 - fibreDistSq)`; the Cauchy–Schwarz defect of the
Hermitian pairing is the common source of both the qualitative fibre theorem and
its sharp stability constant.
-- !-- Lab Notes -- !--
-/

open ComplexConjugate FourthDimensionPlayground

namespace HopfRigidity

/-- A pair of complex numbers describing a unit vector of `ℂ² ≅ ℝ⁴`. -/
def IsUnitPair (z w : ℂ) : Prop := ‖z‖ ^ 2 + ‖w‖ ^ 2 = 1

/-- The Hermitian pairing `⟪(z,w), (z',w')⟫` of two vectors of `ℂ²`. -/
noncomputable def pairing (z w z' w' : ℂ) : ℂ := z * conj z' + w * conj w'

/-- Squared Euclidean distance between the Hopf images of `(z,w)` and `(z',w')`. -/
noncomputable def hopfDistSq (z w z' w' : ℂ) : ℝ :=
  ∑ i : Fin 3, (hopf z w i - hopf z' w' i) ^ 2

/-- Squared distance between `(z,w)` and the phase rotation `u · (z',w')`. -/
noncomputable def phaseDistSq (u z w z' w' : ℂ) : ℝ :=
  ‖z - u * z'‖ ^ 2 + ‖w - u * w'‖ ^ 2

/-- Squared distance from `(z,w)` to the whole circle orbit of `(z',w')`
(for unit vectors; see `phaseDistSq_ge_fibreDistSq` and `exists_optimal_phase`). -/
noncomputable def fibreDistSq (z w z' w' : ℂ) : ℝ := 2 - 2 * ‖pairing z w z' w'‖

/-! ### The two basic quadratic computations -/

/-- Polarisation identity for the Hopf map, valid for arbitrary vectors. -/
theorem hopfDistSq_eq_general (z w z' w' : ℂ) :
    hopfDistSq z w z' w' =
      (‖z‖ ^ 2 + ‖w‖ ^ 2 + ‖z'‖ ^ 2 + ‖w'‖ ^ 2) ^ 2 - 4 * ‖pairing z w z' w'‖ ^ 2 := by
  simp only [hopfDistSq, pairing, Complex.sq_norm, hopf, Fin.sum_univ_three,
    Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re, Complex.mul_im,
    Complex.conj_re, Complex.conj_im]
  ring

/-- For unit vectors, the squared Hopf distance is `4(1 - t²)` where `t` is the
modulus of the Hermitian pairing. -/
theorem hopfDistSq_eq (z w z' w' : ℂ) (hp : IsUnitPair z w) (hq : IsUnitPair z' w') :
    hopfDistSq z w z' w' = 4 * (1 - ‖pairing z w z' w'‖ ^ 2) := by
  rw [hopfDistSq_eq_general]
  rw [IsUnitPair] at hp hq
  rw [show ‖z‖ ^ 2 + ‖w‖ ^ 2 + ‖z'‖ ^ 2 + ‖w'‖ ^ 2 = 2 by rw [add_assoc, hp, hq]; norm_num]
  ring

/-- Exact expansion of the squared distance to a phase rotation. -/
theorem phaseDistSq_eq (u z w z' w' : ℂ) (hu : ‖u‖ = 1)
    (hp : IsUnitPair z w) (hq : IsUnitPair z' w') :
    phaseDistSq u z w z' w' = 2 - 2 * (pairing z w z' w' * conj u).re := by
  have hu2 : ‖u‖ ^ 2 = 1 := by rw [hu]; norm_num
  rw [IsUnitPair] at hp hq
  simp only [phaseDistSq, pairing, Complex.sq_norm, Complex.normSq_apply, Complex.mul_re,
    Complex.mul_im, Complex.add_re, Complex.add_im, Complex.conj_re, Complex.conj_im,
    Complex.sub_re, Complex.sub_im] at *
  nlinarith [hp, hq, hu2, sq_nonneg (u.re), sq_nonneg (u.im)]

/-- Cauchy–Schwarz: the Hermitian pairing of two unit vectors has modulus at most `1`. -/
theorem pairing_norm_le_one (z w z' w' : ℂ) (hp : IsUnitPair z w) (hq : IsUnitPair z' w') :
    ‖pairing z w z' w'‖ ≤ 1 := by
  have h := hopfDistSq_eq z w z' w' hp hq
  have hnn : 0 ≤ hopfDistSq z w z' w' := by
    unfold hopfDistSq
    positivity
  nlinarith [norm_nonneg (pairing z w z' w')]

/-- The circle-orbit distance lies in `[0, 2]`. -/
theorem fibreDistSq_mem (z w z' w' : ℂ) (hp : IsUnitPair z w) (hq : IsUnitPair z' w') :
    0 ≤ fibreDistSq z w z' w' ∧ fibreDistSq z w z' w' ≤ 2 := by
  constructor
  · have := pairing_norm_le_one z w z' w' hp hq
    simp only [fibreDistSq]; linarith
  · have := norm_nonneg (pairing z w z' w')
    simp only [fibreDistSq]; linarith

/-- Every phase rotation is at least as far as the circle-orbit distance. -/
theorem phaseDistSq_ge_fibreDistSq (u z w z' w' : ℂ) (hu : ‖u‖ = 1)
    (hp : IsUnitPair z w) (hq : IsUnitPair z' w') :
    fibreDistSq z w z' w' ≤ phaseDistSq u z w z' w' := by
  rw [phaseDistSq_eq u z w z' w' hu hp hq, fibreDistSq]
  have h1 : (pairing z w z' w' * conj u).re ≤ ‖pairing z w z' w' * conj u‖ :=
    Complex.re_le_norm _
  have h2 : ‖pairing z w z' w' * conj u‖ = ‖pairing z w z' w'‖ := by
    rw [norm_mul, RCLike.norm_conj, hu, mul_one]
  linarith [h2 ▸ h1]

/-- The circle-orbit distance is attained: an optimal phase exists. -/
theorem exists_optimal_phase (z w z' w' : ℂ) (hp : IsUnitPair z w) (hq : IsUnitPair z' w') :
    ∃ u : ℂ, ‖u‖ = 1 ∧ phaseDistSq u z w z' w' = fibreDistSq z w z' w' := by
  by_cases hs : pairing z w z' w' = 0
  · refine ⟨1, by norm_num, ?_⟩
    rw [phaseDistSq_eq 1 z w z' w' (by norm_num) hp hq, fibreDistSq, hs]
    norm_num
  · set s := pairing z w z' w' with hsdef
    refine ⟨s / (‖s‖ : ℂ), ?_, ?_⟩
    · rw [norm_div]
      simp [norm_ne_zero_iff.mpr hs]
    · rw [phaseDistSq_eq _ z w z' w' (by rw [norm_div]; simp [norm_ne_zero_iff.mpr hs]) hp hq,
        fibreDistSq, ← hsdef]
      congr 1
      have hkey : s * conj (s / (‖s‖ : ℂ)) = ((‖s‖ : ℝ) : ℂ) := by
        rw [map_div₀, Complex.conj_ofReal, ← mul_div_assoc, Complex.mul_conj]
        have h1 : (Complex.normSq s : ℂ) = ((‖s‖ : ℝ) : ℂ) ^ 2 := by
          push_cast [Complex.normSq_eq_norm_sq]; ring
        have h2 : ((‖s‖ : ℝ) : ℂ) ≠ 0 := by simpa using hs
        rw [h1]; field_simp
      rw [hkey]
      simp

/-! ### The exact identity and its sharp consequences -/

/-- **Main identity.**  For unit vectors of `ℂ²`, the squared Hopf distance and the
squared distance to the Hopf fibre satisfy
`hopfDistSq = fibreDistSq · (4 - fibreDistSq)`. -/
theorem hopfDistSq_eq_fibre_identity (z w z' w' : ℂ)
    (hp : IsUnitPair z w) (hq : IsUnitPair z' w') :
    hopfDistSq z w z' w' = fibreDistSq z w z' w' * (4 - fibreDistSq z w z' w') := by
  rw [hopfDistSq_eq z w z' w' hp hq, fibreDistSq]
  ring

/-- **Sharp linear stability.**  Squared form: the squared fibre distance is at most
half the squared Hopf distance. -/
theorem fibreDistSq_le_half_hopfDistSq (z w z' w' : ℂ)
    (hp : IsUnitPair z w) (hq : IsUnitPair z' w') :
    fibreDistSq z w z' w' ≤ hopfDistSq z w z' w' / 2 := by
  have hid := hopfDistSq_eq_fibre_identity z w z' w' hp hq
  obtain ⟨h0, h2⟩ := fibreDistSq_mem z w z' w' hp hq
  nlinarith

/-- The Hölder-type stability statement with constant `C` and exponent `α`:
if the Hopf images are at distance at most `ε`, some phase rotation of the second
vector is within `C ε^α` of the first. -/
def HopfStability (C α : ℝ) : Prop :=
  ∀ z w z' w' : ℂ, ∀ ε : ℝ, IsUnitPair z w → IsUnitPair z' w' → 0 ≤ ε →
    hopfDistSq z w z' w' ≤ ε ^ 2 →
      ∃ u : ℂ, ‖u‖ = 1 ∧ phaseDistSq u z w z' w' ≤ (C * ε ^ α) ^ 2

/-- **Linear modulus of stability with constant `1/√2`.** -/
theorem hopf_linear_stability : HopfStability (1 / Real.sqrt 2) 1 := by
  intro z w z' w' ε hp hq _ hε
  obtain ⟨u, hu, hueq⟩ := exists_optimal_phase z w z' w' hp hq
  refine ⟨u, hu, ?_⟩
  rw [hueq]
  have h := fibreDistSq_le_half_hopfDistSq z w z' w' hp hq
  have h2 : (0:ℝ) < Real.sqrt 2 := by positivity
  have hsq : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  rw [Real.rpow_one]
  have : (1 / Real.sqrt 2 * ε) ^ 2 = ε ^ 2 / 2 := by
    field_simp
    nlinarith [hsq]
  rw [this]
  linarith

/-- **The conjectured square-root modulus holds with `C = 1`** — a formal corollary of
the stronger linear bound. -/
theorem hopf_sqrt_stability : HopfStability 1 (1 / 2) := by
  intro z w z' w' ε hp hq hε0 hε
  obtain ⟨u, hu, hueq⟩ := exists_optimal_phase z w z' w' hp hq
  refine ⟨u, hu, ?_⟩
  rw [hueq]
  have h := fibreDistSq_le_half_hopfDistSq z w z' w' hp hq
  obtain ⟨h0, h2⟩ := fibreDistSq_mem z w z' w' hp hq
  have hrw : (1 * ε ^ (1/2 : ℝ)) ^ 2 = ε := by
    rw [one_mul, ← Real.rpow_natCast (ε ^ (1/2:ℝ)) 2, ← Real.rpow_mul hε0]
    norm_num
  rw [hrw]
  rcases le_or_gt ε 2 with hle | hgt
  · nlinarith
  · linarith

/-! ### Optimality: the constant and the exponent cannot be improved -/

/-- The extremal configuration for the constant: two orthogonal unit vectors.  Their
Hopf images are antipodal (`hopfDistSq = 4`) while every phase rotation stays at
squared distance `2`. -/
theorem orthogonal_extremal (u : ℂ) (hu : ‖u‖ = 1) :
    hopfDistSq 1 0 0 1 = 4 ∧ phaseDistSq u 1 0 0 1 = 2 := by
  constructor
  · simp [hopfDistSq, hopf, Fin.sum_univ_three]; norm_num
  · simp [phaseDistSq, hu]; norm_num

/-- **The constant `1/√2` is optimal**: no smaller constant admits a linear modulus. -/
theorem hopf_linear_constant_sharp (C : ℝ) (hC0 : 0 ≤ C) (hC : C < 1 / Real.sqrt 2) :
    ¬ HopfStability C 1 := by
  intro h
  have hup : IsUnitPair (1 : ℂ) 0 := by simp [IsUnitPair]
  have huq : IsUnitPair (0 : ℂ) 1 := by simp [IsUnitPair]
  obtain ⟨u, hu, hle⟩ := h 1 0 0 1 2 hup huq (by norm_num)
    (by rw [(orthogonal_extremal 1 (by norm_num)).1]; norm_num)
  rw [(orthogonal_extremal u hu).2, Real.rpow_one] at hle
  have hs : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hspos : (0:ℝ) < Real.sqrt 2 := by positivity
  rw [lt_div_iff₀ hspos] at hC
  nlinarith

/-- The one-parameter family of near-fibre configurations used to rule out
superlinear moduli: `p = (1, 0)` and `q = (1 - x, √(1 - (1-x)²))`. -/
theorem near_fibre_family (x : ℝ) (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    IsUnitPair ((1 - x : ℝ) : ℂ) ((Real.sqrt (1 - (1 - x) ^ 2) : ℝ) : ℂ) ∧
      hopfDistSq 1 0 ((1 - x : ℝ) : ℂ) ((Real.sqrt (1 - (1 - x) ^ 2) : ℝ) : ℂ)
        = 8 * x - 4 * x ^ 2 ∧
      fibreDistSq 1 0 ((1 - x : ℝ) : ℂ) ((Real.sqrt (1 - (1 - x) ^ 2) : ℝ) : ℂ) = 2 * x := by
  have hnn : (0:ℝ) ≤ 1 - (1 - x) ^ 2 := by nlinarith
  have hsq : Real.sqrt (1 - (1 - x) ^ 2) ^ 2 = 1 - (1 - x) ^ 2 := Real.sq_sqrt hnn
  have hup : IsUnitPair (1 : ℂ) 0 := by simp [IsUnitPair]
  have huq : IsUnitPair ((1 - x : ℝ) : ℂ) ((Real.sqrt (1 - (1 - x) ^ 2) : ℝ) : ℂ) := by
    simp only [IsUnitPair, Complex.norm_real, Real.norm_eq_abs, sq_abs]
    nlinarith
  have hpair : ‖pairing 1 0 ((1 - x : ℝ) : ℂ) ((Real.sqrt (1 - (1 - x) ^ 2) : ℝ) : ℂ)‖
      = 1 - x := by
    simp only [pairing, Complex.conj_ofReal, one_mul, zero_mul, add_zero, Complex.norm_real,
      Real.norm_eq_abs]
    exact abs_of_nonneg (by linarith)
  refine ⟨huq, ?_, ?_⟩
  · rw [hopfDistSq_eq _ _ _ _ hup huq, hpair]; ring
  · rw [fibreDistSq, hpair]; ring

/-- **No superlinear modulus of stability.**  For every constant `C` and every
exponent `α > 1`, the Hölder bound fails: the exponent `1` of
`hopf_linear_stability` is optimal. -/
theorem no_stability_of_exponent_gt_one (C α : ℝ) (hα : 1 < α) : ¬ HopfStability C α := by
  intro h
  -- choose the scale
  set a : ℝ := 1 / (4 * C ^ 2 + 1) with ha
  have hCpos : (0:ℝ) < 4 * C ^ 2 + 1 := by positivity
  have ha0 : 0 < a := by rw [ha]; positivity
  have ha1 : a ≤ 1 := by
    rw [ha, div_le_one hCpos]; nlinarith [sq_nonneg C]
  set y : ℝ := min (1/2) (a ^ (1 / (α - 1))) with hy
  have hexp : 0 < α - 1 := by linarith
  have hy0 : 0 < y := by
    rw [hy]
    exact lt_min (by norm_num) (Real.rpow_pos_of_pos ha0 _)
  have hyhalf : y ≤ 1/2 := min_le_left _ _
  have hya : y ^ (α - 1) ≤ a := by
    have h1 : y ≤ a ^ (1 / (α - 1)) := min_le_right _ _
    calc y ^ (α - 1) ≤ (a ^ (1 / (α - 1))) ^ (α - 1) :=
          Real.rpow_le_rpow hy0.le h1 hexp.le
      _ = a := by
          rw [← Real.rpow_mul ha0.le]
          rw [one_div, inv_mul_cancel₀ (ne_of_gt hexp), Real.rpow_one]
  set x : ℝ := y / 8 with hxdef
  have hx0 : 0 ≤ x := by positivity
  have hx1 : x ≤ 1 := by rw [hxdef]; linarith
  obtain ⟨huq, hhd, hfd⟩ := near_fibre_family x hx0 hx1
  have hup : IsUnitPair (1 : ℂ) 0 := by simp [IsUnitPair]
  set z' : ℂ := ((1 - x : ℝ) : ℂ)
  set w' : ℂ := ((Real.sqrt (1 - (1 - x) ^ 2) : ℝ) : ℂ)
  set ε : ℝ := Real.sqrt (8 * x - 4 * x ^ 2) with hε
  have hεnn : 0 ≤ 8 * x - 4 * x ^ 2 := by nlinarith
  have hε0 : 0 ≤ ε := Real.sqrt_nonneg _
  have hεsq : ε ^ 2 = 8 * x - 4 * x ^ 2 := Real.sq_sqrt hεnn
  obtain ⟨u, hu, hle⟩ := h 1 0 z' w' ε hup huq hε0 (by rw [hhd, hεsq])
  have hlow : fibreDistSq 1 0 z' w' ≤ phaseDistSq u 1 0 z' w' :=
    phaseDistSq_ge_fibreDistSq u 1 0 z' w' hu hup huq
  -- now compare the two bounds
  have hbound : (C * ε ^ α) ^ 2 = C ^ 2 * (ε ^ 2) ^ α := by
    rw [mul_pow, ← Real.rpow_natCast (ε ^ α) 2, ← Real.rpow_mul hε0,
      ← Real.rpow_natCast ε 2, ← Real.rpow_mul hε0]
    ring_nf
  have hmono : (ε ^ 2) ^ α ≤ (8 * x) ^ α := by
    rw [hεsq]
    exact Real.rpow_le_rpow hεnn (by nlinarith) (by linarith)
  have h8x : (8 : ℝ) * x = y := by rw [hxdef]; ring
  have hsplit : y ^ α = y * y ^ (α - 1) := by
    rw [← Real.rpow_one_add' hy0.le (by linarith)]
    ring_nf
  have hyα : y ^ α ≤ y * a := by
    rw [hsplit]
    exact mul_le_mul_of_nonneg_left hya hy0.le
  have hfinal : (C * ε ^ α) ^ 2 < 2 * x := by
    have h1 : (C * ε ^ α) ^ 2 ≤ C ^ 2 * (y * a) := by
      rw [hbound]
      calc C ^ 2 * (ε ^ 2) ^ α ≤ C ^ 2 * (8 * x) ^ α :=
            mul_le_mul_of_nonneg_left hmono (sq_nonneg C)
        _ = C ^ 2 * y ^ α := by rw [h8x]
        _ ≤ C ^ 2 * (y * a) := mul_le_mul_of_nonneg_left hyα (sq_nonneg C)
    have haC : a * (4 * C ^ 2 + 1) = 1 := by
      rw [ha]; field_simp
    have h2 : C ^ 2 * (y * a) < y / 4 := by
      have hq : (1 / 4 - C ^ 2 * a) * (4 * C ^ 2 + 1) = 1 / 4 := by
        linear_combination (-C ^ 2) * haC
      have hpos : 0 < 1 / 4 - C ^ 2 * a := by nlinarith
      nlinarith
    have h3 : 2 * x = y / 4 := by rw [hxdef]; ring
    linarith
  rw [hfd] at hlow
  linarith

end HopfRigidity