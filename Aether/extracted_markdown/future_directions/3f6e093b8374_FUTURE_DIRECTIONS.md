# Future Directions: Functorial Entropy

## Synthesis

This research cycle established a rigorous theory of **functorial entropy** for functions between finite types and lifted it to functors between finite categories. The central achievement is the **post-composition monotonicity theorem** (H(g ∘ f) ≥ H(f)), proved via the superadditivity of t·log(t), which is the functorial analog of the data processing inequality from information theory. The **Entropy–Shannon Bridge** (H(f) = log|α| − H_Shannon(fiber distribution)) connects our theory directly to 75 years of information-theoretic results.

The most promising cross-domain connection is between the **Landauer cost** formalization and **reversible computation theory**. The theorem that reversible computations have zero Landauer cost, combined with composition monotonicity, suggests that functorial entropy could serve as a complexity measure for computational irreversibility. This connects to the Catalog's existing work on `ReversibleTropicalMachine` and `zero_uniform_entropy_loss_iff_bijective`, creating a bridge between tropical algebra and information theory.

The highest breakthrough potential lies in Direction 1 (Composition Superadditivity), which if proved would complete the information-theoretic characterization of functorial entropy and connect to the log-sum inequality — one of the deepest inequalities in information theory. Direction 3 (Entropy Rate of Endofunctors) has the most novel mathematical content, potentially connecting dynamical systems theory with categorical information theory.

---

### Direction 1: Composition Superadditivity via the Log-Sum Inequality

**Conjecture**: For any surjective function f : α → β and any function g : β → γ between finite nonempty types:

H(g) ≤ H(g ∘ f)

where H(h) = ∑_c (fiberCard(h, c) / |domain|) · log(fiberCard(h, c)).

This states that pre-composing with a surjection cannot decrease functorial entropy — the "other half" of the data processing inequality.

**Test**: Computationally verify for all functions f : Fin n → Fin m (surjective) and g : Fin m → Fin k for n, m, k ≤ 6. Any counterexample would disprove the conjecture; survival across all small cases would strengthen evidence.

**Impact**: If true, combined with the already-proved post-composition monotonicity (H(g ∘ f) ≥ H(f)), this would give a complete characterization: composition can only increase entropy, regardless of whether the additional function is applied before or after. This mirrors the full data processing inequality in classical information theory and would be the first functorial proof of this principle.

**Catalog References**: `Speculative/AutoResearch/FunctorialEntropy/Core.lean` (composition_entropy_conjecture), `Computation/ReversibleTropicalMachine.lean` (zero_uniform_entropy_loss_iff_bijective)

**Proof Strategy**: The key difficulty is comparing H(g) (defined over β) with H(g∘f) (defined over α), where the domains differ. Write H(g) = log|β| − S(q) and H(g∘f) = log|α| − S(r) where q, r are the respective fiber distributions and S is Shannon entropy. Then we need log(|α|/|β|) ≥ S(r) − S(q). The fiber distribution r is a "dilation" of q obtained by replacing each point mass at q(c) = n_c/|β| with r(c) = m_c/|α| where m_c = ∑_{b∈g⁻¹(c)} fiberCard(f,b) ≥ n_c. The log-sum inequality (∑ aᵢ log(aᵢ/bᵢ) ≥ (∑ aᵢ) log((∑ aᵢ)/(∑ bᵢ))) applied with aᵢ = m_c and bᵢ = n_c may yield the result. Alternatively, use Schur-convexity of the entropy functional.

**Domain Bridges**: Information Theory ↔ Category Theory, Thermodynamics ↔ Algebra

**Lineage**: Builds on `functorialEntropy'_comp_ge` (proved this cycle) and the superadditivity inequality `mul_log_add_le`.

**Ambition**: grand_challenge

---

### Direction 2: Entropy of Forgetful Functors on Finite Groups

**Conjecture**: Define the "abelianization entropy" for finite groups of order ≤ n:

H_ab(n) = ∑_{[G]≤n} (number of groups with same abelianization as G) / (total groups of order ≤ n) · log(number of groups with same abelianization as G)

Then H_ab(n) grows as Θ(n^{2/3}) as n → ∞, reflecting the fact that the number of non-abelian groups with a given abelianization grows polynomially.

**Test**: Compute H_ab(n) for n ≤ 100 using the GAP computer algebra system's SmallGroups library. Plot H_ab(n)/n^{2/3} and check convergence to a constant.

**Impact**: If the growth rate is confirmed, this would quantify the precise "information cost" of forgetting non-commutativity in group theory. It would also connect to the famous question of counting groups of a given order, since the entropy depends on the fiber structure of the abelianization functor.

**Catalog References**: `Speculative/AutoResearch/FunctorialEntropy/CategoryEntropy.lean` (functorObjEntropy), `Algebra/Basic.lean`

**Proof Strategy**: Upper bound: the number of groups of order n is at most n^{cn^{2/3}} (Higman-Sims), and most are p-groups. Lower bound: construct explicit families of non-abelian groups with the same abelianization (e.g., direct products of the form G × Z/2Z) to show that typical fibers grow. The key lemma needed: for a prime p, the number of groups of order p^k with abelianization (Z/pZ)^r grows at least as p^{ck²} for some constant c depending on r.

**Domain Bridges**: Group Theory ↔ Information Theory ↔ Combinatorics

**Lineage**: Extends the functorObjEntropy definition from this cycle to specific algebraic functors.

**Ambition**: grand_challenge

---

### Direction 3: Entropy Rate of Endofunctors

**Conjecture**: For an endofunctor F : C → C on a finite category C, define the *entropy rate*:

h(F) = lim_{n→∞} H(Fⁿ.obj) / n

where Fⁿ is the n-fold composition. Conjecture: h(F) = 0 if and only if the sequence of object maps F.obj, (F²).obj, ... eventually stabilizes (every orbit is eventually periodic).

**Test**: Compute H(Fⁿ.obj) for n ≤ 20 for various endofunctors on FinSet (e.g., the power-set functor restricted to {0,1,...,k}). Check whether h(F) converges and characterize when it equals zero.

**Impact**: This would create a dynamical systems theory for functors, connecting categorical algebra to ergodic theory. The entropy rate would measure the "information destruction speed" of a functor, analogous to the Kolmogorov-Sinai entropy of a measure-preserving transformation.

**Catalog References**: `Speculative/AutoResearch/FunctorialEntropy/Composition.lean` (functorialEntropy'_comp_ge), `Speculative/AutoResearch/FunctorialEntropy/CategoryEntropy.lean` (functorObjEntropy_comp_ge)

**Proof Strategy**: The existence of the limit follows from the subadditivity of H(Fⁿ.obj) (which is the content of composition monotonicity applied iteratively). For the zero-rate characterization, use the fact that on a finite set, every function eventually reaches a fixed-point cycle. If F.obj stabilizes, then H(Fⁿ.obj) is eventually constant, giving rate 0. Conversely, if the rate is 0, the orbit structure must be eventually constant because any non-trivial merging at each step contributes a fixed positive amount.

**Domain Bridges**: Dynamical Systems ↔ Category Theory ↔ Information Theory

**Lineage**: Builds on functorialEntropy'_comp_ge and the composition monotonicity framework.

**Ambition**: extension

---

### Direction 4: Tropical Entropy and the Max-Plus Data Processing Inequality

**Conjecture**: Define tropical functorial entropy by replacing (sum, product) with (max, plus):

H_trop(f) = max_{b ∈ β} (fiberCard(f, b) / |α| + log(fiberCard(f, b)))

Then H_trop satisfies a tropical analog of composition monotonicity: H_trop(g ∘ f) ≥ H_trop(f). Moreover, H_trop(f) = 0 iff f is injective.

**Test**: Verify the tropical composition inequality for all functions f : Fin n → Fin m and g : Fin m → Fin k for n, m, k ≤ 8.

**Impact**: Would connect functorial entropy to the Catalog's extensive tropical mathematics infrastructure, creating a bridge between information theory and tropical algebraic geometry.

**Catalog References**: `Tropical/FiberEntropy.lean`, `Tropical/EntropyTropicalDuality.lean`, `Speculative/AutoResearch/SpectralTropicalEntropy.lean`

**Proof Strategy**: The tropical version replaces the sum with a max, which simplifies the analysis. The monotonicity should follow from the monotonicity of max: for each c, the merged fiber of g∘f over c contains a sub-fiber of f over some b with g(b) = c, so the max fiber size can only increase. The zero characterization is simpler: if any fiber has size > 1, the max term is positive.

**Domain Bridges**: Tropical Mathematics ↔ Information Theory ↔ Category Theory

**Lineage**: Connects to `entropy_nonneg_sum_bound` from SpectralTropicalEntropy.lean and the tropical-entropy duality framework.

**Ambition**: extension

---

### Direction 5: Information Channels as a Category

**Conjecture**: Define a category **InfoChan** whose objects are finite types and whose morphisms f : α → β are functions equipped with their functorial entropy H(f). Composition is ordinary function composition with entropy given by H(g ∘ f). Conjecture: the entropy function H : Mor(InfoChan) → ℝ≥0 is a **lax monoidal functor** from (InfoChan, ∘) to (ℝ≥0, +), meaning H(g ∘ f) ≥ H(f) + H(g) is FALSE in general, but H is a lax transformation in the sense that H(g ∘ f) ≥ H(f) (already proved).

**Test**: Find concrete functions where H(g ∘ f) < H(f) + H(g) (expected) and where H(g ∘ f) > H(f) + H(g) (also expected). This would show entropy is neither sub- nor super-additive under composition, but is bounded below by each component.

**Impact**: Would formalize the categorical structure of information processing pipelines, giving a mathematical foundation for data flow analysis in compilers and signal processing.

**Catalog References**: `Speculative/AutoResearch/FunctorialEntropy/CategoryEntropy.lean` (EntropyMorphism), `Speculative/AutoResearch/FunctorialEntropy/Core.lean` (InformationChannel)

**Proof Strategy**: Construct explicit examples. For sub-additivity failure: take f : Fin 4 → Fin 2 (fiber sizes 2,2) and g : Fin 2 → Fin 1. Then H(f) = log(2), H(g) = log(2), H(g∘f) = log(4) = 2·log(2) = H(f) + H(g). For super-additivity failure: take f : Fin 3 → Fin 2 (fiber sizes 1,2) and g = id. Then H(f) = (2/3)·log(2), H(g) = 0, H(g∘f) = H(f) = H(f) + H(g). Need a case where strict inequality holds both ways.

**Domain Bridges**: Category Theory ↔ Computer Science ↔ Information Theory

**Lineage**: Builds on InformationChannel and EntropyMorphism structures defined this cycle.

**Ambition**: extension
