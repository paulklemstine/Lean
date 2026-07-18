# Universal Collision Rays in Finite Min-Plus Digest Families

**Aristotle**  
**July 18, 2026**

## Abstract

We study a family of tropical, or min-plus, digest maps on real-valued messages. Given $r$ key vectors on $k$ coordinates, the digest of a message records, for each key, the minimum of the coordinatewise message–key sums. We prove that whenever $r<k$, every digest fiber contains an unbounded collision ray obtained by increasing one message coordinate. The construction is universal: it applies to every choice of keys and every base message. Positive points on the ray are distinct from the base message, and distinct positive parameters produce distinct messages, so every fiber contains an injective copy of the positive real half-line. The argument selects one minimizing coordinate for each output component and applies the pigeonhole principle to find a coordinate outside all selected witnesses. We give a deterministic $O(rk)$ collision-construction algorithm, discuss the polyhedral geometry of the fibers, and explain the implications for tropical analogues of cryptocurrency mining. The result isolates a dimension-based obstruction to collision resistance and clarifies why bounded alphabets, restricted nonce languages, and richer nonlinear constructions are the relevant settings for further study.

## 1. Introduction

The min-plus semiring replaces ordinary addition by minimum and ordinary multiplication by addition. It is a natural language for shortest paths, scheduling, optimal control, and discrete-event systems. If alternatives compete by cost, taking a minimum chooses the winner; if stages are concatenated, adding costs composes them. These operations lead to piecewise-linear maps with explicit combinatorial structure.

That same structure is problematic when min-plus expressions are used as cryptographic digests. A cryptographic hash is expected to compress an input while frustrating inversion and deliberate collision construction. A min-plus expression instead exposes a winning coordinate. Its output is certified locally: one coordinate attaining a minimum suffices to explain an entire component.

We consider messages $m\in\mathbb{R}^k$ and a finite family of $r$ keys. Each key produces one scalar minimum, and the $r$ scalars form the digest. The central question is whether parallel components can remove the elementary collisions visible in a one-component minimum. Our answer is negative whenever there are fewer output components than message coordinates.

The main result is the Universal Collision-Ray Theorem. For arbitrary keys and an arbitrary message, if $r<k$, then some coordinate may be increased by every nonnegative real amount without changing any digest component. This yields not just one collision but an unbounded continuum through every message. Moreover, the parameterization by positive real increments is injective.

The mechanism is a pigeonhole obstruction. Choose one active minimizing coordinate for each component. These $r$ choices occupy at most $r$ coordinates. Since the message has $k>r$ coordinates, one coordinate remains outside the chosen active set. Increasing it cannot lower any candidate value, while every component retains an unchanged witness to its former minimum.

This observation has several consequences. First, collision construction is deterministic and elementary, requiring $O(rk)$ work for dense inputs. Second, the failure is geometric rather than statistical: every fiber contains a recession direction. Third, adding parallel outputs does not repair the primitive until the output count at least reaches the input dimension, and even then no positive security conclusion follows automatically. Finally, if a restricted tropical mining problem is computationally difficult, that difficulty must come from restrictions on admissible messages or nonces, not from the unrestricted min-plus digest.

The paper is organized as follows. Section 2 defines the digest and its fibers. Section 3 establishes minimum stability under a nonnegative update. Section 4 proves the universal ray, positive collision, and injectivity results. Section 5 presents constructive algorithms and complexity bounds. Section 6 develops the polyhedral interpretation. Section 7 discusses mining and security implications. Section 8 treats limitations and boundary cases, Section 9 gives applications, and Section 10 outlines future research.

## 2. Min-plus digest families

### 2.1. Tropical arithmetic

The min-plus operations on real numbers are commonly written

$$
a\oplus b=\min(a,b),\qquad a\odot b=a+b.
$$

Only the resulting minimum-of-sums expression is needed here. Fix a positive integer $k$, the message dimension. A message is a vector

$$
m=(m_1,\ldots,m_k)\in\mathbb{R}^k.
$$

A min-plus key is another vector

$$
h=(h_1,\ldots,h_k)\in\mathbb{R}^k.
$$

### Definition 2.1 (Single-component min-plus digest)

For a key $h\in\mathbb{R}^k$, define

$$
T_h(m)=\min_{1\le i\le k}(m_i+h_i).
$$

An index $p\in\{1,\ldots,k\}$ is an **active minimizing coordinate** for $h$ at $m$ if

$$
m_p+h_p=T_h(m).
$$

Because the index set is finite and nonempty, at least one active minimizing coordinate always exists. It need not be unique.

### Definition 2.2 (Finite digest family)

Fix a nonnegative integer $r$ and keys

$$
h^{(1)},\ldots,h^{(r)}\in\mathbb{R}^k.
$$

The associated $r$-component digest is the map $D:\mathbb{R}^k\to\mathbb{R}^r$ given by

$$
D(m)_j=T_{h^{(j)}}(m)
=\min_{1\le i\le k}\bigl(m_i+h^{(j)}_i\bigr),
\qquad 1\le j\le r.
$$

When $r=0$, the codomain consists of the unique empty tuple and every message has the same digest. The substantive case has $1\le r<k$.

### Definition 2.3 (Digest fiber and collision)

For $y\in\mathbb{R}^r$, the fiber over $y$ is

$$
D^{-1}(y)=\{x\in\mathbb{R}^k:D(x)=y\}.
$$

Two distinct messages $m,n\in\mathbb{R}^k$ form a collision if $D(m)=D(n)$. A collision ray through $m$ is a family $m(d)$ indexed by $d\ge 0$ such that $m(0)=m$ and $D(m(d))=D(m)$ for all $d\ge 0$.

### Definition 2.4 (Single-coordinate update)

For a coordinate $q\in\{1,\ldots,k\}$ and an increment $d\in\mathbb{R}$, define $U_{q,d}(m)$ by

$$
U_{q,d}(m)_i=
\begin{cases}
m_q+d,&i=q,\\
m_i,&i\ne q.
\end{cases}
$$

Our collision rays have the form $d\mapsto U_{q,d}(m)$ for $d\ge 0$.

## 3. Stability of a minimum under an avoided update

The core analytic fact is elementary: if one known minimizer is left untouched and another coordinate is only increased, then the minimum cannot change.

### Lemma 3.1 (One-component stability)

Let $h,m\in\mathbb{R}^k$. Suppose $p$ is an active minimizing coordinate for $h$ at $m$. If $q\ne p$ and $d\ge 0$, then

$$
T_h\bigl(U_{q,d}(m)\bigr)=T_h(m).
$$

#### Proof sketch

Set $m'=U_{q,d}(m)$. Since $q\ne p$, the value at the active coordinate is unchanged:

$$
m'_p+h_p=m_p+h_p=T_h(m).
$$

Thus $T_h(m')\le T_h(m)$. Conversely, every adjusted coordinate value for $m'$ is at least its old value. Values with index $i\ne q$ are unchanged, while

$$
m'_q+h_q=m_q+h_q+d\ge m_q+h_q.
$$

Taking minima gives $T_h(m')\ge T_h(m)$. The two inequalities imply equality. $\square$

This lemma deliberately requires only one preserved minimizer. If a component has several tied minimizers and the updated coordinate is one of them, the conclusion can still hold because another tied minimizer may remain. The later construction chooses a particular witness for each component and avoids all chosen witnesses, which is sufficient regardless of ties.

### Lemma 3.2 (Avoided-witness stability for a family)

For each component $j$, choose an active minimizing coordinate $p_j$ for $h^{(j)}$ at $m$. If a coordinate $q$ satisfies $q\ne p_j$ for every $j$, then for every $d\ge 0$,

$$
D\bigl(U_{q,d}(m)\bigr)=D(m).
$$

#### Proof sketch

Apply Lemma 3.1 separately to each key $h^{(j)}$, using its selected witness $p_j$. Equality holds in every output coordinate, hence for the whole digest vector. $\square$

The remaining problem is purely combinatorial: prove that a coordinate avoiding all selected witnesses exists.

### Lemma 3.3 (Coordinate outside a short selection)

Let $p_1,\ldots,p_r$ be indices in $\{1,\ldots,k\}$. If $r<k$, then some $q\in\{1,\ldots,k\}$ differs from every $p_j$.

#### Proof sketch

The set $\{p_1,\ldots,p_r\}$ has cardinality at most $r$. It therefore cannot equal a set of $k>r$ coordinates. Any coordinate in its complement has the required property. This is the pigeonhole principle in range form. $\square$

## 4. Main results

### Theorem 4.1 (Universal Collision-Ray Theorem)

Let $D:\mathbb{R}^k\to\mathbb{R}^r$ be the digest associated with any family of $r$ min-plus keys. If $r<k$, then for every message $m\in\mathbb{R}^k$ there exists a coordinate $q$ such that

$$
D\bigl(U_{q,d}(m)\bigr)=D(m)
\qquad\text{for every }d\ge 0.
$$

Consequently, every fiber containing $m$ includes the entire nonnegative coordinate ray

$$
\{U_{q,d}(m):d\ge 0\}.
$$

#### Proof sketch

For each output component $j$, choose an active minimizing coordinate $p_j$ satisfying

$$
m_{p_j}+h^{(j)}_{p_j}=D(m)_j.
$$

There are $r$ selected coordinates among $k$ possible coordinates. Since $r<k$, Lemma 3.3 supplies a coordinate $q$ not equal to any $p_j$. Lemma 3.2 then shows that increasing coordinate $q$ by any $d\ge 0$ preserves all components of the digest. $\square$

Several quantifiers in the theorem are worth emphasizing. The keys are arbitrary, the message is arbitrary, and the increment is unbounded. The escaping coordinate may depend on both the key family and the message because active minimizers can change across message space. No randomness or genericity assumption is used.

### Corollary 4.2 (Positive-Ray Collision Result)

Under the assumptions of Theorem 4.1, for every message $m$ there is a coordinate $q$ such that, for every $d>0$,

$$
U_{q,d}(m)\ne m
\qquad\text{and}\qquad
D\bigl(U_{q,d}(m)\bigr)=D(m).
$$

#### Proof sketch

The digest equality follows from Theorem 4.1 because $d>0$ implies $d\ge 0$. The updated message differs from $m$ at coordinate $q$, where its value is $m_q+d\ne m_q$. $\square$

Thus every base message has explicit collisions at arbitrary positive distances along one coordinate direction. In any norm for which $\|d e_q\|$ tends to infinity with $d$, these collisions can be arbitrarily far from the base message.

### Theorem 4.3 (Injective Collision-Ray Result)

Under the assumptions of Theorem 4.1, for every message $m$ there is a coordinate $q$ such that the map

$$
\Phi:(0,\infty)\to\mathbb{R}^k,
\qquad
\Phi(d)=U_{q,d}(m),
$$

is injective and satisfies

$$
D(\Phi(d))=D(m)
\qquad\text{for every }d>0.
$$

Hence every digest fiber contains an injectively parameterized copy of the positive real half-line.

#### Proof sketch

Choose $q$ from Theorem 4.1. Digest constancy is immediate. If $\Phi(d)=\Phi(e)$, compare their $q$th coordinates:

$$
m_q+d=m_q+e.
$$

Cancellation gives $d=e$, proving injectivity. $\square$

### Corollary 4.4 (Uncountably infinite fibers)

If $r<k$, every nonempty fiber of $D$ is uncountable and unbounded.

#### Proof sketch

Choose any $m$ in the fiber. Theorem 4.3 injects $(0,\infty)$ into that fiber, proving uncountability. The coordinate $m_q+d$ tends to infinity as $d$ tends to infinity, proving unboundedness. $\square$

This corollary is a standard set-theoretic and geometric consequence of the stronger injective-ray statement. The ray theorem is more informative than a cardinality assertion because it gives both a formula and a direction.

## 5. Constructive collision algorithms

The proof provides an algorithm rather than merely an existence argument.

### Algorithm 5.1 (Active-Witness Escape)

**Input:** a message $m\in\mathbb{R}^k$, keys $h^{(1)},\ldots,h^{(r)}\in\mathbb{R}^k$ with $r<k$, and an increment $d\ge 0$.

**Output:** a coordinate $q$ and a message $m'=U_{q,d}(m)$ satisfying $D(m')=D(m)$; if $d>0$, then $m'\ne m$.

1. Initialize a Boolean array of $k$ marks to false.
2. For each component $j$, scan all coordinates and choose an index $p_j$ minimizing $m_i+h^{(j)}_i$.
3. Mark coordinate $p_j$.
4. Scan the marks and choose any unmarked coordinate $q$.
5. Return $q$ and the message obtained by adding $d$ to coordinate $q$.

The condition $r<k$ guarantees that step 4 succeeds, since at most one new coordinate is marked per component.

### Proposition 5.2 (Correctness and complexity)

For dense arrays, Active-Witness Escape is correct and runs in $O(rk)$ time using $O(k)$ auxiliary space. Once $q$ is known, each additional point on the same collision ray can be generated in $O(1)$ update time, excluding the cost of copying or printing a full $k$-vector.

#### Proof sketch

Correctness is Theorem 4.1. Computing one minimum over $k$ candidates costs $O(k)$, repeated for $r$ components, giving $O(rk)$. The mark array and the scan for an unmarked coordinate use $O(k)$ space and time. A single coordinate update is constant-time in a mutable or sparse-update representation; materializing a fresh dense vector costs $O(k)$. $\square$

### Algorithm 5.3 (Collision-Ray Sampler)

Given a base message and keys, first run the witness-selection phase once to obtain $q$. For any requested list of positive parameters $d_1,\ldots,d_s$, output

$$
U_{q,d_1}(m),\ldots,U_{q,d_s}(m).
$$

The preprocessing cost is $O(rk)$, followed by $O(s)$ coordinate updates or $O(sk)$ work if all dense messages must be copied. Distinct parameters produce distinct collision messages by Theorem 4.3.

### Algorithm 5.4 (Digest and active-set analysis)

For geometric analysis, one may compute not only one witness but the full active set

$$
A_j(m)=\{i:m_i+h^{(j)}_i=D(m)_j\}
$$

for every component. This requires two passes per component, or one pass maintaining the current minimum and tied indices, and still costs $O(rk)$ time. Any coordinate outside a chosen transversal $p_j\in A_j(m)$ yields the guaranteed ray. The full active sets can reveal additional simultaneous escape directions not captured by a single witness selection.

## 6. Polyhedral geometry of digest fibers

The collision theorem has a natural geometric interpretation. For a fixed key $h$ and a chosen active index $p$, the region in which $p$ attains the minimum is defined by

$$
m_p+h_p\le m_i+h_i
\qquad\text{for every }i.
$$

Equivalently,

$$
m_p-m_i\le h_i-h_p
\qquad\text{for every }i.
$$

These are linear inequalities, so the active region is a closed polyhedron. For a family of keys and a selected active pattern $(p_1,\ldots,p_r)$, intersecting the corresponding inequalities again gives a polyhedron.

Within such a region, the digest has the affine form

$$
D(m)_j=m_{p_j}+h^{(j)}_{p_j}.
$$

If $q$ differs from every selected $p_j$, then moving in the positive coordinate direction $e_q$ leaves each displayed affine expression unchanged. It also preserves the active inequalities because the right-hand competitors involving $m_q$ become larger rather than smaller. Thus $e_q$ lies in a recession cone of the relevant fiber cell.

### Proposition 6.1 (Guaranteed recession direction)

For every message $m$ and every $r$-component min-plus digest with $r<k$, some standard basis direction $e_q$ satisfies

$$
m+d e_q\in D^{-1}(D(m))
\qquad\text{for all }d\ge 0.
$$

#### Proof sketch

This is Theorem 4.1 rewritten in vector notation. The selected coordinate update is exactly $m+d e_q$. $\square$

The proposition guarantees a one-dimensional cone but does not identify the full recession cone. Different witness selections may expose different coordinates. If a coordinate is absent from every active set, it is clearly free to increase. More subtly, even a coordinate belonging to some active set may be avoidable if that component has another tied minimizer. The combinatorics of active sets therefore controls the local geometry.

A tempting dimension heuristic is that $r$ scalar outputs should constrain at most $r$ independent directions, leaving roughly $k-r$ recession dimensions. The present argument proves only one direction universally because selecting one witness per component ensures only that the complement is nonempty. Establishing a general $k-r$ lower bound, or an exact generic dimension, requires compatible choices across all active sets and a precise analysis of fiber cells.

## 7. Implications for tropical cryptocurrency models

A proof-of-work system based on a conventional hash repeatedly evaluates a digest of a block header and nonce, seeking an output under a target. Its security intuition relies on the absence of exploitable algebraic structure. A min-plus digest behaves differently: each output component is an optimization statistic whose winner is directly identifiable.

In an unrestricted real-valued message model, collision resistance fails maximally when $r<k$. Every message has an unbounded ray of collisions, and Active-Witness Escape constructs one deterministically. Increasing the number of parallel components does not remove the obstruction unless the count reaches at least $k$. Even $r\ge k$ is only a necessary condition for avoiding this particular theorem, not a sufficient condition for cryptographic security.

Preimage and target problems also inherit piecewise-linear structure. A condition such as

$$
T_h(m)\le t
$$

means that at least one coordinate satisfies $m_i+h_i\le t$, a union of half-spaces. An equality $T_h(m)=t$ requires all candidates to be at least $t$ and at least one to equal $t$. For several components, the feasible set is a union of polyhedra indexed by active-coordinate patterns. This geometry is useful for optimization but offers attackers an explicit decomposition into linear regions.

Restrictions can change the computational picture. A practical nonce is not an arbitrary point of $\mathbb{R}^k$; it may encode a bounded integer or belong to a structured language. If the escaping coordinate cannot be changed independently, the universal ray need not correspond to legal nonces. In that case, any hardness comes from the admissible set and its interaction with the digest. Difference constraints may preserve efficient shortest-path structure, whereas arbitrary binary linear constraints can express combinatorial choices.

The correct conclusion is therefore not that all tropical computation is unsuitable for security. Rather, a finite family of bare coordinatewise min-plus forms is intrinsically non-collision-resistant in the underdetermined regime. Cryptographic aspirations would require additional mixing, nonlinear tropical circuitry, constrained encodings, or other mechanisms that prevent one coordinate from escaping all output witnesses.

## 8. Boundary cases and limitations

### 8.1. Output count at least the message dimension

When $r\ge k$, a list of $r$ selected minimizers can cover every coordinate, so Lemma 3.3 no longer applies. The universal theorem makes no claim in this regime. Collisions may still arise from repeated witnesses, ties, redundant keys, translation symmetries under modified output conventions, or other degeneracies. The absence of the pigeonhole obstruction is not evidence of one-wayness.

### 8.2. Bounded alphabets

Suppose messages belong to

$$
\{0,1,\ldots,B\}^k.
$$

The real collision ray may leave this set. If the selected escape coordinate has value $m_q<B$, then at least the increment $d=1$ gives a legal discrete collision. If every coordinate that can avoid the witnesses already equals $B$, this direct construction is blocked. A sharp finite theorem must therefore account for coordinate slack and key-dependent active patterns.

### 8.3. Negative increments

The theorem uses $d\ge 0$. Decreasing a non-witness coordinate can create a new, smaller minimum and change one or more outputs. A limited negative interval may still preserve the digest if the coordinate has sufficient margin above every relevant minimum, but no unbounded negative ray is universally available.

For a fixed candidate coordinate $q$, the permissible decrease before component $j$ changes is governed by

$$
(m_q+h^{(j)}_q)-D(m)_j.
$$

The minimum of these nonnegative margins controls a local two-sided segment when $q$ is not strictly active. The universal statement chooses the monotone direction because increasing a candidate is always safe once another witness remains.

### 8.4. One guaranteed dimension versus many

The result proves that each fiber has at least one explicit recession direction when $r<k$. It does not prove that the recession dimension is exactly one, nor that it is always at least $k-r$. Some examples possess many free coordinates. Others have complicated tied active sets. A full dimension theorem must distinguish the recession cone of a particular polyhedral cell from the global, possibly nonconvex fiber.

## 9. Examples and applications

### Example 9.1 (Two outputs and four coordinates)

Let

$$
m=(3,1,4,2),
$$

and choose

$$
h^{(1)}=(0,2,-1,3),\qquad
h^{(2)}=(4,0,2,-2).
$$

The adjusted values are

$$
m+h^{(1)}=(3,3,3,5),
$$

and

$$
m+h^{(2)}=(7,1,6,0).
$$

Choose coordinate $1$ as a witness for the first component and coordinate $4$ for the second. Coordinate $3$ avoids both. Hence

$$
D(3,1,4+d,2)=(3,0)
\qquad\text{for all }d\ge 0.
$$

The same would hold using coordinate $2$ as the selected escape direction for this witness choice, although coordinate $2$ is itself active for neither selected component here.

### Example 9.2 (Repeated minimizers strengthen the failure)

Let $k=5$ and suppose all three output components attain their minima at coordinate $1$. Selecting $p_1=p_2=p_3=1$ leaves four coordinates outside the selected range, even though $r=3$. Each of those four coordinates can individually be increased without changing the digest. This demonstrates why the actual fiber geometry may be much larger than the universal one-ray guarantee.

### Example 9.3 (A bounded obstruction)

Consider messages in $\{0,1\}^3$ with one output component. If a message is $(0,1,1)$ and the unique selected witness is coordinate $1$, the unused coordinates are already at their upper bound. The real-valued rays through coordinates $2$ and $3$ exist in the ambient space but have no positive discrete point inside the alphabet. This does not restore general security; it shows that finite-domain collision statements require a separate slack argument.

### Application 9.4 (Diagnostic for winner-based summaries)

The same proof applies to any map whose $j$th output is a minimum of expressions in which increasing coordinate $q$ cannot decrease a candidate, provided one untouched active witness certifies the old output. Thus the witness-cover test can diagnose hidden recession directions in optimization summaries, winner-take-all feature maps, and scheduling observables. The cryptographic language highlights collisions, while the geometric content concerns non-identifiability of inputs from winner-based outputs.

## 10. Discussion and future work

The universal collision ray is a baseline structural theorem. It settles the strongest unconditional statement available from output-count alone: fewer min-plus components than coordinates guarantee an explicit unbounded collision family through every message. Several refinements remain open.

First, one expects a sharper description of recession dimension. For generic keys and messages with $r<k$, a natural conjecture is that a nonempty fiber has a polyhedral cell whose recession cone has dimension exactly $k-r$, with sharpness on a dense open set. Proving this requires converting the rank heuristic into a robust statement about active patterns.

Second, the active sets

$$
A_j(m)=\{i:m_i+h^{(j)}_i=D(m)_j\}
$$

suggest a Hall-type criterion. A multidirectional coordinate cone should depend on whether the family of active sets admits a transversal whose complement is large. The one-ray proof chooses an arbitrary transversal with repetition allowed and uses only that its range has size at most $r$. Systems of distinct representatives and complement cardinalities may reveal the full local cone.

Third, bounded alphabets call for a sharp threshold in terms of key spread and coordinate slack. The ambient ray persists only until it reaches the boundary. A useful theorem would identify a computable parameter guaranteeing at least one legal positive step and show that its dependence on $B$ is asymptotically optimal.

Fourth, nonce-restricted mining may exhibit a genuine complexity transition. Tropical output conditions are unions of linear regions indexed by active coordinates. If nonce constraints are difference constraints, shortest-path methods may retain polynomial-time solvability. If arbitrary binary linear constraints are permitted, active-coordinate choices may encode difficult combinatorial decisions.

Finally, nonlinear tropical circuits deserve separate analysis. The present negative result concerns finite families of single-layer coordinate minima. Composing min-plus operations can create richer piecewise-linear maps, although piecewise linearity alone does not imply one-way behavior. Any proposed construction should be evaluated through its active-region geometry, fiber recession cones, and the complexity of navigating its admissible input language.

## 11. Conclusion

A finite min-plus digest with $r$ outputs on $k$ real coordinates cannot be collision-resistant when $r<k$. For every key family and every message, one can select a minimizing witness for each output, find a coordinate outside those witnesses, and increase it by an arbitrary nonnegative amount. The digest remains unchanged. Positive increments yield messages distinct from the base, and distinct parameters yield distinct messages, placing an injective copy of $(0,\infty)$ inside every fiber.

The proof combines minimum stability with the pigeonhole principle, but its implications are geometric and algorithmic. Every fiber has an explicit recession direction, and a collision ray can be found in $O(rk)$ time. Parallel repetition with too few components cannot repair the defect. Restrictions on alphabets or nonce languages may block a particular ray, and the regime $r\ge k$ requires separate analysis, but the unrestricted underdetermined model has a universal escape route.

Min-plus arithmetic excels at exposing winners and shortest paths. A cryptographic digest must instead conceal exploitable paths through its input space. In the setting studied here, the winning-coordinate structure leaves one such path visible in every fiber.
