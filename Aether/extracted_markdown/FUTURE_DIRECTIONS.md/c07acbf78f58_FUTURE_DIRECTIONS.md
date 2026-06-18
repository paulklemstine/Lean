# Future Directions: Holographic Dictionary — Valuations, Anomalies, and Entanglement Structure

## What We Proved

This cycle formalized the mathematical dictionary between holographic gravity and quantum error correction, centered on four main theorems:

1. **Modular Decomposition Theorem** (`modular_sum_singletons`): Every modular set function with f(∅)=0 decomposes as f(X) = ∑_{a∈X} f({a}). This classifies valuations on the Boolean lattice.

2. **Flatness–Atomicity Bridge** (`flat_profile_atomic`): Holographic entropy profiles with zero total defect decompose atomically — their entropy is determined purely by single-site values. Zero gravity ⟹ no entanglement beyond local data.

3. **Singleton Gap Nonnegativity** (`singleton_gap_nonneg`): The coding-theoretic "anomaly" Δ(X) = N(X) - 2D(X) + 2 - S(X) ≥ 0 always, with equality characterizing extremal (MDS-like) codes.

4. **MMI Four-Party & Five-Party Inequalities** (`mmi_four_party_ineq`, `mmi_five_party_ineq`): Monogamy of mutual information yields cyclic bounds on multi-party correlations beyond what strong subadditivity provides.

Supporting results include: modular functions form a vector space (closed under +, scalar ·, with 0), uniqueness of modular functions from singleton data, counterexamples showing submodularity alone is insufficient for atomic decomposition, entanglement wedge order structure (monotonicity and downward closure).

---

## Direction 1: Holographic Entropy Cone via Graph Cuts

The four-party inequality we proved has explicit correction terms (+S(A)+S(C)). The key insight is that for *disjoint* boundary regions with the RT formula (entropy = minimal cut), these correction terms should vanish, yielding a tight cyclic inequality I(A:C) + I(B:D) ≤ I(A:B) + I(B:C) + I(C:D) + I(D:A). Why now? We have the MMI infrastructure and the disjoint-region simplification (`normDefect_disjoint` equating defect with mutual information). The next step is to formalize RT as a minimum-cut computation on a graph and derive the tight inequality from cut structure.

**Testable conjecture**: For 4 pairwise-disjoint regions in a monogamous profile, the correction terms in `mmi_four_party_ineq` can be eliminated entirely. Formalize this as a strengthening conditional on disjointness.

---

## Direction 2: Tropical Limits of Submodular Profiles

The modular decomposition theorem shows flat profiles are "tropical points" — they live on the boundary of the submodularity cone where all inequalities become equalities. The key insight is that every modular profile arises as a limit of strictly submodular profiles under rescaling (tropical degeneration). Why now? The `modular_sum_singletons` theorem gives us the exact structure of modular profiles, and Mathlib's convex cone machinery can formalize the cone structure.

**Testable conjecture**: The modular profiles on `Finset (Fin n)` form a convex cone of dimension n, and every ray in this cone is the tropical limit (in the sense of lim_{t→∞} f_t/t) of a 1-parameter family of strictly submodular profiles. Prove this for n = 3.

---

## Direction 3: Singleton Gap as Approximate Error Correction Measure

We proved Δ(X) ≥ 0 and its monotonicity under code refinement. The key insight is that Δ should satisfy a *superadditivity* property Δ(X∪Y) ≥ Δ(X) + Δ(Y) for disjoint X, Y when N is additive and D is subadditive — this would make Δ a "measure of non-extremality" that grows under composition. Why now? The gap functional is now formalized with all needed axioms, and the additivity/subadditivity conditions on N, D are natural extensions of the existing `HoloStabilizerProfile`.

**Testable conjecture**: Define a `DisjointAdditiveProfile` extending `HoloStabilizerProfile` with N additive on disjoint regions and D subadditive. Prove Δ(X∪Y) ≥ Δ(X) + Δ(Y) for disjoint X, Y, or find a counterexample.

---

## Direction 4: Möbius Inversion and Higher-Order Defects

The modular decomposition uses only the "first-order" defect (pairwise). The key insight is that higher-order defects — the Möbius function of the defect poset — should capture higher-order entanglement structure. For k regions, define δ_k(X₁,...,X_k) as the alternating sum of entropies over all subsets of {X₁,...,X_k}. The tripartite information I₃ is δ₃. Why now? The existing `tripartiteInfo` and `normDefect` can be unified into a single k-ary defect functional, and Möbius inversion on the partition lattice is available in Mathlib.

**Testable conjecture**: For a monogamous profile, the k-th order defect δ_k has sign (-1)^k for all k ≤ n. This is the "complete monotonicity" conjecture for holographic entropy, generalizing MMI (the k=3 case). Test for k=4 on `Fin 4`.

---

## Direction 5: Categorical Wedge Reconstruction

We proved that reconstructable regions form an order ideal (downward-closed set) under anti-monotone distance. The key insight is that the assignment Y ↦ {X : Reconstructable D Y X} defines a *functor* from (Finset α, ⊆) to (Set (Finset α), ⊆), and this functor should have an adjoint (the "minimal enclosing boundary" map). Why now? The `reconstructable_monotone` theorem gives functoriality, and `reconstructable_downward` gives the order-ideal property. The adjoint would be the bulk-to-boundary map dual to entanglement wedge reconstruction.

**Testable conjecture**: Define the "reconstruction functor" R : Finset α → Set (Finset α) by R(Y) = {X | Reconstructable D Y X}. Prove that R is a monotone map (done: `reconstructable_monotone`). Then define the left adjoint L(S) = ⋂{Y | S ⊆ R(Y)} and prove it exists and is monotone. Show that L ∘ R = id on a suitable subcategory.
