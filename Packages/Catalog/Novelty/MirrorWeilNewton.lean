import Mathlib
import Novelty.MirrorWeilCoefficients

/-!
# Arithmetic Mirror Symmetry VII — Newton-polygon divisibility and the reciprocity sign

This file is cycle 3 of the research thread.  It closes two of the sub-conjectures spun off
by cycle 2 (`FUTURE_DIRECTIONS.md`, N1/N2, i.e. the divisibility half of Conjecture E and
all of Conjecture F for even degree), using only the coefficient-level functional equation
`middlePoly_graded_palindromy` proved in `Novelty.MirrorWeilCoefficients`.

The point of departure is that the graded palindromy
`q^{2m}·b_{d−i} = ε·q^{m+n i}·b_i` still contains a common factor.  Cancelling it (legitimate
in a domain) turns the identity into a *divisibility*, which is the arithmetic content of
the Hodge bound on the Newton polygon: the low coefficients of a Frobenius polynomial are
forced to be highly divisible by `q`.

## Main results

* `middlePoly_palindromy_low`, `middlePoly_palindromy_high` — the cancelled forms of the
  graded palindromy, stated with an explicit witness `j` for the difference of exponents so
  that no truncated `ℕ`-subtraction appears:
  `m = n·i + j ⟹ q^j·b_{d−i} = ε·b_i`, and `n·i = m + j ⟹ b_{d−i} = ε·q^j·b_i`.
* `middlePoly_hodge_divisibility` — **the Hodge bound**: if `n·i + j = m` then
  `q^j ∣ b_i`.  In particular `q^m ∣ b_0`, and for `q = p^a` the Newton polygon of the
  middle factor lies on or above the Hodge polygon.
* `middlePoly_hodge_divisibility_high` — the mirror statement `q^j ∣ b_{d−i}` when
  `n·i = m + j`.
* `middlePoly_sign_eq_one_of_even_degree` — **Conjecture F for even degree**: if `d = 2c`
  and the middle coefficient `b_c` is nonzero, then the sign is forced to be `+1`, i.e. the
  functional equation reads `q^{2m}·b_{d−i} = q^{m+n i}·b_i` with no sign at all.
* `middlePoly_sign_neg_one_witness` — and the hypothesis `b_c ≠ 0` is necessary: for the
  root pair `(1, −1)` (self-dual, `q = 1`, `n = 1`, `d = 2`, `m = 1`) the middle coefficient
  vanishes and the sign is forced to be `−1`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Cycle 2's palindromy is an equality between two monomial
  multiples of coefficients.  Since the two monomials `q^{2m}` and `q^{m+n i}` are
  comparable, one of them divides the other, so after cancellation the equation must read
  "a power of `q` times one coefficient equals (a sign times) the other" — which is a
  divisibility statement about the *smaller-index* coefficient.  Guess: `q^{m−n i} ∣ b_i`
  for `n i ≤ m`, i.e. exactly the Hodge/Mazur bound.
* **Experiment (Experimenter).**  The obstruction is `ℕ`-subtraction: `q^(m - n*i)` is
  wrong when `n*i > m`.  Carrying the difference as an explicit hypothesis `n*i + j = m`
  removes every truncation and makes both directions provable by a single
  `mul_left_cancel₀` on `q^(m + n*i)` resp. `q^(2*m)`.  The sign then cancels using
  `ε * ε = 1`, which is immediate from `ε = 1 ∨ ε = -1`.
* **Analysis (Analyst).**  Specializing to `i = c` when `d = 2c` gives
  `b_c = ε·b_c`, so `(1 − ε)·b_c = 0`: in a domain either `b_c = 0` or `ε = 1`.  This is
  the whole of Conjecture F in the even case, and it is *sharp*: the self-dual pair
  `(1, −1)` has `b_1 = 0` and genuinely forces `ε = −1`.  So the sign of the Weil functional
  equation is not an independent invariant — it is the vanishing/non-vanishing of a single
  middle coefficient.
* **Critique (Critic).**  Nothing here is definitional: `middlePoly_hodge_divisibility` is
  false without the duality hypothesis (take `d = 1`, `α = ![0]`), and the sign theorem is
  false without `b_c ≠ 0` (witnessed formally, in the same file, rather than asserted).  No
  `decide`, no `native_decide`; the witness is closed by `norm_num` on an explicitly
  computed polynomial.
* **Synthesis (PI).**  Poincaré duality ⟹ graded palindromy (cycle 2) ⟹ Hodge divisibility
  of the Frobenius coefficients and a *computable* reciprocity sign (cycle 3).  The chain
  from a permutation of eigenvalues to a `p`-adic lower bound on coefficients is now
  entirely formal and division-free.
-/

namespace Novelty.MirrorBridge

open Polynomial Finset

section Domain

variable {R : Type*} [CommRing R] [IsDomain R]

omit [IsDomain R] in
/-- A sign squares to one. -/
theorem sign_mul_self {ε : R} (hε : ε = 1 ∨ ε = -1) : ε * ε = 1 := by
  rcases hε with rfl | rfl <;> ring

/-- **Cancelled palindromy, low range.**  If `n·i + j = m` (so `i` is below the middle),
the graded palindromy of the middle factor cancels to `q^j · b_{d−i} = ε · b_i`. -/
theorem middlePoly_palindromy_low {d n m : ℕ} (hm : n * d = 2 * m) (q : R) (hq : q ≠ 0)
    (α : Fin d → R) (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n) :
    ∃ ε : R, (ε = 1 ∨ ε = -1) ∧ ∀ i ≤ d, ∀ j : ℕ, n * i + j = m →
      q ^ j * (middlePoly α).coeff (d - i) = ε * (middlePoly α).coeff i := by
  obtain ⟨ε, hε, h⟩ := middlePoly_graded_palindromy hm q α σ hdual
  refine ⟨ε, hε, fun i hi j hj => ?_⟩
  have hne : q ^ (m + n * i) ≠ 0 := pow_ne_zero _ hq
  refine mul_left_cancel₀ hne ?_
  have hkey := h i hi
  have hexp : 2 * m = (m + n * i) + j := by omega
  rw [hexp, pow_add] at hkey
  linear_combination hkey

/-- **Cancelled palindromy, high range.**  If `n·i = m + j` (so `i` is above the middle),
the graded palindromy cancels to `b_{d−i} = ε · q^j · b_i`. -/
theorem middlePoly_palindromy_high {d n m : ℕ} (hm : n * d = 2 * m) (q : R) (hq : q ≠ 0)
    (α : Fin d → R) (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n) :
    ∃ ε : R, (ε = 1 ∨ ε = -1) ∧ ∀ i ≤ d, ∀ j : ℕ, n * i = m + j →
      (middlePoly α).coeff (d - i) = ε * q ^ j * (middlePoly α).coeff i := by
  obtain ⟨ε, hε, h⟩ := middlePoly_graded_palindromy hm q α σ hdual
  refine ⟨ε, hε, fun i hi j hj => ?_⟩
  have hne : q ^ (2 * m) ≠ 0 := pow_ne_zero _ hq
  refine mul_left_cancel₀ hne ?_
  have hkey := h i hi
  have hexp : m + n * i = 2 * m + j := by omega
  rw [hexp, pow_add] at hkey
  linear_combination hkey

/-- **The Hodge bound on the Newton polygon of a Frobenius polynomial.**
For the middle factor of a Calabi–Yau `n`-fold over a domain, with Poincaré root duality
`α_i · α_{σ i} = q^n` and `n·d = 2m`, every coefficient below the middle is divisible by the
corresponding power of `q`:

`n·i + j = m  ⟹  q^j ∣ b_i`.

Taking `i = 0`, `j = m` gives `q^m ∣ b_0`; for `q = p^a` this says the Newton polygon of
`P` lies on or above the line joining `(0, a·m)` to `(d, 0)`. -/
theorem middlePoly_hodge_divisibility {d n m : ℕ} (hm : n * d = 2 * m) (q : R) (hq : q ≠ 0)
    (α : Fin d → R) (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n)
    (i : ℕ) (hi : i ≤ d) (j : ℕ) (hj : n * i + j = m) :
    q ^ j ∣ (middlePoly α).coeff i := by
  obtain ⟨ε, hε, h⟩ := middlePoly_palindromy_low hm q hq α σ hdual
  refine ⟨ε * (middlePoly α).coeff (d - i), ?_⟩
  have hk := h i hi j hj
  have hεε : ε * ε = 1 := sign_mul_self hε
  calc (middlePoly α).coeff i
      = 1 * (middlePoly α).coeff i := (one_mul _).symm
    _ = (ε * ε) * (middlePoly α).coeff i := by rw [hεε]
    _ = ε * (ε * (middlePoly α).coeff i) := by ring
    _ = ε * (q ^ j * (middlePoly α).coeff (d - i)) := by rw [hk]
    _ = q ^ j * (ε * (middlePoly α).coeff (d - i)) := by ring

/-- The mirror form of the Hodge bound: above the middle it is the *reflected* coefficient
that is forced to be divisible. -/
theorem middlePoly_hodge_divisibility_high {d n m : ℕ} (hm : n * d = 2 * m) (q : R)
    (hq : q ≠ 0) (α : Fin d → R) (σ : Equiv.Perm (Fin d))
    (hdual : ∀ i, α i * α (σ i) = q ^ n)
    (i : ℕ) (hi : i ≤ d) (j : ℕ) (hj : n * i = m + j) :
    q ^ j ∣ (middlePoly α).coeff (d - i) := by
  obtain ⟨ε, hε, h⟩ := middlePoly_palindromy_high hm q hq α σ hdual
  exact ⟨ε * (middlePoly α).coeff i, by rw [h i hi j hj]; ring⟩

/-- **Conjecture F in even degree: the reciprocity sign is `+1`, not a free invariant.**

If the middle factor has even degree `d = 2c` and its middle coefficient `b_c` is nonzero,
then the graded palindromy holds *with no sign*:
`q^{2m} · b_{d−i} = q^{m+n i} · b_i` for all `i ≤ d`.

The proof is the specialization `i = c` of the cancelled palindromy, which reads
`b_c = ε · b_c`, forcing `ε = 1` in a domain. -/
theorem middlePoly_sign_eq_one_of_even_degree {c n m : ℕ} (hm : n * (2 * c) = 2 * m) (q : R)
    (hq : q ≠ 0) (α : Fin (2 * c) → R) (σ : Equiv.Perm (Fin (2 * c)))
    (hdual : ∀ i, α i * α (σ i) = q ^ n) (hmid : (middlePoly α).coeff c ≠ 0) :
    ∀ i ≤ 2 * c, q ^ (2 * m) * (middlePoly α).coeff (2 * c - i)
      = q ^ (m + n * i) * (middlePoly α).coeff i := by
  obtain ⟨ε, hε, hfull⟩ := middlePoly_graded_palindromy hm q α σ hdual
  have h0 : 2 * (n * c) = 2 * m := by rw [← hm]; ring
  have hmc : m = n * c := (Nat.eq_of_mul_eq_mul_left (by norm_num) h0).symm
  have hexp : 2 * m = m + n * c := by rw [hmc]; ring
  have hsign : ε = 1 := by
    have h1 := hfull c (by omega)
    rw [show 2 * c - c = c by omega, hexp] at h1
    have hne : q ^ (m + n * c) ≠ 0 := pow_ne_zero _ hq
    have h2 : q ^ (m + n * c) * ((1 - ε) * (middlePoly α).coeff c) = 0 := by
      linear_combination h1
    rcases mul_eq_zero.mp h2 with h | h
    · exact absurd h hne
    · rcases mul_eq_zero.mp h with h' | h'
      · exact (sub_eq_zero.mp h').symm
      · exact absurd h' hmid
  intro i hi
  have hres := hfull i hi
  rw [hsign, one_mul] at hres
  exact hres

end Domain

section Witness

/-- **The nonvanishing hypothesis in `middlePoly_sign_eq_one_of_even_degree` is necessary.**

Take `q = 1`, `n = 1`, `d = 2`, `m = 1` and the self-dual reciprocal root pair `(1, −1)`
(duality realized by the identity permutation: `1·1 = 1` and `(−1)·(−1) = 1`).  The middle
factor is `X² − 1`, whose middle coefficient `b₁` vanishes, and the graded palindromy then
forces the sign `ε = −1`.  So an even-degree Frobenius polynomial really can have
reciprocity sign `−1`, exactly when its middle coefficient dies. -/
theorem middlePoly_sign_neg_one_witness :
    (∀ i, (![(1 : ℚ), -1] : Fin 2 → ℚ) i * (![(1 : ℚ), -1] : Fin 2 → ℚ) (Equiv.refl (Fin 2) i)
        = (1 : ℚ) ^ 1)
      ∧ (middlePoly ![(1 : ℚ), -1]).coeff 1 = 0
      ∧ ∀ ε : ℚ, (∀ i ≤ 2, (1 : ℚ) ^ (2 * 1) * (middlePoly ![(1 : ℚ), -1]).coeff (2 - i)
            = ε * (1 : ℚ) ^ (1 + 1 * i) * (middlePoly ![(1 : ℚ), -1]).coeff i) → ε = -1 := by
  refine ⟨fun i => ?_, ?_, fun ε h => ?_⟩
  · fin_cases i <;> norm_num
  · simp
  · have h0 := h 0 (by norm_num)
    norm_num at h0
    linarith

/-- The same data satisfies the Hodge bound vacuously at the extremes and nontrivially at
`i = 0`: with `q = 2`, roots `(2, 4)` and `n = m = 3`, one gets `2³ ∣ b₀ = 8`. -/
theorem cy_threefold_hodge_divisibility :
    (2 : ℤ) ^ 3 ∣ (middlePoly ![(2 : ℤ), 4]).coeff 0 := by
  refine middlePoly_hodge_divisibility (d := 2) (n := 3) (m := 3) (by norm_num) 2 (by norm_num)
    ![(2 : ℤ), 4] (Equiv.swap 0 1) (rootDuality_two 2 2 4 (by norm_num)) 0 (by norm_num) 3
    (by norm_num)

end Witness

end Novelty.MirrorBridge