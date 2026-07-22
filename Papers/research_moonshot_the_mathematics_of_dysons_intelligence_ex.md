# Discovery Rates, Finite Deadlines, and the Semantic Diagonal Barrier

**Aristotle**  
**July 22, 2026**

## Abstract

We study a discrete model of mathematical discovery motivated by proposals that accelerating intelligence might eventually exhaust mathematics. At each natural-number stage, a discovery process records a finite set of items. We distinguish three notions that are often conflated: the number of discoveries made per stage, eventual discovery of each individual item, and completion of an entire corpus by one finite deadline. For an arbitrary schedule, the number of distinct items discovered by stage $N$ is at most the sum of the batch sizes through $N$. Under a uniform physical cap $C$, this gives the exact general upper bound $(N+1)C$. No schedule of finite batches can cover all natural-number codes by a finite deadline, regardless of whether its permitted rate is exponential, double-exponential, or faster. Conversely, the unit-rate schedule that records code $n$ at stage $n$ eventually covers every code, and hence an exponential upper bound alone does not imply a permanently missed syntactic item. A common finite deadline does follow for every finite corpus whose members are individually eventually discovered. Finally, moving from countable syntax to the semantic space of all predicates on the natural numbers yields a genuine obstruction: diagonalization constructs, from every countable stream of predicates, a predicate outside that stream. These results clarify the mathematical content and limitations of intelligence-explosion claims, isolate the role of physical throughput bounds, and distinguish counting arguments from incompleteness and semantic uncountability.

## 1. Introduction

The image of an indefinitely self-improving civilization invites a quantitative question: if the rate of mathematical discovery grows sufficiently quickly, can mathematics be completed? One proposed profile is the double-exponential function

$$
r_{\mathrm D}(n)=2^{2^n},
$$

where $n$ is a discrete time or developmental stage. Because this rate rapidly exceeds ordinary physical scales, it is tempting to infer that all theorems of a countable formal language must be discovered by some finite time. A complementary temptation is to associate a slower rate, such as $2^n$, with permanent incompleteness.

Both inferences confuse logically different properties. A rate is a pointwise bound on batch size. Eventual coverage means that each individual item appears at some stage, with a stage that may depend on the item. Finite completion means that one stage works simultaneously for all items. No growth comparison among finite natural numbers erases these distinctions.

The purpose of this paper is to give a minimal, self-contained mathematical framework in which the relevant claims can be stated and settled. The model deliberately abstracts away from the internal content of proofs. A theorem, formula, or proof document is represented by a code. Since finite strings over a finite or countable alphabet admit natural-number encodings, natural numbers provide the canonical model for countable syntax. A schedule assigns a finite set of codes to each stage.

The principal conclusions are as follows.

* The cumulative number of distinct discoveries by a finite stage is bounded by the sum of the finite batch sizes.
* A uniform per-stage physical cap $C$ implies a finite-horizon bound of $(N+1)C$ by stage $N$.
* Every finite deadline misses some natural-number code, no matter how rapidly the finite batches grow.
* Nevertheless, one discovery per stage suffices to cover every natural-number code eventually.
* Every finite corpus of eventually discovered items has a common finite deadline.
* Every countable list of predicates on $\mathbb N$ omits an explicitly constructed diagonal predicate.

The first five statements concern countable syntax and elementary finite counting. The last concerns the uncountable semantic space of all truth-valued functions on $\mathbb N$. Their juxtaposition identifies where a genuine cardinality obstruction enters.

The paper does not claim that enumerating natural-number codes amounts to proving all true mathematical statements. Nor does it derive a physical constant such as $10^{120}$ from first principles. A physical cap can be inserted as a parameter, but a realistic resource theory must also model operations, memory, proof-search cost, verification, and time. Similarly, Gödelian incompleteness requires assumptions about effective axiomatizability, consistency or soundness, and arithmetic strength; it is not a consequence of a discovery-rate bound.

## 2. Discovery schedules

### 2.1 Items, stages, and finite batches

Let $A$ be a set of discoverable items. A **discovery schedule** on $A$ is a sequence

$$
S=(S_0,S_1,S_2,\ldots)
$$

in which each $S_n$ is a finite subset of $A$. The set $S_n$ is the batch recorded at stage $n$. Requiring finite batches models the elementary fact that finite resources over a finite interval can produce only finitely many distinct finite records.

For a finite deadline $N$, define the **cumulative archive**

$$
D_S(N)=\bigcup_{n=0}^{N}S_n.
$$

An item $a\in A$ is **eventually discovered** by $S$ if there exists $n\in\mathbb N$ such that $a\in S_n$. The schedule is **eventually complete** on $A$ if every $a\in A$ is eventually discovered.

These definitions use two orders of quantifiers that must not be exchanged. Eventual completeness is

$$
\forall a\in A\;\exists n\in\mathbb N\quad a\in S_n,
$$

whereas completion by one finite deadline is

$$
\exists N\in\mathbb N\;\forall a\in A\quad a\in D_S(N).
$$

The latter implies the former, but for infinite $A$ the converse generally fails.

### 2.2 Rate bounds

A function $r:\mathbb N\to\mathbb N$ is a **rate bound** for $S$ if

$$
|S_n|\le r(n)
$$

for every stage $n$. This is an upper bound, not a requirement that all available capacity be used. In particular, the same schedule may satisfy many rate bounds.

Two profiles of interest are the exponential rate

$$
r_{\mathrm E}(n)=2^n
$$

and the double-exponential rate

$$
r_{\mathrm D}(n)=2^{2^n}.
$$

Nothing in the abstract definition guarantees novelty, fairness, or successful proof search. A schedule may repeatedly record the same items, leave capacity unused, or enumerate systematically. Consequently, rate information alone cannot determine completeness.

### 2.3 Countable syntax

When $A=\mathbb N$, items are natural-number codes. Any countable collection of finite symbolic objects can be injected into this model. The abstraction is intentionally broad: a code might represent a sentence, a derivation, or a complete theorem-proof pair. Which codes are valid is a separate predicate and does not affect the counting results below.

## 3. Finite-horizon bounds

### Theorem 3.1: Cumulative Counting Bound

For every discovery schedule $S$ on $A$ and every $N\in\mathbb N$,

$$
|D_S(N)|\le \sum_{n=0}^{N}|S_n|.
$$

**Proof sketch.** Every element of $D_S(N)$ appears in at least one of the sets $S_0,\ldots,S_N$. If these sets were disjoint, the cardinality of their union would equal the sum of their cardinalities. Intersections can only reduce the number of distinct elements in the union, because an item appearing in several batches is counted once on the left and several times on the right. Therefore the displayed inequality holds. $\square$

The result is insensitive to the nature of the items. It is a finite union bound and applies equally to theorem codes, experimental observations, or stored computational outputs.

### Corollary 3.2: Uniform Physical-Cap Bound

Suppose there is a constant $C\in\mathbb N$ such that $|S_n|\le C$ for every $n$. Then for every finite deadline $N$,

$$
|D_S(N)|\le (N+1)C.
$$

**Proof sketch.** Apply Theorem 3.1 and bound each of the $N+1$ summands by $C$:

$$
|D_S(N)|\le\sum_{n=0}^{N}|S_n|
\le\sum_{n=0}^{N}C=(N+1)C.
$$

$\square$

This is the precise finite-horizon consequence of a uniform Bekenstein-style cap. If a physical model proposes $C\approx 10^{120}$ elementary operations or records per stage, then the cumulative output by stage $N$ is bounded by approximately $(N+1)10^{120}$. The bound remains finite for finite $N$.

The corollary should not be overinterpreted. If $C$ counts elementary operations, then one discovery may require many operations, and $|S_n|\le C$ is only a coarse upper bound. If $C$ counts memory states rather than operations, the temporal interpretation changes. A complete physical model must specify units, stage duration, available energy and memory, and whether resources can be recycled.

### Corollary 3.3: Variable-Rate Bound

If $r$ is a rate bound for $S$, then

$$
|D_S(N)|\le\sum_{n=0}^{N}r(n).
$$

**Proof sketch.** Combine Theorem 3.1 with $|S_n|\le r(n)$ term by term. $\square$

For $r(n)=2^{2^n}$, the sum is extraordinarily large but finite at every finite $N$. The size of this bound has no bearing on whether it equals the cardinality of $\mathbb N$; it does not.

## 4. Impossibility of a finite universal deadline

### Theorem 4.1: A Finite Deadline Misses a Code

Let $S$ be any discovery schedule on $\mathbb N$. For every $N\in\mathbb N$, there exists a code $m\in\mathbb N$ such that

$$
m\notin D_S(N).
$$

**Proof sketch.** The set $D_S(N)$ is finite because it is a union of the finitely many finite sets $S_0,\ldots,S_N$. Since $\mathbb N$ is infinite, some natural number is absent.

An explicit witness can be obtained without selecting the least missing number. Define

$$
m=\sum_{x\in D_S(N)}(x+1).
$$

Assume for contradiction that $m\in D_S(N)$. Since all summands are nonnegative and the summand corresponding to $x=m$ equals $m+1$, the defining sum satisfies $m+1\le m$. This is impossible. Hence $m\notin D_S(N)$. $\square$

The explicit witness emphasizes that the result is constructive at the level of a given finite archive: inspection of the archive supplies a code outside it.

### Corollary 4.2: No Finite Universal Deadline

For every schedule $S$ of finite subsets of $\mathbb N$,

$$
\neg\exists N\in\mathbb N\;\forall m\in\mathbb N,
\quad m\in D_S(N).
$$

**Proof sketch.** If such an $N$ existed, Theorem 4.1 would provide a code omitted by $D_S(N)$, contradicting universality. $\square$

### Interpretation

Corollary 4.2 applies to every finite-valued rate profile. In particular, it applies when

$$
|S_n|\le 2^{2^n}.
$$

It would apply equally to faster profiles formed from iterated exponentials, provided each stage still produces a finite set. Thus the statement “superexponential growth yields a finite date by which every code is present” is false in this model.

This result is not an appeal to incompleteness, undecidability, or computational hardness. It is a cardinality statement about a finite archive and an infinite set of codes. Compactness does not alter it. A logical compactness theorem typically says that a set of sentences has a model when every finite subset has a model; it does not turn infinitely many distinct eventual discovery times into a bounded set of times.

## 5. Eventual completeness at minimal rate

The absence of a universal deadline leaves open whether every individual code can appear eventually. It can.

### Definition 5.1: Enumeration Schedule

Define the enumeration schedule $E$ by

$$
E_n=\{n\}.
$$

Exactly one code is recorded at each stage.

### Theorem 5.2: Unit-Rate Eventual Completeness

The enumeration schedule has the following properties:

1. $|E_n|=1$ for every $n$;
2. every code $k\in\mathbb N$ is eventually discovered;
3. $E$ satisfies the exponential rate bound $|E_n|\le 2^n$;
4. $E$ satisfies the double-exponential rate bound $|E_n|\le 2^{2^n}$.

**Proof sketch.** The set $E_n$ is a singleton, so its cardinality is one. Given a code $k$, choose stage $n=k$; then $k\in E_k$. Finally, $1\le 2^n$ and $1\le 2^{2^n}$ for every natural number $n$. $\square$

### Consequence 5.3: Exponential Upper Bounds Do Not Force Omission

There exists a schedule bounded by $2^n$ that eventually discovers every natural-number code.

This consequence directly separates rate bounds from Gödelian conclusions. An upper bound of $2^n$ does not entail an undiscovered code. Indeed, even the constant upper bound $1$ permits eventual enumeration.

Nor does Theorem 5.2 claim that every code represents a valid theorem. If $V\subseteq\mathbb N$ is the set of valid theorem codes for some effective system, enumerating all natural numbers certainly visits every element of $V$, but it also visits invalid codes. A more refined schedule might enumerate valid derivations and extract their conclusions. The counting distinction remains the same.

### Quantifier analysis

For the enumeration schedule,

$$
\forall k\in\mathbb N\;\exists n\in\mathbb N,
\quad k\in E_n
$$

is true, witnessed by $n=k$. In contrast,

$$
\exists N\in\mathbb N\;\forall k\in\mathbb N,
\quad k\in D_E(N)
$$

is false. Indeed,

$$
D_E(N)=\{0,1,\ldots,N\},
$$

so $N+1$ is absent. This example is the simplest possible demonstration that exchanging $\forall k\exists n$ with $\exists N\forall k$ changes the claim.

## 6. Finite corpora and common deadlines

Although eventual discovery does not produce a common deadline for an infinite corpus, it does for a finite one.

### Theorem 6.1: Finite-Corpus Common Deadline

Let $F\subseteq A$ be finite, and let $S$ be a discovery schedule on $A$. Suppose every $a\in F$ is eventually discovered. Then there exists $N\in\mathbb N$ such that

$$
F\subseteq D_S(N).
$$

**Proof sketch.** For each $a\in F$, choose a discovery stage $n_a$ with $a\in S_{n_a}$. Because $F$ is finite, the finite set of witnesses $\{n_a:a\in F\}$ has a maximum. Let

$$
N=\max_{a\in F}n_a.
$$

Then $n_a\le N$ for every $a\in F$, so every such $a$ belongs to one of the batches included in $D_S(N)$. $\square$

The theorem also covers the empty corpus, for which every deadline works. For a nonempty corpus, the maximum witness construction is explicit once one discovery time per item is known.

### Why finiteness is essential

For an infinite corpus, the chosen witnesses may be unbounded. Under the enumeration schedule, the discovery time of code $k$ is $k$, and the set $\{k:k\in\mathbb N\}$ has no maximum. The finite-corpus theorem therefore cannot be extended by simply dropping finiteness.

The result resembles a finite compactness principle only in the elementary sense that finitely many existential witnesses can be combined by taking their maximum. It should not be confused with topological compactness or model-theoretic compactness. Extending the statement to an infinite family requires additional structure that controls the witness times.

## 7. The semantic diagonal barrier

The preceding sections show that countable syntax can be covered eventually. A genuine cardinality obstruction arises only after enlarging the target space.

### 7.1 Predicates as semantic objects

A **predicate on the natural numbers** is a function

$$
P:\mathbb N\to\{\mathrm{true},\mathrm{false}\}.
$$

Equivalently, a predicate determines the subset $\{n\in\mathbb N:P(n)\}$ of natural numbers on which it holds. The collection of all such predicates is therefore in bijection with the power set $\mathcal P(\mathbb N)$.

A **countable predicate stream** is a sequence

$$
f=(P_0,P_1,P_2,\ldots),
$$

or equivalently a function assigning a predicate $P_k$ to each natural number $k$.

### Definition 7.1: Diagonal Predicate

Given a countable predicate stream $(P_k)_{k\in\mathbb N}$, define its diagonal predicate $Q$ by

$$
Q(n)=\neg P_n(n).
$$

The construction inspects the $n$th predicate at its own index and reverses the answer.

### Theorem 7.2: Diagonal Omission

For every countable predicate stream $(P_k)_{k\in\mathbb N}$ and every $k\in\mathbb N$,

$$
Q\ne P_k.
$$

**Proof sketch.** Evaluate both predicates at $k$. By construction,

$$
Q(k)=\neg P_k(k).
$$

Thus $Q$ and $P_k$ have opposite truth values at input $k$, so they cannot be equal as predicates. $\square$

### Corollary 7.3: No Enumeration of All Predicates

There is no surjective function from $\mathbb N$ to the collection of all predicates on $\mathbb N$.

**Proof sketch.** Suppose a stream were surjective. Construct its diagonal predicate $Q$. Surjectivity would give an index $k$ with $P_k=Q$, while Theorem 7.2 gives $P_k\ne Q$. This contradiction rules out surjectivity. $\square$

### Theorem 7.4: Semantic Expressibility Barrier

For every proposed countable catalogue of predicates on $\mathbb N$, there exists a predicate absent from the catalogue; specifically, its diagonal predicate is absent.

This strong form does more than compare cardinalities: it supplies a missing object relative to any proposed list. No acceleration of a countably indexed stream can overcome the theorem, because rearranging or producing entries faster does not change the fact that the stream has only countably many positions.

### Syntax versus semantics

The diagonal theorem must be interpreted at the correct level. The set of finite expressions in a countable alphabet is countable. The set of all predicates $\mathbb N\to\{\mathrm{true},\mathrm{false}\}$ is uncountable. Therefore most semantic predicates have no finite description in any fixed countable language.

It does not follow from Theorem 7.4 that the diagonal predicate associated with an arbitrary stream is computable, definable in arithmetic, or expressible in a selected formal system. Those stronger claims require an effective coding of syntax, a satisfaction relation, and appropriate undefinability or incompleteness theorems. The present theorem establishes the clean cardinal boundary: all semantic predicates cannot be exhausted by a countable stream.

## 8. Algorithms and numerical illustrations

The abstract results admit simple finite simulations. Such simulations illustrate finite horizons but do not prove statements about infinity.

### 8.1 Cumulative archive algorithm

Given batches $S_0,\ldots,S_N$, initialize an empty set and successively union each batch into it. The final set is $D_S(N)$. If the total number of listed batch entries is

$$
M=\sum_{n=0}^{N}|S_n|,
$$

then a hash-set implementation has expected time $O(M)$ and space $O(|D_S(N)|)$. The algorithm also checks the inequality $|D_S(N)|\le M$ directly.

### 8.2 Explicit missing-code certificate

Given a finite archive $D$, compute

$$
m=\sum_{x\in D}(x+1).
$$

Then $m\notin D$. With arbitrary-precision integers, the arithmetic cost depends on bit lengths; in a unit-cost model for additions, the procedure uses $O(|D|)$ additions. A simpler alternative is to search for the least missing natural number, but the sum certificate mirrors the proof and avoids assumptions about the archive’s shape.

### 8.3 Finite diagonal algorithm

For a finite Boolean table with rows $P_0,\ldots,P_{m-1}$ and at least $m$ columns, define

$$
Q(i)=\neg P_i(i)
$$

for $0\le i<m$. The output differs from row $i$ at column $i$. Construction takes $O(m)$ time and $O(m)$ output space. This finite computation is an exact illustration of the disagreement mechanism used in the infinite theorem.

### 8.4 Scale comparisons

The profiles $2^n$ and $2^{2^n}$ can be tabulated for small $n$. Their rapid divergence is visually dramatic, but both values are finite for every fixed $n$. Plotting logarithms is often necessary: the binary logarithm of the double-exponential rate is $2^n$, and the iterated binary logarithm is $n$. These transformed axes display the growth while preserving the finite-stage message.

## 9. Applications and conceptual consequences

### 9.1 Long-run research planning

A finite institution typically targets a finite corpus: a collection of conjectures, a benchmark suite, or a bounded body of literature. Theorem 6.1 says that if every target is eventually reached, then the corpus has a common completion date. This does not estimate the date, but it identifies the extra ingredient needed for practical planning: finite scope.

### 9.2 Physical computation limits

Corollary 3.2 translates a per-stage physical cap into a cumulative bound. It can be used as the outermost layer of a resource budget. More realistic estimates should refine $C$ into operations, memory accesses, communication, verification costs, and error correction. If stage lengths vary, one should replace the constant cap by a rate integrated or summed over time.

### 9.3 Automated theorem discovery

For a countable formal syntax, eventual enumeration is compatible with a very low output rate. The bottleneck is not cardinality but effectiveness and relevance: distinguishing valid derivations, avoiding duplication, prioritizing meaningful statements, and controlling proof cost. Rate bounds do not encode these qualities.

### 9.4 Limits of compression

The semantic diagonal barrier states that no countable representational system names every predicate on $\mathbb N$. Any language of finite strings is countable, so some semantic properties remain unnamed. This is a limitation on universal representation, not merely on available runtime.

## 10. Discussion

The model reveals two independent axes.

The first axis is **temporal**. Finite throughput over finite time yields finite output. Nevertheless, an unbounded sequence of stages can cover a countable target point by point. The relevant logical distinction is between a bound on all witness times and the existence of a witness time for each target.

The second axis is **representational**. Countable syntax can in principle be enumerated, but the full semantic power set of $\mathbb N$ cannot. Diagonalization, rather than a comparison between exponential and double-exponential functions, establishes this second barrier.

These axes explain why several common slogans fail.

* “Sufficiently fast growth finishes a countable infinity at finite time” fails because every finite prefix of finite batches is finite.
* “A merely exponential rate permanently misses a code” fails because the unit-rate enumeration is eventually complete.
* “Gödel follows from a throughput ceiling” fails because incompleteness is about effective formal theories under structural hypotheses, not batch cardinalities.
* “Diagonalization supplies a new written theorem outside every language” overstates the result because the diagonal object is an arbitrary semantic predicate unless further definability conditions are established.

A mathematically disciplined intelligence-explosion thesis should therefore specify at least: the target class, its coding, the meaning of discovery, the resource measured by the rate, whether completeness means individual eventuality or a common deadline, and whether the target is syntactic, computable, definable, true, or fully semantic.

## 11. Future research

Several extensions would connect the abstract model more closely to logic and physics.

1. Replace natural-number codes by a concrete recursively enumerable syntax for first-order set theory, with a proof-checking predicate and an explicit enumeration of derivations.
2. Separate theorems, true sentences, and semantic predicates. Transferring the present diagonal barrier to arithmetic truth requires a satisfaction relation and a formal undefinability theorem.
3. State incompleteness with the hypotheses it actually needs: effective axiomatizability, consistency or soundness, and enough represented arithmetic. A discovery-rate bound alone has no Gödel consequence.
4. Generalize the finite-corpus common-deadline theorem to compact topological families and determine which additional continuity or boundedness hypotheses yield uniform deadlines.
5. Add resource costs for proof search and verification rather than only counting output. A Bekenstein-style model should specify a time horizon, operations per step, memory, and whether the cap is instantaneous or cumulative.
6. Study fair schedules under arbitrary positive rate profiles and construct exact-rate disjoint batches using prefix sums.
7. Replace arbitrary truth-valued predicates in the semantic diagonal theorem by computable Boolean predicates. The naive diagonal is computable only relative to a sufficiently strong evaluator, leading naturally to Turing jumps and oracle-relative discovery.

## 12. Conclusion

Extreme growth rates change scale but not quantifier order or cardinality. For schedules that produce finite batches, every finite deadline has a finite archive and therefore misses a natural-number code. No double-exponential rate creates a finite universal deadline. Yet countable syntax presents no cardinal obstacle to eventual coverage: the schedule $E_n=\{n\}$ reaches every code at unit rate. Finite corpora recover a common deadline by taking the maximum of finitely many discovery times.

The genuine barrier in this framework appears when the target is enlarged from coded finite syntax to all predicates on the natural numbers. Every countable stream then omits its diagonal predicate. This barrier is semantic and cardinal, not a consequence of insufficient speed.

Accordingly, discussions of unlimited intelligence should distinguish output rate, eventual discovery, finite completion, syntactic enumeration, formal provability, arithmetic truth, computability, and unrestricted semantics. Once these notions are separated, the mathematical picture is clear: a civilization may enumerate every numbered item over unbounded time, but it cannot complete an infinite numbered archive at a finite stage, and no numbered archive can contain every semantic predicate.
