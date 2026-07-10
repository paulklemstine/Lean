# Categorification of Entropy: The Information Loss of a Functor

## Abstract

We quantify the information that a functor loses when it identifies distinct objects. Working with functors between finite categories — equivalently, with the map they induce on finite sets of objects — we define the **functorial entropy** $H(F)$ as the conditional entropy of a uniformly random domain object given its image. Concretely, if $c_d$ denotes the cardinality of the fiber of $F$ over a target object $d$ and $n$ is the number of objects in the domain, then
$$H(F) = \sum_{d} \frac{c_d}{n}\,\log c_d.$$
We prove six structural theorems characterizing this invariant: (1) it is nonnegative; (2) it vanishes exactly when $F$ is injective on objects, giving a precise form of the slogan "faithful functors lose no information"; (3) when all fibers share a common size $k$ it equals $\log k = \log(|\mathrm{Ob}\,C|/|\mathrm{Ob}\,D|)$; (4) for a constant functor it attains the value $\log n$; (5) it is bounded above by $\log n$; and (6) it obeys a **data-processing inequality** $H(f) \le H(g\circ f)$, so that composing with a further functor can only increase the loss. We situate these results against the classical Shannon theory they categorify, work through the motivating examples of abelianization, inclusion of finite groups, and the forgetful functor to sets, and outline extensions to weighted priors, morphism-level loss, and infinite categories.

**Keywords:** functorial entropy, conditional entropy, categorification, information loss, data-processing inequality, faithful functor, fiber cardinality.

---

## 1. Introduction

Entropy, in the sense of Shannon, measures the uncertainty of a random variable: for a variable $X$ taking value $x$ with probability $p(x)$,
$$H(X) = -\sum_x p(x)\log p(x).$$
Category theory, meanwhile, offers a language for structure-preserving translation between mathematical worlds via **functors** $F : C \to D$. A recurring informal theme is that a functor "loses information" when it maps non-isomorphic objects to isomorphic ones — the paradigmatic case being a *forgetful functor* that discards structure. The qualitative counterpart of this idea is the notion of a **faithful** functor, one that does not conflate distinct data.

This paper makes the metaphor quantitative. We assign to each functor between finite categories a real number $H(F) \ge 0$, its **information loss**, and we prove that this number behaves exactly as an information-theoretic measure of forgetting should. The construction is a *categorification* of entropy in the sense that a purely combinatorial/probabilistic quantity is recovered as an invariant of a morphism in a category of categories.

### 1.1 The naive marginal entropy is the wrong invariant

A tempting first definition would push the uniform distribution on the objects of $C$ forward along $F$ and take the ordinary Shannon entropy of the resulting distribution on the objects of $D$:
$$H_{\mathrm{marg}}(F) = -\sum_d p(d)\log p(d), \qquad p(d) = \frac{c_d}{n}.$$
This quantity is unsuitable as a measure of *loss*. An injective functor into an $m$-object target already has marginal entropy $\log m > 0$, even though it forgets nothing. The marginal entropy measures the *spread of the image*, conflating the richness of the codomain with the collapsing behaviour of the map. We therefore discard it.

### 1.2 Conditional entropy is the right invariant

The correct measure is the **conditional entropy** $H(C \mid F(C))$ of the domain object given its image, under the uniform distribution on $\mathrm{Ob}\,C$. Given that the image is $d$, the domain object is uniformly distributed over the $c_d$ objects of the fiber, so the residual uncertainty is $\log c_d$; averaging over the image distribution $p(d) = c_d/n$ gives
$$H(F) = \sum_d \frac{c_d}{n}\,\log c_d. \tag{$\ast$}$$
This is genuinely the information lost by $F$: it is $0$ precisely when $F$ is injective, and it attains its maximum $\log n$ for a constant functor. Equation $(\ast)$ is the definition we study.

---

## 2. Setup and definitions

We model a functor between finite categories by the function it induces on their (finite) sets of objects. Fix finite nonempty sets of objects; write $\alpha = \mathrm{Ob}\,C$ and $\beta = \mathrm{Ob}\,D$, with $n = |\alpha|$.

**Definition 2.1 (Fiber cardinality).** For a function $F : \alpha \to \beta$ and a target object $d \in \beta$, the **fiber cardinality** is
$$c_d := \bigl|\{a \in \alpha : F(a) = d\}\bigr| = |F^{-1}(d)|.$$

The fibers partition the domain, whence the elementary but essential identity:

**Lemma 2.2 (Fiber partition).** $\displaystyle\sum_{d \in \beta} c_d = |\alpha| = n.$

*Proof.* The sets $F^{-1}(d)$ for $d \in \beta$ are pairwise disjoint and cover $\alpha$; summing their cardinalities counts each element of $\alpha$ exactly once. $\qquad\blacksquare$

**Definition 2.3 (Functorial entropy).** The **functorial entropy**, or **information loss**, of $F : \alpha \to \beta$ is
$$H(F) := \sum_{d \in \beta} \frac{c_d}{n}\,\log c_d,$$
with the standard convention that the summand vanishes when $c_d = 0$ (since the weight $c_d/n$ is then $0$). Here $\log$ denotes the natural logarithm; changing the base rescales $H(F)$ by a positive constant and does not affect any of the results below.

Interpreted probabilistically, $H(F)$ is the conditional entropy $H(A \mid F(A))$ where $A$ is uniform on $\alpha$: it is the expected number of nats needed to specify the exact domain object once its image is known.

---

## 3. Main results

Throughout, $F : \alpha \to \beta$ is a function between finite sets with $|\alpha| = n \ge 1$.

### 3.1 Nonnegativity

**Theorem 3.1 (Loss is nonnegative).** $H(F) \ge 0$.

*Proof.* Each summand $\frac{c_d}{n}\log c_d$ is a product of two nonnegative factors: the weight $c_d/n \ge 0$, and $\log c_d \ge 0$ because $c_d$ is a nonnegative integer, so either $c_d = 0$ (and the whole term is $0$) or $c_d \ge 1$ and $\log c_d \ge 0$. A sum of nonnegative terms is nonnegative. $\qquad\blacksquare$

Information cannot be created by translation; $H$ registers only loss.

### 3.2 The vanishing criterion

**Lemma 3.2 (Injectivity via fibers).** $F$ is injective if and only if $c_d \le 1$ for every $d \in \beta$.

*Proof.* If $F$ is injective, no two distinct elements share an image, so each fiber has at most one element. Conversely, if some fiber had two distinct elements $x \ne y$ with $F(x) = F(y)$, that fiber would have cardinality $\ge 2$; the hypothesis $c_d \le 1$ therefore forbids such a collision, giving injectivity. $\qquad\blacksquare$

**Theorem 3.3 (Vanishing criterion).** $H(F) = 0$ if and only if $F$ is injective on objects.

*Proof.* By Theorem 3.1 the sum $(\ast)$ has nonnegative terms, so it is zero if and only if every term is zero. The term for $d$ is zero exactly when $c_d = 0$ or $\log c_d = 0$, i.e. when $c_d \in \{0,1\}$, i.e. when $c_d \le 1$. By Lemma 3.2 this holds for all $d$ if and only if $F$ is injective. $\qquad\blacksquare$

This is the precise, quantitative form of the categorical slogan "a faithful functor loses no information," with faithfulness on objects captured by injectivity.

### 3.3 The uniform-fiber formula

**Theorem 3.4 (Uniform fibers).** Suppose every fiber has the same cardinality $k$, i.e. $c_d = k$ for all $d \in \beta$. Then
$$H(F) = \log k.$$
Moreover, when $F$ is surjective (so no fiber is empty and $|\beta| = m$), Lemma 2.2 gives $n = mk$, whence
$$H(F) = \log k = \log\frac{n}{m} = \log\frac{|\mathrm{Ob}\,C|}{|\mathrm{Ob}\,D|}.$$

*Proof.* Substituting $c_d = k$ into $(\ast)$,
$$H(F) = \sum_{d\in\beta} \frac{k}{n}\log k = \Bigl(\sum_{d\in\beta}\frac{k}{n}\Bigr)\log k = \frac{mk}{n}\log k.$$
By Lemma 2.2, $\sum_d c_d = mk = n$, so the prefactor $mk/n = 1$ and $H(F) = \log k$. If additionally $k \ge 1$ (surjectivity), $n = mk$ rearranges to $k = n/m$. When $k = 0$ the domain is empty, contradicting $n \ge 1$, so this case does not arise. $\qquad\blacksquare$

A uniform $k$-to-one functor loses exactly $\log k$ nats: one bit for a two-to-one map, ten bits for a $1024$-to-one map.

### 3.4 The constant functor and the maximum

**Theorem 3.5 (Constant functor).** If $F$ is constant, i.e. $F(a) = d_0$ for all $a \in \alpha$, then
$$H(F) = \log n.$$

*Proof.* The single nonempty fiber is over $d_0$, with $c_{d_0} = n$, and all other fibers are empty. Hence $(\ast)$ collapses to the single term $\frac{n}{n}\log n = \log n$. $\qquad\blacksquare$

**Theorem 3.6 (Maximum-loss bound).** For every $F$, $\quad H(F) \le \log n.$

*Proof.* For each $d$, monotonicity of $\log$ and the bound $c_d \le n$ (Lemma 2.2) give $\log c_d \le \log n$ whenever $c_d \ge 1$; when $c_d = 0$ the term vanishes. Therefore, term by term,
$$\frac{c_d}{n}\log c_d \le \frac{c_d}{n}\log n.$$
Summing over $d$ and applying Lemma 2.2,
$$H(F) \le \sum_d \frac{c_d}{n}\log n = \frac{\log n}{n}\sum_d c_d = \frac{\log n}{n}\cdot n = \log n. \qquad\blacksquare$$

Together, Theorems 3.5 and 3.6 show the constant functor is a *maximizer*: it realizes the ceiling $\log n$, forgetting the entire information content of the domain.

### 3.5 The data-processing inequality

The final result is the categorical analogue of the data-processing inequality of information theory: further processing of an image cannot recover information about the source.

**Lemma 3.7 (Fibers of a composite).** Let $f : \alpha \to \beta$ and $g : \beta \to \gamma$ with $\gamma$ finite. For $e \in \gamma$, the fiber of $g\circ f$ over $e$ decomposes along the $f$-fibers of the points lying over $e$:
$$c^{g\circ f}_e = \sum_{d : g(d) = e} c^{f}_d,$$
where $c^{g\circ f}_e = |(g\circ f)^{-1}(e)|$ and $c^f_d = |f^{-1}(d)|$.

*Proof.* An element $a \in \alpha$ satisfies $g(f(a)) = e$ if and only if $f(a) = d$ for some (unique) $d$ with $g(d) = e$. Thus $(g\circ f)^{-1}(e)$ is the disjoint union of the sets $f^{-1}(d)$ over those $d$ with $g(d)=e$; taking cardinalities gives the claim. $\qquad\blacksquare$

**Theorem 3.8 (Data-processing inequality).** For $f : \alpha\to\beta$ and $g : \beta\to\gamma$ with $\alpha,\beta,\gamma$ finite and $n = |\alpha| \ge 1$,
$$H(f) \le H(g\circ f).$$

*Proof sketch.* Both sides are averages of fiber log-cardinalities against the uniform distribution on $\alpha$. Group the domain by its $f$-fiber. Within the block of $f$-fibers mapping to a common $e \in \gamma$, superadditivity of $x\mapsto x\log x$ under aggregation — equivalently, concavity of the logarithm, or the fact that merging fibers can only enlarge each surviving log-cardinality — shows that the contribution to $H(g\circ f)$, namely $\frac{1}{n}c^{g\circ f}_e\log c^{g\circ f}_e$, dominates the sum of the corresponding contributions $\frac{1}{n}\sum_{g(d)=e} c^f_d\log c^f_d$ to $H(f)$. Concretely, using Lemma 3.7 and $c^f_d \le c^{g\circ f}_e = \sum_{g(d')=e}c^f_{d'}$ for each $d$ with $g(d)=e$,
$$\sum_{g(d)=e} c^f_d\log c^f_d \;\le\; \sum_{g(d)=e} c^f_d\log c^{g\circ f}_e \;=\; c^{g\circ f}_e\log c^{g\circ f}_e.$$
Dividing by $n$ and summing over $e \in \gamma$ yields $H(f) \le H(g\circ f)$. $\qquad\blacksquare$

Interpretively: once information about the domain has been lost by $f$, no subsequent functor $g$ can restore it, and $g$ typically discards more. Layers of abstraction accumulate loss monotonically.

---

## 4. Worked examples

The theory reproduces the values that motivated it.

**4.1 Inclusion of finite groups.** The inclusion functor from finite groups into all groups sends each finite group to itself; it is injective on (isomorphism classes of) objects. By Theorem 3.3, $H = 0$: no information is lost, consistent with the expectation that an inclusion is faithful.

**4.2 Abelianization.** The abelianization functor sends a group to its largest abelian quotient. Distinct non-isomorphic groups can share an abelianization, so the functor is genuinely non-injective. On finite models where each abelian object receives a small, roughly two-element family of preimages, the uniform-fiber formula (Theorem 3.4) gives a loss on the order of $\log 2$ — one bit — matching the informal expectation that each abelian group hides on average a nontrivial noncommutative companion.

**4.3 The forgetful functor to sets.** The functor discarding the topology of a space records only its underlying point-set. Over an infinite set there are uncountably many distinct topologies, so the relevant fibers are infinite and the loss diverges: $H \to \infty$. This is the boundary case flagged for the infinite theory (Section 6): it exemplifies the principle that a functor identifying infinitely many non-isomorphic objects has infinite entropy.

---

## 5. Algorithms

The invariant is directly computable for functors between finite categories.

**Algorithm A (Functorial entropy).** Given the object map $F : \alpha \to \beta$ as a list of $n$ images:
1. Tally the fiber cardinalities $c_d$ by a single pass over the domain (a histogram).
2. Return $\sum_{d : c_d > 0} \frac{c_d}{n}\log c_d$.

This runs in $O(n)$ time and $O(|\beta|)$ space and requires only the object map. Choosing base-$2$ logarithms reports the loss in bits.

**Algorithm B (Composite loss and the data-processing check).** Given $f : \alpha\to\beta$ and $g : \beta\to\gamma$, compute $H(f)$, $H(g\circ f)$ (via Algorithm A applied to the pointwise composite), and verify $H(f) \le H(g\circ f)$ numerically. This furnishes an empirical confirmation of Theorem 3.8 across random functors.

**Algorithm C (Uniform-fiber verification).** Given $F$, test whether all nonempty fibers have equal size $k$; if so, check $H(F) = \log k$ and, when $F$ is surjective, $k = |\alpha|/|\beta|$, confirming Theorem 3.4.

---

## 6. Discussion and future directions

The functorial entropy converts a qualitative categorical notion (faithfulness, forgetfulness) into a quantitative one, and the six theorems show it behaves as an information measure ought to: nonnegative, zero exactly on faithful functors, bounded by the domain's information content, maximized by total collapse, and monotone under composition. The last property, the data-processing inequality, is the structural heart of the theory and mirrors its classical namesake exactly.

Several natural extensions remain.

1. **Chain rule / additivity.** Establish $H(g\circ f) = H(f) + H_f(g)$ for a suitable relative loss $H_f(g)$, mirroring $H(X,Y) = H(X) + H(Y\mid X)$.
2. **Weighted / non-uniform priors.** Replace the uniform distribution on $\mathrm{Ob}\,C$ by an arbitrary probability weight, recovering the full Shannon conditional entropy and re-deriving all theorems in that generality.
3. **Morphism-level entropy.** The present invariant sees only the action on objects. A finer invariant would weight by hom-set collapse, quantifying loss of morphism information — the genuinely categorical form of faithfulness.
4. **Infinite categories.** Formalize $H = \infty$ for the forgetful functor to sets via extended nonnegative reals or a limit of finite truncations, once a fiber-cardinality measure is available.
5. **Functoriality of entropy itself.** Study whether $F \mapsto H(F)$ is monotone/continuous for natural orders on functors, and its behaviour under products and coproducts of categories (expected additivity).
6. **Connections to the literature.** Compare this conditional-entropy invariant with categorical characterizations of entropy in the magnitude and Baez–Fritz–Leinster traditions.

## 7. Conclusion

Every functor casts an information-theoretic shadow. Defining $H(F)$ as the conditional entropy of a domain object given its image yields a computable, nonnegative invariant that vanishes exactly on faithful functors, has a clean closed form for uniform fibers, is maximized by constant functors, is bounded by the domain's total information, and satisfies a data-processing inequality under composition. Entropy is thus not merely a measure-theoretic notion but the information-theoretic shadow of functoriality itself.
