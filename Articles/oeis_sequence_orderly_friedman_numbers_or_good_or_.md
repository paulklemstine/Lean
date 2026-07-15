# The Number That Can Read Itself

## An infinite family of orderly Friedman numbers

Most numbers are content simply to *be* numbers. A Friedman number does something more theatrical: it reconstructs itself from its own decimal digits. The digits may be joined by familiar arithmetic operations—addition, multiplication, exponentiation, negation, and parentheses—so that the resulting expression has exactly the value of the original number.

The number $127$ is a compact example:

$$
127=-1+2^7.
$$

The right-hand side uses the digits $1$, $2$, and $7$ exactly as they appear in the decimal numeral. It does not smuggle in any new digit, and it performs genuine arithmetic rather than merely writing $127$ again.

This example belongs to a particularly elegant class: the **orderly Friedman numbers**. In an ordinary Friedman representation, the original digits may be rearranged. In an orderly representation, they must occur from left to right in their original reading order. The expression for $127$ is orderly because its digit leaves are $1$, then $2$, then $7$. So is

$$
736=7+3^6.
$$

The order restriction turns a recreational puzzle into a question about syntax, place value, recurrence, and growth. It asks not merely whether arithmetic can hit a target, but whether it can do so while respecting the information encoded by a decimal word.

The central result described here is unexpectedly simple: one small certificate, repeated block by block, generates infinitely many distinct orderly Friedman numbers. Better still, the resulting sequence has an exact recurrence, a closed form, a divisibility law, a fixed decimal suffix, and a precise asymptotic error.

## What “orderly” really means

To avoid ambiguity, imagine an arithmetic expression as a tree. Its leaves carry decimal digits. Reading the leaves from left to right gives a digit word. Internal nodes perform arithmetic operations. Exponentiation deserves one convention: in $2^7$, both $2$ and the exponent digit $7$ occur as leaves, so the leaf word is $27$. Unary minus contributes no digit of its own.

Decimal concatenation is also allowed. If an expression $E$ is followed by a $k$-digit expression $F$, their concatenation has value

$$
10^k E+F.
$$

The width $k$ must agree with the number of decimal places reserved for the right-hand expression. This matters because leading zeroes and variable widths can otherwise make concatenation ambiguous.

A positive integer $N$ is called an **orderly Friedman number** here when there is such an expression satisfying four conditions:

1. its leaves, read from left to right, are exactly the decimal digits of $N$;
2. the expression evaluates to $N$;
3. every concatenation uses the correct width; and
4. at least one genuine arithmetic operation occurs, so simply concatenating the original digits is not accepted.

This last condition keeps the game honest. Without it, every positive integer would certify itself by doing nothing.

There is a basic place-value identity behind everything that follows. If $x$ and $y$ are digit words, and $V(x)$ denotes the integer represented by a word, then

$$
V(xy)=V(x)10^{|y|}+V(y),
$$

where $|y|$ is the length of $y$. This is the algebraic meaning of putting one decimal block after another.

## A seed that can be copied

Return to

$$
127=-1+2^7.
$$

Now place two copies of the three-digit block side by side. Numerically, this gives $127127$. On the expression side, place two copies of the certificate side by side as well:

$$
(-1+2^7)\Vert	riangleright	hinspace(-1+2^7),
$$

where the symbol indicates decimal concatenation of two evaluated three-digit expressions. The result is

$$
1000igl(-1+2^7igr)+igl(-1+2^7igr)=127127.
$$

The leaves are $1,2,7,1,2,7$, precisely the digits of $127127$ in order. Each copy already contains genuine arithmetic, and joining copies does not disturb their internal order.

Repeat again and obtain $127127127$. Continue indefinitely. Define $F_0=127$ and

$$
F_{n+1}=1000F_n+127.
$$

The multiplication by $1000$ shifts the existing numeral three places to the left; adding $127$ fills the new final block. Thus

$$
F_0=127,
\qquad F_1=127127,
\qquad F_2=127127127,
$$

and in general $F_n$ is the decimal word $127$ repeated $n+1$ times.

### Repeated-Certificate Theorem

**For every nonnegative integer $n$, the number $F_n$ is an orderly Friedman number.**

The proof follows the construction. Begin with the valid certificate $-1+2^7$. At each stage, concatenate one more copy on the right using width $3$. The leaf word gains exactly the digits $1,2,7$ at its end. The place-value identity shows that the evaluated expression changes from $F_n$ to $1000F_n+127=F_{n+1}$. Correct widths and nontrivial arithmetic persist. Induction completes the argument.

This theorem does more than exhibit a long list. Because the sequence is strictly increasing, it provides infinitely many pairwise distinct orderly Friedman numbers.

## Turning repetition into a formula

The recurrence is an affine geometric process. Multiply it by $999=1000-1$, or simply sum the geometric series, and obtain the exact identity

$$
999F_n=127igl(1000^{n+1}-1igr).
$$

Equivalently,

$$
F_n=127\frac{1000^{n+1}-1}{999}.
$$

The quotient is an integer because

$$
\frac{1000^{n+1}-1}{999}=1+1000+1000^2+\cdots+1000^n.
$$

This is a repunit, not in base $10$ but in base $1000$. Multiplying it by $127$ writes $127$ into each three-digit “superdigit” position. The decimal repetition is therefore a geometric series wearing a typographical disguise.

The formula immediately gives a divisibility law:

$$
1000^{n+1}-1\mid 999F_n.
$$

It also gives a suffix law:

$$
F_n\equiv127\pmod{1000}.
$$

Every member ends in the same certified block. This is visible from the decimal notation, but the recurrence explains it algebraically: all earlier information is multiplied by $1000$, leaving only the added $127$ modulo $1000$.

## Exactly how fast does the family grow?

The closed form makes the scale transparent. The dominant part of $F_n$ is

$$
\frac{127}{999}1000^{n+1}.
$$

A sharp integer sandwich is

$$
126\cdot1000^{n+1}<999F_n<127\cdot1000^{n+1}.
$$

The right inequality follows because $1000^{n+1}-1<1000^{n+1}$. For the left, the gap of one unit inside the parentheses is tiny compared with the power: for $1000^{n+1}>1$,

$$
127igl(1000^{n+1}-1igr)>126\cdot1000^{n+1}.
$$

Thus the family grows on the order of $1000^{n+1}$, with leading constant $127/999$.

Even the normalized error is exact:

$$
\frac{127}{999}-\frac{F_n}{1000^{n+1}}
=
\frac{127}{999\cdot1000^{n+1}}.
$$

So the normalized values approach $127/999$ geometrically, losing a factor of $1000$ with each additional block. There is no mysterious fluctuation: the entire error is the missing final $1$ in the geometric-series numerator.

This is a miniature example of a broad mathematical theme. Repetition of a finite word becomes an affine dynamical system; the affine system becomes a geometric series; and the geometric series supplies congruences, divisibility, and asymptotics all at once.

## Two warnings hidden in the data

Patterns in a list can be seductive, and two elementary checks prevent overreach.

First, orderly Friedman numbers are not necessarily odd. The certificate

$$
736=7+3^6
$$

uses the digits $7,3,6$ in order, and $736$ is even. Any conjecture that all orderly Friedman numbers are odd fails immediately.

Second, the displayed collection

$$
127,343,736,1285,2187,2502,2592,2737,3125,3685,3864,3972,
4096,6455,11264,11664,12850,13825,14641,155
$$

is not strictly increasing: the final $155$ follows $14641$. That does not say that $155$ lacks an orderly representation; it says only that this displayed ordering cannot be treated as an increasing prefix. A transcription, truncation, or ordering issue must be resolved before drawing conclusions from positions in the list.

These checks illustrate a useful discipline. A constructive theorem should be separated from claims suggested merely by presentation. The repeated-$127$ family rests on explicit identities and survives independently of how any external list is ordered.

## An algorithm hiding in plain sight

To compute $F_n$, one may iterate the recurrence $n$ times. Starting from $127$, replace the current value $x$ by $1000x+127$. This uses $O(n)$ arithmetic steps and produces the numeral one block at a time.

For large $n$, the closed form supports exponentiation by squaring. Compute $1000^{n+1}$ in $O(\log n)$ multiplications and evaluate

$$
F_n=127\frac{1000^{n+1}-1}{999}.
$$

The integers themselves have $3(n+1)$ decimal digits, so bit complexity must also account for growing operands. Still, the two methods reflect complementary viewpoints: recurrence is best for streaming successive terms, while the closed form is best for random access to a distant term.

A verifier for this particular family can check several independent signatures. It can compare against the repeated decimal word, test the recurrence, verify the closed-form identity without division, check the suffix congruence, and confirm that the repeated expression evaluates block by block. Agreement among these views makes numerical experiments transparent and robust.

## What has—and has not—been solved

The construction proves an infinite-family theorem, not a classification of all orderly Friedman numbers. It does not provide an asymptotic count of every such number below a bound, nor does it show that most Friedman numbers are orderly. Instead, it isolates a closure mechanism: a certified decimal block can sometimes be repeated without losing either digit order or arithmetic validity.

That mechanism suggests a wider program. If a positive $k$-digit block $b$ has an orderly certificate, then repeating it should lead to

$$
G_0=b,
\qquad G_{n+1}=10^kG_n+b,
$$

and hence

$$
(10^k-1)G_n=bigl(10^{k(n+1)}-1igr).
$$

The block $127$ demonstrates every moving part: syntax, evaluation, width, recurrence, and growth. The challenge is to identify general hypotheses under which repetition always preserves a nontrivial certificate, then to combine several blocks so that the number of constructions branches rather than merely marches along one ray.

That is where a playful numeral puzzle begins to touch combinatorics on words, automata, symbolic dynamics, and analytic counting. A decimal string is not just notation. Under the right arithmetic rules, it is a reusable program—and $127$ is a program that can copy itself forever.
