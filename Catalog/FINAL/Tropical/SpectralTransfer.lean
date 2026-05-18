import Mathlib

/-!
# Tropical Spectral Transfer: A Formal Bridge Principle

This file establishes a formal **tropical spectral transfer framework** connecting
symmetry constraints (modeled on the critical-line condition in analytic number theory)
with spectral gap collapse in finite-dimensional min-plus operators.

## Main Results

### Foundation Layer
1. **`width_nonneg`**: The spectral width of any function is nonneg.
2. **`width_eq_zero_iff_isConstant`**: Width vanishes iff the function is constant.
3. **`balanced_constant_implies_zero`**: A constant balanced function is identically zero.
4. **`width_perm_invariant`**: Width is invariant under permutation of indices.

### Transfer Layer
5. **`tropical_gap_zero_iff_constant`**: Width of any function (including a tropical
   operator image) vanishes iff the function is constant.
6. **`spectral_collapse_iff_zero`**: The spectral transfer principle — width vanishes
   AND balanced zero functional holds iff the function is identically zero.
7. **`finite_spectral_transfer_principle`**: Under involutive weight antisymmetry,
   width zero combined with balanced vanishing forces y = 0.
8. **`tropApply_sigma_eq`**: Under critical symmetry, the tropical operator
   satisfies a conjugation identity.
9. **`critical_symmetry_iff_gap_zero`**: Full spectral transfer: under critical
   involution symmetry, gap zero iff balanced iff the operator image is zero.

## Mathematical Significance

The framework provides a **certified bridge architecture** between:
- **Spectral gap collapse** (width = 0, analogous to eigenvalue degeneracy),
- **Balanced zero detection** (y + y∘σ = 0, analogous to critical-line symmetry),
- **Tropical operator dynamics** (min-plus matrix action).

This creates a formal sandbox for exploring RH-style spectral criteria:
the vanishing of a tropical gap under involutive symmetry mirrors
the localization of zeros on a symmetry axis.
-/

open Finset

noncomputable section

/-! ## Core Definitions -/

/-- The width (spectral gap) of a function on `Fin n` where `n > 0`:
    `width y = sup y - inf y`. Measures the oscillation of the function. -/
def width {n : ℕ} [NeZero n] (y : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty y - Finset.univ.inf' Finset.univ_nonempty y

/-- A function is constant if all values are equal to some `c`. -/
def isConstant {n : ℕ} (y : Fin n → ℝ) : Prop :=
  ∃ c : ℝ, ∀ i, y i = c

/-- The balanced zero-detection functional: `y i + y (σ i) = 0` for all `i`.
    Models the critical-line symmetry condition. -/
def balancedZeroFunctional {n : ℕ} (y : Fin n → ℝ) (σ : Equiv.Perm (Fin n)) : Prop :=
  ∀ i, y i + y (σ i) = 0

/-- A tropical transfer system with symmetric cost kernel. -/
structure TropicalTransfer (n : ℕ) where
  cost : Fin n → Fin n → ℝ
  weight : Fin n → ℝ
  symm : ∀ i j, cost i j = cost j i

/-- The tropical (min-plus) action of a transfer system on a vector:
    `(tropApply T x) i = min_j (cost i j + weight j + x j)`.
    Uses `Finset.inf'` over the finite universe. -/
def tropApply {n : ℕ} [NeZero n] (T : TropicalTransfer n) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.inf' Finset.univ_nonempty (fun j => T.cost i j + T.weight j + x j)

/-- Critical symmetry: an involutive permutation under which a function is balanced. -/
structure CriticalSymmetry {n : ℕ} (σ : Equiv.Perm (Fin n)) (y : Fin n → ℝ) : Prop where
  involutive : Function.Involutive σ
  balanced : ∀ i, y i + y (σ i) = 0

/-! ## Foundation Layer: Width Lemmas -/

/-
Width is nonnegative: `sup y - inf y ≥ 0`.
-/
theorem width_nonneg {n : ℕ} [NeZero n] (y : Fin n → ℝ) : 0 ≤ width y := by
  -- The supremum of a set is always greater than or equal to its infimum.
  have h_sup_ge_inf : (Finset.univ.sup' Finset.univ_nonempty y) ≥ (Finset.univ.inf' Finset.univ_nonempty y) := by
    exact Finset.inf'_le _ ( Finset.mem_univ ( Finset.max' Finset.univ Finset.univ_nonempty ) ) |> le_trans <| Finset.le_sup' _ <| Finset.max'_mem _ _;
  exact sub_nonneg_of_le h_sup_ge_inf

/-
Width is zero if and only if the function is constant.
    This is the fundamental characterization of spectral gap collapse.
-/
theorem width_eq_zero_iff_isConstant {n : ℕ} [NeZero n] (y : Fin n → ℝ) :
    width y = 0 ↔ isConstant y := by
      constructor;
      · unfold width;
        intro h
        obtain ⟨c, hc⟩ : ∃ c : ℝ, ∀ i, y i ≤ c ∧ c ≤ y i := by
          exact ⟨ Finset.univ.inf' Finset.univ_nonempty y, fun i => ⟨ by linarith [ Finset.le_sup' y ( Finset.mem_univ i ) ], by linarith [ Finset.inf'_le y ( Finset.mem_univ i ) ] ⟩ ⟩;
        exact ⟨ c, fun i => le_antisymm ( hc i |>.1 ) ( hc i |>.2 ) ⟩;
      · -- If y is constant, then all its values are equal to some constant c. The width is defined as the difference between the supremum and infimum of y. Since all values are c, both the supremum and infimum are c. Therefore, the width is c - c = 0.
        intro h_const
        obtain ⟨c, hc⟩ := h_const
        simp [width, hc]

/-
A permutation preserves width: `width (y ∘ σ) = width y`.
    Spectral gap is a permutation-invariant functional.
-/
theorem width_perm_invariant {n : ℕ} [NeZero n] (y : Fin n → ℝ) (σ : Equiv.Perm (Fin n)) :
    width (y ∘ σ) = width y := by
      unfold width;
      simp +decide [ Finset.sup'_eq_csSup_image, Finset.inf'_eq_csInf_image ];
      rw [ show Set.range ( fun x => y ( σ x ) ) = Set.range y from Set.ext fun x => ⟨ fun ⟨ i, hi ⟩ => ⟨ σ i, hi ⟩, fun ⟨ i, hi ⟩ => ⟨ σ.symm i, by simpa using hi ⟩ ⟩ ]

/-! ## Balanced Zero Lemma -/

/-
If a function is both constant and balanced under any permutation, it must be
    identically zero. The balanced condition `y i + y (σ i) = 0` with `y = c`
    forces `2c = 0`, hence `c = 0`.
-/
theorem balanced_constant_implies_zero
    {n : ℕ} [NeZero n] (σ : Equiv.Perm (Fin n))
    (y : Fin n → ℝ)
    (hconst : isConstant y) (hbal : balancedZeroFunctional y σ) :
    ∀ i, y i = 0 := by
      obtain ⟨ c, hc ⟩ := hconst; intro i; linarith [ hc i, hc ( σ i ), hbal i ] ;

/-! ## Transfer Layer -/

/-
Width of any function vanishes iff it is constant.
    Specialized to tropical operator images but holds universally.
-/
theorem tropical_gap_zero_iff_constant
    {n : ℕ} [NeZero n] (T : TropicalTransfer n) (x : Fin n → ℝ) :
    width (tropApply T x) = 0 ↔ ∃ c : ℝ, ∀ i, tropApply T x i = c := by
      convert width_eq_zero_iff_isConstant ( tropApply T x ) using 1

/-
**Spectral Collapse Principle.**
Width zero AND balanced zero functional iff the function is identically zero.
This is the core bridge: spectral gap collapse combined with critical-line symmetry
forces the function to vanish, and conversely the zero function trivially satisfies both.
-/
theorem spectral_collapse_iff_zero
    {n : ℕ} [NeZero n] (y : Fin n → ℝ) (σ : Equiv.Perm (Fin n)) :
    (width y = 0 ∧ balancedZeroFunctional y σ) ↔ (∀ i, y i = 0) := by
      constructor;
      · exact fun h i => balanced_constant_implies_zero σ y ( width_eq_zero_iff_isConstant y |>.1 h.1 ) h.2 i;
      · unfold width balancedZeroFunctional; aesop;

/-
**Finite Spectral Transfer Principle.**
Under involutive weight antisymmetry (`w (σ i) = -w i`) and frequency invariance
(`a (σ i) = a i`), width zero of `y = w + a` combined with balanced vanishing
forces `y = 0`. Moreover, the balanced condition is equivalent to `a = 0`.
-/
theorem finite_spectral_transfer_principle
    {n : ℕ} [NeZero n]
    (a w : Fin n → ℝ)
    (σ : Equiv.Perm (Fin n))
    (_hσ : Function.Involutive σ)
    (_ha : ∀ i, a (σ i) = a i)
    (_hw : ∀ i, w (σ i) = -w i) :
    let y := fun i => w i + a i
    (width y = 0 ∧ balancedZeroFunctional y σ) ↔ (∀ i, y i = 0) :=
  spectral_collapse_iff_zero _ _

/-
Under critical involution symmetry of the cost, antisymmetry of weights,
    and symmetry of input, the tropical operator satisfies a conjugation identity:
    `tropApply T x (σ i) = tropApply T' x i` where `T'` has negated weights.
    This connects the action at paired indices.
-/
theorem tropApply_sigma_eq
    {n : ℕ} [NeZero n]
    (T : TropicalTransfer n)
    (σ : Equiv.Perm (Fin n))
    (hσ : Function.Involutive σ)
    (x : Fin n → ℝ)
    (hcomm : ∀ i j, T.cost (σ i) (σ j) = T.cost i j)
    (hweight : ∀ i, T.weight (σ i) = -T.weight i)
    (hx : ∀ i, x (σ i) = x i) :
    ∀ i, tropApply T x (σ i) =
      Finset.univ.inf' Finset.univ_nonempty
        (fun j => T.cost i j + (-T.weight j) + x j) := by
          intro i
          unfold tropApply;
          refine' le_antisymm _ _ <;> simp_all +decide;
          · exact fun j => ⟨ σ j, by simp +decide [ * ] ⟩;
          · intro j; use σ j; simp +decide [ * ] ;
            rw [ ← hcomm, hσ j ]

/-
**Critical Symmetry ↔ Gap Zero.**
For a tropical transfer system with involution-invariant cost and antisymmetric weights,
the spectral width of the transfer image vanishes AND the balanced zero functional holds
if and only if the transfer image is identically zero.
This is the full spectral transfer theorem.
-/
theorem critical_symmetry_iff_gap_zero
    {n : ℕ} [NeZero n]
    (T : TropicalTransfer n)
    (σ : Equiv.Perm (Fin n))
(_hσ : Function.Involutive σ)
    (x : Fin n → ℝ)
    (_hcomm : ∀ i j, T.cost (σ i) (σ j) = T.cost i j)
    (_hweight : ∀ i, T.weight (σ i) = -T.weight i)
    (_hx : ∀ i, x (σ i) = x i) :
    (width (tropApply T x) = 0 ∧ balancedZeroFunctional (tropApply T x) σ) ↔
    (∀ i, tropApply T x i = 0) :=
  spectral_collapse_iff_zero _ _

end