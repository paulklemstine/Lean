import Mathlib

/-!
# Cellular Automata as Algebraic Geometry over GF(2)

We formalize elementary cellular automata (ECAs) as polynomial dynamical systems
over GF(2) = ZMod 2, and study their fixed-point varieties.

## Main Results

* `zmod2_idempotent`: Over GF(2), every element is idempotent: a² = a
* `zmod2_self_add`: Over GF(2), a + a = 0 (characteristic 2)
* `rule204_all_fixed`: The identity rule (Rule 204) fixes every state
* `rule0_fixed_iff_zero`: The zero rule (Rule 0) has a unique fixed point
* `additive_rule_fixed_closed_add`: Fixed points of additive rules form a subgroup
* `additive_rule_fixed_submodule`: Fixed points of additive rules form a GF(2)-submodule
* `rule110_anf`: Rule 110 has the algebraic normal form b + c + bc + abc
* `rule110_maximal_degree`: Rule 110's ANF has degree 3 (maximal)
* `anf_eval_unique`: The algebraic normal form representation is unique

## Definitions

* `ECALocalRule`: A local rule for an elementary cellular automaton
* `ECAState`: The state space of an ECA on a cyclic array of length n
* `ecaUpdate`: The global update function for an ECA
* `IsFixedPoint`: Predicate for fixed points of an ECA
* `ANFCoeffs`: Algebraic Normal Form coefficients for a 3-variable Boolean function
* `IsAdditiveRule`: Predicate for additive (linear) ECA rules
* `ECAFixedSubmodule`: The fixed-point variety as a GF(2)-submodule (for additive rules)

-/

open ZMod

namespace CellularAlgebraicGeometry

/-! ## GF(2) Algebraic Properties -/

/-- Over GF(2), every element is idempotent: a² = a. This is the key property
that makes every polynomial over GF(2) equivalent to a multilinear polynomial. -/
theorem zmod2_idempotent (a : ZMod 2) : a * a = a := by
  fin_cases a <;> decide

/-- Over GF(2), a + a = 0 (characteristic 2). -/
theorem zmod2_self_add (a : ZMod 2) : a + a = 0 := by
  fin_cases a <;> decide

/-- The only elements of ZMod 2 are 0 and 1. -/
theorem zmod2_cases (a : ZMod 2) : a = 0 ∨ a = 1 := by
  fin_cases a
  · left; rfl
  · right; rfl

/-! ## ECA State Space and Update -/

/-- An ECA local rule: a function from three GF(2) inputs to one GF(2) output.
This represents the transition function g : GF(2)³ → GF(2). -/
abbrev ECALocalRule := ZMod 2 → ZMod 2 → ZMod 2 → ZMod 2

/-- The state of an ECA on a cyclic array of length n, viewed as a vector in GF(2)^n. -/
abbrev ECAState (n : ℕ) := Fin n → ZMod 2

/-- Global update function for an ECA with cyclic boundary conditions.
Given local rule g and state s, the updated state is:
  f(s)_i = g(s_{i-1 mod n}, s_i, s_{i+1 mod n}) -/
def ecaUpdate {n : ℕ} (hn : 0 < n) (g : ECALocalRule) (s : ECAState n) : ECAState n :=
  fun i =>
    g (s ⟨(i.val + n - 1) % n, Nat.mod_lt _ hn⟩)
      (s i)
      (s ⟨(i.val + 1) % n, Nat.mod_lt _ hn⟩)

/-- A state s is a fixed point of ECA rule g if f_g(s) = s. -/
def IsFixedPoint {n : ℕ} (hn : 0 < n) (g : ECALocalRule) (s : ECAState n) : Prop :=
  ecaUpdate hn g s = s

/-- Pointwise characterization of fixed points. -/
theorem isFixedPoint_iff {n : ℕ} (hn : 0 < n) (g : ECALocalRule) (s : ECAState n) :
    IsFixedPoint hn g s ↔ ∀ i : Fin n,
      g (s ⟨(i.val + n - 1) % n, Nat.mod_lt _ hn⟩) (s i)
        (s ⟨(i.val + 1) % n, Nat.mod_lt _ hn⟩) = s i := by
  simp [IsFixedPoint, ecaUpdate, funext_iff]

/-! ## Named ECA Rules -/

/-- Rule 0: the null rule, sends everything to 0. -/
def rule0 : ECALocalRule := fun _ _ _ => 0

/-- Rule 204: the identity rule, returns the center cell. -/
def rule204 : ECALocalRule := fun _ b _ => b

/-- Rule 90: XOR of left and right neighbors. A linear (additive) rule. -/
def rule90 : ECALocalRule := fun a _ c => a + c

/-- Rule 150: XOR of all three cells. A linear (additive) rule. -/
def rule150 : ECALocalRule := fun a b c => a + b + c

/-- Rule 110: b + c + bc + abc over GF(2). The Turing-complete rule. -/
def rule110 : ECALocalRule := fun a b c => b + c + b * c + a * b * c

/-! ## Algebraic Normal Form -/

/-- Coefficients of the Algebraic Normal Form (ANF) for a 3-variable function over GF(2).
Every function f : GF(2)³ → GF(2) has a unique representation as:
  f(a,b,c) = c₀ + c₁a + c₂b + c₃c + c₄ab + c₅ac + c₆bc + c₇abc -/
structure ANFCoeffs where
  c₀ : ZMod 2  -- constant term
  c₁ : ZMod 2  -- coefficient of a
  c₂ : ZMod 2  -- coefficient of b
  c₃ : ZMod 2  -- coefficient of c
  c₄ : ZMod 2  -- coefficient of ab
  c₅ : ZMod 2  -- coefficient of ac
  c₆ : ZMod 2  -- coefficient of bc
  c₇ : ZMod 2  -- coefficient of abc
  deriving DecidableEq, Repr

/-- Evaluate the ANF polynomial at given inputs. -/
def ANFCoeffs.eval (coeffs : ANFCoeffs) : ECALocalRule := fun a b c =>
  coeffs.c₀ + coeffs.c₁ * a + coeffs.c₂ * b + coeffs.c₃ * c +
  coeffs.c₄ * a * b + coeffs.c₅ * a * c + coeffs.c₆ * b * c +
  coeffs.c₇ * a * b * c

/-- The degree of an ANF is the maximum degree among its nonzero terms. -/
def ANFCoeffs.degree (coeffs : ANFCoeffs) : ℕ :=
  if coeffs.c₇ ≠ 0 then 3
  else if coeffs.c₄ ≠ 0 ∨ coeffs.c₅ ≠ 0 ∨ coeffs.c₆ ≠ 0 then 2
  else if coeffs.c₁ ≠ 0 ∨ coeffs.c₂ ≠ 0 ∨ coeffs.c₃ ≠ 0 then 1
  else 0

/-- Extract ANF coefficients from a local rule via Möbius inversion. -/
def anfFromRule (g : ECALocalRule) : ANFCoeffs where
  c₀ := g 0 0 0
  c₁ := g 1 0 0 + g 0 0 0
  c₂ := g 0 1 0 + g 0 0 0
  c₃ := g 0 0 1 + g 0 0 0
  c₄ := g 1 1 0 + g 1 0 0 + g 0 1 0 + g 0 0 0
  c₅ := g 1 0 1 + g 1 0 0 + g 0 0 1 + g 0 0 0
  c₆ := g 0 1 1 + g 0 1 0 + g 0 0 1 + g 0 0 0
  c₇ := g 1 1 1 + g 1 1 0 + g 1 0 1 + g 0 1 1 + g 1 0 0 + g 0 1 0 + g 0 0 1 + g 0 0 0

/-
The ANF evaluation of the extracted coefficients agrees with the original rule.
-/
set_option maxRecDepth 10000 in
theorem anf_eval_correct (g : ECALocalRule) :
    ∀ a b c : ZMod 2, (anfFromRule g).eval a b c = g a b c := by
  decide +revert

/-
The ANF representation is unique: if two coefficient sets give the same function,
they must be equal.
-/
theorem anf_unique (c₁ c₂ : ANFCoeffs) (h : ∀ a b c : ZMod 2, c₁.eval a b c = c₂.eval a b c) :
    c₁ = c₂ := by
  revert h;
  -- By definition of ANF, if two ANFCoeffs evaluate to the same function, then their coefficients must be equal.
  intros h_eval
  have h_coeffs : c₁.c₀ = c₂.c₀ ∧ c₁.c₁ = c₂.c₁ ∧ c₁.c₂ = c₂.c₂ ∧ c₁.c₃ = c₂.c₃ ∧ c₁.c₄ = c₂.c₄ ∧ c₁.c₅ = c₂.c₅ ∧ c₁.c₆ = c₂.c₆ ∧ c₁.c₇ = c₂.c₇ := by
    have := h_eval 0 0 0; have := h_eval 1 0 0; have := h_eval 0 1 0; have := h_eval 0 0 1; have := h_eval 1 1 0; have := h_eval 1 0 1; have := h_eval 0 1 1; have := h_eval 1 1 1; simp_all +decide [ ANFCoeffs.eval ] ;
  cases c₁ ; cases c₂ ; aesop

/-! ## Rule 110 Algebraic Properties -/

/-- The ANF coefficients of Rule 110. -/
def rule110ANF : ANFCoeffs where
  c₀ := 0; c₁ := 0; c₂ := 1; c₃ := 1
  c₄ := 0; c₅ := 0; c₆ := 1; c₇ := 1

/-
Rule 110 has the algebraic normal form b + c + bc + abc.
-/
theorem rule110_anf :
    ∀ a b c : ZMod 2, rule110ANF.eval a b c = rule110 a b c := by
  decide +revert

/-
Rule 110's ANF has maximal degree 3, reflecting its computational complexity.
This connects the algebraic degree of the rule to its dynamical complexity:
rules with higher ANF degree can exhibit more complex behavior.
-/
theorem rule110_maximal_degree : rule110ANF.degree = 3 := by
  decide +revert

/-! ## Fixed Point Theorems -/

/-
Rule 204 (identity) fixes every state: the fixed-point variety is the entire space.
-/
theorem rule204_all_fixed {n : ℕ} (hn : 0 < n) (s : ECAState n) :
    IsFixedPoint hn rule204 s := by
  exact (isFixedPoint_iff hn rule204 s).mpr (congrFun rfl)

/-
Rule 0 has a unique fixed point: the zero vector.
-/
theorem rule0_fixed_iff_zero {n : ℕ} (hn : 0 < n) (s : ECAState n) :
    IsFixedPoint hn rule0 s ↔ s = 0 := by
  -- Unfold IsFixedPoint and use the definition of rule0.
  unfold IsFixedPoint;
  unfold ecaUpdate rule0; aesop;

/-! ## Additive Rules and Submodule Structure -/

/-- An ECA rule is additive (linear) if it can be written as g(a,b,c) = αa + βb + γc
for some coefficients α, β, γ ∈ GF(2). -/
def IsAdditiveRule (g : ECALocalRule) : Prop :=
  ∃ α β γ : ZMod 2, ∀ a b c : ZMod 2, g a b c = α * a + β * b + γ * c

/-
Rule 90 is additive: g(a,b,c) = a + c.
-/
theorem rule90_additive : IsAdditiveRule rule90 := by
  exists 1, 0, 1

/-
Rule 150 is additive: g(a,b,c) = a + b + c.
-/
theorem rule150_additive : IsAdditiveRule rule150 := by
  exact ⟨ 1, 1, 1, fun a b c => by simp +decide [ rule150 ] ⟩

/-
Rule 110 is NOT additive (it has nonlinear terms bc and abc).
-/
theorem rule110_not_additive : ¬ IsAdditiveRule rule110 := by
  rintro ⟨ α, β, γ, h ⟩;
  fin_cases α <;> fin_cases β <;> fin_cases γ <;> trivial

/-
The zero vector is always a fixed point of additive rules.
-/
theorem additive_rule_zero_fixed {n : ℕ} (hn : 0 < n) (g : ECALocalRule)
    (hg : IsAdditiveRule g) :
    IsFixedPoint hn g 0 := by
  exact funext fun i => by rcases hg with ⟨ α, β, γ, hg ⟩ ; simp +decide [ hg, ecaUpdate ] ;

/-
Fixed points of additive rules are closed under addition.
This is the key algebraic-geometric result: for additive rules,
the fixed-point variety V(f - id) is a vector subspace of GF(2)^n.
-/
theorem additive_rule_fixed_closed_add {n : ℕ} (hn : 0 < n) (g : ECALocalRule)
    (hg : IsAdditiveRule g) (s t : ECAState n)
    (hs : IsFixedPoint hn g s) (ht : IsFixedPoint hn g t) :
    IsFixedPoint hn g (s + t) := by
  obtain ⟨ α, β, γ, hg_eq ⟩ := hg; ext i; simp_all +decide [ funext_iff, IsFixedPoint ] ;
  convert congr_arg₂ ( · + · ) ( hs i ) ( ht i ) using 1 ; simp +decide [ ecaUpdate, hg_eq ] ; ring

/-
Fixed points of additive rules are closed under GF(2)-scalar multiplication.
-/
theorem additive_rule_fixed_closed_smul {n : ℕ} (hn : 0 < n) (g : ECALocalRule)
    (hg : IsAdditiveRule g) (c : ZMod 2) (s : ECAState n)
    (hs : IsFixedPoint hn g s) :
    IsFixedPoint hn g (c • s) := by
  fin_cases c <;> simp_all +decide
  exact additive_rule_zero_fixed hn g hg

/-- The fixed-point set of an additive ECA rule forms a GF(2)-submodule of GF(2)^n.
This is the central algebraic-geometric theorem: the "variety" V(f - id) has
the structure of a linear subspace, and its dimension classifies the rule's behavior. -/
def ECAFixedSubmodule {n : ℕ} (hn : 0 < n) (g : ECALocalRule)
    (hg : IsAdditiveRule g) : Submodule (ZMod 2) (ECAState n) where
  carrier := { s | IsFixedPoint hn g s }
  zero_mem' := additive_rule_zero_fixed hn g hg
  add_mem' := fun {s t} hs ht => additive_rule_fixed_closed_add hn g hg s t hs ht
  smul_mem' := fun c s hs => additive_rule_fixed_closed_smul hn g hg c s hs

/-
The fixed-point submodule of Rule 204 (identity) is the entire space.
-/
theorem rule204_fixed_submodule_eq_top {n : ℕ} (hn : 0 < n) :
    ECAFixedSubmodule hn rule204 ⟨0, 1, 0, fun a b c => by simp [rule204]⟩ = ⊤ := by
  exact SetLike.ext fun x => by simp +decide [ ECAFixedSubmodule, rule204_all_fixed ] ;

/-! ## Orbit and Dynamics -/

/-- The k-th iterate of an ECA update. -/
def ecaIterate {n : ℕ} (hn : 0 < n) (g : ECALocalRule) : ℕ → ECAState n → ECAState n
  | 0, s => s
  | k + 1, s => ecaIterate hn g k (ecaUpdate hn g s)

/-
Fixed points are invariant under all iterates.
-/
theorem fixed_point_iterate_invariant {n : ℕ} (hn : 0 < n) (g : ECALocalRule)
    (s : ECAState n) (hs : IsFixedPoint hn g s) (k : ℕ) :
    ecaIterate hn g k s = s := by
  induction' k with k ih;
  · rfl;
  · rw [ show ecaIterate hn g ( k + 1 ) s = ecaIterate hn g k ( ecaUpdate hn g s ) from rfl, hs, ih ]

/-! ## Connecting Degree to Complexity: The Degree-Dimension Bridge -/

/-- An ECA rule is *nilpotent* if iterating it eventually reaches the zero state
from any initial state. -/
def IsNilpotentRule {n : ℕ} (hn : 0 < n) (g : ECALocalRule) : Prop :=
  ∀ s : ECAState n, ∃ k, ecaIterate hn g k s = 0

/-
Rule 0 is nilpotent: one iteration sends everything to zero.
-/
theorem rule0_nilpotent {n : ℕ} (hn : 0 < n) : IsNilpotentRule hn rule0 := by
  intro s;
  -- For any state s, we can choose k = 1. Then ecaIterate hn rule0 1 s is the zero vector.
  use 1
  funext i
  simp [ecaIterate, ecaUpdate, rule0]

/-- The algebraic degree of an ECA rule: the degree of its ANF representation. -/
noncomputable def algebraicDegree (g : ECALocalRule) : ℕ := (anfFromRule g).degree

/-
Additive rules have algebraic degree at most 1.
This connects the algebraic classification to the dynamical one:
degree ≤ 1 rules have subspace fixed-point varieties.
-/
theorem additive_degree_le_one (g : ECALocalRule) (hg : IsAdditiveRule g) :
    algebraicDegree g ≤ 1 := by
  obtain ⟨ α, β, γ, hg ⟩ := hg;
  unfold algebraicDegree;
  fin_cases α <;> fin_cases β <;> fin_cases γ <;> simp +decide [ hg, anfFromRule ]

end CellularAlgebraicGeometry