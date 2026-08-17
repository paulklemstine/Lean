import Geometry.TaxicabCabtaxi

/-!
# From rational points on the Fermat cubic to integers with many cube representations

The mission's Conjecture 1 (`Taxicab n` exists for every `n`) rests on two steps:

1. *arithmetic geometry*: produce `n` distinct rational points on a single affine cubic
   `x³ + y³ = q`;
2. *clearing denominators*: collapse those `n` rational points onto one integer carrying
   `n` integer representations.

Step 2 is elementary and is proved here in full (`signed_rational_transfer`), so that the
whole conjecture is reduced to step 1 (`unbounded_of_infinite_rational_orbit`). Step 1's
engine, the chord–tangent construction, is also made explicit and verified as an algebraic
identity (`cubic_tangent`), together with the fact that it always produces a genuinely new
unordered pair when started from a positive rational point (`cubic_tangent_ne_fst`,
`cubic_tangent_ne_snd`). What is *not* proved — and is exactly the arithmetic input any
full proof must supply — is that the tangent orbit of some point is infinite.
-/

namespace Taxicab

open Finset

/-! ## Clearing denominators -/

/-- If the denominator of `r` divides `D`, then `D * r` is an integer. -/
private theorem exists_int_mul {r : ℚ} {D : ℕ} (h : r.den ∣ D) :
    ∃ k : ℤ, (D : ℚ) * r = (k : ℚ) := by
  obtain ⟨m, hm⟩ := h
  refine ⟨r.num * m, ?_⟩
  have hden : ((r.den : ℚ)) * r = (r.num : ℚ) := Rat.den_mul_eq_num r
  subst hm
  push_cast
  linear_combination (m : ℚ) * hden

/-- Numerator formula for a cleared denominator. -/
private theorem clear_den {r : ℚ} {D : ℕ} (h : r.den ∣ D) :
    ((((D : ℚ) * r).num : ℤ) : ℚ) = (D : ℚ) * r := by
  obtain ⟨k, hk⟩ := exists_int_mul h
  rw [hk, Rat.num_intCast]

/-- **Transfer theorem (step 2).** A finite family of *rational* points with nonzero
coordinates on one affine cubic `x³ + y³ = q` (`q > 0`) yields a single positive integer
`M` with at least that many representations as a sum of two nonzero integer cubes:
scale every coordinate by a common denominator `D` and land on `M = D³q`. -/
theorem signed_rational_transfer (S : Finset (ℚ × ℚ)) (q : ℚ) (hq : 0 < q)
    (hS : ∀ p ∈ S, p.1 ≠ 0 ∧ p.2 ≠ 0 ∧ p.1 ≤ p.2 ∧ p.1 ^ 3 + p.2 ^ 3 = q) :
    ∃ M : ℕ, 0 < M ∧ S.card ≤ (signedCubeReps M).card := by
  rcases Finset.eq_empty_or_nonempty S with rfl | ⟨p₀, hp₀⟩
  · exact ⟨1, by norm_num, by simp⟩
  -- a common denominator for all coordinates
  set D : ℕ := ∏ p ∈ S, p.1.den * p.2.den with hD
  have hDpos : 0 < D := by
    refine Finset.prod_pos fun p _ => ?_
    exact Nat.mul_pos p.1.pos p.2.pos
  have hDQ : (0 : ℚ) < (D : ℚ) := by exact_mod_cast hDpos
  have hdvd : ∀ p ∈ S, p.1.den ∣ D ∧ p.2.den ∣ D := by
    intro p hp
    have hmem : p.1.den * p.2.den ∣ D := Finset.dvd_prod_of_mem _ hp
    exact ⟨dvd_trans (Dvd.intro _ rfl) hmem, dvd_trans (Dvd.intro_left _ rfl) hmem⟩
  -- the scaled coordinates
  set f : ℚ × ℚ → ℤ × ℤ := fun p => ((((D : ℚ) * p.1).num), (((D : ℚ) * p.2).num)) with hf
  have hcast : ∀ p ∈ S, (((f p).1 : ℤ) : ℚ) = (D : ℚ) * p.1 ∧
      (((f p).2 : ℤ) : ℚ) = (D : ℚ) * p.2 := by
    intro p hp
    exact ⟨clear_den (hdvd p hp).1, clear_den (hdvd p hp).2⟩
  have hsum : ∀ p ∈ S, (((f p).1 ^ 3 + (f p).2 ^ 3 : ℤ) : ℚ) = (D : ℚ) ^ 3 * q := by
    intro p hp
    obtain ⟨h1, h2⟩ := hcast p hp
    have h3 := (hS p hp).2.2.2
    push_cast
    rw [h1, h2, ← h3]
    ring
  -- the common value is a positive integer
  set K : ℤ := (f p₀).1 ^ 3 + (f p₀).2 ^ 3 with hK
  have hKQ : (K : ℚ) = (D : ℚ) ^ 3 * q := hsum p₀ hp₀
  have hKpos : 0 < K := by
    have : (0 : ℚ) < (K : ℚ) := by rw [hKQ]; positivity
    exact_mod_cast this
  refine ⟨K.toNat, by omega, ?_⟩
  have hKtoNat : ((K.toNat : ℤ) : ℚ) = (D : ℚ) ^ 3 * q := by
    rw [Int.toNat_of_nonneg hKpos.le]; exact hKQ
  have hKnat : (0 : ℕ) < K.toNat := by omega
  refine Finset.card_le_card_of_injOn f (fun p hp => ?_) ?_
  · -- the scaled point is a signed representation of `M`
    obtain ⟨h1, h2⟩ := hcast p hp
    obtain ⟨hne1, hne2, hle, _⟩ := hS p hp
    simp only [Finset.mem_coe]
    rw [mem_signedCubeReps hKnat]
    refine ⟨?_, ?_, ?_, ?_⟩
    · intro hc
      rw [hc] at h1
      simp only [Int.cast_zero] at h1
      rcases mul_eq_zero.mp h1.symm with hz | hz
      · exact hDQ.ne' hz
      · exact hne1 hz
    · intro hc
      rw [hc] at h2
      simp only [Int.cast_zero] at h2
      rcases mul_eq_zero.mp h2.symm with hz | hz
      · exact hDQ.ne' hz
      · exact hne2 hz
    · have : (((f p).1 : ℤ) : ℚ) ≤ (((f p).2 : ℤ) : ℚ) := by
        rw [h1, h2]
        exact mul_le_mul_of_nonneg_left hle hDQ.le
      exact_mod_cast this
    · have hq' : (((f p).1 ^ 3 + (f p).2 ^ 3 : ℤ) : ℚ) = ((K.toNat : ℤ) : ℚ) := by
        rw [hsum p hp, hKtoNat]
      have : (f p).1 ^ 3 + (f p).2 ^ 3 = (K.toNat : ℤ) := by exact_mod_cast hq'
      simpa using this
  · -- distinct rational points stay distinct after scaling
    intro p hp p' hp' heq
    obtain ⟨h1, h2⟩ := hcast p hp
    obtain ⟨h1', h2'⟩ := hcast p' hp'
    have e1 : (D : ℚ) * p.1 = (D : ℚ) * p'.1 := by rw [← h1, ← h1', heq]
    have e2 : (D : ℚ) * p.2 = (D : ℚ) * p'.2 := by rw [← h2, ← h2', heq]
    exact Prod.ext (mul_left_cancel₀ hDQ.ne' e1) (mul_left_cancel₀ hDQ.ne' e2)

/-- **Conjecture 1, reduced to its arithmetic input.** If some affine cubic `x³ + y³ = q`
(`q > 0`) carries infinitely many distinct rational points with nonzero coordinates —
which is what a rational point of infinite order provides — then for every `n` there is a
positive integer with at least `n` representations as a sum of two nonzero integer cubes. -/
theorem unbounded_of_infinite_rational_orbit (q : ℚ) (hq : 0 < q) (P : ℕ → ℚ × ℚ)
    (hP : ∀ k, (P k).1 ≠ 0 ∧ (P k).2 ≠ 0 ∧ (P k).1 ≤ (P k).2 ∧
      (P k).1 ^ 3 + (P k).2 ^ 3 = q)
    (hinj : Function.Injective P) (n : ℕ) :
    ∃ M : ℕ, 0 < M ∧ n ≤ (signedCubeReps M).card := by
  obtain ⟨M, hM, hcard⟩ := signed_rational_transfer ((Finset.range n).image P) q hq
    (by
      intro p hp
      obtain ⟨k, _, rfl⟩ := Finset.mem_image.mp hp
      exact hP k)
  refine ⟨M, hM, le_trans ?_ hcard⟩
  rw [Finset.card_image_of_injective _ hinj, Finset.card_range]

/-! ## The chord–tangent engine -/

/-- **Tangent duplication on the affine Fermat cubic.** If `(x, y)` is a rational point of
`x³ + y³ = N` with `x³ ≠ y³`, the tangent line at `(x, y)` meets the cubic again in the
rational point `(x(x³+2y³)/(x³−y³), −y(2x³+y³)/(x³−y³))`. -/
theorem cubic_tangent (x y N : ℚ) (hxy : x ^ 3 ≠ y ^ 3) (h : x ^ 3 + y ^ 3 = N) :
    (x * (x ^ 3 + 2 * y ^ 3) / (x ^ 3 - y ^ 3)) ^ 3 +
      (-(y * (2 * x ^ 3 + y ^ 3)) / (x ^ 3 - y ^ 3)) ^ 3 = N := by
  have hd : x ^ 3 - y ^ 3 ≠ 0 := sub_ne_zero.mpr hxy
  subst h
  field_simp
  ring

/-- The tangent construction never returns the first coordinate it started from. -/
theorem cubic_tangent_ne_fst {x y : ℚ} (hx : x ≠ 0) (hy : y ≠ 0) (hxy : x ^ 3 ≠ y ^ 3) :
    x * (x ^ 3 + 2 * y ^ 3) / (x ^ 3 - y ^ 3) ≠ x := by
  have hd : x ^ 3 - y ^ 3 ≠ 0 := sub_ne_zero.mpr hxy
  intro hc
  rw [div_eq_iff hd] at hc
  have h3 : 3 * (x * y ^ 3) = 0 := by linarith [hc]
  have : x * y ^ 3 = 0 := by linarith
  rcases mul_eq_zero.mp this with h | h
  · exact hx h
  · exact hy (pow_eq_zero_iff (n := 3) (by norm_num) |>.mp h)

/-- Started from a point in the positive quadrant, the tangent construction also avoids the
second coordinate: the new unordered pair is genuinely new. -/
theorem cubic_tangent_ne_snd {x y : ℚ} (hx : 0 < x) (hy : 0 < y) (hxy : x ^ 3 ≠ y ^ 3) :
    x * (x ^ 3 + 2 * y ^ 3) / (x ^ 3 - y ^ 3) ≠ y := by
  have hd : x ^ 3 - y ^ 3 ≠ 0 := sub_ne_zero.mpr hxy
  intro hc
  rw [div_eq_iff hd] at hc
  -- `x⁴ - x³y + 2xy³ + y⁴ = 0` is impossible for positive `x, y`
  nlinarith [hc, hx, hy, mul_pos hx hy, sq_nonneg (x - y), sq_nonneg (x + y),
    mul_pos (mul_pos hx hx) (mul_pos hx hx), mul_pos (mul_pos hy hy) (mul_pos hy hy)]

/-- A worked instance of the chord–tangent step: from the point `(1, 2)` on `x³ + y³ = 9`
one obtains the further rational point `(-17/7, 20/7)`. -/
theorem cubic_tangent_example :
    ((-17 : ℚ) / 7) ^ 3 + ((20 : ℚ) / 7) ^ 3 = 9 ∧
      (1 : ℚ) * (1 ^ 3 + 2 * 2 ^ 3) / (1 ^ 3 - 2 ^ 3) = -17 / 7 ∧
      -(2 * (2 * 1 ^ 3 + 2 ^ 3)) / ((1 : ℚ) ^ 3 - 2 ^ 3) = 20 / 7 := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-! ## The positive-orthant version -/

/-- **Transfer theorem in the positive orthant.** A finite family of rational points with
*positive* coordinates on one cubic `x³ + y³ = q` yields a positive integer with at least
that many representations as a sum of two **positive** cubes. This is the form the
classical `Taxicab n` conjecture needs. -/
theorem positive_rational_transfer (S : Finset (ℚ × ℚ)) (q : ℚ)
    (hS : ∀ p ∈ S, 0 < p.1 ∧ p.1 ≤ p.2 ∧ p.1 ^ 3 + p.2 ^ 3 = q) :
    ∃ M : ℕ, 0 < M ∧ S.card ≤ (cubeReps M).card := by
  rcases Finset.eq_empty_or_nonempty S with rfl | ⟨p₀, hp₀⟩
  · exact ⟨1, by norm_num, by simp⟩
  set D : ℕ := ∏ p ∈ S, p.1.den * p.2.den with hD
  have hDpos : 0 < D := by
    refine Finset.prod_pos fun p _ => ?_
    exact Nat.mul_pos p.1.pos p.2.pos
  have hDQ : (0 : ℚ) < (D : ℚ) := by exact_mod_cast hDpos
  have hdvd : ∀ p ∈ S, p.1.den ∣ D ∧ p.2.den ∣ D := by
    intro p hp
    have hmem : p.1.den * p.2.den ∣ D := Finset.dvd_prod_of_mem _ hp
    exact ⟨dvd_trans (Dvd.intro _ rfl) hmem, dvd_trans (Dvd.intro_left _ rfl) hmem⟩
  set g : ℚ × ℚ → ℕ × ℕ :=
    fun p => ((((D : ℚ) * p.1).num).toNat, (((D : ℚ) * p.2).num).toNat) with hg
  have hcast : ∀ p ∈ S, (((g p).1 : ℕ) : ℚ) = (D : ℚ) * p.1 ∧
      (((g p).2 : ℕ) : ℚ) = (D : ℚ) * p.2 := by
    intro p hp
    obtain ⟨h1, h2, _⟩ := hS p hp
    have hx : ((((D : ℚ) * p.1).num : ℤ) : ℚ) = (D : ℚ) * p.1 := clear_den (hdvd p hp).1
    have hy : ((((D : ℚ) * p.2).num : ℤ) : ℚ) = (D : ℚ) * p.2 := clear_den (hdvd p hp).2
    have hxpos : 0 < (((D : ℚ) * p.1).num : ℤ) := by
      have : (0 : ℚ) < ((((D : ℚ) * p.1).num : ℤ) : ℚ) := by
        rw [hx]; exact mul_pos hDQ h1
      exact_mod_cast this
    have hypos : 0 < (((D : ℚ) * p.2).num : ℤ) := by
      have : (0 : ℚ) < ((((D : ℚ) * p.2).num : ℤ) : ℚ) := by
        rw [hy]; exact mul_pos hDQ (lt_of_lt_of_le h1 h2)
      exact_mod_cast this
    constructor
    · rw [hg]
      simp only
      rw [← hx]
      exact_mod_cast congrArg (fun k : ℤ => (k : ℚ)) (Int.toNat_of_nonneg hxpos.le)
    · rw [hg]
      simp only
      rw [← hy]
      exact_mod_cast congrArg (fun k : ℤ => (k : ℚ)) (Int.toNat_of_nonneg hypos.le)
  have hsum : ∀ p ∈ S, (((g p).1 ^ 3 + (g p).2 ^ 3 : ℕ) : ℚ) = (D : ℚ) ^ 3 * q := by
    intro p hp
    obtain ⟨h1, h2⟩ := hcast p hp
    have h3 := (hS p hp).2.2
    push_cast
    rw [h1, h2, ← h3]
    ring
  refine ⟨(g p₀).1 ^ 3 + (g p₀).2 ^ 3, ?_, ?_⟩
  · have hp1 : 0 < (g p₀).1 := by
      obtain ⟨h1, _⟩ := hcast p₀ hp₀
      have : (0 : ℚ) < (((g p₀).1 : ℕ) : ℚ) := by
        rw [h1]; exact mul_pos hDQ (hS p₀ hp₀).1
      exact_mod_cast this
    positivity
  refine Finset.card_le_card_of_injOn g (fun p hp => ?_) ?_
  · obtain ⟨h1, h2⟩ := hcast p hp
    obtain ⟨hx, hxy, _⟩ := hS p hp
    simp only [Finset.mem_coe]
    rw [mem_cubeReps]
    refine ⟨?_, ?_, ?_⟩
    · have : (0 : ℚ) < (((g p).1 : ℕ) : ℚ) := by rw [h1]; exact mul_pos hDQ hx
      exact_mod_cast this
    · have : (((g p).1 : ℕ) : ℚ) ≤ (((g p).2 : ℕ) : ℚ) := by
        rw [h1, h2]; exact mul_le_mul_of_nonneg_left hxy hDQ.le
      exact_mod_cast this
    · have hq1 : (((g p).1 ^ 3 + (g p).2 ^ 3 : ℕ) : ℚ)
          = (((g p₀).1 ^ 3 + (g p₀).2 ^ 3 : ℕ) : ℚ) := by
        rw [hsum p hp, hsum p₀ hp₀]
      exact_mod_cast hq1
  · intro p hp p' hp' heq
    obtain ⟨h1, h2⟩ := hcast p hp
    obtain ⟨h1', h2'⟩ := hcast p' hp'
    have e1 : (D : ℚ) * p.1 = (D : ℚ) * p'.1 := by rw [← h1, ← h1', heq]
    have e2 : (D : ℚ) * p.2 = (D : ℚ) * p'.2 := by rw [← h2, ← h2', heq]
    exact Prod.ext (mul_left_cancel₀ hDQ.ne' e1) (mul_left_cancel₀ hDQ.ne' e2)

/-- **Conjecture 1 in its classical form, reduced to its arithmetic input.** An infinite
family of distinct rational points with positive coordinates on a single cubic
`x³ + y³ = q` produces, for every `n`, an integer with at least `n` representations as a
sum of two positive cubes. -/
theorem unbounded_positive_of_infinite_rational_orbit (q : ℚ) (P : ℕ → ℚ × ℚ)
    (hP : ∀ k, 0 < (P k).1 ∧ (P k).1 ≤ (P k).2 ∧ (P k).1 ^ 3 + (P k).2 ^ 3 = q)
    (hinj : Function.Injective P) (n : ℕ) :
    ∃ M : ℕ, 0 < M ∧ n ≤ (cubeReps M).card := by
  obtain ⟨M, hM, hcard⟩ := positive_rational_transfer ((Finset.range n).image P) q
    (by
      intro p hp
      obtain ⟨k, _, rfl⟩ := Finset.mem_image.mp hp
      exact hP k)
  refine ⟨M, hM, le_trans ?_ hcard⟩
  rw [Finset.card_image_of_injective _ hinj, Finset.card_range]

end Taxicab