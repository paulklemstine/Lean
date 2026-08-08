import Probability.ThreeCubes.Basic

/-!
# Geometry of the cubic surface `x³ + y³ + z³ = n`

Two structural results about the geometry of the affine cubic surface `S_n : x³+y³+z³ = n`
and its projective closure `X³ + Y³ + Z³ = n W³`.

* `ThreeCubes.projective_has_nontrivial_point` — the projective surface **always** has an
  integral point, for every `n`, namely `[1 : -1 : 0 : 0]`.  Consequently the mod `9`
  obstruction is a purely *integral/affine* phenomenon: it says nothing about the projective
  cubic surface, which satisfies the Hasse principle trivially.

* `ThreeCubes.containsLine_iff_isCube` — the affine surface `S_n` contains a straight line of
  integral points **iff** `n` is a perfect cube.  The interesting direction rests on Fermat's
  Last Theorem for exponent three: the direction vector of a line must satisfy
  `u³ + v³ + w³ = 0`, so one of its coordinates vanishes.  This gives a clean geometric
  characterisation of the cubes among all `n`, and explains why lines cannot be used to
  produce representations for non-cube `n`.
-/

namespace ThreeCubes

/-! ### The projective surface always has a point -/

/-- The projective cubic surface `X³ + Y³ + Z³ = n W³` has the integral point
`[1 : -1 : 0 : 0]` for **every** `n`.  So the failure of representability for `n ≡ ±4 (mod 9)`
is invisible projectively. -/
theorem projective_has_nontrivial_point (n : ℤ) :
    ∃ x y z w : ℤ, (x, y, z, w) ≠ ((0 : ℤ), (0 : ℤ), (0 : ℤ), (0 : ℤ)) ∧
      x ^ 3 + y ^ 3 + z ^ 3 = n * w ^ 3 :=
  ⟨1, -1, 0, 0, by simp, by ring⟩

/-- Every projective point of `X³+Y³+Z³ = nW³` with `W ≠ 0` gives a rational point of the
affine surface, and conversely.  This records the precise sense in which the arithmetic of
the affine surface is the arithmetic of the projective surface away from the plane at
infinity. -/
theorem affine_iff_projective_of_ne_zero (n : ℤ) (x y z w : ℤ) (hw : w ≠ 0) :
    x ^ 3 + y ^ 3 + z ^ 3 = n * w ^ 3 ↔
      ((x : ℚ) / w) ^ 3 + ((y : ℚ) / w) ^ 3 + ((z : ℚ) / w) ^ 3 = (n : ℚ) := by
  have hwQ : (w : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hw
  constructor
  · intro h
    field_simp
    rw [mul_comm]
    exact_mod_cast h
  · intro h
    field_simp at h
    rw [mul_comm] at h
    exact_mod_cast h

/-! ### Lines on the affine surface -/

/-- The affine surface `x³ + y³ + z³ = n` contains an integral straight line: there is a base
point and a nonzero direction vector such that the whole line lies on the surface. -/
def ContainsLine (n : ℤ) : Prop :=
  ∃ a b c u v w : ℤ, ¬ (u = 0 ∧ v = 0 ∧ w = 0) ∧
    ∀ t : ℤ, (a + t * u) ^ 3 + (b + t * v) ^ 3 + (c + t * w) ^ 3 = n

/-- Fermat's Last Theorem for exponent `3`, over `ℤ`. -/
theorem fermatLastTheorem_three_int : FermatLastTheoremWith ℤ 3 :=
  ((fermatLastTheoremWith_nat_int_rat_tfae 3).out 0 1).mp fermatLastTheoremThree

/-- The Fermat cubic `u³ + v³ + w³ = 0` has only the trivial integral points. -/
theorem cube_sum_three_eq_zero (u v w : ℤ) (h : u ^ 3 + v ^ 3 + w ^ 3 = 0) :
    u = 0 ∨ v = 0 ∨ w = 0 := by
  by_contra hc
  push_neg at hc
  obtain ⟨hu, hv, hw⟩ := hc
  have hcube : u ^ 3 + v ^ 3 = (-w) ^ 3 := by ring_nf; linarith [h]
  exact fermatLastTheorem_three_int u v (-w) hu hv (neg_ne_zero.mpr hw) hcube

theorem cube_injective {x y : ℤ} (h : x ^ 3 = y ^ 3) : x = y :=
  (Odd.strictMono_pow (R := ℤ) (by decide)).injective h

/-- The coefficients of the cubic polynomial `t ↦ (a+tu)³+(b+tv)³+(c+tw)³ - n` all vanish
when the line lies on the surface. -/
theorem line_coeffs {n a b c u v w : ℤ}
    (h : ∀ t : ℤ, (a + t * u) ^ 3 + (b + t * v) ^ 3 + (c + t * w) ^ 3 = n) :
    u ^ 3 + v ^ 3 + w ^ 3 = 0 ∧ a * u ^ 2 + b * v ^ 2 + c * w ^ 2 = 0 ∧
      a ^ 2 * u + b ^ 2 * v + c ^ 2 * w = 0 ∧ a ^ 3 + b ^ 3 + c ^ 3 = n := by
  have h0 := h 0
  have h1 := h 1
  have hm1 := h (-1)
  have h2 := h 2
  refine ⟨by nlinarith [h0, h1, hm1, h2], by nlinarith [h0, h1, hm1, h2],
    by nlinarith [h0, h1, hm1, h2], by nlinarith [h0]⟩

/-- **The affine cubic surface contains a line exactly when `n` is a cube.**
The forward direction uses Fermat's Last Theorem for exponent three. -/
theorem containsLine_iff_isCube (n : ℤ) : ContainsLine n ↔ ∃ k : ℤ, n = k ^ 3 := by
  constructor
  · rintro ⟨a, b, c, u, v, w, hne, hline⟩
    obtain ⟨hA, hB, -, hD⟩ := line_coeffs hline
    rcases cube_sum_three_eq_zero u v w hA with hu | hv | hw
    · -- `u = 0`, so `w = -v` and `c = -b`
      subst hu
      have hvw : w = -v := by
        have : w ^ 3 = (-v) ^ 3 := by rw [show (-v) ^ 3 = -v ^ 3 by ring]; linarith [hA]
        exact cube_injective this
      have hvne : v ≠ 0 := by
        rintro rfl
        exact hne ⟨rfl, rfl, by simpa using hvw⟩
      have hbc : c = -b := by
        have hB' : v ^ 2 * (b + c) = 0 := by rw [hvw] at hB; nlinarith [hB]
        have : b + c = 0 := by
          rcases mul_eq_zero.mp hB' with h | h
          · exact absurd (pow_eq_zero_iff (n := 2) (by omega) |>.mp h) hvne
          · exact h
        linarith
      exact ⟨a, by rw [hbc] at hD; nlinarith [hD]⟩
    · -- `v = 0`, so `w = -u` and `c = -a`
      subst hv
      have huw : w = -u := by
        have : w ^ 3 = (-u) ^ 3 := by rw [show (-u) ^ 3 = -u ^ 3 by ring]; linarith [hA]
        exact cube_injective this
      have hune : u ≠ 0 := by
        rintro rfl
        exact hne ⟨rfl, rfl, by simpa using huw⟩
      have hac : c = -a := by
        have hB' : u ^ 2 * (a + c) = 0 := by rw [huw] at hB; nlinarith [hB]
        have : a + c = 0 := by
          rcases mul_eq_zero.mp hB' with h | h
          · exact absurd (pow_eq_zero_iff (n := 2) (by omega) |>.mp h) hune
          · exact h
        linarith
      exact ⟨b, by rw [hac] at hD; nlinarith [hD]⟩
    · -- `w = 0`, so `v = -u` and `b = -a`
      subst hw
      have huv : v = -u := by
        have : v ^ 3 = (-u) ^ 3 := by rw [show (-u) ^ 3 = -u ^ 3 by ring]; linarith [hA]
        exact cube_injective this
      have hune : u ≠ 0 := by
        rintro rfl
        exact hne ⟨rfl, by simpa using huv, rfl⟩
      have hab : b = -a := by
        have hB' : u ^ 2 * (a + b) = 0 := by rw [huv] at hB; nlinarith [hB]
        have : a + b = 0 := by
          rcases mul_eq_zero.mp hB' with h | h
          · exact absurd (pow_eq_zero_iff (n := 2) (by omega) |>.mp h) hune
          · exact h
        linarith
      exact ⟨c, by rw [hab] at hD; nlinarith [hD]⟩
  · rintro ⟨k, rfl⟩
    exact ⟨0, 0, k, 1, -1, 0, by simp, fun t => by ring⟩

/-- Consequently, for `n ≡ ±4 (mod 9)` the surface `S_n` has neither integral points nor
integral lines — but its projective closure still has integral points. -/
theorem no_line_of_mod_nine {n : ℤ} (h : n % 9 = 4 ∨ n % 9 = 5) : ¬ ContainsLine n := by
  intro hc
  obtain ⟨k, rfl⟩ := (containsLine_iff_isCube n).mp hc
  exact not_isSumOfThreeCubes_of_mod_nine h (isSumOfThreeCubes_cube k)

end ThreeCubes