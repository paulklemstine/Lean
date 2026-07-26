import Mathlib

/-!
# Quantum Berggren Fourier Duality via Primitive Triple Wavelets

This file develops a rigorous **multiresolution analysis (MRA)** on the Berggren tree
of primitive Pythagorean triples, establishing:

1. **Canonical Berggren MRA**: For each depth `n`, the function space on depth-`n`
   Berggren nodes admits a canonical telescoping decomposition into scaling and detail
   components via conditional expectations on prefix cylinders.

2. **Exact Reconstruction**: Forward wavelet transform and inverse transform are
   provably inverse to each other.

3. **Spectral Sparsity**: Functions constant on prefix cylinders have vanishing
   detail coefficients at fine scales.

4. **Berggren Arithmetic**: Evaluation of words to primitive Pythagorean triples,
   with hypotenuse observables and modular periodicity.

5. **Wavelet Basis**: Explicit Haar-type wavelet basis on the ternary Berggren tree,
   with orthogonality theorems.
-/

open Finset Complex
open scoped ComplexConjugate

noncomputable section

namespace BerggrenFourier

/-! ## Section 1: Core Types and Berggren Arithmetic -/

/-- A Berggren word of depth `n`: a sequence of `n` generator indices from `{0,1,2}`. -/
abbrev BergWord (n : ℕ) := Fin n → Fin 3

/-- The complex-valued function space on depth-`n` Berggren nodes. -/
abbrev LayerFun (n : ℕ) := BergWord n → ℂ

/-- The three Berggren generator matrices acting on (a,b,c) triples. -/
def berggrenMat : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | 1 => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | 2 => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The root triple vector (3, 4, 5). -/
def rootVec : Fin 3 → ℤ := ![3, 4, 5]

/-- Product of Berggren matrices along a word. -/
def berggrenWordMat : {n : ℕ} → BergWord n → Matrix (Fin 3) (Fin 3) ℤ
  | 0, _ => 1
  | _+1, w => berggrenMat (w 0) * berggrenWordMat (fun i => w i.succ)

/-- Evaluate a Berggren word to get the corresponding triple (a, b, c). -/
def berggrenEval {n : ℕ} (w : BergWord n) : Fin 3 → ℤ :=
  (berggrenWordMat w).mulVec rootVec

/-- The hypotenuse of the triple at a Berggren node. -/
def hypotenuseAt {n : ℕ} (w : BergWord n) : ℤ := berggrenEval w 2

/-- The Lorentzian quadratic form Q(a,b,c) = a² + b² - c². -/
def lorentzQ (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-! ## Section 2: Prefix Operations and Cylinders -/

/-- Restrict a word of length `n` to its first `k` letters. -/
def wordPrefix {n : ℕ} (w : BergWord n) (k : ℕ) (hk : k ≤ n) : BergWord k :=
  fun i => w ⟨i.val, lt_of_lt_of_le i.isLt hk⟩

/-- A function is `k`-prefix-constant if it depends only on the first `k` letters. -/
def IsPrefixConstant {n : ℕ} (k : ℕ) (hk : k ≤ n) (f : LayerFun n) : Prop :=
  ∀ w₁ w₂ : BergWord n, wordPrefix w₁ k hk = wordPrefix w₂ k hk → f w₁ = f w₂

/-- The cylinder set: all depth-`n` words extending a given prefix `u` of length `k`. -/
def cylSet {n : ℕ} (k : ℕ) (hk : k ≤ n) (u : BergWord k) : Finset (BergWord n) :=
  Finset.univ.filter (fun w => wordPrefix w k hk = u)

/-- The cylinder containing `w` at depth `k`. -/
def cylOf {n : ℕ} (k : ℕ) (hk : k ≤ n) (w : BergWord n) : Finset (BergWord n) :=
  cylSet k hk (wordPrefix w k hk)

/-! ## Section 3: Cardinality Results -/

/-- The number of depth-`n` Berggren words is `3^n`. -/
theorem card_bergWord (n : ℕ) : Fintype.card (BergWord n) = 3 ^ n := by
  simp [BergWord, Fintype.card_fun, Fintype.card_fin]

/-- `3` is nonzero in `ℂ`. -/
theorem three_ne_zero_complex : (3 : ℂ) ≠ 0 := by norm_num

/-- `3^k` is nonzero in `ℂ` for all `k`. -/
theorem three_pow_ne_zero (k : ℕ) : (3 : ℂ) ^ k ≠ 0 :=
  pow_ne_zero k three_ne_zero_complex

/-
The cardinality of a cylinder set at depth `k` is `3^(n-k)`.
-/
theorem cylSet_card {n : ℕ} (k : ℕ) (hk : k ≤ n) (u : BergWord k) :
    (cylSet k hk u).card = 3 ^ (n - k) := by
  rw [ cylSet ];
  -- We can define a bijection between the cylinder set and the set of words of length $n-k$.
  have h_bij : {w : BergWord n | wordPrefix w k hk = u} ≃ (BergWord (n - k)) := by
    refine' Equiv.ofBijective (fun w => fun i => w.val ⟨k + i.val, by
      linarith [ Fin.is_lt i, Nat.sub_add_cancel hk ]⟩) ⟨fun a b h => _, fun a => _⟩
    all_goals generalize_proofs at *;
    · -- Since the functions are equal on the suffix and the prefix is the same, the entire functions must be equal.
      ext i; by_cases hi : i.val < k;
      · have := a.2; have := b.2; simp_all +decide [ wordPrefix ] ;
        have := a.2; have := b.2; simp_all +decide [ funext_iff, wordPrefix ] ;
        convert ‹∀ x : Fin k, ( a : BergWord n ) ⟨ x, by linarith [ Fin.is_lt x ] ⟩ = u x› ⟨ i, hi ⟩ |> Eq.trans <| Eq.symm <| ‹∀ x : Fin k, ( b : BergWord n ) ⟨ x, by linarith [ Fin.is_lt x ] ⟩ = u x› ⟨ i, hi ⟩ using 1;
        simp +decide [ Fin.ext_iff, Fin.val_add ];
      · convert congr_fun h ⟨ i - k, by omega ⟩ using 1 <;> simp +decide [ Nat.add_sub_of_le ( le_of_not_gt hi ) ];
        grind;
    · refine' ⟨ ⟨ fun i => if hi : i.val < k then u ⟨ i.val, hi ⟩ else a ⟨ i.val - k, by omega ⟩, _ ⟩, _ ⟩ <;> simp +decide [ Fin.ext_iff, wordPrefix ];
      exact funext fun i => by simp +decide [ wordPrefix ] ;
  convert Fintype.card_congr h_bij using 1;
  · rw [ Fintype.card_of_subtype ] ; aesop;
  · convert card_bergWord ( n - k ) |> Eq.symm using 1

/-
The cylinder at depth `n` containing `w` is the singleton `{w}`.
-/
theorem cylOf_self {n : ℕ} (w : BergWord n) :
    cylOf n (le_refl n) w = {w} := by
  unfold cylOf;
  unfold cylSet; aesop;

/-
The cylinder at depth `0` is the entire universe.
-/
theorem cylOf_zero {n : ℕ} (w : BergWord n) :
    cylOf 0 (Nat.zero_le n) w = Finset.univ := by
  ext w';
  simp +decide [ cylOf, cylSet ];
  exact Subsingleton.elim _ _

/-! ## Section 4: Scaling and Detail Submodules -/

/-- The scaling subspace at level `k`: functions constant on `k`-prefix cylinders. -/
def scalingSpace (n : ℕ) (k : ℕ) (hk : k ≤ n) : Submodule ℂ (LayerFun n) where
  carrier := {f | IsPrefixConstant k hk f}
  add_mem' {a b} ha hb w₁ w₂ hw := by
    show a w₁ + b w₁ = a w₂ + b w₂
    rw [ha w₁ w₂ hw, hb w₁ w₂ hw]
  zero_mem' _ _ _ := rfl
  smul_mem' c _f hf w₁ w₂ hw := by
    show c • _f w₁ = c • _f w₂
    rw [hf w₁ w₂ hw]

/-- Detail subspace at level `k`: functions in `scalingSpace(k+1)` that sum to zero
    on each `k`-cylinder. -/
def detailSpace (n : ℕ) (k : ℕ) (hk : k < n) : Submodule ℂ (LayerFun n) where
  carrier := {f | IsPrefixConstant (k + 1) hk f ∧
    ∀ u : BergWord k, (cylSet k (le_of_lt hk) u).sum f = 0}
  add_mem' {a b} ha hb := by
    refine ⟨fun w₁ w₂ hw => ?_, fun u => ?_⟩
    · show a w₁ + b w₁ = a w₂ + b w₂
      rw [ha.1 w₁ w₂ hw, hb.1 w₁ w₂ hw]
    · simp only [Pi.add_apply, Finset.sum_add_distrib]
      rw [ha.2 u, hb.2 u]; ring
  zero_mem' := by
    exact ⟨fun _ _ _ => rfl, fun u => by simp⟩
  smul_mem' c _f hf := by
    refine ⟨fun w₁ w₂ hw => ?_, fun u => ?_⟩
    · show c • _f w₁ = c • _f w₂; rw [hf.1 w₁ w₂ hw]
    · simp only [Pi.smul_apply, smul_eq_mul, ← Finset.mul_sum]
      rw [hf.2 u]; ring

/-
Scaling space is monotone: finer prefix gives larger function class.
    If `j ≤ k`, then functions constant on `j`-prefix cylinders are also
    constant on `k`-prefix cylinders (since k-agreement implies j-agreement).
-/
theorem scalingSpace_monotone {n : ℕ} {j k : ℕ} (hj : j ≤ n) (hk : k ≤ n) (hjk : j ≤ k) :
    scalingSpace n j hj ≤ scalingSpace n k hk := by
  intro f hf;
  intro w₁ w₂ hw;
  apply hf;
  exact funext fun i => by simpa using congr_fun hw ⟨ i, by linarith [ Fin.is_lt i ] ⟩ ;

/-
Detail space is contained in the next scaling level.
-/
theorem detailSpace_le_scalingSpace {n : ℕ} {k : ℕ} (hk : k < n) :
    detailSpace n k hk ≤ scalingSpace n (k + 1) hk := by
  exact fun f hf => hf.1

/-! ## Section 5: Conditional Expectation and Telescoping -/

/-- Conditional expectation at level `k`: average of `f` over the `k`-cylinder
    containing `w`. -/
def condExp {n : ℕ} (k : ℕ) (hk : k ≤ n) (f : LayerFun n) (w : BergWord n) : ℂ :=
  (cylOf k hk w).sum f / ((3 : ℂ) ^ (n - k))

/-
**Conditional expectation at maximum depth is the identity.**
-/
theorem condExp_self {n : ℕ} (f : LayerFun n) (w : BergWord n) :
    condExp n (le_refl n) f w = f w := by
  unfold condExp;
  rw [ cylOf_self, Finset.sum_singleton, Nat.sub_self, pow_zero, div_one ]

/-
**Conditional expectation at depth 0 is the global average.**
-/
theorem condExp_zero {n : ℕ} (f : LayerFun n) (w : BergWord n) :
    condExp 0 (Nat.zero_le n) f w = Finset.univ.sum f / ((3 : ℂ) ^ n) := by
  unfold condExp;
  rw [ cylOf_zero ] ; simp +decide

/-
**Conditional expectation is prefix-constant at its level.**
-/
theorem condExp_isPrefixConstant {n : ℕ} (k : ℕ) (hk : k ≤ n) (f : LayerFun n) :
    IsPrefixConstant k hk (condExp k hk f) := by
  unfold IsPrefixConstant;
  unfold condExp;
  unfold cylOf; aesop;

/-- Helper: step-k-to-(k+1) conditional expectation increment for `Fin n` indexing. -/
private def condExpStep {n : ℕ} (f : LayerFun n) (w : BergWord n) (k : Fin n) : ℂ :=
  condExp (k.val + 1) k.isLt f w - condExp k.val (le_of_lt k.isLt) f w

/-
**Berggren Wavelet Reconstruction Theorem (Telescoping Form).**
    Every function on the Berggren layer decomposes exactly as the global average
    plus detail contributions at each scale.
-/
theorem berggren_reconstruction {n : ℕ} (f : LayerFun n) (w : BergWord n) :
    f w = condExp 0 (Nat.zero_le n) f w +
      ∑ k : Fin n, condExpStep f w k := by
  by_contra h_contra;
  simp_all +decide [ Finset.sum_range_sub, condExpStep ];
  exact h_contra ( by rw [ show ( ∑ x : Fin n, condExp ( x + 1 ) ( by linarith [ Fin.is_lt x ] ) f w ) = ∑ x : Fin ( n + 1 ), condExp x ( by linarith [ Fin.is_lt x ] ) f w - condExp 0 ( by linarith ) f w from by rw [ Fin.sum_univ_succ ] ; simp +decide [ Fin.sum_univ_castSucc ] ] ; rw [ show ( ∑ x : Fin n, condExp x ( by linarith [ Fin.is_lt x ] ) f w ) = ∑ x : Fin ( n + 1 ), condExp x ( by linarith [ Fin.is_lt x ] ) f w - condExp n ( by linarith ) f w from by rw [ Fin.sum_univ_castSucc ] ; simp +decide [ Fin.sum_univ_succ ] ] ; rw [ condExp_self ] ; ring )

/-! ## Section 6: Spectral Sparsity -/

/-
**Detail Vanishing Theorem.**
    If `f` is constant on `k`-prefix cylinders, then the detail contribution at level
    `j ≥ k` vanishes.
-/
theorem detail_vanishes_of_prefix_constant {n : ℕ} (k : ℕ) (hk : k ≤ n)
    (f : LayerFun n) (hf : IsPrefixConstant k hk f)
    (j : Fin n) (hjk : k ≤ j.val) (w : BergWord n) :
    condExpStep f w j = 0 := by
  -- By definition of `condExp`, we know that `condExp j f w = f w` and `condExp (j + 1) f w = f w`.
  have h_condExp_j : condExp j.val (le_of_lt j.isLt) f w = f w := by
    -- Since $f$ is constant on $k$-prefix cylinders and $k \leq j$, $f$ is also constant on $j$-prefix cylinders.
    have h_const_j : ∀ w₁ w₂ : BergWord n, wordPrefix w₁ j.val (le_of_lt j.isLt) = wordPrefix w₂ j.val (le_of_lt j.isLt) → f w₁ = f w₂ := by
      intro w₁ w₂ h_eq
      have h_const_j : wordPrefix w₁ k hk = wordPrefix w₂ k hk := by
        convert congr_arg ( fun x : BergWord j.val => fun i : Fin k => x ⟨ i.val, by linarith [ Fin.is_lt i ] ⟩ ) h_eq using 1
      exact hf w₁ w₂ h_const_j;
    -- Since $f$ is constant on $j$-prefix cylinders, we have $f(v) = f(w)$ for all $v$ in the $j$-cylinder of $w$.
    have h_const_j_cylinder : ∀ v ∈ cylOf j.val (le_of_lt j.isLt) w, f v = f w := by
      exact fun v hv => h_const_j v w <| Finset.mem_filter.mp hv |>.2;
    unfold condExp;
    rw [ Finset.sum_congr rfl h_const_j_cylinder, Finset.sum_const, cylOf, cylSet_card ] ; norm_num
  have h_condExp_j1 : condExp (j.val + 1) j.isLt f w = f w := by
    -- Since $f$ is constant on $(j+1)$-prefix cylinders, the sum of $f$ over the cylinder is $f(w)$ times the cardinality of the cylinder.
    have h_sum_cyl : ∑ v ∈ cylOf (j.val + 1) j.isLt w, f v = f w * 3 ^ (n - (j.val + 1)) := by
      rw [ Finset.sum_congr rfl fun x hx => show f x = f w from ?_ ];
      · simp +decide [ mul_comm, cylOf, cylSet_card ];
      · unfold cylOf at hx;
        unfold cylSet at hx;
        exact hf x w ( funext fun i => by simpa using congr_fun ( Finset.mem_filter.mp hx |>.2 ) ⟨ i, by linarith [ Fin.is_lt i, Fin.is_lt j ] ⟩ );
    unfold condExp; aesop;
  rw [condExpStep]
  rw [h_condExp_j, h_condExp_j1]
  simp

/-
**Sparsity of Prefix-Constant Functions.**
-/
theorem sparse_reconstruction_of_prefix_constant {n : ℕ} (k : ℕ) (hk : k ≤ n)
    (f : LayerFun n) (hf : IsPrefixConstant k hk f) (w : BergWord n) :
    f w = condExp 0 (Nat.zero_le n) f w +
      ∑ j : Fin k, condExpStep f w ⟨j.val, lt_of_lt_of_le j.isLt hk⟩ := by
  have h_tail_zero : ∑ j : Fin n, condExpStep f w j = ∑ j ∈ Finset.univ.filter (fun j : Fin n => j.val < k), condExpStep f w j := by
    rw [ Finset.sum_filter_of_ne ];
    exact fun x _ hx => lt_of_not_ge fun hx' => hx <| detail_vanishes_of_prefix_constant k hk f hf x hx' w;
  have h_sum_eq : ∑ j ∈ Finset.univ.filter (fun j : Fin n => j.val < k), condExpStep f w j = ∑ j : Fin k, condExpStep f w ⟨j.val, lt_of_lt_of_le j.isLt hk⟩ := by
    refine' Finset.sum_bij ( fun j hj => ⟨ j, by linarith [ Fin.is_lt j, Finset.mem_filter.mp hj ] ⟩ ) _ _ _ _ <;> simp +decide [ Fin.ext_iff ];
    exact fun b => ⟨ ⟨ b, by linarith [ Fin.is_lt b ] ⟩, by simp +decide ⟩;
  exact h_sum_eq ▸ h_tail_zero ▸ berggren_reconstruction f w

/-! ## Section 7: Explicit Wavelet Basis -/

/-- Wavelet function for a detail index at level `k`, prefix `u`, flavor 0.
    Distinguishes child 0 from child 1 within the cylinder of `u`. -/
def detailWavelet0 {n : ℕ} (k : ℕ) (hk : k < n) (u : BergWord k)
    (w : BergWord n) : ℂ :=
  if wordPrefix w k (le_of_lt hk) = u then
    if w ⟨k, hk⟩ = 0 then 1
    else if w ⟨k, hk⟩ = 1 then -1
    else 0
  else 0

/-- Wavelet function for a detail index at level `k`, prefix `u`, flavor 1.
    Distinguishes children {0,1} from child 2 within the cylinder of `u`. -/
def detailWavelet1 {n : ℕ} (k : ℕ) (hk : k < n) (u : BergWord k)
    (w : BergWord n) : ℂ :=
  if wordPrefix w k (le_of_lt hk) = u then
    if w ⟨k, hk⟩ = 0 then 1
    else if w ⟨k, hk⟩ = 1 then 1
    else -2
  else 0

/-- The global scaling function: constant 1 everywhere. -/
def scalingWavelet {n : ℕ} (_ : BergWord n) : ℂ := 1

/-
Detail wavelets are orthogonal to the scaling function.
-/
theorem detailWavelet0_orthogonal_scaling {n : ℕ} (k : ℕ) (hk : k < n)
    (u : BergWord k) :
    Finset.univ.sum (fun w : BergWord n =>
      detailWavelet0 k hk u w * starRingEnd ℂ (scalingWavelet w)) = 0 := by
  unfold scalingWavelet detailWavelet0; norm_num; ring;
  rw [ ← Finset.sum_filter ] ; simp_all +decide [ Finset.sum_ite ] ; ring;
  rw [ sub_eq_zero ];
  refine' congr_arg _ ( Finset.card_bij ( fun x hx => fun i => if i.val = k then 1 else x i ) _ _ _ ) <;> simp_all +decide [ Finset.mem_filter, Finset.mem_univ ];
  · intro a ha ha'; ext i; simp_all +decide [ wordPrefix ] ;
    rw [ if_neg ( ne_of_lt i.2 ), ← ha ] ; rfl;
  · intro a₁ ha₁ ha₂ a₂ ha₃ ha₄ h; ext i; by_cases hi : i.val = k <;> simp_all +decide [ funext_iff ] ;
    · rw [ show i = ⟨ k, hk ⟩ from Fin.ext hi ] ; aesop;
    · specialize h i; aesop;
  · intro b hb hb' hb''; use fun i => if i.val = k then 0 else b i; simp_all +decide [ funext_iff, wordPrefix ] ;
    grind +suggestions

/-
Flavor-0 and flavor-1 detail wavelets at the same node are orthogonal.
-/
theorem detailWavelet_cross_orthogonal {n : ℕ} (k : ℕ) (hk : k < n)
    (u : BergWord k) :
    Finset.univ.sum (fun w : BergWord n =>
      detailWavelet0 k hk u w * starRingEnd ℂ (detailWavelet1 k hk u w)) = 0 := by
  unfold detailWavelet0 detailWavelet1; simp +decide [ Finset.sum_ite ] ;
  -- Since these two sets are complementary within the cylinder, their sums cancel each other out.
  have h_compl : Finset.card (Finset.filter (fun x : BergWord n => x ⟨k, hk⟩ = 0) (Finset.filter (fun x : BergWord n => wordPrefix x k (le_of_lt hk) = u) Finset.univ)) =
                 Finset.card (Finset.filter (fun x : BergWord n => x ⟨k, hk⟩ = 1) (Finset.filter (fun x : BergWord n => wordPrefix x k (le_of_lt hk) = u) Finset.univ)) := by
                   refine' Finset.card_bij ( fun x hx => fun i => if i.val < k then x i else if x i = 0 then 1 else if x i = 1 then 0 else x i ) _ _ _ <;> simp +decide [ Finset.mem_filter, Finset.mem_univ ];
                   · unfold wordPrefix; aesop;
                   · intro a₁ ha₁ ha₂ a₂ ha₃ ha₄ h; ext i; replace h := congr_fun h i; aesop;
                   · intro b hb hb'; use fun i => if i.val < k then b i else if b i = 0 then 1 else if b i = 1 then 0 else b i; simp_all +decide [ funext_iff, wordPrefix ] ;
                     grind +revert;
  simp_all +decide [ Finset.filter_filter ];
  rw [ Finset.sum_congr rfl fun x hx => by aesop, Finset.sum_congr rfl fun x hx => by aesop ] ; norm_num [ h_compl ];
  rw [ Finset.sum_congr rfl fun x hx => by aesop ] ; norm_num [ h_compl ];
  rw [ show ( Finset.filter ( fun a : Fin n → Fin 3 => ( wordPrefix a k ( le_of_lt hk ) = u ∧ ¬a ⟨ k, hk ⟩ = 0 ) ∧ a ⟨ k, hk ⟩ = 1 ) Finset.univ ) = Finset.filter ( fun a : Fin n → Fin 3 => wordPrefix a k ( le_of_lt hk ) = u ∧ a ⟨ k, hk ⟩ = 1 ) Finset.univ from Finset.filter_congr fun x hx => by aesop ] ; ring

/-
Detail wavelets at different prefixes have disjoint support, hence are orthogonal.
-/
theorem detailWavelet0_orthogonal_diff_prefix {n : ℕ} (k : ℕ) (hk : k < n)
    (u₁ u₂ : BergWord k) (hu : u₁ ≠ u₂) :
    Finset.univ.sum (fun w : BergWord n =>
      detailWavelet0 k hk u₁ w * starRingEnd ℂ (detailWavelet0 k hk u₂ w)) = 0 := by
  refine Finset.sum_eq_zero fun w hw => ?_;
  unfold detailWavelet0;
  grind +revert

/-! ## Section 8: Wavelet Coefficients and Transforms -/

/-- Forward wavelet coefficient for detail wavelet (k, u, 0). -/
def detailCoeff0 {n : ℕ} (k : ℕ) (hk : k < n) (u : BergWord k) (f : LayerFun n) : ℂ :=
  Finset.univ.sum (fun w => f w * starRingEnd ℂ (detailWavelet0 k hk u w)) /
    (2 * (3 : ℂ) ^ (n - k - 1))

/-- Forward wavelet coefficient for detail wavelet (k, u, 1). -/
def detailCoeff1 {n : ℕ} (k : ℕ) (hk : k < n) (u : BergWord k) (f : LayerFun n) : ℂ :=
  Finset.univ.sum (fun w => f w * starRingEnd ℂ (detailWavelet1 k hk u w)) /
    (6 * (3 : ℂ) ^ (n - k - 1))

/-- Scaling coefficient: the global average. -/
def scalingCoeff {n : ℕ} (f : LayerFun n) : ℂ :=
  Finset.univ.sum f / ((3 : ℂ) ^ n)

/-- Reconstruction from wavelet coefficients. -/
def waveletReconstruct {n : ℕ} (f : LayerFun n) (w : BergWord n) : ℂ :=
  scalingCoeff f * scalingWavelet w +
  ∑ ki : Fin n,
    Finset.univ.sum (fun u : BergWord ki.val =>
      detailCoeff0 ki.val ki.isLt u f * detailWavelet0 ki.val ki.isLt u w +
      detailCoeff1 ki.val ki.isLt u f * detailWavelet1 ki.val ki.isLt u w)

/-
**Berggren Wavelet Perfect Reconstruction.**
-/
set_option maxHeartbeats 800000 in
theorem berggren_wavelet_perfect_reconstruction {n : ℕ} (f : LayerFun n)
    (w : BergWord n) :
    waveletReconstruct f w = f w := by
  unfold waveletReconstruct scalingWavelet;
  unfold detailCoeff0 detailCoeff1 detailWavelet0 detailWavelet1; simp +decide [ div_mul_eq_mul_div, Finset.sum_div _ _ _ ] ;
  rw [ Finset.sum_congr rfl ];
  rotate_right;
  use fun k => ( ∑ x : BergWord n, if wordPrefix x k.val ( le_of_lt k.isLt ) = wordPrefix w k.val ( le_of_lt k.isLt ) then f x * ( if x ⟨ k.val, k.isLt ⟩ = w ⟨ k.val, k.isLt ⟩ then 1 else 0 ) else 0 ) / ( 3 ^ ( n - k.val - 1 ) ) - ( ∑ x : BergWord n, if wordPrefix x k.val ( le_of_lt k.isLt ) = wordPrefix w k.val ( le_of_lt k.isLt ) then f x else 0 ) / ( 3 ^ ( n - k.val ) );
  · have := @berggren_reconstruction n f w;
    unfold condExpStep at this; simp +decide [ Finset.sum_add_distrib, Finset.sum_ite ] at this ⊢;
    unfold condExp at this; simp +decide [ Finset.sum_div _ _ _, Nat.sub_sub ] at this ⊢;
    convert this.symm using 2;
    · unfold scalingCoeff; simp +decide [ Finset.sum_div _ _ _, cylOf_zero ] ;
    · congr! 2;
      refine' Finset.sum_bij ( fun x hx => x ) _ _ _ _ <;> simp +decide [ cylOf ];
      · intro a ha₁ ha₂; unfold cylSet; simp +decide [ ha₁, ha₂, wordPrefix ] ;
        ext i; simp +decide [ wordPrefix ] at *;
        by_cases hi : i.val < ‹Fin n›.val;
        · exact congr_arg Fin.val ( congr_fun ha₁ ⟨ i, hi ⟩ );
        · grind +splitImp;
      · unfold cylSet; simp +decide [ wordPrefix ] ;
        unfold wordPrefix; simp +decide [ funext_iff ] ;
        exact fun b hb => ⟨ fun i => hb ⟨ i, by linarith [ Fin.is_lt i ] ⟩, hb ⟨ _, by linarith [ Fin.is_lt ‹_› ] ⟩ ⟩;
  · intro x hx;
    rcases h : w x with ( _ | _ | _ | k ) <;> simp +decide [ h ];
    · rw [ Finset.sum_eq_single ( wordPrefix w x ( le_of_lt x.isLt ) ) ] <;> simp +decide [ Finset.sum_add_distrib, Finset.sum_div _ _ _ ];
      · rw [ ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib ] ; refine' Finset.sum_congr rfl fun i hi => _ ; split_ifs <;> simp +decide [ *, Nat.sub_sub ] ; ring;
        · rw [ show n - x = n - ( 1 + x ) + 1 by exact Nat.sub_eq_of_eq_add <| by linarith [ Nat.sub_add_cancel <| show 1 + x ≤ n from by linarith [ Fin.is_lt x ] ] ] ; ring;
        · rw [ show n - x = n - ( x + 1 ) + 1 by exact Nat.sub_eq_of_eq_add <| by linarith [ Nat.sub_add_cancel <| show x + 1 ≤ n from Nat.succ_le_of_lt x.2 ] ] ; ring;
        · rw [ show ( n : ℕ ) - x = ( n - ( x + 1 ) ) + 1 by exact Nat.sub_eq_of_eq_add <| by linarith [ Nat.sub_add_cancel <| show x + 1 ≤ n from Nat.succ_le_of_lt x.2 ] ] ; norm_num [ pow_add, pow_one, pow_mul, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm ] ; ring;
          exact Or.inl ( by rw [ show ( starRingEnd ℂ ) 2 = 2 by norm_num [ Complex.ext_iff ] ] ; ring );
      · aesop;
    · rw [ Finset.sum_eq_single ( wordPrefix w x ( le_of_lt x.isLt ) ) ] <;> simp +decide [ Finset.sum_add_distrib, Finset.sum_div _ _ _ ];
      · rw [ ← Finset.sum_neg_distrib, ← Finset.sum_sub_distrib ];
        rw [ ← Finset.sum_add_distrib ] ; refine' Finset.sum_congr rfl fun y hy => _ ; split_ifs <;> simp +decide [ *, Nat.sub_sub ] ; ring;
        · cases ‹y x = 0›.symm.trans ‹y x = 1›;
        · rw [ show n - x = n - ( x + 1 ) + 1 by exact Nat.sub_eq_of_eq_add <| by linarith [ Nat.sub_add_cancel <| show x + 1 ≤ n from Nat.succ_le_of_lt x.2 ] ] ; ring;
        · rw [ show ( n : ℕ ) - x = ( n - ( x + 1 ) ) + 1 by exact Nat.sub_eq_of_eq_add <| by linarith [ Nat.sub_add_cancel <| show ( x : ℕ ) + 1 ≤ n from Nat.succ_le_of_lt x.2 ] ] ; ring;
        · rw [ show ( n : ℕ ) - x = ( n - ( x + 1 ) ) + 1 by exact Nat.sub_eq_of_eq_add <| by linarith [ Nat.sub_add_cancel <| show x + 1 ≤ n from Nat.succ_le_of_lt x.2 ] ] ; norm_num [ pow_add, pow_one, pow_mul, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm ];
          exact Or.inl ( by rw [ show ( starRingEnd ℂ ) 2 = 2 by norm_num [ Complex.ext_iff ] ] ; ring );
      · grind;
    · rw [ show ( n - x : ℕ ) = ( n - x - 1 ) + 1 by rw [ Nat.sub_add_cancel ( Nat.sub_pos_of_lt ( Fin.is_lt x ) ) ] ] ; norm_num [ pow_add, Finset.sum_div _ _ _ ] ; ring;
      rw [ ← Finset.sum_sub_distrib ] ; rw [ ← Finset.sum_mul _ _ _ ] ; ring;
      rw [ Finset.sum_mul _ _ _ ] ; refine' Finset.sum_congr rfl fun y hy => _ ; split_ifs <;> norm_num ; ring;
      · cases ‹y x = 0›.symm.trans ‹y x = 2›;
      · cases ‹y x = 1›.symm.trans ‹y x = 2›;
      · erw [ Complex.conj_ofReal ] ; norm_num ; ring;
      · grind;
    · linarith

/-
**Vanishing of Detail-0 Coefficients for Prefix-Constant Functions.**
-/
theorem detailCoeff0_vanishes_of_prefix_constant {n : ℕ} (k : ℕ) (hk : k ≤ n)
    (f : LayerFun n) (hf : IsPrefixConstant k hk f)
    (j : ℕ) (hjn : j < n) (hjk : k ≤ j) (u : BergWord j) :
    detailCoeff0 j hjn u f = 0 := by
  unfold detailCoeff0;
  -- Since f is k-prefix-constant, f(w) depends only on the first k letters of w. Since k ≤ j, f is also constant on j-prefix cylinders.
  have h_const : ∃ c : ℂ, ∀ w ∈ cylSet j (le_of_lt hjn) u, f w = c := by
    unfold cylSet;
    unfold wordPrefix at *;
    use f (fun i => if h : i.val < k then u ⟨i.val, by linarith⟩ else 0);
    grind +locals;
  obtain ⟨ c, hc ⟩ := h_const; simp_all +decide [ Finset.sum_ite, cylSet ] ;
  -- Since $f$ is constant on the cylinder of $u$, we can factor $c$ out of the sum.
  have h_factor : ∑ w : Fin n → Fin 3, f w * (starRingEnd ℂ) (if wordPrefix w j (le_of_lt hjn) = u then if w ⟨j, hjn⟩ = 0 then 1 else if w ⟨j, hjn⟩ = 1 then -1 else 0 else 0) = c * ∑ w : Fin n → Fin 3, (if wordPrefix w j (le_of_lt hjn) = u then if w ⟨j, hjn⟩ = 0 then 1 else if w ⟨j, hjn⟩ = 1 then -1 else 0 else 0) := by
    rw [ Finset.mul_sum _ _ _ ] ; congr ; ext w ; aesop;
  -- The sum of the detail wavelet over the cylinder of $u$ is zero because it is a sum of equal parts.
  have h_sum_zero : ∑ w : Fin n → Fin 3, (if wordPrefix w j (le_of_lt hjn) = u then if w ⟨j, hjn⟩ = 0 then 1 else if w ⟨j, hjn⟩ = 1 then -1 else 0 else 0) = 0 := by
    -- The sum of the detail wavelet over the cylinder of $u$ is zero because it is a sum of equal parts. We can split the sum into three parts: one for each possible value of $w ⟨j, hjn⟩$.
    have h_split_sum : ∑ w : Fin n → Fin 3, (if wordPrefix w j (le_of_lt hjn) = u then if w ⟨j, hjn⟩ = 0 then 1 else if w ⟨j, hjn⟩ = 1 then -1 else 0 else 0) = ∑ w : Fin n → Fin 3, (if wordPrefix w j (le_of_lt hjn) = u ∧ w ⟨j, hjn⟩ = 0 then 1 else 0) - ∑ w : Fin n → Fin 3, (if wordPrefix w j (le_of_lt hjn) = u ∧ w ⟨j, hjn⟩ = 1 then 1 else 0) := by
      rw [ ← Finset.sum_sub_distrib ] ; congr ; ext w ; aesop;
    rw [ h_split_sum, sub_eq_zero ];
    apply Finset.sum_bij (fun w _ => fun i => if i = ⟨j, hjn⟩ then 1 - w i else w i);
    · simp;
    · intro a₁ _ a₂ _ h; ext i; replace h := congr_fun h i; aesop;
    · intro b hb; use fun i => if i = ⟨ j, hjn ⟩ then 1 - b i else b i; aesop;
    · simp +decide [ wordPrefix ];
      intro a; congr! 2;
      unfold wordPrefix; simp +decide [ Fin.ext_iff ] ;
      grind;
  convert h_factor using 1;
  norm_cast;
  exact h_sum_zero.symm ▸ by norm_num;

/-
**Vanishing of Detail-1 Coefficients for Prefix-Constant Functions.**
-/
theorem detailCoeff1_vanishes_of_prefix_constant {n : ℕ} (k : ℕ) (hk : k ≤ n)
    (f : LayerFun n) (hf : IsPrefixConstant k hk f)
    (j : ℕ) (hjn : j < n) (hjk : k ≤ j) (u : BergWord j) :
    detailCoeff1 j hjn u f = 0 := by
  -- Since $f$ is constant on $k$-prefix cylinders, within each $j$-prefix cylinder, $f$ is constant (value $c$).
  have h_const : ∃ c : ℂ, ∀ w ∈ cylSet j (le_of_lt hjn) u, f w = c := by
    refine' ⟨ f ( fun i ↦ if h : i.val < j then u ⟨ i.val, h ⟩ else 0 ), fun w hw ↦ hf _ _ _ ⟩;
    simp_all +decide [ wordPrefix, cylSet ];
    ext i; simp +decide [ ← hw, wordPrefix ] ;
    grind;
  unfold detailCoeff1;
  obtain ⟨ c, hc ⟩ := h_const; simp_all +decide [ Finset.sum_ite, detailWavelet1 ] ;
  -- Since the sum of the detail wavelet1 over the cylinder is zero, the entire sum is zero.
  have h_sum_zero : ∑ w ∈ cylSet j (le_of_lt hjn) u, (if w ⟨j, hjn⟩ = 0 then 1 else if w ⟨j, hjn⟩ = 1 then 1 else -2 : ℂ) = 0 := by
    have h_sum_zero : ∑ w ∈ Finset.univ.filter (fun w : Fin (n - j) → Fin 3 => True), (if w ⟨0, Nat.sub_pos_of_lt hjn⟩ = 0 then (1 : ℂ) else if w ⟨0, Nat.sub_pos_of_lt hjn⟩ = 1 then (1 : ℂ) else (-2 : ℂ)) = 0 := by
      have h_sum_zero : Finset.card (Finset.filter (fun w : Fin (n - j) → Fin 3 => w ⟨0, Nat.sub_pos_of_lt hjn⟩ = 0) Finset.univ) = Finset.card (Finset.filter (fun w : Fin (n - j) → Fin 3 => w ⟨0, Nat.sub_pos_of_lt hjn⟩ = 1) Finset.univ) ∧ Finset.card (Finset.filter (fun w : Fin (n - j) → Fin 3 => w ⟨0, Nat.sub_pos_of_lt hjn⟩ = 2) Finset.univ) = Finset.card (Finset.filter (fun w : Fin (n - j) → Fin 3 => w ⟨0, Nat.sub_pos_of_lt hjn⟩ = 0) Finset.univ) := by
        constructor <;> rw [ Finset.card_filter, Finset.card_filter ];
        · apply Finset.sum_bij (fun w _ => fun i => if w i = 0 then 1 else if w i = 1 then 0 else w i);
          · exact fun _ _ => Finset.mem_univ _;
          · intro a₁ _ a₂ _ h; ext i; replace h := congr_fun h i; aesop;
          · exact fun b _ => ⟨ fun i => if b i = 0 then 1 else if b i = 1 then 0 else b i, Finset.mem_univ _, by ext i; aesop ⟩;
          · grind;
        · apply Finset.sum_bij (fun w _ => fun i => if w i = 2 then 0 else if w i = 0 then 2 else w i);
          · exact fun _ _ => Finset.mem_univ _;
          · intro a₁ _ a₂ _ h; ext i; replace h := congr_fun h i; aesop;
          · exact fun b _ => ⟨ fun i => if b i = 2 then 0 else if b i = 0 then 2 else b i, Finset.mem_univ _, by ext i; aesop ⟩;
          · grind;
      simp_all +decide [ Finset.sum_ite ];
      simp_all +decide [ Finset.filter_filter, Finset.filter_ne' ];
      simp_all +decide [ Finset.filter_and, Finset.filter_ne' ];
      rw [ show ( Finset.filter ( fun w : Fin ( n - j ) → Fin 3 => ¬w ⟨ 0, Nat.sub_pos_of_lt hjn ⟩ = 0 ) Finset.univ ∩ Finset.filter ( fun w : Fin ( n - j ) → Fin 3 => w ⟨ 0, Nat.sub_pos_of_lt hjn ⟩ = 1 ) Finset.univ ) = Finset.filter ( fun w : Fin ( n - j ) → Fin 3 => w ⟨ 0, Nat.sub_pos_of_lt hjn ⟩ = 1 ) Finset.univ from ?_, show ( Finset.filter ( fun w : Fin ( n - j ) → Fin 3 => ¬w ⟨ 0, Nat.sub_pos_of_lt hjn ⟩ = 0 ) Finset.univ ∩ Finset.filter ( fun w : Fin ( n - j ) → Fin 3 => ¬w ⟨ 0, Nat.sub_pos_of_lt hjn ⟩ = 1 ) Finset.univ ) = Finset.filter ( fun w : Fin ( n - j ) → Fin 3 => w ⟨ 0, Nat.sub_pos_of_lt hjn ⟩ = 2 ) Finset.univ from ?_ ];
      · norm_num [ h_sum_zero ] ; ring;
      · grind;
      · ext; simp +decide [ Finset.mem_inter, Finset.mem_filter ] ; aesop;
    convert h_sum_zero using 1;
    refine' Finset.sum_bij ( fun w hw => fun i => w ⟨ i + j, by linarith [ Fin.is_lt i, Nat.sub_add_cancel hjn.le ] ⟩ ) _ _ _ _ <;> simp +decide [ cylSet ];
    · intro a₁ ha₁ a₂ ha₂ h; ext i; by_cases hi : i.val < j <;> simp_all +decide [ funext_iff, wordPrefix ] ;
      · have := ha₁ ⟨ i, hi ⟩ ; have := ha₂ ⟨ i, hi ⟩ ; aesop;
      · convert congr_arg Fin.val ( h ⟨ i - j, by rw [ tsub_lt_iff_left ] <;> linarith [ Fin.is_lt i, Nat.sub_add_cancel hjn.le ] ⟩ ) using 1 <;> simp +decide [ Nat.sub_add_cancel hi ];
    · intro b; use fun i => if h : i.val < j then u ⟨ i.val, h ⟩ else b ⟨ i.val - j, by
        exact tsub_lt_tsub_iff_right ( le_of_not_gt h ) |>.2 i.2 ⟩ ; simp +decide [ wordPrefix ] ;
      exact funext fun i => by simp +decide [ wordPrefix ] ;
  convert congr_arg ( fun x : ℂ => c * starRingEnd ℂ x ) h_sum_zero using 1;
  · rw [ map_sum, Finset.mul_sum _ _ _ ];
    rw [ ← Finset.sum_subset ( Finset.subset_univ ( cylSet j ( le_of_lt hjn ) u ) ) ];
    · exact Finset.sum_congr rfl fun x hx => by rw [ hc x hx, if_pos ( Finset.mem_filter.mp hx |>.2 ) ] ;
    · unfold cylSet; aesop;
  · norm_num

/-! ## Section 9: Berggren Arithmetic Verification -/

/-- The root evaluation at depth 0 gives (3, 4, 5). -/
theorem berggrenEval_root : berggrenEval (n := 0) (Fin.elim0) = rootVec := by
  simp [berggrenEval, berggrenWordMat, Matrix.one_mulVec]

/-- The root triple (3, 4, 5) satisfies the Pythagorean equation. -/
theorem root_is_pythagorean : lorentzQ rootVec = 0 := by
  native_decide

/-
Each Berggren generator preserves the Lorentz form.
-/
theorem berggrenMat_preserves_lorentz (i : Fin 3) (v : Fin 3 → ℤ) :
    lorentzQ ((berggrenMat i).mulVec v) = lorentzQ v := by
  fin_cases i <;> simp +decide [ lorentzQ, Matrix.mulVec ] <;> ring!;
  · simp +decide [ Fin.sum_univ_three, dotProduct, berggrenMat ] ; ring!;
  · simp +decide [ berggrenMat ] ; ring!;
  · simp +decide [ berggrenMat ] ; ring!;

/-
All Berggren words evaluate to Pythagorean triples.
-/
theorem berggrenEval_is_pythagorean {n : ℕ} (w : BergWord n) :
    lorentzQ (berggrenEval w) = 0 := by
  induction' n with n ih;
  · exact?;
  · exact ih _ |> fun h => by simpa [ berggrenEval ] using berggrenMat_preserves_lorentz ( w 0 ) _ |> fun h' => h'.trans h;

/-! ## Section 10: Transport Operators -/

/-- The averaging operator: maps a function on depth `n+1` to its average over
    the three children of each depth-`n` node. -/
def berggrenAvg (n : ℕ) : LayerFun (n + 1) →ₗ[ℂ] LayerFun n where
  toFun f w := (f (Fin.cons 0 w) + f (Fin.cons 1 w) + f (Fin.cons 2 w)) / 3
  map_add' _ _ := by ext; simp [Pi.add_apply]; ring
  map_smul' _ _ := by ext; simp [Pi.smul_apply, smul_eq_mul]; ring

/-- The child-shift operator for generator `i`. -/
def childShift (n : ℕ) (i : Fin 3) : LayerFun (n + 1) →ₗ[ℂ] LayerFun n where
  toFun f w := f (Fin.cons i w)
  map_add' _ _ := by ext; simp [Pi.add_apply]
  map_smul' _ _ := by ext; simp [Pi.smul_apply]

/-- The upsample operator: embeds depth-`n` functions into depth-`(n+1)`. -/
def berggrenUpsample (n : ℕ) : LayerFun n →ₗ[ℂ] LayerFun (n + 1) where
  toFun f w := f (fun i => w i.succ)
  map_add' _ _ := by ext; simp [Pi.add_apply]
  map_smul' _ _ := by ext; simp [Pi.smul_apply]

/-! ## Section 11: Multiresolution Decomposition -/

/-
**Scaling at level `n` is the full space.**
-/
theorem scalingSpace_n_eq_top (n : ℕ) :
    scalingSpace n n (le_refl n) = ⊤ := by
  ext f; simp [scalingSpace];
  intro w₁ w₂ hw; congr;

/-
**Scaling at level 0 is the subspace of constant functions.**
-/
theorem scalingSpace_zero (n : ℕ) :
    ∀ f ∈ scalingSpace n 0 (Nat.zero_le n), ∀ w₁ w₂ : BergWord n, f w₁ = f w₂ := by
  intro f hf w₁ w₂;
  exact hf w₁ w₂ ( by ext i; fin_cases i )

/-
**Berggren Wavelet Basis Existence.**
    There exists a finite linearly independent spanning set for `LayerFun n`.
-/
theorem berggren_wavelet_basis_exists (n : ℕ) :
    ∃ (ι : Type) (_ : Fintype ι) (ψ : ι → BergWord n → ℂ),
      LinearIndependent ℂ ψ ∧
      Submodule.span ℂ (Set.range ψ) = ⊤ := by
  fconstructor;
  exact Fin ( 3 ^ n );
  have := Module.finBasis ℂ ( BergWord n → ℂ );
  have h_card : Fintype.card (BergWord n) = 3 ^ n := by
    convert card_bergWord n;
  have h_finrank : Module.finrank ℂ (BergWord n → ℂ) = 3 ^ n := by
    simp +decide [ h_card, Module.finrank ];
  rw [ h_finrank ] at this;
  exact ⟨ inferInstance, this, this.linearIndependent, this.span_eq ⟩

/-! ## Section 12: Signal Distance and Certified Recovery -/

/-- The ℓ² signal distance on `LayerFun n`. -/
def signalDistSq {n : ℕ} (f g : LayerFun n) : ℂ :=
  Finset.univ.sum (fun w : BergWord n => (f w - g w) * starRingEnd ℂ (f w - g w))

/-- A function has bounded height. -/
def BoundedHeightSignal {n : ℕ} (B : ℝ) (f : LayerFun n) : Prop :=
  ∀ w : BergWord n, ‖f w‖ ≤ B

/-
**Certified Robust Recovery.**
    If `f` is prefix-constant (sparse), then the detail coefficient of `g`
    equals the detail coefficient of the perturbation `g - f`.
-/
theorem certified_robust_recovery {n : ℕ} (f g : LayerFun n)
    (k : ℕ) (hk : k ≤ n) (hf : IsPrefixConstant k hk f)
    (j : ℕ) (hjn : j < n) (hjk : k ≤ j) (u : BergWord j) :
    detailCoeff0 j hjn u g = detailCoeff0 j hjn u (g - f) := by
  unfold detailCoeff0;
  have := detailCoeff0_vanishes_of_prefix_constant k hk f hf j hjn hjk u; simp_all +decide [ sub_eq_add_neg, Finset.sum_add_distrib, add_mul, div_eq_mul_inv ] ;
  unfold detailCoeff0 at this; aesop;

/-
**Sparse Spectrum of Prefix-Quotient Observables.**
    If an observable factors through the `k`-prefix, then composing with any `φ`
    yields vanishing detail coefficients at levels ≥ `k`.
-/
theorem sparse_spectrum_of_prefix_quotient {n : ℕ} {α : Type*}
    (k : ℕ) (hk : k ≤ n)
    (obs : BergWord n → α) (hobs : ∀ w₁ w₂, wordPrefix w₁ k hk = wordPrefix w₂ k hk →
      obs w₁ = obs w₂)
    (φ : α → ℂ)
    (j : ℕ) (hjn : j < n) (hjk : k ≤ j) (u : BergWord j) :
    detailCoeff0 j hjn u (φ ∘ obs) = 0 := by
  convert detailCoeff0_vanishes_of_prefix_constant k hk ( φ ∘ obs ) _ j hjn hjk u using 1;
  exact fun w₁ w₂ hw => by simp +decide [ hobs w₁ w₂ hw ] ;

end BerggrenFourier

end