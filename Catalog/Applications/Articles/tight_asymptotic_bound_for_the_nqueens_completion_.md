# The Queens That Always Fit: How Far Can You Crowd a Chessboard Before It Locks Up?

Place a single queen on an empty chessboard. Can you always finish the job —
adding queens until every row, every column, and the whole board is covered by a
non-attacking army? On a standard $8 \times 8$ board the answer is famously *yes*,
but the question hides a much deeper one. Suppose an adversary scatters not one
queen but a whole crowd of them, all mutually peaceful. How many can they place
before the board *locks up* — before it becomes impossible to extend their
arrangement to a complete solution? This is the **n-queens completion problem**,
and it sits at the crossroads of recreational puzzles, combinatorics, and the
theory of randomized algorithms.

This article tells the story of a clean mathematical core inside that problem: a
single elegant construction that simultaneously *solves* the puzzle for an infinite
family of board sizes and *guarantees* that no single placed queen can ever spoil
the game. Along the way we will meet a marriage theorem, a slope-2 line wrapped
around a torus, and a stubborn constant — $0.216$ — that marks the frontier of
what is currently known.

## The rules, made precise

The $n$-queens problem lives on an $n \times n$ grid. A **queen** at position
$(r, c)$ attacks any other queen sharing its row $r$, its column $c$, or either of
its two diagonals. To talk about diagonals cleanly, give each cell two integer
coordinates: its **anti-diagonal index** $r + c$ and its **main-diagonal index**
$r - c$. Two cells lie on a common diagonal exactly when one of these indices
agrees. So we declare that cells $a$ and $b$ **attack** each other when

$$a_{\text{row}} = b_{\text{row}} \quad\text{or}\quad a_{\text{col}} = b_{\text{col}} \quad\text{or}\quad a_{\text{row}}+a_{\text{col}} = b_{\text{row}}+b_{\text{col}} \quad\text{or}\quad a_{\text{row}}-a_{\text{col}} = b_{\text{row}}-b_{\text{col}}.$$

A set $Q$ of queens is **non-attacking** if no two distinct members attack each
other. A **full solution** is a non-attacking set of exactly $n$ queens — the
maximum possible, since each of the $n$ rows can hold at most one. A partial
arrangement $Q$ is **completable** if it is a subset of some full solution.

Two simple but load-bearing facts come for free. In any non-attacking placement,
each row holds at most one queen and each column holds at most one queen. (If two
queens shared a row, they would attack along it; same for columns.) So a full
solution is really a *permutation*: it picks exactly one cell in every row, with
all columns distinct, and no two on a shared diagonal.

## The completion threshold, and a number worth chasing

Now imagine the adversary's game. They place some non-attacking queens; you try to
finish. Define the **completion threshold** $qc(n)$ informally as the largest size
of an arrangement that is *guaranteed* to be completable — place fewer than $qc(n)$
peaceful queens and you can always finish; allow more and some arrangement gets
stuck. How does this threshold grow with the board size $n$?

A landmark conjecture says the answer settles to a precise *density*:

$$\limsup_{n \to \infty} \frac{qc(n)}{n} = 0.216.$$

The constant $0.216$ is exactly $27/125$. It says that, in the worst case, you can
crowd a board up to roughly twenty-two percent of its rows with peaceful queens and
still always finish — but push past that fraction and unsolvable configurations
begin to appear infinitely often. This is a hard, research-level statement, and it
remains a conjecture. What we *can* prove rigorously are the structural pillars on
which any attack on such a conjecture must rest: that solutions exist in abundance,
that small obstructions never lock the board, and that a generous fraction of any
sparse arrangement can always be repaired.

## A line that wraps around the world

The first pillar is an explicit solution that works for infinitely many board
sizes. The trick is to stop thinking of the board as a flat grid and start
thinking of it as a **torus**: identify the coordinates modulo $n$, so that row
$n$ is the same as row $0$. On this wrapped board, arithmetic becomes a powerful
weapon.

Consider the placement that puts a queen in column $2x + b$ of row $x$, for every
row $x = 0, 1, \dots, n-1$, where $b$ is a fixed offset. Geometrically this is a
straight line of slope $2$, marching diagonally across the torus and wrapping
around as it goes. Call this set of queens $\text{diagGraph}(b)$.

Does it work? Rows are automatically distinct — we used each row once. The columns
$2x + b$ are distinct precisely when doubling is reversible modulo $n$, i.e. when
$2$ has a multiplicative inverse mod $n$. The diagonals require a little more. A
queen in row $x$ has anti-diagonal index $x + (2x + b) = 3x + b$ and main-diagonal
index $x - (2x + b) = -x - b$. Two queens collide on an anti-diagonal exactly when
$3x + b = 3x' + b$, that is, when $3x = 3x'$ — impossible for distinct rows as long
as $3$ is invertible mod $n$. They collide on a main-diagonal exactly when
$-x - b = -x' - b$, i.e. $x = x'$ — again impossible for distinct rows, with no
condition at all.

So the slope-2 line is a perfect non-attacking solution **whenever both $2$ and
$3$ are invertible modulo $n$** — equivalently, whenever $n$ shares no common
factor with $6$. In symbols, $\gcd(n, 6) = 1$. This gives our first headline
result:

> **Existence of solutions.** Whenever $\gcd(n, 6) = 1$, the $n$-queens problem has
> a full solution, namely the toroidal line $x \mapsto 2x + b$.

There are infinitely many such board sizes — every number of the form $6k + 1$
qualifies, for instance ($7, 13, 19, 25, \dots$), as does every $6k+5$. So this is
not a sporadic trick but an infinite, uniform family of solutions, all given by a
single closed formula.

## Why one queen can never lock the board

The second pillar is where the construction really earns its keep. The offset $b$
was free — we can slide the whole slope-2 line up or down. That freedom turns out
to be exactly enough to *catch any single cell we like*.

Suppose an adversary places one queen anywhere, at $(r, c)$. We want a full
solution containing it. Just choose the offset $b = c - 2r$. Then in row $r$ our
line sits in column $2r + b = 2r + (c - 2r) = c$ — precisely the adversary's cell.
The rest of the line fills out a complete non-attacking solution around it. Hence:

> **Single-queen completion.** Whenever $\gcd(n, 6) = 1$, *any* single placed queen
> can be extended to a full solution.

In the language of the completion threshold, this says $qc(n) \ge 1$ for the entire
infinite family $\{n : \gcd(n,6) = 1\}$: one peaceful queen is never an obstruction.
It may sound modest, but it is the base case of the whole edifice — the proof that
the threshold is genuinely positive, achieved not by a clever case analysis but by
the *same* slope-2 line, merely shifted into place.

## From one queen to many: a marriage theorem

What happens when the adversary places not one queen but a small crowd? Here the
toroidal trick alone no longer suffices, and we call on a classical tool: **Hall's
Marriage Theorem**. Picture a bipartite matching problem whose left side is the set
of rows and whose right side is the set of columns. We must marry each empty row to
an empty column so that the resulting cell avoids the diagonals of every pre-placed
queen.

The bookkeeping is a double count. A single pre-placed queen blocks at most two
columns in any given empty row — one for each of its two diagonals — and likewise
at most two rows in any given column. If the crowd is sparse enough that

$$5 \cdot |Q| \le n,$$

the blocked cells never overwhelm the available ones, Hall's condition holds, and a
valid matching exists. This yields the **completion relaxation**: any non-attacking
arrangement $Q$ with at most $n/5$ queens extends to a full permutation placement in
which no newly placed queen shares a row, column, or diagonal with any original
queen.

The constant here is $1/5 = 0.2$ — tantalizingly close to the conjectured
$0.216$. One should be candid about the gap, though: Hall's theorem guarantees
peace only *between new and old* queens; it does not, by itself, forbid two freshly
placed queens from clashing on a diagonal of their own. Closing that final gap — to
turn the relaxation into a genuine completion for a linear number of pre-placed
queens — is the deep completion-threshold theorem at the heart of the conjecture,
and it is not settled here. What the relaxation does provide is a rigorous,
quantitative foothold: a guarantee that sparse arrangements are almost completable,
with an explicit and respectable density.

## Where the boundary really is

Putting the pieces together, we have a clear picture of the lower frontier. There
exist full solutions for infinitely many board sizes; a single queen never locks
the board; and any arrangement of up to a fifth of the rows can be extended into a
non-attacking permutation consistent with all the originals. Above this, the
landscape becomes the domain of the conjecture: the belief that the true threshold
density converges to $0.216 = 27/125$, neither more nor less.

It is worth savoring how concrete the obstruction at the top really is. The
conjecture is not merely that the threshold is *some* number; it is that no constant
larger than $0.216$ can serve as a universal lower bound, because for infinitely
many $n$ there exist peaceful arrangements of size just above $0.216\, n$ that
genuinely cannot be completed. The number is sharp from both sides.

## Why it matters beyond the chessboard

The $n$-queens completion problem is a microcosm of a question that pervades
computer science and combinatorics: when does a *partial* solution to a constraint
problem doom you, and when can you always recover? Sudoku, graph coloring, Latin
squares, scheduling — all share this DNA. A peaceful arrangement of queens is a
particularly clean instance because its constraints are purely linear and modular,
which is exactly why a single algebraic line can solve it and a single marriage
theorem can repair it.

The completion framing also connects to the probabilistic method, where one shows a
structure exists by demonstrating that a random construction succeeds with positive
probability. The Hall-theorem relaxation is the deterministic shadow of such an
argument: instead of arguing that a random extension avoids conflicts, we exhibit
the matching outright and count the obstructions by hand.

And then there is the sheer aesthetic pull of the constant. Mathematics is full of
thresholds — phase transitions where a system flips from solvable to hopeless — and
$0.216$ is one of the crispest. The journey from "any single queen always fits" to
"the boundary sits at exactly twenty-two percent" is the journey from a child's
chessboard puzzle to the frontier of modern combinatorics. The pieces proved here —
an infinite family of explicit solutions, the impossibility of locking the board
with one queen, and a marriage-theorem repair guarantee at density $0.2$ — are the
solid ground from which that frontier is surveyed.
