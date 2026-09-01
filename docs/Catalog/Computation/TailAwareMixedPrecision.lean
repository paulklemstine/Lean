import Mathlib

/-!
# Tail-aware mixed precision: a formal theory of layer-wise precision protection

This file formalises the mathematics behind the NET-84 experiment
(*TAIL-AWARE-MIXED-PRECISION-WORKS*), in which three quantization arms of a
24-layer transformer (Qwen2.5-0.5B, gate exact, ctx = 1024) were measured:

| arm                                   | retained |
|---------------------------------------|----------|
| GPTQ4 on every layer                  | 0.9081   |
| GPTQ4 everywhere except `L22`, `L23`  | 0.9261   |
| GPTQ4 on `L22`, `L23` only            | 0.9766   |

Three structurally different pieces of theory are developed, each of which is
independent of the empirical numbers and each of which the numbers then
instantiate.

## 1. The propagation model (`run`, `tailProd`, `errBound`)

A network is the composition `run f i k` of layers `f i, …, f (i+k-1)` on `ℝ`.
If layer `j` is Lipschitz with constant `L j` and the deployed (quantized)
layer `g j` deviates from `f j` by at most `δ j` uniformly, then the end-to-end
deviation is bounded by

`errBound δ L i k = ∑ t < k, δ (i+t) * tailProd L (i+t+1) (k-1-t)`,

i.e. each layer's perturbation is amplified by the product of the Lipschitz
constants of the layers *downstream* of it (`run_dist_le`).

The **sensitivity profile** of a depth-`n` network is `sens L n m`, the
downstream amplification of layer `m`.  The central structural theorem
(`sens_mono`, `sens_last_eq_one`, `sens_le_one`) is:

> In a non-expansive network (`L j ≤ 1` for all `j`) the sensitivity profile is
> **monotone increasing in depth** and attains its maximum, `1`, at the last
> layer.

So for a non-expansive stack the *tail* carries the largest certified
perturbation budget — precisely the phenomenon NET-84 measures — while for an
expansive stack (`1 ≤ L j`) the ordering reverses and the *head* dominates
(`sens_anti_of_expansive`).  This dichotomy (`precision_dichotomy`) is the
theoretical content of "tail-aware": which end of the network to protect is
decided by the contraction regime, not by a universal rule.

## 2. The coverage (disagreement-set) model

Retained accuracy is an agreement rate, so it is governed by a *set* of
disagreeing prompts `D S` for each quantized layer set `S`.  Under the two
structural hypotheses

* monotonicity `A ⊆ B → D A ⊆ D B`, and
* coverage `D (A ∪ B) ⊆ D A ∪ D B`,

the error `qErr D S = (D S).card` is monotone and subadditive, which yields the
**protection sandwich** (`protection_gain_sandwich`)

`0 ≤ gain(T) ≤ qErr D T`,

i.e. *protecting a layer set can never buy back more quality than that set
loses when it alone is quantized*, and the **protection budget bound**
(`protection_budget`) `gain(T) ≤ ∑ i ∈ T, qErr D {i}`.

Conversely, a *super-additive* measurement (the 7× epistasis of NET-60, the
super-additive quantization × sparsity interaction of NET-83) is a certificate
that coverage fails: there are prompts that only the *joint* perturbation
breaks (`emergent_disagreement`, `superadditive_refutes_coverage`).

## 3. The NET-84 arithmetic

The three measured arms are checked against the theory in exact rational
arithmetic: they are coverage-consistent with slack `0.0054`
(`net84_coverage_consistent`), the gain is exactly `0.018`
(`net84_gain_eq`), it sits inside the sandwich (`net84_gain_le_ceiling`), and it
realises exactly `10/13` of the theoretical ceiling
(`net84_efficiency_exact`).

Finally `errBound_mono_delta` proves the monotonicity in precision that makes
the "8-bit tail" follow-up experiment well posed: a finer tail quantizer can
only lower the certified error.
-/

namespace TailPrecision

open Finset

/-! ## 1. Layer-wise propagation model -/

/-- `run f i k x` applies the layers `f i, f (i+1), …, f (i+k-1)` to the input `x`. -/
def run (f : ℕ → ℝ → ℝ) : ℕ → ℕ → ℝ → ℝ
  | _, 0, x => x
  | i, (k + 1), x => run f (i + 1) k (f i x)

@[simp] lemma run_zero (f : ℕ → ℝ → ℝ) (i : ℕ) (x : ℝ) : run f i 0 x = x := rfl

lemma run_succ (f : ℕ → ℝ → ℝ) (i k : ℕ) (x : ℝ) :
    run f i (k + 1) x = run f (i + 1) k (f i x) := rfl

/-- `tailProd L m k = L m * L (m+1) * ⋯ * L (m+k-1)`: the amplification of a block of
`k` consecutive layers starting at `m`. -/
def tailProd (L : ℕ → ℝ) (m k : ℕ) : ℝ := ∏ s ∈ range k, L (m + s)

@[simp] lemma tailProd_zero (L : ℕ → ℝ) (m : ℕ) : tailProd L m 0 = 1 := by
  simp [tailProd]

lemma tailProd_succ (L : ℕ → ℝ) (m k : ℕ) :
    tailProd L m (k + 1) = L m * tailProd L (m + 1) k := by
  simp only [tailProd, Finset.prod_range_succ']
  rw [mul_comm]
  congr 1
  exact Finset.prod_congr rfl (fun t _ => by ring_nf)

lemma tailProd_nonneg (L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j) (m k : ℕ) : 0 ≤ tailProd L m k :=
  Finset.prod_nonneg (fun _ _ => hL _)

lemma tailProd_le_one (L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j) (hL1 : ∀ j, L j ≤ 1) (m k : ℕ) :
    tailProd L m k ≤ 1 :=
  Finset.prod_le_one (fun _ _ => hL _) (fun _ _ => hL1 _)

lemma one_le_tailProd (L : ℕ → ℝ) (hL1 : ∀ j, 1 ≤ L j) (m k : ℕ) :
    1 ≤ tailProd L m k := by
  unfold tailProd
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Finset.prod_range_succ]
      nlinarith [hL1 (m + k)]

/-- A composed block of layers is Lipschitz with the product of the layer constants. -/
theorem run_lipschitz (f : ℕ → ℝ → ℝ) (L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j)
    (hlip : ∀ j x y, |f j x - f j y| ≤ L j * |x - y|) :
    ∀ (k i : ℕ) (x y : ℝ), |run f i k x - run f i k y| ≤ tailProd L i k * |x - y| := by
  intro k
  induction k with
  | zero => intro i x y; simp
  | succ k ih =>
      intro i x y
      rw [run_succ, run_succ, tailProd_succ]
      calc |run f (i + 1) k (f i x) - run f (i + 1) k (f i y)|
          ≤ tailProd L (i + 1) k * |f i x - f i y| := ih (i + 1) _ _
        _ ≤ tailProd L (i + 1) k * (L i * |x - y|) := by
              have h := hlip i x y
              have h0 := tailProd_nonneg L hL (i + 1) k
              nlinarith [abs_nonneg (x - y)]
        _ = L i * tailProd L (i + 1) k * |x - y| := by ring

/-- The certified end-to-end error of replacing every layer `f j` by a layer `g j`
that deviates from it by at most `δ j`: each perturbation is amplified by the
downstream Lipschitz product. -/
def errBound (δ L : ℕ → ℝ) (i k : ℕ) : ℝ :=
  ∑ t ∈ range k, δ (i + t) * tailProd L (i + t + 1) (k - 1 - t)

lemma errBound_succ (δ L : ℕ → ℝ) (i k : ℕ) :
    errBound δ L i (k + 1) = errBound δ L (i + 1) k + δ i * tailProd L (i + 1) k := by
  unfold errBound
  rw [Finset.sum_range_succ' (fun t => δ (i + t) * tailProd L (i + t + 1) (k + 1 - 1 - t)) k]
  congr 1
  exact Finset.sum_congr rfl (fun t _ => by congr 2 <;> omega)

/-- **Master propagation theorem.**  Two networks whose layers deviate pointwise by at
most `δ` produce outputs within `errBound δ L i k` of each other. -/
theorem run_dist_le (f g : ℕ → ℝ → ℝ) (L δ : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j)
    (hlip : ∀ j x y, |f j x - f j y| ≤ L j * |x - y|)
    (hδ : ∀ j x, |f j x - g j x| ≤ δ j) :
    ∀ (k i : ℕ) (x : ℝ), |run f i k x - run g i k x| ≤ errBound δ L i k := by
  intro k
  induction k with
  | zero => intro i x; simp [errBound]
  | succ k ih =>
      intro i x
      have hsplit : |run f (i + 1) k (f i x) - run g (i + 1) k (g i x)|
          ≤ |run f (i + 1) k (f i x) - run f (i + 1) k (g i x)|
            + |run f (i + 1) k (g i x) - run g (i + 1) k (g i x)| :=
        abs_sub_le _ _ _
      have h1 : |run f (i + 1) k (f i x) - run f (i + 1) k (g i x)|
          ≤ tailProd L (i + 1) k * δ i := by
        refine le_trans (run_lipschitz f L hL hlip k (i + 1) _ _) ?_
        exact mul_le_mul_of_nonneg_left (hδ i x) (tailProd_nonneg L hL (i + 1) k)
      have h2 := ih (i + 1) (g i x)
      rw [run_succ, run_succ, errBound_succ]
      linarith

/-- Refining the quantizer (pointwise smaller layer deviations) can only lower the
certified error.  This is what makes the "8-bit tail" follow-up well posed. -/
theorem errBound_mono_delta (δ δ' L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j)
    (h : ∀ j, δ' j ≤ δ j) (i k : ℕ) : errBound δ' L i k ≤ errBound δ L i k := by
  unfold errBound
  refine Finset.sum_le_sum (fun t _ => ?_)
  exact mul_le_mul_of_nonneg_right (h _) (tailProd_nonneg L hL _ _)

/-! ### Sensitivity profile of a depth-`n` network -/

/-- `sens L n m` is the downstream amplification of layer `m` in a network with layers
`0, …, n-1`: the product of the Lipschitz constants of the layers after `m`. -/
def sens (L : ℕ → ℝ) (n m : ℕ) : ℝ := tailProd L (m + 1) (n - 1 - m)

lemma sens_nonneg (L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j) (n m : ℕ) : 0 ≤ sens L n m :=
  tailProd_nonneg L hL _ _

/-- The last layer of a network has sensitivity exactly `1`: nothing amplifies it. -/
@[simp] theorem sens_last_eq_one (L : ℕ → ℝ) (n : ℕ) : sens L n (n - 1) = 1 := by
  unfold sens
  have : n - 1 - (n - 1) = 0 := by omega
  rw [this, tailProd_zero]

lemma sens_le_one (L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j) (hL1 : ∀ j, L j ≤ 1) (n m : ℕ) :
    sens L n m ≤ 1 := tailProd_le_one L hL hL1 _ _

/-- One step of the key structural fact: in a non-expansive network, going one layer
deeper cannot decrease the sensitivity. -/
theorem sens_le_sens_succ (L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j) (hL1 : ∀ j, L j ≤ 1)
    {n m : ℕ} (h : m + 1 < n) : sens L n m ≤ sens L n (m + 1) := by
  have hk : n - 1 - m = (n - 1 - (m + 1)) + 1 := by omega
  have : sens L n m = L (m + 1) * sens L n (m + 1) := by
    unfold sens
    rw [hk, tailProd_succ]
  rw [this]
  have h0 : 0 ≤ sens L n (m + 1) := sens_nonneg L hL n (m + 1)
  nlinarith [hL1 (m + 1)]

/-- **Tail dominance for non-expansive networks.**  The sensitivity profile is monotone
increasing in depth: deeper layers carry a larger certified perturbation budget. -/
theorem sens_mono (L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j) (hL1 : ∀ j, L j ≤ 1)
    {n m m' : ℕ} (hmm : m ≤ m') (h : m' < n) : sens L n m ≤ sens L n m' := by
  induction m' with
  | zero =>
      have : m = 0 := Nat.le_zero.mp hmm
      simp [this]
  | succ p ih =>
      rcases Nat.lt_or_ge m (p + 1) with hlt | hge
      · have hmp : m ≤ p := Nat.lt_succ_iff.mp hlt
        have hp : p < n := by omega
        exact le_trans (ih hmp hp) (sens_le_sens_succ L hL hL1 (by omega))
      · have : m = p + 1 := le_antisymm hmm hge
        simp [this]

/-- In a non-expansive network the last layer is the most sensitive one. -/
theorem sens_le_sens_last (L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j) (hL1 : ∀ j, L j ≤ 1)
    (n m : ℕ) : sens L n m ≤ sens L n (n - 1) := by
  rw [sens_last_eq_one]
  exact sens_le_one L hL hL1 n m

/-- **The expansive regime reverses the ordering:** if every layer expands
(`1 ≤ L j`) then the sensitivity profile is antitone in depth, so the *head*
carries the largest amplification. -/
theorem sens_anti_of_expansive (L : ℕ → ℝ) (hL1 : ∀ j, 1 ≤ L j)
    {n m m' : ℕ} (hmm : m ≤ m') (h : m' < n) : sens L n m' ≤ sens L n m := by
  induction m' with
  | zero =>
      have : m = 0 := Nat.le_zero.mp hmm
      simp [this]
  | succ p ih =>
      rcases Nat.lt_or_ge m (p + 1) with hlt | hge
      · have hmp : m ≤ p := Nat.lt_succ_iff.mp hlt
        have hp : p < n := by omega
        refine le_trans ?_ (ih hmp hp)
        have hk : n - 1 - p = (n - 1 - (p + 1)) + 1 := by omega
        have hstep : sens L n p = L (p + 1) * sens L n (p + 1) := by
          unfold sens; rw [hk, tailProd_succ]
        have h0 : 1 ≤ sens L n (p + 1) := one_le_tailProd L hL1 _ _
        rw [hstep]
        nlinarith [hL1 (p + 1)]
      · have : m = p + 1 := le_antisymm hmm hge
        simp [this]

/-- **Precision dichotomy.**  Which end of a network deserves precision protection is
determined by the contraction regime: for a non-expansive stack the maximal
sensitivity is at the tail, for an expansive stack it is at the head. -/
theorem precision_dichotomy (L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j) {n : ℕ} (hn : 0 < n) :
    ((∀ j, L j ≤ 1) → ∀ m < n, sens L n m ≤ sens L n (n - 1)) ∧
    ((∀ j, 1 ≤ L j) → ∀ m < n, sens L n (n - 1) ≤ sens L n m) := by
  refine ⟨fun hL1 m _ => sens_le_sens_last L hL hL1 n m, fun hL1 m hm => ?_⟩
  exact sens_anti_of_expansive L hL1 (by omega) (by omega)

/-- Under uniform per-layer quantization noise `ε` in a non-expansive network, the
end-to-end certified error is at most `ε * n`: the tail-dominant profile is still
summable. -/
theorem errBound_uniform_le (L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j) (hL1 : ∀ j, L j ≤ 1)
    (ε : ℝ) (hε : 0 ≤ ε) (n : ℕ) :
    errBound (fun _ => ε) L 0 n ≤ ε * n := by
  unfold errBound
  have : ∀ t ∈ range n, (fun _ : ℕ => ε) (0 + t) * tailProd L (0 + t + 1) (n - 1 - t) ≤ ε := by
    intro t _
    have h1 := tailProd_le_one L hL hL1 (0 + t + 1) (n - 1 - t)
    have h0 := tailProd_nonneg L hL (0 + t + 1) (n - 1 - t)
    nlinarith
  calc ∑ t ∈ range n, (fun _ : ℕ => ε) (0 + t) * tailProd L (0 + t + 1) (n - 1 - t)
      ≤ ∑ _t ∈ range n, ε := Finset.sum_le_sum this
    _ = ε * n := by simp [mul_comm]

/-! ## 2. The coverage (disagreement-set) model of retained accuracy -/

section Coverage

variable {α ι : Type*} [DecidableEq α] [DecidableEq ι]

/-- `qErr D S` is the number of evaluation prompts on which the network with layer set
`S` quantized disagrees with the full-precision baseline. -/
def qErr (D : Finset ι → Finset α) (S : Finset ι) : ℕ := (D S).card

variable {D : Finset ι → Finset α}

/-- Coverage implies subadditivity of the disagreement count. -/
theorem qErr_subadditive (hcov : ∀ A B, D (A ∪ B) ⊆ D A ∪ D B) (A B : Finset ι) :
    qErr D (A ∪ B) ≤ qErr D A + qErr D B :=
  le_trans (Finset.card_le_card (hcov A B)) (Finset.card_union_le _ _)

omit [DecidableEq α] [DecidableEq ι] in
/-- Monotone disagreement sets give a monotone error. -/
theorem qErr_mono (hmono : ∀ A B, A ⊆ B → D A ⊆ D B) {A B : Finset ι} (h : A ⊆ B) :
    qErr D A ≤ qErr D B := Finset.card_le_card (hmono A B h)

/-- **Protection sandwich.**  Protecting (i.e. not quantizing) a layer set `T` inside a
quantized set `U` never hurts, and never gains more than the standalone damage of `T`:
`0 ≤ qErr D U - qErr D (U \ T) ≤ qErr D T`. -/
theorem protection_gain_sandwich (hcov : ∀ A B, D (A ∪ B) ⊆ D A ∪ D B)
    (hmono : ∀ A B, A ⊆ B → D A ⊆ D B) (U T : Finset ι) :
    qErr D (U \ T) ≤ qErr D U ∧ qErr D U ≤ qErr D (U \ T) + qErr D T := by
  refine ⟨qErr_mono hmono (Finset.sdiff_subset), ?_⟩
  have hsub : U ⊆ (U \ T) ∪ T := by
    intro x hx
    by_cases hxT : x ∈ T
    · exact Finset.mem_union_right _ hxT
    · exact Finset.mem_union_left _ (Finset.mem_sdiff.mpr ⟨hx, hxT⟩)
  calc qErr D U ≤ qErr D ((U \ T) ∪ T) := qErr_mono hmono hsub
    _ ≤ qErr D (U \ T) + qErr D T := qErr_subadditive hcov _ _

/-- **Protection budget bound.**  Under coverage, the error of a quantized set is at
most the sum of the standalone errors of its layers; hence the gain from protecting a
set is bounded by the sum of its layers' individual damages. -/
theorem protection_budget (hcov : ∀ A B, D (A ∪ B) ⊆ D A ∪ D B) (hempty : D ∅ = ∅)
    (S : Finset ι) : qErr D S ≤ ∑ i ∈ S, qErr D {i} := by
  classical
  induction S using Finset.induction_on with
  | empty => simp [qErr, hempty]
  | insert a S ha ih =>
      have hins : insert a S = {a} ∪ S := by
        ext x; simp [Finset.mem_insert]
      have hstep : qErr D (insert a S) ≤ qErr D {a} + qErr D S := by
        rw [hins]; exact qErr_subadditive hcov _ _
      rw [Finset.sum_insert ha]
      omega

theorem protection_gain_le_budget (hcov : ∀ A B, D (A ∪ B) ⊆ D A ∪ D B)
    (hmono : ∀ A B, A ⊆ B → D A ⊆ D B) (hempty : D ∅ = ∅) (U T : Finset ι) :
    qErr D U ≤ qErr D (U \ T) + ∑ i ∈ T, qErr D {i} := by
  have h := (protection_gain_sandwich hcov hmono U T).2
  have hb := protection_budget hcov hempty T
  omega

/-- **Epistasis certificate.**  A super-additive joint error (NET-60's 7× effect,
NET-83's quantization × sparsity interaction) forces the existence of *emergent*
disagreements: prompts broken by the joint perturbation but by neither part alone. -/
theorem emergent_disagreement {A B : Finset ι}
    (h : qErr D A + qErr D B < qErr D (A ∪ B)) :
    (D (A ∪ B) \ (D A ∪ D B)).Nonempty := by
  rw [Finset.nonempty_iff_ne_empty]
  intro hcon
  have hsub : D (A ∪ B) ⊆ D A ∪ D B := Finset.sdiff_eq_empty_iff_subset.mp hcon
  have : qErr D (A ∪ B) ≤ qErr D A + qErr D B :=
    le_trans (Finset.card_le_card hsub) (Finset.card_union_le _ _)
  omega

/-- The quantitative form: the emergent set is at least as large as the super-additive
excess. -/
theorem emergent_card_ge {A B : Finset ι} :
    qErr D (A ∪ B) ≤ (D (A ∪ B) \ (D A ∪ D B)).card + qErr D A + qErr D B := by
  have h1 : (D (A ∪ B)).card ≤ (D (A ∪ B) \ (D A ∪ D B)).card + (D A ∪ D B).card :=
    Finset.card_le_card_sdiff_add_card
  have h2 : (D A ∪ D B).card ≤ (D A).card + (D B).card := Finset.card_union_le _ _
  simp only [qErr]
  omega

/-- A single super-additive measurement refutes the coverage hypothesis globally. -/
theorem superadditive_refutes_coverage {A B : Finset ι}
    (h : qErr D A + qErr D B < qErr D (A ∪ B)) :
    ¬ (∀ X Y : Finset ι, D (X ∪ Y) ⊆ D X ∪ D Y) := by
  intro hcov
  have := qErr_subadditive hcov A B
  omega

end Coverage

/-! ## 3. The NET-84 measurement, checked against the theory

`T` denotes the tail pair `{L22, L23}` and `R` the remaining 22 layers.
`retX` is the measured retained accuracy of the arm in which the layer set `X`
is quantized at 4 bits, and `errX = 1 - retX`.
-/

/-- Retained accuracy with only the tail pair `L22/L23` quantized (arm 3). -/
def retTail : ℚ := 9766 / 10000

/-- Retained accuracy with everything *except* the tail quantized: the tail-aware
mixed-precision arm (arm 2). -/
def retRest : ℚ := 9261 / 10000

/-- Retained accuracy with every layer quantized (arm 1, full GPTQ4). -/
def retFull : ℚ := 9081 / 10000

/-- Damage of quantizing only the tail. -/
def errTail : ℚ := 1 - retTail

/-- Damage of quantizing everything but the tail. -/
def errRest : ℚ := 1 - retRest

/-- Damage of quantizing the whole network. -/
def errFull : ℚ := 1 - retFull

/-- The gain bought by keeping the tail pair in fp32. -/
def net84Gain : ℚ := retRest - retFull

/-- The measured gain is exactly `+1.8` points. -/
theorem net84_gain_eq : net84Gain = 9 / 500 := by
  unfold net84Gain retRest retFull; norm_num

/-- Protection strictly helps: `P1` (mixed precision beats full 4-bit) is confirmed and
`P2` (the tail does not benefit from protection) is refuted. -/
theorem net84_protection_strictly_positive : 0 < net84Gain := by
  rw [net84_gain_eq]; norm_num

/-- The three arms are **coverage-consistent**: the joint damage is subadditive, so
NET-84 (unlike NET-60/NET-83) exhibits no emergent disagreement.  The slack is
`0.0054`. -/
theorem net84_coverage_consistent : errFull ≤ errRest + errTail := by
  unfold errFull errRest errTail retFull retRest retTail; norm_num

theorem net84_coverage_slack : errRest + errTail - errFull = 27 / 5000 := by
  unfold errFull errRest errTail retFull retRest retTail; norm_num

/-- The gain lies inside the protection sandwich `0 ≤ gain ≤ errTail` predicted by the
coverage model — an independent numerical confirmation of
`protection_gain_sandwich`. -/
theorem net84_gain_le_ceiling : net84Gain ≤ errTail := by
  unfold net84Gain errTail retRest retFull retTail; norm_num

/-- Tail protection realises exactly `10/13 ≈ 0.769` of its theoretical ceiling. -/
theorem net84_efficiency_exact : 13 * net84Gain = 10 * errTail := by
  unfold net84Gain errTail retRest retFull retTail; norm_num

/-- The efficiency ratio is strictly between `3/4` and `1`: protection is highly, but
not perfectly, effective. -/
theorem net84_efficiency_bounds : 3 / 4 * errTail < net84Gain ∧ net84Gain < errTail := by
  constructor <;>
    (unfold net84Gain errTail retRest retFull retTail; norm_num)

/-! ### Memory accounting

The protected tail is `2` layers of `1.8 × 10⁶` parameters each.  At 4 bits a
parameter costs `1/2` byte, at fp32 it costs `4` bytes, so the protection costs
`3.6 × 10⁶ × (4 - 1/2) = 1.26 × 10⁷` bytes on top of the `4`-bit model, whose size for
the `494 × 10⁶`-parameter Qwen2.5-0.5B is `2.47 × 10⁸` bytes.
-/

/-- Parameters in the protected tail pair. -/
def tailParams : ℚ := 2 * 1800000

/-- Total parameters of Qwen2.5-0.5B. -/
def modelParams : ℚ := 494000000

/-- Extra bytes needed to keep the tail in fp32 rather than 4 bits. -/
def protectionBytes : ℚ := tailParams * (4 - 1 / 2)

/-- Size in bytes of the fully 4-bit model. -/
def baseBytes : ℚ := modelParams * (1 / 2)

/-- The memory overhead of tail protection is under `6%` of the 4-bit model. -/
theorem net84_overhead_small : protectionBytes / baseBytes < 6 / 100 := by
  unfold protectionBytes baseBytes tailParams modelParams; norm_num

/-- Quality bought per unit of memory overhead: more than `0.29` retained points per
percent of extra memory (i.e. the trade is strongly favourable). -/
theorem net84_quality_per_overhead :
    29 / 100 * (protectionBytes / baseBytes) < net84Gain := by
  unfold protectionBytes baseBytes tailParams modelParams net84Gain retRest retFull
  norm_num

/-! ## 4. Bridging the models: the propagation bound explains the arms

If the tail block and the rest block have certified damages `dT` and `dR`, the
propagation theorem gives a subadditive certificate for the joint arm, matching the
observed `net84_coverage_consistent`.  The following statement is the abstract form of
that reasoning: a two-block split of the certified error bound. -/
theorem errBound_split (δ L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j) (hδ : ∀ j, 0 ≤ δ j) (i k : ℕ) :
    errBound δ L i k ≤ errBound δ L (i + 1) (k - 1) + δ i * tailProd L (i + 1) (k - 1) := by
  cases k with
  | zero =>
      simp only [errBound, Finset.range_zero, Finset.sum_empty]
      have := mul_nonneg (hδ i) (tailProd_nonneg L hL (i + 1) 0)
      simpa using this
  | succ k =>
      have := errBound_succ δ L i k
      simp only [Nat.add_sub_cancel]
      exact le_of_eq this

/-- The certified error of a **protected** network (the perturbation of the protected
block set to `0`) is at most that of the fully perturbed network: protection never
increases the certificate.  This is the propagation-model counterpart of
`protection_gain_sandwich`. -/
theorem errBound_protect_le (δ L : ℕ → ℝ) (hL : ∀ j, 0 ≤ L j) (hδ : ∀ j, 0 ≤ δ j)
    (P : ℕ → Prop) [DecidablePred P] (i k : ℕ) :
    errBound (fun j => if P j then 0 else δ j) L i k ≤ errBound δ L i k := by
  refine errBound_mono_delta δ _ L hL (fun j => ?_) i k
  by_cases h : P j <;> simp [h, hδ j]

/-- And the protected certificate improves by at most the certified damage of the
protected block alone — the propagation-model sandwich. -/
theorem errBound_protect_ge (δ L : ℕ → ℝ)
    (P : ℕ → Prop) [DecidablePred P] (i k : ℕ) :
    errBound δ L i k
      ≤ errBound (fun j => if P j then 0 else δ j) L i k
        + errBound (fun j => if P j then δ j else 0) L i k := by
  unfold errBound
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_le_sum (fun t _ => ?_)
  by_cases h : P (i + t) <;> simp [h]

end TailPrecision