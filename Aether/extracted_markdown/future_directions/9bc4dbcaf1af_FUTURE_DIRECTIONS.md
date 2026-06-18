# Future Directions: Spectral Geometry of Berggren Quantum Walks

The new module `Catalog/Computation/BerggrenSpectralGap.lean` pins down the *exact* spectrum
of the averaged single-vertex walk generator `W = (A+B+C)/3` of the Berggren tree:
its eigenvalues are `(6±√33)/3` and `-1/3`, with explicit eigenvectors `(1,1,(3±√33)/6)` and
`(1,-1,0)`, a constant Perron-to-second gap of `2√33/3`, and a sharp counterexample showing
that — unlike each generator — the *average* `W` is **not** a Lorentz isometry (it sends the
seed `(3,4,5)` off the light cone to Lorentz value `-200/9`). These exact, machine-checked
spectral facts are the launch pad for the genuinely open questions below.

## Direction 1 — Closing the depth gap: prove `depthGap d ≥ C/d²`

The headline `Ω(1/d²)` rapid-mixing bound is recorded in the module as the conjecture
`berggren_depth_spectral_gap_conjecture` (with `sorry`). The route to a real proof is to
instantiate `depthGap d` as the spectral gap of the *graph Laplacian* of the depth-`d`
Berggren subtree (the `3^d`-leaf ternary tree of `Geometry/BerggrenRamanujan.lean`) and bound
it below by Cheeger's inequality against the linear chain produced by the all-`B` branch.

The key insight is that the slowest relaxation mode of a tree-of-depth-`d` averaging walk is
carried by the **longest embedded path**, and the Berggren tree contains a canonical length-`d`
path — the iterated middle child `berggrenStep .mid` — along which the walk degenerates to a
birth–death chain with the textbook `Θ(1/d²)` Laplacian gap. Why now? The catalog already has
the level-cardinality result (`3^d` vertices at depth `d`) and the explicit `.mid` recurrence,
so the combinatorial skeleton needed for a Cheeger argument is in place; only the Laplacian
comparison lemma is missing.

## Direction 2 — The surd `√33` as a branch invariant

Our spectrum lives in `ℚ(√33)`. The conjecture: for the analogous averaged generator of *any*
three-generator Apollonian/Berggren-type tree in `O(2,1;ℤ)`, the non-Perron eigenvalues lie in
a real quadratic field `ℚ(√D)` whose discriminant `D` is a fixed polynomial in the common
off-diagonal weight of the generators (here weight `2`, giving `D = 33`).

The key insight is that the symmetric `(1,1,t)` sector always collapses the three `O(2,1;ℤ)`
generators to a single `2×2` companion matrix whose characteristic discriminant is a generator
invariant, turning a spectral question into an arithmetic one about quadratic fields. Why now?
`Algebra/BerggrenLorentz/Core.lean` already classifies determinants and traces of the
generators, so the trace/determinant inputs to the companion discriminant are available to test
the polynomial-in-weight hypothesis on the Pell-twisted siblings already in the catalog.

## Direction 3 — Quantum vs. classical mixing separation made rigorous

The corollary advertised in the concept — an `O(d² log(1/ε))` quantum mixing time versus
classical BFS — should be stated as a *separation theorem*: classical BFS enumeration of
depth-`d` triples is `Θ(3^d)`, while the quantum walk hitting time on the same tree is
`O(d² · √(3^d))` via amplitude amplification seeded by the constant gap `2√33/3` proved here.

The key insight is that the constant single-step gap (`2√33/3`) controls *local* amplitude
spreading while the `1/d²` global gap (Direction 1) controls *diameter* traversal, and the
Grover/Szegedy quantum-walk framework multiplies these into a quadratic speedup. Why now? The
catalog's `QuantumBerggrenWalk.lean` already carries `QuantumWalkConfig` and step-count bounds,
so the classical baseline `3^d` and the quantum step budget can be compared inside one file
without new infrastructure.

## Direction 4 — Diagonalizability and a spectral decomposition of `W`

We exhibited three eigenvectors with distinct eigenvalues; the natural strengthening is to
prove `W` is diagonalizable over `ℝ` and produce the explicit spectral projectors, giving a
closed form for `Wⁿ` and hence for the amplitude at any tree vertex after `n` steps.

The key insight is that distinctness of `{(6±√33)/3, -1/3}` already forces a basis of
eigenvectors, so the remaining work is purely the linear algebra of assembling the change-of-
basis matrix and inverting it — a finite, fully constructive computation. Why now? With all
three eigenpairs now formally verified (`walkGen_spectrum_three`), Mathlib's
`Matrix.eigenvalues`/`LinearMap` spectral API can be applied directly rather than re-deriving
the eigenvectors.

## Direction 5 — Why the average breaks the symmetry: a deficiency functional

`walkGen_not_lorentz` shows `W` leaves the light cone. Quantify it: define the *Lorentz
deficiency* `δ(v) = Q(Wv) − Q(v)` and conjecture that `δ` is a fixed negative-definite
quadratic form (here `δ(3,4,5) = -200/9`), so the averaged walk **contracts** the Lorentz norm
uniformly, giving an independent, purely geometric proof of a spectral gap.

The key insight is that averaging three isometries of an *indefinite* form produces a strict
contraction precisely because the three image directions are not collinear, so the deficiency
form `δ` inherits definiteness from the non-commutativity already proved in the catalog. Why
now? The pointwise preservation lemmas (`generatorA/B/C_preserves_lorentzForm`) plus the single
counterexample value give exactly the data needed to compute `δ` as a `3×3` form and test its
definiteness with the same `nlinarith`/`decide` machinery used in this cycle.
