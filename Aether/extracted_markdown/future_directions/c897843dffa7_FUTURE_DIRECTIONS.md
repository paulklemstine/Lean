# Future Directions: Tropicalized Berggren Dynamics

The file `Catalog/Bridges/TropicalBerggrenAutomaton.lean` establishes a min-plus
automaton shadowing the classical Berggren tree of primitive Pythagorean triples.
It proves functoriality of tropical evaluation (`tropEval_append`), a canonical
affine form (`tropEval_canonical`), a two-sided comparison bracketing the classical
hypotenuse between `5·3^(countB w)` and `5·7^(w.length)` (`tropical_certifies_height`),
a certified branch-pruning guarantee (`branch_pruning`), and the real-logarithm
form of the bridge (`log_hyp_lower`, `log_hyp_upper`). It also pins down where the
tropical lower bound is lossy (`tropical_lower_not_tight`). The following directions
push this bridge from a coarse two-sided bracket toward a *tight* tropical model.

## 1. A tight piecewise-linear tropical model via the dominant-leg coordinate

The current lower bracket counts only `B`-generators because `A` and `C` can grow the
hypotenuse by a factor arbitrarily close to `1`. Conjecture: tracking the *full*
log-vector `(log a, log b, log c)` under a genuine min-plus 3×3 matrix recursion
(one affine piece per sign pattern of the Berggren matrices) reproduces the classical
hypotenuse up to a uniformly bounded additive error `≤ log 7`, with the error attained
only on a measure-zero set of branch sequences.

The key insight is that the growth factor of `A` and `C` is governed by the *ratio*
of the two legs, which is exactly the data a piecewise-linear (tropical) map records
in its choice of dominant affine piece — so the loss in the scalar `countB` model is
precisely the projection that forgets which leg dominates. Why now? We already have
the exact per-generator inequalities `actGen_hyp_ge`, `actGen_hyp_B_ge`,
`actGen_hyp_le_7` and the catalog's `mpMatVecMul` / `TropicalLightCone` machinery in
`BerggrenTropicalBridge`, so the vector-valued recursion can be assembled from
verified pieces rather than from scratch.

## 2. Exact tropical recovery of the Lorentz height

Replace the Euclidean hypotenuse by the Lorentz height `c² - a² - b² = 0` data and
its perturbations. Conjecture: there is a tropical (max-plus) linear functional `h`
on the log-state such that `h(tropEval w s0)` equals `⌊log_φ⌋` of the Lorentz
co-height for an explicit base, *exactly* (no error term), because the Berggren
matrices act as exact isometries of the Lorentz form.

The key insight is that exactness should come from the Lorentz-preservation identities
`Bᵀ Q B = Q` (catalog `berggren_*_preserves_lorentz`): an invariant quadratic form
tropicalizes to an invariant *linear* form, and invariants are exactly where
tropicalization is lossless. Why now? The Lorentz-preservation theorems are already
proven in `BerggrenTropicalBridge`, and our `evalWord_preserves_good` shows the
Pythagorean invariant survives every step, so the linear invariant is within reach.

## 3. Sharp tropical complexity of certified enumeration

Our `branch_pruning` proves soundness: a tropical certificate over `N` excludes a whole
subtree. Conjecture: the resulting branch-and-bound search visits at most
`O(N^{log_3 7})` nodes to enumerate all triples of hypotenuse `≤ N`, and this exponent
`log_3 7 ≈ 1.77` is optimal, matching the ratio of the upper (base 7) and lower (base 3)
tropical bases proven here.

The key insight is that the *gap* between the two tropical bases `7` and `3` — not the
classical arithmetic — controls the pruning efficiency, so the search complexity is a
purely tropical quantity readable off `tropical_certifies_height`. Why now? With both
brackets formalized and `candidateWordSet_finite` already in the catalog, the node-count
bound becomes a counting argument over words with bounded `countB` and bounded length.

## 4. Tropical fingerprints and collision resistance

Combine the tropical automaton with the cryptographic fingerprint rigidity of
`Cryptography/BerggrenFingerprintRigidity.lean`. Conjecture: the tropical state
`tropEval w (0,0) = (countB w, w.length)` is a *complete* invariant of a word's
hypotenuse magnitude class but a *deliberately lossy* fingerprint of the word itself,
and the number of words sharing a tropical fingerprint of budget `(k, n)` is exactly
`C(n, k)`, giving an exact tropical collision count.

The key insight is that tropicalization is precisely the controlled information loss a
fingerprint needs: it forgets generator order while preserving the multiset type, so the
collision structure is the binomial lattice. Why now? `tropEval_canonical` already proves
the state is `(countB, length)`, reducing the conjecture to a clean enumerative identity
that the existing rigidity lemmas can anchor.

## 5. Min-plus spectral radius and asymptotic growth rate

Conjecture: the almost-sure exponential growth rate of the hypotenuse along a *random*
infinite Berggren branch (each generator i.i.d. uniform) equals the min-plus Lyapunov
exponent of the three tropical affine pieces, an explicit algebraic number strictly
between `log 3` and `log 7`, and equal to `(2 log 3 + log 7)/3` in the symmetric model.

The key insight is that the random product of tropical (min-plus) matrices has a
Furstenberg-type deterministic Lyapunov exponent even though the classical random matrix
product does not factor, because in min-plus algebra the log-growth is additive along the
chosen dominant pieces. Why now? Our additive `log_hyp_lower`/`log_hyp_upper` already give
the deterministic envelope `[countB·log3, length·log7]`; promoting it to an i.i.d. law of
large numbers is the natural probabilistic next step, with the bracket constants as the
proven extreme cases.
