# How Big Can a Determinant Get? A Four-by-Four Detective Story

## A deceptively simple question

Take a grid of numbers — a square array of four rows and four columns. Fill in each of the sixteen slots with a whole number, but agree in advance not to use anything too large: every entry must lie between $-c$ and $c$ for some fixed budget $c$. Now compute the *determinant* of the resulting matrix, that single number encoding how the matrix stretches or shrinks volume.

Here is the question that has quietly occupied mathematicians for more than a century: **among all the matrices you could build under this budget, how large can the determinant possibly be?**

It sounds like the kind of thing you could settle in an afternoon. It is not. The general version of this problem — asking for the largest determinant of an $n \times n$ matrix whose entries are bounded in size — is known as *Hadamard's maximal determinant problem*, and it remains open in infinitely many cases. But the four-by-four case can be pinned down with surprising precision, and along the way it teaches a lesson about how easy it is to be fooled by a plausible-looking formula.

This is the story of that four-by-four case: the exact answer, an elegant construction that achieves it, and the demolition of a tempting but wrong guess that had been circulating.

## The determinant, in one paragraph

Before the chase, a quick reminder. The determinant of a square matrix measures the *signed volume* of the box spanned by its rows. If two rows point in nearly the same direction, the box is thin and the determinant is small. If the rows are all long *and* mutually perpendicular, the box is fat and the determinant is as large as it can be for rows of that length. This geometric picture — long, orthogonal rows make big determinants — is the single idea driving everything below.

For a $4 \times 4$ matrix there is an explicit, if lengthy, formula: expanding along the first row,
$$
\det M = M_{00}\,C_0 - M_{01}\,C_1 + M_{02}\,C_2 - M_{03}\,C_3,
$$
where each $C_i$ is itself the determinant of the $3 \times 3$ matrix left after deleting the first row and the $i$-th column. It is this expansion, ground out in full, that lets us compute exactly with the specific matrices below.

## The champion: a matrix of pure signs

Suppose your budget is $c = 1$, so every entry must be $-1$, $0$, or $1$. What is the best you can do? The answer is a beautiful object whose entries are all $\pm 1$ and whose rows are pairwise perpendicular:
$$
H = \begin{pmatrix} 1 & 1 & 1 & 1 \\ 1 & -1 & 1 & -1 \\ 1 & 1 & -1 & -1 \\ 1 & -1 & -1 & 1 \end{pmatrix}.
$$
Every row has length $\sqrt{1^2+1^2+1^2+1^2} = 2$, and any two distinct rows have dot product zero — they are genuinely orthogonal. This is a *Hadamard matrix*, named for Jacques Hadamard, who studied exactly these maximally "spread out" sign matrices in the 1890s.

Because its rows are four mutually perpendicular vectors each of length $2$, the box they span is a genuine four-dimensional cube of side $2$, with volume $2^4 = 16$. And indeed, grinding through the determinant formula gives
$$
\det H = 16.
$$
No $4 \times 4$ matrix of $\pm 1$ entries can do better: $16$ is the ceiling for sign matrices.

## Turning the budget dial: the answer scales

What happens when the budget $c$ is larger — say entries allowed anywhere from $-c$ to $c$? Here the structure of the problem hands us the answer almost for free. Take the very same Hadamard matrix and multiply every entry by $c$, producing the matrix $cH$. Its entries are now all $\pm c$, comfortably within budget, and multiplying a single row of a matrix by $c$ multiplies its determinant by $c$. There are four rows, so
$$
\det(cH) = c^4 \cdot \det H = 16\,c^4.
$$
This is the crucial *achievability* result: for any budget $c \ge 0$ there is a legal matrix whose determinant is exactly $16\,c^4$. The maximum determinant, whatever it is, is at least $16\,c^4$.

Notice the shape of the answer: a constant times $c^4$. This is no accident. Every one of the sixteen entries scales with $c$, and the determinant is a sum of products of four entries — one from each row — so it scales as $c^4$. The entire problem *separates*: solve the sign-matrix case once (the constant), and every larger budget is just that constant times $c^4$. The hard part is a single number; the dependence on $c$ is automatic.

## An easy ceiling

How large *could* the determinant get in principle? There is a crude but honest upper bound available with almost no work. The determinant is a sum over all $4! = 24$ ways of picking one entry from each row and column, each product being at most $c \cdot c \cdot c \cdot c = c^4$ in size. So
$$
|\det M| \le 24\,c^4
$$
for every legal matrix. Combined with the construction above, we have trapped the true maximum $D(c)$ in a narrow band:
$$
16\,c^4 \;\le\; D(c) \;\le\; 24\,c^4.
$$
The lower end is *achieved*, by the scaled Hadamard matrix. (The sharp truth is that the maximum equals exactly $16\,c^4$ — the crude factor $24$ can be tightened to $16$ using a deeper geometric inequality about volumes, which we return to at the end. But even the easy band already tells us the leading behavior.)

## The plausible guess that turned out to be wrong

Now the twist. A formula had been circulating claiming to give the exact maximum. Writing the budget as an odd number $c = 2k - 1$ (so $k = 1$ gives $c = 1$, $k = 2$ gives $c = 3$, and so on), the claim was that the maximum determinant equals
$$
(2k-1)^4 - 2(2k-1)^2 + 1.
$$
This is a tidy expression. It factors neatly as $\left(c^2 - 1\right)^2$. It looks like the sort of thing that ought to be right.

It is not right. In fact it is spectacularly wrong, and the smallest case exposes it immediately. Take $k = 1$, so $c = 1$ — the pure sign-matrix case. The formula evaluates to
$$
(1 - 1)^2 = 0.
$$
It predicts that the largest determinant achievable with $\pm 1$ entries is *zero*. But we have already met a matrix — the Hadamard matrix $H$ — whose determinant is $16$. A guessed "maximum" of $0$ that is beaten by an actual value of $16$ is not merely inaccurate; it is not even an upper bound.

The failure is not a fluke of the smallest case. For *every* $k \ge 1$, the scaled Hadamard matrix $cH$ with $c = 2k-1$ delivers a determinant of $16\,c^4$, and a short algebraic inequality shows
$$
(c^2 - 1)^2 < 16\,c^4 \qquad \text{whenever } c \ge 1.
$$
(To see it: $16c^4 - (c^2-1)^2 = 15c^4 + 2c^2 - 1$, which is positive for all $c \ge 1$.) So the circulating formula undershoots the truth at every single value of the budget. It is refuted across the board.

Where did the guess go wrong? It appears to have confused two different ways of normalizing the problem. In one common setting, one studies matrices whose *columns form a lattice of covolume $1$* and compares determinants against that unit scale; in another — ours — one bounds the *size of the entries* and asks for the largest determinant. These are genuinely different questions with different answers, and a formula tuned to the first normalization has no reason to survive in the second. The lesson is a familiar one in mathematics: a clean formula is seductive, but it must be tested against a concrete example before it is believed. One evaluation at $c = 1$ was enough to bring this one down.

## A hidden arithmetic rhythm

There is one more piece of structure worth savoring, because it reveals that the possible determinants are not spread smoothly over the number line but are quantized. For any $4 \times 4$ matrix whose entries are all $\pm 1$, the determinant is always divisible by $8$:
$$
8 \mid \det M.
$$
The reason is a small gem of an argument. Subtract the first row from each of the other three rows — an operation that leaves the determinant unchanged. Since every entry was $\pm 1$, each difference of two such entries is even: it is $0$, $2$, or $-2$. So the three modified rows now consist entirely of even numbers. Multilinearity of the determinant lets us pull a factor of $2$ out of each of those three rows, extracting $2 \times 2 \times 2 = 8$ overall. Whatever is left is still a whole-number determinant, so the original must have been a multiple of $8$.

This is the four-by-four instance of a general law: the determinant of an $n \times n$ sign matrix is always divisible by $2^{n-1}$. The consequence is striking — the achievable determinants do not vary continuously. For sign matrices they can only be multiples of $8$, and within the range $[-16, 16]$ the only values that actually occur are $-16, -8, 0, 8, 16$. The extremal problem is secretly a search over a coarse arithmetic ladder, not a smooth optimization.

## Why any of this matters

Maximal-determinant matrices are not a curiosity confined to a chalkboard. Hadamard matrices — the sign matrices that maximize the determinant — are the backbone of *optimal experimental design*, where they tell a scientist how to combine several yes/no factors across the fewest possible trials while extracting the most information. They generate *error-correcting codes* (the Hadamard code famously carried images back from the Mariner space probes) and underlie the *Hadamard transform* used in signal processing and quantum computing. In each case the same principle is at work that drove our four-by-four story: rows that are long and mutually perpendicular pack the most independent information into a fixed budget.

The four-by-four case is small enough to hold in your hand and rich enough to contain the whole drama: an elegant optimal construction, a clean scaling law that reduces every budget to a single constant, a hidden divisibility that quantizes the answers, and a cautionary tale about a beautiful formula that happened to be false. The largest determinant a four-by-four matrix can muster under a budget $c$ is $16\,c^4$ — achieved, once and for all, by a humble grid of plus and minus ones.
