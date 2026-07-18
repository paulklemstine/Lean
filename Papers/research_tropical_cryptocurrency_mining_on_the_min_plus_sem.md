# Tropical Cryptocurrency: Exact Fibers, Efficient Inversion, Universal Two-Key Collisions, and Concavity

**Aristotle**  
**July 18, 2026**

## Abstract

We analyze a proposed tropical analogue of cryptographic hashing built from min-plus linear forms. For a nonempty real message vector $m\in\mathbb{R}^k$ and key $h\in\mathbb{R}^k$, the scalar map is

$$
T_h(m)=\min_{1\le i\le k}(m_i+h_i).
$$

A proposed two-key variant returns $T_{h,h'}^{(2)}(m)=(T_h(m),T_{h'}(m))$. We give a complete characterization of every scalar fiber: $T_h(m)=y$ exactly when all coordinate sums lie above $y$ and at least one attains $y$. This immediately yields the canonical preimage $m_i=y-h_i$, proving that every scalar output is attained and that inversion requires only linear time. We then establish an update principle: increasing a coordinate not serving as a chosen minimizer leaves the output unchanged. Applying this principle simultaneously to two keys proves that, for every $k\ge3$, every message and every pair of keys admits a distinct message with exactly the same two-key output. Thus adding a second uncoupled min-plus linear form does not yield collision resistance; collisions are universal rather than merely probable. Finally, we place the construction in its optimization-geometric setting by proving concavity of the two-coordinate minimum along line segments. The results distinguish useful tropical optimization structure from cryptographic one-wayness and identify coordinate coupling, domain restrictions, and nonlinear tropical circuits as necessary directions for any redesigned scheme.

## 1. Introduction

The min-plus semiring replaces ordinary addition and multiplication by

$$
a\oplus b=\min(a,b),\qquad a\otimes b=a+b.
$$

Its algebra describes a wide range of optimization phenomena. Serial costs add, competing alternatives are minimized, and matrix operations encode shortest-path and scheduling recurrences. These successes motivate a natural question: can a tropical expression serve as a cryptographic hash, and can proof-of-work mining be reframed as tropical optimization?

The simplest proposed construction takes a message $m=(m_1,\ldots,m_k)$ and key $h=(h_1,\ldots,h_k)$ and computes the tropical inner product

$$
T_h(m)=\bigoplus_{i=1}^k(m_i\otimes h_i)
      =\min_{1\le i\le k}(m_i+h_i).
$$

Evaluation takes $O(k)$ operations. An initial intuition might suggest that inversion requires a combinatorial search for the active coordinate or an implicit tropical path. A second intuition is that two independently keyed outputs may suppress collisions:

$$
T_{h,h'}^{(2)}(m)=\big(T_h(m),T_{h'}(m)\big).
$$

Both intuitions are false for unrestricted real messages. The central reason is informational: a minimum retains one winning value while discarding the margins of all losing values. The scalar fibers can be described exactly, inverted explicitly, and seen geometrically as unions of faces of translated orthants. For two keys, one minimizing witness per output component is enough to preserve both values. If at least one additional coordinate exists, that coordinate may be increased without changing either component.

The principal contributions are as follows.

1. We characterize the fiber over every scalar output by coordinate inequalities and one active equality.
2. We construct a canonical preimage for every real target, proving surjectivity and $O(k)$ inversion.
3. We prove a stability lemma for non-minimizing coordinate updates.
4. We prove deterministic universal collisions for the two-key map in every dimension $k\ge3$, with an $O(k)$ collision algorithm and an unbounded collision ray.
5. We prove concavity of the two-coordinate minimum along line segments, connecting the hash expression to tropical optimization geometry.

These conclusions concern the stated domain $\mathbb{R}^k$ and uncoupled min-plus linear forms. They do not imply that every constrained, discrete, or nonlinear tropical construction is insecure. Rather, they show that any genuine hardness must enter through additional structure—particularly coupling among coordinates—not through the bare minimum operation.

## 2. Algebraic setting and definitions

### 2.1 The min-plus semiring

The min-plus semiring is the extended-real algebra in which the tropical sum of $a$ and $b$ is $\min(a,b)$ and their tropical product is $a+b$. The present analysis uses finite real vectors, so no infinite element is needed. Tropical notation is conceptually useful, but all proofs reduce to ordinary inequalities involving minima and sums.

Let $k\ge1$. A **message** is a vector $m\in\mathbb{R}^k$, and a **key** is a vector $h\in\mathbb{R}^k$. Coordinates are indexed by $i\in\{1,\ldots,k\}$.

### 2.2 Scalar and two-key tropical hashes

**Definition 2.1 (Scalar min-plus hash).** For a key $h$ and message $m$, define

$$
T_h(m)=\min_{1\le i\le k}(m_i+h_i).
$$

A coordinate $p$ is called an **active coordinate** or **minimizing witness** for $(h,m)$ if

$$
m_p+h_p=T_h(m).
$$

At least one active coordinate exists because the index set is finite and nonempty.

**Definition 2.2 (Two-key min-plus hash).** Given keys $h,h'\in\mathbb{R}^k$, define

$$
T_{h,h'}^{(2)}(m)=\left(T_h(m),T_{h'}(m)\right)\in\mathbb{R}^2.
$$

**Definition 2.3 (Fiber, preimage, and collision).** For $y\in\mathbb{R}$, the scalar fiber is

$$
F_h(y)=\{m\in\mathbb{R}^k:T_h(m)=y\}.
$$

An element of $F_h(y)$ is a preimage of $y$. A collision for a scalar or vector-valued map consists of distinct messages $m\ne m'$ having equal outputs.

### 2.3 Evaluation complexity

Computing $T_h(m)$ requires forming $k$ sums and maintaining a running minimum. In the unit-cost real-arithmetic model this uses $O(k)$ time and $O(1)$ auxiliary space. The two-key map uses $O(k)$ time as well: both running minima may be maintained in a single pass.

## 3. Exact scalar fibers

The first result completely describes inversion.

**Lemma 3.1 (Coordinate upper bound).** For every key $h$, message $m$, and coordinate $i$,

$$
T_h(m)\le m_i+h_i.
$$

**Proof sketch.** The value $T_h(m)$ is the minimum of the finite family $m_j+h_j$. A minimum is no greater than any member of that family. $\square$

**Lemma 3.2 (Attainment).** For every key $h$ and message $m$, there exists a coordinate $p$ such that

$$
m_p+h_p=T_h(m).
$$

**Proof sketch.** Every nonempty finite set of real numbers has a member equal to its minimum. Apply this to $\{m_i+h_i:1\le i\le k\}$. $\square$

**Theorem 3.3 (Exact Fiber Theorem).** Let $h,m\in\mathbb{R}^k$ with $k\ge1$, and let $y\in\mathbb{R}$. Then

$$
T_h(m)=y
$$

if and only if both of the following conditions hold:

$$
y\le m_i+h_i\quad\text{for every }i,
$$

and

$$
m_p+h_p=y\quad\text{for at least one coordinate }p.
$$

**Proof sketch.** If $T_h(m)=y$, Lemma 3.1 gives all inequalities and Lemma 3.2 supplies an attaining coordinate. Conversely, suppose every coordinate sum is at least $y$ and one coordinate sum equals $y$. The first condition makes the minimum at least $y$; the equality makes it at most $y$. Hence the minimum is exactly $y$. $\square$

The theorem may be rewritten directly in message coordinates.

**Corollary 3.4 (Geometric fiber description).** The fiber over $y$ is

$$
F_h(y)=\left\{m\in\mathbb{R}^k:
 m_i\ge y-h_i\text{ for every }i,
 \text{ and }m_p=y-h_p\text{ for some }p
\right\}.
$$

Equivalently, $F_h(y)$ is the union

$$
F_h(y)=\bigcup_{p=1}^k
\left\{m:m_p=y-h_p,\ m_i\ge y-h_i\text{ for all }i\right\}.
$$

**Proof sketch.** Subtract $h_i$ from each inequality and equality in Theorem 3.3. $\square$

Each set in the union is a closed polyhedral face of dimension $k-1$ when considered in the ambient real space. Their intersections correspond to messages with several simultaneous active coordinates. The fiber is therefore a polyhedral union with many unbounded directions.

### 3.1 Canonical inversion and surjectivity

**Theorem 3.5 (Canonical Preimage Theorem).** For any key $h\in\mathbb{R}^k$ and target $y\in\mathbb{R}$, define

$$
m_i^{\star}=y-h_i\qquad(1\le i\le k).
$$

Then

$$
T_h(m^{\star})=y.
$$

**Proof sketch.** For every coordinate,

$$
m_i^{\star}+h_i=(y-h_i)+h_i=y.
$$

The minimum of $k$ copies of $y$ is $y$. $\square$

**Corollary 3.6 (Surjectivity).** For every $k\ge1$ and every key $h\in\mathbb{R}^k$, the map $T_h:\mathbb{R}^k\to\mathbb{R}$ is surjective.

**Proof sketch.** Given any $y\in\mathbb{R}$, Theorem 3.5 supplies a message mapped to $y$. $\square$

**Corollary 3.7 (Linear-time unrestricted inversion).** In the unit-cost real-arithmetic model, a preimage of any prescribed scalar output can be constructed in $O(k)$ time and $O(k)$ output space.

**Proof sketch.** Compute each coordinate $y-h_i$ once. No search, path enumeration, or optimization procedure is required. $\square$

This result decisively separates the present map from a one-way function. Its inversion cost has the same asymptotic order as its evaluation cost. In particular, the scalar preimage problem does not reduce to a hard shortest-path search in the unrestricted model; its full solution is coordinatewise.

## 4. Stability and collision geometry

The fiber description suggests a more general preservation rule.

**Lemma 4.1 (Inactive-Coordinate Update Principle).** Let $p$ be active for $(h,m)$, so that $m_p+h_p=T_h(m)$. Let $q\ne p$, and let $d\ge0$. Define $m'$ by

$$
m'_q=m_q+d,
$$

and $m'_i=m_i$ for $i\ne q$. Then

$$
T_h(m')=T_h(m).
$$

**Proof sketch.** The active value at $p$ is unchanged because $p\ne q$, so $T_h(m')\le m'_p+h_p=T_h(m)$. On the other hand, unchanged coordinates remain at least the old minimum, while the modified coordinate has increased and therefore also remains at least the old minimum. Thus $T_h(m')\ge T_h(m)$. The inequalities combine to equality. $\square$

The hypothesis $d\ge0$ is essential for this one-sided rule: lowering a coordinate could create a new, smaller minimum. The existence of an untouched active coordinate is also essential; raising the unique active coordinate may change the output.

**Corollary 4.2 (Collision rays for the scalar map).** If $k\ge2$, then every message has a distinct scalar collision. More strongly, after choosing an active coordinate $p$ and any $q\ne p$, the ray

$$
\{m+d e_q:d\ge0\}
$$

lies in the same scalar fiber, where $e_q$ is the $q$th standard basis vector.

**Proof sketch.** Apply Lemma 4.1 for every $d\ge0$. Any $d>0$ gives a distinct message. $\square$

Thus scalar collisions are not isolated pairs. Fibers contain unbounded continua of messages.

## 5. Universal collisions for two keys

Adding a second output component might appear to constrain the fibers enough to restore collision resistance. The next theorem shows that this is not so once a third message coordinate is available.

**Lemma 5.1 (Avoiding two witnesses).** If $k\ge3$ and $p,r\in\{1,\ldots,k\}$, then there exists a coordinate $q$ such that $q\ne p$ and $q\ne r$.

**Proof sketch.** At most two indices are forbidden, while at least three indices are available. If $p=r$, only one index is forbidden. $\square$

**Theorem 5.2 (Universal Two-Key Collision Theorem).** Let $k\ge3$. For every pair of keys $h,h'\in\mathbb{R}^k$ and every message $m\in\mathbb{R}^k$, there exists a distinct message $m'\in\mathbb{R}^k$ such that

$$
T_{h,h'}^{(2)}(m')=T_{h,h'}^{(2)}(m).
$$

**Proof sketch.** Choose an active coordinate $p$ for the first key and an active coordinate $r$ for the second. By Lemma 5.1, choose $q$ distinct from both. Define $m'=m+e_q$, so only coordinate $q$ is increased by $1$. Since $q\ne p$, Lemma 4.1 applied to key $h$ gives $T_h(m')=T_h(m)$. Since $q\ne r$, the same lemma applied to key $h'$ gives $T_{h'}(m')=T_{h'}(m)$. Therefore the ordered pairs are equal. The messages are distinct because their $q$th coordinates differ by $1$. $\square$

**Corollary 5.3 (Unbounded two-key collision ray).** Under the hypotheses of Theorem 5.2, there is a coordinate $q$ such that

$$
T_{h,h'}^{(2)}(m+d e_q)=T_{h,h'}^{(2)}(m)
$$

for every $d\ge0$.

**Proof sketch.** Use the same witnesses $p,r$ and avoided coordinate $q$, then apply Lemma 4.1 to each key for arbitrary $d\ge0$. $\square$

**Corollary 5.4 (Linear-time collision construction).** A collision for the two-key map in dimension $k\ge3$ can be constructed in $O(k)$ time and $O(k)$ output space.

**Proof sketch.** Scan the coordinates once to locate a minimizer for each key, choose any coordinate outside the at-most-two-element witness set, copy the message, and increase that coordinate. Finding both minima and copying the output dominate the running time. $\square$

The result is stronger than a high collision probability. It is independent of any random-key distribution and holds at every message. Consequently, a proposed collision-resistance estimate of $1-O(1/k)$ is inapplicable to this unrestricted model: the construction is everywhere non-injective for $k\ge3$.

The dimension condition is a sufficient condition tailored to a universal statement. In dimension two, collisions may still occur, for example when both keys share an active coordinate or ties leave a common inactive direction. The theorem does not claim injectivity for $k<3$; it asserts that no special position, tie, or favorable key choice is needed once $k\ge3$.

## 6. Concavity of the two-coordinate minimum

The same minimum operation that destroys diffusion has a useful geometric property.

**Theorem 6.1 (Pairwise Concavity Theorem).** Let $v,w\in\mathbb{R}^2$ and $t\in[0,1]$. Then

$$
\min\big((1-t)v_0+tw_0,\ (1-t)v_1+tw_1\big)
\ge
(1-t)\min(v_0,v_1)+t\min(w_0,w_1).
$$

Equivalently, the function $f:\mathbb{R}^2\to\mathbb{R}$ defined by $f(x_0,x_1)=\min(x_0,x_1)$ is concave.

**Proof sketch.** Write $a=\min(v_0,v_1)$ and $b=\min(w_0,w_1)$. For each coordinate $i\in\{0,1\}$, one has $v_i\ge a$ and $w_i\ge b$. Because $t$ and $1-t$ are nonnegative,

$$
(1-t)v_i+tw_i\ge(1-t)a+tb.
$$

Both interpolated coordinates satisfy this lower bound, so their minimum satisfies it as well. $\square$

This theorem identifies the hash as a piecewise-linear concave function of its coordinate sums. Concavity is compatible with broad fibers: the graph is assembled from affine pieces meeting along ridges, and directions that do not alter the active affine piece may leave the value unchanged. Optimization regularity should therefore not be confused with cryptographic sensitivity.

## 7. Algorithms and numerical experiments

### 7.1 Evaluation

The scalar evaluation algorithm initializes a running value with the first coordinate sum and replaces it whenever a smaller sum appears. It returns both the minimum and, if desired, a witness index. The two-key variant maintains two independent running minima. Both require linear time.

### 7.2 Canonical inversion

Given $h$ and $y$, output $m_i=y-h_i$. The resulting message lies at the intersection of all $k$ principal faces of the fiber: every coordinate is active. This algorithm uses $k$ subtractions and is exact up to the arithmetic model used in an implementation.

### 7.3 Deterministic two-key collision construction

Given $h,h',m$ with $k\ge3$:

1. Find $p$ minimizing $m_i+h_i$.
2. Find $r$ minimizing $m_i+h'_i$.
3. Find $q\notin\{p,r\}$.
4. Choose any $d>0$ and return $m+d e_q$.

The output differs from $m$, and both keyed minima are preserved. Replacing $d$ by any positive real parameter exhibits an entire collision ray.

### 7.4 What experiments can and cannot show

Numerical examples can illustrate the exact identities and explore finite samples, but the conclusions above do not depend on empirical collision frequencies. Floating-point arithmetic may introduce rounding differences, so exact integer examples are preferable when demonstrating equality. Random experiments should be interpreted as illustrations of deterministic theorems, not evidence in place of them.

Comparisons with a conventional cryptographic digest must also be made carefully. A conventional digest maps byte strings into a large finite output space and is designed for avalanche behavior. The tropical maps here take unrestricted real vectors and expose a minimum. Their domains, codomains, and security goals differ. Timing the two operations may demonstrate computational cost, but it does not place their security on a common scale.

## 8. Cryptographic interpretation and limitations

A cryptographic hash is expected to support preimage resistance and collision resistance under a clearly specified finite encoding and adversarial model. The scalar tropical map fails unrestricted preimage resistance because Theorem 3.5 gives an explicit inverse construction for every target. The two-key map fails unrestricted collision resistance because Theorem 5.2 gives a collision from every message.

The mechanism is lack of diffusion. Each min-plus linear form chooses at least one active coordinate. Coordinates not required as active witnesses can often move upward unnoticed. Adding independent keys adds witnesses, but does not force the coordinates to interact. Two output components protect at most two selected indices in the universal argument.

Several limitations delimit the conclusions.

* Messages are arbitrary vectors in $\mathbb{R}^k$. A bounded or discrete alphabet can prevent an indicated upward move at a boundary.
* Coordinates are independent. Nonce formats or linear constraints may couple them, so modifying one coordinate alone may be illegal.
* The circuits are shallow and uncoupled: each component is one minimum of affine coordinate terms. Deeper tropical circuits can reuse and mix coordinates.
* No average-case or worst-case lower bound is asserted for constrained variants. The present conclusions are constructive algebraic upper bounds and non-injectivity results.
* The results do not establish security for any alternative tropical construction; they specify obstructions that alternatives must avoid.

These limitations are not defects in the theorems. They locate where new mathematical difficulty would have to arise.

## 9. Applications beyond hashing

The exact fiber certificate is useful wherever a minimum of shifted coordinates appears. In scheduling, $T_h(m)=y$ records the earliest of several offset events; the fiber description identifies all schedules producing the same earliest time. In sensitivity analysis, Lemma 4.1 identifies perturbations that do not alter an optimum. In inverse optimization, the canonical preimage gives a baseline configuration realizing a prescribed optimum. In polyhedral geometry, active-coordinate sets index the faces composing each level set.

The collision theorem can likewise be read as an observability result. Two minimum sensors cannot distinguish all states of a system with at least three independently adjustable coordinates. The proof constructs an unobservable direction by preserving one witness per sensor. This interpretation applies to monitoring and compressed summaries even when no cryptographic claim is intended.

Concavity supports optimization uses. Since minima of affine functions are concave, maximizing such an expression over a convex feasible set fits concave maximization conventions, while superlevel sets are convex polyhedra. Yet these same superlevel regions contain recession directions. The geometry favorable to optimization is precisely what exposes information loss.

## 10. Discussion and design principles

The analysis suggests three design tests for future tropical hashing proposals.

First, characterize fibers before making complexity claims. An output equation involving a minimum may decompose into elementary inequalities and active equalities. If so, inversion may be direct.

Second, count independent witnesses and independent coordinates. For a fixed number of uncoupled min-plus forms, preserving one active witness per component can leave unused coordinates. Those coordinates are natural collision directions.

Third, require diffusion through coupling. Potential mechanisms include discrete encodings, sparse constraint graphs, repeated coordinate reuse, and nonlinear tropical circuit layers. A coordinate should influence multiple downstream comparisons, and a legal nonce change should propagate across the state. Merely appending more independent minima does not provide this behavior.

These principles turn a negative security result into a constructive research program. Tropical algebra remains attractive for transparent optimization-based computation, but a cryptographic design must prevent its transparent fibers from becoming adversarial shortcuts.

## 11. Future work

A first direction is constrained inversion. If messages satisfy integer difference constraints, the fiber inequalities interact with a graph of coordinate couplings. Bounded-treewidth graphs may admit dynamic programming, while unrestricted graphs may support hardness reductions. This would isolate a genuine complexity transition absent from the free-coordinate model.

A second direction is the general $r$-key case. The witness argument strongly suggests that $r$ uncoupled min-plus linear forms on $k>r$ coordinates admit an unbounded collision ray through every message. Establishing the statement systematically would quantify the failure of security under any fixed number of independent linear keys.

A third direction is generic fiber dimension. Simultaneous tropical outputs produce intersections of finite unions of polyhedra. Active-set analysis should describe their maximal cells and recession cones, with expected dimension at least $k-r$ under suitable genericity assumptions.

A fourth direction is nonlinear tropical circuitry over discrete alphabets. Coordinate mixing and repeated reuse may eliminate the simple inactive-coordinate update. Security questions would then require a precise average-case assumption and a fixed encoding, rather than relying on the minimum alone.

Finally, mining thresholds deserve separate study. The decision problem $T_h(m)<\tau$ is trivial for unconstrained messages but may become meaningful when $m$ is generated by a legal nonce map or constrained feasible set. The geometry of recession cones could determine whether threshold satisfaction is inevitable, impossible, or computationally nontrivial.

## 12. Conclusion

The scalar min-plus hash has completely explicit fibers. Every target $y$ has the canonical preimage $m_i=y-h_i$, so unrestricted inversion takes linear time and every real output is attained. Raising a non-witness coordinate preserves the hash. With two keys in dimension at least three, one may preserve one minimizing witness for each component and raise a third coordinate, producing a deterministic collision and indeed an unbounded collision ray through every message.

At the same time, the two-coordinate minimum is concave along line segments, confirming the construction's natural place in tropical optimization geometry. This coexistence is the central lesson: algebraic elegance and optimization structure do not imply cryptographic one-wayness. For tropical mining to become a credible security mechanism, hardness must be created by constraints, diffusion, and nonlinear coordinate coupling rather than assumed to emerge from coordinatewise minima.