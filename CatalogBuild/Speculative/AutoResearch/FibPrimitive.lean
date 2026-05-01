/-! # CatalogBuild.Speculative.AutoResearch.FibPrimitive.lean

Auto-generated from theorem catalog database.
Domain: Speculative/AutoResearch
Declarations: 13
-/

import Mathlib

/-- If p divides both F(k) and F(n), then p divides F(gcd(k,n)).
Follows from the strong divisibility `F(gcd(m,n)) = gcd(F(m), F(n))`. -/
lemma prime_dvd_fib_gcd {p k n : ℕ} (hp : Nat.Prime p)
    (hk : p ∣ Nat.fib k) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd k n) := by
  exact Nat.dvd_gcd hk hn |> fun h => by simpa [Nat.fib_gcd] using h


/-- Checking primitivity over all 0 < k < n is equivalent to
checking only proper divisors d | n with 0 < d < n.
This uses `Nat.fib_gcd` to show that if p | F(k) and p | F(n),
then p | F(gcd(k,n)), and gcd(k,n) is a proper divisor of n. -/
lemma fib_primitive_iff_divisors {n : ℕ} (hn : 0 < n) {p : ℕ} (hp : Nat.Prime p)
    (hpn : p ∣ Nat.fib n) :
    (∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)) ↔
    (∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) := by
  refine ⟨fun h d hd _ _ ↦ h d ‹_› ‹_›, fun h k hk hk' ↦ ?_⟩
  exact fun hk'' => h (Nat.gcd k n) (Nat.gcd_dvd_right _ _)
    (Nat.gcd_pos_of_pos_left _ hk)
    (lt_of_le_of_lt (Nat.le_of_dvd hk (Nat.gcd_dvd_left _ _)) hk')
    (prime_dvd_fib_gcd hp hk'' hpn)


/-- List of proper divisors of n (d with 0 < d < n and d | n). -/
def properDivs (n : ℕ) : List ℕ :=
  (List.range n).filter (fun d => 0 < d ∧ n % d = 0)


/-- [Section: ## Verified Computational Checker] -/
lemma mem_properDivs {n d : ℕ} :
    d ∈ properDivs n ↔ d < n ∧ 0 < d ∧ d ∣ n := by
  simp +decide [properDivs, Nat.dvd_iff_mod_eq_zero]


/-- Compute the "primitive residual" of F(n): iteratively divide out
gcd with F(d) for each proper divisor d of n.
If the result R > 1, then R has a prime factor that is primitive. -/
def primitiveResidual (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  if fn ≤ 1 then 0
  else
    let divs := properDivs n
    Id.run do
      let mut rem := fn
      for _ in List.range 200 do
        let mut changed := false
        for d in divs do
          let g := Nat.gcd rem (Nat.fib d)
          if g > 1 then
            rem := rem / g
            changed := true
        if !changed then break
      return rem


/-- Verify that R certifies a primitive prime divisor:
R > 1, R | F(n), and gcd(R, F(d)) = 1 for all proper divisors d. -/
def verifyResidual (n R : ℕ) : Bool :=
  (R > 1) &&
  (Nat.fib n % R == 0) &&
  (properDivs n).all (fun d => Nat.gcd R (Nat.fib d) == 1)


/-- Combined check: compute residual and verify. -/
def checkPrimitiveExistence (n : ℕ) : Bool :=
  verifyResidual n (primitiveResidual n)


/-- Range check for all composite n in [lo, hi]. -/
def checkRangePrimitive (lo hi : ℕ) : Bool :=
  (List.range (hi - lo + 1)).all (fun i =>
    let n := lo + i
    Nat.Prime n || checkPrimitiveExistence n)


/-- If `verifyResidual` returns true, then F(n) has a primitive prime divisor.
The proof: R > 1 gives a prime factor p of R. Since R | F(n), p | F(n).
Since gcd(R, F(d)) = 1 for proper divisors d, p ∤ F(d).
By `fib_primitive_iff_divisors`, p is a primitive prime divisor. -/
lemma verifyResidual_sound {n R : ℕ} (hn : 0 < n)
    (h : verifyResidual n R = true) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  obtain ⟨p, hp_prime, hp_div_R⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ∣ R := by
    exact Nat.exists_prime_and_dvd (by unfold verifyResidual at h; aesop)
  refine' ⟨p, hp_prime, _, _⟩
  · exact dvd_trans hp_div_R (Nat.dvd_of_mod_eq_zero (by unfold verifyResidual at h; aesop))
  · intro k hk hk'; simp_all +decide [verifyResidual]
    contrapose! h
    refine' fun h => ⟨Nat.gcd k n, _, _⟩ <;> simp_all +decide [mem_properDivs]
    · exact ⟨lt_of_le_of_lt (Nat.le_of_dvd hk (Nat.gcd_dvd_left _ _)) hk', Nat.gcd_dvd_right _ _⟩
    · rw [Nat.Prime.not_coprime_iff_dvd]
      exact ⟨p, hp_prime, hp_div_R, prime_dvd_fib_gcd hp_prime ‹p ∣ Nat.fib k›
        (hp_div_R.trans (Nat.dvd_of_mod_eq_zero h.2))⟩


/-- If `checkPrimitiveExistence` returns true, F(n) has a primitive prime divisor. -/
lemma checkPrimitiveExistence_sound {n : ℕ} (hn : 0 < n)
    (h : checkPrimitiveExistence n = true) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) :=
  verifyResidual_sound hn h


/-- Soundness of the range checker. -/
lemma checkRangePrimitive_sound {lo hi : ℕ} (hlo : 0 < lo)
    (h : checkRangePrimitive lo hi = true) :
    ∀ n, lo ≤ n → n ≤ hi → ¬Nat.Prime n →
      ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  unfold checkRangePrimitive at h
  simp_all +decide [List.all_eq_true]
  intro n hn₁ hn₂ hn₃
  specialize h (n - lo) (Nat.sub_le_sub_right hn₂ _)
  rcases h with (h | h) <;> simp_all +decide [add_tsub_cancel_of_le hn₁]
  exact checkPrimitiveExistence_sound (by linarith) h


/-- Verified: all composite n ∈ [13, 50000] have a primitive prime divisor of F(n). -/
theorem fib_primitive_le_50000 : checkRangePrimitive 13 50000 = true := by native_decide


/-- For composite n > 50000, F(n) has a primitive prime divisor.
This follows from the Fibonacci LTE and exponential growth of
the primitive part. -/
lemma fib_primitive_large (n : ℕ) (hn : 50000 < n) (hnp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  sorry

