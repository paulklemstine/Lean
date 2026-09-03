import Mathlib
import Combinatorics.OctaveShiftLaw

/-!
# The real-parameter scale flow on knee chains (NET-66, continuous form)

`Combinatorics.OctaveShiftLaw` establishes the *discrete* octave shift law: the
scale × context knee table is one chain translated by one octave per scale
doubling, and scale acts on chains through the additive monoid `(ℕ, +)`:

`shift K s = fun j => K (j - s)`   (truncated subtraction).

This file extends the action to a **real scale parameter**.  The observation that
makes the extension canonical is that the clamp `max (j - σ, 0)` occurring in the
informal law `k*(σ, j) = K₀((j − σ)⁺)` is *exactly* truncated subtraction in the
ordered-subtraction monoid `ℝ≥0`.  So the discrete picture is reproduced verbatim
one universe up:

* `RChain := ℝ≥0 → ℝ` — a *real knee profile*, `K₀ x` = budget at `x` octaves of
  context headroom above the model's base context.
* `rshift K s = fun t => K (t - s)` — the **scale flow**, `t - s` truncated in `ℝ≥0`.

What is proved:

* `rshift_zero`, `rshift_add` — the flow is an action of the additive monoid
  `(ℝ≥0, +)`; `flowAction` packages it as a genuine `MulAction` instance for
  `Multiplicative ℝ≥0`, so "the shift action extends from `(ℕ,+)` to `(ℝ≥0,+)`"
  is a theorem about a structure, not a slogan.
* `rshift_natCast` and `rshift_restricts` — the flow **restricts** to the discrete
  action on the measured integer cells: at integer scale and integer octave the
  real table reproduces `Combinatorics.OctaveShiftLaw.shift` exactly.
* `ScaleFlow` + `ScaleFlow.eq_rshift` — the **continuous rigidity theorem**: the
  real exchange law `F(σ+a, t+a) = F(σ, t)` together with base-context inertia
  `F(σ, 0) = F(0, 0)` forces `F σ = rshift (F 0) σ` for *all* real σ.  This is the
  exact analogue of `ScaleFamily.eq_shift`, with the induction on scale steps
  replaced by a single translation.
* `ScaleFlow.antitone_scale`, `ScaleFlow.no_flattening` — the structural
  refutations of "scale amplifies sensitivity" and "scale flattens the context
  axis" survive verbatim in the continuous setting.
* `ScaleFlow.abs_sub_le_of_slope` — a **Lipschitz transport bound**: if the base
  profile rises at rate at most `δ` keys per octave, then moving the scale
  parameter by `h` moves every knee by at most `δ·h`.  Deployment tables are
  therefore continuous — indeed Lipschitz — in scale.
* `rshift_injective_of_strictMono` — real-rate identifiability: a strictly
  increasing profile pins the scale parameter, so the continuous ladder does not
  introduce gauge freedom.
-/

namespace Tropical.ScaleFlowCore

open Combinatorics.OctaveShiftLaw NNReal

/-! ## Real knee profiles and the scale flow -/

/-- A **real knee profile**: `K x` is the key budget required at `x` octaves of
context *above* the model's own base context.  The domain is `ℝ≥0` because a model
is never asked for less than its base context: the chain is clamped, not
extrapolated, below `x = 0`. -/
abbrev RChain := ℝ≥0 → ℝ

/-- The **scale flow**: shifting a real profile by a real scale parameter `s`.
Truncated subtraction in `ℝ≥0` *is* the clamp `max (t - s) 0`, so
`rshift K s t = K ((t - s)⁺)`. -/
def rshift (K : RChain) (s : ℝ≥0) : RChain := fun t => K (t - s)

@[simp] theorem rshift_apply (K : RChain) (s t : ℝ≥0) : rshift K s t = K (t - s) := rfl

@[simp] theorem rshift_zero (K : RChain) : rshift K 0 = K := by
  funext t; simp [rshift]

/-- The clamp made explicit: the real table is `K₀ (max (t − σ) 0)`. -/
theorem rshift_eq_max (K : RChain) (s t : ℝ≥0) :
    rshift K s t = K ⟨max ((t : ℝ) - s) 0, le_max_right _ _⟩ := by
  simp only [rshift]
  congr 1

/-- **Scale acts as the additive monoid `(ℝ≥0, +)`.**  This is the continuous
extension of `Combinatorics.OctaveShiftLaw.shift_add`. -/
theorem rshift_add (K : RChain) (a b : ℝ≥0) : rshift (rshift K a) b = rshift K (a + b) := by
  funext t
  simp only [rshift, tsub_tsub]
  rw [add_comm]

/-- **The continuous exchange law.**  Buying `a` octaves of scale buys exactly `a`
octaves of context, for *every real* `a`. -/
theorem rshift_exchange (K : RChain) (s t a : ℝ≥0) :
    rshift K (s + a) (t + a) = rshift K s t := by
  simp [rshift, add_tsub_add_eq_tsub_right]

/-- **The boundary law.**  At or below its base context the profile is clamped. -/
theorem rshift_boundary (K : RChain) {s t : ℝ≥0} (h : t ≤ s) : rshift K s t = K 0 := by
  simp [rshift, tsub_eq_zero_of_le h]

theorem rshift_monotone {K : RChain} (hK : Monotone K) (s : ℝ≥0) : Monotone (rshift K s) :=
  fun _ _ h => hK (tsub_le_tsub_right h s)

theorem rshift_antitone_scale {K : RChain} (hK : Monotone K) (t : ℝ≥0) :
    Antitone fun s => rshift K s t :=
  fun _ _ h => hK (tsub_le_tsub_left h t)

/-- The flow as a genuine monoid action of `(ℝ≥0, +)` on real knee profiles. -/
instance flowAction : MulAction (Multiplicative ℝ≥0) RChain where
  smul s K := rshift K (Multiplicative.toAdd s)
  one_smul K := rshift_zero K
  mul_smul a b K := by
    show rshift K (Multiplicative.toAdd (a * b))
        = rshift (rshift K (Multiplicative.toAdd b)) (Multiplicative.toAdd a)
    rw [rshift_add]
    congr 1
    exact add_comm _ _

theorem smul_def (s : Multiplicative ℝ≥0) (K : RChain) :
    s • K = rshift K (Multiplicative.toAdd s) := rfl

/-! ## Restriction to the measured integer cells -/

/-- On integer scale and integer context the flow **is** the discrete octave
shift: `rshift (K ∘ cast) s (j : ℝ≥0) = shift K s j`. -/
theorem natCast_tsub (s j : ℕ) : ((j : ℝ≥0) - (s : ℝ≥0)) = ((j - s : ℕ) : ℝ≥0) := by
  rcases le_total j s with h | h
  · rw [tsub_eq_zero_of_le (by exact_mod_cast h), Nat.sub_eq_zero_of_le h]
    simp
  · have : ((j - s : ℕ) : ℝ≥0) + (s : ℝ≥0) = (j : ℝ≥0) := by
      rw [← Nat.cast_add, Nat.sub_add_cancel h]
    rw [← this, add_tsub_cancel_right]

/-- **The extension restricts to the measurements.**  For any real profile `K₀`
that interpolates the measured chain `K` at integer octaves, the real flow
reproduces the whole discrete table. -/
theorem rshift_restricts {K : Chain} {K0 : RChain} (hint : ∀ n : ℕ, K0 n = K n)
    (s j : ℕ) : rshift K0 (s : ℝ≥0) (j : ℝ≥0) = (shift K s j : ℝ) := by
  rw [rshift_apply, natCast_tsub, hint, shift_apply]

/-! ## Continuous rigidity -/

/-- A **real scale flow**: a two-parameter knee table indexed by a real scale
parameter and a real context octave, subject to the continuous exchange law and
base-context inertia. -/
structure ScaleFlow where
  /-- `table σ t` is the knee at real scale `σ` and real context octave `t`. -/
  table : ℝ≥0 → ℝ≥0 → ℝ
  /-- The base profile is monotone in context. -/
  base_mono : Monotone (table 0)
  /-- `a` octaves of scale buy `a` octaves of context, for every real `a`. -/
  exchange : ∀ s t a, table (s + a) (t + a) = table s t
  /-- At the base context, scale changes nothing. -/
  boundary : ∀ s, table s 0 = table 0 0

namespace ScaleFlow

variable (F : ScaleFlow)

/-- **Continuous rigidity.**  The two local laws determine the entire real table
from the single base profile: `F σ = rshift (F 0) σ`.  This is the real-parameter
analogue of `ScaleFamily.eq_shift`. -/
theorem eq_rshift (s : ℝ≥0) : F.table s = rshift (F.table 0) s := by
  funext t
  rcases le_total t s with h | h
  · -- clamped region: transport back to the base context
    have h1 : F.table s t = F.table (s - t) 0 := by
      have := F.exchange (s - t) 0 t
      rw [tsub_add_cancel_of_le h, zero_add] at this
      exact this
    rw [h1, F.boundary, rshift, tsub_eq_zero_of_le h]
  · have h1 : F.table s t = F.table 0 (t - s) := by
      have := F.exchange 0 (t - s) s
      rw [zero_add, tsub_add_cancel_of_le h] at this
      exact this
    rw [h1, rshift]

theorem apply_eq (s t : ℝ≥0) : F.table s t = F.table 0 (t - s) := by
  rw [F.eq_rshift s]; rfl

/-- Every profile in the flow is monotone in context. -/
theorem table_mono (s : ℝ≥0) : Monotone (F.table s) := by
  rw [F.eq_rshift s]; exact rshift_monotone F.base_mono s

/-- **"Scale amplifies sensitivity" is refuted structurally, in continuous form.**
Larger models never need a larger budget at the same context. -/
theorem antitone_scale (t : ℝ≥0) : Antitone fun s => F.table s t := by
  intro a b hab
  show F.table b t ≤ F.table a t
  rw [F.apply_eq b t, F.apply_eq a t]
  exact F.base_mono (tsub_le_tsub_left hab t)

/-- **"Scale flattens the context axis" is refuted structurally, in continuous
form.**  Unboundedness of the base profile propagates to every real scale. -/
theorem no_flattening (hub : ∀ b : ℝ, ∃ t, b < F.table 0 t) (s : ℝ≥0) (b : ℝ) :
    ∃ t, b < F.table s t := by
  obtain ⟨t, ht⟩ := hub b
  refine ⟨t + s, ?_⟩
  rw [F.apply_eq s (t + s), add_tsub_cancel_right]
  exact ht

/-- **Lipschitz transport.**  If the base profile rises at a rate of at most `δ`
keys per octave, then a change of `h` in the scale parameter changes every knee by
at most `δ·h`: interpolated deployment tables are Lipschitz in scale. -/
theorem abs_sub_le_of_slope {delta : ℝ} (hδ : 0 ≤ delta)
    (hslope : ∀ x y : ℝ≥0, x ≤ y → F.table 0 y - F.table 0 x ≤ delta * ((y : ℝ) - x))
    (s t h : ℝ≥0) : |F.table s t - F.table (s + h) t| ≤ delta * h := by
  have hle : F.table (s + h) t ≤ F.table s t :=
    F.antitone_scale t (le_add_of_nonneg_right (zero_le h))
  have hmono : (t - (s + h)) ≤ (t - s) := tsub_le_tsub_left (le_add_of_nonneg_right (zero_le h)) t
  have hkey : F.table s t - F.table (s + h) t
      ≤ delta * (((t - s : ℝ≥0) : ℝ) - ((t - (s + h) : ℝ≥0) : ℝ)) := by
    rw [F.apply_eq s t, F.apply_eq (s + h) t]
    exact hslope _ _ hmono
  have hdiff : ((t - s) - (t - (s + h)) : ℝ≥0) ≤ h := by
    rw [tsub_le_iff_right, tsub_le_iff_right]
    calc t ≤ (t - (s + h)) + (s + h) := le_tsub_add
      _ = h + (t - (s + h)) + s := by ring
  have hdiffR : ((t - s : ℝ≥0) : ℝ) - ((t - (s + h) : ℝ≥0) : ℝ) ≤ (h : ℝ) := by
    rw [← NNReal.coe_sub hmono]
    exact_mod_cast hdiff
  have hnn : (0 : ℝ) ≤ ((t - s : ℝ≥0) : ℝ) - ((t - (s + h) : ℝ≥0) : ℝ) := by
    have : ((t - (s + h) : ℝ≥0) : ℝ) ≤ ((t - s : ℝ≥0) : ℝ) := by exact_mod_cast hmono
    linarith
  rw [abs_of_nonneg (by linarith)]
  calc F.table s t - F.table (s + h) t
      ≤ delta * (((t - s : ℝ≥0) : ℝ) - ((t - (s + h) : ℝ≥0) : ℝ)) := hkey
    _ ≤ delta * h := by nlinarith

end ScaleFlow

/-- Every real profile generates a scale flow. -/
def ScaleFlow.ofProfile (K : RChain) (hK : Monotone K) : ScaleFlow where
  table := fun s => rshift K s
  base_mono := by simpa using hK
  exchange := fun s t a => rshift_exchange K s t a
  boundary := fun s => by simp [rshift]

/-! ## Identifiability of the real rate -/

/-- **Real-rate identifiability.**  A strictly increasing profile pins the real
scale parameter: passing from `(ℕ,+)` to `(ℝ≥0,+)` introduces no gauge freedom in
the exchange rate. -/
theorem rshift_injective_of_strictMono {K : RChain} (hK : StrictMono K) {a b : ℝ≥0}
    (h : rshift K a = rshift K b) : a = b := by
  by_contra hne
  rcases lt_or_gt_of_ne hne with hab | hab
  · have := congrFun h b
    simp only [rshift, tsub_self] at this
    have hpos : (0 : ℝ≥0) < b - a := tsub_pos_of_lt hab
    exact absurd this (ne_of_gt (hK hpos))
  · have := congrFun h a
    simp only [rshift, tsub_self] at this
    have hpos : (0 : ℝ≥0) < a - b := tsub_pos_of_lt hab
    exact absurd this.symm (ne_of_gt (hK hpos))

end Tropical.ScaleFlowCore