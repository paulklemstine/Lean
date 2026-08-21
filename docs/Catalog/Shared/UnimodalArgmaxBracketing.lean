/-
# Strict unimodality and the *explicit* comparison of the two bracketing degrees

Research cycle theme: *strict unimodality and the bracketing of the argmax are
theorems; the missing ingredient is the explicit comparison of the two bracketing
degrees.*

A finite positive sequence `a 0, …, a n` which is **strictly log-concave**
(`a k * a (k+2) < a (k+1)^2`) is strictly unimodal.  Its set of maximisers is an
interval `[d⁻, d⁺]`, where

* `d⁻ = firstArgmax n a` is the first index at which the sequence stops *strictly*
  rising, and
* `d⁺ = lastArgmax n a` is the first index at which the sequence starts *strictly*
  falling.

Both indices *bracket* the argmax.  The point of this file is the **explicit
comparison** of the two bracketing degrees:

`lastArgmax_le_firstArgmax_succ` :  `d⁺ ≤ d⁻ + 1`
`lastArgmax_eq_succ_iff`         :  `d⁺ = d⁻ + 1 ↔ (d⁻ < n ∧ a d⁻ = a (d⁻+1))`
`lastArgmax_sub_firstArgmax`     :  `d⁺ - d⁻ = 0` or `1`, decided by the tie.

so the gap between the two brackets is `0` or `1` and *the value `1` occurs exactly
when the peak is a two-point plateau*.

The second half instantiates this for the **binomial weights**
`a k = C(n,k) p^k q^(n-k)` (`p, q > 0`), i.e. the terms of the binomial theorem for
`(p+q)^n`.  There the two bracketing degrees become completely explicit in terms of

`θ = (n+1) * p / (p + q)` :

`binomialWeight_firstArgmax` : `d⁻ = ⌈θ⌉₊ - 1`
`binomialWeight_lastArgmax`  : `d⁺ = ⌊θ⌋₊`

and the explicit comparison of the two degrees reads

`binomialWeight_bracket_gap` : `d⁺ = d⁻ + 1 ↔ θ ∈ ℕ`,

with the arithmetic corollary (`binomialWeight_nat_bracket_gap`) that for natural
weights `p, q ≥ 1` the plateau occurs iff `(p+q) ∣ (n+1)*p`, and the classical
special case `p = q = 1` (`choose_bracket_gap`): the binomial coefficients
`C(n,k)` have a two-point plateau exactly when `n` is odd.

Everything is proved from scratch; the only external input is `Mathlib`.
-/
import Mathlib

namespace Shared
namespace UnimodalArgmaxBracketing

attribute [local instance] Classical.propDecidable

/-! ## Strictly log-concave finite sequences -/

/-- A real sequence `a` is *strictly log-concave on the window* `[0, n]` if it is
positive there and satisfies the strict Newton inequality
`a k * a (k+2) < a (k+1)^2` for every admissible `k`. -/
structure StrictLogConcaveOn (n : ℕ) (a : ℕ → ℝ) : Prop where
  pos : ∀ k ≤ n, 0 < a k
  newton : ∀ k, k + 2 ≤ n → a k * a (k + 2) < a (k + 1) ^ 2

namespace StrictLogConcaveOn

variable {n : ℕ} {a : ℕ → ℝ}

/-- One step of ratio decrease: the consecutive ratios strictly decrease. -/
theorem ratio_step (h : StrictLogConcaveOn n a) {k : ℕ} (hk : k + 2 ≤ n) :
    a (k + 2) / a (k + 1) < a (k + 1) / a k := by
  have h0 : 0 < a k := h.pos k (by omega)
  have h1 : 0 < a (k + 1) := h.pos (k + 1) (by omega)
  rw [div_lt_div_iff₀ h1 h0]
  nlinarith [h.newton k hk]

/-- The sequence of consecutive ratios `a (k+1) / a k` is strictly decreasing. -/
theorem ratio_strictAnti (h : StrictLogConcaveOn n a) {j k : ℕ} (hjk : j < k) :
    k < n → a (k + 1) / a k < a (j + 1) / a j := by
  induction k, hjk using Nat.le_induction with
  | base => intro hk; exact h.ratio_step (by omega)
  | succ k hjk ih => intro hk; exact lt_trans (h.ratio_step (by omega)) (ih (by omega))

/-- If the sequence does not fall at a late index `k`, it strictly rises at every
earlier index. -/
theorem rise_of_rise_later (h : StrictLogConcaveOn n a) {j k : ℕ} (hjk : j < k) (hk : k < n)
    (hrise : a k ≤ a (k + 1)) : a j < a (j + 1) := by
  have h0 : 0 < a j := h.pos j (by omega)
  have hk0 : 0 < a k := h.pos k (by omega)
  have h1 : (1 : ℝ) ≤ a (k + 1) / a k := (one_le_div hk0).2 hrise
  have h2 := h.ratio_strictAnti hjk hk
  have : (1 : ℝ) < a (j + 1) / a j := lt_of_le_of_lt h1 h2
  exact (one_lt_div h0).1 this

/-- If the sequence does not rise at an early index `j`, it strictly falls at every
later index. -/
theorem fall_of_fall_earlier (h : StrictLogConcaveOn n a) {j k : ℕ} (hjk : j < k) (hk : k < n)
    (hfall : a (j + 1) ≤ a j) : a (k + 1) < a k := by
  have h0 : 0 < a j := h.pos j (by omega)
  have hk0 : 0 < a k := h.pos k (by omega)
  have h1 : a (j + 1) / a j ≤ 1 := (div_le_one h0).2 hfall
  have h2 := h.ratio_strictAnti hjk hk
  have : a (k + 1) / a k < 1 := lt_of_lt_of_le h2 h1
  exact (div_lt_one hk0).1 this

end StrictLogConcaveOn

/-! ## The two bracketing degrees -/

/-- The **lower bracketing degree**: the first index `k ≤ n` at which the sequence
stops rising strictly (capped at `n`). -/
noncomputable def firstArgmax (n : ℕ) (a : ℕ → ℝ) : ℕ :=
  Nat.find (p := fun k => k = n ∨ a (k + 1) ≤ a k) ⟨n, Or.inl rfl⟩

/-- The **upper bracketing degree**: the first index `k ≤ n` at which the sequence
starts falling strictly (capped at `n`). -/
noncomputable def lastArgmax (n : ℕ) (a : ℕ → ℝ) : ℕ :=
  Nat.find (p := fun k => k = n ∨ a (k + 1) < a k) ⟨n, Or.inl rfl⟩

variable {n : ℕ} {a : ℕ → ℝ}

theorem firstArgmax_le : firstArgmax n a ≤ n :=
  Nat.find_le (Or.inl rfl)

theorem lastArgmax_le : lastArgmax n a ≤ n :=
  Nat.find_le (Or.inl rfl)

theorem rise_of_lt_firstArgmax {j : ℕ} (hj : j < firstArgmax n a) : a j < a (j + 1) := by
  have := Nat.find_min (p := fun k => k = n ∨ a (k + 1) ≤ a k) ⟨n, Or.inl rfl⟩ hj
  push_neg at this
  exact this.2

theorem weak_rise_of_lt_lastArgmax {j : ℕ} (hj : j < lastArgmax n a) : a j ≤ a (j + 1) := by
  have := Nat.find_min (p := fun k => k = n ∨ a (k + 1) < a k) ⟨n, Or.inl rfl⟩ hj
  push_neg at this
  exact this.2

theorem fall_at_firstArgmax (h : firstArgmax n a < n) :
    a (firstArgmax n a + 1) ≤ a (firstArgmax n a) := by
  rcases Nat.find_spec (p := fun k => k = n ∨ a (k + 1) ≤ a k) ⟨n, Or.inl rfl⟩ with h1 | h1
  · exact absurd h1 (Nat.ne_of_lt h)
  · exact h1

theorem strict_fall_at_lastArgmax (h : lastArgmax n a < n) :
    a (lastArgmax n a + 1) < a (lastArgmax n a) := by
  rcases Nat.find_spec (p := fun k => k = n ∨ a (k + 1) < a k) ⟨n, Or.inl rfl⟩ with h1 | h1
  · exact absurd h1 (Nat.ne_of_lt h)
  · exact h1

/-- Characterisation of the lower bracketing degree: it suffices to exhibit an index
which stops the strict rise and below which the sequence rises strictly. -/
theorem firstArgmax_eq_of {d : ℕ} (hd : d ≤ n) (hstop : d = n ∨ a (d + 1) ≤ a d)
    (hrise : ∀ j < d, a j < a (j + 1)) : firstArgmax n a = d := by
  rw [firstArgmax, Nat.find_eq_iff]
  refine ⟨hstop, fun j hj => ?_⟩
  push_neg
  exact ⟨by omega, hrise j hj⟩

/-- Characterisation of the upper bracketing degree. -/
theorem lastArgmax_eq_of {d : ℕ} (hd : d ≤ n) (hstop : d = n ∨ a (d + 1) < a d)
    (hrise : ∀ j < d, a j ≤ a (j + 1)) : lastArgmax n a = d := by
  rw [lastArgmax, Nat.find_eq_iff]
  refine ⟨hstop, fun j hj => ?_⟩
  push_neg
  exact ⟨by omega, hrise j hj⟩

/-- The lower bracket is at most the upper bracket.  (No log-concavity needed.) -/
theorem firstArgmax_le_lastArgmax : firstArgmax n a ≤ lastArgmax n a := by
  by_contra hcon
  push_neg at hcon
  have hlt : lastArgmax n a < n := lt_of_lt_of_le hcon firstArgmax_le
  have h1 := strict_fall_at_lastArgmax (n := n) (a := a) hlt
  have h2 := rise_of_lt_firstArgmax (n := n) (a := a) hcon
  linarith

/-! ### The explicit comparison of the two bracketing degrees -/

/-- **Explicit comparison, upper half.**  The two bracketing degrees differ by at
most one.  This is exactly where strict log-concavity enters: a strictly
log-concave sequence cannot have a plateau of length `≥ 3`. -/
theorem lastArgmax_le_firstArgmax_succ (h : StrictLogConcaveOn n a) :
    lastArgmax n a ≤ firstArgmax n a + 1 := by
  by_contra hcon
  push_neg at hcon
  set d := firstArgmax n a with hd
  have hdn : d + 1 < n := lt_of_lt_of_le hcon lastArgmax_le
  have hrise1 : a d ≤ a (d + 1) := weak_rise_of_lt_lastArgmax (n := n) (by omega)
  have hrise2 : a (d + 1) ≤ a (d + 2) := weak_rise_of_lt_lastArgmax (n := n) (by omega)
  have hfall : a (d + 1) ≤ a d := fall_at_firstArgmax (by omega)
  have heq : a d = a (d + 1) := le_antisymm hrise1 hfall
  have h0 : 0 < a d := h.pos d (by omega)
  have := h.newton d (by omega)
  nlinarith

/-- **Explicit comparison, exact form.**  The gap between the two bracketing
degrees is `1` precisely when the peak is a genuine two-point plateau. -/
theorem lastArgmax_eq_succ_iff (h : StrictLogConcaveOn n a) :
    lastArgmax n a = firstArgmax n a + 1 ↔
      (firstArgmax n a < n ∧ a (firstArgmax n a) = a (firstArgmax n a + 1)) := by
  set d := firstArgmax n a with hd
  constructor
  · intro hgap
    have hdn : d < n := by
      have : d + 1 ≤ n := hgap ▸ lastArgmax_le (n := n) (a := a)
      omega
    refine ⟨hdn, le_antisymm ?_ (fall_at_firstArgmax hdn)⟩
    exact weak_rise_of_lt_lastArgmax (n := n) (by omega)
  · rintro ⟨hdn, heq⟩
    have hne : lastArgmax n a ≠ d := by
      intro hcon
      have := strict_fall_at_lastArgmax (n := n) (a := a) (by omega)
      rw [hcon] at this
      linarith
    have := firstArgmax_le_lastArgmax (n := n) (a := a)
    have := lastArgmax_le_firstArgmax_succ h
    omega

/-- The gap of the bracket is `0` or `1`. -/
theorem lastArgmax_sub_firstArgmax (h : StrictLogConcaveOn n a) :
    lastArgmax n a - firstArgmax n a = 0 ∨ lastArgmax n a - firstArgmax n a = 1 := by
  have := firstArgmax_le_lastArgmax (n := n) (a := a)
  have := lastArgmax_le_firstArgmax_succ h
  omega

/-- The bracket is *tight* (both degrees agree) exactly when there is no tie. -/
theorem firstArgmax_eq_lastArgmax_iff (h : StrictLogConcaveOn n a) :
    firstArgmax n a = lastArgmax n a ↔
      ¬ (firstArgmax n a < n ∧ a (firstArgmax n a) = a (firstArgmax n a + 1)) := by
  rw [← lastArgmax_eq_succ_iff h]
  have := firstArgmax_le_lastArgmax (n := n) (a := a)
  have := lastArgmax_le_firstArgmax_succ h
  omega

/-! ## Strict unimodality -/

/-- Below the lower bracket the sequence is *strictly* increasing. -/
theorem strict_increasing_below {j k : ℕ} (hjk : j < k) (hk : k ≤ firstArgmax n a) :
    a j < a k := by
  induction k, hjk using Nat.le_induction with
  | base => exact rise_of_lt_firstArgmax (n := n) (by omega)
  | succ k hjk ih =>
      exact lt_trans (ih (by omega)) (rise_of_lt_firstArgmax (n := n) (by omega))

/-- One step of strict decrease above the upper bracket. -/
theorem strict_fall_above (h : StrictLogConcaveOn n a) {j : ℕ} (hj : lastArgmax n a ≤ j)
    (hjn : j < n) : a (j + 1) < a j := by
  rcases eq_or_lt_of_le hj with heq | hlt
  · rw [← heq]; exact strict_fall_at_lastArgmax (by omega)
  · have hl : lastArgmax n a < n := by omega
    exact h.fall_of_fall_earlier hlt hjn (le_of_lt (strict_fall_at_lastArgmax hl))

/-- Above the upper bracket the sequence is *strictly* decreasing. -/
theorem strict_decreasing_above (h : StrictLogConcaveOn n a) {j k : ℕ}
    (hj : lastArgmax n a ≤ j) (hjk : j < k) (hk : k ≤ n) : a k < a j := by
  induction k, hjk using Nat.le_induction with
  | base => exact strict_fall_above h hj (by omega)
  | succ k hjk ih =>
      exact lt_trans (strict_fall_above h (by omega) (by omega)) (ih (by omega))

/-- The two bracketing degrees carry the same value: the peak is a plateau of
length one or two. -/
theorem value_firstArgmax_eq_lastArgmax (h : StrictLogConcaveOn n a) :
    a (firstArgmax n a) = a (lastArgmax n a) := by
  rcases (lastArgmax_sub_firstArgmax h) with hgap | hgap
  · have := firstArgmax_le_lastArgmax (n := n) (a := a)
    have : firstArgmax n a = lastArgmax n a := by omega
    rw [this]
  · have hgap' : lastArgmax n a = firstArgmax n a + 1 := by
      have := firstArgmax_le_lastArgmax (n := n) (a := a); omega
    rw [hgap']
    exact ((lastArgmax_eq_succ_iff h).1 hgap').2

/-- **The bracketing of the argmax**: every term is dominated by the value at the
lower bracketing degree. -/
theorem le_value_firstArgmax (h : StrictLogConcaveOn n a) {k : ℕ} (hk : k ≤ n) :
    a k ≤ a (firstArgmax n a) := by
  rcases lt_or_ge k (firstArgmax n a) with hlt | hge
  · exact le_of_lt (strict_increasing_below hlt le_rfl)
  · rcases lt_or_ge (lastArgmax n a) k with hlt2 | hge2
    · rw [value_firstArgmax_eq_lastArgmax h]
      exact le_of_lt (strict_decreasing_above h le_rfl hlt2 hk)
    · -- `firstArgmax ≤ k ≤ lastArgmax ≤ firstArgmax + 1`
      have h1 := lastArgmax_le_firstArgmax_succ h
      have : k = firstArgmax n a ∨ k = lastArgmax n a := by omega
      rcases this with rfl | rfl
      · exact le_rfl
      · exact le_of_eq (value_firstArgmax_eq_lastArgmax h).symm

/-- **Strict unimodality.**  Outside the bracket `[d⁻, d⁺]` the inequality is
strict, so the set of maximisers is *exactly* the interval `[d⁻, d⁺]`. -/
theorem lt_value_firstArgmax_of_outside (h : StrictLogConcaveOn n a) {k : ℕ} (hk : k ≤ n)
    (hout : k < firstArgmax n a ∨ lastArgmax n a < k) : a k < a (firstArgmax n a) := by
  rcases hout with hlt | hgt
  · exact strict_increasing_below hlt le_rfl
  · rw [value_firstArgmax_eq_lastArgmax h]
    exact strict_decreasing_above h le_rfl hgt hk

/-- The maximiser set of a strictly log-concave window is the *interval between the
two bracketing degrees*. -/
theorem argmax_eq_Icc (h : StrictLogConcaveOn n a) {k : ℕ} (hk : k ≤ n) :
    a k = a (firstArgmax n a) ↔ (firstArgmax n a ≤ k ∧ k ≤ lastArgmax n a) := by
  constructor
  · intro hval
    by_contra hcon
    push_neg at hcon
    have hout : k < firstArgmax n a ∨ lastArgmax n a < k := by
      rcases lt_or_ge k (firstArgmax n a) with h1 | h1
      · exact Or.inl h1
      · exact Or.inr (hcon h1)
    exact absurd hval (ne_of_lt (lt_value_firstArgmax_of_outside h hk hout))
  · rintro ⟨h1, h2⟩
    have h3 := lastArgmax_le_firstArgmax_succ h
    have : k = firstArgmax n a ∨ k = lastArgmax n a := by omega
    rcases this with rfl | rfl
    · rfl
    · exact (value_firstArgmax_eq_lastArgmax h).symm

/-! ## Threshold windows: the abstract mechanism producing *explicit* brackets

In every concrete example the rise pattern of the window is governed by a single
real parameter `θ` through the criterion `a k < a (k+1) ↔ k + 1 < θ`.  Isolating this
hypothesis turns the two bracketing degrees into `⌈θ⌉₊ - 1` and `⌊θ⌋₊`, and their
comparison into the arithmetic question of whether `θ` is an integer. -/

/-- A *threshold window*: the window `[0, n]` rises exactly below the real threshold
`θ ∈ (0, n+1)`. -/
structure ThresholdWindow (n : ℕ) (a : ℕ → ℝ) (θ : ℝ) : Prop where
  pos : 0 < θ
  lt_succ : θ < (n : ℝ) + 1
  rise_iff : ∀ k < n, (a k < a (k + 1) ↔ ((k : ℝ) + 1) < θ)
  weak_rise_iff : ∀ k < n, (a k ≤ a (k + 1) ↔ ((k : ℝ) + 1) ≤ θ)

/-- `⌊θ⌋₊ = ⌈θ⌉₊` exactly for non-negative integers `θ`. -/
theorem floor_eq_ceil_iff_exists_nat {θ : ℝ} (hθ : 0 ≤ θ) :
    ⌊θ⌋₊ = ⌈θ⌉₊ ↔ ∃ m : ℕ, (m : ℝ) = θ := by
  constructor
  · intro h
    refine ⟨⌊θ⌋₊, le_antisymm (Nat.floor_le hθ) ?_⟩
    rw [h]
    exact Nat.le_ceil θ
  · rintro ⟨m, rfl⟩
    rw [Nat.floor_natCast, Nat.ceil_natCast]

namespace ThresholdWindow

variable {θ : ℝ}

/-- **The lower bracketing degree of a threshold window is `⌈θ⌉₊ - 1`.** -/
theorem firstArgmax_eq (h : ThresholdWindow n a θ) : firstArgmax n a = ⌈θ⌉₊ - 1 := by
  have hceilpos : 1 ≤ ⌈θ⌉₊ := Nat.ceil_pos.2 h.pos
  have hceille : ⌈θ⌉₊ ≤ n + 1 := by
    apply Nat.ceil_le.2
    push_cast
    linarith [h.lt_succ]
  have hd : ⌈θ⌉₊ - 1 ≤ n := by omega
  refine firstArgmax_eq_of hd ?_ ?_
  · rcases eq_or_lt_of_le hd with hEq | hlt
    · exact Or.inl hEq
    · refine Or.inr (not_lt.1 ?_)
      rw [h.rise_iff _ hlt]
      push_neg
      have hcast : ((⌈θ⌉₊ - 1 : ℕ) : ℝ) + 1 = (⌈θ⌉₊ : ℝ) := by
        have : ((⌈θ⌉₊ - 1 : ℕ) : ℝ) = (⌈θ⌉₊ : ℝ) - 1 := by
          simpa using Nat.cast_sub (R := ℝ) hceilpos
        rw [this]; ring
      rw [hcast]
      exact Nat.le_ceil θ
  · intro j hj
    have hjn : j < n := lt_of_lt_of_le hj hd
    rw [h.rise_iff _ hjn]
    have hlt : j + 1 < ⌈θ⌉₊ := by omega
    have hnot : ¬ (θ ≤ ((j + 1 : ℕ) : ℝ)) := fun hcon =>
      absurd (Nat.ceil_le.2 hcon) (by omega)
    push_cast at hnot
    linarith [not_le.1 hnot]

/-- **The upper bracketing degree of a threshold window is `⌊θ⌋₊`.** -/
theorem lastArgmax_eq (h : ThresholdWindow n a θ) : lastArgmax n a = ⌊θ⌋₊ := by
  have hd : ⌊θ⌋₊ ≤ n := by
    have : ⌊θ⌋₊ < n + 1 := by
      apply (Nat.floor_lt h.pos.le).2
      push_cast
      linarith [h.lt_succ]
    omega
  refine lastArgmax_eq_of hd ?_ ?_
  · rcases eq_or_lt_of_le hd with hEq | hlt
    · exact Or.inl hEq
    · refine Or.inr (not_le.1 ?_)
      rw [h.weak_rise_iff _ hlt]
      push_neg
      exact Nat.lt_floor_add_one θ
  · intro j hj
    have hjn : j < n := lt_of_lt_of_le hj hd
    rw [h.weak_rise_iff _ hjn]
    have hle : ((j + 1 : ℕ) : ℝ) ≤ θ := (Nat.le_floor_iff h.pos.le).1 (by omega)
    push_cast at hle
    linarith

/-- **The explicit comparison of the two bracketing degrees of a threshold window.**
The gap is `1` exactly when the threshold is an integer. -/
theorem bracket_gap (h : ThresholdWindow n a θ) :
    lastArgmax n a = firstArgmax n a + 1 ↔ ∃ m : ℕ, (m : ℝ) = θ := by
  have hceilpos : 1 ≤ ⌈θ⌉₊ := Nat.ceil_pos.2 h.pos
  rw [h.firstArgmax_eq, h.lastArgmax_eq, ← floor_eq_ceil_iff_exists_nat h.pos.le]
  omega

/-- If the threshold is not an integer the maximiser is unique. -/
theorem bracket_tight (h : ThresholdWindow n a θ) (hirr : ¬ ∃ m : ℕ, (m : ℝ) = θ) :
    firstArgmax n a = lastArgmax n a := by
  rw [h.firstArgmax_eq, h.lastArgmax_eq]
  have hceilpos : 1 ≤ ⌈θ⌉₊ := Nat.ceil_pos.2 h.pos
  have hfc : ⌊θ⌋₊ ≠ ⌈θ⌉₊ := fun hcon => hirr ((floor_eq_ceil_iff_exists_nat h.pos.le).1 hcon)
  have h1 : ⌊θ⌋₊ ≤ ⌈θ⌉₊ := Nat.floor_le_ceil θ
  have h2 : ⌈θ⌉₊ ≤ ⌊θ⌋₊ + 1 := by
    have := Nat.lt_floor_add_one θ
    exact Nat.ceil_le.2 (by push_cast; linarith)
  omega

/-- **Monotone dependence of the brackets on the threshold.**  Larger threshold means
larger (or equal) bracketing degrees: the peak moves monotonically with the
parameter. -/
theorem brackets_mono {n' : ℕ} {a' : ℕ → ℝ} {θ' : ℝ} (h : ThresholdWindow n a θ)
    (h' : ThresholdWindow n' a' θ') (hle : θ ≤ θ') :
    firstArgmax n a ≤ firstArgmax n' a' ∧ lastArgmax n a ≤ lastArgmax n' a' := by
  rw [h.firstArgmax_eq, h.lastArgmax_eq, h'.firstArgmax_eq, h'.lastArgmax_eq]
  exact ⟨Nat.sub_le_sub_right (Nat.ceil_le_ceil hle) 1, Nat.floor_le_floor hle⟩

/-- **A sub-unit shift of the threshold moves each bracketing degree by at most one.**
This is the quantitative form of "the argmax is a staircase in the parameter". -/
theorem brackets_step {n' : ℕ} {a' : ℕ → ℝ} {θ' : ℝ} (h : ThresholdWindow n a θ)
    (h' : ThresholdWindow n' a' θ') (hstep : θ' < θ + 1) :
    firstArgmax n' a' ≤ firstArgmax n a + 1 ∧ lastArgmax n' a' ≤ lastArgmax n a + 1 := by
  have hceilpos : 1 ≤ ⌈θ⌉₊ := Nat.ceil_pos.2 h.pos
  have hc : ⌈θ'⌉₊ ≤ ⌈θ⌉₊ + 1 := by
    refine Nat.ceil_le.2 ?_
    push_cast
    linarith [Nat.le_ceil θ]
  have hf : ⌊θ'⌋₊ ≤ ⌊θ⌋₊ + 1 := by
    have hb : θ' < ((⌊θ⌋₊ + 2 : ℕ) : ℝ) := by
      push_cast
      linarith [Nat.lt_floor_add_one θ]
    have := (Nat.floor_lt h'.pos.le).2 hb
    omega
  rw [h.firstArgmax_eq, h.lastArgmax_eq, h'.firstArgmax_eq, h'.lastArgmax_eq]
  omega

end ThresholdWindow

end UnimodalArgmaxBracketing
end Shared