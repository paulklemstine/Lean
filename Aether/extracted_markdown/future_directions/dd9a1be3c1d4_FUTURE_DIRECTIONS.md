# Future Directions: Tropical Hodge Theory

The file `Catalog/Tropical/HodgeDecomposition/HarmonicTheory.lean` establishes the
analytic backbone of tropical Hodge theory on a finite weighted polyhedral
complex modelled by a single weighted coboundary `d : ℝ^m → ℝ^n`: Green's
identity, positive semidefiniteness and self-adjointness of the up-Laplacian
`Δ = δ∘d`, the orthogonality of the harmonic space `ker d` to the image of the
codifferential `δ`, and the energy characterization of harmonicity. These results
extend the catalog foundations in `Tropical.HodgeDecomposition.Defs`
(`adjunction`, `ker_laplacianUp_eq_ker_d`, `weightedIP_pos_def`,
`weightedIP_eq_zero_iff`). Below are concrete, falsifiable directions that build on
this work.

## 1. The full orthogonal Hodge decomposition `ℝ^m = ker Δ ⊕ im δ`

We proved that the harmonic space `ker d = ker Δ` is *orthogonal* to `im δ`
(`harmonic_orthogonal_image_delta`). The natural completion is the *direct sum*
statement: every cochain `v ∈ ℝ^m` decomposes uniquely as `v = h + δw` with
`h` harmonic, and the two summands are weighted-orthogonal. The key insight is
that orthogonality plus a dimension count `dim(ker d) + rank(δ) = m` (a
rank–nullity bookkeeping already glimpsed in `rank_nullity`) forces the
orthogonal complement of `im δ` to coincide with `ker d`, so no extra analysis
is needed beyond finite-dimensional linear algebra over `ℝ`. Why now? Both
ingredients — the orthogonality lemma and a rank–nullity skeleton — already live
in the catalog, so this is a short, self-contained capstone that turns the
present "orthogonality" results into a genuine decomposition theorem. A
falsifiable prediction: for the unit-weight path graph on 3 vertices the
harmonic space is exactly the 1-dimensional constants and the complement is
2-dimensional, matching `m - dim(ker d) = 3 - 1 = 2`.

## 2. Hodge isomorphism: harmonic representatives of cohomology

For a genuine two-step complex `ℝ^ℓ →^{d₀} ℝ^m →^{d₁} ℝ^n` with `d₁∘d₀ = 0`,
the middle cohomology `ker d₁ / im d₀` should be represented uniquely by harmonic
cochains (`ker Δ` for the combined Laplacian `Δ = δ₀d₀ + δ₁d₁`). The key insight
is that the *combined* Laplacian's kernel splits as the intersection
`ker d₁ ∩ ker δ₀`, and the orthogonality already proven (harmonic ⊥ im δ, and
dually harmonic ⊥ im d) makes the quotient map to harmonic forms an isomorphism.
Why now? Our single-coboundary self-adjointness and orthogonality results are
exactly the per-degree pieces that assemble into the combined statement; the only
new content is encoding the cochain condition `d₁∘d₀ = 0` as a structure. A
testable case: the triangle (cycle graph `C₃`) should give a 1-dimensional
harmonic `H¹`, recovering `b₁ = 1`.

## 3. Spectral gap and tropical heat-flow contraction

The PSD and self-adjointness theorems make `Δ` a genuine symmetric PSD operator,
hence diagonalizable with nonnegative real spectrum. The first nonzero eigenvalue
`λ₁` (the tropical spectral gap) should control the exponential decay rate of the
discrete heat semigroup `e^{-tΔ}` onto the harmonic space. The key insight is
that `greens_identity` already identifies `⟨Δv,v⟩` with the Dirichlet energy, so a
Poincaré-type inequality `⟨Δv,v⟩ ≥ λ₁‖v‖²` on the complement of the harmonics is
equivalent to a min-max characterization of `λ₁` that is purely linear-algebraic.
Why now? With self-adjointness and PSD in hand, Mathlib's spectral theorem for
symmetric operators applies directly; the missing step is only the variational
(Rayleigh-quotient) wrapper. Falsifiable prediction: for the complete graph `Kₙ`
with unit weights, `λ₁ = n` with multiplicity `n-1`, so heat flow contracts at
rate `e^{-nt}`.

## 4. Weight-monotonicity of harmonic energy (a tropical comparison principle)

Because every summand of the weighted inner product is `wᵢ·xᵢ²`, the Dirichlet
energy `⟨dv, dv⟩_tgt` is *monotone* in the target weights. The conjecture: if
`tgtWeight ≤ tgtWeight'` pointwise then the harmonic projection energies satisfy a
matching inequality, giving a comparison principle for how reweighting cells
(refining the tropical complex) can only increase Dirichlet energy. The key
insight is that monotonicity is visible term-by-term in `weightedIP`, so the
comparison follows from `Finset.sum_le_sum` without any spectral input. Why now?
The energy identity `greens_identity` reduces a statement about the Laplacian
operator to a statement about a single weighted sum, where monotonicity is
elementary. A falsifiable check: doubling all edge weights of a graph exactly
doubles every Dirichlet energy `⟨dv,dv⟩`, hence doubles `⟨Δv,v⟩`.

## 5. Tropical Hard Lefschetz for matroidal fans via Laplacian positivity

The catalog records the Hard Lefschetz Property (`SatisfiesHLP`) as a Betti-number
unimodality condition. The deeper conjecture is that for the Bergman fan of a
realizable matroid, the Lefschetz operator `L` composed with the harmonic
projection is *positive definite* in the weighted inner product, so HLP follows
from the same PSD/self-adjointness machinery proven here applied to `L`-twisted
Laplacians. The key insight is that Hodge–Riemann positivity — the engine behind
Adiprasito–Huh–Katz — is a statement about signature of a symmetric form, and our
`weightedIP_pos_def` + self-adjointness give exactly the framework to state and
test it combinatorially. Why now? The single-coboundary harmonic theory is the
degree-one shadow of the full matroidal story; formalizing the `U_{2,4}` example
(predicted Betti sequence `(1,3,1)`) is a concrete, falsifiable first milestone
that stress-tests whether the present definitions scale to graded complexes.
