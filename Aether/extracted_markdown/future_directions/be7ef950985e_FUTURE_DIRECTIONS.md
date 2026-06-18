# Future Directions — Quantum Random Walks on Cayley Graphs

## Synthesis

`Physics/QuantumWalkCayley.lean` isolates the algebraic spine of continuous-time
quantum walks on Cayley graphs of finite **abelian** groups. The five theorems
say, in one breath, that the additive characters `χ : G → ℂ` simultaneously
diagonalise the adjacency operator `A_S f(x) = ∑_{s∈S} f(x+s)` with eigenvalues
the character sums `λ_χ = ∑_{s∈S} χ(s)` (`cayley_eigenvector`); that the trivial
character pins the Perron value `|S|` (`degree_eigenvalue`); that `|λ_χ| ≤ |S|`
(`eigenvalue_norm_le`); that a symmetric `S = -S` forces a real spectrum
(`eigenvalue_real_of_symmetric`); and that the quantum evolution `e^{-iA_S t}`
is unitary on each mode (`quantum_phase_conserves_modulus`). Together they give a
clean conceptual separation between the *classical* picture (contraction governed
by the spectral gap `1 - |λ₂|/|S|`) and the *quantum* picture (norm-preserving
phase rotation, hence ballistic spreading and time-averaged mixing).

This work bridges the catalog's classical expander material
(`Algebra/ClassicalGroupExpanders.lean`, `Algebra/ExpanderWalk/Amplification.lean`)
with the quantum-information files under `Physics/`, all through the single
invariant `λ_χ = ∑_{s∈S} χ(s)`.

## Results Summary

- 5 theorems, 0 `sorry`, axioms limited to `propext, Classical.choice, Quot.sound`.
- The character-sum eigenvalue is established as the universal invariant linking
  graph degree, spectral bound, Hermiticity, and quantum unitarity.

## Research Directions

### 1. Concrete cycle spectrum: `2cos(2πk/n)` on `Z_n`
Instantiate the abstract theory on `G = ZMod n` with `S = {1, -1}` and the
standard characters `χ_k(j) = exp(2πi kj/n)`, proving `λ_{χ_k} = 2cos(2πk/n)` and
that the spectral gap is `Θ(1/n²)`. **The key insight is** that the abstract
`cayley_eigenvector` already determines every eigenvalue as a character sum, so
the only remaining work is evaluating that sum at roots of unity — a finite
trigonometric identity, not new spectral theory. **Why now?** The abstract
eigenvalue theorem is proved and the Mathlib `Complex.exp`/root-of-unity API is
mature, so this is a self-contained, falsifiable first stress-test of the engine
(the gap claim is wrong if it is anything other than `Θ(1/n²)`).

### 2. Average mixing measure and the no-pointwise-convergence theorem
Define the Cesàro-averaged distribution `\bar P_T(g) = (1/T)∑_{t<T} P_t(g)` and
prove it converges to a limit governed only by eigenvalue *multiplicities*, while
the instantaneous `P_t` does **not** converge (a direct corollary of
`quantum_phase_conserves_modulus`). **The key insight is** that unitarity blocks
pointwise convergence, so the correct notion of quantum mixing must be the
time-average, whose limit is a purely spectral (multiplicity) quantity. **Why
now?** Theorem 5 already encodes the obstruction; formalising the averaged
limit turns a slogan ("quantum walks don't mix pointwise") into a checkable
theorem and gives the next cycle a rigorous target for "mixing time".

### 3. Tensor/product groups and quadratic dimension scaling
Show the eigenvalues of `A_{S×T}` on `G × H` factor through those of `A_S` and
`A_T`, so spectra of product Cayley graphs are sums of factor eigenvalues.
**The key insight is** that characters of a product group are products of
characters, making the character-sum invariant multiplicative across factors —
the natural categorical functoriality of the construction. **Why now?** With the
single-group eigenvector theorem in hand, the product law is a short
representation-theoretic step, and it is exactly the lemma needed to scale any
mixing-time bound from `Z_n` to `Z_n^d` (hypercube-type walks), the regime where
the conjectured quadratic speedup is most often tested.

### 4. The non-abelian frontier via Schur's lemma
Replace 1-dimensional characters by irreducible representations `ρ : G → U(d_ρ)`
and prove `A_S` acts as the block matrix `∑_{s∈S} ρ(s)` on each isotypic
component, recovering the abelian result when `d_ρ = 1`. **The key insight is**
that `cayley_eigenvector` is the `d_ρ = 1` shadow of a block-scalar action, so the
honest generalisation is "eigen-blocks", not eigenvalues — exactly where the
random-transposition walk on `Sₙ` lives. **Why now?** Mathlib's
`Representation`/`FDRep` and character theory are now strong enough to state the
block decomposition, and this is the precise missing ingredient for the
`S = transpositions` conjecture flagged in the file's Failure analysis.

### 5. Gap-to-mixing inequality as a falsifiable bound
State and prove a quantitative bridge `τ_mix ≤ C / gap` for the classical walk and
contrast it with a quantum bound `τ_quant = O(1/√gap)` on the averaged measure,
making the "quadratic speedup" a single inequality between two proved quantities.
**The key insight is** that both sides are controlled by the *same* eigenvalues
`λ_χ`, so the speedup is not two separate analyses but one spectral quantity read
two ways. **Why now?** Directions 1–2 supply the concrete gap and the averaged
limit; chaining them yields the headline conjecture in a form that is outright
false if the quantum exponent is anything other than `1/2`, giving the next cycle
a sharp, refutable goal.
