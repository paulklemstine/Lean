# Future Directions: Tropical Collision Complexity

## 1. Concrete Gadget Construction for Specific CA Rules

### Theorem Target
```
theorem concrete_nand_gadget_for_von_neumann_rule :
    ∃ (m n T : ℕ) (enc : Bool → Bool → Config ℤ m n)
      (dec : Config ℤ m n → Bool),
      ∀ a b, dec (evolve vonNeumannStep T (enc a b)) = !(a && b)
```

### Strategy
1. **Enumerate** small collision patterns on 10×10 to 20×20 tori using computer search.
2. For each candidate, verify the truth table by evolving all 4 input combinations.
3. **Certify** the winning pattern in the formal framework by instantiating `BinaryGateGadget`.
4. Extend to specific rules beyond von Neumann: Moore neighborhood, asymmetric rules, higher-dimensional tori.

### Impact
This would convert our abstract universality theorem into a concrete, runnable universal computer. It would be the first rigorously verified collision-based universal CA in the tropical setting.

### Cross-domain connections
- **Experimental mathematics:** GPU-accelerated search over collision patterns
- **Symmetry exploitation:** Rule symmetries reduce the search space
- **Machine learning:** Train a classifier to predict which collision patterns realize which gates

---

## 2. Tropical Circuit Complexity Theory

### Theorem Target
```
theorem tropical_circuit_depth_lower_bound :
    ∀ (f : (Fin n → Bool) → Bool),
      f ∈ PARITY n →
        ∀ (C : NandCircuit), C.computes f →
          C.depth ≥ ⌈log₂ n⌉
```

```
theorem torus_size_lower_bound :
    ∀ (f : (Fin n → Bool) → Bool) (C : NandCircuit),
      C.computes f →
        torusArea (compile C) ≥ C.numGates * minGadgetArea
```

### Research Program
1. Define **tropical circuit size** = number of collision gadgets, **tropical circuit depth** = number of sequential collision layers, **tropical circuit area** = torus cells used.
2. Prove **lower bounds** on area and runtime for specific functions (parity, majority, threshold).
3. Define **tropical P** and **tropical NP** based on polynomial torus area and runtime.
4. Study the relationship between tropical circuit complexity and classical circuit complexity (AC⁰, TC⁰, NC¹).
5. Investigate whether tropical structure provides new proof techniques for circuit lower bounds.

### Impact
A new complexity theory where computational resources are geometric (area, propagation time) rather than combinatorial (tape cells, time steps). This could provide fresh approaches to circuit lower bound problems.

---

## 3. Monoidal Category of Collision Gadgets

### Theorem Target
```
theorem collision_gadgets_form_smc :
    ∃ (C : Category), SymmetricMonoidalCategory C ∧
      FaithfulFunctor BoolCircuitCat C ∧
      (∀ obj : C.obj, obj ≅ SignalBundle) ∧
      (∀ f : C.hom, f.realizes_ca_evolution)
```

### Research Program
1. **Objects** = signal bundles (lists of typed signal channels).
2. **Morphisms** = collision gadgets modulo spacetime equivalence.
3. **Tensor product** = spatial juxtaposition with sufficient separation.
4. **Composition** = sequential connection via wire delays.
5. Show the category is **symmetric monoidal closed**, with internal hom given by "gadgets that transform one signal bundle into another."
6. Prove a **faithful functor** from the category of Boolean circuits into the collision gadget category, making universality a categorical statement.

### Impact
This would provide a compositional semantics for collision computing, connecting to the broader program of categorical quantum mechanics, string diagrams, and process theories. It would enable reasoning about circuits at a higher level of abstraction.

---

## 4. Tropical Zeta Functions for Periodic Orbit Counting

### Theorem Target
```
theorem tropical_zeta_rationality :
    ∀ (F : MinPlusCA m n),
      ∃ (P Q : Polynomial ℤ),
        tropicalZeta F = P / Q
```

where `tropicalZeta F (t) := exp(∑_{p≥1} |Per_p(F)| * t^p / p)`.

### Research Program
1. For min-plus CAs with **bounded value range**, count `|Per_p(F)|` for small p using constraint system enumeration.
2. Test whether the sequence `|Per_p(F)|` satisfies a linear recurrence (which would imply rationality of the zeta function).
3. **Connect to tropical geometry:** The number of lattice points in the periodic prevariety `V_p` should be computable via Ehrhart theory if the prevariety is a rational polyhedron.
4. Prove rationality or establish counterexamples for specific CA rules.
5. Study the **tropical dynamical degree** = growth rate of `|Per_p(F)|^{1/p}` and its relationship to topological entropy.

### Impact
Dynamical zeta functions are central objects in ergodic theory and number theory. A tropical version would connect CA dynamics to algebraic geometry in a quantitative way, with implications for understanding the complexity of long-term behavior.

---

## 5. Intrinsic Simulation of Tag Systems and Reversible Lattice Gases

### Theorem Target
```
theorem tropical_ca_simulates_cyclic_tag :
    ∀ (T : CyclicTagSystem),
      ∃ (m n : ℕ) (enc : T.Config → Config ℤ m n)
        (dec : Config ℤ m n → T.Config),
        ∀ (c : T.Config) (t : ℕ),
          dec (evolve tropicalStep (t * simTimePerStep) (enc c)) = T.step^[t] c
```

### Research Program
1. **Cyclic tag systems** are the simplest known Turing-complete computation model. Simulate them directly in the tropical CA.
2. Alternatively, simulate a **reversible lattice gas** (Margolus partitioning CA) which is known to be universal.
3. For each primitive operation of the simulated system, construct a tropical collision gadget.
4. Prove the simulation is **faithful**: the encoding preserves computation steps exactly.
5. **Transfer Turing universality** from the simulated system to the tropical CA.

### Impact
This would establish not just circuit universality but **Turing universality** of tropical CAs, showing they can compute any computable function given unbounded time and space. Combined with the periodic orbit classification, this would mean that the halting problem for tropical CAs is undecidable—a strong indicator of dynamical complexity.

### Cross-domain connections
- **Reaction-diffusion computing:** tropical CAs as discrete analogues of chemical computing
- **Asynchronous computation:** tag systems are inherently sequential; their tropical simulation would illuminate the relationship between sequential and parallel computation
- **Kolmogorov complexity:** the simulation overhead relates to the descriptional complexity of the tropical CA rule
