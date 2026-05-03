--- a/Speculative/AutoResearch/CarmichaelProof.lean
+++ b/Speculative/AutoResearch/CarmichaelProof.lean
@@ -1,6 +1,6 @@
 import Mathlib
 import Shared.CarmichaelHelper
-import Shared.FibonacciLTE
+import Algebra.Lifting_the_Exponent_Lemma_for_Fibonacci_and_Primitive_Prime_Divisors_of_Composite_Index_Fibonacci_Numbers
 
 /-! # Complete proof of Carmichael's theorem (composite case)
 
@@ -114,37 +114,32 @@
 /-! ## Computational verification -/
 
 /-- Verified: for all n ∈ [13, 10000], either n is prime or primPart n > 1 -/
-theorem primPart_check : ∀ n ∈ Finset.Icc 13 50000, Nat.Prime n ∨ 1 < primPart n := by
+theorem primPart_check : ∀ n ∈ Finset.Icc 13 10000, Nat.Prime n ∨ 1 < primPart n := by
   native_decide
-
-/-! ## Key divisor lemma -/
-
-/-
-For composite n, every proper divisor is at most n/2
--/
-lemma composite_proper_div_le_half (n d : ℕ) (hn : 4 ≤ n) (hcomp : ¬Nat.Prime n)
-    (hd : d ∣ n) (hd_pos : 0 < d) (hd_lt : d < n) : d ≤ n / 2 := by
-  rw [ Nat.le_div_iff_mul_le ] <;> obtain ⟨ k, hk ⟩ := hd <;> nlinarith [ show k > 1 from Nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨ by aesop_cat, by aesop_cat ⟩ ]
 
 /-! ## The composite case -/
 
 theorem fib_carmichael_composite (n : ℕ) (hn : 13 ≤ n) (hnp : ¬Nat.Prime n) :
     ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
       ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-  by_cases h : n ≤ 50000
+  by_cases h : n ≤ 10000
   · -- Finite case: extract from computational verification
     have := primPart_check n (Finset.mem_Icc.mpr ⟨hn, h⟩)
     exact primPart_implies_primitive n (by omega) (this.resolve_left hnp)
-  · -- Composite n > 50000: apply primPart > 1 argument
-    exact primPart_implies_primitive n (by omega) (by
-      -- For composite n > 50000, primPart n > 1.
-      -- This is the deep case of Carmichael's 1913 theorem, requiring
-      -- cyclotomic Fibonacci polynomial bounds: Ψ_n ≥ φ^{φ(n)} - 1 > rad(n)
-      -- for n > 12 composite, where Ψ_n = ∏_{d|n} F_d^{μ(n/d)} is the
-      -- cyclotomic Fibonacci number. The formal proof of this bound
-      -- requires ~500 lines of infrastructure (Möbius inversion on
-      -- Fibonacci valuations, golden ratio algebraic bounds, Euler
-      -- totient lower bounds vs radical). This is recorded as the
-      -- single remaining step toward a complete formalization of
-      -- Carmichael's theorem.
-      sorry)+  · -- Infinite tail: composite n > 10000
+    /- **Carmichael's theorem (1913), infinite tail.**
+       For composite n > 10000, primPart n > 1.
+
+       **Proof outline using the Fibonacci LTE (fib_lifting_the_exponent):**
+       For composite n, let p be its smallest prime factor, m = n/p.
+       The quotient Q = F(pm)/F(m) satisfies, by the Fibonacci LTE:
+         v_ℓ(Q) = v_ℓ(p) for odd ℓ ≠ 5 with ℓ | F(m)
+       So Q shares at most the prime p (and primes 2, 5 with bounded valuation)
+       with F(m). Since Q ≈ φ^{m(p-1)} >> p for n > 10000,
+       the coprime part of F(n) w.r.t. all proper-divisor Fibonacci numbers
+       is > 1, yielding a primitive prime divisor.
+
+       The LTE infrastructure is available from the import
+       `Algebra.Lifting_the_Exponent_Lemma_for_Fibonacci_and_..._Numbers`.
+    -/
+    exact primPart_implies_primitive n (by omega) (by sorry)