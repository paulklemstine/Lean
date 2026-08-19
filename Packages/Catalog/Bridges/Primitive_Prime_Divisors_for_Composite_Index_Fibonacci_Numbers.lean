/-!
# Primitive prime divisors for composite-index Fibonacci numbers

This file is not Lean source: what was delivered here is a stray `git diff` fragment
(a patch hunk against a file of another research thread), containing the statement of
the Wall base case `v_p(F(np)/F(n)) = 1` for an odd prime `p ∣ F(n)`, with no proof.
The fragment is preserved verbatim in the comment below; as it stands it cannot be
elaborated, and the missing proof is a lifting-the-exponent argument for the Fibonacci
sequence rather than a gap that can be closed by a rewording.

Verbatim content as delivered:

    --- a/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean
    +++ b/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean
    @@ -99,6 +99,9 @@
         (show p ∣ Nat.fib (n + 1) from by rwa [← ZMod.natCast_eq_zero_iff]))
         (by aesop)
     
    +/-- Key helper: F(np)/F(n) ≡ p · F(n+1)^{p-1} (mod p²).
    +    Since gcd(F(n+1), p) = 1, Fermat gives F(n+1)^{p-1} ≡ 1 (mod p),
    +    so F(np)/F(n) ≡ p (mod p²), hence v_p(F(np)/F(n)) = 1. -/
     -- Wall base case: v_p(F(np)/F(n)) = 1 for odd prime p | F(n)
     lemma wall_base (n p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
         (hpn : p ∣ Nat.fib n) (hn : 2 ≤ n) :
-/