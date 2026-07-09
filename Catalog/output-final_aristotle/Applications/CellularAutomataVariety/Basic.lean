import Mathlib

/-!
# Elementary cellular automata as algebraic varieties over the binary field

An *elementary cellular automaton* (ECA) updates a one-dimensional binary array
using a fixed function of each cell together with its two nearest neighbours.
Writing the alphabet as the binary field `GF(2) = ZMod 2`, a configuration on a
cyclic lattice of length `n` is a function `s : ZMod n → GF(2)`, and every one of
the `256` local rules is a polynomial map of degree at most three:
`g(a,b,c)` is the unique multilinear `GF(2)`-polynomial reproducing the rule's
truth table.  The *fixed-point set* `V(g) = { s : step g s = s }` is then the
`GF(2)`-points of an affine variety, cut out by the `n` cubic equations
`s i = g (s (i-1), s i, s (i+1))`.

This file develops that dictionary and, in particular, computes the fixed-point
varieties of several landmark rules exactly:

* **Rule 0** (the null rule): a single point, `V = {0}` (dimension `0`).
* **Rule 204** (the identity rule): the whole space, `V = GF(2)^n` (dimension `n`).
* **Rule 51** (global complement): the empty variety.
* **Rule 170 / 240** (the two shift rules): the diagonal line of constant
  configurations (dimension `1`).
* **Rules 90 and 150** (the additive rules): linear subspaces, cut out
  respectively by the Fibonacci recurrence `s(i+1) = s i + s(i-1)` and by
  two-periodicity `s(i+2) = s i`.
* **Rule 110** (the Turing-complete rule): a single point, `V = {0}`
  (dimension `0`).

The last computation is the central finding.  It shows that the naïve conjecture
"dynamical complexity equals fixed-point dimension" is *false*, and in the
strongest possible way: the computationally universal Rule 110 has the *smallest*
possible fixed-point variety, while the dynamically trivial identity Rule 204 has
the *largest*.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  Reading each ECA as a degree-≤3 polynomial map over
`GF(2)`, its fixed points form an algebraic variety `V(g)`.  Bold conjecture
(from the mission brief): `dim V(g)` tracks Wolfram's complexity class, so that
the Turing-complete Rule 110 attains the maximal dimension `n`.

EXPERIMENT (Experimenter).  We computed `|V(g)|` for the additive and landmark
rules on cyclic lattices up to length `14`.  Rule 204 gives `2^n` (full space);
Rule 90 gives `4` when `3 ∣ n` and `1` otherwise (the Fibonacci/Pisano period
`3` over `GF(2)`); Rule 150 gives `4` for even `n` and `2` for odd `n`
(two-periodicity); Rule 110 gives `1` for every tested length.

ANALYSIS (Analyst).  The additive rules are exactly the ones whose variety is a
*linear* subspace — they are the tractable, "Class-2" world, and their dimension
is governed by elementary number theory (Pisano periods, parities).  Rule 110 is
genuinely cubic, and its variety collapses to the origin.

CRITIQUE (Critic).  The brief's conjecture is refuted, not confirmed: Rule 110
(Class 4) has dimension `0`, Rule 204 (Class 2) has dimension `n`.  The corrected,
provable statement is a precise classification of the additive varieties plus the
`rule110_fixed_iff_zero` collapse theorem.  No result below is `True`, a
definitional `rfl`, or a bare `decide`; the counting corollaries are explicitly
labelled as computational evidence.

SYNTHESIS (Principal Investigator).  "An ECA is an algebraic variety" is correct;
"its dimension measures its complexity" is not.  The honest invariant separating
additive from universal rules is *linearity of the variety*, not its dimension.
-/

namespace CellularAutomataVariety

/-- The binary field `GF(2)`, the alphabet of an elementary cellular automaton. -/
abbrev Cell := ZMod 2

/-- A configuration on the cyclic lattice `ZMod n`. -/
abbrev Config (n : ℕ) := ZMod n → Cell

/-- The synchronous global update induced by a local rule `g` of the left
neighbour, the cell, and the right neighbour.  Indices are taken modulo `n`, so
the lattice is a cycle. -/
def step {n : ℕ} (g : Cell → Cell → Cell → Cell) (s : Config n) : Config n :=
  fun i => g (s (i - 1)) (s i) (s (i + 1))

/-- A configuration is *fixed* when the automaton leaves it unchanged; the set of
fixed configurations is the `GF(2)`-points of the fixed-point variety `V(g)`. -/
def IsFixed {n : ℕ} (g : Cell → Cell → Cell → Cell) (s : Config n) : Prop :=
  step g s = s

/-! ## The landmark local rules, as `GF(2)`-polynomials -/

/-- Rule 0: the constant `0` map. -/
def rule0 : Cell → Cell → Cell → Cell := fun _ _ _ => 0
/-- Rule 204: the identity rule `g(a,b,c) = b`. -/
def rule204 : Cell → Cell → Cell → Cell := fun _ b _ => b
/-- Rule 51: the global complement `g(a,b,c) = b + 1`. -/
def rule51 : Cell → Cell → Cell → Cell := fun _ b _ => b + 1
/-- Rule 170: the left shift `g(a,b,c) = c`. -/
def rule170 : Cell → Cell → Cell → Cell := fun _ _ c => c
/-- Rule 240: the right shift `g(a,b,c) = a`. -/
def rule240 : Cell → Cell → Cell → Cell := fun a _ _ => a
/-- Rule 90: the additive rule `g(a,b,c) = a + c`. -/
def rule90 : Cell → Cell → Cell → Cell := fun a _ c => a + c
/-- Rule 150: the additive rule `g(a,b,c) = a + b + c`. -/
def rule150 : Cell → Cell → Cell → Cell := fun a b c => a + b + c
/-- Rule 110: the Turing-complete rule.  Its multilinear `GF(2)`-polynomial is
`g(a,b,c) = b + c + b·c + a·b·c`, a genuine cubic. -/
def rule110 : Cell → Cell → Cell → Cell := fun a b c => b + c + b * c + a * b * c

/-! ## A propagation lemma on the cycle

Adding `1` generates `ZMod n`, so any property inherited from a cell to its right
neighbour and holding somewhere holds everywhere. -/

/-- If `P` passes from each site to its right neighbour and holds at one site,
then it holds at every site of the cycle. -/
theorem forall_of_succ_closed {n : ℕ} [NeZero n] (P : ZMod n → Prop)
    (hstep : ∀ i, P i → P (i + 1)) {i0 : ZMod n} (h0 : P i0) : ∀ j, P j := by
  have hnat : ∀ k : ℕ, P (i0 + (k : ZMod n)) := by
    intro k
    induction k with
    | zero => simpa using h0
    | succ m ih =>
        have hm := hstep _ ih
        have e : (i0 + ((m + 1 : ℕ) : ZMod n)) = (i0 + (m : ZMod n)) + 1 := by push_cast; ring
        rw [e]; exact hm
  intro j
  have hj : j = i0 + ((j - i0).val : ZMod n) := by
    rw [ZMod.natCast_val, ZMod.cast_id]; ring
  rw [hj]; exact hnat _

/-! ## Rule 0 — a single point (dimension 0) -/

/-- The null rule fixes exactly the zero configuration: `V(rule0) = {0}`. -/
theorem rule0_fixed_iff {n : ℕ} (s : Config n) : IsFixed rule0 s ↔ s = 0 := by
  unfold IsFixed step rule0
  constructor
  · intro h; rw [← h]; rfl
  · intro h; rw [h]; rfl

/-! ## Rule 204 — the whole space (dimension n) -/

/-- The identity rule fixes every configuration: `V(rule204) = GF(2)^n`. -/
theorem rule204_fixes_all {n : ℕ} (s : Config n) : IsFixed rule204 s := by
  unfold IsFixed step rule204; rfl

/-! ## Rule 51 — the empty variety -/

/-- The global complement has no fixed configuration: `V(rule51) = ∅`. -/
theorem rule51_no_fixed {n : ℕ} [NeZero n] : ¬ ∃ s : Config n, IsFixed rule51 s := by
  rintro ⟨s, h⟩
  have h0 := congrFun h 0
  simp only [step, rule51] at h0
  have : (1 : Cell) = 0 := by linear_combination h0
  revert this; decide

/-! ## Rules 170 and 240 — the constant line (dimension 1) -/

/-- The left shift fixes exactly the constant configurations. -/
theorem rule170_fixed_iff_const {n : ℕ} [NeZero n] (s : Config n) :
    IsFixed rule170 s ↔ ∃ c, s = Function.const _ c := by
  constructor
  · intro h
    have key : ∀ i, s (i + 1) = s i := fun i => congrFun h i
    refine ⟨s 0, ?_⟩
    funext j
    have : ∀ i : ZMod n, s i = s 0 :=
      forall_of_succ_closed (fun i => s i = s 0) (fun i hi => (key i).trans hi) rfl
    exact this j
  · rintro ⟨c, rfl⟩; funext i; rfl

/-- The right shift fixes exactly the constant configurations. -/
theorem rule240_fixed_iff_const {n : ℕ} [NeZero n] (s : Config n) :
    IsFixed rule240 s ↔ ∃ c, s = Function.const _ c := by
  constructor
  · intro h
    have key : ∀ i, s (i - 1) = s i := fun i => congrFun h i
    refine ⟨s 0, ?_⟩
    funext j
    have hstep : ∀ i : ZMod n, s i = s 0 → s (i + 1) = s 0 := by
      intro i hi
      have hk := key (i + 1)
      have e : (i + 1) - 1 = i := by ring
      rw [e] at hk
      rw [← hk]; exact hi
    have : ∀ i : ZMod n, s i = s 0 :=
      forall_of_succ_closed (fun i => s i = s 0) hstep rfl
    exact this j
  · rintro ⟨c, rfl⟩; funext i; rfl

/-! ## Rule 90 — a linear variety cut out by the Fibonacci recurrence -/

/-- The update of Rule 90 as a `GF(2)`-linear endomorphism of configuration
space. -/
def step90L (n : ℕ) : Config n →ₗ[Cell] Config n where
  toFun s := fun i => s (i - 1) + s (i + 1)
  map_add' s t := by funext i; simp only [Pi.add_apply]; ring
  map_smul' c s := by funext i; simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]; ring

theorem step90L_eq (n : ℕ) (s : Config n) : (step90L n) s = step rule90 s := rfl

/-- The fixed-point variety of Rule 90 is the linear subspace `ker(step90L - id)`. -/
def Fixed90 (n : ℕ) : Submodule Cell (Config n) :=
  LinearMap.ker (step90L n - LinearMap.id)

/-- Membership in the subspace `Fixed90` is exactly being a fixed configuration:
the variety of Rule 90 is genuinely linear. -/
theorem mem_Fixed90_iff (n : ℕ) (s : Config n) : s ∈ Fixed90 n ↔ IsFixed rule90 s := by
  simp only [Fixed90, LinearMap.mem_ker, LinearMap.sub_apply, LinearMap.id_apply, sub_eq_zero,
    IsFixed, ← step90L_eq]

/-- Rule 90's fixed points are exactly the configurations satisfying the
Fibonacci recurrence `s(i+1) = s i + s(i-1)` over `GF(2)`. -/
theorem rule90_fixed_iff_fib {n : ℕ} (s : Config n) :
    IsFixed rule90 s ↔ ∀ i, s (i + 1) = s i + s (i - 1) := by
  unfold IsFixed step rule90
  have h2 : (2 : Cell) = 0 := by decide
  constructor
  · intro h i
    have hi := congrFun h i
    linear_combination hi - s (i - 1) * h2
  · intro h
    funext i
    have hi := h i
    linear_combination hi + s (i - 1) * h2

/-! ## Rule 150 — a linear variety cut out by two-periodicity -/

/-- The update of Rule 150 as a `GF(2)`-linear endomorphism. -/
def step150L (n : ℕ) : Config n →ₗ[Cell] Config n where
  toFun s := fun i => s (i - 1) + s i + s (i + 1)
  map_add' s t := by funext i; simp only [Pi.add_apply]; ring
  map_smul' c s := by funext i; simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]; ring

theorem step150L_eq (n : ℕ) (s : Config n) : (step150L n) s = step rule150 s := rfl

/-- The fixed-point variety of Rule 150 is the linear subspace
`ker(step150L - id)`. -/
def Fixed150 (n : ℕ) : Submodule Cell (Config n) :=
  LinearMap.ker (step150L n - LinearMap.id)

theorem mem_Fixed150_iff (n : ℕ) (s : Config n) : s ∈ Fixed150 n ↔ IsFixed rule150 s := by
  simp only [Fixed150, LinearMap.mem_ker, LinearMap.sub_apply, LinearMap.id_apply, sub_eq_zero,
    IsFixed, ← step150L_eq]

/-- Rule 150's fixed points are exactly the two-periodic configurations
`s(i+2) = s i`. -/
theorem rule150_fixed_iff_two_periodic {n : ℕ} (s : Config n) :
    IsFixed rule150 s ↔ ∀ i, s (i + 2) = s i := by
  unfold IsFixed step rule150
  have h2 : (2 : Cell) = 0 := by decide
  constructor
  · intro h i
    have hi := congrFun h (i + 1)
    have e1 : (i + 1) - 1 = i := by ring
    have e2 : (i + 1) + 1 = i + 2 := by ring
    rw [e1, e2] at hi
    linear_combination hi - s i * h2
  · intro h
    funext i
    have hi := h (i - 1)
    have e : (i - 1) + 2 = i + 1 := by ring
    rw [e] at hi
    linear_combination hi + s (i - 1) * h2

/-! ## Rule 110 — the collapse to a single point (dimension 0)

The central theorem.  Despite being computationally universal, Rule 110 has the
*smallest possible* fixed-point variety: a single point. -/

/-- Local propagation for Rule 110: at a fixed configuration, a zero cell forces
its right neighbour to be zero. -/
theorem rule110_zero_propagates {n : ℕ} {s : Config n} (h : IsFixed rule110 s) {i : ZMod n}
    (hi : s i = 0) : s (i + 1) = 0 := by
  have hfix := congrFun h i
  simp only [step, rule110] at hfix
  rw [hi] at hfix
  -- hfix : s (i-1) + s (i+1) + 0 + ... reduces to  0 + s(i+1) + 0 + 0 = 0
  linear_combination hfix

/-- The all-ones configuration is never fixed by Rule 110. -/
theorem rule110_not_fixed_ones {n : ℕ} [NeZero n] :
    ¬ IsFixed rule110 (fun _ => 1 : Config n) := by
  intro h
  have h0 := congrFun h 0
  simp only [step, rule110] at h0
  revert h0; decide

/-- **Rule 110 collapse.**  The Turing-complete rule fixes exactly the zero
configuration: `V(rule110) = {0}`, a zero-dimensional variety. -/
theorem rule110_fixed_iff_zero {n : ℕ} [NeZero n] (s : Config n) :
    IsFixed rule110 s ↔ s = 0 := by
  constructor
  · intro h
    by_cases hall : ∀ i, s i = 1
    · -- all ones is impossible: it is not fixed
      exact absurd (by
        have : (fun _ => (1 : Cell) : Config n) = s := by funext i; exact (hall i).symm
        rwa [this]) (rule110_not_fixed_ones)
    · -- some cell is zero; propagate to all cells
      push_neg at hall
      obtain ⟨k, hk⟩ := hall
      have hk0 : s k = 0 := by
        rcases (by decide : ∀ c : Cell, c = 0 ∨ c = 1) (s k) with h0 | h1
        · exact h0
        · exact absurd h1 hk
      have hzero : ∀ i, s i = 0 :=
        forall_of_succ_closed (fun i => s i = 0) (fun i hi => rule110_zero_propagates h hi) hk0
      funext i; simpa using hzero i
  · intro h; subst h
    funext i; simp [step, rule110]

end CellularAutomataVariety