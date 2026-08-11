import Pythagorean.RationalStarDensity

/-!
# The innermost ray of a star is a Farey neighbourhood

The charge of a Euclid seed at a rational ideal point measures how well the slope of the
node approximates that ideal point:

  `n/m - p/q = - charge / (q m)`  (`slope_sub_eq_charge_div`).

So a node sits on a *low* ray of the star at `p/q` exactly when `p/q` is a *good* rational
approximation of its slope, in the strong Diophantine sense `|t - p/q| ≤ |k|/(q m)`. The
innermost ray, `|k| = 1`, is therefore the set of nodes whose slope is a **Farey neighbour**
of `p/q` — a unimodular partner — and Farey's theorem then says that nothing of small
denominator can be squeezed in between.

This is the arithmetic reason why the visible stars sit over small-denominator rationals:
the innermost ray of `p/q` is populated by the nodes that see `p/q` as a best approximation,
and there are many such nodes only when `q` is small.

## Main results

* `slope_sub_eq_charge_div` : the exact approximation dictionary.
* `abs_slope_sub_le_iff_charge_le` : `|n/m - p/q| ≤ K/(q m)` if and only if `|charge| ≤ K`;
  the rays of the star are precisely the levels of approximation quality.
* `farey_denominator_ge` : **Farey's theorem.** If `q n - p m = 1` (unimodular pair, i.e.
  charge `-1`) then no fraction strictly between `p/q` and `n/m` has denominator smaller
  than `q + m`.
* `mediant_lt`, `lt_mediant` : the mediant `(p+n)/(q+m)` realises the bound, so `q + m` is
  sharp.
* `innermost_ray_best_approximation` : a node on the innermost ray of the star at `p/q` is
  a Farey neighbour of `p/q`: between its slope and `p/q` there is no rational of
  denominator `< q + m`. The nodes of the innermost ray are best approximations, which is
  the Diophantine content of the visible innermost spoke.
* `two_principal_stars` : conversely, every node of the Berggren tree lies on the innermost
  ray of at least two distinct stars of denominator `≤ m` — every node participates in the
  star picture, in at least two places.
-/

namespace BerggrenRationalStar

open BerggrenHypercycleStars

/-! ## Part 1. The approximation dictionary -/

/-- The signed distance from the slope of a node to the ideal point `p/q` is
`- charge / (q m)`: the charge is the numerator of the approximation error. -/
theorem slope_sub_eq_charge_div (p : ℤ) (q m n : ℕ) (hq : 0 < q) (hm : 0 < m) :
    (n : ℝ) / m - (p : ℝ) / q = -(charge p q m n : ℝ) / ((q : ℝ) * m) := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  simp only [charge, chargeZ, Int.cast_sub, Int.cast_mul, Int.cast_natCast]
  field_simp
  ring

/-- **The rays are levels of approximation quality.** The node `z(m,n)` lies on a ray of
charge at most `K` in absolute value at `p/q` exactly when `p/q` approximates its slope to
within `K/(q m)`. -/
theorem abs_slope_sub_le_iff_charge_le (p : ℤ) (q m n : ℕ) (hq : 0 < q) (hm : 0 < m)
    (K : ℝ) :
    |(n : ℝ) / m - (p : ℝ) / q| ≤ K / ((q : ℝ) * m) ↔ |(charge p q m n : ℝ)| ≤ K := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hQM : (0 : ℝ) < (q : ℝ) * m := by positivity
  rw [slope_sub_eq_charge_div p q m n hq hm, abs_div, abs_neg,
    abs_of_pos hQM, div_le_div_iff_of_pos_right hQM]

/-! ## Part 2. Farey's theorem -/

/-- **Farey's theorem.** If the pair `(p/q, n/m)` is unimodular — `q n - p m = 1`, i.e. the
node `(m,n)` lies on the innermost ray of the star at `p/q` — then every rational strictly
between them has denominator at least `q + m`. -/
theorem farey_denominator_ge {p q n m r s : ℤ} (hq : 0 < q) (hm : 0 < m) (hs : 0 < s)
    (huni : q * n - p * m = 1) (h1 : (p : ℚ) / q < (r : ℚ) / s)
    (h2 : (r : ℚ) / s < (n : ℚ) / m) : q + m ≤ s := by
  have hqQ : (0 : ℚ) < (q : ℚ) := by exact_mod_cast hq
  have hmQ : (0 : ℚ) < (m : ℚ) := by exact_mod_cast hm
  have hsQ : (0 : ℚ) < (s : ℚ) := by exact_mod_cast hs
  -- turn the two strict inequalities into integer inequalities
  have hA : p * s < r * q := by
    have := (div_lt_div_iff₀ hqQ hsQ).mp h1
    exact_mod_cast this
  have hB : r * m < n * s := by
    have := (div_lt_div_iff₀ hsQ hmQ).mp h2
    exact_mod_cast this
  have hA' : 1 ≤ r * q - p * s := by omega
  have hB' : 1 ≤ n * s - m * r := by
    have hcomm : m * r = r * m := mul_comm _ _
    omega
  -- the classical determinant identity
  have hid : m * (r * q - p * s) + q * (n * s - m * r) = s * (q * n - p * m) := by ring
  rw [huni, mul_one] at hid
  nlinarith [hA', hB', hm, hq]

/-- The mediant of two fractions lies strictly between them (left half). -/
theorem lt_mediant {p q n m : ℤ} (hq : 0 < q) (hm : 0 < m)
    (h : (p : ℚ) / q < (n : ℚ) / m) : (p : ℚ) / q < ((p + n : ℤ) : ℚ) / ((q + m : ℤ) : ℚ) := by
  have hqQ : (0 : ℚ) < (q : ℚ) := by exact_mod_cast hq
  have hmQ : (0 : ℚ) < (m : ℚ) := by exact_mod_cast hm
  have hsum : (0 : ℚ) < ((q + m : ℤ) : ℚ) := by push_cast; linarith
  rw [div_lt_div_iff₀ hqQ hsum]
  have := (div_lt_div_iff₀ hqQ hmQ).mp h
  push_cast
  nlinarith [this]

/-- The mediant of two fractions lies strictly between them (right half). -/
theorem mediant_lt {p q n m : ℤ} (hq : 0 < q) (hm : 0 < m)
    (h : (p : ℚ) / q < (n : ℚ) / m) : ((p + n : ℤ) : ℚ) / ((q + m : ℤ) : ℚ) < (n : ℚ) / m := by
  have hqQ : (0 : ℚ) < (q : ℚ) := by exact_mod_cast hq
  have hmQ : (0 : ℚ) < (m : ℚ) := by exact_mod_cast hm
  have hsum : (0 : ℚ) < ((q + m : ℤ) : ℚ) := by push_cast; linarith
  rw [div_lt_div_iff₀ hsum hmQ]
  have := (div_lt_div_iff₀ hqQ hmQ).mp h
  push_cast
  nlinarith [this]

/-- The Farey bound `q + m` is **sharp**: the mediant is a fraction strictly between the two
with denominator exactly `q + m`. -/
theorem farey_bound_sharp {p q n m : ℤ} (hq : 0 < q) (hm : 0 < m)
    (h : (p : ℚ) / q < (n : ℚ) / m) :
    (p : ℚ) / q < ((p + n : ℤ) : ℚ) / ((q + m : ℤ) : ℚ) ∧
      ((p + n : ℤ) : ℚ) / ((q + m : ℤ) : ℚ) < (n : ℚ) / m :=
  ⟨lt_mediant hq hm h, mediant_lt hq hm h⟩

/-! ## Part 3. The innermost ray consists of best approximations -/

/-- **The innermost ray of a star is a Farey neighbourhood.** If the seed `(m,n)` sits on
the innermost ray of the star at `p/q` — that is, its charge there is `-1`, equivalently
`q n - p m = 1` — then no rational of denominator smaller than `q + m` lies strictly between
the ideal point `p/q` and the slope `n/m` of the node. The nodes of the innermost spoke are
best rational approximations to the star centre. -/
theorem innermost_ray_best_approximation {p q m n : ℕ} (hq : 0 < q) (hm : 0 < m)
    (hcharge : charge (p : ℤ) q m n = -1) {r s : ℤ} (hs : 0 < s)
    (h1 : (p : ℚ) / q < (r : ℚ) / s) (h2 : (r : ℚ) / s < (n : ℚ) / m) :
    (q : ℤ) + m ≤ s := by
  have huni : (q : ℤ) * n - (p : ℤ) * m = 1 := by
    have : (p : ℤ) * m - (q : ℤ) * n = -1 := hcharge
    linarith
  exact farey_denominator_ge (by exact_mod_cast hq) (by exact_mod_cast hm) hs huni h1 h2

/-- A node of charge `-1` at `p/q` really is closer to `p/q` than the Farey bound allows for
anything else: its slope differs from `p/q` by exactly `1/(q m)`. -/
theorem innermost_ray_error {p q m n : ℕ} (hq : 0 < q) (hm : 0 < m)
    (hcharge : charge (p : ℤ) q m n = -1) :
    (n : ℝ) / m - (p : ℝ) / q = 1 / ((q : ℝ) * m) := by
  have h := slope_sub_eq_charge_div (p : ℤ) q m n hq hm
  rw [hcharge] at h
  push_cast at h
  linarith [h]

/-! ## Part 4. Every node is the innermost node of at least two stars -/

/-- **Two principal stars.** Every Euclid seed `(m,n)` with `m ≥ 2` lies on the innermost
ray of two *distinct* stars whose denominator is smaller than `m`: a star `p/q` with
`q n - p m = 1` and a star `p'/q'` with `q' n - p' m = -1`. So every node of the Berggren
tree feeds two of the visible fans, as a Farey neighbour on either side. -/
theorem two_principal_stars {m n : ℕ} (h : IsSeed m n) (hm2 : 2 ≤ m) :
    ∃ p q p' q' : ℤ, 0 < q ∧ q < m ∧ 0 < q' ∧ q' < m ∧ (p, q) ≠ (p', q') ∧
      chargeZ p q m n = -1 ∧ chargeZ p' q' m n = 1 := by
  have hm0 : (0 : ℤ) < (m : ℤ) := by exact_mod_cast (by omega : 0 < m)
  have hm2' : (2 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hm2
  have hcop : Nat.Coprime n m := Nat.Coprime.symm h.cop
  obtain ⟨u, v, huv⟩ : IsCoprime (n : ℤ) (m : ℤ) := Int.isCoprime_iff_gcd_eq_one.mpr hcop
  set t : ℤ := u / (m : ℤ) with ht
  set q : ℤ := u % (m : ℤ) with hqdef
  have hqe : (m : ℤ) * t + q = u := Int.mul_ediv_add_emod u (m : ℤ)
  have hq0 : 0 ≤ q := Int.emod_nonneg u (ne_of_gt hm0)
  have hqm : q < (m : ℤ) := Int.emod_lt_of_pos u hm0
  have hqval : q = u - (m : ℤ) * t := by linarith [hqe]
  have hqne : q ≠ 0 := by
    intro h0
    have hu : u = (m : ℤ) * t := by rw [h0] at hqval; linarith
    have hdvd : (m : ℤ) ∣ 1 := ⟨t * n + v, by linear_combination -huv + (n : ℤ) * hu⟩
    have := Int.le_of_dvd (by norm_num) hdvd
    linarith
  have hqpos : 0 < q := lt_of_le_of_ne hq0 (Ne.symm hqne)
  set p : ℤ := -(v + t * n) with hp
  have hkey : q * (n : ℤ) - p * (m : ℤ) = 1 := by
    rw [hqval, hp]
    linear_combination huv
  refine ⟨p, q, (n : ℤ) - p, (m : ℤ) - q, hqpos, hqm, by linarith, by linarith, ?_, ?_, ?_⟩
  · intro hcontra
    have h1 : p = (n : ℤ) - p := congrArg Prod.fst hcontra
    have h2 : q = (m : ℤ) - q := congrArg Prod.snd hcontra
    have hcharge2 : ((m : ℤ) - q) * (n : ℤ) - ((n : ℤ) - p) * (m : ℤ) = -1 := by
      linarith [hkey]
    rw [← h1, ← h2] at hcharge2
    linarith [hkey, hcharge2]
  · simp only [chargeZ]
    linarith [hkey]
  · simp only [chargeZ]
    linarith [hkey]

end BerggrenRationalStar