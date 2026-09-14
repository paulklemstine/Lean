import Shared.CarmichaelHelper

/-!
# Carmichael's theorem for Fibonacci numbers: the prime-index case (re-export)

`Shared/NumberTheory/CarmichaelProof.lean` imports this module path, while the proof of
the prime-index case of Carmichael's primitive-divisor theorem actually lives in
`Shared/CarmichaelHelper.lean` (and is re-exported under a third path by
`MachineLearning/CarmichaelHelper.lean`).  The module file for this path was missing from
the repository, which made the import fail and broke the build of every downstream
Carmichael module.

This file is a thin re-export, so all three import paths resolve to the *same*
declaration `fib_primitive_divisor_prime`; no duplicate enters the environment.
-/