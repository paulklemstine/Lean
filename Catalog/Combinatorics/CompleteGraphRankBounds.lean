/-
# Consequences of the exact uniform rank on complete graphs

Building on `rank_const_top` (`r(m • 1) = m(m+3)/2` on `K_n`, `n ≥ m + 1`) this file
records:

* `rank_mono` — the Baker–Norine rank is monotone under the pointwise order on
  divisors (true on *every* graph);
* `rank_sandwich_top` — **a two-sided estimate for an arbitrary divisor on `K_n`**:
  if `μ = min_v D v` and `M = max_v D v` then `μ(μ+3)/2 ≤ r(D) ≤ M(M+3)/2`.  Both
  ends are attained (by uniform divisors), so the estimate is sharp;
* `thetaChar_const_top`, `degD_const_top_half_canonical`,
  `four_mul_rank_gt_genus_top`, `rank_const_top_gt_regularity` — on `K_{2m+3}` the
  uniform divisor `m • 1` is a theta characteristic sitting at the half-canonical
  degree `g - 1`, its rank `m(m+3)/2` is a positive proportion of the genus
  (`4r > g`), and it beats the universal bound `k - 1` for the degree of regularity
  as soon as `m ≥ 3`;
* `rank_ne_concFormula_K3` — a **counterexample**: the closed formula
  `a(a+1)/2 + min(b,a)` (with `d = a(n-1) + b`) conjectured for the maximal rank at
  degree `d` on `K_n` is *false* as stated for `d` above the canonical degree: on
  `K_3` at `d = 6` it predicts `6`, while every divisor of degree `6` has rank `5`.
-/
import Combinatorics.CompleteGraphExactRank

namespace TropicalRR

open Finset

/-! ### Monotonicity of the rank -/

section Mono

variable {V : Type*} [Fintype V] [DecidableEq V] [Nonempty V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

omit [DecidableEq V] [Nonempty V] in
/-- If `D ≤ D'` pointwise then `RankGE` transfers from `D` to `D'`. -/
theorem rankGE_mono {D D' : Divisor V} (hle : ∀ v, D v ≤ D' v) {k : ℕ}
    (h : RankGE G D k) : RankGE G D' k := by
  intro E hE hdeg
  have hw := h E hE hdeg
  have hsplit : D' - E = (D - E) + (D' - D) := by
    funext v; simp only [Pi.sub_apply, Pi.add_apply]; ring
  rw [hsplit]
  exact hw.add_effective G fun v => sub_nonneg.2 (hle v)

/-- **The Baker–Norine rank is monotone** for the pointwise order on divisors. -/
theorem rank_mono {D D' : Divisor V} (hle : ∀ v, D v ≤ D' v) : rank G D ≤ rank G D' := by
  rcases lt_or_ge (rank G D) 0 with h | h
  · have h1 := neg_one_le_rank G D'
    omega
  · set k : ℕ := (rank G D).toNat with hk
    have hkD : ((k : ℕ) : ℤ) ≤ rank G D := by omega
    have := (rank_ge_iff G D' k).2 (rankGE_mono G hle ((rank_ge_iff G D k).1 hkD))
    omega

end Mono

/-! ### A sharp two-sided estimate on `K_n` -/

section Sandwich

variable {n : ℕ} [NeZero n]

/-- **Lower bound.**  On `K_n`, a divisor with at least `μ` chips at every vertex has
rank at least `μ(μ+3)/2`. -/
theorem rank_ge_uniformRank_min {μ : ℕ} (hmn : μ + 1 ≤ n) {D : Divisor (Fin n)}
    (hD : ∀ v, (μ : ℤ) ≤ D v) :
    (uniformRank μ : ℤ) ≤ rank (⊤ : SimpleGraph (Fin n)) D := by
  have h := rank_mono (⊤ : SimpleGraph (Fin n)) (D := constDiv n (μ : ℤ)) (D' := D) hD
  rwa [rank_const_top hmn] at h

/-- **Upper bound.**  On `K_n`, a divisor with at most `M` chips at every vertex has
rank at most `M(M+3)/2`. -/
theorem rank_le_uniformRank_max {M : ℕ} (hMn : M + 1 ≤ n) {D : Divisor (Fin n)}
    (hD : ∀ v, D v ≤ (M : ℤ)) :
    rank (⊤ : SimpleGraph (Fin n)) D ≤ (uniformRank M : ℤ) := by
  have h := rank_mono (⊤ : SimpleGraph (Fin n)) (D := D) (D' := constDiv n (M : ℤ)) hD
  rwa [rank_const_top hMn] at h

/-- **The sandwich.**  For every divisor on `K_n` whose values lie between `μ` and `M`
(with `M + 1 ≤ n`), the Baker–Norine rank lies between `μ(μ+3)/2` and `M(M+3)/2`.
Both bounds are attained, by the uniform divisors `μ • 1` and `M • 1`. -/
theorem rank_sandwich_top {μ M : ℕ} (hμM : μ ≤ M) (hMn : M + 1 ≤ n) {D : Divisor (Fin n)}
    (hlo : ∀ v, (μ : ℤ) ≤ D v) (hhi : ∀ v, D v ≤ (M : ℤ)) :
    (uniformRank μ : ℤ) ≤ rank (⊤ : SimpleGraph (Fin n)) D ∧
      rank (⊤ : SimpleGraph (Fin n)) D ≤ (uniformRank M : ℤ) :=
  ⟨rank_ge_uniformRank_min (by omega) hlo, rank_le_uniformRank_max hMn hhi⟩

end Sandwich

/-! ### The general staircase upper bound -/

section StairBound

variable {n : ℕ} [NeZero n]

/-- The degree of the staircase test divisor attached to `D`. -/
def stairDeg (D : Divisor (Fin n)) : ℤ := ∑ i, max 0 (D i - ((i : ℕ) : ℤ) + 1)

omit [NeZero n] in
lemma stairDeg_nonneg (D : Divisor (Fin n)) : 0 ≤ stairDeg D :=
  Finset.sum_nonneg fun _ _ => le_max_left _ _

omit [NeZero n] in
lemma sub_stairFloor (D : Divisor (Fin n)) (i : Fin n) :
    D i - stairFloor D i = max 0 (D i - ((i : ℕ) : ℤ) + 1) := by
  simp only [stairFloor]
  rcases le_or_gt (D i) (((i : ℕ) : ℤ) - 1) with h | h
  · rw [min_eq_left h, max_eq_left (by omega)]; ring
  · rw [min_eq_right (by omega), max_eq_right (by omega)]; ring

/-- **The staircase upper bound.**  On `K_n`, every divisor whose values are all smaller
than `n` has rank at most `(∑_i max(0, D i - i + 1)) - 1`: the explicit staircase test
divisor `D - stairFloor D` already defeats it.  For the uniform divisor this recovers
`r(m • 1) ≤ m(m+3)/2`. -/
theorem rank_le_stairDeg {D : Divisor (Fin n)} (hlt : ∀ i, D i < (n : ℤ)) :
    rank (⊤ : SimpleGraph (Fin n)) D ≤ stairDeg D - 1 := by
  set E : Divisor (Fin n) := D - stairFloor D with hE
  have hEeff : Effective E := by
    intro i
    rw [hE]
    simp only [Pi.sub_apply, sub_stairFloor D i]
    exact le_max_left _ _
  have hdeg : degD E = stairDeg D := by
    rw [degD, stairDeg]
    exact Finset.sum_congr rfl fun i _ => by rw [hE]; exact sub_stairFloor D i
  set k : ℕ := (stairDeg D).toNat with hk
  have hkc : ((k : ℕ) : ℤ) = stairDeg D := Int.toNat_of_nonneg (stairDeg_nonneg D)
  have hnot : ¬ RankGE (⊤ : SimpleGraph (Fin n)) D k := by
    intro h
    have hw := h E hEeff (by rw [hdeg, hkc])
    have : D - E = stairFloor D := by funext i; rw [hE]; simp
    rw [this] at hw
    exact not_winnable_stairFloor hlt hw
  have hlt2 : ¬ (((k : ℕ) : ℤ) ≤ rank (⊤ : SimpleGraph (Fin n)) D) := fun hcon =>
    hnot ((rank_ge_iff (⊤ : SimpleGraph (Fin n)) D k).1 hcon)
  omega

/-- **An exact rank formula for a family of non-uniform divisors.**  If `D` has all its
values `≥ μ` and its staircase degree is no larger than that of the uniform divisor
`μ • 1`, then the two bounds meet and `r(D) = μ(μ+3)/2`. -/
theorem rank_eq_uniformRank_of_stairDeg_le {μ : ℕ} (hμn : μ + 1 ≤ n) {D : Divisor (Fin n)}
    (hlo : ∀ i, (μ : ℤ) ≤ D i) (hlt : ∀ i, D i < (n : ℤ))
    (hstair : stairDeg D ≤ (uniformRank μ : ℤ) + 1) :
    rank (⊤ : SimpleGraph (Fin n)) D = (uniformRank μ : ℤ) := by
  have h1 := rank_ge_uniformRank_min hμn hlo
  have h2 := rank_le_stairDeg hlt
  omega

/-- **Staircase-dominated divisors.**  Every divisor on `K_n` squeezed between the
constant `μ` and the staircase `i ↦ max(μ, i - 1)` has Baker–Norine rank exactly
`μ(μ+3)/2`.  Taking `D = μ • 1` recovers `rank_const_top`; the family also contains
genuinely non-uniform divisors of unbounded degree, e.g. `(μ, …, μ, μ+1, μ+2, …)`. -/
theorem rank_eq_uniformRank_of_staircase_dominated {μ : ℕ} (hμn : μ + 1 ≤ n)
    {D : Divisor (Fin n)} (hlo : ∀ i, (μ : ℤ) ≤ D i)
    (hhi : ∀ i, D i ≤ max (μ : ℤ) (((i : ℕ) : ℤ) - 1)) :
    rank (⊤ : SimpleGraph (Fin n)) D = (uniformRank μ : ℤ) := by
  have hlt : ∀ i : Fin n, D i < (n : ℤ) := by
    intro i
    have h1 := hhi i
    have h2 : ((i : ℕ) : ℤ) < (n : ℤ) := by exact_mod_cast i.isLt
    have h3 : (μ : ℤ) < (n : ℤ) := by exact_mod_cast (by omega : μ < n)
    rcases max_cases ((μ : ℤ)) (((i : ℕ) : ℤ) - 1) with ⟨h, _⟩ | ⟨h, _⟩ <;> omega
  refine rank_eq_uniformRank_of_stairDeg_le hμn hlo hlt ?_
  have hdeg : degD (stairE n μ) = (uniformRank μ : ℤ) + 1 := by
    have h1 := two_mul_degD_stairE (n := n) (m := μ) hμn
    have h2 := two_mul_uniformRank_succ μ
    omega
  have hterm : ∀ i : Fin n, max 0 (D i - ((i : ℕ) : ℤ) + 1) ≤ stairE n μ i := by
    intro i
    simp only [stairE]
    rcases max_cases ((μ : ℤ)) (((i : ℕ) : ℤ) - 1) with ⟨h, _⟩ | ⟨h, _⟩
    · have := hhi i
      rw [h] at this
      rcases le_or_gt ((μ : ℤ) + 1 - ((i : ℕ) : ℤ)) 0 with hc | hc
      · rw [max_eq_left hc]; simp only [max_le_iff]; omega
      · rw [max_eq_right (le_of_lt hc)]; simp only [max_le_iff]; omega
    · have := hhi i
      rw [h] at this
      have : max 0 (D i - ((i : ℕ) : ℤ) + 1) = 0 := by
        rw [max_eq_left]; omega
      rw [this]
      exact le_max_left _ _
  calc stairDeg D ≤ degD (stairE n μ) := Finset.sum_le_sum fun i _ => hterm i
    _ = (uniformRank μ : ℤ) + 1 := hdeg

end StairBound

/-! ### The uniform divisor of large multiplicity -/

section LargeUniform

lemma two_mul_choose_two (k : ℕ) : 2 * k.choose 2 = k * (k - 1) := by
  rw [Nat.choose_two_right]
  rcases k with _ | j
  · simp
  · have hd : 2 ∣ (j + 1) * ((j + 1) - 1) := by
      have h : (j + 1) * ((j + 1) - 1) = j * (j + 1) := by
        simp only [Nat.add_sub_cancel]; ring
      rw [h]
      exact (Nat.even_mul_succ_self j).two_dvd
    obtain ⟨t, ht⟩ := hd
    rw [ht]
    omega

/-- Twice the genus of `K_n`. -/
theorem two_mul_genus_top_fin (n : ℕ) :
    2 * genus (⊤ : SimpleGraph (Fin n)) = (n : ℤ) * ((n : ℤ) - 1) - 2 * (n : ℤ) + 2 := by
  rcases n with _ | j
  · simp [genus, SimpleGraph.edgeFinset]
  · rw [genus_top, Fintype.card_fin]
    have h : ((2 * (j + 1).choose 2 : ℕ) : ℤ) = (((j + 1) * ((j + 1) - 1) : ℕ) : ℤ) := by
      exact_mod_cast two_mul_choose_two (j + 1)
    have hs : (j + 1) - 1 = j := by omega
    rw [hs] at h
    push_cast at h ⊢
    linarith

lemma degD_constDiv {n : ℕ} (c : ℤ) : degD (constDiv n c) = (n : ℤ) * c := by
  rw [degD]
  simp only [constDiv, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

/-- **The uniform divisor of large multiplicity.**  As soon as `m ≥ n` the divisor
`m • 1` has degree above `2g - 1`, so its rank is `deg - g` and the quadratic formula
`m(m+3)/2` no longer applies. -/
theorem two_mul_rank_const_top_large {n m : ℕ} [NeZero n] (hnm : n ≤ m) :
    2 * rank (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ))
      = 2 * (m : ℤ) * (n : ℤ) - (n : ℤ) * ((n : ℤ) - 1) + 2 * (n : ℤ) - 2 := by
  have hn0 : 0 < n := Nat.pos_of_ne_zero (NeZero.ne n)
  have hn : (1 : ℤ) ≤ (n : ℤ) := by exact_mod_cast hn0
  have hm : (n : ℤ) ≤ (m : ℤ) := by exact_mod_cast hnm
  have hg := two_mul_genus_top_fin n
  have hdeg : degD (constDiv n (m : ℤ)) = (n : ℤ) * (m : ℤ) := degD_constDiv _
  have hlarge : 2 * genus (⊤ : SimpleGraph (Fin n)) - 1 ≤ degD (constDiv n (m : ℤ)) := by
    rw [hdeg]
    nlinarith
  have := rank_eq_of_degD_large (⊤ : SimpleGraph (Fin n)) top_connected hlarge
  rw [this, hdeg]
  linarith

/-- **The rank of every uniform divisor on every complete graph.**  Combining
`rank_const_top` with the large-degree regime, the value is now known for all `m, n`. -/
theorem two_mul_rank_const_top_complete {n m : ℕ} [NeZero n] :
    2 * rank (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ))
      = if m + 1 ≤ n then (m : ℤ) * ((m : ℤ) + 3)
        else 2 * (m : ℤ) * (n : ℤ) - (n : ℤ) * ((n : ℤ) - 1) + 2 * (n : ℤ) - 2 := by
  by_cases h : m + 1 ≤ n
  · rw [if_pos h]
    exact two_mul_rank_const_top h
  · rw [if_neg h]
    exact two_mul_rank_const_top_large (by omega)

/-- **The exact excess over Riemann's inequality.**  For `n ≥ m + 1` the uniform divisor
on `K_n` beats the Riemann bound `deg D - g` by exactly `(n-m-1)(n-m-2)/2`, which is the
genus of the *complementary* complete graph `K_{n-m}`.  In particular the Riemann bound is
sharp precisely when `n = m + 1` or `n = m + 2`. -/
theorem two_mul_rank_const_top_defect {n m : ℕ} [NeZero n] (hmn : m + 1 ≤ n) :
    2 * (rank (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ))
          - degD (constDiv n (m : ℤ)) + genus (⊤ : SimpleGraph (Fin n)))
      = ((n : ℤ) - (m : ℤ) - 1) * ((n : ℤ) - (m : ℤ) - 2) := by
  have h1 := two_mul_rank_const_top (n := n) (m := m) hmn
  have h2 : degD (constDiv n (m : ℤ)) = (n : ℤ) * (m : ℤ) := degD_constDiv _
  have h3 := two_mul_genus_top_fin n
  rw [h2]
  linear_combination h1 + h3

end LargeUniform

/-! ### The half-canonical divisor on `K_{2m+3}` -/

section ThetaChar

variable {m : ℕ}

lemma choose_two_odd (m : ℕ) : (2 * m + 3).choose 2 = (2 * m + 3) * (m + 1) := by
  have h1 : 2 * m + 3 - 1 = 2 * (m + 1) := by omega
  rw [Nat.choose_two_right, h1,
    show (2 * m + 3) * (2 * (m + 1)) = ((2 * m + 3) * (m + 1)) * 2 by ring]
  exact Nat.mul_div_cancel _ (by norm_num)

/-- The genus of `K_{2m+3}` is `2m² + 3m + 1`. -/
theorem genus_top_odd :
    genus (⊤ : SimpleGraph (Fin (2 * m + 3))) = 2 * (m : ℤ) ^ 2 + 3 * (m : ℤ) + 1 := by
  rw [genus_top, Fintype.card_fin, choose_two_odd]
  push_cast
  ring

/-- **`m • 1` is a theta characteristic of `K_{2m+3}`**: twice it is the canonical
divisor. -/
theorem thetaChar_const_top :
    constDiv (2 * m + 3) (m : ℤ) + constDiv (2 * m + 3) (m : ℤ)
      = canonical (⊤ : SimpleGraph (Fin (2 * m + 3))) := by
  rw [canonical_top, Fintype.card_fin]
  funext v
  simp only [constDiv, Pi.add_apply]
  push_cast
  ring

/-- Its degree is the half-canonical degree `g - 1`. -/
theorem degD_const_top_half_canonical :
    degD (constDiv (2 * m + 3) (m : ℤ)) = genus (⊤ : SimpleGraph (Fin (2 * m + 3))) - 1 := by
  rw [genus_top_odd, degD]
  simp only [constDiv, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  push_cast
  ring

/-- **`4 r > g` on `K_{2m+3}` for `m ≥ 1`.**  The rank of the half-canonical uniform
divisor is a positive proportion of the genus — far above the `O(√g)` predicted by the
Brill–Noether heuristic. -/
theorem four_mul_rank_gt_genus_top (hm : 1 ≤ m) :
    genus (⊤ : SimpleGraph (Fin (2 * m + 3)))
      < 4 * rank (⊤ : SimpleGraph (Fin (2 * m + 3))) (constDiv (2 * m + 3) (m : ℤ)) := by
  haveI : NeZero (2 * m + 3) := ⟨by omega⟩
  have hr := two_mul_rank_const_top (n := 2 * m + 3) (m := m) (by omega)
  rw [genus_top_odd]
  have hm' : (1 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hm
  nlinarith [hr]

/-- **The half-canonical rank of `K_{2m+3}` beats the universal bound `k - 1`.**
The complete graph `K_{2m+3}` is `k`-regular with `k = 2m + 2`; for `m ≥ 3` the uniform
theta characteristic has rank strictly larger than `k - 1`. -/
theorem rank_const_top_gt_regularity (hm : 3 ≤ m) :
    (2 * (m : ℤ) + 1)
      < rank (⊤ : SimpleGraph (Fin (2 * m + 3))) (constDiv (2 * m + 3) (m : ℤ)) := by
  haveI : NeZero (2 * m + 3) := ⟨by omega⟩
  have hr := two_mul_rank_const_top (n := 2 * m + 3) (m := m) (by omega)
  have hm' : (3 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hm
  nlinarith [hr]

/-- At `m = 2` (that is, on `K_7`) the bound `k - 1` is attained exactly. -/
theorem rank_const_top_eq_regularity_two :
    rank (⊤ : SimpleGraph (Fin 7)) (constDiv 7 (2 : ℤ)) = 5 := by
  have hr := two_mul_rank_const_top (n := 7) (m := 2) (by omega)
  push_cast at hr
  omega

end ThetaChar

/-! ### A counterexample to the conjectured closed formula -/

section Counterexample

/-- The closed formula `a(a+1)/2 + min(b, a)` (where `d = a(n-1) + b`) conjectured for
the maximal Baker–Norine rank in degree `d` on `K_n`. -/
def concFormula (n d : ℕ) : ℕ :=
  (d / (n - 1)) * (d / (n - 1) + 1) / 2 + min (d % (n - 1)) (d / (n - 1))

lemma concFormula_three_six : concFormula 3 6 = 6 := by
  norm_num [concFormula]

/-- The genus of `K_3` is `1`. -/
theorem genus_top_three : genus (⊤ : SimpleGraph (Fin 3)) = 1 := by
  rw [genus_top, Fintype.card_fin]
  norm_num

/-- On `K_3` **every** divisor of degree `6` has rank exactly `5`. -/
theorem rank_eq_five_of_degD_six {D : Divisor (Fin 3)} (h : degD D = 6) :
    rank (⊤ : SimpleGraph (Fin 3)) D = 5 := by
  have hg : genus (⊤ : SimpleGraph (Fin 3)) = 1 := genus_top_three
  have := rank_eq_of_degD_large (⊤ : SimpleGraph (Fin 3)) top_connected
    (D := D) (by rw [hg, h]; norm_num)
  rw [this, hg, h]
  norm_num

/-- **The conjectured formula is false.**  On `K_3` in degree `6` it predicts a maximal
rank of `6`, but the concentrated divisor `6 · q` — like every divisor of degree `6` —
has rank `5`. -/
theorem rank_ne_concFormula_K3 :
    rank (⊤ : SimpleGraph (Fin 3)) (chip (0 : Fin 3) 6) ≠ (concFormula 3 6 : ℤ) := by
  rw [rank_eq_five_of_degD_six (degD_chip _ _), concFormula_three_six]
  norm_num

/-- Stronger: no divisor of degree `6` on `K_3` reaches the conjectured value. -/
theorem no_divisor_attains_concFormula_K3 :
    ∀ D : Divisor (Fin 3), degD D = 6 →
      rank (⊤ : SimpleGraph (Fin 3)) D < (concFormula 3 6 : ℤ) := by
  intro D h
  rw [rank_eq_five_of_degD_six h, concFormula_three_six]
  norm_num

end Counterexample

end TropicalRR