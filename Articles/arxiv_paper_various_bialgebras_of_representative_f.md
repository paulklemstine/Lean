# Two Ways to Multiply a Word

*How riffle shuffles, rational languages and exponentials of letters split the world of noncommutative series into two irreconcilable halves.*

---

## A deck of cards made of letters

Take two words, say $ab$ and $c$, and imagine each is a small stack of cards: the first stack has the cards $a$ then $b$, the second has just $c$. Now riffle them together, keeping the internal order of each stack intact. There are exactly three ways:

$$ab \sqcup\!\sqcup c \;=\; abc + acb + cab .$$

(I write $\sqcup\!\sqcup$, a symbol meant to evoke two rows of cards being interleaved, for this operation.) This is the **shuffle product**, and it is one of the most quietly important operations in mathematics. It is what you get when you multiply iterated integrals; it is what governs the algebra of Chen's path signatures behind modern "rough path" methods in stochastic analysis; it is the multiplication behind multiple zeta values; and it is the reason the algebra of polynomial functions on a free group looks the way it does.

There is a subtlety you must respect from the outset: the shuffle is a *multiset*. Shuffle $a$ with $a$ and you do not get $aa$; you get $aa$ **twice**, because the two cards, though they look identical, came from different stacks. Multiplicity is not a bookkeeping nuisance — it is the whole content. In general,

$$|u \sqcup\!\sqcup v| \;=\; \binom{|u| + |v|}{|u|},$$

the number of ways to choose which positions of the merged word come from $u$: exactly the count of riffles of a $|u|$-card stack with a $|v|$-card stack.

Now notice that words already had an obvious multiplication: **concatenation**, $u \cdot v = uv$. It is associative, it has the empty word as unit, and it is spectacularly noncommutative. The shuffle is a completely different multiplication on the same objects, and it *is* commutative. So the vector space of "polynomials in noncommuting letters" — finite formal linear combinations of words, written $K\langle X\rangle$ over a field $K$ containing the rationals — carries two products at once.

This article is about what happens when you take that coincidence seriously.

## Multiplication needs a partner

A product tells you how to fuse two things. A **coproduct** tells you how to take one thing apart, in all possible ways at once. A vector space with a compatible product and coproduct is a **bialgebra**, and bialgebras are the algebraic skeletons of symmetry: they are what group algebras, function algebras on groups, and enveloping algebras of Lie algebras all secretly are.

Words come with two natural ways to take them apart.

**Take apart by position.** Pick a subset $S$ of the positions of the word $w$; read off the letters at those positions as one word $u$, the letters at the remaining positions as another word $v$, and record the pair $u \otimes v$. Summing over all $2^{|w|}$ subsets gives the **unshuffle coproduct**:

$$\Delta_{\sqcup\!\sqcup}(w) \;=\; \sum_{S \subseteq \text{positions}} w|_S \otimes w|_{S^c}.$$

For example $\Delta_{\sqcup\!\sqcup}(aba) = 1 \otimes aba + a \otimes ba + b \otimes aa + a\otimes ab + ab \otimes a + aa\otimes b + ba \otimes a + aba \otimes 1$: eight terms, as promised. Equivalently, $\Delta_{\sqcup\!\sqcup}$ is the unique way of taking words apart which is multiplicative for concatenation and makes each single letter *primitive*, $\Delta_{\sqcup\!\sqcup}(a) = a \otimes 1 + 1 \otimes a$ — exactly the recursion $\Delta_{\sqcup\!\sqcup}(aw) = (a \otimes 1 + 1 \otimes a)\,\Delta_{\sqcup\!\sqcup}(w)$.

**Take apart by cutting.** Slice the word at one of its $|w|+1$ cut points:

$$\Delta_{\mathrm{conc}}(w) \;=\; \sum_{w = z_1 z_2} z_1 \otimes z_2, \qquad \Delta_{\mathrm{conc}}(abc) = 1\otimes abc + a \otimes bc + ab \otimes c + abc \otimes 1.$$

This is the **deconcatenation coproduct**.

Pair them off correctly and you get two bialgebras on the very same space:

$$\bigl(K\langle X\rangle,\ \text{concatenation},\ \Delta_{\sqcup\!\sqcup}\bigr) \qquad\text{and}\qquad \bigl(K\langle X\rangle,\ \sqcup\!\sqcup,\ \Delta_{\mathrm{conc}}\bigr).$$

The first is noncommutative but *cocommutative* (its coproduct is symmetric under swapping the two tensor factors — visibly so, since complementing $S$ swaps the factors). The second is commutative but *co-noncommutative*. Each is the mirror of the other, and the mirror is not a metaphor: it is an honest duality, which is the first theorem of this story.

**Shuffle/Unshuffle Duality.** *For all words $u, v, w$, the multiplicity of $w$ in the shuffle $u \sqcup\!\sqcup v$ equals the multiplicity of the pair $(u,v)$ in the unshuffle $\Delta_{\sqcup\!\sqcup}(w)$.*

In the inner product on $K\langle X\rangle$ that declares distinct words orthonormal, this says $\langle u \sqcup\!\sqcup v,\, w\rangle = \langle u \otimes v,\, \Delta_{\sqcup\!\sqcup}(w)\rangle$: shuffling and unshuffling are transposes of one another. The proof is a four-case induction peeling one letter at a time, but the picture is simpler than the induction: both numbers count the same thing, namely the ways to colour the positions of $w$ with two colours so that the first colour spells $u$ and the second spells $v$.

Both compatibility axioms hold, and their proofs illustrate the difference in temperament between the two structures. On the concatenation side it is a short induction: $\Delta_{\sqcup\!\sqcup}(uv) = \Delta_{\sqcup\!\sqcup}(u)\,\Delta_{\sqcup\!\sqcup}(v)$, because splitting the positions of a concatenation means splitting those of each factor independently.

On the shuffle side, the corresponding statement is the harder and more beautiful

**Bialgebra Axiom for the Shuffle Structure.** *Cutting commutes with riffling:*
$$\Delta_{\mathrm{conc}}(u \sqcup\!\sqcup v) \;=\; \Delta_{\mathrm{conc}}(u) \,\sqcup\!\sqcup_2\, \Delta_{\mathrm{conc}}(v),$$
*where $\sqcup\!\sqcup_2$ shuffles tensors componentwise, $(p_1 \otimes p_2)\sqcup\!\sqcup_2(q_1\otimes q_2) = (p_1 \sqcup\!\sqcup q_1)\otimes(p_2\sqcup\!\sqcup q_2)$.*

Combinatorially: cutting a riffle of two decks in one place is the same as cutting each deck in one place and riffling the two left halves and the two right halves separately. That is intuitive to say and unpleasant to prove directly, because both sides are sums over an unruly index set. The elegant route is to *not* prove it directly at all. Compute the coefficient of a fixed tensor $z_1 \otimes z_2$ on each side; use duality to convert every shuffle count into an unshuffle count; and watch both sides turn into the *same* fourfold sum, with the two sides differing only by the order in which the four summations are performed. Transposing a quadruple sum is a triviality — and the theorem falls out. It is a small lesson in the economy of duality: choose the right side of the mirror and the work evaporates.

## The characters: who are the multiplicative functions?

Once you have a bialgebra, the interesting question is: what are its **characters**? A character is a scalar-valued function that turns the product into ordinary multiplication of numbers and sends the unit to $1$. Characters are the "points" of an algebra; for the algebra of functions on a group they are literally the points of the group.

For concatenation, a character is a function $f$ on words with $f(1) = 1$ and $f(uv) = f(u)f(v)$ — a monoid morphism to the multiplicative scalars. Such an $f$ is determined by its values on single letters, and the answer is complete and clean.

**Characters of the Concatenation Structure.** *A function $f: X^* \to K$ satisfies $f(1)=1$ and $f(uv) = f(u)f(v)$ if and only if there is a family of scalars $(c_x)_{x \in X}$ with*
$$f(x_1 x_2 \cdots x_n) = c_{x_1} c_{x_2}\cdots c_{x_n}.$$

Series of this form have a name with a pleasing pedigree. Write $\ell = \sum_x c_x\, x$ for a **plane**: a linear combination of letters only, the degree-one part of the picture. Then the function above is precisely the coefficient list of the **Kleene star** $\ell^* = 1 + \ell + \ell^2 + \cdots$. So: *the characters of the concatenation bialgebra are exactly the Kleene stars of planes.* Nothing else is multiplicative.

There is an infinitesimal counterpart. Differentiate the multiplicativity condition, in the sense of replacing "$f(uv) = f(u)f(v)$" by the Leibniz-style rule $g(uv) = g(u)\varepsilon(v) + \varepsilon(u)g(v)$, where $\varepsilon$ is the counit ($\varepsilon(w) = 1$ if $w$ is empty, $0$ otherwise). These are the **infinitesimal characters**, and they too are pinned down completely.

**Infinitesimal Characters are Planes.** *A function $g$ satisfies $g(uv) = g(u)\varepsilon(v) + \varepsilon(u)g(v)$ for all $u,v$ if and only if $g$ vanishes on every word whose length is not $1$ — that is, if and only if $g$ is a plane.*

The proof in one direction is a two-line calculation ($g$ must kill the empty word, and if both $u$ and $v$ are nonempty then both terms on the right vanish while $uv$ has length $\ge 2$); in the other, one just checks the rule case by case. This is the "Ree theorem" flavour of the subject: a global multiplicativity condition collapses onto a statement about a single degree.

## The other side of the mirror: exponentials

Now ask the same question for the shuffle. A **shuffle character** is a function $f$ with $f(1)=1$ and

$$f(u)\,f(v) \;=\; \sum_{z \in u \sqcup\!\sqcup v} f(z) \qquad \text{(with multiplicity)}.$$

By duality, these are exactly the *group-like* series for the unshuffle coproduct — the analogue, in this setting, of points of a group. And they look completely unlike the previous family.

**Exponentials of Planes are Shuffle Characters.** *For any plane $\ell = \sum_x c_x x$, the series $\exp(\ell)$ whose coefficient at a word $x_1\cdots x_n$ is*
$$\frac{c_{x_1}\cdots c_{x_n}}{n!}$$
*is a character of the shuffle algebra.*

Why the factorials? Because every shuffle of $u$ and $v$ has exactly the same multiplicative letter-weight as $uv$ — shuffling permutes letters, it does not create or destroy them — so the shuffle sum collapses to (number of shuffles) $\times$ (common weight), and the binomial cardinality $\binom{m+n}{m}$ is precisely the fudge factor that turns $\frac{1}{m!}\cdot\frac{1}{n!}$ into $\frac{1}{(m+n)!}$. It is the same identity that makes $e^x e^y = e^{x+y}$ work, transported to words.

That the factorials are forced, and not merely convenient, is the content of the one-letter case of Ree's theorem:

**Divided Powers.** *Every shuffle character $f$ satisfies $f(a^n) = f(a)^n/n!$ for each letter $a$ and each $n$.*

The proof is a one-line induction resting on the identity $a^n \sqcup\!\sqcup a = (n+1)\, a^{n+1}$: shuffling a stack of $n$ identical cards with a single card gives the same word $n+1$ times over. Multiplicity, again, doing the real work. So a shuffle character has *no freedom at all* along a single letter beyond its value on that letter — it must be an exponential there.

We now have two clean families:

| | characters | typical member |
|---|---|---|
| concatenation | Kleene stars $\ell^*$ of planes | coefficient of $w=x_1\cdots x_n$ is $c_{x_1}\cdots c_{x_n}$ |
| shuffle | group-like series, including $\exp(\ell)$ | coefficient of $w=x_1\cdots x_n$ is $c_{x_1}\cdots c_{x_n}/n!$ |

The two lists differ only by $n!$. That innocuous factorial is about to become a chasm.

## Rationality, or: what a finite machine can compute

To see the chasm, we need the third character of the story: **rationality**.

A function $f$ on words is called **representative** when the two-variable function $(u,v) \mapsto f(uv)$ factors through a finite sum,

$$f(uv) \;=\; \sum_{i=1}^{n} g_i(u)\, h_i(v)$$

for some finite families of functions $g_i, h_i$. This is a "finite memory" condition: to know $f$ on $uv$, you need to know only finitely many numbers about $u$.

That intuition is a theorem — the Kleene–Schützenberger theorem, one of the foundational results of automata theory, here in its function-theoretic form.

**Kleene–Schützenberger.** *For a function $f : X^* \to K$ with values in a field, the following are equivalent:*
1. *$f$ is representative: $f(uv) = \sum_{i<n} g_i(u)h_i(v)$;*
2. *the left translates $w^{-1}f : u \mapsto f(wu)$, over all words $w$, span a finite dimensional space of functions;*
3. *$f$ admits a **linear representation**: there are an integer $n$, a row vector $\lambda \in K^n$, a column vector $\gamma \in K^n$, and a monoid morphism $\mu : X^* \to M_n(K)$ (that is, a matrix $\mu(x)$ for each letter, extended multiplicatively) with*
$$f(w) \;=\; \lambda\, \mu(w)\, \gamma \quad\text{for every word } w.$$

The cycle of implications is short to describe. From (1) to (2): the factorization exhibits every translate $w^{-1}f$ inside the span of the finitely many $h_i$. From (2) to (3): this is the Myhill–Nerode construction — the space $V$ spanned by the translates is stable under the shift operators $f \mapsto x^{-1}f$, so choosing a basis of $V$ turns each letter into a matrix, the vector $\lambda$ reads the coordinates of $f$ itself, and $\gamma$ evaluates at the empty word. From (3) to (1): expand $\mu(uv) = \mu(u)\mu(v)$ and read off the finite sum over matrix entries.

So the representative functions are exactly the ones computable by a finite weighted automaton; their formal series $\sum_w f(w)\, w$ are exactly the **rational** noncommutative series. And they form a rich algebra:

**Closure Properties.** *Representative functions are closed under sums, scalar multiples, and pointwise (Hadamard) products (the latter via the tensor product of representations, of dimension $nm$). Every monoid morphism $X^* \to (K,\cdot)$ — in particular every Kleene star of a plane — is representative, with a one-dimensional representation.*

And, less obviously, they are closed under the shuffle too. Define the **shuffle product of series** coefficientwise through the unshuffle coproduct,

$$(f \sqcup\!\sqcup g)(w) \;=\; \sum_{(u,v)\,\in\,\Delta_{\sqcup\!\sqcup}(w)} f(u)\, g(v).$$

This is the honest extension of the shuffle of words: applied to the indicator series of $u$ and of $v$, it returns exactly the multiplicity function of $u \sqcup\!\sqcup v$ — which is duality, once again, in action. Cocommutativity of $\Delta_\sqcup\!\sqcup$ makes this product commutative; coassociativity makes it associative; the counit is its unit. And:

**Rationality is Preserved by Shuffling.** *If $f$ and $g$ are representative, so is $f \sqcup\!\sqcup g$.*

The proof is the bialgebra axiom doing exactly what a bialgebra axiom is for. Since $\Delta_{\sqcup\!\sqcup}(uv) = \Delta_{\sqcup\!\sqcup}(u)\Delta_{\sqcup\!\sqcup}(v)$, a splitting of $uv$ is a splitting of $u$ followed by one of $v$; substituting the factorizations $f(uv) = \sum_i a_i(u)b_i(v)$ and $g(uv)=\sum_j c_j(u)d_j(v)$ and regrouping yields
$$(f\sqcup\!\sqcup g)(uv) \;=\; \sum_{i,j}\ \bigl(a_i \sqcup\!\sqcup c_j\bigr)(u)\ \bigl(b_i \sqcup\!\sqcup d_j\bigr)(v),$$
a factorization of size $nm$. So the rational world is a subalgebra for the shuffle as well as for the ordinary pointwise product.

## The chasm

We can finally put the two halves of the mirror side by side, and the answer is stark.

**The Separation Theorem.** *Over the real numbers, let $\ell$ be a plane with $c_a \neq 0$ for some letter $a$. Then:*
- *$\exp(\ell)$ is a character of the shuffle algebra, but it is **not** a representative function — its graph is a non-rational series;*
- *$\ell^*$ is a representative function of rank one, but it is **not** a character of the shuffle algebra.*

*Indeed, a Kleene star $\ell^*$ is a shuffle character only in the degenerate case where $\ell$ vanishes on every letter. The two character groups intersect exactly in the counit.*

The second half is a one-line computation: if $\ell^*$ were a shuffle character, then applying the shuffle rule to $x \sqcup\!\sqcup x = 2\,xx$ gives $c_x^2 = 2c_x^2$, so $c_x = 0$ for every letter.

The first half is where the factorials take their revenge. Suppose $\exp(\ell)$ were representative. By Kleene–Schützenberger, its translates would span a finite dimensional space, say of dimension $N$. Then the $N+1$ translates along the powers of the single letter $a$ must be linearly dependent, and unwinding the coefficient $\exp(\ell)(a^{m+n}) = c_a^{m+n}/(m+n)!$ turns that dependency into a nontrivial relation

$$\sum_{i \le N} g_i \cdot \frac{1}{(n+i)!} \;=\; 0 \qquad \text{for every } n \ge 0.$$

In other words, the infinite **Hankel matrix** $\bigl[\,1/(m+n)!\,\bigr]_{m,n \ge 0}$ would have finite rank. It does not:

**Independence of the Factorial Hankel Rows.** *If $\sum_{i \le N} g_i /(n+i)! = 0$ for every $n \ge 0$, then every $g_i = 0$.*

The argument is a beautifully elementary Archimedean squeeze. Fix the smallest index $k$ whose coefficient you wish to kill (by strong induction, all smaller ones already vanish). Multiply the relation by $(n+k)!$. The $k$-th term becomes exactly $g_k$; every later term $i > k$ picks up a factor
$$\frac{(n+k)!}{(n+i)!} \;\le\; \frac{1}{n+k+1},$$
because the factorial in the denominator has at least one extra factor of size at least $n+k+1$. Hence $|g_k| \le M/(n+k+1)$ where $M = \sum_i |g_i|$ is a fixed constant — and this holds for *every* $n$. Letting $n$ grow, $g_k = 0$. Nothing deeper than the fact that factorials outrun any constant.

Equivalently and more vividly: the determinants of the leading $n\times n$ blocks of $[1/(i+j)!]$ are $1$, $-\tfrac12$, $-\tfrac1{144}$, $\tfrac{1}{1036800}$, $\tfrac{1}{1463132160000}, \dots$ — tiny, alternating in sign, but never zero. The matrix has infinite rank. And so $\exp(\ell)$ has infinite Hankel rank, and no finite automaton, however cleverly weighted, will ever compute the coefficients $c^n/n!$.

## What the chasm means

Step back and look at the shape of the result.

The space $K\langle X\rangle$ carries two bialgebra structures that are formally mirror images, and each has a perfectly describable set of characters. On the concatenation side, the characters are *exactly* the objects that finite automata love: Kleene stars, geometric-type series, rank-one rational functions. On the shuffle side, the characters are exponentials — the objects that analysis loves, carrying divided powers and factorial denominators — and they are exactly the objects finite automata can never produce.

This is not a defect of one structure or an accident of the other; it is the precise sense in which the "group-like" and the "rational" worlds are transverse. The dictionary that the duality provides is perfect at the level of the algebra: shuffle and unshuffle are transposes, both bialgebra axioms hold, rationality survives the shuffle product. It is only at the level of *points* — of characters — that the two worlds refuse to overlap, meeting in the single trivial point $\varepsilon$.

There is a practical moral, too. The shuffle algebra is exactly the algebra of iterated integrals: the signature of a smooth path multiplies by the shuffle rule, and its exponential-like coefficients are why signatures encode geometry so efficiently. The concatenation algebra is exactly the algebra of finite-state computation. The separation theorem says, in the sharpest available terms, that path signatures are not automaton-computable objects: their factorial decay is a genuinely analytic phenomenon, not a combinatorial one. Anyone who has tried to truncate a signature at a fixed depth and hoped for an exact finite recursion has met this theorem empirically.

The most satisfying part, to me, is how much of the argument is carried by multiplicities. That $a \sqcup\!\sqcup a = 2\,aa$ rather than $aa$ is the seed of the divided powers; the divided powers are the seed of the factorials; the factorials are the seed of the Hankel obstruction; and the Hankel obstruction is the chasm. A single factor of two, patiently followed, separates two universes.

---

### The results, collected

For a field $K \supseteq \mathbb{Q}$ and an alphabet $X$:

1. **Shuffle basics.** $\sqcup\!\sqcup$ is commutative and associative, is graded ($z \in u\sqcup\!\sqcup v \Rightarrow |z| = |u|+|v|$), and $|u \sqcup\!\sqcup v| = \binom{|u|+|v|}{|u|}$.
2. **Duality.** The multiplicity of $w$ in $u \sqcup\!\sqcup v$ equals the multiplicity of $(u,v)$ in $\Delta_{\sqcup\!\sqcup}(w)$.
3. **Two bialgebras.** $\Delta_{\sqcup\!\sqcup}$ is coassociative, cocommutative and multiplicative for concatenation; $\Delta_{\mathrm{conc}}$ is an algebra morphism for the shuffle, $\Delta_{\mathrm{conc}}(u \sqcup\!\sqcup v) = \Delta_{\mathrm{conc}}(u) \sqcup\!\sqcup_2 \Delta_{\mathrm{conc}}(v)$.
4. **Characters.** Concatenation characters $=$ Kleene stars of planes; concatenation infinitesimal characters $=$ planes; $\exp(\ell)$ is a shuffle character; every shuffle character has divided powers $f(a^n) = f(a)^n/n!$.
5. **Kleene–Schützenberger.** Representative $\iff$ finite dimensional translate space $\iff$ linear representation $f(w) = \lambda\mu(w)\gamma$. Representative functions are closed under sums, scalars, Hadamard products and shuffle products.
6. **Separation.** Over $\mathbb{R}$, $\exp(\ell)$ for a nonzero plane $\ell$ is a shuffle character that is not representative; $\ell^*$ is representative but is a shuffle character only when $\ell = 0$.

$\sqcup\!\sqcup$ denotes the shuffle product throughout.
