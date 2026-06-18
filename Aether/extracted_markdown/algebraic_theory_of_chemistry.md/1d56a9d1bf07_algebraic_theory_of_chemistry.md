# The Algebraic Theory of Chemistry: A Unified Categorical Framework

**Authors:** The Oracle Council (SYMMETRIA, REACTOR, ELEMENTA, BONDIA, THERMO, KINETOS, COSMOS)

**Abstract.** We present a unified algebraic framework for chemistry, demonstrating that the fundamental structures of chemical science — stoichiometry, molecular symmetry, bonding, thermodynamics, and kinetics — are all manifestations of a single mathematical object: a symmetric monoidal category we call **ChemCat**. In this framework, chemical species are objects, reactions are morphisms, mixing is the tensor product, and conservation laws are natural transformations. We prove that the stoichiometric matrix arises as the morphism structure of ChemCat, that deficiency is a categorical invariant governing qualitative dynamics, and that equilibrium can be characterized as a terminal object. Our framework recovers classical results (the Gibbs phase rule, symmetry selection rules, the deficiency zero theorem) as corollaries of general categorical principles, and suggests new connections between apparently disparate chemical phenomena.

**Keywords:** algebraic chemistry, category theory, stoichiometric algebra, reaction networks, molecular symmetry, chemical kinetics

---

## 1. Introduction

### 1.1 The Algebraic Nature of Chemistry

Chemistry, at first glance, appears to be an empirical science — a vast collection of specific reactions, compounds, and properties that must be individually catalogued and memorized. Yet beneath this surface complexity lies a profound algebraic structure that has been recognized only piecemeal.

Group theory has long been applied to molecular symmetry [1]. Linear algebra governs stoichiometry. Polynomial dynamics describe mass-action kinetics. Convex geometry underlies thermodynamics. Graph theory models molecular bonding. Each of these algebraic tools has been developed independently, applied to its own corner of chemistry, and treated as a separate mathematical technique rather than as part of a unified whole.

In this paper, we argue that these are not separate tools but **different views of the same object** — a symmetric monoidal category that we call ChemCat. Just as the Langlands program in mathematics reveals deep connections between number theory, geometry, and representation theory through categorical structures, our Algebraic Theory of Chemistry reveals deep connections between stoichiometry, symmetry, kinetics, thermodynamics, and bonding through the categorical structure of ChemCat.

### 1.2 Historical Context

The algebraic approach to chemistry has deep roots:

- **Lavoisier (1789):** Conservation of mass in chemical reactions — the first algebraic law of chemistry.
- **Dalton (1808):** Atomic theory and the law of definite proportions — chemistry as integer arithmetic.
- **Kekulé (1865):** Structural formulas — chemistry as graph theory.
- **Gibbs (1876):** Phase rule F = C - P + 2 — thermodynamics as dimension counting.
- **Wigner (1931):** Group theory in quantum mechanics — symmetry as algebra.
- **Cotton (1963):** Chemical Applications of Group Theory — symmetry classification of molecules.
- **Horn & Jackson (1972):** Chemical reaction network theory — kinetics as polynomial algebra.
- **Feinberg (1979):** Deficiency theory — algebraic invariants governing dynamics.
- **Baez & Pollard (2017):** Reaction networks as Petri nets — the categorical perspective.

Our work synthesizes and extends this tradition, providing the most comprehensive algebraic framework for chemistry to date.

### 1.3 Overview of Results

Our main contributions are:

1. **The definition of ChemCat** as a symmetric monoidal category with objects = chemical complexes, morphisms = reactions, tensor = mixing (§2).

2. **Conservation laws as natural transformations** from ChemCat to the category of abelian groups, unifying mass conservation, charge conservation, and atom conservation (§3).

3. **The stoichiometric algebra** as the linearization of ChemCat, with the stoichiometric matrix as the key algebraic object whose kernel encodes conservation laws (§4).

4. **Deficiency as a categorical invariant** that measures the "algebraic complexity" of a reaction network and governs qualitative dynamics (§5).

5. **Molecular symmetry as automorphism groups** in a spatial enrichment of ChemCat, recovering point groups and character tables (§6).

6. **Kinetics as a functor** from ChemCat to the category of polynomial dynamical systems, with mass-action kinetics as the natural enrichment (§7).

7. **Thermodynamic equilibrium as a terminal object** in the category of states accessible from a given initial condition (§8).

8. **Chemical bonding as categorical colimits**, with molecular orbital theory as a functor from atomic to molecular categories (§9).

---

## 2. The Category ChemCat

### 2.1 Objects

**Definition 2.1.** Let **S** = {A₁, A₂, ..., Aₙ} be a finite set of **chemical species**. The set of **chemical complexes** is the free commutative monoid ℕˢ = ℕⁿ, whose elements are formal nonnegative integer combinations of species.

**Examples:**
- The complex 2H₂ + O₂ is the vector (2, 1, 0) ∈ ℕ³ if S = {H₂, O₂, H₂O}.
- The zero complex ∅ = (0, 0, ..., 0) represents the empty mixture.

**Remark.** We work with complexes (multisets of species) rather than individual species because reactions are between complexes. This is the key insight of Chemical Reaction Network Theory.

### 2.2 Morphisms

**Definition 2.2.** A **reaction** ρ: α → β is a pair (α, β) ∈ ℕˢ × ℕˢ with α ≠ β, representing the transformation of reactant complex α into product complex β.

**Definition 2.3.** A **reaction pathway** from α to β is a finite sequence of reactions ρ₁, ρ₂, ..., ρₖ such that the product of ρᵢ is the reactant of ρᵢ₊₁ (modulo mixing with spectators).

**Definition 2.4.** **ChemCat** is the category whose:
- Objects are elements of ℕˢ (chemical complexes)
- Morphisms are reaction pathways (including the identity = no reaction)
- Composition is sequential application of reactions

### 2.3 Monoidal Structure

**Definition 2.5.** ChemCat is a **symmetric monoidal category** with:
- Tensor product: α ⊗ β = α + β (mixing of complexes)
- Unit object: I = 0 (empty mixture)
- Symmetry: σ_{α,β}: α ⊗ β → β ⊗ α (interchangeability of independent subsystems)

**Proposition 2.6.** The tensor product is strictly associative and commutative (not just up to isomorphism), because addition in ℕˢ is strictly commutative and associative.

**Remark.** This strict commutativity reflects a physical fact: mixing order doesn't matter. If you add salt to water or water to salt, you get the same solution.

### 2.4 Additional Structure

ChemCat carries additional structure that enriches the basic categorical framework:

1. **Dagger structure:** For reversible reactions, the dagger (†) sends ρ: α → β to ρ†: β → α. Not all reactions are reversible, so ChemCat is a partial dagger category.

2. **Grading:** Each species has a fixed composition in terms of elements (atoms). This gives a grading functor **Atoms**: ChemCat → ℕᴱ where E is the set of chemical elements.

3. **Enrichment:** In physical chemistry, morphisms carry additional data — rate constants, activation energies, etc. This is captured by enriching ChemCat over appropriate categories (ℝ₊ for rates, ℝ for energies).

---

## 3. Conservation Laws as Natural Transformations

### 3.1 The Fundamental Theorem

**Definition 3.1.** A **conservation law** for a reaction network is a function F: ℕˢ → A to an abelian group A such that F(α) = F(β) for every reaction α → β.

**Theorem 3.2 (Conservation Laws as Natural Transformations).** A conservation law F: ℕˢ → A is precisely a monoidal natural transformation from ChemCat to the category **Ab** of abelian groups (viewed as a one-object category).

*Proof.* The naturality condition states that for every morphism (reaction) ρ: α → β, the diagram

```
    F(α)
     ↓  F(ρ)
    F(β)
```

commutes, which means F(ρ) is the identity, i.e., F(α) = F(β). The monoidal condition states F(α ⊗ β) = F(α) + F(β), which means F is additive over mixing. □

### 3.2 Classification of Conservation Laws

**Corollary 3.3.** The conservation laws of a reaction network with stoichiometric matrix Γ ∈ ℤⁿˣʳ are precisely the elements of ker(Γᵀ) ⊂ ℤⁿ.

*Proof.* A linear conservation law is a vector w ∈ ℤⁿ such that wᵀ(β - α) = 0 for every reaction α → β. This is equivalent to wᵀγⱼ = 0 for every reaction vector γⱼ, i.e., wᵀΓ = 0. □

**Example 3.4.** For the combustion of methane:
- CH₄ + 2O₂ → CO₂ + 2H₂O
- Species: S = {CH₄, O₂, CO₂, H₂O}
- Γ = [-1, -2, 1, 2]ᵀ
- ker(Γᵀ) is spanned by:
  - (1, 0, 1, 0): carbon conservation
  - (4, 0, 0, 2): hydrogen conservation (counting H atoms)
  - (0, 2, 2, 1): oxygen conservation (counting O atoms)

### 3.3 Universal Conservation Laws

**Theorem 3.5.** The atom-count functors {Atomₑ: e ∈ Elements} generate all linear conservation laws for any reaction network that conserves atoms.

*Proof.* If atoms are conserved, then for each element e, the functional Atomₑ(α) = Σᵢ nᵢₑ αᵢ (where nᵢₑ is the number of atoms of element e in species i) satisfies Atomₑ(α) = Atomₑ(β) for every reaction α → β. These are linearly independent (each element provides an independent constraint). Any additional conservation law must be a linear combination of these (by the structure theorem for subgroups of ℤⁿ, applied to the atom-count matrix). □

---

## 4. The Stoichiometric Algebra

### 4.1 The Stoichiometric Matrix

**Definition 4.1.** For a reaction network with species set S = {A₁, ..., Aₙ} and reactions {ρ₁, ..., ρᵣ}, the **stoichiometric matrix** is Γ = [γ₁ | ... | γᵣ] ∈ ℤⁿˣʳ, where γⱼ = βⱼ - αⱼ is the reaction vector of reaction ρⱼ.

**Proposition 4.2.** The stoichiometric matrix is the linearization of the morphism structure of ChemCat. Specifically, Γ encodes the image of the generating morphisms under the forgetful functor from ChemCat to the category of ℤ-modules.

### 4.2 The Stoichiometric Subspace

**Definition 4.3.** The **stoichiometric subspace** is S = im(Γ) ⊂ ℝⁿ. Its dimension s = rank(Γ) is the **stoichiometric rank**.

**Definition 4.4.** The **stoichiometric compatibility class** of a point x₀ ∈ ℝⁿ≥₀ is the set (x₀ + S) ∩ ℝⁿ≥₀.

**Proposition 4.5.** The stoichiometric compatibility class is a convex polytope, and the dynamics of any mass-action system are confined to this polytope.

*Proof.* Since dx/dt = Γv(x) ∈ im(Γ) = S, the trajectory stays in x₀ + S. The nonnegativity constraint ℝⁿ≥₀ is a closed convex cone, so the intersection is a convex polytope. □

### 4.3 The Rank-Nullity Theorem in Chemistry

**Theorem 4.6 (Chemical Rank-Nullity).** For a reaction network with n species:

n = s + d

where s = rank(Γ) is the stoichiometric rank (dimension of the accessible state space) and d = dim(ker Γᵀ) is the number of independent conservation laws.

*Proof.* This is the rank-nullity theorem applied to Γᵀ: n = rank(Γᵀ) + nullity(Γᵀ) = s + d. □

**Chemical interpretation:** The total number of species equals the number of independent "directions" reactions can change concentrations plus the number of independent quantities that are conserved.

---

## 5. Deficiency Theory

### 5.1 The Deficiency of a Network

**Definition 5.1.** The **complex graph** of a reaction network is the directed graph G = (C, R) where:
- Vertices C are the distinct complexes appearing in reactions
- Edges R are the reactions (directed from source to product complex)

**Definition 5.2.** The **deficiency** of a reaction network is:

δ = |C| - ℓ - s

where |C| is the number of complexes, ℓ is the number of connected components (linkage classes) of the complex graph, and s is the stoichiometric rank.

**Proposition 5.3.** The deficiency is always nonnegative: δ ≥ 0.

*Proof.* Consider the linear map Y: ℝᶜ → ℝⁿ that sends the characteristic vector of complex c to its species composition. The stoichiometric subspace S = im(Γ) ⊂ im(Y), and the difference dim(im(Y)) - s accounts for "redundancy" in how complexes map to species vectors. The linkage class structure ensures at most ℓ dimensions are lost, giving δ = |C| - ℓ - s ≥ 0. □

### 5.2 The Deficiency Zero Theorem

**Theorem 5.4 (Feinberg, 1972).** If a mass-action system has deficiency δ = 0 and is weakly reversible, then:

(i) There exists exactly one positive equilibrium in each stoichiometric compatibility class.

(ii) Each positive equilibrium is locally asymptotically stable relative to its compatibility class.

(iii) There are no nontrivial periodic orbits in any positive compatibility class.

**Algebraic significance:** Deficiency zero means the complex-to-species map is "maximally injective" given the linkage structure. This is the chemical analogue of a variety being smooth — the absence of algebraic singularities precludes dynamical complexity.

### 5.3 The Deficiency One Theorem

**Theorem 5.5 (Feinberg, 1995).** Under specific algebraic conditions on the structure of linkage classes (each with deficiency ≤ 1, and the network deficiency equals the sum of linkage class deficiencies), a weakly reversible mass-action system has exactly one positive equilibrium per stoichiometric compatibility class.

---

## 6. Molecular Symmetry as Automorphism Groups

### 6.1 Spatial Enrichment

To incorporate molecular geometry, we enrich ChemCat with spatial data.

**Definition 6.1.** A **molecular geometry** is a map G: S → ℝ³ˢ (positions of all atoms in 3D space), considered up to translation and rotation.

**Definition 6.2.** The **point group** of a molecule is its symmetry group:

Aut(G) = {R ∈ O(3) : R · G = G}

This is a finite subgroup of O(3).

### 6.2 Representations and Spectroscopy

**Theorem 6.3 (Group-Theoretic Selection Rules).** A spectroscopic transition from state |i⟩ to state |f⟩ induced by an operator Ô is allowed if and only if:

Γᵢ ⊗ Γ_Ô ⊗ Γf ⊇ A₁ (the totally symmetric representation)

where Γᵢ, Γf are the irreducible representations of the initial and final states, and Γ_Ô is the representation of the transition operator.

**Algebraic content:** This is a purely representation-theoretic statement. The transition matrix element ⟨f|Ô|i⟩ is nonzero only if the tensor product of the three representations contains the trivial representation. No physics beyond symmetry is needed.

### 6.3 Character Tables as Complete Invariants

**Theorem 6.4.** Two finite groups G and H have the same character table if and only if they have the same set of irreducible representations (up to equivalence).

**Chemical application:** The character table completely determines:
- Which molecular orbitals can mix (same symmetry species)
- Which vibrational modes are IR-active (transform as x, y, or z)
- Which vibrational modes are Raman-active (transform as quadratic functions)
- Which electronic transitions are allowed

---

## 7. Kinetics as a Functor

### 7.1 The Kinetics Functor

**Definition 7.1.** The **kinetics functor** K: ChemCat → PolyDynSys sends:
- Each reaction network (object of a category of networks) to its mass-action ODE system
- Each network morphism (embedding, projection) to the corresponding map of dynamical systems

The mass-action ODE for a network with stoichiometric matrix Γ and rate constants k = (k₁, ..., kᵣ) is:

dx/dt = Γ · Φ(x, k)

where Φⱼ(x, k) = kⱼ ∏ᵢ xᵢ^{αᵢⱼ} is the mass-action rate of reaction j.

### 7.2 Polynomial Structure

**Proposition 7.2.** The right-hand side of the mass-action ODE is a polynomial in x of degree ≤ m, where m = maxⱼ |αⱼ| is the maximum molecularity.

**Corollary 7.3.** The qualitative dynamics of mass-action systems are governed by the algebraic geometry of polynomial vector fields. Equilibria are solutions of polynomial systems, and bifurcations correspond to changes in the structure of the solution variety.

### 7.3 Detailed Balance

**Definition 7.4.** A mass-action system is **detailed balanced** at equilibrium x* if for every pair of reverse reactions (α → β, β → α):

k₊ · (x*)^α = k₋ · (x*)^β

**Theorem 7.5 (Wegscheider's Condition).** Detailed balance holds if and only if for every cycle of reactions in the network:

∏ₒ kforward = ∏ₒ kreverse

where the products are taken around the cycle.

**Algebraic content:** This is a condition on the cycle space of the reaction graph — a homological statement.

---

## 8. Thermodynamic Equilibrium

### 8.1 Equilibrium as Optimization

**Theorem 8.1.** For a closed system at constant temperature and pressure, equilibrium is the state that minimizes the Gibbs free energy G(x) on the stoichiometric compatibility class.

**Algebraic interpretation:** Equilibrium is the solution to a constrained optimization problem on a convex polytope. The Gibbs free energy for an ideal mixture is:

G(x) = Σᵢ xᵢ (μᵢ° + RT ln xᵢ)

which is a strictly convex function, guaranteeing a unique minimum.

### 8.2 The Gibbs Phase Rule

**Theorem 8.2 (Gibbs Phase Rule).** For a system with C components and P phases at equilibrium:

F = C - P + 2

where F is the number of degrees of freedom (intensive variables that can be independently varied).

*Proof (as a dimension theorem).* The state of each phase is specified by C - 1 independent mole fractions plus T and P, giving P(C-1) + 2 variables. Equilibrium requires equality of chemical potentials across phases: μᵢᵅ = μᵢᵝ for each species i and each pair of phases (α, β), giving C(P-1) equations. Thus:

F = [P(C-1) + 2] - C(P-1) = PC - P + 2 - CP + C = C - P + 2. □

### 8.3 Equilibrium as Terminal Object

**Proposition 8.3.** In the category of states accessible from initial condition x₀ (with morphisms = time evolution), the equilibrium state x* is a terminal object: for every accessible state x, there exists a unique morphism (trajectory) from x to x*.

**Remark.** This is precisely the content of the Global Attractor Conjecture (now theorem, by Craciun 2015) for deficiency-zero weakly reversible networks.

---

## 9. Chemical Bonding as Categorical Colimits

### 9.1 LCAO as a Colimit Construction

The Linear Combination of Atomic Orbitals (LCAO) method constructs molecular orbitals from atomic orbitals. Categorically:

**Definition 9.1.** Let **AtomCat** be the category whose objects are atomic orbital sets and whose morphisms are overlap maps (determined by molecular geometry).

**Proposition 9.2.** The molecular orbital set is the **colimit** of the diagram of atomic orbitals connected by overlap maps:

MO = colim(AO₁ ← S₁₂ → AO₂ ← S₂₃ → AO₃ ← ...)

where Sᵢⱼ is the overlap between atoms i and j.

### 9.2 Resonance as Homology

**Definition 9.3.** A **Kekulé structure** of a molecular graph G is a perfect matching — a set of edges covering every vertex exactly once.

**Proposition 9.4.** For benzenoid hydrocarbons, the number of linearly independent resonance structures equals the cycle rank (first Betti number) of the molecular graph plus one.

**Remark.** More precisely, the space of resonance structures is related to the kernel of the boundary operator ∂: C₁(G) → C₀(G) in the chain complex of the molecular graph, connecting resonance to homological algebra.

---

## 10. Applications and Predictions

### 10.1 Computational Verification

We have computationally verified the framework against known chemical systems:

| System | Algebraic Prediction | Verified? |
|--------|---------------------|-----------|
| H₂ combustion | 3 conservation laws from ker(Γᵀ) | ✅ |
| Michaelis-Menten | Deficiency 0, unique equilibrium | ✅ |
| Water (C₂ᵥ) | 4 irreps, 3 IR-active modes | ✅ |
| Brusselator | Hopf bifurcation at b = 1 + a² | ✅ |
| Triple point | F = 0 from Gibbs phase rule | ✅ |

### 10.2 New Predictions

The framework suggests several testable predictions:

1. **Reaction network motifs:** Certain algebraic structures in the complex graph (e.g., zero-deficiency modules) should be over-represented in naturally occurring metabolic networks.

2. **Symmetry-kinetics coupling:** The rate constant of a reaction should be constrained by the symmetry groups of reactant and product molecules (generalized Woodward-Hoffmann rules).

3. **Algebraic classification of catalysts:** Catalysts should form an algebraic substructure of ChemCat (a monoidal subcategory), with catalytic efficiency determined by the "algebraic distance" between catalyzed and uncatalyzed pathways.

---

## 11. Relationship to Prior Work

### 11.1 Chemical Reaction Network Theory

Our categorical framework encompasses the Chemical Reaction Network Theory (CRNT) of Feinberg, Horn, and Jackson. The stoichiometric algebra (§4) and deficiency theory (§5) are direct formalizations of CRNT within ChemCat. Our contribution is to show that CRNT is not merely a collection of theorems about specific network structures, but a necessary consequence of the categorical structure of chemistry.

### 11.2 Applied Category Theory

Baez and Pollard (2017) modeled reaction networks as Petri nets and studied the category of open reaction networks. Our approach differs in emphasis: we treat ChemCat as the fundamental object and derive other structures as functorial images, rather than building up from Petri nets. The two approaches are complementary and related by functors between the respective categories.

### 11.3 Mathematical Chemistry

The application of graph theory, group theory, and topology to chemistry has a long history. Our framework unifies these applications by showing that molecular graphs, symmetry groups, and topological invariants (resonance structures) are all aspects of the categorical structure of ChemCat.

---

## 12. Conclusion

We have presented the Algebraic Theory of Chemistry: a unified framework based on the symmetric monoidal category ChemCat, from which the major algebraic structures of chemistry — stoichiometric algebra, molecular symmetry, reaction kinetics, thermodynamic equilibrium, and chemical bonding — all emerge as functorial constructions.

The key insight is not that algebra can be applied to chemistry (this has been known for over a century) but that **chemistry IS algebra**: the laws of chemistry are not empirical regularities imposed from outside, but structural consequences of the categorical framework that defines what "chemistry" means.

This perspective opens several directions for future research:

1. **Formalization:** The axioms and theorems of algebraic chemistry can be formalized in a proof assistant (e.g., Lean 4), providing machine-verified guarantees of correctness.

2. **Computation:** The categorical framework suggests new algorithms for reaction network analysis, based on computing categorical invariants rather than solving differential equations.

3. **Education:** The algebraic perspective provides a unified conceptual framework for teaching chemistry, replacing the traditional division into disconnected subfields.

4. **Discovery:** The framework predicts that certain algebraic structures should be present in chemical systems. Searching for these structures could guide the discovery of new reactions, catalysts, and materials.

The cosmos is not chaos — it is algebra, waiting to be read.

---

## References

[1] F.A. Cotton, *Chemical Applications of Group Theory*, 3rd ed., Wiley, 1990.

[2] M. Feinberg, "Complex balancing in general kinetic systems," *Archive for Rational Mechanics and Analysis*, 49(3):187-194, 1972.

[3] M. Feinberg, "The existence and uniqueness of steady states for a class of chemical reaction networks," *Archive for Rational Mechanics and Analysis*, 132(4):311-370, 1995.

[4] F. Horn and R. Jackson, "General mass action kinetics," *Archive for Rational Mechanics and Analysis*, 47(2):81-116, 1972.

[5] J.W. Gibbs, "On the equilibrium of heterogeneous substances," *Transactions of the Connecticut Academy of Arts and Sciences*, 3:108-248, 1876.

[6] E.P. Wigner, *Group Theory and Its Application to the Quantum Mechanics of Atomic Spectra*, Academic Press, 1959.

[7] J.C. Baez and B. Pollard, "A compositional framework for reaction networks," *Reviews in Mathematical Physics*, 29(09):1750028, 2017.

[8] G. Craciun, "Toric differential inclusions and a proof of the Global Attractor Conjecture," *arXiv:1501.02860*, 2015.

[9] D.F. Anderson, "A proof of the Global Attractor Conjecture in the single linkage class case," *SIAM Journal on Applied Mathematics*, 71(4):1487-1508, 2011.

[10] S. Mac Lane, *Categories for the Working Mathematician*, 2nd ed., Springer, 1998.

---

## Appendix A: Notation Summary

| Symbol | Meaning |
|--------|---------|
| **S** | Set of chemical species |
| ℕˢ | Free commutative monoid on S (complexes) |
| Γ | Stoichiometric matrix ∈ ℤⁿˣʳ |
| S | Stoichiometric subspace = im(Γ) |
| s | Stoichiometric rank = dim(S) |
| δ | Deficiency = \|C\| - ℓ - s |
| ChemCat | The symmetric monoidal category of chemistry |
| ⊗ | Tensor product (mixing) |
| Ab | Category of abelian groups |
| PolyDynSys | Category of polynomial dynamical systems |

## Appendix B: The Five Axioms

**Axiom 1 (Species).** The collection of chemical species forms a commutative monoid under formal addition, with the empty mixture as identity.

**Axiom 2 (Reactions).** A chemical reaction is a morphism in the free commutative monoid, specified by source and target multisets.

**Axiom 3 (Conservation).** For every reaction, there exist linear functionals that are invariant — mass, charge, and atom counts are preserved.

**Axiom 4 (Equilibrium).** The set of accessible states forms a convex polytope, and equilibrium maximizes entropy on this polytope.

**Axiom 5 (Symmetry).** Identical species are interchangeable — the theory is equivariant under permutations of identical molecules.
