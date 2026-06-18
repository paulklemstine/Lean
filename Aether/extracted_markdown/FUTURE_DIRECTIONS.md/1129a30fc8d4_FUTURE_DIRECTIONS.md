# Future Directions: Non-Archimedean Probability Theory

## What We Built

This cycle established `FinProbSpace F n` (in `Defs.lean`) and extended it with four new
machine-verified theorems (in `DutchBook.lean`) — all over arbitrary linearly ordered fields,
zero sorries, zero `sorryAx` in axiom traces. The combined framework now includes:

- **Inclusion-exclusion**, **Bayes' theorem**, **Markov inequality** (Defs.lean)
- **Dutch Book from negative prices** — explicit construction (DutchBook.lean, Theorem 1)
- **Full Dutch Book characterization** — ¬DutchBook ↔ Kolmogorov axioms (DutchBook.lean, Theorem 2)
- **Law of total probability** — partition decomposition (DutchBook.lean, Theorem 3)
- **Variance nonnegativity** — purely algebraic (DutchBook.lean, Theorem 4)

The central insight: **all classical finite probability is purely algebraic**. The ordered
field axioms suffice — no completeness, Archimedean property, or measure theory required.

---

## Direction 1: Non-Archimedean Chebyshev and Concentration Inequalities

The key insight is that Chebyshev's inequality P(|X - μ| ≥ t) ≤ Var(X)/t² follows from
Markov applied to (X - μ)², and our `variance_nonneg` already establishes the critical
nonnegativity. Over non-Archimedean fields, the concentration bound Var(X)/t² can be
infinitesimal even when t is finite, giving qualitatively different concentration behavior
than over ℝ — a distribution can have infinitesimal variance while having non-infinitesimal
support.

**Falsifiable prediction**: Define `chebyshev_ineq` as a direct corollary of `markov_ineq`
and `variance_nonneg`. Then construct a `FinProbSpace` over a non-Archimedean field where
weights are (1/2 - ε, ε, 1/2) with values (-1, 0, 1). The variance should be 1/2 + O(ε),
and Chebyshev with t = 1 gives P(|X| ≥ 1) ≤ 1/2 + O(ε). Verify the bound is tight to
leading order.

**Why now?** We have both `markov_ineq` and `variance_nonneg`. Chebyshev is a 5-line
corollary, and the non-Archimedean examples require only instantiating `FinProbSpace`
with explicit weights.

---

## Direction 2: Algebraic Jensen's Inequality and Convexity over Ordered Fields

The key insight is that Jensen's inequality E[f(X)] ≥ f(E[X]) for convex f is algebraic
for finite probability spaces — it follows from the definition of convexity and induction
on the number of atoms, with no appeal to integration theory. Our `FinProbSpace.expectation`
provides the weighted sum; we need only formalize "f is convex on an interval" as
`∀ x y ∈ I, ∀ t ∈ [0,1], f(t*x + (1-t)*y) ≤ t*f(x) + (1-t)*f(y)` and prove the
finite-sum version by induction.

**Falsifiable prediction**: The inductive proof requires the key lemma that if
∑_{i=0}^{n} w_i = 1 with w_i ≥ 0, and w₀ < 1, then ∑_{i=1}^{n} w_i/(1-w₀) = 1.
This normalization step is where the algebraic structure matters — it requires
division in the field. Formalize this as `renormalize_weights` and verify it over ℚ
with w = (1/3, 1/3, 1/3).

**Why now?** The `FinProbSpace` framework with `expectation` is ready. Jensen's inequality
would unlock the AM-GM inequality, power mean inequalities, and information-theoretic
results (via log-convexity) — all over arbitrary ordered fields.

---

## Direction 3: Complete Dutch Book Theorem with Transaction Costs

The key insight is that our `dutch_book_full_characterization` assumes frictionless
markets. With transaction costs c > 0 per bet, the characterization weakens:
¬DutchBook_c ↔ ∃ probability measure P such that |p(i) - P(i)| ≤ c for all i.
This is the "approximate coherence" theorem, fundamental to robust Bayesian inference.

**Falsifiable prediction**: Define `DutchBookWithCost F n p c` where profit at ω must
exceed c · ‖s‖₁ (total transaction cost). Conjecture: for c > 0, the no-Dutch-book
condition becomes `∃ (w : Fin n → F), (∀ i, 0 ≤ w i) ∧ ∑ w = 1 ∧ ∀ i, |p i - w i| ≤ c`.
The forward direction should fail for c > 1/n (too much tolerance), giving a concrete
boundary.

**Why now?** We have the exact (c = 0) characterization. The extension to c > 0 requires
only modifying the `DutchBook` structure and reproving the characterization with the
tolerance parameter — the proof structure (construct FinProbSpace / find explicit stakes)
transfers directly.

---

## Direction 4: Tropical Probability via Valuation Maps

The key insight is that `prob_weight_power_bound` (in Defs.lean) is already a shadow of
the tropical correspondence. When weights are ε^{k(i)} with ε ∈ (0,1), probability is
squeezed between ε^{min k} and n·ε^{min k}. Under the valuation v(x) = -log_ε(x),
this becomes v(P(A)) = min_{i ∈ A} k(i) + O(1) — exactly the tropical sum.

**Falsifiable prediction**: Define a valuation map `val : F → ℤ ∪ {∞}` satisfying
val(xy) = val(x) + val(y) and val(x+y) ≥ min(val(x), val(y)). Prove that for
`FinProbSpace F n` with weights satisfying val(w(i)) = k(i), the Bayes identity
val(P(A|B)) + val(P(B)) = val(P(A∩B)) holds exactly (it's a one-line rewriting of
the definition of conditional probability under the valuation). The tropical Bayes
theorem is: val(P(A|B)) = val(P(A∩B)) - val(P(B)) in the min-plus semiring.

**Why now?** Mathlib already has `Valuation` and `Tropical` types. Connecting our
`FinProbSpace` to these existing structures via a formal functor would create a
genuine cross-domain bridge between probability and tropical geometry.

---

## Direction 5: Finite de Finetti Theorem over Ordered Fields

The key insight is that de Finetti's theorem — every exchangeable sequence is a mixture
of i.i.d. sequences — has a finite version that is purely algebraic. For a finite
exchangeable sequence (X₁,...,Xₙ) over `FinProbSpace F (k^n)` (k outcomes per trial,
n trials), the joint distribution is a convex combination of product distributions.
The proof uses the symmetric group action and the Birkhoff-von Neumann theorem for
doubly stochastic matrices, both of which are algebraic.

**Falsifiable prediction**: For n = 2, k = 2 (two binary trials), an exchangeable
distribution on {0,1}² has 3 free parameters (p(00), p(01)=p(10), p(11)).
Exchangeability forces p(01) = p(10). The de Finetti representation is:
p(00) = ∫ (1-θ)² dμ(θ), p(11) = ∫ θ² dμ(θ), p(01) = ∫ θ(1-θ) dμ(θ).
Over a non-Archimedean field, μ can assign infinitesimal weight to "extreme" θ values,
yielding distributions not expressible over ℝ. Verify this for the specific case
p(00) = 1/2 - ε, p(01) = ε, p(11) = 1/2 - ε with mixing measure
μ = (1/2 - ε)·δ₀ + 2ε·δ_{1/2} + (1/2 - ε)·δ₁.

**Why now?** Our framework handles `FinProbSpace F (k^n)` directly. The exchangeability
condition is a group-theoretic constraint (invariance under Sym(n) acting on coordinates),
and Mathlib has extensive symmetric group support.
