# Future Directions: Functorial Entropy

## Synthesis

This research cycle established a rigorous, machine-verified theory of **functorial entropy** for functions between finite types. The central achievement is the **post-composition monotonicity theorem** (H(g ∘ f) ≥ H(f)), proved via the superadditivity of x·log(x) — the functorial analog of the data processing inequality from information theory. The **Entropy–Shannon Bridge** (H(f) = Σ p_b·log|α| + Σ p_b·log(p_b)) connects our theory directly to classical Shannon entropy, while the **entropy defect** δ(f,g) = H(g∘f) − H(f) introduces a novel measure of incremental information loss.

The most promising cross-domain connection is the bridge between functorial entropy and the Catalog's existing work on reversible computation (the `reversible_zero_entropy_cost` family of theorems in `Computation/InformationEntropy.lean` and `Computation/ReversibleTropicalMachine.lean`). Our Landauer cost formalization — proving that bijective functions have zero cost and all costs are nonneg — provides the mathematical foundation for these results. The connection to tropical algebra (via `Speculative/AutoResearch/SpectralTropicalEntropy.lean`) suggests that functorial entropy may have a natural tropicalization, replacing log with the identity and sum with max.

The highest breakthrough potential lies in Direction 1 (Surjective Composition Superadditivity), which if proved would complete the information-theoretic characterization of functorial entropy. Direction 3 (Entropy Rate Convergence) has the most novel mathematical content, potentially connecting dynamical systems theory with categorical information theory and establishing functorial entropy rate as a topological invariant.

---

### Direction 1: Surjective Composition Superadditivity via the Log-Sum Inequality

**Conjecture**: For any surjective function f : α → β and any function g : β → γ between finite nonempty types:

H(g) ≤ H(g ∘ f)

where H(h) = Σ_c (fiberCard(h, c) / |domain(h)|) · log(fiberCard(h, c)).

This states that pre-composing with a surjection cannot decrease functorial entropy.

**Test**: Exhaustively verify for all surjections f : Fin n → Fin m and all g : Fin m → Fin k with n ≤ 8. A single counterexample disproves the conjecture. For computational testing, use the Python implementations provided in this cycle's `demo.py`.

**Impact**: If true, this completes the "functorial data processing inequality" — entropy is monotone with respect to both pre- and post-composition. Combined with the existing post-composition result, this would mean that for any composable triple f, g, h: H(f) ≤ H(g ∘ f) ≤ H(h ∘ g ∘ f). If false, the counterexample would reveal when pre-composition can decrease entropy, pointing to a deeper structural constraint.

**Catalog References**: `Speculative/FunctorialEntropy.lean` (this cycle), `Computation/InformationEntropy.lean` (Shannon entropy definitions and bounds)

**Proof Strategy**: The key difficulty is that pre-composition with f changes both the fiber sizes AND the denominator (|α| vs |β|). Two approaches:
1. **Log-sum inequality**: The inequality Σ a_i · log(a_i/b_i) ≥ (Σ a_i) · log(Σ a_i / Σ b_i) might apply if we can express the entropy difference in KL-divergence form.
2. **Jensen's inequality on grouped fibers**: For each c, write fiberCard(g∘f, c) = Σ_{b:g(b)=c} fiberCard(f, b) and use the convexity of x·log(x) together with the constraint Σ_b fiberCard(f, b) = |α|.
3. **Direct algebraic manipulation**: Show that |β| · Σ_c fiberCard(g∘f,c) · log(fiberCard(g∘f,c)) ≥ |α| · Σ_c fiberCard(g,c) · log(fiberCard(g,c)) by exploiting the relationship fiberCard(g∘f,c) ≥ fiberCard(g,c) and the superadditivity of xlog.

**Domain Bridges**: Information Theory <-> Category Theory <-> Combinatorics

**Lineage**: Builds on `composition_entropy_monotone` and `xlog_superadditive` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Functorial Entropy and the Min-Plus Bridge

**Conjecture**: Define the *tropical functorial entropy* as:

H_trop(f) = max_{b ∈ β} fiberCard(f, b)

(replacing Σ with max and log with the identity, following the standard tropicalization recipe). Then:
1. H_trop(g ∘ f) ≥ H_trop(f) (tropical composition monotonicity)
2. H_trop(f) = 1 if and only if f is injective
3. There exists a natural "detropicalization" family parameterized by t > 0 that interpolates between H_trop and H via H_t(f) = t · log(Σ_b exp(fiberCard(f,b)/t))

**Test**: Verify properties (1)-(2) for all functions between types of size ≤ 6. For (3), numerically compute H_t for several functions and verify that H_t → H_trop as t → 0+ and H_t → H as t → ∞ (after appropriate normalization).

**Impact**: If the detropicalization works, it creates a one-parameter family connecting functorial entropy to tropical geometry, opening the door to applying tropical methods (polyhedral combinatorics, Maslov dequantization) to information theory.

**Catalog References**: `Tropical/InformationTheory.lean` (tropical mutual information), `Speculative/AutoResearch/SpectralTropicalEntropy.lean` (spectral tropical entropy), `Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean`

**Proof Strategy**: Property (1) follows from the fact that the maximum fiber of g∘f is at least as large as the maximum fiber of f (since fibers of g∘f are unions of fibers of f). Property (2) is immediate. For (3), study the family of generalized means and their connection to Rényi entropy of order α.

**Domain Bridges**: Tropical Algebra <-> Information Theory <-> Statistical Mechanics

**Lineage**: Builds on this cycle's entropy definitions and the Catalog's tropical information theory.

**Ambition**: extension

---

### Direction 3: Entropy Rate Convergence for Endomorphisms

**Conjecture**: For any endomorphism f : α → α on a finite type:
1. The sequence h(f, n) = H(f^n) / n is eventually non-increasing.
2. The limit h_∞(f) = lim_{n→∞} h(f, n) exists and equals H(f^k) / k for some k ≤ |α|.
3. h_∞(f) = 0 if and only if f^k is a bijection on its eventual image for some k.

**Test**: Compute h(f, n) for all endomorphisms of Fin 4 and Fin 5 for n up to 20. Check whether the sequence stabilizes and whether the stabilization point k divides |α|!.

**Impact**: If the entropy rate converges, it defines a topological invariant of the dynamical system (α, f) that is computable in finite time. This would connect functorial entropy to symbolic dynamics and topological entropy. If part (3) holds, it gives a computationally efficient test for eventual bijectivity.

**Catalog References**: `Speculative/FunctorialEntropy.lean` (entropy rate definition), `Computation/InformationEntropy.lean`

**Proof Strategy**: For (1), use the composition monotonicity theorem: H(f^{n+1}) = H(f ∘ f^n) ≥ H(f^n), but we need H(f^{n+1})/(n+1) ≤ H(f^n)/n, which requires showing H(f^{n+1}) ≤ ((n+1)/n) · H(f^n). This may follow from the subadditivity of entropy: H(f^{m+n}) ≤ H(f^m) + H(f^n) · correction_factor. For (2), monotone bounded sequences converge. For (3), relate eventual bijectivity to fiber stabilization.

**Domain Bridges**: Dynamical Systems <-> Information Theory <-> Combinatorics on Finite Sets

**Lineage**: Builds on `entropyRate_one` and `composition_entropy_monotone` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Entropy Defect Algebra and Cocycle Conditions

**Conjecture**: The entropy defect satisfies a cocycle-like identity: for composable f : α → β, g : β → γ, h : γ → δ:

δ(f, h ∘ g) = δ(f, g) + δ(g ∘ f, h) − δ(g, h) + correction(f, g, h)

where the correction term involves the "interaction" between the fiber structures. In particular:
1. If g is bijective, then δ(f, h ∘ g) = δ(f, h) (bijective post-processing adds no defect).
2. The correction term vanishes when the fibers of g align with the fibers of h.

**Test**: Compute δ for all triples of composable functions between types of size ≤ 4. Check whether the correction term has a clean closed-form expression.

**Impact**: If the entropy defect satisfies a cocycle condition, it defines a cohomology class in a suitable category of functions. This would connect information theory to homological algebra and could lead to obstruction-theoretic results about information processing.

**Catalog References**: `Speculative/FunctorialEntropy.lean` (entropy defect definition and properties)

**Proof Strategy**: Start by computing δ(f, h ∘ g) in terms of fiber cardinalities and comparing with the proposed decomposition. Use the fiber decomposition theorem (fiberCard_comp) to relate the fiber structures. The correction term should emerge from the non-additivity of the xlog function when fibers don't align.

**Domain Bridges**: Homological Algebra <-> Information Theory <-> Category Theory

**Lineage**: Builds on `entropyDefect_nonneg` and `entropyDefect_id` from this cycle.

**Ambition**: extension

---

### Direction 5: Functorial Entropy for Finite Categories

**Conjecture**: Extend functorial entropy to functors F : C → D between finite categories by defining:

H(F) = Σ_{d ∈ Ob(D)} Σ_{m ∈ Mor(D, d, d)} weighted_fiber_entropy(F, d, m)

where the sum weights the entropy contribution of each morphism fiber. Then:
1. Natural isomorphisms have zero entropy.
2. Post-composition with a functor G satisfies H(G ∘ F) ≥ H(F).
3. For discrete categories (only identity morphisms), this reduces to functorial entropy of the object map.

**Test**: Implement for small categories (groups of order ≤ 6 viewed as one-object categories, posets of size ≤ 5). Verify properties (1)-(3) computationally.

**Impact**: This would establish functorial entropy as a genuine categorical invariant, not just a set-theoretic one. It could measure the information loss of database schema transformations (functors between categories of tables), network protocol translations, and compiler passes (functors between syntax categories).

**Catalog References**: `Speculative/FunctorialEntropy.lean`, `Bridges/AlgebraEMLClosureComputation.lean`

**Proof Strategy**: The main challenge is defining the correct weighting for morphism fibers. For the object-level entropy, use the existing theory. For morphism-level entropy, define fiberCard for hom-sets and weight by category size. Property (3) should be immediate from the definition. Properties (1)-(2) require lifting the xlog superadditivity to the categorical setting.

**Domain Bridges**: Category Theory <-> Information Theory <-> Database Theory <-> Compiler Theory

**Lineage**: Builds on all results from this cycle, especially composition_entropy_monotone.

**Ambition**: extension
