# The Combinatorics and Probability of the Library of Babel

**Author:** Aristotle
**Date:** 2026-06-19

## Abstract

We give an exact combinatorial and probabilistic analysis of Borges' *Library of
Babel*, modeled as the finite set of all strings of length `L` over an alphabet of
`b` symbols, endowed with the uniform (counting) probability measure. We prove four
foundational results — the library's cardinality `b^L`, the singleton probability
`b^(-L)`, the exact expected number of occurrences `(L-k+1)·b^(-k)` of a fixed
length-`k` pattern, and the union upper bound on the containment probability — and
then four extensions: the coincidence probability of two independent volumes, the
trivial-but-load-bearing fact that the counting probability never exceeds 1, an
exact count of volumes avoiding a pattern on every aligned block, and the resulting
two-sided estimate for the containment probability. The lower bound is non-vacuous
for every `L` and yields a *Borges completeness* theorem: for any alphabet of size
at least 2, the probability that a uniformly random volume contains a fixed pattern
tends to 1 as `L → ∞`. The disjoint-block argument is realized by an explicit
reindexing bijection between a volume and its block decomposition, avoiding any
appeal to inclusion–exclusion. We close with five conjectures on sharp asymptotics,
variance, autocorrelation, coupon-collecting, and distinct `k`-gram counts.

All results have been formally verified.

---

## 1. Introduction

Borges' 1941 story *La biblioteca de Babel* describes a library containing every
book of a fixed format: 410 pages, 40 lines per page, 80 characters per line, in an
alphabet of 25 orthographic symbols. The library is finite but immense: it holds
`25^1312000` volumes, a number with roughly 1.8 million decimal digits, dwarfing the
`≈10^80` atoms of the observable universe.

The story poses, in literary form, genuine mathematical questions. How many books
are there? What is the chance of finding a given one? How often does a phrase occur
by chance, and how long must a book be before a target phrase is essentially
guaranteed? Can a single book catalog all the others? We answer these precisely.

### 1.1 The model

Throughout, fix natural numbers `b` (alphabet size) and `L` (book length).

**Definition (Volume).** A *volume* is a function `v : Fin L → Fin b`, assigning to
each of the `L` positions one of the `b` symbols. We write `Volume b L` for the type
of volumes.

**Definition (Library).** The *library* `Library b L` is the finite set of all
volumes, i.e. the universal finite set on `Volume b L`.

**Definition (Counting probability).** For a finite sample type `α`, a sample set
`s ⊆ α`, and an event `A ⊆ α`, the *uniform probability* is
`prob(s, A) = #(s ∩ A) / #s`. With `s = Library b L` this is the uniform measure on
the library.

**Definition (Reading and occurrence).** For `v : Volume b L` and `n ∈ ℕ`,
`readAt(v, n) = some v(n)` if `n < L` and `none` otherwise. A *pattern* of length
`k` is a function `p : Fin k → Fin b`. We say `p` *occurs at* position `i`, written
`OccursAt(p, v, i)`, if `readAt(v, i+j) = some p(j)` for all `j ∈ Fin k`. The
*occurrence count* is `occurrenceCount(p, v) = #{ i ∈ {0,…,L-k} : OccursAt(p,v,i) }`,
and `v` *contains* `p`, written `Contains(p, v)`, if `OccursAt(p, v, i)` for some `i`.

**Definition (Expected occurrences).**
`expectedOccurrences(p, L) = (Σ_{v} occurrenceCount(p, v)) / #(Library b L)`,
the mean occurrence count under the uniform measure.

---

## 2. Foundational results

### 2.1 Size of the library

**Theorem 1 (`card_library`).** `#(Library b L) = b^L`.

*Proof sketch.* The library is the full function type `Fin L → Fin b`. The number of
functions from an `L`-element domain to a `b`-element codomain is `b^L`. ∎

### 2.2 Probability of a single volume

**Theorem 2 (`prob_singleton`).** For every volume `v`,
`prob(Library b L, {v}) = b^(-L)`.

*Proof sketch.* The filter of the library to `{v}` is a single point, so its
cardinality is 1, and `prob = 1 / #(Library b L) = 1 / b^L = b^(-L)` by Theorem 1.
∎

### 2.3 Counting lemmas

The expectation and the union bound rest on three counting lemmas.

**Lemma A (`card_filter_agree`).** For finite types `α, β`, a decidable predicate
`p` on `α`, and a fixed `g : α → β`, the number of functions `v : α → β` with
`v(a) = g(a)` for all `a` satisfying `p` equals `(#β)^(#{a : ¬p(a)})`.

*Proof sketch.* Such a `v` is free on positions where `p` fails and pinned on the
rest. Identify the constrained set of functions with the dependent product
`∏_a (if p a then {g a} else univ)`; its cardinality is the product of the factor
sizes, which is `(#β)` raised to the number of unconstrained coordinates. ∎

**Lemma B (`card_agree_inj`).** For an injection `φ : Fin k → Fin L` and pattern
`p`, the number of volumes with `v(φ(j)) = p(j)` for all `j` equals `b^(L-k)`.

*Proof sketch.* Apply Lemma A with the predicate "position lies in the image of
`φ`." Injectivity makes the image have exactly `k` elements, leaving `L - k`
unconstrained positions; the edge case `b = 0` is handled separately. ∎

**Lemma C (`card_occursAt`).** If `i + k ≤ L`, then
`#{ v : OccursAt(p, v, i) } = b^(L-k)`.

*Proof sketch.* The positions `j ↦ i + j` form an injection `Fin k → Fin L` (using
`i + k ≤ L`), and `OccursAt(p, v, i)` is exactly agreement with `p` along it. Apply
Lemma B. ∎

### 2.4 Expected occurrence count

**Theorem 3 (`expected_substring_count`).** If `k ≤ L` and `b > 0`, then
`expectedOccurrences(p, L) = (L - k + 1) · b^(-k)`.

*Proof sketch.* Write the total occurrence count as a double sum and exchange the
order of summation:
`Σ_v occurrenceCount(p, v) = Σ_{i=0}^{L-k} #{ v : OccursAt(p, v, i) }`.
Each summand is `b^(L-k)` by Lemma C, and there are `L - k + 1` of them, giving
`(L-k+1)·b^(L-k)`. Dividing by `#(Library b L) = b^L` (Theorem 1) and simplifying
`b^(L-k)/b^L = b^(-k)` yields the claim; the hypothesis `b > 0` guarantees the
denominator is nonzero. ∎

The shape `(L-k+1)·b^(-k)` is linear in length and exponentially small in pattern
length: a defining quantitative feature of random text.

### 2.5 Union upper bound

**Theorem 4 (`prob_contains_substring_bound`).** If `k ≤ L`, then
`prob(Library b L, {v : Contains(p, v)}) ≤ (L - k + 1) · b^(-k)`.

*Proof sketch.* The containment event is the union over `i ∈ {0,…,L-k}` of the
events `OccursAt(p, ·, i)` (any occurrence forces a valid start position, handled
carefully at the boundary `i = L-k`). By subadditivity of cardinality over a
`biUnion`, the count of containing volumes is at most `Σ_i #{OccursAt at i} =
(L-k+1)·b^(L-k)` via Lemma C. Dividing by `b^L` gives the bound. The degenerate
cases `b = 0` and `k = 0` are dispatched directly. ∎

This bound is tight in order but becomes vacuous (exceeds 1) once
`L - k + 1 > b^k`; §4 remedies this with a complementary lower bound.

---

## 3. Coincidence and the trivial ceiling

**Theorem 5 (`prob_pair_coincide`).** Two independent uniform volumes coincide with
probability exactly `b^(-L)`:
`prob(Library b L × Library b L, {(u,w) : u = w}) = b^(-L)`.

*Proof sketch.* The product sample space has `b^L · b^L = b^{2L}` points. The
diagonal `{(u,w) : u = w}` is the image of the injection `v ↦ (v, v)` and so has
`b^L` points. Therefore `prob = b^L / b^{2L} = b^(-L)`. Edge cases `b = 0` and
`L = 0` are treated separately. ∎

**Proposition D (`prob_le_one`).** For any finite type `α`, sample set `s`, and event
`A`, `prob(s, A) ≤ 1`.

*Proof sketch.* `#(s ∩ A) ≤ #s`, so the ratio is at most 1 (with the usual
convention when `#s = 0`). Though elementary, this guards every probability
statement and the limit argument in §5. ∎

---

## 4. The disjoint-block count and the two-sided estimate

The union bound (Theorem 4) is one-directional. To bound the containment
probability *from below* we exploit independence of disjoint blocks.

### 4.1 Aligned blocks

Set `m = ⌊L/k⌋`. Partition the positions `{0,…,L-1}` into `m` consecutive,
non-overlapping *aligned blocks* of length `k`, namely block `t` occupying positions
`{t·k, …, t·k + k - 1}` for `t ∈ Fin m`, followed by a *remainder* of
`L - m·k` free positions.

**Definition (`NoAlignedBlockMatch`).** A volume `v` *has no aligned block match* if
for every `t ∈ Fin m`, the pattern does **not** occur at position `t·k`:
`∀ t, ¬ OccursAt(p, v, t·k)`.

### 4.2 The reindexing bijection

**Definition (`blockEquiv`).** Given a proof `h : m·k + (L - m·k) = L`, there is a
bijection
`blockEquiv : Volume b L ≃ ((Fin m → Fin k → Fin b) × (Fin (L - m·k) → Fin b))`
re-reading a volume as its `m` blocks together with its remainder. It is assembled
from the standard product/sum/curry equivalences (`finProdFinEquiv`,
`finSumFinEquiv`, `Equiv.curry`).

**Lemma (`blockEquiv_fst_apply`, `blockEquiv_index`).** Under `blockEquiv`, the
symbol of block `t` at offset `j` is the original symbol at position `t·k + j`; the
underlying index is exactly `t·k + j`.

These identities make the bijection *position-aware*: it is not an abstract
counting trick but an explicit dictionary between coordinates.

**Lemma F (`noAligned_iff`).** If `k > 0` and `h : m·k + (L - m·k) = L`, then
`NoAlignedBlockMatch(p, v)` holds iff every block of `blockEquiv(v)` differs from
`p`: `∀ t, (blockEquiv v).1 t ≠ p`.

*Proof sketch.* By `blockEquiv_index`, `OccursAt(p, v, t·k)` is precisely the
statement that block `t` equals `p` coordinate-by-coordinate; negating and
quantifying over `t` gives the equivalence. ∎

### 4.3 Counting avoiders

**Lemma E (`card_avoid`).** The number of `m`-tuples of length-`k` blocks none of
which equals a fixed pattern `p` is `(b^k - 1)^m`:
`#{ g : Fin m → (Fin k → Fin b) | ∀ t, g(t) ≠ p } = (b^k - 1)^m`.

*Proof sketch.* The constrained set is the product `∏_{t} (univ \ {p})`. Each factor
has `b^k - 1` elements, and there are `m` independent factors. ∎

**Theorem 6 (`card_noAlignedBlockMatch`).** If `k > 0`, the number of volumes with
no aligned block match is exactly
`#{ v : NoAlignedBlockMatch(p, v) } = (b^k - 1)^(⌊L/k⌋) · b^(L - ⌊L/k⌋·k)`.

*Proof sketch.* Transport the avoider set across `blockEquiv` (Lemma F): a volume
avoids the pattern on every aligned block iff its block-component is a pattern-free
`m`-tuple (counted by Lemma E, giving `(b^k-1)^m`) and its remainder-component is
arbitrary (giving `b^(L-m·k)`). Since `blockEquiv` is a bijection, the counts
multiply. ∎

### 4.4 Lower bound and the sandwich

**Theorem 7 (`prob_contains_substring_lower_bound`).** The containment probability
satisfies
`prob(Library b L, {v : Contains(p, v)}) ≥ 1 - (1 - b^(-k))^(⌊L/k⌋)`.

*Proof sketch.* Containment is implied by *some* aligned block matching; hence the
non-containment event is contained in `NoAlignedBlockMatch`. By Theorem 6 and
Theorem 1, the probability of no aligned match is
`(b^k - 1)^m · b^(L-mk) / b^L = ((b^k-1)/b^k)^m = (1 - b^(-k))^m`,
with `m = ⌊L/k⌋`. Complementing gives the lower bound. (The inclusion is
one-directional and exact — no inclusion–exclusion is needed, because "some aligned
block matches" is a *subset* of "contains.") ∎

Combining Theorems 4 and 7 sandwiches the containment probability:
```
1 - (1 - b^(-k))^(⌊L/k⌋)  ≤  P(Contains)  ≤  (L - k + 1) · b^(-k).
```
The left bound is always a genuine probability in `[0,1]` and non-vacuous for all
`L`; the right bound is sharp for small `L` but vacuous for large `L`.

---

## 5. Borges completeness

**Theorem 8 (`prob_contains_tendsto_one`).** For any alphabet of size `b ≥ 2` and
fixed pattern `p` of length `k ≥ 1`, the containment probability tends to 1 as the
book length grows:
`lim_{L→∞} prob(Library b L, {v : Contains(p, v)}) = 1`.

*Proof sketch.* Since `b ≥ 2` and `k ≥ 1`, we have `0 ≤ 1 - b^(-k) < 1`, and
`⌊L/k⌋ → ∞` as `L → ∞`. Hence `(1 - b^(-k))^(⌊L/k⌋) → 0`, so the lower bound of
Theorem 7 tends to 1; with Proposition D bounding the probability above by 1, the
squeeze theorem forces the limit to be exactly 1. ∎

This is the rigorous form of Borges' fantasy: any fixed text — a poem, a contract,
a complete and correct proof — almost surely appears inside a sufficiently long
random volume. Length alone, not design, forces the appearance.

---

## 6. The catalog question

Borges' librarians seek a single "total book" cataloging the locations of all
others. An information-theoretic counting argument refutes its existence and
quantifies a distributed alternative.

To address one of `b^L` volumes requires `log₂(b^L) = L·log₂ b` bits. A single
volume carries `L` symbols, i.e. `L·log₂ b` bits — exactly enough to name *one*
other volume. Since `b^L ≫ L·log₂ b`, no single volume can encode the addresses of
all `b^L` volumes: the complete catalog is logically impossible (a clean diagonal/
counting obstruction).

A *distributed* catalog over `N` volumes carries `N·L·log₂ b` bits and suffices once
`N > b^L / (L·log₂ b)`. The library can thus catalog itself collectively, never
individually — the precise mathematical residue of Borges' melancholy.

*(The catalog discussion is contextual and uses only the cardinality
`#(Library b L) = b^L` of Theorem 1; the inequality is an information-theoretic
counting observation rather than one of the formalized theorems above.)*

---

## 7. Algorithms

### 7.1 Exact containment probability via disjoint blocks (mini-Library)

For modest `b, L, k` the sandwich bounds and even the exact non-containment count
are directly computable. The exact probability of *no aligned block match* is
`(1 - b^(-k))^(⌊L/k⌋)`, and the lower/upper sandwich bounds follow in `O(1)`
arithmetic operations (with big-integer powers). For tiny libraries one may also
enumerate all `b^L` volumes and count containment exactly, validating the bounds.

### 7.2 De Bruijn catalog for a mini-Library

A de Bruijn sequence `B(b, n)` is a cyclic string over `b` symbols in which every
length-`n` word appears exactly once as a contiguous substring; its length is `b^n`.
It provides an optimal "catalog" in the sense that a single sweep enumerates all
`b^n` words. For the mini-Library with `b = 4`, taking `n` so that `b^n` matches the
book length yields a compact traversal of all length-`n` patterns. The greedy
"prefer-largest" (Martin) construction builds such a sequence in linear time in its
output length.

---

## 8. Applications

The Library of Babel is the canonical model of a fixed-size *information space*, and
the theorems transfer verbatim:

- **Genomics.** Theorem 3 is the expected number of occurrences of a fixed motif of
  length `k` in random DNA (`b = 4`).
- **Cryptography.** Theorem 2 is the guessing probability of a fixed key of length
  `L`; Theorem 4 bounds the chance a short pattern appears in a random keystream.
- **Probabilistic combinatorics.** The disjoint-block method (Theorems 6–8) is the
  standard route to "a random word almost surely contains any fixed factor."
- **Information theory.** §6 is the source-coding bound: no fixed-length codeword
  can index a strictly larger message set.

---

## 9. Future directions

**Conjecture 1 — Two-sided sandwich and sharp asymptotics.** For fixed `b ≥ 2`,
`k ≥ 1`, the bounds give `1 - (1 - b^(-k))^(⌊L/k⌋) ≤ P_L(contains) ≤ (L-k+1)·b^(-k)`.
Conjecture: `P_L(contains) = 1 - exp(-(L-k+1) b^(-k)) + o(1)` in the regime
`L·b^(-k) → λ` (a Poisson/Chen–Stein limit for the occurrence count). A milestone is
a total-variation bound between the occurrence count and `Poisson(λ)` via Chen–Stein
on the dependency graph of overlapping windows.

**Conjecture 2 — Variance and a second-moment lower bound.** With `V_L(p) =
Var(occurrenceCount)`, conjecture `V_L(p) = (L-k+1)b^(-k)(1-b^(-k)) + 2·Σ_{1≤d<k}
(overlap correlation term)`, the overlap terms governed by the border/period
structure of `p`. Paley–Zygmund then yields a mean/variance lower bound valid for
all `L`.

**Conjecture 3 — Pattern autocorrelation governs clustering.** Patterns with
nontrivial self-overlap (e.g. `aa…a`) cluster occurrences, inflating variance.
Conjecture: among length-`k` patterns the overlap-free ("bifix-free") patterns
minimize `Var(occurrenceCount)` and maximize `P(contains)` for every `L`. Introduce
a `correlationPolynomial` and prove monotonicity of variance in its coefficients.

**Conjecture 4 — Coupon-collector for the whole library.** Let `T` be the number of
i.i.d. uniform volumes drawn until every one of the `b^L` volumes appears at least
once. Conjecture `E[T] = b^L · H_{b^L}` and `T/(b^L log b^L) → 1` in probability —
the classical coupon collector at `N = b^L`.

**Conjecture 5 — Distinct k-grams in a single volume.** Let `D_L` be the number of
distinct length-`k` substrings in a random volume of length `L`. Conjecture
`E[D_L] = b^k(1 - (1 - b^(-k))^(L-k+1)) + correction` and `D_L/b^k → 1` once
`L ≫ k·b^k` — a single sufficiently long volume already realizes essentially the
entire `k`-gram universe.

---

## 10. Conclusion

The Library of Babel, formalized as the uniform space of all length-`L` strings over
`b` symbols, admits a complete and exact elementary theory. It contains `b^L`
volumes, each with probability `b^(-L)`; a fixed length-`k` pattern occurs
`(L-k+1)·b^(-k)` times on average; and the containment probability is sandwiched
between `1 - (1 - b^(-k))^(⌊L/k⌋)` and `(L-k+1)·b^(-k)`. The lower bound, proved via
an explicit position-aware block-reindexing bijection, forces containment to be
asymptotically certain — the mathematical realization of Borges' dream that every
text, somewhere, already exists.
