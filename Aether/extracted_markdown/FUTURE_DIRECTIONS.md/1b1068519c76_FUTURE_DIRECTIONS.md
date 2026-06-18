# Future Directions: Tropical Lens–Berggren Duality

## 1. Tropical Lens Rigidity on Arithmetic Trees Beyond Berggren

**Theorem target:**
For the Apollonian gasket tree (or Markov triple tree), formalize a tropical lens system where edge costs arise from the recursive structure, and prove that delay-separated observations determine the underlying triple uniquely.

**Proof strategy:**
Extend `BerggrenLensSystem` to accept any recursively generated tree of integer triples. The Apollonian gasket has a similar 3-generator structure (Descartes circle theorem). Define `PythagoreanShell` analogues using the curvature relation `(k₁+k₂+k₃+k₄)² = 2(k₁²+k₂²+k₃²+k₄²)`. Prove separation using the strict growth of curvatures along tree paths.

**Cross-domain connections:**
- Circle packing ↔ hyperbolic geometry
- Spectral gap estimates on arithmetic trees
- Connections to Zaremba's conjecture via continued fractions

---

## 2. A Myhill–Nerode Theorem for Tropical Observers

**Theorem target:**
```
theorem tropical_myhill_nerode (Sys : BerggrenLensSystem)
    (hsep : Sys.DelaySeparated) :
    ∃ (Q : Type) (_ : Fintype Q) (φ : Sys.Node → Q),
      Surjective φ ∧
      (∀ s₁ s₂, φ s₁ = φ s₂ ↔ delayNodeEquiv Sys s₁ s₂) ∧
      Fintype.card Q = Fintype.card (myhillNerodeQuotient Sys)
```

**Proof strategy:**
The current `myhill_nerode_bound` already shows `|Q| ≤ |Node|`. The full Myhill–Nerode theorem would additionally show that Q is the *unique minimal* automaton recognizing the delay language: any other automaton with the same input-output behavior has at least as many states. Formalize this by defining "tropical automaton" as a structure with states, transition costs, and output, then proving that the quotient automaton is minimal.

**Cross-domain connections:**
- Weighted automata over idempotent semirings (Simon, Droste–Kuich–Vogler)
- Tropical formal power series
- Minimal realization in systems theory (Kalman decomposition)

---

## 3. Certified Lower Bounds: Delay-Separation Complexity vs. Semiprime Hardness

**Theorem target:**
Prove that for a family of lens systems encoding n-bit semiprimes, the number of observers required for delay separation grows at least polynomially in n.

**Proof strategy:**
Define a family `BerggrenLensSystem_n` parameterized by bit-length n, where nodes encode n-bit primes and sources encode semiprime products. Show that if fewer than f(n) observers suffice for separation, one could factor n-bit semiprimes in polynomial time, contradicting standard complexity assumptions (formalized as an axiom or hypothesis). This connects tropical sensing to computational hardness.

**Cross-domain connections:**
- Complexity-theoretic reductions (factoring → separation)
- Information-theoretic bounds on compressed sensing
- Algebraic complexity theory (arithmetic circuits)

---

## 4. Sheaf/Cosheaf Formulation of Arithmetic Caustics

**Theorem target:**
Define a cellular cosheaf on the Berggren tree whose stalks are tropical semimodules and whose restriction maps are min-plus projections. Prove that global sections of this cosheaf correspond exactly to delay profiles of the lens system.

**Proof strategy:**
Use Mathlib's category theory library to define the cosheaf as a functor from the poset category of Berggren subtrees to the category of tropical semimodules. The key lemma is that the cosheaf condition (compatibility of restrictions) corresponds exactly to the min-plus convolution property of `lensTransform`. This gives a cohomological interpretation of obstruction to reconstruction.

**Cross-domain connections:**
- Persistent homology via cosheaves (Curry, Ghrist)
- Tropical cohomology (Mikhalkin–Zharkov)
- Derived categories in arithmetic geometry

---

## 5. Extension to Multi-Source Tropical Tomography

**Theorem target:**
```
theorem multi_source_reconstruction
    (Sys : BerggrenLensSystem)
    (k : ℕ) (sources : Fin k → BerggrenSource Sys)
    (hsep : MultiSourceSeparated Sys sources) :
    ∀ sources' : Fin k → BerggrenSource Sys,
      (∀ j o, lensTransform Sys (sources' j) o = lensTransform Sys (sources j) o) →
      ∀ j, ObservationallyEquivalent Sys (sources' j) (sources j)
```

**Proof strategy:**
Extend the single-source reconstruction to multiple independent sources. The separation condition now requires that the combined delay profiles of all sources jointly determine each individual source. This is the tropical analogue of multi-source seismology. Key technical challenge: defining "multi-source separation" in a way that doesn't trivially reduce to single-source separation.

**Cross-domain connections:**
- Seismic tomography (travel-time inversion with multiple earthquakes)
- Compressed sensing with structured sparsity
- Network tomography (inferring link delays from end-to-end measurements)

---

## Summary of Research Impact

These five directions collectively establish **tropical arithmetic tomography** as a new field bridging:
- Number theory (arithmetic trees, factorization)
- Tropical geometry (min-plus algebra, tropical varieties)
- Inverse problems (reconstruction, sensing, tomography)
- Automata theory (Myhill–Nerode, minimal realization)
- Algebraic topology (cosheaves, persistent homology)

The formally verified theorems in this module provide the foundational layer. Each future direction is independently publishable and extends the bridge in a distinct mathematical direction.
