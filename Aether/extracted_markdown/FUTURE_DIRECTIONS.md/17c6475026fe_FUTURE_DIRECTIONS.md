# Future Directions: From Coefficient Extraction to Directional Algebra

This document identifies five falsifiable scientific hypotheses arising from the formalization of the coefficient extraction theorem for multivariate polynomial line restrictions. Each hypothesis is specific enough to fail, testable in finite time, and significant enough to matter.

---

## Hypothesis 1: Projective Symbol Vanishing with Multiplicity

**Conjecture.** Let $P \in \mathbb{F}_q[X_1, \ldots, X_n]$ have total degree $d < q$. If $P$ vanishes to multiplicity $\geq r$ at every point of a Kakeya set $K$ (i.e., all Hasse derivatives of order $< r$ vanish on $K$), then the coefficient of $t^k$ in the restriction $P(x + tv)$ can be expressed as a sum involving Hasse derivatives of the homogeneous components of $P$ evaluated at $v$, for each $k \geq d - r + 1$. Specifically:

$$\text{coeff}(P(x+tv), t^k) = \sum_{j=0}^{d-k} \binom{d}{k} \cdot D_v^{(j)}[\text{HC}_{k+j}(P)](x)$$

where $D_v^{(j)}$ denotes the $j$-th directional Hasse derivative in direction $v$.

**Test.** Implement the Hasse derivative formula in Python and verify it for all polynomials of degree $\leq 3$ over $\mathbb{F}_5^2$, checking both sides of the identity for all monomials and random base points. Then attempt to formalize the identity in Lean for the monomial case.

**Success criterion.** The identity holds for all test cases, and the monomial case can be proved in Lean. Failure: a counterexample is found for some specific $(P, x, v, k)$.

**Impact.** If true, this generalizes the coefficient extraction theorem to the multiplicity polynomial method used in [Dvir-Kopparty-Saraf-Sudan, 2013], enabling formal verification of improved Kakeya-type bounds. It would also provide the first formal connection between Hasse derivatives and graded polynomial structure over finite fields.

---

## Hypothesis 2: Extremizer Rigidity in $\mathbb{F}_q^2$

**Conjecture.** For prime $q \geq 5$, the minimum-size Kakeya set in $\mathbb{F}_q^2$ has size exactly $q(q+1)/2$, and every minimum-size Kakeya set is affinely equivalent to the "standard" construction consisting of lines through a common point with slopes forming a complete set of representatives for $\mathbb{P}^1(\mathbb{F}_q)$.

**Test.** For $q \in \{3, 5, 7, 11\}$:
1. Enumerate all Kakeya sets of minimum size using exhaustive search (feasible for $q \leq 7$).
2. Classify them up to affine equivalence.
3. Compute their incidence energy $E = \sum_x m(x)^2$ and verify it is maximized by the standard construction.

**Success criterion.** For each tested $q$, all minimum Kakeya sets are affinely equivalent. Failure: two non-equivalent minimum Kakeya sets exist for some $q$, or the minimum size differs from $q(q+1)/2$.

**Impact.** Rigidity of extremizers would establish that Kakeya minimization has a unique solution up to symmetry, analogous to equality cases in isoperimetric inequalities. It would provide structural insight into why the polynomial method gives tight bounds in 2D and whether this tightness extends to higher dimensions.

---

## Hypothesis 3: Energy Gap Beyond Cauchy-Schwarz

**Conjecture.** For any family of $N$ lines in $\mathbb{F}_q^2$ with one line in each projective direction (so $N = q + 1$), if the union has size $|P| \leq cq^2$ for a constant $c < 1$, then the incidence energy satisfies:

$$E = \sum_x m(x)^2 \geq \frac{(Nq)^2}{|P|} + \Omega\left(\frac{N^2}{q}\right)$$

That is, there is a gap of order $N^2/q$ beyond the trivial Cauchy-Schwarz bound.

**Test.** For $q \in \{5, 7, 11, 13, 17, 19\}$:
1. For each possible set of base points defining a line family, compute $|P|$ and $E$.
2. Compute $E - (Nq)^2/|P|$ and check whether it is $\geq cN^2/q$ for some universal constant $c > 0$.
3. Plot the energy gap as a function of $|P|/q^2$.

**Success criterion.** The gap $E - (Nq)^2/|P| \geq cN^2/q$ holds for all tested configurations with $|P| \leq 0.9q^2$, with $c \geq 0.1$. Failure: a configuration with $|P| \leq 0.9q^2$ has energy gap less than $0.01 N^2/q$.

**Impact.** An energy gap beyond Cauchy-Schwarz would provide an alternative proof architecture for Kakeya bounds, potentially giving improved constants. It would also connect Kakeya geometry to expander-graph-like phenomena and second-moment methods in additive combinatorics.

---

## Hypothesis 4: Full Jet Expansion API

**Conjecture.** For any polynomial $P$ of total degree $D$, base point $x$, direction $v$, and integer $0 \leq k \leq D$, the coefficient of $t^k$ in $P(x + tv)$ can be expressed as:

$$\text{coeff}(P(x+tv), t^k) = \sum_{d=k}^{D} \binom{d}{k} \cdot \text{eval}\left(v^{\otimes k} \otimes x^{\otimes (d-k)}, \text{HC}_d(P)\right)_{\text{mixed}}$$

where the right-hand side is a weighted sum over homogeneous components of degree $\geq k$, with each term involving a "mixed evaluation" that picks $k$ factors of $v$ and $d-k$ factors of $x$ from the monomial.

More precisely, for a monomial $X^s$ with $|s| = d$:
$$\text{coeff}\left(\prod_i (x_i + tv_i)^{s_i}, t^k\right) = \sum_{\substack{r : \sigma \to \mathbb{N} \\ r \leq s, |r| = k}} \prod_i \binom{s_i}{r_i} x_i^{s_i - r_i} v_i^{r_i}$$

**Test.** Verify the formula computationally for all monomials of degree $\leq 5$ in 3 variables, with random $x, v$ over $\mathbb{F}_{11}$, for all values of $k$. Then formalize the monomial case in Lean as a generalization of `coeff_restrictToLine_monomial_eq_eval_of_degree_eq`.

**Success criterion.** The formula holds for all test cases, and the monomial case is provable in Lean (possibly requiring new API for multinomial coefficients). Failure: the formula is incorrect for some specific monomial.

**Impact.** This would provide a complete "jet expansion API" expressing all coefficients of a line restriction in terms of the polynomial's graded structure. It would be the formal foundation for directional derivative calculus, enabling verified proofs in microlocal analysis, differential algebra, and symbolic computation.

---

## Hypothesis 5: Tropical Initial-Form Analogue

**Conjecture.** In tropical mathematics (where addition is replaced by min and multiplication by addition), the tropical analogue of the coefficient extraction theorem holds: the "initial form" of a tropical polynomial along a tropical line in direction $v$ is determined by the tropical homogeneous component of the polynomial.

Specifically, for a tropical polynomial $P(X) = \min_{s} (a_s + \sum_i s_i X_i)$ and the tropical line $X_i = x_i + t \cdot v_i$, the slope of $P(x + tv)$ as a function of $t$ (i.e., the coefficient of $t$ in the tropical restriction) equals the tropical evaluation of the top-degree tropical homogeneous component of $P$ at $v$:

$$\text{trop-slope}(P \circ \ell_{x,v}) = \min_{\substack{s : |s| = d}} \left(a_s + \sum_i s_i v_i\right)$$

**Test.** Implement tropical polynomial evaluation and line restriction in Python. Verify the conjecture for:
1. All tropical polynomials with support size $\leq 10$ and degree $\leq 4$ in 2–3 variables.
2. Random coefficient vectors in $\{-10, \ldots, 10\}$.
3. All directions $v$ in a suitable lattice.

**Success criterion.** The tropical initial-form identity holds for all test cases, and the proof strategy from the algebraic case (monomial-by-monomial + linearity) adapts to the tropical setting. Failure: a counterexample is found, or the tropical version requires fundamentally different proof techniques.

**Impact.** A tropical coefficient extraction theorem would connect the polynomial method to tropical geometry, optimization, and computational geometry. It could enable tropical Kakeya-type bounds and provide new tools for analyzing tropical varieties and their intersections with linear subspaces. This would be the seed of a "tropical directional algebra" theory.

---

## Summary Table

| # | Hypothesis | Key Test | Timeline | Risk Level |
|---|-----------|----------|----------|------------|
| 1 | Hasse derivative coefficient formula | Compute over $\mathbb{F}_5^2$ | 1–2 weeks | Medium |
| 2 | Extremizer rigidity in $\mathbb{F}_q^2$ | Exhaustive search $q \leq 7$ | 2–4 weeks | High |
| 3 | Energy gap beyond Cauchy-Schwarz | Numerical survey $q \leq 19$ | 1–2 weeks | Medium-High |
| 4 | Full jet expansion API | Formal verification | 2–3 weeks | Low |
| 5 | Tropical initial-form analogue | Tropical computation | 1–2 weeks | Medium |

Each hypothesis is designed to be testable within weeks, not years. They range from near-certain (Hypothesis 4, which is essentially a combinatorial identity) to genuinely speculative (Hypothesis 2, which touches on deep structural questions about finite geometry). Together, they define a research program that extends the coefficient extraction theorem from a single formal result into a theory of directional algebraic extraction.
