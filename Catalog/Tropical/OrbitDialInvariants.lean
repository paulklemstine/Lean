import Mathlib

/-!
# Berggren-tree orbit invariants: the revealed residue set is universal

This file formalises the *characterisation arm* of the ORBIT-DIAL-CAP-TEST
(FACT round-74 #2, exp 564): the residues revealed by the root component of the
Berggren triplet tree are fixed once and for all, so the "orbit dial" they define is
the same table for every semiprime `N`.

## Contents

* `OrbitDialCap.Berggren.InTree` — the root component of the Berggren tree, generated
  from `(3,4,5)` by the three unimodular matrices `B₁, B₂, B₃`.
* `OrbitDialCap.Berggren.inTree_isPT` — every node is a Pythagorean triple.
* `OrbitDialCap.Berggren.inTree_congruence` — the congruence invariant of the whole
  component: `a` odd, `4 ∣ b`, `c ≡ 1 (mod 4)`.
* `OrbitDialCap.Berggren.revealed_mod4_eq` — **the revealed residue set mod 4 is the
  fixed two-element set `{(1,0,1), (3,0,1)}`**, hence carries no parameter dependence:
  the orbit dial is one universal exclusion table.
* `OrbitDialCap.Berggren.three_dvd_leg_mul` — barrier 6 restated as a primitive-triple
  congruence: `3` divides a leg of every Pythagorean triple.
* `OrbitDialCap.Berggren.parity_dial_sound` — the bridge to factoring: the parity skip
  never discards a divisor of an odd `N`, i.e. it has soundness `s = 1`.
-/

namespace OrbitDialCap
namespace Berggren

/-- An integer Pythagorean triple. -/
def IsPT (t : ℤ × ℤ × ℤ) : Prop := t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2

/-- First Berggren matrix `[[1,-2,2],[2,-1,2],[2,-2,3]]`. -/
def B1 (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 - 2 * t.2.1 + 2 * t.2.2, 2 * t.1 - t.2.1 + 2 * t.2.2, 2 * t.1 - 2 * t.2.1 + 3 * t.2.2)

/-- Second Berggren matrix `[[1,2,2],[2,1,2],[2,2,3]]`. -/
def B2 (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 + 2 * t.2.1 + 2 * t.2.2, 2 * t.1 + t.2.1 + 2 * t.2.2, 2 * t.1 + 2 * t.2.1 + 3 * t.2.2)

/-- Third Berggren matrix `[[-1,2,2],[-2,1,2],[-2,2,3]]`. -/
def B3 (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (-t.1 + 2 * t.2.1 + 2 * t.2.2, -2 * t.1 + t.2.1 + 2 * t.2.2, -2 * t.1 + 2 * t.2.1 + 3 * t.2.2)

/-- The root component of the Berggren tree: the orbit of `(3,4,5)` under the three
Berggren moves.  This is exactly the set of nodes enumerated by the experiment's
root BFS. -/
inductive InTree : ℤ × ℤ × ℤ → Prop
  | root : InTree (3, 4, 5)
  | step1 {t} : InTree t → InTree (B1 t)
  | step2 {t} : InTree t → InTree (B2 t)
  | step3 {t} : InTree t → InTree (B3 t)

/-- Every node of the root component is a Pythagorean triple. -/
theorem inTree_isPT {t : ℤ × ℤ × ℤ} (h : InTree t) : IsPT t := by
  induction h with
  | root => norm_num [IsPT]
  | step1 _ ih => simp only [IsPT, B1] at ih ⊢; linear_combination ih
  | step2 _ ih => simp only [IsPT, B2] at ih ⊢; linear_combination ih
  | step3 _ ih => simp only [IsPT, B3] at ih ⊢; linear_combination ih

/-- **The congruence invariant of the root component.**  Every node has odd first leg,
second leg divisible by `4`, and hypotenuse `≡ 1 (mod 4)`.  The three Berggren moves
preserve this class, so no BFS budget — and in particular no choice of a target `N` —
can enlarge the revealed set. -/
theorem inTree_congruence {t : ℤ × ℤ × ℤ} (h : InTree t) :
    t.1 % 2 = 1 ∧ t.2.1 % 4 = 0 ∧ t.2.2 % 4 = 1 := by
  induction h with
  | root => norm_num
  | step1 _ ih => simp only [B1]; omega
  | step2 _ ih => simp only [B2]; omega
  | step3 _ ih => simp only [B3]; omega

/-- The node `(5,12,13)`, the first `B₁`-child of the root. -/
theorem inTree_five_twelve_thirteen : InTree (5, 12, 13) := by
  have h := InTree.step1 InTree.root
  norm_num [B1] at h
  exact h

/-- The revealed residue set of the root component, projected to `ZMod 4`. -/
def revealedMod4 : Set (ZMod 4 × ZMod 4 × ZMod 4) :=
  {r | ∃ t, InTree t ∧ r = ((t.1 : ZMod 4), (t.2.1 : ZMod 4), (t.2.2 : ZMod 4))}

private lemma cast_of_emod {t : ℤ} {r : ℕ} (h : t % 4 = (r : ℤ)) :
    (t : ZMod 4) = (r : ZMod 4) := by
  have hdvd : (4 : ℤ) ∣ t - (r : ℤ) := by omega
  have := (ZMod.intCast_zmod_eq_zero_iff_dvd (t - (r : ℤ)) 4).mpr hdvd
  push_cast at this
  linear_combination this

/-- **N-invariance of the orbit dial.**  The revealed set mod `4` is exactly the fixed
two-element set `{(1,0,1), (3,0,1)}`.  It is a constant of the tree, not a function of
any target: an orbit dial built from it is one universal exclusion table. -/
theorem revealed_mod4_eq :
    revealedMod4 =
      {((1 : ZMod 4), (0 : ZMod 4), (1 : ZMod 4)), ((3 : ZMod 4), (0 : ZMod 4), (1 : ZMod 4))} := by
  ext r
  constructor
  · rintro ⟨t, ht, rfl⟩
    obtain ⟨h1, h2, h3⟩ := inTree_congruence ht
    have e2 : (t.2.1 : ZMod 4) = 0 := by
      have := cast_of_emod (t := t.2.1) (r := 0) (by exact_mod_cast h2)
      simpa using this
    have e3 : (t.2.2 : ZMod 4) = 1 := by
      have := cast_of_emod (t := t.2.2) (r := 1) (by exact_mod_cast h3)
      simpa using this
    rcases (by omega : t.1 % 4 = 1 ∨ t.1 % 4 = 3) with h | h
    · left
      have e1 := cast_of_emod (t := t.1) (r := 1) (by exact_mod_cast h)
      simp [e1, e2, e3]
    · right
      have e1 := cast_of_emod (t := t.1) (r := 3) (by exact_mod_cast h)
      simp [e1, e2, e3]
  · rintro (rfl | rfl)
    · exact ⟨(5, 12, 13), inTree_five_twelve_thirteen, by decide⟩
    · exact ⟨(3, 4, 5), InTree.root, by decide⟩

/-- The revealed set is *not* a singleton: both odd classes mod `4` occur, so the orbit
dial is a genuine two-class table (and still parameter-free). -/
theorem revealed_mod4_card_two :
    ((1 : ZMod 4), (0 : ZMod 4), (1 : ZMod 4)) ∈ revealedMod4 ∧
    ((3 : ZMod 4), (0 : ZMod 4), (1 : ZMod 4)) ∈ revealedMod4 := by
  rw [revealed_mod4_eq]
  exact ⟨by simp, by simp⟩

/-- Barrier 6 as a primitive-triple congruence: in every Pythagorean triple one of the
legs is divisible by `3`. -/
theorem three_dvd_leg_mul {t : ℤ × ℤ × ℤ} (h : IsPT t) : (3 : ℤ) ∣ t.1 * t.2.1 := by
  have key : ∀ x y z : ZMod 3, x ^ 2 + y ^ 2 = z ^ 2 → x * y = 0 := by decide
  have hcast : ((t.1 : ZMod 3)) ^ 2 + ((t.2.1 : ZMod 3)) ^ 2 = ((t.2.2 : ZMod 3)) ^ 2 := by
    have h' := congrArg (fun n : ℤ => (n : ZMod 3)) h
    push_cast at h'
    exact h'
  have hz : (((t.1 * t.2.1 : ℤ)) : ZMod 3) = 0 := by
    push_cast
    exact key _ _ _ hcast
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ 3).mp hz

/-- Every node of the Berggren root component has a leg divisible by `3`. -/
theorem inTree_three_dvd_leg_mul {t : ℤ × ℤ × ℤ} (h : InTree t) : (3 : ℤ) ∣ t.1 * t.2.1 :=
  three_dvd_leg_mul (inTree_isPT h)

/-- **Soundness of the parity skip.**  If `N` is odd, no divisor of `N` is even, so the
dial "skip even candidates" never discards the answer: its soundness is `s = 1`.  It is
computable from `N` alone and is identical for every `N`, hence carries no per-`N`
information. -/
theorem parity_dial_sound {N p : ℕ} (hN : Odd N) (hp : p ∣ N) : ¬ (2 ∣ p) := by
  intro h2
  have h : 2 ∣ N := h2.trans hp
  rw [Nat.odd_iff] at hN
  omega

/-- The parity dial's *kept set*, as a family indexed by the target `N`. -/
def parityKept : ℕ → Set ℕ := fun _ => {p | ¬ (2 ∣ p)}

/-- The family is constant: the same table for every target. -/
theorem parityKept_const (N M : ℕ) : parityKept N = parityKept M := rfl

/-- Nevertheless the parity dial is *useful*: for odd `N` its kept set contains every
divisor, i.e. it is sound while discarding half of all candidates. -/
theorem parityKept_sound {N : ℕ} (hN : Odd N) : ∀ p, p ∣ N → p ∈ parityKept N :=
  fun _ hp => parity_dial_sound hN hp

/-- An *informative* residue dial, for contrast: for a semiprime `N = p q` with odd
factors, knowing `N ≡ 3 (mod 4)` pins the pair of factor classes mod `4` down to a
swap — one genuine bit of per-`N` content, unlike the orbit dial. -/
theorem residue_dial_one_bit {p q : ℕ} (hp : Odd p) (hq : Odd q) (hN : (p * q) % 4 = 3) :
    (p % 4 = 1 ∧ q % 4 = 3) ∨ (p % 4 = 3 ∧ q % 4 = 1) := by
  have hp4 : p % 4 = 1 ∨ p % 4 = 3 := by rcases hp with ⟨k, hk⟩; omega
  have hq4 : q % 4 = 1 ∨ q % 4 = 3 := by rcases hq with ⟨k, hk⟩; omega
  have hmul : (p * q) % 4 = (p % 4) * (q % 4) % 4 := Nat.mul_mod p q 4
  rcases hp4 with h1 | h1 <;> rcases hq4 with h2 | h2 <;> rw [h1, h2] at hmul <;> omega

end Berggren
end OrbitDialCap