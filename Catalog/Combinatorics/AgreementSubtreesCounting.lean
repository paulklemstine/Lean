import Mathlib
import Applications.Core
import Novelty.AgreementSubtreesMultiple

/-!
# Counting restrictions and the tower behind multiple-tree agreement subtrees

Snir and Yuster asked for the least number `h(k)` of leaves that force `k` unrooted binary
phylogenetic trees to share a common quartet.  The upper-bound arguments for the many-tree
Maximum Agreement Subtree problem are driven by two elementary but decisive facts:

* the induced split system of a tree on `a` retained leaves is one of at most `2^(2^a)`
  possibilities (a *double* exponential), because every such system is a set of subsets of
  the `a` leaves; and
* once the number of trees exceeds this count, two trees must induce *identical* systems on
  the retained leaves — a pigeonhole step that seeds the iterated-exponential recursion.

This chapter isolates these facts from the analytic bookkeeping, and develops the
arithmetic of the iterated exponential *tower* `iterExp n a = 2^(2^(⋯^a))` in which the
paper's four-times iterated exponential bound lives (`iterExp 4`).

The results build directly on the restriction algebra of `Catalog.Applications.Core`
(`restrict`, `AgreeOn`, `CommonAgreement`).

-- !-- Lab Notes -- !--
## Hypothesis (Hypothesizer)
Category: **cross-domain bridge** — finite information counting (double powerset) meets
phylogenetic agreement and the pigeonhole principle, feeding an iterated-exponential tower.

1. **Bold / named-problem:** the number of trees needed to *avoid* a repeated restriction on
   `a` leaves is governed exactly by the double exponential `2^(2^a)`; this is the atomic
   step of the fourfold-iterated bound.
2. **Bold:** the pigeonhole threshold is sharp in *form* — beyond `2^(2^a)` trees a repeated
   induced system, hence an agreeing pair, is unavoidable regardless of tree shape.
3. **Structural:** the iterated exponential tower `iterExp` is strictly increasing at every
   level and monotone in the base, so composing the atomic step four times is well defined
   and lands above every intermediate value.
4. **Bridge:** `restrict` is monotone in the split system, so agreement counting respects
   sub-systems.

## Experiment (Experimenter)
The double-powerset containment `restrict T A ⊆ 𝒫(A)` was verified symbolically, giving the
double-exponential cardinality bound `2^(2^|A|)` by `card_powerset` twice.  The pigeonhole
step was obtained from `Finset.exists_ne_map_eq_of_card_lt_of_maps_to` with the map
`i ↦ restrict (T i) A`.

## Analysis (Analyst)
Three layers separate cleanly: (i) a *containment* layer (restrictions live in the double
powerset), (ii) a *counting* layer (cardinalities), and (iii) a *tower* layer (arithmetic of
`iterExp`).  The pigeonhole result is the pivot connecting (ii) to phylogenetic agreement.

## Critique (Critic)
The counting bound counts *split systems*, not whole binary topologies; it is deliberately
not the paper's final quantitative estimate, only the atomic recursion step.  The pigeonhole
statement needs a strict inequality `2^(2^|A|) < k`; equality is genuinely insufficient,
which is why the tower grows.  All statements are shape-agnostic: no binary-degree or
compatibility hypothesis is smuggled in.

## Synthesis (Principal Investigator)
Containment, double-exponential counting, the pigeonhole pivot, and the arithmetic of the
iterated tower form a reusable quantitative interface: exactly the pieces a compatibility-
sensitive refinement must iterate four times to reach the Snir–Yuster upper bound.
-/

open Finset

namespace AgreementSubtrees

variable {α ι : Type*} [DecidableEq α]

/-! ### Containment layer -/

/-- Restriction is monotone in the split system. -/
theorem restrict_mono {T U : SplitSystem α} (h : T ⊆ U) (A : Finset α) :
    restrict T A ⊆ restrict U A := by
  unfold restrict
  exact Finset.image_subset_image h

/-- Every restricted system is a set of subsets of the retained leaves, i.e. an element of
the double powerset of `A`. -/
theorem restrict_mem_double_powerset (T : SplitSystem α) (A : Finset α) :
    restrict T A ∈ (A.powerset).powerset := by
  refine Finset.mem_powerset.mpr (fun s hs => Finset.mem_powerset.mpr ?_)
  exact mem_restrict_subset hs

/-! ### Counting layer: the double exponential -/

/-- Among any finite family of trees, at most `2^(2^|A|)` distinct induced systems on `A`
occur.  This double exponential is the atomic step iterated to reach the paper's fourfold
exponential bound. -/
theorem card_image_restrict_le {k : ℕ} (T : Fin k → SplitSystem α) (A : Finset α) :
    (Finset.univ.image (fun i => restrict (T i) A)).card ≤ 2 ^ (2 ^ A.card) := by
  have hsub : Finset.univ.image (fun i => restrict (T i) A) ⊆ (A.powerset).powerset := by
    intro x hx
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.mp hx
    exact restrict_mem_double_powerset (T i) A
  calc (Finset.univ.image (fun i => restrict (T i) A)).card
      ≤ ((A.powerset).powerset).card := Finset.card_le_card hsub
    _ = 2 ^ (2 ^ A.card) := by rw [Finset.card_powerset, Finset.card_powerset]

/-- **Pigeonhole pivot.**  If more than `2^(2^|A|)` trees are given, two distinct trees
induce identical systems on `A`, hence agree on `A`. -/
theorem exists_agreeing_pair {k : ℕ} (T : Fin k → SplitSystem α) (A : Finset α)
    (hk : 2 ^ (2 ^ A.card) < k) : ∃ i j : Fin k, i ≠ j ∧ AgreeOn (T i) (T j) A := by
  have hcard : ((A.powerset).powerset).card < (Finset.univ : Finset (Fin k)).card := by
    rw [Finset.card_powerset, Finset.card_powerset, Finset.card_univ, Fintype.card_fin]
    exact hk
  obtain ⟨i, _, j, _, hij, hfeq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard
      (f := fun i => restrict (T i) A)
      (fun i _ => restrict_mem_double_powerset (T i) A)
  exact ⟨i, j, hij, hfeq⟩

/-- Restated as common agreement of a two-element index family: beyond the double
exponential number of trees, some pair already shares an induced subtree on `A`. -/
theorem exists_commonAgreement_pair {k : ℕ} (T : Fin k → SplitSystem α) (A : Finset α)
    (hk : 2 ^ (2 ^ A.card) < k) :
    ∃ i j : Fin k, i ≠ j ∧ CommonAgreement ({i, j} : Finset (Fin k)) T A := by
  obtain ⟨i, j, hij, hagree⟩ := exists_agreeing_pair T A hk
  refine ⟨i, j, hij, restrict (T i) A, ?_⟩
  intro x hx
  rcases Finset.mem_insert.mp hx with rfl | hx
  · rfl
  · rw [Finset.mem_singleton.mp hx]
    exact hagree.symm

/-! ### Tower layer: the iterated exponential -/

/-- The iterated exponential tower: `iterExp 0 a = a` and `iterExp (n+1) a = 2^(iterExp n a)`.
The Snir–Yuster upper bound lives at height four, `iterExp 4`. -/
def iterExp : ℕ → ℕ → ℕ
  | 0, a => a
  | n + 1, a => 2 ^ (iterExp n a)

@[simp] theorem iterExp_zero (a : ℕ) : iterExp 0 a = a := rfl

@[simp] theorem iterExp_succ (n a : ℕ) : iterExp (n + 1) a = 2 ^ (iterExp n a) := rfl

/-- The double exponential of the counting layer is exactly the height-two tower. -/
theorem iterExp_two (a : ℕ) : iterExp 2 a = 2 ^ (2 ^ a) := by
  simp [iterExp]

/-- The tower is monotone in its base at every fixed height. -/
theorem iterExp_mono_base (n : ℕ) : Monotone (iterExp n) := by
  induction n with
  | zero => simpa using monotone_id
  | succ n ih =>
    intro a b hab
    simp only [iterExp_succ]
    exact Nat.pow_le_pow_right (by norm_num) (ih hab)

/-- The tower strictly increases with height: each level dominates the one below. -/
theorem iterExp_lt_succ (n a : ℕ) : iterExp n a < iterExp (n + 1) a := by
  rw [iterExp_succ]
  exact Nat.lt_two_pow_self

/-- Consequently the tower is strictly monotone in its height. -/
theorem iterExp_strictMono_height (a : ℕ) : StrictMono (fun n => iterExp n a) := by
  exact strictMono_nat_of_lt_succ (fun n => iterExp_lt_succ n a)

/-- The fourfold self-composition of `Core`'s `iterateFour` (renamed here in tower form)
agrees with iterating `f` four times. -/
theorem iterateFour_eq_iterate (f : ℕ → ℕ) (x : ℕ) : iterateFour f x = f^[4] x := by
  rfl

/-- If the step function is monotone, so is its fourfold iterate. -/
theorem iterateFour_mono {f : ℕ → ℕ} (hf : Monotone f) : Monotone (iterateFour f) := by
  intro a b hab
  exact hf (hf (hf (hf hab)))

/-- The four-times iterated exponential is exactly the height-four tower on any base. -/
theorem iterateFour_two_pow (a : ℕ) : iterateFour (fun x => 2 ^ x) a = iterExp 4 a := by
  rfl

/-! ### Bridge to the pigeonhole threshold via the tower -/

/-- Phrased through the tower: beyond `iterExp 2 |A|` trees, an agreeing pair on `A` is
forced.  This is the height-two instance of the recursion the paper iterates four times. -/
theorem exists_agreeing_pair_tower {k : ℕ} (T : Fin k → SplitSystem α) (A : Finset α)
    (hk : iterExp 2 A.card < k) : ∃ i j : Fin k, i ≠ j ∧ AgreeOn (T i) (T j) A := by
  rw [iterExp_two] at hk
  exact exists_agreeing_pair T A hk

end AgreementSubtrees

/-! ### Examples, generalizations, and boundaries -/

section Examples

open AgreementSubtrees

-- Concrete instantiation of the tower.
#check @iterExp
#eval iterExp 0 3   -- 3
#eval iterExp 1 3   -- 8
#eval iterExp 2 2   -- 16 = 2^(2^2)
#eval iterExp 3 1   -- 16 = 2^(2^(2^1))

example : iterExp 2 2 = 16 := by decide
example : iterExp 4 0 = iterExp 3 1 := by decide

-- The pigeonhole threshold on two retained leaves: `2^(2^2) = 16` trees can still be
-- pairwise distinct on those two leaves; the bound is a genuine double exponential.
#check @exists_agreeing_pair
#check @card_image_restrict_le

/-
**Generalization.**  The containment and counting layers use no property of the split
systems beyond being finite sets of subsets, so they extend verbatim to any finite
labelled combinatorial object whose restriction is a subset operation.  The pigeonhole
pivot then applies to any family indexed by a set larger than the double powerset.

**Boundary / limit case.**  The strict inequality in `exists_agreeing_pair` cannot be
relaxed to `≤`: with exactly `2^(2^|A|)` trees one can, in principle, realize every element
of the double powerset once, leaving no repeated restriction.  This boundary is precisely
what forces the exponential to be *iterated*: each level only reduces the problem to a
strictly smaller — but still doubly exponential — number of trees, so four levels are
needed to descend to a common quartet.
-/

end Examples