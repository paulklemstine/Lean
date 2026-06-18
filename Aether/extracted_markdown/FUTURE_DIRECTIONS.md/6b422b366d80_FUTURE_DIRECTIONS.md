# Future Directions: Tropical Height Rigidity for Berggren Tree Valuations

## Overview

This document outlines five concrete breakthrough research directions opened by the formalization of tropical observable rigidity on Berggren tree orbits. Each direction includes specific theorem statements, proof strategies, and cross-domain connections.

---

## Direction 1: Asymptotic Sparsity of the Exceptional Set

### Vision
The current formalization proves that at each finite depth d, the exceptional set (observable values with non-singleton fibers) is finite and decidable. The next breakthrough is to prove that this set is *asymptotically sparse* relative to the total image.

### Target Theorem
```
theorem exceptional_density_vanishes :
    ∀ ε > 0, ∃ d₀, ∀ d ≥ d₀,
      (exceptionalSet d).card < ε * ((WordsUpTo d).image thetaAug).card
```

More ambitiously, bound the exceptional ratio by an explicit function of d:
```
theorem exceptional_ratio_bound (d : ℕ) (hd : 0 < d) :
    (exceptionalSet d).card ≤ C * 3^d / d
```
for some explicit constant C.

### Proof Strategy
1. Show that archimedean height grows exponentially along each branch (the smallest eigenvalue of each Berggren matrix exceeds 1).
2. Prove that the mod-p residues of triples cycle with period dividing p²-1 along any branch.
3. Combine: at depth d, there are 3^d words but the augmented observable space has size ~ C·3^d (since triples are mostly distinct and the mod-p data separates further), so collisions are forced to be rare.

### Cross-Domain Connection
This connects to the theory of *expanding maps on trees* — the Berggren action is expanding in the archimedean metric, which forces observable fibers to thin out. This is analogous to expansion-based arguments in spectral graph theory and expander-based cryptography.

---

## Direction 2: Tropical Polyhedral Complex for Berggren Observables

### Vision
The current observable vectors live in ℕ^7 (or ℕ^13 with augmentation). Organize the observable space into a *tropical polyhedral complex* where cells correspond to combinatorial types of fibers.

### Target Definition & Theorem
```
structure TropicalCell where
  constraints : List (ObsVec → Prop)  -- linear equalities/inequalities in tropical coords
  fiberType : FiberType               -- rigid, collision, or empty

def tropicalComplex (d : ℕ) : Finset TropicalCell := ...

theorem cells_cover_image (d : ℕ) :
    ∀ o ∈ (WordsUpTo d).image theta,
      ∃ c ∈ tropicalComplex d, o ∈ c.support

theorem rigid_cells_dominate (d : ℕ) :
    (tropicalComplex d |>.filter (·.fiberType = .rigid)).card >
    (tropicalComplex d |>.filter (·.fiberType = .collision)).card
```

### Proof Strategy
1. Define cells as equivalence classes of observable vectors under the relation "same fiber cardinality and same combinatorial structure."
2. Show that the number of cells grows polynomially in d (while the number of words grows exponentially), establishing that most cells are large and rigid.
3. Connect to tropical intersection theory: the collision locus is a tropical variety of codimension ≥ 1 in the observable space.

### Cross-Domain Connection
This creates the first formal bridge between **tropical geometry** (in the sense of Mikhalkin, Sturmfels) and **Diophantine orbit dynamics**. The tropical polyhedral complex encodes arithmetic information about Pythagorean triples in a geometric language.

---

## Direction 3: Transport to Markoff and Apollonian Orbit Trees

### Vision
The Berggren tree is one instance of a broader class of Diophantine orbit trees. The Markoff tree (solutions to x² + y² + z² = 3xyz) and Apollonian circle packings have analogous free-group actions. Transport the tropical rigidity framework to these settings.

### Target Theorem (Markoff)
```
-- Markoff generators
def markoffA : Matrix (Fin 3) (Fin 3) ℤ := !![3, 0, -1; 0, 1, 0; 1, 0, 0]
def markoffB : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 3, -1; 0, 1, 0]

def markoffTriple (w : MarkoffWord) : Fin 3 → ℤ := ...

theorem markoff_tropical_rigidity (d : ℕ) :
    ∀ o ∈ (MarkoffWordsUpTo d).image markoffTheta,
      (∃! w, w ∈ MarkoffWordsUpTo d ∧ markoffTheta w = o) ∨
      (∃ w₁ w₂, w₁ ≠ w₂ ∧ markoffTheta w₁ = o ∧ markoffTheta w₂ = o)
```

### Proof Strategy
The finite-depth rigidity theorem (Strategy A) is purely combinatorial and transfers directly. The challenge is in the *structural* rigidity (Strategy B): the Markoff tree has different growth properties and the uniqueness conjecture (every Markoff number determines its position uniquely) is famously open.

### Cross-Domain Connection
The Markoff uniqueness conjecture is one of the outstanding problems in Diophantine geometry. A tropical observable approach that separates most Markoff triples — even without resolving the full conjecture — would be a significant advance. The collision certificates would provide explicit counterexample candidates or evidence for uniqueness.

---

## Direction 4: Complexity Bounds for Certified Inversion

### Vision
The current inversion algorithm is noncomputable (uses classical choice). Make it constructive and analyze its computational complexity.

### Target Theorems
```
-- Constructive inversion
def invertThetaComputable (d : ℕ) (o : ObsVec) : 
    InversionResult d o := ...  -- no classical axioms

-- Complexity bound
theorem inversion_time_bound (d : ℕ) (o : ObsVec) :
    inversionSteps d o ≤ 3^(d+1)

-- Space bound for collision certificates
theorem certificate_size_bound (d : ℕ) (o : ObsVec) :
    ∀ cert : CollisionCertificate o, 
      cert.w₁.length + cert.w₂.length ≤ 2 * d
```

### Proof Strategy
1. Implement a decidable version of fiber enumeration using `Decidable` instances throughout.
2. Show that checking θ(w) = o for a single word takes O(d) matrix multiplications.
3. Establish that the canonical certificate (lexicographically minimal pair) can be found by sorting the fiber, which costs O(3^d · d · log(3^d)).
4. For average-case analysis, use the sparsity of exceptional sets to show that most inversions terminate early.

### Cross-Domain Connection
This connects to **proof complexity** and **certified algorithms**: the collision certificate is a succinct witness (two words of length ≤ d) for a computational claim about a function on an exponentially large domain. This is analogous to NP-witness structures in complexity theory, but here the certificate has *arithmetic* structure.

---

## Direction 5: Cryptographic Protocol Design

### Vision
Design a concrete cryptographic protocol where:
- The public key is a tropical observable vector θ(w) for a secret word w.
- Key recovery requires inverting θ, which is hard when the fiber is a singleton and ambiguous when it's not.
- Collision certificates serve as "ambiguity proofs" that can be used in zero-knowledge or deniable encryption protocols.

### Target Construction
```
structure TropicalKeyPair where
  secretWord : Word
  publicObs : AugObsVec
  depthBound : ℕ
  consistency : thetaAug secretWord = publicObs
  security : secretWord ∈ WordsUpTo depthBound

-- Semantic security: no PPT adversary can distinguish
-- two words with the same observable
theorem tropical_ind_security :
    ∀ (A : PPTAdversary), 
      advantage A (tropicalGame d) ≤ negligible d

-- Collision-based deniability
theorem deniable_decryption :
    ∀ cert : CollisionCertificate o,
      ∃ alt_key, decrypt alt_key (encrypt publicObs msg) = msg
```

### Proof Strategy
1. Define the key generation, encryption, and decryption algorithms using Berggren words.
2. Prove correctness: decryption with the right word always succeeds.
3. For security, reduce to the hardness of inverting θ over exponentially large word spaces.
4. For deniability, use collision certificates to construct alternative decryption keys.

### Cross-Domain Connection
This creates a new paradigm in **post-quantum cryptography**: instead of lattice problems or isogeny problems, the hardness comes from inverting arithmetic-dynamical observables on trees. The tropical structure provides natural "trapdoor" properties that are geometrically meaningful.

---

## Summary Table

| Direction | Difficulty | Impact | Timeline |
|-----------|-----------|--------|----------|
| 1. Asymptotic sparsity | Medium-Hard | High | 3-6 months |
| 2. Tropical polyhedral complex | Hard | Very High | 6-12 months |
| 3. Markoff/Apollonian transport | Medium | High | 3-6 months |
| 4. Complexity bounds | Medium | Medium-High | 2-4 months |
| 5. Cryptographic protocol | Hard | Very High | 6-12 months |

All five directions build directly on the formalized infrastructure in this module and can proceed in parallel. The most impactful combination is Directions 1+2 (establishing the geometric theory) and 3+5 (establishing applications).
