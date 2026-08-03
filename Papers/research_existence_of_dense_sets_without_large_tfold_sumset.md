# Dense Sets Without Large Many-Fold Sumsets: Sharp Finite-Interval Obstructions and the Logarithmic Frontier

**Aristotle**  
**August 3, 2026**

## Abstract

For finite nonempty sets of integers $A_1,\ldots,A_t$, their many-fold sumset satisfies the sharp growth inequality

$$
|A_1+\cdots+A_t|\ge \sum_{i=1}^t |A_i|-t+1.
$$

We specialize this principle to the initial interval $[n]=\{0,\ldots,n-1\}$ and derive an exact deterministic obstruction: if every summand has at least $k$ elements and the whole $t$-fold sumset lies in $[n]$, then $t(k-1)+1\le n$. Consequently, whenever $n\le t(k-1)$, even the full interval avoids every such sumset. Since the full interval has density at least any prescribed $0\le\delta\le1$, this yields an explicit dense-set existence theorem at a linear part-size threshold. We give proofs, equality examples, algorithms for checking the obstruction, and small numerical illustrations. We then formulate the substantially stronger logarithmic-scale avoidance problem for fixed $t\ge2$ and $0<\delta<1$, carefully separating the established linear theorem from this open target. Finally, we discuss repeated summands, finite-container enumeration, random constructions, and matching lower bounds as routes toward the logarithmic regime.

## 1. Introduction

For finite subsets $A$ and $B$ of an additive group, the sumset

$$
A+B=\{a+b:a\in A,\ b\in B\}
$$

encodes all totals obtainable from one choice in each set. Additive combinatorics studies the tension between the sizes and internal structures of $A$, $B$, and $A+B$. Over the integers, order forces a particularly clean phenomenon: two nonempty finite sets cannot add without growing by at least the sum of their cardinalities minus one.

The present work concerns an extremal containment question. Given an interval $[n]$ and $t$ finite nonempty sets $A_1,\ldots,A_t$, when can the complete sumset $A_1+\cdots+A_t$ be contained in $[n]$? More generally, can a subset $S\subseteq[n]$ of prescribed positive density avoid all such sumsets when the component sets are large?

There are two distinct scales. At the **linear scale**, cardinality growth alone answers the question sharply. If every $A_i$ has at least $k$ elements, then the sumset has at least $t(k-1)+1$ elements. It therefore cannot fit into $[n]$ when $n\le t(k-1)$. This observation yields a dense witness of maximal size: the full interval itself.

At the **logarithmic scale**, cardinality is no longer sufficient. The motivating target asks whether, for fixed $t\ge2$ and density $0<\delta<1$, one can find density-$\delta$ subsets of every sufficiently long interval that avoid all $t$-fold sumsets whose parts have size at least a constant multiple of

$$
\frac{\log n}{\bigl(\log(1/\delta)\bigr)^{1/(t-1)}}.
$$

The established results below do not prove this logarithmic assertion. Rather, they identify exactly the deterministic obstruction that any future argument must surpass. This distinction is essential: the linear theorem is unconditional and sharp, whereas the logarithmic statement requires new structural or probabilistic ideas.

The paper is organized as follows. Section 2 introduces the notation and density model. Section 3 proves sharp many-fold growth. Section 4 gives the finite-container theorem and its contrapositive. Section 5 derives the dense linear-scale existence theorem. Section 6 examines equality and examples. Section 7 presents computational procedures. Section 8 formulates the logarithmic target. Sections 9 and 10 discuss probabilistic heuristics, applications, limitations, and future problems.

## 2. Definitions and setting

### 2.1. Initial intervals

For a nonnegative integer $n$, define

$$
[n]=\{0,1,\ldots,n-1\}\subset\mathbb Z.
$$

Thus $[0]=\varnothing$, and for every $n$ one has

$$
|[n]|=n.
$$

The zero-based convention is convenient for addition and does not affect cardinality arguments. Translating the interval by an integer produces an equivalent container.

### 2.2. Many-fold sumsets

Let $A_1,\ldots,A_t$ be finite subsets of $\mathbb Z$. Their $t$-fold sumset is

$$
A_1+\cdots+A_t
=
\{a_1+\cdots+a_t:a_i\in A_i\text{ for }1\le i\le t\}.
$$

When all summands agree with a set $A$, we write

$$
tA=\underbrace{A+\cdots+A}_{t\text{ copies}}.
$$

The nonemptiness of every summand is important. It guarantees that successive addition is meaningful for cardinality growth and excludes the degenerate empty sumset.

### 2.3. Uniform part size and avoidance

Fix an integer $k\ge1$. A $t$-fold sumset has **uniform part size at least $k$** if

$$
|A_i|\ge k
$$

for every $i$. A set $S\subseteq\mathbb Z$ **avoids** such sumsets if there are no finite nonempty $A_1,\ldots,A_t$ of uniform part size at least $k$ satisfying

$$
A_1+\cdots+A_t\subseteq S.
$$

Notice that the sets $A_i$ themselves need not lie in $S$ or in $[n]$. Only their complete sumset is required to lie in the container. The obstruction proved below therefore applies without any assumptions on the locations or diameters of the summands.

### 2.4. Density

For $S\subseteq[n]$ and $0\le\delta\le1$, we say that $S$ has density at least $\delta$ in $[n]$ if

$$
|S|\ge\delta n.
$$

The inequality uses a real-valued right-hand side, so no rounding convention is needed. Equivalently, when $n>0$, one has $|S|/n\ge\delta$.

## 3. Sharp growth of sumsets in the integers

We begin with the elementary two-set estimate.

### Lemma 3.1. Two-set growth

Let $A$ and $B$ be finite nonempty subsets of $\mathbb Z$. Then

$$
|A+B|\ge |A|+|B|-1.
$$

#### Proof sketch

Write the elements in increasing order:

$$
A=\{a_1<\cdots<a_r\},
\qquad
B=\{b_1<\cdots<b_s\}.
$$

Consider

$$
a_1+b_1,
a_2+b_1,
\ldots,
a_r+b_1,
a_r+b_2,
\ldots,
a_r+b_s.
$$

These are all elements of $A+B$. They form a strictly increasing chain because increasing either coordinate strictly increases the sum. The chain has $r+s-1$ terms, proving the claim. $\square$

The estimate extends by induction.

### Theorem 3.2. Many-fold growth

Let $t\ge1$, and let $A_1,\ldots,A_t$ be finite nonempty subsets of $\mathbb Z$. Then

$$
|A_1+\cdots+A_t|
\ge
\sum_{i=1}^t |A_i|-t+1.
$$

#### Proof sketch

For $t=1$, equality holds. Suppose the statement is known for $t-1$ summands and set

$$
B=A_1+\cdots+A_{t-1}.
$$

Because all summands are nonempty, $B$ is nonempty. Lemma 3.1 gives

$$
|B+A_t|\ge |B|+|A_t|-1.
$$

The inductive hypothesis gives

$$
|B|\ge\sum_{i=1}^{t-1}|A_i|-(t-1)+1.
$$

Combining the inequalities yields

$$
|A_1+\cdots+A_t|
\ge
\sum_{i=1}^t|A_i|-t+1.
$$

This completes the induction. $\square$

### Corollary 3.3. Uniform growth

Under the hypotheses of Theorem 3.2, if $|A_i|\ge k$ for every $i$, then

$$
|A_1+\cdots+A_t|\ge t(k-1)+1.
$$

#### Proof sketch

Theorem 3.2 gives

$$
|A_1+\cdots+A_t|
\ge
\sum_{i=1}^t |A_i|-t+1
\ge tk-t+1=t(k-1)+1.
$$

$\square$

### 3.1. Sharpness

The lower bound cannot be improved. Let

$$
A_i=\{x_i,x_i+d,\ldots,x_i+(m_i-1)d\}
$$

be arithmetic progressions with the same positive step $d$. Their sumset is

$$
A_1+\cdots+A_t
=
\left\{
\sum_{i=1}^t x_i+jd:
0\le j\le\sum_{i=1}^t(m_i-1)
\right\}.
$$

Hence

$$
|A_1+\cdots+A_t|
=
1+\sum_{i=1}^t(m_i-1)
=
\sum_{i=1}^t|A_i|-t+1.
$$

In particular, if every $m_i=k$, equality in Corollary 3.3 becomes

$$
|A_1+\cdots+A_t|=t(k-1)+1.
$$

Thus the obstruction in the next section is exact as a universal cardinality statement.

## 4. The finite-container obstruction

### Theorem 4.1. Uniform finite-container bound

Let $n,t,k$ be nonnegative integers, and let $A_1,\ldots,A_t$ be finite nonempty subsets of $\mathbb Z$. Assume $|A_i|\ge k$ for every $i$ and

$$
A_1+\cdots+A_t\subseteq[n].
$$

Then

$$
t(k-1)+1\le n.
$$

For the intended regime $t\ge1$ and $k\ge1$, all terms have their ordinary integer meaning.

#### Proof sketch

By Corollary 3.3,

$$
t(k-1)+1\le|A_1+\cdots+A_t|.
$$

Containment in $[n]$ implies

$$
|A_1+\cdots+A_t|\le|[n]|=n.
$$

Transitivity proves the result. $\square$

This theorem uses no geometric information about the sets beyond cardinality and nonemptiness. It is invariant under translating the summands in ways that preserve containment of the resulting sumset.

### Theorem 4.2. Linear-threshold avoidance

Let $n,t,k$ be nonnegative integers satisfying

$$
n\le t(k-1).
$$

Then there do not exist finite nonempty sets $A_1,\ldots,A_t\subset\mathbb Z$, each satisfying $|A_i|\ge k$, for which

$$
A_1+\cdots+A_t\subseteq[n].
$$

#### Proof sketch

If such sets existed, Theorem 4.1 would imply

$$
t(k-1)+1\le n.
$$

Together with $n\le t(k-1)$, this would force

$$
t(k-1)+1\le t(k-1),
$$

which is impossible. $\square$

The strict one-point gap matters. At the boundary $n=t(k-1)+1$, containment can occur. For example, take every summand to be

$$
A_i=\{0,1,\ldots,k-1\}.
$$

Then

$$
A_1+\cdots+A_t=\{0,1,\ldots,t(k-1)\}=[t(k-1)+1].
$$

Thus the transition between automatic impossibility and possible containment occurs exactly between $n=t(k-1)$ and $n=t(k-1)+1$.

## 5. A dense-set existence theorem

The finite-container obstruction immediately provides a dense witness.

### Theorem 5.1. Dense linear-scale avoidance

Let $0\le\delta\le1$, and let $n,t,k$ be nonnegative integers satisfying

$$
n\le t(k-1).
$$

Then there exists a set $S\subseteq[n]$ such that

$$
|S|=n,
\qquad
|S|\ge\delta n,
$$

and $S$ contains no sumset $A_1+\cdots+A_t$ generated by finite nonempty integer sets with $|A_i|\ge k$ for every $i$.

#### Proof sketch

Choose

$$
S=[n].
$$

Then $S\subseteq[n]$ and $|S|=n$. Since $\delta\le1$ and $n\ge0$,

$$
\delta n\le n=|S|.
$$

The avoidance assertion is exactly Theorem 4.2. $\square$

### Remark 5.2. Why density one can still avoid

The forbidden object is an entire sumset, not a single additive relation. The interval $[n]$ contains many triples satisfying $x+y=z$, but under the barrier condition it cannot contain all sums obtained from $t$ independent choices among $k$ or more possibilities. Density one therefore does not conflict with avoidance.

### Remark 5.3. Scope of the density hypothesis

The theorem only requires $\delta\le1$; positivity of $\delta$ is unnecessary for this witness. The range $0<\delta<1$ becomes relevant in the logarithmic problem, where the density deficit is expected to control the achievable threshold.

## 6. Examples and exact boundary behavior

### Example 6.1. Two sets of size three

Let $A$ and $B$ be finite nonempty sets with

$$
|A|\ge3,
\qquad
|B|\ge3.
$$

Then

$$
|A+B|\ge3+3-1=5.
$$

Consequently,

$$
A+B\nsubseteq[3].
$$

Indeed, a set with at least five elements cannot lie in a three-element interval. The general barrier reads

$$
3\le2(3-1)=4,
$$

so automatic avoidance applies.

### Example 6.2. Three sets of size two

Let $A,B,C$ be finite nonempty sets satisfying

$$
|A|,|B|,|C|\ge2.
$$

Then

$$
|A+B+C|\ge2+2+2-3+1=4.
$$

Thus

$$
A+B+C\nsubseteq[3].
$$

Here the condition is exactly

$$
3\le3(2-1)=3.
$$

### Example 6.3. Equality at the first feasible interval

For $t=3$ and $k=2$, take

$$
A=B=C=\{0,1\}.
$$

Then

$$
A+B+C=\{0,1,2,3\}=[4].
$$

The three-point interval is too short, while the four-point interval is exactly large enough. This realizes

$$
t(k-1)+1=3(2-1)+1=4.
$$

### Example 6.4. Nonuniform summands

Theorem 3.2 retains more information than its uniform corollary. If

$$
|A_1|=2,
\quad |A_2|=5,
\quad |A_3|=7,
$$

then

$$
|A_1+A_2+A_3|
\ge2+5+7-3+1=12.
$$

Hence no interval with fewer than twelve points can contain the sumset. For applications with unequal part sizes, the exact bound

$$
1+\sum_{i=1}^t(|A_i|-1)
$$

should be used instead of replacing all sizes by their minimum.

## 7. Algorithms and numerical exploration

Although the principal theorem is symbolic, two simple algorithms make its content concrete.

### 7.1. Barrier test

Given $n,t,k$, compute

$$
L=t(k-1)+1.
$$

If $L>n$, containment is impossible for every qualifying family. If $L\le n$, cardinality alone is inconclusive: containment may or may not occur, depending on structure and location.

This computation uses constant many arithmetic operations. Under a bit-complexity model, its running time is governed by multiplication of integers of size $O(\log n+\log t+\log k)$.

### 7.2. Explicit sumset enumeration

For small finite sets, one may build the sumset iteratively. Start with the neutral set $T=\{0\}$ and update

$$
T\leftarrow\{x+a:x\in T,\ a\in A_i\}
$$

for $i=1,\ldots,t$. The final $T$ equals $A_1+\cdots+A_t$.

If the intermediate set before stage $i$ has size $M_{i-1}$, that stage performs $M_{i-1}|A_i|$ additions before duplicate removal. A direct upper bound is

$$
O\!\left(\prod_{i=1}^t|A_i|\right)
$$

arithmetic operations, with additional hashing or sorting costs. This exponential dependence on $t$ reflects the Cartesian family of choices, although collisions may greatly reduce stored output size.

### 7.3. Experimental interpretation

Enumeration can illustrate equality cases and test proposed finite examples, but it does not replace the universal theorem. The barrier test proves impossibility simultaneously for all possible summands, including sets far outside the ambient interval whose sums happen to land inside it.

## 8. The logarithmic-scale target

The deterministic theorem excludes uniform part sizes above approximately $n/t$. The motivating research problem asks for avoidance at a much smaller threshold.

### Conjecture 8.1. Logarithmic-scale many-fold sumset avoidance

Fix an integer $t\ge2$ and a real density $0<\delta<1$. There should exist a constant $C=C(t,\delta)>0$ and an integer $N$ such that for every $n\ge N$ there exists $S\subseteq[n]$ with

$$
|S|\ge\delta n
$$

and such that no finite nonempty sets $A_1,\ldots,A_t\subset\mathbb Z$ satisfy both

$$
A_1+\cdots+A_t\subseteq S
$$

and, for every $i$,

$$
|A_i|
\ge
C\,
\frac{\log n}
{\bigl(\log(1/\delta)\bigr)^{1/(t-1)}}.
$$

The inequality compares an integer cardinality with a real threshold in the ordinary way. The logarithms are well-defined because $n>0$ for sufficiently large $n$ and $0<\delta<1$ implies $1/\delta>1$.

### 8.1. Separation from the proved result

Theorem 5.1 does not establish Conjecture 8.1. At the conjectured threshold, Corollary 3.3 guarantees only a sumset of logarithmic cardinality, while $S$ has cardinality of order $n$. There is ample room in a cardinal sense. Avoidance must therefore arise from arranging the missing points of $S$ so that every candidate sumset hits at least one missing point.

### 8.2. Dependence on density

The factor $\log(1/\delta)$ measures the cost of requiring a whole pattern to survive in a density-$\delta$ set. For fixed $\delta$, the proposed part size grows like $\log n$. As $\delta$ decreases, $\log(1/\delta)$ grows and the threshold becomes smaller. The exponent $1/(t-1)$ predicts a different density sensitivity for each number of summands.

## 9. Probabilistic and enumerative heuristics

Suppose each point of $[n]$ is retained independently with probability $\delta$. For a fixed set $T\subseteq[n]$, the probability that $T$ is entirely retained is

$$
\mathbb P(T\subseteq S)=\delta^{|T|}.
$$

If $T=A_1+\cdots+A_t$ and every $|A_i|\ge k$, then Corollary 3.3 yields

$$
\mathbb P(T\subseteq S)
\le
\delta^{t(k-1)+1}.
$$

For a single candidate, this decays exponentially in $k\log(1/\delta)$. The obstacle is the number of distinct candidate sumsets. A naive count of all tuples of subsets is far too large. Successful probabilistic avoidance requires a structural enumeration theorem that counts distinct sumsets, or a dependency-sensitive argument that avoids paying for every representation separately.

A particularly suggestive finite-container estimate would assert that, for fixed $t$, the number of distinct $t$-fold sumsets contained in $[n]$ with all component sizes at least $k$ is at most

$$
\exp\!\left(\frac{K_t n}{k^{t-1}}\right)
$$

for a constant $K_t$ and suitable $n,k$. Such a bound is not established here, but it illustrates why the exponent $1/(t-1)$ may emerge when enumeration and survival probability are balanced.

Repeated sumsets $tA$ form a more structured subclass. Their representations are constrained by a single set, potentially making them more tractable. Proving logarithmic avoidance first for repeated summands could reveal which aspects of the general problem are caused by independent variation among the $A_i$.

## 10. Applications, limitations, and future work

### 10.1. Applications of the finite obstruction

The finite-container theorem can serve as a preprocessing rule in searches for additive configurations. Before enumerating candidate sets, one checks whether

$$
1+\sum_{i=1}^t(|A_i|-1)>n.
$$

If so, every candidate is impossible and the branch can be discarded. The uniform form provides an even cheaper test when only a common lower bound $k$ is known.

The theorem also calibrates numerical experiments. Any claimed containment violating $t(k-1)+1\le n$ must contain an error. Equality examples based on aligned arithmetic progressions provide canonical positive tests.

More conceptually, the result partitions parameter space. In the automatic-avoidance region $n\le t(k-1)$, no construction is needed. In the feasible region $n\ge t(k-1)+1$, cardinality permits containment and more refined structure becomes decisive.

### 10.2. Limitations

Cardinality growth cannot distinguish a random-looking sumset from an arithmetic progression when they have the same size. It also says nothing about how many candidate sumsets exist or how their containment events overlap. These are precisely the issues that dominate the logarithmic regime.

The integer order is central to the sharp inequality used here. Analogous questions in finite cyclic groups require attention to wraparound and group order; the lower bound $|A+B|\ge|A|+|B|-1$ can fail without an appropriate minimum involving the ambient group size.

Finally, the density theorem at linear scale uses the full interval. It should not be interpreted as evidence that the full interval works at logarithmic scale; it plainly contains many small sumsets. The witness demonstrates only that very large summands are excluded by lack of capacity.

### 10.3. Future directions

Five problems emerge naturally.

1. **Logarithmic-scale avoidance.** Prove Conjecture 8.1 for every $t\ge2$ and $0<\delta<1$.

2. **Common-summand specialization.** Determine whether one can avoid every repeated sumset $tA$ once

$$
|A|\ge
C\,
\frac{\log n}{\bigl(\log(1/\delta)\bigr)^{1/(t-1)}}.
$$

3. **Finite-container sharpening.** Establish an enumerative bound of order

$$
\exp\!\left(\frac{K_t n}{k^{t-1}}\right)
$$

for distinct qualifying sumsets inside $[n]$.

4. **Random-construction threshold.** Decide whether Bernoulli-$\delta$ subsets avoid every qualifying sumset with positive probability at the conjectured scale, with a constant depending only on $t$ before the explicit density normalization.

5. **Sharpness up to constants.** Seek a converse guaranteeing that every sufficiently large density-$\delta$ subset contains a $t$-fold sumset whose parts have size at least a positive constant multiple of the conjectured logarithmic threshold.

These directions separate construction, enumeration, probability, and lower bounds. Progress on any one would clarify whether the proposed logarithmic scale is intrinsic.

## 11. Broader structural perspective

The proof depends on two features of the integers: translation-invariant addition and a total order compatible with addition. The increasing chain in Lemma 3.1 is a one-dimensional path through the Cartesian grid $A\times B$. It moves first through one coordinate and then through the other, producing $|A|+|B|-1$ distinct values. Iteration concatenates such paths across further coordinates. This viewpoint explains why the argument is robust under arbitrary gaps between elements but sensitive to ambient algebraic settings where sums may wrap around.

The equality construction also points toward inverse questions. Arithmetic progressions with a common difference achieve minimal growth. Thus candidate sumsets near the smallest possible cardinality should exhibit substantial additive organization. A future counting theorem may profit by dividing candidates into low-growth structured families and higher-growth families, whose larger cardinality makes their complete inclusion in a random set less likely. Such a structure-versus-probability decomposition would connect the deterministic theorem directly to the logarithmic program.

There is also an algorithmic dichotomy. Below the barrier, one constant-time arithmetic test certifies nonexistence. Above it, explicit enumeration can be expensive because the number of tuples of choices is $\prod_i|A_i|$. Structural compression is therefore not merely aesthetically desirable; it is necessary for scalable experimentation. Canonical descriptions of low-growth sumsets, combined with bounds on the number of descriptions, could serve both probabilistic proofs and practical searches.

Finally, the exact boundary guards against misleading asymptotics. Replacing $t(k-1)+1$ by a rough expression such as $tk$ loses the equality case and can misclassify small instances. Since the intended logarithmic threshold is tested through finite experiments before asymptotic behavior becomes visible, retaining the exact additive constants is mathematically and computationally useful.

## 12. Conclusion

The expansion of finite integer sets under addition gives an exact universal rule:

$$
|A_1+\cdots+A_t|
\ge
1+\sum_{i=1}^t(|A_i|-1).
$$

For summands of size at least $k$, this becomes $t(k-1)+1$. Since $[n]$ has exactly $n$ points, containment forces

$$
t(k-1)+1\le n.
$$

The inequality is sharp, and its contrapositive yields a complete avoidance theorem below the boundary. Choosing the full interval then gives a density-$\delta$ witness for every $0\le\delta\le1$ at the linear threshold.

This resolves the deterministic capacity question but exposes a substantial scale gap. At logarithmic part size, the ambient set has enough room, so avoidance must exploit the collective structure of all candidate sumsets. Sharp enumeration, random constructions, and matching unavoidable-pattern results are the natural next steps. The finite obstruction supplies the baseline against which each such advance must be measured.
