# The Monster in a Single Coefficient

## How a 194-fold product of mysterious series turns out to remember everything

In 1978 the mathematician John McKay noticed something that should not have
happened. He was reading about two utterly unrelated subjects. On one side sat
the **modular function** $j$, an object from nineteenth-century complex
analysis whose expansion in a variable $q$ begins

$$j(q) \;=\; \frac{1}{q} + 744 + 196884\,q + 21493760\,q^{2} + 864299970\,q^{3} + \cdots$$

On the other side sat the **Monster**, the largest of the twenty-six sporadic
finite simple groups — a single, exceptional symmetry object with roughly
$8 \times 10^{53}$ elements, so large that it took decades to prove it exists at
all. The smallest way the Monster can act nontrivially on a vector space, other
than doing nothing, is in dimension $196883$.

McKay's observation was the arithmetic of a schoolchild:

$$196884 \;=\; 196883 + 1.$$

That could be coincidence. It was not. The next coefficient obeys

$$21493760 \;=\; 1 + 196883 + 21296876,$$

where $21296876$ is the next smallest dimension in which the Monster can act.
And the one after that,

$$864299970 \;=\; 2 \cdot 1 + 2\cdot 196883 + 21296876 + 842609326.$$

Every coefficient of a function from analysis turned out to be a sum of
dimensions of representations of a gigantic finite group. John Conway and Simon
Norton christened the phenomenon **Monstrous Moonshine** — "moonshine" being
British slang for something illicit, delusional, or too good to be true.

This article is about a different, quieter question hiding inside moonshine:
**how much of the phenomenon can be pinned down by a finite amount of
arithmetic?** The answer turns out to be: much more than one might expect, and
in a very precise sense, *all* of it — at the level of the crucial first
coefficients.

---

## The 194 series

Conway and Norton's conjecture is not just about $j$. To every conjugacy class
$g$ of the Monster — there are exactly $194$ of them — moonshine attaches a
series called the **McKay–Thompson series**,

$$T_g(q) \;=\; \frac{1}{q} + 0 + c_g(1)\,q + c_g(2)\,q^{2} + \cdots$$

The identity class gives back $j$ minus its constant: $T_{1A} = j - 744$, so
that $c_{1A}(1) = 196884$. For every other class, $T_g$ is a genuinely
different series, and moonshine predicts that each of them is again a very
special modular function. All $194$ share a rigid shape: a simple pole
$q^{-1}$, no constant term, and integer coefficients from then on.

The list of first coefficients
$$c_{1A}(1),\; c_{2A}(1),\; \dots,\; c_{\text{last}}(1)$$
is what we shall call the **head table**: $194$ integers, one for each class.
Moonshine predicts every one of them, because it predicts
$c_g(1) = 1 + \chi(g)$, where $\chi$ is the character of the $196883$-dimensional
representation. In particular, $|c_g(1) - 1| \le 196883$ for all $g$, with
equality exactly at the identity class, where $\chi(1A) = 196883$.

Now form the product of all $194$ series at once:

$$P \;=\; \prod_{g} T_g(q) \;=\; T_{1A}(q)\,T_{2A}(q)\cdots$$

Each factor blows up like $1/q$ near $q = 0$, so the product blows up like
$q^{-194}$. This single object is the hero of the story.

---

## Why a product?

The reason to multiply is a familiar one from high-school algebra. If you take
a polynomial and multiply out its linear factors,

$$(x + a_1)(x + a_2)\cdots(x + a_n) = x^n + e_1 x^{n-1} + e_2 x^{n-2} + \cdots + e_n,$$

the coefficients you get are the **elementary symmetric functions**
$e_1 = \sum a_i$, $e_2 = \sum_{i<j} a_i a_j$, and so on: Vieta's formulas. The
individual $a_i$ get scrambled, but the collection of them is faithfully
recorded in the coefficients.

The same thing happens for the moonshine product, and the computation is
prettier than one might guess. Multiply the polar part away: $q\,T_g$ is an
ordinary power series with constant term $1$. If we keep only the head of each
series — that is, if we replace $T_g$ by the "toy" series
$q^{-1} + c_g(1)\,q$, which has the right pole, no constant term, and the right
first coefficient — then

$$q\left(\frac{1}{q} + c_g(1)\,q\right) = 1 + c_g(1)\,q^{2},$$

and therefore

$$q^{194}\,P \;=\; \prod_{g}\bigl(1 + c_g(1)\,q^{2}\bigr).$$

Expanding the right-hand side is exactly Vieta again, with $q^2$ in place of a
formal variable. The result is a clean statement:

> **Vieta for the moonshine product.** For every $k$, the coefficient of
> $q^{2k-194}$ in the $194$-fold product is the $k$-th elementary symmetric
> function $e_k$ of the head table.

The case $k = 0$ says the leading term is exactly $q^{-194}$ with coefficient
$1$: the pole has order exactly $194$, no accidental cancellation. The case
$k=1$ is the one that matters most:

> **The reduction.** The coefficient of $q^{-192}$ in the $194$-fold product
> equals $\sum_g c_g(1)$, the plain sum of the head table.

---

## From transcendence to arithmetic

That last statement deserves a moment of appreciation. On the left is an
analytic-looking quantity: a Laurent coefficient of an infinite product of
modular functions attached to the largest sporadic simple group. On the right
is a sum of $194$ integers.

So a statement like *"the coefficient of $q^{-192}$ in the moonshine product is
$S$"* — which sounds like it needs modular forms, Hauptmoduln, genus-zero
subgroups of $\mathrm{SL}_2(\mathbb{R})$ and the whole apparatus — is
**exactly equivalent** to the schoolroom assertion

$$c_{1A}(1) + c_{2A}(1) + \cdots \;=\; S.$$

Nothing has been lost and nothing has been added: it is an "if and only if".
And an equation between two integers is *checkable*. You add up $194$ numbers
and compare. There is no approximation, no truncation error, no analytic
subtlety left.

The same collapse happens one level deeper. The next coefficient of a general
product of such series is governed by a Newton-type identity: for $m$ series
with heads $a_0^{(i)}, a_1^{(i)}, a_2^{(i)}$, the coefficient of $q^{3-m}$ in
the product is

$$\sum_i a_2^{(i)} \;+\; \Bigl[\Bigl(\sum_i a_0^{(i)}\Bigr)\Bigl(\sum_i a_1^{(i)}\Bigr) - \sum_i a_0^{(i)}a_1^{(i)}\Bigr] \;+\; \frac{p_1^3 - 3p_1p_2 + 2p_3}{6},$$

where $p_r = \sum_i (a_0^{(i)})^r$ are power sums of the constant terms. For
McKay–Thompson series all the constant terms vanish, every correction term dies,
and the whole expression collapses to $\sum_g c_g(2)$: the coefficient of
$q^{-191}$ in the product is the sum of the *second* column of the head table.

---

## The worry, and the answer

Here is the obvious objection to celebrating too early. A single number —
the sum of $194$ integers — is a very coarse fingerprint. Trillions of
different tables have the same sum. If somebody handed you a scrambled or
subtly wrong table, the sum would happily agree, and the check would pass.
Isn't the reduction *lossy*?

The surprising answer is: **the full product is not lossy at all.**

> **Rigidity of the head table.** Two integral head tables produce the same
> $194$-fold product if and only if they are rearrangements of each other. In
> other words, the product determines the multiset $\{c_g(1)\}$ exactly.

So while any *one* coefficient of the product is a coarse invariant, the
product as a whole is a **complete** invariant of the table up to relabelling —
which is the best any product can possibly do, since multiplication does not
know the order of its factors.

The proof is Vieta run backwards. Equal products force equal coefficients in
every degree $2k - 194$, hence equal elementary symmetric functions $e_k$ for
all $k$. But the $e_k$ are precisely the coefficients of the monic polynomial

$$\Phi(X) \;=\; \prod_g \bigl(X + c_g(1)\bigr) \;=\; X^{194} + e_1X^{193} + \cdots + e_{194},$$

and over the complex numbers a monic polynomial factors into linear factors in
essentially one way. So the two tables give the same polynomial, hence the same
multiset of roots, hence the same multiset of entries. Turning the argument
around, two tables that are rearrangements obviously give the same product,
since a product does not care about the order of its factors.

Two consequences follow immediately, both practical.

First, the **contrapositive that a checker actually uses**: if two candidate
tables have different sums, then already their products differ. Perturb any
entry of a proposed table and the product notices.

Second, **decidability**: comparing two Monster-sized Laurent products —
infinite objects, built from $194$ transcendental-looking series — reduces to
comparing two multisets of $194$ integers, which a computer settles in
microseconds. An equality that looks like a question in analysis is, provably,
a question in finite combinatorics.

---

## Where the numbers come from

A reduction is only as good as its input. It is easy to say "add up the $194$
entries"; it is a different matter to *know* an entry rather than copy it from a
table in a book. So it is worth asking what it costs to establish even one.

Take the identity class. Its entry is the coefficient of $q$ in $j - 744$, and
$j$ is built from two classical series,

$$E_4 = 1 + 240\sum_{n \ge 1}\sigma_3(n)\,q^n, \qquad \Delta = q\prod_{k \ge 1}(1-q^k)^{24}, \qquad j = \frac{E_4^{3}}{\Delta},$$

where $\sigma_3(n)$ is the sum of the cubes of the divisors of $n$. Remarkably,
one can determine the coefficients of $j$ without any analysis whatsoever, by
pure formal algebra with integer coefficients. Three ideas make it work.

**Truncation stability.** The infinite product $\prod_{k\ge1}(1-q^k)^{24}$ looks
like it needs a convergence theorem to make sense. It does not: because
$(1-q^k)^{24}$ differs from $1$ only in degrees $\ge k$, the coefficients of the
partial product $\prod_{k \le m}(1-q^k)^{24}$ below degree $N$ stop changing as
soon as $m \ge N-1$. The infinite product is well defined coefficient by
coefficient, for free.

**Unit-ness.** That product has constant term $1$, so it is invertible in the
ring of integer power series. Hence the equation $\Delta/q \cdot f = E_4^3$ has
one and only one solution $f$, and its coefficients are automatically integers.
No denominators ever appear; the integrality of the $j$-coefficients is a
triviality of formal algebra, not a theorem about modular forms.

**A congruence calculus.** Working "modulo $q^N$" is working in the quotient by
the ideal generated by $q^N$; congruences multiply, take powers, and — because
of unit-ness — allow cancellation. A finite convolution of integer lists then
establishes the truncated identity

$$E_4^{3} \;\equiv\; \Bigl(\prod_{k \le 11}(1-q^{k})^{24}\Bigr)\cdot\bigl(1 + 744q + 196884q^{2} + 21493760q^{3} + \cdots\bigr) \pmod{q^{12}},$$

and cancellation upgrades it from "one solution has these coefficients" to
"**every** solution has these coefficients". The head entry
$c_{1A}(1) = 196884$ is then *forced*, not assumed — and McKay's
$196884 = 196883 + 1$ is a statement about a number one has derived.

The same computation hands over a bonus. The coefficients of
$\prod_{k\ge1}(1-q^k)^{24}$ are the Ramanujan tau values

$$\tau = 1,\, -24,\, 252,\, -1472,\, 4830,\, -6048,\, -16744,\, 84480,\, -113643,\, -115920,\, 534612,\, -370944,$$

and on these derived numbers one can *observe* the deep structural facts rather
than quote them: multiplicativity $\tau(2)\tau(3) = \tau(6)$, the prime-power
recursions $\tau(4) = \tau(2)^2 - 2^{11}$, $\tau(9) = \tau(3)^2 - 3^{11}$,
$\tau(8) = \tau(2)\tau(4) - 2^{11}\tau(2)$, Ramanujan's congruence
$\tau(n) \equiv \sigma_{11}(n) \pmod{691}$, and the non-vanishing of $\tau(n)$
in this range — the first window of Lehmer's still-open conjecture that
$\tau(n)$ never vanishes.

---

## What this buys, and what it does not

Put the pieces together and the picture is this. The moonshine head statement —
an assertion about the Laurent expansion of a product of $194$ modular-looking
series — is *equivalent* to a sum of $194$ integers taking a specific value.
The full product, moreover, is a complete invariant: it remembers the entire
table up to relabelling, so the arithmetic reformulation throws nothing away.
And the table entries are the sort of thing that can be computed from
first principles, as the identity class demonstrates.

There is even a cheap sanity check that requires no modular input at all. If
moonshine is right, then every entry satisfies $|c_g(1) - 1| \le 196883$,
because $c_g(1) - 1$ is a character value of a $196883$-dimensional
representation and character values are bounded by the dimension. Summing over
$194$ classes,

$$\bigl|\textstyle\sum_g c_g(1) - 194\bigr| \;\le\; 194 \cdot 196883 = 38195302,$$

so the check must land in the interval $[-38195108,\, 38195496]$. A proposed
table violating that is refuted instantly — no modular forms required. And the
identity class is precisely the extreme case, $|c_{1A}(1) - 1| = 196883$: the
numerical fingerprint of the fact that the character of a representation attains
its maximum modulus at the identity.

What the story does *not* do is prove moonshine. Conway and Norton's conjecture
— proved in 1992 by Richard Borcherds, work for which he received the Fields
Medal — is a statement about *all* the coefficients of *all* $194$ series and
their modularity, and no finite check reaches that. What the reduction does is
carve out a well-defined, finite, self-contained fragment: the head layer, which
is exactly the layer McKay first noticed. Within that layer, an infinite,
analytic-looking question has been converted, without loss, into arithmetic on
$194$ integers.

That conversion is the point. Mathematics is full of statements that look
transcendental and are secretly finite. Finding the boundary — the exact place
where the infinite collapses into the countable, and then into the finitely
checkable — is one of the most useful things one can do with a hard theorem. In
moonshine, that boundary sits precisely one Vieta formula deep.

---

## Coda: a symmetric-function spectrum

Vieta gives more than the sum. Every coefficient of the moonshine product in
degree $2k - 194$ is the elementary symmetric function $e_k$ of the head table —
a whole spectrum of invariants, $195$ of them, interpolating between the
leading $1$ and the giant product $e_{194} = \prod_g c_g(1)$.

That spectrum invites a question one can actually attack. Newton's inequalities
say that for a polynomial with all real roots, the normalized coefficients
$e_k/\binom{n}{k}$ form a log-concave sequence:
$e_{k-1}e_{k+1} \le e_k^2$ after normalization. The polynomial
$\prod_g (X + c_g(1))$ has all real roots by construction, since its roots are
minus the head entries. So the moonshine spectrum is subject to Newton's and
Maclaurin's inequalities — a rigid analytic-looking constraint on the Laurent
expansion of a Monster-sized product, arrived at with nothing but symmetric
function theory.

The Monster, in other words, has left a shadow that is entirely elementary. You
just have to multiply everything together and read off the coefficients.
