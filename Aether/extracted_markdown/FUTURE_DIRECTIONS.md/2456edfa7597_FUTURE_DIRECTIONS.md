# Future Directions: Galois Theory of Cellular Automata

## Synthesis

This cycle established a rigorous algebraic framework for reversible cellular automata on finite periodic lattices. The central discovery is the **centralizer identification** — the reversibility group Rev(n, A) equals the centralizer of the shift permutation in the symmetric group — proved by showing that commuting with a single shift generator implies commuting with all shifts (the induction step from ℕ to ℤ/nℤ). This identification unlocks the entire centralizer theory of symmetric groups for studying reversible CAs.

The **CA Galois Correspondence** is the most novel contribution: a formal Galois connection between subgroups of the reversibility group and families of shift-invariant subsets of configuration space, with proved antitonicity and a stabilizer construction with finiteness-based inverse closure. This directly parallels the classical Galois correspondence (subgroups ↔ intermediate fields) but in a dynamical context, connecting algebraic structure to orbital geometry.

The most promising cross-domain connection is between the **centralizer formula** (from symmetric group theory) and **necklace combinatorics** (from enumerative combinatorics / number theory). The orbit structure of the shift is determined by binary necklace counts, which involve Euler's totient function and Möbius inversion. This connects our Galois-theoretic framework to `Algebra/ArtinPrimitiveRoot.lean` and number-theoretic infrastructure in the Catalog. The **wreath product decomposition** of the centralizer (Direction 1) has the highest breakthrough potential because it would give a complete structural characterization of the reversibility group, not just its order.

---

### Direction 1: Wreath Product Structure of the Reversibility Group

**Conjecture**: For any finite alphabet A and period n, the reversibility group Rev(n, A) is isomorphic to a direct product of wreath products:

Rev(n, A) ≅ Π_{d | n} (ℤ/dℤ ≀ S_{m_d})

where m_d is the number of shift orbits of size d (the number of binary necklaces of minimal period d).

**Test**: Formalize the wreath product decomposition for n = 3, A = {0, 1} in Lean 4. The prediction is Rev(3, {0,1}) ≅ S₂ × (ℤ/3ℤ ≀ S₂), which has order 2 × 18 = 36. Construct an explicit isomorphism and verify it computationally.

**Impact**: A complete structural theorem for Rev(n, A) would reduce all questions about reversible CAs to questions about wreath products — a well-studied class of groups. This would immediately give character tables, normal subgroup lattices, and representation-theoretic data for the reversibility group.

**Catalog References**: `Geometry/CellularAutomataGalois.lean` (reversibility_eq_centralizer, orbit_image_eq_orbit)

**Proof Strategy**: 
1. Formalize wreath products ℤ/dℤ ≀ S_m as Lean structures.
2. Construct the restriction of the centralizer to orbits of a fixed size d.
3. Show each orbit-restricted piece is isomorphic to ℤ/dℤ ≀ S_{m_d}.
4. Show the full centralizer is the direct product of these pieces (orbits of different sizes are independent).

**Domain Bridges**: Algebra (group theory, wreath products) ↔ Combinatorics (necklace counting) ↔ Dynamics (CA reversibility)

**Lineage**: Builds on reversibility_eq_centralizer and orbit_image_eq_orbit from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Higher-Dimensional Reversibility Groups

**Conjecture**: For CAs on the d-dimensional torus (ℤ/n₁ℤ × ... × ℤ/n_dℤ), the reversibility group equals the centralizer of the d commuting shift generators in the symmetric group. The group structure is determined by the joint orbit decomposition under all d shifts, and the centralizer formula generalizes to:

|Rev| = Π_O (|O|^{mult(O)} · mult(O)!)

where the product is over distinct orbit types O under the joint ℤ^d action.

**Test**: Compute Rev for the 2D torus ℤ/2ℤ × ℤ/3ℤ with binary alphabet. The joint shift group is ℤ/2ℤ × ℤ/3ℤ ≅ ℤ/6ℤ acting on 2^6 = 64 configurations. Compare the centralizer order with the predicted value from the orbit decomposition.

**Impact**: Would extend the entire framework to multi-dimensional CAs, where reversibility is known to be undecidable in general (Kari, 1994). For fixed finite tori, the algebraic structure remains tractable and could provide new decidability results for specific lattice shapes.

**Catalog References**: `Geometry/CellularAutomataGalois.lean`, `Algebra/ArtinPrimitiveRoot.lean`

**Proof Strategy**:
1. Generalize shiftConfig to multi-dimensional shifts.
2. Define the multi-shift centralizer as the joint centralizer of d commuting permutations.
3. Reduce to the single-generator case via the structure theorem for finite abelian groups.
4. Apply the wreath product formula from Direction 1.

**Domain Bridges**: Dynamics (higher-dimensional CAs) ↔ Algebra (abelian group actions) ↔ Computation (decidability boundaries)

**Lineage**: Direct generalization of this cycle's 1D results.

**Ambition**: grand_challenge

---

### Direction 3: Galois Correspondence Completeness

**Conjecture**: The CA Galois correspondence is complete in the following sense: for any subgroup H ≤ Rev(n, A), the stabilizer of the invariant sets of H recovers H exactly:

Stab(Inv(H)) = H

This would make the correspondence a *perfect* Galois connection (a closure operator pair), analogous to the fundamental theorem of Galois theory.

**Test**: Verify computationally for n = 3, A = {0,1} by enumerating all 36 elements of Rev(3, {0,1}), computing Inv(H) for each subgroup H, and checking that Stab(Inv(H)) = H. The prediction is that this holds for all subgroups of Rev(3, {0,1}).

**Impact**: If true, this would establish a *bijection* between subgroups of Rev and "closed" families of invariant sets — a genuine Galois correspondence, not merely a Galois connection. If false, identifying the closure defect would reveal new structural constraints on CA dynamics.

**Catalog References**: `Geometry/CellularAutomataGalois.lean` (invariantSets_antitone, stabilizerSubgroup)

**Proof Strategy**:
1. Show H ≤ Stab(Inv(H)) (easy direction, follows from definitions).
2. Show Stab(Inv(H)) ≤ H (hard direction, requires showing that non-H elements fail to preserve some H-invariant set).
3. The hard direction likely requires exhibiting explicit "separating sets" for each element not in H.

**Domain Bridges**: Algebra (Galois theory) ↔ Lattice theory (closure operators) ↔ Dynamics (invariant structure)

**Lineage**: Builds on invariantSets_antitone and stabilizerSubgroup from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Reversibility and Min-Plus CAs

**Conjecture**: Define a **tropical cellular automaton** where the local rule uses min and + operations (in the tropical semiring ℝ_min = (ℝ ∪ {∞}, min, +)) instead of Boolean operations. The reversibility group of tropical CAs on periodic lattices is the centralizer of the shift in the group of tropical-linear bijections, and has order determined by a tropical analogue of the necklace counting formula.

**Test**: Formalize tropical CAs on ℤ/3ℤ with alphabet ℤ_min (truncated tropical integers). Compute the group of tropical-linear shift-equivariant bijections and compare with the classical (Boolean) reversibility group. The conjecture predicts these groups are non-isomorphic but have related structure.

**Impact**: Would bridge cellular automata theory with tropical geometry and the tropical cryptography work in the Catalog. Could yield new reversible computation models based on min-plus arithmetic, relevant to optimization and scheduling.

**Catalog References**: `Tropical/HashInversion.lean` (reversible_iff_bijective), `Cryptography/TropicalCryptography.lean`

**Proof Strategy**:
1. Define tropical CAs as shift-equivariant maps on (ℤ_min)^(ℤ/nℤ).
2. Characterize tropical-linear maps (those preserving the tropical semiring structure).
3. Compute the centralizer of shift among tropical-linear bijections.
4. Compare with the Boolean centralizer via a functor between the two settings.

**Domain Bridges**: Tropical geometry ↔ Cellular automata ↔ Cryptography (min-plus Diffie-Hellman)

**Lineage**: Cross-domain bridge connecting this cycle's framework with the Tropical catalog entries.

**Ambition**: extension

---

### Direction 5: Reversibility Density and Asymptotic Group Theory

**Conjecture**: The logarithmic reversibility density:

ρ(n) = log₂|Rev(n, {0,1})| / log₂(2^n!)

satisfies ρ(n) = Θ(n · 2^n / (2^n · log 2^n)) = Θ(n / log(2^n)) = Θ(1/log 2) as n → ∞, measured in the appropriate normalization. More precisely, log|Rev(n, {0,1})| ~ c · 2^n for some constant c related to the necklace generating function.

**Test**: Compute log|Rev(n, {0,1})| for n = 1, ..., 12 and fit the asymptotic growth rate. The centralizer formula gives log|Rev| = Σ_d m_d · log(d) + Σ_d log(m_d!), where m_d counts orbits of size d. Since m_d ~ 2^d/(dn) by the necklace formula, this sum should grow like 2^n/n.

**Impact**: Would establish the precise asymptotic growth rate of the reversibility group, settling whether Rev grows polynomially, exponentially, or super-exponentially in the configuration space size. This connects to asymptotic group theory and the study of large permutation groups.

**Catalog References**: `Geometry/CellularAutomataGalois.lean` (centralizer_order formula)

**Proof Strategy**:
1. Use the Möbius inversion formula for necklace counts to get asymptotics for m_d.
2. Apply Stirling's approximation to the factorial terms m_d!.
3. Sum over divisors d | n to get the leading term of log|Rev|.
4. Formalize the bound in Lean using Mathlib's asymptotic analysis library.

**Domain Bridges**: Number theory (Möbius inversion, totient function) ↔ Asymptotic analysis ↔ Group theory

**Lineage**: Quantitative extension of the centralizer formula from this cycle.

**Ambition**: extension
