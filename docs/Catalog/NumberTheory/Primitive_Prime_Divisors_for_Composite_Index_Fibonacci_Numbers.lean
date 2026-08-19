/-
This file is disabled: its content is not Lean source but a unified diff fragment against
`Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean`.
It was emitted this way by the catalog generator.  The original text is preserved verbatim
below inside this comment (with comment delimiters spaced out) so that nothing is lost while
the project builds end to end.

--- a/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean
+++ b/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean
@@ -99,6 +99,9 @@
     (show p ∣ Nat.fib (n + 1) from by rwa [← ZMod.natCast_eq_zero_iff]))
     (by aesop)
 
+/ -- Key helper: F(np)/F(n) ≡ p · F(n+1)^{p-1} (mod p²).
+    Since gcd(F(n+1), p) = 1, Fermat gives F(n+1)^{p-1} ≡ 1 (mod p),
+    so F(np)/F(n) ≡ p (mod p²), hence v_p(F(np)/F(n)) = 1. - /
 -- Wall base case: v_p(F(np)/F(n)) = 1 for odd prime p | F(n)
 lemma wall_base (n p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
     (hpn : p ∣ Nat.fib n) (hn : 2 ≤ n) :
-/