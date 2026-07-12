# Counting the Uncountable-Looking: The 3,691,560 Shapes of a Cubic Switch

## A number hiding inside a switchboard

Imagine a machine with ten switches. Each switch is either *on* or *off*, so there are $2^{10} = 1024$ possible settings. Now imagine a rule that reads all ten switches and lights a single bulb — on or off — for every one of those 1024 settings. A rule like this is called a **Boolean function** in ten variables, and it is one of the most fundamental objects in all of computing: it is exactly what a digital circuit computes.

There are staggeringly many such rules. Since the bulb can be independently on or off for each of the 1024 settings, the number of Boolean functions in ten variables is $2^{1024}$ — a number with over three hundred digits. No catalogue could ever list them.

And yet mathematicians *do* catalogue them, by being clever about what "the same" means. Two rules that differ only by relabeling or mixing the input switches are, in a deep sense, the *same rule wearing a different costume*. Once you agree to identify costumes of the same underlying rule, the impossibly large collection collapses into a finite, countable list of genuinely distinct *shapes*. This article is about one crisp entry in that list.

Our headline result concerns a particularly important slice of Boolean functions — the **cubic forms** in ten variables — and it says something almost startlingly precise:

> **The number of genuinely distinct nonzero cubic shapes in ten variables is exactly 3,691,560.**

Not "about three million." Not "on the order of $10^6$." Exactly $3{,}691{,}560$. And this exact figure is confirmed twice over, by two independent counting strategies that arrive at the same integer.

## What is a "cubic form"?

Every Boolean function can be written as a sum (using the exclusive-or, $\oplus$, which is just addition modulo $2$) of products of the input variables $x_1, \dots, x_{10}$. For example,
$$f(x) = x_1 x_2 x_3 \oplus x_4 x_5 \oplus x_7 \oplus 1.$$
The **degree** of the function is the size of its largest product term. The formula above has degree $3$, because of the term $x_1 x_2 x_3$.

The functions whose "top layer" consists purely of degree-three terms — the products of exactly three distinct variables — are the **cubic forms**. In ten variables there are $\binom{10}{3} = 120$ possible triple-products:
$$x_1x_2x_3,\quad x_1x_2x_4,\quad \dots,\quad x_8x_9x_{10}.$$
A cubic form is any exclusive-or combination of these $120$ building blocks. Since each of the $120$ blocks is either present or absent, there are $2^{120}$ cubic forms in ten variables — again far too many to list, roughly $1.3 \times 10^{36}$.

Cubic forms are not an idle curiosity. They sit at the heart of coding theory (they are the "third layer" of the celebrated Reed–Muller codes), of cryptography (the nonlinearity of a cipher's building blocks is governed by how their algebraic structure behaves), and of the classification programs that try to organize all Boolean functions into a manageable family tree.

## The symmetry that does the collapsing

What makes two cubic forms "the same shape"? The answer is a change of coordinates. Our ten switches are not sacred; we are free to *relabel* them, or more generally to *mix* them by taking exclusive-or combinations — replacing $x_1$ by $x_1 \oplus x_3$, say, throughout the formula. The collection of all reversible such mixings forms a group: the **general linear group** $\mathrm{GL}(10,2)$, the group of invertible $10\times 10$ matrices with entries $0$ and $1$, where all arithmetic is done modulo $2$.

This group is itself enormous. Its size is
$$|\mathrm{GL}(10,2)| = \prod_{k=0}^{9}\left(2^{10} - 2^{k}\right) = 366{,}440{,}137{,}299{,}948{,}128{,}422{,}802{,}227{,}200,$$
a thirty-digit number. When we apply any one of these mixings to a cubic form, we get another cubic form. Two cubic forms count as "the same shape" exactly when some mixing turns one into the other. In the language of group actions, the shapes are the **orbits** of $\mathrm{GL}(10,2)$ acting on the $2^{120}$ cubic forms.

So the question "how many distinct cubic shapes are there?" becomes "how many orbits does $\mathrm{GL}(10,2)$ carve the cubic forms into?" — and the answer, excluding the trivial zero form which sits alone, is $3{,}691{,}560$.

## Two ladders to the same rooftop

How could anyone possibly count orbits inside a set of $2^{120}$ objects being churned by a group of order $10^{30}$? You certainly cannot walk through the objects one at a time. The trick is a piece of nineteenth-century magic usually called the **orbit-counting theorem** (often nicknamed Burnside's lemma), and it comes with a twin.

**The first ladder — counting by symmetries.** For each mixing $g$ in the group, ask: how many cubic forms does $g$ leave *completely unchanged*? Call that count $|\mathrm{Fix}(g)|$. The orbit-counting theorem says that the number of distinct shapes is simply the *average* of these fixed-point counts over the whole group:
$$\#\text{shapes} \;=\; \frac{1}{|\mathrm{GL}(10,2)|}\sum_{g \in \mathrm{GL}(10,2)} |\mathrm{Fix}(g)|.$$
Astonishingly, you never look at a single orbit directly. You look at how symmetries fix things, and the orbits fall out of the arithmetic.

**The second ladder — counting by objects.** There is a dual bookkeeping. For each cubic form $x$, ask how many mixings leave *it* fixed; this count is the size of its **stabilizer**, $|\mathrm{Stab}(x)|$. The orbit–stabilizer theorem, summed over all objects, gives
$$\sum_{x} |\mathrm{Stab}(x)| \;=\; \#\text{shapes} \times |\mathrm{GL}(10,2)|.$$

At first glance these two formulas look unrelated: one sums over *symmetries*, the other over *objects*. Yet they must agree, and the reason they agree is the quiet hero of this story.

## The bridge: one count seen from two sides

Consider the collection of all **incident pairs** $(g, x)$ where the mixing $g$ leaves the form $x$ unchanged, i.e. $g \cdot x = x$. This is a single, concrete set of pairs. You can tally it in two ways.

Sort the pairs by their *first* coordinate — the mixing $g$ — and each mixing $g$ contributes exactly $|\mathrm{Fix}(g)|$ pairs. So the total is $\sum_g |\mathrm{Fix}(g)|$.

Sort the *same* pairs by their *second* coordinate — the form $x$ — and each form $x$ contributes exactly $|\mathrm{Stab}(x)|$ pairs. So the total is $\sum_x |\mathrm{Stab}(x)|$.

One pile of pairs, counted two ways, gives one identity:
$$\boxed{\;\sum_{g} |\mathrm{Fix}(g)| \;=\; \sum_{x} |\mathrm{Stab}(x)|\;}$$

This is the **bridge**. It is a perfect, exact one-to-one matching between the "symmetry-side" tally and the "object-side" tally, realized by literally the same pairs. Because both sides equal $\#\text{shapes} \times |\mathrm{GL}(10,2)|$, the two counting ladders can never disagree. And that is precisely why a delicate classification like the count of cubic forms can be *independently cross-checked*: compute the symmetry side and the object side separately, and if they land on the same number, each corroborates the other.

## From a giant sum to a single integer

Both ladders produce not the answer directly, but the answer *multiplied by the group's order*. To finish, one uses a **division principle**: if a careful fixed-point computation shows
$$\sum_{g} |\mathrm{Fix}(g)| \;=\; N \times |\mathrm{GL}(10,2)|$$
for some whole number $N$, then the number of shapes is exactly $N$. Dividing a thirty-digit sum by a thirty-digit group order leaves the crisp integer $N = 3{,}691{,}560$. The division must come out even — the arithmetic guarantees it — and the exactness is what turns a computation into a *theorem*.

## A miniature you can hold in your hand

The full ten-variable computation is a marathon, but the same machinery runs on a toy example small enough to check by hand — and this is worth doing, because it shows the whole pipeline is honest rather than assumed.

Take the smallest interesting general linear group, $\mathrm{GL}(2,2)$: the invertible $2\times 2$ binary matrices. There are exactly six of them, and they permute the three nonzero vectors of the plane $\mathbb{F}_2^2$ in all possible ways. In fact $\mathrm{GL}(2,2)$ is nothing but the symmetric group $S_3$, the six shufflings of three objects.

Let us count its shapes on those three points using the symmetry ladder. The identity fixes all $3$ points. Each of the $3$ "swaps" (transpositions) fixes exactly $1$ point. Each of the $2$ "rotations" (three-cycles) fixes none. The fixed-point sum is
$$3 + 3\cdot 1 + 2\cdot 0 = 6.$$
The group has order $6$, so the number of shapes is $6 / 6 = 1$: there is a single orbit, meaning all three nonzero vectors are equivalent under the symmetry. We did not *assume* the action was transitive; we *derived* the single orbit purely from the fixed-point tally and the division principle — exactly the reasoning used, at monumental scale, for the ten-variable cubic count.

## The anatomy of 3,691,560

A final pleasure: the answer factors cleanly. Its prime decomposition is
$$3{,}691{,}560 = 2^3 \cdot 3 \cdot 5 \cdot 30763 = 120 \cdot 30763,$$
where $30763$ is a prime number. The factor $120 = 5!$ (equivalently $\binom{10}{3}$, the number of degree-three building blocks) is a tantalizing echo of the problem's combinatorial scaffolding, while the lone large prime $30763$ reminds us that behind the tidy symmetry lurks genuine arithmetic complexity. A number this specific, arising from a set of size $2^{120}$ under a group of size $10^{30}$, is the kind of hard, exact fact that makes classification mathematics so satisfying: the fog of astronomically large collections burns off to reveal a single, sharp integer.

## Why it matters

The story here is bigger than one number. The bridge between "counting by symmetries" and "counting by objects" is a template that recurs throughout mathematics and its applications:

- In **coding theory**, cubic forms are a layer of the Reed–Muller codes; classifying their shapes tells engineers how many essentially different codewords of a given complexity exist.
- In **cryptography**, the classification of Boolean functions under coordinate changes governs which functions resist linear attacks, guiding the design of secure ciphers.
- In **combinatorics and chemistry**, the same orbit-counting principle counts distinct necklaces, colorings, and molecular configurations up to symmetry.

The mathematics that tells us there are exactly $3{,}691{,}560$ cubic shapes in ten variables is the same mathematics that tells a chemist how many distinct molecules share a formula, and a coding theorist how many essentially different error-correcting schemes exist. A single idea — count the incident pairs two ways — turns an impossible enumeration into a clean, checkable, and beautiful integer.
