import Mathlib
import Shared.CarmichaelHelper
import Shared.CarmichaelComposite

/-! # Carmichael's theorem for composite n

We prove that for composite n ≥ 14, F(n) has a primitive prime divisor.

Key idea: For composite n, we split n = d * m where d is the smallest proper divisor > 1.
Then we use the identity: gcd(F(n), F(d)) = F(gcd(n,d)) = F(d) (since d | n).
So F(d) | F(n). The quotient F(n)/F(d) is "large" for n ≥ 14, and contains prime factors
that don't appear in F(k) for any 0 < k < n with F(k) | F(d)*lcm(...).

Actually, we use a different approach: for the entry point α(p) of any prime p,
we have p | F(n) iff α(p) | n. If every prime factor of F(n) has entry point
strictly less than n, then every prime factor divides F(d) for some proper divisor d | n,
so F(n) | lcm{F(d) : d | n, d < n}. But F(n) > this lcm for n ≥ 13.

We prove the bound F(n) > ∏{F(d) : d | n, 0 < d < n} for n ≥ 13 with n composite.

NOTE: The proof is provided by Shared.CarmichaelComposite.fib_carmichael.
The duplicate declarations below are placed in a namespace to avoid conflicts.
-/

namespace Speculative.AutoResearch.CarmichaelCompositeNS

open Classical in
/-- The "Fibonacci entry point" of p: smallest k > 0 with p | F(k), or 0 if none. -/
noncomputable def fibEntryPt (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then
    Nat.find h
  else 0

end Speculative.AutoResearch.CarmichaelCompositeNS

/-- For n ≥ 13 (either prime or composite), F(n) has a primitive prime divisor.
    This combines the prime case (from CarmichaelHelper) with the composite case.
    Proved in Shared.CarmichaelComposite. -/
theorem fib_carmichael' (n : ℕ) (hn : 13 ≤ n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) :=
  fib_carmichael n hn
