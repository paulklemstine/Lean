# FUTURE DIRECTIONS — Berggren–Lorentz Certificates for Lattice Reduction

Follow-up conjectures arising from `Catalog/Bridges/BerggrenLatticeReduction.lean`,
which recast the inverse Berggren generators as a terminating reduction algorithm
on the hyperbolic lattice ℤ³ with Lorentz form `Q(a,b,c) = a² + b² − c²`.

What is already proved (this cycle):
- Universal hypotenuse descent: `0 < hypReduce a b c < c` for every positive-leg
  Pythagorean triple, where `hypReduce a b c = 3c − 2a − 2b` is the common third
  coordinate of all three inverse children (`hypReduce_descent`).
- A strict natural-number termination measure `c.toNat` (`reduceStep_toNat_lt`).
- Per-branch admissibility lemmas keyed on the signs of the selectors
  `p = a + 2b − 2c`, `q = 2a + b − 2c` (`invChild{A,B,C}_admissible`).
- The inverse generators are genuine mutual inverses of the Berggren children and
  preserve both `Q` and the Pythagorean predicate.

## C1. Global reachability with logarithmic certificate length
**Conjecture.** For every *primitive* Pythagorean triple `(a,b,c)` there is a
unique finite word `w ∈ {A,B,C}*` of length `|w| ≤ K · log c` (for an absolute
constant `K`) such that iterating the branch-selected reduction
`parentOf` (chosen by the sign pattern of `(p,q)` as in the admissibility
lemmas) drives `(a,b,c)` to the apex ray `(1,0,1)`.
**Testable kernel:** define `parentOf : ℤ³ → ℤ³` via the `(p,q)` sign case-split,
prove it preserves primitivity and positivity off the apex, and prove the
`c.toNat` measure strictly decreases each step (the contraction part is already
`hypReduce_descent`). The missing piece is positivity/primitivity preservation.

## C2. Exact-uniqueness of the reduction branch
**Conjecture.** Off the apex, the four sign cases of `(sign p, sign q)` partition
all positive-leg primitive triples so that *exactly one* of `invChildA/B/C`
returns a positive-leg triple, and the degenerate case `p ≤ 0 ∧ q ≤ 0` occurs
**only** at the apex `(1,0,1)` (up to leg swap). This would make the Berggren tree
a deterministic free trie and the reduction a perfect inverse of growth.

## C3. Quantitative depth bound 5^d ≤ c < ... and certificate compression
**Conjecture.** If `(a,b,c)` sits at depth `d` in the Barning–Hall tree then
`5^d ≤ c` (sharpening the `hypB_pythag_lower : 5c < hypB` growth bound from
`Core.lean`). Consequently a reduction certificate has length `≤ log₅ c`,
giving an `O(log c)`-bit witness for orbit membership — a concrete cryptographic
certificate-compression statement bridging to
`Cryptography/NoetherianCertification.lean`.

## C4. Hyperbolic reducedness ≈ LLL-reducedness
**Conjecture.** Call a triple **Lorentz-reduced** when no inverse generator
strictly decreases `c` while keeping legs positive (equivalently `p ≤ 0 ∧ q ≤ 0`).
Then the Lorentz-reduced triples are exactly the apex orbit, and the predicate is
the hyperbolic analogue of a size-reduced / Gauss-reduced lattice basis. Formalize
a `LorentzReduced` predicate and prove it is preserved under no further descent,
mirroring the LLL invariant.

## C5. Spectral contraction rate of the reduction operator
**Conjecture.** The inverse generators all share dominant contraction governed by
the smallest eigenvalue of `matB` (trace 5, the unique det = −1 generator). Make
precise: along any reduction path the ratio `c_{k+1}/c_k` is bounded above by a
constant `< 1` determined by the spectral radius of the inverse generators, giving
*geometric* (not merely strict) descent. This connects the `trace`/eigenvalue
results in `Core.lean` to a Lyapunov-style convergence rate for the reduction.
