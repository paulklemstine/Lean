# The Crossword Where Every Clue Must Be Sharp: How One Matrix Property Hides a Universal Uncertainty Law

## A puzzle about hiding and revealing

Imagine you have a signal — a list of numbers $f = (f_1, f_2, \dots, f_n)$ — and you are allowed to look at it through two different windows. The first window shows you the signal itself. The second window shows you a transformed version, $Mf$, where $M$ is some fixed mixing rule (a square matrix). A natural question: *can the signal be sparse in both windows at once?*

"Sparse" simply means *mostly zeros*. We measure it with the **support** of a vector — the count of positions where it is not zero. Write $|\mathrm{supp}(f)|$ for that count.

It turns out that for the very best mixing rules, the answer is a flat **no**. If your signal is concentrated in a few places before mixing, it is forced to spread out almost everywhere after mixing, and vice versa. The two windows fight each other. Concretely, for these special matrices,

$$|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge n + 1$$

for **every** nonzero signal $f$ of length $n$. You can never make both supports small simultaneously; their sizes must add up to more than the length of the signal.

This is an *uncertainty principle*. It is a cousin of the famous statement in physics that a particle cannot have both a sharply defined position and a sharply defined momentum. Here the two "conjugate" descriptions are not position and momentum but "before mixing" and "after mixing." And the punchline of this article is a clean, complete answer to a precise question: **exactly which mixing rules obey this sharpest possible uncertainty law?**

The answer is a single, crisp algebraic condition with a name borrowed from coding theory: the matrix must be **MDS**.

## What makes a matrix "maximally separable"

Picture a matrix as a grid of numbers. From that grid you can cut out smaller square grids by choosing some rows and the same number of columns. A $3\times 5$ choice of rows-and-columns is not square; but pick $2$ rows and $2$ columns and you get a $2\times 2$ block, a *square submatrix*. Each such block has a determinant — a single number that is zero precisely when the block is "degenerate" (its rows collapse onto each other).

A matrix is **MDS** — short for *Maximum Distance Separable* — when **every** square submatrix you can carve out of it, of every size, has a nonzero determinant. Nothing is allowed to be degenerate, anywhere, ever. Formally, for a square $n\times n$ matrix $M$ over a field, $M$ is MDS when for every size $k$ and every choice of $k$ rows (an injection $r$) and $k$ columns (an injection $c$), the determinant of the carved-out block $M[r,c]$ is nonzero:

$$\det\big(M[r,c]\big) \neq 0 \quad \text{for all } k, r, c.$$

This is an extraordinarily strong demand. A random matrix usually fails it: somewhere among its myriad sub-blocks, some determinant will vanish. MDS matrices are the perfectionists of linear algebra. They are exactly the matrices behind **Reed–Solomon codes** — the error-correcting codes that protect QR codes, CDs, DVDs, deep-space transmissions, and the data scattered across the disks of a RAID array. The "maximum distance" in the name is the coding-theoretic statement that these codes correct the largest possible number of errors for their size, hitting a ceiling called the **Singleton bound**.

So we have two very different-sounding properties:

- **A linear-algebra property:** every square submatrix is invertible (MDS).
- **A signal-analysis property:** every nonzero signal spreads out under mixing (the uncertainty bound $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge n+1$).

The central theorem says these are *the same property in disguise.*

## The main theorem: a perfect equivalence

> **MDS–Uncertainty Theorem.** A square $n\times n$ matrix $M$ over a field is MDS **if and only if** it satisfies the strongest additive uncertainty bound: for every nonzero vector $f$,
> $$|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge n+1.$$

This is a genuine *if and only if* — an exact characterization, proven with no gaps. It means the uncertainty law is not merely a *consequence* of MDS; it is a *complete fingerprint* of it. If you tell me a matrix forces every signal to spread, I can tell you that every one of its sub-blocks is invertible, and conversely.

Let us see why each direction is true, because the reasoning is beautifully short.

### Why MDS forces spreading

Suppose, for contradiction, that some nonzero signal $f$ *beats* the bound, so

$$|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \le n.$$

Let $s = |\mathrm{supp}(f)|$ be the number of nonzero entries of $f$. Because supports and zero-sets partition the $n$ coordinates, the number of zeros of $Mf$ is

$$|\mathrm{zeros}(Mf)| = n - |\mathrm{supp}(Mf)| \ge n - (n - s) = s.$$

So $Mf$ has *at least* $s$ zero coordinates. Now play a matching game. Pick any $s$ of those zero rows of $Mf$; call this choice of rows $r$. Pick the $s$ columns where $f$ is nonzero; call them $c$. Cut out the $s\times s$ block $M[r,c]$.

Here is the key computation, the hinge of the whole proof: because $f$ vanishes *outside* the chosen columns, multiplying the block $M[r,c]$ by the nonzero part of $f$ reproduces exactly the corresponding entries of the full product $Mf$. And those entries are precisely the zero rows we chose. So the block sends the (nonzero!) restricted vector to zero:

$$M[r,c]\,(f \text{ on } c) = 0.$$

But $M$ is MDS, so $\det(M[r,c]) \neq 0$, which means the block is invertible — the only vector it sends to zero is the zero vector. Hence $f$ restricted to its own support is zero, i.e. $f = 0$. Contradiction. The signal could not have beaten the bound after all.

### Why spreading forces MDS

Now the converse. Suppose $M$ is *not* MDS. Then by definition there is some square sub-block $M[r,c]$ — say $k\times k$ — whose determinant *is* zero. A matrix with zero determinant has a nontrivial kernel, so there is a nonzero vector $v$ of length $k$ with $M[r,c]\,v = 0$.

Inflate $v$ back into a full-length signal $f$: place the entries of $v$ in the columns indexed by $c$, and put zeros everywhere else. Then $f$ is nonzero and lives entirely on those $k$ columns, so

$$|\mathrm{supp}(f)| \le k.$$

Meanwhile, the same hinge computation shows that $Mf$ vanishes on all $k$ rows indexed by $r$ (because that is exactly $M[r,c]\,v = 0$). So $Mf$ has at least $k$ zeros, meaning

$$|\mathrm{supp}(Mf)| \le n - k.$$

Adding up, $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \le k + (n-k) = n$. We have produced a signal that *violates* the $n+1$ bound. So if the bound always held, $M$ must have been MDS. $\blacksquare$

The symmetry of the two arguments is the source of their elegance: the same little lemma — *a block applied to a localized signal reproduces a slice of the global product* — runs forward to force spreading and backward to build a counterexample.

## Sharpness: the bound cannot be improved

A skeptic might ask: maybe MDS matrices spread signals out even more than $n+1$? Could the true bound be $n+2$, or $2n$? No. The bound $n+1$ is exactly tight, and seeing why takes one line.

> **Tightness (Singleton bound for uncertainty).** For any invertible $n\times n$ matrix $M$ (with $n \ge 1$), there is a nonzero signal $f$ with
> $$|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \le n+1.$$

Take $f$ to be a single spike: $1$ in the first coordinate, $0$ elsewhere. Then $|\mathrm{supp}(f)| = 1$, and $Mf$ is just one column of $M$, which has at most $n$ nonzero entries. The sum is at most $1 + n = n+1$. So *some* signal always achieves the bound — MDS matrices push every signal up to the wall, but never past it. The wall sits exactly at $n+1$.

## Two more facts that fall out for free

The framework yields two further results almost as corollaries.

**MDS matrices are invertible.** This is the special case "$k = n$" of the MDS condition: taking the whole matrix as its own (largest) square submatrix, its determinant is nonzero, so $M$ itself is invertible. Perfection at every scale implies perfection at the top scale.

**Transposing preserves MDS.** If $M$ is MDS, so is its transpose $M^{\mathsf T}$. The reason is that a square submatrix of $M^{\mathsf T}$ is the transpose of a square submatrix of $M$, and transposing does not change a determinant. In coding-theoretic language this is the statement that **the dual of an MDS code is again MDS** — a structural duality that error-correction engineers rely on constantly.

## Three worlds, one law

What makes this result more than a clever exercise is that the *same* equivalence shows up wearing three different costumes.

**Harmonic analysis.** The discrete Fourier transform over a cyclic group of *prime* order is an MDS matrix — every minor is nonzero, a classical fact tied to the irreducibility of cyclotomic polynomials. So our theorem immediately reproduces a celebrated result: a nonzero function on $\mathbb{Z}/p\mathbb{Z}$ and its Fourier transform cannot both be supported on few points; their supports must sum to at least $p+1$. This is the discrete heart of the Heisenberg uncertainty principle, and it is the engine behind compressed sensing, where the impossibility of double-sparsity guarantees that sparse signals can be recovered from few measurements.

**Coding theory.** Reed–Solomon and other MDS codes are precisely the codes whose generator matrices are MDS. Our uncertainty bound *is* the Singleton bound in disguise: the minimum distance of the code — its error-correcting power — is governed by exactly the same support arithmetic.

**Linear algebra.** Stripped of context, the statement is a pure fact about matrices: "every square submatrix invertible" is logically equivalent to "every nonzero vector and its image have supports summing to more than $n$." Two conditions that look nothing alike turn out to be two faces of one coin.

## Why the equivalence is the prize

It would have been satisfying just to prove that MDS matrices obey the uncertainty law. What elevates the result is the word *iff*. An equivalence is a translation dictionary: any time you can verify one side, you get the other for free, and you can choose whichever side is easier in your situation.

Designing a code with maximal error correction? Hunt for a matrix obeying the uncertainty bound. Trying to guarantee that no signal can hide in two domains? Build an MDS matrix — and Reed–Solomon hands you an explicit recipe. Studying a Fourier-type transform? The MDS property tells you instantly whether a sparsity-based recovery scheme can possibly work.

The deepest pleasure of mathematics is moments like this, where a wall you were leaning against from one room turns out to be the same wall someone else was leaning against from a completely different room. The signal analyst worried about hiding information, the engineer building a fault-tolerant disk array, and the algebraist cataloguing invertible submatrices were all, unknowingly, studying the identical line. The MDS–Uncertainty Theorem draws that line and proves there is only one.

## The takeaway

A signal cannot be sparse before and after mixing — *if and only if* the mixing matrix is flawless at every scale. The threshold is exactly $n+1$: never less for the best matrices, and always achievable. From this single equivalence flow the invertibility of MDS matrices, the self-duality of MDS codes, the discrete Fourier uncertainty principle, and the Singleton bound of error correction. One crossword, and every clue must be sharp.
