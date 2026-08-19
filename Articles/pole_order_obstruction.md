# The Pole That Cannot Be Cancelled

## How a single integer explains why moonshine's building blocks refuse to multiply

There is a strange and beautiful family of mathematical objects sitting at the
heart of one of the deepest stories in modern algebra. They are called
*McKay–Thompson series*, and each one is an infinite expansion in a variable
$q$ that begins the same way:

$$T = \frac{1}{q} + a_0 + a_1 q + a_2 q^2 + a_3 q^3 + \cdots$$

There are exactly $194$ of them — one for each conjugacy class of the Monster,
the largest of the sporadic finite simple groups, a symmetry group with roughly
$8 \times 10^{53}$ elements living in $196883$ dimensions. Every one of these
$194$ series starts with the same simple pole $q^{-1}$, and then their
coefficients encode, class by class, the representation theory of a group so
large it was once thought not to exist.

A natural instinct, when handed $194$ objects that all look alike, is to
multiply them together. Surely, one thinks, the family is closed under
multiplication: they all have the same shape, so the product should have that
shape too.

It does not. And the reason it does not is a single integer.

---

## Series with a pole

Let us set up the stage carefully, because the whole story lives in the setup.

A **formal power series** in $q$ is an infinite expression
$c_0 + c_1 q + c_2 q^2 + \cdots$: no negative powers allowed. Power series
form a ring — you can add them and multiply them and never leave the world of
non-negative exponents.

A **formal Laurent series** relaxes this. It allows finitely many negative
powers:

$$f = \sum_{n \ge N} c_n q^n$$

for some integer $N$ that may be negative. Laurent series form a *field*: every
nonzero one has a multiplicative inverse. The Laurent series with complex
coefficients we will write as $\mathbb{C}(\!(q)\!)$, and the power series
subring as $\mathbb{C}[\![q]\!]$.

Every nonzero Laurent series has an **order**: the smallest exponent whose
coefficient is nonzero. So $3q^{-2} + q^5$ has order $-2$; the series $1 + q$
has order $0$; the series $q^7$ has order $7$. Negative order means a *pole* at
$q = 0$; non-negative order means the series is honestly a power series. It is
convenient to declare the order of the zero series to be $+\infty$ — a symbol
that swallows everything it is added to. That convention will matter later, and
in a way that is not merely cosmetic.

Call a Laurent series **normalized** if it has the exact shape of a
McKay–Thompson series:

> **Definition.** A Laurent series $f$ is *normalized* if the coefficient of
> $q^{-1}$ in $f$ equals $1$, and every coefficient in degree strictly below
> $-1$ vanishes.

Equivalently: $f = q^{-1} + a_0 + a_1 q + a_2 q^2 + \cdots$. The pole is simple
and its residue is exactly $1$. All $194$ moonshine series satisfy this, and
the most famous of them — the modular $j$-function shifted by $744$, usually
written

$$J(q) = \frac{1}{q} + 196884\, q + 21493760\, q^2 + 864299970\, q^3 + \cdots$$

— is the case where the Monster acts trivially.

---

## Orders add

Here is the entire engine of the story, in one sentence: **the order of a
product is the sum of the orders.**

This is completely elementary, and completely decisive. If $f$ has order $d$
and $g$ has order $e$, then $f = c_d q^d + \cdots$ and $g = c_e q^e + \cdots$
with $c_d, c_e \ne 0$, so the lowest term of $fg$ is $c_d c_e q^{d+e}$. Since
$\mathbb{C}$ has no zero divisors, $c_d c_e \ne 0$, and the order of $fg$ is
exactly $d + e$. Not "at least"; exactly. There is no cancellation, and there
cannot be: the leading coefficients simply cannot annihilate one another in a
field.

That word "exactly" is the whole point. A bound would leave room for hope. An
equality closes the door.

Now count. Each normalized series has order $-1$. Multiply $m$ of them and the
orders add:

> **Theorem (Pole-Order Theorem).** Let $f_1, \dots, f_m$ be normalized Laurent
> series. Then the product $f_1 f_2 \cdots f_m$ has order exactly $-m$, and its
> leading coefficient — the coefficient of $q^{-m}$ — is exactly $1$.

The leading-coefficient claim follows by the same argument: each leading
coefficient is $1$, and $1 \cdot 1 \cdots 1 = 1$. So the product begins
$q^{-m} + \cdots$: it is normalized-*looking*, but at the wrong depth.

And now the punchline, which is immediate but worth stating as a theorem in its
own right because of what it rules out:

> **Theorem (Non-Closure).** A product of $m$ normalized series is itself
> normalized if and only if $m = 1$.

For a normalized series has order $-1$, and the product has order $-m$; these
agree precisely when $m = 1$. The family of normalized series is closed under
multiplication only in the trivial sense in which any set is closed under a
one-fold product.

This is what we call the **pole-order obstruction**. It is not a subtle
analytic difficulty. It is an integer, and the integer is wrong.

For the Monster: multiply all $194$ McKay–Thompson series together and you get
a series whose expansion begins

$$\frac{1}{q^{194}} + \cdots$$

with leading coefficient exactly $1$. A pole of order $194$ — one order of
pole for every conjugacy class of the Monster. In particular the full moonshine
product is *not* a power series at all: it has a genuine pole, so it does not
lie in $\mathbb{C}[\![q]\!]$, and no amount of rearrangement will put it there.

---

## The cure, and its uniqueness

Of course there is an obvious fix. If the trouble is a pole of order $m$,
multiply by $q^m$.

> **Theorem (Correction).** For normalized $f_1, \dots, f_m$, the series
> $q^m f_1 \cdots f_m$ has order exactly $0$, and $m$ is the *only* exponent
> with that property: for a natural number $k$, the series $q^k f_1 \cdots f_m$
> has order $0$ if and only if $k = m$.

Again this is just addition: $k + (-m) = 0$ forces $k = m$. But the uniqueness
matters. It says that the correction factor is not a choice, not a convention,
not one normalization among several. It is *determined by the arithmetic of the
obstruction*. Count the factors and you know the fix.

What is more surprising is where the corrected series lands. Order $0$ merely
says "no pole" — it says the result is a power series with some nonzero constant
term. But the constant term here is forced:

> **Theorem (Unit Structure).** For normalized $f_1, \dots, f_m$, the corrected
> product $q^m f_1 \cdots f_m$ is a power series with constant term $1$ — hence
> an *invertible* element of the ring of power series.

The reason is a factorization that is worth isolating, because it is the
structural heart of everything above:

> **Theorem (Unique Factorization of Normalized Series).** Every normalized
> Laurent series $f$ can be written as
> $$f = q^{-1} \cdot u$$
> for a power series $u$ with constant term $1$, and the power series $u$ is
> uniquely determined by $f$.

Existence is a shift: the coefficients of $u$ are the coefficients of $f$ moved
one step, so $u = 1 + a_0 q + a_1 q^2 + \cdots$, whose constant term is $1$ by
normalization. Uniqueness is because $q^{-1}$ is invertible: multiply both sides
by $q$ and $u$ is pinned down.

Once you have this, the pole-order theorem stops being a computation and becomes
a tautology. Write each $f_i = q^{-1} u_i$. Then

$$f_1 \cdots f_m = q^{-m} \, (u_1 \cdots u_m),$$

and the product $u_1 \cdots u_m$ of power series with constant term $1$ is again
a power series with constant term $1$ — an invertible power series, since a
power series is invertible exactly when its constant term is nonzero. So the
whole product is a monomial $q^{-m}$ times a *unit*. The pole is a clean,
separated, monomial factor; the "interesting content" is a unit; and no
interaction between the two can ever occur.

The invertible power series with constant term $1$ form a group under
multiplication. That is the deep reason nothing cancels: the group $1 + q\,
\mathbb{C}[\![q]\!]$ contains no element that can reduce the exponent of the
monomial in front. The pole and the unit live in complementary directions.

---

## A group homomorphism in disguise

There is a slicker way to say all of this, and it is the way that generalizes.

Since $\mathbb{C}(\!(q)\!)$ is a field, its nonzero elements form a group under
multiplication, and "order" is a map from this group to the integers. The
statement "orders add" is precisely the statement that this map is a **group
homomorphism**

$$\mathrm{ord} \colon \mathbb{C}(\!(q)\!)^{\times} \longrightarrow \mathbb{Z}.$$

It is surjective: the monomial $q^k$ is invertible with inverse $q^{-k}$, and
has order $k$, so every integer is realized as the order of some invertible
Laurent series.

Now the obstruction has a one-line description. Normalized series lie in the
fibre $\mathrm{ord}^{-1}(-1)$. A product of $m$ of them lies in
$\mathrm{ord}^{-1}(-m)$. Distinct fibres of a homomorphism are disjoint. Done.

This reframing explains why the obstruction is *complete* rather than merely a
necessary condition. It is not that we found one invariant that happens to
distinguish the product from a normalized series; it is that the invariant is a
homomorphism, its fibres partition the group, and membership in the wrong fibre
is an absolute barrier. One integer decides everything, and integers do not
negotiate.

---

## What the next coefficients know

Order tells you where a series begins. The coefficients just after the start
tell you what the factors were doing, and here something pretty happens: the
first few coefficients of a big product are *symmetric functions* of the first
few coefficients of the factors.

Write each normalized factor as $f_i = q^{-1} + a_i + b_i q + \cdots$, so $a_i$
is its constant term and $b_i$ its linear coefficient.

> **Theorem (Subleading Coefficient).** The coefficient of $q^{1-m}$ in
> $f_1 \cdots f_m$ — one step above the pole — equals $a_1 + a_2 + \cdots + a_m$,
> the sum of the constant terms of the factors.

> **Theorem (Sub-subleading Coefficient).** The coefficient $c$ of $q^{2-m}$ in
> $f_1 \cdots f_m$ satisfies
> $$2c \;=\; 2\sum_{i} b_i \;+\; \Big(\sum_i a_i\Big)^{\!2} \;-\; \sum_i a_i^2 .$$
> Equivalently, $c = \sum_i b_i + e_2(a_1, \dots, a_m)$, where
> $e_2$ is the second elementary symmetric polynomial $\sum_{i<j} a_i a_j$.

Both follow from the factorization: the coefficient of $q^{k-m}$ in the product
is the coefficient of $q^k$ in the unit part $u_1 \cdots u_m$, and expanding a
product of power series with constant term $1$ produces exactly the elementary
symmetric functions of the lower coefficients. The identity is written in the
"denominator-free" form $2c = \cdots$ because $\big(\sum a_i\big)^2 - \sum a_i^2
= 2 e_2(a)$ — a Newton-style identity relating power sums to elementary
symmetric functions. This is the first step of an entire hierarchy: at level $k$
the coefficient at $q^{k-m}$ is a universal polynomial in the coefficients of
the factors, whose shape is governed by the logarithm of a product of units.

Now specialize. The standard normalization of a McKay–Thompson series is
$T_g = q^{-1} + O(q)$: the constant term $a_g$ is *zero* for every conjugacy
class $g$. The two theorems then collapse beautifully. The full moonshine
product of all $194$ series begins

$$\frac{1}{q^{194}} \;+\; 0 \cdot \frac{1}{q^{193}} \;+\;
\Big(\sum_{g} c_g(1)\Big) \frac{1}{q^{192}} \;+\; \cdots,$$

where $c_g(1)$ is the linear coefficient of $T_g$ — the trace of $g$ on the
first graded piece of the moonshine module. The subleading coefficient vanishes
identically, and the next one is a pure character sum.

A small, checkable instance makes it concrete. Take just two series: the
$j$-function $J = q^{-1} + 196884q + \cdots$ (class $1A$) and the series for
class $2A$, $T_{2A} = q^{-1} + 4372q + \cdots$. Their product has a double pole,
its coefficient at $q^{-1}$ is $0$ (both constant terms vanish), and its
constant coefficient is

$$196884 + 4372 = 201256.$$

Two numbers from the character table of a group with $8 \times 10^{53}$
elements, added together by nothing more sophisticated than the rule for
multiplying two series. The dimension $196884 = 196883 + 1$ is the famous
observation that started moonshine; $4372 = 4371 + 1$ is its companion for the
class $2A$. Their sum falls out of the second coefficient of a product.

---

## Why bother proving the obvious?

Every step above is elementary. Orders add; $-1$ times $m$ is $-m$; distinct
integers are distinct. So why is any of this worth writing down?

Because *elementary* and *automatic* are different words, and in this subject
the difference costs people theorems.

The concrete payoff is the discipline it imposes on constructions. Moonshine is
full of operations that combine trace functions: Hecke-type operators, replicable
recursions, denominator formulas for the Monster Lie algebra, twisted products
across the conjugacy classes. Any such construction that involves multiplying
$m$ hauptmoduln must, on pain of contradiction, restore the pole order by hand —
and the theorems above say exactly how: multiply by $q^m$, uniquely, and what
remains is a unit. A construction that forgets the correction is not slightly
wrong; it is off by an integer that no clever choice of coefficients can repair.

There is also a warning buried in the setup, and it is a real one. Extending the
order function to the zero series by $+\infty$ is not a bookkeeping convenience;
it is essential. If instead one insists that order takes integer values and
assigns the zero series the order $0$ — a tempting convention, since it makes
"order" a total function to $\mathbb{Z}$ — then the statement "a product of $m$
normalized series has order $-m$" becomes *false* as soon as a family is allowed
to contain the zero series, and it becomes false silently, with no warning
anywhere in the algebra. The correct statement lives in $\mathbb{Z} \cup
\{+\infty\}$, where $\infty$ absorbs, and every integer-valued version has to
carry an explicit non-vanishing hypothesis. The choice of value group is part of
the theorem, not a preamble to it.

And finally: there is a real pleasure in watching a wall of arithmetic
complexity — $194$ infinite series, coefficients running into the hundreds of
millions, a group of order $808017424794512875886459904961710757005754368000000000$ —
be entirely governed by a homomorphism to $\mathbb{Z}$. The Monster is
unfathomable. The pole order of a product of its trace functions is not. It is
$194$, it is exactly $194$, and it will never be anything else.

That is the pole-order obstruction: the smallest possible piece of information —
one integer — placed exactly where it decides the largest possible question.
