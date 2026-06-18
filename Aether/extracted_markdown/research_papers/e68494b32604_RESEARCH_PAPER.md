# Finite Tropical Update Laws for the Rips Profile Bridge

**Formalized in** `Catalog/Bridges/RipsTropicalProfileExtensions.lean`
(namespace `RipsTropicalProfileExt`).

This note documents a fully verified extension of the Vietoris–Rips / tropical
bridge to the setting of **finite weighted graphs**. It records the metric
filtration by a monotone edge-count profile, models reachability through a
tropical *birth valuation*, and proves concrete **reconstruction** and
**update** laws for both objects. Everything is finite, order-theoretic, and
free of measure theory, persistent-homology abstractions, or barcode machinery.
All theorems depend only on the standard axioms `propext`, `Classical.choice`,
and `Quot.sound`.

## 1. Setup and definitions

A weighted graph on a vertex type `α` is encoded by a single symmetric weight
function

```
w : α → α → ℝ≥0∞,
```

where `w a b = ⊤` means "no edge `{a,b}`" and a finite value is the edge weight.
Working in `ℝ≥0∞` lets a single object carry both finite edge weights and the
"unreachable = ∞" value, with no truncated-subtraction friction (perturbation
bounds are phrased additively as `≤ · + ε`).

* **Threshold connectivity** `connAt w t : α → α → Prop` is the
  reflexive–transitive closure (`Relation.ReflTransGen`) of the thresholded
  adjacency relation `fun a b => w a b ≤ t`. Thus `connAt w t x y` holds iff `x`
  and `y` are joined by a path all of whose edges have weight `≤ t` — exactly the
  edge set of the Rips 1-skeleton at scale `t`.

* **Birth valuation** `birth w x y := sInf {t | connAt w t x y}`. This is the
  minimal threshold at which `x` and `y` become connected: the **bottleneck**
  (minimax) path value. Path concatenation is realized by the tropical sum `⊔`
  (`max`), and `birth w x y = ⊤` exactly when `x, y` lie in different connected
  components.

* **Reachability** `Reachable w x y := birth w x y < ⊤`.

* **Edge-count profiles**. `profileM M t` counts the weights `≤ t` in a multiset
  `M : Multiset ℝ≥0∞`; `profileF E w t` counts the edges `e ∈ E` with `w e ≤ t`
  in a finite indexed family. They satisfy `profileF E w t = profileM (E.val.map w) t`.

* **Graph operations**. The disjoint union `wSum w1 w2` on `β ⊕ γ` keeps
  within-component weights and sets cross pairs to `⊤`; `wBridge w1 w2 u v b`
  additionally inserts one bridge edge of weight `b` between `u : β` and `v : γ`.
  Gluing along a common vertex is modelled by a cut-vertex hypothesis `hsep`.

## 2. The master sublevel law and the tropical triangle inequality

The technical heart is **achievement of the infimum** on a finite vertex set:

* `connAt_exists_edgeval` — any connecting walk can be tightened so that its
  bottleneck value is `0` or an actual edge value (induction on `ReflTransGen`,
  taking running maxima).
* `connAt_birth` (needs `[Fintype α]`) — therefore `sInf {t | connAt w t x y}` is
  attained: `connAt w (birth w x y) x y`. The proof intersects the connecting
  set with the finite set `insert 0 (range w)` and takes its least element.

Achievement yields the clean **master sublevel law**

```
connAt_iff_birth_le :  connAt w t x y ↔ birth w x y ≤ t,
```

the tropical analogue of "the Rips edge set at scale `t` is the sublevel set of
the birth valuation." From it we read off, with one-line proofs:

* `birth_self`, `birth_le_single`, `birth_symm` (for symmetric `w`);
* the **strong tropical triangle law** `birth_strong_triangle`:
  `birth w x z ≤ birth w x y ⊔ birth w y z`,
  proved by concatenating the two achieving walks — i.e. ultrametricity of the
  bottleneck distance.

## 3. The six update and reconstruction theorems

1. **Disjoint-union profile** (`profileM_add`, `profileF_disjSum`).
   The threshold edge-count profile of a disjoint union is the sum of the
   component profiles: `profileM (M + N) = profileM M + profileM N` and
   `profileF (E.disjSum F) (Sum.elim w1 w2) t = profileF E w1 t + profileF F w2 t`.
   Proof: `Multiset.filter` distributes over `+`, and cardinality adds.

2. **Disjoint-union tropical** (`birth_wSum_inl`, `birth_wSum_cross`).
   Same-component births are unchanged: `birth (wSum w1 w2) (inl a) (inl b)
   = birth w1 a b`. Cross-component pairs are unreachable:
   `birth (wSum w1 w2) (inl a) (inr b) = ⊤` (so `not_reachable_wSum_cross`).
   Proof: below `⊤`, a walk starting in the left component stays there
   (`connAt_wSum_inl_of_lt`), and only `⊤` connects across.

3. **Bridge-edge update** (`birth_wBridge`).
   Joining `w1` and `w2` by an edge of weight `b` between `u` and `v` gives, for
   `x : β`, `y : γ`,
   ```
   birth (wBridge w1 w2 u v b) (inl x) (inr y) = birth w1 x u ⊔ b ⊔ birth w2 v y,
   ```
   i.e. `max (birth x u) (max b (birth v y))`. The `≤` direction concatenates a
   left walk to `u`, the bridge, and a right walk from `v`. The `≥` direction uses
   `connAt_wBridge_cross`: any sub-`⊤` left-to-right walk must cross the unique
   bridge, decomposing into the three pieces. This is the tropical
   path-concatenation (`⊔`) machinery made explicit.

4. **Gluing along a common vertex** (`birth_glue`).
   If the vertices split into `L`, `R` meeting only at the cut vertex `c`
   (`L ∩ R = {c}`) and every finite-weight edge stays within `L` or within `R`,
   then for `x ∈ L`, `y ∈ R`,
   ```
   birth w x y = birth w x c ⊔ birth w c y.
   ```
   The `≤` direction is the triangle law; the `≥` direction proves by induction
   that any sub-`⊤` walk from `L` to `R` must pass through `c`.

5. **Reconstruction** (`profileM_injective`, `profileF_reconstruct`).
   A finite multiset of edge weights is determined by its profile: if
   `profileM M t = profileM N t` for all `t`, then `M = N` (hence equal sorted
   weight lists). Proof: locate a value `a` where the counts disagree and a
   threshold `a⁻` just below `a` (the max realized value `< a`); the profiles at
   `a` and `a⁻` then pin down `count a`, a contradiction. Indexed corollary:
   equal profiles on a fixed edge set realize the same weight multiset.

6. **Stability** (`profileF_stability`, `birth_stability`).
   If `w'` is at most an `ε`-increase of `w` on the edge set, then
   `profileF E w t ≤ profileF E w' (t + ε)` (a sublevel set inclusion plus
   `Finset.card_le_card`). If `∀ a b, w a b ≤ w' a b + ε`, then
   `birth w x y ≤ birth w' x y + ε` pointwise (monotonicity of `ReflTransGen`
   under the `ε`-shifted adjacency, applied to the achieving walk). Applying the
   bound symmetrically gives the two-sided `|birth − birth'| ≤ ε` statement.

## 4. Algorithmic significance

The bridge turns a topological filtration into a finite data structure with
predictable update rules:

* The **birth valuation is a bottleneck/minimax metric**, computable by
  single-linkage clustering or a Kruskal/Borůvka-style union–find sweep; the
  strong triangle law is its defining ultrametric property.
* The **update laws are local**. Adding a bridge edge or gluing at a cut vertex
  rewrites all affected cross births by a single `max` against precomputed
  within-component births — the algebra behind incremental/streaming persistence
  and divide-and-conquer merge of Rips skeletons.
* The **profile is a sufficient statistic** for the weight multiset
  (reconstruction), and it is **1-Lipschitz** in the threshold under weight
  perturbations (stability), making it a stable, invertible summary.

## 5. Next questions

* Promote the gluing hypothesis to a constructed quotient graph and prove a
  general Mayer–Vietoris-style merge for profiles of overlapping covers.
* Extend the birth valuation to higher Rips simplices and relate the resulting
  multi-parameter profile to the existing interleaving/bottleneck API in the
  Boltzmann-bridge arc.
* Quantify the reconstruction map: bound the number of distinct thresholds needed
  (the realized edge values) and give an explicit inverse.

See `FUTURE_DIRECTIONS.md` for longer-form research directions.
