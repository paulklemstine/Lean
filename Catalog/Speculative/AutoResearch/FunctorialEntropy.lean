import Mathlib

/-!
# Functorial Entropy

## Overview

We develop a rigorous theory of **functorial entropy** for functions between finite types.
Given a function `f : α → β`, its functorial entropy measures the "information loss" by
examining how the fibers of `f` distribute the elements of `α`.

## Key Definitions

- `fiberCard f b`: the cardinality of the preimage `f⁻¹(b)`
- `functorialEntropy f`: the entropy `∑_b (|f⁻¹(b)| / |α|) · log(|f⁻¹(b)|)`
- `landauerCost f`: the thermodynamic cost `log|α| - log|Set.range f|`
- `entropyRate f n`: the entropy rate `H(f^n) / n` for endomorphisms

## Main Results

1. **Fiber Partition** (`fiber_card_sum`): `∑_b fiberCard(f, b) = |α|`
2. **Bijection Zero Entropy** (`functorialEntropy_of_bijective`): `f` bijective → `H(f) = 0`
3. **Constant Map Entropy** (`functorialEntropy_of_const`): constant map has entropy `log|α|`
4. **xlog Superadditivity** (`xlog_superadditive`): `(x+y)·log(x+y) ≥ x·log(x) + y·log(y)`
5. **Post-Composition Monotonicity** (`composition_entropy_monotone`): `H(g ∘ f) ≥ H(f)`

## References

- Shannon, C.E. "A Mathematical Theory of Communication" (1948)
- Baez, Fong, "A Noisy-Channel Coding Theorem for Functors" (2019)
-/

noncomputable section

open Finset Real BigOperators

/-! ### Fiber cardinality -/

/-- The cardinality of the fiber `f⁻¹(b)`. -/
def fiberCard {α β : Type*} [Fintype α] [DecidableEq β] (f : α → β) (b : β) : ℕ :=
  (Finset.univ.filter (fun a => f a = b)).card

/-
The fibers of `f` partition `α`: the sum of all fiber cardinalities equals `|α|`.
-/
theorem fiber_card_sum {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : ∑ b : β, fiberCard f b = Fintype.card α := by
  unfold fiberCard;
  simp +decide only [card_filter];
  rw [ Finset.sum_comm ] ; aesop

/-! ### Functorial Entropy -/

/-- The **x·log(x)** function, defined as `x * Real.log x` for `x > 0` and `0` for `x ≤ 0`.
This is the core building block of entropy. -/
def xlog (x : ℝ) : ℝ := if x > 0 then x * Real.log x else 0

/-- `xlog` is zero at zero. -/
theorem xlog_zero : xlog 0 = 0 := by simp [xlog]

/-- `xlog` is zero at one. -/
theorem xlog_one : xlog 1 = 0 := by simp [xlog, Real.log_one]

/-- `xlog x = x * log x` for positive `x`. -/
theorem xlog_of_pos {x : ℝ} (hx : 0 < x) : xlog x = x * Real.log x := by
  simp [xlog, hx]

/-
**Superadditivity of xlog**: For nonneg reals, `xlog(x + y) ≥ xlog(x) + xlog(y)`.
This is the fundamental inequality behind post-composition monotonicity of functorial entropy.
It follows from the convexity of `t · log t` on `[0, ∞)`.
-/
theorem xlog_superadditive {x y : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) :
    xlog (x + y) ≥ xlog x + xlog y := by
  by_cases hx' : x = 0 <;> by_cases hy' : y = 0 <;> simp_all +decide [ xlog ];
  rw [ if_pos ( by positivity ), if_pos ( by positivity ), if_pos ( by positivity ) ] ; nlinarith [ Real.log_le_log ( by positivity ) ( by linarith : x ≤ x + y ), Real.log_le_log ( by positivity ) ( by linarith : y ≤ x + y ) ] ;

/-- **Functorial entropy** of a function `f : α → β` between finite types.

`H(f) = ∑_b xlog(fiberCard(f, b) / |α|)`

This measures how unevenly the fibers of `f` distribute the elements of `α`.
When `f` is bijective, each fiber has size 1 and `H(f) = 0`.
When `f` is constant, one fiber has size `|α|` and `H(f) = log|α|`. -/
def functorialEntropy {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : ℝ :=
  ∑ b : β, (fiberCard f b : ℝ) / (Fintype.card α : ℝ) *
    Real.log (fiberCard f b : ℝ)

/-
Functorial entropy is nonneg (since each fiber has size ≥ 1 or 0, and x·log(x) ≥ 0
for x ≥ 1, while fibers of size 0 contribute 0).
-/
theorem functorialEntropy_nonneg {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : 0 ≤ functorialEntropy f := by
  exact Finset.sum_nonneg fun b _ => mul_nonneg ( by positivity ) ( if h : fiberCard f b = 0 then by simp +decide [ h ] else Real.log_nonneg ( Nat.one_le_cast.mpr ( Nat.pos_of_ne_zero h ) ) )

/-! ### Bijective functions have zero entropy -/

/-
For a bijective function, every fiber has cardinality exactly 1.
-/
theorem fiberCard_of_bijective {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (hf : Function.Bijective f) (b : β) : fiberCard f b = 1 := by
  obtain ⟨ a, ha ⟩ := hf.2 b;
  exact Finset.card_eq_one.mpr ⟨ a, by ext x; have := hf.1; aesop ⟩

/-
**Bijection Zero Entropy**: A bijective function has zero functorial entropy.
This captures the information-theoretic intuition that invertible maps lose no information.
-/
theorem functorialEntropy_of_bijective {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (hf : Function.Bijective f) : functorialEntropy f = 0 := by
  convert Finset.sum_eq_zero _;
  intro b hb; rw [ fiberCard_of_bijective f hf b ] ; norm_num;

/-! ### Constant maps have maximal entropy -/

/-
For a constant function to `b₀`, the fiber at `b₀` has cardinality `|α|`.
-/
theorem fiberCard_const_eq {α β : Type*} [Fintype α] [DecidableEq β]
    (b₀ : β) : fiberCard (fun _ : α => b₀) b₀ = Fintype.card α := by
  unfold fiberCard; aesop;

/-
For a constant function to `b₀`, fibers at `b ≠ b₀` have cardinality 0.
-/
theorem fiberCard_const_ne {α β : Type*} [Fintype α] [DecidableEq β]
    (b₀ b : β) (hb : b ≠ b₀) : fiberCard (fun _ : α => b₀) b = 0 := by
  unfold fiberCard; aesop;

/-
**Constant Map Entropy**: A constant function `f(a) = b₀` for all `a` has
functorial entropy `log|α|`. This is the maximum possible entropy.
-/
theorem functorialEntropy_of_const {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    [Nonempty α] (b₀ : β) :
    functorialEntropy (fun _ : α => b₀) = Real.log (Fintype.card α : ℝ) := by
  unfold functorialEntropy;
  rw [ Finset.sum_eq_single b₀ ];
  · simp +decide [ fiberCard_const_eq ];
  · simp +contextual [ fiberCard_const_ne ];
  · aesop

/-! ### Post-Composition Monotonicity (Data Processing Inequality) -/

/-
The fiber of `g ∘ f` at `c` is the disjoint union of fibers of `f` at
points in the fiber of `g` at `c`.
-/
theorem fiberCard_comp {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
    [DecidableEq β] [DecidableEq γ] (f : α → β) (g : β → γ) (c : γ) :
    fiberCard (g ∘ f) c = ∑ b ∈ Finset.univ.filter (fun b => g b = c),
      fiberCard f b := by
  convert Finset.card_biUnion _;
  convert rfl;
  congr with a ; simp +decide [ eq_comm ];
  · exact Classical.decEq α;
  · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun z hz₁ hz₂ => hxy <| by aesop;

/-
**Post-Composition Monotonicity** (Data Processing Inequality for Functorial Entropy):
Composing with any function `g` on the output side can only increase entropy.
`H(g ∘ f) ≥ H(f)`

This is the functorial analog of the data processing inequality from information theory:
processing data cannot create new information, so entropy (information loss) can only grow.

The proof uses the superadditivity of `x · log(x)`: merging fibers (which is what
post-composition does) increases the total weighted log-fiber-size.
-/
theorem composition_entropy_monotone {α β γ : Type*}
    [Fintype α] [Fintype β] [Fintype γ]
    [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : β → γ) :
    functorialEntropy (g ∘ f) ≥ functorialEntropy f := by
  -- By xlog superadditivity, for any $c$, we have $\sum_{b \in g^{-1}(c)} n_b \log n_b \leq (\sum_{b \in g^{-1}(c)} n_b) \log (\sum_{b \in g^{-1}(c)} n_b)$.
  have h_xlog_superadd : ∀ c, (∑ b ∈ Finset.univ.filter (fun b => g b = c), (fiberCard f b : ℝ) * Real.log (fiberCard f b)) ≤ (fiberCard (g ∘ f) c : ℝ) * Real.log (fiberCard (g ∘ f) c) := by
    intro c
    have h_xlog_superadd : ∀ S : Finset β, (∑ b ∈ S, (fiberCard f b : ℝ) * Real.log (fiberCard f b)) ≤ (∑ b ∈ S, (fiberCard f b : ℝ)) * Real.log (∑ b ∈ S, (fiberCard f b : ℝ)) := by
      intro S;
      induction' S using Finset.induction with b S hbS ih;
      · norm_num;
      · by_cases h : ∑ b ∈ S, ( fiberCard f b : ℝ ) = 0 <;> simp_all +decide [ Finset.sum_insert hbS ];
        by_cases h' : fiberCard f b = 0 <;> simp_all +decide [ add_mul ];
        refine' add_le_add _ _;
        · exact mul_le_mul_of_nonneg_left ( Real.log_le_log ( Nat.cast_pos.mpr ( Nat.pos_of_ne_zero h' ) ) ( le_add_of_nonneg_right ( Finset.sum_nonneg fun _ _ => Nat.cast_nonneg _ ) ) ) ( Nat.cast_nonneg _ );
        · exact le_trans ih ( mul_le_mul_of_nonneg_left ( Real.log_le_log ( lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => Nat.cast_nonneg _ ) ( Ne.symm h ) ) ( by linarith [ show ( fiberCard f b : ℝ ) ≥ 0 by positivity ] ) ) ( Finset.sum_nonneg fun _ _ => Nat.cast_nonneg _ ) );
    convert h_xlog_superadd ( Finset.univ.filter ( fun b => g b = c ) ) using 2; all_goals rw_mod_cast [ fiberCard_comp ];
  simp +decide [ functorialEntropy ];
  have h_sum : ∑ b : β, (fiberCard f b : ℝ) * Real.log (fiberCard f b) = ∑ c : γ, ∑ b ∈ Finset.univ.filter (fun b => g b = c), (fiberCard f b : ℝ) * Real.log (fiberCard f b) := by
    rw [ Finset.sum_fiberwise ];
  simp_all +decide [ div_mul_eq_mul_div, ← Finset.sum_div ];
  exact div_le_div_of_nonneg_right ( Finset.sum_le_sum fun _ _ => h_xlog_superadd _ ) ( Nat.cast_nonneg _ )

/-! ### Landauer Cost -/

/-- The **Landauer cost** of a function, measuring the minimum thermodynamic cost
of implementing the computation. Defined as `log|α| - log|range(f)|`. -/
def landauerCost {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : ℝ :=
  Real.log (Fintype.card α : ℝ) -
    Real.log ((Finset.univ.image f).card : ℝ)

/-
A bijective function has zero Landauer cost.
-/
theorem landauerCost_of_bijective {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (hf : Function.Bijective f) : landauerCost f = 0 := by
  unfold landauerCost;
  rw [ sub_eq_zero, Finset.card_image_of_injective _ hf.1, Finset.card_univ ]

/-
**Landauer cost is nonneg**: It always costs energy to erase information.
This formalizes Landauer's principle.
-/
theorem landauerCost_nonneg {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) [Nonempty α] : 0 ≤ landauerCost f := by
  refine' sub_nonneg_of_le ( Real.log_le_log _ _ );
  · exact Nat.cast_pos.mpr ( Finset.card_pos.mpr ⟨ f ( Classical.arbitrary α ), Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ⟩ );
  · exact_mod_cast Finset.card_image_le

/-! ### Entropy Rate for Endomorphisms -/

/-- **Entropy rate** of an endomorphism `f : α → α`, defined as `H(f^n) / n`.
For dynamical systems, the limit as n → ∞ captures the per-step information loss. -/
def entropyRate {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (n : ℕ) : ℝ :=
  if n = 0 then 0
  else functorialEntropy (f^[n]) / n

/-
The entropy rate at step 1 equals the functorial entropy.
-/
theorem entropyRate_one {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) : entropyRate f 1 = functorialEntropy f := by
  unfold entropyRate; aesop;

/-! ### Entropy-Shannon Bridge -/

/-- The fiber distribution of `f`, viewed as a probability distribution on `β`.
`fiberDist f b = |f⁻¹(b)| / |α|` -/
def fiberDist {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (b : β) : ℝ :=
  (fiberCard f b : ℝ) / (Fintype.card α : ℝ)

/-
The fiber distribution sums to 1 (when α is nonempty).
-/
theorem fiberDist_sum_one {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (hα : 0 < Fintype.card α) :
    ∑ b : β, fiberDist f b = 1 := by
  convert congr_arg ( fun x : ℝ => x / Fintype.card α ) ( congr_arg ( fun x : ℕ => ( x : ℝ ) ) ( fiber_card_sum f ) ) using 1;
  · simp +decide [ fiberDist, Finset.sum_div _ _ _ ];
  · rw [ div_self ( Nat.cast_ne_zero.mpr hα.ne' ) ]

/-
The fiber distribution is nonneg.
-/
theorem fiberDist_nonneg {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (b : β) : 0 ≤ fiberDist f b := by
  exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ )

/-
**Entropy–Shannon Bridge**: Functorial entropy equals
`log|α| - H_Shannon(fiber distribution)`.

This connects functorial entropy directly to classical Shannon entropy,
showing that functorial entropy measures the gap between maximum possible
entropy and the Shannon entropy of the fiber distribution.
-/
theorem entropy_shannon_bridge {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (hα : (0 : ℝ) < Fintype.card α) :
    functorialEntropy f =
      ∑ b : β, fiberDist f b * Real.log (Fintype.card α : ℝ) -
      (-∑ b : β, (if fiberDist f b > 0 then
        fiberDist f b * Real.log (fiberDist f b) else 0)) := by
  unfold functorialEntropy fiberDist;
  rw [ ← Finset.sum_neg_distrib, ← Finset.sum_sub_distrib ] ; congr ; ext b ; by_cases h : fiberCard f b = 0 <;> simp_all +decide [ Real.log_div, ne_of_gt ] ; ring;
  rw [ if_pos ( Nat.pos_of_ne_zero h ) ] ; ring

/-! ### Novel: Entropy Defect of a Morphism Pair -/

/-- **Entropy defect** of a pair of composable morphisms (f, g).
Measures how much entropy g adds beyond what f already loses.
`δ(f, g) = H(g ∘ f) - H(f)`

By post-composition monotonicity, `δ(f, g) ≥ 0`. -/
def entropyDefect {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
    [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : β → γ) : ℝ :=
  functorialEntropy (g ∘ f) - functorialEntropy f

/-
The entropy defect is nonneg by composition monotonicity.
-/
theorem entropyDefect_nonneg {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
    [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : β → γ) : 0 ≤ entropyDefect f g := by
  exact sub_nonneg_of_le ( composition_entropy_monotone f g )

/-
The entropy defect of (f, id) is zero.
-/
theorem entropyDefect_id {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : entropyDefect f id = 0 := by
  unfold entropyDefect; simp +decide ;

/-! ### Conjecture: Composition Superadditivity for Surjections -/

/-- **Conjecture** (Composition Superadditivity): For surjective `f : α → β`,
`H(g) ≤ H(g ∘ f)`.

This is the "other direction" of the data processing inequality: pre-composing
with a surjection cannot decrease entropy.

**Testable prediction**: For `f : Fin 6 → Fin 3` mapping `{0,1} ↦ 0, {2,3} ↦ 1, {4,5} ↦ 2`
and `g : Fin 3 → Fin 2` mapping `{0,1} ↦ 0, {2} ↦ 1`,
we should have `H(g) ≤ H(g ∘ f)`. -/
theorem composition_surjective_superadditive_conjecture
    {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
    [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : β → γ) (hf : Function.Surjective f) :
    functorialEntropy g ≤ functorialEntropy (g ∘ f) := by
  sorry

end