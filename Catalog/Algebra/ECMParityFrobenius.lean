/-
# ECM-PARITY, Frobenius face: Stickelberger's parity law for a depressed cubic

Let `p` be an odd prime and `x³ + A x + B` a separable cubic over `𝔽_p`
(`Δ = -4A³ - 27B² ≠ 0`).  The number `r` of roots in `𝔽_p` is `0`, `1` or `3`
(`ECMParityCore`), i.e. Frobenius acts on the three geometric roots as a
`3`-cycle, a transposition, or the identity.  This file proves the exact
**parity law** relating the cycle type to the quadratic character of `Δ`:

* `ECMParity.disc_isSquare_of_no_root` — `r = 0` (Frobenius a `3`-cycle) forces
  `Δ` to be a **square**.  This is the substantial direction: one passes to
  `K = 𝔽_p[x]/(f) ≅ 𝔽_{p³}`, where the three roots are `a, a^p, a^{p²}`, and
  observes that the root-difference product `δ` is Frobenius invariant, hence
  lies in the prime field, while `δ² = Δ`.
* `ECMParity.disc_not_isSquare_of_unique_root` — `r = 1` (a transposition)
  forces `Δ` to be a **non-square** (the complementary quadratic factor is
  irreducible).
* `ECMParity.disc_isSquare_of_three_roots` — `r = 3` gives a square.

Consequences: `Δ` is a non-square **iff** Frobenius is a transposition
(`ECMParity.disc_not_isSquare_iff_card_eq_one`), and therefore
`(Δ|p) = -1 ⇒ 2 ∣ #E` (`ECMParity.two_dvd_curveCard_of_legendre_eq_neg_one`),
the "transposition face is `(Δ|p)`-pinned" phenomenon: on `(Δ|p) = -1` the
elliptic order is even with probability exactly `1`.
-/
import Mathlib
import Algebra.ECMParityCore

namespace ECMParity

open Polynomial Finset

variable {p : ℕ} [Fact p.Prime]

/-! ## 1. The cubic as a polynomial -/

/-- The depressed cubic as a polynomial over `ZMod p`. -/
noncomputable def cubicPoly (A B : ZMod p) : (ZMod p)[X] := X ^ 3 + C A * X + C B

@[simp] theorem cubicPoly_eval (A B x : ZMod p) : (cubicPoly A B).eval x = cubic A B x := by
  simp [cubicPoly, cubic]

theorem cubicPoly_natDegree (A B : ZMod p) : (cubicPoly A B).natDegree = 3 := by
  unfold cubicPoly
  compute_degree!

/-- A rootless cubic is irreducible over `𝔽_p` (Frobenius is a `3`-cycle). -/
theorem cubicPoly_irreducible {A B : ZMod p} (hnr : ∀ x : ZMod p, cubic A B x ≠ 0) :
    Irreducible (cubicPoly A B) := by
  refine Polynomial.irreducible_of_degree_le_three_of_not_isRoot ?_ ?_
  · simp [cubicPoly_natDegree]
  · intro x hx
    exact hnr x (by simpa using hx)

/-! ## 2. `r = 0` forces a square discriminant -/

/-- **Stickelberger, `3`-cycle face.**  If the separable cubic `x³ + A x + B` has no
root in `𝔽_p`, its discriminant is a square in `𝔽_p`.

The proof works in `K = 𝔽_p[x]/(f) ≅ 𝔽_{p³}`: the roots are `a, a^p, a^{p²}`,
Frobenius permutes them cyclically, hence fixes the root-difference product `δ`,
so `δ` lies in the prime field and `Δ = δ²`. -/
theorem disc_isSquare_of_no_root {A B : ZMod p} (hd : disc A B ≠ 0)
    (hnr : ∀ x : ZMod p, cubic A B x ≠ 0) : IsSquare (disc A B) := by
  classical
  have hf : Irreducible (cubicPoly A B) := cubicPoly_irreducible hnr
  haveI : Fact (Irreducible (cubicPoly A B)) := ⟨hf⟩
  set K := AdjoinRoot (cubicPoly A B) with hK
  haveI : FiniteDimensional (ZMod p) K := (AdjoinRoot.powerBasis hf.ne_zero).finite
  haveI : Finite K := Module.finite_of_finite (ZMod p)
  haveI : Fintype K := Fintype.ofFinite _
  have hcard : Fintype.card K = p ^ 3 := by
    rw [Module.card_fintype (AdjoinRoot.powerBasis hf.ne_zero).basis, ZMod.card,
      Fintype.card_fin, AdjoinRoot.powerBasis_dim, cubicPoly_natDegree]
  haveI : CharP K p :=
    charP_of_injective_algebraMap (algebraMap (ZMod p) K).injective p
  -- notation
  set φ : ZMod p →+* K := algebraMap (ZMod p) K with hφ
  have hinj : Function.Injective φ := (algebraMap (ZMod p) K).injective
  have hfix : ∀ y : ZMod p, (φ y) ^ p = φ y := by
    intro y; rw [← map_pow, ZMod.pow_card]
  set A' := φ A with hA'
  set B' := φ B with hB'
  set a := AdjoinRoot.root (cubicPoly A B) with hadef
  -- `a` is a root of the cubic over `K`
  have ha : cubic A' B' a = 0 := by
    have h0 : (Polynomial.aeval a) (cubicPoly A B) = 0 := by
      rw [AdjoinRoot.aeval_eq, AdjoinRoot.mk_self]
    simpa [cubicPoly, cubic, hA', hB'] using h0
  -- Frobenius sends roots to roots
  have hroot_frob : ∀ x : K, cubic A' B' x = 0 → cubic A' B' (x ^ p) = 0 := by
    intro x hx
    have hexp : cubic A' B' (x ^ p) = (cubic A' B' x) ^ p := by
      rw [cubic, cubic, add_pow_char, add_pow_char, mul_pow, hA', hB', hfix, hfix,
        ← pow_mul, ← pow_mul, mul_comm 3 p]
    rw [hexp, hx, zero_pow (Fact.out : p.Prime).ne_zero]
  -- transporting elements of the prime field
  have hprime_field : ∀ x : K, x ^ p = x → ∃ t : ZMod p, φ t = x := by
    intro x hx
    have hmem : x ∈ (⊥ : Subfield K) := (Subfield.mem_bot_iff_pow_eq_self _ p).2 hx
    rw [Subfield.bot_eq_of_zMod_algebra p] at hmem
    exact hmem
  -- `a ∉ 𝔽_p`, so `a ≠ a^p`
  have hne : a ≠ a ^ p := by
    intro h
    obtain ⟨t, ht⟩ := hprime_field a h.symm
    refine hnr t (hinj ?_)
    have hmap : φ (cubic A B t) = cubic A' B' (φ t) := by
      simp [cubic, hA', hB', map_add, map_mul, map_pow]
    rw [map_zero, hmap, ht, ha]
  set b := a ^ p with hbdef
  set c := -(a + b) with hcdef
  have hb : cubic A' B' b = 0 := hroot_frob a ha
  -- the discriminant over `K`
  have hdmap : φ (disc A B) = disc A' B' := by
    simp only [disc, hA', hB', map_sub, map_mul, map_pow, map_neg, map_ofNat]
  have hd' : disc A' B' ≠ 0 := by
    rw [← hdmap]
    simpa using fun h => hd (hinj (by simpa using h))
  -- the third root is `a^{p²}`
  have hfrob3 : ∀ x : K, x ^ (p ^ 3) = x := by
    intro x; rw [← hcard]; exact FiniteField.pow_card x
  have hb2 : cubic A' B' (a ^ (p ^ 2)) = 0 := by
    have : a ^ (p ^ 2) = b ^ p := by rw [hbdef, ← pow_mul, ← pow_two]
    rw [this]
    exact hroot_frob b hb
  have hc2 : a ^ (p ^ 2) = c := by
    rcases root_cases hne ha hb hb2 with h | h | h
    · exfalso
      apply hne
      have h3 : a ^ (p ^ 3) = (a ^ (p ^ 2)) ^ p := by rw [← pow_mul, pow_succ]
      rw [hfrob3, h] at h3
      exact h3
    · exfalso
      apply hne
      have h4 : a ^ (p ^ 3) = (a ^ (p ^ 2)) ^ p := by rw [← pow_mul, pow_succ]
      rw [hfrob3, h, hbdef, ← pow_mul, ← pow_two] at h4
      -- now `a = a^{p²}`, which as above forces `a = a^p`
      have h5 : a ^ (p ^ 3) = (a ^ (p ^ 2)) ^ p := by rw [← pow_mul, pow_succ]
      rw [hfrob3, ← h4] at h5
      exact h5
    · exact h
  -- Frobenius fixes the root difference product
  set δ := (a - b) * (b - -(a + b)) * (-(a + b) - a) with hδdef
  have hδp : δ ^ p = δ := by
    have hcp : c ^ p = a := by
      rw [hcdef] at hc2 ⊢
      rw [← hc2, ← pow_mul, ← pow_succ, hfrob3]
    have hbp : b ^ p = c := by rw [hbdef, ← pow_mul, ← pow_two, hc2]
    rw [hδdef, mul_pow, mul_pow, sub_pow_char, sub_pow_char, sub_pow_char, ← hbdef,
      ← hcdef, hbp, hcp]
    rw [hcdef]
    ring
  have hδsq : disc A' B' = δ ^ 2 := by
    rw [hδdef]
    exact disc_eq_sq hne ha hb
  obtain ⟨t, ht⟩ := hprime_field δ hδp
  refine ⟨t, hinj ?_⟩
  rw [map_mul, hdmap, hδsq, ht, sq]

/-! ## 3. `r = 1` forces a non-square discriminant -/

/-- Over `𝔽_p` (`p` odd) a quadratic `x² + a x + c` has a root iff its discriminant
`a² - 4c` is a square. -/
theorem quadratic_root_iff_isSquare (hp : p ≠ 2) (a c : ZMod p) :
    (∃ x : ZMod p, x ^ 2 + a * x + c = 0) ↔ IsSquare (a ^ 2 - 4 * c) := by
  have h2 : (2 : ZMod p) ≠ 0 := two_ne_zero_of_odd hp
  constructor
  · rintro ⟨x, hx⟩
    exact ⟨2 * x + a, by linear_combination -4 * hx⟩
  · rintro ⟨u, hu⟩
    refine ⟨(u - a) / 2, ?_⟩
    field_simp
    linear_combination -hu

/-- **Stickelberger, transposition face.**  A separable cubic with exactly one root in
`𝔽_p` has non-square discriminant. -/
theorem disc_not_isSquare_of_unique_root (hp : p ≠ 2) {A B a : ZMod p} (hd : disc A B ≠ 0)
    (ha : cubic A B a = 0) (huniq : ∀ x : ZMod p, cubic A B x = 0 → x = a) :
    ¬ IsSquare (disc A B) := by
  -- `x³ + A x + B = (x - a)(x² + a x + (a² + A))`
  have hB : B = -(a ^ 3) - A * a := by unfold cubic at ha; linear_combination ha
  have hfac : ∀ x : ZMod p, cubic A B x = (x - a) * (x ^ 2 + a * x + (a ^ 2 + A)) := by
    intro x; rw [cubic, hB]; ring
  -- the quadratic factor has no root
  have hnoroot : ¬ ∃ x : ZMod p, x ^ 2 + a * x + (a ^ 2 + A) = 0 := by
    rintro ⟨x, hx⟩
    have hxr : cubic A B x = 0 := by rw [hfac, hx, mul_zero]
    have hxa : x = a := huniq x hxr
    subst hxa
    -- `x = a` would be a double root, so `Δ = 0`
    apply hd
    have hA : A = -3 * x ^ 2 := by linear_combination hx
    rw [disc, hB, hA]; ring
  have hDns : ¬ IsSquare (a ^ 2 - 4 * (a ^ 2 + A)) := by
    rw [← quadratic_root_iff_isSquare hp]
    exact hnoroot
  -- `Δ = (3a² + A)² * (-3a² - 4A)`
  have hkey : disc A B = (3 * a ^ 2 + A) ^ 2 * (a ^ 2 - 4 * (a ^ 2 + A)) := by
    rw [disc, hB]; ring
  have hne : (3 * a ^ 2 + A) ≠ 0 := by
    intro h
    apply hd
    rw [hkey, h]; ring
  rintro ⟨s, hs⟩
  apply hDns
  have hval : (a ^ 2 - 4 * (a ^ 2 + A)) * ((3 * a ^ 2 + A) * (3 * a ^ 2 + A)) = s * s := by
    linear_combination hs - hkey
  refine ⟨s / (3 * a ^ 2 + A), ?_⟩
  rw [div_mul_div_comm, eq_div_iff (mul_ne_zero hne hne)]
  exact hval

/-! ## 4. `r = 3` gives a square, and the full parity law -/

/-- The split face: three roots make the discriminant a square. -/
theorem disc_isSquare_of_three_roots {A B a b : ZMod p} (hab : a ≠ b)
    (ha : cubic A B a = 0) (hb : cubic A B b = 0) : IsSquare (disc A B) := by
  refine ⟨(a - b) * (b - -(a + b)) * (-(a + b) - a), ?_⟩
  rw [disc_eq_sq hab ha hb, sq]

/-- **Parity law (Stickelberger for cubics).**  For a separable cubic over `𝔽_p`
(`p` odd), the discriminant is a non-square exactly when Frobenius is a
transposition, i.e. exactly when the cubic has precisely one root. -/
theorem disc_not_isSquare_iff_card_eq_one (hp : p ≠ 2) (A B : ZMod p) (hd : disc A B ≠ 0) :
    ¬ IsSquare (disc A B) ↔ (rootSet A B).card = 1 := by
  constructor
  · intro hns
    rcases rootSet_card_cases A B hd with h | h | h
    · exfalso
      apply hns
      refine disc_isSquare_of_no_root hd (fun x hx => ?_)
      have : x ∈ rootSet A B := by simp [rootSet, hx]
      rw [Finset.card_eq_zero.1 h] at this
      simp at this
    · exact h
    · exfalso
      apply hns
      have hcard : 1 < (rootSet A B).card := by omega
      obtain ⟨a, ha, b, hb, hab⟩ := Finset.one_lt_card.1 hcard
      simp only [rootSet, Finset.mem_filter] at ha hb
      exact disc_isSquare_of_three_roots hab ha.2 hb.2
  · intro h
    obtain ⟨a, hasingle⟩ := Finset.card_eq_one.1 h
    have ha : cubic A B a = 0 := by
      have : a ∈ rootSet A B := by rw [hasingle]; simp
      simpa [rootSet] using this
    refine disc_not_isSquare_of_unique_root hp hd ha (fun x hx => ?_)
    have hx' : x ∈ rootSet A B := by simp [rootSet, hx]
    rw [hasingle] at hx'
    simpa using hx'

/-! ## 5. The `(Δ|p)`-pinned face of the elliptic order -/

/-- **Transposition face is `(Δ|p)`-pinned.**  If the discriminant of the (separable)
cubic is a non-square mod `p`, then the order of the curve `y² = x³ + A x + B`
over `𝔽_p` is even — with probability exactly `1`, not `2/3`. -/
theorem two_dvd_curveCard_of_disc_not_isSquare (hp : p ≠ 2) (A B : ZMod p)
    (hd : disc A B ≠ 0) (hns : ¬ IsSquare (disc A B)) : 2 ∣ curveCard A B := by
  rw [two_dvd_curveCard_iff hp A B hd]
  by_contra hc
  push_neg at hc
  exact hns (disc_isSquare_of_no_root hd hc)

/-- Legendre-symbol form of the previous theorem. -/
theorem two_dvd_curveCard_of_legendre_eq_neg_one (hp : p ≠ 2) (A B : ZMod p) (D : ℤ)
    (hD : (D : ZMod p) = disc A B) (hd : disc A B ≠ 0) (hleg : legendreSym p D = -1) :
    2 ∣ curveCard A B := by
  refine two_dvd_curveCard_of_disc_not_isSquare hp A B hd ?_
  rw [← hD]
  exact (legendreSym.eq_neg_one_iff p).1 hleg

end ECMParity