# Future Directions: Tropical Cellular Automata

## Roadmap for Breakthrough Research Opportunities

This document outlines five concrete next directions opened by our formalization of the tropical Game of Life. Each direction includes specific hypotheses, proof strategies, and cross-domain connections.

---

### 1. Tropical Garden-of-Eden Theorem

**Hypothesis**: Every non-surjective tropical Life step on a finite torus has configurations with no pre-image (Garden-of-Eden configurations), and the Moore–Myhill theorem holds in the tropical setting.

**Proof Strategy**:
- Formalize the step operator as a function `Config m n → Config m n` on a finite type.
- Use `Fintype.card` and pigeonhole to show non-injectivity implies non-surjectivity (since the domain is finite, these are equivalent).
- Explicitly construct a Garden-of-Eden pattern by exhaustive search on small grids (e.g., 4×4) using `native_decide`.
- Prove the abstract equivalence: `Function.Surjective (tropicalLifeStep hm hn) ↔ Function.Injective (tropicalLifeStep hm hn)` using `Finite.surjective_iff_injective`.

**Cross-Domain Connections**: This connects tropical dynamics to symbolic dynamics (Curtis–Hedlund–Lyndon theorem), finite model theory, and constraint satisfaction. The Garden-of-Eden theorem in classical cellular automata has deep connections to amenability of groups; the tropical version opens questions about which group-theoretic properties are needed when the local rule has algebraic structure.

**Concrete Lean Target**:
```lean
theorem tropical_surjective_iff_injective {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    Function.Surjective (tropicalLifeStep hm hn) ↔
    Function.Injective (tropicalLifeStep hm hn)
```

---

### 2. Entropy and Growth-Rate Invariants for Tropical Automata

**Hypothesis**: The topological entropy of the tropical Life shift action (on the space of all bi-infinite orbits) is positive, and can be bounded below using the glider's orbit diversity.

**Proof Strategy**:
- Define the set of periodic orbits of period dividing `T` and count them.
- Use the glider's linear orbit diversity to establish that the number of distinguishable orbit prefixes grows at least linearly, giving a logarithmic entropy lower bound.
- For upper bounds, use the finite state space of the torus: entropy is at most `m * n * log 2` (for binary configurations).
- Formalize the entropy as `limsup (1/T * log(orbitDiversity T))` and prove positivity.

**Cross-Domain Connections**: Topological entropy is a fundamental invariant in ergodic theory and symbolic dynamics. Computing it for a tropical cellular automaton bridges algebraic dynamics with information theory. The tropical structure may yield sharper entropy formulas via tropical intersection theory.

**Concrete Lean Target**:
```lean
theorem positive_orbit_growth {m n : ℕ} (hm : 6 ≤ m) (hn : 6 ≤ n) :
    ∃ c : Config m n, ∀ T : ℕ, 0 < T → 1 ≤ orbitDiversity hm hn T c
```

---

### 3. Reversible Tropical Automata and Conserved Min-Plus Quantities

**Hypothesis**: There exist nontrivial reversible cellular automata whose local rule is expressible in tropical (min-plus) arithmetic, and these automata admit conserved tropical quantities (analogous to energy conservation in Hamiltonian systems).

**Proof Strategy**:
- Define a reversible tropical automaton by requiring the step operator to be a bijection on `Config m n`.
- Consider second-order rules: `c_{t+1}(x) = f(neighbors(c_t, x)) ⊕_trop c_{t-1}(x)` where `⊕_trop` is tropical addition (min). These are automatically reversible.
- Define a tropical "energy" functional `E(c) = Σ_x min(c(x), neighborMin(c, x))` and prove conservation: `E(step(c)) = E(c)`.
- Use `native_decide` on small grids to verify conservation, then prove it algebraically for general grids.

**Cross-Domain Connections**: Reversible computation is central to thermodynamics of computation (Landauer's principle). Tropical conserved quantities connect to shortest-path invariants and max-flow/min-cut duality. This direction bridges tropical geometry, Hamiltonian dynamics, and the physics of computation.

**Concrete Lean Target**:
```lean
def tropicalEnergy {m n : ℕ} (c : Config m n) : ℕ := Finset.univ.sum (fun x => c x)

theorem reversible_tropical_conserves_energy
    {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (c : Config m n) :
    tropicalEnergy (reversibleTropicalStep hm hn c) = tropicalEnergy c
```

---

### 4. Universality via Finite-Support Embeddings on Infinite Grids

**Hypothesis**: The tropical Life automaton on `ℤ × ℤ` (or sufficiently large tori) can simulate arbitrary Boolean circuits, achieving P-completeness of the circuit value problem under tropical local rules.

**Proof Strategy**:
- Define finite-support configurations on `ℤ × ℤ` as the colimit of torus configurations.
- Build signal-carrying trajectories from gliders: prove that gliders on large tori have long collision-free paths.
- Construct AND, OR, NOT gadgets from glider collisions:
  - NOT: a glider colliding with a fixed reflector produces an output glider iff no input glider arrives.
  - AND: two gliders must collide at the right time to produce an output.
- Prove compositional correctness by induction on circuit depth.
- Use the finite-torus results as building blocks: each gadget is verified by `native_decide` on a bounded region, then embedded into the larger grid.

**Cross-Domain Connections**: This places tropical dynamics in conversation with intrinsic universality (the study of which cellular automata can simulate all others), circuit complexity (P-completeness via uniform circuit families), and unconventional computing (physical computation via algebraic dynamics). A Lean-certified universality proof would be a landmark in formal verification of computational universality.

**Concrete Lean Target**:
```lean
inductive GateType | and | or | not

structure BooleanCircuit where
  gates : List (GateType × List ℕ)
  inputs : ℕ

theorem tropicalLife_simulates_circuit (C : BooleanCircuit) :
    ∃ m n : ℕ, ∃ c : Config m n, ∃ t : ℕ,
      decodeOutput ((tropicalLifeStep ...)^[t] c) = C.eval (encodeInput c)
```

---

### 5. Categorical Semantics of Tropical Local Rules as Semiring Transducers

**Hypothesis**: Tropical cellular automata form a category where morphisms are radius-bounded tropical transducers, and this category is equivalent to a subcategory of modules over the tropical semiring.

**Proof Strategy**:
- Define the category `TropCA` with objects being tropical automata (pairs of alphabet and local rule) and morphisms being factor maps (shift-commuting continuous surjections with tropical structure).
- Prove that composition of tropical local rules (block maps) is again a tropical local rule, establishing closure under composition.
- Define functors to the category of tropical modules: the configuration space `Config m n` is a module over the tropical semiring `(ℕ, min, +)`.
- Show that the step operator is a tropical-linear map (it preserves `min` and commutes with tropical scalar multiplication) under appropriate conditions.
- Prove that factor maps between tropical automata correspond to tropical module homomorphisms.

**Cross-Domain Connections**: This provides a rigorous algebraic framework for tropical computation theory. The categorical perspective connects to:
- Algebraic automata theory (Krohn-Rhodes decomposition in the tropical setting)
- Tropical algebraic geometry (tropical varieties as invariant sets of tropical transducers)
- Formal language theory (tropical weighted automata and their semiring-theoretic properties)
- Quantum computation (tropical semirings as classical limits of quantum probability amplitudes)

**Concrete Lean Target**:
```lean
structure TropicalCA where
  alphabet : Type*
  radius : ℕ
  localRule : (Fin (2 * radius + 1) → alphabet) → alphabet

def TropicalCA.compose (f g : TropicalCA) : TropicalCA := ...

instance : Category TropicalCA where
  Hom := TropicalCAMorphism
  id := TropicalCAMorphism.id
  comp := TropicalCAMorphism.comp
```

---

## Priority Ordering

1. **Garden-of-Eden** (Direction 1) — most tractable, uses existing finite-grid infrastructure
2. **Entropy bounds** (Direction 2) — natural extension of orbit diversity results
3. **Reversible automata** (Direction 3) — opens new territory with physics connections
4. **Circuit universality** (Direction 4) — high-impact but requires significant gadget engineering
5. **Categorical semantics** (Direction 5) — foundational but requires the most new mathematical infrastructure

## Team Directive

Create a team to conduct research, brainstorm hypotheses, run experiments, validate data, update knowledge base and iterate. Each direction above is specific enough to assign to a sub-team:

- **Team Alpha**: Garden-of-Eden + surjectivity/injectivity on finite tori
- **Team Beta**: Entropy computation + growth-rate bounds from glider theory
- **Team Gamma**: Reversible tropical rules + conservation laws
- **Team Delta**: Gate gadgets + circuit simulation + universality
- **Team Epsilon**: Category theory infrastructure + tropical module theory

All teams should maintain a shared library of verified tropical lemmas and contribute to a growing Lean formalization of tropical computation theory.
