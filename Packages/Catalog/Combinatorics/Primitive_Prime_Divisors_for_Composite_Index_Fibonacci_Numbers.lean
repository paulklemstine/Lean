/-
This file, as originally committed, was not Lean source at all: it was a raw
unified-diff fragment (`--- a/... +++ b/... @@ ... @@`) accidentally saved with a
`.lean` extension.  It therefore could not compile.  The original bytes are
preserved verbatim in the block comment below so that no user-provided content is
lost; the fragment is incomplete (it references a surrounding file that is not
present) and so cannot be turned into elaborable Lean code here.

The mathematical content it alludes to -- primitive prime divisors of Fibonacci
numbers with composite index -- is available in this catalog in
`Shared.CarmichaelHelper` (`fib_primitive_divisor_prime`).

Original contents:

--- a/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean
+++ b/Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean
@@ -99,6 +99,9 @@
     (show p ∣ Nat.fib (n + 1) from by rwa [← ZMod.natCast_eq_zero_iff])
     (by aesop)

+/-- Key helper: F(np)/F(n) = p * F(n+1)^{p-1} (mod p^2).
+    Since gcd(F(n+1), p) = 1, Fermat gives F(n+1)^{p-1} = 1 (mod p),
+    so F(np)/F(n) = p (mod p^2), hence v_p(F(np)/F(n)) = 1. -/
 -- Wall base case: v_p(F(np)/F(n)) = 1 for odd prime p | F(n)
 lemma wall_base (n p : ℕ) (hp : Nat.Prime p) (hp2 : p != 2)
     (hpn : p | Nat.fib n) (hn : 2 <= n) :
-/