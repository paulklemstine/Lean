# Computational evidence for the symmetry dichotomy of attention architectures

All numbers below were produced by exact rational (`ℚ`) computation in Lean 4 (`#eval`) before
the formal proofs in
`Catalog/MachineLearning/TransformerUniversality/PermutationDichotomy.lean` were written.  They
are *evidence*, not verification; every claim that appears as a theorem in the catalog is proved
there with 0 sorries.

## 1. Group averaging collapses readouts to uniform pooling

Symmetrizing the weight vector `w` of a linear attention readout over all 6 permutations of a
3-token sequence (`symW w = (1/6) ∑_σ w ∘ σ`):

| input `w`  | symmetrized weights |
|------------|---------------------|
| `[1,0,0]`  | `[1/3, 1/3, 1/3]`   |
| `[2,0,0]`  | `[2/3, 2/3, 2/3]`   |
| `[1,2,3]`  | `[2, 2, 2]`         |

Observation that shaped the formalization: the symmetrization of a *single* readout is always a
uniform-attention (mean-pooling) readout, i.e. the linear part of the symmetric class is only
one-dimensional per feature.  Hence the invariant class can only be rich because of the
*multiplicative* (feed-forward / gating) structure of the algebra — this is why the positive
half of the dichotomy is proved for the subalgebra `attentionAlgebra`, not for readouts alone,
and why the averaging step is applied *after* Stone–Weierstrass rather than before.
Formal counterparts: `symmetrize_mem`, `symmetrize_invariant`, `softmaxHeadRead_zero_scores`.

## 2. The orbit barrier is exactly 1/2 for position reading

Target `g x = x 0` (read the first token), input `u = (1,0,0)`, orbit under `S_3`:

* values of `g` on the orbit: `[1, 1, 0, 0, 0, 0]`;
* half oscillation `(max − min)/2 = 1/2`;
* errors of the best invariant (constant midpoint `1/2`) model on the orbit:
  `[1/2, 1/2, 1/2, 1/2, 1/2, 1/2]`.

So the lower bound `1/2` is met with equality by a constant model: the barrier is *sharp*, not
merely a bound.  Formal counterparts: `orbit_barrier_lower`, `orbit_barrier_attained`,
`symmetry_barrier_position_read`.

## 3. Relative (cyclic) symmetry has the same barrier

For a 4-token sequence with the cyclic shift `r` and `u = (1,0,0,0)`, the values of `g x = x 0`
along the cyclic orbit are `[1, 0, 0, 0]`: oscillation 1, barrier `1/2` again.  A shift-invariant
(relative positional encoding) model is therefore just as unable to read an *absolute* position
as a fully permutation-symmetric one.  This suggested proving the barrier for a *single*
permutation that moves the queried position, which is the form
`symmetry_barrier_position_read` actually takes, and motivated generalizing the positive half
from `S_ι` to an arbitrary finite symmetry group (`group_uniform_universal`,
`shift_uniform_universal`).

## 4. Counterexample hunt

We looked for an invariant functional separating two sequences that differ only by a
permutation; by construction none exists, and the search instead produced the two-point
certificate `u = (1,0,…,0)` versus `σ · u` used in the Lean proof.  No counterexample to any
stated theorem was found; the one *failed* conjecture of the cycle (that linear readouts alone,
without the multiplicative mixing, already give the symmetric universality) is refuted by
table 1 above: symmetrized readouts span a one-dimensional space per feature, so they cannot
approximate, e.g., the invariant functional `x ↦ ∑_i (x_i)²`.

## 5. No OEIS sequence

No integer sequence arises in this development (the objects are function algebras and
approximation constants), so no OEIS lookup applies.
