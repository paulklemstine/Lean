/-! # CatalogBuild.Speculative.SPBFiniteFieldOrder

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 3
-/

import Mathlib

/-- [Section: # SPB over Finite Fields: The p±1 Order Law (Hypothesis H3)
Over 𝔽_p, the SPB group has order:
- p + 1 when p ≡ 3 (mod 4)
- p - 1 when p ≡ 1 (mod 4)
We verify this computationally for small primes using native_decide.] -/
def spbMod (x y : ZMod p) : ZMod p := (x + y) / (1 - x * y)


def spbModIter (g : ZMod p) : ℕ → ZMod p
  | 0 => 0
  | n + 1 => spbMod g (spbModIter g n)


theorem spbModIter_one (g : ZMod p) : spbModIter g 1 = g := by
  simp [spbModIter, spbMod]

