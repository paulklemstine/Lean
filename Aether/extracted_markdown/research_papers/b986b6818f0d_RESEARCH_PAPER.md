# The Observation Complexity Theorem: The Exact Query Cost of Indistinguishability

## Abstract

We determine the exact number of Boolean observations required to distinguish
every element of a finite set. An *observation system* of depth `n` on a finite
type `A` is a family of `n` Boolean predicates; it *distinguishes* `A` if the
induced map sending each element to its tuple of predicate values (its *profile*)
is injective. We prove that the minimum depth of a distinguishing system is exactly
`⌈log₂ |A|⌉`, the ceiling logarithm base two. The result has two halves that meet
at a single value: an information-theoretic **lower bound**, holding even for fully
*adaptive* systems (decision trees whose queries depend on previous answers), and a
matching **upper bound** realized by an explicit *static* (non-adaptive) system
built from binary encoding. The coincidence of these two bounds yields a precise
form of a folklore principle: **adaptivity provides no worst-case speedup** for the
distinguishability task. We package the result as the statement that `⌈log₂ |A|⌉`
is the least element of the set of achievable distinguishing depths, give the
concrete corollary that separating 100 elements costs exactly 7 observations, and
extend the lower bound to `k`-ary observations, where the cost becomes `⌈log_k |A|⌉`
for every `k ≥ 2`. All results have been formalized and machine-checked. We present
full mathematical statements, proof sketches, algorithms, applications, and open
directions.

**Keywords.** query complexity, decision trees, pigeonhole principle, information
theory, distinguishability, ceiling logarithm, adaptive vs. non-adaptive, Shannon
bound.

---

## 1. Introduction

A recurring question across information theory, database design, sensor placement,
and the analysis of search and sorting is the following: *given a finite universe
of possibilities, how many yes/no measurements are required so that no two
possibilities are confused?* This is the problem of **distinguishability** under a
budget of observations.

The problem decomposes naturally into two opposing questions. A **lower bound**
asks how many observations are *necessary*: a guarantee that *no* system below a
certain depth can succeed. An **upper bound** asks how many are *sufficient*: an
explicit construction achieving the task at a given depth. When the two coincide
they pin down the *exact complexity*.

A prior development established the one-sided counting law for this problem. It
proved that a system of `n` Boolean observations can separate at most `2^n`
elements (a pigeonhole bound), and that this bound is *achievable* on the special
type `Fin (2^n)` of size exactly `2^n`. It further extended the counting bound to
*adaptive* systems modeled as binary decision trees, showing adaptivity cannot
exceed the `2^n` count. What remained open was the **exact query complexity for an
arbitrary finite type**: a two-sided, tight statement valid for *every* `|A|`, not
only powers of two, identifying the precise minimal depth and confirming that
adaptivity yields no advantage.

This paper closes that gap. The central object is the **ceiling logarithm**
`clog₂ n = ⌈log₂ n⌉`, the least `k` with `n ≤ 2^k`, which turns out to be the exact
inverse of `n ↦ 2^n` on powers and is therefore the natural bridge between a
cardinality bound and a depth bound.

### 1.1 Contributions

1. **Lower bound, adaptive (Theorem 4.1, `distinguish_depth_ge_clog`).** Any
   adaptive observation system that distinguishes all of `A` has depth at least
   `clog₂ |A|`.
2. **Upper bound, static (Theorem 4.2, `exists_distinguishing_static`).** Every
   finite `A` admits a *static* observation system of depth exactly `clog₂ |A|`
   that distinguishes all of its elements.
3. **Exact complexity (Theorem 4.3, `min_distinguishing_depth`).** `clog₂ |A|` is
   the *least* depth admitting a distinguishing adaptive system. Adaptivity buys no
   worst-case speedup.
4. **Concrete corollary (Theorem 4.4).** Distinguishing the 100 elements of
   `Fin 100` costs exactly 7 observations.
5. **Generalization (Theorem 4.5, `generalized_observation_complexity`).** For
   observations valued in a `k`-element alphabet, the cost is at least `clog_k |A|`,
   sharp for `k ≥ 2`; the degenerate `k ≤ 1` case carries no discriminative power.

---

## 2. Preliminaries and definitions

Throughout, `A` is a finite type (a finite set) and `|A|` denotes its cardinality.
We write `Bool = {false, true}` and identify a tuple of `n` bits with a function
`Fin n → Bool`, where `Fin n = {0, 1, …, n−1}`.

### 2.1 The ceiling logarithm

**Definition 2.1 (Ceiling logarithm).** For a base `b ≥ 2` and `n ≥ 1`, the
*ceiling logarithm* `clog_b n` is the least `k ∈ ℕ` such that `n ≤ b^k`. By
convention `clog_b 0 = clog_b 1 = 0`, and `clog_b n = 0` whenever `b ≤ 1`.

The following two facts are the load-bearing arithmetic of the paper; both are
standard properties of the ceiling logarithm.

**Lemma 2.2 (clog is a right inverse of exponentiation on powers).** For `b ≥ 2`
and all `n ∈ ℕ`, `clog_b (b^n) = n`.

**Lemma 2.3 (clog upper-bounds the argument as an exponent).** For `b ≥ 2` and all
`n ∈ ℕ`, `n ≤ b^{clog_b n}`.

**Lemma 2.4 (Monotonicity).** For `b ≥ 2`, `clog_b` is monotone: `m ≤ n` implies
`clog_b m ≤ clog_b n`.

Together, Lemmas 2.2–2.4 say that `clog_b` is the *exact inverse* of `k ↦ b^k`
restricted to powers, and is monotone in general. This is precisely what lets us
transport a cardinality inequality `|A| ≤ b^n` into a depth inequality
`clog_b |A| ≤ n`, and back.

### 2.2 Static observation systems

**Definition 2.5 (Static observation system).** A *static observation system* of
depth `n` on `A`, written `ObsSys A n`, is a family of `n` Boolean predicates
`pred : Fin n → A → Bool`.

**Definition 2.6 (Profile and twins).** The *profile* of `a ∈ A` under a system `O`
is the bit-tuple `profile_O(a) : Fin n → Bool`, `i ↦ O.pred i a`. Two elements
`a, b` are *twins* (written `O.twins a b`) if `profile_O(a) = profile_O(b)`. The
system *distinguishes* `A` if `twins` implies equality — equivalently, if `profile`
is injective.

Twinhood is an equivalence relation (reflexive, symmetric, transitive by equality
of profiles), and the *observation quotient* `A / twins` is the set of profile
classes.

### 2.3 Adaptive observation systems

A static system asks a fixed list of questions. An adaptive system may choose its
next question based on the answers received so far. We model this as a binary
decision tree.

**Definition 2.7 (Adaptive observation system).** An *adaptive observation system*
of depth `n` on `A`, written `AdaptiveObs A n`, is a binary decision tree of height
`n`, defined inductively:
- `nil : AdaptiveObs A 0` — the empty tree (depth 0);
- `node p f : AdaptiveObs A (n+1)` — a tree that asks predicate `p : A → Bool` and,
  on answer `b ∈ Bool`, continues with the subtree `f b : AdaptiveObs A n`.

**Definition 2.8 (Transcript).** The *transcript* of `a ∈ A` under an adaptive
system `O`, `transcript_O(a) : Fin n → Bool`, is the length-`n` sequence of answers
obtained by running `O` on `a`. Formally:
- on `nil`, the transcript is the empty tuple;
- on `node p f`, the transcript of `a` is `(p a)` prepended to the transcript of
  `a` under the subtree `f (p a)`.

Two elements are *adaptive twins* if they have equal transcripts; the system
*distinguishes* `A` if `transcript` is injective.

**The key structural observation.** Although the *queries* of an adaptive system
are not fixed, the *transcript* of every element is still a member of `Fin n → Bool`,
a set of cardinality `2^n`. This is the precise sense in which "each query yields at
most one bit," and it is what forces adaptive systems to obey the same counting
floor as static ones.

### 2.4 The static–adaptive bridge

**Definition 2.9 (Static to adaptive).** Given a static system `O : ObsSys A n`,
define the history-independent adaptive system `ofStatic(O) : AdaptiveObs A n` that
asks `O.pred 0`, then `O.pred 1`, …, regardless of answers (each node's two
subtrees are identical).

**Lemma 2.10 (Transcript equals profile).** For every static `O` and every `a`,
`transcript_{ofStatic(O)}(a) = profile_O(a)`. Consequently `ofStatic(O)` and `O`
have identical twin relations: `ofStatic(O).twins a b ↔ O.twins a b`.

*Proof sketch.* Induction on `n`. The transcript of `ofStatic(O)` prepends
`O.pred 0 a` to the transcript of the depth-`(n−1)` shifted system, which by the
inductive hypothesis equals the profile `i ↦ O.pred (i+1) a`. Reassembling via the
cons/head–tail identity for tuples gives `i ↦ O.pred i a = profile_O(a)`. ∎

Lemma 2.10 makes static systems a *special case* of adaptive systems with the same
discriminative behavior. Thus any lower bound proved for adaptive systems
immediately applies to static systems, and any static construction immediately
yields an adaptive one of the same depth — the two ingredients we need to make the
bounds meet.

---

## 3. The prior counting law (foundations)

We record the one-sided results on which the new theorems build.

**Proposition 3.1 (Static pigeonhole).** If `2^n < |A|`, then every static system
of depth `n` has a twin pair.

*Proof sketch.* The profile map `A → (Fin n → Bool)` targets a set of size `2^n`.
If `|A| > 2^n` it cannot be injective, so two distinct elements share a profile. ∎

**Proposition 3.2 (Adaptive cardinality bound).** If an adaptive system of depth
`n` distinguishes `A` (transcript injective), then `|A| ≤ 2^n`.

*Proof sketch.* The transcript map `A → (Fin n → Bool)` is injective into a set of
size `2^n`; cardinality of the domain is at most that of the codomain. ∎

**Proposition 3.3 (Sufficiency on powers).** For every `n`, there is a static
system on `Fin (2^n)` distinguishing all elements: the bit-extraction system
`pred i a = testBit(a, i)` (the `i`-th binary digit of `a`).

*Proof sketch.* Two elements of `Fin (2^n)` agreeing on bits `0, …, n−1` agree on
all bits (higher bits are zero, as both are `< 2^n`), hence are equal. ∎

Propositions 3.1–3.3 give the *boundary* case `|A| = 2^n` but leave open the exact
depth for general `|A|`. The remainder of the paper closes this.

---

## 4. Main results

### 4.1 The lower bound (adaptive)

**Theorem 4.1 (`distinguish_depth_ge_clog`).** Let `A` be finite and let
`O : AdaptiveObs A n` distinguish `A` (i.e. `transcript_O` is injective). Then
`clog₂ |A| ≤ n`.

*Proof.* By Proposition 3.2, injectivity of the transcript forces `|A| ≤ 2^n`.
Apply `clog₂` to both sides and use monotonicity (Lemma 2.4):
`clog₂ |A| ≤ clog₂ (2^n)`. By Lemma 2.2, `clog₂ (2^n) = n`. Hence
`clog₂ |A| ≤ n`. ∎

This *sharpens* the cardinality bound of Proposition 3.2 into a *depth* bound: it is
the same fact transported through `clog₂`. Crucially, it holds for fully adaptive
systems, so it is the strongest possible form of the lower bound.

### 4.2 The upper bound (static)

**Theorem 4.2 (`exists_distinguishing_static`).** Every finite type `A` admits a
*static* observation system of depth exactly `clog₂ |A|` distinguishing all of its
elements.

*Proof.* Set `n = clog₂ |A|`. By Lemma 2.3, `|A| ≤ 2^n`, so there is an injection
(an embedding) `e : A ↪ Fin (2^n)`. By Proposition 3.3, there is a static system
`O'` on `Fin (2^n)` whose profile is injective. Pull it back along `e`: define the
depth-`n` system on `A` by `pred i a = O'.pred i (e a)`. If two elements `a, b` of
`A` have equal profiles under this system, then `e a` and `e b` have equal profiles
under `O'`, hence `e a = e b` (Proposition 3.3), hence `a = b` (injectivity of
`e`). ∎

The construction is conceptually transparent: *binary-encode an injection of `A`
into `Fin (2^n)` and read off the bits.* It generalizes Proposition 3.3 from the
special type `Fin (2^n)` to an arbitrary finite type, witnessing that the
power-of-two case is genuinely the universal one.

### 4.3 The exact complexity

**Theorem 4.3 (Observation Complexity Theorem, `min_distinguishing_depth`).** For
every finite type `A`,
```
clog₂ |A| = min { n : there exists an adaptive system of depth n distinguishing A }.
```
Formally, `clog₂ |A|` is the least element (`IsLeast`) of the set
`{ n | ∃ O : AdaptiveObs A n, transcript_O injective }`.

*Proof.* `IsLeast` requires two facts: membership and the lower bound.

*Membership.* By Theorem 4.2 there is a static system `O` of depth `clog₂ |A|`
distinguishing `A`. By Lemma 2.10, `ofStatic(O)` is an adaptive system of the same
depth with the same twin relation; since `O` distinguishes `A`, so does
`ofStatic(O)`. Hence `clog₂ |A|` belongs to the set.

*Lower bound.* For any `n` in the set, witnessed by a distinguishing adaptive system
`O`, Theorem 4.1 gives `clog₂ |A| ≤ n`. So `clog₂ |A|` is a lower bound for the
set. ∎

This is the flagship result. The lower bound is proved for the *adaptive* model and
the matching upper bound is realized in the *static* model; their coincidence yields:

**Corollary 4.3.1 (No adaptive speedup).** The minimal worst-case depth required to
distinguish `A` is the same for static and adaptive systems, namely `clog₂ |A|`.
Adaptivity provides no worst-case advantage for the distinguishability task.

Phrasing the result as `IsLeast` rather than as an `inf`-equality is deliberate: it
is the cleaner and in fact stronger statement, and it avoids the technical need to
*pad* a shallow decision tree up to a prescribed larger depth.

### 4.4 A concrete corollary

**Theorem 4.4.** The minimal number of Boolean observations distinguishing the 100
elements of `Fin 100` is exactly `7`.

*Proof.* By Theorem 4.3 the cost is `clog₂ 100`. Since `2^6 = 64 < 100 ≤ 128 = 2^7`,
the least `k` with `100 ≤ 2^k` is `7`. ∎

Concretely: seven well-chosen yes/no questions fingerprint a hundred objects, and
six provably cannot (six questions distinguish at most `2^6 = 64`).

### 4.5 The generalized k-ary bound

**Theorem 4.5 (`generalized_observation_complexity`).** Consider observations
valued in a `k`-element alphabet, so that a depth-`n` system assigns each element a
profile in a set of size `k^n`. If such a system distinguishes `A`, then
`clog_k |A| ≤ n`. Hence for `k ≥ 2` the minimal depth is `clog_k |A|`, achieved by a
base-`k` encoding analogue of Theorem 4.2.

*Proof sketch.* The profile map is injective into a set of size `k^n`, so
`|A| ≤ k^n`; applying `clog_k` and using its monotonicity and the identity
`clog_k (k^n) = n` (valid for `k ≥ 2`) gives `clog_k |A| ≤ n`. The matching upper
bound replaces binary digits with base-`k` digits in the construction of Theorem
4.2. ∎

**The unary degeneracy.** For `k ≤ 1` the formula collapses: `clog_1 n = 0` by
convention, and indeed `1^n = 1` for all `n`, so a unary alphabet yields only one
possible profile and *cannot* distinguish more than one element. The logarithmic law
genuinely requires `k ≥ 2` — at least one real bit of choice per observation. Far
from a mere edge case, this is the theory explaining from first principles *why*
discrimination requires genuine alternatives.

---

## 5. Algorithms

The constructive content of the theorems yields directly executable procedures.

### 5.1 Computing the exact complexity

`clog₂ |A|` is computed by repeated doubling: start with `power = 1`, `k = 0`, and
double `power` (incrementing `k`) until `power ≥ |A|`. This runs in
`O(log |A|)` arithmetic steps. The same routine with base `k` computes the `k`-ary
cost.

### 5.2 The optimal static questionnaire

To build the optimal depth-`d` (`d = clog₂ |A|`) system on `{0, …, |A|−1}`: emit the
`d` predicates `pred_i(a) = testBit(a, i)` for `i = 0, …, d−1`. Each element's
profile is its `d`-bit binary label; distinctness of labels guarantees distinct
profiles. Construction is `O(d)`; evaluating all profiles is `O(|A| · d)`.

### 5.3 Verifying distinguishability

Given any system (static family or decision tree) and the element set, compute each
element's profile/transcript and insert into a hash set; a collision certifies a
twin pair (failure), no collision certifies distinguishability. This runs in
`O(|A| · n)` time and is used to empirically confirm both the upper bound (the
`d`-predicate system succeeds) and the lower bound (any `(d−1)`-predicate system
fails).

### 5.4 The static-to-adaptive bridge

To exhibit a distinguishing decision tree of optimal depth, apply `ofStatic` to the
optimal static system: build a tree in which every node's two children are identical
copies of the subtree for the remaining predicates. The resulting tree has depth `d`
and, by Lemma 2.10, the same (distinguishing) behavior — an executable witness that
adaptivity gains nothing.

---

## 6. Applications

- **Sensor and diagnostic design.** Choosing measurements to identify the internal
  state of a system among `S` possibilities requires at least `⌈log₂ S⌉` binary
  sensors; no adaptive measurement schedule lowers this worst-case count.
- **Database keys.** A minimal binary key on a table of `R` records has width
  exactly `⌈log₂ R⌉`: the smallest set of bit-valued attributes whose joint values
  are unique.
- **Fixed-length coding.** Theorem 4.2's construction *is* a fixed-length binary
  code of length `⌈log₂ |A|⌉`; Theorem 4.1 is the matching optimality (no shorter
  fixed-length code separates all symbols).
- **Comparison-based search and sorting.** Modeling each comparison as one Boolean
  observation, the `2^n` counting floor reproduces the classical `⌈log₂ N⌉` lower
  bound for searching among `N` outcomes and the `⌈log₂ (N!)⌉` bound for sorting.
- **Group testing and adaptive screening.** The result delineates exactly where
  adaptivity *cannot* help (worst-case full identification) versus where it can
  (average-case under nonuniform priors), guiding when adaptive protocols are worth
  their overhead.

---

## 7. Discussion

The conceptual core is a single act of *transport*. The prior development supplied
a cardinality law, `|A| ≤ 2^n`, in two flavors (a floor for all systems and a
ceiling on powers of two). The ceiling logarithm `clog₂`, being the exact inverse of
`2^{(·)}` on powers and monotone in general, converts that cardinality law into a
*depth* law, `clog₂ |A| ≤ n`, in both directions simultaneously. The cardinality
bound and the depth bound are, quite literally, the same statement viewed through
`clog₂`.

The second payoff is the equality of the static and adaptive optima. The
asymmetry of the proof is the point: we prove the lower bound where it is *hardest*
to prove (adaptive systems, with their answer-dependent queries) and the upper bound
where it is *easiest* to construct (a fixed binary code). Their meeting at one number
is the precise content of "adaptivity buys no worst-case speedup."

A methodological note: stating the theorem as `IsLeast` rather than as an equality
of two infima sidesteps a genuine technical obstruction — that comparing static and
adaptive optima as infima would require a *padding* operation lifting a shallow
decision tree to a deeper one. `IsLeast` is at once the stronger statement and the
one that avoids this construction. The missing padding primitive is itself a natural
object of future study (Section 8).

Finally, the unary degeneracy (`k ≤ 1`) is not noise but signal: it is the boundary
at which the logarithmic law must fail, and the formula's honest report of "zero
useful questions" is the theory recognizing that discrimination is impossible
without genuine alternatives.

---

## 8. Future directions

*(Reproduced, lightly edited, from the research cycle that produced these results.)*

**Synthesis.** This cycle attacked the information-theoretic gap in the observation
framework. Prior work established only the one-sided counting law: a system of depth
`n` separates at most `2^n` elements, achievable on `Fin (2^n)`. What was missing
was the exact query complexity for an arbitrary finite type. We closed the gap with
the theorem that the minimal depth needed to distinguish every element of a finite
type `A` is exactly `clog₂ |A| = ⌈log₂ |A|⌉`, stated as an `IsLeast` fact.

The structural insight driving the proofs is that `clog` is the exact inverse of
`2^{(·)}` on powers. This lets us transport both directions of the counting law into
a single depth statement: the cardinality bound `|A| ≤ 2^n` becomes the depth lower
bound by monotonicity of `clog`, and the `Fin (2^n)` sufficiency result becomes a
general construction by binary-encoding an embedding `A ↪ Fin (2^n)`. A second
payoff is that the same number `clog₂ |A|` is optimal for both the static and
adaptive models — the lower bound proved for adaptive systems, the upper bound
realized by a static one — so adaptivity buys no speedup. The one genuine subtlety
is that the base-`k` version is sharp only for `k ≥ 2`; the `k ≤ 1` boundary, where
`clog` collapses to `0`, requires an explicit case split, and is itself informative:
a unary alphabet carries no discriminative power, which is exactly why the
logarithmic law needs `k ≥ 2`.

What did not work cleanly: phrasing the result as an `sInf` equality between the
static and adaptive optimal depths would force *padding* of small decision trees up
to larger depths (a constructive operation on the adaptive-tree type). Re-casting as
`IsLeast` sidesteps this and is the stronger, cleaner statement. The padding
operation remains an interesting missing primitive.

**Concrete directions.**

1. *Average-case and prior-weighted complexity.* Replace worst-case depth by
   expected number of queries under a distribution on `A`. Here adaptivity *does*
   help, and the optimum is governed by Shannon entropy and Huffman-style codes
   rather than `clog`. Formalizing the entropy lower bound and the optimal adaptive
   construction would complement the present worst-case theory.

2. *Cost-weighted observations.* Assign each predicate a cost; minimize total cost
   rather than count. This connects to weighted decision-tree and alphabetic-coding
   problems and would test how robustly the `clog` law degrades under heterogeneity.

3. *A padding/normal-form primitive for decision trees.* Define and verify an
   operation extending a depth-`m` adaptive system to depth `n ≥ m` preserving
   transcripts, enabling an `sInf`-equality formulation and a clean theory of
   minimal decision trees.

4. *Partial distinguishability and approximate separation.* Quantify the depth
   needed to distinguish all but an `ε`-fraction of pairs, interpolating between the
   trivial (depth 0) and full-separation (`clog`) regimes.

5. *Structured observation classes.* Restrict predicates to a class (e.g. threshold
   functions, juntas, linear forms over a finite field) and study how the minimal
   depth changes — typically increasing above `clog₂ |A|` — connecting to VC theory
   and learning.

---

## 9. Conclusion

The number of yes/no observations needed to distinguish every element of a finite
set `A` is exactly `⌈log₂ |A|⌉`: necessary even against adaptive strategies,
sufficient via an explicit static binary code, and identical for the static and
adaptive models. With richer `k`-ary observations the cost becomes `⌈log_k |A|⌉` for
`k ≥ 2`, while a unary alphabet can distinguish nothing. The result is a tight,
two-sided, fully general form of Shannon's "one bit per query" principle, with
immediate consequences for coding, keys, sensing, and the complexity of search.
