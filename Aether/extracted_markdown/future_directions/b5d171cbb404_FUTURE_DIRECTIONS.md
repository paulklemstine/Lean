# Future Directions: Compression Stability and Categorical Observability

## Synthesis

The compression stability results established in this work — monotonicity, rigidity, strict gain, and the full iff characterization — reveal that probe families on finite presheaves form an **information preorder** with rich structural properties. This opens a research program connecting categorical measurement theory to information theory, statistical experiment comparison, and computational complexity. The five directions below range from incremental extensions (Directions 3–5) to paradigm-shifting conjectures (Directions 1–2) that would, if proved, establish a full categorical information theory.

---

## Direction 1: Quantitative Information Gap and Categorical Entropy

**Conjecture:** There exists a natural "categorical entropy" function H(P, F, r) such that:
- H is monotone in P (data processing inequality).
- H(P) = H(P') iff NoNewSeparation(P, P') (equality characterization).
- H satisfies a chain rule: H(P ∪ Q) + H(P ∩ Q) ≤ H(P) + H(Q) (submodularity).
- H reduces to Shannon entropy when the presheaf encodes a probabilistic model.

**Test:** Define H(P) = Σ_Y log(μ_Y(P)) or H(P) = Σ_Y f(μ_Y(P)) for various concave f. Verify submodularity computationally on all presheaves over ≤ 4-object categories. A single counterexample to submodularity for any candidate function refutes that candidate. Exhaustive testing over 3-object categories with fibers of size ≤ 4 is feasible (~10^6 presheaves).

**Impact:** Would establish a full categorical information theory with entropy, conditional entropy, mutual information, and capacity — extending Shannon theory from probability distributions to presheaves.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionStability.lean` — `measurementInvariant_mono`, `measurementInvariant_eq_iff_noNewSeparation`
- `Pythagorean/ProbeComplexity/RepresentableDimension.lean` — `measurementInvariant_eq_objectwiseTotalCard`

**Proof Strategy:** Define H(P) = Σ_Y log₂(μ_Y(P)). Prove submodularity by showing μ_Y(P ∪ Q) · μ_Y(P ∩ Q) ≤ μ_Y(P) · μ_Y(Q) at each object Y, which reduces to a combinatorial identity about image cardinalities of product vs. projected signatures.

**Domain Bridges:** Information theory (Shannon entropy), combinatorics (matroid rank functions), physics (von Neumann entropy).

**Lineage:** Extends `measurementInvariant_mono` from order to quantitative metric.

**Ambition:** Grand challenge — would unify categorical probe theory with classical information theory.

---

## Direction 2: Blackwell Ordering of Probe Families

**Conjecture:** For finite presheaves, the following are equivalent:
1. P.Refines(P', r) (our refinement relation).
2. For every "decision problem" D : Ob → Set and "loss function" L, the optimal expected loss under P is ≤ that under P' (Blackwell sufficiency).
3. There exists a "garbling" map T such that sig_P = T ∘ sig_{P'}.

**Test:** Formalize conditions (2) and (3) for discrete presheaves. Computationally verify equivalence (1) ⟺ (3) on all presheaves over 3-object categories with fibers of size ≤ 3 (feasible). Condition (2) requires defining a class of decision problems; test with all possible loss functions on categories with ≤ 4 objects.

**Impact:** Would establish a categorical Blackwell theorem — the definitive comparison principle for experiments in category theory.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionStability.lean` — `ObProbeFamily.Refines`, `probeSignature_refines`
- `Pythagorean/ProbeComplexity/Theorems.lean` — `ProbeFamily.IsSeparating.supset`

**Proof Strategy:** For (1) ⟹ (3): construct T by defining it on image(sig_{P'}) using the refinement hypothesis. For (3) ⟹ (1): use functoriality of T. For the Blackwell direction, adapt Le Cam's randomization criterion to the deterministic setting.

**Domain Bridges:** Statistics (sufficient statistics, Blackwell ordering), decision theory, experiment design.

**Lineage:** Extends `ObProbeFamily.refines_of_subset` to a full experiment comparison theory.

**Ambition:** Grand challenge — would connect categorical measurement to 70 years of statistical decision theory.

---

## Direction 3: Minimum Separating Probe Complexity

**Conjecture:** For a finite presheaf F on n objects with maximum fiber size m, the minimum separating probe family has size at most ⌈log₂(m)⌉ + 1 (logarithmic in the distinguishability requirement).

**Test:** Compute the minimum separating probe family for all presheaves on categories with 3–5 objects and fiber sizes ≤ 5. Record the minimum and compare to ⌈log₂(max_Y |F(Y)|)⌉ + 1. A single presheaf requiring more than this bound refutes the conjecture.

**Impact:** Would establish tight complexity bounds for optimal sensor placement, feature selection, and experimental design.

**Catalog References:**
- `Pythagorean/ProbeComplexity/Theorems.lean` — `probeComplexity_le_card`
- `Pythagorean/ProbeComplexity/Defs.lean` — `probeComplexity`, `ProbeFamily.IsSeparating`

**Proof Strategy:** Upper bound: show that random probe selection achieves separation with high probability when |P| ≥ c · log(m). Lower bound: construct explicit presheaves requiring ⌈log₂(m)⌉ probes via Hadamard-style restriction matrices.

**Domain Bridges:** Combinatorics (set cover), coding theory (error-correcting codes), VC dimension theory.

**Lineage:** Strengthens `probeComplexity_le_card` from |Ob| to logarithmic bounds.

**Ambition:** Solid extension — directly actionable for sensor optimization.

---

## Direction 4: Product and Coproduct Formulas for Measurement Invariants

**Conjecture:** For presheaves F and G on the same category:
- μ(P, F × G) = μ(P, F) · μ(P, G) (product formula, when restrictions decompose).
- μ(P, F ⊔ G) = μ(P, F) + μ(P, G) (coproduct formula).

And the monotonicity/rigidity theorems lift to these compound constructions.

**Test:** Verify both formulas computationally on all pairs of presheaves over 2-object categories with fibers of size ≤ 3. A single counterexample refutes the conjecture; counterexamples to the product formula likely require restrictions that don't decompose as products.

**Impact:** Would enable compositional computation of measurement invariants, critical for scaling to large systems.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionProduct.lean`
- `Pythagorean/ProbeComplexity/CoproductSubadditivity.lean`
- `Pythagorean/ProbeComplexity/CompressionStability.lean` — all stability theorems

**Proof Strategy:** Product: show sig_P(x, y) = (sig_P(x), sig_P(y)) when restrictions decompose, then use |image(f × g)| = |image(f)| · |image(g)| for independent components. Coproduct: use disjointness of signature images.

**Domain Bridges:** Algebra (ring structure on invariants), physics (tensor products, superposition).

**Lineage:** Extends compression stability to compound systems.

**Ambition:** Solid extension — essential for practical scalability.

---

## Direction 5: Noisy Probe Families and Approximate Redundancy

**Conjecture:** There exists an ε-approximate version of NoNewSeparation where:
- P' is "ε-redundant over" P if at most ε-fraction of pairs are newly separated.
- Under ε-redundancy, μ(P) and μ(P') differ by at most δ(ε, |F|), for a computable function δ → 0 as ε → 0.

**Test:** Define ε-redundancy as: |{(x,y) : newly separated}| / |{(x,y) : total pairs}| ≤ ε. Compute the actual gap |μ(P') - μ(P)| for all (P, P', presheaf) triples over small categories. Fit the relationship between ε and the invariant gap. Refute if the gap grows unboundedly for fixed ε.

**Impact:** Would make the theory applicable to real-world noisy measurement systems where exact equivalence rarely holds.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionStability.lean` — `measurementInvariant_eq_iff_noNewSeparation`

**Proof Strategy:** Use a counting argument: if at most k pairs are newly separated, the partition can have at most k more classes, giving μ(P') ≤ μ(P) + k. Sharpen via Sauer-Shelah-type bounds if signatures have bounded VC dimension.

**Domain Bridges:** Robust statistics, approximate sufficient statistics, PAC learning.

**Lineage:** Relaxes the exact rigidity theorem to an approximate version.

**Ambition:** Solid extension — bridges theory to practice.
