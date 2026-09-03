import Catalog.Geometry.HyperbolicBerggrenGeodesicsII

/-!
# Hyperbolic–Pythagorean Geodesics, cycle III: quadratic ball growth

The first cycle proved that the hyperbolic ball of radius `R` around `i` contains at least
`e^{R-2} - 1` Berggren nodes, and conjectured (sub-conjecture **C1-lite**) the true order
`e^{2R}`: the number of nodes should grow like the *hypotenuse*, not like its square root.

This file proves that conjecture.  The obstruction is arithmetic, not geometric: one has to
produce quadratically many *coprime* pairs of opposite parity, which requires a sieve.

## Main results

* `card_multiples_Ioc` : the exact count of multiples of `k` in an interval `(a, b]`.
* `sum_inv_sq_odd`, `sum_inv_odd` : two telescoping estimates,
  `∑_{i<n} 1/(2i+3)² ≤ 1/4` and `∑_{i<n} 1/(2i+3) ≤ √(2n+1) - 1`.
* `card_seedBox_lower` : **the sieve bound.**  For `K ≥ 256` the box
  `{m even, 2K < m ≤ 4K} × {n odd, 1 ≤ n ≤ 2K}` contains at least `K²/4` Euclid seeds.
* `hyperbolic_ball_quadratic_growth` : **C1-lite, closed.**  For every `K ≥ 256` the
  hyperbolic ball of radius `R = log K + 2` around the base point contains at least
  `e^{2R}/300` distinct Berggren nodes.  Since every node with hypotenuse `c` sits at
  distance `≈ ½ log c`, this is the true order of growth, and it shows definitively that
  geodesic search through the Berggren tree cannot beat exhaustive search: the ball that
  is guaranteed to contain a colliding pair for `N` already contains `≍ N` nodes.
-/

namespace HyperbolicBerggrenGeodesics

open Real UpperHalfPlane

noncomputable section

/-! ## Part A. Counting multiples -/

/-- The number of multiples of `k` in the interval `(a, b]`. -/
theorem card_multiples_Ioc (k a b : ℕ) (hab : a ≤ b) :
    ((Finset.Ioc a b).filter (fun x => k ∣ x)).card = b / k - a / k := by
  have hsub : (Finset.Ioc 0 a).filter (fun x => k ∣ x)
      ⊆ (Finset.Ioc 0 b).filter (fun x => k ∣ x) := by
    intro x hx
    simp only [Finset.mem_filter, Finset.mem_Ioc] at hx ⊢
    exact ⟨⟨hx.1.1, hx.1.2.trans hab⟩, hx.2⟩
  have hEq : (Finset.Ioc a b).filter (fun x => k ∣ x)
      = ((Finset.Ioc 0 b).filter (fun x => k ∣ x)) \ ((Finset.Ioc 0 a).filter (fun x => k ∣ x)) := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_Ioc, Finset.mem_sdiff, not_and]
    constructor
    · rintro ⟨⟨h1, h2⟩, h3⟩
      exact ⟨⟨⟨by omega, h2⟩, h3⟩, by intro hc; omega⟩
    · rintro ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩
      refine ⟨⟨?_, h2⟩, h3⟩
      by_contra hc
      exact absurd h3 (h4 ⟨h1, by omega⟩)
  rw [hEq, Finset.card_sdiff_of_subset hsub, Nat.Ioc_filter_dvd_card_eq_div,
    Nat.Ioc_filter_dvd_card_eq_div]

/-- Natural division is subadditive up to one. -/
theorem add_div_le_add_div (a b k : ℕ) : (a + b) / k ≤ a / k + b / k + 1 := by
  rcases Nat.eq_zero_or_pos k with rfl | h
  · omega
  · have hma := Nat.mod_lt a h
    have hmb := Nat.mod_lt b h
    have hsplit : a + b = k * (a / k + b / k) + (a % k + b % k) := by
      have hka := Nat.div_add_mod a k
      have hkb := Nat.div_add_mod b k
      have : k * (a / k + b / k) = k * (a / k) + k * (b / k) := by ring
      omega
    rw [hsplit, Nat.mul_add_div h]
    have : (a % k + b % k) / k < 2 := (Nat.div_lt_iff_lt_mul h).2 (by omega)
    omega

/-! ## Part B. Two telescoping estimates -/

/-- `∑_{i<n} 1/(2i+3)² ≤ 1/4 - 1/(4n+4)`; in particular the sum is `< 1/4`. -/
theorem sum_inv_sq_odd (n : ℕ) :
    ∑ i ∈ Finset.range n, (1 : ℝ) / (2 * (i : ℝ) + 3) ^ 2 ≤ 1 / 4 - 1 / (4 * (n : ℝ) + 4) := by
  induction n with
  | zero => norm_num
  | succ n ih =>
    rw [Finset.sum_range_succ]
    have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    have key : (1 : ℝ) / (2 * (n : ℝ) + 3) ^ 2
        ≤ 1 / (4 * (n : ℝ) + 4) - 1 / (4 * ((n : ℝ) + 1) + 4) := by
      have e : 1 / (4 * (n : ℝ) + 4) - 1 / (4 * ((n : ℝ) + 1) + 4)
          = 4 / ((4 * (n : ℝ) + 4) * (4 * (n : ℝ) + 8)) := by
        field_simp
        ring
      rw [e]
      refine (div_le_div_iff₀ (by positivity) (by positivity)).mpr ?_
      nlinarith [sq_nonneg ((n : ℝ))]
    push_cast
    linarith [ih]

/-- `∑_{i<n} 1/(2i+3) ≤ √(2n+1) - 1`. -/
theorem sum_inv_odd (n : ℕ) :
    ∑ i ∈ Finset.range n, (1 : ℝ) / (2 * (i : ℝ) + 3) ≤ Real.sqrt (2 * (n : ℝ) + 1) - 1 := by
  induction n with
  | zero => norm_num
  | succ n ih =>
    rw [Finset.sum_range_succ]
    have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    set u := Real.sqrt (2 * (n : ℝ) + 1) with hu
    have hu2 : u ^ 2 = 2 * (n : ℝ) + 1 := Real.sq_sqrt (by positivity)
    have hupos : 0 < u := Real.sqrt_pos.2 (by positivity)
    have hveq : Real.sqrt (2 * ((n : ℝ) + 1) + 1) = Real.sqrt (2 * (n : ℝ) + 3) := by
      congr 1; ring
    set v := Real.sqrt (2 * (n : ℝ) + 3) with hv
    have hv2 : v ^ 2 = 2 * (n : ℝ) + 3 := Real.sq_sqrt (by positivity)
    have hvpos : 0 < v := Real.sqrt_pos.2 (by positivity)
    have hv1 : 1 ≤ v := by nlinarith
    have key : (1 : ℝ) / (2 * (n : ℝ) + 3) ≤ v - u := by
      rw [div_le_iff₀ (by positivity)]
      nlinarith [sq_nonneg (v - u), sq_nonneg (v + u)]
    push_cast
    rw [hveq]
    linarith [ih]

/-! ## Part C. The sieve -/

/-- Even numbers in `(2K, 4K]`. -/
def evenBox (K : ℕ) : Finset ℕ := (Finset.Ioc (2 * K) (4 * K)).filter (fun m => 2 ∣ m)

/-- Odd numbers in `[1, 2K]`. -/
def oddBox (K : ℕ) : Finset ℕ := (Finset.Icc 1 (2 * K)).filter (fun n => ¬ 2 ∣ n)

/-- The coprime pairs of the box: genuine Euclid seeds. -/
def seedBox (K : ℕ) : Finset (ℕ × ℕ) :=
  ((evenBox K) ×ˢ (oddBox K)).filter (fun p => Nat.Coprime p.1 p.2)

/-- The possible odd common divisors. -/
def oddDivs (K : ℕ) : Finset ℕ := (Finset.Icc 3 (2 * K)).filter (fun d => ¬ 2 ∣ d)

theorem card_evenBox (K : ℕ) : (evenBox K).card = K := by
  rw [evenBox, card_multiples_Ioc 2 (2 * K) (4 * K) (by omega)]
  omega

theorem card_oddBox (K : ℕ) : (oddBox K).card = K := by
  have hall : (Finset.Icc 1 (2 * K)).card = 2 * K := by simp
  have hhalf : ((Finset.Icc 1 (2 * K)).filter (fun n => 2 ∣ n)).card = K := by
    have hIcc : Finset.Icc 1 (2 * K) = Finset.Ioc 0 (2 * K) := by
      ext x; simp [Nat.lt_iff_add_one_le]
    rw [hIcc, Nat.Ioc_filter_dvd_card_eq_div]
    omega
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := Finset.Icc 1 (2 * K)) (p := fun n => 2 ∣ n)
  rw [oddBox]
  omega

/-- Every element of the coprime box is a Euclid seed. -/
theorem mem_seedBox_isSeed {K : ℕ} {p : ℕ × ℕ} (hp : p ∈ seedBox K) : IsSeed p.1 p.2 := by
  rw [seedBox, Finset.mem_filter, Finset.mem_product] at hp
  obtain ⟨⟨hm, hn⟩, hcop⟩ := hp
  rw [evenBox, Finset.mem_filter, Finset.mem_Ioc] at hm
  rw [oddBox, Finset.mem_filter, Finset.mem_Icc] at hn
  obtain ⟨⟨hm1, hm2⟩, hm3⟩ := hm
  obtain ⟨⟨hn1, hn2⟩, hn3⟩ := hn
  refine ⟨by omega, by omega, hcop, ?_⟩
  omega

/-- Multiples of an odd `d` inside the even box are multiples of `2d`. -/
theorem card_evenBox_filter {K d : ℕ} (hd : ¬ 2 ∣ d) :
    ((evenBox K).filter (fun m => d ∣ m)).card ≤ K / d + 1 := by
  have hcop : Nat.Coprime 2 d := (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).2 hd
  have hset : (evenBox K).filter (fun m => d ∣ m)
      = (Finset.Ioc (2 * K) (4 * K)).filter (fun m => 2 * d ∣ m) := by
    rw [evenBox, Finset.filter_filter]
    apply Finset.filter_congr
    intro x _
    constructor
    · rintro ⟨h2, hdx⟩
      exact hcop.mul_dvd_of_dvd_of_dvd h2 hdx
    · intro h
      exact ⟨dvd_trans ⟨d, rfl⟩ h, dvd_trans ⟨2, by ring⟩ h⟩
  rw [hset, card_multiples_Ioc _ _ _ (by omega)]
  have h1 : 4 * K / (2 * d) = 2 * K / d := by
    rw [show 4 * K = 2 * (2 * K) by ring, Nat.mul_div_mul_left _ _ (by omega)]
  have h2 : 2 * K / (2 * d) = K / d := Nat.mul_div_mul_left _ _ (by omega)
  rw [h1, h2]
  have h3 : 2 * K / d ≤ K / d + K / d + 1 := by
    have h := add_div_le_add_div K K d
    rwa [show K + K = 2 * K from (two_mul K).symm] at h
  exact Nat.sub_le_iff_le_add.2 (by linarith)

theorem card_oddBox_filter (K d : ℕ) :
    ((oddBox K).filter (fun n => d ∣ n)).card ≤ 2 * K / d := by
  have hsub : (oddBox K).filter (fun n => d ∣ n)
      ⊆ (Finset.Ioc 0 (2 * K)).filter (fun n => d ∣ n) := by
    intro x hx
    rw [oddBox, Finset.filter_filter, Finset.mem_filter, Finset.mem_Icc] at hx
    simp only [Finset.mem_filter, Finset.mem_Ioc]
    exact ⟨⟨by omega, by omega⟩, hx.2.2⟩
  have := Finset.card_le_card hsub
  rwa [Nat.Ioc_filter_dvd_card_eq_div] at this

/-- The non-coprime pairs of the box are covered by the odd-divisor classes. -/
theorem bad_subset {K : ℕ} :
    ((evenBox K ×ˢ oddBox K).filter (fun p => ¬ Nat.Coprime p.1 p.2))
      ⊆ (oddDivs K).biUnion (fun d =>
          ((evenBox K).filter (fun m => d ∣ m)) ×ˢ ((oddBox K).filter (fun n => d ∣ n))) := by
  intro p hp
  rw [Finset.mem_filter, Finset.mem_product] at hp
  obtain ⟨⟨hm, hn⟩, hcop⟩ := hp
  have hn' := hn
  rw [oddBox, Finset.mem_filter, Finset.mem_Icc] at hn'
  obtain ⟨⟨hn1, hn2⟩, hn3⟩ := hn'
  set d := Nat.gcd p.1 p.2 with hd
  have hdm : d ∣ p.1 := Nat.gcd_dvd_left _ _
  have hdn : d ∣ p.2 := Nat.gcd_dvd_right _ _
  have hdle : d ≤ p.2 := Nat.le_of_dvd (by omega) hdn
  have hdodd : ¬ 2 ∣ d := fun h2 => hn3 (h2.trans hdn)
  have hd0 : d ≠ 0 := by
    intro h0
    rw [h0] at hdn
    omega
  have hd1 : d ≠ 1 := hcop
  have hd3 : 3 ≤ d := by
    rcases Nat.lt_or_ge d 3 with h | h
    · interval_cases d
      · exact absurd rfl hd0
      · exact absurd rfl hd1
      · exact absurd ⟨1, rfl⟩ hdodd
    · exact h
  refine Finset.mem_biUnion.2 ⟨d, ?_, ?_⟩
  · rw [oddDivs, Finset.mem_filter, Finset.mem_Icc]
    exact ⟨⟨hd3, by omega⟩, hdodd⟩
  · exact Finset.mem_product.2 ⟨Finset.mem_filter.2 ⟨hm, hdm⟩, Finset.mem_filter.2 ⟨hn, hdn⟩⟩

/-- The sieve inequality in `ℕ`. -/
theorem card_bad_le (K : ℕ) :
    ((evenBox K ×ˢ oddBox K).filter (fun p => ¬ Nat.Coprime p.1 p.2)).card
      ≤ ∑ d ∈ oddDivs K, (K / d + 1) * (2 * K / d) := by
  refine le_trans (Finset.card_le_card bad_subset) ?_
  refine le_trans (Finset.card_biUnion_le) ?_
  refine Finset.sum_le_sum ?_
  intro d hd
  rw [oddDivs, Finset.mem_filter, Finset.mem_Icc] at hd
  rw [Finset.card_product]
  exact Nat.mul_le_mul (card_evenBox_filter hd.2) (card_oddBox_filter K d)

/-! ## Part D. From the sieve to a quadratic lower bound -/

/-- The real-valued sieve estimate. -/
theorem sum_bad_real_le (K : ℕ) :
    (((∑ d ∈ oddDivs K, (K / d + 1) * (2 * K / d) : ℕ)) : ℝ)
      ≤ (K : ℝ) ^ 2 / 2 + 2 * (K : ℝ) * Real.sqrt (2 * (K : ℝ) + 1) := by
  have hK0 : (0 : ℝ) ≤ (K : ℝ) := Nat.cast_nonneg K
  rw [Nat.cast_sum]
  set g : ℕ → ℝ := fun d => ((K : ℝ) / (d : ℝ) + 1) * (2 * (K : ℝ) / (d : ℝ)) with hg
  -- each term is bounded by its real counterpart
  have hterm : ∀ d ∈ oddDivs K, (((K / d + 1) * (2 * K / d) : ℕ) : ℝ) ≤ g d := by
    intro d hd
    rw [oddDivs, Finset.mem_filter, Finset.mem_Icc] at hd
    have hd0 : (0 : ℝ) < (d : ℝ) := by
      have : 0 < d := by omega
      exact_mod_cast this
    push_cast
    have h1 : (((K / d : ℕ)) : ℝ) ≤ (K : ℝ) / d := Nat.cast_div_le
    have h2 : (((2 * K / d : ℕ)) : ℝ) ≤ (2 * (K : ℝ)) / d := by
      have := Nat.cast_div_le (α := ℝ) (m := 2 * K) (n := d)
      push_cast at this
      linarith
    have h3 : (0 : ℝ) ≤ (((2 * K / d : ℕ)) : ℝ) := Nat.cast_nonneg _
    rw [hg]
    nlinarith [Nat.cast_nonneg (α := ℝ) (K / d)]
  refine le_trans (Finset.sum_le_sum hterm) ?_
  -- reindex the odd divisors as `2i+3`
  have hsub : oddDivs K ⊆ (Finset.range K).image (fun i => 2 * i + 3) := by
    intro d hd
    rw [oddDivs, Finset.mem_filter, Finset.mem_Icc] at hd
    refine Finset.mem_image.2 ⟨(d - 3) / 2, Finset.mem_range.2 (by omega), ?_⟩
    omega
  have hnonneg : ∀ d ∈ (Finset.range K).image (fun i => 2 * i + 3),
      d ∉ oddDivs K → (0 : ℝ) ≤ g d := by
    intro d hd _
    have : (0 : ℝ) ≤ (d : ℝ) := Nat.cast_nonneg d
    rw [hg]
    positivity
  refine le_trans (Finset.sum_le_sum_of_subset_of_nonneg hsub hnonneg) ?_
  have hinj : Set.InjOn (fun i => 2 * i + 3) (Finset.range K) := by
    intro x _ y _ h
    dsimp only at h
    omega
  rw [Finset.sum_image hinj]
  -- split into the `1/d²` and `1/d` parts
  have hsplit : ∀ i ∈ Finset.range K,
      g (2 * i + 3)
        = 2 * (K : ℝ) ^ 2 * (1 / (2 * (i : ℝ) + 3) ^ 2)
          + 2 * (K : ℝ) * (1 / (2 * (i : ℝ) + 3)) := by
    intro i _
    have hi : ((2 * i + 3 : ℕ) : ℝ) = 2 * (i : ℝ) + 3 := by push_cast; ring
    rw [hg]
    simp only [hi]
    have hpos : (0 : ℝ) < 2 * (i : ℝ) + 3 := by positivity
    field_simp
  rw [Finset.sum_congr rfl hsplit, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
  have h1 := sum_inv_sq_odd K
  have h2 := sum_inv_odd K
  have hs : 0 ≤ Real.sqrt (2 * (K : ℝ) + 1) := Real.sqrt_nonneg _
  have hb1 : 2 * (K : ℝ) ^ 2 * (∑ i ∈ Finset.range K, (1 : ℝ) / (2 * (i : ℝ) + 3) ^ 2)
      ≤ (K : ℝ) ^ 2 / 2 := by
    have hnn : (0 : ℝ) ≤ 2 * (K : ℝ) ^ 2 := by positivity
    have : (∑ i ∈ Finset.range K, (1 : ℝ) / (2 * (i : ℝ) + 3) ^ 2) ≤ 1 / 4 := by
      have : (0 : ℝ) < 4 * (K : ℝ) + 4 := by positivity
      linarith [h1, one_div_pos.2 this]
    nlinarith
  have hb2 : 2 * (K : ℝ) * (∑ i ∈ Finset.range K, (1 : ℝ) / (2 * (i : ℝ) + 3))
      ≤ 2 * (K : ℝ) * Real.sqrt (2 * (K : ℝ) + 1) := by
    have hnn : (0 : ℝ) ≤ 2 * (K : ℝ) := by positivity
    nlinarith [h2]
  linarith

/-- **The sieve bound.**  For `K ≥ 256` the box contains at least `K²/4` Euclid seeds. -/
theorem card_seedBox_lower {K : ℕ} (hK : 256 ≤ K) : (K : ℝ) ^ 2 / 4 ≤ ((seedBox K).card : ℝ) := by
  have hKR : (256 : ℝ) ≤ (K : ℝ) := by exact_mod_cast hK
  have hK0 : (0 : ℝ) < (K : ℝ) := by linarith
  -- total = good + bad
  have htotal : (evenBox K ×ˢ oddBox K).card = K * K := by
    rw [Finset.card_product, card_evenBox, card_oddBox]
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := evenBox K ×ˢ oddBox K) (p := fun p => Nat.Coprime p.1 p.2)
  have hgood : (seedBox K).card
      + ((evenBox K ×ˢ oddBox K).filter (fun p => ¬ Nat.Coprime p.1 p.2)).card = K * K := by
    rw [seedBox]
    omega
  have hbad : (((evenBox K ×ˢ oddBox K).filter (fun p => ¬ Nat.Coprime p.1 p.2)).card : ℝ)
      ≤ (K : ℝ) ^ 2 / 2 + 2 * K * Real.sqrt (2 * K + 1) := by
    refine le_trans ?_ (sum_bad_real_le K)
    exact_mod_cast card_bad_le K
  -- `2 K √(2K+1) ≤ K²/4` for `K ≥ 256`
  have hsq : Real.sqrt (2 * (K : ℝ) + 1) ≤ (K : ℝ) / 8 := by
    rw [show (K : ℝ) / 8 = Real.sqrt (((K : ℝ) / 8) ^ 2) from (Real.sqrt_sq (by linarith)).symm]
    apply Real.sqrt_le_sqrt
    nlinarith
  have hfinal : 2 * (K : ℝ) * Real.sqrt (2 * (K : ℝ) + 1) ≤ (K : ℝ) ^ 2 / 4 := by
    nlinarith
  have hcast : ((seedBox K).card : ℝ) + (((evenBox K ×ˢ oddBox K).filter
      (fun p => ¬ Nat.Coprime p.1 p.2)).card : ℝ) = (K : ℝ) * K := by
    exact_mod_cast congrArg (fun x : ℕ => (x : ℝ)) hgood
  nlinarith [hbad, hfinal, hcast]

/-! ## Part E. Quadratic volume growth of hyperbolic balls (C1-lite, closed) -/

/-- The hyperbolic point attached to a pair, extended by a default value. -/
def nodePoint (p : ℕ × ℕ) : ℍ :=
  if h : 0 < p.1 then hpoint p.1 p.2 h else UpperHalfPlane.I

theorem nodePoint_injOn (K : ℕ) : Set.InjOn nodePoint (seedBox K) := by
  intro p hp q hq hpq
  have hsp := mem_seedBox_isSeed (K := K) (by simpa using hp)
  have hsq := mem_seedBox_isSeed (K := K) (by simpa using hq)
  have hp0 : 0 < p.1 := lt_trans hsp.pos hsp.lt
  have hq0 : 0 < q.1 := lt_trans hsq.pos hsq.lt
  rw [nodePoint, nodePoint, dif_pos hp0, dif_pos hq0] at hpq
  obtain ⟨h1, h2⟩ := hpoint_injective hp0 hq0 hpq
  exact Prod.ext h1 h2

/-- Every node of the box lies within hyperbolic distance `log K + 2` of the base point. -/
theorem nodePoint_dist_le {K : ℕ} (hK : 256 ≤ K) {p : ℕ × ℕ} (hp : p ∈ seedBox K) :
    dist (nodePoint p) UpperHalfPlane.I ≤ Real.log K + 2 := by
  have hs := mem_seedBox_isSeed hp
  have hp0 : 0 < p.1 := lt_trans hs.pos hs.lt
  rw [nodePoint, dif_pos hp0]
  have hb := dist_le_half_log_two_hypotenuse hs.pos hs.lt
  refine le_trans hb ?_
  -- the box forces `m ≤ 4K` and `n ≤ 2K`, so `2 (c+1) ≤ 42 K² ≤ K² e⁴`
  rw [seedBox, Finset.mem_filter, Finset.mem_product] at hp
  obtain ⟨⟨hm, hn⟩, -⟩ := hp
  rw [evenBox, Finset.mem_filter, Finset.mem_Ioc] at hm
  rw [oddBox, Finset.mem_filter, Finset.mem_Icc] at hn
  have hmle : (p.1 : ℝ) ≤ 4 * K := by exact_mod_cast hm.1.2
  have hnle : (p.2 : ℝ) ≤ 2 * K := by exact_mod_cast hn.1.2
  have hm0 : (0 : ℝ) ≤ (p.1 : ℝ) := Nat.cast_nonneg _
  have hn0 : (0 : ℝ) ≤ (p.2 : ℝ) := Nat.cast_nonneg _
  have hKR : (256 : ℝ) ≤ (K : ℝ) := by exact_mod_cast hK
  have hK0 : (0 : ℝ) < (K : ℝ) := by linarith
  have hc : 2 * ((p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2 + 1) ≤ 42 * (K : ℝ) ^ 2 := by nlinarith
  have hexp : (42 : ℝ) ≤ Real.exp 4 := by
    have h1 : (2.7182818283 : ℝ) ≤ Real.exp 1 := le_of_lt Real.exp_one_gt_d9
    have h2 : Real.exp 4 = (Real.exp 1) ^ 4 := by
      rw [← Real.exp_nat_mul]; norm_num
    have h3 : (2.7182818283 : ℝ) ^ 4 ≤ (Real.exp 1) ^ 4 :=
      pow_le_pow_left₀ (by norm_num) h1 4
    rw [h2]
    nlinarith [h3]
  have hle : 2 * ((p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2 + 1) ≤ Real.exp 4 * (K : ℝ) ^ 2 := by
    nlinarith
  have hpos : (0 : ℝ) < 2 * ((p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2 + 1) := by positivity
  have hlog : Real.log (2 * ((p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2 + 1))
      ≤ 4 + 2 * Real.log K := by
    have hR : Real.log (Real.exp 4 * (K : ℝ) ^ 2) = 4 + 2 * Real.log K := by
      rw [Real.log_mul (by positivity) (by positivity), Real.log_exp, Real.log_pow]
      push_cast; ring
    have h1 := Real.log_le_log hpos hle
    rwa [hR] at h1
  linarith

/-- **C1-lite, closed: quadratic volume growth.**
For every `K ≥ 256` there are at least `e^{2R}/300` distinct Berggren nodes inside the
hyperbolic ball of radius `R = log K + 2` around the base point `i`.

Combined with `dist_ge_half_log_hypotenuse` (`d ≥ ½ log c`), this pins the growth exponent:
the ball of radius `R` contains `≍ e^{2R}` nodes, i.e. as many as there are hypotenuses of
size `e^{2R}`.  Geodesic energy minimisation therefore cannot factor `N` faster than
exhaustive search over the collision fibre. -/
theorem hyperbolic_ball_quadratic_growth {K : ℕ} (hK : 256 ≤ K) :
    ∃ (R : ℝ) (S : Finset ℍ), R = Real.log K + 2 ∧
      Real.exp (2 * R) / 300 ≤ (S.card : ℝ) ∧
      ∀ z ∈ S, dist z UpperHalfPlane.I ≤ R := by
  classical
  refine ⟨Real.log K + 2, (seedBox K).image nodePoint, rfl, ?_, ?_⟩
  · have hcard : (((seedBox K).image nodePoint).card : ℝ) = ((seedBox K).card : ℝ) := by
      rw [Finset.card_image_of_injOn (nodePoint_injOn K)]
    rw [hcard]
    refine le_trans ?_ (card_seedBox_lower hK)
    have hKR : (256 : ℝ) ≤ (K : ℝ) := by exact_mod_cast hK
    have hK0 : (0 : ℝ) < (K : ℝ) := by linarith
    have hexp : Real.exp (2 * (Real.log K + 2)) = Real.exp 4 * (K : ℝ) ^ 2 := by
      rw [show 2 * (Real.log K + 2) = 4 + 2 * Real.log K by ring, Real.exp_add,
        show (2 : ℝ) * Real.log K = Real.log ((K : ℝ) ^ 2) by
          rw [Real.log_pow]; push_cast; ring,
        Real.exp_log (by positivity)]
    rw [hexp]
    have h4 : Real.exp 4 ≤ 75 := by
      have h1 : Real.exp 1 ≤ 2.7182818286 := le_of_lt Real.exp_one_lt_d9
      have h2 : Real.exp 4 = (Real.exp 1) ^ 4 := by
        rw [← Real.exp_nat_mul]; norm_num
      have h3 : (Real.exp 1) ^ 4 ≤ (2.7182818286 : ℝ) ^ 4 :=
        pow_le_pow_left₀ (Real.exp_pos 1).le h1 4
      rw [h2]
      nlinarith [h3]
    nlinarith [sq_nonneg ((K : ℝ))]
  · intro z hz
    obtain ⟨p, hp, rfl⟩ := Finset.mem_image.1 hz
    exact nodePoint_dist_le hK hp

/-! ## Part F. Cycle IV: the matching upper bound, and exact semiprime splitting -/

/-- **Matching upper bound (sub-conjecture D1-lite, closed).**
Any family of Berggren nodes inside the hyperbolic ball of radius `R` has at most
`4 e^{2R}` members.  Together with `hyperbolic_ball_quadratic_growth` this pins the volume
growth of the Berggren tree in the hyperbolic metric to the exact exponent `2R`:
`e^{2R}/300 ≤ #B(R) ≤ 4 e^{2R}`. -/
theorem ball_card_upper {R : ℝ} (hR : 0 ≤ R) (S : Finset (ℕ × ℕ))
    (hseed : ∀ p ∈ S, IsSeed p.1 p.2)
    (hball : ∀ p ∈ S, ∀ h : 0 < p.1, dist (hpoint p.1 p.2 h) UpperHalfPlane.I ≤ R) :
    (S.card : ℝ) ≤ 4 * Real.exp (2 * R) := by
  classical
  set M : ℕ := ⌊Real.exp R⌋₊ with hM
  have hMle : (M : ℝ) ≤ Real.exp R := Nat.floor_le (Real.exp_pos R).le
  -- every node in the ball has both coordinates at most `M`
  have hsub : S ⊆ Finset.range (M + 1) ×ˢ Finset.range (M + 1) := by
    intro p hp
    have hs := hseed p hp
    have hp0 : 0 < p.1 := lt_trans hs.pos hs.lt
    have hd := hball p hp hp0
    have hlow := dist_ge_half_log_hypotenuse hs.pos hs.lt
    have hc0 : (0 : ℝ) < (p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2 := by
      have : (0 : ℝ) < (p.1 : ℝ) := by exact_mod_cast hp0
      positivity
    have hlog : Real.log ((p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2) ≤ 2 * R := by linarith
    have hcle : (p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2 ≤ Real.exp (2 * R) := by
      have := Real.exp_le_exp.2 hlog
      rwa [Real.exp_log hc0] at this
    have hm2 : (p.1 : ℝ) ^ 2 ≤ (Real.exp R) ^ 2 := by
      have hn0 : (0 : ℝ) ≤ (p.2 : ℝ) ^ 2 := by positivity
      have hsq : (Real.exp R) ^ 2 = Real.exp (2 * R) := by
        rw [← Real.exp_nat_mul]; ring_nf
      rw [hsq]
      linarith
    have hmle : (p.1 : ℝ) ≤ Real.exp R := by
      nlinarith [Nat.cast_nonneg (α := ℝ) p.1, (Real.exp_pos R).le]
    have hmM : p.1 ≤ M := Nat.le_floor hmle
    have hnM : p.2 ≤ M := le_trans hs.lt.le hmM
    exact Finset.mem_product.2 ⟨Finset.mem_range.2 (by omega), Finset.mem_range.2 (by omega)⟩
  have hcard : S.card ≤ (M + 1) * (M + 1) := by
    simpa [Finset.card_product] using Finset.card_le_card hsub
  have hcardR : (S.card : ℝ) ≤ ((M : ℝ) + 1) * ((M : ℝ) + 1) := by
    have : ((S.card : ℕ) : ℝ) ≤ (((M + 1) * (M + 1) : ℕ) : ℝ) := by exact_mod_cast hcard
    push_cast at this
    linarith
  have he1 : (1 : ℝ) ≤ Real.exp R := Real.one_le_exp hR
  have hsq : (Real.exp R) ^ 2 = Real.exp (2 * R) := by
    rw [← Real.exp_nat_mul]; ring_nf
  nlinarith [Nat.cast_nonneg (α := ℝ) M]

/-- **Exact semiprime splitting (sub-conjecture D2-lite, closed).**
If `N = p q` is a product of two primes and two distinct Berggren nodes carry the
hypotenuse `N`, then the two factors produced by `berggren_collision_splits` are exactly
`p` and `q`: a single collision fully factors the semiprime.  (The hypothesis `p ≠ q` that one
might expect turns out to be unnecessary: the argument only uses primality of `p` and `q`.) -/
theorem semiprime_collision_splits_exactly {m₁ n₁ m₂ n₂ p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (h₁ : IsSeed m₁ n₁) (h₂ : IsSeed m₂ n₂)
    (hN₁ : m₁ ^ 2 + n₁ ^ 2 = p * q) (hN₂ : m₂ ^ 2 + n₂ ^ 2 = p * q)
    (hne : (m₁, n₁) ≠ (m₂, n₂)) :
    (Nat.gcd (p * q) (m₁ * m₂ + n₁ * n₂) = p ∧ Nat.gcd (p * q) (m₁ * n₂ + n₁ * m₂) = q) ∨
      (Nat.gcd (p * q) (m₁ * m₂ + n₁ * n₂) = q ∧ Nat.gcd (p * q) (m₁ * n₂ + n₁ * m₂) = p) := by
  obtain ⟨hprod, hg1, hg2, hh1, hh2⟩ := berggren_collision_splits h₁ h₂ hN₁ hN₂ hne
  set g := Nat.gcd (p * q) (m₁ * m₂ + n₁ * n₂) with hgdef
  set h := Nat.gcd (p * q) (m₁ * n₂ + n₁ * m₂) with hhdef
  -- `g` is a divisor of `p q` other than `1` and `p q`, hence `p` or `q`
  have hgdvd : g ∣ p * q := Nat.gcd_dvd_left _ _
  have hgp : g = p ∨ g = q := by
    by_cases hdvd : p ∣ g
    · obtain ⟨t, ht⟩ := hdvd
      have htq : t ∣ q := by
        have : p * t ∣ p * q := ht ▸ hgdvd
        exact (mul_dvd_mul_iff_left (by exact_mod_cast hp.pos.ne' : (p : ℕ) ≠ 0)).1 this
      rcases (hq.eq_one_or_self_of_dvd t htq) with h1 | h1
      · left; rw [ht, h1, mul_one]
      · exfalso; rw [ht, h1] at hg2; omega
    · right
      have hcopg : Nat.Coprime g p := (Nat.Prime.coprime_iff_not_dvd hp).2 hdvd |>.symm
      have : g ∣ q := hcopg.dvd_of_dvd_mul_left hgdvd
      rcases (hq.eq_one_or_self_of_dvd g this) with h1 | h1
      · exact absurd h1 (by omega)
      · exact h1
  have hqpos : 0 < q := hq.pos
  have hppos : 0 < p := hp.pos
  rcases hgp with hgval | hgval
  · left
    refine ⟨hgval, ?_⟩
    rw [hgval] at hprod
    exact Nat.eq_of_mul_eq_mul_left hppos hprod
  · right
    refine ⟨hgval, ?_⟩
    rw [hgval, mul_comm p q] at hprod
    exact Nat.eq_of_mul_eq_mul_left hqpos hprod

end

end HyperbolicBerggrenGeodesics