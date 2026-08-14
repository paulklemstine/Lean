# The Dial That Knows Everything and Tells You Nothing

## A two-hundred-year-old machine, and a modern hope

In 1801, in the *Disquisitiones Arithmeticae*, Carl Friedrich Gauss did something
that still feels like sleight of hand. He took the humble question *"which whole
numbers can be written as $x^2 + 5y^2$?"* and turned it into a piece of group
theory. Attached to each *discriminant* $D$ — for us, a negative integer such as
$-20$ — there is a finite list of essentially different quadratic expressions
$$Q(x,y) = ax^2 + bxy + cy^2, \qquad b^2 - 4ac = D,$$
and Gauss showed that this finite list carries a *group law*. Multiply a number
represented by one form by a number represented by another, and the product is
represented by a third form, determined by the first two. The group is called
the **class group** $\mathrm{Cl}(D)$, and its size $h(D)$ is the **class number**.

For $D = -20$ there are exactly two forms:
$$P(x,y) = x^2 + 5y^2, \qquad Q(x,y) = 2x^2 + 2xy + 3y^2,$$
and the group is $\mathbb{Z}/2$: $P\cdot P = P$, $P \cdot Q = Q$, $Q\cdot Q = P$.
Numbers of the shape $x^2+5y^2$ times numbers of the shape $x^2+5y^2$ are again
of that shape; but $2x^2+2xy+3y^2$ times $2x^2+2xy+3y^2$ lands you back in
$x^2+5y^2$. That last identity is not obvious. It is Gauss composition, and you
can check it by hand with an explicit bilinear substitution.

Now here is the modern hope, and it is a seductive one.

Take a large number $N = pq$, the product of two unknown primes — the kind of
number the security of a great deal of the internet rests on. Choose a
discriminant $D$ of your own liking, entirely unrelated to $N$. Compute, for each
of the $h(D)$ reduced forms, the number of ways $N$ can be written in that shape:
$$r_D(N) = \Big(\#\{(x,y) : Q_1(x,y)=N\}, \ \ldots, \ \#\{(x,y) : Q_h(x,y)=N\}\Big).$$
This **representation vector** is cheap to compute — you scan a box of size
roughly $\sqrt{N/|D|}$ in one variable, and there is no factoring anywhere in
sight.

And here is the reason for hope. Deep theory says which prime $p$ falls into
which class, and that assignment is governed by the Legendre symbol $(D/p)$ —
a property of $p$, not of $N$. The class of $N = pq$ should be the *product*
$[\mathfrak p]\cdot[\mathfrak q]$ of the two prime classes. Different
factorizations of the same size, one would think, should produce different
class products. If the vector could distinguish a semiprime whose two primes are
both "principal" from one whose two primes are both "non-principal", you would
have extracted, for free, something about the factors of $N$ from a computation
that never factored $N$.

This article is about why that hope is not merely unfulfilled but *provably*
empty — and about the precise place where the proof stops working, which turns
out to be the most interesting part of the story.

## The dial

Let us look at $D=-20$ concretely. Restrict to integers $N$ coprime to $20$.
A short finite check — there are only $20 \times 20$ residue pairs to try — shows:

> **Genus separation at $D=-20$.** If $N$ is coprime to $20$ and
> $N = x^2+5y^2$, then $N \equiv 1$ or $9 \pmod{20}$. If $N$ is coprime to $20$
> and $N = 2x^2+2xy+3y^2$, then $N \equiv 3$ or $7 \pmod{20}$.

The two residue sets $\{1,9\}$ and $\{3,7\}$ are **disjoint**. That single word
is the whole story. Disjointness means that *at most one* of the two forms can
ever represent a given $N$ coprime to $20$, and — more damningly — that which one
it is can be read off from $N \bmod 20$ alone. You do not need $N$; you need two
digits of $N$.

I will call such a configuration a **residue dial**. Abstractly: a family of
"is represented by class $i$" predicates on the integers, together with sets
$S_i$ of residues modulo $m$, such that every value of class $i$ coprime to $m$
lands in $S_i$, and the $S_i$ are pairwise disjoint. From those two axioms —
*soundness* and *disjointness* — everything follows mechanically:

> **Factor-blindness.** In any residue dial, if $N$ and $M$ are coprime to $m$
> and $N \equiv M \pmod m$, and $N$ is represented by class $i$ while $M$ is
> represented by class $j$, then $i = j$.

There is even an explicit function $\mathbb{Z}/m \to \{\text{classes}\}$ — the
*readout* — that the whole observation factors through. The vector is a dial
with $m$ positions, and $N$ turns it only through $N \bmod m$.

So the answer to the question "does $r_{-20}(N)$ know anything about the factors
of $N$?" is: it knows exactly as much as $N \bmod 20$ knows, which is nothing.
The information the dial reports was already sitting in the last two digits.

## The collision, made concrete

Abstractions are convincing; collisions are visceral. Consider

- $21 = 3 \cdot 7$. Both $3$ and $7$ are represented by the *non-principal* form
  ($3 = 2\cdot 0^2 + 2\cdot 0\cdot 1 + 3\cdot 1^2$, $7 = 2 + 2 + 3$). Call this
  an **NN** semiprime.
- $1189 = 29 \cdot 41$. Both $29 = 3^2 + 5\cdot 2^2$ and $41 = 6^2 + 5\cdot 1^2$
  are represented by the *principal* form. A **PP** semiprime.

These are utterly different factorization types. And yet:
$$r_{-20}(21) = (8,\,0), \qquad r_{-20}(1189) = (8,\,0).$$
Both are $8$ in the first slot, $0$ in the second — identical. ($21 = 1^2+5\cdot2^2 = 4^2+5\cdot1^2$
and their sign flips give eight pairs; and $1189 = 28^2 + 5\cdot 9^2 = 8^2 + 5\cdot 15^2$,
again eight.) The mixed case is visible only because it, too, is a residue fact:
$87 = 3 \cdot 29$ has one factor in each class, so
$$r_{-20}(87) = (0,\,8),$$
and indeed $87 \equiv 7 \pmod{20}$ while $21 \equiv 1$ and $1189 \equiv 9$.

The structural reason is a one-line piece of group theory that deserves to be
underlined. Encode "principal" as $0$ and "non-principal" as $1$; the dial bit
$\delta$ is then a homomorphism from the multiplicative group of allowed
residues $\{1,3,7,9\} \bmod 20$ to $\mathbb{Z}/2$:
$$\delta(ab) = \delta(a) \oplus \delta(b).$$
The observation is a **character**. And a character is blind to squares:
$\delta(a\cdot a) = \delta(a)\oplus\delta(a) = 0$, whatever $a$ was. A semiprime
$N=pq$ whose two primes share a class is, from the character's point of view, a
square — and every square looks like $1$. PP and NN are both invisible for the
same reason, and no cleverness applied to $r_{-20}$ can fix it.

## Bigger class groups do not help

Perhaps two classes is simply too few. Take $D = -84$, where there are four:
$$f_1 = x^2+21y^2,\quad f_2 = 2x^2+2xy+11y^2,\quad f_3 = 3x^2+7y^2,\quad f_4 = 5x^2+4xy+5y^2,$$
and the class group is the Klein four-group $(\mathbb{Z}/2)^2$. Again a finite
check settles the residues: modulo $84$, the four classes occupy the disjoint sets
$$\{1,25,37\},\quad \{11,23,71\},\quad \{19,31,55\},\quad \{5,17,41\},$$
so the same dial mechanism applies verbatim. Every class squares to the
principal one, and therefore *three* distinct factorization types now collapse
into a single observation: semiprimes built from two $f_2$-primes, from two
$f_3$-primes, and from two $f_4$-primes are all reported as "represented by
$x^2+21y^2$ and by nothing else". Concretely,
$$253 = 11 \cdot 23 \ (f_2 \cdot f_2), \qquad 589 = 19\cdot 31 \ (f_3\cdot f_3),$$
both congruent to $1$ modulo $84$, both with representation vector $(8,0,0,0)$.
More classes bought more collisions, not fewer.

## Nor does stacking discriminants

The next instinct is amplification: if one discriminant leaks nothing, use ten.
Concatenate $r_{D_1}(N), \ldots, r_{D_k}(N)$ into one long vector and hope the
joint reading separates what no single reading could.

It cannot, and the reason is a closure property so clean it feels like cheating:

> **Dials tensor.** If $d_1$ is a residue dial modulo $m_1$ and $d_2$ is a
> residue dial modulo $m_2$, then the joint observation
> $N \mapsto (\text{class of } N \text{ for } d_1, \ \text{class of } N \text{ for } d_2)$
> is a residue dial modulo $m_1 m_2$.

Soundness is inherited by reducing modulo each factor; disjointness holds because
two distinct joint indices must differ in *some* coordinate, and that coordinate's
sets were already disjoint. So the stacked observation is still a function of a
single residue — now $N \bmod m_1m_2$ — and factor-blindness applies to the whole
family at once. Stack $D=-20$ (two classes) on $D=-84$ (four classes) and you get
a dial of modulus $1680$ with eight index positions — only four of which are ever
occupied, since $\gcd(20,84) = 4$ forces the two readings to agree mod $4$. The PP/NN collision survives
untouched. It confuses $109 \cdot 421$ with $23 \cdot 107$, since $109$ and $421$
are principal for both discriminants while $23$ and $107$ are non-principal for
both. The extrinsic corner collapses all at once, not one discriminant at a time.

There is even an exact accounting of the loss. In any finite group $G$, the set
of pairs $(g_1,g_2)$ with $g_1 g_2 = c$ has exactly $|G|$ elements — pick $g_1$
freely and $g_2$ is forced. So an observation that reports only the product of
the two prime classes is exactly $|\mathrm{Cl}(D)|$-to-one on pairs: two
factorization types for $D=-20$, four for $D=-84$. At most $\log_2 |\mathrm{Cl}(D)|$
bits about the pair $([\mathfrak p],[\mathfrak q])$ survive — and those bits, as
we saw, are already determined by $N \bmod |D|$.

## Where the dial breaks

Here the story turns. Everything above rested on disjointness of residue sets,
and disjointness is not a theorem about class groups — it is a theorem about
*genus theory*, the part of the class group visible in congruences. The two
discriminants above share a special property: **one class per genus**. Each class
is cut out by congruence conditions alone. That is a rare and classical
phenomenon (these are the *idoneal*-type discriminants; Euler tabulated them,
and only finitely many are believed to exist).

Go to $D = -23$, where the class number is $3$ and there is a *single* genus, and
the machinery visibly dies. The forms are
$$P_{23} = x^2+xy+6y^2, \qquad Q_{23} = 2x^2+xy+3y^2$$
(the third is $Q_{23}$'s mirror image). A finite check modulo $23$ gives:

> **No genus separation at $D=-23$.** For every residue $a$ modulo $23$, $a$ is
> a value of $x^2+xy+6y^2$ modulo $23$ if and only if it is a value of
> $2x^2+xy+3y^2$ modulo $23$.

The residue sets are not merely overlapping — they are *equal*. Congruences see
nothing at all. And this is not a failure of bookkeeping; representability
genuinely is not a residue condition:
$$59 \equiv 13 \pmod{23}, \qquad 59 = 5^2 + 5\cdot 2 + 6\cdot 2^2, \qquad 13 = 2\cdot 2^2 + 2 + 3\cdot 1^2,$$
while $13$ is *not* of the form $x^2+xy+6y^2$ at all (rewrite $4\cdot 13 = (2x+y)^2 + 23y^2$,
which forces $|y|\le 1$ and $|x| \le 4$; a finite search closes the case). Two
integers with the same residue modulo $23$, both coprime to $23$, in *different*
classes. Therefore no residue dial modulo $23$ can contain both forms: the
abstract mechanism has a genuine boundary, and $-23$ is on the far side of it.

## What this actually means

It is tempting to read the failure at $-23$ as an opening. It is better read as a
conservation law. For discriminants where the representation vector is cheap to
compute, it is a residue dial and therefore useless. For discriminants where it
is not a residue dial — where the classes truly separate arithmetic that
congruences cannot see — computing which class contains $N$ is no longer a
residue computation. It is a question about how $N$ splits in the Hilbert class
field of $\mathbb{Q}(\sqrt{D})$, a non-abelian object over $\mathbb{Q}$, and no
polynomial-time method for it is known that does not go through factoring $N$
first.

That is the dichotomy the work above makes precise, and the conjecture it
suggests: *readable if and only if idoneal*. The residue dial is the abelianized,
ramified shadow of the class field. Everything the dial shows you was written on
$N$'s last few digits; everything else is hidden behind the same wall as
factoring itself.

Gauss's group law is a genuinely deep structure, and it does know which class
each prime belongs to. It simply refuses to tell you separately. It tells you
the product — and a product, in a group where everything squares to the
identity, is a very quiet thing to be told.
