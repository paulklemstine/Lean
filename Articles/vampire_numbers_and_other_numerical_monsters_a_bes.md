# Vampire Numbers and the Modular Curve Hidden in Their Digits

Numbers usually reveal themselves through magnitude, divisibility, or geometry. Vampire numbers reveal themselves through disguise. Their digits appear to be an ordinary decimal string, but the string can be split, rearranged, and transformed into a multiplication that recreates the original number. The smallest example is

$$
1260=21\cdot 60.
$$

The two factors, traditionally called **fangs**, use exactly the digits of the product, with the same multiplicities: one $1$, one $2$, one $6$, and one $0$. Another is

$$
1395=15\cdot 93,
$$

and further examples include $1435=35\cdot41$, $1530=30\cdot51$, $1827=21\cdot87$, $2187=27\cdot81$, and $6880=80\cdot86$.

At first sight this looks like recreational arithmetic: a hunt through digit permutations followed by trial multiplication. Yet the defining condition has an unexpectedly rigid algebraic shadow. Every fang pair, in every positional base, lies on a small modular hyperbola. In base ten, this reduces all possible fang residues to six ordered pairs modulo $9$. If both fangs are prime, only three pairs survive, and their product must be congruent to $4$ modulo $9$.

That hidden curve is the central idea of this story.

## What exactly is a fang pair?

Fix a base $b\ge 2$. Write nonnegative integers in base $b$, retaining every digit with its multiplicity. We say that positive integers $x$ and $y$ form a **base-$b$ fang pair** when the multiset of digits of $xy$ is exactly the union of the digit multisets of $x$ and $y$.

This definition isolates the combinatorial heart of a vampire factorization. It does not impose equal fang lengths, an even number of product digits, or the customary rule excluding two fangs that both end in zero. Those extra conventions are useful for classifying classical vampire numbers, but they play no role in the algebraic phenomenon. The modular restriction comes from digit conservation alone.

A multiset, rather than a set, is essential. The number $1260$ has four digit occurrences. Losing multiplicity would erase the difference between, for example, a number containing one zero and a number containing two zeros. Order, by contrast, is irrelevant: the digits may be permuted.

## Casting out $b-1$

The key observation is an old arithmetic trick in a general costume. If

$$
n=d_0+d_1b+d_2b^2+\cdots+d_rb^r,
$$

then $b\equiv1\pmod{b-1}$, so

$$
n\equiv d_0+d_1+\cdots+d_r\pmod{b-1}.
$$

In decimal this is “casting out nines”: a number and its digit sum have the same residue modulo $9$. In base twelve one casts out elevens; in base two the modulus is $1$, so the statement becomes uninformative but remains valid.

Now suppose $x$ and $y$ are a base-$b$ fang pair. The digits of $xy$ are precisely the digits of $x$ and $y$ combined. Therefore the digit sum of $xy$ equals the digit sum of $x$ plus the digit sum of $y$. Casting out $b-1$ gives

$$
xy\equiv x+y\pmod{b-1}.
$$

Rearranging produces the **Unit-Curve Theorem**:

> **Unit-Curve Theorem.** For every base $b\ge2$ and every base-$b$ fang pair $(x,y)$,
> $$
> (x-1)(y-1)\equiv1\pmod{b-1}.
> $$

The proof is a single algebraic step:

$$
(x-1)(y-1)=xy-x-y+1\equiv1\pmod{b-1}.
$$

A digit permutation has become a point on a modular hyperbola.

## Why “unit curve”?

An integer $u$ is a **unit modulo $m$** when it has a multiplicative inverse modulo $m$, equivalently when $\gcd(u,m)=1$. The equation

$$
(x-1)(y-1)\equiv1\pmod{b-1}
$$

says that $x-1$ and $y-1$ are inverses. Consequently both must be units modulo $b-1$. For positive fangs,

$$
\gcd(x-1,b-1)=\gcd(y-1,b-1)=1.
$$

This has an immediate local consequence. If a prime $p$ divides $b-1$, neither fang can be congruent to $1$ modulo $p$. Indeed, $x\equiv1\pmod p$ would make $p$ divide both $x-1$ and $b-1$, contradicting coprimality. The same applies to $y$.

In decimal, $3$ divides $9$, so neither fang of any decimal fang pair can be $1$ modulo $3$. The smallest example illustrates this: $21\equiv0\pmod3$ and $60\equiv0\pmod3$. The pair $15$ and $93$ also avoids residue $1$.

This sieve is cheap. Before comparing a single digit or multiplying a candidate pair, one may reject every $x$ with $\gcd(x-1,b-1)>1$, and likewise for $y$. The modular curve then determines the residue of one decremented fang as the inverse of the other.

## The six gates in base ten

Modulo $9$, the units are

$$
1,2,4,5,7,8.
$$

Set $u=x-1$ and $v=y-1$. The curve condition is $uv\equiv1\pmod9$. Taking each unit and its inverse, then adding $1$ back to both coordinates, yields exactly six ordered residue pairs:

$$
(x\bmod9,y\bmod9)\in
\{(0,0),(2,2),(3,6),(5,8),(6,3),(8,5)\}.
$$

This is the **Decimal Residue Sieve**. It is a complete classification of the residues permitted by the exact digit-multiset condition. It is necessary, not sufficient: passing through one of the six gates does not guarantee that the digits match. But every genuine decimal fang pair must pass through one.

For $1260=21\cdot60$, the residues are $(3,6)$. For $1395=15\cdot93$, they are $(6,3)$. For $1435=35\cdot41$, they are $(8,5)$. The examples occupy different points on the same curve.

The number of gates is not accidental. For a modulus $m$, every solution of $(X-1)(Y-1)\equiv1\pmod m$ is determined by choosing a unit $X-1$ and taking its unique inverse for $Y-1$. Thus the curve has as many ordered points as there are units modulo $m$, namely Euler’s totient $\varphi(m)$. Establishing and exploiting this count uniformly across bases is a natural next step.

## When both fangs are prime

Prime fangs face a sharper filter. From the six decimal pairs, those containing a coordinate divisible by $3$ are

$$
(0,0),\qquad(3,6),\qquad(6,3).
$$

A prime with residue $0$, $3$, or $6$ modulo $9$ is divisible by $3$, and hence must equal $3$. But substituting that exceptional possibility into the exact curve constraints eliminates these cases. Therefore only three ordered residue pairs remain:

$$
(2,2),\qquad(5,8),\qquad(8,5).
$$

This is the **Prime-Fang Residue Theorem**: if both fangs of a decimal fang pair are prime, their residues modulo $9$ must be one of those three pairs.

Each surviving pair has the same product residue:

$$
2\cdot2\equiv5\cdot8\equiv8\cdot5\equiv4\pmod9.
$$

Hence the **Prime-Fang Product Corollary** states that whenever both decimal fangs are prime,

$$
xy\equiv4\pmod9.
$$

This does not say that every number congruent to $4$ modulo $9$ has prime fangs. It says that a proposed prime-prime fang factorization with any other product residue is impossible. One modular reduction destroys eight ninths of the search space.

## A practical search strategy

A direct search over candidate factors can be organized around the mathematics.

First, choose a base and a numerical bound. For each possible fang $x$, compute $\gcd(x-1,b-1)$. Reject $x$ unless this gcd is $1$. For each survivor, invert $x-1$ modulo $b-1$; this determines the required residue class of $y$. Search only divisors $y$ in that class. Finally, compare sorted digit lists, or more efficiently compare digit-frequency vectors of length $b$.

For fixed numbers, creating a digit-frequency vector takes time proportional to the number of digits. If factor pairs are generated by trial division up to $\sqrt v$, the elementary method costs about $O(\sqrt v\log_b v)$ per product in the worst case. The unit-curve sieve does not change that worst-case exponent, but it removes most residue-incompatible candidates at negligible cost. More sophisticated divisor generation can improve the factoring stage while retaining the same filters.

There is also a visual way to explore the constraint. Draw a $9$ by $9$ grid and mark the six allowed decimal pairs. The sparse pattern makes clear that digit conservation is not merely a decorative condition. It forces arithmetic alignment.

## Monsters not yet classified

The language of a numerical bestiary invites other creatures: “werewolf” factorizations whose factors share a prescribed number of digits with the product, “ghost” factorizations with no shared digits, and “zombie” variants involving primality. These ideas are suggestive, but definitions must come before tables. Does “share exactly one digit” count distinct digit values or occurrences? Is the condition applied to each factor separately or to their combined digits? A proposed prime-based category must also distinguish “both factors prime” from “one prime and one composite.” Those are different predicates and lead to different mathematics.

Likewise, broad density claims remain open. A conjecture that vampire numbers have density comparable to $1/\sqrt n$ requires a precise interval, a precise denominator, and control of the dependence between multiplication, factorization, carries, and digit permutations. Counting permutations alone cannot supply that control. Claims that ghost numbers have density zero or that every large even-length decimal interval contains a vampire number similarly require proofs beyond finite examples.

The unit curve offers a disciplined starting point. It gives upper-bound sieves in every base, identifies forbidden residue classes from every prime divisor of $b-1$, and suggests combining modular restrictions with divisor estimates or finite automata for digit constraints.

## The moral of the bestiary

Vampire numbers are memorable because their factors seem to hide in plain sight. But their deeper lesson is methodological. A combinatorial statement about rearranged symbols can carry an algebraic invariant. Positional notation connects digits to congruences; congruences turn digit conservation into an inverse equation; the inverse equation compresses an enormous search into a finite modular curve.

The smallest vampire, $1260=21\cdot60$, is therefore more than a curiosity. It is one visible specimen of a general phenomenon valid in every base $b\ge2$:

$$
\text{exact conservation of digits}\quad\Longrightarrow\quad
(x-1)(y-1)\equiv1\pmod{b-1}.
$$

Behind the shuffled digits stands a rigid arithmetic skeleton. The monster has bones.