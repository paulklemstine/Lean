# Future Directions: Berggren Tree Descent and Pythagorean Lattice Cryptography

## 1. Completeness of the Berggren Tree via Descent Normal Forms

The descent algorithm established in `BerggrenDescentAlgorithm.lean` proves that
every non-root primitive Pythagorean triple has a parent with strictly smaller
hypotenuse. The natural next step is to prove that every primitive triple with
a odd and b even lies in the Berggren tree — that is, iterated descent always
reaches (3,4,5), not just a triple with c < 5.

**The key insight is** that combining `descent_natAbs_lt` with `pyth_c_ge_5`
(c ≥ 5 for all primitive triples) and `root_unique_c5` (c = 5 forces the root)
gives a complete proof of Berggren tree membership, provided one additionally
shows that each inverse Berggren map preserves coprimality and parity. The
coprimality preservation is already established in `BerggrenLatticeReduction/Core.lean`
for the forward direction; the inverse direction should follow from the same
gcd-divisibility argument run in reverse.

**Why now?** All the pieces are in the catalog: `parent_c_pos`, `parent_c_lt`,
`descent_natAbs_lt`, `boundary_2a_b_eq_2c`, and the coprimality/parity proofs
for forward steps. Assembling them into a full termination proof is a mechanical
(if tedious) exercise.

## 2. Uniqueness of Berggren Words (Normal Form Theorem)

The forward-inverse roundtrip theorems (`fwdU_invU`, etc.) show that each
Berggren generator is injective. Combined with the three-way case analysis
(`case4_impossible` eliminates the fourth case), this should yield a uniqueness
theorem: every primitive Pythagorean triple has a unique Berggren word.

**The key insight is** that the case analysis on the signs of `a + 2b - 2c` and
`2a + b - 2c` is deterministic — for any non-root triple, exactly one of the
three inverse maps produces all-positive output, so the parent step is uniquely
determined. By induction on `c.natAbs`, the entire reduction path is unique.

**Why now?** The `invU_pos`, `invA_pos`, `invD_pos` theorems already establish
which inverse map is valid in each case. What remains is to show that the other
two maps necessarily produce a non-positive component (this is essentially the
negation of the positivity conditions in the other cases).

## 3. Cryptographic Separation via Lorentz Fingerprints

The Lorentz invariance theorems (`invU_lorentz`, `fwdA_lorentz`, etc.) show that
Q(a,b,c) = a² + b² − c² is preserved by all Berggren maps. For Pythagorean
triples, Q = 0. A natural cryptographic application is to define a "Lorentz
fingerprint" for Berggren words by evaluating them on non-Pythagorean inputs
(Q ≠ 0) and using the resulting Q-value as a collision-resistant hash.

**The key insight is** that distinct Berggren words applied to a non-light-cone
vector should produce distinct outputs (since the Berggren semigroup acts freely
on ℤ³, which is already partially established in `BerggrenFingerprintRigidity.lean`).
The Lorentz form provides a polynomial invariant that distinguishes orbits.

**Why now?** The Lorentz invariance is fully proved, and the freeness of the
semigroup action is established in the catalog. Combining these gives a
constructive collision-resistance theorem.

## 4. Quantitative Descent Bounds and Tree Depth Complexity

The descent measure `c.natAbs` decreases at each step, but by how much?
The parent hypotenuse satisfies `c' = 3c − 2(a+b)`, and we showed
`0 < c' < c`. A tighter bound would be: `c' ≤ c/√2` (since
`4(a+b)² ≥ 4c² + 4` for non-trivial triples). This would give a logarithmic
depth bound: the Berggren tree has depth at most `O(log c)`.

**The key insight is** that `c' = 3c − 2(a+b)` and `(a+b)² = c² + 2ab ≥ c² + 2`
(for a,b ≥ 1) give `a+b ≥ √(c²+2) > c`, so `c' < c`. But more precisely,
`(a+b) ≥ c + 1/(a+b)` which gives `c' ≤ c − 2/(a+b)`, a weak bound.
The conjectured `c' ≤ c/√2` would follow from `a+b ≥ c(3−√2)/2`.

**Why now?** The basic descent is proved. Tightening the bound would connect
to the exponential growth of the tree (3^d nodes at depth d) and provide
concrete security parameter estimates for lattice cryptography.

## 5. Berggren Descent as a Lattice Reduction Algorithm

The descent algorithm can be viewed as a lattice reduction procedure: given a
vector v = (a,b,c) on the Lorentz light cone, iteratively apply inverse Berggren
maps to reduce it to the shortest vector (3,4,5). This is analogous to the
Euclidean algorithm reducing fractions, or LLL reducing lattice bases.

**The key insight is** that the Berggren matrices generate the full stabilizer
of the light cone in O(2,1;ℤ), and the descent algorithm computes the unique
factorization of a group element into generators — exactly the word problem for
this group. This transforms the abstract algebraic word problem into a concrete
polynomial-time algorithm with certified correctness.

**Why now?** The descent is proved terminating, and the Lorentz group structure
is well-established in the catalog (`BerggrenLatticeCryptography.lean`,
`BerggrenDiophantineLattice.lean`). The connection to lattice reduction would
unify these separate developments into a single algorithmic framework.
