--- a/Speculative/AutoResearch/Primitive_Prime_Divisors_of_Composite_Index_Fibonacci_Numbers_via_LTE_and_Entry_Point_Theory.lean
+++ b/Speculative/AutoResearch/Primitive_Prime_Divisors_of_Composite_Index_Fibonacci_Numbers_via_LTE_and_Entry_Point_Theory.lean
@@ -1,4 +1,5 @@
 import Mathlib
+import Shared.CarmichaelProof
 
 /-!
 # Carmichael's Primitive Divisor Theorem for Fibonacci Numbers (Composite Index Case)
@@ -166,4 +167,4 @@
 theorem fib_composite_has_primitive (n : ℕ) (hn : n > 10000) (hcomp : ¬Nat.Prime n) :
     ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
       ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-  sorry+  exact fib_carmichael_composite n (by omega) hcomp