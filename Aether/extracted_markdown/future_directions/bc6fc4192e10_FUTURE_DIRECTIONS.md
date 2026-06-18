# Future Directions: Arithmetic Phase Locking in Gradient Descent

## Conjecture A: Spectral Torsion Predicts Positive-Density Locking

**Precise Statement.** For a quadratic loss $L(w) = \frac{1}{2} w^\top A w + b^\top w + c$ over $\mathbb{Q}$, with gradient descent update $T(w) = (I - \eta A) w - \eta b$, let $M = I - \eta A$. If the semisimple part of $M$ has all eigenvalues that are roots of unity, then there exists $m > 0$ such that for a positive-density set of good primes $p$ (i.e., primes not dividing denominators of $A$, $b$, or $\eta$), every reduced orbit modulo $p$ has period dividing $m$.

**Test.** Sample rational quadratic losses (random $A \in \text{Mat}_n(\mathbb{Q})$, $b \in \mathbb{Q}^n$, $\eta \in \mathbb{Q}$). Compute the eigenvalues of $M = I - \eta A$ symbolically. For each of 10,000 primes $p < 100{,}000$, reduce the system mod $p$ and compute the orbit period from 100 random starting points. Measure the fraction of primes where all orbits have period dividing $m = \text{lcm}(\text{orders of eigenvalues})$. Compare this fraction between systems with root-of-unity eigenvalues and those without.

**Refutation.** Either (a) a family with non-root-of-unity semisimple part but persistent bounded-period locking on a positive-density set of primes, or (b) a family with root-of-unity semisimple part where the locking density is zero. Either outcome would refute the conjecture.

**Impact.** If true, this provides a computable spectral criterion for "trainability resonance" — a discrete analogue of Floquet theory for optimization that could predict training instabilities from the loss Hessian alone.

---

## Conjecture B: Large Galois Monodromy Implies Long Modular Orbits

**Precise Statement.** For a generic polynomial loss of degree $d \geq 3$ in $n$ variables, with rational coefficients and rational step size, if the arithmetic monodromy group of the gradient descent update map (viewed as a rational self-map of $\mathbb{A}^n$) is not virtually solvable, then for density-1 good primes $p$, the reduced orbit length from a generic rational initialization $w_0$ grows at least like $p^\delta$ for some $\delta > 0$ depending only on $d$ and $n$.

**Test.** For cubic and quartic polynomial losses in 2 variables, compute the orbit length modulo primes $p \in [100, 10000]$ from random initializations. Fit the growth rate to $p^\delta$ and estimate $\delta$. Compare against the monodromy group (computed via specialization or numerical algebraic geometry). Systems with full symmetric monodromy should show $\delta \approx 1$; those with abelian monodromy should show $\delta \approx 0$.

**Refutation.** A family with non-solvable monodromy but uniformly bounded orbit lengths for a positive-density set of primes.

**Impact.** This would establish the "non-locking" side of the arithmetic dichotomy and connect optimization complexity to Galois-theoretic invariants — a genuinely new bridge between computational learning theory and arithmetic geometry.

---

## Conjecture C: Arithmetic Locking Correlates with Flat Critical Skeletons

**Precise Statement.** Consider polynomial losses $L : \mathbb{Q}^n \to \mathbb{Q}$ of degree $d$. Define the "Hessian resonance" at a critical point $w^*$ as the number of eigenvalue ratios of $\nabla^2 L(w^*)$ that are roots of unity. The conjecture is: losses with higher Hessian resonance at their critical points exhibit elevated prime-density phase locking (more primes $p$ where the reduced orbit has bounded period) compared to generic Morse losses where no eigenvalue ratios are roots of unity.

**Test.** Generate families of degree-4 losses in 2 variables. At each critical point, compute the Hessian eigenvalue ratios. Classify losses by their Hessian resonance score (0, 1, or 2 resonant ratios). For each family, compute the fraction of primes $p < 10{,}000$ where the gradient descent orbit (from a fixed initialization) has period $\leq 100$. Plot locking density vs. resonance score.

**Refutation.** No statistically significant correlation between Hessian resonance and locking density across a large sample of losses.

**Impact.** Would connect the arithmetic dynamics of optimization to the classical theory of resonant Hamiltonian systems and provide a new diagnostic for "loss landscape flatness" — a concept central to deep learning generalization theory.

---

## Conjecture D: Affine Phase Locking Extends to Nilpotent Perturbations

**Precise Statement.** Let $T(x) = Mx + b$ where $M = S + N$ with $S$ semisimple (diagonalizable over $\overline{\mathbb{Q}}$), $N$ nilpotent, $SN = NS$, and $S^m = I$ for some $m > 0$. If $N^k = 0$ (nilpotency index $k$) and the geometric sum condition $\sum_{j=0}^{m-1} M^j b = 0$ holds, then $T^{m \cdot k!} = \text{id}$ over $\mathbb{Z}$ (after clearing denominators), and hence every orbit modulo every good prime has period dividing $m \cdot k!$.

**Test.** Construct explicit affine systems with Jordan blocks where $S$ has finite order and $N$ is strictly upper triangular. Verify the period bound $m \cdot k!$ computationally for primes up to $10{,}000$. Check whether the bound is tight (i.e., whether the actual period equals $m \cdot k!$ for some prime and some starting point).

**Refutation.** A system satisfying the hypotheses where some orbit modulo some good prime has period not dividing $m \cdot k!$.

**Impact.** Extends our Theorem 4 (affine torsion locking) from the semisimple case to the full quasi-unipotent case, completing the affine theory. This is the natural next step toward the full spectral criterion.

---

## Conjecture E: Phase Locking Density Is Computable from the Chebotarev Distribution

**Precise Statement.** For a polynomial gradient descent map $T : \mathbb{Q}^n \to \mathbb{Q}^n$ with good reduction at all but finitely many primes, the density of primes $p$ for which the reduced orbit has period dividing $m$ equals the density of Frobenius elements in a specific conjugacy class of the arithmetic monodromy group $G$ of the $m$-th dynatomic polynomial of $T$. In particular, this density is a rational number computable from $G$.

**Test.** For 1D quadratic maps $T(x) = x^2 + c$ with $c \in \mathbb{Q}$, compute the dynatomic polynomials for periods $m = 1, 2, 3$. Factor them and determine their Galois groups. Use the Chebotarev density theorem to predict the density of primes where the orbit from $x_0 = 0$ has period dividing $m$. Compare against empirical counts for primes $p < 10^6$.

**Refutation.** Systematic deviation between predicted and observed locking densities beyond what finite-sample effects can explain.

**Impact.** Would establish a complete quantitative theory of arithmetic phase locking densities, reducing the optimization-theoretic question to a computation in algebraic number theory. This is the most ambitious direction and would constitute a major theorem in arithmetic dynamics.
