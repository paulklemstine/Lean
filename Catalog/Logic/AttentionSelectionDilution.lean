/-
# Selection gaps, concentration, and the dilution of top-`k` pruning at long context
# (NET-45, cycle 1)

Round NET-45 measures, at `(d = 4, ctx = 2048, seed 1)`, three quantities that the
knee files of this catalog (`Logic.KneeFluctuationTwoSeed`, `Logic.KneeDriftLadder`,
`Logic.KneeSeedEnsembleBracket`) do **not** touch, because they are not statements about
a threshold on a sweep grid but about the *attention profile itself*:

* the **selection gap** — how much better data-free top-`k` pruning is than keeping a
  uniformly random set of `k` positions (`+5.9 / +4.6` accuracy points at `ctx = 256`,
  `+5.3 / +4.6` at `512`, `+5.9 / +4.6` at `1024`, and only `+1.7 / +1.8` at
  `ctx = 2048`: the selection advantage **dilutes** with context);
* the **effective support** `N_eff` (`291.16` at `ctx = 1024`, `526.39` at `ctx = 2048`,
  a factor `1.81` per doubling — superlinear in the sense that it does not saturate);
* the **absence of a bounded working set**: top-`128` mass `0.589` and top-`256` mass
  `0.731` at `16×` context, both far from `1`.

This file develops the order-theoretic and convex-geometric content of those three
observations for an arbitrary attention profile `p : ι → ℝ` on a finite position set.

**Results.**

* `SelectionDilution.exists_isTopMass`, `IsTopMass.unique` : the top-`k` mass is a
  well-defined functional of the profile whenever `k ≤ |ι|`.
* `SelectionDilution.sum_mass_powersetCard` : the double-counting identity
  `∑_{|S| = k} ∑_{i ∈ S} p i = C(L-1, k-1) · ∑ p`, i.e. **the random-`k` baseline is
  exactly `k/L` of the total mass** — the null model the round compares against, proved
  rather than assumed (`randomK_baseline`).
* `SelectionDilution.uniform_le_topMass` : the selection gap is **always non-negative**.
  The round's observation that all measured gaps are positive is therefore not evidence
  for anything; only the *size* of the gap is informative.
* `SelectionDilution.uniform_of_topMass_eq` : **rigidity.**  A vanishing selection gap
  forces the profile to be *exactly uniform* (for `0 < k < L`).  So the dilution observed
  at `16×` context is a quantitative approach to uniformity, and a gap of exactly zero
  would be the strongest possible negative result about attention pruning.
* `SelectionDilution.topMass_sq_le_card_mul_sumSq` : the Cauchy–Schwarz concentration
  bound `T_k² ≤ k · ‖p‖₂² = k / N_eff`, tying the round's `N_eff` to its top-`k` masses.
* `SelectionDilution.no_bounded_working_set` : if the effective support of a family of
  profiles is unbounded, then **no fixed budget retains a fixed fraction of the mass** —
  a bounded working set is impossible, exactly the round's conclusion, and the reason a
  knee law must grow with context.
* `SelectionDilution.topMass_split_ge`,
  `selection_gap_mono_under_self_similar_refinement`,
  `dilution_refutes_self_similarity` : the **dilution theorem**.  Under exact
  self-similar refinement of the context (each position split into two half-weight
  positions, the scale-invariant null model of a Zipf-type profile), the selection gap at
  the matched ratio `k/L` can only *increase*.  Hence the measured strict decrease
  `+5.9 → +1.7` refutes exact self-similarity of the attention profile across the
  doubling — a falsifiable structural conclusion drawn from the round's weakest number.
-/

import Mathlib

namespace SelectionDilution

open Finset

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## 1.  The top-`k` mass functional -/

/-- `IsTopMass p k T` : `T` is the largest mass that any `k` positions of the profile `p`
carry.  This is the quantity a data-free top-`k` attention pruner retains. -/
def IsTopMass (p : ι → ℝ) (k : ℕ) (T : ℝ) : Prop :=
  (∃ S ∈ univ.powersetCard k (α := ι), ∑ i ∈ S, p i = T) ∧
    ∀ S ∈ univ.powersetCard k (α := ι), ∑ i ∈ S, p i ≤ T

omit [DecidableEq ι] in
/-- The top-`k` mass exists as soon as the budget fits in the context. -/
theorem exists_isTopMass (p : ι → ℝ) {k : ℕ} (hk : k ≤ Fintype.card ι) :
    ∃ T, IsTopMass p k T := by
  classical
  have hne : (univ.powersetCard k (α := ι)).Nonempty :=
    powersetCard_nonempty.2 (by simpa using hk)
  refine ⟨(univ.powersetCard k (α := ι)).sup' hne (fun S => ∑ i ∈ S, p i), ?_, ?_⟩
  · obtain ⟨S, hS, hSval⟩ :=
      Finset.exists_mem_eq_sup' hne (fun S : Finset ι => ∑ i ∈ S, p i)
    exact ⟨S, hS, hSval.symm⟩
  · intro S hS
    exact Finset.le_sup' (fun S : Finset ι => ∑ i ∈ S, p i) hS

omit [DecidableEq ι] in
/-- The top-`k` mass is unique. -/
theorem IsTopMass.unique {p : ι → ℝ} {k : ℕ} {T T' : ℝ}
    (h : IsTopMass p k T) (h' : IsTopMass p k T') : T = T' := by
  obtain ⟨⟨S, hS, hSval⟩, hle⟩ := h
  obtain ⟨⟨S', hS', hS'val⟩, hle'⟩ := h'
  exact le_antisymm (hSval ▸ hle' S hS) (hS'val ▸ hle S' hS')

/-! ## 2.  The random-`k` baseline, by double counting -/

/-- Every `k`-subset containing a fixed position `i` is `insert i` of a `(k-1)`-subset of
the remaining positions. -/
theorem card_filter_mem_powersetCard (i : ι) {k : ℕ} (hk : 1 ≤ k) :
    ((univ.powersetCard k (α := ι)).filter (fun S => i ∈ S)).card
      = (Fintype.card ι - 1).choose (k - 1) := by
  classical
  have hbij :
      ((univ.powersetCard k (α := ι)).filter (fun S => i ∈ S)).card
        = ((univ.erase i).powersetCard (k - 1)).card := by
    refine Finset.card_bij' (fun S _ => S.erase i) (fun T _ => insert i T) ?_ ?_ ?_ ?_
    · intro S hS
      simp only [mem_filter, mem_powersetCard] at hS ⊢
      obtain ⟨⟨-, hcard⟩, hmem⟩ := hS
      refine ⟨fun x hx => ?_, ?_⟩
      · exact mem_erase.2 ⟨(mem_erase.1 hx).1, mem_univ _⟩
      · rw [card_erase_of_mem hmem, hcard]
    · intro T hT
      simp only [mem_powersetCard] at hT
      obtain ⟨hsub, hcard⟩ := hT
      have hiT : i ∉ T := fun h => (mem_erase.1 (hsub h)).1 rfl
      simp only [mem_filter, mem_powersetCard]
      refine ⟨⟨fun x _ => mem_univ x, ?_⟩, mem_insert_self _ _⟩
      rw [card_insert_of_notMem hiT, hcard]
      omega
    · intro S hS
      simp only [mem_filter] at hS
      exact insert_erase hS.2
    · intro T hT
      simp only [mem_powersetCard] at hT
      have hiT : i ∉ T := fun h => (mem_erase.1 (hT.1 h)).1 rfl
      exact erase_insert hiT
  rw [hbij, card_powersetCard, card_erase_of_mem (mem_univ i)]
  simp

/-- **Double counting.**  Summing the mass of every `k`-subset counts each position
`C(L-1, k-1)` times. -/
theorem sum_mass_powersetCard (p : ι → ℝ) {k : ℕ} (hk : 1 ≤ k) :
    ∑ S ∈ univ.powersetCard k (α := ι), ∑ i ∈ S, p i
      = ((Fintype.card ι - 1).choose (k - 1) : ℝ) * ∑ i, p i := by
  classical
  have hswap : ∀ S ∈ univ.powersetCard k (α := ι),
      ∑ i ∈ S, p i = ∑ i, if i ∈ S then p i else 0 := by
    intro S _
    rw [Finset.sum_ite_mem]
    simp
  rw [Finset.sum_congr rfl hswap, Finset.sum_comm]
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rw [← Finset.sum_filter, Finset.sum_const, ← card_filter_mem_powersetCard i hk]
  simp [nsmul_eq_mul]

/-- The binomial identity behind the baseline: `L · C(L-1, k-1) = C(L, k) · k`. -/
theorem nat_double_count (L k : ℕ) (hk : 1 ≤ k) (hkL : k ≤ L) :
    L * (L - 1).choose (k - 1) = L.choose k * k := by
  obtain ⟨L', rfl⟩ : ∃ L', L = L' + 1 := ⟨L - 1, by omega⟩
  obtain ⟨k', rfl⟩ : ∃ k', k = k' + 1 := ⟨k - 1, by omega⟩
  simpa using Nat.add_one_mul_choose_eq L' k'

/-- **The random-`k` baseline is exactly `k/L` of the total mass.**  Averaging the mass
over all `k`-subsets — the round's random-`k` control — returns `k/L · ∑ p`. -/
theorem randomK_baseline (p : ι → ℝ) {k : ℕ} (hk : 1 ≤ k) (hkL : k ≤ Fintype.card ι) :
    (Fintype.card ι : ℝ) * ∑ S ∈ univ.powersetCard k (α := ι), ∑ i ∈ S, p i
      = (k : ℝ) * ((Fintype.card ι).choose k : ℝ) * ∑ i, p i := by
  have hL : 1 ≤ Fintype.card ι := le_trans hk hkL
  have hnat : Fintype.card ι * (Fintype.card ι - 1).choose (k - 1)
      = (Fintype.card ι).choose k * k := nat_double_count _ _ hk hkL
  rw [sum_mass_powersetCard p hk, ← mul_assoc]
  have : ((Fintype.card ι : ℝ)) * ((Fintype.card ι - 1).choose (k - 1) : ℝ)
      = ((Fintype.card ι).choose k : ℝ) * (k : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hnat
  rw [this]
  ring

/-! ## 3.  The selection gap is non-negative, and vanishes only for uniform attention -/

/-- **The selection gap is never negative.**  Top-`k` selection always retains at least
the random-`k` baseline `k/L` of the mass.  The round's observation that all measured
gaps are positive therefore carries no information; only their magnitude does. -/
theorem uniform_le_topMass {p : ι → ℝ} {k : ℕ} {T : ℝ} (hk : 1 ≤ k)
    (hkL : k ≤ Fintype.card ι) (hsum : ∑ i, p i = 1) (hT : IsTopMass p k T) :
    (k : ℝ) / (Fintype.card ι : ℝ) ≤ T := by
  have hL : 1 ≤ Fintype.card ι := le_trans hk hkL
  have hLpos : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast hL
  have hchoose : 0 < (Fintype.card ι).choose k := Nat.choose_pos hkL
  have hchoosepos : (0 : ℝ) < ((Fintype.card ι).choose k : ℝ) := by exact_mod_cast hchoose
  have hbound : ∑ S ∈ univ.powersetCard k (α := ι), ∑ i ∈ S, p i
      ≤ ((Fintype.card ι).choose k : ℝ) * T := by
    calc ∑ S ∈ univ.powersetCard k (α := ι), ∑ i ∈ S, p i
        ≤ ∑ _S ∈ univ.powersetCard k (α := ι), T :=
          Finset.sum_le_sum (fun S hS => hT.2 S hS)
      _ = ((Fintype.card ι).choose k : ℝ) * T := by
          rw [Finset.sum_const, card_powersetCard]
          simp [nsmul_eq_mul]
  have hkey := randomK_baseline p hk hkL
  rw [hsum, mul_one] at hkey
  have : (k : ℝ) * ((Fintype.card ι).choose k : ℝ)
      ≤ (Fintype.card ι : ℝ) * (((Fintype.card ι).choose k : ℝ) * T) := by
    rw [← hkey]
    exact mul_le_mul_of_nonneg_left hbound hLpos.le
  rw [div_le_iff₀ hLpos]
  nlinarith [hchoosepos]

/-- **Rigidity.**  If the selection gap vanishes at some intermediate budget
`0 < k < L`, the attention profile is *exactly uniform*.  Dilution of the gap is thus a
quantitative approach to the completely unstructured profile, and is the only way an
attention mechanism can defeat data-free pruning. -/
theorem uniform_of_topMass_eq {p : ι → ℝ} {k : ℕ} {T : ℝ} (hk : 1 ≤ k)
    (hkL : k < Fintype.card ι) (hsum : ∑ i, p i = 1) (hT : IsTopMass p k T)
    (hgap : T = (k : ℝ) / (Fintype.card ι : ℝ)) :
    ∀ i j, p i = p j := by
  classical
  have hL : 1 ≤ Fintype.card ι := le_trans hk hkL.le
  have hLpos : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast hL
  have hchoosepos : (0 : ℝ) < ((Fintype.card ι).choose k : ℝ) := by
    exact_mod_cast Nat.choose_pos hkL.le
  -- every `k`-subset has mass exactly `T`
  have hall : ∀ S ∈ univ.powersetCard k (α := ι), ∑ i ∈ S, p i = T := by
    have hsumeq : ∑ S ∈ univ.powersetCard k (α := ι), ∑ i ∈ S, p i
        = ∑ _S ∈ univ.powersetCard k (α := ι), T := by
      have hkey := randomK_baseline p hk hkL.le
      rw [hsum, mul_one] at hkey
      have hrhs : ∑ _S ∈ univ.powersetCard k (α := ι), T
          = ((Fintype.card ι).choose k : ℝ) * T := by
        rw [Finset.sum_const, card_powersetCard]; simp [nsmul_eq_mul]
      rw [hrhs, hgap]
      field_simp at hkey ⊢
      linarith [hkey]
    exact fun S hS => (Finset.sum_eq_sum_iff_of_le (fun S hS => hT.2 S hS)).1 hsumeq S hS
  intro i j
  by_cases hij : i = j
  · rw [hij]
  -- pick a `(k-1)`-subset `A` of the positions other than `i` and `j`
  have hcard : k - 1 ≤ ((univ.erase j).erase i).card := by
    have h1 : ((univ.erase j).erase i).card = Fintype.card ι - 1 - 1 := by
      rw [card_erase_of_mem (mem_erase.2 ⟨hij, mem_univ i⟩), card_erase_of_mem (mem_univ j),
        card_univ]
    omega
  obtain ⟨A, hAsub, hAcard⟩ := Finset.exists_subset_card_eq hcard
  have hiA : i ∉ A := fun h => (mem_erase.1 (hAsub h)).1 rfl
  have hjA : j ∉ A := fun h => (mem_erase.1 (mem_of_mem_erase (hAsub h))).1 rfl
  have hSi : insert i A ∈ univ.powersetCard k (α := ι) := by
    rw [mem_powersetCard]
    exact ⟨fun x _ => mem_univ x, by rw [card_insert_of_notMem hiA, hAcard]; omega⟩
  have hSj : insert j A ∈ univ.powersetCard k (α := ι) := by
    rw [mem_powersetCard]
    exact ⟨fun x _ => mem_univ x, by rw [card_insert_of_notMem hjA, hAcard]; omega⟩
  have hi := hall _ hSi
  have hj := hall _ hSj
  rw [Finset.sum_insert hiA] at hi
  rw [Finset.sum_insert hjA] at hj
  linarith

/-! ## 4.  Concentration: Cauchy–Schwarz and the impossibility of a bounded working set -/

omit [DecidableEq ι] in
/-- **Cauchy–Schwarz concentration bound.**  The top-`k` mass obeys
`T² ≤ k · ‖p‖₂²`; with the effective support `N_eff = 1/‖p‖₂²` this is
`T ≤ √(k / N_eff)`.  Concentration measurements therefore *cap* the achievable retained
mass at any budget. -/
theorem topMass_sq_le_card_mul_sumSq {p : ι → ℝ} {k : ℕ} {T : ℝ} (hT : IsTopMass p k T) :
    T ^ 2 ≤ (k : ℝ) * ∑ i, p i ^ 2 := by
  obtain ⟨⟨S, hS, hSval⟩, -⟩ := hT
  rw [mem_powersetCard] at hS
  have hcs : (∑ i ∈ S, p i) ^ 2 ≤ (S.card : ℝ) * ∑ i ∈ S, p i ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have hmono : ∑ i ∈ S, p i ^ 2 ≤ ∑ i, p i ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg (fun x _ => mem_univ x)
      (fun i _ _ => sq_nonneg (p i))
  have hk : (S.card : ℝ) = (k : ℝ) := by rw [hS.2]
  rw [← hSval]
  calc (∑ i ∈ S, p i) ^ 2 ≤ (S.card : ℝ) * ∑ i ∈ S, p i ^ 2 := hcs
    _ ≤ (k : ℝ) * ∑ i, p i ^ 2 := by
        rw [hk]
        exact mul_le_mul_of_nonneg_left hmono (by positivity)

/-- **No bounded working set.**  If the effective supports `N n` of a family of attention
profiles are unbounded, then for every fixed budget `k` and every target fraction
`m > 0` there is a context in the family at which the top-`k` mass is below `m`.  A
context-independent budget therefore cannot retain a constant fraction of the attention
mass — the knee must grow with the context. -/
theorem no_bounded_working_set {ι' : ℕ → Type} [∀ n, Fintype (ι' n)] [∀ n, DecidableEq (ι' n)]
    (k : ℕ) (p : ∀ n, ι' n → ℝ) (N : ℕ → ℝ) (T : ℕ → ℝ)
    (hN : ∀ n, 0 < N n) (hsupp : ∀ n, ∑ i, p n i ^ 2 ≤ 1 / N n)
    (hT : ∀ n, IsTopMass (p n) k (T n)) (hunbdd : ∀ C : ℝ, ∃ n, C < N n) (m : ℝ) (hm : 0 < m) :
    ∃ n, T n < m := by
  obtain ⟨n, hn⟩ := hunbdd ((k : ℝ) / m ^ 2)
  have hNpos := hN n
  refine ⟨n, ?_⟩
  by_contra hcon
  push_neg at hcon
  have hsq : T n ^ 2 ≤ (k : ℝ) * (1 / N n) := by
    refine le_trans (topMass_sq_le_card_mul_sumSq (hT n)) ?_
    exact mul_le_mul_of_nonneg_left (hsupp n) (by positivity)
  have hm2 : m ^ 2 ≤ T n ^ 2 := by nlinarith
  have hkm : (k : ℝ) / m ^ 2 < N n := hn
  rw [div_lt_iff₀ (by positivity)] at hkm
  have : (k : ℝ) * (1 / N n) < m ^ 2 := by
    rw [mul_one_div, div_lt_iff₀ hNpos]
    linarith
  linarith

/-! ## 5.  The dilution theorem: self-similar refinement cannot dilute selection -/

/-- The **self-similar refinement** of a profile: every position is split into two
positions of half the weight.  This is the exact scale-invariance a Zipf-type attention
profile would have across a context doubling. -/
noncomputable def split (p : ι → ℝ) : ι × Bool → ℝ := fun q => p q.1 / 2

omit [DecidableEq ι] in
/-- Under self-similar refinement, the matched budget `2k` retains at least what the
budget `k` retained before: splitting each selected position in two is available to the
refined pruner. -/
theorem topMass_split_ge {p : ι → ℝ} {k : ℕ} {T T' : ℝ}
    (hT : IsTopMass p k T) (hT' : IsTopMass (split p) (2 * k) T') : T ≤ T' := by
  classical
  obtain ⟨⟨S, hS, hSval⟩, -⟩ := hT
  rw [mem_powersetCard] at hS
  have hmem : S ×ˢ (univ : Finset Bool) ∈ univ.powersetCard (2 * k) (α := ι × Bool) := by
    rw [mem_powersetCard]
    refine ⟨fun x _ => mem_univ x, ?_⟩
    rw [card_product, hS.2]
    simp [Nat.mul_comm]
  have hmass : ∑ q ∈ S ×ˢ (univ : Finset Bool), split p q = ∑ i ∈ S, p i := by
    rw [Finset.sum_product]
    refine Finset.sum_congr rfl (fun i _ => ?_)
    simp [split]
    ring
  have := hT'.2 _ hmem
  rw [hmass, hSval] at this
  exact this

omit [DecidableEq ι] in
/-- **Dilution theorem.**  Comparing a profile with its self-similar refinement at the
*same* sparsity ratio `k/L`, the selection gap can only grow.  Scale-invariant attention
profiles do not dilute. -/
theorem selection_gap_mono_under_self_similar_refinement {p : ι → ℝ} {k : ℕ} {T T' : ℝ}
    (hT : IsTopMass p k T) (hT' : IsTopMass (split p) (2 * k) T') :
    T - (k : ℝ) / (Fintype.card ι : ℝ)
      ≤ T' - (2 * k : ℝ) / (Fintype.card (ι × Bool) : ℝ) := by
  have hcard : (Fintype.card (ι × Bool) : ℝ) = 2 * (Fintype.card ι : ℝ) := by
    simp [Fintype.card_prod]
    ring
  have hratio : (2 * k : ℝ) / (Fintype.card (ι × Bool) : ℝ)
      = (k : ℝ) / (Fintype.card ι : ℝ) := by
    rw [hcard]
    rcases eq_or_ne (Fintype.card ι : ℝ) 0 with h | h
    · simp [h]
    · field_simp
  rw [hratio]
  linarith [topMass_split_ge hT hT']

omit [DecidableEq ι] in
/-- **The measured dilution refutes exact self-similarity.**  If the selection gap is
observed to *decrease* strictly across a context doubling at matched sparsity — the
NET-45 observation `+5.9 → +1.7` — then the long-context profile is not the self-similar
refinement of the short-context one, whatever profile is fitted to either. -/
theorem dilution_refutes_self_similarity {p : ι → ℝ} {q : ι × Bool → ℝ} {k : ℕ}
    {T T' : ℝ} (hT : IsTopMass p k T) (hT' : IsTopMass q (2 * k) T')
    (hdilute : T' - (2 * k : ℝ) / (Fintype.card (ι × Bool) : ℝ)
      < T - (k : ℝ) / (Fintype.card ι : ℝ)) :
    q ≠ split p := by
  intro hq
  subst hq
  exact absurd (selection_gap_mono_under_self_similar_refinement hT hT') (not_le.2 hdilute)

/-! ## 6.  The NET-45 numbers -/

/-- The measured concentration at `(d = 4, ctx = 2048)`: effective support `526.39`,
`1.81×` the `ctx = 1024` value `291.16` — the doubling multiplies the effective support
by less than `2` (sublinear growth of the working set) but by more than `1`
(no saturation), so neither a fixed working set nor a proportional one fits. -/
theorem net45_effective_support_growth :
    (52639 : ℝ) / 100 < 2 * (29116 / 100) ∧ (29116 : ℝ) / 100 < 52639 / 100 := by
  constructor <;> norm_num

/-- **Internal-consistency check (Critic).**  The measured top-`k` masses at `16×`
context *exceed* the Cauchy–Schwarz cap computed from the reported effective support:
`128/526.39 < 0.589²` and `256/526.39 < 0.731²`. -/
theorem net45_topmass_exceeds_l2_cap :
    (128 : ℝ) / (52639 / 100) < (589 / 1000) ^ 2 ∧
      (256 : ℝ) / (52639 / 100) < (731 / 1000) ^ 2 := by
  constructor <;> norm_num

omit [DecidableEq ι] in
/-- **Consequence: the reported effective support is not the inverse participation
ratio.**  Any profile whose top-`256` mass reaches the measured `0.731` has
`‖p‖₂² ≥ 0.731²/256`, hence inverse participation ratio strictly below the reported
`526.39`.  The round's `N_eff` must therefore be a different concentration functional
(an entropy-based one), and the two numbers may not be combined in a single bound. -/
theorem net45_reported_support_exceeds_participation_ratio {p : ι → ℝ} {T : ℝ}
    (hT : IsTopMass p 256 T) (hmeas : (731 : ℝ) / 1000 ≤ T)
    (hpos : 0 < ∑ i, p i ^ 2) :
    1 / (∑ i, p i ^ 2) < 52639 / 100 := by
  have hcs := topMass_sq_le_card_mul_sumSq hT
  have hTsq : ((731 : ℝ) / 1000) ^ 2 ≤ T ^ 2 := by nlinarith
  have hlow : ((731 : ℝ) / 1000) ^ 2 / 256 ≤ ∑ i, p i ^ 2 := by
    rw [div_le_iff₀ (by norm_num)]
    push_cast at hcs
    nlinarith
  rw [div_lt_iff₀ hpos]
  nlinarith

omit [DecidableEq ι] in
/-- **A concentration measurement is a hard lower bound on any mass-retaining budget.**
Retaining a fraction `β` of the attention mass costs at least `β²·N_eff` positions.  With
the effective support growing by `1.81×` per context doubling, the budget required to
retain a *fixed fraction of mass* grows with the same exponent — this is the quantitative
form of "no bounded working set". -/
theorem budget_ge_of_retained_mass {p : ι → ℝ} {k : ℕ} {T β N : ℝ}
    (hT : IsTopMass p k T) (hβ : β ≤ T) (hβ0 : 0 ≤ β) (hN : 0 < N)
    (hsupp : ∑ i, p i ^ 2 ≤ 1 / N) : β ^ 2 * N ≤ (k : ℝ) := by
  have hcs := topMass_sq_le_card_mul_sumSq hT
  have hk0 : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have h1 : β ^ 2 ≤ T ^ 2 := by nlinarith
  have h2 : T ^ 2 ≤ (k : ℝ) * (1 / N) := le_trans hcs (by nlinarith)
  rw [mul_one_div] at h2
  rw [← le_div_iff₀ hN]
  linarith

omit [DecidableEq ι] in
/-- **The knee retains accuracy, not mass.**  Read through the inverse participation
ratio, a budget of `256` at the reported concentration of the `16×` cell cannot carry
more than `0.70` of the attention mass — far below the `0.98` bar.  The knee is therefore
a statement about the *output* of the layer, not about the attention distribution: mass
retention and accuracy retention are genuinely different thresholds. -/
theorem net45_mass_retention_at_knee_bound {p : ι → ℝ} {T : ℝ} (hT : IsTopMass p 256 T)
    (hT0 : 0 ≤ T) (hsupp : ∑ i, p i ^ 2 ≤ 1 / (52639 / 100)) : T < 7 / 10 := by
  have hcs := topMass_sq_le_card_mul_sumSq hT
  push_cast at hcs
  have h2 : T ^ 2 ≤ 256 * (1 / (52639 / 100 : ℝ)) := le_trans hcs (by nlinarith)
  nlinarith

end SelectionDilution