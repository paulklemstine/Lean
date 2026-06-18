# Future Directions: Frankl's Union-Closed Conjecture

## Synthesis

The verified results in this project—the double-counting identity, the averaging criterion, and the small ground theorem—form a coherent *proof architecture* for Frankl's conjecture. They demonstrate three complementary attack strategies: counting arguments, structural case analysis, and lattice-theoretic abstraction. The directions below extend each strategy toward the full conjecture, with the most transformative being the entropic potential (Direction 1) and the lattice-algebraic approach (Direction 3). Together, they chart a path from the current frontier (ground size 3) through intermediate milestones (ground size 12, family size 50) toward the general conjecture.

---

## Direction 1: Entropic Potential and Gilmer-Style Bounds

**Conjecture:** There exists a concave functional $\Phi : \text{UCF} \to \mathbb{R}$ (the "entropic potential") such that $\Phi(\mathcal{F}) \geq 0$ for all union-closed families $\mathcal{F}$ with nonempty ground, and $\Phi(\mathcal{F}) \geq 0$ implies HasFranklWitness($\mathcal{F}$). Moreover, $\Phi$ is additive under a natural product construction on union-closed families.

**Test:** Define the candidate $\Phi(\mathcal{F}) = \sum_{a \in \text{ground}} h(\text{freq}(a) / |\mathcal{F}|)$ where $h(p) = -p \log p - (1-p)\log(1-p)$ is the binary entropy function. Compute $\Phi$ for all union-closed families on $\{1,\ldots,n\}$ for $n \leq 5$. Check whether $\Phi(\mathcal{F}) \geq 0$ always holds when normalized appropriately. A counterexample would be a family where this entropy-based bound fails to detect the witness.

**Impact:** This would unify Reimer's entropy method with Gilmer's breakthrough bound ($\text{freq} \geq 0.382 \cdot |\mathcal{F}|$), providing a single framework for quantitative Frankl bounds. The formalized averaging criterion (Theorem 4.1) is the "zeroth-order" version of this approach.

**Catalog References:** `Algebra/Frankl/AverageCriterion.lean` (averaging criterion as energy lower bound)

**Proof Strategy:** Formalize binary entropy in Lean 4, define $\Phi$ over union-closed families, prove monotonicity under subfamily restrictions, then derive the Frankl witness condition from positivity of $\Phi$.

**Domain Bridges:** Information theory (Shannon entropy), convex analysis (concavity of binary entropy), probability (random variable formulation of element frequencies).

**Lineage:** Extends the double-counting identity (Theorem 3.1) and averaging criterion (Theorem 4.1) to a full information-theoretic framework.

**Ambition:** Grand challenge — would resolve the conjecture in the information-theoretic regime and potentially yield the full conjecture via tensorization.

---

## Direction 2: Extended Ground Size Results (n ≤ 6)

**Conjecture:** The proof architecture from the ground size 3 case (combining singleton injection + averaging criterion) extends to ground size $n \leq 6$ with at most $O(n)$ additional structural lemmas.

**Test:** Attempt to prove Frankl for ground size 4 by: (a) handling the singleton case via Theorem 5.1, (b) handling the "no singletons, no ∅" case via the averaging criterion, (c) classifying the remaining "no singletons, ∅ ∈ F" case by bounding the number of possible set configurations. A failure would be a ground-4 configuration where neither the singleton injection nor the averaging criterion applies and direct case analysis requires more than polynomial many cases.

**Impact:** Extending verified results to ground size 6 would match the state of the art for formally verified Frankl results and demonstrate the scalability of the proof architecture.

**Catalog References:** `Algebra/Frankl/SmallGround.lean` (ground size ≤ 3), `Algebra/Frankl/DoubleCount.lean` (double counting)

**Proof Strategy:** For ground size 4: the non-singleton, non-empty-set case has sets of size ≥ 2. Total incidence ≥ 2(|F| - 1). Need 4|F| ≤ 2·totalIncidence, i.e., 4|F| ≤ 4(|F|-1), which fails for |F| ≤ 4. So handle |F| ≤ 4 with ∅ ∈ F separately (finitely many configurations). For ground sizes 5-6, refine the averaging bound by exploiting that most sets must have size ≥ 3 (when no singletons or pairs exist).

**Domain Bridges:** Finite combinatorics, exhaustive search, decision procedures.

**Lineage:** Direct extension of `frankl_ground_card_le_three`.

**Ambition:** Solid extension — incremental but validates the architecture.

---

## Direction 3: Lattice-Algebraic Frankl via Join-Irreducibles

**Conjecture (Join-Irreducible Witness Principle):** Every union-closed family $\mathcal{F}$ with nonempty ground has a Frankl witness $a$ such that $a$ belongs to some join-irreducible set in $\mathcal{F}$.

**Test:** For each union-closed family on $\{1,\ldots,n\}$ with $n \leq 6$: (1) compute all join-irreducible sets, (2) compute all Frankl witnesses (elements with freq ≥ |F|/2), (3) check if some witness belongs to a join-irreducible set. A counterexample would be a family where all Frankl witnesses avoid all join-irreducible sets.

**Impact:** This would reduce the Frankl witness search from the full ground set to the typically much smaller set of elements in join-irreducible sets. For lattices with few join-irreducibles (e.g., modular lattices), this immediately implies Frankl.

**Catalog References:** `Algebra/Frankl/Lattice.lean` (join-irreducible definition, upper cones)

**Proof Strategy:** Prove that the singleton injection argument generalizes: if $J$ is join-irreducible in $\mathcal{F}$, then the map $S \mapsto S \cup J$ is injective on $\{S \in \mathcal{F} : J \not\subseteq S\}$ into $\{S \in \mathcal{F} : J \subseteq S\}$. Then frequency of any element in $J$ is at least freq(J)/|J|, and relate this to |F|/2.

**Domain Bridges:** Order theory (Birkhoff representation), lattice theory (modular/distributive lattices), universal algebra.

**Lineage:** Extends `frankl_of_singleton_in_sets` from singleton sets to join-irreducible sets.

**Ambition:** Grand challenge — would transform Frankl from a combinatorial conjecture into a lattice-theoretic theorem.

---

## Direction 4: Verified Counterexample Search for Strengthened Conjectures

**Conjecture (Entropy-Gap Monotonicity):** For every union-closed family $\mathcal{F}$ with nonempty ground:
$$2 \cdot \max_a \text{freq}(a) - |\mathcal{F}| \geq \frac{2 \cdot \text{totalIncidence} - |\text{ground}| \cdot |\mathcal{F}|}{|\text{ground}|}$$

That is, the "Frankl excess" is bounded below by the "energy excess per ground element."

**Test:** Compute both sides for all union-closed families on $\{1,\ldots,n\}$ for $n \leq 5$. A counterexample would be a family where the left side is smaller than the right side.

**Impact:** If true, this would give a quantitative strengthening of Frankl's conjecture: not only does a witness exist, but its excess frequency is controlled by the energy. If false, the counterexample structure would reveal which families are "tight" for Frankl.

**Catalog References:** `Algebra/Frankl/DoubleCount.lean` (double counting), `Algebra/Frankl/AverageCriterion.lean`

**Proof Strategy:** If the conjecture is true, prove it by combining the double-counting identity with a refined pigeonhole argument. If false, formalize the counterexample as a concrete `UnionClosedFamily` instance and verify that the inequality fails.

**Domain Bridges:** Extremal combinatorics (tight examples), optimization (linear programming duals over UC families).

**Lineage:** Strengthens `frankl_of_average_card_large` from existence to quantitative bounds.

**Ambition:** Solid extension — yields either a new theorem or a useful counterexample structure.

---

## Direction 5: Certificate Compression for Algorithmic Frankl

**Conjecture (Logarithmic Certificate):** For every separating union-closed family $\mathcal{F}$ of size $m$, there exists a subfamily $\mathcal{G} \subseteq \mathcal{F}$ with $|\mathcal{G}| = O(\log m)$ such that the Frankl witness of $\mathcal{F}$ can be verified using only $\mathcal{G}$.

**Test:** For each separating UC family on $\{1,\ldots,n\}$ for $n \leq 5$: (1) find a Frankl witness $a$, (2) find the minimum subfamily $\mathcal{G}$ needed to certify that freq$_{\mathcal{G}}(a) \geq |\mathcal{G}|/2$, (3) check if $|\mathcal{G}| = O(\log |\mathcal{F}|)$. A counterexample would be a family requiring $\Omega(m)$ certificate size.

**Impact:** This would give efficient proof certificates for Frankl witnesses, relevant to verified computation and proof complexity. It would also connect Frankl's conjecture to communication complexity and proof length.

**Catalog References:** `Algebra/Frankl/Defs.lean` (findFranklWitness?, heavyElements)

**Proof Strategy:** Use the injection argument (Theorem 5.1) to construct small certificates: the certificate contains the witness element, the singleton set {a}, and the images of the injection pairing. Bound the certificate size by the depth of the lattice (which is O(log m) for separating families by a theorem of Poonen).

**Domain Bridges:** Computational complexity (certificate complexity), proof complexity (proof length), algorithms (verification).

**Lineage:** Extends `findFranklWitness?_correct` to efficient certified search.

**Ambition:** Solid extension — bridges formal verification with algorithmic complexity.
