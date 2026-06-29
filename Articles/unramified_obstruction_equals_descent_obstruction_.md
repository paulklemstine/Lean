# When Two Obstacles Are Secretly the Same Wall

## A detective story about rational points

Some of the oldest questions in mathematics are deceptively simple to state: given an
equation, does it have a solution in whole numbers or fractions? The Pythagorean
equation $x^2 + y^2 = z^2$ has infinitely many; the equation $x^2 + y^2 = 3z^2$ has
none but the trivial one. The difference between "yes" and "no" is the entire subject
of *Diophantine geometry*, and after two thousand years it remains stubbornly hard.

Modern geometry repackages such an equation as a *variety* $X$ — the geometric shape
carved out by its solutions — and asks whether $X$ has a *rational point*, a solution
with coordinates in the field $K$ we care about. There is a classical first test. If
$X$ has a genuine solution over $K$, then it must have a solution everywhere
*locally*: in every completion of $K$, the analytic neighborhoods that record one
prime or one place at a time. Packaging all of these local worlds together gives the
*adelic space* $X(\mathbf{A}_K)$, a single object that sees every place at once. A
necessary condition for a rational point is therefore an adelic point.

But the test is famously incomplete. There are varieties with adelic points and no
rational point at all — shapes that look solvable everywhere locally yet are
unsolvable globally. The gap between local and global is where the deepest arithmetic
lives, and mathematicians measure that gap with *obstructions*: rules that carve away
the adelic points that could never have come from a real, global solution.

This article is about a surprising discovery: over a particular family of fields, two
obstructions that look completely different — built from different cohomology, motivated
by different geometry — secretly carve away *exactly the same* set of adelic points.
They are two names for one wall. And the reason has nothing to do with the intricate
analysis of adeles. It is a soft, structural fact about how pairings and orthogonality
interact.

## The Brauer–Manin idea, and its descendants

The most influential obstruction is the *Brauer–Manin obstruction*, introduced by Yuri
Manin in 1970. Its engine is a pairing. To each adelic point $s$ and each cohomology
class $b$ (drawn from the Brauer group of $X$), reciprocity in class field theory
assigns a value $\langle s, b\rangle$ in the circle group $\mathbb{Q}/\mathbb{Z}$.
A genuine rational point pairs to zero with *every* class $b$. So the adelic points
that survive — the ones that might still come from a rational point — are exactly those
that are *orthogonal* to the whole group of classes. Everything outside that orthogonal
locus is provably unreachable.

Over number fields, Jean-Louis Colliot-Thélène made a bold conjecture: for the most
flexible varieties — the *rationally connected* ones, where any two points can be joined
by a chain of rational curves — the Brauer–Manin obstruction is *the only* obstruction.
If a rationally connected variety survives the Brauer–Manin test, it really does have a
rational point. This is one of the guiding stars of modern arithmetic geometry.

The Brauer–Manin obstruction has refinements. The *descent obstruction* uses families
of auxiliary covering spaces (torsors) to cut deeper. The *étale–Brauer obstruction*
combines both ideas. Each refinement is built from a richer supply of cohomology
classes, and each can, in principle, carve away more adelic points than its predecessor.
A natural and recurring question is: *when do two of these obstructions coincide?*

## A different field, a different ceiling

Our story takes place not over a number field but over a *$p$-adic function field*.
Concretely: start with a $p$-adic field (a completion of the rationals at a prime $p$),
take a smooth projective curve over it, and let $K$ be the field of rational functions
on that curve. These fields are the natural arithmetic home of surfaces and higher
families, and they have a crucial numerical signature: their *cohomological dimension*
is exactly $3$. A $p$-adic field has cohomological dimension $2$; adding the curve adds
one more.

That number is decisive. Over a number field, the Brauer group lives in degree two —
$H^2_{nr}(X, \mathbb{Q}/\mathbb{Z}(1))$ in the language of unramified cohomology. Over a
$p$-adic function field, the cohomological dimension is one higher, and the right
object to pair against is the *degree-three* unramified cohomology
$H^3_{nr}(X, \mathbb{Q}/\mathbb{Z}(2))$. This degree-three group plays exactly the role
the Brauer group plays over number fields. It produces what we call the *unramified
obstruction*.

So we have two obstructions on the same variety:

- the **descent obstruction**, built from torsors;
- the **unramified obstruction**, built from degree-three unramified cohomology.

The conjecture at the heart of this work is that, for smooth proper rationally connected
varieties over a $p$-adic function field, these two are equal:
$$ X(\mathbf{A}_K)^{H^3_{nr}} \;=\; X(\mathbf{A}_K)^{\mathrm{descent}}. $$
This is the precise $p$-adic-function-field analogue of Colliot-Thélène's conjecture,
with the unramified obstruction stepping into the role of Brauer–Manin, exactly as the
cohomological dimension demands.

## The structural heart: orthogonality is a Galois connection

Here is the surprise. To prove that two obstruction sets are equal, you do *not* need to
understand the fine analytic structure of adeles. Every obstruction of this kind — Brauer–Manin,
descent, étale–Brauer, unramified — is a *left orthogonal under a pairing*. And equality
of orthogonals is governed by an old, soft piece of order theory: a *Galois connection*.

Let us strip the situation to its bones. We have three abelian groups:

- $S$, standing in for the adelic points;
- $B$, the group of cohomology classes;
- $C$, the value group (think $\mathbb{Q}/\mathbb{Z}$),

together with a biadditive **pairing** $\langle\,\cdot\,,\,\cdot\,\rangle : S \times B \to C$.

For any set of classes $H \subseteq B$, the **obstruction set** it cuts out is its left
orthogonal,
$$ H^{\perp} \;=\; \{\, s \in S : \langle s, b\rangle = 0 \ \text{ for all } b \in H \,\}. $$
Symmetrically, any set of adelic points $T \subseteq S$ has a right orthogonal
$T^{\perp} \subseteq B$. These two operations satisfy the defining law of a Galois
connection:
$$ H \subseteq T^{\perp} \quad\Longleftrightarrow\quad T \subseteq H^{\perp}. $$
Both maps reverse inclusions: the *more* classes you pair against, the *fewer* adelic
points survive.

From this single law, everything follows by pure formalism. Composing the two
orthogonals gives a **closure operator** on the classes,
$$ \mathrm{cl}_B(H) \;=\; \bigl(H^{\perp}\bigr)^{\perp}, $$
which is extensive ($H \subseteq \mathrm{cl}_B H$), monotone, and idempotent. Its closed
sets are exactly the subgroups of $B$ that can be recovered as orthogonals — the
"saturated" families of classes. The two facts we need are immediate consequences:

> **The obstruction depends only on the closure.** For every family $H$,
> $H^{\perp} = (\mathrm{cl}_B H)^{\perp}$. Adding classes that already lie in the
> closure of $H$ changes nothing about which adelic points survive.

> **Equality criterion.** Two families $H_1$ and $H_2$ cut out the same obstruction set,
> $H_1^{\perp} = H_2^{\perp}$, *if and only if* they have the same closure,
> $\mathrm{cl}_B H_1 = \mathrm{cl}_B H_2$.

Now comes the punchline, which is almost embarrassingly clean. Suppose the descent
classes $H_{\mathrm{desc}}$ and the unramified classes $H_{\mathrm{unr}}$ are sandwiched:
$$ H_{\mathrm{desc}} \;\subseteq\; H_{\mathrm{unr}} \;\subseteq\; \mathrm{cl}_B(H_{\mathrm{desc}}). $$
The first inclusion says every descent class is unramified; the second says the
unramified classes add nothing new beyond the closure of the descent classes. Apply the
closure operator across the sandwich. Monotonicity and idempotence squeeze everything
together,
$$ \mathrm{cl}_B H_{\mathrm{desc}} \subseteq \mathrm{cl}_B H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(\mathrm{cl}_B H_{\mathrm{desc}}) = \mathrm{cl}_B H_{\mathrm{desc}}, $$
so the closures are equal. By the equality criterion, the obstruction sets are equal:
$$ X(\mathbf{A}_K)^{H^3_{nr}} = X(\mathbf{A}_K)^{\mathrm{descent}}. $$

That is the entire logical skeleton of the conjecture. The hard arithmetic — rational
connectedness, the cohomological dimension being three, the role of degree-three
unramified cohomology — enters at *exactly one point*: it is what guarantees the
sandwich inclusion $H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}})$. Once
that single inclusion of cohomology subgroups is in hand, the equality of two infinite
sets of adelic points is *forced* by the Galois-connection formalism, with no further
analysis.

## Is the theorem empty?

A skeptic should immediately worry. The sandwich hypothesis could be a disguised
triviality. What if "$H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}})$"
secretly forces $H_{\mathrm{desc}} = H_{\mathrm{unr}}$ on the nose, so that the two
obstructions are equal only because the inputs were equal all along? A theorem that only
fires when its conclusion is already obvious is worthless.

The doubt is answered by an explicit, hands-on example small enough to check by hand.
Take all three groups to be $\mathbb{Z}/4$, the integers modulo $4$. Define the pairing
by $\langle s, b\rangle = (2s)\cdot b$. Let the descent classes be the single element
$H_{\mathrm{desc}} = \{1\}$ and the unramified classes be
$H_{\mathrm{unr}} = \{1, 2\}$.

These are genuinely different sets: $2$ is unramified but not a descent class, so
$H_{\mathrm{desc}} \subsetneq H_{\mathrm{unr}}$ strictly. Yet $1$ *generates* all of
$\mathbb{Z}/4$ under addition — $1+1 = 2$ — so the element $2$ lies in the subgroup
generated by $\{1\}$, hence in its closure. The sandwich holds with a strict inclusion
of class sets.

What is the common wall? The orthogonal of $\{1\}$ is the set of $s$ with $2s = 0$ in
$\mathbb{Z}/4$, namely $\{0, 2\}$. This is a *proper, nonempty* subset of $\mathbb{Z}/4$:
the point $0$ survives, the point $1$ does not. So the obstruction is real — it
genuinely throws away points — and the two obstructions, despite arising from different
class sets, carve out the identical locus $\{0, 2\}$. The coincidence is produced by the
closure operator, not by any renaming. The theorem has teeth.

## Why this matters

The reframing pays a conceptual dividend that goes well beyond a single conjecture. It
says that *the entire tower of obstruction refinements is governed by one closure
operator*. Descent, étale–Brauer, unramified — each corresponds to a family of
cohomology classes, and the only way a refinement can be strictly stronger than its
predecessor is for its classes to *escape the closure* of the smaller family. Over a
$p$-adic function field, the cohomological dimension is precisely three, which is the
ceiling at which degree-three unramified cohomology can still absorb new classes. Above
that ceiling there is nowhere left to escape to. The prediction is sharp and checkable:
the whole tower should collapse to a single locus.

It also turns a hard Diophantine question into an internal one. Asking whether the
unramified obstruction is *the only* obstruction to a rational point becomes equivalent
to asking whether the unramified classes are *saturated* — closed under the
double-orthogonal operation. That is a structural property of a cohomology group, not a
statement about the elusive existence of points, and structural properties are the kind
of thing current cohomological methods can actually attack.

Two walls, it turns out, were one all along. Seeing that they coincide required not more
analysis but less — peeling away the analytic scaffolding until the bare order-theoretic
skeleton stood revealed, and with it a clean, sharp map of where the real arithmetic
must live.
