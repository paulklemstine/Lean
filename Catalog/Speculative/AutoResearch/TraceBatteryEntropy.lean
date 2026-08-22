/-
# TRACE-BATTERY, part I: an exact finitary Shannon calculus

Companion to the round-30 experiment `TRACE-BATTERY` (paper 108), whose numeric
claim is that the *joint channel capacity* of a battery of arithmetic "dials"
grows as dials are added, staying under the CRT ceiling `log₂ M` and under the
sample ceiling `log₂ N`.

Mathlib (v4.28.0) has no general Shannon entropy, so this file builds the
finitary theory that the experiment's book-keeping silently uses.  For a finite
population `Ω` and a statistic `f : Ω → α` we define the *empirical entropy*

  `H f = ∑_{a ∈ image f} (nₐ/N) · log (N/nₐ)`,   `nₐ = #f⁻¹(a)`, `N = #Ω`,

i.e. the Shannon entropy of the push-forward of the uniform measure on `Ω`.
Because a dial reading is a *deterministic* function of the individual, this is
exactly the mutual information `I(individual ; reading)` the experiment reports.

The results proved here, all sorry-free:

* `TraceBattery.H_nonneg` — capacities are non-negative.
* `TraceBattery.H_le_log_card_img` — **max-entropy / alphabet ceiling**,
  `H f ≤ log #(image f)`; proved by the Gibbs estimate `log x ≤ x - 1`.
* `TraceBattery.H_le_log_card` — **sparse-table bias**: `H f ≤ log N`.  A
  capacity read off a table with `N` rows can never exceed `log₂ N` bits,
  whatever the alphabet.
* `TraceBattery.H_comp_le` — **data processing**: post-processing a statistic
  cannot increase its capacity, `H (g ∘ f) ≤ H f`.
* `TraceBattery.H_comp_eq_of_injective` — relabelling is free.
* `TraceBattery.H_pos_of_ne` — a statistic separating two individuals has
  strictly positive capacity.
* `TraceBattery.H_pair_le` — **subadditivity** `H⟨f,g⟩ ≤ H f + H g`.

Everything is stated in nats (`Real.log`); the bit-valued capacity
`TraceBattery.Hb = H / log 2` used by the experiment is introduced at the end.
-/
import Mathlib

namespace TraceBattery

open Finset Real

section Entropy

variable {Ω : Type*} [Fintype Ω] {α β : Type*}

open Classical in
/-- The fibre of `f` over `a`, as a finset of the population. -/
noncomputable def fib (f : Ω → α) (a : α) : Finset Ω := univ.filter (fun x => f x = a)

/-- The number of individuals with reading `a`. -/
noncomputable def cnt (f : Ω → α) (a : α) : ℕ := (fib f a).card

open Classical in
/-- The set of readings actually attained. -/
noncomputable def img (f : Ω → α) : Finset α := univ.image f

@[simp] theorem mem_fib {f : Ω → α} {a : α} {x : Ω} : x ∈ fib f a ↔ f x = a := by
  classical simp [fib]

@[simp] theorem mem_img {f : Ω → α} {a : α} : a ∈ img f ↔ ∃ x, f x = a := by
  classical simp [img]

theorem self_mem_img (f : Ω → α) (x : Ω) : f x ∈ img f := mem_img.2 ⟨x, rfl⟩

theorem cnt_pos_of_mem_img {f : Ω → α} {a : α} (ha : a ∈ img f) : 0 < cnt f a := by
  obtain ⟨x, hx⟩ := mem_img.1 ha
  exact Finset.card_pos.2 ⟨x, mem_fib.2 hx⟩

theorem cnt_le_card (f : Ω → α) (a : α) : cnt f a ≤ Fintype.card Ω :=
  Finset.card_le_univ _

theorem sum_cnt (f : Ω → α) : ∑ a ∈ img f, cnt f a = Fintype.card Ω := by
  classical
  have h := Finset.card_eq_sum_card_image f (univ : Finset Ω)
  rw [Fintype.card, h]
  exact Finset.sum_congr rfl fun a _ => rfl

/-- **Empirical Shannon entropy** (in nats) of a statistic `f` on a finite
population: the entropy of the distribution of readings under the uniform
measure.  As readings are deterministic, this is the mutual information between
an individual and its reading. -/
noncomputable def H (f : Ω → α) : ℝ :=
  ∑ a ∈ img f, (cnt f a / (Fintype.card Ω : ℝ)) * Real.log ((Fintype.card Ω : ℝ) / cnt f a)

theorem sum_prob (f : Ω → α) [Nonempty Ω] :
    ∑ a ∈ img f, (cnt f a / (Fintype.card Ω : ℝ)) = 1 := by
  have hN : (0 : ℝ) < Fintype.card Ω := by
    exact_mod_cast Fintype.card_pos
  rw [← Finset.sum_div]
  rw [div_eq_one_iff_eq (ne_of_gt hN)]
  exact_mod_cast sum_cnt f

/-- Capacities are non-negative. -/
theorem H_nonneg (f : Ω → α) : 0 ≤ H f := by
  refine Finset.sum_nonneg fun a ha => ?_
  have hpos : 0 < cnt f a := cnt_pos_of_mem_img ha
  have hle : (cnt f a : ℝ) ≤ (Fintype.card Ω : ℝ) := by exact_mod_cast cnt_le_card f a
  have hcpos : (0 : ℝ) < cnt f a := by exact_mod_cast hpos
  have h1 : (1 : ℝ) ≤ (Fintype.card Ω : ℝ) / cnt f a := (one_le_div hcpos).2 hle
  have : (0 : ℝ) ≤ Real.log ((Fintype.card Ω : ℝ) / cnt f a) := Real.log_nonneg h1
  have hN : (0 : ℝ) ≤ (Fintype.card Ω : ℝ) := Nat.cast_nonneg _
  positivity

/-- **Alphabet ceiling (max entropy).**  A statistic taking `K` distinct values
carries at most `log K` nats.  Proof: the Gibbs estimate `log x ≤ x - 1`
against the uniform distribution on the attained readings. -/
theorem H_le_log_card_img [Nonempty Ω] (f : Ω → α) :
    H f ≤ Real.log ((img f).card : ℝ) := by
  set N : ℝ := (Fintype.card Ω : ℝ) with hNdef
  have hN : (0 : ℝ) < N := by rw [hNdef]; exact_mod_cast Fintype.card_pos
  set K : ℝ := ((img f).card : ℝ) with hKdef
  have hImgNe : (img f).Nonempty := ⟨f (Classical.arbitrary Ω), self_mem_img _ _⟩
  have hKpos : (0 : ℝ) < K := by
    rw [hKdef]; exact_mod_cast Finset.card_pos.2 hImgNe
  have key : ∀ a ∈ img f,
      (cnt f a / N) * Real.log (N / cnt f a)
        ≤ (cnt f a / N) * Real.log K + (1 / K - cnt f a / N) := by
    intro a ha
    have hcpos : (0 : ℝ) < cnt f a := by exact_mod_cast cnt_pos_of_mem_img ha
    have hx : (0 : ℝ) < N / (cnt f a * K) := by positivity
    have hlog : Real.log (N / (cnt f a * K)) ≤ N / (cnt f a * K) - 1 :=
      Real.log_le_sub_one_of_pos hx
    have hsplit : Real.log (N / cnt f a) = Real.log (N / (cnt f a * K)) + Real.log K := by
      rw [← Real.log_mul (by positivity) (by positivity)]
      congr 1
      field_simp
    have hp : (0 : ℝ) ≤ cnt f a / N := by positivity
    have hmul : (cnt f a / N) * Real.log (N / (cnt f a * K))
        ≤ (cnt f a / N) * (N / (cnt f a * K) - 1) :=
      mul_le_mul_of_nonneg_left hlog hp
    have hcalc : (cnt f a / N) * (N / (cnt f a * K) - 1) = 1 / K - cnt f a / N := by
      field_simp
    rw [hsplit, mul_add]
    linarith [hcalc ▸ hmul]
  have hsum := Finset.sum_le_sum key
  have h1 : ∑ a ∈ img f, ((cnt f a : ℝ) / N) = 1 := sum_prob f
  have hrewrite : ∑ a ∈ img f, ((cnt f a / N) * Real.log K + (1 / K - cnt f a / N))
      = Real.log K := by
    rw [Finset.sum_add_distrib, ← Finset.sum_mul, h1, one_mul, Finset.sum_sub_distrib,
      Finset.sum_const, nsmul_eq_mul, h1, ← hKdef]
    field_simp
    ring
  calc H f ≤ ∑ a ∈ img f, ((cnt f a / N) * Real.log K + (1 / K - cnt f a / N)) := hsum
    _ = Real.log K := hrewrite

/-- **Sparse-table bias.**  A capacity estimated from a population of `N`
individuals never exceeds `log N`, no matter how fine the dial alphabet.  This
is the structural reason the measured joint capacities sit well below their CRT
ceilings. -/
theorem H_le_log_card [Nonempty Ω] (f : Ω → α) :
    H f ≤ Real.log (Fintype.card Ω : ℝ) := by
  classical
  refine (H_le_log_card_img f).trans ?_
  have hcard : (img f).card ≤ Fintype.card Ω := by
    have := Finset.card_image_le (s := (univ : Finset Ω)) (f := f)
    rwa [Finset.card_univ] at this
  have hcast : ((img f).card : ℝ) ≤ (Fintype.card Ω : ℝ) := by exact_mod_cast hcard
  refine Real.log_le_log ?_ hcast
  have hne : (img f).Nonempty := ⟨f (Classical.arbitrary Ω), self_mem_img _ _⟩
  exact_mod_cast Finset.card_pos.2 hne

open Classical in
/-- Counting a coarsened statistic fibrewise. -/
theorem cnt_comp (f : Ω → α) (g : α → β) (b : β) :
    cnt (g ∘ f) b = ∑ a ∈ (img f).filter (fun a => g a = b), cnt f a := by
  have hmap : ∀ x ∈ fib (g ∘ f) b, f x ∈ (img f).filter (fun a => g a = b) := by
    intro x hx
    have hgx : g (f x) = b := (mem_fib (f := g ∘ f) (a := b) (x := x)).1 hx
    exact Finset.mem_filter.2 ⟨self_mem_img f x, hgx⟩
  have h := Finset.card_eq_sum_card_fiberwise hmap
  rw [cnt, h]
  refine Finset.sum_congr rfl fun a ha => ?_
  have hga : g a = b := (Finset.mem_filter.1 ha).2
  rw [cnt]
  congr 1
  ext x
  simp only [Finset.mem_filter, mem_fib, Function.comp_apply]
  constructor
  · rintro ⟨-, h⟩; exact h
  · intro h; exact ⟨by rw [h]; exact hga, h⟩

open Classical in
theorem img_comp (f : Ω → α) (g : α → β) : img (g ∘ f) = (img f).image g := by
  ext b
  simp only [mem_img, Finset.mem_image, Function.comp_apply]
  constructor
  · rintro ⟨x, hx⟩; exact ⟨f x, ⟨x, rfl⟩, hx⟩
  · rintro ⟨a, ⟨x, hx⟩, hab⟩; exact ⟨x, by rw [hx, hab]⟩

open Classical in
/-- Fibrewise splitting of the entropy of `f` along a coarsening `g`. -/
theorem H_split_fiberwise [Nonempty Ω] (f : Ω → α) (g : α → β) :
    H f = ∑ b ∈ img (g ∘ f), ∑ a ∈ (img f).filter (fun a => g a = b),
      (cnt f a / (Fintype.card Ω : ℝ)) * Real.log ((Fintype.card Ω : ℝ) / cnt f a) := by
  have hmaps : ∀ a ∈ img f, g a ∈ img (g ∘ f) := by
    intro a ha
    obtain ⟨x, hx⟩ := mem_img.1 ha
    exact mem_img.2 ⟨x, by simp [hx]⟩
  rw [H]
  exact (Finset.sum_fiberwise_of_maps_to hmaps _).symm

open Classical in
/-- The readings in one coarse fibre carry exactly the fibre's probability. -/
theorem sum_prob_fiber (f : Ω → α) (g : α → β) (b : β) :
    ∑ a ∈ (img f).filter (fun a => g a = b), ((cnt f a : ℝ) / (Fintype.card Ω : ℝ))
      = (cnt (g ∘ f) b : ℝ) / (Fintype.card Ω : ℝ) := by
  rw [← Finset.sum_div]
  congr 1
  rw [cnt_comp f g b]
  push_cast
  rfl

open Classical in
/-- A fine fibre is contained in the coarse fibre above it. -/
theorem cnt_le_cnt_comp (f : Ω → α) (g : α → β) {a : α} {b : β}
    (ha : a ∈ img f) (hab : g a = b) : cnt f a ≤ cnt (g ∘ f) b := by
  rw [cnt_comp f g b]
  exact Finset.single_le_sum (f := fun a => cnt f a) (fun _ _ => Nat.zero_le _)
    (Finset.mem_filter.2 ⟨ha, hab⟩)

open Classical in
/-- If a coarse fibre splits into at least two fine fibres, the containment of
`cnt_le_cnt_comp` is strict. -/
theorem cnt_lt_cnt_comp (f : Ω → α) (g : α → β) {a a' : α} {b : β}
    (ha : a ∈ img f) (ha' : a' ∈ img f) (hne : a' ≠ a) (hab : g a = b) (hab' : g a' = b) :
    cnt f a < cnt (g ∘ f) b := by
  rw [cnt_comp f g b]
  refine Finset.single_lt_sum (f := fun a => cnt f a) hne
    (Finset.mem_filter.2 ⟨ha, hab⟩) (Finset.mem_filter.2 ⟨ha', hab'⟩)
    (cnt_pos_of_mem_img ha') (fun k _ _ => Nat.zero_le _)

open Classical in
/-- The coarse term is dominated by the corresponding fine terms. -/
theorem H_comp_term_le [Nonempty Ω] (f : Ω → α) (g : α → β) {b : β} (hb : b ∈ img (g ∘ f)) :
    ((cnt (g ∘ f) b : ℝ) / (Fintype.card Ω : ℝ))
        * Real.log ((Fintype.card Ω : ℝ) / cnt (g ∘ f) b)
      ≤ ∑ a ∈ (img f).filter (fun a => g a = b),
          ((cnt f a : ℝ) / (Fintype.card Ω : ℝ)) * Real.log ((Fintype.card Ω : ℝ) / cnt f a) := by
  have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  have hbpos : (0 : ℝ) < cnt (g ∘ f) b := by exact_mod_cast cnt_pos_of_mem_img hb
  have hle : ∀ a ∈ (img f).filter (fun a => g a = b),
      ((cnt f a : ℝ) / (Fintype.card Ω : ℝ)) * Real.log ((Fintype.card Ω : ℝ) / cnt (g ∘ f) b)
        ≤ ((cnt f a : ℝ) / (Fintype.card Ω : ℝ)) * Real.log ((Fintype.card Ω : ℝ) / cnt f a) := by
    intro a ha
    have hapos : (0 : ℝ) < cnt f a := by
      exact_mod_cast cnt_pos_of_mem_img (Finset.mem_filter.1 ha).1
    have hcle : (cnt f a : ℝ) ≤ (cnt (g ∘ f) b : ℝ) := by
      exact_mod_cast cnt_le_cnt_comp f g (Finset.mem_filter.1 ha).1 (Finset.mem_filter.1 ha).2
    have hlog : Real.log ((Fintype.card Ω : ℝ) / cnt (g ∘ f) b)
        ≤ Real.log ((Fintype.card Ω : ℝ) / cnt f a) :=
      Real.log_le_log (by positivity) (div_le_div_of_nonneg_left (le_of_lt hN) hapos hcle)
    exact mul_le_mul_of_nonneg_left hlog (by positivity)
  refine le_trans (le_of_eq ?_) (Finset.sum_le_sum hle)
  rw [← Finset.sum_mul, sum_prob_fiber f g b]

/-- **Data processing.**  Post-processing a statistic can only destroy
information: `H (g ∘ f) ≤ H f`.  Equivalently, refining a partition of the
population never decreases the empirical entropy.  This is the exact form of
the experiment's "adding a dial cannot lower the joint capacity". -/
theorem H_comp_le [Nonempty Ω] (f : Ω → α) (g : α → β) : H (g ∘ f) ≤ H f := by
  classical
  calc H (g ∘ f)
      = ∑ b ∈ img (g ∘ f), ((cnt (g ∘ f) b : ℝ) / (Fintype.card Ω : ℝ))
          * Real.log ((Fintype.card Ω : ℝ) / cnt (g ∘ f) b) := rfl
    _ ≤ ∑ b ∈ img (g ∘ f), ∑ a ∈ (img f).filter (fun a => g a = b),
          ((cnt f a : ℝ) / (Fintype.card Ω : ℝ))
            * Real.log ((Fintype.card Ω : ℝ) / cnt f a) :=
        Finset.sum_le_sum fun b hb => H_comp_term_le f g hb
    _ = H f := (H_split_fiberwise f g).symm

/-- **Strict data processing.**  If the coarsening `g` genuinely merges two
attained readings of `f` — witnessed by two individuals `x, y` that `f`
separates but `g ∘ f` does not — then information is strictly lost.  Applied to
a dial battery this is the *strict* scaling criterion: a new dial raises the
joint capacity as soon as it separates two individuals that the old
sub-battery confuses. -/
theorem H_comp_lt [Nonempty Ω] (f : Ω → α) (g : α → β) {x y : Ω}
    (hcoarse : g (f x) = g (f y)) (hfine : f x ≠ f y) : H (g ∘ f) < H f := by
  classical
  set b : β := g (f x) with hb
  have hbmem : b ∈ img (g ∘ f) := mem_img.2 ⟨x, rfl⟩
  have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  -- the coarse fibre over `b` splits, so its term is *strictly* dominated
  have hstrict :
      ((cnt (g ∘ f) b : ℝ) / (Fintype.card Ω : ℝ))
          * Real.log ((Fintype.card Ω : ℝ) / cnt (g ∘ f) b)
        < ∑ a ∈ (img f).filter (fun a => g a = b),
            ((cnt f a : ℝ) / (Fintype.card Ω : ℝ))
              * Real.log ((Fintype.card Ω : ℝ) / cnt f a) := by
    have hmemx : f x ∈ (img f).filter (fun a => g a = b) :=
      Finset.mem_filter.2 ⟨self_mem_img f x, rfl⟩
    have hmemy : f y ∈ (img f).filter (fun a => g a = b) :=
      Finset.mem_filter.2 ⟨self_mem_img f y, hcoarse.symm⟩
    have hltx : cnt f (f x) < cnt (g ∘ f) b :=
      cnt_lt_cnt_comp f g (self_mem_img f x) (self_mem_img f y) (Ne.symm hfine) rfl hcoarse.symm
    have hbpos : (0 : ℝ) < cnt (g ∘ f) b := by exact_mod_cast cnt_pos_of_mem_img hbmem
    have hle : ∀ a ∈ (img f).filter (fun a => g a = b),
        ((cnt f a : ℝ) / (Fintype.card Ω : ℝ))
            * Real.log ((Fintype.card Ω : ℝ) / cnt (g ∘ f) b)
          ≤ ((cnt f a : ℝ) / (Fintype.card Ω : ℝ))
            * Real.log ((Fintype.card Ω : ℝ) / cnt f a) := by
      intro a ha
      have hapos : (0 : ℝ) < cnt f a := by
        exact_mod_cast cnt_pos_of_mem_img (Finset.mem_filter.1 ha).1
      have hcle : (cnt f a : ℝ) ≤ (cnt (g ∘ f) b : ℝ) := by
        exact_mod_cast cnt_le_cnt_comp f g (Finset.mem_filter.1 ha).1 (Finset.mem_filter.1 ha).2
      have hlog : Real.log ((Fintype.card Ω : ℝ) / cnt (g ∘ f) b)
          ≤ Real.log ((Fintype.card Ω : ℝ) / cnt f a) :=
        Real.log_le_log (by positivity) (div_le_div_of_nonneg_left (le_of_lt hN) hapos hcle)
      exact mul_le_mul_of_nonneg_left hlog (by positivity)
    have hxpos : (0 : ℝ) < cnt f (f x) := by
      exact_mod_cast cnt_pos_of_mem_img (self_mem_img f x)
    have hltR : (cnt f (f x) : ℝ) < (cnt (g ∘ f) b : ℝ) := by exact_mod_cast hltx
    have hlogx : Real.log ((Fintype.card Ω : ℝ) / cnt (g ∘ f) b)
        < Real.log ((Fintype.card Ω : ℝ) / cnt f (f x)) :=
      Real.log_lt_log (by positivity) (div_lt_div_of_pos_left hN hxpos hltR)
    have hex : ∃ a ∈ (img f).filter (fun a => g a = b),
        ((cnt f a : ℝ) / (Fintype.card Ω : ℝ))
            * Real.log ((Fintype.card Ω : ℝ) / cnt (g ∘ f) b)
          < ((cnt f a : ℝ) / (Fintype.card Ω : ℝ))
            * Real.log ((Fintype.card Ω : ℝ) / cnt f a) := by
      refine ⟨f x, hmemx, ?_⟩
      exact mul_lt_mul_of_pos_left hlogx (by positivity)
    have hsum := Finset.sum_lt_sum hle hex
    refine lt_of_le_of_lt (le_of_eq ?_) hsum
    rw [← Finset.sum_mul, sum_prob_fiber f g b]
  have hsum : ∑ c ∈ img (g ∘ f), ((cnt (g ∘ f) c : ℝ) / (Fintype.card Ω : ℝ))
        * Real.log ((Fintype.card Ω : ℝ) / cnt (g ∘ f) c)
      < ∑ c ∈ img (g ∘ f), ∑ a ∈ (img f).filter (fun a => g a = c),
          ((cnt f a : ℝ) / (Fintype.card Ω : ℝ))
            * Real.log ((Fintype.card Ω : ℝ) / cnt f a) :=
    Finset.sum_lt_sum (fun c hc => H_comp_term_le f g hc) ⟨b, hbmem, hstrict⟩
  calc H (g ∘ f) = ∑ c ∈ img (g ∘ f), ((cnt (g ∘ f) c : ℝ) / (Fintype.card Ω : ℝ))
        * Real.log ((Fintype.card Ω : ℝ) / cnt (g ∘ f) c) := rfl
    _ < _ := hsum
    _ = H f := (H_split_fiberwise f g).symm

/-- Relabelling readings by an injective map changes nothing. -/
theorem H_comp_eq_of_injective (f : Ω → α) {g : α → β} (hg : Function.Injective g) :
    H (g ∘ f) = H f := by
  classical
  have hcnt : ∀ a, cnt (g ∘ f) (g a) = cnt f a := by
    intro a
    have hfib : fib (g ∘ f) (g a) = fib f a := by
      ext x
      rw [mem_fib (f := g ∘ f) (a := g a) (x := x), mem_fib (f := f) (a := a) (x := x)]
      exact ⟨fun h => hg h, fun h => by simp [Function.comp_apply, h]⟩
    rw [cnt, cnt, hfib]
  rw [H, H, img_comp, Finset.sum_image (fun a _ b _ h => hg h)]
  exact Finset.sum_congr rfl fun a _ => by rw [hcnt a]

/-- A statistic that separates two individuals has strictly positive capacity. -/
theorem H_pos_of_ne [Nonempty Ω] {f : Ω → α} {x y : Ω} (hxy : f x ≠ f y) : 0 < H f := by
  classical
  have hmem : f x ∈ img f := self_mem_img _ _
  have hNpos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  have hcpos : (0 : ℝ) < cnt f (f x) := by exact_mod_cast cnt_pos_of_mem_img hmem
  -- the fibre over `f x` misses `y`, hence is a proper subset
  have hlt : cnt f (f x) < Fintype.card Ω := by
    have hsub : fib f (f x) ⊂ (univ : Finset Ω) := by
      refine ⟨Finset.subset_univ _, fun h => ?_⟩
      have : y ∈ fib f (f x) := h (Finset.mem_univ y)
      exact hxy (mem_fib.1 this).symm
    have hlt' := Finset.card_lt_card hsub
    rw [Finset.card_univ] at hlt'
    exact hlt'
  have hlt' : (cnt f (f x) : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hlt
  have hterm : 0 < (cnt f (f x) / (Fintype.card Ω : ℝ)) *
      Real.log ((Fintype.card Ω : ℝ) / cnt f (f x)) := by
    have h1 : (1 : ℝ) < (Fintype.card Ω : ℝ) / cnt f (f x) := (one_lt_div hcpos).2 hlt'
    have := Real.log_pos h1
    positivity
  refine lt_of_lt_of_le hterm ?_
  refine Finset.single_le_sum (f := fun a =>
    (cnt f a / (Fintype.card Ω : ℝ)) * Real.log ((Fintype.card Ω : ℝ) / cnt f a)) ?_ hmem
  intro a ha
  have hpos : 0 < cnt f a := cnt_pos_of_mem_img ha
  have hle : (cnt f a : ℝ) ≤ (Fintype.card Ω : ℝ) := by exact_mod_cast cnt_le_card f a
  have hcp : (0 : ℝ) < cnt f a := by exact_mod_cast hpos
  have h1 : (1 : ℝ) ≤ (Fintype.card Ω : ℝ) / cnt f a := (one_le_div hcp).2 hle
  have := Real.log_nonneg h1
  positivity

end Entropy

section Subadditivity

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {α β : Type*}

omit [Nonempty Ω] in
open Classical in
/-- The marginal of the joint statistic is the individual statistic. -/
theorem sum_cnt_pair_fst (f : Ω → α) (g : Ω → β) (a : α) :
    ∑ c ∈ (img fun x => (f x, g x)).filter (fun c => c.1 = a), cnt (fun x => (f x, g x)) c
      = cnt f a := by
  classical
  have := cnt_comp (fun x => (f x, g x)) Prod.fst a
  simpa using this.symm

/-- **Subadditivity.**  The capacity of a pair of statistics is at most the sum
of the individual capacities: joint dials never carry more than the total of
their per-dial trace informations. -/
theorem H_pair_le (f : Ω → α) (g : Ω → β) :
    H (fun x => (f x, g x)) ≤ H f + H g := by
  classical
  set p : Ω → α × β := fun x => (f x, g x) with hp
  set N : ℝ := (Fintype.card Ω : ℝ) with hNdef
  have hN : (0 : ℝ) < N := by rw [hNdef]; exact_mod_cast Fintype.card_pos
  have hsub : img p ⊆ (img f) ×ˢ (img g) := by
    intro c hc
    obtain ⟨x, hx⟩ := mem_img.1 hc
    subst hx
    refine Finset.mem_product.2 ⟨?_, ?_⟩
    · exact self_mem_img f x
    · exact self_mem_img g x
  -- Gibbs bound term by term against the product distribution
  have key : ∀ c ∈ img p,
      (cnt p c / N) * Real.log (N / cnt p c)
        ≤ (cnt p c / N) * Real.log (N / cnt f c.1)
          + (cnt p c / N) * Real.log (N / cnt g c.2)
          + ((cnt f c.1 : ℝ) * cnt g c.2 / (N * N) - cnt p c / N) := by
    intro c hc
    have hcp : (0 : ℝ) < cnt p c := by exact_mod_cast cnt_pos_of_mem_img hc
    have hf : (0 : ℝ) < cnt f c.1 := by
      obtain ⟨x, hx⟩ := mem_img.1 hc
      exact_mod_cast cnt_pos_of_mem_img (α := α) (f := f) (a := c.1)
        (by rw [← hx]; exact self_mem_img _ _)
    have hg : (0 : ℝ) < cnt g c.2 := by
      obtain ⟨x, hx⟩ := mem_img.1 hc
      exact_mod_cast cnt_pos_of_mem_img (α := β) (f := g) (a := c.2)
        (by rw [← hx]; exact self_mem_img _ _)
    set u : ℝ := (cnt f c.1 : ℝ) * cnt g c.2 / (N * cnt p c) with hu
    have hupos : (0 : ℝ) < u := by rw [hu]; positivity
    have hlog : Real.log u ≤ u - 1 := Real.log_le_sub_one_of_pos hupos
    have hexp : Real.log (N / cnt p c)
        = Real.log (N / cnt f c.1) + Real.log (N / cnt g c.2) + Real.log u := by
      rw [← Real.log_mul (by positivity) (by positivity),
        ← Real.log_mul (by positivity) (by positivity)]
      congr 1
      rw [hu]
      field_simp
    have hmul : (cnt p c / N) * Real.log u ≤ (cnt p c / N) * (u - 1) :=
      mul_le_mul_of_nonneg_left hlog (by positivity)
    have hval : (cnt p c / N) * (u - 1)
        = (cnt f c.1 : ℝ) * cnt g c.2 / (N * N) - cnt p c / N := by
      rw [hu]; field_simp
    rw [hexp, mul_add, mul_add]
    linarith [hmul, hval]
  have hsum := Finset.sum_le_sum key
  -- the three pieces
  have h1 : ∑ c ∈ img p, (cnt p c / N) * Real.log (N / cnt f c.1) = H f := by
    have hmapsto : ∀ c ∈ img p, c.1 ∈ img f := by
      intro c hc
      exact (Finset.mem_product.1 (hsub hc)).1
    rw [← Finset.sum_fiberwise_of_maps_to hmapsto
      (fun c => (cnt p c / N) * Real.log (N / cnt f c.1))]
    refine Finset.sum_congr rfl fun a ha => ?_
    have hstep : ∀ c ∈ (img p).filter (fun c => c.1 = a),
        (cnt p c / N) * Real.log (N / cnt f c.1)
          = (cnt p c / N) * Real.log (N / cnt f a) := by
      intro c hc; rw [(Finset.mem_filter.1 hc).2]
    rw [Finset.sum_congr rfl hstep, ← Finset.sum_mul, ← Finset.sum_div]
    have hm : ∑ c ∈ (img p).filter (fun c => c.1 = a), (cnt p c : ℝ) = (cnt f a : ℝ) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (sum_cnt_pair_fst f g a)
    rw [hm, hNdef]
  have h2 : ∑ c ∈ img p, (cnt p c / N) * Real.log (N / cnt g c.2) = H g := by
    have hmapsto : ∀ c ∈ img p, c.2 ∈ img g := by
      intro c hc
      exact (Finset.mem_product.1 (hsub hc)).2
    rw [← Finset.sum_fiberwise_of_maps_to hmapsto
      (fun c => (cnt p c / N) * Real.log (N / cnt g c.2))]
    refine Finset.sum_congr rfl fun b hb => ?_
    have hstep : ∀ c ∈ (img p).filter (fun c => c.2 = b),
        (cnt p c / N) * Real.log (N / cnt g c.2)
          = (cnt p c / N) * Real.log (N / cnt g b) := by
      intro c hc; rw [(Finset.mem_filter.1 hc).2]
    rw [Finset.sum_congr rfl hstep, ← Finset.sum_mul, ← Finset.sum_div]
    have hnat : ∑ c ∈ (img p).filter (fun c => c.2 = b), cnt p c = cnt g b := by
      have hcc := cnt_comp (fun x => (f x, g x)) Prod.snd b
      simpa using hcc.symm
    have hm : ∑ c ∈ (img p).filter (fun c => c.2 = b), (cnt p c : ℝ) = (cnt g b : ℝ) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hnat
    rw [hm, hNdef]
  have h3 : ∑ c ∈ img p, ((cnt f c.1 : ℝ) * cnt g c.2 / (N * N) - cnt p c / N) ≤ 0 := by
    have hprob : ∑ c ∈ img p, (cnt p c / N) = 1 := sum_prob p
    have hbig : ∑ c ∈ img p, ((cnt f c.1 : ℝ) * cnt g c.2 / (N * N))
        ≤ ∑ c ∈ (img f) ×ˢ (img g), ((cnt f c.1 : ℝ) * cnt g c.2 / (N * N)) := by
      refine Finset.sum_le_sum_of_subset_of_nonneg hsub ?_
      intro c _ _
      positivity
    have hfull : ∑ c ∈ (img f) ×ˢ (img g), ((cnt f c.1 : ℝ) * cnt g c.2 / (N * N)) = 1 := by
      rw [Finset.sum_product]
      have : ∀ a ∈ img f, ∑ b ∈ img g, ((cnt f a : ℝ) * cnt g b / (N * N))
          = (cnt f a / N) * ∑ b ∈ img g, (cnt g b / N) := by
        intro a _
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl fun b _ => by ring
      rw [Finset.sum_congr rfl this, sum_prob g]
      simpa using sum_prob f
    rw [Finset.sum_sub_distrib, hprob]
    linarith [hbig, hfull ▸ hbig]
  have hexpand : ∑ c ∈ img p, ((cnt p c / N) * Real.log (N / cnt f c.1)
      + (cnt p c / N) * Real.log (N / cnt g c.2)
      + ((cnt f c.1 : ℝ) * cnt g c.2 / (N * N) - cnt p c / N))
      = H f + H g + ∑ c ∈ img p, ((cnt f c.1 : ℝ) * cnt g c.2 / (N * N) - cnt p c / N) := by
    rw [Finset.sum_add_distrib, Finset.sum_add_distrib, h1, h2]
  calc H p ≤ _ := hsum
    _ = H f + H g + ∑ c ∈ img p, ((cnt f c.1 : ℝ) * cnt g c.2 / (N * N) - cnt p c / N) :=
        hexpand
    _ ≤ H f + H g := by linarith [h3]

end Subadditivity

section Bits

variable {Ω : Type*} [Fintype Ω] {α : Type*}

/-- Capacity measured in **bits**, the unit used in the experiment's tables. -/
noncomputable def Hb (f : Ω → α) : ℝ := H f / Real.log 2

theorem log_two_pos : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)

theorem Hb_nonneg (f : Ω → α) : 0 ≤ Hb f :=
  div_nonneg (H_nonneg f) (le_of_lt log_two_pos)

theorem Hb_le_logb_card_img [Nonempty Ω] (f : Ω → α) :
    Hb f ≤ Real.logb 2 ((img f).card : ℝ) := by
  rw [Hb, Real.logb]
  gcongr
  exact H_le_log_card_img f

end Bits

end TraceBattery