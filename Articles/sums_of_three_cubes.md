# The Three-Cube Puzzle: Which Numbers Hide a Triple of Cubes?

Pick a whole number — say $29$. Can you write it as the sum of three perfect cubes, allowing negative numbers? After a little fiddling you might find
$$
29 = 3^3 + 1^3 + 1^3 = 27 + 1 + 1.
$$
Easy. Now try $30$. This one is far harder; the smallest solution known is
$$
30 = 2{,}220{,}422{,}932^3 + (-2{,}218{,}888{,}517)^3 + (-283{,}059{,}965)^3,
$$
a triple of ten-digit giants that nearly cancel one another out. And then try $33$. For decades nobody could decide whether it was possible at all — until $2019$, when a worldwide computation finally produced an answer with numbers sixteen digits long.

This is the **sum of three cubes** problem, one of the most deceptively simple questions in all of mathematics. It asks, for a given integer $n$, whether there exist integers $x$, $y$, $z$ with
$$
x^3 + y^3 + z^3 = n.
$$
The catch — and the beauty — is that the cubes may be negative, so there is no upper limit on how large the ingredients can grow. A number might be representable using astronomically large cubes that all but annihilate each other, leaving behind a small remainder. There is no obvious way to bound the search, and that is precisely what makes the problem so slippery.

## A wall that nine builds

Before chasing giant solutions, there is a much cheaper question to ask: are there numbers for which the answer is *obviously no*? Remarkably, yes — and the reason is a single, elegant piece of arithmetic involving the number nine.

Look at what cubes do modulo $9$ (that is, look at their remainders after dividing by $9$). Run through the possibilities:
$$
0^3 \equiv 0,\quad 1^3 \equiv 1,\quad 2^3 \equiv 8,\quad 3^3 \equiv 0,\quad 4^3 \equiv 1,\quad 5^3 \equiv 8,\ \dots
$$
The pattern never escapes a tiny set. **Every cube of an integer leaves a remainder of $0$, $1$, or $8$ when divided by $9$.** There are no other options. This is the heart of the matter, and it is easy to see why: any integer is one of $0, \pm 1, \pm 2, \pm 3, \pm 4$ modulo $9$, and cubing each of these nine possibilities only ever yields $0$, $1$, or $8$.

Now suppose $n$ is a sum of three cubes. Then modulo $9$, $n$ must be a sum of three numbers each drawn from the set $\{0, 1, 8\}$. How many totals can three such picks produce? We can simply list them. The possible sums are
$$
0,\ 1,\ 2,\ 3,\ 8,\ 9,\ 10,\ 16,\ 17,\ 24,
$$
which modulo $9$ collapse to the remainders
$$
0,\ 1,\ 2,\ 3,\ 6,\ 7,\ 8.
$$
Two remainders are conspicuously missing: **$4$ and $5$**. No matter how you combine three elements of $\{0,1,8\}$, you can never land on $4$ or $5$ modulo $9$.

The conclusion is immediate and airtight:

> **The Modular Obstruction.** If $n \equiv 4$ or $n \equiv 5 \pmod 9$, then $n$ is *not* a sum of three integer cubes.

This rules out infinitely many numbers in one stroke — $4, 5, 13, 14, 22, 23, \dots$ and so on, the entire arithmetic progressions $\equiv \pm 4 \pmod 9$. It is a complete, unconditional proof of impossibility, and it costs nothing more than checking a handful of remainders. Mathematicians call this kind of barrier a *local obstruction*: a failure that can be detected by looking at a single modulus.

## The conjecture: is nine the *only* wall?

The obvious next question is whether nine tells the whole story. We now know that $n \equiv 4, 5 \pmod 9$ is impossible. But is *every other* number representable?

Concretely: if $n$ is **not** congruent to $4$ or $5$ modulo $9$, must $n$ be a sum of three cubes? This is the celebrated **conjecture of Heath-Brown**, and it remains *open* — one of the genuinely unsolved problems of modern number theory. All available evidence says yes. Every integer below $100$ has now been settled, including the two notorious holdouts $33$ and $42$, cracked only in $2019$ after enormous distributed computations. Not a single admissible number has ever resisted. Yet there is no proof, and the difficulty is structural: each residue class contains infinitely many integers, and there is no finite list of examples that could ever certify them all. The number $0$, the number $9$, the number $18$ — all live in the same class modulo $9$, yet each may demand a genuinely different and larger representation. A conjecture about infinitely many numbers cannot be settled by checking finitely many of them.

So the problem splits cleanly into two halves of utterly different character:

- **The impossibility half** is *finished*. The modular obstruction is a theorem, proved completely and rigorously: numbers congruent to $4$ or $5$ modulo $9$ are forever beyond reach.
- **The possibility half** is *conjectural*. Whether nine is the only obstacle is unknown, and it cannot be reduced to a finite computation.

We can package both halves into a single statement, being scrupulously honest about which side is settled:

> **Characterization (one direction open).** An integer $n$ fails to be a sum of three cubes *if and only if* $n \equiv 4$ or $5 \pmod 9$. The "if" direction — that these residues are impossible — is a proven theorem. The "only if" direction — that nothing else is impossible — is exactly Heath-Brown's open conjecture.

## Why the giants appear

What makes the *possibility* half so computationally savage? Geometry offers a clue. The equation $x^3 + y^3 + z^3 = n$ describes a surface floating in three-dimensional space — a smooth **cubic surface**. Asking whether $n$ is a sum of three cubes is asking whether this surface passes through any point with whole-number coordinates.

The surface stretches off to infinity, and integer points on it can be extraordinarily sparse and far from the origin. Heuristic counting arguments — essentially estimating how many lattice points lie near the surface — predict that solutions should exist for every admissible $n$, but that the *smallest* one can be wildly large. That is why $30$ needs ten-digit cubes and $33$ needs sixteen-digit ones: not because the numbers are special, but because the surface only grazes the integer lattice at remote outposts. The hunt for these points is a triumph of clever number theory and raw computational power, often phrased as searching for $x, y$ with $x^3 + y^3 - n$ divisible by a cube and combing through residues with sophisticated sieves.

There is also a built-in symmetry that softens the search: since
$$
(-x)^3 + (-y)^3 + (-z)^3 = -(x^3+y^3+z^3),
$$
a number $n$ is a sum of three cubes exactly when $-n$ is. Representations come in mirror-image pairs, halving the work and reflecting the central symmetry of the cubic surface itself.

## Families that never run out

Not every number is a tightrope walk. Some values are *abundantly* representable, and the reason is algebraic identity rather than brute search. For instance, there is a polynomial recipe that produces solutions for the value $1$ for every parameter, and a classical identity does the same for $2$. These are not lucky accidents; they are whole one-parameter families of solutions, infinite assembly lines that manufacture representations on demand. Small targets like $0 = 0^3+0^3+0^3$, $2 = 1^3 + 1^3 + 0^3$, $3 = 1^3+1^3+1^3$, $6 = 2^3 + (-1)^3 + (-1)^3$, and $7 = 2^3 + 0^3 + (-1)^3$ fall out instantly, while the same surface can hide its solutions for a number like $33$ for the better part of a century.

This contrast — effortless families on one side, deep isolated giants on the other — is the signature of the three-cube problem. It is what links a question a schoolchild can pose to the frontier of analytic number theory, the geometry of cubic surfaces, and the grand philosophy of the **Hasse principle**, which asks when local solvability (no obstruction at any modulus, no obstruction over the real numbers) guarantees global solvability (an actual integer solution). The modular obstruction modulo $9$ is the one and only local barrier here; Heath-Brown's conjecture is the bold claim that, for three cubes, local solvability is *enough*.

## The state of play

So where do we stand? We have a clean, complete, and final answer to one of the two halves: the numbers that are $\pm 4$ modulo $9$ are impossible, no exceptions, no loopholes, proved by nothing more than the arithmetic of remainders. We have overwhelming computational evidence, and not a single counterexample, for the other half. And we have a beautiful conjecture — nine is the whole story — that has resisted proof for decades despite its innocent appearance.

The sum of three cubes problem endures because it sits exactly on the boundary between the knowable and the unknown. One small number, nine, draws an unbreakable wall. Beyond that wall, we believe everything is reachable — but the proof, like the cubes for $33$, may be hiding very far away indeed.
