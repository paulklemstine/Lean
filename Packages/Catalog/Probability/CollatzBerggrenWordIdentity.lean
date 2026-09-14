import Mathlib
import Probability.CollatzBerggrenBranching

/-!
# The Collatz–Berggren bridge, II: the word identity and what *does* transfer

The Berggren tree owes its tractability to a *word calculus*: a finite word in
the letters `A, B, C` acts on a triple by a product of three fixed matrices of
the Lorentz group `O(2,1;ℤ)`, and the quadratic form `a² + b² − c²` is conserved
by each letter.

This file isolates the exact analogue for the Syracuse (odd-to-odd Collatz) map
and shows precisely how far the analogy goes.  A Syracuse path is a word
`ks = [k₁, …, k_L]` of `2`-adic valuations, and it acts on the starting value by
an *affine* map:

`syrChain_identity` :  `2 ^ (Σ kᵢ) * n = 3 ^ L * m + syrWeight ks`.

This is the Collatz counterpart of "apply the matrix word": the multiplier
`3 ^ L / 2 ^ (Σ kᵢ)` plays the role of the Berggren expansion factor and
`syrWeight ks` is the inhomogeneous cocycle that has no Berggren analogue —
the Berggren action is *linear*, the Collatz action is only *affine*, and it is
exactly this affine defect that destroys the conserved quadratic form
(see `Probability.CollatzBerggrenRigidity`).

Consequences proved here:

* `syrChain_growth` — the exact one-sided growth law `3 ^ L * m < 2 ^ S * n`;
* `syr_cycle_formula` — a cycle of the Syracuse map forces
  `m * (2 ^ S − 3 ^ L) = syrWeight ks`, the classical cycle equation;
* `syr_cycle_pow_lt` — any cycle satisfies `3 ^ L < 2 ^ S`;
* `syr_cycle_has_big_step` — any nonempty cycle must use at least one step with
  `2`-adic valuation `≥ 2`; in particular there is no cycle all of whose steps
  are "`3n+1` then one halving".
-/

namespace CollatzBerggren

/-! ## Syracuse words -/

/-- `SyrChain m ks n` : there is a Syracuse path from the odd number `m` to `n`
whose successive `2`-adic valuations are the entries of `ks`.  A single step
with letter `k` is `3 * m + 1 = 2 ^ k * m'`. -/
inductive SyrChain : ℕ → List ℕ → ℕ → Prop
  | nil (m : ℕ) : SyrChain m [] m
  | cons {m m' n k : ℕ} {ks : List ℕ} (hk : 1 ≤ k) (h : 3 * m + 1 = 2 ^ k * m') :
      SyrChain m' ks n → SyrChain m (k :: ks) n

/-- The inhomogeneous cocycle attached to a Syracuse word.  It is the Collatz
analogue of the *translation part* of a Berggren matrix word — and the Berggren
words have none. -/
def syrWeight : List ℕ → ℕ
  | [] => 0
  | k :: ks => 3 ^ ks.length + 2 ^ k * syrWeight ks

@[simp] theorem syrWeight_nil : syrWeight [] = 0 := rfl

@[simp] theorem syrWeight_cons (k : ℕ) (ks : List ℕ) :
    syrWeight (k :: ks) = 3 ^ ks.length + 2 ^ k * syrWeight ks := rfl

/-- A single Syracuse edge is a one-letter chain. -/
theorem SyrChain.of_pred {m n : ℕ} (h : SyrPred m n) : ∃ k, SyrChain m [k] n := by
  obtain ⟨-, k, hk, hmn⟩ := h
  exact ⟨k, SyrChain.cons hk hmn (SyrChain.nil n)⟩

/-- **The Collatz word identity.**  Along a Syracuse path with valuation word
`ks`, the start `m` and the end `n` are related by the affine law
`2 ^ (Σ ks) * n = 3 ^ |ks| * m + syrWeight ks`.  This is the exact analogue of
evaluating a Berggren matrix word, except for the extra additive term. -/
theorem syrChain_identity {m n : ℕ} {ks : List ℕ} (h : SyrChain m ks n) :
    2 ^ ks.sum * n = 3 ^ ks.length * m + syrWeight ks := by
  induction h with
  | nil m => simp
  | @cons m m' n k ks hk hstep hrest ih =>
      have hsum : (k :: ks).sum = k + ks.sum := by simp
      calc 2 ^ (k :: ks).sum * n
          = 2 ^ k * (2 ^ ks.sum * n) := by rw [hsum, pow_add, mul_assoc]
        _ = 2 ^ k * (3 ^ ks.length * m' + syrWeight ks) := by rw [ih]
        _ = 3 ^ ks.length * (2 ^ k * m') + 2 ^ k * syrWeight ks := by ring
        _ = 3 ^ ks.length * (3 * m + 1) + 2 ^ k * syrWeight ks := by rw [hstep]
        _ = 3 ^ (k :: ks).length * m + syrWeight (k :: ks) := by
              simp only [List.length_cons, syrWeight_cons]; ring

/-- The cocycle is strictly positive on nonempty words. -/
theorem syrWeight_pos {ks : List ℕ} (h : ks ≠ []) : 0 < syrWeight ks := by
  cases ks with
  | nil => exact absurd rfl h
  | cons k ks =>
      have : 0 < 3 ^ ks.length := Nat.pow_pos (by norm_num)
      simp only [syrWeight_cons]
      omega

/-- Every letter of a Syracuse word is at least `1`. -/
theorem SyrChain.letters_pos {m n : ℕ} {ks : List ℕ} (h : SyrChain m ks n) :
    ∀ k ∈ ks, 1 ≤ k := by
  induction h with
  | nil m => intro k hk; simp at hk
  | @cons m m' n k ks hk hstep hrest ih =>
      intro j hj
      rcases List.mem_cons.1 hj with rfl | hj
      · exact hk
      · exact ih j hj

/-- **One-sided growth law.**  Along any nonempty Syracuse path,
`3 ^ L * m < 2 ^ S * n`: the multiplicative defect between the `3`-expansion and
the `2`-contraction is strictly positive.  (This is the Collatz shadow of the
Berggren statement that each step strictly increases the hypotenuse.) -/
theorem syrChain_growth {m n : ℕ} {ks : List ℕ} (h : SyrChain m ks n) (hne : ks ≠ []) :
    3 ^ ks.length * m < 2 ^ ks.sum * n := by
  have hid := syrChain_identity h
  have hw := syrWeight_pos hne
  omega

/-- **The cycle equation.**  If a Syracuse path returns to its starting point,
the starting value is pinned down by the word:
`m * (2 ^ S − 3 ^ L) = syrWeight ks` (stated over `ℤ` to avoid truncation). -/
theorem syr_cycle_formula {m : ℕ} {ks : List ℕ} (h : SyrChain m ks m) :
    (m : ℤ) * (2 ^ ks.sum - 3 ^ ks.length) = (syrWeight ks : ℤ) := by
  have hid := syrChain_identity h
  have : ((2 ^ ks.sum * m : ℕ) : ℤ) = ((3 ^ ks.length * m + syrWeight ks : ℕ) : ℤ) := by
    exact_mod_cast congrArg (fun x : ℕ => (x : ℤ)) hid
  push_cast at this
  linarith [this]

/-- **Cycles are `2`-heavy.**  Any nontrivial Syracuse cycle through a positive
value satisfies `3 ^ L < 2 ^ S`, i.e. the number of halvings strictly exceeds
`L · log₂ 3`. -/
theorem syr_cycle_pow_lt {m : ℕ} {ks : List ℕ} (h : SyrChain m ks m)
    (hne : ks ≠ []) : 3 ^ ks.length < 2 ^ ks.sum := by
  have hid := syrChain_identity h
  have hw := syrWeight_pos hne
  by_contra hcon
  push_neg at hcon
  have : 2 ^ ks.sum * m ≤ 3 ^ ks.length * m := Nat.mul_le_mul_right m hcon
  omega

/-- Sum and length of a word all of whose letters are `1` coincide. -/
theorem sum_eq_length_of_all_one {ks : List ℕ} (h : ∀ k ∈ ks, k = 1) :
    ks.sum = ks.length := by
  induction ks with
  | nil => simp
  | cons k ks ih =>
      have hk : k = 1 := h k (List.mem_cons_self ..)
      have hrest : ∀ j ∈ ks, j = 1 := fun j hj => h j (List.mem_cons_of_mem _ hj)
      simp [hk, ih hrest, Nat.add_comm]

/-- **No all-minimal cycle.**  Every nonempty Syracuse cycle through a positive
value contains a step whose `2`-adic valuation is at least `2`.  Equivalently, a
trajectory that alternates `3n+1` with exactly one halving can never close up.
This is the sharpest *positive* structural consequence of the word identity, and
it is the genuine analogue of the Berggren spine growth estimate: the Collatz
tree admits no "constant-letter" loop. -/
theorem syr_cycle_has_big_step {m : ℕ} {ks : List ℕ} (h : SyrChain m ks m)
    (hne : ks ≠ []) : ∃ k ∈ ks, 2 ≤ k := by
  by_contra hcon
  push_neg at hcon
  -- every letter of a Syracuse word is ≥ 1, so all letters would equal 1
  have hone : ∀ k ∈ ks, k = 1 := by
    have hge : ∀ k ∈ ks, 1 ≤ k := h.letters_pos
    intro k hk
    have := hge k hk
    have := hcon k hk
    omega
  have hsum : ks.sum = ks.length := sum_eq_length_of_all_one hone
  have hlt : 3 ^ ks.length < 2 ^ ks.sum := syr_cycle_pow_lt h hne
  rw [hsum] at hlt
  have hL : 0 < ks.length := List.length_pos_iff.2 hne
  have : 2 ^ ks.length < 3 ^ ks.length :=
    Nat.pow_lt_pow_left (by norm_num) (by omega)
  omega

/-! ## Worked instances of the identity -/

/-- The self-loop `1 → 1` has word `[2]`, weight `1`, and satisfies the cycle
equation `1 * (2² − 3¹) = 1`. -/
theorem syrChain_one : SyrChain 1 [2] 1 :=
  SyrChain.cons (m' := 1) (by norm_num) (by norm_num) (SyrChain.nil 1)

theorem syr_cycle_formula_one :
    (1 : ℤ) * (2 ^ ([2] : List ℕ).sum - 3 ^ ([2] : List ℕ).length) = (syrWeight [2] : ℤ) :=
  syr_cycle_formula syrChain_one

/-- A two-step example: `7 → 11 → 17` with word `[1, 1]`, verifying
`2² · 17 = 3² · 7 + (3 + 2)`. -/
theorem syrChain_seven : SyrChain 7 [1, 1] 17 :=
  SyrChain.cons (m' := 11) (le_refl 1) (by norm_num)
    (SyrChain.cons (m' := 17) (le_refl 1) (by norm_num) (SyrChain.nil 17))

theorem syrChain_seven_identity :
    2 ^ ([1, 1] : List ℕ).sum * 17 = 3 ^ ([1, 1] : List ℕ).length * 7 + syrWeight [1, 1] :=
  syrChain_identity syrChain_seven

end CollatzBerggren