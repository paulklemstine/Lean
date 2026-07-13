/-
# Labeled Partial Orders modulo Small Numbers

Let `P(n)` denote the number of partial orders that can be placed on a fixed set
of `n` labeled points (OEIS **A001035**):

```
P(0) = 1, P(1) = 1, P(2) = 3, P(3) = 19, P(4) = 219, P(5) = 4231, …
```

A striking empirical pattern is that, from `n = 2` onward, every value is
congruent to `3` modulo `4`.  The residue `3 (mod 4)` in particular forces
`P(n)` to be **odd** for all `n`.

This file isolates the *parity* half of that phenomenon and proves it in full
generality, together with the exact modulo-`4` values for the first few `n`.

## Main results

* `LabeledPosets.selfDual_unique` — the **discrete order** (equality) is the
  *unique* self-dual labeled partial order on any point set.  Order reversal
  (duality) is an involution on the set of partial orders, and antisymmetry
  collapses every self-dual order to the discrete one.
* `LabeledPosets.Q_eq_one` — consequently the number of self-dual labeled
  partial orders is exactly `1` for every `n`.
* `LabeledPosets.P_odd` — **`P(n)` is odd for every `n`.**  This is obtained by
  a fixed-point/involution parity count applied to duality: the number of
  partial orders has the same parity as the number of self-dual ones, which is
  `1`.
* `LabeledPosets.P_two_mod_four`, `P_three_mod_four`, `P_four_mod_four` — the
  exact residue `P(n) ≡ 3 (mod 4)` for `n = 2, 3, 4`.

The general statement `P(n) ≡ 3 (mod 4)` for all `n ≥ 2` refines `P_odd` and is
recorded as a conjecture in the accompanying notes.
-/
import Mathlib

namespace LabeledPosets

/-! ## Encoding partial orders as boolean matrices -/

/-- A partial order on `Fin n`, encoded as a boolean matrix `r` that is
reflexive, antisymmetric and transitive. -/
def IsPO {n : ℕ} (r : Fin n → Fin n → Bool) : Prop :=
  (∀ a, r a a = true) ∧
  (∀ a b, r a b = true → r b a = true → a = b) ∧
  (∀ a b c, r a b = true → r b c = true → r a c = true)

instance {n : ℕ} (r : Fin n → Fin n → Bool) : Decidable (IsPO r) := by
  unfold IsPO; infer_instance

/-- The finite set of all labeled partial orders on `Fin n`. -/
def POSet (n : ℕ) : Finset (Fin n → Fin n → Bool) :=
  Finset.univ.filter (fun r => IsPO r)

/-- `P n` : the number of labeled partial orders on `n` points (OEIS A001035). -/
def P (n : ℕ) : ℕ := (POSet n).card

@[simp] lemma mem_POSet {n : ℕ} (r : Fin n → Fin n → Bool) :
    r ∈ POSet n ↔ IsPO r := by
  simp [POSet]

/-! ## Duality (order reversal) -/

/-- Order reversal: the dual of `r` swaps the two arguments. -/
def dualPO {n : ℕ} (r : Fin n → Fin n → Bool) : Fin n → Fin n → Bool :=
  fun a b => r b a

/-- Duality preserves the partial-order axioms. -/
lemma isPO_dual {n : ℕ} {r : Fin n → Fin n → Bool} (h : IsPO r) : IsPO (dualPO r) := by
  obtain ⟨hrefl, hanti, htrans⟩ := h
  refine ⟨fun a => hrefl a, ?_, ?_⟩
  · intro a b hab hba; exact hanti a b hba hab
  · intro a b c hab hbc; exact htrans c b a hbc hab

/-- Order reversal is an involution. -/
lemma dualPO_involutive {n : ℕ} : Function.Involutive (dualPO (n := n)) := by
  intro r; rfl

/-! ## The discrete order and self-duality -/

/-- The discrete (equality) order: `a ≤ b` iff `a = b`. -/
def disc (n : ℕ) : Fin n → Fin n → Bool := fun a b => decide (a = b)

/-- The discrete order is a partial order. -/
lemma isPO_disc (n : ℕ) : IsPO (disc n) := by
  refine ⟨fun a => by simp [disc], ?_, ?_⟩
  · intro a b hab _; simpa [disc] using hab
  · intro a b c hab hbc
    simp only [disc, decide_eq_true_eq] at *; omega

/-- The discrete order is self-dual. -/
lemma dual_disc (n : ℕ) : dualPO (disc n) = disc n := by
  funext a b; simp [dualPO, disc, eq_comm]

/-- **The discrete order is the unique self-dual labeled partial order.**
A self-dual order is symmetric, and symmetry together with antisymmetry forces
every relation to reduce to equality. -/
lemma selfDual_unique {n : ℕ} (r : Fin n → Fin n → Bool)
    (h : IsPO r) (hd : dualPO r = r) : r = disc n := by
  obtain ⟨hrefl, hanti, _⟩ := h
  funext a b
  have hsym : r a b = r b a := (congrFun (congrFun hd a) b).symm
  simp only [disc]
  by_cases hab : a = b
  · subst hab; simp [hrefl a]
  · have hf : r a b = false := by
      cases hr : r a b with
      | false => rfl
      | true => exact absurd (hanti a b hr (by rw [← hsym]; exact hr)) hab
    simp [hf, hab]

/-- The set of self-dual labeled partial orders. -/
def selfDualSet (n : ℕ) : Finset (Fin n → Fin n → Bool) :=
  (POSet n).filter (fun r => dualPO r = r)

/-- `Q n` : the number of self-dual labeled partial orders on `n` points. -/
def Q (n : ℕ) : ℕ := (selfDualSet n).card

/-- The self-dual set is exactly the singleton `{disc n}`. -/
lemma selfDualSet_eq_singleton (n : ℕ) : selfDualSet n = {disc n} := by
  apply Finset.eq_singleton_iff_unique_mem.mpr
  constructor
  · simp [selfDualSet, mem_POSet, isPO_disc n, dual_disc n]
  · intro r hr
    simp only [selfDualSet, Finset.mem_filter, mem_POSet] at hr
    exact selfDual_unique r hr.1 hr.2

/-- **There is exactly one self-dual labeled partial order** for every `n`. -/
theorem Q_eq_one (n : ℕ) : Q n = 1 := by
  rw [Q, selfDualSet_eq_singleton]; simp

/-! ## Parity via the duality involution -/

/-
**Involution parity count.** For a self-map `f` that maps a finite set `s`
into itself and is involutive there, the cardinality of `s` and the number of
its fixed points inside `s` have the same parity: the non-fixed points split
into disjoint two-element orbits `{a, f a}`.
-/
lemma card_modEq_card_fixed {α : Type*} [DecidableEq α] (s : Finset α) (f : α → α)
    (hmap : ∀ a ∈ s, f a ∈ s) (hinv : ∀ a ∈ s, f (f a) = a) :
    s.card ≡ (s.filter (fun a => f a = a)).card [MOD 2] := by
  -- Let's define the set of elements in $s$ that are not fixed points of $f$.
  set m := s.filter (fun a => f a ≠ a) with hm;
  -- Since $m$ is the set of elements in $s$ that are not fixed points of $f$, and $f$ is an involution on $s$, $m$ can be partitioned into pairs $\{a, f(a)\}$.
  have hm_partition : ∃ p : Finset (Finset α), (∀ x ∈ p, x.card = 2) ∧ (∀ x ∈ p, ∀ y ∈ p, x ≠ y → Disjoint x y) ∧ m = p.biUnion id := by
    refine' ⟨ Finset.image ( fun a => { a, f a } ) m, _, _, _ ⟩ <;> simp_all +decide [ Finset.disjoint_left ];
    · grind;
    · grind;
    · ext a; simp [Finset.mem_biUnion, Finset.mem_image];
      grind;
  -- Since $m$ can be partitioned into pairs, its cardinality is even.
  have hm_even : Even m.card := by
    obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ := hm_partition; rw [ hp₃, Finset.card_biUnion ] <;> aesop;
  simp_all +decide [ Nat.ModEq, Finset.filter_not, Finset.card_sdiff ];
  grind

/-- **`P(n)` is odd for every `n`.**  Order reversal is a fixed-point involution
on the set of labeled partial orders whose only fixed point is the discrete
order; hence `P(n)` has the same parity as `Q(n) = 1`. -/
theorem P_odd (n : ℕ) : Odd (P n) := by
  have hmap : ∀ r ∈ POSet n, dualPO r ∈ POSet n := by
    intro r hr; rw [mem_POSet] at *; exact isPO_dual hr
  have hinv : ∀ r ∈ POSet n, dualPO (dualPO r) = r := by
    intro r _; exact dualPO_involutive r
  have hmod : P n ≡ ((POSet n).filter (fun r => dualPO r = r)).card [MOD 2] :=
    card_modEq_card_fixed (POSet n) dualPO hmap hinv
  have hfix : ((POSet n).filter (fun r => dualPO r = r)).card = 1 := by
    have := Q_eq_one n; simpa [Q, selfDualSet] using this
  rw [hfix] at hmod
  rw [Nat.odd_iff]
  simpa [Nat.ModEq] using hmod

/-! ## A second parity constraint: relabeling symmetries -/

/-- Relabeling a partial order along a permutation `σ` of the points. -/
def relabel {n : ℕ} (σ : Equiv.Perm (Fin n)) (r : Fin n → Fin n → Bool) :
    Fin n → Fin n → Bool :=
  fun a b => r (σ a) (σ b)

/-- Relabeling preserves the partial-order axioms. -/
lemma isPO_relabel {n : ℕ} (σ : Equiv.Perm (Fin n)) {r : Fin n → Fin n → Bool}
    (h : IsPO r) : IsPO (relabel σ r) := by
  obtain ⟨hrefl, hanti, htrans⟩ := h
  refine ⟨fun a => hrefl _, ?_, ?_⟩
  · intro a b hab hba; exact σ.injective (hanti _ _ hab hba)
  · intro a b c hab hbc; exact htrans _ _ _ hab hbc

/-- Relabeling along an involutive permutation is itself an involution. -/
lemma relabel_involutive {n : ℕ} (σ : Equiv.Perm (Fin n))
    (hσ : Function.Involutive σ) : Function.Involutive (relabel σ) := by
  intro r; funext a b; simp only [relabel, hσ a, hσ b]

/-- **The number of labeled partial orders admitting a given involutive
relabeling symmetry `σ` as an automorphism is odd.**  Relabeling by `σ` is an
involution on the set of orders, so the fixed count has the same parity as the
total count `P(n)`, which is odd.  (Taking `σ` a transposition of two labels
gives the transposition-invariant orders.) -/
theorem symmetryFixed_odd {n : ℕ} (σ : Equiv.Perm (Fin n))
    (hσ : Function.Involutive σ) :
    Odd ((POSet n).filter (fun r => relabel σ r = r)).card := by
  have hmap : ∀ r ∈ POSet n, relabel σ r ∈ POSet n := by
    intro r hr; rw [mem_POSet] at *; exact isPO_relabel σ hr
  have hinv : ∀ r ∈ POSet n, relabel σ (relabel σ r) = r := by
    intro r _; exact relabel_involutive σ hσ r
  have hmod : P n ≡ ((POSet n).filter (fun r => relabel σ r = r)).card [MOD 2] :=
    card_modEq_card_fixed (POSet n) (relabel σ) hmap hinv
  obtain ⟨k, hk⟩ := P_odd n
  rw [Nat.odd_iff]
  have h2 : P n % 2 = ((POSet n).filter (fun r => relabel σ r = r)).card % 2 := hmod
  omega

/-! ## Exact residues modulo four for small `n` -/

/-- `P(2) = 3 ≡ 3 (mod 4)`. -/
theorem P_two_mod_four : P 2 % 4 = 3 := by native_decide

/-- `P(3) = 19 ≡ 3 (mod 4)`. -/
theorem P_three_mod_four : P 3 % 4 = 3 := by native_decide

/-- `P(4) = 219 ≡ 3 (mod 4)`. -/
theorem P_four_mod_four : P 4 % 4 = 3 := by native_decide

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  The labeled poset counts `P(n)` (A001035) satisfy
`P(n) ≡ 3 (mod 4)` for all `n ≥ 2`.  A necessary consequence is that `P(n)` is
odd for every `n`.

**Experiment.**  Direct enumeration confirms `P(2..4) = 3, 19, 219`, all
`≡ 3 (mod 4)`, and computes the self-dual counts `Q(2..5) = 1`.  The constancy
`Q = 1` suggested a structural cause rather than a numerical accident.

**Analysis.**  Duality (order reversal) is an involution on the set of partial
orders.  A self-dual order is symmetric; symmetry plus antisymmetry forces the
relation to be equality, so the discrete order is the *unique* fixed point.  A
fixed-point/involution parity count then yields that `P(n)` has the same parity
as the number of fixed points, which is exactly `1` — proving `P(n)` odd for all
`n`.  This is the parity shadow of the full `mod 4` congruence.

**Critique.**  `P_odd` is fully general (all `n`) and non-computational; the
`mod 4` statements are exact residues verified by enumeration for the small
cases where enumeration is feasible.  The general `mod 4` congruence is *not*
reducible to a single involution (a group of order 4 acting with a single global
fixed point would give `P ≡ 1 (mod 4)`, contradicting the data), so it requires
a finer orbit analysis; it is left as a conjecture.

**Synthesis.**  The duality involution explains the parity `P(n) ≡ 1 (mod 2)`
structurally and identifies the unique self-dual order as the obstruction.  The
step from `mod 2` to `mod 4` is the natural next target, via a
`ℤ/2 × ℤ/2` action combining duality with a label transposition.
-/

end LabeledPosets