# The Shadow of Computation

## Every Polynomial Casts a Shadow — and That Shadow Reveals Its Secrets

In 1979, Leslie Valiant posed a question that would haunt mathematics for the next half-century: Is there a short recipe for computing the permanent of a matrix? The permanent looks almost identical to the determinant — the same sum over permutations, the same product of matrix entries — but without the alternating signs. Yet while the determinant can be computed in the blink of an eye, the permanent seems to require an astronomically long computation. Proving this — proving that *no* shortcut exists — remains one of the deepest unsolved problems in all of mathematics.

The difficulty is not in showing that any *particular* method fails. It is in proving that *every conceivable* method must fail. You must rule out algorithms that nobody has imagined yet, strategies that exploit structure nobody has noticed. This is why circuit lower bounds, as they are called, have resisted attack for over fifty years.

But what if the answer has been hiding in plain sight — not in the algebra of the computation, but in its *geometry*?

---

## The Shape of a Polynomial

Every polynomial has a hidden skeleton. Take a polynomial like $3x^2y + 7xy^3 - 2y^2$. Strip away the coefficients — the 3, the 7, the −2 — and look only at which combinations of powers appear. You are left with a set of points: $(2,1)$, $(1,3)$, and $(0,2)$, representing the exponents. This set of points is called the *support* of the polynomial, and it lives in a grid of non-negative integers.

Mathematicians have known since Newton that the shape of this support — its convex hull, known as the Newton polytope — carries deep information about the polynomial's behavior. Where are its roots? How does it factor? These questions are connected to the geometry of its support.

But there is a finer invariant than the Newton polytope. It captures not just the outline of the support, but its internal structure — how it erodes under a natural combinatorial process. This invariant is called the *shadow profile*.

## Shadows All the Way Down

Imagine the support of a polynomial as a collection of blocks stacked in a multi-dimensional grid. Now imagine removing one block from the bottom of each stack — reducing exactly one coordinate of each point by one. The set of all possible results is called the *lower shadow* of the support.

This is an old idea in combinatorics, going back to the Kruskal-Katona theorem of the 1960s, which determines how small a shadow can be. But the new insight is to iterate: take the shadow of the shadow, then the shadow of that, and so on. At each step, you count how many distinct points you see. This sequence of counts — the shadow profile — is a fingerprint of the support's combinatorial structure.

The *shadow complexity* is the total count across all levels: how many distinct points appear in all the iterated shadows combined. It measures, in a precise sense, how "spread out" the support is as you peel it layer by layer down to nothing.

## The Convolution Surprise

Here is where the mathematics becomes genuinely surprising. When you multiply two polynomials, their supports combine through the *Minkowski sum*: you add every exponent vector from the first polynomial to every exponent vector from the second. This is the combinatorial counterpart of the algebraic operation of multiplication.

The key discovery is a *convolution inequality* for shadows under Minkowski sum. It says: if you take the $k$-th iterated shadow of a Minkowski sum $A + B$, the result is contained in a union:

$$\partial^k(A + B) \subseteq \bigcup_{i+j=k} \partial^i(A) + \partial^j(B)$$

In words: the shadow of a sum is controlled by sums of shadows. This containment has a beautifully simple proof. If a vector $c$ is in the $k$-th shadow of $A + B$, it was obtained by peeling off $k$ unit vectors from some sum $a + b$. Each of those $k$ peelings must reduce either the $a$-part or the $b$-part. If $i$ of them reduce $a$ and $j = k - i$ reduce $b$, then $c$ lies in $\partial^i(A) + \partial^j(B)$.

From this containment, counting gives a *convolution bound*: the shadow profile of $A + B$ is bounded by the convolution of the shadow profiles of $A$ and $B$. And summing over all levels yields the punchline:

**Shadow complexity is sub-multiplicative under Minkowski sum.**

That is: $\Sigma(A + B) \leq \Sigma(A) \cdot \Sigma(B)$.

## What This Means for Computation

Why does this matter for circuits? An algebraic circuit computes a polynomial by combining simpler polynomials through addition and multiplication gates. Addition gates combine supports by union; multiplication gates combine them by Minkowski sum.

Shadow complexity behaves perfectly with respect to both operations:
- **Addition**: $\Sigma(A \cup B) \leq \Sigma(A) + \Sigma(B)$ (sub-additivity)
- **Multiplication**: $\Sigma(A + B) \leq \Sigma(A) \cdot \Sigma(B)$ (sub-multiplicativity)

A circuit of size $s$ (meaning $s$ gates) can therefore produce a polynomial whose shadow complexity is at most $2^s$. This is because each gate at most doubles (addition) or squares (multiplication) the shadow complexity, and starting from inputs with shadow complexity 2 (a single variable $x_i$ has support $\{e_i\}$ with $\Sigma = 2$), after $s$ gates you get at most $2^s$.

This transforms the circuit lower bound problem: **to prove that a polynomial requires large circuits, it suffices to prove that its support has large shadow complexity.**

## The Counterexample That Sharpened the Blade

As with all good mathematics, the first naive conjecture turned out to be wrong — and the failure was illuminating.

The polynomial $x^d$ has support $\{(d)\}$ — a single point. Its shadow profile is $a_k = 1$ for each $k$ from 0 to $d$: at each level, you have exactly one point. The shadow complexity is $d + 1$. But $x^d$ can be computed by repeated squaring using only $O(\log d)$ gates. So the shadow complexity is polynomial in $d$, while the circuit size is logarithmic. The upper bound $\Sigma \leq 2^s$ is not tight enough, by itself, to give super-polynomial lower bounds for general polynomials.

But this failure points the way forward. The polynomial $x^d$ is degenerate: it lives in one dimension and has trivially small support. The interesting case is *multi-linear* polynomials — those where each variable appears with degree at most 0 or 1 — which live in the Boolean hypercube $\{0,1\}^n$. For these polynomials, the shadow profile is constrained by the combinatorics of the hypercube, and the Kruskal-Katona theorem guarantees rich shadow structure. The refined conjecture targets exactly this class.

## A New Front in an Old War

The permanent vs. determinant problem has been approached from many directions: algebraic geometry, representation theory, geometric complexity theory, communication complexity. Each approach illuminates part of the landscape but stalls against formidable barriers.

Shadow complexity opens a genuinely new front. Instead of analyzing the algebraic structure of the computation (which is the traditional approach), it analyzes the combinatorial structure of what the computation produces. The shadow profile is a *combinatorial invariant of the output*, not the circuit. Yet the convolution theorem shows that this invariant is tightly constrained by the circuit's structure.

This shift in perspective — from computation to its combinatorial shadow — draws on deep connections across mathematics. The convolution inequality echoes the entropy power inequality in information theory. The shadow operation connects to tropical geometry, where the "shadow" becomes a projection in the min-plus semiring. The sub-multiplicativity recalls how entropy behaves under convolution in probability theory.

## The Road Ahead

The immediate challenge is to compute shadow profiles for specific polynomials of interest — the permanent, the determinant, the elementary symmetric polynomials — and to prove that the shadow complexity of the permanent grows super-polynomially. If this can be done, it would establish the first unconditional super-polynomial lower bound on formula complexity via a purely combinatorial argument.

Beyond circuit complexity, shadow profiles may find applications wherever Minkowski sums appear: in convex geometry, where they characterize mixed volumes; in additive combinatorics, where they relate to sumset structure; in optimization, where they connect to the complexity of linear programming relaxations.

The shadow of computation is a faithful one. It preserves the essential structure of the computation while stripping away the algebraic noise. And in that shadow, the secrets of computational complexity may finally become visible.

---

*The mathematical results described in this article — the shadow convolution theorem, the sub-multiplicativity of shadow complexity, and the sub-additivity under union — have been proved with complete mathematical rigor. The proofs proceed by induction on the shadow iteration depth, using a key lemma about how shadows interact with Minkowski sums: if you reduce one coordinate of a sum, you must reduce it in one of the summands. This simple observation, iterated carefully, yields the full convolution inequality.*
