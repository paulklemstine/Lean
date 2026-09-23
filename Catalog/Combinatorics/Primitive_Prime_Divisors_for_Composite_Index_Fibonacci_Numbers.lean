/-
# Primitive prime divisors for composite-index Fibonacci numbers (recovered stub)

This module did not contain Lean source at all: it held a *unified diff hunk*
against a file `Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_
Index_Fibonacci_Numbers.lean` which is not part of this repository, so the module
could not compile and nothing could be recovered from it.  The hunk is preserved
verbatim below, as a comment, for reference:

```
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
```

No mathematical content is claimed here.  The Fibonacci primitive-divisor
material that *is* proved in this repository lives in `Shared.CarmichaelHelper`,
`Shared.CarmichaelComposite` and `Shared.CarmichaelProof`.
-/