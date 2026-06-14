/-
  Arithmetic Mirror Symmetry: a self-contained combinatorial skeleton.

  This file formalizes a rigorous, ring-valued skeleton of mirror symmetry:

    * the Hodge-diamond mirror reflection `p ↦ n - p` and its companion
      reflections (second-index reflection and transpose),
    * the resulting Euler-characteristic relation `χ(mirror Y) = (-1)^n χ(X)`,
      specializing to `χ = -χ` for threefolds,
    * the reflection-group structure of the diamond: the three reflections all
      act on `χ` by `±1`, so `χ` is an invariant of the symmetry group up to sign,
    * the Weil functional equation for the zeta function of projective space,
      proved as a polynomial identity over an *arbitrary* commutative ring,
    * a cross-domain bridge: for `Pⁿ` the `𝔽_q`-point count is congruent to the
      topological Euler characteristic `n+1` modulo `q - 1`.

  Everything is stated over a general `CommRing R` (the codomain of the Hodge
  numbers / coefficients), which immediately subsumes the integer-valued
  ordinary theory and the rational-valued "stringy" theory.
-/
import Mathlib

open Finset

namespace ArithmeticMirror

/-! ### Hodge diamonds and the Euler characteristic -/

variable {R : Type*} [CommRing R]

/-- The Euler characteristic of a Hodge diamond `h : (p,q) ↦ h^{p,q}` of a
complex `n`-dimensional variety, as the alternating double sum. -/
def eulerChar (n : ℕ) (h : ℕ → ℕ → R) : R :=
  ∑ p ∈ Finset.range (n+1), ∑ q ∈ Finset.range (n+1), (-1)^(p+q) * h p q

/-- The mirror diamond reflects the first Hodge index `p ↦ n - p`. -/
def mirror (n : ℕ) (h : ℕ → ℕ → R) : ℕ → ℕ → R := fun p q => h (n - p) q

/-- The second-index reflection `q ↦ n - q`. -/
def mirror2 (n : ℕ) (h : ℕ → ℕ → R) : ℕ → ℕ → R := fun p q => h p (n - q)

/-- The transpose (complex-conjugation) reflection `h^{p,q} ↦ h^{q,p}`. -/
def transpose (h : ℕ → ℕ → R) : ℕ → ℕ → R := fun p q => h q p

-- !-- Lab Notebook -- !--
-- Hypothesis: the mirror reflection `p ↦ n-p` should rescale χ by exactly (-1)^n.
-- Result: proved (`eulerChar_mirror`).  Insight: the whole content is
-- `Finset.sum_range_reflect` plus the elementary sign identity
-- (-1)^(n-p) = (-1)^n (-1)^p valid for p ≤ n; no positivity or field structure
-- is needed, so the statement holds over any CommRing.
-- Failure analysis: a first attempt factored the sign in the wrong order and the
-- `rw` could not find `(-1)^p * (-1)^p`; isolating the helper `hsub` fixed it.

-- !-- comment -- !--
-- Reflecting the first Hodge index multiplies the Euler characteristic by (-1)^n:
-- reindex the outer sum by `p ↦ n-p` and use (-1)^(n-p) = (-1)^n (-1)^p.
-- !-- comment -- !--
/-- **Mirror Euler relation.** Reflecting the first Hodge index multiplies the
Euler characteristic by `(-1)^n`. -/
theorem eulerChar_mirror (n : ℕ) (h : ℕ → ℕ → R) :
    eulerChar n (mirror n h) = (-1)^n * eulerChar n h := by
  unfold eulerChar mirror
  rw [Finset.mul_sum]
  rw [← Finset.sum_range_reflect
        (fun p => ∑ q ∈ Finset.range (n+1), (-1)^(p+q) * h (n-p) q) (n+1)]
  apply Finset.sum_congr rfl
  intro p hp
  simp only [Finset.mem_range] at hp
  have hpn : p ≤ n := by omega
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro q _
  have e1 : n + 1 - 1 - p = n - p := by omega
  rw [e1]
  have e2 : n - (n - p) = p := by omega
  rw [e2]
  have hsub : (-1:R)^(n-p) = (-1)^n * (-1)^p := by
    have hkey : (-1:R)^(n-p) * (-1)^p = (-1)^n := by
      rw [← pow_add, Nat.sub_add_cancel hpn]
    have hu : ((-1:R)^p) * ((-1:R)^p) = 1 := by
      rw [← pow_add, ← two_mul, pow_mul]; norm_num
    calc (-1:R)^(n-p) = (-1)^(n-p) * ((-1)^p * (-1)^p) := by rw [hu, mul_one]
      _ = ((-1)^(n-p) * (-1)^p) * (-1)^p := by ring
      _ = (-1)^n * (-1)^p := by rw [hkey]
  have sgn : (-1:R)^((n-p)+q) = (-1)^n * (-1)^(p+q) := by
    rw [pow_add, hsub, pow_add]; ring
  rw [sgn]; ring

-- !-- comment -- !--
-- Same argument on the inner (q) sum: reflecting the second index also scales χ
-- by (-1)^n.
-- !-- comment -- !--
/-- The second-index reflection multiplies the Euler characteristic by `(-1)^n`. -/
theorem eulerChar_mirror2 (n : ℕ) (h : ℕ → ℕ → R) :
    eulerChar n (mirror2 n h) = (-1)^n * eulerChar n h := by
  unfold eulerChar mirror2
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro p _
  rw [Finset.mul_sum]
  rw [← Finset.sum_range_reflect (fun q => (-1)^(p+q) * h p (n-q)) (n+1)]
  apply Finset.sum_congr rfl
  intro q hq
  simp only [Finset.mem_range] at hq
  have hqn : q ≤ n := by omega
  have e1 : n + 1 - 1 - q = n - q := by omega
  rw [e1]
  have e2 : n - (n - q) = q := by omega
  rw [e2]
  have hsub : (-1:R)^(n-q) = (-1)^n * (-1)^q := by
    have hkey : (-1:R)^(n-q) * (-1)^q = (-1)^n := by
      rw [← pow_add, Nat.sub_add_cancel hqn]
    have hu : ((-1:R)^q) * ((-1:R)^q) = 1 := by
      rw [← pow_add, ← two_mul, pow_mul]; norm_num
    calc (-1:R)^(n-q) = (-1)^(n-q) * ((-1)^q * (-1)^q) := by rw [hu, mul_one]
      _ = ((-1)^(n-q) * (-1)^q) * (-1)^q := by ring
      _ = (-1)^n * (-1)^q := by rw [hkey]
  have sgn : (-1:R)^(p+(n-q)) = (-1)^n * (-1)^(p+q) := by
    rw [pow_add, pow_add, hsub]; ring
  rw [sgn]; ring

-- !-- comment -- !--
-- The transpose merely swaps the two summation indices in an expression whose
-- sign `(-1)^(p+q)` is already symmetric, so χ is unchanged (no hypotheses).
-- !-- comment -- !--
/-- **Transpose invariance.** The Euler characteristic is invariant under the
Hodge transpose `h^{p,q} ↦ h^{q,p}`; unlike the mirror this needs no symmetry
hypothesis on `h`. -/
theorem eulerChar_transpose (n : ℕ) (h : ℕ → ℕ → R) :
    eulerChar n (transpose h) = eulerChar n h := by
  unfold eulerChar transpose
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl; intro p _
  apply Finset.sum_congr rfl; intro q _
  rw [Nat.add_comm]

-- !-- comment -- !--
-- Composing both index reflections multiplies χ by (-1)^n twice, i.e. by 1:
-- the diamond's reflection group acts on χ through the sign character.
-- !-- comment -- !--
/-- **Double reflection is trivial on `χ`.** Reflecting both Hodge indices fixes
the Euler characteristic, since `(-1)^n · (-1)^n = 1`. This exhibits `χ` as an
invariant of the reflection group generated by the two mirror reflections. -/
theorem eulerChar_double_reflection (n : ℕ) (h : ℕ → ℕ → R) :
    eulerChar n (mirror n (mirror2 n h)) = eulerChar n h := by
  rw [eulerChar_mirror, eulerChar_mirror2, ← mul_assoc, ← pow_add, ← two_mul, pow_mul]
  norm_num

-- !-- comment -- !--
-- Specialize `eulerChar_mirror` at n = 3 where (-1)^3 = -1.
-- !-- comment -- !--
/-- **Threefold mirror relation.** For a Calabi–Yau threefold the mirror has
opposite Euler characteristic. -/
theorem eulerChar_mirror_threefold (h : ℕ → ℕ → R) :
    eulerChar 3 (mirror 3 h) = - eulerChar 3 h := by
  rw [eulerChar_mirror]; norm_num

-- !-- comment -- !--
-- The h^{1,1} ↔ h^{2,1} exchange (rational curves ↔ Picard rank) is literally
-- `mirror 3 h 1 1 = h 2 1` by unfolding the reflection p ↦ 3 - p.
-- !-- comment -- !--
omit [CommRing R] in
/-- **Hodge-number exchange.** On a threefold the mirror swaps `h^{1,1}` and
`h^{2,1}` — the combinatorial shadow of "rational curves on `X` ↔ rank of
`Pic(Y)`". -/
theorem mirror_swaps_hodge_threefold (h : ℕ → ℕ → R) :
    mirror 3 h 1 1 = h 2 1 := rfl

/-! ### The arithmetic side: the Weil functional equation for `Pⁿ` -/

-- !-- Lab Notebook -- !--
-- Hypothesis: the multiset of Frobenius reciprocal roots {q^0,…,q^n} of P^n is
-- self-dual under α ↦ q^n/α, yielding the Weil functional equation.
-- Result: proved as the division-free polynomial identity
--   ∏ (q^{n-i} T - 1) = (-1)^{n+1} ∏ (1 - q^i T)   (`projectiveSpace_zeta_functional_equation`).
-- Insight: clearing the denominators of Z(1/(q^n T)) = (-1)^{n+1} q^{n(n+1)/2} T^{n+1} Z(T)
-- collapses to `Finset.prod_range_reflect` (the reciprocal roots q^i ↦ q^{n-i})
-- followed by pulling out a factor (-1) from each of the n+1 factors.
-- Failure analysis: the guessed lemma `prod_neg_eq_neg_one_pow_card_mul_prod`
-- does not exist; `Finset.prod_mul_distrib` + `Finset.prod_const` is the route.

-- !-- comment -- !--
-- Reindex i ↦ n-i (self-duality of the reciprocal roots q^i ↦ q^{n-i}), then
-- factor (-1) out of each of the n+1 factors q^i T - 1.
-- !-- comment -- !--
/-- **Weil functional equation for `Pⁿ`.** The "zeta denominator"
`P(T) = ∏_{i=0}^{n} (1 - qⁱ T)` (whose reciprocal is the zeta function of `ℙⁿ`)
obeys the functional equation in division-free form: reflecting `T` through the
self-dual reciprocal-root multiset reverses the factors with a global sign
`(-1)^{n+1}`. Valid over any commutative ring. -/
theorem projectiveSpace_zeta_functional_equation (n : ℕ) (q T : R) :
    ∏ i ∈ Finset.range (n+1), (q^(n-i) * T - 1)
      = (-1)^(n+1) * ∏ i ∈ Finset.range (n+1), (1 - q^i * T) := by
  rw [← Finset.prod_range_reflect (fun i => q^(n-i) * T - 1) (n+1)]
  have hc : ∀ j ∈ Finset.range (n+1),
      q^(n-(n+1-1-j)) * T - 1 = (-1) * (1 - q^j * T) := by
    intro j hj
    simp only [Finset.mem_range] at hj
    have : n - (n+1-1-j) = j := by omega
    rw [this]; ring
  rw [Finset.prod_congr rfl hc, Finset.prod_mul_distrib, Finset.prod_const,
    Finset.card_range]

-- !-- comment -- !--
-- (-1)^{n+1} = -(-1)^n by `pow_succ`: the FE sign and the Euler sign differ by
-- exactly one factor of (-1).
-- !-- comment -- !--
/-- **Sign bridge (arithmetic ↔ Hodge).** The sign `(-1)^{n+1}` of the Weil
functional equation and the sign `(-1)^n` of the mirror Euler relation are the
same datum up to one sign: `(-1)^{n+1} = -(-1)^n`. In particular for threefolds
the functional-equation sign is `+1` (compatible with weight-`4` modularity)
while the Euler sign is `-1`. -/
theorem functional_equation_sign_vs_euler_sign (n : ℕ) :
    (-1:R)^(n+1) = -((-1)^n) := by
  rw [pow_succ]; ring

/-! ### Cross-domain bridge: point counts modulo `q - 1` -/

/-- The number of `𝔽_q`-points of `ℙⁿ`, as the geometric sum `∑_{i=0}^{n} qⁱ`. -/
def pointCount (n : ℕ) (q : ℤ) : ℤ := ∑ i ∈ Finset.range (n+1), q^i

/-- The integer Hodge diamond of `ℙⁿ`: `h^{p,q} = 1` on the diagonal `p = q ≤ n`
and `0` elsewhere. -/
def projHodge (n : ℕ) : ℕ → ℕ → ℤ := fun p q => if p = q ∧ p ≤ n then 1 else 0

-- !-- Lab Notebook -- !--
-- Hypothesis: #P^n(F_q) ≡ χ_top(P^n) (mod q-1), the point count remembering the
-- topological Euler characteristic n+1.
-- Result: proved `pointCount_congr_eulerChar` via `projHodge_eulerChar`
-- (χ(P^n) = n+1) and `Finset.dvd_sum` with `sub_dvd_pow_sub_pow` (q-1 | q^i-1).
-- Insight: this is a genuine cross-domain identity — the *arithmetic* point
-- count and the *Hodge-theoretic* Euler characteristic agree mod q-1, bridging
-- the two faces of mirror symmetry through the already-proven Euler machinery.

-- !-- comment -- !--
-- Only the diagonal q = p survives the inner sum (sign (-1)^{2p}=1 there), and
-- there are exactly n+1 diagonal entries.
-- !-- comment -- !--
/-- **Euler characteristic of `Pⁿ`.** `χ(ℙⁿ) = n + 1`. -/
theorem projHodge_eulerChar (n : ℕ) :
    eulerChar n (projHodge n) = (n : ℤ) + 1 := by
  unfold eulerChar projHodge
  have hinner : ∀ p ∈ Finset.range (n+1),
      (∑ q ∈ Finset.range (n+1), (-1)^(p+q) * (if p = q ∧ p ≤ n then (1:ℤ) else 0)) = 1 := by
    intro p hp
    simp only [Finset.mem_range] at hp
    rw [Finset.sum_eq_single p]
    · have hpn : p ≤ n := by omega
      simp [hpn, ← two_mul, pow_mul]
    · intro b _ hbp
      have hno : ¬ (p = b ∧ p ≤ n) := by rintro ⟨rfl, _⟩; exact hbp rfl
      simp [hno]
    · intro hpr; exact absurd (Finset.mem_range.mpr (by omega)) hpr
  rw [Finset.sum_congr rfl hinner, Finset.sum_const, Finset.card_range]
  simp

-- !-- comment -- !--
-- ∑ q^i - (n+1) = ∑ (q^i - 1), and q-1 ∣ q^i - 1 for every i (`sub_dvd_pow_sub_pow`).
-- !-- comment -- !--
/-- **Point count ≡ Euler characteristic (mod `q-1`).** The `𝔽_q`-point count of
`ℙⁿ` is congruent to its topological Euler characteristic `n+1 = χ(ℙⁿ)` modulo
`q - 1`. This is the toy Wan-type congruence: arithmetic point counts remember
the Hodge-theoretic Euler number. -/
theorem pointCount_congr_eulerChar (n : ℕ) (q : ℤ) :
    (q - 1) ∣ (pointCount n q - eulerChar n (projHodge n)) := by
  rw [projHodge_eulerChar]
  unfold pointCount
  have hsum : (∑ i ∈ Finset.range (n+1), q^i) - ((n:ℤ)+1)
      = ∑ i ∈ Finset.range (n+1), (q^i - 1) := by
    rw [Finset.sum_sub_distrib]; simp [Finset.sum_const, Finset.card_range]
  rw [hsum]
  apply Finset.dvd_sum
  intro i _
  have := sub_dvd_pow_sub_pow q 1 i
  simpa using this

end ArithmeticMirror