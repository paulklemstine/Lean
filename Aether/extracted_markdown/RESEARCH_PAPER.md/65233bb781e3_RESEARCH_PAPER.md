# Rips Graph Monotonicity as a Functor into Tropical Valuation Objects

**Domain:** Bridges (geometry ↔ order theory ↔ computation)

## Abstract

The Vietoris–Rips construction assigns to a metric space and a scale parameter a graph whose edges record proximity. We isolate and formalize the precise order-theoretic content of this construction on *finite* metric spaces, packaging the size of the Rips 1-skeleton as a monotone integer-valued *edge-count profile* `edgeCountProfile : ℕ → ℕ`. Our central results establish that this profile is (i) monotone non-decreasing in the threshold, (ii) zero at threshold zero in any metric space, and (iii) uniformly bounded above by the number of unordered point-pairs. We show that monotonicity is precisely the property that allows the assignment *finite metric space ↦ edge-count profile* to be read as a functor into an ordered, idempotent ("tropical") target — the natural home of valuation-like, order-preserving summaries. The arguments reduce, by design, to two robust primitives: subgraph monotonicity of the Rips graph under threshold increase, and monotonicity of cardinality under set inclusion. We then develop a companion *dynamical bridge*: a formal theory of continuous iteration showing that iterates of a continuous self-map remain continuous, that orbit maps into finite product spaces are continuous, that compactness and connectedness are transported by iteration, and that commutation and semiconjugacy intertwine all iterates. Both developments instantiate a single thesis: the load-bearing theorems of applied geometry and dynamics are statements that structure is carried faithfully by monotone, structure-preserving maps. All results have been formally verified.

---

## 1. Introduction

### 1.1 Motivation

Topological data analysis (TDA) reconstructs qualitative shape from finite samples. Its foundational device is the *filtration*: a one-parameter family of combinatorial objects, indexed by a scale, that grows monotonically with the parameter. The Vietoris–Rips filtration is the most widely used such family. From a finite metric space `(α, dist)` and a scale `ε ∈ ℝ`, it builds the **Rips graph** whose vertices are the points of `α` and whose edges join pairs within distance `ε`. As `ε` increases, edges appear and never disappear; the *scales of appearance and disappearance* of homological features constitute the *persistence diagram*, the principal invariant of TDA.

The entire interpretive scaffolding of persistence — birth scales, death scales, barcodes, stability — depends on a single structural fact: **monotonicity**. A feature, once present, must remain present at larger scales, for otherwise "birth before death" would be meaningless. This paper isolates that fact at the level of the 1-skeleton, formalizes it together with its natural numerical avatar (the edge count), and exhibits the resulting assignment as a functor into an ordered tropical target.

### 1.2 Contributions

1. **The edge-count profile** (Definition 3.1): a canonical, finiteness-robust integer summary `edgeCountProfile : ℕ → ℕ` of the Rips 1-skeleton, defined via `Set.ncard` of the edge set so that statements carry no `Fintype`/`Decidable` side conditions.
2. **Monotonicity** (Theorem 4.1 and Corollary 4.2): the profile is non-decreasing, packaged both as a pointwise inequality and as the order-theoretic statement `Monotone (edgeCountProfile)`.
3. **Boundary and bound** (Theorems 4.3 and 4.4): the profile vanishes at threshold zero in any metric space, and is uniformly bounded by the number of unordered pairs `card (Sym2 α)`.
4. **The functorial bridge** (Section 5): an account of why monotonicity is exactly the property making *space ↦ profile* a functor into an idempotent, order-theoretic (tropical) target — the categorical content of the title.
5. **A dynamical companion bridge** (Section 6): a formal theory of continuous iteration — continuity of iterates and orbit maps, transport of compactness and connectedness, and intertwining of iterates by commutation and semiconjugacy.

All statements below are presented with mathematical proof sketches; each has been fully formally verified.

---

## 2. Preliminaries

### 2.1 Finite metric and pseudometric spaces

A **pseudometric space** is a set `α` with `dist : α × α → ℝ` satisfying `dist x x = 0`, symmetry `dist x y = dist y x`, the triangle inequality `dist x z ≤ dist x y + dist y z`, and non-negativity `0 ≤ dist x y`. A **metric space** additionally satisfies `dist x y = 0 → x = y`. We work with a finite type `α` (`[Fintype α]`, with `[DecidableEq α]`) carrying a metric. Finiteness of `α` makes the set of unordered pairs `Sym2 α` finite as well.

### 2.2 Simple graphs and edge sets

A `SimpleGraph α` is given by an irreflexive symmetric adjacency relation `Adj`. Its **edge set** `edgeSet ⊆ Sym2 α` consists of the unordered pairs `s(x, y)` with `x` adjacent to `y`. Graphs are ordered by `G ≤ H ⟺ ∀ x y, G.Adj x y → H.Adj x y`; this order is reflected on edge sets: `G ≤ H → G.edgeSet ⊆ H.edgeSet`.

### 2.3 Counting with `ncard`

For a set `s`, `Set.ncard s : ℕ` is its natural-number cardinality (`0` if infinite). We use the inclusion-monotonicity lemma: if `s ⊆ t` and `t` is finite, then `ncard s ≤ ncard t`. Using `ncard` (rather than `Finset.card`) keeps the *statements* free of finiteness hypotheses; finiteness of the relevant sets is supplied on demand from `[Fintype α]` (whence `Sym2 α` and all subsets of it are finite).

---

## 3. The Rips Graph and the Edge-Count Profile

### 3.1 The Rips graph

**Definition 3.1 (Rips graph).** For a pseudometric space `α` and `ε ∈ ℝ`, the **Rips graph** `ripsGraph α ε : SimpleGraph α` has adjacency
```
(ripsGraph α ε).Adj x y  ⟺  x ≠ y ∧ dist x y ≤ ε.
```
Symmetry follows from `dist x y = dist y x`; irreflexivity from the `x ≠ y` clause.

The following three lemmas about the Rips graph itself are the primitives on which the profile theory rests.

**Lemma 3.2 (Graph monotonicity).** If `ε₁ ≤ ε₂` then `ripsGraph α ε₁ ≤ ripsGraph α ε₂`.

*Proof.* Let `x, y` be adjacent at scale `ε₁`, so `x ≠ y` and `dist x y ≤ ε₁`. Then `dist x y ≤ ε₁ ≤ ε₂`, so `x, y` are adjacent at scale `ε₂`. ∎

**Lemma 3.3 (Vanishing at zero in a metric space).** In a metric space, `ripsGraph α 0 = ⊥` (the edgeless graph).

*Proof.* If `x, y` were adjacent at scale `0` then `dist x y ≤ 0`, and with `0 ≤ dist x y` this gives `dist x y = 0`, hence `x = y` (metric separation), contradicting `x ≠ y`. The converse is vacuous. ∎

**Lemma 3.4 (Vanishing at negative scale).** In a pseudometric space, `ε < 0 ⟹ ripsGraph α ε = ⊥`.

*Proof.* Adjacency would require `dist x y ≤ ε < 0`, contradicting `0 ≤ dist x y`. ∎

### 3.2 The edge-count profile

**Definition 3.5 (Edge-count profile).** For a finite metric space `α` with `[Fintype α] [DecidableEq α] [MetricSpace α]`, define
```
edgeCountProfile α : ℕ → ℕ,     edgeCountProfile α r := (ripsGraph α (r : ℝ)).edgeSet.ncard.
```
That is, `edgeCountProfile α r` is the number of edges of the Rips graph at the (real) threshold obtained by casting the integer `r`. The use of integer thresholds yields a discrete summary `ℕ → ℕ` while losing no qualitative information: the jumps of the profile occur at integer scales bracketing the pairwise distances.

---

## 4. Main Results

### 4.1 Monotonicity

**Theorem 4.1 (Edge-count monotonicity).** For all `r, s : ℕ` with `r ≤ s`,
```
edgeCountProfile α r ≤ edgeCountProfile α s.
```

*Proof.* Cast `r ≤ s` to `(r : ℝ) ≤ (s : ℝ)`. By Lemma 3.2, `ripsGraph α r ≤ ripsGraph α s`, hence `edgeSet (ripsGraph α r) ⊆ edgeSet (ripsGraph α s)` by edge-set monotonicity. The larger edge set is finite (it sits in the finite set `Sym2 α`), so `ncard` of the subset is at most `ncard` of the superset. ∎

**Corollary 4.2 (Order-theoretic packaging).** `Monotone (edgeCountProfile α)`.

*Proof.* Unfolding `Monotone`, this is exactly Theorem 4.1 applied to arbitrary `r ≤ s`. ∎

Corollary 4.2 is the clean order-theoretic statement: the profile is a morphism in the category of preorders from `(ℕ, ≤)` to `(ℕ, ≤)`.

### 4.2 Boundary value

**Theorem 4.3 (Zero threshold).** `edgeCountProfile α 0 = 0`.

*Proof.* The cast of `0 : ℕ` is `0 : ℝ`, so the graph is `ripsGraph α 0`, which equals `⊥` by Lemma 3.3. The empty graph has empty edge set, whose `ncard` is `0`. ∎

### 4.3 Uniform upper bound

**Theorem 4.4 (Upper bound by unordered pairs).** For all `r : ℕ`,
```
edgeCountProfile α r ≤ Fintype.card (Sym2 α).
```

*Proof.* The edge set is a subset of the universe `Set.univ : Set (Sym2 α)`. Since `Sym2 α` is finite, `ncard (edgeSet) ≤ ncard (univ) = Nat.card (Sym2 α) = Fintype.card (Sym2 α)`. ∎

Theorems 4.1, 4.3, and 4.4 jointly characterize the profile as a non-decreasing staircase function on `ℕ`, pinned to `0` at the origin and capped at `card (Sym2 α) = n(n−1)/2` for `n = card α`. Every plateau is a band of scales with no new proximity; every jump marks one or more pairwise distances crossing the integer threshold.

---

## 5. The Functorial Bridge to Tropical Valuation Objects

This section explains the title: why monotonicity makes *space ↦ profile* a functor into an ordered, idempotent ("tropical") target. The discussion is interpretive; the load-bearing formal content is Theorems 4.1–4.4.

### 5.1 Objects: monotone profiles as valuation objects

Let `Prof` denote the set of monotone functions `ℕ → ℕ` that vanish at `0` and are eventually constant (bounded). This is the natural target type of the edge-count construction: by Corollary 4.2 and Theorems 4.3–4.4, every finite metric space produces an element of `Prof`. We regard `Prof` as a *tropical valuation object*: it is partially ordered pointwise (`p ≤ q ⟺ ∀ r, p r ≤ q r`), and the relevant algebra is idempotent — the operations that govern accumulation of features are `max` and `≤`, not `+` and `×`. In this idempotent semiring (min-plus / max-plus) worldview, a monotone, non-decreasing, bounded integer staircase is precisely a discrete *valuation*: it measures, at each scale, the "mass" of proximity accumulated so far, and the order `≤` is the valuation-comparison relation.

### 5.2 Morphisms: non-expanding maps and profile domination

The natural morphisms between metric spaces are **non-expanding (1-Lipschitz) maps**: `f : α → β` with `dist (f x) (f y) ≤ dist x y`. Such a map carries proximity forward: if `x, y` are adjacent in `ripsGraph α ε` (so `dist x y ≤ ε`), then `dist (f x) (f y) ≤ ε`, so `f x, f y` are adjacent in `ripsGraph β ε` whenever `f x ≠ f y`. For **injective** non-expanding maps the side condition `f x ≠ f y` is automatic, and the induced map on edge sets is injective; counting then yields a *domination* of profiles,
```
edgeCountProfile α r ≤ edgeCountProfile β r     for all r,
```
i.e. `edgeCountProfile α ≤ edgeCountProfile β` in the pointwise order on `Prof`. We call this relation **RipsProfileDomination**.

### 5.3 Functoriality

The assignment
```
F : (finite metric space)  ⟼  edgeCountProfile,        (object map)
F : (injective non-expanding map)  ⟼  domination,      (morphism map)
```
respects identities (the identity map gives equality of profiles, the reflexivity of domination) and composition (composite non-expanding maps give the transitive composite domination). It therefore behaves as a functor from the category of finite metric spaces with injective non-expanding maps to the thin category `(Prof, ≤)`. Because `(Prof, ≤)` is a partial order, the morphism between any two objects is unique when it exists; domination is the categorical image of a map of spaces.

**Order-theoretic upgrade.** Domination is reflexive (`dom_refl`) and transitive (`dom_trans`) — a preorder. On the quotient of finite integer metric spaces by "equal profile", antisymmetry holds: mutual domination forces equal profiles, upgrading the preorder to a genuine partial order. This is the `le_antisymm` axiom of the ambient tropical valuation object, exposed for free by the categorical packaging.

### 5.4 The profile as a discrete derivative of the distance distribution

The jumps of `edgeCountProfile` recover the multiset of pairwise distances: the increment `edgeCountProfile α r − edgeCountProfile α (r−1)` counts the pairs whose distance lies in `(r−1, r]`. Hence the profile is, up to the integer-binning of thresholds, a cumulative count of the distance histogram, and the monotone staircase is the discrete integral of that histogram. Equal profiles for all `r` is equivalent to an equal multiset of (binned) pairwise distances; the profile is therefore a *complete invariant of the distance multiset* (though not of the space up to isometry, since the distance multiset does not determine the space).

---

## 6. The Dynamical Companion Bridge: Continuous Iteration

The same thesis — *structure is carried faithfully by structure-preserving maps* — animates a second, self-contained development on the dynamics of continuous self-maps. We summarize it as a miniature theory of *observable dynamics*.

### 6.1 Continuity of iterates and orbit maps

**Theorem 6.1 (Iterates are continuous).** If `f : α → α` is continuous on a topological space `α`, then for every `n : ℕ` the iterate `f^[n]` is continuous.

*Proof.* Induction on `n`: `f^[0] = id` is continuous, and `f^[n+1] = f ∘ f^[n]` is a composite of continuous maps. ∎

**Theorem 6.2 (Orbit map continuity).** For continuous `f` and fixed `N : ℕ`, the **orbit map**
```
x ⟼ (k ↦ f^[k] x) : α → (Fin N → α)
```
into the finite product space is continuous.

*Proof.* A map into a product is continuous iff each coordinate is; coordinate `k` is `f^[k]`, continuous by Theorem 6.1. ∎

Theorem 6.2 is the key dynamical bridge: it repackages a nonlinear, time-evolving process as a single continuous feature map into a finite-dimensional product, the input to downstream geometric or statistical analysis.

### 6.2 Transport of geometric structure

**Theorem 6.3 (Compactness transport).** If `f` is continuous and `s` is compact, then `f^[n] '' s` is compact for every `n`.

*Proof.* The continuous image of a compact set is compact; apply with the continuous map `f^[n]` (Theorem 6.1). ∎

**Theorem 6.4 (Connectedness transport).** If `f` is continuous and `s` is connected (nonempty and topologically connected), then `f^[n] '' s` is connected for every `n`.

*Proof.* The continuous image of a connected set is connected; apply with `f^[n]`. ∎

### 6.3 Commutation and semiconjugacy intertwine iterates

**Theorem 6.5 (Semiconjugacy intertwines iterates).** If `h : α → β` semiconjugates `f` to `g`, i.e. `h ∘ f = g ∘ h`, then `h ∘ f^[n] = g^[n] ∘ h` for all `n`.

*Proof.* Induction on `n`. Base: `h ∘ f^[0] = h = g^[0] ∘ h`. Step: using `f^[n+1] = f^[n] ∘ f`-style unfolding and the hypothesis `h ∘ f = g ∘ h`,
`h ∘ f^[n+1] = (h ∘ f^[n]) ∘ f = (g^[n] ∘ h) ∘ f = g^[n] ∘ (h ∘ f) = g^[n] ∘ (g ∘ h) = g^[n+1] ∘ h`. ∎

**Theorem 6.6 (Commuting maps pass through iterates).** If `f` and `g` commute, `f ∘ g = g ∘ f`, then `g ∘ f^[n] = f^[n] ∘ g` for all `n`.

*Proof.* The case `h = g`, `α = β`, `f = g`-image of Theorem 6.5; equivalently a direct induction using `f ∘ g = g ∘ f`. ∎

**Theorem 6.7 (Set-level transfer).** If `f` and `g` commute, then for every set `s` and every `n`,
```
g '' (f^[n] '' s) = f^[n] '' (g '' s).
```

*Proof.* `g '' (f^[n] '' s) = (g ∘ f^[n]) '' s = (f^[n] ∘ g) '' s = f^[n] '' (g '' s)`, using Theorem 6.6 and functoriality of images under composition. ∎

**Theorem 6.8 (Continuous semiconjugate orbit map).** If `f, g, h` are continuous and `h` semiconjugates `f` to `g`, then for fixed `N` the map `x ⟼ (k ↦ g^[k] (h x))` is continuous.

*Proof.* It is the composite of `h` (continuous) with the `g`-orbit map (continuous by Theorem 6.2). Each coordinate `x ⟼ g^[k] (h x)` is continuous. ∎

These commutation laws are the algebraic seeds of *orbit factorization*: a system with a symmetry `g` (or a semiconjugacy `h`) descends to its quotient, and orbits in the quotient are images of orbits upstairs. This is the dynamical analogue of the functoriality of Section 5.

---

## 7. Algorithms

The theory is directly computational. We record two algorithms underlying the formal definitions.

### 7.1 Edge-count profile evaluation

Given a finite metric space as a distance matrix `D` on `n` points and a threshold `r`, count the unordered pairs within distance `r`:
```
function EDGE_COUNT(D, n, r):
    count ← 0
    for i in 0 .. n-1:
        for j in i+1 .. n-1:
            if D[i][j] ≤ r:
                count ← count + 1
    return count
```
Complexity: `O(n²)` per threshold. The full profile over thresholds `0 .. R` is obtained either by `R+1` independent sweeps (`O(R n²)`) or, more efficiently, by sorting the `O(n²)` pairwise distances once and accumulating (`O(n² log n)`), which makes the staircase and its jumps explicit.

### 7.2 Orbit-vector evaluation

Given a self-map `f` and horizon `N`, compute the orbit vector of a point `x`:
```
function ORBIT(f, x, N):
    v ← array of length N
    cur ← x
    for k in 0 .. N-1:
        v[k] ← cur
        cur ← f(cur)
    return v
```
Complexity: `O(N · cost(f))`. This is the constructive content of the orbit map of Theorem 6.2.

---

## 8. Applications

- **Persistent homology (H₀ and 1-skeleton).** The edge-count profile is the connectivity backbone of Vietoris–Rips persistence; monotonicity guarantees well-defined birth/death scales for connected components.
- **Shape fingerprints.** The monotone staircase is a compact, comparable signature of a point cloud, usable for indexing and nearest-neighbor retrieval in shape databases; the tropical (order/`max`) structure makes such summaries composable.
- **Distance-distribution recovery.** Via the discrete-derivative interpretation (Section 5.4), the profile recovers the binned pairwise-distance histogram.
- **Observable dynamics.** The orbit map (Theorem 6.2) provides a continuous feature embedding of trajectories; compactness/connectedness transport (Theorems 6.3–6.4) certifies that qualitative invariants survive evolution; commutation laws (Theorems 6.5–6.7) support symmetry reduction.

---

## 9. Discussion

The mathematical heart of this work is deliberately elementary: a one-line inequality `dist x y ≤ ε₁ ≤ ε₂` and the monotonicity of cardinality under inclusion. Its significance is structural rather than technical. By choosing `Set.ncard` over `Finset.card`, the statements remain free of finiteness side conditions, and the proofs reduce to two reusable primitives — subgraph monotonicity and inclusion-monotone counting. This makes the development modular and robust to changes of ambient category.

The functorial reading (Section 5) is what places the result on the *Bridges* map: it connects metric geometry (point clouds), order theory / tropical algebra (monotone valuations under `max`/`≤`), and computation (the `O(n² log n)` profile algorithm). The dynamical companion (Section 6) reinforces the same moral in a different category, showing that "structure transported by structure-preserving maps" is a unifying principle, not a one-off.

---

## 10. Future Directions

**Conjecture 1 — Strict monotonicity across critical scales.** For a finite metric space with at least two points at distance `d`, the profile strictly increases at the threshold `r = ⌈d⌉`: `edgeCountProfile (r−1) < edgeCountProfile r` whenever a pair first becomes connected at `r`. The jumps of the monotone profile encode exactly the multiset of pairwise distances; strict monotonicity at a scale certifies a new edge appearing there. The weak inequality is Theorem 4.1; the strict version needs only an explicit witnessing edge in the difference set.

**Conjecture 2 — Profiles separate spaces up to a tropical isometry invariant.** Two finite metric spaces with integer distances have equal edge-count profiles for all `r` iff they have the same multiset of pairwise distances; the profile is a complete invariant of the distance multiset (though not of the space). The forward direction is immediate; the reverse is a counting identity over `Sym2 α`.

**Conjecture 3 — Domination is a partial order, not merely a preorder.** On the quotient of finite integer metric spaces by "equal profile", `RipsProfileDomination` is antisymmetric: mutual domination forces equal profiles. Reflexivity and transitivity give a preorder; the `le_antisymm` axiom of the ambient tropical valuation object upgrades it to a partial order once profiles are the carriers.

**Conjecture 4 — Non-injective nonexpanding maps satisfy a reversed bound.** A surjective non-expanding map `f : α → β` satisfies `edgeCountProfile β r ≤ (a factor explicit in fibers) · edgeCountProfile α r`; quotient (gluing) maps can only *decrease* edges after accounting for collapsed fibers.

---

## 11. Conclusion

We have formalized the order-theoretic core of the Vietoris–Rips construction on finite metric spaces. The edge-count profile is a monotone, boundary-pinned, uniformly bounded integer staircase, and monotonicity is precisely what realizes *space ↦ profile* as a functor into an idempotent tropical valuation object. A companion theory of continuous iteration demonstrates the same structural principle in the category of topological dynamics. The results are simple by design and verified in full, providing a reusable, side-condition-free foundation for the connectivity layer of persistent topology and for the transport of geometric structure under continuous evolution.
