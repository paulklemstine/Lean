import Mathlib

/-!
# AKS polynomial criterion for primality

The AKS polynomial criterion states that for `n ≥ 2` and `a : ZMod n` a unit,
`n` is prime iff `(X + C a)^n = X^n + C a` in `(ZMod n)[X]`.
-/

open Polynomial Finset

namespace AKS

/-- Forward direction: if `n` is prime, then `(X + C a)^n = X^n + C a` in `(ZMod n)[X]`.
This is the "freshman's dream" combined with Fermat's little theorem. -/
theorem aks_forward {n : ℕ} (hp : n.Prime) (a : ZMod n) :
    (X + C a) ^ n = X ^ n + C a := by
  haveI : Fact n.Prime := ⟨hp⟩
  rw [add_pow_char]
  congr 1
  rw [← C_pow, ZMod.pow_card]

/-- Key binomial identity: `q * C(n,q) = n * C(n-1, q-1)`. -/
theorem mul_choose_eq {n q : ℕ} (hq1 : 1 ≤ q) (hqn : q ≤ n) :
    q * n.choose q = n * (n - 1).choose (q - 1) := by
  rcases n with _ | m
  · omega
  · rcases q with _ | j
    · omega
    · simp only [Nat.succ_sub_one]
      rw [Nat.add_one_mul_choose_eq m j]; ring

/-- Step 1: `C(n-1, q-1) ≡ 1 [MOD q]` when `q` is prime and `q ∣ n`. -/
theorem choose_pred_eq_one_mod {n q : ℕ} (hq : q.Prime) (hqn : q ∣ n) (hqn' : q ≤ n) :
    (n - 1).choose (q - 1) ≡ 1 [MOD q] := by
  rw [ ← ZMod.natCast_eq_natCast_iff ];
  haveI := Fact.mk hq; simp_all +decide [ ← ZMod.natCast_eq_zero_iff ] ;
  -- By definition of binomial coefficients, we have:
  have h_binom : (Nat.descFactorial (n - 1) (q - 1) : ZMod q) = (Nat.factorial (q - 1) : ZMod q) * (Nat.choose (n - 1) (q - 1) : ZMod q) := by
    rw_mod_cast [ Nat.descFactorial_eq_factorial_mul_choose ];
  -- On the other hand, we can compute the product $\prod_{i=0}^{q-2} (n-1-i)$ directly.
  have h_prod : (Nat.descFactorial (n - 1) (q - 1) : ZMod q) = (-1 : ZMod q) ^ (q - 1) * (Nat.factorial (q - 1) : ZMod q) := by
    -- We can rewrite the product as $\prod_{i=0}^{q-2} (n-1-i) = \prod_{i=0}^{q-2} (-1-i)$.
    have h_prod_rewrite : (Nat.descFactorial (n - 1) (q - 1) : ZMod q) = ∏ i ∈ Finset.range (q - 1), (-1 - i : ZMod q) := by
      rw [ Nat.descFactorial_eq_prod_range ];
      rw [ Nat.cast_prod ];
      refine' Finset.prod_congr rfl fun i hi => _;
      rw [ Nat.cast_sub <| Nat.le_sub_one_of_lt <| by linarith [ Finset.mem_range.mp hi, Nat.sub_add_cancel hq.pos ] ] ; rw [ Nat.cast_sub <| by linarith [ Finset.mem_range.mp hi, Nat.sub_add_cancel hq.pos ] ] ; aesop;
    rw [ h_prod_rewrite ];
    exact Nat.recOn ( q - 1 ) ( by norm_num ) fun n ih => by rw [ Finset.prod_range_succ, pow_succ' ] ; simp +decide [ *, Nat.factorial ] ; ring;
  rcases hq.eq_two_or_odd' with rfl | ⟨ m, rfl ⟩ <;> simp_all +decide;
  exact mul_left_cancel₀ ( show ( ( 2 * m ).factorial : ZMod ( 2 * m + 1 ) ) ≠ 0 from by rw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact mt hq.dvd_factorial.mp ( by linarith ) ) ( by linear_combination' h_prod )

/-- Step 2: `n ∤ C(n, q)` when `q` is a prime factor of `n` with `q < n`. -/
theorem not_dvd_choose_of_prime_dvd {n q : ℕ} (hn : 2 ≤ n) (hq : q.Prime)
    (hqn : q ∣ n) (hqlt : q < n) : ¬ (n ∣ n.choose q) := by
  intro hdiv
  have hdiv_choose : q ∣ (n - 1).choose (q - 1) := by
    obtain ⟨ k, hk ⟩ := hdiv;
    exact ⟨ k, by nlinarith [ mul_choose_eq ( show 1 ≤ q by exact hq.pos ) ( show q ≤ n by linarith ) ] ⟩;
  convert choose_pred_eq_one_mod hq hqn ( le_of_lt hqlt ) using 1 ; simp_all +decide [ Nat.ModEq ];
  rw [ Nat.mod_eq_zero_of_dvd hdiv_choose, Nat.mod_eq_of_lt hq.two_le ] ; aesop

/-- Step 3: the coefficient of `X^q` in `(X + C a)^n` is nonzero in `(ZMod n)[X]`. -/
theorem coeff_Xq_ne_zero {n q : ℕ} (hn : 2 ≤ n) (a : ZMod n) (ha : IsUnit a)
    (hq : q.Prime) (hqn : q ∣ n) (hqlt : q < n) :
    ((X + C a) ^ n).coeff q ≠ 0 := by
  rw [ Polynomial.coeff_X_add_C_pow ];
  have h_choose : ¬(n ∣ Nat.choose n q) := by
    convert not_dvd_choose_of_prime_dvd hn hq hqn hqlt using 1;
  contrapose! h_choose; haveI := Fact.mk ( show 1 < n by linarith ) ; simp_all +decide [ ← ZMod.natCast_eq_zero_iff ] ;
  exact ha.pow ( n - q ) |> fun h => h.mul_right_eq_zero.mp h_choose

/-- Step 4: reverse direction (contrapositive form): if `n` is composite, then
`(X + C a)^n ≠ X^n + C a`. -/
theorem aks_reverse {n : ℕ} (hn : 2 ≤ n) (a : ZMod n) (ha : IsUnit a)
    (hcomp : ¬ n.Prime) : (X + C a) ^ n ≠ X ^ n + C a := by
  -- Let `q := n.minFac`. Then:
  set q := n.minFac with hq_def
  have hq : q.Prime := by
    exact Nat.minFac_prime ( by linarith )
  have hqn : q ∣ n := by
    exact Nat.minFac_dvd n
  have hqlt : q < n := by
    exact lt_of_le_of_ne ( Nat.minFac_le ( by linarith ) ) fun con => hcomp <| con ▸ hq;
  intro H; have := congr_arg ( fun p => p.coeff q ) H; norm_num [ Polynomial.coeff_X_pow, Polynomial.coeff_C, add_pow, mul_assoc, hq.ne_zero, hqlt.ne ] at this; ( have := coeff_Xq_ne_zero hn a ha hq hqn hqlt; aesop; )

/-- The AKS polynomial criterion for primality. -/
theorem aks_criterion {n : ℕ} (hn : 2 ≤ n) (a : ZMod n) (ha : IsUnit a) :
    n.Prime ↔ (X + C a) ^ n = X ^ n + C a := by
  constructor
  · intro hp; exact aks_forward hp a
  · intro heq
    by_contra hcomp
    exact aks_reverse hn a ha hcomp heq

end AKS