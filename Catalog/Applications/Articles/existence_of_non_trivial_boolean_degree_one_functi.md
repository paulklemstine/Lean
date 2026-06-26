# Lines, Pencils, and the Hidden Arithmetic of Geometry

## A function that can only see one dimension at a time

Imagine you are handed an enormous catalogue of all the *lines* in a geometric
world. Not lines on a sheet of paper, but lines inside a higher-dimensional
space built over a finite arithmetic — a space where there are only $q$ numbers
to count with instead of infinitely many. Your job is to invent a rule that
labels each line either **YES** (1) or **NO** (0). A simple sorting rule.

There are astronomically many ways to sort lines into yes and no. But suppose
someone adds a constraint that sounds innocent and turns out to be ferociously
restrictive: your YES/NO rule must be **"degree one."** Loosely, it must be
*smooth* with respect to the geometry — it can't wiggle wildly from line to line.
It has to be expressible as a simple accumulation of local contributions, one per
point, with nothing more elaborate allowed.

The astonishing fact, conjectured and largely proven by mathematicians studying
these *Grassmann schemes*, is that this single smoothness constraint nearly
annihilates your freedom. Once $q \ge 3$ and the ambient space has dimension at
least $4$, **the only YES/NO smooth rules that exist are the obvious ones**: say
yes to everything, say no to everything, or say yes exactly to the lines passing
through one chosen point — plus the mirror images of these. There is essentially
nothing creative left to do. The geometry is *rigid*.

This article is about that rigidity, about the one exceptional case ($q = 2$,
the famous **Fano plane**) where the rigidity cracks and exotic rules sneak in,
and about a clean, elementary skeleton that captures why the whole phenomenon
happens. We will build that skeleton from scratch, and along the way we will meet
*point-pencils*, the surprising power of every line having the same length, and a
small, beautiful obstruction that explains why you cannot simply glue two valid
rules together to make a new one.

## The world of lines over a finite field

Start with $\mathbb{F}_q$, the field of $q$ elements — think of it as clock
arithmetic where $q$ is prime: the numbers $0, 1, \dots, q-1$ with addition and
multiplication wrapping around. Now build an $n$-dimensional vector space
$\mathbb{F}_q^n$ over it. The **2-dimensional subspaces** of this space are what
geometers call the *lines* of the projective geometry $\mathrm{PG}(n-1, q)$.

The collection of all these lines, with a natural notion of "closeness" between
them, is the **Grassmann scheme** $J_q(n,2)$ — the $q$-analogue of the classical
Johnson scheme. It is one of the central objects of algebraic combinatorics: a
highly symmetric structure whose spectral theory (its eigenvalues and
eigenspaces) encodes deep geometric truths.

For our story we strip this down to its combinatorial bones, and what remains is
a structure every schoolchild half-knows: a **linear space** of points and lines
where

- every line contains exactly $q + 1$ points, and
- any two distinct points lie on exactly one common line.

That second axiom — *two points determine a unique line* — is Euclid's, reborn in
a finite world. The first — *every line has the same length $q+1$* — is the
combinatorial fingerprint of the underlying field, and, as we will see, it does
an enormous amount of work.

## Degree one, made elementary

Here is where the analytic notion of "smooth" becomes something you can compute
on your fingers. A real-valued function $f$ on the lines is **degree $\le 1$** if
there is a single constant $c$ and a **weight** $w(p)$ attached to each point $p$
such that the value on any line $\ell$ is simply the constant plus the sum of the
weights of the points lying on that line:

$$f(\ell) \;=\; c \;+\; \sum_{p \in \ell} w(p).$$

That is the entire definition. No products, no higher interactions — just a
baseline plus a tally of point-contributions. In the language of the scheme this
is exactly the top of the spectrum, the eigenspace $V_0 \oplus V_1$; but rendered
this way it is pure bookkeeping.

The function $f$ is **Boolean** if it only ever outputs $0$ or $1$:

$$f(\ell) = 0 \quad\text{or}\quad f(\ell) = 1 \qquad \text{for every line } \ell.$$

A **Boolean degree one function** is one that is both: a genuine YES/NO labelling
that also admits the smooth, additive description above. These are the objects
whose entire population we want to count and classify.

## The cast of "trivial" solutions

Some Boolean degree one functions are obvious. Let us name them, because the
deep theorem says these are *all* of them.

**The constants.** Always say $0$, or always say $1$. Take $w(p) = 0$ for every
point and $c = 0$ (or $c = 1$). The tally is empty, the baseline carries the day.

**The point-pencils.** Fix one point $p$. The **pencil** of $p$ is the set of all
lines passing through $p$ — the "star" of lines radiating from that point. Its
indicator function,

$$\mathbf{1}[p \in \ell] = \begin{cases} 1 & \text{if } p \text{ lies on } \ell, \\ 0 & \text{otherwise,} \end{cases}$$

is Boolean, and it is degree one: take $c = 0$ and the weight that is $1$ at $p$
and $0$ everywhere else. Then $\sum_{q \in \ell} w(q)$ counts how many times $p$
appears among the points of $\ell$, which is $1$ if $p \in \ell$ and $0$ if not.
Exactly the indicator. These pencils are the prototypical non-constant solutions.

**The complements.** If $f$ is a Boolean degree one function, so is $1 - f$. The
value flips $0 \leftrightarrow 1$ (still Boolean), and the smooth description
flips too: replace $c$ by $1 - c$ and every weight $w(p)$ by $-w(p)$. So every
solution comes with its mirror image for free.

(There is also a dual family — the "hyperplane" families $\mathbf{1}[\ell \subseteq H]$
of lines lying inside a fixed hyperplane — which by a point/hyperplane duality
behave just like pencils. We focus on the pencils; the duals are their reflection.)

## How many solutions must there be?

Even before classifying everything, we can *count from below*. Suppose our linear
space is rich enough to tell points apart — formally:

- every point lies on **some** line,
- every point is **avoided** by some line, and
- any two distinct points can be **separated**: there is a line through one but
  not the other.

These are mild richness conditions, true in any honest projective geometry. Under
them, the pencils of distinct points are genuinely different functions. The
reason is delightfully direct: if points $p$ and $p'$ differ, pick a separating
line $\ell$ — one through $p$ but not $p'$. Then the pencil of $p$ outputs $1$ on
$\ell$ while the pencil of $p'$ outputs $0$. The functions disagree somewhere, so
they are distinct. (Formally, this is the injectivity of the map sending a point
to its pencil.)

Counting them up: the two constants plus one pencil per point gives at least

$$|P| + 2$$

distinct Boolean degree one functions, where $|P|$ is the number of points. They
are packaged as an *injection* from "points-plus-two-bits" into the space of
functions, every one of whose images is verified to be Boolean degree one. So the
trivial solutions are abundant — there are at least $|P| + 2$ of them — and the
rigidity theorem says, for $q \ge 3$, that (together with the dual hyperplane
families and complements) they are the *whole story*.

## Why symmetry forces constancy

Now comes the first piece of real magic, and it leans entirely on every line
having the same length $q+1$.

Suppose your weight is **symmetric** — it does not single out any point, assigning
the *same* value $a$ to every point. Then on a line $\ell$ the tally is just $a$
added to itself once per point on the line:

$$f(\ell) = c + \sum_{p \in \ell} a = c + (q+1)\,a.$$

But $q+1$ is the same number for *every* line. So $f$ takes the identical value
$c + (q+1)a$ on every single line — it is **constant**. There is no room for a
non-trivial symmetric solution. This is the clean, abstract reason the only
*symmetric* (automorphism-invariant) Boolean degree one functions are the boring
constants. The uniform line size — the regularity of the scheme — is doing all
the work. In our framework this is the theorem `const_weight_is_constant`.

## The obstruction: why you can't just add two pencils

The most tempting way to manufacture a *new* solution is to combine old ones.
Take two distinct points $p$ and $p'$ and add their pencils:

$$g(\ell) = \mathbf{1}[p \in \ell] + \mathbf{1}[p' \in \ell].$$

This is still degree one — sums of degree one functions are degree one; the
weights just add. So smoothness survives. But is $g$ Boolean? Watch what happens
on the unique line $\ell^\*$ joining $p$ and $p'$ (the second axiom guarantees it
exists). That line passes through *both* points, so

$$g(\ell^\*) = 1 + 1 = 2.$$

The value $2$ is neither $0$ nor $1$. The function has burst out of the Boolean
range. The very axiom that makes the geometry coherent — two points lie on a
common line — is what sabotages the naive gluing: that shared line is forced to
register a $2$. This little fact (the theorem `two_pencils_not_boolean`) is the
seed of the whole rigidity phenomenon: you cannot cheaply combine trivial
solutions to escape triviality, because the geometry keeps colliding your
contributions on shared lines.

## The exceptional plane: $q = 2$ and Fano

Every good rigidity theorem has its rebel, and here the rebel is $q = 2$. The
smallest projective plane, $\mathrm{PG}(2,2)$, is the celebrated **Fano plane**:
$7$ points, $7$ lines, every line holding exactly $3$ points, every point on
exactly $3$ lines. It is the most symmetric tiny geometry in existence, drawn as
a triangle with its medians and inscribed circle, and it is $J_2(3,2)$ in our
notation.

When $q = 2$, the arithmetic over the field with two elements is special — adding
is the same as subtracting, and $1 + 1 = 0$. This collapse breaks the obstruction
above just enough that **non-trivial** Boolean degree one functions appear, rules
that are not constants, not pencils, not hyperplane families, and not complements
of any of these. The boundary between $q = 2$ and $q \ge 3$ is precisely the
fault line the main theorem traces. Studying the Fano plane concretely is how one
sees the exception in the flesh, and it is what makes the $q \ge 3$ rigidity
remarkable rather than automatic.

## Why anyone should care

This may sound like a private game played by combinatorialists, but the structure
echoes loudly elsewhere.

**The analysis of Boolean functions.** In theoretical computer science, "low
degree" Boolean functions on the hypercube (think: voting rules, decision
procedures, error-correcting codes) are famously constrained — the
Friedgut–Kalai–Naor theorem and its descendants say low-degree Boolean functions
must be *juntas*, depending on only a few coordinates. The Grassmann story is the
same melody transposed into the world of subspaces: degree one plus Boolean
equals "essentially a single point's pencil." The point-pencils are the
geometric juntas.

**Coding theory and design theory.** Pencils and hyperplane families are exactly
the kinds of structured subsets that build optimal codes and combinatorial
designs over finite fields. Knowing that *no other* small-degree Boolean
structures exist tells designers that these classical constructions are not just
convenient — they are, in a precise sense, the only ones.

**The shape of rigidity itself.** The phenomenon — a mild smoothness constraint
crushing an exponential sea of possibilities down to a short, fully understood
list — is one of the recurring miracles of modern combinatorics. It is the same
spirit as stability theorems, as the classification of extremal configurations,
as the idea that "almost optimal implies almost structured." Here it appears in
an unusually clean and provable form.

## What we actually built

Stripped to essentials, the framework is a finite linear space — points, lines,
$q+1$ points per line, two points on a unique line — together with three
notions: *Boolean* (outputs in $\{0,1\}$), *degree $\le 1$* (a constant plus a
sum of point-weights), and their conjunction. On this skeleton we established,
with no gaps:

- the trivial solutions really qualify — the constants, every point-pencil, and
  all complements are Boolean degree one;
- there are at least $|P| + 2$ of them, via an explicit, verified injection that
  separates distinct points by a line;
- every *symmetric* degree-one function is constant, because every line has the
  same length $q+1$;
- and you cannot build a new Boolean solution by adding two pencils, because
  their unique common line is forced to read $2$.

Together these are the load-bearing walls of the rigidity theorem. The grand
conjecture — that for $q \ge 3$ and $n \ge 4$ *nothing else exists* — stands on
exactly this foundation, with the Fano plane standing quietly to one side as the
beautiful exception that proves the rule.

Geometry, it turns out, has an arithmetic of its own, and that arithmetic is far
stingier with its secrets than its size would ever suggest.
