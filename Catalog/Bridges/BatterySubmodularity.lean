/-
# BATTERY-SCALING, part I: strong subadditivity of the counting entropy

Companion to `Combinatorics.TraceBatteryEntropy` (the finitary Shannon calculus of a
statistic `f : Ω → α` on a finite population) and `Combinatorics.TraceBatteryCapacity`
(the joint capacity of a battery of dials).

Those files stop at *sub*additivity, `H (f, g) ≤ H f + H g`.  The round-27 #4
battery experiment ("the capacity curve saturates at the label-entropy ceiling")
needs the genuinely stronger statement, which is the analytic engine of every
monotonicity claim about a nested battery:

  **strong subadditivity** `H (u, v, w) + H u ≤ H (u, v) + H (u, w)`.

Equivalently: conditioning on more data never increases conditional entropy.  It is
proved here from scratch by a single Gibbs inequality against the *conditional product
reference* `q(a,b,c) = n(a,b) · n(a,c) / (n(a) · N)`, which is exactly a probability
weight on the triples: `Σ q = 1`.

## Main results

* `TraceBattery.gibbs_gen` — Gibbs against an arbitrary positive reference weight.
* `TraceBattery.cnt_triple_marginal_mid` — marginalising the *middle* coordinate of a
  triple statistic.
* `TraceBattery.H_triple_eq_sum_product` — the triple entropy as a sum over the full
  product of the three value sets.
* `TraceBattery.H_strong_subadditive` — **strong subadditivity**.
* `TraceBattery.H_cond_mono` — conditioning reduces entropy, in the `H(u,w) - H u` form.
-/
import Mathlib
import Combinatorics.TraceBatteryEntropy

namespace TraceBattery

open Finset

variable {Ω : Type*} [Fintype Ω] {α β γ : Type*}

/-! ## 1. Gibbs against an arbitrary reference -/

/-- **Gibbs inequality, general reference.**  For a weight `p ≥ 0` and any positive
reference value `q`, `p log (1/p) ≤ p log (1/q) + (q - p)`.  Summing this over a
probability weight `p` and a sub-probability reference `q` is the standard
`KL ≥ 0` argument. -/
theorem gibbs_gen {p q : ℝ} (hp : 0 ≤ p) (hq : 0 < q) :
    p * Real.log (1 / p) ≤ p * Real.log (1 / q) + (q - p) := by
  rcases eq_or_lt_of_le hp with hp0 | hp0
  · rw [← hp0]; simp only [zero_mul, sub_zero, zero_add]; linarith
  have h := Real.log_le_sub_one_of_pos (show (0 : ℝ) < q / p by positivity)
  have hlog : Real.log (q / p) = Real.log (1 / p) - Real.log (1 / q) := by
    rw [Real.log_div (ne_of_gt hq) (ne_of_gt hp0), one_div, one_div, Real.log_inv,
      Real.log_inv]
    ring
  rw [hlog] at h
  have h2 := mul_le_mul_of_nonneg_left h hp
  have h3 : p * (q / p - 1) = q - p := by field_simp
  rw [h3] at h2
  nlinarith [h2]

/-! ## 2. Marginals of a triple statistic -/

/-- Marginalising the **middle** coordinate of the triple statistic
`x ↦ ((u x, v x), w x)` returns the `(u, w)` pair statistic. -/
theorem cnt_triple_marginal_mid (u : Ω → α) (v : Ω → β) (w : Ω → γ) (a : α) (c : γ) :
    ∑ b ∈ img v, cnt (fun x => ((u x, v x), w x)) ((a, b), c)
      = cnt (fun x => (u x, w x)) (a, c) := by
  classical
  have hmaps : ∀ x ∈ fib (fun x => (u x, w x)) (a, c), v x ∈ img v :=
    fun x _ => self_mem_img v x
  have h := Finset.card_eq_sum_card_fiberwise (f := v)
    (s := fib (fun x => (u x, w x)) (a, c)) (t := img v) hmaps
  rw [cnt, h]
  refine Finset.sum_congr rfl fun b _ => ?_
  rw [cnt, fib_eq_filter]
  congr 1
  ext x
  simp only [Finset.mem_filter, mem_fib, Finset.mem_univ, true_and, Prod.mk.injEq]
  tauto

/-- Marginalising the **last** coordinate returns the `(u, v)` pair statistic. -/
theorem cnt_triple_marginal_last (u : Ω → α) (v : Ω → β) (w : Ω → γ) (a : α) (b : β) :
    ∑ c ∈ img w, cnt (fun x => ((u x, v x), w x)) ((a, b), c)
      = cnt (fun x => (u x, v x)) (a, b) :=
  cnt_pair_marginal_fst (fun x => (u x, v x)) w (a, b)

/-- The triple entropy written as a sum over the full product of the three value sets. -/
theorem H_triple_eq_sum_product (u : Ω → α) (v : Ω → β) (w : Ω → γ) :
    H (fun x => ((u x, v x), w x))
      = ∑ a ∈ img u, ∑ b ∈ img v, ∑ c ∈ img w,
          phi (Fintype.card Ω) (cnt (fun x => ((u x, v x), w x)) ((a, b), c)) := by
  classical
  have hsub : img (fun x => ((u x, v x), w x)) ⊆ (img u ×ˢ img v) ×ˢ img w := by
    intro t ht
    obtain ⟨x, rfl⟩ := mem_img.1 ht
    exact Finset.mem_product.2
      ⟨Finset.mem_product.2 ⟨self_mem_img u x, self_mem_img v x⟩, self_mem_img w x⟩
  have hzero : ∀ t ∈ (img u ×ˢ img v) ×ˢ img w, t ∉ img (fun x => ((u x, v x), w x)) →
      phi (Fintype.card Ω) (cnt (fun x => ((u x, v x), w x)) t) = 0 := by
    intro t _ ht
    rw [cnt_eq_zero ht, phi_zero]
  calc H (fun x => ((u x, v x), w x))
      = ∑ t ∈ img (fun x => ((u x, v x), w x)),
          phi (Fintype.card Ω) (cnt (fun x => ((u x, v x), w x)) t) := rfl
    _ = ∑ t ∈ (img u ×ˢ img v) ×ˢ img w,
          phi (Fintype.card Ω) (cnt (fun x => ((u x, v x), w x)) t) :=
        Finset.sum_subset hsub hzero
    _ = ∑ ab ∈ img u ×ˢ img v, ∑ c ∈ img w,
          phi (Fintype.card Ω) (cnt (fun x => ((u x, v x), w x)) (ab, c)) :=
        Finset.sum_product _ _ _
    _ = ∑ a ∈ img u, ∑ b ∈ img v, ∑ c ∈ img w,
          phi (Fintype.card Ω) (cnt (fun x => ((u x, v x), w x)) ((a, b), c)) := by
        rw [Finset.sum_product]

/-! ## 3. Strong subadditivity -/

/-- **Strong subadditivity of the counting entropy.**
`H(u, v, w) + H u ≤ H(u, v) + H(u, w)`: once the common statistic `u` is known,
the extra readings `v` and `w` can only be sub-additive.  This is the analytic core of
every monotonicity statement about a nested dial battery. -/
theorem H_strong_subadditive (u : Ω → α) (v : Ω → β) (w : Ω → γ) :
    H (fun x => ((u x, v x), w x)) + H u
      ≤ H (fun x => (u x, v x)) + H (fun x => (u x, w x)) := by
  classical
  rcases isEmpty_or_nonempty Ω with hΩ | hΩ
  · simp [H, img_eq_empty_of_isEmpty]
  have hNpos : 0 < Fintype.card Ω := Fintype.card_pos
  have hNR : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hNpos
  set N : ℕ := Fintype.card Ω with hNdef
  -- the three statistics
  set T : Ω → (α × β) × γ := fun x => ((u x, v x), w x) with hT
  set Fuv : Ω → α × β := fun x => (u x, v x) with hFuv
  set Fuw : Ω → α × γ := fun x => (u x, w x) with hFuw
  -- the termwise Gibbs bound
  have hterm : ∀ a ∈ img u, ∀ b ∈ img v, ∀ c ∈ img w,
      phi N (cnt T ((a, b), c))
        ≤ (cnt T ((a, b), c) : ℝ) / N * Real.log (1 / ((cnt Fuv (a, b) : ℝ) / N))
          + (cnt T ((a, b), c) : ℝ) / N * Real.log (1 / ((cnt Fuw (a, c) : ℝ) / N))
          - (cnt T ((a, b), c) : ℝ) / N * Real.log (1 / ((cnt u a : ℝ) / N))
          + ((cnt Fuv (a, b) : ℝ) / N * ((cnt Fuw (a, c) : ℝ) / N) / ((cnt u a : ℝ) / N)
              - (cnt T ((a, b), c) : ℝ) / N) := by
    intro a _ b _ c _
    rcases Nat.eq_zero_or_pos (cnt T ((a, b), c)) with h0 | hpos
    · rw [h0]
      simp only [phi_zero, Nat.cast_zero, zero_div, zero_mul, sub_zero, zero_add, add_zero]
      positivity
    · -- the triple actually occurs, so all three marginals are positive
      obtain ⟨x, hx⟩ : ∃ x, T x = ((a, b), c) := by
        have : (fib T ((a, b), c)).Nonempty := Finset.card_pos.1 hpos
        obtain ⟨x, hx⟩ := this
        exact ⟨x, (mem_fib).1 hx⟩
      have hxu : u x = a := congrArg (fun t => t.1.1) hx
      have hxv : v x = b := congrArg (fun t => t.1.2) hx
      have hxw : w x = c := congrArg (fun t => t.2) hx
      have huv : 0 < cnt Fuv (a, b) := by
        refine cnt_pos ?_
        exact mem_img.2 ⟨x, by simp [hFuv, hxu, hxv]⟩
      have huw : 0 < cnt Fuw (a, c) := by
        refine cnt_pos ?_
        exact mem_img.2 ⟨x, by simp [hFuw, hxu, hxw]⟩
      have hu : 0 < cnt u a := cnt_pos (mem_img.2 ⟨x, hxu⟩)
      have hx1 : (0 : ℝ) < (cnt Fuv (a, b) : ℝ) / N := by
        have : (0 : ℝ) < (cnt Fuv (a, b) : ℝ) := by exact_mod_cast huv
        positivity
      have hy1 : (0 : ℝ) < (cnt Fuw (a, c) : ℝ) / N := by
        have : (0 : ℝ) < (cnt Fuw (a, c) : ℝ) := by exact_mod_cast huw
        positivity
      have hz1 : (0 : ℝ) < (cnt u a : ℝ) / N := by
        have : (0 : ℝ) < (cnt u a : ℝ) := by exact_mod_cast hu
        positivity
      set X : ℝ := (cnt Fuv (a, b) : ℝ) / N
      set Y : ℝ := (cnt Fuw (a, c) : ℝ) / N
      set Z : ℝ := (cnt u a : ℝ) / N
      have hqpos : (0 : ℝ) < X * Y / Z := by positivity
      have hlog : Real.log (1 / (X * Y / Z))
          = Real.log (1 / X) + Real.log (1 / Y) - Real.log (1 / Z) := by
        rw [one_div, one_div, one_div, one_div, Real.log_inv, Real.log_inv, Real.log_inv,
          Real.log_inv, Real.log_div (by positivity) (ne_of_gt hz1),
          Real.log_mul (ne_of_gt hx1) (ne_of_gt hy1)]
        ring
      have hg := gibbs_gen (p := (cnt T ((a, b), c) : ℝ) / N) (q := X * Y / Z)
        (by positivity) hqpos
      rw [hlog] at hg
      rw [phi_eq_plogp hNpos]
      nlinarith [hg]
  -- the four summands
  have hA : ∑ a ∈ img u, ∑ b ∈ img v, ∑ c ∈ img w,
      (cnt T ((a, b), c) : ℝ) / N * Real.log (1 / ((cnt Fuv (a, b) : ℝ) / N))
      = H Fuv := by
    rw [H_pair_eq_sum_product u v]
    refine Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b _ => ?_
    rw [← Finset.sum_mul, ← Finset.sum_div]
    have hm : ∑ c ∈ img w, (cnt T ((a, b), c) : ℝ) = (cnt Fuv (a, b) : ℝ) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (cnt_triple_marginal_last u v w a b)
    rw [hm, ← phi_eq_plogp hNpos]
  have hB : ∑ a ∈ img u, ∑ b ∈ img v, ∑ c ∈ img w,
      (cnt T ((a, b), c) : ℝ) / N * Real.log (1 / ((cnt Fuw (a, c) : ℝ) / N))
      = H Fuw := by
    rw [H_pair_eq_sum_product u w]
    refine Finset.sum_congr rfl fun a _ => ?_
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun c _ => ?_
    rw [← Finset.sum_mul, ← Finset.sum_div]
    have hm : ∑ b ∈ img v, (cnt T ((a, b), c) : ℝ) = (cnt Fuw (a, c) : ℝ) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (cnt_triple_marginal_mid u v w a c)
    rw [hm, ← phi_eq_plogp hNpos]
  have hmarg_u : ∀ a : α, ∑ b ∈ img v, ∑ c ∈ img w, (cnt T ((a, b), c) : ℝ)
      = (cnt u a : ℝ) := by
    intro a
    have h1 : ∀ b : β, ∑ c ∈ img w, (cnt T ((a, b), c) : ℝ) = (cnt Fuv (a, b) : ℝ) := by
      intro b
      exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (cnt_triple_marginal_last u v w a b)
    rw [Finset.sum_congr rfl fun b _ => h1 b]
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (cnt_pair_marginal_fst u v a)
  have hC : ∑ a ∈ img u, ∑ b ∈ img v, ∑ c ∈ img w,
      (cnt T ((a, b), c) : ℝ) / N * Real.log (1 / ((cnt u a : ℝ) / N))
      = H u := by
    rw [H_eq_sum_phi]
    refine Finset.sum_congr rfl fun a _ => ?_
    have : ∑ b ∈ img v, ∑ c ∈ img w,
        (cnt T ((a, b), c) : ℝ) / N * Real.log (1 / ((cnt u a : ℝ) / N))
        = ((∑ b ∈ img v, ∑ c ∈ img w, (cnt T ((a, b), c) : ℝ)) / N)
            * Real.log (1 / ((cnt u a : ℝ) / N)) := by
      rw [Finset.sum_div, Finset.sum_mul]
      refine Finset.sum_congr rfl fun b _ => ?_
      rw [Finset.sum_div, Finset.sum_mul]
    rw [this, hmarg_u a, ← phi_eq_plogp hNpos]
  have hD : (∑ a ∈ img u, ∑ b ∈ img v, ∑ c ∈ img w,
        (cnt Fuv (a, b) : ℝ) / N * ((cnt Fuw (a, c) : ℝ) / N) / ((cnt u a : ℝ) / N))
      - (∑ a ∈ img u, ∑ b ∈ img v, ∑ c ∈ img w, (cnt T ((a, b), c) : ℝ) / N) = 0 := by
    have hq : ∀ a ∈ img u, ∑ b ∈ img v, ∑ c ∈ img w,
        (cnt Fuv (a, b) : ℝ) / N * ((cnt Fuw (a, c) : ℝ) / N) / ((cnt u a : ℝ) / N)
        = (cnt u a : ℝ) / N := by
      intro a ha
      have hu : 0 < cnt u a := cnt_pos ha
      have huR : (0 : ℝ) < (cnt u a : ℝ) := by exact_mod_cast hu
      have hsb : ∑ b ∈ img v, (cnt Fuv (a, b) : ℝ) = (cnt u a : ℝ) := by
        exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (cnt_pair_marginal_fst u v a)
      have hsc : ∑ c ∈ img w, (cnt Fuw (a, c) : ℝ) = (cnt u a : ℝ) := by
        exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (cnt_pair_marginal_fst u w a)
      have hZ : (cnt u a : ℝ) ≠ 0 := ne_of_gt huR
      have hNne : (N : ℝ) ≠ 0 := ne_of_gt hNR
      have hstep : ∀ b : β, ∑ c ∈ img w,
          (cnt Fuv (a, b) : ℝ) / N * ((cnt Fuw (a, c) : ℝ) / N) / ((cnt u a : ℝ) / N)
          = (cnt Fuv (a, b) : ℝ) / N := by
        intro b
        have hK : ∀ c : γ,
            (cnt Fuv (a, b) : ℝ) / N * ((cnt Fuw (a, c) : ℝ) / N) / ((cnt u a : ℝ) / N)
            = ((cnt Fuv (a, b) : ℝ) / (N * (cnt u a : ℝ))) * (cnt Fuw (a, c) : ℝ) := by
          intro c
          field_simp
        rw [Finset.sum_congr rfl fun c _ => hK c, ← Finset.mul_sum, hsc]
        field_simp
      rw [Finset.sum_congr rfl fun b _ => hstep b, ← Finset.sum_div, hsb]
    have hp : ∀ a : α, ∑ b ∈ img v, ∑ c ∈ img w, (cnt T ((a, b), c) : ℝ) / N
        = (cnt u a : ℝ) / N := by
      intro a
      rw [← hmarg_u a, Finset.sum_div]
      exact Finset.sum_congr rfl fun b _ => by rw [Finset.sum_div]
    have hQ : ∑ a ∈ img u, ∑ b ∈ img v, ∑ c ∈ img w,
        (cnt Fuv (a, b) : ℝ) / N * ((cnt Fuw (a, c) : ℝ) / N) / ((cnt u a : ℝ) / N) = 1 := by
      rw [Finset.sum_congr rfl hq]
      exact sum_prob u
    have hP : ∑ a ∈ img u, ∑ b ∈ img v, ∑ c ∈ img w, (cnt T ((a, b), c) : ℝ) / N = 1 := by
      rw [Finset.sum_congr rfl fun a _ => hp a]
      exact sum_prob u
    linarith [hQ, hP]
  -- assemble
  have hsum : ∑ a ∈ img u, ∑ b ∈ img v, ∑ c ∈ img w,
      ((cnt T ((a, b), c) : ℝ) / N * Real.log (1 / ((cnt Fuv (a, b) : ℝ) / N))
        + (cnt T ((a, b), c) : ℝ) / N * Real.log (1 / ((cnt Fuw (a, c) : ℝ) / N))
        - (cnt T ((a, b), c) : ℝ) / N * Real.log (1 / ((cnt u a : ℝ) / N))
        + ((cnt Fuv (a, b) : ℝ) / N * ((cnt Fuw (a, c) : ℝ) / N) / ((cnt u a : ℝ) / N)
            - (cnt T ((a, b), c) : ℝ) / N))
      = H Fuv + H Fuw - H u + 0 := by
    simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib]
    rw [hA, hB, hC]
    linarith [hD]
  have hle : H T ≤ H Fuv + H Fuw - H u + 0 := by
    rw [H_triple_eq_sum_product u v w, ← hsum]
    exact Finset.sum_le_sum fun a ha =>
      Finset.sum_le_sum fun b hb => Finset.sum_le_sum fun c hc => hterm a ha b hb c hc
  linarith [hle]

/-! ## 4. Conditioning reduces entropy -/

/-- **Conditioning reduces entropy.**  Writing `H(w | u) = H(u, w) - H u`, knowing the
extra statistic `v` as well can only lower the conditional entropy:
`H(w | u, v) ≤ H(w | u)`. -/
theorem H_cond_mono (u : Ω → α) (v : Ω → β) (w : Ω → γ) :
    H (fun x => ((u x, v x), w x)) - H (fun x => (u x, v x))
      ≤ H (fun x => (u x, w x)) - H u :=
  by linarith [H_strong_subadditive u v w]

/-- Pair entropy determined by a refinement: if `u = r ∘ v` then `H(u, v) = H v`. -/
theorem H_pair_eq_of_factors {u : Ω → α} {v : Ω → β} {r : β → α} (hr : ∀ x, u x = r (v x)) :
    H (fun x => (u x, v x)) = H v := by
  have hfun : (fun x => (u x, v x)) = (fun b => (r b, b)) ∘ v := by
    funext x; simp [hr x]
  rw [hfun]
  exact H_comp_eq_of_injective v (fun b₁ b₂ h => congrArg Prod.snd h)

end TraceBattery