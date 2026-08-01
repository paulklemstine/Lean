# Finite-Perturbation Invariance and a Parity Obstruction for Strongly Complete Sets

**Aristotle**  
**August 1, 2026**

## Abstract

A set of nonnegative integers is complete if every sufficiently large integer is a sum of distinct elements of the set, and strongly complete if this remains true after every finite deletion. We develop the elementary structure of strong completeness and isolate the precise role of finite perturbations. Strong completeness implies completeness, is inherited after finite deletion, cannot be created by finite addition, and is invariant under finite symmetric difference. We then disprove the tempting converse from completeness to strong completeness. The set consisting of all even nonnegative integers together with $1$ represents every nonnegative integer as a sum of distinct elements, but deletion of $1$ leaves only even summands and therefore excludes every odd target. This example identifies a modular single point of failure and shows why robust completeness requires distributional information beyond ordinary representability. We also present finite algorithms for enumerating subset sums and detecting deletion-induced residue obstructions, and we discuss how these foundational results motivate ordered-block, dyadic-density, and analytic divergence criteria.

## 1. Introduction

Subset-sum completeness is an asymptotic covering property. Given a set $A\subseteq\mathbb N$, one asks whether every sufficiently large natural number can be expressed as a finite sum of pairwise distinct elements of $A$. The distinctness condition prevents unlimited reuse of a small generating collection and forces the large-scale structure of $A$ to carry the representation problem.

A stronger notion asks for fault tolerance. If finitely many elements of $A$ are removed, does the surviving set retain the same asymptotic covering property? A positive answer for every finite deletion defines strong completeness. The difference between the two notions is subtle enough to invite a false intuition: because ordinary completeness concerns only sufficiently large targets, one might expect the loss of finitely many fixed summands merely to shift the threshold. That intuition overlooks the possibility that a finite exceptional set carries an entire congruence class of representations.

The main example of this paper is

$$
E=2\mathbb N\cup\{1\},
$$

where $2\mathbb N$ denotes the even nonnegative integers. Every even target belongs to $E$, and every odd target at least $3$ is $1$ plus an even element. Thus $E$ is not merely complete: it represents every natural number. Nevertheless, removing $1$ leaves only even summands. No odd number can then be represented, so the remainder is not complete. Ordinary completeness can therefore be supported by a single indispensable element.

Against this negative result, strong completeness has a powerful positive stability property. If two sets differ in only finitely many places, either both are strongly complete or neither is. This finite-perturbation invariance shows that strong completeness is genuinely a tail property. Finitely many elements may create ordinary completeness, as the example $2\mathbb N\cup\{1\}$ demonstrates, but they cannot create strong completeness.

The paper is organized as follows. Section 2 gives the definitions and elementary monotonicity principle. Section 3 proves closure under finite deletion and reflection under finite addition. Section 4 establishes invariance under finite symmetric difference. Section 5 develops the counterexample and its parity obstruction. Section 6 gives algorithms for finite experiments. Section 7 places the results in the context of scale density and distributional hypotheses. Sections 8 and 9 discuss applications, limitations, and future directions.

## 2. Definitions and preliminary principles

Throughout, $\mathbb N=\{0,1,2,\ldots\}$. All sums are finite unless explicitly stated otherwise.

### Definition 2.1 (Distinct subset-sum representation)

Let $A\subseteq\mathbb N$ and $n\in\mathbb N$. We say that $n$ is a **distinct subset sum from $A$** if there exists a finite set $S\subseteq A$ such that

$$
\sum_{a\in S}a=n.
$$

The use of a finite set $S$ enforces distinctness: each element of $A$ occurs at most once.

### Definition 2.2 (Completeness)

A set $A\subseteq\mathbb N$ is **complete** if there exists $N\in\mathbb N$ such that every $n\ge N$ is a distinct subset sum from $A$.

The integer $N$ is a completeness threshold. No condition is imposed below it.

### Definition 2.3 (Strong completeness)

A set $A\subseteq\mathbb N$ is **strongly complete** if, for every finite set $F\subseteq\mathbb N$, the difference $A\setminus F$ is complete.

The completeness threshold may depend on $F$. Thus the definition asserts recovery after each finite failure, not one threshold uniform over all failures.

The first implication follows by taking the finite deletion to be empty.

### Proposition 2.4 (Strong completeness implies completeness)

Every strongly complete set is complete.

**Proof sketch.** Apply the definition of strong completeness with $F=\varnothing$. Since $A\setminus\varnothing=A$, completeness of the remainder is exactly completeness of $A$. $\square$

We repeatedly use a monotonicity principle.

### Lemma 2.5 (Upward monotonicity of completeness)

If $C\subseteq D\subseteq\mathbb N$ and $C$ is complete, then $D$ is complete.

**Proof sketch.** Let $N$ be a completeness threshold for $C$. For every $n\ge N$, choose a finite set $S\subseteq C$ summing to $n$. Since $C\subseteq D$, the same set $S$ is a valid representation from $D$. $\square$

This lemma contains no delicate additive argument. It records that adding available summands never invalidates an existing representation.

## 3. Finite deletions and finite additions

Strong completeness is designed to absorb finite deletion. The first structural theorem makes the closure property explicit.

### Theorem 3.1 (Closure under finite deletion)

Let $A\subseteq\mathbb N$ be strongly complete, and let $F\subseteq\mathbb N$ be finite. Then $A\setminus F$ is strongly complete.

**Proof sketch.** Let $G$ be any finite set to be deleted from $A\setminus F$. Set difference satisfies

$$
(A\setminus F)\setminus G=A\setminus(F\cup G).
$$

The union $F\cup G$ is finite. Strong completeness of $A$ therefore implies completeness of the right-hand side, which is precisely what is required for strong completeness of $A\setminus F$. $\square$

The reverse-looking statement for finite additions is equally important. A finite set can improve ordinary representability, but it cannot be the source of strong completeness.

### Theorem 3.2 (Finite addition cannot create strong completeness)

Let $A,F\subseteq\mathbb N$, with $F$ finite. If $A\cup F$ is strongly complete, then $A$ is strongly complete.

**Proof sketch.** Fix an arbitrary finite deletion $G$. Strong completeness of $A\cup F$ allows deletion of the finite set $G\cup F$, giving completeness of

$$
(A\cup F)\setminus(G\cup F).
$$

Every element of this set belongs to $A$ and avoids $G$, so

$$
(A\cup F)\setminus(G\cup F)\subseteq A\setminus G.
$$

By upward monotonicity, $A\setminus G$ is complete. Since $G$ was arbitrary, $A$ is strongly complete. $\square$

A related monotonicity statement follows directly and is useful conceptually.

### Proposition 3.3 (Upward monotonicity of strong completeness)

If $A\subseteq B\subseteq\mathbb N$ and $A$ is strongly complete, then $B$ is strongly complete.

**Proof sketch.** For every finite $F$, one has $A\setminus F\subseteq B\setminus F$. The former is complete by strong completeness of $A$, so the latter is complete by Lemma 2.5. $\square$

Theorems 3.1 and 3.2 distinguish robust structure from a finite repair. If adding finitely many terms turns an incomplete set into a complete one, the new completeness may depend on those terms. If the enlarged set is strongly complete, however, its robustness must already have been present in the original infinite set.

## 4. Invariance under finite symmetric difference

The natural equivalence relation for tail properties is equality up to finitely many elements.

### Definition 4.1 (Symmetric difference)

For sets $A,B\subseteq\mathbb N$, their **symmetric difference** is

$$
A\mathbin{\triangle}B=(A\setminus B)\cup(B\setminus A).
$$

It consists exactly of the elements on which membership in $A$ and $B$ disagrees.

### Theorem 4.2 (Finite-perturbation invariance)

Suppose $A,B\subseteq\mathbb N$ and $A\mathbin{\triangle}B$ is finite. Then $A$ is strongly complete if and only if $B$ is strongly complete.

**Proof sketch.** Assume first that $A$ is strongly complete. Because the symmetric difference is finite, the set $A\setminus B$ is finite. Let $G$ be any finite set. Delete from $A$ the finite union

$$
G\cup(A\setminus B).
$$

Strong completeness of $A$ shows that

$$
A\setminus\bigl(G\cup(A\setminus B)\bigr)
$$

is complete. A membership check identifies this set with

$$
(A\cap B)\setminus G.
$$

Indeed, an element survives precisely when it belongs to $A$, belongs to $B$, and is not in $G$. The common remainder satisfies

$$
(A\cap B)\setminus G\subseteq B\setminus G.
$$

Lemma 2.5 therefore implies that $B\setminus G$ is complete. Since $G$ was arbitrary, $B$ is strongly complete.

For the converse, interchange $A$ and $B$. The set $B\setminus A$ is finite, and the same common-core argument proves strong completeness of $A$ from strong completeness of $B$. $\square$

The proof reveals more than the statement. The key object is the common core $A\cap B$. To compare deletion robustness, one deletes from the first set all finitely many points not shared with the second. Completeness of the resulting core then propagates upward.

### Corollary 4.3 (Finite additions and deletions preserve the classification)

If $F$ is finite, then the following are equivalent:

1. $A$ is strongly complete;
2. $A\cup F$ is strongly complete;
3. $A\setminus F$ is strongly complete.

**Proof sketch.** Each pair of sets differs by at most the finite set $F$, so Theorem 4.2 applies. $\square$

This is the precise sense in which strong completeness is a tail invariant. Any finite modification leaves its truth value unchanged.

## 5. A complete set that is not strongly complete

We now show that ordinary completeness lacks this robustness.

### Definition 5.1 (The parity example)

Let

$$
E=2\mathbb N\cup\{1\}
 =\{n\in\mathbb N:n\text{ is even}\}\cup\{1\}.
$$

### Theorem 5.2 (Completeness of the parity example)

The set $E$ is complete. In fact, every $n\in\mathbb N$ is a distinct subset sum from $E$.

**Proof sketch.** If $n$ is even, then $n\in E$ and the singleton set $\{n\}$ has sum $n$. If $n$ is odd and $n\ge3$, then $n-1$ is even and

$$
n=1+(n-1).
$$

The summands are distinct: equality $1=n-1$ would force $n=2$, contradicting oddness. Both belong to $E$. Finally, $1$ is represented by $\{1\}$, while $0$ is represented by the empty set or $\{0\}$. Thus the threshold may be chosen as $N=0$. $\square$

### Lemma 5.3 (Parity closure of finite sums)

A finite sum of even natural numbers is even.

**Proof sketch.** The empty sum is $0$, hence even. Adding one even term to an even partial sum preserves evenness. Induction on the number of summands proves the claim. $\square$

### Theorem 5.4 (Completeness does not imply strong completeness)

The set $E$ is complete but not strongly complete.

**Proof sketch.** Completeness is Theorem 5.2. Delete the finite set $\{1\}$. Every element of $E\setminus\{1\}$ is even, so Lemma 5.3 shows that every distinct subset sum from the remainder is even. For any proposed completeness threshold $N$, the number

$$
m=2N+1
$$

is odd and satisfies $m\ge N$. It therefore cannot be represented from $E\setminus\{1\}$. The remainder is not complete, and $E$ is not strongly complete. $\square$

The theorem is sharp at the conceptual level: even universal representation before deletion does not imply eventual representation after deletion. The issue is not a sparse set or a high threshold. The issue is structural concentration. One element, $1$, supplies all access to odd parity.

### Remark 5.5 (A modular template)

Parity is the case $m=2$ of a broader obstruction. Suppose that after deleting a finite set, all remaining elements lie in a subgroup of the additive group $\mathbb Z/m\mathbb Z$. Every subset sum then lies in the same subgroup, excluding every target in the other residue classes. Since each excluded residue class contains arbitrarily large integers, the remainder cannot be complete.

This observation provides a strategy for constructing further counterexamples: arrange ordinary completeness using finitely many exceptional residue carriers, then remove them to expose a modular obstruction.

## 6. Computational demonstrations

The infinite statements above have short proofs, but finite computation is valuable for exploration and illustration. Two algorithms are particularly useful.

### 6.1 Bounded distinct subset-sum enumeration

Given a finite collection $V$ of nonnegative integers and a target bound $T$, compute all sums at most $T$ obtainable from distinct elements of $V$.

Initialize the reachable set as $R=\{0\}$. For each value $a\in V$, update

$$
R\leftarrow R\cup\{r+a:r\in R,\ r+a\le T\}.
$$

The update must use the pre-update version of $R$ so that $a$ is not reused. A Boolean-array implementation takes $O(|V|T)$ time and $O(T)$ space. A set implementation is often convenient for demonstrations.

For a truncation

$$
E_M=\{0,2,4,\ldots,M\}\cup\{1\},
$$

the reachable sums fill a substantial initial interval. After replacing $E_M$ by $E_M\setminus\{1\}$, every reachable sum is even. The finite pattern exactly reflects the invariant used in Theorem 5.4.

### 6.2 Finite deletion stress testing

Given $V$, $T$, and a family of candidate deletion sets, recompute bounded subset sums after each deletion. Report targets that were reachable before deletion but not afterward, and classify the missing targets by residue modulo small moduli.

For a fixed deletion budget $d$, exhaustive testing of all deletions of size at most $d$ requires

$$
\sum_{j=0}^{d}\binom{|V|}{j}
$$

subset-sum computations. The procedure is exponential when $d$ grows with $|V|$, but practical for small fixed $d$. It does not prove strong completeness of an infinite set; rather, it discovers candidate obstructions and indispensable elements.

Applied to $E_M$, deletion of $1$ produces missing residues $1$ modulo $2$. This is stronger evidence than an irregular list of gaps because residue exclusion suggests an invariant extending to all scales.

### 6.3 Direct representation formulas

For the infinite example, enumeration is unnecessary. A direct constructor returns

$$
S(n)=
\begin{cases}
\{n\}, & n\text{ even},\\
\{1\}, & n=1,\\
\{1,n-1\}, & n\ge3\text{ odd}.
\end{cases}
$$

Each output consists of distinct elements of $E$ and sums to $n$. This is an $O(1)$ arithmetic description, apart from the storage needed for at most two integers. It demonstrates that the positive completeness claim is fully constructive, while the negative strong-completeness claim follows from a parity invariant.

## 7. Toward stronger sufficient criteria

The counterexample explains why ordinary completeness is insufficient, but it also points toward hypotheses that may enforce robustness.

### 7.1 Density across scales

For $k\in\mathbb N$, define the dyadic block of $A$ at scale $k$ by

$$
D_k(A)=A\cap(2^k,2^{k+1}].
$$

A lower bound on $|D_k(A)|$ for all sufficiently large $k$ guarantees recurring supply. Unlike a global counting estimate, a block condition prevents all useful summands from being concentrated below a fixed scale or separated by uncontrolled deserts.

The parity example itself has many elements in each large dyadic block, so scale density alone does not explain every aspect of robustness. This highlights the need for a second ingredient controlling arithmetic distribution.

### 7.2 Distance to the nearest integer

For $x\in\mathbb R$, write

$$
\|x\|=\min_{z\in\mathbb Z}|x-z|
$$

for the distance from $x$ to the nearest integer. Conditions involving

$$
\sum_{a\in A}\|a\theta\|
$$

for nonintegral real $\theta$ measure how persistently the dilates $a\theta$ avoid exact integral alignment. Divergence for every $\theta\notin\mathbb Z$ rules out certain forms of arithmetic concentration.

The foundational results proved here do not establish a theorem from a dyadic block bound and such a divergence condition. They instead identify the logical role those assumptions must play. The block hypothesis supplies summands at successive magnitudes, while the analytic hypothesis is designed to prevent hidden modular or near-modular collapse. Any robust criterion must overcome examples in which finitely many exceptional elements carry essential arithmetic information.

### 7.3 Ordered blocks

A more flexible framework replaces dyadic intervals by finite ordered blocks $B_0,B_1,\ldots$ satisfying

$$
\max B_k<\min B_{k+1}.
$$

One may impose lower bounds on $|A\cap B_k|$ and hypotheses ensuring that attainable subset-sum intervals from successive blocks overlap. If a block extends an already covered interval by more than the next possible gap, induction can propagate coverage to arbitrarily large targets.

Such a theorem would separate three components:

1. local combinatorial richness within each block;
2. geometric ordering of the blocks;
3. overlap or gap control for accumulated subset sums.

Strong completeness would then require these properties to survive finite deletion, which is plausible when the conditions hold eventually and with sufficient slack.

## 8. Applications and interpretation

### 8.1 Fault tolerance in additive bases

Completeness is an availability statement: every large demand can be assembled. Strong completeness is a reliability statement: availability persists after finitely many component failures. The parity example shows that high availability can coexist with a catastrophic single point of failure.

This language is useful beyond number theory. In resource allocation, denominations or packet sizes may combine without repetition. In coding-inspired constructions, available weights generate message totals. In each setting, a finite exceptional set may carry an entire class of outputs. Strong completeness captures redundancy of function rather than mere abundance of components.

### 8.2 Tail classification

Finite-perturbation invariance allows sets to be grouped into equivalence classes under finite symmetric difference. Strong completeness is constant on each class. Consequently, one may discard finitely many awkward initial values, normalize a construction, or add finitely many convenient terms without changing the robust classification.

Ordinary completeness does not share this invariance. The sets $2\mathbb N$ and $2\mathbb N\cup\{1\}$ differ by one element, yet the first misses every odd number and the second represents every number. This contrast sharply separates an asymptotic statement about targets from a tail-invariant statement about generators.

### 8.3 Counterexample design

The example suggests a general three-step method.

First, choose a large structured core whose subset sums remain trapped in selected residue classes. Second, add finitely many exceptional elements that bridge the missing classes and produce ordinary completeness. Third, delete the bridge elements to recover the obstruction.

The method warns against conjectures asserting that completeness plus a weak infinitude condition implies strong completeness. Infinitely many odd elements may defeat the simplest parity example, but analogous concentration could occur modulo larger integers or through more delicate additive constraints.

## 9. Discussion and future work

The results establish the elementary logic of robustness but not a full analytic criterion. Several next steps are natural.

First, an ordered-block theorem should be developed before specializing to dyadic blocks. The desired hypotheses should specify finite pairwise ordered blocks, lower cardinality bounds, and enough overlap among attainable subset-sum intervals to force eventual coverage after finite deletion.

Second, the dyadic condition should be treated as a specialization. With

$$
D_k(A)=A\cap(2^k,2^{k+1}],
$$

an eventual lower bound on $|D_k(A)|$ can be checked against the abstract block hypotheses.

Third, the analytic divergence condition should be formulated carefully. Because the sum is indexed by a set, one needs an order-independent notion of a nonnegative infinite sum. The central property is divergence of $\sum_{a\in A}\|a\theta\|$ for every nonintegral $\theta$.

Fourth, a useful tail characterization should compare arbitrary finite deletion with deletion of finite initial segments. If every finite set $F$ is contained in $\{0,1,\ldots,M\}$, then deleting the whole initial segment leaves a subset of $A\setminus F$. Upward monotonicity suggests that strong completeness is equivalent to completeness after every finite initial-segment deletion. This reduces arbitrary adversarial deletions to a canonical family.

Finally, several contrarian tests deserve investigation:

1. Does completeness together with infinitely many odd elements imply strong completeness?
2. If every residue class modulo every $m\ge2$ contains infinitely many elements of $A$, does completeness imply strong completeness?
3. Can a fixed dyadic block requirement be weakened when the analytic distribution hypothesis is strengthened quantitatively?

The first statement is doubtful because parity is only one possible finite-deletion obstruction. The second eliminates obvious residue scarcity but may still permit interactions between scale and congruence. Computational searches over structured finite models may help locate plausible counterexamples before attempting general proofs.

## 10. Conclusion

Strong completeness is not a cosmetic strengthening of completeness. It measures whether distinct subset-sum coverage is distributed throughout an infinite set rather than routed through finitely many exceptional summands.

The set $2\mathbb N\cup\{1\}$ gives the decisive elementary example. It represents every nonnegative integer, yet the deletion of $1$ eliminates all odd subset sums. Therefore completeness does not imply strong completeness.

At the same time, strong completeness has exact finite-perturbation stability. It survives finite deletion, cannot be manufactured by finite addition, and is invariant whenever two sets differ at only finitely many elements. These facts establish strong completeness as a genuine tail property and provide the correct structural foundation for more powerful criteria involving ordered blocks, dyadic scale density, and analytic distribution.
