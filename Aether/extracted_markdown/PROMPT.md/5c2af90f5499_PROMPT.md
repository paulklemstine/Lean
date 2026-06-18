
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

**Title**: Proof Complexity Collapse: P=NP via Proof Checking
**Domain**: Logic
**Mathematical framing**: The key insight is that proof checking is fundamentally different from proof search. Conjecture: There exists a proof system in which every true quantifier-free formula has a proof of polynomial size, and this proof can be verified in polynomial time. The barrier has been that existing proof systems (Frege, Extended Frege) have exponential lower bounds for specific formulas. But what if we construct a NEW proof system based on EML computations? Define EML-Frege where each proof step is an EML identity (exp-log composition) verified by numeric evaluation. Since EML identities can be checked in O(1) field operations, and every boolean circuit can be simulated by an EML network of depth O(log n), we get a quasi-polynomial proof system. Why now: recent breakthroughs in circuit lower bounds (Williams 2014, 2023) and the EML single-operator universality result suggest that EML-Frege could break the natural proofs barrier. Test: prove that EML-Frege polynomially simulates Extended Frege for CNF formulas, and show it has no exponential lower bounds under the EML independence assumption. Impact: if EML-Frege has short proofs for all tautologies, then NP = coNP in this proof system, which would be the most significant result in proof complexity since Cook's theorem.
Research domain: Logic
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Physics/V12_VariationalPrinciples.lean
import Mathlib

/-! # CatalogBuild.Speculative.OISCC.V12_VariationalPrinciples

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 15
-/

noncomputable section

/-- The EML potential. -/
def f_var (x : ℝ) : ℝ := Real.exp x - Real.log x - 1

/-- The Riemannian metric. -/
def g_var (x : ℝ) : ℝ := Real.exp x + x⁻¹ ^ 2

/-- The "kinetic energy" in the EML metric. -/
def kinetic (x v : ℝ) : ℝ := g_var x * v ^ 2 / 2

/-- The EML Lagrangian. -/
def lagrangian (x v : ℝ) : ℝ := kinetic x v - f_var x

/-- [Section: # CatalogBuild.Speculative.OISCC.V12_VariationalPrinciples
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 15] -/
theorem f_var_ge_one (x : ℝ) (hx : 0 < x) : f_var x ≥ 1 := by
  unfold f_var;
  nlinarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx ]

theorem f_var_pos (x : ℝ) (hx : 0 < x) : f_var x > 0 := by
  have := f_var_ge_one x hx
  linarith

theorem g_var_pos (x : ℝ) (hx : 0 < x) : g_var x > 0 := by
  exact add_pos_of_pos_of_nonneg ( Real.exp_pos _ ) ( sq_nonneg _ )

theorem kinetic_nonneg (x v : ℝ) (hx : 0 < x) : kinetic x v ≥ 0 := by
  exact div_nonneg ( mul_nonneg ( le_of_lt ( g_var_pos x hx ) ) ( sq_nonneg v ) ) zero_le_two

theorem kinetic_eq_zero_iff (x v : ℝ) (hx : 0 < x) :
    kinetic x v = 0 ↔ v = 0 := by
  unfold kinetic;
  norm_num [ g_var ];
  exact fun h => absurd h <| by positivity;

theorem lagrangian_at_rest (x : ℝ) (hx : 0 < x) :
    lagrangian x 0 = -f_var x := by
  unfold lagrangian kinetic f_var g_var; ring;

theorem lagrangian_at_rest_neg (x : ℝ) (hx : 0 < x) :
    lagrangian x 0 < 0 := by
  linarith [ lagrangian_at_rest x hx, f_var_pos x hx ]

/-- The "total energy" E = K + f is always ≥ 1 (positive energy theorem). -/
def total_energy (x v : ℝ) : ℝ := kinetic x v + f_var x

theorem total_energy_ge_one (x v : ℝ) (hx : 0 < x) :
    total_energy x v ≥ 1 := by
  exact le_add_of_nonneg_of_le ( kinetic_nonneg x v hx ) ( f_var_ge_one x hx )

theorem f_var_convexOn : ConvexOn ℝ (Ioi 0) f_var := by
  apply_rules [ convexOn_of_deriv2_nonneg, convex_Ioi ];
  · exact continuousOn_of_forall_continuousAt fun x hx => by exact ContinuousAt.sub ( ContinuousAt.sub ( Real.continuous_exp.continuousAt ) ( Real.continuousAt_log hx.out.ne' ) ) continuousAt_const;
  · exact DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.log differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx ) |> DifferentiableOn.sub <| differentiableOn_const _;
  · -- The first derivative of $f(x)$ is $f'(x) = e^x - \frac{1}{x}$.
    have h_deriv : ∀ x ∈ Set.Ioi 0, deriv f_var x = Real.exp x - 1 / x := by
      intro x hx; unfold f_var; norm_num [ Real.differentiableAt_exp, hx.out.ne' ] ;
    exact DifferentiableOn.congr ( by exact DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.div ( differentiableOn_const _ ) differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx ) ) fun x hx => h_deriv x <| interior_subset hx;
  · have h_deriv2 : ∀ x > 0, deriv^[2] (fun x => Real.exp x - Real.log x - 1) x = Real.exp x + 1 / x^2 := by
      have h_deriv2 : ∀ x > 0, deriv^[2] (fun x => Real.exp x - Real.log x - 1) x = deriv (fun x => Real.exp x - 1 / x) x := by
        exact fun x x_pos => Filter.EventuallyEq.deriv_eq ( by filter_upwards [ lt_mem_nhds x_pos ] with y hy using by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hy.ne' ] );
      intro x hx; rw [ h_deriv2 x hx ] ; norm_num [ Real.differentiableAt_exp, differentiableAt_inv, hx.ne' ];
    exact fun x hx => h_deriv2 x ( interior_subset hx ) ▸ add_nonneg ( Real.exp_nonneg x ) ( one_div_nonneg.mpr ( sq_nonneg x ) )

theorem f_var_orbit_growth (x : ℝ) (hx : 0 < x) :
    f_var (Real.exp x - Real.log x) > f_var x := by
  unfold f_var;
  -- Let $y = \exp(x) - \log(x)$.
  set y : ℝ := Real.exp x - Real.log x;
  -- Since $y > x$, we have $y > 1$.
  have hy_gt_one : 1 < y := by
    linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx ];
  have := Real.add_one_le_exp ( y - 1 );
  norm_num [ Real.exp_sub ] at *;
  rw [ le_div_iff₀ ( Real.exp_pos _ ) ] at this;
  nlinarith [ Real.add_one_le_exp 1, Real.log_le_sub_one_of_pos ( by linarith : 0 < y ) ]

end


-- NEW_FILE: Catalog/Pythagorean/BoundedBetaDefs.lean
/-
# Bounded Beta-Reduction Semantics: Definitions

Defines core structures for extracting finite transition systems from lambda
calculus terms under bounded β-reduction.
-/

import Mathlib

/-- Lambda calculus terms with named variables. -/
inductive Lam : Type where
  | var : Nat → Lam
  | app : Lam → Lam → Lam
  | lam : Nat → Lam → Lam
  deriving DecidableEq, Repr

namespace Lam

/-- The size of a lambda term (number of constructors). -/
def size : Lam → Nat
  | var _ => 1
  | app t u => 1 + t.size + u.size
  | lam _ t => 1 + t.size

/-- Substitution of term `s` for variable `x` in term `t`. -/
def subst (t : Lam) (x : Nat) (s : Lam) : Lam :=
  match t with
  | var n => if n = x then s else var n
  | app t₁ t₂ => app (t₁.subst x s) (t₂.subst x s)
  | lam y body =>
    if y = x then lam y body
    else lam y (body.subst x s)

end Lam

/-- One-step β-reduction. -/
inductive BetaStep : Lam → Lam → Prop where
  | beta (x : Nat) (body arg : Lam) :
      BetaStep (.app (.lam x body) arg) (body.subst x arg)
  | appLeft {t t' : Lam} (u : Lam) (h : BetaStep t t') :
      BetaStep (.app t u) (.app t' u)
  | appRight (t : Lam) {u u' : Lam} (h : BetaStep u u') :
      BetaStep (.app t u) (.app t u')
  | lamBody (x : Nat) {t t' : Lam} (h : BetaStep t t') :
      BetaStep (.lam x t) (.lam x t')

/-- β-equivalence: the equivalence closure of BetaStep. -/
inductive BetaEq : Lam → Lam → Prop where
  | refl (t : Lam) : BetaEq t t
  | step {t u : Lam} (h : BetaStep t u) : BetaEq t u
  | symm {t u : Lam} (h : BetaEq t u) : BetaEq u t
  | trans {t u v : Lam} (h₁ : BetaEq t u) (h₂ : BetaEq u v) : BetaEq t v

/-- Bounded reachability: `u` is reachable from `t` within `d` β-steps. -/
inductive ReachableWithin : Nat → Lam → Lam → Prop where
  | refl (d : Nat) (t : Lam) : ReachableWithin d t t
  | step {d : Nat} {t v u : Lam}
      (h₁ : ReachableWithin d t v) (h₂ : BetaStep v u) :
      ReachableWithin (d + 1) t u

/-- If `u` is reachable from `t` within 0 steps, then `u = t`. -/
theorem reachableWithin_zero_iff {t u : Lam} :
    ReachableWithin 0 t u ↔ u = t := by
  constructor
  · intro h; cases h with | refl => rfl
  · rintro rfl; exact ReachableWithin.refl 0 _

/-
ReachableWithin is monotone in the depth bound.
-/
theorem ReachableWithin.mono {d₁ d₂ : Nat} {t u : Lam}
    (h : ReachableWithin d₁ t u) (hle : d₁ ≤ d₂) :
    ReachableWithin d₂ t u := by
  induction' hle with d₂ hle ih;
  · assumption;
  · -- If $u$ is reachable from $t$ within $d₂$ steps, then $u$ is also reachable from $t$ within $d₂+1$ steps by adding one more step.
    have h_step : ∀ {d : ℕ} {t u : Lam}, ReachableWithin d t u → ReachableWithin (d + 1) t u := by
      intros d t u h; exact (by
      induction' h with d t u h ih;
      · exact ReachableWithin.refl _ _;
      · exact ReachableWithin.step ‹_› ‹_›);
    exact h_step ih

/-
Reachable terms are β-equivalent to the source.
-/
theorem reachableWithin_betaEq {d : Nat} {t u : Lam}
    (h : ReachableWithin d t u) : BetaEq t u := by
  induction' h with d' t' u' h₁ h₂ h₃;
  · constructor;
  · exact BetaEq.trans ‹_› ( BetaEq.step ‹_› )

/-- The bounded reduct system of term `t` at depth `d`:
    the subtype of terms reachable within d steps. -/
def BoundedReductSystem (d : Nat) (t : Lam) : Type :=
  {u : Lam // ReachableWithin d t u}

/-- The state set of a bounded reduct system. -/
def boundedStateSet (d : Nat) (t : Lam) : Set Lam :=
  {u | ReachableWithin d t u}

/-- A Finite Transition System with a distinguished initial state. -/
structure FTS where
  State : Type
  init : State
  step : State → State → Prop

/-- Extract an FTS from a lambda term at bounded depth. -/
non
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Proof System Collapse Theory

## 1. Polynomial Simulation and the Cook–Reckhow Program

The abstract simulation preorder formalized in `ProofSystemCollapse.lean` captures the *qualitative* structure of proof complexity. The next step is to enrich simulation with *quantitative* bounds — polynomial-time proof translation and polynomial proof-size blowup. The key insight is that our lattice structure (union = join, intersection = meet) should lift to the polynomial setting: the union of two p-bounded systems should be p-bounded, and the meet should have proof size bounded by the sum of the components. Why now? Lean 4's `Complexity` namespace and recent formalizations of polynomial-time functions in Mathlib provide the computational backbone needed to state polynomial simulation precisely. The testable conjecture: *the indexed union of finitely many p-bounded proof systems is p-bounded*, formalized as a theorem about `ProofSys.iUnion` restricted to systems whose proof sizes are polynomially related to formula size.

## 2. Concrete Proof Systems: Resolution and Frege

The abstract framework should be instantiated with concrete proof systems to yield non-trivial lower and upper bounds. Define a `ResolutionSystem` over CNF formulas (clauses as `Finset (Fin n × Bool)`) and a `FregeSystem` with substitution and modus ponens rules. The key insight is that the singleton system construction in our duality theorem (`singletonSys`) can be generalized to *interpolation systems*, where the proof of a formula encodes a Craig interpolant. The testable conjecture: *Resolution does not simulate Frege*, witnessed by the formalized pigeonhole principle — PHP formulas have polynomial Frege proofs but require exponential resolution proofs (Ben-Sasson and Wigderson 1999). This would be the first formalized proof complexity separation in Lean.

## 3. Proof System Morphisms as a Category

The `ProofSysMorphism` structure (explicit proof translations preserving verification) forms a category whose objects are proof systems and whose morphisms are proof translations. The key insight is that functorial properties of this category encode proof-theoretic phenomena: natural transformations between morphisms correspond to proof transformation strategies, and adjunctions capture optimal simulation relationships. Why now? Mathlib's category theory library is mature enough to express this directly. The testable conjecture: *the category of proof systems with morphisms has all small limits and colimits*, which would give a clean categorical account of why arbitrary meets and joins of proof systems exist.

## 4. EML-Based Proof Systems and Circuit Depth

The `EMLExpr` syntax already formalized in this project provides a concrete basis for defining proof systems where proof steps are verified by evaluating EML (exp-log) expressions. The key insight is that if EML expressions of depth $d$ can represent all Boolean circuits of depth $O(d)$, then an EML-Frege system c
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
