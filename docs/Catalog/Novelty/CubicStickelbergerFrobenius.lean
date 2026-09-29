/-
# Stickelberger's parity law for cubics over `𝔽_p` (the irreducible case)

Completing `CubicDiscriminantSignLaw` (the reducible case), we prove that an
*irreducible* depressed cubic `X³ + aX + b` over `𝔽_p` with non-zero discriminant has
a **square** discriminant: its Frobenius is a 3-cycle, an even permutation.

The proof is Galois-theoretic but fully elementary:

* `exists_algebraMap_of_pow_eq_self` : in any field extension `K / 𝔽_p`, an element
  fixed by the Frobenius `x ↦ x ^ p` lies in `𝔽_p` (the `p` elements of `𝔽_p` already
  exhaust the roots of `X ^ p - X`);
* `isSquare_disc_of_root_in_ext` : if the cubic has no root in `𝔽_p` but a root `r`
  in some extension `K`, then `r ↦ r ^ p ↦ r ^ {p²} ↦ r` cycles the three roots,
  so the Vandermonde `δ = (r₁-r₂)(r₁-r₃)(r₂-r₃)` is Frobenius-fixed, lies in `𝔽_p`,
  and squares to the discriminant;
* `isSquare_disc_of_no_root` : the same, with `K = 𝔽_p[X]/(f)`.
* `sign_law_Fp` : **the full sign law** — for odd `p` and `Δ ≠ 0`,
  `Δ` is a square in `𝔽_p`  ↔  `f` does not have exactly one root in `𝔽_p`.
* `trinomial_sign_law` : for `x³ + x + 1` and every prime `p ∉ {2, 31}`,
  the splitting type is `1 + 2` (exactly one root)  ↔  `-31` is a non-square mod `p`.
-/
import Novelty.CubicDiscriminantSignLaw

namespace CubicStickelbergerFrobenius

open Polynomial hiding disc
open CubicDiscriminantSignLaw

variable {p : ℕ} [hp : Fact p.Prime]

section Ext

variable {K : Type*} [Field K] [Algebra (ZMod p) K]

lemma charP_ext : CharP K p :=
  charP_of_injective_algebraMap (algebraMap (ZMod p) K).injective p

/-- An element of an extension of `𝔽_p` fixed by Frobenius lies in `𝔽_p`. -/
theorem exists_algebraMap_of_pow_eq_self (x : K) (hx : x ^ p = x) :
    ∃ c : ZMod p, algebraMap (ZMod p) K c = x := by
  classical
  by_contra h
  push_neg at h
  have hp1 := hp.out.one_lt
  set P : K[X] := X ^ p - X
  have hP0 : P ≠ 0 := FiniteField.X_pow_card_sub_X_ne_zero K hp1
  have hdeg : P.natDegree = p := FiniteField.X_pow_card_sub_X_natDegree_eq K hp1
  set S : Finset K := insert x (Finset.univ.image (algebraMap (ZMod p) K))
  have hS : S ⊆ P.roots.toFinset := by
    intro y hy
    rw [Multiset.mem_toFinset, mem_roots hP0, IsRoot, eval_sub, eval_pow, eval_X]
    rcases Finset.mem_insert.1 hy with rfl | hy
    · rw [hx, sub_self]
    · obtain ⟨c, -, rfl⟩ := Finset.mem_image.1 hy
      rw [← map_pow, ZMod.pow_card, sub_self]
  have hcard : S.card = p + 1 := by
    rw [Finset.card_insert_of_notMem, Finset.card_image_of_injective _
      (algebraMap (ZMod p) K).injective, Finset.card_univ, ZMod.card]
    intro hmem
    obtain ⟨c, -, hc⟩ := Finset.mem_image.1 hmem
    exact h c hc
  have := (Finset.card_le_card hS).trans (Multiset.toFinset_card_le _)
  have := this.trans (card_roots' P)
  omega

/-- The key Galois step: if the cubic has no root in `𝔽_p` but has a root in an
extension `K`, then its discriminant is a square in `𝔽_p`. -/
theorem isSquare_disc_of_root_in_ext (a b : ZMod p)
    (hno : ∀ x : ZMod p, cubic a b x ≠ 0) (r : K)
    (hr : r ^ 3 + algebraMap _ K a * r + algebraMap _ K b = 0) :
    IsSquare (disc a b) := by
  haveI := charP_ext (p := p) (K := K)
  set A := algebraMap (ZMod p) K a
  set B := algebraMap (ZMod p) K b
  set F := frobenius K p
  have hF : ∀ x, F x = x ^ p := fun x => frobenius_def p x
  have hFc : ∀ c : ZMod p, F (algebraMap _ K c) = algebraMap _ K c := by
    intro c; rw [hF, ← map_pow, ZMod.pow_card]
  -- roots are mapped to roots
  have hroot : ∀ x : K, x ^ 3 + A * x + B = 0 → (F x) ^ 3 + A * F x + B = 0 := by
    intro x hx
    have := congrArg F hx
    rwa [map_zero, map_add, map_add, map_mul, map_pow, hFc, hFc] at this
  -- no Frobenius-fixed root
  have hnofix : ∀ x : K, x ^ 3 + A * x + B = 0 → F x ≠ x := by
    intro x hx hfx
    obtain ⟨c, rfl⟩ := exists_algebraMap_of_pow_eq_self x ((hF x).symm.trans hfx)
    apply hno c
    apply (algebraMap (ZMod p) K).injective
    simp only [cubic, map_add, map_mul, map_pow, map_zero]
    exact hx
  set r1 := r
  set r2 := F r1
  have hr2 : r2 ^ 3 + A * r2 + B = 0 := hroot r1 hr
  have h12 : r1 ≠ r2 := fun h => hnofix r1 hr h.symm
  have hq : r1 ^ 2 + r1 * r2 + r2 ^ 2 + A = 0 := by
    have : (r1 - r2) * (r1 ^ 2 + r1 * r2 + r2 ^ 2 + A) = 0 := by
      linear_combination hr - hr2
    exact (mul_eq_zero.1 this).resolve_left (sub_ne_zero.2 h12)
  set r3 := -r1 - r2
  have hA : A = -(r1 ^ 2 + r1 * r2 + r2 ^ 2) := by linear_combination hq
  have hB : B = -r1 ^ 3 - A * r1 := by linear_combination hr
  have hfac : ∀ x : K, x ^ 3 + A * x + B = (x - r1) * (x - r2) * (x - r3) := by
    intro x
    rw [hB, hA]; ring
  set δ := (r1 - r2) * (r1 - r3) * (r2 - r3)
  have hδ2 : δ * δ = algebraMap (ZMod p) K (disc a b) := by
    simp only [disc, map_sub, map_mul, map_pow, map_neg, map_ofNat]
    change δ * δ = -4 * A ^ 3 - 27 * B ^ 2
    rw [hB, hA]; ring
  -- Frobenius on r2 is a root different from r2
  set s := F r2
  have hs : (s - r1) * (s - r2) * (s - r3) = 0 := by rw [← hfac]; exact hroot r2 hr2
  have hs2 : s ≠ r2 := hnofix r2 hr2
  have hF3 : F r3 = -r2 - s := by
    change F (-r1 - r2) = -r2 - s
    rw [map_sub, map_neg]
  have hδfix : F δ = δ := by
    rcases mul_eq_zero.1 hs with h | h
    · rcases mul_eq_zero.1 h with h1 | h1
      · -- `s = r1`: then `r3` would be fixed
        exfalso
        have hsr1 : s = r1 := sub_eq_zero.1 h1
        have hr3 : r3 ^ 3 + A * r3 + B = 0 := by rw [hfac]; ring
        apply hnofix r3 hr3
        rw [hF3, hsr1]; ring
      · exact absurd (sub_eq_zero.1 h1) hs2
    · have hsr3 : s = r3 := sub_eq_zero.1 h
      have : F r3 = r1 := by rw [hF3, hsr3]; ring
      simp only [δ, map_mul, map_sub, this]
      change (r2 - s) * (r2 - r1) * (s - r1) = _
      rw [hsr3]; ring
  obtain ⟨c, hc⟩ := exists_algebraMap_of_pow_eq_self δ ((hF δ).symm.trans hδfix)
  refine ⟨c, (algebraMap (ZMod p) K).injective ?_⟩
  rw [map_mul, hc, hδ2]

end Ext

/-- The cubic as a polynomial over `𝔽_p`. -/
noncomputable def cubicPoly (a b : ZMod p) : (ZMod p)[X] := X ^ 3 + C a * X + C b

lemma cubicPoly_natDegree (a b : ZMod p) : (cubicPoly a b).natDegree = 3 := by
  unfold cubicPoly; compute_degree!

/-- **Irreducible case.**  A depressed cubic over `𝔽_p` with no root in `𝔽_p` has
square discriminant (its Frobenius is a 3-cycle).  No separability hypothesis is
needed: an irreducible cubic over a finite field is automatically separable. -/
theorem isSquare_disc_of_no_root (a b : ZMod p)
    (hno : ∀ x : ZMod p, cubic a b x ≠ 0) : IsSquare (disc a b) := by
  have hirr : Irreducible (cubicPoly a b) := by
    refine irreducible_of_degree_le_three_of_not_isRoot ?_ ?_
    · rw [cubicPoly_natDegree]; decide
    · intro x hx
      apply hno x
      simpa [cubicPoly, cubic, IsRoot] using hx
  haveI : Fact (Irreducible (cubicPoly a b)) := ⟨hirr⟩
  refine isSquare_disc_of_root_in_ext (K := AdjoinRoot (cubicPoly a b)) a b hno
    (AdjoinRoot.root (cubicPoly a b)) ?_
  have := AdjoinRoot.eval₂_root (cubicPoly a b)
  simpa [cubicPoly, AdjoinRoot.algebraMap_eq] using this

/-- **Stickelberger's sign law for cubics over `𝔽_p`.**  For an odd prime `p` and a
depressed cubic with non-zero discriminant, the discriminant is a square iff the
cubic does *not* have exactly one root in `𝔽_p`; i.e. the Frobenius is odd
(a transposition, type `1 + 2`) iff `Δ` is a non-square. -/
theorem sign_law_Fp (hp2 : p ≠ 2) (a b : ZMod p) (hΔ : disc a b ≠ 0) :
    ¬ IsSquare (disc a b) ↔ ∃ r, cubic a b r = 0 ∧ ∀ s, cubic a b s = 0 → s = r := by
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro h
    have : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
    rw [ZMod.natCast_eq_zero_iff] at this
    exact hp2 ((Nat.prime_dvd_prime_iff_eq hp.out Nat.prime_two).1 this)
  constructor
  · intro hns
    by_cases hex : ∃ r, cubic a b r = 0
    · obtain ⟨r, hr⟩ := hex
      exact ⟨r, hr, unique_root_of_not_isSquare h2 a b r hr hns⟩
    · push_neg at hex
      exact absurd (isSquare_disc_of_no_root a b hex) hns
  · rintro ⟨r, hr, huniq⟩ hsq
    obtain ⟨s, hsr, hs⟩ := (isSquare_disc_iff h2 a b r hr hΔ).1 hsq
    exact hsr (huniq s hs)

/-- **The sign law for `x³ + x + 1`.**  For every prime `p ∉ {2, 31}`, `x³ + x + 1`
has exactly one root mod `p` (odd Frobenius) iff `-31` is a non-square mod `p`.
Its sign character is the quadratic character of `-31`, not a character mod `3`. -/
theorem trinomial_sign_law (hp2 : p ≠ 2) (hp31 : p ≠ 31) :
    (∃ r : ZMod p, r ^ 3 + r + 1 = 0 ∧ ∀ s : ZMod p, s ^ 3 + s + 1 = 0 → s = r) ↔
      ¬ IsSquare (-31 : ZMod p) := by
  have hdisc : disc (1 : ZMod p) 1 = -31 := by simp [disc]; ring
  have h31 : (31 : ZMod p) ≠ 0 := by
    intro h
    have : ((31 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
    rw [ZMod.natCast_eq_zero_iff] at this
    exact hp31 ((Nat.prime_dvd_prime_iff_eq hp.out (by norm_num)).1 this)
  have key := sign_law_Fp hp2 (1 : ZMod p) 1 (by rw [hdisc]; exact neg_ne_zero.2 h31)
  rw [hdisc] at key
  rw [key]
  simp [cubic]

/-- **The sign law for `x³ - 2`.**  For every prime `p ∉ {2, 3}`, `x³ - 2` has exactly
one root mod `p` iff `-108` is a non-square mod `p`. -/
theorem pure_cubic_sign_law (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    (∃ r : ZMod p, r ^ 3 = 2 ∧ ∀ s : ZMod p, s ^ 3 = 2 → s = r) ↔
      ¬ IsSquare (-108 : ZMod p) := by
  have hdisc : disc (0 : ZMod p) (-2) = -108 := by simp [disc]; ring
  have hne : ∀ q : ℕ, q.Prime → q ≠ p → (q : ZMod p) ≠ 0 := by
    intro q hq hqp h
    rw [ZMod.natCast_eq_zero_iff] at h
    exact hqp ((Nat.prime_dvd_prime_iff_eq hp.out hq).1 h).symm
  have h108 : (108 : ZMod p) ≠ 0 := by
    have : (108 : ZMod p) = ((2 : ℕ) : ZMod p) ^ 2 * ((3 : ℕ) : ZMod p) ^ 3 := by
      push_cast; norm_num
    rw [this]
    exact mul_ne_zero (pow_ne_zero _ (hne 2 Nat.prime_two (Ne.symm hp2)))
      (pow_ne_zero _ (hne 3 Nat.prime_three (Ne.symm hp3)))
  have key := sign_law_Fp hp2 (0 : ZMod p) (-2) (by rw [hdisc]; exact neg_ne_zero.2 h108)
  rw [hdisc] at key
  rw [key]
  have e : ∀ x : ZMod p, cubic 0 (-2) x = 0 ↔ x ^ 3 = 2 := by
    intro x; simp only [cubic, zero_mul, add_zero]
    constructor <;> intro h <;> linear_combination h
  simp only [e]

end CubicStickelbergerFrobenius