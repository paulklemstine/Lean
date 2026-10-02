/-
# The fifth `S₃` field: `x³ - 4x + 1`, discriminant `229`

Arithmetic of the cubic `f = x³ - 4x + 1` that underlies the FIVE-FIELDS-ONE-LAW
type-channel result (`Combinatorics.S3TypeChannelLaw`).

* `disc_eq_sq` — two distinct roots `r, s` give `((r-s)(r+2s)(2r+s))² = 229`;
* `isSquare_of_no_root` — **Stickelberger for `f`**: if `f` has no root mod `p` then
  `229` is a square mod `p` (Frobenius acts on the roots as a 3-cycle, fixing the
  Vandermonde product; proved with an explicit Frobenius computation in `AdjoinRoot f`);
* `existsUnique_root_iff` — for `p ∉ {2, 229}`: exactly one root ⇔ `229` is a non-square;
* `existsUnique_root_iff_conductor` — by quadratic reciprocity: exactly one root ⇔ `p` is
  a quadratic non-residue **mod 229**;
* `typeSign_eq_legendreSym` — the root-count sign equals the Legendre symbol `(p/229)`;
* `three_roots_of_isSquare`, `third_root_ne` — on the residue side the type is `1+1+1`
  or `3`; the root count is never `2`;
* `irreducible_over_rat`, `disc_not_square_rat`, `three_real_roots` — `f` defines a totally
  real cubic field with Galois group `S₃`.
-/
import Mathlib

namespace S3Cubic229

open Polynomial Finset

/-! ## 1. The discriminant identity -/

/-- The cubic `x³ - 4x + 1` evaluated in a commutative ring. -/
def cub {R : Type*} [CommRing R] (x : R) : R := x ^ 3 - 4 * x + 1

/-- Two distinct roots `r ≠ s` of `x³ - 4x + 1` in a domain satisfy the two
symmetric relations `r² + rs + s² = 4` and `rs(r + s) = 1`. -/
theorem two_root_relations {K : Type*} [CommRing K] [IsDomain K] {r s : K}
    (hr : cub r = 0) (hs : cub s = 0) (hrs : r ≠ s) :
    r ^ 2 + r * s + s ^ 2 = 4 ∧ r * s * (r + s) = 1 := by
  unfold cub at hr hs
  have h0 : (r - s) * (r ^ 2 + r * s + s ^ 2 - 4) = 0 := by linear_combination hr - hs
  have h1 : r ^ 2 + r * s + s ^ 2 = 4 := by
    have := (mul_eq_zero.1 h0).resolve_left (sub_ne_zero.2 hrs)
    linear_combination this
  exact ⟨h1, by linear_combination r * h1 - hr⟩

/-- The third root: if `r ≠ s` are roots, so is `-(r + s)`. -/
theorem third_root {K : Type*} [CommRing K] [IsDomain K] {r s : K}
    (hr : cub r = 0) (hs : cub s = 0) (hrs : r ≠ s) : cub (-(r + s)) = 0 := by
  obtain ⟨h1, h2⟩ := two_root_relations hr hs hrs
  unfold cub
  linear_combination (-(r + s)) * h1 - h2

/-- **Discriminant 229.**  If `x³ - 4x + 1` has two distinct roots `r, s` in a domain,
then `229 = δ²` with `δ = (r - s)(r + 2s)(2r + s)` the Vandermonde product of the three
roots `r, s, -(r+s)`. -/
theorem disc_eq_sq {K : Type*} [CommRing K] [IsDomain K] {r s : K}
    (hr : cub r = 0) (hs : cub s = 0) (hrs : r ≠ s) :
    ((r - s) * (r + 2 * s) * (2 * r + s)) ^ 2 = 229 := by
  obtain ⟨h1, h2⟩ := two_root_relations hr hs hrs
  have hid : ((r - s) * (r + 2 * s) * (2 * r + s)) ^ 2
      = 4 * (r ^ 2 + r * s + s ^ 2) ^ 3 - 27 * (r * s * (r + s)) ^ 2 := by ring
  rw [hid, h1, h2]
  norm_num

/-- Consequently, if `229` is not a square in a domain `K`, the cubic has at most one
root in `K`. -/
theorem root_unique_of_not_isSquare {K : Type*} [CommRing K] [IsDomain K]
    (h : ¬ IsSquare (229 : K)) {r s : K} (hr : cub r = 0) (hs : cub s = 0) : r = s := by
  by_contra hrs
  exact h ⟨_, (disc_eq_sq hr hs hrs).symm.trans (sq _)⟩

/-- The residual-discriminant identity: for a root `r`,
`229 = (16 - 3r²)(3r² - 4)²`, i.e. `disc(f) = disc(f/(x-r)) · f'(r)²`. -/
theorem disc_residual {K : Type*} [CommRing K] {r : K} (hr : cub r = 0) :
    (16 - 3 * r ^ 2) * (3 * r ^ 2 - 4) ^ 2 = 229 := by
  unfold cub at hr
  linear_combination (-27 * r ^ 3 + 108 * r + 27) * hr

/-! ## 2. Frobenius: no root forces a square discriminant -/

/-- In a field of characteristic `p`, the solutions of `x ^ p = x` are exactly the
elements of the prime field. -/
theorem exists_zmod_of_pow_eq_self {p : ℕ} [Fact p.Prime] {L : Type*} [Field L]
    [Algebra (ZMod p) L] {x : L} (hx : x ^ p = x) : ∃ k : ZMod p, algebraMap (ZMod p) L k = x := by
  classical
  have hp1 : 1 < p := (Fact.out : p.Prime).one_lt
  set P : L[X] := X ^ p - X with hPdef
  have hP : P ≠ 0 := FiniteField.X_pow_card_sub_X_ne_zero L hp1
  have hdeg : P.natDegree = p := FiniteField.X_pow_card_sub_X_natDegree_eq L hp1
  let S : Finset L := univ.image (algebraMap (ZMod p) L)
  have hS : S ⊆ P.roots.toFinset := by
    intro y hy
    obtain ⟨k, -, rfl⟩ := mem_image.1 hy
    rw [Multiset.mem_toFinset, mem_roots hP, IsRoot, hPdef]
    simp [← map_pow, ZMod.pow_card]
  have hScard : S.card = p := by
    rw [card_image_of_injective _ (algebraMap (ZMod p) L).injective, card_univ, ZMod.card]
  have hle : P.roots.toFinset.card ≤ S.card :=
    hScard ▸ (Multiset.toFinset_card_le _).trans (hdeg ▸ card_roots' P)
  have heq := eq_of_subset_of_card_le hS hle
  have hxr : x ∈ P.roots.toFinset := by
    rw [Multiset.mem_toFinset, mem_roots hP, IsRoot, hPdef]
    simp [hx]
  rw [← heq] at hxr
  obtain ⟨k, -, hk⟩ := mem_image.1 hxr
  exact ⟨k, hk⟩

/-- The cubic as a polynomial over `ZMod p`. -/
noncomputable def cubPoly (p : ℕ) : (ZMod p)[X] := X ^ 3 - C 4 * X + 1

theorem cubPoly_natDegree (p : ℕ) [Fact p.Prime] : (cubPoly p).natDegree = 3 := by
  unfold cubPoly
  compute_degree!

theorem eval_cubPoly {p : ℕ} (x : ZMod p) : (cubPoly p).eval x = cub x := by
  simp [cubPoly, cub]

/-- **Frobenius core.**  Let `L` be a field of characteristic `p` containing a root `α`
of `x³ - 4x + 1`, while `ZMod p` contains none.  Then `229` is a square in `ZMod p`. -/
theorem isSquare_of_root_in_ext {p : ℕ} [Fact p.Prime] {L : Type*} [Field L]
    [Algebra (ZMod p) L] (h : ∀ x : ZMod p, cub x ≠ 0) {α : L} (hα : cub α = 0) :
    IsSquare (229 : ZMod p) := by
  haveI : CharP L p := charP_of_injective_algebraMap (algebraMap (ZMod p) L).injective p
  -- roots of the cubic in `L` are mapped to roots by Frobenius
  have hroot_frob : ∀ y : L, cub y = 0 → cub (y ^ p) = 0 := by
    intro y hy
    have := congrArg (frobenius L p) hy
    simp only [cub, map_add, map_sub, map_mul, map_pow, map_one, map_zero, map_ofNat,
      frobenius_def] at this
    unfold cub
    rw [← this]
  -- no root of the cubic in `L` is fixed by Frobenius
  have hnofix : ∀ y : L, cub y = 0 → y ^ p ≠ y := by
    intro y hy hfix
    obtain ⟨k, rfl⟩ := exists_zmod_of_pow_eq_self hfix
    apply h k
    apply (algebraMap (ZMod p) L).injective
    simp only [cub, map_add, map_sub, map_mul, map_pow, map_one, map_zero, map_ofNat] at hy ⊢
    exact hy
  set β : L := α ^ p with hβdef
  have hβ : cub β = 0 := hroot_frob α hα
  have hαβ : α ≠ β := fun e => hnofix α hα e.symm
  set θ : L := -(α + β) with hθdef
  have hθ : cub θ = 0 := third_root hα hβ hαβ
  obtain ⟨h1, -⟩ := two_root_relations hα hβ hαβ
  -- every root is one of `α, β, θ`
  have hroots : ∀ y : L, cub y = 0 → y = α ∨ y = β ∨ y = θ := by
    intro y hy
    by_cases hyα : y = α
    · exact Or.inl hyα
    obtain ⟨h1', -⟩ := two_root_relations hy hα hyα
    have : (y - β) * (y - θ) = 0 := by rw [hθdef]; linear_combination h1' - h1
    rcases mul_eq_zero.1 this with h | h
    · exact Or.inr (Or.inl (sub_eq_zero.1 h))
    · exact Or.inr (Or.inr (sub_eq_zero.1 h))
  -- Frobenius acts as the 3-cycle `α ↦ β ↦ θ`
  have hθp : θ ^ p = -(α ^ p + β ^ p) := by
    rw [hθdef, ← frobenius_def, map_neg, map_add, frobenius_def, frobenius_def]
  have hβp : β ^ p = θ := by
    rcases hroots _ (hroot_frob β hβ) with e | e | e
    · exfalso
      apply hnofix θ hθ
      rw [hθp, e, hθdef]
      ring
    · exact absurd e (hnofix β hβ)
    · exact e
  set δ : L := (α - β) * (α + 2 * β) * (2 * α + β) with hδdef
  have hδ2 : δ ^ 2 = 229 := disc_eq_sq hα hβ hαβ
  have hδp : δ ^ p = δ := by
    have e : δ ^ p = (α ^ p - β ^ p) * (α ^ p + 2 * β ^ p) * (2 * α ^ p + β ^ p) := by
      rw [← frobenius_def, hδdef]
      simp only [map_mul, map_sub, map_add, map_ofNat, frobenius_def]
    rw [e, hβp, ← hβdef, hθdef]
    ring
  obtain ⟨k, hk⟩ := exists_zmod_of_pow_eq_self hδp
  refine ⟨k, (algebraMap (ZMod p) L).injective ?_⟩
  rw [map_mul, hk, ← sq, hδ2, map_ofNat]

/-- **Stickelberger for `x³ - 4x + 1`.**  If the cubic has no root modulo the prime `p`,
then `229` is a square modulo `p`.  (The Frobenius acts on the three roots as a
fixed-point-free permutation, i.e. a 3-cycle, which fixes the Vandermonde product.) -/
theorem isSquare_of_no_root {p : ℕ} [hp : Fact p.Prime] (h : ∀ x : ZMod p, cub x ≠ 0) :
    IsSquare (229 : ZMod p) := by
  have hirr : Irreducible (cubPoly p) :=
    irreducible_of_degree_le_three_of_not_isRoot (by rw [cubPoly_natDegree]; decide)
      (fun x hx => h x (by rw [← eval_cubPoly]; exact hx))
  haveI : Fact (Irreducible (cubPoly p)) := ⟨hirr⟩
  refine isSquare_of_root_in_ext (L := AdjoinRoot (cubPoly p)) h
    (α := AdjoinRoot.root (cubPoly p)) ?_
  have h0 := AdjoinRoot.eval₂_root (cubPoly p)
  simpa [cubPoly, cub, eval₂_sub, eval₂_add] using h0

/-! ## 3. A root plus a square discriminant gives a second root -/

/-- In a field where `2 ≠ 0` and `229 ≠ 0`, a root `r` of `x³ - 4x + 1` together with a
square discriminant yields a second, different root. -/
theorem exists_second_root {K : Type*} [Field K] (h2 : (2 : K) ≠ 0) (h229 : (229 : K) ≠ 0)
    {r : K} (hr : cub r = 0) (hsq : IsSquare (229 : K)) : ∃ s, cub s = 0 ∧ s ≠ r := by
  obtain ⟨d, hd⟩ := hsq
  have hres := disc_residual hr
  have hw : 3 * r ^ 2 - 4 ≠ 0 := by
    intro hw
    apply h229
    rw [← hres, hw]
    ring
  set e := d / (3 * r ^ 2 - 4) with he_def
  have he : e ^ 2 = 16 - 3 * r ^ 2 := by
    rw [he_def, div_pow, div_eq_iff (pow_ne_zero 2 hw), sq d, ← hd, ← hres]
  have he0 : e ≠ 0 := by
    intro h0
    apply h229
    rw [hd, ← sq, ← div_mul_cancel₀ d hw, ← he_def, h0]
    ring
  have hroot : ∀ s : K, (2 * s + r) ^ 2 = e ^ 2 → cub s = 0 := by
    intro s hs
    have h4 : (4 : K) * (s ^ 2 + r * s + r ^ 2 - 4) = 0 := by linear_combination hs + he
    have h4' : (4 : K) ≠ 0 := by
      rw [show (4 : K) = 2 * 2 by norm_num]
      exact mul_ne_zero h2 h2
    have hq := (mul_eq_zero.1 h4).resolve_left h4'
    unfold cub at hr ⊢
    linear_combination (s - r) * hq + hr
  have hs1 : cub ((-r + e) / 2) = 0 := hroot _ (by field_simp; ring)
  have hs2 : cub ((-r - e) / 2) = 0 := hroot _ (by field_simp; ring)
  have hne : (-r + e) / 2 ≠ (-r - e) / 2 := by
    intro h
    apply he0
    have : (-r + e) - (-r - e) = 0 := by
      rw [div_left_inj' h2] at h
      rw [h, sub_self]
    have h2e : 2 * e = 0 := by linear_combination this
    exact (mul_eq_zero.1 h2e).resolve_left h2
  by_cases h1 : (-r + e) / 2 = r
  · exact ⟨_, hs2, fun h => hne (h1.trans h.symm)⟩
  · exact ⟨_, hs1, h1⟩

/-! ## 4. The conductor law for `x³ - 4x + 1` -/

instance fact_prime_229 : Fact (Nat.Prime 229) := ⟨by norm_num⟩

lemma two_ne_zero_zmod {p : ℕ} [hp : Fact p.Prime] (hp2 : p ≠ 2) : (2 : ZMod p) ≠ 0 := by
  intro h
  have : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
  rw [ZMod.natCast_eq_zero_iff] at this
  exact hp2 ((Nat.prime_dvd_prime_iff_eq hp.out Nat.prime_two).1 this)

lemma n229_ne_zero_zmod {p : ℕ} [hp : Fact p.Prime] (hp229 : p ≠ 229) : (229 : ZMod p) ≠ 0 := by
  intro h
  have : ((229 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
  rw [ZMod.natCast_eq_zero_iff] at this
  exact hp229 ((Nat.prime_dvd_prime_iff_eq hp.out (by norm_num)).1 this)

/-- **Splitting-type law, discriminant form.**  For a prime `p ∉ {2, 229}`, the cubic
`x³ - 4x + 1` has exactly one root modulo `p` (splitting type `1 + 2`, Frobenius a
transposition) if and only if `229` is a quadratic non-residue modulo `p`. -/
theorem existsUnique_root_iff {p : ℕ} [Fact p.Prime] (hp2 : p ≠ 2) (hp229 : p ≠ 229) :
    (∃! x : ZMod p, cub x = 0) ↔ ¬ IsSquare (229 : ZMod p) := by
  constructor
  · rintro ⟨r, hr, huniq⟩ hsq
    obtain ⟨s, hs, hsr⟩ :=
      exists_second_root (two_ne_zero_zmod hp2) (n229_ne_zero_zmod hp229) hr hsq
    exact hsr (huniq s hs)
  · intro hns
    have hex : ∃ x : ZMod p, cub x = 0 := by
      by_contra hno
      push_neg at hno
      exact hns (isSquare_of_no_root hno)
    obtain ⟨r, hr⟩ := hex
    exact ⟨r, hr, fun s hs => root_unique_of_not_isSquare hns hs hr⟩

/-- **Splitting-type law, conductor form (`p mod 229`).**  By quadratic reciprocity
(`229 ≡ 1 mod 4`), for a prime `p ∉ {2, 229}` the cubic `x³ - 4x + 1` has exactly one
root modulo `p` iff `p` is a quadratic non-residue modulo `229`.  Thus the residue class
`p mod 229` determines whether the splitting type is `1 + 2`. -/
theorem existsUnique_root_iff_conductor {p : ℕ} [Fact p.Prime] (hp2 : p ≠ 2)
    (hp229 : p ≠ 229) :
    (∃! x : ZMod p, cub x = 0) ↔ ¬ IsSquare ((p : ℤ) : ZMod 229) := by
  rw [existsUnique_root_iff hp2 hp229]
  have h1 : ((229 : ℤ) : ZMod p) ≠ 0 := by exact_mod_cast n229_ne_zero_zmod hp229
  have h2 : ((p : ℤ) : ZMod 229) ≠ 0 := by
    intro h
    rw [Int.cast_natCast, ZMod.natCast_eq_zero_iff] at h
    exact hp229 ((Nat.prime_dvd_prime_iff_eq (by norm_num) (Fact.out : p.Prime)).1 h).symm
  have hrec : legendreSym p 229 = legendreSym 229 p :=
    (legendreSym.quadratic_reciprocity_one_mod_four (p := 229) (q := p) (by norm_num) hp2)
  rw [not_iff_not, ← legendreSym.eq_one_iff 229 h2, ← hrec, legendreSym.eq_one_iff p h1]
  push_cast
  rfl

open Classical in
/-- **The type-sign coupling.**  The sign of the Frobenius of `p` read off from the root
count of `x³ - 4x + 1` (`-1` iff exactly one root) equals the Legendre symbol
`(p / 229)`.  This is precisely the coupling `sign σ = χ(p mod 229)` of the Chebotarev
fibre-product model in `Combinatorics.S3TypeChannelLaw`. -/
theorem typeSign_eq_legendreSym {p : ℕ} [Fact p.Prime] (hp2 : p ≠ 2) (hp229 : p ≠ 229) :
    (if ∃! x : ZMod p, cub x = 0 then (-1 : ℤ) else 1) = legendreSym 229 p := by
  have h2 : ((p : ℤ) : ZMod 229) ≠ 0 := by
    intro h
    rw [Int.cast_natCast, ZMod.natCast_eq_zero_iff] at h
    exact hp229 ((Nat.prime_dvd_prime_iff_eq (by norm_num) (Fact.out : p.Prime)).1 h).symm
  rw [existsUnique_root_iff_conductor hp2 hp229]
  rcases legendreSym.eq_one_or_neg_one 229 h2 with h | h
  · rw [if_neg (not_not.2 ((legendreSym.eq_one_iff 229 h2).1 h)), h]
  · have hns : ¬ IsSquare ((p : ℤ) : ZMod 229) := by
      rw [← legendreSym.eq_one_iff 229 h2, h]
      decide
    rw [if_pos hns, h]

/-- **No splitting type `1 + 1 + (double)`.**  In a domain where `229 ≠ 0`, two distinct
roots force a third root distinct from both: the number of roots is never exactly two. -/
theorem third_root_ne {K : Type*} [CommRing K] [IsDomain K] (h229 : (229 : K) ≠ 0) {r s : K}
    (hr : cub r = 0) (hs : cub s = 0) (hrs : r ≠ s) : -(r + s) ≠ r ∧ -(r + s) ≠ s := by
  have hd := disc_eq_sq hr hs hrs
  constructor
  · intro h
    apply h229
    rw [← hd, show 2 * r + s = 0 by linear_combination -h]
    ring
  · intro h
    apply h229
    rw [← hd, show r + 2 * s = 0 by linear_combination -h]
    ring

/-- **The residue branch.**  For a prime `p ∉ {2, 229}` with `229` a square mod `p`
(equivalently `p` a quadratic residue mod `229`), a single root forces complete splitting:
three pairwise distinct roots.  Hence the splitting type is `1+1+1` or `3`, never `1+2`. -/
theorem three_roots_of_isSquare {p : ℕ} [Fact p.Prime] (hp2 : p ≠ 2) (hp229 : p ≠ 229)
    (hsq : IsSquare (229 : ZMod p)) {r : ZMod p} (hr : cub r = 0) :
    ∃ s t : ZMod p, cub s = 0 ∧ cub t = 0 ∧ r ≠ s ∧ r ≠ t ∧ s ≠ t := by
  obtain ⟨s, hs, hsr⟩ :=
    exists_second_root (two_ne_zero_zmod hp2) (n229_ne_zero_zmod hp229) hr hsq
  have hrs : r ≠ s := fun h => hsr h.symm
  obtain ⟨h1, h2⟩ := third_root_ne (n229_ne_zero_zmod hp229) hr hs hrs
  exact ⟨s, -(r + s), hs, third_root hr hs hrs, hrs, fun h => h1 h.symm, fun h => h2 h.symm⟩

/-- **The residue class does not determine the type.**  The primes `3` and `461 = 3 + 2·229`
lie in the same class mod `229`, yet `x³ - 4x + 1` is inert mod `3` (type `3`, no root) and
splits completely mod `461` (roots `162, 368, 392`).  So knowing `p mod 229` leaves genuine
uncertainty on the residue half: the conditional entropy `H(T | p mod 229)` is positive,
and the type-channel bit is exactly the sign bit, not the full type. -/
theorem same_class_different_type :
    (461 : ℕ) % 229 = 3 % 229 ∧ (∀ x : ZMod 3, cub x ≠ 0) ∧
      ∃ a b c : ZMod 461, cub a = 0 ∧ cub b = 0 ∧ cub c = 0 ∧ a ≠ b ∧ a ≠ c ∧ b ≠ c := by
  refine ⟨by norm_num, by unfold cub; decide, 162, 368, 392, ?_, ?_, ?_, by decide,
    by decide, by decide⟩ <;> (unfold cub; decide)

/-! ## 5. The field over `ℚ` and `ℝ`: an `S₃` cubic with three real roots -/

/-- `x³ - 4x + 1` has no rational root (reduce a primitive solution modulo `3`). -/
theorem no_rational_root (q : ℚ) : cub q ≠ 0 := by
  intro h
  have hden : (q.den : ℚ) ≠ 0 := by positivity
  have hint : q.num ^ 3 - 4 * q.num * (q.den : ℤ) ^ 2 + (q.den : ℤ) ^ 3 = 0 := by
    have hq : (q.num : ℚ) / q.den = q := Rat.num_div_den q
    have : (q.num : ℚ) ^ 3 - 4 * q.num * (q.den : ℚ) ^ 2 + (q.den : ℚ) ^ 3 = 0 := by
      rw [← hq] at h
      unfold cub at h
      field_simp at h
      linear_combination h
    exact_mod_cast this
  have key : ∀ a b : ZMod 3, a ^ 3 - 4 * a * b ^ 2 + b ^ 3 = 0 → a = 0 ∧ b = 0 := by decide
  have hmod := congrArg (Int.cast : ℤ → ZMod 3) hint
  push_cast at hmod
  obtain ⟨ha, hb⟩ := key _ _ hmod
  rw [ZMod.intCast_zmod_eq_zero_iff_dvd] at ha
  rw [ZMod.natCast_eq_zero_iff] at hb
  have ha' : 3 ∣ q.num.natAbs := Int.ofNat_dvd_left.1 ha
  have := Nat.dvd_gcd ha' hb
  rw [q.reduced.gcd_eq_one] at this
  omega

/-- `x³ - 4x + 1` is irreducible over `ℚ`. -/
theorem irreducible_over_rat : Irreducible (X ^ 3 - C 4 * X + 1 : ℚ[X]) := by
  refine irreducible_of_degree_le_three_of_not_isRoot ?_ ?_
  · have : (X ^ 3 - C 4 * X + 1 : ℚ[X]).natDegree = 3 := by compute_degree!
    rw [this]; decide
  · intro x hx
    apply no_rational_root x
    simpa [cub] using hx

/-- The discriminant `229` is not a rational square, so the Galois group of the
irreducible cubic is the full `S₃`. -/
theorem disc_not_square_rat : ¬ IsSquare (229 : ℚ) := by
  rintro ⟨q, hq⟩
  have h : ¬ IsSquare (229 : ℤ) := by
    rintro ⟨m, hm⟩
    have hm' : m.natAbs * m.natAbs = 229 := by
      have := congrArg Int.natAbs hm
      simpa [Int.natAbs_mul] using this.symm
    have : m.natAbs ≤ 15 := by nlinarith
    interval_cases m.natAbs <;> omega
  apply h
  have := (Rat.isSquare_intCast_iff (z := 229)).1
  exact this ⟨q, by exact_mod_cast hq⟩

/-- The field is totally real: the cubic has three real roots, in `(-3, -2)`, `(0, 1)` and
`(1, 2)` (consistent with the positive discriminant `229`). -/
theorem three_real_roots :
    ∃ a b c : ℝ, a < b ∧ b < c ∧ cub a = 0 ∧ cub b = 0 ∧ cub c = 0 := by
  have hc : Continuous (fun x : ℝ => cub x) := by unfold cub; fun_prop
  obtain ⟨a, ha, ha0⟩ := intermediate_value_Ioo (show (-3 : ℝ) ≤ -2 by norm_num)
    hc.continuousOn (show (0 : ℝ) ∈ Set.Ioo (cub (-3 : ℝ)) (cub (-2 : ℝ)) by
      unfold cub; constructor <;> norm_num)
  obtain ⟨b, hb, hb0⟩ := intermediate_value_Ioo' (show (0 : ℝ) ≤ 1 by norm_num)
    hc.continuousOn (show (0 : ℝ) ∈ Set.Ioo (cub (1 : ℝ)) (cub (0 : ℝ)) by
      unfold cub; constructor <;> norm_num)
  obtain ⟨c, hc', hc0⟩ := intermediate_value_Ioo (show (1 : ℝ) ≤ 2 by norm_num)
    hc.continuousOn (show (0 : ℝ) ∈ Set.Ioo (cub (1 : ℝ)) (cub (2 : ℝ)) by
      unfold cub; constructor <;> norm_num)
  exact ⟨a, b, c, by linarith [ha.2, hb.1], by linarith [hb.2, hc'.1], ha0, hb0, hc0⟩

end S3Cubic229