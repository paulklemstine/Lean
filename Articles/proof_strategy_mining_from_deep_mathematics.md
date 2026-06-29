# The Hidden Skeleton of a Proof

## How one idea quietly powers Fibonacci numbers, Mersenne primes, and the deepest theorems in number theory

Every great proof tells a story. But buried inside that story — beneath the
clever substitution, the surprising lemma, the moment where everything clicks —
there is usually a *skeleton*: a structural pattern that does the real work. The
characters change from theorem to theorem, but the skeleton stays the same.
Mathematicians feel this in their bones. They say things like "this is just a
descent argument" or "that's a pigeonhole in disguise." What they rarely do is
write the skeleton down as a precise object that can be reused, instantiated, and
checked.

This article is about doing exactly that for one famous skeleton: the
**primitive divisor argument**. It is the engine behind Carmichael's theorem on
Fibonacci numbers, behind Zsygmondy's theorem on $a^n - 1$, and behind a
surprising amount of elementary number theory that looks, on the surface, to be
about completely different objects. We will extract that skeleton, state it once
in full generality, and then watch it snap into place across two famous families
of numbers — the Fibonacci sequence and the Mersenne-type sequence $a^n - 1$ —
with no extra work.

## A puzzle about Fibonacci numbers

Start with the Fibonacci numbers, the sequence everyone knows:

$$F_0 = 0,\quad F_1 = 1,\quad F_2 = 1,\quad F_3 = 2,\quad F_4 = 3,\quad F_5 = 5,\quad F_6 = 8,\quad F_7 = 13,\dots$$

Now ask a deceptively simple question. Pick a prime number, say $p = 11$. Where
does $11$ first show up as a divisor of a Fibonacci number?

$$F_1 = 1,\ F_2 = 1,\ F_3 = 2,\ \dots,\ F_{10} = 55 = 5\cdot 11.$$

So $11$ first divides $F_{10}$. The interesting fact is what happens next: $11$
divides $F_n$ **exactly when** $10$ divides $n$. Not approximately, not usually —
exactly. The prime $11$ has a kind of "home base" at index $10$, and it visits a
Fibonacci number precisely at the multiples of that home base.

This home base has a classical name: the **rank of apparition** of $p$, the
smallest positive index $n$ with $p \mid F_n$. The remarkable law is that the set
of indices where $p$ appears is *completely determined* by this one number:

$$p \mid F_n \iff (\text{rank of } p) \mid n.$$

A messy infinite condition — "$p$ divides the $n$-th Fibonacci number" — collapses
into a single divisibility check between two ordinary integers.

A prime is called a **primitive divisor** of $F_n$ when $F_n$ is the *first*
Fibonacci number it divides; that is, $n$ is the rank of $p$. Carmichael's theorem
(1913) says that, with a tiny list of exceptions, every Fibonacci number $F_n$ has
such a primitive divisor — a prime making its very first appearance. This is a deep
and useful fact. But the question that drives this work is not *whether* it is
true. It is: **what is the argument actually made of?**

## The same trick, wearing a different costume

Now forget Fibonacci numbers entirely and look at a different sequence:

$$u_n = a^n - 1$$

for a fixed base $a$. With $a = 2$ these are the numbers $1, 3, 7, 15, 31, 63,
127, \dots$, one less than a power of two — the **Mersenne numbers**, whose primes
have been hunted for centuries.

Ask the same question. Pick a prime $p$ not dividing $a$. Where does it first
divide some $a^n - 1$? The answer is governed by the **multiplicative order** of
$a$ modulo $p$ — the smallest $n$ with $a^n \equiv 1 \pmod p$. And once again you
get the identical law:

$$p \mid a^n - 1 \iff (\text{order of } a \bmod p) \mid n.$$

The same collapse. The same "home base." The same primitive-divisor story, which
here is Zsygmondy's theorem: for almost all $n$, the number $a^n - 1$ has a prime
factor that divides no earlier term.

Two sequences. Two famous theorems. Two different-looking proofs in the
textbooks — one about Fibonacci's recurrence, one about modular orders. And yet
the *shape* of the argument is identical. That is not a coincidence. It is a sign
that we are looking at the same skeleton through two different costumes.

## Finding the one true hypothesis

Here is the central move of this project, and it is the move at the heart of
"proof strategy mining": go through the Fibonacci argument line by line and ask,
for each step, *what property of the Fibonacci numbers did I actually use?*

When you do this honestly, something striking happens. You never use the
recurrence $F_{n} = F_{n-1} + F_{n-2}$. You never use Binet's golden-ratio
formula. You use exactly **one** fact, over and over:

$$\gcd(F_m, F_n) = F_{\gcd(m, n)}.$$

The greatest common divisor of two Fibonacci numbers is the Fibonacci number at
the greatest common divisor of their indices. This single, elegant identity is the
load-bearing wall of the entire building.

And — here is the punchline — the sequence $a^n - 1$ satisfies the *very same
identity*:

$$\gcd(a^m - 1,\ a^n - 1) = a^{\gcd(m,n)} - 1.$$

So we give the property a name. Call a sequence $u_0, u_1, u_2, \dots$ of natural
numbers a **strong divisibility sequence** if

$$\gcd(u_m, u_n) = u_{\gcd(m,n)} \quad\text{for all } m, n.$$

Both Fibonacci and $a^n - 1$ are strong divisibility sequences. And it turns out
that *every* step of the primitive-divisor argument can be carried out using only
this one hypothesis — nothing else. The skeleton, written down at last, is a
theory of strong divisibility sequences. The two famous theorems are just two
places where you hang the same coat.

## The skeleton, stated plainly

Let me state the mined results in their general form, for an arbitrary strong
divisibility sequence $u$. Each is a precise theorem; together they *are* the
skeleton.

**1. Strong implies weak.** If $m$ divides $n$, then $u_m$ divides $u_n$. (The
gcd identity instantly gives the simpler "divisibility sequence" property as a free
corollary.)

**2. The meet law.** For *any* candidate divisor $d$,
$$d \mid u_{\gcd(m,n)} \iff d \mid u_m \ \text{and}\ d \mid u_n.$$
This is the lattice-theoretic heart: divisibility into the sequence respects
greatest common divisors exactly.

**3. Primitivity is rigid.** Call $p$ a *primitive divisor* of $u_n$ if $p \mid
u_n$ but $p$ divides none of $u_1, \dots, u_{n-1}$. Then a given number can be a
primitive divisor for **at most one** positive index. There is no ambiguity about
where a prime "belongs."

**4. The pinning law.** If $p$ is a primitive divisor of $u_n$, then
$$p \mid u_m \iff n \mid m.$$
This is the abstract form of the Fibonacci and Mersenne laws above. Once a prime
has a home base $n$, it appears exactly at the multiples of $n$. The infinite
appearance pattern is pinned down by a single integer.

**5. The join law (simultaneous apparition).** If $p$ is primitive for $u_a$ and
$q$ is primitive for $u_b$, then both divide $u_n$ together exactly when
$$\operatorname{lcm}(a, b) \mid n.$$
Two primes synchronize their appearances at the least common multiple of their
home bases — and this extends to any finite family of primes at once.

**6. Density of appearances.** Among the first $N$ indices, a primitive divisor of
$u_n$ appears at exactly $\lfloor N/n \rfloor$ of them. Its natural density is
precisely $1/n$. Two primes with home bases $a$ and $b$ co-appear with density
$1/\operatorname{lcm}(a,b)$. The order-theoretic law has a clean quantitative
shadow.

None of these six statements mentions Fibonacci numbers, golden ratios, modular
orders, or Mersenne primes. They mention only "a strong divisibility sequence."
That is the skeleton, fully exposed.

## Manufacturing the home base

There is one more refinement worth telling, because it turns the theory from a
collection of facts into a genuine *tool*. The pinning law (#4) requires you to
already know a primitive index $n$ for $p$ — to be handed the home base. But the
home base can be *manufactured* from $p$ alone.

Define the **rank of apparition** of $p$ in the sequence $u$ to be the least
positive index $k$ with $p \mid u_k$ (and $0$ if $p$ never appears). Then:

- The rank is *always* a primitive index: $p$ is automatically a primitive
  divisor of $u_{\text{rank}}$ whenever it appears at all.
- The rank is the *unique* primitive index: $p$ is primitive for $u_n$ if and
  only if $n$ equals the rank of $p$.
- The criterion becomes self-contained:
  $$p \mid u_m \iff \operatorname{rank}(p) \mid m,$$
  with no externally supplied index. The divisibility set of $p$ is *exactly* the
  multiples of its rank.

This last statement, the **strong primitive-divisor criterion**, is the polished
form of the whole theory. It says that for any strong divisibility sequence, a
prime's entire interaction with the sequence is encoded in one number, its rank,
and detected by one operation, divisibility. And it specializes instantly to
recover both the Fibonacci law of apparition and the Mersenne / multiplicative-order
law — the same theorem twice, paid for once.

## Why mining skeletons matters

Step back and notice what just happened. We took two celebrated theorems with
two separate proofs and discovered they share a single structural core. We named
that core (the strong divisibility sequence), isolated the one hypothesis it needs
(the gcd identity), and re-derived the consequences once, in a form that does not
care whether you are thinking about rabbits breeding, powers growing, or primes
hiding.

This is more than tidiness. It is a different way of doing mathematics — treating
*proof strategies themselves* as objects to be studied, abstracted, and reused.
When a strategy is mined into a clean hypothesis-and-conclusion package, three
good things happen at once. New examples become free: the moment you verify that
some exotic sequence satisfies the gcd identity, every result above applies with no
further argument. Connections become visible: the Fibonacci and Mersenne worlds,
historically studied by different communities, turn out to be two readings of one
script. And the genuinely hard part of each original theorem is laid bare — once
the skeleton is removed, what remains (for Carmichael and Zsygmondy alike) is a
single growth estimate, the real obstacle that no amount of structural abstraction
can wish away.

The dream behind "proof strategy mining" is to do this systematically — to take
the great proofs, the ones whose names we speak in hushed tones, and ask of each:
*what is the skeleton?* What pattern, stated once and for all, would let the next
person reuse the idea without reliving the discovery? The primitive divisor
argument is one such skeleton, now written down precisely enough that a machine can
check it and a student can apply it. There are many more waiting inside the proofs
we already have, hidden in plain sight, doing the real work while the costumes get
all the attention.

The numbers $11 \mid F_{10}$ and $7 \mid 2^3 - 1$ look like trivia from different
chapters of different books. They are, in truth, the same sentence — and once you
know how to read the skeleton, you can never unsee it.
