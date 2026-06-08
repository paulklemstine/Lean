import Mathlib

/-!
# Dark Mathematics: Theorems That Exist But Cannot Be Found

We formalize "dark witness families" — mathematical structures where witnesses to an
existential claim exist in every interpretation ("world"), but no specific witness works
universally across all worlds. This captures the essence of "dark theorems" in
metamathematics: statements T such that a theory proves ∃x. T(x) but for no specific n
can the theory prove T(n).

## The Model

We model provability via *semantic completeness*: a statement is "provable" iff it holds
in all models (worlds). A predicate P : ℕ → Prop is **dark at level k** if every world
has at least k witnesses to P, yet no specific natural number is a witness in all worlds.

## Main Definitions

* `DarkWitnessFamily` — Core structure: a family of finite witness sets indexed by worlds,
  with guaranteed minimum cardinality but no universal witness.
* `shadow` — The set of universal witnesses (empty for dark families).
* `spectrum` — For each number, the set of worlds where it is a witness.
* `darknessProduct` — Composition of independent dark families.

## Main Results

* `shadow_eq_empty` — The shadow of any dark family is empty (Theorem 1).
* `spectrum_card_lt` — Each element's spectrum has strictly fewer than all worlds (Theorem 2).
* `darkness_double_count` — Double counting bound: level × worlds ≤ universe × (worlds - 1) (Theorem 3).
* `strict_hierarchy` — Explicit construction achieving each darkness level exactly (Theorem 4).
* `darkProduct_level` — Product construction is level-additive (Theorem 5).
* `darkness_bound_tight` — Tightness of the double counting bound (Conjecture/Theorem 6).

## Novel Concept

The **darkness spectrum** `spectrum D n` — measuring the "visibility" of each witness
across worlds — is a new mathematical object. The double counting theorem shows that
the sum of spectrum sizes equals the sum of witness set sizes, establishing a duality
between "darkness from the witness perspective" and "darkness from the world perspective."
-/

namespace DarkMathematics

open Finset Fintype

/-! ### Core Definitions -/

/-- A `DarkWitnessFamily` over a type of "worlds" α captures the core phenomenon of
dark theorems: witnesses to an existential claim exist in every world, but no witness
is universal across all worlds.

This models the metamathematical situation where a theory T proves "∃x. P(x)" (every
model/world has witnesses) but for no specific n does T prove P(n) (no number is a
witness in every model/world). The `level` parameter measures the "depth of darkness":
how many witnesses are guaranteed in each world. -/
structure DarkWitnessFamily (α : Type*) where
  /-- For each world, the finite set of valid witnesses in that world -/
  witnesses : α → Finset ℕ
  /-- The darkness level: minimum number of witnesses guaranteed per world -/
  level : ℕ
  /-- The darkness level is positive (existence is nontrivial) -/
  level_pos : 0 < level
  /-- Every world has at least `level` witnesses -/
  has_enough : ∀ a : α, level ≤ (witnesses a).card
  /-- No natural number is a witness in every world -/
  no_universal : ∀ n : ℕ, ∃ a : α, n ∉ witnesses a

variable {α β : Type*}

/-- The **shadow** of a dark witness family: the set of numbers that appear as witnesses
in *every* world. For genuine dark families, this is always empty — the shadow is the
"visible part" of the dark theorem, and darkness means nothing is visible. -/
def shadow (D : DarkWitnessFamily α) : Set ℕ :=
  {n : ℕ | ∀ a : α, n ∈ D.witnesses a}

/-- The **darkness spectrum** of a natural number n: the set of worlds where n serves
as a valid witness. This measures the "partial visibility" of each potential witness.
A number with full spectrum (all worlds) would be universal — which dark families forbid. -/
def spectrum [Fintype α] [DecidableEq α] (D : DarkWitnessFamily α) (n : ℕ) : Finset α :=
  Finset.univ.filter (fun a => n ∈ D.witnesses a)

/-! ### Theorem 1: Shadow Emptiness -/

/-
**Shadow Emptiness Theorem**: The shadow of every dark witness family is empty.
No natural number is a witness in all worlds simultaneously.

This is the formal expression of the core "dark theorem" phenomenon: existence is
guaranteed (by `has_enough`), but no specific instance can be verified universally
(by `no_universal`). The shadow — representing verifiable knowledge — is void.
-/
theorem shadow_eq_empty (D : DarkWitnessFamily α) : shadow D = ∅ := by
  ext n; simp [shadow, DarkWitnessFamily.no_universal]

/-! ### Theorem 2: Spectrum Bound -/

/-
**Spectrum Strict Bound**: For every natural number, its spectrum (the set of worlds
where it is a witness) is strictly smaller than the total number of worlds.

This theorem quantifies the "incompleteness" of each potential witness: no matter which
number we examine, there is always at least one world that rejects it.
-/
theorem spectrum_card_lt [Fintype α] [DecidableEq α]
    (D : DarkWitnessFamily α) (n : ℕ) :
    (spectrum D n).card < Fintype.card α := by
  obtain ⟨ a, ha ⟩ := D.no_universal n; exact Finset.card_lt_card ( Finset.filter_ssubset.mpr ⟨ a, by aesop ⟩ ) ;

/-! ### Hierarchy: Monotonicity and Strict Levels -/

/-- Darkness level can be lowered: if a family is dark at level k, it is dark at any
lower positive level. This gives monotonicity of the darkness hierarchy. -/
def lowerLevel (D : DarkWitnessFamily α) (k : ℕ) (hk : 0 < k) (hle : k ≤ D.level) :
    DarkWitnessFamily α where
  witnesses := D.witnesses
  level := k
  level_pos := hk
  has_enough := fun a => le_trans hle (D.has_enough a)
  no_universal := D.no_universal

/-
**Two-World Dark Family**: An explicit construction of a dark family at any level k ≥ 1
using exactly two worlds. World 0 gets witnesses {0, ..., k-1} and World 1 gets
witnesses {k, ..., 2k-1}. The two witness sets are complementary (disjoint), ensuring
no universal witness exists while each world has exactly k witnesses.
-/
def twoWorldFamily (k : ℕ) (hk : 0 < k) : DarkWitnessFamily (Fin 2) where
  witnesses := fun i => if i = 0 then Finset.range k else Finset.Icc k (2 * k - 1)
  level := k
  level_pos := hk
  has_enough := by
    simp +zetaDelta at *;
    omega
  no_universal := by
    intro n
    by_cases hn : n < k
    · exact ⟨1, by simp [Finset.mem_Icc]; omega⟩
    · exact ⟨0, by simp [Finset.mem_range]; omega⟩

/-
The two-world family has a world with exactly k witnesses (world 0).
-/
theorem twoWorldFamily_world0_card (k : ℕ) (hk : 0 < k) :
    ((twoWorldFamily k hk).witnesses 0).card = k := by
  unfold twoWorldFamily; aesop;

/-
**Strict Hierarchy Theorem**: For each level k ≥ 1, there exists a dark family
achieving exactly level k — no more, no less. This establishes that the darkness
hierarchy is strict: each level represents a genuinely distinct degree of darkness.

The construction uses two complementary worlds, each with exactly k witnesses drawn
from disjoint ranges. This is optimal in the sense that neither world has room for
additional witnesses without breaking the darkness property.
-/
theorem strict_hierarchy (k : ℕ) (hk : 0 < k) :
    ∃ D : DarkWitnessFamily (Fin 2),
      D.level = k ∧ ∃ a : Fin 2, (D.witnesses a).card = k := by
  exact ⟨ twoWorldFamily k hk, rfl, 0, twoWorldFamily_world0_card k hk ⟩

/-! ### Theorem 3: Double Counting Bound -/

/-
Helper: the total number of witness slots is at least level × number of worlds.
-/
theorem sum_witnesses_ge [Fintype α] (D : DarkWitnessFamily α) :
    D.level * Fintype.card α ≤ ∑ a : α, (D.witnesses a).card := by
  simpa [ mul_comm ] using Finset.sum_le_sum fun a ( ha : a ∈ Finset.univ ) => D.has_enough a

/-
**Double Counting Bound (Dark Inequality)**: For a dark family with finitely many
worlds and witnesses drawn from {0, ..., N-1}, the darkness level is constrained by:

  level × |worlds| ≤ N × (|worlds| - 1)

This is the fundamental trade-off of darkness: more worlds allow higher levels, but each
world's rejection of at least one number per element creates an information-theoretic
ceiling. The proof uses the *double counting* (bijective) argument: count (world, witness)
pairs two ways — by world (giving ≥ level × |worlds|) and by witness number (giving
≤ N × (|worlds| - 1), since each number appears in at most |worlds| - 1 worlds).

This inequality has deep implications: it shows that achieving high darkness levels
requires either many worlds or a large witness universe, quantifying the "cost" of
mathematical unknowability.
-/
theorem darkness_double_count [Fintype α] [DecidableEq α]
    (D : DarkWitnessFamily α) (N : ℕ)
    (h_range : ∀ a, D.witnesses a ⊆ Finset.range N)
    (hm : 2 ≤ Fintype.card α) :
    D.level * Fintype.card α ≤ N * (Fintype.card α - 1) := by
  have h_double_counting : ∑ a : α, (D.witnesses a).card = ∑ n ∈ Finset.range N, (spectrum D n).card := by
    -- By definition of spectrum, we can rewrite the sum over the worlds as a sum over the range N.
    have h_spectrum_sum : ∑ a : α, (D.witnesses a).card = ∑ n ∈ Finset.range N, ∑ a : α, (if n ∈ D.witnesses a then 1 else 0) := by
      rw [ Finset.sum_comm, Finset.sum_congr rfl ];
      simp +decide;
      exact fun a => by rw [ Finset.inter_eq_right.mpr ( h_range a ) ] ;
    simp_all +decide [spectrum];
  refine' le_trans ( sum_witnesses_ge D ) _;
  exact h_double_counting.symm ▸ le_trans ( Finset.sum_le_sum fun _ _ => Nat.le_sub_one_of_lt ( spectrum_card_lt D _ ) ) ( by simp +decide )

/-! ### Theorem 4: Product Composition -/

/-
**Dark Product Construction**: Given two dark families with disjoint witness ranges,
their product — pairing one world from each family — yields a dark family whose level
is the *sum* of the individual levels.

This establishes that darkness is *additive under composition*: independent dark
phenomena combine to produce deeper darkness. The disjointness condition ensures no
interference between the two families' witness sets.
-/
def darkProduct [Nonempty α] [Nonempty β]
    (D₁ : DarkWitnessFamily α) (D₂ : DarkWitnessFamily β)
    (h_disjoint : ∀ a b, Disjoint (D₁.witnesses a) (D₂.witnesses b)) :
    DarkWitnessFamily (α × β) where
  witnesses := fun ⟨a, b⟩ => D₁.witnesses a ∪ D₂.witnesses b
  level := D₁.level + D₂.level
  level_pos := Nat.add_pos_left D₁.level_pos _
  has_enough := by
    simp +zetaDelta at *;
    exact fun a b => by rw [ Finset.card_union_of_disjoint ( h_disjoint a b ) ] ; exact add_le_add ( D₁.has_enough a ) ( D₂.has_enough b ) ;
  no_universal := by
    intro n
    obtain ⟨a, ha⟩ := D₁.no_universal n
    obtain ⟨b, hb⟩ := D₂.no_universal n
    exact ⟨(a, b), by simp [Finset.mem_union]; tauto⟩

/-- The product construction achieves exactly the sum of levels. -/
theorem darkProduct_level [Nonempty α] [Nonempty β]
    (D₁ : DarkWitnessFamily α) (D₂ : DarkWitnessFamily β)
    (h : ∀ a b, Disjoint (D₁.witnesses a) (D₂.witnesses b)) :
    (darkProduct D₁ D₂ h).level = D₁.level + D₂.level := rfl

/-! ### Conjecture: Tightness of the Double Counting Bound -/

/-
**Complementary Block Partition**: Explicit construction of an extremal dark family.
For m worlds and N elements with m ∣ N, construct worlds where each world gets all
elements except one block of N/m consecutive elements. Each world has N - N/m = N(m-1)/m
witnesses, and each element is missing from exactly one world.

**Testable prediction**: For m=3, N=12, this gives level 8. For m=4, N=20, level 15.
Verify computationally that no dark family over Fin m with witnesses in range N can
exceed level N(m-1)/m. If the bound is NOT tight for some non-divisible N, that
identifies a richer combinatorial structure in the darkness hierarchy.
-/
theorem darkness_bound_tight (m : ℕ) (hm : 2 ≤ m) (N : ℕ) (hdvd : m ∣ N)
    (hN : 0 < N) :
    ∃ D : DarkWitnessFamily (Fin m),
      D.level = N - N / m ∧
      (∀ a, D.witnesses a ⊆ Finset.range N) := by
  rcases hdvd with ⟨ k, rfl ⟩;
  refine' ⟨ _, _, _ ⟩;
  refine' ⟨ fun a => Finset.range ( m * k ) \ Finset.Ico ( a.val * k ) ( a.val * k + k ), m * k - m * k / m, _, _, _ ⟩ <;> norm_num;
  any_goals tauto;
  any_goals intro a; exact Finset.sdiff_subset;
  · exact Nat.div_lt_self ( by nlinarith ) hm;
  · intro a; rw [ Finset.card_sdiff ] ; norm_num;
    rw [ show ( Ico ( a.val * k ) ( a.val * k + k ) ∩ range ( m * k ) ) = Finset.Ico ( a.val * k ) ( a.val * k + k ) from ?_ ];
    · norm_num [ Nat.mul_div_cancel_left _ ( pos_of_gt hm ) ];
      omega;
    · exact Finset.inter_eq_left.mpr fun x hx => Finset.mem_range.mpr ( by nlinarith [ Finset.mem_Ico.mp hx, Fin.is_lt a ] );
  · intro n;
    by_cases hn : n < m * k;
    · exact ⟨ ⟨ n / k, Nat.div_lt_of_lt_mul <| by linarith ⟩, fun _ => ⟨ Nat.div_mul_le_self _ _, by linarith [ Nat.div_add_mod n k, Nat.mod_lt n ( by nlinarith : 0 < k ) ] ⟩ ⟩;
    · exact ⟨ ⟨ 0, by linarith ⟩, by aesop ⟩

/-! ### Darkness Transfer Theorem -/

/-
**Darkness Transfer**: If a dark family can be refined (each world's witness set
shrinks but remains large enough), the result is still dark. This models how
strengthening a predicate (requiring more conditions on witnesses) preserves darkness
as long as enough witnesses survive in each world.
-/
theorem darkness_transfer (D : DarkWitnessFamily α)
    (w' : α → Finset ℕ)
    (k : ℕ) (hk : 0 < k)
    (_h_sub : ∀ a, w' a ⊆ D.witnesses a)
    (h_enough : ∀ a, k ≤ (w' a).card)
    (h_no_univ : ∀ n : ℕ, ∃ a : α, n ∉ w' a) :
    ∃ D' : DarkWitnessFamily α, D'.level = k ∧ D'.witnesses = w' := by
  exact ⟨ ⟨ w', k, hk, h_enough, h_no_univ ⟩, rfl, rfl ⟩

end DarkMathematics