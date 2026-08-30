import Mathlib

/-!
# The Berggren / Price tree of primitive Pythagorean triples: nodes, letters, blindness

This file develops the ternary Berggren tree in its Price coordinates: nodes are
pairs `(m, n)` with `m > n ≥ 1`, `gcd m n = 1` and `m + n` odd, the root is `(2,1)`,
and the three children of `(m, n)` are

* `A : (m, n) ↦ (2m - n, m)`,
* `B : (m, n) ↦ (2m + n, m)`,
* `C : (m, n) ↦ (m + 2n, n)`.

The triple attached to a node is `(m² - n², 2mn, m² + n²)`.

Main results.

* `isNode_childA/B/C`, `parent_*` : the tree is well defined and every non-root node
  has a unique parent, given by the *ascent letter* `letterOf`.
* `isNode.inTree` : **coverage** — every node in the arithmetic sense is reachable
  from the root `(2,1)`; the letter of a node is exactly the branch taken by its parent.
* `letterOf_blind_of_residue` : **residue dials are blind.**  For *every* modulus
  `M ≥ 1` and every scale `t ≥ 1` there are three nodes with hypotenuses all
  congruent to `1 mod M` and with the three distinct ascent letters.  Hence no
  function of `hyp mod M` computes the ascent letter (`residue_dial_letterBlind`),
  in particular no Gauss-sum style dial on `N mod 720720`.
* `letterOf_blind_of_magnitude` : **magnitude mirrors are blind.**  There is an
  infinite family of hypotenuses realised by two different nodes with *different*
  letters, e.g. `505 = 19² + 12² = 21² + 8² = 5 · 101`.  Hence no function of the
  hypotenuse itself — monotone or not — computes the ascent letter
  (`magnitude_probe_letterBlind`).
* `parityProfile_constant` : structural sensors (leg parities, Lorentz form) are
  *exactly* constant on the tree, so they are blind for trivial reasons.
-/

namespace TwoTreeClosure

/-! ### Nodes -/

/-- A Price/Berggren node: `m > n ≥ 1`, coprime, of opposite parity. -/
def IsNode (m n : ℕ) : Prop :=
  1 ≤ n ∧ n < m ∧ Nat.Coprime m n ∧ (m + n) % 2 = 1

/-- The hypotenuse attached to a node. -/
def hyp (m n : ℕ) : ℕ := m ^ 2 + n ^ 2

/-- The odd leg attached to a node. -/
def legOdd (m n : ℕ) : ℕ := m ^ 2 - n ^ 2

/-- The even leg attached to a node. -/
def legEven (m n : ℕ) : ℕ := 2 * m * n

/-- The Euclid triple of a node is Pythagorean (stated over `ℤ`, where the
subtraction is unproblematic). -/
theorem euclid_pythag (m n : ℕ) :
    ((m : ℤ) ^ 2 - (n : ℤ) ^ 2) ^ 2 + (2 * (m : ℤ) * (n : ℤ)) ^ 2
      = ((m : ℤ) ^ 2 + (n : ℤ) ^ 2) ^ 2 := by
  ring

/-- The natural-number version of `euclid_pythag`, valid at every node. -/
theorem legOdd_sq_add_legEven_sq (m n : ℕ) (h : IsNode m n) :
    legOdd m n ^ 2 + legEven m n ^ 2 = hyp m n ^ 2 := by
  obtain ⟨-, hnm, -, -⟩ := h
  have hle : n ^ 2 ≤ m ^ 2 := Nat.pow_le_pow_left hnm.le 2
  have hcast : ((legOdd m n : ℕ) : ℤ) = (m : ℤ) ^ 2 - (n : ℤ) ^ 2 := by
    simp only [legOdd]
    push_cast [hle]
    ring
  have : ((legOdd m n ^ 2 + legEven m n ^ 2 : ℕ) : ℤ) = ((hyp m n ^ 2 : ℕ) : ℤ) := by
    push_cast [hcast, legEven, hyp]
    ring
  exact_mod_cast this

/-! ### Children -/

/-- Berggren/Price child `A`. -/
def childA (m n : ℕ) : ℕ × ℕ := (2 * m - n, m)
/-- Berggren/Price child `B`. -/
def childB (m n : ℕ) : ℕ × ℕ := (2 * m + n, m)
/-- Berggren/Price child `C`. -/
def childC (m n : ℕ) : ℕ × ℕ := (m + 2 * n, n)

private lemma coprime_two_mul_sub {m n : ℕ} (h : Nat.Coprime m n) (hle : n ≤ 2 * m) :
    Nat.Coprime (2 * m - n) m := by
  have h1 : Nat.gcd (2 * m - n) m ∣ 2 * m - n := Nat.gcd_dvd_left _ _
  have h2 : Nat.gcd (2 * m - n) m ∣ m := Nat.gcd_dvd_right _ _
  have h3 : Nat.gcd (2 * m - n) m ∣ 2 * m := h2.mul_left 2
  have h4 : Nat.gcd (2 * m - n) m ∣ n := by
    have := Nat.dvd_sub h3 h1
    simpa [show 2 * m - (2 * m - n) = n from by omega] using this
  have h5 : Nat.gcd (2 * m - n) m ∣ Nat.gcd m n := Nat.dvd_gcd h2 h4
  exact Nat.eq_one_of_dvd_one (h ▸ h5)

private lemma coprime_two_mul_add {m n : ℕ} (h : Nat.Coprime m n) :
    Nat.Coprime (2 * m + n) m := by
  have h1 : Nat.gcd (2 * m + n) m ∣ 2 * m + n := Nat.gcd_dvd_left _ _
  have h2 : Nat.gcd (2 * m + n) m ∣ m := Nat.gcd_dvd_right _ _
  have h3 : Nat.gcd (2 * m + n) m ∣ 2 * m := h2.mul_left 2
  have h4 : Nat.gcd (2 * m + n) m ∣ n := by
    have := Nat.dvd_sub h1 h3
    simpa using this
  have h5 : Nat.gcd (2 * m + n) m ∣ Nat.gcd m n := Nat.dvd_gcd h2 h4
  exact Nat.eq_one_of_dvd_one (h ▸ h5)

private lemma coprime_add_two_mul {m n : ℕ} (h : Nat.Coprime m n) :
    Nat.Coprime (m + 2 * n) n := by
  have h1 : Nat.gcd (m + 2 * n) n ∣ m + 2 * n := Nat.gcd_dvd_left _ _
  have h2 : Nat.gcd (m + 2 * n) n ∣ n := Nat.gcd_dvd_right _ _
  have h3 : Nat.gcd (m + 2 * n) n ∣ 2 * n := h2.mul_left 2
  have h4 : Nat.gcd (m + 2 * n) n ∣ m := by
    have := Nat.dvd_sub h1 h3
    simpa using this
  have h5 : Nat.gcd (m + 2 * n) n ∣ Nat.gcd m n := Nat.dvd_gcd h4 h2
  exact Nat.eq_one_of_dvd_one (h ▸ h5)

theorem isNode_childA {m n : ℕ} (h : IsNode m n) : IsNode (2 * m - n) m := by
  obtain ⟨hn, hnm, hcop, hpar⟩ := h
  exact ⟨by omega, by omega, coprime_two_mul_sub hcop (by omega), by omega⟩

theorem isNode_childB {m n : ℕ} (h : IsNode m n) : IsNode (2 * m + n) m := by
  obtain ⟨hn, hnm, hcop, hpar⟩ := h
  exact ⟨by omega, by omega, coprime_two_mul_add hcop, by omega⟩

theorem isNode_childC {m n : ℕ} (h : IsNode m n) : IsNode (m + 2 * n) n := by
  obtain ⟨hn, hnm, hcop, hpar⟩ := h
  exact ⟨by omega, by omega, coprime_add_two_mul hcop, by omega⟩

/-! ### Ascent letters -/

/-- The three branch letters. -/
inductive Letter | A | B | C
  deriving DecidableEq, Repr

/-- The ascent letter of a node: which of the three branches produced it.  It is a
pure ratio test: `A` for `n < m < 2n`, `B` for `2n < m < 3n`, `C` for `m > 3n`. -/
def letterOf (m n : ℕ) : Letter :=
  if m < 2 * n then Letter.A else if m < 3 * n then Letter.B else Letter.C

theorem letterOf_eq_A {m n : ℕ} (h : m < 2 * n) : letterOf m n = Letter.A := by
  simp [letterOf, h]

theorem letterOf_eq_B {m n : ℕ} (h1 : 2 * n < m) (h2 : m < 3 * n) :
    letterOf m n = Letter.B := by
  simp [letterOf, h2]
  omega

theorem letterOf_eq_C {m n : ℕ} (h : 3 * n < m) : letterOf m n = Letter.C := by
  simp only [letterOf]
  rw [if_neg (by omega), if_neg (by omega)]

/-! ### Reachability from the root, and coverage -/

/-- Reachability in the Berggren/Price tree from the root `(2,1)`. -/
inductive InTree : ℕ → ℕ → Prop
  | root : InTree 2 1
  | stepA {m n : ℕ} : InTree m n → InTree (2 * m - n) m
  | stepB {m n : ℕ} : InTree m n → InTree (2 * m + n) m
  | stepC {m n : ℕ} : InTree m n → InTree (m + 2 * n) n

/-- Degenerate ratios cannot occur at a node except at the root. -/
theorem node_ratio_trichotomy {m n : ℕ} (h : IsNode m n) (hroot : ¬ (m = 2 ∧ n = 1)) :
    (n < m ∧ m < 2 * n) ∨ (2 * n < m ∧ m < 3 * n) ∨ 3 * n < m := by
  obtain ⟨hn, hnm, hcop, hpar⟩ := h
  rcases lt_trichotomy m (2 * n) with h1 | h1 | h1
  · exact Or.inl ⟨hnm, h1⟩
  · -- `m = 2n` forces `n ∣ m`, hence `n = 1` and we are at the root
    exfalso
    have hdvd : n ∣ m := ⟨2, by omega⟩
    have : n ∣ Nat.gcd m n := Nat.dvd_gcd hdvd dvd_rfl
    rw [hcop] at this
    have : n = 1 := Nat.eq_one_of_dvd_one this
    exact hroot ⟨by omega, this⟩
  · rcases lt_trichotomy m (3 * n) with h2 | h2 | h2
    · exact Or.inr (Or.inl ⟨h1, h2⟩)
    · -- `m = 3n` forces `n = 1`, and then the parity condition fails
      exfalso
      have hdvd : n ∣ m := ⟨3, by omega⟩
      have : n ∣ Nat.gcd m n := Nat.dvd_gcd hdvd dvd_rfl
      rw [hcop] at this
      have hn1 : n = 1 := Nat.eq_one_of_dvd_one this
      omega
    · exact Or.inr (Or.inr h2)

/-- Parent of an `A`-node is a node. -/
theorem isNode_parentA {m n : ℕ} (h : IsNode m n) (h1 : n < m) (h2 : m < 2 * n) :
    IsNode n (2 * n - m) := by
  obtain ⟨hn, hnm, hcop, hpar⟩ := h
  refine ⟨by omega, by omega, ?_, by omega⟩
  have hcop' : Nat.Coprime n m := Nat.Coprime.symm hcop
  have h1' : Nat.gcd n (2 * n - m) ∣ n := Nat.gcd_dvd_left _ _
  have h2' : Nat.gcd n (2 * n - m) ∣ (2 * n - m) := Nat.gcd_dvd_right _ _
  have h3' : Nat.gcd n (2 * n - m) ∣ 2 * n := h1'.mul_left 2
  have h4' : Nat.gcd n (2 * n - m) ∣ m := by
    have := Nat.dvd_sub h3' h2'
    simpa [show 2 * n - (2 * n - m) = m from by omega] using this
  have h5' : Nat.gcd n (2 * n - m) ∣ Nat.gcd n m := Nat.dvd_gcd h1' h4'
  exact Nat.eq_one_of_dvd_one (hcop' ▸ h5')

/-- Parent of a `B`-node is a node. -/
theorem isNode_parentB {m n : ℕ} (h : IsNode m n) (h1 : 2 * n < m) (h2 : m < 3 * n) :
    IsNode n (m - 2 * n) := by
  obtain ⟨hn, hnm, hcop, hpar⟩ := h
  refine ⟨by omega, by omega, ?_, by omega⟩
  have hcop' : Nat.Coprime n m := Nat.Coprime.symm hcop
  have h1' : Nat.gcd n (m - 2 * n) ∣ n := Nat.gcd_dvd_left _ _
  have h2' : Nat.gcd n (m - 2 * n) ∣ (m - 2 * n) := Nat.gcd_dvd_right _ _
  have h3' : Nat.gcd n (m - 2 * n) ∣ 2 * n := h1'.mul_left 2
  have h4' : Nat.gcd n (m - 2 * n) ∣ m := by
    have := Nat.dvd_add h2' h3'
    simpa [show m - 2 * n + 2 * n = m from by omega] using this
  have h5' : Nat.gcd n (m - 2 * n) ∣ Nat.gcd n m := Nat.dvd_gcd h1' h4'
  exact Nat.eq_one_of_dvd_one (hcop' ▸ h5')

/-- Parent of a `C`-node is a node. -/
theorem isNode_parentC {m n : ℕ} (h : IsNode m n) (h1 : 3 * n < m) :
    IsNode (m - 2 * n) n := by
  obtain ⟨hn, hnm, hcop, hpar⟩ := h
  refine ⟨by omega, by omega, ?_, by omega⟩
  have h1' : Nat.gcd (m - 2 * n) n ∣ (m - 2 * n) := Nat.gcd_dvd_left _ _
  have h2' : Nat.gcd (m - 2 * n) n ∣ n := Nat.gcd_dvd_right _ _
  have h3' : Nat.gcd (m - 2 * n) n ∣ 2 * n := h2'.mul_left 2
  have h4' : Nat.gcd (m - 2 * n) n ∣ m := by
    have := Nat.dvd_add h1' h3'
    simpa [show m - 2 * n + 2 * n = m from by omega] using this
  have h5' : Nat.gcd (m - 2 * n) n ∣ Nat.gcd m n := Nat.dvd_gcd h4' h2'
  exact Nat.eq_one_of_dvd_one (hcop ▸ h5')

/-- **Coverage.** Every arithmetic node is reachable from the root of the tree.
The descent is by strong induction on the larger coordinate, using the ascent
letter to select the parent. -/
theorem IsNode.inTree : ∀ m : ℕ, ∀ n : ℕ, IsNode m n → InTree m n := by
  intro m
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    intro n h
    by_cases hroot : m = 2 ∧ n = 1
    · obtain ⟨rfl, rfl⟩ := hroot
      exact InTree.root
    · rcases node_ratio_trichotomy h hroot with ⟨h1, h2⟩ | ⟨h1, h2⟩ | h1
      · have hp := isNode_parentA h h1 h2
        have hlt : n < m := h1
        have := (ih n hlt (2 * n - m) hp).stepA
        rwa [show 2 * n - (2 * n - m) = m from by omega] at this
      · have hp := isNode_parentB h h1 h2
        have hlt : n < m := by omega
        have := (ih n hlt (m - 2 * n) hp).stepB
        rwa [show 2 * n + (m - 2 * n) = m from by omega] at this
      · have hp := isNode_parentC h h1
        have hn : 1 ≤ n := h.1
        have hlt : m - 2 * n < m := by omega
        have := (ih (m - 2 * n) hlt n hp).stepC
        rwa [show m - 2 * n + 2 * n = m from by omega] at this

/-- The ascent letter really names the branch: an `A`-node is the `A`-child of its
parent, and likewise for `B` and `C`. -/
theorem letter_names_branch {m n : ℕ} (h : IsNode m n) (hroot : ¬ (m = 2 ∧ n = 1)) :
    (letterOf m n = Letter.A ∧ IsNode n (2 * n - m) ∧ (2 * n - (2 * n - m), n) = (m, n)) ∨
    (letterOf m n = Letter.B ∧ IsNode n (m - 2 * n) ∧ (2 * n + (m - 2 * n), n) = (m, n)) ∨
    (letterOf m n = Letter.C ∧ IsNode (m - 2 * n) n ∧ (m - 2 * n + 2 * n, n) = (m, n)) := by
  rcases node_ratio_trichotomy h hroot with ⟨h1, h2⟩ | ⟨h1, h2⟩ | h1
  · exact Or.inl ⟨letterOf_eq_A h2, isNode_parentA h h1 h2, by simp; omega⟩
  · exact Or.inr (Or.inl ⟨letterOf_eq_B h1 h2, isNode_parentB h h1 h2, by simp; omega⟩)
  · exact Or.inr (Or.inr ⟨letterOf_eq_C h1, isNode_parentC h h1, by simp; omega⟩)

/-! ### Blindness -/

/-- A sensor `s` on nodes is *letter blind* if it takes the same value at two nodes
carrying different ascent letters: no decision rule based on `s` can output the
letter. -/
def LetterBlind {β : Type} (s : ℕ → ℕ → β) : Prop :=
  ∃ m n m' n', IsNode m n ∧ IsNode m' n' ∧ s m n = s m' n' ∧ letterOf m n ≠ letterOf m' n'

/-! #### Strength 1–2: residue dials -/

/-- **Residue dials are blind, at every modulus and every scale.**  Let `M ≥ 1` and
let `n ≥ 2` be even with `M ∣ n`.  The three nodes `(n+1, n)`, `(2n+1, n)`,
`(3n+1, n)` have the three distinct ascent letters and their hypotenuses are all
congruent to `1` mod `M`. -/
theorem letterOf_blind_of_residue (M n : ℕ) (hn2 : 2 ≤ n) (hne : n % 2 = 0)
    (hMn : M ∣ n) :
    letterOf (n + 1) n = Letter.A ∧
    letterOf (2 * n + 1) n = Letter.B ∧
    letterOf (3 * n + 1) n = Letter.C ∧
    IsNode (n + 1) n ∧ IsNode (2 * n + 1) n ∧ IsNode (3 * n + 1) n ∧
    hyp (n + 1) n % M = 1 % M ∧
    hyp (2 * n + 1) n % M = 1 % M ∧
    hyp (3 * n + 1) n % M = 1 % M := by
  have hcop1 : Nat.Coprime (n + 1) n := by simp
  have hcop2 : Nat.Coprime (2 * n + 1) n := by simp
  have hcop3 : Nat.Coprime (3 * n + 1) n := by simp
  obtain ⟨c, hc⟩ := hMn
  refine ⟨letterOf_eq_A (by omega), letterOf_eq_B (by omega) (by omega),
    letterOf_eq_C (by omega), ⟨by omega, by omega, hcop1, by omega⟩,
    ⟨by omega, by omega, hcop2, by omega⟩, ⟨by omega, by omega, hcop3, by omega⟩, ?_, ?_, ?_⟩
  · have e : hyp (n + 1) n = 1 + M * (M * (2 * c ^ 2) + 2 * c) := by
      simp only [hyp, hc]; ring
    rw [e, Nat.add_mul_mod_self_left]
  · have e : hyp (2 * n + 1) n = 1 + M * (M * (5 * c ^ 2) + 4 * c) := by
      simp only [hyp, hc]; ring
    rw [e, Nat.add_mul_mod_self_left]
  · have e : hyp (3 * n + 1) n = 1 + M * (M * (10 * c ^ 2) + 6 * c) := by
      simp only [hyp, hc]; ring
    rw [e, Nat.add_mul_mod_self_left]

/-- For every modulus there is such a scale: `n = 2 * M * t`. -/
theorem residue_scale_exists (M t : ℕ) (hM : 1 ≤ M) (ht : 1 ≤ t) :
    2 ≤ 2 * M * t ∧ (2 * M * t) % 2 = 0 ∧ M ∣ 2 * M * t := by
  have hfac : 2 * M * t = 2 * (M * t) := by ring
  have hpos : 1 ≤ M * t := Nat.one_le_iff_ne_zero.2 (by positivity)
  exact ⟨by omega, by omega, ⟨2 * t, by ring⟩⟩

/-- **No residue dial computes the ascent letter.**  For every modulus `M ≥ 1`, no
function of the hypotenuse's residue mod `M` agrees with the ascent letter on all
nodes.  (Applies verbatim to the Gauss-sum dial modulus `M = 720720`.) -/
theorem residue_dial_letterBlind (M : ℕ) (hM : 1 ≤ M) (g : ℕ → Letter) :
    ¬ (∀ m n, IsNode m n → g (hyp m n % M) = letterOf m n) := by
  intro hg
  obtain ⟨hs2, hse, hsd⟩ := residue_scale_exists M 1 hM le_rfl
  obtain ⟨hA, hB, -, hnA, hnB, -, hrA, hrB, -⟩ :=
    letterOf_blind_of_residue M (2 * M * 1) hs2 hse hsd
  have e1 := hg _ _ hnA
  have e2 := hg _ _ hnB
  rw [hA] at e1
  rw [hB] at e2
  rw [hrA] at e1
  rw [hrB] at e2
  rw [e1] at e2
  exact Letter.noConfusion e2

/-- The Gauss-sum magnitude dial (any function of `N mod 720720`) is letter blind. -/
theorem gaussDial_letterBlind (g : ℕ → Letter) :
    ¬ (∀ m n, IsNode m n → g (hyp m n % 720720) = letterOf m n) :=
  residue_dial_letterBlind 720720 (by norm_num) g

/-! #### Strength 4: magnitude mirrors -/

/-- **Magnitude mirrors are blind.**  For every `t ≥ 1` the two nodes
`(20t - 1, 10t + 2)` and `(20t + 1, 10t - 2)` share the hypotenuse `500t² + 5`
but carry the letters `A` and `B`.  At `t = 1` this is `505 = 19² + 12² = 21² + 8²`. -/
theorem letterOf_blind_of_magnitude (t : ℕ) (ht : 1 ≤ t) :
    IsNode (20 * t - 1) (10 * t + 2) ∧ IsNode (20 * t + 1) (10 * t - 2) ∧
    hyp (20 * t - 1) (10 * t + 2) = hyp (20 * t + 1) (10 * t - 2) ∧
    letterOf (20 * t - 1) (10 * t + 2) = Letter.A ∧
    letterOf (20 * t + 1) (10 * t - 2) = Letter.B := by
  have hcop1 : Nat.Coprime (20 * t - 1) (10 * t + 2) := by
    have h1 : Nat.gcd (20 * t - 1) (10 * t + 2) ∣ 20 * t - 1 := Nat.gcd_dvd_left _ _
    have h2 : Nat.gcd (20 * t - 1) (10 * t + 2) ∣ 10 * t + 2 := Nat.gcd_dvd_right _ _
    have h3 : Nat.gcd (20 * t - 1) (10 * t + 2) ∣ 20 * t + 4 := by
      have := h2.mul_left 2
      simpa [show 2 * (10 * t + 2) = 20 * t + 4 from by ring] using this
    have h5 : Nat.gcd (20 * t - 1) (10 * t + 2) ∣ 5 := by
      have := Nat.dvd_sub h3 h1
      simpa [show 20 * t + 4 - (20 * t - 1) = 5 from by omega] using this
    -- a divisor of `5` dividing `20t - 1` must be `1`, since `5 ∤ 20t - 1`
    rcases (Nat.Prime.eq_one_or_self_of_dvd (by norm_num) _ h5) with h | h
    · exact h
    · exfalso
      rw [h] at h1
      omega
  have hcop2 : Nat.Coprime (20 * t + 1) (10 * t - 2) := by
    have h1 : Nat.gcd (20 * t + 1) (10 * t - 2) ∣ 20 * t + 1 := Nat.gcd_dvd_left _ _
    have h2 : Nat.gcd (20 * t + 1) (10 * t - 2) ∣ 10 * t - 2 := Nat.gcd_dvd_right _ _
    have h3 : Nat.gcd (20 * t + 1) (10 * t - 2) ∣ 20 * t - 4 := by
      have := h2.mul_left 2
      simpa [show 2 * (10 * t - 2) = 20 * t - 4 from by omega] using this
    have h5 : Nat.gcd (20 * t + 1) (10 * t - 2) ∣ 5 := by
      have := Nat.dvd_sub h1 h3
      simpa [show 20 * t + 1 - (20 * t - 4) = 5 from by omega] using this
    rcases (Nat.Prime.eq_one_or_self_of_dvd (by norm_num) _ h5) with h | h
    · exact h
    · exfalso
      rw [h] at h1
      omega
  refine ⟨⟨by omega, by omega, hcop1, by omega⟩, ⟨by omega, by omega, hcop2, by omega⟩, ?_,
    letterOf_eq_A (by omega), letterOf_eq_B (by omega) (by omega)⟩
  obtain ⟨s, hs⟩ : ∃ s, t = s + 1 := ⟨t - 1, by omega⟩
  subst hs
  simp only [hyp]
  have e1 : 20 * (s + 1) - 1 = 20 * s + 19 := by omega
  have e2 : 10 * (s + 1) + 2 = 10 * s + 12 := by omega
  have e3 : 20 * (s + 1) + 1 = 20 * s + 21 := by omega
  have e4 : 10 * (s + 1) - 2 = 10 * s + 8 := by omega
  rw [e1, e2, e3, e4]
  ring

/-- **No probe reading only the magnitude computes the ascent letter.**  This seals
the "spectral summary" class: any statistic that is a function of the hypotenuse
alone — monotone in `|N|` or not — fails on the family of
`letterOf_blind_of_magnitude`. -/
theorem magnitude_probe_letterBlind (f : ℕ → Letter) :
    ¬ (∀ m n, IsNode m n → f (hyp m n) = letterOf m n) := by
  intro hf
  obtain ⟨h1, h2, hh, hA, hB⟩ := letterOf_blind_of_magnitude 1 le_rfl
  have e1 := hf _ _ h1
  have e2 := hf _ _ h2
  rw [hA] at e1
  rw [hB] at e2
  rw [hh, e2] at e1
  exact Letter.noConfusion e1

/-- The magnitude witness at `t = 1` is a genuine semiprime: `505 = 5 * 101`. -/
theorem magnitude_witness_semiprime :
    hyp 19 12 = 505 ∧ hyp 21 8 = 505 ∧ (505 : ℕ) = 5 * 101 ∧ Nat.Prime 5 ∧ Nat.Prime 101 := by
  refine ⟨by norm_num [hyp], by norm_num [hyp], by norm_num, by norm_num, by norm_num⟩

/-- Every residue dial is in particular a magnitude probe, so
`magnitude_probe_letterBlind` implies the residue statement; the direct proof above
is kept because it exhibits all three letters inside one residue class. -/
theorem magnitude_blind_implies_residue_blind (M : ℕ) (hM : 1 ≤ M) (g : ℕ → Letter) :
    ¬ (∀ m n, IsNode m n → g (hyp m n % M) = letterOf m n) :=
  residue_dial_letterBlind M hM g

/-! #### Strength 3: structurally constant sensors -/

/-- The parity profile of the Euclid triple of a node. -/
def parityProfile (m n : ℕ) : ℕ × ℕ × ℕ := (legOdd m n % 2, legEven m n % 2, hyp m n % 2)

/-- **Structural constancy.**  The parity profile is *exactly* `(1, 0, 1)` at every
node: the sensor is constant, hence carries zero information (mutual information
`0.000000`, as measured empirically). -/
theorem parityProfile_constant {m n : ℕ} (h : IsNode m n) : parityProfile m n = (1, 0, 1) := by
  obtain ⟨hn, hnm, hcop, hpar⟩ := h
  have hsq : n ^ 2 ≤ m ^ 2 := Nat.pow_le_pow_left hnm.le 2
  have hm2 : m ^ 2 % 2 = m % 2 := by
    rcases Nat.even_or_odd m with ⟨k, hk⟩ | ⟨k, hk⟩ <;> subst hk <;>
      [ (have : (k + k) ^ 2 = 2 * (2 * k ^ 2) := by ring); (have : (2 * k + 1) ^ 2 = 2 * (2 * k ^ 2 + 2 * k) + 1 := by ring) ] <;> omega
  have hn2 : n ^ 2 % 2 = n % 2 := by
    rcases Nat.even_or_odd n with ⟨k, hk⟩ | ⟨k, hk⟩ <;> subst hk <;>
      [ (have : (k + k) ^ 2 = 2 * (2 * k ^ 2) := by ring); (have : (2 * k + 1) ^ 2 = 2 * (2 * k ^ 2 + 2 * k) + 1 := by ring) ] <;> omega
  have hev : legEven m n % 2 = 0 := by
    have : legEven m n = 2 * (m * n) := by simp only [legEven]; ring
    omega
  simp only [parityProfile, legOdd, hyp, hev, Prod.mk.injEq]
  refine ⟨by omega, ?_, by omega⟩
  trivial

/-- A constant sensor is letter blind: it cannot separate the `A`-node `(19,12)`
from the `B`-node `(21,8)`. -/
theorem parityProfile_letterBlind : LetterBlind parityProfile := by
  obtain ⟨h1, h2, -, hA, hB⟩ := letterOf_blind_of_magnitude 1 le_rfl
  refine ⟨20 * 1 - 1, 10 * 1 + 2, 20 * 1 + 1, 10 * 1 - 2, h1, h2, ?_, ?_⟩
  · rw [parityProfile_constant h1, parityProfile_constant h2]
  · rw [hA, hB]; exact Letter.noConfusion

/-- The Lorentz form of the Euclid triple vanishes identically: the "energy" sensor
of the tree is structurally constant, so it too is blind. -/
theorem lorentz_form_constant (m n : ℕ) :
    ((m : ℤ) ^ 2 - (n : ℤ) ^ 2) ^ 2 + (2 * (m : ℤ) * n) ^ 2 - ((m : ℤ) ^ 2 + (n : ℤ) ^ 2) ^ 2 = 0 := by
  ring

/-! ### Branching base: the tree is exactly ternary

The ascent letter of a child names the branch that produced it, so the three
children of a node are pairwise distinct and each child remembers its parent.
Consequently the depth-`h` descendant set of any node has exactly `3 ^ h`
elements: the branching base of the Berggren/Price tree is pinned at `3`.
-/

/-- The parent map, driven by the ascent letter. -/
def parentP (p : ℕ × ℕ) : ℕ × ℕ :=
  match letterOf p.1 p.2 with
  | Letter.A => (p.2, 2 * p.2 - p.1)
  | Letter.B => (p.2, p.1 - 2 * p.2)
  | Letter.C => (p.1 - 2 * p.2, p.2)

theorem letterOf_childA {m n : ℕ} (h : IsNode m n) : letterOf (2 * m - n) m = Letter.A := by
  obtain ⟨hn, hnm, -, -⟩ := h
  exact letterOf_eq_A (by omega)

theorem letterOf_childB {m n : ℕ} (h : IsNode m n) : letterOf (2 * m + n) m = Letter.B := by
  obtain ⟨hn, hnm, -, -⟩ := h
  exact letterOf_eq_B (by omega) (by omega)

theorem letterOf_childC {m n : ℕ} (h : IsNode m n) : letterOf (m + 2 * n) n = Letter.C := by
  obtain ⟨hn, hnm, -, -⟩ := h
  exact letterOf_eq_C (by omega)

theorem parentP_childA {m n : ℕ} (h : IsNode m n) : parentP (childA m n) = (m, n) := by
  have hn := h.1
  have hnm := h.2.1
  simp only [parentP, childA, letterOf_childA h]
  rw [show 2 * m - (2 * m - n) = n from by omega]

theorem parentP_childB {m n : ℕ} (h : IsNode m n) : parentP (childB m n) = (m, n) := by
  have hn := h.1
  have hnm := h.2.1
  simp only [parentP, childB, letterOf_childB h]
  rw [show 2 * m + n - 2 * m = n from by omega]

theorem parentP_childC {m n : ℕ} (h : IsNode m n) : parentP (childC m n) = (m, n) := by
  have hn := h.1
  have hnm := h.2.1
  simp only [parentP, childC, letterOf_childC h]
  rw [show m + 2 * n - 2 * n = m from by omega]

/-- The set of children of a node. -/
def childrenF (p : ℕ × ℕ) : Finset (ℕ × ℕ) :=
  {childA p.1 p.2, childB p.1 p.2, childC p.1 p.2}

/-- **Three distinct children.**  A node has exactly three children. -/
theorem card_childrenF {m n : ℕ} (h : IsNode m n) : (childrenF (m, n)).card = 3 := by
  obtain ⟨hn, hnm, -, -⟩ := h
  have hAB : childA m n ≠ childB m n := by
    simp only [childA, childB, ne_eq, Prod.mk.injEq, not_and]
    intro hc; omega
  have hAC : childA m n ≠ childC m n := by
    simp only [childA, childC, ne_eq, Prod.mk.injEq, not_and]
    intro _; omega
  have hBC : childB m n ≠ childC m n := by
    simp only [childB, childC, ne_eq, Prod.mk.injEq, not_and]
    intro _; omega
  simp [childrenF, hAB, hAC, hBC]

theorem children_isNode {m n : ℕ} (h : IsNode m n) :
    ∀ p ∈ childrenF (m, n), IsNode p.1 p.2 := by
  intro p hp
  simp only [childrenF, Finset.mem_insert, Finset.mem_singleton] at hp
  rcases hp with rfl | rfl | rfl
  · exact isNode_childA h
  · exact isNode_childB h
  · exact isNode_childC h

theorem parentP_of_mem_children {m n : ℕ} (h : IsNode m n) :
    ∀ p ∈ childrenF (m, n), parentP p = (m, n) := by
  intro p hp
  simp only [childrenF, Finset.mem_insert, Finset.mem_singleton] at hp
  rcases hp with rfl | rfl | rfl
  · exact parentP_childA h
  · exact parentP_childB h
  · exact parentP_childC h

/-- Depth-`h` descendants of a node. -/
def desc (p : ℕ × ℕ) : ℕ → Finset (ℕ × ℕ)
  | 0 => {p}
  | h + 1 => (desc p h).biUnion childrenF

theorem desc_isNode {m n : ℕ} (h : IsNode m n) :
    ∀ k : ℕ, ∀ p ∈ desc (m, n) k, IsNode p.1 p.2 := by
  intro k
  induction k with
  | zero => intro p hp; simp only [desc, Finset.mem_singleton] at hp; subst hp; exact h
  | succ k ih =>
      intro p hp
      simp only [desc, Finset.mem_biUnion] at hp
      obtain ⟨w, hw, hpw⟩ := hp
      have hwn : IsNode w.1 w.2 := ih w hw
      have : childrenF w = childrenF (w.1, w.2) := by simp
      rw [this] at hpw
      exact children_isNode hwn p hpw

/-- **Branching base pinned at 3.**  The depth-`h` descendant set of any node has
exactly `3 ^ h` elements, for every `h`. -/
theorem card_desc {m n : ℕ} (h : IsNode m n) : ∀ k : ℕ, (desc (m, n) k).card = 3 ^ k := by
  intro k
  induction k with
  | zero => simp [desc]
  | succ k ih =>
      have hdisj : ∀ x ∈ desc (m, n) k, ∀ y ∈ desc (m, n) k, x ≠ y →
          Disjoint (childrenF x) (childrenF y) := by
        intro x hx y hy hxy
        have hxn : IsNode x.1 x.2 := desc_isNode h k x hx
        have hyn : IsNode y.1 y.2 := desc_isNode h k y hy
        rw [Finset.disjoint_left]
        intro a hax hay
        have h1 : parentP a = x := by
          have : childrenF x = childrenF (x.1, x.2) := by simp
          rw [this] at hax
          simpa using parentP_of_mem_children hxn a hax
        have h2 : parentP a = y := by
          have : childrenF y = childrenF (y.1, y.2) := by simp
          rw [this] at hay
          simpa using parentP_of_mem_children hyn a hay
        exact hxy (h1 ▸ h2 ▸ rfl)
      have hcard : ∀ x ∈ desc (m, n) k, (childrenF x).card = 3 := by
        intro x hx
        have hxn : IsNode x.1 x.2 := desc_isNode h k x hx
        have : childrenF x = childrenF (x.1, x.2) := by simp
        rw [this]
        exact card_childrenF hxn
      calc (desc (m, n) (k + 1)).card
          = ∑ x ∈ desc (m, n) k, (childrenF x).card := by
            simp only [desc]
            exact Finset.card_biUnion hdisj
        _ = ∑ _x ∈ desc (m, n) k, 3 := Finset.sum_congr rfl hcard
        _ = 3 ^ k * 3 := by rw [Finset.sum_const, ih]; ring
        _ = 3 ^ (k + 1) := by ring

/-- Total number of nodes visited by an exhaustive search to depth `h`:
`2 * visits + 1 = 3 ^ (h + 1)`, i.e. the search cost is `(3^{h+1} - 1)/2`. -/
theorem sum_card_desc {m n : ℕ} (h : IsNode m n) (H : ℕ) :
    2 * (∑ k ∈ Finset.range (H + 1), (desc (m, n) k).card) + 1 = 3 ^ (H + 1) := by
  induction H with
  | zero => simp [card_desc h]
  | succ H ih =>
      rw [Finset.sum_range_succ]
      rw [card_desc h (H + 1)]
      have : 3 ^ (H + 1 + 1) = 3 * 3 ^ (H + 1) := by ring
      omega

/-! ### The tree is free: injective child maps with disjoint ranges -/

/-- The three child maps are injective on nodes. -/
theorem childMaps_injective {m n m' n' : ℕ} (h : IsNode m n) (h' : IsNode m' n') :
    (childA m n = childA m' n' → (m, n) = (m', n')) ∧
    (childB m n = childB m' n' → (m, n) = (m', n')) ∧
    (childC m n = childC m' n' → (m, n) = (m', n')) := by
  refine ⟨fun he => ?_, fun he => ?_, fun he => ?_⟩
  · rw [← parentP_childA h, he, parentP_childA h']
  · rw [← parentP_childB h, he, parentP_childB h']
  · rw [← parentP_childC h, he, parentP_childC h']

/-- Children produced by different branches are never equal, even across different
parents: the ascent letter separates the three ranges. -/
theorem childMaps_ranges_disjoint {m n m' n' : ℕ} (h : IsNode m n) (h' : IsNode m' n') :
    childA m n ≠ childB m' n' ∧ childA m n ≠ childC m' n' ∧ childB m n ≠ childC m' n' := by
  refine ⟨fun he => ?_, fun he => ?_, fun he => ?_⟩
  · have hA : letterOf (childA m n).1 (childA m n).2 = Letter.A := letterOf_childA h
    have hB : letterOf (childB m' n').1 (childB m' n').2 = Letter.B := letterOf_childB h'
    rw [he, hB] at hA
    exact Letter.noConfusion hA
  · have hA : letterOf (childA m n).1 (childA m n).2 = Letter.A := letterOf_childA h
    have hC : letterOf (childC m' n').1 (childC m' n').2 = Letter.C := letterOf_childC h'
    rw [he, hC] at hA
    exact Letter.noConfusion hA
  · have hB : letterOf (childB m n).1 (childB m n).2 = Letter.B := letterOf_childB h
    have hC : letterOf (childC m' n').1 (childC m' n').2 = Letter.C := letterOf_childC h'
    rw [he, hC] at hB
    exact Letter.noConfusion hB

/-- **The odd leg is not a function of the hypotenuse.**  So probes reading the leg
pair genuinely leave the sealed magnitude class — but they are not computable from
`N` either. -/
theorem legOdd_not_function_of_hyp (L : ℕ → ℕ) :
    ¬ (∀ m n, IsNode m n → L (hyp m n) = legOdd m n) := by
  intro hL
  obtain ⟨h1, h2, hh, -, -⟩ := letterOf_blind_of_magnitude 1 le_rfl
  have e1 := hL _ _ h1
  have e2 := hL _ _ h2
  rw [hh] at e1
  rw [e2] at e1
  norm_num [legOdd] at e1

end TwoTreeClosure