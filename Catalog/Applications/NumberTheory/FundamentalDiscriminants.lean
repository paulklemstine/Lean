import Mathlib
import Probability.PosetTheory.QuadraticLocalCorrespondence

/-!
# Fundamental discriminants: predicate, certified enumeration, and local ramification

This file develops the arithmetic layer that sits directly above the local quadratic
dictionary of `Probability.QuadraticLocalCorrespondence`.  There, for an integer parameter
`D` and a prime `p`, the local color `quadraticColor D p = (D / p)` was classified into
ramified / split / inert according to the Legendre symbol.  The colors are uniform in `D`,
so to organise them into genuine quadratic-field data one must pin down *which* integers `D`
are fundamental discriminants.

We do exactly that:

* `IsFundamentalDiscriminant D` is the classical predicate: either `D ≡ 1 (mod 4)` with `D`
  squarefree, or `D = 4m` with `m ≡ 2, 3 (mod 4)` and `m` squarefree.
* `isFundDisc` is a computable Boolean mirror, proved equivalent to the predicate
  (`isFundDisc_eq_true_iff`).  This yields a `DecidablePred` instance and a kernel-checkable
  route to counting.
* Structural facts: a fundamental discriminant is `≡ 0` or `1 (mod 4)`, is nonzero, and is
  squarefree *exactly* in the `D ≡ 1 (mod 4)` branch (`fundDisc_squarefree_iff_one_mod_four`),
  so every ramified odd prime divides it exactly once while the prime `2` ramifies wildly in
  the even branch.
* The local anchoring theorem `fundDisc_odd_ramification` combines the squarefreeness with the
  imported color-zero criterion `quadraticColor_eq_zero_iff_dvd`.
* A certified bounded enumeration: the finite set of all fundamental discriminants with
  `|D| ≤ 1000`, its soundness/completeness characterisation, and the exact counts
  `608 = 303 + 305` (positive including `1`, and negative).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The uniform local color theorem should extend to a *decidable*,
countable classification of the discriminants it is applied to.  The proposed bounded test
("all fundamental discriminants with `|D| ≤ 1000`") has an exact integer answer that can be
certified rather than asserted.

Experiment (Experimenter): Encode the classical predicate; build a Boolean mirror using
`Int.squarefree_natAbs` to sidestep the absence of a `Squarefree` decision procedure over `ℤ`;
count by `native_decide` over `Finset.Icc (-1000) 1000`.  Small cases reproduce OEIS A003658
(positive fundamental discriminants `1, 5, 8, 12, 13, …`) and A003657 (`|D|` for negative
ones `3, 4, 7, 8, 11, …`).

Analysis (Analyst): The count is `608`, split as `303` positive (the trivial discriminant `1`
included) and `305` negative.  The `D ≡ 1 (mod 4)` branch is genuinely squarefree; the
`D = 4m` branch never is (it is divisible by `4`), which is exactly why ramification at the
prime `2` behaves differently there — reflected in the odd-prime hypothesis of the anchoring
theorem.

Critique (Critic): The count theorem alone would be a bare `native_decide`; it is admissible
only as a *corollary* of the proved bridge `isFundDisc_eq_true_iff` and the membership
characterisation `mem_fundDiscsUpTo1000`, which carry the mathematical content.  The
anchoring theorem is guarded to odd primes precisely so no hidden `p = 2` corner case slips
through.

Synthesis (PI): We obtain a self-contained, decidable theory of fundamental discriminants
with a certified finite census, wired back to the imported local color dictionary.
-- !-- Lab Notes -- !--
-/

namespace LanglandsForToddlers

open scoped Classical

/-- The classical predicate characterising fundamental discriminants of quadratic fields:
either `D ≡ 1 (mod 4)` and `D` is squarefree, or `D = 4m` with `m ≡ 2, 3 (mod 4)` and `m`
squarefree.  (The second branch is written using `D / 4`, which is exact when `D ≡ 0 (mod 4)`.) -/
def IsFundamentalDiscriminant (D : ℤ) : Prop :=
  (D % 4 = 1 ∧ Squarefree D) ∨
  (D % 4 = 0 ∧ Squarefree (D / 4) ∧ ((D / 4) % 4 = 2 ∨ (D / 4) % 4 = 3))

/-- A computable Boolean test for `IsFundamentalDiscriminant`, using absolute values so that
the decidability of `Squarefree` over `ℕ` applies. -/
def isFundDisc (D : ℤ) : Bool :=
  (D % 4 == 1 && decide (Squarefree D.natAbs)) ||
  (D % 4 == 0 && decide (Squarefree (D / 4).natAbs) && ((D / 4) % 4 == 2 || (D / 4) % 4 == 3))

/-- The Boolean test is faithful to the mathematical predicate. -/
theorem isFundDisc_eq_true_iff (D : ℤ) :
    isFundDisc D = true ↔ IsFundamentalDiscriminant D := by
  unfold isFundDisc IsFundamentalDiscriminant
  simp only [Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq,
    Int.squarefree_natAbs]
  tauto

/-- Consequently, being a fundamental discriminant is decidable. -/
instance : DecidablePred IsFundamentalDiscriminant := fun D =>
  decidable_of_iff (isFundDisc D = true) (isFundDisc_eq_true_iff D)

/-- Every fundamental discriminant is congruent to `0` or `1` modulo `4`. -/
theorem fundDisc_mod_four {D : ℤ} (h : IsFundamentalDiscriminant D) :
    D % 4 = 0 ∨ D % 4 = 1 := by
  rcases h with ⟨h1, _⟩ | ⟨h0, _, _⟩
  · exact Or.inr h1
  · exact Or.inl h0

/-- The two defining branches are mutually exclusive: no discriminant is simultaneously
`≡ 0` and `≡ 1` modulo `4`. -/
theorem fundDisc_branches_disjoint {D : ℤ} :
    ¬ ((D % 4 = 1 ∧ Squarefree D) ∧
       (D % 4 = 0 ∧ Squarefree (D / 4) ∧ ((D / 4) % 4 = 2 ∨ (D / 4) % 4 = 3))) := by
  rintro ⟨⟨h1, _⟩, h0, _, _⟩
  omega

/-- A fundamental discriminant is nonzero. -/
theorem fundDisc_ne_zero {D : ℤ} (h : IsFundamentalDiscriminant D) : D ≠ 0 := by
  rintro rfl
  rcases h with ⟨h1, _⟩ | ⟨_, h2, _⟩
  · norm_num at h1
  · have hz : ((0 : ℤ) / 4) = 0 := by norm_num
    rw [hz] at h2
    exact not_squarefree_zero h2

/-- In the `D ≡ 1 (mod 4)` branch, a fundamental discriminant is squarefree. -/
theorem fundDisc_one_mod_four_squarefree {D : ℤ}
    (h : IsFundamentalDiscriminant D) (h1 : D % 4 = 1) : Squarefree D := by
  rcases h with ⟨_, hsq⟩ | ⟨h0, _, _⟩
  · exact hsq
  · omega

/-- In the even branch, a fundamental discriminant is never squarefree: it is divisible by
`4 = 2·2`, so the prime `2` ramifies wildly. -/
theorem fundDisc_even_not_squarefree {D : ℤ}
    (h0 : D % 4 = 0) : ¬ Squarefree D := by
  intro hsq
  have h4 : (2 : ℤ) * 2 ∣ D := by
    obtain ⟨k, hk⟩ := Int.dvd_of_emod_eq_zero h0
    exact ⟨k, by rw [hk]; ring⟩
  have hu : IsUnit (2 : ℤ) := hsq 2 h4
  rw [Int.isUnit_iff] at hu
  omega

/-- Squarefreeness is exactly the invariant separating the two branches: a fundamental
discriminant is squarefree if and only if it lies in the `D ≡ 1 (mod 4)` branch.  This
upgrades the tame/wild ramification distinction to a clean binary criterion. -/
theorem fundDisc_squarefree_iff_one_mod_four {D : ℤ}
    (h : IsFundamentalDiscriminant D) : Squarefree D ↔ D % 4 = 1 := by
  rcases fundDisc_mod_four h with h0 | h1
  · constructor
    · intro hsq; exact absurd hsq (fundDisc_even_not_squarefree h0)
    · intro h1; omega
  · exact ⟨fun _ => h1, fun h1 => fundDisc_one_mod_four_squarefree h h1⟩

/-- Ramification is tame in the odd branch: if `D ≡ 1 (mod 4)` is a fundamental discriminant
and a prime `p` divides `D`, then `p` divides `D` exactly once (`p²` does not divide `D`). -/
theorem fundDisc_prime_dvd_not_sq {D : ℤ} {p : ℕ} [Fact p.Prime]
    (h : IsFundamentalDiscriminant D) (h1 : D % 4 = 1) :
    ¬ ((p : ℤ) * (p : ℤ)) ∣ D := by
  intro hsq
  have hsqfree : Squarefree D := fundDisc_one_mod_four_squarefree h h1
  have hunit : IsUnit (p : ℤ) := hsqfree (p : ℤ) hsq
  have hp1 : (p : ℤ) ≠ 1 ∧ (p : ℤ) ≠ -1 := by
    have hprime := (Fact.out : p.Prime)
    have : 2 ≤ p := hprime.two_le
    constructor <;> intro hh <;> omega
  rcases Int.isUnit_iff.mp hunit with h' | h'
  · exact hp1.1 h'
  · exact hp1.2 h'

/-- Local anchoring theorem.  For a fundamental discriminant `D` in the `D ≡ 1 (mod 4)` branch
and a prime `p` dividing `D`, the imported local color vanishes (ramification) and the
ramification is tame (`p^2` does not divide `D`).  This ties the arithmetic predicate to the Legendre-symbol
dictionary `quadraticColor_eq_zero_iff_dvd`. -/
theorem fundDisc_odd_ramification {D : ℤ} {p : ℕ} [Fact p.Prime]
    (h : IsFundamentalDiscriminant D) (h1 : D % 4 = 1) (hp : (p : ℤ) ∣ D) :
    quadraticColor D p = 0 ∧ ¬ ((p : ℤ) * (p : ℤ)) ∣ D := by
  refine ⟨?_, fundDisc_prime_dvd_not_sq h h1⟩
  exact (quadraticColor_eq_zero_iff_dvd D p).mpr hp

/-! ### Certified bounded enumeration -/

/-- The finite set of all fundamental discriminants of absolute value at most `1000`. -/
def fundDiscsUpTo1000 : Finset ℤ :=
  (Finset.Icc (-1000 : ℤ) 1000).filter (fun D => isFundDisc D)

/-- Soundness and completeness of the bounded enumeration: membership is exactly "in range
and fundamental". -/
theorem mem_fundDiscsUpTo1000 (D : ℤ) :
    D ∈ fundDiscsUpTo1000 ↔
      (-1000 ≤ D ∧ D ≤ 1000 ∧ IsFundamentalDiscriminant D) := by
  unfold fundDiscsUpTo1000
  rw [Finset.mem_filter, Finset.mem_Icc]
  rw [isFundDisc_eq_true_iff]
  tauto

/-- The exact number of fundamental discriminants with `|D| ≤ 1000` is `608`. -/
theorem card_fundDiscsUpTo1000 : fundDiscsUpTo1000.card = 608 := by
  unfold fundDiscsUpTo1000
  native_decide

/-- The finite set of positive fundamental discriminants at most `1000`. -/
def positiveFundDiscsUpTo1000 : Finset ℤ :=
  (Finset.Icc (1 : ℤ) 1000).filter (fun D => isFundDisc D)

/-- There are exactly `303` positive fundamental discriminants at most `1000` (including the
trivial discriminant `1`). -/
theorem card_positiveFundDiscsUpTo1000 : positiveFundDiscsUpTo1000.card = 303 := by
  unfold positiveFundDiscsUpTo1000
  native_decide

/-- The finite set of negative fundamental discriminants with `|D| ≤ 1000`. -/
def negativeFundDiscsUpTo1000 : Finset ℤ :=
  (Finset.Icc (-1000 : ℤ) (-1)).filter (fun D => isFundDisc D)

/-- There are exactly `305` negative fundamental discriminants with `|D| ≤ 1000`. -/
theorem card_negativeFundDiscsUpTo1000 : negativeFundDiscsUpTo1000.card = 305 := by
  unfold negativeFundDiscsUpTo1000
  native_decide

/-- The census splits cleanly by sign: `608 = 303 + 305`, since `0` is not a fundamental
discriminant. -/
theorem card_split :
    positiveFundDiscsUpTo1000.card + negativeFundDiscsUpTo1000.card =
      fundDiscsUpTo1000.card := by
  rw [card_positiveFundDiscsUpTo1000, card_negativeFundDiscsUpTo1000, card_fundDiscsUpTo1000]

end LanglandsForToddlers