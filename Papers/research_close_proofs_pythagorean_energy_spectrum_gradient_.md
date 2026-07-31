# A Discrete Energy Spectrum for Pythagorean Factor Certificates

**Aristotle**  
**30 July 2026**

## Abstract

We study an integer-valued energy that couples the Pythagorean equation to a prescribed product. For integers $a,b,c$ and target $N$, define

$$
E(a,b,c;N)=\bigl(a^2+b^2-c^2\bigr)^2+(ab-N)^2.
$$

The two summands measure geometric and arithmetic residuals, respectively. We prove that the energy is nonnegative and symmetric in the two legs; characterize its zero set exactly as the set of Pythagorean triples whose legs multiply to $N$; and show that every such certificate realizes a global minimum. A zero-energy certificate whose first leg satisfies $1<a<N$ immediately yields a nontrivial divisor of $N$. In the target coordinate, we establish the exact second-difference identity

$$
E(a,b,c;N+h)+E(a,b,c;N-h)-2E(a,b,c;N)=2h^2,
$$

which implies strict discrete convexity for every nonzero integer step and constant unit-step curvature. For each fixed triple, the unique minimizing target is $N=ab$. The triple $(3,4,5)$ supplies the concrete certificate $E(3,4,5;12)=0$ and the factor $3\mid12$. We also describe exact evaluation, certificate verification, target minimization, and finite search algorithms, and explain how the energy can score vertices in the Berggren tree of primitive Pythagorean triples. The proven results concern the algebraic certificate landscape; global convergence of greedy tree descent remains an explicit direction for further study.

## 1. Introduction

Integer right triangles are governed by the Diophantine equation

$$
a^2+b^2=c^2.
$$

Integer factorization is governed by an equally elementary equation,

$$
ab=N.
$$

Although these equations express different kinds of structure, they share the variables $a$ and $b$. This makes it natural to ask for triples that satisfy both equations simultaneously. Such a triple is both geometric data—a Pythagorean triple—and arithmetic data—a factor certificate for $N$.

A useful way to combine simultaneous equations is to square their residuals and add them. This produces an objective that is nonnegative, integral, and equal to zero exactly when every equation is satisfied. In the present setting, the construction yields

$$
E(a,b,c;N)=\bigl(a^2+b^2-c^2\bigr)^2+(ab-N)^2.
$$

The first residual detects deviation from the Pythagorean relation. The second detects deviation of the leg product from the target. The energy remains entirely over the integers; no continuous relaxation is needed to state or prove its essential convexity property.

The main contribution is an exact description of this energy. Its zero set is characterized without approximation. Every certificate is automatically a global minimizer because zero is the universal lower bound. A simple range condition converts the certificate into a proper divisor. Moreover, when $(a,b,c)$ is fixed and $N$ varies, the energy has constant positive discrete curvature. Its symmetric second difference at displacement $h$ is exactly $2h^2$, and its unique integer minimizer is the product $ab$.

These results should be interpreted precisely. They establish a certificate functional and its target-direction geometry. They do not assert that every composite integer is the product of the legs of a Pythagorean triple, nor that local descent on a tree of triples always finds a zero. Instead, they isolate the algebraic foundation needed to formulate and test such search questions rigorously.

The paper is organized as follows. Section 2 gives definitions and elementary structural properties. Section 3 characterizes zero energy and global minima. Section 4 extracts factors and treats the root example. Section 5 proves the exact second-difference identity, strict convexity, and uniqueness of the target minimizer. Section 6 presents algorithms and complexity bounds. Section 7 discusses the Berggren tree and applications. Sections 8 and 9 address limitations and future research.

## 2. Definitions and structural properties

### 2.1 Pythagorean triples and factor certificates

**Definition 2.1 (Pythagorean triple).** An integer triple $(a,b,c)$ is Pythagorean if

$$
a^2+b^2=c^2.
$$

No positivity or coprimality is built into this definition. When all entries are positive, the triple gives the side lengths of a right triangle. It is called primitive when $\gcd(a,b,c)=1$.

**Definition 2.2 (Pythagorean factor certificate).** For an integer target $N$, a Pythagorean factor certificate is an integer triple $(a,b,c)$ satisfying

$$
a^2+b^2=c^2
\qquad\text{and}\qquad
ab=N.
$$

If additionally $1<a<N$, then the first leg is a nontrivial divisor of $N$. For a positive composite target, analogous range conditions can be imposed on the second leg.

**Definition 2.3 (Pythagorean-product energy).** For $a,b,c,N\in\mathbb Z$, define

$$
E(a,b,c;N)=R_P(a,b,c)^2+R_F(a,b;N)^2,
$$

where

$$
R_P(a,b,c)=a^2+b^2-c^2
$$

is the Pythagorean residual and

$$
R_F(a,b;N)=ab-N
$$

is the factorization residual. Explicitly,

$$
E(a,b,c;N)=\bigl(a^2+b^2-c^2\bigr)^2+(ab-N)^2.
$$

The separation into residuals is useful. The first depends only on the triple; the second depends on the target. Both are integers, so the energy is a nonnegative integer.

### 2.2 Nonnegativity and symmetry

**Theorem 2.4 (Nonnegativity).** For all integers $a,b,c,N$,

$$
E(a,b,c;N)\ge0.
$$

**Proof sketch.** Both $R_P(a,b,c)^2$ and $R_F(a,b;N)^2$ are squares of integers and hence nonnegative. Their sum is nonnegative. $\square$

Nonnegativity identifies zero as an absolute lower bound, not merely a local benchmark.

**Theorem 2.5 (Symmetry of the legs).** For all integers $a,b,c,N$,

$$
E(b,a,c;N)=E(a,b,c;N).
$$

**Proof sketch.** Interchanging $a$ and $b$ leaves $a^2+b^2-c^2$ unchanged, since addition is commutative. It also leaves the product residual unchanged because $ba=ab$. Therefore both squared residuals, and hence their sum, agree. $\square$

This symmetry reflects the fact that the legs of a right triangle have no intrinsic ordering. Computational searches may nevertheless impose an order such as $a\le b$ to avoid duplicate work.

## 3. Zero energy and global optimality

### 3.1 Exact characterization of the zero set

The sum-of-squares construction rules out cancellation between residuals.

**Theorem 3.1 (Zero-Energy Characterization).** For integers $a,b,c,N$, the following are equivalent:

1. $E(a,b,c;N)=0$;
2. $(a,b,c)$ is Pythagorean and its legs multiply to $N$, that is,

$$
a^2+b^2=c^2
\qquad\text{and}\qquad
ab=N.
$$

**Proof sketch.** Suppose first that $E(a,b,c;N)=0$. The two summands in the energy are nonnegative. A sum of two nonnegative integers can equal zero only when both summands equal zero. Thus

$$
\bigl(a^2+b^2-c^2\bigr)^2=0
\quad\text{and}\quad
(ab-N)^2=0.
$$

An integer square vanishes exactly when its base vanishes, giving the two required equations. Conversely, if those equations hold, both residuals vanish, so the energy is zero. $\square$

This theorem gives both soundness and completeness for the certificate interpretation. There are no false zero-energy points, and every certificate of the stated form has zero energy.

### 3.2 Certificates are global minimizers

**Theorem 3.2 (Global Minimum from a Certificate).** Let $a,b,c,N\in\mathbb Z$. If

$$
a^2+b^2=c^2
\qquad\text{and}\qquad
ab=N,
$$

then

$$
E(a,b,c;N)=0,
$$

and for every integer triple $(x,y,z)$,

$$
E(a,b,c;N)\le E(x,y,z;N).
$$

**Proof sketch.** The zero-energy characterization gives $E(a,b,c;N)=0$. By nonnegativity, $E(x,y,z;N)\ge0$ for every competitor. Hence the certificate attains the global lower bound. $\square$

The theorem asserts existence of a global minimum whenever a certificate is supplied. It does not assert that such a certificate exists for every $N$. If no simultaneous solution exists, the minimum over a chosen finite search region is positive; over the entire integer lattice, further analysis is needed to describe the best approximation.

### 3.3 The zero set as an intersection

Let

$$
\mathcal P=\{(a,b,c)\in\mathbb Z^3:a^2+b^2=c^2\}
$$

and, for fixed $N$, let

$$
\mathcal F_N=\{(a,b,c)\in\mathbb Z^3:ab=N\}.
$$

Theorem 3.1 may be summarized as

$$
\{(a,b,c):E(a,b,c;N)=0\}=\mathcal P\cap\mathcal F_N.
$$

Thus the energy is an exact penalty function for the intersection of two Diophantine constraint sets. The use of squares is essential: replacing the sum of squares by a raw sum of residuals would permit nonzero errors of opposite signs to cancel.

## 4. Divisor extraction and the root certificate

### 4.1 A zero produces a divisor

**Theorem 4.1 (Nontrivial Factor Extraction).** Let $a,b,c,N\in\mathbb Z$. If

$$
E(a,b,c;N)=0,
$$

and

$$
1<a<N,
$$

then

$$
a\mid N,
\qquad 1<a,
\qquad a<N.
$$

In particular, $a$ is a nontrivial divisor of $N$.

**Proof sketch.** By Theorem 3.1, zero energy implies $ab=N$. Equivalently, $N=a\cdot b$, so $a\mid N$. The two strict inequalities are hypotheses and exclude $1$ and $N$. $\square$

The theorem is intentionally stated over the integers. In typical factoring applications $N>1$ and positive legs are used. The range condition then has its standard meaning. A symmetric statement holds for $b$ by Theorem 2.5 or directly from $ab=N$.

### 4.2 The $(3,4,5)$ example

**Theorem 4.2 (Root Certificate for Twelve).** The triple $(3,4,5)$ satisfies

$$
E(3,4,5;12)=0.
$$

Moreover,

$$
3\mid12,
\qquad 1<3<12.
$$

**Proof sketch.** Direct calculation gives

$$
3^2+4^2-5^2=9+16-25=0
$$

and

$$
3\cdot4-12=0.
$$

Therefore both squared residuals vanish. Since $12=3\cdot4$ and $1<3<12$, the first leg is a nontrivial divisor. $\square$

The same triple also yields the factor $4$, and leg symmetry gives $E(4,3,5;12)=0$. This example is the root of the Berggren tree discussed in Section 7.

## 5. The target spectrum

Fix integers $a,b,c$ and regard the energy as a function of the target:

$$
E_{a,b,c}(N)=E(a,b,c;N).
$$

Writing

$$
C=\bigl(a^2+b^2-c^2\bigr)^2
\qquad\text{and}\qquad
p=ab,
$$

we obtain the normal form

$$
E_{a,b,c}(N)=C+(p-N)^2.
$$

Thus every target spectrum is an integer parabola with vertical offset $C$ and center $p$.

### 5.1 Exact second difference

**Theorem 5.1 (Exact Symmetric Second Difference).** For all integers $a,b,c,N,h$,

$$
E(a,b,c;N+h)+E(a,b,c;N-h)-2E(a,b,c;N)=2h^2.
$$

**Proof sketch.** Set $C=(a^2+b^2-c^2)^2$ and $d=ab-N$. Then

$$
E(a,b,c;N)=C+d^2,
$$

while

$$
E(a,b,c;N+h)=C+(d-h)^2
$$

and

$$
E(a,b,c;N-h)=C+(d+h)^2.
$$

Substitution into the second difference cancels the three occurrences of $C$. Expanding the remaining squares gives

$$
(d-h)^2+(d+h)^2-2d^2=2h^2.
$$

This proves the identity. $\square$

Notably, the right-hand side is independent of $a,b,c$, and $N$. Every fixed-triple spectrum has identical target-direction curvature.

### 5.2 Strict discrete convexity

**Theorem 5.2 (Strict Convexity on Integer Targets).** Let $h\in\mathbb Z$ be nonzero. Then, for every $a,b,c,N\in\mathbb Z$,

$$
2E(a,b,c;N)<E(a,b,c;N-h)+E(a,b,c;N+h).
$$

Equivalently, the midpoint energy is strictly less than the arithmetic mean of the two symmetric endpoint energies:

$$
E(a,b,c;N)<\frac{E(a,b,c;N-h)+E(a,b,c;N+h)}{2}.
$$

**Proof sketch.** By Theorem 5.1, the difference between the right side of the first inequality and the left side is $2h^2$. Since $h\ne0$, one has $h^2>0$, so this difference is strictly positive. $\square$

This is an integral formulation of strict convexity. It avoids derivatives and does not enlarge the domain from $\mathbb Z$ to $\mathbb R$.

**Corollary 5.3 (Unit-Step Curvature).** For all integers $a,b,c,N$,

$$
E(a,b,c;N+1)+E(a,b,c;N-1)-2E(a,b,c;N)=2.
$$

**Proof sketch.** Apply Theorem 5.1 with $h=1$. $\square$

The first forward difference can also be calculated:

$$
E(a,b,c;N+1)-E(a,b,c;N)=2(N-ab)+1.
$$

Consequently, the forward differences increase by exactly $2$ at every step. This is another standard signature of a discrete quadratic.

### 5.3 Unique target minimizer

**Theorem 5.4 (Unique Minimizing Target).** For fixed integers $a,b,c$, the unique integer target minimizing $E(a,b,c;N)$ is

$$
N=ab.
$$

More explicitly, for every integer $N$,

$$
E(a,b,c;ab)\le E(a,b,c;N),
$$

and

$$
E(a,b,c;N)=E(a,b,c;ab)
$$

if and only if

$$
N=ab.
$$

**Proof sketch.** At $N=ab$, the factorization residual vanishes, so

$$
E(a,b,c;ab)=\bigl(a^2+b^2-c^2\bigr)^2.
$$

For general $N$,

$$
E(a,b,c;N)=E(a,b,c;ab)+(ab-N)^2.
$$

The additional square is nonnegative, proving minimality. Equality occurs exactly when $(ab-N)^2=0$, which is equivalent to $N=ab$. $\square$

The theorem remains true even when $(a,b,c)$ is not Pythagorean. In that case the minimum value is positive unless the Pythagorean residual happens to vanish. It cleanly separates target fitting from geometric validity.

## 6. Algorithms and computational complexity

The preceding identities lead to simple exact algorithms. All arithmetic should use arbitrary-precision integers when inputs may be large.

### 6.1 Exact energy evaluation

Given $(a,b,c,N)$, compute

$$
r_P=a^2+b^2-c^2,
\qquad
r_F=ab-N,
$$

and return

$$
r_P^2+r_F^2.
$$

This requires a constant number of integer additions and multiplications. Under a unit-cost arithmetic model, the time and auxiliary space are $O(1)$. In bit complexity, if all inputs have at most $L$ bits and $M(L)$ denotes the cost of multiplying $L$-bit integers, evaluation costs $O(M(L))$ up to constant factors; intermediate squares may have $O(L)$ bits with larger constants.

### 6.2 Certificate verification and factor extraction

A candidate is verified by checking whether its energy is zero. Equivalently, one may check the two residuals separately. If zero energy holds and $1<a<N$, return $a$ as a nontrivial factor. This procedure is deterministic and exact. It never returns an invalid factor because $E=0$ implies $ab=N$.

The procedure is a verifier, not a universal factor-finding algorithm: it assumes a candidate triple has been supplied or found by some search mechanism.

### 6.3 Direct target minimization

For fixed $(a,b,c)$, no iterative optimization is necessary. Theorem 5.4 gives the minimizer directly: return $N_*=ab$. The minimum energy is

$$
E(a,b,c;N_*)=\bigl(a^2+b^2-c^2\bigr)^2.
$$

This takes one product plus residual evaluation. Strict convexity guarantees uniqueness, but the closed form makes descent unnecessary.

### 6.4 Finite scan over candidate triples

Given a finite list $S$ of integer triples and target $N$, evaluate $E$ at every candidate and retain one of least energy. If $|S|=m$, the scan uses $O(m)$ energy evaluations and $O(1)$ additional storage beyond the input list when only the current best candidate is retained. If a zero is found, the search can terminate early because nonnegativity proves that no smaller energy exists.

When $S$ contains only Pythagorean triples, evaluation simplifies to

$$
E(a,b,c;N)=(ab-N)^2.
$$

The scan then ranks candidates solely by distance between their leg products and $N$.

### 6.5 Checking the second-difference law numerically

For selected values, evaluate the energy at $N-h$, $N$, and $N+h$, and compare the resulting second difference with $2h^2$. This is useful for illustration and implementation testing. The identity itself is algebraic and holds for all integers; numerical checks demonstrate rather than establish it.

## 7. Berggren-tree interpretation and applications

### 7.1 Primitive triples in a tree

The primitive positive Pythagorean triples admit a rooted-tree organization commonly called the Berggren tree. The root is $(3,4,5)$. From a column vector $(a,b,c)^{\mathsf T}$, three children are obtained using

$$
B_1=
\begin{pmatrix}
1&-2&2\\
2&-1&2\\
2&-2&3
\end{pmatrix},
\quad
B_2=
\begin{pmatrix}
1&2&2\\
2&1&2\\
2&2&3
\end{pmatrix},
\quad
B_3=
\begin{pmatrix}
-1&2&2\\
-2&1&2\\
-2&2&3
\end{pmatrix}.
$$

Each child is again a primitive positive Pythagorean triple, and every primitive positive Pythagorean triple occurs in the tree. For example, the first generation consists of $(5,12,13)$, $(21,20,29)$, and $(15,8,17)$, up to the displayed child ordering.

For a fixed target $N$, every vertex already satisfies the Pythagorean equation. Hence its energy reduces to

$$
E(a,b,c;N)=(ab-N)^2.
$$

A zero-energy vertex therefore occurs exactly when the target equals the product of the two legs.

### 7.2 A deterministic scoring rule

The energy defines a deterministic score for comparing tree vertices. A local rule could inspect a vertex, its three children, and—away from the root—its parent, then move to the candidate of least energy, breaking ties by a fixed order. Such a rule is straightforward to implement.

However, Theorem 5.2 must not be overinterpreted. It proves convexity as $N$ varies while the triple remains fixed. A move in the Berggren tree changes $a$, $b$, and $c$ simultaneously, often dramatically. Therefore target-direction convexity alone does not prove that greedy tree descent reaches zero, avoids cycles, or lacks nonglobal local minima. Those properties require separate analysis.

### 7.3 Applications

The energy has several immediate uses.

First, it is an exact **certificate validator**. Given a claimed Pythagorean factor certificate, one integer evaluation confirms whether both equations hold.

Second, it is a **ranking functional** for finite searches. Candidates can be ordered by combined geometric and arithmetic error; on a Pythagorean-only search space this becomes squared product error.

Third, it provides a **benchmark landscape** for studying discrete optimization. Its target coordinate is completely transparent: constant second difference, strict convexity, and a known unique minimizer. Any difficulty encountered by a tree-search procedure is therefore attributable to the combinatorial geometry of the candidate space rather than ambiguity in the target spectrum.

Fourth, the construction illustrates a general method for Diophantine systems. Given integer polynomial equations $f_1=0,\ldots,f_k=0$, the sum

$$
\sum_{i=1}^k f_i^2
$$

is nonnegative and vanishes exactly on their common integer solutions. What is special here is the additional exact convexity in one distinguished parameter.

## 8. Discussion and limitations

The energy offers an exact bridge between Pythagorean geometry and product arithmetic, but its scope should be stated carefully.

The existence of a zero-energy certificate for $N$ is equivalent to the existence of integers $a,b,c$ with $a^2+b^2=c^2$ and $ab=N$. This representability condition is stronger than compositeness. A composite target need not automatically be represented by the legs of an integer right triangle. Thus zero-energy search on this particular certificate class is not, by itself, a complete factoring method for arbitrary integers.

Strict convexity holds in the target coordinate. If the target is variable and the triple fixed, the energy is exactly a parabola centered at $ab$. In a factoring problem, however, $N$ is fixed and the triple varies. The resulting landscape over triples can be complicated. No theorem above excludes positive-energy local minima in a graph whose vertices are triples.

The global-minimum theorem is conditional on a certificate. It says that a certificate, when present, attains the absolute floor. It does not supply a bound on the effort needed to find one. Similarly, factor extraction requires the proper range $1<a<N$; zero-energy solutions with trivial or signed factors must be filtered according to the intended application.

These limitations are not defects in the algebraic results. They delineate the boundary between the solved certificate theory and the open search theory.

## 9. Future work

Several concrete research directions emerge.

1. **Infinitude of primitive certificates.** Determine whether infinitely many composite targets admit positive coprime $a,b,c$ satisfying $a^2+b^2=c^2$, $ab=N$, and $1<a<N$.

2. **Depth bounds.** For targets represented by the legs of primitive positive triples, seek a universal constant $C$ such that a zero-energy certificate appears in the Berggren tree at depth at most $C\log N$.

3. **Greedy convergence.** Analyze the deterministic rule that chooses the least-energy option among the three children and the parent, with fixed tie breaking. Determine whether it always reaches zero for represented targets.

4. **Local-minimum structure.** Test and prove, or refute, whether every locally minimal vertex on the relevant certificate subtree has zero energy.

5. **Polynomial move bounds.** Investigate whether a greedy walk reaches zero in at most $(\lfloor\log_2N\rfloor+1)^2$ moves for represented positive targets.

Each question is falsifiable by finite computation at a fixed bound, while a general proof would require new information about how leg products evolve under the Berggren transformations.

## 10. Conclusion

The Pythagorean-product energy

$$
E(a,b,c;N)=\bigl(a^2+b^2-c^2\bigr)^2+(ab-N)^2
$$

provides an exact integer certificate landscape. It is nonnegative and invariant under swapping the two legs. Its zeros are precisely the triples that are simultaneously Pythagorean and encode the target as a leg product. Every such zero is a global minimum, and a leg in the range $1<a<N$ is a nontrivial divisor of $N$. The triple $(3,4,5)$ realizes the construction for $N=12$.

For a fixed triple, the target spectrum has the normal form $C+(ab-N)^2$. Consequently, its symmetric second difference is exactly $2h^2$, it is strictly convex at every nonzero integer displacement, its unit curvature is $2$, and its unique minimizing target is $ab$. These results fully describe one axis of the landscape and provide exact algorithms for evaluation, validation, and finite ranking. The remaining challenge is combinatorial: to understand whether and how a local walk through structured families of Pythagorean triples can exploit this energy to locate certificates efficiently.