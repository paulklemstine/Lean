# Beyond Power Series: A Number System for Infinity

## Where the calculus of limits runs out

Every student of calculus learns to compare growth rates. Exponentials beat polynomials; polynomials beat logarithms. Write it as a chain and it looks almost childishly simple:

$$1 \;\ll\; \log x \;\ll\; x \;\ll\; e^x \;\ll\; e^{e^x}.$$

But that chain hides something strange. Between $x$ and $e^x$ there is not just room — there is an *infinity* of room. The function $x^{100}$ sits above $x$; so does $x^{10^{100}}$; so does $x^{\log x}$. None of them ever catches $e^x$. The chain is not a ladder with rungs you can climb one at a time. It is a continuum, densely packed, and ordinary numbers are the wrong instrument for measuring it.

The instrument that *is* right was invented, in different guises, by Hardy, by Hahn, by Écalle, and by the model theorists who studied o-minimal structures: a **transseries**. A transseries is what you get if you allow yourself infinite formal sums, not of powers of $x$ alone, but of the whole exponential–logarithmic zoo:

$$\frac{e^{2x}}{x^3} \;-\; 7\,e^{x}\log x \;+\; 5 \;+\; \frac{1}{x} \;+\; \frac{1}{x^2} \;+\; \frac{1}{x^3} \;+\; \cdots$$

Power series answer the question "what does this function look like near a point?" Transseries answer the harder question: **"what does this function look like at infinity?"** — and they answer it so completely that the answer *is* the function.

This article describes a body of results establishing exactly that, for a natural and computationally tractable slice of the transseries world.

---

## Ranks: turning growth into arithmetic

The first idea is a piece of bookkeeping so simple it feels like cheating. Consider the functions

$$\mathfrak{m}_{d,a,b,c}(x) \;=\; \exp(d\,e^x)\cdot \exp(a x)\cdot x^{b}\cdot (\log x)^{c},$$

where $d,a,b,c$ are arbitrary *real* numbers. Call these the **transmonomials**. They cover an enormous range: $c=1$ and the rest zero gives $\log x$; $b=1$ gives $x$; $b = \pi$ gives $x^\pi$; $a=1$ gives $e^x$; $d=1$ gives $e^{e^x}$; $a=-1$ gives the decaying $e^{-x}$.

Now notice two things.

**First**, transmonomials multiply by *adding* their exponent data:

$$\mathfrak{m}_{d,a,b,c}\cdot \mathfrak{m}_{d',a',b',c'} \;=\; \mathfrak{m}_{d+d',\,a+a',\,b+b',\,c+c'}.$$

So under multiplication the transmonomials are just a copy of the additive group $\mathbb{R}^4$. Inverses and powers come free: $\mathfrak{m}_{d,a,b,c}^{-1} = \mathfrak{m}_{-d,-a,-b,-c}$ and $\mathfrak{m}^n = \mathfrak{m}_{nd,na,nb,nc}$.

**Second** — and this is the theorem that makes the whole subject work — *comparing* transmonomials is comparing their exponent data **lexicographically**, fastest scale first.

> **Scale Comparison Theorem.** $\mathfrak{m}_{d,a,b,c} \prec \mathfrak{m}_{d',a',b',c'}$ (the first is eventually negligible against the second) precisely when $d < d'$, or $d = d'$ and $a<a'$, or $d=d'$, $a=a'$ and $b<b'$, or $d=d'$, $a=a'$, $b=b'$ and $c<c'$.

Read it slowly and you'll see that it *contains* the whole folklore of growth rates. The double-exponential coordinate $d$ dominates everything: if $d < d'$, no amount of compensation in $a$, $b$, $c$ can help. Only when the double-exponential rates tie does the exponential rate $a$ get a vote, and so on down.

The sharp consequences are worth spelling out, because they are exactly the statements that the naive picture of "a ladder of growth rates" gets wrong. For every natural number $n$:

$$(\log x)^n \prec x, \qquad x^n \prec e^x, \qquad (e^x)^n \prec e^{e^x}.$$

No finite power of one level ever reaches the next. The levels are separated by infinite gaps, and the gaps are filled with a continuum of intermediate rates.

---

## The field of transseries

With ranks in hand, a transseries is defined as a formal sum

$$f \;=\; \sum_{\mathfrak{m}} c_{\mathfrak{m}}\,\mathfrak{m}$$

over transmonomials, with real coefficients, subject to one discipline: the set of transmonomials actually appearing must be *well-ordered* going downward, so that there is always a unique biggest term, a unique next-biggest, and so on. This condition is what lets you add, multiply and divide these infinite sums without ever facing an ill-defined computation. The result is a genuine field, and — because every nonzero transseries has an unambiguous leading term with a nonzero real leading coefficient — it carries a canonical order: $f > 0$ exactly when its leading coefficient is positive.

That order is **not Archimedean**. No integer multiple of $1$ ever reaches $x$; the transseries $1/x$ is a nonzero quantity smaller than every positive real number. Infinities and infinitesimals live here on equal footing with ordinary numbers, and unlike the infinitesimals of nonstandard analysis they are entirely explicit: $1/x$, $1/\log x$, $e^{-x}$ are all infinitesimal, and you can compute with them by hand.

---

## Taking roots: where the infinite sums earn their keep

Here is the first serious theorem.

> **Root Extraction Theorem.** Every positive transseries has a positive $n$-th root, for every $n \ge 1$. Consequently the nonnegative transseries are *exactly* the squares, and every transseries whatsoever — positive, negative or zero — has an $n$-th root when $n$ is odd.

The proof is a three-step factorisation that repays study, because it shows precisely why finite expressions are not enough. Write a positive transseries as

$$f \;=\; \underbrace{\mathfrak{m}}_{\text{leading transmonomial}} \cdot \underbrace{r}_{\text{leading coefficient} > 0} \cdot \underbrace{(1+\varepsilon)}_{\varepsilon \text{ infinitesimal}}.$$

- The transmonomial $\mathfrak{m}$ has an $n$-th root because you can divide its exponent data by $n$: the rank group $\mathbb{R}^4$ is *divisible*. This is why the exponents were allowed to be real numbers rather than integers.
- The positive real $r$ has an $n$-th root because $\mathbb{R}$ does.
- The factor $1+\varepsilon$ has an $n$-th root because of the binomial series
  $$(1+\varepsilon)^{1/n} \;=\; 1 + \tfrac1n \varepsilon + \tfrac{\frac1n(\frac1n-1)}{2}\varepsilon^2 + \cdots,$$
  which converges *formally* because $\varepsilon$ is infinitesimal, so higher powers of $\varepsilon$ live at ever-smaller ranks.

That last step is the moment of truth. Even when $\varepsilon$ is a single monomial like $1/x$, the root $(1+1/x)^{1/2}$ is an honestly infinite series $1 + \frac{1}{2x} - \frac{1}{8x^2} + \frac{1}{16x^3} - \cdots$. Transseries are not a notational convenience wrapped around finite algebra; the infinite sums are load-bearing.

A striking corollary: **$-1$ is not a sum of squares** in this field. Transseries are *formally real*, just like $\mathbb{R}$ — an algebraic fact about a system of infinite formal objects.

---

## The order is not an extra structure — it is forced

Because the nonnegative elements are exactly the squares, one may replace the inequality sign entirely:

$$f \le g \iff g - f \text{ is a square.}$$

This looks like a triviality until you see what it buys.

> **Order Rigidity Theorem.** The asymptotic ordering is the *unique* ordering compatible with the ring operations. Moreover, every ring homomorphism from the transseries field into any ordered field is automatically order-preserving — in particular, every symmetry of the transseries field respects the entire hierarchy of growth rates.

In other words, growth is encoded in addition and multiplication alone. No structure remembers "which functions grow faster"; the arithmetic already knows. An algebraic isomorphism cannot secretly swap $x$ and $1/x$.

The same square-root machinery immediately gives the quadratic formula: a monic quadratic $z^2 + bz + c$ has a transseries root exactly when $b^2 - 4c \ge 0$. So $z^2 = x$ has a solution — $\sqrt{x}$ is a transseries — while $z^2 = -1$ does not.

---

## The point of it all: expansions determine functions

So far this is formal algebra. The payoff is the bridge back to analysis.

Take the finite real linear combinations of transmonomials — expressions like $3e^{x}/x^2 - 5\log x + 7$. Each such expression names an actual real function on $(1,\infty)$, and each also names a (finite) transseries. Both assignments are ring homomorphisms, and the central theorem says they have *exactly the same fibres*:

> **Faithfulness Theorem.** Two such expressions define eventually equal functions if and only if their transseries expansions are identical. Furthermore one function is eventually smaller than the other exactly when its transseries is smaller.

So the expansion is a complete invariant, and an order-preserving one: the germs at $+\infty$ of these functions form an ordered ring sitting inside the transseries field, exactly matching the classical notion of a **Hardy field**.

The sharpest form of the statement is the one that gives this circle of ideas its name.

> **Asymptotic Comparison Theorem.** *(Formal.)* A transseries whose absolute value is smaller than **every** transmonomial is zero. Equivalently, two transseries that agree to all orders are equal.
> *(Analytic.)* If the difference of two exp-log functions is $o(\mathfrak{m})$ for every transmonomial $\mathfrak{m}$, then the two expressions are literally the same.

This is not a tautology, and it is worth saying why. In ordinary asymptotic analysis, "agrees to all orders" does *not* imply equality: the function $e^{-1/x^2}$ has every Taylor coefficient zero at the origin without being zero. Such **flat** functions are the bane of classical asymptotics — they are invisible to expansion. The theorem above says the exp-log world has no flat elements at all. Nothing hides below the scale. That is why the expansion loses no information, and it is the precise sense in which "the transseries *is* the function".

---

## No oscillation, and always a limit

Two more consequences of the same dominant-term analysis paint the picture of how tame these functions are.

> **Hardy Field Theorem.** Every exp-log function of the kind above eventually becomes strictly increasing, strictly decreasing, or constant — it never oscillates forever. Consequently it has a limit at $+\infty$ in $\mathbb{R}\cup\{\pm\infty\}$, and if it is non-constant it is eventually injective.

Compare $\sin x$, which does none of these things. The exp-log world is a place where limits always exist and pathology has been zoned out. That is precisely why Hardy fields are the natural home for asymptotic analysis, and why they appear in the model theory of o-minimal structures, in the resurgence theory of divergent perturbation series, and in the automated algorithms that computer algebra systems use to evaluate limits.

---

## The escape of $\log\log x$

Differentiation stays inside this world. The logarithmic derivative of a transmonomial is

$$\frac{\mathfrak{m}'_{d,a,b,c}}{\mathfrak{m}_{d,a,b,c}} \;=\; d\,e^x + a + \frac{b}{x} + \frac{c}{x\log x},$$

which is again a finite combination of transmonomials. So the algebra of exp-log expressions is a **differential ring**: it satisfies the Leibniz rule, and the formal derivative computed symbolically is the honest analytic derivative of the corresponding function. A pleasing structural fact confirms that the derivation is the right one: **its kernel is exactly the constants $\mathbb{R}$**, nothing more. (The proof is a nice cross-over argument: a vanishing formal derivative gives a real function with vanishing derivative, hence a constant by the mean value theorem, and faithfulness of the expansion pushes that conclusion back to the formal side.)

Integration is a different story — and here is where the subject bites back. The function $1/x$ *does* have an antiderivative in the algebra, namely $\log x$. What about $1/(x\log x)$? Its antiderivative is $\log\log x$, and:

> **Liouville-type Obstruction.** $\log \log x$ is not an exp-log function of this type, not even up to an additive constant. Hence $1/(x\log x)$ has no antiderivative in the algebra.

The proof is a beautiful piece of asymptotic reasoning rather than symbolic bookkeeping. Any function in the algebra that tends to $+\infty$ must, by the dominant-term theorem, be asymptotic to a constant multiple of a single *growing* transmonomial. But $\log\log x$ grows — and grows more slowly than **every** growing transmonomial in the scale, including $(\log x)^{\epsilon}$ for arbitrarily small $\epsilon>0$. It is a genuine ghost: unboundedly large, yet flat against the entire hierarchy. So it can be no such asymptotic multiple, and the escape is complete.

This is the exact analogue, one level up, of the classical fact that $1/x$ has no rational antiderivative. Each closure of the algebra under integration forces a new layer of the logarithmic tower, forever.

---

## Roots that radicals cannot reach

The final theme is the algebraic ambition of the subject: is the transseries field **real closed**? A real closed field is one that behaves algebraically exactly like $\mathbb{R}$: the nonnegative elements are the squares, and every odd-degree polynomial has a root. The first half is a theorem here. The second half is the deep half.

Two genuine advances toward it:

**1. Roots beyond radicals.** For any infinitesimal $t$ (say $t = 1/x$, or $e^{-x}$), the cubic

$$z^3 - 3z + t = 0$$

has a transseries root — even though its Cardano discriminant $t^2/4 - 1$ is strictly negative. This is the classical **casus irreducibilis**: a cubic with three real roots whose roots cannot be written using real radicals. So this root can *not* be produced by the $n$-th-root theorem; it is genuinely new. It is obtained by Hensel's lemma instead: the polynomial $z^3 - 3z$ has the simple root $z=0$, and simple roots *deform* uniquely when the coefficients are perturbed infinitesimally. Making this precise required proving that the ring of real formal power series is complete for the $X$-adic topology (hence Henselian), and then substituting an infinitesimal transseries for $X$. Cubics with nonnegative discriminant, by contrast, are solved outright by Cardano's formula, since the field has both square and cube roots.

**2. Newton scaling.** Classical Newton-polygon theory says: to find the roots of a polynomial over a valued field, first *rescale* so that the coefficients become comparable. Substituting $z = \lambda w$ and dividing by $\lambda^n$ turns a monic $P$ of degree $n$ into a monic polynomial whose coefficients are $\lambda^{i-n}a_i$, with the same roots up to the factor $\lambda$. The theorem proved here is that the right $\lambda$ always exists inside the transseries field:

> **Newton Normalisation Theorem.** For every monic $P$ of degree $n$ there is a positive transseries $\lambda$ — explicitly, $\lambda = \max_i |a_i|^{1/(n-i)}$ over the indices $i<n$ with $a_i \neq 0$ — such that the rescaled polynomial has all coefficients of absolute value at most $1$, and (unless $P = z^n$) at least one non-leading coefficient of absolute value exactly $1$.

The maximum makes sense because the ordering is total; the fractional powers exist because of the Root Extraction Theorem. Normalisation matters because it makes the residue polynomial — reduce all coefficients modulo the infinitesimals — a *genuine* monic real polynomial of degree $n$, different from $z^n$, so that real closedness of $\mathbb{R}$ (proved via the intermediate value theorem) becomes usable. A companion Cauchy-type bound shows every root of a normalised monic polynomial satisfies $|z| < 2$.

Together with a reduction showing that real closedness is *equivalent* to the odd-degree root property for monic polynomials, this cuts the open problem down to a single sharply stated clause: **every normalised monic odd-degree polynomial over the transseries field has a root**. That the full statement remains open is worth saying plainly; what has been achieved is a reduction to exactly the hypothesis under which the classical Newton-polygon/Hensel machinery operates, with the two classical inputs — divisibility of the value group, real closedness of the residue field — both in hand.

---

## Why care

Transseries are not an exotic curiosity. They are the language in which computer algebra systems compute limits of complicated exp-log expressions: represent both sides as transseries, compare the dominant terms, read off the answer. They are the framework of *resurgence theory* in mathematical physics, where the divergent perturbative expansions of quantum field theory and of nonlinear ODEs are completed by exponentially small non-perturbative terms — precisely the terms that a power series cannot see and a transseries can. They are central to the model theory of Hardy fields and o-minimal structures, where the question of real closedness is the question of how much of $\mathbb{R}$'s algebra survives at infinity.

And at the heart of all of it is one modest observation with outsized consequences: growth rates, if you record them as points in $\mathbb{R}^4$ and compare them lexicographically, become *arithmetic*. Once you can add and compare growth rates, you can add, multiply, divide, differentiate and take roots of the functions that carry them. Infinity becomes a place with coordinates.
