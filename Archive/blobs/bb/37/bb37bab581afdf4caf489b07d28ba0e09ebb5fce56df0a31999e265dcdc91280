# Future Directions — Functorial Tropical Lower Bounds on Persistent Betti-0

Follow-up conjectures arising from `Catalog/Bridges/TropicalPersistentBetti.lean`,
which proved that over a valuation-depth (ultrametric) space the persistent 0-th
Betti number equals the maximal ε-packing number (`betti0_isGreatest_packing`),
with the non-Archimedean hypothesis isolated exactly in the forward nerve direction
(`dist_le_of_reachable`).

Each conjecture below is stated to be *testable* in Lean (a precise target statement is
sketched) and *falsifiable* (a concrete failure mode if the hypothesis is dropped).

---

## C1. Antitone valuation-depth profile of β₀ (step-function structure)

**Conjecture.** Over a finite ultrametric space `α`, the map `ε ↦ persistentBetti0 α ε`
on `[0, ∞)` is a non-increasing step function whose jump set is exactly the finite set of
realised pairwise distances `{dist x y | x y : α}`, and between consecutive distances β₀
is constant. Equivalently, `persistentBetti0 α` is locally constant off the (finite) distance
spectrum.

**Lean target.** `∀ ε₁ ε₂, (∀ x y, dist x y ∉ Set.Ioc ε₁ ε₂) → persistentBetti0 α ε₁ = persistentBetti0 α ε₂`.

**Falsifiable.** If a strict drop of β₀ could occur at an `ε` that is *not* a realised
distance, the conjecture is false; this is checkable on small `Fin n` ultrametric models.

---

## C2. Tropical product / ultrametric product law for β₀

**Conjecture.** For ultrametric spaces `α`, `β` with the *sup* (ℓ^∞, i.e. tropical/max)
product metric `dist((a,b),(a',b')) = max (dist a a') (dist b b')`, the product is again
ultrametric and persistent β₀ multiplies:
`persistentBetti0 (α × β) ε = persistentBetti0 α ε * persistentBetti0 β ε`.

**Why plausible.** Under `ripsGraph_reachable_iff`, components are ε-balls; the sup metric
makes ε-balls of the product the products of ε-balls.

**Falsifiable.** Replace the max product metric by the ℓ^1 (additive) product metric: the
identity should *break*, demonstrating that the tropical (max) product is the correct
monoidal structure for this functor.

---

## C3. Functorial transfer of β₀ bounds along valuation-nonexpansive maps

**Conjecture.** If `f : α → β` is *valuation-nonexpansive* (`dist (f x) (f y) ≤ dist x y`)
between finite ultrametric spaces, then it induces, for each ε, a surjection on the
ε-ball quotients and hence `persistentBetti0 β ε ≤ persistentBetti0 α ε`. Moreover the
assignment `(α, ε) ↦ persistentBetti0 α ε` is a functor on the category of finite
ultrametric spaces and nonexpansive maps (contravariant in `ε`, covariant-with-inequality
in `α`).

**Lean target.** A `simp`-able lemma `persistentBetti0_le_of_nonexpansive`.

**Falsifiable.** Drop nonexpansiveness (allow a 1-Lipschitz-violating map): exhibit an `f`
that *increases* β₀, refuting the monotone transfer.

---

## C4. Valuation-depth = persistence lifetime (p-adic spectral sequence collapse)

**Conjecture.** Over `ℤ_[p]`, the persistence *barcode* of a finite point cloud has bars
whose endpoints are exactly powers `p^{-k}` (the realised p-adic distances), and the
β₀ persistence diagram is supported on the `valuation-depth lattice` `{p^{-k} : k ∈ ℕ}`.
Concretely, `persistentBetti0` of a finite subset of `ℤ_[p]` only changes at scales
`ε = p^{-k}`, tying topological lifetime directly to `PadicValuationDepth` complexity.

**Lean target.** `persistentBetti0 S ε = persistentBetti0 S (p ^ (-⌈log_p ε⌉))`-style
quantisation lemma for finite `S ⊆ ℤ_[p]`.

**Falsifiable.** A jump at a non-`p^{-k}` scale would refute it; testable on explicit
finite p-adic samples.

---

## C5. Tropical lower bound is the *only* sharp bound (higher Betti obstruction)

**Conjecture.** The packing=β₀ identity is special to dimension 0: for the full
Vietoris–Rips complex over an ultrametric space, *all* higher persistent Betti numbers
vanish, `βₖ(ε) = 0` for `k ≥ 1` and `ε ≥ 0`, because the ultrametric nerve is a disjoint
union of *cliques* (each ε-ball is complete), which is homotopy-equivalent to a discrete set.

**Lean target.** Show `ripsGraph α ε` restricted to one component is the complete graph
(`IsUltrametric ⟹ component ⇒ ⊤`), hence the Rips complex is a disjoint union of simplices;
conclude reduced homology is concentrated in degree 0.

**Falsifiable.** Any ultrametric point cloud exhibiting a persistent 1-cycle would refute
it — a strong, clean, checkable claim that would, if false, reveal genuinely non-trivial
non-Archimedean persistent topology.
