import Catalog.Physics.ErdosStraus

/-!
# Erdős–Straus: prime-core reduction (FINAL location)

This module is the canonical entry point for the prime-core reduction of the
Erdős–Straus conjecture.  The mathematical content lives in
`Catalog/Physics/ErdosStraus.lean`; this file simply re-exports it under the
`Catalog/FINAL/Physics/` path referenced by the project plan.

Key results re-exported here (all in the `ErdosStraus` namespace):

* `ErdosStraus.ErdosStrausSolution` — the predicate `4/n = 1/x + 1/y + 1/z`.
* `ErdosStraus.es_of_nat` — denominator-cleared arithmetic bridge.
* `ErdosStraus.es_even`, `es_three_dvd`, `es_three_mod_four`, `es_five_mod_eight`
  — the four elementary solution families.
* `ErdosStraus.erdosStraus_reduction` — reduction to primes `p ≡ 1 [MOD 8]`.
* `ErdosStraus.erdosStraus_lt_1000` — finite verification below `1000`.
-/