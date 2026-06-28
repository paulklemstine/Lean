# The Function That Refused to Be Boring

## A surprise hiding in the geometry of lines

Mathematics has a quiet talent for surprises. You set up a tidy world, you list all the
objects you expect to find in it, you become convinced the list is complete — and then,
peering a little harder, you discover one more object that nobody invited. This is the story
of one such gate-crasher: a "Boolean degree-one function" on a space of lines that absolutely
should not exist according to the obvious catalog, yet provably does.

To get there we need to wander through projective geometry, the strange arithmetic of finite
fields, and an idea borrowed from the analysis of voting and influence. The destination is a
single clean statement: **for every odd prime power $q \ge 3$ and every dimension $n \ge 4$,
there is a "yes/no" function on the lines of a finite geometry that is as simple as possible
in a precise spectral sense — degree one — and yet is not one of the handful of obvious
examples.** It is genuinely new structure, and its existence has been pinned down exactly.

## Functions on lines

Start with a finite world of points and lines. Take a vector space over a finite field with
$q$ elements — think of $q$ as the number of "colours" available for coordinates — and look at
its two-dimensional subspaces. In the language of projective geometry these are the *lines* of
a projective space $\mathrm{PG}(n-1, q)$. The collection of all such lines, equipped with the
natural relations between them, is called the **Grassmann scheme** $J_q(n,2)$. It is the
$q$-analogue of the more familiar Johnson scheme of $k$-element subsets, and it is one of the
fundamental playgrounds of algebraic combinatorics.

Now put a function on this world. A **function on lines** assigns a real number $f(\ell)$ to
every line $\ell$. The functions we care about are the modest ones: those that only ever say
*yes* or *no*. We call a function **Boolean** when it takes only the values $0$ and $1$:

$$f(\ell) = 0 \quad \text{or} \quad f(\ell) = 1 \quad \text{for every line } \ell.$$

A Boolean function is just a *set* of lines in disguise — the set on which it answers $1$.

The simplest interesting Boolean functions are **point-pencils**. Fix a point $p$. The
function that answers $1$ on exactly the lines passing through $p$ is its indicator,

$$\mathbf{1}[p \le \ell] = \begin{cases} 1 & \text{if } p \text{ lies on } \ell,\\ 0 & \text{otherwise.}\end{cases}$$

This is the "star" of lines through a single point. Dually, fix a plane $h$ and take the set of
lines lying inside $h$; that is another natural Boolean function. Together with the two
constants ($f \equiv 0$ and $f \equiv 1$) and the *complements* of everything (swap every
$0$ and $1$), these form the obvious, hand-built examples.

## Degree one

Here is where a second idea enters, on loan from the analysis of Boolean functions in computer
science and probability — the world of influences, juntas, and Fourier expansions. Every
function on a nicely symmetric space can be decomposed by "frequency," and the lowest
frequencies are the simplest. A function is **degree one** when, apart from a constant
offset, it is built entirely out of the point-pencils:

$$f(\ell) = c + \sum_{p \in \ell} w(p),$$

for some constant $c$ and some weighting $w$ of the points. Concretely: assign each point a
real weight, and let a line's value be a baseline plus the total weight of the points it
carries. Nothing more elaborate than summing weights over a line is allowed. That is exactly
what "degree at most one" means here, and it is the lowest non-trivial rung of the spectral
ladder.

The objects at the heart of this story are the functions that are **both** Boolean **and**
degree one at the same time — call them **Boolean degree-one functions**. They must answer in
crisp yes/no fashion, *and* they must be expressible as a baseline plus a weighted point-count.
That is a severe double constraint, and it is natural to guess that only the obvious examples
survive it.

## The official boring list

So let us write down the obvious examples — the ones every expert would produce on demand.
A Boolean degree-one function on the lines is called **trivial** if it is one of:

- the constant $0$;
- the constant $1$;
- a point-pencil $\mathbf{1}[p \le \ell]$ (lines through a point);
- a plane line-set $\mathbf{1}[\ell \le h]$ (lines inside a plane);
- or the complement of any of these.

These really are Boolean degree-one functions — the constants trivially so, the point-pencils
by construction, and complements because the property survives the swap $f \mapsto 1 - f$.
The grand conjecture in this area, advanced by Yuval Filmus and Ferdinand Ihringer, says that
for $q \ge 3$ and $n \ge 4$ *these are the only ones*. Every Boolean degree-one function on
$J_q(n,2)$ should be on the boring list.

## Why you can't just add

The first instinct, when hunting for a new example, is to combine old ones. Why not add two
point-pencils? Take two distinct points $p \ne p'$ and form

$$\mathbf{1}[p \le \ell] + \mathbf{1}[p' \le \ell].$$

This is still degree one — it is a sum of point-pencils, which is exactly the shape degree-one
functions are allowed to have. But it is *not Boolean*. In any such geometry there is a unique
line through any two distinct points, and on that one shared line both indicators fire at
once, so the sum equals $2$. A function that ever says $2$ is not a yes/no function. This tiny
observation — that the sum of two distinct pencils breaks Booleanness on their common line — is
the seed of all the rigidity in the subject. It is why naive constructions fail and why people
came to believe the boring list might be everything.

And for the prime field $q = 2$, and in many other places, the conjecture *is* a theorem: there
truly is nothing new. The boring list is complete. So the surprise is all the more striking
when we find that, for odd $q \ge 3$, the list is **not** complete after all.

## The magic number

The gate-crasher comes from a classical geometric construction of Aiden Bruen and Keldon
Drudge from 1999, living in three-dimensional projective space $\mathrm{PG}(3,q)$ — the case
$n = 4$. Their object is a **Cameron–Liebler line class**: a set of lines obeying a strong
regularity condition that makes its indicator a Boolean degree-one function. Such a class
carries a single integer fingerprint, its **parameter** $x$, and the class always has exactly

$$x \cdot (q^2 + q + 1)$$

lines. The parameter is the whole story: the boring classes are precisely those with one of six
boring parameter values, namely

$$x \in \{\,0,\ 1,\ 2,\ q^2 - 1,\ q^2,\ q^2 + 1\,\}.$$

These correspond, in order, to the empty class, a point-pencil, a plane's worth of lines, and
the complements of those three. If a Cameron–Liebler class has any *other* parameter, its
indicator is a Boolean degree-one function that cannot be on the trivial list.

Bruen and Drudge built one with the audacious parameter

$$x = \frac{q^2 + 1}{2}.$$

Everything interesting flows from this single fraction. First, is it even a whole number? For
odd $q$, yes: $q^2$ is odd, so $q^2 + 1$ is even, and the division is exact. Spelled out as an
identity,

$$2 \cdot \frac{q^2+1}{2} = q^2 + 1,$$

which is the rigorous way of certifying that $x$ is a genuine integer and not a fraction in
disguise. (For *even* $q$ this fails — $q^2 + 1$ becomes odd — which is exactly why this
particular construction is an odd-$q$ phenomenon.)

## Its own mirror image

The number $x = (q^2+1)/2$ has a beautiful self-referential property. Complementing a
Cameron–Liebler class — swapping the lines it contains for the lines it omits — sends a class
of parameter $x$ to one of parameter $q^2 + 1 - x$. For the Bruen–Drudge value,

$$\frac{q^2+1}{2} = (q^2+1) - \frac{q^2+1}{2},$$

so the parameter is **its own mirror image**: the class and its complement carry the *same*
fingerprint. Equivalently, the class contains exactly half of all the lines in the space. This
self-complementary symmetry is not a curiosity; it is a powerful design constraint that
dramatically narrows where such an object can live, and it is the structural signature that
distinguishes the Bruen–Drudge example from everything on the boring list.

## Six boring values, and a number that dodges them all

To certify that the example is genuinely new, we must show its parameter avoids all six boring
values. Two simple bounds do the job. For $q \ge 3$ we have $q^2 \ge 9$, and so:

- $x = (q^2+1)/2$ is **greater than $2$** (since $q^2 + 1 \ge 10$, we get $x \ge 5$); this rules
  out $0$, $1$, and $2$.
- $x$ is **strictly less than $q^2 - 1$**; this rules out $q^2 - 1$, $q^2$, and $q^2 + 1$.

Putting the two bounds together, $2 < x < q^2 - 1$, so $x$ lands strictly between the small
boring values and the large ones and matches none of

$$\{\,0,\ 1,\ 2,\ q^2-1,\ q^2,\ q^2+1\,\}.$$

The Bruen–Drudge parameter therefore lies in the forbidden middle zone, exactly where no
trivial class can reach. Take the smallest case $q = 3$: then $x = (9+1)/2 = 5$, the boring set
is $\{0, 1, 2, 8, 9, 10\}$, and $5$ is comfortably outside it. The class has $5 \cdot 13 = 65$
lines out of a total of $130$ — precisely half, as self-complementarity demands.

## Putting it together

Now the pieces snap into place. There is a bridge — the **Filmus–Ihringer correspondence** —
between the geometric world and the functional world: Cameron–Liebler line classes of
$\mathrm{PG}(3,q)$ are *exactly* the Boolean degree-one functions on the lines $J_q(4,2)$, and
under this dictionary the *trivial* classes correspond precisely to the *trivial* Boolean
degree-one functions. So a class whose parameter dodges the six boring values must map to a
Boolean degree-one function off the boring list.

Feed the Bruen–Drudge class through this dictionary. Its indicator is, by the construction, a
Boolean degree-one function on $J_q(4,2)$. Its parameter is $(q^2+1)/2$, which we just showed is
not trivial. Therefore its image cannot be a constant, a point-pencil, a plane line-set, or any
of their complements. It is a *non-trivial* Boolean degree-one function — the very object the
naive analysis said should not exist.

The result is the cleanest possible refutation of "the boring list is everything": for odd
$q \ge 3$ there is always at least one more.

## Climbing to higher dimensions

The construction lives in three-dimensional space, the $n = 4$ case. But the surprise does not
stop there. A line of $\mathrm{PG}(3,q)$ is also a line of any larger $\mathrm{PG}(n-1,q)$ once
we embed the small space inside the big one. Embedding a three-dimensional subspace into an
$(n-1)$-dimensional one carries the Bruen–Drudge example along for the ride, producing a
non-trivial Boolean degree-one function on $J_q(n,2)$ for **every** $n \ge 4$. One construction,
infinitely many spaces.

## Why this matters

It is tempting to file this away as a technical footnote, but it speaks to something larger.
Across mathematics and computer science there is a recurring dream of *classification*: prove
that a class of simple objects consists of nothing but the obvious examples. When such a
theorem holds, it is enormously useful — it means structure equals simplicity, and any
low-complexity object can be recognized on sight. The analysis of low-degree Boolean functions
underpins parts of theoretical computer science, coding theory, and the study of error-resilient
computation, precisely because "degree one means trivial" is such a convenient hammer.

The Bruen–Drudge example is a warning and a guide. It shows that the convenient hammer has
exceptions, and it pins down *exactly* where: odd characteristic, the self-complementary
half-and-half regime, parameter $(q^2+1)/2$. Knowing the precise shape of the exception is what
lets the broader classification program proceed honestly — you cannot prove a clean theorem
until you know which "clean" statements are actually false.

There is also an aesthetic payoff. The whole argument rests on one number, $(q^2+1)/2$, and on
three almost childishly simple facts about it: it is a whole number, it equals its own
reflection $q^2 + 1 - x$, and it sits strictly between $2$ and $q^2 - 1$. From those three
arithmetic truths — integrality, self-complementarity, and a pair of inequalities — flows the
existence of an object that resisted the obvious classification. It is a reminder that the
deepest surprises in mathematics often turn on the simplest sums.

## The number to remember

If you take one thing away, let it be the fraction. In a finite projective space of odd order
$q \ge 3$, look at the lines; ask for a yes/no function that is spectrally as simple as
possible; expect only the boring stars and planes; and then notice the half-and-half class with
fingerprint

$$x = \frac{q^2 + 1}{2}.$$

It is whole, it is its own mirror, it dodges every boring value — and it is the function that
refused to be boring.
