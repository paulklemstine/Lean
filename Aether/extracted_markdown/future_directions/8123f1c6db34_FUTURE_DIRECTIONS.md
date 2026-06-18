# Future Directions: Berggren-Tree Rigidity and Post-Quantum Cryptography

## 1. Formal Branch-Separation Radii and Certified Decoding Thresholds

The noisy decoding demo shows that exact recovery fails under even small L∞ perturbations. A key open formalization target is **explicit certified radii** around each triple in the tree within which decoding is guaranteed correct.

**Formal target:**
```lean
def certifiedRadius (v : PrimitiveTriple) : ℝ :=
  -- minimum over i ≠ j of the separation between inv branches i and j

theorem decodeNearestWord_correct_of_local_radius
    (w : List (Fin 3)) (η : Triple)
    (hη : tripleDefect η (actWord w rootTriple) < certifiedRadius (evalWord w)) :
    decodeNearestWord η = w
```

The cone separation inequalities (differences in signs of inverse-branch coordinates) provide natural lower bounds. Making these explicit and proving they grow with depth would establish a **formally certified decoding guarantee** analogous to Babai's nearest-plane algorithm for lattices.

## 2. Berggren Nearest-Plane Algorithm with Polynomial Complexity Bounds

Design a nearest-triple decoder that runs in time polynomial in the word length (i.e., logarithmic in the hypotenuse). The key insight is that at each descent step, only 3 inverse branches need to be tested, making each step O(1). The number of steps equals the word length, which is O(log c) where c is the hypotenuse.

**Formal target:**
```lean
def nearestPlaneDecoder : Triple → BWord := ...

theorem nearestPlane_complexity (t : Triple) (ht : GoodTriple t) :
    (nearestPlaneDecoder t).length ≤ ⌈Real.log (t.2.2 : ℝ) / Real.log 3⌉₊

theorem nearestPlane_correct_exact (w : BWord) :
    nearestPlaneDecoder (evalAtRoot w) = w
```

This would formalize the analogy between Berggren descent and LLL/BKZ lattice reduction: both are polynomial-time algorithms for recovering short vectors, but in fundamentally different geometric settings (abelian vs. free-semigroup).

## 3. Symbolic Geodesic Coding for Lorentzian/Hyperbolic Dynamics

The Berggren tree admits a natural interpretation as a subtree of the modular group PSL(2,ℤ) acting on the upper half-plane. The Berggren matrices preserve the Lorentz form a² + b² − c², making them elements of SO(2,1;ℤ). The height function log(c) is a discrete geodesic energy.

**Formal target:**
```lean
def lorentzForm (v : Triple) : ℤ := v.1^2 + v.2.1^2 - v.2.2^2

theorem actGen_preserves_lorentz (g : BGen) (v : Triple) :
    lorentzForm (actGen g v) = lorentzForm v

def symbolicGeodesic (v : PrimitiveTriple) : ℕ → BGen :=
  -- infinite symbolic coding of the geodesic from root to boundary point

theorem symbolicGeodesic_encodes_continued_fraction :
    -- the symbolic geodesic corresponds to a generalized continued fraction
    -- expansion of the angle arctan(a/b)
```

This bridges number theory, hyperbolic geometry, and symbolic dynamics. The formal verification would connect the Berggren tree to Markov chains on the Farey graph and to the thermodynamic formalism of geodesic flows.

## 4. Cryptographic Hardness Reductions from Noisy Berggren Decoding

The **noisy word recovery problem** is: given a perturbed triple η ≈ evalAtRoot(w), recover w. The security of a Berggren-word cryptosystem depends on this problem being hard for large perturbations (large noise-to-signal ratio relative to the certified radius).

**Formal target:**
```lean
def NoisyWordRecovery (η : Triple) (D : ℕ) : Prop :=
  ∃ w : BWord, tripleDefect η (evalAtRoot w) ≤ D

theorem noisy_recovery_hardness_lower_bound
    (D : ℕ) (hD : certifiedRadius_uniform < D) :
    -- The number of candidate words within defect D grows exponentially
    ∃ S : Finset BWord, ∀ w ∈ S, tripleDefect (evalAtRoot w) target ≤ D ∧
      S.card ≥ 3^(D / separation_gap)
```

A formal hardness reduction from approximate CVP (closest vector problem) in lattices to noisy Berggren decoding would establish post-quantum security guarantees. The noncommutativity of the Berggren semigroup means that quantum algorithms for abelian hidden subgroup problems (like Shor's algorithm) do not directly apply.

## 5. Higher-Dimensional Analogues: Markov-Hurwitz and Lorentzian Norm-Form Trees

The Berggren construction generalizes to other indefinite quadratic forms. The **Markov equation** x² + y² + z² = 3xyz generates a similar ternary tree of integer solutions. The Hurwitz equation and higher-dimensional Lorentzian norm forms (a₁² + ... + aₙ₋₁² = aₙ²) also admit tree structures.

**Formal target:**
```lean
def MarkovTriple (v : Fin 3 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 = 3 * v 0 * v 1 * v 2

def markovGen (i : Fin 3) (v : Fin 3 → ℤ) : Fin 3 → ℤ :=
  -- Vieta involution on coordinate i

theorem markov_tree_faithful :
    ∀ w₁ w₂ : List (Fin 3),
      markovEval w₁ markovRoot = markovEval w₂ markovRoot → w₁ = w₂

-- Pythagorean quadruples a² + b² + c² = d²
def PythQuadGen (i : Fin 7) : Matrix (Fin 4) (Fin 4) ℤ := ...

theorem quadruple_tree_completeness :
    ∀ v : Fin 4 → ℤ, primitiveQuadruple v →
      ∃ w : List (Fin 7), quadEval w quadRoot = v
```

The unifying theme is **arithmetic tree structures** arising from indefinite quadratic forms, where the Berggren tree is the simplest nontrivial case. Formalizing the general framework would connect number theory, algebraic geometry, and cryptographic group actions.
