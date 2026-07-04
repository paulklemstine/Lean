/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Infinitesimal kernels `μ_p` and the non-smooth stabilizer in characteristic `p`

This file generalizes the characteristic-`2` degeneration of the `SL₂ → PGL₂`
stabilizer (see `RegularUnipotentStabilizer.lean`) to *all* primes `p`.

For the group `SL_p`, the kernel of the universal cover `π : SL_p → PGL_p` is the
group scheme `μ_p` of `p`-th roots of unity, realized inside `SL_p` as the scalar
matrices `{a·I : aⁿ = 1}` with `n = p`.  The central fact powering the failure of
smoothness of the stabilizer of a regular unipotent class is that, in
characteristic `p`, the Frobenius identity `(x-1)^p = x^p - 1` forces the equation
`x^p = 1` to collapse to `(x-1)^p = 0`, i.e. to the single fat point `x = 1`.

## Main results

* `RegUnipMuP.mu_p_char_p_infinitesimal` — in characteristic `p`, the `p`-th
  roots of unity are exactly `{1}`; `μ_p` is a non-reduced (infinitesimal) group
  scheme, so the stabilizer of a regular unipotent is non-étale.
* `RegUnipMuP.det_scalar` — the determinant of the `n×n` scalar matrix `a·I` is
  `aⁿ`, so `a·I ∈ SL_n` iff `a ∈ μ_n`; this identifies the scalar (central) part
  of `SL_n` with `μ_n`.
* `RegUnipMuP.ker_pi_SLp_trivial_points` — combining the two: in characteristic
  `p`, the only `k`-point of `ker(π : SL_p → PGL_p)` is the identity, even though
  the defining equation `a^p = 1` is non-reduced.
* `RegUnipMuP.mu_p_poly_collapse` — the defining polynomial factors as
  `X^p - 1 = (X - 1)^p`, the scheme-theoretic incarnation of the point collapse.
* `RegUnipMuP.mu_p_derivative_eq_zero` / `RegUnipMuP.mu_p_not_separable` — the
  derivative of `X^p - 1` vanishes and the polynomial fails to be separable:
  `μ_p` is not étale.
* `RegUnipMuP.mu_p_coordinate_ring_finrank` — the coordinate ring
  `k[X]/(X^p - 1)` of `μ_p` has `k`-dimension exactly `p` (length `p`), so no
  length is lost even though all points but one disappear.
* `RegUnipMuP.mu_p_root_sub_one_pow` / `RegUnipMuP.mu_p_root_sub_one_ne_zero` /
  `RegUnipMuP.mu_p_coordinate_ring_not_reduced` — the coordinate ring of `μ_p`
  contains a *nonzero nilpotent* (`root - 1`, with `(root - 1)^p = 0`), so it is
  not reduced: `μ_p` is a genuinely infinitesimal group scheme.
* `RegUnipMuP.mu_p_coordinate_ring_isLocalRing` — the coordinate ring
  `k[X]/(X^p - 1)` is moreover a *local* ring, so `μ_p` is *connected*: combined
  with non-reducedness this says `μ_p` is a connected, non-reduced (infinitesimal)
  group scheme in characteristic `p`.

-- !-- Lab Notes -- !--
## Hypothesis (team: Hypothesizer)
Continuation of the main cycle.  New conjectures generated from the `SL₂` result:
  G1. The char-`2` collapse `a² = 1 ⇒ a = 1` is the `p = 2` case of a uniform
      char-`p` collapse `a^p = 1 ⇒ a = 1`.
  G2. (surprising) The number of `k`-points of the kernel `μ_p` of `SL_p → PGL_p`
      *drops* from `p` (char `≠ p`, étale) to `1` (char `p`), while the scheme
      keeps "length `p`" — the missing points hide in nilpotents.
  G3. Central membership `a·I ∈ SL_n` is governed purely by `a ∈ μ_n`
      (`det(a·I) = aⁿ`), independently of characteristic.

## Experiment (team: Experimenter)
Frobenius `sub_pow_char` gives `(x-1)^p = x^p - 1^p`; with `x^p = 1` this is `0`,
and `pow_eq_zero_iff` (valid since `p ≠ 0`) yields `x = 1`.  For G3 we compute
`det (a • I) = a ^ card(Fin n) = aⁿ` via `Matrix.det_smul`.

## Analysis (team: Analyst)
G1 and G3 are fully formal below (`mu_p_char_p_infinitesimal`, `det_scalar`).  G2
survives as the *point-count* statement `ker_pi_SLp_trivial_points`, and its full
"length `p`" incarnation is now formal too: `mu_p_coordinate_ring_finrank` shows
the coordinate ring `k[X]/(X^p - 1)` has `k`-dimension `p`, while
`mu_p_coordinate_ring_not_reduced` exhibits a nonzero nilpotent `root - 1`.  So
the `p - 1` missing points really do "hide in the nilpotents": the length stays
`p` while the reduced point set shrinks to `{1}`.

## Critique (team: Critic)
`mu_p_char_p_infinitesimal` genuinely uses `sub_pow_char` (a characteristic-`p`
theorem), not `decide`; `det_scalar` is a real determinant computation.  No
theorem is vacuous or definitional.

## Synthesis (team: PI)
The non-smoothness of the regular-unipotent stabilizer is not an `SL₂` accident:
for every prime `p` the kernel `μ_p` of the simply connected cover of `PGL_p`
becomes infinitesimal exactly in characteristic `p`.  The full picture is now
formal end-to-end: the defining equation collapses `X^p - 1 = (X - 1)^p`
(`mu_p_poly_collapse`), it is non-separable (`mu_p_not_separable`) with vanishing
derivative (`mu_p_derivative_eq_zero`), its coordinate ring keeps length `p`
(`mu_p_coordinate_ring_finrank`) yet is non-reduced
(`mu_p_coordinate_ring_not_reduced`) and *local*
(`mu_p_coordinate_ring_isLocalRing`, so `μ_p` is connected).  This is exactly the
scheme-theoretic signature of a connected, non-étale (infinitesimal) group
scheme, and hence of the failure of smoothness of `Stab_{Z(G')}(C_{u'})`.
-- !-- end Lab Notes -- !--
-/

open Matrix Polynomial

namespace RegUnipMuP

variable {k : Type*} [Field k]

/-- **Infinitesimal kernel in characteristic `p`.**  In a field of characteristic
`p` (prime), the only `p`-th root of unity is `1`: the equation `x^p = 1`
collapses, via Frobenius `(x-1)^p = x^p - 1`, to the single non-reduced point
`x = 1`.  This is the mechanism making the kernel `μ_p = ker(SL_p → PGL_p)`
non-étale, hence the stabilizer of a regular unipotent non-smooth. -/
theorem mu_p_char_p_infinitesimal (p : ℕ) [Fact p.Prime] [CharP k p] (x : k) :
    x ^ p = 1 ↔ x = 1 := by
  have hp : p ≠ 0 := (Fact.out : p.Prime).pos.ne'
  constructor
  · intro h
    have hz : (x - 1) ^ p = 0 := by rw [sub_pow_char]; simp [h]
    have hx := (pow_eq_zero_iff hp).mp hz
    linear_combination hx
  · rintro rfl; simp

/-- The determinant of the `n×n` scalar matrix `a·I` is `aⁿ`.  Hence a scalar
matrix lies in `SL_n` iff `a` is an `n`-th root of unity, identifying the scalar
(central) part of `SL_n` with `μ_n`. -/
theorem det_scalar (n : ℕ) (a : k) :
    (a • (1 : Matrix (Fin n) (Fin n) k)).det = a ^ n := by
  rw [Matrix.det_smul]
  simp

/-- A scalar matrix `a·I` lies in `SL_n` iff `a` is an `n`-th root of unity. -/
theorem scalar_mem_SL_iff (n : ℕ) (a : k) :
    (a • (1 : Matrix (Fin n) (Fin n) k)).det = 1 ↔ a ^ n = 1 := by
  rw [det_scalar]

/-- **Trivial point set of the infinitesimal kernel.**  In characteristic `p`,
the scalar matrix `a·I` lies in `SL_p` iff `a = 1`; equivalently the only
`k`-point of `ker(π : SL_p → PGL_p) = μ_p` is the identity — while the defining
equation `a^p = 1` remains non-reduced, witnessing non-smoothness. -/
theorem ker_pi_SLp_trivial_points (p : ℕ) [Fact p.Prime] [CharP k p] (a : k) :
    (a • (1 : Matrix (Fin p) (Fin p) k)).det = 1 ↔ a = 1 := by
  rw [scalar_mem_SL_iff, mu_p_char_p_infinitesimal]

/-! ### The coordinate ring of `μ_p` as an infinitesimal group scheme

The group scheme `μ_p` is `Spec` of the Hopf algebra `k[X]/(X^p - 1)`.  The
lemmas below establish the scheme-theoretic (as opposed to point-set) content of
its infinitesimality in characteristic `p`. -/

/-- **Scheme-theoretic collapse.**  In characteristic `p` the defining polynomial
of `μ_p` factors as a single `p`-fold root: `X^p - 1 = (X - 1)^p`.  This is the
polynomial-level shadow of `mu_p_char_p_infinitesimal`: all `p` roots of unity
crash together at `1`. -/
theorem mu_p_poly_collapse (p : ℕ) [Fact p.Prime] [CharP k p] :
    (X ^ p - 1 : k[X]) = (X - 1) ^ p := by
  rw [sub_pow_char]; simp

/-- The defining polynomial `X^p - 1` of `μ_p` has degree exactly `p`. -/
theorem mu_p_natDegree (p : ℕ) [Fact p.Prime] [CharP k p] :
    (X ^ p - 1 : k[X]).natDegree = p := by
  have h1 : (X ^ p - 1 : k[X]) = X ^ p - C 1 := by simp
  rw [h1, natDegree_X_pow_sub_C]

/-- The defining polynomial `X^p - 1` is nonzero. -/
theorem mu_p_ne_zero (p : ℕ) [Fact p.Prime] [CharP k p] :
    (X ^ p - 1 : k[X]) ≠ 0 := by
  have hdeg := mu_p_natDegree (k := k) p
  have hp0 : p ≠ 0 := (Fact.out : p.Prime).ne_zero
  intro h; rw [h] at hdeg; simp at hdeg; exact hp0 hdeg.symm

/-- **Vanishing derivative.**  In characteristic `p` the derivative of `X^p - 1`
is identically `0`.  A separable polynomial is coprime to its derivative, so a
nonzero polynomial whose derivative vanishes cannot be separable — the algebraic
hallmark of a non-étale scheme. -/
theorem mu_p_derivative_eq_zero (p : ℕ) [Fact p.Prime] [CharP k p] :
    derivative (X ^ p - 1 : k[X]) = 0 := by
  simp [derivative_pow]

/-- **Non-separability (non-étaleness).**  In characteristic `p` the polynomial
`X^p - 1` is not separable: since it equals `(X - 1)^p` with `p ≥ 2`, it is not
even squarefree.  Thus `μ_p = Spec k[X]/(X^p - 1)` is not étale over `k`. -/
theorem mu_p_not_separable (p : ℕ) [Fact p.Prime] [CharP k p] :
    ¬ (X ^ p - 1 : k[X]).Separable := by
  rw [mu_p_poly_collapse]
  intro hsep
  have hsq : Squarefree ((X - 1 : k[X]) ^ p) := hsep.squarefree
  have hp2 : 2 ≤ p := (Fact.out : p.Prime).two_le
  have hdvd : (X - 1 : k[X]) * (X - 1 : k[X]) ∣ (X - 1 : k[X]) ^ p := by
    rw [← pow_two]; exact pow_dvd_pow _ hp2
  have hunit : IsUnit (X - 1 : k[X]) := hsq _ hdvd
  have h0 : (X - 1 : k[X]).natDegree = 0 := Polynomial.natDegree_eq_zero_of_isUnit hunit
  have hne : (X - 1 : k[X]).natDegree = 1 := by compute_degree!
  omega

/-- **Length `p`.**  The coordinate ring `k[X]/(X^p - 1)` of `μ_p` has
`k`-dimension exactly `p`.  Even in characteristic `p`, where the reduced point
set shrinks to the single point `{1}` (`ker_pi_SLp_trivial_points`), the scheme
retains its full length `p`: the `p - 1` "missing" points survive as
infinitesimal (nilpotent) thickenings. -/
theorem mu_p_coordinate_ring_finrank (p : ℕ) [Fact p.Prime] [CharP k p] :
    Module.finrank k (AdjoinRoot (X ^ p - 1 : k[X])) = p := by
  have hne := mu_p_ne_zero (k := k) p
  rw [(AdjoinRoot.powerBasis hne).finrank, AdjoinRoot.powerBasis_dim hne,
    mu_p_natDegree]

/-- The canonical generator `root - 1` of the coordinate ring of `μ_p` is
nilpotent: `(root - 1)^p = 0`.  Indeed the root `α` satisfies `α^p = 1`, so
`(α - 1)^p = α^p - 1 = 0` by the Frobenius collapse `mu_p_poly_collapse`. -/
theorem mu_p_root_sub_one_pow (p : ℕ) [Fact p.Prime] [CharP k p] :
    (AdjoinRoot.root (X ^ p - 1 : k[X]) - 1) ^ p = 0 := by
  have key : (AdjoinRoot.root (X ^ p - 1 : k[X]) - 1) ^ p
        = (AdjoinRoot.mk (X ^ p - 1 : k[X])) ((X - 1) ^ p) := by
    rw [map_pow, map_sub, map_one, AdjoinRoot.mk_X]
  rw [key, ← mu_p_poly_collapse, AdjoinRoot.mk_self]

/-- The nilpotent `root - 1` is nonzero: were it `0`, the root would be `1`, i.e.
`X^p - 1 ∣ X - 1`, impossible for degree reasons (`p ≥ 2 > 1`). -/
theorem mu_p_root_sub_one_ne_zero (p : ℕ) [Fact p.Prime] [CharP k p] :
    (AdjoinRoot.root (X ^ p - 1 : k[X]) - 1) ≠ 0 := by
  have hp2 : 2 ≤ p := (Fact.out : p.Prime).two_le
  intro h
  have hr : AdjoinRoot.root (X ^ p - 1 : k[X]) = 1 := by rwa [sub_eq_zero] at h
  have hmk : (AdjoinRoot.mk (X ^ p - 1 : k[X])) (X - 1) = 0 := by
    rw [map_sub, map_one, AdjoinRoot.mk_X, hr, sub_self]
  rw [AdjoinRoot.mk_eq_zero] at hmk
  have hdvddeg : (X - 1 : k[X]).natDegree = 1 := by compute_degree!
  have hle := Polynomial.natDegree_le_of_dvd hmk (by
    intro hh; rw [hh] at hdvddeg; simp at hdvddeg)
  rw [mu_p_natDegree, hdvddeg] at hle
  omega

/-- **Full infinitesimal characterization.**  In characteristic `p` the
coordinate ring `k[X]/(X^p - 1)` of `μ_p` is *not reduced*: it contains the
nonzero nilpotent `root - 1`.  Combined with `mu_p_coordinate_ring_finrank`
(length `p`) and `ker_pi_SLp_trivial_points` (single `k`-point), this is the
complete scheme-theoretic statement that `μ_p = ker(π : SL_p → PGL_p)` is a
genuinely infinitesimal group scheme — the source of the non-smoothness of
`Stab_{Z(G')}(C_{u'})` on regular unipotents. -/
theorem mu_p_coordinate_ring_not_reduced (p : ℕ) [Fact p.Prime] [CharP k p] :
    ¬ IsReduced (AdjoinRoot (X ^ p - 1 : k[X])) := by
  intro hred
  have hnil : IsNilpotent (AdjoinRoot.root (X ^ p - 1 : k[X]) - 1) :=
    ⟨p, mu_p_root_sub_one_pow p⟩
  exact mu_p_root_sub_one_ne_zero p (hred.eq_zero _ hnil)

/-
**Connectedness / local ring.**  In characteristic `p` the coordinate ring
`k[X]/(X^p - 1)` of `μ_p` is a *local* ring: since `X^p - 1 = (X - 1)^p` it is
`k[X]/((X-1)^p)`, an Artinian ring with the single maximal ideal generated by the
nilpotent `root - 1`.  A group scheme with local coordinate ring is *connected*;
together with `mu_p_coordinate_ring_not_reduced` this says `μ_p` is a connected,
non-reduced (infinitesimal) group scheme in characteristic `p`.
-/
theorem mu_p_coordinate_ring_isLocalRing (p : ℕ) [Fact p.Prime] [CharP k p] :
    IsLocalRing (AdjoinRoot (X ^ p - 1 : k[X])) := by
  convert IsLocalRing.of_nonunits_add ( R := AdjoinRoot ( X ^ p - 1 : Polynomial k ) ) ( fun { x y } hx hy => ?_ ) using 1;
  · convert ( mu_p_coordinate_ring_finrank p ) |> fun h => ( Module.finrank_pos_iff.mp ( by rw [ h ] ; exact Nat.Prime.pos Fact.out ) );
    · exact fun _ => inferInstance;
    · exact fun h => Module.finite_of_finrank_pos ( by rw [ h ] ; exact Nat.Prime.pos Fact.out );
    · exact fun _ => by infer_instance;
    · exact fun h => DivisionSemiring.to_moduleIsTorsionFree
    · infer_instance;
  · -- By definition of $AdjoinRoot$, there exist polynomials $f$ and $g$ in $k[X]$ such that $x = f + (X^p - 1)$ and $y = g + (X^p - 1)$.
    obtain ⟨f, hf⟩ : ∃ f : Polynomial k, x = AdjoinRoot.mk (X ^ p - 1 : Polynomial k) f := by
      exact ⟨ Classical.choose ( Ideal.Quotient.mk_surjective x ), Eq.symm ( Classical.choose_spec ( Ideal.Quotient.mk_surjective x ) ) ⟩
    obtain ⟨g, hg⟩ : ∃ g : Polynomial k, y = AdjoinRoot.mk (X ^ p - 1 : Polynomial k) g := by
      exact ⟨ Classical.choose ( Ideal.Quotient.mk_surjective y ), Eq.symm ( Classical.choose_spec ( Ideal.Quotient.mk_surjective y ) ) ⟩;
    -- Since $x$ and $y$ are non-units, their constant terms $f(1)$ and $g(1)$ must be zero.
    have h_const_zero : f.eval 1 = 0 ∧ g.eval 1 = 0 := by
      constructor <;> contrapose! hx <;> contrapose! hy <;> simp_all +decide [ nonunits ];
      · -- Since $f$ is a polynomial with a non-zero constant term, it is coprime with $X^p - 1$.
        have h_coprime : IsCoprime f (X ^ p - 1) := by
          have h_coprime : IsCoprime f (X - 1) := by
            exact IsCoprime.symm ( Polynomial.irreducible_X_sub_C 1 |> fun h => h.coprime_iff_not_dvd.mpr fun h' => hx <| Polynomial.eval_eq_zero_of_dvd_of_eval_eq_zero h' <| by simp +decide );
          convert h_coprime.pow_right using 1 ; rw [ mu_p_poly_collapse ];
        obtain ⟨ a, b, h ⟩ := h_coprime; replace h := congr_arg ( AdjoinRoot.mk ( X ^ p - 1 ) ) h; simp_all +decide [ isUnit_iff_exists_inv ] ;
        exact False.elim ( hy ( AdjoinRoot.mk ( X ^ p - 1 ) a ) ( by rw [ mul_comm, h ] ) );
      · -- Since $g(1) \neq 0$, we can find a polynomial $h$ such that $g \cdot h \equiv 1 \pmod{X^p - 1}$.
        obtain ⟨h, hh⟩ : ∃ h : Polynomial k, g * h - 1 ∈ Ideal.span {X ^ p - 1} := by
          have h_coprime : IsCoprime g (X ^ p - 1) := by
            have h_coprime : IsCoprime g ((X - 1) ^ p) := by
              exact IsCoprime.pow_right ( IsCoprime.symm <| Polynomial.irreducible_X_sub_C 1 |> fun h => h.coprime_iff_not_dvd.mpr fun h' => hx <| Polynomial.eval_eq_zero_of_dvd_of_eval_eq_zero h' <| by simp +decide );
            convert h_coprime using 1 ; rw [ mu_p_poly_collapse ];
          rcases h_coprime with ⟨ a, b, h ⟩ ; exact ⟨ a, by rw [ Ideal.mem_span_singleton ] ; exact ⟨ -b, by linear_combination' h ⟩ ⟩ ;
        rw [ Ideal.mem_span_singleton ] at hh;
        exact isUnit_iff_exists_inv.mpr ⟨ AdjoinRoot.mk ( X ^ p - 1 ) h, by simpa [ sub_eq_iff_eq_add ] using AdjoinRoot.mk_eq_zero.mpr hh ⟩;
    -- Since $f(1) = 0$ and $g(1) = 0$, we have $f + g$ is divisible by $X - 1$.
    have h_div : (X - 1) ∣ (f + g) := by
      exact dvd_add ( Polynomial.dvd_iff_isRoot.mpr h_const_zero.1 ) ( Polynomial.dvd_iff_isRoot.mpr h_const_zero.2 );
    -- Since $(X - 1)$ divides $f + g$, we have $(f + g)^p$ is divisible by $(X - 1)^p$.
    have h_div_pow : (X - 1) ^ p ∣ (f + g) ^ p := by
      exact pow_dvd_pow_of_dvd h_div p;
    -- Since $(X - 1)^p$ divides $(f + g)^p$, we have $(f + g)^p$ is zero in the quotient ring $k[X]/(X^p - 1)$.
    have h_zero : (AdjoinRoot.mk (X ^ p - 1 : Polynomial k) (f + g)) ^ p = 0 := by
      convert AdjoinRoot.mk_eq_zero.mpr _;
      convert h_div_pow using 1;
      exact mu_p_poly_collapse p;
    intro h; have := h.pow p; simp_all +decide ;
    exact hx ( isUnit_of_dvd_one <| by simp [ ← this ] )

end RegUnipMuP