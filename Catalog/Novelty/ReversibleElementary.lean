import Mathlib

/-!
# Reversible elementary cellular automata

This file gives a finite, machine-checked correction to the proposed “local-rule
permutation” picture.  An elementary local rule has type `Bool³ → Bool`, so it
is not a permutation of the eight neighborhoods.  Reversibility concerns the
induced global map on configurations.

We prove a chain of structural results for the six projection/complement rules,
then exhaustively classify the rules which are bijective on cyclic configurations
of sizes 1 through 4.  The finite test leaves exactly Wolfram rules
15, 51, 85, 170, 204, and 240.  Since each of these six is proved reversible on
every nonempty finite cycle, the test also gives a certified obstruction of
period at most four for every other elementary rule.
-/

namespace ReversibleElementary

abbrev Config (n : ℕ) := Fin n → Bool
abbrev LocalRule := Bool → Bool → Bool → Bool

/-- The index `4l + 2c + r` of a Boolean neighborhood. -/
def neighborhoodIndex (l c r : Bool) : ℕ :=
  4 * l.toNat + 2 * c.toNat + r.toNat

/-- Elementary rule with Wolfram number `w`. -/
def wolframRule (w : Fin 256) : LocalRule := fun l c r =>
  Nat.testBit w.val (neighborhoodIndex l c r)

/-- Cyclic successor. -/
def rightIdx {n : ℕ} (hn : 0 < n) (i : Fin n) : Fin n :=
  ⟨(i.val + 1) % n, Nat.mod_lt _ hn⟩

/-- Cyclic predecessor. -/
def leftIdx {n : ℕ} (hn : 0 < n) (i : Fin n) : Fin n :=
  ⟨(i.val + n - 1) % n, Nat.mod_lt _ hn⟩

/-- Global map induced on a nonempty finite cyclic configuration. -/
def globalMap (f : LocalRule) {n : ℕ} (hn : 0 < n) (x : Config n) : Config n :=
  fun i => f (x (leftIdx hn i)) (x i) (x (rightIdx hn i))

/-- Reversibility on the cycle of length `n` (false for the empty cycle). -/
def ReversibleOn (n : ℕ) (w : Fin 256) : Prop :=
  if hn : 0 < n then Function.Bijective (globalMap (wolframRule w) hn) else False

instance (n : ℕ) (w : Fin 256) : Decidable (ReversibleOn n w) := by
  unfold ReversibleOn
  split <;> infer_instance

/-- Reversibility on every nonempty finite cyclic configuration space. -/
def UniversallyReversible (w : Fin 256) : Prop :=
  ∀ n (hn : 0 < n), Function.Bijective (globalMap (wolframRule w) hn)

/-- Successor followed by predecessor returns the original cyclic index. -/
theorem leftIdx_rightIdx {n : ℕ} (hn : 0 < n) (i : Fin n) :
    leftIdx hn (rightIdx hn i) = i := by
  apply Fin.ext
  simp [leftIdx, rightIdx]
  rcases n with _ | _ | n <;> norm_num at *
  simp +arith +decide
  norm_num [(by ring : n + i + 2 = n + 2 + i)]
  exact Fin.is_le i

/-- Cyclic successor is injective, using its explicit left inverse. -/
theorem rightIdx_injective {n : ℕ} (hn : 0 < n) :
    Function.Injective (rightIdx hn) := by
  intro i j hij
  have := congr_arg (leftIdx hn) hij
  simpa only [leftIdx_rightIdx] using this

/-- Predecessor followed by successor also returns the original index. -/
theorem rightIdx_leftIdx {n : ℕ} (hn : 0 < n) (i : Fin n) :
    rightIdx hn (leftIdx hn i) = i := by
  rcases n with _ | _ | n <;> norm_num [Fin.ext_iff, leftIdx, rightIdx] at *
  · contradiction
  · norm_num [add_assoc, Nat.mod_eq_of_lt]

/-- The two cyclic shifts on configurations are mutual inverses. -/
theorem cyclic_shift_inverse {n : ℕ} (hn : 0 < n) (x : Config n) :
    (fun i => (fun j => x (leftIdx hn j)) (rightIdx hn i)) = x ∧
    (fun i => (fun j => x (rightIdx hn j)) (leftIdx hn i)) = x := by
  constructor <;> funext i <;> simp only
  · rw [leftIdx_rightIdx]
  · rw [rightIdx_leftIdx]

/-- Precomposition by cyclic successor is bijective. -/
theorem cyclic_right_shift_bijective {n : ℕ} (hn : 0 < n) :
    Function.Bijective (fun x : Config n => fun i => x (rightIdx hn i)) := by
  rw [Function.bijective_iff_has_inverse]
  refine ⟨(fun x i => x (leftIdx hn i)), ?_, ?_⟩
  · intro x
    exact (cyclic_shift_inverse hn x).2
  · intro x
    exact (cyclic_shift_inverse hn x).1

/-- Pointwise Boolean complement is an involution. -/
theorem complement_involutive {n : ℕ} :
    Function.Involutive (fun x : Config n => fun i => !x i) := by
  intro x
  funext i
  simp only [Bool.not_not]

/-- Complementing after a cyclic right shift is bijective. -/
theorem complemented_right_shift_bijective {n : ℕ} (hn : 0 < n) :
    Function.Bijective (fun x : Config n => fun i => !(x (rightIdx hn i))) := by
  have hs := cyclic_right_shift_bijective hn
  have hc := complement_involutive (n := n) |>.bijective
  exact hc.comp hs

/-- Complementing after a cyclic left shift is bijective. -/
theorem complemented_left_shift_bijective {n : ℕ} (hn : 0 < n) :
    Function.Bijective (fun x : Config n => fun i => !(x (leftIdx hn i))) := by
  have hr := complemented_right_shift_bijective hn
  rw [Function.bijective_iff_has_inverse] at hr ⊢
  refine ⟨(fun x i => !(x (rightIdx hn i))), ?_, ?_⟩ <;> intro x <;> funext i <;>
    simp only [Bool.not_not]
  · rw [leftIdx_rightIdx]
  · rw [rightIdx_leftIdx]

/-- The six named Wolfram rules are exactly projections or complemented projections. -/
theorem six_rule_formulas (hn : 0 < n) (x : Config n) :
    globalMap (wolframRule ⟨15, by decide⟩) hn x = (fun i => !(x (leftIdx hn i))) ∧
    globalMap (wolframRule ⟨51, by decide⟩) hn x = (fun i => !x i) ∧
    globalMap (wolframRule ⟨85, by decide⟩) hn x = (fun i => !(x (rightIdx hn i))) ∧
    globalMap (wolframRule ⟨170, by decide⟩) hn x = (fun i => x (rightIdx hn i)) ∧
    globalMap (wolframRule ⟨204, by decide⟩) hn x = x ∧
    globalMap (wolframRule ⟨240, by decide⟩) hn x = (fun i => x (leftIdx hn i)) := by
  repeat' apply And.intro
  all_goals
    funext i
    simp only [globalMap, wolframRule, neighborhoodIndex]
    cases hL : x (leftIdx hn i) <;> cases hC : x i <;>
      cases hR : x (rightIdx hn i) <;> decide

/-- Each of the six elementary projection/complement rules is reversible on every cycle. -/
theorem six_rules_universally_reversible :
    ∀ w ∈ ([15, 51, 85, 170, 204, 240] : List (Fin 256)), UniversallyReversible w := by
  intro w hw n hn
  simp at hw
  rcases hw with rfl | rfl | rfl | rfl | rfl | rfl
  · have hform : globalMap (wolframRule 15) hn =
        (fun x i => !(x (leftIdx hn i))) := funext fun x => (six_rule_formulas hn x).1
    rw [hform]
    exact complemented_left_shift_bijective hn
  · have hform : globalMap (wolframRule 51) hn =
        (fun x i => !x i) := funext fun x => (six_rule_formulas hn x).2.1
    rw [hform]
    exact (complement_involutive (n := n)).bijective
  · have hform : globalMap (wolframRule 85) hn =
        (fun x i => !(x (rightIdx hn i))) := funext fun x => (six_rule_formulas hn x).2.2.1
    rw [hform]
    exact complemented_right_shift_bijective hn
  · have hform : globalMap (wolframRule 170) hn =
        (fun x i => x (rightIdx hn i)) := funext fun x => (six_rule_formulas hn x).2.2.2.1
    rw [hform]
    exact cyclic_right_shift_bijective hn
  · have hform : globalMap (wolframRule 204) hn = id := by
      funext x
      exact (six_rule_formulas hn x).2.2.2.2.1
    rw [hform]
    exact Function.bijective_id
  · have hform : globalMap (wolframRule 240) hn =
        (fun x i => x (leftIdx hn i)) := funext fun x => (six_rule_formulas hn x).2.2.2.2.2
    rw [hform, Function.bijective_iff_has_inverse]
    refine ⟨(fun x i => x (rightIdx hn i)), ?_, ?_⟩ <;> intro x <;> funext i <;> simp only
    · rw [leftIdx_rightIdx]
    · rw [rightIdx_leftIdx]

/-- Exhaustive finite calculation: bijectivity on cycles 1 through 4 leaves exactly six rules. -/
theorem reversible_small_cycles_iff (w : Fin 256) :
    (ReversibleOn 1 w ∧ ReversibleOn 2 w ∧ ReversibleOn 3 w ∧ ReversibleOn 4 w) ↔
      w ∈ ([15, 51, 85, 170, 204, 240] : List (Fin 256)) := by
  constructor
  · fin_cases w <;> decide
  · intro hw
    have hu := six_rules_universally_reversible w hw
    constructor
    · simpa [ReversibleOn] using hu 1 (by omega)
    constructor
    · simpa [ReversibleOn] using hu 2 (by omega)
    constructor
    · simpa [ReversibleOn] using hu 3 (by omega)
    · simpa [ReversibleOn] using hu 4 (by omega)

/-- Every elementary rule outside the six-rule list already fails injectivity or
surjectivity on a cycle of length at most four. -/
theorem short_period_obstruction (w : Fin 256)
    (hw : w ∉ ([15, 51, 85, 170, 204, 240] : List (Fin 256))) :
    ∃ n ∈ ({1, 2, 3, 4} : Finset ℕ), ¬ ReversibleOn n w := by
  have hw' : ¬ (ReversibleOn 1 w ∧ ReversibleOn 2 w ∧
      ReversibleOn 3 w ∧ ReversibleOn 4 w) := by
    intro h
    exact hw ((reversible_small_cycles_iff w).mp h)
  have hor : ¬ ReversibleOn 1 w ∨ ¬ ReversibleOn 2 w ∨
      ¬ ReversibleOn 3 w ∨ ¬ ReversibleOn 4 w := by
    tauto
  rcases hor with h1 | h2 | h3 | h4
  · exact ⟨1, by decide, h1⟩
  · exact ⟨2, by decide, h2⟩
  · exact ⟨3, by decide, h3⟩
  · exact ⟨4, by decide, h4⟩

/-- Classification for universal finite-cycle reversibility. -/
theorem universally_reversible_iff (w : Fin 256) :
    UniversallyReversible w ↔
      w ∈ ([15, 51, 85, 170, 204, 240] : List (Fin 256)) := by
  constructor
  · intro hu
    by_contra hw
    obtain ⟨n, hn, hbad⟩ := short_period_obstruction w hw
    have hnpos : 0 < n := by fin_cases hn <;> omega
    exact hbad (by simp only [ReversibleOn, dif_pos hnpos]; exact hu n hnpos)
  · intro hw
    exact six_rules_universally_reversible w hw

/-- A Boolean radius-one rule is coordinate-permutative when it reads exactly
one neighborhood coordinate through a permutation of the Boolean alphabet. -/
def IsSingleCoordinate (f : LocalRule) : Prop :=
  (∃ e : Equiv.Perm Bool, ∀ l c r, f l c r = e l) ∨
  (∃ e : Equiv.Perm Bool, ∀ l c r, f l c r = e c) ∨
  (∃ e : Equiv.Perm Bool, ∀ l c r, f l c r = e r)

instance (f : LocalRule) : Decidable (IsSingleCoordinate f) := by
  unfold IsSingleCoordinate
  infer_instance

/-- The six Wolfram rules are exactly the coordinate-permutative local rules. -/
theorem wolfram_single_coordinate_iff (w : Fin 256) :
    IsSingleCoordinate (wolframRule w) ↔
      w ∈ ([15, 51, 85, 170, 204, 240] : List (Fin 256)) := by
  fin_cases w <;> decide

/-- Complete local-rule characterization: an elementary Boolean CA is reversible
on every finite cycle exactly when its local rule reads one coordinate through
an alphabet permutation. -/
theorem universally_reversible_iff_single_coordinate (w : Fin 256) :
    UniversallyReversible w ↔ IsSingleCoordinate (wolframRule w) := by
  rw [universally_reversible_iff, wolfram_single_coordinate_iff]

/-! ## Alphabet-independent reversible dynamics

The elementary classification above is binary, but its positive mechanism does
not depend on the alphabet being Boolean. A local rule that reads one site and
then applies an alphabet permutation is reversible over every alphabet.
-/

/-- Configurations over an arbitrary alphabet. -/
abbrev ConfigOver (α : Type*) (n : ℕ) := Fin n → α

/-- Radius-one local rules over an arbitrary alphabet. -/
abbrev LocalRuleOver (α : Type*) := α → α → α → α

/-- The cyclic global map of an arbitrary-alphabet radius-one rule. -/
def globalMapOver {α : Type*} (f : LocalRuleOver α) {n : ℕ} (hn : 0 < n)
    (x : ConfigOver α n) : ConfigOver α n :=
  fun i => f (x (leftIdx hn i)) (x i) (x (rightIdx hn i))

/-- Applying an alphabet equivalence after permuting the sites is an equivalence
of configuration spaces. -/
def coordinateAlphabetEquiv {α : Type*} {n : ℕ}
    (p : Equiv.Perm (Fin n)) (e : Equiv.Perm α) :
    ConfigOver α n ≃ ConfigOver α n where
  toFun x i := e (x (p i))
  invFun x i := e.symm (x (p.symm i))
  left_inv x := by
    funext i
    simp
  right_inv x := by
    funext i
    simp

/-- Configuration equivalences compose by independent composition of site and
alphabet permutations. -/
theorem coordinateAlphabetEquiv_trans {α : Type*} {n : ℕ}
    (p q : Equiv.Perm (Fin n)) (e d : Equiv.Perm α) :
    (coordinateAlphabetEquiv p e).trans (coordinateAlphabetEquiv q d) =
      coordinateAlphabetEquiv (p * q) (d * e) := by
  ext x i
  change d (e (x (p (q i)))) = d (e (x (p (q i))))
  rfl

/-- A radius-one rule obtained by applying an alphabet permutation to any one
of its three inputs has bijective dynamics on every nonempty finite cycle. -/
theorem single_coordinate_rule_bijective {α : Type*} {n : ℕ} (hn : 0 < n)
    (f : LocalRuleOver α) (e : Equiv.Perm α)
    (hf : (∀ l c r, f l c r = e l) ∨
      (∀ l c r, f l c r = e c) ∨
      (∀ l c r, f l c r = e r)) :
    Function.Bijective (globalMapOver f hn) := by
  rw [Function.bijective_iff_has_inverse]
  rcases hf with hl | hc | hr
  · refine ⟨(fun x i => e.symm (x (rightIdx hn i))), ?_, ?_⟩
    · intro x
      funext i
      simp only [globalMapOver, hl, Equiv.symm_apply_apply, leftIdx_rightIdx]
    · intro x
      funext i
      simp only [globalMapOver, hl, rightIdx_leftIdx, Equiv.apply_symm_apply]
  · refine ⟨(fun x i => e.symm (x i)), ?_, ?_⟩
    · intro x
      funext i
      simp only [globalMapOver, hc, Equiv.symm_apply_apply]
    · intro x
      funext i
      simp only [globalMapOver, hc, Equiv.apply_symm_apply]
  · refine ⟨(fun x i => e.symm (x (leftIdx hn i))), ?_, ?_⟩
    · intro x
      funext i
      simp only [globalMapOver, hr, Equiv.symm_apply_apply, rightIdx_leftIdx]
    · intro x
      funext i
      simp only [globalMapOver, hr, leftIdx_rightIdx, Equiv.apply_symm_apply]

/-- The inverse dynamics of a left-reading permutative rule is the right shift
followed by the inverse alphabet permutation. -/
theorem left_rule_explicit_inverse {α : Type*} {n : ℕ} (hn : 0 < n)
    (f : LocalRuleOver α) (e : Equiv.Perm α)
    (hf : ∀ l c r, f l c r = e l) :
    Function.LeftInverse
      (fun x i => e.symm (x (rightIdx hn i)))
      (globalMapOver f hn) ∧
    Function.RightInverse
      (fun x i => e.symm (x (rightIdx hn i)))
      (globalMapOver f hn) := by
  constructor <;> intro x <;> funext i
  · simp only [globalMapOver, hf, Equiv.symm_apply_apply, leftIdx_rightIdx]
  · simp only [globalMapOver, hf, rightIdx_leftIdx, Equiv.apply_symm_apply]

end ReversibleElementary