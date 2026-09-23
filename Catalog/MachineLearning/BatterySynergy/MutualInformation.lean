/-
# BATTERY-SYNERGY, part I: the finitary mutual-information calculus

This file is the machinery demanded by the round-27 **BATTERY-CAPACITY**
experiment (paper 92, verdict *SYNERGY-COMPOUNDS*): the experiment measures a
*joint* trace information `I = 8.2246` bits of a four-dial battery against the
*additive* prediction `Σ marginals = 3.9099` bits, and reports a joint
label-entropy ceiling of `9.5276` bits.  Marginal bookkeeping is therefore not
the right arithmetic; one needs mutual information of a label against a joint
statistic, together with its exact monotonicity theory.

Everything is finitary and counting-based, built on the empirical entropy
`TraceBattery.H` of `Combinatorics.TraceBatteryEntropy`:

* `BatterySynergy.real_logsum_le` — the **log-sum inequality** on a finite index
  set, proved from `log t ≤ t - 1`;
* `BatterySynergy.psi_sum_le` — its counting form: merging cells can only raise
  the conditional-entropy contribution;
* `BatterySynergy.condH`, `BatterySynergy.MI`, `BatterySynergy.MIb` —
  conditional entropy and mutual information (nats and bits) of an empirical
  population;
* `BatterySynergy.MI_nonneg`, `MI_le_label_entropy`, `MI_le_stat_entropy` — the
  two ceilings; the first is the `9.5276`-bit joint-label-entropy ceiling of the
  experiment, the second is the CRT/sparse-code ceiling;
* `BatterySynergy.condH_comp_le`, `BatterySynergy.MI_comp_le` — the **data
  processing inequality** for mutual information, i.e. coarsening a battery
  never raises its capacity.  This is the theorem that makes "joint capacity"
  monotone in the set of dials, and it is *not* a consequence of
  `TraceBattery.H_comp_le`;
* `BatterySynergy.MI_eq_of_same_fibers` — capacity depends only on the partition
  a statistic induces, which is what licenses replacing a CRT residue vector by
  any faithful numeric code;
* `BatterySynergy.MI_eq_label_entropy_of_determines` — a battery that pins the
  label carries exactly the label entropy: the ceiling is attained.

No numerical input, no `native_decide`.
-/
import Mathlib
import Combinatorics.TraceBatteryEntropy

namespace BatterySynergy

open TraceBattery Finset

variable {Ω : Type*} [Fintype Ω] {α β Λ : Type*} {ι : Type*}

/-! ## 1. The log-sum inequality -/

/-- **Log-sum inequality.**  For nonnegative weights `a i` and positive
references `b i`,
`Σ aᵢ (log bᵢ - log aᵢ) ≤ (Σ aᵢ)(log Σ bᵢ - log Σ aᵢ)`.
(The convention `0 · log 0 = 0` is automatic here: the factor `a i` is `0`.)
The proof is Gibbs' `log t ≤ t - 1` applied to `t = bᵢ A / (aᵢ B)`. -/
theorem real_logsum_le (t : Finset ι) (a b : ι → ℝ)
    (ha : ∀ i ∈ t, 0 ≤ a i) (hb : ∀ i ∈ t, 0 < b i) :
    ∑ i ∈ t, a i * (Real.log (b i) - Real.log (a i))
      ≤ (∑ i ∈ t, a i) * (Real.log (∑ i ∈ t, b i) - Real.log (∑ i ∈ t, a i)) := by
  set A := ∑ i ∈ t, a i with hA
  set B := ∑ i ∈ t, b i with hB
  have hA0 : 0 ≤ A := Finset.sum_nonneg ha
  rcases eq_or_lt_of_le hA0 with hA0' | hApos
  · -- degenerate case: all weights vanish
    have hzero : ∀ i ∈ t, a i = 0 := by
      intro i hi
      have := (Finset.sum_eq_zero_iff_of_nonneg ha).1 hA0'.symm i hi
      exact this
    have : ∑ i ∈ t, a i * (Real.log (b i) - Real.log (a i)) = 0 := by
      refine Finset.sum_eq_zero fun i hi => ?_
      rw [hzero i hi, zero_mul]
    rw [this, ← hA0']
    simp
  · have hne : t.Nonempty := by
      by_contra h
      rw [Finset.not_nonempty_iff_eq_empty] at h
      rw [hA, h] at hApos
      simp at hApos
    have hBpos : 0 < B := Finset.sum_pos hb hne
    have key : ∀ i ∈ t, a i * (Real.log (b i) - Real.log (a i))
        ≤ a i * (Real.log B - Real.log A) + (A / B * b i - a i) := by
      intro i hi
      rcases eq_or_lt_of_le (ha i hi) with hai | hai
      · have h0 : 0 ≤ A / B * b i := mul_nonneg (div_nonneg hA0 hBpos.le) (hb i hi).le
        rw [← hai]
        simp only [zero_mul, sub_zero, zero_add]
        linarith
      · have hbi := hb i hi
        have hx : (0 : ℝ) < b i * A / (a i * B) := by positivity
        have hlog := Real.log_le_sub_one_of_pos hx
        have hxlog : Real.log (b i * A / (a i * B))
            = Real.log (b i) - Real.log (a i) - (Real.log B - Real.log A) := by
          rw [Real.log_div (by positivity) (by positivity), Real.log_mul (ne_of_gt hbi)
            (ne_of_gt hApos), Real.log_mul (ne_of_gt hai) (ne_of_gt hBpos)]
          ring
        rw [hxlog] at hlog
        have h2 := mul_le_mul_of_nonneg_left hlog (le_of_lt hai)
        have h3 : a i * (b i * A / (a i * B) - 1) = A / B * b i - a i := by
          field_simp
        rw [h3] at h2
        nlinarith [h2]
    calc ∑ i ∈ t, a i * (Real.log (b i) - Real.log (a i))
        ≤ ∑ i ∈ t, (a i * (Real.log B - Real.log A) + (A / B * b i - a i)) :=
          Finset.sum_le_sum key
      _ = A * (Real.log B - Real.log A) := by
          rw [Finset.sum_add_distrib, ← Finset.sum_mul, Finset.sum_sub_distrib,
            ← Finset.mul_sum, ← hA, ← hB]
          field_simp
          ring


/-! ## 2. The cell contribution of a conditional entropy -/

/-- The conditional-entropy contribution of a cell of size `c` inside a block of
size `C`, on a population of `N` individuals:  `ψ N c C = (c/N) log (C/c)`. -/
noncomputable def psi (N c C : ℕ) : ℝ := (c : ℝ) / N * (Real.log C - Real.log c)

theorem psi_eq (N c C : ℕ) :
    psi N c C = phi N c + (c : ℝ) / N * (Real.log C - Real.log N) := by
  simp only [psi, phi]; ring

/-- Splitting a block of counts into its cells: the sum of the cell
contributions is the entropy defect of the block. -/
theorem sum_psi_eq (N : ℕ) (t : Finset ι) (c : ι → ℕ) :
    ∑ i ∈ t, psi N (c i) (∑ j ∈ t, c j)
      = (∑ i ∈ t, phi N (c i)) - phi N (∑ j ∈ t, c j) := by
  simp only [psi_eq]
  rw [Finset.sum_add_distrib, ← Finset.sum_mul]
  have hcast : ∑ i ∈ t, (c i : ℝ) / N = ((∑ j ∈ t, c j : ℕ) : ℝ) / N := by
    rw [← Finset.sum_div]
    push_cast
    ring
  rw [hcast]
  simp only [phi]
  ring

/-- **Counting log-sum inequality.**  Merging the cells `c i` (inside blocks
`C i`) into one cell can only increase the conditional-entropy contribution. -/
theorem psi_sum_le (N : ℕ) (t : Finset ι) (c C : ι → ℕ) (hC : ∀ i ∈ t, 0 < C i) :
    ∑ i ∈ t, psi N (c i) (C i) ≤ psi N (∑ i ∈ t, c i) (∑ i ∈ t, C i) := by
  have hb : ∀ i ∈ t, (0 : ℝ) < (C i : ℝ) := by
    intro i hi; exact_mod_cast hC i hi
  have ha : ∀ i ∈ t, (0 : ℝ) ≤ (c i : ℝ) := by
    intro i _; positivity
  have hmain := real_logsum_le t (fun i => (c i : ℝ)) (fun i => (C i : ℝ)) ha hb
  have hcc : ∑ i ∈ t, ((c i : ℝ)) = ((∑ i ∈ t, c i : ℕ) : ℝ) := by push_cast; ring
  have hCC : ∑ i ∈ t, ((C i : ℝ)) = ((∑ i ∈ t, C i : ℕ) : ℝ) := by push_cast; ring
  rw [hcc, hCC] at hmain
  have hN : (0 : ℝ) ≤ 1 / (N : ℝ) := by positivity
  have hscale := mul_le_mul_of_nonneg_left hmain hN
  calc ∑ i ∈ t, psi N (c i) (C i)
      = 1 / (N : ℝ) * ∑ i ∈ t, (c i : ℝ) * (Real.log (C i) - Real.log (c i)) := by
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl fun i _ => ?_
        simp only [psi]
        ring
    _ ≤ 1 / (N : ℝ) * (((∑ i ∈ t, c i : ℕ) : ℝ)
          * (Real.log ((∑ i ∈ t, C i : ℕ) : ℝ) - Real.log ((∑ i ∈ t, c i : ℕ) : ℝ))) := hscale
    _ = psi N (∑ i ∈ t, c i) (∑ i ∈ t, C i) := by
        simp only [psi]; ring

/-! ## 3. Conditional entropy and mutual information -/

/-- The joint statistic `(label, reading)`. -/
def pr (L : Ω → Λ) (f : Ω → α) : Ω → Λ × α := fun x => (L x, f x)

/-- The **conditional entropy** `H(L | f)` in nats, as an entropy defect. -/
noncomputable def condH (L : Ω → Λ) (f : Ω → α) : ℝ := H (pr L f) - H f

/-- The **trace information** `I(L ; f)` in nats. -/
noncomputable def MI (L : Ω → Λ) (f : Ω → α) : ℝ := H L - condH L f

/-- The trace information in **bits** — the unit of the experiment. -/
noncomputable def MIb (L : Ω → Λ) (f : Ω → α) : ℝ := MI L f / Real.log 2

theorem MI_eq (L : Ω → Λ) (f : Ω → α) : MI L f = H L + H f - H (pr L f) := by
  simp only [MI, condH]; ring

theorem H_le_H_pr (L : Ω → Λ) (f : Ω → α) : H L ≤ H (pr L f) := by
  have h : (Prod.fst ∘ pr L f) = L := rfl
  have := H_comp_le (pr L f) (Prod.fst (β := α))
  rwa [h] at this

theorem H_stat_le_H_pr (L : Ω → Λ) (f : Ω → α) : H f ≤ H (pr L f) := by
  have h : (Prod.snd ∘ pr L f) = f := rfl
  have := H_comp_le (pr L f) (Prod.snd (α := Λ))
  rwa [h] at this

theorem condH_nonneg (L : Ω → Λ) (f : Ω → α) : 0 ≤ condH L f := by
  simp only [condH]
  linarith [H_stat_le_H_pr L f]

theorem condH_le_label (L : Ω → Λ) (f : Ω → α) : condH L f ≤ H L := by
  have hpr : H (pr L f) = H (fun x => (L x, f x)) := rfl
  simp only [condH, hpr]
  linarith [H_pair_le L f]

/-- **Nonnegativity of trace information.** -/
theorem MI_nonneg (L : Ω → Λ) (f : Ω → α) : 0 ≤ MI L f := by
  simp only [MI]
  linarith [condH_le_label L f]

/-- **Joint-label-entropy ceiling.**  No battery, however wide, can carry more
than the entropy of the labels it is being read against.  This is the
`9.5276`-bit ceiling of the experiment. -/
theorem MI_le_label_entropy (L : Ω → Λ) (f : Ω → α) : MI L f ≤ H L := by
  simp only [MI]
  linarith [condH_nonneg L f]

/-- **Code ceiling.**  The trace information is also at most the entropy of the
joint reading itself; composed with `TraceBattery.capacity_le_logb_prod` this is
the CRT ceiling `log₂ 51336`. -/
theorem MI_le_stat_entropy (L : Ω → Λ) (f : Ω → α) : MI L f ≤ H f := by
  rw [MI_eq]
  linarith [H_le_H_pr L f]

theorem MIb_nonneg (L : Ω → Λ) (f : Ω → α) : 0 ≤ MIb L f :=
  div_nonneg (MI_nonneg L f) (le_of_lt log_two_pos)

theorem MIb_le_label_entropy (L : Ω → Λ) (f : Ω → α) : MIb L f ≤ Hb L := by
  rw [MIb, Hb]
  exact (div_le_div_iff_of_pos_right log_two_pos).mpr (MI_le_label_entropy L f)

theorem MIb_le_stat_entropy (L : Ω → Λ) (f : Ω → α) : MIb L f ≤ Hb f := by
  rw [MIb, Hb]
  exact (div_le_div_iff_of_pos_right log_two_pos).mpr (MI_le_stat_entropy L f)

/-! ## 4. The data processing inequality -/

section DPI

variable (L : Ω → Λ) (f : Ω → α)

/-- The conditional entropy as a double sum of cell contributions. -/
theorem condH_eq_sum :
    condH L f
      = ∑ a ∈ img f, ∑ l ∈ img L, psi (Fintype.card Ω) (cnt (pr L f) (l, a)) (cnt f a) := by
  classical
  have hpair : H (pr L f)
      = ∑ a ∈ img f, ∑ l ∈ img L, phi (Fintype.card Ω) (cnt (pr L f) (l, a)) := by
    rw [show H (pr L f) = H (fun x => (L x, f x)) from rfl, H_pair_eq_sum_product L f]
    exact Finset.sum_comm
  have hmarg : ∀ a ∈ img f, cnt f a = ∑ l ∈ img L, cnt (pr L f) (l, a) := by
    intro a _
    exact (cnt_pair_marginal_snd L f a).symm
  rw [condH, hpair, H_eq_sum_phi, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun a ha => ?_
  rw [hmarg a ha, sum_psi_eq]

/-- Fibre refinement of the joint counts along a coarsening `g` of the reading. -/
theorem cnt_pr_comp [DecidableEq β] (g : α → β) (l : Λ) (b : β) :
    cnt (pr L (g ∘ f)) (l, b)
      = ∑ a ∈ (img f).filter (fun a => g a = b), cnt (pr L f) (l, a) := by
  classical
  have hmaps : ∀ x ∈ fib (pr L (g ∘ f)) (l, b), f x ∈ (img f).filter (fun a => g a = b) := by
    intro x hx
    have hx' : (L x, g (f x)) = (l, b) := (mem_fib (f := pr L (g ∘ f))).1 hx
    exact Finset.mem_filter.2 ⟨self_mem_img f x, congrArg Prod.snd hx'⟩
  have h := Finset.card_eq_sum_card_fiberwise (f := f) (s := fib (pr L (g ∘ f)) (l, b))
    (t := (img f).filter (fun a => g a = b)) hmaps
  rw [cnt, h]
  refine Finset.sum_congr rfl fun a ha => ?_
  have hga : g a = b := (Finset.mem_filter.1 ha).2
  rw [cnt, fib_eq_filter]
  congr 1
  ext x
  simp only [Finset.mem_filter, mem_fib, Finset.mem_univ, true_and, pr, Prod.mk.injEq,
    Function.comp_apply]
  constructor
  · rintro ⟨⟨hL, _⟩, hf⟩
    exact ⟨hL, hf⟩
  · rintro ⟨hL, hf⟩
    exact ⟨⟨hL, by rw [hf, hga]⟩, hf⟩

/-- **Data processing for conditional entropy.**  Coarsening the reading can
only increase the residual uncertainty about the label. -/
theorem condH_comp_le (g : α → β) : condH L f ≤ condH L (g ∘ f) := by
  classical
  have hsplit : condH L f
      = ∑ b ∈ img (g ∘ f), ∑ a ∈ (img f).filter (fun a => g a = b),
          ∑ l ∈ img L, psi (Fintype.card Ω) (cnt (pr L f) (l, a)) (cnt f a) := by
    rw [condH_eq_sum L f]
    exact (Finset.sum_fiberwise_of_maps_to (maps_img_comp f g) _).symm
  have hcoarse : condH L (g ∘ f)
      = ∑ b ∈ img (g ∘ f), ∑ l ∈ img L,
          psi (Fintype.card Ω) (cnt (pr L (g ∘ f)) (l, b)) (cnt (g ∘ f) b) :=
    condH_eq_sum L (g ∘ f)
  rw [hsplit, hcoarse]
  refine Finset.sum_le_sum fun b _ => ?_
  rw [Finset.sum_comm]
  refine Finset.sum_le_sum fun l _ => ?_
  have hCpos : ∀ a ∈ (img f).filter (fun a => g a = b), 0 < cnt f a := by
    intro a ha
    exact cnt_pos (Finset.mem_filter.1 ha).1
  have h := psi_sum_le (Fintype.card Ω) ((img f).filter (fun a => g a = b))
    (fun a => cnt (pr L f) (l, a)) (fun a => cnt f a) hCpos
  rwa [← cnt_pr_comp L f g l b, ← cnt_comp f g b] at h

/-- **Data processing inequality for trace information.**  Post-processing the
reading of a battery can never raise its capacity.  Equivalently: enlarging a
battery never lowers its capacity. -/
theorem MI_comp_le (g : α → β) : MI L (g ∘ f) ≤ MI L f := by
  simp only [MI]
  linarith [condH_comp_le L f g]

theorem MIb_comp_le (g : α → β) : MIb L (g ∘ f) ≤ MIb L f := by
  rw [MIb, MIb]
  exact (div_le_div_iff_of_pos_right log_two_pos).mpr (MI_comp_le L f g)

end DPI

/-! ## 5. Capacity depends only on the induced partition -/

/-- If two statistics induce the same partition of the population they have the
same entropy. -/
theorem H_eq_of_same_fibers [Nonempty Ω] (f : Ω → α) (g : Ω → β)
    (h : ∀ x y, f x = f y ↔ g x = g y) : H f = H g := by
  classical
  obtain ⟨x₀⟩ := ‹Nonempty Ω›
  have hforward : ∃ u : α → β, g = u ∘ f := by
    refine ⟨fun a => if ha : ∃ x, f x = a then g ha.choose else g x₀, ?_⟩
    funext x
    have hex : ∃ y, f y = f x := ⟨x, rfl⟩
    simp only [Function.comp_apply, dif_pos hex]
    exact ((h hex.choose x).1 hex.choose_spec).symm
  have hback : ∃ v : β → α, f = v ∘ g := by
    refine ⟨fun b => if hb : ∃ x, g x = b then f hb.choose else f x₀, ?_⟩
    funext x
    have hex : ∃ y, g y = g x := ⟨x, rfl⟩
    simp only [Function.comp_apply, dif_pos hex]
    exact ((h hex.choose x).2 hex.choose_spec).symm
  obtain ⟨u, hu⟩ := hforward
  obtain ⟨v, hv⟩ := hback
  refine le_antisymm ?_ ?_
  · calc H f = H (v ∘ g) := by rw [← hv]
      _ ≤ H g := H_comp_le g v
  · calc H g = H (u ∘ f) := by rw [← hu]
      _ ≤ H f := H_comp_le f u

/-- **Faithful recoding.**  The trace information carried by a statistic depends
only on the partition it induces, so a CRT residue vector may be replaced by any
injective numeric code of it without changing the measured capacity. -/
theorem MI_eq_of_same_fibers [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β)
    (h : ∀ x y, f x = f y ↔ g x = g y) : MI L f = MI L g := by
  have hf : H f = H g := H_eq_of_same_fibers f g h
  have hpr : H (pr L f) = H (pr L g) := by
    refine H_eq_of_same_fibers (pr L f) (pr L g) fun x y => ?_
    simp only [pr, Prod.mk.injEq]
    constructor
    · rintro ⟨hL, hfx⟩; exact ⟨hL, (h x y).1 hfx⟩
    · rintro ⟨hL, hgx⟩; exact ⟨hL, (h x y).2 hgx⟩
  rw [MI_eq, MI_eq, hf, hpr]

theorem MIb_eq_of_same_fibers [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β)
    (h : ∀ x y, f x = f y ↔ g x = g y) : MIb L f = MIb L g := by
  rw [MIb, MIb, MI_eq_of_same_fibers L f g h]

/-- **The ceiling is attained.**  A battery whose joint reading pins the label
carries exactly the label entropy. -/
theorem MI_eq_label_entropy_of_determines [Nonempty Ω] (L : Ω → Λ) (f : Ω → α)
    (h : ∀ x y, f x = f y → L x = L y) : MI L f = H L := by
  have hpr : H (pr L f) = H f := by
    refine H_eq_of_same_fibers (pr L f) f fun x y => ?_
    simp only [pr, Prod.mk.injEq]
    constructor
    · rintro ⟨_, hfx⟩; exact hfx
    · intro hfx; exact ⟨h x y hfx, hfx⟩
  rw [MI_eq, hpr]
  ring

theorem MIb_eq_label_entropy_of_determines [Nonempty Ω] (L : Ω → Λ) (f : Ω → α)
    (h : ∀ x y, f x = f y → L x = L y) : MIb L f = Hb L := by
  rw [MIb, Hb, MI_eq_label_entropy_of_determines L f h]

/-! ## 6. Uniform statistics -/

/-- The entropy of a statistic all of whose fibres have the same size `k` is the
logarithm of the number of values taken. -/
theorem H_eq_log_card_img_of_uniform [Nonempty Ω] (f : Ω → α) (k : ℕ) (hk : 0 < k)
    (hcnt : ∀ a ∈ img f, cnt f a = k) : H f = Real.log ((img f).card : ℝ) := by
  classical
  set m := (img f).card with hm
  have hsum : m * k = Fintype.card Ω := by
    have h := sum_cnt f
    rw [Finset.sum_congr rfl hcnt, Finset.sum_const, smul_eq_mul] at h
    exact h
  have hmpos : 0 < m := by
    rw [hm, Finset.card_pos]
    exact ⟨f (Classical.arbitrary Ω), self_mem_img f _⟩
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hmpos
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hNR : ((Fintype.card Ω : ℕ) : ℝ) = (m : ℝ) * (k : ℝ) := by
    rw [← hsum]; push_cast; ring
  have : H f = ∑ _a ∈ img f, phi (Fintype.card Ω) k := by
    rw [H_eq_sum_phi]
    exact Finset.sum_congr rfl fun a ha => by rw [hcnt a ha]
  rw [this, Finset.sum_const, ← hm, nsmul_eq_mul, phi, hNR,
    Real.log_mul (ne_of_gt hmR) (ne_of_gt hkR)]
  field_simp
  ring

/-- The same statement in the form used for batteries on a cube: a statistic all
of whose fibres have size `k` has entropy `log N - log k`. -/
theorem H_eq_log_sub_log_of_uniform [Nonempty Ω] (f : Ω → α) (k : ℕ) (hk : 0 < k)
    (hcnt : ∀ a ∈ img f, cnt f a = k) :
    H f = Real.log (Fintype.card Ω : ℝ) - Real.log (k : ℝ) := by
  classical
  have hsum : (img f).card * k = Fintype.card Ω := by
    have h := sum_cnt f
    rw [Finset.sum_congr rfl hcnt, Finset.sum_const, smul_eq_mul] at h
    exact h
  have hmpos : 0 < (img f).card := by
    rw [Finset.card_pos]
    exact ⟨f (Classical.arbitrary Ω), self_mem_img f _⟩
  have hmR : (0 : ℝ) < ((img f).card : ℝ) := by exact_mod_cast hmpos
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hNR : ((Fintype.card Ω : ℕ) : ℝ) = ((img f).card : ℝ) * (k : ℝ) := by
    rw [← hsum]; push_cast; ring
  rw [H_eq_log_card_img_of_uniform f k hk hcnt, hNR,
    Real.log_mul (ne_of_gt hmR) (ne_of_gt hkR)]
  ring

/-! ## 7. The price of synergy -/

/-- **Incremental capacity bound.**  Adding a statistic `g` to a battery raises
its capacity by at most the entropy of `g` itself.  Together with the CRT
ceiling this is what funds the synergy of a battery: unused code capacity. -/
theorem MI_pair_le_add_H (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    MI L (fun x => (f x, g x)) ≤ MI L f + H g := by
  have hsub : H (fun x => (f x, g x)) ≤ H f + H g := H_pair_le f g
  have hcoarse : H (pr L f) ≤ H (pr L (fun x => (f x, g x))) := by
    have hc : (fun w : Λ × (α × β) => (w.1, w.2.1)) ∘ (pr L fun x => (f x, g x)) = pr L f := rfl
    have := H_comp_le (pr L fun x => (f x, g x)) (fun w : Λ × (α × β) => (w.1, w.2.1))
    rwa [hc] at this
  rw [MI_eq, MI_eq]
  linarith

end BatterySynergy