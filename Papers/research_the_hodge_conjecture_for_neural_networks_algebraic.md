# Cellular Homology and Architecture Bounds for Piecewise-Linear Neural Decision Surfaces

**Aristotle**  
**July 19, 2026**

## Abstract

The zero set of a real-valued ReLU network is piecewise linear, but it is generally real, noncompact, and singular rather than a smooth complex projective variety. Consequently, classical Hodge numbers and the classical Hodge conjecture do not apply without substantial additional structure. This paper develops a rigorous finite-dimensional replacement. For a three-term cellular chain complex $C_2\xrightarrow{d_2}C_1\xrightarrow{d_1}C_0$ over any field, with $d_1d_2=0$, we prove the exact middle-rank identity

$$
\dim H_1+\operatorname{rank}(d_1)+\operatorname{rank}(d_2)=\dim C_1.
$$

It follows that middle homology is nonzero precisely when the two adjacent ranks do not exhaust $C_1$, vanishes precisely when they do, and is maximal precisely when both differentials vanish. Every homology class has a cellular-cycle representative. We also derive the three-term Euler–Poincaré identity

$$
\dim H_0-\dim H_1+\dim H_2=\dim C_0-\dim C_1+\dim C_2,
$$

prove independence from the differentials once chain dimensions are fixed, and establish an absolute bound by total chain dimension. A network with hidden widths $w_1,\ldots,w_L$ has exactly $P=\prod_i2^{w_i}$ Boolean activation patterns. Under the explicit hypothesis that each of the three chain dimensions is at most $P$, the Euler characteristic obeys $|\chi|\le 3P$. These results provide a precise cellular theory for finite polyhedral models of decision surfaces while identifying the additional constructions required for a genuine Hodge-type representability theorem.

## 1. Introduction

Let $f:\mathbb{R}^n\to\mathbb{R}$ be represented by a feed-forward neural network with rectified linear activations. Its decision surface is

$$
V(f)=\{x\in\mathbb{R}^n:f(x)=0\}.
$$

A ReLU network is affine on each region where every hidden unit has a fixed active/inactive state. Thus $V(f)$ is assembled from polyhedral pieces. This makes cellular and polyhedral topology natural tools for studying connected components, loops, voids, and higher-dimensional cycles in a finite model of $V(f)$.

A tempting analogy compares such cycles with algebraic cycles in the classical Hodge conjecture. That analogy is not, by itself, a theorem. Classical Hodge theory concerns smooth complex projective varieties and a decomposition of complex cohomology into spaces of type $(p,q)$. A general ReLU zero set is a real piecewise-linear set, often noncompact and singular. There is no canonical bigrading $H^{p,q}$ in this setting. Furthermore, although every polyhedral face is contained in an affine subspace cut out by linear equations, the face itself is usually constrained by inequalities and need not be a global algebraic subvariety or hyperplane section.

The mathematically available statement is cellular. Given a finite polyhedral cell complex modeling a compact decision surface or a compact truncation, cellular chains form finite-dimensional vector spaces. Boundary operators make them a chain complex. Homology classes are represented by cellular cycles, while their dimensions are determined by ranks. This paper isolates the complete theory of three consecutive degrees and relates its numerical invariants to a coarse count derived from network architecture.

The main contributions are:

1. an exact rank formula for middle homology;
2. exact criteria for nonzero, zero, and maximal middle homology;
3. cellular representability of every quotient class;
4. an abstract telescoping Euler–Poincaré principle and its three-term specialization;
5. rigidity of the Euler characteristic under changes of boundary maps that preserve chain dimensions;
6. total-dimension and activation-pattern bounds;
7. an exact rational-matrix algorithm for numerical examples.

All statements hold over an arbitrary field unless a coefficient field is specified. Taking the field to be $\mathbb{Q}$ gives the rational cellular theory relevant to rational polyhedral complexes.

## 2. Piecewise-linear decision surfaces

### 2.1 ReLU networks and activation patterns

The rectified linear unit is the function

$$
\rho(t)=\max(0,t).
$$

Consider a network with $L$ hidden layers of widths $w_1,\ldots,w_L$. Each hidden unit is either active, when its preactivation is positive, or inactive, when its preactivation is nonpositive. An **activation pattern** assigns one of these two states to every hidden unit.

**Proposition 2.1 (Activation-pattern count).** The number of Boolean activation patterns is

$$
P(w_1,\ldots,w_L)=\prod_{i=1}^{L}2^{w_i}=2^{\sum_{i=1}^{L}w_i}.
$$

**Proof sketch.** Layer $i$ contains $w_i$ units and therefore has $2^{w_i}$ Boolean state assignments. Choices in different layers form a Cartesian product, so their cardinalities multiply. $\square$

On the subset of input space realizing a fixed pattern, every ReLU acts either as the identity or as zero. The network therefore restricts to an affine function there, and its zero set within that region lies in an affine hyperplane.

The number $P$ counts abstract Boolean assignments, not necessarily nonempty regions in input space. It is therefore a coarse ceiling on activation states. Turning it into a bound on cells requires an explicit geometric construction and a cell-count hypothesis.

### 2.2 Finite cellular models

A general decision surface may be unbounded. The theory below applies to a finite cellular model, such as a compact decision surface, a compact truncation equipped with a finite polyhedral decomposition, or any finite complex extracted from the network geometry.

Fix a field $F$. Let $C_k$ be the finite-dimensional $F$-vector space generated by the oriented $k$-cells. The cellular boundary map $d_k:C_k\to C_{k-1}$ sends each cell to its oriented boundary. The geometric cancellation of codimension-two faces yields

$$
d_{k-1}d_k=0.
$$

We concentrate on

$$
C_2\xrightarrow{d_2}C_1\xrightarrow{d_1}C_0,
$$

where $d_1d_2=0$. Denote $c_i=\dim_F C_i$ and $r_i=\operatorname{rank}(d_i)$.

## 3. Cycles, boundaries, and homology

### 3.1 Definitions

The middle **cycle space** is

$$
Z_1=\ker d_1.
$$

The middle **boundary space** is

$$
B_1=\operatorname{im}d_2.
$$

The chain condition gives $B_1\subseteq Z_1$. The middle homology is

$$
H_1=Z_1/B_1=\ker d_1/\operatorname{im}d_2.
$$

At the endpoints of the three-term complex, define

$$
H_0=C_0/\operatorname{im}d_1
$$

and

$$
H_2=\ker d_2.
$$

Write $\beta_i=\dim_F H_i$.

When $F=\mathbb{Q}$, these are rational cellular chains and rational homology groups. A chain is a finite rational linear combination of cells.

### 3.2 Cellular representatives

**Theorem 3.1 (Cellular Representation Theorem).** Every class in $H_1$ is represented by an element of $Z_1$, and therefore by a cellular cycle, that is, a linear combination of the chosen one-dimensional cells whose boundary is zero.

**Proof sketch.** By definition, $H_1$ is the quotient $Z_1/B_1$. The canonical quotient map $Z_1\to Z_1/B_1$ is surjective: each coset contains the cycle from which it was formed. $\square$

This theorem is an exact representability statement, but its scope must be observed. It concerns cellular cycles. It does not identify those representatives with classical algebraic cycles. Such an identification would require a separately defined cycle-class or realization map into an appropriate geometric cohomology theory.

## 4. The exact middle-rank identity

**Theorem 4.1 (Middle Betti Rank Formula).** Let $C_2\xrightarrow{d_2}C_1\xrightarrow{d_1}C_0$ be a finite-dimensional chain complex over a field. Then

$$
\beta_1+r_1+r_2=c_1.
$$

Equivalently,

$$
\beta_1=c_1-r_1-r_2.
$$

**Proof sketch.** Rank–nullity for $d_1$ gives

$$
\dim Z_1=\dim\ker d_1=c_1-r_1.
$$

Since $d_1d_2=0$, the image of $d_2$ is a subspace of $Z_1$ and has dimension $r_2$. The dimension formula for a quotient yields

$$
\beta_1=\dim(Z_1/B_1)=\dim Z_1-\dim B_1=(c_1-r_1)-r_2.
$$

Rearranging proves the identity. $\square$

The theorem immediately implies $r_1+r_2\le c_1$. This inequality is not an independent assumption; it follows from the chain condition because the incoming image must fit inside the outgoing kernel.

### 4.1 Exact obstruction criteria

**Corollary 4.2 (Nonvanishing Criterion).** Middle homology is nonzero if and only if

$$
r_1+r_2<c_1.
$$

**Proof sketch.** By Theorem 4.1, $\beta_1=c_1-r_1-r_2$. Since $\beta_1$ is a nonnegative integer, it is positive exactly when the rank sum is strictly less than $c_1$. $\square$

**Corollary 4.3 (Vanishing Criterion).** Middle homology vanishes if and only if

$$
r_1+r_2=c_1.
$$

**Proof sketch.** The same formula gives $\beta_1=0$ precisely when the rank sum exhausts $c_1$. $\square$

**Corollary 4.4 (Maximal-Homology Criterion).** The equality $\beta_1=c_1$ holds if and only if $d_1=0$ and $d_2=0$.

**Proof sketch.** If $\beta_1=c_1$, Theorem 4.1 gives $r_1+r_2=0$. Nonnegativity forces $r_1=r_2=0$, and a linear map has rank zero exactly when it is the zero map. Conversely, if both maps vanish, every middle chain is a cycle and no nonzero middle chain is a boundary, so $H_1\cong C_1$. $\square$

These results identify a complete finite-dimensional obstruction. A middle-dimensional class exists exactly when the two adjacent boundary maps leave an unused direction in $C_1$.

## 5. Euler–Poincaré rigidity

### 5.1 An abstract telescoping identity

The three-term formula is a special case of cancellation in any bounded numerical homology profile. Let $a_n$ denote chain dimensions, $r_n$ boundary ranks, and $h_n$ homology dimensions. Suppose

$$
h_0=a_0-r_0
$$

and, for $n\ge 0$,

$$
h_{n+1}=a_{n+1}-r_n-r_{n+1}.
$$

**Theorem 5.1 (Euler–Poincaré Defect Identity).** For every $N\ge 0$,

$$
\sum_{n=0}^{N}(-1)^nh_n
=
\sum_{n=0}^{N}(-1)^na_n-(-1)^Nr_N.
$$

**Proof sketch.** Substitute the rank formulas into the left-hand side. Each interior rank $r_n$ appears twice with opposite signs: once in $h_n$ and once in $h_{n+1}$. They telescope, leaving only the top term $-(-1)^Nr_N$. Equivalently, one may induct on $N$, append the formula for $h_{N+1}$, and use $(-1)^{N+1}=-(-1)^N$. $\square$

**Corollary 5.2 (Euler–Poincaré Principle).** If the complex is bounded at degree $N$, so $r_N=0$, then

$$
\sum_{n=0}^{N}(-1)^nh_n
=
\sum_{n=0}^{N}(-1)^na_n.
$$

The alternating homology dimension therefore equals the alternating chain dimension.

### 5.2 Homology dimensions in three terms

For the concrete complex, rank–nullity gives the endpoint formulas.

**Lemma 5.3 (Bottom Homology Dimension).**

$$
\beta_0=c_0-r_1.
$$

**Proof sketch.** The quotient $C_0/\operatorname{im}d_1$ has dimension $c_0-\dim\operatorname{im}d_1=c_0-r_1$. $\square$

**Lemma 5.4 (Top Homology Dimension).**

$$
\beta_2=c_2-r_2.
$$

**Proof sketch.** Here $H_2=\ker d_2$, so rank–nullity for $d_2$ gives the formula. $\square$

Together with Theorem 4.1, these endpoint identities determine all three Betti numbers from $c_0,c_1,c_2,r_1,r_2$.

**Theorem 5.5 (Three-Term Euler–Poincaré Identity).**

$$
\beta_0-\beta_1+\beta_2=c_0-c_1+c_2.
$$

**Proof sketch.** Substitute

$$
\beta_0=c_0-r_1,
\qquad
\beta_1=c_1-r_1-r_2,
\qquad
\beta_2=c_2-r_2.
$$

The terms involving $r_1$ and $r_2$ cancel. $\square$

The common integer is the Euler characteristic

$$
\chi=\beta_0-\beta_1+\beta_2=c_0-c_1+c_2.
$$

### 5.3 Consequences

**Corollary 5.6 (Independence from Differentials).** Consider two three-term chain complexes over the same field. If their corresponding chain spaces have equal dimensions, then their Euler characteristics are equal, regardless of the particular boundary maps.

**Proof sketch.** By Theorem 5.5, each Euler characteristic equals $c_0-c_1+c_2$, which depends only on chain dimensions. $\square$

This does not mean that the individual homology groups are independent of the differentials. Different ranks can redistribute dimensions among $H_0,H_1,H_2$ while preserving the alternating sum.

**Corollary 5.7 (Total-Dimension Bound).**

$$
|\chi|\le c_0+c_1+c_2.
$$

**Proof sketch.** Theorem 5.5 gives $\chi=c_0-c_1+c_2$. Since each $c_i$ is nonnegative, the triangle inequality yields

$$
|c_0-c_1+c_2|\le c_0+c_1+c_2.
$$

$\square$

## 6. Width-driven bounds

Activation patterns connect architecture to a coarse combinatorial scale. Let

$$
P=\prod_{i=1}^{L}2^{w_i}.
$$

The following statement makes its geometric premise explicit.

**Theorem 6.1 (Architecture-Driven Euler Bound).** Suppose a finite three-term cellular model associated with a ReLU decision surface satisfies

$$
c_0\le P,
\qquad
c_1\le P,
\qquad
c_2\le P.
$$

Then

$$
|\chi|\le 3P.
$$

**Proof sketch.** Corollary 5.7 gives $|\chi|\le c_0+c_1+c_2$. Applying the three cell-count hypotheses gives

$$
c_0+c_1+c_2\le P+P+P=3P.
$$

$\square$

Because $P=2^{\sum_iw_i}$, the estimate can also be written

$$
|\chi|\le 3\cdot 2^{\sum_{i=1}^{L}w_i}.
$$

The theorem is conditional on the common cell bound. The activation-pattern count alone does not prove that every finite decomposition has at most one cell of each dimension per pattern. A rigorous network-to-complex construction must establish the needed correspondence or replace $P$ with a sharper proven cell count.

The result should also not be interpreted as a bound on classical Hodge numbers $h^{p,q}$. Such numbers require a bigraded cohomology theory not canonically present for general real piecewise-linear zero sets. The Euler characteristic is instead a valid, grading-independent topological invariant available from the cellular model.

## 7. Exact computational method

The theory yields a direct algorithm for finite examples. Let $D_1$ and $D_2$ be matrices over $\mathbb{Q}$ representing $d_1$ and $d_2$ in chosen cellular bases.

### Algorithm 7.1: Exact Betti computation

**Input:** Rational matrices $D_1\in\mathbb{Q}^{c_0\times c_1}$ and $D_2\in\mathbb{Q}^{c_1\times c_2}$.

**Output:** $\beta_0,\beta_1,\beta_2$, and $\chi$.

1. Compute $D_1D_2$ and reject the input unless it is the zero matrix.
2. Compute $r_1=\operatorname{rank}(D_1)$ and $r_2=\operatorname{rank}(D_2)$ by exact Gaussian elimination.
3. Set

$$
\beta_0=c_0-r_1,
\qquad
\beta_1=c_1-r_1-r_2,
\qquad
\beta_2=c_2-r_2.
$$

4. Set

$$
\chi_H=\beta_0-\beta_1+\beta_2
$$

and

$$
\chi_C=c_0-c_1+c_2.
$$

5. Verify $\chi_H=\chi_C$ and return the values.

For dense matrices, exact Gaussian elimination uses $O(mn\min(m,n))$ field operations for an $m\times n$ matrix; in a square scale $N$, this is $O(N^3)$. Sparse cellular matrices often permit substantially better practical performance. Rational arithmetic avoids rank errors caused by floating-point tolerances.

### 7.1 Canonical examples

**Example 7.2 (Polygonal circle).** Take a triangle with three vertices and three oriented edges but no face, so $(c_0,c_1,c_2)=(3,3,0)$. The incidence matrix $D_1$ has rank $2$, and $D_2$ has rank $0$. Therefore

$$
(\beta_0,\beta_1,\beta_2)=(1,1,0),
$$

and $\chi=1-1=0=3-3$.

**Example 7.3 (Filled triangle).** Add one two-cell whose boundary is the sum of the three oriented edges. Then $(c_0,c_1,c_2)=(3,3,1)$, $r_1=2$, and $r_2=1$. Thus

$$
(\beta_0,\beta_1,\beta_2)=(1,0,0),
$$

and $\chi=1=3-3+1$. The incoming face boundary fills the unique loop.

**Example 7.4 (Two isolated points).** Let $(c_0,c_1,c_2)=(2,0,0)$. Both maps have rank zero, so

$$
(\beta_0,\beta_1,\beta_2)=(2,0,0)
$$

and $\chi=2$. The bottom homology records two connected components.

These examples show both rigidity and flexibility. Adding a face changes $\beta_1$, but the corresponding change in $c_2$ preserves Euler–Poincaré equality.

## 8. Applications

### 8.1 Diagnosing topological complexity

The nonvanishing criterion provides a rank test for one-dimensional holes. Rather than explicitly enumerating a basis of quotient classes, one may compare $r_1+r_2$ with $c_1$. This is particularly useful when only the existence or number of holes matters.

### 8.2 Comparing models with equal cell profiles

If two finite decision-surface models have the same cell counts in dimensions zero through two, then they share the same Euler characteristic. Their Betti vectors may differ, so the Euler characteristic is a coarse invariant, but it provides an immediate consistency check across geometric constructions or parameter choices.

### 8.3 Topological monitoring during network variation

As network parameters vary without changing a chosen finite cell profile, the Euler characteristic remains fixed. A change in $\chi$ therefore requires a change in the cellular dimensions of that model. Individual Betti numbers may change through compensating rank changes even when $\chi$ does not.

### 8.4 Rational decision-surface cycles

For rational polyhedral complexes and $F=\mathbb{Q}$, every rational cellular homology class is represented by a rational linear combination of cells. This supports exact symbolic computation and avoids numerical ambiguity. It is the appropriate representability result before any separate geometric cycle-class theory has been supplied.

## 9. Scope and correction of the Hodge analogy

The phrase “Hodge conjecture for neural networks” can suggest two different claims, and they must be separated.

The first is a cellular claim: every homology class of a finite cellular model is represented by a cellular cycle. This is true by quotient surjectivity, and the dimensions of these classes obey the exact formulas above.

The second is a classical algebraic-geometric claim: certain rational cohomology classes are rational combinations of algebraic cycle classes. This requires, at minimum, a complex projective variety, a Hodge decomposition, algebraic cycles of specified codimension, and a cycle-class map. A generic ReLU zero set supplies none of these automatically.

Linear containment does not bridge the gap. A polyhedral face can be described by linear equalities together with inequalities. It may be contained in a hyperplane, but it is not thereby a global hyperplane section or algebraic subvariety. Consequently, cellular generators should not be renamed algebraic cycles without an explicit realization theorem.

The proposed inequality

$$
h^{p,q}\le {w_1\choose p}{w_L\choose q}\prod_{i=2}^{L-1}w_i
$$

also remains conjectural at the level of motivation because $h^{p,q}$ has not been defined canonically for the objects under study. The established architecture-sensitive statement is instead the conditional Euler bound of Theorem 6.1.

## 10. Discussion

The exact rank formula and Euler–Poincaré identity answer complementary questions. The first is local to the middle degree and sensitive to the boundary maps. It says precisely how $H_1$ is created: cycles arise from the nullity of $d_1$, while boundaries from $d_2$ remove cycle directions. The second combines all degrees and eliminates the ranks entirely. It says that their alternating contribution is constrained by the cell profile.

This division is useful for neural decision surfaces. Architecture may give coarse control over the number of combinatorial regions and hence, after a geometric construction, over cell counts. Boundary matrices encode how those cells are attached. The first kind of information controls broad ceilings; the second determines actual topology.

The theory is field-independent, but coefficients matter geometrically. Over $\mathbb{Q}$ it detects rational Betti numbers and ignores torsion. Integral homology would retain torsion but would require finitely generated abelian groups and Smith normal form rather than dimensions and ordinary rank–nullity. For the motivating rational representability question, $\mathbb{Q}$ is the natural coefficient field.

Noncompactness is another substantive issue. A compact truncation can be modeled by a finite complex, but its boundary conditions influence homology. For the full unbounded zero set, locally finite homology, compactly supported cohomology, or a specified compactification may be more appropriate. Different choices answer different geometric questions.

## 11. Future work

Several developments are needed to turn the present linear-algebraic core into a full theory of neural decision surfaces.

1. **Finite rational polyhedral complexes.** Define the face and incidence data of a finite rational polyhedral complex and instantiate cellular boundary maps in every degree.
2. **Network-to-complex construction.** Starting from affine weights and ReLU activations, construct a finite polyhedral complex for a compact truncation of $V(f)$ and prove that consecutive boundaries compose to zero.
3. **Unbounded surfaces.** Develop locally finite homology, compactly supported cohomology, or explicit compactifications for noncompact decision surfaces.
4. **Realization maps.** Define a cycle-class map from rational polyhedral cycles to a selected geometric cohomology theory. Only a surjectivity theorem for such a map would justify Hodge-type representability language.
5. **Sharper architecture bounds.** Prove cell counts from network architecture rather than assuming them. The Boolean count $2^{\sum_iw_i}$ is a coarse combinatorial ceiling; sharper bounds should account for input dimension, degeneracies, and realizable activation regions.
6. **Bigraded invariants.** If a meaningful bigrading is desired, define the geometric or sheaf-theoretic structure that produces it before proposing bounds analogous to $h^{p,q}$.
7. **Stability.** Study how ranks and Betti numbers change under perturbations of weights, and distinguish stable topological features from events caused by combinatorial transitions.

## 12. Conclusion

For finite cellular models of piecewise-linear neural decision surfaces, the central topology is completely controlled by elementary but exact linear algebra. Every middle homology class has a cellular-cycle representative, and

$$
\beta_1=c_1-r_1-r_2.
$$

This yields exact nonvanishing, vanishing, and maximality criteria. Across all three degrees,

$$
\chi=\beta_0-\beta_1+\beta_2=c_0-c_1+c_2,
$$

so the Euler characteristic is independent of the differentials once cell counts are fixed and satisfies $|\chi|\le c_0+c_1+c_2$. With a common activation-pattern cell ceiling $P=\prod_i2^{w_i}$, one obtains $|\chi|\le3P$.

These statements form a rigorous cellular replacement for an initially classical Hodge-theoretic analogy. They identify what is already available for ReLU zero sets, what remains conditional on a network-to-complex construction, and what additional geometry would be required before algebraic-cycle or Hodge-number claims become meaningful.
