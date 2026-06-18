# Future Directions: Sharp Collatz Contraction & Parity-Word Combinatorics

## What We Proved This Cycle

In `Catalog/Computation/CollatzSharpContraction.lean` we closed three of the open frontiers
left by the parity-contraction work, with fully verified (`sorry`-free, standard-axiom) proofs:

1. **Sharp logarithmic contraction criterion** (`pow3_lt_pow2_iff_log`): the real inequality
   `3^j < 2^k` is *equivalent* to the linear exponent inequality `j·log 3 < k·log 2`. This
   upgrades the crude integer sufficient condition `2j < k` to the exact threshold
   `j/k < log 2 / log 3 ≈ 0.6309`.
2. **Nat transfer + sharp witness** (`nat_pow3_lt_pow2_of_log`, `sharp_contraction_example`):
   the real criterion descends to `ℕ`, and `3^63 < 2^100` is exhibited as a real contraction
   (density `0.63`) that the integer criterion `2·63 < 100` provably cannot detect.
3. **Affine orbit bound** (`shortcut_affine`, `shortcut_lt_double`): the exact two-step affine
   identity `2·T_shortcut n = 3n+1` for odd `n`, plus the bound `T_shortcut n ≤ 2n`.
4. **Fibonacci parity-word count** (`goodLists_length`, `mem_goodLists`, `goodLists_nodup`,
   `noConsec_word_count_eq_fib`): an explicit, *verified* generator of all length-`k` binary
   words with no two consecutive `1`s, proven correct, duplicate-free, and of cardinality
   exactly `F_{k+2}`.

---

## Direction 1: From Word Count to a Realizable-Word Upper Bound

The set of *Collatz-realizable* parity words of length `k` is a subset of the no-consecutive-`1`s
words counted by `noConsec_word_count_eq_fib`, so the number of realizable orbit-parity prefixes is
at most `F_{k+2}`, which is `O(φ^k)` with `φ = (1+√5)/2 < 2`. The key insight is that
`mem_goodLists` already gives a *constructive bijection-grade* characterization of the admissible
words, so the realizability inclusion can be stated as a `List.Sublist`/`Finset.subset` fact and
the density bound `oddCount_le_half_ceil` becomes a corollary of the Fibonacci count rather than an
independent induction.

**Why now?** Both ingredients exist in Lean: `noConsec_word_count_eq_fib` gives the exact ambient
count, and the parity-exclusion theorem `collatz_odd_step_yields_even` supplies the membership
predicate. The only missing step is the injection from realizable prefixes into `goodLists k`.

**Testable claim**: For `k ≤ 12`, the number of orbit-parity prefixes actually realized by starting
values `n < 2^k` is `≤ Nat.fib (k+2)`, verifiable by `decide`/`#eval` and then in general via the
sublist injection.

---

## Direction 2: Quantitative Log-Threshold Bounds via Verified Rational Enclosures

`pow3_lt_pow2_iff_log` reduces contraction to comparing `j·log 3` and `k·log 2`, but applying it to
concrete `(j,k)` near the boundary `j/k = 0.6309…` requires verified numeric bounds on `log 3 /
log 2`. The key insight is that one does not need transcendence: a *rational sandwich*
`p/q < log 2 / log 3 < r/s` follows from integer power comparisons `3^a < 2^b` and `2^c < 3^d`
(both `decide`-checkable), which by `pow3_lt_pow2_iff_log` translate into linear bounds on the log
ratio. This yields a self-contained, axiom-light proof that `0.6309 < log 2 / log 3 < 0.6310`.

**Why now?** `sharp_contraction_example` already demonstrates the `decide`-checkable integer power
comparisons; chaining several of them through the iff lemma is purely mechanical and avoids any
floating-point or analytic estimate of the logarithm.

**Testable claim**: Prove `(0.63 : ℝ) < Real.log 2 / Real.log 3 ∧ Real.log 2 / Real.log 3 < 0.631`
using only `pow3_lt_pow2_iff_log` and integer power inequalities `3^a < 2^b`.

---

## Direction 3: Closed-Form Generating Function for the Verified Generator

`goodLists` is a concrete `List`-valued recursion whose length is `F_{k+2}`. The key insight is that
the same recursion underlies a transfer-matrix / generating-function identity: the bivariate
generating function `∑_k (goodLists k).length · x^k = (1 + x) / (1 - x - x²)`, and refining the
count by the *number of `1`s* gives `∑_{k,m} N(k,m) x^k y^m = (1 + xy) / (1 - x - x²y)`, whose
diagonal recovers the Fibonacci polynomials. Formalizing `N(k,m) = C(k-m+1, m)` (binary words of
length `k` with `m` non-adjacent `1`s) refines `noConsec_word_count_eq_fib` into a precise odd-step
*histogram*, directly bounding `oddCount`.

**Why now?** Mathlib has `Nat.choose`, `Polynomial`, and `PowerSeries`; the refined generator is a
one-line modification of `goodLists` that tags each appended `true` with a `+1` weight, and the
binomial identity is a clean two-step induction mirroring `goodLists_length`.

**Testable claim**: Prove that the number of length-`k` no-consecutive-`1`s words with exactly `m`
ones equals `Nat.choose (k - m + 1) m`, and that summing over `m` reproduces `Nat.fib (k+2)`.

---

## Direction 4: Iterated Affine Contraction over Mixed Odd/Even Blocks

`shortcut_affine` gives the exact relation `2·T_shortcut n = 3n+1` for a single odd-then-even block.
The key insight is that composing `j` shortcut blocks and `e` further halvings yields the closed
affine bound `(T-orbit value) ≤ (3^j·n + (3^j − 1)) / 2^{j+e}`, where the numerator's error term is
the geometric sum `∑_{i<j} 3^i = (3^j−1)/2`. Combined with `nat_pow3_lt_pow2_of_log`, this gives a
fully explicit, log-sharp descent certificate: whenever `j·log 3 + log(n+1) < (j+e)·log 2`, the
orbit value drops below `n`.

**Why now?** The single-block identity (`shortcut_affine`) and the sharp power comparison
(`nat_pow3_lt_pow2_of_log`) are both proven; the missing piece is the induction packaging the
geometric error term, a standard `Nat.rec` argument over the number of blocks.

**Testable claim**: For `n = 27` (whose orbit has `41` odd steps and `70` even steps), prove that the
affine upper bound `(27·3^41 + (3^41 − 1)) / 2^111 < 27`, certifying net contraction across the full
orbit by a single inequality.

---

## Direction 5: Parity-Exclusion Classification of Generalized Collatz Systems

The standard system has a *branch-exclusion* property (an odd step forces an even step), which is
exactly what makes the realizable words a subset of the Fibonacci-counted set. The key insight is
that for a generalized `mx+r` system with modulus `m`, branch-exclusion holds iff each "expanding"
branch maps its residue class entirely into the union of "contracting" residue classes — a finite,
`decide`-checkable condition on the residues mod `m²`. Systems satisfying it inherit an
`F_{k+2}`-style sub-exponential bound on realizable branch words and hence automatic density bounds;
systems violating it admit consecutive expansions and lie in the suspected-undecidable regime.

**Why now?** The exclusion mechanism is already isolated abstractly (the `a = true ⇒ b = false` step
of `mem_goodLists`), so it can be parameterized over a general branch table; the per-system check is
a finite residue computation that `decide` can discharge for small `m`.

**Testable claim**: For the modulus-`3` system with branches `{0 ↦ n/3, 1 ↦ (2n+1)/3,
2 ↦ (4n+1)/3}`, decide whether branch-exclusion holds by checking all residue classes mod `9`, and
classify the system as "tame" (bounded branch-word density) or "wild" accordingly.
