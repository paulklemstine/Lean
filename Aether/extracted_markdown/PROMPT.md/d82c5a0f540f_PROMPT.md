
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
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Close Proofs: Dream Logic: Non-Monotone Reasoning Where Contradictions Coexist
**Domain**: Novelty
**Mathematical framing**: Cycle 362ed1b3 (Q=0.460) proved 1404 theorems in Bridges but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Formalize a logic where contradictions do not explode and beliefs can be retracted. Prove that paraconsistent logics can model dream-like reasoning where impossible objects coexist. Show that such log
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/ArrowDepthComplexity.lean
import Pythagorean.STLCDefs
import Bridges.Catalog.Pythagorean.BisimMinimization
import Mathlib

/-!
# Arrow-Depth Exponential Complexity for Simple Types

This file establishes a structural complexity theory for simple types, proving that
**arrow depth alone cannot control semantic state complexity** (`typeStateBound`),
but that **type size** provides a clean exponential bound.

## Main Results

1. `typeStateBound` equals `Ty.complexity` — they share the same recurrence.
2. For **chain types** (right-spined with base-type arguments), `typeStateBound`
   is singly exponential in depth: `typeStateBound A ≤ 3^(depth A + 1)`.
3. For **bushy types** (balanced binary arrow trees), `typeStateBound` grows
   doubly exponentially: `typeStateBound (bushy n) + 1 ≥ 2^(2^n)`.
4. **Impossibility theorem**: no constant `c` can uniformly bound
   `typeStateBound A` by `c^(depth A + 1)`.
5. **Size-exponential bound**: `typeStateBound A + 1 ≤ 2^(Ty.size A)` always holds.

These results identify depth as an *insufficient* invariant and establish size
(equivalently, complexity) as the correct controlling parameter, with depth plus
width jointly characterizing the growth regime.

**Application keywords:** higher-order semantics, bisimulation minimization,
semantic state complexity, arrow depth, structural parameterization,
fixed-parameter tractability, descriptive complexity, automata state explosion,
width-depth tradeoff, semantic compression, type-theoretic complexity
-/

/-! ## New Definitions -/

/-- A **chain type** is a right-spined arrow type where every left argument is `base`.
    Chain types represent simple function pipelines: `base → base → ... → base`.
    They are the types of minimal branching complexity at each depth level. -/
def ChainTy : Ty → Prop
  | .base => True
  | .arrow A B => A = Ty.base ∧ ChainTy B

/-- **Arrow width**: the total number of arrow constructors in a type.
    This measures the "bushiness" or branching complexity of the type tree. -/
def arrowWidth : Ty → ℕ
  | .base => 0
  | .arrow A B => 1 + arrowWidth A + arrowWidth B

/-- **Bushy types**: the canonical family of maximally branching types at each depth.
    `bushy n` is a balanced binary arrow tree of depth `n`. -/
def bushy : ℕ → Ty
  | 0 => Ty.base
  | n + 1 => Ty.arrow (bushy n) (bushy n)

/-- **Depth profile**: counts type nodes at each residual depth level. -/
def depthProfile : Ty → ℕ → ℕ
  | .base, 0 => 1
  | .base, _ + 1 => 0
  | .arrow _ _, 0 => 1
  | .arrow A B, k + 1 => depthProfile A k + depthProfile B k

/-- **Predicted bound**: a certified upper bound on `typeStateBound` computable
    from the type's size. -/
def predictedBound (A : Ty) : ℕ := 2 ^ Ty.size A - 1

/-! ## Theorem 1: typeStateBound equals Ty.complexity -/

/-
`typeStateBound` and `Ty.complexity` satisfy the same recurrence with the
    same base case, hence are identical.
-/
theorem typeStateBound_eq_complexity (A : Ty) : typeStateBound A = Ty.complexity A := by
  induction' A using Ty.recOn with A B hA hB;
  · rfl;
  · rw [ show typeStateBound ( A.arrow B ) = ( typeStateBound A + 1 ) * ( typeStateBound B + 1 ) from rfl, show ( A.arrow B ).complexity = ( A.complexity + 1 ) * ( B.complexity + 1 ) from rfl, hA, hB ]

/-! ## Theorem 2: Depth is bounded by complexity -/

/-
Arrow depth is always bounded by type complexity.
-/
theorem depth_le_complexity (A : Ty) : Ty.depth A ≤ Ty.complexity A := by
  induction' A using Ty.recOn with A B ihA ihB;
  · exact Nat.zero_le _;
  · simp +arith +decide [ Ty.depth, Ty.complexity ] at *;
    constructor <;> nlinarith [ Ty.complexity_pos A, Ty.complexity_pos B ]

/-! ## Theorem 3: Chain type depth bound -/

/-
For chain types, `typeStateBound` is singly exponential in depth:
    `typeStateBound A ≤ 3^(depth A + 1)`.
-/
theorem typeStateBound_le_exp_depth_of_chain :
    ∀ A : Ty, ChainTy A → typeStateBound A ≤ 3 ^ (Ty.depth A + 1) := by
  intro AA;
  induction' AA with AA ih;
  · exact fun _ => by decide;
  · -- By definition of `ChainTy`, if `ChainTy (AA.arrow ih)` holds, then `AA = .base` and `ChainTy ih`.
    intro h_chain
    obtain ⟨rfl, h_chain_ih⟩ := h_chain;
    -- By definition of `typeStateBound`, we have `typeStateBound (.arrow Ty.base ih) = (1 + 1) * (typeStateBound ih + 1)`.
    have h_typeStateBound_arrow : typeStateBound (.arrow Ty.base ih) = 2 * (typeStateBound ih + 1) := by
      exact show ( 1 + 1 ) * ( typeStateBound ih + 1 ) = 2 * ( typeStateBound ih + 1 ) by ring;
    simp_all +decide [ Ty.depth ];
    grind +revert

/-! ## Theorem 4: Bushy type depth -/

/-
The depth of `bushy n` is exactly `n`.
-/
theorem bushy_depth_eq (n : ℕ) : Ty.depth (bushy n) = n := by
  induction' n with n ih;
  · rfl;
  · exact show 1 + Max.max ( bushy n |> Ty.depth ) ( bushy n |> Ty.depth ) = n + 1 from by simp +arith +decide [ ih ] ;

/-! ## Theorem 5: Bushy type recurrence -/

/-
The `typeStateBound` recurrence for bushy types.
-/
theorem bushy_tsb_recurrence (n : ℕ) :
    typeStateBound (bushy (n + 1)) = (typeStateBound (bushy n) + 1) ^ 2 := by
  exact Eq.symm ( by rw [ sq ] ; rfl )

/-! ## Theorem 6: Doubly-exponential lower bound for bushy types -/

/-
`typeStateBound (bushy n) + 1 ≥ 2^(2^n)`: doubly-exponential growth.
-/
theorem bushy_tsb_plus_one_ge (n : ℕ) :
    2 ^ 2 ^ n ≤ typeStateBound (bushy n) + 1 := by
  induction' n with n ih;
  · native_decide +revert;
  · convert Nat.le_succ_of_le ( pow_le_pow_left' ih 2 ) using 1 ; ring;
    exact congr_arg _ ( bushy_tsb_recurrence n )

/-! ## Theorem 7: Impossibility of uniform depth-only bound -/

/-
**Main impossibility theorem**: no constant `c` gives a uniform
    `typeStateBound A ≤ c^(depth A + 1)` bound.
-/
theorem not_exists_uniform_exp_depth_bound :
    ¬ ∃ c : ℕ, ∀ A : Ty, typeStateBound A ≤ c ^ (Ty.depth A + 1) := by
  by_contra h_contra;
  obtain ⟨ c, hc ⟩ := h_contra
  have h_contra_bushy : ∀ n, typeStateBound (bushy n) ≤ c ^ (n + 1) := by
    exact fun n => by simpa [ bushy_depth_eq ] using hc ( bushy n ) ;
  -- But typeStateBound(bushy n) + 1 ≥ 2^(2^n) by bushy_tsb_plus_one_ge.
  have h_contra_bushy_plus_one : ∀ n, 2 ^ (2 ^ n) ≤ c ^ (n + 1) + 1 := by
    exact fun n => le_trans ( bushy_tsb_plus_one_ge n ) ( Nat.succ_le_succ ( h_contra_bushy n ) );
  -- Since $c \leq 2^c$ (by le_two_pow), $c^{n+1} \leq (2^c)^{n+1} = 2^{c(n+1)}$.
  have h_contra_bushy_plus_one_simplified : ∀ n, 2 ^ (2 ^ n) ≤ 2 ^ (c * (n + 1) + 1) := by
    intros n
    have h_contra_bushy_plus_one_simplified_step : c ^ (n + 1) + 1 ≤ 2 * 2 ^ (c * (n + 1)) := by
      rw [ two_mul, pow_mul ];
      gcongr;
      · exact le_of_lt ( Nat.recOn c ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; linarith [ Nat.one_le_pow n 2 zero_lt_two ] );
      · exact Nat.one_le_pow _ _ ( by norm_num );
    exact le_trans ( h_contra_bushy_plus_one n ) ( h_contra_bushy_plus_one_simplified_step.trans_eq ( by ring ) );
  -- So $2^n \leq c(n+1) + 1 < c(n+1) + n + 1 = (c+1)(n+1)$.
  have h_contra_bushy_plus_one_final : ∀ n, 2 ^ n ≤ (c + 1) * (n + 1) := by
    intro n; specialize h_contra_bushy_plus_one_simplified n; rw [ pow_le_pow_iff_right₀ ] at h_contra_bushy_plus_one_simplified <;> nlinarith;
  exact absurd ( h_contra_bushy_plus_one_final ( 2 * ( c + 1 ) ) ) ( by { exact Nat.recOn c ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ', Nat.pow_mul ] at * ; nlinarith } )

/-! ## Theorem 8: Size-exponential upper bound -/

/-
`typeStateBound A + 1 ≤ 2^(Ty.size A)` for all types.
-/
theorem typeStateBound_add_one_le_two_pow_size (A : Ty) :
    typeStateBound A + 1 ≤ 2 ^ Ty.size A := by
  induction' A with A B ihA ihB;
  · exact Nat.le_refl 2;
  · convert Nat.succ_le_of_lt ( lt_of_le_of_lt ( Nat.mul_le_mul ihA ihB ) _ ) using 1;
    rw [ ← pow_add ] ; exact pow_lt_pow_right₀ ( by decide ) ( by simp +arith +decide [ Ty.size ] ) ;

/-
Certified upper bound: `typeStateBound A ≤ predictedBound A`.
-/
theorem typeStateBound_le_predictedBound (A : Ty) :
    typeStateBound A ≤ predictedBound A := by
  -- A
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# FUTURE_DIRECTIONS — Dream Logic: Paraconsistent Reasoning over Belnap's FOUR₂

## Synthesis

This cycle lifted the *algebraic* paraconsistency of the catalog file
`Logic.BelnapBilattice` (which proves `Belnap.explosion_fails` and
`Belnap.bneg_not_complement` as facts about a four-valued distributive bilattice)
to a *proof-theoretic* layer: a propositional language `Form`, a four-valued
semantics `eval`, and a multiple-premise consequence relation `DreamEntails`. The
new file `Catalog/Logic/DreamLogic.lean` proves eight theorems with zero `sorry`
and only the `propext` axiom. The headline results are that **ex contradictione
quodlibet fails** (`dream_non_explosion`) and that **disjunctive syllogism fails**
(`dream_disj_syllogism_fails`) — the two inferences whose collapse is the signature
of First-Degree Entailment — while the lattice rules ∧-elimination and
∨-introduction survive intact (`dream_conj_elim_valid`, `dream_disj_intro_valid`).

The structural insight that emerged is that **paraconsistency and non-monotonicity
are independent phenomena**. We proved `dream_entails_monotone`: the Tarskian
relation `DreamEntails` is fully monotone even though it is paraconsistent. This
sharpens the catalog's `consistent_consequence_nonmonotone`, which obtains
non-monotonicity only by *restricting to consistent (gap/glut-free) models*. So the
"belief retraction" half of the research brief does not live in the base
consequence relation at all; it must be sought in a *preferential* refinement.

The other decisive result is the *localisation* of paraconsistency. The classical
bridge `dream_classical_bridge` shows that on two-valued valuations dream-designation
coincides exactly with Boolean truth, and `dream_classical_explosion` shows explosion
*returns* there (vacuously: no two-valued world designates both `p` and `¬p`). Taken
with `dream_non_explosion`, this proves the glut value `B` is the *sole* algebraic
source of paraconsistency. What was deferred this cycle: the priority targets
`CarmichaelComposite` / `Fib_gcd_identity` remain blocked because their Lean
infrastructure references a missing module (`Shared.CarmichaelHelper`) and an
undefined `fib_primitive_divisor_prime`, and the one genuine `sorry`
(`fib_carmichael_composite`, composite `n > 10000`) is the full infinite-tail
Carmichael primitive-divisor theorem — a Zsygmondy-class result needing cyclotomic
machinery far beyond a single cycle. We deliberately invested compute in the
self-contained, fully-closeable dream-logic theory instead.

## Results Summary

- `dream_non_explosion`: **proved** — `p, ¬p ⊬ q`; ex falso quodlibet fails as an inference (inference-level form of catalog `Belnap.explosion_fails`).
- `dream_disj_syllogism_fails`: **proved** — `¬p, p∨q ⊬ q`; disjunctive syllogism fails, the defining invalidity of FDE.
- `dream_conj_elim_valid`: **proved** — ∧-elimination `φ∧ψ ⊢ φ` survives paraconsistency.
- `dream_disj_intro_valid`: **proved** — ∨-introduction `φ ⊢ φ∨ψ` survives paraconsi
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
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
