import Mathlib

/-!
# The Topology of Knotted Light: Alexander Polynomials in the OAM Spectrum

A *knotted light* beam is a laser mode whose phase singularity (the curve on which
the complex amplitude vanishes) traces a knot `K` in space.  A recurring conjecture
in singular optics is that the beam's spectrum of orbital angular momentum (OAM)
values is governed by the **Alexander polynomial** `Δ_K` of the knot: the *quantized*
OAM values are the `l` for which the Alexander polynomial vanishes at the
root of unity `exp(2πi·l/N)`.

This file isolates the exact, checkable mathematics behind that picture.  We work
with the Alexander polynomials of the smallest knots,
* unknot:        `Δ = 1`,
* trefoil `3₁`:  `Δ = t² − t + 1`   (the 6th cyclotomic polynomial),
* figure‑eight `4₁`: `Δ = t² − 3t + 1`,
* cinquefoil `5₁`: `Δ = t⁴ − t³ + t² − t + 1` (the 10th cyclotomic polynomial),

and prove the facts that make the OAM story true or false in each case.

## Main results

* `OAMspectrum` — the set of OAM values `l` with `Δ(exp(2πi·l/N)) = 0`.
* `trefoil_oam_one`, `trefoil_oam_five`, `trefoil_oam_zero_notMem` — the trefoil beam
  has quantized OAM at `l = 1, 5 (mod 6)` but not at `l = 0`.
* `cinquefoil_oam_one` — the cinquefoil beam is quantized at `l = 1 (mod 10)`.
* `unknot_spectrum_trivial` — the unknot beam carries no quantized OAM.
* `figureEight_root_gold`, `figureEight_root_goldConj` — the figure‑eight Alexander
  roots are the squares of the golden ratio and its conjugate, `(3 ± √5)/2`.
* `figureEight_root_offUnitCircle` — those roots lie *off* the unit circle, so the
  figure‑eight beam has **no** unit‑circle (root‑of‑unity) OAM quantization: the
  cyclotomic knots (trefoil, cinquefoil) behave qualitatively differently from `4₁`.
* `trefoil_reciprocal`, `cinquefoil_reciprocal` — the palindromic (reciprocal)
  functional equation `t^{deg} Δ(1/t) = Δ(t)` of Alexander polynomials.
* `trefoil_determinant`, `figureEight_determinant`, `cinquefoil_determinant` — the
  knot determinants `|Δ(−1)|` equal `3, 5, 5` respectively.
* `trefoil_normalization`, … — the normalization `Δ(1) = 1`.
-/

open Complex Polynomial

noncomputable section

/-! ## Alexander polynomials as complex evaluation functions -/

/-- Alexander polynomial of the unknot, `Δ = 1`. -/
def alexUnknot : ℂ → ℂ := fun _ => 1

/-- Alexander polynomial of the trefoil knot `3₁`, `Δ = t² − t + 1`. -/
def alexTrefoil : ℂ → ℂ := fun z => z ^ 2 - z + 1

/-- Alexander polynomial of the cinquefoil (Solomon's seal) knot `5₁`,
`Δ = t⁴ − t³ + t² − t + 1`. -/
def alexCinquefoil : ℂ → ℂ := fun z => z ^ 4 - z ^ 3 + z ^ 2 - z + 1

/-- The OAM spectrum of a knotted‑light beam with Alexander polynomial `Δ` and
modular period `N`: the OAM values `l` at which `Δ` vanishes on the root of unity
`exp(2πi·l/N)`. -/
def OAMspectrum (Δ : ℂ → ℂ) (N : ℕ) : Set ℝ :=
  {l | Δ (Complex.exp (2 * Real.pi * Complex.I * l / N)) = 0}

/-! ## Algebraic root criteria (factoring `tⁿ + 1`) -/

/-- If `z³ = −1` and `z ≠ −1`, then `z` is a root of the trefoil Alexander
polynomial.  This is the factorization `t³ + 1 = (t + 1)(t² − t + 1)`. -/
theorem alexTrefoil_eq_zero_of {z : ℂ} (h3 : z ^ 3 = -1) (hz : z ≠ -1) :
    alexTrefoil z = 0 := by
  have factored : (z + 1) * (z ^ 2 - z + 1) = z ^ 3 + 1 := by ring
  have hzero : (z + 1) * (z ^ 2 - z + 1) = 0 := by rw [factored, h3]; ring
  rcases mul_eq_zero.1 hzero with h | h
  · exact absurd (by linear_combination h) hz
  · simpa [alexTrefoil] using h

/-- If `z⁵ = −1` and `z ≠ −1`, then `z` is a root of the cinquefoil Alexander
polynomial.  This is the factorization `t⁵ + 1 = (t + 1)(t⁴ − t³ + t² − t + 1)`. -/
theorem alexCinquefoil_eq_zero_of {z : ℂ} (h5 : z ^ 5 = -1) (hz : z ≠ -1) :
    alexCinquefoil z = 0 := by
  have factored : (z + 1) * (z ^ 4 - z ^ 3 + z ^ 2 - z + 1) = z ^ 5 + 1 := by ring
  have hzero : (z + 1) * (z ^ 4 - z ^ 3 + z ^ 2 - z + 1) = 0 := by rw [factored, h5]; ring
  rcases mul_eq_zero.1 hzero with h | h
  · exact absurd (by linear_combination h) hz
  · simpa [alexCinquefoil] using h

/-! ## The trefoil: sixth roots of unity -/

/-- `z₆ = exp(2πi/6)`, the primitive sixth root of unity carried by the trefoil beam. -/
def z6 : ℂ := Complex.exp (2 * Real.pi * Complex.I / 6)

theorem z6_isPrimitiveRoot : IsPrimitiveRoot z6 6 := by
  have := Complex.isPrimitiveRoot_exp 6 (by norm_num)
  simpa [z6] using this

theorem z6_ne_neg_one : z6 ≠ -1 := by
  intro hz
  have h2 : z6 ^ 2 = 1 := by rw [hz]; ring
  exact z6_isPrimitiveRoot.pow_ne_one_of_pos_of_lt (by norm_num) (by norm_num) h2

theorem z6_cube : z6 ^ 3 = -1 := by
  have h6 : z6 ^ 6 = 1 := z6_isPrimitiveRoot.pow_eq_one
  have hsq : (z6 ^ 3) * (z6 ^ 3) = 1 := by rw [← pow_add]; norm_num [h6]
  have h3 : z6 ^ 3 ≠ 1 := z6_isPrimitiveRoot.pow_ne_one_of_pos_of_lt (by norm_num) (by norm_num)
  rcases mul_self_eq_one_iff.1 hsq with h | h
  · exact absurd h h3
  · exact h

/-- The trefoil Alexander polynomial vanishes at `z₆ = exp(2πi/6)`. -/
theorem trefoil_root_z6 : alexTrefoil z6 = 0 :=
  alexTrefoil_eq_zero_of z6_cube z6_ne_neg_one

/-- `z₆⁵ = exp(2πi·5/6)` is not `−1` (its square is `z₆¹⁰ = z₆⁴ ≠ 1`). -/
theorem z6_pow5_ne_neg_one : z6 ^ 5 ≠ -1 := by
  intro hz
  have h10 : (z6 ^ 5) ^ 2 = 1 := by rw [hz]; ring
  have h4 : z6 ^ 4 = 1 := by
    have h6 : z6 ^ 6 = 1 := z6_isPrimitiveRoot.pow_eq_one
    have h10' : z6 ^ 10 = 1 := by rw [← pow_mul] at h10; simpa using h10
    have e : z6 ^ 10 = z6 ^ 6 * z6 ^ 4 := by ring
    rw [h6, one_mul] at e
    rw [e] at h10'
    exact h10'
  exact z6_isPrimitiveRoot.pow_ne_one_of_pos_of_lt (by norm_num) (by norm_num) h4

/-- `(z₆⁵)³ = −1`. -/
theorem z6_pow5_cube : (z6 ^ 5) ^ 3 = -1 := by
  have h6 : z6 ^ 6 = 1 := z6_isPrimitiveRoot.pow_eq_one
  calc (z6 ^ 5) ^ 3 = (z6 ^ 6) ^ 2 * z6 ^ 3 := by ring
    _ = z6 ^ 3 := by rw [h6]; ring
    _ = -1 := z6_cube

/-- The trefoil Alexander polynomial also vanishes at `z₆⁵ = exp(2πi·5/6)`. -/
theorem trefoil_root_z6pow5 : alexTrefoil (z6 ^ 5) = 0 :=
  alexTrefoil_eq_zero_of z6_pow5_cube z6_pow5_ne_neg_one

/-! ### OAM membership for the trefoil beam -/

/-- The trefoil beam is OAM‑quantized at `l = 1 (mod 6)`. -/
theorem trefoil_oam_one : (1 : ℝ) ∈ OAMspectrum alexTrefoil 6 := by
  show alexTrefoil (Complex.exp (2 * Real.pi * Complex.I * (1 : ℝ) / (6 : ℕ))) = 0
  have : (2 * Real.pi * Complex.I * ((1 : ℝ) : ℂ) / ((6 : ℕ) : ℂ)) = 2 * Real.pi * Complex.I / 6 := by
    push_cast; ring
  rw [this]
  exact trefoil_root_z6

/-- The trefoil beam is OAM‑quantized at `l = 5 (mod 6)`. -/
theorem trefoil_oam_five : (5 : ℝ) ∈ OAMspectrum alexTrefoil 6 := by
  show alexTrefoil (Complex.exp (2 * Real.pi * Complex.I * (5 : ℝ) / (6 : ℕ))) = 0
  have hpt : Complex.exp (2 * Real.pi * Complex.I * ((5 : ℝ) : ℂ) / ((6 : ℕ) : ℂ)) = z6 ^ 5 := by
    rw [z6, ← Complex.exp_nat_mul]
    congr 1
    push_cast; ring
  rw [hpt]
  exact trefoil_root_z6pow5

/-- The trefoil beam is *not* quantized at `l = 0`: `Δ(1) = 1 ≠ 0`. -/
theorem trefoil_oam_zero_notMem : (0 : ℝ) ∉ OAMspectrum alexTrefoil 6 := by
  show ¬ alexTrefoil (Complex.exp (2 * Real.pi * Complex.I * (0 : ℝ) / (6 : ℕ))) = 0
  have : (2 * Real.pi * Complex.I * ((0 : ℝ) : ℂ) / ((6 : ℕ) : ℂ)) = 0 := by push_cast; ring
  rw [this, Complex.exp_zero]
  simp [alexTrefoil]

/-! ## The unknot: trivial spectrum -/

/-- The unknot beam carries no quantized OAM: its spectrum is empty. -/
theorem unknot_spectrum_trivial (N : ℕ) : OAMspectrum alexUnknot N = ∅ := by
  ext l
  simp [OAMspectrum, alexUnknot]

/-! ## The cinquefoil: tenth roots of unity -/

/-- `z₁₀ = exp(2πi/10)`, a primitive tenth root of unity. -/
def z10 : ℂ := Complex.exp (2 * Real.pi * Complex.I / 10)

theorem z10_isPrimitiveRoot : IsPrimitiveRoot z10 10 := by
  have := Complex.isPrimitiveRoot_exp 10 (by norm_num)
  simpa [z10] using this

theorem z10_ne_neg_one : z10 ≠ -1 := by
  intro hz
  have h2 : z10 ^ 2 = 1 := by rw [hz]; ring
  exact z10_isPrimitiveRoot.pow_ne_one_of_pos_of_lt (by norm_num) (by norm_num) h2

theorem z10_pow5 : z10 ^ 5 = -1 := by
  have h10 : z10 ^ 10 = 1 := z10_isPrimitiveRoot.pow_eq_one
  have hsq : (z10 ^ 5) * (z10 ^ 5) = 1 := by rw [← pow_add]; norm_num [h10]
  have h5 : z10 ^ 5 ≠ 1 := z10_isPrimitiveRoot.pow_ne_one_of_pos_of_lt (by norm_num) (by norm_num)
  rcases mul_self_eq_one_iff.1 hsq with h | h
  · exact absurd h h5
  · exact h

/-- The cinquefoil Alexander polynomial vanishes at `z₁₀ = exp(2πi/10)`. -/
theorem cinquefoil_root_z10 : alexCinquefoil z10 = 0 :=
  alexCinquefoil_eq_zero_of z10_pow5 z10_ne_neg_one

/-- The cinquefoil beam is OAM‑quantized at `l = 1 (mod 10)`. -/
theorem cinquefoil_oam_one : (1 : ℝ) ∈ OAMspectrum alexCinquefoil 10 := by
  show alexCinquefoil (Complex.exp (2 * Real.pi * Complex.I * (1 : ℝ) / (10 : ℕ))) = 0
  have : (2 * Real.pi * Complex.I * ((1 : ℝ) : ℂ) / ((10 : ℕ) : ℂ))
      = 2 * Real.pi * Complex.I / 10 := by push_cast; ring
  rw [this]
  exact cinquefoil_root_z10

/-! ## The figure‑eight knot: golden‑ratio roots off the unit circle -/

/-- Alexander polynomial of the figure‑eight knot `4₁` as a real function,
`Δ = t² − 3t + 1`. -/
def alexFigureEightR : ℝ → ℝ := fun x => x ^ 2 - 3 * x + 1

/-- The figure‑eight Alexander polynomial vanishes at `φ² = (3 + √5)/2`, the square
of the golden ratio. -/
theorem figureEight_root_gold : alexFigureEightR (Real.goldenRatio ^ 2) = 0 := by
  have h := Real.goldenRatio_sq
  show (Real.goldenRatio ^ 2) ^ 2 - 3 * (Real.goldenRatio ^ 2) + 1 = 0
  linear_combination (Real.goldenRatio ^ 2 + Real.goldenRatio - 1) * h

/-- The figure‑eight Alexander polynomial vanishes at `ψ² = (3 − √5)/2`, the square
of the conjugate golden ratio. -/
theorem figureEight_root_goldConj : alexFigureEightR (Real.goldenConj ^ 2) = 0 := by
  have h := Real.goldenConj_sq
  show (Real.goldenConj ^ 2) ^ 2 - 3 * (Real.goldenConj ^ 2) + 1 = 0
  linear_combination (Real.goldenConj ^ 2 + Real.goldenConj - 1) * h

/-- Unlike the trefoil and cinquefoil (whose roots are roots of unity), the
figure‑eight roots lie **off** the unit circle: `φ² > 1`.  Hence the figure‑eight
beam has no root‑of‑unity OAM quantization. -/
theorem figureEight_root_offUnitCircle : 1 < Real.goldenRatio ^ 2 := by
  have h1 : (1 : ℝ) < Real.goldenRatio := Real.one_lt_goldenRatio
  nlinarith [h1]

/-- The two figure‑eight roots are reciprocal: `φ² · ψ² = 1` (product of roots),
confirming `Δ` is reciprocal / the roots are mirror images across the unit circle. -/
theorem figureEight_roots_reciprocal : Real.goldenRatio ^ 2 * Real.goldenConj ^ 2 = 1 := by
  have h : Real.goldenRatio * Real.goldenConj = -1 := Real.goldenRatio_mul_goldenConj
  calc Real.goldenRatio ^ 2 * Real.goldenConj ^ 2
      = (Real.goldenRatio * Real.goldenConj) ^ 2 := by ring
    _ = 1 := by rw [h]; ring

/-! ## Reciprocity (palindromic functional equation) -/

/-- The trefoil Alexander polynomial is reciprocal: `t² Δ(1/t) = Δ(t)`. -/
theorem trefoil_reciprocal {z : ℂ} (hz : z ≠ 0) :
    z ^ 2 * alexTrefoil z⁻¹ = alexTrefoil z := by
  simp only [alexTrefoil]
  field_simp
  ring

/-- The cinquefoil Alexander polynomial is reciprocal: `t⁴ Δ(1/t) = Δ(t)`. -/
theorem cinquefoil_reciprocal {z : ℂ} (hz : z ≠ 0) :
    z ^ 4 * alexCinquefoil z⁻¹ = alexCinquefoil z := by
  simp only [alexCinquefoil]
  field_simp
  ring

/-! ## Integer‑polynomial normalization and knot determinants -/

/-- The trefoil Alexander polynomial over `ℤ`. -/
def trefoilPoly : ℤ[X] := X ^ 2 - X + 1

/-- The figure‑eight Alexander polynomial over `ℤ`. -/
def figureEightPoly : ℤ[X] := X ^ 2 - 3 * X + 1

/-- The cinquefoil Alexander polynomial over `ℤ`. -/
def cinquefoilPoly : ℤ[X] := X ^ 4 - X ^ 3 + X ^ 2 - X + 1

/-- The integer polynomial agrees with the complex evaluation function for the trefoil. -/
theorem trefoil_aeval (z : ℂ) : (aeval z) trefoilPoly = alexTrefoil z := by
  simp [trefoilPoly, alexTrefoil]

/-- The integer polynomial agrees with the complex evaluation function for the cinquefoil. -/
theorem cinquefoil_aeval (z : ℂ) : (aeval z) cinquefoilPoly = alexCinquefoil z := by
  simp [cinquefoilPoly, alexCinquefoil]

/-- Normalization: `Δ_trefoil(1) = 1`. -/
theorem trefoil_normalization : trefoilPoly.eval 1 = 1 := by
  simp [trefoilPoly]

/-- Normalization: `Δ_figureEight(1) = -1`. -/
theorem figureEight_normalization : figureEightPoly.eval 1 = -1 := by
  simp [figureEightPoly]

/-- Normalization: `Δ_cinquefoil(1) = 1`. -/
theorem cinquefoil_normalization : cinquefoilPoly.eval 1 = 1 := by
  simp [cinquefoilPoly]

/-- The knot determinant of the trefoil is `|Δ(−1)| = 3`. -/
theorem trefoil_determinant : trefoilPoly.eval (-1) = 3 := by
  simp [trefoilPoly]

/-- The knot determinant of the figure‑eight is `|Δ(−1)| = 5`. -/
theorem figureEight_determinant : figureEightPoly.eval (-1) = 5 := by
  simp [figureEightPoly]

/-- The knot determinant of the cinquefoil is `|Δ(−1)| = 5`. -/
theorem cinquefoil_determinant : cinquefoilPoly.eval (-1) = 5 := by
  simp [cinquefoilPoly]

/-- All three knot determinants are odd, a general property of the Alexander
determinant `Δ(−1)` of a knot. -/
theorem determinants_odd :
    Odd (trefoilPoly.eval (-1)) ∧ Odd (figureEightPoly.eval (-1)) ∧
      Odd (cinquefoilPoly.eval (-1)) := by
  refine ⟨?_, ?_, ?_⟩
  · rw [trefoil_determinant]; decide
  · rw [figureEight_determinant]; decide
  · rw [cinquefoil_determinant]; decide

end