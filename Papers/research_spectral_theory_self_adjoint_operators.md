# Affine Rerandomization, Noise Budgets, and Quarter-Modulus Decoding in Learning with Errors

**Author:** Aristotle  
**Date:** July 25, 2026

## Abstract

This paper develops a self-contained collection of algebraic and analytic results underlying elementary search-to-decision and correctness arguments for Learning with Errors cryptography. Over a prime residue field, every affine transformation $x\mapsto ax+b$ with $a\ne0$ is a bijection; it therefore preserves uniform distributions and finite sums. Bounded additive errors accumulate at most linearly, both for complete families and selected subsets. For the standard binary encoding with centers $0$ and $q/2$, any perturbation of magnitude strictly below $q/4$ remains in the correct decoding region, and two independently perturbed codewords retain a positive separation. A hybrid decomposition across $n$ coordinates guarantees a coordinate gap of at least one $n$th of the total distinguishing advantage. We combine these facts with an additive modulus-switching budget, an independent-repetition amplification formula, and a modulus-noise parameter inequality. The resulting framework makes explicit the hypotheses—especially positivity of the modulus—needed for valid rounding and separation statements, and supplies direct algorithms and numerical diagnostics for parameter selection.

## 1. Introduction

Learning with Errors (LWE) replaces exact linear equations over a finite residue system by equations containing small additive disturbances. If a secret vector is $s$, a typical sample consists schematically of a public vector $a$ and a value resembling $\langle a,s\rangle+e$ modulo a modulus, where $e$ is a small error. The error frustrates direct linear-algebraic recovery, while legitimate cryptographic procedures preserve enough geometric separation to decode intended messages.

Two kinds of reasoning recur in this setting. The first is exact finite algebra. Multiplication by a nonzero element in a prime field and addition of a constant are permutations. Consequently, affine rerandomization does not introduce statistical bias. The second is quantitative real or integer analysis. Triangle inequalities bound accumulated noise; interval inequalities certify decoding; and averaging arguments identify a useful coordinate in a hybrid sequence.

The aim here is to present these components as one transparent mathematical package. The central results are deliberately elementary, but their assumptions matter. In particular, a statement involving an “error smaller than $q/4$” does not itself imply that $q$ is positive in every formulation. Positivity is required when deriving the interval occupied by a noisy encoding of $1$ or a positive separation between two noisy codewords. We therefore state $q>0$ explicitly wherever the order argument needs it.

The paper proceeds from affine maps over prime residue fields to deterministic noise accumulation, binary rounding, hybrid advantages, modulus switching, amplification, and parameter tradeoffs. Each theorem includes a proof sketch. We then give algorithms whose outputs serve as executable diagnostics rather than substitutes for the mathematical guarantees.

## 2. Algebraic setting

### 2.1 Prime residue fields

Let $p$ be prime, and write $\mathbb{Z}_p$ for the residues modulo $p$. Addition and multiplication are taken modulo $p$. Because $p$ is prime, $\mathbb{Z}_p$ is a field: each $a\ne0$ has a unique multiplicative inverse $a^{-1}$.

An **affine map** with multiplier $a$ and offset $b$ is the function $A_{a,b}:\mathbb{Z}_p\to\mathbb{Z}_p$ defined by

$$
A_{a,b}(x)=ax+b.
$$

A function is **bijective** if it is both injective and surjective. On a finite set, injectivity and surjectivity are equivalent, though explicit inverses will be available here.

### Theorem 2.1 (Nonzero multiplication is a permutation)

Let $p$ be prime and $a\in\mathbb{Z}_p$ satisfy $a\ne0$. Then $x\mapsto ax$ is a bijection of $\mathbb{Z}_p$.

**Proof sketch.** If $ax=ay$, multiply both sides by $a^{-1}$ to obtain $x=y$, proving injectivity. Since the domain and codomain are the same finite set, the map is bijective. Equivalently, every $y$ has the unique preimage $a^{-1}y$.

### Theorem 2.2 (Affine permutation theorem)

Let $p$ be prime, $a,b\in\mathbb{Z}_p$, and $a\ne0$. Then $A_{a,b}$ is a bijection, with inverse

$$
A_{a,b}^{-1}(y)=a^{-1}(y-b).
$$

**Proof sketch.** Multiplication by $a$ is bijective by Theorem 2.1, and translation by $b$ is bijective with inverse translation by $-b$. Their composition is bijective. Direct substitution verifies the inverse formula.

### Proposition 2.3 (Composition law)

For arbitrary $a_1,b_1,a_2,b_2\in\mathbb{Z}_p$,

$$
A_{a_1,b_1}\circ A_{a_2,b_2}
=A_{a_1a_2,\,a_1b_2+b_1}.
$$

**Proof sketch.** Expand $a_1(a_2x+b_2)+b_1$ and use associativity and distributivity.

### Corollary 2.4 (Affine image and sum invariance)

Under the hypotheses of Theorem 2.2, the image of $\mathbb{Z}_p$ under $A_{a,b}$ is all of $\mathbb{Z}_p$. Moreover, for every function $f:\mathbb{Z}_p\to\mathbb{R}$,

$$
\sum_{x\in\mathbb{Z}_p}f(ax+b)=\sum_{y\in\mathbb{Z}_p}f(y).
$$

**Proof sketch.** The image claim is surjectivity. For the sum, relabel the index $y=A_{a,b}(x)$. Bijectivity ensures that each residue occurs exactly once.

This corollary also proves distributional invariance: if $X$ is uniform on $\mathbb{Z}_p$, then $aX+b$ is uniform. Indeed, every output has exactly one preimage of probability $1/p$.

## 3. Deterministic accumulation of bounded noise

Let $I$ be a finite index set and let $e_i$ denote additive errors. The only analytic tool needed for worst-case accumulation is the triangle inequality.

### Theorem 3.1 (Full-family noise accumulation)

Let $e_1,\ldots,e_m$ be integers, and suppose $|e_i|\le B$ for every $i$. Then

$$
\left|\sum_{i=1}^{m}e_i\right|\le mB.
$$

The same conclusion holds for real-valued errors and a real bound $B$.

**Proof sketch.** Apply the triangle inequality and then the individual bounds:

$$
\left|\sum_i e_i\right|\le\sum_i|e_i|\le\sum_iB=mB.
$$

The hypotheses imply $B\ge0$ whenever the family is nonempty, so the right side is a meaningful nonnegative ceiling.

### Theorem 3.2 (Subset noise accumulation)

Let $S\subseteq\{1,\ldots,m\}$ and suppose $|e_i|\le B$ for all $i$. Then

$$
\left|\sum_{i\in S}e_i\right|\le |S|B.
$$

**Proof sketch.** Repeat the proof of Theorem 3.1 using only indices in $S$. The number of constant terms in the final sum is $|S|$.

The bounds are sharp as worst-case statements: if every selected error equals $B\ge0$, equality holds. They do not claim that typical independent centered errors have magnitude proportional to $m$; probabilistic cancellation can improve average behavior. Their role is to certify correctness for every admissible error vector.

## 4. Quarter-modulus binary decoding

Let $q>0$ be a real modulus used to describe decoding intervals. Encode a binary message $\mu\in\{0,1\}$ at the center

$$
c_\mu=\mu\frac q2.
$$

Thus $c_0=0$ and $c_1=q/2$. A received representative has the form $c_\mu+e$. Modulo $q$, nearest-center decoding chooses whichever of $0$ and $q/2$ is closer on the circle of circumference $q$.

### Lemma 4.1 (Noisy zero interval)

If $|e|<q/4$, then

$$
-\frac q4<e<\frac q4.
$$

**Proof sketch.** The equivalence $|e|<r$ if and only if $-r<e<r$ applies with $r=q/4$. The hypothesis itself forces $q/4>0$; we nevertheless maintain $q>0$ globally for a coherent modulus interpretation.

### Theorem 4.2 (Noisy one interval)

Let $q>0$. If $|e|<q/4$, then

$$
\frac q4<\frac q2+e<\frac{3q}{4}.
$$

**Proof sketch.** From $|e|<q/4$ obtain $-q/4<e<q/4$. Adding $q/2$ throughout yields the stated interval. Both endpoints simplify by elementary arithmetic.

### Theorem 4.3 (Positive separation of perturbed codewords)

Let $q>0$, and suppose $|e|<q/4$ and $|e'|<q/4$. Then

$$
\frac q2-|e|-|e'|>0.
$$

In particular, an encoding of $0$ perturbed by $e$ and an encoding of $1$ perturbed by $e'$ cannot be forced together by perturbations of these magnitudes.

**Proof sketch.** Add the two strict inequalities to obtain $|e|+|e'|<q/2$, then rearrange. Positivity of $q$ makes the permitted bounds consistent and the resulting gap meaningful.

### Theorem 4.4 (Translation-invariant rounding correctness)

Let $q>0$, let $\mu\in\mathbb{R}$, and suppose $|e|<q/4$. Then

$$
\left|\mu\frac q2+e-\mu\frac q2\right|<\frac q4.
$$

**Proof sketch.** The two center terms cancel, leaving $|e|$. For binary $\mu$, Theorems 4.1 and 4.2 additionally locate the received point in the appropriate decoding interval.

The strict inequality is important. At exactly $|e|=q/4$, a received point can lie on a decision boundary and nearest-center decoding may face a tie. Correctness therefore requires a tie-breaking convention or, more simply, the strict safety margin used above.

## 5. Hybrid decomposition and coordinate advantage

A hybrid argument connects two distributions through a sequence of intermediate distributions, often changing one secret coordinate at each step. Let $g_i$ denote a real-valued contribution or gap associated with coordinate $i$. No nonnegativity assumption on every $g_i$ is needed for the averaging theorem below; only a lower bound on their sum matters.

### Theorem 5.1 (Coordinate advantage bound)

Let $n$ be a positive integer. Let $g_1,\ldots,g_n\in\mathbb{R}$ and $\varepsilon\in\mathbb{R}$ satisfy

$$
\varepsilon\le\sum_{i=1}^{n}g_i.
$$

Then there exists an index $i$ such that

$$
g_i\ge\frac{\varepsilon}{n}.
$$

**Proof sketch.** Assume to the contrary that every $g_i<\varepsilon/n$. Summing the strict inequalities gives

$$
\sum_i g_i<n\frac{\varepsilon}{n}=\varepsilon,
$$

contradicting the assumed lower bound. The condition $n>0$ is needed to divide by $n$ and to ensure there is an index.

### Corollary 5.2 (Search signal from decision signal)

If a decision procedure yields total distinguishing gap at least $\varepsilon$ across an $n$-coordinate hybrid decomposition, then some coordinate contributes gap at least $\varepsilon/n$.

**Proof sketch.** Apply Theorem 5.1 to the coordinate gaps. In a prime-modulus rerandomization step, Theorem 2.2 supplies the exact permutation property needed to preserve uniformity for transformed wrong guesses.

This result is an existence guarantee. An algorithm may evaluate all coordinate candidates and select a maximal empirical gap. The theorem says the best true gap cannot lie below $\varepsilon/n$ when the decomposition inequality holds.

## 6. Modulus switching and correctness budgets

Modulus switching introduces rounding errors in addition to the original LWE error. Let $e_{\mathrm{LWE}}\in\mathbb{R}$ satisfy $|e_{\mathrm{LWE}}|\le B$. Let $r_1,\ldots,r_n$ be rounding errors satisfying $|r_i|\le\delta$.

### Theorem 6.1 (Combined switching-noise bound)

Under these assumptions,

$$
\left|e_{\mathrm{LWE}}+\sum_{i=1}^{n}r_i\right|
\le B+n\delta.
$$

**Proof sketch.** First apply the two-term triangle inequality:

$$
\left|e_{\mathrm{LWE}}+\sum_i r_i\right|
\le |e_{\mathrm{LWE}}|+\left|\sum_i r_i\right|.
$$

Bound the first term by $B$ and the second by Theorem 3.1.

### Corollary 6.2 (Correctness after modulus switching)

If, in addition,

$$
B+n\delta<\frac q4,
$$

then

$$
\left|e_{\mathrm{LWE}}+\sum_{i=1}^{n}r_i\right|<\frac q4.
$$

Hence the combined disturbance remains within the quarter-modulus decoding radius.

**Proof sketch.** Chain the weak inequality of Theorem 6.1 with the strict budget inequality. The condition also implies $q>0$ whenever the other bounds are nonnegative and feasible.

The expression $B+n\delta$ is a compositional interface: one stage need not know the signs of errors produced by another. It needs only a magnitude certificate. This modularity is valuable when parameters are selected across several cryptographic operations.

## 7. Independent repetition and parameter scaling

### Theorem 7.1 (Independent success amplification)

Let $0\le p\le1$, and let $k$ be a positive integer. For $k$ independent trials, each succeeding with probability $p$, the probability of at least one success is

$$
P_k=1-(1-p)^k,
$$

and

$$
p\le P_k.
$$

**Proof sketch.** All trials fail with probability $(1-p)^k$, giving the formula by complementation. Since $0\le1-p\le1$ and $k\ge1$, one has $(1-p)^k\le1-p$. Subtracting from $1$ yields $P_k\ge p$.

The theorem does not assert independence when none is present; independence is exactly what justifies multiplying failure probabilities. It also gives a conservative monotonicity fact rather than a prescribed repetition count. For a target failure probability $\eta$, one may choose $k$ so that $(1-p)^k\le\eta$.

### Theorem 7.2 (Modulus-noise tradeoff)

Let $n$ be a nonnegative integer and let $q>0$. If $\alpha\in\mathbb{R}$ satisfies

$$
\frac{2\sqrt n}{q}\le\alpha,
$$

then

$$
2\sqrt n\le\alpha q.
$$

**Proof sketch.** Multiply the assumed inequality by the positive quantity $q$, which preserves its direction. The converse follows by division by $q$, so these two parameter conditions are equivalent when $q>0$.

## 8. Algorithms

### 8.1 Affine uniformity audit

Given a candidate prime modulus $p$, multiplier $a$, and offset $b$, enumerate $(ax+b)\bmod p$ for all residues $x$. Reject $a\equiv0\pmod p$ and check that every residue occurs exactly once. Enumeration costs $O(p)$ time and $O(p)$ memory if the image is stored. For a known prime $p$, a faster symbolic audit checks only $a\not\equiv0\pmod p$ and then invokes Theorem 2.2, requiring arithmetic logarithmic in $p$ under standard integer representations.

### 8.2 Noise-budget certification

Given $q$, an original bound $B$, dimension $n$, and per-coordinate rounding bound $\delta$, compute

$$
M=B+n\delta
$$

and accept the parameter set exactly when $M<q/4$. This takes constant arithmetic time once the summary bounds are known. If raw errors are supplied, verifying all $n$ coordinate bounds takes $O(n)$ time.

### 8.3 Coordinate-gap selection

Given gaps $g_1,\ldots,g_n$ and a claimed total $\varepsilon$, first verify $\varepsilon\le\sum_i g_i$. Then return an index maximizing $g_i$. A single scan takes $O(n)$ time and $O(1)$ auxiliary memory. Theorem 5.1 guarantees the returned gap is at least $\varepsilon/n$.

### 8.4 Repetition planning

For $0<p<1$ and target failure bound $0<\eta<1$, choose

$$
k=\left\lceil\frac{\log\eta}{\log(1-p)}\right\rceil.
$$

Both logarithms are negative, so the ratio is positive. The resulting independent failure probability is at most $\eta$. Boundary cases are handled separately: if $p=1$, one trial suffices; if $p=0$, repetition cannot create success.

## 9. Numerical examples

Take $p=17$, $a=5$, and $b=8$. Enumerating $5x+8$ modulo $17$ produces

$$
8,13,1,6,11,16,4,9,14,2,7,12,0,5,10,15,3,
$$

which contains every residue exactly once. This is a concrete affine permutation.

For $q=128$, the quarter-modulus radius is $32$. Encoding bit $0$ with error $19$ gives $19$, still inside the zero region. Encoding bit $1$ with error $-23$ gives $64-23=41$, which lies between $32$ and $96$ and therefore remains in the one region.

Suppose the original switching error is $4$, while four rounding errors are $0.5,-0.25,0.75,0.1$. If each rounding magnitude is bounded by $0.75$, the deterministic budget is

$$
4+4(0.75)=7<32.
$$

The actual combined signed error is $5.1$, also below $32$. The discrepancy between $7$ and $5.1$ reflects cancellation that the worst-case theorem intentionally does not assume.

Let four coordinate gaps be $0.01,0.025,0.04,0.015$, whose sum is $0.09$. If the certified total gap is $\varepsilon=0.08$, the theorem guarantees some coordinate gap of at least $0.02$. The maximal observed value $0.04$ meets that guarantee.

Finally, if a trial succeeds with probability $0.18$, eight independent repetitions succeed at least once with probability

$$
1-(0.82)^8\approx0.796.
$$

This illustrates how a modest individual advantage can become operationally useful, provided independence is justified.

## 10. Applications and limitations

The affine permutation theorem supports exact rerandomization arguments over prime moduli. Its prime assumption may be weakened to the requirement that $a$ be a unit for a general composite modulus; a merely nonzero multiplier need not be invertible there. Thus prime moduli provide a convenient condition under which every nonzero guess multiplier works.

The quarter-modulus theorems establish correctness of a scalar binary rounding layer. They do not by themselves prove a complete encryption scheme secure, specify an error distribution, or analyze wraparound in every representation. Those tasks require connecting the scalar representative to the scheme's full ciphertext algebra. What these theorems provide is the central interval certificate once the ciphertext phase has been reduced to an intended center plus additive error.

Similarly, the hybrid theorem is an averaging principle, not a complete search-to-decision reduction. A full reduction must define the hybrids, prove the total-gap decomposition, construct each coordinate test, and account for sampling error and running time. The result here isolates the exact quantitative loss once those ingredients are available.

Worst-case accumulation is often conservative. If errors are independent and subgaussian, concentration inequalities can replace $n\delta$ by a scale closer to $\sqrt n$ with a controlled failure probability. Deterministic and probabilistic bounds answer different questions: the former certifies all admissible errors, while the latter gives tighter performance outside a small exceptional event.

## 11. Discussion

The framework reveals a useful separation of responsibilities. Algebra handles distributions: permutations preserve exact uniformity, and affine composition keeps transformations tractable. Analysis handles correctness: absolute values turn signed errors into budgets, while strict inequalities keep received values away from decision boundaries. Combinatorics handles reduction losses: a sum of coordinate contributions must contain one contribution at least as large as the average. Probability handles operational boosting through independent repetition.

Explicit positivity assumptions are not cosmetic. Multiplying or dividing inequalities by $q$ depends on the sign of $q$, and the interval $(q/4,3q/4)$ represents the intended neighborhood of $q/2$ only for $q>0$. Parameter statements should therefore carry the semantic constraints needed by their proofs rather than relying on an informal understanding that a modulus is positive.

A second lesson concerns interfaces. The combined-noise theorem consumes only bounds $B$ and $\delta$, not the internal origin of either error. The coordinate theorem consumes only a lower bound on a sum, not the detailed construction of the hybrids. Such interfaces permit components to be improved independently: a sharper rounding analysis can reduce $\delta$, while the correctness theorem remains unchanged.

## 12. Future work

Several extensions follow naturally. Composite moduli can be treated by replacing nonzero multipliers with units and tracking the image size of nonunits. Probabilistic noise models can supplement deterministic budgets with tail bounds. Full search-to-decision constructions can instantiate the abstract coordinate gaps and quantify oracle calls. More realistic modulus-switching analyses can account for vector norms, matrix dimensions, and correlated rounding.

At a broader mathematical level, future work may also investigate extremal Rayleigh principles and the Courant–Fischer hierarchy, compact self-adjoint operators with discrete spectra and multiplicities, continuous and Borel functional calculi, projection-valued measures, and quantum-mechanical notions such as variance, uncertainty, commuting observables, and measurement probabilities. These spectral directions are logically separate from the finite-field and LWE results developed here, but share the general goal of turning structural mathematics into explicit quantitative guarantees.

## 13. Reproducibility of numerical diagnostics

The numerical procedures associated with these results use only exact modular integer arithmetic and elementary floating-point evaluations. An affine audit enumerates all residues and compares the image cardinality with $p$. A decoder reduces a received representative modulo $q$, computes its circular distance from $0$ and its ordinary distance from $q/2$, and chooses the smaller. A switching audit reports both the signed realized error and the worst-case budget $B+n\delta$ so that accidental cancellation is never confused with a guarantee.

For robust use, implementations should reject $q\le0$, empty coordinate lists in the hybrid selector, probabilities outside $[0,1]$, and multipliers congruent to zero modulo $p$. Floating-point demonstrations near $q/4$ should include a tolerance or use rational arithmetic, because binary floating-point can blur strict boundaries. These checks correspond directly to the mathematical hypotheses rather than being incidental software conventions.

The diagnostics have linear complexity in the natural input size when raw vectors are inspected. They are intended to expose parameter relationships and counterexamples to malformed inputs. They do not establish primality, independence, or distributional assumptions unless dedicated checks are added. Thus the computational layer preserves the same division of responsibility as the theory: exact structural assumptions enter explicitly, and quantitative conclusions follow only after those assumptions are certified.


## 14. Conclusion

Prime-field affine maps, deterministic noise bounds, quarter-modulus separation, hybrid averaging, switching budgets, and repetition amplification form a concise mathematical toolkit for noisy cryptographic reasoning. The central correctness condition is especially simple: two binary centers separated by $q/2$ remain distinguishable when perturbations stay strictly below $q/4$. Around this geometric fact, exact algebra preserves uniformity and elementary inequalities account for every loss. The result is a modular chain of arguments in which each hypothesis has a visible role and each parameter can be audited numerically.
