# The Hidden Symmetry in Carrying the One

## A puzzle hiding in plain sight

Take any whole number and write it in binary — the language of `0`s and `1`s
that computers speak. Now count how many `1`s appear. That count has a name:
the **binary digit sum**, written $s_2(n)$. For example, $13$ in binary is
$1101$, so $s_2(13) = 3$. The number $8$ is $1000$, so $s_2(8) = 1$.

This humble counting function hides a surprising amount of structure, and one
particular question about it has resisted mathematicians for decades. Fix a
"shift" $t$ — say $t = 1$, or $t = 5$, or $t = 1000$. Now scan through all the
whole numbers $n = 0, 1, 2, 3, \dots$ and ask, for each one, a simple yes/no
question:

> When I add $t$ to $n$, does the number of binary `1`s go **up or stay the
> same**? In symbols: is $s_2(n+t) \ge s_2(n)$?

Sometimes the answer is yes, sometimes no. Adding can flip many `1`s to `0`s
through a cascade of carries (think of $0111 + 1 = 1000$: four ones collapse to
one). But it can also create new `1`s. The natural question is: **how often is
the answer yes?**

More precisely, what fraction of all numbers satisfy $s_2(n+t) \ge s_2(n)$? This
limiting fraction is called the **Cusick density**,

$$c_t = \lim_{N \to \infty} \frac{1}{N}\,\#\{\, 0 \le n < N : s_2(n+t) \ge s_2(n)\,\}.$$

In 2011 Thomas Cusick conjectured something clean and bold: **for every shift
$t \ge 1$, the density $c_t$ is strictly greater than one half.** Adding $t$
is, ever so slightly, more likely to preserve or raise your digit count than to
lower it. The bias is real, but it is subtle, and proving it in general is
genuinely hard.

This article tells the story of a piece of that puzzle that can be nailed down
**exactly** — not approximately, not "for large $N$," but with a clean closed
form — and of a beautiful self-similarity that makes it possible.

## Why "more than half" is not obvious

A first instinct is that addition should be perfectly balanced: surely going up
is just as likely as going down? But that intuition is wrong, and the reason is
the *asymmetry of carrying*.

Here is the key fact, a 19th-century gem due to Ernst Kummer. When you add $n$
and $t$ in binary, count the number of **carries** that ripple through the
addition. Call that count $\text{carries}(t, n)$. Then the digit sums obey an
exact bookkeeping law:

$$s_2(n+t) + \text{carries}(t,n) = s_2(n) + s_2(t).$$

In words: the digits you *would* have had if addition were carry-free,
$s_2(n) + s_2(t)$, get reduced by exactly one for every carry. Each carry
destroys one net `1`.

Rearranging, the Cusick question $s_2(n+t) \ge s_2(n)$ becomes a question about
carries alone:

$$s_2(n+t) \ge s_2(n) \quad\Longleftrightarrow\quad \text{carries}(t,n) \le s_2(t).$$

So the whole problem is really: *"How often does adding $t$ to $n$ produce no
more than $s_2(t)$ carries?"* Cusick's conjecture says: more than half the time.

This reformulation is more than cosmetic. It connects the digit sum to one of
the oldest theorems in number theory. Kummer's theorem says that the number of
carries when adding $n$ and $t$ in base $2$ equals the power of $2$ dividing the
binomial coefficient $\binom{n+t}{t}$. So the carry count is literally a
2-adic valuation:

$$\text{carries}(t,n) = v_2\!\left(\binom{n+t}{t}\right).$$

A question about counting `1`s in binary has quietly turned into a question about
the divisibility of binomial coefficients by powers of two.

## The simplest shift, solved completely

Start with the easiest case, $t = 1$. Adding one in binary flips a trailing run
of `1`s to `0`s and turns the first `0` into a `1`. The number of carries is
exactly the length of that trailing run of `1`s — equivalently, the power of two
dividing $n+1$.

Working this out, the Cusick condition for $t = 1$ has a startlingly simple
description:

$$s_2(n) \le s_2(n+1) \quad\Longleftrightarrow\quad n \bmod 4 \ne 3.$$

That is: the inequality **fails only when $n$ ends in $\dots 11$ in binary**
(the residues $3, 7, 11, 15, \dots$), because then adding $1$ triggers at least
two carries and wipes out a net digit. For the other three residues mod $4$, the
digit count holds or climbs.

Three out of every four numbers pass. So we can compute the density on the nose:
out of every block of $4m$ consecutive integers, **exactly $3m$ of them satisfy
the inequality**. Therefore

$$c_1 = \frac{3}{4} = \frac{1}{2} + \frac{1}{4}.$$

Not just "bigger than a half" — bigger by a clean quarter. This is an exact
theorem, valid for every block size, not a numerical approximation.

## The magic trick: doubling invariance

Now comes the part that turns one solved case into infinitely many. It rests on
two almost childishly simple observations about what happens when you append a
bit to the end of a binary number.

Appending a `0` (which doubles the number) does not change the digit sum:

$$s_2(2n) = s_2(n).$$

Appending a `1` (doubling and adding one) raises the digit sum by exactly one:

$$s_2(2n+1) = s_2(n) + 1.$$

These are obvious once you picture the binary strings — but watch what they do
to the Cusick question. Suppose we *double both* the number and the shift,
sending $(n, t) \mapsto (2n, 2t)$. Then for the even numbers,

$$s_2(2n) \le s_2(2n + 2t) \quad\Longleftrightarrow\quad s_2(n) \le s_2(n+t),$$

because both sides just had a trailing `0` appended and nothing changed. And for
the odd numbers $2n+1$, the same shift $2t$ gives

$$s_2(2n+1) \le s_2(2n+1 + 2t) \quad\Longleftrightarrow\quad s_2(n) \le s_2(n+t),$$

because both sides gained a `1` in the same place — the $+1$ cancels. **Both
parity classes collapse onto the very same question at $(n, t)$.**

This is the heart of the matter, and it has a striking consequence for counting.
Define the finite tally

$$\text{cusickCount}(t, N) = \#\{\, n < N : s_2(n) \le s_2(n+t)\,\}.$$

Splitting the window $[0, 2N)$ into its even and odd halves, and using the two
equivalences above, every solution in the doubled problem corresponds to a
solution in the original — twice over. The result is an exact self-similarity:

$$\text{cusickCount}(2t,\ 2N) = 2 \cdot \text{cusickCount}(t,\ N).$$

Doubling the shift and the window simply doubles the count. The pattern is a
fractal: the Cusick statistics for $2t$ are a scaled copy of those for $t$.

## Infinitely many exact densities for free

Iterate the doubling. Starting from $t = 1$ and applying the rule $k$ times
carries us to the shift $t = 2^k$, and the self-similarity stacks up:

$$\text{cusickCount}(2^k,\ 2^{k+2} \cdot m) = 3 \cdot 2^k \cdot m.$$

Read that as a density. The window has size $2^{k+2}m = 4 \cdot (2^k m)$, and the
count is $3 \cdot 2^k m$, which is exactly three quarters of the window. So for
**every** power of two,

$$c_{2^k} = \frac{3}{4} = \frac{1}{2} + \frac{1}{4}.$$

One exact computation at $t = 1$, propagated by symmetry, yields an entire
infinite family of exact densities — at $t = 1, 2, 4, 8, 16, \dots$ — each
sitting a full quarter above one half. No approximations, no limits left dangling.

There is even a clean pointwise rule, the natural big sibling of the $t=1$
criterion $n \bmod 4 \ne 3$. For the shift $2^k$:

$$s_2(n) \le s_2(n + 2^k) \quad\Longleftrightarrow\quad \left\lfloor n / 2^k \right\rfloor \bmod 4 \ne 3.$$

In plain terms: ignore the bottom $k$ bits of $n$, then apply the $t=1$ rule to
what remains. The structure of the simplest case is preserved exactly under
doubling.

## Where the bias lives, and why the rest is hard

This circle of ideas does more than settle the powers of two. It also reveals
*where the difficulty hides* in the general conjecture.

The doubling argument shows that $c_t$ depends only on the **odd part** of $t$:
multiplying $t$ by two leaves the density untouched. So the entire mystery is
concentrated in odd shifts. And among odd shifts, the controlling quantity is
$s_2(t)$, the number of `1`s in $t$ itself.

When $t$ is a power of two, $s_2(t) = 1$, only one `1`, and the doubling symmetry
alone pins the density to a single rational number, $3/4$. But as soon as $t$ has
two or more `1`s in its binary expansion, doubling no longer forces a unique
answer, and a genuinely harder analysis — transfer operators and finite-state
automata tracking carry patterns — takes over. The general conjectured bound,

$$c_t \ge \frac{1}{2} + 2^{-(2 s_2(t) + 1)},$$

shrinks geometrically as $t$ acquires more `1`s, and the proved cases sit
comfortably above it: $c_{2^k} = 3/4 \ge 1/2 + 1/8$, with room to spare.

The carry reformulation also tells us, gently, that the good set is never empty.
Placing a single fresh high bit far above $t$ never triggers a carry, so the
numbers $n = 2^{j+t}$ always satisfy the inequality. Hence for *every* shift $t$,
infinitely many $n$ obey $s_2(n) \le s_2(n+t)$ — a modest but unconditional
foothold on the full conjecture.

## The bigger picture

There is something quietly delightful about how the argument flows. A question
about the digits of numbers becomes a question about carries; carries become
2-adic valuations of binomial coefficients via Kummer; and then a pair of
one-line facts about appending bits unlocks a fractal self-similarity that turns
a single computation into an infinite family of exact results.

Digit sums are not an idle curiosity. They govern the efficiency of arithmetic
circuits, appear in the analysis of random number generators and pseudorandom
sequences, and connect to deep questions in analytic number theory about how
"independent" the binary digits of $n$ and $n+t$ really are. Cusick's conjecture
is, at bottom, a precise statement that addition has a small but persistent
preference: carrying destroys digits, but not quite often enough to win.

The powers of two now sit fully understood, $3/4$ exactly, with their bias of a
clean quarter. The odd shifts with many `1`s still guard their secrets. But the
map of where the difficulty lives is now drawn — and that, in mathematics, is
very often the first step toward the summit.
