# Future Directions: Arithmetic Monodromy Fingerprints of Gradient Descent

## Conjecture 1: Arithmetic Fingerprint Separation for Quartic Families

**Conjecture:** Let $f_a(x) = x^4 - 2ax^2$ and $f_b(x) = x^4 - 2bx^2$ with $a, b \in \mathbb{Z} \setminus \{0\}$. If $a/b$ is not a perfect square in $\mathbb{Q}$, then there exist infinitely many odd primes $p$ for which the gradient descent maps $T(x) = x - f'(x)$ over $\mathbb{F}_p$ have different fixed-point counts:
$$\#\text{FixedPts}_p(f_a) \neq \#\text{FixedPts}_p(f_b).$$

**Test:** For primes $p \leq B$ (starting with $B = 10^4$), compute fixed-point counts for both families. The conjecture predicts a separation rate stabilizing near $50\%$ (governed by quadratic reciprocity). If the separation frequency drops to zero for large $B$, the conjecture is refuted.

**Impact:** This would establish the first rigorous arithmetic invariant distinguishing optimization landscapes that are topologically identical over $\mathbb{R}$.

---

## Conjecture 2: Critical-Value Splitting Predicts Cycle-Length Distribution

**Conjecture:** For generic integer polynomials $f, g$ of degree $d \geq 3$ with distinct splitting fields for their critical-value polynomials (the polynomial whose roots are $f(c_i)$ for critical points $c_i$), the cycle-length distributions of the gradient step maps over $\mathbb{F}_p$ differ for a positive density of primes.

**Test:** For degree-4 polynomials, compute the splitting field of the critical-value polynomial over $\mathbb{Q}$. For pairs with different Galois groups, compute cycle-length histograms of $T_{f,1}$ over $\mathbb{F}_p$ for $p \leq 10^3$. Compare distributions using Kolmogorov–Smirnov tests. If pairs with distinct Galois groups consistently show $p$-value $< 0.01$, the conjecture is supported.

**Impact:** Would provide the first bridge from Galois theory of critical values to dynamics of optimization, opening the door to monodromy-based trainability analysis.

---

## Conjecture 3: Basin-Size Distribution Determines the Polynomial Up to Arithmetic Equivalence

**Conjecture:** Two polynomials $f, g \in \mathbb{Z}[X]$ of degree $d$ with the same basin-size distributions over $\mathbb{F}_p$ for all but finitely many primes $p$ must satisfy: the splitting fields of $f'$ and $g'$ over $\mathbb{Q}$ are isomorphic as Galois extensions.

**Test:** Enumerate all monic integer polynomials of degree 4 with coefficients in $\{-5, \ldots, 5\}$. For each pair, check if basin distributions match for all primes $p \leq 200$. Among matching pairs, verify whether their derivative splitting fields are isomorphic (using PARI/GP or Sage). A single counterexample—matching basins but non-isomorphic splitting fields—refutes the conjecture.

**Impact:** If true, this gives a dynamical characterization of arithmetic equivalence: optimization dynamics modulo primes fully determines the Galois structure of critical loci.

---

## Conjecture 4: Multivariate Fingerprint Separation via Hessian Discriminants

**Conjecture:** For multivariate polynomial losses $f, g : \mathbb{Z}^n \to \mathbb{Z}$ of total degree $d$, if the discriminants of the Hessian determinant polynomials $\det(\text{Hess}(f))$ and $\det(\text{Hess}(g))$ have different square-free parts, then the gradient descent functional graphs over $\mathbb{F}_p^n$ have different cycle structures for infinitely many primes $p$.

**Test:** Start with $n = 2$, $d = 3$. Compute Hessian discriminants symbolically. For families with distinct discriminants, enumerate $\mathbb{F}_p^2$ for $p \leq 100$ and compare functional graph invariants (number of fixed points, cycle lengths, connected components). Failure condition: if families with distinct Hessian discriminants show identical functional graph invariants for all tested primes.

**Impact:** Extends the univariate theory to the multivariate setting relevant to actual machine learning losses, where the Hessian replaces the second derivative.

---

## Conjecture 5: p-Adic Convergence Rates of Gradient Descent Are Controlled by Newton Polygons

**Conjecture:** For a polynomial $f \in \mathbb{Z}_p[X]$ and step size $\eta \in \mathbb{Z}_p$, the $p$-adic convergence rate of gradient descent iterates $T^n(x_0)$ to a critical point $c$ is determined by the slopes of the Newton polygon of $f'(X) - f'(c)$ at $X = c$. Specifically, if the smallest slope of the Newton polygon is $\lambda$, then $|T^n(x_0) - c|_p \leq C \cdot p^{-\lambda n}$ for $x_0$ sufficiently close to $c$.

**Test:** For the cubic family $f_a(x) = x^3 - ax$ over $\mathbb{Z}_p$, compute Newton polygons of $f'(x) = 3x^2 - a$ at critical points $c = \pm\sqrt{a/3}$. Verify the convergence rate prediction by computing gradient iterates to high $p$-adic precision (e.g., mod $p^{100}$) and checking that the valuation $v_p(T^n(x_0) - c)$ grows linearly with slope $\lambda$. Failure: non-linear growth or disagreement with Newton polygon prediction.

**Impact:** Would establish a p-adic optimization theory, connecting classical algebraic geometry tools (Newton polygons) to convergence analysis, potentially leading to new insights about the arithmetic complexity of finding minima.
