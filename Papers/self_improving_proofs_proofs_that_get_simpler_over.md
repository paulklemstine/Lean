# Computational Evidence — Self-Improving Proofs

The mission's conjecture reduces, once made precise, to a statement about the
order structure of `ℕ`: a proof `P` carries a complexity
`C(P) = length(P) + depth(P) + #lemmas(P) ∈ ℕ`, and refinement means strict
decrease of `C`. All the dynamical claims (a simplest proof exists, the process
halts, chains can be arbitrarily long) are therefore claims about descending
sequences in `ℕ`. Below is the concrete evidence gathered before formalizing.

## 1. Small-case calculations

### The `√2` refinement chain

Three genuine proof strategies for `Irrational (√2)`, with a coarse complexity
count `C = length + depth + #lemmas` (lines of essential tactic script + nesting
depth of case splits + number of auxiliary lemmas invoked):

| Strategy | length | depth | #lemmas | `C(P)` |
|---|---|---|---|---|
| A. classical proof by contradiction (`a/b` in lowest terms, both even) | 4 | 2 | 1 | **7** |
| B. via `2 ∣ n² → 2 ∣ n` (`Nat.Prime.dvd_of_dvd_pow`) | 2 | 1 | 1 | **4** |
| C. packaged `irrational_sqrt_two` | 1 | 0 | 1 | **2** |

Refinement chain: `C = 7 ⇝ 4 ⇝ 2`, strictly decreasing, halting at `C = 2`.
The values themselves are only illustrative; what is verified formally is that
they form a strictly descending, terminating chain with a unique minimum.

### Descending sequences in `ℕ` (the abstract content)

Simulating "measure `C` at each refinement step" for a few monotone-improving
sequences:

| start `C₀` | sample non-increasing walk | halts at step | limit `C∞` |
|---|---|---|---|
| 5 | 5,4,4,2,2,2,… | 3 | 2 |
| 9 | 9,7,7,7,3,3,… | 4 | 3 |
| N | N, N−1, …, 1, 0, 0, … | N | 0 |

Every walk stabilizes; the stabilization index is unbounded across the family
(row 3 needs `N` steps), matching "the process can be arbitrarily long yet always
halts."

## 2. OEIS search

The only sequence that appears is the maximal chain length as a function of the
starting complexity `N`, namely `N ↦ N` (the padded chain `N, N−1, …, 0`). This
is the identity sequence A001477 (0,1,2,3,…) and carries no further structure —
consistent with the fact that the phenomenon is purely the well-ordering of `ℕ`.

## 3. Counterexample hunt

The universal claims were stress-tested against attempts to build a
counterexample:

- **"Infinite strictly-descending refinement chain."** Any candidate `f : ℕ →
  Proof T` with `C(f(n+1)) < C(f(n))` yields a strictly decreasing sequence of
  naturals, which cannot exist. No counterexample — formalized as
  `no_infinite_refinement`.
- **"A non-increasing sequence that never stabilizes."** Impossible for the same
  reason (a never-stabilizing antitone `ℕ`-sequence would be strictly decreasing
  infinitely often). No counterexample — formalized as `refinement_terminates`.
- **"A family of proofs with no simplest element."** Would require a nonempty
  subset of `ℕ` with no least element. No counterexample — formalized as
  `exists_minimal_proof`.
- **"Two simplest proofs of different complexity."** Would violate antisymmetry
  of `≤` on `ℕ`. No counterexample — formalized as `simplest_complexity_unique`.

No counterexamples were found to any universal claim, as expected.

## 4. Tables / plots

The single relevant plot is the complexity-vs-step trace of a refinement run,
e.g. for row 2 above: `9 → 7 → 7 → 7 → 3 → 3 → …`, a staircase that is
non-increasing and eventually flat. Every such trace is a non-increasing `ℕ`
sequence, hence eventually constant — the visual content of
`refinement_terminates`.

## Conclusion

The evidence is unanimous: modelled honestly, the refinement dynamics are exactly
the descending-chain behaviour of `ℕ`. This is what is proved, without any
axioms beyond `propext`, `Classical.choice`, `Quot.sound`, in
`Catalog/NumberTheory/SelfImprovingProofs.lean`.
