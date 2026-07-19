# The Arithmetic of Games: How Finite Surreal Numbers Become Dyadic

## A number born from a choice

Most number systems begin with objects and then add rules. The surreal numbers reverse that order. A surreal number is born from a choice between two collections of earlier numbers. It is written

$$
\{L\mid R\},
$$

where every member of the left set $L$ is smaller than every member of the right set $R$. The new number is the simplest number lying strictly between those options. This construction turns arithmetic into a family tree: each number has a birthday recording the stage at which its description first becomes available.

The first day is almost empty. With no options on either side, one obtains

$$
0=\{\,\mid\,\}.
$$

Once zero exists, the next stage produces

$$
1=\{0\mid\},\qquad -1=\{\mid 0\}.
$$

Then the gap between $0$ and $1$ yields

$$
\frac12=\{0\mid 1\}.
$$

The next rounds create halves of halves, odd numerators between neighboring fractions, and ever larger integers. This simple game of choosing a left and a right boundary eventually generates an enormous ordered number system containing the familiar real numbers, ordinal numbers, infinitely large quantities, and infinitesimals.

But the finite opening of this universe has a strikingly rigid arithmetic shape. It is governed not by arbitrary fractions, but by the **dyadic rationals**: numbers of the form

$$
\frac{m}{2^n},
$$

where $m$ is an integer and $n$ is a nonnegative integer. The arithmetic developed here explains why the powers of two are not an accident, why their canonical surreal representatives are distinct, and why this finite-birthday world is a ring rather than a field.

## The binary staircase

Begin with the canonical game for $1$ and repeatedly take the simplest number between $0$ and the preceding value. This creates

$$
1,\quad \frac12,\quad \frac14,\quad \frac18,\quad \ldots.
$$

The key birthday theorem says that the canonical representative of $2^{-n}$ has birthday exactly $n+1$. Thus $1=2^0$ appears at birthday $1$, $1/2$ at birthday $2$, $1/4$ at birthday $3$, and so on.

This result says two things at once. First, every inverse power of two appears after finitely many stages. Second, no fixed finite stage contains them all: their birthdays are unbounded among the natural numbers. The approach to zero is therefore also a journey deeper into the construction.

These values behave exactly as their ordinary fractional notation suggests. Every $2^{-n}$ is positive, and the sequence is strictly decreasing:

$$
2^{-(n+1)}<2^{-n}.
$$

Consequently, two canonical inverse powers of two are equal if and only if their exponents agree. The hierarchy does not accidentally collapse $1/4$ and $1/8$, for example; order keeps every rung of the binary staircase separate.

There is another essential cancellation fact. If $m$ is an integer, then

$$
m\,2^{-n}=0
$$

holds if and only if $m=0$. A nonzero integer cannot annihilate a positive inverse power of two. This elementary-looking statement is the hinge on which uniqueness turns.

## Fractions that cannot disguise themselves

A dyadic number can have more than one written form. For instance,

$$
\frac12=\frac24=\frac48.
$$

So the right uniqueness statement cannot require identical numerators and denominators. Instead, it uses the familiar rule of cross multiplication.

For integers $m_1,m_2$ and nonnegative integers $n_1,n_2$, the corresponding surreal dyadics satisfy

$$
m_1 2^{-n_1}=m_2 2^{-n_2}
$$

if and only if

$$
m_1 2^{n_2}=m_2 2^{n_1}.
$$

This is the **Cross-Multiplication Theorem for Dyadic Surreals**. It provides a complete test for equality using integer arithmetic alone. As an example,

$$
\frac{6}{2^4}=\frac{3}{2^3}
$$

because $6\cdot 2^3=3\cdot 2^4=48$. By contrast,

$$
\frac{5}{2^3}\ne\frac{3}{2^2}
$$

because $5\cdot 2^2=20$ while $3\cdot 2^3=24$.

This criterion proves that the canonical map from the localized ring $\mathbb Z[1/2]$ into the surreal numbers is injective. Here $\mathbb Z[1/2]$ means the integers with powers of two made invertible; concretely, it is precisely the set of fractions $m/2^n$. Injectivity means that no two genuinely different dyadic rationals become the same surreal number. The image is therefore a faithful copy of dyadic arithmetic inside the surreal universe.

There is a practical lesson here. Equality in a recursively generated world may look like a question about game trees, but for this entire family it reduces to a single multiplication test in the integers. The elaborate genealogy of a number and its ordinary arithmetic value agree perfectly.

## A ring, not a field

It is tempting to call every rich collection of numbers a field. The dyadic rationals are closed under addition, subtraction, and multiplication:

$$
\frac{a}{2^m}+\frac{b}{2^n}
 =\frac{a2^n+b2^m}{2^{m+n}},
$$

and

$$
\frac{a}{2^m}\frac{b}{2^n}=\frac{ab}{2^{m+n}}.
$$

They also contain $0$ and $1$. These properties make them a commutative ring. Yet division exposes a boundary. The number $3$ has no multiplicative inverse in $\mathbb Z[1/2]$.

Suppose, for contradiction, that some dyadic $m/2^n$ were an inverse of $3$. Then

$$
3\frac{m}{2^n}=1,
$$

so

$$
3m=2^n.
$$

The left side is divisible by $3$, whereas no power of $2$ is divisible by $3$. This is impossible. Hence $1/3$ is not dyadic.

This obstruction corrects a subtle but important misconception about birthdays. The numbers born at finite stages are naturally associated with the dyadic **subring**, not a subfield. Closing that collection under multiplicative inverses would immediately force the inclusion of $1/3$, which does not have a finite birthday in the canonical surreal hierarchy.

The distinction matters far beyond terminology. A birthday cutoff describes when objects are constructed. A ring closure describes which objects arithmetic operations generate. A field closure additionally demands every nonzero inverse. These are different processes, and they need not preserve the same boundary.

## Why powers of two rule the finite days

The appearance of dyadics reflects a universal fact about repeatedly selecting simplest midpoints. Given neighboring dyadic boundaries, the simplest point inserted between them refines the denominator by a factor of two. Binary subdivision is built into the construction:

$$
0,1
\quad\longrightarrow\quad
0,\frac12,1
\quad\longrightarrow\quad
0,\frac14,\frac12,\frac34,1.
$$

This is the same geometry behind binary search, bisection algorithms, digital fixed-point arithmetic, and subdivision meshes in computer graphics. A finite binary word records a finite route through successive left-right choices. Correspondingly, a dyadic fraction is exactly a rational number with a terminating binary expansion.

For example,

$$
\frac{13}{16}=0.1101_2.
$$

Its denominator records four levels of binary resolution. Surreal birthdays add a genealogical interpretation: denominator depth measures part of the history required to isolate the number, though for general dyadics the exact birthday also depends on the integer part and reduction of the fraction.

This makes dyadic surreals useful as a conceptual bridge. In numerical computation, dyadic fractions are the exactly representable finite binary values. In harmonic analysis, dyadic intervals organize functions by scale. In combinatorial game theory, birthdays organize numbers by constructive complexity. The same powers of two describe precision, scale, and ancestry.

## The horizon at day $\omega$

All finite birthdays lie before the first infinite ordinal $\omega$. The sequence $2^{-n}$ demonstrates what happens near that horizon: each term is born finitely, but there is no final finite day on which the entire sequence appears. The union of all finite stages contains every dyadic fraction, while remaining arithmetically incomplete as a field.

That observation prevents an easy but false leap from “all finite constructions” to “a closed number field.” The finite-birthday collection can support addition and multiplication of dyadic values, yet inversion can leave it. In particular, $3$ is present, but $1/3$ is not.

The next classification challenge is to prove the converse in full generality: not only does every canonical dyadic arise at a finite birthday, but every surreal with a finite-birthday representative is dyadic. The natural strategy is to inspect the finite left and right option sets and identify the simplest dyadic lying between them. Such a theorem would convert the vivid binary picture into a complete characterization of the finite region.

Beyond that boundary, one must proceed carefully. There is no smallest positive infinitesimal: given a positive infinitesimal $x$, the number $x/2$ is smaller and still positive. Thus any theory built around “the smallest positive infinitesimal” must instead choose a specific distinguished infinitesimal, such as $\omega^{-1}$. Likewise, a birthday-bounded class should never be silently identified with the ring or field it generates.

## The moral of the game

The surreal numbers show how a vast arithmetic universe can grow from an austere rule: choose earlier values on the left and right, then create the simplest number between them. In the finite stages, this rule speaks binary. The canonical units $2^{-n}$ appear on precisely scheduled birthdays, remain positive and strictly ordered, and admit no unexpected additive collapse. Integer multiples of these units give a faithful copy of $\mathbb Z[1/2]$, with equality decided exactly by cross multiplication.

And the first obstruction is just as illuminating as the successes: $3$ has no dyadic inverse. The finite world is not deficient because of an accident in notation. Its limitation is structural. Birthdays measure construction, while field operations demand closure, and those two ideas diverge as soon as one asks for $1/3$.

That is the arithmetic of games in miniature: a family tree that becomes a number line, a binary genealogy that becomes a ring, and a missing inverse that marks the boundary between finite construction and the larger surreal cosmos.
