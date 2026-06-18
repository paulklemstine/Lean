# Ordinal Rank as a Functor on GL Frames: Duality, Products, and Polymodal Monotonicity

## Abstract

Gödel–Löb provability logic (GL) is the modal logic of the formal provability
predicate; by Segerberg's completeness theorem it is sound and complete for the
class of finite, irreflexive, transitive Kripke frames. The accessibility
relation of such a frame is converse-well-founded, and hence assigns to every
world a canonical **ordinal rank** measuring the height of the tree of ascending
accessibility chains issuing from it. This paper develops the thesis that the
ordinal rank behaves *functorially*: the natural order-theoretic operations on GL
frames — modal duality, the categorical (synchronized) product, and the nested
family of accessibility relations underlying polymodal GLP — each translate into an
elementary operation on ordinals.

We prove four principal results. (1) A general set-theoretic lemma:
well-founded rank is **monotone under shrinking the relation**, and more generally
decreases along any relation homomorphism between well-founded relations. (2) A
**diamond rank stratification** dual to the known Löb stratification: the `k`-fold
diamond of the universe is exactly the set of worlds of rank `≥ k`, the
set-complement of `□^k ∅ = {rank < k}`. (3) The **rank of a synchronized product is
the pointwise minimum** of the coordinate ranks. (4) Polymodal rank is **antitone
in the modality index**: higher, sparser modalities assign smaller ordinals. The
unifying observation is that (3) and (4) are both consequences of (1): the
coordinate projections of a product and the inclusion of a higher accessibility
relation into a lower one are relation homomorphisms, so monotonicity of rank does
the work. We give complete mathematical statements, proof sketches, the supporting
algorithms for computing ranks and verifying the identities on finite frames, and
a discussion of the broader role of rank as a termination/consistency-strength
gauge.

**Keywords.** provability logic, Gödel–Löb logic GL, Kripke semantics,
well-founded relation, ordinal rank, polymodal logic GLP, categorical product,
modal duality, consistency strength.

---

## 1. Introduction

### 1.1 Background

The modal logic **GL** (Gödel–Löb) is obtained from the basic normal modal logic
**K** by adding a single schema, **Löb's axiom**:
```
□(□φ → φ) → □φ.
```
Under the *arithmetical interpretation*, `□` is read as the formalized provability
predicate `Prov_T(⌜·⌝)` of a sufficiently strong arithmetical theory `T` (such as
Peano Arithmetic), and Löb's axiom is the modal transcription of Löb's theorem,
which in turn encodes Gödel's second incompleteness theorem (the instance with
`φ = ⊥` yields `¬□⊥` is unprovable, i.e. `T` cannot prove its own consistency).
Solovay's celebrated arithmetical completeness theorem (1976) shows GL proves
exactly the schematically valid principles of provability.

On the semantic side, **Segerberg's theorem** characterizes GL as the modal logic
of the class of **finite, transitive, irreflexive Kripke frames** — equivalently,
finite strict partial orders, equivalently finite converse-well-founded transitive
relations. This is the setting of the present paper: the frame is the primary
object, and the logic is read off the geometry of the accessibility relation.

### 1.2 The central object: ordinal rank

Because a finite (more generally, converse-well-founded) transitive irreflexive
relation has no infinite ascending chains, its *converse* is well-founded. Every
well-founded relation `≺` carries the standard **rank function**
```
rank(a) = sup { rank(b) + 1 : b ≺ a },
```
the order type of the tree of `≺`-descending sequences from `a`. Applying this to
the converse accessibility relation of a GL frame assigns each world an ordinal
`rank(w)`. The rank strictly decreases along accessibility — if `w R v` then
`rank(v) < rank(w)` — and in a finite frame equals the length of the longest
`R`-chain out of `w`.

This invariant is well known to coincide with *consistency strength* in the
canonical models: in the frame `(ℕ, >)`, the world `n` has rank `n`, and `n`
witnesses `n`-fold consistency. The thesis of this paper is that rank is far more
than a per-frame invariant — it is *natural with respect to the constructions of
the GL world*. We make this precise through four theorems.

### 1.3 Contributions

We establish the following, all over arbitrary GL frames (no finiteness of the
ordinal values is assumed; everything is stated for general well-founded
relations where applicable).

1. **Rank monotonicity (the engine).** Shrinking a well-founded relation lowers
   rank pointwise; rank decreases along any relation homomorphism.
2. **Diamond rank stratification (duality).** `◇^k univ = {w : k ≤ rank(w)}`,
   the set-complement of the Löb stratification `□^k ∅ = {w : rank(w) < k}`.
3. **Product rank (categorical product).** In the synchronized product,
   `rank(a,b) = min(rank(a), rank(b))`.
4. **Polymodal antitonicity (hierarchy).** For levels `n ≤ m`,
   `rank_m(w) ≤ rank_n(w)`.

Results 3 and 4 are corollaries of result 1, exhibiting a single structural cause
for two superficially unrelated phenomena.

---

## 2. Definitions

Throughout, `Set X` denotes the powerset of `X`, `Sᶜ` the complement,
`f^[k]` the `k`-fold iterate of an operator `f`, and `Ordinal` the proper class of
ordinals with its standard well-order.

### 2.1 GL frames

**Definition 2.1 (GL frame).** A *GL frame* `F` consists of a finite type of
**worlds** `World`, together with an accessibility relation `R : World → World →
Prop` satisfying:
- **irreflexivity:** `∀ w, ¬ R w w`;
- **transitivity:** `∀ w v u, R w v → R v u → R w u`.

**Definition 2.2 (box and diamond).** For `S ⊆ World`,
```
□S := { w : ∀ v, R w v → v ∈ S },      ◇S := { w : ∃ v, R w v ∧ v ∈ S }.
```
They are dual: `◇S = (□(Sᶜ))ᶜ` and `□S = (◇(Sᶜ))ᶜ`.

**Definition 2.3 (maximal world).** A world `w` is *maximal* (a dead-end) if
`∀ v, ¬ R w v`. Equivalently `w ∈ □∅`.

**Proposition 2.4 (well-foundedness).** In any GL frame, `R` is well-founded and
its converse `flip R` is well-founded. *(Finiteness + transitivity + irreflexivity
forbid cycles and infinite chains in either direction.)*

**Theorem 2.5 (Löb soundness).** Every GL frame validates Löb's axiom: for all
`S`, `□((□S)ᶜ ∪ S) ⊆ □S`. *(Here `(□S)ᶜ ∪ S` encodes `□S → S`.) The proof is
well-founded induction on `R`.*

### 2.2 Ordinal rank

**Definition 2.6 (well-founded rank).** For a well-founded relation `≺` on `α`,
the rank function `rank_≺ : α → Ordinal` is the unique function satisfying
```
rank_≺(a) = ⨆_{b : b ≺ a} (rank_≺(b) + 1) = sup { Order.succ(rank_≺(b)) : b ≺ a }.
```
In particular `rank_≺(a) = 0` iff `a` is `≺`-minimal, and `b ≺ a ⟹ rank_≺(b) <
rank_≺(a)`.

**Definition 2.7 (rank of a GL frame).** The *rank* of a world `w` in a GL frame
`F` is `rank_F(w) := rank_{flip R}(w)`, the well-founded rank of the converse
accessibility relation.

**Lemma 2.8 (descent).** If `F.R w v` then `rank_F(v) < rank_F(w)`.

**Lemma 2.9 (bottom layer).** `rank_F(w) = 0 ⟺ w` is maximal; and
`□∅ = {w : w maximal}`.

### 2.3 The synchronized product

**Definition 2.10 (product frame).** For GL frames `F, G`, the *synchronized
product* `F.prod G` has worlds `F.World × G.World` and accessibility
```
(F.prod G).R (a,b) (c,d) ⟺ F.R a c ∧ G.R b d.
```
It is again a GL frame: irreflexivity and transitivity are inherited coordinatewise.
This is the categorical product in the category of GL frames and bounded morphisms.

**Proposition 2.11 (diamond rectangle).** `(F.prod G).◇(A ×ˢ B) = (F.◇A) ×ˢ
(G.◇B)`. *(The box operator does not factor in this way, because a maximal
coordinate makes `□` vacuously true.)*

### 2.4 Polymodal GLP frames

**Definition 2.12 (GLP frame).** A *polymodal GLP frame* `G` consists of a finite
type `World` and a family `R : ℕ → World → World → Prop` of relations such that
each `R n` is irreflexive and transitive, and the family is **nested**:
`∀ n w v, R (n+1) w v → R n w v`. Equivalently `R m ⊆ R n` whenever `n ≤ m`; the
modalities get *sparser* as the index grows.

**Definition 2.13 (level).** The *`n`-th level* `G.level n` is the GL frame with
the same worlds and accessibility `R n`. Each level validates Löb's axiom, and
the box operators are monotone in the index: `n ≤ m ⟹ (level n).□ S ⊆ (level m).□ S`
(the frame-semantic form of the GLP axiom `[n]φ → [n+1]φ`).

---

## 3. The engine: rank monotonicity

The technical core of the paper is a pair of purely set-theoretic facts about
well-founded rank, with no reference to GL.

### 3.1 Statements

**Theorem 3.1 (rank monotone under shrinking the relation).** Let `r, s` be
well-founded relations on a type `α` with `r ⊆ s` (i.e. `∀ x y, r x y → s x y`).
Then for all `a`,
```
rank_r(a) ≤ rank_s(a).
```

**Theorem 3.2 (rank decreases along a relation homomorphism).** Let `r` be a
well-founded relation on `α`, `s` a well-founded relation on `β`, and `f : α → β`
a map with `∀ x y, r x y → s (f x) (f y)`. Then for all `a`,
```
rank_r(a) ≤ rank_s(f a).
```
Theorem 3.1 is the special case `β = α`, `f = id`.

### 3.2 Proof sketch

Both are proved by transfinite (well-founded) induction on the value of the
*target* rank. Fix `a` and assume the claim for all points whose `s`-rank
(resp. `s`-rank of their image) is strictly smaller. Unfold the recursive equation
```
rank_s(f a) = ⨆_{b' : s b' (f a)} succ(rank_s(b')).
```
To bound `rank_r(a) = ⨆_{b : r b a} succ(rank_r(b))` by this supremum, it suffices,
by `Ordinal.iSup_le_iff`, to bound each summand. Fix an `r`-predecessor `b` of `a`.
By the hypothesis, `f b` is an `s`-predecessor of `f a`, so
`rank_s(f b) < rank_s(f a)`; this both legitimizes the inductive hypothesis at `b`
(its target rank is strictly smaller) and gives `rank_r(b) ≤ rank_s(f b)` by IH.
Hence
```
succ(rank_r(b)) ≤ succ(rank_s(f b)) ≤ rank_s(f a),
```
where the last step is `Order.succ_le_of_lt` applied to `rank_s(f b) < rank_s(f a)`.
Taking the supremum over `b` completes the induction. ∎

**Intuition.** Rank is the order type of the predecessor tree. A relation
homomorphism maps each descending `r`-chain to a descending `s`-chain, so the
`r`-tree embeds into the `s`-tree; embedding can only prune, never deepen, hence
rank cannot increase.

---

## 4. Diamond stratification: the dual of Löb

### 4.1 The known Löb stratification

We take as given (it is the immediately preceding result in this program) the
**rank stratification of iterated box**:

**Theorem 4.1 (Löb / box stratification).** For every GL frame `F` and `k ∈ ℕ`,
```
F.□^k ∅ = { w : rank_F(w) < k }.
```
*Proof sketch.* Induction on `k`. Base: `□^0 ∅ = ∅ = {rank < 0}`. Step: using the
recursive identity `rank(w) = ⨆_{R w v} succ(rank v)`, we have `rank(w) < k+1 ⟺
rank(w) ≤ k ⟺ ∀ v, R w v → rank(v) < k`, which by the inductive hypothesis is
exactly membership of `w` in `□{rank < k} = □(□^k ∅)= □^{k+1} ∅`. The strict `<` is
forced by the `succ`; the naive guess `□^k ∅ = {rank ≤ k}` is off by one
(`□^1 ∅` is the maximal worlds, `{rank = 0} = {rank < 1}`). ∎

### 4.2 Iterated duality

**Lemma 4.2 (iterated diamond/box duality).** For every `k`,
```
F.◇^k univ = (F.□^k ∅)ᶜ.
```
*Proof sketch.* Induction on `k` using the pointwise duality `◇S = (□Sᶜ)ᶜ` and the
iterate identity `f^[k+1] = f ∘ f^[k]`; complementation interchanges `univ`/`∅` and
`◇`/`□` at each step. ∎

### 4.3 Main result

**Theorem 4.3 (diamond rank stratification).** For every GL frame `F` and `k ∈ ℕ`,
```
F.◇^k univ = { w : (k : Ordinal) ≤ rank_F(w) }.
```
*Proof sketch.* By Lemma 4.2, `◇^k univ = (□^k ∅)ᶜ`. By Theorem 4.1,
`□^k ∅ = {rank < k}`. Complementing and using the linearity of the ordinal order
(`¬(rank < k) ⟺ k ≤ rank`) yields the claim. The use of linearity (`not_lt`) is
essential and cannot be replaced by a Boolean decision procedure. ∎

**Interpretation.** `□^k ∅` is "`k`-fold inconsistency / falsity," holding exactly
at shallow worlds (rank `< k`). `◇^k univ` is "`k`-fold consistency," holding
exactly at deep worlds (rank `≥ k`). The two stratifications are exact
complements: every GL frame is partitioned by the single ordinal cut `rank = k`
into the worlds that fail `k`-fold consistency and those that satisfy it.
Gödel-style "`k`-consistency" and the set-theoretic ordinal rank of the
accessibility tree are one and the same.

---

## 5. Products: rank is the pointwise minimum

**Theorem 5.1 (product rank).** For GL frames `F, G` and worlds `a ∈ F.World`,
`b ∈ G.World`,
```
rank_{F.prod G}(a, b) = min( rank_F(a), rank_G(b) ).
```

### 5.1 The `≤` direction (from the engine)

The two coordinate projections
```
π₁ : (F.prod G).World → F.World,   π₁(a,b) = a,
π₂ : (F.prod G).World → G.World,   π₂(a,b) = b
```
are relation homomorphisms: a product step `(a,b) → (c,d)` requires `F.R a c` and
`G.R b d`, so `π₁` and `π₂` each send product edges to coordinate edges. Applying
Theorem 3.2 to `π₁` and to `π₂` gives
```
rank_{F.prod G}(a,b) ≤ rank_F(a)   and   rank_{F.prod G}(a,b) ≤ rank_G(b),
```
hence `rank_{F.prod G}(a,b) ≤ min(rank_F(a), rank_G(b))`.

### 5.2 The `≥` direction (coordinatewise extraction)

This is the only genuinely product-specific argument. We must show
`min(rank_F(a), rank_G(b)) ≤ rank_{F.prod G}(a,b)`. By `le_of_forall_lt` it suffices
to show that every ordinal `γ < min(rank_F(a), rank_G(b))` satisfies
`γ < rank_{F.prod G}(a,b)`. Since `γ < rank_F(a) = ⨆_{F.R a c} succ(rank_F c)` and
`γ < rank_G(b) = ⨆_{G.R b d} succ(rank_G d)`, and using the recursive characterization
of rank, one extracts — *independently in each coordinate* — a successor `c` of `a`
in `F` and a successor `d` of `b` in `G` whose ranks dominate the relevant portion
of `γ`. The pair `(c,d)` is then a product-successor of `(a,b)`, witnessing
`γ < rank_{F.prod G}(a,b)`. The key methodological point: by splitting into the two
inequalities we never need the ordinal distributive law
`min(⨆ f)(⨆ g) = ⨆ min(f,g)`, which fails to be convenient over `Ordinal` (not a
complete lattice). ∎

**Interpretation.** A synchronized descending chain advances both coordinates at
once and therefore terminates as soon as *either* coordinate is exhausted. The
consistency strength of a product world is that of its *weaker* coordinate — a
chain is only as long as its shortest synchronized leg.

**Remark 5.2 (contrast with diamond).** By Proposition 2.11, the diamond factors
across the product as a rectangle, `◇(A×B) = ◇A × ◇B`, whereas the box does not.
Rank cuts through this asymmetry and returns the single number `min`. This is the
sense in which rank is a *cleaner* invariant of the product than either modality
alone.

---

## 6. Polymodal antitonicity

**Theorem 6.1 (polymodal rank is antitone in the level).** For a GLP frame `G` and
indices `n ≤ m`,
```
rank_{G.level m}(w) ≤ rank_{G.level n}(w)   for all w.
```

*Proof sketch.* The nesting axiom gives `R m ⊆ R n` whenever `n ≤ m` (proved by
induction on `m - n` from the single-step `R(k+1) ⊆ R k`). The accessibility
relation of `G.level m` is `R m`, that of `G.level n` is `R n`, and
`G.level m`’s converse relation is therefore contained in `G.level n`’s converse
relation. Apply Theorem 3.1 (rank monotone under shrinking the relation) to the
two converse relations. ∎

**Interpretation.** Climbing the polymodal hierarchy removes accessibility edges,
which can only shorten descending chains, so ranks step down (or hold). This is the
rank-theoretic shadow of the GLP monotonicity axiom `[n]φ → [n+1]φ`: a sparser,
higher modality is logically weaker and assigns smaller ordinals. Together with the
box-monotonicity `(level n).□ S ⊆ (level m).□ S`, it shows the polymodal hierarchy
is *coherent*: weaker provability, fewer arrows, smaller rank, all aligned.

---

## 7. Algorithms

All four identities are decidable on finite frames and admit direct algorithmic
verification. We summarize the procedures; the demo provides reference Python
implementations.

### 7.1 Rank by longest-chain dynamic programming

For a finite GL frame given as an adjacency relation `R`, the rank of every world
is computed by memoized recursion on the (acyclic) accessibility graph:
```
rank(w) = 0                       if w has no successors,
rank(w) = 1 + max_{R w v} rank(v) otherwise.
```
Because `R` is transitive and irreflexive (hence a DAG with no cycles), the
recursion is well-defined; memoization gives `O(|World| + |R|)` time. The integer
output equals the ordinal rank (finite ordinals are natural numbers).

### 7.2 Iterated box / diamond and stratification check

Compute `□^k ∅` and `◇^k univ` by iterating the set operators, and compare against
the rank cuts `{w : rank(w) < k}` and `{w : rank(w) ≥ k}`. This verifies
Theorems 4.1 and 4.3 on any finite instance.

### 7.3 Product-rank and polymodal-antitonicity checks

Build the synchronized product frame, compute its ranks, and verify the
`min`-identity against the coordinate ranks (Theorem 5.1). For a GLP frame, build
each level’s frame, compute level ranks, and verify the pointwise `≤` chain across
levels (Theorem 6.1).

---

## 8. Applications and significance

- **Consistency-strength gauge.** Theorems 4.1 and 4.3 turn the qualitative
  Gödelian notion "this world survives `k` rounds of consistency assertions" into
  the quantitative statement "rank `≥ k`." This is a faithful, computable measure
  of consistency depth on any finite frame.

- **Modular construction of models.** The product-rank theorem lets one assemble a
  frame of prescribed consistency strength by taking products: to obtain a world of
  rank exactly `r`, combine factors whose minimum rank is `r`. The minimum law makes
  the strength of composite models predictable.

- **Coherence of polymodal hierarchies.** The antitonicity theorem certifies that
  the GLP tower behaves monotonically at the level of ordinal invariants, a
  prerequisite for ordinal analyses (e.g. Beklemishev's use of GLP to compute
  proof-theoretic ordinals such as `ε₀`).

- **A reusable termination principle.** Theorems 3.1–3.2 are stated for arbitrary
  well-founded relations and are directly applicable wherever termination measures
  appear: program-termination orders, recursion ranks, and the consistency-strength
  ordering of set theories. The message — *rank is monotone under shrinking the
  relation and decreasing along homomorphisms* — is a general tool.

---

## 9. Discussion

The conceptual thrust of this paper is that **the ordinal rank of the (converse)
accessibility relation is the single structure underlying all of these results.**
Modal duality becomes set-complement (Theorem 4.3); the categorical product becomes
the lattice minimum (Theorem 5.1); the polymodal nesting becomes the ordinal `≤`
(Theorem 6.1). And two of these three reduce to one engine: rank monotonicity under
relation shrinking/homomorphism (Theorems 3.1–3.2).

A methodological lesson emerged from the product theorem. A monolithic attempt to
prove `rank(a,b) = min` by a single well-founded induction stalls because matching a
supremum over product predecessors against the minimum of two component suprema
forces the distributive law `min(⨆ f)(⨆ g) = ⨆ min(f,g)`, awkward over `Ordinal`
(which is not a complete lattice). Splitting into two inequalities sidesteps the
distributive law entirely: the `≤` half is pure homomorphism monotonicity, and the
`≥` half uses `le_of_forall_lt` plus independent coordinatewise extraction, never
commuting `min` past a supremum. The reusable principle: *prefer `le_of_forall_lt`
plus coordinatewise extraction over sup/min distributivity when reasoning about
ranks of product orders.*

A second lesson concerns the role of *linearity* of the ordinals. The diamond
stratification (Theorem 4.3) hinges on `¬(rank < k) ⟺ k ≤ rank`, valid precisely
because ordinals are linearly ordered; no Boolean/decidable shortcut suffices.

---

## 10. Future work

The natural continuations of this program include:

- **Rank as an explicit functor.** Formalize the category of GL frames with bounded
  morphisms and prove that `rank` is a (lax) functor to the ordinals, with the
  product law as preservation of products up to `min`.
- **Transfinite frames.** The rank machinery is stated for well-founded relations
  generally; extending the modal results to converse-well-founded frames on
  infinite carrier types would generalize beyond the finite Segerberg setting.
- **Quantitative GLP and proof-theoretic ordinals.** Connect the level-antitone
  rank to Beklemishev-style ordinal analysis, computing the rank profile of the
  canonical GLP frames whose ordinals reach `ε₀` and beyond.
- **Other frame operations.** Determine the rank behaviour of disjoint unions
  (expected: `sup`/order-type addition), lexicographic and unsynchronized products,
  and bisimulation quotients.

---

## 11. Summary of results

| # | Result | Statement |
|---|--------|-----------|
| 3.1 | Rank monotone under shrinking | `r ⊆ s ⟹ rank_r(a) ≤ rank_s(a)` |
| 3.2 | Rank along homomorphism | `f` rel-hom `⟹ rank_r(a) ≤ rank_s(f a)` |
| 4.3 | Diamond stratification | `◇^k univ = {w : k ≤ rank(w)}` |
| 5.1 | Product rank | `rank(a,b) = min(rank a, rank b)` |
| 6.1 | Polymodal antitonicity | `n ≤ m ⟹ rank_m(w) ≤ rank_n(w)` |

Each is a theorem about a single converse-well-founded order: the accessibility
relation of a Gödel–Löb frame, viewed through the lens of its ordinal rank.
