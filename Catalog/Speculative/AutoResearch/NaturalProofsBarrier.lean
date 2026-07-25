import Mathlib

/-!
# The Razborov–Rudich Natural Proofs Barrier: a Quantitative Distinguisher

This file formalizes the *core mechanism* of the Razborov–Rudich natural proofs
barrier (1994). The catalog already contains a **skeleton** of the barrier in
`Catalog/Computation/BarrierFramework.lean`
(`BoolFnProperty`, `IsLargeProperty`, `IsUsefulAgainst`,
`natural_proof_distinguisher`) and the *relativization* / *algebrization*
barriers in `Catalog/Computation/CircuitBarriers.lean`
(`relativization_barrier`, `algebrization_barrier`,
`no_relativizing_equivalence`).

Those skeletons only assert the *existence* of a hard function inside a large,
useful property — they never extract the actual cryptographic distinguisher that
makes the barrier bite. This file closes that gap with a fully quantitative,
finite, and `sorry`-free development:

A property `P` that is **large** (accepts a `δ`-fraction of all truth tables)
and **useful** against a function family `g` (rejects every function the family
produces) is *exactly* a statistical test that separates the pseudorandom
ensemble `g` from the uniform ensemble with advantage `≥ δ`. If the family is a
secure pseudorandom function generator against the class of properties the proof
lives in, no such property can exist — this is the barrier.

## Main results

* `pseudoProb_eq_zero_of_useful` — usefulness collapses the pseudorandom
  acceptance probability to `0`.
* `natural_property_distinguishes` — **largeness + usefulness ⇒ advantage ≥ δ**.
  This is the quantitative heart of Razborov–Rudich.
* `natural_property_distinguishes_approx` — a *strengthening* allowing the
  property to leak on an `ε`-fraction of seeds: advantage `≥ δ − ε`.
* `useful_of_class_useful` — bridge: usefulness against a circuit *class*
  containing the family yields usefulness against the family.
* `natural_proofs_barrier` — a natural property in a class against which `g` is
  `δ`-secure **cannot** be useful: security is destroyed.
* `razborov_rudich` — the headline: a constructive, large property useful
  against a circuit class that contains a secure PRF breaks that PRF.
* `barrier_needs_largeness` — boundary case: drop largeness and the advantage
  can be `0`, so the barrier genuinely requires the largeness hypothesis.
-/

noncomputable section
open Classical Finset

namespace NaturalProofs

variable {F S : Type*} [Fintype F] [Fintype S]

/-! ## Section 1: Statistical-test semantics of a property

We identify the universe `F` with the set of all Boolean truth tables on `n`
inputs (so `Fintype.card F = 2 ^ 2 ^ n`), and `S` with the seed space of a
pseudorandom function family `g : S → F`. A property `P : F → Prop` is a
statistical test: it accepts a function when `P f` holds. -/

/-- Number of functions accepted by `P` (the "size" of the property). -/
def acceptCount (P : F → Prop) : ℕ := (univ.filter (fun f => P f)).card

/-- Acceptance probability of `P` under the **uniform** ensemble on `F`. -/
def randomProb (P : F → Prop) : ℚ := (acceptCount P : ℚ) / (Fintype.card F : ℚ)

/-- Number of seeds whose function `g s` is accepted by `P`. -/
def pseudoCount (P : F → Prop) (g : S → F) : ℕ :=
  (univ.filter (fun s => P (g s))).card

/-- Acceptance probability of `P` under the **pseudorandom** ensemble `g`. -/
def pseudoProb (P : F → Prop) (g : S → F) : ℚ :=
  (pseudoCount P g : ℚ) / (Fintype.card S : ℚ)

/-- Distinguishing advantage of the test `P` between the uniform ensemble and the
pseudorandom ensemble `g`. -/
def advantage (P : F → Prop) (g : S → F) : ℚ := |randomProb P - pseudoProb P g|

/-- `P` is **useful against** the family `g` if it rejects every function the
family can produce — the complexity-theoretic notion of usefulness (no
"easy" function satisfies `P`). -/
def UsefulAgainst (P : F → Prop) (g : S → F) : Prop := ∀ s, ¬ P (g s)

/-! ## Section 2: Basic probability facts -/

/-
The uniform acceptance probability is non-negative.
-/
theorem randomProb_nonneg (P : F → Prop) : 0 ≤ randomProb P := by
  exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ )

/-
The pseudorandom acceptance probability is non-negative.
-/
omit [Fintype F] in
theorem pseudoProb_nonneg (P : F → Prop) (g : S → F) : 0 ≤ pseudoProb P g := by
  exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ )

/-! ## Section 3: Usefulness kills the pseudorandom mass -/

/-
!-- Useful ⇒ no seed is accepted ⇒ the filtered set is empty ⇒ probability 0. -- !--

If `P` is useful against `g`, then `g` never lands in the accepting set, so
the pseudorandom acceptance probability is exactly `0`.
-/
omit [Fintype F] in
theorem pseudoProb_eq_zero_of_useful (P : F → Prop) (g : S → F)
    (h : UsefulAgainst P g) : pseudoProb P g = 0 := by
      unfold pseudoProb pseudoCount;
      rw [ Finset.card_eq_zero.mpr ] <;> aesop

/-! ## Section 4: The quantitative distinguisher (heart of Razborov–Rudich) -/

/-
!-- pseudoProb = 0 by usefulness, so advantage = |randomProb| = randomProb ≥ δ. -- !--

**Natural properties are distinguishers.** A property that accepts a
`δ`-fraction of all functions (largeness) yet rejects everything the family `g`
produces (usefulness) distinguishes the pseudorandom ensemble from uniform with
advantage at least `δ`. This is the quantitative core that the catalog skeleton
`natural_proof_distinguisher` only gestured at.
-/
theorem natural_property_distinguishes
    (P : F → Prop) (g : S → F) (δ : ℚ)
    (hlarge : δ ≤ randomProb P)
    (huseful : UsefulAgainst P g) :
    δ ≤ advantage P g := by
      refine' le_trans hlarge _;
      unfold advantage;
      rw [ pseudoProb_eq_zero_of_useful P g huseful, sub_zero, abs_of_nonneg ( randomProb_nonneg P ) ]

/-
!-- |randomProb − pseudoProb| ≥ randomProb − pseudoProb ≥ δ − ε. -- !--

**Strengthening (approximate usefulness).** Even if `P` is allowed to leak,
accepting the family's output on a set of seeds of probability at most `ε`, the
distinguishing advantage is still at least `δ − ε`. Setting `ε = 0` recovers
`natural_property_distinguishes`.
-/
theorem natural_property_distinguishes_approx
    (P : F → Prop) (g : S → F) (δ ε : ℚ)
    (hlarge : δ ≤ randomProb P)
    (hweak : pseudoProb P g ≤ ε) :
    δ - ε ≤ advantage P g := by
      unfold advantage;
      grind

/-! ## Section 5: From circuit-class usefulness to family usefulness -/

/-- `P` is useful against a **class** `C` of functions if no function with
property `P` lies in `C` (e.g. `C` = functions computable by small circuits). -/
def UsefulAgainstClass (P : F → Prop) (C : F → Prop) : Prop :=
  ∀ f, P f → ¬ C f

/-
!-- The family lands in C; P rejects everything in C; hence P rejects the family. -- !--

**Bridge.** If every seed of the family `g` produces a function inside the
circuit class `C`, and `P` is useful against `C`, then `P` is useful against the
family `g`. This is how "useful against P/poly" upgrades to "useful against a
PRF computable in P/poly".
-/
omit [Fintype F] [Fintype S] in
theorem useful_of_class_useful
    (P C : F → Prop) (g : S → F)
    (hCg : ∀ s, C (g s))
    (huse : UsefulAgainstClass P C) :
    UsefulAgainst P g := by
      exact fun s hs => huse _ hs ( hCg s )

/-! ## Section 6: The barrier -/

/-- The family `g` is **`δ`-secure** against a class `cls` of admissible tests
(the "constructive" properties that a natural proof is allowed to use) if no
test in `cls` distinguishes it from uniform with advantage `≥ δ`. -/
def SecureAgainst (g : S → F) (cls : Set (F → Prop)) (δ : ℚ) : Prop :=
  ∀ P ∈ cls, advantage P g < δ

/-- A property is **natural for** the admissible class `cls` at density `δ` if it
is constructive (lies in `cls`) and large (`δ`-dense). This packages the two
non-usefulness Razborov–Rudich axioms. -/
def Natural (P : F → Prop) (cls : Set (F → Prop)) (δ : ℚ) : Prop :=
  P ∈ cls ∧ δ ≤ randomProb P

/-
!-- Distinguisher (advantage ≥ δ) contradicts δ-security (advantage < δ). -- !--

**Natural proofs barrier.** If `g` is `δ`-secure against the admissible
class `cls`, then no property that is natural for `cls` at density `δ` can be useful
against `g`. Equivalently: a natural proof of a lower bound against `g` would
break the security of `g`.
-/
theorem natural_proofs_barrier
    (g : S → F) (cls : Set (F → Prop)) (δ : ℚ)
    (P : F → Prop) (hnat : Natural P cls δ)
    (hsec : SecureAgainst g cls δ) :
    ¬ UsefulAgainst P g := by
      exact fun h => not_lt_of_ge ( natural_property_distinguishes P g δ hnat.2 h ) ( hsec P hnat.1 )

/-
!-- Combine the class→family bridge with the barrier. -- !--

**Razborov–Rudich (headline form).** Suppose a secure pseudorandom family
`g` is computable in a circuit class `C` (every seed produces a function in
`C`), and `P` is a *constructive, large* property (natural for the admissible
class `cls` at density `δ`) that is useful against `C`. Then `g` cannot be
`δ`-secure against `cls`. Contrapositively: while strong PRFs exist, no natural
property is useful against the class that computes them — natural lower-bound
proofs are blocked.
-/
theorem razborov_rudich
    (g : S → F) (cls : Set (F → Prop)) (δ : ℚ)
    (P C : F → Prop)
    (hnat : Natural P cls δ)
    (hCg : ∀ s, C (g s))
    (huse : UsefulAgainstClass P C) :
    ¬ SecureAgainst g cls δ := by
      exact fun h => natural_proofs_barrier g cls δ P hnat h ( useful_of_class_useful P C g hCg huse )

/-! ## Section 7: Boundary case — largeness is indispensable -/

/-
!-- The empty property is vacuously useful but 0-dense, giving advantage 0. -- !--

**Boundary case.** Largeness cannot be dropped. The always-false property is
vacuously useful against *every* family, yet its distinguishing advantage is
`0`: a non-large property carries no barrier.
-/
theorem barrier_needs_largeness (g : S → F) :
    UsefulAgainst (fun _ : F => False) g ∧
      advantage (fun _ : F => False) g = 0 := by
        unfold advantage;
        unfold randomProb pseudoProb; simp +decide [ acceptCount, pseudoCount ] ;
        exact fun s => by simp +decide ;

end NaturalProofs

end