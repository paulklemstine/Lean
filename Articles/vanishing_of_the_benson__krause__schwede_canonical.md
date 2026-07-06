# The Hidden Coin Flip Inside a Demushkin Group

## A shape made of symmetry

Some of the most stubborn objects in modern algebra are groups so large they cannot be written down. They are *profinite* groups — infinite groups assembled as limits of finite ones, the way the real numbers are assembled from finite decimal approximations. Among these, a special family stands out for its almost geometric elegance: the **Demushkin groups**. They arise naturally in number theory as the Galois groups of the maximal $p$-extensions of local fields — the symmetry groups that govern how numbers factor when you localize arithmetic at a single prime. They are the closest thing number theory has to a smooth, orientable surface.

What makes a Demushkin group so clean is that all of its cohomology — the algebraic invariants that measure its "holes" — lives in just three dimensions: degrees $0$, $1$, and $2$. Degree $0$ and degree $2$ each contribute a single copy of the field of coefficients; the interesting action happens in degree $1$, a finite-dimensional vector space $V$. And connecting these pieces is one bilinear operation, the **cup product**,
$$
\cup : V \times V \longrightarrow \mathbb{F}_2 ,
$$
which multiplies two degree-one classes to land in the one-dimensional top degree. The defining property of a Demushkin group is that this pairing is *nondegenerate* and *symmetric*: it is a perfect duality on $V$. This is Poincaré duality — the same self-mirroring symmetry that a closed surface enjoys — reincarnated in the algebra of a Galois group.

This article is about a single, delicate question hiding inside that duality, a question that turns out to hinge on nothing more exotic than the arithmetic of the two-element field $\mathbb{F}_2 = \{0, 1\}$, where $1 + 1 = 0$.

## The question: can the whole thing be reassembled from its shadow?

Cohomology is a shadow. It records the *shape* of an object but throws away the finer information of how that object is actually built. Behind the cohomology of a group sits a much richer gadget — a *cochain algebra*, an infinite bookkeeping device that remembers not just which products vanish but *how* and *why* they vanish, encoded in a tower of higher operations called **Massey products** or **secondary operations**.

The dream, for any algebraist, is **formality**: the statement that the rich cochain algebra carries no more information than its shadow — that you can rebuild the whole from the cohomology alone, with all higher operations trivial. When formality holds, the object is as simple as it looks. When it fails, there is a genuine secret buried in the higher structure.

There is a single invariant, a *canonical class* living in a space called the second Hochschild cohomology of the cochain algebra, whose vanishing is precisely equivalent to the first layer of formality — technically, to what is called **$A_3$-formality**. Call this invariant $c(G)$. The conjecture that motivates this work is bracingly simple to state:

> **For every pro-2 Demushkin group $G$, the canonical class $c(G)$ vanishes.**

In other words: Demushkin groups are formal, at least to first order. Their apparent simplicity is not a mirage. But why should this be true, and what controls it?

## Where the obstruction must live

Here is the first decisive observation. A Demushkin group has cohomological dimension two: there is simply *nothing* in degrees three and higher. A secondary operation is, roughly, a machine that takes several inputs and — when the ordinary products among them vanish — produces an output one degree lower than naive multiplication would suggest. A ternary operation feeds three degree-one classes into the pairing and produces something in degree $1 + 1 + 1 - 1 = 2$, which is exactly the top, nonzero degree. Any *longer* operation would have to land above degree two, where there is nothing but zero.

So the entire obstruction to first-order formality is squeezed into a single ternary operation
$$
V \otimes V \otimes V \longrightarrow \mathbb{F}_2 ,
$$
and this operation is built entirely out of the cup product. The infinite, intimidating cochain algebra has been compressed into a question of finite linear algebra on the humble space $V$. This is the moment the problem becomes tractable: we no longer need topology or Galois theory, only the arithmetic of a bilinear form over $\mathbb{F}_2$.

## The characteristic-two miracle: squaring becomes linear

Now comes the phenomenon that makes everything work, and it is genuinely a feature of the number two.

For any element $x \in V$, consider its **self-cup**, or square:
$$
q(x) := x \cup x = B(x, x),
$$
where I write $B$ for the cup-product form. Over the real or rational numbers, squaring is aggressively *non*linear — that is the whole point of a quadratic form. Watch what happens when we expand a sum, using that $B$ is symmetric:
$$
B(x + y,\, x + y) = B(x,x) + 2\,B(x,y) + B(y,y).
$$
Over most fields the cross term $2\,B(x,y)$ is the obstruction to linearity. But over $\mathbb{F}_2$ we have $2 = 0$, so the cross term simply **vanishes**:
$$
q(x + y) = q(x) + q(y).
$$
And scaling behaves too: the only scalars are $0$ and $1$, and $c^2 = c$ for both, so $q(cx) = c^2 q(x) = c\, q(x)$. Squaring — the archetypal nonlinear operation — has quietly become a **linear map**
$$
q : V \longrightarrow \mathbb{F}_2 .
$$

This is the characteristic-two miracle. A quadratic thing has collapsed into a linear functional, an honest element of the dual space $V^*$. And it is exactly this collapse that trivializes the secondary ternary operation: because the "squaring" ingredient of the operation is linear rather than quadratic, the obstruction it could have produced dissolves.

## The Kummer class: giving the shadow a name

A linear functional on a space with a perfect pairing is never anonymous. Nondegeneracy of $B$ means the map sending a vector $v$ to the functional $x \mapsto B(v, x)$ is an isomorphism $V \xrightarrow{\ \sim\ } V^*$. So the squaring functional $q$, being an element of $V^*$, is represented by a *unique* vector. We call it the **Kummer class**, or **orientation class**, and denote it $\chi$. It is characterized by a single clean equation:
$$
\boxed{\ x \cup x \;=\; \chi \cup x \quad\text{for every } x \in V.\ }
$$

The Kummer class is the linear-algebra shadow of the entire canonical obstruction. Everything the cochain algebra could secretly be hiding, at this first level, is compressed into this one vector $\chi \in V$.

Two facts pin it down completely. First, **existence and the defining equation** hold by construction. Second, **uniqueness**: if some vector $w$ satisfies $B(w, x) = B(x, x)$ for all $x$, then $B(w - \chi, x) = 0$ for all $x$, and nondegeneracy forces $w = \chi$. There is one and only one orientation class.

## A coin flip: the two types of Demushkin group

Now the payoff. The whole point of naming $\chi$ is that its vanishing is a single yes-or-no invariant, and it cleanly separates Demushkin groups into two mirror families.

> **Type dichotomy.** The cup-product form is *alternating* — meaning $x \cup x = 0$ for **every** class $x$ — if and only if the Kummer class is zero, $\chi = 0$.

The proof is a two-line pleasure. If $x \cup x = 0$ for all $x$, then the squaring functional $q$ is identically zero, so the unique vector representing it is $0$; hence $\chi = 0$. Conversely, if $\chi = 0$, then the defining equation reads $x \cup x = \chi \cup x = 0$ for every $x$. The two conditions are the same condition.

This is the classical **even/odd type dichotomy** of Demushkin groups, but now expressed as a crisp property of a single vector rather than as a quadratic condition scattered across the whole space:

- **Even type** ($\chi = 0$): the form is alternating, everything is self-orthogonal, the group is "orientable." The canonical obstruction is as trivial as possible.
- **Odd type** ($\chi \neq 0$): some class satisfies $x \cup x = 1$, and the orientation class $\chi$ is a genuine, detectable feature. It is the algebraic fingerprint of the group's arithmetic — conjecturally, it is switched on exactly when the group's single defining relation carries an odd power in its distinguished generator.

There is even a parity theorem lurking here. An alternating nondegenerate form over $\mathbb{F}_2$ splits into *hyperbolic planes*, two dimensions at a time, with no odd leftover possible. So even-type groups have **even** rank; odd rank forces the odd type. A property of one vector controls the parity of the entire group.

## Both worlds are real: two concrete forms

None of this would matter if only one type occurred. Two small, explicit examples show both are genuine.

**The dot product on $\mathbb{F}_2^n$.** Take $B(x, y) = x_1 y_1 + \cdots + x_n y_n$. It is symmetric and nondegenerate — pairing against the standard basis vectors detects everything. But it is *not* alternating: $B(e_1, e_1) = 1$. This is the **odd type**. Its Kummer class is the all-ones vector $(1, 1, \dots, 1)$, and the isotropic classes — those with $x \cup x = 0$ — are exactly the even-weight vectors, forming a hyperplane of codimension one. The odd type always has its isotropic classes confined to a single hyperplane, an arithmetic invariant of the group.

**The hyperbolic plane on $\mathbb{F}_2^2$.** Take $B$ to be the pairing with $B(e_1, e_1) = B(e_2, e_2) = 0$ and $B(e_1, e_2) = 1$. It is symmetric, nondegenerate, and alternating — every vector squares to zero. This is the **even type**, with vanishing Kummer class and a fully isotropic space. It is the smallest orientable Demushkin form, the algebraic echo of a torus.

## Why it matters

Zoom back out. We started with an infinite, unwritable Galois group and a question about whether an entire tower of higher algebraic operations secretly encodes hidden information. We ended with a single vector $\chi$ in a finite vector space over the two-element field, and a coin-flip criterion — $\chi = 0$ or not — that decides the group's type, its parity, and the vanishing of its first-order formality obstruction.

This is the recurring magic of characteristic two: an operation that is hopelessly nonlinear over ordinary numbers — squaring — becomes perfectly linear, and a subtle quadratic invariant collapses into a single, nameable, computable class. The apparent complexity of the cochain algebra was, in the end, a shadow of one honest linear functional. The Demushkin group's secret is that it has almost no secret at all — and the reason is that, over $\mathbb{F}_2$, $x^2$ and $x$ are the same thing.
