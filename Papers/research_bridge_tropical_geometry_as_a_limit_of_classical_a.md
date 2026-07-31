# Non-Archimedean Cancellation, Tropical Corner Loci, and Weighted Intersection Correspondence

**Aristotle**  
**July 31, 2026**

## Abstract

We isolate three elementary mechanisms that form a rigorous bridge from classical algebraic equations to tropical geometry. First, for a finite vanishing sum of nonzero elements in a non-Archimedean valued division field, the maximal valuation cannot occur uniquely. This cancellation principle implies that the valuation data of every zero of a finite sum lies in the max-corner locus of the associated tropical term family, giving the forward hypersurface inclusion of the tropical fundamental theorem in a finite termwise form. Second, the corner locus of a real-valued tropical term family is invariant under every positive common rescaling; consequently, the corner sets at all positive integral valuation scales agree exactly, providing setwise stabilization rather than merely eventual convergence. Third, a multiplicity-preserving bijection between finite classical and tropical intersection sets preserves their weighted intersection numbers. Hence a classical Bézout count of $de$ transfers to the tropical intersection whenever such a correspondence exists. We state all hypotheses explicitly, distinguish these results from stronger lifting and convergence theorems, provide constructive algorithms for corner detection and weighted-count transfer, and discuss applications and extensions.

## 1. Introduction

Tropical geometry replaces nonlinear algebraic objects by polyhedral ones while retaining surprisingly rich information. Under the max convention, ordinary multiplication becomes addition and ordinary addition degenerates into taking a maximum. A finite polynomial becomes a maximum of affine-linear functions, and its tropical hypersurface is the locus where the maximum is attained at least twice. The central question is why the zero set of a classical polynomial should be related to that corner locus.

The essential local reason is non-Archimedean cancellation. A non-Archimedean valuation satisfies a strengthened triangle inequality: the valuation of a sum is bounded by the larger valuation of its summands. More strongly, a finite sum of terms all strictly smaller than a fixed nonzero term remains strictly smaller than that term. It follows that a uniquely dominant term cannot be cancelled by all remaining terms. Therefore, whenever a finite sum of nonzero terms vanishes, at least two terms share the maximal valuation.

Once a polynomial is viewed as a finite sum of monomial terms, this cancellation principle immediately places every classical zero on the tropical corner locus. The argument is independent of coordinate choices and uses no limiting procedure. It is a finite statement about terms, valuations, and maxima.

A second bridge concerns scale. Tropicalization is often motivated as a large-parameter limit. For an already tropical term family, multiplying every real-valued term by the same positive scalar preserves every order relation and therefore preserves the corner locus exactly. Thus the corner locus at scale $n+1$ is independent of $n$. This is a precise setwise stabilization statement. It should not be confused with stronger claims about Hausdorff convergence of classical logarithmic zero sets, which require further analytic arguments.

A third bridge concerns enumerative geometry. If finite classical and tropical intersection sets are related by a bijection preserving local multiplicities, then their weighted sums agree by reindexing. In particular, if the classical sum is $de$, the tropical sum is $de$. This identifies the combinatorial core of a tropical Bézout transfer while leaving the genuinely geometric task—constructing and proving multiplicity preservation of the correspondence—as an explicit hypothesis.

The organization is as follows. Section 2 fixes conventions and definitions. Section 3 proves non-Archimedean cancellation. Section 4 derives the valuation-to-corner theorem. Section 5 proves scale invariance and clarifies its limiting interpretation. Section 6 treats weighted correspondences and conditional tropical Bézout. Section 7 gives algorithms and numerical examples. Sections 8–10 discuss applications, scope, and future directions.

## 2. Definitions and conventions

### 2.1. Non-Archimedean valuations

Let $K$ be a division field, possibly noncommutative, and let $\Gamma_0$ be a nontrivial linearly ordered commutative monoid with zero. A multiplicative valuation is a map

$$
v:K\longrightarrow \Gamma_0
$$

such that

$$
v(0)=0, \qquad v(1)=1, \qquad v(ab)=v(a)v(b),
$$

and

$$
v(a+b)\leq \max\{v(a),v(b)\}.
$$

We also use the standard separation property

$$
v(a)=0 \quad\Longleftrightarrow\quad a=0.
$$

In particular, $v(-a)=v(a)$. The order on $\Gamma_0$ allows comparison of finitely many valuations. The nontriviality assumption prevents the value structure from collapsing.

The common additive convention uses a map $w$ satisfying $w(ab)=w(a)+w(b)$ and $w(a+b)\geq \min\{w(a),w(b)\}$. The present multiplicative max convention is equivalent after a suitable monotone or order-reversing change of coordinates in standard examples. Our statements are expressed directly in the max convention.

### 2.2. Maximal terms and corner loci

Let $I$ be a finite nonempty index set, $X$ a set, and $\Gamma$ a linearly ordered set. Consider a family of functions

$$
F_i:X\longrightarrow \Gamma, \qquad i\in I.
$$

An index $i$ is **maximal at $x$** if

$$
F_k(x)\leq F_i(x) \quad\text{for every }k\in I.
$$

The point $x$ is a **max-corner point** if two distinct indices are maximal there. Equivalently, there exist $i\ne j$ such that

$$
F_i(x)=F_j(x)=\max_{k\in I}F_k(x).
$$

The **max-corner locus** is the set of all max-corner points. When $X=\mathbb{R}^n$ and the $F_i$ are affine-linear, the function

$$
F(x)=\max_{i\in I}F_i(x)
$$

is convex and piecewise linear. Its corner locus is the union of codimension-one and lower-dimensional cells on which more than one affine piece is active.

For the min convention, a point is a corner if at least two distinct terms attain the minimum. The following elementary lemma reconciles the conventions.

**Lemma 2.1 (Sign reversal).** Let $\Gamma$ be a linearly ordered additive commutative group whose order is compatible with addition. For every finite family $F_i:X\to\Gamma$ and every $x\in X$, the minimum of $-F_i(x)$ is attained at least twice if and only if the maximum of $F_i(x)$ is attained at least twice.

**Proof sketch.** Order reversal under negation gives

$$
-F_i(x)\leq -F_k(x) \quad\Longleftrightarrow\quad F_k(x)\leq F_i(x).
$$

Thus an index minimizes the negated family exactly when it maximizes the original family. Distinct pairs of extremizers are preserved. $\square$

### 2.3. Finite weighted intersection numbers

Let $S$ be a finite set of intersection points and let

$$
m:S\longrightarrow \mathbb{N}
$$

assign a nonnegative integral multiplicity to each point. The **weighted intersection number** is

$$
I(S,m)=\sum_{p\in S}m(p).
$$

This definition deliberately separates the formal act of weighted counting from the geometric origin of the multiplicity. Depending on context, $m(p)$ may be a local algebraic intersection multiplicity, a lattice determinant, or a stable tropical multiplicity.

## 3. The non-Archimedean cancellation principle

We begin with the key finite-sum result.

**Theorem 3.1 (No unique maximal valuation in a vanishing sum).** Let $S$ be a finite index set and let $a_i\in K$ be nonzero for every $i\in S$. Suppose

$$
\sum_{i\in S}a_i=0.
$$

Then for every $i\in S$ there exists $j\in S$ with $j\ne i$ and

$$
v(a_i)\leq v(a_j).
$$

Consequently, the maximum of the finite family $\{v(a_i):i\in S\}$ is attained by at least two distinct indices.

**Proof sketch.** Fix $i\in S$ and suppose, for contradiction, that

$$
v(a_j)<v(a_i) \quad\text{for every }j\in S\setminus\{i\}.
$$

Because $a_i\ne 0$, its valuation is nonzero. Repeated use of the strict non-Archimedean sum property gives

$$
v\!\left(\sum_{j\in S\setminus\{i\}}a_j\right)<v(a_i).
$$

On the other hand, the vanishing-sum hypothesis implies

$$
\sum_{j\in S\setminus\{i\}}a_j=-a_i.
$$

Taking valuations and using $v(-a_i)=v(a_i)$ yields

$$
v\!\left(\sum_{j\in S\setminus\{i\}}a_j\right)=v(a_i),
$$

contradicting the strict inequality. Therefore some distinct $j$ satisfies $v(a_i)\leq v(a_j)$. If $i$ is chosen to attain the overall maximum, this $j$ must also attain that maximum. $\square$

The theorem is stronger than the assertion that some maximal pair exists: it says that no individual term can dominate all the others in any vanishing nonzero sum. Its proof exposes the ultrametric obstruction to ordinary-style collective cancellation.

**Remark 3.2.** The nonzero hypothesis on every $a_i$ ensures that each participating valuation is nonzero and that strict sum estimates apply cleanly. In polynomial applications, zero terms may be removed from the finite support before invoking the theorem. If one fixes a support in advance, the theorem applies at points where all supported term evaluations are nonzero, as is automatic for Laurent monomials evaluated on an algebraic torus with nonzero coefficients.

**Example 3.3.** For a prime $p$, use the $p$-adic norm $|\cdot|_p$. If $a+b+c=0$ and all terms are nonzero, it is impossible to have

$$
|a|_p>|b|_p \quad\text{and}\quad |a|_p>|c|_p.
$$

Indeed, the ultrametric inequality would give $|b+c|_p<|a|_p$, whereas $b+c=-a$ gives equality. Thus at least two among $|a|_p,|b|_p,|c|_p$ share the maximum.

## 4. From classical zeros to tropical corners

Let $I$ be a finite nonempty set, let $X$ be any parameter space, and let

$$
T_i:X\longrightarrow K, \qquad i\in I,
$$

be a finite family of term functions. Define their classical sum by

$$
f(x)=\sum_{i\in I}T_i(x)
$$

and their valuation family by

$$
F_i(x)=v(T_i(x)).
$$

The associated max-tropical hypersurface is the max-corner locus of the family $\{F_i\}_{i\in I}$.

**Theorem 4.1 (Valuation images of zeros lie in the tropical corner locus).** Fix $x\in X$. Assume

$$
f(x)=\sum_{i\in I}T_i(x)=0
$$

and

$$
T_i(x)\ne 0 \quad\text{for every }i\in I.
$$

Then $x$ is a max-corner point of the valuation family. Explicitly, there exist distinct $i,j\in I$ such that

$$
v(T_i(x))=v(T_j(x))=\max_{k\in I}v(T_k(x)).
$$

**Proof sketch.** Since $I$ is finite and nonempty, choose $i$ attaining the maximum valuation. Apply Theorem 3.1 to the vanishing family $a_k=T_k(x)$. It supplies $j\ne i$ with

$$
v(T_i(x))\leq v(T_j(x)).
$$

Maximality of $i$ gives the reverse inequality, so $i$ and $j$ both attain the maximum. This is exactly the max-corner condition. $\square$

For a Laurent polynomial on an algebraic torus, one typically writes

$$
f(z)=\sum_{u\in A}c_u z^u,
$$

where $A\subset\mathbb{Z}^n$ is finite, $c_u\ne 0$, and $z\in(K^\times)^n$. Every term $c_u z^u$ is then nonzero. If $f(z)=0$, Theorem 4.1 says that at least two term valuations are maximal. After passing to additive logarithmic coordinates, these term valuations become affine functions of the valuation vector of $z$, so that vector lies on the tropical hypersurface.

This is the forward hypersurface inclusion customarily associated with the tropical fundamental theorem:

$$
\operatorname{val}(V(f))\subseteq \operatorname{Trop}(f),
$$

under the stated termwise interpretation and convention. The theorem does not assert the reverse inclusion. Showing that every tropical corner lifts to a classical zero generally requires an algebraically closed and suitably complete valued field, together with a lifting theorem. The distinction is essential: cancellation proves necessity, while lifting proves sufficiency.

**Example 4.2 (The tropical line).** Consider three tropical affine terms

$$
F_0(x,y)=0, \qquad F_1(x,y)=x, \qquad F_2(x,y)=y.
$$

The corner condition for $\max\{0,x,y\}$ holds on three rays:

$$
\{(x,0):x\leq 0\}, \qquad
\{(0,y):y\leq 0\}, \qquad
\{(t,t):t\geq 0\}.
$$

If a three-term classical Laurent polynomial has valuation terms represented by these affine functions, every zero in the torus has valuation vector on this graph.

## 5. Positive scaling and exact setwise stabilization

Let $F_i:X\to\mathbb{R}$ be any family of real-valued functions, with no assumption of affinity. For $c>0$, define the rescaled family

$$
(cF)_i(x)=cF_i(x).
$$

**Theorem 5.1 (Positive-scale invariance of corner loci).** For every $x\in X$ and every $c>0$, the point $x$ is a max-corner point of $\{cF_i\}$ if and only if it is a max-corner point of $\{F_i\}$. Hence

$$
\operatorname{Corner}(cF)=\operatorname{Corner}(F).
$$

**Proof sketch.** Positive multiplication is an order isomorphism of $\mathbb{R}$. Therefore, for every pair of indices $i,k$,

$$
cF_k(x)\leq cF_i(x)
\quad\Longleftrightarrow\quad
F_k(x)\leq F_i(x).
$$

The set of maximizing indices is unchanged. Having at least two distinct maximizers is consequently invariant. $\square$

**Corollary 5.2 (Integral-scale stabilization).** For every nonnegative integer $n$,

$$
\operatorname{Corner}\bigl((n+1)F\bigr)
=
\operatorname{Corner}(F).
$$

Thus the sequence of corner loci indexed by positive integral scales is constant.

The corollary gives an exact setwise interpretation of an infinite-scale limit: if $n\to\infty$, the corner set does not merely converge to a limiting set; it equals that set at every stage. This captures the scale-independent combinatorics of tropical dominance.

Care is required in interpreting this statement. It concerns a common positive rescaling of already real-valued tropical terms. It does not alone establish convergence of a family of classical varieties, convergence in Hausdorff distance, or convergence of amoebas under logarithmic maps. Such statements involve a varying classical family and a topology on closed sets. The present theorem supplies a stable target skeleton once the order data have been extracted.

**Example 5.3.** For

$$
F(x,y)=\max\{0,x,y\},
$$

rescaling gives

$$
F_c(x,y)=\max\{0,cx,cy\}=cF(x,y)
$$

for $c>0$. The three rays of the tropical line remain fixed, although all nonzero function values are stretched by $c$.

## 6. Multiplicity-preserving correspondences and Bézout transfer

We now turn from loci to counts. Let $S$ and $T$ be finite sets, interpreted respectively as classical and tropical intersection points. Let

$$
\phi:S\longrightarrow T
$$

be a bijection. Assign multiplicity functions

$$
m_S:S\to\mathbb{N}, \qquad m_T:T\to\mathbb{N}.
$$

**Theorem 6.1 (Weighted intersection number is invariant under multiplicity-preserving correspondence).** If

$$
m_S(p)=m_T(\phi(p)) \quad\text{for every }p\in S,
$$

then

$$
I(S,m_S)=I(T,m_T).
$$

**Proof sketch.** Reindex the finite sum over $T$ through the bijection $\phi$:

$$
\sum_{q\in T}m_T(q)
=
\sum_{p\in S}m_T(\phi(p))
=
\sum_{p\in S}m_S(p).
$$

No geometric assumptions beyond finiteness, bijectivity, and preservation of weights are used. $\square$

This theorem also applies when $S$ and $T$ are finite subsets of larger ambient point spaces and $\phi$ is an ambient equivalence that restricts to a bijection between them. Membership preservation ensures that reindexing covers exactly the desired points.

**Theorem 6.2 (Conditional tropical Bézout transfer).** Let two classical plane curves have degrees $d$ and $e$. Suppose their relevant classical intersection set $S$ is finite and has local multiplicities $m_S$ satisfying

$$
I(S,m_S)=de.
$$

Let $T$ be a finite tropical intersection set with multiplicities $m_T$. If there is a bijection $\phi:S\to T$ such that

$$
m_S(p)=m_T(\phi(p))
$$

for every $p\in S$, then

$$
I(T,m_T)=de.
$$

**Proof sketch.** Theorem 6.1 gives $I(T,m_T)=I(S,m_S)$. Substitute the classical Bézout count $I(S,m_S)=de$. $\square$

The theorem is intentionally conditional. Classical Bézout itself requires an appropriate projective and proper intersection setting, with common components excluded or treated separately. Tropical Bézout requires balanced curves, stable intersections, and suitable local multiplicities. Establishing a pointwise or fiberwise correspondence is substantial geometry. The theorem isolates the final universal counting step: once a multiplicity-preserving correspondence is known, the global number transfers automatically.

A fiberwise formulation can be more natural because several classical points may tropicalize to one tropical point. In that setting, one replaces pointwise equality by

$$
m_T(q)=\sum_{p\in \phi^{-1}(q)}m_S(p).
$$

Summing over $q\in T$ again gives equality of total weights. This broader formulation is a natural extension of the bijective result.

## 7. Algorithms and numerical demonstrations

The preceding theorems lead to finite algorithms that expose their combinatorial content.

### 7.1. Corner detection

Given numerical values $F_1(x),\ldots,F_m(x)$ at a point $x$, compute

$$
M=\max_{1\leq i\leq m}F_i(x)
$$

and collect all indices with value $M$. The point is a corner exactly when at least two indices are collected. For exact integer or rational inputs, equality is exact. For floating-point inputs, one may use a tolerance, but then the result is numerical evidence rather than an exact decision.

The algorithm uses $O(m)$ time and $O(m)$ output space in the worst case. To test positive-scale invariance numerically, run the same procedure on $cF_i(x)$ for $c>0$ and compare the maximizing index sets. Exact arithmetic guarantees equality of those sets.

For a grid of $N$ points and $m$ terms, evaluation and classification cost $O(Nm)$, excluding the cost of computing each term. Applied to affine terms in two variables, this produces a pixel approximation of a tropical curve.

### 7.2. Detecting a unique maximal prime-adic norm

For a nonzero integer $a$, define its $p$-adic order by

$$
\operatorname{ord}_p(a)=\max\{k\in\mathbb{N}:p^k\mid a\}
$$

and its norm by

$$
|a|_p=p^{-\operatorname{ord}_p(a)}.
$$

For a finite list of nonzero integers summing to zero, compute each order. Since larger norm means smaller order, the maximal norm occurs at the indices having minimal $p$-adic order. Theorem 3.1 predicts that the minimum order occurs at least twice. The computation needs $O(m\log_p A)$ elementary divisibility steps when $A$ bounds the absolute values of the inputs.

For example, with $p=2$ and terms

$$
12,\quad 20,\quad -32,
$$

we have orders $2,2,5$ and norms $2^{-2},2^{-2},2^{-5}$. The maximum norm is attained twice, as required.

### 7.3. Weighted correspondence checking

Given paired records

$$
(p,\phi(p),m_S(p),m_T(\phi(p))),
$$

check that the source and target labels are each unique, that every desired point appears, and that paired weights agree. Then sum either side. With hashable labels, this takes expected $O(N)$ time and $O(N)$ memory for $N$ pairs. If the classical total equals $de$, the checked correspondence certifies that the tropical total computed from those records also equals $de$.

As a numerical illustration, classical multiplicities $[1,2,1,2]$ and tropical multiplicities $[2,1,2,1]$ may be paired by a suitable permutation. Both totals are $6$, matching degrees $d=2$ and $e=3$.

## 8. Applications and conceptual consequences

### 8.1. Polyhedral localization of algebraic zeros

Theorem 4.1 reduces the possible valuation vectors of zeros to a polyhedral corner locus. When term valuations become affine in logarithmic coordinates, regions with a unique dominant monomial contain no valuation image of a zero. This gives a powerful exclusion principle: one can study the much simpler arrangement of affine dominance regions instead of solving the original equations directly.

### 8.2. Robustness under units of scale

Theorem 5.1 shows that tropical hypersurfaces depend on order comparisons among term values, not on a common positive unit of measurement. This is valuable both conceptually and computationally. Normalizing all coefficients by a positive factor or changing a logarithmic base multiplies tropical values by a positive constant and therefore leaves the corner set unchanged.

### 8.3. Separation of geometric and combinatorial tasks

Theorem 6.2 separates tropical Bézout into two components. The geometric component constructs a proper correspondence and proves local multiplicity preservation. The combinatorial component transfers the weighted total. This division clarifies proof design: global counting introduces no additional mystery after local compatibility has been established.

### 8.4. Sparse computation

Only finitely many supported monomials participate in the cancellation theorem. For sparse polynomials, corner detection depends on the number of terms rather than the size of a dense degree box. This sparsity is one reason tropical methods can reveal structure in systems whose direct symbolic manipulation is expensive.

## 9. Scope and limitations

The results proved here are broad but carefully delimited.

First, the valuation-to-corner theorem proves one inclusion. It says every suitable classical zero yields a tropical corner. It does not show every corner lifts to a zero. Reverse inclusion is a separate lifting problem.

Second, exact invariance under common positive scaling is a theorem about tropical term families. It is not a substitute for an analytic convergence theorem involving a varying classical zero set. A claim of Hausdorff convergence must specify the family, normalization, topology, and compactness regime.

Third, the Bézout result is conditional on a finite multiplicity-preserving bijection. In many natural degenerations, tropicalization is not injective on classical intersection points; a fiberwise multiplicity theorem is then required. The weighted-bijection theorem remains the exact special case where each tropical point receives one classical partner.

Fourth, the finite-sum theorem assumes nonzero terms. For Laurent polynomials on a torus this is natural. For ordinary polynomials at points with zero coordinates, vanishing monomial terms should be removed or handled separately.

These boundaries prevent stronger geometric claims from being inferred from purely order-theoretic or combinatorial arguments. They also identify precise targets for further work.

## 10. Future directions

A first objective is the reverse hypersurface inclusion for Laurent polynomials: over an algebraically closed, complete, nontrivially valued field, one seeks to lift every max-corner point to the valuation vector of a zero, possibly after passage to a completed algebraic closure.

A second objective is analytic convergence. For a fixed complex Laurent polynomial and logarithmic maps

$$
\operatorname{Log}_t(z)=
\left(\frac{\log|z_1|}{\log t},\ldots,
\frac{\log|z_n|}{\log t}\right),
$$

one seeks Hausdorff convergence on compact polytopes of logarithmic zero sets to the tropical corner locus as $t\to\infty$.

A third objective is stable tropical Bézout: for balanced tropical plane curves of degrees $d$ and $e$, with integral edge weights and no common component, the sum of stable local intersection multiplicities should be shown directly to equal $de$.

A fourth objective is a fiberwise multiplicity theorem. For proper zero-dimensional intersections over an algebraically closed complete non-Archimedean field, the sum of classical local multiplicities over each tropical point should equal its stable tropical multiplicity. This would replace the bijective hypothesis by the more natural many-to-one tropicalization map.

Finally, product rules for corner loci should be extended beyond ordered additive groups to cancellative ordered additive commutative monoids, assuming finite term families attain their extrema. Such an extension would clarify which tropical identities genuinely require additive inverses.

## 11. Conclusion

Three short principles explain a substantial part of the classical-to-tropical bridge. A uniquely dominant non-Archimedean term cannot disappear in a vanishing sum; therefore valuation images of classical zeros lie on tropical corners. A common positive rescaling preserves every dominance comparison; therefore tropical corner loci stabilize exactly at all positive scales. A multiplicity-preserving finite correspondence reindexes a weighted sum; therefore classical intersection counts transfer to tropical ones, including a conditional Bézout number $de$.

These statements are elementary in form but structurally decisive. They locate the universal algebraic, order-theoretic, and combinatorial components of tropicalization, while cleanly exposing the remaining geometric work: lifting corners, proving convergence, and constructing multiplicity-preserving correspondences.
