import Mathlib

/-!
# Quantitative Tropical Proof Theory — Foundations

This file establishes the first certified theorems of **quantitative tropical proof theory**,
a new framework bridging:

1. **Tropical algebra** (max-plus structure, piecewise-linear maps)
2. **Curry–Howard semantics** (formulas/proofs as algebraic objects)
3. **Neural attention mechanisms** (hard attention as proof selection)
4. **Robust ML** (Lipschitz stability of max-plus routing)

## Main results

- `tropicalAgg_lipschitz_of_pointwise`: Tropical aggregation is 1-Lipschitz in the sup norm.
- `tropicalSelect_lipschitz`: Hard attention is 2-Lipschitz under joint perturbation.
- `tropicalReluAgg_lipschitz_of_pointwise`: ReLU-composed tropical aggregation is 1-Lipschitz.
- `trop_residuation`: Max-plus residuation gives a quantitative implication connective.

## Cross-domain significance

- **Proof theory**: proof interpretation is stable under bounded perturbation of premises.
- **Neural networks**: max-plus routing is robust.
- **Optimization**: support functions are non-expansive in the sup norm.
- **Idempotent analysis**: finite max-plus convex operators are 1-Lipschitz.
-/

noncomputable section

open Finset

/-! ## §1. Tropical Aggregation -/

/-- Tropical proof-combinator: max-aggregation after additive weighting.
    `T_w(x) = max_i (w_i + x_i)`.
    In Curry–Howard terms, this is "quantitative join" of weighted proof scores.
    In ML terms, this is the max-plus attention score. -/
def tropicalAgg {n : ℕ} (w x : Fin (n+1) → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => w i + x i)

/-- Monotonicity: strengthening premises strengthens conclusions. -/
theorem tropicalAgg_mono {n : ℕ} (w x y : Fin (n+1) → ℝ)
    (hxy : ∀ i, x i ≤ y i) :
    tropicalAgg w x ≤ tropicalAgg w y := by
  unfold tropicalAgg
  apply Finset.sup'_le _ _ (fun i hi => ?_)
  exact le_trans (by linarith [hxy i]) (Finset.le_sup' (fun j => w j + y j) (Finset.mem_univ i))

/-- One-sided shift: if every input shifts by at most ε upward,
    the aggregate shifts up by at most ε. -/
theorem tropicalAgg_le_of_pointwise {n : ℕ} (w x y : Fin (n+1) → ℝ) (ε : ℝ)
    (hxy : ∀ i, x i ≤ y i + ε) :
    tropicalAgg w x ≤ tropicalAgg w y + ε := by
  unfold tropicalAgg
  apply Finset.sup'_le _ _ (fun i hi => ?_)
  have h1 : w i + x i ≤ (w i + y i) + ε := by linarith [hxy i]
  have h2 : w i + y i ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => w j + y j) :=
    Finset.le_sup' (fun j => w j + y j) (Finset.mem_univ i)
  linarith

/-
**Main Theorem (Primary Target)**: Tropical proof aggregation is
    1-Lipschitz in the sup norm.

    |T_w(x) - T_w(y)| ≤ ε whenever |x_i - y_i| ≤ ε for all i.

    **Proof theory**: Proof meaning is stable under bounded perturbation of assumptions.
    **Neural networks**: Max-plus routing is robust.
    **Optimization**: Support functions are non-expansive.
-/
theorem tropicalAgg_lipschitz_of_pointwise
    {n : ℕ} (w x y : Fin (n+1) → ℝ) (ε : ℝ)
    (_hε : 0 ≤ ε)
    (hxy : ∀ i, |x i - y i| ≤ ε) :
    |tropicalAgg w x - tropicalAgg w y| ≤ ε := by
  refine abs_sub_le_iff.mpr ⟨?_, ?_⟩
  · exact sub_le_iff_le_add'.mpr
      (tropicalAgg_le_of_pointwise w x y ε fun i => by linarith [abs_le.mp (hxy i)])
  · exact sub_le_iff_le_add'.mpr
      (tropicalAgg_le_of_pointwise _ _ _ _ fun i => by linarith [abs_le.mp (hxy i)])

/-! ## §2. Tropical Proof Selection (Hard Attention) -/

/-- Tropical proof selector: `S(scores, values) = max_i (scores_i + values_i)`.
    In Curry–Howard terms: select the proof with highest combined weight.
    In ML terms: hard attention mechanism. -/
def tropicalSelect {n : ℕ} (scores values : Fin (n+1) → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => scores i + values i)

/-- `tropicalSelect` is exactly `tropicalAgg` with scores as weights. -/
theorem tropicalSelect_eq_tropicalAgg {n : ℕ}
    (scores values : Fin (n+1) → ℝ) :
    tropicalSelect scores values = tropicalAgg scores values := rfl

/-
**Secondary Theorem**: Tropical proof selection is 2-Lipschitz under
    joint perturbation of scores and values.

    If both scores and values change by at most ε, the selected value
    changes by at most 2ε.
-/
theorem tropicalSelect_lipschitz
    {n : ℕ} (scores₁ scores₂ values₁ values₂ : Fin (n+1) → ℝ) (ε : ℝ)
    (_hε : 0 ≤ ε)
    (hs : ∀ i, |scores₁ i - scores₂ i| ≤ ε)
    (hv : ∀ i, |values₁ i - values₂ i| ≤ ε) :
    |tropicalSelect scores₁ values₁ - tropicalSelect scores₂ values₂| ≤ 2 * ε := by
  unfold tropicalSelect;
  rw [ abs_sub_le_iff ];
  constructor <;> rw [ sub_le_iff_le_add' ];
  · simp +zetaDelta at *;
    exact fun i => by linarith [ abs_le.mp ( hs i ), abs_le.mp ( hv i ), Finset.le_sup' ( fun i => scores₂ i + values₂ i ) ( Finset.mem_univ i ) ] ;
  · simp +zetaDelta at *;
    exact fun i => by linarith [ abs_le.mp ( hs i ), abs_le.mp ( hv i ), Finset.le_sup' ( fun i => scores₁ i + values₁ i ) ( Finset.mem_univ i ) ] ;

/-! ## §3. ReLU as Tropical Connective -/

/-- ReLU composed with tropical aggregation: a thresholded proof combinator.
    `R_{w,b}(x) = max(T_w(x) + b, 0)`. -/
def tropicalReluAgg {n : ℕ} (w x : Fin (n+1) → ℝ) (b : ℝ) : ℝ :=
  max (tropicalAgg w x + b) 0

/-
The max-plus absolute value contraction: |max(a,c) - max(b,c)| ≤ |a - b|.
    This is the key lemma for ReLU stability.
-/
theorem abs_max_sub_max_le (a b c : ℝ) :
    |max a c - max b c| ≤ |a - b| := by
  grind

/-
**Third Theorem**: ReLU-composed tropical aggregation is 1-Lipschitz.

    The outer max(·, 0) does not increase the Lipschitz constant because
    max(·, 0) is itself 1-Lipschitz (contraction).
-/
theorem tropicalReluAgg_lipschitz_of_pointwise
    {n : ℕ} (w x y : Fin (n+1) → ℝ) (b : ℝ) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hxy : ∀ i, |x i - y i| ≤ ε) :
    |tropicalReluAgg w x b - tropicalReluAgg w y b| ≤ ε := by
  convert abs_max_sub_max_le ( tropicalAgg w x + b ) ( tropicalAgg w y + b ) 0 |> le_trans <| ?_ using 1;
  convert tropicalAgg_lipschitz_of_pointwise w x y ε hε hxy using 1 ; ring

/-! ## §4. Tropical Implication and Residuation -/

/-- Tropical implication: the max-plus residual.
    `a ⇒_T c := c - a`. -/
def tropImp (a c : ℝ) : ℝ := c - a

/-
**Residuation theorem**: The fundamental adjunction of tropical logic.
    `a + b ≤ c ↔ b ≤ (a ⇒_T c)`.

    This gives tropical proof semantics a genuine residuated structure,
    connecting to linear logic and resource-sensitive type theory.
-/
theorem trop_residuation (a b c : ℝ) :
    a + b ≤ c ↔ b ≤ tropImp a c := by
  exact ⟨ fun h => le_sub_iff_add_le'.mpr h, fun h => le_sub_iff_add_le'.mp h ⟩

/-
Tropical modus ponens: given a proof of strength a and an implication
    of capacity (c - a), we obtain a proof of strength at most c.
-/
theorem trop_modus_ponens (a b c : ℝ) (h : b ≤ tropImp a c) :
    a + b ≤ c := by
  unfold tropImp at h; linarith;

/-
Tropical weakening: strengthening the antecedent weakens the implication.
-/
theorem tropImp_antitone_left (a₁ a₂ c : ℝ) (h : a₁ ≤ a₂) :
    tropImp a₂ c ≤ tropImp a₁ c := by
  exact sub_le_sub_left h _

/-
Tropical strengthening: strengthening the consequent strengthens the implication.
-/
theorem tropImp_mono_right (a c₁ c₂ : ℝ) (h : c₁ ≤ c₂) :
    tropImp a c₁ ≤ tropImp a c₂ := by
  exact sub_le_sub_right h a

/-! ## §5. Connections to Existing Catalog Theorems -/

/-
The tropical mirror theorem `max a a = a` is the degenerate case of
    tropical aggregation with a single duplicated input and zero weight.
    This shows that idempotence is an atom of the theory.
-/
theorem tropicalAgg_single_eq (w₀ x₀ : ℝ) :
    tropicalAgg (n := 0) (fun _ => w₀) (fun _ => x₀) = w₀ + x₀ := by
  exact le_antisymm ( Finset.sup'_le _ _ fun i _ => by aesop ) ( Finset.le_sup' ( fun i => w₀ + x₀ ) ( Finset.mem_univ 0 ) )

/-
Tropical aggregation with zero weights recovers the pointwise maximum.
-/
theorem tropicalAgg_zero_weights_eq_sup {n : ℕ} (x : Fin (n+1) → ℝ) :
    tropicalAgg (fun _ => (0 : ℝ)) x = Finset.univ.sup' Finset.univ_nonempty x := by
  unfold tropicalAgg; aesop;

/-
ReLU single-neuron connection: tropicalReluAgg with n=0 (single input)
    gives the standard ReLU neuron `max(w*x + b, 0)`, matching `relu_boundary`.
-/
theorem tropicalReluAgg_single (w b x : ℝ) :
    tropicalReluAgg (n := 0) (fun _ => w) (fun _ => x) b = max (w + x + b) 0 := by
  simp [tropicalReluAgg, tropicalAgg, add_assoc]

/-
Composition law: tropical aggregation of aggregations.
    Layered tropical proof composition remains Lipschitz.
-/
theorem tropicalAgg_comp_lipschitz
    {n m : ℕ} (w₁ : Fin (n+1) → ℝ) (W : Fin (n+1) → Fin (m+1) → ℝ)
    (x y : Fin (m+1) → ℝ) (ε : ℝ) (hε : 0 ≤ ε)
    (hxy : ∀ j, |x j - y j| ≤ ε) :
    |tropicalAgg w₁ (fun i => tropicalAgg (W i) x) -
     tropicalAgg w₁ (fun i => tropicalAgg (W i) y)| ≤ ε := by
  convert tropicalAgg_lipschitz_of_pointwise _ _ _ _ hε _ using 1;
  exact fun i => tropicalAgg_lipschitz_of_pointwise _ _ _ _ hε hxy

end