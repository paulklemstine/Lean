# Alien Number Systems: Arithmetic Beyond Base Ten

*By Aristotle — July 22, 2026*

Imagine intercepting a message from another civilization. The signal repeats in crisp pulses, grouped into apparent numerals. Would the senders count by tens because they have ten fingers? By eights because they have eight tentacles? Or might they choose a system for mathematical rather than anatomical reasons—a base that is negative, irrational, or even complex?

Our familiar decimal notation is only one member of a much larger family. In base ten, a word such as $327$ means

$$
3\cdot 10^2+2\cdot 10+7.
$$

The same positional idea survives when the radix is stranger than $10$. Replace $10$ by $-2$, by the golden ratio $\varphi=(1+\sqrt5)/2$, or by the complex number $i-1$, and the powers of the radix trace radically different paths. Yet in each case, tiny local rules can organize an infinite world of numbers.

This story has three branches. Negabinary notation gives every integer a unique signless binary name. Fibonacci notation gives every natural number a unique sum of nonadjacent Fibonacci numbers, tied to base $\varphi$ by a carry law. And the complex base $i-1$ gives every Gaussian integer—a lattice point $a+bi$—a unique signless binary name. Together they show that positional notation is not really about rows of digits. It is about division, remainders, descent, and normalization.

## A minus sign hidden in the radix

A finite negabinary word with digits $d_j\in\{0,1\}$ has value

$$
N=\sum_{j=0}^{k}d_j(-2)^j.
$$

Because successive powers alternate sign, the numeral itself needs no separate minus sign. For example, the ordinary-looking word $110111_{(-2)}$, read with its most significant digit on the left, means

$$
(-2)^5+(-2)^4+(-2)^2+(-2)+1=-32+16+4-2+1=-13.
$$

The first central result is complete.

**Negabinary Representation Theorem.** Every integer $n$ has exactly one finite base-$-2$ expansion with digits $0$ and $1$, provided the zero integer is represented by the empty word and every nonempty word has leading digit $1$.

The qualification about leading zeroes matters. Without it, $11$, $011$, $0011$, and infinitely many padded variants would be different strings for the same value.

Why does an expansion always exist? Given an integer $n$, choose its parity digit $r=n\bmod 2$, where $r$ is either $0$ or $1$. Then define

$$
q=\frac{r-n}{2}.
$$

This rearranges to $n=r+(-2)q$. Thus $r$ is the least significant digit, while $q$ is the integer still to be encoded. Repeating the operation peels off one digit at a time.

The only subtle point is proving that repetition stops. Ordinary size is not enough: starting from $-1$, the next quotient is $1$, so absolute value does not decrease. Instead, order the integers in the interleaved sequence

$$
0,1,-1,2,-2,3,-3,\ldots
$$

and assign the measure

$$
\mu(n)=
\begin{cases}
2n-1,&n>0,\\
-2n,&n\le 0.
\end{cases}
$$

For every nonzero $n$, the quotient $(r-n)/2$ has strictly smaller $\mu$. No infinite descent is possible among natural-number measures, so the algorithm reaches $0$.

Uniqueness is even more revealing. Reducing a base-$-2$ value modulo $2$ destroys all terms except the least significant digit. Therefore parity forces that digit. If two canonical words have the same value, their first digits agree; subtract that common digit and divide by $-2$. The tails then have equal values. Repeating proves equality digit by digit.

This is a recurring pattern: residue extraction determines a local symbol, and descent guarantees that local choices eventually describe the whole number.

## The golden ratio learns to carry

The golden ratio satisfies

$$
\varphi^2=\varphi+1.
$$

Multiplying by $\varphi^n$ gives the carry identity

$$
\varphi^n+\varphi^{n+1}=\varphi^{n+2}
$$

for every natural number $n$. In a binary string indexed by powers of $\varphi$, two adjacent $1$ digits can therefore be replaced by a single $1$ one place farther left. Symbolically, the local pattern $011$ becomes $100$.

The discrete counterpart uses Fibonacci numbers. Let $F_0=0$, $F_1=1$, and $F_{m+2}=F_{m+1}+F_m$. An admissible Fibonacci representation is a sum of distinct Fibonacci numbers $F_j$ with indices $j\ge2$, no two selected indices consecutive.

**Zeckendorf Representation Theorem.** Every natural number has exactly one admissible representation as a sum of nonconsecutive Fibonacci numbers.

For $100$, the unique choice is

$$
100=89+8+3=F_{11}+F_6+F_4.
$$

A greedy algorithm finds it: take the largest Fibonacci number not exceeding the current remainder, subtract it, and continue. If $F_k$ is chosen, the remainder is smaller than $F_{k-1}$; otherwise $F_{k+1}=F_k+F_{k-1}$ would also have fit. Thus the next chosen index cannot be adjacent. For uniqueness, compare the largest selected indices in two admissible sums. All permitted lower, nonadjacent Fibonacci terms sum to less than the larger leading term, so unequal leading indices cannot yield equal totals. Remove the shared leading term and repeat.

The relation with base $\varphi$ is structural rather than a license for an overbroad claim. It is false that every integer can be written using only $0$ and $1$ and only nonnegative powers of $\varphi$. Such sums lie in the ring $\mathbb Z+\mathbb Z\varphi$, and matching an ordinary integer generally requires cancellation involving negative powers or another endpoint convention. What is established without ambiguity is the unique Fibonacci expansion and the exact carry law that makes it the combinatorial shadow of phinary notation.

## A binary system that fills a plane

Now let the radix be $\beta=i-1$. Its powers no longer alternate along a line; multiplication rotates and stretches the complex plane. Remarkably, the same two real digits $0$ and $1$ can name every Gaussian integer $a+bi$, with $a,b\in\mathbb Z$.

A finite word has value

$$
Z=\sum_{j=0}^{k}d_j(i-1)^j,
\qquad d_j\in\{0,1\}.
$$

**Complex Binary Representation Theorem.** Every Gaussian integer has exactly one finite base-$(i-1)$ expansion with digits $0$ and $1$, after leading zeroes are forbidden.

No explicit sign is needed. No imaginary digit is needed. For instance,

$$
11_{(i-1)}=1+(i-1)=i.
$$

To see how digit extraction works, write $z=x+yi$. Multiplication by $i-1$ sends $u+vi$ to

$$
(-u-v)+(u-v)i.
$$

The sum of the resulting coordinates is $-2v$, always even. Consequently the parity of $x+y$ forces the least significant digit $d$. After choosing $d\in\{0,1\}$ with $d\equiv x+y\pmod2$, the quotient $(z-d)/(i-1)$ is again a Gaussian integer. In coordinates it is

$$
\left(\frac{y-(x-d)}{2}\right)
+
\left(-\frac{(x-d)+y}{2}\right)i.
$$

As before, parity proves uniqueness: equal values have the same first digit, cancellation and division expose equal tails, and induction finishes the comparison.

Existence is more delicate. The Gaussian norm $N(x+yi)=x^2+y^2$ usually decreases after extracting a digit, but not always. At $z=i$, the next quotient is $1$, and both have norm $1$. A correct argument isolates five exceptional points,

$$
i,\quad -i,\quad -1,\quad -2+i,\quad -2-i,
$$

which have direct finite expansions. Outside this set and $0$, the quotient has strictly smaller norm. Induction on the norm then constructs an expansion for every lattice point. The exception is not an embarrassment; it is the geometry that a one-dimensional intuition would miss.

## One architecture, three worlds

These systems share a common design.

1. **Evaluation:** a numeral is interpreted by repeated multiplication by a radix and addition of a digit.
2. **Local normalization:** parity or an algebraic relation determines an allowed rewrite.
3. **Termination:** a well-founded measure prevents endless rewriting.
4. **Canonical form:** leading-zero rules and local restrictions remove ambiguity.
5. **Uniqueness:** residues or dominant terms force choices one step at a time.

Ordinary positive bases hide this machinery because division with remainder and absolute-value descent behave so smoothly. Exotic bases make it visible. Negative bases need a signed interleaving measure. Complex bases need lattice geometry and a finite exceptional region. Golden-ratio arithmetic replaces integer remainder classes with an algebraic carry and Fibonacci combinatorics.

There are practical echoes. Signed-digit systems can simplify subtraction in digital circuits. Fibonacci coding supports self-synchronizing data representations. Complex radices turn planar lattice arithmetic into one-dimensional digit streams. More broadly, numeral design becomes an optimization problem: not merely how short a representation is, but how expensive its carries are, how robust its boundaries are, and what geometry its radix naturally follows.

Consider addition. In decimal notation, a carry can ripple through a long run of $9$ digits. In Fibonacci notation, normalization responds to forbidden local patterns; in a negative or complex base, carries can move with the geometry of alternating or rotating powers. The average number of rewrites may matter more to a machine than the number of written digits. One can imagine ranking radices by the stationary behavior of a finite carry process, just as engineers rank codes by error rate or compression ratio.

The complex theorem also changes how we picture a numeral. Ordinary notation lays points from a line into strings. Base $i-1$ lays an entire square lattice into strings while preserving exact arithmetic. A map of representation lengths over the Gaussian plane would show rings, anisotropies, and small irregularities around the five exceptional points. The radix is therefore both an encoding device and a geometric lens.

An alien civilization might still choose base eight or twelve for anatomical reasons. But mathematics offers stranger possibilities. A civilization doing lattice signal processing might find a complex radix natural. One concerned with local rewrite simplicity might favor a Fibonacci system. One seeking signless encoding of positive and negative quantities might choose a negative radix.

The deepest lesson is that a number base is not a fact of nature. It is a coordinate system for arithmetic. Change the coordinate system, and familiar numbers acquire unfamiliar shapes—yet parity, descent, and canonical form continue to guide us home.