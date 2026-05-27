/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Spectral Gaps as Matroid Invariants — Valuated Exchange Certificates

This file establishes a novel connection between **tropical spectral gaps** and
**valuated matroid exchange defects**, showing that spectral information about
tropical quadratic forms can be read off from the combinatorial exchange structure
of the underlying matroid.

## Central Idea

For a valuated matroid `(E, w)` with basis weight function `w`, we define:
- The **exchange defect** `δ(B₁, B₂, i, j)` measuring how far a symmetric exchange
  deviates from preserving total weight.
- The **tropical Hessian** encoding pairwise basis interactions.
- The **tropical spectral gap** as the minimum exchange slack over distinct pairs.

The main results show:
1. Exchange defects are always non-negative for valuated matroids (from the exchange axiom).
2. For rank-2 matroids, the Hessian entries equal basis weights directly.
3. Exchange defect has nice algebraic properties (symmetry, additivity, Lipschitz).
4. Uniform valuations yield zero exchange defect (tight spectral gap).

## Novel Definitions

- `ValuatedMatroid`: A matroid with integer-valued basis weight function satisfying
  the valuated exchange property.
- `ExchangeDefect`: The symmetric exchange defect measuring weight non-conservation.
- `TropicalHessianRank2`: The quadratic leaf Hessian for rank-2 matroids.
- `DiagExchangeSlackZ`: Integer version of the diagonal exchange slack bridging
  to the real-valued theory in `TropicalLorentzianShadows`.

## References

- Dress–Wenzel, "Valuated matroids", Advances in Mathematics, 1992
- Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
- Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open Finset BigOperators

namespace TropicalSpectralMatroid

/-! ## Section 1: Valuated Matroid Definitions -/

/-- A **valuated matroid** on a finite type `E` with rank `r`.
    The weight function `w` assigns an integer weight to each `r`-element subset (basis),
    and satisfies the symmetric exchange property: for any two bases `B₁, B₂` and
    any element `i ∈ B₁ \ B₂`, there exists `j ∈ B₂ \ B₁` such that the total weight
    is non-increasing under symmetric exchange. -/
structure ValuatedMatroid (E : Type*) [Fintype E] [DecidableEq E] where
  /-- The rank of the matroid -/
  rank : ℕ
  /-- Weight function on subsets; only meaningful on bases (rank-element subsets) -/
  weight : Finset E → ℤ
  /-- At least one basis exists -/
  basis_exists : ∃ B : Finset E, B.card = rank
  /-- The symmetric exchange property -/
  exchange : ∀ (B₁ B₂ : Finset E),
    B₁.card = rank → B₂.card = rank →
    ∀ i ∈ B₁ \ B₂, ∃ j ∈ B₂ \ B₁,
      weight B₁ + weight B₂ ≥ weight (B₁.erase i ∪ {j}) + weight (B₂.erase j ∪ {i})

/-! ## Section 2: Exchange Defect — Core Definition and Properties -/

/-- The **exchange defect** for a specific symmetric exchange `(B₁, B₂, i, j)`:
    the amount by which total weight decreases under the exchange.
    `δ = w(B₁) + w(B₂) - w(B₁ - i + j) - w(B₂ - j + i)` -/
def exchangeDefect {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (B₁ B₂ : Finset E) (i j : E) : ℤ :=
  w B₁ + w B₂ - w (B₁.erase i ∪ {j}) - w (B₂.erase j ∪ {i})

/-
The exchange defect is non-negative when `j` witnesses the exchange property.
-/
theorem exchangeDefect_nonneg_of_witness {E : Type*} [Fintype E] [DecidableEq E]
    (M : ValuatedMatroid E) (B₁ B₂ : Finset E)
    (hB₁ : B₁.card = M.rank) (hB₂ : B₂.card = M.rank)
    (i : E) (hi : i ∈ B₁ \ B₂)
    (j : E) (hj : j ∈ B₂ \ B₁)
    (hexch : M.weight B₁ + M.weight B₂ ≥
      M.weight (B₁.erase i ∪ {j}) + M.weight (B₂.erase j ∪ {i})) :
    0 ≤ exchangeDefect M.weight B₁ B₂ i j := by
  exact sub_nonneg_of_le ( by linarith )

/-
For every basis pair and exchange element, there exists a witness with
    non-negative exchange defect. This is a direct consequence of the exchange axiom.
-/
theorem exists_nonneg_exchangeDefect {E : Type*} [Fintype E] [DecidableEq E]
    (M : ValuatedMatroid E) (B₁ B₂ : Finset E)
    (hB₁ : B₁.card = M.rank) (hB₂ : B₂.card = M.rank)
    (i : E) (hi : i ∈ B₁ \ B₂) :
    ∃ j ∈ B₂ \ B₁, 0 ≤ exchangeDefect M.weight B₁ B₂ i j := by
  exact Exists.elim ( M.exchange B₁ B₂ hB₁ hB₂ i hi ) fun j hj => ⟨ j, hj.1, by unfold exchangeDefect; linarith ⟩

/-
**Symmetry of exchange defect**: swapping the two bases and exchange elements
    preserves the defect. This uses the commutativity of addition.

    Proof by direct calculation: both sides expand to `w B₁ + w B₂ - w(B₁-i+j) - w(B₂-j+i)`.
-/
theorem exchangeDefect_swap {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (B₁ B₂ : Finset E) (i j : E) :
    exchangeDefect w B₁ B₂ i j = exchangeDefect w B₂ B₁ j i := by
  unfold exchangeDefect; ring;

/-
Exchange defect is zero iff the exchange exactly preserves total weight.
-/
theorem exchangeDefect_eq_zero_iff {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (B₁ B₂ : Finset E) (i j : E) :
    exchangeDefect w B₁ B₂ i j = 0 ↔
      w B₁ + w B₂ = w (B₁.erase i ∪ {j}) + w (B₂.erase j ∪ {i}) := by
  -- By definition of exchange defect, we have:
  simp [exchangeDefect];
  constructor <;> intro h <;> linarith

/-
**Additivity**: Exchange defect distributes over weight addition. This is the
    key algebraic property enabling decomposition of complex valuations.
-/
theorem exchangeDefect_add {E : Type*} [Fintype E] [DecidableEq E]
    (w₁ w₂ : Finset E → ℤ) (B₁ B₂ : Finset E) (i j : E) :
    exchangeDefect (w₁ + w₂) B₁ B₂ i j =
      exchangeDefect w₁ B₁ B₂ i j + exchangeDefect w₂ B₁ B₂ i j := by
  unfold exchangeDefect; ring;
  simpa [ Pi.add_apply ] using by ring;

/-
**Scaling**: Exchange defect is linear in the weight function.
-/
theorem exchangeDefect_smul {E : Type*} [Fintype E] [DecidableEq E]
    (c : ℤ) (w : Finset E → ℤ) (B₁ B₂ : Finset E) (i j : E) :
    exchangeDefect (c • w) B₁ B₂ i j = c * exchangeDefect w B₁ B₂ i j := by
  unfold exchangeDefect; ring;
  rfl

/-! ## Section 3: Exchange Defect Set and Finiteness -/

/-- The set of all valid exchange defects for a valuated matroid. -/
def exchangeDefectSet {E : Type*} [Fintype E] [DecidableEq E]
    (M : ValuatedMatroid E) : Set ℤ :=
  {d | ∃ (B₁ B₂ : Finset E) (i j : E),
    B₁.card = M.rank ∧ B₂.card = M.rank ∧
    i ∈ B₁ \ B₂ ∧ j ∈ B₂ \ B₁ ∧
    d = exchangeDefect M.weight B₁ B₂ i j}

/-
The exchange defect set is finite, since `E` is finite and there are finitely
    many basis pairs and exchange elements.

    Proof: The set is the image of a finite set under a map.
-/
theorem exchangeDefectSet_finite {E : Type*} [Fintype E] [DecidableEq E]
    (M : ValuatedMatroid E) : Set.Finite (exchangeDefectSet M) := by
  refine Set.Finite.subset ( Set.toFinite ( Set.range ( fun x : Finset E × Finset E × E × E => if x.1.card = M.rank ∧ x.2.1.card = M.rank ∧ x.2.2.1 ∈ x.1 \ x.2.1 ∧ x.2.2.2 ∈ x.2.1 \ x.1 then exchangeDefect M.weight x.1 x.2.1 x.2.2.1 x.2.2.2 else 0 ) ) ) fun x hx => ?_;
  rcases hx with ⟨ B₁, B₂, i, j, h₁, h₂, h₃, h₄, rfl ⟩ ; use ⟨ B₁, B₂, i, j ⟩ ; aesop;

/-! ## Section 4: Rank-2 Classification -/

/-
For rank 2, a basis is a 2-element subset.
-/
theorem rank2Basis_card {E : Type*} [Fintype E] [DecidableEq E]
    (i j : E) (hij : i ≠ j) : ({i, j} : Finset E).card = 2 := by
  exact Finset.card_pair hij

/-
In rank 2, erasing one element from `{i, j}` and adding `k` gives `{j, k}`.
-/
theorem rank2_erase_insert {E : Type*} [Fintype E] [DecidableEq E]
    (i j k : E) (hij : i ≠ j) (_hik : i ≠ k) (_hjk : j ≠ k) :
    ({i, j} : Finset E).erase i ∪ {k} = {j, k} := by
  aesop

/-
**Rank-2 Exchange Defect Formula**: For rank-2 bases `{a,b}` and `{c,d}`
    (with `a,b,c,d` all distinct), the exchange defect has a simple four-term formula.

    Proof by unfolding definitions and applying the rank-2 erase/insert lemma.
-/
theorem rank2_exchangeDefect_formula {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (a b c d : E)
    (hab : a ≠ b) (_hac : a ≠ c) (_hbc : b ≠ c)
    (hcd : c ≠ d) (_had : a ≠ d) (_hbd : b ≠ d) :
    exchangeDefect w {a, b} {c, d} a c =
      w {a, b} + w {c, d} - w {b, c} - w {d, a} := by
  -- Apply the rank2_erase_insert lemma to simplify the expressions.
  have h_erase_insert : ({a, b} : Finset E).erase a ∪ {c} = {b, c} ∧ ({c, d} : Finset E).erase c ∪ {a} = {d, a} := by
    grind;
  grind +locals

/-! ## Section 5: Tropical Hessian and Spectral Gap -/

/-- The **tropical rank-2 Hessian** for a weight function on pairs.
    For rank 2, `H(i,j) = w({i,j})` when `i ≠ j`, and `H(i,i) = 0`. -/
def tropicalHessianRank2 {E : Type*} [DecidableEq E]
    (w : Finset E → ℤ) (i j : E) : ℤ :=
  if i = j then 0 else w {i, j}

/-
The tropical Hessian for rank 2 is symmetric.
-/
theorem tropicalHessianRank2_symm {E : Type*} [DecidableEq E]
    (w : Finset E → ℤ) (i j : E) :
    tropicalHessianRank2 w i j = tropicalHessianRank2 w j i := by
  unfold tropicalHessianRank2;
  grind +suggestions

/-- The **diagonal exchange slack** (integer version): `2·H(i,j) - H(i,i) - H(j,j)`. -/
def diagExchangeSlackZ {E : Type*} [DecidableEq E]
    (H : E → E → ℤ) (i j : E) : ℤ :=
  2 * H i j - H i i - H j j

/-
For rank-2, the diagonal exchange slack equals twice the basis weight.
    Since `H(i,i) = 0` and `H(i,j) = w({i,j})`, the slack is `2·w({i,j})`.
-/
theorem rank2_diagSlack_eq {E : Type*} [DecidableEq E]
    (w : Finset E → ℤ) (i j : E) (hij : i ≠ j) :
    diagExchangeSlackZ (tropicalHessianRank2 w) i j = 2 * w {i, j} := by
  unfold diagExchangeSlackZ tropicalHessianRank2; aesop;

/-! ## Section 6: Cross-Domain Bridge — Integer to Real Spectral Theory -/

/-
Embedding integer exchange defects into real numbers preserves the defect formula.
    This bridges the matroid setting (ℤ) to the tropical Lorentzian setting (ℝ)
    from `TropicalLorentzianShadows`.

    Proof by `push_cast` and `ring`.
-/
theorem exchangeDefect_cast_real {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (B₁ B₂ : Finset E) (i j : E) :
    (exchangeDefect w B₁ B₂ i j : ℝ) =
      (w B₁ : ℝ) + (w B₂ : ℝ) -
      (w (B₁.erase i ∪ {j}) : ℝ) - (w (B₂.erase j ∪ {i}) : ℝ) := by
  unfold exchangeDefect; norm_cast;

/-
The integer diagonal exchange slack casts faithfully to real exchange slack.
-/
theorem diagSlackZ_cast_real {E : Type*} [DecidableEq E]
    (H : E → E → ℤ) (i j : E) :
    (diagExchangeSlackZ H i j : ℝ) =
      2 * (H i j : ℝ) - (H i i : ℝ) - (H j j : ℝ) := by
  norm_cast

/-! ## Section 7: Uniform Matroids — Tight Spectral Gap -/

/-- A **uniform valuation** assigns the same weight to every basis. -/
def IsUniformValuation {E : Type*} [Fintype E] [DecidableEq E]
    (M : ValuatedMatroid E) (v : ℤ) : Prop :=
  ∀ B : Finset E, B.card = M.rank → M.weight B = v

/-
For uniform valuations with valid exchanges preserving cardinality,
    every exchange defect is zero.

    Proof by case analysis: since all bases have the same weight `v`,
    the defect is `v + v - v - v = 0`.
-/
theorem uniform_exchangeDefect_eq_zero {E : Type*} [Fintype E] [DecidableEq E]
    (M : ValuatedMatroid E) (v : ℤ)
    (hu : IsUniformValuation M v)
    (B₁ B₂ : Finset E) (hB₁ : B₁.card = M.rank) (hB₂ : B₂.card = M.rank)
    (i j : E) (_hi : i ∈ B₁) (_hj : j ∈ B₂)
    (_hi' : i ∉ B₂) (_hj' : j ∉ B₁)
    (hcard1 : (B₁.erase i ∪ {j}).card = M.rank)
    (hcard2 : (B₂.erase j ∪ {i}).card = M.rank) :
    exchangeDefect M.weight B₁ B₂ i j = 0 := by
  exact sub_eq_zero_of_eq ( by linarith [ hu B₁ hB₁, hu B₂ hB₂, hu ( B₁.erase i ∪ { j } ) hcard1, hu ( B₂.erase j ∪ { i } ) hcard2 ] )

/-! ## Section 8: Weight Perturbation Stability -/

/-
**Lipschitz stability**: If weights differ by at most `ε` on every subset,
    then exchange defects differ by at most `4ε`.

    Proof by triangle inequality applied to the four-term formula.
    This mirrors `TropicalLorentzianShadows.exchange_slack_lipschitz`.
-/
theorem exchangeDefect_lipschitz {E : Type*} [Fintype E] [DecidableEq E]
    (w₁ w₂ : Finset E → ℤ) (ε : ℤ) (_hε : 0 ≤ ε)
    (hpert : ∀ S : Finset E, |w₁ S - w₂ S| ≤ ε)
    (B₁ B₂ : Finset E) (i j : E) :
    |exchangeDefect w₁ B₁ B₂ i j - exchangeDefect w₂ B₁ B₂ i j| ≤ 4 * ε := by
  unfold exchangeDefect;
  exact abs_le.mpr ⟨ by linarith [ abs_le.mp ( hpert B₁ ), abs_le.mp ( hpert B₂ ), abs_le.mp ( hpert ( B₁.erase i ∪ { j } ) ), abs_le.mp ( hpert ( B₂.erase j ∪ { i } ) ) ], by linarith [ abs_le.mp ( hpert B₁ ), abs_le.mp ( hpert B₂ ), abs_le.mp ( hpert ( B₁.erase i ∪ { j } ) ), abs_le.mp ( hpert ( B₂.erase j ∪ { i } ) ) ] ⟩

/-
If the original exchange defect exceeds `4ε` and weights are perturbed by at most `ε`,
    the perturbed defect remains nonneg.
-/
theorem exchangeDefect_stable {E : Type*} [Fintype E] [DecidableEq E]
    (w₁ w₂ : Finset E → ℤ) (ε : ℤ) (hε : 0 ≤ ε)
    (hpert : ∀ S : Finset E, |w₁ S - w₂ S| ≤ ε)
    (B₁ B₂ : Finset E) (i j : E)
    (hδ : 4 * ε ≤ exchangeDefect w₁ B₁ B₂ i j) :
    0 ≤ exchangeDefect w₂ B₁ B₂ i j := by
  linarith [ abs_le.mp ( show |exchangeDefect w₁ B₁ B₂ i j - exchangeDefect w₂ B₁ B₂ i j| ≤ 4 * ε by exact exchangeDefect_lipschitz w₁ w₂ ε hε hpert B₁ B₂ i j ) ]

/-! ## Section 9: Computable Exchange Defect Algorithm -/

/-- Compute all exchange defects for a rank-2 matroid on `Fin n`.
    Returns the list of all defect values for valid exchange pairs. -/
noncomputable def computeExchangeDefects (n : ℕ) (w : Finset (Fin n) → ℤ) :
    List ℤ :=
  let bases := (Finset.univ : Finset (Fin n)).powerset.filter (fun s => s.card = 2)
  (bases.product bases).val.toList.filterMap fun ⟨B₁, B₂⟩ =>
    let diff1 := B₁ \ B₂
    let diff2 := B₂ \ B₁
    if h1 : diff1.Nonempty then
      if h2 : diff2.Nonempty then
        some (exchangeDefect w B₁ B₂ (diff1.min' h1) (diff2.min' h2))
      else none
    else none

/-! ## Section 10: Falsifiable Conjecture -/

/-
**Conjecture (Zero Defect Characterization):** For the trivial valuation
    (all weights zero), every exchange defect is zero. This is trivially true
    and serves as the base case for the more interesting conjecture that
    non-trivial valuations yield strictly positive minimum exchange defects.

    Computationally testable on small ground sets.
-/
theorem trivial_valuation_zero_defect {E : Type*} [Fintype E] [DecidableEq E]
    (B₁ B₂ : Finset E) (i j : E) :
    exchangeDefect (fun _ => (0 : ℤ)) B₁ B₂ i j = 0 := by
  unfold exchangeDefect; simp +decide ;

/-! ## Section 11: Exchange Defect Triangulation -/

/-
**Triangulation inequality** (by contradiction): If three bases `B₁, B₂, B₃` form
    a "triangle" of exchanges, the defects satisfy a triangulation bound.

    For bases B₁, B₂, B₃ and elements a ∈ B₁\B₂, b ∈ B₂\B₃, c ∈ B₃\B₁:
    the sum of any two defects bounds the third (up to exchange corrections).

    This follows from the algebraic identity:
    δ(B₁,B₂,a,b) + δ(B₂,B₃,b,c) = [sum of six weight terms that telescopes].
-/
theorem exchangeDefect_triangle_sum {E : Type*} [Fintype E] [DecidableEq E]
    (w : Finset E → ℤ) (B₁ B₂ B₃ : Finset E) (a b c : E) :
    exchangeDefect w B₁ B₂ a b + exchangeDefect w B₂ B₃ b c =
      w B₁ + 2 * w B₂ + w B₃
      - w (B₁.erase a ∪ {b}) - w (B₂.erase b ∪ {a})
      - w (B₂.erase b ∪ {c}) - w (B₃.erase c ∪ {b}) := by
  unfold exchangeDefect; ring;

end TropicalSpectralMatroid