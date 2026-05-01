/-! # CatalogBuild.Speculative.AutoResearch.Carmichael_Primitive_Divisors_for_Composite_Indices_via_Fibonacci_Entry_Points_and_LTE

Auto-generated from theorem catalog database.
Domain: Speculative/AutoResearch
Declarations: 18
-/

import Mathlib

/-- Remove all prime factors that `n` shares with `g`. -/
def removeFactors (n g : ℕ) : ℕ :=
  if hn : n ≤ 1 then n
  else if hg : g ≤ 1 then n
  else
    if hd : Nat.gcd n g ≤ 1 then n
    else
      have : n / Nat.gcd n g < n := Nat.div_lt_self (by omega) (not_le.mp hd)
      removeFactors (n / Nat.gcd n g) g
termination_by n


/-- The proper positive divisors of `n` as a list. -/
def properDivisors (n : ℕ) : List ℕ :=
  (List.range n).filter (fun d => d > 0 && (n % d == 0))


/-- The primitive part of F(n): the largest factor of F(n) coprime to F(d)
for every proper positive divisor d of n. -/
def fibPrimPart (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  let divs := properDivisors n
  divs.foldl (fun acc d => removeFactors acc (Nat.fib d)) fn


/-- Boolean check that all composite n in [lo, hi] have fibPrimPart > 1. -/
def checkCompositeRange (lo hi : ℕ) : Bool :=
  (List.range (hi - lo + 1)).all fun i =>
    let n := lo + i
    n.Prime || fibPrimPart n > 1


/-- [Section: ### Key Properties of removeFactors] -/
lemma removeFactors_dvd (n g : ℕ) : removeFactors n g ∣ n := by
  -- We'll use induction on $n$. The base case is when $n \leq 1$.
  induction' n using Nat.strong_induction_on with n ih generalizing g;
  unfold removeFactors;
  split_ifs <;> simp_all +decide [ Nat.gcd_dvd_left, Nat.gcd_dvd_right ];
  exact dvd_trans ( ih _ ( Nat.div_lt_self ( by linarith ) ( by linarith ) ) _ ) ( Nat.div_dvd_of_dvd ( Nat.gcd_dvd_left _ _ ) )


lemma removeFactors_coprime (n g : ℕ) (hn : 0 < n) (hg : g > 0) :
    Nat.Coprime (removeFactors n g) g := by
  induction' n using Nat.strongRecOn with n ih;
  -- We consider three cases for the gcd of n and g.
  by_cases h_gcd : Nat.gcd n g ≤ 1;
  · unfold removeFactors;
    cases h_gcd.eq_or_lt <;> simp_all +decide [ Nat.Coprime, Nat.gcd_eq_left_iff_dvd ];
  · unfold removeFactors;
    split_ifs <;> simp_all +decide [ Nat.gcd_eq_left_iff_dvd ];
    · interval_cases n ; aesop;
    · interval_cases g ; aesop;
    · exact ih _ ( Nat.div_lt_self hn ( lt_of_not_ge h_gcd ) ) ( Nat.div_pos ( Nat.le_of_dvd hn ( Nat.gcd_dvd_left _ _ ) ) ( Nat.gcd_pos_of_pos_left _ hn ) )


lemma removeFactors_le (n g : ℕ) : removeFactors n g ≤ n := by
  unfold removeFactors;
  split_ifs <;> norm_num;
  exact le_trans ( show _ ≤ n / n.gcd g from Nat.le_of_dvd ( Nat.div_pos ( Nat.le_of_dvd ( by linarith ) ( Nat.gcd_dvd_left _ _ ) ) ( Nat.gcd_pos_of_pos_left _ ( by linarith ) ) ) ( removeFactors_dvd _ _ ) ) ( Nat.div_le_self _ _ )


/-- [Section: ### fibPrimPart Properties] -/
lemma fibPrimPart_dvd_fib (n : ℕ) : fibPrimPart n ∣ Nat.fib n := by
  -- By definition of `fibPrimPart`, we know that `fibPrimPart n` is the result of repeatedly applying `removeFactors` to `Nat.fib n`.
  simp [fibPrimPart];
  induction' ( properDivisors n ) using List.reverseRecOn with d l ih <;> simp_all +decide [ Nat.dvd_trans ];
  exact dvd_trans ( removeFactors_dvd _ _ ) ih


lemma fibPrimPart_coprime_proper_div (n d : ℕ) (hd : d ∣ n) (hd0 : 0 < d)
    (hdn : d < n) : Nat.Coprime (fibPrimPart n) (Nat.fib d) := by
  -- By definition of `properDivisors`, `d` appears in the list `properDivisors n`.
  have h_d_in_divs : d ∈ properDivisors n := by
    unfold properDivisors;
    simp +decide [ List.mem_filter, List.mem_range, Nat.mod_eq_zero_of_dvd hd, hd0, hdn ];
  have h_foldl_coprime : ∀ {l : List ℕ}, d ∈ l → Nat.Coprime (List.foldl (fun acc d => removeFactors acc (Nat.fib d)) (Nat.fib n) l) (Nat.fib d) := by
    intros l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.Coprime ] ;
    by_cases h : 0 < List.foldl ( fun acc d => removeFactors acc ( Nat.fib d ) ) ( Nat.fib n ) l <;> by_cases h' : 0 < Nat.fib ih <;> simp_all +decide [ Nat.Coprime, Nat.gcd_comm ];
    · have := removeFactors_coprime ( List.foldl ( fun acc d => removeFactors acc ( Nat.fib d ) ) ( Nat.fib n ) l ) ( Nat.fib ih ) h ( Nat.fib_pos.mpr h' ) ; simp_all +decide [ Nat.Coprime, Nat.Coprime.symm ] ;
      cases hl <;> simp_all +decide [ Nat.Coprime, Nat.Coprime.symm ];
      exact Nat.Coprime.coprime_dvd_right ( removeFactors_dvd _ _ ) ‹_›;
    · unfold removeFactors; aesop;
    · have h_contra : ∀ {l : List ℕ}, List.foldl (fun acc d => removeFactors acc (Nat.fib d)) (Nat.fib n) l = 0 → False := by
        intros l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.Coprime ] ;
        have := removeFactors_dvd ( List.foldl ( fun acc d => removeFactors acc ( Nat.fib d ) ) ( Nat.fib n ) l ) ( Nat.fib ih ) ; simp_all +decide [ Nat.Coprime ] ;
      exact False.elim <| h_contra h;
    · unfold removeFactors; aesop;
  exact h_foldl_coprime h_d_in_divs


/-- [Section: ### Bridge Lemma: fibPrimPart > 1 implies primitive prime exists] -/
theorem fibPrimPart_gt_one_implies_primitive (n : ℕ) (hn : 1 < n)
    (hfp : 1 < fibPrimPart n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  -- Since fibPrimPart n > 1, it has a prime factor p (by Nat.exists_prime_and_dvd).
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p, Nat.Prime p ∧ p ∣ fibPrimPart n := by
    exact Nat.exists_prime_and_dvd hfp.ne';
  refine' ⟨ p, hp_prime, dvd_trans hp_div ( fibPrimPart_dvd_fib n ), _ ⟩;
  intros k hk_pos hk_lt_n hp_div_k
  have h_div_d : p ∣ Nat.fib (Nat.gcd k n) := by
    have h_div_d : p ∣ Nat.gcd (Nat.fib k) (Nat.fib n) := by
      exact Nat.dvd_gcd hp_div_k ( dvd_trans hp_div ( fibPrimPart_dvd_fib n ) );
    rw [ Nat.gcd_comm ] at h_div_d; simp_all +decide [ Nat.fib_gcd ] ;
    rwa [ Nat.gcd_comm ];
  have := fibPrimPart_coprime_proper_div n ( Nat.gcd k n ) ( Nat.gcd_dvd_right _ _ ) ( Nat.gcd_pos_of_pos_left _ hk_pos ) ( lt_of_le_of_lt ( Nat.le_of_dvd hk_pos ( Nat.gcd_dvd_left _ _ ) ) hk_lt_n ) ; have := Nat.dvd_gcd hp_div h_div_d ; aesop;


/-- Computational check: fibPrimPart n > 1 for all composite n ∈ [13, 100000]. -/
theorem fibPrimPart_gt_one_range :
    checkCompositeRange 13 100000 = true := by native_decide


/-- [Section: ### Finite Verification via native_decide] -/
lemma fibPrimPart_gt_one_le_100000 (n : ℕ) (hn : 13 ≤ n) (hn' : n ≤ 100000)
    (hn_comp : ¬Nat.Prime n) : 1 < fibPrimPart n := by
  -- By definition of `checkCompositeRange`, we know that `fibPrimPart n > 1` for all composite `n` in the range [13, 100000].
  have h_check : ∀ n ∈ Finset.Icc 13 100000, ¬n.Prime → 1 < fibPrimPart n := by
    intros n hn hn_comp
    have h_check : checkCompositeRange 13 100000 = true := by
      exact?;
    unfold checkCompositeRange at h_check;
    norm_num [ List.all_eq_true ] at h_check;
    have := h_check ( n - 13 ) ( by rw [ tsub_lt_iff_left ] <;> linarith [ Finset.mem_Icc.mp hn ] ) ; rw [ add_tsub_cancel_of_le ( by linarith [ Finset.mem_Icc.mp hn ] ) ] at this ; aesop;
  exact h_check n ( Finset.mem_Icc.mpr ⟨ hn, hn' ⟩ ) hn_comp


lemma fib_entry_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hpn : p ∣ Nat.fib n) : fibEntryPt p ∣ n := by
  unfold fibEntryPt;
  split_ifs with h;
  · have h_gcd : Nat.fib (Nat.gcd (Nat.find h) n) = Nat.gcd (Nat.fib (Nat.find h)) (Nat.fib n) := by
      exact?;
    have h_gcd_div : Nat.gcd (Nat.find h) n = Nat.find h := by
      refine' Nat.le_antisymm _ _;
      · exact Nat.le_of_dvd ( Nat.find_spec h |>.1 ) ( Nat.gcd_dvd_left _ _ );
      · refine' Nat.find_min' h ⟨ Nat.gcd_pos_of_pos_right _ hn, _ ⟩;
        exact h_gcd.symm ▸ Nat.dvd_gcd ( Nat.find_spec h |>.2 ) hpn;
    exact h_gcd_div ▸ Nat.gcd_dvd_right _ _;
  · exact False.elim <| h ⟨ n, hn, hpn ⟩


/-- The Lucas companion: L(m) = F(m-1) + F(m+1) = 2*F(m+1) - F(m). -/
def lucasCompanion (m : ℕ) : ℕ := Nat.fib (m + 1) + Nat.fib (m + 1) - Nat.fib m


/-- F(2m) = F(m) * L(m) where L(m) = 2*F(m+1) - F(m). -/
lemma fib_two_mul_eq (m : ℕ) : Nat.fib (2 * m) = Nat.fib m * (2 * Nat.fib (m + 1) - Nat.fib m) := by
  exact Nat.fib_two_mul m


lemma gcd_lucas_fib_dvd_two (m : ℕ) (hm : 0 < m) :
    Nat.gcd (2 * Nat.fib (m + 1) - Nat.fib m) (Nat.fib m) ∣ 2 := by
  -- Since $F(m)$ and $F(m+1)$ are coprime, any common divisor of $2F(m+1) - F(m)$ and $F(m)$ must also divide $2$.
  have h_coprime : Nat.gcd (Nat.fib m) (Nat.fib (m + 1)) = 1 := by
    exact?;
  -- Since $d$ divides $L(m)$ and $F(m)$, it must also divide $2F(m+1)$.
  have h_div_2Fm1 : Nat.gcd (2 * Nat.fib (m + 1) - Nat.fib m) (Nat.fib m) ∣ 2 * Nat.fib (m + 1) := by
    convert Nat.dvd_add ( Nat.gcd_dvd_left _ _ ) ( Nat.gcd_dvd_right _ _ ) using 1 ; rw [ tsub_add_cancel_of_le ] ; linarith [ Nat.fib_mono ( Nat.le_succ m ) ];
  exact ( Nat.Coprime.dvd_of_dvd_mul_right ( show Nat.Coprime ( Nat.gcd ( 2 * Nat.fib ( m + 1 ) - Nat.fib m ) ( Nat.fib m ) ) ( Nat.fib ( m + 1 ) ) from Nat.Coprime.coprime_dvd_left ( Nat.gcd_dvd_right _ _ ) h_coprime ) h_div_2Fm1 )


lemma lucas_ge_three (m : ℕ) (hm : 2 ≤ m) :
    3 ≤ 2 * Nat.fib (m + 1) - Nat.fib m := by
  rcases m with ( _ | _ | _ | m ) <;> simp +arith +decide [ Nat.fib_add_two ] at *;
  exact le_tsub_of_add_le_left ( by linarith [ Nat.fib_pos.2 m.succ_pos ] )


/-- For composite n > 100000, fibPrimPart n > 1.
This uses entry point theory and Lifting-the-Exponent for Fibonacci. -/
lemma fibPrimPart_gt_one_gt_100000 (n : ℕ) (hn : 100000 < n)
    (hn_comp : ¬Nat.Prime n) : 1 < fibPrimPart n := by
  sorry

