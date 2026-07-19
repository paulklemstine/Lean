# Functorial Information Loss: Entropy, Fibers, and Finite Object Maps

**Aristotle**  
**July 19, 2026**

## Abstract

A functor between finite categories induces a deterministic map on objects, and such a map can be studied as an information channel fed by the uniform distribution on its source. Two quantities must be distinguished: the Shannon entropy of the output object and the expected logarithmic cardinality of the observed fiber. This paper develops the resulting finite theory. We prove that the fiber probabilities form a distribution and establish the exact chain rule

$$
H_{\mathrm{out}}(f)+L_{\mathrm{fib}}(f)=\log |A|.
$$

We show that fiber loss vanishes exactly when the object map is injective. For a map with uniform nonempty fibers of size $k$ and $m$ attained outputs, the loss is $\log k=\log(|A|/m)$, whereas the output entropy is $\log m$. Thus the formula often proposed as “functorial entropy” is properly an information-loss term, not the entropy of the output distribution. Constant maps and the residue map from six states to three states illustrate the endpoints and the uniform case. We explain why object-level loss does not characterize categorical faithfulness, why unweighted object counting does not extend directly to large or infinite categories, and how the finite chain rule points toward compositional, groupoid-valued, morphism-sensitive, and measurable extensions.

## 1. Introduction

Functors are routinely described as forgetting structure. A forgetful functor sends a structured object to an underlying one; an invariant sends many objects to the same classification; a quotient construction merges distinctions. This language suggests an information-theoretic question: how much information does a functor lose?

For finite collections of objects, the first step is elementary. If $A$ is a nonempty finite source and $f:A\to B$ is the map on objects, choose a source object uniformly and observe only its image. The resulting process is a deterministic channel. Its fibers record which source objects become indistinguishable.

A subtlety appears immediately. The Shannon entropy

$$
-\sum_b p_b\log p_b
$$

measures uncertainty in the output. It does not directly measure what was erased. A constant map has output entropy zero, although it identifies every source object. Conversely, an injective map preserves all distinctions, although its output entropy may be large. Information loss is instead the conditional uncertainty of the source after observing the output. Under a uniform source and a deterministic map, that conditional uncertainty is the expected logarithm of fiber cardinality.

The theory therefore has two complementary statistics. The **output entropy** measures visible diversity. The **fiber loss** measures hidden ambiguity. Their sum is the entropy of the original uniform source. This separation both repairs the interpretation of the logarithmic quotient formula and identifies the precise finite statement from which broader categorical notions may grow.

The results concern finite object maps. They apply directly to finite sets and to the object maps of finite categories once a presentation and uniform source distribution have been fixed. They do not, by themselves, detect faithfulness, which concerns morphisms. Nor do they justify uniform counting in categories with infinitely many or a proper class of objects. These limitations are structural rather than technical, and they motivate the extensions discussed below.

All logarithms in this paper are natural logarithms, so entropy is measured in nats. A different base merely rescales every identity by a fixed constant.

## 2. Finite deterministic object channels

### 2.1 Source, target, and fibers

Let $A$ and $B$ be finite sets, assume $A$ is nonempty, and let

$$
f:A\to B
$$

be a function. In a categorical application, $A$ and $B$ may be chosen finite sets of displayed objects and $f$ may be induced by a functor.

**Definition 2.1 (Fiber).** For $b\in B$, the fiber of $f$ over $b$ is

$$
A_b=f^{-1}(b)=\{a\in A:f(a)=b\}.
$$

An output $b$ is **attained** when $A_b$ is nonempty. The set of attained outputs is the image $f(A)$.

The family of nonempty fibers partitions $A$. In particular,

$$
|A|=\sum_{b\in B}|A_b|.
$$

### 2.2 Pushforward probabilities

Choose $a\in A$ uniformly, so every source has probability $1/|A|$. The probability of observing $b$ is the total probability of its fiber.

**Definition 2.2 (Output probability).** For $b\in B$, define

$$
p_b=\frac{|A_b|}{|A|}.
$$

**Lemma 2.3 (Normalization).** The family $(p_b)_{b\in B}$ is a probability distribution: $p_b\ge 0$ for every $b$, and

$$
\sum_{b\in B}p_b=1.
$$

**Proof sketch.** Nonnegativity follows from cardinalities. For normalization, use the fiber partition:

$$
\sum_{b\in B}p_b
=\frac{1}{|A|}\sum_{b\in B}|A_b|
=\frac{|A|}{|A|}
=1.
$$

The assumption that $A$ is nonempty ensures that the denominator is positive. $\square$

### 2.3 Output entropy and fiber loss

We adopt the standard convention that a zero-probability entropy term is zero, equivalently $0\log 0=0$ in entropy sums.

**Definition 2.4 (Output object entropy).** The output entropy of $f$ is

$$
H_{\mathrm{out}}(f)=-\sum_{b\in B}p_b\log p_b.
$$

It measures the uncertainty of the observed output.

**Definition 2.5 (Expected fiber loss).** The fiber information loss of $f$ is

$$
L_{\mathrm{fib}}(f)=\sum_{b\in B}p_b\log |A_b|,
$$

where empty fibers contribute zero because their probability is zero.

Conditioned on observing an attained output $b$, all elements of $A_b$ remain equally likely: each had prior probability $1/|A|$, and the event $f(a)=b$ has probability $|A_b|/|A|$. Thus the posterior distribution on $A_b$ is uniform. Its Shannon entropy is $\log|A_b|$. Consequently, $L_{\mathrm{fib}}(f)$ is precisely the expected conditional entropy of the source given the output.

Both statistics are nonnegative. Output entropy is nonnegative because $0\le p_b\le 1$. Fiber loss is nonnegative because every attained fiber has size at least one, so $\log|A_b|\ge 0$.

## 3. The entropy–loss chain rule

The principal identity is the deterministic entropy chain rule specialized to a uniform finite source.

**Theorem 3.1 (Entropy–Loss Chain Rule).** Let $A$ be a nonempty finite set, $B$ a finite set, and $f:A\to B$. Then

$$
H_{\mathrm{out}}(f)+L_{\mathrm{fib}}(f)=\log|A|.
$$

**Proof sketch.** For each attained $b$,

$$
p_b=\frac{|A_b|}{|A|},
$$

so

$$
-\log p_b
=-\log\left(\frac{|A_b|}{|A|}\right)
=\log|A|-\log|A_b|.
$$

Rearranging gives

$$
-\log p_b+\log|A_b|=\log|A|.
$$

Multiply by $p_b$ and sum over all outputs. Empty fibers contribute zero. By Lemma 2.3,

$$
\begin{aligned}
H_{\mathrm{out}}(f)+L_{\mathrm{fib}}(f)
&=\sum_{b\in B}p_b\left(-\log p_b+\log|A_b|\right)\\
&=\sum_{b\in B}p_b\log|A|\\
&=\log|A|.
\end{aligned}
$$

This proves the claim. $\square$

The theorem gives an exact ledger. The uniform source entropy is $\log|A|$. The output preserves $H_{\mathrm{out}}(f)$ nats as observable diversity; the fibers retain $L_{\mathrm{fib}}(f)$ nats as unresolved source identity.

**Corollary 3.2 (Complementarity).** Under the hypotheses of Theorem 3.1,

$$
L_{\mathrm{fib}}(f)=\log|A|-H_{\mathrm{out}}(f)
$$

and

$$
H_{\mathrm{out}}(f)=\log|A|-L_{\mathrm{fib}}(f).
$$

Thus maximizing output entropy over maps with fixed source size is equivalent to minimizing fiber loss.

## 4. Zero loss and object injectivity

The expected logarithmic fiber size detects object identification exactly.

**Theorem 4.1 (Zero-Loss Characterization).** Let $A$ be a nonempty finite set, let $B$ be finite, and let $f:A\to B$. Then

$$
L_{\mathrm{fib}}(f)=0
$$

if and only if $f$ is injective.

**Proof sketch.** Suppose first that $f$ is injective. Every attained fiber has cardinality one. Hence each nonzero summand in $L_{\mathrm{fib}}(f)$ contains $\log 1=0$, and the total is zero.

Conversely, suppose $f$ is not injective. Then distinct $a,a'\in A$ satisfy $f(a)=f(a')=b$ for some $b$. Therefore $|A_b|\ge 2$. Since $A_b$ is nonempty, $p_b>0$, while $\log|A_b|\ge\log 2>0$. The contribution $p_b\log|A_b|$ is strictly positive. Every other contribution is nonnegative, so $L_{\mathrm{fib}}(f)>0$. $\square$

**Corollary 4.2.** If $f$ is injective, then

$$
H_{\mathrm{out}}(f)=\log|A|.
$$

This follows immediately from Theorems 3.1 and 4.1.

### 4.1 Object injectivity is not faithfulness

For a functor $F:\mathcal{C}\to\mathcal{D}$, categorical faithfulness means that, for every pair of objects $X,Y$ of $\mathcal{C}$, the function

$$
\operatorname{Hom}_{\mathcal{C}}(X,Y)
\longrightarrow
\operatorname{Hom}_{\mathcal{D}}(F(X),F(Y))
$$

is injective. This is a condition on morphisms. Theorem 4.1 concerns injectivity of the object assignment $X\mapsto F(X)$. The two conditions are logically independent in general.

Accordingly, zero fiber loss should not be advertised as equivalent to faithfulness. It is equivalent to object injectivity for the supported finite object map. A categorical loss capable of detecting faithfulness must include morphism-level probability models and morphism fibers.

## 5. Uniform fibers

Uniform many-to-one maps produce the simplest closed formulas.

**Definition 5.1 (Uniform-fiber map).** A map $f:A\to B$ has uniform nonempty fibers of size $k$ if

$$
|A_b|=k
$$

for every attained output $b\in f(A)$.

Let $m=|f(A)|$ be the number of attained outputs. Since the fibers partition $A$,

$$
|A|=mk.
$$

Nonemptiness of $A$ implies $m\ge 1$ and $k\ge 1$.

**Theorem 5.2 (Uniform-Fiber Loss Formula).** If $f:A\to B$ has uniform nonempty fibers of size $k$, then

$$
L_{\mathrm{fib}}(f)=\log k.
$$

Equivalently, with $m=|f(A)|$,

$$
L_{\mathrm{fib}}(f)=\log\frac{|A|}{m}.
$$

**Proof sketch.** Every attained output has probability

$$
p_b=\frac{k}{|A|}=\frac{1}{m}.
$$

The logarithmic fiber size is the constant $\log k$ on the support. Taking its expectation yields

$$
L_{\mathrm{fib}}(f)=\sum_{b\in f(A)}\frac{1}{m}\log k=\log k.
$$

The quotient form follows from $|A|=mk$. $\square$

**Theorem 5.3 (Uniform-Fiber Output Formula).** Under the same hypotheses,

$$
H_{\mathrm{out}}(f)=\log m.
$$

**Proof sketch.** The output distribution is uniform on the $m$ attained outputs, each having probability $1/m$. Therefore

$$
H_{\mathrm{out}}(f)
=-m\left(\frac{1}{m}\right)\log\left(\frac{1}{m}\right)
=\log m.
$$

Alternatively, combine Theorems 3.1 and 5.2 with $|A|=mk$. $\square$

These two theorems settle an important interpretive issue. The expression

$$
\log\frac{|A|}{m}=\log k
$$

is the information loss, while $\log m$ is the output entropy. They coincide only in special numerical cases, such as $m=k$.

## 6. Extremal and concrete examples

### 6.1 Constant maps

**Proposition 6.1 (Complete object erasure).** Let $A$ be nonempty and finite, and let $f:A\to B$ be constant. Then

$$
H_{\mathrm{out}}(f)=0
$$

and

$$
L_{\mathrm{fib}}(f)=\log|A|.
$$

**Proof sketch.** Exactly one output is attained, with probability one, so its output entropy is $-1\log 1=0$. Its unique nonempty fiber is all of $A$, so the expected logarithmic fiber size is $\log|A|$. $\square$

This is the maximal-loss case for a fixed source, because Theorem 3.1 and nonnegativity of output entropy imply

$$
0\le L_{\mathrm{fib}}(f)\le\log|A|.
$$

### 6.2 Injective maps

At the opposite endpoint, an injective map has singleton fibers. By Theorem 4.1,

$$
L_{\mathrm{fib}}(f)=0,
$$

and by the chain rule,

$$
H_{\mathrm{out}}(f)=\log|A|.
$$

Thus injective and constant maps realize the two endpoints of the information ledger.

### 6.3 The six-to-three residue channel

Let

$$
A=\{0,1,2,3,4,5\},
\qquad
B=\{0,1,2\},
$$

and define $f(i)$ to be the remainder of $i$ modulo $3$. The fibers are

$$
A_0=\{0,3\},\qquad A_1=\{1,4\},\qquad A_2=\{2,5\}.
$$

Every fiber has size $2$, and there are $3$ attained outputs. Hence

$$
L_{\mathrm{fib}}(f)=\log 2,
$$

while

$$
H_{\mathrm{out}}(f)=\log 3.
$$

The chain rule becomes

$$
\log 3+\log 2=\log 6.
$$

This example separates the two quantities with the smallest familiar nontrivial factors: the output retains the choice among three residue classes, while one binary distinction remains hidden inside each class.

### 6.4 A nonuniform example

Consider fiber sizes $1$, $2$, and $3$ over three attained outputs. Then $|A|=6$ and the output probabilities are $1/6$, $2/6$, and $3/6$. The output entropy is

$$
H_{\mathrm{out}}
=-\frac{1}{6}\log\frac{1}{6}
-\frac{2}{6}\log\frac{2}{6}
-\frac{3}{6}\log\frac{3}{6},
$$

and the loss is

$$
L_{\mathrm{fib}}
=\frac{1}{6}\log 1
+\frac{2}{6}\log 2
+\frac{3}{6}\log 3.
$$

Although neither term reduces to the logarithm of a single integer, their sum remains exactly $\log 6$. This demonstrates why expected logarithmic fiber size, rather than the logarithm of the average fiber size, is the natural quantity for arbitrary maps.

## 7. Algorithms

### 7.1 Exact counting pipeline

For a finite map represented by a list of output labels, one can compute all quantities in linear expected time using a hash table.

**Algorithm 7.1 (Fiber-Entropy Decomposition).** Given labels $f(a)$ for all $a\in A$:

1. Count the number $n=|A|$ of source objects.
2. Build a frequency table $c_b=|A_b|$ by scanning the labels once.
3. For each attained $b$, set $p_b=c_b/n$.
4. Accumulate $-p_b\log p_b$ into the output entropy.
5. Accumulate $p_b\log c_b$ into the fiber loss.
6. Compare their sum with $\log n$ as a numerical consistency check.

With $n$ source entries and $m$ attained outputs, the scan takes expected time $O(n)$ and the entropy pass takes $O(m)$. The memory requirement is $O(m)$. A sorting-based implementation uses $O(n\log n)$ time and can avoid hashing.

### 7.2 Uniformity test

**Algorithm 7.2 (Uniform-Fiber Certification).** Build the same frequency table. If all positive counts equal a common value $k$, the map has uniform nonempty fibers. Set $m$ equal to the number of positive counts and verify $n=mk$. The closed formulas are then

$$
H_{\mathrm{out}}=\log m,
\qquad
L_{\mathrm{fib}}=\log k.
$$

The test has expected time $O(n)$ and memory $O(m)$.

### 7.3 Collision witness for positive loss

**Algorithm 7.3 (Zero-Loss Diagnostic).** While scanning source objects, store the first source seen for each output. If a later, distinct source has the same output, return the pair as a collision witness. If no collision occurs, the map is injective and its loss is zero. This algorithm runs in expected time $O(n)$ and memory $O(m)$; it may terminate early when a collision is found.

## 8. Applications

### 8.1 Classification by invariants

Many mathematical constructions map an object to a coarse invariant: a vector space to its dimension, a matrix to its rank, a group to an abelian quotient, or a space to a homological signature. On a finite sampled family, output entropy measures the diversity of invariant values, while fiber loss measures the average unresolved ambiguity among objects sharing an invariant.

This distinction is practically useful. A balanced set of invariant values may have high output entropy even if each value represents many source objects. Conversely, a nearly injective invariant may have low loss despite a skewed output distribution.

### 8.2 Clustering and coarse-graining

A clustering map sends each data point to a cluster label. Under a uniform empirical distribution, the cluster-label entropy is $H_{\mathrm{out}}$, and the expected log cluster size is $L_{\mathrm{fib}}$. Equal-sized clusters give the uniform-fiber formulas. For unequal clusters, Theorem 3.1 still gives an exact decomposition of the logarithm of the sample size.

### 8.3 Privacy and anonymization

An anonymization rule maps records to released equivalence classes. Fiber loss measures average ambiguity about the original record after the released class is known. It is not, by itself, a complete privacy metric: real records are rarely uniform, side information changes posterior probabilities, and semantic sensitivity matters. Nevertheless, the finite model isolates the combinatorial contribution of a deterministic release rule.

### 8.4 Irreversible and reversible computation

A many-to-one operation erases distinctions. If the surrounding computation must remain reversible, enough auxiliary information must be retained to distinguish states within each fiber. The expected amount under a uniform source is naturally related to $L_{\mathrm{fib}}$. Uniform $k$-to-one maps hide $\log k$ nats per input on average.

## 9. Scope and limitations

### 9.1 Dependence on the source distribution

The formulas above assume a uniform source. For a general source distribution $q_a$, the output probability becomes

$$
p_b=\sum_{a\in A_b}q_a,
$$

and the conditional distribution inside a fiber need not be uniform. The correct loss is then the conditional entropy $H(A\mid B)$, not merely the expected logarithm of fiber cardinality. The present formula is exact because uniform priors remain uniform after conditioning on a deterministic fiber.

### 9.2 Dependence on categorical presentation

Raw object counts are not invariant under equivalence of categories. Two equivalent categories may display different numbers of isomorphic copies of the same object. Therefore an entropy based on displayed objects describes a chosen finite presentation or sample, not an equivalence-invariant property of an abstract category.

A skeletal category removes duplicate isomorphic objects, but automorphisms still carry structural information. For finite groupoids, homotopy cardinality suggests weighting each isomorphism class by the reciprocal of its automorphism-group order.

### 9.3 Infinite categories

A uniform probability distribution generally does not exist on a countably infinite set, much less on a proper class. Consequently, expressions based on dividing fiber cardinalities by the total number of objects are not defined for categories such as all sets, all groups, or all topological spaces without additional choices and size controls.

Nor does a single infinite fiber automatically imply infinite expected loss. Expected loss depends on both magnitude and probability. In a measurable extension, divergence should mean that conditional entropy has infinite integral, with suitable attention to positive-measure sets and integrability.

### 9.4 Object information versus morphism information

The object statistic cannot detect whether distinct morphisms are identified. A complete categorical theory should model distributions on objects and conditional distributions on hom-sets. Total loss could then split into an object-identification term and a morphism-identification term. Theorem 4.1 provides the exact baseline for the object component.

## 10. Future directions

### 10.1 A chain rule for composable finite functors

For composable functors between finite skeletal categories, one should define object loss from the uniform distribution on source objects and conditional loss relative to the intermediate image. The loss of a composite is expected to decompose into stagewise terms only when each term is weighted by the actual intermediate pushforward distribution. Conditional-uniformity hypotheses may identify when simpler logarithmic formulas apply.

### 10.2 Groupoid-cardinality entropy

For finite groupoids, raw object counts should be replaced by homotopy cardinality. An isomorphism class represented by $x$ receives weight proportional to $1/|\operatorname{Aut}(x)|$. An essentially surjective functor with homotopically uniform fibers may then satisfy an entropy-loss identity with homotopy fiber cardinality in place of ordinary cardinality. Such a theory would aim to be invariant under equivalence.

### 10.3 Mutual information between objects and morphisms

For finite categories with probability distributions on objects and conditional distributions on hom-sets, one may seek a decomposition into object and morphism loss. Vanishing total loss should correspond to injectivity on supported objects together with faithfulness on supported hom-sets. The independence of these conditions makes a multicomponent invariant more natural than a single object statistic.

### 10.4 Measured entropy for infinite categories

For essentially small categories whose isomorphism classes form a countable or standard Borel space, a probability measure can replace uniform counting. The appropriate loss is measurable conditional entropy. Infinite loss should correspond to divergence of its expectation, rather than to cardinality alone.

## 11. Conclusion

A finite object map has two complementary information statistics. The Shannon entropy of its output records the diversity that remains visible. The expected logarithmic fiber size records the source ambiguity that remains hidden. Their exact relation is

$$
H_{\mathrm{out}}(f)+L_{\mathrm{fib}}(f)=\log|A|.
$$

Zero loss is equivalent to injectivity on objects. Uniform fibers of size $k$ produce loss $\log k$, while $m$ attained outputs produce output entropy $\log m$. Constant and injective maps occupy the opposite endpoints of the same ledger.

This finite theory does not collapse object injectivity into categorical faithfulness, and it does not assign uniform probabilities to infinite collections where none exist. Instead, it supplies a precise foundation: information retained belongs to the output distribution, information lost belongs to conditional fibers, and categorical generalizations must account for equivalence, automorphisms, morphisms, and measure. The phrase “a functor forgets” thereby becomes a quantitative program with a clear first theorem and equally clear next questions.
