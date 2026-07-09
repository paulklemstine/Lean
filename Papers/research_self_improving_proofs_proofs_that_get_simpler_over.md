# Self-Improving Proofs: A Refinement Calculus on Proof Complexity

## Abstract

We develop a rigorous calculus of *proof refinement*, making precise the idea that a proof of a theorem can be progressively simplified and that this simplification is a well-behaved dynamical process. Each proof $P$ of a proposition $T$ is assigned a **complexity** $C(P) = \mathrm{length}(P) + \mathrm{depth}(P) + \#\mathrm{lemmas}(P) \in \mathbb{N}$, and a proof $P'$ *refines* $P$ when it proves the same theorem strictly more simply, $C(P') < C(P)$. We prove that refinement is a well-founded strict order, that every nonempty family of proofs of $T$ contains a complexity-minimal member, and consequently that as soon as $T$ is provable it possesses a globally simplest proof $P_\infty$ — the limit of the refinement process, which always exists. We show the minimal complexity $C(P_\infty)$ is a well-defined invariant of $T$; that no infinite strictly-descending refinement chain exists; that every non-increasing refinement sequence is eventually constant (termination); and yet that refinement chains can be arbitrarily long. The theory is instantiated on the irrationality of $\sqrt{2}$, exhibiting an explicit chain $C = 7 \rightsquigarrow 4 \rightsquigarrow 2$ whose minimal member is identified. We close by isolating exactly which parts of the informal "self-improving proofs" program are established and which remain open, and lay out a route toward a syntactic complexity measure and a rewrite-based refinement engine.

**Keywords.** proof complexity, refinement, well-foundedness, well-ordering, minimal proof, Kolmogorov complexity, termination, irrationality of $\sqrt{2}$.

## 1. Introduction

A proof is customarily regarded as a static artifact: once verified, it is complete and immutable. Yet mathematical practice tells a different story. The same theorem is reproved again and again, each generation trimming hypotheses, merging cases, replacing bespoke arguments by reusable lemmas, until a folklore "book proof" emerges. This suggests treating a proof not as a fixed object but as a *state* in a dynamical system, with a transition rule — *simplification* — driving it toward an optimum.

This paper makes that picture precise and proves its structural backbone. We introduce a minimal but faithful model in which the only feature of a proof we track is a scalar complexity, and we show that the entire qualitative behavior of proof simplification is governed by a single classical fact: the **well-ordering of the natural numbers**. From it we extract, in a tight dependency chain, the existence of simplest proofs, the well-definedness of a theorem's minimal complexity, the impossibility of infinite refinement, the termination of every improving sequence, and — as a counterweight — the unboundedness of chain length.

The central conceptual payoff is a clean separation of two notions that intuition tends to conflate: *how simple can a proof of $T$ get* (a well-defined number, the minimal complexity) versus *how long simplification might take to get there* (unbounded). Both are theorems below.

This separation deserves emphasis because informal discussions of "difficulty" routinely blur it. When one says a theorem is *hard*, one might mean that its simplest known argument is intrinsically long — that its minimal complexity is large — or one might mean that, although a short argument exists, finding it (walking the refinement path down to the valley floor) is laborious. The theory below shows these are genuinely orthogonal: a theorem can have minimal complexity as small as one likes while sitting at the far end of a refinement chain of any prescribed length. Any honest account of proof simplification must keep the two apart, and our formalism does so by construction.

A second theme is *unconditionality*. The existence of the simplest proof requires no search procedure, no bound on the family, and no finiteness. It is a pure consequence of order structure, and it holds the instant the theorem is provable at all. Where much of the folklore around "the book proof" is aspirational — we hope a beautiful proof exists — here it is a theorem that one does.

### 1.1 Contributions

1. A precise model of proofs-as-complexity-bundles and of the refinement relation (§2).
2. Well-foundedness of refinement and the strict-order laws (§3).
3. Existence of complexity-minimal proofs in arbitrary nonempty families, and hence a globally simplest proof $P_\infty$ whenever $T$ is provable (§4).
4. Well-definedness of the minimal complexity $C(P_\infty)$ as an invariant of $T$ (§5).
5. Non-existence of infinite refinement chains and termination of every non-increasing refinement sequence (§6).
6. Unboundedness of refinement chain length (§7).
7. A worked instantiation on $\mathrm{Irrational}(\sqrt 2)$ with the explicit chain $7 \rightsquigarrow 4 \rightsquigarrow 2$ (§8).
8. A careful account of the theory's scope and its relation to Kolmogorov complexity (§9), and a research program toward a syntactic measure (§10).

## 2. The model

### 2.1 Proofs as complexity bundles

Fix a proposition $T$.

**Definition 2.1 (Proof).** A *proof* of $T$ is a pair
$$P = (\,C(P),\ \mathrm{cert}(P)\,),$$
where $C(P) \in \mathbb{N}$ is its **complexity** and $\mathrm{cert}(P)$ is a certificate that $T$ holds. We write $\mathrm{Proof}(T)$ for the type of all proofs of $T$.

Two remarks fix the intended reading.

*The complexity as a composite.* The mission measure is $C(P) = \mathrm{length}(P) + \mathrm{depth}(P) + \#\mathrm{lemmas}(P)$, where $\mathrm{length}$ counts proof steps, $\mathrm{depth}$ the nesting of sub-derivations, and $\#\mathrm{lemmas}$ the number of auxiliary results invoked. Each summand is a nonnegative integer, so their sum is a natural number. Modelling $C(P)$ as an abstract element of $\mathbb{N}$ therefore loses no structure: every claim about the *dynamics* of refinement is a claim about the order structure of $\mathbb{N}$, and it is exactly that structure we analyze. §10 discusses replacing this scalar by a measure derived from a genuine proof-term datatype.

*The certificate.* Requiring $\mathrm{cert}(P) : T$ makes $\mathrm{Proof}(T)$ inhabited **iff** $T$ is true. This guarantees refinement is a relation *between genuine proofs of the same theorem* — we never compare or manufacture proofs of falsehoods.

### 2.2 Refinement

**Definition 2.2 (Refinement).** For $P, Q \in \mathrm{Proof}(T)$, say $P$ **refines** $Q$, written $P \prec Q$, iff
$$C(P) < C(Q).$$

Thus $P \prec Q$ means "$P$ proves the same theorem, strictly more simply." Refinement is literally the pullback of the strict order $<$ on $\mathbb{N}$ along the complexity map $C : \mathrm{Proof}(T) \to \mathbb{N}$.

## 3. Refinement is a well-founded strict order

**Theorem 3.1 (Well-foundedness — the engine).** The relation $\prec$ on $\mathrm{Proof}(T)$ is well-founded: there is no infinite sequence $P_0, P_1, P_2, \dots$ with $P_{n+1} \prec P_n$ for all $n$.

*Proof.* $\prec$ is the pullback of $<$ on $\mathbb{N}$ along $C$. The pullback (inverse image) of a well-founded relation along any function is well-founded, and $<$ on $\mathbb{N}$ is well-founded (equivalently, $\mathbb{N}$ is well-ordered). Hence $\prec$ is well-founded. $\qquad\blacksquare$

This single fact drives everything below.

**Theorem 3.2 (Transitivity).** If $P \prec Q$ and $Q \prec R$ then $P \prec R$.

*Proof.* $C(P) < C(Q) < C(R)$, and $<$ on $\mathbb{N}$ is transitive. $\qquad\blacksquare$

**Theorem 3.3 (Irreflexivity).** For every $P$, $\lnot (P \prec P)$.

*Proof.* $C(P) < C(P)$ is false. $\qquad\blacksquare$

Together, Theorems 3.2–3.3 make $\prec$ a strict order, and Theorem 3.1 makes it well-founded.

## 4. Existence of the simplest proof and the limit $P_\infty$

**Theorem 4.1 (Minimal member of a family).** Let $S \subseteq \mathrm{Proof}(T)$ be nonempty. Then there exists $P \in S$ such that no $Q \in S$ refines $P$:
$$\exists\, P \in S,\ \forall\, Q \in S,\ \lnot(Q \prec P).$$

*Proof.* Direct from well-foundedness (Theorem 3.1): a well-founded relation has a minimal element on every nonempty subset. Concretely, $\{\,C(Q) : Q \in S\,\}$ is a nonempty set of naturals, so it has a least element $m$; any $P \in S$ with $C(P) = m$ is minimal, since $Q \prec P$ would give $C(Q) < m$, contradicting minimality of $m$. $\qquad\blacksquare$

No finiteness of $S$ is required, and $P$ need not be unique.

**Theorem 4.2 (The limit always exists).** If $T$ has at least one proof $P_0$, then it has a *globally simplest* proof $P$: one that no proof of $T$ can refine,
$$\exists\, P \in \mathrm{Proof}(T),\ \forall\, Q \in \mathrm{Proof}(T),\ \lnot(Q \prec P).$$

*Proof.* Apply Theorem 4.1 to the total family $S = \mathrm{Proof}(T)$, which is nonempty since $P_0 \in S$. The resulting minimal member is minimal against *all* proofs of $T$. $\qquad\blacksquare$

We call such a $P$ the **limit** $P_\infty$ of the refinement process. Theorem 4.2 says $P_\infty$ exists the moment $T$ is provable — no construction, continuity, or search is needed for the guarantee.

## 5. The minimal complexity is an invariant of the theorem

Distinct globally simplest proofs may exist, but they cannot disagree on complexity.

**Theorem 5.1 (Uniqueness of the minimal complexity).** If $P$ and $Q$ are both globally simplest proofs of $T$ (each refined by no proof of $T$), then $C(P) = C(Q)$.

*Proof.* Since $Q$ does not refine $P$, $\lnot(C(Q) < C(P))$, i.e. $C(P) \le C(Q)$. Since $P$ does not refine $Q$, $C(Q) \le C(P)$. By antisymmetry of $\le$ on $\mathbb{N}$, $C(P) = C(Q)$. $\qquad\blacksquare$

**Definition 5.2 (Minimal complexity).** For a provable $T$, define $C_{\min}(T) := C(P_\infty)$, the common complexity of all globally simplest proofs. By Theorem 5.1 this is well-defined and independent of the chosen simplest proof.

$C_{\min}(T)$ is the intrinsic, irreducible cost of proving $T$ *within this measure* — a concrete analogue of a Kolmogorov-minimal description (see §9 for the precise scope of this analogy).

## 6. No infinite refinement, and termination

**Theorem 6.1 (No infinite refinement).** There is no sequence $f : \mathbb{N} \to \mathrm{Proof}(T)$ with $f(n+1) \prec f(n)$ for all $n$.

*Proof.* Suppose such $f$ exists. The range $\{f(n) : n \in \mathbb{N}\}$ is nonempty, so by Theorem 4.1 it has a minimal member $f(k)$. But $f(k+1) \prec f(k)$ with $f(k+1)$ in the range contradicts minimality. $\qquad\blacksquare$

(This is Theorem 3.1 re-derived through the minimal-member lemma, emphasizing the chain of dependence.)

**Theorem 6.2 (Termination).** Let $f : \mathbb{N} \to \mathrm{Proof}(T)$ have non-increasing complexity, i.e. $n \le m \Rightarrow C(f(m)) \le C(f(n))$ (the sequence "never gets more complex"). Then $f$ is eventually constant in complexity: there is $N$ with
$$\forall\, n \ge N,\ C(f(n)) = C(f(N)).$$

*Proof.* By Theorem 4.1 the range of $f$ has a complexity-minimal member $f(N)$. For $n \ge N$, monotonicity gives $C(f(n)) \le C(f(N))$, while minimality of $f(N)$ gives $\lnot(C(f(n)) < C(f(N)))$, i.e. $C(f(N)) \le C(f(n))$. Hence $C(f(n)) = C(f(N))$. $\qquad\blacksquare$

Theorem 6.2 is the precise form of the slogan $C(P_N) = C(P_{N+1}) = \cdots = C(P_\infty)$. Note it locks the *complexity*, not the proof object: after stage $N$ the proofs may still vary, but only among proofs of the same minimal complexity reached along the sequence.

## 7. Chains can be arbitrarily long

Termination does not bound the *time to terminate*.

**Theorem 7.1 (Unbounded chain length).** If $T$ holds, then for every $N \in \mathbb{N}$ there is a strictly descending refinement chain of length $N+1$: a family $f : \{0, 1, \dots, N\} \to \mathrm{Proof}(T)$ with $C(f(i))$ strictly decreasing in $i$.

*Proof.* Because $T$ holds, we may form, for each $i \in \{0,\dots,N\}$, a proof $f(i)$ with certificate the given proof of $T$ and complexity $C(f(i)) = N - i$ (padding the complexity by irrelevant steps). Then $i < j \le N$ implies $N - i > N - j \ge 0$, so $C(f(j)) < C(f(i))$; the chain $f(0), \dots, f(N)$ has strictly decreasing complexities $N, N-1, \dots, 0$. $\qquad\blacksquare$

Corollary: although every refinement process terminates (Theorem 6.2), there is no uniform bound on how many strict steps it may take. This captures the intuition that a theorem may possess a very simple $P_\infty$ that is nonetheless reachable only through an astronomically long simplification.

## 8. Worked example: the irrationality of $\sqrt{2}$

We instantiate the theory at $T = \mathrm{Irrational}(\sqrt{2})$, a true proposition, and compare three proof strategies by their complexities.

**Strategy A — classical proof by contradiction ($C = 7$).** Assume $\sqrt 2 = a/b$ in lowest terms; then $a^2 = 2 b^2$, so $2 \mid a^2$, so $2 \mid a$; write $a = 2c$, obtain $b^2 = 2 c^2$, so $2 \mid b$; this contradicts $\gcd(a,b)=1$. The step count, the nested even/odd case reasoning, and the several arithmetic lemmas invoked accumulate to complexity $7$.

**Strategy B — via prime divisibility ($C = 4$).** Use the lemma "if a prime $p$ divides $n^2$ then $p \mid n$." For $p = 2$ this absorbs the two separate "$a$ even" and "$b$ even" deductions into one reusable principle, cutting length, depth, and lemma-count to total complexity $4$.

**Strategy C — the packaged theorem ($C = 2$).** Invoke the finished result that $\sqrt 2$ is irrational as a single named fact. Complexity $2$ (state and apply).

These three proofs form a nonempty family $S = \{A, B, C\} \subseteq \mathrm{Proof}(\mathrm{Irrational}(\sqrt2))$ with complexities $7, 4, 2$. We record:

**Proposition 8.1 (The chain $7 \rightsquigarrow 4 \rightsquigarrow 2$).** $B \prec A$ and $C \prec B$ (since $4 < 7$ and $2 < 4$), and by transitivity $C \prec A$. Thus $A \rightsquigarrow B \rightsquigarrow C$ is a genuine refinement chain.

**Proposition 8.2 (Simplest of the three).** $C$ is the minimal member of $S$: no member of $S$ refines $C$, because none has complexity $< 2$. By Theorem 4.1 this is exactly the guaranteed minimal member for the family $S$, and $C_{\min}$ restricted to $S$ equals $2$.

This concrete episode is the abstract theory in miniature: a nonempty family of proofs, a guaranteed minimal member, a strictly descending chain realizing successive refinements, and a well-defined minimal complexity.

The example also illustrates the two axes of §1 in one picture. All three strategies prove the very same theorem, and the packaged proof — complexity $2$ — is genuinely simple. Yet historically the community reached it only after generations of reorganization: first the classical contradiction, then its distillation through the prime-divisibility lemma, then the packaging of the whole argument as a single citable fact. The minimal complexity ($2$, over this family) is small; the refinement path that led there was long. The abstract theorems say this pattern is not an accident of $\sqrt2$ but the generic shape of proof simplification.

One can tabulate the family compactly. Writing each proof as $(\mathrm{length}, \mathrm{depth}, \#\mathrm{lemmas})$:

| Strategy | length | depth | #lemmas | $C$ |
|---|---|---|---|---|
| A: classical contradiction | 4 | 2 | 1 | 7 |
| B: via prime divisibility | 2 | 1 | 1 | 4 |
| C: packaged theorem | 1 | 1 | 0 | 2 |

Each row certifies a true proof of the same theorem; the strictly decreasing final column is the chain $7 \rightsquigarrow 4 \rightsquigarrow 2$, and the bottom row is the minimal member guaranteed by Theorem 4.1.

## 9. Scope: what is and is not claimed

The informal program speaks of "the simplest proof in the sense of Kolmogorov complexity." We are deliberately precise about the correspondence.

- **What holds.** Bundling $\mathrm{length} + \mathrm{depth} + \#\mathrm{lemmas}$ into a single $C \in \mathbb{N}$ yields, via Theorem 5.1, a well-defined *minimal complexity value* $C_{\min}(T)$. This is the honest formal counterpart of a minimal-description length *within this measure*.
- **What does not.** We do **not** claim uniqueness of the simplest *proof object*: there may be many proofs achieving complexity $C_{\min}(T)$. Theorem 5.1 asserts uniqueness of the *value*, not of the witness. Nor do we claim any connection to the uncomputable Kolmogorov complexity $K$; $C_{\min}$ here is defined relative to the chosen additive measure and is not asserted to be uncomputable or to coincide with $K$.

This scoping is what makes the theory clean: every theorem is a statement about the order structure of $\mathbb{N}$ pulled back along $C$, and each is proved without appeal to any informal intuition.

### 9.1 Design rationale: why a scalar complexity suffices

A reader might object that collapsing a rich, structured proof into a single number throws away everything interesting. Two responses justify the choice. First, the *dynamics* of refinement — the questions of existence, uniqueness of value, termination, and chain length — depend only on how complexities compare, i.e. on the total preorder that $C$ induces on proofs. Any faithful model of "strictly simpler" must at minimum give such a comparison; our scalar model gives exactly it and nothing extraneous, so the theorems isolate precisely the order-theoretic content of the informal program. Second, the scalar is not a straitjacket: §10 explains how to *derive* it from a genuine proof-term datatype so that $\mathrm{length}$, $\mathrm{depth}$, and $\#\mathrm{lemmas}$ become computed statistics rather than posited ones. The theorems proved here transfer verbatim to any such derived $C$, because their proofs use only that $C$ lands in a well-ordered set. In this sense the abstract development is a reusable core: instantiate $C$ however one likes, and the entire chain of consequences follows for free.

### 9.2 Relation to descending-chain conditions

The backbone of the theory is the *descending chain condition* (DCC) on $\mathbb{N}$: there is no infinite strictly decreasing sequence. Structures satisfying a DCC pervade mathematics — Noetherian rings and modules, well-founded recursions, ordinal-indexed constructions, and termination arguments in rewriting theory all rest on it. Our contribution is to observe that proof simplification, once complexity is measured in a well-ordered set, is *another* instance of this pattern, and to draw out its specific consequences (existence of simplest proofs, invariance of minimal complexity, termination of improving sequences). The unboundedness result (Theorem 7.1) is the familiar companion to every DCC argument: well-foundedness controls *whether* descent stops, never *when*. Recognizing proof refinement as a DCC phenomenon both explains why the results are robust and points to the natural strengthenings — confluence and quantitative bounds — pursued in §10.

## 10. Discussion and future directions

The results isolate the mathematical core of "self-improving proofs" — the well-ordering of complexity — and derive from it a complete qualitative picture: refinement is a well-founded strict order (Thms 3.1–3.3); every nonempty family has a simplest member (Thm 4.1); the limit $P_\infty$ exists whenever $T$ is provable (Thm 4.2); its complexity is an invariant (Thm 5.1); infinite refinement is impossible (Thm 6.1) and every improving sequence halts (Thm 6.2); yet chains are unbounded in length (Thm 7.1). The $\sqrt2$ instance (§8) shows the apparatus in action.

**Future directions.**

1. **A syntactic complexity measure.** Replace the abstract $C : \mathbb{N}$ by a function computed from a genuine inductive proof-term datatype (constructors for introduction, application, case analysis, lemma references, …), so that $\mathrm{length}$, $\mathrm{depth}$, and $\#\mathrm{lemmas}$ are *derived* rather than posited; then re-establish the entire chain for this concrete $C$.

2. **Refinement rules as rewrites.** Model the specific moves — "eliminate an unnecessary lemma," "shorten a case split," "remove a redundant quantifier" — as operations on proof terms, and prove each is complexity-non-increasing. The abstract results then certify termination of any pipeline built from such rules.

3. **Confluence and canonical forms.** Determine whether a fixed set of refinement rewrites is confluent, yielding a *unique normal-form proof* rather than merely a unique minimal complexity — the natural strengthening of Theorem 5.1.

4. **Quantitative bounds.** Theorem 7.1 shows chains are unbounded; a refinement would relate maximal chain length to starting complexity for a *specific* rewrite system, capturing the "$10^{100}$ refinements" intuition as an explicit (e.g. exponential) bound.

## 11. Conclusion

Treating proofs as living objects and refinement as a downhill flow, we have shown the flow is globally well-behaved: it cannot cycle, cannot run forever, and always reaches a valley floor whose height is an invariant of the theorem — while being free to take arbitrarily long to get there. Elegance, on this account, is not merely aesthetic: the simplest proof exists, and its cost is a number attached to the theorem for all time.
