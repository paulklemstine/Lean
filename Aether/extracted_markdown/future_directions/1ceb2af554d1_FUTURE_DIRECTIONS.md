# Future Directions: Spectral & Multi-Output Neural Tangent Kernel Theory

This cycle produced `MachineLearning/NTKSpectral.lean`, which extends the core
NTK file (`MachineLearning/NTKCore.lean`) in three directions: a fully
index-agnostic Gram-matrix PSD result (`gramMatrix_posSemidef`), the
positive-semidefiniteness of the multi-output / block NTK
(`blockNtkGramMatrix_posSemidef`), and a spectral account of the abstract
contractivity constant — `diagonalKernel_contractive`,
`optimalLearningRate_eigenvalue_bound`, `optimalLearningRate_contractive` — closed
out by the genuine convergence guarantees `gdLoss_geometric_decay`
(loss decays as `c^{2t}`) and `gdResidual_tendsto_zero` (residual → 0). The
following conjectures push past what is now formalized.

## 1. The operator norm of `I - ηK` equals `max_i |1 - η λ_i|`

We currently exhibit the contraction constant only in the *eigenbasis*, where the
kernel is diagonal (`diagonalKernel_contractive`). The missing step is a basis-free
statement: for a symmetric PSD kernel `K` with eigenvalues `λ_i`, the operator norm
of `gdUpdateOp K η` on the Euclidean space `EuclideanSpace ℝ (Fin n)` is exactly
`max_i |1 - η λ_i|`. The key insight is that `gdUpdateOp_isSymm` (from NTKCore)
plus the orthogonal diagonalization `Matrix.IsHermitian.spectral_theorem` lets one
*conjugate* `diagonalKernel_contractive` by the (norm-preserving) eigenvector
unitary, transporting the diagonal bound to the original basis without recomputing
anything. Why now? Both ingredients — symmetry preservation and the diagonal
contraction theorem — are already proved in this project; what remains is invoking
Mathlib's spectral theorem and a `LinearIsometryEquiv` change of basis. Note the
subtlety that `Fin n → ℝ` carries the *sup* norm in our files, so this conjecture
must be stated on `EuclideanSpace ℝ (Fin n)` for the operator-norm/eigenvalue
identity to hold.

## 2. Strict positive definiteness from full column rank of the feature map

`gramMatrix_posSemidef` gives `K ⪰ 0`; the convergence rate sharpens dramatically
when `K ≻ 0`. Conjecture: `gramMatrix Φ` is positive *definite* iff the feature
map `Matrix.of Φ` has full row rank `n` (equivalently, the feature vectors
`{Φ i}` are linearly independent in `Fin p → ℝ`, which forces `p ≥ n`). The key
insight is that `vᵀ K v = ‖(Matrix.of Φ)ᵀ ᵥ* v‖² = 0` exactly when `v` lies in the
kernel of `(Matrix.of Φ)ᵀ`, so positive definiteness is precisely injectivity of
that map — a clean reformulation via `Matrix.rank` and `LinearMap.ker_eq_bot`.
Why now? The Gram-as-product factorization (`gramMatrix_eq_mul_transpose`) already
reduces the quadratic form to a squared norm; the only new content is connecting
the vanishing locus to the rank, for which Mathlib's `Matrix.rank` API is adequate.
Combined with `optimalLearningRate_contractive` this yields the textbook bound
`L(θ_t) ≤ (1 - η λ_min)^{2t} L(θ_0)` with an *explicit* nonzero `λ_min`.

## 3. The block NTK inherits the spectrum of the per-output kernels

`blockNtkGramMatrix_posSemidef` shows the multi-output kernel is PSD, but says
nothing about its eigenvalues. Conjecture: when the per-output Jacobians share a
common feature geometry — concretely `J a i l = g(a) · ψ i l` for an output-scaling
`g : Fin k → ℝ` — the block kernel factors as a Kronecker product
`K_block = D ⊗ K_scalar` with `D = diagonal (g · g)`, so its spectrum is the
pairwise products `{ g(a)² · λ_j }`. The key insight is that the block index
`Fin n × Fin k` makes this a literal `Matrix.kroneckerMap`, and PSD/eigenvalue
behaviour of Kronecker products is multiplicative. Why now? Our block matrix is
already defined over the product index type and proved to be a Gram matrix; the
remaining work is recognizing the separable case as a Kronecker product and citing
`Matrix.PosSemidef.kronecker`, giving the first quantitative multi-output rate.

## 4. Loss is monotonically non-increasing without the contraction hypothesis

`gdLoss_geometric_decay` assumes `IsContractive`. A weaker but very useful fact
needs only PSD-ness and a learning-rate cap: if `K ⪰ 0` and `0 ≤ η ≤ 1/λ_max`,
then `gdLoss (gdStep K η u) ≤ gdLoss u` — gradient descent never increases the
training loss. The key insight is the algebraic identity
`‖(I-ηK)u‖² = ‖u‖² - η ⟨u, (2K - ηK²) u⟩`, and `2K - ηK² = K(2I - ηK) ⪰ 0`
precisely when `ηλ_max ≤ 2`, which is exactly the descent condition. Why now? The
quadratic-form machinery from `gramMatrix_posSemidef` and the operator algebra of
`gdUpdateOp` are in place; this conjecture only needs the PSD-ness of the
polynomial `K(2I-ηK)` in `K`, a one-line spectral-calculus fact once Direction 1
is available, and it removes the somewhat unsatisfying black-box contractivity
assumption from the convergence story.

## 5. Discrete-to-continuous: gradient descent tracks gradient flow as `η → 0`

Our dynamics are discrete (`gdResidual K η u₀ t = (I-ηK)^t u₀`). The continuous-time
NTK story is gradient *flow* `u'(s) = -K u(s)`, solved by `u(s) = exp(-sK) u₀`.
Conjecture: for fixed horizon `s`, the discretization with step `η = s/t` converges,
`gdResidual K (s/t) u₀ t → (Matrix.exp (-s • K)).mulVec u₀` as `t → ∞`. The key
insight is that `(I - (s/t) K)^t → exp(-sK)` is the matrix Lie-product / exponential
limit, and the residual identity `gdResidual_eq_pow` from NTKCore turns the problem
into exactly this classical limit. Why now? Mathlib has `Matrix.exp` and the
scalar exponential limit `tendsto_one_plus_div_pow_exp`; lifting it to commuting
matrix powers gives a rigorous bridge between the discrete theorems proved here and
the continuous-time kernel-regression picture, unifying the two standard NTK
formalisms under one roof.
