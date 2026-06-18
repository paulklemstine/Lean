# FUTURE DIRECTIONS — Discrete Hodge ↔ Probability

This cycle established a self-contained Mathlib foundation for the discrete Hodge
program on finite weighted graphs and bridged it to the probability of reversible
random walks (file `Catalog/Bridges/DiscreteHodgeRandomWalk.lean`).

Proved this cycle:
- Dirichlet energy identity `xᵀ L x = ½ Σᵢⱼ wᵢⱼ (xᵢ − xⱼ)²`.
- Positive semidefiniteness of the combinatorial Laplacian `L = D − A`.
- Symmetry of `L`, zero row-sums, and harmonicity of constants.
- Detailed balance / reversibility of `P = D⁻¹A` w.r.t. the degree measure
  (stated *unconditionally* using totality of real division).
- The factorization `L f = D(f − Pf)` and the bridge theorem:
  at a positive-degree vertex, `(L f) i = 0 ⟺ (P f) i = f i`
  (discrete harmonic forms = walk-invariant functions).

The following conjectures are bold, precise, and testable in subsequent cycles.

## C1 — Kernel of `L` = locally constant functions (connectivity ⇒ 0th Hodge number)
For a finite weighted graph whose positive-weight relation is connected,
`L.mulVec f = 0 ↔ f` is constant. More generally, `dim ker L` equals the number
of connected components of the support graph. This is the discrete `H⁰` and the
0th Betti number; it is the natural next theorem after `laplacian_mulVec_const`
and `quadForm_nonneg` (the energy `½ Σ wᵢⱼ(fᵢ−fⱼ)²` vanishes iff `f` is constant
on each component).

## C2 — Spectral gap ⇒ exponential mixing of the reversible walk
Let `0 = λ₀ ≤ λ₁ ≤ … ` be the eigenvalues of the *normalized* Laplacian
`𝓛 = I − D^{-1/2} A D^{-1/2}`. Conjecture: for a connected graph with
`λ₁ > 0`, the reversible walk `P` satisfies a Poincaré inequality
`Var_π(f) ≤ (1/λ₁) · 𝓔(f, f)` (Dirichlet form), hence `Lᵖ` mixing
`‖Pᵗf − π(f)‖ ≤ (1 − λ₁)ᵗ ‖f‖`. This connects the Hodge spectrum directly to
the probabilistic convergence rate; the Dirichlet identity proved here is the
exact `𝓔(f,f)` appearing in the inequality.

## C3 — Discrete Hodge decomposition `ℝ^V = ker L ⊕ im L`
Because `L` is symmetric PSD, `ℝ^V` orthogonally decomposes as
`ker L ⊕ range L`, with `ker L` the harmonic part and `range L` the "exact +
co-exact" part. Conjecture (and formalize): every function uniquely splits as
`f = h + Lg` with `h` harmonic, and `h` is the orthogonal projection minimizing
Dirichlet energy among representatives of `f mod range L`. This is the finite-
dimensional Hodge theorem; it needs only `Matrix.IsSymm` + PSD already proved.

## C4 — Reversibility characterizes self-adjointness of `P` in the `π`-inner product
Conjecture: a stochastic kernel `P` on `Fin n` is reversible w.r.t. a positive
measure `π` (`πᵢ Pᵢⱼ = πⱼ Pⱼᵢ`) **iff** `P` is self-adjoint for the weighted
inner product `⟨f,g⟩_π = Σ πᵢ fᵢ gᵢ`, **iff** `P` arises from some symmetric
weight kernel `w` via `wᵢⱼ = πᵢ Pᵢⱼ`. This upgrades `reversible` from a property
of graph-derived walks to a full equivalence, identifying "reversible Markov
chain" with "weighted graph" canonically.

## C5 — Effective resistance is a metric, and a graph-Green's-function identity
Define effective resistance `R(i,j)` via the energy-minimizing `g` with
`L g = eᵢ − eⱼ` (well-defined on connected graphs by C3). Conjecture:
`R` is a metric on vertices (the "resistance metric"), `R(i,j) = (eᵢ−eⱼ)ᵀ L⁺ (eᵢ−eⱼ)`
with `L⁺` the Moore–Penrose pseudoinverse, and it equals the expected commute
time of the reversible walk up to the factor `2·(total weight)`. This is the
deepest probability↔Hodge bridge: the Green's function `L⁺` simultaneously
governs harmonic extension (Hodge) and commute/hitting times (probability).
