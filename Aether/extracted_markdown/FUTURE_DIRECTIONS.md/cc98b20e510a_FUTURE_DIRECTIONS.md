# FUTURE_DIRECTIONS: Tropical Hecke Operators and PL Eigenfunction Spaces

## Synthesis

This cycle established the foundational formalization of tropical Hecke operators acting on piecewise-linear functions. We defined tropical PL functions as pointwise minima of finitely many affine pieces (`tropMinEval`), introduced the 1D tropical Hecke operator `T_p` acting by min over shifted evaluations, and proved four core results: constant-shift distributivity, PL closure under pointwise min, PL preservation under the Hecke operator, and the constant-function eigenform theorem.

The main structural insight is that the min-plus algebra's lack of additive inverses makes tropical Hecke theory fundamentally different from classical Hecke theory: eigenspaces are closed under min (tropical addition) and scalar shift (tropical multiplication) but not under classical subtraction, making them polyhedral cones rather than vector spaces. The proof of `tropHecke_preserves_pl` reveals that the Hecke operator multiplies the number of affine pieces by `p`, giving an explicit bound on the combinatorial complexity of iterated Hecke images.

A notable failure: we initially planned to prove commutativity of tropical Hecke operators (`T_p ∘ T_q = T_q ∘ T_p`), which requires a delicate reindexing of iterated minima over `range(p) × range(q)`. This is tractable but requires additional infrastructure for product Finset manipulation that would extend the file beyond the current scope. The eigenvalue integrality conjecture was also deferred — it requires defining tropical weight and the projective-line setting more carefully.

## Results Summary

1. **`tropMinEval_add_const`** — proved — constant shift distributes over tropical polynomial evaluation; validates that tropical scalar action commutes with evaluation
2. **`tropMinEval_min_eq`** — proved — pointwise min of two tropical polynomials is a tropical polynomial with `n + m` pieces; establishes closure under tropical addition
3. **`tropHecke_constant_eq`** — proved — the tropical Hecke operator maps constant functions to constant functions; identifies the simplest eigenspace
4. **`tropHecke_preserves_pl`** — proved — the tropical Hecke operator preserves PL structure, mapping `n`-piece functions to `n·p`-piece functions; the main preservation theorem
5. **`constant_isTropHeckeEigenform`** — proved — constant functions are Hecke eigenforms with eigenvalue equal to the shift parameter

## Research Directions

### Direction 1: Tropical Hecke Operator Commutativity

**Hypothesis**: For any `p, q > 0` and any shift parameters `s_p, s_q`, the tropical Hecke operators commute: `T_p^{s_p} ∘ T_q^{s_q} = T_q^{s_q} ∘ T_p^{s_p}` on all functions `ℝ → ℝ`, without any coprimality assumption on `p` and `q`.

**Test**: Prove `tropHecke1D p hp s_p (tropHecke1D q hq s_q f) x = tropHecke1D q hq s_q (tropHecke1D p hp s_p f) x` for all `f` and `x`. The proof should go through a product-Finset reindexing: `inf'_{j ∈ range p} inf'_{k ∈ range q} g(j,k) = inf'_{k ∈ range q} inf'_{j ∈ range p} g(j,k)`.

**Why now**: The `tropHecke_preserves_pl` proof already handles iterated min manipulation over Finsets. The key insight is that unlike the classical case (where commutativity requires coprimality for the full Hecke algebra relations), tropical commutativity should hold unconditionally because min is commutative and associative — the reindexing is purely combinatorial.

**If true**: This would establish that the tropical Hecke operators form a commutative algebra, enabling simultaneous diagonalization and a tropical analogue of the Atkin-Lehner theory.

**If false**: This would reveal unexpected non-commutativity in the tropical setting, pointing to a fundamentally different algebraic structure worth investigating.

### Direction 2: Finite-Dimensionality of Tropical Eigenspaces

**Hypothesis**: For a fixed number of affine pieces `n` and prime `p`, the eigenspace `E_λ = {f ∈ PL_n : T_p(f) = f + λ}` is a finite-dimensional polyhedral cone, where "dimension" is the tropical rank (maximum number of tropically independent elements).

**Test**: Define `TropEigenspace n p shift λ` as the set of `(a, b) : (Fin n → ℝ) × (Fin n → ℝ)` such that `tropMinEval a b` is a Hecke eigenform with eigenvalue `λ`. Prove this set is a polyhedral cone (intersection of finitely many half-spaces) by analyzing the linear constraints that the eigenvalue equation imposes on `(a, b)`.

**Why now**: The `tropHecke_preserves_pl` proof gives explicit formulas for the Hecke-transformed slopes and intercepts. The key insight is that the eigenvalue equation `T_p(f) = f + λ` becomes a system of tropical polynomial equalities, which by the fundamental theorem of tropical geometry defines a polyhedral complex.

**If true**: This gives a decidable characterization of tropical Hecke eigenforms — one can enumerate all eigenforms of bounded complexity by solving a system of linear inequalities.

**If false**: Infinite-dimensional eigenspaces would suggest that the piece-count filtration is not the right notion of "weight" in tropical modular form theory.

### Direction 3: Tropical Eisenstein Series as Explicit Eigenform

**Hypothesis**: The function `E_k(x) = min_{m ≥ 1} (k · m · |x|)` (a simplified tropical Eisenstein series) is a Hecke eigenform with eigenvalue `(k-1) · log(p)` for the weight-`k` tropical Hecke operator, for all primes `p`.

**Test**: Compute `T_p(E_k)` explicitly using the formula, verify the eigenvalue equation. The key step is showing that `min_{m ≥ 1} min_{j=0}^{p-1} k · m · |(x+j)/p|` can be reindexed to `(k-1) · log(p) + min_{m ≥ 1} k · m · |x|`. This requires a lattice-point counting argument.

**Why now**: The constant eigenform result (`constant_isTropHeckeEigenform`) shows the simplest case works. The key insight is that the tropical Eisenstein series is a limit of finite tropical polynomials, and each finite truncation is PL by our preservation theorem. The challenge is extending from finite to infinite tropical sums.

**If true**: This provides the first explicit non-trivial tropical Hecke eigenform, analogous to classical Eisenstein series being the simplest modular forms.

**If false**: The failure point would reveal whether tropical Eisenstein series need a different normalization or whether the analogy with classical Eisenstein series breaks down.

### Direction 4: Tropical Hecke Operator on the Projective Line

**Hypothesis**: The 1D tropical Hecke operator extends to a well-defined operator on homogeneous tropical PL functions on `ℝ²` (tropical projective line), where `f(x, y)` is homogeneous of degree `k` if `f(x + c, y + c) = f(x, y) + k · c`.

**Test**: Define `TropHomogeneous k f := ∀ c x y, f (x + c) (y + c) = f x y + k * c`, define the 2D Hecke operator, and prove that homogeneity is preserved. The key insight is that the 1D operator on the affine chart `y = 0` extends uniquely by homogeneity.

**Why now**: Our 1D results (`tropHecke_preserves_pl`) provide the affine-chart foundation. The projective extension requires only the homogeneity constraint, which is a linear condition on the slopes.

**If true**: This would complete the connection to tropical modular forms and enable the formulation of tropical Hecke algebras on spaces of tropical modular forms.

**If false**: The projective extension might require different boundary conditions at tropical infinity, revealing subtleties in the compactification.

### Direction 5: Complexity Growth Under Iterated Hecke Application

**Hypothesis**: The number of essential affine pieces in `T_p^n(f)` (the `n`-fold application of `T_p`) grows as `O(n · p)` rather than `O(p^n)`, because many of the `n · p^n` formal pieces become redundant (dominated by other pieces).

**Test**: For specific small examples (e.g., `f(x) = min(x, -x + 1)` with `p = 2`), compute `T_2(f)`, `T_2^2(f)`, `T_2^3(f)` and count the essential (non-dominated) pieces. Use `#eval` to check piece counts.

**Why now**: The `tropHecke_preserves_pl` proof shows that `T_p` multiplies the piece count by `p` in the worst case. The key insight is that in practice, many pieces are dominated (their affine function is never the minimum), and the tropical analogue of Sturm-Liouville theory should control the growth of essential pieces.

**If true**: Sub-exponential growth would mean iterated Hecke operators are computationally tractable, enabling explicit computation of tropical Hecke eigenforms by iterative refinement.

**If false**: Exponential growth would indicate a fundamental computational barrier, suggesting that tropical Hecke theory is harder than classical Hecke theory (where dimensions grow polynomially).
