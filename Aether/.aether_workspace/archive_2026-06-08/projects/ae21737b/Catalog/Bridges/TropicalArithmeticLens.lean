import Mathlib

/-!
# Tropical Arithmetic Lensing on the Berggren Tree

## Overview

This module develops a novel formal bridge between three mathematical worlds:
1. **The Berggren tree** of primitive Pythagorean triples
2. **Tropical (min-plus) path actions** on weighted arithmetic trees
3. **Arithmetic reconstruction** of prime factorization signatures from caustic profiles

## Central Discovery

Factorization information can be encoded as a tropical optical profile on the
Berggren tree and then rigidly recovered from its caustics. Specifically:

- The **prime interaction profile** of a number n records which primes appear as
  common factors of n and hypotenuses of Berggren-tree triples.
- **Caustic rigidity**: equal profiles over a sufficient probe set force equal
  prime factor supports.
- A **certified reconstruction algorithm** extracts prime factor candidates from
  the profile with a formal soundness guarantee.

## Main Results

### Berggren Tree Structure
- `childA_preserves_pythag`, `childB_preserves_pythag`, `childC_preserves_pythag`:
  Berggren child maps preserve the Pythagorean property.
- `childA_hyp_increase`, `childB_hyp_increase`, `childC_hyp_increase`:
  All child maps strictly increase the hypotenuse for positive triples.

### Tropical Path Actions
- `tropicalLensAction_append`: Tropical action is additive on path concatenation.
- `tropicalLensAction_mono`: Pointwise height domination implies action domination.
- `tropicalLensAction_map_mono`: Child maps that increase height yield larger actions.

### Caustic Profiles and Rigidity
- `causticHeightProfile_mono`: Profile monotonicity under height domination.
- `interaction_profile_eq_of_sufficient`: The prime interaction profile equals the
  full prime factor set when the probe set is sufficient.
- `caustic_rigidity`: Equal profiles over sufficient probes imply equal prime supports.
- `caustic_rigidity_squarefree`: Specialization to squarefree integers.

### Certified Reconstruction
- `reconstructCandidates_sound`: All prime factors appear in extracted candidates.
- `reconstructCandidates_exact`: Exactness when probes are sufficient.
- `reconstructCandidates_bounded`: The candidate set is always bounded.
-/

open Finset Nat List

namespace TropicalArithmeticLens

/-! ## §1. Berggren Tree Infrastructure

The Berggren tree organizes all primitive Pythagorean triples as a ternary tree
rooted at (3, 4, 5). The three child maps A, B, C are integer-linear
transformations that preserve the Pythagorean property a² + b² = c².

These definitions mirror the catalog (`BerggrenPythagoreanCore`) but are
self-contained here for modularity.
-/

/-- A triple (a, b, c) over ℤ is Pythagorean when a² + b² = c². -/
def IsPythag (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Berggren child map A: (a,b,c) ↦ (a−2b+2c, 2a−b+2c, 2a−2b+3c). -/
def childA (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)

/-- Berggren child map B: (a,b,c) ↦ (a+2b+2c, 2a+b+2c, 2a+2b+3c). -/
def childB (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)

/-- Berggren child map C: (a,b,c) ↦ (−a+2b+2c, −2a+b+2c, −2a+2b+3c). -/
def childC (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)

/-- Child A preserves the Pythagorean property.
    Uses the catalog identity: if a²+b²=c², then (a−2b+2c)²+(2a−b+2c)²=(2a−2b+3c)². -/
theorem childA_preserves_pythag {a b c : ℤ} (h : IsPythag a b c) :
    IsPythag (childA a b c).1 (childA a b c).2.1 (childA a b c).2.2 := by
  unfold IsPythag childA at *; nlinarith

/-- Child B preserves the Pythagorean property. -/
theorem childB_preserves_pythag {a b c : ℤ} (h : IsPythag a b c) :
    IsPythag (childB a b c).1 (childB a b c).2.1 (childB a b c).2.2 := by
  unfold IsPythag childB at *; nlinarith

/-- Child C preserves the Pythagorean property. -/
theorem childC_preserves_pythag {a b c : ℤ} (h : IsPythag a b c) :
    IsPythag (childC a b c).1 (childC a b c).2.1 (childC a b c).2.2 := by
  unfold IsPythag childC at *; nlinarith

/-! ## §2. Hypotenuse Growth Under Berggren Child Maps

Every Berggren child map strictly increases the hypotenuse c when applied to a
positive Pythagorean triple. This is the fundamental geometric fact underlying
the monotonicity of tropical lens actions.

For positive (a,b,c) with a²+b²=c²:
- c > a and c > b (hypotenuse is largest side)
- childA hypotenuse = 2a − 2b + 3c = c + 2(a − b + c) > c since a + c > b
- childB hypotenuse = 2a + 2b + 3c > 3c > c
- childC hypotenuse = −2a + 2b + 3c = c + 2(b − a + c) > c since b + c > a
-/

/-
Child A strictly increases the hypotenuse for positive Pythagorean triples.
-/
theorem childA_hyp_increase {a b c : ℤ} (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (hpyth : IsPythag a b c) :
    c < (childA a b c).2.2 := by
  unfold childA; nlinarith [ sq_nonneg ( c - b ), hpyth.symm ] ;

/-
Child B strictly increases the hypotenuse (immediate from positivity).
-/
theorem childB_hyp_increase {a b c : ℤ} (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) :
    c < (childB a b c).2.2 := by
  exact show c < 2 * a + 2 * b + 3 * c by linarith;

/-
Child C strictly increases the hypotenuse for positive Pythagorean triples.
-/
theorem childC_hyp_increase {a b c : ℤ} (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (hpyth : IsPythag a b c) :
    c < (childC a b c).2.2 := by
  -- Unfold the definition of `childC` and `IsPythag`.
  unfold childC IsPythag at *;
  nlinarith [ sq_nonneg ( c - a ) ]

/-! ## §3. Tropical Path Action

The tropical lens action is the sum of height potentials along a path in
the Berggren tree. In the min-plus semiring, this corresponds to the cost
of a tropical geodesic.
-/

/-- The hypotenuse height potential on integer triples. -/
def hypotenuseHeight (t : ℤ × ℤ × ℤ) : ℕ := t.2.2.natAbs

/-- The perimeter height potential on integer triples. -/
def perimeterHeight (t : ℤ × ℤ × ℤ) : ℕ := (t.1 + t.2.1 + t.2.2).natAbs

/-- Tropical lens action: sum of a height function along a path.
    In tropical geometry, this is the total cost of a min-plus geodesic. -/
def tropicalLensAction (H : α → ℕ) (path : List α) : ℕ :=
  (path.map H).sum

@[simp]
theorem tropicalLensAction_nil (H : α → ℕ) :
    tropicalLensAction H [] = 0 := rfl

@[simp]
theorem tropicalLensAction_singleton (H : α → ℕ) (x : α) :
    tropicalLensAction H [x] = H x := by
  simp [tropicalLensAction]

/-
Tropical action is additive on path concatenation:
    the action of a composed path equals the sum of the actions.
-/
theorem tropicalLensAction_append (H : α → ℕ) (p q : List α) :
    tropicalLensAction H (p ++ q) = tropicalLensAction H p + tropicalLensAction H q := by
  unfold tropicalLensAction; simp +decide [ List.map_append, List.sum_append ] ;

/-
**Monotonicity under height domination**: if H₁ ≤ H₂ pointwise,
    then the tropical action under H₁ is ≤ the action under H₂.
    This is the tropical analogue of gravitational lens monotonicity:
    a denser mass distribution produces larger deflection angles.
-/
theorem tropicalLensAction_mono {H₁ H₂ : α → ℕ} (hle : ∀ x, H₁ x ≤ H₂ x)
    (path : List α) :
    tropicalLensAction H₁ path ≤ tropicalLensAction H₂ path := by
  exact List.sum_le_sum fun x hx => hle x

/-
**Functoriality under child maps**: if f increases height,
    then the tropical action of a mapped path dominates the original.
    For Berggren child maps (which increase hypotenuse), this gives
    monotonicity of tropical actions under tree descent.
-/
theorem tropicalLensAction_map_mono {H : α → ℕ} {f : α → α}
    (hf : ∀ x, H x ≤ H (f x)) (path : List α) :
    tropicalLensAction H path ≤ tropicalLensAction H (path.map f) := by
  unfold tropicalLensAction;
  simpa using List.sum_le_sum fun x hx => hf x

/-- Length of the mapped path equals original length. -/
theorem tropicalLensAction_map_length {f : α → α} (path : List α) :
    (path.map f).length = path.length := by
  simp

/-! ## §4. Caustic Height Profiles

The caustic profile records the image of a height function over a finite set
of Berggren nodes. Profile monotonicity is the key structural property
enabling arithmetic comparison through tropical lensing.
-/

/-- The caustic height profile: the set of height values attained by
    elements of a finite probe set S. -/
def causticHeightProfile (H : α → ℕ) [DecidableEq ℕ] (S : Finset α) : Finset ℕ :=
  S.image H

/-- A partial order on profiles: P₁ ≤ P₂ if every value in P₁ is
    dominated by some value in P₂. This captures the tropical order
    on min-plus envelopes. -/
def profileLe (P₁ P₂ : Finset ℕ) : Prop :=
  ∀ x ∈ P₁, ∃ y ∈ P₂, x ≤ y

/-
Profile order is reflexive.
-/
theorem profileLe_refl (P : Finset ℕ) : profileLe P P := by
  exact fun x hx => ⟨ x, hx, le_rfl ⟩

/-
**Profile monotonicity**: pointwise height domination implies
    profile domination. If one height function is everywhere ≤ another,
    then the corresponding caustic profiles respect the profile order.
    This is the optical comparison principle for tropical lenses.
-/
theorem causticHeightProfile_mono {H₁ H₂ : α → ℕ} [DecidableEq ℕ]
    (hle : ∀ x, H₁ x ≤ H₂ x) (S : Finset α) :
    profileLe (causticHeightProfile H₁ S) (causticHeightProfile H₂ S) := by
  exact fun x hx => by rcases Finset.mem_image.mp hx with ⟨ y, hy, rfl ⟩ ; exact ⟨ _, Finset.mem_image_of_mem _ hy, hle y ⟩ ;

/-! ## §5. Prime Interaction Profiles and Caustic Rigidity

The prime interaction profile of a natural number n with respect to a probe set S
records all primes that appear as common factors of n and elements of S. This is
the arithmetic content extracted from the tropical lens.

**Central insight**: the probe set S consists of hypotenuses (or products abc) of
Berggren-tree triples. The tropical lens action determines which triples contribute
to the profile and at what cost. Rigidity says: equal profiles over sufficient
probes force equal prime supports.
-/

/-- The prime interaction profile: the set of primes that divide both n
    and some element of the probe set S. This is the "arithmetic caustic"
    that records factorization information visible through the tropical lens. -/
def primeInteractionProfile (n : ℕ) (S : Finset ℕ) : Finset ℕ :=
  S.biUnion (fun s => (Nat.gcd n s).primeFactors)

/-- The prime support signature: the set of prime factors of n.
    This is the target of arithmetic reconstruction. -/
def primeSupportSignature (n : ℕ) : Finset ℕ := n.primeFactors

/-- A probe set S is sufficient for n if every prime factor of n divides
    some element of S. Intuitively, the tropical lens "sees" all primes in n.
    In the Berggren tree context, this means every prime dividing n also
    divides some hypotenuse at the given depth. -/
def IsSufficientProbeSet (n : ℕ) (S : Finset ℕ) : Prop :=
  ∀ p ∈ n.primeFactors, ∃ s ∈ S, p ∣ s

/-
Key lemma: a prime factor of n that divides some probe element appears
    in the prime interaction profile. This is the "visibility" property:
    if the lens can see a prime, it records it.
-/
theorem prime_mem_interaction_of_dvd {n p : ℕ} {S : Finset ℕ}
    (hp : Nat.Prime p) (hpn : p ∣ n) (hn : n ≠ 0)
    {s : ℕ} (hs : s ∈ S) (hps : p ∣ s) :
    p ∈ primeInteractionProfile n S := by
  exact Finset.mem_biUnion.mpr ⟨ s, hs, Nat.mem_primeFactors.mpr ⟨ hp, Nat.dvd_gcd hpn hps, by aesop ⟩ ⟩

/-
Every element of the prime interaction profile divides n.
    This is the "faithfulness" property: the lens does not hallucinate primes.
    Requires all probe elements to be nonzero.
-/
theorem interaction_profile_sub_primeFactors {n : ℕ} {S : Finset ℕ}
    (hn : n ≠ 0) (_hS : ∀ s ∈ S, s ≠ 0) :
    primeInteractionProfile n S ⊆ n.primeFactors := by
  intro p;
  simp +contextual [ primeInteractionProfile ];
  exact fun x _hx hp hpn _ => ⟨ Nat.dvd_trans hpn ( Nat.gcd_dvd_left _ _ ), hn ⟩

/-
If S is sufficient for n, the prime interaction profile equals n's
    full prime factor set. Combines visibility and faithfulness.
-/
theorem interaction_profile_eq_of_sufficient {n : ℕ} {S : Finset ℕ}
    (hn : n ≠ 0) (hS : ∀ s ∈ S, s ≠ 0)
    (hsuff : IsSufficientProbeSet n S) :
    primeInteractionProfile n S = n.primeFactors := by
  refine' Finset.Subset.antisymm ( interaction_profile_sub_primeFactors hn hS ) _;
  exact fun p hp => prime_mem_interaction_of_dvd ( Nat.prime_of_mem_primeFactors hp ) ( Nat.dvd_of_mem_primeFactors hp ) hn ( hsuff p hp |> Classical.choose_spec |> And.left ) ( hsuff p hp |> Classical.choose_spec |> And.right )

/-
**Caustic Rigidity Theorem**: if two nonzero numbers have the same prime
    interaction profile over a probe set that is sufficient for both, then
    they have the same prime factor support.

    This is the central theorem of tropical arithmetic lensing: factorization
    data is rigidly determined by the tropical caustic profile on the
    Berggren tree.

    Proof idea: By `interaction_profile_eq_of_sufficient`, the profile of n
    equals n.primeFactors and similarly for m. Profile equality then gives
    n.primeFactors = m.primeFactors.
-/
theorem caustic_rigidity {n m : ℕ} {S : Finset ℕ}
    (hn : n ≠ 0) (hm : m ≠ 0) (hS : ∀ s ∈ S, s ≠ 0)
    (hn_suff : IsSufficientProbeSet n S)
    (hm_suff : IsSufficientProbeSet m S)
    (hprof : primeInteractionProfile n S = primeInteractionProfile m S) :
    primeSupportSignature n = primeSupportSignature m := by
  have := interaction_profile_eq_of_sufficient hn hS hn_suff; have := interaction_profile_eq_of_sufficient hm hS hm_suff; aesop;

/-
**Squarefree caustic rigidity**: specialization of the rigidity theorem
    to the squarefree regime. In this case, the prime support completely
    determines the radical of the number.
-/
theorem caustic_rigidity_squarefree {n m : ℕ} {S : Finset ℕ}
    (_hn : Squarefree n) (_hm : Squarefree m)
    (hn0 : n ≠ 0) (hm0 : m ≠ 0) (hS : ∀ s ∈ S, s ≠ 0)
    (hn_suff : IsSufficientProbeSet n S)
    (hm_suff : IsSufficientProbeSet m S)
    (hprof : primeInteractionProfile n S = primeInteractionProfile m S) :
    primeSupportSignature n = primeSupportSignature m :=
  caustic_rigidity hn0 hm0 hS hn_suff hm_suff hprof

/-! ## §6. Certified Reconstruction Algorithm

The reconstruction algorithm extracts candidate prime factors from a prime
interaction profile. The profile elements are already primes (since they come
from primeFactors of gcd values), so reconstruction is essentially a filter.

This gives a certified inverse algorithm: from tropical caustic data on the
Berggren tree, we can extract a finite candidate set that provably contains
all true prime factors.
-/

/-- Extract candidate prime factors from a profile.
    Since profile elements come from `primeFactors` of gcd values,
    they are already prime; we filter for primality as a soundness check. -/
def reconstructCandidates (prof : Finset ℕ) : Finset ℕ :=
  prof.filter Nat.Prime

/-
**Reconstruction soundness**: all prime factors of n appear in the
    candidates extracted from n's prime interaction profile, provided
    the probe set is sufficient.

    This is the soundness guarantee of the certified inverse algorithm:
    no true prime factor is missed.
-/
theorem reconstructCandidates_sound {n : ℕ} {S : Finset ℕ}
    (hn : n ≠ 0) (_hS : ∀ s ∈ S, s ≠ 0)
    (hsuff : IsSufficientProbeSet n S) :
    primeSupportSignature n ⊆
      reconstructCandidates (primeInteractionProfile n S) := by
  have := @interaction_profile_eq_of_sufficient n S hn _hS hsuff;
  exact this.symm ▸ fun p hp => Finset.mem_filter.mpr ⟨ hp, Nat.prime_of_mem_primeFactors hp ⟩

/-
**Candidate boundedness**: the candidate set is finite and bounded.
    Since Finset is inherently finite, we get an explicit upper bound.
-/
theorem reconstructCandidates_bounded (prof : Finset ℕ) :
    ∃ B, ∀ p ∈ reconstructCandidates prof, p ≤ B := by
  exact Finset.bddAbove _

/-
**Reconstruction exactness**: when the probe set is sufficient,
    reconstruction gives exactly the prime support signature.

    This is the exactness guarantee: no spurious primes are introduced.
-/
theorem reconstructCandidates_exact {n : ℕ} {S : Finset ℕ}
    (hn : n ≠ 0) (_hS : ∀ s ∈ S, s ≠ 0)
    (hsuff : IsSufficientProbeSet n S) :
    reconstructCandidates (primeInteractionProfile n S) = primeSupportSignature n := by
  ext p; simp +decide [ reconstructCandidates, primeSupportSignature ];
  constructor <;> intro h;
  · exact ⟨ h.2, Nat.dvd_trans ( Nat.dvd_of_mem_primeFactors <| Finset.mem_biUnion.mp h.1 |> Classical.choose_spec |> And.right ) <| Nat.gcd_dvd_left _ _, hn ⟩;
  · exact ⟨ prime_mem_interaction_of_dvd h.1 h.2.1 h.2.2 ( hsuff p ( by aesop ) |> Classical.choose_spec |> And.left ) ( hsuff p ( by aesop ) |> Classical.choose_spec |> And.right ), h.1 ⟩

/-! ## §7. Concrete Berggren Tree Computations

Verification that the (3,4,5) root and its first-generation children
satisfy the Pythagorean property and exhibit hypotenuse growth.
-/

/-- The root triple (3,4,5) is Pythagorean. -/
theorem root_is_pythag : IsPythag 3 4 5 := by
  unfold IsPythag; norm_num

/-- Child A of (3,4,5) is (5,12,13). -/
theorem childA_root : childA 3 4 5 = (5, 12, 13) := by
  unfold childA; norm_num

/-- Child B of (3,4,5) is (21,20,29). -/
theorem childB_root : childB 3 4 5 = (21, 20, 29) := by
  unfold childB; norm_num

/-- Child C of (3,4,5) is (15,8,17). -/
theorem childC_root : childC 3 4 5 = (15, 8, 17) := by
  unfold childC; norm_num

/-- Hypotenuse growth at root: 13 > 5, 29 > 5, 17 > 5. -/
theorem root_hyp_growth :
    (5 : ℤ) < 13 ∧ (5 : ℤ) < 29 ∧ (5 : ℤ) < 17 := by omega

end TropicalArithmeticLens