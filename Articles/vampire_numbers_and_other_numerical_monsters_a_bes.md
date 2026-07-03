# Vampire Numbers and Other Numerical Monsters: A Bestiary of Arithmetic Oddities

Somewhere between recreational puzzles and serious number theory lives a small
zoo of arithmetic creatures. They are easy to describe to a child, delightful to
hunt with a computer, and — as it turns out — governed by a hidden law that no
one who plays with them for the first time expects. This is the story of vampire
numbers and their kin, and of the surprisingly rigid rule that all of them are
forced to obey.

## A number that hides inside its own factors

Begin with the star of the show. Take the number $1260$. It has four digits:
$1, 2, 6, 0$. Now factor it: $1260 = 21 \times 60$. Look at the digits of the two
factors, $21$ and $60$: they are $2, 1, 6, 0$ — exactly the same four digits as
$1260$ itself, just rearranged. The number $1260$ has, in a sense, *dissolved
into its own factors and reassembled from the same raw material.*

Numbers with this property are called **vampire numbers**, a name coined by the
science-fiction writer Clifford Pickover. The two factors are called the
**fangs**. To keep the game honest, we ask that the number have an even count of
digits, that each fang have exactly half as many digits as the number, and that
the fangs not both end in zero (otherwise trailing zeros would make the game too
easy). By that standard, $1260 = 21 \times 60$ is the smallest vampire, and the
hunt is on: $1395 = 15 \times 93$, $1435 = 35 \times 41$, $1530 = 30 \times 51$,
$1827 = 21 \times 87$, and so on.

Formally, if we write $D_b(n)$ for the multiset of base-$b$ digits of a number
$n$, a pair $(x, y)$ is a **fang pair** in base $b$ when

$$D_b(x \cdot y) = D_b(x) \,\cup\, D_b(y),$$

that is, the digits of the product are a rearrangement of all the digits of the
two factors combined. This one combinatorial sentence — *"the product is an
anagram of its factors"* — is the seed from which the entire bestiary grows.

## Expanding the menagerie

Once you have one monster, you can breed others by tweaking the digit rule.

- **Werewolf numbers**: instead of sharing *all* digits, the product shares
  *exactly one* digit with its factors — a partial transformation, human by day,
  wolf by night.
- **Ghost numbers**: the product shares *no* digits at all with either factor.
  The number $v = x \times y$ is completely transparent to its own
  factorization; nothing of $x$ or $y$ shows through.
- **Zombie numbers**: composite numbers with multiple factorizations of mixed
  character — one factorization pairs a prime with a composite, another does the
  same with different partners — so the number refuses to stay cleanly
  "alive" (prime) or "dead" (a clean product). A worked example is
  $125460 = 204 \times 615 = 246 \times 510$.

These definitions are pure play. The digits are a decorative costume; the
arithmetic underneath — which numbers multiply to which — has nothing obviously
to do with how the digits happen to line up. That is exactly what makes the next
discovery startling.

## The law every monster obeys

Here is the surprise. Although the fang condition is a statement about *digits*,
it forces an exact statement about *values*. Every fang pair, in every base,
must satisfy

$$x \cdot y \;\equiv\; x + y \pmod{b - 1}.$$

In base $10$ this reads $x \cdot y \equiv x + y \pmod 9$. Check it on our vampire:
$21 \times 60 = 1260$ and $21 + 60 = 81$; both $1260$ and $81$ are multiples of
$9$, so both sides are $\equiv 0 \pmod 9$. The rule holds, and it holds not by
luck but by necessity.

Why is a digit condition secretly an arithmetic one? The bridge is the oldest
trick in the elementary-arithmetic book: **casting out nines**. In base $b$, any
number is congruent to the sum of its digits modulo $b - 1$:

$$n \;\equiv\; (\text{sum of base-}b\text{ digits of } n) \pmod{b - 1}.$$

(In base $10$, that is the familiar fact that a number and its digit sum leave the
same remainder on division by $9$.) Now the fang condition says the digits of
$x \cdot y$ are a *rearrangement* of the digits of $x$ and $y$ together. A
rearrangement does not change a sum — order never matters when you add. So the
digit sum of $x \cdot y$ equals the digit sum of $x$ plus the digit sum of $y$.
Feed that equality through casting out nines and the digits vanish, leaving only
the values:

$$x \cdot y \equiv \text{digitsum}(xy) = \text{digitsum}(x) + \text{digitsum}(y) \equiv x + y \pmod{b-1}.$$

The combinatorial costume falls away and a clean number-theoretic skeleton
stands underneath.

## The vampire's true nature: a pair of inverse residues

The additive law $x y \equiv x + y$ has an even more elegant multiplicative
shadow. Subtract, and complete the rectangle:

$$(x - 1)(y - 1) = xy - x - y + 1 \equiv (x + y) - (x + y) + 1 = 1 \pmod{b - 1}.$$

So for **every** fang pair,

$$(x - 1)(y - 1) \equiv 1 \pmod{b - 1}.$$

Read this aloud: *each fang, decremented by one, is a unit modulo $b - 1$, and
the two decremented fangs are multiplicative inverses of one another.* In base
$10$: $(x - 1)(y - 1) \equiv 1 \pmod 9$. Our vampire again: $(21 - 1)(60 - 1) =
20 \times 59 = 1180$, and $1180 = 131 \times 9 + 1$, so $1180 \equiv 1 \pmod 9$.
Exactly as promised.

This is the sharp reason vampires are rare. A random pair of factors will almost
never have its decremented values be mutual inverses modulo $9$. The digit
coincidence that *defines* a vampire quietly imposes an *algebraic* coincidence,
and coincidences compound.

The unit law even tells us which numbers can *never* be fangs. Since $9 = 3
\times 3$, a congruence modulo $9$ implies one modulo $3$. If a fang $x$ were
$\equiv 1 \pmod 3$, then $x - 1 \equiv 0$, and $(x-1)(y-1)$ would be divisible by
$3$ — it could not possibly be $\equiv 1 \pmod 3$. Therefore **no fang of a base-10
vampire is congruent to $1$ modulo $3$**: the values $1, 4, 7, 10, 13, \dots$ are
forbidden from ever being fangs. Check $1260$: both fangs $21$ and $60$ are
multiples of $3$ (so $\equiv 0$), comfortably obeying the ban.

## From two fangs to a whole pack

Nothing about the argument needed there to be exactly two factors. If a number is
the product of a whole list of factors $x_1, x_2, \dots, x_k$, and the digits of
the product are an anagram of all the factors' digits pooled together, then the
same casting-out-nines argument gives

$$x_1 x_2 \cdots x_k \;\equiv\; x_1 + x_2 + \cdots + x_k \pmod{b - 1}.$$

The law scales seamlessly from a single pair of fangs to an entire monstrous
brood. Product and sum agree modulo $b - 1$ whenever the digits are conserved.

## What we can prove, and what still prowls in the dark

The law above is airtight: it is a theorem, true for all bases $b \ge 2$ and all
factorizations, proved from first principles. But the folklore surrounding
vampire numbers is mostly *conjecture*, and here the creatures still elude
capture.

It is believed that vampire numbers thin out at a very specific rate — that the
fraction of $2n$-digit numbers which are vampires behaves like $1/\sqrt{n}$ as the
number of digits grows — and that every "even window" $[10^{2k}, 10^{2k+2})$
contains at least one. **Ghost numbers**, by contrast, are conjectured to have
density zero: as numbers get longer, it becomes overwhelmingly unlikely that a
product will avoid *every* digit of its factors, so ghosts fade toward
extinction. These claims are easy to state and stubborn to prove, because they
amount to controlling the digits of *random products* — a problem entangled with
the deep difficulty of understanding multiplication and factoring at the level of
digits.

That tension is the real charm of the bestiary. A vampire number is nothing more
than a coincidence between two lists of digits — the product's and the fangs' —
and yet chasing those coincidences leads straight to questions as hard as any in
number theory. The monsters are easy to name. Pinning down how many there are, and
where they lurk, is the hunt that continues.

## Why bother?

Because the same move that tames vampires — noticing that a condition on
*symbols* forces a condition on *values* — is one of the most powerful and
recurring ideas in mathematics. Casting out nines is a toy, but the principle
behind it, that digit patterns and arithmetic residues are two faces of one
coin, echoes through cryptography, coding theory, and the study of how numbers
are built from primes. The bestiary is a playground, but the games it teaches are
the real thing. And there is genuine joy in discovering that a creature invented
purely for fun turns out to carry, stamped into its bones, a law it cannot
escape.
