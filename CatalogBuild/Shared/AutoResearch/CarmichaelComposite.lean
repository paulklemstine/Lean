/-! # CatalogBuild.Shared.AutoResearch.CarmichaelComposite

Auto-generated from theorem catalog database.
Domain: Shared/AutoResearch
Declarations: 1
-/

import Mathlib
import Shared.CarmichaelComposite
import Shared.CarmichaelHelper

/-- For n ≥ 13 (either prime or composite), F(n) has a primitive prime divisor.
This combines the prime case (from CarmichaelHelper) with the composite case.
Proved in Shared.CarmichaelComposite. -/
theorem fib_carmichael' (n : ℕ) (hn : 13 ≤ n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) :=
  fib_carmichael n hn

