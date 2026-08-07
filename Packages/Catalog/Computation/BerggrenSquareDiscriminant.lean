import Computation.BerggrenRationalLines

/-!
# Cycle 7: the square-discriminant dichotomy, and why every node lies on an infinite line

Cycle 6 (`BerggrenRationalLines`) showed that the rational line of radial value `ϱ = a/b`,
i.e. the conic

  `RatConic a b : b m² - a m n - b n² = b`,

carries infinitely many nodes as soon as its discriminant `a² + 4b²` is **not** a perfect square,
and gave one example (`ϱ = 3/2`, discriminant `25`) of a *square*-discriminant line that is
completely empty.  Sub-conjecture C of `FUTURE_DIRECTIONS.md` asked what happens in the square
case in general; the numerical census suggested "finite", and it is in fact "empty".

## Main results

* `ratConic_pos_empty_of_isSquare_disc` — **the square-discriminant case is always empty.**  If
  `a ≥ 0`, `b > 0` and `a² + 4b²` is a perfect square, the conic `b m² - a m n - b n² = b` has no
  solution at all with `m, n > 0`.  The proof is a descent to the primitive case followed by the
  Pythagorean parametrization `a = f² - e²`, `b = e f`, `√(a²+4b²) = e² + f²` with `gcd(e,f) = 1`,
  under which the conic factors as `(e m - f n)(f m + e n) = e f`; the second factor then divides
  `e f`, and since every divisor of `e f` splits as `A · B` with `A ∣ e` and `B ∣ f`, and `B` must
  divide `n`, one gets `f m + e n = A B ≤ e n`, which is absurd.
* `ratConic_pos_nonempty_iff`, `ratConic_pos_infinite_iff`, `ratConic_pos_empty_or_infinite` —
  **the dichotomy.**  A rational line is nonempty iff it is infinite iff its discriminant is not a
  perfect square.  There are no finite nonempty lines: the picture contains no "short" alignments
  through the centre.
* `radialDiscriminant_not_isSquare` — the Diophantine corollary: for integers `0 < n < m` the
  number `(m² - n² - 1)² + (2 m n)²` is **never** a perfect square, i.e. `(m² - n² - 1, 2 m n)` is
  never the pair of legs of a Pythagorean triple.  (Every Euclid seed produces such a pair, so this
  is exactly the statement that no node sits on a square-discriminant line.)
* `node_line_infinite`, `node_line_collinear` — the geometric payoff, and the explanation of the
  picture: **every** node `(m,n)` of the Berggren tree lies on a line through the centre that
  carries infinitely many further integral nodes, and all of them are exactly hyperbolically
  collinear with the centre and with `(m,n)`.  The visible straight lines are not an artefact:
  through each node there really is one.

## Lab notes

Exhaustive search for a node on a square-discriminant line.

* Direct sweep over all `0 < n < m ≤ 4000`: for each pair the reduced radial value `a/b` was
  formed and `a² + 4b²` tested for squareness — **0 hits** out of `7 998 000` pairs.
* Dual sweep over the lines themselves: for every `b ≤ 199` and every `a ≤ 1999` with `a² + 4b²`
  square, all factorizations `P · Q = 4b²` (both signs) were enumerated and solved back for
  `(m, n)` — **0 solutions** with `m, n > 0`.  This is exhaustive for those lines, since every
  point yields such a factorization.

Sample square-discriminant lines and their factorized form, all empty:

| ϱ = a/b | disc a²+4b² | (e,f) | factorization of the conic       |
|---------|-------------|-------|-----------------------------------|
| 0/1     | 4  = 2²     | (1,1) | `(m - n)(m + n) = 1`              |
| 3/2     | 25 = 5²     | (1,2) | `(m - 2n)(2m + n) = 2`            |
| 8/3     | 100 = 10²   | (1,3) | `(m - 3n)(3m + n) = 3`            |
| 5/6     | 169 = 13²   | (2,3) | `(2m - 3n)(3m + 2n) = 6`          |
| 16/15   | 1156 = 34²  | (3,5) | `(3m - 5n)(5m + 3n) = 15`         |

In each case the second factor `f m + e n` would have to divide `e f`, which forces
`f m + e n ≤ e n` — the contradiction formalized below.
-/

noncomputable section

namespace BerggrenHyperbolic

/-! ## 1. The combinatorial heart: a divisor inequality -/

/-- **The divisor obstruction (natural-number form).**  For positive coprime `e, f` and positive
`m, n` the number `f m + e n` never divides `e f`.

Indeed a divisor of `e f` factors as `A · B` with `A ∣ e` and `B ∣ f`; from `B ∣ f m + e n` and
`B ∣ f m` one gets `B ∣ e n`, hence `B ∣ n` by coprimality, so `A B ≤ e n < f m + e n`. -/
theorem not_dvd_mul_of_pos {e f m n : ℕ} (he : 0 < e) (hf : 0 < f) (hm : 0 < m) (hn : 0 < n)
    (hco : Nat.Coprime e f) : ¬ (f * m + e * n ∣ e * f) := by
  intro hdvd
  obtain ⟨A, B, hA, hB, hQ⟩ := exists_dvd_and_dvd_of_dvd_mul hdvd
  have h1 : B ∣ f * m := Dvd.dvd.mul_right hB m
  have h2 : B ∣ f * m + e * n := hQ ▸ Dvd.intro_left A rfl
  have h3 : B ∣ e * n := by simpa using Nat.dvd_sub h2 h1
  have hcoB : Nat.Coprime B e := (Nat.Coprime.coprime_dvd_right hB hco).symm
  have hBn : B ∣ n := hcoB.dvd_of_dvd_mul_left h3
  have hle : A * B ≤ e * n := Nat.mul_le_mul (Nat.le_of_dvd he hA) (Nat.le_of_dvd hn hBn)
  have hfm : 0 < f * m := Nat.mul_pos hf hm
  omega

/-- The integral form of the divisor obstruction: the factored conic
`(e m - f n)(f m + e n) = e f` has no positive solution when `gcd(e,f) = 1`. -/
theorem factored_conic_no_pos_solution {e f m n : ℤ} (he : 0 < e) (hf : 0 < f) (hm : 0 < m)
    (hn : 0 < n) (hco : Int.gcd e f = 1) : (e * m - f * n) * (f * m + e * n) ≠ e * f := by
  intro h
  have hdvd : (f * m + e * n) ∣ e * f := Dvd.intro_left _ h
  have hnat : (f * m + e * n).natAbs ∣ (e * f).natAbs := Int.natAbs_dvd_natAbs.2 hdvd
  have e1 : (f * m + e * n).natAbs = f.natAbs * m.natAbs + e.natAbs * n.natAbs := by
    have h2 : (f * m + e * n).natAbs = (f * m).natAbs + (e * n).natAbs := by
      rw [Int.natAbs_add_of_nonneg (by positivity) (by positivity)]
    simpa [Int.natAbs_mul] using h2
  rw [e1, Int.natAbs_mul] at hnat
  exact not_dvd_mul_of_pos (Int.natAbs_pos.2 he.ne') (Int.natAbs_pos.2 hf.ne')
    (Int.natAbs_pos.2 hm.ne') (Int.natAbs_pos.2 hn.ne') hco hnat

/-! ## 2. Emptiness of a square-discriminant line -/

/-- **The primitive case.**  If `gcd(a,b) = 1`, `a ≥ 0`, `b > 0` and `a² + 4b² = d²`, then the
line `a/b` carries no node with positive coordinates.

The proof extracts the Pythagorean parametrization: `E = (d-a)/2` and `F = (d+a)/2` are coprime
positive integers with `E F = b²`, hence `E = e²`, `F = f²`, `b = e f`, `a = f² - e²` with
`gcd(e,f) = 1`, and the conic becomes `(e m - f n)(f m + e n) = e f`. -/
theorem ratConic_primitive_empty {a b m n : ℤ} (ha : 0 ≤ a) (hb : 0 < b) (hm : 0 < m) (hn : 0 < n)
    (hco : Int.gcd a b = 1) {d : ℤ} (hd0 : 0 ≤ d) (hd : d ^ 2 = a ^ 2 + 4 * b ^ 2)
    (hc : b * m ^ 2 - a * m * n - b * n ^ 2 = b) : False := by
  have hda : a < d := by nlinarith
  -- `d` and `a` have the same parity, since `d² - a² = 4b²`
  have hev : Even (d - a) := by
    have h2 : Even ((d - a) * (d + a)) := ⟨2 * b ^ 2, by nlinarith⟩
    rcases Int.even_mul.mp h2 with h | h
    · exact h
    · have h3 : Even ((d + a) - 2 * a) := h.sub ⟨a, by ring⟩
      have h4 : (d + a) - 2 * a = d - a := by ring
      rwa [h4] at h3
  obtain ⟨E, hE⟩ := hev
  have hEd : d - a = 2 * E := by linarith [hE]
  set F : ℤ := E + a with hF
  have hEpos : 0 < E := by linarith
  have hFpos : 0 < F := by simp only [hF]; linarith
  have hEF : E * F = b ^ 2 := by simp only [hF]; nlinarith [hEd, hd]
  have hFE : F - E = a := by simp only [hF]; ring
  -- `E` and `F` are coprime, because a common divisor divides `a` and `b`
  have hcoEF : Int.gcd E F = 1 := by
    have hkE : ((Int.gcd E F : ℕ) : ℤ) ∣ E := Int.gcd_dvd_left E F
    have hkF : ((Int.gcd E F : ℕ) : ℤ) ∣ F := Int.gcd_dvd_right E F
    have hka : ((Int.gcd E F : ℕ) : ℤ) ∣ a := hFE ▸ dvd_sub hkF hkE
    have hkb : ((Int.gcd E F : ℕ) : ℤ) ∣ b := by
      have h2 : ((Int.gcd E F : ℕ) : ℤ) ^ 2 ∣ b ^ 2 := by
        rw [← hEF, sq]; exact mul_dvd_mul hkE hkF
      exact (Int.pow_dvd_pow_iff two_ne_zero).1 h2
    have hdd : Int.gcd E F ∣ Int.gcd a b := Int.dvd_gcd hka hkb
    rw [hco] at hdd
    exact Nat.dvd_one.mp hdd
  -- coprime factors of a square are squares
  obtain ⟨E0, hE0⟩ := Int.sq_of_gcd_eq_one hcoEF hEF
  obtain ⟨F0, hF0⟩ := Int.sq_of_gcd_eq_one (Int.gcd_comm E F ▸ hcoEF) (by rw [mul_comm]; exact hEF)
  set e : ℤ := |E0| with he
  set f : ℤ := |F0| with hf
  have hEe : E = e ^ 2 := by
    rcases hE0 with h | h
    · rw [h, he, sq_abs]
    · exfalso; nlinarith [sq_nonneg E0]
  have hFf : F = f ^ 2 := by
    rcases hF0 with h | h
    · rw [h, hf, sq_abs]
    · exfalso; nlinarith [sq_nonneg F0]
  have he0 : e ≠ 0 := by intro h; rw [h] at hEe; simp at hEe; omega
  have hf0 : f ≠ 0 := by intro h; rw [h] at hFf; simp at hFf; omega
  have hepos : 0 < e := lt_of_le_of_ne (abs_nonneg E0) (Ne.symm he0)
  have hfpos : 0 < f := lt_of_le_of_ne (abs_nonneg F0) (Ne.symm hf0)
  have hbef : b = e * f := by
    have h1 : (e * f - b) * (e * f + b) = 0 := by nlinarith [hEF, hEe, hFf]
    rcases mul_eq_zero.1 h1 with h | h
    · linarith
    · nlinarith [mul_pos hepos hfpos]
  have haef : a = f ^ 2 - e ^ 2 := by rw [← hFE, hEe, hFf]
  have hcoef : Int.gcd e f = 1 := by
    have hke : ((Int.gcd e f : ℕ) : ℤ) ∣ E := hEe ▸ Dvd.dvd.pow (Int.gcd_dvd_left e f) two_ne_zero
    have hkf : ((Int.gcd e f : ℕ) : ℤ) ∣ F := hFf ▸ Dvd.dvd.pow (Int.gcd_dvd_right e f) two_ne_zero
    have hdd : Int.gcd e f ∣ Int.gcd E F := Int.dvd_gcd hke hkf
    rw [hcoEF] at hdd
    exact Nat.dvd_one.mp hdd
  refine factored_conic_no_pos_solution hepos hfpos hm hn hcoef ?_
  rw [hbef, haef] at hc
  linear_combination hc

/-- **The square-discriminant case is empty.**  If `a ≥ 0`, `b > 0` and the discriminant
`a² + 4b²` is a perfect square, then the rational line of radial value `a/b` carries no node with
positive coordinates whatsoever.  Together with `ratConic_infinite` this settles the discriminant
dichotomy for the lines of the Poincaré-disk picture. -/
theorem ratConic_pos_empty_of_isSquare_disc {a b : ℤ} (ha : 0 ≤ a) (hb : 0 < b)
    (hD : IsSquare (a ^ 2 + 4 * b ^ 2)) :
    {q : ℤ × ℤ | RatConic a b q ∧ 0 < q.1 ∧ 0 < q.2} = ∅ := by
  ext ⟨m, n⟩
  simp only [Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false, not_and]
  rintro hcm hm hn
  simp only [RatConic] at hcm
  -- descend to the primitive line `a/g, b/g`
  set g : ℕ := Int.gcd a b with hg
  have hgpos : 0 < g := Int.gcd_pos_of_ne_zero_right a hb.ne'
  have hgZ : (0 : ℤ) < (g : ℤ) := by exact_mod_cast hgpos
  set a' : ℤ := a / (g : ℤ) with ha'
  set b' : ℤ := b / (g : ℤ) with hb'
  have hga : (g : ℤ) * a' = a := Int.mul_ediv_cancel' (Int.gcd_dvd_left a b)
  have hgb : (g : ℤ) * b' = b := Int.mul_ediv_cancel' (Int.gcd_dvd_right a b)
  have hco : Int.gcd a' b' = 1 := Int.gcd_div_gcd_div_gcd hgpos
  have ha'0 : 0 ≤ a' := by nlinarith [hga]
  have hb'0 : 0 < b' := by nlinarith [hgb]
  have hc' : b' * m ^ 2 - a' * m * n - b' * n ^ 2 = b' := by
    have h1 : (g : ℤ) * (b' * m ^ 2 - a' * m * n - b' * n ^ 2 - b') = 0 := by
      rw [show (g : ℤ) * (b' * m ^ 2 - a' * m * n - b' * n ^ 2 - b')
        = ((g : ℤ) * b') * m ^ 2 - ((g : ℤ) * a') * m * n - ((g : ℤ) * b') * n ^ 2
          - ((g : ℤ) * b') by ring, hga, hgb]
      linarith [hcm]
    rcases mul_eq_zero.1 h1 with h | h
    · exact absurd h hgZ.ne'
    · linarith
  -- the discriminant of the primitive line is again a square
  obtain ⟨r, hr⟩ := hD
  have hr2 : ((g : ℤ) * (a' ^ 2 + 4 * b' ^ 2)) * (g : ℤ) = r * r := by
    rw [← hr, ← hga, ← hgb]; ring
  have hgr : (g : ℤ) ∣ r := by
    have h2 : ((g : ℤ)) ^ 2 ∣ r ^ 2 := ⟨a' ^ 2 + 4 * b' ^ 2, by rw [sq, sq, ← hr2]; ring⟩
    exact (Int.pow_dvd_pow_iff two_ne_zero).1 h2
  obtain ⟨d0, hd0⟩ := hgr
  have hdisc : |d0| ^ 2 = a' ^ 2 + 4 * b' ^ 2 := by
    have h3 : (g : ℤ) ^ 2 * (d0 ^ 2 - (a' ^ 2 + 4 * b' ^ 2)) = 0 := by
      have := hr2
      rw [hd0] at this
      nlinarith [this]
    rcases mul_eq_zero.1 h3 with h | h
    · exact absurd (pow_eq_zero_iff two_ne_zero |>.1 h) hgZ.ne'
    · rw [sq_abs]; linarith
  exact ratConic_primitive_empty ha'0 hb'0 hm hn hco (abs_nonneg d0) hdisc hc'

/-! ## 3. The dichotomy -/

/-- **Nonempty ⇔ non-square discriminant.**  A rational line of the picture carries a node exactly
when its discriminant is not a perfect square. -/
theorem ratConic_pos_nonempty_iff {a b : ℤ} (ha : 0 ≤ a) (hb : 0 < b) :
    {q : ℤ × ℤ | RatConic a b q ∧ 0 < q.1 ∧ 0 < q.2}.Nonempty
      ↔ ¬ IsSquare (a ^ 2 + 4 * b ^ 2) := by
  constructor
  · rintro ⟨q, hq⟩ hD
    have := ratConic_pos_empty_of_isSquare_disc ha hb hD
    rw [this] at hq
    exact hq
  · intro hD
    exact (ratConic_infinite ha hb hD).nonempty

/-- **Infinite ⇔ non-square discriminant.**  Combining `ratConic_infinite` with the emptiness
theorem: a rational line is infinite exactly when it is nonempty. -/
theorem ratConic_pos_infinite_iff {a b : ℤ} (ha : 0 ≤ a) (hb : 0 < b) :
    {q : ℤ × ℤ | RatConic a b q ∧ 0 < q.1 ∧ 0 < q.2}.Infinite
      ↔ ¬ IsSquare (a ^ 2 + 4 * b ^ 2) := by
  constructor
  · intro hinf hD
    have := ratConic_pos_empty_of_isSquare_disc ha hb hD
    rw [this] at hinf
    exact hinf Set.finite_empty
  · exact ratConic_infinite ha hb

/-- **No short alignments.**  Every rational line through the centre is either completely empty or
carries infinitely many nodes; a finite nonempty line does not exist. -/
theorem ratConic_pos_empty_or_infinite {a b : ℤ} (ha : 0 ≤ a) (hb : 0 < b) :
    {q : ℤ × ℤ | RatConic a b q ∧ 0 < q.1 ∧ 0 < q.2} = ∅
      ∨ {q : ℤ × ℤ | RatConic a b q ∧ 0 < q.1 ∧ 0 < q.2}.Infinite := by
  by_cases hD : IsSquare (a ^ 2 + 4 * b ^ 2)
  · exact Or.inl (ratConic_pos_empty_of_isSquare_disc ha hb hD)
  · exact Or.inr (ratConic_infinite ha hb hD)

/-! ## 4. Consequences for the Berggren picture -/

/-- **A Diophantine corollary.**  For integers `0 < n < m` the number `(m² - n² - 1)² + (2mn)²` is
never a perfect square: the numerator and twice the denominator of the radial invariant of a node
are never the legs of a Pythagorean triple.

This is exactly the statement that no node of the picture sits on a square-discriminant line. -/
theorem radialDiscriminant_not_isSquare {m n : ℤ} (hn : 0 < n) (hmn : n < m) :
    ¬ IsSquare ((m ^ 2 - n ^ 2 - 1) ^ 2 + 4 * (m * n) ^ 2) := by
  intro hD
  have hm : 0 < m := hn.trans hmn
  have ha : 0 ≤ m ^ 2 - n ^ 2 - 1 := by nlinarith
  have hb : 0 < m * n := mul_pos hm hn
  have hmem : (m, n) ∈ {q : ℤ × ℤ | RatConic (m ^ 2 - n ^ 2 - 1) (m * n) q ∧ 0 < q.1 ∧ 0 < q.2} := by
    refine ⟨?_, hm, hn⟩
    simp only [RatConic]
    ring
  rw [ratConic_pos_empty_of_isSquare_disc ha hb hD] at hmem
  exact hmem

/-- **Every node lies on an infinite line.**  For any node `(m,n)` of the picture the radial line
through it — the conic `m n · x² - (m² - n² - 1) · x y - m n · y² = m n` — carries infinitely many
integral points with positive coordinates.  There are no isolated alignments: the straight lines
one sees through the nodes are genuinely infinite. -/
theorem node_line_infinite {m n : ℤ} (hn : 0 < n) (hmn : n < m) :
    {q : ℤ × ℤ | RatConic (m ^ 2 - n ^ 2 - 1) (m * n) q ∧ 0 < q.1 ∧ 0 < q.2}.Infinite := by
  have hm : 0 < m := hn.trans hmn
  have ha : 0 ≤ m ^ 2 - n ^ 2 - 1 := by nlinarith
  have hb : 0 < m * n := mul_pos hm hn
  exact ratConic_infinite ha hb (radialDiscriminant_not_isSquare hn hmn)

/-- **…and the line really is straight.**  Every point of the radial line through a node `(m,n)`
is exactly hyperbolically collinear with the centre `i` and with `(m,n)`: the Cayley–Menger
determinant `seedDet` of the triple vanishes identically along the line. -/
theorem node_line_collinear {m n : ℤ} (hn : 0 < n) (hmn : n < m) {q : ℤ × ℤ}
    (hq : q ∈ {q : ℤ × ℤ | RatConic (m ^ 2 - n ^ 2 - 1) (m * n) q ∧ 0 < q.1 ∧ 0 < q.2}) :
    seedDet 1 0 (m : ℝ) (n : ℝ) ((q.1 : ℤ) : ℝ) ((q.2 : ℤ) : ℝ) = 0 := by
  obtain ⟨hqc, hq1, hq2⟩ := hq
  have hm : 0 < m := hn.trans hmn
  have hbR : (0 : ℝ) < (m : ℝ) * (n : ℝ) := by
    have : (0 : ℤ) < m * n := mul_pos hm hn
    exact_mod_cast this
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hq1R : (0 : ℝ) < ((q.1 : ℤ) : ℝ) := by exact_mod_cast hq1
  have hq2R : (0 : ℝ) < ((q.2 : ℤ) : ℝ) := by exact_mod_cast hq2
  refine seedDet_base_eq_zero_ratConic (a := ((m : ℝ) ^ 2 - (n : ℝ) ^ 2 - 1))
    hbR hmR hnR hq1R hq2R (by ring) ?_
  simp only [RatConic] at hqc
  have := congrArg (fun x : ℤ => (x : ℝ)) hqc
  push_cast at this
  linarith [this]

end BerggrenHyperbolic