/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression I: Schemes and the Relaxed Pigeonhole Bound

## Bridge: Combinatorics (pigeonhole) ↔ Probability (min-entropy) ↔ Coding theory

The exact pigeonhole bound says: a code that decodes *every* source symbol
correctly needs at least `|α|` codewords.  This file develops the *relaxed*
(almost-lossless) form of that statement:

* a scheme is an encoder/decoder pair `enc : α → Code`, `dec : Code → Option α`;
* the decoder may abstain (`none`), and may in principle err silently;
* the **success set** is the set of symbols decoded exactly.

Main results:

* `enc_injOn_successSet` / `card_successSet_le_card_code` — the exact pigeonhole
  bound applies to the success set only;
* `successMass_le` — `P(success) ≤ |Code| · p_max`, i.e. the counting bound is
  relaxed by a factor governed by the min-entropy of the source;
* `card_code_ge_of_success` — the converse: to succeed with probability `1 - ε`
  one needs `|Code| ≥ (1-ε)/p_max`;
* `log_card_code_ge_of_success` — the same statement in entropy form,
  `log |Code| ≥ H_∞(μ) + log (1-ε)`;
* `exact_decoding_pigeonhole` — the classical bound is recovered at `ε = 0`.

## Impact: certified_compression_bound, almost_lossless_converse
-/

import Mathlib
import Bridges.MinEntropy

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

variable {α : Type*} [Fintype α]

/-! ## Section 1: Mass of a finite set of source symbols -/

/-- The probability mass of a finite set of source symbols. -/
noncomputable def setMass (μ : FinProbDist α) (S : Finset α) : ℝ :=
  ∑ x ∈ S, μ.mass x

theorem setMass_nonneg (μ : FinProbDist α) (S : Finset α) : 0 ≤ setMass μ S :=
  Finset.sum_nonneg fun x _ => μ.mass_nonneg x

theorem setMass_univ (μ : FinProbDist α) : setMass μ Finset.univ = 1 :=
  μ.mass_sum_one

theorem setMass_mono (μ : FinProbDist α) {S T : Finset α} (h : S ⊆ T) :
    setMass μ S ≤ setMass μ T :=
  Finset.sum_le_sum_of_subset_of_nonneg h fun x _ _ => μ.mass_nonneg x

theorem setMass_le_one (μ : FinProbDist α) (S : Finset α) : setMass μ S ≤ 1 := by
  simpa [setMass_univ] using setMass_mono μ (Finset.subset_univ S)

theorem setMass_union_le (μ : FinProbDist α) [DecidableEq α] (S T : Finset α) :
    setMass μ (S ∪ T) ≤ setMass μ S + setMass μ T := by
  classical
  unfold setMass
  have h := Finset.sum_union_inter (s₁ := S) (s₂ := T) (f := μ.mass)
  have h2 : 0 ≤ ∑ x ∈ S ∩ T, μ.mass x :=
    Finset.sum_nonneg fun x _ => μ.mass_nonneg x
  linarith

/-- Subadditivity over an indexed union. -/
theorem setMass_biUnion_le {ι : Type*} [DecidableEq α] (μ : FinProbDist α)
    (s : Finset ι) (t : ι → Finset α) :
    setMass μ (s.biUnion t) ≤ ∑ i ∈ s, setMass μ (t i) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [setMass]
  | insert a s ha ih =>
      rw [Finset.biUnion_insert, Finset.sum_insert ha]
      have := setMass_union_le μ (t a) (s.biUnion t)
      linarith

/-- Splitting the total mass across a set and its complement. -/
theorem setMass_add_compl (μ : FinProbDist α) [DecidableEq α] (S : Finset α) :
    setMass μ S + setMass μ Sᶜ = 1 := by
  classical
  unfold setMass
  rw [← Finset.sum_union (disjoint_compl_right)]
  simpa using μ.mass_sum_one

/-- A set of `n` symbols carries at most `n · p_max` mass: the elementary
counting bound behind every converse in this file. -/
theorem setMass_le_card_mul_maxMass [Nonempty α] (μ : FinProbDist α) (S : Finset α) :
    setMass μ S ≤ (S.card : ℝ) * maxMass μ := by
  calc setMass μ S = ∑ x ∈ S, μ.mass x := rfl
    _ ≤ ∑ _x ∈ S, maxMass μ := Finset.sum_le_sum fun x _ => mass_le_maxMass μ x
    _ = (S.card : ℝ) * maxMass μ := by simp [Finset.sum_const, nsmul_eq_mul]

/-! ## Section 2: Compression schemes with an abstaining decoder -/

/-- A compression scheme: an encoder into a code space, and a decoder that is
allowed to abstain by returning `none`. -/
structure Scheme (α : Type*) (Code : Type*) where
  /-- The encoder. -/
  enc : α → Code
  /-- The decoder, allowed to report failure. -/
  dec : Code → Option α

variable {Code : Type*}

/-- The scheme decodes `x` correctly. -/
def Scheme.Succeeds (sch : Scheme α Code) (x : α) : Prop :=
  sch.dec (sch.enc x) = some x

/-- The scheme *silently corrupts* `x`: it returns a confident but wrong answer. -/
def Scheme.SilentError (sch : Scheme α Code) (x : α) : Prop :=
  ∃ y, sch.dec (sch.enc x) = some y ∧ y ≠ x

/-- A scheme *never corrupts silently* when every confident answer is correct;
failures are then always detected (reported as `none`). -/
def Scheme.NeverSilent (sch : Scheme α Code) : Prop :=
  ∀ x, ¬ sch.SilentError x

omit [Fintype α] in
theorem Scheme.neverSilent_iff (sch : Scheme α Code) :
    sch.NeverSilent ↔ ∀ x, sch.dec (sch.enc x) = some x ∨ sch.dec (sch.enc x) = none := by
  constructor
  · intro h x
    rcases hx : sch.dec (sch.enc x) with _ | y
    · exact Or.inr rfl
    · refine Or.inl ?_
      have hxy : y = x := by
        by_contra hne
        exact h x ⟨y, hx, hne⟩
      simp [hxy]
  · rintro h x ⟨y, hy, hne⟩
    rcases h x with h1 | h1
    · rw [h1] at hy; exact hne (Option.some_inj.mp hy).symm
    · rw [h1] at hy; simp at hy

instance Scheme.decidableSucceeds [DecidableEq α] (sch : Scheme α Code) :
    DecidablePred sch.Succeeds := fun _ => by unfold Scheme.Succeeds; infer_instance

instance Scheme.decidableSilentError [DecidableEq α] (sch : Scheme α Code) :
    DecidablePred sch.SilentError := fun _ => by unfold Scheme.SilentError; infer_instance

variable [DecidableEq α]

/-- The set of source symbols the scheme decodes exactly. -/
def successSet (sch : Scheme α Code) : Finset α :=
  Finset.univ.filter (fun x => sch.dec (sch.enc x) = some x)

theorem mem_successSet {sch : Scheme α Code} {x : α} :
    x ∈ successSet sch ↔ sch.Succeeds x := by
  simp [successSet, Scheme.Succeeds]

/-- **Pigeonhole, localized.** The encoder is injective on the success set:
correct decoding forces distinct codewords. -/
theorem enc_injOn_successSet (sch : Scheme α Code) :
    Set.InjOn sch.enc (successSet sch) := by
  intro x hx y hy hxy
  simp only [Finset.mem_coe, mem_successSet] at hx hy
  unfold Scheme.Succeeds at hx hy
  rw [hxy] at hx
  rw [hx] at hy
  exact Option.some_inj.mp hy

/-- **Relaxed pigeonhole bound (counting form).** However small the failure
probability is allowed to be, the number of *exactly* decoded symbols never
exceeds the number of codewords. -/
theorem card_successSet_le_card_code [Fintype Code] (sch : Scheme α Code) :
    (successSet sch).card ≤ Fintype.card Code := by
  classical
  have h : (successSet sch).card ≤ (Finset.univ : Finset Code).card :=
    Finset.card_le_card_of_injOn sch.enc (fun x _ => Finset.mem_univ _)
      (enc_injOn_successSet sch)
  simpa [Finset.card_univ] using h

/-- **Exact pigeonhole, recovered.** A scheme that decodes *every* symbol
correctly needs at least `|α|` codewords. -/
theorem exact_decoding_pigeonhole [Fintype Code] (sch : Scheme α Code)
    (h : ∀ x : α, sch.Succeeds x) :
    Fintype.card α ≤ Fintype.card Code := by
  have hall : successSet sch = Finset.univ := by
    apply Finset.eq_univ_of_forall
    intro x; rw [mem_successSet]; exact h x
  have := card_successSet_le_card_code sch
  rwa [hall, Finset.card_univ] at this

/-! ## Section 3: The ε-relaxed counting bound -/

/-- The success probability of a scheme. -/
noncomputable def successProb (μ : FinProbDist α) (sch : Scheme α Code) : ℝ :=
  setMass μ (successSet sch)

/-- **The counting bound relaxes by a min-entropy factor.**
`P(success) ≤ |Code| · p_max`. -/
theorem successProb_le [Nonempty α] [Fintype Code] (μ : FinProbDist α)
    (sch : Scheme α Code) :
    successProb μ sch ≤ (Fintype.card Code : ℝ) * maxMass μ := by
  refine (setMass_le_card_mul_maxMass μ _).trans ?_
  exact mul_le_mul_of_nonneg_right
    (by exact_mod_cast card_successSet_le_card_code sch) (le_of_lt (maxMass_pos μ))

/-- **Almost-lossless converse.** If the decoder succeeds with probability at
least `1 - ε`, then the code space must have at least `(1-ε)/p_max` elements.
At `ε = 0` this is the pigeonhole bound `|Code| ≥ 2^{H_∞}`. -/
theorem card_code_ge_of_success [Nonempty α] [Fintype Code] (μ : FinProbDist α)
    (sch : Scheme α Code) (ε : ℝ) (h : 1 - ε ≤ successProb μ sch) :
    (1 - ε) / maxMass μ ≤ (Fintype.card Code : ℝ) := by
  have hp := maxMass_pos μ
  rw [div_le_iff₀ hp]
  calc 1 - ε ≤ successProb μ sch := h
    _ ≤ (Fintype.card Code : ℝ) * maxMass μ := successProb_le μ sch

/-- **Almost-lossless converse, entropy form.**
`log |Code| ≥ H_∞(μ) + log(1-ε)`: the rate must exceed the min-entropy of the
source, discounted by `log(1-ε)`. -/
theorem log_card_code_ge_of_success [Nonempty α] [Fintype Code] (μ : FinProbDist α)
    (sch : Scheme α Code) (ε : ℝ) (hε : ε < 1) (h : 1 - ε ≤ successProb μ sch) :
    minEntropy μ + Real.log (1 - ε) ≤ Real.log (Fintype.card Code : ℝ) := by
  have hp := maxMass_pos μ
  have h1 : (0 : ℝ) < 1 - ε := by linarith
  have hkey := card_code_ge_of_success μ sch ε h
  have hpos : (0 : ℝ) < (1 - ε) / maxMass μ := div_pos h1 hp
  have := Real.log_le_log hpos hkey
  rw [Real.log_div (ne_of_gt h1) (ne_of_gt hp)] at this
  unfold minEntropy
  linarith

/-- **Uniform-source form.** For the uniform source on `α`, success probability
`1 - ε` forces `|Code| ≥ (1-ε)|α|`: the pigeonhole bound degrades exactly by the
factor `1 - ε`, and by nothing more. -/
theorem card_code_ge_of_success_uniform [Nonempty α] [Fintype Code]
    (sch : Scheme α Code) (ε : ℝ)
    (h : 1 - ε ≤ successProb (uniformDist α) sch) :
    (1 - ε) * (Fintype.card α : ℝ) ≤ (Fintype.card Code : ℝ) := by
  have hcard : (0 : ℝ) < (Fintype.card α : ℝ) := by exact_mod_cast Fintype.card_pos
  have hmax : maxMass (uniformDist α) = 1 / (Fintype.card α : ℝ) := by
    have hle : maxMass (uniformDist α) ≤ 1 / (Fintype.card α : ℝ) := by
      obtain ⟨x, hx⟩ := maxMass_exists_witness (uniformDist α)
      rw [← hx]
      simp [uniformDist]
    exact le_antisymm hle (one_div_card_le_maxMass _)
  have := card_code_ge_of_success (uniformDist α) sch ε h
  rw [hmax, div_div_eq_mul_div, div_one] at this
  linarith

/-! ## Section 4: The relaxed bound is attained -/

/-- **Tightness of the relaxed pigeonhole bound.**  For every code size
`0 < M ≤ n+1` there is a scheme on the uniform source over `Fin (n+1)` whose
success probability is *exactly* `M/(n+1)`.  Together with `successProb_le`
(which gives `≤ M/(n+1)` here) this shows the ε-relaxed counting bound is
attained, so none of the converses above can be improved. -/
theorem relaxed_pigeonhole_tight (n M : ℕ) (hM : 0 < M) (hMn : M ≤ n + 1) :
    ∃ sch : Scheme (Fin (n + 1)) (Fin M),
      successProb (uniformDist (Fin (n + 1))) sch = (M : ℝ) / (n + 1) := by
  classical
  refine ⟨⟨fun x => if h : x.val < M then ⟨x.val, h⟩ else ⟨0, hM⟩,
    fun i => some (Fin.castLE hMn i)⟩, ?_⟩
  have hsucc : successSet (α := Fin (n + 1))
      ⟨fun x => if h : x.val < M then ⟨x.val, h⟩ else ⟨0, hM⟩,
        fun i => some (Fin.castLE hMn i)⟩
      = Finset.univ.filter (fun x : Fin (n + 1) => x.val < M) := by
    ext x
    simp only [mem_successSet, Scheme.Succeeds, Finset.mem_filter, Finset.mem_univ, true_and]
    by_cases hx : x.val < M
    · simp [hx]
    · simp only [dif_neg hx]
      constructor
      · intro h
        have h2 := congrArg Fin.val (Option.some_inj.mp h)
        simp only [Fin.val_castLE] at h2
        omega
      · intro h; exact absurd h hx
  have hcard : (Finset.univ.filter (fun x : Fin (n + 1) => x.val < M)).card = M := by
    have : Finset.univ.filter (fun x : Fin (n + 1) => x.val < M)
        = Finset.univ.map (Fin.castLEEmb hMn) := by
      ext x
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_map,
        Fin.castLEEmb_apply]
      constructor
      · intro hx
        refine ⟨⟨x.val, hx⟩, ?_⟩
        simp
      · rintro ⟨y, hy⟩
        have hylt := y.isLt
        simp only [← hy]
        simp [hylt]
    rw [this, Finset.card_map, Finset.card_univ, Fintype.card_fin]
  unfold successProb setMass
  rw [hsucc]
  simp only [uniformDist, Finset.sum_const, nsmul_eq_mul, hcard, Fintype.card_fin]
  push_cast
  ring

end AlmostLossless