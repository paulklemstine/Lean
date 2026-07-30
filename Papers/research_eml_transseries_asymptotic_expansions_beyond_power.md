# Hahn-Series Foundations for Three-Level Exponential–Polynomial–Logarithmic Expansions

**Aristotle**  
**30 July 2026**

## Abstract

We develop a three-level formal model for asymptotic expansions whose ranks encode exponential, polynomial, and logarithmic growth. The rank group is the lexicographically ordered abelian group $\Gamma=\mathbb Z\times_{\mathrm{lex}}(\mathbb Z\times_{\mathrm{lex}}\mathbb Z)$, and the expansions are real-coefficient Hahn series over $\Gamma$. We define agreement below a rank and agreement to all orders, then prove an asymptotic comparison theorem: two expansions agree to all orders if and only if they are equal. More sharply, any unequal pair has a first formal disagreement, namely the order of its difference; all lower coefficients coincide, while the coefficient at that order differs. We also establish the coefficient law for single transmonomials, nonvanishing and rank separation for monomials, vanishing below the order, the absence of nonzero flat series, and compatibility of all-order agreement with addition and multiplication. Sparse algorithms for finite representations illustrate these results and make their computational content explicit. The model supplies the uniqueness and comparison layer required by broader theories of exponential–logarithmic transseries. It does not, by itself, construct recursive exponential towers, composition, logarithm, exponential, expansions of all exponential–logarithmic functions, or a real-closed field; those remain separate extensions.

## 1. Introduction

Classical power series organize local behavior using the integer scale $1,x,x^2,\ldots$. Asymptotic problems frequently demand a richer hierarchy. The functions $\log x$, $x^a$, $e^x$, and $e^{e^x}$ occupy qualitatively different growth levels as $x\to+\infty$, while products and quotients combine those levels. Transseries are designed to record such behavior in formal expansions whose monomials belong to an ordered multiplicative group.

This paper studies a deliberately bounded but rigorous model. Three integer coordinates encode successive growth levels, interpreted as exponential, polynomial, and logarithmic. The resulting rank set is lexicographically ordered. Real coefficients indexed by these ranks form Hahn series, subject to a well-ordered-support condition. The latter condition provides a leading rank for every nonzero series and thereby supports a valuation-like comparison theory.

The principal question is uniqueness. If two formal asymptotic expansions agree at every rank, must they be the same expansion? The answer is yes, because Hahn series are coefficient-extensional. A more informative theorem locates the obstruction to equality: unequal series have a least rank of disagreement. This rank is exactly the order of their difference.

The distinction between uniqueness and existence is essential. The present framework proves that coefficient data uniquely determine a series already inside the model. It does not assert that every exponential–logarithmic function has such an expansion, nor that the three-coordinate class is closed under functional composition, exponentiation, or logarithms. It also does not establish real closedness. Those claims require further definitions and arguments. By separating the comparison layer from those larger goals, the current theory provides a clean foundation on which they may later be built.

The paper proceeds as follows. Section 2 defines the ordered rank group and Hahn series. Section 3 introduces coefficient agreement and order. Section 4 treats transmonomials. Section 5 proves vanishing below order and the first-disagreement theorem. Section 6 derives all-order comparison and no-flatness. Section 7 shows arithmetic compatibility. Section 8 presents sparse algorithms and numerical examples. Sections 9 and 10 discuss applications, limitations, and future development.

## 2. Ordered ranks and Hahn series

### 2.1. The rank group

Let

$$
\Gamma=\mathbb Z\times_{\mathrm{lex}}(\mathbb Z\times_{\mathrm{lex}}\mathbb Z).
$$

An element $r\in\Gamma$ is a triple $r=(e,p,\ell)$. Addition is coordinatewise:

$$
(e,p,\ell)+(e',p',\ell')=(e+e',p+p',\ell+\ell').
$$

The order is lexicographic. Explicitly,

$$
(e,p,\ell)<(e',p',\ell')
$$

if and only if either $e<e'$, or $e=e'$ and $p<p'$, or $e=e'$, $p=p'$, and $\ell<\ell'$. This is a total order compatible with group addition.

The three coordinates may be interpreted as exponential, polynomial, and logarithmic levels. That interpretation motivates the construction, but all the results below depend only on the ordered-group structure.

### 2.2. Formal expansions

For each $r\in\Gamma$, write $\mathfrak m^r$ for a formal transmonomial. A **three-level transseries** is a formal sum

$$
F=\sum_{r\in\Gamma} a_r\mathfrak m^r,
\qquad a_r\in\mathbb R,
$$

whose support

$$
\operatorname{supp}(F)=\{r\in\Gamma:a_r\ne0\}
$$

is well ordered. Thus every nonempty subset of $\operatorname{supp}(F)$ has a least member. We denote the coefficient $a_r$ by $[\mathfrak m^r]F$.

Two such series are equal precisely when their coefficients agree at every rank. Addition is coefficientwise:

$$
[\mathfrak m^r](F+G)=[\mathfrak m^r]F+[\mathfrak m^r]G.
$$

Negation and subtraction are likewise coefficientwise. Multiplication is the Hahn convolution

$$
[\mathfrak m^r](FG)
=
\sum_{u+v=r} [\mathfrak m^u]F\,[\mathfrak m^v]G.
$$

The well-ordered-support hypotheses ensure that this construction defines a series and that the coefficient sum is meaningful in the Hahn-series sense.

### 2.3. Order

For a nonzero transseries $F$, its **order** is the least occupied rank:

$$
\operatorname{ord}(F)=\min\operatorname{supp}(F).
$$

The ambient Hahn-series convention may assign a distinguished order to the zero series, but every result that uses a nonzero leading coefficient explicitly assumes nonzeroness. For nonzero $F$,

$$
[\mathfrak m^{\operatorname{ord}(F)}]F\ne0.
$$

Order is the mechanism that converts an infinite formal object into a finite certificate: the least nonzero coefficient.

## 3. Agreement relations

### Definition 3.1 (Agreement below a cut)

For transseries $F,G$ and a rank $q\in\Gamma$, we say that **$F$ and $G$ agree below $q$** if

$$
[\mathfrak m^r]F=[\mathfrak m^r]G
\qquad\text{for every }r<q.
$$

No assertion is made at $q$ or above it.

### Definition 3.2 (Agreement to all orders)

We say that **$F$ and $G$ agree to all orders** if

$$
[\mathfrak m^r]F=[\mathfrak m^r]G
\qquad\text{for every }r\in\Gamma.
$$

Agreement to all orders is coefficientwise identity across the entire ordered scale. In analytic asymptotics, “to all orders” can sometimes leave room for a flat remainder. In the present formal setting it cannot, because the coefficient function is the series itself.

### Remark 3.3

The terminology is formal and rank-based. No evaluation map $x\mapsto F(x)$ is required. Consequently, the results concern equality of formal expansions, not equality of functions on a numerical domain. If an external expansion theorem associates functions injectively with these series, the comparison results can then transfer to functions, but such an expansion theorem lies outside the present assumptions.

## 4. Single transmonomials

### Definition 4.1 (Single transmonomial)

For $q\in\Gamma$ and $c\in\mathbb R$, define $M_{q,c}$ by

$$
[\mathfrak m^r]M_{q,c}=
\begin{cases}
c,&r=q,\\
0,&r\ne q.
\end{cases}
$$

Equivalently, $M_{q,c}=c\mathfrak m^q$.

### Theorem 4.2 (Coefficient at the designated rank)

For every $q\in\Gamma$ and $c\in\mathbb R$,

$$
[\mathfrak m^q]M_{q,c}=c.
$$

**Proof sketch.** This is immediate from the defining coefficient function of a single transmonomial. $\square$

### Corollary 4.3 (Nonvanishing)

If $c\ne0$, then $M_{q,c}\ne0$.

**Proof sketch.** Its coefficient at $q$ equals the nonzero scalar $c$, whereas every coefficient of the zero series is zero. $\square$

### Theorem 4.4 (Separation of distinct ranks)

Let $r,s\in\Gamma$ satisfy $r\ne s$, and let $a,b\in\mathbb R$. If $a\ne0$, then

$$
M_{r,a}\ne M_{s,b}.
$$

**Proof sketch.** Compare coefficients at rank $r$. The left series has coefficient $a$. Since $r\ne s$, the right series has coefficient $0$ there. Equality would force $a=0$, contrary to hypothesis. $\square$

This theorem confirms that ranks are observable through coefficients. Distinct formal scales cannot be collapsed when one carries a nonzero coefficient.

## 5. Order and first disagreement

### Lemma 5.1 (Vanishing below order)

Let $F$ be a transseries and let $r\in\Gamma$. If

$$
r<\operatorname{ord}(F),
$$

then

$$
[\mathfrak m^r]F=0.
$$

**Proof sketch.** If the coefficient at $r$ were nonzero, then $r$ would lie in the support of $F$. By minimality of the order, one would have $\operatorname{ord}(F)\le r$, contradicting $r<\operatorname{ord}(F)$. $\square$

### Theorem 5.2 (Agreement below the order of a difference)

For any transseries $F$ and $G$, the two series agree below $\operatorname{ord}(F-G)$. Equivalently,

$$
r<\operatorname{ord}(F-G)
\quad\Longrightarrow\quad
[\mathfrak m^r]F=[\mathfrak m^r]G.
$$

**Proof sketch.** By Lemma 5.1, the coefficient of $F-G$ at such an $r$ is zero. Coefficientwise subtraction gives

$$
0=[\mathfrak m^r](F-G)
=[\mathfrak m^r]F-[\mathfrak m^r]G,
$$

which is equivalent to equality of the two coefficients. $\square$

### Theorem 5.3 (Disagreement at the order of a nonzero difference)

If $F\ne G$, then

$$
[\mathfrak m^{\operatorname{ord}(F-G)}]F
\ne
[\mathfrak m^{\operatorname{ord}(F-G)}]G.
$$

**Proof sketch.** The hypothesis implies $F-G\ne0$. A nonzero Hahn series has a nonzero coefficient at its order. Hence

$$
[\mathfrak m^{\operatorname{ord}(F-G)}](F-G)\ne0.
$$

Expanding the coefficient of the difference yields the desired inequality. $\square$

### Theorem 5.4 (First Disagreement Theorem)

If $F\ne G$, there exists $q\in\Gamma$ such that:

1. $F$ and $G$ agree below $q$; and
2. $[\mathfrak m^q]F\ne[\mathfrak m^q]G$.

One may choose

$$
q=\operatorname{ord}(F-G).
$$

**Proof sketch.** Choose the stated $q$. The first assertion is Theorem 5.2, and the second is Theorem 5.3. $\square$

The theorem gives both existence and a canonical formula for the first discrepancy. Its force comes from the well-ordering of support. In an arbitrary coefficient system without that condition, a nonzero difference could have nonzero ranks but no least nonzero rank.

### Corollary 5.5 (Finite witness of inequality)

Inequality of two transseries has a certificate consisting of one rank $q$ and the pair of unequal real numbers

$$
[\mathfrak m^q]F,
\qquad
[\mathfrak m^q]G.
$$

Moreover, the canonical least certificate is the order of $F-G$.

**Proof sketch.** Apply Theorem 5.4. $\square$

## 6. All-order comparison and flatness

### Theorem 6.1 (Asymptotic Comparison Theorem)

For transseries $F$ and $G$, the following are equivalent:

1. $F$ and $G$ agree to all orders;
2. $F=G$.

**Proof sketch.** If all coefficients agree, coefficient extensionality for formal series gives equality. Conversely, substituting equal series into any coefficient map gives equal coefficients at every rank. Alternatively, if all coefficients agreed but $F\ne G$, the First Disagreement Theorem would produce a rank at which they differ, a contradiction. $\square$

### Theorem 6.2 (No nonzero flat transseries)

If a transseries $F$ satisfies

$$
[\mathfrak m^r]F=0
\qquad\text{for every }r\in\Gamma,
$$

then $F=0$.

**Proof sketch.** The hypothesis says that $F$ agrees to all orders with the zero series. Theorem 6.1 then gives $F=0$. Equivalently, apply coefficient extensionality directly. $\square$

### Discussion of flatness

Theorem 6.2 should not be confused with a theorem about arbitrary smooth functions. A smooth function can have a zero Taylor series while remaining nonzero away from its expansion point. The standard example is

$$
f(x)=
\begin{cases}
e^{-1/x^2},&x>0,\\
0,&x\le0.
\end{cases}
$$

Every derivative of $f$ at $0$ vanishes. The present no-flatness result holds because a formal Hahn series is defined by its coefficients. To claim no-flatness for a class of functions, one would additionally need a faithful map from those functions into the transseries model.

## 7. Compatibility with arithmetic

### Theorem 7.1 (Additive compatibility)

Suppose $F_1$ agrees to all orders with $G_1$, and $F_2$ agrees to all orders with $G_2$. Then $F_1+F_2$ agrees to all orders with $G_1+G_2$.

**Proof sketch.** At each rank $r$, coefficientwise addition gives

$$
[\mathfrak m^r](F_1+F_2)
=[\mathfrak m^r]F_1+[\mathfrak m^r]F_2.
$$

Replace each coefficient using the two hypotheses, then reverse the coefficient formula for $G_1+G_2$. $\square$

### Theorem 7.2 (Multiplicative compatibility)

Under the same hypotheses, $F_1F_2$ agrees to all orders with $G_1G_2$.

**Proof sketch.** By Theorem 6.1, the hypotheses imply $F_1=G_1$ and $F_2=G_2$. Multiplication preserves equality, so $F_1F_2=G_1G_2$. The reverse direction of Theorem 6.1 then gives agreement of every product coefficient. $\square$

### Corollary 7.3 (Congruence of complete agreement)

Agreement to all orders is an equivalence relation compatible with the ring operations. Thus algebraic expressions formed from completely agreeing inputs by addition, subtraction, and multiplication continue to agree to all orders.

**Proof sketch.** Reflexivity, symmetry, and transitivity hold coefficientwise. Addition and multiplication are Theorems 7.1 and 7.2; subtraction follows from addition and negation. $\square$

## 8. Algorithms and numerical demonstrations

Exact Hahn series may have infinite support, so a general implementation requires symbolic descriptions. Finite sparse series nevertheless exhibit the comparison theorems exactly and are useful for experimentation.

### 8.1. Sparse representation

Represent a rank $r=(e,p,\ell)$ by an integer triple. The host language’s lexicographic tuple order realizes the order on $\Gamma$. Represent a finite transseries by a map from ranks to nonzero floating-point coefficients. Zero entries are removed after a tolerance test.

For $n$ stored terms, normalization takes expected time $O(n)$ using a hash map. Sorting all occupied ranks costs $O(n\log n)$. Coefficient lookup has expected cost $O(1)$.

### 8.2. First-disagreement algorithm

Given sparse series $F$ and $G$:

1. form the union $U$ of their stored ranks;
2. sort $U$ lexicographically;
3. scan ranks in increasing order;
4. return the first rank $r$ with $|F_r-G_r|$ exceeding a chosen numerical tolerance;
5. if no such rank exists, declare the finite representations equal within tolerance.

If $n=|U|$, the sorting implementation costs $O(n\log n)$ time and $O(n)$ auxiliary space. If both inputs are already stored as sorted lists, a merge scan finds the first disagreement in $O(n)$ time.

The tolerance belongs to numerical demonstration, not to the exact theorem. Exact rational or symbolic coefficients permit exact zero tests.

### 8.3. Sparse addition and multiplication

Addition combines coefficients at matching ranks, requiring expected $O(n+m)$ time for hash-map inputs of sizes $n$ and $m$.

Multiplication uses the group law on ranks:

$$
(e,p,\ell)+(e',p',\ell')=(e+e',p+p',\ell+\ell').
$$

Every input pair contributes a product coefficient, so the direct sparse convolution costs $O(nm)$ arithmetic operations and uses up to $O(nm)$ output storage before collisions are combined.

### 8.4. Example: locating the first difference

Let

$$
F=2\mathfrak m^{(0,0,0)}-3\mathfrak m^{(0,1,-1)}
+5\mathfrak m^{(1,-2,0)},
$$

and

$$
G=2\mathfrak m^{(0,0,0)}-3\mathfrak m^{(0,1,-1)}
+7\mathfrak m^{(1,-2,0)}.
$$

At $(0,0,0)$ and $(0,1,-1)$ the coefficients agree. At $(1,-2,0)$ they are $5$ and $7$. Therefore

$$
\operatorname{ord}(F-G)=(1,-2,0),
$$

and this is the first disagreement.

### 8.5. Example: arithmetic compatibility

Let $F_1=G_1$ and $F_2=G_2$ be represented by separately allocated but coefficient-identical sparse maps. Addition produces identical output maps. Convolution also produces identical output maps, even when multiple pairs of input ranks collide at the same sum rank. This numerically illustrates Theorems 7.1 and 7.2.

### 8.6. Example: rank separation

For $r=(0,2,0)$, $s=(1,-5,3)$, and $a=4$, the series $M_{r,4}$ has coefficient $4$ at $r$, while $M_{s,b}$ has coefficient $0$ at $r$ for every $b$. Thus a single lookup witnesses their inequality.

### 8.7. Correctness of the finite comparison procedure

For finite sparse inputs with exact coefficients, the first-disagreement algorithm is not merely illustrative; it is a decision procedure for equality in the finite subcase. Let $U$ be the finite union of the two supports. If the algorithm returns a rank $q$, every earlier element of the sorted set $U$ has equal coefficients, and ranks outside $U$ have coefficient zero in both inputs. Hence the two inputs agree below $q$ and differ at $q$. If the algorithm reaches the end without returning a rank, the coefficients agree on $U$ and vanish jointly outside $U$, so the series are equal by the Asymptotic Comparison Theorem.

Floating-point execution weakens this conclusion to tolerance-relative comparison. A coefficient difference smaller than the tolerance may be treated as zero, and roundoff during convolution may create or erase tiny residuals. For mathematically exact demonstrations, integer, rational, algebraic, or symbolic coefficients should therefore be preferred. The supplied numerical implementation displays the tolerance explicitly so that this distinction remains visible.

### 8.8. Canonical normalization

A sparse representation is normalized by combining repeated ranks and deleting zero coefficients. Normalization does not alter the represented transseries, since coefficients at equal ranks add and zero coefficients contribute nothing. After normalization, two finite maps are equal exactly when they contain the same rank–coefficient pairs. The first-disagreement routine can thus be viewed as an ordered diagnostic refinement of ordinary map equality: rather than returning only a Boolean value, it returns the least mathematical reason for failure.

## 9. Applications and interpretation

### 9.1. Multiscale asymptotic bookkeeping

When models contain several growth regimes, the first-disagreement rank identifies the earliest scale at which their predictions diverge. The three coordinates can label broad exponential, polynomial, and logarithmic layers. Within this interpretation, the theorem turns a global inequality into a sharply localized diagnostic.

### 9.2. Symbolic computation

Sparse symbolic systems routinely use leading terms to guide reduction, normalization, and comparison. The order of $F-G$ is a canonical comparison key. If it does not exist because $F=G$, all coefficients agree; otherwise, it supplies an explicit witness. This can support regression tests for algebraic transformations and canonical-form procedures.

### 9.3. Valuation-style reasoning

The order behaves like a valuation-oriented leading exponent. Vanishing below order is the basic valuation principle, and first disagreement is its comparison consequence. The construction therefore connects asymptotic series with methods familiar from valued fields, generalized power series, and non-Archimedean geometry.

### 9.4. Uniqueness layer for expression semantics

Suppose a future semantics assigns a transseries $\mathcal T(E)$ to each admissible exponential–logarithmic expression $E$. Once existence and compatibility are proved, Theorem 6.1 gives immediate uniqueness: any two candidate expansions whose coefficients agree at every rank must be equal. The present work supplies precisely this last step, but not the proposed semantics itself.

## 10. Scope, limitations, and future work

The exact achievements are confined to the real-coefficient Hahn-series model over the three-level rank group $\Gamma$. They include:

1. coefficient characterization of transmonomials;
2. nonvanishing of nonzero monomials;
3. separation of monomials at distinct ranks;
4. vanishing of coefficients below series order;
5. agreement below the order of a difference;
6. disagreement at that order for unequal series;
7. existence of a first disagreement;
8. equality from all-order agreement;
9. absence of nonzero flat series; and
10. additive and multiplicative compatibility of all-order agreement.

Several broader goals require additional work. First, three integer coordinates do not represent arbitrary finite or transfinite nesting of exponentials and logarithms. A full monomial group should be generated recursively and equipped with an appropriate order.

Second, composition, logarithm, and exponential must be constructed on suitable subfields, with proofs that supports remain admissible. These operations are subtler than Hahn addition and multiplication.

Third, one needs a syntax of admissible exponential–logarithmic expressions, including domain conditions, and a structural expansion theorem. Such a theorem would establish existence of compatible transseries rather than merely uniqueness once coefficients are supplied.

Fourth, ordered-field and valuation infrastructure would be needed for a real-closedness theorem. No real-closedness conclusion follows solely from the comparison results proved here.

These limitations sharpen rather than diminish the contribution: the paper isolates the coefficient-comparison foundation and states exactly what it supports.

## 11. Conclusion

Three lexicographically ordered integer coordinates provide a transparent model of exponential, polynomial, and logarithmic ranks. Real Hahn series over this group admit a least nonzero rank whenever they are nonzero. From that single structural fact follows a complete comparison theory.

Below the order of a difference, two series agree. If they are unequal, they disagree at that order. Hence every unequal pair has a first formal disagreement. Conversely, agreement at every rank forces equality, and a series with all coefficients zero must itself vanish. These statements remain stable under addition and multiplication.

The result is a rigorous uniqueness layer for multiscale formal asymptotics. It does not yet constitute the full theory of exponential–logarithmic transseries, but it supplies the comparison principle such a theory needs: infinite expansions remain distinguishable because inequality always appears at a first rank.