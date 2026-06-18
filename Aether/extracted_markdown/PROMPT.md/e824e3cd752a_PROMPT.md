
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
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
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
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
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Close Proofs: Close Proofs: The sphere-packing bound gives an upper bound on code si
**Domain**: Novelty
**Mathematical framing**: Cycle 26dedf74 (Q=0.424) proved 1369 theorems in Applications but left 5 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle 4cb3cf07 (Q=0.421) proved 1108 theorems in Novelty but left 1 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: The
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/Advanced.lean
import Mathlib
import Algebra.BerggrenLorentz.Core

/-!
# Berggren-Lorentz Monoid: Advanced Structure Theory

This file extends the core Berggren-Lorentz theory with:

1. **Iterated B-branch growth**: exponential hypotenuse growth along the B-orbit
2. **Parametric Pythagorean families**: Euclid's parametrization and its connection
3. **Abstract quadratic form preservation**: monoid closure theorem
4. **Trace algebra**: product traces and spectral invariants
5. **Twin-leg triples**: the consecutive-integer subfamily
6. **Entrywise norm bounds**: elementary Lipschitz estimates

## Bridge: Algebra (monoid theory) ↔ Number Theory (Pythagorean triples, GCD)
↔ Dynamics (iterated maps) ↔ Cryptography (search space bounds)
↔ ML (lipschitz_certified_robustness via entrywise bounds)
-/

set_option maxHeartbeats 1600000

namespace BerggrenLorentz

/-! ## Section 1: Iterated B-Branch Growth -/

/-- The n-th iterated B-child starting from (3,4,5).
    This traces the B-branch of the Berggren tree. -/
def iterateB : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => childB (iterateB n).1 (iterateB n).2.1 (iterateB n).2.2

/-- The first iterated B-child of (3,4,5) is (21,20,29). -/
theorem iterateB_one : iterateB 1 = (21, 20, 29) := by
  simp only [iterateB, childB]; norm_num

/-- The second iterated B-child is (119,120,169). -/
theorem iterateB_two : iterateB 2 = (119, 120, 169) := by
  simp only [iterateB, childB]; norm_num

/-- The third iterated B-child is (697,696,985). -/
theorem iterateB_three : iterateB 3 = (697, 696, 985) := by
  simp only [iterateB, childB]; norm_num

/-- Each iterated B-child is Pythagorean.
    Proof by induction using childB_preserves_pythag.
    Bridge: dynamics (orbit closure) ↔ Diophantine invariants. -/
theorem iterateB_pythag : ∀ n, IsPythag (iterateB n).1 (iterateB n).2.1 (iterateB n).2.2 := by
  intro n; induction n with
  | zero => exact seed_is_pythag
  | succ n ih => exact childB_preserves_pythag _ _ _ ih

/-- Each iterated B-child preserves the Lorentz form at zero. -/
theorem iterateB_on_light_cone :
    ∀ n, lorentzQ (iterateB n).1 (iterateB n).2.1 (iterateB n).2.2 = 0 := by
  intro n; rw [lorentzQ_zero_iff_pythag]; exact iterateB_pythag n

/-! ## Section 2: Hypotenuse Sequence Analysis -/

/-- The hypotenuse of the n-th B-iterate. -/
def bHypotenuse (n : ℕ) : ℤ := (iterateB n).2.2

/-- The hypotenuse sequence starts at 5. -/
theorem bHyp_zero : bHypotenuse 0 = 5 := by rfl

/-- The hypotenuse sequence at step 1 is 29. -/
theorem bHyp_one : bHypotenuse 1 = 29 := by
  unfold bHypotenuse; rw [iterateB_one]

/-- The hypotenuse sequence at step 2 is 169 = 13². -/
theorem bHyp_two : bHypotenuse 2 = 169 := by
  unfold bHypotenuse; rw [iterateB_two]

/-- The hypotenuse sequence at step 3 is 985. -/
theorem bHyp_three : bHypotenuse 3 = 985 := by
  unfold bHypotenuse; rw [iterateB_three]

/-- The hypotenuse grows by a factor > 5 at each B-step.
    Bridge: spectral theory ↔ post_quantum_security key size estimation.
    Impact: Ω(5^depth) growth means O(log c / log 5) depth. -/
theorem bHyp_ratio_lower_01 : 5 * bHypotenuse 0 < bHypotenuse 1 := by
  rw [bHyp_zero, bHyp_one]; norm_num

theorem bHyp_ratio_lower_12 : 5 * bHypotenuse 1 < bHypotenuse 2 := by
  rw [bHyp_one, bHyp_two]; norm_num

theorem bHyp_ratio_lower_23 : 5 * bHypotenuse 2 < bHypotenuse 3 := by
  rw [bHyp_two, bHyp_three]; norm_num

/-! ## Section 3: The Parametric Pythagorean Family -/

/-- The parametric family (m²-n², 2mn, m²+n²) for Pythagorean triples.
    Bridge: classical number theory ↔ Berggren tree traversal. -/
def parametricTriple (m n : ℤ) : ℤ × ℤ × ℤ := (m^2 - n^2, 2*m*n, m^2 + n^2)

/-- The parametric family always produces Pythagorean triples (Euclid).
    Bridge: ancient mathematics ↔ modern algebraic structure. -/
theorem parametricTriple_pythag (m n : ℤ) :
    IsPythag (parametricTriple m n).1 (parametricTriple m n).2.1
             (parametricTriple m n).2.2 := by
  unfold IsPythag parametricTriple; ring

/-- (3,4,5) arises from (m,n) = (2,1). -/
theorem parametric_seed : parametricTriple 2 1 = (3, 4, 5) := by
  unfold parametricTriple; norm_num

/-- (5,12,13) arises from (m,n) = (3,2). -/
theorem parametric_5_12_13 : parametricTriple 3 2 = (5, 12, 13) := by
  unfold parametricTriple; norm_num

/-- (15,8,17) arises from (m,n) = (4,1). -/
theorem parametric_15_8_17 : parametricTriple 4 1 = (15, 8, 17) := by
  unfold parametricTriple; norm_num

/-- The parametric family always lies on the light cone. -/
theorem parametric_on_light_cone (m n : ℤ) :
    lorentzQ (parametricTriple m n).1 (parametricTriple m n).2.1
             (parametricTriple m n).2.2 = 0 := by
  unfold lorentzQ parametricTriple; ring

/-! ## Section 4: Abstract Quadratic Form Preservation -/

/-- A matrix preserves a quadratic form Q iff MᵀQM = Q. -/
def preservesForm (M Q : Matrix (Fin 3) (Fin 3) ℤ) : Prop :=
  M.transpose * Q * M = Q

/-- If M₁ and M₂ both preserve Q, so does M₁ * M₂.
    This is the submonoid closure theorem.
    Bridge: abstract algebra ↔ certified_robustness (composition of Lipschitz maps). -/
theorem preservesForm_mul (M₁ M₂ Q : Matrix (Fin 3) (Fin 3) ℤ)
    (h₁ : preservesForm M₁ Q) (h₂ : preservesForm M₂ Q) :
    preservesForm (M₁ * M₂) Q := by
  unfold preservesForm at *
  have : (M₁ * M₂).transpose * Q * (M₁ * M₂) =
    M₂.transpose * (M₁.transpose * Q * M₁) * M₂ := by
    simp [Matrix.transpose_mul, Matrix.mul_assoc]
  rw [this, h₁, h₂]

/-- The identity preserves any quadratic form. -/
theorem preservesForm_one (Q : Matrix (Fin 3) (Fin 3) ℤ) :
    preservesForm 1 Q := by
  unfold preservesForm; simp

/-- Each generator preserves the Lorentz form (rephrased abstractly). -/
theorem matA_preserves_abstract : preservesForm matA metricQ :=
  matA_preserves_lorentz
theorem matB_preserves_abstract : preservesForm matB metricQ :=
  matB_preserves_lorentz
theorem matC_preserves_abstract : preservesForm matC metricQ :=
  matC_preserves_lorentz

/-! ## Section 5: Trace Algebra -/

/-- Trace of product AB = 17. The trace of products encodes
    the "angles" between generators in O(2,1;ℤ).
    Bridge: spectral invariants ↔ quantum observable basis-independence. -/
theorem trace_matAB : (matA * matB).trace = 17 := by native_decide

/-- Trace of product AC = 15. -/
theorem trace_matAC : (matA * matC).trace = 15 := by native_decide

/-- Trace of product BC = 17. Note: Tr(AB) = Tr(BC) = 17.
    This reflects the "A ↔ C symmetry" of the Berggren tree. -/
theorem trace_matBC : (matB * matC).trace = 17 := by native_decide

/-- Trace(AB) = Trace(BA) (conjugation invariance, verified concretely). -/
theorem trace_AB_eq_BA : (matA * matB).trace = (matB * matA).trace := by native_decide
theorem trace_AC_eq_CA : (matA * matC).trace = (matC * matA).trace := by native_decide
theorem trace_BC_eq_CB : (matB * matC).trace = (matC * matB).trace := by native_decide

/-- The trace of AB equals the trace of BC — an unexpected symmetry.
    This reflects the involutive relationship between the A and C generators.
    Bridge: spectral symmetry ↔ hidden conservation law. -/
theorem trace_AB_eq_BC : (matA * matB).trace = (matB * matC).trace := by native_decide

/-! ## Section 6: Special Pythagorean Triple Families -/

/-- The "twin leg" family: triples where |a - b| = 1.
    Examples: (3,4,5), (20,21,29), (119,120,169), (696,697,985).
    These arise from the B-branch of the Berggren tree.
    Bridge: number theory (consecutive integers) ↔ dynamics (B-orbit). -/
def isTwinLeg (a b c : ℤ) : Prop := IsPythag a b c ∧ (a - b = 1 ∨ b - a = 1)

/-- (3,4,5) is a twin-leg triple. -/
theorem seed_twin_leg : isTwinLeg 3 4 5 := by
  exact ⟨seed_is_pythag, Or.inr (by norm_num)⟩

/-- (20,21,29) is a twin-leg triple. -/
theorem twin_20_21_29 : isTwinLeg 20 21 29 := by
  exact ⟨by unfold IsPythag; norm_num, Or.inr (by norm_num)⟩

/-- (119,120,169) is a twin-leg triple. -/
theorem twin_119_120_169 : isTwinLeg 119 120 169 := by
  exact ⟨by unfold IsPythag; norm_num, Or.in
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Sphere-Packing Bound and Beyond

The file `Tropical/SpherePackingBound.lean` establishes the classical Hamming
(sphere-packing) bound over an arbitrary finite additive-group alphabet `G`
indexed by a finite type `ι`: for any code `C ⊆ (ι → G)` of minimum Hamming
distance at least `2t + 1`,

    |C| · V(t) ≤ qⁿ,   with   V(t) = ∑_{i=0}^{t} C(n, i) (q − 1)ⁱ,

where `q = |G|`, `n = |ι|`, and `V(t)` is the exact volume of a radius-`t`
Hamming ball, which we also compute in closed form (`hammingBall_card_formula`).
This complements the *compression* side of coding theory already present in the
catalog (`QarySourceCoding.lean`: q-ary entropy, the Kraft inequality, and the
Shannon source-coding bounds) with the *error-correction* side. Both rest on the
same volume/counting principle over q-ary alphabets, so several natural research
directions open up from the shared counting infrastructure.

## Direction 1 — Perfect codes and the equality case

The packing bound is tight precisely for *perfect codes*, where the radius-`t`
balls about the codewords tile the whole space. A formal characterization
`|C| · V(t) = qⁿ ↔ (the balls cover everything)` would let us certify
the Hamming, Golay, and repetition codes as perfect, and would connect to the
disjointness lemma `hammingBall_pairwise_disjoint` we already proved.
**The key insight is** that equality in the sphere-packing bound is equivalent to
the disjoint codeword balls forming a *partition* of `(ι → G)`, i.e. the
biUnion used in `sphere_packing_bound` equalling `Finset.univ`, which converts a
metric statement into a pure cardinality identity. **Why now?** The volume
formula and the disjoint-biUnion machinery are already in place, so the
equality case is a direct strengthening rather than new theory, and it gives a
falsifiable test: any code meeting the bound must cover the space exactly.

## Direction 2 — The Singleton bound and a unified comparison

Alongside the packing bound sits the Singleton bound `|C| ≤ q^{n−d+1}` for
minimum distance `d`. Formalizing it (codewords are distinguished by any
`n − d + 1` coordinates, so the projection to those coordinates is injective)
and then proving, in the same file, when each bound dominates the other would
give a comparative theory of code-size bounds.
**The key insight is** that the Singleton bound is a *projection/injectivity*
statement while the packing bound is a *volume/disjointness* statement, and the
two can be uniformly phrased through the Hamming metric on `(ι → G)` we already
use. **Why now?** Our codewords are already plain functions `ι → G`, so the
coordinate-projection argument is immediate with `Finset.card_le_card_of_injOn`,
and a head-to-head comparison with the proven packing bound is a falsifiable,
self-contained next step.

## Direction 3 — The Gilbert–Varshamov existence counterpart

The packing bound is an *upper* bound on code size; the Gilbert–Varshamov bound
is a matching *lower* bound: a code of minimum distance `
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
