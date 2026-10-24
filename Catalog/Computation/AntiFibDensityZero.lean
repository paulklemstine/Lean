module

public import Catalog.Computation.AntiFibSumTwoSquares
public import Catalog.Computation.PrimeReciprocalsInAP

/-!
# The sums of two anti-Fibonacci numbers have natural density zero

Building on the reduction `IsAntiFibSum m ↔ 8m - 14 is a sum of two squares`, we run a
Chinese-remainder sieve over primes `p ≡ 3 (mod 4)`:

* `LocOK p m` : the local condition `p ∣ 4m-7 → p² ∣ 4m-7`, necessary for representability;
* for a finite set `S` of odd primes, `Good S m := ∀ p ∈ S, LocOK p m` is periodic modulo
  `sieveModulus S = ∏ p², ` and has exactly `sieveCount S = ∏ (p² - p + 1)` solutions per
  period (`card_good_period`);
* hence `#{m < N : IsAntiFibSum m} ≤ (N / ∏ p² + 1) · ∏ (p² - p + 1)` (`card_rep_le`);
* `∏ (1 - (p-1)/p²) ≤ 1 / (1 + ½ ∑ 1/p)` (`sieveRatio_le`), and `∑_{p ≡ 3 (4)} 1/p = ∞`
  (`PrimeRecipAP.exists_finset_three_mod_four_sum_gt`).

Main theorem: `AntiFib.tendsto_card_rep_div_zero`.
-/

@[expose] public section

open Finset Filter Topology

namespace AntiFib

/-- The local condition at `p`: if `p ∣ 4m - 7` then `p² ∣ 4m - 7` (in `ℤ`). -/
def LocOK (p m : ℕ) : Prop := (p : ℤ) ∣ 4 * (m : ℤ) - 7 → (p : ℤ) ^ 2 ∣ 4 * (m : ℤ) - 7

/-- The sieve condition for a finite set of primes. -/
def Good (S : Finset ℕ) (m : ℕ) : Prop := ∀ p ∈ S, LocOK p m

/-- The sieve modulus `∏_{p ∈ S} p²`. -/
def sieveModulus (S : Finset ℕ) : ℕ := ∏ p ∈ S, p ^ 2

/-- The number of sieve survivors per period, `∏_{p ∈ S} (p² - p + 1)`. -/
def sieveCount (S : Finset ℕ) : ℕ := ∏ p ∈ S, (p ^ 2 - p + 1)

/-- Representable integers satisfy every local condition at primes `≡ 3 (mod 4)`. -/
theorem locOK_of_isAntiFibSum {p m : ℕ} (hp : p.Prime) (hp4 : p % 4 = 3)
    (h : IsAntiFibSum m) : LocOK p m := by
  have hm := two_le_of_isAntiFibSum h
  have hcast : (4 * (m : ℤ) - 7) = ((4 * m - 7 : ℕ) : ℤ) := by omega
  intro h1
  rw [hcast] at h1 ⊢
  by_contra h2
  exact not_isAntiFibSum_of_exact_dvd hp hp4 (by exact_mod_cast h1) (by exact_mod_cast h2) h

theorem good_of_isAntiFibSum {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime ∧ p % 4 = 3) {m : ℕ}
    (h : IsAntiFibSum m) : Good S m :=
  fun p hp => locOK_of_isAntiFibSum (hS p hp).1 (hS p hp).2 h

/-! ### Counting lemmas -/

/-- Splitting `[0, Q n)` into residue classes modulo `Q`. -/
lemma card_filter_range_mul (f : ℕ → Prop) [DecidablePred f] (Q n : ℕ) :
    ((range (Q * n)).filter f).card =
      ∑ r ∈ range Q, ((range n).filter (fun t => f (r + Q * t))).card := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [card_filter] at ih ⊢
    simp only [card_filter] at ih ⊢
    rw [show Q * (n + 1) = Q * n + Q by ring, sum_range_add, ih]
    simp only [sum_range_succ, sum_add_distrib]
    congr 1
    refine sum_congr rfl (fun r _ => ?_)
    rw [add_comm (Q * n) r]

/-- Counting a `Q`-periodic predicate over full periods. -/
lemma card_filter_periodic (f : ℕ → Prop) [DecidablePred f] (Q n : ℕ)
    (hf : ∀ m, f (m + Q) ↔ f m) :
    ((range (Q * n)).filter f).card = n * ((range Q).filter f).card := by
  have hper : ∀ r t, f (r + Q * t) ↔ f r := by
    intro r t
    induction t with
    | zero => simp
    | succ t ih => rw [show r + Q * (t + 1) = (r + Q * t) + Q by ring, hf, ih]
  rw [card_filter_range_mul, card_filter, mul_sum]
  refine sum_congr rfl (fun r _ => ?_)
  by_cases h : f r <;> simp [hper, h]

/-- A linear congruence `a + b t ≡ 0 (mod d)` with `b` a unit has exactly one solution
in `[0, d)`. -/
lemma card_dvd_linear (d : ℕ) (hd : 0 < d) (a b : ℤ) (hb : IsCoprime b d) :
    ((range d).filter (fun t : ℕ => (d : ℤ) ∣ a + b * (t : ℤ))).card = 1 := by
  obtain ⟨u, v, huv⟩ := hb
  have hd' : (0 : ℤ) < d := by exact_mod_cast hd
  set t0 : ℤ := (-a * u) % d with ht0
  have ht0nn : 0 ≤ t0 := Int.emod_nonneg _ hd'.ne'
  have ht0lt : t0 < d := Int.emod_lt_of_pos _ hd'
  have hsol : (d : ℤ) ∣ a + b * t0 := by
    have : t0 = -a * u - d * ((-a * u) / d) := by rw [ht0, Int.emod_def]
    rw [this]
    exact ⟨a * v - b * ((-a * u) / d), by linear_combination -a * huv⟩
  rw [card_eq_one]
  refine ⟨t0.toNat, ?_⟩
  ext t
  simp only [mem_filter, mem_range, mem_singleton]
  constructor
  · rintro ⟨htd, ht⟩
    have hdiff : (d : ℤ) ∣ b * ((t : ℤ) - t0) := by
      have := dvd_sub ht hsol
      rwa [show a + b * (t : ℤ) - (a + b * t0) = b * ((t : ℤ) - t0) by ring] at this
    have hcop : IsCoprime (d : ℤ) b := ⟨v, u, by linear_combination huv⟩
    have h2 := hcop.dvd_of_dvd_mul_left hdiff
    have h3 : (t : ℤ) - t0 = 0 := by
      apply Int.eq_zero_of_abs_lt_dvd h2
      rw [abs_lt]; constructor <;> omega
    omega
  · rintro rfl
    refine ⟨by omega, ?_⟩
    rwa [Int.toNat_of_nonneg ht0nn]

lemma locOK_add_sq_mul (p m k : ℕ) : LocOK p (m + p ^ 2 * k) ↔ LocOK p m := by
  unfold LocOK
  have e : 4 * ((m + p ^ 2 * k : ℕ) : ℤ) - 7 = (4 * (m : ℤ) - 7) + (p : ℤ) * (4 * p * k) := by
    push_cast; ring
  have e2 : (p : ℤ) * (4 * p * k) = (p : ℤ) ^ 2 * (4 * k) := by ring
  rw [e]
  constructor
  · intro h h1
    have := h (dvd_add h1 (dvd_mul_right _ _))
    have h3 := dvd_sub this (Dvd.intro _ e2.symm)
    simpa using h3
  · intro h h1
    have h1' : (p : ℤ) ∣ 4 * (m : ℤ) - 7 := by
      have := dvd_sub h1 (dvd_mul_right (p : ℤ) (4 * p * k))
      simpa using this
    rw [e2]
    exact dvd_add (h h1') (dvd_mul_right _ _)

open Classical in
/-- **Local count.** For an odd prime `p` and `Q` coprime to `p`, exactly `p² - p + 1` of the
`t ∈ [0, p²)` satisfy the local condition at `r + Q t`. -/
lemma card_locOK (p Q r : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) (hQ : Nat.Coprime p Q) :
    ((range (p ^ 2)).filter (fun t => LocOK p (r + Q * t))).card = p ^ 2 - p + 1 := by
  classical
  have hp1 : 1 ≤ p := hp.one_lt.le
  set a : ℤ := 4 * (r : ℤ) - 7
  set b : ℤ := 4 * (Q : ℤ)
  have hu : ∀ t : ℕ, 4 * ((r + Q * t : ℕ) : ℤ) - 7 = a + b * t := by
    intro t; simp only [a, b]; push_cast; ring
  have hcop4 : Nat.Coprime p 4 := by
    rw [show (4 : ℕ) = 2 ^ 2 by norm_num]
    exact Nat.Coprime.pow_right _ ((Nat.coprime_primes hp Nat.prime_two).2 hp2)
  have hcopb : IsCoprime b (p : ℤ) := by
    have : Nat.Coprime (4 * Q) p := (Nat.Coprime.mul_right hcop4 hQ).symm
    have := Nat.isCoprime_iff_coprime.2 this
    simpa [b] using this
  -- count of `p² ∣ u(t)`
  have hsq : ((range (p ^ 2)).filter (fun t : ℕ => ((p ^ 2 : ℕ) : ℤ) ∣ a + b * (t : ℤ))).card = 1 :=
    card_dvd_linear (p ^ 2) (by positivity) a b (by
      have := hcopb.pow_right (n := 2); simpa using this)
  -- count of `p ∣ u(t)`
  have hlin : ((range (p ^ 2)).filter (fun t : ℕ => (p : ℤ) ∣ a + b * (t : ℤ))).card = p := by
    rw [sq, card_filter_periodic _ p p, card_dvd_linear p hp.pos a b hcopb, mul_one]
    intro m
    have e : a + b * ((m + p : ℕ) : ℤ) = (a + b * m) + p * b := by push_cast; ring
    rw [e]
    exact (dvd_add_left (dvd_mul_right _ _))
  -- complement
  have hnot : ∀ t, ¬ LocOK p (r + Q * t) ↔
      ((p : ℤ) ∣ a + b * t ∧ ¬ ((p ^ 2 : ℕ) : ℤ) ∣ a + b * t) := by
    intro t; unfold LocOK; rw [hu]; push_cast; tauto
  have hsub : (range (p ^ 2)).filter (fun t : ℕ => ((p ^ 2 : ℕ) : ℤ) ∣ a + b * (t : ℤ)) =
      ((range (p ^ 2)).filter (fun t : ℕ => (p : ℤ) ∣ a + b * (t : ℤ))).filter
        (fun t : ℕ => ((p ^ 2 : ℕ) : ℤ) ∣ a + b * (t : ℤ)) := by
    rw [filter_filter]
    refine filter_congr (fun t _ => ?_)
    constructor
    · intro h; refine ⟨?_, h⟩
      exact dvd_trans ⟨(p : ℤ), by push_cast; ring⟩ h
    · exact fun h => h.2
  have hsplit := card_filter_add_card_filter_not
    (s := (range (p ^ 2)).filter (fun t : ℕ => (p : ℤ) ∣ a + b * (t : ℤ)))
    (fun t : ℕ => ((p ^ 2 : ℕ) : ℤ) ∣ a + b * (t : ℤ))
  rw [← hsub, hsq, hlin, filter_filter] at hsplit
  have htot := card_filter_add_card_filter_not (s := range (p ^ 2))
    (fun t => LocOK p (r + Q * t))
  rw [card_range] at htot
  have hbad : (range (p ^ 2)).filter (fun t => ¬ LocOK p (r + Q * t)) =
      (range (p ^ 2)).filter (fun t : ℕ => (p : ℤ) ∣ a + b * (t : ℤ) ∧
        ¬ ((p ^ 2 : ℕ) : ℤ) ∣ a + b * (t : ℤ)) := filter_congr (fun t _ => hnot t)
  rw [hbad] at htot
  have hpp : p ≤ p ^ 2 := by nlinarith
  omega

/-- `Good S` is periodic with period `sieveModulus S`. -/
lemma good_add_modulus (S : Finset ℕ) (m k : ℕ) :
    Good S (m + sieveModulus S * k) ↔ Good S m := by
  unfold Good
  refine forall₂_congr (fun p hp => ?_)
  obtain ⟨j, hj⟩ : p ^ 2 ∣ sieveModulus S := dvd_prod_of_mem _ hp
  rw [hj, mul_assoc]
  exact locOK_add_sq_mul p m (j * k)

lemma sieveModulus_pos (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime) : 0 < sieveModulus S :=
  prod_pos (fun p hp => by have := (hS p hp).pos; positivity)

open Classical in
/-- **One-period count (CRT sieve).** For a finite set of odd primes, exactly
`∏ (p² - p + 1)` residues modulo `∏ p²` pass every local test. -/
theorem card_good_period (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2) :
    ((range (sieveModulus S)).filter (Good S)).card = sieveCount S := by
  induction S using Finset.induction_on with
  | empty =>
    simp only [sieveModulus, sieveCount, prod_empty]
    rw [filter_true_of_mem (fun m _ => by simp [Good])]
    simp
  | insert p S hpS ih =>
    have hS' : ∀ q ∈ S, q.Prime ∧ q ≠ 2 := fun q hq => hS q (mem_insert_of_mem hq)
    have hp := hS p (mem_insert_self p S)
    have hmod : sieveModulus (insert p S) = sieveModulus S * p ^ 2 := by
      simp [sieveModulus, prod_insert hpS, mul_comm]
    have hcnt : sieveCount (insert p S) = (p ^ 2 - p + 1) * sieveCount S := by
      simp [sieveCount, prod_insert hpS]
    have hcop : Nat.Coprime p (sieveModulus S) := by
      apply Nat.Coprime.prod_right
      intro q hq
      apply Nat.Coprime.pow_right
      rw [Nat.coprime_primes hp.1 (hS' q hq).1]
      rintro rfl; exact hpS hq
    rw [hmod, hcnt, card_filter_range_mul, ← ih hS', card_filter, mul_sum]
    refine sum_congr rfl (fun r _ => ?_)
    have hg : ∀ t, Good (insert p S) (r + sieveModulus S * t) ↔
        LocOK p (r + sieveModulus S * t) ∧ Good S r := by
      intro t
      rw [← good_add_modulus S r t]
      simp [Good]
    simp only [hg]
    by_cases hr : Good S r
    · simp only [hr, and_true, if_true, mul_one]
      exact card_locOK p (sieveModulus S) r hp.1 hp.2 hcop
    · simp [hr]

open Classical in
/-- **Sieve upper bound.** For every finite set `S` of primes `≡ 3 (mod 4)` and every `N`,
`#{m < N : m is a sum of two anti-Fibonacci numbers} ≤ (N / ∏ p² + 1) · ∏ (p² - p + 1)`. -/
theorem card_rep_le (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p % 4 = 3) (N : ℕ) :
    ((range N).filter IsAntiFibSum).card ≤ (N / sieveModulus S + 1) * sieveCount S := by
  have hS2 : ∀ p ∈ S, p.Prime ∧ p ≠ 2 := fun p hp => ⟨(hS p hp).1, by
    have := (hS p hp).2; omega⟩
  have hQ := sieveModulus_pos S (fun p hp => (hS p hp).1)
  set Q := sieveModulus S
  have hN : N ≤ Q * (N / Q + 1) := by
    have := Nat.lt_mul_div_succ N hQ; omega
  calc ((range N).filter IsAntiFibSum).card
      ≤ ((range (Q * (N / Q + 1))).filter (Good S)).card := by
        apply card_le_card
        intro m hm
        simp only [mem_filter, mem_range] at hm ⊢
        exact ⟨by omega, good_of_isAntiFibSum hS hm.2⟩
    _ = (N / Q + 1) * sieveCount S := by
        rw [card_filter_periodic _ Q _ (fun m => by
          have := good_add_modulus S m 1; rwa [mul_one] at this), card_good_period S hS2]

/-- **Euler-product estimate.** `∏ (p² - p + 1) / ∏ p² ≤ 1 / (1 + ½ ∑ 1/p)` whenever all
elements of `S` are `≥ 2`. -/
theorem sieveRatio_le (S : Finset ℕ) (hS : ∀ p ∈ S, 2 ≤ p) :
    (sieveCount S : ℝ) / sieveModulus S ≤ 1 / (1 + (1 / 2) * ∑ p ∈ S, (1 : ℝ) / p) := by
  induction S using Finset.induction_on with
  | empty => simp [sieveCount, sieveModulus]
  | insert p S hpS ih =>
    have ih := ih (fun q hq => hS q (mem_insert_of_mem hq))
    have hp : 2 ≤ p := hS p (mem_insert_self p S)
    have hpR : (2 : ℝ) ≤ p := by exact_mod_cast hp
    have hQpos : (0 : ℝ) < sieveModulus S :=
      by exact_mod_cast prod_pos (fun q hq => by
        have := hS q (mem_insert_of_mem hq); positivity)
    have hcnt : (sieveCount (insert p S) : ℝ) = ((p : ℝ) ^ 2 - p + 1) * sieveCount S := by
      simp only [sieveCount, prod_insert hpS]
      push_cast [show p ≤ p ^ 2 by nlinarith]
      ring
    have hmod : (sieveModulus (insert p S) : ℝ) = (p : ℝ) ^ 2 * sieveModulus S := by
      simp [sieveModulus, prod_insert hpS]
    rw [hcnt, hmod, sum_insert hpS]
    set s := ∑ q ∈ S, (1 : ℝ) / q
    have hs : 0 ≤ s := sum_nonneg (fun q _ => by positivity)
    set R := (sieveCount S : ℝ) / sieveModulus S
    have hR : R ≤ 1 / (1 + 1 / 2 * s) := ih
    have hR0 : 0 ≤ R := by positivity
    have e : ((p : ℝ) ^ 2 - p + 1) * sieveCount S / ((p : ℝ) ^ 2 * sieveModulus S) =
        (1 - ((p : ℝ) - 1) / p ^ 2) * R := by
      simp only [R]; field_simp; ring
    rw [e]
    set y := ((p : ℝ) - 1) / p ^ 2
    set z := (1 : ℝ) / 2 * (1 / p)
    have hy1 : y ≤ 1 := by
      simp only [y]; rw [div_le_one (by positivity)]; nlinarith
    have hzy : z ≤ y := by
      simp only [y, z]
      rw [show (1 : ℝ) / 2 * (1 / p) = 1 / (2 * p) by ring,
        div_le_div_iff₀ (by positivity) (by positivity)]
      nlinarith
    have hz0 : 0 ≤ z := by positivity
    have hA : 0 < 1 + 1 / 2 * s := by positivity
    calc (1 - y) * R ≤ (1 - y) * (1 / (1 + 1 / 2 * s)) :=
          mul_le_mul_of_nonneg_left hR (by linarith)
      _ ≤ (1 - z) * (1 / (1 + 1 / 2 * s)) :=
          mul_le_mul_of_nonneg_right (by linarith) (by positivity)
      _ ≤ 1 / (1 + 1 / 2 * (1 / p + s)) := by
          rw [show 1 + 1 / 2 * (1 / (p : ℝ) + s) = (1 + 1 / 2 * s) + z by simp only [z]; ring]
          rw [mul_one_div, div_le_div_iff₀ hA (by positivity)]
          nlinarith

open Classical in
/-- **Density zero.** The proportion of integers in `[0, N)` that are sums of two
anti-Fibonacci numbers tends to `0`. -/
theorem tendsto_card_rep_div_zero :
    Tendsto (fun N : ℕ => (((range N).filter IsAntiFibSum).card : ℝ) / N) atTop (𝓝 0) := by
  rw [Metric.tendsto_atTop]
  intro ε hε
  obtain ⟨S, hS, hsum⟩ := PrimeRecipAP.exists_finset_three_mod_four_sum_gt (4 / ε)
  have hS2 : ∀ p ∈ S, 2 ≤ p := fun p hp => (hS p hp).1.two_le
  have hQ := sieveModulus_pos S (fun p hp => (hS p hp).1)
  set Q := sieveModulus S
  set c := sieveCount S
  have hratio := sieveRatio_le S hS2
  have hratio' : (c : ℝ) / Q < ε / 2 := by
    refine lt_of_le_of_lt hratio ?_
    have hpos : 0 < 1 + 1 / 2 * ∑ p ∈ S, (1 : ℝ) / p := by
      have : 0 ≤ ∑ p ∈ S, (1 : ℝ) / p := sum_nonneg (fun _ _ => by positivity)
      positivity
    rw [div_lt_div_iff₀ hpos (by norm_num)]
    have : 4 < ε * ∑ p ∈ S, (1 : ℝ) / p := by
      rwa [div_lt_iff₀ hε, mul_comm] at hsum
    nlinarith
  obtain ⟨N0, hN0⟩ := exists_nat_gt (2 * c / ε)
  refine ⟨N0 + 1, fun N hN => ?_⟩
  have hNpos : (0 : ℝ) < N := by
    have : 0 < N := by omega
    exact_mod_cast this
  have hNbig : 2 * (c : ℝ) / ε < N := by
    have : (N0 : ℝ) < N := by exact_mod_cast (by omega : N0 < N)
    linarith
  rw [Real.dist_eq, sub_zero, abs_of_nonneg (by positivity)]
  have hb := card_rep_le S hS N
  have hb' : (((range N).filter IsAntiFibSum).card : ℝ) ≤ ((N / Q : ℕ) + 1 : ℝ) * c := by
    exact_mod_cast hb
  have hdiv : ((N / Q : ℕ) : ℝ) ≤ (N : ℝ) / Q := Nat.cast_div_le
  have hQR : (0 : ℝ) < Q := by exact_mod_cast hQ
  have hcN : (c : ℝ) / N < ε / 2 := by
    rw [div_lt_iff₀ hNpos]
    rw [div_lt_iff₀ hε] at hNbig
    linarith
  calc (((range N).filter IsAntiFibSum).card : ℝ) / N
      ≤ (((N / Q : ℕ) : ℝ) + 1) * c / N := by gcongr
    _ ≤ ((N : ℝ) / Q + 1) * c / N := by gcongr
    _ = (c : ℝ) / Q + c / N := by field_simp
    _ < ε / 2 + ε / 2 := by linarith
    _ = ε := by ring

open Classical in
/-- Equivalently, almost all integers are **not** sums of two anti-Fibonacci numbers. -/
theorem tendsto_card_nonrep_div_one :
    Tendsto (fun N : ℕ => (((range N).filter (fun m => ¬ IsAntiFibSum m)).card : ℝ) / N)
      atTop (𝓝 1) := by
  have h := tendsto_card_rep_div_zero
  have h1 : Tendsto (fun N : ℕ => (1 : ℝ) - (((range N).filter IsAntiFibSum).card : ℝ) / N)
      atTop (𝓝 1) := by
    simpa using (tendsto_const_nhds (x := (1 : ℝ))).sub h
  refine h1.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with N hN
  have hsplit := card_filter_add_card_filter_not (s := range N) IsAntiFibSum
  rw [card_range] at hsplit
  have hNR : (N : ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  have : (((range N).filter (fun m => ¬ IsAntiFibSum m)).card : ℝ) =
      N - ((range N).filter IsAntiFibSum).card := by
    have := congrArg (Nat.cast (R := ℝ)) hsplit
    push_cast at this; linarith
  rw [this]; field_simp

end AntiFib