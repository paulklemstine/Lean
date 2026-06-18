# Future Directions — The Goldbach Circle of Conjectures

## Synthesis

This cycle isolates the *logical and computational skeleton* of the Goldbach
problem from its (open) analytic core. We name the strong (binary) conjecture as
a `Prop` (`Goldbach.GoldbachStrong`) and prove the classical elementary
reductions around it formally:

- **binary ⟹ ternary** (`strong_implies_weak`): every odd `n ≥ 7` is a sum of
  three primes once every even `n ≥ 4` is a sum of two, via the bridge
  `n = 3 + (n - 3)`.
- **the three-primes corollary** (`strong_implies_three_primes`): assuming the
  strong conjecture, every `n ≥ 6` is a sum of three primes (even case
  `n = 2 + (n-2)`; odd case through the weak form).

Alongside these conditional results we establish two *unconditional* facts:

- **infinitude of representable evens** (`infinitely_many_goldbach_even`): the
  numbers `2p = p + p` give arbitrarily large even sums of two primes, directly
  from `Nat.exists_infinite_primes`.
- **odd-prime structure** (`even_rep_uses_odd_primes`): every two-prime
  representation of an even `n ≥ 6` uses two *odd* primes — the only even prime is
  `2`, and `2 + (n-2)` would force `n = 4`.

Finally, `Verification.lean` provides a *kernel-trusted* computational
certificate: a decidable Boolean search `goldbachCheck`, its soundness bridge
`goldbachCheck_sound`, and a `native_decide` verification
(`goldbach_verified_range`) that strong Goldbach holds for every even
`4 ≤ n ≤ 1000`, packaged as the existence statement `goldbach_holds_below`.

## Results Summary

| Theorem | Status | Trusted axioms |
|---|---|---|
| `infinitely_many_goldbach_even` | unconditional | `propext, Classical.choice, Quot.sound` |
| `even_rep_uses_odd_primes` | unconditional | `propext, Classical.choice, Quot.sound` |
| `strong_implies_weak` | conditional on `GoldbachStrong` | same |
| `strong_implies_three_primes` | conditional on `GoldbachStrong` | same |
| `goldbachCheck_sound` | unconditional | same |
| `goldbach_holds_below` (≤ 1000) | unconditional | adds `Lean.ofReduceBool, Lean.trustCompiler` |

No `sorry` remains on any result.

## Research Directions

### 1. Push the verified window and make the bound a parameter

Replace the hard-coded `1000` in `goldbach_verified_range` with a general
`goldbach_verified_upto (B : ℕ)` whose proof is dispatched by `native_decide`,
and benchmark how far `B` can go (10⁴, 10⁵, …) before reflection becomes the
bottleneck. The key insight is that the *soundness extraction*
(`goldbachCheck_sound`) is completely independent of `B`, so only the Boolean
reflection step needs to scale — meaning a single, reusable correctness lemma
already covers every finite verification window. **Why now?** We have a clean
sound/complete Boolean oracle in hand; turning the constant into a parameter is a
falsifiable, immediately testable engineering claim (it fails the moment a
counterexample appears or `native_decide` times out), and it converts an open
conjecture into an ever-growing body of certified finite evidence.

### 2. A counting refinement: the Goldbach partition function `r₂(n)`

Define `r₂(n)` as the cardinality of the `Finset` of representations
`{(p,q) : p ≤ q, p+q = n, p,q prime}` and prove elementary monotonicity/positivity
facts: `goldbachCheck n = true ↔ r₂(n) > 0`, and that `r₂(2p) ≥ 1` for prime `p`.
The key insight is that `even_rep_uses_odd_primes` already pins the support of
`r₂` to odd-prime pairs, so the counting function inherits exact structural
constraints rather than being an opaque analytic object. **Why now?** The
decidable search infrastructure trivially upgrades from a `Bool` to a `Finset`
cardinal, giving a formal handle on the *quantitative* Goldbach heuristic
(`r₂(n) ≈ n / (log n)²`) — a precise, falsifiable target whose lower-bound
fragments are within reach of elementary sieve bounds.

### 3. Formalize the Goldbach–Levy / odd-number reformulation

State and prove the equivalence `GoldbachStrong ↔ (∀ m ≥ 2, ∃ p q prime, 2*m = p+q)`
and the Levy-style statement that every odd `n ≥ 7` is `p + 2q` for primes `p, q`
follows from the binary conjecture. The key insight is that re-indexing evens as
`2m` exposes the conjecture as a statement about the *additive convolution of the
primes with themselves*, the exact object the circle method integrates. **Why
now?** All the parity plumbing is already proven in `Core.lean`; these
equivalences are short formal corollaries that connect our skeleton to the
analytic literature and give the next cycle a precise convolution target.

### 4. Chen-flavored relaxation: prime-plus-almost-prime, decidably

Introduce `Almost2 n := ∃ p s, p.Prime ∧ (s.Prime ∨ ∃ a b, a.Prime ∧ b.Prime ∧ s = a*b) ∧ n = p + s`
(prime + (prime or semiprime)) with a decidable Boolean search, and verify it on
an initial range, mirroring Chen's theorem in miniature. The key insight is that
weakening "two primes" to "prime + semiprime" enlarges the search space enough
that *every* tested even number is representable with large slack, making the
relaxed statement an over-determined, robustly testable surrogate. **Why now?**
Our `goldbachCheck`/soundness pattern transfers verbatim to the relaxed predicate,
so a formal, machine-checked toy Chen theorem is essentially free and seeds a path
toward sieve-theoretic lower bounds on representation counts.

### 5. Density lower bound for representable evens via the `2p` family

Prove that the counting function `E(N) := #{even n ≤ N : RepTwoPrimes n}`
satisfies `E(N) ≥ π(N/2)` (each prime `p ≤ N/2` contributes the distinct even
`2p`), giving an *unconditional* positive-density-flavored lower bound on the
Goldbach-representable evens. The key insight is that the diagonal `p + p`
already certifies a number of representable evens equal to a prime-counting
quantity, so a nontrivial unconditional lower bound exists *without* resolving the
conjecture. **Why now?** Mathlib's `Nat.primeCounting`/`Nat.nth` API makes
`π(N/2)` a first-class object, so the diagonal injection `p ↦ 2p` can be turned
into a formal `Finset.card` inequality — a falsifiable density statement that
sharpens the qualitative `infinitely_many_goldbach_even` result already proven.
