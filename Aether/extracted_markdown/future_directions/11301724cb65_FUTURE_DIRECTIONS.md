# Future Directions: Falsifiable Conjectures and Testable Hypotheses

## Conjecture 1: Derivative Normal-Form Sparsity

**Statement.** After algebraic simplification (constant folding, identity elimination, zero elimination), the size of the simplified derivative satisfies `size(simplify(derivE e)) ≤ C · size(e)^{3/2}` for some universal constant `C`, for all elementary expressions `e` of depth at most 10.

**Test.** Exhaustively generate all `EExpr` trees up to depth 6. For each expression, compute `derivE`, apply a fixed simplification algorithm, and measure the simplified size. Fit the empirical growth function to `size^α` and check whether `α < 1.6`.

**Impact.** If true, this would show that the worst-case quadratic blowup (proven in our `size_derivE_le`) is rarely achieved in practice, and that simplification makes symbolic differentiation much more efficient than the worst-case bound suggests. This has direct implications for the scalability of proof-producing computer algebra systems.

---

## Conjecture 2: Semantic Non-Injectivity at Low Depth

**Statement.** There exist distinct `EExpr` expressions `e₁` and `e₂` of depth ≤ 4 such that `evalE e₁ = evalE e₂` as functions ℝ → ℝ, but `e₁` and `e₂` are not related by any finite sequence of algebraic identity rewrites (commutativity, associativity, distribution).

**Test.** Enumerate all expressions of depth ≤ 4 (with constants drawn from {0, 1, -1, 2}). For each pair, numerically compare evaluations at 1000 random points in [-10, 10]. Report pairs with maximum pointwise difference < 10⁻¹² that are syntactically unrelated by standard rewrite rules.

**Impact.** If confirmed, this shows that the quotient of `EExpr` by extensional equality is nontrivially smaller than the syntactic type, even at very small depths. This bears on the feasibility of decision procedures for elementary function equality (which is known to be undecidable in general but may be tractable for bounded depth).

---

## Conjecture 3: Exp-Free Subclass Cannot Represent Exponential Growth

**Statement.** For any exp-free expression `e` (i.e., `containsExp e = false`), the function `evalE e` is either eventually bounded by a polynomial, or has at most logarithmic growth: there exist `C, N, k` such that `|evalE e x| ≤ C · x^k · (log x)^k` for all `x > N`.

**Test.** For a large sample of exp-free expressions of depth ≤ 8, numerically evaluate at `x = 10, 100, 1000, 10000` and fit the growth rate. Check whether any exp-free expression exhibits super-polynomial growth.

**Impact.** If true, this provides a *semantic* separation theorem: the exp-free subclass is not just syntactically smaller but represents a strictly smaller class of functions (missing exponential growth). Combined with `derivE_noexp`, this would show that the exp-free differential algebra is a proper, closed sub-algebra of the full elementary algebra — a result with implications for Liouville theory and the classification of solvable ODEs.

---

## Conjecture 4: Elementary ODE Observable Closure under Lie Derivatives

**Statement.** For any polynomial vector field `V(x) = p(x)` (a polynomial in `x`) and any elementary expression `e`, the Lie derivative `L_V(e) := p(x) · derivE(e)` is again an elementary expression with `size(L_V(e)) ≤ size(V) · size(e)^2`.

**Test.** Implement symbolic Lie derivative computation. For polynomial vector fields of degree ≤ 5 and elementary observables of depth ≤ 6, verify the size bound computationally. Check whether iterated Lie derivatives `L_V^n(e)` remain bounded in size for small `n`.

**Impact.** If true, this extends differential closure from the derivative operator to Lie derivatives along polynomial flows, connecting our results to the theory of dynamical systems. It would provide a formal tool for analyzing when trajectory-level observables remain in the elementary class — useful for control theory and qualitative ODE analysis.

---

## Conjecture 5: Normalization Reduces Derivative Blowup by at Least 40%

**Statement.** A basic algebraic simplifier (constant folding, identity/zero elimination, common subexpression detection) reduces the average AST size of `derivE(e)` by at least 40% for random expressions `e` of depth ≤ 6, sampled uniformly from the space of all depth-bounded expressions with constants in {0, 1, -1, 2, 1/2}.

**Test.** Generate 10,000 random expressions of depth ≤ 6. For each, compute `size(derivE(e))` and `size(simplify(derivE(e)))`. Report the mean and median reduction ratio `1 - size(simplified)/size(raw)`.

**Impact.** If confirmed, this provides empirical evidence that a simple verified simplifier (an extension of our formalization) would make the derivative algorithm practical for larger expressions. If the reduction exceeds 60%, it suggests that most of the quadratic blowup is "trivial" (algebraic identities) rather than inherent. This has direct engineering implications for verified symbolic computation tools.
