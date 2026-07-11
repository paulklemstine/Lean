# What If the Primes Were Different?

## A counterfactual arithmetic, and the one law that breaks

Every child who learns multiplication eventually meets the primes: $2, 3, 5, 7, 11, \dots$, the numbers that refuse to be broken apart. And every student of number theory eventually meets the theorem that makes those primes the load-bearing wall of all arithmetic — the **Fundamental Theorem of Arithmetic**. It promises that each whole number bigger than $1$ can be written as a product of primes in exactly one way. The number $60$ is $2 \cdot 2 \cdot 3 \cdot 5$, and there is no rival factorization hiding somewhere; that list of primes is $60$'s fingerprint, unique to it forever.

This uniqueness feels less like a theorem and more like a law of nature. It is so deeply woven into how we think about numbers that it is easy to forget it was ever in doubt. But here is a mischievous question: *how much of number theory actually depends on it?* If we reached into the machinery of arithmetic and quietly swapped out the primes for a different set of "unbreakable" numbers, what would still work — and what would shatter?

This article follows exactly that experiment. We build a **counterfactual number theory**: same whole numbers, same multiplication, but a deformed notion of *which numbers count as prime*. Then we watch, theorem by theorem, what survives.

## Remembering only one thing about a number

Here is the trick that generates our alternate universe. Take an ordinary whole number and remember exactly one fact about it: its remainder when divided by $4$. Now keep only the numbers whose remainder is $1$:

$$H = \{\,1,\ 5,\ 9,\ 13,\ 17,\ 21,\ 25,\ 29,\ 33,\ 37,\ 41,\ 45,\ 49,\ \dots\,\}.$$

These are the numbers of the form $4k+1$. We will call this collection the **Hilbert monoid**, after David Hilbert, who used it as a teaching example a century ago. It is a small, clean world — a thin slice of the integers — but it is a world with its own arithmetic.

Why does it have an arithmetic at all? Because of a happy accident of remainders. Multiply two numbers that are each $1$ more than a multiple of $4$, and the product is again $1$ more than a multiple of $4$. In symbols, if $a \equiv 1$ and $b \equiv 1 \pmod 4$, then $a \cdot b \equiv 1 \pmod 4$. You can check it on the list: $5 \cdot 9 = 45$, and $45$ is on the list; $13 \cdot 17 = 221 = 4\cdot 55 + 1$, on the list again. So $H$ is *closed under multiplication*: you can never multiply your way out of it. This is our first survivor.

**Survivor 1 — the multiplicative skeleton.** *The set $H$ contains $1$ and is closed under multiplication.* Multiplication still makes sense inside the counterfactual world. This is the bedrock on which everything else is built, and it survives the deformation completely intact.

## Who are the primes now?

Inside $H$, a number is "prime" — we will say **$H$-irreducible** — if it cannot be broken into a product of two smaller members of $H$. The crucial subtlety, the thing that makes this a genuine alternate universe rather than a relabeling, is that *the factors must themselves live in $H$*. We are only allowed to use the numbers of our world.

Watch what this does to a familiar number: $9$. In ordinary arithmetic $9 = 3 \cdot 3$, so $9$ is not prime. But $3$ is not in $H$ — it leaves remainder $3$, not $1$, when divided by $4$. The only way to split $9$ using our numbers would require a factor of $3$, and that factor is forbidden. So inside $H$, the number $9$ is unbreakable. **In the counterfactual universe, $9$ is prime.**

The same thing happens to $21 = 3 \cdot 7$ and to $49 = 7 \cdot 7$. Both $3$ and $7$ leave remainder $3$ modulo $4$, so both are exiled from $H$. With their only would-be factors banished, $21$ and $49$ become unbreakable too. Three ordinary composite numbers — $9$, $21$, $49$ — are promoted to primes the moment we change which numbers we are allowed to use.

Let us state this carefully, because it is the engine of everything that follows.

**Definition.** A number $n$ is **$H$-irreducible** if $n \geq 2$, $n$ lies in $H$ (that is, $n \equiv 1 \pmod 4$), and whenever $n = a \cdot b$ with both $a$ and $b$ in $H$, one of $a, b$ must equal $1$.

**Lemma.** *The numbers $9$, $21$, and $49$ are each $H$-irreducible.* The proof is a short finite check: for each of these numbers, list the ways it could factor with both parts in $H$, and observe that the only nontrivial factor available ($3$ or $7$) has the wrong remainder. There is simply nowhere for the factorization to go.

## The theorem that survives: infinitely many primes

Euclid's most famous theorem says the ordinary primes never run out. Does our deformed world also have infinitely many primes, or did we accidentally build a universe with only a handful?

It has infinitely many — and we can point to exactly where they come from.

**Survivor 2 — infinitude of primes.** *There are infinitely many $H$-irreducible numbers.*

The reason is beautiful in its economy. Consider the ordinary primes that happen to leave remainder $1$ modulo $4$: numbers like $5, 13, 17, 29, 37, 41, \dots$. Each of these is already prime in the ordinary sense, so it certainly cannot be broken apart using the restricted numbers of $H$ — it cannot be broken apart *at all*. And since each leaves remainder $1$, each lives in $H$. So **every ordinary prime congruent to $1$ modulo $4$ is automatically an $H$-irreducible of our world.**

Are there infinitely many such ordinary primes? Yes — this is a celebrated result of Dirichlet, whose theorem on primes in arithmetic progressions guarantees that the progression $1, 5, 9, 13, 17, \dots$ contains infinitely many primes. (In fact the special case of remainder $1$ modulo $4$ was known even earlier.) Every one of them lands in our world as a counterfactual prime. So the counterfactual primes never run out either.

This is a striking pattern: **the infinitude of primes is robust.** It does not care about the fine structure of which numbers we call prime. As long as our world is rich enough to import Dirichlet's primes, Euclid's promise carries over unchanged.

## The theorem that shatters: unique factorization

Now for the casualty. We come to the Fundamental Theorem of Arithmetic — the guarantee of *one and only one* prime factorization. Does it survive?

It does not. And the counterexample is small enough to hold in your hand.

Consider the number $441$. It lives in $H$, since $441 = 4 \cdot 110 + 1$. Now factor it two ways:

$$441 = 9 \cdot 49 \qquad \text{and} \qquad 441 = 21 \cdot 21.$$

Both are legitimate. Both use only numbers from our world. And — this is the whole point — every factor appearing in them ($9$, $49$, and $21$) is $H$-irreducible, a genuine prime of the counterfactual universe. So we have written $441$ as a product of counterfactual primes in two genuinely different ways. One factorization uses the primes $\{9, 49\}$; the other uses $\{21, 21\}$. These are not rearrangements of each other — the numbers involved are simply different.

**The casualty — unique factorization.** *In the counterfactual world, $441 = 9 \cdot 49 = 21 \cdot 21$ are two distinct factorizations into counterfactual primes.* The Fundamental Theorem of Arithmetic is false in this universe.

It is worth savoring how this happens. In ordinary arithmetic, $441 = 3^2 \cdot 7^2$, a tidy prime factorization with the primes $3$ and $7$. But $3$ and $7$ are exiles from $H$. When we forbid them, the arithmetic has to route around them — and it can do so in more than one way. Bundling the exiled factors as $(3\cdot 3)(7 \cdot 7) = 9 \cdot 49$ gives one legal factorization; bundling them as $(3 \cdot 7)(3 \cdot 7) = 21 \cdot 21$ gives another. The forbidden numbers, unable to appear on their own, hide inside larger irreducibles — and they can hide in different disguises. Uniqueness dies.

## The moral: which laws are load-bearing?

Step back and look at the scoreboard of our experiment. We deformed number theory by remembering only remainders modulo $4$, keeping the residue-$1$ numbers. Then:

- **Multiplicative closure survived.** You can still multiply.
- **Infinitude of primes survived.** They still never run out.
- **Unique factorization collapsed.** The very first casualty, visible already at $441$.

This dividing line is the real discovery. It tells us that infinitude of primes and the multiplicative skeleton of arithmetic are *coarse* facts — they are robust, they hold in a whole family of alternate arithmetics, and they do not depend on the precise identity of the primes. Unique factorization, by contrast, is a *fine* fact. It is delicate. It is the first thing to break when you disturb the primes even slightly, and its breakage is structural, not a fluke of small numbers.

There is a natural way to see why the collapse is not an accident. The Hilbert world is defined by insisting on a single admitted remainder, $1$, out of the group of possible remainders $\{1, 3\}$ that are coprime to $4$. That group has two elements; we kept only one. This "index two" — throwing away half of the allowed remainders — is exactly what leaves room for exiled factors like $3$ and $7$ to reappear in multiple disguises. The moment the admitted remainders stop forming the *full* set of units, uniqueness has an opening to fail. One expects, and can begin to prove, that a similar dichotomy holds for every modulus: keep all the coprime remainders and factorization stays unique; keep a proper subset and it must eventually fail.

## Why counterfactuals matter

Asking "what if the primes were different?" is not idle whimsy. It is how mathematicians discover which of their theorems are truly fundamental and which are lucky features of the integers we happen to live with. The Hilbert monoid is a laboratory: cheap to build, easy to compute in, and yet rich enough to separate the robust from the fragile.

The same style of question reaches much further. One can ask what happens in a *random* number theory, where each whole number $n$ is declared "prime" independently with probability roughly $1/\log n$ — mimicking the density with which real primes actually appear. In such a random universe, Dirichlet-type statements about how primes distribute themselves are expected to survive almost surely, precisely because they are coarse, statistical facts; but the rigid clockwork of unique factorization has no reason to hold at all. The pattern we found in the small, exact world of $H$ appears to be a shadow of a much larger truth.

And that is the quiet lesson of counterfactual number theory. The primes are not a monolith of equally sacred laws. Some of what they give us is structural and portable, carried along by nothing more than closure and abundance. Some of it — the crown jewel, unique factorization — is a rare gift, easily lost, and all the more precious for how fragile it turns out to be.
