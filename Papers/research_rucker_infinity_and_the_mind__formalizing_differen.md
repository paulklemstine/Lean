# The Cantorian Hierarchy of Infinities: An Explicit Tower, Hartogs Bounds, and the Continuum

## Abstract

We present a self-contained development of the core structural facts governing the sizes of infinite sets, organized around Rudy Rucker's slogan that "infinity is a place you can visit." Working within the standard axioms of set theory (Zermelo–Fraenkel with the Axiom of Choice, ZFC), we (i) construct an explicit strictly increasing tower of infinite cardinals $\aleph_0 < 2^{\aleph_0} < 2^{2^{\aleph_0}} < \cdots$, a truncated *beth* sequence; (ii) prove that the cardinals form a proper class with no maximal element, via Cantor's theorem in power-set form; (iii) establish Hartogs' theorem, providing a well-orderable ordinal exceeding any given set *without* invoking its power set; (iv) locate the Continuum Hypothesis (CH) precisely as the single inequality $\mathfrak{c} \le \aleph_1$, given the ZFC theorem $\aleph_1 \le \mathfrak{c}$; (v) apply König's theorem to show the continuum has uncountable cofinality and to prove the unconditional ZFC result $\mathfrak{c} \ne \aleph_\omega$; and (vi) analyze $\aleph_0$ as the prototype of an "unreachable" cardinal — regular and a strong limit, failing inaccessibility only through the uncountability clause. We include algorithms and numerical demonstrations that make the cardinal arithmetic concrete, and we discuss the independence of CH and directions toward large-cardinal theory.

**Keywords:** cardinal arithmetic, Cantor's theorem, beth sequence, Hartogs number, continuum hypothesis, König's theorem, cofinality, inaccessible cardinal, regular cardinal, strong limit.

---

## 1. Introduction

The discovery that infinity comes in different sizes is among the most consequential in the history of mathematics. Georg Cantor's demonstration that the real numbers cannot be enumerated — that no list, however cleverly constructed, exhausts them — opened a hierarchy of transfinite magnitudes that has never been seen to terminate. This paper assembles the load-bearing facts of that hierarchy into a coherent narrative, stating each result inline with a proof sketch, and it emphasizes a unifying theme: the *ascent* through the infinities.

We adopt the metaphor of Rudy Rucker's *Infinity and the Mind*: each infinity is a *place*, and the mathematical results describe how to travel between places, which places cannot be reached from below, and which questions about the geography are permanently beyond the reach of our current axioms.

All results below are theorems of ZFC unless explicitly flagged as independent. We use the following standard notation. For a set $S$, $|S|$ (equivalently $\#S$) is its cardinality. $\aleph_0$ is the cardinality of the natural numbers; $\aleph_1$ the first uncountable cardinal; $\aleph_\omega$ the first cardinal of countable "limit" type; $\mathfrak{c} = 2^{\aleph_0}$ the cardinality of the continuum (the real numbers). $\mathcal{P}(S)$ denotes the power set. For cardinals, $c < d$ means there is an injection witnessing $c \le d$ but none witnessing $d \le c$; equivalently, an injection from a set of size $c$ into one of size $d$ but no surjection the other way.

---

## 2. Preliminaries: cardinals, ordinals, and cardinal exponentiation

A **cardinal** is a measure of the size of a set: two sets have the same cardinality iff there is a bijection between them. The finite cardinals are the natural numbers; the least infinite cardinal is $\aleph_0$. Cardinals are linearly ordered (using the Axiom of Choice), so it is meaningful to speak of one infinity being smaller than another.

**Cardinal exponentiation.** For cardinals $c$ and $d$, the power $d^c$ is the cardinality of the set of all functions from a set of size $c$ to a set of size $d$. The single most important instance is $2^c$, the cardinality of the power set of a set of size $c$: a subset is exactly a function to $\{0,1\}$ (its indicator). Thus

$$
|\mathcal{P}(S)| = 2^{|S|}.
$$

**Ordinals.** An **ordinal** is an order type of a well-ordering — a linear order in which every non-empty subset has a least element. Ordinals are themselves well-ordered, and every cardinal (under AC) can be represented by a least ordinal of that size (its *initial ordinal*). The **cofinality** $\operatorname{cof}(\lambda)$ of a limit ordinal or infinite cardinal $\lambda$ is the least length of a strictly increasing sequence whose supremum is $\lambda$. Cofinality measures reachability from below: small cofinality means $\lambda$ is the limit of a short ascending sequence.

We now turn to the results.

---

## 3. An explicit tower of infinities

We begin with the most concrete embodiment of the ascending hierarchy: a computable recipe that produces a strictly increasing sequence of infinite cardinals.

**Definition 3.1 (Cantor tower / truncated beth sequence).**
Define $T : \mathbb{N} \to \mathbf{Card}$ by
$$
T_0 = \aleph_0, \qquad T_{n+1} = 2^{T_n}.
$$
Thus $T_0 = \aleph_0$, $T_1 = 2^{\aleph_0} = \mathfrak{c}$, $T_2 = 2^{2^{\aleph_0}}$, and so on. This is the beth sequence $\beth_0, \beth_1, \beth_2, \dots$ restricted to finite indices.

**Theorem 3.2 (Cantor's theorem).**
For every cardinal $c$, $c < 2^c$.

*Proof sketch.* The map $x \mapsto \{x\}$ injects a set $S$ into $\mathcal{P}(S)$, so $|S| \le 2^{|S|}$. For strictness, suppose $f : S \to \mathcal{P}(S)$ were a surjection. Form the "diagonal" set $D = \{x \in S : x \notin f(x)\}$. If $D = f(y)$ for some $y$, then $y \in D \iff y \notin f(y) = D$, a contradiction. Hence no surjection exists, and $|S| < |\mathcal{P}(S)| = 2^{|S|}$. $\square$

**Theorem 3.3 (every stage is infinite).**
For all $n$, $\aleph_0 \le T_n$.

*Proof sketch.* Induction on $n$. The base case is equality. For the step, $\aleph_0 \le T_n \le 2^{T_n} = T_{n+1}$, the middle inequality being Cantor's theorem $T_n < 2^{T_n}$. $\square$

**Theorem 3.4 (strict monotonicity of the tower).**
The sequence $(T_n)$ is strictly increasing: $T_n < T_{n+1}$ for all $n$, and hence $T_m < T_n$ whenever $m < n$.

*Proof sketch.* $T_n < 2^{T_n} = T_{n+1}$ is exactly Cantor's theorem applied to the cardinal $T_n$. Strict monotonicity of the whole sequence follows because a natural-number sequence that strictly increases at each successor step is strictly increasing overall. $\square$

Theorem 3.4 is the precise sense in which one can "keep visiting larger infinities": we have an explicit, effectively described itinerary $\aleph_0 < \mathfrak{c} < 2^{\mathfrak c} < \cdots$ of distinct infinite magnitudes.

---

## 4. No largest infinity: the cardinals form a proper class

The tower ascends without bound, but more is true: *no* cardinal, however it is obtained, can be maximal.

**Theorem 4.1 (Cantor's theorem, power-set form).**
For any set $S$, $|S| < |\mathcal{P}(S)|$.

*Proof sketch.* Immediate from Theorem 3.2 and $|\mathcal{P}(S)| = 2^{|S|}$. $\square$

**Theorem 4.2 (successor cardinals exist).**
For every cardinal $c$ there exists a cardinal $d$ with $c < d$.

*Proof sketch.* Take $d = 2^c$ and apply Theorem 3.2. $\square$

**Theorem 4.3 (the cardinals are unbounded — a proper class).**
There is no cardinal $M$ such that $c \le M$ for every cardinal $c$.

*Proof sketch.* If such an $M$ existed, then in particular $2^M \le M$. But Cantor's theorem gives $M < 2^M$, contradicting $2^M \le M$. Hence no maximal cardinal exists; the collection of cardinals is a proper class, not a set. $\square$

Theorem 4.3 is the rigorous refutation of the naïve "largest infinity" — there is always somewhere higher to go.

---

## 5. Hartogs' theorem: a well-orderable bound without power sets

Cantor's theorem produces larger cardinals via the power set. Hartogs' theorem does so differently and more parsimoniously: it produces a *well-ordered* larger structure with no appeal to the power set of the given set and — in its classical form — no appeal to choice on the given set.

**Theorem 5.1 (Hartogs).**
For every set $\alpha$ there exists an ordinal $o$ whose cardinality strictly exceeds that of $\alpha$:
$$
|\alpha| < |o|.
$$

*Proof sketch.* Consider the least cardinal strictly greater than $|\alpha|$ — the cardinal successor $|\alpha|^+$ — and take $o$ to be its initial ordinal, so $|o| = |\alpha|^+ > |\alpha|$. The successor cardinal is well-defined because the well-orderable order types injecting into $\alpha$ form a set (a subset of order types on subsets of $\alpha \times \alpha$), whose supremum yields an ordinal of size strictly above $|\alpha|$. Crucially, this $o$ is *well-orderable by construction*, and the argument never forms $\mathcal{P}(\alpha)$. $\square$

The witnessing ordinal is the **Hartogs number** of $\alpha$. Iterating Hartogs' construction from $\aleph_0$ generates the aleph hierarchy $\aleph_0, \aleph_1, \aleph_2, \dots$ of well-ordered infinite cardinals. Hartogs' theorem is what guarantees that "the next well-ordered size" always exists — the backbone of the aleph scale.

---

## 6. $\aleph_1$, the continuum, and the Continuum Hypothesis

Hartogs' construction applied to $\aleph_0$ yields the first uncountable cardinal.

**Theorem 6.1 ($\aleph_1$ is uncountable).**
$\aleph_0 < \aleph_1$.

*Proof sketch.* $\aleph_1$ is the cardinal successor of $\aleph_0$, hence strictly greater by definition of successor. $\square$

There are now two candidates for "the next infinity above the countable": the order-theoretic successor $\aleph_1$, and the continuum $\mathfrak{c} = 2^{\aleph_0}$ delivered by Cantor's diagonal. They are comparable, and one inequality is a theorem.

**Theorem 6.2 (the easy half of CH).**
$\aleph_1 \le \mathfrak{c}$.

*Proof sketch.* $\mathfrak{c} = 2^{\aleph_0}$ is uncountable (Cantor), so it is an uncountable cardinal; since $\aleph_1$ is the *least* uncountable cardinal, $\aleph_1 \le \mathfrak{c}$. $\square$

**Definition 6.3 (Continuum Hypothesis).**
The **Continuum Hypothesis** (CH) is the statement
$$
\aleph_1 = \mathfrak{c}.
$$

Because one direction is already a theorem, CH reduces to a single inequality — this isolates its entire content.

**Theorem 6.4 (CH is exactly one inequality).**
CH holds if and only if $\mathfrak{c} \le \aleph_1$.

*Proof sketch.* If $\aleph_1 = \mathfrak{c}$ then trivially $\mathfrak{c} \le \aleph_1$. Conversely, combining $\mathfrak{c} \le \aleph_1$ with the ZFC theorem $\aleph_1 \le \mathfrak{c}$ (Theorem 6.2) and antisymmetry of the cardinal order gives $\aleph_1 = \mathfrak{c}$. $\square$

**Theorem 6.5 (CH in exponential form).**
CH holds if and only if $\aleph_1 = 2^{\aleph_0}$.

*Proof sketch.* Immediate from $\mathfrak{c} = 2^{\aleph_0}$. $\square$

**On the status of CH.** Theorem 6.4 pins the whole undecidable content of CH onto the single inequality $\mathfrak{c} \le \aleph_1$. Gödel (1940), via the constructible universe $L$, showed $\mathrm{Con}(\mathrm{ZFC}) \Rightarrow \mathrm{Con}(\mathrm{ZFC} + \mathrm{CH})$; Cohen (1963), via forcing, showed $\mathrm{Con}(\mathrm{ZFC}) \Rightarrow \mathrm{Con}(\mathrm{ZFC} + \neg\mathrm{CH})$. Together these establish that CH is **independent** of ZFC — neither provable nor refutable. Accordingly, CH is a well-posed proposition whose truth value the standard axioms do not determine; we state it and analyze its equivalent forms without asserting or denying it.

---

## 7. König's theorem and constraints on the continuum

Independence does not leave the continuum wholly unconstrained. König's theorem sharply limits the possible values of $\mathfrak{c}$.

**Cofinality.** Recall $\operatorname{cof}(\lambda)$ is the least length of an increasing sequence with supremum $\lambda$. A cardinal is **regular** if $\operatorname{cof}(\lambda) = \lambda$ and **singular** otherwise.

**Theorem 7.1 (König; continuum has uncountable cofinality).**
$$
\aleph_0 < \operatorname{cof}(\mathfrak{c}).
$$

*Proof sketch.* König's theorem yields, for any infinite cardinal $\kappa$ and any $2 \le \mu$, the inequality $\operatorname{cof}(\mu^\kappa) > \kappa$. Specializing to $\mu = 2$, $\kappa = \aleph_0$ gives $\operatorname{cof}(2^{\aleph_0}) > \aleph_0$, i.e. $\operatorname{cof}(\mathfrak{c}) > \aleph_0$. Intuitively, $\mathfrak{c}$ cannot be written as a countable union/limit of strictly smaller cardinals. $\square$

**Theorem 7.2 (cofinality of $\aleph_\omega$).**
$$
\operatorname{cof}(\aleph_\omega) = \aleph_0.
$$

*Proof sketch.* By definition $\aleph_\omega = \sup_n \aleph_n$ is the limit of the countable strictly increasing sequence $\aleph_0 < \aleph_1 < \aleph_2 < \cdots$, so a cofinal sequence of length $\aleph_0$ exists, and none shorter can reach a limit cardinal; hence the cofinality is exactly $\aleph_0$. $\square$

**Theorem 7.3 (the continuum is not $\aleph_\omega$ — unconditional in ZFC).**
$$
\mathfrak{c} \ne \aleph_\omega.
$$

*Proof sketch.* If $\mathfrak{c} = \aleph_\omega$, then their cofinalities would agree; but $\operatorname{cof}(\mathfrak{c}) > \aleph_0$ (Theorem 7.1) while $\operatorname{cof}(\aleph_\omega) = \aleph_0$ (Theorem 7.2), a contradiction. $\square$

Theorem 7.3 is a genuine, hypothesis-free ZFC constraint: although the exact value of $\mathfrak{c}$ is independent of the axioms, certain candidate values (any cardinal of countable cofinality, such as $\aleph_\omega$) are *provably* excluded.

---

## 8. $\aleph_0$ as the prototype of an unreachable cardinal

The frontier of set theory concerns **large cardinals**, whose existence transcends ZFC. The gateway notion is inaccessibility.

**Definition 8.1 (inaccessible cardinal).**
A cardinal $\kappa$ is **inaccessible** if it is
(1) **uncountable** ($\aleph_0 < \kappa$),
(2) **regular** ($\kappa \le \operatorname{cof}(\kappa)$), and
(3) a **strong limit** (for every $x < \kappa$, $2^x < \kappa$).

Inaccessible cardinals cannot be reached from below by the ordinary operations of successor, union of few sets, or power set — precisely the operations by which ZFC builds sets. Their existence is not provable in ZFC. Remarkably, the least infinity satisfies two of the three defining clauses.

**Theorem 8.2 ($\aleph_0$ is regular).**
$\aleph_0 \le \operatorname{cof}(\aleph_0)$; equivalently $\operatorname{cof}(\aleph_0) = \aleph_0$.

*Proof sketch.* A finite union of finite sets is finite, so no finite (i.e. length-$<\aleph_0$) increasing sequence of naturals has supremum $\aleph_0$; the least cofinal length is $\aleph_0$ itself. $\square$

**Theorem 8.3 ($\aleph_0$ is a strong limit).**
For every cardinal $x < \aleph_0$, $2^x < \aleph_0$.

*Proof sketch.* $x < \aleph_0$ means $x$ is finite; then $2^x$ is a finite power of $2$, hence finite, hence $< \aleph_0$. $\square$

**Theorem 8.4 ($\aleph_0$ is inaccessible except for uncountability).**
$\aleph_0$ is regular and a strong limit, yet $\aleph_0$ is **not** inaccessible — and it fails *only* the uncountability clause.

*Proof sketch.* Regularity and strong-limitness are Theorems 8.2 and 8.3. If $\aleph_0$ were inaccessible, clause (1) would give $\aleph_0 < \aleph_0$, impossible. Thus the sole obstruction is the uncountability requirement, which is imposed by fiat in the definition. $\square$

Theorem 8.4 offers a satisfying closure to the ascent: $\aleph_0$ is the first infinity that cannot be reached from below by finite means — regular and strong-limit, "inaccessible in spirit," and excluded from the formal class of inaccessibles only because that class is reserved, by convention, for the uncountable. The genuine inaccessibles are the uncountable analogues of $\aleph_0$: the next places one cannot climb to, and whose existence is a new axiom rather than a theorem.

---

## 9. Algorithms

The cardinal arithmetic above, while transfinite, has an entirely finite and computable "skeleton" that makes the hierarchy tangible. We record three algorithms.

**Algorithm A (Beth/Cantor tower exponents).** Represent each rung $T_n$ of the tower symbolically as an iterated power $2 \uparrow\uparrow$ over $\aleph_0$, and compute, for finite *models*, the sizes obtained by starting from a finite base $b$: $t_0 = b$, $t_{n+1} = 2^{t_n}$. This exhibits the explosive growth that, in the limit, separates the infinite rungs. Complexity: each step is a single exponentiation; the numbers grow as a tower (non-elementary), so bignum arithmetic dominates.

**Algorithm B (Cantor diagonalization).** Given a finite list of binary sequences (a "would-be enumeration"), construct a sequence not on the list by flipping the $i$-th bit of the $i$-th row. This is the finite shadow of the proof that $\aleph_0 < 2^{\aleph_0}$. Complexity: $O(n)$ in the number of listed sequences.

**Algorithm C (cofinality of a limit cardinal from an aleph-index).** Given the aleph-index of a cardinal (e.g. $\omega$ for $\aleph_\omega$, or a successor index for a regular successor cardinal), decide whether it is regular or singular and report its cofinality index. This is the decision procedure underlying $\mathfrak{c} \ne \aleph_\omega$: any cardinal of countable cofinality is excluded as a value of $\mathfrak{c}$.

Pseudocode and reference implementations appear in the accompanying materials.

---

## 10. Applications and connections

- **Foundations of analysis.** The uncountability of $\mathbb{R}$ ($\aleph_0 < \mathfrak{c}$) underlies the existence of non-measurable sets, the failure of naive enumerative arguments on the reals, and the distinction between countable and uncountable dense orders.
- **Computability and descriptive set theory.** Only countably many objects can be finitely described; since $\mathfrak{c} > \aleph_0$, "most" real numbers are undefinable. The aleph/beth hierarchy stratifies the complexity of definable sets.
- **Model theory.** Hartogs numbers and cardinal successors govern the Löwenheim–Skolem spectrum: theories have models in every infinite cardinality, and the aleph scale indexes them.
- **The independence phenomenon.** CH was the first natural mathematical statement shown independent of the standard axioms, inaugurating the modern study of what mathematics can and cannot settle — a template later applied across combinatorics, algebra, and analysis.

---

## 11. Discussion

The results assemble into a single picture. Cantor's theorem is the engine of ascent (§3–§4): it guarantees that from any infinity we can step to a strictly larger one, and it forbids a maximal infinity. Hartogs' theorem gives an alternative, more frugal engine (§5) that builds *well-ordered* larger infinities without power sets, generating the aleph scale. The interaction of the two engines — the power-set continuum $2^{\aleph_0}$ versus the order-successor $\aleph_1$ — is exactly the site of the Continuum Hypothesis (§6), whose entire undecidable content compresses to one inequality. König's theorem (§7) then shows that even an undecidable magnitude obeys firm constraints: $\mathfrak{c}$ has uncountable cofinality and thus cannot equal $\aleph_\omega$. Finally (§8), the least infinity $\aleph_0$ mirrors, in miniature, the large-cardinal notion of inaccessibility, being unreachable from below by finite means.

A recurring methodological point: several of the sharpest facts are *negative* — no largest cardinal, $\mathfrak{c} \ne \aleph_\omega$, $\aleph_0$ is not inaccessible — and each negative result is proved by exhibiting a specific structural obstruction (a diagonal set, a cofinality mismatch, a violated clause). These negations carve out the shape of the hierarchy as precisely as the positive constructions.

---

## 12. Future directions

Natural next steps extend the development in several directions.

1. **The full beth function** over all ordinals, $\beth : \mathbf{Ord} \to \mathbf{Card}$, and its fixed points; the finite tower $T_n$ agrees with $\beth_n$, and the general theory of $\beth$-fixed points and their cofinalities can be packaged.
2. **Further König consequences.** The general statements $\operatorname{cof}(2^\kappa) > \kappa$ and $\kappa < \kappa^{\operatorname{cof}\kappa}$ yield additional exclusions on cardinal exponentiation beyond $\mathfrak{c} \ne \aleph_\omega$.
3. **Independence of CH.** A full account requires forcing (Cohen) and inner-model theory (Gödel's $L$) to establish the relative consistency results $\mathrm{Con}(\mathrm{ZFC}) \Rightarrow \mathrm{Con}(\mathrm{ZFC} \pm \mathrm{CH})$. Building this model theory of set theory is a substantial long-term program; until then CH is treated as an undischarged proposition.
4. **Large cardinals beyond inaccessibility.** Measurable, Ramsey, and supercompact cardinals, the implication measurable $\Rightarrow$ inaccessible, and the consistency-strength hierarchy are the natural continuation of §8.

---

## 13. Conclusion

The infinities form an endless, strictly ascending hierarchy with no summit. We can name explicit rungs (the beth tower), guarantee ascent both by power sets (Cantor) and by well-orderings (Hartogs), locate the exact single inequality carrying the Continuum Hypothesis, constrain the continuum unconditionally (König: $\mathfrak{c} \ne \aleph_\omega$), and recognize in $\aleph_0$ the first prototype of an unreachable place. Infinity is, in the precise sense made rigorous here, a landscape one can visit — one summit at a time, forever.
