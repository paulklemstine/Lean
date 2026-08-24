# The Wrong Multiplication: How a Single Factor of $q$ Turns Moonshine Series Into a Group

## A series that starts with a pole

Some of the most famous objects in mathematics begin with a small act of bookkeeping. Take the modular invariant $J$, the function at the heart of Monstrous Moonshine. Expanded as a series in the variable $q$, it looks like this:

$$J(q) \;=\; \frac{1}{q} \;+\; 196884\,q \;+\; 21493760\,q^{2} \;+\; 864299970\,q^{3} \;+\; \cdots$$

Two things about this expansion are conventions, and one is a miracle. The conventions are that the series begins with exactly $q^{-1}$ — coefficient $1$, no worse pole — and that the constant term has been shifted away to $0$. The miracle is $196884 = 196883 + 1$: the dimension of the smallest nontrivial representation of the Monster, the largest sporadic finite simple group, plus one. That coincidence, spotted by John McKay in 1978, launched Monstrous Moonshine.

The conventions matter more than they look. The Monster has $194$ conjugacy classes, and to each one Moonshine attaches its own series — the McKay–Thompson series $T_g$ — every single one of which is expanded in the same shape:

$$T_g(q) \;=\; \frac{1}{q} \;+\; a_0 \;+\; a_1 q \;+\; a_2 q^{2} \;+\; \cdots$$

Call a formal Laurent series of that shape **normalized**: a simple pole at $q=0$ with residue exactly $1$, and nothing worse. Normalization is what makes the coefficients comparable across the $194$ classes; without it, "the coefficient of $q^n$" would be meaningful only up to a rescaling, and the whole numerology would dissolve.

So here is a natural question, the one this article is about. The normalized series form a beautiful, rigid family. Can we *do algebra* with them? Can we multiply two of them, invert one, take the square root of one — and stay inside the family?

## The obstruction, in one line

Multiply two normalized series and see what happens:

$$\left(\frac{1}{q} + \cdots\right)\left(\frac{1}{q} + \cdots\right) \;=\; \frac{1}{q^{2}} \;+\; \cdots$$

The pole doubles. Multiply $m$ of them and the pole has order exactly $m$: the leading term is $q^{-m}$, with leading coefficient $1 \cdot 1 \cdots 1 = 1$. The normalized series are emphatically *not* closed under multiplication, and the failure is not a subtle analytic defect — it is a clean, exactly computable integer. The order of the pole simply adds.

This is worth stating as a theorem, because its precision is the point.

> **Pole-Order Theorem.** If $f_1, \dots, f_m$ are normalized Laurent series, then their product has a pole of order exactly $m$ at $q = 0$, with leading coefficient $1$. Moreover, for an integer $k$, the series $q^{k} f_1 \cdots f_m$ is normalized **if and only if** $k = m - 1$.

The second sentence is where the mood changes. The obstruction is not just measurable; it is *correctable*, and correctable in exactly one way. There is precisely one power of $q$ that repairs the damage. For two series, it is a single factor of $q$. For all $194$ McKay–Thompson series at once, it is $q^{193}$:

$$q^{193} \prod_{g} T_g \quad\text{is normalized, and no other exponent works.}$$

## The corrected product

Once you know the repair is unique, the right move is obvious in hindsight: stop repairing products after the fact, and change the multiplication instead. Define the **corrected product** of two Laurent series by

$$f \star g \;:=\; q \cdot f \cdot g .$$

This one extra factor of $q$ does everything. If $f$ and $g$ are normalized, so is $f \star g$. The operation is commutative and associative — it is just ordinary multiplication with a twist that cancels itself out over repeated use. It has an identity element, and the identity is not $1$ (which is not normalized at all) but

$$\varepsilon(q) = \frac{1}{q},$$

since $q^{-1} \star f = q \cdot q^{-1} \cdot f = f$. And every normalized series has a corrected inverse: for $f = q^{-1} + a_0 + a_1 q + \cdots$ there is a unique normalized $g$ with $g \star f = q^{-1}$, and its first coefficients are

$$g = \frac{1}{q} \;-\; a_0 \;+\; (a_0^2 - a_1)\,q \;+\; \cdots$$

> **Group Theorem.** Under the corrected product $f \star g = q f g$, the normalized $q$-series form a commutative group with identity $q^{-1}$.

Why does this work so smoothly? Because of a change of coordinates that is almost too simple to notice. A Laurent series $f$ is normalized precisely when it can be written

$$f = \frac{1}{q}\,u(q), \qquad u(q) = 1 + u_1 q + u_2 q^{2} + \cdots$$

for a unique ordinary power series $u$ whose constant term is $1$. Such power series are called **$1$-units**, and they form a group under ordinary multiplication (their inverses are again $1$-units, computed by the usual recursion). Under the dictionary $f \leftrightarrow u = q f$, the corrected product becomes plain multiplication:

$$(q^{-1}u) \star (q^{-1}v) \;=\; q \cdot q^{-1}u \cdot q^{-1}v \;=\; q^{-1}(uv).$$

So the group of normalized $q$-series *is* the group of $1$-units, wearing a $q^{-1}$ as a hat. That is the entire content of the "normalization obstruction": normalized series are not a sub-semigroup of Laurent series, they are a **torsor** — a copy of the $1$-unit group shifted one step down the valuation axis.

The same picture explains where the pole order lives globally. Every invertible Laurent series $f$ factors uniquely as $q^{k} v$ where $k$ is its order and $v$ is an invertible power series, and this factorization is multiplicative in both coordinates. In other words:

> **Splitting Theorem.** The group of invertible formal Laurent series splits as a direct product $\mathbb{C}((q))^{\times} \cong \mathbb{Z} \times \mathbb{C}[[q]]^{\times}$, where the $\mathbb{Z}$-coordinate is the order of vanishing (the negative of the pole order) and the second factor is the group of invertible power series.

The pole order is a group homomorphism onto a direct summand. That is why the obstruction is total, and also why it is harmless: it is a coordinate, not a tangle.

## Square roots of moonshine

With a group in hand, one can ask the questions that only make sense in a group. Does a normalized series have a square root? Does $J$?

In the corrected world, a square root of $f$ means a normalized $g$ with $g \star g = f$, that is,

$$q\,g(q)^{2} = f(q).$$

Two things could go wrong. There might be no such $g$ (the group might fail to be *divisible*), or there might be several (the group might contain *torsion* — nontrivial elements $t$ with $t^{\star n} = \varepsilon$, which you could multiply into a root to get another). Both fail to go wrong, and both for reasons worth savoring.

**No torsion.** Suppose a $1$-unit $t$ satisfies $t^n = 1$ with $n \ge 1$. The geometric-sum identity

$$(1 + t + t^{2} + \cdots + t^{n-1})\,(t - 1) \;=\; t^{n} - 1 \;=\; 0$$

holds in the ring of power series, which has no zero divisors. So one of the two factors vanishes. But the constant term of $1 + t + \cdots + t^{n-1}$ is $1 + 1 + \cdots + 1 = n$, a nonzero complex number, so the first factor is not zero. Hence $t = 1$. No root of unity hides among the $1$-units, and therefore none hides among the normalized series.

**Full divisibility.** Every $1$-unit has an $n$-th root, and here the classical binomial series does the work. Write $u = 1 + h$ where $h$ has zero constant term, and set

$$v \;=\; (1+X)^{1/n}\Big|_{X = h} \;=\; \sum_{k \ge 0} \binom{1/n}{k}\, h^{k}.$$

The substitution makes sense as a formal power series because $h$ has no constant term, so each coefficient of $v$ is a finite sum. Because the binomial series obeys the exponent law $(1+X)^{r}(1+X)^{s} = (1+X)^{r+s}$, raising $v$ to the $n$-th power replaces the exponent $1/n$ by $n \cdot \tfrac1n = 1$, and $(1+X)^{1} = 1 + X$ evaluated at $h$ is simply $1 + h = u$. So $v^n = u$, and $v$ has constant term $1$. Note where the hypotheses live: we needed to divide by $n$, so this is a characteristic-zero phenomenon.

Put the two together and you get the punchline of the story.

> **Unique Divisibility Theorem.** For every normalized $q$-series $f$ and every $n \ge 1$ there is **exactly one** normalized $q$-series $g$ with $g^{\star n} = f$; equivalently, exactly one normalized $g$ with $q^{\,n-1} g(q)^{n} = f(q)$.

The exponent $n-1$ is not decoration: the $n$-th power in the corrected group is $f^{\star n} = q^{\,n-1} f^{n}$, the same correcting exponent as before, now for $n$ equal factors.

A torsion-free divisible abelian group is a $\mathbb{Q}$-vector space; the scalar $r = p/d$ acts by "take the $d$-th root, then the $p$-th power", and unique divisibility makes this well defined. So the normalized $q$-series carry *rational* corrected powers $f^{\star r}$, obeying $f^{\star (r+s)} = f^{\star r} \star f^{\star s}$ and $f^{\star (rs)} = (f^{\star s})^{\star r}$, with $f^{\star r}$ characterized as the unique normalized series whose $d$-th corrected power equals the $p$-th corrected power of $f$.

The obstruction of the opening paragraphs has evaporated completely. Once you use the right multiplication, the family of moonshine-shaped series has no arithmetic obstruction whatsoever: it is as divisible as the rational numbers, and roots are never ambiguous.

## What the square root of $J$ actually looks like

Uniqueness has a pleasant consequence: the coefficients of a root are given by universal polynomial formulas. Writing $f = q^{-1} + a_0 + a_1 q + a_2 q^{2} + \cdots$ and $g = q^{-1} + b_0 + b_1 q + b_2 q^{2} + \cdots$ for its corrected square root, comparing coefficients gives

$$b_0 = \frac{a_0}{2}, \qquad b_1 = \frac{a_1}{2} - \frac{a_0^{2}}{8}, \qquad b_2 = \frac{a_2}{2} - \frac{a_0 a_1}{4} + \frac{a_0^{3}}{16}.$$

These are the first Newton-type identities of the corrected group, and the denominators $2, 8, 16$ are exactly what a square root should produce.

Now feed in $J$, whose constant term is $0$ and whose next coefficients are $196884$ and $21493760$. The corrected square root of $J$ starts

$$\sqrt{J}^{\;\star} \;=\; \frac{1}{q} \;+\; 0 \;+\; 98442\,q \;+\; 10746880\,q^{2} \;+\; \cdots$$

with $98442 = 196884/2$ and $10746880 = 21493760/2$. So far, unremarkable: those two coefficients are even. But the formula for $b_2$ divides by $16$, and the next ones divide by ever larger powers of $2$, so the natural expectation is denominators growing without bound. Instead, an exact computation of the coefficients gives

$$-4413263697,\quad -1047821432832,\quad 376869391313174,\quad 150580578862513152,\quad \ldots$$

— integers, every one of them, at least as far as the computation has been pushed (through $q^{10}$). The divisions by $2$, $8$, $16$, $32$ all cancel.

The contrast makes it sharper. Do the same with the corrected *cube* root of $J$ and the denominators are

$$1,\ 1,\ 3,\ 1,\ 1,\ 9,\ 1,\ 1,\ 81,\ \ldots$$

and with the fifth root they are powers of $5$ climbing to $5^{6}$ within ten terms. The integrality of the corrected square root of $J$ is a prime-specific phenomenon: halving moonshine is integral, thirding it is not.

This is not an accident waiting to be explained away. In the corrected group, "take the square root" is the operator $u \mapsto u^{1/2}$ on $1$-units, and asking whether it preserves integrality of the moonshine coefficients is asking for a family of $2$-adic congruences among the graded dimensions $c(n)$ of the Moonshine module — the kind of congruence that replication formulas and Hecke-type operators are made of. The framework above turns a numerical curiosity into a precise conjecture about the image of the binomial series $(1+X)^{1/2}$ over the $2$-adic integers.

## The geometric mean of the Monster

There is one more thing a group buys you, and it is irresistible.

The corrected product of all $194$ McKay–Thompson series, namely $q^{193}\prod_g T_g$, is a normalized series. It is therefore a single element of a uniquely divisible group, and single elements of uniquely divisible groups have unique $194$-th roots. So:

> **Moonshine Mean Theorem.** There is exactly one normalized $q$-series $G$ with
> $$q^{193} G(q)^{194} \;=\; q^{193} \prod_{g} T_g(q).$$

$G$ is the *geometric mean* of the Monster's trace functions — the canonical "average" McKay–Thompson series, well defined with no choices at all. In an ordinary multiplicative setting one would have to worry about which $194$-th root to pick, and there would be $194$ of them differing by roots of unity. Here, torsion freeness kills the ambiguity outright: the mean exists, and it is one series, not $194$.

Whether $G$ has arithmetic meaning — modularity, integrality, a representation-theoretic interpretation — is exactly the sort of question the corrected framework is built to pose. What is settled is that the object exists and is unique.

## The moral

The story has the shape of a good algebraic joke. A famous family of objects appears to be badly behaved: closed under nothing, obstructed by an integer that grows with the number of factors. One inspects the obstruction and finds it is not noise but a homomorphism — the order of vanishing, a coordinate on the group of invertible Laurent series that splits off cleanly. One repairs the operation rather than the objects, by the unique power of $q$ that the obstruction itself dictates. And then the repaired structure turns out to be not merely a group but the friendliest kind of abelian group there is: torsion free, divisible, a $\mathbb{Q}$-vector space in multiplicative clothing, where every root of every order exists and is unique.

The normalization $q^{-1} + O(q)$ was never an obstruction. It was a coordinate chart, and the corrected product is the transition map that makes it an atlas.

Along the way, one concrete question is left standing on the table, with numerical evidence and a precise formulation: *why is the corrected square root of the modular invariant integral?* The coefficients

$$98442,\quad 10746880,\quad -4413263697,\quad -1047821432832,\quad \ldots$$

are waiting for their representation-theoretic explanation. Moonshine, as usual, has answered one question by asking a better one.
