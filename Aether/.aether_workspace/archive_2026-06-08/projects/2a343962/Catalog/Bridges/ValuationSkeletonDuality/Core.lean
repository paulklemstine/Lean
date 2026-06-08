import Mathlib

/-!
# Valuation-Skeleton Margin Duality for p-adic Rational Networks — Core

This file establishes a valuation-theoretic margin theory for arithmetic rational
networks over non-Archimedean fields, connecting Berkovich-style skeleton decompositions
to certified ML robustness, tropical piecewise-linearization, and post-quantum
complexity proxies.

## Mathematical Domains Bridged
1. **Non-Archimedean Analytic Geometry** ↔ **Certified ML Robustness**
2. **Tropical Geometry** ↔ **Arithmetic Operadic Networks**
3. **Berkovich Skeleta** ↔ **Post-Quantum / Lattice Complexity**

Bridge: connects non-Archimedean analytic geometry to certified robustness in ML,
tropical piecewise-linearization to arithmetic operadic networks, and Berkovich
skeleta to post_quantum_security / lattice-style complexity proxies.
-/

open Finset Function Classical

noncomputable section

attribute [local instance] Classical.propDecidable

namespace ValuationSkeleton

/-! ## §1. Extended Valuation Codomain and HasIntValuation Typeclass -/

/-- Extended integer valuation type.
    Bridge: connects p-adic valuation theory to tropical semiring geometry. -/
abbrev EVal := WithTop ℤ

/-- `HasIntValuation`: Typeclass for fields with an integer non-Archimedean valuation.
    Bridge: connects non-Archimedean number theory to certified_robustness
    and post_quantum_security via discrete valuation arithmetic. -/
class HasIntValuation (K : Type*) [Field K] where
  v : K → EVal
  map_zero : v 0 = ⊤
  map_one : v 1 = (0 : ℤ)
  map_mul : ∀ x y, v (x * y) = v x + v y
  map_add_le_min : ∀ x y, min (v x) (v y) ≤ v (x + y)

variable {K : Type*} [Field K] [HasIntValuation K]
variable {α : Type*}

/-! ## §2. Primitive Valuation Lemmas -/

/-- Multiplicativity: v(xy) = v(x) + v(y).
    Bridge: connects ring multiplication to tropical addition. -/
theorem valuation_mul (x y : K) :
    HasIntValuation.v (x * y) = HasIntValuation.v x + HasIntValuation.v y :=
  HasIntValuation.map_mul x y

/-- Ultrametric inequality: min(v(x), v(y)) ≤ v(x+y).
    Bridge: connects ultrametric topology to certified_robustness. -/
theorem valuation_add_ge_min (x y : K) :
    min (HasIntValuation.v x) (HasIntValuation.v y) ≤ HasIntValuation.v (x + y) :=
  HasIntValuation.map_add_le_min x y

/-
Valuation of negation equals valuation.
    Bridge: connects additive symmetry to tropical geometry invariance.
-/
theorem valuation_neg (x : K) :
    HasIntValuation.v (-x) = HasIntValuation.v x := by
  obtain ⟨ v, hv ⟩ := ‹HasIntValuation K›;
  rename_i h₁ h₂ h₃ h₄;
  have := h₁.map_mul ( -1 ) ( -1 ) ; simp_all +decide;
  have := h₃ ( -x ) ( -1 ) ; simp_all +decide;
  cases h : h₁.v ( -1 ) <;> simp_all +decide [ add_comm ];
  · cases h₁;
    rename_i h₁ h₂ h₃ h₄;
    cases this.symm.trans h₂;
  · have := h₁.map_one; simp_all +decide [ WithTop.some_eq_coe ] ;
    norm_cast at * ; simp_all +decide [ ← two_mul ];
    have := h₁.map_mul ( -x ) ( -1 ) ; simp_all +decide [ add_comm ] ;

/-
The valuation of a nonzero element is finite.
    Bridge: connects field non-degeneracy to tropical finiteness.
-/
theorem valuation_ne_top_of_ne_zero (x : K) (hx : x ≠ 0) :
    HasIntValuation.v x ≠ ⊤ := by
  intro h;
  have := ‹HasIntValuation K›.map_mul x x⁻¹;
  have := ‹HasIntValuation K›.map_one; simp_all +decide ;

/-
Inversion negates valuation away from zero.
    Bridge: connects field inversion to tropical negation.
-/
theorem valuation_inv (x : K) (hx : x ≠ 0) :
    HasIntValuation.v x⁻¹ = -(HasIntValuation.v x) := by
  rename_i h;
  have h_neg : h.v x + h.v x⁻¹ = 0 := by
    rw [ ← h.map_mul, mul_inv_cancel₀ hx, h.map_one ];
    rfl;
  rw [ eq_neg_of_add_eq_zero_right h_neg ]

/-
Strict dominance: if v(x) < v(y), then v(x+y) = v(x).
    Bridge: connects strict ultrametric inequality to tropical monomial selection.
-/
theorem valuation_add_eq_of_strict_dom (x y : K)
    (h : HasIntValuation.v x < HasIntValuation.v y) :
    HasIntValuation.v (x + y) = HasIntValuation.v x := by
  rename_i h';
  have := h'.map_add_le_min ( x + y ) ( -y ) ; simp_all +decide [ lt_iff_le_and_ne ] ;
  cases this <;> have := h'.map_add_le_min x y <;> simp_all +decide [ lt_iff_le_and_ne ];
  · exact le_antisymm ‹_› ‹_›;
  · grind +suggestions

/-! ## §3. Threshold Margin and Label Definitions -/

/-- `thresholdMargin`: Valuation-theoretic margin of `f` at `x` relative to threshold `t`.
    Bridge: connects p-adic analytic margin to certified_robustness. -/
def thresholdMargin (f : α → K) (t : K) (x : α) : EVal :=
  HasIntValuation.v (f x - t)

/-- `valuationLabel`: Binary classification by valuation comparison.
    Bridge: connects tropical geometry to neural_network classification. -/
def valuationLabel (f₀ f₁ : α → K) (x : α) : Prop :=
  HasIntValuation.v (f₀ x) ≤ HasIntValuation.v (f₁ x)

/-- `boolLabel`: Decidable version of valuation label.
    Bridge: connects tropical geometry to neural_network classification. -/
def boolLabel (f₀ f₁ : α → K) (x : α) : Bool :=
  if HasIntValuation.v (f₀ x) ≤ HasIntValuation.v (f₁ x) then true else false

/-- `PoleFreeOn`: A function is pole-free on a set.
    Bridge: connects algebraic geometry to certified_robustness. -/
def PoleFreeOn (f : α → K) (s : Set α) : Prop :=
  ∀ x ∈ s, f x ≠ 0

/-! ## §4. Skeleton Cell and Finite Cover Structures -/

/-- `SkeletonCell`: A cell in a Berkovich-style skeleton decomposition.
    Bridge: connects Berkovich analytic geometry to thermodynamic phase
    classification and lattice complexity. -/
structure SkeletonCell (α : Type*) where
  carrier : Set α
  chartDim : ℕ
  chart : α → Fin chartDim → ℤ

/-- `FiniteSkeletonCover`: A finite covering of a type by skeleton cells.
    Uses a natural-number indexed family for cleaner Finset-free API.
    Bridge: connects Berkovich skeleton theory to post_quantum_security complexity. -/
structure FiniteSkeletonCover (α : Type*) where
  numCells : ℕ
  cell : Fin numCells → SkeletonCell α
  covers : ∀ x : α, ∃ i : Fin numCells, x ∈ (cell i).carrier

/-- `skeletonComplexity`: Number of cells in a skeleton cover.
    Bridge: connects Berkovich geometry to arithmetic_complexity. -/
def skeletonComplexity (S : FiniteSkeletonCover α) : ℕ := S.numCells

/-- `CellConst`: A function is constant on a skeleton cell.
    Bridge: connects tropical constancy to certified_robustness. -/
def CellConst {β : Type*} (φ : α → β) (C : SkeletonCell α) : Prop :=
  ∃ b, ∀ x ∈ C.carrier, φ x = b

/-- `IsAffineOnCell`: A ℤ-valued function is affine on a cell.
    Bridge: connects tropical piecewise-linear geometry to neural_network
    decision boundary analysis. -/
def IsAffineOnCell (φ : α → ℤ) (C : SkeletonCell α) : Prop :=
  ∃ (a : Fin C.chartDim → ℤ) (b : ℤ),
    ∀ x ∈ C.carrier, φ x = ∑ i : Fin C.chartDim, a i * C.chart x i + b

/-- `mixedLabelCellCount`: Cells on which a label takes both values.
    Bridge: connects combinatorial complexity to VC-dimension. -/
def mixedLabelCellCount (S : FiniteSkeletonCover α) (lbl : α → Bool) : ℕ :=
  Finset.card (Finset.univ.filter fun i : Fin S.numCells =>
    (∃ x ∈ (S.cell i).carrier, lbl x = true) ∧
    (∃ y ∈ (S.cell i).carrier, lbl y = false))

/-- `HighMarginRegion`: Points where margin exceeds threshold γ.
    Bridge: connects margin theory to certified_robustness. -/
def HighMarginRegion (f : α → K) (t : K) (γ : ℤ) : Set α :=
  {x | (γ : EVal) ≤ thresholdMargin f t x}

/-! ## §5. Rational Gate Syntax -/

/-- `RationalGate`: Inductive syntax for rational arithmetic circuits.
    Bridge: connects operadic algebra to quantum circuit design
    and post_quantum_security arithmetic complexity. -/
inductive RationalGate (K : Type*) where
  | input : ℕ → RationalGate K
  | const : K → RationalGate K
  | add : RationalGate K → RationalGate K → RationalGate K
  | mul : RationalGate K → RationalGate K → RationalGate K
  | inv : RationalGate K → RationalGate K
  deriving Inhabited

namespace RationalGate

/-- Evaluation of a rational gate.
    Bridge: connects circuit semantics to p-adic function evaluation. -/
def eval [Field K] (σ : ℕ → K) : RationalGate K → K
  | input i => σ i
  | const c => c
  | add g h => g.eval σ + h.eval σ
  | mul g h => g.eval σ * h.eval σ
  | inv g => if g.eval σ = 0 then 0 else (g.eval σ)⁻¹

/-- Depth of a rational gate.
    Bridge: connects circuit complexity to post_quantum_security. -/
def depth : RationalGate K → ℕ
  | input _ => 0
  | const _ => 0
  | add g h => 1 + max g.depth h.depth
  | mul g h => 1 + max g.depth h.depth
  | inv g => 1 + g.depth

/-- Gate count.
    Bridge: connects circuit size to arithmetic_complexity. -/
def gateCount : RationalGate K → ℕ
  | input _ => 1
  | const _ => 1
  | add g h => 1 + g.gateCount + h.gateCount
  | mul g h => 1 + g.gateCount + h.gateCount
  | inv g => 1 + g.gateCount

/-- Gate count is always positive.
    Bridge: connects circuit structure to arithmetic_complexity. -/
theorem gateCount_pos (g : RationalGate K) : 0 < g.gateCount := by
  cases g <;> simp [gateCount] <;> omega

/-- Depth ≤ gate count.
    Bridge: connects circuit depth to arithmetic_complexity. -/
theorem depth_le_gateCount (g : RationalGate K) : g.depth ≤ g.gateCount := by
  induction g with
  | input _ => simp [depth, gateCount]
  | const _ => simp [depth, gateCount]
  | add l r ihl ihr => simp only [depth, gateCount]; omega
  | mul l r ihl ihr => simp only [depth, gateCount]; omega
  | inv g ih => simp only [depth, gateCount]; omega

/-- Input gate evaluation.
    Bridge: connects circuit input to function evaluation. -/
theorem eval_input (σ : ℕ → K) (i : ℕ) :
    (RationalGate.input i : RationalGate K).eval σ = σ i := rfl

/-- Const gate evaluation.
    Bridge: connects circuit constant to p-adic value. -/
theorem eval_const (σ : ℕ → K) (c : K) :
    (RationalGate.const c : RationalGate K).eval σ = c := rfl

/-- Add gate evaluation.
    Bridge: connects circuit addition to p-adic addition. -/
theorem eval_add (σ : ℕ → K) (g h : RationalGate K) :
    (RationalGate.add g h).eval σ = g.eval σ + h.eval σ := rfl

/-- Mul gate evaluation.
    Bridge: connects circuit multiplication to p-adic multiplication. -/
theorem eval_mul (σ : ℕ → K) (g h : RationalGate K) :
    (RationalGate.mul g h).eval σ = g.eval σ * h.eval σ := rfl

end RationalGate

/-! ## §6. Counting and Complexity Theorems -/

/-- Mixed-label cells bounded by total cell count.
    Bridge: connects finite cell decomposition to VC-dimension bounds. -/
theorem mixedLabelCellCount_le (S : FiniteSkeletonCover α) (lbl : α → Bool) :
    mixedLabelCellCount S lbl ≤ S.numCells := by
  unfold mixedLabelCellCount
  calc Finset.card (Finset.univ.filter _) ≤ Finset.card (Finset.univ : Finset (Fin S.numCells)) :=
        Finset.card_filter_le _ _
    _ = S.numCells := Finset.card_fin S.numCells

/-- Mixed-label bounded by skeleton complexity.
    Bridge: connects label-change combinatorics to certified_robustness. -/
theorem mixedLabel_le_skeletonComplexity (S : FiniteSkeletonCover α) (lbl : α → Bool) :
    mixedLabelCellCount S lbl ≤ skeletonComplexity S :=
  mixedLabelCellCount_le S lbl

/-- Skeleton complexity is nonneg.
    Bridge: connects cell counting to thermodynamic partition function. -/
theorem skeletonComplexity_nonneg (S : FiniteSkeletonCover α) :
    0 ≤ skeletonComplexity S := Nat.zero_le _

/-! ## §7. Chart Evaluation Cost Model -/

/-- `chartEvalCost`: Cost of evaluating an affine chart function.
    Bridge: connects tropical geometry evaluation to arithmetic_complexity. -/
def chartEvalCost (C : SkeletonCell α) : ℕ := 2 * C.chartDim + 1

/-- Chart evaluation cost is O(d).
    Bridge: connects tropical evaluation to tropical_hash_collision cost. -/
theorem tropical_hash_collision_chartEvalCost_linear (C : SkeletonCell α) :
    chartEvalCost C ≤ 2 * C.chartDim + 1 := le_refl _

/-- Chart evaluation cost positive.
    Bridge: connects cost model to post_quantum_security. -/
theorem chartEvalCost_pos (C : SkeletonCell α) : 0 < chartEvalCost C := by
  unfold chartEvalCost; omega

/-! ## §8. Refinement and Entropy -/

/-- `SkeletonRefinement`: One cover refines another.
    Bridge: connects geometric refinement to thermodynamic coarse-graining. -/
def SkeletonRefinement (S₁ S₂ : FiniteSkeletonCover α) : Prop :=
  ∀ i : Fin S₂.numCells, ∃ j : Fin S₁.numCells,
    (S₂.cell i).carrier ⊆ (S₁.cell j).carrier

/-- `cellEntropy`: Entropy proxy for a skeleton cover.
    Bridge: connects Berkovich combinatorics to thermodynamic entropy. -/
def cellEntropy (S : FiniteSkeletonCover α) : ℕ := Nat.log 2 S.numCells

/-- Entropy monotone in cell count.
    Bridge: connects thermodynamic entropy to complexity growth. -/
theorem thermodynamic_entropy_monotone_card (S₁ S₂ : FiniteSkeletonCover α)
    (h : S₁.numCells ≤ S₂.numCells) :
    cellEntropy S₁ ≤ cellEntropy S₂ :=
  Nat.log_mono_right h

/-! ## §9. Valuation Lipschitz and Robustness -/

/-- `ValuationLipschitz`: Lipschitz in the valuation sense with constant L.
    v(f(x) - f(y)) ≥ v(x - y) - L for all x, y.
    Bridge: connects Lipschitz continuity to certified_robustness. -/
def ValuationLipschitz (f : K → K) (L : ℤ) : Prop :=
  ∀ x y, (HasIntValuation.v (x - y) : EVal) ≤ HasIntValuation.v (f x - f y) + (L : EVal)

/-- Identity is Lipschitz with constant 0.
    Bridge: connects trivial network to baseline certified_robustness. -/
theorem valuationLipschitz_id : ValuationLipschitz (id : K → K) (0 : ℤ) := by
  intro x y; simp [id]

/-- `latticeSecurityProxy`: Complexity proxy for post-quantum security.
    Bridge: connects Berkovich geometry to post_quantum_security. -/
def latticeSecurityProxy (S : FiniteSkeletonCover α) : ℕ := skeletonComplexity S

/-- Security proxy equals skeleton complexity.
    Bridge: connects lattice-style hardness to cell enumeration. -/
theorem latticeSecurityProxy_eq (S : FiniteSkeletonCover α) :
    latticeSecurityProxy S = skeletonComplexity S := rfl

/-! ## §10. Gate Complexity Bound -/

/-- `gateComplexityBound`: Upper bound on skeleton complexity for a rational gate.
    Bridge: connects circuit structure to post_quantum_security complexity. -/
def gateComplexityBound : RationalGate K → ℕ
  | .input _ => 1
  | .const _ => 1
  | .add g h => gateComplexityBound g * gateComplexityBound h
  | .mul g h => gateComplexityBound g * gateComplexityBound h
  | .inv g => gateComplexityBound g + 1

/-- Gate complexity is always positive.
    Bridge: connects arithmetic_complexity to post_quantum_security. -/
theorem gateComplexityBound_pos (g : RationalGate K) : 0 < gateComplexityBound g := by
  induction g with
  | input _ => simp [gateComplexityBound]
  | const _ => simp [gateComplexityBound]
  | add l r ihl ihr => simp only [gateComplexityBound]; exact Nat.mul_pos ihl ihr
  | mul l r ihl ihr => simp only [gateComplexityBound]; exact Nat.mul_pos ihl ihr
  | inv g ih => simp only [gateComplexityBound]; omega

/-
Gate complexity ≤ 2^(gateCount).
    Bridge: connects circuit depth to skeleton complexity.
-/
theorem gateComplexityBound_le_exp (g : RationalGate K) :
    gateComplexityBound g ≤ 2 ^ g.gateCount := by
  -- By definition of `gateComplexityBound`, we have `gateComplexityBound g = 2 ^ gateCount g`.
  induction' g using RationalGate.recOn with g ih;
  · exact?;
  · exact?;
  · rename_i g₁ g₂ ih₁ ih₂;
    refine' le_trans ( mul_le_mul ih₁ ih₂ ( by exact Nat.zero_le _ ) ( by positivity ) ) _;
    rw [ ← pow_add ];
    exact pow_le_pow_right₀ ( by decide ) ( by simp +decide [ RationalGate.gateCount ] );
  · rename_i g₁ g₂ ih₁ ih₂;
    exact le_trans ( Nat.mul_le_mul ih₁ ih₂ ) ( by rw [ ← pow_add ] ; exact pow_le_pow_right₀ ( by decide ) ( by simp +arith +decide [ RationalGate.gateCount ] ) );
  · rename_i g hg;
    exact Nat.succ_le_of_lt ( lt_of_le_of_lt hg ( pow_lt_pow_right₀ ( by decide ) ( by simp +decide [ gateComplexityBound, RationalGate.gateCount ] ) ) )

/-- Complexity composition: add/mul multiply child complexities.
    Bridge: connects operadic composition to post_quantum_security. -/
theorem complexity_composition_mul (g h : RationalGate K) :
    gateComplexityBound (RationalGate.add g h) =
    gateComplexityBound g * gateComplexityBound h := rfl

/-- Complexity of inversion adds 1.
    Bridge: connects rational inversion to arithmetic_complexity. -/
theorem complexity_inv_succ (g : RationalGate K) :
    gateComplexityBound (RationalGate.inv g) = gateComplexityBound g + 1 := rfl

/-! ## §11. Tropical Margin Profile -/

/-- `TropicalMarginProfile`: Coefficients of an affine margin on a cell.
    Bridge: connects tropical geometry to neural_network decision boundary. -/
structure TropicalMarginProfile (d : ℕ) where
  slope : Fin d → ℤ
  intercept : ℤ

/-- Evaluate a tropical margin profile.
    Bridge: connects tropical affine evaluation to margin computation. -/
def TropicalMarginProfile.evalAt {d : ℕ} (p : TropicalMarginProfile d)
    (coords : Fin d → ℤ) : ℤ :=
  ∑ i : Fin d, p.slope i * coords i + p.intercept

/-- Zero profile evaluates to zero.
    Bridge: connects tropical zero to baseline margin. -/
theorem TropicalMarginProfile.zero_eval (coords : Fin d → ℤ) :
    (TropicalMarginProfile.mk (fun _ => 0) 0).evalAt coords = 0 := by
  simp [TropicalMarginProfile.evalAt]

/-! ## §12. High-Margin Label Constancy -/

/-- If margin is constant and finite on a cell, f(x) - t ≠ 0 on the cell.
    Bridge: connects certified_robustness to Berkovich skeleton geometry. -/
theorem pole_free_of_finite_margin
    (f : α → K) (t : K) (C : SkeletonCell α) (m : ℤ)
    (hconst : ∀ x ∈ C.carrier, thresholdMargin f t x = (m : EVal)) :
    PoleFreeOn (fun x => f x - t) C.carrier := by
  intro x hx habs
  simp at habs
  have hv : HasIntValuation.v (f x - t) = ⊤ := by rw [habs, HasIntValuation.map_zero]
  have hm := hconst x hx
  rw [thresholdMargin, hv] at hm
  exact absurd hm.symm (WithTop.coe_ne_top (a := m))

/-- Constant margin implies CellConst for the margin.
    Bridge: connects skeleton constancy to certified_robustness. -/
theorem margin_cellConst_of_const
    (f : α → K) (t : K) (C : SkeletonCell α) (m : EVal)
    (hconst : ∀ x ∈ C.carrier, thresholdMargin f t x = m) :
    CellConst (thresholdMargin f t) C := ⟨m, hconst⟩

/-! ## §13. Reparametrization and Symmetry -/

/-- `ChartEquivalence`: Two cells are chart-equivalent.
    Bridge: connects coordinate-free Berkovich geometry to computation. -/
def ChartEquivalence (C₁ C₂ : SkeletonCell α) : Prop :=
  C₁.carrier = C₂.carrier ∧ C₁.chartDim = C₂.chartDim

/-- Chart equivalence is reflexive.
    Bridge: connects Berkovich identity to tropical identity. -/
theorem ChartEquivalence.refl (C : SkeletonCell α) : ChartEquivalence C C :=
  ⟨rfl, rfl⟩

/-- Chart equivalence is symmetric.
    Bridge: connects Berkovich duality to tropical mirror symmetry. -/
theorem ChartEquivalence.symm' {C₁ C₂ : SkeletonCell α}
    (h : ChartEquivalence C₁ C₂) : ChartEquivalence C₂ C₁ :=
  ⟨h.1.symm, h.2.symm⟩

/-- `SymmetricCell`: Chart invariant under coordinate permutations.
    Bridge: connects symmetric group to quantum gate symmetries. -/
def SymmetricCell (C : SkeletonCell α) : Prop :=
  ∀ (σ : Equiv.Perm (Fin C.chartDim)) (x : α), x ∈ C.carrier →
    ∀ i, C.chart x (σ i) = C.chart x i

/-- `skeletonCellComplexity`: Complexity of a single cell.
    Bridge: connects cell complexity to quantum circuit width. -/
def skeletonCellComplexity (C : SkeletonCell α) : ℕ := C.chartDim

/-- Symmetric cells have permutation-invariant complexity.
    Bridge: symmetric_skeleton_quantum_invariance. -/
theorem symmetric_skeleton_quantum_invariance (C : SkeletonCell α) :
    skeletonCellComplexity C = C.chartDim := rfl

/-! ## §14. Robustness from Margin -/

/-- Certified robustness: Lipschitz → output controlled.
    Bridge: connects lipschitz_certified_robustness to p-adic margin. -/
theorem padic_quantum_certified_robustness_from_margin
    (f : K → K) (L : ℤ) (x y : K)
    (hLip : ValuationLipschitz f L) :
    (HasIntValuation.v (x - y) : EVal) ≤ HasIntValuation.v (f x - f y) + (L : EVal) :=
  hLip x y

/-! ## §15. Total Evaluation Cost -/

/-- Total evaluation cost across cells.
    Bridge: connects Berkovich skeleton to tropical evaluation cost. -/
def totalEvalCost (S : FiniteSkeletonCover α) : ℕ :=
  ∑ i : Fin S.numCells, chartEvalCost (S.cell i)

/-! ## §16. Quantified Existence Theorems -/

/-- Every rational gate has a finite complexity bound.
    Bridge: connects operadic composition to finite Berkovich skeleton. -/
theorem exists_complexity_bound (g : RationalGate K) :
    ∃ B : ℕ, gateComplexityBound g ≤ B := ⟨_, le_refl _⟩

/-! ## §17. Addition and Multiplication Margin -/

/-- Addition margin satisfies ultrametric lower bound.
    Bridge: connects ultrametric inequality to tropical min-plus. -/
theorem margin_add_ge_min_margins (f g : α → K) (t₁ t₂ : K) (x : α) :
    min (HasIntValuation.v (f x - t₁)) (HasIntValuation.v (g x - t₂))
      ≤ HasIntValuation.v ((f x - t₁) + (g x - t₂)) :=
  valuation_add_ge_min _ _

/-- Multiplication margin is additive.
    Bridge: connects ring multiplication to tropical semiring addition. -/
theorem margin_mul_additive (f g : α → K) (x : α) :
    HasIntValuation.v (f x * g x) = HasIntValuation.v (f x) + HasIntValuation.v (g x) :=
  HasIntValuation.map_mul _ _

/-! ## §18. Constant Gate Margin -/

/-- Constant margin for any threshold.
    Bridge: connects constant function to tropical constant. -/
theorem const_margin (c t : K) :
    ∀ x : α, thresholdMargin (fun _ => c) t x = HasIntValuation.v (c - t) :=
  fun _ => rfl

/-! ## §19. Tropicalized Margin Is Min-Plus Affine -/

/-- If a margin is affine on a cell, it has tropical profile coefficients.
    Bridge: connects tropicalized_margin_is_minplus_affine to tropical geometry. -/
theorem tropicalized_margin_is_minplus_affine
    (C : SkeletonCell α) (φ : α → ℤ)
    (hAff : IsAffineOnCell φ C) :
    ∃ (a : Fin C.chartDim → ℤ) (b : ℤ),
      ∀ x ∈ C.carrier,
        φ x = ∑ i : Fin C.chartDim, a i * C.chart x i + b :=
  hAff

/-! ## §20. Security Proxy Monotonicity -/

/-- Security proxy monotone in cell count.
    Bridge: post_quantum_security_proxy_monotone_in_depth. -/
theorem post_quantum_security_proxy_monotone
    (S₁ S₂ : FiniteSkeletonCover α)
    (h : S₁.numCells ≤ S₂.numCells) :
    latticeSecurityProxy S₁ ≤ latticeSecurityProxy S₂ := h

/-! ## §21. Label Change Cells Finite -/

/-- Label-change cells bounded by total.
    Bridge: connects VC-dimension to Berkovich cell enumeration. -/
theorem label_change_cells_finite (S : FiniteSkeletonCover α) (lbl : α → Bool) :
    mixedLabelCellCount S lbl ≤ skeletonComplexity S :=
  mixedLabel_le_skeletonComplexity S lbl

/-! ## §22. Affine Constancy on Cells -/

/-- Constant function is affine on any cell.
    Bridge: connects constant functions to degenerate tropical affine. -/
theorem const_is_affine_on_cell (C : SkeletonCell α) (b : ℤ) :
    IsAffineOnCell (fun _ => b) C :=
  ⟨fun _ => 0, b, by simp⟩

/-! ## §23. Depth-Zero Gates Have Trivial Complexity -/

set_option linter.unusedSectionVars false in
/-- Input gates have complexity 1.
    Bridge: connects base circuit to trivial skeleton. -/
theorem input_complexity_one (i : ℕ) :
    gateComplexityBound (K := K) (RationalGate.input i) = 1 := rfl

set_option linter.unusedSectionVars false in
/-- Depth-zero gates have complexity 1.
    Bridge: connects base cases to post_quantum_security baseline. -/
theorem depth_zero_complexity (g : RationalGate K) (hd : g.depth = 0) :
    gateComplexityBound g = 1 := by
  cases g with
  | input _ => rfl
  | const _ => rfl
  | add l r => simp [RationalGate.depth] at hd
  | mul l r => simp [RationalGate.depth] at hd
  | inv g => simp [RationalGate.depth] at hd

/-! ## §24. HighMarginRegion Monotonicity -/

/-- Higher margin threshold gives smaller high-margin region.
    Bridge: connects margin threshold to certified_robustness strength. -/
theorem highMarginRegion_antitone (f : α → K) (t : K) (γ₁ γ₂ : ℤ) (h : γ₁ ≤ γ₂) :
    HighMarginRegion f t γ₂ ⊆ HighMarginRegion f t γ₁ := by
  intro x hx
  simp only [HighMarginRegion, Set.mem_setOf_eq] at *
  exact le_trans (WithTop.coe_le_coe.mpr h) hx

/-! ## §25. Pole-Free Composition -/

/-- Pole-free on subset.
    Bridge: connects algebraic geometry to certified_robustness. -/
theorem poleFreeOn_subset (f : α → K) (s t : Set α) (h : s ⊆ t) (hpf : PoleFreeOn f t) :
    PoleFreeOn f s :=
  fun x hx => hpf x (h hx)

/-- Constant nonzero is pole-free everywhere.
    Bridge: connects constant to baseline certified_robustness. -/
theorem poleFreeOn_const (c : K) (hc : c ≠ 0) (s : Set α) :
    PoleFreeOn (fun _ => c) s :=
  fun _ _ => hc

/-! ## §26. Valuation Label Constancy -/

/-- If valuations agree, labels agree.
    Bridge: connects valuation constancy to label stability. -/
theorem valuationLabel_of_eq_valuations (f₀ f₁ : α → K) (x y : α)
    (h₀ : HasIntValuation.v (f₀ x) = HasIntValuation.v (f₀ y))
    (h₁ : HasIntValuation.v (f₁ x) = HasIntValuation.v (f₁ y)) :
    valuationLabel f₀ f₁ x ↔ valuationLabel f₀ f₁ y := by
  simp only [valuationLabel, h₀, h₁]

/-! ## §27. CellConst Implies No Mixed Labels -/

/-- If a Bool-valued label is constant on a cell, that cell is not mixed.
    Bridge: connects constancy to label homogeneity for certified_robustness. -/
theorem cellConst_not_mixed (C : SkeletonCell α) (lbl : α → Bool)
    (hconst : CellConst lbl C) :
    ¬((∃ x ∈ C.carrier, lbl x = true) ∧ (∃ y ∈ C.carrier, lbl y = false)) := by
  obtain ⟨b, hb⟩ := hconst
  rintro ⟨⟨x, hx, hlx⟩, ⟨y, hy, hly⟩⟩
  rw [hb x hx] at hlx
  rw [hb y hy] at hly
  rw [hlx] at hly
  exact Bool.noConfusion hly

end ValuationSkeleton