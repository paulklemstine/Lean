/-
# Tropical Stone Duality via Weighted Consequence Semimodules

This file establishes a finite Stone/Priestley-style duality for **tropical
(min-plus) consequence structures**, where:
- The algebraic side is a **weighted entailment structure** — a tropical metric
  space encoding derivation costs between formulas.
- The semantic side is a **tropical spectrum** of feasible potentials (dual
  objects in shortest-path duality).

## Main Results

* `tropicalStoneEmbedding` — separation ⟹ injective evaluation into spectrum
* `strong_duality` — weighted entailment cost = extremal potential bound
* `spectrum_determines_consequence` — same feasible potentials ⟹ same costs
* `canonical_separates` — sufficient condition for separation
* `spectralSection_isBalanced` — evaluation preserves tropical structure
* `tropicalStoneDuality` — full representation as tropical spectral sections
* `canonical_achieves_max` — tight duality via canonical potentials

## Cross-Domain Connections

- **Shortest-path duality**: feasible potentials = LP duals of shortest paths
- **Tropical geometry**: prime theories = tropical points; costs = tropical functions
- **Algebraic logic**: weighted sequents generalize classical entailment
- **Optimization**: reconstruction = extracting irredundant constraints
-/

import Mathlib

open Function Set

namespace TropicalStoneDuality

/-! ## §1. The Tropical Semiring and Core Definitions -/

/-- The tropical semiring: natural numbers with infinity.
    `min` = tropical addition, `+` = tropical multiplication. -/
abbrev Trop := ℕ∞

/-- A weighted entailment structure on `n` formulas.
    `cost i j` = minimum cost of deriving formula `j` from formula `i`.
    Axioms: reflexivity (free self-derivation) and triangle inequality (transitivity). -/
structure WeightedEntailment (n : ℕ) where
  cost : Fin n → Fin n → Trop
  cost_refl : ∀ i, cost i i = 0
  cost_triangle : ∀ i j k, cost i k ≤ cost i j + cost j k

/-- A feasible potential: assigns proof costs compatible with entailment.
    The dual object in tropical shortest-path duality. -/
structure FeasiblePotential {n : ℕ} (W : WeightedEntailment n) where
  val : Fin n → Trop
  feasible : ∀ i j, val j ≤ val i + W.cost i j

/-- The tropical spectrum: the type of all feasible potentials. -/
abbrev SpecTrop {n : ℕ} (W : WeightedEntailment n) := FeasiblePotential W

/-- Evaluation map: sends each formula to its evaluation on the spectrum. -/
def evalMap {n : ℕ} {W : WeightedEntailment n} (i : Fin n) :
    SpecTrop W → Trop :=
  fun p => p.val i

/-- Separation: distinct formulas are distinguishable by some potential. -/
def IsSeparated {n : ℕ} (W : WeightedEntailment n) : Prop :=
  ∀ i j : Fin n, i ≠ j → ∃ p : SpecTrop W, p.val i ≠ p.val j

/-- An extremal (prime) feasible potential: cannot be decomposed as the
    pointwise minimum of two strictly different potentials. -/
def IsExtremal {n : ℕ} {W : WeightedEntailment n} (p : SpecTrop W) : Prop :=
  ∀ q r : SpecTrop W,
    (∀ i, p.val i = min (q.val i) (r.val i)) →
    (∀ i, p.val i = q.val i) ∨ (∀ i, p.val i = r.val i)

/-! ## §2. Canonical Potentials -/

/-- The canonical potential from source `s`: assigns to each formula `j` the
    shortest derivation cost from `s` to `j`. -/
def canonicalPotential {n : ℕ} (W : WeightedEntailment n) (s : Fin n) :
    SpecTrop W where
  val := W.cost s
  feasible := W.cost_triangle s

theorem canonicalPotential_self {n : ℕ} (W : WeightedEntailment n) (s : Fin n) :
    (canonicalPotential W s).val s = 0 := by
  simp [canonicalPotential, W.cost_refl]

/-- The zero potential (all costs = 0) is always feasible. -/
def zeroPotential {n : ℕ} (W : WeightedEntailment n) : SpecTrop W where
  val := fun _ => 0
  feasible := fun _ _ => by simp

/-! ## §3. The Tropical Stone Embedding Theorem -/

/-- **Tropical Stone Embedding Theorem.**
    If the weighted entailment is separated, the evaluation map is injective.
    Formulas are faithfully represented by their evaluation profiles on the
    tropical spectrum. -/
theorem tropicalStoneEmbedding {n : ℕ} {W : WeightedEntailment n}
    (hsep : IsSeparated W) :
    Injective (fun i : Fin n => evalMap (W := W) i) := by
  intro i j h
  by_contra hij
  obtain ⟨p, hp⟩ := hsep i j hij
  exact hp (congr_fun h p)

/-! ## §4. Strong Duality -/

/-- **Strong Tropical Duality.**
    The entailment cost is completely characterized by the spectrum:
    `cost i j ≤ k ↔ ∀ p, p.val j ≤ p.val i + k`.
    This is the tropical analogue of LP strong duality for shortest paths. -/
theorem strong_duality {n : ℕ} (W : WeightedEntailment n) (i j : Fin n) (k : Trop) :
    W.cost i j ≤ k ↔ ∀ p : SpecTrop W, p.val j ≤ p.val i + k := by
  constructor
  · intro h p
    calc p.val j ≤ p.val i + W.cost i j := p.feasible i j
      _ ≤ p.val i + k := by gcongr
  · intro h
    have h1 := h (canonicalPotential W i)
    simp only [canonicalPotential, W.cost_refl i, zero_add] at h1
    exact h1

/-- Strong duality equality form: cost = sup over normalized potentials. -/
theorem cost_eq_iSup_potential_sep {n : ℕ} (W : WeightedEntailment n) (i j : Fin n) :
    W.cost i j = ⨆ (p : SpecTrop W) (_ : p.val i = 0), p.val j := by
  apply le_antisymm
  · apply le_iSup_of_le (canonicalPotential W i)
    apply le_iSup_of_le (canonicalPotential_self W i)
    exact le_refl _
  · apply iSup_le; intro p
    apply iSup_le; intro hp
    have := p.feasible i j
    rw [hp, zero_add] at this
    exact this

/-! ## §5. Separation Results -/

/-- **Canonical Separation.**
    Distinct cost profiles ⟹ canonical potentials separate. -/
theorem canonical_separates {n : ℕ} (W : WeightedEntailment n)
    (h : ∀ i j : Fin n, i ≠ j → ∃ k, W.cost k i ≠ W.cost k j) :
    IsSeparated W := by
  intro i j hij
  obtain ⟨k, hk⟩ := h i j hij
  exact ⟨canonicalPotential W k, hk⟩

/-- Asymmetric costs imply separation. -/
theorem asymmetric_separates {n : ℕ} (W : WeightedEntailment n)
    (h : ∀ i j : Fin n, i ≠ j → W.cost i j ≠ 0 ∨ W.cost j i ≠ 0) :
    IsSeparated W := by
  apply canonical_separates
  intro i j hij
  obtain hc | hc := h i j hij
  · exact ⟨i, by simp [W.cost_refl]; exact Ne.symm hc⟩
  · exact ⟨j, by simp [W.cost_refl]; exact hc⟩

/-! ## §6. Spectrum Determines Consequence -/

/-- **Spectrum Determines Consequence.**
    Same feasible potentials ⟹ same cost matrices. The spectrum is a
    complete invariant of the consequence structure. -/
theorem spectrum_determines_consequence {n : ℕ} (W₁ W₂ : WeightedEntailment n)
    (h : ∀ v : Fin n → Trop,
      (∀ i j, v j ≤ v i + W₁.cost i j) ↔ (∀ i j, v j ≤ v i + W₂.cost i j)) :
    W₁.cost = W₂.cost := by
  ext i j
  apply le_antisymm
  · rw [strong_duality]
    intro p
    exact ((h p.val).mp p.feasible) i j
  · rw [strong_duality]
    intro p
    exact ((h p.val).mpr p.feasible) i j

/-! ## §7. Tropical Structural Preservation -/

/-- Pointwise min of two feasible potentials is feasible.
    The spectrum is closed under tropical addition. -/
noncomputable def specTrop_inf {n : ℕ} {W : WeightedEntailment n}
    (p q : SpecTrop W) : SpecTrop W where
  val j := min (p.val j) (q.val j)
  feasible a b := by
    rcases le_total (p.val a) (q.val a) with ha | ha
    · rw [min_eq_left ha]
      exact le_trans (min_le_left _ _) (p.feasible a b)
    · rw [min_eq_right ha]
      exact le_trans (min_le_right _ _) (q.feasible a b)

/-- Shifting a feasible potential by a constant preserves feasibility.
    The spectrum is closed under tropical scalar action. -/
noncomputable def specTrop_shift {n : ℕ} {W : WeightedEntailment n}
    (p : SpecTrop W) (c : Trop) : SpecTrop W where
  val j := c + p.val j
  feasible a b := by
    show c + p.val b ≤ (c + p.val a) + W.cost a b
    rw [add_assoc]
    gcongr
    exact p.feasible a b

/-- Evaluation commutes with tropical shift. -/
theorem eval_shift {n : ℕ} {W : WeightedEntailment n}
    (i : Fin n) (p : SpecTrop W) (c : Trop) :
    evalMap i (specTrop_shift p c) = c + evalMap i p := rfl

/-! ## §8. Balanced Sections and Representation -/

/-- A balanced section satisfies compatibility with shift and meet. -/
def IsBalancedSection {n : ℕ} {W : WeightedEntailment n}
    (f : SpecTrop W → Trop) : Prop :=
  (∀ p : SpecTrop W, ∀ c : Trop,
    f (specTrop_shift p c) = c + f p) ∧
  (∀ p q : SpecTrop W,
    f (specTrop_inf p q) = min (f p) (f q))

/-- Every evaluation map is balanced. -/
theorem spectralSection_isBalanced {n : ℕ} {W : WeightedEntailment n}
    (i : Fin n) : IsBalancedSection (evalMap (W := W) i) :=
  ⟨fun _ _ => rfl, fun _ _ => rfl⟩

/-- A spectral section: a function in the range of evaluation. -/
def IsSpectralSection {n : ℕ} {W : WeightedEntailment n}
    (f : SpecTrop W → Trop) : Prop :=
  ∃ i : Fin n, f = evalMap i

/-- The type of spectral sections. -/
def SpectralSections {n : ℕ} (W : WeightedEntailment n) :=
  { f : SpecTrop W → Trop // IsSpectralSection f }

/-- **Tropical Stone Duality (Equivalence form).**
    For a separated weighted entailment, evaluation gives an equivalence
    between formulas and spectral sections. -/
noncomputable def tropicalStoneDuality {n : ℕ} {W : WeightedEntailment n}
    (hsep : IsSeparated W) :
    Fin n ≃ SpectralSections W where
  toFun i := ⟨evalMap i, i, rfl⟩
  invFun f := f.2.choose
  left_inv i := by
    simp only
    have h := tropicalStoneEmbedding hsep
    apply h
    exact (Exists.choose_spec (⟨i, rfl⟩ : IsSpectralSection (evalMap (W := W) i))).symm
  right_inv f := by
    apply Subtype.ext
    simp only
    exact f.2.choose_spec.symm

/-! ## §9. Cost Recovery and Reconstruction -/

/-- Cost equals evaluation of canonical potential. -/
theorem cost_is_canonical_eval {n : ℕ} (W : WeightedEntailment n) (i j : Fin n) :
    W.cost i j = evalMap j (canonicalPotential W i) := rfl

/-- **Reconstruction Correctness**: the cost matrix is fully recoverable
    from the spectrum via canonical potentials. -/
theorem reconstruction_from_spectrum {n : ℕ} (W : WeightedEntailment n) :
    ∀ i j : Fin n, W.cost i j = evalMap j (canonicalPotential W i) :=
  fun _ _ => rfl

/-- **Tight Duality**: the canonical potential achieves the maximum separation.
    For any potential with `p(i) = 0`, we have `p(j) ≤ cost(i,j)`. -/
theorem canonical_achieves_max {n : ℕ} (W : WeightedEntailment n) (i j : Fin n) :
    ∀ p : SpecTrop W, p.val i = 0 → p.val j ≤ W.cost i j := by
  intro p hp
  have := p.feasible i j
  rw [hp, zero_add] at this
  exact this

/-- The canonical potential achieves equality in the duality. -/
theorem canonical_is_max {n : ℕ} (W : WeightedEntailment n) (i j : Fin n) :
    (canonicalPotential W i).val i = 0 ∧
    (canonicalPotential W i).val j = W.cost i j :=
  ⟨canonicalPotential_self W i, rfl⟩

/-! ## §10. Concrete Example: Three-Formula System -/

/-- Example: a three-formula weighted entailment.
    0 →(2)→ 1 →(3)→ 2, with derived 0 →(5)→ 2 by transitivity. -/
def threeFormulaExample : WeightedEntailment 3 where
  cost := ![
    ![0, 2, 5],
    ![⊤, 0, 3],
    ![⊤, ⊤, 0]]
  cost_refl := by
    intro ⟨i, hi⟩
    interval_cases i <;> simp [Matrix.cons_val_zero, Matrix.cons_val_one]
  cost_triangle := by
    intro ⟨i, hi⟩ ⟨j, hj⟩ ⟨k, hk⟩
    set_option linter.unnecessarySeqFocus false in
    interval_cases i <;> interval_cases j <;> interval_cases k <;>
      simp [Matrix.cons_val_zero, Matrix.cons_val_one] <;> norm_num

/-- The three-formula example is separated. -/
theorem threeFormula_separated : IsSeparated threeFormulaExample := by
  apply canonical_separates
  intro ⟨i, hi⟩ ⟨j, hj⟩ hij
  interval_cases i <;> interval_cases j <;>
    simp_all [threeFormulaExample, Matrix.cons_val_zero, Matrix.cons_val_one]
  all_goals
    exact ⟨⟨0, by omega⟩, by simp [Matrix.cons_val_zero]⟩

/-- Evaluation on the three-formula example is injective. -/
theorem threeFormula_embedding :
    Injective (fun i : Fin 3 => evalMap (W := threeFormulaExample) i) :=
  tropicalStoneEmbedding threeFormula_separated

/-! ## §11. Evaluation Lipschitz Property -/

/-- If `cost i j ≤ d`, then `eval(j)(p) ≤ eval(i)(p) + d` for all potentials. -/
theorem eval_lipschitz {n : ℕ} {W : WeightedEntailment n}
    (i j : Fin n) (d : Trop) (hd : W.cost i j ≤ d) :
    ∀ p : SpecTrop W, evalMap j p ≤ evalMap i p + d := by
  intro p
  calc evalMap j p = p.val j := rfl
    _ ≤ p.val i + W.cost i j := p.feasible i j
    _ ≤ p.val i + d := by gcongr

/-- Dual: evaluation bounds imply cost bounds. -/
theorem cost_from_eval_bound {n : ℕ} {W : WeightedEntailment n}
    (i j : Fin n) (d : Trop)
    (h : ∀ p : SpecTrop W, evalMap j p ≤ evalMap i p + d) :
    W.cost i j ≤ d :=
  (strong_duality W i j d).mpr h

/-! ## §12. Weighted Rule Basis -/

/-- A weighted entailment rule. -/
structure WRule (n : ℕ) where
  src : Fin n
  tgt : Fin n
  wt : ℕ

/-- A rule is valid for a weighted entailment. -/
def RuleValid {n : ℕ} (W : WeightedEntailment n) (r : WRule n) : Prop :=
  W.cost r.src r.tgt ≤ ↑r.wt

/-- Direct rules: the set of all finite-cost entailments. -/
def directRules {n : ℕ} (W : WeightedEntailment n) : Set (WRule n) :=
  { r | r.src ≠ r.tgt ∧ W.cost r.src r.tgt = ↑r.wt }

/-- Every direct rule is valid. -/
theorem directRule_valid {n : ℕ} (W : WeightedEntailment n) (r : WRule n)
    (hr : r ∈ directRules W) : RuleValid W r := by
  simp only [directRules, Set.mem_setOf_eq, RuleValid] at hr ⊢
  exact le_of_eq hr.2

/-! ## §13. Extremality of Canonical Potentials -/

/-- A canonical potential is extremal when no decomposition improves on it. -/
theorem canonical_extremal_of_unique {n : ℕ} {W : WeightedEntailment n}
    (s : Fin n)
    (huniq : ∀ q r : SpecTrop W,
      (∀ i, W.cost s i = min (q.val i) (r.val i)) →
      (∀ i, W.cost s i = q.val i) ∨ (∀ i, W.cost s i = r.val i)) :
    IsExtremal (canonicalPotential W s) := by
  intro q r h
  exact huniq q r (fun i => h i)

/-! ## §14. Functoriality: Morphisms of Weighted Entailments -/

/-- A morphism of weighted entailments: a cost-non-increasing map. -/
structure WMorphism {m n : ℕ} (W₁ : WeightedEntailment m) (W₂ : WeightedEntailment n) where
  toFun : Fin m → Fin n
  cost_le : ∀ i j, W₂.cost (toFun i) (toFun j) ≤ W₁.cost i j

/-- A morphism induces a pullback map on spectra (contravariantly). -/
def WMorphism.pullback {m n : ℕ} {W₁ : WeightedEntailment m} {W₂ : WeightedEntailment n}
    (f : WMorphism W₁ W₂) (p : SpecTrop W₂) : SpecTrop W₁ where
  val i := p.val (f.toFun i)
  feasible i j := by
    calc p.val (f.toFun j) ≤ p.val (f.toFun i) + W₂.cost (f.toFun i) (f.toFun j) :=
          p.feasible _ _
      _ ≤ p.val (f.toFun i) + W₁.cost i j := by gcongr; exact f.cost_le i j

/-- Pullback commutes with evaluation. -/
theorem pullback_eval {m n : ℕ} {W₁ : WeightedEntailment m} {W₂ : WeightedEntailment n}
    (f : WMorphism W₁ W₂) (i : Fin m) (p : SpecTrop W₂) :
    evalMap i (f.pullback p) = evalMap (f.toFun i) p := rfl

end TropicalStoneDuality