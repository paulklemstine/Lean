# Perfect Simulation, Random-Point Soundness, and Local Verification

## A Unified Mathematical Account of Zero-Knowledge Verifiable Computation

**Aristotle**  
**29 July 2026**

## Abstract

This paper presents a self-contained mathematical framework connecting three central mechanisms of verifiable computation: perfect zero-knowledge simulation, the graph three-coloring protocol, and polynomial random-point verification, together with a constant-query bridge to probabilistically checkable proofs. Perfect interactive zero knowledge is defined by exact equality between the distribution of a verifier's real view and a simulator distribution depending only on the public statement. Its non-interactive analogue additionally requires every proof in the support of the honest distribution to be accepted. For graph three-colorability, random permutation of the three color labels preserves properness and makes the transcript on a challenged properly colored edge exactly uniform over ordered pairs of distinct colors, yielding perfect completeness and perfect honest-verifier zero knowledge. For a simplified quadratic-arithmetic-program verifier over a finite field, a false identity $p=ht$ passes the random-point test at no more than $\deg(p-ht)$ points; conversely, passing at more points forces the identity. Finally, the graph-coloring oracle verifier reads at most two symbols per edge, and every alleged coloring of a non-three-colorable graph is rejected on at least one such query. Numerical algorithms illustrate transcript equality, root-count soundness, and local rejection. The results isolate a common architecture: small local observations, structural consistency bounds, and simulation-based privacy.

## 1. Introduction

Verifiable computation asks how a resource-limited verifier can gain confidence in a claim without reproducing all of the claimant's work. Zero-knowledge proof adds a stringent privacy requirement: the verification process should reveal nothing about a secret witness beyond what follows from the public claim itself. Succinct arguments and probabilistically checkable proofs approach the same economy from different directions, compressing global correctness into a few algebraic checks or local oracle queries.

This paper develops a compact bridge among these ideas. The treatment begins with distributional definitions of perfect interactive and non-interactive zero knowledge. It then studies the graph three-coloring protocol, where a witness is hidden by a random permutation of color names. Next comes a simplified polynomial verifier of the kind that underlies quadratic arithmetic programs: the verifier tests a claimed identity at a random field point, and polynomial root counting bounds false acceptance. Finally, graph coloring is represented as a locally testable proof oracle in which each edge check reads only two symbols.

The resulting claims are precise but deliberately scoped. The graph theorem gives perfect zero knowledge against the prescribed honest verifier. The polynomial theorem proves the soundness of the random-point identity check, not every cryptographic property of a deployed succinct argument. The local graph verifier establishes constant query complexity and existence of a rejecting query on false instances, not a graph-size-independent rejection gap. These distinctions identify exactly what is obtained from the elementary mathematical core and what remains for cryptographic composition and PCP amplification.

### 1.1. Main results

The paper proves the following results.

1. Equality of real and simulated distributions implies equality of the probability assigned to every individual transcript or proof object.
2. In a non-interactive system, every proof object appearing with nonzero honest probability is accepted.
3. A proper graph three-coloring remains proper under every permutation of the three colors.
4. On a properly colored challenged edge, the revealed ordered pair after a uniform random color permutation has exactly the simulator distribution, uniform over the six ordered pairs of distinct colors.
5. If polynomials $p,h,t$ over a finite field fail to satisfy $p=ht$, then the random-point equality $p(s)=h(s)t(s)$ holds at at most $\deg(p-ht)$ field points.
6. If that equality holds at more field points than the discrepancy degree, then $p=ht$.
7. A local graph-coloring verifier reads at most two oracle symbols per edge, and every alleged coloring of a non-three-colorable graph is rejected on at least one edge.

## 2. Probability Distributions and Proof Systems

### 2.1. Finite probability distributions

Let $X$ be a finite set. A probability mass function on $X$ is a function $\mu:X\to[0,1]$ satisfying

$$
\sum_{x\in X}\mu(x)=1.
$$

Two distributions $\mu$ and $\nu$ are equal when $\mu(x)=\nu(x)$ for every $x\in X$. Exact equality is stronger than computational indistinguishability and stronger than merely having small statistical distance.

The support of $\mu$ is

$$
\operatorname{supp}(\mu)=\{x\in X:\mu(x)>0\}.
$$

For finite spaces, writing $\mu(x)\ne 0$ is equivalent to membership in the support.

### 2.2. Interactive proof systems

An interactive proof system for statements in a set $S$ consists conceptually of a prover, a verifier, a validity predicate $\operatorname{Valid}:S\to\{\text{true},\text{false}\}$, and an interaction producing a verifier view. The view includes everything observed by the verifier: its random coins, messages, challenges, responses, and any public data derived during the exchange.

Completeness requires acceptance on valid statements when the prover follows the protocol using a valid witness. Soundness requires that false statements cannot be accepted too often by a cheating prover. The present distributional layer focuses on privacy and can be combined with separate completeness and soundness theorems.

**Definition 2.1 (Perfect interactive zero knowledge).** Let $V$ be the finite or countable space of verifier views. For each public statement $s$, let $R_s$ be the real-view distribution generated by an honest interaction, and let $M_s$ be a simulator distribution computed from $s$ alone. The system is perfectly zero knowledge on valid statements if

$$
R_s=M_s
$$

for every $s$ satisfying $\operatorname{Valid}(s)$.

The simulator receives no witness. Therefore equality says that the complete observable experiment can be reproduced from public information.

**Theorem 2.2 (Pointwise equality of interactive views).** If a system is perfectly interactive zero knowledge, then for every valid statement $s$ and every view $v$,

$$
R_s(v)=M_s(v).
$$

**Proof sketch.** Equality of probability distributions is extensional equality of their probability mass functions. Evaluating both equal functions at $v$ gives the result. $\square$

This elementary consequence is operationally important. Every event $A\subseteq V$ also has equal probability in the two experiments, because summing pointwise equal probabilities gives

$$
\Pr_{R_s}[A]=\sum_{v\in A}R_s(v)=\sum_{v\in A}M_s(v)=\Pr_{M_s}[A].
$$

### 2.3. Non-interactive perfect zero knowledge

A non-interactive proof system replaces a conversation by one finite proof object. Let $P$ be a finite proof space and let $\operatorname{Verify}(s,\pi)$ be the verifier's acceptance predicate.

**Definition 2.3 (Perfect non-interactive zero knowledge).** For every statement $s$, let $H_s$ be the honest proof distribution and $M_s$ a simulator distribution depending only on $s$. The system is perfectly non-interactive zero knowledge if, for every valid $s$:

1. every $\pi\in\operatorname{supp}(H_s)$ satisfies $\operatorname{Verify}(s,\pi)=\text{true}$; and
2. $H_s=M_s$ as distributions.

The first clause is support correctness. It prevents an honest prover from assigning positive probability to an invalid proof. The second is perfect simulation.

**Theorem 2.4 (Pointwise equality and honest-support acceptance).** For every valid statement $s$ and proof object $\pi$,

$$
H_s(\pi)=M_s(\pi).
$$

Moreover, if $H_s(\pi)>0$, then $\operatorname{Verify}(s,\pi)=\text{true}$.

**Proof sketch.** The equality follows by evaluating $H_s=M_s$ at $\pi$. The acceptance statement is exactly support correctness applied to $\pi$. $\square$

The theorem emphasizes that privacy and acceptance are independent obligations. Simulation alone would permit a simulator and honest prover to agree on a distribution containing rejected proofs; support correctness excludes this defect.

## 3. Perfect Honest-Verifier Zero Knowledge for Graph Three-Coloring

### 3.1. Graphs and proper colorings

Let $G=(V,E)$ be a finite graph, with $E\subseteq V\times V$. Let the color set be

$$
C=\{0,1,2\}.
$$

A coloring is a function $c:V\to C$. It is proper when

$$
\forall (u,v)\in E,\qquad c(u)\ne c(v).
$$

The public statement is that $G$ is three-colorable. The secret witness is a proper coloring $c$.

### 3.2. One round of the protocol

One round proceeds as follows.

1. The prover chooses a permutation $\pi:C\to C$ uniformly from the six permutations of the colors.
2. For every vertex $v$, the prover commits to $\pi(c(v))$. The commitments are binding and hiding at the abstraction level considered here.
3. The verifier selects an edge $(u,v)\in E$.
4. The prover opens the two endpoint commitments.
5. The verifier accepts if the openings are valid and the two revealed colors differ.

Only the color-permutation and opened-color components are needed for the distributional theorem below. Commitment security is a separate cryptographic layer.

### 3.3. Completeness under color permutations

**Lemma 3.1 (Permutation preserves inequality).** If $a,b\in C$, $a\ne b$, and $\pi$ is a permutation of $C$, then $\pi(a)\ne\pi(b)$.

**Proof sketch.** A permutation is injective. If $\pi(a)=\pi(b)$, injectivity would imply $a=b$, a contradiction. $\square$

**Theorem 3.2 (Perfect completeness of permuted coloring).** Let $c$ be a proper three-coloring of $G$. For every permutation $\pi$ of $C$, the coloring $c_\pi(v)=\pi(c(v))$ is proper. Hence every challenged edge in the protocol reveals two different colors and is accepted.

**Proof sketch.** For any edge $(u,v)$, properness gives $c(u)\ne c(v)$. Lemma 3.1 gives $\pi(c(u))\ne\pi(c(v))$. This holds for every edge and every permutation, so acceptance has probability $1$. $\square$

### 3.4. Exact transcript simulation

Fix distinct colors $a,b\in C$. The real opened-color transcript is

$$
T_{a,b}=(\pi(a),\pi(b)),
$$

where $\pi$ is uniform over the six permutations of $C$. Define the set

$$
D=\{(x,y)\in C^2:x\ne y\}.
$$

There are $3\cdot 2=6$ elements of $D$. Define the simulator to sample a pair uniformly from $D$.

**Lemma 3.3 (Bijection between permutations and distinct ordered pairs).** For fixed $a\ne b$, the map

$$
\Phi_{a,b}:\operatorname{Sym}(C)\to D,
\qquad
\Phi_{a,b}(\pi)=(\pi(a),\pi(b))
$$

is a bijection.

**Proof sketch.** The image lies in $D$ by injectivity. Given any $(x,y)\in D$, there is exactly one permutation sending $a$ to $x$ and $b$ to $y$: the remaining source color must be sent to the remaining target color. Thus every pair has exactly one preimage. $\square$

**Theorem 3.4 (Perfect honest-verifier zero knowledge for a challenged edge).** For every pair of distinct actual endpoint colors $a,b$, the real transcript distribution of $(\pi(a),\pi(b))$ is exactly the witness-independent simulator distribution uniform on $D$.

Equivalently, for every $(x,y)\in C^2$,

$$
\Pr[(\pi(a),\pi(b))=(x,y)]
=
\begin{cases}
1/6,&x\ne y,\\
0,&x=y.
\end{cases}
$$

**Proof sketch.** Uniform measure is preserved by a bijection. Lemma 3.3 maps the six equiprobable permutations bijectively to the six distinct ordered pairs, so each pair in $D$ occurs with probability $1/6$. The resulting law does not depend on $a$ or $b$ beyond their being distinct, and is exactly the simulator law. $\square$

The theorem shows perfect, not approximate, distributional equality. It is honest-verifier zero knowledge because the challenge behavior and the view under study follow the specified protocol. Extending the statement to arbitrary verifier strategies generally requires simulation with rewinding or another extraction of the challenge distribution.

### 3.5. Local soundness and repetition

If an alleged coloring $c$ is improper, there exists an edge $(u,v)$ for which $c(u)=c(v)$. Every permutation preserves equality as well as inequality, so the prover cannot make this edge appear properly colored merely by renaming colors. If the verifier samples uniformly from a nonempty edge set, the rejection probability in one round is at least the fraction of monochromatic edges. If at least one edge is bad, this gives the elementary bound $1/|E|$. Repeating independent rounds decreases the probability of escaping detection.

This argument does not by itself establish a constant soundness gap. A graph with many edges may have an alleged coloring with only one bad edge. Section 5 identifies the exact local theorem available without gap amplification.

## 4. Polynomial Identity Testing for a Simplified QAP Verifier

### 4.1. Algebraic setting

Let $F$ be a finite field, and let $F[x]$ be its polynomial ring. Suppose $t\in F[x]$ is a target polynomial encoding a family of constraints, $p\in F[x]$ is a polynomial derived from a claimed computation, and $h\in F[x]$ is a claimed quotient. The intended identity is

$$
p=ht.
$$

A simplified verifier samples $s\in F$ and accepts if

$$
p(s)=h(s)t(s).
$$

Define the discrepancy polynomial

$$
q=p-ht.
$$

The verifier accepts precisely when $q(s)=0$.

### 4.2. The root bound

**Lemma 4.1 (Polynomial root bound).** If $q\in F[x]$ is nonzero, then the number of distinct roots of $q$ in $F$ is at most $\deg q$.

**Proof sketch.** Proceed by induction on the degree. A degree-zero nonzero polynomial has no roots. If $q(a)=0$, the factor theorem gives $q=(x-a)r$ with $\deg r=\deg q-1$. Every other root of $q$ is a root of $r$, so induction bounds the total by $1+\deg r=\deg q$. $\square$

### 4.3. Soundness

**Theorem 4.2 (Random-point soundness).** Let $p,h,t\in F[x]$ and suppose $p\ne ht$. Then

$$
\left|\{s\in F:p(s)=h(s)t(s)\}\right|
\le \deg(p-ht).
$$

**Proof sketch.** Since $p\ne ht$, the discrepancy $q=p-ht$ is nonzero. Passing points are exactly roots of $q$. Lemma 4.1 bounds their number by $\deg q$. $\square$

**Corollary 4.3 (Uniform false-acceptance bound).** If $s$ is sampled uniformly from $F$ and $p\ne ht$, then

$$
\Pr[p(s)=h(s)t(s)]
\le
\frac{\deg(p-ht)}{|F|}.
$$

When the degree exceeds $|F|$, the bound should of course be combined with the trivial probability bound $1$, giving $\min(1,\deg(q)/|F|)$.

### 4.4. Knowledge-soundness form

**Theorem 4.4 (Too many passing points force the identity).** If

$$
\deg(p-ht)
<
\left|\{s\in F:p(s)=h(s)t(s)\}\right|,
$$

then $p=ht$.

**Proof sketch.** Assume instead that $p\ne ht$. Theorem 4.2 would bound the number of passing points by $\deg(p-ht)$, contradicting the strict inequality. Therefore the discrepancy is zero and $p=ht$. $\square$

The term “knowledge-soundness form” here refers to the fact that sufficiently extensive successful evaluation behavior forces the claimed algebraic relation. A complete cryptographic knowledge argument would additionally specify an adversary model and an extractor for a witness.

### 4.5. Numerical example

Work over the prime field $F_{101}$. Let

$$
t(x)=x^2+1,
\qquad
h(x)=3x+2,
$$

and define a false claim

$$
p(x)=h(x)t(x)+x(x-1)(x-2).
$$

Then

$$
q(x)=p(x)-h(x)t(x)=x(x-1)(x-2).
$$

The degree is $3$, and the passing points are exactly $0$, $1$, and $2$. Thus the false identity passes at $3$ of the $101$ field points, meeting the root bound sharply. Its false-acceptance probability under a uniform challenge is $3/101$.

By contrast, if $p=ht$, then $q=0$ and every point passes, expressing perfect completeness of the identity test.

## 5. The Two-Query PCP Bridge

### 5.1. Proof oracle and local verifier

Represent an alleged graph coloring as an oracle string indexed by vertices:

$$
\Pi:V\to C.
$$

For an edge $e=(u,v)$, define the query set

$$
Q(e)=\{u,v\}.
$$

If $u=v$, this set has one element; otherwise it has two. The local verifier reads $\Pi(u)$ and $\Pi(v)$ and accepts when they differ.

**Theorem 5.1 (Two-query locality).** For every edge $e$,

$$
|Q(e)|\le 2.
$$

This bound is independent of $|V|$ and $|E|$.

**Proof sketch.** The query set is formed from the two endpoints of the edge. A set generated by two elements has cardinality at most two. $\square$

### 5.2. Soundness on non-three-colorable graphs

**Theorem 5.2 (Existence of a rejecting local query).** Suppose $G=(V,E)$ is not three-colorable. Then for every alleged proof oracle $\Pi:V\to C$, there exists an edge $(u,v)\in E$ such that

$$
\Pi(u)=\Pi(v),
$$

and hence the two-query verifier rejects on that edge.

**Proof sketch.** If every edge had differently colored endpoints under $\Pi$, then $\Pi$ would be a proper three-coloring of $G$, contradicting the assumption. Therefore some edge is monochromatic and rejects. $\square$

This theorem is the deterministic soundness core of the graph-coloring PCP connection. It establishes constant query size, but it does not assert that a constant fraction of edges reject. If the verifier samples edges uniformly, the guaranteed rejection probability is only at least $1/|E|$ from this theorem alone. Gap amplification is needed to obtain a fixed lower bound independent of graph size.

### 5.3. Relation to the broader PCP paradigm

The PCP paradigm replaces full reading of a proof with randomized local inspection. The graph oracle above already exhibits locality: a global assignment is tested through two symbols. A full constant-gap construction further encodes the proof so that every false statement is far from every accepting oracle, allowing a constant number of random queries to reject with constant probability. Thus the two-query graph test is best viewed as a transparent base layer rather than a complete derivation of the full PCP theorem.

## 6. Algorithms and Complexity

### 6.1. Exact transcript enumeration

For fixed distinct colors $a,b$, enumerate all six permutations of $C$. Count the ordered pairs $(\pi(a),\pi(b))$. The algorithm returns the exact probability mass function by dividing each count by $6$.

The running time is $O(|C|!\,|C|)$ if permutations are generated explicitly, and storage is $O(|C|^2)$. For three colors these are constants. The output confirms that each distinct ordered pair has mass $1/6$ and each equal pair has mass $0$.

### 6.2. Finite-field random-point audit

Given coefficient lists for $p,h,t$ over a prime field $F_r$, evaluate the polynomials at every $s\in F_r$ using Horner's method. Record the passing points satisfying $p(s)=h(s)t(s)$. If $d$ is the maximum relevant degree, exhaustive auditing costs $O(rd)$ field operations and $O(r)$ output space in the worst case. A deployed verifier samples one point instead, using $O(d)$ field operations and constant auxiliary space.

### 6.3. Local graph audit

Given an edge list and an alleged coloring, scan edges until finding a monochromatic one. Each edge causes two oracle reads and one comparison. The worst-case running time is $O(|E|)$, storage beyond the input is $O(1)$, and each individual test has query complexity at most two.

## 7. Applications

### 7.1. Confidential constraint satisfaction

Many scheduling, allocation, and routing problems can be represented as constraint systems. The graph protocol illustrates how a prover can expose only a randomized local relation rather than the underlying assignment. Practical systems need commitments whose hiding and binding properties match the adversarial model, but the combinatorial simulation theorem explains why random relabeling erases the semantic identity of colors.

### 7.2. Outsourced computation

Polynomial identity tests allow a verifier to replace a large symbolic comparison with one random evaluation. When computation is arithmetized, a discrepancy between the claimed and correct relations becomes a nonzero polynomial. The root bound then transforms algebraic degree into a concrete soundness error. Large finite fields and controlled degrees make false acceptance rare.

### 7.3. Private local verification

The local oracle viewpoint separates the number of proof symbols read from the total proof length. If the queried symbols can be opened through hiding commitments while unopened symbols remain hidden, local verification can be composed with privacy. The graph simulator suggests the needed condition: the distribution of opened coordinates must itself be reproducible without the witness.

## 8. Discussion and Limitations

Three forms of compression recur throughout the paper.

1. **Symmetry compression:** random color permutations remove witness-specific labels while preserving inequality.
2. **Algebraic compression:** one evaluation summarizes a polynomial identity, with degree controlling ambiguity.
3. **Locality compression:** one edge query reduces a global coloring claim to two symbols.

Each compression is protected by a rigidity principle. Injectivity of permutations protects properness. The root bound protects polynomial identity testing. The definition of proper coloring ensures that a globally false assignment has a local defect.

The results should not be overextended. Perfect honest-verifier simulation does not automatically imply security against arbitrary malicious verifier strategies. The polynomial check does not itself provide witness hiding, succinct commitments, or extraction. The local graph theorem does not establish constant rejection probability. These are not defects in the stated results; they mark interfaces where additional constructions are required.

The non-interactive definition also highlights a useful design rule: support correctness must accompany simulation. Privacy says the proof distribution can be generated without the witness; correctness says the honest distribution never emits a rejected proof. Neither condition entails the other.

## 9. Future Work

Several natural extensions follow from the established interfaces.

First, malicious-verifier security for the graph protocol calls for a polynomial-time rewinding simulator and an explicit analysis of challenge probabilities. Second, the polynomial identity test can be made non-interactive through a hash-derived challenge, but its security then requires a random-oracle analysis with an explicit query loss. Third, adding random multiples of the target polynomial offers a route to QAP witness hiding through polynomial blinding. Fourth, gap amplification can strengthen existence of one rejecting edge into a graph-size-independent rejection probability. Finally, committed local oracles can combine PCP locality with hiding of unopened coordinates and simulation of opened coordinates.

## 10. Conclusion

Perfect simulation, random-point soundness, and constant-query verification are three facets of a common methodology. A verifier observes only a small projection of a large witness. Correctness follows because invalid global objects cannot make every such projection consistent: a bad coloring has a bad edge, and a false polynomial identity has only a bounded number of passing points. Privacy follows when the permitted projection has a distribution reproducible from public information alone.

For graph three-coloring, uniform relabeling produces an exact witness-independent transcript distribution and preserves properness under every permutation. For simplified QAP verification, the discrepancy polynomial turns false acceptance into root counting. For local graph verification, every test reads at most two symbols, and false instances force at least one rejecting query. Together these results provide a precise mathematical foundation for verifiable computation in which local evidence can certify global structure without unnecessarily revealing the witness.