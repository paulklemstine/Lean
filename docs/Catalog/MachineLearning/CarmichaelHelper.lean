import Shared.CarmichaelHelper

/-!
# Carmichael's theorem for Fibonacci numbers: the prime-index case (re-export)

Several files of the catalog (`CarmichaelComposite`, `CarmichaelProof`,
`Fib_gcd_identity`, `FibonacciGcdSynchronization`, `EntanglementCyclicity`) refer to this
module path for the prime-index case of Carmichael's primitive divisor theorem, while
others refer to `Shared.CarmichaelHelper`.  The proof itself lives in
`Shared/CarmichaelHelper.lean`; this module is a thin re-export so that both import paths
resolve to the *same* declaration `fib_primitive_divisor_prime` and no duplicate is
introduced into the environment.
-/