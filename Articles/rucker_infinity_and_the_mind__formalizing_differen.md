# Infinity Is a Place You Can Visit

## A traveler's guide to the endless staircase of infinities

Ask a child what the biggest number is, and after a moment's thought they will grin and say, "There isn't one — you can always add one more." That instinct is exactly right, and it is also the doorway to one of the most disorienting and beautiful discoveries in all of mathematics: not only are there infinitely many numbers, there are infinitely many *sizes of infinity*, and they are stacked one above the other in an endless tower that no vantage point can see the top of.

The writer and mathematician Rudy Rucker once described infinity not as a vague fog at the edge of thought but as a landscape — a place you can actually travel to, one summit at a time. This article is a guide to that landscape. We will climb the first few steps of the staircase, learn why the staircase never ends, discover that some heights can never be reached from below, and meet a single innocent-looking equation whose truth or falsehood the human race has never been able to settle.

## Counting past the end of counting

The first infinity is the one you already know: the sizes of the collections $\{1, 2, 3, \dots\}$, $\{0, 1, 2, \dots\}$, the even numbers, the fractions. All of these are *countable* — you can, in principle, line them up in a list, a first, a second, a third, and never miss one. Mathematicians call this size $\aleph_0$ (pronounced "aleph-null"), the smallest infinity.

It is genuinely surprising that the fractions are countable — there seem to be so many more of them than whole numbers — but they can be arranged into a single list, so their size is exactly $\aleph_0$. For a while it looks as though *every* infinite collection might be the same size. Perhaps "infinite" simply means "$\aleph_0$," and there is nothing more to say.

That comfortable idea was demolished by Georg Cantor in the 1870s with an argument of breathtaking economy. Consider the collection of *all* infinite sequences of 0s and 1s — or, equivalently, all the real numbers between 0 and 1 written as decimals. Suppose someone claims to have listed them all:

$$
\begin{aligned}
s_1 &= 0.\,\mathbf{d_{11}}\, d_{12}\, d_{13}\, \dots \\
s_2 &= 0.\, d_{21}\, \mathbf{d_{22}}\, d_{23}\, \dots \\
s_3 &= 0.\, d_{31}\, d_{32}\, \mathbf{d_{33}}\, \dots \\
&\vdots
\end{aligned}
$$

Cantor builds a brand-new sequence by walking down the diagonal and *changing every digit he meets*: wherever the list has a 0 he writes a 1, and vice versa. The resulting number differs from $s_1$ in the first place, from $s_2$ in the second place, from $s_n$ in the $n$-th place — so it cannot appear anywhere on the list. The list was incomplete, and it always will be, no matter how it is drawn up. There is no list of all the reals. The continuum is *strictly larger* than $\aleph_0$. This size is written $2^{\aleph_0}$, also called the *continuum* and denoted $\mathfrak{c}$, and Cantor's theorem says plainly:

$$
\aleph_0 < 2^{\aleph_0}.
$$

## The staircase that never ends

The diagonal trick was not a one-time miracle. It works for *any* collection whatsoever. Given a set $S$, consider its **power set** $\mathcal{P}(S)$ — the collection of all of $S$'s subsets. Cantor's theorem in full generality states that

$$
|S| < |\mathcal{P}(S)|
$$

for every set $S$, finite or infinite. A set can never be put into one-to-one correspondence with the collection of its own subsets; there are always "too many" subsets. The proof is the diagonal argument in disguise: any proposed matching of elements to subsets leaves out the cunningly defined set of "all elements not belonging to the subset they are matched with."

This single fact has a staggering consequence. Start anywhere — say at $\aleph_0$ — and take the power set. You land on something strictly bigger. Take the power set of *that*, and you land higher still. Repeat forever. We can write this **tower of infinities** explicitly. Define a sequence of cardinals by starting at the countable infinity and repeatedly exponentiating:

$$
T_0 = \aleph_0, \qquad T_{n+1} = 2^{T_n},
$$

so that

$$
\aleph_0 = T_0 < T_1 = 2^{\aleph_0} < T_2 = 2^{2^{\aleph_0}} < T_3 < \cdots
$$

Every rung is genuinely infinite (each is at least $\aleph_0$), and every rung is *strictly* below the next, precisely because $c < 2^c$ always holds. The tower is a rigorous, concrete realization of Rucker's image: an explicit itinerary of larger and larger infinities, each a real destination, each reachable by a single well-defined step from the one before.

And the staircase has no top. Suppose, for contradiction, that there were a largest infinity $M$ — a cardinal at least as big as every other. Then $2^M$ would be strictly larger than $M$, contradicting its supposed maximality. So **there is no largest infinity**: above every cardinal sits a strictly larger one. The sizes of infinity do not form a set with a ceiling; they form an unbounded, ever-ascending hierarchy — what mathematicians call a *proper class*. You can always visit somewhere higher.

## Reaching new heights without the power set

The power set is one engine for building bigger infinities, but it is not the only one, and there is something philosophically uncomfortable about it: it takes *all* subsets of a set at once, an enormous and somewhat mysterious act of collection. Is there a more frugal way to guarantee that we can always climb higher?

Yes — and it is one of the quiet gems of the subject, due to Friedrich Hartogs in 1915. **Hartogs' theorem** says: for *any* collection $\alpha$ whatsoever, there is a *well-ordered* structure — an ordinal — whose size is strictly greater than that of $\alpha$. An ordinal is an infinity equipped with a tidy, list-like ordering in which every non-empty part has a first element. The remarkable thing is that Hartogs manufactures this larger, well-ordered infinity *without ever forming the power set of $\alpha$* and without any appeal to arbitrary choices. Concretely, one can take the smallest ordinal whose cardinality is bigger than $|\alpha|$: its size $o$ satisfies

$$
|\alpha| < o.
$$

Hartogs' theorem is the seed from which the orderly **aleph sequence** grows: $\aleph_0, \aleph_1, \aleph_2, \dots$, and onward through the transfinite. Each aleph is the next well-ordered size after the one before, guaranteed to exist by exactly this construction.

## The first uncountable summit, and the riddle at its foot

The very first application of Hartogs' construction gives us $\aleph_1$, the *first uncountable infinity* — the smallest size that is genuinely bigger than $\aleph_0$. By construction it is uncountable:

$$
\aleph_0 < \aleph_1,
$$

and there is nothing strictly between them; $\aleph_1$ is the immediate next step above the countable.

Now we have two ways of naming "the next infinity after $\aleph_0$." One is $\aleph_1$, the next *well-ordered* size. The other is $2^{\aleph_0} = \mathfrak{c}$, the size of the continuum handed to us by Cantor's diagonal. It is a theorem — provable, settled, no controversy — that

$$
\aleph_1 \le \mathfrak{c}.
$$

The first uncountable infinity is *no larger than* the continuum. The burning question is whether they are *equal*. This is the celebrated **Continuum Hypothesis** (CH):

$$
\aleph_1 = 2^{\aleph_0}.
$$

In plain words: is the continuum the *very first* uncountable infinity, or does it leap over hidden intermediate sizes? Is there a set of real numbers too big to be countable yet too small to match all the reals?

Because the inequality $\aleph_1 \le \mathfrak{c}$ is already a theorem, the entire mystery of CH collapses into the single reverse inequality $\mathfrak{c} \le \aleph_1$. CH is true exactly when the continuum is *no bigger* than the first uncountable cardinal — one clean $\le$ sign carrying the whole weight of the problem.

Here the story takes its most famous turn. Kurt Gödel (1940) and Paul Cohen (1963) proved, between them, that CH can be *neither proved nor disproved* from the standard axioms of mathematics. Both "$\mathfrak{c} = \aleph_1$" and "$\mathfrak{c} > \aleph_1$" are perfectly consistent. The universe of sets simply does not tell us, on the basis of the usual rules, how big the continuum is. It is the first great example of a concrete mathematical question that is *independent* of our axioms — undecidable not because it is vague, but because our foundations are genuinely silent.

## What we *can* say about the continuum

Independence does not mean anarchy. Even though we cannot pin down $\mathfrak{c}$ exactly, we can *rule out* many possible values, and the tool that does it is another of Cantor-era set theory's crown jewels: **König's theorem**. One of its consequences concerns *cofinality* — a measure of how "reachable from below" an infinity is. The cofinality of a cardinal is the shortest length of an ascending sequence of smaller cardinals that piles up to reach it. Some infinities can be sneaked up on by a short sequence; others cannot.

König's theorem implies that the continuum has **uncountable cofinality**: you can *never* reach $\mathfrak{c}$ as the limit of a mere countable sequence of smaller infinities,

$$
\aleph_0 < \operatorname{cof}(\mathfrak{c}).
$$

This one fact demolishes a tempting guess. There is a natural "limit" infinity called $\aleph_\omega$ — the first infinity you reach by stacking $\aleph_0, \aleph_1, \aleph_2, \dots$ and taking the limit. It is built, by its very nature, as the limit of a countable ascending sequence, so its cofinality is exactly $\aleph_0$. But the continuum's cofinality is *bigger* than $\aleph_0$. The two cannot be the same size. Therefore, provably and with no hypotheses whatsoever:

$$
\mathfrak{c} \ne \aleph_\omega.
$$

The continuum's exact size is beyond our axioms — but it is *not* $\aleph_\omega$, and König's theorem tells us so outright. We are ignorant of the answer, but not helplessly so; the landscape has firm walls even where it has no marked destination.

## The first place you cannot climb to

Our final vista looks toward the frontier of modern set theory: the **large cardinals**, infinities so vast that their existence cannot even be proved from the standard axioms and must be *assumed* as new principles. The gateway to that world is the notion of an **inaccessible** cardinal — an infinity that cannot be reached from below by any of the usual construction methods. Precisely, a cardinal is inaccessible if it is:

1. **uncountable**;
2. **regular** — it cannot be reached as the limit of a *shorter* ascending sequence (its cofinality equals itself); and
3. a **strong limit** — whenever a smaller infinity $x$ lives below it, the far larger $2^x$ still lives below it too.

Inaccessible cardinals are the base camp of the large-cardinal mountains. But here is a delightful observation that closes our tour by returning to where it began. Look carefully at $\aleph_0$, the humble countable infinity. It *is* regular: you cannot reach it by stacking finitely many finite quantities. And it *is* a strong limit: if $x$ is any finite number, then $2^x$ is still finite, hence still below $\aleph_0$. In other words, $\aleph_0$ satisfies *two of the three* clauses of inaccessibility, and fails the third for one reason only — inaccessibility, by decree, insists on being uncountable, and $\aleph_0$ is the countable infinity.

Strip away that one clause and $\aleph_0$ is the perfect prototype of an unreachable place: the first infinity, the one you cannot climb up to from the finite world no matter how you stack, multiply, or exponentiate your finite ingredients. The endless staircase begins with a step that itself cannot be reached from below — and it ascends, past the continuum, past the towers of power sets, past the alephs, up toward inaccessible peaks whose very existence is an act of mathematical faith.

Infinity, it turns out, really is a place you can visit. You just never run out of new places to go.
