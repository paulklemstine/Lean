# Non-Standard Arithmetic: Transfer, Internal Structure, and the Failure Spectrum of Classical Theorems in an Ultrapower of $\mathbb{N}$

**Author:** Aristotle
**Date:** 2026-08-16

## Abstract

We develop, from first principles and in complete detail, the theory of a concrete nonstandard model of arithmetic: the ultrapower ${}^\ast\mathbb{N} = \mathbb{N}^{\mathbb{N}}/\mathcal{U}$ of the natural numbers modulo a nonprincipal ultrafilter $\mathcal{U}$ on $\mathbb{N}$. Our aim is a systematic answer to the question *which classical theorems survive in a non-Archimedean model of arithmetic, and in what form*. We prove a transfer principle in two complementary guises — Łoś's theorem for arbitrary first-order structures, and explicit quantifier transfer for internal subsets of ${}^\ast\mathbb{N}$ — and use it to organize the classical corpus into two columns. In the *internal* column, the least number principle, the induction principle, the supremum principle for bounded sets, Euclidean division with uniqueness, greatest common divisors, the existence of prime factors, Euclid's theorem in the sharp form "there is a least hyperprime above any element", Fermat's little theorem with nonstandard base *and* exponent, and Wilson's theorem all survive verbatim. In the *external* column, each of the first three fails in the strongest possible sense: the unlimited elements have no least element, induction fails for the predicate "is standard", and the standard cut has no least upper bound. We determine the size of the model, $|{}^\ast\mathbb{N}| = \mathfrak{c}$, by an analytic construction of a continuum-sized strictly ordered family of unlimited elements (germs of the staircases $i \mapsto \lfloor i r\rfloor$), and show that the unlimited part alone has size $\mathfrak{c}$ while the standard part has size $\aleph_0$. We analyze the order type of the model through its *galaxies* (classes modulo standard translation), proving that they form a linear order whose least element is the standard galaxy and which is dense and unbounded above it. We prove countable ($\aleph_1$-) saturation by an explicit diagonal construction and derive overspill and a countable intersection property for internal sets. Finally we show that the primes are *not* uniformly distributed across galaxies: transferring the classical long-composite runs $i!+2,\dots,i!+i$, we produce an unlimited element whose entire galaxy is prime-free, and, more strongly, an interval of galaxies containing no hyperprime whatsoever — so the prime-carrying galaxies are not dense in the galaxy order. As applications in the reverse direction, we give nonstandard proofs of the infinite pigeonhole principle and of the Bolzano–Weierstrass theorem, and we prove Robinson's characterizations of convergence and divergence for real sequences.

**Keywords:** nonstandard arithmetic, ultrapower, ultrafilter, transfer principle, internal sets, overspill, saturation, galaxies, hyperprimes, prime gaps, Robinson's criterion.

---

## 1. Introduction

Ordinary arithmetic is not categorical. By the Löwenheim–Skolem and compactness theorems there are models of the first-order theory of $\mathbb{N}$ containing elements larger than every numeral. Such models are usually invoked abstractly, as an existence statement. This paper instead studies one *concrete* model in detail, an ultrapower of $\mathbb{N}$, and asks a systematic question: taking the classical theorems of elementary arithmetic and analysis one at a time, which survive in the nonstandard model, in what form, and why do the others fail?

The answer has an unexpectedly clean shape. Everything expressible in the first-order language of arithmetic survives, by transfer, and this is not the interesting part. The interesting part is the second-order corpus — statements quantifying over *sets* of numbers — where the model bifurcates. Every subset of ${}^\ast\mathbb{N}$ is either *internal* (assembled coordinatewise from ordinary sets) or *external*. Our central empirical finding, established across a dozen theorems, is that:

> **classical set-theoretic principles of arithmetic survive for internal sets and fail for external ones**, and the failures are not marginal — they are as violent as the statement permits.

We also find, in the number-theoretic direction, one genuine surprise: unboundedness of primes transfers, but *equidistribution across scales does not*. There are entire intervals of galaxies of the model in which no prime lives.

### 1.1 Organization

Section 2 constructs the model. Section 3 proves the transfer principles. Section 4 develops internal sets, overspill and underspill, and establishes the externality of the standard cut. Section 5 gives the survival/failure dichotomy for the three classical set principles. Section 6 computes cardinalities. Section 7 analyzes the galaxy order. Section 8 proves countable saturation. Section 9 develops number theory in the model, including the prime-free galaxy theorem. Section 10 gives applications back to standard mathematics. Sections 11 and 12 discuss algorithms, open problems and future directions.

---

## 2. The Model

### 2.1 Largeness

**Definition 2.1 (Ultrafilter).** A *filter* on $\mathbb{N}$ is a nonempty family $\mathcal{F}$ of subsets of $\mathbb{N}$, closed under supersets and finite intersections, with $\varnothing \notin \mathcal{F}$. An *ultrafilter* is a filter $\mathcal{U}$ such that for every $S \subseteq \mathbb{N}$, either $S \in \mathcal{U}$ or $\mathbb{N}\setminus S \in \mathcal{U}$. It is *nonprincipal* when it contains no finite set; equivalently, it contains every cofinite set.

Throughout, $\mathcal{U}$ denotes a fixed nonprincipal ultrafilter on $\mathbb{N}$ (the *hyperfilter*), whose existence follows from Zorn's lemma applied to the filter of cofinite sets. We call $S \subseteq \mathbb{N}$ *large* when $S \in \mathcal{U}$, and we say a property $P(i)$ holds *for almost all $i$*, written $\forall^{\mathcal{U}} i,\ P(i)$, when $\{i : P(i)\}$ is large. The three facts used constantly are:

1. (finite intersection) if $P$ and $Q$ hold for almost all $i$, so does $P \wedge Q$;
2. (dichotomy) $\neg\,\forall^{\mathcal{U}} i,\ P(i)$ if and only if $\forall^{\mathcal{U}} i,\ \neg P(i)$;
3. (cofiniteness) for every $m$, $\forall^{\mathcal{U}} i,\ i \ge m$.

Property 2 is the defining feature of an ultrafilter and is what makes the model *complete* in the logical sense: no statement is left undecided.

### 2.2 Hypernaturals

**Definition 2.2.** For $f,g : \mathbb{N} \to \mathbb{N}$ write $f \sim g$ when $\forall^{\mathcal{U}} i,\ f(i) = g(i)$. This is an equivalence relation; the quotient
$$ {}^\ast\mathbb{N} \;=\; \mathbb{N}^{\mathbb{N}}/\!\sim $$
is the set of *hypernaturals*, and $[f]$ denotes the class (the *germ*) of $f$.

**Definition 2.3 (Structure).** Define $[f]+[g] = [i \mapsto f(i)+g(i)]$, $[f]\cdot[g]=[i\mapsto f(i)g(i)]$, and $[f] < [g] \iff \forall^{\mathcal{U}} i,\ f(i)<g(i)$; likewise $[f] \le [g]$, and for relations and functions of any arity, by lifting pointwise. All of these are well defined: replacing a representative on a large set changes nothing, by closure under finite intersections.

**Proposition 2.4.** $({}^\ast\mathbb{N}, +, \cdot, <)$ is a linearly ordered commutative semiring, and the map $n \mapsto n^\ast := [i \mapsto n]$ is an injective order- and operation-preserving embedding of $\mathbb{N}$.

*Proof sketch.* Each algebraic identity holds pointwise, hence on the large set $\mathbb{N}$. Linearity of the order uses the dichotomy property: the three sets $\{i : f(i)<g(i)\}$, $\{i : f(i)=g(i)\}$, $\{i:f(i)>g(i)\}$ partition $\mathbb{N}$ and a filter cannot contain two disjoint sets, so exactly one is large. Injectivity of $n \mapsto n^\ast$ holds because a nonprincipal ultrafilter contains no finite set, in particular not $\varnothing$. $\square$

**Definition 2.5.** $H \in {}^\ast\mathbb{N}$ is *standard* if $H = n^\ast$ for some $n \in \mathbb{N}$, and *unlimited* if $n^\ast < H$ for all $n \in \mathbb{N}$. Write $\omega := [i \mapsto i]$.

**Proposition 2.6.** $\omega$ is unlimited; unlimited elements are not standard; and $[f]$ is unlimited if and only if for every $n$, $f(i) > n$ for almost all $i$.

*Proof.* $\{i : i > n\}$ is cofinite, hence large, giving $n^\ast < \omega$. A standard $n^\ast$ is not unlimited since $n^\ast \not< n^\ast$. The last claim is the definition of $<$ unwound. $\square$

Thus ${}^\ast\mathbb{N}$ is *non-Archimedean*: it properly extends $\mathbb{N}$ and contains elements above the whole of it.

---

## 3. Transfer

### 3.1 Łoś's theorem

**Theorem 3.1 (Transfer Principle).** Let $L$ be a first-order language, $M$ a nonempty $L$-structure, $\mathcal{U}$ an ultrafilter on an index set $I$, and ${}^\ast M = M^I/\mathcal{U}$ the ultrapower. Then for every $L$-sentence $\varphi$,
$$ {}^\ast M \models \varphi \iff M \models \varphi. $$
Consequently ${}^\ast M \equiv M$: the ultrapower and the base structure are elementarily equivalent.

*Proof sketch.* One proves the stronger statement, for formulas $\varphi(x_1,\dots,x_k)$ with free variables and germs $[f_1],\dots,[f_k]$:
$$ {}^\ast M \models \varphi([f_1],\dots,[f_k]) \iff \forall^{\mathcal{U}} i,\ M \models \varphi(f_1(i),\dots,f_k(i)), $$
by induction on $\varphi$. Atomic formulas hold by definition of the lifted relations. Conjunction uses closure under finite intersections; negation uses the ultrafilter dichotomy — this is the only place where "ultra" (rather than merely "filter") is needed, and it is what makes the equivalence, rather than merely one implication, true. For the existential step, the direction "$\Leftarrow$" requires choosing, at each coordinate $i$ where a witness exists, a witness $w(i)$; the germ $[w]$ then works. The direction "$\Rightarrow$" is immediate. Applying the statement to a sentence (no free variables) makes the right-hand side a constant condition, true either on $\varnothing$ or on all of $I$, and the theorem follows. $\square$

**Corollary 3.2.** ${}^\ast\mathbb{N}$ satisfies every first-order theorem of arithmetic: the ordering is discrete with least element $0$; every element has an immediate successor; every element $>1$ has a prime divisor; for every $x$ there is a prime $>x$; Euclidean division exists; and so forth.

The corollary is what makes the phrase "alien but indistinguishable" precise, and it also tells us where to look for pathology: not in first-order statements, but in statements quantifying over subsets.

### 3.2 Quantifier transfer for internal sets

**Definition 3.3 (Internal set).** An *internal subset* of ${}^\ast\mathbb{N}$ is a germ $[A]$ of a sequence $A : \mathbb{N} \to \mathcal{P}(\mathbb{N})$ of ordinary subsets of $\mathbb{N}$; membership is the lifted relation,
$$ [f] \in^\ast [A] \quad :\iff\quad \forall^{\mathcal{U}} i,\ f(i) \in A_i. $$
A subset of ${}^\ast\mathbb{N}$ is *external* if it is not of this form. For $S \subseteq \mathbb{N}$, the *star-extension* ${}^\ast S$ is the internal set given by the constant sequence $A_i = S$.

Membership is well defined on germs on both sides, again by the finite-intersection property. Because the ultrafilter decides complements, internal sets are closed under complement in the strongest sense:

**Lemma 3.4.** $[f] \in^\ast [A^c]$ if and only if $[f] \notin^\ast [A]$, where $A^c_i = \mathbb{N}\setminus A_i$.

**Theorem 3.5 (Universal transfer).** For a sequence of sets $A$,
$$ \big(\forall H \in {}^\ast\mathbb{N},\ H \in^\ast [A]\big) \iff \forall^{\mathcal{U}} i,\ A_i = \mathbb{N}. $$

*Proof sketch.* ($\Leftarrow$) is immediate. For ($\Rightarrow$), suppose the right side fails; by dichotomy, for almost all $i$ there exists $x \notin A_i$. Choose such an $x = g(i)$ for each such $i$ (arbitrarily elsewhere). Then $g(i) \notin A_i$ for almost all $i$, so $[g] \notin^\ast [A]$, contradicting the left side. $\square$

**Theorem 3.6 (Existential transfer).** $\big(\exists H,\ H \in^\ast [A]\big) \iff \forall^{\mathcal{U}} i,\ A_i \ne \varnothing$.

*Proof sketch.* ($\Rightarrow$) A witness germ supplies a pointwise element almost everywhere. ($\Leftarrow$) Choose $g(i) \in A_i$ where possible. $\square$

These two statements are the quantifier steps of Łoś's theorem in the special case at hand, isolated because they are the workhorses of everything below. As a first application, they yield the internal induction principle directly:

**Proposition 3.7 (Internal induction from transfer).** If for almost all $i$ we have $0 \in A_i$ and $A_i$ is closed under successor, then $H \in^\ast [A]$ for every hypernatural $H$.

*Proof.* By ordinary induction, such an $A_i$ equals $\mathbb{N}$; apply Theorem 3.5. $\square$

---

## 4. Internal sets, spilling, and the externality of the standard cut

**Theorem 4.1 (Overspill).** Let $[A]$ be internal and suppose $n^\ast \in^\ast [A]$ for every $n \in \mathbb{N}$. Then there is an unlimited $H$ with $H \in^\ast [A]$.

*Proof.* The hypothesis says: for each $n$, $n \in A_i$ for almost all $i$. Define
$$ f(i) := \max\{k \le i : k \in A_i\} \quad(\text{and } 0 \text{ if no such } k). $$
Fix $n$. For almost all $i$ we have both $n+1 \in A_i$ and $i \ge n+1$; for such $i$, $f(i) \ge n+1 > n$. Hence $[f]$ is unlimited. Moreover, for almost all $i$ we have $1 \in A_i$ and $i \ge 1$, and then $f(i) \in A_i$; hence $[f] \in^\ast[A]$. $\square$

Note the essential role of the finite-level bound $k \le i$: it is what makes $f$ well defined coordinatewise, and it is the reason the argument is called *diagonal*.

**Theorem 4.2 (Underspill).** If an internal set contains every unlimited hypernatural, it contains a standard one.

*Proof.* Otherwise $n^\ast \in^\ast [A^c]$ for all $n$ by Lemma 3.4, so by overspill $[A^c]$ contains an unlimited $H$; but then $H \notin^\ast [A]$, contradicting the hypothesis. $\square$

**Theorem 4.3 (The standard cut is external).** There is no internal set whose members are exactly the standard hypernaturals. Likewise there is no internal set whose members are exactly the unlimited hypernaturals.

*Proof.* Such an internal set would contain all standard elements, hence by overspill an unlimited one, which is not standard — contradiction. For the second statement see Corollary 5.3. $\square$

Theorem 4.3 is the structural heart of the subject. From inside the model — that is, using only internal sets — the boundary between finite and infinite is invisible. This is precisely why transfer can coexist with non-Archimedean behavior.

---

## 5. The survival/failure dichotomy

We now run three classical principles through the internal/external filter.

### 5.1 The least number principle

**Theorem 5.1 (Internal well-ordering).** Every nonempty internal set has a least element: if $[A]$ is internal and some $H \in^\ast [A]$, then there is $H_0 \in^\ast [A]$ with $H_0 \le K$ for all $K \in^\ast [A]$.

*Proof.* Let $[g] \in^\ast [A]$, so $g(i) \in A_i$ for almost all $i$; in particular $A_i \ne \varnothing$ there. Put $s(i) := \min A_i$ (any value where $A_i=\varnothing$). Then $s(i) \in A_i$ almost everywhere, so $[s] \in^\ast [A]$; and if $[k] \in^\ast [A]$ then $k(i)\in A_i$ almost everywhere, whence $s(i)\le k(i)$ almost everywhere, i.e. $[s]\le[k]$. $\square$

**Theorem 5.2 (External failure).** For every unlimited $H$ there is an unlimited $K$ with $K < H$. Hence the set of unlimited hypernaturals has no least element.

*Proof.* Write $H=[f]$ with, for each $n$, $f(i)>n$ almost everywhere. Take $K = [i \mapsto f(i)-1]$ (truncated subtraction). For each $n$: almost everywhere $f(i) > n+1$, so $f(i)-1 > n$; and almost everywhere $f(i)>0$, so $f(i)-1 < f(i)$. $\square$

**Corollary 5.3.** The set of unlimited hypernaturals is external.

*Proof.* If it were internal, it would be nonempty ($\omega$ belongs) and hence, by Theorem 5.1, would have a least element, contradicting Theorem 5.2. $\square$

### 5.2 Induction

**Theorem 5.4 (Internal induction).** If $[A]$ is internal, $0^\ast \in^\ast [A]$, and $H \in^\ast [A] \Rightarrow H+1 \in^\ast[A]$ for every hypernatural $H$, then $H \in^\ast [A]$ for every $H$.

*Proof.* Suppose $[h] \notin^\ast [A]$. By dichotomy, $h(i)\notin A_i$ almost everywhere, while $0 \in A_i$ almost everywhere. On the intersection define
$$ c(i) := \max\{k \le h(i) : k \in A_i\}, $$
which exists since $0$ qualifies. Then $c(i)\in A_i$; and $c(i) \ne h(i)$ since $h(i)\notin A_i$, so $c(i)+1 \le h(i)$ and by maximality $c(i)+1\notin A_i$. Thus $[c] \in^\ast [A]$ while $[c]+1 \notin^\ast [A]$, contradicting closure under successor. $\square$

**Theorem 5.5 (External failure).** The predicate "is standard" satisfies the induction hypotheses — $0^\ast$ is standard, and $H$ standard implies $H+1$ standard — yet fails for $\omega$.

The contrast is instructive: internal induction is a *theorem*, not an axiom, in this model; the diagonal construction of $c$ is what replaces the well-ordering argument. Its failure externally is exactly the assertion that the model is nonstandard.

### 5.3 Completeness

In $\mathbb{N}$ every nonempty set bounded above has a greatest element, which is then its least upper bound.

**Lemma 5.6 (Bound transfer).** If every $H \in^\ast [A]$ satisfies $H \le [b]$, then $x \le b(i)$ for all $x \in A_i$, for almost all $i$.

*Proof.* Suppose not; by dichotomy, for almost all $i$ the set $B_i := \{x \in A_i : x > b(i)\}$ is nonempty. By existential transfer (Theorem 3.6) there is $[g] \in^\ast [B]$. Then $[g] \in^\ast [A]$, so $[g] \le [b]$, i.e. $g(i)\le b(i)$ almost everywhere; but $g(i) > b(i)$ almost everywhere — contradiction. $\square$

**Theorem 5.7 (Internal completeness).** A nonempty internal set that is bounded above has a greatest element $S$, and $S$ is its least upper bound.

*Proof.* Let $[b]$ be an upper bound and $[g] \in^\ast[A]$. By Lemma 5.6, almost everywhere every element of $A_i$ is $\le b(i)$. Set $s(i) := \max\{x \le b(i) : x \in A_i\}$, well defined almost everywhere since $g(i)\in A_i$ and $g(i)\le b(i)$ there. Then $[s]\in^\ast[A]$ and $[s]$ dominates every member; being itself a member, it is below every upper bound. $\square$

**Theorem 5.8 (External failure).** The standard cut is bounded above by $\omega$, yet has no least upper bound.

*Proof.* Any upper bound $S$ satisfies $n^\ast < (n+1)^\ast \le S$ for all $n$, so $S$ is unlimited. By Theorem 5.2 there is unlimited $K<S$, and $K$ is also an upper bound for the standard cut. So no upper bound is least. $\square$

**Summary of Section 5.**

| Classical principle | Internal form | External form |
|---|---|---|
| Least number principle | holds (Thm 5.1) | fails maximally (Thm 5.2) |
| Induction | holds (Thm 5.4) | fails for "is standard" (Thm 5.5) |
| Bounded sets have suprema | holds, with maxima (Thm 5.7) | fails: no supremum exists (Thm 5.8) |

---

## 6. The size of the model

**Theorem 6.1.** $|{}^\ast\mathbb{N}| = \mathfrak{c}$. Moreover $|\{H : H \text{ unlimited}\}| = \mathfrak{c}$ and $|\{H : H \text{ standard}\}| = \aleph_0$. In particular ${}^\ast\mathbb{N}$ is uncountable and there is no bijection ${}^\ast\mathbb{N} \to \mathbb{N}$.

The upper bound is immediate: ${}^\ast\mathbb{N}$ is a quotient of $\mathbb{N}^{\mathbb{N}}$, and $|\mathbb{N}^{\mathbb{N}}| = \aleph_0^{\aleph_0} = \mathfrak{c}$. The lower bound is the substantial half, and we give it by an analytic family.

**Definition 6.2 (Staircase germs).** For a real $r>0$ put
$$ S_r := \big[\, i \mapsto \lfloor i\, r\rfloor \,\big] \in {}^\ast\mathbb{N}. $$

**Lemma 6.3.** For $r>0$, $S_r$ is unlimited.

*Proof.* Fix $c \in \mathbb{N}$ and pick $N > (c+1)/r$, so $c+1 < Nr$. For almost all $i$ (indeed all $i \ge N$) we have $Nr \le ir$, hence $c+1 \le ir$ and thus $c + 1 \le \lfloor ir \rfloor$, i.e. $c < \lfloor ir\rfloor$. $\square$

**Lemma 6.4 (Slope separation).** If $0<r<s$ then $S_r < S_s$.

*Proof.* Pick $N > 1/(s-r)$, so $1 < N(s-r)$. For $i \ge N$ we get $1 < i(s-r)$, i.e. $ir + 1 < is$. Since $\lfloor ir\rfloor \le ir$, we obtain $\lfloor ir\rfloor + 1 \le is$, hence $\lfloor ir\rfloor + 1 \le \lfloor is\rfloor$, i.e. $\lfloor ir\rfloor < \lfloor is\rfloor$. As $\{i : i \ge N\}$ is large, $S_r<S_s$. $\square$

**Corollary 6.5.** $r \mapsto S_r$ is injective and strictly increasing on $(0,\infty)$; hence $\mathfrak{c} = |(0,\infty)| \le |\{H : H\ \text{unlimited}\}| \le |{}^\ast\mathbb{N}| \le \mathfrak{c}$, proving Theorem 6.1. The standard part is the injective image of $\mathbb{N}$, hence countably infinite. $\square$

**Remark 6.6.** Theorem 6.1 combined with Theorem 3.1 is the sharpest possible illustration of the weakness of first-order expressibility: ${}^\ast\mathbb{N}$ and $\mathbb{N}$ satisfy exactly the same sentences, yet they are not even of the same cardinality. Notice also that the strictly increasing embedding $(0,\infty)\hookrightarrow{}^\ast\mathbb{N}$ shows the order type of the model contains a copy of the real line's order.

---

## 7. Galaxies: the order type of the model

**Definition 7.1.** For $H,K \in {}^\ast\mathbb{N}$ define
$$ H \approx K \quad:\iff\quad \exists n \in \mathbb{N},\ K \le H + n^\ast \ \wedge\ H \le K + n^\ast \qquad (\textit{same galaxy}), $$
$$ H \prec K \quad:\iff\quad \forall n \in \mathbb{N},\ H + n^\ast < K \qquad (\textit{$K$ is far above $H$}). $$

**Theorem 7.2.** $\approx$ is an equivalence relation and a congruence for addition: $H\approx H'$ and $K \approx K'$ imply $H+K \approx H'+K'$.

*Proof sketch.* Reflexivity with $n=0$; symmetry by swapping; transitivity by adding the two constants ($a$ then $b$ gives $a+b$). For the congruence, if $g \le f + a$ and $g'\le f'+b$ pointwise almost everywhere then $g+g' \le (f+f') + (a+b)$, and symmetrically. $\square$

**Theorem 7.3.** (i) $H \prec K$ implies $H<K$. (ii) $\prec$ is irreflexive and transitive. (iii) For $H<K$: $H \prec K$ if and only if $H \not\approx K$. (iv) $\prec$ is a congruence: if $H\approx H'$, $K \approx K'$ and $H \prec K$ then $H' \prec K'$. Hence $\prec$ induces a strict linear order on the set of galaxies.

*Proof sketch.* (i) take $n=0$. (ii) transitivity from $H+n^\ast<K<M$. (iii) If $H \prec K$ then no $n$ can satisfy $K \le H + n^\ast$. Conversely if $H\not\prec K$ then $K \le H+n^\ast$ for some $n$, and $H \le K \le K+n^\ast$, so $H\approx K$. (iv) Pointwise: if $f(i)+n+a+b < g(i)$, $f'(i) \le f(i)+a$, $g(i)\le g'(i)+b$ almost everywhere, then $f'(i)+n<g'(i)$ almost everywhere. $\square$

**Theorem 7.4 (Least galaxy).** $0^\ast \prec H$ if and only if $H$ is unlimited; and every unlimited $H$ satisfies $m^\ast \prec H$ for every standard $m$. Thus the galaxy of $0$ is exactly $\mathbb{N}$ (viewed inside the model) and is the least galaxy.

**Theorem 7.5 (Density).** If $H \prec K$ then there is $M$ with $H \prec M \prec K$.

*Proof.* Write $H=[f]$, $K=[g]$; the hypothesis gives, for each $n$, $f(i)+n<g(i)$ almost everywhere. Put $M := [\,i \mapsto f(i) + \lfloor (g(i)-f(i))/2\rfloor\,]$. Given $n$, apply the hypothesis with $2n+2$: almost everywhere $g(i)-f(i) > 2n+2$, whence the midpoint exceeds $f(i)+n$ and is exceeded by $g(i)-n$. $\square$

**Theorem 7.6 (No greatest galaxy).** $H \prec H + \omega$ for every $H$.

*Proof.* Given $n$, for almost all $i$ (all $i\ge n+1$) we have $f(i)+n < f(i)+i$. $\square$

**Theorem 7.7 (No least nonstandard galaxy).** If $H$ is unlimited there is unlimited $K$ with $K \prec H$.

*Proof.* $K = [\,i \mapsto \lfloor f(i)/2\rfloor\,]$: given $n$, almost everywhere $f(i) > 2n+2$, so $\lfloor f(i)/2\rfloor > n$ and $\lfloor f(i)/2\rfloor + n < f(i)$. $\square$

**Corollary 7.8 (Descending chain of scales).** There is a sequence $c_0 \succ c_1 \succ c_2 \succ \cdots$ of unlimited hypernaturals, each far below the previous; e.g. $c_0=\omega$ and $c_{n+1}=\lfloor c_n/2 \rfloor$ (interpreted coordinatewise).

**Summary.** The galaxy order is a linear order with least element (the standard galaxy), and above that element it is dense with no endpoints. This is the classical order type "$\mathbb{N}$ followed by a dense unbounded order": failure of the Archimedean property is not a single defect but a densely stratified continuum of scales.

---

## 8. Countable saturation

**Definition 8.1.** A family of internal sets has the *finite intersection property* (FIP) if every finite subfamily has a common element.

**Theorem 8.2 ($\aleph_1$-saturation).** Let $\{[A^{(n)}]\}_{n\in\mathbb{N}}$ be a countable family of internal subsets of ${}^\ast\mathbb{N}$ with the FIP. Then there is a single $H$ with $H \in^\ast [A^{(n)}]$ for every $n$.

*Proof.* Write $A^{(n)}_i \subseteq \mathbb{N}$ for the coordinates, and let
$$ \Pi_n(i) := \bigcap_{k \le n} A^{(k)}_i, $$
so $\Pi_n(i) \subseteq \Pi_m(i)$ for $m\le n$.

*Step 1.* For each $n$, $\Pi_n(i) \ne \varnothing$ for almost all $i$. Indeed the FIP gives $H = [h]$ lying in $[A^{(k)}]$ for all $k \le n$; each of these is a largeness statement about $\{i : h(i) \in A^{(k)}_i\}$, and a *finite* intersection of large sets is large, so $h(i) \in \Pi_n(i)$ almost everywhere.

*Step 2 (diagonal).* Define the *depth*
$$ d(i) := \max\{\, n \le i \;:\; \Pi_n(i) \ne \varnothing \,\}, $$
and let $f(i)$ be an element of $\Pi_{d(i)}(i)$ when nonempty ($0$ otherwise).

*Step 3.* Fix $n$. For almost all $i$ we have simultaneously $\Pi_0(i)\ne\varnothing$, $\Pi_n(i)\ne\varnothing$ and $i \ge n$; for such $i$, the depth satisfies $d(i) \ge n$, the set $\Pi_{d(i)}(i)$ is nonempty, and $f(i) \in \Pi_{d(i)}(i) \subseteq \Pi_n(i)\subseteq A^{(n)}_i$. Hence $[f] \in^\ast[A^{(n)}]$. $\square$

The mechanism deserves emphasis. Each coordinate $i$ is a *finite* world, in which only finitely many of the conditions can be met; the bound $n \le i$ lets the number of satisfied conditions grow with the coordinate, and the ultrafilter converts "grows without bound" into "all of them, at once, in the limit object."

**Corollary 8.3 (Overspill again).** If an internal $[A]$ contains all standard elements, apply saturation to the conditions $B^{(n)} := \{x \in A_i : x > n\}$: each finite subfamily is satisfied by $(n+1)^\ast$. The resulting common element is unlimited and lies in $[A]$.

**Corollary 8.4 (Countable intersection property).** If $[A^{(0)}] \supseteq [A^{(1)}] \supseteq \cdots$ is a decreasing chain of nonempty internal sets, then $\bigcap_n [A^{(n)}] \ne \varnothing$.

This last statement is the sharpest contrast with $\mathbb{N}$ itself, where the nonempty decreasing sets $\{k : k \ge n\}$ have empty intersection. Saturation is precisely the compactness that the standard model lacks, and it is the engine behind most nonstandard arguments.

---

## 9. Number theory in the model

### 9.1 Internal operations and hyperprimes

Truncated subtraction, exponentiation *with hypernatural exponent*, and the factorial are defined coordinatewise:
$$ A \ominus B := [\,i \mapsto a(i)-b(i)\,],\quad A^{B} := [\,i \mapsto a(i)^{b(i)}\,],\quad A! := [\,i\mapsto a(i)!\,]. $$
Divisibility is the lifted relation: $A \mid B$ iff $a(i) \mid b(i)$ almost everywhere. Finally, $P$ is a *hyperprime* iff $p(i)$ is prime for almost all $i$.

### 9.2 What survives

**Theorem 9.1 (Unlimited primes exist).** The germ $[\,i \mapsto p_i\,]$ of the sequence of ordinary primes is an unlimited hyperprime.

*Proof.* Every coordinate is prime. For unlimitedness use $p_i \ge i$ together with strict monotonicity of $i \mapsto p_i$ and the largeness of $\{i \ge n+1\}$. $\square$

**Theorem 9.2 (Sharp Euclid).** For every $H$ there exists a hyperprime $P > H$ that is *least* among hyperprimes exceeding $H$.

*Proof.* Let $H=[f]$ and consider the internal set $A_i := \{p : p \text{ prime},\ p > f(i)\}$. Each $A_i$ is nonempty by Euclid, so the internal set is nonempty; a germ $[g]$ lies in it exactly when $[g]$ is a hyperprime exceeding $H$. Apply the internal least number principle (Theorem 5.1). $\square$

This is worth pausing on: the *existence of a least* prime above a nonstandard number is available even though the ambient order is not a well-order. Internal well-ordering is exactly the right amount of well-ordering.

**Theorem 9.3 (Fermat's little theorem, doubly nonstandard).** For every hypernatural $A$ and hyperprime $P$: $P \mid A^{P} \ominus A$.

*Proof.* Pointwise, for prime $p$ and any $a$, $p \mid a^p - a$ (Fermat), noting $a \le a^p$ so truncated subtraction agrees with the integer one. Transfer coordinatewise. $\square$

**Theorem 9.4 (Wilson's theorem for hyperprimes).** For every hyperprime $P$: $P \mid (P \ominus 1)! + 1$.

*Proof.* Pointwise Wilson: $p \mid (p-1)!+1$ for prime $p$. $\square$

**Theorem 9.5 (Parity).** No unlimited hyperprime is divisible by $2^\ast$.

*Proof.* If $2 \mid p(i)$ with $p(i)$ prime then $p(i)=2$, contradicting $p(i)>2$ almost everywhere. $\square$

**Theorem 9.6 (Euclidean division with uniqueness).** For $B \ne 0$ and any $A$ there exist $Q,R$ with $A = BQ+R$ and $R<B$, and the pair $(Q,R)$ is unique.

*Proof.* $B\ne 0$ means $b(i)\ne 0$ almost everywhere. Take $Q := [\,i\mapsto a(i)\,\mathrm{div}\,b(i)\,]$ and $R := [\,i\mapsto a(i) \bmod b(i)\,]$; the identity and the inequality hold coordinatewise. For uniqueness, suppose $A = BQ'+R'$ with $R'<B$; then almost everywhere $a(i) = b(i)q'(i)+r'(i)$ with $r'(i)<b(i)$, and ordinary uniqueness of division gives $q'(i)=a(i)\,\mathrm{div}\,b(i)$ and $r'(i)=a(i)\bmod b(i)$ there. $\square$

**Theorem 9.7 (Greatest common divisors).** $\gcd(A,B) := [\,i\mapsto \gcd(a(i),b(i))\,]$ divides $A$ and $B$, and any common divisor of $A$ and $B$ divides it.

**Theorem 9.8 (Prime factors exist).** Every $A > 1^\ast$ has a hyperprime divisor, namely $[\,i \mapsto \mathrm{minFac}(a(i))\,]$.

Together, Theorems 9.6–9.8 say that the *algorithmic* layer of arithmetic — the layer usually proved by strong induction or minimal-counterexample arguments — survives intact, despite the absence of well-ordering in the external sense.

### 9.3 What fails: primes are not distributed across all scales

Since primes are unbounded (Theorem 9.1) and the model is stratified into galaxies (Section 7), one is tempted to conjecture that primes appear at every scale: *every galaxy contains a hyperprime*. This is false, and the refutation is a transfer of the oldest construction of long prime gaps.

**Lemma 9.9 (Long composite runs).** For $2 \le j \le i$, the number $i!+j$ is composite, since $j \mid i!$ and $j \mid j$, hence $j \mid i!+j$ with $1 < j < i!+j$.

**Definition 9.10.** Let $C := [\,i \mapsto i! + \lfloor i/2\rfloor\,]$, the *composite centre*.

**Theorem 9.11 (Prime-free galaxy).** $C$ is unlimited, and no hyperprime lies in the galaxy of $C$: if $P$ is a hyperprime then $P \not\approx C$.

*Proof.* Unlimitedness: $i! \ge i$ for all $i$, and $\{i \ge n+1\}$ is large. Suppose $P = [p]$ is a hyperprime with $P \approx C$, witnessed by $m$: almost everywhere
$$ i! + \lfloor i/2\rfloor \le p(i) + m \quad\text{and}\quad p(i) \le i! + \lfloor i/2\rfloor + m. $$
Restrict further to the large set $\{i \ge 2m+8\}$. Writing $j(i) := p(i) - i!$ (legitimate since $p(i) \ge i!+\lfloor i/2\rfloor - m > i!$ there), the two inequalities give $2 \le j(i) \le i$. By Lemma 9.9, $p(i) = i! + j(i)$ is composite, contradicting primality on a large set. $\square$

**Theorem 9.12 (An interval of prime-free galaxies).** Let $H := [\,i\mapsto i!\,]$ and $K := [\,i\mapsto i!+i\,]$. Then $H \prec K$, and there is no hyperprime $P$ with $H \prec P \prec K$. Consequently the prime-carrying galaxies are **not dense** in the galaxy order.

*Proof.* $H \prec K$: given $n$, for $i \ge n+1$ we have $i!+n < i!+i$. Now suppose $P=[p]$ is a hyperprime with $H \prec P \prec K$. Applying the two conditions with $n=3$ and restricting to $\{i \ge 8\}$ gives, almost everywhere, $i!+3 < p(i)$ and $p(i)+3 < i!+i$, hence $2 \le p(i)-i! \le i$; Lemma 9.9 again contradicts primality. $\square$

**Theorem 9.13 (Some galaxies do carry primes).** The galaxy of $[\,i\mapsto p_i\,]$ contains a hyperprime — itself.

Thus primality is a *galaxy-dependent* property, splitting the scales of the model into a prime-carrying part and a provably prime-free part. This is the transferred content of "arbitrarily long prime gaps", but restated as geometry of the number line rather than asymptotics.

---

## 10. Applications: standard theorems with nonstandard proofs

### 10.1 Robinson's criteria

Every real sequence $a : \mathbb{N}\to\mathbb{R}$ extends to hypernatural indices. Working with hyperreals ${}^\ast\mathbb{R} = \mathbb{R}^{\mathbb{N}}/\mathcal{U}$ along the same ultrafilter, define
$$ a^\ast([f]) := [\,i \mapsto a_{f(i)}\,] \in {}^\ast\mathbb{R}. $$
This agrees with $a$ on standard indices. Recall that a hyperreal $X$ has *standard part* $L\in\mathbb{R}$ (written $X \approx L$) when $|X - L| < \varepsilon$ for every real $\varepsilon>0$, and that $X$ is *positive infinite* when $X>r$ for every real $r$.

**Theorem 10.1 (Convergence).** $a_n \to L$ as $n\to\infty$ if and only if $a^\ast(H) \approx L$ for every unlimited $H$.

*Proof sketch.* ($\Rightarrow$) Given $\varepsilon>0$ choose $N$ with $|a_n-L|<\varepsilon$ for $n \ge N$. If $H=[f]$ is unlimited then $f(i)>N$ almost everywhere, so $|a_{f(i)}-L|<\varepsilon$ almost everywhere, i.e. $|a^\ast(H)-L|<\varepsilon$. ($\Leftarrow$) If $a_n \not\to L$, there is $\varepsilon>0$ and for each $i$ an index $f(i) \ge i$ with $|a_{f(i)}-L|\ge\varepsilon$. Then $[f]$ is unlimited but $|a^\ast([f])-L| \ge \varepsilon$, contradicting the hypothesis. $\square$

**Theorem 10.2 (Divergence to $+\infty$).** $a_n \to +\infty$ if and only if $a^\ast(H)$ is positive infinite for every unlimited $H$.

**Example 10.3.** The sequence $a_n=(-1)^n$ has no limit: the unlimited indices $[2i]$ and $[2i+1]$ give $a^\ast = 1$ and $a^\ast=-1$, with standard parts $1 \ne -1$.

The content of these theorems is a change of logical shape: the $\forall\varepsilon\exists N\forall n$ of the definition is replaced by a *universally quantified evaluation* over unlimited indices. Both directions are genuine transfer results; the reverse implications need choice to assemble a misbehaving unlimited index.

### 10.2 Infinitude and pigeonhole

**Theorem 10.4 (Nonstandard criterion for infinitude).** $S\subseteq\mathbb{N}$ is infinite if and only if ${}^\ast S$ contains an unlimited element.

*Proof.* If $S$ is infinite, choose $f(i)\in S$ with $f(i)>i$; then $[f]$ is unlimited and lies in ${}^\ast S$. Conversely if $S$ is finite with bound $N$ and $[f] \in {}^\ast S$ is unlimited, then almost everywhere $f(i)\in S$, so $f(i)\le N$, contradicting $f(i)>N$ almost everywhere. $\square$

**Lemma 10.5 (Ultrafilter concentration).** For any map $j:\mathbb{N}\to F$ into a finite set, there is $b \in F$ with $j(i)=b$ for almost all $i$.

*Proof.* The pushforward ultrafilter $j_\ast\mathcal{U}$ on the finite set $F$ is principal, say at $b$; then $j^{-1}(\{b\})$ is large. $\square$

**Theorem 10.6 (Infinite pigeonhole).** If $S_1,\dots,S_k \subseteq \mathbb{N}$ cover $\mathbb{N}$, some $S_j$ is infinite.

*Proof.* Choose $j(i)$ with $i \in S_{j(i)}$. By Lemma 10.5 there is $b$ with $j(i)=b$ almost everywhere, so $i \in S_b$ almost everywhere, i.e. $\omega \in {}^\ast S_b$. Since $\omega$ is unlimited, Theorem 10.4 gives that $S_b$ is infinite. $\square$

### 10.3 Bolzano–Weierstrass

**Theorem 10.7.** Every bounded real sequence has a cluster point: if $|a_n|\le C$ for all $n$, there is $L\in\mathbb{R}$ such that for all $\varepsilon>0$ and all $N$ there is $n\ge N$ with $|a_n - L|<\varepsilon$.

*Proof.* Consider $X := [\,i \mapsto a_i\,] \in {}^\ast\mathbb{R}$, the value of the sequence at the infinite index $\omega$. Since $-(C+1) < a_i < C+1$ for all $i$, $X$ is not infinite, hence has a standard part $L := \mathrm{st}(X)$. Suppose $L$ were not a cluster point: there are $\varepsilon>0$ and $N$ with $|a_n - L| \ge \varepsilon$ for all $n \ge N$. Since $\{i \ge N\}$ is large, $|a_i - L|\ge\varepsilon$ almost everywhere, so $|X - L| \ge \varepsilon$ in ${}^\ast\mathbb{R}$, contradicting $X \approx L$. $\square$

Compactness has been reduced to the *rounding* of a finite hyperreal to a real number. This is the paradigmatic nonstandard proof: an infinitary construction (a convergent subsequence) is replaced by the evaluation of a single object at a single infinite point.

---

## 11. Algorithms and computational content

Although $\mathcal{U}$ is not constructible, all the constructions above are *coordinatewise algorithmic*: each proof produces an explicit sequence, and truncating the sequence at a finite horizon gives a finite computation that exhibits the phenomenon. Three algorithms recur.

**A. Diagonal witness (overspill / saturation).** Given coordinatewise data $A_i$ (or a family $A^{(n)}_i$), compute at coordinate $i$ the *depth*
$$ d(i) = \max\{n \le i : \Pi_n(i) \neq \varnothing\},\qquad \Pi_n(i)=\bigcap_{k\le n}A^{(k)}_i, $$
and return a point of $\Pi_{d(i)}(i)$. For a single set this specializes to $\max\{k \le i : k \in A_i\}$. Cost at coordinate $i$: $O(i \cdot |A|)$ membership tests with the search bounded by $i$; the resulting sequence is unlimited whenever the data are "eventually deep". This one construction proves overspill, internal induction, internal completeness (with the bound $b(i)$ in place of $i$) and countable saturation.

**B. Slope separation (cardinality).** For $0<r<s$, the smallest coordinate at which the staircases separate is bounded by $\lceil 1/(s-r)\rceil$; from that point on $\lfloor ir\rfloor<\lfloor is\rfloor$ forever. Computing this crossing index numerically demonstrates that a continuum of pairwise distinct unlimited elements is available, and that the separation is *eventual*, never immediate.

**C. Composite-run localization (prime-free galaxies).** Given a standard bandwidth $m$, find coordinates $i$ for which the whole window $[\,i!+\lfloor i/2\rfloor-m,\ i!+\lfloor i/2\rfloor+m\,]$ is composite. By Lemma 9.9 every $i \ge 2m+8$ works, which is exactly the finite content of Theorem 9.11: the galaxy of $C$ is prime-free because every finite bandwidth is eventually swallowed by the composite run.

---

## 12. Discussion, open problems, and future directions

### 12.1 What the survey shows

Three theses are supported by the results above.

1. **Transfer is total, and therefore uninformative about pathology.** Every first-order theorem of arithmetic holds in the model (Theorem 3.1). The interesting mathematics of nonstandard models is thus entirely about the second-order layer.

2. **Internal/external is the correct dividing line.** Well-ordering, induction and completeness survive precisely in their internal forms (Theorems 5.1, 5.4, 5.7) and fail precisely in their external forms (Theorems 5.2, 5.5, 5.8). The failures are as extreme as possible: not merely "the supremum may be missing", but "no supremum exists"; not merely "the minimum may be missing", but "every element admits a strictly smaller one in the set".

3. **Some classical phenomena become geometric.** Arbitrarily long prime gaps, an asymptotic statement about $\mathbb{N}$, becomes the structural statement that whole intervals of galaxies are prime-free (Theorems 9.11, 9.12). This is the clearest instance in our survey where the nonstandard model does not merely re-encode a classical fact but reorganizes it.

### 12.2 Limitations

The results concern one specific model, an ultrapower along a nonprincipal ultrafilter on $\mathbb{N}$. Its cardinality is $\mathfrak{c}$ and its saturation is $\aleph_1$; both are optimal for this construction but not for nonstandard models in general. Whether the galaxy order is, under the continuum hypothesis, of the specific type $\mathbb{N} + \eta\cdot\mathfrak{c}$ (with $\eta$ the order type of $\mathbb{Q}$) is not settled here. Nor is the exact strength of the internal/external dividing line: we have established the dichotomy on a substantial sample of theorems rather than proving a metatheorem that explains it.

### 12.3 Future Directions

*Conjecture 1 (Saturation $\Rightarrow$ nonstandard compactness for internal families).* Every countable family of internal subsets of ${}^\ast\mathbb{N}$ with the finite intersection property has an *internal set* contained in all of them — not merely a common element as established in Theorem 8.2. Equivalently, the internal sets form a countably compact family closed under internal intersections indexed by a hypernatural. The key insight is that the diagonal depth function used in the saturation proof already produces an internal object, namely the germ of the finite intersections $\bigcap_{k \le d(i)} A^{(k)}_i$; making this precise turns countable saturation into a statement about internal families indexed by an unlimited hypernatural, i.e. into genuine "hyperfinite compactness". The diagonal witness and the internal-set machinery are already in place; only the indexing by an unlimited element is missing, and the decreasing case (Corollary 8.4) is already in reach.

*Conjecture 2 (Primes are dense on the multiplicative scale) — twice revised.* Two successive versions of this conjecture are refuted above: "every galaxy contains a hyperprime" fails (Theorem 9.11), and even "prime-carrying galaxies are dense" fails (Theorem 9.12: no galaxy strictly between the galaxies of $[i!]$ and $[i!+i]$ carries a prime). Additive scales are therefore the wrong invariant. The surviving conjecture is multiplicative: call $H$ and $K$ *commensurable* when $H \le K^n$ and $K \le H^n$ for some standard $n$; then every commensurability class of unlimited hypernaturals contains a hyperprime. The key insight is that Bertrand's postulate produces a prime in every interval $(x,2x)$ pointwise, and $[x]$ and $[2x]$ are always commensurable even though they are typically in different galaxies — so the multiplicative scale is exactly the resolution at which the prime distribution becomes uniform, while the additive (galaxy) scale is too fine. The germ-level machinery for commensurability is a direct variant of the same-galaxy relation, and the two refutations pin down precisely why the additive version fails.

*Conjecture 3 (Galaxy order type is that of a nonstandard model of arithmetic).* The quotient of ${}^\ast\mathbb{N}$ by the same-galaxy relation is a dense linear order without endpoints above its least element, and it is order-isomorphic to a quotient of size exactly $\mathfrak{c}$. Density (Theorem 7.5), unboundedness (Theorems 7.6, 7.7) and the least element (Theorem 7.4) are established; what remains is the cardinality of the quotient and, under the continuum hypothesis, the isomorphism type $\mathbb{N} + \eta\cdot\mathfrak{c}$.

Further natural targets suggested by the present work: an internal version of the prime number theorem (what is the internal density of hyperprimes below an unlimited $H$?); a systematic metatheorem characterizing which second-order principles survive internally; the behavior of the model under iterated ultrapowers, where saturation can be increased beyond $\aleph_1$; and a nonstandard treatment of Ramsey-type theorems along the lines of the pigeonhole proof of Theorem 10.6, where the ultrafilter concentration lemma replaces a compactness argument.

---

## 13. Conclusion

We have exhibited a concrete non-Archimedean model of arithmetic and mapped, theorem by theorem, what classical mathematics survives inside it. First-order arithmetic transfers completely; the classical set-theoretic principles of $\mathbb{N}$ survive exactly in their internal forms and fail maximally in their external forms; the model has the cardinality of the continuum and a densely stratified order of scales; countable saturation supplies a compactness that $\mathbb{N}$ itself lacks; elementary number theory transfers in force, including Euclidean division with uniqueness, gcd's, sharp Euclid, Fermat and Wilson; but the primes are not spread uniformly across scales, and whole intervals of galaxies are prime-free. In the other direction, the model repays the effort: convergence becomes evaluation at an infinite index, infinitude becomes membership, pigeonhole becomes ultrafilter concentration, and Bolzano–Weierstrass becomes rounding. The alien arithmetic is indistinguishable from ours in what it can *say*, radically different in what it *contains*, and useful precisely because of the gap.
