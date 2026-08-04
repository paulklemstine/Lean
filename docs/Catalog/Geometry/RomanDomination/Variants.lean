/-
# Roman-type domination parameters and the inequality chain

This file develops, from scratch, the family of *Roman-type domination* parameters
studied in the literature on Roman domination and its variants:

* the **domination number** `gammaDom G`,
* the **Roman domination number** `gammaR G`,
* the **Italian (a.k.a. Roman-{2}) domination number** `gammaI G`,
* the **double Roman domination number** `gammaDR G`,
* the **perfect Roman domination number** `gammaPR G`,
* the **unique response Roman domination number** `gammaUR G`.

All of them are defined as an infimum of the weight `∑ v, f v` over a class of
functions `f : V → ℕ` satisfying a local protection condition, and all of them are
well defined (the defining set of weights is non-empty) for every finite graph.

The main results are the classical comparison inequalities relating these six
parameters, together with the general upper bound `γ_R(G) ≤ n` and the exact value
`γ_R(G) = n` for the edgeless graph.
-/

import Mathlib

namespace RomanDomination

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The weight of a labelling `f : V → ℕ` is the sum of its values. -/
def weight (f : V → ℕ) : ℕ := ∑ v, f v

section Defs

variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- `S` dominates `G` if every vertex lies in `S` or has a neighbour in `S`. -/
def IsDominating (S : Finset V) : Prop := ∀ v, v ∈ S ∨ ∃ u ∈ S, G.Adj v u

/-- A *Roman dominating function*: values in `{0,1,2}` such that every vertex
labelled `0` has a neighbour labelled `2`. -/
def IsRDF (f : V → ℕ) : Prop :=
  (∀ v, f v ≤ 2) ∧ ∀ v, f v = 0 → ∃ u, G.Adj v u ∧ f u = 2

/-- An *Italian* (Roman-`{2}`) *dominating function*: values in `{0,1,2}` such that
the labels in the neighbourhood of any `0`-vertex sum to at least `2`. -/
def IsIDF (f : V → ℕ) : Prop :=
  (∀ v, f v ≤ 2) ∧ ∀ v, f v = 0 → 2 ≤ ∑ u ∈ G.neighborFinset v, f u

/-- A *double Roman dominating function*: values in `{0,1,2,3}` such that every
`0`-vertex has either a neighbour labelled `3` or two neighbours labelled at least `2`,
and every `1`-vertex has a neighbour labelled at least `2`. -/
def IsDRDF (f : V → ℕ) : Prop :=
  (∀ v, f v ≤ 3) ∧
  (∀ v, f v = 0 → (∃ u, G.Adj v u ∧ f u = 3) ∨
      ∃ u w, u ≠ w ∧ G.Adj v u ∧ G.Adj v w ∧ 2 ≤ f u ∧ 2 ≤ f w) ∧
  (∀ v, f v = 1 → ∃ u, G.Adj v u ∧ 2 ≤ f u)

/-- A *perfect Roman dominating function*: values in `{0,1,2}` and every `0`-vertex
has **exactly one** neighbour labelled `2`. -/
def IsPRDF (f : V → ℕ) : Prop :=
  (∀ v, f v ≤ 2) ∧ ∀ v, f v = 0 → ∃! u, G.Adj v u ∧ f u = 2

/-- A *unique response Roman dominating function*: every `0`-vertex has exactly one
neighbour labelled `2`, and no vertex with a positive label has a neighbour labelled `2`. -/
def IsURRDF (f : V → ℕ) : Prop :=
  (∀ v, f v ≤ 2) ∧ (∀ v, f v = 0 → ∃! u, G.Adj v u ∧ f u = 2) ∧
  (∀ v, 1 ≤ f v → ∀ u, G.Adj v u → f u ≠ 2)

/-- The domination number `γ(G)`. -/
noncomputable def gammaDom : ℕ := sInf {k | ∃ S : Finset V, IsDominating G S ∧ S.card = k}

/-- The Roman domination number `γ_R(G)`. -/
noncomputable def gammaR : ℕ := sInf {w | ∃ f, IsRDF G f ∧ weight f = w}

/-- The Italian (Roman-`{2}`) domination number `γ_I(G)`. -/
noncomputable def gammaI : ℕ := sInf {w | ∃ f, IsIDF G f ∧ weight f = w}

/-- The double Roman domination number `γ_dR(G)`. -/
noncomputable def gammaDR : ℕ := sInf {w | ∃ f, IsDRDF G f ∧ weight f = w}

/-- The perfect Roman domination number `γ_p(G)`. -/
noncomputable def gammaPR : ℕ := sInf {w | ∃ f, IsPRDF G f ∧ weight f = w}

/-- The unique response Roman domination number `u(G)`. -/
noncomputable def gammaUR : ℕ := sInf {w | ∃ f, IsURRDF G f ∧ weight f = w}

end Defs

section Basic

variable (G : SimpleGraph V) [DecidableRel G.Adj]

omit [DecidableEq V] in
lemma weight_const_one : weight (fun _ : V => 1) = Fintype.card V := by
  simp [weight, Finset.card_univ]

omit [DecidableEq V] in
lemma weight_const_two : weight (fun _ : V => 2) = 2 * Fintype.card V := by
  simp [weight, Finset.card_univ, mul_comm]

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- The constant labelling `1` is a unique response Roman dominating function. -/
lemma isURRDF_one : IsURRDF G (fun _ : V => 1) := by
  refine ⟨fun _ => by norm_num, fun v hv => by simp at hv, fun v _ u _ => by norm_num⟩

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
lemma isPRDF_of_isURRDF {f : V → ℕ} (h : IsURRDF G f) : IsPRDF G f := ⟨h.1, h.2.1⟩

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
lemma isRDF_of_isPRDF {f : V → ℕ} (h : IsPRDF G f) : IsRDF G f :=
  ⟨h.1, fun v hv => (h.2 v hv).imp fun _ hu => hu.1⟩

omit [DecidableEq V] in
lemma isIDF_of_isRDF {f : V → ℕ} (h : IsRDF G f) : IsIDF G f := by
  refine ⟨h.1, fun v hv => ?_⟩
  obtain ⟨u, hadj, hu⟩ := h.2 v hv
  calc (2 : ℕ) = f u := hu.symm
    _ ≤ ∑ w ∈ G.neighborFinset v, f w := by
        refine Finset.single_le_sum (f := f) (fun _ _ => Nat.zero_le _) ?_
        simpa [SimpleGraph.mem_neighborFinset] using hadj

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- The constant labelling `2` is a double Roman dominating function. -/
lemma isDRDF_two : IsDRDF G (fun _ : V => 2) := by
  refine ⟨fun _ => by norm_num, fun v hv => by simp at hv, fun v hv => by simp at hv⟩

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma isDominating_univ : IsDominating G (Finset.univ : Finset V) :=
  fun v => Or.inl (Finset.mem_univ v)

/-! ### Membership and minimality plumbing -/

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
lemma gammaDom_le {S : Finset V} (h : IsDominating G S) : gammaDom G ≤ S.card :=
  Nat.sInf_le ⟨S, h, rfl⟩

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma gammaR_le {f : V → ℕ} (h : IsRDF G f) : gammaR G ≤ weight f :=
  Nat.sInf_le ⟨f, h, rfl⟩

omit [DecidableEq V] in
lemma gammaI_le {f : V → ℕ} (h : IsIDF G f) : gammaI G ≤ weight f :=
  Nat.sInf_le ⟨f, h, rfl⟩

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma gammaDR_le {f : V → ℕ} (h : IsDRDF G f) : gammaDR G ≤ weight f :=
  Nat.sInf_le ⟨f, h, rfl⟩

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma gammaPR_le {f : V → ℕ} (h : IsPRDF G f) : gammaPR G ≤ weight f :=
  Nat.sInf_le ⟨f, h, rfl⟩

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma gammaUR_le {f : V → ℕ} (h : IsURRDF G f) : gammaUR G ≤ weight f :=
  Nat.sInf_le ⟨f, h, rfl⟩

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma exists_gammaDom : ∃ S : Finset V, IsDominating G S ∧ S.card = gammaDom G :=
  Nat.sInf_mem (s := {k | ∃ S : Finset V, IsDominating G S ∧ S.card = k})
    ⟨(Finset.univ : Finset V).card, Finset.univ, isDominating_univ G, rfl⟩

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma exists_gammaR : ∃ f : V → ℕ, IsRDF G f ∧ weight f = gammaR G :=
  Nat.sInf_mem (s := {w | ∃ f, IsRDF G f ∧ weight f = w})
    ⟨weight (fun _ : V => 1), fun _ => 1,
      isRDF_of_isPRDF G (isPRDF_of_isURRDF G (isURRDF_one G)), rfl⟩

omit [DecidableEq V] in
lemma exists_gammaI : ∃ f : V → ℕ, IsIDF G f ∧ weight f = gammaI G :=
  Nat.sInf_mem (s := {w | ∃ f, IsIDF G f ∧ weight f = w})
    ⟨weight (fun _ : V => 1), fun _ => 1,
      isIDF_of_isRDF G (isRDF_of_isPRDF G (isPRDF_of_isURRDF G (isURRDF_one G))), rfl⟩

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma exists_gammaDR : ∃ f : V → ℕ, IsDRDF G f ∧ weight f = gammaDR G :=
  Nat.sInf_mem (s := {w | ∃ f, IsDRDF G f ∧ weight f = w})
    ⟨weight (fun _ : V => 2), fun _ => 2, isDRDF_two G, rfl⟩

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma exists_gammaPR : ∃ f : V → ℕ, IsPRDF G f ∧ weight f = gammaPR G :=
  Nat.sInf_mem (s := {w | ∃ f, IsPRDF G f ∧ weight f = w})
    ⟨weight (fun _ : V => 1), fun _ => 1, isPRDF_of_isURRDF G (isURRDF_one G), rfl⟩

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma exists_gammaUR : ∃ f : V → ℕ, IsURRDF G f ∧ weight f = gammaUR G :=
  Nat.sInf_mem (s := {w | ∃ f, IsURRDF G f ∧ weight f = w})
    ⟨weight (fun _ : V => 1), fun _ => 1, isURRDF_one G, rfl⟩

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- Lower bounds on `γ_R` are proved by bounding the weight of every Roman
dominating function. -/
lemma le_gammaR {k : ℕ} (h : ∀ f : V → ℕ, IsRDF G f → k ≤ weight f) : k ≤ gammaR G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaR G
  exact hw ▸ h f hf

omit [DecidableEq V] in
/-- Lower bounds on `γ_I` are proved by bounding the weight of every Italian
dominating function. -/
lemma le_gammaI {k : ℕ} (h : ∀ f : V → ℕ, IsIDF G f → k ≤ weight f) : k ≤ gammaI G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaI G
  exact hw ▸ h f hf

end Basic

/-! ### Elementary weight computations -/

section WeightLemmas

variable (f : V → ℕ) (S : Finset V)

omit [DecidableEq V] in
/-- The support of a labelling is no larger than its weight. -/
lemma card_support_le_weight :
    (Finset.univ.filter fun v => 1 ≤ f v).card ≤ weight f := by
  simp only [weight]
  have h : (Finset.univ.filter fun v => 1 ≤ f v).card =
      ∑ v, if 1 ≤ f v then 1 else 0 := by
    rw [card_filter]
  rw [h]
  exact Finset.sum_le_sum fun v _ => by split_ifs <;> linarith

omit [DecidableEq V] in
/-- Doubling on the support at most doubles the weight. -/
lemma weight_double_support_le :
    weight (fun v => if 1 ≤ f v then 2 else 0) ≤ 2 * weight f := by
  simp [weight]
  rw [two_mul, ← Finset.sum_add_distrib]
  exact Finset.sum_le_sum fun v _ => by split_ifs <;> linarith

omit [DecidableEq V] in
/-- Truncating at `2` does not increase the weight. -/
lemma weight_min_two_le : weight (fun v => min (f v) 2) ≤ weight f := by
  apply Finset.sum_le_sum
  intro v _
  exact min_le_left _ _

omit [DecidableEq V] in
/-- Adding one on the support at most doubles the weight, provided all values
are at most `2`. -/
lemma weight_succ_support_le (h : ∀ v, f v ≤ 2) :
    weight (fun v => if f v = 0 then 0 else f v + 1) ≤ 2 * weight f := by
  unfold weight
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro v _
  have hv := h v
  interval_cases f v <;> simp

omit [DecidableEq V] in
/-- Twice the number of vertices labelled at least `2` is at most the weight. -/
lemma two_mul_card_two_le_weight :
    2 * (Finset.univ.filter fun v => 2 ≤ f v).card ≤ weight f := by
  simp only [weight]
  have h1 : 2 * (Finset.univ.filter fun v : V => 2 ≤ f v).card =
      ∑ _v ∈ Finset.univ.filter (fun v : V => 2 ≤ f v), 2 := by
    rw [Finset.sum_const, Finset.card_filter, smul_eq_mul, mul_comm]
  have h2 : (∑ _v ∈ Finset.univ.filter (fun v : V => 2 ≤ f v), 2) ≤
      ∑ v ∈ Finset.univ.filter (fun v : V => 2 ≤ f v), f v :=
    Finset.sum_le_sum fun v hv => (Finset.mem_filter.mp hv).2
  exact le_trans (h1 ▸ h2) (Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) fun _ _ _ => Nat.zero_le _)

/-- The weight of `c` times the indicator of `S`. -/
lemma weight_indicator (c : ℕ) : weight (fun v => if v ∈ S then c else 0) = c * S.card := by
  simp [weight, Finset.sum_ite_mem, mul_comm]

end WeightLemmas

/-! ### Transfer constructions between the variants -/

section Constructions

variable (G : SimpleGraph V) [DecidableRel G.Adj]

omit [DecidableEq V] in
/-- The support of an Italian dominating function is a dominating set. -/
lemma isDominating_support_of_isIDF {f : V → ℕ} (h : IsIDF G f) :
    IsDominating G (Finset.univ.filter fun v => 1 ≤ f v) := by
  intro v
  by_cases hv : f v = 0
  · right
    have hsum := h.2 v hv
    by_contra hne
    push_neg at hne
    have : ∑ u ∈ G.neighborFinset v, f u = 0 := by
      apply Finset.sum_eq_zero
      intro u hu
      rw [SimpleGraph.mem_neighborFinset] at hu
      by_contra hfpos
      push_neg at hfpos
      have hfpos' : 1 ≤ f u := Nat.one_le_iff_ne_zero.mpr hfpos
      exact hne u (by simpa using hfpos') hu
    omega
  · left
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact Nat.pos_of_ne_zero hv

omit [DecidableEq V] in
/-- Doubling the support of an Italian dominating function gives a Roman
dominating function. -/
lemma isRDF_double_support {f : V → ℕ} (h : IsIDF G f) :
    IsRDF G (fun v => if 1 ≤ f v then 2 else 0) := by
  refine ⟨fun v => ?_, fun v hv => ?_⟩
  · simp only; split_ifs <;> norm_num
  · by_cases hv0 : f v = 0
    · have hsum := h.2 v hv0
      by_contra hne
      push_neg at hne
      have : ∑ u ∈ G.neighborFinset v, f u = 0 := by
        apply Finset.sum_eq_zero
        intro u hu
        simp_all [SimpleGraph.mem_neighborFinset]
      omega
    · simp_all

omit [Fintype V] [DecidableRel G.Adj] in
/-- Assigning `2` to a dominating set gives a Roman dominating function. -/
lemma isRDF_two_indicator {S : Finset V} (h : IsDominating G S) :
    IsRDF G (fun v => if v ∈ S then 2 else 0) := by
  refine ⟨fun v => by simp only; split <;> norm_num, fun v hv => ?_⟩
  have hvt : v ∉ S := by rintro hvS; simp [hvS] at hv
  obtain ⟨u, hu⟩ := (h v).resolve_left hvt
  exact ⟨u, hu.2, if_pos hu.1⟩

omit [Fintype V] [DecidableRel G.Adj] in
/-- Assigning `3` to a dominating set gives a double Roman dominating function. -/
lemma isDRDF_three_indicator {S : Finset V} (h : IsDominating G S) :
    IsDRDF G (fun v => if v ∈ S then 3 else 0) := by
  refine ⟨fun v => by by_cases hv : v ∈ S <;> simp [hv], fun v hv => ?_, fun v hv => ?_⟩
  · -- v has value 0, so v ∉ S; by dominating property, ∃ u ∈ S adjacent to v
    simp at hv
    obtain ⟨u, huS, hadj⟩ := (h v).resolve_left hv
    exact Or.inl ⟨u, hadj, by simp [huS]⟩
  · -- v has value 1, but values are only 0 or 3, contradiction
    by_cases hvS : v ∈ S <;> simp [hvS] at hv

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Truncating a double Roman dominating function at `2` gives a Roman
dominating function. -/
lemma isRDF_min_two {f : V → ℕ} (h : IsDRDF G f) : IsRDF G (fun v => min (f v) 2) := by
  refine ⟨fun v => min_le_right _ _, fun v hv => ?_⟩
  have hf_zero : f v = 0 := by simp_all [min_eq_iff]
  have ⟨h0, h1, h2⟩ := h
  have := h1 v hf_zero
  rcases this with ⟨u, hadj, hu⟩ | ⟨u, w, hne, hadj_u, hadj_w, hu, hw⟩
  · exact ⟨u, hadj, by simp [hu]⟩
  · exact ⟨u, hadj_u, by simp [min_eq_right hu]⟩

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Adding one on the support of a Roman dominating function gives a double
Roman dominating function. -/
lemma isDRDF_succ_support {f : V → ℕ} (h : IsRDF G f) :
    IsDRDF G (fun v => if f v = 0 then 0 else f v + 1) := by
  refine ⟨fun v => ?_, fun v hv => ?_, fun v hv => ?_⟩
  · -- g v ≤ 3
    by_cases hf : f v = 0
    · simp [hf]
    · have := h.1 v
      simp [hf]
      omega
  · -- g v = 0 case
    simp at hv
    have := h.2 v hv
    obtain ⟨u, hadj, hu⟩ := this
    left
    use u, hadj
    simp [hu]
  · -- g v = 1 case
    by_cases hfv : f v = 0 <;> simp [hfv] at hv

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- The vertices labelled at least `2` by a double Roman dominating function
form a dominating set. -/
lemma isDominating_two_of_isDRDF {f : V → ℕ} (h : IsDRDF G f) :
    IsDominating G (Finset.univ.filter fun v => 2 ≤ f v) := by
  intro v
  by_cases hv : 2 ≤ f v
  · left
    simp [hv]
  · right
    have hfv : f v = 0 ∨ f v = 1 := by omega
    cases hfv with
    | inl h0 =>
      have := h.2.1 v h0
      rcases this with ⟨u, hu, hu'⟩ | ⟨u, w, _, huv, hwv, hu'', hw''⟩
      · exact ⟨u, by simp [hu'], hu⟩
      · exact ⟨u, by simp [hu''], huv⟩
    | inr h1 =>
      exact (h.2.2 v h1).imp fun u hu => ⟨by simp [hu.2], hu.1⟩

end Constructions

/-! ### The chain of inequalities -/

section Chain

variable (G : SimpleGraph V) [DecidableRel G.Adj]

omit [DecidableEq V] in
/-- Every Roman dominating function is an Italian dominating function, hence
`γ_I(G) ≤ γ_R(G)`. -/
theorem gammaI_le_gammaR : gammaI G ≤ gammaR G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaR G
  exact hw ▸ gammaI_le G (isIDF_of_isRDF G hf)

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- Every perfect Roman dominating function is a Roman dominating function, hence
`γ_R(G) ≤ γ_p(G)`. -/
theorem gammaR_le_gammaPR : gammaR G ≤ gammaPR G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaPR G
  exact hw ▸ gammaR_le G (isRDF_of_isPRDF G hf)

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- Every unique response Roman dominating function is a perfect one, hence
`γ_p(G) ≤ u(G)`. -/
theorem gammaPR_le_gammaUR : gammaPR G ≤ gammaUR G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaUR G
  exact hw ▸ gammaPR_le G (isPRDF_of_isURRDF G hf)

omit [DecidableEq V] in
/-- `γ(G) ≤ γ_I(G)`. -/
theorem gammaDom_le_gammaI : gammaDom G ≤ gammaI G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaI G
  exact hw ▸ le_trans (gammaDom_le G (isDominating_support_of_isIDF G hf))
    (card_support_le_weight f)

omit [DecidableEq V] in
/-- `γ_R(G) ≤ 2 γ_I(G)`. -/
theorem gammaR_le_two_gammaI : gammaR G ≤ 2 * gammaI G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaI G
  exact hw ▸ le_trans (gammaR_le G (isRDF_double_support G hf)) (weight_double_support_le f)

omit [DecidableRel G.Adj] in
/-- `γ_R(G) ≤ 2 γ(G)`. -/
theorem gammaR_le_two_gammaDom : gammaR G ≤ 2 * gammaDom G := by
  obtain ⟨S, hS, hc⟩ := exists_gammaDom G
  have h := gammaR_le G (isRDF_two_indicator G hS)
  rw [weight_indicator S 2] at h
  omega

omit [DecidableEq V] in
/-- `γ(G) ≤ γ_R(G)`. -/
theorem gammaDom_le_gammaR : gammaDom G ≤ gammaR G :=
  le_trans (gammaDom_le_gammaI G) (gammaI_le_gammaR G)

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- `γ_R(G) ≤ γ_dR(G)`. -/
theorem gammaR_le_gammaDR : gammaR G ≤ gammaDR G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaDR G
  exact hw ▸ le_trans (gammaR_le G (isRDF_min_two G hf)) (weight_min_two_le f)

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- `γ_dR(G) ≤ 2 γ_R(G)`. -/
theorem gammaDR_le_two_gammaR : gammaDR G ≤ 2 * gammaR G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaR G
  exact hw ▸ le_trans (gammaDR_le G (isDRDF_succ_support G hf))
    (weight_succ_support_le f hf.1)

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- `2 γ(G) ≤ γ_dR(G)`. -/
theorem two_gammaDom_le_gammaDR : 2 * gammaDom G ≤ gammaDR G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaDR G
  refine hw ▸ le_trans ?_ (two_mul_card_two_le_weight f)
  exact Nat.mul_le_mul_left 2 (gammaDom_le G (isDominating_two_of_isDRDF G hf))

omit [DecidableRel G.Adj] in
/-- `γ_dR(G) ≤ 3 γ(G)`. -/
theorem gammaDR_le_three_gammaDom : gammaDR G ≤ 3 * gammaDom G := by
  obtain ⟨S, hS, hc⟩ := exists_gammaDom G
  have h := gammaDR_le G (isDRDF_three_indicator G hS)
  rw [weight_indicator S 3] at h
  omega

/-- The full chain, assembled:
`γ ≤ γ_I ≤ γ_R ≤ γ_p ≤ u` and `γ_R ≤ γ_dR ≤ 2 γ_R`, with
`2 γ ≤ γ_dR ≤ 3 γ` and `γ_R ≤ min (2 γ_I) (2 γ)`. -/
theorem roman_chain :
    gammaDom G ≤ gammaI G ∧ gammaI G ≤ gammaR G ∧ gammaR G ≤ gammaPR G ∧
      gammaPR G ≤ gammaUR G ∧ gammaR G ≤ 2 * gammaI G ∧ gammaR G ≤ 2 * gammaDom G ∧
      gammaR G ≤ gammaDR G ∧ gammaDR G ≤ 2 * gammaR G ∧
      2 * gammaDom G ≤ gammaDR G ∧ gammaDR G ≤ 3 * gammaDom G :=
  ⟨gammaDom_le_gammaI G, gammaI_le_gammaR G, gammaR_le_gammaPR G, gammaPR_le_gammaUR G,
    gammaR_le_two_gammaI G, gammaR_le_two_gammaDom G, gammaR_le_gammaDR G,
    gammaDR_le_two_gammaR G, two_gammaDom_le_gammaDR G, gammaDR_le_three_gammaDom G⟩

end Chain

section Bounds

variable (G : SimpleGraph V) [DecidableRel G.Adj]

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- The general upper bound `γ_R(G) ≤ n`. -/
theorem gammaR_le_card : gammaR G ≤ Fintype.card V := by
  have := gammaR_le G (isRDF_of_isPRDF G (isPRDF_of_isURRDF G (isURRDF_one G)))
  simpa [weight_const_one] using this

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- The unique response Roman domination number is also at most `n`. -/
theorem gammaUR_le_card : gammaUR G ≤ Fintype.card V := by
  have := gammaUR_le G (isURRDF_one G)
  simpa [weight_const_one] using this

omit [DecidableEq V] in
/-- In the edgeless graph no vertex can be labelled `0`, so every Roman dominating
function has weight at least `n`. -/
lemma card_le_weight_of_isRDF_bot {f : V → ℕ} (h : IsRDF (⊥ : SimpleGraph V) f) :
    Fintype.card V ≤ weight f := by
  have h1 : ∀ v, 1 ≤ f v := fun v => by
    by_contra h_neg
    push_neg at h_neg
    have hf0 : f v = 0 := Nat.lt_one_iff.mp h_neg
    have := h.2 v hf0
    obtain ⟨u, hadj, _⟩ := this
    simp at hadj
  calc Fintype.card V = ∑ _ : V, (1 : ℕ) := by simp
    _ ≤ ∑ v : V, f v := Finset.sum_le_sum fun v _ => h1 v
    _ = weight f := rfl

omit [DecidableEq V] in
/-- `γ_R(⊥) = n` for the edgeless graph on `n` vertices. -/
theorem gammaR_bot : gammaR (⊥ : SimpleGraph V) = Fintype.card V :=
  le_antisymm (gammaR_le_card _) (le_gammaR _ fun _ hf => card_le_weight_of_isRDF_bot hf)

end Bounds

end RomanDomination