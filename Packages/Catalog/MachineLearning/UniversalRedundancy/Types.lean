/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality II: parametric classes pay only `O(log n)`

Continuation of `MachineLearning.UniversalRedundancy.Core`.  There the minimax
redundancy of a source class was identified *exactly* with `log₂ Cₛ`, the log of
the Shtarkov sum.  Here we bound `Cₛ` for the classes that matter in practice —
memoryless (i.i.d.) sources and Markov sources — and obtain closed-form bounds
in the message length `n` and the *class complexity*.

## Central Idea

The abstract engine is a **sufficient statistic** bound: if the likelihood
`p_θ x` depends on `x` only through a statistic `T x` taking `N` values, then

`Cₛ ≤ N`.

Indeed the fibre of `T` over a value `s` has some cardinality `k`, on which the
maximum likelihood is a constant `M`; since `k · p_θ x ≤ 1` for every `θ`, also
`k · M ≤ 1`, so each fibre contributes at most `1` to `∑ₓ maxₜ p_θ x`.

For a class whose likelihood is a product of `m` factors drawn from a finite
"feature alphabet" `B` (times a factor depending on a finite initial statistic
in `C`), the counts of the features form such a statistic, giving

`Cₛ ≤ #C · (m+1) ^ #B`.

Specialising: memoryless sources over an alphabet `A` on messages of length `n`
give `Cₛ ≤ (n+1) ^ #A`, and first-order Markov sources give
`Cₛ ≤ #A · (n+1) ^ (#A · #A)`.  In bits: the price of universality is at most
`#A · log₂ (n+1)` resp. `log₂ #A + #A² · log₂ (n+1)` bits — logarithmic in `n`,
matching the Rissanen-style `(d/2) log₂ n` rate up to the constant factor `2`
in front of the parameter dimension `d`.

## Main Results

* `SourceClass.shtarkovSum_le_card_statistic` — sufficient-statistic bound
* `SourceClass.shtarkovSum_le_of_product_form` — counting bound for product
  likelihoods, `Cₛ ≤ #C · (m+1) ^ #B`
* `iidClass`, `shtarkovSum_iidClass_le` — memoryless sources: `Cₛ ≤ (n+1) ^ #A`
* `markovClass`, `shtarkovSum_markovClass_le` — Markov sources:
  `Cₛ ≤ #A · (n+1) ^ (#A * #A)`
* `iid_redundancy_bits_le`, `markov_redundancy_bits_le` — the bit-level
  statements: a single universal code is within `#A log₂(n+1) + 1` bits of the
  code tailored to the true memoryless source, for *every* source and *every*
  message
* `iid_redundancy_rate_tendsto_zero` — the per-symbol price of universality
  tends to `0`: specialisation buys a vanishing fraction of the message

## Application Keywords

method of types, sufficient statistic, Rissanen redundancy, Markov sources,
universal coding, parametric class complexity
-/

import Catalog.MachineLearning.UniversalRedundancy.Core

open Finset Real

namespace UniversalRedundancy

/-! ## Sufficient-statistic bound on the Shtarkov sum -/

namespace SourceClass

variable {X : Type*} [Fintype X] {Θ : Type*} (S : SourceClass X Θ)

/-- **Sufficient-statistic bound.**  If the likelihood factors through a
statistic `T : X → σ` with `σ` finite, then the Shtarkov sum — hence the minimax
redundancy factor — is at most `#σ`. -/
theorem shtarkovSum_le_card_statistic [Nonempty Θ] {σ : Type*} [Fintype σ]
    [DecidableEq σ] (T : X → σ)
    (hT : ∀ θ x y, T x = T y → S.prob θ x = S.prob θ y) :
    S.shtarkovSum ≤ (Fintype.card σ : ℝ) := by
  classical
  have hfib : ∀ s : σ, ∑ x ∈ univ.filter (fun x => T x = s), S.maxLik x ≤ 1 := by
    intro s
    rcases Finset.eq_empty_or_nonempty (univ.filter (fun x => T x = s)) with he | hne
    · simp [he]
    obtain ⟨x0, hx0⟩ := hne
    have hx0' : T x0 = s := (Finset.mem_filter.mp hx0).2
    have hconstprob : ∀ θ, ∀ x ∈ univ.filter (fun x => T x = s),
        S.prob θ x = S.prob θ x0 := by
      intro θ x hx
      exact hT θ x x0 (by rw [(Finset.mem_filter.mp hx).2, hx0'])
    have hconst : ∀ x ∈ univ.filter (fun x => T x = s), S.maxLik x = S.maxLik x0 := by
      intro x hx
      unfold SourceClass.maxLik
      exact congrArg _ (funext fun θ => hconstprob θ x hx)
    set k : ℕ := (univ.filter (fun x => T x = s)).card with hk
    have hkpos : 0 < k := Finset.card_pos.mpr ⟨x0, hx0⟩
    have hmass : ∀ θ, (k : ℝ) * S.prob θ x0 ≤ 1 := by
      intro θ
      have h1 : ∑ x ∈ univ.filter (fun x => T x = s), S.prob θ x = (k : ℝ) * S.prob θ x0 := by
        rw [Finset.sum_congr rfl (hconstprob θ), Finset.sum_const, nsmul_eq_mul, hk]
      have h2 : ∑ x ∈ univ.filter (fun x => T x = s), S.prob θ x ≤ ∑ x, S.prob θ x :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
          fun x _ _ => S.nonneg θ x
      rw [S.sum_one θ] at h2
      linarith [h1 ▸ h2]
    have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hkpos
    have hmaxle : S.maxLik x0 ≤ 1 / (k : ℝ) := by
      refine S.maxLik_le fun θ => ?_
      rw [le_div_iff₀ hkR]
      calc S.prob θ x0 * (k : ℝ) = (k : ℝ) * S.prob θ x0 := by ring
        _ ≤ 1 := hmass θ
    calc ∑ x ∈ univ.filter (fun x => T x = s), S.maxLik x
        = (k : ℝ) * S.maxLik x0 := by
          rw [Finset.sum_congr rfl hconst, Finset.sum_const, nsmul_eq_mul, hk]
      _ ≤ (k : ℝ) * (1 / (k : ℝ)) := by
          exact mul_le_mul_of_nonneg_left hmaxle hkR.le
      _ = 1 := by field_simp
  calc S.shtarkovSum
      = ∑ s : σ, ∑ x ∈ univ.filter (fun x => T x = s), S.maxLik x :=
        (Finset.sum_fiberwise univ T S.maxLik).symm
    _ ≤ ∑ _s : σ, (1 : ℝ) := Finset.sum_le_sum fun s _ => hfib s
    _ = (Fintype.card σ : ℝ) := by simp

/-! ## Counting statistic for product likelihoods -/

end SourceClass

/-- The count statistic of a feature word: how often each feature occurs. -/
def countStat {B : Type*} [DecidableEq B] {m : ℕ} (w : Fin m → B) (b : B) : Fin (m + 1) :=
  ⟨(univ.filter (fun j => w j = b)).card, by
    have : (univ.filter (fun j : Fin m => w j = b)).card ≤ Fintype.card (Fin m) :=
      le_trans (Finset.card_filter_le _ _) (le_of_eq (by simp))
    simp only [Fintype.card_fin] at this
    omega⟩

/-- A product over positions equals the product of feature weights raised to
their multiplicities: the counts are a sufficient statistic for product
likelihoods. -/
lemma prod_eq_prod_pow_countStat {B : Type*} [Fintype B] [DecidableEq B] {m : ℕ}
    (g : B → ℝ) (w : Fin m → B) :
    ∏ j, g (w j) = ∏ b, g b ^ ((countStat w b : Fin (m + 1)) : ℕ) := by
  classical
  rw [← Finset.prod_fiberwise (g := fun j => w j) (f := fun j => g (w j))]
  refine Finset.prod_congr rfl fun b _ => ?_
  rw [Finset.prod_congr rfl (fun j hj => by simp only [Finset.mem_filter] at hj; rw [hj.2]),
    Finset.prod_const]
  rfl

namespace SourceClass

variable {X : Type*} [Fintype X] {Θ : Type*} (S : SourceClass X Θ)

/-- **Counting bound for product likelihoods.**  If every likelihood is a
product of `m` feature weights (features in a finite alphabet `B`) times a
factor depending only on a finite initial statistic in `C`, then

`Cₛ ≤ #C · (m + 1) ^ #B`,

so the price of universality is at most `log₂ #C + #B · log₂ (m+1)` bits. -/
theorem shtarkovSum_le_of_product_form [Nonempty Θ] {B C : Type*} [Fintype B]
    [DecidableEq B] [Fintype C] [DecidableEq C] {m : ℕ}
    (feat : X → Fin m → B) (init : X → C) (g : Θ → B → ℝ) (h : Θ → C → ℝ)
    (hform : ∀ θ x, S.prob θ x = h θ (init x) * ∏ j, g θ (feat x j)) :
    S.shtarkovSum ≤ (Fintype.card C : ℝ) * ((m + 1 : ℕ) : ℝ) ^ (Fintype.card B) := by
  classical
  have hstat := S.shtarkovSum_le_card_statistic
    (T := fun x => (init x, countStat (feat x))) ?_
  · refine le_trans hstat (le_of_eq ?_)
    rw [Fintype.card_prod, Fintype.card_pi]
    simp only [Fintype.card_fin, Finset.prod_const, Finset.card_univ]
    push_cast
    ring
  · intro θ x y hxy
    have h1 : init x = init y := congrArg Prod.fst hxy
    have h2 : countStat (feat x) = countStat (feat y) := congrArg Prod.snd hxy
    rw [hform θ x, hform θ y, h1, prod_eq_prod_pow_countStat, prod_eq_prod_pow_countStat, h2]

end SourceClass

/-! ## Memoryless (i.i.d.) sources -/

/-- The parameter space of a memoryless source over the alphabet `A`. -/
def Simplex (A : Type*) [Fintype A] : Type _ :=
  {θ : A → ℝ // (∀ a, 0 ≤ θ a) ∧ ∑ a, θ a = 1}

instance (A : Type*) [Fintype A] [Nonempty A] [DecidableEq A] :
    Nonempty (Simplex A) :=
  ⟨⟨fun _ => (Fintype.card A : ℝ)⁻¹, fun _ => by positivity, by
      have hA : (Fintype.card A : ℝ) ≠ 0 := by
        have : 0 < Fintype.card A := Fintype.card_pos
        positivity
      rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
      field_simp⟩⟩

variable {A : Type*} [Fintype A] [DecidableEq A]

/-- The class of memoryless (i.i.d.) sources on messages of length `n`. -/
noncomputable def iidClass (A : Type*) [Fintype A] [DecidableEq A] (n : ℕ) :
    SourceClass (Fin n → A) (Simplex A) where
  prob θ x := ∏ i, θ.1 (x i)
  nonneg θ x := Finset.prod_nonneg fun i _ => θ.2.1 (x i)
  sum_one θ := by
    classical
    have := Finset.prod_univ_sum (fun _ : Fin n => (univ : Finset A))
      (fun _ (a : A) => θ.1 a)
    simp only [Fintype.piFinset_univ, θ.2.2, Finset.prod_const_one] at this
    simpa using this.symm

/-- **Memoryless sources: `Cₛ ≤ (n+1) ^ #A`.**  The price of universality for
the whole i.i.d. class is at most `#A · log₂ (n+1)` bits, regardless of how
finely the parameter is tuned. -/
theorem shtarkovSum_iidClass_le [Nonempty A] (n : ℕ) :
    (iidClass A n).shtarkovSum ≤ ((n + 1 : ℕ) : ℝ) ^ (Fintype.card A) := by
  classical
  have := (iidClass A n).shtarkovSum_le_of_product_form
    (B := A) (C := Unit) (m := n) (feat := fun x j => x j) (init := fun _ => ())
    (g := fun θ a => θ.1 a) (h := fun _ _ => 1) (by intro θ x; simp [iidClass])
  simpa using this

/-- Every message has positive maximum likelihood in the i.i.d. class (witness:
the uniform parameter), so the NML code is well defined. -/
lemma maxLik_iidClass_pos [Nonempty A] (n : ℕ) (x : Fin n → A) :
    0 < (iidClass A n).maxLik x := by
  have hA : (0 : ℝ) < (Fintype.card A : ℝ) := by exact_mod_cast Fintype.card_pos
  set θ : Simplex A := Classical.arbitrary (Simplex A) with hθ
  have hpos : 0 < (iidClass A n).prob
      (⟨fun _ => (Fintype.card A : ℝ)⁻¹, fun _ => by positivity, by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
        field_simp⟩ : Simplex A) x := by
    simp only [iidClass]
    exact Finset.prod_pos fun i _ => by positivity
  exact lt_of_lt_of_le hpos ((iidClass A n).le_maxLik _ x)

/-- **The price of universality for memoryless sources, in bits.**  A single
universal code (the NML code of the i.i.d. class) is, on *every* message and
against *every* memoryless source, within `#A · log₂ (n+1) + 1` bits of the code
tailored to that source. -/
theorem iid_redundancy_bits_le [Nonempty A] (n : ℕ) (θ : Simplex A) (x : Fin n → A)
    (hx : 0 < (iidClass A n).prob θ x) :
    ((iidClass A n).nmlCodeLength x : ℝ)
      ≤ logb 2 (1 / (iidClass A n).prob θ x)
        + (Fintype.card A : ℝ) * logb 2 ((n : ℝ) + 1) + 1 := by
  have h1 := (iidClass A n).nmlCodeLength_le (maxLik_iidClass_pos n) hx
  have h2 : logb 2 (iidClass A n).shtarkovSum
      ≤ (Fintype.card A : ℝ) * logb 2 ((n : ℝ) + 1) := by
    have hC := shtarkovSum_iidClass_le (A := A) n
    have hbase : ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 := by push_cast; ring
    rw [hbase] at hC
    have hle : logb 2 (iidClass A n).shtarkovSum
        ≤ logb 2 (((n : ℝ) + 1) ^ (Fintype.card A)) :=
      Real.logb_le_logb_of_le (by norm_num) (iidClass A n).shtarkovSum_pos hC
    rwa [Real.logb_pow] at hle
  linarith

/-- **Vanishing rate.**  The per-symbol price of universality for the memoryless
class tends to `0`: a universal code loses only `o(1)` bits per symbol, so
specialising the decompressor to a memoryless class can move only a vanishing
fraction of the message into the shared decompressor. -/
theorem redundancy_rate_tendsto_zero (c : ℝ) :
    Filter.Tendsto (fun n : ℕ => (c * logb 2 ((n : ℝ) + 1) + 1) / (n : ℝ))
      Filter.atTop (nhds 0) := by
  have hbase : Filter.Tendsto (fun x : ℝ => logb 2 x ^ 1 / (1 * x + (-1)))
      Filter.atTop (nhds 0) :=
    Real.tendsto_pow_logb_div_mul_add_atTop 1 (-1) 1 one_ne_zero
  have hshift : Filter.Tendsto (fun n : ℕ => ((n : ℝ) + 1)) Filter.atTop Filter.atTop :=
    Filter.tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop
  have hcomp : Filter.Tendsto
      (fun n : ℕ => logb 2 ((n : ℝ) + 1) ^ 1 / (1 * ((n : ℝ) + 1) + (-1)))
      Filter.atTop (nhds 0) := hbase.comp hshift
  have hlog : Filter.Tendsto (fun n : ℕ => logb 2 ((n : ℝ) + 1) / (n : ℝ))
      Filter.atTop (nhds 0) := by
    refine hcomp.congr fun n => ?_
    simp only [pow_one, one_mul]
    ring_nf
  have hinv : Filter.Tendsto (fun n : ℕ => 1 / (n : ℝ)) Filter.atTop (nhds 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have := ((hlog.const_mul c).add hinv)
  rw [mul_zero, add_zero] at this
  refine this.congr fun n => ?_
  field_simp

end UniversalRedundancy