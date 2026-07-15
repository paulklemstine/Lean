# Cubic Spectral Gaps in a One-Dimensional Swap Model

**Aristotle**  
**15 July 2026**

## Abstract

We study a one-dimensional local-swap model whose state graph is the unit-weight path on $n$ sites. Using an unnormalized ordered-pair variation, we define the spectral gap as the infimum of a Rayleigh quotient over all nonconstant real observables. Two complementary estimates determine its order. First, the position observable has oriented Dirichlet energy $2(n-1)$ and pairwise variation $n^2(n^2-1)/6$, giving the exact witness quotient $12/[n^2(n+1)]$ and hence an upper bound of $12n^{-3}$. Second, telescoping each endpoint difference along the unique path and applying Cauchy–Schwarz gives the Poincaré inequality $\mathcal V(f)\le n^3E_{\mathrm{edge}}(f)$ for every observable $f$. Since the oriented energy is twice the edge energy, this yields the lower bound $2n^{-3}$. Consequently, for every $n\ge2$, the gap $\gamma_n$ satisfies

$$
\frac{2}{n^3}\le \gamma_n\le \frac{12}{n^3},
$$

and is therefore $\Theta(n^{-3})$. The proof cleanly separates a slowly varying witness from an all-observable routing estimate. We discuss numerical computation, edge congestion, possible sharpening by discrete cosine modes, tensor products, and applications to more complicated swap reconfiguration spaces.

## 1. Introduction

Local reconfiguration dynamics arise when a complex state may change only through elementary moves. Adjacent transpositions, local updates of a polymer, nearest-neighbor exchanges, and combinatorial sampling chains all fit this pattern. A central question is how local mobility controls global relaxation.

The spectral gap provides a variational measure of this relaxation. Small gap means that an observable can maintain substantial global variation while paying little local energy; such an observable represents a slow mode. Estimating the gap requires two logically distinct arguments. An upper bound needs only one carefully designed test function. A lower bound must control every nonconstant function.

The path is the simplest geometry in which these mechanisms can be separated and examined exactly enough to reveal their scaling. Consider $n$ sites arranged in a line, with unit-weight transitions only between consecutive sites. The position function changes by one across each edge, so its local energy grows like $n$. Its global pairwise variation grows like $n^4$. This immediately suggests a quotient of order $n^{-3}$.

The nontrivial issue is whether another observable can have an even smaller quotient. The answer is no, up to a universal constant. Any difference $f(i)-f(j)$ is a telescoping sum of adjacent increments along the unique path from $i$ to $j$. Cauchy–Schwarz charges its square to the path length times the adjacent-edge energy. There are $n^2$ ordered endpoint pairs and no route is longer than $n$, giving a global $n^3$ comparison.

The main result is the following.

**Theorem 1 (Two-sided cubic spectral estimate).** For the unit-weight path on $n\ge2$ sites, let $\gamma_n$ be the infimum of the oriented-energy-to-ordered-pair-variation quotient over all nonconstant real observables. Then

$$
\frac{2}{n^3}\le \gamma_n\le\frac{12}{n^3}.
$$

In particular, $\gamma_n=\Theta(n^{-3})$.

The normalization in Theorem 1 is stated explicitly because it differs by a factor depending on $n$ from conventions based on probability variance. Under the present convention, the variation is summed over all ordered pairs without division by $2n^2$.

The paper proceeds as follows. Section 2 defines the path, energies, variation, Rayleigh quotient, and gap. Section 3 establishes elementary identities. Section 4 derives the position-witness upper bound. Section 5 proves the telescoping Poincaré inequality and the lower bound. Section 6 presents algorithms for numerical evaluation. Sections 7 and 8 discuss interpretation, applications, limitations, and future directions.

## 2. Definitions and normalization

### 2.1. The unit path

Fix an integer $n\ge0$ and write

$$
V_n=\{0,1,\ldots,n-1\}.
$$

The unit-weight path has symmetric weight matrix $Q_n$ given by

$$
Q_n(i,j)=
\begin{cases}
1,& |i-j|=1,\\
0,& \text{otherwise}.
\end{cases}
$$

Thus each undirected edge $\{k,k+1\}$ occurs in two orientations, $(k,k+1)$ and $(k+1,k)$.

### 2.2. Adjacent-edge and oriented Dirichlet energies

For an observable $f:V_n\to\mathbb R$, define its unoriented adjacent-edge energy by

$$
E_{\mathrm{edge}}(f)
=\sum_{k=0}^{n-2}\bigl(f(k+1)-f(k)\bigr)^2.
$$

When $n<2$, the sum is empty and equals zero. The oriented Dirichlet energy associated with $Q_n$ is

$$
\mathcal E_n(f)
=\sum_{i\in V_n}\sum_{j\in V_n}Q_n(i,j)\bigl(f(i)-f(j)\bigr)^2.
$$

### 2.3. Pairwise variation

Define the ordered-pair variation by

$$
\mathcal V_n(f)
=\sum_{i\in V_n}\sum_{j\in V_n}\bigl(f(i)-f(j)\bigr)^2.
$$

This quantity is translation-invariant: adding a constant to $f$ does not change it. It also satisfies the discrete variance identity

$$
\mathcal V_n(f)
=2\left(n\sum_{i=0}^{n-1}f(i)^2-
\left(\sum_{i=0}^{n-1}f(i)\right)^2\right).
$$

If $\bar f=n^{-1}\sum_i f(i)$ for $n>0$, then equivalently

$$
\mathcal V_n(f)=2n\sum_{i=0}^{n-1}\bigl(f(i)-\bar f\bigr)^2.
$$

Thus $\mathcal V_n(f)>0$ exactly when $f$ is nonconstant.

### 2.4. Rayleigh quotient and spectral gap

For nonconstant $f$, define

$$
R_n(f)=\frac{\mathcal E_n(f)}{\mathcal V_n(f)}.
$$

The combinatorial spectral gap in this normalization is

$$
\gamma_n=\inf\{R_n(f):f:V_n\to\mathbb R\text{ is nonconstant}\}.
$$

The restriction $n\ge2$ in the main theorem is essential: on an empty or singleton path there is no nonconstant observable.

## 3. Preliminary identities

We begin with three elementary facts that fix the normalization.

**Lemma 2 (Variation identity).** For every $f:V_n\to\mathbb R$,

$$
\mathcal V_n(f)
=2\left(n\sum_i f(i)^2-\left(\sum_i f(i)\right)^2\right).
$$

**Proof sketch.** Expand each squared difference:

$$
(f(i)-f(j))^2=f(i)^2-2f(i)f(j)+f(j)^2.
$$

After summing over ordered pairs, the first and third terms each contribute $n\sum_i f(i)^2$, while the middle term contributes $-2(\sum_i f(i))^2$. Combining terms gives the identity. $\square$

**Lemma 3 (Positivity of variation).** If $f$ is nonconstant, then $\mathcal V_n(f)>0$.

**Proof sketch.** Every summand in $\mathcal V_n(f)$ is nonnegative. If $f$ is nonconstant, some pair $(i,j)$ has $f(i)\ne f(j)$, and the corresponding squared difference is strictly positive. $\square$

**Lemma 4 (Oriented/unoriented energy identity).** For every $f:V_n\to\mathbb R$,

$$
\mathcal E_n(f)=2E_{\mathrm{edge}}(f).
$$

**Proof sketch.** Nonadjacent ordered pairs have zero weight. Each undirected edge $\{k,k+1\}$ contributes once in each orientation. The two squared differences are equal, because

$$
(f(k)-f(k+1))^2=(f(k+1)-f(k))^2.
$$

Summing over the $n-1$ undirected edges gives the factor of two. $\square$

These statements require no monotonicity and apply to arbitrary real profiles.

## 4. The slowly varying position witness

Let the position observable be

$$
p_n(k)=k,
\qquad 0\le k<n.
$$

For $n\ge2$, this observable is nonconstant.

**Lemma 5 (Energy of the position observable).** For $n\ge1$,

$$
\mathcal E_n(p_n)=2(n-1).
$$

**Proof sketch.** Every adjacent increment satisfies $p_n(k+1)-p_n(k)=1$. Hence $E_{\mathrm{edge}}(p_n)=n-1$, and Lemma 4 doubles this value. $\square$

The variation can be computed from the classical finite sums

$$
\sum_{k=0}^{n-1}k=\frac{n(n-1)}{2}
$$

and

$$
\sum_{k=0}^{n-1}k^2=\frac{n(n-1)(2n-1)}{6}.
$$

**Lemma 6 (Variation of the position observable).** For every $n\ge0$,

$$
\mathcal V_n(p_n)=\frac{n^2(n^2-1)}{6}.
$$

**Proof sketch.** Substitute the two finite-sum formulas into Lemma 2:

$$
\mathcal V_n(p_n)
=2\left(
 n\frac{n(n-1)(2n-1)}{6}
 -\left(\frac{n(n-1)}{2}\right)^2
\right).
$$

Elementary simplification yields $n^2(n^2-1)/6$. $\square$

Combining the energy and variation gives an exact witness value.

**Theorem 7 (Exact position-witness quotient).** For $n\ge2$,

$$
R_n(p_n)=\frac{12}{n^2(n+1)}.
$$

**Proof sketch.** Divide the expression from Lemma 5 by that from Lemma 6:

$$
R_n(p_n)
=\frac{2(n-1)}{n^2(n^2-1)/6}
=\frac{12(n-1)}{n^2(n-1)(n+1)}.
$$

Since $n\ge2$, cancellation of $n-1$ is valid. $\square$

**Corollary 8 (Cubic upper bound).** For $n\ge2$,

$$
\gamma_n\le \frac{12}{n^3}.
$$

**Proof sketch.** The gap is the infimum over all nonconstant observables, so it is at most the quotient of $p_n$. Since $n+1\ge n$,

$$
\gamma_n\le \frac{12}{n^2(n+1)}\le\frac{12}{n^3}.
$$

$\square$

The witness quotient itself lies in a more explicit cubic window.

**Corollary 9 (Witness scaling).** For $n\ge2$,

$$
\frac{6}{n^3}\le R_n(p_n)\le\frac{12}{n^3}.
$$

**Proof sketch.** The upper estimate is Corollary 8 applied to the exact witness quotient. For the lower estimate, $n+1\le2n$ gives

$$
\frac{12}{n^2(n+1)}\ge\frac{12}{2n^3}=\frac{6}{n^3}.
$$

$\square$

This result concerns the chosen witness, not the gap itself. The gap may be smaller, and the next section proves that it is not smaller by more than a universal factor.

## 5. A telescoping Poincaré inequality

The lower bound rests on the unique route between any two sites.

**Lemma 10 (Pairwise telescoping bound).** For every $f:V_n\to\mathbb R$ and all $i,j\in V_n$,

$$
\bigl(f(i)-f(j)\bigr)^2
\le nE_{\mathrm{edge}}(f).
$$

**Proof sketch.** The cases $i=j$ and $n<2$ are immediate. Suppose without loss of generality that $i<j$. Telescoping gives

$$
f(j)-f(i)=\sum_{k=i}^{j-1}\Delta_k,
\qquad
\Delta_k=f(k+1)-f(k).
$$

Cauchy–Schwarz implies

$$
\left(\sum_{k=i}^{j-1}\Delta_k\right)^2
\le (j-i)\sum_{k=i}^{j-1}\Delta_k^2.
$$

The route length satisfies $j-i\le n$, and the segment energy is at most the total nonnegative edge energy. Therefore

$$
(f(j)-f(i))^2\le nE_{\mathrm{edge}}(f).
$$

If $j<i$, interchange the endpoints; squaring removes the sign. $\square$

The use of $n$ rather than the slightly sharper $n-1$ keeps the subsequent expression simple. More importantly, the proof deliberately replaces the energy on the segment $[i,j]$ by the energy of the entire path. These two relaxations are where constant-factor information is lost.

**Theorem 11 (Path Poincaré inequality).** For every $f:V_n\to\mathbb R$,

$$
\mathcal V_n(f)\le n^3E_{\mathrm{edge}}(f).
$$

**Proof sketch.** Sum the inequality in Lemma 10 over all $n^2$ ordered pairs $(i,j)$. The left side becomes $\mathcal V_n(f)$, while the right side becomes

$$
n^2\cdot nE_{\mathrm{edge}}(f)=n^3E_{\mathrm{edge}}(f).
$$

$\square$

This is an all-observable estimate. Oscillation, nonmonotonicity, and sign changes do not affect the argument.

**Theorem 12 (Uniform Rayleigh lower bound).** Let $n\ge2$. Every nonconstant $f:V_n\to\mathbb R$ satisfies

$$
R_n(f)\ge\frac{2}{n^3}.
$$

**Proof sketch.** By Lemma 3, the denominator $\mathcal V_n(f)$ is positive. Theorem 11 and Lemma 4 give

$$
\mathcal V_n(f)
\le n^3E_{\mathrm{edge}}(f)
=\frac{n^3}{2}\mathcal E_n(f).
$$

Rearranging yields $\mathcal E_n(f)/\mathcal V_n(f)\ge2/n^3$. $\square$

**Corollary 13 (Cubic lower bound).** For $n\ge2$,

$$
\gamma_n\ge\frac{2}{n^3}.
$$

**Proof sketch.** Theorem 12 applies to every member of the family over which the infimum defining $\gamma_n$ is taken. $\square$

Combining Corollaries 8 and 13 proves Theorem 1.

## 6. Computational methods and numerical checks

The preceding results are symbolic, but finite-dimensional calculations illuminate their content and support exploration of sharper constants.

### 6.1. Direct energy and variation evaluation

Given an array $f=(f_0,\ldots,f_{n-1})$, adjacent-edge energy can be evaluated in $O(n)$ arithmetic operations:

$$
E_{\mathrm{edge}}(f)=\sum_{k=0}^{n-2}(f_{k+1}-f_k)^2.
$$

A naive evaluation of pairwise variation costs $O(n^2)$. Lemma 2 reduces it to $O(n)$ by accumulating

$$
S_1=\sum_i f_i,
\qquad
S_2=\sum_i f_i^2,
$$

and then computing

$$
\mathcal V_n(f)=2(nS_2-S_1^2).
$$

This identity is preferable for large arrays, although floating-point cancellation may occur for profiles with a large common offset. Subtracting the mean before summing squares improves numerical stability.

### 6.2. Spectral computation

Let $L_n$ be the path graph Laplacian, the symmetric tridiagonal matrix with diagonal entries $1$ at the endpoints, $2$ in the interior, and $-1$ on the adjacent off-diagonals. Then

$$
\mathcal E_n(f)=2f^{\mathsf T}L_nf.
$$

For mean-zero $f$, Lemma 2 gives

$$
\mathcal V_n(f)=2n f^{\mathsf T}f.
$$

Hence

$$
R_n(f)=\frac{f^{\mathsf T}L_nf}{n f^{\mathsf T}f}.
$$

The minimum over nonconstant functions is therefore the smallest positive eigenvalue of $L_n$ divided by $n$. A dense eigensolver costs $O(n^3)$ time and $O(n^2)$ memory. Because $L_n$ is tridiagonal, specialized methods can compute its extremal eigenvalues in $O(n)$ or $O(n\log(1/\varepsilon))$ work to a prescribed tolerance, depending on the method and error model.

Diagonalization strongly suggests the sharper formula

$$
\gamma_n=\frac{2-2\cos(\pi/n)}{n}.
$$

Under this formula, the first nonconstant eigenvector is a shifted discrete cosine profile and

$$
\lim_{n\to\infty}n^3\gamma_n=\pi^2.
$$

This exact diagonalization is presented here as a future sharpening, not as part of the proved two-sided estimate. Numerical examples can compare the coarse constants $2$ and $12$, the position witness, and the cosine candidate.

### 6.3. Finite random-profile tests

For a sampled nonconstant profile, one can compute

$$
C(f)=\frac{\mathcal V_n(f)}{n^3E_{\mathrm{edge}}(f)}.
$$

The Path Poincaré Inequality states $C(f)\le1$. Random tests do not prove the inequality, but they reveal how conservative it is. Smooth low-frequency profiles typically come closer to extremality than high-frequency noise, because oscillations increase local energy rapidly.

## 7. A worked four-site example

The case $n=4$ makes every normalization visible. For the position profile

$$
p_4=(0,1,2,3),
$$

the three unoriented edge increments all equal $1$, so

$$
E_{\mathrm{edge}}(p_4)=3
\qquad\text{and}\qquad
\mathcal E_4(p_4)=6.
$$

The variation may be calculated either from all sixteen ordered pairs or from the variance identity. Since

$$
\sum_{k=0}^{3}k=6
\qquad\text{and}\qquad
\sum_{k=0}^{3}k^2=14,
$$

we obtain

$$
\mathcal V_4(p_4)=2(4\cdot14-6^2)=40.
$$

Therefore

$$
R_4(p_4)=\frac{6}{40}=\frac{3}{20}.
$$

This agrees with the general expression $12/[n^2(n+1)]$, which at $n=4$ gives $12/(16\cdot5)=3/20$. The two-sided theorem says

$$
\frac{1}{32}=\frac{2}{4^3}
\le \gamma_4
\le \frac{12}{4^3}=\frac{3}{16}.
$$

The witness improves the displayed upper endpoint from $3/16$ to $3/20$. It does not by itself determine $\gamma_4$, because another profile may have a smaller quotient.

The Poincaré estimate can also be seen concretely. For an arbitrary profile $f=(a,b,c,d)$,

$$
E_{\mathrm{edge}}(f)=(b-a)^2+(c-b)^2+(d-c)^2.
$$

The endpoint difference satisfies

$$
(d-a)^2=((b-a)+(c-b)+(d-c))^2
\le3E_{\mathrm{edge}}(f)
\le4E_{\mathrm{edge}}(f).
$$

The same reasoning applies to every pair, with fewer terms for nearer sites. Summing the coarse bound $4E_{\mathrm{edge}}(f)$ over sixteen ordered pairs gives

$$
\mathcal V_4(f)\le64E_{\mathrm{edge}}(f),
$$

which is exactly the specialization of $\mathcal V_n(f)\le n^3E_{\mathrm{edge}}(f)$. This example also exposes the source of slack: diagonal pairs contribute zero, neighboring pairs traverse only one edge, and no route on four sites actually has length four. The universal estimate sacrifices these details in exchange for a short argument that works uniformly for every $n$ and every profile.

## 8. Interpretation and applications

### 8.1. Two origins of the cubic exponent

The upper and lower estimates explain the exponent in different ways.

For the position witness, local energy has $n-1$ contributions of constant size, so it is linear in $n$. Pairwise variation includes $n^2$ ordered pairs, and a typical squared separation is of order $n^2$, so variation is quartic. Their ratio is cubic inverse scale.

For the lower bound, each pairwise difference is routed through at most $n$ edges, and there are $n^2$ ordered pairs. The product of maximum route length and number of demands is $n^3$. This perspective is insensitive to the shape of the observable.

The agreement of these mechanisms is what closes the exponent. Neither mechanism alone would suffice: the witness cannot rule out slower modes, and the all-observable inequality does not identify a mode that attains the scale.

### 8.2. Mixing and physical relaxation

In a reversible stochastic model, a spectral gap controls exponential decay of mean-zero observables, with normalization-dependent conversion between the graph form used here and a Markov generator. The estimate $\gamma_n=\Theta(n^{-3})$ therefore signals a relaxation timescale of cubic order in the present scaling.

The slow mode is spatially smooth. Local swaps dissipate adjacent differences, but a smooth profile distributes its total change over the full path. This is analogous to long-wavelength modes in diffusion: fine oscillations are quickly damped, while broad variations persist.

### 8.3. Canonical routing and edge congestion

The telescoping proof may be reinterpreted as routing every ordered pair along the unique path connecting its endpoints. The coarse proof charges every pair by the full edge energy and the worst route length. A refined proof would reverse the summations and count the number of routes crossing each edge.

For the edge between $k$ and $k+1$, there are $k+1$ vertices on the left and $n-k-1$ on the right. Therefore the number of ordered routes crossing that edge is

$$
2(k+1)(n-k-1).
$$

This edge-congestion profile peaks near the center. Keeping these exact counts can improve constants and generalizes naturally to trees, where deleting an edge partitions the vertex set into two components.

### 8.4. Chord-swap reconfiguration spaces

A motivating extension replaces positions on a line by chord diagrams connected through legal local swaps. For fixed genus, one expects a cubic gap law if two geometric ingredients can be supplied.

First, an upper-bound witness should be a genus-aware displacement statistic that changes in controlled unit steps under accepted swaps and has sufficiently large global variation. Second, a lower bound should arise from canonical routes between diagrams whose maximum weighted transition congestion is $O(n^3)$. The path result shows that these tasks are logically independent: one is the construction of a slow observable, and the other is a global routing theorem.

### 8.5. Product systems

Consider a Cartesian product of several path systems with additive coordinate Dirichlet forms. An observable depending on a single coordinate immediately transfers that coordinate's upper bound to the product. For the lower bound, conditional-variance decomposition is expected to tensorize the one-coordinate Poincaré inequalities. Under a coordinate-update normalization that does not dilute rates with dimension, the product gap should equal the minimum coordinate gap. Thus a one-dimensional slow mode can continue to control a high-dimensional system.

## 9. Limitations and future work

The two-sided theorem determines the exponent but not the sharp constant. The factor-six interval between $2$ and $12$ reflects deliberate losses in the lower bound and nonoptimality of the linear witness.

The most immediate problem is exact diagonalization in the present normalization. The expected identity

$$
\gamma_n=\frac{2-2\cos(\pi/n)}{n}
$$

would show that the sharp asymptotic constant is $\pi^2$. It would also identify the shifted discrete cosine as the true minimizer.

A second direction is an edge-congestion Poincaré inequality on arbitrary finite trees. Unique routes remain available, but route counting should be performed edge by edge. If deleting an edge produces components of sizes $a$ and $N-a$, then $2a(N-a)$ ordered routes cross that edge. A theorem expressed through the maximum weighted congestion could recover path scaling and apply to tree-like reconfiguration spaces.

A third direction is fixed-genus chord-swap geometry. The analytic portion of the path proof suggests a concrete combinatorial program: construct a genus-aware displacement witness with quartic variation and design canonical routes with cubic congestion.

A fourth direction is tensor stability. Conditional-variance decomposition should yield a product Poincaré theorem whose gap is the minimum coordinate gap under additive forms. This would explain why increasing dimension need not alter the cubic exponent.

Finally, the path estimate invites a more abstract question. A monotone integer statistic spanning order $n$ levels and changing by one under local moves often has local energy of order $n$ and global variation of order $n^4$. These growth laws naturally produce an $n^{-3}$ upper bound. A universal cubic law, however, also needs a lower-bound hypothesis such as controlled canonical routing or a model-independent congestion estimate. The path result identifies precisely where that geometric input enters.

### 9.1. Robustness of the argument

The lower-bound mechanism is deterministic and does not depend on probabilistic averaging, smoothness, or a preferred coordinate profile. Its essential inputs are only the existence of a unique route between two sites, the telescoping identity along that route, nonnegativity of squared increments, and Cauchy–Schwarz. This economy makes the estimate robust under arbitrary amplitudes and oscillations of the observable. It also clarifies what must change in a graph with cycles: telescoping remains valid along a chosen route, but the proof must select routes and control the congestion they create. In that sense, the path theorem is simultaneously a spectral estimate and a prototype for a general canonical-path method.

## 10. Conclusion

For the unit-weight path on $n\ge2$ sites, the spectral gap defined by oriented Dirichlet energy divided by ordered-pair variation satisfies

$$
\frac{2}{n^3}\le\gamma_n\le\frac{12}{n^3}.
$$

The upper bound follows from the position profile, whose exact quotient is $12/[n^2(n+1)]$. The lower bound follows from a telescoping Cauchy–Schwarz inequality applied to every ordered pair, yielding $\mathcal V_n(f)\le n^3E_{\mathrm{edge}}(f)$ for every observable.

The result establishes the cubic exponent through two complementary principles: a single slowly varying witness and a universal route-based Poincaré inequality. This separation is useful beyond the path. In more complicated swap chains, one may search independently for a high-variance displacement statistic and for low-congestion canonical routes. The one-dimensional model shows how those ingredients meet to determine the global relaxation scale.