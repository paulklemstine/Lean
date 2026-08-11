import Novelty.DiophantineLatticeWeightEnumerator

/-!
# Cycle 10: strictness of the packing–covering inequality in rank two

This file closes **sub-conjecture C1** of the previous cycle's future directions: for *every*
positive-definite rational quadratic form `Q` on the lattice `L = ℤ²` the covering radius²
`μ(Q)` is **strictly** larger than a quarter of the minimal lattice energy,

  `μ(Q) > λ₁(Q)/4`,

whereas in rank one `μ = λ₁/4` (cycle 6, `deepHole_one_isInhomMin`).  Together with
`covering_ge_quarter_min` this pins down the equality case of the packing–covering inequality
in the first open rank.

## Strategy

Everything is done in the coordinates of the binary form: a matrix `B` on `Fin 2` has
`form B x = a x₀² + b x₀x₁ + c x₁²` with `a = B 0 0`, `b = B 0 1 + B 1 0`, `c = B 1 1`
(`form_eq_bq`), so the whole theory is elementary algebra in the triple `(a, b, c)`, and a
change of lattice basis is the polynomial identity `bq_change`.

* `bq_int_ge` : for a *reduced* triple (`0 < a`, `|b| ≤ a ≤ c`) the minimum of the form over
  nonzero integer points is `a`; hence `reduced_isMinEnergy`.
* `reduced_half_lower` : at the `2`-torsion shift `(½, ½)` the form is at least
  `(a + c − |b|)/4`.  This certifies strictness whenever `|b| < c`.
* `hex_int_ge_three` : if `X ≡ Y ≡ 1 (mod 3)` then `X² + XY + Y² ≥ 3`.  This certifies
  strictness in the *remaining* case `|b| = c`, which forces `a = c = |b|`, i.e. the
  hexagonal form `a(x² ± xy + y²)`, where the certificate has to be the `3`-torsion shift
  `(⅓, ±⅓)` — no `2`-torsion shift works (`hexagonal_two_torsion_never_deepest`).
* `reduced_certificate` : combines the two cases into a single shift `t` with
  `Q(t − m) > a/4` for *all* lattice points `m`.
* `strict_certificate_of_min` : removes the reducedness hypothesis by an explicit reduction —
  a shortest vector is primitive (`primitive_of_min`), a Bézout complement turns it into the
  first basis vector, and one shear `w ↦ w + k v` with `k = round(−b/2a)` makes `|b| ≤ a`.
* `rank_two_covering_strict` : the theorem, in the vocabulary of the catalogue.

## Lab notes

*Hypothesizer.*  Conjecture C of cycle 9 predicts `μ > λ₁/4` for every rank `≥ 2` lattice, the
`2`-torsion certificate `(½,…,½)` being available only for diagonal forms.  In rank two the
prediction becomes a finite algebraic dichotomy.

*Experimenter.*  Exact rational enumeration over the reduced forms
`(a,b,c) ∈ {(1,0,1),(1,1,1),(2,1,3),(1,0,5),(3,2,7),(5,4,9),(2,2,3),(1,1,2),(3,3,3),(1,-1,1)}`
gives `μ((½,½)) = (a − |b| + c)/4` in every single case, and the covering radius² strictly
exceeds `λ₁/4` in every case; see `ComputationalEvidence.md`.  The two hexagonal entries
`(1,1,1)` and `(3,3,3)` are exactly the ones where the `2`-torsion value `(a−|b|+c)/4` collapses
to `λ₁/4`, and there the maximum is attained at `(⅓,⅓)`.

*Analyst.*  The dichotomy is *not* an artefact: `|b| = c` together with `|b| ≤ a ≤ c` forces
`a = c = |b|`, so the failure locus of the `2`-torsion certificate is exactly the hexagonal
form, one point in the reduction domain.  The mechanism behind `μ((½,½)) ≥ (a+c−|b|)/4` is that
the four sign patterns of an odd pair `(X,Y)` realise `a ± b + c`, and the minimum of these is
`a − |b| + c`; the mechanism behind the hexagonal bound is a congruence: `X ≡ Y ≡ 1 (mod 3)`
forces `3 ∣ X² + XY + Y²`, and positivity upgrades this to `≥ 3`.

*Critic.*  Two possible weaknesses were checked.  (i) The reduction step needs the shortest
vector to be *primitive*; this is `primitive_of_min` and uses only minimality, not positivity of
the whole form.  (ii) The certificate must be a bound valid for **every** lattice point, not just
the nearby ones; both `reduced_half_lower` and the hexagonal bound are proved for arbitrary
integers `p, q`, so no truncation of the lattice is involved.  Finally
`hexagonal_two_torsion_never_deepest` shows the theorem genuinely needs the `3`-torsion branch:
for the hexagonal lattice all three nonzero classes of `L/2L` contain a shortest vector, so every
`2`-torsion shift has gap exactly `λ₁/4`.

*PI.*  Rank two of Conjecture C is closed, and the obstruction is identified: the `2`-torsion
part of the gap spectrum certifies strictness for every binary form except the hexagonal one,
which is certified by `3`-torsion.
-/

namespace DiophantineLattice
namespace RankTwo

open Finset

/-! ## Binary forms in coordinates -/

/-- The value `a x² + b x y + c y²` of a binary quadratic form. -/
def bq (a b c x y : ℚ) : ℚ := a * x ^ 2 + b * x * y + c * y ^ 2

/-- The middle coefficient of the form in the basis `(v, w)`. -/
def crossCoeff (a b c v0 v1 w0 w1 : ℚ) : ℚ :=
  2 * a * v0 * w0 + b * (v0 * w1 + v1 * w0) + 2 * c * v1 * w1

/-- Every quadratic form on `Fin 2` is a binary quadratic form in the above sense. -/
lemma form_eq_bq (B : Matrix (Fin 2) (Fin 2) ℚ) (x : Fin 2 → ℚ) :
    form B x = bq (B 0 0) (B 0 1 + B 1 0) (B 1 1) (x 0) (x 1) := by
  simp only [form, bil, Fin.sum_univ_two, bq]
  ring

/-- **Change of basis.**  Reading the form in the basis `(v, w)` replaces the coefficient triple
`(a, b, c)` by `(Q v, ⟨v, w⟩, Q w)`. -/
lemma bq_change (a b c v0 v1 w0 w1 x y : ℚ) :
    bq a b c (v0 * x + w0 * y) (v1 * x + w1 * y)
      = bq (bq a b c v0 v1) (crossCoeff a b c v0 v1 w0 w1) (bq a b c w0 w1) x y := by
  unfold bq crossCoeff
  ring

/-- A shear `w ↦ w + k v` changes the middle coefficient by `2k Q(v)`. -/
lemma crossCoeff_shear (a b c v0 v1 w0 w1 k : ℚ) :
    crossCoeff a b c v0 v1 (w0 + k * v0) (w1 + k * v1)
      = crossCoeff a b c v0 v1 w0 w1 + 2 * k * bq a b c v0 v1 := by
  unfold crossCoeff bq
  ring

lemma bq_smul (a b c d x y : ℚ) : bq a b c (d * x) (d * y) = d ^ 2 * bq a b c x y := by
  unfold bq; ring

/-! ## Elementary integer inequalities -/

lemma int_sq_ge_one {p : ℤ} (hp : p ≠ 0) : 1 ≤ p ^ 2 := by
  nlinarith [Int.one_le_abs hp, sq_abs p]

lemma int_two_var_ge_one {p q : ℤ} (hq : q ≠ 0) : 1 ≤ p ^ 2 - |p * q| + q ^ 2 := by
  have h2 : |p * q| = |p| * |q| := abs_mul p q
  have h3 : |p| ^ 2 = p ^ 2 := sq_abs p
  have h4 : |q| ^ 2 = q ^ 2 := sq_abs q
  have h5 : 1 ≤ |q| := Int.one_le_abs hq
  rcases eq_or_ne p 0 with hp | hp
  · subst hp; simp only [abs_zero, zero_mul] at *; nlinarith
  · have h6 : 1 ≤ |p| := Int.one_le_abs hp
    nlinarith [sq_nonneg (|p| - |q|)]

/-- If `X ≡ Y ≡ 1 (mod 3)` then the hexagonal form `X² + XY + Y²` is at least `3`: it is a
positive multiple of `3`. -/
lemma hex_int_ge_three {X Y : ℤ} (hX : X % 3 = 1) (hY : Y % 3 = 1) :
    3 ≤ X ^ 2 + X * Y + Y ^ 2 := by
  obtain ⟨k, hk⟩ : ∃ k : ℤ, X = 3 * k + 1 := ⟨X / 3, by omega⟩
  obtain ⟨l, hl⟩ : ∃ l : ℤ, Y = 3 * l + 1 := ⟨Y / 3, by omega⟩
  subst hk; subst hl
  have key : 0 ≤ k ^ 2 + k * l + l ^ 2 + k + l := by
    rcases eq_or_ne (k + l + 1) 0 with h | h
    · have hkl : k ≠ 0 ∨ l ≠ 0 := by omega
      have h1 : 1 ≤ k ^ 2 + l ^ 2 := by
        rcases hkl with h1 | h1
        · nlinarith [Int.one_le_abs h1, sq_abs k, sq_nonneg l]
        · nlinarith [Int.one_le_abs h1, sq_abs l, sq_nonneg k]
      nlinarith [sq_nonneg (k - l)]
    · have h1 : 1 ≤ (k + l + 1) ^ 2 := by nlinarith [Int.one_le_abs h, sq_abs (k + l + 1)]
      nlinarith [sq_nonneg (k - l)]
  nlinarith

/-! ## Reduced triples -/

/-- The classical reduction domain for a positive-definite binary form. -/
def IsReduced (a b c : ℚ) : Prop := 0 < a ∧ |b| ≤ a ∧ a ≤ c

/-- **The homogeneous minimum of a reduced form is its leading coefficient.** -/
lemma bq_int_ge {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) {p q : ℤ}
    (h : ¬(p = 0 ∧ q = 0)) : a ≤ bq a b c (p : ℚ) (q : ℚ) := by
  unfold bq
  rcases eq_or_ne q 0 with hq | hq
  · subst hq
    have hp : p ≠ 0 := by tauto
    have hp2 : (1 : ℚ) ≤ (p : ℚ) ^ 2 := by exact_mod_cast int_sq_ge_one hp
    push_cast
    nlinarith
  · have key : (1 : ℤ) ≤ p ^ 2 - |p * q| + q ^ 2 := int_two_var_ge_one hq
    have keyQ : (1 : ℚ) ≤ (p : ℚ) ^ 2 - |(p : ℚ) * q| + (q : ℚ) ^ 2 := by
      have h' : ((1 : ℤ) : ℚ) ≤ ((p ^ 2 - |p * q| + q ^ 2 : ℤ) : ℚ) := Int.cast_le.2 key
      push_cast at h'
      exact h'
    have hbmul : b * ((p : ℚ) * q) ≥ -(a * |(p : ℚ) * q|) := by
      have h1 : |b * ((p : ℚ) * q)| ≤ a * |(p : ℚ) * q| := by
        rw [abs_mul]
        exact mul_le_mul_of_nonneg_right hb (abs_nonneg _)
      linarith [neg_abs_le (b * ((p : ℚ) * q))]
    have hq2 : (1 : ℚ) ≤ (q : ℚ) ^ 2 := by exact_mod_cast int_sq_ge_one hq
    nlinarith [sq_nonneg ((p : ℚ)), abs_nonneg ((p : ℚ) * q)]

/-- **The `2`-torsion certificate.**  At the shift `(½, ½)` a reduced form is at least
`(a + c − |b|)/4` — the minimum over the four sign patterns of an odd pair. -/
lemma reduced_half_lower {a b c : ℚ} (hb : |b| ≤ a) (hc : a ≤ c) (p q : ℤ) :
    a + c - |b| ≤ 4 * bq a b c (1 / 2 - (p : ℚ)) (1 / 2 - (q : ℚ)) := by
  have hbc : |b| ≤ c := le_trans hb hc
  have hb0 : (0 : ℚ) ≤ |b| := abs_nonneg b
  set X : ℚ := 1 - 2 * (p : ℚ) with hX
  set Y : ℚ := 1 - 2 * (q : ℚ) with hY
  have hu : (1 : ℚ) ≤ |X| := by
    have h1 : ((1 : ℤ) : ℚ) ≤ ((|1 - 2 * p| : ℤ) : ℚ) := by
      exact_mod_cast Int.one_le_abs (by omega : (1 - 2 * p : ℤ) ≠ 0)
    calc (1 : ℚ) ≤ ((|1 - 2 * p| : ℤ) : ℚ) := h1
      _ = |X| := by rw [hX]; push_cast [Int.cast_abs]; ring_nf
  have hv : (1 : ℚ) ≤ |Y| := by
    have h1 : ((1 : ℤ) : ℚ) ≤ ((|1 - 2 * q| : ℤ) : ℚ) := by
      exact_mod_cast Int.one_le_abs (by omega : (1 - 2 * q : ℤ) ≠ 0)
    calc (1 : ℚ) ≤ ((|1 - 2 * q| : ℤ) : ℚ) := h1
      _ = |Y| := by rw [hY]; push_cast [Int.cast_abs]; ring_nf
  have hval : 4 * bq a b c (1 / 2 - (p : ℚ)) (1 / 2 - (q : ℚ)) = a * X ^ 2 + b * X * Y + c * Y ^ 2 := by
    unfold bq; rw [hX, hY]; ring
  rw [hval]
  have hsq1 : X ^ 2 = |X| ^ 2 := (sq_abs X).symm
  have hsq2 : Y ^ 2 = |Y| ^ 2 := (sq_abs Y).symm
  have hcross : b * X * Y ≥ -(|b| * (|X| * |Y|)) := by
    have h1 : |b * X * Y| ≤ |b| * (|X| * |Y|) := by
      rw [abs_mul, abs_mul]
      exact le_of_eq (by ring)
    linarith [neg_abs_le (b * X * Y)]
  rw [hsq1, hsq2]
  nlinarith [mul_nonneg (sub_nonneg.2 hb) (sub_nonneg.2 (by nlinarith : (1 : ℚ) ≤ |X| ^ 2)),
    mul_nonneg (sub_nonneg.2 hbc) (sub_nonneg.2 (by nlinarith : (1 : ℚ) ≤ |Y| ^ 2)),
    mul_nonneg hb0 (sq_nonneg (|X| - |Y|)),
    mul_nonneg hb0 (sub_nonneg.2 (by nlinarith : (1 : ℚ) ≤ |X| * |Y|))]

/-- **The `3`-torsion certificate**, positive hexagonal form. -/
lemma hex_third_lower (a : ℚ) (ha : 0 < a) (p q : ℤ) :
    a / 3 ≤ bq a a a (1 / 3 - (p : ℚ)) (1 / 3 - (q : ℚ)) := by
  have h3 : (3 : ℤ) ≤ (1 - 3 * p) ^ 2 + (1 - 3 * p) * (1 - 3 * q) + (1 - 3 * q) ^ 2 :=
    hex_int_ge_three (by omega) (by omega)
  have h3q : (3 : ℚ) ≤ (1 - 3 * (p : ℚ)) ^ 2 + (1 - 3 * (p : ℚ)) * (1 - 3 * (q : ℚ))
      + (1 - 3 * (q : ℚ)) ^ 2 := by
    have h' := (Int.cast_le (R := ℚ)).2 h3
    push_cast at h'
    linarith
  have hval : bq a a a (1 / 3 - (p : ℚ)) (1 / 3 - (q : ℚ))
      = a * ((1 - 3 * (p : ℚ)) ^ 2 + (1 - 3 * (p : ℚ)) * (1 - 3 * (q : ℚ))
        + (1 - 3 * (q : ℚ)) ^ 2) / 9 := by
    unfold bq; ring
  rw [hval]
  nlinarith

/-- **The `3`-torsion certificate**, negative hexagonal form. -/
lemma hex_third_lower' (a : ℚ) (ha : 0 < a) (p q : ℤ) :
    a / 3 ≤ bq a (-a) a (1 / 3 - (p : ℚ)) (-(1 / 3) - (q : ℚ)) := by
  have h3 : (3 : ℤ) ≤ (1 - 3 * p) ^ 2 + (1 - 3 * p) * (1 + 3 * q) + (1 + 3 * q) ^ 2 :=
    hex_int_ge_three (by omega) (by omega)
  have h3q : (3 : ℚ) ≤ (1 - 3 * (p : ℚ)) ^ 2 + (1 - 3 * (p : ℚ)) * (1 + 3 * (q : ℚ))
      + (1 + 3 * (q : ℚ)) ^ 2 := by
    have h' := (Int.cast_le (R := ℚ)).2 h3
    push_cast at h'
    linarith
  have hval : bq a (-a) a (1 / 3 - (p : ℚ)) (-(1 / 3) - (q : ℚ))
      = a * ((1 - 3 * (p : ℚ)) ^ 2 + (1 - 3 * (p : ℚ)) * (1 + 3 * (q : ℚ))
        + (1 + 3 * (q : ℚ)) ^ 2) / 9 := by
    unfold bq; ring
  rw [hval]
  nlinarith

/-- **Strict certificate for a reduced triple.**  There is a rational shift whose distance² to
*every* lattice point exceeds `a/4 = λ₁/4`.  The shift is `2`-torsion except for the hexagonal
form, where it is `3`-torsion. -/
theorem reduced_certificate {a b c : ℚ} (ha : 0 < a) (hb : |b| ≤ a) (hc : a ≤ c) :
    ∃ s t : ℚ, ∀ p q : ℤ, a / 4 < bq a b c (s - (p : ℚ)) (t - (q : ℚ)) := by
  rcases lt_or_eq_of_le (le_trans hb hc) with hlt | heq
  · refine ⟨1 / 2, 1 / 2, fun p q => ?_⟩
    have h := reduced_half_lower hb hc p q
    linarith
  · -- `|b| = c` forces `a = c = |b|`: the hexagonal form.
    have hca : c ≤ a := heq ▸ hb
    have hac : a = c := le_antisymm hc hca
    have hbabs : |b| = a := by rw [heq, ← hac]
    rcases abs_eq (le_of_lt ha) |>.1 hbabs with hba | hba
    · refine ⟨1 / 3, 1 / 3, fun p q => ?_⟩
      have h : a / 3 ≤ bq a b c (1 / 3 - (p : ℚ)) (1 / 3 - (q : ℚ)) := by
        rw [hba, ← hac]
        exact hex_third_lower a ha p q
      linarith
    · refine ⟨1 / 3, -(1 / 3), fun p q => ?_⟩
      have h : a / 3 ≤ bq a b c (1 / 3 - (p : ℚ)) (-(1 / 3) - (q : ℚ)) := by
        rw [hba, ← hac]
        exact hex_third_lower' a ha p q
      linarith

/-! ## Removing the reducedness hypothesis -/

/-- A vector realising the homogeneous minimum is primitive. -/
lemma primitive_of_min {a b c lam : ℚ} (hlam : 0 < lam)
    (hlow : ∀ p q : ℤ, ¬(p = 0 ∧ q = 0) → lam ≤ bq a b c (p : ℚ) (q : ℚ))
    {v0 v1 : ℤ} (hv : ¬(v0 = 0 ∧ v1 = 0)) (hvlam : bq a b c (v0 : ℚ) (v1 : ℚ) = lam) :
    Int.gcd v0 v1 = 1 := by
  set d : ℤ := (Int.gcd v0 v1 : ℤ) with hd
  have hdpos : 0 < d := by
    have : Int.gcd v0 v1 ≠ 0 := by
      intro h
      exact hv ⟨Int.eq_zero_of_gcd_eq_zero_left h, Int.eq_zero_of_gcd_eq_zero_right h⟩
    omega
  obtain ⟨w0, hw0⟩ : d ∣ v0 := Int.gcd_dvd_left v0 v1
  obtain ⟨w1, hw1⟩ : d ∣ v1 := Int.gcd_dvd_right v0 v1
  have hwne : ¬(w0 = 0 ∧ w1 = 0) := by
    rintro ⟨h0, h1⟩
    exact hv ⟨by rw [hw0, h0, mul_zero], by rw [hw1, h1, mul_zero]⟩
  have hsplit : bq a b c (v0 : ℚ) (v1 : ℚ) = (d : ℚ) ^ 2 * bq a b c (w0 : ℚ) (w1 : ℚ) := by
    rw [hw0, hw1]
    push_cast
    exact bq_smul a b c _ _ _
  have hW : lam ≤ bq a b c (w0 : ℚ) (w1 : ℚ) := hlow w0 w1 hwne
  have hWpos : 0 < bq a b c (w0 : ℚ) (w1 : ℚ) := lt_of_lt_of_le hlam hW
  have hdq : (1 : ℚ) ≤ (d : ℚ) := by exact_mod_cast hdpos
  have hd1 : (d : ℚ) ^ 2 ≤ 1 := by
    by_contra hcon
    push_neg at hcon
    have : lam < bq a b c (v0 : ℚ) (v1 : ℚ) := by
      rw [hsplit]
      nlinarith
    rw [hvlam] at this
    exact lt_irrefl _ this
  have : d = 1 := by
    by_contra hcon
    have h2 : (2 : ℚ) ≤ (d : ℚ) := by
      have : (2 : ℤ) ≤ d := by omega
      exact_mod_cast this
    nlinarith
  omega

/-- Choosing `k = round(−b/2λ)` shears the middle coefficient into `|b'| ≤ λ`. -/
lemma exists_shear_abs_le {lam : ℚ} (hlam : 0 < lam) (Bc : ℚ) :
    ∃ k : ℤ, |Bc + 2 * (k : ℚ) * lam| ≤ lam := by
  refine ⟨round (-Bc / (2 * lam)), ?_⟩
  set r : ℚ := -Bc / (2 * lam) with hr
  have hB : Bc = -2 * lam * r := by rw [hr]; field_simp
  have heq : Bc + 2 * ((round r : ℤ) : ℚ) * lam = -2 * lam * (r - ((round r : ℤ) : ℚ)) := by
    rw [hB]; ring
  have habs : |r - ((round r : ℤ) : ℚ)| ≤ 1 / 2 := abs_sub_round r
  calc |Bc + 2 * ((round r : ℤ) : ℚ) * lam|
      = |(-2 * lam)| * |r - ((round r : ℤ) : ℚ)| := by rw [heq, abs_mul]
    _ = 2 * lam * |r - ((round r : ℤ) : ℚ)| := by
        rw [abs_of_nonpos (by linarith : (-2 : ℚ) * lam ≤ 0)]; ring
    _ ≤ 2 * lam * (1 / 2) := mul_le_mul_of_nonneg_left habs (by linarith)
    _ = lam := by ring

/-- **Reduction theory for binary forms.**  A vector realising the homogeneous minimum `lam` can
be completed to a basis `(v, w)` of `ℤ²` in which the form is *reduced*: the new coefficient
triple is `(lam, b', c')` with `|b'| ≤ lam ≤ c'`.  Only minimality is used — no positivity beyond
`lam > 0`, and no descent. -/
theorem exists_reduced_basis {a b c lam : ℚ} (hlam : 0 < lam)
    (hlow : ∀ p q : ℤ, ¬(p = 0 ∧ q = 0) → lam ≤ bq a b c (p : ℚ) (q : ℚ))
    {v0 v1 : ℤ} (hv : ¬(v0 = 0 ∧ v1 = 0)) (hvlam : bq a b c (v0 : ℚ) (v1 : ℚ) = lam) :
    ∃ w0 w1 : ℤ, v0 * w1 - w0 * v1 = 1 ∧
      |crossCoeff a b c (v0 : ℚ) (v1 : ℚ) (w0 : ℚ) (w1 : ℚ)| ≤ lam ∧
      lam ≤ bq a b c (w0 : ℚ) (w1 : ℚ) := by
  -- a shortest vector is primitive, so it has a Bézout complement
  have hcop : Int.gcd v0 v1 = 1 := primitive_of_min hlam hlow hv hvlam
  obtain ⟨x, y, hxy⟩ : IsCoprime v0 v1 := Int.isCoprime_iff_gcd_eq_one.2 hcop
  -- shear the complement so that the middle coefficient is small
  obtain ⟨k, hkabs⟩ :=
    exists_shear_abs_le hlam (crossCoeff a b c (v0 : ℚ) (v1 : ℚ) ((-y : ℤ) : ℚ) ((x : ℤ) : ℚ))
  obtain ⟨w0, hw0⟩ : ∃ w0 : ℤ, w0 = -y + k * v0 := ⟨_, rfl⟩
  obtain ⟨w1, hw1⟩ : ∃ w1 : ℤ, w1 = x + k * v1 := ⟨_, rfl⟩
  have hdet : v0 * w1 - w0 * v1 = 1 := by rw [hw0, hw1]; linear_combination hxy
  have hwne : ¬(w0 = 0 ∧ w1 = 0) := by
    rintro ⟨h0, h1⟩
    rw [h0, h1] at hdet
    simp at hdet
  have hCge : lam ≤ bq a b c (w0 : ℚ) (w1 : ℚ) := hlow w0 w1 hwne
  have hshear : crossCoeff a b c (v0 : ℚ) (v1 : ℚ) (w0 : ℚ) (w1 : ℚ)
      = crossCoeff a b c (v0 : ℚ) (v1 : ℚ) ((-y : ℤ) : ℚ) ((x : ℤ) : ℚ) + 2 * (k : ℚ) * lam := by
    have h1 : ((w0 : ℤ) : ℚ) = ((-y : ℤ) : ℚ) + (k : ℚ) * (v0 : ℚ) := by
      rw [hw0]; push_cast; ring
    have h2 : ((w1 : ℤ) : ℚ) = ((x : ℤ) : ℚ) + (k : ℚ) * (v1 : ℚ) := by
      rw [hw1]; push_cast; ring
    rw [h1, h2, crossCoeff_shear, hvlam]
  exact ⟨w0, w1, hdet, by rw [hshear]; exact hkabs, hCge⟩

/-- **Reduction and certificate.**  For any binary form whose homogeneous minimum is `lam > 0`
there is a rational shift at squared distance `> lam/4` from every lattice point. -/
theorem strict_certificate_of_min {a b c lam : ℚ} (hlam : 0 < lam)
    (hlow : ∀ p q : ℤ, ¬(p = 0 ∧ q = 0) → lam ≤ bq a b c (p : ℚ) (q : ℚ))
    {v0 v1 : ℤ} (hv : ¬(v0 = 0 ∧ v1 = 0)) (hvlam : bq a b c (v0 : ℚ) (v1 : ℚ) = lam) :
    ∃ s t : ℚ, ∀ p q : ℤ, lam / 4 < bq a b c (s - (p : ℚ)) (t - (q : ℚ)) := by
  obtain ⟨w0, w1, hdet, hBabs, hCge⟩ := exists_reduced_basis hlam hlow hv hvlam
  -- the reduced certificate, transported back to the original coordinates
  obtain ⟨s0, t0, hcert⟩ := reduced_certificate hlam hBabs hCge
  refine ⟨(v0 : ℚ) * s0 + (w0 : ℚ) * t0, (v1 : ℚ) * s0 + (w1 : ℚ) * t0, fun p q => ?_⟩
  obtain ⟨p', hp'⟩ : ∃ p' : ℤ, p' = w1 * p - w0 * q := ⟨_, rfl⟩
  obtain ⟨q', hq'⟩ : ∃ q' : ℤ, q' = -(v1 * p) + v0 * q := ⟨_, rfl⟩
  have hp0 : (p : ℚ) = (v0 : ℚ) * (p' : ℚ) + (w0 : ℚ) * (q' : ℚ) := by
    have hz : v0 * p' + w0 * q' = p := by rw [hp', hq']; linear_combination p * hdet
    exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hz.symm
  have hq0 : (q : ℚ) = (v1 : ℚ) * (p' : ℚ) + (w1 : ℚ) * (q' : ℚ) := by
    have hz : v1 * p' + w1 * q' = q := by rw [hp', hq']; linear_combination q * hdet
    exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hz.symm
  have hxx : (v0 : ℚ) * s0 + (w0 : ℚ) * t0 - (p : ℚ)
      = (v0 : ℚ) * (s0 - (p' : ℚ)) + (w0 : ℚ) * (t0 - (q' : ℚ)) := by
    rw [hp0]; ring
  have hyy : (v1 : ℚ) * s0 + (w1 : ℚ) * t0 - (q : ℚ)
      = (v1 : ℚ) * (s0 - (p' : ℚ)) + (w1 : ℚ) * (t0 - (q' : ℚ)) := by
    rw [hq0]; ring
  rw [hxx, hyy, bq_change, hvlam]
  exact hcert p' q'

/-! ## The theorem, in the vocabulary of the catalogue -/

lemma form_pair (B : Matrix (Fin 2) (Fin 2) ℚ) (p q : ℤ) :
    form B (emb ![p, q]) = bq (B 0 0) (B 0 1 + B 1 0) (B 1 1) (p : ℚ) (q : ℚ) := by
  rw [form_eq_bq]
  simp [emb]

/-- **Conjecture C1, closed.**  For every positive-definite quadratic form on the lattice `ℤ²`
the covering radius² is *strictly* larger than a quarter of the minimal lattice energy.  (In rank
one there is equality, `deepHole_one_isInhomMin`.) -/
theorem rank_two_covering_strict {B : Matrix (Fin 2) (Fin 2) ℚ} (hpd : PosDef B) {lam mu : ℚ}
    (hmin : IsMinEnergy B lam)
    (hcov : ∀ t : Fin 2 → ℚ, ∃ m : Fin 2 → ℤ, form B (fun i => t i - emb m i) ≤ mu) :
    lam / 4 < mu := by
  obtain ⟨⟨v, hv0, hvlam⟩, hlow⟩ := hmin
  have hlampos : 0 < lam := by rw [← hvlam]; exact hpd _ (emb_ne_zero hv0)
  have hvpair : ¬(v 0 = 0 ∧ v 1 = 0) := by
    rintro ⟨h0, h1⟩
    exact hv0 (funext fun i => by fin_cases i <;> simpa using ‹_›)
  have hlowbq : ∀ p q : ℤ, ¬(p = 0 ∧ q = 0) →
      lam ≤ bq (B 0 0) (B 0 1 + B 1 0) (B 1 1) (p : ℚ) (q : ℚ) := by
    intro p q hpq
    have hne : (![p, q] : Fin 2 → ℤ) ≠ 0 := by
      intro hcon
      exact hpq ⟨by simpa using congrFun hcon 0, by simpa using congrFun hcon 1⟩
    have := hlow ![p, q] hne
    rwa [form_pair] at this
  have hvbq : bq (B 0 0) (B 0 1 + B 1 0) (B 1 1) ((v 0 : ℤ) : ℚ) ((v 1 : ℤ) : ℚ) = lam := by
    rw [← hvlam, form_eq_bq]
    simp [emb]
  obtain ⟨s, t, hcert⟩ := strict_certificate_of_min hlampos hlowbq hvpair hvbq
  obtain ⟨m, hm⟩ := hcov ![s, t]
  have hval : form B (fun i => (![s, t] : Fin 2 → ℚ) i - emb m i)
      = bq (B 0 0) (B 0 1 + B 1 0) (B 1 1) (s - (m 0 : ℚ)) (t - (m 1 : ℚ)) := by
    rw [form_eq_bq]
    simp [emb]
  rw [hval] at hm
  exact lt_of_lt_of_le (hcert (m 0) (m 1)) hm

/-! ## The hexagonal lattice: the certificate must be `3`-torsion -/

/-- The hexagonal (`A₂`) form `x² + xy + y²`. -/
def hexForm : Matrix (Fin 2) (Fin 2) ℚ := !![1, 1 / 2; 1 / 2, 1]

lemma form_hex (x : Fin 2 → ℚ) : form hexForm x = bq 1 1 1 (x 0) (x 1) := by
  rw [form_eq_bq]
  norm_num [hexForm]

lemma hex_value (t : Fin 2 → ℚ) (m : Fin 2 → ℤ) :
    form hexForm (fun i => t i - emb m i) = bq 1 1 1 (t 0 - ((m 0 : ℤ) : ℚ)) (t 1 - ((m 1 : ℤ) : ℚ)) := by
  rw [form_hex]
  simp [emb]

lemma hex_posDef : PosDef hexForm := by
  intro x hx
  rw [form_hex]
  have hne : x 0 ≠ 0 ∨ x 1 ≠ 0 := by
    by_contra hcon
    push_neg at hcon
    exact hx (funext fun i => by fin_cases i <;> simp [hcon.1, hcon.2])
  unfold bq
  rcases hne with h | h
  · have := sq_pos_of_ne_zero h
    nlinarith [sq_nonneg (x 0 + 2 * x 1), sq_nonneg (x 1)]
  · have := sq_pos_of_ne_zero h
    nlinarith [sq_nonneg (2 * x 0 + x 1), sq_nonneg (x 0)]

/-- The hexagonal lattice has minimal energy `1`. -/
theorem hex_isMinEnergy : IsMinEnergy hexForm 1 := by
  constructor
  · refine ⟨![1, 0], ?_, ?_⟩
    · intro hcon
      simpa using congrFun hcon 0
    · rw [form_hex]
      norm_num [bq, emb]
  · intro m hm
    have hpair : ¬(m 0 = 0 ∧ m 1 = 0) := by
      rintro ⟨h0, h1⟩
      exact hm (funext fun i => by fin_cases i <;> simpa using ‹_›)
    rw [form_hex]
    have hm0 : ((emb m) 0) = ((m 0 : ℤ) : ℚ) := rfl
    have hm1 : ((emb m) 1) = ((m 1 : ℤ) : ℚ) := rfl
    rw [hm0, hm1]
    exact bq_int_ge one_pos (by norm_num) (by norm_num) hpair

lemma hex_halfPt_value (v m : Fin 2 → ℤ) :
    form hexForm (fun i => halfPt v i - emb m i)
      = bq 1 1 1 ((v 0 - 2 * m 0 : ℤ) : ℚ) ((v 1 - 2 * m 1 : ℤ) : ℚ) / 4 := by
  rw [hex_value]
  simp only [halfPt, bq]
  push_cast
  ring

/-- **All three nonzero classes of `L/2L` contain a shortest vector.**  Hence every `2`-torsion
shift of the hexagonal lattice has gap exactly `λ₁/4 = 1/4`, and no `2`-torsion shift can certify
strictness in `rank_two_covering_strict`. -/
theorem hex_two_torsion_gap (v : Fin 2 → ℤ) (hv : ¬(2 ∣ v 0 ∧ 2 ∣ v 1)) :
    IsInhomMin hexForm (halfPt v) (1 / 4) := by
  constructor
  · -- a nearest lattice point, at squared distance `1/4`
    have hcase : ∃ m : Fin 2 → ℤ, (v 0 - 2 * m 0) ^ 2 + (v 0 - 2 * m 0) * (v 1 - 2 * m 1)
        + (v 1 - 2 * m 1) ^ 2 = 1 := by
      rcases Int.even_or_odd (v 0) with h0 | h0 <;> rcases Int.even_or_odd (v 1) with h1 | h1
      · exact absurd ⟨h0.two_dvd, h1.two_dvd⟩ hv
      · obtain ⟨j, hj⟩ := h0
        obtain ⟨l, hl⟩ := h1
        refine ⟨![j, l], ?_⟩
        simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
        rw [hj, hl]; ring
      · obtain ⟨j, hj⟩ := h0
        obtain ⟨l, hl⟩ := h1
        refine ⟨![j, l], ?_⟩
        simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
        rw [hj, hl]; ring
      · obtain ⟨j, hj⟩ := h0
        obtain ⟨l, hl⟩ := h1
        refine ⟨![j, l + 1], ?_⟩
        simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
        rw [hj, hl]; ring
    obtain ⟨m, hm⟩ := hcase
    refine ⟨m, ?_⟩
    rw [hex_halfPt_value]
    have hcast : ((v 0 - 2 * m 0 : ℤ) : ℚ) ^ 2
        + ((v 0 - 2 * m 0 : ℤ) : ℚ) * ((v 1 - 2 * m 1 : ℤ) : ℚ)
        + ((v 1 - 2 * m 1 : ℤ) : ℚ) ^ 2 = 1 := by
      exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hm
    unfold bq
    linarith [hcast]
  · intro m
    rw [hex_halfPt_value]
    have hne : ¬(v 0 - 2 * m 0 = 0 ∧ v 1 - 2 * m 1 = 0) := by
      rintro ⟨h0, h1⟩
      exact hv ⟨⟨m 0, by omega⟩, ⟨m 1, by omega⟩⟩
    have hge := bq_int_ge (a := 1) (b := 1) (c := 1) one_pos (by norm_num) (by norm_num) hne
    linarith

/-- The `3`-torsion shift `(⅓, ⅓)` of the hexagonal lattice has gap `1/3 > λ₁/4 = 1/4`: it is the
deep hole, and it certifies strictness. -/
theorem hex_third_isInhomMin : IsInhomMin hexForm (fracPt ![1, 1] 3) (1 / 3) := by
  have hpt0 : fracPt (![1, 1] : Fin 2 → ℤ) 3 0 = 1 / 3 := by norm_num [fracPt]
  have hpt1 : fracPt (![1, 1] : Fin 2 → ℤ) 3 1 = 1 / 3 := by norm_num [fracPt]
  have hvalue : ∀ m : Fin 2 → ℤ, form hexForm (fun i => fracPt ![1, 1] 3 i - emb m i)
      = bq 1 1 1 (1 / 3 - ((m 0 : ℤ) : ℚ)) (1 / 3 - ((m 1 : ℤ) : ℚ)) := by
    intro m
    rw [hex_value, hpt0, hpt1]
  constructor
  · refine ⟨0, ?_⟩
    rw [hvalue 0]
    norm_num [bq]
  · intro m
    rw [hvalue m]
    have h := hex_third_lower 1 one_pos (m 0) (m 1)
    linarith

/-- **No `2`-torsion certificate for the hexagonal lattice.**  Its covering radius² is `1/3`, but
every `2`-torsion shift has gap `1/4` (the three nonzero classes) or `0` (the trivial class);
hence the extremal shift in `rank_two_covering_strict` must be allowed to have order `3`. -/
theorem hexagonal_two_torsion_never_deepest (v : Fin 2 → ℤ) :
    ¬ IsInhomMin hexForm (halfPt v) (1 / 3) := by
  intro hcon
  by_cases hv : 2 ∣ v 0 ∧ 2 ∣ v 1
  · obtain ⟨⟨j, hj⟩, ⟨l, hl⟩⟩ := hv
    have h0 : form hexForm (fun i => halfPt v i - emb ![j, l] i) = 0 := by
      rw [hex_value]
      have e0 : halfPt v 0 - (((![j, l] : Fin 2 → ℤ) 0 : ℤ) : ℚ) = 0 := by
        simp only [halfPt, Matrix.cons_val_zero]
        rw [hj]; push_cast; ring
      have e1 : halfPt v 1 - (((![j, l] : Fin 2 → ℤ) 1 : ℤ) : ℚ) = 0 := by
        simp only [halfPt, Matrix.cons_val_one]
        rw [hl]; push_cast; ring
      rw [e0, e1]
      norm_num [bq]
    have h := hcon.2 ![j, l]
    rw [h0] at h
    linarith
  · have hgap := hex_two_torsion_gap v hv
    have := isInhomMin_unique hgap hcon
    norm_num at this

end RankTwo
end DiophantineLattice