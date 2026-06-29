# The Sign Hidden in a Mirror: Periods, Discriminants, and the Geometry of GL(n)

## A number that refuses to disappear

Some of the most stubborn facts in mathematics are *signs*. Not the magnitudes, not
the elaborate formulas, but the lone $\pm 1$ that survives every simplification and
quietly decides whether two quantities are equal or opposite. The story told here is
about one such sign — a single $\pm 1$ that governs how a deep arithmetic object
behaves when you look at it in a mirror.

The arithmetic objects are called *automorphic representations*, and they sit at the
center of the Langlands program, the sprawling web of conjectures that connects
number theory, geometry, and harmonic analysis. To each such representation $\pi$ of
the group $\mathrm{GL}(n)$ — the group of invertible $n \times n$ matrices — one can
attach a precise numerical invariant called a **period**. Periods are the bridge
between the analytic world of integrals and the algebraic world of rational numbers.
They are notoriously hard to compute, and even harder to compare.

Every representation $\pi$ has a *mirror image*, its **contragredient**
$\pi^{\vee}$ — informally, the representation built from the inverse-transpose of
matrices. A natural and very old question asks: **how does the period of $\pi$ relate
to the period of its mirror image $\pi^{\vee}$?**

The answer, it turns out, is breathtakingly clean. The two periods differ by exactly
one sign, and that sign is determined by a single arithmetic datum: the
**discriminant of the number field** you are working over, raised to a power equal to
the dimension of a certain geometric space. In symbols, the relation is
$$P^{b}(\pi^{\vee}) = \varepsilon\big(\mathrm{disc}(k)\big)^{\,b} \cdot P^{b}(\pi),$$
and the rest of this article is devoted to unpacking every piece of it.

## The cast of characters

Let us assemble the players slowly.

**The number field $k$.** A number field is a finite extension of the rational
numbers $\mathbb{Q}$ — think of $\mathbb{Q}(\sqrt{2})$ or $\mathbb{Q}(i)$. Every
number field comes with a list of *places*, the different ways of measuring the size
of its elements. Some places are *real* (they embed $k$ into the real numbers
$\mathbb{R}$); others are *complex* (they embed $k$ into $\mathbb{C}$ and come in
conjugate pairs). We write $r_1$ for the number of real places and $r_2$ for the
number of complex places. For $\mathbb{Q}$ itself, $r_1 = 1$ and $r_2 = 0$. For
$\mathbb{Q}(i)$, $r_1 = 0$ and $r_2 = 1$.

**The discriminant $\mathrm{disc}(k)$.** Every number field carries an integer
invariant, its discriminant, that measures how the field is "twisted." Its sign
matters enormously: a classical theorem of Brill says the sign of $\mathrm{disc}(k)$
equals $(-1)^{r_2}$, where $r_2$ counts the complex places. So the parity of $r_2$ is
literally written into the sign of the discriminant — a fact we will exploit.

**The bottom degree $b$.** Representations of $\mathrm{GL}(n)$ live on a geometric
stage called a *locally symmetric space*. Its cohomology — a way of counting holes of
various dimensions — is nonzero only in a band of degrees, and the lowest degree
where interesting classes appear is called the **bottom degree**. For $\mathrm{GL}(n)$
over a field with $r_1$ real and $r_2$ complex places, this number has a beautiful
closed form:
$$b \;=\; r_1 \cdot \left\lfloor \frac{n^2}{4} \right\rfloor \;+\; r_2 \cdot \binom{n}{2}.$$
The real places contribute the *quarter-square* $\lfloor n^2/4 \rfloor$, an integer
sequence $0, 0, 1, 2, 4, 6, 9, 12, \dots$ that appears all over combinatorics. The
complex places contribute the triangular number $\binom{n}{2} = \tfrac{n(n-1)}{2}$.
This $b$ is the exponent in our central formula.

**The component group $\pi_0(k_\infty^{\times})$.** Bundle together all the
archimedean (real and complex) completions of $k$ into one big group
$k_\infty^{\times} \cong (\mathbb{R}^{\times})^{r_1} \times (\mathbb{C}^{\times})^{r_2}$.
Now ask: how many *connected pieces* does this group have? The nonzero reals
$\mathbb{R}^{\times}$ split into two pieces (positive and negative), while the nonzero
complex numbers $\mathbb{C}^{\times}$ form a single connected blob. So the group of
connected components is
$$\pi_0(k_\infty^{\times}) \;\cong\; (\mathbb{Z}/2)^{r_1}.$$
This little group of "signs at the real places" is where all the action happens.

**The discriminant class.** Through the determinant map, the discriminant of $k$
defines a distinguished element of $\pi_0(k_\infty^{\times})$, which we call the
**discriminant class**. Its coordinate at every real place is the sign $(-1)^{r_2}$ —
exactly the sign of the discriminant we met earlier. It is a single, canonical point
of $(\mathbb{Z}/2)^{r_1}$.

**The quadratic character $\varepsilon$.** Finally, $\varepsilon$ is a
*character* — a multiplicative function $\varepsilon : \pi_0(k_\infty^{\times}) \to
\mathbb{C}^{\times}$ — that is **quadratic**, meaning every one of its values squares
to $1$. So $\varepsilon$ only ever outputs $+1$ or $-1$. This $\varepsilon$ encodes
the choice of rational structure that makes periods well defined.

## The relation, in plain words

Now reread the formula:
$$P^{b}(\pi^{\vee}) = \varepsilon\big(\mathrm{disc}(k)\big)^{\,b} \cdot P^{b}(\pi).$$

The period of the mirror representation $\pi^{\vee}$ equals the period of $\pi$
itself, multiplied by a single sign $\varepsilon(\mathrm{disc}(k))$ raised to the
power $b$. Because $\varepsilon$ is quadratic, $\varepsilon(\mathrm{disc}(k))$ is
either $+1$ or $-1$. Therefore the whole twist $\varepsilon(\mathrm{disc}(k))^{b}$ is:

- always $+1$ if $\varepsilon(\mathrm{disc}(k)) = +1$ (the "self-dual" case), or
- equal to $(-1)^b$ if $\varepsilon(\mathrm{disc}(k)) = -1$,

so it depends only on the **parity of the bottom degree $b$**. The deep analytic
machinery of automorphic periods collapses, in the end, to a question about whether a
single integer is even or odd.

This is the kind of result that makes number theorists smile: an ocean of analysis
distilled into one sign.

## Three pillars of the proof

What makes the relation *true*? Strip away the analytic scaffolding and exactly three
structural facts remain — three pillars, each simple on its own, that together hold up
the whole bridge.

**Pillar 1: the mirror is an involution.** Taking the contragredient twice returns
you to where you started: $(\pi^{\vee})^{\vee} = \pi$. A mirror of a mirror is the
original. This forces the twist factor to be *consistent*: applying the relation
twice multiplies the period by $\varepsilon(\mathrm{disc}(k))^{2b}$, and since this
must equal $1$ (we have come full circle), the twist has to square away to nothing.

**Pillar 2: the character is quadratic.** Because every value of $\varepsilon$
satisfies $\varepsilon(x)^2 = 1$, *any even power* of $\varepsilon$ is automatically
trivial: $\varepsilon(x)^{2m} = (\varepsilon(x)^2)^m = 1^m = 1$. This is the algebraic
engine that lets the double-mirror twist $\varepsilon(\mathrm{disc}(k))^{2b}$ vanish
cleanly. Quadraticity is not a convenience; it is precisely what makes Pillar 1
consistent.

**Pillar 3: the bottom degree controls the exponent.** The number $b$ is not arbitrary
— it is the genuine bottom cohomological degree, with the closed form
$b = r_1 \lfloor n^2/4 \rfloor + r_2 \binom{n}{2}$. Two facts about $b$ do the
heavy lifting. First, the quarter-square identity
$$\left\lfloor \frac{n^2}{4} \right\rfloor = \left\lfloor \frac{n}{2} \right\rfloor \cdot \left\lfloor \frac{n+1}{2} \right\rfloor,$$
which rewrites the floor as a clean product. Second, the elementary observation that
$n(n-1)$ is always even, so the triangular term $\tfrac{n(n-1)}{2}$ is a genuine
integer. With these, $b$ is a well-defined natural number whose parity we can compute,
and $2b$ is visibly even — exactly the cancellation Pillars 1 and 2 demand.

Put together: the mirror is involutive (Pillar 1), so the twist must square to one;
the character is quadratic (Pillar 2), so even powers of it *do* square to one; and
the exponent is the honest bottom degree (Pillar 3), an integer whose double is even.
The three facts interlock so tightly that the period relation becomes not a miracle
but an inevitability.

## A worked example: the rational numbers

Take the simplest field of all, $k = \mathbb{Q}$. Here $r_1 = 1$ (one real place) and
$r_2 = 0$ (no complex places), and the discriminant is $1$ — positive, consistent with
$(-1)^{r_2} = (-1)^0 = +1$. The component group is
$\pi_0(\mathbb{R}^{\times}) \cong \mathbb{Z}/2$, just the two signs.

The bottom degree for $\mathrm{GL}(n)$ over $\mathbb{Q}$ is simply the quarter-square:
$$b = \left\lfloor \frac{n^2}{4}\right\rfloor = 0, 0, 1, 2, 4, 6, 9, 12, 16, 20, \dots
\quad (n = 1, 2, 3, \dots).$$
For $\mathrm{GL}(2)$, $b = 1$; for $\mathrm{GL}(3)$, $b = 2$; for $\mathrm{GL}(4)$,
$b = 4$. Because the discriminant of $\mathbb{Q}$ has positive sign, the discriminant
class is trivial and $\varepsilon(\mathrm{disc}(\mathbb{Q})) = +1$ for *every* quadratic
character. The twist is therefore always $+1^b = +1$, and the period relation reads
$$P^{b}(\pi^{\vee}) = P^{b}(\pi).$$
Over the rationals, a representation and its mirror have **exactly equal** periods. No
sign at all. The arithmetic of $\mathbb{Q}$ is too tame to produce a discrepancy.

## A worked example: an imaginary quadratic field

Now turn up the temperature. Take $k = \mathbb{Q}(i)$, the Gaussian field. Here
$r_1 = 0$ and $r_2 = 1$, with discriminant $-4$ — negative, consistent with
$(-1)^{r_2} = (-1)^1 = -1$. The bottom degree is the triangular number:
$$b = \binom{n}{2} = 0, 1, 3, 6, 10, 15, \dots \quad (n = 1, 2, 3, \dots).$$
But here something subtle happens. Because $r_1 = 0$, the component group
$\pi_0(k_\infty^{\times}) \cong (\mathbb{Z}/2)^0$ is *trivial* — a single point. There
are no real places to carry a sign. The discriminant class collapses to the identity,
and once again $\varepsilon(\mathrm{disc}(k)) = +1$, so the periods coincide.

The interesting case — where the twist can genuinely be $-1$ — requires a field with
**at least one real place** whose discriminant has negative sign, and a character
$\varepsilon$ that is nontrivial on the corresponding $\mathbb{Z}/2$ factor. Then
$\varepsilon(\mathrm{disc}(k)) = -1$, and the period relation becomes the parity
dichotomy
$$P^{b}(\pi^{\vee}) = (-1)^{b}\, P^{b}(\pi),$$
so the mirror agrees with the original exactly when $b$ is even, and *flips sign* when
$b$ is odd. Whether two periods are equal or opposite is decided by whether a single
quarter-square-plus-triangular-number is even or odd.

## Why the floor function is the secret hero

It is worth pausing on the humble function $\lfloor n^2/4 \rfloor$. At first glance it
looks like an awkward bit of bookkeeping. But it hides a perfect symmetry. Split into
cases:

- If $n = 2m$ is even, then $\lfloor n^2/4 \rfloor = m^2$.
- If $n = 2m+1$ is odd, then $\lfloor n^2/4 \rfloor = m(m+1)$.

The product form $\lfloor n/2 \rfloor \cdot \lfloor (n+1)/2 \rfloor$ unifies both. And
notice the parity story: $m(m+1)$ is the product of consecutive integers, hence
**always even**, so for odd $n$ the real contribution is even. Only even $n$ can
contribute an odd quarter-square (when $m$ itself is odd, i.e. $n \equiv 2 \pmod 4$).
This is why, over a field like $\mathbb{Q}$, the period sign flips precisely for the
groups $\mathrm{GL}(n)$ with $n \equiv 2 \pmod 4$ — a clean arithmetic progression
emerging from a floor function.

## The bigger picture

This period relation is one tile in an enormous mosaic. The contragredient
$\pi \mapsto \pi^{\vee}$ is a symmetry of the entire automorphic world, and periods
are the most refined invariants we know how to attach. Understanding how periods
transform under this symmetry feeds directly into the study of *L-functions* — the
generating functions whose special values encode the deepest arithmetic of a
representation. Functional equations of $L$-functions relate the value at $s$ to the
value at $1 - s$, and the contragredient sits at the heart of that reflection. The
discriminant twist we have described is exactly the kind of correction term that
appears when one tracks rational structures across that functional equation.

What is remarkable is how *robust* the relation is. It does not care about the fine
internal structure of $\pi$; it does not require the representation to be regular or
generic in any restrictive sense; it asks only for the three structural pillars —
an involutive mirror, a quadratic character, and an honest bottom degree. Strip a
theorem down to its load-bearing walls and you often find it standing on surprisingly
few. Here, three suffice.

## Coda

We began with a sign that refuses to disappear, and we end with an exact formula for
it. The period of a representation $\pi$ of $\mathrm{GL}(n)$ over a number field $k$,
and the period of its mirror image $\pi^{\vee}$, differ by
$\varepsilon(\mathrm{disc}(k))^{b}$ — a discriminant sign raised to the bottom degree.
When the field is too tame to register a sign, the periods are equal. When it is
wild enough, they differ by $(-1)^b$, and a single parity computation tells you which.

It is a small theorem with a large reach: analysis collapsing to algebra, algebra
collapsing to a sign, and the sign collapsing to whether one integer is even or odd.
That is the quiet beauty of arithmetic — that something as grand as the Langlands
program should, in this corner, come down to counting by twos.
