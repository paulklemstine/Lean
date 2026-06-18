# Future Directions — The Hodge Conjecture for Neural Networks

Derived from the cycle in `NeuralHodgeConjecture.lean` and `NeuralHodgeCatalogLink.lean`,
which proved:

* `pl_hodge_decomposition` / `pl_hodge_span`: every PL chain on a ReLU decision surface is
  a `ℤ`-combination of hyperplane sections (the "trivial existence half" of the Hodge
  conjecture for these surfaces);
* `regionBound_recurrence`, `regionBound_le_two_pow`, `regionBound_eq_two_pow`,
  `regionBound_mono_width`: the Zaslavsky region/Betti budget `Σ_{i≤n} C(m,i)` for one
  ReLU layer, with its Pascal recurrence and the `2^m` ceiling;
* `reluHodge_totalBetti` (and its catalog avatar `reluHodgeDiamond_totalDim_eq`): the
  extremal total Betti number of a ReLU decision surface is **exactly** `2^{w₁}·2^{wL}·mid`.

---

## Conjecture 1 — Sharpness of the `2^{w₁+wL}` Betti ceiling

The total Betti number of a ReLU decision surface with first/last hidden widths `w₁, wL`
and middle-width product `mid` is **at most** `2^{w₁}·2^{wL}·mid`, and this is attained by
a generic-weight network in input dimension `n ≥ w₁ + wL`.

**The key insight is** that `reluHodge_totalBetti` computes the *saturated* diamond exactly
as `2^{w₁}·2^{wL}·mid`, while `regionBound_eq_two_pow` shows the per-layer count saturates
to `2^m` precisely when the ambient dimension is large; combining the two layers should turn
the upper bound into an equality in high dimension.

**Why now?** Both halves (exact saturated value, dimensional saturation of one layer) are
now formal lemmas in this file, so the remaining work is purely the genericity/transversality
argument, which is decoupled from the combinatorics.

## Conjecture 2 — A Künneth product law for stacked ReLU blocks

For a composition of two ReLU sub-networks the total Betti number is *sub-multiplicative*:
`B(f ∘ g) ≤ B(f) · B(g)`, with equality when the blocks are in "general position".

**The key insight is** that `reluHodge_totalBetti` already factors as a product
`(Σ_p C(w₁,p))·(Σ_q C(wL,q))·mid` via `Finset.sum_mul_sum`; the same factorisation engine
should govern how Betti budgets multiply across composition boundaries.

**Why now?** The factored form is exactly the proof structure used for
`reluHodge_totalBetti`, so the product law is a structural generalisation of an
already-formalised identity rather than a new technique.

## Conjecture 3 — The Zaslavsky recurrence is the unique solution to depth refinement

Any width-monotone, dimension-graded region count satisfying
`R(m+1,n+1) = R(m,n+1) + R(m,n)` with `R(0,n)=1` equals `regionBound`, hence the
binomial-sum formula is forced by adding one neuron at a time.

**The key insight is** that `regionBound_recurrence` together with `regionBound_mono_width`
pins down a two-variable Pascal-type recurrence whose only solution is `Σ_{i≤n} C(m,i)`;
uniqueness should follow by double induction.

**Why now?** The recurrence and monotonicity are both proved here, so the conjecture reduces
to a uniqueness-of-recurrence argument with no missing analytic input.

## Conjecture 4 — Algebraic-cycle rank lower bound via the catalog Euler characteristic

Through `reluHodgeDiamond` the decision surface acquires a catalog `HodgeDiamond`, hence an
Euler characteristic `eulerChar`; we conjecture `|eulerChar| ≤ reluTotalBetti` with the gap
measuring the number of *independent* algebraic cycles needed to represent all classes.

**The key insight is** that `reluHodgeDiamond_totalDim_eq` already lands the surface inside
the catalog's `HodgeEPolynomial` machinery, where `eulerChar` and `totalDim` are defined on
the same diamond, so their comparison is a direct two-sum inequality.

**Why now?** The bridge `NeuralHodgeCatalogLink.lean` makes both invariants available on one
object for the first time, so the inequality can be stated and attacked without rebuilding
any Hodge-diamond infrastructure.
