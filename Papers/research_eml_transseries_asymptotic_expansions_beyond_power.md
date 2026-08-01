# Integer-Ranked Hahn Transseries: Unique Asymptotic Comparison, a Real-Closedness Obstruction, and the Limits of Pointwise Semantics

**Aristotle**  
**July 31, 2026**

## Abstract

We study a concrete Hahn-series model for finite-level transseries with real coefficients and lexicographically ordered integer growth ranks

$$
\Gamma=\mathbb Z\times_{\mathrm{lex}}(\mathbb Z\times_{\mathrm{lex}}\mathbb Z).
$$

Three claims that are sometimes conflated in broad transseries programs are separated. First, the exact asymptotic comparison principle is strengthened: every unequal pair of series has a unique first rank at which its coefficients differ. This follows from well-ordered support and totality of the rank order, and yields a canonical finite witness of inequality. Second, the field is not real closed. The monomial at rank $(1,0,0)$ is not a square, since the order of a nonzero square is twice the order of its root and hence has even first coordinate; its negative has the same obstruction. This contradicts the real-closed-field property that one of $a$ and $-a$ is a square. Third, evaluation of raw exponential–logarithmic expressions at a single point is not injective: the variable and constant zero are distinct expressions but coincide at zero. We give comparison and obstruction-detection algorithms, discuss analytic interpretation and computational applications, and formulate corrected programs based on divisible value groups and eventual germs at $+\infty$.

## 1. Introduction

Ordinary power series organize local behavior into integer powers of a variable. They are powerful precisely because their monomials are ordered by scale: near the expansion point, the first nonzero coefficient controls the leading behavior. Yet many asymptotic problems involve functions outside any fixed power scale. Logarithms grow more slowly than positive powers, exponentials grow faster than all powers, and iterated exponentials introduce further levels. Transseries seek to place these scales in a common algebraic and ordered framework.

This ambition contains several mathematically distinct questions. Does the formal series representation admit exact coefficientwise comparison? Is the resulting field real closed? Does an expansion uniquely determine the expression or function from which it arose? Positive answers require different hypotheses. The present paper makes that separation explicit in a finite-level Hahn-series model.

Our rank group is the lexicographically ordered abelian group

$$
\Gamma=\mathbb Z\times_{\mathrm{lex}}(\mathbb Z\times_{\mathrm{lex}}\mathbb Z).
$$

The three integer coordinates may be viewed as abstract growth levels. The results do not require a fixed interpretation of those levels as exponentials, powers, or logarithms; only the ordered-group structure matters. A transseries is a real-coefficient Hahn series indexed by $\Gamma$, namely a formal sum with well-ordered support.

The first main result is positive. If two series differ, their coefficient functions differ on a nonempty set of ranks. Because the relevant support is well ordered, this set has a least element. That element is the first disagreement rank. Totality of the order makes it unique. Thus agreement “to all ranks” implies equality, while inequality always has a canonical leading witness.

The second result identifies a sharp obstruction to real closedness. In every nonzero Hahn series product, orders add. Hence a square has order twice a rank. But $(1,0,0)$ is not twice any element of the integer rank group. The monomial at that rank is therefore not a square, and neither is its negative. A real closed field cannot contain such an element. The issue is the nondivisibility of the rank group, suggesting rational rather than integer coordinates for a corrected real-closedness program.

The third result concerns semantics rather than field structure. Any claim that a single point value uniquely determines raw expression syntax fails immediately: the variable expression and constant zero are distinct but agree at zero. More sophisticated identities make raw syntax still less appropriate. A viable uniqueness theorem should concern normalized expansions of eventual germs, or expressions modulo eventual equality on a controlled domain.

The paper is organized as follows. Section 2 defines ranks, Hahn series, order, first disagreement, expression evaluation, and real closedness. Section 3 proves the comparison theorem. Section 4 proves the square obstruction and failure of real closedness. Section 5 isolates the failure of point-evaluation injectivity and proposes corrected semantics. Section 6 presents finite algorithms. Sections 7 and 8 discuss examples and applications, while Sections 9 and 10 set out limitations and future directions.

## 2. Definitions and structural facts

### 2.1. Lexicographic growth ranks

Let

$$
\Gamma=\mathbb Z^3
$$

as an additive abelian group, and equip it with lexicographic order. For ranks $\alpha=(a_1,a_2,a_3)$ and $\beta=(b_1,b_2,b_3)$, declare $\alpha<\beta$ if and only if one of the following holds:

1. $a_1<b_1$;
2. $a_1=b_1$ and $a_2<b_2$;
3. $a_1=b_1$, $a_2=b_2$, and $a_3<b_3$.

This is a total order compatible with addition. We write it suggestively as

$$
\mathbb Z\times_{\mathrm{lex}}(\mathbb Z\times_{\mathrm{lex}}\mathbb Z).
$$

The group is not divisible: for example, there is no $\delta\in\Gamma$ such that $2\delta=(1,0,0)$.

### 2.2. Hahn transseries

A **Hahn transseries** over $\Gamma$ with real coefficients is a formal expression

$$
F=\sum_{\gamma\in\Gamma} a_\gamma t^\gamma,
$$

where $a_\gamma\in\mathbb R$ and the support

$$
\operatorname{supp}(F)=\{\gamma\in\Gamma:a_\gamma\ne0\}
$$

is well ordered by the rank order. The coefficient of $F$ at $\gamma$ is denoted $[t^\gamma]F=a_\gamma$.

Addition is coefficientwise. Multiplication is the convolution determined by

$$
t^\alpha t^\beta=t^{\alpha+\beta}.
$$

The support condition makes the relevant coefficient sums well behaved and yields a field in the standard Hahn-series construction because the coefficient system is a field and $\Gamma$ is an ordered abelian group.

A **monomial** of rank $\gamma$ and coefficient $c\ne0$ is the one-term series $ct^\gamma$. The coefficient-$1$ monomial is simply $t^\gamma$.

### 2.3. Order

For nonzero $F$, define its order by

$$
\operatorname{ord}(F)=\min\operatorname{supp}(F).
$$

The minimum exists because the support is nonempty and well ordered. The decisive multiplicative property is the following.

**Lemma 2.1 (Order of a product).** If $F$ and $G$ are nonzero Hahn transseries, then

$$
\operatorname{ord}(FG)=\operatorname{ord}(F)+\operatorname{ord}(G).
$$

**Proof sketch.** Let $\alpha=\operatorname{ord}(F)$ and $\beta=\operatorname{ord}(G)$. All occupied ranks of $F$ are at least $\alpha$, and all occupied ranks of $G$ are at least $\beta$, so no product contribution can occur below $\alpha+\beta$. At rank $\alpha+\beta$, the product of the two leading coefficients contributes a nonzero value. Ordered-group compatibility and the minimality of $\alpha$ and $\beta$ exclude a lower term. Hence $\alpha+\beta$ is the least occupied rank of the product. $\square$

Taking $G=F$ gives an immediate corollary.

**Corollary 2.2 (Order of a square).** If $F\ne0$, then

$$
\operatorname{ord}(F^2)=2\operatorname{ord}(F).
$$

### 2.4. Agreement below a rank

For transseries $F$ and $G$ and a rank $\rho$, say that **$F$ and $G$ agree below $\rho$** when

$$
[t^\gamma]F=[t^\gamma]G
\quad\text{for every }\gamma<\rho.
$$

A rank $\rho$ is a **first disagreement rank** for $F$ and $G$ if they agree below $\rho$ but

$$
[t^\rho]F\ne[t^\rho]G.
$$

This definition records both the agreement of all earlier coefficients and the actual disagreement at the candidate rank.

### 2.5. Real closed fields

An ordered field $K$ is **real closed** if it has no proper algebraic ordered extension; equivalently, every positive element is a square and every odd-degree polynomial has a root in $K$. We use only the following necessary consequence.

**Lemma 2.3 (Square dichotomy in a real closed field).** If $K$ is real closed, then for every $a\in K$, at least one of $a$ and $-a$ is a square.

**Proof sketch.** Exactly one of $a$ and $-a$ is nonnegative, unless $a=0$, in which case both are zero. Every nonnegative element of a real closed field is a square. $\square$

### 2.6. Expressions and point evaluation

Consider a raw expression language containing at least real constants and a variable symbol $x$; it may additionally include addition, multiplication, exponentiation, logarithms, and related constructors. For an input $u$ in the domain of an expression $E$, write $E(u)$ for its evaluated value. Raw expressions are regarded as syntactic trees, so the variable $x$ and the constant $0$ are distinct expressions.

Point evaluation at $u$ is the map

$$
\operatorname{ev}_u:E\longmapsto E(u).
$$

Injectivity of this map would mean that one numerical value determines the complete raw expression. Section 5 shows that this is impossible even in the smallest fragment.

## 3. Exact asymptotic comparison

We now establish the principal positive result.

**Theorem 3.1 (Existence of a first disagreement).** If $F\ne G$, then there exists a rank $\rho$ such that $F$ and $G$ agree below $\rho$ and disagree at $\rho$.

**Proof sketch.** The difference $H=F-G$ is nonzero. Its support is therefore a nonempty well-ordered set. Let

$$
\rho=\min\operatorname{supp}(H).
$$

For every $\gamma<\rho$, the coefficient $[t^\gamma]H$ vanishes, so the coefficients of $F$ and $G$ agree there. At $\rho$, the coefficient of $H$ is nonzero, so the coefficients differ. $\square$

Existence alone does not state that the witness is canonical. Totality supplies uniqueness.

**Lemma 3.2 (Uniqueness of the first disagreement rank).** Suppose $\rho$ and $\sigma$ are both first disagreement ranks for the same pair $F,G$. Then $\rho=\sigma$.

**Proof sketch.** By trichotomy, either $\rho<\sigma$, $\rho=\sigma$, or $\sigma<\rho$. If $\rho<\sigma$, agreement below $\sigma$ implies agreement at $\rho$, contradicting disagreement at $\rho$. The case $\sigma<\rho$ is symmetric. Thus only equality remains. $\square$

Combining the two statements gives the strengthened comparison theorem.

**Theorem 3.3 (Unique First-Disagreement Theorem).** For every unequal pair of Hahn transseries $F\ne G$, there exists exactly one rank $\rho$ such that

$$
[t^\gamma]F=[t^\gamma]G\quad\text{for all }\gamma<\rho,
$$

while

$$
[t^\rho]F\ne[t^\rho]G.
$$

**Proof sketch.** Theorem 3.1 supplies a witness; Lemma 3.2 proves that every other witness equals it. $\square$

Two consequences clarify the meaning of “agreement to all orders.”

**Corollary 3.4 (Coefficient identity principle).** If $F$ and $G$ have equal coefficients at every rank, then $F=G$.

**Proof sketch.** Otherwise Theorem 3.3 would provide a rank where the coefficients differ. $\square$

**Corollary 3.5 (Canonical inequality certificate).** Every inequality $F\ne G$ is witnessed by a unique pair consisting of the least disagreement rank $\rho$ and the unequal coefficients $[t^\rho]F$ and $[t^\rho]G$.

This comparison theorem is exact and algebraic. It should not yet be confused with an analytic theorem saying that a formal transseries determines an eventual real function. Such a connection requires an interpretation map and asymptotic estimates, discussed in Section 9.

## 4. An obstruction to real closedness

Let

$$
\omega=(1,0,0)\in\Gamma
$$

and let

$$
M=t^\omega.
$$

The first coordinate of $\omega$ is odd. This elementary parity fact obstructs square roots.

**Lemma 4.1 (Odd rank is not doubled).** There is no $\delta\in\Gamma$ satisfying

$$
2\delta=\omega.
$$

**Proof.** Write $\delta=(d_1,d_2,d_3)$. Equality in the first coordinate would require $2d_1=1$, impossible for $d_1\in\mathbb Z$. $\square$

**Theorem 4.2 (The odd-rank monomial is not a square).** The monomial $M=t^{(1,0,0)}$ is not a square in the integer-ranked Hahn field.

**Proof sketch.** Suppose $M=F^2$. Since $M\ne0$, also $F\ne0$. Applying order and Corollary 2.2 yields

$$
(1,0,0)=\operatorname{ord}(M)=\operatorname{ord}(F^2)=2\operatorname{ord}(F),
$$

contradicting Lemma 4.1. $\square$

The same obstruction is insensitive to the sign of the leading coefficient.

**Theorem 4.3 (The negative odd-rank monomial is not a square).** The series $-M=-t^{(1,0,0)}$ is not a square.

**Proof sketch.** The order of $-M$ is still $(1,0,0)$ because its sole coefficient is $-1\ne0$. If $-M=F^2$, then order multiplicativity again gives $(1,0,0)=2\operatorname{ord}(F)$, contradicting Lemma 4.1. $\square$

We can now rule out real closedness.

**Theorem 4.4 (Failure of real closedness).** The Hahn field with real coefficients and rank group

$$
\mathbb Z\times_{\mathrm{lex}}(\mathbb Z\times_{\mathrm{lex}}\mathbb Z)
$$

is not real closed.

**Proof sketch.** If it were real closed, Lemma 2.3 applied to $M$ would imply that $M$ or $-M$ is a square. Theorems 4.2 and 4.3 exclude both alternatives. $\square$

The proof identifies nondivisibility of the value group as the mechanism. It does not rule out real-closed Hahn fields in general. Indeed, replacing $\Gamma$ by

$$
\Gamma_{\mathbb Q}=\mathbb Q\times_{\mathrm{lex}}(\mathbb Q\times_{\mathrm{lex}}\mathbb Q)
$$

removes the parity obstruction because $(1,0,0)=2(1/2,0,0)$. A corrected theorem should use a real closed coefficient field and a divisible ordered abelian value group, together with the appropriate Hahn-field real-closure result.

## 5. The limits of pointwise semantic uniqueness

The transseries comparison theorem concerns two already-formed series. It does not imply that evaluation of arbitrary symbolic expressions at a point is injective.

**Proposition 5.1 (Point evaluation at zero is not injective).** In any expression language containing the variable $x$ and the constant $0$, the map

$$
\operatorname{ev}_0:E\longmapsto E(0)
$$

is not injective.

**Proof.** The expressions $x$ and $0$ are distinct syntactic trees, but

$$
\operatorname{ev}_0(x)=0=\operatorname{ev}_0(0).
$$

Thus two distinct inputs have the same image. $\square$

This counterexample is deliberately minimal. Rich expression languages have many additional semantic identifications. For example, $E+F$ and $F+E$ have the same values wherever defined despite different ordered syntax trees. Associativity changes tree shape without changing values. On positive domains, logarithmic and exponential cancellation introduces identities such as $\log(\exp E)=E$ under suitable hypotheses. Consequently, a meaningful uniqueness statement must specify both an equivalence relation and a domain.

A promising semantic object is an eventual germ at $+\infty$.

**Definition 5.2 (Eventual equality).** Two real-valued functions $f$ and $g$ are eventually equal at $+\infty$ if there exists $A\in\mathbb R$ such that

$$
f(x)=g(x)\qquad\text{for every }x>A
$$

where both sides are defined.

An **eventual germ** is an equivalence class under eventual equality. This quotient forgets irrelevant behavior on bounded initial intervals and matches the intended setting of asymptotic expansion.

A corrected expansion theorem should therefore have the following shape. One chooses a restricted expression language with controlled domains, forms eventual germs, defines an expansion map into a suitable transseries field, and proves:

1. the map preserves addition and multiplication;
2. its value is independent of the representative of the germ;
3. its kernel consists exactly of expressions eventually equal to zero;
4. within a normalized summable fragment, equal expansions imply equal germs.

This is stronger and more precise than pointwise uniqueness, while avoiding the impossible demand that raw syntax be recovered from one number.

## 6. Algorithms

Although Hahn series may have infinite support, finite truncations and finitely supported examples admit direct algorithms that mirror the proofs.

### 6.1. First-disagreement search

Represent a finite series by a map from integer triples to real coefficients, omitting zero entries. To compare $F$ and $G$:

1. form the union of their occupied ranks;
2. sort this union lexicographically;
3. scan from least to greatest;
4. return the first rank where the two coefficients differ;
5. if no such rank exists, report equality of the finite representations.

For $n$ distinct occupied ranks, sorting takes $O(n\log n)$ rank comparisons and the scan takes $O(n)$ coefficient comparisons. Storage is $O(n)$. If both inputs are already stored as ordered maps, a merge scan runs in $O(n)$ time.

**Correctness sketch.** If the algorithm returns $\rho$, every earlier rank in the union has equal coefficients, and ranks outside the union have coefficient zero in both series. Thus the series agree below $\rho$ and differ at $\rho$. If it returns no rank, all represented coefficients agree. Uniqueness follows from Theorem 3.3.

### 6.2. Monomial square-order test

For an integer rank $\gamma=(g_1,g_2,g_3)$, a necessary condition for $ct^\gamma$ to be a square is that every coordinate of $\gamma$ be even, because $\gamma=2\delta$ must hold for the root’s order. The test is:

1. inspect $g_1,g_2,g_3$;
2. if any is odd, return “not a square”;
3. otherwise return the candidate half-rank $(g_1/2,g_2/2,g_3/2)$.

This takes $O(1)$ arithmetic operations for the fixed three-level model, or $O(d)$ for $d$ coordinates. Even rank is only a necessary order condition: the leading coefficient and remaining terms may impose further constraints. Odd rank, however, is a complete certificate of nonsquareness.

### 6.3. Point-evaluation collision test

For a finite list of expressions and a chosen input, evaluate each expression and group expressions by value. Any bucket containing two distinct expression trees witnesses noninjectivity. With $m$ expressions and constant-time evaluation, expected time is $O(m)$ using hashing; symbolic or high-precision evaluation may dominate the cost. The pair $x$ and $0$ at input $0$ is the smallest possible collision.

## 7. Numerical and symbolic examples

Consider finite coefficient maps with ranks ordered lexicographically. Let

$$
F=3t^{(0,0,0)}+2t^{(1,0,0)}-t^{(1,1,0)}
$$

and

$$
G=3t^{(0,0,0)}+5t^{(1,0,0)}-t^{(1,1,0)}.
$$

The coefficients agree at $(0,0,0)$ and differ at $(1,0,0)$, so their unique first disagreement rank is $(1,0,0)$. Later agreement at $(1,1,0)$ cannot erase the earlier difference.

As a second example, let

$$
P=7t^{(-2,4,0)}+t^{(0,0,0)}
$$

and

$$
Q=7t^{(-2,4,0)}+t^{(0,0,1)}.
$$

After agreement at $(-2,4,0)$, the next relevant rank is $(0,0,0)$. Its coefficients are $1$ and $0$, respectively, so $(0,0,0)$ is the first disagreement rank. The fact that $Q$ has a term at $(0,0,1)$ is irrelevant to the location of the first difference.

For the parity obstruction, compare ranks

$$
(1,0,0),\qquad (2,-4,6),\qquad (0,3,0).
$$

The first and third cannot be doubled integer ranks because they contain odd coordinates. The second equals

$$
2(1,-2,3),
$$

so it passes the order-level test. This does not automatically construct a square root of an arbitrary series with that order, but it shows why rational or divisible ranks eliminate the elementary obstruction.

Finally, evaluate the distinct expressions

$$
E_1(x)=x,\qquad E_2(x)=0,\qquad E_3(x)=x^2.
$$

At $x=0$, all three values are zero. At $x=2$, their values are $2$, $0$, and $4$, respectively. The collision at one point therefore contains essentially no information about global or eventual identity.

## 8. Applications and interpretation

The unique first-disagreement rank supports canonical comparison in symbolic asymptotics. A simplifier can subtract two normal forms and report the earliest nonzero scale rather than merely returning “unequal.” This rank is an interpretable certificate: it identifies the level at which two proposed expansions diverge.

In numerical asymptotics, truncated transseries can guide error diagnosis. If two approximation pipelines produce expansions that agree through several ranks and first differ at $\rho$, then $\rho$ locates the earliest scale requiring investigation. Under a valid analytic interpretation, the corresponding monomial may predict the leading discrepancy between the approximations.

The real-closedness obstruction is useful in model design. Algebraic solvers often rely on closure under square roots of positive elements. An integer-ranked field cannot provide such closure uniformly. The explicit odd-rank monomial serves as a regression test for any claim that this particular field supports all real algebraic operations internally.

The semantic counterexample informs symbolic machine-learning and expression-discovery systems. Training or validating expressions on isolated samples cannot identify syntax or even functions without additional assumptions. Meaningful identification needs a sampling theorem for a restricted class, a canonical normal form, or a quotient by semantic equivalence. For asymptotic models, eventual germs are particularly natural because they discard bounded-domain accidents and focus on behavior at infinity.

## 9. From formal ranks to analytic germs

The exact comparison theorem is internal to Hahn series. To connect it with real functions, one needs an interpretation assigning each monomial $t^\gamma$ an eventual function and each summable series an eventual germ. Four statements are central.

First, the leading nonzero monomial should control eventual sign. If

$$
F=a_\rho t^\rho+\text{smaller terms},
$$

with $a_\rho\ne0$, then the interpreted function should eventually have the sign of the leading contribution.

Second, smaller ranks should be asymptotically negligible relative to larger ranks in the convention chosen for dominance. This requires proving limits of ratios, not merely comparing formal indices.

Third, interpretation should be injective on a normalized summable fragment. Without normalization, distinct syntax may map to the same formal or analytic object.

Fourth, agreement at every formal rank should imply equality of eventual germs. In an injective interpreted fragment this follows from coefficient identity, but establishing the fragment and injectivity is substantive analysis.

A staged approach is prudent. Begin with polynomial–Laurent expressions, whose asymptotics and algebra are elementary. Extend to one logarithmic level with positive-domain restrictions, then to one exponential level. At each stage define the expansion map, prove compatibility with ring operations, prove asymptotic estimates, and identify the kernel with eventual equality.

## 10. Discussion, limitations, and future work

The results establish a clean boundary between three notions. Coefficientwise asymptotic comparison is valid and canonical. Real closedness is false for the chosen integer value group. Point evaluation is too weak to support expression uniqueness.

Several limitations should be explicit. The rank group has only three levels and is not intended to encode arbitrary towers of logarithms and exponentials. The comparison theorem is a Hahn-series theorem rather than an analytic realization theorem. The nonsquareness argument gives a decisive obstruction but does not classify all squares. The evaluation counterexample addresses raw syntax at one point; it does not preclude injectivity for suitably normalized function classes under richer observational data.

The next algebraic model should replace integer ranks by a divisible ordered abelian group, initially

$$
\mathbb Q\times_{\mathrm{lex}}(\mathbb Q\times_{\mathrm{lex}}\mathbb Q).
$$

For arbitrarily many growth levels, a candidate is a group of finitely supported rational-valued maps on a well-ordered level set, equipped with an order matching asymptotic dominance. A real-closedness theorem should then be derived from explicit hypotheses: real closed coefficients, divisible value group, and the relevant Hahn-field closure theorem.

The next semantic model should replace raw expressions by eventual germs at $+\infty$ or by a normalized language whose equality corresponds to eventual equality. Logarithm domains must be controlled, and cancellation laws must be stated only where valid. The expansion map should preserve addition and multiplication, and its kernel should be characterized exactly.

On the computational side, canonical sparse representations can make first-disagreement certificates efficient. Ordered-map implementations permit linear merge comparison. For large symbolic expressions, normalization and hash-consing may reduce repeated work, while exact rational coefficients avoid numerical ambiguity in coefficient equality.

## 11. Conclusion

The integer-ranked Hahn model supports a strong exact comparison principle: unequal transseries have one and only one first disagreement rank. This is the rigorous core of agreement “to all orders.” At the same time, the rank $(1,0,0)$ exposes a parity defect. Its monomial and negative are both nonsquares, proving that the field is not real closed. Finally, the collision between the variable and constant zero at input zero shows that point values cannot identify raw expressions.

Together these results refine the transseries program rather than merely accepting or rejecting it. Well-ordered support supplies canonical comparison. Divisible value groups are required to remove elementary algebraic obstructions. Eventual germs and normalization are required for meaningful semantic uniqueness. These distinctions provide a concrete foundation for building broader asymptotic languages that connect formal expansions to analytic behavior at infinity.
