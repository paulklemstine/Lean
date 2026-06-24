import Mathlib

/-!
# The Brahmagupta–Fibonacci composition identity

This file records the classical *Brahmagupta–Fibonacci* identity, which shows that
the set of integers expressible as a sum of two squares is closed under
multiplication.  It is the algebraic shadow of the multiplicativity of the norm
of the Gaussian integers `ℤ[i]`.

We give both sign conventions of the identity; they correspond to multiplying by
`c + d·i` and by its conjugate `c - d·i` respectively.
-/

namespace FINAL.Pythagorean

/-- **Brahmagupta–Fibonacci identity** (first form).

The product of two sums of two squares is again a sum of two squares:
`(a² + b²)(c² + d²) = (ac − bd)² + (ad + bc)²`. -/
theorem brahmagupta_fibonacci (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
  ring

/-- **Brahmagupta–Fibonacci identity** (second/conjugate form).

`(a² + b²)(c² + d²) = (ac + bd)² + (ad − bc)²`. -/
theorem brahmagupta_fibonacci' (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by
  ring

end FINAL.Pythagorean