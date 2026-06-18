
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
4. **HTML widgets** in PACKAGE.json interactive_demos field
   (1-3 self-contained HTML+CSS+JS snippets that visualize the results).
5. **PACKAGE.json** — Single JSON bundling all of the above.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` (Phase A already produced future directions)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: Learning with Errors: Hardness Reductions
**Domain**: Computation
**Mathematical framing**: Formalize the hardness reduction from worst-case lattice problems (GapSVP, SIVP) to the Learning with Errors problem with specific parameters.
Research domain: Computation
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Computation/LWEBasic.lean
/-
  Learning with Errors: Definitions and Basic Structural Theorems

  This module formalizes the core mathematical structures underlying the
  Learning with Errors (LWE) problem and worst-case lattice problems (GapSVP, SIVP),
  then proves structural theorems about parameter relationships and variant reductions.

  The key insight formalized here is that LWE's hardness is controlled by a precise
  interplay between dimension n, modulus q, and error rate α. We prove:
  1. LWE sample reduction (m samples → m' < m samples)
  2. Modulus divisibility reduction (ZMod q → ZMod p when p ∣ q)
  3. Parameter lower bounds (αq ≥ 2√n is necessary)
  4. Approximation factor tradeoffs

  Reference: Regev, "On Lattices, Learning with Errors, Random Linear Codes,
  and Cryptography" (STOC 2005, J.ACM 2009)
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Core Definitions -/

/-- An LWE instance: matrix A ∈ ℤ_q^{m×n} and target vector b ∈ ℤ_q^m.
    In the "real" distribution, b = As + e (mod q) for secret s and error e.
    In the "uniform" distribution, b is uniform random. -/
structure LWEInstance (n m q : ℕ) where
  A : Fin m → Fin n → ZMod q
  b : Fin m → ZMod q

/-- A lattice basis in ℤ^n, represented as a matrix B ∈ ℤ^{n×n}. -/
structure IntLatticeBasis (n : ℕ) where
  basis : Fin n → Fin n → ℤ

/-- The squared ℓ₂ norm of an integer vector. -/
def intVecNormSq {n : ℕ} (v : Fin n → ℤ) : ℤ :=
  ∑ i, v i * v i

/-- Predicate: a vector is a lattice point (integer combination of basis vectors). -/
def isLatticePoint {n : ℕ} (B : IntLatticeBasis n) (v : Fin n → ℤ) : Prop :=
  ∃ c : Fin n → ℤ, ∀ j, v j = ∑ i, c i * B.basis i j

/-- A lattice vector is nonzero -/
def isNonzero {n : ℕ} (v : Fin n → ℤ) : Prop :=
  ∃ i, v i ≠ 0

/-- Propositional: λ₁(L) ≤ d means there exists a nonzero lattice point
    with squared norm ≤ d². -/
def hasShortVector {n : ℕ} (B : IntLatticeBasis n) (d : ℤ) : Prop :=
  ∃ v : Fin n → ℤ, isLatticePoint B v ∧ isNonzero v ∧ intVecNormSq v ≤ d * d

/-- The Regev parameter validity condition: αq ≥ 2√n. -/
def regev_parameter_valid (n q : ℕ) (α : ℝ) : Prop :=
  α * (q : ℝ) ≥ 2 * Real.sqrt (n : ℝ)

/-- The approximation factor γ in GapSVP corresponding to LWE parameters.
    Regev's theorem gives γ = Õ(n/α). -/
def regev_approx_factor (n : ℕ) (α : ℝ) : ℝ :=
  (n : ℝ) / α

/-! ## Theorem 1: LWE Sample Reduction -/

/-
Reducing samples: LWE with m samples reduces to LWE with m' ≤ m samples
    by discarding rows. This constructs the explicit extraction map.
-/
theorem lwe_sample_reduction (n m m' q : ℕ) (hle : m' ≤ m) :
    ∃ (extract : LWEInstance n m q → LWEInstance n m' q),
    ∀ inst : LWEInstance n m q,
      ∀ (i : Fin m') (j : Fin n),
        (extract inst).A i j = inst.A ⟨i.val, Nat.lt_of_lt_of_le i.isLt hle⟩ j := by
  fconstructor;
  exact fun x => ⟨ fun i j => x.A ⟨ i, by linarith [ Fin.is_lt i ] ⟩ j, fun i => x.b ⟨ i, by linarith [ Fin.is_lt i ] ⟩ ⟩;
  aesop

-- !-- Proof sketch: Define extract by restricting A and b to the first m' rows.
-- The property follows by definition of the restriction. -- !--

/-- Example: extracting 3 samples from 5 -/
example : ∃ (extract : LWEInstance 4 5 7 → LWEInstance 4 3 7),
    ∀ inst, ∀ (i : Fin 3) (j : Fin 4),
      (extract inst).A i j = inst.A ⟨i.val, by omega⟩ j := by
  refine ⟨fun inst => ⟨fun i j => inst.A ⟨i.val, by omega⟩ j,
                         fun i => inst.b ⟨i.val, by omega⟩⟩, ?_⟩
  intro inst i j
  rfl

/-
Generalization: sample reduction with arbitrary injection (not just prefix).
-/
theorem lwe_sample_injection_reduction (n m m' q : ℕ) (f : Fin m' ↪ Fin m) :
    ∃ (extract : LWEInstance n m q → LWEInstance n m' q),
    ∀ inst : LWEInstance n m q,
      ∀ (i : Fin m') (j : Fin n),
        (extract inst).A i j = inst.A (f i) j := by
  exact ⟨ fun inst => ⟨ fun i j => inst.A ( f i ) j, fun i => inst.b ( f i ) ⟩, fun inst i j => rfl ⟩

-- !-- Proof sketch: Define extract by composing A and b with f.
-- The embedding f provides the index map. -- !--

/-- Boundary: with 0 samples, LWE reveals nothing about the secret.
    Any two instances with m=0 are trivially equal. -/
theorem lwe_zero_samples_trivial (n q : ℕ) :
    ∀ (inst₁ inst₂ : LWEInstance n 0 q), inst₁.A = inst₂.A := by
  intro inst₁ inst₂
  ext i
  exact Fin.elim0 i

/-! ## Theorem 2: Modulus Switching via Ring Homomorphism -/

/-
When p ∣ q, there is a natural surjective ring homomorphism ZMod q → ZMod p.
    This is the algebraic foundation of modulus switching reductions.
-/
theorem zmod_quotient_surjective (q p : ℕ) [NeZero p] [NeZero q] (hdvd : p ∣ q) :
    Function.Surjective (ZMod.castHom hdvd (ZMod p)) := by
  convert ZMod.castHom_surjective hdvd using 1

-- !-- Proof sketch: Use ZMod.castHom_surjective from Mathlib. -- !--

/-- Example: the canonical map ZMod 6 → ZMod 3 is surjective -/
example : Function.Surjective (ZMod.castHom (show 3 ∣ 6 by norm_num) (ZMod 3)) := by
  exact ZMod.castHom_surjective _

/-
Modulus switching induces an LWE instance reduction.
-/
theorem lwe_modulus_switch (n m q p : ℕ) [NeZero p] [NeZero q] (hdvd : p ∣ q) :
    ∃ (reduce : LWEInstance n m q → LWEInstance n m p),
    ∀ inst : LWEInstance n m q,
      ∀ (i : Fin m) (j : Fin n),
        (reduce inst).A i j = ZMod.castHom hdvd (ZMod p) (inst.A i j) := by
  refine' ⟨ fun inst => ⟨ fun i j => ( ZMod.castHom hdvd ( ZMod p ) ) ( inst.A i j ), fun i => ( ZMod.castHom hdvd ( ZMod p ) ) ( inst.b i ) ⟩, _ ⟩ ; aesop

/-
!-- Proof sketch: Apply ZMod.castHom pointwise to A and b. -- !--

Generalization: modulus switching is transitive.
    For p ∣ q ∣ r, reducing r → q → p equals reducing r → p directly.
-/
theorem modulus_switch_transitive (p q r : ℕ) [NeZero p] [NeZero q] [NeZero r]
    (hpq : p ∣ q) (hqr : q ∣ r) :
    (ZMod.castHom hpq (ZMod p)).comp (ZMod.castHom hqr (ZMod q)) =
    ZMod.castHom (dvd_trans hpq hqr) (ZMod p) := by
  cases r <;> cases q <;> cases p <;> aesop

/-
!-- Proof sketch: Both sides are ring homomorphisms ZMod r → ZMod p.
By ZMod's universal property, they agree iff they agree on 1. Check on 1. -- !--

Boundary: switching to modulus 1 collapses all information.
-/
theorem modulus_switch_one_trivial (q : ℕ) [NeZero q] (x y : ZMod q) :
    ZMod.castHom (one_dvd q) (ZMod 1) x = ZMod.castHom (one_dvd q) (ZMod 1) y := by
  exact Subsingleton.elim _ _

-- !-- Proof sketch: ZMod 1 has exactly one element, so all values are equal.
-- Use Subsingleton (ZMod 1). -- !--

/-! ## Theorem 3: Error Rate Parameter Bounds -/

/-
If regev_parameter_valid holds, then α ≥ 2√n/q.
    This gives the minimum error rate for security.
-/
theorem regev_alpha_lower_bound {n q : ℕ} {α : ℝ} (hq : (0 : ℝ) < q)
    (h : regev_parameter_valid n q α) :
    α ≥ 2 * Real.sqrt (n : ℝ) / (q : ℝ) := by
  exact div_le_iff₀ hq |>.2 h

-- !-- Proof sketch: From α · q ≥ 2√n and q > 0, divide both sides by q
-- to get α ≥ 2√n / q. -- !--

/-- Example: for n = 4, q = 17, α ≥ 2·2/17 = 4/17 -/
example : regev_parameter_valid 4 17 (4 / 17) → (4 : ℝ) / 17 ≥ 2 * Real.sqrt 4 / 17 := by
  intro _; norm_num

/-
The approximation factor is anti-monotone in the error rate:
    larger α → smaller γ → easier lattice problem.
-/
theorem approx_factor_anti_monotone {n : ℕ} {α₁ α₂ : ℝ}
    (hn : 0 < (n : ℝ)) (hα₁ : 0 < α₁) (hle : α₁ ≤ α₂) :
    regev_approx_factor n α₂ ≤ regev_approx_factor n α₁ := by
  exact mul_le_mul_of_nonneg_left ( inv_anti₀ hα₁ hle ) hn.le

/-
!-- Proof sketch: regev_approx_factor n α = n/α. Since α₁ ≤ α₂ and n > 0,
we have n/α₂ ≤ n/α₁ by monotonicity of x ↦ n/x on (0,∞). -- !--

Scaling the error rate by c > 0 scales the approximation factor by 1/c.
-/
theorem approx_factor_scaling {n : ℕ} {α c : ℝ} :
    regev_approx_factor n (c * α) = regev_approx_factor n α / c := by
  unfold regev_approx_factor; ring;

-- !-- Proof sketch: n/(cα) = (n/α)/c by field arithmetic. -- !--

/-- Example: doubling the error rate halves the approximation factor -/
example : regev_approx_factor 128 0.02 = regev_appr
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
HTML widgets: build 1-3 interactive visualizations that let users explore
the mathematical objects defined in the Lean code.
PACKAGE.json: bundle all of the above into a single JSON file.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
