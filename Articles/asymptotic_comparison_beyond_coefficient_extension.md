# The Ghost in the Expansion

## What an asymptotic series really tells you — and the exact size of what it hides

There is a moment in every applied mathematician's education when a beautiful lie is told, and then never quite retracted.

The lie is this: *if two functions have the same asymptotic expansion, they are the same function.*

It sounds so reasonable. An asymptotic expansion is a complete description of how a function behaves as its argument runs off to infinity — the leading term, then the correction, then the correction to the correction, and so on forever. If you know every term of that infinite ledger, surely you know the function?

You do not. And the gap between what you know and what you would like to know turns out to be measurable with surgical precision. That measurement — what survives, what fails, and *exactly by how much* — is the subject of this article.

---

## Two different kinds of object

Start with the honest algebra, where nothing goes wrong.

Fix a scale of comparison functions. The simplest interesting one is the **rank scale**: for each integer $r$, the monomial

$$m_r(x) = x^r,$$

thought of as a function of a large real variable $x$. Rank $2$ is $x^2$, rank $0$ is the constant $1$, rank $-3$ is $x^{-3}$. The whole scale is ordered by a single, entirely elementary fact:

> **Rank Comparison.** If $r < s$ then $x^r$ is negligible compared to $x^s$ as $x \to +\infty$: the ratio $x^r/x^s = x^{r-s}$ tends to $0$.

This is the backbone. It says the scale never ties: two different ranks are always strictly ordered at infinity, with a gap that grows without bound. Nothing subtle here — but everything downstream rests on it.

Now, a **formal series** on this scale is just a bookkeeping device:

$$a_0 + a_1 x^{-1} + a_2 x^{-2} + a_3 x^{-3} + \cdots$$

with real numbers $a_n$. It is not a function. It is a list of coefficients wearing a costume. Two such objects are equal precisely when every coefficient matches. Call this **coefficient extensionality**: in the formal world, series are their coefficients, full stop.

The trouble begins the instant you try to make a formal series *mean* something analytic.

---

## The interpretation map

A function $f$ of a large real variable is said to have the expansion $a_0 + a_1x^{-1} + a_2x^{-2}+\cdots$ when every truncation is accurate to the order of its last retained term. Precisely: for each $N$,

$$f(x) - \sum_{n=0}^{N} a_n x^{-n} \;=\; o\!\left(x^{-N}\right) \quad \text{as } x \to +\infty.$$

The error after keeping $N+1$ terms is not merely small — it is small *compared to the last term you kept*. This is the standard notion, and it is the right one: it is what makes "the next term is a genuine correction" a meaningful statement.

So we have a map. Feed it a function, and it returns the coefficient list — its asymptotic expansion. Two immediate questions:

- Is the map well defined? (Can a function have two different expansions?)
- Is it injective? (Can two different functions share an expansion?)

The first answer is clean and positive.

> **Uniqueness of Expansion Coefficients.** A function has at most one asymptotic expansion on the rank scale.

The proof is a small piece of machinery worth seeing, because it is the only place where the Rank Comparison principle does real work. Suppose $f$ had two expansions, with coefficient lists $a$ and $b$. Take the first rank $N$ where they disagree. Subtract the two defining estimates. Everything below rank $N$ cancels, because those coefficients agree by the choice of $N$; what is left is the single term $(b_N - a_N)x^{-N}$, and the subtraction tells us it is $o(x^{-N})$. But a nonzero constant multiple of $x^{-N}$ is emphatically not negligible against $x^{-N}$ — the ratio is that constant, forever. So $b_N = a_N$, a contradiction. The coefficients are pinned down one at a time, each by the sheer rigidity of the scale.

The second question — injectivity — is where the beautiful lie lives.

---

## The ghost: $e^{-x}$

Consider the function $e^{-x}$ as $x \to +\infty$.

Ask what its asymptotic expansion on the rank scale is. The leading coefficient: $e^{-x}$ divided by $1$ tends to $0$, so $a_0 = 0$. The next: $e^{-x}$ divided by $x^{-1}$ is $x e^{-x}$, which tends to $0$, so $a_1 = 0$. In general $x^n e^{-x} \to 0$ for every $n$ — exponentials beat polynomials, the oldest fact in the book. So

$$e^{-x} \sim 0 + 0\cdot x^{-1} + 0 \cdot x^{-2} + \cdots.$$

Every coefficient vanishes. The asymptotic expansion of $e^{-x}$ is the zero series — the same expansion as the zero function. And yet $e^{-x}$ is never zero, anywhere.

> **Failure of Analytic Extensionality.** There exist two functions with identical asymptotic expansions to all ranks which do not eventually agree: namely $0$ and $e^{-x}$.

Call such a function **flat**: negligible against *every* rank of the scale, invisible to the expansion map at every order. Flat functions are ghosts. They walk through the wall of the asymptotic series and leave no trace.

This is not a pathology confined to exotic examples. It is the reason asymptotic series in physics and applied analysis are *asymptotic* rather than convergent, the reason exponentially small effects — tunnelling, Stokes phenomena, the difference between two solutions of the same differential equation — are invisible to perturbation theory at every finite order. The ghost is everywhere in the applied literature. It has a name there: it is called "beyond all orders".

So the beautiful lie is false. But *how* false? That is the interesting question, and it has an exact answer.

---

## Measuring the failure exactly

Here is the first main theorem, and it is sharper than one might hope.

> **The Fibre Theorem.** Suppose $f$ has asymptotic expansion $a$. Then a function $g$ has the *same* expansion $a$ if and only if $f - g$ is flat.

In other words: the map "take the asymptotic expansion" has fibres that are exactly the cosets of the flat functions. The ghosts are not merely *some* of the ambiguity — they are *all* of it, precisely. Knowing a function's expansion determines the function modulo flatness, and modulo nothing more.

The proof in both directions is the same two-line manoeuvre, done forwards and backwards: subtract two truncation estimates and note that the truncations cancel. What makes the statement content-bearing is not the difficulty of the argument but its exactness — it converts a vague "expansions lose information" into an equation between two sets.

The flat functions themselves form a tidy structure. They are closed under addition, subtraction, and scaling by constants, so they form a linear space. Better:

> **The Flat Ideal.** If $f$ is flat and $g$ is bounded (more generally, $g = O(1)$ at infinity), then $g \cdot f$ is flat.

Ghosts absorb bounded functions. Multiplying $e^{-x}$ by $\sin x$, or by any bounded thing you like, keeps it invisible. This is what makes "modulo flat" a robust equivalence rather than a fragile one.

---

## Where extensionality is rescued

Having found the exact defect, one can now ask the constructive question: *on what class of functions is the beautiful lie actually true?*

The answer: restrict to functions that are genuinely *sums* of their series, not merely asymptotic to them.

Call a formal series $\sum_n a_n x^{-n}$ **bounded** if there is a constant $M$ with $|a_n| \le M$ for every $n$. Substituting $t = 1/x$ turns it into an ordinary power series $\sum a_n t^n$ with bounded coefficients, which converges for $|t| < 1$ — that is, for $x > 1$. So a bounded formal series is not just symbols: it defines an honest function on $(1,\infty)$, and hence a germ at $+\infty$. Call this the **interpretation** of the series.

The whole analytic content is packed into one estimate.

> **The Tail Bound.** For a bounded series with coefficient bound $M$, and $0 \le t < 1$,
> $$\left| \sum_{n\ge 0} a_n t^n - \sum_{n=0}^{k-1} a_n t^n \right| \;\le\; \frac{M t^k}{1-t}.$$

Truncating at order $k$ costs at most a geometric tail. This single inequality, applied at $t = 1/x$, yields everything:

> **Interpretation Realizes the Expansion.** The function defined by a bounded series has that series as its classical asymptotic expansion.

> **Extensionality on the Fragment.** Two bounded series have eventually equal interpretations if and only if all their coefficients agree.

There it is. Coefficient extensionality — the clean algebraic principle — is *valid*, provided you stay inside the convergent world. It fails only when you let arbitrary functions in, and then it fails by exactly a flat correction. Both halves are now theorems, and they fit together exactly:

> **No Ghosts in the Fragment.** A bounded series whose interpretation is flat has all coefficients zero. In particular, no bounded series interprets to $e^{-x}$.

The image of the interpretation map meets the flat functions only at zero. The convergent fragment is a set of canonical representatives, one per fibre it touches.

---

## Signs, and the total order at infinity

Once you know the interpretation is faithful, you can ask what it preserves. It turns out to preserve *order*, and in a strikingly rigid way.

> **The Leading Monomial Controls the Sign.** Let $\sum a_n x^{-n}$ be bounded with bound $M$, and let $n_0$ be the first index with $a_{n_0} \ne 0$. Then for all sufficiently large $x$, the value of the interpreted function has the same sign as $a_{n_0}$. Explicitly, the conclusion holds once
> $$x > \frac{M + |a_{n_0}|}{|a_{n_0}|}.$$

The threshold is not an artifact — it is sharp. There are series in the fragment whose interpretation vanishes exactly at the point the estimate produces, so the "eventually" cannot be replaced by "everywhere", and the bound cannot be improved. What the leading term controls is the germ, not the function.

Stronger still, the function is asymptotically *equivalent* to its leading term: the ratio of the interpreted function to $a_{n_0}x^{-n_0}$ tends to $1$. The leading monomial is not just a sign detector; it is a faithful first approximation.

Push this to comparisons between two series and something remarkable falls out.

> **Trichotomy (No Oscillation).** For any two bounded series, exactly one of the following holds: their interpretations are eventually equal; the first is eventually strictly below the second; or the second is eventually strictly below the first.

Two arbitrary functions can cross each other infinitely often forever — think of $\sin x$ against $0$. Interpretations of bounded series cannot. They settle. This is the defining property of what analysts call a **Hardy field**, and it means the germs of the fragment form a genuinely *ordered* set, not merely a partially ordered one.

And the order is computable from the coefficients alone:

> **Order Embedding.** The interpretation of one bounded series is eventually strictly below that of another if and only if the coefficient lists are ordered lexicographically: at the first rank where they differ, the first is smaller.

Compare two infinite lists left to right; the first disagreement decides. That is exactly how the functions themselves compare at infinity. The algebra of the coefficients and the analysis of the germs are the same ordered structure, seen twice.

---

## Multiplication, and a fragment that breaks

Sums and scalars pose no problem: the interpretation is linear. Products are more interesting.

The formal product of $\sum a_n x^{-n}$ and $\sum b_n x^{-n}$ is the **Cauchy product**, with coefficients

$$c_n = \sum_{i+j=n} a_i b_j.$$

> **Multiplicativity.** Wherever both series converge, the product of the two interpreted functions equals the interpretation of the Cauchy product.

This is Mertens' theorem in disguise — absolute convergence permits the double sum to be rearranged along antidiagonals. So the interpretation respects multiplication.

But there is a sting. Is the *bounded* fragment closed under this product? Bound the Cauchy coefficient the obvious way: each of the $n+1$ terms is at most $MM'$, so $|c_n| \le (n+1)MM'$. Linear growth. Can one do better?

No.

> **The Bounded Fragment Is Not a Ring.** Squaring the all-ones series $1 + x^{-1} + x^{-2} + \cdots$ gives Cauchy coefficients $c_n = n+1$, which are unbounded. No bounded series has those coefficients.

The crude estimate was tight all along. The problem is not the interpretation — that behaved perfectly — but the *choice of fragment*: boundedness of coefficients is preserved by sums but not by products. It is the wrong norm.

The repair is to allow the coefficients a geometric budget. Call a series **geometrically bounded at rate $\rho$** if $|a_n| \le M \rho^n$ for some $M$ and some $\rho > 0$. Such a series converges for $x > \rho$; the bounded case is $\rho = 1$. All the earlier theory survives verbatim: the same tail bound (now with geometric ratio $\rho t$), the same realization of the expansion, the same injectivity. And now:

> **Product Closure.** The Cauchy product of two series geometrically bounded at rates $\rho_1, \rho_2$ is geometrically bounded at rate $2\max(\rho_1,\rho_2)$, with constant the product of the constants. Consequently, the asymptotic expansion of a product of two such functions is the Cauchy product of their expansions.

The doubling is a convenience: it absorbs the factor $n+1$ using $n+1 \le 2^n$. How much of it is really necessary?

> **The Inflation Is Arbitrarily Small — But Not Removable.** For *any* rate $r$ strictly larger than $\max(\rho_1,\rho_2)$, the Cauchy product is geometrically bounded at rate $r$ (with a constant that blows up as $r$ approaches the maximum). But at the rate $\max(\rho_1,\rho_2)$ itself, closure fails: the all-ones series has rate $1$, and its square has coefficients $n+1$, which admit no bound $M \cdot 1^n$.

This is the exact statement. The factor of $2$ can be shrunk to $1+\varepsilon$ for any $\varepsilon>0$, using the elementary inequality $n+1 \le (1 + \tfrac{1}{q-1})q^n$ for $q > 1$. It cannot be shrunk to $1$. So no single rate is closed under multiplication; what *is* closed is the union over all rates — a directed system of fragments, each embedded in the next. Algebraically: the right object is not one ring but a colimit of modules, and multiplication is a map between different levels.

---

## What the whole picture says

Assemble the pieces and a single sentence emerges.

*On the convergent fragment, the formal and analytic worlds are the same world: the interpretation is injective, linear, order-preserving for the lexicographic order, multiplicative, and its image is a set of canonical representatives. Outside the fragment, the formal world is exactly a quotient of the analytic one, with kernel the flat germs — and not one bit larger.*

The beautiful lie fails, but it fails in a way you can write down. That is what a good theorem does with a false intuition: not simply refute it, but locate its exact boundary, and hand you back the largest domain on which it is true.

For the working analyst this is a licence with fine print. You may reason formally with asymptotic series — add them, multiply them, compare them, differentiate the comparison — and every conclusion transfers to the functions, *provided* you are asking a question that is blind to flat corrections. Sign at infinity: fine. Order of growth: fine. Which of two solutions is eventually larger: fine. The exact value of a solution, the presence of an exponentially small resonance, the difference between two branches that agree to all orders: not fine, and no amount of extra terms will make it fine. Those questions live entirely in the kernel.

The ghost in the expansion cannot be exorcised. But it can be named, its ideal can be described, and everything outside it can be trusted completely. In mathematics, that is usually the best kind of victory.
