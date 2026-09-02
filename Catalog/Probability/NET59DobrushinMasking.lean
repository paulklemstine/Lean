import Probability.NET59HybridEpistasis

/-!
# NET-59, round 2: why solo profiles are flat — downstream contraction

`Probability.NET59NonIdentifiability` shows that a flat solo profile is
*compatible* with anything.  This file explains why a flat solo profile is what
one should have **expected**, and makes the explanation quantitative.

The mechanism is Dobrushin contraction.  For a channel `K` put

  `δ(K) = max_{a,b} tv (K a) (K b)`,

the *Dobrushin coefficient*; we work with any upper bound `δ` for it, so no
`sup` has to be constructed.  The classical contraction theorem
`tv_push_le_dobrushin` says `tv (K∗μ) (K∗ν) ≤ δ · tv μ ν`; it is proved here
from scratch by the Hahn (positive/negative part) decomposition.

Consequences for the NET-59 measurement:

* `tv_chain_le_dobrushin_pow` — a stack of `m` layers with coefficient `≤ δ`
  contracts by `δ^m`.
* `solo_le_pow_point` — the **masking theorem**: the solo cost of layer `j` is at
  most `δ^(number of layers after j)` times its point cost.  Damage done deep in
  the stack is exponentially invisible to a solo ablation.
* `contraction_masks_maximal_damage` — with `δ = 1/2`, a layer sitting `11` or
  more layers before the output can destroy its own output law *completely*
  (point cost `1`) and still register a solo cost below `0.0005`, i.e. an order
  of magnitude below the entire `0.006` spread reported in NET-59.  A flat solo
  profile at depth `24` is therefore evidence about the contraction of the
  stack, not about the importance of its layers.
* `solo_last_eq_point` — the one exception: for the **final** layer, solo cost
  and point cost coincide exactly, with no inequality lost.  The NET-59
  measurement is fully informative exactly at the output end of the stack, which
  is precisely where it reported the smallest damage (`L23`).  So the tail's
  own perturbation really is small, and its established specialness must live in
  its interaction with upstream layers.
-/

namespace Catalog.Probability.NET59

open Finset

variable {α β : Type*} [Fintype α] [Fintype β]

/-! ## 1. Nonemptiness of the state space -/

theorem nonempty_of_dist (μ : Dist α) : Nonempty α := by
  by_contra h
  rw [not_nonempty_iff] at h
  have : (0 : ℚ) = 1 := by simpa using μ.sum_one.symm
  norm_num at this

/-! ## 2. Dobrushin contraction -/

/-- **Dobrushin's contraction theorem** (finite, rational form).  If any two rows
of the channel `K` are within `δ` in total variation, then `K` contracts total
variation by the factor `δ`. -/
theorem tv_push_le_dobrushin {δ : ℚ} (K : Kern α β) (μ ν : Dist α)
    (h : ∀ a b, tv (K a) (K b) ≤ δ) : tv (push K μ) (push K ν) ≤ δ * tv μ ν := by
  classical
  obtain ⟨a₀⟩ := nonempty_of_dist μ
  have hδ : 0 ≤ δ := le_trans (le_of_eq (tv_self (K a₀)).symm) (h a₀ a₀)
  set P : α → ℚ := fun a => max (μ.p a - ν.p a) 0 with hP
  set N : α → ℚ := fun a => max (ν.p a - μ.p a) 0 with hN
  have hPnn : ∀ a, 0 ≤ P a := fun a => le_max_right _ _
  have hNnn : ∀ a, 0 ≤ N a := fun a => le_max_right _ _
  have hdiff : ∀ a, P a - N a = μ.p a - ν.p a := by
    intro a
    simp only [hP, hN]
    rcases le_total (μ.p a) (ν.p a) with hle | hle
    · rw [max_eq_right (by linarith : μ.p a - ν.p a ≤ 0),
        max_eq_left (by linarith : (0 : ℚ) ≤ ν.p a - μ.p a)]
      ring
    · rw [max_eq_left (by linarith : (0 : ℚ) ≤ μ.p a - ν.p a),
        max_eq_right (by linarith : ν.p a - μ.p a ≤ 0)]
      ring
  have habs : ∀ a, P a + N a = |μ.p a - ν.p a| := by
    intro a
    simp only [hP, hN]
    rcases le_total (μ.p a) (ν.p a) with hle | hle
    · rw [abs_of_nonpos (by linarith : μ.p a - ν.p a ≤ 0),
        max_eq_right (by linarith : μ.p a - ν.p a ≤ 0),
        max_eq_left (by linarith : (0 : ℚ) ≤ ν.p a - μ.p a)]
      ring
    · rw [abs_of_nonneg (by linarith : (0 : ℚ) ≤ μ.p a - ν.p a),
        max_eq_left (by linarith : (0 : ℚ) ≤ μ.p a - ν.p a),
        max_eq_right (by linarith : ν.p a - μ.p a ≤ 0)]
      ring
  set m : ℚ := tv μ ν with hm
  have hmnn : (0 : ℚ) ≤ m := tv_nonneg _ _
  have hsum_diff : ∑ a, P a - ∑ a, N a = 0 := by
    rw [← Finset.sum_sub_distrib]
    have h' : ∑ a, (P a - N a) = ∑ a, (μ.p a - ν.p a) :=
      Finset.sum_congr rfl fun a _ => hdiff a
    rw [h', Finset.sum_sub_distrib, μ.sum_one, ν.sum_one, sub_self]
  have hsum_abs : ∑ a, P a + ∑ a, N a = 2 * m := by
    rw [← Finset.sum_add_distrib]
    have h' : ∑ a, (P a + N a) = ∑ a, |μ.p a - ν.p a| :=
      Finset.sum_congr rfl fun a _ => habs a
    rw [h', hm]
    unfold tv
    ring
  have hPsum : ∑ a, P a = m := by linarith
  have hNsum : ∑ a, N a = m := by linarith
  -- the Hahn-decomposition identity
  have key : ∀ y : β, m * ((push K μ).p y - (push K ν).p y)
      = ∑ a, ∑ b, P a * N b * ((K a).p y - (K b).p y) := by
    intro y
    have inner : ∀ a : α, ∑ b, P a * N b * ((K a).p y - (K b).p y)
        = P a * (K a).p y * m - P a * ∑ b, N b * (K b).p y := by
      intro a
      calc ∑ b, P a * N b * ((K a).p y - (K b).p y)
          = ∑ b, (P a * (K a).p y * N b - P a * (N b * (K b).p y)) :=
            Finset.sum_congr rfl fun b _ => by ring
        _ = (∑ b, P a * (K a).p y * N b) - ∑ b, P a * (N b * (K b).p y) :=
            Finset.sum_sub_distrib _ _
        _ = P a * (K a).p y * m - P a * ∑ b, N b * (K b).p y := by
            rw [← Finset.mul_sum, hNsum, ← Finset.mul_sum]
    have outer : ∑ a, ∑ b, P a * N b * ((K a).p y - (K b).p y)
        = m * (∑ a, P a * (K a).p y) - m * ∑ b, N b * (K b).p y := by
      calc ∑ a, ∑ b, P a * N b * ((K a).p y - (K b).p y)
          = ∑ a, (P a * (K a).p y * m - P a * ∑ b, N b * (K b).p y) :=
            Finset.sum_congr rfl fun a _ => inner a
        _ = (∑ a, P a * (K a).p y * m) - ∑ a, P a * ∑ b, N b * (K b).p y :=
            Finset.sum_sub_distrib _ _
        _ = (∑ a, P a * (K a).p y) * m - (∑ a, P a) * ∑ b, N b * (K b).p y := by
            rw [← Finset.sum_mul, ← Finset.sum_mul]
        _ = m * (∑ a, P a * (K a).p y) - m * ∑ b, N b * (K b).p y := by
            rw [hPsum]; ring
    rw [outer]
    have hsplit : (push K μ).p y - (push K ν).p y
        = (∑ a, P a * (K a).p y) - ∑ a, N a * (K a).p y := by
      simp only [push_apply]
      rw [← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun a _ => ?_
      rw [← sub_mul, ← sub_mul, hdiff a]
    rw [hsplit]
    ring
  have step : m * (2 * tv (push K μ) (push K ν)) ≤ 2 * δ * m ^ 2 := by
    have h1 : m * (2 * tv (push K μ) (push K ν))
        = ∑ y, |m * ((push K μ).p y - (push K ν).p y)| := by
      have h' : ∑ y, |m * ((push K μ).p y - (push K ν).p y)|
          = ∑ y, m * |(push K μ).p y - (push K ν).p y| :=
        Finset.sum_congr rfl fun y _ => by rw [abs_mul, abs_of_nonneg hmnn]
      rw [h', ← Finset.mul_sum]
      unfold tv
      ring
    have h2 : ∀ y : β, |m * ((push K μ).p y - (push K ν).p y)|
        ≤ ∑ a, ∑ b, P a * N b * |(K a).p y - (K b).p y| := by
      intro y
      rw [key y]
      refine (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun a _ => ?_)
      refine (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun b _ => ?_)
      rw [abs_mul, abs_of_nonneg (mul_nonneg (hPnn a) (hNnn b))]
    have h3 : ∑ y, ∑ a, ∑ b, P a * N b * |(K a).p y - (K b).p y|
        = ∑ a, ∑ b, P a * N b * (2 * tv (K a) (K b)) := by
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl fun a _ => ?_
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl fun b _ => ?_
      rw [← Finset.mul_sum]
      congr 1
      unfold tv
      ring
    have h4 : ∑ a, ∑ b, P a * N b * (2 * tv (K a) (K b)) ≤ 2 * δ * m ^ 2 := by
      have hle : ∑ a, ∑ b, P a * N b * (2 * tv (K a) (K b))
          ≤ ∑ a, ∑ b, P a * N b * (2 * δ) :=
        Finset.sum_le_sum fun a _ => Finset.sum_le_sum fun b _ =>
          mul_le_mul_of_nonneg_left (by linarith [h a b]) (mul_nonneg (hPnn a) (hNnn b))
      refine hle.trans (le_of_eq ?_)
      calc ∑ a, ∑ b, P a * N b * (2 * δ)
          = ∑ a, P a * ((∑ b, N b) * (2 * δ)) := by
            refine Finset.sum_congr rfl fun a _ => ?_
            rw [Finset.sum_mul, Finset.mul_sum]
            exact Finset.sum_congr rfl fun b _ => by ring
        _ = (∑ a, P a) * ((∑ b, N b) * (2 * δ)) := (Finset.sum_mul _ _ _).symm
        _ = 2 * δ * m ^ 2 := by rw [hPsum, hNsum]; ring
    calc m * (2 * tv (push K μ) (push K ν))
        = ∑ y, |m * ((push K μ).p y - (push K ν).p y)| := h1
      _ ≤ ∑ y, ∑ a, ∑ b, P a * N b * |(K a).p y - (K b).p y| :=
          Finset.sum_le_sum fun y _ => h2 y
      _ = ∑ a, ∑ b, P a * N b * (2 * tv (K a) (K b)) := h3
      _ ≤ 2 * δ * m ^ 2 := h4
  rcases eq_or_lt_of_le hmnn with hm0 | hmpos
  · have hμν : μ = ν := (tv_eq_zero_iff μ ν).1 (by rw [← hm]; exact hm0.symm)
    rw [hm, hμν]
    simp
  · nlinarith [tv_nonneg (push K μ) (push K ν), step, hmpos]



/-- A stack of `m` layers, each with Dobrushin coefficient at most `δ`,
contracts total variation by `δ ^ m`. -/
theorem tv_chain_le_dobrushin_pow {δ : ℚ} (hδ : 0 ≤ δ) :
    ∀ (L : List (Kern α α)), (∀ K ∈ L, ∀ a b, tv (K a) (K b) ≤ δ) →
      ∀ μ ν : Dist α, tv (chain L μ) (chain L ν) ≤ δ ^ L.length * tv μ ν := by
  intro L
  induction L with
  | nil => intro _ μ ν; simp
  | cons K L ih =>
      intro h μ ν
      have hK : ∀ a b, tv (K a) (K b) ≤ δ := h K (by simp)
      have htail : ∀ K' ∈ L, ∀ a b, tv (K' a) (K' b) ≤ δ := fun K' hK' => h K' (by simp [hK'])
      have h1 := ih htail (push K μ) (push K ν)
      have h2 : tv (push K μ) (push K ν) ≤ δ * tv μ ν := tv_push_le_dobrushin K μ ν hK
      have h3 : δ ^ L.length * tv (push K μ) (push K ν) ≤ δ ^ L.length * (δ * tv μ ν) :=
        mul_le_mul_of_nonneg_left h2 (pow_nonneg hδ _)
      calc tv (chain (K :: L) μ) (chain (K :: L) ν)
          = tv (chain L (push K μ)) (chain L (push K ν)) := rfl
        _ ≤ δ ^ L.length * tv (push K μ) (push K ν) := h1
        _ ≤ δ ^ L.length * (δ * tv μ ν) := h3
        _ = δ ^ (K :: L).length * tv μ ν := by rw [List.length_cons]; ring

/-! ## 3. The masking theorem -/

/-- **Masking.**  The solo cost of layer `j` is at most `δ ^ (layers after j)`
times its point cost: what a layer does to its own output is attenuated
exponentially by the contraction of everything downstream.

This is the structural reason a solo ablation profile comes out flat, and it is
independent of any hypothesis about which layer matters. -/
theorem solo_le_pow_point {δ : ℚ} (hδ : 0 ≤ δ) (F : List (Kern α α)) (j : ℕ) (f p : Kern α α)
    (hj : j < F.length) (hf : F[j] = f)
    (hdown : ∀ K ∈ F.drop (j + 1), ∀ a b, tv (K a) (K b) ≤ δ) (μ : Dist α) :
    tv (chain F μ) (chain (F.set j p) μ)
      ≤ δ ^ (F.length - (j + 1))
        * tv (push f (upstream F j μ)) (push p (upstream F j μ)) := by
  have hF : F = F.take j ++ f :: F.drop (j + 1) := by
    conv_lhs => rw [← List.set_getElem_self hj]
    rw [List.set_eq_take_cons_drop _ hj, hf]
  have hFset : F.set j p = F.take j ++ p :: F.drop (j + 1) :=
    List.set_eq_take_cons_drop _ hj
  have e1 : chain F μ = chain (F.drop (j + 1)) (push f (upstream F j μ)) := by
    conv_lhs => rw [hF]
    rw [chain_append, chain_cons, upstream]
  have e2 : chain (F.set j p) μ = chain (F.drop (j + 1)) (push p (upstream F j μ)) := by
    rw [hFset, chain_append, chain_cons, upstream]
  have hlen : (F.drop (j + 1)).length = F.length - (j + 1) := by simp
  rw [e1, e2, ← hlen]
  exact tv_chain_le_dobrushin_pow hδ _ hdown _ _

/-- **Exact solo damage at the output layer.**  For the last layer of a stack the
solo cost *equals* the point cost: nothing downstream is left to mask it. -/
theorem solo_last_eq_point (F : List (Kern α α)) (f p : Kern α α)
    (hne : F ≠ []) (hf : F[F.length - 1]'(by
      cases F with
      | nil => exact absurd rfl hne
      | cons a l => simp) = f) (μ : Dist α) :
    tv (chain F μ) (chain (F.set (F.length - 1) p) μ)
      = tv (push f (upstream F (F.length - 1) μ)) (push p (upstream F (F.length - 1) μ)) := by
  have hj : F.length - 1 < F.length := by
    cases F with
    | nil => exact absurd rfl hne
    | cons a l => simp
  have hF : F = F.take (F.length - 1) ++ f :: F.drop (F.length - 1 + 1) := by
    conv_lhs => rw [← List.set_getElem_self hj]
    rw [List.set_eq_take_cons_drop _ hj, hf]
  have hFset : F.set (F.length - 1) p = F.take (F.length - 1) ++ p :: F.drop (F.length - 1 + 1) :=
    List.set_eq_take_cons_drop _ hj
  have hdrop : F.drop (F.length - 1 + 1) = [] := by
    apply List.drop_eq_nil_of_le
    omega
  have e1 : chain F μ = push f (upstream F (F.length - 1) μ) := by
    conv_lhs => rw [hF]
    rw [chain_append, chain_cons, hdrop, chain_nil, upstream]
  have e2 : chain (F.set (F.length - 1) p) μ = push p (upstream F (F.length - 1) μ) := by
    rw [hFset, chain_append, chain_cons, hdrop, chain_nil, upstream]
  rw [e1, e2]

/-! ## 4. The NET-59 numbers -/

/-- The spread of the measured NET-59 solo profile at `k = 16`: `0.6` points. -/
def net59Spread : ℚ := 6 / 1000

/-- **A totally destroyed layer is invisible.**  In a `24`-layer stack whose last
`11` layers each have Dobrushin coefficient at most `1/2`, a layer that
completely destroys its own output law (point cost `1`, the maximum possible)
registers a solo cost smaller than `1/2000` — a tenth of the entire spread
`0.006` that NET-59 was able to resolve.

Hence the observed flatness of the solo profile is exactly what a contracting
stack must produce, whatever its layers are doing. -/
theorem contraction_masks_maximal_damage (F : List (Kern α α)) (j : ℕ) (f p : Kern α α)
    (hlen : F.length = 24) (hj : j = 12) (hf : F[j]'(by omega) = f)
    (hdown : ∀ K ∈ F.drop (j + 1), ∀ a b, tv (K a) (K b) ≤ 1 / 2) (μ : Dist α) :
    tv (chain F μ) (chain (F.set j p) μ) < net59Spread / 10 := by
  have hpt : tv (push f (upstream F j μ)) (push p (upstream F j μ)) ≤ 1 :=
    tv_le_one _ _
  have hmain := solo_le_pow_point (by norm_num : (0:ℚ) ≤ 1/2) F j f p (by omega) hf hdown μ
  have hpow : ((1:ℚ)/2) ^ (F.length - (j + 1)) = (1/2) ^ 11 := by
    rw [hlen, hj]
  have hbound : ((1:ℚ)/2) ^ (F.length - (j + 1))
      * tv (push f (upstream F j μ)) (push p (upstream F j μ)) ≤ (1/2) ^ 11 := by
    rw [hpow]
    calc ((1:ℚ)/2) ^ 11 * tv (push f (upstream F j μ)) (push p (upstream F j μ))
        ≤ (1/2) ^ 11 * 1 := by
          exact mul_le_mul_of_nonneg_left hpt (by positivity)
      _ = (1/2) ^ 11 := by ring
  have : ((1:ℚ)/2) ^ 11 < net59Spread / 10 := by norm_num [net59Spread]
  linarith

end Catalog.Probability.NET59