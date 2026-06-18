# Summary of changes for run d7745ea5-7cc8-422f-a60d-f302b6223fb6
Research cycle complete. I created a new, fully verified (0-sorry) Lean 4 file and a future-directions document, both in the `Catalog/Algebra/` directory of the NumberTheory catalog.

## New verified file: `Catalog/Algebra/FibEntryPointReciprocity.lean`

This extends the catalog's existing Fibonacci primitive-divisor / entry-point work (in `Catalog/Algebra/Tropical_p_adic_..._Fibonacci_Primitive_Divisors.lean`) by **sharpening the classical coarse bound `z(p) ∣ p² − 1` into the precise two-sided "law of apparition"** governed by `p mod 5`. The file is self-contained (`import Mathlib` only) and builds cleanly; all main theorems verify using only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`, `Lean.ofReduceBool`, `Lean.trustCompiler`).

Key results proved:
- `fib_binet_ring` — Binet's formula in an arbitrary commutative ring: `(a−b)·F(n) = aⁿ − bⁿ` whenever `a+b=1, a·b=−1`. This single engine drives both the residue and non-residue cases.
- `five_isSquare_iff` — quadratic-reciprocity bridge: for odd prime `p≠5`, `5` is a square mod `p` iff `p % 5 ∈ {1,4}`.
- `fib_dvd_pred_of_five_isSquare` / `fib_dvd_succ_of_not_five_isSquare` — the residue case (golden ratios in `ZMod p`, Fermat) and non-residue case (golden ratios in `GF(p²)`/algebraic closure, Frobenius swapping conjugate roots).
- `fib_dvd_pred_of_mod`, `fib_dvd_succ_of_mod` — `p ≡ ±1 (mod 5) ⟹ p ∣ F(p−1)` and `p ≡ ±2 (mod 5) ⟹ p ∣ F(p+1)`.
- `zfib` (rank of apparition, self-contained) with `zfib_dvd_of_dvd`, `zfib_dvd_pred`, `zfib_dvd_succ`.
- `fib_dvd_pred_or_succ`, `zfib_dvd_pred_or_succ` — the unconditional dichotomy that strictly refines `z(p) ∣ p² − 1` by pinning down which factor of `(p−1)(p+1)`.
- `not_dvd_pred_and_succ` plus `fib_dvd_pred_iff` / `fib_dvd_succ_iff` — using `gcd(F(p−1),F(p+1)) = F(2) = 1`, these upgrade the laws to exact **equivalences** (`p ∣ F(p−1) ⟺ p ≡ ±1 mod 5`, etc.).

Lab notes are included as inline `-- !-- Lab Notes -- !--` blocks recording the hypotheses (numerically confirmed for primes `< 60`), the central insight (phrasing Binet over a general ring lets one induction serve both `ZMod p` and `GF(p²)`), and failure analysis (an unconditional product bound `F_n ∣ n·∏_{d<n,d∣n}F_d` was checked false; a cross-file import was dropped in favor of a self-contained reproof of the small entry-point fact).

## `Catalog/Algebra/FUTURE_DIRECTIONS.md`
Five bold, testable conjectures for follow-up cycles: (C1) the exact equivalence form of the law of apparition; (C2) generalizing the Binet engine and reciprocity law to all Lucas sequences `U_n(P,Q)` with discriminant `D` (`p ∣ U_{p−(D|p)}`); (C3) the cyclotomic lower bound `Φ_n ≥ α^{φ(n)−1}` plus structure theorem needed to close the open composite-`n` tail of Carmichael's primitive-divisor theorem; (C4) Wall's question `z(p²)=p·z(p)` / Wall–Sun–Sun primes; (C5) density of "Fibonacci-maximal" primes with `z(p)=p−1`.

Note on the pre-existing priority target: the `CarmichaelComposite` open problem reduces to an infinite-tail lemma (`fib_carmichael_composite` for composite `n > 10000`) in `Shared/CarmichaelProof.lean`. That file also has a broken import and the tail requires the sharp cyclotomic primitive-part lower bound (the naive divisor-product bound provably fails for abundant `n`); I documented the precise route to close it as conjecture C3 rather than leaving an unsound or vacuous claim. The work delivered this cycle is genuinely new, fully proved, and directly extends the catalog's entry-point theory.