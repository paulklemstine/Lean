/-
# The Davenport constant of `(ZMod p)^2`: `D(C_p ⊕ C_p) ≤ 2p - 1`

This file proves, by an application of the **Chevalley–Warning theorem**, that
any sequence of `2p - 1` vectors in `(ZMod p)^2` admits a nonempty subsequence
summing to zero (`exists_nonempty_zeroSum_sublist`).

This is the additive-combinatorial engine behind the "line bound" of
`Algebra.Heisenberg125.LineBound`: the preimage in `H_{p^3}` of a line through
the origin of `(ZMod p)^2` is an abelian subgroup isomorphic to `C_p ⊕ C_p`, and
product-one-freeness there is exactly zero-sum-freeness in `(ZMod p)^2`.

The Finset version `exists_nonempty_zeroSum_pair` is stated for two coordinate
functions `u, w : Fin n → ZMod p` so that it can be applied directly to
arbitrary pairs of `ZMod p`-valued statistics of a sequence.
-/
import Mathlib

namespace Heisenberg125

open Finset MvPolynomial

variable {p : ℕ} [Fact p.Prime]

/-- The Chevalley–Warning test polynomial `Σ_i u i • X i ^ (p-1)`. -/
private noncomputable def cwPoly {n : ℕ} (u : Fin n → ZMod p) : MvPolynomial (Fin n) (ZMod p) :=
  ∑ i, u i • X i ^ (p - 1)

private lemma totalDegree_cwPoly_le {n : ℕ} (u : Fin n → ZMod p) :
    (cwPoly u).totalDegree ≤ p - 1 := by
  refine totalDegree_finsetSum_le ?_
  rintro i -
  exact (totalDegree_smul_le _ _).trans (totalDegree_X_pow _ _).le

private lemma eval_cwPoly {n : ℕ} (u : Fin n → ZMod p) (x : Fin n → ZMod p) :
    eval x (cwPoly u) = ∑ i ∈ Finset.univ.filter (fun i => x i ≠ 0), u i := by
  classical
  rw [cwPoly, map_sum, Finset.sum_filter]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [MvPolynomial.smul_eval, map_pow, eval_X, ZMod.pow_card_sub_one]
  by_cases h : x i = 0 <;> simp [h]

set_option maxHeartbeats 1000000 in
/-- **Davenport constant of `(ZMod p)^k`, Chevalley–Warning form.**  Given
`n > k(p-1)` vectors, described by their `k` coordinate functions
`u 0, …, u (k-1) : Fin n → ZMod p`, some nonempty set of indices has all `k`
coordinate sums equal to zero.  This is Olson's theorem for elementary abelian
`p`-groups: `D((ZMod p)^k) ≤ k(p-1) + 1`. -/
theorem exists_nonempty_zeroSum_family {ι : Type*} [Fintype ι] [DecidableEq ι] {n : ℕ}
    (u : ι → Fin n → ZMod p) (hn : Fintype.card ι * (p - 1) < n) :
    ∃ t : Finset (Fin n), t.Nonempty ∧ ∀ j, ∑ i ∈ t, u j i = 0 := by
  set F : ι → MvPolynomial (Fin n) (ZMod p) := fun j => cwPoly (u j) with hF
  letI : ∀ x : Fin n → ZMod p,
      Decidable (∀ i ∈ (Finset.univ : Finset ι), eval x (F i) = 0) :=
    fun _ => decidableDforallFinset
  have hzero : ∀ j ∈ (Finset.univ : Finset ι), eval (0 : Fin n → ZMod p) (F j) = 0 := by
    intro j _
    rw [hF, eval_cwPoly]
    exact Finset.sum_eq_zero (by intro i hi; simp at hi)
  have hdeg : ∑ j : ι, (F j).totalDegree < Fintype.card (Fin n) := by
    calc ∑ j : ι, (F j).totalDegree ≤ ∑ _j : ι, (p - 1) :=
          Finset.sum_le_sum fun j _ => totalDegree_cwPoly_le (u j)
      _ = Fintype.card ι * (p - 1) := by simp
      _ < Fintype.card (Fin n) := by simpa using hn
  have hpN := char_dvd_card_solutions_of_sum_lt (K := ZMod p) p
    (s := (Finset.univ : Finset ι)) (f := F) hdeg
  obtain ⟨x, hx⟩ := Fintype.exists_ne_of_one_lt_card
    ((Fact.out : p.Prime).one_lt.trans_le
      (Nat.le_of_dvd (Fintype.card_pos_iff.2 ⟨⟨0, hzero⟩⟩) hpN)) ⟨0, hzero⟩
  refine ⟨Finset.univ.filter (fun i => x.1 i ≠ 0), ?_, ?_⟩
  · rw [← Subtype.coe_ne_coe, Function.ne_iff] at hx
    obtain ⟨i, hi⟩ := hx
    exact ⟨i, by simpa using hi⟩
  · intro j
    rw [← eval_cwPoly]
    exact x.2 j (Finset.mem_univ j)

/-- **Davenport constant of `(ZMod p)^k`, sequence form.** -/
theorem exists_nonempty_zeroSum_sublist_family {α : Type*} {k : ℕ} (M : List α)
    (u : Fin k → α → ZMod p) (hM : k * (p - 1) < M.length) :
    ∃ T : List α, T.Sublist M ∧ T ≠ [] ∧ ∀ j, (T.map (u j)).sum = 0 := by
  classical
  obtain ⟨t, htne, ht⟩ :=
    exists_nonempty_zeroSum_family (fun j => fun i : Fin M.length => u j (M.get i))
      (by simpa using hM)
  set idxs : List (Fin M.length) := (List.finRange M.length).filter (fun i => decide (i ∈ t))
    with hidxs
  have hnodup : idxs.Nodup := (List.nodup_finRange _).filter _
  have htoFinset : idxs.toFinset = t := by
    ext i
    simp [hidxs]
  have hsum : ∀ f : α → ZMod p, ((idxs.map M.get).map f).sum = ∑ i ∈ t, f (M.get i) := by
    intro f
    rw [List.map_map, ← htoFinset, List.sum_toFinset _ hnodup]
    rfl
  refine ⟨idxs.map M.get, ?_, ?_, ?_⟩
  · have : (idxs.map M.get).Sublist ((List.finRange M.length).map M.get) :=
      List.Sublist.map _ (by rw [hidxs]; exact List.filter_sublist)
    rwa [List.map_get_finRange] at this
  · obtain ⟨i, hi⟩ := htne
    have hmem : i ∈ idxs := by
      rw [hidxs, List.mem_filter]
      exact ⟨List.mem_finRange i, by simpa using hi⟩
    intro hc
    have hmm : M.get i ∈ idxs.map M.get := List.mem_map_of_mem hmem
    rw [hc] at hmm
    simp at hmm
  · intro j
    rw [hsum]
    exact ht j

/-- **Davenport constant of `C_p ⊕ C_p`, Chevalley–Warning form.**  Given
`n ≥ 2p - 1` pairs `(u i, w i)` of elements of `ZMod p`, some nonempty set of
indices has both coordinate sums equal to zero. -/
theorem exists_nonempty_zeroSum_pair {n : ℕ} (u w : Fin n → ZMod p) (hn : 2 * p - 1 ≤ n) :
    ∃ t : Finset (Fin n), t.Nonempty ∧ ∑ i ∈ t, u i = 0 ∧ ∑ i ∈ t, w i = 0 := by
  classical
  have hp2 : 2 ≤ p := (Fact.out : p.Prime).two_le
  set N := Fintype.card {x : Fin n → ZMod p // eval x (cwPoly u) = 0 ∧ eval x (cwPoly w) = 0}
    with hN
  have hzero : eval (0 : Fin n → ZMod p) (cwPoly u) = 0 ∧
      eval (0 : Fin n → ZMod p) (cwPoly w) = 0 := by
    constructor <;>
      · rw [eval_cwPoly]
        apply Finset.sum_eq_zero
        intro i hi
        simp at hi
  have hN₀ : 0 < N := @Fintype.card_pos _ _ ⟨⟨0, hzero⟩⟩
  have hdeg : (cwPoly u).totalDegree + (cwPoly w).totalDegree < Fintype.card (Fin n) := by
    have h1 := totalDegree_cwPoly_le u
    have h2 := totalDegree_cwPoly_le w
    simp only [Fintype.card_fin]
    omega
  have hpN : p ∣ N := char_dvd_card_solutions_of_add_lt p hdeg
  obtain ⟨x, hx⟩ := Fintype.exists_ne_of_one_lt_card
    ((Fact.out : p.Prime).one_lt.trans_le (Nat.le_of_dvd hN₀ hpN)) ⟨0, hzero⟩
  refine ⟨Finset.univ.filter (fun i => x.1 i ≠ 0), ?_, ?_, ?_⟩
  · rw [← Subtype.coe_ne_coe, Function.ne_iff] at hx
    obtain ⟨i, hi⟩ := hx
    exact ⟨i, by simpa using hi⟩
  · rw [← eval_cwPoly]; exact x.2.1
  · rw [← eval_cwPoly]; exact x.2.2

/-- **Davenport constant of `C_p ⊕ C_p`, sequence form.**  Given a list `M`
over any type and two `ZMod p`-valued statistics `u, w`, if `M` has at least
`2p - 1` entries then some nonempty subsequence has both statistics summing to
zero. -/
theorem exists_nonempty_zeroSum_sublist {α : Type*} (M : List α) (u w : α → ZMod p)
    (hM : 2 * p - 1 ≤ M.length) :
    ∃ T : List α, T.Sublist M ∧ T ≠ [] ∧ (T.map u).sum = 0 ∧ (T.map w).sum = 0 := by
  classical
  obtain ⟨t, htne, ht1, ht2⟩ :=
    exists_nonempty_zeroSum_pair (fun i : Fin M.length => u (M.get i))
      (fun i : Fin M.length => w (M.get i)) hM
  set idxs : List (Fin M.length) := (List.finRange M.length).filter (fun i => decide (i ∈ t))
    with hidxs
  have hnodup : idxs.Nodup := (List.nodup_finRange _).filter _
  have htoFinset : idxs.toFinset = t := by
    ext i
    simp [hidxs]
  have hsum : ∀ f : α → ZMod p, ((idxs.map M.get).map f).sum = ∑ i ∈ t, f (M.get i) := by
    intro f
    rw [List.map_map, ← htoFinset, List.sum_toFinset _ hnodup]
    rfl
  refine ⟨idxs.map M.get, ?_, ?_, ?_, ?_⟩
  · have : (idxs.map M.get).Sublist ((List.finRange M.length).map M.get) :=
      List.Sublist.map _ (by rw [hidxs]; exact List.filter_sublist)
    rwa [List.map_get_finRange] at this
  · obtain ⟨i, hi⟩ := htne
    have hmem : i ∈ idxs := by
      rw [hidxs, List.mem_filter]
      exact ⟨List.mem_finRange i, by simpa using hi⟩
    intro hc
    have hmm : M.get i ∈ idxs.map M.get := List.mem_map_of_mem hmem
    rw [hc] at hmm
    simp at hmm
  · rw [hsum]; exact ht1
  · rw [hsum]; exact ht2

end Heisenberg125