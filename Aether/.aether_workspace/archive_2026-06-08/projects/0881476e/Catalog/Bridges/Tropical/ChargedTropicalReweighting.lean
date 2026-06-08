/-
# Charged Tropical Reweighting: Reduction of Tropical Einstein–Maxwell to Standard Bellman

This file establishes a gauge-elimination principle in tropical dynamics:
electromagnetic forcing encoded by a gauge potential `A` and charge `q` can be absorbed
into a modified Bellman weight, converting a coupled tropical Einstein–Maxwell system
into a pure tropical Einstein equation with an effective charged potential.

## Main results

* `maxwellBellmanOp_eq_bellmanOp_charged` — The Maxwell–Bellman operator equals the
  standard Bellman operator for the charged weight `W + q • A`.
* `tropical_einstein_maxwell_iff_charged` — The tropical Einstein–Maxwell equation is
  logically equivalent to the tropical Einstein equation for `chargedWeight W A q`.
* `tropical_einstein_maxwell_fixedPoint_iff` — Fixed-point equivalence of the two operators.
* `iterate_maxwellBellmanOp_eq` — All iterates of the Maxwell–Bellman operator equal
  iterates of the charged Bellman operator (equivalence of dynamics).
* `chargedWeight_mono_charge` — Monotonicity of charged weight in the charge parameter
  when the gauge potential is nonneg.
-/

import Mathlib

open Matrix

/-! ## Core definitions -/

/-- The charged (reweighted) transition cost matrix: `W(i,j) + q * A(i,j)`. -/
def chargedWeight {n : ℕ} (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => W i j + q * A i j

/-- Standard tropical Bellman operator: `(T_W Φ)(i) = ⨆ j, (W(i,j) + Φ(j))`. -/
noncomputable def bellmanOp {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (Φ : Fin n → ℝ) :
    Fin n → ℝ :=
  fun i => ⨆ j : Fin n, (W i j + Φ j)

/-- Maxwell–Bellman operator with gauge coupling:
    `(T_{W,A,q} Φ)(i) = ⨆ j, (W(i,j) + q * A(i,j) + Φ(j))`. -/
noncomputable def maxwellBellmanOp {n : ℕ} (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ)
    (Φ : Fin n → ℝ) : Fin n → ℝ :=
  fun i => ⨆ j : Fin n, (W i j + q * A i j + Φ j)

/-- The tropical Einstein equation: `Φ(s) = (T_W Φ)(s)`. -/
noncomputable def TropicalEinsteinEquation {n : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ) (s : Fin n) (Φ : Fin n → ℝ) : Prop :=
  Φ s = bellmanOp W Φ s

/-- The tropical Einstein–Maxwell equation: `Φ(s) = (T_{W,A,q} Φ)(s)`. -/
noncomputable def TropicalEinsteinMaxwell {n : ℕ}
    (W A : Matrix (Fin n) (Fin n) ℝ) (s : Fin n) (q : ℝ) (Φ : Fin n → ℝ) : Prop :=
  Φ s = maxwellBellmanOp W A q Φ s

/-! ## Simplification lemmas -/

@[simp]
theorem chargedWeight_apply {n : ℕ} (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ)
    (i j : Fin n) : chargedWeight W A q i j = W i j + q * A i j :=
  rfl

@[simp]
theorem bellmanOp_apply {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (Φ : Fin n → ℝ) (i : Fin n) :
    bellmanOp W Φ i = ⨆ j : Fin n, (W i j + Φ j) :=
  rfl

@[simp]
theorem maxwellBellmanOp_apply {n : ℕ} (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ)
    (Φ : Fin n → ℝ) (i : Fin n) :
    maxwellBellmanOp W A q Φ i = ⨆ j : Fin n, (W i j + q * A i j + Φ j) :=
  rfl

/-! ## Main theorems -/

/-
**Operator equality**: The Maxwell–Bellman operator is exactly the standard Bellman
operator for the charged weight `chargedWeight W A q`. This is the core reduction.
-/
theorem maxwellBellmanOp_eq_bellmanOp_charged {n : ℕ}
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) (Φ : Fin n → ℝ) :
    maxwellBellmanOp W A q Φ = bellmanOp (chargedWeight W A q) Φ := by
  grind +suggestions

/-- **Gauge elimination principle**: The tropical Einstein–Maxwell equation is logically
equivalent to the tropical Einstein equation for the charged weight. -/
theorem tropical_einstein_maxwell_iff_charged {n : ℕ}
    (W A : Matrix (Fin n) (Fin n) ℝ) (s : Fin n) (q : ℝ) (Φ : Fin n → ℝ) :
    TropicalEinsteinMaxwell W A s q Φ ↔
      TropicalEinsteinEquation (chargedWeight W A q) s Φ := by
  simp only [TropicalEinsteinMaxwell, TropicalEinsteinEquation,
    maxwellBellmanOp_eq_bellmanOp_charged]

/-- **Fixed-point equivalence**: `Φ` is a fixed point of the Maxwell–Bellman operator
iff it is a fixed point of the charged Bellman operator. -/
theorem tropical_einstein_maxwell_fixedPoint_iff {n : ℕ}
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) (Φ : Fin n → ℝ) :
    (maxwellBellmanOp W A q Φ = Φ) ↔
      (bellmanOp (chargedWeight W A q) Φ = Φ) := by
  rw [maxwellBellmanOp_eq_bellmanOp_charged]

/-- **Functorial operator equality**: The Maxwell–Bellman operator is the Bellman operator
composed with charged reweighting, as functions. -/
theorem bellman_charged_functorial {n : ℕ}
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) :
    maxwellBellmanOp W A q = bellmanOp (chargedWeight W A q) := by
  ext Φ i
  exact congr_fun (maxwellBellmanOp_eq_bellmanOp_charged W A q Φ) i

/-
**Equivalence of dynamics**: All iterates of the Maxwell–Bellman operator equal
the corresponding iterates of the charged Bellman operator.
-/
theorem iterate_maxwellBellmanOp_eq {n : ℕ}
    (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) (k : ℕ) (Φ : Fin n → ℝ) :
    (maxwellBellmanOp W A q)^[k] Φ = (bellmanOp (chargedWeight W A q))^[k] Φ := by
  exact congr_arg ( fun f => f^[k] Φ ) ( bellman_charged_functorial W A q )

/-! ## Monotonicity corollary -/

/-
**Monotonicity in charge**: When all gauge potential entries are nonneg,
the charged weight is monotone in the charge parameter `q`.
-/
theorem chargedWeight_mono_charge {n : ℕ}
    (W A : Matrix (Fin n) (Fin n) ℝ) (hA : ∀ i j, 0 ≤ A i j)
    {q₁ q₂ : ℝ} (hq : q₁ ≤ q₂) (i j : Fin n) :
    chargedWeight W A q₁ i j ≤ chargedWeight W A q₂ i j := by
  -- Unfold chargedWeight. Need W i j + q₁ * A i j ≤ W i j + q₂ * A i j. This is add_le_add_left applied to q₁ * A i j ≤ q₂ * A i j, which follows from mul_le_mul_of_nonneg_right hq (hA i j).
  simp [chargedWeight];
  -- Since $A_{ij} \geq 0$, multiplying both sides of $q₁ \leq q₂$ by $A_{ij}$ preserves the inequality.
  apply mul_le_mul_of_nonneg_right hq (hA i j)

/-! ## Generalized version for arbitrary finite types -/

/-- Charged weight for function-valued weights on arbitrary types. -/
def chargedWeightFn {α : Type*} (W A : α → α → ℝ) (q : ℝ) : α → α → ℝ :=
  fun i j => W i j + q * A i j

/-- Generalized Bellman operator for arbitrary finite types using `iSup`. -/
noncomputable def bellmanOpGen {α : Type*} [Fintype α]
    (W : α → α → ℝ) (Φ : α → ℝ) : α → ℝ :=
  fun i => ⨆ j : α, (W i j + Φ j)

/-- Generalized Maxwell–Bellman operator for arbitrary finite types. -/
noncomputable def maxwellBellmanOpGen {α : Type*} [Fintype α]
    (W A : α → α → ℝ) (q : ℝ) (Φ : α → ℝ) : α → ℝ :=
  fun i => ⨆ j : α, (W i j + q * A i j + Φ j)

/-
**Generalized operator equality** for arbitrary finite types.
-/
theorem maxwellBellmanOpGen_eq_bellmanOpGen_charged {α : Type*} [Fintype α]
    (W A : α → α → ℝ) (q : ℝ) (Φ : α → ℝ) :
    maxwellBellmanOpGen W A q Φ = bellmanOpGen (chargedWeightFn W A q) Φ := by
  grind +locals

/-- **Generalized gauge elimination** for arbitrary finite types. -/
theorem tropical_einstein_maxwell_gen_iff {α : Type*} [Fintype α]
    (W A : α → α → ℝ) (s : α) (q : ℝ) (Φ : α → ℝ) :
    (Φ s = maxwellBellmanOpGen W A q Φ s) ↔
      (Φ s = bellmanOpGen (chargedWeightFn W A q) Φ s) := by
  rw [maxwellBellmanOpGen_eq_bellmanOpGen_charged]

/-
**Generalized iterate equivalence** for arbitrary finite types.
-/
theorem iterate_maxwellBellmanOpGen_eq {α : Type*} [Fintype α]
    (W A : α → α → ℝ) (q : ℝ) (k : ℕ) (Φ : α → ℝ) :
    (maxwellBellmanOpGen W A q)^[k] Φ = (bellmanOpGen (chargedWeightFn W A q))^[k] Φ := by
  congr 1

/-
Charged weight addition decomposes: `chargedWeight W A (q₁ + q₂)` relates to
successive charging.
-/
theorem chargedWeight_add_charge {n : ℕ}
    (W A : Matrix (Fin n) (Fin n) ℝ) (q₁ q₂ : ℝ) :
    chargedWeight W A (q₁ + q₂) = chargedWeight (chargedWeight W A q₁) A q₂ := by
  exact funext fun i => funext fun j => by unfold chargedWeight; ring;

/-
Zero charge gives the original weight.
-/
@[simp]
theorem chargedWeight_zero {n : ℕ} (W A : Matrix (Fin n) (Fin n) ℝ) :
    chargedWeight W A 0 = W := by
  -- By definition of `chargedWeight`, we have `chargedWeight W A 0 i j = W i j + 0 * A i j`.
  funext i j; simp [chargedWeight]