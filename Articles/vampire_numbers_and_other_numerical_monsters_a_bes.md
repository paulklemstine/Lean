# Vampire Numbers and Other Numerical Monsters: A Bestiary of Arithmetic Oddities

## A number that eats its own children

Take the number $1260$. It looks ordinary enough — a four‑digit integer you might find on a receipt or an odometer. But split it into a product,

$$1260 = 21 \times 60,$$

and something eerie happens. Look at the digits on the right: a $2$, a $1$, a $6$, and a $0$. Now look at the digits of $1260$: a $1$, a $2$, a $6$, and a $0$. **They are exactly the same digits, merely rearranged.** The number $1260$ has, in a sense, been reconstituted from its two factors, as if the product remembered every digit it was built from and gave them all back.

Numbers like this were named **vampire numbers** by the recreational mathematician Clifford Pickover, and the name is apt. A vampire hides in plain sight among ordinary people; a vampire number hides among ordinary integers. Its two factors are called **fangs**. And like a good monster story, once you start looking for these creatures you discover that $1260$ is only the first specimen in a whole bestiary.

This article is a field guide to that bestiary — vampires, werewolves, ghosts, and zombies — and to a small, sharp piece of theory that explains *why* the vampires behave the way they do. The surprise is that these playful puzzles, easy enough to explain to a child, sit right next to some of the hardest problems in mathematics.

## The formal bite

Let us pin down the vampire precisely. Throughout, "the digits of $n$" means the ordinary base‑ten digits of $n$, collected *with multiplicity* — so the digits of $1260$ are the collection $\{1,2,6,0\}$, and the digits of $525$ are $\{5,5,2\}$, counting the two fives separately.

> **Definition (vampire number).** A **vampire number** is a positive integer $v$ with an even number of digits that can be written as a product $v = x \times y$ of two integers $x$ and $y$, each having half as many digits as $v$, neither ending in a trailing zero simultaneously, such that the digits of $x$ together with the digits of $y$ are exactly the digits of $v$, rearranged. The pair $(x, y)$ is called a pair of **fangs**.

The smallest vampire is $1260 = 21 \times 60$. The next few are

$$1395 = 15 \times 93, \qquad 1435 = 35 \times 41, \qquad 1530 = 30 \times 51, \qquad 1827 = 21 \times 87.$$

Some numbers are greedier still. The number $125460$ is a *double* vampire, with two entirely different sets of fangs:

$$125460 = 204 \times 615 = 246 \times 510.$$

Both factorizations use precisely the digits $\{1,2,4,5,6,0\}$ — the digits of $125460$ itself.

## The heart of the matter: a conservation law for digits

Here is the single idea that organizes everything. Forget, for a moment, the *order* of the digits. What matters for a vampire is the **multiset** of digits — the tally of how many $0$s, $1$s, $2$s, and so on a number contains, with order thrown away. Write $M(n)$ for this digit tally of $n$. For example $M(1260) = \{0,1,2,6\}$ and $M(21) + M(60) = \{1,2\} + \{0,6\} = \{0,1,2,6\}$, where $+$ means "pool the two tallies together."

In this language the vampire condition is stunningly clean:

> **The fang relation.** A pair $(x,y)$ are fangs of $v$ exactly when
> $$M(v) = M(x) + M(y) \quad\text{and}\quad v = x \cdot y.$$

That is: *pooling the digit tallies of the two fangs reproduces the digit tally of the product.* Everything else — digit sums, digit counts, and the congruences we are about to meet — flows from this one equation, purely by counting, with no cleverness required.

Two immediate harvests come from treating the digit tally as a bookkeeping device.

**The digit count is additive.** The number of digits is just the *size* of the tally. Since pooling two tallies adds their sizes,
$$\text{(number of digits of } v) = \text{(number of digits of } x) + \text{(number of digits of } y).$$
This is why a vampire with $2n$ digits must have fangs with $n$ digits each — the digit budget has to balance.

**The digit sum is additive.** The sum of a number's digits is the *total* of its tally. Pooling tallies adds their totals, so
$$S(v) = S(x) + S(y),$$
where $S(n)$ denotes the sum of the digits of $n$. Nothing here uses arithmetic modulo anything; it is pure accounting.

## Casting out nines, and the vampire's modular signature

Now we combine the digit‑sum law with a schoolchild's trick that is secretly a theorem. **Casting out nines** says that any number leaves the same remainder on division by $9$ as the sum of its digits does:
$$n \equiv S(n) \pmod 9,$$
and the same holds modulo $3$. This is why the old bookkeeper's check works: if you add a column of figures and your total disagrees with the sum modulo nine, you made a mistake.

Feed the additivity of digit sums into casting out nines and the vampire acquires a **modular signature**. Because $S(v) = S(x) + S(y)$, and because each number matches its digit sum modulo nine, we get

$$\boxed{\,v \equiv x + y \pmod 9\,} \qquad\text{and}\qquad \boxed{\,v \equiv x + y \pmod 3\,}.$$

Read that again, because it is genuinely strange. On one hand $v = x \cdot y$ — the number is the **product** of its fangs. On the other hand, modulo nine, $v$ behaves like the **sum** of its fangs. A vampire is a number that is simultaneously a product and (modulo nine) a sum of the same two ingredients. That coincidence is the fingerprint every vampire must carry.

Squeeze this fingerprint and it yields a genuine prohibition. Combining $x \cdot y \equiv x + y \pmod 3$ with a short case check rules out an entire residue class for the fangs:

> **The fang taboo (modulo 3).** In any fang pair, *neither fang* can leave remainder $1$ on division by $3$.

Check it on the archetype: $21 \equiv 0$ and $60 \equiv 0$ modulo $3$ — both avoid the forbidden residue $1$, exactly as the theorem demands. This is not a guess or a pattern spotted in a table; it is forced. Rearrange the congruence $xy \equiv x + y$ into $(x-1)(y-1) \equiv 1 \pmod 3$: if either factor were $\equiv 1$, the left side would vanish, and $0 \equiv 1$ is impossible. The same rearrangement modulo nine, $(x-1)(y-1)\equiv 1 \pmod 9$, traps the pair of fang residues inside a tiny, explicit list of allowed possibilities. Most candidate factorizations die here, instantly, without anyone ever doing the multiplication.

This is the practical payoff of the theory: a **free filter**. Before you test whether $x \times y$ reproduces the digits of $v$ — an expensive check — you can throw away the vast majority of candidates using nothing but remainders.

## The rest of the menagerie

Vampires are the celebrities, but they share the forest with other creatures, each defined by a twist on the same digit‑sharing idea.

**Werewolves.** A werewolf number is a product $v = x \times y$ whose fangs share *exactly one* digit with $v$ — not all of them, not none, precisely one. The werewolf is the vampire's half‑transformed cousin: caught between two worlds, partially reconstituted from its factors but not fully.

**Ghosts.** A ghost number is a product $v = x \times y$ whose factors share *no* digit at all with $v$. The product has vanished from its own factors, leaving no trace — a number haunted by an arithmetic it refuses to reveal. Ghosts are the rarest of the creatures, and there is a good reason for it. To be a ghost, a product must *avoid* every single digit appearing in either factor. As numbers grow longer, dodging every one of the ten digit classes across a longer and longer number becomes a wildly improbable coincidence. A clean probabilistic estimate — a union bound over the ten possible digits — predicts that the number of ghosts below a $d$‑digit ceiling shrinks like a fixed fraction raised to the power $d$. In other words:

> **Ghosts vanish geometrically.** The density of ghost numbers tends to zero as the number of digits grows, and it does so *exponentially fast*.

**Zombies.** Zombies are the boundary‑dwellers, the numbers that break the rules yet refuse to die. The tidy definition of a vampire wants both fangs to be "small" and neither to be prime, but reality is messier. The number $125460$ we met earlier has factorizations mixing primes and composites, and such near‑vampires — products that satisfy the digit condition while violating the fine print of the definition — shamble around the edges of the bestiary. They remind us that the definitions are human conventions imposed on an untamed arithmetic landscape.

## How common are the vampires?

Counting these creatures turns the recreational puzzle into real number theory. Empirically, vampires become *more* common, in a relative sense, as numbers grow: within the band of numbers with $2n$ digits, a growing supply of digit rearrangements gives more and more chances for a product to swallow its own digits. A natural conjecture holds that the density of vampires in the range $[10^{2n}, 10^{2n+1}]$ decays only gently, like $1/\sqrt{n}$, and — more strikingly — that

> **Vampires never go extinct.** Every even‑length band of integers $[10^{2k}, 10^{2k+2}]$ contains at least one vampire.

There is a constructive dream behind this: to *engineer* vampires rather than merely stumble upon them, by building fang pairs from a digit‑balanced core and a carefully controlled tail so that their product is guaranteed to land in the target band while permuting — never losing — its digits. If that construction can be made rigorous, vampires would be shown to appear in *every* even‑length block, with bounded gaps in digit length. They would be not a curiosity but a permanent feature of the number line.

## Easy to ask, hard to answer

Why should a serious mathematician care about numbers named after monsters? Because the vampire hunt is a perfect miniature of mathematics itself. The question "is $v$ a vampire?" is trivial to state and, for a specific small number, easy to check. But finding *all* vampires, or proving how many there are, forces you to search over factorizations — and searching over factorizations is, in general, as hard as **factoring integers**, the very problem whose difficulty guards the world's encrypted secrets.

So the bestiary straddles a fault line. On the surface it is play: whimsical creatures, memorable names, puzzles you can pose at a dinner table. Underneath, the same digit‑combinatorial questions brush against the frontier of what is computationally feasible. The modular signature we uncovered — that a vampire is at once a product and a sum modulo nine — is a rare gift from the easy side of that fault line: a rigorous, provable, *free* constraint in a landscape otherwise ruled by the hardness of factoring.

That is the enduring charm of the numerical monsters. They invite you in with a joke about vampires eating their digits, and before you know it you are staring at conservation laws, modular fingerprints, exponential decay, and the shadow of one of the deepest problems in computing — all hiding inside the number $1260$.
