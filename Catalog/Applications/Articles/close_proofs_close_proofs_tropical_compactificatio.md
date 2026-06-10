# When a Number Can't Hide: The Secret Arithmetic of Sums of Powers

## A puzzle older than algebra

Pick a whole number — say, 33. Now ask a deceptively simple question: can you
write it as a sum of three cubes? That is, are there integers *x*, *y*, *z*
(positive, negative, or zero) with

$$x^3 + y^3 + z^3 = 33?$$

For centuries this resisted everyone who tried. Then, in 2019, after a planetary
computer search, the answer arrived:

$$8{,}866{,}128{,}975{,}287{,}528^3 + (-8{,}778{,}405{,}442{,}862{,}239)^3 + (-2{,}736{,}111{,}468{,}807{,}040)^3 = 33.$$

Those are sixteen-digit numbers conspiring to land exactly on 33. The companion
case, 42, fell shortly after, requiring even larger solutions found across a
global network of volunteer machines.

Now ask the same question about 42's neighbor, 4. Or about 5, 13, 14, 22, 23,
31, or 32. No matter how long you search — not for years, not for the lifetime of
the universe — you will **never** find three cubes summing to any of these. And
here is the remarkable part: we can *prove* it in a single line of arithmetic,
without searching at all.

This is the heart of a beautiful and ancient idea in number theory: some numbers
carry a kind of invisible fingerprint that makes a representation *impossible*,
and that fingerprint can be read off instantly. This article is about a clean,
general, machine-verified framework — an **obstruction calculus** — that captures
exactly when this trick works, for sums of *any* number of *any* power.

## The shadow on the wall

The trick that rules out 4 as a sum of three cubes is to look not at the whole
numbers but at their *shadows*. Take every cube and record only its remainder
when divided by 9. Something miraculous happens: every cube, no matter how large,
leaves a remainder of only **0, 1, or 8** when divided by 9. Try it: $1^3 = 1$,
$2^3 = 8$, $3^3 = 27 = 3\cdot 9$ (remainder 0), $4^3 = 64 = 7\cdot 9 + 1$
(remainder 1), and the pattern locks in forever.

So a sum of three cubes can only have a remainder you can build by adding three
numbers from the set $\{0, 1, 8\}$. List them all:

$$0,\ 1,\ 2,\ 3,\ 8,\ 9,\ 16,\ 17,\ 24,\dots$$

Reduce mod 9 and you get every remainder *except* 4 and 5. So **any** number that
leaves a remainder of 4 or 5 when divided by 9 simply cannot be a sum of three
cubes — and 4, 5, 13, 14, 22, 23, ... are exactly those numbers. The proof fits
on a napkin. No supercomputer required.

This is the local–global principle in miniature. The full equation lives in the
infinite, hard-to-search world of the integers (the *global* world). But its
shadow lives in a tiny, finite world — the integers modulo 9 — where you can
simply check every possibility by hand (the *local* world). If the equation has a
solution globally, it must cast a consistent shadow locally. **Contrapositive: if
there is no shadow, there is no solution.** A local obstruction kills the global
problem dead.

## From cubes to a universal calculus

The cubes-mod-9 trick is a special case of something far more general. Replace 3
(the power) by any exponent *n*, replace "three" (the number of terms) by any
count *s*, and replace 9 by any modulus *m*. The general question becomes:

> Given a target *k*, can we write $k = x_1^n + x_2^n + \cdots + x_s^n$?

And the general obstruction test becomes:

> Look at the equation modulo *m*. Is there *any* choice of residues whose
> *n*-th powers add up to *k* mod *m*?

If the answer is "no" for even a single modulus *m*, then *k* is impossible. The
recent formalization at the center of this article builds this idea into a precise,
verified theory. It introduces a single clean predicate:

**Local admissibility.** We say *k* is *locally admissible* for *s* powers of
degree *n* modulo *m* if there exist residues $x_1, \dots, x_s$ in
$\mathbb{Z}/m\mathbb{Z}$ with

$$x_1^n + x_2^n + \cdots + x_s^n \equiv k \pmod{m}.$$

In words: *k*'s shadow can be assembled from *s* power-shadows. A number that is
locally admissible at *every* modulus is called **everywhere locally admissible** —
it passes every shadow test there is.

With this vocabulary, the napkin proof becomes a theorem: 4 is *not* locally
admissible for three cubes modulo 9, therefore 4 is not a sum of three cubes.

## Five pillars of the obstruction calculus

What makes this more than a single clever trick is that the framework comes with a
handful of structural theorems, each rigorously proved and machine-checked. Think
of them as the laws of physics for shadows. Here they are, in plain language.

### Pillar 1 — Global solutions always cast a shadow

> **If $k = x_1^n + \cdots + x_s^n$ has an integer solution, then $k$ is locally
> admissible modulo every positive $m$.**

This is the foundation. It says the local tests can *never* give a false negative:
a genuinely representable number passes every modular check. The proof is almost a
tautology once stated correctly — reducing an integer equation modulo *m* is just
applying the same operation to both sides — but it is the load-bearing wall of the
whole subject. Its power is entirely in the contrapositive: **fail one test, fail
forever.** This is what licenses the napkin proof for 4.

A direct corollary packages the idea cleanly: a globally representable number is
*everywhere* locally admissible. Every shadow it could cast, it casts correctly.

### Pillar 2 — Obstructions flow downhill

> **If $m$ divides $M$, then admissibility modulo $M$ implies admissibility
> modulo $m$.**

Picture the moduli as a hierarchy ordered by divisibility. Information about
solvability flows *downward*: knowing the shadow mod 9 automatically tells you the
shadow mod 3, because the integers mod 3 are a quotient — a coarser snapshot — of
the integers mod 9. The proof rides the natural projection map
$\mathbb{Z}/M \to \mathbb{Z}/m$, which carries any witnessing solution from the
finer world to the coarser one.

The practical payoff is enormous. It means you never have to test *every* modulus.
By the Chinese Remainder Theorem, every modulus factors into prime powers, and
this descent law tells you that the *finest* prime-power moduli carry all the
information. The infinite search collapses to a finite, structured one.

### Pillar 3 — When the shadow world is full, nothing is obstructed

> **If every residue class modulo $m$ is a sum of $s$ $n$-th powers, then every
> integer is locally admissible modulo $m$.**

Sometimes the shadow world holds no obstructions at all. We call such a modulus
**universally surjective**: every single residue can be hit by a sum of *s* powers.
When that happens, the modulus *m* tells you nothing about impossibility — it gives
every number a clean bill of health. This theorem formalizes that intuition: a
universally surjective modulus is a "transparent" one, contributing no obstruction.

This is the other side of the coin from Pillar 1. To rule a number out you want an
*opaque* modulus (like 9 for three cubes, which misses residues 4 and 5). To gain
confidence that no obstruction hides at *m*, you prove *m* is transparent.

### Pillar 4 — The shadows have hidden symmetry

> **The set of residues that are sums of $s$ $n$-th powers is unchanged when you
> multiply by the $n$-th power of any invertible residue.**

This is the most surprising of the pillars, and the one that connects the additive
question (sums) to the multiplicative world (products). Suppose *r* is a sum of *s*
*n*-th powers mod *m*, and let *u* be the *n*-th power of some unit *a* (an
invertible residue). Then $u \cdot r$ is *also* a sum of *s* *n*-th powers. The
reason is elegant: if $r = \sum x_i^n$, then

$$u \cdot r = a^n \sum x_i^n = \sum (a\,x_i)^n.$$

Multiplying through by $a^n$ simply rescales each term, and an *n*-th power of a
unit times an *n*-th power is again an *n*-th power. So the admissible set is not a
random scatter of residues — it is a **union of orbits** under the action of the
group of *n*-th-power units. This is additive number theory and group theory
shaking hands: the symmetry of the multiplicative unit group organizes the additive
landscape of sums of powers. In practice it slashes the work needed to map out the
admissible set, because computing one representative of an orbit gives you the whole
orbit for free.

### Pillar 5 — Coprime worlds combine

> **If $m_1$ and $m_2$ are coprime and each is universally surjective, then their
> product $m_1 m_2$ is universally surjective.**

This is the Chinese Remainder Theorem doing the heavy lifting. Two coprime moduli
describe *independent* shadow worlds; a residue mod $m_1 m_2$ is exactly a pair
consisting of a residue mod $m_1$ and a residue mod $m_2$. If you can hit any target
in each world separately, you can hit any pair simultaneously, just by solving each
world and gluing the answers back together with the CRT isomorphism. Combined with
Pillar 2, this is the engine that reduces the entire infinite question of
obstructions to a finite checklist of prime powers.

## A verified algorithm, not just theory

The framework is not only descriptive; it is *computational*, and the computation
is certified correct. The theory defines an explicit procedure that, given *n*, *s*,
and *m*, produces the exact finite set of all residues reachable as a sum of *s*
*n*-th powers mod *m*: simply run over every possible tuple of residues, compute the
sum of powers, and collect the results. A theorem then proves the obvious-but-crucial
fact that this computed set is *correct* — a residue *k* lies in it **if and only if**
*k* is genuinely locally admissible. Nothing is missed, nothing is hallucinated.

This is what turns the obstruction calculus into a usable tool. To decide whether a
modulus *m* obstructs a target *k*, you run the algorithm and check membership. To
prove 4 is not a sum of three cubes, the algorithm computes the set of sums of three
cubes mod 9 as $\{0,1,2,3,6,7,8\}$, notes that 4 is absent, and the correctness
theorem certifies that this absence is a genuine impossibility, not a bug.

## Why this matters

At first glance this might look like recreational arithmetic — a parlor trick for
deciding which numbers are sums of cubes. But the local–global philosophy it
embodies is one of the deepest organizing principles in all of number theory.

It is the spirit behind **Hasse's principle** for quadratic forms, where solvability
"everywhere locally" (over the real numbers and modulo every prime power) guarantees
solvability globally. It is the structure underlying **Waring's problem** — Hilbert's
celebrated theorem that for every exponent *n*, some fixed number of *n*-th powers
suffices to represent *all* sufficiently large integers — where the remaining
exceptional cases are governed precisely by local obstructions like the one mod 9.
And it is the cautionary tale of the **counterexamples to Hasse's principle**, curves
that pass every local test yet have no global solution, which opened the door to the
modern theory of the Brauer–Manin obstruction.

What the obstruction calculus contributes is *uniformity and certainty*. The same
five pillars hold for squares, cubes, fourth powers, and beyond; for two terms, three
terms, or a hundred; at every modulus at once. And because the entire framework —
definitions, theorems, and the correctness of the algorithm — has been verified down
to the logical bedrock, there is no gap between the napkin proof and the machine: the
shadow on the wall is now a theorem you can trust absolutely.

## The takeaway

A number trying to disguise itself as a sum of cubes cannot hide its shadow. Divide
by 9 and look: if the remainder is 4 or 5, the disguise is blown, instantly and
forever. The obstruction calculus is the general law behind that one-line verdict —
a complete, symmetric, computable, and rigorously verified account of when a number's
local fingerprints make a global representation impossible. It is a small, sharp
window into the grand local–global drama that animates modern number theory: the
eternal negotiation between the infinite world of the integers and the finite worlds
of their shadows.
