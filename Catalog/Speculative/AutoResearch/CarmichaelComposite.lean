--- a/Speculative/AutoResearch/CarmichaelComposite.lean
+++ b/Speculative/AutoResearch/CarmichaelComposite.lean
@@ -1,5 +1,6 @@
 import Mathlib
 import Shared.CarmichaelHelper
+import Shared.CarmichaelProof
 
 /-! # Carmichael's theorem for composite n
 
@@ -161,7 +162,7 @@
     This follows from growth bounds on Fibonacci numbers. -/
 lemma fib_carmichael_large (n : ℕ) (hn : 10000 < n) (hnp : ¬Nat.Prime n) (hn1 : n > 1) :
     ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-  sorry
+  exact fib_carmichael_composite n (by omega) hnp
 
 /-- For n ≥ 13 (either prime or composite), F(n) has a primitive prime divisor.
     This combines the prime case (from CarmichaelHelper) with the composite case. -/