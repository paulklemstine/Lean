/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Cycle 2: the sign is the parity of the central order of vanishing

`EigenvalueModel.lean` computed the functional-equation sign of a duality eigensystem as

  `ε = (−1)^{d + #neg-fixed}`.

That formula refers to the duality permutation.  This file eliminates `σ` from the answer
entirely and proves the **intrinsic** law

  `ε = (−1)^{m₊}`,   `m₊ := #{ i : α_i = Q }`,

where `m₊` is the multiplicity of the "central" eigenvalue `α = q^{n/2}`.  Since
`P(T) = ∏ (1 - α_i T)` vanishes at the central point `T = Q⁻¹` to order exactly `m₊`
(`charPoly_factor_central`, `centralFactor_ne_zero`), this says:

> **the sign of the functional equation is the parity of the order of vanishing at the
> central point** —

the exact function-field analogue of the parity statement proved analytically for
`Λ(2 - s) = w Λ(s)` in `Catalog/Applications/BSD/FunctionalEquation.lean`
(`analyticRank_parity`).  There the input was Taylor symmetry of an analytic function;
here it is a purely combinatorial pairing of Frobenius eigenvalues.  The two theorems are
the archimedean and the finite-field faces of one statement.

The bridge from cycle 1 is a `ℤ/2` count (`even_deg_add_negFixed_add_centralOrder`):
duality 2-cycles contribute evenly to *both* `d` and `m₊`, `+Q` fixed points contribute
oddly to both, and `−Q` fixed points contribute `1` to `d` and `1` to `#neg-fixed`.  The
hypothesis `−1 ≠ 1` is necessary and sharp: in characteristic `2` the two fixed-point
types coincide and the bookkeeping collapses.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): `ε` should not depend on `σ` at all — `σ` is auxiliary data,
  while the multiset `{α_i}` is intrinsic.  The only intrinsic `ℤ/2` invariant available
  is the multiplicity of the self-dual eigenvalue `+Q`.
Experiment (Experimenter): count.  Split `ι` into `Fix(σ)` and its complement `R`.  On
  `R`, `σ` is a free involution, so `|R|` is even; and `{α_i = Q}` is `σ`-stable
  (`α_i = Q ⟹ α_{σ i} = Q²/Q = Q`), so its intersection with `R` is also even.  The two
  even contributions cancel mod `2` and leave `m₊ ≡ |Fix₊|` and `d + #neg ≡ |Fix₊|`.
Analysis (Analyst): the same "free involution ⟹ even" principle is used twice, so it is
  isolated as `even_card_of_free_involution`; it is the combinatorial engine of the whole
  project (`Finset.prod_involution` over `ℤ` with constant value `−1`).
Critique (Critic): in characteristic `2` the statement `ε = (−1)^{m₊}` degenerates
  (`ε = 1` always), and the counting argument genuinely fails, so the theorems carry
  `hchar : (-1 : K) ≠ 1`.  The central factorisation, by contrast, needs no such
  hypothesis and is stated in full generality.
Synthesis (PI): cycle 1's sign law plus this parity bridge give a self-contained,
  σ-free statement of the conjecture: *no `−q^{n/2}` self-dual eigenvalue* forces
  `ε = (−1)^d`, and *always* `ε = (−1)^{ord_{T = q^{-n/2}} P}`.
-/
import Mathlib
import Catalog.Applications.WeilDualitySign.EigenvalueModel

open Finset
open scoped Classical

namespace WeilDualitySign

/-- **Free involutions have even orbit counts.**  If `g` is an involution of the ambient
type that maps a finset `s` into itself without fixed points on `s`, then `s` has even
cardinality.  (Proved by evaluating `∏_{a ∈ s} (-1 : ℤ)` through the pairing.) -/
theorem even_card_of_free_involution {ι : Type*} [DecidableEq ι] (s : Finset ι) (g : ι → ι)
    (hmem : ∀ a ∈ s, g a ∈ s) (hginv : ∀ a, g (g a) = a) (hfree : ∀ a ∈ s, g a ≠ a) :
    Even s.card := by
  have h1 : ∏ _a ∈ s, (-1 : ℤ) = 1 :=
    Finset.prod_involution (fun a _ => g a) (fun a _ => by norm_num)
      (fun a ha _ => hfree a ha) (fun a ha => hmem a ha) (fun a _ => hginv a)
  rw [Finset.prod_const] at h1
  rcases Nat.even_or_odd s.card with h | h
  · exact h
  · rw [h.neg_one_pow] at h1; norm_num at h1

namespace DualEigensystem

variable {K : Type*} [Field K] {ι : Type*} [Fintype ι] [DecidableEq ι]
variable (E : DualEigensystem K ι)

/-- The **central multiplicity** `m₊ = #{i : α_i = Q}`: the multiplicity of the self-dual
eigenvalue `+q^{n/2}`, equivalently the order of vanishing of `P` at `T = Q⁻¹`. -/
noncomputable def centralOrder : ℕ := by
  classical
  exact (univ.filter (fun i => E.α i = E.Q)).card

/-! ### The central eigenvalue set is duality-stable -/

/-- Duality preserves the central eigenvalue: if `α_i = Q` then `α_{σ i} = Q`. -/
theorem alpha_sigma_eq_Q {i : ι} (h : E.α i = E.Q) : E.α (E.σ i) = E.Q := by
  have hd := E.duality i
  rw [h] at hd
  have hQ := E.Q_ne_zero
  field_simp at hd
  linear_combination hd

/-- The non-fixed indices come in duality pairs, so there is an even number of them. -/
theorem even_card_nonfixed :
    Even ((univ.filter (fun i => ¬ E.σ i = i)).card) := by
  classical
  refine even_card_of_free_involution _ (fun i => E.σ i) ?_ E.σ_involutive ?_
  · intro a ha
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha ⊢
    rw [E.σ_involutive a]
    exact fun hh => ha hh.symm
  · intro a ha
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha
    exact ha

/-- The non-fixed indices carrying the central eigenvalue also come in duality pairs. -/
theorem even_card_nonfixed_central :
    Even ((univ.filter (fun i => ¬ E.σ i = i ∧ E.α i = E.Q)).card) := by
  classical
  refine even_card_of_free_involution _ (fun i => E.σ i) ?_ E.σ_involutive ?_
  · intro a ha
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha ⊢
    obtain ⟨h1, h2⟩ := ha
    refine ⟨?_, E.alpha_sigma_eq_Q h2⟩
    rw [E.σ_involutive a]
    exact fun hh => h1 hh.symm
  · intro a ha
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha
    exact ha.1

/-! ### The `ℤ/2` bridge -/

/-- **Counting bridge.**  Modulo `2`, the degree plus the number of `−Q` fixed points
agrees with the central multiplicity.  (Needs `−1 ≠ 1`: in characteristic `2` the two
kinds of fixed point are the same point.) -/
theorem even_deg_add_negFixed_add_centralOrder (hchar : (-1 : K) ≠ 1) :
    Even (E.deg + E.negFixed.card + E.centralOrder) := by
  classical
  have hQne : E.Q ≠ -E.Q := by
    intro h
    apply hchar
    have h2 : (2 : K) * E.Q = 0 := by linear_combination h
    rcases mul_eq_zero.mp h2 with h3 | h3
    · linear_combination -h3
    · exact absurd h3 E.Q_ne_zero
  -- split the index set into fixed and non-fixed indices
  have hsplit : (univ.filter (fun i => E.σ i = i)).card
      + (univ.filter (fun i => ¬ E.σ i = i)).card = E.deg := by
    rw [Finset.card_filter_add_card_filter_not (s := (univ : Finset ι))
      (p := fun i => E.σ i = i)]
    simp [deg]
  -- split the fixed indices according to the sign of their eigenvalue
  have hNF : E.negFixed = univ.filter (fun i => E.σ i = i ∧ ¬ E.α i = E.Q) := by
    ext i
    simp only [E.mem_negFixed, Finset.mem_filter, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨h1, h2⟩
      refine ⟨h1, ?_⟩
      rw [h2]
      intro h3
      exact hQne h3.symm
    · rintro ⟨h1, h2⟩
      exact ⟨h1, (E.fixed_alpha_eq_pos_or_neg h1).resolve_left h2⟩
  have hfix : (univ.filter (fun i => E.σ i = i ∧ E.α i = E.Q)).card
      + E.negFixed.card = (univ.filter (fun i => E.σ i = i)).card := by
    have hc := Finset.card_filter_add_card_filter_not
      (s := univ.filter (fun i => E.σ i = i)) (p := fun i => E.α i = E.Q)
    rw [Finset.filter_filter, Finset.filter_filter] at hc
    rw [hNF]
    exact hc
  -- split the central set according to fixedness
  have hcentral : (univ.filter (fun i => E.σ i = i ∧ E.α i = E.Q)).card
      + (univ.filter (fun i => ¬ E.σ i = i ∧ E.α i = E.Q)).card = E.centralOrder := by
    rw [centralOrder, ← Finset.card_union_of_disjoint (s := univ.filter
        (fun i => E.σ i = i ∧ E.α i = E.Q))
      (t := univ.filter (fun i => ¬ E.σ i = i ∧ E.α i = E.Q)) ?_]
    · congr 1
      ext i
      by_cases h : E.σ i = i <;> simp [h]
    · refine Finset.disjoint_left.mpr ?_
      intro a ha hb
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha hb
      exact hb.1 ha.1
  obtain ⟨k, hk⟩ := E.even_card_nonfixed
  obtain ⟨l, hl⟩ := E.even_card_nonfixed_central
  refine ⟨(univ.filter (fun i => E.σ i = i ∧ E.α i = E.Q)).card + E.negFixed.card + k + l, ?_⟩
  omega

/-- Two `ℤ`-powers of `−1` agree once the exponents have the same parity. -/
private theorem neg_one_pow_congr {a b : ℕ} (h : Even (a + b)) :
    (-1 : K) ^ a = (-1 : K) ^ b := by
  rcases Nat.even_or_odd a with ha | ha
  · have hb : Even b := by
      rcases h with ⟨k, hk⟩; rcases ha with ⟨m, hm⟩
      exact ⟨k - m, by omega⟩
    rw [ha.neg_one_pow, hb.neg_one_pow]
  · have hb : Odd b := by
      rcases h with ⟨k, hk⟩; rcases ha with ⟨m, hm⟩
      exact ⟨k - m - 1, by omega⟩
    rw [ha.neg_one_pow, hb.neg_one_pow]

/-- **Cycle-2 headline: the sign is the parity of the central multiplicity.**

  `ε = (−1)^{m₊}`,  `m₊ = #{i : α_i = q^{n/2}}`.

The duality permutation has disappeared from the statement: only the multiset of
eigenvalues matters. -/
theorem rootSign_eq_neg_one_pow_centralOrder (hchar : (-1 : K) ≠ 1) :
    E.rootSign = (-1 : K) ^ E.centralOrder := by
  rw [E.rootSign_eq]
  exact neg_one_pow_congr (by
    have h := E.even_deg_add_negFixed_add_centralOrder hchar
    rcases h with ⟨k, hk⟩
    exact ⟨k, by omega⟩)

/-! ### The central point: factorisation and vanishing -/

/-- The non-central part of the characteristic polynomial,
`G(T) = ∏_{α_i ≠ Q} (1 - α_i T)`. -/
noncomputable def centralFactor (T : K) : K := by
  classical
  exact ∏ i ∈ univ.filter (fun i => ¬ E.α i = E.Q), (1 - E.α i * T)

/-- **Central factorisation.**  `P(T) = (1 - Q T)^{m₊} · G(T)`: the characteristic
polynomial splits off exactly `m₊` copies of the central factor. -/
theorem charPoly_factor_central (T : K) :
    E.charPoly T = (1 - E.Q * T) ^ E.centralOrder * E.centralFactor T := by
  classical
  rw [charPoly, centralFactor, centralOrder,
    ← Finset.prod_filter_mul_prod_filter_not (univ : Finset ι) (fun i => E.α i = E.Q)]
  congr 1
  rw [← Finset.prod_const]
  exact Finset.prod_congr rfl fun i hi => by
    simp only [Finset.mem_filter] at hi
    rw [hi.2]

/-- The non-central part does **not** vanish at the central point `T = Q⁻¹`: the order of
vanishing of `P` at `Q⁻¹` is exactly `m₊`. -/
theorem centralFactor_ne_zero : E.centralFactor E.Q⁻¹ ≠ 0 := by
  classical
  rw [centralFactor]
  refine Finset.prod_ne_zero_iff.mpr fun i hi => ?_
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi
  intro h
  apply hi
  have hQ := E.Q_ne_zero
  field_simp at h
  linear_combination -h

/-- **Function-field parity conjecture (eigenvalue model).**  The root sign is `−1`
exactly when the characteristic polynomial vanishes at the central point to *odd* order;
in particular sign `−1` forces central vanishing `P(Q⁻¹) = 0`, and sign `+1` forbids odd
vanishing.  This is the finite-field mirror of the analytic parity theorem
`BSD.FunctionalEquation.analyticRank_parity`. -/
theorem rootSign_neg_one_iff_odd_centralOrder (hchar : (-1 : K) ≠ 1) :
    E.rootSign = -1 ↔ Odd E.centralOrder := by
  rw [E.rootSign_eq_neg_one_pow_centralOrder hchar]
  constructor
  · intro h
    rcases Nat.even_or_odd E.centralOrder with he | ho
    · rw [he.neg_one_pow] at h
      exact absurd h.symm (by simpa using hchar)
    · exact ho
  · intro h
    exact h.neg_one_pow

/-- **Sign `−1` forces central vanishing.**  If the functional equation has sign `−1`,
then `P(Q⁻¹) = 0`: the zeta factor vanishes at the central point.  (Compare
`BSD.FunctionalEquation.central_vanishing_of_sign_neg_one`.) -/
theorem charPoly_central_eq_zero_of_rootSign_neg (hchar : (-1 : K) ≠ 1)
    (h : E.rootSign = -1) : E.charPoly E.Q⁻¹ = 0 := by
  have hodd : Odd E.centralOrder := (E.rootSign_neg_one_iff_odd_centralOrder hchar).mp h
  have hpos : 0 < E.centralOrder := hodd.pos
  rw [E.charPoly_factor_central]
  have h1 : (1 : K) - E.Q * E.Q⁻¹ = 0 := by
    rw [mul_inv_cancel₀ E.Q_ne_zero, sub_self]
  rw [h1, zero_pow (by omega), zero_mul]

/-- **Under the mission hypothesis the parity is that of the degree.**  With no `−Q`
fixed point, the central multiplicity has the same parity as the degree; so the zeta
factor vanishes at the central point to odd order exactly when `d` is odd. -/
theorem centralOrder_parity_of_no_neg_fixed (hchar : (-1 : K) ≠ 1)
    (hno : ∀ i, E.σ i = i → E.α i ≠ -E.Q) :
    ((-1 : K) ^ E.centralOrder = (-1 : K) ^ E.deg) := by
  rw [← E.rootSign_eq_neg_one_pow_centralOrder hchar, E.rootSign_eq_neg_one_pow_deg hno]

end DualEigensystem

end WeilDualitySign