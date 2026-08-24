/-
# The one-bit cap, III: the exact two-primary law

For the two-state fork `q = 2` the fibre estimate of `Tropical.OneBitCapCore` is
an *equality*: on a type class of `box (2^k)` the product residue is confined to a
single coset of `2^(v+1) ℤ`, and that coset has exactly as many elements as the
larger of the two type classes.  Combining the resulting upper bound for the
conditional entropy with the universal lower bound gives the exact law

  `Ipair (2 ^ k) = (4/3) (1 - 4^{-k})`,

which reproduces the catalogue values `Ipair 2 = 1`, `Ipair 4 = 5/4`,
`Ipair 16 = 85/64`, `Ipair 32 = 341/256` and settles the whole `2`-primary tower:
the cap is attained exactly at `k = 1` and strictly exceeded for every `k ≥ 2`.
-/
import Tropical.OneBitCapPrimePower

namespace CyclicTypeChannel

open Finset

/-! ## 1. Two-adic bookkeeping -/

/-- The gcd of any exponent with `2 ^ k` is a power of two. -/
theorem gcd_two_pow_eq (k a : ℕ) : ∃ j ≤ k, Nat.gcd a (2 ^ k) = 2 ^ j :=
  (Nat.dvd_prime_pow Nat.prime_two).1 (Nat.gcd_dvd_right _ _)

/-- The splitting type in terms of the two-adic gcd. -/
theorem ordType_two_pow {k a j : ℕ} (hj : j ≤ k) (h : Nat.gcd a (2 ^ k) = 2 ^ j) :
    ordType (2 ^ k) a = 2 ^ (k - j) := by
  rw [ordType, h, Nat.pow_div hj (by norm_num)]

theorem totient_two_pow {c : ℕ} (hc : 0 < c) : Nat.totient (2 ^ c) = 2 ^ (c - 1) := by
  rw [Nat.totient_prime_pow Nat.prime_two hc]
  simp

/-- The splitting type determines the gcd. -/
theorem gcd_eq_of_ordType_eq {n a b : ℕ} (hn : 0 < n) (h : ordType n a = ordType n b) :
    Nat.gcd a n = Nat.gcd b n := by
  have ha : Nat.gcd a n ∣ n := Nat.gcd_dvd_right _ _
  have hb : Nat.gcd b n ∣ n := Nat.gcd_dvd_right _ _
  have e1 : n / (n / Nat.gcd a n) = Nat.gcd a n := Nat.div_div_self ha (by omega)
  have e2 : n / (n / Nat.gcd b n) = Nat.gcd b n := Nat.div_div_self hb (by omega)
  rw [← e1, ← e2, ordType, ordType] at *
  rw [h]

/-- An exponent whose two-adic gcd is `2 ^ j` with `j < k` is `2 ^ j` times an odd
number: it is congruent to `2 ^ j` modulo `2 ^ (j+1)`. -/
theorem mod_two_pow_succ_of_gcd {k a j : ℕ} (hj : j < k) (h : Nat.gcd a (2 ^ k) = 2 ^ j) :
    a % 2 ^ (j + 1) = 2 ^ j := by
  have hdvd : 2 ^ j ∣ a := h ▸ Nat.gcd_dvd_left a (2 ^ k)
  have hnot : ¬ (2 ^ (j + 1) ∣ a) := by
    intro hc
    have hd : (2 : ℕ) ^ (j + 1) ∣ Nat.gcd a (2 ^ k) :=
      Nat.dvd_gcd hc (pow_dvd_pow 2 (by omega))
    rw [h] at hd
    have hle := Nat.le_of_dvd (pow_pos (by norm_num) j) hd
    have hlt : (2 : ℕ) ^ j < 2 ^ (j + 1) := by
      exact Nat.pow_lt_pow_right (by norm_num) (by omega)
    omega
  obtain ⟨t, rfl⟩ := hdvd
  have ht : t % 2 = 1 := by
    rcases Nat.even_or_odd t with he | ho
    · obtain ⟨u, rfl⟩ := he
      exact absurd ⟨u, by rw [pow_succ]; ring⟩ hnot
    · exact Nat.odd_iff.1 ho
  rw [pow_succ, Nat.mul_mod_mul_left, ht, mul_one]

/-- Two exponents with the same two-adic gcd are congruent modulo twice that gcd,
hence modulo any smaller power of two. -/
theorem congr_of_gcd_eq {k a b j v : ℕ} (hj : j ≤ k) (hv : v ≤ j)
    (ha : a < 2 ^ k) (hb : b < 2 ^ k)
    (hga : Nat.gcd a (2 ^ k) = 2 ^ j) (hgb : Nat.gcd b (2 ^ k) = 2 ^ j) :
    a % 2 ^ (v + 1) = b % 2 ^ (v + 1) := by
  rcases eq_or_lt_of_le hj with hjk | hjk
  · have ha0 : a = 0 :=
      Nat.eq_zero_of_dvd_of_lt (hga ▸ Nat.gcd_dvd_left a (2 ^ k)) (by rw [hjk]; exact ha)
    have hb0 : b = 0 :=
      Nat.eq_zero_of_dvd_of_lt (hgb ▸ Nat.gcd_dvd_left b (2 ^ k)) (by rw [hjk]; exact hb)
    rw [ha0, hb0]
  · have hdvd : (2 : ℕ) ^ (v + 1) ∣ 2 ^ (j + 1) := pow_dvd_pow 2 (by omega)
    have e1 : a % 2 ^ (v + 1) = (a % 2 ^ (j + 1)) % 2 ^ (v + 1) :=
      (Nat.mod_mod_of_dvd a hdvd).symm
    have e2 : b % 2 ^ (v + 1) = (b % 2 ^ (j + 1)) % 2 ^ (v + 1) :=
      (Nat.mod_mod_of_dvd b hdvd).symm
    rw [e1, e2, mod_two_pow_succ_of_gcd hjk hga, mod_two_pow_succ_of_gcd hjk hgb]

/-! ## 2. Counting a residue class -/

theorem card_mod_class {d m r : ℕ} (hd : 0 < d) (hr : r < d) :
    #{s ∈ range (d * m) | s % d = r} = m := by
  classical
  have himg : {s ∈ range (d * m) | s % d = r} = (range m).image (fun i => d * i + r) := by
    ext s
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_image]
    constructor
    · rintro ⟨hs, hmod⟩
      refine ⟨s / d, Nat.div_lt_of_lt_mul hs, ?_⟩
      rw [← hmod]
      exact Nat.div_add_mod s d
    · rintro ⟨i, hi, rfl⟩
      refine ⟨?_, ?_⟩
      · calc d * i + r < d * i + d := by omega
          _ = d * (i + 1) := by ring
          _ ≤ d * m := Nat.mul_le_mul_left d (by omega)
      · rw [Nat.mul_add_mod, Nat.mod_eq_of_lt hr]
  rw [himg, Finset.card_image_of_injective _
    (fun a b hab => Nat.eq_of_mul_eq_mul_left hd (by omega)), Finset.card_range]

/-! ## 3. The class-wise upper bound at `q = 2` -/

theorem uEnt_class_le_two_pow {k : ℕ} (x : ℕ × ℕ) (hx : x ∈ box (2 ^ k)) :
    uEnt {y ∈ box (2 ^ k) | ordPair (2 ^ k) y = ordPair (2 ^ k) x} (prodRes (2 ^ k))
      ≤ maxTot (2 ^ k) x := by
  classical
  have h2k : 0 < 2 ^ k := pow_pos (by norm_num) k
  have hmaxpos :
      0 < max (Nat.totient (ordType (2 ^ k) x.1)) (Nat.totient (ordType (2 ^ k) x.2)) := by
    have h1 : 0 < Nat.totient (ordType (2 ^ k) x.1) :=
      Nat.totient_pos.2 (ordType_pos h2k x.1)
    omega
  have hmaxnn : (0 : ℝ) ≤ maxTot (2 ^ k) x := by
    rw [maxTot, ← Nat.cast_max]
    exact Real.logb_nonneg (by norm_num) (by exact_mod_cast hmaxpos)
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · have hcard : #{y ∈ box (2 ^ 0) | ordPair (2 ^ 0) y = ordPair (2 ^ 0) x} ≤ 1 := by
      refine le_trans (Finset.card_le_card (Finset.filter_subset _ _)) ?_
      rw [card_box]
      norm_num
    rw [uEnt_of_card_le_one hcard]
    exact hmaxnn
  obtain ⟨hx1, hx2⟩ := mem_box_iff.1 hx
  obtain ⟨j1, hj1, hg1⟩ := gcd_two_pow_eq k x.1
  obtain ⟨j2, hj2, hg2⟩ := gcd_two_pow_eq k x.2
  set w := min (min j1 j2) (k - 1) with hwdef
  have hw1 : w ≤ j1 := by omega
  have hw2 : w ≤ j2 := by omega
  have hwk : w + 1 ≤ k := by omega
  have hdvd : (2 : ℕ) ^ (w + 1) ∣ 2 ^ k := pow_dvd_pow 2 hwk
  set r := prodRes (2 ^ k) x % 2 ^ (w + 1) with hr
  have hrlt : r < 2 ^ (w + 1) := Nat.mod_lt _ (pow_pos (by norm_num) _)
  have hcardS : #{s ∈ range (2 ^ k) | s % 2 ^ (w + 1) = r} = 2 ^ (k - w - 1) := by
    have he : (2 : ℕ) ^ k = 2 ^ (w + 1) * 2 ^ (k - w - 1) := by
      rw [← pow_add]; congr 1; omega
    calc #{s ∈ range (2 ^ k) | s % 2 ^ (w + 1) = r}
        = #{s ∈ range (2 ^ (w + 1) * 2 ^ (k - w - 1)) | s % 2 ^ (w + 1) = r} := by rw [← he]
      _ = 2 ^ (k - w - 1) := card_mod_class (pow_pos (by norm_num) _) hrlt
  have hmaps : ∀ y ∈ {y ∈ box (2 ^ k) | ordPair (2 ^ k) y = ordPair (2 ^ k) x},
      prodRes (2 ^ k) y ∈ {s ∈ range (2 ^ k) | s % 2 ^ (w + 1) = r} := by
    intro y hy
    simp only [Finset.mem_filter, mem_box_iff] at hy
    obtain ⟨⟨hy1, hy2⟩, hord⟩ := hy
    have ho1 : ordType (2 ^ k) y.1 = ordType (2 ^ k) x.1 := congrArg Prod.fst hord
    have ho2 : ordType (2 ^ k) y.2 = ordType (2 ^ k) x.2 := congrArg Prod.snd hord
    have hgy1 : Nat.gcd y.1 (2 ^ k) = 2 ^ j1 := by
      rw [gcd_eq_of_ordType_eq h2k ho1]; exact hg1
    have hgy2 : Nat.gcd y.2 (2 ^ k) = 2 ^ j2 := by
      rw [gcd_eq_of_ordType_eq h2k ho2]; exact hg2
    have hc1 : y.1 % 2 ^ (w + 1) = x.1 % 2 ^ (w + 1) :=
      congr_of_gcd_eq hj1 hw1 hy1 hx1 hgy1 hg1
    have hc2 : y.2 % 2 ^ (w + 1) = x.2 % 2 ^ (w + 1) :=
      congr_of_gcd_eq hj2 hw2 hy2 hx2 hgy2 hg2
    refine Finset.mem_filter.2 ⟨Finset.mem_range.2 (Nat.mod_lt _ h2k), ?_⟩
    rw [hr]
    simp only [prodRes]
    rw [Nat.mod_mod_of_dvd _ hdvd, Nat.mod_mod_of_dvd _ hdvd, Nat.add_mod y.1, Nat.add_mod x.1,
      hc1, hc2]
  have hSpos : 0 < #{s ∈ range (2 ^ k) | s % 2 ^ (w + 1) = r} := by
    rw [hcardS]; exact pow_pos (by norm_num) _
  have hkey := uEnt_le_logb_card_of_mapsTo hSpos hmaps
  rw [hcardS] at hkey
  refine hkey.trans ?_
  have hT1 : ordType (2 ^ k) x.1 = 2 ^ (k - j1) := ordType_two_pow hj1 hg1
  have hT2 : ordType (2 ^ k) x.2 = 2 ^ (k - j2) := ordType_two_pow hj2 hg2
  have hbound : (2 : ℕ) ^ (k - w - 1)
      ≤ max (Nat.totient (ordType (2 ^ k) x.1)) (Nat.totient (ordType (2 ^ k) x.2)) := by
    rcases le_total (min j1 j2) (k - 1) with hcase | hcase
    · rcases le_total j1 j2 with h12 | h12
      · have hpos : 0 < k - j1 := by omega
        have he : Nat.totient (ordType (2 ^ k) x.1) = 2 ^ (k - w - 1) := by
          rw [hT1, totient_two_pow hpos]; congr 1; omega
        rw [← he]
        exact le_max_left _ _
      · have hpos : 0 < k - j2 := by omega
        have he : Nat.totient (ordType (2 ^ k) x.2) = 2 ^ (k - w - 1) := by
          rw [hT2, totient_two_pow hpos]; congr 1; omega
        rw [← he]
        exact le_max_right _ _
    · have hzero : k - w - 1 = 0 := by omega
      rw [hzero, pow_zero]
      omega
  rw [maxTot, ← Nat.cast_max]
  refine Real.logb_le_logb_of_le (by norm_num) ?_ ?_
  · exact_mod_cast pow_pos (show 0 < 2 by norm_num) (k - w - 1)
  · exact_mod_cast hbound

/-! ## 4. The exact two-primary law -/

/-- The lower companion of `Ipair_le_Wsum`: a class-wise *upper* bound for the
residue entropy turns the universal envelope into a lower bound. -/
theorem Ipair_ge_Wsum {n : ℕ} (hn : 0 < n)
    (h : ∀ x ∈ box n,
      uEnt {y ∈ box n | ordPair n y = ordPair n x} (prodRes n) ≤ maxTot n x) :
    Real.logb 2 n - Wsum n / ((n : ℝ) ^ 2) ≤ Ipair n := by
  have hkey := Ipair_ge_avg hn
    (fun t : ℕ × ℕ => Real.logb 2 (max (Nat.totient t.1) (Nat.totient t.2) : ℝ)) h
  exact hkey

/-- **The exact two-primary law.**  For every `k`,
`Ipair (2 ^ k) = (4/3) (1 - 4^{-k})`.

Both halves of the fibre sandwich are tight at `q = 2`: on a type class of
`box (2^k)` the product residue ranges over exactly one coset of `2^{v+1}ℤ`, whose
size is the larger of the two type-class sizes. -/
theorem Ipair_two_pow_eq (k : ℕ) : Ipair (2 ^ k) = 4 / 3 * (1 - 1 / 4 ^ k) := by
  have hn : 0 < 2 ^ k := pow_pos (by norm_num) k
  have hcast : ((2 ^ k : ℕ) : ℝ) = (2 : ℝ) ^ k := by push_cast; ring
  have h4 : (0 : ℝ) < 4 ^ k := by positivity
  have hpow : (2 : ℝ) ^ (2 * k) = 4 ^ k := by
    rw [pow_mul]; norm_num
  -- the closed form of the class average at `q = 2`
  have hW : Wsum (2 ^ k) = (k : ℝ) * 4 ^ k - 4 / 3 * (4 ^ k - 1) := by
    have h := Wsum_prime_pow_closed Nat.prime_two k
    rw [show ((2 : ℕ) : ℝ) = 2 by norm_num,
      show Real.logb 2 (2 : ℝ) = 1 by simp,
      show (2 : ℝ) - 1 = 1 by norm_num, Real.logb_one, hpow] at h
    nlinarith [h]
  -- the envelope evaluates to the claimed constant
  have hval : Real.logb 2 ((2 ^ k : ℕ) : ℝ) - Wsum (2 ^ k) / (((2 ^ k : ℕ) : ℝ)) ^ 2
      = 4 / 3 * (1 - 1 / 4 ^ k) := by
    rw [hcast, hW, Real.logb_pow, show Real.logb 2 (2 : ℝ) = 1 by simp,
      show ((2 : ℝ) ^ k) ^ 2 = 4 ^ k by rw [← pow_mul, pow_mul']; norm_num]
    field_simp
    ring
  have hle : Ipair (2 ^ k) ≤ 4 / 3 * (1 - 1 / 4 ^ k) := by
    have := Ipair_le_Wsum hn
    rwa [hval] at this
  have hge : 4 / 3 * (1 - 1 / 4 ^ k) ≤ Ipair (2 ^ k) := by
    have := Ipair_ge_Wsum hn (fun x hx => uEnt_class_le_two_pow x hx)
    rwa [hval] at this
  linarith

end CyclicTypeChannel