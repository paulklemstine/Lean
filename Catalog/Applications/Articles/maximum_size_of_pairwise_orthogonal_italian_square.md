# The Secret Geometry of Grids: How Many Puzzles Can Share a Board?

## A puzzle older than it looks

Take a square grid, say $4 \times 4$, and fill it with four symbols — call them $1, 2, 3, 4$ — so that every symbol appears exactly once in each row and exactly once in each column. You have just built one of the oldest and most stubbornly fascinating objects in all of mathematics. Sudoku players meet a constrained cousin of it every morning over coffee; agronomists used it to lay out experimental fields a century ago; cryptographers and coding theorists quietly rely on it to scramble and protect data today.

In this article we call such a grid an **Italian square** — a name that nods to the long European tradition of arranging symbols in balanced arrays. (Mathematicians more often call it a *Latin square*; the two words mean exactly the same thing.) An Italian square of order $n$ is an $n \times n$ array of $n$ symbols in which each symbol occurs once per row and once per column. Here is one of order $4$:

$$
\begin{array}{cccc}
1 & 2 & 3 & 4 \\
2 & 1 & 4 & 3 \\
3 & 4 & 1 & 2 \\
4 & 3 & 2 & 1
\end{array}
$$

One square is already pretty. The real magic begins when you try to make *two* squares cooperate.

## When two squares fall in love: orthogonality

Suppose you have two Italian squares of the same order, $L$ and $M$. Lay them on top of each other so that every cell now carries a *pair* of symbols: the entry from $L$ and the entry from $M$. We say $L$ and $M$ are **orthogonal** if, as you sweep across all $n^2$ cells, you see every possible ordered pair of symbols exactly once — never a repeat, never a gap.

To feel the constraint, try it with two squares of order $3$. Write the first square's symbols in capital letters and the second's in lowercase, then read off the pairs:

$$
\begin{array}{ccc}
Aa & Bb & Cc \\
Bc & Ca & Ab \\
Cb & Ac & Ba
\end{array}
$$

There are exactly $3 \times 3 = 9$ possible pairs $(X, y)$, and each of the nine cells shows a different one. The two squares are orthogonal. Such a pair is sometimes called a *Graeco-Latin square*, because the eighteenth-century master Leonhard Euler famously dressed one alphabet in Greek letters and the other in Latin.

Orthogonality is not a curiosity. It is the precise mathematical statement of "two independent classifications that never interfere." Imagine assigning $n$ medical treatments and $n$ diet plans to a square field of plots so that every treatment-diet combination is tested exactly once, in a way perfectly balanced across rows and columns of the field. That is two orthogonal squares doing real scientific work — and it is exactly how the statistician R. A. Fisher revolutionized agricultural experiments.

## The question that drives everything

Now raise the stakes. Instead of two squares, ask for a whole **family** of Italian squares, all of the same order $n$, that are **pairwise orthogonal** — meaning *every* two of them are orthogonal to each other. Such a family is called a set of *mutually orthogonal* squares.

The central question is brutally simple to state:

> **How many mutually orthogonal Italian squares of order $n$ can possibly exist?**

You might hope the answer grows without limit. It does not. There is a hard ceiling, and finding it is the heart of this story.

**The ceiling theorem.** *For every order $n \ge 2$, any family of pairwise orthogonal Italian squares contains at most $n - 1$ squares.*

A $4 \times 4$ board can host at most $3$ mutually orthogonal squares. A $10 \times 10$ board, at most $9$. No matter how cleverly you fill the grids, you cannot escape the bound $n - 1$. It is a law of the combinatorial universe.

## Why the ceiling is exactly $n - 1$

The proof is one of those gems where a seemingly impossible counting problem collapses under a single clever observation. Here is the idea in plain language.

First, a harmless normalization. Orthogonality does not care what we *name* the symbols in any individual square — we are free to relabel the symbols of each square independently, because permuting symbols just permutes which pairs appear, and "every pair exactly once" survives unchanged. So we may quietly relabel each square in our family so that its very first row reads $1, 2, 3, \dots, n$ in order. Call such squares *standardized*.

Now look at one specific cell — say the first cell of the *second* row — across all the standardized squares in our family. Each square places some symbol there. The punchline is:

> **No two distinct squares in the family can place the same symbol in that cell.**

Why? Suppose two standardized squares $L$ and $M$ both put the symbol $s$ in that cell. Both also have first row $1, 2, \dots, n$, so somewhere in the first row each of them shows the symbol $s$ — in the *same* column, the $s$-th one. That means the pair $(s, s)$ shows up at two different cells: once in the shared first row, and once in the second-row cell we are watching. But orthogonality demands every pair appear *exactly once*. Contradiction.

So the symbols appearing in that one watched cell are all distinct across our family. There are only $n$ symbols available — and one of them, the symbol that would force a clash with the diagonal pair in the first row, is forbidden. That leaves at most $n - 1$ usable symbols, hence at most $n - 1$ squares. The ceiling is born from nothing more than the pigeonhole principle applied to a single cell.

In our formal development this is the theorem named `card_le_card_sub_one`: any indexed family $L$ of pairwise orthogonal Italian squares over a symbol set with at least two elements satisfies (number of squares) $\le n - 1$.

## Can we actually reach the ceiling?

A ceiling you can never touch is a disappointment. The thrilling part is that for an enormous class of orders, the bound is not just an abstract limit — it is *achieved*, with room to spare in elegance.

The key is to stop thinking of symbols as arbitrary labels and start thinking of them as **numbers in a finite arithmetic system**. When $n$ is a *prime power* — that is, $n = p^k$ for a prime $p$ and an exponent $k \ge 1$, so $n \in \{2, 3, 4, 5, 7, 8, 9, 11, 13, 16, \dots\}$ — there exists a finite field of exactly $n$ elements, written $\mathrm{GF}(p^k)$. A field is a number system where you can add, subtract, multiply, and (crucially) divide by anything nonzero, with all the familiar laws of algebra intact. The integers modulo a prime form the simplest examples.

Inside such a field, build squares by a single beautiful formula. For each **nonzero** field element $a$, define the square $S_a$ whose entry in row $i$, column $j$ is

$$
S_a(i, j) = a \cdot i + j.
$$

That's the whole construction. The "slope" $a$ tilts the arithmetic; the column index $j$ slides it.

Three facts make this work, and each is a short, clean algebraic check:

1. **Every $S_a$ is a genuine Italian square.** Fix a row $i$; then $j \mapsto a \cdot i + j$ just adds a constant to $j$, which is a bijection of the field — so each symbol appears once per row. Fix a column $j$; then $i \mapsto a \cdot i + j$ is multiplication by the nonzero constant $a$ followed by a shift, again a bijection — so each symbol appears once per column. (These are the lemmas `affine_row_bij` and `affine_col_bij`.)

2. **Distinct slopes give orthogonal squares.** Take $a \ne b$, both nonzero. To check $S_a$ and $S_b$ are orthogonal, we must solve, for any target pair $(u, v)$, the system
$$
a \cdot i + j = u, \qquad b \cdot i + j = v.
$$
Subtracting the equations gives $(a - b)\, i = u - v$. Since $a \ne b$, the element $a - b$ is nonzero, so we may divide: $i = (u - v)/(a - b)$, and then $j = u - a \cdot i$ follows uniquely. Exactly one cell produces each pair — that is orthogonality on the nose. This is the lemma `affineSquare_orthogonal`, and the single fact that powers it is that *in a field, nonzero elements are invertible*. The whole construction hinges on being able to divide by $a - b$.

3. **There are exactly $n - 1$ slopes.** The nonzero elements of a field with $n$ elements number precisely $n - 1$. So the family $\{S_a : a \ne 0\}$ has $n - 1$ pairwise orthogonal squares — and it slams straight into the ceiling.

Combining the construction with the ceiling theorem gives the centerpiece result, which in our formalization is `maximum_mols_eq_card_sub_one`:

> **Over a finite field with $n \ge 2$ elements, the maximum number of mutually orthogonal Italian squares is exactly $n - 1$, and this maximum is attained.**

Specializing the field to a Galois field $\mathrm{GF}(p^k)$ yields the headline statement `exists_mols_prime_power`:

> **For every prime power $n = p^k \ge 2$, there exist $n - 1$ mutually orthogonal Italian squares of order $n$.**

## The smallest example you can hold in your hand

Take $n = 3$, the field of integers modulo $3$ with elements $\{0, 1, 2\}$. The nonzero slopes are $a = 1$ and $a = 2$, giving us exactly $n - 1 = 2$ squares.

For $a = 1$, $S_1(i,j) = i + j \bmod 3$:

$$
\begin{array}{ccc}
0 & 1 & 2 \\
1 & 2 & 0 \\
2 & 0 & 1
\end{array}
$$

For $a = 2$, $S_2(i,j) = 2i + j \bmod 3$:

$$
\begin{array}{ccc}
0 & 1 & 2 \\
2 & 0 & 1 \\
1 & 2 & 0
\end{array}
$$

Superimpose them and read the pairs:

$$
\begin{array}{ccc}
(0,0) & (1,1) & (2,2) \\
(1,2) & (2,0) & (0,1) \\
(2,1) & (0,2) & (1,0)
\end{array}
$$

All nine ordered pairs, each once. Two orthogonal squares of order $3$, conjured from nothing but the arithmetic of slopes — and $2$ is exactly the ceiling $3 - 1$.

## The famous hole in the floor: order 6

If the bound were always achievable, the story would end here in triumph. It does not, and the gap is one of the most romantic episodes in mathematics.

Euler, around 1782, posed his celebrated **36 officers problem**: arrange $36$ officers of six ranks and six regiments in a $6 \times 6$ square so that each row and each column contains one officer of every rank and one of every regiment. In our language, he was asking for **two** orthogonal Italian squares of order $6$ — far below the ceiling of $5$. Euler conjectured, correctly, that it is impossible, and in 1900 Gaston Tarry confirmed it by exhaustive analysis: **no two orthogonal squares of order $6$ exist.** For $n = 6$ the achievable maximum is just $1$, dramatically short of the bound $5$.

Euler went further and guessed that the same failure happens for every order of the form $4k + 2$ — orders $6, 10, 14, 18, \dots$. Here he was spectacularly wrong. In a triumph of mid-twentieth-century combinatorics, Bose, Shrikhande, and Parker — soon nicknamed "Euler's spoilers" — constructed orthogonal squares of order $10$, then of every order $4k+2$ above $6$. The lone exception to abundance is $6$ itself.

## Why prime powers, and what we still don't know

So the bound $n - 1$ is *attained* whenever $n$ is a prime power — that direction is now fully and rigorously established. The natural converse asks: **is $n - 1$ attainable only when $n$ is a prime power?** Reaching the full ceiling of $n - 1$ squares is equivalent to the existence of a **finite projective plane** of order $n$, one of the most elegant structures in geometry. Every known finite projective plane has prime-power order, and it is a famous open conjecture — unproven for over a century — that no others exist.

Partial knowledge fences the problem in. The Bruck–Ryser–Chowla theorem rules out infinitely many non-prime-power orders (for instance $6$, $14$, $21$, $22$); and a monumental computer search settled that **no projective plane of order $10$ exists**, so the full ceiling of $9$ squares is unreachable at $n = 10$ even though pairs and larger partial families do exist there. But for general $n$ the converse remains gloriously open. We have proven the half that can be proven — the prime-power construction reaching the bound — and we have been scrupulous not to claim the half that nobody yet can.

## Why any of this matters

These squares are not idle decoration. Orthogonal families are the combinatorial skeleton of:

- **Experimental design.** Balanced testing of multiple factors — fertilizers, drugs, machine settings — without confounding, the foundation Fisher laid for modern statistics.
- **Error-correcting codes.** A complete family of $n - 1$ mutually orthogonal squares is equivalent to a maximum-distance-separable code, the gold standard for detecting and repairing corrupted data.
- **Cryptography and hashing.** The affine maps $x \mapsto a x + b$ that generate our squares form a *sharply 2-transitive* group, the algebraic engine behind authentication codes and good hash functions.
- **Scheduling and tournaments.** Round-robin schedules, conflict-free time-tabling, and frequency assignment all reduce to coloring a grid with non-interfering classifications.

The deepest lesson, though, is aesthetic. We began with a children's puzzle — fill a grid so nothing repeats in a line. We asked a single sharp question — how many such grids can coexist in harmony? And the answer braided together the pigeonhole principle, the arithmetic of finite fields, eighteenth-century officers, and a geometry conjecture still open today. A ceiling of $n - 1$, touched effortlessly by the slopes of a finite field, yet hovering forever out of reach over a $6 \times 6$ board. That is the quiet, durable beauty of the secret geometry of grids.
