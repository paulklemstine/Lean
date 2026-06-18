# Future Directions: Functorial Entropy

## Synthesis

This research cycle established a rigorous theory of **functorial entropy** for functions between finite types, proving three main theorems: the zero-entropy characterization (H(f) = 0 iff f is injective), post-composition monotonicity (H(g ∘ f) ≥ H(f)), and entropy stabilization for endomorphisms. The most significant result is the post-composition monotonicity theorem, which is a purely combinatorial proof of the data processing inequality using the superadditivity of t·log(t). This theorem connects directly to Landauer's principle in computational thermodynamics.

The highest breakthrough potential lies in **Direction 1 (Composition Superadditivity)**, which would complete the bilateral data processing inequality. If proved, it would establish that functorial entropy is fully compatible with both pre- and post-composition, making it a genuine invariant of the composition structure of functions. This connects to the log-sum inequality — one of the deepest results in information theory. The most novel mathematical territory is **Direction 3 (Entropy Spectrum Characterization)**, which links the theory to partition theory, dynamical systems, and combinatorics in a way that could produce new number-theoretic results.

The bridge between functorial entropy and the Catalog's tropical semiring work (via `Tropical/InformationTheory.lean` and `Tropical/TropicalEntropyCompact.lean`) is the most promising cross-domain connection. The tropical data processing inequality operates in the min-plus algebra, while our functorial DPI operates in the standard real algebra — showing that both are shadows of a deeper categorical principle would unify two parallel streams of information-theoretic formalization.

---

### Direction 1: Composition Superadditivity via the Log-Sum Inequality

**Conjecture**: For any surjective function f : α → β and any function g : β → γ between finite nonempty types:

H(g) ≤ H(g ∘ f)

where H(h) = ∑_c (fiberCard(h, c) / |domain(h)|) · log(fiberCard(h, c)).

**Test**: Verify computationally for all functions f : Fin 4 → Fin 3 (surjective) and g : Fin 3 → Fin 2. If any counterexample exists, the conjecture is false. If all ~500 cases pass, attempt a formal proof.

**Impact**: If true, combined with post-composition monotonicity, this would establish that functorial entropy is monotone under both pre-composition (with surjections) and post-composition (with arbitrary functions). This is the complete bilateral data processing inequality for deterministic channels. If false, the failure would reveal that the surjectivity condition is insufficient and point toward the correct hypothesis.

**Catalog References**: `FINAL/Tropical/InformationTheory.lean` (tropical_mutual_information_data_processing), `FINAL/Tropical/TropicalEntropyCompact.lean` (tropical_data_processing)

**Proof Strategy**: The key step is to relate the fiber sizes of g∘f to those of g through the surjectivity of f. For each c ∈ γ, fiberCard(g∘f, c) = ∑_{g(b)=c} fiberCard(f, b). Since f is surjective, each fiberCard(f, b) ≥ 1. The ratio fiberCard(g∘f, c)/|α| can be related to fiberCard(g, c)/|β| via the average fiber size |α|/|β|. The log-sum inequality would then give the result. Key auxiliary lemma: for surjective f, the fiber distribution of g∘f is a "refinement" of the fiber distribution of g, weighted by the fiber sizes of f.

**Domain Bridges**: Information Theory (DPI) <-> Combinatorics (fiber partitions) <-> Convex Analysis (log-sum inequality)

**Lineage**: Builds on post-composition monotonicity (entropy_comp_ge) and superadditivity lemmas from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical-Real Entropy Correspondence

**Conjecture**: There exists a deformation parameter q ∈ (0,1] such that the functorial entropy H(f) is the q → 1 limit of a tropical entropy H_q(f) defined using the (min, +) semiring, and the tropical data processing inequality (from `tropical_data_processing`) is the q → 0 limit of the post-composition monotonicity theorem.

**Test**: Define H_q(f) = (1/(q-1)) · log(∑_b (fiberCard(f,b)/|α|)^q) (the Rényi entropy of the fiber distribution). Verify that lim_{q→1} H_q = H (Shannon) and lim_{q→∞} H_q = log(max_b fiberCard(f,b)) (tropical/max entropy). Implement numerical verification for f : Fin 5 → Fin 3.

**Impact**: If true, this would unify the tropical and classical data processing inequalities as endpoints of a one-parameter family, revealing both as shadows of a deeper Rényi-entropy DPI. This would bridge the Catalog's tropical information theory with the new functorial entropy theory.

**Catalog References**: `FINAL/Tropical/InformationTheory.lean`, `FINAL/Tropical/TropicalEntropyCompact.lean`, `FINAL/Tropical/TropicalAdvancedTheory.lean`

**Proof Strategy**: Define the Rényi fiber entropy as a noncomputable function parameterized by q : ℝ. Prove the Rényi DPI (H_q(g∘f) ≥ H_q(f)) for all q ≥ 0 using the convexity of x^q. Then take limits. The tropical case (q → ∞) should recover max-fiber entropy, connecting to the min-plus formulation.

**Domain Bridges**: Tropical Geometry (min-plus algebra) <-> Information Theory (Rényi entropy) <-> Analysis (convexity families)

**Lineage**: Builds on entropy_comp_ge, mul_log_superadditive, and the tropical DPI theorems in the Catalog.

**Ambition**: grand_challenge

---

### Direction 3: Entropy Spectrum Characterization for Fin n

**Conjecture**: For α = Fin n with n ≥ 2, the entropy spectrum Spec(Fin n) is a finite subset of [0, log n] whose cardinality grows at least as fast as the partition function p(n).

**Test**: Compute Spec(Fin n) exactly for n = 2, 3, 4, 5 by enumerating all endomorphisms and computing their entropy rates. Compare |Spec(Fin n)| with p(n). For n = 4, there are 4^4 = 256 endomorphisms to check.

**Impact**: If the spectrum is determined by the partition structure, this would establish a direct connection between functorial entropy and the combinatorics of integer partitions. If the spectrum has unexpected structure (gaps, clustering), this would reveal new constraints on which information-loss patterns are dynamically achievable.

**Catalog References**: `Tropical/FunctorialEntropy/EntropyRate.lean` (entropySpectrum, zero_mem_entropySpectrum, entropySeq_eventually_const)

**Proof Strategy**: For each partition λ = (λ₁, ..., λ_k) of n, construct an endomorphism f whose eventual fiber structure realizes λ. Show that distinct partitions yield distinct entropy rates (using the strict convexity of t·log(t) to distinguish weighted sums). For the lower bound, show that every partition of n is dynamically achievable as the fiber structure of some f^N.

**Domain Bridges**: Number Theory (partition function) <-> Dynamical Systems (eventual image) <-> Information Theory (entropy rates)

**Lineage**: Builds on entropySeq_eventually_const, entropyRate_of_bijective, and zero_mem_entropySpectrum from this cycle.

**Ambition**: extension

---

### Direction 4: Categorical Entropy for Finite Functors

**Conjecture**: For a functor F : C → D between finite categories (finitely many objects and morphisms), define the **categorical entropy** as H(F_obj) + H(F_mor|F_obj), where H(F_obj) is the functorial entropy of the object map and H(F_mor|F_obj) is the conditional entropy of the morphism map given the object map. Then: (a) H_cat(F) = 0 iff F is faithful and injective on objects; (b) H_cat(G ∘ F) ≥ H_cat(F) for natural transformations.

**Test**: Implement for the category Fin n (objects = elements of Fin n, only identity morphisms) and verify that categorical entropy reduces to functorial entropy. Then test for the free category on a directed graph with ≤ 4 vertices.

**Impact**: If true, this would extend the entire functorial entropy theory from Set to Cat, making entropy a genuine invariant of categorical structure. The characterization H_cat = 0 iff faithful+injective-on-objects would be a new result in categorical information theory.

**Catalog References**: `Tropical/FunctorialEntropy/Core.lean` (all definitions), `Catalog/Geometry/CategoricalTower.lean`

**Proof Strategy**: Define FinCat as a structure with finite object and morphism types, composition, and identity. Define FunctorialMap between FinCats. The entropy decomposes as object entropy + conditional morphism entropy by the chain rule for Shannon entropy. Post-composition monotonicity should follow from applying the DPI to both components separately.

**Domain Bridges**: Category Theory (functors, faithfulness) <-> Information Theory (conditional entropy, chain rule) <-> Algebra (finite categories)

**Lineage**: Builds on all Core.lean and DataProcessing.lean results from this cycle.

**Ambition**: extension

---

### Direction 5: Entropy-Optimal Factorizations

**Conjecture**: Every function f : α → β between finite nonempty types admits a unique factorization f = i ∘ π where π : α → image(f) is the surjection onto the image and i : image(f) ↪ β is the inclusion. Furthermore, H(f) = H(π) (all the entropy is in the surjection) and this factorization is entropy-optimal: for any other factorization f = g ∘ h, we have H(h) ≤ H(f).

**Test**: Verify H(f) = H(π) for all functions f : Fin 4 → Fin 4. Verify the optimality claim for all factorizations of all functions f : Fin 3 → Fin 3.

**Impact**: If true, this canonical factorization would be the information-theoretic analog of the epi-mono factorization in category theory. It would show that the "information-destroying part" of any function is precisely its surjective core. This connects to the Catalog's compression theory in `FINAL/Pythagorean/CompressionStability.lean`.

**Catalog References**: `FINAL/Pythagorean/CompressionStability.lean` (data_processing_inequality_for_measurementInvariant), `Tropical/FunctorialEntropy/DataProcessing.lean`

**Proof Strategy**: The factorization f = i ∘ π exists by the universal property of the image. Since i is injective, H(i) = 0 (or rather, H(i) contributes nothing since injective functions have zero entropy). By the chain rule interpretation, H(f) = H(π) + H(i|π) = H(π) + 0 = H(π). For optimality, any factorization f = g ∘ h means h refines the fiber structure of f, and by the DPI, H(h) ≤ H(g ∘ h) = H(f).

**Domain Bridges**: Category Theory (epi-mono factorization) <-> Information Theory (source coding) <-> Compression Theory (optimal compression)

**Lineage**: Builds on entropy_of_injective and entropy_comp_ge from this cycle.

**Ambition**: extension
