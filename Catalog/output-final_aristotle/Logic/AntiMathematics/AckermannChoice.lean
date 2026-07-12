import Mathlib

/-!
# Anti-Mathematics V: Negating Infinity makes Choice a theorem

**Mission.** *Anti-Mathematics: What if all axioms were negated?* — and,
crucially, *which anti-axioms are consistent, and how do they interact?*

A striking interaction: while the Axiom of **Choice** is independent of `ZF`, it
is **not** independent of `ZF − Infinity + ¬Infinity`.  In the hereditarily finite
universe every set is finite, so Choice is provable outright.  We make this precise
in the Ackermann model (`a ∈ₐ b :⟺ Nat.testBit b a`).

## Results

* `wellOrdered_universe` — the whole universe carries a definable well-order
  (`<` on `ℕ`), i.e. global choice holds.
* `exists_least_member` — every nonempty set has an `≤`-least member (choice from a
  single set).
* `choice_HF` — the full set-theoretic **Axiom of Choice**: any set `a` of
  nonempty, pairwise-disjoint sets has a *choice set* `c` meeting each member of `a`
  in exactly one point.  The choice set is exhibited as a genuine `HF` object,
  built by selecting the least element of each member.
-/

namespace AntiMath.Choice

/-- **Ackermann membership**: `a ∈ₐ b` iff the `a`-th binary digit of `b` is `1`. -/
def Mem (a b : ℕ) : Prop := b.testBit a

@[inherit_doc] scoped infix:50 " ∈ₐ " => Mem

instance (a : ℕ) : DecidablePred (fun x => Mem x a) := fun x => by
  unfold Mem; infer_instance

/-- Membership strictly decreases the Ackermann code: `a ∈ₐ b → a < b`. -/
theorem mem_lt {a b : ℕ} (h : a ∈ₐ b) : a < b :=
  lt_of_lt_of_le (Nat.lt_two_pow_self) (Nat.ge_two_pow_of_testBit h)

/-- A nonempty set has at least one member. -/
theorem exists_mem {b : ℕ} (hb : b ≠ 0) : ∃ i, i ∈ₐ b := by
  by_contra h; push_neg at h
  exact hb (Nat.eq_of_testBit_eq (fun i => by simpa [Mem] using h i))

/-- **Global choice / the well-ordering of the universe.**  The entire Ackermann
universe carries a definable strict well-order, namely `<` on the codes.  Hence a
global choice function exists (least element of any nonempty class). -/
theorem wellOrdered_universe : IsWellOrder ℕ (· < ·) := inferInstance

/-- **Choice from a single set.**  Every nonempty set has an `≤`-least member. -/
theorem exists_least_member {a : ℕ} (ha : a ≠ 0) :
    ∃ m, m ∈ₐ a ∧ ∀ x, x ∈ₐ a → m ≤ x := by
  classical
  have hex : ∃ i, i ∈ₐ a := exists_mem ha
  exact ⟨Nat.find hex, Nat.find_spec hex, fun x hx => Nat.find_le hx⟩

open Classical in
/-- The least set-bit index of a nonempty set; junk value `0` for the empty set. -/
noncomputable def leastMem (b : ℕ) : ℕ :=
  if h : ∃ i, b.testBit i then Nat.find h else 0

/-- The chosen element of a nonempty set is indeed a member of it. -/
theorem leastMem_mem {b : ℕ} (hb : b ≠ 0) : leastMem b ∈ₐ b := by
  have h : ∃ i, b.testBit i := exists_mem hb
  rw [Mem, leastMem, dif_pos h]
  exact Nat.find_spec h

/-- Bit `z` of an `or`-fold of `if q y then 2 ^ (g y) else 0` over `L` is on exactly
when some `y ∈ L` satisfies `q` and has `g y = z`. -/
theorem fold_testBit_img (q : ℕ → Prop) [DecidablePred q] (g : ℕ → ℕ) (z : ℕ) :
    ∀ L : List ℕ,
    (List.foldr (fun y acc => acc ||| (if q y then 2 ^ (g y) else 0)) 0 L).testBit z
      = (L.any (fun y => decide (q y) && decide (g y = z))) := by
  intro L
  induction L with
  | nil => simp
  | cons a t ih =>
    simp only [List.foldr_cons, Nat.testBit_or, List.any_cons, ih]
    by_cases hqa : q a
    · by_cases hax : g a = z
      · subst hax; simp [hqa]
      · simp [hqa, hax]
    · simp [hqa]

/-- The image of a set under a (meta-)function is a set (Replacement, needed to
build the choice set as an `HF` object). -/
theorem replacement (F : ℕ → ℕ) (a : ℕ) :
    ∃ s, ∀ y, y ∈ₐ s ↔ ∃ x, x ∈ₐ a ∧ y = F x := by
  refine ⟨(List.range a).foldr
      (fun x acc => acc ||| if a.testBit x then 2 ^ (F x) else 0) 0, fun y => ?_⟩
  simp only [Mem]
  rw [fold_testBit_img (fun x => a.testBit x) F y]
  simp only [List.any_eq_true, List.mem_range, Bool.and_eq_true, decide_eq_true_eq]
  constructor
  · rintro ⟨x, _, hx, hFx⟩; exact ⟨x, hx, hFx.symm⟩
  · rintro ⟨x, hx, rfl⟩; exact ⟨x, mem_lt hx, hx, rfl⟩

/-- **The Axiom of Choice, as a theorem of the ¬Infinity model.**  Given a set `a`
whose members are all nonempty and pairwise disjoint, there is a *choice set* `c`
that meets each member `b ∈ₐ a` in exactly one point.  The witness `c` is a genuine
hereditarily finite set: it collects the least element of each member of `a`. -/
theorem choice_HF (a : ℕ) (hne : ∀ b, b ∈ₐ a → b ≠ 0)
    (hdisj : ∀ b b', b ∈ₐ a → b' ∈ₐ a → b ≠ b' → ∀ x, ¬ (x ∈ₐ b ∧ x ∈ₐ b')) :
    ∃ c, ∀ b, b ∈ₐ a → ∃! x, x ∈ₐ c ∧ x ∈ₐ b := by
  obtain ⟨c, hc⟩ := replacement leastMem a
  refine ⟨c, fun b hb => ?_⟩
  refine ⟨leastMem b, ⟨(hc _).mpr ⟨b, hb, rfl⟩, leastMem_mem (hne b hb)⟩, ?_⟩
  rintro y ⟨hyc, hyb⟩
  obtain ⟨b', hb', rfl⟩ := (hc y).mp hyc
  by_cases hbb : b' = b
  · rw [hbb]
  · exact absurd ⟨leastMem_mem (hne b' hb'), hyb⟩ (hdisj b' b hb' hb hbb (leastMem b'))

end AntiMath.Choice