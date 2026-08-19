import Algebra.ScanSchemeDecoding.Core

/-!
# The exact optimum of a scan scheme, and the pigeonhole failure analysis

Combining the exact cost accounting of `Algebra.ScanSchemeDecoding.Core` with the
exact pigeonhole optimum of `Algebra.ScanSchemeDecoding.Triangle` we obtain:

* `ScanSchemeDecoding.ScanScheme.triangleOpt_le_decodeCost` — **every** scan scheme on
  `N` keys with `m` bucket labels costs at least `triangleOpt N m`;
* `ScanSchemeDecoding.modScheme_decodeCost` — the residue scheme `x ↦ x % m` costs
  *exactly* `triangleOpt N m`;
* `ScanSchemeDecoding.scan_optimum` — hence `triangleOpt N m` is the least achievable
  total cost (`IsLeast`), an exact optimum rather than a bound;
* `ScanSchemeDecoding.ScanScheme.exists_costly_key` — the failure analysis: some key
  always costs at least the average bucket size, `N ≤ m * decodeCost x`;
* `ScanSchemeDecoding.ScanScheme.two_mul_decodeCost_ge` — the averaged `ε`-form.
-/

namespace ScanSchemeDecoding

open Finset

namespace ScanScheme

variable {α β : Type*} [Fintype α] [LinearOrder α] [Fintype β] [DecidableEq β]
variable (S : ScanScheme α β)

/-- **Universal lower bound.**  No scan scheme on `Fintype.card α` keys distributed over
`Fintype.card β` buckets can decode for less than the pigeonhole optimum. -/
theorem triangleOpt_le_decodeCost (hβ : 0 < Fintype.card β) :
    triangleOpt (Fintype.card α) (Fintype.card β) ≤ ∑ x, S.decodeCost x := by
  classical
  set m := Fintype.card β with hm
  let e : β ≃ Fin m := Fintype.equivFin β
  have hsum : ∑ i : Fin m, (S.fiber (e.symm i)).card = Fintype.card α := by
    rw [Equiv.sum_comp e.symm (fun b => (S.fiber b).card)]
    exact S.sum_fiber_card
  have hbound := sum_triangle_ge hβ (fun i => (S.fiber (e.symm i)).card) (Fintype.card α) hsum
  have htri : ∑ i : Fin m, triangle (S.fiber (e.symm i)).card
      = ∑ b, triangle (S.fiber b).card :=
    Equiv.sum_comp e.symm (fun b => triangle (S.fiber b).card)
  rw [htri] at hbound
  rw [S.decodeCost_eq]
  exact hbound

/-- **Averaged (`ε`-)lower bound.**  The mean decoding cost of any scheme is at least
`(⌊N/m⌋ + 1)/2`: halving the cost requires doubling the number of buckets. -/
theorem two_mul_decodeCost_ge (hβ : 0 < Fintype.card β) :
    Fintype.card α * (Fintype.card α / Fintype.card β + 1) ≤ 2 * ∑ x, S.decodeCost x :=
  le_trans (triangleOpt_two_mul_ge hβ (Fintype.card α))
    (Nat.mul_le_mul_left 2 (S.triangleOpt_le_decodeCost hβ))

omit [Fintype β] in
/-- The final key of a nonempty bucket costs exactly the size of that bucket. -/
theorem exists_key_cost_eq_card {b : β} (hb : (S.fiber b).Nonempty) :
    ∃ x, S.bucket x = b ∧ S.decodeCost x = (S.fiber b).card := by
  classical
  have hlen : (S.scanList b).length = (S.fiber b).card := S.length_scanList b
  have hpos : 0 < (S.scanList b).length := by
    rw [hlen]; exact Finset.card_pos.mpr hb
  have hlt : (S.scanList b).length - 1 < (S.scanList b).length := by omega
  have hmem : (S.scanList b)[(S.scanList b).length - 1] ∈ S.scanList b := List.getElem_mem hlt
  have hbucket : S.bucket (S.scanList b)[(S.scanList b).length - 1] = b := S.mem_scanList.mp hmem
  refine ⟨(S.scanList b)[(S.scanList b).length - 1], hbucket, ?_⟩
  have hidx : (S.scanList b).idxOf (S.scanList b)[(S.scanList b).length - 1]
      = (S.scanList b).length - 1 :=
    List.Nodup.idxOf_getElem (S.scanList_nodup b) _ hlt
  rw [decodeCost, idx, hbucket, hidx]
  omega

/-- **Pigeonhole failure analysis.**  In every scan scheme some key is expensive:
its decoding cost is at least the average bucket size `N / m`. -/
theorem exists_costly_key (hα : 0 < Fintype.card α) [Nonempty β] :
    ∃ x, Fintype.card α ≤ Fintype.card β * S.decodeCost x := by
  classical
  have hβ : 0 < Fintype.card β := Fintype.card_pos
  -- some bucket carries at least the average load
  have hex : ∃ b : β, Fintype.card α ≤ Fintype.card β * (S.fiber b).card := by
    by_contra hcon
    push_neg at hcon
    have hlt : ∀ b : β, Fintype.card β * (S.fiber b).card ≤ Fintype.card α - 1 :=
      fun b => by have := hcon b; omega
    have h1 : ∑ b : β, Fintype.card β * (S.fiber b).card
        ≤ ∑ _b : β, (Fintype.card α - 1) := Finset.sum_le_sum (fun b _ => hlt b)
    rw [← Finset.mul_sum, S.sum_fiber_card] at h1
    simp only [Finset.sum_const, Finset.card_univ, smul_eq_mul] at h1
    have : Fintype.card β * Fintype.card α ≤ Fintype.card β * (Fintype.card α - 1) := h1
    have := Nat.le_of_mul_le_mul_left this hβ
    omega
  obtain ⟨b, hb⟩ := hex
  have hne : (S.fiber b).Nonempty := by
    rw [← Finset.card_pos]
    rcases Nat.eq_zero_or_pos (S.fiber b).card with h | h
    · rw [h] at hb; omega
    · exact h
  obtain ⟨x, _, hx⟩ := S.exists_key_cost_eq_card hne
  exact ⟨x, by rw [hx]; exact hb⟩

end ScanScheme

/-! ### The residue scheme attains the optimum -/

/-- Counting the residues below `N`: exactly `⌈(N - j)/m⌉` naturals below `N` are
congruent to `j` mod `m`, i.e. `N / m` plus one more when `j < N % m`. -/
theorem card_range_filter_mod {m : ℕ} (hm : 0 < m) {j : ℕ} (hj : j < m) (N : ℕ) :
    ((Finset.range N).filter (fun x => x % m = j)).card
      = N / m + (if j < N % m then 1 else 0) := by
  classical
  induction N with
  | zero => simp
  | succ N ih =>
    rw [Finset.range_add_one, Finset.filter_insert]
    have hnotmem : N ∉ (Finset.range N).filter (fun x => x % m = j) := by
      simp
    -- arithmetic of the successor step
    have hdm : m * (N / m) + N % m = N := Nat.div_add_mod N m
    have hmod : N % m < m := Nat.mod_lt _ hm
    by_cases hfull : N % m + 1 = m
    · have hNsucc : N + 1 = m * (N / m + 1) := by
        rw [Nat.mul_add, Nat.mul_one]; omega
      have hd : (N + 1) / m = N / m + 1 := by
        rw [hNsucc, Nat.mul_div_cancel_left _ hm]
      have hr : (N + 1) % m = 0 := by
        rw [hNsucc]; exact Nat.mul_mod_right _ _
      rw [hd, hr]
      by_cases hjm : N % m = j
      · rw [if_pos hjm, Finset.card_insert_of_notMem hnotmem, ih]
        have : ¬ j < N % m := by omega
        simp [this]
      · rw [if_neg hjm, ih]
        have h1 : j < N % m := by omega
        simp [h1]
    · have hsplit : N + 1 = m * (N / m) + (N % m + 1) := by omega
      have hz : (N % m + 1) / m = 0 := Nat.div_eq_of_lt (by omega)
      have hz' : (N % m + 1) % m = N % m + 1 := Nat.mod_eq_of_lt (by omega)
      have hd : (N + 1) / m = N / m := by
        rw [hsplit, Nat.mul_add_div hm, hz, Nat.add_zero]
      have hr : (N + 1) % m = N % m + 1 := by
        rw [hsplit, Nat.mul_add_mod, hz']
      rw [hd, hr]
      by_cases hjm : N % m = j
      · rw [if_pos hjm, Finset.card_insert_of_notMem hnotmem, ih]
        have h1 : ¬ j < N % m := by omega
        have h2 : j < N % m + 1 := by omega
        simp [h1, h2]
      · rw [if_neg hjm, ih]
        by_cases h1 : j < N % m
        · simp [h1, Nat.lt_succ_of_lt h1]
        · have h2 : ¬ j < N % m + 1 := by omega
          simp [h1, h2]

/-- The **residue scan scheme**: store key `x` in bucket `x % m`. -/
def modScheme (N : ℕ) {m : ℕ} (hm : 0 < m) : ScanScheme (Fin N) (Fin m) :=
  ⟨fun x => ⟨(x : ℕ) % m, Nat.mod_lt _ hm⟩⟩

/-- The residue scheme has perfectly balanced buckets. -/
theorem modScheme_fiber_card (N : ℕ) {m : ℕ} (hm : 0 < m) (j : Fin m) :
    ((modScheme N hm).fiber j).card = balancedProfile N m j := by
  classical
  have hfilter : ((modScheme N hm).fiber j)
      = Finset.filter (fun x : Fin N => (x : ℕ) % m = (j : ℕ)) Finset.univ := by
    ext x
    simp [ScanScheme.fiber, modScheme, Fin.ext_iff]
  have hcount := card_range_filter_mod hm j.isLt N
  rw [Finset.card_filter] at hcount
  rw [hfilter, Finset.card_filter,
    Fin.sum_univ_eq_sum_range (fun k => if k % m = (j : ℕ) then 1 else 0) N, hcount]
  rfl

/-- **The residue scheme attains the pigeonhole optimum exactly.** -/
theorem modScheme_decodeCost (N : ℕ) {m : ℕ} (hm : 0 < m) :
    ∑ x, (modScheme N hm).decodeCost x = triangleOpt N m := by
  classical
  rw [ScanScheme.decodeCost_eq]
  have : ∀ j : Fin m, triangle ((modScheme N hm).fiber j).card
      = triangle (balancedProfile N m j) := by
    intro j; rw [modScheme_fiber_card]
  rw [Finset.sum_congr rfl (fun j _ => this j), sum_triangle_balanced hm N]

/-- **Exact optimum.**  `triangleOpt N m` is the least total decoding cost achievable by
a scan scheme storing `N` keys in `m` buckets: it is attained (by the residue scheme)
and no scheme beats it. -/
theorem scan_optimum (N : ℕ) {m : ℕ} (hm : 0 < m) :
    IsLeast {c : ℕ | ∃ S : ScanScheme (Fin N) (Fin m), ∑ x, S.decodeCost x = c}
      (triangleOpt N m) := by
  constructor
  · exact ⟨modScheme N hm, modScheme_decodeCost N hm⟩
  · rintro c ⟨S, rfl⟩
    have hβ : 0 < Fintype.card (Fin m) := by simpa using hm
    have := S.triangleOpt_le_decodeCost hβ
    simpa using this

end ScanSchemeDecoding