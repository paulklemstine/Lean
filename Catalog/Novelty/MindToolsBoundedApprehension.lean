import Mathlib
import Logic.MindTools

/-!
# Resource-bounded apprehension: unconditional mind tools

The previous development (`Catalog/Logic/MindTools.lean`) treats "directly
apprehended by a human brain" as an undefined set-valued parameter, so every
mind-tool statement there is *conditional*: it needs a certificate consisting of
a containment and a theorem certified not to be apprehended.

This file carries out natural extensions 2, 3, 6 and 7 of the programme:

* **Bounded apprehension (2).**  We replace the psychological predicate by a
  *resource bound*: a sentence is apprehended at level `b` when it has a proof
  of size at most `b` in a fixed proof system.  This is a mathematically
  testable notion.
* **Unconditional certificates (3).**  For proof systems with finitely many
  proofs of each size and infinitely many theorems, both premises of the
  conditional theorem are *discharged*: the containment holds by definition and
  the inaccessible witness exists by counting (`isMindTool_of_infinite`).  For
  proof systems whose proofs are binary strings we get an explicit numerical
  witness: some sentence below `2 ^ (b + 1)` has no proof of size `≤ b`
  (`exists_lt_two_pow_not_apprehended`), by a pigeonhole count of the
  `2 ^ (b + 1) - 1` binary strings of length at most `b`.
* **Concrete ranks (6).**  The bounded-apprehension family is ranked by its own
  resource bound, and this ranking satisfies `MindTools.OrdinalRanks`, hence the
  hierarchy is well-founded.
* **Well-founded but not linear (7).**  A two-element family of theories is
  exhibited which is ordinal-ranked (hence well-founded) yet contains
  incomparable tools, so well-foundedness of the hierarchy does not upgrade to
  comparability.
-/

namespace MindTools
namespace Bounded

universe u

/-- A **proof system**: a type of proofs, each with a conclusion and a size.
This is the intensional datum missing from the purely extensional
`MindTools.FormalSystem`. -/
structure ProofSystem (Sentence : Type u) where
  /-- The type of formal derivations. -/
  Proof : Type
  /-- The sentence derived by a proof. -/
  conclusion : Proof → Sentence
  /-- The resource cost (length, size, time, …) of a proof. -/
  size : Proof → ℕ

variable {Sentence : Type u}

/-- The extensional theory of a proof system: the sentences it derives at all. -/
def theory (P : ProofSystem Sentence) : FormalSystem Sentence :=
  ⟨Set.range P.conclusion⟩

/-- Apprehension bounded by resource `b`: the sentences carrying a proof of size
at most `b`.  This is the mathematically testable replacement for "directly
apprehended by a human brain". -/
def apprehends (P : ProofSystem Sentence) (b : ℕ) : CognitiveProfile Sentence :=
  ⟨{s | ∃ p : P.Proof, P.size p ≤ b ∧ P.conclusion p = s}⟩

@[simp] theorem mem_apprehends {P : ProofSystem Sentence} {b : ℕ} {s : Sentence} :
    s ∈ (apprehends P b).direct ↔ ∃ p : P.Proof, P.size p ≤ b ∧ P.conclusion p = s :=
  Iff.rfl

@[simp] theorem mem_theory {P : ProofSystem Sentence} {s : Sentence} :
    s ∈ (theory P).provable ↔ ∃ p : P.Proof, P.conclusion p = s :=
  Iff.rfl

/-! ### Premise (1) is automatic for bounded apprehension -/

/-- Bounded apprehension is always contained in the theory: the formalizability
premise of `MindTools.zfc_isMindTool_of_certificate` needs no assumption here. -/
theorem apprehends_subset_theory (P : ProofSystem Sentence) (b : ℕ) :
    (apprehends P b).direct ⊆ (theory P).provable := by
  rintro s ⟨p, -, rfl⟩
  exact ⟨p, rfl⟩

/-- Larger resource budgets apprehend more. -/
theorem apprehends_mono (P : ProofSystem Sentence) {b b' : ℕ} (h : b ≤ b') :
    (apprehends P b).direct ⊆ (apprehends P b').direct := by
  rintro s ⟨p, hp, rfl⟩
  exact ⟨p, hp.trans h, rfl⟩

/-- Unbounded resources recover the whole theory. -/
theorem iUnion_apprehends (P : ProofSystem Sentence) :
    (⋃ b : ℕ, (apprehends P b).direct) = (theory P).provable := by
  apply Set.Subset.antisymm
  · exact Set.iUnion_subset fun b => apprehends_subset_theory P b
  · rintro s ⟨p, rfl⟩
    exact Set.mem_iUnion.2 ⟨P.size p, ⟨p, le_rfl, rfl⟩⟩

/-! ### Premise (2) by counting -/

/-- If only finitely many proofs fit in the budget, only finitely many sentences
are apprehended. -/
theorem apprehends_finite (P : ProofSystem Sentence) {b : ℕ}
    (h : {p : P.Proof | P.size p ≤ b}.Finite) :
    (apprehends P b).direct.Finite := by
  have : (apprehends P b).direct ⊆ P.conclusion '' {p : P.Proof | P.size p ≤ b} := by
    rintro s ⟨p, hp, rfl⟩
    exact ⟨p, hp, rfl⟩
  exact Set.Finite.subset (h.image _) this

/-- **Unconditional mind tool.**  A proof system with finitely many proofs of
each size but infinitely many theorems is a mind tool for *every* resource
bound: no cognitive hypothesis is required, the inaccessible witness is produced
by counting. -/
theorem isMindTool_of_infinite (P : ProofSystem Sentence)
    (hfin : ∀ b : ℕ, {p : P.Proof | P.size p ≤ b}.Finite)
    (hinf : (theory P).provable.Infinite) (b : ℕ) :
    IsMindTool (theory P) (apprehends P b) := by
  obtain ⟨s, hs, hs'⟩ := (hinf.diff (apprehends_finite P (hfin b))).nonempty
  exact isMindTool_of_witness _ _ (apprehends_subset_theory P b) hs hs'

/-- Under the same hypotheses, no finite budget is final: every budget is
strictly improved by a larger one. -/
theorem exists_strictly_larger_bound (P : ProofSystem Sentence)
    (hfin : ∀ b : ℕ, {p : P.Proof | P.size p ≤ b}.Finite)
    (hinf : (theory P).provable.Infinite) (b : ℕ) :
    ∃ b', b ≤ b' ∧ (apprehends P b).direct ⊂ (apprehends P b').direct := by
  obtain ⟨s, hs, hs'⟩ := (hinf.diff (apprehends_finite P (hfin b))).nonempty
  obtain ⟨p, rfl⟩ := hs
  refine ⟨max b (P.size p), le_max_left _ _, ?_⟩
  refine ⟨apprehends_mono P (le_max_left _ _), fun hsub => hs' ?_⟩
  exact hsub ⟨p, le_max_right _ _, rfl⟩

/-! ### Concrete ranks for the bounded hierarchy (extension 6) -/

/-- The family of theories obtained by capping apprehension at each budget. -/
def boundedTool (P : ProofSystem Sentence) (b : ℕ) : FormalSystem Sentence :=
  ⟨(apprehends P b).direct⟩

/-- The resource budget itself is an ordinal rank for the bounded hierarchy:
strictly more apprehension forces a strictly larger budget. -/
theorem ordinalRanks_boundedTool (P : ProofSystem Sentence) :
    OrdinalRanks (boundedTool P) (fun b => (b : Ordinal.{0})) := by
  intro i j hij
  have : ¬ j ≤ i := by
    intro hji
    exact hij.2 (apprehends_mono P hji)
  exact_mod_cast Nat.cast_lt.mpr (lt_of_not_ge this)

/-- Hence the bounded hierarchy is well-founded, by the catalog's ordinal-rank
theorem. -/
theorem wellFounded_boundedTool (P : ProofSystem Sentence) :
    WellFounded (fun i j : ℕ => Stronger (boundedTool P j) (boundedTool P i)) :=
  hierarchy_wellFounded_of_ordinalRanks _ _ (ordinalRanks_boundedTool P)

/-- In contrast with the general situation (see `wellFounded_not_total` below),
the bounded hierarchy *is* comparable: any two budgets give nested theories. -/
theorem boundedTool_comparable (P : ProofSystem Sentence) (i j : ℕ) :
    (boundedTool P i).provable ⊆ (boundedTool P j).provable ∨
      (boundedTool P j).provable ⊆ (boundedTool P i).provable := by
  rcases le_total i j with h | h
  · exact Or.inl (apprehends_mono P h)
  · exact Or.inr (apprehends_mono P h)

/-! ### Binary proof systems and an explicit pigeonhole witness -/

/-- Proof systems whose derivations are binary strings, the size being the
length of the string.  Every finite proof calculus with a finite alphabet can be
coded this way. -/
def binary (c : List Bool → Sentence) : ProofSystem Sentence :=
  ⟨List Bool, c, List.length⟩

/-- The binary strings of length at most `n`. -/
def shortStrings : ℕ → Finset (List Bool)
  | 0 => {[]}
  | n + 1 =>
      insert [] (((shortStrings n).image (List.cons true)) ∪
        ((shortStrings n).image (List.cons false)))

theorem mem_shortStrings {n : ℕ} {l : List Bool} :
    l ∈ shortStrings n ↔ l.length ≤ n := by
  induction n generalizing l with
  | zero =>
      simp [shortStrings, List.length_eq_zero_iff]
  | succ n ih =>
      constructor
      · intro hl
        simp only [shortStrings, Finset.mem_insert, Finset.mem_union, Finset.mem_image] at hl
        rcases hl with rfl | (⟨t, ht, rfl⟩ | ⟨t, ht, rfl⟩) <;> simp
        · exact ih.1 ht
        · exact ih.1 ht
      · intro hl
        match l with
        | [] => simp [shortStrings]
        | (true :: t) =>
            have : t.length ≤ n := by simpa using hl
            simp only [shortStrings, Finset.mem_insert, Finset.mem_union, Finset.mem_image]
            exact Or.inr (Or.inl ⟨t, ih.2 this, rfl⟩)
        | (false :: t) =>
            have : t.length ≤ n := by simpa using hl
            simp only [shortStrings, Finset.mem_insert, Finset.mem_union, Finset.mem_image]
            exact Or.inr (Or.inr ⟨t, ih.2 this, rfl⟩)

/-- There are exactly `2 ^ (n + 1) - 1` binary strings of length at most `n`. -/
theorem card_shortStrings (n : ℕ) : (shortStrings n).card = 2 ^ (n + 1) - 1 := by
  induction n with
  | zero => simp [shortStrings]
  | succ n ih =>
      have hdisj : Disjoint ((shortStrings n).image (List.cons true))
          ((shortStrings n).image (List.cons false)) := by
        simp [Finset.disjoint_left]
      have hnot : ([] : List Bool) ∉ ((shortStrings n).image (List.cons true)) ∪
          ((shortStrings n).image (List.cons false)) := by simp
      have hA : ((shortStrings n).image (List.cons true)).card = (shortStrings n).card :=
        Finset.card_image_of_injective _ (fun a b h => by simpa using h)
      have hB : ((shortStrings n).image (List.cons false)).card = (shortStrings n).card :=
        Finset.card_image_of_injective _ (fun a b h => by simpa using h)
      rw [shortStrings, Finset.card_insert_of_notMem hnot,
        Finset.card_union_of_disjoint hdisj, hA, hB, ih]
      have h1 : 1 ≤ 2 ^ (n + 1) := Nat.one_le_two_pow
      have h2 : 2 ^ (n + 1 + 1) = 2 * 2 ^ (n + 1) := by ring
      omega

/-- Consequently fewer than `2 ^ (n + 1)` sentences can be reached by proofs of
size at most `n`. -/
theorem card_shortStrings_lt (n : ℕ) : (shortStrings n).card < 2 ^ (n + 1) := by
  have h1 : 1 ≤ 2 ^ (n + 1) := Nat.one_le_two_pow
  have h2 := card_shortStrings n
  omega

/-- **Pigeonhole certificate.**  For *any* proof system whose proofs are binary
strings and whose sentences are natural numbers, some number below
`2 ^ (b + 1)` has no proof of size at most `b`.  The inaccessible witness is
produced by counting alone. -/
theorem exists_lt_two_pow_not_apprehended (c : List Bool → ℕ) (b : ℕ) :
    ∃ n < 2 ^ (b + 1), n ∉ (apprehends (binary c) b).direct := by
  by_contra hcon
  push_neg at hcon
  have hsub : Finset.range (2 ^ (b + 1)) ⊆ (shortStrings b).image c := by
    intro n hn
    obtain ⟨p, hp, rfl⟩ := hcon n (Finset.mem_range.1 hn)
    exact Finset.mem_image.2 ⟨p, mem_shortStrings.2 hp, rfl⟩
  have h1 : 2 ^ (b + 1) ≤ ((shortStrings b).image c).card := by
    simpa using Finset.card_le_card hsub
  have h2 : ((shortStrings b).image c).card ≤ (shortStrings b).card := Finset.card_image_le
  have h3 := card_shortStrings_lt b
  omega

/-- **Unconditional mind tool for binary proof systems.**  If a binary proof
system derives every natural number, then for every resource bound `b` its
theory strictly exceeds what is apprehensible within that bound.  No premise
about human cognition is used. -/
theorem binary_isMindTool (c : List Bool → ℕ) (hc : Function.Surjective c) (b : ℕ) :
    IsMindTool (theory (binary c)) (apprehends (binary c) b) := by
  obtain ⟨n, -, hn⟩ := exists_lt_two_pow_not_apprehended c b
  obtain ⟨p, hp⟩ := hc n
  exact isMindTool_of_witness _ _ (apprehends_subset_theory _ b) ⟨p, hp⟩ hn

/-! ### A fully concrete instance: the length code -/

/-- The concrete binary proof system whose conclusion is the length of the
proof: a proof of `n` is any string of `n` bits. -/
def lengthSystem : ProofSystem ℕ := binary List.length

@[simp] theorem lengthSystem_apprehends (b : ℕ) :
    (apprehends lengthSystem b).direct = Set.Iic b := by
  ext n
  constructor
  · rintro ⟨p, hp, rfl⟩
    exact hp
  · intro hn
    exact ⟨List.replicate n true, by simpa [lengthSystem, binary] using hn,
      by simp [lengthSystem, binary]⟩

@[simp] theorem lengthSystem_theory : (theory lengthSystem).provable = Set.univ := by
  ext n
  exact ⟨fun _ => trivial, fun _ => ⟨List.replicate n true, by simp [lengthSystem, binary]⟩⟩

/-- For the length code the inaccessible witness is completely explicit: `b + 1`
is a theorem with no proof of size `≤ b`. -/
theorem lengthSystem_isMindTool (b : ℕ) :
    IsMindTool (theory lengthSystem) (apprehends lengthSystem b) := by
  refine isMindTool_of_witness _ _ (apprehends_subset_theory _ b)
    (sentence := b + 1) (by simp) ?_
  simp

/-- The length-code hierarchy is strictly increasing in the resource bound, so
it is an infinite strictly ascending chain of cognitive profiles. -/
theorem lengthSystem_strictMono {b b' : ℕ} (h : b < b') :
    (apprehends lengthSystem b).direct ⊂ (apprehends lengthSystem b').direct := by
  simp only [lengthSystem_apprehends]
  exact Set.Iic_ssubset_Iic.2 h

/-! ### Well-founded does not mean linearly ordered (extension 7) -/

/-- A theory proving exactly the sentence `0`. -/
def toolZero : FormalSystem ℕ := ⟨{0}⟩

/-- A theory proving exactly the sentence `1`. -/
def toolOne : FormalSystem ℕ := ⟨{1}⟩

/-- The two sample theories are incomparable and distinct. -/
theorem toolZero_toolOne_incomparable :
    ¬ Stronger toolZero toolOne ∧ ¬ Stronger toolOne toolZero ∧ toolZero ≠ toolOne := by
  refine ⟨fun h => ?_, fun h => ?_, fun h => ?_⟩
  · have : (1 : ℕ) ∈ ({0} : Set ℕ) := h.1 rfl
    simp at this
  · have : (0 : ℕ) ∈ ({1} : Set ℕ) := h.1 rfl
    simp at this
  · have : (0 : ℕ) ∈ ({1} : Set ℕ) := by
      rw [show ({1} : Set ℕ) = toolOne.provable from rfl, ← h]; rfl
    simp at this

/-- The sample two-element family. -/
def sampleTools : Bool → FormalSystem ℕ := fun i => if i then toolZero else toolOne

/-- The sample family is ordinal-ranked (vacuously: no strict comparison holds),
so by `hierarchy_wellFounded_of_ordinalRanks` its strength order is
well-founded — yet the two tools are incomparable.  Well-foundedness of a
hierarchy of mind tools therefore does *not* imply that all tools are
comparable. -/
theorem wellFounded_not_total :
    ∃ (tools : Bool → FormalSystem ℕ) (rank : Bool → Ordinal),
      OrdinalRanks tools rank ∧
      WellFounded (fun i j : Bool => Stronger (tools j) (tools i)) ∧
      ¬ (∀ i j, Stronger (tools i) (tools j) ∨ Stronger (tools j) (tools i) ∨
          tools i = tools j) := by
  obtain ⟨h01, h10, hne⟩ := toolZero_toolOne_incomparable
  have hrank : OrdinalRanks sampleTools (fun _ => 0) := by
    intro i j hij
    rcases i <;> rcases j <;> simp only [sampleTools, if_true] at hij
    · exact absurd hij (ssubset_irrefl _)
    · exact absurd hij h01
    · exact absurd hij h10
    · exact absurd hij (ssubset_irrefl _)
  refine ⟨sampleTools, fun _ => 0, hrank,
    hierarchy_wellFounded_of_ordinalRanks _ _ hrank, fun htot => ?_⟩
  rcases htot true false with h | h | h
  · exact h01 (by simpa [sampleTools] using h)
  · exact h10 (by simpa [sampleTools] using h)
  · exact hne (by simpa [sampleTools] using h)

end Bounded
end MindTools