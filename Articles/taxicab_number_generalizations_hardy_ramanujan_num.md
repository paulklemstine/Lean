# The Dullest Number That Wasn't: A Journey Through the Taxicab Numbers

## A famous cab ride

One of the most beloved anecdotes in the history of mathematics takes place beside a hospital bed. The brilliant, self-taught Indian mathematician Srinivasa Ramanujan lay ill in a sanatorium near London, and his mentor G. H. Hardy came to visit. Searching for small talk, Hardy remarked that he had arrived in taxicab number 1729, "a rather dull number," he added, hoping it was not a bad omen.

"No, Hardy," Ramanujan replied at once, "it is a very interesting number. It is the smallest number expressible as the sum of two cubes in two different ways."

He was right, and effortlessly so:

$$1729 = 1^3 + 12^3 = 1 + 1728,$$
$$1729 = 9^3 + 10^3 = 729 + 1000.$$

Two completely different pairs of cubes, one landing on the same total. That single observation launched an entire family of numbers now known as the **taxicab numbers**, and it poses a question that turns out to be surprisingly deep: how far can this game be pushed?

## What exactly are we counting?

Let us be precise. Given a whole number $N$, we call a pair of positive whole numbers $(a, b)$ a **representation** of $N$ if

$$a^3 + b^3 = N, \qquad a \le b.$$

The condition $a \le b$ simply prevents us from double-counting the same pair written in the opposite order; $(1,12)$ and $(12,1)$ describe the same decomposition, so we agree to record only the version with the smaller number first.

The number $1729$ has exactly **two** such representations. The natural next question — the one Ramanujan's remark practically begs us to ask — is: for each target count $n$, what is the *smallest* number that can be written as a sum of two positive cubes in $n$ different ways? That smallest number is called the **$n$-th taxicab number**, written $\mathrm{Taxicab}(n)$.

The first few values are:

- $\mathrm{Taxicab}(1) = 2 = 1^3 + 1^3$ (one way — the humble base case),
- $\mathrm{Taxicab}(2) = 1729$ (Ramanujan's number),
- $\mathrm{Taxicab}(3) = 87{,}539{,}319$,
- $\mathrm{Taxicab}(4) = 6{,}963{,}472{,}309{,}248.$

Notice how violently these numbers explode. Going from two ways to three ways multiplies the answer by roughly fifty thousand. Going from three to four multiplies it by nearly eighty thousand more. This ferocious growth is not an accident, and part of the story below is about pinning down exactly *why* it must happen.

## The three-way and four-way champions

The third taxicab number, $87{,}539{,}319$, is a genuine triple. Discovered by the computer scientist John Leech in 1957, it splits into three separate sums of cubes:

$$87{,}539{,}319 = 167^3 + 436^3 = 228^3 + 423^3 = 255^3 + 414^3.$$

You can check each line with patience and a calculator: $167^3 + 436^3 = 4{,}657{,}463 + 82{,}881{,}856 = 87{,}539{,}319$, and the other two lines land on the very same total. Three distinct pairs, one destination.

The fourth taxicab number is larger still — nearly seven trillion:

$$6{,}963{,}472{,}309{,}248 = 2421^3 + 19083^3 = 5436^3 + 18948^3 = 10200^3 + 18072^3 = 13322^3 + 16630^3.$$

Each of these decompositions is a real, checkable arithmetic fact, and each of the four pairs is genuinely different from the others. It is worth pausing on what "genuinely different" means, because it is the crux of the whole subject. A number with four representations does not merely *happen* to have four ways written down; it must have four *distinct* pairs of smaller-and-larger summands, no two overlapping. Establishing this pairwise distinctness — not just displaying the sums — is exactly what makes these facts more than idle arithmetic.

## A hidden rigidity: the smaller cube tells you everything

Here is a small but powerful structural observation. Suppose you know only the *smaller* number $a$ in a representation of some fixed target $N$. Do you now know the larger number $b$?

The answer is yes, and the reason is almost embarrassingly simple. If $a^3 + b^3 = N$, then $b^3 = N - a^3$, which fixes $b^3$ completely. And since a positive whole number has exactly one positive cube root, $b$ is determined. In other words:

> **The smaller summand determines the entire representation.** No two distinct representations of the same number can share the same smaller cube.

This "rigidity" sounds like a technicality, but it is the engine behind one of the main theorems below. Because every representation of $N$ carries its own unique smaller summand, counting representations is the same as counting distinct smaller summands. And distinct positive whole numbers cannot be squeezed together — they need room.

## Why the taxicab numbers must grow at least cubically

Now we can turn that rigidity into a hard, provable lower bound on how big $\mathrm{Taxicab}(n)$ has to be.

Suppose $N$ has $n$ different representations. Each one has its own smaller summand, and by the rigidity principle these $n$ smaller summands are all distinct positive whole numbers. Line them up in increasing order:

$$a_1 < a_2 < \cdots < a_n.$$

Because they are $n$ distinct positive integers, the largest of them cannot be smaller than $n$; the tightest possible packing is $1, 2, \ldots, n$, in which the top value is exactly $n$. So $a_n \ge n$.

But $a_n$ is the smaller cube of some genuine representation $a_n^3 + b_n^3 = N$, with $b_n$ at least as big as $a_n$ and strictly positive. Therefore

$$N = a_n^3 + b_n^3 > a_n^3 \ge n^3.$$

We have proved something clean and unconditional:

> **Cubic growth floor.** Any number expressible as a sum of two positive cubes in $n$ distinct ways must exceed $n^3$. In particular, $\mathrm{Taxicab}(n) > n^3$ for every $n$.

This is a real inequality with a real proof — a pigeonhole argument dressed in cubes. It explains, at least partially, the explosive growth we saw in the table: the fourth taxicab number *has* to exceed $4^3 = 64$, and of course it dwarfs that floor, weighing in at seven trillion. The floor is honest but generous; the true values race far above it, hinting that the real growth is dramatically faster than merely cubic.

## Scaling: how to manufacture representations for free

There is one more piece of structure worth telling, because it reveals both what is easy and what is genuinely hard about this subject.

Suppose $N = a^3 + b^3$. Multiply everything by a cube $t^3$:

$$N \cdot t^3 = (a\,t)^3 + (b\,t)^3.$$

So every representation of $N$ instantly becomes a representation of $N t^3$, simply by scaling both summands by $t$. And because scaling by a fixed positive $t$ never collapses two different pairs into one, this transformation is faithful: if $N$ has $n$ representations, then $N t^3$ has *at least* $n$ as well.

> **Cube-scaling principle.** Multiplying a number by a perfect cube cannot decrease its number of taxicab representations.

This is a satisfying, fully elementary fact — and it tempts you to think you could build ever more representations just by multiplying. But here is the subtlety: scaling only *transports* the representations you already had. It never conjures a genuinely new one out of thin air. To get a number with *more* representations than anything before it — to prove that $\mathrm{Taxicab}(n)$ exists at all for large $n$ — you need a source of truly new pairs, and scaling by cubes is not it.

## The frontier: does $\mathrm{Taxicab}(n)$ always exist?

This brings us to the great open horizon of the subject. It is *believed*, and in fact known, that for every $n$ there is some number expressible as a sum of two positive cubes in at least $n$ ways — so that $\mathrm{Taxicab}(n)$ is always a well-defined finite number. But the known proofs are anything but elementary. They pass through the theory of **elliptic curves**.

The equation $x^3 + y^3 = N$, viewed over the rational numbers, is an elliptic curve — one of the most studied objects in modern number theory. Such a curve can carry a rational point of "infinite order," a seed point from which the curve's group law generates an endless supply of further rational solutions. Collect $n$ of these rational representations, clear their denominators by multiplying through by a common cube, and they all land on a single integer that now inherits $n$ distinct integer representations. That is how mathematicians know the taxicab numbers never run out.

The cube-scaling principle above is, in a sense, the elementary shadow of this deep machinery: it shows you can move representations around by multiplying by cubes, but it stops exactly at the boundary where the genuinely new points must come from the elliptic curve's group law. Isolating that boundary — knowing precisely which arithmetic input the elementary toolkit cannot supply — is itself a form of understanding.

## Why any of this matters

At first glance, taxicab numbers look like a parlor trick: cute coincidences of arithmetic, fit for a hospital-room anecdote and little else. But they are a doorway. The question "in how many ways can a number be written as a sum of two cubes?" is a special case of the vast program of understanding integer solutions to polynomial equations — the subject of Diophantine geometry. The moment you ask for *many* solutions to $x^3 + y^3 = N$, you are forced to confront the arithmetic of elliptic curves, the same objects at the heart of the proof of Fermat's Last Theorem and of modern cryptography.

Ramanujan's instant reply was not merely a feat of memory. It was a window into the idea that whole numbers hide rich, layered structure, and that even the "dullest" number might, on closer inspection, be interesting after all. Every integer, Hardy later mused, was one of Ramanujan's personal friends. The taxicab numbers are a reminder of why: pull on the loose thread of a single coincidence, and an entire theory unspools.

So the next time you climb into a taxi, glance at the number. It may be duller than $1729$ — but then again, so is almost every number, and each one is waiting for someone to notice what makes it interesting.
