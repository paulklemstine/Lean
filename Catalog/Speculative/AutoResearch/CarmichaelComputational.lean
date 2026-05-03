--- a/Speculative/AutoResearch/CarmichaelComputational.lean
+++ b/Speculative/AutoResearch/CarmichaelComputational.lean
@@ -1,5 +1,6 @@
 import Mathlib
 import Shared.CarmichaelHelper
+import Shared.CarmichaelProof
 
 /-! # Computational verification of Carmichael's theorem
 
@@ -68,4 +69,4 @@
 theorem fib_composite_has_primitive (n : ℕ) (hn : 13 ≤ n) (hn_comp : ¬Nat.Prime n) :
     ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
       ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-  sorry+  exact fib_carmichael_composite n hn hn_comp