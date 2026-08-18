/-
# The price of universality, IX: rigidity of the maximal price

`shtarkov_disjointSupports` showed that `m` perfectly distinguishable sources
cost exactly `log₂ m` bits of universality — the cost of naming the source.
Here we prove the **converse**, and hence a rigidity theorem:

  `S(P) = m`  ⟺  the `m` sources have pairwise disjoint supports,

and, in strict form, **every genuinely overlapping class is strictly cheaper**
than naming its members:

  `¬ DisjointSupports P  →  S(P) < m`  and  `log₂ S(P) < log₂ m`.

So the naive "one code per model, plus a label" scheme is optimal *only* in the
degenerate case where the models never produce the same data; as soon as two
sources share a possible message the universal code strictly beats the labelling
scheme.  This is the precise sense in which the price of universality is a
measure of *statistical distinguishability*, not of class cardinality.
-/
import Novelty.UniversalRedundancyShtarkov

namespace PriceOfUniversality

open Finset Real

variable {A : Type*} [Fintype A] [Nonempty A]
variable {Θ : Type*} [Fintype Θ] [Nonempty Θ]

omit [Nonempty A] in
/-- The maximum likelihood at a message never exceeds the total mass the class
puts on that message. -/
theorem maxLik_le_sum (p : Θ → A → ℝ) (hp : ∀ θ, IsPMF (p θ)) (a : A) :
    maxLik p a ≤ ∑ θ, p θ a := by
  obtain ⟨θ₀, hθ₀⟩ := exists_eq_maxLik p a
  rw [hθ₀]
  exact Finset.single_le_sum (f := fun θ => p θ a) (fun θ _ => (hp θ).nonneg a) (mem_univ θ₀)

omit [Nonempty A] in
/-- **The counting bound**: the Shtarkov sum of a class of `m` sources is at most
`m`, so the price of universality never exceeds the cost of naming the source. -/
theorem shtarkov_le_card {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) :
    shtarkov p ≤ Fintype.card Θ := by
  calc shtarkov p ≤ ∑ a, ∑ θ, p θ a :=
        Finset.sum_le_sum fun a _ => maxLik_le_sum p hp a
    _ = ∑ _θ : Θ, (1:ℝ) := by
        rw [Finset.sum_comm]
        exact Finset.sum_congr rfl fun θ _ => (hp θ).total
    _ = Fintype.card Θ := by
        rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ, mul_one]

omit [Nonempty A] in
/-- If at a message the maximum likelihood already accounts for the whole mass of
the class, then only one source can give that message positive probability. -/
theorem unique_positive_of_maxLik_eq_sum {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) (a : A)
    (h : maxLik p a = ∑ θ, p θ a) :
    ∀ θ θ' : Θ, θ ≠ θ' → 0 < p θ a → p θ' a = 0 := by
  classical
  obtain ⟨θ₀, hθ₀⟩ := exists_eq_maxLik p a
  have hsplit : ∑ ψ, p ψ a = p θ₀ a + ∑ ψ ∈ univ.erase θ₀, p ψ a :=
    (Finset.add_sum_erase univ (fun ψ => p ψ a) (mem_univ θ₀)).symm
  have hzero : ∑ ψ ∈ univ.erase θ₀, p ψ a = 0 := by
    rw [hθ₀] at h; rw [hsplit] at h; linarith
  have hall : ∀ ψ : Θ, ψ ≠ θ₀ → p ψ a = 0 := by
    intro ψ hψ
    have hmem : ψ ∈ univ.erase θ₀ := Finset.mem_erase.2 ⟨hψ, mem_univ ψ⟩
    exact (Finset.sum_eq_zero_iff_of_nonneg
      (fun x _ => (hp x).nonneg a)).1 hzero ψ hmem
  intro θ θ' hne hposθ
  have hθeq : θ = θ₀ := by
    by_contra hc
    exact absurd (hall θ hc) (ne_of_gt hposθ)
  exact hall θ' (by rw [hθeq] at hne; exact fun hcon => hne (hcon ▸ rfl))

omit [Nonempty A] in
/-- **Rigidity, hard direction**: only perfectly distinguishable classes pay the
maximal price `log₂ m`. -/
theorem disjointSupports_of_shtarkov_eq_card {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ))
    (h : shtarkov p = Fintype.card Θ) : DisjointSupports p := by
  have hle : ∀ a ∈ (univ : Finset A), maxLik p a ≤ ∑ θ, p θ a :=
    fun a _ => maxLik_le_sum p hp a
  have htot : ∑ a, maxLik p a = ∑ a, ∑ θ, p θ a := by
    have hsum : ∑ a, ∑ θ, p θ a = (Fintype.card Θ : ℝ) := by
      calc ∑ a, ∑ θ, p θ a = ∑ _θ : Θ, (1:ℝ) := by
            rw [Finset.sum_comm]
            exact Finset.sum_congr rfl fun θ _ => (hp θ).total
        _ = Fintype.card Θ := by
            rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ, mul_one]
    rw [hsum, ← h, shtarkov]
  have hpt : ∀ a ∈ (univ : Finset A), maxLik p a = ∑ θ, p θ a :=
    (Finset.sum_eq_sum_iff_of_le hle).1 htot
  intro θ θ' a hne hpos
  exact unique_positive_of_maxLik_eq_sum hp a (hpt a (mem_univ a)) θ θ' hne hpos

omit [Nonempty A] in
/-- **Rigidity of the maximal price of universality.** A class of `m` sources has
Shtarkov sum exactly `m` if and only if its members are perfectly
distinguishable. -/
theorem shtarkov_eq_card_iff {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) :
    shtarkov p = Fintype.card Θ ↔ DisjointSupports p :=
  ⟨disjointSupports_of_shtarkov_eq_card hp, shtarkov_disjointSupports hp⟩

omit [Nonempty A] in
/-- **Overlapping classes are strictly cheaper.** -/
theorem shtarkov_lt_card_of_not_disjoint {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ))
    (hnd : ¬ DisjointSupports p) : shtarkov p < Fintype.card Θ :=
  lt_of_le_of_ne (shtarkov_le_card hp) fun h => hnd ((shtarkov_eq_card_iff hp).1 h)

omit [Nonempty A] in
/-- The logarithmic form: if two sources of the class can produce the same
message, the exact minimax regret is strictly below `log₂ m`, so the
"label + specialised code" scheme is strictly suboptimal. -/
theorem logb_shtarkov_lt_logb_card_of_not_disjoint {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ))
    (hnd : ¬ DisjointSupports p) :
    logb 2 (shtarkov p) < logb 2 (Fintype.card Θ) :=
  Real.logb_lt_logb (by norm_num) (shtarkov_pos hp) (shtarkov_lt_card_of_not_disjoint hp hnd)

end PriceOfUniversality