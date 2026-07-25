# When Equality Is Too Rigid: A Concrete Journey into Bicategories

## The hidden importance of parentheses

Most of elementary arithmetic trains us to ignore parentheses. Whether we calculate $(2+3)+4$ or $2+(3+4)$, the answer is $9$. The same is true of ordinary multiplication. This familiar law, associativity, is so pervasive that it can seem like part of the furniture of mathematics.

But many processes are sensitive to order and grouping. Combining two data transformations and then a third need not agree literally with combining the last two first. In a distributed system, intermediate synchronization can matter. In geometry, composing changes of coordinates may produce descriptions that are canonically related without being word-for-word identical. In quantum and topological models, the *way* composites are identified can carry mathematical information of its own.

Category theory answers this tension by distinguishing equality from coherent equivalence. A bicategory is a setting in which composition need not be strictly associative. Instead, the two bracketings are connected by a reversible comparison called an associator. That flexibility is not a license for chaos: associators must satisfy coherence laws ensuring that every legitimate route of rebracketing is compatible.

A particularly transparent construction shows exactly how far this idea can go. Start with almost the weakest multiplication one can imagine, a set with a binary operation and a two-sided unit. The operation may fail associativity completely. By adding a unique reversible comparison between any two composites, one obtains a bicategory. Even better, this bicategory is strict precisely when the original multiplication is associative. Thus a basic algebraic equation becomes the exact dividing line between strict and genuinely non-strict higher-dimensional composition.

## The algebraic seed: a unital magma

A **unital magma** is a set $M$ equipped with a binary operation $(a,b)\mapsto a*b$ and a distinguished element $e$ satisfying

$$
e*a=a,\qquad a*e=a
$$

for every $a\in M$. No associativity law is assumed. Consequently, $(a*b)*c$ and $a*(b*c)$ may be different elements.

This modest structure supplies the one-dimensional ingredients of our construction. There will be a single object, which we may picture as one location. Each element $a\in M$ is a process from that location back to itself. The identity process is $e$, and consecutive processes $a$ and $b$ compose to $a*b$.

If this were an ordinary one-object category, associativity would be compulsory. A nonassociative magma would therefore fail at the entrance. A bicategory asks for something subtler: it permits the two composites $(a*b)*c$ and $a*(b*c)$ to differ as processes, provided that a reversible transformation connects them.

## Adding a second dimension

The decisive move is to place exactly one transformation between every ordered pair of processes. For any $a,b\in M$, declare that there is a unique $2$-cell

$$
a\Longrightarrow b.
$$

A collection with exactly one arrow between every pair of objects is often called **codiscrete** or **indiscrete**. Its simplicity is extreme. The unique transformation from $a$ to $b$ and the unique transformation from $b$ to $a$ must compose to the unique transformation from $a$ to itself, which is the identity. Hence every transformation is automatically invertible.

The associator for $a,b,c$ is now forced: it is the unique reversible $2$-cell

$$
\alpha_{a,b,c}:(a*b)*c\Longrightarrow a*(b*c).
$$

Likewise, the left and right unitors are the unique comparisons

$$
\lambda_a:e*a\Longrightarrow a,
\qquad
\rho_a:a*e\Longrightarrow a.
$$

Because $e$ is already a strict two-sided unit in the magma, the endpoints of these unitors are equal. Yet retaining the unitors is important: they belong to the bicategorical language and must interact correctly with the associator.

The main construction can now be stated in ordinary mathematical terms.

**Codiscrete Bicategory Theorem.** *Every unital magma $(M,*,e)$ determines a one-object bicategory. Its $1$-cells are the elements of $M$, their composition is $*$, the identity $1$-cell is $e$, and between every two $1$-cells there is exactly one $2$-cell.*

The proof is short but conceptually revealing. Vertical composition of $2$-cells, horizontal composition, and whiskering are all uniquely determined because their source and target fix the only available $2$-cell. The associator and unitors are the unique reversible comparisons with the required endpoints. Every coherence axiom compares two parallel $2$-cells; because there is only one such $2$-cell, the two sides coincide.

## Why the pentagon cannot fail

The best-known coherence condition for associators is the pentagon. Four composable $1$-cells admit five full parenthesizations. Traveling around the pentagon by elementary rebracketings gives two principal routes from $(((a*b)*c)*d)$ to $a*(b*(c*d))$. The pentagon law says that the composites of associators along these routes agree.

In a rich bicategory, proving this can be substantial. Here, both routes are $2$-cells with the same source and target. Codiscreteness says there is exactly one. They therefore agree automatically.

The triangle law similarly compares rebracketing with removal of a unit. Again, its two sides are parallel $2$-cells and hence equal. This mechanism is worth emphasizing: nonassociativity has not been denied or concealed. The endpoints $(a*b)*c$ and $a*(b*c)$ may genuinely differ. What codiscreteness guarantees is a unique coherent bridge between them.

This resembles a transportation network in which towns remain distinct but exactly one canonical road is declared between each ordered pair. Saying that two itineraries end at the same towns no longer makes the towns identical; it says the itineraries represent the same canonical connection.

## A sharp test for strictness

A bicategory is **strict on its given data** when unit and composition laws hold as literal equalities of $1$-cells and its structural comparisons are exactly those induced by these equalities. In the one-object codiscrete construction, strictness has a complete characterization.

**Strictness Characterization Theorem.** *The codiscrete one-object bicategory associated with a unital magma $(M,*,e)$ admits a strict structure on its fixed $1$-cells and fixed composition if and only if $*$ is associative; that is, if and only if*

$$
(a*b)*c=a*(b*c)
$$

*for all $a,b,c\in M$.*

For the forward implication, assume a strict structure exists. Strict associativity supplies equality of the two bracketed composites for every triple of $1$-cells. Since those $1$-cells are precisely the elements of $M$, this is exactly the associative law for $*$.

For the reverse implication, suppose $*$ is associative. The unit equalities already come from the definition of a unital magma, and associativity gives literal equality of all triple composites. The remaining compatibility conditions ask that the chosen unitors and associator agree with the reversible comparisons generated by these equalities. But between any fixed endpoints there is only one reversible $2$-cell, so agreement is automatic.

The theorem separates two ideas that are often blurred. A weak structure may be coherent even when its composites are unequal. Strictness, however, cannot manufacture equality where the underlying operation lacks it.

As an immediate consequence, every monoid—a unital magma whose multiplication is associative—produces a strict codiscrete bicategory. Nonassociative unital magmas occupy the genuinely non-strict side of the boundary.

## A numerical witness: five versus seven

An explicit operation on the natural numbers makes the distinction visible. Let the unit be $0$, and define a twisted product $\star$ by

$$
a\star b=
\begin{cases}
b,&a=0,\\
a,&b=0,\\
a+2b,&a>0\text{ and }b>0.
\end{cases}
$$

The special zero cases ensure

$$
0\star a=a,\qquad a\star 0=a.
$$

Thus $(\mathbb N,\star,0)$ is a unital magma. But it is not associative. First $1\star1=3$, and then

$$
(1\star1)\star1=3\star1=5,
$$

whereas

$$
1\star(1\star1)=1\star3=7.
$$

The discrepancy is literal: $5\ne7$. Nevertheless, in the associated codiscrete bicategory there is a unique invertible $2$-cell

$$
5\Longrightarrow7.
$$

This is the associator at the triple $(1,1,1)$. All pentagon and triangle laws still hold because all parallel $2$-cells are unique.

**Concrete Non-Strictness Corollary.** *The codiscrete bicategory built from $(\mathbb N,\star,0)$ is a coherent bicategory, but it admits no strict structure with this same collection of $1$-cells and this same composition.*

Indeed, strictness would force associativity, contradicting $5\ne7$. This is not merely a bicategory presented in an inconvenient notation. The fixed multiplication itself obstructs strictness.

## An algorithmic view of the obstruction

For a finite unital magma, the strictness question can be decided by a cubic scan. For every triple $(a,b,c)$, compare $(a*b)*c$ with $a*(b*c)$. If any triple differs, it is a certificate that the associated bicategory is non-strict. If every triple agrees, the multiplication is associative and the bicategory is strict.

For a magma with $n$ elements and a constant-time multiplication table, this requires at most $n^3$ triple tests and constant extra space beyond the table. A second useful output is the **defect table**, which records every triple where the bracketings differ. The bicategory supplies an associator across each defect; the strictness theorem says that the defect table is empty exactly in the strict case.

This computational picture turns an abstract structural issue into something observable. In the twisted natural-number example, the single test $(1,1,1)$ already settles the matter.

## What the construction teaches

The construction offers a clean laboratory for weak composition. It proves three things at once.

First, coherence and equality are different resources. A coherent reversible comparison can exist even when its endpoints are unequal.

Second, uniqueness makes coherence automatic. The pentagon is not an additional numerical miracle here; it follows because there is no competing parallel $2$-cell.

Third, strictness on fixed data is rigid. One may hope to replace a weak bicategory by an equivalent strict structure after changing its presentation, but that is a different question. For the fixed twisted multiplication, no strict structure exists.

The next frontier begins precisely where codiscreteness ends. If several automorphisms are allowed between a $1$-cell and itself, associators are no longer unique. The pentagon then becomes a genuine equation among choices, closely related to a $3$-cocycle. In that richer world, coherence can store information rather than merely guarantee consistency.

The humble calculation $5\ne7$ therefore opens onto a broad principle. Parentheses need not disappear for mathematics to remain orderly. Sometimes the right structure does not force two composites to be equal; it records a canonical, reversible, and globally coherent way to pass between them.