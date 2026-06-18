
## PHASE A: LEAN 4 ONLY — DOING THE MATH

You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

### DELIVERABLES (strict — only this):
1. **lean files (count chosen by the Plan)**
2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
   conjectures as a freeform narrative (NOT a form). Each direction MUST
   include a "The key insight is..." sentence and a "Why now?" justification.
   This file drives the next research cycle — make it count.

### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
- NO `ARTICLE.md`
- NO `RESEARCH_PAPER.md`
- NO `demo.py` / `algorithms.py`
- NO HTML widgets
- NO `PACKAGE.json`
- NO prose for human readers (except FUTURE_DIRECTIONS.md)

### WHY THIS NARROW:
The Lean 4 file IS the deliverable. A self-contained Lean file with
3-5 world-class theorems is worth more than 30K characters of prose
about trivial results. Focus 100% of your compute on the math.
If your work is genuinely world-class, the packaging step is dispatched
automatically and cheaply.


## Concept

**Title**: Berggren Tree Ising Model: Exact Phase Transition via Spectral Radius
**Domain**: Physics
**Mathematical framing**: Define the Berggren tree B = (V, E) where V = {primitive Pythagorean triples} and E connects each triple to its 3 children via Berggren matrices. Define the Ising Hamiltonian H(σ) = -J Σ_{(i,j)∈E} σ_i σ_j for σ ∈ {+1, -1}^V. Prove: (1) The partition function Z_n(β) at depth n satisfies Z_n = 2cosh(β)·[Z_{n-1}]³ - 2sinh(β)·[Z̃_{n-1}]³ where Z̃ involves the constrained partition function with a fixed boundary spin. (2) The critical inverse temperature β_c = arctanh(1/3), proved by analyzing the magnetization recursion m_{n+1} = tanh(β + β·3·arctanh(m_n)) and showing m_n → 0 for β < β_c while m_n → m* > 0 for β > β_c. (3) For β < β_c, spin-spin correlations decay exponentially: ⟨σ_i σ_j⟩ ≤ C·exp(-d(i,j)/ξ(β)) where ξ(β) = 1/|ln(tanh(β)·3)| is the correlation length. The branching number 3 of the Berggren tree directly determines both the critical temperature and the correlation length.
**Concept description**: The key insight is that the Berggren tree (generating all primitive Pythagorean triples via matrices A, B, C) is a rooted tree with branching number 3, and the Ising model on such a tree has an exactly solvable phase transition at β_c = arctanh(1/3). The recursive structure of the Berggren tree allows the partition function to be computed in closed form, and the critical temperature follows from the branching ratio. This bridges statistical mechanics (Ising phase transitions), number theory (Berggren tree of Pythagorean triples), and computation (phase transitions as complexity thresholds). Why now: the IsingPartitionStability file already has Ising model foundations with 2 open sorries, the Berggren tree is well-established in FINAL/Geometry/BerggrenRamanujan.lean, and the Physics domain is under-explored (0 sorries, 4256 declarations). Proving that the Berggren tree's branching structure determines the Ising critical point creates the first rigorous bridge between Pythagorean number theory and statistical physics.
**Novelty estimate**: 0.72
**Breakthrough potential**: 0.68
Research domain: Physics
Research mode: prove


### Lean 4 Sketch
theorem berggren_ising_critical_temp : ∀ β : ℝ, β > arctanh (1/3) → ∃ m > 0, isBerggrenSpontaneousMagnetization β m ∧ ∀ β' < arctanh (1/3), berggrenCorrelationDecay β'


### Catalog Context
@FINAL/Geometry/BerggrenRamanujan.lean
```lean
import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenRamanujan

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 59
-/

noncomputable section

/-- A direction in the ternary Berggren tree. -/
inductive BDir where
  | left  : BDir   -- B₁ branch
  | mid   : BDir   -- B₂ branch
  | right : BDir   -- B₃ branch
  deriving DecidableEq, Repr, Inhabited

/-- A position in the Berggren tree is a finite word over {left, mid, right}. -/
abbrev BPos := List BDir

/-- Apply a single Berggren step. -/
def berggrenStep (d : BDir) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  let (a, b, c) := t
  match d with
  | .left  => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .mid   => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .right => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The Pythagorean triple at a given position (path applied left-to-right from root). -/
def berggrenAt (path : BPos) : ℤ × ℤ × ℤ :=
  path.foldl (fun t d => berggrenStep d t) (3, 4, 5)

/-- Each Berggren step preserves the Pythagorean equation. -/
theorem berggrenStep_preserves_pyth (d : BDir) (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let (a', b', c') := berggrenStep d (a, b, c)
    a' ^ 2 + b' ^ 2 = c' ^ 2 := by
  cases d <;> simp [berggrenStep] <;> nlinarith [sq_nonneg (a - b), sq_nonneg (a + b)]

/-- Every position in the Berggren tree yields a Pythagorean triple. -/
theorem berggrenAt_pyth (path : BPos) :
    let (a, b, c) := berggrenAt path
    a ^ 2 + b ^ 2 = c ^ 2 := by
  simp only [berggrenAt]
  suffices h : ∀ (t : ℤ × ℤ × ℤ), t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 →
    let r := path.foldl (fun t d => berggrenStep d t) t
    r.1 ^ 2 + r.2.1 ^ 2 = r.2.2 ^ 2 from
    h (3, 4, 5) (by norm_num)
  intro t ht
  induction path generalizing t with
  | nil => exact ht
  | cons d ds ih =>
    simp only [List.foldl]
    apply ih
    exact berggrenStep_preserves_pyth d t.1 t.2.1 t.2.2 ht

/-- Berggren matrix B₁. -/
def berggrenB₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]
-- ... (truncated, full file has 316 lines)
```

@FINAL/Geometry/RamanujanFrontiers.lean
```lean
import Mathlib

/-! # CatalogBuild.Pythagorean.ModularForms.RamanujanFrontiers

Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 79
-/

noncomputable section

/-- Berggren matrix B₁. -/
def rfB₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂. -/
def rfB₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃. -/
def rfB₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- The Lorentz form matrix: diag(1, 1, -1). -/
def rfQ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- Reduction of a matrix modulo N. -/
def matMod (N : ℕ) [NeZero N] (M : Matrix (Fin 3) (Fin 3) ℤ) :
    Matrix (Fin 3) (Fin 3) (ZMod N) :=
  M.map (Int.cast)

/-- The Berggren matrices modulo 5 still preserve the Lorentz form. -/
theorem rfB₁_lorentz_mod5 :
    (matMod 5 rfB₁)ᵀ * (matMod 5 rfQ) * (matMod 5 rfB₁) = matMod 5 rfQ := by
  native_decide

/-- [Section: # CatalogBuild.Pythagorean.ModularForms.RamanujanFrontiers
Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 79] -/
theorem rfB₂_lorentz_mod5 :
    (matMod 5 rfB₂)ᵀ * (matMod 5 rfQ) * (matMod 5 rfB₂) = matMod 5 rfQ := by
  native_decide

/-- [Section: # CatalogBuild.Pythagorean.ModularForms.RamanujanFrontiers
Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 79] -/
theorem rfB₃_lorentz_mod5 :
    (matMod 5 rfB₃)ᵀ * (matMod 5 rfQ) * (matMod 5 rfB₃) = matMod 5 rfQ := by
  native_decide

/-- The Berggren matrices modulo 7 preserve the Lorentz form. -/
theorem rfB₁_lorentz_mod7 :
    (matMod 7 rfB₁)ᵀ * (matMod 7 rfQ) * (matMod 7 rfB₁) = matMod 7 rfQ := by
  native_decide

theorem rfB₂_lorentz_mod7 :
    (matMod 7 rfB₂)ᵀ * (matMod 7 rfQ) * (matMod 7 rfB₂) = matMod 7 rfQ := by
-- ... (truncated, full file has 384 lines)
```

@Cryptography/BerggrenGroupoidOrbit.lean
```lean
import Mathlib

/-!
# Berggren Groupoid Orbit Cryptography

This module formalizes the Berggren generation of primitive Pythagorean triples
as an algebraic-combinatorial machine and establishes the first certified bridge
between arithmetic tree dynamics and post-quantum lattice-style hardness.

## Main Results

1. **Cone & Primitivity Preservation**: Each Berggren matrix preserves the
   Pythagorean cone a² + b² = c² and maps primitive triples to primitive triples.
2. **Faithful Orbit Action**: The map from Berggren words to primitive triples
   (via the root (3,4,5)) is injective — distinct words yield distinct triples.
3. **Lattice Extraction**: Orbit differences generate nontrivial integer lattice
   vectors, connecting orbit geometry to shortest-vector-type problems.
4. **Security Reduction**: Faithfulness + entropy → post-quantum key security
   via a clean reduction interface.

## Keywords

post-quantum cryptography, lattice hardness, shortest vector problem,
arithmetic dynamics, Berggren tree, primitive Pythagorean triples,
groupoid action, faithful representation, entropy extraction, orbit cryptography,
Lorentzian lattice, Diophantine key exchange
-/

open Matrix

namespace BerggrenGroupoid

/-! ## Section 1: Core Definitions -/

/-- Berggren matrix A: the first generator of the Berggren tree.
    Sends (3,4,5) ↦ (5,12,13). Has determinant 1. -/
def berggrenA : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B: the second generator of the Berggren tree.
    Sends (3,4,5) ↦ (21,20,29). Has determinant -1. -/
def berggrenB : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix C: the third generator of the Berggren tree.
    Sends (3,4,5) ↦ (15,8,17). Has determinant 1. -/
def berggrenC : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Integer inverse of Berggren matrix A. Satisfies A⁻¹A = AA⁻¹ = I. -/
def berggrenA_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- Integer inverse of Berggren matrix B. -/
def berggrenB_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- Integer inverse of Berggren matrix C. -/
def berggrenC_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, -2, 2; 2, 1, -2; -2, -2, 3]
-- ... (truncated, full file has 591 lines)
```

@Speculative/AutoResearch/IsingPartitionStability.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Stability of Ising Partition Functions Under Noisy Couplings

This file develops a **quantitative robustness theory for Ising partition functions
under coupling perturbations**, building on the Lorentzian polynomial stability
framework from `LorentzianSharpStability.lean` and `LorentzianStability.lean`.

## Mathematical Overview

For an Ising system on `n` spins with couplings `J : Fin n → Fin n → ℝ`, inverse
temperature `β > 0`, and external field `h : Fin n → ℝ`, the partition function is:

  Z_J(h) = ∑_{σ ∈ {±1}^n} exp(β · E(J, h, σ))

where E(J, h, σ) = ∑_i h_i σ_i + ∑_{i,j} J_{ij} σ_i σ_j.

We prove that:
1. The partition function is always strictly positive.
2. The energy changes in a controlled way under coupling perturbations.
3. The log partition function is Lipschitz in the coupling matrix.
4. The Gibbs expectation values are stable under coupling noise.
5. A quadratic covariance form identity connects the Hessian of log Z to
   spin covariances, bridging Lorentzian geometry to statistical physics.

The key insight is that the `1/(β n²)` perturbation scale from Lorentzian
stability theory translates directly into a physically meaningful robustness
scale for thermodynamic observables.

## Main Results

* `isingPartition_pos` — Partition function is strictly positive
* `isingEnergy_diff_bound` — Energy difference bounded by n² · δ under coupling noise
* `isingPartition_ratio_bound` — Multiplicative bound on partition function ratio
* `isingPartition_logLipschitz` — Log partition function is Lipschitz in couplings
* `gibbs_weight_ratio_bound` — Gibbs weights are stable under coupling noise
* `covarianceForm_eq_variance` — Cross-domain covariance identity
* `covarianceForm_nonneg` — Susceptibility positive semidefiniteness
* `certified_robustness_preserves_signature` — Verified robustness certificate

## Application Keywords

Ising model, partition function, log-concavity, Gibbs measure, covariance,
susceptibility, phase transition, noisy couplings, robustness certificate,
Lorentzian polynomial, Hodge theory, free energy stability

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators

noncomputable section

-- ... (truncated, full file has 477 lines)
```

@Bridges/AlgebraPythagoreanCryptography/BerggrenLatticeReductionDuality.lean
```lean
import Mathlib

/-!
# Berggren Lattice-Reduction Duality via Triple-Tree Semimodules and Certified Reconstruction

This module establishes a rigorous bridge between **primitive Pythagorean triple dynamics**
(the Berggren tree) and **certified lattice trapdoor structure**. The central insight is that
Berggren ancestry constitutes a new arithmetic trapdoor: finitely generated Berggren-stable
collections of primitive triples admit canonical positive-definite lattice realizations with
certified short-basis witnesses, and the hidden minimal generating structure can be
reconstructed from sufficiently rich lattice certificates.

## Main Results

1. **Positive-Definite Gram Construction** (`gramPD`, `gramPD_det`, `gramPD_posDef`):
   The rank-2 matrix `G⁺(a,b,c) = [[c, a], [a, c]]` with `det = b²` is positive definite
   for any primitive Pythagorean triple, and the rank-3 lift adds a canonical third component.

2. **Injectivity / Reconstruction** (`gramPD_injective`, `cert_determines_triple`):
   The Gram map is injective on primitive triples, enabling unique reconstruction.

3. **Realization Theorem** (`realization_of_finite_berggren_family`):
   Every finite set of primitive triples admits a canonical family of positive-definite
   lattice certificates with explicit short-basis bounds.

4. **Rigidity / Uniqueness** (`rigidity_of_gramPD_family`):
   The Gram realization is faithful: distinct finite sets of primitive triples produce
   distinct lattice certificate families.

5. **Certified Reconstruction** (`reconstructTriple_spec`):
   Certificate data uniquely determines the source triple.

6. **Degenerate Boundary** (`gramDegenerate_det_zero`):
   The naive Gram matrix `[[c+a, b], [b, c-a]]` is correctly identified as degenerate
   (det = 0), motivating the positive-definite lift.

## Mathematical Significance

This formalization inaugurates **Pythagorean arithmetic cryptography**: trapdoors as
arithmetic provenance in the Berggren tree, where hidden combinatorial ancestry becomes
a formal cryptographic primitive backed by certified lattice-theoretic witnesses.
-/

set_option maxHeartbeats 800000

open Matrix

/-! ## Section 1: Primitive Pythagorean Triples -/

/-- A primitive Pythagorean triple `(a, b, c)` with:
    - `a² + b² = c²`
    - all components positive
    - `gcd(a, b) = 1`
    - `a` odd, `b` even (canonical normalization) -/
@[ext]
structure PrimTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  pos_a : 0 < a
-- ... (truncated, full file has 472 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v5 Depth Requirements (MANDATORY — WORLD-CLASS STANDARD)

You are working on the frontier of mathematics. The Catalog has 100+ research
packages already. Each new cycle must contribute something genuinely new —
not a rephrasing, not a textbook exercise, not a "mathematics of X" parlor trick.

### STEP 1: PLAN (REQUIRED — before any Lean code)

Before writing any `.lean` file, you MUST output a `## Plan` section that
states, in plain prose:

- **Strategy**: Grothendieck path (define a new structure, prove its properties)
  OR Cauchy path (extend an existing catalog result). Choose the one that fits
  the concept. Do BOTH only if the concept genuinely demands it.
- **Files**: What `.lean` files you will create and what each contains.
  Use sensible names. No fixed count.
- **Theorems**: A list of the theorems you will prove, with one-sentence statements.
- **Why this is non-trivial**: A paragraph explaining the structural insight
  that makes this work world-class. If you cannot write this paragraph, the
  work is not world-class. Pick a different concept.

The Plan is not optional. Cycles that skip the Plan are rejected.

### STEP 2: PEGB for EVERY theorem (strict)

For EACH theorem you prove, you MUST provide all four of:

- **P**roof: A complete, non-trivial Lean 4 proof.
- **E**xample: A concrete worked example (an `example` block or a specific instance).
- **G**eneralization: A one-level-up generalization (a stronger statement, a
  broader class, a higher categorical level). State it as a `theorem` or `lemma`
  with `sorry` if proving it would take the cycle too far — but STATE it.
- **B**oundary: A counterexample or limit-case analysis. When does the result
  fail? What assumptions are essential?

"Top 3-5 theorems" is no longer accepted. EVERY theorem you produce must have
full PEGB. If you produce 2 theorems with full PEGB, that's better than 5 theorems
with PEGB on only 2.

### STEP 3: Anti-patterns (REJECTED outright)

The following tactics are BLACKLISTED for the primary proof of any non-trivial theorem:

- `native_decide`, `decide`, `norm_num`, `rfl` — unless the statement is genuinely
  a numeric/equality fact and the tactic is doing real work (not papering over
  a structural insight).
- `Aesop` — unless the goal is provably trivial (≤ 3 hypotheses, no arithmetic).
- `omega`, `linarith` on quantified goals — these are not "proofs" of structural
  statements.
- `simp only []` with no explicit simp set — this is "let the lemma solver figure it out."

If your only proof of a non-trivial theorem uses one of these, the theorem is not
worth proving. Find a structural proof, or drop the theorem.

### STEP 4: Novelty check

A theorem is "novel" only if a working mathematician in the area would say
"I haven't seen that before." Test yourself:

- Is the statement in a textbook? If yes, find a non-trivial generalization.
- Is the statement a rephrasing of a known result? If yes, the cycle is not novel.
- Is the proof essentially the same as a known proof? If yes, the contribution
  is the statement, not the proof — make sure the statement is genuinely new.

"Mathematics of X" where X is a real-world phenomenon (memes, dreams, consciousness,
art, music, social networks) is NOT a mathematical contribution unless you formalize
X as a precise mathematical object first. If you cannot formalize X rigorously, pick
a different topic.

### STEP 5: Either path (Aristotle's choice)

You are NOT required to follow a specific path. Choose the one that fits the concept:

**Grothendieck path** (define a new structure):
- Invent a new operator, category, algebraic variety, or combinatorial object.
- State its defining properties as axioms or definitions.
- Prove 2-4 non-obvious theorems about it.
- Best for: novel concepts, unexplored territory, "what if we defined X this way?".

**Cauchy path** (extend an existing result):
- Pick a specific catalog theorem (cite it by name).
- Generalize, strengthen, or bridge it.
- Prove the new version is strictly stronger or more general.
- Best for: deepening the catalog, building on existing strength.

You may do BOTH if the concept requires it. But the Plan must justify why both paths
are needed in a single cycle.

### STEP 6: Theorem count

No fixed count. Some concepts deserve 2 deep theorems. Some deserve 6. The Plan
must justify the count. The quality bar is "every theorem has full PEGB" — not
"produce a specific number".

### STEP 7: Cite your sources

Your `## Plan` and any prose must reference specific catalog results by name or path
when you build on them. The catalog is the substrate; you are growing new math on it.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
