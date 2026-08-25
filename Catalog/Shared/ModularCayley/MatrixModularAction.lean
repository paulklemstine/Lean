import Mathlib

/-!
# Matrix-level modular action: translations, the Cayley transform and horocycles

This file develops the matrix picture behind the catalog declarations
`cayley`, `spb` and `spbMat` (`Catalog/Shared/CatalogbuildSharedCayley/Cayley.lean`,
`Catalog/Shared/AbstractAlgebra/Spb.lean`).  The catalog definitions are repeated
verbatim here so that the file stays self-contained, exactly as the other catalog
files do.

Contents.

* `mobius` : the Möbius action of a `2 × 2` complex matrix on `ℂ`, together with the
  imaginary-part transformation law `mobius_im_ofReal` and the cocycle law `mobius_mul`.
* `transMat t = !![1, t; 0, 1]` : translations as determinant-one matrices, with the
  parabolic trace identity `trace ^ 2 = 4 * det`.
* `cayleyMat = !![I, 1; -I, 1]` : the Cayley transform as a matrix; its Möbius action is
  `cayleyC`, which restricts on `ℝ` to the catalog function `cayley`.
* `discPar t` : the image of `transMat t` under Cayley conjugation, an `SU(1,1)`
  parabolic element; the *intertwining identity* `cayleyMat_transMat` and its Möbius
  form `cayleyC_add_ofReal`.
* `discHoro` : the disc-side horocycle function, with `discHoro_cayleyC` showing that it
  transports to `Im` on the half-plane, and `discPar_preserves_discHoro`.
* The main bridge `horocycle_preserving_iff_translation`: a determinant-one real matrix
  preserves every horocycle `Im z = c` iff it is `±transMat t`; consequently the trace
  condition `trace ^ 2 = 4 * det` holds.  The converse needs the guard `M 1 0 = 0`
  (`parabolic_fixing_infty_preserves_horocycles`), and this guard is necessary
  (`parabolic_not_horocycle_preserving`).
* The elliptic contrast: `cayleyMat_spbMat` conjugates the catalog matrix `spbMat a` to a
  rotation, and `cayleyC_spb` shows the catalog operation `spb` becomes multiplication on
  the unit circle.
-/

noncomputable section

open Complex Matrix

namespace CatalogShared.ModularCayley

/-! ## Catalog definitions (repeated verbatim, self-contained) -/

/-- The Cayley transform maps a real number to a point on the unit circle
in the complex plane: `cayley(x) = (1 + ix)/(1 - ix)`.  (Catalog definition.) -/
def cayley (x : ℝ) : ℂ := (1 + x * Complex.I) / (1 - x * Complex.I)

/-- The catalog "special-relativistic / tangent" addition `spb x y = (x+y)/(1-xy)`. -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The catalog SPB matrix `M(a) = !![1, a; -a, 1]`. -/
def spbMat (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ := !![1, a; -a, 1]

/-! ## The Möbius action -/

/-- The Möbius action of a `2 × 2` complex matrix on the Riemann sphere, read on `ℂ`. -/
def mobius (M : Matrix (Fin 2) (Fin 2) ℂ) (z : ℂ) : ℂ :=
  (M 0 0 * z + M 0 1) / (M 1 0 * z + M 1 1)

/-- Complexification of a real matrix. -/
def cx (M : Matrix (Fin 2) (Fin 2) ℝ) : Matrix (Fin 2) (Fin 2) ℂ :=
  M.map (fun r => (r : ℂ))

@[simp] lemma cx_apply (M : Matrix (Fin 2) (Fin 2) ℝ) (i j : Fin 2) :
    cx M i j = ((M i j : ℝ) : ℂ) := rfl

/-- Transformation law for the imaginary part under a real Möbius map:
`Im (M • z) = det M * Im z / |c z + d| ^ 2`. -/
lemma mobius_im_ofReal (a b c d : ℝ) (z : ℂ) (h : (c : ℂ) * z + d ≠ 0) :
    (((a : ℂ) * z + b) / ((c : ℂ) * z + d)).im
      = (a * d - b * c) * z.im / Complex.normSq ((c : ℂ) * z + d) := by
  have hns : Complex.normSq ((c : ℂ) * z + d) ≠ 0 := by
    simpa [Complex.normSq_eq_zero] using h
  rw [Complex.div_im]
  simp only [Complex.add_im, Complex.add_re, Complex.mul_im, Complex.mul_re,
    Complex.ofReal_re, Complex.ofReal_im, Complex.normSq_apply]
  field_simp
  ring

/-- Möbius action of a real matrix, in terms of its entries. -/
lemma mobius_cx (M : Matrix (Fin 2) (Fin 2) ℝ) (z : ℂ) :
    mobius (cx M) z = ((M 0 0 : ℂ) * z + (M 0 1 : ℝ)) / ((M 1 0 : ℝ) * z + (M 1 1 : ℝ)) := rfl

/-- The Möbius action is a (partial) action: matrix product corresponds to composition. -/
lemma mobius_mul (M N : Matrix (Fin 2) (Fin 2) ℂ) (z : ℂ)
    (hN : N 1 0 * z + N 1 1 ≠ 0) :
    mobius (M * N) z = mobius M (mobius N z) := by
  have hexp : ∀ i j : Fin 2, (M * N) i j = M i 0 * N 0 j + M i 1 * N 1 j := by
    intro i j; simp [Matrix.mul_apply, Fin.sum_univ_two]
  simp only [mobius, hexp]
  set D : ℂ := N 1 0 * z + N 1 1 with hD
  have hnum : M 0 0 * ((N 0 0 * z + N 0 1) / D) + M 0 1
      = ((M 0 0 * N 0 0 + M 0 1 * N 1 0) * z + (M 0 0 * N 0 1 + M 0 1 * N 1 1)) / D := by
    field_simp [hD]; ring
  have hden : M 1 0 * ((N 0 0 * z + N 0 1) / D) + M 1 1
      = ((M 1 0 * N 0 0 + M 1 1 * N 1 0) * z + (M 1 0 * N 0 1 + M 1 1 * N 1 1)) / D := by
    field_simp [hD]; ring
  rw [hnum, hden]
  field_simp


/-! ## Translations as determinant-one matrices -/

/-- The translation `z ↦ z + t` as a determinant-one matrix. -/
def transMat (t : ℝ) : Matrix (Fin 2) (Fin 2) ℝ := !![1, t; 0, 1]

@[simp] lemma transMat_det (t : ℝ) : (transMat t).det = 1 := by
  simp [transMat, Matrix.det_fin_two]

@[simp] lemma transMat_trace (t : ℝ) : (transMat t).trace = 2 := by
  simp [transMat, Matrix.trace_fin_two]
  norm_num

/-- Translations satisfy the parabolic trace condition `tr ^ 2 = 4 det`. -/
theorem transMat_parabolic (t : ℝ) :
    (transMat t).trace ^ 2 = 4 * (transMat t).det := by
  rw [transMat_trace, transMat_det]; norm_num

/-- `t ↦ transMat t` is a homomorphism from `(ℝ, +)` to `SL₂(ℝ)`. -/
theorem transMat_mul (s t : ℝ) : transMat s * transMat t = transMat (s + t) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [transMat, Matrix.mul_apply, Fin.sum_univ_two, add_comm]

@[simp] theorem transMat_zero : transMat 0 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [transMat]

/-- Powers of a translation matrix translate by multiples. -/
theorem transMat_pow (t : ℝ) : ∀ n : ℕ, transMat t ^ n = transMat (n * t)
  | 0 => by simp
  | (n + 1) => by
      rw [pow_succ, transMat_pow t n, transMat_mul]
      push_cast
      ring_nf

/-- The Möbius action of `transMat t` is the translation `z ↦ z + t`. -/
theorem transMat_mobius (t : ℝ) (z : ℂ) : mobius (cx (transMat t)) z = z + t := by
  simp [mobius, cx, transMat]

/-! ## The Cayley transform as a matrix -/

/-- The Cayley matrix `!![I, 1; -I, 1]`, whose Möbius action is the Cayley transform. -/
def cayleyMat : Matrix (Fin 2) (Fin 2) ℂ := !![I, 1; -I, 1]

/-- The Cayley transform extended to `ℂ`: it maps the upper half-plane onto the unit disc. -/
def cayleyC (z : ℂ) : ℂ := (1 + z * I) / (1 - z * I)

/-- On the reals, `cayleyC` is the catalog function `cayley`. -/
theorem cayleyC_ofReal (x : ℝ) : cayleyC (x : ℂ) = cayley x := rfl

@[simp] theorem cayleyMat_det : cayleyMat.det = 2 * I := by
  simp [cayleyMat, Matrix.det_fin_two]
  ring


theorem cayleyMat_isUnit : IsUnit cayleyMat.det := by
  rw [cayleyMat_det]
  exact isUnit_iff_ne_zero.2 (by simp [Complex.I_ne_zero])

/-- The Möbius action of the Cayley matrix is the Cayley transform. -/
theorem mobius_cayleyMat (z : ℂ) : mobius cayleyMat z = cayleyC z := by
  simp [mobius, cayleyMat, cayleyC]
  congr 1 <;> ring

/-- The Cayley denominator vanishes only at `-I`. -/
theorem cayley_den_ne_zero {z : ℂ} (hz : z ≠ -I) : 1 - z * I ≠ 0 := by
  intro h
  apply hz
  have h1 : z * I = 1 := by linear_combination -h
  have h2 := congrArg (fun w => w * (-I)) h1
  simpa [mul_assoc, Complex.I_mul_I] using h2

/-! ## The parabolic disc matrices -/

/-- The Cayley conjugate of `transMat t`: a parabolic element of `SU(1,1)` fixing `-1`. -/
def discPar (t : ℝ) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![1 + (t : ℂ) * I / 2, (t : ℂ) * I / 2; -((t : ℂ) * I / 2), 1 - (t : ℂ) * I / 2]

@[simp] theorem discPar_det (t : ℝ) : (discPar t).det = 1 := by
  simp [discPar, Matrix.det_fin_two]
  ring

@[simp] theorem discPar_trace (t : ℝ) : (discPar t).trace = 2 := by
  simp [discPar, Matrix.trace_fin_two]
  ring

/-- The disc-side matrices satisfy the parabolic trace condition. -/
theorem discPar_parabolic (t : ℝ) :
    (discPar t).trace ^ 2 = 4 * (discPar t).det := by
  rw [discPar_trace, discPar_det]; norm_num

/-- `discPar t` lies in `SU(1,1)`: its entries have the shape `!![α, β; conj β, conj α]`. -/
theorem discPar_su11 (t : ℝ) :
    (starRingEnd ℂ) (discPar t 0 0) = discPar t 1 1 ∧
      (starRingEnd ℂ) (discPar t 0 1) = discPar t 1 0 := by
  constructor <;>
    simp [discPar, Complex.ext_iff, Complex.div_re, Complex.div_im, Complex.normSq_apply] <;>
    ring

/-- The disc-side parabolic matrices form a one-parameter group. -/
theorem discPar_mul (s t : ℝ) : discPar s * discPar t = discPar (s + t) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [discPar, Matrix.mul_apply, Fin.sum_univ_two, Complex.ext_iff] <;> ring

@[simp] theorem discPar_zero : discPar 0 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [discPar]

theorem discPar_pow (t : ℝ) : ∀ n : ℕ, discPar t ^ n = discPar (n * t)
  | 0 => by simp
  | (n + 1) => by
      rw [pow_succ, discPar_pow t n, discPar_mul]
      push_cast
      ring_nf

/-- **Matrix-level compatibility of the Cayley transform with translations.**
The Cayley matrix intertwines the real translation `transMat t` with the disc-side
parabolic `discPar t`. -/
theorem cayleyMat_transMat (t : ℝ) :
    cayleyMat * cx (transMat t) = discPar t * cayleyMat := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [cayleyMat, discPar, cx, transMat, Matrix.mul_apply, Fin.sum_univ_two,
      Complex.ext_iff]
  ring

/-- **Möbius-level compatibility**: the Cayley transform conjugates the translation `z ↦ z + t`
into the disc-side parabolic Möbius map of `discPar t`. -/
theorem cayleyC_add_ofReal (t : ℝ) (z : ℂ) (hz : z ≠ -I) :
    cayleyC (z + t) = mobius (discPar t) (cayleyC z) := by
  have hden : cayleyMat 1 0 * z + cayleyMat 1 1 ≠ 0 := by
    have h := cayley_den_ne_zero hz
    simp only [cayleyMat, Matrix.of_apply, Matrix.cons_val', Matrix.cons_val_zero,
      Matrix.cons_val_fin_one, Matrix.cons_val_one, Matrix.empty_val']
    intro hcon
    exact h (by linear_combination hcon)
  have h1 : mobius (cayleyMat * cx (transMat t)) z = cayleyC (z + t) := by
    rw [mobius_mul _ _ _ (by simp [cx, transMat]), transMat_mobius, mobius_cayleyMat]
  have h2 : mobius (discPar t * cayleyMat) z = mobius (discPar t) (cayleyC z) := by
    rw [mobius_mul _ _ _ hden, mobius_cayleyMat]
  rw [← h1, cayleyMat_transMat, h2]

/-- The fixed point of the disc-side parabolic is the boundary point `-1`. -/
theorem discPar_fixed_point (t : ℝ) : mobius (discPar t) (-1) = -1 := by
  simp [mobius, discPar]

/-- For `t ≠ 0` the point `-1` is the *only* fixed point: `discPar t` is genuinely parabolic
(a single fixed point on the boundary circle, none inside the disc). -/
theorem discPar_unique_fixed_point (t : ℝ) (ht : t ≠ 0) (w : ℂ)
    (hden : discPar t 1 0 * w + discPar t 1 1 ≠ 0)
    (hfix : mobius (discPar t) w = w) : w = -1 := by
  have ht' : (t : ℂ) ≠ 0 := by exact_mod_cast ht
  rw [mobius, div_eq_iff hden] at hfix
  simp only [discPar, Matrix.of_apply, Matrix.cons_val', Matrix.cons_val_zero,
    Matrix.cons_val_fin_one, Matrix.cons_val_one, Matrix.empty_val'] at hfix
  have key : (t : ℂ) * I / 2 * (w + 1) ^ 2 = 0 := by linear_combination hfix
  have hne : (t : ℂ) * I / 2 ≠ 0 := by
    simp [ht', Complex.I_ne_zero]
  have hsq : (w + 1) ^ 2 = 0 := by
    rcases mul_eq_zero.1 key with h | h
    · exact absurd h hne
    · exact h
  have hw1 : w + 1 = 0 := by
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hsq
  linear_combination hw1

/-! ## Horocycles -/

/-- The disc-side horocycle function based at the boundary point `-1`:
`discHoro w = (1 - |w|²) / |w + 1|²`.  Its level sets are exactly the horocycles tangent to
the unit circle at `-1`. -/
def discHoro (w : ℂ) : ℝ := (1 - Complex.normSq w) / Complex.normSq (w + 1)

/-- **Horocycle dictionary**: the Cayley transform carries the half-plane height `Im z` to the
disc-side horocycle function based at `-1`.  Thus the horocycles `Im z = c` of the half-plane
correspond exactly to the horocycles `discHoro w = c` of the disc. -/
theorem discHoro_cayleyC (z : ℂ) (hz : z ≠ -I) : discHoro (cayleyC z) = z.im := by
  have hd : (1 : ℂ) - z * I ≠ 0 := cayley_den_ne_zero hz
  have hB : Complex.normSq (1 - z * I) = (1 + z.im) ^ 2 + z.re ^ 2 := by
    simp [Complex.normSq_apply]; ring
  have hBpos : (0 : ℝ) < (1 + z.im) ^ 2 + z.re ^ 2 := by
    rw [← hB]
    simpa [Complex.normSq_pos] using hd
  have hA : Complex.normSq (1 + z * I) = (1 - z.im) ^ 2 + z.re ^ 2 := by
    simp [Complex.normSq_apply]; ring
  have hsum : cayleyC z + 1 = 2 / (1 - z * I) := by
    rw [cayleyC, div_add_one hd]
    congr 1
    ring
  have h1 : Complex.normSq (cayleyC z) =
      Complex.normSq (1 + z * I) / Complex.normSq (1 - z * I) := by
    rw [cayleyC, map_div₀]
  have h2 : Complex.normSq (cayleyC z + 1) = 4 / Complex.normSq (1 - z * I) := by
    rw [hsum, map_div₀]
    norm_num
  rw [discHoro, h1, h2, hA, hB]
  field_simp
  ring

/-- The Cayley transform maps the upper half-plane into the open unit disc. -/
theorem normSq_cayleyC_lt_one (z : ℂ) (hz : 0 < z.im) : Complex.normSq (cayleyC z) < 1 := by
  have hzne : z ≠ -I := by
    intro h
    rw [h] at hz
    simp at hz
    linarith
  have hh := discHoro_cayleyC z hzne
  have hne : cayleyC z + 1 ≠ 0 := by
    intro hcon
    rw [discHoro, hcon] at hh
    simp at hh
    exact absurd hh.symm (ne_of_gt hz)
  have hpos : (0 : ℝ) < Complex.normSq (cayleyC z + 1) := by
    simpa [Complex.normSq_pos] using hne
  rw [discHoro] at hh
  have hmul := (div_eq_iff (ne_of_gt hpos)).1 hh
  nlinarith [hmul, hpos, hz]

/-- Numerator and denominator of the disc-side parabolic Möbius map. -/
def parNum (t : ℝ) (w : ℂ) : ℂ := (1 + (t : ℂ) * I / 2) * w + (t : ℂ) * I / 2

def parDen (t : ℝ) (w : ℂ) : ℂ := -((t : ℂ) * I / 2 * w) + (1 - (t : ℂ) * I / 2)

lemma discPar_num (t : ℝ) (w : ℂ) :
    discPar t 0 0 * w + discPar t 0 1 = parNum t w := by
  simp [discPar, parNum]

lemma discPar_den (t : ℝ) (w : ℂ) :
    discPar t 1 0 * w + discPar t 1 1 = parDen t w := by
  simp [discPar, parDen]

/-- The parabolic Möbius map fixes the "affine sum": `num + den = w + 1`.  This is the algebraic
shadow of the fact that `-1` is the fixed point. -/
theorem parNum_add_parDen (t : ℝ) (w : ℂ) : parNum t w + parDen t w = w + 1 := by
  simp [parNum, parDen]; ring

/-- **The `SU(1,1)` horocycle identity**: `|den|² - |num|² = 1 - |w|²`.  Everything else about
horocycle invariance follows from this single quadratic identity. -/
theorem discPar_normSq_key (t : ℝ) (w : ℂ) :
    Complex.normSq (parDen t w) - Complex.normSq (parNum t w) = 1 - Complex.normSq w := by
  simp [parNum, parDen, Complex.normSq_apply, Complex.add_re, Complex.add_im,
    Complex.mul_re, Complex.mul_im]
  ring

/-- If `w` lies in the closed unit disc, the disc-side parabolic denominator does not vanish:
the parabolic group `discPar` acts on the closed disc without poles. -/
theorem discPar_den_ne_zero (t : ℝ) (w : ℂ) (hw : Complex.normSq w ≤ 1) :
    discPar t 1 0 * w + discPar t 1 1 ≠ 0 := by
  rw [discPar_den]
  intro hD
  have hkey := discPar_normSq_key t w
  rw [hD] at hkey
  simp at hkey
  have hNzero : Complex.normSq (parNum t w) = 0 := by
    have h1 : Complex.normSq (parNum t w) = Complex.normSq w - 1 := by linarith
    have h2 : (0 : ℝ) ≤ Complex.normSq (parNum t w) := Complex.normSq_nonneg _
    linarith
  have hN : parNum t w = 0 := by
    simpa [Complex.normSq_eq_zero] using hNzero
  have hw1 : w + 1 = 0 := by
    rw [← parNum_add_parDen t w, hN, hD]; ring
  have hwm : w = -1 := by linear_combination hw1
  rw [hwm] at hD
  simp [parDen] at hD

/-- **Horocycle invariance on the disc**: the parabolic `discPar t` preserves the horocycle
function based at its fixed point `-1`.  This is the disc-side form of the statement that a
translation preserves each horizontal line of the half-plane. -/
theorem discPar_preserves_discHoro (t : ℝ) (w : ℂ)
    (hden : discPar t 1 0 * w + discPar t 1 1 ≠ 0) (hw : w + 1 ≠ 0) :
    discHoro (mobius (discPar t) w) = discHoro w := by
  rw [discPar_den] at hden
  have hDpos : (0 : ℝ) < Complex.normSq (parDen t w) := by
    simpa [Complex.normSq_pos] using hden
  have hw1 : (0 : ℝ) < Complex.normSq (w + 1) := by
    simpa [Complex.normSq_pos] using hw
  have hmob : mobius (discPar t) w = parNum t w / parDen t w := by
    rw [mobius, discPar_num, discPar_den]
  have hshift : mobius (discPar t) w + 1 = (w + 1) / parDen t w := by
    rw [hmob, div_add_one hden, parNum_add_parDen]
  have hquot : Complex.normSq (mobius (discPar t) w)
      = Complex.normSq (parNum t w) / Complex.normSq (parDen t w) := by
    rw [hmob, map_div₀]
  rw [discHoro, discHoro, hquot, hshift, map_div₀]
  have hsplit : (1 - Complex.normSq (parNum t w) / Complex.normSq (parDen t w)) /
      (Complex.normSq (w + 1) / Complex.normSq (parDen t w))
      = (Complex.normSq (parDen t w) - Complex.normSq (parNum t w))
          / Complex.normSq (w + 1) := by
    field_simp
  rw [hsplit, discPar_normSq_key]

/-- The disc-side parabolic preserves the open unit disc (a consequence of the same identity). -/
theorem discPar_maps_disc (t : ℝ) (w : ℂ) (hw : Complex.normSq w < 1) :
    Complex.normSq (mobius (discPar t) w) < 1 := by
  have hden : parDen t w ≠ 0 := by
    have := discPar_den_ne_zero t w (le_of_lt hw)
    rwa [discPar_den] at this
  have hDpos : (0 : ℝ) < Complex.normSq (parDen t w) := by
    simpa [Complex.normSq_pos] using hden
  have hkey := discPar_normSq_key t w
  have hmob : mobius (discPar t) w = parNum t w / parDen t w := by
    rw [mobius, discPar_num, discPar_den]
  rw [hmob, map_div₀, div_lt_one hDpos]
  linarith

/-! ## From the horocycle equation to the parabolic trace condition -/

/-- Real Möbius maps: the imaginary part transforms by `det / |c z + d|²`. -/
theorem mobius_cx_im (M : Matrix (Fin 2) (Fin 2) ℝ) (z : ℂ)
    (h : (M 1 0 : ℂ) * z + (M 1 1 : ℝ) ≠ 0) :
    (mobius (cx M) z).im
      = M.det * z.im / Complex.normSq ((M 1 0 : ℂ) * z + (M 1 1 : ℝ)) := by
  rw [mobius_cx, mobius_im_ofReal _ _ _ _ _ h, Matrix.det_fin_two]

/-- For a determinant-one real matrix the Möbius denominator is nonzero on the
upper half-plane. -/
theorem den_ne_zero_of_det_one (M : Matrix (Fin 2) (Fin 2) ℝ) (hdet : M.det = 1)
    (z : ℂ) (hz : 0 < z.im) : (M 1 0 : ℂ) * z + (M 1 1 : ℝ) ≠ 0 := by
  intro h
  rw [Complex.ext_iff] at h
  obtain ⟨h1, h2⟩ := h
  simp [Complex.add_re, Complex.add_im, Complex.mul_re, Complex.mul_im] at h1 h2
  rcases h2 with hc | him
  · rw [hc] at h1
    simp at h1
    rw [Matrix.det_fin_two, hc, h1] at hdet
    norm_num at hdet
  · exact absurd him (ne_of_gt hz)

/-- Auxiliary computation: `|c (yI) + d|² = d² + (c y)²`. -/
theorem normSq_vertical (c d y : ℝ) :
    Complex.normSq ((c : ℂ) * ((y : ℝ) * I) + (d : ℝ)) = d ^ 2 + (c * y) ^ 2 := by
  simp [Complex.normSq_apply]
  ring

/-- **Main bridge.**  A determinant-one real matrix preserves the horocycle foliation
`Im z = const` of the upper half-plane if and only if it is `± transMat t`; that is, exactly the
unipotent (parabolic) matrices fixing the cusp `∞`, up to sign. -/
theorem horocycle_preserving_iff_translation (M : Matrix (Fin 2) (Fin 2) ℝ)
    (hdet : M.det = 1) :
    (∀ z : ℂ, 0 < z.im → (mobius (cx M) z).im = z.im) ↔
      ∃ t : ℝ, M = transMat t ∨ M = -transMat t := by
  constructor
  · intro hpres
    have key : ∀ y : ℝ, 0 < y →
        Complex.normSq ((M 1 0 : ℂ) * ((y : ℝ) * I) + (M 1 1 : ℝ)) = 1 := by
      intro y hy
      have hzim : (0 : ℝ) < (((y : ℝ) : ℂ) * I).im := by simpa using hy
      have hne := den_ne_zero_of_det_one M hdet (((y : ℝ) : ℂ) * I) hzim
      have hp := hpres (((y : ℝ) : ℂ) * I) hzim
      rw [mobius_cx_im M _ hne, hdet] at hp
      have hpos : (0 : ℝ) < Complex.normSq ((M 1 0 : ℂ) * (((y : ℝ) : ℂ) * I) + (M 1 1 : ℝ)) := by
        simpa [Complex.normSq_pos] using hne
      rw [div_eq_iff (ne_of_gt hpos)] at hp
      have him : ((((y : ℝ) : ℂ)) * I).im = y := by simp
      rw [him] at hp
      nlinarith [hp, hy]
    have e1 := key 1 (by norm_num)
    have e2 := key 2 (by norm_num)
    rw [normSq_vertical] at e1 e2
    have hc0 : M 1 0 = 0 := by nlinarith [e1, e2, sq_nonneg (M 1 0)]
    have hd1 : M 1 1 ^ 2 = 1 := by rw [hc0] at e1; nlinarith [e1]
    have hdet' : M 0 0 * M 1 1 = 1 := by
      rw [Matrix.det_fin_two, hc0] at hdet; linarith
    have hdd : M 1 1 = 1 ∨ M 1 1 = -1 := by
      have hfac : (M 1 1 - 1) * (M 1 1 + 1) = 0 := by nlinarith [hd1]
      rcases mul_eq_zero.1 hfac with h | h
      · exact Or.inl (by linarith)
      · exact Or.inr (by linarith)
    rcases hdd with hd | hd
    · refine ⟨M 0 1, Or.inl ?_⟩
      have ha : M 0 0 = 1 := by rw [hd] at hdet'; linarith
      ext i j
      fin_cases i <;> fin_cases j <;> simp [transMat, ha, hc0, hd]
    · refine ⟨-(M 0 1), Or.inr ?_⟩
      have ha : M 0 0 = -1 := by rw [hd] at hdet'; linarith
      ext i j
      fin_cases i <;> fin_cases j <;> simp [transMat, ha, hc0, hd]
  · rintro ⟨t, rfl | rfl⟩ <;> intro z hz
    · rw [transMat_mobius]; simp
    · have hval : mobius (cx (-transMat t)) z = z + t := by
        simp [mobius, cx, transMat]
        field_simp
        ring
      rw [hval]; simp

/-- **Horocycle equation ⟹ parabolic trace condition.**  Preserving the horocycle foliation
forces the trace to be extremal: `tr² = 4 det`. -/
theorem horocycle_preserving_parabolic (M : Matrix (Fin 2) (Fin 2) ℝ) (hdet : M.det = 1)
    (hpres : ∀ z : ℂ, 0 < z.im → (mobius (cx M) z).im = z.im) :
    M.trace ^ 2 = 4 * M.det := by
  obtain ⟨t, h | h⟩ := (horocycle_preserving_iff_translation M hdet).1 hpres
  · rw [h, transMat_trace, transMat_det]; norm_num
  · rw [h]
    simp [transMat, Matrix.trace_fin_two, Matrix.det_fin_two]
    norm_num

/-- **Guarded converse**: the parabolic trace condition together with fixing the cusp `∞`
(i.e. `c = 0`) implies horocycle preservation. -/
theorem parabolic_fixing_infty_preserves_horocycles (M : Matrix (Fin 2) (Fin 2) ℝ)
    (hdet : M.det = 1) (htr : M.trace ^ 2 = 4 * M.det) (hc : M 1 0 = 0) :
    ∀ z : ℂ, 0 < z.im → (mobius (cx M) z).im = z.im := by
  intro z hz
  have hne := den_ne_zero_of_det_one M hdet z hz
  have had : M 0 0 * M 1 1 = 1 := by
    rw [Matrix.det_fin_two, hc] at hdet; linarith
  have hsum : (M 0 0 + M 1 1) ^ 2 = 4 := by
    rw [Matrix.trace_fin_two, hdet] at htr
    simpa using htr
  have hd2 : M 1 1 ^ 2 = 1 := by nlinarith [had, hsum]
  rw [mobius_cx_im M z hne, hdet]
  have hns : Complex.normSq ((M 1 0 : ℂ) * z + (M 1 1 : ℝ)) = 1 := by
    rw [hc]
    simp [Complex.normSq_apply]
    nlinarith [hd2]
  rw [hns]
  ring

/-- **The guard is necessary.**  The matrix `!![1, 0; 1, 1]` is parabolic (`tr² = 4 det`) yet it
moves the horocycle `Im z = 1` to height `1/2`: the trace condition alone does *not* imply
horocycle preservation — the parabolic must also fix the cusp at `∞`. -/
theorem parabolic_not_horocycle_preserving :
    let N : Matrix (Fin 2) (Fin 2) ℝ := !![1, 0; 1, 1]
    N.det = 1 ∧ N.trace ^ 2 = 4 * N.det ∧ (mobius (cx N) I).im = 1 / 2 := by
  intro N
  have hdet : N.det = 1 := by simp [N, Matrix.det_fin_two]
  refine ⟨hdet, ?_, ?_⟩
  · rw [hdet]
    simp [N, Matrix.trace_fin_two]
    norm_num
  · have hne : ((N 1 0 : ℝ) : ℂ) * I + ((N 1 1 : ℝ) : ℂ) ≠ 0 := by
      simp [N, Complex.ext_iff]
    rw [mobius_cx_im N I hne, hdet]
    simp [N, Complex.normSq_apply]
    norm_num

/-! ## The elliptic contrast: the catalog `spb` operation -/

/-- The disc-side rotation matrix `!![1 + a I, 0; 0, 1 - a I]`. -/
def rotMat (a : ℝ) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![1 + (a : ℂ) * I, 0; 0, 1 - (a : ℂ) * I]

/-- **Cayley conjugation of the elliptic catalog matrix**: `spbMat a` is intertwined with a
diagonal rotation of the disc.  Compare `cayleyMat_transMat`, where the parabolic `transMat t`
is intertwined with the unipotent `discPar t`. -/
theorem cayleyMat_spbMat (a : ℝ) :
    cayleyMat * cx (spbMat a) = rotMat a * cayleyMat := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [cayleyMat, rotMat, cx, spbMat, Matrix.mul_apply, Fin.sum_univ_two,
      Complex.ext_iff]

/-- Conjugation preserves the trace: `2` on the half-plane side, `2` on the disc side. -/
theorem rotMat_trace (a : ℝ) : (rotMat a).trace = ((spbMat a).trace : ℂ) := by
  simp [rotMat, spbMat, Matrix.trace_fin_two]

/-- Conjugation preserves the determinant: `1 + a²` on both sides. -/
theorem rotMat_det (a : ℝ) : (rotMat a).det = ((spbMat a).det : ℂ) := by
  simp [rotMat, spbMat, Matrix.det_fin_two]
  linear_combination (-(a : ℂ) ^ 2) * Complex.I_sq

/-- The Möbius action of `rotMat a` is multiplication by the unimodular number `cayley a`. -/
theorem mobius_rotMat (a : ℝ) (w : ℂ) : mobius (rotMat a) w = cayley a * w := by
  simp only [mobius, rotMat, cayley, Matrix.of_apply, Matrix.cons_val', Matrix.cons_val_zero,
    Matrix.cons_val_fin_one, Matrix.cons_val_one, Matrix.empty_val']
  rw [div_mul_eq_mul_div]
  congr 1 <;> ring

/-- **The Cayley transform linearises the catalog operation `spb`**: on the unit circle the
"velocity addition" `spb x y = (x + y)/(1 - x y)` becomes ordinary multiplication. -/
theorem cayleyC_spb (x y : ℝ) (h : 1 - x * y ≠ 0) :
    cayley (spb x y) = cayley x * cayley y := by
  have hx : (1 : ℂ) - (x : ℂ) * I ≠ 0 := by
    intro hcon
    have := congrArg Complex.re hcon
    simp at this
  have hy : (1 : ℂ) - (y : ℂ) * I ≠ 0 := by
    intro hcon
    have := congrArg Complex.re hcon
    simp at this
  have hden : (1 : ℂ) - ((spb x y : ℝ) : ℂ) * I ≠ 0 := by
    intro hcon
    have := congrArg Complex.re hcon
    simp at this
  have hcC : ((1 : ℂ) - (x : ℂ) * (y : ℂ)) ≠ 0 := by
    have : ((1 - x * y : ℝ) : ℂ) ≠ 0 := Complex.ofReal_ne_zero.2 h
    push_cast at this
    exact this
  have hspb : ((spb x y : ℝ) : ℂ) = ((x : ℂ) + y) / (1 - (x : ℂ) * y) := by
    rw [spb]
    push_cast
    ring
  rw [cayley, cayley, cayley, div_mul_div_comm, hspb]
  rw [div_eq_div_iff (by rwa [hspb] at hden) (mul_ne_zero hx hy)]
  field_simp
  ring_nf
  have h3 : I ^ 3 = -I := by rw [pow_succ, Complex.I_sq]; ring
  simp only [Complex.I_sq, h3]
  ring

/-- Consistency of the two dictionaries: rotating a Cayley image by `rotMat a` is the Cayley
image of the `spb`-translate.  This is the elliptic analogue of `cayleyC_add_ofReal`. -/
theorem mobius_rotMat_cayley (a x : ℝ) (h : 1 - x * a ≠ 0) :
    mobius (rotMat a) (cayley x) = cayley (spb x a) := by
  rw [mobius_rotMat, cayleyC_spb x a h, mul_comm]

/-- **Trichotomy of the Cayley dictionary.**  Under Cayley conjugation the catalog families are
distinguished by their discriminants: translations are exactly parabolic (`tr² - 4 det = 0`)
while the catalog matrices `spbMat a` are elliptic for `a ≠ 0` (`tr² - 4 det < 0`). -/
theorem discriminant_dichotomy (t a : ℝ) (ha : a ≠ 0) :
    (transMat t).trace ^ 2 - 4 * (transMat t).det = 0 ∧
      (spbMat a).trace ^ 2 - 4 * (spbMat a).det < 0 := by
  constructor
  · rw [transMat_trace, transMat_det]; norm_num
  · have htr : (spbMat a).trace = 2 := by
      simp [spbMat, Matrix.trace_fin_two]
      norm_num
    have hdet : (spbMat a).det = 1 + a ^ 2 := by
      simp [spbMat, Matrix.det_fin_two]
      ring
    rw [htr, hdet]
    have ha2 : 0 < a ^ 2 := by rcases lt_or_gt_of_ne ha with h | h <;> nlinarith
    nlinarith [ha2]

/-! ## Second cycle: faithfulness, the boundary circle, and fixed points -/

/-- The translation subgroup is a faithful one-parameter subgroup. -/
theorem transMat_injective {s t : ℝ} (h : transMat s = transMat t) : s = t := by
  have := congrFun (congrFun h 0) 1
  simpa [transMat] using this

/-- The disc-side parabolic subgroup is faithful as well: `t ↦ discPar t` is injective. -/
theorem discPar_injective {s t : ℝ} (h : discPar s = discPar t) : s = t := by
  have h01 := congrFun (congrFun h 0) 1
  simp only [discPar, Matrix.of_apply, Matrix.cons_val', Matrix.cons_val_zero,
    Matrix.cons_val_fin_one, Matrix.cons_val_one, Matrix.empty_val'] at h01
  have hI : (s : ℂ) * I = (t : ℂ) * I := by linear_combination 2 * h01
  have hst : (s : ℂ) = (t : ℂ) := mul_right_cancel₀ Complex.I_ne_zero hI
  exact_mod_cast hst

/-- The Cayley transform never hits the parabolic fixed point `-1`. -/
theorem cayley_ne_neg_one (x : ℝ) : cayley x ≠ -1 := by
  intro h
  have hd : (1 : ℂ) - (x : ℂ) * I ≠ 0 := by
    intro hcon
    have := congrArg Complex.re hcon
    simp at this
  rw [cayley, div_eq_iff hd] at h
  have h2 : (2 : ℂ) = 0 := by linear_combination h
  norm_num at h2

/-- The Cayley transform is injective on `ℝ`. -/
theorem cayley_injective {x y : ℝ} (h : cayley x = cayley y) : x = y := by
  have hx : (1 : ℂ) - (x : ℂ) * I ≠ 0 := by
    intro hcon
    have := congrArg Complex.re hcon
    simp at this
  have hy : (1 : ℂ) - (y : ℂ) * I ≠ 0 := by
    intro hcon
    have := congrArg Complex.re hcon
    simp at this
  rw [cayley, cayley, div_eq_div_iff hx hy] at h
  have h2 : (2 : ℂ) * I * ((x : ℂ) - y) = 0 := by linear_combination h
  have h3 : ((x : ℂ) - y) = 0 := by
    rcases mul_eq_zero.1 h2 with h4 | h4
    · rcases mul_eq_zero.1 h4 with h5 | h5
      · norm_num at h5
      · exact absurd h5 Complex.I_ne_zero
    · exact h4
  have : (x : ℂ) = (y : ℂ) := by linear_combination h3
  exact_mod_cast this

/-- **The Cayley transform parametrises the punctured boundary circle.**  Every unimodular
`w ≠ -1` is `cayley x` for a (unique) real `x`.  Together with `cayley_normSq` and
`cayley_injective` this identifies `ℝ` with the circle minus the parabolic fixed point. -/
theorem cayley_surjective_circle (w : ℂ) (hw : Complex.normSq w = 1) (hne : w ≠ -1) :
    ∃ x : ℝ, cayley x = w := by
  have hw1 : w + 1 ≠ 0 := by
    intro h
    exact hne (by linear_combination h)
  refine ⟨(-I * (w - 1) / (w + 1)).re, ?_⟩
  have hre : ((-I * (w - 1) / (w + 1)).re : ℂ) = -I * (w - 1) / (w + 1) := by
    rw [Complex.ext_iff]
    refine ⟨by simp, ?_⟩
    simp only [Complex.ofReal_im]
    rw [Complex.div_im]
    simp only [Complex.mul_re, Complex.mul_im, Complex.neg_re, Complex.neg_im, Complex.I_re,
      Complex.I_im, Complex.sub_re, Complex.sub_im, Complex.one_re, Complex.one_im,
      Complex.add_re, Complex.add_im, Complex.normSq_apply]
    have hns : w.re ^ 2 + w.im ^ 2 = 1 := by
      rw [Complex.normSq_apply] at hw; nlinarith [hw]
    have hnsw : Complex.normSq (w + 1) = (w.re + 1) ^ 2 + w.im ^ 2 := by
      simp [Complex.normSq_apply]; ring
    have hpos : (0 : ℝ) < Complex.normSq (w + 1) := by
      simpa [Complex.normSq_pos] using hw1
    have hden : (0 : ℝ) < (w.re + 1) ^ 2 + w.im ^ 2 := by rw [← hnsw]; exact hpos
    field_simp
    rw [eq_comm, div_eq_zero_iff]
    left
    nlinarith [hns]
  have hx : (1 : ℂ) - ((-I * (w - 1) / (w + 1)).re : ℝ) * I ≠ 0 := by
    intro hcon
    have := congrArg Complex.re hcon
    simp at this
  rw [cayley, div_eq_iff hx, hre]
  field_simp
  simp only [Complex.I_sq]
  ring

/-- **The unique fixed point of a real parabolic.**  If `M` has determinant one, trace two and
`c ≠ 0`, then `x₀ = (a - d)/(2c)` is a fixed point of its Möbius action. -/
theorem parabolic_fixed_point (M : Matrix (Fin 2) (Fin 2) ℝ) (hdet : M.det = 1)
    (htr : M.trace = 2) (hc : M 1 0 ≠ 0) :
    mobius (cx M) (((M 0 0 - M 1 1) / (2 * M 1 0) : ℝ) : ℂ)
      = (((M 0 0 - M 1 1) / (2 * M 1 0) : ℝ) : ℂ) := by
  set a := M 0 0
  set b := M 0 1
  set c := M 1 0
  set d := M 1 1
  have hsum : a + d = 2 := by rw [Matrix.trace_fin_two] at htr; linarith
  have hdet' : a * d - b * c = 1 := by rw [Matrix.det_fin_two] at hdet; linarith
  set x0 : ℝ := (a - d) / (2 * c) with hx0
  have hdenR : c * x0 + d = 1 := by
    rw [hx0]
    field_simp
    linarith
  have hfix : a * x0 + b = x0 * (c * x0 + d) := by
    rw [hx0]
    field_simp
    nlinarith [hsum, hdet', sq_nonneg (a - d)]
  have hdenC : (c : ℂ) * (x0 : ℝ) + (d : ℝ) ≠ 0 := by
    have : ((c * x0 + d : ℝ) : ℂ) = 1 := by rw [hdenR]; norm_num
    push_cast at this
    rw [this]
    norm_num
  have hfixC : (a : ℂ) * (x0 : ℝ) + (b : ℝ) = (x0 : ℝ) * ((c : ℂ) * (x0 : ℝ) + (d : ℝ)) := by
    exact_mod_cast hfix
  rw [mobius_cx, div_eq_iff hdenC]
  exact hfixC

/-! ## Classification: every real parabolic is conjugate to a translation -/

/-- Complexification is multiplicative. -/
theorem cx_mul (M N : Matrix (Fin 2) (Fin 2) ℝ) : cx (M * N) = cx M * cx N := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [cx, Matrix.mul_apply, Fin.sum_univ_two]

/-- Complexification preserves determinants. -/
theorem cx_det (M : Matrix (Fin 2) (Fin 2) ℝ) : (cx M).det = ((M.det : ℝ) : ℂ) := by
  simp [cx, Matrix.det_fin_two]

/-- **Conjugacy classification of real parabolics.**  A determinant-one real matrix with trace
`2` which is not the identity is `SL₂(ℝ)`-conjugate to a nontrivial translation:
`M P = P (transMat s)` with `det P = 1` and `s ≠ 0`. -/
theorem parabolic_conjugate_to_translation (M : Matrix (Fin 2) (Fin 2) ℝ)
    (hdet : M.det = 1) (htr : M.trace = 2) (hM : M ≠ 1) :
    ∃ (P : Matrix (Fin 2) (Fin 2) ℝ) (s : ℝ),
      P.det = 1 ∧ s ≠ 0 ∧ M * P = P * transMat s := by
  have hsum : M 0 0 + M 1 1 = 2 := by rw [Matrix.trace_fin_two] at htr; linarith
  have hdet' : M 0 0 * M 1 1 - M 0 1 * M 1 0 = 1 := by
    rw [Matrix.det_fin_two] at hdet; linarith
  by_cases hc : M 1 0 = 0
  · -- `M` already fixes `∞`; then `M = transMat b` with `b ≠ 0`.
    have haa : M 0 0 * M 1 1 = 1 := by rw [hc] at hdet'; linarith
    have ha1 : M 0 0 = 1 := by nlinarith [hsum, haa]
    have hd1 : M 1 1 = 1 := by linarith
    have hb : M 0 1 ≠ 0 := by
      intro hb0
      apply hM
      ext i j
      fin_cases i <;> fin_cases j <;> simp [ha1, hd1, hc, hb0]
    refine ⟨1, M 0 1, by simp, hb, ?_⟩
    rw [mul_one, one_mul]
    ext i j
    fin_cases i <;> fin_cases j <;> simp [transMat, ha1, hd1, hc]
  · -- `M` moves the cusp; conjugate by an explicit basis change.
    refine ⟨!![-(M 0 0 - 1) / M 1 0, 1; -1, 0], -M 1 0, ?_, by simpa using hc, ?_⟩
    · simp [Matrix.det_fin_two]
    · have hbc : M 0 1 * M 1 0 = -(M 0 0 - 1) ^ 2 := by
        linear_combination -hdet' + M 0 0 * hsum
      ext i j
      fin_cases i <;> fin_cases j <;>
        simp [transMat, Matrix.mul_apply, Fin.sum_univ_two] <;> field_simp <;> nlinarith [hbc, hsum]

/-- **Cayley form of the classification.**  Every non-identity parabolic of `SL₂(ℝ)` is
conjugate, inside `GL₂(ℂ)` and via the Cayley matrix, to a disc-side horocyclic element
`discPar s`.  Consequently every such parabolic preserves a horocycle foliation of the disc
based at the image of its fixed point. -/
theorem parabolic_cayley_conjugate (M : Matrix (Fin 2) (Fin 2) ℝ)
    (hdet : M.det = 1) (htr : M.trace = 2) (hM : M ≠ 1) :
    ∃ (X : Matrix (Fin 2) (Fin 2) ℂ) (s : ℝ),
      IsUnit X.det ∧ s ≠ 0 ∧ cx M * X = X * discPar s := by
  obtain ⟨P, s, hP, hs, hMP⟩ := parabolic_conjugate_to_translation M hdet htr hM
  refine ⟨cx P * cayleyMat⁻¹, s, ?_, hs, ?_⟩
  · rw [Matrix.det_mul, cx_det, hP]
    simp only [Complex.ofReal_one, one_mul]
    rw [Matrix.det_nonsing_inv]
    exact isUnit_ringInverse.mpr cayleyMat_isUnit
  · have hAinv : cayleyMat⁻¹ * discPar s = cx (transMat s) * cayleyMat⁻¹ := by
      have h := cayleyMat_transMat s
      calc cayleyMat⁻¹ * discPar s
          = cayleyMat⁻¹ * (discPar s * (cayleyMat * cayleyMat⁻¹)) := by
            rw [Matrix.mul_nonsing_inv _ cayleyMat_isUnit, mul_one]
        _ = cayleyMat⁻¹ * ((discPar s * cayleyMat) * cayleyMat⁻¹) := by rw [mul_assoc]
        _ = cayleyMat⁻¹ * ((cayleyMat * cx (transMat s)) * cayleyMat⁻¹) := by rw [h]
        _ = (cayleyMat⁻¹ * cayleyMat) * (cx (transMat s) * cayleyMat⁻¹) := by
            simp [mul_assoc]
        _ = cx (transMat s) * cayleyMat⁻¹ := by
            rw [Matrix.nonsing_inv_mul _ cayleyMat_isUnit, one_mul]
    calc cx M * (cx P * cayleyMat⁻¹) = cx (M * P) * cayleyMat⁻¹ := by rw [cx_mul, mul_assoc]
      _ = cx (P * transMat s) * cayleyMat⁻¹ := by rw [hMP]
      _ = cx P * (cx (transMat s) * cayleyMat⁻¹) := by rw [cx_mul, mul_assoc]
      _ = cx P * (cayleyMat⁻¹ * discPar s) := by rw [hAinv]
      _ = cx P * cayleyMat⁻¹ * discPar s := by rw [mul_assoc]

end CatalogShared.ModularCayley

end