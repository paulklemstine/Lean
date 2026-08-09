# The Matrices That Can Only Say "Equal"

## A story about grids of zeros and ones, the cheapest possible questions, and a forbidden staircase

Imagine a huge grid — a million rows, a million columns — with a $0$ or a $1$ in every cell. Row $i$ belongs to Alice, column $j$ belongs to Bob, and the two of them want to know the value $A_{ij}$ in the cell where their row and column meet. Neither can see the other's index. How much do they have to say to each other?

There is one question that is so cheap it is almost free: *"Is my name the same as your name?"* If Alice can compute a label $f(i)$ from her row, Bob can compute a label $g(j)$ from his column, and the answer to the puzzle is simply whether $f(i) = g(j)$, then the pair have solved their problem with a single equality test. Equality is the atom of communication: it is the one nontrivial question that cheap randomized fingerprinting answers in a constant number of bits, no matter how astronomically large the label space is.

Which grids can be solved this way? And which grids can be solved by a *few* equality tests, with the answers added and subtracted?

That innocent-sounding question turns out to be the same question as one asked in operator algebras half a century ago, about objects called **idempotent Schur multipliers**. This article is about a piece of that question that can now be settled completely — including an exact, and slightly surprising, numerical constant: $2\sqrt{3}/3 \approx 1.1547$.

---

## Multiplying matrices entrywise

Take a fixed matrix $A$ and define an operation on all other matrices of the same shape:
$$ (S_A B)_{ij} = A_{ij}\, B_{ij}. $$
This is the **Schur multiplier** with symbol $A$: multiply entry by entry, leaving the shape untouched. It is a beautifully simple operation, and yet it is the source of some of the deepest inequalities in analysis, from Grothendieck's inequality onwards.

When is $S_A$ a *projection*, i.e. when does applying it twice do nothing more than applying it once? Exactly when $A_{ij}^2 = A_{ij}$ for every cell — that is, exactly when $A$ is a **boolean** matrix, filled with zeros and ones. So "idempotent Schur multiplier" and "grid of zeros and ones" are two names for the same thing.

Now measure the *size* of the multiplier. The natural norm — the norm of $S_A$ acting on bounded operators — has a purely geometric description, the **factorization norm** $\|A\|_{\gamma_2}$: it is the smallest $c$ for which one can find vectors $x_1,\dots,x_m$ and $y_1,\dots,y_n$ in some Euclidean space with
$$ A_{ij} = \langle x_i, y_j\rangle \qquad\text{and}\qquad \|x_i\|^2 \le c,\quad \|y_j\|^2 \le c \ \ \text{for all } i,j. $$
Every entry of the matrix is recovered as an angle-and-length between two vectors; the norm asks how short those vectors can be made. (One may equivalently ask for $\max_i\|x_i\| \cdot \max_j\|y_j\| \le c$, without insisting the two sides be balanced: a simple rescaling $x_i \mapsto \lambda x_i$, $y_j \mapsto \lambda^{-1} y_j$ converts one formulation to the other.)

A first easy consequence: since $|A_{ij}| = |\langle x_i,y_j\rangle| \le \|x_i\|\|y_j\| \le c$ by Cauchy–Schwarz, no entry can exceed the norm.

---

## Blow-ups: the grids that answer to a single equality test

Say a boolean matrix $A$ is a **blow-up of a partial identity** if there are labellings $f$ of the rows and $g$ of the columns with
$$ A_{ij} = \begin{cases} 1 & \text{if } f(i) = g(j),\\ 0 & \text{otherwise.}\end{cases} $$
Picture it: reorder the rows and columns so that equally-labelled ones sit together, and the matrix becomes a block-diagonal pattern of solid all-ones rectangles, everything else zero. A "blow-up" of an identity matrix is exactly that — each $1$ on the diagonal inflated into a rectangle of ones. These are precisely the grids Alice and Bob solve with a single equality query.

Such matrices are contractive: $\|A\|_{\gamma_2} \le 1$. To see it, put $x_i = e_{f(i)}$ and $y_j = e_{g(j)}$, standard basis vectors indexed by the labels. Then $\langle x_i, y_j\rangle$ is $1$ when the labels match and $0$ otherwise — exactly $A_{ij}$ — and every vector is a unit vector.

The striking fact is the converse.

> **Theorem (Characterization of the contractive case).** For a boolean matrix $A$ the following are equivalent:
> 1. $\|A\|_{\gamma_2} \le 1$;
> 2. $A$ is a blow-up of a partial identity matrix;
> 3. $A$ is **row rigid**: whenever two rows both carry a $1$ in some common column, those two rows are identical.

So the analytic condition (norm at most one), the structural condition (block-diagonal after permutation), and the purely combinatorial condition (row rigidity) all coincide. The bridge from analysis to combinatorics is the *equality case of Cauchy–Schwarz*: if $\|x_i\|^2 \le 1$, $\|y_j\|^2 \le 1$ and $\langle x_i,y_j\rangle = 1$, then the inequality $\langle x_i, y_j\rangle \le \|x_i\|\|y_j\| \le 1$ is tight, which forces $x_i = y_j$ exactly. A $1$ in the grid therefore *glues the two vectors together*. If rows $i$ and $i'$ both hit a $1$ in column $j$, then $x_i = y_j = x_{i'}$, so the two rows are literally the same vector and hence the same row of the matrix. Rigidity in turn lets one manufacture the labels: give each row the index of its leftmost $1$, give each column a matching label, and check that the blow-up formula holds.

---

## The forbidden staircase, and a gap at $2/\sqrt{3}$

What is the smallest way for a matrix to *fail* row rigidity? Two rows that overlap in a $1$ but disagree somewhere — that is, a $2\times 2$ pattern
$$ T_2 = \begin{pmatrix} 1 & 1\\ 1 & 0\end{pmatrix} $$
sitting inside the matrix, its four cells at the intersections of two rows and two columns (not necessarily adjacent). Call this a **$2$-staircase**. So: a boolean matrix is a blow-up if and only if it contains no $2$-staircase.

Now the analytic question. How expensive is the staircase? The answer is a clean irrational number.

> **Theorem (Exact norm of the triangular truth matrix).** $\left\|\begin{pmatrix}1&1\\1&0\end{pmatrix}\right\|_{\gamma_2} = \dfrac{2\sqrt{3}}{3} = \dfrac{2}{\sqrt3} \approx 1.1547.$

Both halves of this are pretty. For the **upper bound**, take four vectors in the plane, all of the same length $r = \sqrt{2\sqrt3/3}$, at angles
$$ -30^\circ,\ 0^\circ,\ 30^\circ,\ 60^\circ. $$
Assign $x_1$ to $0^\circ$ and $x_2$ to $60^\circ$ (the rows), $y_1$ to $30^\circ$ and $y_2$ to $-30^\circ$ (the columns). Three of the four pairings are $30^\circ$ apart, giving inner product $r^2\cos 30^\circ = \frac{2\sqrt3}{3}\cdot\frac{\sqrt3}{2} = 1$; the fourth pairing, $x_2$ against $y_2$, is $90^\circ$ apart and gives $0$. That is exactly the pattern $\begin{pmatrix}1&1\\1&0\end{pmatrix}$, drawn as a fan of four vectors at consecutive $30^\circ$ intervals. Nothing more is needed: two dimensions suffice.

For the **lower bound** there is a certificate one can verify with bare hands. Suppose $a, b$ are the row vectors and $p, q$ the column vectors of any factorization with all squared lengths at most $c$, so $\langle a,p\rangle = \langle a,q\rangle = \langle b,p\rangle = 1$ and $\langle b,q\rangle = 0$. Then consider the manifestly nonnegative quantity
$$ 0 \;\le\; \bigl\|\sqrt3\,b - 2p + q\bigr\|^2 \;+\; 2\,\bigl\|-\sqrt3\,a + p + q\bigr\|^2 . $$
Expand the squares. Every cross term is one of the four known inner products, and the result collapses to
$$ 0 \le 6\|a\|^2 + 3\|b\|^2 + 6\|p\|^2 + 3\|q\|^2 - 12\sqrt3 \le 18c - 12\sqrt3, $$
whence $c \ge 12\sqrt3/18 = 2\sqrt3/3$. Two well-chosen squares, and the bound is sharp. This is not luck: the coefficients $\sqrt3, -2, 1$ and $-\sqrt3, 1, 1$ come from the optimal solution of the dual semidefinite program, and a sharp primal together with a matching dual certificate is exactly what "the norm equals $2\sqrt3/3$" means.

Combining the two theorems yields the punchline.

> **Gap Theorem.** No boolean matrix, of any size, has factorization norm strictly between $1$ and $2\sqrt3/3$. If $\|A\|_{\gamma_2} < 2\sqrt3/3$, then $A$ is a blow-up of a partial identity and $\|A\|_{\gamma_2} \le 1$.

The proof is a two-line argument once the pieces are in place: if $A$ is not a blow-up, it is not row rigid, so it contains a $2$-staircase, so — because passing to a submatrix can only decrease the factorization norm — its norm is at least $2\sqrt3/3$. And the gap is *sharp*: the $2\times2$ staircase itself sits exactly at the top of it.

So the set of achievable norms of idempotent Schur multipliers is not a continuum near the bottom. It starts with $\{0,1\}$-style rigid objects at norm $\le 1$, then jumps. Nothing lives in between.

---

## Counting equality questions

Return to Alice and Bob. Say that a boolean matrix is a **signed sum of $L$ blow-ups** if
$$ A = \sum_{\ell=1}^{L} \varepsilon_\ell B_\ell, \qquad \varepsilon_\ell \in \{+1,-1\}, $$
with each $B_\ell$ a blow-up of a partial identity. Unwinding the definition of a blow-up, this says precisely: there are $L$ pairs of labelling functions $f_\ell, g_\ell$ and signs $\varepsilon_\ell$ with
$$ A_{ij} \;=\; \sum_{\ell=1}^{L} \varepsilon_\ell \cdot \mathbf{1}[\,f_\ell(i) = g_\ell(j)\,]. $$
Alice and Bob compute the grid with $L$ equality queries and a signed tally. Define the **blow-up number** $\mathrm{eq}(A)$ to be the least such $L$.

One direction is easy and completely general: because the factorization norm is subadditive (concatenate the factorizations, so the vectors of a sum live in the direct sum of the spaces) and each blow-up has norm at most $1$,
$$ \|A\|_{\gamma_2} \;\le\; \mathrm{eq}(A). $$
Also, every boolean $m\times n$ matrix is a *positive* sum of at most $m$ blow-ups — one per row, each row being a single all-ones block sitting in its own row — so $\mathrm{eq}(A) \le \min(m,n)$ always, and similarly $\|A\|_{\gamma_2} \le \sqrt{\min(m,n)}$ (take $x_i$ the $i$-th basis vector and $y_j$ the $j$-th column).

The conjecture that motivates this whole story is the *reverse* implication, with the size of the matrix eliminated from the answer:

> **Conjecture.** For every $\gamma$ there is an $L = L(\gamma)$, depending on $\gamma$ alone and not on the dimensions, such that every boolean matrix with $\|A\|_{\gamma_2} \le \gamma$ satisfies $\mathrm{eq}(A) \le L$.

Equivalently: every idempotent Schur multiplier is a finite signed sum of contractive idempotents, with the number of terms controlled by the norm. The known bounds in the literature are of the form $L = 2^{O(\gamma^9)+\log^* n}$ — enormous, and still carrying a whisper of dependence on $n$ through the iterated logarithm $\log^* n$, the number of times one must take a logarithm to bring $n$ below $1$. Removing that $\log^*$ is the open problem.

The Gap Theorem settles the conjecture, exactly and uniformly, at the bottom of the range:

> **Theorem.** For every $\gamma < 2\sqrt3/3$, every boolean matrix of any size with $\|A\|_{\gamma_2} \le \gamma$ satisfies $\mathrm{eq}(A) \le 1$.

Not $2^{O(\gamma^9)}$, not $\log^* n$ — just $1$. Below the first gap, the conjecture is true with the smallest constant imaginable.

---

## An algebra of cheap questions

There is one more structural pleasure. Schur multipliers compose by entrywise multiplication of their symbols, so if the class of "cheap" matrices is to deserve the name, it had better be closed under that operation. It is.

- **The norm is submultiplicative**: $\|A \odot B\|_{\gamma_2} \le \|A\|_{\gamma_2}\,\|B\|_{\gamma_2}$, where $\odot$ is the entrywise product. Proof: *tensor the two factorizations*. If $A_{ij} = \langle x_i, y_j\rangle$ and $B_{ij} = \langle u_i, v_j\rangle$, then $A_{ij}B_{ij} = \langle x_i \otimes u_i,\ y_j \otimes v_j\rangle$, and $\|x_i \otimes u_i\|^2 = \|x_i\|^2\|u_i\|^2$.
- **Blow-ups are closed under $\odot$**: composing two contractive idempotent multipliers gives another one. The labels of the product are the *pairs* of labels, $(f_1(i), f_2(i))$ against $(g_1(j),g_2(j))$, since two pairs agree iff both coordinates do.
- **Signed sums of blow-ups form a ring** under entrywise operations, with the blow-up number acting like a degree: $\mathrm{eq}(A+B) \le \mathrm{eq}(A)+\mathrm{eq}(B)$, $\mathrm{eq}(-A) = \mathrm{eq}(A)$, $\mathrm{eq}(A\odot B) \le \mathrm{eq}(A)\,\mathrm{eq}(B)$, and for the complement $\mathrm{eq}(1-A) \le \mathrm{eq}(A) + 1$ (the all-ones matrix is a single blow-up).

In protocol language: equality-based protocols compose. Running two of them and multiplying answers costs the product of the query counts; running them in parallel and adding costs the sum; negating is free.

---

## What comes next

Beyond the first gap lies the $3\times 3$ staircase
$$ T_3 = \begin{pmatrix} 1&1&1\\ 1&1&0\\ 1&0&0\end{pmatrix}, $$
which contains a $2$-staircase (so its norm is at least $2\sqrt3/3$) and is at most $\sqrt3$ by the general bound. Its exact norm is not known here — crude numerical searching places it somewhere between about $1.40$ and $1.48$, and two searches disagreed, so no value is claimed. The natural conjecture is that the set of achievable norms is *discrete* near its bottom: after $1$ and $2\sqrt3/3$ the next attained value is $\|T_3\|_{\gamma_2}$, with nothing in between.

The bolder guess is that the whole conjecture on idempotent Schur multipliers is really a statement about forbidden patterns. Row rigidity — the condition characterizing norm $\le 1$ — is exactly "contains no $2$-staircase". Perhaps, in general, $\|A\|_{\gamma_2} \le \gamma$ forces the absence of staircases longer than some $k(\gamma)$, and conversely the absence of long staircases forces a bounded factorization norm and a bounded number of equality questions. If so, an analytic conjecture about operator algebras dissolves into a combinatorial one about a hierarchy of forbidden zero-one patterns — and the case $k = 2$, proved here in both directions with a sharp constant, is the first rung of that ladder.

There is something satisfying in the shape of the answer. A question about norms of operators on infinite-dimensional spaces reduces to a question about two rows of a grid disagreeing; the reduction is quantitative; and the constant that measures how expensive that disagreement is turns out to be four vectors in the plane, thirty degrees apart.
