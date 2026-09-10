import Mathlib

/-!
# TRACE-BATTERY, part I: the finitary Shannon calculus

This file develops, from scratch and with no measure theory, the Shannon entropy of a
*statistic* `f : Ω → α` on a finite population `Ω`:

  `H f = Σ_{a ∈ img f} (cnt f a / N) · (log N - log (cnt f a))`,  `N = #Ω`,

i.e. the entropy in nats of the empirical distribution of `f`, and `Hb f = H f / log 2`
the same quantity in bits.

The results proved here are exactly the calculus needed by the companion file
`Combinatorics.TraceBatteryCapacity`:

* `sum_cnt` — the fibre counts of a statistic partition the population;
* `H_nonneg`, `Hb_nonneg` — nonnegativity;
* `H_le_log_card_img`, `H_le_log_card`, `Hb_le_logb_card_img` — the **maximum-entropy
  bound**, proved by the Gibbs inequality `log t ≤ t - 1`;
* `H_comp_le` — **data processing**: post-composing a statistic with any map can only
  lose information.  The engine is the subadditivity `phi_subadd` of the single-cell
  entropy contribution `phi N c = (c/N)(log N - log c)`;
* `H_comp_lt` — the *strict* form: merging two nonempty distinct cells strictly lowers
  the entropy (`phi_subadd_lt`);
* `H_comp_eq_of_injective` — relabelling changes nothing;
* `H_pair_le` — **subadditivity**: `H(f, g) ≤ H f + H g`, again by Gibbs, this time
  against the product of the two marginals.

Everything is elementary and finitary: no `native_decide`, no numerical input.
-/

namespace TraceBattery

open Finset

variable {Ω : Type*} [Fintype Ω] {α β : Type*}

/-! ## 1. Fibres, counts and the image -/

open Classical in
/-- The finite set of values actually taken by the statistic `f`. -/
noncomputable def img (f : Ω → α) : Finset α := Finset.image f Finset.univ

open Classical in
/-- The fibre of `f` over the value `a`. -/
noncomputable def fib (f : Ω → α) (a : α) : Finset Ω := Finset.univ.filter fun x => f x = a

/-- The number of individuals whose reading is `a`. -/
noncomputable def cnt (f : Ω → α) (a : α) : ℕ := (fib f a).card

theorem mem_img {f : Ω → α} {a : α} : a ∈ img f ↔ ∃ x, f x = a := by
  classical
  simp [img]

theorem self_mem_img (f : Ω → α) (x : Ω) : f x ∈ img f := mem_img.2 ⟨x, rfl⟩

theorem mem_fib {f : Ω → α} {a : α} {x : Ω} : x ∈ fib f a ↔ f x = a := by
  classical
  simp [fib]

theorem fib_eq_filter (f : Ω → α) (a : α) [DecidablePred fun x => f x = a] :
    fib f a = Finset.univ.filter fun x => f x = a := by
  ext x
  simp [mem_fib]

theorem cnt_pos {f : Ω → α} {a : α} (ha : a ∈ img f) : 0 < cnt f a := by
  obtain ⟨x, hx⟩ := mem_img.1 ha
  exact Finset.card_pos.2 ⟨x, mem_fib.2 hx⟩

theorem cnt_eq_zero {f : Ω → α} {a : α} (ha : a ∉ img f) : cnt f a = 0 := by
  rw [cnt, Finset.card_eq_zero]
  refine Finset.eq_empty_of_forall_notMem fun x hx => ?_
  exact ha (mem_fib.1 hx ▸ self_mem_img f x)

theorem cnt_le_card (f : Ω → α) (a : α) : cnt f a ≤ Fintype.card Ω := by
  simpa [cnt, Finset.card_univ] using Finset.card_le_card (Finset.subset_univ (fib f a))

/-- The fibre counts of a statistic add up to the size of the population. -/
theorem sum_cnt (f : Ω → α) : ∑ a ∈ img f, cnt f a = Fintype.card Ω := by
  classical
  have h := Finset.card_eq_sum_card_fiberwise (f := f) (s := (Finset.univ : Finset Ω))
    (t := img f) (fun x _ => self_mem_img f x)
  rw [Finset.card_univ] at h
  rw [h]
  exact Finset.sum_congr rfl fun a _ => by rw [cnt, fib_eq_filter]

/-! ## 2. The entropy of a statistic -/

/-- The contribution of a single cell of size `c` in a population of size `N`. -/
noncomputable def phi (N c : ℕ) : ℝ := (c : ℝ) / N * (Real.log N - Real.log c)

/-- **Shannon entropy in nats** of the empirical distribution of a statistic. -/
noncomputable def H (f : Ω → α) : ℝ :=
  ∑ a ∈ img f, (cnt f a : ℝ) / (Fintype.card Ω : ℝ) *
    (Real.log (Fintype.card Ω : ℝ) - Real.log (cnt f a : ℝ))

/-- **Shannon entropy in bits.** -/
noncomputable def Hb (f : Ω → α) : ℝ := H f / Real.log 2

theorem H_eq_sum_phi (f : Ω → α) : H f = ∑ a ∈ img f, phi (Fintype.card Ω) (cnt f a) := rfl

/-- `0 < log 2`, used throughout to convert nats into bits. -/
theorem log_two_pos : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)

/-! ## 3. The cell function `phi` -/

theorem phi_eq (N c : ℕ) :
    phi N c = (1 / (N : ℝ)) * ((c : ℝ) * (Real.log N - Real.log c)) := by
  rw [phi]; ring

@[simp] theorem phi_zero (N : ℕ) : phi N 0 = 0 := by simp [phi]

theorem phi_nonneg {N c : ℕ} (h : c ≤ N) : 0 ≤ phi N c := by
  rcases Nat.eq_zero_or_pos c with rfl | hc
  · simp
  have hcR : (0 : ℝ) < c := by exact_mod_cast hc
  have hNR : (0 : ℝ) < N := by exact_mod_cast lt_of_lt_of_le hc h
  have hlog : Real.log c ≤ Real.log N := Real.log_le_log hcR (by exact_mod_cast h)
  rw [phi]
  have : (0 : ℝ) ≤ (c : ℝ) / N := by positivity
  exact mul_nonneg this (by linarith)

/-- `x log x` is superadditive: merging two cells destroys entropy. -/
theorem mul_log_add_le (c d : ℕ) :
    (c : ℝ) * Real.log c + (d : ℝ) * Real.log d ≤ ((c : ℝ) + d) * Real.log ((c : ℝ) + d) := by
  rcases Nat.eq_zero_or_pos c with rfl | hc
  · simp
  rcases Nat.eq_zero_or_pos d with rfl | hd
  · simp
  have hcR : (0 : ℝ) < c := by exact_mod_cast hc
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd
  have h1 : Real.log c ≤ Real.log ((c : ℝ) + d) := Real.log_le_log hcR (by linarith)
  have h2 : Real.log d ≤ Real.log ((c : ℝ) + d) := Real.log_le_log hdR (by linarith)
  nlinarith

theorem mul_log_add_lt {c d : ℕ} (hc : 0 < c) (hd : 0 < d) :
    (c : ℝ) * Real.log c + (d : ℝ) * Real.log d < ((c : ℝ) + d) * Real.log ((c : ℝ) + d) := by
  have hcR : (0 : ℝ) < c := by exact_mod_cast hc
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd
  have h1 : Real.log c < Real.log ((c : ℝ) + d) := Real.log_lt_log hcR (by linarith)
  have h2 : Real.log d < Real.log ((c : ℝ) + d) := Real.log_lt_log hdR (by linarith)
  nlinarith

/-- **Subadditivity of the cell function**: a merged cell contributes at most as much as
the two cells it came from. -/
theorem phi_subadd (N c d : ℕ) : phi N (c + d) ≤ phi N c + phi N d := by
  rcases Nat.eq_zero_or_pos N with rfl | hN
  · simp [phi]
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have key := mul_log_add_le c d
  have hle : ((c + d : ℕ) : ℝ) * (Real.log N - Real.log ((c + d : ℕ) : ℝ))
      ≤ (c : ℝ) * (Real.log N - Real.log c) + (d : ℝ) * (Real.log N - Real.log d) := by
    push_cast
    nlinarith [key]
  rw [phi_eq, phi_eq, phi_eq, ← mul_add]
  exact mul_le_mul_of_nonneg_left hle (by positivity)

/-- The strict form of `phi_subadd`, for two nonempty cells. -/
theorem phi_subadd_lt {N c d : ℕ} (hN : 0 < N) (hc : 0 < c) (hd : 0 < d) :
    phi N (c + d) < phi N c + phi N d := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have key := mul_log_add_lt hc hd
  have hlt : ((c + d : ℕ) : ℝ) * (Real.log N - Real.log ((c + d : ℕ) : ℝ))
      < (c : ℝ) * (Real.log N - Real.log c) + (d : ℝ) * (Real.log N - Real.log d) := by
    push_cast
    nlinarith [key]
  rw [phi_eq, phi_eq, phi_eq, ← mul_add]
  exact mul_lt_mul_of_pos_left hlt (by positivity)

theorem phi_sum_le {ι : Type*} (N : ℕ) (t : Finset ι) (c : ι → ℕ) :
    phi N (∑ a ∈ t, c a) ≤ ∑ a ∈ t, phi N (c a) := by
  classical
  induction t using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.sum_insert ha]
      exact (phi_subadd N (c a) (∑ b ∈ s, c b)).trans (by linarith)

theorem phi_sum_lt {ι : Type*} [DecidableEq ι] {N : ℕ} (hN : 0 < N) (t : Finset ι) (c : ι → ℕ)
    {a₁ a₂ : ι} (h1 : a₁ ∈ t) (h2 : a₂ ∈ t) (hne : a₁ ≠ a₂) (hc1 : 0 < c a₁) (hc2 : 0 < c a₂) :
    phi N (∑ a ∈ t, c a) < ∑ a ∈ t, phi N (c a) := by
  have ha2 : a₂ ∈ t.erase a₁ := Finset.mem_erase.2 ⟨hne.symm, h2⟩
  have hsum : ∑ a ∈ t, c a = c a₁ + c a₂ + ∑ a ∈ (t.erase a₁).erase a₂, c a := by
    rw [← Finset.add_sum_erase _ _ h1, ← Finset.add_sum_erase _ _ ha2, add_assoc]
  have hsumphi : ∑ a ∈ t, phi N (c a)
      = phi N (c a₁) + phi N (c a₂) + ∑ a ∈ (t.erase a₁).erase a₂, phi N (c a) := by
    rw [← Finset.add_sum_erase _ _ h1, ← Finset.add_sum_erase _ _ ha2, add_assoc]
  rw [hsum, hsumphi]
  calc phi N (c a₁ + c a₂ + ∑ a ∈ (t.erase a₁).erase a₂, c a)
      ≤ phi N (c a₁ + c a₂) + phi N (∑ a ∈ (t.erase a₁).erase a₂, c a) :=
        phi_subadd _ _ _
    _ < phi N (c a₁) + phi N (c a₂) + phi N (∑ a ∈ (t.erase a₁).erase a₂, c a) := by
        have := phi_subadd_lt hN hc1 hc2
        linarith
    _ ≤ phi N (c a₁) + phi N (c a₂) + ∑ a ∈ (t.erase a₁).erase a₂, phi N (c a) := by
        have := phi_sum_le N ((t.erase a₁).erase a₂) c
        linarith

/-- The cell contribution written as `p log (1/p)`. -/
theorem phi_eq_plogp {N c : ℕ} (hN : 0 < N) :
    phi N c = ((c : ℝ) / N) * Real.log (1 / ((c : ℝ) / N)) := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  rcases Nat.eq_zero_or_pos c with rfl | hc
  · simp
  have hcR : (0 : ℝ) < c := by exact_mod_cast hc
  rw [phi, one_div_div, Real.log_div (ne_of_gt hNR) (ne_of_gt hcR)]

/-! ## 4. Two Gibbs inequalities -/

/-- **Gibbs, uniform reference.**  For a probability weight `p` and a positive reference
`1/M`, `p log (1/p) ≤ p log M + (1/M - p)`. -/
theorem gibbs_term {p M : ℝ} (hp : 0 ≤ p) (hM : 0 < M) :
    p * Real.log (1 / p) ≤ p * Real.log M + (1 / M - p) := by
  rcases eq_or_lt_of_le hp with hp0 | hp0
  · rw [← hp0]
    simp only [zero_mul, sub_zero]
    positivity
  have h := Real.log_le_sub_one_of_pos (show (0 : ℝ) < 1 / (p * M) by positivity)
  have hlog : Real.log (1 / (p * M)) = Real.log (1 / p) - Real.log M := by
    rw [one_div, one_div, Real.log_inv, Real.log_inv,
      Real.log_mul (ne_of_gt hp0) (ne_of_gt hM)]
    ring
  rw [hlog] at h
  have h2 := mul_le_mul_of_nonneg_left h hp
  have h3 : p * (1 / (p * M) - 1) = 1 / M - p := by field_simp
  rw [h3] at h2
  nlinarith [h2]

/-- **Gibbs, product reference.**  For a weight `p` and positive marginals `u, v`,
`p log (1/p) ≤ p log (1/u) + p log (1/v) + (uv - p)`. -/
theorem gibbs_pair_term {p u v : ℝ} (hp : 0 ≤ p) (hu : 0 < u) (hv : 0 < v) :
    p * Real.log (1 / p) ≤ p * Real.log (1 / u) + p * Real.log (1 / v) + (u * v - p) := by
  rcases eq_or_lt_of_le hp with hp0 | hp0
  · rw [← hp0]
    simp only [zero_mul, sub_zero, zero_add]
    positivity
  have h := Real.log_le_sub_one_of_pos (show (0 : ℝ) < u * v / p by positivity)
  have hlog : Real.log (u * v / p) = Real.log (1 / p) - Real.log (1 / u) - Real.log (1 / v) := by
    rw [Real.log_div (by positivity) (ne_of_gt hp0), Real.log_mul (ne_of_gt hu) (ne_of_gt hv),
      one_div, one_div, one_div, Real.log_inv, Real.log_inv, Real.log_inv]
    ring
  rw [hlog] at h
  have h2 := mul_le_mul_of_nonneg_left h hp
  have h3 : p * (u * v / p - 1) = u * v - p := by field_simp
  rw [h3] at h2
  nlinarith [h2]

/-! ## 5. Nonnegativity and the maximum-entropy bound -/

theorem H_nonneg (f : Ω → α) : 0 ≤ H f :=
  Finset.sum_nonneg fun a _ => phi_nonneg (cnt_le_card f a)

theorem Hb_nonneg (f : Ω → α) : 0 ≤ Hb f :=
  div_nonneg (H_nonneg f) (le_of_lt log_two_pos)

theorem img_eq_empty_of_isEmpty [IsEmpty Ω] (f : Ω → α) : img f = ∅ := by
  refine Finset.eq_empty_of_forall_notMem fun a ha => ?_
  obtain ⟨x, _⟩ := mem_img.1 ha
  exact IsEmpty.elim ‹IsEmpty Ω› x

theorem sum_prob (f : Ω → α) [Nonempty Ω] :
    ∑ a ∈ img f, (cnt f a : ℝ) / (Fintype.card Ω : ℝ) = 1 := by
  have hNR : (0 : ℝ) < Fintype.card Ω := by exact_mod_cast Fintype.card_pos
  rw [← Finset.sum_div]
  have hcast : ∑ a ∈ img f, (cnt f a : ℝ) = (Fintype.card Ω : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (sum_cnt f)
  rw [hcast, div_self (ne_of_gt hNR)]

/-- **Maximum entropy.**  The entropy of a statistic never exceeds the logarithm of the
number of values it takes. -/
theorem H_le_log_card_img (f : Ω → α) : H f ≤ Real.log ((img f).card : ℝ) := by
  rcases isEmpty_or_nonempty Ω with hΩ | hΩ
  · simp [H, img_eq_empty_of_isEmpty f]
  have hNR : (0 : ℝ) < Fintype.card Ω := by exact_mod_cast Fintype.card_pos
  have hMne : (img f).Nonempty := ⟨f (Classical.arbitrary Ω), self_mem_img _ _⟩
  have hMR : (0 : ℝ) < ((img f).card : ℝ) := by
    exact_mod_cast Finset.card_pos.2 hMne
  have hterm : ∀ a ∈ img f, phi (Fintype.card Ω) (cnt f a)
      ≤ (cnt f a : ℝ) / (Fintype.card Ω : ℝ) * Real.log ((img f).card : ℝ)
        + (1 / ((img f).card : ℝ) - (cnt f a : ℝ) / (Fintype.card Ω : ℝ)) := by
    intro a _
    rw [phi_eq_plogp Fintype.card_pos]
    exact gibbs_term (by positivity) hMR
  have hT : ∑ a ∈ img f, (cnt f a : ℝ) / (Fintype.card Ω : ℝ) = 1 := sum_prob f
  calc H f = ∑ a ∈ img f, phi (Fintype.card Ω) (cnt f a) := rfl
    _ ≤ ∑ a ∈ img f, ((cnt f a : ℝ) / (Fintype.card Ω : ℝ) * Real.log ((img f).card : ℝ)
          + (1 / ((img f).card : ℝ) - (cnt f a : ℝ) / (Fintype.card Ω : ℝ))) :=
        Finset.sum_le_sum hterm
    _ = Real.log ((img f).card : ℝ) := by
        rw [Finset.sum_add_distrib, ← Finset.sum_mul, hT, one_mul, Finset.sum_sub_distrib,
          Finset.sum_const, hT, nsmul_eq_mul, mul_one_div, div_self (ne_of_gt hMR)]
        ring

theorem card_img_le (f : Ω → α) : ((img f).card : ℝ) ≤ (Fintype.card Ω : ℝ) := by
  classical
  have : (img f).card ≤ Fintype.card Ω := by
    rw [img, ← Finset.card_univ (α := Ω)]
    exact Finset.card_image_le
  exact_mod_cast this

/-- The entropy of a statistic never exceeds the logarithm of the population size. -/
theorem H_le_log_card (f : Ω → α) : H f ≤ Real.log (Fintype.card Ω : ℝ) := by
  rcases isEmpty_or_nonempty Ω with hΩ | hΩ
  · simp [H, img_eq_empty_of_isEmpty f]
  have hMne : (img f).Nonempty := ⟨f (Classical.arbitrary Ω), self_mem_img _ _⟩
  have hMR : (0 : ℝ) < ((img f).card : ℝ) := by
    exact_mod_cast Finset.card_pos.2 hMne
  exact (H_le_log_card_img f).trans (Real.log_le_log hMR (card_img_le f))

theorem Hb_le_logb_card_img (f : Ω → α) : Hb f ≤ Real.logb 2 ((img f).card : ℝ) := by
  rw [Hb, Real.logb]
  gcongr
  exact H_le_log_card_img f

/-! ## 6. Data processing -/

theorem cnt_comp (f : Ω → α) (g : α → β) [DecidableEq β] (b : β) :
    cnt (g ∘ f) b = ∑ a ∈ (img f).filter (fun a => g a = b), cnt f a := by
  classical
  have hmaps : ∀ x ∈ fib (g ∘ f) b, f x ∈ (img f).filter (fun a => g a = b) := by
    intro x hx
    exact Finset.mem_filter.2 ⟨self_mem_img f x, (mem_fib (f := g ∘ f)).1 hx⟩
  have h := Finset.card_eq_sum_card_fiberwise (f := f) (s := fib (g ∘ f) b)
    (t := (img f).filter (fun a => g a = b)) hmaps
  rw [cnt, h]
  refine Finset.sum_congr rfl fun a ha => ?_
  have hga : g a = b := (Finset.mem_filter.1 ha).2
  rw [cnt, fib_eq_filter]
  congr 1
  ext x
  simp only [Finset.mem_filter, mem_fib, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨_, hfa⟩; exact hfa
  · intro hfa
    refine ⟨?_, hfa⟩
    show g (f x) = b
    rw [hfa, hga]

theorem maps_img_comp (f : Ω → α) (g : α → β) :
    ∀ a ∈ img f, g a ∈ img (g ∘ f) := by
  intro a ha
  obtain ⟨x, rfl⟩ := mem_img.1 ha
  exact self_mem_img (g ∘ f) x

/-- **Data processing.**  Post-composing a statistic with an arbitrary map can only
decrease its entropy. -/
theorem H_comp_le (f : Ω → α) (g : α → β) : H (g ∘ f) ≤ H f := by
  classical
  calc H (g ∘ f) = ∑ b ∈ img (g ∘ f), phi (Fintype.card Ω) (cnt (g ∘ f) b) := rfl
    _ = ∑ b ∈ img (g ∘ f),
          phi (Fintype.card Ω) (∑ a ∈ (img f).filter (fun a => g a = b), cnt f a) := by
        exact Finset.sum_congr rfl fun b _ => by rw [cnt_comp]
    _ ≤ ∑ b ∈ img (g ∘ f), ∑ a ∈ (img f).filter (fun a => g a = b),
          phi (Fintype.card Ω) (cnt f a) :=
        Finset.sum_le_sum fun b _ => phi_sum_le _ _ _
    _ = ∑ a ∈ img f, phi (Fintype.card Ω) (cnt f a) :=
        Finset.sum_fiberwise_of_maps_to (maps_img_comp f g) _
    _ = H f := rfl

/-- **Strict data processing.**  If `g` confuses two values of `f` that actually occur,
the entropy drops strictly. -/
theorem H_comp_lt (f : Ω → α) (g : α → β) {x y : Ω} (hcoarse : g (f x) = g (f y))
    (hfine : f x ≠ f y) : H (g ∘ f) < H f := by
  classical
  have hN : 0 < Fintype.card Ω := Fintype.card_pos_iff.2 ⟨x⟩
  have hstep : ∀ b ∈ img (g ∘ f), phi (Fintype.card Ω) (cnt (g ∘ f) b)
      ≤ ∑ a ∈ (img f).filter (fun a => g a = b), phi (Fintype.card Ω) (cnt f a) := by
    intro b _
    rw [cnt_comp]
    exact phi_sum_le _ _ _
  have hex : ∃ b ∈ img (g ∘ f), phi (Fintype.card Ω) (cnt (g ∘ f) b)
      < ∑ a ∈ (img f).filter (fun a => g a = b), phi (Fintype.card Ω) (cnt f a) := by
    refine ⟨g (f x), self_mem_img (g ∘ f) x, ?_⟩
    rw [cnt_comp]
    refine phi_sum_lt hN _ _ (a₁ := f x) (a₂ := f y) ?_ ?_ hfine
      (cnt_pos (self_mem_img f x)) (cnt_pos (self_mem_img f y))
    · exact Finset.mem_filter.2 ⟨self_mem_img f x, rfl⟩
    · exact Finset.mem_filter.2 ⟨self_mem_img f y, hcoarse.symm⟩
  calc H (g ∘ f) = ∑ b ∈ img (g ∘ f), phi (Fintype.card Ω) (cnt (g ∘ f) b) := rfl
    _ < ∑ b ∈ img (g ∘ f), ∑ a ∈ (img f).filter (fun a => g a = b),
          phi (Fintype.card Ω) (cnt f a) := Finset.sum_lt_sum hstep hex
    _ = ∑ a ∈ img f, phi (Fintype.card Ω) (cnt f a) :=
        Finset.sum_fiberwise_of_maps_to (maps_img_comp f g) _
    _ = H f := rfl

theorem img_comp_eq_image (f : Ω → α) (g : α → β) [DecidableEq β] :
    img (g ∘ f) = (img f).image g := by
  classical
  ext b
  simp only [mem_img, Finset.mem_image]
  constructor
  · rintro ⟨x, rfl⟩
    exact ⟨f x, ⟨x, rfl⟩, rfl⟩
  · rintro ⟨a, ⟨x, rfl⟩, rfl⟩
    exact ⟨x, rfl⟩

theorem cnt_comp_of_injective (f : Ω → α) {g : α → β} (hg : Function.Injective g) (a : α) :
    cnt (g ∘ f) (g a) = cnt f a := by
  rw [cnt, cnt]
  congr 1
  ext x
  simp only [mem_fib]
  exact ⟨fun h => hg h, fun h => congrArg g h⟩

/-- Relabelling a statistic by an injection does not change its entropy. -/
theorem H_comp_eq_of_injective (f : Ω → α) {g : α → β} (hg : Function.Injective g) :
    H (g ∘ f) = H f := by
  classical
  calc H (g ∘ f) = ∑ b ∈ img (g ∘ f), phi (Fintype.card Ω) (cnt (g ∘ f) b) := rfl
    _ = ∑ b ∈ (img f).image g, phi (Fintype.card Ω) (cnt (g ∘ f) b) := by
        rw [img_comp_eq_image f g]
    _ = ∑ a ∈ img f, phi (Fintype.card Ω) (cnt (g ∘ f) (g a)) :=
        Finset.sum_image (fun a _ b _ h => hg h)
    _ = ∑ a ∈ img f, phi (Fintype.card Ω) (cnt f a) :=
        Finset.sum_congr rfl fun a _ => by rw [cnt_comp_of_injective f hg]
    _ = H f := rfl

/-! ## 7. Subadditivity -/

section Pair

variable (f : Ω → α) (g : Ω → β)

theorem cnt_pair_marginal_fst (a : α) :
    ∑ b ∈ img g, cnt (fun x => (f x, g x)) (a, b) = cnt f a := by
  classical
  have hmaps : ∀ x ∈ fib f a, g x ∈ img g := fun x _ => self_mem_img g x
  have h := Finset.card_eq_sum_card_fiberwise (f := g) (s := fib f a) (t := img g) hmaps
  rw [cnt, h]
  refine Finset.sum_congr rfl fun b _ => ?_
  rw [cnt, fib_eq_filter]
  congr 1
  ext x
  simp only [Finset.mem_filter, mem_fib, Finset.mem_univ, true_and, Prod.mk.injEq]

theorem cnt_pair_marginal_snd (b : β) :
    ∑ a ∈ img f, cnt (fun x => (f x, g x)) (a, b) = cnt g b := by
  classical
  have hmaps : ∀ x ∈ fib g b, f x ∈ img f := fun x _ => self_mem_img f x
  have h := Finset.card_eq_sum_card_fiberwise (f := f) (s := fib g b) (t := img f) hmaps
  rw [cnt, h]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [cnt, fib_eq_filter]
  congr 1
  ext x
  simp only [Finset.mem_filter, mem_fib, Finset.mem_univ, true_and, Prod.mk.injEq]
  tauto

theorem H_pair_eq_sum_product :
    H (fun x => (f x, g x))
      = ∑ a ∈ img f, ∑ b ∈ img g, phi (Fintype.card Ω) (cnt (fun x => (f x, g x)) (a, b)) := by
  classical
  have hsub : img (fun x => (f x, g x)) ⊆ (img f) ×ˢ (img g) := by
    intro w hw
    obtain ⟨x, rfl⟩ := mem_img.1 hw
    exact Finset.mem_product.2 ⟨self_mem_img f x, self_mem_img g x⟩
  have hzero : ∀ w ∈ (img f) ×ˢ (img g), w ∉ img (fun x => (f x, g x)) →
      phi (Fintype.card Ω) (cnt (fun x => (f x, g x)) w) = 0 := by
    intro w _ hw
    rw [cnt_eq_zero hw, phi_zero]
  calc H (fun x => (f x, g x))
      = ∑ w ∈ img (fun x => (f x, g x)), phi (Fintype.card Ω)
          (cnt (fun x => (f x, g x)) w) := rfl
    _ = ∑ w ∈ (img f) ×ˢ (img g), phi (Fintype.card Ω) (cnt (fun x => (f x, g x)) w) :=
        Finset.sum_subset hsub hzero
    _ = _ := Finset.sum_product _ _ _

/-- **Subadditivity of entropy.**  Reading two statistics at once is worth at most the
sum of their separate informations. -/
theorem H_pair_le : H (fun x => (f x, g x)) ≤ H f + H g := by
  classical
  rcases isEmpty_or_nonempty Ω with hΩ | hΩ
  · simp [H, img_eq_empty_of_isEmpty]
  have hNpos : 0 < Fintype.card Ω := Fintype.card_pos
  have hNR : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hNpos
  set N : ℕ := Fintype.card Ω with hN
  set F : Ω → α × β := fun x => (f x, g x) with hF
  -- abbreviations for the empirical weights
  have hterm : ∀ a ∈ img f, ∀ b ∈ img g,
      phi N (cnt F (a, b))
        ≤ (cnt F (a, b) : ℝ) / N * Real.log (1 / ((cnt f a : ℝ) / N))
          + (cnt F (a, b) : ℝ) / N * Real.log (1 / ((cnt g b : ℝ) / N))
          + ((cnt f a : ℝ) / N * ((cnt g b : ℝ) / N) - (cnt F (a, b) : ℝ) / N) := by
    intro a ha b hb
    have hu : (0 : ℝ) < (cnt f a : ℝ) / N := by
      have : 0 < cnt f a := cnt_pos ha
      have : (0 : ℝ) < (cnt f a : ℝ) := by exact_mod_cast this
      positivity
    have hv : (0 : ℝ) < (cnt g b : ℝ) / N := by
      have : 0 < cnt g b := cnt_pos hb
      have : (0 : ℝ) < (cnt g b : ℝ) := by exact_mod_cast this
      positivity
    rw [phi_eq_plogp hNpos]
    exact gibbs_pair_term (by positivity) hu hv
  have hsum1 : ∀ a ∈ img f,
      ∑ b ∈ img g, (cnt F (a, b) : ℝ) / N * Real.log (1 / ((cnt f a : ℝ) / N))
        = phi N (cnt f a) := by
    intro a _
    rw [← Finset.sum_mul, ← Finset.sum_div]
    have : ∑ b ∈ img g, (cnt F (a, b) : ℝ) = (cnt f a : ℝ) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (cnt_pair_marginal_fst f g a)
    rw [this, ← phi_eq_plogp hNpos]
  have hsum2 : ∀ b ∈ img g,
      ∑ a ∈ img f, (cnt F (a, b) : ℝ) / N * Real.log (1 / ((cnt g b : ℝ) / N))
        = phi N (cnt g b) := by
    intro b _
    rw [← Finset.sum_mul, ← Finset.sum_div]
    have : ∑ a ∈ img f, (cnt F (a, b) : ℝ) = (cnt g b : ℝ) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (cnt_pair_marginal_snd f g b)
    rw [this, ← phi_eq_plogp hNpos]
  have hPf : ∑ a ∈ img f, (cnt f a : ℝ) / N = 1 := sum_prob f
  have hPg : ∑ b ∈ img g, (cnt g b : ℝ) / N = 1 := sum_prob g
  have hPF : ∑ a ∈ img f, ∑ b ∈ img g, (cnt F (a, b) : ℝ) / N = 1 := by
    rw [← hPf]
    refine Finset.sum_congr rfl fun a _ => ?_
    rw [← Finset.sum_div]
    congr 1
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (cnt_pair_marginal_fst f g a)
  calc H F = ∑ a ∈ img f, ∑ b ∈ img g, phi N (cnt F (a, b)) := H_pair_eq_sum_product f g
    _ ≤ ∑ a ∈ img f, ∑ b ∈ img g,
          ((cnt F (a, b) : ℝ) / N * Real.log (1 / ((cnt f a : ℝ) / N))
            + (cnt F (a, b) : ℝ) / N * Real.log (1 / ((cnt g b : ℝ) / N))
            + ((cnt f a : ℝ) / N * ((cnt g b : ℝ) / N) - (cnt F (a, b) : ℝ) / N)) :=
        Finset.sum_le_sum fun a ha => Finset.sum_le_sum fun b hb => hterm a ha b hb
    _ = H f + H g := by
        have hsplit : ∀ a ∈ img f,
            ∑ b ∈ img g,
              ((cnt F (a, b) : ℝ) / N * Real.log (1 / ((cnt f a : ℝ) / N))
                + (cnt F (a, b) : ℝ) / N * Real.log (1 / ((cnt g b : ℝ) / N))
                + ((cnt f a : ℝ) / N * ((cnt g b : ℝ) / N) - (cnt F (a, b) : ℝ) / N))
            = phi N (cnt f a)
              + ∑ b ∈ img g, (cnt F (a, b) : ℝ) / N * Real.log (1 / ((cnt g b : ℝ) / N))
              + ((cnt f a : ℝ) / N * (∑ b ∈ img g, (cnt g b : ℝ) / N)
                  - ∑ b ∈ img g, (cnt F (a, b) : ℝ) / N) := by
          intro a ha
          rw [Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.sum_sub_distrib,
            hsum1 a ha, Finset.mul_sum]
        rw [Finset.sum_congr rfl hsplit, Finset.sum_add_distrib, Finset.sum_add_distrib,
          Finset.sum_sub_distrib, Finset.sum_comm (s := img f) (t := img g),
          Finset.sum_congr rfl hsum2, hPg]
        simp only [mul_one]
        rw [hPf, hPF]
        rw [H_eq_sum_phi, H_eq_sum_phi]
        ring

end Pair

end TraceBattery