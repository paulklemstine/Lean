# The First Place Two Infinite Expansions Disagree

## A map for scales beyond power series

Power series are among mathematics’ most successful compression devices. Near a point, a complicated function can be replaced by a list of coefficients attached to $1,x,x^2,x^3,\ldots$. That list can turn differentiation into bookkeeping and approximation into truncation. Yet many functions arising in asymptotic analysis refuse to live on a single power scale. Exponentials outrun powers, logarithms trail behind them, and nested expressions such as $\exp(\exp x)$ create still more distant levels of growth.

To compare such expressions, it is not enough to ask for the coefficient of $x^n$. We need an organized atlas of scales: exponential, polynomial, and logarithmic. The framework developed here supplies a rigorous finite-level model of that atlas. Its central message is strikingly simple:

> An expansion is completely determined by all of its coefficients, and two unequal expansions have a first rank at which they disagree.

That statement sounds inevitable until one remembers that the expansions may have infinitely many terms and their exponents need not march along the ordinary integers. The decisive ingredient is not finiteness but a well-ordered support condition, which prevents the nonzero terms from descending forever without a first one.

## Three coordinates of growth

A **growth rank** is a triple of integers

$$
r=(e,p,\ell)\in\mathbb Z^3,
$$

ordered lexicographically. Thus $(e,p,\ell)<(e',p',\ell')$ if the first coordinate at which the two triples differ is smaller. The coordinates may be read as exponential, polynomial, and logarithmic levels. This interpretation is schematic rather than a claim that every possible exponential–logarithmic expression has already been encoded. It gives a clean three-level laboratory in which the essential order theory can be seen.

A **three-level transseries** is a formal sum

$$
F=\sum_{r\in\mathbb Z^3} a_r\,\mathfrak m^r,
$$

with real coefficients $a_r$, subject to the condition that the set of ranks with $a_r\ne0$ is well ordered. The symbol $\mathfrak m^r$ denotes a formal transmonomial of rank $r$; one can picture it heuristically as carrying exponential, power, and logarithmic information. Formal means that identity is determined by coefficients rather than by evaluating at a numerical value of $x$.

Well ordering is the quiet engine of the theory. Every nonempty collection of occupied ranks has a least element. Consequently, every nonzero transseries has an **order**: the least rank carrying a nonzero coefficient. This resembles the lowest exponent in a polynomial, the order of vanishing of an analytic function, or the valuation of a Laurent series.

The simplest object is a **transmonomial** $M_{r,c}$, which has coefficient $c$ at rank $r$ and coefficient $0$ everywhere else. Its coefficient at its own rank is exactly $c$. If $c\ne0$, then $M_{r,c}$ is nonzero. Moreover, if $r\ne s$ and $a\ne0$, then $M_{r,a}$ cannot equal $M_{s,b}$ for any $b$: inspecting the coefficient at $r$ distinguishes them.

## Listening below the leading order

Suppose $F$ has order $q$. No coefficient below $q$ can be nonzero; otherwise $q$ would not be least. In symbols,

$$
r<\operatorname{ord}(F)\quad\Longrightarrow\quad [\mathfrak m^r]F=0,
$$

where $[\mathfrak m^r]F$ denotes the coefficient of $F$ at rank $r$.

This elementary observation becomes powerful when applied to a difference. Given two transseries $F$ and $G$, set

$$
D=F-G.
$$

At every rank below $\operatorname{ord}(D)$, the coefficient of $D$ vanishes. Since coefficients subtract term by term, this says

$$
r<\operatorname{ord}(F-G)
\quad\Longrightarrow\quad
[\mathfrak m^r]F=[\mathfrak m^r]G.
$$

Thus the two expansions agree completely below the order of their difference.

If $F\ne G$, then $D\ne0$. Its coefficient at its own order is nonzero. Therefore

$$
[\mathfrak m^{\operatorname{ord}(F-G)}]F
\ne
[\mathfrak m^{\operatorname{ord}(F-G)}]G.
$$

These two statements combine into the **First Disagreement Theorem**:

> For any unequal three-level transseries $F$ and $G$, there is a rank $q$ such that their coefficients agree at every rank below $q$ and differ at $q$. One may take $q=\operatorname{ord}(F-G)$.

Imagine comparing two infinitely long musical scores from the quietest note upward. Well ordering guarantees that, if the scores differ at all, there is a first audible discrepancy. No endless search through ever-lower ranks is possible.

## Agreement to every order

Say that $F$ and $G$ **agree below a cut** $q$ if their coefficients coincide at every rank $r<q$. Say that they **agree to all orders** if

$$
[\mathfrak m^r]F=[\mathfrak m^r]G
\qquad\text{for every }r\in\mathbb Z^3.
$$

The **Asymptotic Comparison Theorem** states:

> Two three-level transseries agree to all orders if and only if they are equal.

The forward direction follows because a formal series is determined by its coefficient function. The reverse direction is immediate: equal objects have equal coefficients. The theorem also follows conceptually from first disagreement. If two series were unequal, there would be a first coefficient at which they differ, contradicting agreement to all orders.

A useful corollary is the **No-Flatness Theorem**:

> If every coefficient of a three-level transseries $F$ is zero, then $F=0$.

In ordinary smooth analysis, a nonzero function can be “flat” at a point: for example, the function equal to $e^{-1/x^2}$ for $x>0$ and $0$ for $x\le0$ has every derivative zero at the origin. Its Taylor series cannot detect it. In the present formal setting, that pathology is absent by construction. There is no nonzero series whose entire coefficient data vanish.

This distinction matters. The theorem concerns equality inside the formal series model; it does not by itself prove that every analytic or exponential–logarithmic function possesses such an expansion. Existence of expansions is a separate and deeper question. But once an expansion belongs to this model, uniqueness is absolute.

## Arithmetic respects complete agreement

A useful language of asymptotics must survive calculation. Suppose $F_1$ agrees to all orders with $G_1$, and $F_2$ agrees to all orders with $G_2$. Then coefficientwise addition gives

$$
F_1+F_2\quad\text{agreeing to all orders with}\quad G_1+G_2.
$$

For multiplication, complete agreement first yields $F_1=G_1$ and $F_2=G_2$ by the comparison theorem. Substitution then gives $F_1F_2=G_1G_2$, so the products also agree to all orders. Thus complete asymptotic identity is compatible with both addition and multiplication.

This is more than a tidiness condition. It means that coefficient data can act as a reliable computational interface. Once two inputs are known coefficient by coefficient, ordinary algebra cannot make their representatives diverge.

## A finite window onto an infinite structure

A computer demonstration can only store finitely many terms, but it can reproduce the logic exactly within that window. Represent a rank by an integer triple and a sparse transseries by a dictionary from ranks to nonzero real coefficients. Sort ranks lexicographically. To compare two inputs, subtract matching coefficients and choose the least rank with nonzero difference. Every lower listed coefficient agrees, while the chosen coefficient differs.

For example, consider

$$
F=2\mathfrak m^{(0,0,0)}-3\mathfrak m^{(0,1,-1)}
   +5\mathfrak m^{(1,-2,0)}
$$

and

$$
G=2\mathfrak m^{(0,0,0)}-3\mathfrak m^{(0,1,-1)}
   +7\mathfrak m^{(1,-2,0)}.
$$

The first two occupied ranks match. At $(1,-2,0)$, the coefficients are $5$ and $7$. Their difference has coefficient $-2$ there, so that rank is the order of $F-G$ and the first disagreement.

If instead every stored coefficient agrees, the finite representations are equal. The exact infinite theorem says the same thing without a storage boundary, because the coefficient function itself is the object.

## What has—and has not—been reached

The three-level theory establishes a dependable Hahn-series foundation: coefficient extensionality, nonzero and distinct monomials, vanishing below order, first disagreement, absence of nonzero flat series, and compatibility of complete agreement with addition and multiplication.

It does not yet establish the much broader vision sometimes associated with full exponential–logarithmic transseries. A complete theory would require recursively generated towers of monomials rather than only three integer coordinates. It would need well-defined composition, logarithm, and exponential on appropriate classes; a syntax and semantics for exponential–logarithmic expressions with domain conditions; an existence theorem assigning expansions to those expressions; and substantial ordered-field theory, potentially culminating in real closedness. Those are future constructions, not consequences of coefficient uniqueness alone.

Still, the foundation isolates the key logical hinge. Existence asks whether a function can be translated into a transseries. Uniqueness asks whether two translations could conflict. Here uniqueness is settled for the model: all-order agreement forces equality, and inequality always reveals a first witness.

## Why first disagreement matters

The same pattern appears across mathematics and applications. In perturbation theory, one seeks the first order at which two models predict different behavior. In symbolic computation, sparse leading terms guide simplification. In non-Archimedean geometry, valuations measure the earliest nonzero contribution. In algorithm design, lexicographic keys separate objects efficiently. In multiscale modeling, locating the first disagreement tells us which scale carries new information.

The philosophical lesson is equally useful. Infinity need not erase distinguishability. With the right order on scales, an infinite expansion can be inspected from its leading edge. Equality is global, but inequality has a local certificate: one rank and two unequal coefficients.

Beyond ordinary power series lies a landscape of exponentials, powers, and logarithms. The present three-level model does not map the whole territory. It does, however, provide a trustworthy compass. Every occupied expansion has a first term; every unequal pair has a first disagreement; and complete coefficient data leave no room for ambiguity. That principle is modest enough to state in one sentence, yet strong enough to organize comparison, computation, and future expansion theories around a single canonical witness.