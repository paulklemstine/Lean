--- a/Speculative/AutoResearch/CarmichaelWork.lean
+++ b/Speculative/AutoResearch/CarmichaelWork.lean
@@ -1,4 +1,5 @@
 import Mathlib
+import Shared.CarmichaelProof
 
 /-! # Standalone Carmichael theorem helper
 
@@ -46,4 +47,4 @@
     Möbius inversion. -/
 theorem fib_carmichael_large' (n : ℕ) (hn : 10000 < n) (hnp : ¬ Nat.Prime n) :
     ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k := by
-  sorry+  exact fib_carmichael_composite n (by omega) hnp