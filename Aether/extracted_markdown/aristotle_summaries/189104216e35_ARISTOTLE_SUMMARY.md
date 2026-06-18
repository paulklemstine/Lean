# Summary of changes for run 6c2fd49b-dca0-4e3e-99de-827dcca8ba96
Completed a research cycle on the Korselt criterion for Carmichael numbers and its divisor-lattice "tropical flatness" reformulation, delivering two fully-proved Lean files (0 sorries) plus a future-directions document.

Deliverables (all build cleanly against the project's Mathlib; only allowed axioms used: propext, Classical.choice, Quot.sound, and Lean.ofReduceBool/trustCompiler from the numeric certificate examples):

1. `Shared/KorseltCarmichael.lean`
   - `Korselt` and `FermatProperty` definitions.
   - `pow_modEq_one_of_sub_one_dvd`: Fermat's little theorem lifted along divisibility.
   - `dvd_of_squarefree_of_forall_prime_dvd`: squarefree recombination via factorization domination.
   - `fermatProperty_of_korselt`: the substantive implication that Korselt's criterion forces the universal Fermat congruence `a^(n-1) ≡ 1 [MOD n]` for every base coprime to `n` (i.e. Korselt ⟹ Carmichael).
   - Concrete certificates `korselt_561`, `korselt_1105`, `korselt_1729` and `fermatProperty_561`.
   - `not_korselt_two_primes`: no product of two distinct primes is Korselt (the dimension-two flatness obstruction).

2. `Bridges/KorseltTropicalFlatness.lean` (uses catalog results: imports `EML.LatticeTreeCorrespondence` and reuses `berggren_M₃'`, and imports `Shared.KorseltCarmichael`)
   - `dvd_iff_factorization_le` / `dvd_iff_forall_factorization_le`: divisibility = pointwise domination of prime-exponent (valuation) profiles — the master tropical-flatness principle.
   - `korselt_iff_flat`: Korselt's criterion is exactly "squarefree and the valuation profile of `n-1` dominates that of every `p-1` with `p ∣ n`."
   - `berggren_M3_pow`, `berggren_M3_pow_offdiag`, `berggren_M3_pow_reduces_iff`: the Berggren shear's k-th power is `!![1,2k;0,1]`, and its reduction mod `m` collapses to the identity iff `m ∣ 2k` — the same single divisibility/valuation-domination law, giving the Shared ↔ Computation ↔ Pythagorean bridge.

3. `FUTURE_DIRECTIONS.md`: five falsifiable conjectures derived from this cycle (Korselt ⟺ Carmichael converse; ≥3 prime factors; quantitative flatness defect; Berggren shear order; flat reduction preserving Pythagorean primitivity), each with a "key insight" and a "Why now?" justification.

Both Lean files contain `-- !-- Lab Notes -- !--` blocks documenting the hypothesize/experiment/analyze/critique/synthesis loop.

Note on the existing `Shared/CarmichaelProof.lean`: its remaining `sorry` is the infinite-tail case of Carmichael's primitive-divisor theorem for Fibonacci numbers (composite `n > 10000`), a deep result; it was left untouched as it is outside the scope of this Korselt-focused cycle (and that file additionally fails to build in the project because its imported `Shared.CarmichaelHelper` is missing — a pre-existing condition). The new files are independent and self-contained.