# The Golden Right Triangle: How Fibonacci Numbers Build Pythagorean Triples

## A number that answers to two masters

Some numbers lead a double life. Take $5$: to a geometer it is the hypotenuse of the most famous right triangle in the world, the $3$–$4$–$5$ triangle that carpenters and surveyors have used for millennia to lay out a perfect corner. To an arithmetician, $5$ is a *Fibonacci number* — the fifth term in the sequence

$$0,\ 1,\ 1,\ 2,\ 3,\ 5,\ 8,\ 13,\ 21,\ 34,\ 55,\ \dots$$

in which every entry is the sum of the two before it. That the same small integer plays both roles could be a coincidence. But look one triangle further. The next celebrity right triangle is $5$–$12$–$13$, and there again the hypotenuse, $13$, is a Fibonacci number. Keep going and the pattern refuses to break: $16$–$30$–$34$, then $39$–$80$–$89$, then $105$–$208$–$233$. Every hypotenuse — $5, 13, 34, 89, 233$ — is a Fibonacci number.

This is not luck. It is the visible tip of a clean, complete theorem: **the Fibonacci sequence secretly manufactures an endless supply of right triangles**, and it does so with a precision that turns geometry into arithmetic and back again. This article tells the story of that machine — how four consecutive Fibonacci numbers snap together into a right triangle, why the hypotenuse is always Fibonacci, and how the triangle's area turns out to be nothing more mysterious than a product of Fibonacci numbers.

## The recipe

Write $F_n$ for the $n$-th Fibonacci number, so $F_0 = 0$, $F_1 = 1$, $F_2 = 1$, $F_3 = 2$, and in general $F_{n+2} = F_n + F_{n+1}$. Now grab any four *consecutive* Fibonacci numbers,

$$F_n,\quad F_{n+1},\quad F_{n+2},\quad F_{n+3},$$

and assemble three quantities out of them:

- a first leg $a = F_n \cdot F_{n+3}$ — the **product of the outer two**;
- a second leg $b = 2\,F_{n+1} F_{n+2}$ — **twice the product of the inner two**;
- a hypotenuse $c = F_{n+1}^{2} + F_{n+2}^{2}$ — the **sum of the squares of the inner two**.

The claim is that $(a, b, c)$ is always a Pythagorean triple: $a^2 + b^2 = c^2$.

Try it with $n = 1$. The four Fibonacci numbers are $F_1, F_2, F_3, F_4 = 1, 1, 2, 3$. Then $a = 1 \cdot 3 = 3$, $b = 2 \cdot 1 \cdot 2 = 4$, and $c = 1^2 + 2^2 = 5$. Out pops $3$–$4$–$5$. Take $n = 2$, with $1, 2, 3, 5$: now $a = 1\cdot 5 = 5$, $b = 2\cdot 2\cdot 3 = 12$, $c = 2^2+3^2 = 13$, and we have $5$–$12$–$13$. The recipe never fails.

## Why it works: Euclid meets Fibonacci

The reason is a marriage between two ideas separated by two thousand years.

More than two millennia ago, Euclid recorded a complete formula for right triangles with whole-number sides. Pick any two whole numbers $p > q$ and form

$$a = p^2 - q^2,\qquad b = 2pq,\qquad c = p^2 + q^2.$$

A single line of algebra confirms $a^2 + b^2 = c^2$, because $(p^2 - q^2)^2 + (2pq)^2 = (p^2+q^2)^2$. Every whole-number right triangle arises this way. Euclid's $p$ and $q$ are the *generators*: choose them, and a triangle appears.

The Fibonacci construction is simply **Euclid's formula fed by two consecutive Fibonacci numbers**. Set

$$p = F_{n+2}, \qquad q = F_{n+1}.$$

Two elementary facts about consecutive Fibonacci numbers do all the work. First, because $F_{n+2} = F_n + F_{n+1}$, the difference of the generators is another Fibonacci number:

$$p - q = F_{n+2} - F_{n+1} = F_n.$$

Second, their sum climbs one further up the sequence:

$$p + q = F_{n+2} + F_{n+1} = F_{n+3}.$$

Now watch Euclid's first leg dissolve into a product. Since $p^2 - q^2 = (p-q)(p+q)$,

$$a = p^2 - q^2 = (p - q)(p + q) = F_n \cdot F_{n+3}.$$

The other two pieces are immediate: $b = 2pq = 2\,F_{n+1}F_{n+2}$ and $c = p^2 + q^2 = F_{n+1}^2 + F_{n+2}^2$. The recipe is exactly Euclid's machine with the crank turned by Fibonacci. The Pythagorean identity $a^2 + b^2 = c^2$ then holds automatically, because it holds for *every* Euclid triple.

## The hypotenuse is always Fibonacci

Euclid's formula guarantees a right triangle, but it does not, on its own, promise anything special about the hypotenuse $c = p^2 + q^2$. The Fibonacci input is what makes the hypotenuse land back inside the sequence. The reason is a beautiful classical identity: **the sum of the squares of two consecutive Fibonacci numbers is again a Fibonacci number**, sitting at an odd index:

$$F_{m}^{2} + F_{m+1}^{2} = F_{2m+1}.$$

With $m = n+1$ this reads $F_{n+1}^2 + F_{n+2}^2 = F_{2n+3}$, so

$$c = F_{2n+3}.$$

The hypotenuses of the family are therefore $F_3, F_5, F_7, F_9, F_{11}, \dots = 2, 5, 13, 34, 89, \dots$ — precisely the **odd-indexed Fibonacci numbers**. (The first, $F_3 = 2$, belongs to the degenerate triangle at $n=0$; the genuine triangles start at $n=1$ with hypotenuse $F_5 = 5$.) An entire subsequence of the Fibonacci numbers is revealed to be a list of Pythagorean hypotenuses.

This odd-index identity is itself a special case of the *Fibonacci addition law* $F_{i+j} = F_i F_{j+1} + F_{i-1} F_j$, which, when the two indices are made equal, produces exactly a sum of two squares. The geometry of the triangle and the arithmetic of the sequence are two faces of one identity.

## The area is a product of four Fibonacci numbers

Here the construction delivers its most quietly elegant surprise. The area of a right triangle is half the product of its legs. For our family,

$$\text{Area} = \tfrac12\, a\, b = \tfrac12 \cdot \big(F_n F_{n+3}\big)\cdot\big(2\,F_{n+1}F_{n+2}\big) = F_n \cdot F_{n+1} \cdot F_{n+2} \cdot F_{n+3}.$$

The factor of $2$ in leg $b$ cancels the $\tfrac12$ perfectly, and the area of the triangle is simply the **product of all four consecutive Fibonacci numbers you started with**. For $n = 1$ the $3$–$4$–$5$ triangle has area $6 = 1\cdot 1\cdot 2\cdot 3$. For $n = 2$ the $5$–$12$–$13$ triangle has area $30 = 1\cdot 2\cdot 3\cdot 5$. A geometric measurement collapses into a bare arithmetic product, with nothing left over.

The perimeter is just as tidy. Adding the three sides and simplifying gives

$$P = a + b + c = 2\,F_{n+2}F_{n+3},$$

another clean product of two consecutive Fibonacci numbers. And the *inradius* — the radius of the largest circle that fits inside the triangle — which for any right triangle equals $(a + b - c)/2$, comes out to

$$r = F_n \cdot F_{n+1},$$

the product of the two *smallest* of the four Fibonacci numbers. Every natural quantity attached to the triangle — legs, hypotenuse, area, perimeter, inradius — is a short product or sum of Fibonacci numbers. The triangle is, through and through, an arithmetic object wearing a geometric costume.

## Golden ratios hiding in the shape

The Fibonacci numbers are famous for their link to the *golden ratio* $\varphi = (1+\sqrt5)/2 \approx 1.618$: the ratio $F_{n+1}/F_n$ marches steadily toward $\varphi$ as $n$ grows. That limit leaves fingerprints on the shape of our triangles.

Consider the ratio of area to perimeter, a natural measure of a triangle's "bulk relative to its boundary." From the formulas above,

$$\frac{\text{Area}}{P} = \frac{F_n F_{n+1} F_{n+2} F_{n+3}}{2\,F_{n+2}F_{n+3}} = \tfrac12\,F_n F_{n+1},$$

which grows without bound — the triangles get ever larger. But the *proportions* settle down. The two legs $a$ and $b$ approach a fixed ratio governed by $\varphi$, so the family converges in shape to a single limiting right triangle even as it explodes in size. The infinite list of triangles is not a random scatter; it is a sequence homing in on one golden silhouette.

## Why this is more than a curiosity

Pythagorean triples and Fibonacci numbers are each among the oldest objects in mathematics, and each has been studied exhaustively. What makes their meeting point worth telling is that it is *exact and complete*. There is no error term, no "for large $n$," no exceptional cases to sweep aside (beyond the single degenerate triangle at $n = 0$). Every leg, hypotenuse, area, perimeter, and inradius is pinned to a closed Fibonacci expression, and every identity is a polynomial consequence of the one recurrence $F_{n+2} = F_n + F_{n+1}$.

The construction also builds a *bridge*. Number theory studies the additive world of the Fibonacci recurrence; Euclidean geometry studies the multiplicative, squared world of $a^2 + b^2 = c^2$. Here a single substitution — feed consecutive Fibonacci numbers into Euclid's formula — carries facts freely across the bridge. An additive identity about consecutive terms ($F_{n+2} - F_{n+1} = F_n$) becomes a geometric one about a triangle's leg; an identity about sums of squares becomes the statement that hypotenuses are Fibonacci; a product of four sequence terms becomes an area. Each side of the bridge illuminates the other.

And it hints at more. The hypotenuses obey their own simple law, $c_{n+1} = 3c_n - c_{n-1}$, so the sequence $5, 13, 34, 89, 233, \dots$ can be generated by a single recurrence without ever mentioning triangles. The primitivity of the triples — whether the three sides share a common factor — turns out to be governed entirely by where the *even* Fibonacci numbers fall, which happens with perfect regularity every third step. What began as an idle observation about the number $5$ opens into a small, fully mapped landscape where arithmetic and geometry are the same terrain seen from two directions.

Grab four consecutive Fibonacci numbers. Out comes a right triangle whose hypotenuse is Fibonacci and whose area is their product. It is one of those rare mathematical facts that is at once elementary enough to check by hand and deep enough to feel inevitable — the golden ratio's quiet signature written into the corner of a triangle.
