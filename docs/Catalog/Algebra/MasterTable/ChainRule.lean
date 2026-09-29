/-
# MASTER-TABLE (paper 119) — the chain rule behind the dial columns

A structural explanation of the "exactly one bit" entries of the table.

* `uEnt_chain_of_factor` — **chain rule** for the counting entropy: if the dial `k`
  is a function of the read-out `g` (`k = φ ∘ g`), then
  `H(g) = H(k) + H(g | k)`;
* `mutInfo_eq_uEnt_of_factor` — hence `I(g ; k) = H(k)`: a dial that is determined
  by the type carries exactly its own entropy;
* `mutInfo_rotSign_odd'` — second, conceptual proof that for odd `n` the rotation
  character carries exactly one bit about the dihedral type: for odd `n` the
  character is a function of the number of roots (`rotSign = [T = 1]`), and it is
  a fair coin;
* `condEnt_congr_fibrewise`, `mutInfo_comm` — **symmetry of the mutual
  information** `I(g ; k) = I(k ; g)` for the counting framework, and the
  *dial capacity* bound `I(g ; k) ≤ H(k)` (`mutInfo_le_uEnt_dial`);
* `uEnt_pos_of_ne`, `condEnt_pos_of_ne` — strict positivity criteria;
* `mutInfo_rotSign_even_lt_one`, `mutInfo_rotSign_eq_one_iff` — **parity law**:
  for `n ≥ 3` the rotation character carries exactly one bit about the dihedral
  type iff `n` is odd (strictly less for even `n`).
-/
import Algebra.MasterTable.Dihedral

namespace MasterTable

open CyclicTypeChannel D6TypeChannel DihedralGroup Finset

section Chain

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]

/-- **Chain rule for a determined dial**: `H(g) = H(φ ∘ g) + H(g | φ ∘ g)`. -/
theorem uEnt_chain_of_factor (s : Finset α) (g : α → β) (φ : β → γ) :
    uEnt s g = uEnt s (φ ∘ g) + condEnt s g (φ ∘ g) := by
  set k : α → γ := φ ∘ g with hk
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt, condEnt]
  have hN : (0 : ℝ) < s.card := by exact_mod_cast hs.card_pos
  -- the `g`-fibres inside a `k`-fibre are the global `g`-fibres
  have hfib : ∀ c, ∀ a ∈ ({x ∈ s | k x = c} : Finset α),
      #{x ∈ {x ∈ s | k x = c} | g x = g a} = #{x ∈ s | g x = g a} := by
    intro c a ha
    congr 1
    ext x
    simp only [mem_filter] at ha ⊢
    constructor
    · rintro ⟨⟨hx, -⟩, hgx⟩
      exact ⟨hx, hgx⟩
    · rintro ⟨hx, hgx⟩
      refine ⟨⟨hx, ?_⟩, hgx⟩
      rw [← ha.2, hk, Function.comp_apply, Function.comp_apply, hgx]
  have hterm : ∀ c ∈ s.image k,
      ((#{x ∈ s | k x = c} : ℝ) / s.card) * uEnt {x ∈ s | k x = c} g
        = ((#{x ∈ s | k x = c} : ℝ) / s.card) * Real.logb 2 (#{x ∈ s | k x = c} : ℝ)
          - (∑ a ∈ {x ∈ s | k x = c}, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)) / s.card := by
    intro c hc
    obtain ⟨a₀, ha₀, rfl⟩ := mem_image.1 hc
    have hc0 : (0 : ℝ) < (#{x ∈ s | k x = k a₀} : ℝ) := by
      exact_mod_cast card_pos.2 ⟨a₀, by simp [ha₀]⟩
    rw [uEnt, Finset.sum_congr rfl (fun a ha => by rw [hfib (k a₀) a ha])]
    field_simp
  have hsumfib : ∑ c ∈ s.image k,
      (∑ a ∈ {x ∈ s | k x = c}, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ))
        = ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ) :=
    sum_fiberwise_of_maps_to (fun a ha => mem_image_of_mem k ha) _
  have hk_log : ∑ c ∈ s.image k,
      ((#{x ∈ s | k x = c} : ℝ) / s.card) * Real.logb 2 (#{x ∈ s | k x = c} : ℝ)
        = (∑ a ∈ s, Real.logb 2 (#{x ∈ s | k x = k a} : ℝ)) / s.card := by
    rw [sum_logb_fiber, sum_div]
    exact sum_congr rfl fun c _ => by ring
  rw [condEnt, sum_congr rfl hterm, sum_sub_distrib, hk_log, ← sum_div, hsumfib]
  simp only [uEnt]
  ring

/-- **A determined dial carries exactly its own entropy**: `I(g ; φ ∘ g) = H(φ ∘ g)`. -/
theorem mutInfo_eq_uEnt_of_factor (s : Finset α) (g : α → β) (φ : β → γ) :
    mutInfo s g (φ ∘ g) = uEnt s (φ ∘ g) := by
  rw [mutInfo, uEnt_chain_of_factor s g φ]
  ring

/-- Conditional entropies agree when the two read-outs induce the same partition
on every fibre of the conditioning variable. -/
theorem condEnt_congr_fibrewise {β' : Type*} [DecidableEq β'] (s : Finset α) (g : α → β)
    (g' : α → β') (k : α → γ)
    (h : ∀ x ∈ s, ∀ y ∈ s, k x = k y → (g x = g y ↔ g' x = g' y)) :
    condEnt s g k = condEnt s g' k := by
  refine sum_congr rfl fun c _ => ?_
  congr 1
  rw [uEnt, uEnt]
  congr 2
  refine sum_congr rfl fun a ha => ?_
  congr 3
  ext x
  simp only [mem_filter] at ha ⊢
  constructor
  · rintro ⟨hx, hgx⟩
    exact ⟨hx, (h x hx.1 a ha.1 (hx.2.trans ha.2.symm)).1 hgx⟩
  · rintro ⟨hx, hgx⟩
    exact ⟨hx, (h x hx.1 a ha.1 (hx.2.trans ha.2.symm)).2 hgx⟩

/-- **Symmetry of the mutual information**: `I(g ; k) = I(k ; g)`. -/
theorem mutInfo_comm (s : Finset α) (g : α → β) (k : α → γ) :
    mutInfo s g k = mutInfo s k g := by
  set P : α → β × γ := fun a => (g a, k a)
  have h1 : uEnt s P = uEnt s g + condEnt s P g := uEnt_chain_of_factor s P Prod.fst
  have h2 : uEnt s P = uEnt s k + condEnt s P k := uEnt_chain_of_factor s P Prod.snd
  have e1 : condEnt s P g = condEnt s k g :=
    condEnt_congr_fibrewise s P k g fun x _ y _ hxy => by
      simp only [P, Prod.mk.injEq, hxy, true_and]
  have e2 : condEnt s P k = condEnt s g k :=
    condEnt_congr_fibrewise s P g k fun x _ y _ hxy => by
      simp only [P, Prod.mk.injEq, hxy, and_true]
  rw [mutInfo, mutInfo]
  linarith

/-- **Dial capacity**: a dial never carries more than its own entropy,
`I(g ; k) ≤ H(k)`. -/
theorem mutInfo_le_uEnt_dial (s : Finset α) (g : α → β) (k : α → γ) :
    mutInfo s g k ≤ uEnt s k := by
  rw [mutInfo_comm]
  exact mutInfo_le_uEnt s k g

/-- A read-out that is not constant on `s` has strictly positive entropy. -/
theorem uEnt_pos_of_ne {s : Finset α} {g : α → β} {x y : α} (hx : x ∈ s) (hy : y ∈ s)
    (hxy : g x ≠ g y) : 0 < uEnt s g := by
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 ⟨x, hx⟩
  have hlt : ∀ a ∈ s, (#{z ∈ s | g z = g a} : ℝ) < s.card := by
    intro a ha
    have hsub : {z ∈ s | g z = g a} ⊂ s := by
      refine ⟨filter_subset _ _, fun hss => ?_⟩
      have hxa := (mem_filter.1 (hss hx)).2
      have hya := (mem_filter.1 (hss hy)).2
      exact hxy (hxa.trans hya.symm)
    exact_mod_cast card_lt_card hsub
  have hsum : ∑ a ∈ s, Real.logb 2 (#{z ∈ s | g z = g a} : ℝ)
      < ∑ _a ∈ s, Real.logb 2 (s.card : ℝ) := by
    refine sum_lt_sum_of_nonempty ⟨x, hx⟩ fun a ha => ?_
    have hpos : (0 : ℝ) < (#{z ∈ s | g z = g a} : ℝ) := by
      exact_mod_cast card_pos.2 ⟨a, by simp [ha]⟩
    exact Real.logb_lt_logb (by norm_num) hpos (hlt a ha)
  rw [sum_const, nsmul_eq_mul] at hsum
  rw [uEnt, sub_pos, div_lt_iff₀ hN]
  linarith

/-- The conditional entropy is strictly positive as soon as some fibre of the
conditioning variable contains two points with different read-outs. -/
theorem condEnt_pos_of_ne [DecidableEq α] {s : Finset α} {g : α → β} {k : α → γ} {x y : α}
    (hx : x ∈ s) (hy : y ∈ s) (hk : k x = k y) (hxy : g x ≠ g y) : 0 < condEnt s g k := by
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 ⟨x, hx⟩
  rw [condEnt_eq_avg]
  apply div_pos _ hN
  refine sum_pos' (fun a _ => uEnt_nonneg _ _) ⟨x, hx, ?_⟩
  exact uEnt_pos_of_ne (x := x) (y := y) (by simp [hx]) (by simp [hy, hk]) hxy

end Chain

/-! ## Application: the odd dihedral dial, conceptually -/

section OddDial

variable {n : ℕ} [NeZero n]

/-- For odd `n` the rotation character is read off from the number of roots:
`rotSign g = 1 ↔ fixCount g = 1`. -/
theorem rotSign_eq_of_fixCount (hn : Odd n) (h3 : 3 ≤ n) (g : DihedralGroup n) :
    rotSign g = (fun t : ℕ => if t = 1 then (1 : ZMod 2) else 0) (fixCount g) := by
  cases g with
  | r i =>
    have : fixCount (r i) ≠ 1 := fixCount_r_ne one_ne_zero (by omega) i
    simp [rotSign, this]
  | sr i => simp [rotSign, fixCount_sr_of_odd hn]

/-- The rotation character is a fair coin on `D_n`. -/
theorem uEnt_rotSign : uEnt (univ : Finset (DihedralGroup n)) rotSign = 1 := by
  have hn0 : (0 : ℝ) < n := by exact_mod_cast Nat.pos_of_ne_zero (NeZero.ne n)
  rw [uEnt_uniform_fibres (c := n) univ_nonempty, card_univ, DihedralGroup.card]
  · push_cast
    rw [logb_two_mul hn0]
    ring
  · intro a _
    cases a with
    | r i => exact card_rotSign_zero
    | sr i => exact card_rotSign_one

/-- **Second proof of the one-bit law**, via the chain rule. -/
theorem mutInfo_rotSign_odd' (hn : Odd n) (h3 : 3 ≤ n) :
    mutInfo (univ : Finset (DihedralGroup n)) fixCount rotSign = 1 := by
  have hfun : (rotSign : DihedralGroup n → ZMod 2)
      = (fun t : ℕ => if t = 1 then (1 : ZMod 2) else 0) ∘ fixCount :=
    funext fun g => rotSign_eq_of_fixCount hn h3 g
  rw [hfun, mutInfo_eq_uEnt_of_factor, ← hfun, uEnt_rotSign]

/-- **Even degrees: the abelian dial carries strictly less than one bit.** A root-free
Frobenius can be a rotation (`r 1`) or a reflection (`sr 1`), so the type does not
determine the character. -/
theorem mutInfo_rotSign_even_lt_one (hn : Even n) (h4 : 4 ≤ n) :
    mutInfo (univ : Finset (DihedralGroup n)) fixCount rotSign < 1 := by
  have hr1 : fixCount (r (1 : ZMod n)) = 0 := by
    rw [fixCount_r_eq_zero_iff]
    intro h
    have := congrArg ZMod.val h
    rw [ZMod.val_one'' (by omega), ZMod.val_zero] at this
    exact one_ne_zero this
  have hs1 : fixCount (sr (1 : ZMod n)) = 0 := by
    rw [fixCount_sr_eq_zero_iff hn, ZMod.val_one'' (by omega)]
    decide
  have hpos : 0 < condEnt (univ : Finset (DihedralGroup n)) rotSign fixCount :=
    condEnt_pos_of_ne (x := r 1) (y := sr 1) (mem_univ _) (mem_univ _) (hr1.trans hs1.symm)
      (by simp [rotSign])
  rw [mutInfo_comm, mutInfo, uEnt_rotSign]
  linarith

/-- **Parity law of the abelian dial**: for `n ≥ 3`, the rotation character
carries exactly one bit about the dihedral splitting type iff `n` is odd. -/
theorem mutInfo_rotSign_eq_one_iff (h3 : 3 ≤ n) :
    mutInfo (univ : Finset (DihedralGroup n)) fixCount rotSign = 1 ↔ Odd n := by
  refine ⟨fun h => ?_, fun h => mutInfo_rotSign_odd' h h3⟩
  by_contra hodd
  have he : Even n := Nat.not_odd_iff_even.1 hodd
  have h4 : 4 ≤ n := by
    obtain ⟨m, hm⟩ := he
    omega
  exact (mutInfo_rotSign_even_lt_one he h4).ne h

end OddDial

end MasterTable