import Combinatorics.BerggrenCongruentMain

/-!
# `2` is not a congruent number: a second unconditional law of the tree

No node of the Berggren tree has area twice a square.  Combined with the main
equivalence this says that `2` — and hence its whole square class `2t²` — is not a
congruent number.

The argument splits on which leg parameter is even (exactly one of `m`, `n` is):

* if `m` is even then `m = 2a²`, `n = b²`, `m − n = c²`, `m + n = d²` and
  `c² + d² = 4a²` is impossible modulo `8` because `c`, `d` are odd;
* if `n` is even then `m = a²`, `n = 2b²` and the half-sum/half-difference
  `u = (d+c)/2`, `v = (d−c)/2` satisfy `u² + v² = a²`, `uv = b²` with `u`, `v` coprime,
  so `u = g²`, `v = h²` and `g⁴ + h⁴ = a²`, contradicting Mathlib's `not_fermat_42`.

## Main results

* `euclidArea_ne_two_mul_sq` — no node has area `2k²`.
* `two_not_congruentNumber` — `2` is not a congruent number.
* `two_mul_sq_not_congruentNumber` — neither is `2t²` for any nonzero rational `t`.
-/

namespace BerggrenCongruent

open BerggrenStars

/-- An integer whose square is odd is odd. -/
private theorem odd_of_odd_sq {z : ℤ} (h : Odd (z ^ 2)) : Odd z := by
  rcases Int.even_or_odd z with hze | hzo
  · exact absurd h (by simp [Int.even_pow, hze, Int.not_odd_iff_even])
  · exact hzo

/-- **No node of the Berggren tree has area twice a square.** -/
theorem euclidArea_ne_two_mul_sq {m n : ℤ} (h : IsParam m n) (k : ℤ) :
    euclidArea m n ≠ 2 * k ^ 2 := by
  intro hk
  have hm : 0 < m := h.mpos
  have hn : 0 < n := h.npos
  have hlt : n < m := h.lt
  have hmn : IsCoprime m n := Int.isCoprime_iff_gcd_eq_one.mpr h.cop
  have hmC : IsCoprime m (m - n) := by
    have := (hmn.neg_right).add_mul_left_right 1
    rwa [show -n + m * 1 = m - n by ring] at this
  have hmD : IsCoprime m (m + n) := by
    have := hmn.add_mul_left_right 1
    rwa [show n + m * 1 = m + n by ring] at this
  have hnC : IsCoprime n (m - n) := by
    have := hmn.symm.add_mul_left_right (-1)
    rwa [show m + n * (-1) = m - n by ring] at this
  have hnD : IsCoprime n (m + n) := by
    have := hmn.symm.add_mul_left_right 1
    rwa [show m + n * 1 = m + n by ring] at this
  have hCD : IsCoprime (m - n) (m + n) := by
    have h2 : IsCoprime (m - n) 2 := isCoprime_two_of_odd h.par
    have := (h2.mul_right hnC.symm).add_mul_left_right 1
    rwa [show 2 * n + (m - n) * 1 = m + n by ring] at this
  have hCpos : (0 : ℤ) < m - n := by linarith
  have hDpos : (0 : ℤ) < m + n := by linarith
  have hCodd : Odd (m - n) := h.par
  have hDodd : Odd (m + n) := by
    obtain ⟨t, ht⟩ := h.par
    exact ⟨t + n, by linarith⟩
  -- exactly one of `m`, `n` is even
  rcases Int.even_or_odd m with hme | hmo
  · -- `m` even: `m = 2a²`, and `c² + d² = 4a²` with `c`, `d` odd is impossible mod 8
    obtain ⟨m₁, hm₁⟩ := hme
    have hm₁' : m = 2 * m₁ := by omega
    have hm₁0 : 0 < m₁ := by omega
    have hcopm₁ : IsCoprime m₁ (n * ((m - n) * (m + n))) :=
      (hmn.mul_right (hmC.mul_right hmD)).of_isCoprime_of_dvd_left ⟨2, by omega⟩
    have hprod : m₁ * (n * ((m - n) * (m + n))) = k ^ 2 := by
      have : 2 * (m₁ * (n * ((m - n) * (m + n)))) = 2 * k ^ 2 := by
        rw [← hk]; simp only [euclidArea]; rw [hm₁']; ring
      linarith
    obtain ⟨a, ha0, ha⟩ := sq_of_isCoprime_pos hm₁0 hcopm₁ hprod
    obtain ⟨j, hj0, hj⟩ :=
      sq_of_isCoprime_pos (show (0:ℤ) < n * ((m - n) * (m + n)) by positivity)
        hcopm₁.symm (by rw [← hprod]; ring)
    obtain ⟨c, hc0, hc⟩ := sq_of_isCoprime_pos hCpos (hnC.symm.mul_right hCD)
      (by rw [← hj]; ring)
    obtain ⟨d, hd0, hd⟩ := sq_of_isCoprime_pos hDpos (hnD.symm.mul_right hCD.symm)
      (by rw [← hj]; ring)
    -- `c`, `d` are odd
    have hcodd : Odd c := odd_of_odd_sq (by rw [← hc]; exact hCodd)
    have hdodd : Odd d := odd_of_odd_sq (by rw [← hd]; exact hDodd)
    obtain ⟨c₁, hc₁⟩ := hcodd
    obtain ⟨d₁, hd₁⟩ := hdodd
    -- `c² + d² = 2m = 4a²`
    have hsum : c ^ 2 + d ^ 2 = 4 * a ^ 2 := by
      have : c ^ 2 + d ^ 2 = 2 * m := by rw [← hc, ← hd]; ring
      rw [this, hm₁', ha]; ring
    have hc₁even : ∃ t : ℤ, c₁ * (c₁ + 1) = 2 * t := by
      rcases Int.even_or_odd c₁ with ⟨t, ht⟩ | ⟨t, ht⟩
      · exact ⟨t * (c₁ + 1), by rw [ht]; ring⟩
      · exact ⟨c₁ * (t + 1), by rw [ht]; ring⟩
    have hd₁even : ∃ t : ℤ, d₁ * (d₁ + 1) = 2 * t := by
      rcases Int.even_or_odd d₁ with ⟨t, ht⟩ | ⟨t, ht⟩
      · exact ⟨t * (d₁ + 1), by rw [ht]; ring⟩
      · exact ⟨d₁ * (t + 1), by rw [ht]; ring⟩
    obtain ⟨tc, htc⟩ := hc₁even
    obtain ⟨td, htd⟩ := hd₁even
    have hexp : c ^ 2 + d ^ 2 = 8 * (tc + td) + 2 := by
      rw [hc₁, hd₁]
      have h1 : (2 * c₁ + 1) ^ 2 = 4 * (c₁ * (c₁ + 1)) + 1 := by ring
      have h2 : (2 * d₁ + 1) ^ 2 = 4 * (d₁ * (d₁ + 1)) + 1 := by ring
      rw [h1, h2, htc, htd]; ring
    have h4a : 4 * a ^ 2 = 8 * (tc + td) + 2 := by rw [← hsum, hexp]
    omega
  · -- `n` even: descent to `g⁴ + h⁴ = a²`
    have hne : Even n := by
      rcases Int.even_or_odd n with hne | hno
      · exact hne
      · exfalso
        obtain ⟨s, hs⟩ := hmo
        obtain ⟨t, ht⟩ := hno
        obtain ⟨r, hr⟩ := h.par
        omega
    obtain ⟨n₁, hn₁⟩ := hne
    have hn₁' : n = 2 * n₁ := by omega
    have hn₁0 : 0 < n₁ := by omega
    have hcopn₁ : IsCoprime n₁ (m * ((m - n) * (m + n))) :=
      (hmn.symm.mul_right (hnC.mul_right hnD)).of_isCoprime_of_dvd_left ⟨2, by omega⟩
    have hprod : n₁ * (m * ((m - n) * (m + n))) = k ^ 2 := by
      have : 2 * (n₁ * (m * ((m - n) * (m + n)))) = 2 * k ^ 2 := by
        rw [← hk]; simp only [euclidArea]; rw [hn₁']; ring
      linarith
    obtain ⟨b, hb0, hb⟩ := sq_of_isCoprime_pos hn₁0 hcopn₁ hprod
    obtain ⟨j, hj0, hj⟩ :=
      sq_of_isCoprime_pos (show (0:ℤ) < m * ((m - n) * (m + n)) by positivity)
        hcopn₁.symm (by rw [← hprod]; ring)
    obtain ⟨a, ha0, ha⟩ := sq_of_isCoprime_pos hm (hmC.mul_right hmD) hj
    obtain ⟨c, hc0, hc⟩ := sq_of_isCoprime_pos hCpos (hmC.symm.mul_right hCD)
      (by rw [← hj]; ring)
    obtain ⟨d, hd0, hd⟩ := sq_of_isCoprime_pos hDpos (hmD.symm.mul_right hCD.symm)
      (by rw [← hj]; ring)
    have hcodd : Odd c := odd_of_odd_sq (by rw [← hc]; exact hCodd)
    have hdodd : Odd d := odd_of_odd_sq (by rw [← hd]; exact hDodd)
    have hcltd : c < d := by nlinarith [hc, hd, hn, hc0, hd0]
    obtain ⟨c₁, hc₁⟩ := hcodd
    obtain ⟨d₁, hd₁⟩ := hdodd
    obtain ⟨u, hu⟩ : ∃ u : ℤ, u = c₁ + d₁ + 1 := ⟨_, rfl⟩
    obtain ⟨v, hv⟩ : ∃ v : ℤ, v = d₁ - c₁ := ⟨_, rfl⟩
    have huv_add : u + v = d := by omega
    have huv_sub : u - v = c := by omega
    have hu0 : 0 < u := by omega
    have hv0 : 0 < v := by omega
    have hsum : u ^ 2 + v ^ 2 = a ^ 2 := by
      have h1 : 2 * (u ^ 2 + v ^ 2) = (u + v) ^ 2 + (u - v) ^ 2 := by ring
      rw [huv_add, huv_sub, ← hd, ← hc] at h1
      have h2 : (m + n) + (m - n) = 2 * m := by ring
      rw [h2, ha] at h1
      linarith
    have hprod₂ : u * v = b ^ 2 := by
      have h1 : 4 * (u * v) = (u + v) ^ 2 - (u - v) ^ 2 := by ring
      rw [huv_add, huv_sub, ← hd, ← hc] at h1
      have h2 : (m + n) - (m - n) = 2 * n := by ring
      rw [h2, hn₁', hb] at h1
      linarith
    -- `u`, `v` are coprime because `c`, `d` are
    have hCD' : IsCoprime c d := by
      rw [hc, hd] at hCD
      exact (hCD.of_isCoprime_of_dvd_left (dvd_pow_self c two_ne_zero)).of_isCoprime_of_dvd_right
        (dvd_pow_self d two_ne_zero)
    have hcopuv : IsCoprime u v := by
      obtain ⟨s, t, hst⟩ := hCD'
      exact ⟨s + t, t - s, by rw [← huv_add, ← huv_sub] at hst; linear_combination hst⟩
    obtain ⟨g, hg0, hg⟩ := sq_of_isCoprime_pos hu0 hcopuv hprod₂
    obtain ⟨w, hw0, hw⟩ := sq_of_isCoprime_pos hv0 hcopuv.symm (by rw [← hprod₂]; ring)
    -- `g⁴ + h⁴ = a²` contradicts Fermat's theorem for exponent 4
    have hfermat : g ^ 4 + w ^ 4 = a ^ 2 := by
      have : (g ^ 2) ^ 2 + (w ^ 2) ^ 2 = a ^ 2 := by rw [← hg, ← hw]; exact hsum
      linarith [this, sq_nonneg g, sq_nonneg w]
    exact not_fermat_42 hg0.ne' hw0.ne' hfermat

/-- **`2` is not a congruent number.** -/
theorem two_not_congruentNumber : ¬ IsCongruentNumber (2 : ℚ) := by
  intro h
  have hs : Squarefree (2 : ℤ) := by
    have : Squarefree ((2 : ℕ) : ℤ) := Int.squarefree_natCast.mpr (by decide +kernel)
    exact_mod_cast this
  obtain ⟨m, n, k, hpar, hk, harea⟩ :=
    (congruent_iff_exists_param hs).mp (by exact_mod_cast h)
  exact euclidArea_ne_two_mul_sq hpar k harea

/-- The whole square class of `2` consists of non-congruent numbers. -/
theorem two_mul_sq_not_congruentNumber {t : ℚ} (ht : t ≠ 0) :
    ¬ IsCongruentNumber (2 * t ^ 2) := by
  intro h
  exact two_not_congruentNumber ((isCongruentNumber_mul_sq_iff 2 ht).mp h)

end BerggrenCongruent