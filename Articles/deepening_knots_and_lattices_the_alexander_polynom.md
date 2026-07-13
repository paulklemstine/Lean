# Knots and Lattices: When a Knot Becomes a Counting Problem

## A tangle you can hold in your hand

Take a piece of string, tie it up, and glue the two ends together. You now hold a *knot* — not the temporary kind that comes undone when you pull, but a permanent loop with a personality all its own. Some loops are secretly boring: no matter how tangled they look, you can wiggle them back into a plain circle. Others are stubborn. The simplest stubborn one, the **trefoil**, is the pretzel-shaped loop with three crossings that refuses to untangle no matter how cleverly you push the string around.

The central problem of knot theory is deceptively simple to state: *given two tangled loops, are they secretly the same knot?* You are allowed to slide and stretch the string however you like, but never to cut it. This is hard. Our eyes are easily fooled, and a knot drawn one way can look nothing like the same knot drawn another way.

The mathematician's escape from this confusion is to attach to each knot a *fingerprint* — a piece of data that never changes when you wiggle the string, so that two knots with different fingerprints are guaranteed to be genuinely different. One of the oldest and most beloved fingerprints is the **Alexander polynomial**, discovered in 1928. To every knot $K$ it assigns a polynomial $\Delta_K(t)$ in a variable $t$ (and its reciprocal $t^{-1}$). For the trefoil, this fingerprint is the tidy expression

$$\Delta_{\text{trefoil}}(t) = t - 1 + t^{-1}.$$

The Alexander polynomial is powerful, computable, and everywhere in low-dimensional topology. But where does it *come from*? Is there a way to see it not as the output of an abstract algebraic machine, but as something you could, in principle, *count*?

## The dream: a knot as a counting problem

Here is the dream that drives this article. Combinatorics is full of *generating functions*: you have a collection of objects, each object has a "size," and you record how many objects there are of each size by writing

$$\sum_{\text{objects } s} t^{\,\text{size}(s)}.$$

The coefficient of $t^k$ is simply *the number of objects of size $k$*. Generating functions are the accountants of mathematics — every coefficient is a headcount.

The seductive conjecture at the heart of this work is that the Alexander polynomial is secretly one of these headcounts. Picture a grid, the integer lattice $\mathbb{Z}^2$, and picture little paths hopping from point to point, forced to avoid some forbidden region carved out by the knot's crossings. Each path encloses a certain **area**. Could it be that

$$\Delta_K(t) = \sum_{\text{lattice paths } s} t^{\,\text{area}(s)},$$

so that the Alexander polynomial is nothing more exotic than *the number of allowed lattice paths of each area*? If so, a topological fingerprint would dissolve into a pure counting problem, and the entire toolkit of combinatorics would swing open.

It is a beautiful dream. And, as stated, it is **false**. This article is the story of exactly *why* it fails, exactly *how much* must be added to rescue it, and the surprising discovery that the rescued version is not a fragile patch but a sweeping, universal truth.

## The fatal minus sign

Look again at the trefoil's fingerprint: $t - 1 + t^{-1}$. Read off the coefficients: the coefficient of $t^1$ is $+1$, the coefficient of $t^0$ is $-1$, and the coefficient of $t^{-1}$ is $+1$.

A minus one.

But a headcount can never be negative. You cannot have $-1$ paths of area zero. This single minus sign is fatal to the naive dream. The trefoil — the very first nontrivial knot anyone meets — already breaks the conjecture on its second coefficient.

We can make this obstruction precise and permanent. Say that a coefficient sequence is an **unsigned area generating function** if there is some finite collection of "states," each carrying an integer area, such that the coefficient of $t^k$ literally equals the number of states of area $k$. The first theorem of this work is the obvious-but-crucial observation, now nailed down beyond dispute:

> **Non-negativity.** Every unsigned area generating function has non-negative coefficients. A count is never negative.

Because $\Delta_{\text{trefoil}}$ has a negative coefficient, it can never be such a count. The dream, taken literally, is dead.

## Reviving the dream with a sign

Anyone who has met the world of "signed counting" — determinants, Euler characteristics, inclusion–exclusion — knows the standard remedy. When honest counts refuse to produce your quantity, you allow each object to carry a **sign**, either $+1$ or $-1$, and you count with signs. The genuine formula for the Alexander polynomial, it turns out, is exactly of this kind: each state $s$ contributes $(-1)^{w(s)}$ for some parity $w(s)$, and the coefficient of $t^k$ is the *signed* total

$$\sum_{\text{states } s \text{ of area } k} (\pm 1).$$

Call this a **signed state sum**. The trefoil is now easy to accommodate: two states of area $0$ that cancel to leave $-1$ do the job. But this feels like a cheap trick tailored to one small example. Is the signed model just a bespoke patch for the trefoil, or does it reflect something structural?

The answer — the centerpiece of this work — is as strong as it could possibly be.

> **Universality of the signed state sum.** *Every* finitely supported integer coefficient sequence is a signed state sum. There is no positivity requirement, no divisibility requirement, no constraint whatsoever beyond having only finitely many nonzero coefficients.

In one stroke this settles the combinatorial status of the whole conjecture. The signed model is *exactly as expressive as the class of integer Laurent polynomials themselves.* Since every Alexander polynomial is such a polynomial, **no Alexander polynomial — of any knot, however complicated — can ever escape the signed model.** The dream, once revived with signs, is not merely repaired; it is complete.

The proof is refreshingly concrete rather than abstract. Given any target sequence $c$, build the state family by hand: for each index $k$ where the coefficient $c_k$ is nonzero, create exactly $|c_k|$ states, all of area $k$, and give each of them the sign of $c_k$ (that is, $+1$ if $c_k>0$ and $-1$ if $c_k<0$). Then the signed total at area $k$ is $\text{sign}(c_k)\cdot |c_k| = c_k$ on the nose. That's the whole idea: a sign and an absolute value multiply back into the original integer.

## The exact price of positivity

Placing the two theorems side by side reveals the crisp punchline. The unsigned model realizes *precisely the finitely supported, non-negative sequences* — no more, no less. (Any such non-negative sequence really is an honest count: for each $k$, just make $c_k$ copies of a state of area $k$.) The signed model realizes *all* finitely supported sequences. The gap between them is nothing but the sign group $\{+1, -1\}$.

So the reason the naive lattice-path dream fails is now pinned down with surgical precision: **the only missing ingredient was the ability to subtract.** Add a single bit of sign to each object and the entire class of Alexander polynomials snaps into view.

## Not just the trefoil — an infinite family of rebels

One might still worry that negative coefficients are a rare pathology, a quirk of the trefoil alone. To dispel this, the work studies an infinite family of knots, the **torus knots** $T(2, 2k+1)$: the loops you get by winding a string $2k+1$ times around a doughnut while it goes around twice. For $k=1$ this is our old friend the trefoil; for $k=2$ it is the cinquefoil (five crossings); and so on forever.

Their Alexander polynomials have a clean closed form, an alternating sum of powers of $t$:

$$\Delta_k(t) = \sum_{i=-k}^{k} (-1)^{i+k}\, t^{\,i} = t^k - t^{k-1} + t^{k-2} - \cdots + t^{-k}.$$

This family is a perfect laboratory, because one can check every property of an Alexander polynomial against it directly:

- **Reciprocity (palindromy).** The coefficient of $t^i$ equals the coefficient of $t^{-i}$; the polynomial reads the same forwards and backwards, $\Delta_k(t) = \Delta_k(t^{-1})$. This mirror symmetry is a hallmark of *all* Alexander polynomials, and here it is transparent.
- **Normalization.** Setting $t = 1$ adds up all the coefficients, and the alternating pattern telescopes to give exactly $\Delta_k(1) = 1$. Every genuine Alexander polynomial satisfies $\Delta_K(1) = \pm 1$; the torus family hits this precisely.
- **The determinant.** Setting $t = -1$ gives the *knot determinant*, one of the most classical numerical invariants. Here the alternating evaluation collapses to $|\Delta_k(-1)| = 2k+1$ — so the determinant of $T(2,2k+1)$ is exactly $2k+1$, growing without bound across the family.
- **Negativity is generic.** For *every* $k \ge 1$, the coefficient at $i = k-1$ equals $-1$. So *every* member of this infinite family has a negative coefficient, and therefore **none** of them is an unsigned lattice count. The trefoil was not a fluke; the obstruction is everywhere.
- **Yet all are signed state sums.** By universality, every single one of them *is* a signed state sum. The obstruction is generic, and the cure is universal.

## Gluing knots, multiplying counts

There is one more piece of magic, and it is the kind of coincidence that makes a mathematician trust that a theory is "right." Knots can be combined: cut two knots open and splice them end to end to form their **connected sum** $K_1 \# K_2$. A classical and cherished fact is that the Alexander polynomial turns this gluing into simple multiplication:

$$\Delta_{K_1 \# K_2}(t) = \Delta_{K_1}(t) \cdot \Delta_{K_2}(t).$$

On the combinatorial side, what does it mean to multiply two generating functions? It is the **Cauchy product**: you form all pairs of states, one from each family; a pair's area is the *sum* of the two areas, and its sign is the *product* of the two signs. The work proves that the signed state sum of this product family is exactly the convolution of the two factor sums — the term-by-term multiplication of polynomials. In particular, evaluating "at $t=1$" (adding up all signed weights) is multiplicative: the total signed weight of the combined family is the product of the two totals.

In plain words: **gluing knots corresponds to multiplying their lattice-state counts.** The topological operation of connected sum and the combinatorial operation of taking a Cauchy product are two faces of the same coin. The dictionary between knots and lattices is not just a list of matching entries; it respects the grammar of both languages.

## Why the story matters

Step back and the shape of the discovery is clear. A famous topological invariant, born from algebra and homology, has been given a completely elementary combinatorial identity — provided we count with signs. The failure of the naive version is not a defect but a *measurement*: it measures exactly the sign group $\{+1,-1\}$, the one algebraic feature that separates honest counting from signed counting. The success of the signed version is total: it captures every integer Laurent polynomial, and hence every possible Alexander polynomial, while respecting the connected-sum structure of knots as multiplication.

Where can this lead? Reciprocity — the palindromic mirror symmetry of Alexander polynomials — invites a geometric explanation: a symmetry of the *polynomial* ought to be the shadow of a genuine symmetry of the *state space*, an involution that flips area from $k$ to $-k$ while preserving signs. Indeed, whenever such an area-flipping, sign-preserving involution exists, the resulting signed sum is automatically palindromic; the open challenge is to realize each palindrome with a minimal, honestly symmetric family. For the special and important class of *alternating* knots, whose coefficients march in strict sign alternation, there is reason to believe a single change of variable $t \mapsto -t$ absorbs the entire sign group and converts the signed sum back into an honest, positive count — with the knot determinant $\Delta(-1)$ as the sole bookkeeper of the signs.

The knot in your hand, it turns out, is a counting problem in disguise. You just have to be willing to count with a minus sign.
