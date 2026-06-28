# The Ring That Refuses to Hide: A Story of Punctured Spaces and Coprime Coordinates

## A hole you cannot see

Imagine a perfectly smooth, featureless plain. Now poke a single, infinitely thin
pinhole in it — a single missing point. From a distance the plain looks unchanged; the
hole has no width, no area, nothing you could trip over. The natural question a
geometer asks is disarmingly simple: *if you know everything about the plain except
that one missing point, do you actually know everything about the whole plain?*

For curves — one-dimensional worlds — the answer is subtle and depends on the geometry.
But for surfaces and higher-dimensional smooth spaces, something almost magical happens.
A single missing point is *too small to matter*. Any well-behaved structure defined on
the plain-minus-a-point automatically, and uniquely, fills in across the hole. The
information was never really lost; the hole could not hide it.

Mathematicians call results of this flavor **purity theorems**, and the phenomenon
**Hartogs extension**, after the complex analyst Friedrich Hartogs, who first noticed
that holomorphic functions in several variables cannot have isolated singularities the
way functions of one variable can. This article tells the story of a modern,
algebraic incarnation of that idea, and of the elementary arithmetic engine that drives
it — an engine you can run with nothing more than fractions and the greatest common
divisor.

## From geometry to arithmetic

The modern setting for "smooth spaces" in arithmetic geometry is the language of
**rings** and their **spectra**. A commutative ring $R$ has a geometric shadow,
$\mathrm{Spec}(R)$, whose points are the prime ideals of $R$. When $R$ is a *regular
local ring* of dimension $d$, its spectrum behaves like a smooth $d$-dimensional space
with one distinguished "center" — the closed point corresponding to the maximal ideal
$\mathfrak{m}$. Deleting that center gives the **punctured spectrum**,
$\mathrm{Spec}(R)\setminus\{\mathfrak{m}\}$, the algebraic version of a plain with a
pinhole.

The structures we want to extend across the puncture are called, in the most refined
contemporary framework, **prismatic $F$-crystals**. Do not let the name intimidate you.
Stripped to its linear-algebraic skeleton, a prismatic $F$-crystal over a base $(R,
\varphi)$ — where $\varphi\colon R\to R$ is a ring map standing in for a *Frobenius*, the
arithmetic analogue of "raising to the $p$-th power" — is just two pieces of data:

- a module $M$ over $R$ (think: a bundle of vector spaces sitting over the space), and
- a map $F\colon M\to M$ that is *$\varphi$-semilinear*: it is additive, and it scales
  according to the twisted rule $F(r\cdot v)=\varphi(r)\cdot F(v)$.

That semilinear $F$ is the "Frobenius structure," the fingerprint that makes these
objects so powerful in number theory. In the formal development behind this article, this
package is recorded faithfully as a structure called `FMod`: a module $M$ together with a
semilinear endomorphism $F$. A **morphism** of these objects — recorded as `FHom` — is an
$R$-linear map between the underlying modules that *commutes with the two Frobenii*. With
identity morphisms and composition (and the associativity law one expects), these objects
and maps form a genuine category, the home of all our characters.

The headline question is the purity question, transplanted:

> **Is a prismatic $F$-crystal on the punctured spectrum the same thing as one on the
> whole spectrum?**

If yes, then crystals — and in particular the canonical objects predicted by deep
conjectures in the field, such as Ogus's conjectural $F$-isocrystal — are *rigid*: they
are completely pinned down by their behavior on any dense open piece, with nothing
hiding at the center.

## Splitting the problem in two

Whenever you want to prove two categories are "the same" via a restriction functor, the
task splits cleanly into two independent jobs:

1. **Faithfulness.** Different maps must *stay* different after restricting. No
   collapse, no information lost about morphisms.
2. **Fullness and essential surjectivity.** Every map and every object that lives on the
   punctured spectrum must actually *come from* one on the whole space. Nothing extra
   appears at the boundary, and nothing fails to extend.

The first job turns out to be the easy half, and it is genuinely proved here in a clean,
general form. The statement, recorded as `restriction_faithful`, says: *if the
restriction map on the target crystal is injective on underlying modules, then two
morphisms whose restrictions agree must themselves be equal.* The proof is a single line
of honest algebra — apply the injective restriction to the equal restricted values — and
crucially it needs **no** deep geometry, only the injectivity that a regular (hence
torsion-free) ring automatically supplies. We even pin it down concretely over the
integers: the trivial $\mathbb{Z}$-crystal restricted to its generic point $\mathrm{Spec}\,
\mathbb{Q}$ has an injective restriction map (`rhoZQ_injective`), so a morphism is
completely determined by what it does over $\mathbb{Q}$ (`trivZ_faithful`).

The second job is where all the difficulty concentrates. To *extend* a crystal across the
puncture, you need a genuine **Hartogs theorem**. And here is the punchline of the whole
project: once you have faithfulness, the entire purity statement reduces to the existence
of compatible extensions. This is captured precisely by `purityHomEquiv`, which takes
faithfulness plus an *extension operator* — a recipe that turns a morphism on the
punctured spectrum into one on the whole space, reconstructing it on restriction — and
upgrades the restriction map into a perfect bijection between morphism-sets. In one clean
formal stroke, **purity becomes equivalent to extension.**

## The trap of circular reasoning

Here the story takes the dramatic turn that gives it its name. An earlier attempt at this
extension input did something embarrassingly common in hard mathematics: it justified the
"extension across the puncture" by quietly invoking *purity itself*. The argument went in
a circle. It assumed what it was trying to prove.

The breakthrough was to ask: *what is the extension input, really, when you strip away the
machinery?* And the answer is beautifully down-to-earth. In the regular case — and a
regular local ring is, by the celebrated **Auslander–Buchsbaum theorem**, a *unique
factorization domain* (UFD), a ring where every element factors into primes in
essentially one way — the deep "extension across the puncture" collapses into an utterly
elementary fact about coprime numbers.

## The coprime-coordinates engine

Here is the heart of the matter, and you can follow every step with ordinary fractions.

Take a UFD $R$ — for concreteness, the integers $\mathbb{Z}$ — sitting inside its field
of fractions $K$ — for $\mathbb{Z}$, the rationals $\mathbb{Q}$. Pick two **coprime**
coordinates $x$ and $y$ in $R$: elements with no common factor. Geometrically, $x$ and
$y$ cut out two different "walls," and removing both walls from the space leaves exactly
the punctured spectrum. The two regions where you are allowed to divide by $x$, and where
you are allowed to divide by $y$, together cover everything except the center.

We say an element $f\in K$ is **$x$-integral** if some power of $x$ clears its
denominator — that is, $x^n\cdot f$ lands back in $R$ for some exponent $n$. This is the
algebraic way of saying "$f$ is a legitimate section over the chart where dividing by $x$
is allowed." The formal predicate is named `IsXIntegral`, and every honest global
section is trivially $x$-integral (take $n=0$), as recorded in `isXIntegral_of_mem_range`.

Now suppose $f$ is *both* $x$-integral and $y$-integral. It is a well-defined section on
each of the two charts, hence a section on their union — the entire punctured spectrum.
Hartogs purity demands that $f$ must already be a global section: $f\in R$.

And it is — by a one-paragraph argument that any student can verify. This is the central
theorem `hartogs_UFD`:

> **Theorem (Hartogs over a UFD).** Let $R$ be a unique factorization domain with
> fraction field $K$. Let $x\neq 0$ be coprime to $y$, and let $f\in K$ be both
> $x$-integral and $y$-integral. Then $f\in R$.

Watch the gears turn. Because $f$ is $x$-integral, $x^a\cdot f=\alpha$ for some
$\alpha\in R$. Because $f$ is $y$-integral, $y^b\cdot f=\beta$ for some $\beta\in R$.
Cross-multiplying eliminates $f$:
$$ y^b\cdot\alpha \;=\; x^a\cdot\beta \qquad\text{(an identity in } R\text{)}. $$
Now coprimality does its work. Since $x$ and $y$ share no factor, neither do their powers
$x^a$ and $y^b$. Yet $x^a$ divides the right-hand side $x^a\cdot\beta$, so it must divide
the left-hand side $y^b\cdot\alpha$ — and since it is coprime to $y^b$, it must divide
$\alpha$ outright. Write $\alpha=x^a\cdot\gamma$. Substituting back,
$x^a\cdot f=x^a\cdot\gamma$, and cancelling the nonzero factor $x^a$ gives
$$ f=\gamma\in R. $$
The section had nowhere to hide. The pinhole could not conceal it.

In the formal language, this exact reasoning is recorded: the cross-multiplication
identity, the divisibility forced by `IsRelPrime.pow`, the cancellation by
`mul_left_cancel₀` over the field. No purity is invoked anywhere — the circle is broken.

## The two charts meet exactly in the ring

There is an elegant way to repackage the theorem. Each coordinate gives a subalgebra of
$K$: the collection of all $x$-integral elements forms $R[1/x]$, the ring where you have
adjoined an inverse of $x$, and likewise $R[1/y]$. The Hartogs theorem says their
intersection inside $K$ is nothing more than $R$ itself. In the formal development this
subalgebra is `xIntegralSubalg`, and the clean statement
$$ R[1/x]\;\cap\;R[1/y]\;=\;R $$
appears as `equalizer_inf` — the two localizations *equalize* exactly on the global ring.
This is the algebraic fingerprint of "two charts covering the punctured spectrum glue back
to a global section."

To prove the abstract statement is never vacuous, it is anchored on a concrete and rather
charming example. Where do you find a reliable supply of coprime pairs? The **Fibonacci
numbers** $1,1,2,3,5,8,13,21,\dots$, where each term is the sum of the previous two. A
classical fact is that *consecutive Fibonacci numbers are always coprime*. Feeding
consecutive Fibonacci numbers $F_n, F_{n+1}$ in as the coprime pair $x,y$ turns the
abstract equalizer into a fully concrete instance over $\mathbb{Z}\subseteq\mathbb{Q}$,
recorded as `fibonacci_inter_eq_bot`. The deepest extension theorem in the project rests,
at the end of the day, on the humblest sequence in mathematics.

## The dimension-one shadow

There is also a complementary, lower-dimensional version of the same phenomenon, and it
is proved completely and unconditionally. In dimension one, "regular" means the ring is a
discrete valuation ring, which is **integrally closed** (or *normal*): an element of the
fraction field that satisfies a monic polynomial over the ring already lies in the ring.
This is the `hartogs_dim_one` theorem:

> **Theorem (Hartogs in dimension one).** Over an integrally closed domain $R$ with
> fraction field $K$, every $x\in K$ that is integral over $R$ lies in the image of
> $R\to K$ — and uniquely so.

Over the integers this is the down-to-earth statement that *an algebraic integer which
happens to be rational is an ordinary integer* (`hartogs_Z`): if a fraction is a root of
a monic polynomial like $t^2-5t+6=(t-2)(t-3)$, it cannot be something like $\tfrac12$; it
must be a whole number. The same statement holds for polynomials inside rational
functions (`hartogs_polyQ`): a rational function integral over the polynomial ring is
itself a polynomial. Uniqueness in every case is just the injectivity of $R\hookrightarrow
K$ (`extension_unique`).

This dimension-one result also reveals exactly *why* the hypotheses cannot be dropped.
Normality is essential. For the non-maximal order $\mathbb{Z}[2i]\subset\mathbb{Z}[i]
\subset\mathbb{Q}(i)$, the element $i$ is integral (it is a root of $t^2+1$) but does not
lie in $\mathbb{Z}[2i]$. Strip away normality and the extension fails outright — the hole
*can* hide something. Purity is a privilege of smoothness.

## Why this matters

The chain of reasoning here is a small masterpiece of mathematical economy. A question
about the rigidity of exotic objects from $p$-adic Hodge theory — prismatic $F$-crystals,
the kind of structure that encodes the arithmetic of varieties over $p$-adic fields — is
peeled apart into two layers. The first layer, faithfulness, is dispatched with pure
injectivity. The second layer, extension, is shown to be *equivalent* to the whole purity
statement, and is then traced down through the Auslander–Buchsbaum theorem until it rests
on a fact about coprime integers that you could explain to a curious teenager: *if you can
divide a fraction's denominator into one wall and into a coprime second wall, the
denominator was never really there.*

This is the recurring lesson of purity theorems across mathematics, from Hartogs's
complex analysis to Grothendieck's algebraic geometry: **codimension two is invisible.**
A locus too thin to separate the space cannot carry independent information. Whatever lives
around it already lives on it. The deepest version of this idea, for the most modern
objects in arithmetic geometry, turns out to run on the oldest arithmetic of all — the
arithmetic of numbers with no common factor.

And if you ever forget where to find a coprime pair to test it on, just remember:
$1, 1, 2, 3, 5, 8, 13, 21, \dots$. The rabbits have you covered.
