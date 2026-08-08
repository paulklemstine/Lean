import Probability.ThreeCubes.LocalSolvability

/-!
# `p`-adic points on the cubic surface `x³ + y³ + z³ = n`

This file upgrades the congruence statement of `Probability.ThreeCubes.LocalSolvability` to a
genuine statement about `p`-adic integers:

`ThreeCubes.padicInt_solvable_iff` :
  the surface `x³ + y³ + z³ = n` has a `ℤ_p`-point for **every** prime `p`
  if and only if `n ≢ ±4 (mod 9)`.

The unramified primes are handled by Mathlib's `hensels_lemma` applied to `X³ - a` at a
point where the derivative `3x²` is a unit.  At `p = 3` the derivative has norm `1/3`, so
Hensel's strong hypothesis `‖F(a)‖ < ‖F'(a)‖²` requires an approximate root modulo `27`;
this is supplied by the ramified lifting lemma `cube_lift_three`.  The negative direction
reduces a hypothetical `ℤ₃`-point modulo `9` via `PadicInt.toZModPow`.
-/

namespace ThreeCubes

/-- A `p`-adic integer coming from an integer prime to `p` has norm one. -/
theorem norm_intCast_eq_one {p : ℕ} [Fact p.Prime] (k : ℤ) (h : ¬ (p : ℤ) ∣ k) :
    ‖((k : ℤ_[p]))‖ = 1 :=
  le_antisymm (PadicInt.norm_le_one _)
    (not_lt.mp fun hc => h ((PadicInt.norm_int_lt_one_iff_dvd k).mp hc))

/-- Hensel's lemma for `X³ - a`, packaged for integer approximate roots. -/
theorem padic_cube_root {p : ℕ} [Fact p.Prime] (a x₀ : ℤ)
    (h : ‖((x₀ ^ 3 - a : ℤ) : ℤ_[p])‖ < ‖((3 * x₀ ^ 2 : ℤ) : ℤ_[p])‖ ^ 2) :
    ∃ z : ℤ_[p], z ^ 3 = (a : ℤ_[p]) := by
  set F : Polynomial ℤ := Polynomial.X ^ 3 - Polynomial.C a with hF
  have hev : (Polynomial.aeval ((x₀ : ℤ_[p]))) F = ((x₀ ^ 3 - a : ℤ) : ℤ_[p]) := by simp [hF]
  have hdev : (Polynomial.aeval ((x₀ : ℤ_[p]))) (Polynomial.derivative F)
      = ((3 * x₀ ^ 2 : ℤ) : ℤ_[p]) := by
    rw [hF]
    simp
    · left; exact map_ofNat _ 3
  obtain ⟨z, hz, -⟩ := hensels_lemma (F := F) (a := ((x₀ : ℤ_[p]))) (by rw [hev, hdev]; exact h)
  refine ⟨z, ?_⟩
  have hzz : (Polynomial.aeval z) F = z ^ 3 - (a : ℤ_[p]) := by simp [hF]
  rw [hzz] at hz
  linear_combination hz

/-- At a prime `p ≠ 3`, any integer congruent to a cube of a unit modulo `p` is a cube in
`ℤ_p`. -/
theorem exists_padicInt_cube_ne_three {p : ℕ} [Fact p.Prime] (hp3 : p ≠ 3) (a x₀ : ℤ)
    (hx : ¬ (p : ℤ) ∣ x₀) (hd : (p : ℤ) ∣ x₀ ^ 3 - a) : ∃ z : ℤ_[p], z ^ 3 = (a : ℤ_[p]) := by
  have hp := Fact.out (p := p.Prime)
  have hderiv : ¬ (p : ℤ) ∣ 3 * x₀ ^ 2 := by
    intro hcon
    have hpp : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
    rcases hpp.dvd_mul.mp hcon with h | h
    · have hd3 : p ∣ 3 := by
        have : ((p : ℤ)) ∣ ((3 : ℕ) : ℤ) := by exact_mod_cast h
        exact_mod_cast this
      exact hp3 ((Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp hd3)
    · exact hx (hpp.dvd_of_dvd_pow h)
  refine padic_cube_root a x₀ ?_
  rw [norm_intCast_eq_one _ hderiv, one_pow]
  exact (PadicInt.norm_int_lt_one_iff_dvd _).mpr hd

/-- At the ramified prime `3`, every integer congruent to `1` modulo `9` is a cube in `ℤ₃`. -/
theorem exists_padicInt_cube_three (a : ℤ) (ha : (9 : ℤ) ∣ a - 1) :
    ∃ z : ℤ_[3], z ^ 3 = (a : ℤ_[3]) := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  obtain ⟨x₀, hx₀⟩ := cube_lift_three a ha 3
  have hx3 : ¬ (3 : ℤ) ∣ x₀ := by
    rintro ⟨c, hc⟩
    obtain ⟨d, hd⟩ := hx₀
    obtain ⟨e, he⟩ := ha
    obtain ⟨m, hA⟩ : ∃ m : ℤ, a = 27 * m := ⟨c ^ 3 - d, by rw [hc] at hd; linarith [hd]⟩
    omega
  refine padic_cube_root a x₀ ?_
  have hn1 : ‖((x₀ ^ 3 - a : ℤ) : ℤ_[3])‖ ≤ (3 : ℝ) ^ (-(3 : ℤ)) := by
    rw [show ((3 : ℝ)) = ((3 : ℕ) : ℝ) by norm_num]
    exact PadicInt.norm_int_le_pow_iff_dvd.mpr (by exact_mod_cast hx₀)
  have hn2 : ‖((3 * x₀ ^ 2 : ℤ) : ℤ_[3])‖ = (3 : ℝ)⁻¹ := by
    have hcast : ((3 * x₀ ^ 2 : ℤ) : ℤ_[3]) = ((3 : ℕ) : ℤ_[3]) * ((x₀ : ℤ_[3])) ^ 2 := by
      push_cast; ring
    rw [hcast, norm_mul, norm_pow, PadicInt.norm_p, norm_intCast_eq_one _ hx3]
    norm_num
  rw [hn2]
  refine lt_of_le_of_lt hn1 ?_
  norm_num

/-- Auxiliary `3`-adic step, mirroring `solvableMod_three_pow_aux`. -/
theorem padicInt_three_aux (n b c e : ℤ) (he : e = 1 ∨ e = -1)
    (h : (9 : ℤ) ∣ e * (n - b ^ 3 - c ^ 3) - 1) :
    ∃ x y z : ℤ_[3], x ^ 3 + y ^ 3 + z ^ 3 = (n : ℤ_[3]) := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  obtain ⟨w, hw⟩ := exists_padicInt_cube_three (e * (n - b ^ 3 - c ^ 3)) h
  refine ⟨(e : ℤ_[3]) * w, (b : ℤ_[3]), (c : ℤ_[3]), ?_⟩
  have he3 : ((e : ℤ_[3])) ^ 3 = (e : ℤ_[3]) := by rcases he with rfl | rfl <;> push_cast <;> ring
  have he2 : ((e : ℤ_[3])) ^ 2 = 1 := by rcases he with rfl | rfl <;> push_cast <;> ring
  have hexp : ((e : ℤ_[3]) * w) ^ 3 = (e : ℤ_[3]) ^ 3 * w ^ 3 := by ring
  rw [hexp, he3, hw]
  push_cast
  linear_combination ((n : ℤ_[3]) - (b : ℤ_[3]) ^ 3 - (c : ℤ_[3]) ^ 3) * he2

/-- **Existence of `ℤ_p`-points.**  If `n ≢ ±4 (mod 9)` then the surface `x³ + y³ + z³ = n`
has a `p`-adic integral point for every prime `p`. -/
theorem exists_padicInt_solution (p : ℕ) [Fact p.Prime] (n : ℤ) (h4 : n % 9 ≠ 4)
    (h5 : n % 9 ≠ 5) : ∃ x y z : ℤ_[p], x ^ 3 + y ^ 3 + z ^ 3 = (n : ℤ_[p]) := by
  by_cases hp3 : p = 3
  · subst hp3
    have h9 : n % 9 = 0 ∨ n % 9 = 1 ∨ n % 9 = 2 ∨ n % 9 = 3 ∨ n % 9 = 6 ∨ n % 9 = 7 ∨
        n % 9 = 8 := by omega
    rcases h9 with h | h | h | h | h | h | h
    · exact padicInt_three_aux n 1 0 (-1) (Or.inr rfl) (by omega)
    · exact padicInt_three_aux n 0 0 1 (Or.inl rfl) (by omega)
    · exact padicInt_three_aux n 1 0 1 (Or.inl rfl) (by omega)
    · exact padicInt_three_aux n 1 1 1 (Or.inl rfl) (by omega)
    · exact padicInt_three_aux n (-1) (-1) (-1) (Or.inr rfl) (by omega)
    · exact padicInt_three_aux n (-1) 0 (-1) (Or.inr rfl) (by omega)
    · exact padicInt_three_aux n 0 0 (-1) (Or.inr rfl) (by omega)
  · obtain ⟨x₀, y, z, hdvd, hx₀⟩ := three_cubes_mod_prime_unit p (Fact.out) n
    obtain ⟨w, hw⟩ := exists_padicInt_cube_ne_three hp3 (n - y ^ 3 - z ^ 3) x₀ hx₀
      (by obtain ⟨c, hc⟩ := hdvd; exact ⟨c, by linarith⟩)
    refine ⟨w, (y : ℤ_[p]), (z : ℤ_[p]), ?_⟩
    rw [hw]
    push_cast
    ring

/-- **The negative direction, `3`-adically.**  If `n ≡ ±4 (mod 9)` there is no `ℤ₃`-point. -/
theorem not_exists_padicInt_three_solution (n : ℤ) (h : n % 9 = 4 ∨ n % 9 = 5) :
    ¬ ∃ x y z : ℤ_[3], x ^ 3 + y ^ 3 + z ^ 3 = (n : ℤ_[3]) := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  rintro ⟨x, y, z, hxyz⟩
  have himg := congrArg (PadicInt.toZModPow (p := 3) 2) hxyz
  simp only [map_add, map_pow, map_intCast] at himg
  have hred : ((n : ZMod (3 ^ 2))) = ((n : ZMod 9)) := by norm_num
  rw [hred] at himg
  set X : ZMod 9 := (PadicInt.toZModPow (p := 3) 2) x
  set Y : ZMod 9 := (PadicInt.toZModPow (p := 3) 2) y
  set Z : ZMod 9 := (PadicInt.toZModPow (p := 3) 2) z
  rcases h with h | h
  · have := intCast_eq_of_emod h
    rw [this] at himg
    exact (sum_three_cubes_ne_four_five X Y Z).1 (by rw [himg]; norm_num)
  · have := intCast_eq_of_emod h
    rw [this] at himg
    exact (sum_three_cubes_ne_four_five X Y Z).2 (by rw [himg]; norm_num)

/-- **Main `p`-adic theorem.**  The cubic surface `x³ + y³ + z³ = n` has `ℤ_p`-points for all
primes `p` exactly when `n ≢ ±4 (mod 9)`. -/
theorem padicInt_solvable_iff (n : ℤ) :
    (∀ (p : ℕ) [Fact p.Prime], ∃ x y z : ℤ_[p], x ^ 3 + y ^ 3 + z ^ 3 = (n : ℤ_[p])) ↔
      (n % 9 ≠ 4 ∧ n % 9 ≠ 5) := by
  haveI h3 : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  constructor
  · intro h
    refine ⟨fun hc => ?_, fun hc => ?_⟩
    · exact not_exists_padicInt_three_solution n (Or.inl hc) (h 3)
    · exact not_exists_padicInt_three_solution n (Or.inr hc) (h 3)
  · rintro ⟨h4, h5⟩ p _
    exact exists_padicInt_solution p n h4 h5

end ThreeCubes