import Combinatorics.BerggrenCongruentDefs

/-!
# Descent from a rational right triangle to a primitive integer triple

This file contains the arithmetic heart of the "triangle side" of the congruent number
problem: if a squarefree positive integer `s` is a congruent number, then `s` already
occurs as the squarefree part of the area of a *primitive integer* Pythagorean triple —
hence, by Barning–Hall, of a node of the Berggren tree.

The ingredients are:

* `eq_sq_mul_of_squarefree` — squarefree cancellation: if `A g² = s d²` with `s`
  squarefree and `g ≠ 0`, then `A = s k²` for some integer `k`.
* `exists_intTriple_of_congruent` — clearing denominators.
* `exists_primitive_of_congruent` — dividing by the gcd and cancelling.
-/

namespace BerggrenCongruent

open BerggrenStars

/-- **Squarefree cancellation.**  If `A g² = s d²` with `s` squarefree and `g ≠ 0`, then
`A` is `s` times a square. -/
theorem eq_sq_mul_of_squarefree {s A g d : ℤ} (hs : Squarefree s) (hg : g ≠ 0)
    (h : A * g ^ 2 = s * d ^ 2) : ∃ k : ℤ, A = s * k ^ 2 := by
  obtain ⟨e, he⟩ : ∃ e : ℤ, e = (Int.gcd g d : ℤ) := ⟨_, rfl⟩
  have hgcdpos : 0 < Int.gcd g d := Int.gcd_pos_of_ne_zero_left d hg
  have he0 : e ≠ 0 := by
    rw [he]
    exact_mod_cast hgcdpos.ne'
  set g₁ : ℤ := g / e with hg₁
  set d₁ : ℤ := d / e with hd₁
  have hgd : e ∣ g := he ▸ Int.gcd_dvd_left g d
  have hdd : e ∣ d := he ▸ Int.gcd_dvd_right g d
  have hge : g = e * g₁ := (Int.mul_ediv_cancel' hgd).symm
  have hde : d = e * d₁ := (Int.mul_ediv_cancel' hdd).symm
  have hcop : Int.gcd g₁ d₁ = 1 := by
    rw [hg₁, hd₁, he]
    exact Int.gcd_div_gcd_div_gcd hgcdpos
  -- cancel the common factor `e²`
  have hcancel : A * g₁ ^ 2 = s * d₁ ^ 2 := by
    have h' : e ^ 2 * (A * g₁ ^ 2) = e ^ 2 * (s * d₁ ^ 2) := by
      calc e ^ 2 * (A * g₁ ^ 2) = A * (e * g₁) ^ 2 := by ring
        _ = A * g ^ 2 := by rw [← hge]
        _ = s * d ^ 2 := h
        _ = s * (e * d₁) ^ 2 := by rw [← hde]
        _ = e ^ 2 * (s * d₁ ^ 2) := by ring
    exact mul_left_cancel₀ (pow_ne_zero 2 he0) h'
  -- `g₁²` divides `s d₁²` and is coprime to `d₁²`, hence divides `s`
  have hcop' : IsCoprime g₁ d₁ := Int.isCoprime_iff_gcd_eq_one.mpr hcop
  have hdvd : g₁ ^ 2 ∣ s * d₁ ^ 2 := ⟨A, by linarith [hcancel]⟩
  have hdvds : g₁ ^ 2 ∣ s := (IsCoprime.pow hcop').dvd_of_dvd_mul_right hdvd
  have hunit : IsUnit g₁ := hs g₁ (by rwa [← sq])
  have hone : g₁ ^ 2 = 1 := by
    rcases Int.isUnit_iff.mp hunit with h' | h' <;> rw [h'] <;> ring
  exact ⟨d₁, by rw [← hcancel, hone, mul_one]⟩

/-- Multiplying a rational by (a multiple of) its denominator gives an integer. -/
private theorem num_mul_cast (q : ℚ) (t : ℕ) :
    ((q.num * (t : ℤ) : ℤ) : ℚ) = q * ((q.den : ℚ) * (t : ℚ)) := by
  have h : (q.num : ℚ) = q * (q.den : ℚ) := by
    rw [mul_comm, Rat.den_mul_eq_num]
  push_cast
  rw [h]
  ring

/-- Clearing denominators: a rational right triangle of area `N` yields an integer right
triangle whose area is `N D²` for some positive integer `D`. -/
theorem exists_intTriple_of_congruent {N : ℚ} (h : IsCongruentNumber N) :
    ∃ x y z D : ℤ, 0 < x ∧ 0 < y ∧ 0 < z ∧ x ^ 2 + y ^ 2 = z ^ 2 ∧ 0 < D ∧
      ((x : ℚ) * y = 2 * N * (D : ℚ) ^ 2) := by
  obtain ⟨a, b, c, ha, hb, hc, hpy, harea⟩ := h
  obtain ⟨D, hD⟩ : ∃ D : ℤ, D = (a.den : ℤ) * (b.den : ℤ) * (c.den : ℤ) := ⟨_, rfl⟩
  have hda := a.pos
  have hdb := b.pos
  have hdc := c.pos
  have hD0 : 0 < D := by
    rw [hD]
    have h1 : (0 : ℤ) < (a.den : ℤ) := by exact_mod_cast hda
    have h2 : (0 : ℤ) < (b.den : ℤ) := by exact_mod_cast hdb
    have h3 : (0 : ℤ) < (c.den : ℤ) := by exact_mod_cast hdc
    positivity
  have hDQ : (D : ℚ) = (a.den : ℚ) * (b.den : ℚ) * (c.den : ℚ) := by
    rw [hD]; push_cast; ring
  obtain ⟨X, hX⟩ : ∃ X : ℤ, X = a.num * ((b.den : ℤ) * (c.den : ℤ)) := ⟨_, rfl⟩
  obtain ⟨Y, hY⟩ : ∃ Y : ℤ, Y = b.num * ((a.den : ℤ) * (c.den : ℤ)) := ⟨_, rfl⟩
  obtain ⟨Z, hZ⟩ : ∃ Z : ℤ, Z = c.num * ((a.den : ℤ) * (b.den : ℤ)) := ⟨_, rfl⟩
  have hXQ : (X : ℚ) = a * (D : ℚ) := by
    rw [hX, hDQ]
    have := num_mul_cast a (b.den * c.den)
    push_cast at this ⊢
    rw [this]
    ring
  have hYQ : (Y : ℚ) = b * (D : ℚ) := by
    rw [hY, hDQ]
    have := num_mul_cast b (a.den * c.den)
    push_cast at this ⊢
    rw [this]
    ring
  have hZQ : (Z : ℚ) = c * (D : ℚ) := by
    rw [hZ, hDQ]
    have := num_mul_cast c (a.den * b.den)
    push_cast at this ⊢
    rw [this]
    ring
  have hDQ0 : (0 : ℚ) < (D : ℚ) := by exact_mod_cast hD0
  refine ⟨X, Y, Z, D, ?_, ?_, ?_, ?_, hD0, ?_⟩
  · have : (0 : ℚ) < (X : ℚ) := by rw [hXQ]; positivity
    exact_mod_cast this
  · have : (0 : ℚ) < (Y : ℚ) := by rw [hYQ]; positivity
    exact_mod_cast this
  · have : (0 : ℚ) < (Z : ℚ) := by rw [hZQ]; positivity
    exact_mod_cast this
  · have key : (X : ℚ) ^ 2 + (Y : ℚ) ^ 2 = (Z : ℚ) ^ 2 := by
      rw [hXQ, hYQ, hZQ, mul_pow, mul_pow, mul_pow, ← add_mul, hpy]
    exact_mod_cast key
  · rw [hXQ, hYQ]
    calc a * (D : ℚ) * (b * (D : ℚ)) = (a * b) * (D : ℚ) ^ 2 := by ring
      _ = 2 * N * (D : ℚ) ^ 2 := by rw [harea]

/-- **Descent to a primitive triple.**  If a squarefree positive integer `s` is a
congruent number, then there is a *primitive* positive Pythagorean triple whose area is
`s` times a perfect square. -/
theorem exists_primitive_of_congruent {s : ℤ} (hs : Squarefree s)
    (h : IsCongruentNumber (s : ℚ)) :
    ∃ x y z k : ℤ, 0 < x ∧ 0 < y ∧ 0 < z ∧ x ^ 2 + y ^ 2 = z ^ 2 ∧ Int.gcd x y = 1 ∧
      0 < k ∧ x * y = 2 * s * k ^ 2 := by
  obtain ⟨x, y, z, D, hx, hy, hz, hpy, hD, harea⟩ := exists_intTriple_of_congruent h
  have hareaZ : x * y = 2 * s * D ^ 2 := by exact_mod_cast harea
  -- divide by the gcd of the legs
  obtain ⟨g, hg⟩ : ∃ g : ℤ, g = (Int.gcd x y : ℤ) := ⟨_, rfl⟩
  have hgpos : 0 < g := by
    have : 0 < Int.gcd x y := Int.gcd_pos_of_ne_zero_left y hx.ne'
    rw [hg]; exact_mod_cast this
  have hgx : g ∣ x := hg ▸ Int.gcd_dvd_left x y
  have hgy : g ∣ y := hg ▸ Int.gcd_dvd_right x y
  have hgz : g ∣ z := by
    have h2 : g ^ 2 ∣ z ^ 2 := by
      rw [← hpy]
      exact dvd_add (pow_dvd_pow_of_dvd hgx 2) (pow_dvd_pow_of_dvd hgy 2)
    exact (Int.pow_dvd_pow_iff two_ne_zero).mp h2
  obtain ⟨x', hx'⟩ := hgx
  obtain ⟨y', hy'⟩ := hgy
  obtain ⟨z', hz'⟩ := hgz
  have hx'0 : 0 < x' := by nlinarith [hx, hgpos, hx']
  have hy'0 : 0 < y' := by nlinarith [hy, hgpos, hy']
  have hz'0 : 0 < z' := by nlinarith [hz, hgpos, hz']
  have hpy' : x' ^ 2 + y' ^ 2 = z' ^ 2 := by
    have hg2 : g ^ 2 * (x' ^ 2 + y' ^ 2) = g ^ 2 * z' ^ 2 := by
      rw [hx', hy', hz'] at hpy
      nlinarith [hpy]
    exact mul_left_cancel₀ (pow_ne_zero 2 hgpos.ne') hg2
  have hcop : Int.gcd x' y' = 1 := by
    have hgg : Int.gcd x y = g.natAbs * Int.gcd x' y' := by
      rw [hx', hy']
      exact Int.gcd_mul_left g x' y'
    have habs : g.natAbs = Int.gcd x y := by
      rw [hg]; simp
    rw [habs] at hgg
    have hpos : 0 < Int.gcd x y := Int.gcd_pos_of_ne_zero_left y hx.ne'
    nlinarith [hgg, hpos]
  -- one leg of a primitive triple is even, so the area is an integer
  have hppt : IsPPT x' y' z' := ⟨hx'0, hy'0, hz'0, hpy', hcop⟩
  have heven : (2 : ℤ) ∣ x' * y' := by
    rcases hppt.odd_xor with ⟨-, h2⟩ | ⟨h1, -⟩
    · rw [Int.not_odd_iff_even] at h2
      exact Dvd.dvd.mul_left h2.two_dvd _
    · rw [Int.not_odd_iff_even] at h1
      exact Dvd.dvd.mul_right h1.two_dvd _
  obtain ⟨A, hA⟩ := heven
  have hA0 : 0 < A := by nlinarith [mul_pos hx'0 hy'0, hA]
  -- cancel `2` and `g²`
  have hAg : A * g ^ 2 = s * D ^ 2 := by
    have h2 : 2 * (A * g ^ 2) = 2 * (s * D ^ 2) := by
      calc 2 * (A * g ^ 2) = g ^ 2 * (2 * A) := by ring
        _ = g ^ 2 * (x' * y') := by rw [hA]
        _ = (g * x') * (g * y') := by ring
        _ = x * y := by rw [← hx', ← hy']
        _ = 2 * s * D ^ 2 := hareaZ
        _ = 2 * (s * D ^ 2) := by ring
    linarith
  obtain ⟨k, hk⟩ := eq_sq_mul_of_squarefree hs hgpos.ne' hAg
  have hk0 : 0 < |k| := by
    rcases eq_or_ne k 0 with rfl | hne
    · simp at hk; omega
    · exact abs_pos.mpr hne
  refine ⟨x', y', z', |k|, hx'0, hy'0, hz'0, hpy', hcop, hk0, ?_⟩
  rw [hA, hk, sq_abs]
  ring

end BerggrenCongruent