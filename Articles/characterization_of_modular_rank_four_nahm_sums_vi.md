# The Number That Might Decide Modularity

## A puzzle written in infinite series

Some of the most beautiful objects in mathematics are infinite sums that, against
all odds, collapse into tidy infinite products. The most famous example is more
than two centuries old. Take the series

$$1 + \sum_{n=1}^{\infty} \frac{q^{n^2}}{(1-q)(1-q^2)\cdots(1-q^n)},$$

and you discover — as Leonard Rogers and Srinivasa Ramanujan did — that it equals
the strikingly simple product

$$\prod_{n=0}^{\infty} \frac{1}{(1-q^{5n+1})(1-q^{5n+4})}.$$

A jagged-looking sum, built from quadratic exponents and awkward denominators,
turns out to be a single elegant product. That is a *Rogers–Ramanujan identity*,
and chasing identities of this kind has occupied number theorists, combinatorialists,
and physicists for a hundred years.

The series above belongs to a vast family discovered, in its modern form, by the
physicist Werner Nahm while studying conformal field theory. A **Nahm sum** of
rank $r$ is

$$f_Q(q) = \sum_{n \in \mathbb{N}^r} \frac{q^{Q(n)}}{(q;q)_{n_1}\,(q;q)_{n_2}\cdots(q;q)_{n_r}},$$

where $n = (n_1,\dots,n_r)$ runs over all tuples of non-negative integers,
$(q;q)_m = (1-q)(1-q^2)\cdots(1-q^m)$ is the *$q$-Pochhammer symbol* sitting in the
denominator, and $Q$ is a quadratic form — a homogeneous degree-two polynomial in
the variables $n_1,\dots,n_r$ — controlling the exponent in the numerator.

Nahm's deep question is disarmingly simple to state: **for which quadratic forms
$Q$ does the sum $f_Q(q)$ turn into a clean infinite product** — what specialists
call a *modular* function, an eta- or theta-quotient? When it does, you have a new
Rogers–Ramanujan-type identity. When it does not, the series is, in a precise
sense, transcendental noise.

For a single variable ($r=1$) the answer is essentially understood. For higher
ranks the landscape is wild and largely uncharted. This article is about a
concrete, testable proposal for **rank four** — four summation variables — and
about a single integer that may hold the key.

## The shape of a quadratic form

Every quadratic form $Q$ in four variables can be encoded in a $4\times 4$ symmetric
matrix called its **Hessian** $H$, via

$$Q(n) = \tfrac{1}{2}\, n^{\mathsf T} H\, n.$$

The Hessian collects the second derivatives of $Q$; it is the algebraic DNA of the
form. For example, the "diagonal" form $Q(n) = n_1^2 + n_2^2 + n_3^2 + \tfrac12 n_4^2$
has Hessian $H = \mathrm{diag}(2,2,2,1)$.

From the Hessian we extract one number, the **discriminant**:

$$\operatorname{disc}(H) = \det H,$$

the determinant of the matrix. The central conjecture that frames this work is bold
and clean:

> **Conjecture.** A rank-four Nahm sum $f_Q(q)$ is modular — expressible as an
> infinite product of $q$-Pochhammer symbols — *if and only if* the discriminant of
> its Hessian equals $8$, $12$, or $16$.

Three numbers. That is the whole criterion the conjecture proposes. If true, it
would turn an analytic question about infinitely many infinite series into a
one-line arithmetic test: compute a $4\times 4$ determinant and check whether the
answer lands in $\{8, 12, 16\}$.

A conjecture this sharp invites an obvious worry. A determinant is not a
self-evidently meaningful quantity — you can change how you write a quadratic form
by relabelling or recombining its variables, and you would not want the answer to a
deep question to depend on such bookkeeping. So before anyone can take the
conjecture seriously, one must prove that the discriminant is *robust*: that it is a
genuine invariant of the underlying mathematics, not an artifact of notation. That
robustness, together with the fact that the three target values are actually
achievable, is exactly what has now been established rigorously. The grand
biconditional remains open; its *foundations* do not.

## Why the discriminant is the right number

Here is the key tension. Two quadratic forms that look different on paper can be the
same form in disguise. If you substitute new integer variables for the old ones —
say, replace $n$ by $S n$ for some integer matrix $S$ that can be inverted over the
integers (a *unimodular* substitution, meaning $\det S = \pm 1$) — you change the
Hessian from $H$ to $S^{\mathsf T} H S$, but you do **not** change the Nahm sum in
any essential way. Such substitutions are just a change of coordinates.

So any honest criterion for modularity must give the same verdict for $H$ and for
$S^{\mathsf T} H S$. Does the discriminant pass this test? The answer comes from a
precise transformation law.

**The congruence law.** For any matrices $S$ and $H$ over any commutative number
system,

$$\det\!\big(S^{\mathsf T} H S\big) = (\det S)^2 \cdot \det H.$$

The proof is a two-line consequence of the multiplicativity of the determinant
($\det(AB) = \det A \det B$) and the fact that transposing a matrix does not change
its determinant. Changing variables multiplies the discriminant by the *square* of
$\det S$.

Now watch what the square does. Over the integers, a legal change of variables has
$\det S = +1$ or $\det S = -1$. Either way, $(\det S)^2 = 1$. The square silently
erases the sign, and we get:

**Unimodular invariance.** If $\det S = \pm 1$, then

$$\operatorname{disc}\!\big(S^{\mathsf T} H S\big) = \operatorname{disc}(H).$$

This is the linchpin. It says the discriminant is not merely invariant *up to a
square factor* (as it would be over the rationals or reals); over the integers it is
a **strict** invariant — exactly equal — across an entire equivalence class of
forms. The discriminant is therefore a legitimate label attached to the *form
itself*, not to any particular way of writing it. That is precisely the robustness
the conjecture needs, and it explains *why* a single integer could possibly govern
something as subtle as modularity: it is the natural numerical fingerprint of an
integral quadratic form.

## Building forms from blocks

The discriminant has a second structural virtue that turns out to be just as
important: it behaves beautifully under *combination*.

Suppose you have a quadratic form in $m$ variables and another in $n$ variables, and
you place them side by side without letting them interact — a so-called orthogonal
direct sum. The combined Hessian is *block-diagonal*: the first form's matrix $A$
sits in the top-left corner, the second form's matrix $D$ in the bottom-right, and
zeros fill the off-diagonal blocks. For such a matrix,

$$\det\begin{pmatrix} A & 0 \\ 0 & D \end{pmatrix} = \det A \cdot \det D.$$

**Discriminants multiply when forms are combined.** This is the multiplicative law.
Pushed to its extreme — a *diagonal* form, which is four independent one-variable
pieces stacked together — it says the discriminant is simply the product of the
diagonal entries:

$$\operatorname{disc}\big(\mathrm{diag}(d_1,d_2,d_3,d_4)\big) = d_1 \, d_2 \, d_3 \, d_4.$$

This gives the conjecture a delightful "Lego" interpretation. The smallest
modular building block — a single Rogers–Ramanujan-style variable of so-called
$A_1$ type — carries discriminant $2$. Larger modular pieces carry small
discriminants like $3$ or $4$. To build a modular rank-four object, you snap
together blocks whose discriminants *multiply* to one of the magic numbers. And
indeed the three targets factor neatly:

$$8 = 2\cdot 2\cdot 2\cdot 1, \qquad 12 = 3\cdot 2\cdot 2\cdot 1, \qquad 16 = 2\cdot 2\cdot 2\cdot 2.$$

The arithmetic of the target set mirrors the geometry of how modular forms are
assembled.

## The three targets are real

A criterion is worthless if its conditions are never met. Could it be that *no*
genuine four-variable form has discriminant $8$, $12$, or $16$? Then the conjecture
would be vacuously, uselessly "true." So the final piece of the foundation is a
concrete demonstration that each target value is achieved by an honest,
positive-definite quadratic form.

**Realisability.** Each of $8$, $12$, and $16$ is the discriminant of a symmetric
integer Hessian with strictly positive diagonal entries — hence a bona-fide
positive quadratic form. The witnesses are explicit and easy to check by the
diagonal-product rule:

$$\mathrm{diag}(2,2,2,1) \;\rightsquigarrow\; 8, \qquad
\mathrm{diag}(2,2,3,1) \;\rightsquigarrow\; 12, \qquad
\mathrm{diag}(2,2,2,2) \;\rightsquigarrow\; 16.$$

Multiply the diagonals: $2\cdot 2\cdot 2\cdot 1 = 8$, $2\cdot 2\cdot 3\cdot 1 = 12$,
$2\cdot 2\cdot 2\cdot 2 = 16$. All entries are positive, so each defines a real
positive-definite form, and each is a legitimate rank-four Nahm datum. The
conjecture is not about an empty set — it is about a rich, populated family, and we
have named members of it.

Notice, too, that every witness contains two doubled coordinates (the repeated
$2$'s). That is not a coincidence in the conjectural picture: a deeper prediction is
that the divisibility $4 \mid \det H$ — *not* mere evenness — is the structural cause
of modularity, reflecting two "doubled directions" coming from an even lattice. The
factor $4 = 2\cdot 2$ is written right into the witnesses.

## What is settled, and what beckons

Let us be scrupulous about the boundary between proof and conjecture. The
biconditional — *modular if and only if the discriminant is $8$, $12$, or $16$* —
remains open. It is a hard problem at the crossroads of number theory, the theory of
modular forms, and mathematical physics. What has been placed on rigorous footing is
the entire **scaffolding** that makes the conjecture meaningful and testable:

1. The discriminant transforms by the square of the substitution determinant, so it
   is well-behaved under any change of variables.
2. Over the integers it is a *strict* invariant of the equivalence class of a form —
   the unique numerical quantity a coordinate-free criterion is allowed to use.
3. It multiplies under direct sums and equals the product of diagonal entries,
   giving a building-block calculus that explains the factorizations of $8$, $12$,
   and $16$.
4. All three target values are realized by explicit positive forms, so the
   conjecture is genuinely non-vacuous.

Together, these reduce the daunting "only if" direction to a sharply focused
lattice-theoretic question: *must a modular rank-four datum come from an even
lattice with discriminant divisible by four and bounded by sixteen?* The remaining
open conjectures push further — that modular data always decompose into smaller
modular blocks, and that a balance between the growth of the numerator's quadratic
exponent and the denominator's degree forces the invariant into its narrow window.

There is something quietly thrilling about a conjecture that compresses an infinite,
unruly family of analytic identities into the inspection of a single determinant. It
echoes a recurring dream in mathematics: that behind apparent chaos lies a small,
crisp invariant doing all the work. Whether the dream holds here — whether $8$, $12$,
and $16$ truly are the only gateways to modularity in rank four — is now a
well-posed question resting on a solid foundation. The next move is to walk through
the gate.
