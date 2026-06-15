# FUTURE DIRECTIONS — Fibonacci Divisibility Spectrum (Algebra)

This cycle added `Catalog/Algebra/FibonacciDivisibilitySpectrum.lean`, proving (against
Mathlib, self-contained):

- `Fib_gcd_identity` : `gcd (F m) (F n) = F (gcd m n)` (strong divisibility sequence).
- `fib_coprime_iff` : `Coprime (F m) (F n) ↔ gcd m n = 1 ∨ gcd m n = 2`.
- `fibRank_lcm` : `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` (rank is an lcm-morphism).
- `fibRank_mul_coprime` : `fibRank (a*b) = lcm (fibRank a) (fibRank b)` for coprime `a,b`.

Together with the catalog's `RankOfApparition.fibRank_dvd_of_dvd` (order morphism) these show
`fibRank` is a morphism of the divisibility lattice `(ℕ_{>0}, ∣, gcd, lcm)`.

The following directions are concrete, falsifiable, and build directly on the lemmas above.

---

## Direction 1 — `fibRank` does NOT preserve gcd (sharp negative companion to `fibRank_lcm`)

**Conjecture.** `fibRank` is an lcm-morphism but **not** a gcd-morphism: there exist positive
`a, b` with `fibRank (gcd a b) ≠ gcd (fibRank a) (fibRank b)`, while the divisibility
`fibRank (gcd a b) ∣ gcd (fibRank a) (fibRank b)` always holds.

- **Key insight.** The spine gives `n ∈ multiples(fibRank m) ↔ m ∣ F n`. For lcm this dualizes
  cleanly (intersection of multiple-sets), but `gcd a b ∣ F n` is *weaker* than
  `a ∣ F n ∨ b ∣ F n`, so only one inclusion survives. The one-sided law is provable from
  `fibRank_dvd_of_dvd`; the strictness needs one explicit witness (search small `a,b`).
- **Why now.** `fibRank_lcm` is already proved here, so both the positive divisibility half and
  the counterexample are short; this pins down exactly how far the lattice morphism extends.

## Direction 2 — Exact coprimality count for Fibonacci blocks

**Conjecture.** For fixed `n`, the number of `m ≤ N` with `Coprime (F m) (F n)` is asymptotically
`(c_n) N` where `c_n = ∏_{p ∣ n, p>2} (1 - 1/p)`-type density determined only by the odd prime
divisors of `n`, via `fib_coprime_iff` (the condition is purely `gcd m n ∈ {1,2}`).

- **Key insight.** `fib_coprime_iff` reduces a statement about Fibonacci values to a congruence
  condition on indices (`gcd m n ≤ 2`), so the count is a standard inclusion–exclusion over
  divisors of `n` — fully elementary and Lean-formalizable as an exact `Finset.card` identity
  before any asymptotics.
- **Why now.** The reduction lemma exists; the remaining work is finite combinatorics on
  `Nat.gcd`, which Mathlib's `Nat.Coprime`/`Finset` API supports directly.

## Direction 3 — Lucas numbers carry the same rank lattice

**Conjecture.** Define the Lucas rank `lucasRank m` (least `k>0` with `m ∣ L k`). Then the same
spine `m ∣ L n ↔ lucasRank m ∣ n` fails in general, but a *mixed* spine holds: `m ∣ L n ↔
fibRank m ∣ 2n` and `fibRank m ∤ n`, giving `lucasRank` as an explicit function of `fibRank`.

- **Key insight.** `L n = F_{2n}/F_n`, so Lucas divisibility is governed by the parity of the
  Fibonacci rank — a clean transfer of the lattice structure proved here to a second sequence.
- **Why now.** The Fibonacci spine is now self-contained in this file; the Lucas case only needs
  the identity `F_{2n} = F_n L_n` (in Mathlib) plus the established `fibRank_dvd_iff`.

## Direction 4 — Rank-lattice characterization of strong divisibility sequences

**Conjecture.** A sequence `a : ℕ → ℕ` with `a 0 = 0`, `gcd (a m) (a n) = a (gcd m n)` admits a
rank function `rank` satisfying both `rank (lcm x y) = lcm (rank x) (rank y)` and the order
morphism law `x ∣ y → rank x ∣ rank y` — i.e. the two morphism laws proved here for Fibonacci
hold for *every* strong divisibility sequence, abstractly.

- **Key insight.** Every proof in this file used only the spine `m ∣ a n ↔ rank m ∣ n`, which is
  derivable from the strong-divisibility gcd identity alone. Abstracting the hypotheses turns the
  four Fibonacci theorems into a single reusable theory.
- **Why now.** The Fibonacci proofs are short and uniform, so generalizing the `a` to an abstract
  strong divisibility sequence is mostly a matter of replacing `Nat.fib` by a hypothesis bundle —
  a high-leverage refactor that would subsume several parallel catalog threads.
