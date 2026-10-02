import Mathlib
import Tropical.CompositeDialLegendre

/-!
# The composite label is saturated: emergent information meets the capacity bound

Companion to `Tropical.CompositeDialEmergence` and `Tropical.CompositeDialLegendre`
(COMPOSITE-DIAL, FACT round-35 #4, paper 125).

We prove the **label-capacity bound** for the finite-alphabet mutual information
`OrbitDialCap.Info.mutualInfo`: for every normalised nonnegative joint table on `α × β`,

`I(X; Y) ≤ log |β|`.

The proof goes through the label entropy `H(Y)`: each term satisfies
`p log (p / (pₓ p_y)) ≤ p log (1 / p_y)` because `p ≤ pₓ`, and then `H(Y) ≤ log |β|` follows
from `log t ≤ t - 1` (Gibbs' inequality, proved here from scratch).

## Consequences

* `info_le_log_card` — the bound for observables.
* `synergy_le_log_card` / `synergy_saturated` — for `k ≥ 2` uniform components with
  the sum label, the synergy `I(whole) - ∑ I(partᵢ)` is not merely positive but *maximal*:
  no observable can carry more than `log |A|` about the label, and the whole attains it.
* `four_types_of_read` — a read of `1.8170` bits forces a label alphabet of size `≥ 4`.
* `jacobi_label_capacity` — at the semiprime level no statistic of a unit whatsoever
  carries more than one bit about its Jacobi label, and the full residue vector attains
  this bound while every prime component carries zero: the emergence is extremal.
-/

namespace CompositeDial

open Finset OrbitDialCap.Info

section Capacity

variable {α β : Type*} [Fintype α] [Fintype β]

/-- The entropy of the label marginal. -/
noncomputable def labelEntropy (p : α → β → ℝ) : ℝ :=
  ∑ b, - marginalY p b * Real.log (marginalY p b)

/-- Gibbs' inequality in the uniform form: a probability vector on `β` has entropy at most
`log |β|`. -/
theorem entropy_le_log_card (q : β → ℝ) (hq : ∀ b, 0 ≤ q b) (hsum : ∑ b, q b = 1) :
    ∑ b, - q b * Real.log (q b) ≤ Real.log (Fintype.card β) := by
  classical
  have hne : Nonempty β := by
    by_contra h
    rw [not_nonempty_iff] at h
    simp at hsum
  set n : ℝ := (Fintype.card β : ℝ) with hn
  have hnpos : 0 < n := by rw [hn]; exact_mod_cast Fintype.card_pos
  have hterm : ∀ b, - q b * Real.log (q b) - q b * Real.log n ≤ 1 / n - q b := by
    intro b
    rcases (hq b).eq_or_lt with h | h
    · rw [← h]; simp; positivity
    · have hpos : 0 < 1 / (n * q b) := by positivity
      have hlog := Real.log_le_sub_one_of_pos hpos
      have heq : - q b * Real.log (q b) - q b * Real.log n = q b * Real.log (1 / (n * q b)) := by
        rw [one_div, Real.log_inv, Real.log_mul hnpos.ne' h.ne']; ring
      rw [heq]
      calc q b * Real.log (1 / (n * q b)) ≤ q b * (1 / (n * q b) - 1) :=
            mul_le_mul_of_nonneg_left hlog h.le
        _ = 1 / n - q b := by field_simp
  have hsum' : ∑ b, (- q b * Real.log (q b) - q b * Real.log n) ≤ ∑ b, (1 / n - q b) :=
    Finset.sum_le_sum fun b _ => hterm b
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul, hsum,
    Finset.sum_const, Finset.card_univ, nsmul_eq_mul, ← hn] at hsum'
  have : n * (1 / n) = 1 := by field_simp
  linarith

/-- Pointwise comparison of a mutual-information term with a label-entropy term. -/
lemma term_le_entropy_term {p : α → β → ℝ} (hp : ∀ a b, 0 ≤ p a b) (a : α) (b : β) :
    p a b * Real.log (p a b / (marginalX p a * marginalY p b)) ≤
      p a b * (- Real.log (marginalY p b)) := by
  rcases (hp a b).eq_or_lt with h | h
  · rw [← h]; simp
  · have hx : p a b ≤ marginalX p a := le_marginalX hp a b
    have hy : p a b ≤ marginalY p b := le_marginalY hp a b
    have hxpos : 0 < marginalX p a := h.trans_le hx
    have hypos : 0 < marginalY p b := h.trans_le hy
    refine mul_le_mul_of_nonneg_left ?_ h.le
    rw [div_mul_eq_div_div, Real.log_div (by positivity) hypos.ne']
    have : Real.log (p a b / marginalX p a) ≤ 0 :=
      Real.log_nonpos (by positivity) ((div_le_one hxpos).mpr hx)
    linarith

/-- Mutual information is bounded by the label entropy. -/
theorem mutualInfo_le_labelEntropy {p : α → β → ℝ} (hp : ∀ a b, 0 ≤ p a b) :
    mutualInfo p ≤ labelEntropy p := by
  unfold mutualInfo labelEntropy
  calc ∑ a, ∑ b, p a b * Real.log (p a b / (marginalX p a * marginalY p b))
      ≤ ∑ a, ∑ b, p a b * (- Real.log (marginalY p b)) :=
        Finset.sum_le_sum fun a _ => Finset.sum_le_sum fun b _ => term_le_entropy_term hp a b
    _ = ∑ b, ∑ a, p a b * (- Real.log (marginalY p b)) := Finset.sum_comm
    _ = ∑ b, - marginalY p b * Real.log (marginalY p b) := by
        refine Finset.sum_congr rfl fun b _ => ?_
        rw [← Finset.sum_mul, marginalY]; ring

/-- **Label-capacity bound.**  `I(X; Y) ≤ log |β|` for every normalised nonnegative joint
table. -/
theorem mutualInfo_le_log_card {p : α → β → ℝ} (hp : ∀ a b, 0 ≤ p a b)
    (htot : ∑ a, ∑ b, p a b = 1) : mutualInfo p ≤ Real.log (Fintype.card β) := by
  refine (mutualInfo_le_labelEntropy hp).trans (entropy_le_log_card _ (marginalY_nonneg hp) ?_)
  rw [← htot, Finset.sum_comm]; rfl

variable {Ω : Type*} [Fintype Ω]

/-- The capacity bound for observables. -/
theorem info_le_log_card {μ : Ω → ℝ} (hμ0 : ∀ ω, 0 ≤ μ ω) (hμ : ∑ ω, μ ω = 1)
    (X : Ω → α) (Y : Ω → β) : info μ X Y ≤ Real.log (Fintype.card β) :=
  mutualInfo_le_log_card (jointLaw_nonneg hμ0 X Y) (by rw [jointLaw_total, hμ])

/-- `log 3 < 1.8170 · log 2`, i.e. `log₂ 3 < 1.8170`, from `3 ^ 5 = 243 < 256 = 2 ^ 8`
(so in fact `log₂ 3 < 1.6`). -/
lemma log_three_lt : Real.log 3 < 1.8170 * Real.log 2 := by
  have h : (3 : ℝ) ^ 5 < (2 : ℝ) ^ 8 := by norm_num
  have hl := Real.log_lt_log (by positivity) h
  rw [Real.log_pow, Real.log_pow] at hl
  push_cast at hl
  have hl2 : 0 < Real.log 2 := Real.log_pos one_lt_two
  linarith

/-- **The measured read needs at least four composite types.**  If some observable carries
at least `1.8170` bits about a label (the COMPOSITE-DIAL semiprime read), then the label
alphabet has at least four letters: three types can carry at most `log₂ 3 ≈ 1.585` bits. -/
theorem four_types_of_read {μ : Ω → ℝ} (hμ0 : ∀ ω, 0 ≤ μ ω) (hμ : ∑ ω, μ ω = 1)
    (X : Ω → α) (Y : Ω → β) (hread : 1.8170 ≤ bits (info μ X Y)) : 4 ≤ Fintype.card β := by
  by_contra hlt
  push_neg at hlt
  have hl2 : 0 < Real.log 2 := Real.log_pos one_lt_two
  have hcap := info_le_log_card hμ0 hμ X Y
  have hne : Nonempty Ω := by
    by_contra h; rw [not_nonempty_iff] at h; simp at hμ
  obtain ⟨ω⟩ := hne
  haveI : Nonempty β := ⟨Y ω⟩
  have hpos : (0 : ℝ) < Fintype.card β := by exact_mod_cast Fintype.card_pos
  have h3 : Real.log (Fintype.card β) ≤ Real.log 3 :=
    Real.log_le_log hpos (by exact_mod_cast (by omega : Fintype.card β ≤ 3))
  unfold bits at hread
  rw [le_div_iff₀ hl2] at hread
  linarith [log_three_lt]

end Capacity

section Saturation

variable {A : Type*} [AddCommGroup A] [Fintype A] {k : ℕ}

/-- **Synergy is bounded by the label capacity.**  No observable of `k` uniform components
can carry more than `log |A|` about the sum label. -/
theorem observable_le_log_card {α : Type*} [Fintype α] (X : (Fin k → A) → α) :
    info (uniformLaw A k) X (compositeLabel (A := A) (k := k)) ≤ Real.log (Fintype.card A) :=
  info_le_log_card uniformLaw_nonneg uniformLaw_total X _

/-- **Saturated emergence.**  For `k ≥ 2` and nontrivial `A`: every part carries `0`, the
whole carries `log |A|`, and `log |A|` is the maximum any observable could carry. -/
theorem synergy_saturated (hk : 2 ≤ k) :
    (∀ i : Fin k, info (uniformLaw A k) (component i) (compositeLabel (A := A)) = 0) ∧
      info (uniformLaw A k) id (compositeLabel (A := A) (k := k)) = Real.log (Fintype.card A) ∧
      ∀ {α : Type} [Fintype α] (X : (Fin k → A) → α),
        info (uniformLaw A k) X (compositeLabel (A := A) (k := k)) ≤
          info (uniformLaw A k) id (compositeLabel (A := A) (k := k)) := by
  have hw := whole_carries_log_card (A := A) (k := k) (by omega)
  refine ⟨fun i => component_blind hk i, hw, fun X => ?_⟩
  rw [hw]; exact observable_le_log_card X

end Saturation

namespace Legendre

variable {k : ℕ} (P : Fin k → ℕ) [∀ i, Fact (P i).Prime]

/-- **Jacobi-label capacity.**  For a squarefree modulus with `k ≥ 2` odd prime factors:
no statistic of a uniformly random unit carries more than one bit about its Jacobi label,
the full residue vector carries exactly one bit, and every single prime component carries
zero.  The emergence of the Jacobi label is extremal. -/
theorem jacobi_label_capacity (hodd : ∀ i, P i ≠ 2) (hk : 2 ≤ k) :
    (∀ {α : Type} [Fintype α] (X : ResidueSpace P → α),
        bits (info (residueLaw P) X (jacobiLabel P)) ≤ 1) ∧
      bits (info (residueLaw P) id (jacobiLabel P)) = 1 ∧
      ∀ i, bits (info (residueLaw P) (primeComponent P i) (jacobiLabel P)) = 0 := by
  have hl2 : 0 < Real.log 2 := Real.log_pos one_lt_two
  refine ⟨fun X => ?_, full_residue_bits P hodd (by omega), fun i => ?_⟩
  · have hle := info_le_log_card (fun _ => by unfold residueLaw; positivity)
      (residueLaw_total P) X (jacobiLabel P)
    rw [ZMod.card] at hle
    unfold bits
    rw [div_le_one hl2]
    exact_mod_cast hle
  · rw [primeComponent_blind P hodd hk i, bits, zero_div]

end Legendre

end CompositeDial