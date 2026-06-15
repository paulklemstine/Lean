# Hidden Simplicity: How a Change of Coordinates Tames Multiplication and Reveals the Symmetry of Right Triangles

## The art of looking from the right angle

There is a recurring miracle in mathematics. You meet an object that looks
tangled, irregular, almost lawless — and then someone tilts their head, looks
at it through a different coordinate system, and the tangle straightens into a
single clean line. The chaos was never in the object. It was in the way you
were looking.

This article tells the story of two such miracles, both made fully rigorous and
machine-checked. They come from completely different corners of mathematics —
one from the algebra of *multiplication and powers*, the other from the
geometry of *right triangles* — yet they share the same secret. In each case, a
sprawling family of complicated expressions turns out to be governed by a small,
rigid skeleton once you find the coordinate system in which the world is
straight.

The first miracle is about taming multiplication with logarithms. The second is
about discovering that the ancient, infinite forest of Pythagorean triples
— (3,4,5), (5,12,13), (8,15,17), and all their cousins — is grown by the same
machine that powers the theory of modular forms. Let us take them in turn.

---

## Part I: Multiplication is just addition wearing a disguise

### A zoo of expressions

Imagine you are handed a positive quantity that depends on several positive
inputs — say the inputs are $x_1, x_2, \dots, x_n$, each a positive real
number. You are allowed to build new quantities out of them using exactly four
moves:

1. **Pick a coordinate.** Take one of the inputs, $x_i$, as it is.
2. **Insert a positive constant.** Throw in any fixed positive number $c$.
3. **Multiply.** Combine two quantities you have already built by multiplying
   them.
4. **Raise to a real power.** Take a quantity you have built and raise it to any
   real exponent $r$ — so $\sqrt{x}$, $x^{-1}$, $x^{2.7}$ are all allowed.

These four moves generate an enormous, branching zoo of formulas. You can write
things like

$$
5 \cdot x_1^{3} \cdot \sqrt{x_2} \cdot \left( 2\, x_3 \, x_1^{-1} \right)^{0.4},
$$

nesting powers inside products inside powers as deep as you like. To the naked
eye, two such formulas built by very different recipes might look unrelated.
Surely this zoo is wild?

### The straightening map

It is not. **Every single one of these expressions is secretly the same kind of
object: a weighted geometric monomial.** No matter how baroque the recipe, the
final result can always be written in the form

$$
x_1^{w_1}\, x_2^{w_2} \cdots x_n^{w_n} \cdot e^{c}
\;=\;
\exp\!\Big( w_1 \log x_1 + w_2 \log x_2 + \cdots + w_n \log x_n + c \Big),
$$

for some list of real *weights* $w_1, \dots, w_n$ and a single real *constant*
$c$. The expression is "log-affine": after you take logarithms, it becomes a
plain affine (linear-plus-constant) function of the logarithms of the inputs.

This is the content of what we will call the **Log-Affine Normal Form Theorem**.
The reason it is true is the oldest trick in the analyst's book — the one that
built the slide rule and powered three centuries of computation. The logarithm
turns multiplication into addition and powers into multiplication:

$$
\log(ab) = \log a + \log b, \qquad \log(a^r) = r \log a.
$$

Watch what the four building moves do once you pass to logarithmic coordinates,
recording each expression by its weight list $w$ and its constant $c$:

- A bare coordinate $x_i$ has weight $1$ on slot $i$ and $0$ everywhere else,
  with constant $0$. (In symbols, its weight vector is the indicator of $i$.)
- A positive constant $c$ has all weights $0$ and constant $\log c$.
- **Multiplying** two expressions simply **adds their weight vectors and adds
  their constants.** Multiplication has become vector addition.
- **Raising to the power $r$** simply **scales the weight vector by $r$ and
  scales the constant by $r$.** Exponentiation has become scalar multiplication.

So the entire wild zoo lives inside the most docile structure in all of
mathematics: a vector space. Each expression is just a point $(w, c)$, and the
only operations are "add two points" and "scale a point." The straightening map
that sends an expression to its pair $(w, c)$ is the heart of the theorem, and
the theorem proves that this map is *faithful*: when you exponentiate the affine
function it describes, you recover exactly the original expression, evaluated at
any positive input. Nothing is lost in translation.

### Why this matters

This is more than a parlor trick. It is the precise reason that whole families
of optimization problems — *geometric programs*, ubiquitous in engineering
design, circuit sizing, and economics — become convex and therefore tractable
the moment you substitute $y_i = \log x_i$. The objective and constraints, which
looked like nasty products of powers, are revealed as affine functions in the
new coordinates, and affine functions are the gentlest creatures convex
optimization knows. The normal form theorem is the rigorous backbone of that
change of variables: it certifies that the multiplicative fragment of the
language *exactly* coincides with the log-affine functions, with no exceptions
and no edge cases. Every expression has one canonical address $(w, c)$, and two
expressions are equal as functions precisely when they share an address.

---

## Part II: Every right triangle is a word in a two-letter alphabet

### The forest of Pythagorean triples

Now we change subjects entirely — from algebra to the geometry of the integers.
A *Pythagorean triple* is a trio of whole numbers $(a, b, c)$ with

$$
a^2 + b^2 = c^2,
$$

the side lengths of a right triangle with integer sides. The Babylonians
tabulated them; Euclid parametrized them; they have fascinated everyone since.
The *primitive* ones (where $a$, $b$, $c$ share no common factor) include
$(3,4,5)$, $(5,12,13)$, $(8,15,17)$, $(7,24,25)$, $(20,21,29)$, and infinitely
many more.

Here is the beautiful structural fact, discovered by Berggren in 1934 and
rediscovered many times since. **Every primitive Pythagorean triple can be
reached from the single seed $(3,4,5)$ by repeatedly applying just three fixed
integer matrices**, and the family tree this produces hits each primitive triple
exactly once. The triples are not a random scatter; they are the leaves of a
perfect ternary tree, and the branches are three explicit linear maps. Working
with the $3 \times 3$ Berggren matrices $B_1, B_2, B_3$ acting on the column
vector $(a, b, c)$, one finds, for example,

$$
B_1 = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3 \end{pmatrix},
\qquad
B_2 = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3 \end{pmatrix},
\qquad
B_3 = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3 \end{pmatrix}.
$$

### The Lorentz connection

Why these particular matrices? Because of a hidden geometry. The Pythagorean
equation $a^2 + b^2 = c^2$ is the same as $a^2 + b^2 - c^2 = 0$, which is the
statement that the vector $(a,b,c)$ is *null* for the **Lorentz form**
$Q = \mathrm{diag}(1, 1, -1)$ — the very quadratic form that governs special
relativity, where $c$ plays the role of time. A linear map sends Pythagorean
triples to Pythagorean triples precisely when it preserves this form, i.e. when
$B^{\mathsf T} Q\, B = Q$. The three Berggren matrices are exactly such
**Lorentz transformations over the integers**: each one satisfies
$B_i^{\mathsf T} Q\, B_i = Q$, with determinants $+1, -1, +1$. They are the
integer isometries of a relativistic "light cone," and the Pythagorean triples
are the integer points on that cone. The tree of triples is an orbit of a group
of symmetries — the symmetries of spacetime, restricted to the integers.

### The same machine that runs modular forms

The story deepens. Restrict attention to the $2 \times 2$ Berggren generators
$M_1, M_2, M_3$ that act on the parameters $(m, n)$ in Euclid's classical
formula $(a, b, c) = (m^2 - n^2,\ 2mn,\ m^2 + n^2)$. Two specific matrices
govern the entire theory of *modular forms* — the deep analytic objects at the
center of modern number theory, the heroes of the proof of Fermat's Last
Theorem. They are the translation
$T = \begin{psmallmatrix} 1 & 1 \\ 0 & 1\end{psmallmatrix}$ and the inversion
$S = \begin{psmallmatrix} 0 & -1 \\ 1 & 0\end{psmallmatrix}$.

The astonishing identities, all verified exactly, are these:

- **The third Berggren generator is the square of the translation:**
  $M_3 = T^2 = \begin{psmallmatrix} 1 & 2 \\ 0 & 1\end{psmallmatrix}$.
- **The first Berggren generator is "translate twice, then invert":**
  $M_1 = T^2 S$. Equivalently, $M_3^{-1} M_1 = S$, so multiplying the Berggren
  generators recovers $S$ on the nose.
- **The inversion has order four:** $S^2 = -I$ and $S^4 = I$.

In other words, the engine that grows the tree of right triangles is, letter for
letter, the engine that generates the **theta group** $\Gamma_\theta$ — the
particular symmetry group of the upper half-plane responsible for theta
functions and the arithmetic of sums of two squares. The theta group is carved
out of all integer $2 \times 2$ matrices of determinant one by a *parity
condition*: the diagonal entries must agree modulo 2, the off-diagonal entries
must agree modulo 2, and the top row must sum to an odd number. Both $T^2$ and
$S$ pass this test; the plain translation $T$ fails it (its top row sums to
$1 + 1 = 2$, which is even). And the parity condition is *closed under
multiplication* among determinant-one matrices — so once you build words out of
$T^2$ and $S$, you never leave the theta group. The Pythagorean tree is a walk
through this group, and the walk never steps outside.

### From triangles to sums of two squares — and to the Farey fractions

This is not an idle coincidence; it has arithmetic teeth. The same circle of
ideas controls how integers are written as sums of two squares. The count
$r_2(N)$ of ways to write $N = x^2 + y^2$ with integer $x, y$ (signs and order
counted) begins $r_2(0) = 1$ (only $0^2 + 0^2$) and $r_2(1) = 4$ (the four
points $(\pm 1, 0)$, $(0, \pm 1)$), and the classical **two-squares theorem**
— every prime $p \equiv 1 \pmod 4$ is a sum of two squares — falls out of the
same modular machinery. And the leaves of the Pythagorean tree, read through the
map $(a,b,c) \mapsto \tfrac{b}{a+c}$, land exactly on the **Farey fractions**:
$(3,4,5) \mapsto \tfrac12$, $(5,12,13) \mapsto \tfrac23$, $(8,15,17) \mapsto
\tfrac35$. The tree of triangles, the tree of fractions, and the symmetries of
the modular world are three faces of one object.

---

## The common thread

Step back and the two stories rhyme. In the first, an unruly zoo of
multiplicative expressions collapses to a single linear template once you pass
to logarithmic coordinates: every formula is a point $(w, c)$ in a vector space,
and multiplication and powers become addition and scaling. In the second, the
unruly forest of Pythagorean triples collapses to words in a two-letter alphabet
$\{T^2, S\}$ once you pass to the modular coordinates of $(m,n)$ parameters:
every triple is a path in a tree, and the branches are the generators of a
famous symmetry group.

In both cases the lesson is the same, and it is the deepest aesthetic principle
in mathematics: *complexity is often an illusion of coordinates.* Find the
chart in which the operations become elementary — logarithms here, the modular
group there — and the apparent chaos resolves into a crystalline normal form. A
weighted monomial. A word in two letters. The right angle to look from turns a
forest into a single straight line, and a zoo into a single point with an
address.

These results have been formalized and verified down to the last symbol, so the
crystalline picture is not a hopeful sketch but a certified fact: multiplication
really is addition in disguise, and every right triangle really is a sentence in
the language of modular symmetry.
