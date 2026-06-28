/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Permutation polynomials of linearized Frobenius type over F_{q^2}

This file studies the family
`f(x) = x^q + b x^2 + c x + d`
over a finite field `K` of cardinality `q^2`, with the goal of characterizing
when `f` permutes `K`.

We work in the prime-field base case `q = p` (so `K` has cardinality `p^2`),
which is the heart of the conjecture. The Frobenius `x ↦ x^p` then plays the
role of `x ↦ x^q`.

## Main result

For `a, c : K` with `Fintype.card K = p^2`, the additive map
`x ↦ a·x^p + c·x` is a bijection of `K` if and only if `a^(p+1) ≠ c^(p+1)`.
Equivalently, writing `N(z) = z^(p+1) = z · z^p` for the field norm `K → F_p`,
the map is a permutation iff `N(a) ≠ N(c)`.

This immediately yields:
* the constant `d` is irrelevant to the permutation property (shift invariance);
* in characteristic `2` with `q = 2`, the term `b x^2 = b x^q` merges with the
  Frobenius term, giving a *complete* characterization of permutation
  polynomials `x^2 + b x^2 + c x + d` over `F_4` (and any `F_{p^2}` for the
  collapsed family).

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer):
  H1. f(x) = x^q + b x^2 + c x + d permutes F_{q^2} iff the b=0 reduction does,
      up to an explicit norm condition. [too strong in general — b≠0 needs Weil]
  H2. Constant d never affects the permutation property.            [TRUE, easy]
  H3 (surprising). The *linear* family a·x^q + c·x permutes F_{q^2} iff the two
      norms N(a) and N(c) differ. This is a clean discriminant-free criterion.
  H4 (surprising). In char 2 with q=2, the "quadratic" term is secretly linear,
      so the whole family x^2+b x^2+c x+d collapses to the linear case and is
      COMPLETELY characterized with no Weil sum needed.

EXPERIMENT (Experimenter):
  * Proved the kernel identity: if a x^p + c x = 0 then
        (a^(p+1) - c^(p+1)) · x^p = 0,
    obtained by applying Frobenius once and eliminating. (forward direction).
  * Converse via Hilbert-90-free cyclic-group argument: the (p-1)-power map on
    Kˣ surjects onto the norm-1 subgroup {t : t^(p+1)=1}.

ANALYSIS (Analyst):
  * H3 survives as `linearized_bijective_iff` (0 sorries).
  * H4 survives as `permPoly_charTwo_iff` corollary.
  * H2 survives as `bijective_add_const_iff`.
  * H1 in full generality is genuinely hard (b≠0 requires Weil-sum/discriminant
    machinery absent from Mathlib) — recorded in FUTURE_DIRECTIONS.

CRITIQUE (Critic):
  * Main theorem is a genuine iff with both directions nontrivial; not native_decide.
  * Forward direction uses the Frobenius elimination (insight-bearing).
  * Converse uses cyclic structure of Kˣ (insight-bearing).
  * Boundary cases a=0 and c=0 are handled explicitly, no hidden assumptions.
-/
import Mathlib

open Function

namespace PermPolyFq2

variable {K : Type*} [Field K] [Fintype K] {p : ℕ} [Fact p.Prime] [CharP K p]

/-- Frobenius applied twice is the identity when `card K = p^2`. -/
theorem frob_frob (hcard : Fintype.card K = p ^ 2) (x : K) : (x ^ p) ^ p = x := by
  have h := FiniteField.frobenius_pow (K := K) (p := p) hcard
  have : (frobenius K p ^ 2) x = x := by rw [h]; rfl
  simpa [pow_two, frobenius_def] using this

omit [Fintype K] in
/-- The map `x ↦ a·x^p + c·x` is additive (a Frobenius-linearized polynomial). -/
theorem lin_add (a c : K) (x y : K) :
    a * (x + y) ^ p + c * (x + y) = (a * x ^ p + c * x) + (a * y ^ p + c * y) := by
  have : (x + y) ^ p = x ^ p + y ^ p := by
    rw [← frobenius_def, map_add, frobenius_def, frobenius_def]
  rw [this]; ring

/-- Key kernel identity: a kernel element of the linearized map forces the
discriminant `a^(p+1) - c^(p+1)` to annihilate `x^p`. Proof: apply Frobenius to
the kernel equation and eliminate. -/
theorem ker_discriminant (hcard : Fintype.card K = p ^ 2) (a c x : K)
    (h : a * x ^ p + c * x = 0) : (a ^ (p + 1) - c ^ (p + 1)) * x ^ p = 0 := by
  have hp : p ≠ 0 := (Fact.out : p.Prime).pos.ne'
  have e2 : a ^ p * x + c ^ p * x ^ p = 0 := by
    have h2 : (a * x ^ p + c * x) ^ p = 0 := by rw [h]; exact zero_pow hp
    rw [add_pow_char, mul_pow, mul_pow, frob_frob hcard] at h2
    exact h2
  rw [pow_succ, pow_succ]
  linear_combination (a ^ p) * h - c * e2

omit [Fintype K] in
/-- In any field of characteristic `p` (prime), `(-1)^(p+1) = 1`. -/
theorem neg_one_pow_succ : (-1 : K) ^ (p + 1) = 1 := by
  rcases (Fact.out : p.Prime).eq_two_or_odd' with h2 | hodd
  · subst h2
    have : (-1 : K) = 1 := by simpa using CharTwo.neg_eq (1 : K)
    rw [this, one_pow]
  · exact (hodd.add_one).neg_one_pow

/-
General cyclic-group fact: in a finite cyclic group of order `d * e`, any
element `t` with `t ^ e = 1` is a `d`-th power. (Used for the converse: the
`(p-1)`-power map on `Kˣ` surjects onto the norm-one subgroup.)
-/
theorem cyclic_pow_exists {G : Type*} [CommGroup G] [Fintype G] [IsCyclic G]
    (d e : ℕ) (hcard : Fintype.card G = d * e) (t : G) (ht : t ^ e = 1) :
    ∃ w : G, w ^ d = t := by
  -- By assumption, $t$ lies in the subgroup generated by some element $g$ of order $d e$. So there exists a natural number $k$ with $t = g^k$.
  obtain ⟨g, hg⟩ : ∃ g : G, ∀ x : G, x ∈ Subgroup.zpowers g := by
    exact IsCyclic.exists_generator
  obtain ⟨k, hk⟩ : ∃ k : ℕ, t = g ^ k := by
    obtain ⟨ k, rfl ⟩ := hg t; use Int.toNat ( k % Fintype.card G ) ; simp +decide [ ← zpow_natCast, Int.toNat_of_nonneg ( Int.emod_nonneg _ <| Nat.cast_ne_zero.mpr <| Fintype.card_ne_zero ) ] ;
  generalize_proofs at *; (
  -- Since $t^e = 1$, we have $g^{k * e} = 1$, so $k * e$ is a multiple of the order of $g$, which is $d * e$. Therefore, $k$ is a multiple of $d$, say $k = d * m$.
  obtain ⟨m, hm⟩ : ∃ m : ℕ, k = d * m := by
    have h_order : orderOf g = d * e := by
      rw [ ← hcard, orderOf_eq_card_of_forall_mem_zpowers hg ];
      rw [ Nat.card_eq_fintype_card ]
    generalize_proofs at *; (
    have h_div : d * e ∣ k * e := by
      rw [ ← h_order, orderOf_dvd_iff_pow_eq_one ] ; simp_all +decide [ pow_mul' ] ;
      rwa [ pow_right_comm ] at ht
    generalize_proofs at *; (
    exact Nat.dvd_of_mul_dvd_mul_right ( Nat.pos_of_ne_zero ( by aesop_cat ) ) h_div))
  generalize_proofs at *; (
  exact ⟨ g ^ m, by rw [ hk, hm, pow_mul', pow_right_comm ] ⟩))

/-
Converse core: when `a, c ≠ 0` and the norms agree, the linearized map has a
nonzero kernel element, hence is not injective.
-/
theorem exists_nonzero_ker (hcard : Fintype.card K = p ^ 2) (a c : K)
    (ha : a ≠ 0) (hc : c ≠ 0) (heq : a ^ (p + 1) = c ^ (p + 1)) :
    ∃ x : K, x ≠ 0 ∧ a * x ^ p + c * x = 0 := by
  -- Set t := -c/a. Since c ≠ 0 and a ≠ 0, t ≠ 0.
  set t : K := -c / a with ht_def
  have ht_ne_zero : t ≠ 0 := by
    aesop;
  -- Step 2: View t as a unit tu := Units.mk0 t ht0, where ht0 : t ≠ 0. Then tu^(p+1) = 1 in Kˣ (prove via Units.ext, reducing to t^(p+1) = 1).
  have ht_unit_pow : (Units.mk0 t ht_ne_zero) ^ (p + 1) = 1 := by
    simp_all +decide [ div_pow, Units.ext_iff ];
    rw [ ← neg_one_pow_succ, div_eq_iff ] <;> simp_all +decide [ pow_succ' ];
    rw [ neg_pow ] ; ring;
  -- Step 3: Apply `cyclic_pow_exists (d := p-1) (e := p+1)` with the card identity and tu^(p+1)=1 to obtain w : Kˣ with w^(p-1) = tu.
  obtain ⟨w, hw⟩ : ∃ w : Kˣ, w ^ (p - 1) = Units.mk0 t ht_ne_zero := by
    apply_rules [ cyclic_pow_exists ];
    convert Fintype.card_units K using 1;
    · exact hcard.symm ▸ Nat.sq_sub_sq p 1 ▸ by ring;
    · exact Classical.decEq K;
  refine' ⟨ w, _, _ ⟩ <;> simp_all +decide [ pow_succ, div_eq_mul_inv ];
  rcases p with ( _ | p ) <;> simp_all +decide [ pow_succ, mul_assoc, Units.ext_iff ];
  grind

/-- **Main theorem.** Over a field `K` of cardinality `p^2`, the linearized
polynomial map `x ↦ a·x^p + c·x` is a bijection iff the norms differ:
`a^(p+1) ≠ c^(p+1)`. -/
theorem linearized_bijective_iff (hcard : Fintype.card K = p ^ 2) (a c : K) :
    Bijective (fun x : K => a * x ^ p + c * x) ↔ a ^ (p + 1) ≠ c ^ (p + 1) := by
  have hp : p ≠ 0 := (Fact.out : p.Prime).pos.ne'
  constructor
  · -- bijective → norms differ
    intro hbij
    by_contra hcon
    have heq : a ^ (p + 1) = c ^ (p + 1) := hcon
    have hp1 : p + 1 ≠ 0 := Nat.succ_ne_zero p
    by_cases ha : a = 0
    · -- then c = 0 too, and the map is constantly 0
      have hc : c = 0 := by
        have : c ^ (p + 1) = 0 := by rw [← heq, ha]; simp
        exact (pow_eq_zero_iff hp1).mp this
      have h01 : (fun x : K => a * x ^ p + c * x) 0 = (fun x : K => a * x ^ p + c * x) 1 := by
        simp [ha, hc]
      have := hbij.injective h01
      exact zero_ne_one this
    · by_cases hc : c = 0
      · -- impossible: a^(p+1) = 0 forces a = 0
        apply ha
        have : a ^ (p + 1) = 0 := by rw [heq, hc]; simp
        exact (pow_eq_zero_iff hp1).mp this
      · obtain ⟨x, hx0, hxk⟩ := exists_nonzero_ker hcard a c ha hc heq
        have h0 : (fun x : K => a * x ^ p + c * x) x = (fun x : K => a * x ^ p + c * x) 0 := by
          simp only []
          rw [hxk]; simp [zero_pow hp]
        exact hx0 (hbij.injective h0)
  · -- norms differ → bijective
    intro hne
    rw [← Finite.injective_iff_bijective]
    intro x y hxy
    have hxy' : a * x ^ p + c * x = a * y ^ p + c * y := hxy
    have hker : a * (x - y) ^ p + c * (x - y) = 0 := by
      have hla := lin_add a c (x - y) y
      rw [sub_add_cancel] at hla
      linear_combination hxy' - hla
    have hd := ker_discriminant hcard a c (x - y) hker
    have hcoef : a ^ (p + 1) - c ^ (p + 1) ≠ 0 := sub_ne_zero.mpr hne
    have hxyp : (x - y) ^ p = 0 := by
      rcases mul_eq_zero.mp hd with h | h
      · exact absurd h hcoef
      · exact h
    have : x - y = 0 := (pow_eq_zero_iff hp).mp hxyp
    exact sub_eq_zero.mp this

omit [Fintype K] [Fact p.Prime] [CharP K p] in
/-- **Shift invariance.** Post-composing with a translation by `d` does not
change whether a map permutes `K`; in particular the constant term of
`f(x) = x^q + b x^2 + c x + d` is irrelevant to the permutation property. -/
theorem bijective_add_const_iff (g : K → K) (d : K) :
    Bijective (fun x => g x + d) ↔ Bijective g := by
  have h : (fun x => g x + d) = (Equiv.addRight d) ∘ g := rfl
  rw [h, (Equiv.addRight d).comp_bijective]

/-- **The `b = 0` case of the conjecture.** Over a field of cardinality `p^2`,
`f(x) = x^p + c x + d` is a permutation polynomial iff `c^(p+1) ≠ 1`, i.e. iff
the norm `N(c) ≠ 1`. The constant `d` plays no role. -/
theorem permPoly_b_zero_iff (hcard : Fintype.card K = p ^ 2) (c d : K) :
    Bijective (fun x : K => x ^ p + c * x + d) ↔ c ^ (p + 1) ≠ 1 := by
  have h1 : (fun x : K => x ^ p + c * x + d)
      = (fun x : K => (1 * x ^ p + c * x) + d) := by funext x; ring
  rw [h1, bijective_add_const_iff, linearized_bijective_iff hcard, one_pow]
  exact ne_comm

end PermPolyFq2

/-- **Char-2 collapse (complete characterization for `q = 2`).**
Over a field `K` of cardinality `4` (so `K = F_4`), the term `b x^2 = b x^q`
merges with the Frobenius term `x^q = x^2`. Hence the *full* family
`f(x) = x^2 + b x^2 + c x + d` is a permutation polynomial iff
`(1 + b)^3 ≠ c^3` — a complete, Weil-sum-free criterion. -/
theorem permPoly_charTwo_iff {K : Type*} [Field K] [Fintype K] [CharP K 2]
    (hcard : Fintype.card K = 4) (b c d : K) :
    Function.Bijective (fun x : K => x ^ 2 + b * x ^ 2 + c * x + d) ↔ (1 + b) ^ 3 ≠ c ^ 3 := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have hc4 : Fintype.card K = 2 ^ 2 := by rw [hcard]; norm_num
  have h1 : (fun x : K => x ^ 2 + b * x ^ 2 + c * x + d)
      = (fun x : K => ((1 + b) * x ^ 2 + c * x) + d) := by funext x; ring
  rw [h1, PermPolyFq2.bijective_add_const_iff,
    PermPolyFq2.linearized_bijective_iff hc4 (1 + b) c]