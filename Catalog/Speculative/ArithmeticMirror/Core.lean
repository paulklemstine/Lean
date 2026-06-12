/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Arithmetic Mirror Symmetry for Calabi–Yau: the Hodge–diamond shadow

Mirror symmetry predicts that to a Calabi–Yau `d`-fold `X` there is associated a
*mirror* `Y`, again Calabi–Yau, whose Hodge diamond is the **vertical reflection** of
that of `X`:

  `hᵖᵠ(Y) = h^{d-p,q}(X)`.

This single combinatorial swap encodes the deep geometric exchange "complex moduli of
`X` ↔ Kähler moduli of `Y`", and in particular the heuristic that the *count of
rational curves* on `X` (controlled by `h^{d-1,1}(X)`) equals the *rank of the Picard
group* of the mirror `Y` (which is `h^{1,1}(Y)`).

This file isolates the fully verifiable **arithmetic / combinatorial heart** of that
picture and proves it `sorry`-free:

* `CalabiYau d` — a Hodge diamond: a symmetric (`conj_symm`), Serre-dual (`serre`)
  array of Hodge numbers supported on `[0,d]²` (`vanish`).
* `mirror` — the vertical reflection, **proved again to be a `CalabiYau`** (closure of
  the Calabi–Yau axioms under mirroring is itself the structural content).
* `mirror_involutive` — mirroring is an involution.
* `picardRank_mirror` — **arithmetic mirror symmetry**: the Picard rank `h^{1,1}` of
  the mirror equals `h^{d-1,1}` of `X`, the curve-counting Hodge number.
* `eulerChar_mirror` — the topological mirror law `χ(Y) = (-1)^d χ(X)`.
* The **K3** diamond as a worked, self-mirror example with `χ = 24`.

## References
* P. Candelas, X. de la Ossa, P. Green, L. Parkes, *A pair of Calabi–Yau manifolds as
  an exactly soluble superconformal theory* (1991).
* D. Cox, S. Katz, *Mirror Symmetry and Algebraic Geometry* (1999).

-- !-- Lab Notebook -- !--
Hypothesis: The "rational-curve count = Picard rank of mirror" slogan and the
  topological law `χ(Y)=(-1)^d χ(X)` are *purely combinatorial* consequences of the
  vertical Hodge reflection, once the Calabi–Yau Hodge axioms (conjugation + Serre
  duality + finite support) are imposed; no geometry is needed for the arithmetic core.
Result: Confirmed. `mirror` is closed inside `CalabiYau`, it is an involution, it sends
  `h^{1,1}` to `h^{d-1,1}`, and it scales the Euler characteristic by `(-1)^d`. The K3
  diamond is self-mirror with `χ = 24`.
Insight: The closure proof (`mirror` is a `CalabiYau`) is where conjugation symmetry and
  Serre duality must be used *together*: `h^{d-p,q} = h^{q,d-p} = h^{d-q,p}`. Reflecting
  one index and conjugating recovers the other reflection — this is the algebraic
  fingerprint of mirror symmetry being an involution on diamonds.
Failure analysis: A naive `mirror` without the `if p ≤ d ∧ q ≤ d` guard breaks finite
  support (`vanish`) because `Nat` truncated subtraction sends `p > d` to `0` rather than
  off-diamond; guarding the reflection on the support box repairs every axiom.
-/

import Mathlib

open scoped BigOperators

namespace ArithmeticMirror

/-- A **Hodge diamond** of a Calabi–Yau `d`-fold: the array of Hodge numbers
`hᵖᵠ = dim H^q(X, Ωᵖ)`, modeled as a function `ℕ → ℕ → ℕ` satisfying the structural
axioms of a Calabi–Yau Hodge diamond.

* `conj_symm` — complex-conjugation symmetry `hᵖᵠ = hᵠᵖ`;
* `serre`     — Serre duality `hᵖᵠ = h^{d-p,d-q}`;
* `vanish`    — finite support: `hᵖᵠ = 0` outside the box `[0,d]²`. -/
structure CalabiYau (d : ℕ) where
  /-- The Hodge numbers `hᵖᵠ`. -/
  h : ℕ → ℕ → ℕ
  /-- Conjugation symmetry of the Hodge diamond. -/
  conj_symm : ∀ p q, p ≤ d → q ≤ d → h p q = h q p
  /-- Serre duality of the Hodge diamond. -/
  serre : ∀ p q, p ≤ d → q ≤ d → h p q = h (d - p) (d - q)
  /-- Hodge numbers vanish outside the support box `[0,d]²`. -/
  vanish : ∀ p q, (d < p ∨ d < q) → h p q = 0

namespace CalabiYau

variable {d : ℕ}

/-- The **Picard rank** (rank of the Néron–Severi / Picard group), `h^{1,1}`. -/
def picardRank (X : CalabiYau d) : ℕ := X.h 1 1

/-- The **Euler characteristic** `χ = Σ_{p,q} (-1)^{p+q} hᵖᵠ`, summed over the support
box `[0,d]²`. -/
def eulerChar (X : CalabiYau d) : ℤ :=
  ∑ p ∈ Finset.range (d + 1), ∑ q ∈ Finset.range (d + 1),
    (-1 : ℤ) ^ (p + q) * (X.h p q : ℤ)

/-- The mirror's Hodge function: the vertical reflection `p ↦ d - p`, guarded to the
support box so finiteness is preserved. -/
def mirrorH (X : CalabiYau d) : ℕ → ℕ → ℕ :=
  fun p q => if p ≤ d ∧ q ≤ d then X.h (d - p) q else 0

-- !-- conj on `(d-p,q)` then Serre on `(q,d-p)` gives `h^{d-p,q}=h^{q,d-p}=h^{d-q,p}`. -- !--
/-- Reflecting one index and using conjugation + Serre duality recovers the other
reflection: this is the key algebraic identity behind mirror symmetry. -/
theorem reflect_eq (X : CalabiYau d) {p q : ℕ} (hp : p ≤ d) (hq : q ≤ d) :
    X.h (d - p) q = X.h (d - q) p := by
  have h1 := X.conj_symm (d - p) q ?_ ?_ <;> simp_all +decide
  convert X.serre q (d - p) hq (Nat.sub_le _ _) using 1
  rw [Nat.sub_sub_self hp]

-- !-- Within the box `mirrorH p q = h^{d-p,q}`; `reflect_eq` makes it symmetric. -- !--
/-- The mirror diamond is again conjugation-symmetric. -/
theorem mirrorH_conj (X : CalabiYau d) (p q : ℕ) (hp : p ≤ d) (hq : q ≤ d) :
    X.mirrorH p q = X.mirrorH q p := by
  unfold CalabiYau.mirrorH
  rw [if_pos ⟨hp, hq⟩, if_pos ⟨hq, hp⟩, reflect_eq X hp hq]

-- !-- `h^{d-p,q} = h^{d-(d-p),d-q} = h^{p,d-q}` by Serre duality directly. -- !--
/-- The mirror diamond is again Serre-dual. -/
theorem mirrorH_serre (X : CalabiYau d) (p q : ℕ) (hp : p ≤ d) (hq : q ≤ d) :
    X.mirrorH p q = X.mirrorH (d - p) (d - q) := by
  unfold mirrorH; simp +decide [*, Nat.sub_sub_self]
  convert X.serre (d - p) q (by omega) (by omega) using 1
  rw [Nat.sub_sub_self hp]

-- !-- The guard `if p ≤ d ∧ q ≤ d` forces `0` off-box. -- !--
/-- The mirror diamond is again finitely supported. -/
theorem mirrorH_vanish (X : CalabiYau d) (p q : ℕ) (h : d < p ∨ d < q) :
    X.mirrorH p q = 0 := by
  unfold CalabiYau.mirrorH
  grind

/-- The **mirror** Calabi–Yau `Y`: vertical reflection of the Hodge diamond. The content
is that this is *again* a Calabi–Yau (closure under mirroring). -/
def mirror (X : CalabiYau d) : CalabiYau d where
  h := X.mirrorH
  conj_symm := X.mirrorH_conj
  serre := X.mirrorH_serre
  vanish := X.mirrorH_vanish

-- !-- `mirror(mirror)(p,q) = h^{d-(d-p),q} = h^{p,q}` in-box; both sides `0` off-box. -- !--
/-- **Mirroring is an involution** on Hodge diamonds. -/
theorem mirror_involutive (X : CalabiYau d) :
    (X.mirror.mirror).h = X.h := by
  ext p q
  by_cases hp : p ≤ d <;> by_cases hq : q ≤ d <;>
    simp +decide [hp, hq, CalabiYau.mirror, CalabiYau.mirrorH]
  · rw [Nat.sub_sub_self hp]
  · exact Eq.symm (X.vanish p q (Or.inr (not_le.mp hq)))
  · rw [X.vanish p q (Or.inl (not_le.mp hp))]
  · rw [X.vanish p q (Or.inl (not_le.mp hp))]

-- !-- By definition `mirror.h 1 1 = h^{d-1,1}` once `1 ≤ d` activates the guard. -- !--
/-- **Arithmetic mirror symmetry (curve count ↔ Picard rank).** The Picard rank
`h^{1,1}` of the mirror equals `h^{d-1,1}` of `X`, the Hodge number governing the count
of rational curves. -/
theorem picardRank_mirror (X : CalabiYau d) (hd : 1 ≤ d) :
    X.mirror.picardRank = X.h (d - 1) 1 := by
  exact if_pos ⟨hd, hd⟩

-- !-- `(-1)^{d-p+q}·(-1)^{2p} = (-1)^{d+p+q}`, and `(-1)^{2p}=1`, since `p ≤ d`. -- !--
/-- Sign reflection identity used for the Euler-characteristic law. -/
theorem sign_reflect (d p q : ℕ) (hp : p ≤ d) :
    (-1 : ℤ) ^ (d - p + q) = (-1) ^ d * (-1) ^ (p + q) := by
  have key : (d - p + q) + 2 * p = d + (p + q) := by omega
  calc (-1 : ℤ) ^ (d - p + q) = (-1) ^ (d - p + q) * (-1) ^ (2 * p) := by simp [pow_mul]
    _ = (-1) ^ (d - p + q + 2 * p) := by rw [← pow_add]
    _ = (-1) ^ (d + (p + q)) := by rw [key]
    _ = (-1) ^ d * (-1) ^ (p + q) := by rw [pow_add]

-- !-- Reflect the `p`-sum (`Finset.sum_range_reflect`/`sum_flip`); each term picks up
-- `(-1)^{d-p+q} = (-1)^d (-1)^{p+q}` (`sign_reflect`), factoring out `(-1)^d`. -- !--
/-- **Topological mirror law.** `χ(Y) = (-1)^d χ(X)`. -/
theorem eulerChar_mirror (X : CalabiYau d) :
    X.mirror.eulerChar = (-1) ^ d * X.eulerChar := by
  simp [CalabiYau.eulerChar, CalabiYau.mirror]
  simp +decide [Finset.mul_sum _ _ _, CalabiYau.mirrorH]
  rw [← Finset.sum_flip]
  refine Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => ?_
  rw [if_pos ⟨Nat.sub_le _ _, Finset.mem_range_succ_iff.mp hj⟩,
    Nat.sub_sub_self (Finset.mem_range_succ_iff.mp hi)]
  rw [← mul_assoc, ← pow_add, tsub_add_eq_add_tsub (Finset.mem_range_succ_iff.mp hi)]
  rw [show d + (i + j) = d + j - i + (2 * i) by
    linarith [Nat.sub_add_cancel (show i ≤ d + j from by
      linarith [Finset.mem_range.mp hi, Finset.mem_range.mp hj])]]
  norm_num [pow_add, pow_mul]

end CalabiYau

/-! ## The K3 surface: a self-mirror example with `χ = 24` -/

/-- The K3 Hodge diamond (`d = 2`):
`h⁰⁰=h²²=h²⁰=h⁰²=1`, `h¹¹=20`, all odd Hodge numbers `0`. -/
def K3h : ℕ → ℕ → ℕ := fun p q =>
  if p ≤ 2 ∧ q ≤ 2 then
    (if p = 1 ∧ q = 1 then 20
     else if p % 2 = 0 ∧ q % 2 = 0 then 1
     else 0)
  else 0

-- !-- K3 diamond is symmetric: check the `3×3` box by `interval_cases`. -- !--
/-- The K3 diamond is conjugation-symmetric. -/
theorem K3h_conj (p q : ℕ) (hp : p ≤ 2) (hq : q ≤ 2) : K3h p q = K3h q p := by
  interval_cases p <;> interval_cases q <;> trivial

-- !-- Serre duality `0↔2, 1↔1` leaves the K3 diamond invariant. -- !--
/-- The K3 diamond is Serre-dual. -/
theorem K3h_serre (p q : ℕ) (hp : p ≤ 2) (hq : q ≤ 2) :
    K3h p q = K3h (2 - p) (2 - q) := by
  interval_cases p <;> interval_cases q <;> rfl

-- !-- The guard forces `0` off the `[0,2]²` box. -- !--
/-- The K3 diamond is finitely supported. -/
theorem K3h_vanish (p q : ℕ) (h : 2 < p ∨ 2 < q) : K3h p q = 0 := by
  grind +locals

/-- The K3 surface as a Calabi–Yau `2`-fold. -/
def K3 : CalabiYau 2 := ⟨K3h, K3h_conj, K3h_serre, K3h_vanish⟩

-- !-- `χ = h⁰⁰+h⁰²+h²⁰+h²²+h¹¹ = 1+1+1+1+20 = 24`, by unfolding the finite sum. -- !--
/-- **`χ(K3) = 24`.** -/
theorem K3_eulerChar : K3.eulerChar = 24 := by
  unfold K3 CalabiYau.eulerChar; decide

-- !-- `picardRank (mirror K3) = h^{1,1}(K3) = 20` since `d-1 = 1`; K3 is self-mirror. -- !--
/-- K3 is self-mirror at the level of the Picard / curve-counting number:
`picardRank (mirror K3) = K3.picardRank = 20`. -/
theorem K3_self_mirror_picard :
    K3.mirror.picardRank = K3.picardRank := by
  rw [CalabiYau.picardRank_mirror K3 (by norm_num)]; rfl

end ArithmeticMirror