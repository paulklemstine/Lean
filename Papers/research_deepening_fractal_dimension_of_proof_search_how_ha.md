# Relative Entropy Dimension for Nonstationary Search Trees

**Aristotle**  
**July 18, 2026**

## Abstract

We develop a finite-scale dimension theory for nonstationary rooted search trees whose ambient branching and successful branching vary by level. A branching profile $a=(a_0,\ldots,a_{n-1})$ has path count $P(a)=\prod_i a_i$ and logarithmic volume $L(a)=\sum_i\log a_i$. For an ambient profile $b$ and a successful profile $s$, the relative entropy dimension is

$$
D(b,s)=\frac{L(s)}{L(b)},
$$

whenever $L(b)\ne 0$. We establish exact path counting, logarithmic additivity, the entropy power law $P(s)=P(b)^{D(b,s)}$, unit-interval bounds under coordinatewise pruning, monotonicity with respect to successful branching, a multiscale composition law, and invariance under repetition. The composition law shows that sequential phases combine by an ambient-entropy-weighted mean rather than a depth-weighted mean. Periodic binary geometries emerge as the special case in which dimension equals the fraction of levels retaining two branches. Algorithms for computing and diagnosing profile dimension are given, together with applications to staged search, bottleneck analysis, constrained languages, and hierarchical decision systems. The theory distinguishes geometric abundance from policy-dependent discovery cost and identifies several routes from exact finite products to submultiplicative, ergodic, and finite-state models.

## 1. Introduction

A rooted search process generates a tree. At each level, a partial candidate can be extended in several ways; some extensions remain compatible with eventual success and others do not. In the simplest model, every node has the same number $b$ of ambient children and exactly $s$ viable children. After $n$ levels there are $b^n$ ambient paths and $s^n$ successful paths, and the exponent relating them is

$$
\frac{\log s}{\log b}.
$$

That exponent has the form of a fractal dimension. It measures successful growth relative to ambient growth.

Uniform branching is rarely realistic. Different stages may expose different rule sets, constraints, or design decisions. One stage can be binary, another can present hundreds of alternatives, and a third can be forced. The successful branching can fluctuate just as strongly. This paper treats such nonstationarity directly through finite branching profiles.

The key move is to measure branching by logarithmic volume. Products of levelwise branching numbers count complete paths, while logarithms turn those products into sums. Sequential phases then become additive before normalization. This produces an exact composition law: the dimension of a concatenated search is the weighted average of the phase dimensions, with each phase weighted by its ambient logarithmic volume.

This weighting is essential. Averaging phase dimensions by depth silently treats a binary decision and a thousand-way decision as equal contributions. They are equal in duration but not in combinatorial information. Relative entropy dimension corrects that mismatch.

The finite theory developed here has six principal conclusions:

1. logarithmic profile volume is exactly the logarithm of the combinatorial path count;
2. successful and ambient path counts satisfy an exact entropy power law;
3. coordinatewise pruning places dimension in $[0,1]$;
4. enlarging successful branching increases dimension;
5. sequential phases combine by ambient-entropy weighting; and
6. repetition preserves dimension.

These claims require no stationarity and no asymptotic limit. They are exact for every finite positive profile. Their proofs also isolate the algebraic structure expected to persist in broader models.

## 2. Search profiles and logarithmic volume

### 2.1 Branching profiles

A **finite branching profile** is a finite sequence of natural numbers

$$
a=(a_0,a_1,\ldots,a_{n-1}),
$$

where $a_i$ is the number of extensions available at level $i$. Unless noted otherwise, profiles considered in counting identities are **positive**, meaning $a_i\ge 1$ for all $i$.

The independent levelwise model associates one complete path with each choice of one branch at every level. This gives the following definition.

**Definition 2.1 (Path count).** The path count of a branching profile $a$ is

$$
P(a)=\prod_{i=0}^{n-1}a_i.
$$

For the empty profile, the empty product is $P(())=1$. This convention represents the unique path of length zero.

**Definition 2.2 (Logarithmic volume).** The logarithmic volume of $a$ is

$$
L(a)=\sum_{i=0}^{n-1}\log a_i.
$$

For the empty profile, $L(())=0$. The logarithm may be taken in any fixed base greater than $1$ because all dimensions below are ratios in which the base-dependent constant cancels. Natural logarithms are used throughout.

Logarithmic volume is an information measure. A level with $a_i$ choices contributes $\log a_i$ units. Unary levels contribute zero because they create no combinatorial choice.

### 2.2 Ambient and successful profiles

Let

$$
b=(b_0,\ldots,b_{n-1})
$$

be an ambient profile and

$$
s=(s_0,\ldots,s_{n-1})
$$

be a successful profile. The intended interpretation is that $b_i$ counts all admissible next steps and $s_i$ counts those next steps that can still be extended to a successful complete path.

A pair $(b,s)$ is **coordinatewise pruned** if the profiles have the same length and

$$
1\le s_i\le b_i
$$

for every level $i$. This assumption excludes extinction at a finite level. Extinction could be represented separately, but logarithms of zero would require an extended-real formulation.

**Definition 2.3 (Relative entropy dimension).** If $L(b)\ne 0$, the profile dimension of $s$ relative to $b$ is

$$
D(b,s)=\frac{L(s)}{L(b)}
      =\frac{\sum_i\log s_i}{\sum_i\log b_i}.
$$

The condition $L(b)\ne 0$ is exact, not cosmetic. A positive integer profile has $L(b)=0$ precisely when every ambient level is unary. Such a profile contains no branching information against which successful growth can be normalized.

The quantity $D(b,s)$ is a relative exponent, not a survival probability. The ratio $P(s)/P(b)$ measures the fraction of terminal paths surviving in this product model. Dimension instead answers: to what power must the ambient path count be raised to obtain the successful path count?

## 3. Basic identities

Concatenation models sequential composition. If $a$ describes one phase and $c$ another, write $a\mathbin{\|}c$ for the profile formed by appending $c$ after $a$.

**Theorem 3.1 (Additivity under concatenation).** For all finite profiles $a$ and $c$,

$$
L(a\mathbin{\|}c)=L(a)+L(c).
$$

**Proof sketch.** The entries of the concatenated profile are exactly the entries of $a$ followed by those of $c$. Splitting the finite sum of their logarithms at the phase boundary yields the result. $\square$

Let $a^{\| k}$ denote the concatenation of $k$ copies of $a$.

**Corollary 3.2 (Scaling under repetition).** For every natural number $k$,

$$
L(a^{\| k})=kL(a).
$$

**Proof sketch.** Induct on $k$. The case $k=0$ is the empty profile. Appending one more copy adds $L(a)$ by Theorem 3.1. $\square$

The combinatorial and logarithmic descriptions coincide exactly.

**Theorem 3.3 (Path-Count Identity).** If $a_i\ge 1$ for every entry of $a$, then

$$
\log P(a)=L(a).
$$

**Proof sketch.** Induct on the profile length. Removing the first entry writes $P(a)$ as that entry times the product of the tail. Positivity permits the logarithmic product identity $\log(xy)=\log x+\log y$. The induction hypothesis identifies the logarithm of the tail product with the tail volume. $\square$

Equivalently,

$$
P(a)=e^{L(a)}.
$$

Thus logarithmic volume is not a surrogate for path count; it is its exact logarithmic representation.

## 4. Exact dimensional scaling

The definition of dimension is arranged so that successful growth obeys a power law.

**Theorem 4.1 (Entropy Power Law).** Let $b$ and $s$ be positive finite branching profiles, not necessarily of the same length. If $L(b)\ne 0$, then

$$
P(s)=P(b)^{D(b,s)}.
$$

**Proof sketch.** By Theorem 3.3,

$$
\log P(s)=L(s).
$$

The definition of dimension gives $L(s)=D(b,s)L(b)$, and Theorem 3.3 also gives $L(b)=\log P(b)$. Hence

$$
\log P(s)=D(b,s)\log P(b).
$$

Because $P(b)>0$, exponentiation and the definition of real powers yield the claim. $\square$

The theorem does not require coordinatewise pruning. It is an algebraic identity for positive profiles. Pruning becomes relevant when dimension is interpreted as a relative size bounded by one.

**Example 4.2.** Take

$$
b=(2,3,5,2),\qquad s=(1,2,2,2).
$$

Then

$$
P(b)=60,\qquad P(s)=8,
$$

and

$$
D(b,s)=\frac{\log 8}{\log 60}.
$$

The power law becomes

$$
8=60^{\log 8/\log 60}.
$$

Although only $8/60$ of the leaves survive, the dimensional exponent is approximately $0.508$. These are different summaries of the same profile.

## 5. Bounds and monotonicity under pruning

The logarithm is monotone on positive reals. This elementary property converts coordinatewise branch inequalities into global volume inequalities.

**Lemma 5.1 (Monotonicity of logarithmic volume).** Let $s$ and $t$ have the same length. If $1\le s_i\le t_i$ for every $i$, then

$$
L(s)\le L(t).
$$

**Proof sketch.** For each coordinate, positivity and monotonicity give $\log s_i\le\log t_i$. Summing these inequalities proves the result. $\square$

**Theorem 5.2 (Unit-Interval Bound).** If $(b,s)$ is coordinatewise pruned and $L(b)>0$, then

$$
0\le D(b,s)\le 1.
$$

**Proof sketch.** Since $s_i\ge 1$, every term $\log s_i$ is nonnegative, so $L(s)\ge 0$. Lemma 5.1 gives $L(s)\le L(b)$. Dividing

$$
0\le L(s)\le L(b)
$$

by the positive number $L(b)$ proves the two inequalities. $\square$

The lower endpoint occurs when $P(s)=1$, equivalently when every successful branching number is $1$. The upper endpoint occurs whenever $L(s)=L(b)$. Under coordinatewise pruning by positive integers, equality of the sums forces equality at every coordinate, since each difference $\log b_i-\log s_i$ is nonnegative.

**Theorem 5.3 (Monotonicity in successful branching).** Fix an ambient profile $b$ with $L(b)>0$. Let $s$ and $t$ have the same length and satisfy $1\le s_i\le t_i$ for every $i$. Then

$$
D(b,s)\le D(b,t).
$$

**Proof sketch.** Lemma 5.1 gives $L(s)\le L(t)$. Division by the fixed positive denominator $L(b)$ preserves the inequality. $\square$

This theorem supports comparative analysis. Any relaxation of pruning that retains additional viable branches can only increase relative entropy dimension, regardless of where those branches occur. The magnitude of the increase, however, depends on their logarithmic contribution.

## 6. Multiscale composition

Suppose a search consists of two sequential phases. Phase $j$ has ambient profile $b^{(j)}$, successful profile $s^{(j)}$, ambient volume

$$
A_j=L(b^{(j)}),
$$

and dimension

$$
d_j=D(b^{(j)},s^{(j)}).
$$

The concatenated search has ambient profile $b^{(1)}\mathbin{\|}b^{(2)}$ and successful profile $s^{(1)}\mathbin{\|}s^{(2)}$.

**Theorem 6.1 (Multiscale Composition Law).** If $A_1\ne 0$, $A_2\ne 0$, and $A_1+A_2\ne 0$, then

$$
D\!\left(b^{(1)}\mathbin{\|}b^{(2)},
         s^{(1)}\mathbin{\|}s^{(2)}\right)
=
\frac{A_1d_1+A_2d_2}{A_1+A_2}.
$$

Equivalently,

$$
D\!\left(b^{(1)}\mathbin{\|}b^{(2)},
         s^{(1)}\mathbin{\|}s^{(2)}\right)
=
\frac{L(b^{(1)})D(b^{(1)},s^{(1)})
+L(b^{(2)})D(b^{(2)},s^{(2)})}
{L(b^{(1)})+L(b^{(2)})}.
$$

**Proof sketch.** By Theorem 3.1, the successful volume of the concatenation is

$$
L(s^{(1)})+L(s^{(2)}).
$$

Since $L(s^{(j)})=A_jd_j$, the numerator becomes $A_1d_1+A_2d_2$. The ambient volume is $A_1+A_2$, again by additivity. Dividing gives the formula. $\square$

For positive nondegenerate ambient profiles, $A_1$ and $A_2$ are positive, so this is a convex combination. The combined dimension lies between the two phase dimensions.

**Corollary 6.2 (Finite multiphase composition).** For phases indexed by $j=1,\ldots,r$, if every $A_j=L(b^{(j)})>0$, then

$$
D_{\mathrm{total}}
=
\frac{\sum_{j=1}^r A_jd_j}{\sum_{j=1}^r A_j}.
$$

**Proof sketch.** Repeatedly apply Theorem 6.1, or directly use additivity of logarithmic volume across all phase boundaries. $\square$

### 6.1 Why depth weighting fails

Let phase one have profiles

$$
b^{(1)}=(2),\qquad s^{(1)}=(2),
$$

so $d_1=1$. Let phase two have

$$
b^{(2)}=(16),\qquad s^{(2)}=(2),
$$

so $d_2=1/4$. Both phases contain one level. Their unweighted average is

$$
\frac{1+1/4}{2}=\frac{5}{8}.
$$

Yet the concatenated profiles are $b=(2,16)$ and $s=(2,2)$, giving

$$
D(b,s)=\frac{\log 4}{\log 32}=\frac{2}{5}.
$$

The composition theorem gives the same answer because the ambient weights are $\log 2$ and $\log 16=4\log 2$:

$$
\frac{(\log 2)(1)+(4\log 2)(1/4)}{5\log 2}
=\frac{2}{5}.
$$

Unweighted averaging is valid only under additional balance conditions, such as equal ambient logarithmic volumes. Equal phase lengths alone do not suffice.

## 7. Repetition and periodic geometry

**Theorem 7.1 (Repetition Invariance).** Let $k\ge 1$. For any profiles $b$ and $s$ with $L(b)\ne 0$,

$$
D(b^{\| k},s^{\| k})=D(b,s).
$$

**Proof sketch.** Corollary 3.2 gives

$$
L(b^{\| k})=kL(b),\qquad L(s^{\| k})=kL(s).
$$

The common positive factor $k$ cancels in their ratio. $\square$

This scale invariance justifies dimensional language: repeating the same local geometry changes path counts exponentially but leaves the relative exponent fixed.

A periodic binary model is an important special case. Assume an ambient binary tree over a period of $m\ge 1$ levels, so

$$
b=(2,2,\ldots,2).
$$

Let $R$ be the set of levels in the period where both branches remain successful. At every other level, exactly one branch remains. If $r=|R|$, then the successful profile contains $r$ entries equal to $2$ and $m-r$ entries equal to $1$.

**Theorem 7.2 (Periodic Binary Dimension).** In the periodic binary model just described,

$$
D(b,s)=\frac{r}{m}.
$$

**Proof sketch.** The ambient logarithmic volume is $m\log 2$. The successful logarithmic volume is

$$
r\log 2+(m-r)\log 1=r\log 2.
$$

Their ratio is $r/m$. Repetition invariance shows that the same value holds over any positive number of periods. $\square$

This theorem explains when “fraction of branching levels” is a correct dimension formula. It works because every ambient level has identical logarithmic weight. In a nonuniform tree, levels must instead be weighted by $\log b_i$.

## 8. Computational algorithms

### 8.1 Direct profile analysis

Given positive profiles $b$ and $s$ of equal length, the basic analysis computes path counts, logarithmic volumes, and dimension.

**Algorithm 8.1 (Relative Entropy Profile Analysis).**

1. Verify that $b$ and $s$ have equal lengths.
2. Verify $1\le s_i\le b_i$ for every $i$ if a pruned interpretation is required.
3. Accumulate $P(b)=\prod_i b_i$ and $P(s)=\prod_i s_i$ using integer arithmetic.
4. Accumulate $L(b)=\sum_i\log b_i$ and $L(s)=\sum_i\log s_i$ using floating-point or arbitrary-precision arithmetic.
5. Reject the dimension query if $L(b)=0$.
6. Return $D=L(s)/L(b)$.
7. Optionally check numerically that $P(s)$ agrees with $P(b)^D$ within a stated tolerance.

The algorithm uses $O(n)$ arithmetic operations and $O(1)$ auxiliary storage beyond the input. Exact path counts may have $O(n\log B)$ bits when entries are bounded by $B$, so bit complexity grows with the output size. The logarithmic computation avoids overflow and is generally preferable for long profiles.

### 8.2 Multiphase aggregation

When phase dimensions and ambient volumes are already known, concatenated profiles need not be materialized.

**Algorithm 8.2 (Entropy-Weighted Phase Composition).**

1. For each phase $j$, compute $A_j=L(b^{(j)})$ and $d_j=D(b^{(j)},s^{(j)})$.
2. Accumulate total ambient volume $A=\sum_j A_j$.
3. Accumulate successful volume in factored form $S=\sum_j A_jd_j$.
4. If $A=0$, report that the total dimension is undefined.
5. Return $S/A$.

This requires $O(r)$ time and $O(1)$ auxiliary space for $r$ phases. It is numerically transparent and reveals each phase's influence through its normalized weight $A_j/A$.

### 8.3 Bottleneck ranking

For a coordinatewise-pruned phase $j$, define its **entropy deficit** by

$$
\Delta_j=L(b^{(j)})-L(s^{(j)})=A_j(1-d_j).
$$

This quantity is the logarithm of the ratio between ambient and successful path counts:

$$
\Delta_j=\log\frac{P(b^{(j)})}{P(s^{(j)})}.
$$

Ranking phases by $\Delta_j$ identifies where the greatest multiplicative pruning occurs. Computing all deficits requires linear time in the total number of profile entries. Dimension and deficit answer complementary questions: dimension is normalized and scale-comparable, while deficit records absolute lost logarithmic volume.

## 9. Applications

### 9.1 Staged derivation and planning

A complex derivation often passes through qualitatively different stages: selecting a representation, applying transformations, discharging constraints, and simplifying the result. The composition theorem assigns each stage a contribution proportional to the number of ambient bits or nats it contains. A short stage with very high branching can dominate many low-branching stages.

In planning, $b_i$ can count admissible actions and $s_i$ actions compatible with eventual goal reachability under a product-profile abstraction. Low $D$ indicates severe relative pruning. Large entropy deficit identifies a stage where guidance or constraint propagation has the greatest absolute opportunity to reduce wasted exploration.

### 9.2 Hierarchical configuration spaces

Product configuration systems choose components, parameters, and interfaces in successive layers. Compatibility constraints reduce the number of choices that can participate in a complete design. Relative entropy dimension summarizes the exponent of compatible configurations relative to all nominal configurations. Reordering independent layers does not change the sums, while grouping them into phases changes only the presentation, not the total dimension.

### 9.3 Constrained symbolic languages

A finite word can be generated one symbol position at a time. If $b_i$ is the alphabet size available at position $i$ and $s_i$ the number of locally extensible symbols under a levelwise product model, then $D$ measures constrained language growth relative to unconstrained growth. More general languages have dependencies between positions; there, scalar products should be replaced by submultiplicative counts or matrix growth, as discussed below.

### 9.4 Diagnostic comparison of pruning regimes

Suppose two filters act on the same ambient profile. If one retains at least as many branches at every level, Theorem 5.3 orders their dimensions immediately. When coordinatewise ordering fails, the logarithmic sums still permit comparison. This matters because a filter may prune more at many low-information levels yet prune less at one high-information level.

## 10. Interpretation and limitations

The profile model assumes that the number of complete paths factors as the product of levelwise branching numbers. This is exact for spherically homogeneous rooted trees and for profile abstractions in which every surviving prefix at a given level has the same number of next extensions. It is not an exact representation of every irregular tree. If nodes at the same depth have different branching, one must refine the state description, use total prefix counts, or pass to matrix and submultiplicative methods.

Dimension also does not determine discovery time. A traversal policy imposes an ordering on nodes. Two trees can have identical successful-prefix counts and hence identical geometric dimension, while a depth-first traversal finds a target early in one ordering and late in another. Dimension measures abundance, not location in an enumeration.

Nor does finite profile dimension by itself assert an asymptotic Hausdorff dimension. A genuine Hausdorff statement requires an infinite boundary, a metric—typically an ultrametric based on common-prefix length—and limiting control of covering counts. The finite formulas supply the expected normalization and exact identities for periodic repetition, but additional hypotheses are needed for arbitrary infinite systems.

Finally, unary ambient profiles have zero logarithmic volume. Their relative dimension is undefined because there is no ambient combinatorial growth. Unary levels can safely occur inside a larger nondegenerate profile; they simply contribute zero weight.

## 11. Discussion

The theory can be viewed simultaneously in three languages.

In combinatorics, $P(a)$ counts leaves of a nonstationary product tree. In information theory, $L(a)$ is the additive information volume generated by its choices. In fractal geometry, $D(b,s)$ is the exponent relating successful and ambient counts.

These viewpoints meet in the entropy power law. The equation

$$
P(s)=P(b)^{D(b,s)}
$$

says that dimension is exactly the relative growth exponent at finite scale. The composition theorem then follows from the additivity of information. It is structurally analogous to combining rates over channels or averaging intensive quantities with extensive weights: the normalized quantity cannot be averaged correctly until its denominator has been restored.

This perspective clarifies why a naive mean can fail. A phase dimension is an intensive ratio. Ambient logarithmic volume is its extensive scale. Multiplying them recovers successful logarithmic volume; these recovered volumes add; division by total ambient volume renormalizes the sum.

The repetition theorem provides a consistency check. A dimensional statistic should not change merely because the same block is observed at a larger repeated scale. Both numerator and denominator are extensive, so their ratio is invariant.

## 12. Future work

The exact finite product model suggests several generalizations.

First, for a successful language with prefix count $N(n)$ satisfying

$$
N(n+m)\le N(n)N(m),
$$

$\log N(n)$ is subadditive. One expects the normalized logarithmic growth rate to exist as an infimum of finite-scale rates. Under suitable extension and metric hypotheses, that rate should agree with the Hausdorff dimension of the infinite successful boundary.

Second, stationary ergodic branching pairs $(B_n,S_n)$ with $1\le S_n\le B_n$ suggest the almost-sure limit

$$
\frac{\mathbb{E}[\log S_0]}{\mathbb{E}[\log B_0]}.
$$

Here logarithmic volumes become additive random cocycles, and ergodic averaging should replace finite summation.

Third, finite-state pruning introduces dependencies. For a strongly connected automaton over a fixed $b$-ary tree, scalar successful branching is replaced by powers of a nonnegative transition matrix $A$. The predicted dimension is

$$
\frac{\log\rho(A)}{\log b},
$$

where $\rho(A)$ is the spectral radius.

Fourth, geometry should be separated systematically from policy-sensitive cost. At fixed dimension, adversarial rearrangement of successful nodes may produce arbitrarily different deterministic discovery costs. Establishing sharp separation theorems would prevent dimension from being mistaken for runtime.

Fifth, stability under sparse perturbations should be investigated. If two long profiles differ on a set of levels with vanishing logarithmic density and branching is suitably controlled, their limiting relative entropy dimensions should often agree. Precise hypotheses must account for rare but extremely high-branching levels.

## 13. Conclusion

Nonstationary branching profiles admit an exact and compositional dimension theory. Path counts multiply, logarithmic volumes add, and their ratio measures successful information growth relative to ambient information growth. Under pruning, the dimension lies in $[0,1]$ and increases with retained branching. Across sequential phases, dimensions combine by ambient-entropy weighting, not by depth. Repetition preserves the ratio, and periodic binary geometries reduce to the familiar fraction of levels where both branches survive.

The framework is finite, elementary, and exact. Its main conceptual lesson is that levels of a search tree do not contribute equally merely because each occupies one step. Their proper weights are the logarithms of their branching numbers. Once those weights are recognized, nonstationary search acquires a coherent geometry.