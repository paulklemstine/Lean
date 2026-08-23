import Probability.SharedTailServingCeiling

/-!
# The sharing phase transition: how many fine-tunes can one shared model serve?

This file closes the `k ≥ 3` half of the open conjecture left by the NET-54
cycle (`FUTURE_DIRECTIONS.md`, Conjecture 2).

`SharedTailServingCeiling.sharing_ceiling_mean` proves that a single shared model
`H` imitating `k` fine-tunes that pairwise agree at most `β` of the time can never
exceed **mean** agreement `(1 + β)/2`.  That bound comes from the Hamming triangle
inequality applied pair by pair and is therefore *independent of `k`*.  The open
question was whether it is attainable for `k ≥ 3`, or whether the achievable value
decays as more fine-tunes are served.

The answer proved here is a sharp phase transition governed by the single quantity
`k (1 − β)` (the number of fine-tunes times their pairwise *disagreement*):

* **A multiplicity (Plotkin-type) bound.**  `sum_agree_sq_bound` counts, position by
  position, how many of the `k` fine-tunes the shared model can match at once.  Two
  fine-tunes matched at the same position agree there, so the pairwise budget
  `β` limits the *square* of the matched count.  Cauchy–Schwarz turns this into
  a quadratic inequality on the total agreement:
  `(∑ᵢ agr(H, Aᵢ))² ≤ ∑ᵢ agr(H, Aᵢ) + k(k−1)β`, equivalently (mean form)
  `k M² ≤ M + (k−1)β` for `M` the mean agreement.  This bound *does* depend on `k`.
* **Strict decay above the threshold.**  `sharing_strict_decay`: if `k(1 − β) > 2`
  then `M < (1 + β)/2` strictly — the pairwise ceiling becomes unreachable.
* **Attainment at the threshold.**  `hub_attains_sharing_ceiling`: for every `k` there
  is a family of `k` fine-tunes with pairwise agreement exactly `β = 1 − 2/k`
  (so `k(1 − β) = 2`) and a shared model whose agreement with *each* of them equals
  the ceiling `(1 + β)/2` exactly.  Hence the threshold `k(1 − β) = 2` is sharp and
  the ceiling theorem cannot be improved below it.
* **A serving-capacity bound.**  `sharing_capacity_bound` reads the transition as a
  capacity: any family served at the ceiling satisfies `k ≤ 2/(1 − β)`.  At the
  measured NET-54 cross-parent baseline `β = 0.8327` this is
  `net54_sharing_capacity_le_eleven`: **at most 11 fine-tunes** can be served at the
  pairwise ceiling, and from `k = 12` on the achievable mean agreement is strictly
  smaller (`net54_twelve_finetunes_below_ceiling`).
* **Asymptotics.**  `sharing_mean_le_sqrt`: `M ≤ √β + 1/k`, so as `k → ∞` the mean
  agreement of one shared model is at most `√β`, strictly below `(1 + β)/2` by AM–GM
  (`sqrt_lt_ceiling`).  Serving many fine-tunes from one set of weights is governed
  by the geometric mean of the pairwise budget, not the arithmetic one.
-/

namespace Catalog.Probability.MultiFineTuneSharingPhase

open Finset
open Catalog.Probability.TailTransplantGeometry

variable {Ω Y : Type*} [Fintype Ω] [DecidableEq Ω] [DecidableEq Y]
variable {k : ℕ}

/-! ### 1. Counting how many fine-tunes a shared model matches at a position -/

/-- Total number of (position, index) incidences at which the shared model matches. -/
lemma sum_match_count (S : Fin k → Finset Ω) :
    ∑ x : Ω, ((univ.filter (fun i => x ∈ S i)).card) = ∑ i, (S i).card := by
  classical
  simp_rw [Finset.card_filter]
  rw [Finset.sum_comm]
  simp

/-- The *square* of the matched count, summed over positions, counts ordered pairs of
fine-tunes matched at a common position. -/
lemma sum_sq_match_count (S : Fin k → Finset Ω) :
    ∑ x : Ω, ((univ.filter (fun i => x ∈ S i)).card) ^ 2
      = ∑ i, ∑ j, ((S i) ∩ (S j)).card := by
  classical
  have h : ∀ x : Ω, ((univ.filter (fun i => x ∈ S i)).card) ^ 2
      = ∑ i, ∑ j, (if x ∈ S i then 1 else 0) * (if x ∈ S j then 1 else 0) := by
    intro x
    rw [Finset.card_filter, sq, Finset.sum_mul_sum]
  simp_rw [h]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl ?_
  intro i _
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl ?_
  intro j _
  have hx : ∀ x : Ω, (if x ∈ S i then 1 else 0) * (if x ∈ S j then (1 : ℕ) else 0)
      = if x ∈ S i ∩ S j then 1 else 0 := by
    intro x; by_cases h1 : x ∈ S i <;> by_cases h2 : x ∈ S j <;> simp [h1, h2]
  simp_rw [hx]
  rw [← Finset.card_filter]
  congr 1
  ext y
  simp

/-- Two fine-tunes matched by the shared model at the same position agree there:
this is what makes the pairwise budget bite on the matched counts. -/
lemma inter_agreeSet_subset (H f g : Ω → Y) :
    agreeSet H f ∩ agreeSet H g ⊆ agreeSet f g := by
  intro x hx
  rw [Finset.mem_inter] at hx
  simp only [agreeSet, Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
  rw [← hx.1, ← hx.2]

omit [DecidableEq Ω] in
lemma card_agreeSet_eq (hN : 0 < Fintype.card Ω) (f g : Ω → Y) :
    ((agreeSet f g).card : ℝ) = agreeFrac f g * (Fintype.card Ω : ℝ) := by
  have hpos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
  rw [agreeFrac, div_mul_cancel₀ _ (ne_of_gt hpos)]

/-! ### 2. The multiplicity bound -/

/-- **The multiplicity (Plotkin-type) bound.**  For `k` fine-tunes that pairwise agree
at most `β` of the time, the *total* agreement `s = ∑ᵢ agr(H, Aᵢ)` of any single shared
model obeys the quadratic inequality `s² ≤ s + k(k−1)β`.

The proof is a double count: at each position, the number of fine-tunes the shared
model matches contributes its square to the number of matched *pairs*, and every
matched pair is a position at which those two fine-tunes agree — of which there are at
most `β` per pair.  Cauchy–Schwarz converts the average of the squares into the square
of the average. -/
theorem sum_agree_sq_bound (hN : 0 < Fintype.card Ω)
    (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ)
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta) :
    (∑ i, agreeFrac H (A i)) ^ 2
      ≤ (∑ i, agreeFrac H (A i)) + (k : ℝ) * ((k : ℝ) - 1) * beta := by
  classical
  set N : ℝ := (Fintype.card Ω : ℝ) with hNdef
  have hNpos : (0 : ℝ) < N := by rw [hNdef]; exact_mod_cast hN
  set S : Fin k → Finset Ω := fun i => agreeSet H (A i) with hS
  set n : Ω → ℕ := fun x => (univ.filter (fun i => x ∈ S i)).card with hn
  set a : Fin k → ℝ := fun i => agreeFrac H (A i) with ha
  have h0 : ∑ x, n x = ∑ i, (S i).card := sum_match_count S
  have hT : (∑ x, (n x : ℝ)) = N * ∑ i, a i := by
    have hcast : ((∑ x, n x : ℕ) : ℝ) = ((∑ i, (S i).card : ℕ) : ℝ) := by exact_mod_cast h0
    push_cast at hcast
    rw [hcast, Finset.mul_sum]
    refine Finset.sum_congr rfl ?_
    intro i _
    rw [ha, hS]
    simp only
    rw [card_agreeSet_eq hN]
    ring
  have hQ : (∑ x, (n x : ℝ) ^ 2) ≤ N * (∑ i, a i) + (k : ℝ) * ((k : ℝ) - 1) * beta * N := by
    have hEq := sum_sq_match_count S
    have hcast : (∑ x, (n x : ℝ) ^ 2) = ∑ i, ∑ j, (((S i) ∩ (S j)).card : ℝ) := by
      have h1 := congrArg (fun m : ℕ => (m : ℝ)) hEq
      push_cast at h1
      exact h1
    rw [hcast]
    have hrow : ∀ i : Fin k,
        ∑ j, (((S i) ∩ (S j)).card : ℝ) ≤ a i * N + ((k : ℝ) - 1) * (beta * N) := by
      intro i
      rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
      have hdiag : (((S i) ∩ (S i)).card : ℝ) = a i * N := by
        rw [Finset.inter_self, hS, ha]
        exact card_agreeSet_eq hN _ _
      have hoff : ∀ j ∈ Finset.univ.erase i, (((S i) ∩ (S j)).card : ℝ) ≤ beta * N := by
        intro j hj
        have hne : i ≠ j := fun h => (Finset.ne_of_mem_erase hj) h.symm
        have h1 : (((S i) ∩ (S j)).card : ℝ) ≤ ((agreeSet (A i) (A j)).card : ℝ) := by
          have := Finset.card_le_card (inter_agreeSet_subset H (A i) (A j))
          exact_mod_cast this
        have h2 : ((agreeSet (A i) (A j)).card : ℝ) = agreeFrac (A i) (A j) * N :=
          card_agreeSet_eq hN _ _
        have h3 : agreeFrac (A i) (A j) * N ≤ beta * N := by
          have := hpair i j hne
          nlinarith
        linarith [h1, h2 ▸ h1]
      have hsum : ∑ j ∈ Finset.univ.erase i, (((S i) ∩ (S j)).card : ℝ)
          ≤ ∑ _j ∈ Finset.univ.erase i, (beta * N) := Finset.sum_le_sum hoff
      rw [Finset.sum_const, nsmul_eq_mul] at hsum
      have hcard : ((Finset.univ.erase i).card : ℝ) = (k : ℝ) - 1 := by
        have h1 : (Finset.univ.erase i).card = k - 1 := by
          rw [Finset.card_erase_of_mem (Finset.mem_univ i)]; simp
        have hk1 : 1 ≤ k := Fin.pos i
        rw [h1]; push_cast [Nat.cast_sub hk1]; ring
      rw [hcard] at hsum
      rw [hdiag]
      linarith
    have hall := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hrow i)
    rw [Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul, Finset.card_univ,
      Fintype.card_fin] at hall
    have hfin : ∑ i, a i * N = N * ∑ i, a i := by
      rw [Finset.mul_sum]; exact Finset.sum_congr rfl (fun i _ => by ring)
    rw [hfin] at hall
    nlinarith [hall]
  have hCS : (∑ x, (n x : ℝ)) ^ 2 ≤ (Fintype.card Ω : ℝ) * ∑ x, (n x : ℝ) ^ 2 := by
    have := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset Ω)) (f := fun x => (n x : ℝ))
    simpa [Finset.card_univ] using this
  rw [hT, ← hNdef] at hCS
  have h1 : (N * ∑ i, a i) ^ 2 ≤ N * (N * (∑ i, a i) + (k : ℝ) * ((k : ℝ) - 1) * beta * N) :=
    le_trans hCS (by nlinarith [hQ, hNpos])
  have hN2 : (0 : ℝ) < N ^ 2 := by positivity
  have h2 : N ^ 2 * (∑ i, a i) ^ 2
      ≤ N ^ 2 * ((∑ i, a i) + (k : ℝ) * ((k : ℝ) - 1) * beta) := by nlinarith [h1]
  exact le_of_mul_le_mul_left h2 hN2

/-! ### 3. Mean form, and the basic sanity facts -/

/-- Mean agreement of a shared model with a family of fine-tunes. -/
noncomputable def meanAgree (H : Ω → Y) (A : Fin k → (Ω → Y)) : ℝ :=
  (∑ i, agreeFrac H (A i)) / (k : ℝ)

omit [DecidableEq Ω] in
lemma meanAgree_nonneg (H : Ω → Y) (A : Fin k → (Ω → Y)) : 0 ≤ meanAgree H A := by
  unfold meanAgree
  have : 0 ≤ ∑ i, agreeFrac H (A i) :=
    Finset.sum_nonneg (fun i _ => agreeFrac_nonneg H (A i))
  positivity

omit [DecidableEq Ω] in
/-- The pairwise budget of a family of at least two fine-tunes is nonnegative. -/
lemma beta_nonneg_of_pair (hk : 2 ≤ k) (A : Fin k → (Ω → Y)) (beta : ℝ)
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta) : 0 ≤ beta := by
  have h0 : (0 : ℕ) < k := lt_of_lt_of_le (by norm_num) hk
  have h1 : (1 : ℕ) < k := lt_of_lt_of_le (by norm_num) hk
  have hne : (⟨0, h0⟩ : Fin k) ≠ ⟨1, h1⟩ := by
    simp [Fin.ext_iff]
  exact le_trans (agreeFrac_nonneg _ _) (hpair _ _ hne)

/-- **Mean form of the multiplicity bound**: `k M² ≤ M + (k−1)β`. -/
theorem sharing_mean_quadratic (hN : 0 < Fintype.card Ω) (hk : 2 ≤ k)
    (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ)
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta) :
    (k : ℝ) * (meanAgree H A) ^ 2 ≤ meanAgree H A + ((k : ℝ) - 1) * beta := by
  have h := sum_agree_sq_bound hN H A beta hpair
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  set s : ℝ := ∑ i, agreeFrac H (A i) with hs
  have hid : (k : ℝ) * (s / (k : ℝ)) ^ 2 - (s / (k : ℝ) + ((k : ℝ) - 1) * beta)
      = (s ^ 2 - s - (k : ℝ) * ((k : ℝ) - 1) * beta) / (k : ℝ) := by
    field_simp; ring
  have hnum : (s ^ 2 - s - (k : ℝ) * ((k : ℝ) - 1) * beta) / (k : ℝ) ≤ 0 :=
    div_nonpos_of_nonpos_of_nonneg (by linarith) (le_of_lt hkpos)
  unfold meanAgree
  rw [← hs]
  linarith [hid ▸ hnum]

/-! ### 4. Strict decay above the threshold `k(1 − β) = 2` -/

/-- **Above the threshold the pairwise ceiling is unreachable.**  If the number of
served fine-tunes exceeds `2/(1 − β)`, then *no* shared model attains mean agreement
`(1 + β)/2`: the value drops strictly below the `SharedTailServingCeiling` bound.
This is the `k ≥ 3` answer to the open conjecture — the ceiling does decay, and the
decay starts exactly at `k(1 − β) = 2`. -/
theorem sharing_strict_decay (hN : 0 < Fintype.card Ω) (hk : 2 ≤ k)
    (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ)
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta)
    (hthr : 2 < (k : ℝ) * (1 - beta)) :
    meanAgree H A < (1 + beta) / 2 := by
  have hb0 : 0 ≤ beta := beta_nonneg_of_pair hk A beta hpair
  have hq := sharing_mean_quadratic hN hk H A beta hpair
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  set M : ℝ := meanAgree H A with hM
  by_contra hcon
  push_neg at hcon
  have hb1 : beta < 1 := by nlinarith
  set c : ℝ := (1 + beta) / 2 with hc
  have hMc : c ≤ M := hcon
  have hnn : (0 : ℝ) ≤ (k : ℝ) * (M + c) - 1 := by nlinarith
  have hmono : (k : ℝ) * c ^ 2 - c ≤ (k : ℝ) * M ^ 2 - M := by
    nlinarith [mul_nonneg (sub_nonneg.2 hMc) hnn]
  have hid : (k : ℝ) * c ^ 2 - c - ((k : ℝ) - 1) * beta
      = (1 - beta) / 4 * ((k : ℝ) * (1 - beta) - 2) := by
    rw [hc]; ring
  have hpos : ((k : ℝ) - 1) * beta < (k : ℝ) * c ^ 2 - c := by nlinarith [hid]
  linarith

/-- **Serving capacity.**  Contrapositive reading: a family that *is* served at the
pairwise ceiling can contain at most `2/(1 − β)` fine-tunes. -/
theorem sharing_capacity_bound (hN : 0 < Fintype.card Ω) (hk : 2 ≤ k)
    (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ)
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta)
    (hceil : (1 + beta) / 2 ≤ meanAgree H A) :
    (k : ℝ) * (1 - beta) ≤ 2 := by
  by_contra hcon
  push_neg at hcon
  exact absurd hceil (not_le.2 (sharing_strict_decay hN hk H A beta hpair hcon))

/-! ### 5. Attainment at the threshold: the hub family -/

/-- **The threshold is sharp.**  For every `k ≥ 2` there are `k` fine-tunes on a
`k`-position index set whose pairwise agreement is exactly `β = 1 − 2/k` — so that
`k(1 − β) = 2`, precisely the threshold of `sharing_strict_decay` — together with a
shared model (the "hub": the common consensus prediction) whose agreement with *every*
one of them equals the ceiling `(1 + β)/2` exactly.

Hence for `k(1 − β) ≤ 2` the ceiling of `SharedTailServingCeiling.sharing_ceiling_mean`
is attained for every `k`, not just for `k = 2`, and even in the strong *pointwise*
sense (every individual agreement, not merely the mean, sits at the ceiling). -/
theorem hub_attains_sharing_ceiling (hk : 2 ≤ k) :
    ∃ (A : Fin k → (Fin k → Fin 2)) (H : Fin k → Fin 2),
      (∀ i j, i ≠ j → agreeFrac (A i) (A j) = 1 - 2 / (k : ℝ)) ∧
      (∀ i, agreeFrac H (A i) = (1 + (1 - 2 / (k : ℝ))) / 2) := by
  classical
  have hkR : (0 : ℝ) < (k : ℝ) := by
    have : 0 < k := lt_of_lt_of_le (by norm_num) hk
    exact_mod_cast this
  refine ⟨fun i => fun x => if x = i then 1 else 0, fun _ => 0, ?_, ?_⟩
  · intro i j hij
    have hset : agreeSet (fun x => if x = i then (1 : Fin 2) else 0)
        (fun x => if x = j then (1 : Fin 2) else 0) = (Finset.univ.erase i).erase j := by
      ext x
      by_cases hxi : x = i <;> by_cases hxj : x = j <;>
        simp [agreeSet, Finset.mem_erase, hxi, hxj, hij, Ne.symm hij]
    have hjmem : j ∈ Finset.univ.erase i := Finset.mem_erase.2 ⟨Ne.symm hij, Finset.mem_univ j⟩
    have hcard : ((Finset.univ.erase i).erase j).card = k - 2 := by
      rw [Finset.card_erase_of_mem hjmem, Finset.card_erase_of_mem (Finset.mem_univ i)]
      simp; omega
    have hcastc : (((k - 2 : ℕ)) : ℝ) = (k : ℝ) - 2 := by
      push_cast [Nat.cast_sub hk]; ring
    simp only [agreeFrac, hset, hcard, Fintype.card_fin, hcastc]
    field_simp
  · intro i
    have hset : agreeSet (fun _ : Fin k => (0 : Fin 2))
        (fun x => if x = i then (1 : Fin 2) else 0) = Finset.univ.erase i := by
      ext x
      by_cases hxi : x = i <;> simp [agreeSet, Finset.mem_erase, hxi]
    have hcard : (Finset.univ.erase i).card = k - 1 := by
      rw [Finset.card_erase_of_mem (Finset.mem_univ i)]; simp
    have hk1 : 1 ≤ k := le_trans (by norm_num) hk
    have hcastc : (((k - 1 : ℕ)) : ℝ) = (k : ℝ) - 1 := by
      push_cast [Nat.cast_sub hk1]; ring
    simp only [agreeFrac, hset, hcard, Fintype.card_fin, hcastc]
    field_simp
    ring

/-- **The multiplicity bound itself is tight.**  The hub family of
`hub_attains_sharing_ceiling` turns the inequality `k M² ≤ M + (k−1)β` of
`sharing_mean_quadratic` into an *equality*.  So the quadratic bound — and with it the
threshold `k(1 − β) = 2` — cannot be improved for any `k`. -/
theorem hub_saturates_multiplicity_bound (hk : 2 ≤ k) :
    ∃ (A : Fin k → (Fin k → Fin 2)) (H : Fin k → Fin 2) (beta : ℝ),
      beta = 1 - 2 / (k : ℝ) ∧
      (∀ i j, i ≠ j → agreeFrac (A i) (A j) = beta) ∧
      meanAgree H A = (1 + beta) / 2 ∧
      (k : ℝ) * (meanAgree H A) ^ 2 = meanAgree H A + ((k : ℝ) - 1) * beta := by
  obtain ⟨A, H, hp, hh⟩ := hub_attains_sharing_ceiling (k := k) hk
  have hkR : (0 : ℝ) < (k : ℝ) := by
    have : 0 < k := lt_of_lt_of_le (by norm_num) hk
    exact_mod_cast this
  have hmean : meanAgree H A = (1 + (1 - 2 / (k : ℝ))) / 2 := by
    unfold meanAgree
    rw [Finset.sum_congr rfl (fun i _ => hh i), Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
    field_simp
  refine ⟨A, H, 1 - 2 / (k : ℝ), rfl, hp, hmean, ?_⟩
  rw [hmean]
  field_simp
  ring

/-! ### 6. Asymptotics: the geometric mean takes over -/

/-- **`M ≤ √β + 1/k`** (in cleared form `k M ≤ k √β + 1`).  Serving many fine-tunes
from one shared model is governed by `√β`, the *geometric* mean of the pairwise
budget. -/
theorem sharing_mean_le_sqrt (hN : 0 < Fintype.card Ω) (hk : 2 ≤ k)
    (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ)
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta) :
    (k : ℝ) * meanAgree H A ≤ (k : ℝ) * Real.sqrt beta + 1 := by
  have hb0 : 0 ≤ beta := beta_nonneg_of_pair hk A beta hpair
  have hq := sharing_mean_quadratic hN hk H A beta hpair
  have hM0 : 0 ≤ meanAgree H A := meanAgree_nonneg H A
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  set M : ℝ := meanAgree H A with hM
  have hs0 : 0 ≤ Real.sqrt beta := Real.sqrt_nonneg beta
  have hs2 : (Real.sqrt beta) ^ 2 = beta := Real.sq_sqrt hb0
  rcases eq_or_lt_of_le hb0 with hb | hb
  · have hsz : Real.sqrt beta = 0 := by rw [← hb]; simp
    rw [hsz]
    rw [← hb] at hq
    rcases eq_or_lt_of_le hM0 with hMz | hMz
    · rw [← hMz]; norm_num
    · nlinarith
  · by_contra hcon
    push_neg at hcon
    have h1 : (1 : ℝ) ≤ (k : ℝ) * (M - Real.sqrt beta) := by nlinarith
    have h2 : (0 : ℝ) ≤ M + Real.sqrt beta := by linarith
    nlinarith [mul_le_mul_of_nonneg_right h1 h2, hs2]

/-- AM–GM: the asymptotic value `√β` is strictly below the pairwise ceiling `(1+β)/2`
whenever the fine-tunes are genuinely distinct (`β < 1`). -/
theorem sqrt_lt_ceiling {beta : ℝ} (hb0 : 0 ≤ beta) (hb1 : beta < 1) :
    Real.sqrt beta < (1 + beta) / 2 := by
  have hs0 : 0 ≤ Real.sqrt beta := Real.sqrt_nonneg beta
  have hs2 : (Real.sqrt beta) ^ 2 = beta := Real.sq_sqrt hb0
  have hs1 : Real.sqrt beta < 1 := by nlinarith
  nlinarith [mul_pos (sub_pos.2 hs1) (sub_pos.2 hs1)]

/-! ### 7. The NET-54 numbers -/

section NET54

/-- **At the measured NET-54 baseline, one shared model serves at most 11 fine-tunes
at the ceiling.**  With cross-parent agreement `β = 0.8327`, `2/(1 − β) = 11.95…`, so a
family served at the pairwise ceiling `(1 + β)/2 = 0.91635` can contain at most `11`
fine-tunes. -/
theorem net54_sharing_capacity_le_eleven (hN : 0 < Fintype.card Ω) (hk : 2 ≤ k)
    (H : Ω → Y) (A : Fin k → (Ω → Y))
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ 0.8327)
    (hceil : (0.91635 : ℝ) ≤ meanAgree H A) :
    k ≤ 11 := by
  have hc : (1 + (0.8327 : ℝ)) / 2 ≤ meanAgree H A := by norm_num; linarith
  have h := sharing_capacity_bound hN hk H A 0.8327 hpair hc
  have hlt : (k : ℝ) < 12 := by linarith
  have hk12 : k < 12 := by exact_mod_cast hlt
  omega

/-- **Twelve fine-tunes already break the ceiling.**  At `β = 0.8327` one has
`12 (1 − β) = 2.0076 > 2`, so any shared model serving twelve such fine-tunes has mean
agreement strictly below `0.91635`.  The sharing budget of NET-54 is therefore not only
bounded per pair, it is exhausted by roughly a dozen fine-tunes. -/
theorem net54_twelve_finetunes_below_ceiling (hN : 0 < Fintype.card Ω)
    (H : Ω → Y) (A : Fin 12 → (Ω → Y))
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ 0.8327) :
    meanAgree H A < 0.91635 := by
  have h := sharing_strict_decay hN (by norm_num) H A 0.8327 hpair (by norm_num)
  norm_num at h ⊢
  linarith

/-- A quantitative instance of the decay: with a hundred fine-tunes at the measured
baseline, the mean agreement of any shared model is at most `0.913`, a drop of more
than three tenths of a percentage point below the pairwise ceiling. -/
theorem net54_hundred_finetunes_bound (hN : 0 < Fintype.card Ω)
    (H : Ω → Y) (A : Fin 100 → (Ω → Y))
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ 0.8327) :
    meanAgree H A ≤ 0.913 := by
  have h := sharing_mean_quadratic hN (by norm_num) H A 0.8327 hpair
  have hM0 : 0 ≤ meanAgree H A := meanAgree_nonneg H A
  norm_num at h
  nlinarith [h, hM0]

end NET54

end Catalog.Probability.MultiFineTuneSharingPhase