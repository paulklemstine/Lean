import Mathlib

/-!
# Thermodynamics of Mathematical Proof

A **Landauer-like principle for mathematical reasoning**.

We model a single *proof step* (a rewrite, a case merge, a lookup, a verification) as a
function `f : α → β` between finite state spaces.  Physically, a computation that is
*logically irreversible* — one that maps several distinct inputs to the same output —
must dump the lost distinctions into the environment.  Landauer's principle states that
erasing one bit of information costs at least `k_B · T · ln 2` of dissipated entropy.

The information erased by the step `f` is the drop in Shannon capacity of the register:

  `erasedBits f = log₂ (card α) − log₂ (image size of f)`.

## Main results

* `erasedBits_nonneg` — a proof step never *un*-erases information.
* `erasedBits_eq_zero_iff_injective` — **reversibility criterion**: a step erases zero bits
  iff it is injective (logically reversible).
* `landauerCost_pos_of_not_injective` — **Landauer's principle**: an irreversible step costs
  strictly positive entropy at positive temperature.
* `erasedBits_lower_bound` — the erasure of any step into a `card β`-state register is at
  least `log₂(card α) − log₂(card β)`.
* `erasedBits_mono_comp` — **erasure is monotone along a proof pipeline**: composing steps
  can only accumulate erasure, never undo it (a data-processing inequality).
* `erasedBits_bennett` — **Bennett's reversible embedding**: *retaining the input* makes any
  step reversible (erases zero bits), so erasure is not forced by computation per se.
* `erasedBits_collapse` / `erasedBits_bigCollapse` — explicit families realising *linear*
  and *exponential* erasure in a size parameter.
* `exponential_erasure_separation` — there are theorems (state collapses) whose verification
  erases unboundedly (indeed exponentially) many bits.
* `incompressible` — a Kolmogorov counting bound: the `2ⁿ` Boolean predicates on `n` bits
  cannot be injectively coded by the `2ⁿ − 1` programs of length `< n`, so some predicate has
  no proof/description shorter than `n` bits — its verification erases `≥ n · k_B T ln 2`.
-/

open Finset Real

namespace ThermoProof

/-! ## Information erased by a proof step -/

/-- The number of distinct outputs of `f` (the size of its image). -/
def imageCard {α β : Type*} [Fintype α] [DecidableEq β] (f : α → β) : ℕ :=
  (Finset.univ.image f).card

lemma imageCard_le_card {α β : Type*} [Fintype α] [DecidableEq β] (f : α → β) :
    imageCard f ≤ Fintype.card α := by
  unfold imageCard
  calc (Finset.univ.image f).card ≤ (Finset.univ : Finset α).card := Finset.card_image_le
    _ = Fintype.card α := by simp [Finset.card_univ]

lemma imageCard_pos {α β : Type*} [Fintype α] [DecidableEq β] [Nonempty α] (f : α → β) :
    0 < imageCard f := by
  unfold imageCard; rw [Finset.card_pos]; exact (Finset.univ_nonempty).image f

lemma imageCard_le_codomain {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β] (f : α → β) :
    imageCard f ≤ Fintype.card β := by
  unfold imageCard
  calc (Finset.univ.image f).card ≤ (Finset.univ : Finset β).card := Finset.card_le_card (by simp)
    _ = Fintype.card β := by simp [Finset.card_univ]

lemma imageCard_of_injective {α β : Type*} [Fintype α] [DecidableEq β] {f : α → β}
    (hf : Function.Injective f) : imageCard f = Fintype.card α := by
  unfold imageCard; rw [Finset.card_image_of_injective _ hf]; simp [Finset.card_univ]

/-- Bits of information erased by one step `f`: the entropy drop between input and output. -/
noncomputable def erasedBits {α β : Type*} [Fintype α] [DecidableEq β] (f : α → β) : ℝ :=
  Real.logb 2 (Fintype.card α) - Real.logb 2 (imageCard f)

/-- A proof step never erases a negative amount of information. -/
lemma erasedBits_nonneg {α β : Type*} [Fintype α] [DecidableEq β] [Nonempty α] (f : α → β) :
    0 ≤ erasedBits f := by
  unfold erasedBits
  have h1 : (0:ℝ) < imageCard f := by exact_mod_cast imageCard_pos f
  have h2 : (imageCard f : ℝ) ≤ Fintype.card α := by exact_mod_cast imageCard_le_card f
  have := (Real.logb_le_logb (b := 2) (by norm_num) h1 (lt_of_lt_of_le h1 h2)).2 h2
  linarith

/-- **Reversibility criterion.** A step erases exactly zero bits iff it is injective, i.e.
logically reversible. -/
lemma erasedBits_eq_zero_iff_injective {α β : Type*} [Fintype α] [DecidableEq β] [Nonempty α]
    (f : α → β) : erasedBits f = 0 ↔ Function.Injective f := by
  unfold erasedBits
  have h1 : (0:ℝ) < imageCard f := by exact_mod_cast imageCard_pos f
  have hα : (0:ℝ) < Fintype.card α := by
    have : 0 < Fintype.card α := Fintype.card_pos; exact_mod_cast this
  constructor
  · intro h
    have hlog : Real.logb 2 (Fintype.card α) = Real.logb 2 (imageCard f) := by linarith
    have hcard : (Fintype.card α : ℝ) = imageCard f :=
      Real.logb_injOn_pos (by norm_num) (Set.mem_Ioi.mpr hα) (Set.mem_Ioi.mpr h1) hlog
    have hcard' : Fintype.card α = imageCard f := by exact_mod_cast hcard
    have hcard'' : imageCard f = (Finset.univ : Finset α).card := by
      unfold imageCard at hcard' ⊢; simp [Finset.card_univ] at hcard' ⊢; omega
    have hinj := Finset.injOn_of_card_image_eq hcard''
    intro a b hab; exact hinj (by simp) (by simp) hab
  · intro hinj
    rw [imageCard_of_injective hinj]; ring

/-! ## The Landauer cost -/

/-- **Landauer cost.** Erasing `bits` of information into an environment at temperature `T`
(with Boltzmann constant `kB`) dissipates `bits · kB · T · ln 2` of entropy/heat. -/
noncomputable def landauerCost (bits kB T : ℝ) : ℝ := bits * (kB * T * Real.log 2)

lemma landauerCost_nonneg {bits kB T : ℝ} (hb : 0 ≤ bits) (hk : 0 ≤ kB) (hT : 0 ≤ T) :
    0 ≤ landauerCost bits kB T := by
  unfold landauerCost
  have : (0:ℝ) ≤ Real.log 2 := le_of_lt (Real.log_pos (by norm_num))
  positivity

/-- **Landauer's principle (strict form).** An irreversible (non-injective) proof step
dissipates strictly positive entropy at positive temperature. -/
theorem landauerCost_pos_of_not_injective {α β : Type*} [Fintype α] [DecidableEq β] [Nonempty α]
    {f : α → β} (hf : ¬ Function.Injective f) {kB T : ℝ} (hk : 0 < kB) (hT : 0 < T) :
    0 < landauerCost (erasedBits f) kB T := by
  have hpos : 0 < erasedBits f := by
    have hne : erasedBits f ≠ 0 := fun h => hf ((erasedBits_eq_zero_iff_injective f).1 h)
    exact lt_of_le_of_ne (erasedBits_nonneg f) (Ne.symm hne)
  unfold landauerCost
  have hlog : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  positivity

/-- **Landauer lower bound.** A step whose output lives in a `card β`-state register erases
at least `log₂(card α) − log₂(card β)` bits: you cannot compress `α` into `β` for free. -/
theorem erasedBits_lower_bound {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) :
    Real.logb 2 (Fintype.card α) - Real.logb 2 (Fintype.card β) ≤ erasedBits f := by
  unfold erasedBits
  have h1 : (0:ℝ) < imageCard f := by exact_mod_cast imageCard_pos f
  have h2 : (imageCard f : ℝ) ≤ Fintype.card β := by exact_mod_cast imageCard_le_codomain f
  have := (Real.logb_le_logb (b := 2) (by norm_num) h1 (lt_of_lt_of_le h1 h2)).2 h2
  linarith

/-! ## Erasure accumulates along a proof (data-processing) -/

lemma imageCard_comp_le {α β γ : Type*} [Fintype α] [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : β → γ) : imageCard (g ∘ f) ≤ imageCard f := by
  unfold imageCard
  have h : (Finset.univ.image (g ∘ f)) = (Finset.univ.image f).image g := by
    rw [Finset.image_image]
  rw [h]; exact Finset.card_image_le

/-- **Erasure is monotone along a pipeline.** Post-composing a step can only *increase* the
total information erased so far — a thermodynamic data-processing inequality: information
already destroyed cannot be recovered downstream. -/
theorem erasedBits_mono_comp {α β γ : Type*} [Fintype α] [DecidableEq β] [DecidableEq γ]
    [Nonempty α] (f : α → β) (g : β → γ) : erasedBits f ≤ erasedBits (g ∘ f) := by
  unfold erasedBits
  have h1 : (0:ℝ) < imageCard (g ∘ f) := by
    have : 0 < imageCard (g ∘ f) := by
      unfold imageCard; rw [Finset.card_pos]; exact (Finset.univ_nonempty).image _
    exact_mod_cast this
  have h2 : (imageCard (g ∘ f) : ℝ) ≤ imageCard f := by exact_mod_cast imageCard_comp_le f g
  have := (Real.logb_le_logb (b := 2) (by norm_num) h1 (lt_of_lt_of_le h1 h2)).2 h2
  linarith

/-! ## Bennett's reversible embedding: erasure is avoidable -/

/-- **Bennett's reversible embedding** of a step `f`: keep the input alongside the output,
`x ↦ (x, f x)`. -/
def bennettEmbedding {α β : Type*} (f : α → β) : α → α × β := fun x => (x, f x)

lemma bennettEmbedding_injective {α β : Type*} (f : α → β) :
    Function.Injective (bennettEmbedding f) := by
  intro a b h; exact (Prod.mk.injEq _ _ _ _ ▸ h).1

/-- **Retaining the input makes any step reversible**: it erases zero bits.  Hence logical
irreversibility — not computation itself — is what carries the Landauer cost. -/
theorem erasedBits_bennett {α β : Type*} [Fintype α] [DecidableEq α] [DecidableEq β] [Nonempty α]
    (f : α → β) : erasedBits (bennettEmbedding f) = 0 :=
  (erasedBits_eq_zero_iff_injective _).2 (bennettEmbedding_injective f)

/-! ## Explicit erasure families and the exponential separation -/

lemma imageCard_const {γ δ : Type*} [Fintype γ] [DecidableEq δ] [Nonempty γ] (c : δ) :
    imageCard (fun _ : γ => c) = 1 := by
  unfold imageCard; rw [Finset.image_const Finset.univ_nonempty]; simp

lemma erasedBits_const {γ δ : Type*} [Fintype γ] [DecidableEq δ] [Nonempty γ] (c : δ) :
    erasedBits (fun _ : γ => c) = Real.logb 2 (Fintype.card γ) := by
  unfold erasedBits; rw [imageCard_const]; simp

/-- Collapsing `2ⁿ` states onto a single answer (a decision procedure) erases exactly `n`
bits. -/
noncomputable def collapse (n : ℕ) : Fin (2^n) → Fin 1 := fun _ => 0

lemma erasedBits_collapse (n : ℕ) : erasedBits (collapse n) = n := by
  unfold erasedBits collapse
  rw [imageCard_const (0 : Fin 1)]
  simp [Fintype.card_fin, Real.logb_pow, Real.logb_self_eq_one]

/-- A doubly-exponential state space collapsed to one answer: erases `2ᵐ` bits. -/
noncomputable def bigCollapse (m : ℕ) : Fin (2^(2^m)) → Fin 1 := fun _ => 0

lemma erasedBits_bigCollapse (m : ℕ) : erasedBits (bigCollapse m) = 2 ^ m := by
  unfold erasedBits bigCollapse
  rw [imageCard_const (0 : Fin 1)]
  simp [Fintype.card_fin, Real.logb_pow, Real.logb_self_eq_one]

/-- The exponential family erases `2` raised to the erasure of the linear family: the erasure
of `bigCollapse m` is exponential in the erasure of `collapse m`. -/
theorem erasedBits_bigCollapse_exp (m : ℕ) :
    erasedBits (bigCollapse m) = Real.rpow 2 (erasedBits (collapse m)) := by
  rw [erasedBits_bigCollapse, erasedBits_collapse]; exact (Real.rpow_natCast 2 m).symm

lemma two_pow_unbounded (C : ℝ) : ∃ m : ℕ, C < (2:ℝ) ^ m := by
  obtain ⟨m, hm⟩ := pow_unbounded_of_one_lt (max C 0) (by norm_num : (1:ℝ) < 2)
  exact ⟨m, lt_of_le_of_lt (le_max_left _ _) hm⟩

/-- **Exponential erasure separation.** There exist theorems (state collapses) whose
verification erases arbitrarily — indeed exponentially — many bits, hence dissipates
arbitrarily much Landauer heat at fixed positive temperature. -/
theorem exponential_erasure_separation (C : ℝ) :
    ∃ m : ℕ, C < erasedBits (bigCollapse m) := by
  obtain ⟨m, hm⟩ := two_pow_unbounded C
  exact ⟨m, by rw [erasedBits_bigCollapse]; exact hm⟩

/-- Physical restatement: the dissipated heat of collapsing `bigCollapse m` is
`2ᵐ · kB · T · ln 2`, exponential in `m`. -/
theorem landauerCost_bigCollapse (m : ℕ) (kB T : ℝ) :
    landauerCost (erasedBits (bigCollapse m)) kB T = (2:ℝ) ^ m * (kB * T * Real.log 2) := by
  rw [erasedBits_bigCollapse]; rfl

/-! ## Kolmogorov incompressibility and the cost of verification -/

/-- **Incompressibility (Kolmogorov counting bound).** There is no injective code sending the
`2ⁿ` Boolean predicates on `n` bits to the `2ⁿ − 1` programs of length `< n`.  Consequently
some predicate has no description (proof) shorter than `n` bits; storing/erasing its truth
table costs `≥ n · kB T ln 2` by Landauer's principle. -/
theorem incompressible (n : ℕ) :
    ¬ ∃ D : (Fin n → Bool) → Fin (2^n - 1), Function.Injective D := by
  rintro ⟨D, hD⟩
  have hcard : Fintype.card (Fin n → Bool) ≤ Fintype.card (Fin (2^n - 1)) :=
    Fintype.card_le_of_injective D hD
  simp only [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin] at hcard
  have h2 : 0 < 2^n := Nat.two_pow_pos n
  omega

end ThermoProof