
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: Zombies and Qualia: Mathematics of Subjective Experience
**Domain**: Algebra
**Mathematical framing**: Formalize the hard problem of consciousness as a theorem about the gap between functional descriptions and subjective experience. Prove that any system satisfying the functional definition of consciousness can have a zombie twin that is functionally identical but experientially void. Show this gap is isomorphic to Gödel's incompleteness gap.
Research domain: Algebra
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Algebra/ObservationGap.lean
import Mathlib

/-!
# The Observation Gap: Algebraic Foundations of Functional Indistinguishability

We formalize the mathematical structure underlying the problem of distinguishing
internal states from external observations. The central question: when can a finite
collection of observations fully determine the internal state of a system?

## Main Results

1. **`observation_pigeonhole`**: Any system of `n` Boolean observations on a type with
   more than `2^n` elements must contain a "twin pair" — two distinct elements that are
   observationally indistinguishable.

2. **`observation_quotient_card_le`**: The quotient by observational equivalence has at most
   `2^n` classes, bounding the discriminative power of any finite observation system.

3. **`refinement_monotone_separation`**: Refining an observation system (adding predicates)
   can only increase discriminative power — the quotient map is surjective.

4. **`observation_can_suffice`**: When `|α| = 2^n`, observations CAN distinguish all
   elements — establishing the tight boundary of the pigeonhole result.

5. **`generalized_observation_pigeonhole`**: Generalization to observations valued in an
   arbitrary finite type `β`, with bound `|β|^n`.
-/

namespace ObservationGap

-- ============================================================================
-- Core Definitions
-- ============================================================================

/-- An observation system consists of `n` Boolean predicates on a type `α`. -/
structure ObsSys (α : Type*) (n : ℕ) where
  pred : Fin n → α → Bool

/-- The observation profile maps each element to its tuple of predicate values. -/
def ObsSys.profile {α : Type*} {n : ℕ} (O : ObsSys α n) (a : α) : Fin n → Bool :=
  fun i => O.pred i a

/-- Two elements are observationally indistinguishable (twins). -/
def ObsSys.twins {α : Type*} {n : ℕ} (O : ObsSys α n) (a b : α) : Prop :=
  O.profile a = O.profile b

/-- The twin relation is an equivalence relation. -/
theorem observation_equiv_is_equivalence {α : Type*} {n : ℕ} (O : ObsSys α n) :
    Equivalence (O.twins) :=
  ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-- The setoid induced by observational equivalence. -/
def ObsSys.setoid {α : Type*} {n : ℕ} (O : ObsSys α n) : Setoid α where
  r := O.twins
  iseqv := observation_equiv_is_equivalence O

/-- Fintype instance for the observation quotient. -/
noncomputable instance ObsSys.quotientFintype {α : Type*} [Fintype α] {n : ℕ}
    (O : ObsSys α n) : Fintype (Quotient O.setoid) := by
  letI : DecidableRel O.setoid.r := fun a b =>
    inferInstanceAs (Decidable (O.profile a = O.profile b))
  exact Quotient.fintype O.setoid

-- ============================================================================
-- Theorem 1: Observation Pigeonhole
-- ============================================================================

-- !-- Uses Fintype.exists_ne_map_eq_of_card_lt on the profile map. The codomain
-- Fin n → Bool has cardinality 2^n, so if |α| > 2^n, profile is not injective. -- !--

/-- **Observation Pigeonhole Theorem**: Any system of `n` Boolean observations on a
    finite type with more than `2^n` elements must contain a twin pair — two distinct
    elements that are observationally indistinguishable. -/
theorem observation_pigeonhole {α : Type*} [Fintype α] [DecidableEq α] {n : ℕ}
    (O : ObsSys α n) (hcard : 2 ^ n < Fintype.card α) :
    ∃ a b : α, a ≠ b ∧ O.twins a b := by
  convert Fintype.exists_ne_map_eq_of_card_lt _ _
  exacts [inferInstance, inferInstance, by simpa [Fintype.card_pi] using hcard]

-- ============================================================================
-- Theorem 2: Quotient Cardinality Bound
-- ============================================================================

-- !-- The profile map descends to an injection on the quotient. Since the codomain has
-- 2^n elements, the quotient has at most 2^n equivalence classes. -- !--

/-- The profile map factors through the quotient injectively. -/
theorem profile_factors_injective {α : Type*} {n : ℕ} (O : ObsSys α n) :
    ∃ f : Quotient O.setoid → (Fin n → Bool),
      Function.Injective f ∧
      ∀ a : α, f (Quotient.mk O.setoid a) = O.profile a := by
  refine ⟨fun q => Quotient.liftOn' q (fun x => O.profile x) ?_, ?_, fun _ => rfl⟩
  · intro a b hab; exact hab
  · rintro ⟨a₁⟩ ⟨a₂⟩ h
    exact Quotient.sound h

/-- **Quotient Cardinality Bound**: The observation quotient has at most `2^n` classes. -/
theorem observation_quotient_card_le {α : Type*} [Fintype α] [DecidableEq α] {n : ℕ}
    (O : ObsSys α n) :
    Fintype.card (Quotient O.setoid) ≤ 2 ^ n := by
  obtain ⟨f, hf, _⟩ := profile_factors_injective O
  simpa using Fintype.card_le_of_injective f hf

-- ============================================================================
-- Theorem 3: Refinement Monotonicity
-- ============================================================================

/-- An observation system `O₂` refines `O₁` if `O₂`-equivalence implies `O₁`-equivalence. -/
def ObsSys.refines {α : Type*} {m n : ℕ} (O₂ : ObsSys α m) (O₁ : ObsSys α n) : Prop :=
  ∀ a b : α, O₂.twins a b → O₁.twins a b

-- !-- Define a map on quotients via Quotient.lift. Well-definedness follows from the
-- refinement condition. Surjectivity follows because every quotient class has a rep. -- !--

/-- **Refinement Surjection**: If `O₂` refines `O₁`, there is a surjection from
    `O₂`-quotient to `O₁`-quotient. -/
theorem refinement_monotone_separation {α : Type*} {m n : ℕ}
    (O₁ : ObsSys α n) (O₂ : ObsSys α m) (href : O₂.refines O₁) :
    ∃ f : Quotient O₂.setoid → Quotient O₁.setoid, Function.Surjective f := by
  use fun q => Quotient.lift (fun a => Quotient.mk O₁.setoid a)
    (fun a b hab => Quotient.sound <| href a b <| by simpa using hab) q
  exact fun q => Quotient.inductionOn' q fun a => ⟨⟦a⟧, rfl⟩

-- ============================================================================
-- Theorem 4: Concrete Example and Boundary
-- ============================================================================

/-- **Concrete Twin Example**: For any single Boolean predicate on `Fin 3`,
    there exist two distinct elements with the same predicate value. -/
theorem concrete_twin_fin3 (p : Fin 3 → Bool) :
    ∃ a b : Fin 3, a ≠ b ∧ p a = p b := by
  native_decide +revert

-- !-- Construct O using bit extraction: pred i a = a.val.testBit i. Two elements
-- with identical first n bits in Fin (2^n) must be equal. -- !--

/-- **Sufficiency Boundary**: When `|α| = 2^n`, an observation system CAN
    distinguish all elements. Uses the binary encoding of `Fin (2^n)`. -/
theorem observation_can_suffice (n : ℕ) :
    ∃ O : ObsSys (Fin (2 ^ n)) n,
      ∀ a b : Fin (2 ^ n), O.twins a b → a = b := by
  use ⟨fun i a => a.val.testBit i⟩
  unfold ObsSys.twins
  simp +decide [funext_iff, ObsSys.profile]
  intro a b h
  exact Fin.ext <| Nat.eq_of_testBit_eq fun i =>
    if hi : i < n then h ⟨i, hi⟩
    else by
      rw [Nat.testBit_eq_false_of_lt, Nat.testBit_eq_false_of_lt] <;>
        linarith [Fin.is_lt a, Fin.is_lt b,
          Nat.pow_le_pow_right two_pos (show n ≤ i from le_of_not_gt hi)]

-- ============================================================================
-- Generalization: Arbitrary Observation Codomains
-- ============================================================================

/-- A generalized observation system with values in an arbitrary finite type `β`. -/
structure GenObsSys (α β : Type*) (n : ℕ) where
  pred : Fin n → α → β

def GenObsSys.profile {α β : Type*} {n : ℕ} (O : GenObsSys α β n) (a : α) : Fin n → β :=
  fun i => O.pred i a

def GenObsSys.twins {α β : Type*} {n : ℕ} (O : GenObsSys α β n) (a b : α) : Prop :=
  O.profile a = O.profile b

-- !-- Same argument as observation_pigeonhole but with |β|^n in place of 2^n. -- !--

/-- **Generalized Pigeonhole**: For observations valued in a `k`-element type,
    `n` observations cannot distinguish more 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Observation Gap

## 1. Adaptive Observation Systems and Information-Theoretic Bounds

The current framework considers *static* observation systems where all predicates are fixed in advance. A natural extension is **adaptive observation**, where the choice of the (k+1)-th predicate depends on the outcomes of the first k predicates. The conjecture is that adaptive observation systems with n Boolean queries can distinguish at most 2^n elements — the same bound as static systems — but the proof requires a different argument (a game-theoretic or information-theoretic one rather than pure pigeonhole).

The key insight is that each Boolean observation provides at most 1 bit of information regardless of whether it's chosen adaptively, so the total information is still bounded by n bits. This connects to Shannon's source coding theorem.

Why now? The static framework is fully formalized, and Mathlib has growing coverage of information theory (`MeasureTheory.Measure.MutualInformation`) that could support an entropy-based proof.

## 2. Continuous Observation Systems and Topological Separation

Replace Boolean predicates with continuous real-valued observations on a topological space. The analogue of the pigeonhole theorem becomes: if α is a compact Hausdorff space and we have n continuous functions f₁,...,fₙ : α → ℝ, then the observation map F = (f₁,...,fₙ) : α → ℝⁿ cannot be injective when dim(α) > n. This is essentially the Borsuk-Ulam theorem / invariance of domain.

The key insight is that the observation gap transitions from a combinatorial phenomenon (pigeonhole) to a topological one (dimension theory), but the algebraic structure — quotient by observational equivalence — is identical in both settings.

Why now? Mathlib has `TopologicalSpace`, compactness, and significant covering dimension theory. The Borsuk-Ulam theorem is not yet in Mathlib but partial formalizations exist, making this a tractable next target.

## 3. Observation Algebras and Stone Duality

The collection of all observation systems on a fixed type α forms a lattice under refinement (Theorem 3). Conjecture: this lattice is isomorphic to the lattice of equivalence relations on α (which is well-studied as the partition lattice). Moreover, when α is finite, this lattice is anti-isomorphic to a sublattice of the Boolean algebra of subsets of α × α via the kernel map.

The key insight is that observation systems are dual to partitions via Stone-type duality, and this duality should extend to a categorical equivalence between "observable properties" and "quotient structures."

Why now? The refinement surjection theorem provides the morphism direction. Mathlib's `Setoid.Lattice` and `Partition` infrastructure can support the lattice-theoretic formalization.

## 4. Probabilistic Observation and Approximate Twins

Strengthen the pigeonhole result: not only do twin pairs exist, but a random pair of elements is observationally indistinguishable with probability at least
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
