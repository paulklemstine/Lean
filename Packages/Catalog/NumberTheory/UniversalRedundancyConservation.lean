/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality VI: conservation of bits

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1:
does specialising the decompressor really **move bits from the message into the
shared decompressor**?

This file answers that question exactly, on the cleanest possible model class:
a *file-type* class.  Fix a classifier `f : X → κ` (the "file type") and let the
source `P_c` be uniform on the files of type `c`.  Then

* a decompressor specialised to the type `c` needs exactly `log₂ #f⁻¹(c)` bits
  per file (the entropy of `P_c`), and
* one shared decompressor serving all types must pay `log₂ #κ` extra bits on
  average against some type, while the uniform Bayes mixture pays no more than
  that against any type (`fiberClass_price_exact`),

so the total, `log₂ #f⁻¹(c) + log₂ #κ`, is again the number of bits needed with
no class knowledge at all (`fiberClass_conservation`, and the explicit two-block
form `bit_conservation_blocks`).  Specialisation therefore *moves* exactly
`log₂ #κ` bits from the message into the identity of the decompressor — never
more, never less.

The file also proves two generally useful robustness tools:

* `logSum_inequality` — the log-sum (data-processing) inequality for the
  Kullback–Leibler sum over a block;
* `exists_kl_ge_of_approx_disjoint` — the *approximate* singularity bound: if
  the sources merely concentrate (mass `≥ 1 - δ`) on disjoint sets, the price of
  universality is still at least `(1-δ) log₂ #Θ - 4` bits, so the exact
  disjointness hypothesis of `singular_minimax_average_exact` is not a knife
  edge.

## Application keywords

universal compression, minimax redundancy, log-sum inequality, typical sets,
file types, price of universality, conservation of description length
-/

import Catalog.NumberTheory.UniversalRedundancyAverage

open Finset Real

namespace UniversalRedundancy

variable {X : Type*} [Fintype X]

/-! ## The log-sum inequality -/

omit [Fintype X] in
/-- **Log-sum inequality.**  Lumping a block `s` of messages into a single
symbol can only decrease the Kullback–Leibler sum. -/
theorem logSum_inequality {s : Finset X} {p q : X → ℝ} (hp : ∀ x ∈ s, 0 ≤ p x)
    (hq : ∀ x ∈ s, 0 < q x) (hps : 0 < ∑ x ∈ s, p x) :
    (∑ x ∈ s, p x) * logb 2 ((∑ x ∈ s, p x) / (∑ x ∈ s, q x))
      ≤ ∑ x ∈ s, p x * logb 2 (p x / q x) := by
  have hne : s.Nonempty := by
    rcases Finset.eq_empty_or_nonempty s with he | hne
    · subst he; simp at hps
    · exact hne
  have hQpos : 0 < ∑ x ∈ s, q x := Finset.sum_pos hq hne
  have hQne : (∑ x ∈ s, q x) ≠ 0 := ne_of_gt hQpos
  have hratio : 0 < (∑ y ∈ s, p y) / (∑ y ∈ s, q y) := div_pos hps hQpos
  have hgibbs : 0 ≤ ∑ x ∈ s, p x *
      logb 2 (p x / (q x * ((∑ y ∈ s, p y) / (∑ y ∈ s, q y)))) := by
    refine sum_mul_logb_div_nonneg hp (fun x hx => mul_pos (hq x hx) hratio) ?_
    rw [← Finset.sum_mul]
    have hcalc : (∑ x ∈ s, q x) * ((∑ y ∈ s, p y) / (∑ y ∈ s, q y)) = ∑ x ∈ s, p x := by
      field_simp
    rw [hcalc]
  have hterm : ∀ x ∈ s, p x * logb 2 (p x / (q x * ((∑ y ∈ s, p y) / (∑ y ∈ s, q y))))
      = p x * logb 2 (p x / q x)
        - p x * logb 2 ((∑ y ∈ s, p y) / (∑ y ∈ s, q y)) := by
    intro x hx
    rcases eq_or_lt_of_le (hp x hx) with h | h
    · simp [← h]
    · have hqx := hq x hx
      rw [Real.logb_div (ne_of_gt h) (ne_of_gt (mul_pos hqx hratio)),
        Real.logb_div (ne_of_gt h) (ne_of_gt hqx),
        Real.logb_mul (ne_of_gt hqx) (ne_of_gt hratio)]
      ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_sub_distrib, ← Finset.sum_mul] at hgibbs
  linarith

/-! ## A crude but sufficient entropy bound -/

/-- The function `t log₂ t` is bounded below by `-2` on the nonnegative reals. -/
lemma mul_logb_self_ge {t : ℝ} (ht0 : 0 ≤ t) : -2 ≤ t * logb 2 t := by
  rcases eq_or_lt_of_le ht0 with h | h
  · simp [← h]
  · have hlog2 : (0.5 : ℝ) < Real.log 2 := by
      have := Real.log_two_gt_d9
      linarith
    have hlogt : 1 - 1 / t ≤ Real.log t := by
      have h1 : Real.log (1 / t) ≤ 1 / t - 1 := Real.log_le_sub_one_of_pos (by positivity)
      have h2 : Real.log (1 / t) = -Real.log t := by rw [one_div, Real.log_inv]
      rw [h2] at h1
      linarith
    have hkey : -1 ≤ t * Real.log t := by
      have h3 := mul_le_mul_of_nonneg_left hlogt ht0
      have h4 : t * (1 - 1 / t) = t - 1 := by field_simp
      rw [h4] at h3
      linarith
    rw [Real.logb, mul_div_assoc', le_div_iff₀ (by linarith : (0:ℝ) < Real.log 2)]
    nlinarith

variable {Θ : Type*} [Fintype Θ]

namespace SourceClass

variable (S : SourceClass X Θ)

/-- **Approximate singularity.**  If the sources of the class merely
*concentrate* on pairwise disjoint sets — each `P_θ` putting mass at least
`1 - δ` on its own set `A θ` — then every universal coding distribution still
loses at least `(1-δ) log₂ #Θ - 4` bits against some source.  Exact mutual
singularity (`δ = 0`) is the case treated by
`singular_minimax_average_exact`; this shows that result is robust. -/
theorem exists_kl_ge_of_approx_disjoint [Nonempty Θ] [DecidableEq X] {δ : ℝ}
    (A : Θ → Finset X) (hdisj : ∀ θ θ', θ ≠ θ' → Disjoint (A θ) (A θ'))
    (hmass : ∀ θ, 1 - δ ≤ ∑ x ∈ A θ, S.prob θ x)
    {q : X → ℝ} (hq0 : ∀ x, 0 < q x) (hq1 : ∑ x, q x ≤ 1) :
    ∃ θ, (1 - δ) * logb 2 (Fintype.card Θ) - 4 ≤ klDiv (S.prob θ) q := by
  classical
  have hcard : (1 : ℝ) ≤ (Fintype.card Θ : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have hlogm : 0 ≤ logb 2 (Fintype.card Θ) := Real.logb_nonneg (by norm_num) hcard
  -- coding mass carried by each concentration set
  set c : Θ → ℝ := fun θ => ∑ x ∈ A θ, q x with hcdef
  have hsum : ∑ θ, c θ ≤ 1 := by
    have hpair : ((univ : Finset Θ) : Set Θ).PairwiseDisjoint A := fun θ _ θ' _ h =>
      hdisj θ θ' h
    have hb : ∑ θ, c θ = ∑ x ∈ (univ : Finset Θ).biUnion A, q x :=
      (Finset.sum_biUnion hpair).symm
    rw [hb]
    exact le_trans (Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      fun x _ _ => (hq0 x).le) hq1
  obtain ⟨θ, -, hθ⟩ : ∃ θ ∈ (univ : Finset Θ), c θ ≤ (Fintype.card Θ : ℝ)⁻¹ := by
    refine Finset.exists_le_of_sum_le ⟨Classical.arbitrary Θ, Finset.mem_univ _⟩ ?_
    calc ∑ θ, c θ ≤ 1 := hsum
      _ = ∑ _θ : Θ, (Fintype.card Θ : ℝ)⁻¹ := by
          rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
          field_simp
  refine ⟨θ, ?_⟩
  have hklnn : 0 ≤ klDiv (S.prob θ) q :=
    klDiv_nonneg (S.nonneg θ) hq0 (S.sum_one θ) hq1
  by_cases hδ : 1 - δ ≤ 0
  · nlinarith
  push_neg at hδ
  set P := ∑ x ∈ A θ, S.prob θ x with hPdef
  have hPpos : 0 < P := lt_of_lt_of_le hδ (hmass θ)
  have hP1 : P ≤ 1 := by
    rw [hPdef, ← S.sum_one θ]
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      fun x _ _ => S.nonneg θ x
  have hcθpos : 0 < c θ := by
    rcases Finset.eq_empty_or_nonempty (A θ) with he | hne
    · exfalso
      rw [hPdef, he, Finset.sum_empty] at hPpos
      exact lt_irrefl 0 hPpos
    · exact Finset.sum_pos (fun x _ => hq0 x) hne
  -- split the divergence over `A θ` and its complement
  have hsplit : klDiv (S.prob θ) q
      = (∑ x ∈ A θ, S.prob θ x * logb 2 (S.prob θ x / q x))
        + ∑ x ∈ univ \ A θ, S.prob θ x * logb 2 (S.prob θ x / q x) := by
    unfold klDiv
    exact (Finset.sum_add_sum_compl (A θ) _).symm
  -- main block: at least `(1-δ) log₂ #Θ - 2`
  have hmain : (1 - δ) * logb 2 (Fintype.card Θ) - 2
      ≤ ∑ x ∈ A θ, S.prob θ x * logb 2 (S.prob θ x / q x) := by
    have hls := logSum_inequality (s := A θ) (p := S.prob θ) (q := q)
      (fun x _ => S.nonneg θ x) (fun x _ => hq0 x) (by rw [← hPdef]; exact hPpos)
    have hcs : (∑ x ∈ A θ, q x) = c θ := rfl
    rw [← hPdef, hcs] at hls
    have hexpand : P * logb 2 (P / c θ) = P * logb 2 P + P * logb 2 (1 / c θ) := by
      rw [Real.logb_div (ne_of_gt hPpos) (ne_of_gt hcθpos), one_div, Real.logb_inv]
      ring
    have hPlogP : -2 ≤ P * logb 2 P := mul_logb_self_ge hPpos.le
    have hinv : logb 2 (Fintype.card Θ) ≤ logb 2 (1 / c θ) := by
      refine Real.logb_le_logb_of_le (by norm_num) (by linarith) ?_
      rw [le_div_iff₀ hcθpos]
      calc (Fintype.card Θ : ℝ) * c θ
          ≤ (Fintype.card Θ : ℝ) * (Fintype.card Θ : ℝ)⁻¹ := by nlinarith
        _ = 1 := by field_simp
    have hcle1 : c θ ≤ 1 := by
      have h0 : (0 : ℝ) < (Fintype.card Θ : ℝ) := by linarith
      have h2 : c θ * (Fintype.card Θ : ℝ) ≤ 1 := by
        calc c θ * (Fintype.card Θ : ℝ)
            ≤ (Fintype.card Θ : ℝ)⁻¹ * (Fintype.card Θ : ℝ) := by nlinarith
          _ = 1 := by field_simp
      nlinarith
    have hone : (1 : ℝ) ≤ 1 / c θ := by
      rw [le_div_iff₀ hcθpos, one_mul]
      exact hcle1
    have hfrac : (1 - δ) * logb 2 (Fintype.card Θ) ≤ P * logb 2 (1 / c θ) := by
      have h1 : (1 - δ) * logb 2 (Fintype.card Θ) ≤ P * logb 2 (Fintype.card Θ) := by
        nlinarith [hmass θ]
      nlinarith [Real.logb_nonneg (b := 2) (by norm_num) hone]
    linarith
  -- complement: at least `-2`
  have hcompl : -2 ≤ ∑ x ∈ univ \ A θ, S.prob θ x * logb 2 (S.prob θ x / q x) := by
    rcases Finset.eq_empty_or_nonempty (univ \ A θ) with he | hne
    · rw [he]; norm_num
    set R := ∑ x ∈ univ \ A θ, S.prob θ x with hRdef
    set Rq := ∑ x ∈ univ \ A θ, q x with hRqdef
    have hRq0 : 0 < Rq := Finset.sum_pos (fun x _ => hq0 x) hne
    have hRq1 : Rq ≤ 1 :=
      le_trans (Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        fun x _ _ => (hq0 x).le) hq1
    have hR0 : 0 ≤ R := Finset.sum_nonneg fun x _ => S.nonneg θ x
    rcases eq_or_lt_of_le hR0 with h | h
    · have hzero : ∀ x ∈ univ \ A θ, S.prob θ x = 0 :=
        (Finset.sum_eq_zero_iff_of_nonneg fun x _ => S.nonneg θ x).mp h.symm
      have : ∑ x ∈ univ \ A θ, S.prob θ x * logb 2 (S.prob θ x / q x) = 0 :=
        Finset.sum_eq_zero fun x hx => by rw [hzero x hx, zero_mul]
      rw [this]; norm_num
    · have hls := logSum_inequality (s := univ \ A θ) (p := S.prob θ) (q := q)
        (fun x _ => S.nonneg θ x) (fun x _ => hq0 x) (by rw [← hRdef]; exact h)
      rw [← hRdef, ← hRqdef] at hls
      have hR1 : R ≤ 1 := by
        rw [hRdef, ← S.sum_one θ]
        exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
          fun x _ _ => S.nonneg θ x
      have hexpand : R * logb 2 (R / Rq) = R * logb 2 R - R * logb 2 Rq := by
        rw [Real.logb_div (ne_of_gt h) (ne_of_gt hRq0)]
        ring
      have hRlogR : -2 ≤ R * logb 2 R := mul_logb_self_ge hR0
      have hRqlog : logb 2 Rq ≤ 0 := Real.logb_nonpos (by norm_num) hRq0.le hRq1
      nlinarith
  linarith

end SourceClass

/-! ## File-type classes and the conservation of bits -/

variable {κ : Type*} [Fintype κ] [DecidableEq κ] [DecidableEq X]

/-- The **file-type class** attached to a classifier `f : X → κ`: the source of
type `c` is uniform on the files of type `c`. -/
noncomputable def fiberClass (f : X → κ)
    (hf : ∀ c, (univ.filter (fun y => f y = c)).Nonempty) : SourceClass X κ where
  prob c x := if f x = c then ((univ.filter (fun y => f y = c)).card : ℝ)⁻¹ else 0
  nonneg c x := by split <;> positivity
  sum_one c := by
    have hN : 0 < ((univ.filter (fun y => f y = c)).card : ℝ) := by
      exact_mod_cast Finset.card_pos.mpr (hf c)
    rw [← Finset.sum_filter, Finset.sum_const, nsmul_eq_mul]
    field_simp

variable (f : X → κ) (hf : ∀ c, (univ.filter (fun y => f y = c)).Nonempty)

omit [Fintype κ] [DecidableEq X] in
lemma fiberClass_disjoint (c c' : κ) (h : c ≠ c') :
    Disjoint (univ.filter (fun y => f y = c)) (univ.filter (fun y => f y = c')) := by
  refine Finset.disjoint_filter.mpr fun x _ hx hx' => ?_
  exact h (hx ▸ hx')

omit [Fintype κ] [DecidableEq X] in
lemma fiberClass_mass (c : κ) :
    ∑ x ∈ univ.filter (fun y => f y = c), (fiberClass f hf).prob c x = 1 := by
  have hN : 0 < ((univ.filter (fun y => f y = c)).card : ℝ) := by
    exact_mod_cast Finset.card_pos.mpr (hf c)
  have hterm : ∀ x ∈ univ.filter (fun y => f y = c),
      (fiberClass f hf).prob c x = ((univ.filter (fun y => f y = c)).card : ℝ)⁻¹ := by
    intro x hx
    have : f x = c := (Finset.mem_filter.mp hx).2
    simp [fiberClass, this]
  rw [Finset.sum_congr rfl hterm, Finset.sum_const, nsmul_eq_mul]
  field_simp

omit [Fintype κ] [DecidableEq X] in
/-- The entropy of a file-type source is the log of the size of its type: the
code specialised to the type `c` needs exactly `log₂ #f⁻¹(c)` bits. -/
lemma entropyBits_fiberClass (c : κ) :
    entropyBits ((fiberClass f hf).prob c)
      = logb 2 ((univ.filter (fun y => f y = c)).card) := by
  have hN : 0 < ((univ.filter (fun y => f y = c)).card : ℝ) := by
    exact_mod_cast Finset.card_pos.mpr (hf c)
  have hterm : ∀ x : X, (fiberClass f hf).prob c x * logb 2 ((fiberClass f hf).prob c x)
      = if f x = c then
          ((univ.filter (fun y => f y = c)).card : ℝ)⁻¹
            * logb 2 (((univ.filter (fun y => f y = c)).card : ℝ)⁻¹)
        else 0 := by
    intro x
    by_cases h : f x = c <;> simp [fiberClass, h]
  rw [entropyBits, Finset.sum_congr rfl (fun x _ => hterm x), ← Finset.sum_filter,
    Finset.sum_const, nsmul_eq_mul, Real.logb_inv]
  field_simp

/-- **The price of universality of a file-type class is exactly `log₂ #κ`.**
The uniform Bayes mixture pays at most that against every type, and every
coding distribution pays at least that against some type. -/
theorem fiberClass_price_exact [Nonempty κ] :
    (∀ c : κ, klDiv ((fiberClass f hf).prob c)
        ((fiberClass f hf).mix (uniformPrior κ)) ≤ logb 2 (Fintype.card κ)) ∧
      (∀ q : X → ℝ, (∀ x, 0 < q x) → ∑ x, q x ≤ 1 →
        ∃ c : κ, logb 2 (Fintype.card κ) ≤ klDiv ((fiberClass f hf).prob c) q) :=
  (fiberClass f hf).singular_minimax_average_exact _ (fiberClass_disjoint f)
    (fiberClass_mass f hf)

/-- **Conservation of bits.**  For every Kraft-compliant code there is a file
type `c` on which the expected code length is at least

`log₂ #f⁻¹(c)` (what the decompressor specialised to `c` needs)
`+ log₂ #κ`  (the price of serving all types with one decompressor).

Specialising the decompressor moves exactly `log₂ #κ` bits out of the message
and into the identity of the decompressor: the total description length is
unchanged. -/
theorem fiberClass_conservation [Nonempty κ] (ℓ : X → ℕ) (hℓ : SourceClass.Kraft ℓ) :
    ∃ c : κ, logb 2 ((univ.filter (fun y => f y = c)).card) + logb 2 (Fintype.card κ)
      ≤ avgLen ((fiberClass f hf).prob c) (fun x => (ℓ x : ℝ)) := by
  obtain ⟨c, hc⟩ := (fiberClass f hf).exists_kl_ge_logb_card_of_disjoint
    (fun c => univ.filter (fun y => f y = c)) (fiberClass_disjoint f) (fiberClass_mass f hf)
    (q := fun x => (2 : ℝ) ^ (-(ℓ x : ℤ))) (fun x => by positivity) hℓ
  refine ⟨c, ?_⟩
  rw [klDiv_code_eq ((fiberClass f hf).nonneg c) ℓ, entropyBits_fiberClass] at hc
  linarith

/-- **Two-block form of the conservation law.**  On messages consisting of a
"type" block `A` and a "payload" block `B`, every Kraft-compliant code spends,
for some type, at least `log₂ #B + log₂ #A` bits on average — exactly the
length of the whole message.  A decompressor specialised to one type spends only
`log₂ #B`; the missing `log₂ #A` bits are precisely the ones absorbed into the
choice of decompressor. -/
theorem prodFiber_nonempty {A B : Type*} [Fintype A] [DecidableEq A] [Fintype B] [Nonempty B]
    (c : A) : (univ.filter (fun y : A × B => y.1 = c)).Nonempty :=
  ⟨(c, Classical.arbitrary B), by simp⟩

theorem bit_conservation_blocks {A B : Type*} [Fintype A] [DecidableEq A] [Nonempty A]
    [Fintype B] [DecidableEq B] [Nonempty B]
    (ℓ : A × B → ℕ) (hℓ : SourceClass.Kraft ℓ) :
    ∃ c : A, logb 2 (Fintype.card B) + logb 2 (Fintype.card A)
      ≤ avgLen ((fiberClass Prod.fst prodFiber_nonempty).prob c) (fun x => (ℓ x : ℝ)) := by
  set hf : ∀ c : A, (univ.filter (fun y : A × B => y.1 = c)).Nonempty := prodFiber_nonempty
  obtain ⟨c, hc⟩ := fiberClass_conservation (Prod.fst : A × B → A) hf ℓ hℓ
  refine ⟨c, ?_⟩
  have hfib : (univ.filter (fun y : A × B => y.1 = c)) = ({c} : Finset A) ×ˢ (univ : Finset B) := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_product,
      Finset.mem_singleton, and_true]
  rw [hfib, Finset.card_product] at hc
  simpa using hc

end UniversalRedundancy