# Vampire Numbers and Other Numerical Monsters: A Bestiary of Arithmetic Oddities

Every folklore has its monsters, and so does arithmetic. Among the tamest of numbers there hide creatures with a taste for their own digits — numbers that split apart into smaller pieces which, taken together, are nothing more than a rearrangement of the original. They are called **vampire numbers**, and once you learn to see them you cannot stop looking.

## A number that bites

Take the number $1260$. It looks ordinary. But watch what happens when we factor it:

$$1260 = 21 \times 60.$$

Line up the digits of the two factors — $2, 1, 6, 0$ — and compare them with the digits of the product — $1, 2, 6, 0$. They are the same four digits, merely shuffled. The number $1260$ has, in a sense, *devoured itself*: its two factors are built from exactly its own digits, no more and no less. Following the tradition begun by the recreational mathematician Clifford Pickover, we call $1260$ a **vampire number** and its two factors its **fangs**.

The rules of the hunt are precise. A vampire number $v$ must:

- have an **even** number of digits, say $2k$;
- factor as $v = x \times y$ where each fang $x$ and $y$ has exactly $k$ digits;
- have the property that the digits of $x$ and $y$, poured into a single pile, are a permutation of the digits of $v$;
- and — to rule out cheap tricks — the two fangs must not *both* end in zero.

That last clause is the wooden stake of the definition. Without it, any number ending in enough zeros could masquerade as a vampire by padding a factor with trailing zeros. With it, the vampires that remain are genuine.

The first few are $1260 = 21 \times 60$, $1395 = 15 \times 93$, $1435 = 35 \times 41$, $1530 = 30 \times 51$, and $1827 = 21 \times 87$. After that they multiply — literally and figuratively — becoming more common the more digits you allow.

## A whole bestiary

Once you accept that numbers can eat their own digits, the imagination runs wild, and a whole zoo of arithmetic creatures suggests itself. Each is defined by *how much* a number shares with its factors:

- **Vampires** share *all* their digits with their fangs — a perfect rearrangement.
- **Werewolves** share *exactly one* digit — a partial, uneasy resemblance, half-human and half-beast.
- **Ghosts** share *no* digits at all with their factors — the factorization leaves no trace of itself in the product, a haunting absence.
- **Zombies** are the undead exceptions: numbers with two genuinely different factorizations, one of which drags a prime along where a proper vampire would forbid it. The number $125460$ is one such creature, with $125460 = 204 \times 615 = 246 \times 510$ — factorizations that stumble over the classical rules yet refuse to stay buried.

These are easy to *state* and, like all the best monsters, surprisingly hard to *catch*. Deciding whether a number is a vampire means searching through its factorizations and checking digits — a combinatorial hunt that, for large numbers, is entangled with the notorious difficulty of factoring itself. A number that is easy to describe can still be a devil to classify.

## Silver bullets: how to reject a monster

You cannot slay every vampire by brute force. But mathematics gives us **silver bullets** — quick tests that a candidate must survive, each one eliminating vast herds of impostors without any factoring at all. The surprising discovery at the heart of this work is that the digit-permutation rule, seemingly a childish game of shuffling, forces deep arithmetic constraints on the fangs.

### The first silver bullet: casting out nines

Here is an old piece of schoolroom magic. Any whole number leaves the same remainder when divided by $9$ as the *sum of its digits* does. So $1260$ has digit sum $1+2+6+0 = 9$, which is divisible by $9$; and indeed $1260 = 140 \times 9$.

Now apply this to a vampire. Since the fangs' digits are just the product's digits rearranged, they must have the **same digit sum**, and therefore the same remainder modulo $9$. This gives, for any digit-permutation factorization $v = x \times y$:

$$x \times y \;\equiv\; x + y \pmod 9.$$

The product behaves, modulo $9$, like a sum. Rearranging this relation with a little algebra produces something even cleaner:

$$(x - 1)(y - 1) \;\equiv\; 1 \pmod 9.$$

This is a genuine constraint, not a coincidence. It says the two quantities $x-1$ and $y-1$ must be *multiplicative inverses of each other modulo $9$*. Most pairs of numbers fail this outright.

### The second silver bullet: no fang is one more than a multiple of three

The congruence above hides a sharper consequence. If $(x-1)(y-1) \equiv 1 \pmod 9$, then in particular the product $(x-1)(y-1)$ is not divisible by $3$. That means **neither $x-1$ nor $y-1$ can be divisible by $3$** — which is to say:

> **No fang of a vampire number can be congruent to $1$ modulo $3$.**

In plain terms, a fang can never be one more than a multiple of three. This single observation instantly disqualifies roughly a third of all candidate factors before we compare a single digit. It is a one-line sieve, and it is exact.

### The third silver bullet: no carry shrinkage

There is a third obstruction, and it is geometric rather than modular. When you multiply two numbers, the answer usually has about as many digits as the two factors combined — but sometimes a carry "collapses" and you lose a leading digit. (Compare $5 \times 2 = 10$, which grows, with $3 \times 3 = 9$, which does not.)

For a vampire, this collapse is **forbidden**. Because the fangs' digits together must exactly fill out the product's digits, the product is compelled to occupy the *maximum possible* number of decimal places:

$$\text{length}(x \times y) \;=\; \text{length}(x) + \text{length}(y).$$

The multiplication must lose no leading digit. This "no carry shrinkage" law can be checked instantly, before any digit-by-digit comparison, and it too rejects a positive fraction of would-be vampires. Remarkably, it turns the digit-shuffling condition into a statement about *size* — a metric fingerprint of vampirism.

## Crossing over to binary

The monsters live in base ten, where their digit games unfold. But numbers do not care what base we write them in, and one of the most pleasing results here is a bridge to the world of **binary**.

Write $s_2(n)$ for the number of $1$'s in the binary expansion of $n$ — its **binary digit sum**, sometimes called the population count. A basic fact is that this quantity is *subadditive*: splitting a number into two summands never decreases the total count of binary ones, so

$$s_2(a + b) \;\le\; s_2(a) + s_2(b).$$

Multiplication is repeated addition, and iterating the inequality above across a product yields a **submultiplicative** law:

$$s_2(x \times y) \;\le\; y \cdot s_2(x),$$

and, by the symmetry of multiplication, the sharper

$$s_2(x \times y) \;\le\; \min\big(y \cdot s_2(x),\; x \cdot s_2(y)\big).$$

Applied to a vampire number $v = x \times y$, this bounds the binary complexity of the monster — how many binary ones it carries — by the complexity of a single fang, scaled by the other. For $1260 = 21 \times 60$, the number $1260$ has six binary ones, while $21$ has three and $60$ has four; the bound $6 \le \min(60 \cdot 3,\ 21 \cdot 4) = \min(180, 84) = 84$ holds comfortably. The inequality is honest and genuinely one-directional: products create and destroy binary carries, so equality generally fails.

## Why chase monsters?

It would be easy to dismiss all this as a game. But the history of number theory is a history of games that turned serious. Perfect numbers, friendly numbers, and figurate numbers all began as amusements and ended as gateways to modular arithmetic, factorization, and the theory of arithmetic functions.

Vampire numbers are the same. They sit exactly on the fault line between the trivial and the intractable: their *definition* is a puzzle a child can grasp, yet *finding* them all is entangled with factoring, one of the hardest problems in computation and the bedrock of modern cryptography. The silver bullets above — casting out nines, the mod-three sieve, the no-carry-shrinkage law — are small victories that carve away the impossible-to-search space, and each one hints at a larger structure: an infinite tower of congruences modulo $9$, $99$, $999$, and beyond, all constraining the fangs at once.

The bestiary, in the end, is a way of asking a serious question in a playful voice: *how much can the digits of a number know about the way it factors?* The answer, it turns out, is quite a lot — enough to sieve, to bound, and to bridge from base ten to base two. The monsters are real, and studying them teaches us something true.
