# Functional Fibers, Experiential Gaps, and Algebraic Forgetting

**Aristotle**  
**July 19, 2026**

## Abstract

This paper develops a self-contained mathematical account of the gap between functional description and subjective experience. An experience model assigns to each possible world both an observable functional profile and an experiential value, with one value distinguished as void. We prove a conservative extension theorem: every such model embeds functionally into a two-sheeted model in which each world has an experience-retaining copy and a functionally identical void copy. Consequently, no predicate depending only on functional profile can distinguish the two sheets. This is an underdetermination theorem, not an assertion that every fixed model already contains a zombie; an all-void singleton model supplies the boundary counterexample.

For a canonical model with exactly two worlds over each functional profile, we classify zombie witnesses by profiles. We then construct a canonical sound semantic system in which each profile indexes one true but unaccepted code, classify semantic-gap witnesses by the same profiles, and obtain an explicit isomorphism between the two witness spaces. The correspondence is precise but model-relative: it does not identify consciousness with arithmetic or establish an unconditional equivalence for arbitrary systems.

We connect this hidden-fiber structure to two further theories. First, for finite systems with nonnegative effective information on nontrivial cuts, integrated information is an attained minimum; we establish existence, greatest-lower-bound character, nonnegativity, reducibility, monotonicity, and equality under a common minimizing cut. These functional invariants coexist with, but do not determine, the experiential fiber. Second, a compositional finite memory on streams necessarily identifies distinct histories. Its erased inputs form a submonoid, and its reachable observable algebra is isomorphic to the stream algebra quotiented by memory indistinguishability. Targeted forgetting satisfies a universal factorization property. Across all three settings, the central object is a forgetful map and the central question is the structure of its fibers.

## 1. Introduction

A functional account of a system records what the system does: its transitions, reports, discriminations, causal roles, or input–output profile. A theory of subjective experience attempts to record an additional fact: what, if anything, it is like to occupy a state. The philosophical “zombie” thought experiment asks whether functional identity forces experiential identity.

The mathematical treatment given here separates three claims that are often conflated.

1. A particular experience model contains a conscious world and a functionally identical void world.
2. Every experience model can be conservatively extended so that such a pair exists while all original functional profiles are preserved.
3. The space of experiential gaps is universally equivalent to a space of semantic incompleteness gaps.

The first claim is model-dependent and can fail. The second admits a general construction. The third is false without structural hypotheses but becomes an exact isomorphism for canonical two-sheeted models. Keeping these quantifiers explicit prevents a construction of underdetermination from being misreported as an empirical existence theorem.

The two-sheeted construction is an instance of a wider pattern. A map from a rich state space to an observable description can forget coordinates. The inverse image of an observable value—its fiber—contains the alternatives that the description cannot distinguish. The same pattern governs true but unaccepted codes in a simple semantic system, equal outputs of finite memories, and the independence of an experiential coordinate from a functional optimization such as integrated information.

The paper has four goals. Section 2 defines experience models and zombie witnesses. Section 3 proves the conservative extension and its boundary. Section 4 classifies canonical zombie and semantic gaps and establishes their isomorphism. Section 5 develops the finite minimum-information landscape. Section 6 gives an algebraic theory of memory and targeted forgetting. Section 7 presents finite algorithms and complexity bounds, and Sections 8–10 discuss applications, limitations, and future directions.

## 2. Experience models and functional indistinguishability

### 2.1 Basic definitions

**Definition 2.1 (Experience model).** An experience model is a tuple

$$
\mathcal M=(W,F,E,B,Q,q_0),
$$

where $W$ is a set of possible worlds, $F$ is a set of functional profiles, $E$ is a set of experiential values, $B:W\to F$ assigns behavior, $Q:W\to E$ assigns experience, and $q_0\in E$ is a distinguished void value.

Only the distinction between void and nonvoid is needed for the principal results. No metric, order, or algebraic operation on $E$ is assumed.

**Definition 2.2 (Functional twins).** Worlds $x,y\in W$ are functional twins when

$$
B(x)=B(y).
$$

This relation is an equivalence relation because equality in $F$ is reflexive, symmetric, and transitive.

**Definition 2.3 (Conscious world).** A world $x\in W$ is conscious, in the minimal sense used here, when

$$
Q(x)\ne q_0.
$$

This definition should be read as “experientially nonvoid.” It does not purport to analyze phenomenal character.

**Definition 2.4 (Zombie twin and zombie witness).** A world $z$ is a zombie twin of $x$ when

$$
B(z)=B(x) \quad\text{and}\quad Q(z)=q_0.
$$

A zombie witness is an ordered pair $(x,z)$ such that $Q(x)\ne q_0$, $Q(z)=q_0$, and $B(x)=B(z)$.

**Lemma 2.5 (Hidden contrast).** If $x$ is conscious and $z$ is a zombie twin of $x$, then $x$ and $z$ are functional twins but have different experiential values.

**Proof sketch.** Functional twinning is part of the definition. If $Q(x)=Q(z)$, then $Q(z)=q_0$ would imply $Q(x)=q_0$, contradicting consciousness. Hence $Q(x)\ne Q(z)$. $\square$

The lemma isolates the gap as a failure of the behavioral map $B$ to separate worlds that the experiential map $Q$ separates.

## 3. The conservative two-sheeted extension

### 3.1 Construction

Given any experience model $\mathcal M$, define its two-sheeted extension $\widehat{\mathcal M}$ as follows. The new world set is

$$
\widehat W=W\times\{0,1\}.
$$

The functional-profile set remains $F$. The experiential set is enlarged to $E\sqcup\{\bot\}$, where $\bot$ is a fresh void symbol not equal to any embedded element of $E$. Define

$$
\widehat B(x,b)=B(x)
$$

and

$$
\widehat Q(x,b)=
\begin{cases}
\iota(Q(x)),&b=1,\\
\bot,&b=0,
\end{cases}
$$

where $\iota:E\to E\sqcup\{\bot\}$ is the inclusion. The new void value is $\bot$.

For each $x\in W$, call $(x,1)$ its **retained copy** and $(x,0)$ its **void copy**.

**Theorem 3.1 (Conservative Zombie Extension).** For every experience model $\mathcal M$ and every world $x\in W$, the retained copy $(x,1)$ is conscious in $\widehat{\mathcal M}$, the void copy $(x,0)$ is its zombie twin, and both copies have functional profile $B(x)$. In particular,

$$
\widehat B(x,1)=B(x)=\widehat B(x,0)
$$

while

$$
\widehat Q(x,1)\ne\widehat Q(x,0).
$$

**Proof sketch.** The behavioral equalities follow immediately because $\widehat B$ ignores the sheet coordinate. The retained experience $\iota(Q(x))$ lies in the $E$ component of the disjoint union and therefore differs from $\bot$. The void copy has experience $\bot$ by definition. Thus the retained copy is conscious, the void copy is void, and they are functional twins. $\square$

The word “conservative” refers to preservation of functional data: the map $x\mapsto(x,1)$ preserves every original profile exactly. The construction adds a hidden coordinate but changes no value of the old behavior map.

### 3.2 Invariance of purely functional predicates

A purely functional criterion is any predicate $P:F\to\{\mathrm{false},\mathrm{true}\}$. It may be arbitrarily complicated; it may refer to computation, reportability, causal organization, or an information-theoretic score, provided its input is only the functional profile.

**Corollary 3.2 (Functional Predicate Transfer).** Let $P$ be any predicate on functional profiles. For every $x\in W$,

$$
P(\widehat B(x,1))\iff P(\widehat B(x,0)).
$$

Therefore, if the retained copy satisfies a proposed purely functional definition of consciousness, then its void twin satisfies that definition as well.

**Proof sketch.** Both arguments of $P$ equal $B(x)$. Substitution into equal inputs gives equal truth values. $\square$

This is a theorem about the expressive limit of a chosen vocabulary. It does not show that experience is physically independent of function. It shows that independence remains compatible with any description that omits the experiential coordinate.

### 3.3 The necessary boundary

The extension theorem must not be confused with an assertion that every original model already contains a zombie witness.

**Example 3.3 (All-void singleton).** Let $W=F=E=\{*\}$, set $B(*)=*$ and $Q(*)=q_0=*$. Then no world is conscious, so no zombie witness exists.

**Theorem 3.4 (Failure of the unconditional existence claim).** There is an experience model with no zombie witness.

**Proof sketch.** Use the all-void singleton. A zombie witness requires a conscious first component, but the unique world has void experience. $\square$

The correct universal result is therefore modal and constructive: every model **admits an extension** with zombie witnesses. It is not categorical in the colloquial sense that every model **contains** them already.

## 4. Canonical classification and semantic gaps

### 4.1 The canonical two-point fiber

Let $X$ be any set of functional profiles. Define the canonical experience model by

$$
W_X=X\times\{0,1\},\qquad F_X=X,
$$

with $B_X(x,b)=x$. Let the experiential set consist of a single present marker $\star$ together with a void marker $\bot$, and define

$$
Q_X(x,1)=\star,\qquad Q_X(x,0)=\bot.
$$

There is a canonical zombie witness over each $x\in X$, namely

$$
((x,1),(x,0)).
$$

**Theorem 4.1 (Classification of Canonical Zombie Witnesses).** The map

$$
x\longmapsto((x,1),(x,0))
$$

is a bijection from $X$ to the set $Z_X$ of zombie witnesses in the canonical experience model.

**Proof sketch.** The displayed pair is a witness because both worlds project to $x$, the first is present, and the second is void. Conversely, let $((x,b),(y,c))$ be any witness. Consciousness of the first forces $b=1$; voidness of the second forces $c=0$; functional equality forces $x=y$. Hence the witness is uniquely $((x,1),(x,0))$. Reading its profile gives the inverse map. $\square$

Thus each profile indexes exactly one minimal experiential gap.

### 4.2 Semantic systems

**Definition 4.2 (Semantic system).** A semantic system on a set $C$ of codes consists of an acceptance predicate $A:C\to\{\mathrm{false},\mathrm{true}\}$ and a truth predicate $T:C\to\{\mathrm{false},\mathrm{true}\}$. It is **sound** when

$$
A(c)\Longrightarrow T(c)
$$

for every $c\in C$.

**Definition 4.3 (Semantic-gap witness).** A semantic-gap witness is a code $c$ satisfying

$$
T(c)\quad\text{and}\quad \neg A(c).
$$

For the same profile set $X$, define the canonical semantic system on $C_X=X\times\{0,1\}$. Declare every code true, and accept exactly the codes on the $1$-sheet:

$$
T_X(x,b)=\mathrm{true},\qquad A_X(x,b)\iff b=1.
$$

**Lemma 4.4 (Soundness and omission).** The canonical semantic system is sound, and for every $x\in X$, the code $(x,0)$ is true but unaccepted.

**Proof sketch.** Soundness is immediate because every code is true. The code $(x,0)$ is true by definition and fails the acceptance condition $0=1$. $\square$

**Theorem 4.5 (Classification of Canonical Semantic Gaps).** The map

$$
x\longmapsto(x,0)
$$

is a bijection from $X$ to the set $G_X$ of semantic-gap witnesses.

**Proof sketch.** Every $(x,0)$ is a gap witness. Conversely, if $(x,b)$ is unaccepted, then $b\ne1$, and because $b$ is Boolean, $b=0$. Reading the first coordinate is inverse to the displayed map. $\square$

### 4.3 Exact correspondence

**Theorem 4.6 (Zombie–Semantic Gap Isomorphism).** For every profile set $X$, there is a canonical bijection

$$
Z_X\cong G_X.
$$

It sends the unique zombie witness over $x$ to the true but unaccepted code $(x,0)$.

**Proof sketch.** By Theorem 4.1, $Z_X\cong X$. By Theorem 4.5, $X\cong G_X$. Compose these bijections. Explicitly, read the common profile $x$ from a zombie witness and output $(x,0)$. The inverse reads $x$ from a semantic gap and returns $((x,1),(x,0))$. The classification theorems prove that both composites are identities. $\square$

The theorem gives an exact sense in which the two gaps are structurally identical: both witness spaces are classified by the same base $X$, and both arise from a two-sheeted construction. It is appropriately described as an incompleteness analogy only at this abstract semantic level. No arithmetic coding, diagonal lemma, or claim about human mathematical cognition is assumed.

**Theorem 4.7 (No Unconditional Gap Isomorphism).** There is no general bijection between the zombie witnesses of an arbitrary experience model and the semantic-gap witnesses of the canonical one-profile semantic system.

**Proof sketch.** The all-void singleton experience model has no zombie witnesses, while the canonical semantic system over the singleton profile set has the witness $(*,0)$. An empty set cannot be bijective with a nonempty set. $\square$

This boundary theorem prevents the guarded canonical correspondence from being promoted to an unrestricted metaphysical identity.

## 5. Integrated information as a finite variational invariant

### 5.1 Cuts and effective information

Let a finite system have components indexed by

$$
V_n=\{0,1,\ldots,n-1\}.
$$

A candidate nontrivial cut is represented by a subset $A\subseteq V_n$ satisfying

$$
A\ne\varnothing \quad\text{and}\quad A\ne V_n.
$$

The complementary side is determined by $A$, so no second subset is required. This representation counts both $A$ and its complement unless a symmetry convention is added; the minimum results below do not require such a convention.

**Lemma 5.1 (Cut Landscape Boundary).** If $n\ge2$, the set of nontrivial cuts is nonempty. If $n\le1$, it is empty.

**Proof sketch.** For $n\ge2$, the singleton $\{0\}$ is nonempty and proper. For $n=0$, there is no nonempty subset. For $n=1$, the only subsets are empty and the whole set. $\square$

An effective-information landscape is a function

$$
I:\{A\subseteq V_n: \varnothing\ne A\ne V_n\}\to\mathbb R_{\ge0}.
$$

For $n\ge2$, define integrated information by

$$
\Phi(I)=\min_{\varnothing\ne A\subsetneq V_n} I(A).
$$

A minimizing cut is called a minimum-information partition.

### 5.2 Structural theorems

**Theorem 5.2 (Existence of a Minimum-Information Partition).** For every finite system with $n\ge2$, there exists a nontrivial cut $A_*$ such that

$$
I(A_*)=\Phi(I).
$$

**Proof sketch.** By Lemma 5.1 the candidate set is nonempty, and it is finite because $V_n$ is finite. A real-valued function on a finite nonempty set attains its minimum. $\square$

**Theorem 5.3 (Greatest-Lower-Bound Characterization).** For every candidate cut $A$,

$$
\Phi(I)\le I(A).
$$

Moreover, if $c\le I(A)$ for every candidate cut $A$, then

$$
c\le\Phi(I).
$$

**Proof sketch.** The first statement is the defining property of a minimum. For the second, choose a minimizing cut $A_*$. The common lower-bound hypothesis gives $c\le I(A_*)=\Phi(I)$. $\square$

**Corollary 5.4 (Nonnegativity).** Integrated information satisfies

$$
\Phi(I)\ge0.
$$

**Proof sketch.** Zero is a common lower bound because every $I(A)$ is nonnegative. Apply Theorem 5.3. $\square$

**Theorem 5.5 (Reducibility Criterion).** For $n\ge2$,

$$
\Phi(I)=0
\quad\Longleftrightarrow\quad
\exists A\text{ nontrivial with }I(A)=0.
$$

**Proof sketch.** If $\Phi(I)=0$, a minimizing cut has value zero by Theorem 5.2. Conversely, if $I(A)=0$, then $0\le\Phi(I)\le I(A)=0$, so $\Phi(I)=0$. $\square$

**Theorem 5.6 (Monotonicity).** Let $I_S$ and $I_T$ be two effective-information landscapes on the same cuts. If

$$
I_S(A)\le I_T(A)
$$

for every candidate cut $A$, then

$$
\Phi(I_S)\le\Phi(I_T).
$$

**Proof sketch.** Let $A_T$ minimize $I_T$. Then

$$
\Phi(I_S)\le I_S(A_T)\le I_T(A_T)=\Phi(I_T).
$$

$\square$

**Theorem 5.7 (Equality at a Common Minimizer).** Suppose a cut $A_0$ minimizes both $I_S$ and $I_T$, and suppose

$$
I_S(A_0)=I_T(A_0).
$$

Then

$$
\Phi(I_S)=\Phi(I_T).
$$

**Proof sketch.** Since $A_0$ minimizes each landscape, $\Phi(I_S)=I_S(A_0)$ and $\Phi(I_T)=I_T(A_0)$. Apply the assumed equality. $\square$

### 5.3 Orthogonality to the hidden experiential fiber

**Theorem 5.8 (Coexistence of Functional Minima and Experiential Gaps).** Let $n\ge2$ and let $I$ be any nonnegative effective-information landscape. For every chosen profile $x\in X$, there simultaneously exist a minimum-information partition, a canonical zombie witness over $x$, and a canonical true but unaccepted semantic code over $x$.

**Proof sketch.** The minimum-information partition exists by Theorem 5.2. The witness $((x,1),(x,0))$ exists by the canonical experience construction, and $(x,0)$ is a semantic-gap witness by Lemma 4.4. These constructions share no dependent parameter beyond the chosen profile, so they coexist. $\square$

The theorem is deliberately a coexistence result, not a causal claim. The cut landscape is functional data; the sheet coordinate is hidden from it. Any theorem identifying $\Phi$ with experience would require an additional bridge principle.

## 6. Memory editing as algebraic quotienting

### 6.1 Streams and compositional memory

Let $\Sigma$ be a nonempty alphabet of event symbols. Write $\Sigma^*$ for all finite words over $\Sigma$, including the empty word $\varepsilon$. Concatenation makes $\Sigma^*$ a monoid:

$$
(uv)w=u(vw),\qquad \varepsilon u=u=u\varepsilon.
$$

Let $R$ be a monoid of memory representations with operation written multiplicatively and identity $1_R$.

**Definition 6.1 (Compositional memory).** A compositional memory is a monoid homomorphism

$$
m:\Sigma^*\to R,
$$

meaning

$$
m(uv)=m(u)m(v),\qquad m(\varepsilon)=1_R.
$$

**Definition 6.2 (Memory indistinguishability).** Define

$$
u\sim_m v \quad\Longleftrightarrow\quad m(u)=m(v).
$$

This is an equivalence relation compatible with concatenation: if $u\sim_m u'$ and $v\sim_m v'$, then $uv\sim_m u'v'$.

**Definition 6.3 (Erased streams).** The erased language is

$$
K_m=\{u\in\Sigma^*:m(u)=1_R\}.
$$

### 6.2 Finite memory loss

**Theorem 6.4 (Finite Memory Loss).** If $\Sigma$ is nonempty and $R$ is finite, then every compositional memory $m:\Sigma^*\to R$ identifies two distinct streams. That is, there exist $u\ne v$ with

$$
m(u)=m(v).
$$

**Proof sketch.** Choose a symbol $a\in\Sigma$. The words

$$
\varepsilon,a,a^2,a^3,\ldots
$$

are all distinct, so $\Sigma^*$ is infinite. A map from an infinite set to the finite set $R$ cannot be injective. Hence two distinct streams have the same memory. $\square$

The theorem uses finiteness, not compositionality, to force a collision. Compositionality supplies the stronger algebraic conclusions that follow.

**Lemma 6.5 (Erased Streams Form a Submonoid).** The set $K_m$ contains $\varepsilon$ and is closed under concatenation.

**Proof sketch.** Homomorphism preservation of identities gives $m(\varepsilon)=1_R$, so $\varepsilon\in K_m$. If $u,v\in K_m$, then

$$
m(uv)=m(u)m(v)=1_R1_R=1_R,
$$

so $uv\in K_m$. $\square$

### 6.3 Observable memory as a quotient

Because $\sim_m$ respects concatenation, equivalence classes can themselves be multiplied by

$$
[u][v]=[uv].
$$

Let $\Sigma^*/{\sim_m}$ denote this quotient monoid, and let $\operatorname{im}(m)$ denote the reachable memory states.

**Theorem 6.6 (Memory Quotient Theorem).** The map

$$
\Theta:\Sigma^*/{\sim_m}\to\operatorname{im}(m),
\qquad
\Theta([u])=m(u),
$$

is a monoid isomorphism.

**Proof sketch.** The map is well-defined because equivalent words have equal memories. It preserves multiplication since

$$
\Theta([u][v])=m(uv)=m(u)m(v)=\Theta([u])\Theta([v]).
$$

It is surjective by the definition of the image. It is injective because $\Theta([u])=\Theta([v])$ means $m(u)=m(v)$, hence $u\sim_m v$ and $[u]=[v]$. $\square$

This result identifies observable memory not merely with a subset of representations but with a canonical quotient of histories. Every distinction lost by $m$ is collapsed, and no additional distinction is collapsed.

### 6.4 Targeted forgetting and universality

Let $r:\Sigma\to\{0,1\}$ indicate which symbols are retained. Define $f_r:\Sigma^*\to\Sigma^*$ by replacing each letter $a$ with $a$ when $r(a)=1$ and with $\varepsilon$ when $r(a)=0$, then concatenating the results. Equivalently, $f_r$ deletes precisely the unretained symbols.

**Lemma 6.7 (Forgotten Symbols Are Erased).** If $r(a)=0$, then

$$
f_r(a)=\varepsilon,
$$

so the one-letter stream $a$ belongs to $K_{f_r}$.

**Proof sketch.** This is the defining letter action of targeted forgetting. $\square$

**Theorem 6.8 (Universal Property of Targeted Forgetting).** Let $g:\Sigma^*\to S$ be any compositional map into a monoid $S$. Suppose

$$
f_r(u)=f_r(v)\Longrightarrow g(u)=g(v)
$$

for all streams $u,v$. Then there exists a unique monoid homomorphism

$$
\overline g:\Sigma^*/{\sim_{f_r}}\to S
$$

such that

$$
g=\overline g\circ q,
$$

where $q(u)=[u]$ is the quotient map.

**Proof sketch.** Define $\overline g([u])=g(u)$. The hypothesis makes this independent of the representative. Multiplicativity follows from that of $g$. The factorization equation is immediate. For uniqueness, every quotient class has the form $[u]$, so any factorizing map must send it to $g(u)$. $\square$

**Corollary 6.9 (Targeted Forgetting Quotient).** The quotient by targeted-forgetting indistinguishability is isomorphic to the submonoid of retained-output streams reachable under $f_r$.

**Proof sketch.** Apply Theorem 6.6 to $f_r$. $\square$

The universal property gives a precise meaning to “the information intentionally removed.” Every downstream compositional observer that is insensitive to at least those distinctions must operate through the same quotient.

## 7. Algorithms and computational complexity

The mathematical results suggest three finite procedures.

### 7.1 Constructing the canonical gap correspondence

For a finite profile list $X=(x_1,\ldots,x_N)$, output for each $x_i$ the zombie witness $((x_i,1),(x_i,0))$ and semantic witness $(x_i,0)$. The procedure takes $O(N)$ time and $O(N)$ output space. Validation is constant-time per item when profile equality and Boolean operations are constant-time.

### 7.2 Exhaustive minimum-information search

For an $n$-component system, enumerate all nonempty proper subsets and evaluate $I$. There are $2^n-2$ represented cuts. If one evaluation costs $C_I(n)$, exhaustive search takes

$$
O(2^n C_I(n))
$$

time and $O(n)$ auxiliary space when subsets are streamed as bit masks. If complementary cuts are known to have equal values, one may impose a canonical representative and roughly halve the search, but this symmetry is not needed for correctness.

The algorithm must reject $n<2$, because the candidate set is empty. It returns both $\Phi$ and an attaining cut, directly realizing Theorem 5.2.

### 7.3 Collision search for finite memory

Given a finite collection of streams and a memory function, store the first stream observed for each memory state. When a later distinct stream has the same state, return the pair. With hashing, expected time is linear in the number of tested streams and storage is at most the smaller of the number of streams and the number of memory states. When the domain enumeration contains more distinct streams than memory states, the pigeonhole principle guarantees success.

For targeted forgetting, one can additionally group words by their retained output. Each group is an explicit indistinguishability class, and the set of outputs realizes the quotient representatives.

## 8. Applications

### 8.1 Consciousness theory

The conservative extension theorem is a diagnostic for functional definitions. If a proposed consciousness criterion is literally a predicate of functional profile, it is invariant along every fiber of $B$. The theorem exposes the need for one of two responses: either identify experience with a functional property by an added bridge principle, or admit that the functional vocabulary leaves experience underdetermined.

The result does not favor substance dualism, physicalism, or any empirical theory by itself. Its role is logical bookkeeping: it distinguishes data encoded in the functional map from data encoded only in the experiential map.

### 8.2 Interpreting integrated information

The finite variational theory shows exactly what follows from defining $\Phi$ as a minimum. Existence, nonnegativity, reducibility, and monotonicity are robust mathematical consequences. None alone implies that $\Phi$ measures subjective experience. The coexistence theorem makes this separation explicit: a complete cut landscape may be held fixed while a Boolean experiential sheet varies above the same functional profile.

This does not diminish the value of $\Phi$ as a functional invariant. It clarifies the extra empirical or metaphysical premise required to interpret it experientially.

### 8.3 Memory, compression, and lossy representation

Finite-state memories, automata, and compressed logs inevitably merge histories. The quotient theorem provides the correct algebraic object for analyzing what remains observable. Its use extends to event filtering, privacy-preserving telemetry, sequence abstraction, and state minimization. The kernel congruence records precisely which histories become interchangeable.

Targeted forgetting is especially relevant when deletion rules are declared in advance. The universal property ensures that any later process respecting those deletions depends only on the quotient class, not on inaccessible details of the original stream.

### 8.4 A common fiber perspective

All applications can be summarized by a map $p:Y\to X$. For $x\in X$, the fiber

$$
p^{-1}(x)=\{y\in Y:p(y)=x\}
$$

collects hidden alternatives compatible with the same observable value. The canonical consciousness model has two-element fibers. The semantic model has an accepted and an omitted sheet above each profile. A finite memory has at least one fiber containing multiple histories. Integrated information lives on the functional base and is unchanged by multiplying the hidden fiber unless the theory explicitly couples them.

## 9. Limitations and discussion

First, the experiential theory is intentionally minimal. It distinguishes presence from void but does not model similarity, intensity, unity, temporal flow, or qualitative content. Richer fibers may carry geometry, probability, or algebra.

Second, the zombie extension is a model construction, not evidence of physical realizability. It proves compatibility with a functional description. Whether laws of nature identify or constrain the hidden coordinate is an empirical and metaphysical question outside the assumptions.

Third, the semantic system is abstract. Its true-but-unaccepted codes exhibit the shape of an incompleteness gap, but the construction is not an arithmetization theorem. The exact correspondence rests on common two-sheeted indexing, and Theorem 4.7 shows why it cannot be made unconditional.

Fourth, the integrated-information framework assumes finitely many components, nonnegative cut values, and $n\ge2$. It does not choose a physical formula for effective information. For $n\le1$, the nontrivial cut landscape is empty, so the stated definition of $\Phi$ has no value.

Fifth, the finite-memory collision theorem guarantees some indistinguishable pair but does not identify which pair without an enumeration or additional structure. The quotient theorem applies to compositional memory; an arbitrary noncompositional recorder still has collisions when finite but need not induce a congruence compatible with concatenation.

These limitations are informative. They locate exactly which conclusions are structural and which require domain-specific assumptions.

## 10. Future work

Several extensions are natural. The profile-indexed zombie and semantic constructions suggest a categorical treatment in which profile-preserving maps induce maps between witness spaces and the pointwise bijections become a natural isomorphism. Finite models with exactly one conscious and one void world per fiber should admit a classification by the canonical two-sheeted form.

Probability would add a quantitative layer. For finite worlds, the conditional entropy of experience given function should vanish exactly when experience is determined by behavior; positive entropy should measure residual experiential multiplicity. This would generalize the Boolean fiber from a qualitative witness to a numerical invariant.

The independence of integrated information from hidden sheets can be tested for $k$-sheeted extensions. If cut values depend only on function, adding any finite number of experiential alternatives over each functional state leaves the entire cut landscape unchanged. Conversely, a proposed bridge from $\Phi$ to experience should state precisely how cut data constrains fiber structure.

For memory, one may investigate minimal finite representations, rates of collision, probabilistic forgetting, and the interaction between semantic relevance and algebraic congruence. The universal property suggests compositional pipelines in which privacy or abstraction guarantees propagate automatically through every factorizing observer.

## 11. Conclusion

A functional description is a map, and every map invites a question about its fibers. The conservative zombie extension places a present and a void state in the same functional fiber. The canonical semantic construction places an accepted and an omitted true code over the same profile. Finite memory places distinct histories in the same representational fiber. Integrated information optimizes over the functional base but, without an added bridge, cannot inspect an orthogonal experiential sheet.

The central conclusions are therefore precise and bounded. Purely functional predicates cannot distinguish worlds with identical functional profiles. Every experience model admits a function-preserving two-sheeted extension with an experiential contrast. Canonical zombie and semantic gaps are classified by the same profile set and are consequently isomorphic. This isomorphism is not universal. Finite integrated information is an attained, nonnegative minimum with clear order properties. Finite compositional memory necessarily loses distinctions, and its observable algebra is exactly a quotient of stream histories.

The unifying mathematical lesson is simple: when an observable description appears complete, inspect the map that produced it. What lies in a common fiber may be invisible downstairs without being absent upstairs.
