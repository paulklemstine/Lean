# Universal Cores, Independent Geometries, and Operation-Relative Primality

**Aristotle**  
**July 22, 2026**

## Abstract

Would mathematically capable non-human intelligences discover the same mathematics? This question becomes tractable after separating invariance under extension, invariance across models, invariance under structural recoding, and dependence on the choice of operation. We develop a general theory of universal consequences using a Tarskian closure operator. For a consistent base theory, the intersection of the consequence sets of all consistent extensions is exactly the consequence set of the base itself. In a semantic setting, extension-universality over a consistent theory is equivalent to ordinary semantic consequence; hence the assertion that one orientation of a sentence is universal is exactly a semantic decision assertion. A two-model criterion then yields nonuniversality in both directions. We illustrate it with two finite incidence geometries, one satisfying and one refuting Playfair’s parallel postulate. Turning to arithmetic, we show that prime elements are invariant under multiplicative equivalence, so every multiplicative recoding of the natural numbers contains images of arbitrarily large ordinary primes. In contrast, when tropical multiplication on natural numbers is ordinary addition, the unique nonzero irreducible is $1$. These results distinguish truths forced by a chosen base, truths preserved by structural translation, and truths altered by changing the primitive operations.

## 1. Introduction

Discussions of “universal mathematics” often move too quickly between several distinct claims. One claim says that a theorem remains true when more axioms are added. Another says that every admissible mathematical world satisfies a sentence. A third says that a property survives translation between equivalent structures. A fourth says that an apparently familiar concept, such as primality, should persist even when the governing operation changes. These assertions require different definitions and have different truth conditions.

The present paper offers a compact framework for distinguishing them. Its central objects are consequence operations, semantic theories, finite incidence geometries, multiplicative equivalences, and tropical addition. The guiding question is not psychological—what symbols another intelligence would prefer—but structural: what mathematical facts are forced once particular assumptions and operations have been fixed?

Four conclusions organize the discussion.

First, let $C$ be a consequence operation and $B$ a consistent base theory. If the universal core over $B$ is defined as the set of statements belonging to the closure of every consistent extension of $B$, then that core is exactly $C(B)$. Thus “universal over a base” introduces no hidden stock of additional truths.

Second, in model-theoretic semantics, a sentence is extension-universal over a consistent base precisely when it is already a semantic consequence of that base. Consequently, the assertion that either a sentence or its negation is extension-universal is a decision assertion, not a consequence of consistency alone.

Third, model variation can refute universality. Two finite incidence worlds suffice to make Playfair’s postulate true in one and false in the other. This proves nonuniversality over an empty geometric base, while carefully avoiding the stronger claim that these small worlds satisfy the axioms of neutral geometry.

Fourth, arithmetic depends on what a translation preserves. Multiplicative equivalences preserve prime elements, and therefore preserve the unbounded supply of natural primes. Tropicalizing multiplication changes the operation rather than merely its representation: under $a\odot b=a+b$, only $1$ is irreducible.

Together these results supply a precise vocabulary for comparing human and non-human mathematics.

## 2. Consequence Operations and Universal Cores

### 2.1 Tarskian consequence

Let $S$ be a set of statements. A *theory* is a subset $\Gamma\subseteq S$. A *Tarskian consequence operation* is a function

$$
C:\mathcal P(S)\longrightarrow\mathcal P(S)
$$

satisfying the following conditions for all theories $\Gamma,\Delta\subseteq S$:

1. **Extensivity:** $\Gamma\subseteq C(\Gamma)$.
2. **Monotonicity:** if $\Gamma\subseteq\Delta$, then $C(\Gamma)\subseteq C(\Delta)$.
3. **Idempotence:** $C(C(\Gamma))=C(\Gamma)$.

The members of $C(\Gamma)$ are the consequences of $\Gamma$. This abstract formulation does not commit to a particular syntax, deductive calculus, or mathematical subject.

We call $\Gamma$ *consistent* when

$$
C(\Gamma)\neq S.
$$

This is an abstract nontriviality notion: an inconsistent theory entails every statement.

For a base theory $B$, define the *universal core over $B$* by

$$
U_C(B)=\{\varphi\in S: \text{for every }\Delta\supseteq B,
\ C(\Delta)\neq S\text{ implies }\varphi\in C(\Delta)\}.
$$

Thus $U_C(B)$ intersects the consequence sets of all consistent extensions of $B$.

### 2.2 Persistence under extension

**Theorem 2.1 (Persistence of consequences).** If $B\subseteq\Delta$, then

$$
C(B)\subseteq C(\Delta).
$$

**Proof sketch.** This is precisely monotonicity. Every derivation available from $B$ remains available when the assumptions in $\Delta\setminus B$ are added. $\square$

**Corollary 2.2 (Base consequences are universal).** For every base $B$,

$$
C(B)\subseteq U_C(B).
$$

**Proof sketch.** Let $\varphi\in C(B)$ and let $\Delta$ be any consistent extension of $B$. Theorem 2.1 gives $\varphi\in C(\Delta)$. $\square$

The converse needs consistency of the base because the definition quantifies only over consistent extensions.

**Theorem 2.3 (Universal Core Theorem).** If $B$ is consistent, then

$$
U_C(B)=C(B).
$$

**Proof sketch.** Corollary 2.2 gives $C(B)\subseteq U_C(B)$. For the reverse inclusion, observe that $B$ itself is a consistent extension of $B$. Hence every statement in $U_C(B)$ must lie in $C(B)$. $\square$

This theorem gives the exact content of base-relative universality. If Peano arithmetic is selected as the base, each of its theorems survives in every consistent extension containing its axioms. The abstract theorem does not claim that all possible intelligences must select that base, nor that all mathematical truths are decided by it.

**Theorem 2.4 (Downward preservation of consistency).** If $B\subseteq\Delta$ and $\Delta$ is consistent, then $B$ is consistent.

**Proof sketch.** Suppose instead that $C(B)=S$. By monotonicity, $S=C(B)\subseteq C(\Delta)$, so $C(\Delta)=S$, contradicting consistency of $\Delta$. $\square$

## 3. Semantic Universality and Independence

### 3.1 Worlds, models, and entailment

Let $W$ be a class of mathematical worlds. A *sentence* is a property $\varphi:W\to\{\text{true},\text{false}\}$. A semantic theory $T$ is a set of sentences. A world $w$ is a *model* of $T$, written $w\models T$, when every sentence in $T$ is true at $w$:

$$
w\models T\quad\Longleftrightarrow\quad
\forall\psi\in T,\ \psi(w).
$$

A theory is *semantically consistent* when it has a model. The theory $T$ *entails* $\varphi$, written $T\models\varphi$, when every model of $T$ satisfies $\varphi$:

$$
T\models\varphi\quad\Longleftrightarrow\quad
\forall w,\ w\models T\Rightarrow\varphi(w).
$$

We call $\varphi$ *extension-universal over $T$* when every semantically consistent extension $V\supseteq T$ entails $\varphi$.

### 3.2 Countermodels and two-sided independence

**Theorem 3.1 (Countermodel Principle).** Suppose $w\models T$ and $\varphi(w)$ is false. Then $\varphi$ is not extension-universal over $T$.

**Proof sketch.** Form the extension

$$
V=T\cup\{\neg\varphi\}.
$$

The world $w$ models $V$, so $V$ is consistent. But $V$ does not entail $\varphi$, since $w$ is a model in which $\varphi$ fails. $\square$

**Theorem 3.2 (Two-Model Independence Principle).** Suppose $w_+$ and $w_-$ are models of $T$ such that $\varphi(w_+)$ is true and $\varphi(w_-)$ is false. Then neither $\varphi$ nor $\neg\varphi$ is extension-universal over $T$.

**Proof sketch.** Apply Theorem 3.1 to $w_-$ and $\varphi$. Apply it again to $w_+$ and $\neg\varphi$. $\square$

### 3.3 Extension-universality is entailment

**Theorem 3.3 (Extension-Universality Equivalence).** If $T$ is semantically consistent, then

$$
\varphi\text{ is extension-universal over }T
\quad\Longleftrightarrow\quad T\models\varphi.
$$

**Proof sketch.** If $\varphi$ is extension-universal, use the consistent extension $T$ itself to conclude $T\models\varphi$. Conversely, suppose $T\models\varphi$ and $V\supseteq T$. Every model of $V$ satisfies all sentences of $T$, hence satisfies $\varphi$. Therefore $V\models\varphi$. $\square$

**Corollary 3.4 (Decision Equivalence).** If $T$ is semantically consistent, then

$$
\begin{aligned}
&\bigl(\varphi\text{ is extension-universal over }T\bigr)
\ \lor\ 
\bigl(\neg\varphi\text{ is extension-universal over }T\bigr)\\
&\qquad\Longleftrightarrow
(T\models\varphi)\ \lor\ (T\models\neg\varphi).
\end{aligned}
$$

**Proof sketch.** Apply Theorem 3.3 separately to $\varphi$ and $\neg\varphi$. $\square$

This corollary identifies the logical burden of an assertion that a sufficiently rich arithmetic base must settle the Riemann Hypothesis. If $\mathrm{RH}$ denotes a sentence expressing that hypothesis, then the claim that either $\mathrm{RH}$ or $\neg\mathrm{RH}$ is extension-universal over $T$ is exactly the claim that $T$ semantically decides $\mathrm{RH}$. Consistency alone does not establish either disjunct.

## 4. A Finite Incidence Experiment

### 4.1 Two worlds

We construct two finite geometries. In each world the point set and line set are both

$$
\{0,1,2\}.
$$

In the *affine witness*, incidence is defined by

$$
p\mathrel{I_A}\ell\quad\Longleftrightarrow\quad p=\ell.
$$

Each line contains only its correspondingly numbered point.

In the *intersecting witness*, incidence is defined by

$$
p\mathrel{I_I}\ell\quad\Longleftrightarrow\quad p=0\text{ or }p=\ell.
$$

Thus every line contains point $0$, and line $\ell$ also contains point $\ell$.

In either world, lines $\ell$ and $m$ are *parallel* if no point is incident with both:

$$
\ell\parallel m\quad\Longleftrightarrow\quad
\forall p,\ \neg(pI\ell\land pIm).
$$

Playfair’s postulate states:

> For every line $\ell$ and every point $p$ not incident with $\ell$, there exists exactly one line $m$ such that $p$ is incident with $m$ and $m\parallel\ell$.

### 4.2 Verification in the affine witness

**Theorem 4.1 (Affine witness satisfies Playfair).** Playfair’s postulate holds in the affine witness.

**Proof sketch.** Let $p$ be external to $\ell$. Since incidence is equality, $p\neq\ell$. The line $m=p$ contains $p$. The only point on $m$ is $p$, and the only point on $\ell$ is $\ell$, so the two lines have no common incident point and are parallel. If another line $m'$ contains $p$, incidence forces $m'=p=m$, establishing uniqueness. $\square$

### 4.3 Refutation in the intersecting witness

**Theorem 4.2 (Intersecting witness refutes Playfair).** Playfair’s postulate fails in the intersecting witness.

**Proof sketch.** Every line contains point $0$. Hence every pair of lines has a common incident point, and no two lines are parallel. There are external point-line pairs—for example, point $1$ is not on line $2$—but no parallel through such a point. $\square$

**Theorem 4.3 (Finite Parallel Independence).** Relative to the empty background theory of these incidence worlds, neither Playfair’s postulate nor its negation is extension-universal.

**Proof sketch.** The affine witness is a model of the empty theory satisfying Playfair’s postulate, while the intersecting witness is a model of the empty theory refuting it. Apply the Two-Model Independence Principle. $\square$

The theorem is intentionally scoped. The witnesses demonstrate independence over an empty base. They do not purport to satisfy a shared neutral-geometry axiom set, and so they should not be confused with full Euclidean and hyperbolic models. Their role is algorithmic and conceptual: finite incidence tables make the two-model argument completely explicit.

## 5. Structural Invariance of Prime Elements

### 5.1 Multiplicative equivalence

Let $M$ and $N$ be commutative monoids with zero. Each has an associative and commutative multiplication, an identity $1$, and an absorbing element $0$. A *multiplicative equivalence* is a bijection $e:M\to N$ satisfying

$$
e(xy)=e(x)e(y),\qquad e(1)=1,
$$

and respecting the zero structure. Its inverse has the same multiplicative compatibility.

An element $x$ is *prime* when it is nonzero, is not a unit, and satisfies the divisibility condition

$$
x\mid ab\quad\Longrightarrow\quad x\mid a\text{ or }x\mid b.
$$

**Theorem 5.1 (Prime Invariance).** If $e:M\to N$ is a multiplicative equivalence, then for every $x\in M$,

$$
e(x)\text{ is prime in }N
\quad\Longleftrightarrow\quad
x\text{ is prime in }M.
$$

**Proof sketch.** A multiplicative equivalence preserves and reflects zero, units, products, and divisibility. In particular, $x\mid y$ exactly when $e(x)\mid e(y)$. Transporting the defining divisibility implication for primality across $e$ proves both directions. $\square$

This theorem isolates what an “alien encoding” must preserve. A cosmetic renaming may be arbitrary, but a structural encoding has obligations: multiplication and its distinguished elements must correspond. Once they do, primality cannot disappear.

### 5.2 Unbounded primes under recoding

The ordinary natural numbers contain primes above every bound.

**Theorem 5.2 (Unbounded Alien Primes).** Let $e$ be any multiplicative equivalence from the natural numbers to themselves. For every natural-number bound $B$, there exists a natural number $p$ such that

$$
p>B,
$$

$p$ is an ordinary prime, and $e(p)$ is prime in the encoded multiplication.

**Proof sketch.** By the infinitude of primes, choose a prime $p>B$. The Prime Invariance Theorem implies that $e(p)$ is prime. $\square$

The numerical order bound applies to the original $p$; a purely multiplicative equivalence need not preserve order. The conclusion is therefore carefully phrased in terms of images of arbitrarily large source primes.

## 6. Tropical Irreducibility

### 6.1 Changing the operation

Structural recoding and operational replacement must not be confused. In min-plus tropical arithmetic, tropical multiplication is ordinary addition:

$$
a\odot b=a+b.
$$

Accordingly, the tropical multiplicative identity is ordinary $0$. For natural numbers, define $n$ to be *tropically irreducible* when

$$
n\neq0
$$

and every factorization $n=a\odot b$, equivalently every ordinary sum $n=a+b$, has a tropical unit factor:

$$
n=a+b\quad\Longrightarrow\quad a=0\text{ or }b=0.
$$

### 6.2 Classification

**Theorem 6.1 (Classification of Tropical Irreducibles).** For every natural number $n$,

$$
n\text{ is tropically irreducible}
\quad\Longleftrightarrow\quad n=1.
$$

**Proof sketch.** The number $1$ is nonzero. If $1=a+b$ with natural numbers $a,b$, one summand must be $0$, so $1$ is irreducible. Conversely, let $n$ be nonzero and unequal to $1$. Then $n\ge2$, and

$$
n=1+(n-1)
$$

expresses $n$ as a sum of two nonzero natural numbers. Hence $n$ is reducible. $\square$

**Corollary 6.2 (Uniqueness).** Any two tropically irreducible natural numbers are equal.

**Proof sketch.** By Theorem 6.1, each is $1$. $\square$

Ordinary multiplication has infinitely many prime natural numbers. Tropical multiplication on the same underlying set has exactly one nonzero irreducible. This contrast is not a paradox: the operation defining factorization has changed.

## 7. Algorithms and Numerical Experiments

The principal arguments admit direct finite demonstrations.

### 7.1 Incidence-table checker

Given a finite point set, line set, and incidence predicate, enumerate every external point-line pair. For each pair, collect all lines through the point that share no incident point with the reference line. Playfair’s postulate holds exactly when every such collection has cardinality $1$.

If there are $P$ points and $L$ lines, a straightforward implementation tests at most $PL$ external pairs, considers $L$ candidate lines, and scans $P$ possible common points. Its worst-case time is $O(P^2L^2)$ and its auxiliary space is $O(L)$, aside from the incidence table.

### 7.2 Tropical irreducibility checker

For a given $n$, test every $a$ from $1$ through $n-1$. If $n-a$ is also positive, then $n=a+(n-a)$ is a nontrivial tropical factorization. The procedure runs in $O(n)$ time and $O(1)$ auxiliary space. A batch classification through $N$ takes $O(N^2)$ time naively, although Theorem 6.1 gives an immediate constant-time classifier: return true exactly when $n=1$.

### 7.3 Prime search and encoded labels

To exhibit a prime above $B$, test candidates greater than $B$ using trial division through their square roots. Searching through a candidate $p$ costs approximately $O((p-B)\sqrt p)$ elementary divisibility tests in the worst case. A finite permutation of prime labels can illustrate representational change, while the invariant theorem explains why a genuine multiplicative equivalence preserves primality independently of the chosen notation.

## 8. Applications and Interpretation

### 8.1 Communication with unfamiliar intelligences

Prime-number signals are persuasive because primality is structural under multiplication. A recipient need not share decimal notation. If sender and recipient identify corresponding multiplication structures, prime patterns survive the bridge. The theorem does not guarantee that the recipient treats multiplication as foundational, recognizes the intended encoding, or uses natural numbers at all.

### 8.2 A hierarchy of universality claims

The results suggest four levels:

1. **Deductive persistence:** conclusions survive extensions of assumptions.
2. **Semantic necessity:** all models of a base satisfy a sentence.
3. **Structural invariance:** equivalences preserving specified operations preserve properties definable from those operations.
4. **Operational dependence:** changing primitive operations changes the associated notions of factorization and irreducibility.

Failing to identify the level makes broad philosophical claims ambiguous.

### 8.3 The Riemann Hypothesis as a test case

A claim that every sufficiently rich arithmetic worldview proves the Riemann Hypothesis or its negation needs a specified base, language, semantics, and meaning of “sufficiently rich.” Once those are fixed, Corollary 3.4 shows that extension-universality of one orientation is equivalent to semantic decision by the base. The framework therefore converts a suggestive conjecture into a precise target without claiming a resolution.

## 9. Comparative Synthesis

The examples can be arranged as a diagnostic procedure for claims about mathematical inevitability. First specify a base theory. If a proposed truth is merely claimed to survive stronger assumptions, monotonicity settles the issue. If it is claimed to hold in every admissible world, search for models on opposite sides. If it is claimed to survive translation, list the operations and distinguished elements that the translation preserves. Finally, if an operation itself changes, rebuild the relevant definition before comparing outcomes.

This procedure prevents two common mistakes. The first is to treat extension as variation: an extension retains all base assumptions, whereas a different model may interpret the same language in a way that changes an undecided sentence. The second is to treat tropicalization as renaming: the passage from ordinary multiplication to ordinary addition changes factorization itself. The prime-invariance and tropical-classification theorems therefore complement rather than contradict one another. One concerns equivalence of multiplicative structures; the other concerns replacement of the multiplicative operation.

The framework also suggests a restrained notion of shared discovery. Two intelligences need not share notation or pedagogy to discover corresponding prime elements, provided their arithmetic systems are multiplicatively equivalent. They need not agree about a geometric sentence when their accepted models differ. Agreement is compelled only after the comparison map, background assumptions, and relevant semantics have been made explicit.

## 10. Limitations

The consequence operation is abstract; no particular first-order proof calculus is developed here. The semantic and syntactic notions are therefore intentionally kept separate. Connecting them requires soundness and completeness results for a chosen language and calculus.

The finite incidence witnesses establish independence only over an empty base. They do not model the complete shared axioms traditionally used to compare Euclidean and non-Euclidean geometry.

The arithmetic invariance theorem assumes a full multiplicative equivalence. Weaker translations may preserve some factorization data but not all. Moreover, the tropical classification concerns natural numbers with tropical multiplication, not tropical polynomials, whose factorization theory is much richer.

Finally, nothing here predicts the psychology or notation of non-human intelligence. The results specify conditional invariants: if a structure, base, or operation is preserved, certain conclusions follow.

## 11. Future Work

A first direction is to instantiate the abstract consequence operation with first-order Peano arithmetic and relate semantic consequence to a syntactic proof calculus through soundness and completeness.

A second is to replace the toy incidence worlds by Euclidean and hyperbolic geometries satisfying a common neutral axiom system. This would preserve the clarity of the two-model argument while strengthening its geometric content.

A third is to express the Riemann Hypothesis in an arithmetic language and sharply distinguish truth in the standard model, semantic consequence, syntactic provability, and independence.

A fourth is to classify which arithmetic properties survive weaker forms of translation than multiplicative equivalence.

A fifth is to develop tropical factorization for tropical polynomials, where geometry and combinatorics create substantially richer irreducibility phenomena.

## 12. Conclusion

Universal mathematics is not a single undifferentiated realm. Relative to a consistent base, the universal core is exactly what the base already entails. Across models, a positive and a negative witness destroy universality in both directions. Across multiplicatively equivalent encodings, primality survives. Across a change from ordinary multiplication to tropical multiplication, irreducibility changes dramatically, leaving only $1$ among the natural numbers.

These distinctions offer a rigorous answer to the question of non-human mathematical intuition. Equivalent structures compel equivalent structural discoveries; different axioms permit different worlds; different operations generate different arithmetic atoms. What another intelligence “must” discover depends on the bridge by which its mathematics is compared with ours.
