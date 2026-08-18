# The Only Thing That Can Go Wrong Is the Pole

## How a question about factoring infinite series turned into a story about gauge freedom, coin flips, and the $p$-adic numbers

### A factory that makes one kind of part

Imagine a factory with exactly one product line. It manufactures a single type of component: an infinite series with a **simple pole** — an object that, near the origin, blows up exactly like $1/q$ and no worse. Written out, such a series looks like

$$f(q) \;=\; \frac{a_{-1}}{q} + a_0 + a_1 q + a_2 q^2 + \cdots, \qquad a_{-1} \neq 0 .$$

The factory can produce any component of this shape. Now a customer arrives with an order. They want a specific target series $g$, and they want it built as a product of exactly $m$ of your components, with one correction applied at the end: multiply the whole product by $q^m$ to cancel the poles you introduced. In symbols, the customer wants

$$g \;=\; q^m \cdot f_0 \, f_1 \cdots f_{m-1},$$

where each $f_i$ has a simple pole.

Which orders can the factory fill? And when it can fill an order, in how many ways?

These two questions — *realizability* and *rigidity* — have complete answers, and the answers turn out to be surprisingly rigid, surprisingly flexible, and (in the right sense) surprisingly universal. This article tells the story.

### Counting poles is the whole game

The single most useful number attached to a formal series is its **order**: the exponent of the lowest power of $q$ that actually appears. A series with a simple pole has order $-1$. A series like $3 + 5q + \cdots$ has order $0$. A series like $q^2 - q^7$ has order $2$. Order is a bookkeeping device with one magic property: **it turns multiplication into addition**. Multiply two series and their orders add.

So look again at the customer's order. Each of the $m$ components contributes order $-1$. Their product therefore has order $-m$. Multiplying by $q^m$ adds $m$ back. The result has order exactly

$$-1 - 1 - \cdots - 1 + m \;=\; 0 .$$

Every fillable order therefore has order $0$: the target must be a series that neither vanishes nor blows up at the origin, one whose constant term is nonzero. That's a genuine obstruction, and it kills, for instance, any request for $g = q$ or $g = 1/q$.

The first main theorem says that this obstruction is the *only* one.

> **Realizability Theorem.** Fix any field of coefficients and any number of slots $m \ge 1$. A series $g$ can be written as $q^m f_0 f_1 \cdots f_{m-1}$ with every $f_i$ having a simple pole **if and only if** $g$ has order $0$.

The proof is a one-line construction, and it is worth seeing because everything later in the story is a deformation of it. Put the entire target into the first slot and fill the rest with the cheapest legal component, $1/q$:

$$f_0 = q^{-1} g, \qquad f_1 = f_2 = \cdots = f_{m-1} = q^{-1}.$$

If $g$ has order $0$, then $q^{-1}g$ has order $-1$: a legitimate component. The product of all $m$ slots is $q^{-m} g$, and the renormalizing factor $q^m$ restores $g$ exactly. Order in, order out. The factory can fill every order-$0$ request, for every $m$, over every field — including the two-element field, where you cannot even rescale by a constant.

### One slot is rigid; two slots are a universe

Now the second question. Having filled the order, could the factory have done it differently?

For $m = 1$ the answer is a flat no. The equation $g = q f_0$ determines $f_0 = q^{-1} g$ and nothing else is possible. One slot, one factorization.

For $m \ge 2$ the situation reverses completely, and does so violently. Take any legal factorization and pick a series $u$ of order $0$ — a **unit**, something invertible with no pole and no zero at the origin. Replace

$$f_0 \rightsquigarrow u \, f_0, \qquad f_1 \rightsquigarrow u^{-1} f_1,$$

leaving all other slots alone. Multiplying by $u$ doesn't change anyone's order, so both modified slots still have simple poles; and the two factors $u$ and $u^{-1}$ annihilate each other inside the product. So the new family is a *different* factorization of the *same* target.

How many such $u$ are there? Infinitely many, always. The series $1 + q$, $1 + q^2$, $1 + q^3$, … are all distinct units of order $0$, and they exist over any field whatsoever. Hence:

> **Non-Uniqueness Theorem.** For every $m \ge 2$ and every order-$0$ target $g$, the set of factorizations of $g$ into $m$ simple-pole factors is infinite.

The dichotomy is sharp and has no middle ground: $m = 1$ gives exactly one factorization; $m \ge 2$ gives infinitely many. And the structure of that infinitude is completely understood. Any two factorizations of the same target differ slot by slot by units of order $0$ whose product is $1$; and conversely, twisting any factorization by such a family of units produces another. In the language of symmetry, the set of factorizations is a **torsor** under the group of unit-valued twists with trivial total product — a homogeneous space with no preferred point, exactly like the set of possible origins of a Euclidean space.

Counting this group makes the dichotomy quantitative. A twist is a choice of $m$ units multiplying to $1$: choose the last $m-1$ freely and the first is forced. So the fibre — the space of ways to fill a given order — is *free of rank $m-1$*. That integer, $m-1$, deserves a name: it is the **rigidity index** of the factorization problem. Rigidity index $0$ means a unique answer. Rigidity index $n > 0$ means $n$ independent knobs to turn.

### The pole profile is a mirage

There is an obvious way to try to break the symmetry: stop insisting that every factor have a *simple* pole. Ask instead for a prescribed **pole profile** $d_0, d_1, \dots, d_{m-1}$ — factor $i$ must have order exactly $d_i$ — and allow an arbitrary renormalization $q^k$. Surely demanding, say, a double pole in slot $0$ and a zero in slot $1$ carves out a different family of achievable targets?

It does not.

> **Gauge Invariance of the Profile.** For $m \ge 1$, the set of targets realizable with profile $d$ and renormalization $q^k$ is exactly the set of series of order $k + \sum_{i<m} d_i$. Two profiles with the same total realize exactly the same targets, and their solution sets are in explicit one-to-one correspondence.

The correspondence is the obvious one, and that is the point: given a factorization with profile $d$, multiply slot $i$ by $q^{\,d_i' - d_i}$. Each slot's order shifts to $d_i'$, and because the shifts sum to zero, the product is untouched. The individual pole orders are what a physicist would call **pure gauge**: they carry no invariant information, and only their sum is observable. Rigidity cannot see the profile either — one profile gives a unique factorization exactly when any other profile of the same total does.

So the entire problem is governed by two integers: the total order (which decides *whether*) and the number of slots (which decides *how many*).

### Where the structure comes from: one short exact sequence

Behind all of this sits a single algebraic skeleton. Let $\mathcal{O}^\times$ denote the group of units — series of order $0$ — and let

$$\Pi \colon (\mathcal{O}^\times)^m \longrightarrow \mathcal{O}^\times, \qquad \Pi(u_0,\dots,u_{m-1}) = u_0 u_1 \cdots u_{m-1}$$

be the product map. Then there is a short exact sequence

$$1 \longrightarrow \ker \Pi \longrightarrow (\mathcal{O}^\times)^m \longrightarrow \mathcal{O}^\times \longrightarrow 1,$$

and it **splits**: the section pushes everything into slot $0$, which is precisely the canonical factorization used to prove realizability. Surjectivity of $\Pi$ *is* the realizability theorem. The kernel *is* the twist group, and it is isomorphic — as a group, not merely as a set — to $m-1$ free copies of $\mathcal{O}^\times$. Non-uniqueness *is* the statement that this kernel is nontrivial. Two theorems that looked like separate facts are the two halves of one exact sequence, and the rigidity index $m-1$ is its corank.

### The same theorem, in a different number system

Nothing in that skeleton mentions series. All it needs is a commutative group $G$ carrying a homomorphism $\mathrm{val} \colon G \to \mathbb{Z}$ (the order) and a distinguished element of value $1$ (the uniformizer $q$). Abstract those three ingredients and the whole theory — realizability, the torsor structure, the count $|\mathcal{O}^\times|^{\,m-1}$, the gauge invariance of profiles, the exact sequence — goes through verbatim.

Two instantiations are worth naming. The first recovers the Laurent series story. The second is a genuinely different world: the **$p$-adic numbers**, where "order" means the exponent of $p$ dividing a number, and the uniformizer is $p$ itself. There the theorem reads: a $p$-adic number is a product of $m$ numbers of prescribed $p$-adic valuations, times $p^k$, precisely when its own valuation is $k + \sum d_i$; and for $m \ge 2$ that factorization is never unique, since the $p$-adic units form an infinite group.

### Counting to the last digit

Over the $p$-adics one can do something the series world does not allow: **truncate**. Work modulo $p^D$ and everything becomes finite, so "infinitely many factorizations" turns into an exact number. The result is clean: modulo $p^D$, with $m = n+1$ slots, every target has exactly

$$\bigl((p-1)\,p^{\,D-1}\bigr)^{\,n}$$

factorizations, because the fibre is $n$ free copies of the unit group $(\mathbb{Z}/p^D)^\times$, whose size is Euler's totient $\varphi(p^D) = (p-1)p^{D-1}$. Raising the precision by one digit multiplies the count by exactly $p^{\,n}$. Package the counts into a generating function in a variable $T$ and the geometric growth becomes a rational function with denominator

$$1 - p^{\,n} T ,$$

an **Euler factor** whose exponent is exactly the rigidity index $n = m-1$. The abstract corank of a group homomorphism resurfaces as the degree in a counting series — the kind of coincidence that is never a coincidence.

Truncation also produces one delightful exception. Modulo $2$, the unit group is trivial: the only unit is $1$. So at $p = 2$, $D = 1$, the factorization is unique for *every* $m$, even though the corresponding statement over the $2$-adic numbers themselves is false. The finite levels are strictly more rigid than their limit, and this is the unique place where that happens. Reassuringly, no information is lost going up the tower: every factorization modulo $p^D$ lifts to one modulo $p^{D+1}$.

### Enter probability, and the collapse of the symmetry

Now turn the algebra into a statement about randomness. Let $X$ be a random variable taking values in $\{0,1,2,\dots\}$ with $P(X = n) = p_n$, and form its generating function $\sum_n p_n q^n$. The order of this series is dictated by a single question: **does the variable ever take the value $0$?** If $p_0 \neq 0$ the order is $0$; if $p_0 = 0$ the order is positive.

Combined with the realizability theorem, this gives a criterion of striking simplicity:

> **Probability Bridge.** A finitely supported law's generating function factors as $q^m$ times $m$ simple-pole series — for every $m \ge 1$ — if and only if the law charges the atom at $0$. If $P(X=0) > 0$ and $m \ge 2$, there are infinitely many such factorizations.

So the entire obstruction to this algebraic decomposition, for a probability distribution, is whether the distribution can output zero.

And now the twist — literally. All that abundance of factorizations came from twisting by a unit $u$ and its inverse $u^{-1}$. Probabilistic objects, though, are not merely algebraic: their coefficients must be **nonnegative**. What happens if we insist that both $u$ and $u^{-1}$ have nonnegative coefficients, so that the twist keeps us inside the world of probability?

Everything collapses. Suppose $u$ and $v$ both have nonnegative coefficients and $uv = 1$. For any $n \ge 1$, the $n$-th coefficient of the product is

$$\sum_{j=0}^{n} u_j v_{n-j} = 0,$$

a sum of nonnegative numbers equal to zero. Every term must therefore vanish. In particular $u_n v_0 = 0$; and since $u_0 v_0 = 1$ forces $v_0 \neq 0$, we get $u_n = 0$. So $u$ is a constant, and after the natural normalization $u_0 = 1$, we get $u = 1$.

> **Positivity Rigidity.** The group of positivity-preserving normalized twists is trivial. Consequently the only probability law on $\{0,1,2,\dots\}$ with $p_0 = 1$ whose generating function has a nonnegative reciprocal is the point mass at $0$.

This is a two-line argument that has no counterpart on the algebraic side, and it changes the character of the whole subject. Over a field, the factorization problem has an infinite-dimensional gauge group and no canonical answer. Impose positivity — that is, insist the objects be probabilities — and the gauge group evaporates. The canonical factorization stops being an arbitrary choice and becomes, in the probabilistic category, the only one.

### What the story is really about

Strip away the series and the primes and a familiar shape remains. There is a conserved quantity (the total order). It is the only obstruction to solving a decomposition problem. The solutions to that problem form not a set of isolated points but an orbit of a symmetry group, whose size is measured by a single integer, the rigidity index. Some features of a solution — the individual pole orders — are gauge artifacts and carry no information; only the invariant total matters. Truncate to finite precision and the symmetry group becomes a finite group whose order shows up as an Euler factor. Add a positivity constraint and the symmetry group dies, leaving a unique physical solution.

That pattern — conservation law, obstruction, gauge orbit, rigidity index, positivity as a symmetry-breaking constraint — recurs across mathematics, from linear algebra to gauge field theory to the theory of moment problems. Here we get to watch it play out in a setting simple enough to see every moving part, from the first line ("orders add") to the last (a sum of nonnegative numbers that vanishes).

The factory, in the end, can fill exactly the orders that conservation permits — and once positivity is demanded of the parts as well as the product, there is precisely one way to do it.
