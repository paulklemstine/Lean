/-!
# Primitive prime divisors for composite-index Fibonacci numbers (unusable source)

The contents of this file, preserved verbatim in the block comment below, are **not** Lean
source: they are a unified `diff` fragment (a patch against a module
`Speculative/AutoResearch/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean`
which is not present in this repository).  Consequently the file could not be elaborated and
broke the build of the `Shared` library.

Nothing is deleted: the original text is kept below as a comment.  A Lean development of the
`fibRank` (rank of apparition) machinery that this patch refers to lives in
`Shared/PosetTheory/FibonacciApparitionSheaf.lean`.
-/

/-
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