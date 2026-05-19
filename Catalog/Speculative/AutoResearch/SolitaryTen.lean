/-
# 10 is a Solitary Number

This file proves that 10 is solitary: the only positive integer with abundancy
index σ(n)/n = 9/5 is n = 10.
-/

import Mathlib

/-- Sum of positive divisors function. -/
def sigma (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d

/-- Abundancy index as a rational number. -/
noncomputable def abund (n : ℕ) : ℚ := (sigma n : ℚ) / n

/-- Two positive integers are friendly if they have the same abundancy index. -/
def Friendly (m n : ℕ) : Prop := abund m = abund n

/-- A positive integer is solitary if no other positive integer shares its abundancy. -/
def Solitary (n : ℕ) : Prop := ∀ ⦃m : ℕ⦄, 0 < m → m ≠ n → abund m ≠ abund n

/-! ## Basic computations -/

theorem sigma_ten : sigma 10 = 18 := by native_decide
theorem sigma_one : sigma 1 = 1 := by native_decide
theorem sigma_two : sigma 2 = 3 := by native_decide
theorem sigma_five : sigma 5 = 6 := by native_decide

theorem not_coprime_ten_sigma : ¬ Nat.Coprime 10 (sigma 10) := by native_decide

/-! ## Key lemmas about sigma -/

theorem sigma_mul_coprime {a b : ℕ} (hab : Nat.Coprime a b) :
    sigma (a * b) = sigma a * sigma b := by
  unfold sigma; grind +suggestions

theorem sigma_ge_self {n : ℕ} (hn : 0 < n) : n ≤ sigma n := by
  exact Finset.single_le_sum (fun x _ => Nat.zero_le x) (by simp [Nat.mem_divisors, hn.ne'])

theorem sigma_eq_self_iff {n : ℕ} (hn : 0 < n) : sigma n = n ↔ n = 1 := by
  rcases n with (_ | _ | n) <;> simp_all +arith +decide [sigma]
  rw [Nat.sum_divisors_eq_sum_properDivisors_add_self]
  exact ne_of_gt (Nat.lt_add_of_pos_left <| Finset.sum_pos
    (fun x hx => Nat.pos_of_mem_properDivisors hx)
    ⟨1, Nat.mem_properDivisors.mpr ⟨by norm_num, by linarith⟩⟩)

theorem five_dvd_of_eq {m : ℕ} (hm : 0 < m) (h : 5 * sigma m = 9 * m) : 5 ∣ m := by omega

theorem sigma_ratio_lt_one_impossible {a b n : ℕ} (hn : 0 < n) (hab : b < a)
    (h : a * sigma n = b * n) : False := by
  have hge := sigma_ge_self hn; nlinarith

/-
If a * σ(n) = b * n and σ(c)/c ≥ b/a (i.e., a*σ(c) ≥ b*c) and c | n, then
    the equation forces constraints on n/c.
-/
theorem sigma_product_lower_bound {n c : ℕ} (hn : 0 < n) (hc : c ∣ n)
    (hcpos : 0 < c) :
    sigma n ≥ sigma c * (n / c) := by
  unfold sigma;
  -- Since $c$ divides $n$, we can write $n = c * k$ for some integer $k$.
  obtain ⟨k, rfl⟩ : ∃ k, n = c * k := hc;
  -- Since $c$ divides $n$, we can write $n = c * k$ for some integer $k$. The divisors of $c * k$ include all divisors of $c$ multiplied by $k$.
  have h_divisors : (c * k).divisors ⊇ Finset.image (fun d => d * k) c.divisors := by
    exact Finset.image_subset_iff.mpr fun x hx => Nat.mem_divisors.mpr ⟨ mul_dvd_mul ( Nat.dvd_of_mem_divisors hx ) ( dvd_refl k ), by aesop ⟩;
  refine' le_trans _ ( Finset.sum_le_sum_of_subset h_divisors );
  rw [ Finset.sum_image ] <;> norm_num [ mul_comm, hcpos.ne' ];
  · rw [ Finset.mul_sum _ _ _ ];
  · exact fun x hx y hy hxy => mul_left_cancel₀ ( by aesop_cat : k ≠ 0 ) hxy

/-! ## The descent lemma for 2σ(j) = 3j -/

theorem two_sigma_eq_three_mul {j : ℕ} (hj : 0 < j) (h : 2 * sigma j = 3 * j) : j = 2 := by
  -- Since $2 \sigma(j) = 3 j$, we have that $j$ must be even. Let $j = 2^c l$ where $l$ is odd and $c \geq 1$.
  obtain ⟨c, l, rfl, hl_odd, hc⟩ : ∃ c l, j = 2 ^ c * l ∧ Odd l ∧ 1 ≤ c := by
    -- Since $2 \sigma(j) = 3 j$, we have that $j$ must be even. Let $c$ be such that $2^c \mid j$ and $2^{c+1} \nmid j$.
    obtain ⟨c, hc⟩ : ∃ c, 2 ^ c ∣ j ∧ ¬2 ^ (c + 1) ∣ j := by
      exact ⟨ Nat.factorization j 2, Nat.ordProj_dvd _ _, Nat.pow_succ_factorization_not_dvd hj.ne' ( by decide ) ⟩;
    rcases hc.1 with ⟨ l, rfl ⟩ ; use c, l ; simp_all +decide [ parity_simps ];
    rcases c with ( _ | c ) <;> simp_all +decide [ pow_succ, mul_dvd_mul_iff_left ];
    · grind;
    · exact Nat.odd_iff.mpr hc;
  -- If $c \geq 2$, then $(2^{c+1}-1)\sigma(l) = 3 \cdot 2^{c-1} l$.
  have h_eq : (2 ^ (c + 1) - 1) * sigma l = 3 * 2 ^ (c - 1) * l := by
    have h_sigma_mul : sigma (2 ^ c * l) = sigma (2 ^ c) * sigma l := by
      exact sigma_mul_coprime <| Nat.Coprime.pow_left _ <| by obtain ⟨ k, rfl ⟩ := hl_odd; norm_num;
    -- Since $\sigma(2^c) = 2^{c+1} - 1$, we can substitute this into the equation.
    have h_sigma_2c : sigma (2 ^ c) = 2 ^ (c + 1) - 1 := by
      simp +decide [ sigma, Nat.geomSum_eq ];
    cases c <;> simp_all +decide [ pow_succ' ] ; linarith;
  -- Since $2^{c+1}-1 > 3 \cdot 2^{c-1}$ for $c \geq 2$, we have a contradiction.
  by_cases hc_ge_2 : c ≥ 2;
  · have h_contradiction : 2 ^ (c + 1) - 1 > 3 * 2 ^ (c - 1) := by
      rcases c with ( _ | _ | c ) <;> simp_all +decide [ pow_succ' ];
      exact lt_tsub_iff_left.mpr ( by linarith [ Nat.pow_le_pow_right two_pos ( show c ≥ 0 by norm_num ) ] );
    exact False.elim <| sigma_ratio_lt_one_impossible ( show 0 < l from Nat.pos_of_ne_zero <| by aesop_cat ) ( show 3 * 2 ^ ( c - 1 ) < 2 ^ ( c + 1 ) - 1 from h_contradiction ) <| by nlinarith [ show 0 < 2 ^ ( c - 1 ) by positivity ] ;
  · interval_cases c ; simp_all +decide;
    exact?

/-! ## Coprime-to-5 case -/

theorem ten_from_coprime_five {m : ℕ} (hm : 0 < m) (h5 : 5 ∣ m)
    (hcop : Nat.Coprime (m / 5) 5) (h : 5 * sigma m = 9 * m) : m = 10 := by
  -- Since $m$ is a multiple of $5$, we can write $m = 5k$ for some integer $k$.
  obtain ⟨k, hk⟩ : ∃ k, m = 5 * k := h5;
  -- Since $k$ is coprime to $5$, we have $\sigma(5k) = \sigma(5)\sigma(k) = 6\sigma(k)$.
  have h_sigma : sigma (5 * k) = 6 * sigma k := by
    convert sigma_mul_coprime _ using 1;
    exact hcop.symm.coprime_dvd_right ( by simp +decide [ hk ] );
  simp_all +arith +decide [ Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
  exact two_sigma_eq_three_mul hm ( by linarith ) ▸ by ring;

/-! ## The 25 | m case -/

/-
If 50 | m and 5σ(m) = 9m, then False. (Uses σ(50)*q ≤ σ(50q).)
-/
theorem no_solution_50_dvd {m : ℕ} (hm : 0 < m) (h50 : 50 ∣ m)
    (h : 5 * sigma m = 9 * m) : False := by
  -- Since 50|m, write m = 50q. For every divisor d of 50 (which are 1,2,5,10,25,50 with sum 93), d*q is a divisor of m. So σ(m) ≥ 93q = 93*(m/50).
  have h_sigma_ge : sigma m ≥ 93 * (m / 50) := by
    have h_sigma_ge : sigma m ≥ ∑ d ∈ Nat.divisors 50, d * (m / 50) := by
      have h_divisors : Nat.divisors m ⊇ Finset.image (fun d => d * (m / 50)) (Nat.divisors 50) := by
        intro x;
        norm_num +zetaDelta at *;
        rintro y hy rfl; exact ⟨ by exact Nat.dvd_trans ( mul_dvd_mul hy dvd_rfl ) ( by rw [ Nat.mul_div_cancel' h50 ] ), hm.ne' ⟩ ;
      exact le_trans ( by rw [ Finset.sum_image ( by intros a ha b hb hab; nlinarith [ Nat.div_mul_cancel h50 ] ) ] ) ( Finset.sum_le_sum_of_subset h_divisors );
    exact h_sigma_ge.trans' ( by rw [ ← Finset.sum_mul _ _ _ ] ; rfl );
  omega

/-
σ(5^b) is even when b is odd.
-/
theorem sigma_pow5_even_of_odd {b : ℕ} (hb : Odd b) : 2 ∣ sigma (5 ^ b) := by
  unfold sigma;
  norm_num [ Nat.geomSum_eq, ← even_iff_two_dvd, parity_simps ];
  obtain ⟨ k, rfl ⟩ := hb; norm_num [ Nat.pow_succ', Nat.pow_mul ] ; ring_nf ;
  exact even_iff_two_dvd.mpr ( Nat.dvd_div_of_mul_dvd ( Nat.dvd_of_mod_eq_zero ( by rw [ ← Nat.mod_add_div ( 5 ^ ( k * 2 ) * 25 ) 8 ] ; norm_num [ Nat.pow_mul', Nat.mul_mod, Nat.pow_mod ] ) ) )

/-- For b ≥ 2 even, gcd(r,5)=1, r odd: σ(5^b)σ(r) = 9·5^(b-1)·r → False.
    Key: at the first descent step, the denominator is even, but r (hence all factors) are odd. -/
theorem no_solution_odd_b_even {b r : ℕ} (hb : 2 ≤ b) (hbeven : Even b)
    (hr : 0 < r) (hrodd : ¬ 2 ∣ r) (hrcop : Nat.Coprime r 5)
    (h : sigma (5 ^ b) * sigma r = 9 * 5 ^ (b - 1) * r) : False := by
  sorry

/-
If 25 | m but 2 ∤ m (m odd) and 5σ(m) = 9m, then False.
-/
theorem no_solution_odd_25_dvd {m : ℕ} (hm : 0 < m) (h25 : 25 ∣ m) (hodd : ¬ 2 ∣ m)
    (h : 5 * sigma m = 9 * m) : False := by
  -- Write m = 5^b * r with b = v₅(m) ≥ 2 and gcd(r, 5) = 1, r odd.
  obtain ⟨b, r, hb, hr, hrcop⟩ : ∃ b r, 2 ≤ b ∧ 5 ^ b ∣ m ∧ ¬5^(b + 1) ∣ m ∧ m = 5 ^ b * r ∧ Nat.Coprime r 5 ∧ ¬2 ∣ r := by
    use Nat.factorization m 5, m / 5 ^ Nat.factorization m 5;
    refine' ⟨ Nat.le_trans _ ( Nat.factorization_le_iff_dvd ( by positivity ) ( by positivity ) |>.2 h25 5 ), Nat.ordProj_dvd _ _, Nat.pow_succ_factorization_not_dvd hm.ne' ( by decide ), Eq.symm ( Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ), _, _ ⟩;
    · native_decide;
    · exact Nat.Coprime.symm ( Nat.Prime.coprime_iff_not_dvd ( by decide ) |>.2 <| Nat.not_dvd_ordCompl ( by decide ) <| by aesop );
    · exact fun h => hodd <| dvd_trans h <| Nat.div_dvd_of_dvd <| Nat.ordProj_dvd _ _;
  -- The equation becomes σ(5^b) * σ(r) = 9 * 5^(b-1) * r.
  have h_eq : sigma (5 ^ b) * sigma r = 9 * 5 ^ (b - 1) * r := by
    -- Using the multiplicative property of σ, we have σ(m) = σ(5^b) * σ(r).
    have h_sigma_mul : sigma m = sigma (5 ^ b) * sigma r := by
      rw [ hrcop.2.1, sigma_mul_coprime ];
      exact Nat.Coprime.pow_left _ ( Nat.Coprime.symm <| hrcop.2.2.1.coprime_dvd_left <| by aesop );
    cases b <;> simp_all +decide [ pow_succ' ] ; linarith;
  rcases Nat.even_or_odd' b with ⟨ k, rfl | rfl ⟩;
  · exact no_solution_odd_b_even ( show 2 ≤ 2 * k from hb ) ( by norm_num ) ( Nat.pos_of_ne_zero ( by aesop_cat ) ) ( by aesop_cat ) ( by aesop_cat ) h_eq;
  · -- For b odd (b ≥ 3): σ(5^b) is even (by sigma_pow5_even_of_odd). The equation σ(5^b)*σ(r) = 9*5^(b-1)*r has LHS even (even * anything). But RHS = 9*5^(b-1)*r is odd (all factors odd). Contradiction.
    have h_even : 2 ∣ sigma (5 ^ (2 * k + 1)) := by
      exact sigma_pow5_even_of_odd ( by simp +decide [ parity_simps ] );
    replace h_eq := congr_arg Even h_eq ; simp_all +decide [ ← even_iff_two_dvd, parity_simps ];
    exact absurd h_eq ( by simpa using hodd )

theorem no_solution_25_dvd {m : ℕ} (hm : 0 < m) (h25 : 25 ∣ m)
    (h : 5 * sigma m = 9 * m) : False := by
  by_cases heven : 2 ∣ m
  · have h50 : 50 ∣ m := by
      obtain ⟨k, rfl⟩ := h25
      obtain ⟨l, hl⟩ := heven
      refine ⟨k / 2, ?_⟩
      omega
    exact no_solution_50_dvd hm h50 h
  · exact no_solution_odd_25_dvd hm h25 heven h

/-! ## Main theorem -/

theorem ten_abundancy_unique {m : ℕ} (hm : 0 < m) (h : 5 * sigma m = 9 * m) : m = 10 := by
  have h5 := five_dvd_of_eq hm h
  obtain ⟨k, rfl⟩ := h5
  by_cases hk5 : 5 ∣ k
  · obtain ⟨l, rfl⟩ := hk5
    exact absurd h (fun heq => no_solution_25_dvd (by positivity) ⟨l, by ring⟩ heq)
  · exact ten_from_coprime_five (by positivity) ⟨k, rfl⟩
      (by rw [Nat.mul_div_cancel_left _ (by norm_num : (0:ℕ) < 5)]
          rw [Nat.coprime_comm]
          exact (Nat.Prime.coprime_iff_not_dvd (by norm_num)).mpr hk5) h

/-! ## Derived results -/

theorem abund_ten : abund 10 = (9 : ℚ) / 5 := by
  unfold abund; rw [sigma_ten]; norm_num

theorem solitary_ten : Solitary 10 := by
  intro m hm hne habund
  apply hne
  apply ten_abundancy_unique hm
  unfold abund at habund
  have h18 : sigma 10 = 18 := sigma_ten
  rw [h18] at habund
  push_cast at habund
  have hmq : (m : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  rw [div_eq_div_iff hmq (by norm_num : (10:ℚ) ≠ 0)] at habund
  have h1 : (sigma m : ℤ) * 10 = 18 * (m : ℤ) := by exact_mod_cast habund
  have h2 : sigma m * 10 = 18 * m := by exact_mod_cast h1
  omega

theorem friendly_with_ten_iff {m : ℕ} (hm : 0 < m) :
    Friendly m 10 ↔ m = 10 := by
  constructor
  · intro hf; by_contra hne; exact solitary_ten hm hne hf
  · intro h; subst h; rfl