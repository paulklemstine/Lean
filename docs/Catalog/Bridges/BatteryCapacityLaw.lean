/-
# BATTERY-SCALING, part II: the capacity curve and its label-entropy ceiling

Round-27 #4 (paper 94) measured, for a nested chain of dial sub-batteries
`S₁ ⊆ S₂ ⊆ ⋯ ⊆ S₆` on a population of pairs, the *label capacity curve*

  `I(k) = I(joint reading of Sₖ ; pair label)`,

its additive comparison `Σ_{i ∈ Sₖ} I(dial i ; label)`, the **deficit**
`D(k) = I(k) - Σ marginals`, and a **ceiling** which the curve approached to `99.6%`
at `k = 6`.  This file proves the structural laws behind that table, on top of the
finitary Shannon calculus of `Combinatorics.TraceBatteryEntropy`, the dial battery of
`Combinatorics.TraceBatteryCapacity` and the strong subadditivity of
`Bridges.BatterySubmodularity`.

## Main definitions

* `TraceBattery.MI` — mutual information (nats) of two statistics of a finite population,
  `I(f ; g) = H f + H g - H(f, g)`; `TraceBattery.MIb` is the same in bits.
* `TraceBattery.labelInfo d S L` — the capacity curve: the information the joint reading
  of the sub-battery `S` carries about the label `L`.
* `TraceBattery.deficit d S L` — the additive deficit `I(joint) - Σ marginals`.

## Main results

* `TraceBattery.MI_le_label_entropy` — **the ceiling**: `I(joint ; L) ≤ H L`.  No battery,
  however many dials, can read more about the labels than the labels contain.
* `TraceBattery.MI_eq_entropy_iff_determines` — **the ceiling is attained exactly when the
  battery determines the label**; anything less is strictly below the ceiling.  This is the
  precise content of "the curve saturates at the label-entropy ceiling".
* `TraceBattery.labelInfo_mono` — **the curve never decreases** when dials are added
  (a genuine data-processing statement for *mutual information*, which needs strong
  subadditivity, not just the joint-entropy monotonicity of part I).
* `TraceBattery.MI_pair_ge_add_of_independent` — **the synergy law**: if two readings are
  statistically independent in the population (the CRT/coprime-conductor situation), their
  joint information about the label is at least the sum of the two marginals.
* `TraceBattery.deficit_mono_of_independent` — **H1, in guarded form**: along a nested chain
  in which each new dial is independent of the previous joint reading, the deficit grows
  monotonically.
* `TraceBattery.deficit_neg_of_duplicate` and `TraceBattery.exists_negative_deficit` —
  **the boundary of H1**: monotone growth of the deficit is *not* a universal law.  A battery
  with a repeated dial has a strictly negative deficit, so the independence hypothesis above
  cannot be dropped.
-/
import Mathlib
import Combinatorics.TraceBatteryCapacity
import Bridges.BatterySubmodularity

namespace TraceBattery

open Finset

variable {Ω : Type*} [Fintype Ω] {α β γ : Type*}

/-! ## 1. Mutual information of two statistics -/

/-- The **mutual information** (in nats) of two statistics of a finite population. -/
noncomputable def MI (f : Ω → α) (g : Ω → β) : ℝ :=
  H f + H g - H (fun x => (f x, g x))

/-- Mutual information in bits. -/
noncomputable def MIb (f : Ω → α) (g : Ω → β) : ℝ := MI f g / Real.log 2

/-- Swapping the two coordinates of a pair statistic does not change its entropy. -/
theorem H_pair_swap (f : Ω → α) (g : Ω → β) :
    H (fun x => (g x, f x)) = H (fun x => (f x, g x)) := by
  have hfun : (fun x => (g x, f x)) = Prod.swap ∘ (fun x => (f x, g x)) := rfl
  rw [hfun]
  exact H_comp_eq_of_injective _ Prod.swap_injective

theorem MI_comm (f : Ω → α) (g : Ω → β) : MI f g = MI g f := by
  rw [MI, MI, H_pair_swap f g]
  ring

/-- Mutual information is non-negative: this is subadditivity of the entropy. -/
theorem MI_nonneg (f : Ω → α) (g : Ω → β) : 0 ≤ MI f g := by
  have := H_pair_le f g
  rw [MI]
  linarith

/-- A pair statistic is at least as informative as either coordinate. -/
theorem H_le_H_pair (f : Ω → α) (g : Ω → β) : H f ≤ H (fun x => (f x, g x)) := by
  have hfun : f = Prod.fst ∘ (fun x => (f x, g x)) := rfl
  calc H f = H (Prod.fst ∘ (fun x => (f x, g x))) := by rw [← hfun]
    _ ≤ H (fun x => (f x, g x)) := H_comp_le _ _

/-- **The ceiling.**  A battery can never learn more about the labels than the labels
themselves contain: `I(f ; L) ≤ H L`. -/
theorem MI_le_label_entropy (f : Ω → α) (L : Ω → β) : MI f L ≤ H L := by
  rw [MI]
  linarith [H_le_H_pair f L]

/-- The ceiling gap is exactly the conditional entropy `H(L | f) = H(f, L) - H f`. -/
theorem ceiling_gap_eq_cond (f : Ω → α) (L : Ω → β) :
    H L - MI f L = H (fun x => (f x, L x)) - H f := by
  rw [MI]; ring

/-! ## 2. Saturation: the ceiling is attained exactly by determination -/

/-- A constant statistic carries no information. -/
theorem H_const_eq_zero [Nonempty Ω] (c : α) : H (fun _ : Ω => c) = 0 := by
  classical
  have himg : img (fun _ : Ω => c) = {c} := by
    ext a
    simp [mem_img, eq_comm]
  have hcnt : cnt (fun _ : Ω => c) c = Fintype.card Ω := by
    rw [cnt, fib_eq_filter]
    simp [Finset.card_univ]
  rw [H_eq_sum_phi, himg, Finset.sum_singleton, hcnt, phi]
  simp

/-- A statistic that takes two different values has strictly positive entropy. -/
theorem H_pos_of_ne {f : Ω → α} {x y : Ω} (h : f x ≠ f y) : 0 < H f := by
  haveI : Nonempty Ω := ⟨x⟩
  have h1 : H ((fun _ : α => (0 : ℕ)) ∘ f) < H f :=
    H_comp_lt f (fun _ => (0 : ℕ)) rfl h
  have h2 : H ((fun _ : α => (0 : ℕ)) ∘ f) = 0 := H_const_eq_zero (Ω := Ω) (0 : ℕ)
  linarith

/-- If `f` determines `g`, the pair statistic is no more informative than `f` itself. -/
theorem H_pair_eq_left_of_determines {f : Ω → α} {g : Ω → β}
    (hdet : ∀ x y, f x = f y → g x = g y) : H (fun x => (f x, g x)) = H f := by
  classical
  rcases isEmpty_or_nonempty Ω with hΩ | hΩ
  · simp [H, img_eq_empty_of_isEmpty]
  obtain ⟨x₀⟩ := hΩ
  obtain ⟨r, hr⟩ : ∃ r : α → β, ∀ x, g x = r (f x) := by
    refine ⟨fun a => if hx : ∃ x, f x = a then g hx.choose else g x₀, fun x => ?_⟩
    have hx : ∃ y, f y = f x := ⟨x, rfl⟩
    show g x = if hy : ∃ y, f y = f x then g hy.choose else g x₀
    rw [dif_pos hx]
    exact (hdet hx.choose x hx.choose_spec).symm
  rw [← H_pair_swap f g]
  exact H_pair_eq_of_factors hr

/-- If `f` confuses two individuals with different labels, the pair statistic is strictly
more informative than `f`. -/
theorem H_lt_H_pair_of_not_determines {f : Ω → α} {g : Ω → β} {x y : Ω}
    (hf : f x = f y) (hg : g x ≠ g y) : H f < H (fun x => (f x, g x)) := by
  have hfine : (f x, g x) ≠ (f y, g y) := fun hcon => hg (congrArg Prod.snd hcon)
  have h := H_comp_lt (fun x => (f x, g x)) Prod.fst (by simpa using hf) hfine
  simpa [Function.comp_def] using h

/-- **Saturation.**  The capacity curve reaches the label-entropy ceiling exactly when the
reading determines the label; otherwise it stays strictly below. -/
theorem MI_eq_entropy_iff_determines (f : Ω → α) (L : Ω → β) :
    MI f L = H L ↔ ∀ x y, f x = f y → L x = L y := by
  constructor
  · intro heq x y hxy
    by_contra hne
    have hlt : H f < H (fun x => (f x, L x)) := H_lt_H_pair_of_not_determines hxy hne
    rw [MI] at heq
    linarith
  · intro hdet
    rw [MI, H_pair_eq_left_of_determines hdet]
    ring

/-- The strict form: a battery that confuses two differently labelled individuals is
strictly below the ceiling. -/
theorem MI_lt_entropy_of_confuses {f : Ω → α} {L : Ω → β} {x y : Ω}
    (hf : f x = f y) (hL : L x ≠ L y) : MI f L < H L := by
  have hlt : H f < H (fun x => (f x, L x)) := H_lt_H_pair_of_not_determines hf hL
  rw [MI]
  linarith

/-! ## 3. Monotonicity of the capacity curve -/

/-- **Data processing for mutual information.**  If the reading `k` is a function of the
finer reading `k'`, then `k` carries no more label information than `k'`.  This is where
strong subadditivity enters: the corresponding statement for joint *entropy* is elementary,
for mutual information it is not. -/
theorem MI_mono_of_factors {k : Ω → α} {k' : Ω → β} {r : β → α} (hk : ∀ x, k x = r (k' x))
    (L : Ω → γ) : MI k L ≤ MI k' L := by
  have hssa := H_strong_subadditive k k' L
  have h1 : H (fun x => (k x, k' x)) = H k' := H_pair_eq_of_factors hk
  have h2 : H (fun x => ((k x, k' x), L x)) = H (fun x => (k' x, L x)) := by
    have hfun : (fun x => ((k x, k' x), L x))
        = (fun p : β × γ => ((r p.1, p.1), p.2)) ∘ (fun x => (k' x, L x)) := by
      funext x
      simp [hk x]
    rw [hfun]
    refine H_comp_eq_of_injective _ ?_
    rintro ⟨b, c⟩ ⟨b', c'⟩ hpq
    simp only [Prod.mk.injEq] at hpq
    exact Prod.ext hpq.1.2 hpq.2
  rw [h1, h2] at hssa
  rw [MI, MI]
  linarith

/-- Two readings that determine each other carry the same label information. -/
theorem MI_congr_of_factors {k : Ω → α} {k' : Ω → β} {r : β → α} {r' : α → β}
    (hk : ∀ x, k x = r (k' x)) (hk' : ∀ x, k' x = r' (k x)) (L : Ω → γ) :
    MI k L = MI k' L :=
  le_antisymm (MI_mono_of_factors hk L) (MI_mono_of_factors hk' L)

/-! ## 4. The synergy law -/

/-- **Synergy under independence.**  If two readings are statistically independent in the
population — the entropy of the pair is the sum of the entropies, which is exactly what
pairwise coprime conductors give through the CRT — then the joint reading carries at least
the sum of the two marginal informations about the label.  Equivalently: the additive
bookkeeping `Σ marginals` under-reports such a battery. -/
theorem MI_pair_ge_add_of_independent {k₁ : Ω → α} {k₂ : Ω → β} (L : Ω → γ)
    (hind : H (fun x => (k₁ x, k₂ x)) = H k₁ + H k₂) :
    MI k₁ L + MI k₂ L ≤ MI (fun x => (k₁ x, k₂ x)) L := by
  have hssa := H_strong_subadditive L k₁ k₂
  have e1 : H (fun x => ((L x, k₁ x), k₂ x)) = H (fun x => ((k₁ x, k₂ x), L x)) := by
    have hfun : (fun x => ((k₁ x, k₂ x), L x))
        = (fun t : (γ × α) × β => ((t.1.2, t.2), t.1.1)) ∘ (fun x => ((L x, k₁ x), k₂ x)) := by
      funext x
      rfl
    rw [hfun]
    refine (H_comp_eq_of_injective _ ?_).symm
    rintro ⟨⟨c, a⟩, b⟩ ⟨⟨c', a'⟩, b'⟩ hpq
    simp only [Prod.mk.injEq] at hpq
    obtain ⟨⟨ha, hb⟩, hc⟩ := hpq
    simp [ha, hb, hc]
  have e2 : H (fun x => (L x, k₁ x)) = H (fun x => (k₁ x, L x)) := H_pair_swap k₁ L
  have e3 : H (fun x => (L x, k₂ x)) = H (fun x => (k₂ x, L x)) := H_pair_swap k₂ L
  rw [e1, e2, e3] at hssa
  rw [MI, MI, MI, hind]
  linarith

/-! ## 4b. How far below the ceiling: a quantitative saturation bound -/

/-- **Quantitative saturation.**  Suppose the reading `C` needs only an `m`-valued extra
statistic `g` to pin the label down (there is an `r` with `L = r (C, g)`).  Then the capacity
curve is within `log m` nats of the label-entropy ceiling.  With `m = 1` this recovers exact
saturation, and it turns the reported `99.6%` into a statement about how much residual
ambiguity the six-dial battery may still have. -/
theorem gap_le_log_of_disambiguator {m : ℕ} {C : Ω → α} {L : Ω → β} (g : Ω → Fin m)
    {r : α × Fin m → β} (hr : ∀ x, L x = r (C x, g x)) :
    H L - MI C L ≤ Real.log m := by
  have h1 : H (fun x => (C x, L x)) ≤ H (fun x => (C x, g x)) := by
    have hfun : (fun x => (C x, L x))
        = (fun t : α × Fin m => (t.1, r t)) ∘ (fun x => (C x, g x)) := by
      funext x
      simp [hr x]
    rw [hfun]
    exact H_comp_le _ _
  have h2 : H (fun x => (C x, g x)) ≤ H C + H g := H_pair_le C g
  have hcard : ((img g).card : ℝ) ≤ (m : ℝ) := by
    have hle : (img g).card ≤ m := by
      have := Finset.card_le_card (Finset.subset_univ (img g))
      simpa using this
    exact_mod_cast hle
  have h3 : H g ≤ Real.log m := by
    refine (H_le_log_card_img g).trans ?_
    rcases Nat.eq_zero_or_pos (img g).card with h0 | hpos
    · rw [h0]
      simp only [Nat.cast_zero, Real.log_zero]
      rcases Nat.eq_zero_or_pos m with rfl | hm
      · simp
      · exact Real.log_nonneg (by exact_mod_cast hm)
    · exact Real.log_le_log (by exact_mod_cast hpos) hcard
  rw [ceiling_gap_eq_cond C L]
  linarith

/-! ## 5. Dial batteries: the capacity curve, the ceiling and the deficit -/

section Battery

variable {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty Ω]

/-- The **capacity curve** of a sub-battery: the information its joint reading carries
about the label `L`. -/
noncomputable def labelInfo (d : ι → Dial Ω) (S : Finset ι) (L : Ω → γ) : ℝ :=
  MI (joint d S) L

/-- The **additive deficit** of a sub-battery: joint information minus the sum of the
per-dial informations. -/
noncomputable def deficit (d : ι → Dial Ω) (S : Finset ι) (L : Ω → γ) : ℝ :=
  labelInfo d S L - ∑ i ∈ S, MI (d i).read L

omit [Fintype ι] [DecidableEq ι] [Nonempty Ω] in
/-- **The curve never decreases.**  Adding dials to the battery can only increase the
label information. -/
theorem labelInfo_mono (d : ι → Dial Ω) {S T : Finset ι} (h : S ⊆ T) (L : Ω → γ) :
    labelInfo d S L ≤ labelInfo d T L :=
  MI_mono_of_factors (r := restr h) (fun x => congrFun (joint_restrict d h) x) L

omit [Fintype ι] [DecidableEq ι] [Nonempty Ω] in
/-- **The ceiling.**  Every sub-battery, of any size, reads at most the label entropy. -/
theorem labelInfo_le_ceiling (d : ι → Dial Ω) (S : Finset ι) (L : Ω → γ) :
    labelInfo d S L ≤ H L :=
  MI_le_label_entropy _ _

omit [Fintype ι] [DecidableEq ι] [Nonempty Ω] in
/-- **Saturation of the curve**: the ceiling is reached exactly when the joint reading
of the sub-battery determines the label. -/
theorem labelInfo_eq_ceiling_iff (d : ι → Dial Ω) (S : Finset ι) (L : Ω → γ) :
    labelInfo d S L = H L ↔ ∀ x y, joint d S x = joint d S y → L x = L y :=
  MI_eq_entropy_iff_determines _ _

omit [Fintype ι] [DecidableEq ι] [Nonempty Ω] in
/-- **H2: every marginal reproduces its dial of origin.**  The one-dial sub-battery carries
exactly the information of that dial, so the additive bookkeeping of a battery really is the
sum of the individual experiments. -/
theorem labelInfo_singleton (d : ι → Dial Ω) (i : ι) (L : Ω → γ) :
    labelInfo d ({i} : Finset ι) L = MI (d i).read L := by
  refine MI_congr_of_factors (k := joint d ({i} : Finset ι)) (k' := (d i).read)
    (r := fun n : ℕ => fun _ : ↥({i} : Finset ι) => n)
    (r' := fun u : ↥({i} : Finset ι) → ℕ => u ⟨i, Finset.mem_singleton_self i⟩)
    (fun x => ?_) (fun _ => rfl) L
  funext k
  have hk : k.1 = i := Finset.mem_singleton.1 k.2
  simp [joint, hk]

omit [Fintype ι] [DecidableEq ι] [Nonempty Ω] in
/-- The deficit is capped by the gap between the ceiling and the additive bookkeeping. -/
theorem deficit_le_ceiling_gap (d : ι → Dial Ω) (S : Finset ι) (L : Ω → γ) :
    deficit d S L ≤ H L - ∑ i ∈ S, MI (d i).read L := by
  have := labelInfo_le_ceiling d S L
  rw [deficit]
  linarith

omit [Fintype ι] [Nonempty Ω] in
/-- **H1 in guarded form.**  If the new dial `j` is statistically independent of the joint
reading of `S` — the CRT situation of pairwise coprime conductors — then the deficit does
not decrease when `j` is added. -/
theorem deficit_mono_of_independent (d : ι → Dial Ω) (L : Ω → γ) {S : Finset ι} {j : ι}
    (hj : j ∉ S)
    (hind : H (fun x => (joint d S x, (d j).read x)) = H (joint d S) + H (d j).read) :
    deficit d S L ≤ deficit d (insert j S) L := by
  have hsyn : MI (joint d S) L + MI (d j).read L
      ≤ MI (fun x => (joint d S x, (d j).read x)) L :=
    MI_pair_ge_add_of_independent L hind
  have hfac : MI (fun x => (joint d S x, (d j).read x)) L ≤ labelInfo d (insert j S) L := by
    refine MI_mono_of_factors
      (r := fun u : ↥(insert j S) → ℕ =>
        ((fun i : ↥S => u ⟨i.1, Finset.mem_insert_of_mem i.2⟩), u ⟨j, Finset.mem_insert_self j S⟩))
      (fun x => ?_) L
    rfl
  have hsum : ∑ i ∈ insert j S, MI (d i).read L
      = MI (d j).read L + ∑ i ∈ S, MI (d i).read L := Finset.sum_insert hj
  rw [deficit, deficit, hsum, labelInfo]
  linarith

omit [Fintype ι] [Nonempty Ω] in
/-- **Strict growth at the completing dial.**  If the new dial carries no label information on
its own, the old sub-battery still confuses two differently labelled individuals, and the
enlarged sub-battery determines the label, then the deficit grows *strictly*: the whole of the
new information is synergy. -/
theorem deficit_lt_of_completing (d : ι → Dial Ω) (L : Ω → γ) {S : Finset ι} {j : ι}
    (hj : j ∉ S) (hzero : MI (d j).read L = 0)
    (hcomplete : ∀ x y, joint d (insert j S) x = joint d (insert j S) y → L x = L y)
    {x y : Ω} (hconf : joint d S x = joint d S y) (hne : L x ≠ L y) :
    deficit d S L < deficit d (insert j S) L := by
  have h1 : labelInfo d (insert j S) L = H L := (labelInfo_eq_ceiling_iff d _ L).2 hcomplete
  have h2 : labelInfo d S L < H L := MI_lt_entropy_of_confuses hconf hne
  have hsum : ∑ i ∈ insert j S, MI (d i).read L
      = MI (d j).read L + ∑ i ∈ S, MI (d i).read L := Finset.sum_insert hj
  rw [deficit, deficit, hsum, hzero, h1]
  linarith

omit [Fintype ι] [Nonempty Ω] in
/-- **The boundary of H1.**  A battery with a duplicated dial has a strictly negative
deficit: synergy is not automatic, the independence hypothesis is essential. -/
theorem deficit_neg_of_duplicate (d : ι → Dial Ω) (L : Ω → γ) {i j : ι} (hij : i ≠ j)
    (hd : (d i).read = (d j).read) (hpos : 0 < MI (d i).read L) :
    deficit d {i, j} L < 0 := by
  have hread : ∀ (k : ι), k ∈ ({i, j} : Finset ι) → (d k).read = (d i).read := by
    intro k hk
    rcases Finset.mem_insert.1 hk with rfl | hk'
    · rfl
    · rw [Finset.mem_singleton] at hk'
      subst hk'
      exact hd.symm
  have hjoint : labelInfo d {i, j} L = MI (d i).read L := by
    refine MI_congr_of_factors (k := joint d ({i, j} : Finset ι)) (k' := (d i).read)
      (r := fun n : ℕ => fun _ : ↥({i, j} : Finset ι) => n)
      (r' := fun u : ↥({i, j} : Finset ι) → ℕ => u ⟨i, Finset.mem_insert_self i {j}⟩)
      (fun x => ?_) (fun x => ?_) L
    · funext k
      exact congrFun (hread k.1 k.2) x
    · exact (congrFun (hread i (Finset.mem_insert_self i {j})) x).symm
  have hsum : ∑ k ∈ ({i, j} : Finset ι), MI (d k).read L
      = MI (d i).read L + MI (d j).read L := Finset.sum_pair hij
  have hij' : MI (d j).read L = MI (d i).read L := by rw [hd]
  rw [deficit, hjoint, hsum, hij']
  linarith

end Battery

/-! ## 6. A concrete battery with a negative deficit -/

section Witness

/-- The duplicated one-bit dial on a two-element population. -/
def boolDial : Dial Bool where
  modulus := 2
  modulus_pos := by norm_num
  read := fun x => if x then 1 else 0
  read_lt := by intro x; cases x <;> simp

/-- The two-dial battery whose two dials are the same one-bit reading. -/
def boolBattery : Fin 2 → Dial Bool := fun _ => boolDial

/-- The one-bit dial reads the population faithfully, so it carries the full label
information, which is positive. -/
theorem boolDial_MI_pos : 0 < MI boolDial.read (id : Bool → Bool) := by
  have hdet : ∀ x y : Bool, boolDial.read x = boolDial.read y → id x = id y := by
    decide
  have heq : MI boolDial.read (id : Bool → Bool) = H (id : Bool → Bool) :=
    (MI_eq_entropy_iff_determines _ _).2 hdet
  rw [heq]
  exact H_pos_of_ne (f := (id : Bool → Bool)) (x := true) (y := false) (by decide)

/-- **A concrete counterexample to unguarded H1.**  On the two-element population with the
identity label, the two-dial battery made of one repeated dial has a strictly negative
deficit: `I(joint) = 1 bit` while the additive bookkeeping reports `2 bits`. -/
theorem exists_negative_deficit :
    deficit boolBattery ({0, 1} : Finset (Fin 2)) (id : Bool → Bool) < 0 := by
  refine deficit_neg_of_duplicate boolBattery (id : Bool → Bool) (i := 0) (j := 1)
    (by decide) rfl ?_
  exact boolDial_MI_pos

end Witness

/-! ## 7. Lab notes: consistency of the reported round-27 #4 table

The six measured rows of paper 94 (`I(joint)`, `Σ marginals`, ceiling).  The theorems above
say the curve must be non-decreasing and must stay below the ceiling; the reported numbers
are checked against exactly that, together with the reported `99.6%` saturation and the
monotone deficit. -/

/-- Reported joint informations `I(k)` for `k = 1, …, 6` (bits); `0` outside the table. -/
def reportedI : ℕ → ℝ
  | 1 => 1.0011
  | 2 => 2.1334
  | 3 => 4.0242
  | 4 => 8.2412
  | 5 => 11.5307
  | 6 => 12.7235
  | _ => 0

/-- Reported additive bookkeeping `Σ marginals` for `k = 1, …, 6` (bits). -/
def reportedMarg : ℕ → ℝ
  | 1 => 1.0011
  | 2 => 2.0020
  | 3 => 2.4777
  | 4 => 3.9120
  | 5 => 5.1591
  | 6 => 5.3650
  | _ => 0

/-- Reported ceilings (joint label entropies) for `k = 2, …, 6` (bits). -/
def reportedCeiling : ℕ → ℝ
  | 2 => 4.6063
  | 3 => 6.4947
  | 4 => 9.5434
  | 5 => 11.9557
  | 6 => 12.7726
  | _ => 0

/-- The reported deficit `D(k) = I(k) - Σ marginals(k)`. -/
noncomputable def reportedDeficit (k : ℕ) : ℝ := reportedI k - reportedMarg k

/-- The reported table is consistent with the proved laws: the curve is strictly increasing,
each measured value lies strictly below its ceiling, the deficit `I - Σ` is strictly
increasing, and the six-dial row sits above `99.6%` of its ceiling. -/
theorem round27_table_consistent :
    reportedI 1 < reportedI 2 ∧ reportedI 2 < reportedI 3 ∧ reportedI 3 < reportedI 4 ∧
      reportedI 4 < reportedI 5 ∧ reportedI 5 < reportedI 6 ∧
    reportedI 2 < reportedCeiling 2 ∧ reportedI 3 < reportedCeiling 3 ∧
      reportedI 4 < reportedCeiling 4 ∧ reportedI 5 < reportedCeiling 5 ∧
      reportedI 6 < reportedCeiling 6 ∧
    reportedDeficit 1 < reportedDeficit 2 ∧ reportedDeficit 2 < reportedDeficit 3 ∧
      reportedDeficit 3 < reportedDeficit 4 ∧ reportedDeficit 4 < reportedDeficit 5 ∧
      reportedDeficit 5 < reportedDeficit 6 ∧
    0.996 * reportedCeiling 6 < reportedI 6 := by
  norm_num [reportedI, reportedMarg, reportedCeiling, reportedDeficit]

end TraceBattery