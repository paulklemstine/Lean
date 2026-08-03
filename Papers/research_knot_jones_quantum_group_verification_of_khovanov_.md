# The Graded Euler State Sum Underlying Khovanov Categorification

**Aristotle**  
**August 3, 2026**

## Abstract

For a finite link diagram, the cube of resolutions replaces every crossing by an $A$- or $B$-smoothing. Enhancing each resulting circle by one of two basis labels of quantum degrees $+1$ and $-1$ produces the generator set underlying the Khovanov cube. We prove directly that the signed graded enumeration of these generators is exactly the Jones state sum in the normalization

$$
J_D(q)=\sum_s(-1)^{b(s)}q^{a(s)-b(s)}(q+q^{-1})^{\ell(s)}.
$$

The decisive finite identity is that the quantum monomials of all binary enhancements of $m$ circles sum to $(q+q^{-1})^m$. Grouping enhanced generators by their smoothing state then yields the result term by term. For oriented diagrams, multiplication by the writhe factor $q^{-3w(D)}$ gives equality of the corresponding normalized expressions. The crossingless unknot evaluates to $q+q^{-1}$. We also describe direct and compressed algorithms for the calculation, analyze their complexity, and clarify precisely how this generator-level identity fits into the broader program of constructing Khovanov homology.

## 1. Introduction

The Jones polynomial and Khovanov homology are connected by categorification: the polynomial is recovered as a graded Euler characteristic of richer algebraic data. At the combinatorial foundation of that statement lies a finite identity. A link diagram with $n$ crossings has $2^n$ smoothing states. A state resolves into circles; each circle can carry either of two homogeneous labels. The resulting enhanced states possess a homological degree and a quantum degree. Their signed quantum generating function reproduces a Jones state sum.

The purpose of this paper is to isolate and prove that identity for arbitrary finite combinatorial link diagrams. The argument is elementary but structurally important. It separates three ingredients:

1. the cube of $A$- and $B$-smoothings, which supplies the homological sign and a quantum shift;
2. a rank-two graded labeling on each circle, which supplies the factor $q+q^{-1}$;
3. the writhe of an oriented diagram, which supplies a global normalization factor.

This separation prevents an ambiguity common in informal summaries of categorification. The calculation here establishes equality between the graded Euler sum of cube generators and the associated Jones state sum. To pass from generators to homology one additionally constructs chain groups and a differential, proves that the differential squares to zero, and proves preservation of graded Euler characteristic under homology. To establish link invariance at chain level one further constructs the maps and homotopies corresponding to Reidemeister moves. Those later structures are motivated by, but logically distinct from, the finite theorem proved here.

All sums below are finite. We work in the Laurent polynomial ring $\mathbb Z[q,q^{-1}]$, whose elements are finite integer linear combinations of monomials $q^k$ with $k\in\mathbb Z$.

## 2. Combinatorial diagrams and smoothing states

### 2.1. Link diagrams

A **finite combinatorial link diagram** $D$ consists of planar diagrammatic data with a finite ordered set of crossings. Only the smoothing information and the number of circles produced by each complete smoothing are needed for the present calculation. Let $n$ denote the number of crossings.

At every crossing there are two local resolutions, called the **$A$-smoothing** and the **$B$-smoothing**. A **smoothing state** is a function

$$
s:\{1,\ldots,n\}\longrightarrow\{A,B\}.
$$

Thus the set of smoothing states is naturally the vertex set of an $n$-dimensional cube and has cardinality $2^n$.

For a smoothing state $s$, define

$$
a(s)=\#\{i:s(i)=A\},\qquad b(s)=\#\{i:s(i)=B\}.
$$

Necessarily $a(s)+b(s)=n$. After applying all local smoothings, the diagram becomes a finite disjoint union of circles. Denote their number by $\ell_D(s)$, or simply $\ell(s)$ when $D$ is fixed.

### 2.2. Enhanced states

Let $V$ be a two-element homogeneous basis $\{v_+,v_-\}$ with degrees

$$
\deg(v_+)=1,\qquad \deg(v_-)=-1.
$$

An **enhancement** of a state $s$ assigns either $v_+$ or $v_-$ to every one of its $\ell(s)$ circles. An **enhanced state**, or cube generator, is a pair $g=(s,e)$ comprising a smoothing state and an enhancement. A state with $m$ circles has exactly $2^m$ enhancements.

The **enhancement degree** is the sum of the circle-label degrees:

$$
\delta(e)=\sum_{C}\deg(e(C)),
$$

where $C$ ranges over the circles of the smoothing. Equivalently, if $p(e)$ and $r(e)$ are the numbers of positive and negative labels, then

$$
\delta(e)=p(e)-r(e)=2p(e)-\ell(s).
$$

### 2.3. Bigrading

The **homological degree** and **quantum degree** of an enhanced state $g=(s,e)$ are

$$
i(g)=b(s)
$$

and

$$
j(g)=a(s)-b(s)+\delta(e),
$$

respectively. The first records the height of $s$ in the smoothing cube. The second combines a smoothing-dependent shift with the degrees of the circle labels.

### 2.4. Two Laurent-polynomial sums

The **graded Euler sum of cube generators** is

$$
\chi_q(D)=\sum_{g}(-1)^{i(g)}q^{j(g)},
$$

where $g$ ranges over all enhanced states of $D$.

The **Jones state sum in the cube normalization** is

$$
J_D(q)=\sum_s(-1)^{b(s)}q^{a(s)-b(s)}(q+q^{-1})^{\ell(s)},
$$

where $s$ ranges over all smoothing states.

Both definitions are finite. The first enumerates every enhancement explicitly. The second has already compressed all enhancements belonging to one smoothing into a power of $q+q^{-1}$. The main theorem states that these descriptions agree.

## 3. The enhancement polynomial

The only nontrivial combinatorial input is the generating function of binary labels.

### Lemma 3.1 (First-circle decomposition)

Let $e$ be an enhancement of $m+1$ ordered circles. Write $b$ for the label of the first circle and $e'$ for the induced enhancement of the remaining $m$ circles. Then

$$
\delta(e)=\deg(b)+\delta(e').
$$

Conversely, every pair consisting of one label $b\in\{v_+,v_-\}$ and an enhancement $e'$ of $m$ circles determines a unique enhancement of $m+1$ circles.

**Proof sketch.** The correspondence is obtained by restricting an enhancement to the first circle and its complement; the inverse prepends the selected first label. Since enhancement degree is defined as a sum over circles, separating its first summand gives the displayed equality. The two operations are mutually inverse.

### Theorem 3.2 (Binary Enhancement Theorem)

For every integer $m\ge 0$, the sum of the quantum monomials over all enhancements of $m$ circles is

$$
E_m(q):=\sum_e q^{\delta(e)}=(q+q^{-1})^m.
$$

**Proof sketch.** Induct on $m$. For $m=0$, there is one empty enhancement, its degree is $0$, and therefore $E_0(q)=1$. Suppose the identity holds for $m$. By Lemma 3.1, enhancements of $m+1$ circles are uniquely pairs of a first label and an enhancement of the remaining circles. Additivity of the degree gives

$$
\begin{aligned}
E_{m+1}(q)
&=\sum_{e'}\left(q^{1+\delta(e')}+q^{-1+\delta(e')}\right)\\
&=(q+q^{-1})\sum_{e'}q^{\delta(e')}\\
&=(q+q^{-1})E_m(q)\\
&=(q+q^{-1})^{m+1}.
\end{aligned}
$$

This completes the induction.

### Corollary 3.3 (Coefficient formula)

For $m\ge 0$,

$$
E_m(q)=\sum_{r=0}^m\binom mr q^{2r-m}.
$$

In particular, the coefficient of $q^k$ is zero unless $|k|\le m$ and $k\equiv m\pmod 2$; in the remaining cases it is

$$
\binom{m}{(m+k)/2}.
$$

**Proof sketch.** Group enhancements by the number $r$ of circles labeled $v_+$. There are $\binom mr$ such enhancements, and each has degree $r-(m-r)=2r-m$. Summing these contributions gives the formula. The coefficient statement follows by solving $k=2r-m$.

### Corollary 3.4 (Symmetry)

The enhancement polynomial is invariant under $q\mapsto q^{-1}$:

$$
E_m(q^{-1})=E_m(q).
$$

**Proof sketch.** Interchanging $v_+$ and $v_-$ negates every enhancement degree and is a bijection on the set of enhancements. Equivalently, $(q^{-1}+q)^m=(q+q^{-1})^m$.

The theorem may also be viewed as multiplicativity of graded dimension. One circle carries a graded two-dimensional object with graded dimension $q+q^{-1}$. Independent labels on $m$ circles correspond at the level of bases to an $m$-fold tensor product, whose graded dimension is the $m$th power.

## 4. Equality of the two state sums

### Theorem 4.1 (Graded Euler–Jones State-Sum Theorem)

For every finite combinatorial link diagram $D$,

$$
\chi_q(D)=J_D(q).
$$

Explicitly,

$$
\sum_{(s,e)}(-1)^{b(s)}q^{a(s)-b(s)+\delta(e)}
=
\sum_s(-1)^{b(s)}q^{a(s)-b(s)}(q+q^{-1})^{\ell(s)}.
$$

**Proof sketch.** The finite set of enhanced states is the disjoint union, over smoothing states $s$, of the enhancement sets of $s$. Hence the left side may be regrouped as

$$
\chi_q(D)=\sum_s\sum_e
(-1)^{b(s)}q^{a(s)-b(s)+\delta(e)}.
$$

For a fixed state $s$, the factors $(-1)^{b(s)}$ and $q^{a(s)-b(s)}$ do not depend on $e$. The multiplicative law $q^{x+y}=q^xq^y$ therefore gives

$$
\chi_q(D)
=\sum_s(-1)^{b(s)}q^{a(s)-b(s)}
\left(\sum_e q^{\delta(e)}\right).
$$

There are $\ell(s)$ circles in this smoothing. By the Binary Enhancement Theorem, the parenthesized sum equals $(q+q^{-1})^{\ell(s)}$. Substitution produces exactly $J_D(q)$.

This proof is statewise: for each fixed $s$, the total contribution of all enhanced generators above $s$ equals the corresponding summand of the Jones state sum. No relation between different smoothing states is needed.

### Remark 4.2 (Scope of the theorem)

The theorem proves the decategorification identity for the generator set underlying the cube. A homological categorification additionally requires a chain differential. If finite-dimensional bigraded chain groups are formed from these generators, if the differential has homological degree $1$ and quantum degree $0$, and if it squares to zero, then the standard Euler-characteristic argument identifies the graded Euler characteristic of the chain groups with that of their homology. Those hypotheses and constructions are separate from Theorem 4.1.

## 5. Oriented normalization

Suppose now that $D$ is oriented. Every crossing has a sign $+1$ or $-1$. The **writhe** is

$$
w(D)=\sum_{c\text{ a crossing}}\operatorname{sgn}(c),
$$

the number of positive crossings minus the number of negative crossings.

Define the **writhe-normalized graded Euler sum** and **writhe-normalized Jones state sum** by

$$
\widetilde\chi_q(D)=q^{-3w(D)}\chi_q(D)
$$

and

$$
\widetilde J_D(q)=q^{-3w(D)}J_D(q).
$$

The exponent convention $-3w(D)$ is the one fixed throughout this paper; changing variables or Jones normalizations may lead to other familiar shifts.

### Theorem 5.1 (Oriented Graded Euler–Jones Theorem)

For every finite oriented combinatorial link diagram $D$,

$$
\widetilde\chi_q(D)=\widetilde J_D(q).
$$

**Proof sketch.** Theorem 4.1 gives $\chi_q(D)=J_D(q)$ for the underlying unoriented diagram. Multiplication of both sides by the common Laurent monomial $q^{-3w(D)}$ gives the stated identity.

The theorem asserts compatibility of the finite state-sum calculation with the chosen writhe shift. It does not by itself establish invariance under Reidemeister moves; that requires the usual normalization analysis at the polynomial level or chain equivalences at the homological level.

## 6. The crossingless unknot and other elementary checks

### Proposition 6.1 (Crossingless unknot)

Let $U$ be the diagram consisting of one circle and no crossings. Then

$$
\chi_q(U)=J_U(q)=q+q^{-1}.
$$

**Proof sketch.** There is one smoothing state, with $a=b=0$ and $\ell=1$. Its two enhancements have degrees $1$ and $-1$, so the graded Euler sum is $q+q^{-1}$. The state-sum formula yields $(-1)^0q^0(q+q^{-1})^1$, the same expression.

For a crossingless diagram of $m$ disjoint circles, the identical argument gives $(q+q^{-1})^m$. For example,

$$
(q+q^{-1})^2=q^2+2+q^{-2}
$$

and

$$
(q+q^{-1})^3=q^3+3q+3q^{-1}+q^{-3}.
$$

The integer coefficients count enhancements sharing a quantum degree. These examples expose the graded multiplicities that the compressed state sum records.

## 7. Algorithms

A Laurent polynomial can be represented computationally by a finite dictionary from integer exponents to integer coefficients. Addition combines coefficients at equal exponents; multiplication adds exponents and multiplies coefficients.

### Algorithm 7.1 (Explicit enhanced-state enumeration)

For every smoothing state $s$, enumerate all $2^{\ell(s)}$ binary circle labels. For each enhancement $e$, add the monomial

$$
(-1)^{b(s)}q^{a(s)-b(s)+\delta(e)}.
$$

If the diagram has $n$ crossings, its running time, apart from the cost of determining circle counts, is

$$
O\left(\sum_s 2^{\ell(s)}\ell(s)\right),
$$

when each enhancement degree is computed by scanning its labels. The memory needed for the accumulated polynomial is proportional to the number of distinct exponents.

### Algorithm 7.2 (Compressed state-sum evaluation)

For each smoothing state $s$, expand the enhancement factor via Corollary 3.3:

$$
(q+q^{-1})^{\ell(s)}
=\sum_{r=0}^{\ell(s)}\binom{\ell(s)}r q^{2r-\ell(s)}.
$$

Multiply by $(-1)^{b(s)}q^{a(s)-b(s)}$ and add the result to the accumulator. Given the triples $(a(s),b(s),\ell(s))$, this takes

$$
O\left(\sum_s(\ell(s)+1)\right)
$$

integer-coefficient updates, rather than one update for every enhancement. Computing all smoothing states still incurs an unavoidable factor of $2^n$ for direct cube enumeration, but the exponential dependence on the number of circles within each state is removed.

### Algorithm 7.3 (Independent consistency check)

For small examples, compute the polynomial by both algorithms and compare their exponent–coefficient dictionaries. Theorem 4.1 guarantees equality. Numerically, this comparison illuminates the proof: explicit binary labelings and binomially compressed circle factors are two enumerations of the same finite weighted set.

The algorithms require as input the smoothing data of a diagram, in particular the number of circles in each complete resolution. Determining those counts from planar connectivity can be implemented with a disjoint-set data structure. The present state-sum theorem is independent of the chosen circle-counting implementation.

## 8. Structural consequences

The statewise proof yields several useful consequences that are worth recording explicitly.

### Proposition 8.1 (Statewise factorization)

Fix a smoothing state $s$ with $m=\ell(s)$ circles. The complete contribution of all enhanced states lying over $s$ is

$$
(-1)^{b(s)}q^{a(s)-b(s)}(q+q^{-1})^m.
$$

**Proof sketch.** Every enhancement over $s$ has the common sign $(-1)^{b(s)}$ and common smoothing shift $q^{a(s)-b(s)}$. Factoring these out leaves the enhancement polynomial $E_m(q)$, which equals $(q+q^{-1})^m$ by Theorem 3.2.

This proposition is stronger in organization, though not in logical content, than merely knowing equality after summing over all states: it says the equality respects the projection from enhanced states to smoothing states. Consequently, no cancellation between distinct vertices of the cube is required for the theorem.

### Proposition 8.2 (Quantum-degree support over one smoothing)

For a fixed state $s$ with $m$ circles, its enhanced generators occur precisely in quantum degrees

$$
a(s)-b(s)-m,\ a(s)-b(s)-m+2,\ldots,
 a(s)-b(s)+m.
$$

The multiplicity in degree $a(s)-b(s)+2r-m$ is $\binom mr$.

**Proof sketch.** An enhancement with $r$ positive labels has enhancement degree $2r-m$. Adding the smoothing shift $a(s)-b(s)$ gives the displayed degree. There are $\binom mr$ ways to choose the positively labeled circles.

Thus every smoothing contributes a translated, parity-constrained binomial profile. This observation provides quick bounds on the exponents that may occur in the total polynomial. It also gives a useful diagnostic for computations: within a fixed smoothing, coefficients must have binomial multiplicities before contributions from other states are combined.

### Proposition 8.3 (Evaluation at $q=1$)

At $q=1$, the common state sum specializes to

$$
\chi_1(D)=J_D(1)=\sum_s(-1)^{b(s)}2^{\ell(s)}.
$$

**Proof sketch.** Each quantum monomial becomes $1$, so an $m$-circle state contributes the signed cardinality $(-1)^{b(s)}2^m$ of its enhancement set. Equivalently, substitute $q=1$ into $(q+q^{-1})^m$.

At $q=-1$, each circle factor becomes $-2$, while the smoothing shift supplies an additional sign determined by $a(s)-b(s)$. Such specializations are elementary but useful for testing implementations and for seeing that the Laurent polynomial retains both cardinality and grading information.

### Proposition 8.4 (Multiplicativity for disjoint diagrammatic data)

Suppose two diagrams $D_1$ and $D_2$ have independent crossing sets and their disjoint union has smoothing circles obtained as the disjoint union of the circles from the two component states. Then

$$
J_{D_1\sqcup D_2}(q)=J_{D_1}(q)J_{D_2}(q),
$$

and the same multiplicativity holds for $\chi_q$.

**Proof sketch.** A smoothing state of the disjoint union is uniquely a pair $(s_1,s_2)$. The quantities $a$, $b$, and $\ell$ add under this pairing. Therefore signs multiply, Laurent monomials multiply, and the circle factor splits as

$$
(q+q^{-1})^{\ell(s_1)+\ell(s_2)}
=(q+q^{-1})^{\ell(s_1)}(q+q^{-1})^{\ell(s_2)}.
$$

Distributing the double sum gives the product of state sums. The generator version follows similarly by pairing enhancements, or directly from Theorem 4.1.

## 9. Applications and interpretation

First, Theorem 4.1 supplies the generator-level Euler calculation needed in categorification. It explains the grading shifts: $b(s)$ controls the alternating sign, $a(s)-b(s)$ shifts the quantum degree of a smoothing, and the labels account for its rank-two circle factor.

Second, the theorem supports efficient evaluation. A smoothing with $m$ circles has $2^m$ generators, but their total contribution has only $m+1$ potential exponents. The binomial form is therefore a substantial compression.

Third, the identity clarifies the role of the graded rank-two object associated with a circle. The factor $q+q^{-1}$ is not an arbitrary state-sum weight; it is the graded dimension of two basis vectors in degrees $1$ and $-1$. The Jones summand is consequently the decategorified footprint of the enhanced state space.

Fourth, the writhe-normalized result cleanly separates orientation from enhancement combinatorics. Orientation does not alter the binary labeling theorem. It changes the final polynomial by a global monomial determined by signed crossings.

Finally, the computation resembles partition functions in statistical mechanics. Smoothing choices are global configurations, circle labels are local internal states, $q$ tracks energy-like degree, and the Euler sign distinguishes parity. The factorization over circles is the familiar multiplication of independent local partition functions.

## 10. Limitations and future work

The present argument deliberately stops at the finite graded enumeration. Several further steps are required for a complete homological and topological theory.

The first is to construct the Khovanov chain groups and the signed cube differential over an arbitrary coefficient ring, and to prove $d^2=0$ from the behavior of square faces in the cube. The second is to formulate the calculation for finitely supported bigraded modules and prove that passage to homology preserves the graded Euler characteristic. Together these steps would promote the generator identity to a homological one.

The third is invariance. One must construct chain maps and chain homotopies for the three Reidemeister moves. A parallel polynomial-level development should connect the cube normalization used here to the oriented Kauffman-bracket normalization, with all writhe and variable conventions explicit.

A further algebraic direction is to replace basis-level binary tables by linear maps on tensor powers of a rank-two Frobenius algebra. This would make multiplication, comultiplication, units, counits, and edge maps available as genuine module homomorphisms and expose the structural reason that cube faces commute or anticommute after signs.

Algorithmically, one may avoid full state enumeration by exploiting diagram decompositions, transfer matrices, treewidth, or memoization of repeated partial smoothings. The compressed enhancement theorem remains useful in all such methods because it eliminates the inner enumeration of circle labels.

### 10.1. Normalization discipline

State-sum formulas in knot theory often differ by substitutions such as $q\mapsto q^{-1}$, powers of $q$, signs, or changes between a bracket variable and a Jones variable. The statements here avoid silently identifying these conventions. The circle value is fixed to $q+q^{-1}$, the smoothing shift is fixed to $a(s)-b(s)$, the homological sign is fixed to $(-1)^{b(s)}$, and the oriented shift is fixed to $q^{-3w(D)}$. Any comparison with another convention should begin by writing the relevant change of variables and global monomial explicitly. This discipline is especially important when extending the calculation to Reidemeister invariance, because a correct local state sum may still require a normalization to compensate for the first Reidemeister move.

### 10.2. General graded label sets

The proof also indicates a broader template. Suppose one replaces the two labels by a finite graded set with degrees $d_1,\ldots,d_r$. The enhancement polynomial of one circle becomes $q^{d_1}+\cdots+q^{d_r}$, and independent labels on $m$ circles contribute

$$
(q^{d_1}+\cdots+q^{d_r})^m.
$$

The same regrouping argument then converts an explicit sum over labels into a compressed state sum. The rank-two choice with degrees $1$ and $-1$ is the specialization relevant here. This generality shows that the proof depends only on additivity of degree and independence of circle labels; the deeper topology enters when one asks for differentials and diagrammatic invariance.

## 11. Conclusion

For every smoothing state, binary labels of degrees $+1$ and $-1$ contribute the graded polynomial $(q+q^{-1})^{\ell(s)}$. Once this identity is inserted into the signed sum over the smoothing cube, the graded Euler sum of enhanced generators becomes exactly

$$
\sum_s(-1)^{b(s)}q^{a(s)-b(s)}(q+q^{-1})^{\ell(s)}.
$$

The oriented version follows by the common writhe factor $q^{-3w(D)}$, and the crossingless unknot gives the atomic value $q+q^{-1}$. The proof is finite, statewise, and normalization-explicit. It reveals the Jones state sum as a compressed record of a graded rank-two choice on every smoothing circle, thereby isolating the combinatorial heart of Khovanov categorification.