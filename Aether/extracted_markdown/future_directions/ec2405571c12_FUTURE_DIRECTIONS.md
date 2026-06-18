# Future Directions: Reversible Computing and Thermodynamic Efficiency

The file `Computation/ReversibleAncillaBound.lean` proves a sharp min–max
characterization of the ancilla overhead of reversible simulation:
`revAncilla_isLeast` shows that `maxFiberSize f` is the *least* size of any
auxiliary register `Fin n` admitting an injective `g : α → β × Fin n` with
`(g a).1 = f a`. This pairs the constructive upper bound
`exists_revAncilla_maxFiber` with the strengthened lower bound
`revAncilla_lower_bound` (which improves the catalog's
`rev_witness_aux_lower_bound` from a bijection to a mere injection). The
corollaries `injective_iff_maxFiberSize_le_one`, `revAncilla_one_of_injective`,
and `maxFiberSize_const` situate the bound between the reversible extreme
(injective maps, one ancilla state) and the maximally irreversible extreme
(fully collapsing maps, `n` ancilla states). The directions below extend this
sharp result.

## 1. Bits, not states: the logarithmic ancilla bound

Our theorem measures ancilla in *states* (`Fin (maxFiberSize f)`), but the
physically meaningful quantity is *bits*, `⌈log₂ (maxFiberSize f)⌉`. The natural
strengthening states that the least `m` for which there is an injective
`g : α → β × (Fin 2)^m` with first component `f` equals exactly
`⌈log₂ (maxFiberSize f)⌉`.

The key insight is that packing the per-fiber index into a Boolean register only
costs the ceiling of its logarithm, and `revAncilla_isLeast` already pins the
state count, so the bit count is its base-2 logarithm rounded up — no new
combinatorics is needed, only the monotone bridge between `Fin k` cardinalities
and Boolean cubes. Why now? We have the exact state-count theorem in hand, and
Mathlib's `Nat.clog 2` together with `Nat.clog_le_iff` / `Nat.le_pow_clog`
provides the rounding API to convert `IsLeast` over state counts into `IsLeast`
over bit counts directly.

## 2. Sub-additivity of ancilla under composition

The catalog's `RevWitness.compose` multiplies auxiliary spaces, but the *minimal*
ancilla should behave sub-additively: `maxFiberSize (g ∘ f) ≤ maxFiberSize f ·
maxFiberSize g`, and in bit terms `ancillaBits (g ∘ f) ≤ ancillaBits f +
ancillaBits g`. Moreover this is sometimes strict, so reuse of intermediate
history can save ancilla.

The key insight is that a fiber of `g ∘ f` over `c` is the disjoint union, over
`b ∈ g⁻¹(c)`, of the `f`-fibers over `b`, so its size is bounded by the largest
`f`-fiber times the number of contributing `b`'s, which is at most
`maxFiberSize g`. Why now? `revAncilla_isLeast` turns these fiber inequalities
into statements about the *minimal* register sizes, letting us phrase composition
laws intrinsically rather than through a particular witness; the disjoint-union
fiber decomposition is already expressible via `Equiv.sigmaFiberEquiv`, used in
`exists_revAncilla_maxFiber`.

## 3. Strict entropy drop and the Landauer floor are the same `maxFiberSize`

The catalog connects irreversibility to `infoErased f = log₂|α| − log₂|image f|`
and proves `landauer_gap_nonneg`. We conjecture a refined, *pointwise* law: the
minimal ancilla `maxFiberSize f` controls the largest possible Shannon-entropy
drop, namely `max_p (H(p) − H(f_* p)) = log₂ (maxFiberSize f)`, achieved by the
distribution uniform on a maximal fiber.

The key insight is that entropy lost by `f` on a distribution supported in a
single fiber of size `k` is exactly `log₂ k`, and no distribution can lose more
than the logarithm of the largest fiber; thus the *worst-case* Landauer cost and
the *minimal reversibility* ancilla are two readings of the same invariant
`maxFiberSize f`. Why now? We have `maxFiberSize` characterized exactly and the
catalog's `infoErased` / `landauerGap` already in place; Mathlib's
`Real.negMulLog` and finite `Finset.sum` entropy let us state the per-fiber
entropy drop without measure-theoretic machinery.

## 4. Reversible circuits realize the optimal ancilla over the Boolean cube

For Boolean functions `f : (Fin 2)^n → (Fin 2)^n` the abstract optimum
`maxFiberSize f` should be *realizable* by an actual reversible circuit: there is
a Toffoli/CNOT circuit on `n + ⌈log₂ (maxFiberSize f)⌉` wires whose restriction
computes `f` in the first `n` wires. This upgrades `exists_revAncilla_maxFiber`
from an existence-of-injection statement to existence-of-circuit.

The key insight is that the injection built in `exists_revAncilla_maxFiber`
factors through `Equiv.Perm ((Fin 2)^(n+m))`, and any permutation of a Boolean
cube decomposes into Toffoli gates (Toffoli universality), so the optimal ancilla
count is met by a concrete gate list, not merely by an abstract bijection. Why
now? The catalog already formalizes the Toffoli and Fredkin gates and the group
structure of `Equiv.Perm`; bridging `exists_revAncilla_maxFiber` to a `List` of
gates connects our optimum to physically buildable hardware.

## 5. Average-case ancilla and the fiber-size distribution

Worst-case ancilla is `maxFiberSize f`, but a *typical* input sits in a fiber far
smaller than the maximum. We conjecture an average-case companion: the expected
ancilla bits needed to disambiguate a uniformly random input equal the conditional
entropy `H(input | output) = (1/|α|) ∑_b |f⁻¹(b)| · log₂ |f⁻¹(b)|`, and this is
always `≤ log₂ (maxFiberSize f)` with equality iff all nonempty fibers have equal
size.

The key insight is that `revAncilla_lower_bound` is a max over fibers, whereas the
amortized cost is the fiber-size-weighted average of `log₂` of fiber sizes, so the
gap between worst- and average-case reversibility is exactly the spread of the
fiber-size distribution. Why now? The fiber-counting identity `fiber_card_sum`
from the catalog gives the normalization `∑_b |f⁻¹(b)| = |α|`, and our
`fiber_card_le_maxFiberSize` supplies the term-by-term bound, so the average-case
inequality is a weighted-average-versus-max argument over data we have already
formalized.
