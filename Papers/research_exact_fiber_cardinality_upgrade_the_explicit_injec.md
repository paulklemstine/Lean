# Exact Interior Fiber Cardinality for the Full-Strength Logistic Map

**Aristotle**  
**August 2, 2026**

## Abstract

Let $L:[0,1]\to[0,1]$ be the full-strength logistic map $L(x)=4x(1-x)$. We give an explicit and exhaustive description of every interior fiber of every finite iterate. For an interior target $y\in(0,1)$, define the lower and upper inverse branches

$$
B_0(y)=\frac{1-\sqrt{1-y}}2,
\qquad
B_1(y)=\frac{1+\sqrt{1-y}}2.
$$

A binary word of length $n$ recursively selects these branches and thereby determines an $n$-step predecessor of $y$. We prove that this decoding map is a bijection from $\{0,1\}^n$ onto the fiber $\{x\in(0,1):L^n(x)=y\}$. Consequently, every interior target has exactly $2^n$ interior preimages under $L^n$. The argument isolates the three ingredients behind the count: inverse branches preserve the open interval, the midpoint separates the branches and prevents collisions, and the quadratic formula proves that the branches exhaust all preimages. We present an enumeration algorithm, numerical diagnostics, and implications for backward inference, finite-precision dynamics, and orbit-suffix ambiguity. Boundary targets are excluded because critical and endpoint collisions destroy the complete binary tree.

## 1. Introduction

The logistic family $x\mapsto rx(1-x)$ is a basic model of nonlinear population dynamics and deterministic chaos. At the parameter $r=4$, the map sends the unit interval onto itself, folds the interval around its midpoint, and exhibits especially transparent symbolic and trigonometric structure. Forward evolution is a function: each state has one successor. Backward evolution is a relation: a typical state has two predecessors. Iterating this relation suggests a complete binary tree of possible histories.

A branching heuristic alone does not determine the size of an iterated fiber. Distinct backward paths could collide, some intermediate values could leave the relevant domain, or the chosen branches could fail to exhaust all algebraic solutions. The purpose of this paper is to resolve all three issues for interior targets.

Our principal result is exact. If $n\ge 0$ and $0<y<1$, then

$$
\#\{x\in(0,1):L^n(x)=y\}=2^n.
$$

More strongly, the proof constructs a canonical bijection between the fiber and binary words of length $n$. Thus the cardinality formula is accompanied by a complete parametrization and an enumeration procedure.

The restriction to interior targets is structural. At $y=1$, the two first-level branches collide at the critical point $1/2$. At $y=0$, inverse images meet the endpoints. The theorem therefore describes precisely the noncritical regime in which each backward step contributes one independent binary choice.

The paper is organized as follows. Section 2 introduces the map, fibers, inverse branches, and recursive decoding. Section 3 proves the elementary one-step facts. Section 4 establishes that every decoded word gives a distinct valid predecessor. Section 5 proves exhaustion and the exact fiber theorem. Section 6 gives algorithms and complexity bounds. Section 7 discusses numerical examples and finite precision. Sections 8 and 9 develop dynamical interpretations, applications, limitations, and future directions.

## 2. Definitions and setup

### 2.1. The logistic map and its iterates

**Definition 2.1 (Full-strength logistic map).** The full-strength logistic map is the function $L:[0,1]\to[0,1]$ defined by

$$
L(x)=4x(1-x).
$$

For $n\in\mathbb N$, define the iterates recursively by

$$
L^0(x)=x,
\qquad
L^{n+1}(x)=L^n(L(x)).
$$

The identity

$$
L(x)=1-(2x-1)^2
$$

shows immediately that $0\le L(x)\le 1$ whenever $0\le x\le 1$. Hence all forward iterates of a point in the unit interval remain in the unit interval.

**Definition 2.2 (Interior fiber).** For $n\in\mathbb N$ and $y\in(0,1)$, the interior $n$-step fiber over $y$ is

$$
F_n(y)=\{x\in(0,1):L^n(x)=y\}.
$$

The adjective “interior” refers both to the target hypothesis $y\in(0,1)$ and to the restriction $x\in(0,1)$ in the fiber.

### 2.2. Explicit inverse branches

Solving $L(x)=y$ gives

$$
4x(1-x)=y,
$$

or equivalently

$$
(1-2x)^2=1-y.
$$

This motivates two branches.

**Definition 2.3 (Lower and upper inverse branches).** For $y\in[0,1]$, set

$$
B_0(y)=\frac{1-\sqrt{1-y}}2,
\qquad
B_1(y)=\frac{1+\sqrt{1-y}}2.
$$

The subscript $0$ denotes the branch below $1/2$ and $1$ denotes the branch above $1/2$.

### 2.3. Binary words and recursive decoding

Let $\{0,1\}^n$ denote the set of binary words $\varepsilon=(\varepsilon_1,\ldots,\varepsilon_n)$ of length $n$. There is one empty word, denoted $()$, when $n=0$.

**Definition 2.4 (Backward decoding).** For a target $y$ and a binary word $\varepsilon$, define $D_\varepsilon(y)$ recursively by

$$
D_{()}(y)=y,
$$

and, for $n\ge 1$,

$$
D_{(\varepsilon_1,\ldots,\varepsilon_n)}(y)
=B_{\varepsilon_1}\left(D_{(\varepsilon_2,\ldots,\varepsilon_n)}(y)\right).
$$

This convention makes $\varepsilon_1$ the branch that reconstructs the initial seed from its immediate successor. The remaining symbols reconstruct that successor from later states.

The main task is to prove that

$$
\varepsilon\longmapsto D_\varepsilon(y)
$$

is a bijection from $\{0,1\}^n$ to $F_n(y)$.

## 3. One-step inverse geometry

We first establish the facts needed at every level of the inverse tree.

**Lemma 3.1 (Right-inverse identity).** If $0\le y\le 1$ and $b\in\{0,1\}$, then

$$
L(B_b(y))=y.
$$

**Proof sketch.** Put $s=\sqrt{1-y}$. Then $s^2=1-y$. For either sign, $B_b(y)=(1\pm s)/2$. Therefore

$$
4B_b(y)(1-B_b(y))
=4\left(\frac{1\pm s}{2}\right)
\left(\frac{1\mp s}{2}\right)
=1-s^2=y.
$$

This calculation works at the endpoints as well as in the interior. $\square$

**Lemma 3.2 (Interior preservation).** If $0<y<1$, then for each $b\in\{0,1\}$,

$$
0<B_b(y)<1.
$$

**Proof sketch.** The inequalities $0<y<1$ imply $0<1-y<1$, hence $0<\sqrt{1-y}<1$. Substituting this strict bound into $(1\pm\sqrt{1-y})/2$ places both values strictly between $0$ and $1$. $\square$

**Lemma 3.3 (Branch separation).** If $0<y<1$, then

$$
B_0(y)<\frac12<B_1(y).
$$

In particular, $B_0(y)\ne B_1(y)$.

**Proof sketch.** Since $\sqrt{1-y}>0$, subtracting it from $1$ gives a value below $1$, while adding it gives a value above $1$. Division by $2$ yields the stated strict inequalities. $\square$

Branch separation is the mechanism that preserves symbolic information. The first bit of an inverse address can be read directly from whether the decoded point lies below or above $1/2$.

**Lemma 3.4 (Exhaustion of one-step preimages).** Let $x\in(0,1)$ and suppose $L(x)=y$. Then exactly one $b\in\{0,1\}$ satisfies

$$
x=B_b(y).
$$

**Proof sketch.** From $L(x)=y$ one obtains

$$
1-y=(1-2x)^2.
$$

If $x\le 1/2$, then $1-2x\ge 0$, so $\sqrt{1-y}=1-2x$ and $x=B_0(y)$. If $x>1/2$, then $1-2x<0$, so $\sqrt{1-y}=2x-1$ and $x=B_1(y)$. Uniqueness follows from branch separation whenever $y$ is interior; in the stated setting $y=L(x)$ may equal $1$ only at $x=1/2$, where the two displayed formulas coincide, but all later uses have interior $y$. $\square$

We also need a backward propagation fact.

**Lemma 3.5 (Interior reflection through one step).** Suppose $x\in[0,1]$ and $L(x)\in(0,1)$. Then $x\in(0,1)$.

**Proof sketch.** At either endpoint, $L(0)=L(1)=0$. Thus an image strictly greater than zero cannot come from an endpoint. Since $x$ is already in the closed interval, it must lie in the open interval. $\square$

**Lemma 3.6 (Interior reflection through iterates).** Suppose $x\in[0,1]$ and $L^n(x)\in(0,1)$. Then $x\in(0,1)$. Moreover, every state $L^j(x)$ for $0\le j\le n$ lies in $(0,1)$.

**Proof sketch.** Work backward from $L^n(x)$. Forward invariance gives $L^j(x)\in[0,1]$ for all $j$. Apply Lemma 3.5 successively to $L^{n-1}(x),L^{n-2}(x),\ldots,x$. $\square$

## 4. Validity and uniqueness of decoded histories

The recursive construction must first be shown to remain in its intended domain.

**Lemma 4.1 (Decoded points are interior).** Let $0<y<1$. For every $n\ge 0$ and every word $\varepsilon\in\{0,1\}^n$,

$$
D_\varepsilon(y)\in(0,1).
$$

**Proof sketch.** Induct on the word length. The empty word decodes to $y$, which is interior. For a nonempty word, the tail decodes to an interior value by induction, and Lemma 3.2 says that either inverse branch of this value is again interior. $\square$

**Lemma 4.2 (Every decoded word is a valid predecessor).** Let $0<y<1$. For every $\varepsilon\in\{0,1\}^n$,

$$
L^n(D_\varepsilon(y))=y.
$$

**Proof sketch.** Again induct on $n$. The claim is immediate for the empty word. For $\varepsilon=(b,\tau)$, the definition gives $D_\varepsilon(y)=B_b(D_\tau(y))$. The tail value is in $(0,1)$ by Lemma 4.1, so Lemma 3.1 yields

$$
L(D_\varepsilon(y))=D_\tau(y).
$$

Applying the induction hypothesis to $\tau$ completes the remaining $n-1$ steps. $\square$

Thus decoding defines a map from binary words into the desired fiber. We next exclude collisions.

**Theorem 4.3 (Uniqueness of binary addresses).** Let $0<y<1$. If $\varepsilon,\delta\in\{0,1\}^n$ and

$$
D_\varepsilon(y)=D_\delta(y),
$$

then $\varepsilon=\delta$.

**Proof sketch.** Induct on $n$. At length zero there is only one word. For positive length, write $\varepsilon=(b,\tau)$ and $\delta=(c,\sigma)$. Apply $L$ to the assumed equality. The right-inverse identity cancels the outer branches and gives

$$
D_\tau(y)=D_\sigma(y).
$$

The induction hypothesis implies $\tau=\sigma$. It remains to show $b=c$. The common tail decodes to an interior value by Lemma 4.1. By Lemma 3.3, selecting branch $0$ puts the full decoded point below $1/2$, while selecting branch $1$ puts it above $1/2$. Since the two full decoded points are equal, they cannot have selected opposite sides. Hence $b=c$, and the words agree completely. $\square$

**Corollary 4.4 (Lower bound).** For $0<y<1$,

$$
\#F_n(y)\ge 2^n.
$$

**Proof sketch.** Lemma 4.2 maps all $2^n$ words into $F_n(y)$, and Theorem 4.3 shows that their images are distinct. $\square$

The corollary is only a lower bound until every point in the fiber is decoded.

## 5. Exhaustion and exact cardinality

**Theorem 5.1 (Every interior predecessor has a binary address).** Let $n\ge 0$, let $0<y<1$, and suppose $x\in(0,1)$ satisfies

$$
L^n(x)=y.
$$

Then there exists a binary word $\varepsilon\in\{0,1\}^n$ such that

$$
D_\varepsilon(y)=x.
$$

**Proof sketch.** Induct on $n$. When $n=0$, the equation says $x=y$, and the empty word decodes to $y$.

For the induction step, suppose $L^{n+1}(x)=y$. Set $z=L(x)$. Forward invariance gives $z\in[0,1]$, while Lemma 3.6 applied to the equation $L^n(z)=y\in(0,1)$ gives $z\in(0,1)$. By induction, there is a tail word $\tau\in\{0,1\}^n$ such that $D_\tau(y)=z$.

Now $L(x)=z$. Lemma 3.4 supplies a branch bit $b$ such that $x=B_b(z)$. Substituting the decoded expression for $z$ gives

$$
x=B_b(D_\tau(y))=D_{(b,\tau)}(y).
$$

Thus appending the uniquely determined first branch choice produces an address for $x$. $\square$

We can now state the complete structural result.

**Theorem 5.2 (Interior Fiber Parametrization Theorem).** For every $n\ge 0$ and every $y\in(0,1)$,

$$
F_n(y)=\{D_\varepsilon(y):\varepsilon\in\{0,1\}^n\}.
$$

Moreover, the map

$$
\{0,1\}^n\longrightarrow F_n(y),
\qquad
\varepsilon\longmapsto D_\varepsilon(y),
$$

is a bijection.

**Proof sketch.** Lemma 4.2 proves that every decoded point belongs to the fiber. Theorem 5.1 proves that every point in the fiber is decoded by some word. Theorem 4.3 proves that this word is unique. These are precisely well-definedness, surjectivity, and injectivity. $\square$

**Theorem 5.3 (Exact Interior Fiber Cardinality Theorem).** For every integer $n\ge 0$ and every target $y$ with $0<y<1$,

$$
\#\{x\in(0,1):L^n(x)=y\}=2^n.
$$

**Proof sketch.** By Theorem 5.2 the fiber is in bijection with $\{0,1\}^n$. A binary word has two independent choices in each of $n$ positions, so $\#\{0,1\}^n=2^n$. $\square$

The theorem includes $n=0$: the fiber of the identity map over $y$ is the singleton $\{y\}$, and $2^0=1$.

## 6. Algorithms

### 6.1. Single-address decoding

Given $y\in(0,1)$ and a word $\varepsilon=(\varepsilon_1,\ldots,\varepsilon_n)$, one may decode it from the last symbol toward the first.

**Algorithm 6.1 (Recursive branch decoding).** Initialize $z\leftarrow y$. For $j=n,n-1,\ldots,1$, replace

$$
z\leftarrow \frac{1+(2\varepsilon_j-1)\sqrt{1-z}}2.
$$

Return $z$.

The sign convention gives the lower branch when $\varepsilon_j=0$ and the upper branch when $\varepsilon_j=1$. The algorithm uses $n$ square roots and $O(n)$ arithmetic operations. Its auxiliary storage is $O(1)$ if the input word is already stored. Under exact real arithmetic, its output is exactly $D_\varepsilon(y)$.

### 6.2. Complete fiber enumeration

**Algorithm 6.2 (Breadth-first inverse-tree enumeration).** Begin with the list $S_0=[y]$. For each level $j=1,\ldots,n$, replace every $z\in S_{j-1}$ by the pair $B_0(z),B_1(z)$, producing $S_j$. Return $S_n$.

Theorem 5.2 proves that the returned list contains every element of $F_n(y)$ exactly once in exact arithmetic. At level $j$, the list has $2^j$ entries. The total number of branch evaluations is

$$
2+4+\cdots+2^n=2^{n+1}-2,
$$

so the time complexity is $\Theta(2^n)$ and output storage is $\Theta(2^n)$. This is asymptotically optimal for explicit enumeration because the output itself contains $2^n$ distinct numbers.

### 6.3. Verification diagnostics

For numerical experiments, each candidate $x$ may be iterated forward $n$ times and compared with $y$. Define the residual

$$
r_n(x;y)=|L^n(x)-y|.
$$

In floating-point arithmetic the residual will generally be nonzero because branch decoding uses rounded square roots and forward iteration magnifies some errors. The residual is a diagnostic, not a substitute for the exact algebraic argument.

The branch itinerary can also be recovered from an exact decoded seed by recording, at each forward stage, whether the current state is below or above $1/2$. For interior fibers generated from interior targets, no reconstructed state equals $1/2$ at the moment when a branch bit must be distinguished; branch separation guarantees a strict side.

## 7. Numerical examples

Take $y=0.7$. At depth one,

$$
B_0(0.7)=\frac{1-\sqrt{0.3}}2\approx0.2261387212,
$$

and

$$
B_1(0.7)=\frac{1+\sqrt{0.3}}2\approx0.7738612788.
$$

Both map forward to $0.7$, and their sum is $1$. At depth two, applying both branches to each of these targets yields four distinct values. At depth six the complete list contains $64$ values, each associated with a unique six-bit address.

The distribution of the points is not uniform. The inverse derivatives satisfy

$$
|B_0'(y)|=|B_1'(y)|=\frac{1}{4\sqrt{1-y}},
$$

which becomes large as $y$ approaches $1$. Consequently, spacing in a backward level depends strongly on the route through the tree. This nonuniform geometry is one reason finite-precision collisions require separate quantitative analysis even though exact-real collisions do not occur.

A useful symmetry is

$$
B_1(y)=1-B_0(y).
$$

Thus one-step predecessors occur in reflected pairs. Deeper fibers inherit a structured reflection symmetry, although the ordering of branch words under reflection depends on the outermost choice.

## 8. Dynamical interpretation and applications

### 8.1. One erased bit per forward step

The map is strictly increasing on $[0,1/2]$ and strictly decreasing on $[1/2,1]$. Restricted to either half, it is one-to-one onto $[0,1]$. A forward step merges one point from the lower half and one from the upper half. The missing information is exactly the branch label.

After $n$ transitions, reconstruction requires $n$ labels. Theorem 5.2 makes this statement exact: the compatible histories are indexed by all binary words of length $n$, with no omissions and no duplications. In this sense each forward step erases one bit of symbolic past information for an interior observation.

### 8.2. Orbit-suffix ambiguity

Suppose an observer sees an exact state $y\in(0,1)$ after $n$ transitions but does not see the preceding states. The observation is compatible with exactly $2^n$ interior initial states. Moreover, all these states share the same orbit suffix beginning at the observed time, because deterministic forward evolution from $y$ is unique.

This has a direct inference consequence: any deterministic statistic that depends only on that suffix has the same value for all $2^n$ candidate seeds. Distinguishing them requires side information about the earlier itinerary, a prior distribution, or additional measurements not determined solely by the suffix.

This ambiguity should not be confused with a complete security analysis. Real implementations use finite representations; outputs may reveal partial branch information; and parameter or timing leakage may distinguish candidates. The theorem supplies an exact-real obstruction to unique backward recovery, not a blanket claim of cryptographic strength.

### 8.3. Trigonometric coordinates

Writing $x=\sin^2\theta$ gives

$$
L(x)=4\sin^2\theta(1-\sin^2\theta)
=4\sin^2\theta\cos^2\theta
=\sin^2(2\theta).
$$

Thus the logistic map is related to angle doubling after the change of variables $x=\sin^2\theta$. Backward branch choices correspond to the multiple solutions of

$$
2^n\phi\equiv \pm\theta \pmod{\pi}.
$$

This suggests representing the fiber by values of the form

$$
\sin^2\left(\frac{s\theta+k\pi}{2^n}\right),
\qquad s\in\{-1,1\},
$$

with a suitable nonredundant indexing of $k$. The recursive branch theorem guarantees that any correct closed indexing must produce exactly $2^n$ distinct interior values.

### 8.4. Statistical structure

If an angle is distributed uniformly and $x=\sin^2\theta$, the induced density on $(0,1)$ is proportional to

$$
\frac{1}{\sqrt{x(1-x)}}.
$$

After normalization, this becomes the arcsine density

$$
\rho(x)=\frac{1}{\pi\sqrt{x(1-x)}}.
$$

The angle-doubling relation strongly suggests that this measure is invariant under $L$. The inverse branches and their Jacobians provide a direct route to proving the corresponding transfer-operator identity. The same doubling structure suggests the Lyapunov exponent $\log 2$ for the invariant distribution. These measure-theoretic claims lie beyond the finite-fiber theorem proved here, but the exact branch decomposition provides their natural starting point.

## 9. Boundary behavior and finite precision

### 9.1. Why interiority is essential

At $y=1$,

$$
B_0(1)=B_1(1)=\frac12.
$$

The two branches collide at the critical point, so a binary choice no longer identifies two distinct predecessors. At $y=0$,

$$
B_0(0)=0,
\qquad
B_1(0)=1,
$$

and both values lie outside the open interval. Subsequent backward levels can interact with endpoints and the critical orbit. Therefore the complete binary count cannot be transferred to boundary targets without modification.

The theorem’s hypotheses prevent these degeneracies at every intermediate stage. Because decoded tail values stay in $(0,1)$, the square root $\sqrt{1-y}$ is strictly positive and strictly less than $1$ whenever branch separation is invoked.

### 9.2. Rounding collapse

In a fixed-point system with grid

$$
G_p=\left\{\frac{k}{2^p}:0\le k\le2^p\right\},
$$

the $2^n$ exact seeds are rounded into only $2^p+1$ representable values. Hence the number of distinct rounded seeds is at most

$$
\min(2^n,2^p+1).
$$

This upper bound follows immediately from counting, but an exact description requires comparing decoded seeds with rounding-cell boundaries. Two exact seeds can round together even though Theorem 4.3 proves that they are unequal. Such merging belongs to the discretized model and should be analyzed through an equivalence relation induced by the rounding rule.

Floating-point iteration introduces further effects because rounding occurs after each arithmetic operation, not merely once after exact decoding. Cycles and collisions in a finite state space are inevitable. The exact theorem serves as a baseline against which those implementation-level phenomena can be measured.

## 10. Discussion

The proof separates existence, uniqueness, and completeness in a way that generalizes beyond this particular polynomial.

First, explicit inverse branches provide candidate histories. Second, invariant-domain estimates ensure that every composition is legal. Third, disjoint branch ranges supply symbolic uniqueness. Fourth, a local inverse classification proves exhaustion. Any interval map with finitely many monotone full branches may admit an analogous finite-depth fiber count, although critical values and non-surjective branches can produce more complicated trees.

For the logistic map at parameter $4$, the situation is exceptionally clean: there are exactly two full branches, each interior target pulls back to one point on each side of $1/2$, and the same structure repeats at every depth. The resulting count is uniform in the target $y$ as long as $y$ remains interior.

The recursive parametrization is stronger than a cardinality calculation. It provides labels for individual seeds, a method to generate them, and a proof that the labels are lossless. It also makes clear what information forward iteration discards. The fiber is not merely a set of roots of a degree-$2^n$ polynomial; it is a binary symbolic object whose geometry is controlled by nested square roots.

## 11. Future work

Several concrete directions follow from the branch description.

1. **Closed trigonometric indexing.** For $0<\theta<\pi/2$, identify each decoded value over $y=\sin^2\theta$ with a unique expression $\sin^2((s\theta+k\pi)/2^n)$, where $s\in\{-1,1\}$ and $k$ is explicitly decoded from the branch word. Proving the converse would give a closed-form version of the complete fiber theorem.

2. **Boundary fiber cardinalities.** Determine the exact interior fibers over $0$ and $1$. The expected formulas are an empty interior fiber over $0$ for positive depth and $2^{n-1}$ interior points over $1$, reflecting the first collision at the critical value.

3. **Fixed-point rounding collapse.** For nearest-grid rounding on $G_p$, characterize exactly when two branch words decode to values in the same rounding cell. The distinct rounded-seed count should be the number of resulting equivalence classes and is bounded by $\min(2^n,2^p+1)$.

4. **Orbit-suffix ambiguity.** Develop a precise stream interface and prove that an exact interior observation after $n$ transitions admits exactly $2^n$ initial states. Then characterize which classes of observers are necessarily constant on these fibers.

5. **Arcsine invariance.** Use the two inverse branches and their Jacobians to prove invariance of the density $1/(\pi\sqrt{x(1-x)})$ and derive the Lyapunov exponent $\log 2$.

## 12. Conclusion

For the full-strength logistic map $L(x)=4x(1-x)$, every interior target has a perfectly regular finite backward structure. The lower and upper quadratic inverse branches map the open interval into disjoint halves of itself. Composing them according to a binary word produces a valid predecessor; the midpoint separation prevents two words from producing the same point; and the quadratic formula ensures that every possible predecessor chooses one of the branches at every stage.

Therefore, for all $n\ge0$ and $0<y<1$,

$$
F_n(y)=\{D_\varepsilon(y):\varepsilon\in\{0,1\}^n\}
$$

with unique addresses, and

$$
\#F_n(y)=2^n.
$$

The theorem turns the informal picture of a backward binary tree into an exact classification of the entire interior fiber.