--- a/Speculative/AutoResearch/FibPrimitive.lean
+++ b/Speculative/AutoResearch/FibPrimitive.lean
@@ -20,6 +20,7 @@
   (Carmichael 1913), which is stated but not yet formally verified.
 -/
 import Mathlib
+import Shared.CarmichaelProof
 
 set_option maxHeartbeats 1600000
 
@@ -166,7 +167,7 @@
     the primitive part. -/
 lemma fib_primitive_large (n : ℕ) (hn : 50000 < n) (hnp : ¬Nat.Prime n) :
     ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-  sorry
+  exact fib_carmichael_composite n (by omega) hnp
 
 /-! ## Main Theorem -/