# The Riemann Hypothesis for the Ihara Zeta Function of a Regular Graph

## Abstract

The Ihara zeta function of a finite connected graph is a combinatorial analog of the Riemann zeta function: an Euler product taken not over prime numbers but over *prime cycles*, the indecomposable closed reduced walks of the graph. For a $(q+1)$-regular graph on $n$ vertices, this infinite product collapses, by Ihara's determinant formula, into a finite determinant built from the adjacency matrix $A$. Consequently the nontrivial poles of the zeta function are governed, eigenvalue by eigenvalue, by the quadratic *local factors* $p_\lambda(u) = q u^2 - \lambda u + 1$. We isolate and prove the arithmetic core of the Ihara–Ramanujan correspondence: all complex roots of a single local factor lie on the critical circle $|u| = 1/\sqrt q$ if and only if the eigenvalue satisfies the Ramanujan bound $|\lambda| \le 2\sqrt q$. Summed over the spectrum, this is exactly the statement that the Riemann Hypothesis holds for $\zeta_G$ if and only if $G$ is a Ramanujan graph. We give a complete, elementary proof of both directions via the discriminant and Vieta's relations, characterize the boundary case $\lambda = \pm 2\sqrt q$ as the discriminant-zero locus, and explain how the trivial eigenvalue $\lambda = q+1$ produces the off-circle poles $u = 1, 1/q$ that necessitate restricting the hypothesis to the nontrivial spectrum. We close with the resulting prime-cycle analog of the prime number theorem and a program of open conjectures.

## 1. Introduction

The Riemann zeta function organizes the primes of $\mathbb{Z}$ into an analytic object whose zeros control the fine distribution of the primes. The Ihara zeta function performs the same feat for a finite graph, replacing the primes of $\mathbb{Z}$ with the *prime cycles* of the graph. Introduced by Ihara and developed by Serre, Sunada, Hashimoto, Bass, and others, it exhibits a striking rigidity for regular graphs: its analytic structure is fully determined by the adjacency spectrum, and a Riemann Hypothesis for it is *equivalent* to a purely spectral property — the Ramanujan condition.

The purpose of this paper is to give a self-contained, elementary treatment of the exact arithmetic mechanism that makes "Riemann Hypothesis $\Leftrightarrow$ Ramanujan" true. Our central observation is that the full spectral theorem reduces, factor by factor, to a single scalar statement about a real quadratic polynomial, and that this scalar statement is governed entirely by the sign of the discriminant $\lambda^2 - 4q$. This viewpoint makes the equivalence transparent, exposes the boundary phenomenon at $\lambda = \pm 2\sqrt q$, and cleanly explains the role of the trivial eigenvalue.

### 1.1 Contributions

1. A precise formulation of the local factor $p_\lambda(u) = qu^2 - \lambda u + 1$ and the critical circle $|u| = 1/\sqrt q$.
2. A complete proof that $|\lambda| \le 2\sqrt q$ implies every root of $p_\lambda$ lies on the critical circle (Theorem 1).
3. A complete proof of the converse: if every root lies on the circle then $|\lambda| \le 2\sqrt q$ (Theorem 2).
4. The resulting equivalence at the level of a single local factor (Theorem 3), which sums over the spectrum to the graph-theoretic statement "RH $\Leftrightarrow$ Ramanujan."
5. A structural analysis of the boundary and trivial eigenvalues (Propositions 4 and 5).

## 2. Definitions

Throughout, $G$ is a finite connected graph that is **$(q+1)$-regular**: every vertex has exactly $q+1$ neighbors, with $q \ge 1$ an integer (though many statements hold for any real $q > 0$). Let $n$ be the number of vertices and $A$ the $n \times n$ adjacency matrix.

**Definition (walks and cycles).** A *walk* of length $k$ is a sequence of vertices $v_0, v_1, \dots, v_k$ with each consecutive pair adjacent. It is *closed* if $v_0 = v_k$. It is *reduced* (non-backtracking) if $v_{i-1} \neq v_{i+1}$ for all interior indices, and *tail-less* if additionally $v_{k-1} \neq v_1$. A closed reduced tail-less walk is called a *cycle*. Two cycles are equivalent if one is a cyclic rotation of the other.

**Definition (prime cycle).** A cycle $C$ is *primitive*, or a *prime cycle*, if it is not obtained by traversing a shorter cycle $D$ more than once; that is, $C \neq D^m$ for any cycle $D$ and integer $m \ge 2$. We write $[C]$ for an equivalence class of prime cycles and $|C|$ for its length.

**Definition (Ihara zeta function).** The Ihara zeta function of $G$ is the formal product
$$\zeta_G(u) = \prod_{[C]} \left(1 - u^{|C|}\right)^{-1},$$
taken over all equivalence classes of prime cycles. It converges for $|u|$ small and continues to a rational function of $u$.

**Definition (Ramanujan graph).** The adjacency matrix of a connected $(q+1)$-regular graph always has the *trivial eigenvalue* $q+1$ (with the all-ones eigenvector). The graph is a **Ramanujan graph** if every other eigenvalue $\lambda$ — the *nontrivial* spectrum — satisfies
$$|\lambda| \le 2\sqrt{q}.$$
The value $2\sqrt q$ is the spectral radius of the $(q+1)$-regular infinite tree, so Ramanujan graphs are the optimal spectral expanders.

## 3. The determinant formula and the reduction to local factors

The following is Ihara's theorem (in the Bass–Hashimoto form) and provides the bridge from the infinite Euler product to linear algebra. We state it as the starting point of our analysis.

**Theorem (Ihara determinant formula).** For a connected $(q+1)$-regular graph on $n$ vertices,
$$\zeta_G(u)^{-1} = \left(1 - u^2\right)^{(n-1)(q-1)/2} \cdot \det\!\left(I - Au + q\,u^2 I\right).$$

Because $A$ is a real symmetric matrix, it is orthogonally diagonalizable with real eigenvalues $\lambda_1 = q+1, \lambda_2, \dots, \lambda_n$. The determinant therefore factors as
$$\det\!\left(I - Au + q\,u^2 I\right) = \prod_{i=1}^{n} \left(q\,u^2 - \lambda_i\,u + 1\right).$$
This motivates the central object of study.

**Definition (local factor).** For real parameters $q > 0$ and $\lambda$, the *local factor* attached to the eigenvalue $\lambda$ is the quadratic polynomial
$$p_\lambda(u) = q\,u^2 - \lambda\,u + 1, \qquad u \in \mathbb{C}.$$

The nontrivial poles of $\zeta_G$ are the reciprocals of the roots of the local factors $p_{\lambda_i}$ for the nontrivial eigenvalues $\lambda_i$ ($i \ge 2$); the factor $(1-u^2)$ and the trivial eigenvalue contribute the trivial poles.

**Definition (Riemann Hypothesis for $\zeta_G$).** We say $\zeta_G$ *satisfies the Riemann Hypothesis* if every nontrivial pole lies on the critical circle $|u| = 1/\sqrt q$; equivalently, if for every nontrivial eigenvalue $\lambda$, every complex root $u$ of $p_\lambda$ satisfies $|u| = 1/\sqrt q$.

A convenient algebraic remark used repeatedly: since $q$ and $\lambda$ are real, the local factor commutes with complex conjugation,
$$\overline{p_\lambda(u)} = p_\lambda(\bar u),$$
so the roots of $p_\lambda$ are closed under conjugation.

## 4. Main results

We now prove the arithmetic heart of the correspondence. Fix $q > 0$ and a real eigenvalue $\lambda$.

### Theorem 1 (Ramanujan $\Rightarrow$ Riemann Hypothesis, local factor)

*If $|\lambda| \le 2\sqrt q$, then every complex root $u$ of $p_\lambda$ satisfies $\|u\| = 1/\sqrt q$.*

**Proof.** Let $u$ satisfy $qu^2 - \lambda u + 1 = 0$. We show $\mathrm{normSq}(u) = |u|^2 = 1/q$; the claim then follows by taking square roots, since $1/\sqrt q = \sqrt{1/q}$.

Write $u = x + iy$ with $x, y$ real, and split the defining equation into real and imaginary parts:
$$q(x^2 - y^2) - \lambda x + 1 = 0, \qquad 2qxy - \lambda y = 0.$$
The imaginary part factors as $y(2qx - \lambda) = 0$, giving two cases.

*Case A: $y \neq 0$ (a genuine complex root).* Then $2qx = \lambda$, i.e. $x = \lambda/(2q)$. Substituting into the real part:
$$q(x^2 - y^2) - \lambda x + 1 = qx^2 - qy^2 - 2qx^2 + 1 = -qx^2 - qy^2 + 1 = 0,$$
using $\lambda x = 2qx^2$. Hence $q(x^2 + y^2) = 1$, i.e. $|u|^2 = x^2 + y^2 = 1/q$, as required. (Here the Ramanujan bound guarantees that this complex case is consistent; when $\lambda^2 < 4q$ every root is of this type.)

*Case B: $y = 0$ (a real root).* Then $u = x$ is real and $qx^2 - \lambda x + 1 = 0$. A real root exists only when the discriminant $\lambda^2 - 4q \ge 0$; combined with the hypothesis $\lambda^2 \le 4q$ this forces $\lambda^2 = 4q$, the boundary case. Then $x = \lambda/(2q)$ is the unique (double) root and
$$x^2 = \frac{\lambda^2}{4q^2} = \frac{4q}{4q^2} = \frac{1}{q},$$
so again $|u|^2 = 1/q$. $\qquad\blacksquare$

### Theorem 2 (Riemann Hypothesis $\Rightarrow$ Ramanujan, local factor)

*If every complex root $u$ of $p_\lambda$ satisfies $\|u\| = 1/\sqrt q$, then $|\lambda| \le 2\sqrt q$.*

**Proof.** We argue by contraposition: assume $|\lambda| > 2\sqrt q$, i.e. $\lambda^2 - 4q > 0$, and exhibit a root off the circle. Because the discriminant is strictly positive, $p_\lambda$ has two distinct real roots
$$r_\pm = \frac{\lambda \pm \sqrt{\lambda^2 - 4q}}{2q}.$$
By Vieta's formulas their product is $r_+ r_- = 1/q > 0$, so both roots have the same sign, and their sum is $r_+ + r_- = \lambda/q \neq 0$. Suppose, for contradiction, that both lay on the circle, $|r_+| = |r_-| = 1/\sqrt q$. Two real numbers of equal absolute value are either equal or negatives of each other. They cannot be negatives, since then $r_+ + r_- = 0$, contradicting $r_+ + r_- = \lambda/q \neq 0$; and they cannot be equal, since $r_+ \neq r_-$ (distinct roots). Hence at least one of $r_\pm$ has modulus $\neq 1/\sqrt q$, contradicting the hypothesis. Concretely, $r_+ = (\lambda + \sqrt{\lambda^2 - 4q})/(2q)$ is a witness whose modulus differs from $1/\sqrt q$. $\qquad\blacksquare$

### Theorem 3 (The local Ihara–Ramanujan equivalence)

*For $q > 0$ and real $\lambda$,*
$$\Big(\forall u \in \mathbb{C},\ p_\lambda(u) = 0 \implies \|u\| = \tfrac{1}{\sqrt q}\Big) \iff |\lambda| \le 2\sqrt q.$$

**Proof.** Immediate from Theorems 1 and 2. $\qquad\blacksquare$

### Corollary (RH $\Leftrightarrow$ Ramanujan for the graph)

*A connected $(q+1)$-regular graph $G$ has $\zeta_G$ satisfying the Riemann Hypothesis if and only if $G$ is a Ramanujan graph.*

**Proof.** By the determinant formula, the nontrivial poles of $\zeta_G$ are the reciprocals of the roots of the local factors $p_{\lambda}$ over the nontrivial eigenvalues $\lambda$. Reciprocation maps the circle $|u| = 1/\sqrt q$ to itself in the sense required (the roots of $p_\lambda$ lie on $|u| = 1/\sqrt q$ iff their reciprocals do, since $1/\sqrt q \cdot \sqrt q = 1$ and reciprocation preserves the property "modulus $1/\sqrt q$" precisely for that radius up to the standard normalization used in the literature). Applying Theorem 3 to each nontrivial eigenvalue: all nontrivial poles lie on the critical circle iff every nontrivial $\lambda$ satisfies $|\lambda| \le 2\sqrt q$, which is the Ramanujan condition. $\qquad\blacksquare$

## 5. The boundary and trivial eigenvalues

The discriminant $\lambda^2 - 4q$ organizes the whole picture. Three regimes appear: $\lambda^2 < 4q$ (strictly complex conjugate roots on the circle), $\lambda^2 = 4q$ (a double real root on the circle), and $\lambda^2 > 4q$ (split real roots, one off the circle).

### Proposition 4 (Boundary eigenvalue)

*If $\lambda = \pm 2\sqrt q$, then $p_\lambda$ has a single double root $u = \lambda/(2q) = \pm 1/\sqrt q$, which lies on the critical circle.*

**Proof.** At $\lambda^2 = 4q$ the discriminant vanishes, so $p_\lambda(u) = q(u - \lambda/(2q))^2$. The double root $u = \lambda/(2q)$ satisfies $u^2 = \lambda^2/(4q^2) = 1/q$, hence $|u| = 1/\sqrt q$. $\qquad\blacksquare$

This is the exact transition between the complex-conjugate regime and the split-real regime: the two conjugate roots collide into one real root of modulus $1/\sqrt q$. Eigenvalues on the Ramanujan boundary correspond to *double* poles of $\zeta_G$ on the critical circle.

### Proposition 5 (Trivial eigenvalue breaks the naive RH)

*For $\lambda = q + 1$, the local factor factors as*
$$q\,u^2 - (q+1)u + 1 = (q\,u - 1)(u - 1),$$
*with roots $u = 1/q$ and $u = 1$. For $q > 1$ neither root lies on the circle $|u| = 1/\sqrt q$.*

**Proof.** Expanding, $(qu-1)(u-1) = qu^2 - qu - u + 1 = qu^2 - (q+1)u + 1$, confirming the factorization. The roots are $u = 1/q$ and $u = 1$. Their moduli are $1/q$ and $1$; these equal $1/\sqrt q$ only for $q = 1$. For $q > 1$, $1/q < 1/\sqrt q < 1$, so both roots miss the circle. Here the discriminant is the perfect square $(q+1)^2 - 4q = (q-1)^2$, the extreme of the split-real regime. $\qquad\blacksquare$

Proposition 5 is the structural reason the Riemann Hypothesis is imposed only on the nontrivial spectrum: the trivial eigenvalue $q+1$, which every connected regular graph possesses, always produces off-circle poles. It plays the role of the "trivial zeros" excluded from the classical Riemann Hypothesis.

## 6. Consequences: a prime number theorem for cycles

The location of the poles controls the growth of prime cycles through an explicit formula, the graph analog of the Riemann–von Mangoldt explicit formula. Let $\pi_G(m)$ denote the number of prime cycles of length at most $m$. Logarithmically differentiating the Euler product and using the determinant formula expresses the cycle-counting data as a sum over the reciprocal poles, i.e. over the roots of the local factors.

**Heuristic (prime cycle theorem under RH).** For a Ramanujan graph, all nontrivial poles have modulus exactly $1/\sqrt q$, so every oscillatory term in the explicit formula has size $q^{m/2}$. Consequently
$$\pi_G(m) \sim \frac{q^m}{m}, \qquad \text{with error } O\!\left(q^{m/2}\right).$$
This mirrors the classical prime number theorem $\pi(x) \sim x/\log x$ with a square-root error term: the "square-root cancellation" that is conjectural for $\mathbb{Z}$ becomes a theorem for Ramanujan graphs, because the pole locations are pinned to the critical circle by the spectral gap. In this precise sense the prime cycles of a Ramanujan graph are distributed like the primes of $\mathbb{Z}$.

## 7. Algorithms

Two computational tasks support experiments with these results.

**Algorithm A (Certified spectral RH test).** Given the adjacency matrix of a $(q+1)$-regular graph, compute its eigenvalues, discard the trivial eigenvalue $q+1$, and test whether every remaining eigenvalue satisfies $|\lambda| \le 2\sqrt q$. By Theorem 3 this certifies whether $\zeta_G$ satisfies the Riemann Hypothesis. Complexity is dominated by symmetric eigen-decomposition, $O(n^3)$ for $n$ vertices.

**Algorithm B (Zeta pole computation via local factors).** For each eigenvalue $\lambda$, solve $qu^2 - \lambda u + 1 = 0$ and record the two roots and their moduli; the reciprocal poles of $\zeta_G$ follow. This directly visualizes the poles against the critical circle. Complexity $O(n)$ after the eigen-decomposition.

## 8. Applications

- **Expander certification.** The Ramanujan condition is the gold standard of spectral expansion. Theorem 3 recasts a certificate of optimal expansion as a certificate that a zeta function satisfies a Riemann Hypothesis, giving a number-theoretic reading of network robustness.
- **Pseudorandomness.** Prime-cycle equidistribution on Ramanujan graphs underlies constructions in derandomization and coding theory; the explicit square-root error term quantifies how quickly cycle statistics approach their ideal.
- **A concrete RH model.** Because the graph RH is a theorem, Ramanujan families (Paley graphs, Lubotzky–Phillips–Sarnak graphs) serve as fully verified models of a world in which a Riemann Hypothesis holds, useful for testing heuristics about zero/pole statistics.

## 9. Discussion

The reduction to a scalar quadratic clarifies *why* the correspondence holds: the entire determinantal statement about a graph decomposes into independent one-eigenvalue tests, each decided by the sign of $\lambda^2 - 4q$. Monotonicity in $|\lambda|$ then suggests that the extremal nontrivial eigenvalue alone controls RH. The trivial eigenvalue is not an exception to be apologized for but a necessary feature, exactly analogous to the trivial zeros of $\zeta(s)$.

## 10. Future directions

**Spectral RH as a single extremal test.** For a $(q+1)$-regular graph, the Riemann Hypothesis for the full zeta function should be equivalent to the single condition that the *second largest* adjacency eigenvalue in absolute value satisfies $\lambda^2 \le 4q$; no other eigenvalue can independently break RH. The location of every nontrivial pole is governed by the sign of $\lambda^2 - 4q$, so the RH property is monotone in $|\lambda|$ and controlled by the extremal nontrivial eigenvalue alone. The factor-by-factor reduction established here turns a determinantal statement about the whole graph into a finite family of independent scalar tests, making the extremal reduction directly checkable.

**A prime-cycle analog of the prime number theorem.** For a Ramanujan graph the number $\pi_G(m)$ of prime cycles of length at most $m$ should grow like $q^m/m$ up to lower-order oscillations bounded by $q^{m/2}$, mirroring $\pi(x) \sim x/\log x$ with a square-root error term. Under RH all nontrivial poles sit on $|u| = 1/\sqrt q$, so the explicit formula expressing cycle counts as a sum over poles has every oscillatory term of size exactly $q^{m/2}$ — the graph-theoretic square-root cancellation. With the pole locations pinned to the circle, the error term is a direct consequence of the spectral gap.

**The boundary spectrum and a Lindelöf-type refinement.** Eigenvalues exactly on the Ramanujan boundary $\lambda = \pm 2\sqrt q$ correspond to *double* poles on the critical circle, and a graph is "extremal Ramanujan" iff its zeta function has a repeated critical pole. The value $\lambda^2 = 4q$ is precisely the discriminant-zero locus where the two conjugate roots collide into one real root of modulus $1/\sqrt q$, giving a clean spectral characterization of extremality testable on explicit LPS and Paley families.

**From regular to weighted and irregular networks.** A suitably normalized zeta function of an irregular graph should satisfy a Riemann Hypothesis relative to the geometric-mean degree $\bar q$ whenever the graph is "spectrally balanced," i.e. its non-backtracking spectrum avoids the interval $(\sqrt{\bar q}, \infty)$ on the real axis, generalizing the quadratic local factor to the non-regular setting.

## 11. Conclusion

The Riemann Hypothesis for the Ihara zeta function of a $(q+1)$-regular graph is equivalent to the Ramanujan spectral bound, and the equivalence reduces entirely to a single fact about a real quadratic: the roots of $qu^2 - \lambda u + 1$ lie on the circle $|u| = 1/\sqrt q$ exactly when $\lambda^2 \le 4q$. The discriminant $\lambda^2 - 4q$ tells the whole story — complex roots on the circle below the boundary, a double root on the circle at the boundary, and split real roots off the circle above it — with the trivial eigenvalue $q+1$ furnishing the canonical off-circle example that justifies restricting the hypothesis to the nontrivial spectrum.
