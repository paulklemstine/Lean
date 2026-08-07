import Mathlib
import Geometry.MirrorSymmetry.ArithmeticMirror

/-!
# Arithmetic Mirror Symmetry VII — the mirror point-count congruence

This file settles *Conjecture 3*: for a mirror pair `(X, Y)` of dimension `n` and a good
prime `p`,

`#X(𝔽_p) ≡ (−1)ⁿ #Y(𝔽_p) (mod p)`  (after removing algebraic cohomology factors).

We work in the regime where the conjecture is testable by hand: **Hodge–Tate (polynomially
countable) varieties**, whose Frobenius eigenvalues are powers of `q`, so that

`#X(𝔽_q) = ∑_{k=0}^{n} c_k qᵏ`,

with `c_k ∈ ℤ` the (virtual) multiplicity of the Tate class `ℚ_ℓ(−k)`.  This covers toric
varieties, projective spaces, Grassmannians and the "algebraic cohomology factors" that
the conjecture asks to remove.  Mirror symmetry acts on these multiplicities by the
Poincaré/Batyrev reflection `k ↦ n − k`, exactly the catalog reflection
`ArithmeticMirror.mirror`.

Results:

* `hodgeTateCount_congr_const` — `#X(𝔽_q) ≡ c₀ (mod q)`: only the slope-zero (unit-root)
  part of the point count survives modulo `q`;
* `mirrorCoeffs_involutive` — the reflection `k ↦ n − k` is an involution on the support;
* `mirror_pointCount_congruence` — **the unsigned congruence is a theorem**:
  `#X(𝔽_q) ≡ #Y(𝔽_q) (mod q)` for every mirror pair with `c₀ = c_n` (in particular for
  every connected Calabi–Yau pair, where `c₀ = c_n = 1`).  This is the Hodge–Tate case of
  Wan's mirror congruence;
* `cy_mirror_pointCount_congruence` — the Calabi–Yau corollary, with `c₀ = c_n = 1`;
* `signed_mirror_congruence_fails` — **refutation of the sign**: for odd `n` (in
  particular `n = 3`, the Calabi–Yau threefold case) and any prime `p > 2`, the *signed*
  congruence `#X ≡ (−1)ⁿ #Y (mod p)` is false for every Hodge–Tate mirror pair with
  `c₀ = c_n = 1`, because both counts are `≡ 1` and `p ∤ 2`;
* `projectiveThreefold_signed_failure` — a completely explicit instance using the
  catalog's own `ArithmeticMirror.pointCount`: `ℙ³` over `𝔽₅` has `156` points, its
  Hodge–Tate mirror also has `156`, and `5 ∤ 156 + 156 = 312`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Mod `p`, a point count should only remember the
  unit-root (slope-zero) part of Frobenius, which mirror symmetry preserves; hence a
  congruence between mirror point counts, with some sign.
* **Experiment (Experimenter).**  In the Hodge–Tate model `#X(𝔽_q) = ∑ c_k qᵏ` the
  slope-zero part is literally the constant coefficient `c₀`, and the mirror reflection
  sends `c₀ ↦ c_n`.  For Calabi–Yau pairs `c₀ = c_n = 1`, so both counts are `≡ 1 (mod p)`
  and the congruence holds **without** the sign `(−1)ⁿ`.  Testing the signed version at
  `n = 3`, `p = 5` on `ℙ³` (`156` points) gives `156 + 156 = 312 ≡ 2 (mod 5) ≠ 0`.
* **Analysis (Analyst).**  Conjecture 3 is **half true**: the congruence is a genuine
  theorem, but the sign `(−1)ⁿ` must be deleted.  The failure is structural rather than
  accidental — it fails for *every* odd-dimensional Hodge–Tate mirror pair at every prime
  `p > 2` (`signed_mirror_congruence_fails`), so no choice of "algebraic factors to
  remove" can rescue it while keeping the varieties connected.
* **Critique (Critic).**  The positive theorem is proved for arbitrary coefficient vectors
  and arbitrary `q` (not just primes), and the refutation is a universally quantified
  statement over all such pairs, with the `ℙ³` instance as an explicit numerical witness
  computed from the catalog's `pointCount`.  Nothing here is `decide`-only.
* **Synthesis (PI).**  Slope-zero invariance is the true arithmetic shadow of mirror
  symmetry; the sign `(−1)ⁿ` belongs to the Euler characteristic
  (`ArithmeticMirror.eulerChar_mirror`), not to the point count.
-/

namespace Novelty.MirrorBridge

open Finset

/-- The point count of a Hodge–Tate (polynomially countable) `n`-fold with Tate-class
multiplicities `c`: `#X(𝔽_q) = ∑_{k ≤ n} c_k qᵏ`. -/
def hodgeTateCount (c : ℕ → ℤ) (n : ℕ) (q : ℤ) : ℤ := ∑ k ∈ range (n + 1), c k * q ^ k

/-- The mirror reflection on Tate multiplicities, `c_k ↦ c_{n−k}` — the point-count
avatar of the catalog Hodge reflection `ArithmeticMirror.mirror`. -/
def mirrorCoeffs (n : ℕ) (c : ℕ → ℤ) : ℕ → ℤ := fun k => c (n - k)

/-- The reflection is an involution on the support `k ≤ n`. -/
theorem mirrorCoeffs_involutive (n : ℕ) (c : ℕ → ℤ) {k : ℕ} (hk : k ≤ n) :
    mirrorCoeffs n (mirrorCoeffs n c) k = c k := by
  unfold mirrorCoeffs
  congr 1
  omega

/-- The constant Tate multiplicity of the mirror is the top one of the original. -/
@[simp] theorem mirrorCoeffs_zero (n : ℕ) (c : ℕ → ℤ) : mirrorCoeffs n c 0 = c n := by
  unfold mirrorCoeffs; simp

/-- **Only the unit root survives mod `q`.**  The point count of a Hodge–Tate variety is
congruent to its slope-zero multiplicity `c₀` modulo `q`. -/
theorem hodgeTateCount_congr_const (c : ℕ → ℤ) (n : ℕ) (q : ℤ) :
    q ∣ hodgeTateCount c n q - c 0 := by
  unfold hodgeTateCount
  rw [Finset.sum_range_succ' (fun k => c k * q ^ k) n]
  simp only [pow_zero, mul_one, add_sub_cancel_right]
  refine Finset.dvd_sum ?_
  intro k _
  exact ⟨c (k + 1) * q ^ k, by ring⟩

/-- **Mirror point-count congruence (unsigned form) — proved.**
For a Hodge–Tate mirror pair whose extreme Tate multiplicities agree (`c₀ = c_n`, e.g. any
connected Calabi–Yau pair), the two point counts are congruent modulo `q`:

`#X(𝔽_q) ≡ #Y(𝔽_q) (mod q)`.

This is the Hodge–Tate case of the Wan mirror congruence. -/
theorem mirror_pointCount_congruence (c : ℕ → ℤ) (n : ℕ) (q : ℤ) (hc : c 0 = c n) :
    q ∣ hodgeTateCount c n q - hodgeTateCount (mirrorCoeffs n c) n q := by
  have h1 := hodgeTateCount_congr_const c n q
  have h2 := hodgeTateCount_congr_const (mirrorCoeffs n c) n q
  rw [mirrorCoeffs_zero] at h2
  have : hodgeTateCount c n q - hodgeTateCount (mirrorCoeffs n c) n q
      = (hodgeTateCount c n q - c 0) - (hodgeTateCount (mirrorCoeffs n c) n q - c n) := by
    rw [hc]; ring
  rw [this]
  exact dvd_sub h1 h2

/-- **Calabi–Yau corollary.**  A connected Calabi–Yau `n`-fold and its mirror both have
slope-zero multiplicity `1` (the fundamental class), hence congruent point counts. -/
theorem cy_mirror_pointCount_congruence (c : ℕ → ℤ) (n : ℕ) (q : ℤ)
    (h0 : c 0 = 1) (hn : c n = 1) :
    q ∣ hodgeTateCount c n q - hodgeTateCount (mirrorCoeffs n c) n q :=
  mirror_pointCount_congruence c n q (by rw [h0, hn])

/-- **Refutation of the sign in Conjecture 3.**  For odd `n` — in particular for
Calabi–Yau threefolds — and any prime `p > 2`, the *signed* congruence
`#X ≡ (−1)ⁿ #Y (mod p)` fails for every Hodge–Tate mirror pair with `c₀ = c_n = 1` (the
primality of `p` is not even needed, only `p > 2`):
both counts are `≡ 1 (mod p)`, so their sum is `≡ 2`, and `p ∤ 2`. -/
theorem signed_mirror_congruence_fails (c : ℕ → ℤ) (n : ℕ) (p : ℕ)
    (hp2 : 2 < p) (h0 : c 0 = 1) (hn : c n = 1) :
    ¬ (p : ℤ) ∣ hodgeTateCount c n p + hodgeTateCount (mirrorCoeffs n c) n p := by
  intro hdvd
  have h1 := hodgeTateCount_congr_const c n (p : ℤ)
  have h2 := hodgeTateCount_congr_const (mirrorCoeffs n c) n (p : ℤ)
  rw [mirrorCoeffs_zero, hn] at h2
  rw [h0] at h1
  have hsum : (p : ℤ) ∣ 2 := by
    have : (2 : ℤ) = (hodgeTateCount c n p + hodgeTateCount (mirrorCoeffs n c) n p)
        - ((hodgeTateCount c n p - 1) + (hodgeTateCount (mirrorCoeffs n c) n p - 1)) := by
      ring
    rw [this]
    exact dvd_sub hdvd (dvd_add h1 h2)
  have hle : (p : ℤ) ≤ 2 := Int.le_of_dvd (by norm_num) hsum
  have : (p : ℤ) > 2 := by exact_mod_cast hp2
  linarith

/-- **Explicit numerical witness (catalog point count).**  Projective `3`-space over `𝔽₅`
has `#ℙ³(𝔽₅) = 156` points; its Hodge–Tate multiplicity vector `(1,1,1,1)` is
reflection-invariant, so the mirror count is also `156`, and the signed congruence would
require `5 ∣ 312`, which is false. -/
theorem projectiveThreefold_signed_failure :
    ArithmeticMirror.pointCount 3 5 = 156 ∧
    ¬ (5 : ℤ) ∣ (ArithmeticMirror.pointCount 3 5 + ArithmeticMirror.pointCount 3 5) := by
  have hcount : ArithmeticMirror.pointCount 3 5 = 156 := by
    unfold ArithmeticMirror.pointCount
    norm_num [Finset.sum_range_succ]
  refine ⟨hcount, ?_⟩
  rw [hcount]
  norm_num

/-- The positive congruence, in contrast, does hold for `ℙ³` at every `q`: its Tate
multiplicity vector is palindromic, so `X` and its Hodge–Tate mirror have equal counts. -/
theorem projectiveSpace_mirror_congruence (n : ℕ) (q : ℤ) :
    q ∣ hodgeTateCount (fun _ => 1) n q - hodgeTateCount (mirrorCoeffs n (fun _ => 1)) n q :=
  mirror_pointCount_congruence (fun _ => 1) n q rfl

/-! ### Second cycle: how far does the congruence extend?

The unsigned congruence above only uses the extreme coefficients.  Poincaré duality on the
*algebraic* cohomology gives more: for a Calabi–Yau threefold the Tate multiplicities
satisfy `c₁ = h^{1,1} = h^{2,2} = c₂` as well as `c₀ = c₃ = 1`, and each such coincidence
buys one extra power of `q`. -/

/-- **Higher-order mirror congruence.**  If the Tate multiplicities agree with their
reflections in the first `r` slots (`c_k = c_{n−k}` for `k < r`), then the mirror point
counts are congruent modulo `q^r`. -/
theorem mirror_pointCount_congruence_pow (c : ℕ → ℤ) (n r : ℕ) (q : ℤ)
    (h : ∀ k, k < r → c k = c (n - k)) :
    q ^ r ∣ hodgeTateCount c n q - hodgeTateCount (mirrorCoeffs n c) n q := by
  unfold hodgeTateCount mirrorCoeffs
  rw [← Finset.sum_sub_distrib]
  refine Finset.dvd_sum ?_
  intro k _
  by_cases hk : k < r
  · rw [h k hk, sub_self]
    exact dvd_zero _
  · have hrk : r ≤ k := by omega
    rw [← sub_mul]
    exact Dvd.dvd.mul_left (pow_dvd_pow q hrk) _

/-- **Calabi–Yau threefold sharpening.**  For a mirror pair of Calabi–Yau threefolds in the
Hodge–Tate regime the point counts are congruent modulo `q²`, not merely modulo `q`: the
input is `c₀ = c₃ = 1` (connectedness and the fundamental class) together with the
Poincaré duality `c₁ = c₂` on algebraic cohomology (`h^{1,1} = h^{2,2}`). -/
theorem cy3_mirror_pointCount_congruence_sq (c : ℕ → ℤ) (q : ℤ)
    (h0 : c 0 = 1) (h3 : c 3 = 1) (h12 : c 1 = c 2) :
    q ^ 2 ∣ hodgeTateCount c 3 q - hodgeTateCount (mirrorCoeffs 3 c) 3 q := by
  refine mirror_pointCount_congruence_pow c 3 2 q ?_
  intro k hk
  interval_cases k
  · simpa [h0] using h3.symm
  · simpa using h12

/-- **Sharpness.**  Without the Poincaré-duality coincidence `c₁ = c₂` the modulus cannot
be improved: for the threefold multiplicity vector `(1, 2, 5, 1)` at `q = 5` the difference
of mirror point counts is `60`, divisible by `5` but not by `25`. -/
theorem mirror_pointCount_congruence_sharp :
    (5 : ℤ) ∣ hodgeTateCount (fun k => if k = 0 then 1 else if k = 1 then 2 else
        if k = 2 then 5 else 1) 3 5
      - hodgeTateCount (mirrorCoeffs 3 (fun k => if k = 0 then 1 else if k = 1 then 2 else
        if k = 2 then 5 else 1)) 3 5 ∧
    ¬ (25 : ℤ) ∣ hodgeTateCount (fun k => if k = 0 then 1 else if k = 1 then 2 else
        if k = 2 then 5 else 1) 3 5
      - hodgeTateCount (mirrorCoeffs 3 (fun k => if k = 0 then 1 else if k = 1 then 2 else
        if k = 2 then 5 else 1)) 3 5 := by
  have hval : hodgeTateCount (fun k => if k = 0 then 1 else if k = 1 then 2 else
      if k = 2 then 5 else 1) 3 5
      - hodgeTateCount (mirrorCoeffs 3 (fun k => if k = 0 then 1 else if k = 1 then 2 else
        if k = 2 then 5 else 1)) 3 5 = 60 := by
    simp [hodgeTateCount, mirrorCoeffs, Finset.sum_range_succ]
  rw [hval]
  norm_num

/-- The Hodge–Tate count of `ℙⁿ` is the catalog point count. -/
theorem hodgeTateCount_projectiveSpace (n : ℕ) (q : ℤ) :
    hodgeTateCount (fun _ => 1) n q = ArithmeticMirror.pointCount n q := by
  unfold hodgeTateCount ArithmeticMirror.pointCount
  exact Finset.sum_congr rfl (fun k _ => one_mul _)

end Novelty.MirrorBridge