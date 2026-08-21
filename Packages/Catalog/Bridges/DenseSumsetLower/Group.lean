/-
# The sharp constant `1 / log (1/δ)` in finite abelian groups

In the interval `[n]` the greedy shift argument loses a factor `4` (the shift window has
`2n` elements and the surviving set is only guaranteed to keep half of its mass).  In a
finite abelian group the shift window is the whole group, and the loss disappears: the
lower bound holds with the **sharp** constant `1 / log (1/δ)`, matching the shape
`(C + o(1)) log |G| / log (1/δ)` of the mission statement with `C = 1`.

* `DenseSumsetLower.exists_sumset_group_density` — the finitary criterion with slack
  parameter `ε`;
* `DenseSumsetLower.exists_threshold_group` — for every `c < 1 / log (1/δ)` there is a
  threshold `N₀` such that every `δ`-dense subset of *any* finite abelian group of order
  `≥ N₀` contains a sumset `A + B` with `|A| = |B| = ⌊c log |G|⌋`;
* `DenseSumsetLower.exists_threshold_zmod` — the cyclic specialisation.

Combined with the sharpness side of `Bridges.DeltaDenseSumsetAvoidance`, this traps the
extremal constant of the problem in the window `[1, 3]`.
-/
import Bridges.DenseSumsetLower.Density

namespace DenseSumsetLower

open Finset Pointwise Filter

universe u

/-- **Density criterion in a finite abelian group.**  If `|S| ≥ δ|G|`, `k ≤ εδ|G|` and
`k (1/((1-ε)δ))^k ≤ δ|G|`, then `S` contains a sumset `A + B` with `|A| = |B| = k`. -/
theorem exists_sumset_group_density {G : Type u} [AddCommGroup G] [Fintype G] [DecidableEq G]
    {S : Finset G} {k : ℕ} {δ ε : ℝ} (hδ0 : 0 < δ) (hε0 : 0 < ε) (hε1 : ε < 1)
    (hdense : δ * (Fintype.card G) ≤ S.card)
    (hk : (k : ℝ) ≤ ε * δ * (Fintype.card G))
    (hcond : (k : ℝ) * (1 / ((1 - ε) * δ)) ^ k ≤ δ * (Fintype.card G)) :
    ∃ A B : Finset G, A.card = k ∧ B.card = k ∧ A + B ⊆ S := by
  have hcardpos : 0 < Fintype.card G := Fintype.card_pos
  set N : ℝ := (Fintype.card G : ℝ) with hN
  have hNpos : (0 : ℝ) < N := by rw [hN]; exact_mod_cast hcardpos
  have hσ : 0 < δ * N := mul_pos hδ0 hNpos
  have hknn : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have hk' : (k : ℝ) ≤ ε * (δ * N) := by rw [← mul_assoc]; exact hk
  have hkD : k ≤ (Finset.univ : Finset G).card := by
    have h1 : (k : ℝ) ≤ δ * N := by nlinarith
    have h2 : (k : ℝ) ≤ (S.card : ℝ) := le_trans h1 hdense
    have h3 : k ≤ S.card := by exact_mod_cast h2
    exact le_trans h3 (Finset.card_le_univ S)
  have hD : ∀ u ∈ S, ∀ s ∈ S, s - u ∈ (Finset.univ : Finset G) :=
    fun u _ s _ => Finset.mem_univ _
  have hDM : ((Finset.univ : Finset G).card : ℝ) ≤ N := by rw [Finset.card_univ, hN]
  have hcond' : (k : ℝ) * (N / ((1 - ε) * (δ * N))) ^ k ≤ δ * N := by
    have hne : (1 - ε) ≠ 0 := by intro h; nlinarith
    have heq : N / ((1 - ε) * (δ * N)) = 1 / ((1 - ε) * δ) := by
      field_simp
    rw [heq]; exact hcond
  exact exists_sumset_of_real_bounds hD hε0 hε1 hσ hdense hDM hkD hk' hcond'

/-- **Sharp asymptotic lower bound in finite abelian groups.**  Fix `0 < δ < 1` and any
`c` with `c log (1/δ) < 1`.  Then there is a threshold `N₀` such that every `δ`-dense
subset `S` of a finite abelian group `G` with `|G| ≥ N₀` contains a sumset `A + B` with
`|A| = |B| = ⌊c log |G|⌋`.

Thus the extremal exponent in a group is at least `(1 - o(1)) log |G| / log (1/δ)`: the
constant `1` cannot be improved by the sharpness constructions, which give `3`. -/
theorem exists_threshold_group {δ c : ℝ} (hδ0 : 0 < δ) (hδ1 : δ < 1) (hc0 : 0 < c)
    (hc : c * Real.log (1 / δ) < 1) :
    ∃ N₀ : ℕ, ∀ {G : Type u} [AddCommGroup G] [Fintype G] [DecidableEq G] (S : Finset G),
      N₀ ≤ Fintype.card G → δ * (Fintype.card G) ≤ S.card →
      ∃ A B : Finset G, A.card = ⌊c * Real.log (Fintype.card G)⌋₊ ∧
        B.card = ⌊c * Real.log (Fintype.card G)⌋₊ ∧ A + B ⊆ S := by
  -- slack parameter: `ε = 1 - exp (-t/(2c))` where `t = 1 - c log (1/δ) > 0`
  set t : ℝ := 1 - c * Real.log (1 / δ) with ht
  have htpos : 0 < t := by simp only [ht]; linarith
  set ε : ℝ := 1 - Real.exp (-(t / (2 * c))) with hε
  have hexp1 : Real.exp (-(t / (2 * c))) < 1 := by
    apply Real.exp_lt_one_iff.mpr
    have : 0 < t / (2 * c) := by positivity
    linarith
  have hexp0 : 0 < Real.exp (-(t / (2 * c))) := Real.exp_pos _
  have hε0 : 0 < ε := by simp only [hε]; linarith
  have hε1 : ε < 1 := by simp only [hε]; linarith
  have h1ε : 1 - ε = Real.exp (-(t / (2 * c))) := by simp [hε]
  -- the base of the exponential bound
  set b : ℝ := 1 / ((1 - ε) * δ) with hb
  have hbase : (0 : ℝ) < (1 - ε) * δ := by rw [h1ε]; positivity
  have hb1 : 1 < b := by
    rw [hb, lt_div_iff₀ hbase, one_mul]
    nlinarith [hexp1, h1ε]
  have hlogb : Real.log b = Real.log (1 / δ) + t / (2 * c) := by
    rw [hb, h1ε, one_div, mul_inv, Real.log_mul (by positivity) (by positivity),
      Real.log_inv, Real.log_inv, Real.log_exp, one_div, Real.log_inv]
    ring
  have hcb : c * Real.log b < 1 := by
    rw [hlogb]
    have : c * (t / (2 * c)) = t / 2 := by field_simp
    rw [mul_add, this, ht]
    linarith
  obtain ⟨N₀, hN₀⟩ := eventually_atTop.mp
    (eventually_floor_log_pow_le hb1 hc0 hcb (α := ε * δ) (by positivity))
  refine ⟨N₀, ?_⟩
  intro G _ _ _ S hcard hdense
  obtain ⟨h1, h2⟩ := hN₀ (Fintype.card G) hcard
  set k : ℕ := ⌊c * Real.log (Fintype.card G)⌋₊ with hk
  have hknn : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have hone : (1 : ℝ) ≤ b ^ k := one_le_pow₀ (le_of_lt hb1)
  have hkle : (k : ℝ) ≤ ε * δ * (Fintype.card G) := by nlinarith
  refine exists_sumset_group_density hδ0 hε0 hε1 hdense hkle ?_
  have : (k : ℝ) * b ^ k ≤ ε * δ * (Fintype.card G) := h2
  nlinarith [mul_pos hδ0 (show (0:ℝ) < (Fintype.card G : ℝ) by
    have : (1:ℝ) ≤ (Fintype.card G : ℝ) := h1
    linarith)]

/-- **Cyclic specialisation.**  For every `c < 1 / log (1/δ)` and all sufficiently large
`N`, every `δ`-dense subset of `ZMod N` contains a sumset `A + B` with
`|A| = |B| = ⌊c log N⌋`. -/
theorem exists_threshold_zmod {δ c : ℝ} (hδ0 : 0 < δ) (hδ1 : δ < 1) (hc0 : 0 < c)
    (hc : c * Real.log (1 / δ) < 1) :
    ∃ N₀ : ℕ, 1 ≤ N₀ ∧ ∀ N : ℕ, N₀ ≤ N → ∀ S : Finset (ZMod N), δ * (N : ℝ) ≤ S.card →
      ∃ A B : Finset (ZMod N), A.card = ⌊c * Real.log N⌋₊ ∧ B.card = ⌊c * Real.log N⌋₊ ∧
        A + B ⊆ S := by
  obtain ⟨N₀, hN₀⟩ := exists_threshold_group.{0} hδ0 hδ1 hc0 hc
  refine ⟨max N₀ 1, le_max_right _ _, ?_⟩
  intro N hN S hdense
  haveI : NeZero N := ⟨by omega⟩
  have hcard : Fintype.card (ZMod N) = N := ZMod.card N
  have h1 : N₀ ≤ Fintype.card (ZMod N) := by rw [hcard]; omega
  have h2 : δ * (Fintype.card (ZMod N) : ℝ) ≤ S.card := by rw [hcard]; exact hdense
  obtain ⟨A, B, hA, hB, hAB⟩ := hN₀ S h1 h2
  rw [hcard] at hA hB
  exact ⟨A, B, hA, hB, hAB⟩

end DenseSumsetLower