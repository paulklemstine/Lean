import Cryptography.TernaryReversible.Core

/-!
# The size-two dichotomy for radius-one reversibility

Everything so far concerned the ternary alphabet.  This file identifies **exactly** for
which alphabets the single-coordinate classification claim is true.

For an arbitrary alphabet `A` we consider radius-one rules `g : A → A → A → A` with the
global maps `globalMapA g s i = g (s (i-1)) (s i) (s (i+1))` on the cycle `ZMod n`.

* If `A` has at least three elements `x₀, x₁, x₂` then the **conditional transposition**
  `twistRule x₀ x₁ x₂ a b c = if c = x₀ then (x₁ x₂)·b else b` is an involution on every
  finite cycle — the transposition fixes `x₀`, so the positions carrying `x₀` are visible
  in the output and the twist can be undone — while it uses two cells of its window.
  Hence the claim fails for *every* alphabet of size `≥ 3`; the ternary counterexamples
  of `Refutation.lean` are the smallest instance of a universal phenomenon.
* For the binary alphabet the claim is **true**: bijectivity on the cycles of length
  `1, 2, 3, 4` already forces a rule on `Fin 2` to be a single coordinate followed by a
  permutation (an exhaustive verification over all `2⁸ = 256` binary rules).

The two results combine into `singleCoordinate_classification_iff`: for `A = Fin q` the
classification claim holds **iff** `q ≤ 2`.

## Main results

* `twistRule_involution`, `twistRule_cycleBijectiveA`, `claim_fails_of_three_elements`;
* `binary_classification`;
* `singleCoordinate_classification_iff`.
-/

namespace Cryptography
namespace TernaryReversible

/-! ## The general framework -/

variable {A : Type}

/-- Global map of a radius-one rule over an arbitrary alphabet. -/
def globalMapA (g : A → A → A → A) {n : ℕ} (s : ZMod n → A) : ZMod n → A :=
  fun i => g (s (i - 1)) (s i) (s (i + 1))

/-- Bijectivity on every nonempty finite cycle, over an arbitrary alphabet. -/
def CycleBijectiveA (g : A → A → A → A) : Prop :=
  ∀ n : ℕ, 0 < n → Function.Bijective (globalMapA (n := n) g)

/-- Single coordinate followed by a permutation, over an arbitrary alphabet. -/
def SingleCoordinatePermA (g : A → A → A → A) : Prop :=
  ∃ σ : Equiv.Perm A, g = (fun a _ _ => σ a) ∨ g = (fun _ b _ => σ b) ∨ g = (fun _ _ c => σ c)

instance decidableSingleCoordinatePermA [Fintype A] [DecidableEq A] (g : A → A → A → A) :
    Decidable (SingleCoordinatePermA g) := by
  unfold SingleCoordinatePermA; infer_instance

/-- The ternary notions of `Core.lean` are the special case `A = Alph`. -/
theorem cycleBijective_iff_general (g : LocalRule) : CycleBijective g ↔ CycleBijectiveA g :=
  Iff.rfl

/-- `g` genuinely uses its middle argument. -/
def DependsMiddleA (g : A → A → A → A) : Prop := ∃ a b b' c, g a b c ≠ g a b' c

/-- `g` genuinely uses its right argument. -/
def DependsRightA (g : A → A → A → A) : Prop := ∃ a b c c', g a b c ≠ g a b c'

/-- A rule using both its middle and its right cell is not a single coordinate followed
by a permutation. -/
theorem not_singleCoordinatePermA_of_MR {g : A → A → A → A} (hm : DependsMiddleA g)
    (hr : DependsRightA g) : ¬ SingleCoordinatePermA g := by
  rintro ⟨σ, rfl | rfl | rfl⟩
  · obtain ⟨a, b, b', c, hne⟩ := hm; exact hne rfl
  · obtain ⟨a, b, c, c', hne⟩ := hr; exact hne rfl
  · obtain ⟨a, b, b', c, hne⟩ := hm; exact hne rfl

/-- **Window-3 decoder criterion**, general alphabet. -/
theorem cycleBijectiveA_of_decoder3 [Fintype A] (g d : A → A → A → A)
    (h : ∀ v w x y z, d (g v w x) (g w x y) (g x y z) = x) : CycleBijectiveA g := by
  intro n hn
  haveI : NeZero n := ⟨hn.ne'⟩
  rw [← Finite.injective_iff_bijective]
  intro s t hst
  funext i
  have key : ∀ u : ZMod n → A,
      d (globalMapA g u (i - 1)) (globalMapA g u i) (globalMapA g u (i + 1)) = u i := by
    intro u
    have e1 : globalMapA g u (i - 1) = g (u (i - 1 - 1)) (u (i - 1)) (u i) := by
      simp [globalMapA, sub_add_cancel]
    have e3 : globalMapA g u (i + 1) = g (u i) (u (i + 1)) (u (i + 1 + 1)) := by
      simp [globalMapA, add_sub_cancel_right]
    rw [e1, e3]
    exact h _ _ _ _ _
  rw [← key s, ← key t, hst]

/-- A self-decoding rule is an involution on every finite cycle. -/
theorem globalMapA_involutive {g : A → A → A → A}
    (h : ∀ v w x y z, g (g v w x) (g w x y) (g x y z) = x) {n : ℕ} (s : ZMod n → A) :
    globalMapA g (globalMapA g s) = s := by
  funext i
  have e1 : globalMapA g s (i - 1) = g (s (i - 1 - 1)) (s (i - 1)) (s i) := by
    simp [globalMapA, sub_add_cancel]
  have e3 : globalMapA g s (i + 1) = g (s i) (s (i + 1)) (s (i + 1 + 1)) := by
    simp [globalMapA, add_sub_cancel_right]
  show g (globalMapA g s (i - 1)) (globalMapA g s i) (globalMapA g s (i + 1)) = s i
  rw [e1, e3]
  exact h _ _ _ _ _

/-- Over a subsingleton alphabet every rule is (trivially) a single coordinate followed
by a permutation. -/
theorem singleCoordinatePermA_of_subsingleton [Subsingleton A] (g : A → A → A → A) :
    SingleCoordinatePermA g := by
  refine ⟨Equiv.refl A, Or.inl ?_⟩
  funext a b c
  exact Subsingleton.elim _ _

/-! ## Alphabets with at least three letters: the claim always fails -/

variable [DecidableEq A]

/-- The conditional transposition rule: transpose `x₁` and `x₂` in the current cell
exactly when the right neighbour equals `x₀`. -/
def twistRule (x₀ x₁ x₂ : A) : A → A → A → A :=
  fun _ b c => if c = x₀ then Equiv.swap x₁ x₂ b else b

variable {x₀ x₁ x₂ : A}

/-- The transposition fixes the marker letter `x₀`. -/
theorem swap_fix (h₁ : x₀ ≠ x₁) (h₂ : x₀ ≠ x₂) : Equiv.swap x₁ x₂ x₀ = x₀ :=
  Equiv.swap_apply_of_ne_of_ne h₁ h₂

/-- Being equal to the marker letter is invariant under the transposition. -/
theorem swap_eq_marker_iff (h₁ : x₀ ≠ x₁) (h₂ : x₀ ≠ x₂) (y : A) :
    Equiv.swap x₁ x₂ y = x₀ ↔ y = x₀ := by
  constructor
  · intro h
    have : Equiv.swap x₁ x₂ y = Equiv.swap x₁ x₂ x₀ := by rw [h, swap_fix h₁ h₂]
    exact (Equiv.swap x₁ x₂).injective this
  · rintro rfl
    exact swap_fix h₁ h₂

/-- **Self-decoding.** The conditional transposition inverts itself. -/
theorem twistRule_selfDecoder (h₁ : x₀ ≠ x₁) (h₂ : x₀ ≠ x₂) :
    ∀ v w x y z, twistRule x₀ x₁ x₂ (twistRule x₀ x₁ x₂ v w x) (twistRule x₀ x₁ x₂ w x y)
      (twistRule x₀ x₁ x₂ x y z) = x := by
  intro v w x y z
  show (if (if z = x₀ then Equiv.swap x₁ x₂ y else y) = x₀
      then Equiv.swap x₁ x₂ (if y = x₀ then Equiv.swap x₁ x₂ x else x)
      else (if y = x₀ then Equiv.swap x₁ x₂ x else x)) = x
  by_cases hy : y = x₀
  · have hcond : (if z = x₀ then Equiv.swap x₁ x₂ y else y) = x₀ := by
      subst hy; split <;> simp [swap_fix h₁ h₂]
    rw [hcond, if_pos rfl, if_pos hy, Equiv.swap_apply_self]
  · have hcond : ¬ (if z = x₀ then Equiv.swap x₁ x₂ y else y) = x₀ := by
      split
      · rw [swap_eq_marker_iff h₁ h₂]; exact hy
      · exact hy
    rw [if_neg hcond, if_neg hy]

/-- The conditional transposition is an involution on every finite cycle. -/
theorem twistRule_involution (h₁ : x₀ ≠ x₁) (h₂ : x₀ ≠ x₂) {n : ℕ} (s : ZMod n → A) :
    globalMapA (twistRule x₀ x₁ x₂) (globalMapA (twistRule x₀ x₁ x₂) s) = s :=
  globalMapA_involutive (twistRule_selfDecoder h₁ h₂) s

/-- Hence it is bijective on every nonempty finite cycle. -/
theorem twistRule_cycleBijectiveA [Fintype A] (h₁ : x₀ ≠ x₁) (h₂ : x₀ ≠ x₂) :
    CycleBijectiveA (twistRule x₀ x₁ x₂) :=
  cycleBijectiveA_of_decoder3 _ _ (twistRule_selfDecoder h₁ h₂)

/-- The conditional transposition uses its middle cell. -/
theorem twistRule_dependsMiddle (h₁₂ : x₁ ≠ x₂) : DependsMiddleA (twistRule x₀ x₁ x₂) := by
  refine ⟨x₀, x₁, x₂, x₀, ?_⟩
  show (if x₀ = x₀ then Equiv.swap x₁ x₂ x₁ else x₁)
      ≠ (if x₀ = x₀ then Equiv.swap x₁ x₂ x₂ else x₂)
  rw [if_pos rfl, if_pos rfl, Equiv.swap_apply_left, Equiv.swap_apply_right]
  exact h₁₂.symm

/-- The conditional transposition uses its right cell. -/
theorem twistRule_dependsRight (h₁ : x₀ ≠ x₁) (h₁₂ : x₁ ≠ x₂) :
    DependsRightA (twistRule x₀ x₁ x₂) := by
  refine ⟨x₀, x₁, x₀, x₁, ?_⟩
  show (if x₀ = x₀ then Equiv.swap x₁ x₂ x₁ else x₁) ≠ (if x₁ = x₀ then Equiv.swap x₁ x₂ x₁ else x₁)
  rw [if_pos rfl, if_neg (Ne.symm h₁), Equiv.swap_apply_left]
  exact h₁₂.symm

/-- **The claim fails over every alphabet with at least three letters.** -/
theorem claim_fails_of_three_elements [Fintype A] (h₁ : x₀ ≠ x₁) (h₂ : x₀ ≠ x₂)
    (h₁₂ : x₁ ≠ x₂) :
    ¬ (∀ g : A → A → A → A, CycleBijectiveA g → SingleCoordinatePermA g) := by
  intro hall
  exact not_singleCoordinatePermA_of_MR (twistRule_dependsMiddle h₁₂)
    (twistRule_dependsRight h₁ h₁₂)
    (hall _ (twistRule_cycleBijectiveA h₁ h₂))

/-! ## The binary alphabet: the claim is true -/

/-- Bijectivity on the four shortest cycles. -/
def BijUpTo4 (g : A → A → A → A) : Prop :=
  Function.Bijective (globalMapA (n := 1) g) ∧ Function.Bijective (globalMapA (n := 2) g) ∧
    Function.Bijective (globalMapA (n := 3) g) ∧ Function.Bijective (globalMapA (n := 4) g)

instance decidableBijUpTo4 [Fintype A] [DecidableEq A] (g : A → A → A → A) :
    Decidable (BijUpTo4 g) := by
  unfold BijUpTo4; infer_instance

set_option maxRecDepth 100000 in
/-- **Exhaustive verification over the 256 binary rules**: bijectivity on the cycles of
length `1, 2, 3, 4` already forces the single-coordinate form.  (Length `≤ 3` does not:
twenty binary rules pass that weaker test.) -/
theorem binary_bijUpTo4_classification :
    ∀ g : Fin 2 → Fin 2 → Fin 2 → Fin 2, BijUpTo4 g → SingleCoordinatePermA g := by
  decide

/-- **Binary classification.** Over the binary alphabet the claim under test is true. -/
theorem binary_classification (g : Fin 2 → Fin 2 → Fin 2 → Fin 2) (hg : CycleBijectiveA g) :
    SingleCoordinatePermA g :=
  binary_bijUpTo4_classification g
    ⟨hg 1 one_pos, hg 2 (by norm_num), hg 3 (by norm_num), hg 4 (by norm_num)⟩

/-! ## The dichotomy -/

/-- **The size-two dichotomy.** For the alphabet `Fin q`, every rule that is bijective on
all nonempty finite cycles is a single coordinate followed by a permutation **iff**
`q ≤ 2`.  Radius-one reversibility is rigid exactly up to two letters. -/
theorem singleCoordinate_classification_iff (q : ℕ) :
    (∀ g : Fin q → Fin q → Fin q → Fin q, CycleBijectiveA g → SingleCoordinatePermA g)
      ↔ q ≤ 2 := by
  constructor
  · intro hall
    by_contra hq
    push_neg at hq
    have h0 : (0 : ℕ) < q := by omega
    have h1 : (1 : ℕ) < q := by omega
    have h2 : (2 : ℕ) < q := by omega
    exact claim_fails_of_three_elements (x₀ := (⟨0, h0⟩ : Fin q)) (x₁ := ⟨1, h1⟩) (x₂ := ⟨2, h2⟩)
      (by simp [Fin.ext_iff]) (by simp [Fin.ext_iff]) (by simp [Fin.ext_iff]) hall
  · intro hq g _
    interval_cases q
    · exact singleCoordinatePermA_of_subsingleton g
    · exact singleCoordinatePermA_of_subsingleton g
    · exact binary_classification g ‹_›

end TernaryReversible
end Cryptography