# Future Directions: Free-Energy No-Self-Compression Theorem

The Free-Energy No-Self-Compression Theorem opens several concrete
research programs at the intersection of proof theory, statistical
mechanics, and algorithmic information theory.

---

## 1. β-Asymptotics and Logical Phase Transitions

**Goal:** Formalize the monotonicity and convexity properties of the
map `β ↦ freeEnergy β (selfCode G)` and prove existence of critical
inverse temperatures where the self-compression obstruction changes
regime.

**Concrete next steps:**
- Prove that the free-energy gap `F(β) − floor(β)` is monotone
  increasing (or convex) in β for diagonal sentences.
- Define a critical inverse temperature `β_c` as the infimum over β
  where the gap exceeds a threshold.
- Investigate whether there exist logical phase transitions: values
  of β where the set of unprovable compression statements undergoes
  a qualitative change (analogous to thermodynamic phase transitions).
- Formalize the zero-temperature limit (`β → ∞`) and prove that the
  no-self-compression theorem degenerates to a min-plus/tropical
  fixed-point obstruction.

**Expected difficulty:** Medium. The monotonicity/convexity properties
should follow from standard analysis once the free-energy functional
is concretely instantiated. The phase transition analysis is more
speculative.

---

## 2. Rate–Distortion Version of Incompleteness

**Goal:** Replace strict self-compression by bounded distortion
relative to truth-preserving approximants, and prove a thermodynamic
rate–distortion lower bound for self-models.

**Concrete next steps:**
- Define a distortion function `d : Sentence × Sentence → ℝ≥0`
  measuring how far an approximant is from the original sentence.
- Define the rate–distortion function `R(D)` as the infimum of
  mutual information (or free energy) over all encodings achieving
  distortion ≤ D.
- Prove that `R(D) ≥ complexityFloor − correction(D)` for
  self-referential sentences.
- Show that the no-self-compression theorem is the D = 0 case
  of this more general rate–distortion bound.

**Expected difficulty:** High. This requires integrating Shannon's
rate–distortion theory with the proof-theoretic framework.

---

## 3. Prime Witness Extraction Algorithm

**Goal:** Use min-energy prime witness extraction (from the
Thermodynamic Stone–Prime Completeness theorem in the project's
Bridges module) to define a certified search procedure for
near-minimal self-evaluations with approximation guarantees.

**Concrete next steps:**
- Connect the `thermodynamic_prime_separation` theorem to the
  no-self-compression result: non-provability of compression
  yields a prime separating witness.
- Define an algorithmic procedure that, given β and a sentence G,
  produces a prime point p and a witness showing F(β, code) ≥ floor(β, G).
- Prove approximation guarantees: the extracted witness achieves
  energy within a factor (1 + ε) of the optimal.
- Implement the extraction algorithm in a computable fragment.

**Expected difficulty:** Medium-High. The theoretical framework
exists in the Bridges module; the main work is connecting the
two developments and extracting computational content.

---

## 4. Tropicalization of Free-Energy Incompleteness

**Goal:** Study the zero-temperature (tropical) limit of the
no-self-compression theorem and prove that it degenerates to
a min-plus fixed-point obstruction.

**Concrete next steps:**
- Define the tropical free energy as `lim_{β→∞} (1/β) · F(β, code)`.
- Prove that the tropical limit of the complexity floor equals
  the min-plus complexity of the sentence.
- Show that the no-self-compression theorem in the tropical limit
  becomes: no sentence can achieve min-plus self-code complexity
  below its tropical complexity floor.
- Connect this to the existing Tropical SPB development in the
  project's EML catalog.

**Expected difficulty:** Medium. The tropical/min-plus algebra
is well-understood, and the project already has tropical SPB
infrastructure.

---

## 5. Multi-Agent Reflective Systems

**Goal:** Generalize from one self-model to interacting closure
self-models and prove a no-mutual-compression theorem.

**Concrete next steps:**
- Define a system of `n` coherent closure self-models
  `M₁, ..., Mₙ` with inter-model provability predicates
  `Prov_i(φ_j)`.
- Define mutual compression: `Mᵢ ⊢ ⌜F(β, code_j(G)) < floor_j(β, G)⌝`.
- Prove: sufficiently coherent agents cannot jointly certify
  sub-floor compression of each other's full reflective theories.
- Investigate whether the multi-agent bound is strictly stronger
  than the single-agent bound (i.e., whether interaction creates
  additional thermodynamic cost).

**Expected difficulty:** High. The multi-agent setting introduces
significant combinatorial complexity in the diagonal argument.

---

## Summary Table

| Direction | Core Technique | Difficulty | Prerequisites |
|-----------|---------------|------------|---------------|
| β-asymptotics | Convex analysis, tropicalization | Medium | Current theorem |
| Rate–distortion | Information theory | High | Current theorem + Shannon theory |
| Prime extraction | Algorithmic witness search | Medium-High | Bridges module |
| Tropicalization | Min-plus algebra | Medium | Tropical SPB catalog |
| Multi-agent | Combinatorial diagonalization | High | Current theorem |

Each direction represents a publishable research contribution
and extends the core insight — self-reference has a thermodynamic
cost — in a distinct mathematical direction.
