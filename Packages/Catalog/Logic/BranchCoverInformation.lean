/-
# BRANCH-RAMIFICATION, part I: information calculus of a fibrewise-small coarsening

Two finitary facts about a coarsening `g ∘ f` of a statistic `f`, built on the catalog
calculus `TraceBattery.H` / `BatterySynergy.condH`, and used in
`Logic.BranchRamification` for the degree-two cover `(s, d) ↦ (s, d²)`:

* `condH_comp_eq` — **pure merging loses nothing**: if whenever `g` merges two distinct
  `f`-values the label is constant on the merged block, then `condH L (g ∘ f) = condH L f`.
  (This is the equality case of the data-processing inequality `condH_comp_le`.)
* `H_sub_H_comp_le_log_two` — **a two-to-one coarsening costs at most one bit**: if every
  `g`-fibre meets the image of `f` in at most two points then `H f - H (g ∘ f) ≤ log 2`.
  The proof is the log-sum inequality `real_logsum_le` applied fibre by fibre.
* `H_sub_H_comp_le_split` — the refined bound: the defect is at most `log 2` times the
  fraction of the population lying in genuinely split fibres; unsplit fibres cost nothing.
* `condH_comp_sub_le` — the conditional-entropy release of a coarsening is bounded by its
  entropy defect.
-/
import Mathlib
import Algebra.SumDiffUniform

namespace BranchRamification

open TraceBattery BatterySynergy SumDiffSplit Finset

section Info

variable {Ω : Type*} [Fintype Ω] {α β Λ ι : Type*}

theorem psi_self (N c : ℕ) : psi N c c = 0 := by simp [psi]

theorem psi_zero_left (N C : ℕ) : psi N 0 C = 0 := by simp [psi]

theorem cnt_pr_pure (L : Ω → Λ) (f : Ω → α) (l : Λ) (a : α) (l₀ : Λ)
    (hL : ∀ x, f x = a → L x = l₀) :
    cnt (pr L f) (l, a) = 0 ∨ cnt (pr L f) (l, a) = cnt f a := by
  classical
  by_cases hl : l = l₀
  · subst hl
    right
    rw [cnt, cnt, fib_eq_filter, fib_eq_filter]
    congr 1
    ext x
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, pr, Prod.mk.injEq]
    exact ⟨fun h => h.2, fun h => ⟨hL x h, h⟩⟩
  · left
    rw [cnt, Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
    intro x hx
    have hx' : (L x, f x) = (l, a) := (mem_fib (f := pr L f)).1 hx
    simp only [Prod.mk.injEq] at hx'
    exact hl (hx'.1 ▸ hL x hx'.2)

theorem psi_pr_pure (L : Ω → Λ) (f : Ω → α) (l : Λ) (a : α) (l₀ : Λ)
    (hL : ∀ x, f x = a → L x = l₀) :
    psi (Fintype.card Ω) (cnt (pr L f) (l, a)) (cnt f a) = 0 := by
  rcases cnt_pr_pure L f l a l₀ hL with h | h <;> rw [h]
  · exact psi_zero_left _ _
  · exact psi_self _ _

theorem condH_comp_eq (L : Ω → Λ) (f : Ω → α) (g : α → β)
    (h : ∀ x y, g (f x) = g (f y) → f x = f y ∨ L x = L y) :
    condH L (g ∘ f) = condH L f := by
  classical
  have hsplit : condH L f
      = ∑ b ∈ img (g ∘ f), ∑ a ∈ (img f).filter (fun a => g a = b),
          ∑ l ∈ img L, psi (Fintype.card Ω) (cnt (pr L f) (l, a)) (cnt f a) := by
    rw [condH_eq_sum L f]
    exact (Finset.sum_fiberwise_of_maps_to (maps_img_comp f g) _).symm
  rw [hsplit, condH_eq_sum L (g ∘ f)]
  refine Finset.sum_congr rfl fun b hb => ?_
  obtain ⟨x₀, hx₀⟩ := mem_img.1 hb
  simp only [Function.comp_apply] at hx₀
  by_cases hall : ∀ y, g (f y) = b → f y = f x₀
  · have hfil : (img f).filter (fun a => g a = b) = {f x₀} := by
      ext a
      simp only [Finset.mem_filter, Finset.mem_singleton]
      constructor
      · rintro ⟨ha, hga⟩
        obtain ⟨y, rfl⟩ := mem_img.1 ha
        exact hall y hga
      · rintro rfl
        exact ⟨self_mem_img f x₀, hx₀⟩
    rw [hfil, Finset.sum_singleton]
    refine Finset.sum_congr rfl fun l _ => ?_
    rw [cnt_pr_comp L f g l b, cnt_comp f g b, hfil, Finset.sum_singleton,
      Finset.sum_singleton]
  · push_neg at hall
    obtain ⟨y, hyb, hyx⟩ := hall
    have hconst : ∀ u, g (f u) = b → L u = L x₀ := by
      intro u hu
      have hLxy : L x₀ = L y := by
        rcases h x₀ y (by rw [hx₀, hyb]) with h1 | h1
        · exact absurd h1.symm hyx
        · exact h1
      by_cases hux : f u = f x₀
      · have huy : f u ≠ f y := fun e => hyx (e.symm.trans hux)
        rcases h u y (by rw [hu, hyb]) with h1 | h1
        · exact absurd h1 huy
        · rw [h1, hLxy]
      · rcases h u x₀ (by rw [hu, hx₀]) with h1 | h1
        · exact absurd h1 hux
        · exact h1
    rw [Finset.sum_eq_zero, Finset.sum_eq_zero]
    · intro a ha
      refine Finset.sum_eq_zero fun l _ => ?_
      have hga : g a = b := (Finset.mem_filter.1 ha).2
      exact psi_pr_pure L f l a (L x₀) fun x hx => hconst x (by rw [hx, hga])
    · intro l _
      exact psi_pr_pure L (g ∘ f) l b (L x₀) fun x hx => hconst x hx

theorem condH_comp_sub_le (L : Ω → Λ) (f : Ω → α) (g : α → β) :
    condH L (g ∘ f) - condH L f ≤ H f - H (g ∘ f) := by
  have hc : (fun w : Λ × α => (w.1, g w.2)) ∘ pr L f = pr L (g ∘ f) := rfl
  have h := H_comp_le (pr L f) fun w : Λ × α => (w.1, g w.2)
  rw [hc] at h
  simp only [condH]
  linarith

theorem sum_psi_le_log_card (N : ℕ) (t : Finset ι) (c : ι → ℕ) :
    ∑ i ∈ t, psi N (c i) (∑ j ∈ t, c j)
      ≤ ((∑ j ∈ t, c j : ℕ) : ℝ) / N * Real.log t.card := by
  have hls := real_logsum_le t (fun i => (c i : ℝ)) (fun _ => (1 : ℝ))
    (fun i _ => Nat.cast_nonneg _) (fun _ _ => one_pos)
  simp only [Real.log_one, zero_sub, Finset.sum_const, nsmul_eq_mul, mul_one] at hls
  have hsum : ∑ i ∈ t, (c i : ℝ) = ((∑ j ∈ t, c j : ℕ) : ℝ) := by push_cast; rfl
  rw [hsum] at hls
  have hexp : ∑ i ∈ t, psi N (c i) (∑ j ∈ t, c j)
      = (1 / (N : ℝ)) * (((∑ j ∈ t, c j : ℕ) : ℝ) * Real.log ((∑ j ∈ t, c j : ℕ) : ℝ)
          + ∑ i ∈ t, (c i : ℝ) * -Real.log (c i)) := by
    simp only [psi, Finset.mul_sum, ← hsum, Finset.sum_mul, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    ring
  rw [hexp]
  rcases Nat.eq_zero_or_pos N with hN | hN
  · simp [hN]
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have key : ((∑ j ∈ t, c j : ℕ) : ℝ) * Real.log ((∑ j ∈ t, c j : ℕ) : ℝ)
      + ∑ i ∈ t, (c i : ℝ) * -Real.log (c i)
      ≤ ((∑ j ∈ t, c j : ℕ) : ℝ) * Real.log t.card := by linarith
  calc (1 / (N : ℝ)) * (((∑ j ∈ t, c j : ℕ) : ℝ) * Real.log ((∑ j ∈ t, c j : ℕ) : ℝ)
          + ∑ i ∈ t, (c i : ℝ) * -Real.log (c i))
        ≤ (1 / (N : ℝ)) * (((∑ j ∈ t, c j : ℕ) : ℝ) * Real.log t.card) :=
          mul_le_mul_of_nonneg_left key (by positivity)
    _ = _ := by ring

theorem H_sub_H_comp_le_log_two [DecidableEq β] (f : Ω → α) (g : α → β)
    (h2 : ∀ b, ((img f).filter (fun a => g a = b)).card ≤ 2) :
    H f - H (g ∘ f) ≤ Real.log 2 := by
  classical
  have hHf : H f = ∑ b ∈ img (g ∘ f), ∑ a ∈ (img f).filter (fun a => g a = b),
      phi (Fintype.card Ω) (cnt f a) :=
    (Finset.sum_fiberwise_of_maps_to (maps_img_comp f g) _).symm
  have hHg : H (g ∘ f) = ∑ b ∈ img (g ∘ f),
      phi (Fintype.card Ω) (∑ a ∈ (img f).filter (fun a => g a = b), cnt f a) := by
    rw [H_eq_sum_phi]
    exact Finset.sum_congr rfl fun b _ => by rw [cnt_comp]
  rw [hHf, hHg, ← Finset.sum_sub_distrib]
  have hterm : ∀ b ∈ img (g ∘ f),
      (∑ a ∈ (img f).filter (fun a => g a = b), phi (Fintype.card Ω) (cnt f a))
        - phi (Fintype.card Ω) (∑ a ∈ (img f).filter (fun a => g a = b), cnt f a)
      ≤ (cnt (g ∘ f) b : ℝ) / Fintype.card Ω * Real.log 2 := by
    intro b _
    rw [← sum_psi_eq, cnt_comp]
    refine (sum_psi_le_log_card _ _ _).trans ?_
    refine mul_le_mul_of_nonneg_left ?_ (by positivity)
    rcases Nat.eq_zero_or_pos ((img f).filter (fun a => g a = b)).card with h0 | h0
    · rw [h0, Nat.cast_zero, Real.log_zero]; exact (Real.log_pos (by norm_num)).le
    · exact Real.log_le_log (by exact_mod_cast h0) (by exact_mod_cast h2 b)
  refine (Finset.sum_le_sum hterm).trans ?_
  rw [← Finset.sum_mul, ← Finset.sum_div]
  rcases isEmpty_or_nonempty Ω with hΩ | hΩ
  · rw [img_eq_empty_of_isEmpty]; simp [(Real.log_pos (by norm_num : (1:ℝ) < 2)).le]
  have hN : (0 : ℝ) < Fintype.card Ω := by exact_mod_cast Fintype.card_pos
  have hs : (∑ b ∈ img (g ∘ f), (cnt (g ∘ f) b : ℝ)) = Fintype.card Ω := by
    exact_mod_cast sum_cnt (g ∘ f)
  rw [hs, div_self hN.ne', one_mul]

/-- **Refined two-to-one bound.**  The entropy defect of a coarsening whose fibres meet the
image in at most two points is at most `log 2` times the fraction of the population lying
in a genuinely split fibre.  Unsplit fibres (the *ramification locus*) contribute nothing. -/
theorem H_sub_H_comp_le_split [DecidableEq β] (f : Ω → α) (g : α → β)
    (h2 : ∀ b, ((img f).filter (fun a => g a = b)).card ≤ 2)
    (S : Finset Ω) (hS : ∀ x y, g (f y) = g (f x) → f y ≠ f x → x ∈ S) :
    H f - H (g ∘ f) ≤ (S.card : ℝ) / Fintype.card Ω * Real.log 2 := by
  classical
  have hHf : H f = ∑ b ∈ img (g ∘ f), ∑ a ∈ (img f).filter (fun a => g a = b),
      phi (Fintype.card Ω) (cnt f a) :=
    (Finset.sum_fiberwise_of_maps_to (maps_img_comp f g) _).symm
  have hHg : H (g ∘ f) = ∑ b ∈ img (g ∘ f),
      phi (Fintype.card Ω) (∑ a ∈ (img f).filter (fun a => g a = b), cnt f a) := by
    rw [H_eq_sum_phi]
    exact Finset.sum_congr rfl fun b _ => by rw [cnt_comp]
  rw [hHf, hHg, ← Finset.sum_sub_distrib]
  have hlog2 : (0 : ℝ) ≤ Real.log 2 := (Real.log_pos (by norm_num)).le
  have hterm : ∀ b ∈ img (g ∘ f),
      (∑ a ∈ (img f).filter (fun a => g a = b), phi (Fintype.card Ω) (cnt f a))
        - phi (Fintype.card Ω) (∑ a ∈ (img f).filter (fun a => g a = b), cnt f a)
      ≤ ((S.filter fun x => (g ∘ f) x = b).card : ℝ) / Fintype.card Ω * Real.log 2 := by
    intro b _
    rw [← sum_psi_eq]
    refine (sum_psi_le_log_card _ _ _).trans ?_
    rw [← cnt_comp]
    set t := (img f).filter (fun a => g a = b) with ht
    by_cases hsplit : 2 ≤ t.card
    · have hfib : fib (g ∘ f) b ⊆ (S.filter fun x => (g ∘ f) x = b) := by
        intro x hx
        have hx : g (f x) = b := (mem_fib (f := g ∘ f)).1 hx
        refine Finset.mem_filter.2 ⟨?_, hx⟩
        obtain ⟨a₁, ha₁, a₂, ha₂, hne⟩ := Finset.one_lt_card.1 hsplit
        have h1 := Finset.mem_filter.1 ha₁
        have h2' := Finset.mem_filter.1 ha₂
        by_cases hx1 : f x = a₁
        · obtain ⟨y, hy⟩ := mem_img.1 h2'.1
          exact hS x y (by rw [hy, h2'.2, hx]) (by rw [hy, hx1]; exact Ne.symm hne)
        · obtain ⟨y, hy⟩ := mem_img.1 h1.1
          exact hS x y (by rw [hy, h1.2, hx]) (by rw [hy]; exact Ne.symm hx1)
      have hc : (cnt (g ∘ f) b : ℝ) ≤ ((S.filter fun x => (g ∘ f) x = b).card : ℝ) := by
        exact_mod_cast Finset.card_le_card hfib
      have hl : Real.log t.card ≤ Real.log 2 :=
        Real.log_le_log (by exact_mod_cast (by omega : 0 < t.card)) (by exact_mod_cast h2 b)
      have hl0 : 0 ≤ Real.log t.card := Real.log_nonneg (by exact_mod_cast (by omega : 1 ≤ t.card))
      have hN : (0 : ℝ) ≤ Fintype.card Ω := Nat.cast_nonneg _
      calc (cnt (g ∘ f) b : ℝ) / Fintype.card Ω * Real.log t.card
          ≤ ((S.filter fun x => (g ∘ f) x = b).card : ℝ) / Fintype.card Ω * Real.log t.card :=
            mul_le_mul_of_nonneg_right (div_le_div_of_nonneg_right hc hN) hl0
        _ ≤ _ := mul_le_mul_of_nonneg_left hl (by positivity)
    · have hle : Real.log t.card ≤ 0 := by
        interval_cases h : t.card <;> simp
      have : (cnt (g ∘ f) b : ℝ) / Fintype.card Ω * Real.log t.card ≤ 0 :=
        mul_nonpos_of_nonneg_of_nonpos (by positivity) hle
      exact this.trans (by positivity)
  refine (Finset.sum_le_sum hterm).trans (le_of_eq ?_)
  rw [← Finset.sum_mul, ← Finset.sum_div]
  have hmaps : ∀ x ∈ S, (g ∘ f) x ∈ img (g ∘ f) := fun x _ => self_mem_img _ x
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  push_cast
  rfl

end Info

end BranchRamification