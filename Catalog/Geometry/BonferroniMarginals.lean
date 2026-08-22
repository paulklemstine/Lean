/-
# Which marginals? — the second-moment upgrade of the Bonferroni machinery

Research thread *Compression Beyond the Pigeonhole Bound*, cycle v19c.

`Geometry.AlmostLosslessConverse` formalises the **second Bonferroni inequality**
(`AlmostLossless.card_sum_le_card_biUnion_add_offDiag`) for an *arbitrary* finite
family of finite sets and feeds it two marginals of the uniform random codebook:

* the first marginal `M · |{H : H p = H q}| = M^{|ι|}` (probability `1/M`), and
* the second marginal `M² · |{H : H p = H r = H q}| ≤ M^{|ι|}` (probability `1/M²`).

The output is the failure bound `P[failure] ≥ k/(2M)`, valid **only** in the
regime `2(k-1) ≤ M`.  This file asks the structural question suggested by that
shape: *is the regime restriction a property of the marginals, or of the
machinery?*  The answer proved here is: **of the machinery**.

Contents.

* `BonferroniMarginals.sq_sum_card_le_card_biUnion_mul_sum_inter` — the
  **Chung–Erdős / second-moment (Paley–Zygmund) inequality in exact counting
  form**, for an arbitrary finite family of finite sets:
  `(∑ |A i|)² ≤ |⋃ A i| · ∑_{(i,j)} |A i ∩ A j|`.
  Proved from scratch by double counting the multiplicity function
  `f w = #{i ∈ I : w ∈ A i}` and Cauchy–Schwarz.
* `BonferroniMarginals.card_biUnion_lower_of_marginals` — the abstract
  *marginal-profile* theorem.  A family with **first marginal `1/m`** and
  **second marginal `≤ 1/c`** satisfies
  `c·k·N ≤ m·|⋃ A i|·(c + m(k-1))`, i.e. `P[⋃] ≥ k / (m + m²(k-1)/c)`,
  with **no upper restriction on `k`**.
* `BonferroniMarginals.marginal_bound_sharp` — the abstract theorem is
  **attained**: a constant family with `c = m` turns the inequality into an
  equality, so no improvement is possible from the marginal profile alone.
* `BonferroniMarginals.bonferroni_conclusion_fails_without_pairwise` — the
  Bonferroni conclusion `|⋃| ≥ kN/(2m)` is *false* for that same family:
  the second marginal is genuinely load-bearing.
* `BonferroniMarginals.hashing_failure_lower_unconditional` — feeding the two
  catalog marginals into the second-moment machinery instead of into Bonferroni
  yields `k · M^{|α|} ≤ |failSet| · (M + k - 1)`, i.e.
  `P[failure] ≥ k/(M+k-1)` **unconditionally**.
* `BonferroniMarginals.chung_erdos_dominates_bonferroni` — in the whole
  Bonferroni regime `2(k-1) ≤ M` the new bound is at least as strong.
* `BonferroniMarginals.hashing_failure_above_rate` — the new bound has content
  the Bonferroni bound cannot have: for `k ≥ M` a uniformly random codebook
  fails with probability `> 1/2`.  Random hashing therefore has a genuine
  *converse*, matching the pigeonhole converse `converse_card_good_le`.
-/
import Geometry.AlmostLosslessConverse

namespace BonferroniMarginals

open Finset

/-! ## 1. The second-moment (Chung–Erdős) inequality in counting form -/

/-- **Chung–Erdős inequality, exact counting form.**  For any finite family
`A : ι → Finset Ω` indexed by `I`,
`(∑_{i ∈ I} |A i|)² ≤ |⋃_{i ∈ I} A i| · ∑_{(i,j) ∈ I × I} |A i ∩ A j|`.

The proof is a double count: the multiplicity function
`f w = #{i ∈ I : w ∈ A i}` satisfies `∑_i |A i| = ∑_{w ∈ ⋃} f w` and
`∑_{i,j} |A i ∩ A j| = ∑_{w ∈ ⋃} f w²`, and Cauchy–Schwarz on the support
finishes.  This is the *second-moment* counterpart of the second Bonferroni
inequality `AlmostLossless.card_sum_le_card_biUnion_add_offDiag`. -/
theorem sq_sum_card_le_card_biUnion_mul_sum_inter {ι Ω : Type*} [DecidableEq ι] [DecidableEq Ω]
    (A : ι → Finset Ω) (I : Finset ι) :
    (∑ i ∈ I, (A i).card) ^ 2
      ≤ (I.biUnion A).card * ∑ p ∈ I ×ˢ I, (A p.1 ∩ A p.2).card := by
  classical
  set U := I.biUnion A with hU
  set f : Ω → ℕ := fun w => (I.filter (fun i => w ∈ A i)).card with hf
  have hsub : ∀ i ∈ I, A i ⊆ U := by
    intro i hi w hw; exact mem_biUnion.2 ⟨i, hi, hw⟩
  have hcardA : ∀ i ∈ I, (A i).card = ∑ w ∈ U, (if w ∈ A i then 1 else 0) := by
    intro i hi
    rw [← Finset.card_filter, Finset.filter_mem_eq_inter, Finset.inter_eq_right.2 (hsub i hi)]
  have key1 : ∑ i ∈ I, (A i).card = ∑ w ∈ U, f w := by
    rw [Finset.sum_congr rfl hcardA, Finset.sum_comm]
    exact Finset.sum_congr rfl (fun w _ => (Finset.card_filter _ _).symm)
  have hcardI : ∀ p ∈ I ×ˢ I, (A p.1 ∩ A p.2).card
      = ∑ w ∈ U, (if w ∈ A p.1 then 1 else 0) * (if w ∈ A p.2 then 1 else 0) := by
    intro p hp
    rw [mem_product] at hp
    have hprod : ∀ w, (if w ∈ A p.1 then 1 else 0) * (if w ∈ A p.2 then 1 else 0)
        = (if w ∈ A p.1 ∩ A p.2 then 1 else 0) := by
      intro w; by_cases h1 : w ∈ A p.1 <;> by_cases h2 : w ∈ A p.2 <;> simp [h1, h2]
    simp only [hprod]
    rw [← Finset.card_filter, Finset.filter_mem_eq_inter,
      Finset.inter_eq_right.2 (subset_trans Finset.inter_subset_left (hsub p.1 hp.1))]
  have key2 : ∑ p ∈ I ×ˢ I, (A p.1 ∩ A p.2).card = ∑ w ∈ U, (f w) ^ 2 := by
    rw [Finset.sum_congr rfl hcardI, Finset.sum_comm]
    refine Finset.sum_congr rfl (fun w _ => ?_)
    have hfw : f w = ∑ i ∈ I, (if w ∈ A i then 1 else 0) := Finset.card_filter _ _
    rw [hfw, sq, Finset.sum_mul_sum, Finset.sum_product]
  rw [key1, key2]
  exact sq_sum_le_card_mul_sum_sq

/-! ## 2. The abstract marginal-profile theorem -/

/-- **Marginal-profile lower bound for a union.**  Suppose every member of the
family has *first marginal exactly `1/m`* (`m·|A i| = N`, where `N` is the size
of the ambient probability space) and every ordered pair of distinct members has
*second marginal at most `1/c`* (`c·|A i ∩ A j| ≤ N`).  Then, writing
`k = |I|` and `U = ⋃ A i`,

`c · k · N ≤ m · |U| · (c + m·(k-1))`,

i.e. `P[U] ≥ k / (m + m²(k-1)/c)`.  Unlike the Bonferroni output
`AlmostLossless.failure_prob_lower_bound_real` this holds for **every** `k`:
the regime restriction `2(k-1) ≤ m` of the Bonferroni route is an artefact of
the inequality used, not of the marginals. -/
theorem card_biUnion_lower_of_marginals {ι Ω : Type*} [DecidableEq ι] [DecidableEq Ω]
    (A : ι → Finset Ω) (I : Finset ι) {m c N : ℕ} (hN : 0 < N)
    (hmarg : ∀ i ∈ I, m * (A i).card = N)
    (hpair : ∀ p ∈ I.offDiag, c * (A p.1 ∩ A p.2).card ≤ N) :
    c * I.card * N ≤ m * (I.biUnion A).card * (c + m * (I.card - 1)) := by
  classical
  set k := I.card with hk
  rcases Nat.eq_zero_or_pos k with hk0 | hkpos
  · simp [hk0]
  set U := I.biUnion A with hU
  set T := ∑ p ∈ I ×ˢ I, (A p.1 ∩ A p.2).card with hT
  -- first moment
  have hfirst : m * ∑ i ∈ I, (A i).card = k * N := by
    rw [Finset.mul_sum, Finset.sum_congr rfl hmarg, Finset.sum_const, smul_eq_mul, hk]
  -- split the second moment into diagonal and off-diagonal parts
  have hsplit : T = ∑ i ∈ I, (A i).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card := by
    rw [hT, ← Finset.diag_union_offDiag I,
      Finset.sum_union (Finset.disjoint_diag_offDiag I)]
    congr 1
    rw [Finset.sum_diag]
    exact Finset.sum_congr rfl (fun i _ => by rw [Finset.inter_self])
  have hoff : c * ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card ≤ (k * k - k) * N := by
    calc c * ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card
        = ∑ p ∈ I.offDiag, c * (A p.1 ∩ A p.2).card := by rw [Finset.mul_sum]
      _ ≤ ∑ _p ∈ I.offDiag, N := Finset.sum_le_sum hpair
      _ = (k * k - k) * N := by rw [Finset.sum_const, smul_eq_mul, Finset.offDiag_card, hk]
  -- second moment bound
  have hsecond : m * c * T ≤ c * (k * N) + m * ((k * k - k) * N) := by
    rw [hsplit, Nat.mul_add]
    have h1 : m * c * ∑ i ∈ I, (A i).card = c * (m * ∑ i ∈ I, (A i).card) := by ring
    have h2 : m * c * ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card
        = m * (c * ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card) := by ring
    rw [h1, h2, hfirst]
    exact Nat.add_le_add_left (Nat.mul_le_mul_left _ hoff) _
  -- Chung–Erdős, scaled by `m² c`
  have hCE := sq_sum_card_le_card_biUnion_mul_sum_inter A I
  have hscaled : c * (k * N) ^ 2 ≤ m * U.card * (c * (k * N) + m * ((k * k - k) * N)) := by
    calc c * (k * N) ^ 2 = c * (m * ∑ i ∈ I, (A i).card) ^ 2 := by rw [hfirst]
      _ = m * m * c * (∑ i ∈ I, (A i).card) ^ 2 := by ring
      _ ≤ m * m * c * (U.card * T) := Nat.mul_le_mul_left _ hCE
      _ = m * U.card * (m * c * T) := by ring
      _ ≤ m * U.card * (c * (k * N) + m * ((k * k - k) * N)) :=
          Nat.mul_le_mul_left _ hsecond
  -- rewrite the right-hand side as `(k * N) * (m * |U| * (c + m * (k - 1)))`
  have hkk : k * k - k = k * (k - 1) := by
    rw [Nat.mul_sub, mul_one]
  have hrhs : m * U.card * (c * (k * N) + m * ((k * k - k) * N))
      = (k * N) * (m * U.card * (c + m * (k - 1))) := by
    rw [hkk]; ring
  have hlhs : c * (k * N) ^ 2 = (k * N) * (c * k * N) := by ring
  rw [hlhs, hrhs] at hscaled
  exact Nat.le_of_mul_le_mul_left hscaled (Nat.mul_pos hkpos hN)

/-- Real-valued form of the marginal-profile theorem: the union has probability
at least `c·k / (m·(c + m(k-1)))`. -/
theorem prob_biUnion_lower_of_marginals {ι Ω : Type*} [DecidableEq ι] [DecidableEq Ω]
    (A : ι → Finset Ω) (I : Finset ι) {m c N : ℕ} (hN : 0 < N) (hm : 0 < m)
    (hc : 0 < c) (hmarg : ∀ i ∈ I, m * (A i).card = N)
    (hpair : ∀ p ∈ I.offDiag, c * (A p.1 ∩ A p.2).card ≤ N) :
    (c : ℝ) * I.card / ((m : ℝ) * (c + m * ((I.card : ℝ) - 1)))
      ≤ ((I.biUnion A).card : ℝ) / N := by
  classical
  rcases Nat.eq_zero_or_pos I.card with hk0 | hkpos
  · rw [hk0]
    simp only [Nat.cast_zero, mul_zero, zero_div]
    positivity
  have hbase := card_biUnion_lower_of_marginals A I hN hmarg hpair
  have hk1 : ((I.card - 1 : ℕ) : ℝ) = (I.card : ℝ) - 1 := by
    have h1 : (1 : ℕ) ≤ I.card := hkpos
    push_cast [Nat.cast_sub h1]; ring
  have hcast : (c : ℝ) * I.card * N
      ≤ (m : ℝ) * (I.biUnion A).card * (c + m * ((I.card : ℝ) - 1)) := by
    have h := (Nat.cast_le (α := ℝ)).2 hbase
    push_cast [hk1] at h
    linarith
  have hmpos : (0 : ℝ) < m := by exact_mod_cast hm
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hcpos : (0 : ℝ) < c := by exact_mod_cast hc
  have hkpos' : (1 : ℝ) ≤ (I.card : ℝ) := by exact_mod_cast hkpos
  have hden : (0 : ℝ) < (m : ℝ) * (c + m * ((I.card : ℝ) - 1)) := by
    have hnn : (0 : ℝ) ≤ m * ((I.card : ℝ) - 1) := by nlinarith
    nlinarith
  rw [div_le_div_iff₀ hden hNpos]
  nlinarith [hcast]

/-! ## 3. Sharpness of the abstract theorem, and necessity of the second marginal

The extremal family is the constant one: `k` copies of a single atom in a space
of size `N = m`.  Its first marginal is exactly `1/m`, its second marginal is
also `1/m` (the worst possible, `c = m`), and its union has probability exactly
`1/m` however large `k` is. -/

/-- The constant family `A i = {0}` in `Fin 2`, indexed by three points. -/
private def cst : ℕ → Finset (Fin 2) := fun _ => {0}

/-- **The abstract marginal bound is attained.**  For the constant family with
`m = c = N = 2` and `k = 3` the inequality
`c·k·N ≤ m·|U|·(c + m(k-1))` holds with *equality* (`12 = 12`).  Hence
`card_biUnion_lower_of_marginals` cannot be improved as a function of the
marginal profile `(m, c, k, N)` alone. -/
theorem marginal_bound_sharp :
    ∃ (A : ℕ → Finset (Fin 2)) (I : Finset ℕ) (m c N : ℕ),
      0 < N ∧ (∀ i ∈ I, m * (A i).card = N) ∧
      (∀ p ∈ I.offDiag, c * (A p.1 ∩ A p.2).card ≤ N) ∧
      c * I.card * N = m * (I.biUnion A).card * (c + m * (I.card - 1)) := by
  refine ⟨cst, {0, 1, 2}, 2, 2, 2, by norm_num, ?_, ?_, ?_⟩
  · intro i _; simp [cst]
  · intro p _; simp [cst]
  · decide

/-- **The second marginal is load-bearing.**  The Bonferroni-style conclusion
`|U| ≥ k·N/(2m)` — the shape of `AlmostLossless.failure_prob_lower_bound_real` —
*fails* for the constant family, which has a perfect first marginal but no
pairwise control: with `m = N = 2` and `k = 3` one has `2m|U| = 4 < 6 = kN`.
So the pairwise hypothesis fed into the Bonferroni machinery cannot be dropped,
and neither can the pairwise hypothesis of `card_biUnion_lower_of_marginals`. -/
theorem bonferroni_conclusion_fails_without_pairwise :
    ∃ (A : ℕ → Finset (Fin 2)) (I : Finset ℕ) (m N : ℕ),
      0 < N ∧ (∀ i ∈ I, m * (A i).card = N) ∧
      2 * m * ((I.biUnion A).card) < I.card * N := by
  refine ⟨cst, {0, 1, 2}, 2, 2, by norm_num, ?_, ?_⟩
  · intro i _; simp [cst]
  · decide

/-! ## 4. Feeding the catalog's two marginals into the second-moment machinery -/

open AlmostLossless

variable {α : Type*} [Fintype α] [DecidableEq α] {M : ℕ}

/-- **Unconditional lower bound on the failure probability of uniform random
hashing.**  The *same two marginals* used by
`AlmostLossless.failure_prob_lower_bound` — the exact first marginal
`card_collisionEvent_mul` and the pairwise bound `card_doubleCollision_mul_le` —
give, through the second-moment machinery,

`k · M^{|α|} ≤ |failSet S x M| · (M + k - 1)`,  `k = |S \ {x}|`,

with **no restriction relating `k` and `M`**.  Equivalently
`P[failure] ≥ k/(M+k-1)`. -/
theorem hashing_failure_lower_unconditional (S : Finset α) (x : α) (hM : 0 < M) :
    (S.erase x).card * M ^ Fintype.card α
      ≤ (failSet S x M).card * (M + (S.erase x).card - 1) := by
  classical
  rcases Nat.eq_zero_or_pos (S.erase x).card with hk0 | hkpos
  · simp [hk0]
  set D := S.erase x with hD
  set N := M ^ Fintype.card α with hN
  have hNpos : 0 < N := pow_pos hM _
  have hmarg : ∀ y ∈ D, M * (collisionEvent M y x).card = N := by
    intro y hy; exact card_collisionEvent_mul (Finset.mem_erase.1 hy).1
  have hpair : ∀ p ∈ D.offDiag,
      M ^ 2 * ((collisionEvent M p.1 x) ∩ (collisionEvent M p.2 x)).card ≤ N := by
    intro p hp
    rw [Finset.mem_offDiag] at hp
    exact card_doubleCollision_mul_le hp.2.2 (Finset.mem_erase.1 hp.1).1
      (Finset.mem_erase.1 hp.2.1).1
  have hmain := card_biUnion_lower_of_marginals
    (fun y => collisionEvent M y x) D hNpos hmarg hpair
  rw [← failSet_eq_biUnion S x] at hmain
  -- `M² k N ≤ M |F| (M² + M(k-1)) = M² (|F| (M + k - 1))`
  set k := D.card with hk
  set F := (failSet S x M).card with hF
  have hrw : M * F * (M ^ 2 + M * (k - 1)) = M ^ 2 * (F * (M + k - 1)) := by
    have h1 : M + k - 1 = M + (k - 1) := by omega
    rw [h1]; ring
  rw [hrw] at hmain
  have hML : M ^ 2 * (k * N) ≤ M ^ 2 * (F * (M + k - 1)) := by
    calc M ^ 2 * (k * N) = M ^ 2 * k * N := by ring
      _ ≤ M ^ 2 * (F * (M + k - 1)) := hmain
  exact Nat.le_of_mul_le_mul_left hML (pow_pos hM 2)

/-- Real-valued form: the failure probability of a uniformly random codebook is
at least `k/(M+k-1)`. -/
theorem hashing_failure_prob_lower (S : Finset α) (x : α) (hM : 0 < M) :
    ((S.erase x).card : ℝ) / ((M : ℝ) + (S.erase x).card - 1)
      ≤ ((failSet S x M).card : ℝ) / ((M : ℝ) ^ Fintype.card α) := by
  classical
  have hbase := hashing_failure_lower_unconditional (M := M) S x hM
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hM1 : (1 : ℝ) ≤ (M : ℝ) := by exact_mod_cast hM
  have hNpos : (0 : ℝ) < (M : ℝ) ^ Fintype.card α := by positivity
  rcases Nat.eq_zero_or_pos (S.erase x).card with hk0 | hkpos
  · rw [hk0]
    simp only [Nat.cast_zero, zero_div]
    positivity
  have hden : (0 : ℝ) < (M : ℝ) + (S.erase x).card - 1 := by
    have hk1 : (1 : ℝ) ≤ ((S.erase x).card : ℝ) := by exact_mod_cast hkpos
    linarith
  have hcast : ((S.erase x).card : ℝ) * (M : ℝ) ^ Fintype.card α
      ≤ ((failSet S x M).card : ℝ) * ((M : ℝ) + (S.erase x).card - 1) := by
    have h := (Nat.cast_le (α := ℝ)).2 hbase
    have hsub : ((M + (S.erase x).card - 1 : ℕ) : ℝ) = (M : ℝ) + (S.erase x).card - 1 := by
      have h1 : 1 ≤ M + (S.erase x).card := by omega
      push_cast [Nat.cast_sub h1]; ring
    push_cast [hsub] at h
    linarith
  rw [div_le_div_iff₀ hden hNpos]
  nlinarith [hcast]

/-- **The second-moment bound dominates the Bonferroni bound throughout the
Bonferroni regime.**  Whenever `2(k-1) ≤ M` — the hypothesis of
`AlmostLossless.failure_prob_lower_bound_real` — the new bound `k/(M+k-1)` is at
least the old bound `k/(2M)`.  So nothing is lost and the regime restriction is
removed. -/
theorem chung_erdos_dominates_bonferroni {k M : ℕ} (hM : 0 < M) (hk : k ≤ M + 1) :
    (k : ℝ) / (2 * M) ≤ (k : ℝ) / ((M : ℝ) + k - 1) := by
  rcases Nat.eq_zero_or_pos k with hk0 | hkpos
  · simp [hk0]
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hk1 : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hkpos
  have hkM : (k : ℝ) ≤ (M : ℝ) + 1 := by exact_mod_cast hk
  have hden : (0 : ℝ) < (M : ℝ) + k - 1 := by linarith
  apply div_le_div_of_nonneg_left (by linarith) hden
  linarith

/-- **A converse for random hashing.**  Above the pigeonhole rate — as soon as
the typical set has at least `M` competitors — a uniformly random codebook fails
with probability strictly greater than `1/2`.  The Bonferroni bound `k/(2M)` is
vacuous here (it exceeds `1` yet its hypothesis `2(k-1) ≤ M` is violated); the
second-moment bound is not.  This is the random-coding analogue of the
pigeonhole converse `AlmostLossless.converse_card_good_le`. -/
theorem hashing_failure_above_rate (S : Finset α) (x : α) (hM : 0 < M)
    (hk : M ≤ (S.erase x).card) :
    (1 : ℝ) / 2 < ((failSet S x M).card : ℝ) / ((M : ℝ) ^ Fintype.card α) := by
  classical
  have hbase := hashing_failure_prob_lower (M := M) S x hM
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hM1 : (1 : ℝ) ≤ (M : ℝ) := by exact_mod_cast hM
  have hkM : (M : ℝ) ≤ ((S.erase x).card : ℝ) := by exact_mod_cast hk
  have hden : (0 : ℝ) < (M : ℝ) + (S.erase x).card - 1 := by linarith
  have hhalf : (1 : ℝ) / 2 < ((S.erase x).card : ℝ) / ((M : ℝ) + (S.erase x).card - 1) := by
    rw [div_lt_div_iff₀ (by norm_num) hden]
    linarith
  linarith [hbase]

end BonferroniMarginals