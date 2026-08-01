# The First Place Infinity Disagrees

## A sharper map of transseries—and the fault lines it reveals

Power series are among mathematics’ most familiar microscopes. Near a point, a complicated function can often be resolved into layers such as $1$, $x$, $x^2$, and $x^3$. Each successive layer is smaller than the one before it, and the first coefficient at which two series differ tells us how their functions initially separate.

But many functions outrun this microscope. The logarithm grows more slowly than every positive power of $x$. The exponential grows faster than every power. An iterated exponential such as $\exp(\exp x)$ makes even $\exp x$ look negligible. To compare such objects near infinity, one needs an asymptotic language with a much larger vocabulary.

That language is supplied by **transseries**: generalized series whose monomials can represent several levels of growth. A schematic example might look like

$$
3\exp(x)-7x^2\log x+\frac{4}{x}+\cdots.
$$

The dots are not merely decorative. They encode a well-ordered succession of smaller terms, so that every nonzero difference has a first significant contribution. This simple principle—there is a first place where two unequal expansions disagree—is the durable heart of the theory developed here.

The same investigation also uncovers two limits. First, a natural model indexed by integer growth ranks is not real closed: one explicit monomial has neither itself nor its negative equal to a square. Second, the value of an expression at one point cannot identify the expression uniquely. These are not failures of transseries. They are diagnostic results: they tell us exactly which hypotheses a stronger theory must possess.

## A ladder of growth

Consider ranks built from integer triples,

$$
\Gamma=\mathbb Z\times_{\mathrm{lex}}(\mathbb Z\times_{\mathrm{lex}}\mathbb Z),
$$

ordered lexicographically. The first coordinate is compared first; only if it ties do we inspect the second, and then the third. One may imagine these coordinates as recording three successive growth levels—say exponential, polynomial, and logarithmic scales—without committing to a particular analytic interpretation.

A generalized series over this rank group is a formal sum

$$
F=\sum_{\gamma\in\Gamma} a_\gamma t^\gamma,
$$

where each $a_\gamma$ is real and the nonzero coefficients occur on a well-ordered set of ranks. The symbol $t^\gamma$ is a monomial of rank $\gamma$. Well-ordering guarantees that every nonzero series has a least occupied rank. We call it the **order**:

$$
\operatorname{ord}(F)=\min\{\gamma:a_\gamma\ne0\}.
$$

This order is the first visible scale of the series. Multiplication adds ranks, and for nonzero series it satisfies

$$
\operatorname{ord}(FG)=\operatorname{ord}(F)+\operatorname{ord}(G).
$$

In particular,

$$
\operatorname{ord}(F^2)=2\operatorname{ord}(F).
$$

That small equation drives one of the central negative results.

## Every disagreement has an address

Say that two series $F$ and $G$ **agree below** a rank $\rho$ if

$$
a_\gamma=b_\gamma\qquad\text{for every }\gamma<\rho,
$$

where $a_\gamma$ and $b_\gamma$ are their coefficients. If they agree below $\rho$ but have different coefficients at $\rho$, then $\rho$ is their first disagreement rank.

The key comparison theorem says:

> **Unique First-Disagreement Theorem.** If $F\ne G$, then there exists exactly one rank $\rho$ such that $F$ and $G$ agree at every rank below $\rho$ and disagree at $\rho$.

Existence comes from applying well-ordering to the support of $F-G$. Since $F-G$ is nonzero, the set of ranks carrying nonzero coefficients has a least element. At all smaller ranks the difference vanishes, while at that least rank it does not.

Uniqueness is just as revealing. Suppose $\rho$ and $\sigma$ were both first disagreement ranks. The total order gives three possibilities. If $\rho<\sigma$, agreement below $\sigma$ forces agreement at $\rho$, contradicting the choice of $\rho$. If $\sigma<\rho$, the symmetric contradiction occurs. Therefore $\rho=\sigma$.

This theorem turns an infinite object into a finite certificate of inequality: a single rank and two unequal coefficients. It is the transseries analogue of lexicographically comparing two words by scanning to the first unequal letter. The alphabet here is not arranged along a finite line but across a hierarchy of asymptotic scales.

A useful consequence is an all-orders identity principle. If two series have equal coefficients at every rank, they are equal. Equivalently, unequal series cannot hide their difference indefinitely: the well-ordered support forces a first witness.

## The odd rank that cannot be halved

The rank group $\Gamma$ uses integer coordinates. That makes it discrete and computationally transparent, but it also introduces a parity obstruction.

Take the rank

$$
\omega=(1,0,0)
$$

and its monomial $M=t^\omega$. Could $M$ be a square? If $M=F^2$ for a nonzero $F$, then

$$
\omega=\operatorname{ord}(M)=\operatorname{ord}(F^2)=2\operatorname{ord}(F).
$$

Yet the first coordinate of $2\operatorname{ord}(F)$ is even, while the first coordinate of $\omega$ is $1$. No integer rank doubles to $\omega$. Therefore $M$ is not a square.

Changing the sign does not help. The series $-M$ has the same order $\omega$, because multiplying a nonzero coefficient by $-1$ does not alter the location of its leading term. If $-M=F^2$, the identical order argument would again demand $2\operatorname{ord}(F)=\omega$. Thus $-M$ is not a square either.

Now recall a basic property of a real closed field: for every element $a$, at least one of $a$ and $-a$ is a square. Positive elements are squares, while the ordering decides which sign is positive. Our element $M$ violates this necessary condition because neither sign is a square.

> **Non-Real-Closedness Theorem.** The generalized-series field with real coefficients and integer lexicographic rank group $\mathbb Z\times_{\mathrm{lex}}(\mathbb Z\times_{\mathrm{lex}}\mathbb Z)$ is not real closed.

This theorem does not say that transseries can never form a real closed field. It identifies the precise defect of this model: the value group is not divisible. A divisible group allows every rank $\gamma$ to be halved, whereas the integer rank $(1,0,0)$ has no half. Replacing the integer coordinates by rational coordinates,

$$
\mathbb Q\times_{\mathrm{lex}}(\mathbb Q\times_{\mathrm{lex}}\mathbb Q),
$$

removes this particular parity obstruction. Establishing real closedness then requires a genuine Hahn-field theorem with a real closed coefficient field and divisible value group, but at least the first barrier has disappeared.

## Why one value cannot name an expression

There is a second temptation to resist: believing that evaluating an expression at one input uniquely identifies it.

Suppose our expression language contains a variable $x$ and real constants. The expression $x$ and the constant expression $0$ are syntactically different. Nevertheless, at the input $x=0$ they have the same value:

$$
x\big|_{x=0}=0=0\big|_{x=0}.
$$

Therefore the map sending an expression to its value at zero is not injective.

> **Point-Evaluation Counterexample.** Evaluation at $0$ does not uniquely determine an expression: the variable expression and the constant-zero expression are distinct but have equal value there.

The lesson extends far beyond this tiny example. Even agreement at many points may not capture the intended notion of identity when logarithms, exponentials, restricted domains, or symbolic rearrangements are involved. Commutativity makes $f+g$ and $g+f$ different pieces of raw syntax with the same meaning. On suitable domains, exponential and logarithm can cancel. A useful uniqueness theorem must say what counts as the same object.

For asymptotic mathematics, the natural object is often an **eventual germ at $+\infty$**: two functions represent the same germ if they agree for every sufficiently large input. Raw expressions should then be quotiented by eventual equality, and any expansion theorem should be stated on that quotient or on a canonical normalized language.

## An algorithm hidden in the theorem

For finitely represented series, the first-disagreement theorem becomes a direct comparison algorithm. Store each series as a dictionary from integer triples to nonzero coefficients. Sort the union of occupied ranks lexicographically. Scan from least to greatest and return the first rank at which the coefficients differ. If no such rank occurs, the finite series are equal.

For $n$ occupied ranks in total, sorting costs $O(n\log n)$ comparisons and scanning costs $O(n)$. If the data are already stored in ordered maps, the comparison can be performed in $O(n)$ time by merging the two ordered streams.

The square obstruction is even cheaper. To ask whether a monomial rank can be twice an integer rank, inspect each coordinate. Any odd coordinate blocks divisibility by $2$; for $(1,0,0)$ the first coordinate settles the question immediately.

These algorithms are modest, but they expose the architecture of the mathematics. Well-ordering creates the first-difference scan. Group divisibility controls which monomial orders can occur as squares.

## What survives, and what must change

Three conclusions now stand clearly apart.

First, exact asymptotic comparison survives intact and becomes sharper: every unequal pair has one and only one first disagreement rank. This provides a canonical witness of inequality.

Second, real closedness fails for the integer-ranked field. The failure is structural, not mysterious: integer ranks contain elements that cannot be halved. Rational or more general divisible ranks are the natural next setting.

Third, unrestricted uniqueness of expressions from point values fails. The remedy is not to collect slogans about “unique expansions,” but to specify the semantic domain, quotient expressions by the right equivalence relation, and normalize the fragment under study.

A practical research program follows. Begin with polynomial and Laurent expressions, where eventual behavior is controlled. Add one logarithmic level, then one exponential level. At each stage define an expansion map, prove that it respects addition and multiplication, and identify its kernel with eventual equality. In parallel, connect formal ranks to genuine functions by proving that a leading nonzero monomial controls eventual sign and that lower-ranked terms are asymptotically negligible.

The broad dream of transseries remains compelling: a calculus in which powers, logarithms, exponentials, and their iterations can be compared in one ordered universe. The strongest progress often comes not from asserting the dream whole, but from locating its exact load-bearing beams. Here one beam is well-ordering, which guarantees a first disagreement. Another is divisibility, which a real-closed model cannot do without. A third is semantic quotienting, without which “uniqueness” confuses expressions with the functions or germs they represent.

Infinity is complicated, but it is not shapeless. When two asymptotic worlds differ, their disagreement has an address. And when an ambitious model fails, the obstruction can have an address too—as simple, and as decisive, as the odd coordinate $1$.
