# Non-Desarguesian Worlds: Geometry Where a "Self-Evident" Theorem Fails

## A picture that looks like it must be true

Draw two triangles on a sheet of paper, and arrange them so that the three
lines joining their corresponding corners all pass through a single point. Call
that point the *center of perspective*: it is as if the two triangles are two
shadows of the same object, cast from a single light source.

Now do something with the *sides*. Extend each side of the first triangle and
the matching side of the second until the two lines meet. You get three meeting
points, one for each pair of corresponding sides. The astonishing claim, made
by the seventeenth-century French architect and mathematician Girard
Desargues, is this:

> **Desargues' Theorem.** If two triangles are perspective from a point, then
> the three intersection points of their corresponding sides all lie on a
> single straight line.

Three points, born from three independent pairs of lines, and yet they always
fall obediently into a row. Draw it carefully and you will see it happen every
time. It feels less like a theorem and more like a law of nature — the kind of
statement that ought to be built into the very meaning of the words *point*,
*line*, and *straight*.

And here is the surprise this article is about: **it is not.** There are
perfectly good geometric worlds — flat planes with points and lines, where any
two points determine exactly one line and parallels behave the way Euclid
wanted — in which Desargues' theorem is simply *false*. In these worlds you can
build two triangles, perspective from a point, whose three side-intersections
stubbornly refuse to line up.

Such worlds are called **non-Desarguesian planes**, and the smallest of them
lives at a very specific size: a plane with exactly **81 points and 90 lines**.
This article tells the story of how to build one, and why the failure of a
"self-evident" geometric fact turns out to be the shadow of a much more
tangible defect: a system of arithmetic in which multiplication forgets how to
distribute over addition.

## Coordinates are secretly algebra

The bridge between geometry and algebra is one of the oldest ideas in
mathematics, and it is the key to the whole story. When Descartes taught us to
label the points of the plane with pairs of numbers $(x, y)$, he did more than
invent graph paper. He revealed that **the geometry of a plane is encoded in the
arithmetic of its coordinates.** A line becomes an equation $y = x \cdot m + b$;
"three points are collinear" becomes an algebraic identity; and deep geometric
theorems become deep algebraic ones.

So here is the natural question. The real number line, the rationals, the
complex numbers — these are the coordinate systems we usually use, and the
planes they build all satisfy Desargues' theorem. What arithmetic properties of
the *numbers* are secretly responsible for that geometric fact? If we could
isolate them, we could try to break them, and see what geometry we get.

The answer, discovered over the first half of the twentieth century, is
beautifully precise. To coordinatize a flat plane you do **not** need all the
familiar laws of arithmetic. You need surprisingly little:

- an **addition** that behaves like ordinary addition (you can add, subtract,
  and there is a zero);
- a **multiplication** with a unit element $1$, so that $1 \cdot a = a \cdot 1 = a$;
- **enough division**: given a nonzero $a$ and any target $c$, the equations
  $a \cdot x = c$ and $x \cdot a = c$ each have exactly one solution;
- **one distributive law** — the *right* one, $(a + b)\cdot c = a\cdot c + b\cdot c$;
- and a technical "no two lines cross twice" condition (the *planar* axiom),
  which says that for distinct slopes $a \neq b$ the equation
  $x\cdot a = x\cdot b + d$ always has a unique solution $x$.

A structure obeying exactly these rules is called a **quasifield**. Notice
what is conspicuously *missing* from the list. A quasifield need not be
**commutative** ($a\cdot b$ may differ from $b\cdot a$). It need not be
**associative** ($(a\cdot b)\cdot c$ may differ from $a\cdot(b\cdot c)$). And,
most importantly, it need not satisfy the **left** distributive law
$a\cdot(b + c) = a\cdot b + a\cdot c$.

The central structural theorem is that this stripped-down list is *exactly* what
geometry needs:

> **Coordinatization Theorem.** Every quasifield $Q$ builds a genuine affine
> plane. Its points are the pairs $(x,y)$ with entries in $Q$; its lines are
> the graphs $y = x\cdot m + b$ together with the vertical lines $x = c$. In
> this plane any two distinct points lie on exactly one line, and through any
> point not on a given line there passes exactly one parallel line (Playfair's
> axiom). The plane is non-degenerate: there exist four points, no three
> collinear.

And here is the punchline that connects everything:

> **The Desargues Dictionary.** The plane coordinatized by $Q$ satisfies
> Desargues' theorem **if and only if** $Q$ can be taken to be a *division
> ring* — an arithmetic that is associative and obeys **both** distributive
> laws.

So Desargues' theorem is not a fact about geometry at all. It is a disguised
fact about *algebra*. If you want a plane where Desargues fails, you must find
a quasifield that is genuinely *not* a division ring — one where associativity
or, more subtly, the left distributive law truly breaks. Every "impossible"
geometric picture corresponds to an honest arithmetic defect.

## Building a lopsided arithmetic

Where does one find such an exotic number system? The trick, due to Leonard
Dickson around 1905, is to start from an ordinary, well-behaved field and
*twist* its multiplication just enough to poison one distributive law while
keeping everything else intact.

Begin with the field of nine elements, $\mathrm{GF}(9)$. It is built the same
way the complex numbers are built from the reals: adjoin a square root of
$-1$. Working with the three numbers $\{0,1,2\}$ and arithmetic modulo $3$ (so
that $-1$ is the same as $2$), we introduce a symbol $\alpha$ with
$\alpha^2 = -1 = 2$. Every element is then written $a + b\alpha$ with
$a, b \in \{0,1,2\}$ — nine elements in all — and they multiply exactly like
complex numbers:
$$(a + b\alpha)(c + d\alpha) = (ac + 2bd) + (ad + bc)\,\alpha.$$
This is a perfectly ordinary field: commutative, associative, both distributive
laws holding. Its plane is thoroughly Desarguesian. We must break it on
purpose.

The tool for the twist is the **Frobenius map**, the "conjugation" of this
little world:
$$\sigma(a + b\alpha) = a - b\alpha = a + 2b\alpha,$$
which is exactly the operation $x \mapsto x^3$. Just as complex conjugation
flips the sign of the imaginary part, $\sigma$ flips the sign of the
$\alpha$-part. It is an automorphism: it respects both addition and
multiplication of $\mathrm{GF}(9)$.

Now the crucial observation. Among the eight nonzero elements of
$\mathrm{GF}(9)$, exactly four are **perfect squares** (values $c\cdot c$ for
some $c$) and four are **non-squares**. A direct check shows the squares are
$\{1, 2, \alpha, 2\alpha\}$ and the non-squares are
$\{1+\alpha,\ 1+2\alpha,\ 2+\alpha,\ 2+2\alpha\}$. This clean split into two
halves is the fault line along which we will fracture the arithmetic.

Define a new multiplication $\ast$, the **Dickson product**, by looking at the
*right-hand* factor:
$$
a \ast b =
\begin{cases}
a \cdot b, & \text{if } b \text{ is zero or a nonzero square},\\[2pt]
\sigma(a)\cdot b, & \text{if } b \text{ is a non-square.}
\end{cases}
$$
In words: multiply as usual, *except* when the right factor is a non-square, in
which case you first conjugate the left factor. The addition is untouched — it
is still the ordinary addition of $\mathrm{GF}(9)$, the flat grid
$\{0,1,2\}\times\{0,1,2\}$. Only multiplication has been made lopsided.

## What survived, and what broke

The delicate point is that the twist is surgical. It destroys precisely the
properties we want gone, and no others. A finite but complete check over all
$9$, $81$, or $729$ relevant combinations confirms each of the following.

**Still a unit.** The element $1$ still satisfies $1 \ast a = a \ast 1 = a$ for
every $a$.

**Still divisible.** For every nonzero $a$, the equations $a\ast x = c$ and
$x\ast a = c$ each have a unique solution — there are no "zero divisors," and
division works in both directions.

**Still right-distributive.** The law $(a+b)\ast c = a\ast c + b\ast c$ holds
universally. (This is why the choice to branch on the *right* factor matters:
the right factor is what right distributivity reaches across, and Frobenius
being an automorphism keeps it intact.)

**Still associative.** Remarkably, $(a\ast b)\ast c = a\ast(b\ast c)$ for all
$a,b,c$. A quasifield whose multiplication is associative is called a
**nearfield**, and this is the celebrated *Dickson nearfield of order 9* — the
unique proper finite nearfield at this size.

Together these guarantee — via the Coordinatization Theorem — that the Dickson
product builds a legitimate flat plane: $81$ points, $90$ lines, any two points
on a unique line, Playfair's parallel axiom satisfied. Geometrically it looks
impeccable.

But two laws did *not* survive, and their failure is explicit and concrete.

**Commutativity is gone.** For example,
$$\alpha \ast (1+\alpha) \ \neq\ (1+\alpha) \ast \alpha,$$
because $1+\alpha$ is a non-square: multiplying by it on the right conjugates
its partner, and $\sigma$ moves $\alpha$.

**Left distributivity is gone.** This is the decisive one. Take
$a = \alpha$, $b = \alpha$, $c = 1$. Then $b + c = 1 + \alpha$ is a
*non-square*, while $b = \alpha$ and $c = 1$ are both *squares*. The left side
$a\ast(b+c)$ conjugates $a$ (because the right factor $1+\alpha$ is a
non-square), but the right side $a\ast b + a\ast c$ does *not* (because $\alpha$
and $1$ are squares). The two sides disagree:
$$\alpha \ast (\alpha + 1) \ \neq\ \alpha\ast\alpha + \alpha\ast 1.$$
The single act of adding two squares to land on a non-square flips which branch
of the definition fires — and that mismatch is exactly the leak that dooms the
distributive law.

> **Theorem (The lopsided nearfield).** The Dickson product on $\mathrm{GF}(9)$
> is associative, has a two-sided unit, admits unique two-sided division, and is
> right-distributive, so it is a quasifield — in fact a nearfield. But it is
> **neither commutative nor left-distributive.** Consequently it is not a
> division ring, and by the Desargues Dictionary the plane it coordinatizes is
> **non-Desarguesian.**

## Why 9, and not sooner

The order $9 = 3^2$ is no accident: it is the *smallest* order at which a
non-Desarguesian plane can exist. For every prime $p$ and every plane of order
$p$ (that is, $2, 3, 4, 5, 7, 8$), and indeed for all orders up to $8$, every
plane is forced to be Desarguesian — the coordinatizing arithmetic has no room
to be anything but a field. Only at $9$ does the field first factor as a genuine
square, $9 = 3^2$, giving $\mathrm{GF}(9)$ a Frobenius automorphism to twist
with and a clean square/non-square split to twist along. The lopsided plane
appears at the earliest possible moment the algebra permits.

The construction generalizes: replace $\mathrm{GF}(9)$ by $\mathrm{GF}(q^2)$ for
any prime power $q$, use the Frobenius $x \mapsto x^q$, and branch on
squares versus non-squares. The result is a proper nearfield and a
non-Desarguesian plane of order $q^2$ for *every* prime power $q$. Far from
being a freak of small numbers, non-Desarguesian worlds are everywhere.

## The symmetry you lose

There is a final, poetic cost to abandoning Desargues, and it concerns
symmetry. A Desarguesian plane is lavishly symmetric: its group of
symmetries — the *collineations*, the transformations sending lines to lines —
is enormous and acts almost transitively, mixing points and lines with great
freedom. This is the projective linear group, and it is what makes classical
projective geometry so homogeneous.

The Dickson plane cannot afford such riches. The twist singled out a
distinguished structure — the sub-arithmetic of "tame" elements over which
multiplication *does* behave nicely, the so-called **nucleus** — and every
symmetry of the plane is compelled to respect it. A collineation cannot scramble
the tame directions with the twisted ones. The result is that the symmetry group
of the non-Desarguesian plane is *strictly smaller* than that of the
Desarguesian plane of the same order. **The loss of a theorem is paid for in
the currency of symmetry.**

## Why any of this matters

It is tempting to file all this under "logical curiosities" — clever
counterexamples to something we never doubted. That would miss the point twice
over.

First, this is a rare and clarifying example of a **theorem that is true for a
reason.** Desargues' theorem is not a tautology; it holds in the familiar plane
*because* the real numbers happen to be associative and doubly distributive.
Strip those properties away and the theorem falls. Discovering that a
geometric statement is exactly equivalent to an algebraic one — that
"triangles align" is the same information as "numbers distribute both ways" — is
the kind of unification mathematicians prize most. Geometry and algebra turn out
to be two languages for one underlying object.

Second, non-Desarguesian planes are the raw material of an entire branch of
combinatorics and design theory. Finite planes underlie error-correcting codes,
combinatorial designs, and the deep still-open questions about which orders of
finite planes can exist at all. The nearfields and their exotic cousins (Hall
planes, Hughes planes) populate the classification of the four projective planes
of order $9$, and the tools built to understand them — quasifields, nuclei,
coordinatization — are now standard instruments.

And third, there is the sheer pleasure of the thing. Somewhere in the space of
all possible arithmetics sits a nine-element world whose multiplication is
*almost* a field — associative, divisible, right-distributive — and yet, because
adding two squares can land you on a non-square, it distributes on one side but
not the other. That microscopic asymmetry, invisible in any single equation,
propagates all the way up to geometry and tears apart a picture that every
student of Euclid would have sworn was inviolable. Three points that should have
been collinear, aren't. It is a small miracle, and it is completely, rigorously,
provably real.
