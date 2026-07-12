/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tropical extremal-support profiles of finitely supported rational sequences

**The core of this file is about finitely supported sequences `f : ℕ →₀ ℚ`.**  The
species / EGF interpretation appears only at the very end as a *downstream corollary*
(`binConv_extremal_profile`), and introduces no new species abstractions.

For a finitely supported sequence `f : ℕ →₀ ℚ` we define two extremal-support indices:

* `ord f : WithTop ℕ` — the least index in `f.support` (`ord 0 = ⊤`);
* `deg f : WithBot ℕ` — the greatest index in `f.support` (`deg 0 = ⊥`).

These are the *valuation* (lowest order term) and *degree* (highest order term) of `f`
viewed as a polynomial / Laurent-style profile.  The main results say that these extremal
indices behave **tropically**:

* under addition they only satisfy inequalities (`ord_add_ge`, `deg_add_le`):
  `min (ord f) (ord g) ≤ ord (f + g)` and `deg (f + g) ≤ max (deg f) (deg g)`;
* under the ordinary finitely-supported Cauchy convolution `cconv` they add **exactly**:
  `ord (cconv f g) = ord f + ord g` and `deg (cconv f g) = deg f + deg g`.

The exact convolution laws are proved through the **unique extremal contributing pair**:
at the index `ord f + ord g` only the summand `(ord f, ord g)` survives, and it is nonzero
because `ℚ` is an integral domain; dually for `deg`.

## Main results
* `ord`, `deg`               — extremal-support indices.
* `ord_eq_of`, `deg_eq_of`   — extremal-characterisation lemmas (the workhorses).
* `ord_add_ge`, `deg_add_le` — the tropical (inequality) laws for addition.
* `cconv`                    — finitely supported Cauchy convolution.
* `cconv_apply`              — its coefficientwise formula.
* `ord_cconv`, `deg_cconv`   — exact additivity of extremal indices under convolution.
* `binConv_extremal_profile` — downstream species/EGF corollary (binomial convolution).
-/
import Mathlib
import Applications.CombinatorialSpecies

open scoped BigOperators
open Finset

namespace SpeciesTropicalProfile

/-! ### Extremal-support indices `ord` and `deg` -/

/-- The **order / valuation** of `f`: the least index in `f.support`, with `ord 0 = ⊤`. -/
def ord (f : ℕ →₀ ℚ) : WithTop ℕ := f.support.min

/-- The **degree** of `f`: the greatest index in `f.support`, with `deg 0 = ⊥`. -/
def deg (f : ℕ →₀ ℚ) : WithBot ℕ := f.support.max

@[simp] lemma ord_zero : ord (0 : ℕ →₀ ℚ) = ⊤ := by
  convert Finset.min_empty

@[simp] lemma deg_zero : deg (0 : ℕ →₀ ℚ) = ⊥ := by
  convert Finset.max_empty

/-! #### Basic support API -/

/--
If `f n ≠ 0`, then `ord f ≤ n`.
-/
lemma ord_le_of_ne_zero {f : ℕ →₀ ℚ} {n : ℕ} (h : f n ≠ 0) : ord f ≤ (n : WithTop ℕ) := by
  exact Finset.min_le ( by aesop )

/--
If `f n ≠ 0`, then `n ≤ deg f`.
-/
lemma le_deg_of_ne_zero {f : ℕ →₀ ℚ} {n : ℕ} (h : f n ≠ 0) : (n : WithBot ℕ) ≤ deg f := by
  exact Finset.le_max ( Finsupp.mem_support_iff.mpr h )

/--
Coefficients strictly below `ord f` vanish.
-/
lemma coeff_eq_zero_of_lt_ord {f : ℕ →₀ ℚ} {n : ℕ} (h : (n : WithTop ℕ) < ord f) : f n = 0 := by
  contrapose! h;
  exact Finset.min_le ( by aesop )

/--
Coefficients strictly above `deg f` vanish.
-/
lemma coeff_eq_zero_of_deg_lt {f : ℕ →₀ ℚ} {n : ℕ} (h : deg f < (n : WithBot ℕ)) : f n = 0 := by
  exact Classical.not_not.1 fun hn => h.not_ge <| le_deg_of_ne_zero hn

/--
If `ord f = n` then the `n`-th coefficient is nonzero.
-/
lemma coeff_ne_zero_of_ord_eq {f : ℕ →₀ ℚ} {n : ℕ} (h : ord f = (n : WithTop ℕ)) : f n ≠ 0 := by
  exact Finsupp.mem_support_iff.mp ( Finset.mem_of_min h )

/--
If `deg f = n` then the `n`-th coefficient is nonzero.
-/
lemma coeff_ne_zero_of_deg_eq {f : ℕ →₀ ℚ} {n : ℕ} (h : deg f = (n : WithBot ℕ)) : f n ≠ 0 := by
  convert Finsupp.mem_support_iff.mp ( Finset.mem_of_max h ) using 1

/--
For `f ≠ 0` the order is realised by an actual index.
-/
lemma exists_ord_eq {f : ℕ →₀ ℚ} (hf : f ≠ 0) : ∃ n : ℕ, ord f = (n : WithTop ℕ) ∧ f n ≠ 0 := by
  obtain ⟨n, hn⟩ : ∃ n, f n ≠ 0 ∧ ∀ m < n, f m = 0 := by
    exact ⟨ Nat.find ( show ∃ n, f n ≠ 0 from not_forall.mp fun h => hf <| Finsupp.ext h ), Nat.find_spec ( show ∃ n, f n ≠ 0 from not_forall.mp fun h => hf <| Finsupp.ext h ), fun m mn => by aesop ⟩;
  use n; simp_all +decide [ ord ] ;
  exact le_antisymm ( Finset.min_le <| by aesop ) ( Finset.le_min fun m hm => Nat.cast_le.mpr <| le_of_not_gt fun hnm => by aesop )

/--
For `f ≠ 0` the degree is realised by an actual index.
-/
lemma exists_deg_eq {f : ℕ →₀ ℚ} (hf : f ≠ 0) : ∃ n : ℕ, deg f = (n : WithBot ℕ) ∧ f n ≠ 0 := by
  have := Finset.max_of_nonempty ( show f.support.Nonempty from Finset.nonempty_of_ne_empty ( by aesop ) );
  exact ⟨ this.choose, this.choose_spec, Finsupp.mem_support_iff.mp ( Finset.mem_of_max this.choose_spec ) ⟩

/--
**Extremal characterisation of `ord`.** A nonzero coefficient at `n` whose strictly
smaller coefficients all vanish realises the order.
-/
lemma ord_eq_of {f : ℕ →₀ ℚ} {n : ℕ} (hmem : f n ≠ 0) (hbelow : ∀ m, m < n → f m = 0) :
    ord f = (n : WithTop ℕ) := by
      refine' le_antisymm ( ord_le_of_ne_zero hmem ) _;
      exact Finset.le_min fun m hm => Nat.cast_le.mpr <| le_of_not_gt fun hnm => by aesop;

/--
**Extremal characterisation of `deg`.** A nonzero coefficient at `n` whose strictly
larger coefficients all vanish realises the degree.
-/
lemma deg_eq_of {f : ℕ →₀ ℚ} {n : ℕ} (hmem : f n ≠ 0) (habove : ∀ m, n < m → f m = 0) :
    deg f = (n : WithBot ℕ) := by
      refine' le_antisymm _ _;
      · exact Finset.max_le fun m hm => WithBot.coe_le_coe.mpr <| le_of_not_gt fun hnm => by aesop;
      · exact Finset.le_max ( by aesop )

/-! ### The tropical laws for addition -/

/--
**Tropical law for `ord` under addition.** `min (ord f) (ord g) ≤ ord (f + g)`.
-/
lemma ord_add_ge (f g : ℕ →₀ ℚ) : min (ord f) (ord g) ≤ ord (f + g) := by
  -- By definition of `ord`, we know that `ord (f + g) = (f + g).support.min`.
  unfold ord;
  simp +decide [ Finset.min ];
  grind

/--
**Tropical law for `deg` under addition.** `deg (f + g) ≤ max (deg f) (deg g)`.
-/
lemma deg_add_le (f g : ℕ →₀ ℚ) : deg (f + g) ≤ max (deg f) (deg g) := by
  unfold deg;
  simp +decide [ Finset.max ];
  grind

/-! ### Finitely supported Cauchy convolution -/

/-- Coefficient function of the Cauchy convolution. -/
def cconvFun (f g : ℕ →₀ ℚ) (n : ℕ) : ℚ := ∑ i ∈ Finset.range (n + 1), f i * g (n - i)

/--
The Cauchy convolution is supported below `(sup f.support) + (sup g.support)`.
-/
lemma cconvFun_mem_support (f g : ℕ →₀ ℚ) :
    ∀ n, cconvFun f g n ≠ 0 →
      n ∈ Finset.range (f.support.sup id + g.support.sup id + 1) := by
        intro n hn;
        contrapose! hn;
        refine Finset.sum_eq_zero fun i hi => ?_;
        simp +zetaDelta at *;
        exact Classical.or_iff_not_imp_left.2 fun h => Classical.not_not.1 fun h' => not_le_of_gt hn <| by linarith [ show f.support.sup id ≥ i from Finset.le_sup ( f := id ) <| by aesop, show g.support.sup id ≥ n - i from Finset.le_sup ( f := id ) <| by aesop, Nat.sub_add_cancel hi ] ;

/-- **Ordinary finitely supported Cauchy convolution.** Its `n`-th coefficient is the finite
sum `∑_{i=0}^{n} fᵢ · g_{n-i}` (see `cconv_apply`). -/
noncomputable def cconv (f g : ℕ →₀ ℚ) : ℕ →₀ ℚ :=
  Finsupp.onFinset (Finset.range (f.support.sup id + g.support.sup id + 1))
    (cconvFun f g) (cconvFun_mem_support f g)

/--
**Coefficient formula** for the Cauchy convolution.
-/
@[simp] lemma cconv_apply (f g : ℕ →₀ ℚ) (n : ℕ) :
    cconv f g n = ∑ i ∈ Finset.range (n + 1), f i * g (n - i) := by
  unfold cconv;
  simp +decide [ Finsupp.onFinset, cconvFun ]

/--
`cconv 0 g = 0`.
-/
@[simp] lemma cconv_zero_left (g : ℕ →₀ ℚ) : cconv 0 g = 0 := by
  convert Finsupp.ext fun n => ?_;
  simp +decide [ cconv_apply ]

/--
`cconv f 0 = 0`.
-/
@[simp] lemma cconv_zero_right (f : ℕ →₀ ℚ) : cconv f 0 = 0 := by
  ext n; simp [cconv_apply]

/-! #### The unique extremal contributing pair -/

/--
Below `a + b` (the sum of orders) every summand of the convolution vanishes.
-/
lemma cconv_eq_zero_below {f g : ℕ →₀ ℚ} {a b : ℕ}
    (ha : ord f = (a : WithTop ℕ)) (hb : ord g = (b : WithTop ℕ))
    {n : ℕ} (hn : n < a + b) : cconv f g n = 0 := by
      by_cases hf : f = 0 <;> by_cases hg : g = 0 <;> simp_all +decide;
      refine Finset.sum_eq_zero fun i hi => ?_;
      by_cases hi' : i < a;
      · rw [ show f i = 0 from coeff_eq_zero_of_lt_ord <| by aesop ] ; ring;
      · simp +zetaDelta at *;
        exact Or.inr ( coeff_eq_zero_of_lt_ord <| by rw [ hb ] ; exact Nat.cast_lt.mpr <| by omega )

/--
At the index `a + b = ord f + ord g`, only the pair `(a, b)` contributes, so the
coefficient is exactly `f a * g b`.
-/
lemma cconv_apply_ord_add {f g : ℕ →₀ ℚ} {a b : ℕ}
    (ha : ord f = (a : WithTop ℕ)) (hb : ord g = (b : WithTop ℕ)) :
    cconv f g (a + b) = f a * g b := by
      convert Finset.sum_eq_single a _ _ using 1;
      convert cconv_apply f g ( a + b ) using 1;
      · rw [ Nat.add_sub_cancel_left ];
      · intro i hi hi'; cases lt_or_gt_of_ne hi' <;> simp_all +decide [ mul_eq_zero ] ;
        · exact Or.inl <| coeff_eq_zero_of_lt_ord <| by aesop;
        · exact Or.inr ( coeff_eq_zero_of_lt_ord <| by rw [ hb ] ; exact Nat.cast_lt.mpr <| by omega );
      · exact fun h => False.elim <| h <| Finset.mem_range.mpr <| by linarith;

/--
Above `a + b` (the sum of degrees) every summand of the convolution vanishes.
-/
lemma cconv_eq_zero_above {f g : ℕ →₀ ℚ} {a b : ℕ}
    (ha : deg f = (a : WithBot ℕ)) (hb : deg g = (b : WithBot ℕ))
    {n : ℕ} (hn : a + b < n) : cconv f g n = 0 := by
      convert Finset.sum_eq_zero _;
      convert cconv_apply f g n;
      intro i hi; cases lt_or_ge i a <;> simp_all +decide ;
      · contrapose! hn;
        exact le_trans ( show n ≤ i + ( n - i ) by omega ) ( add_le_add ( show i ≤ a by omega ) ( show n - i ≤ b by exact_mod_cast hb ▸ le_deg_of_ne_zero hn.2 ) );
      · contrapose! hn;
        exact le_trans ( show n ≤ i + ( n - i ) by omega ) ( add_le_add ( show i ≤ a by exact le_of_not_gt fun hi' => hn.1 <| by { exact coeff_eq_zero_of_deg_lt <| by { exact ha.symm ▸ WithBot.coe_lt_coe.mpr hi' } } ) ( show n - i ≤ b by exact le_of_not_gt fun hi' => hn.2 <| by { exact coeff_eq_zero_of_deg_lt <| by { exact hb.symm ▸ WithBot.coe_lt_coe.mpr hi' } } ) )

/--
At the index `a + b = deg f + deg g`, only the pair `(a, b)` contributes, so the
coefficient is exactly `f a * g b`.
-/
lemma cconv_apply_deg_add {f g : ℕ →₀ ℚ} {a b : ℕ}
    (ha : deg f = (a : WithBot ℕ)) (hb : deg g = (b : WithBot ℕ)) :
    cconv f g (a + b) = f a * g b := by
      rw [ cconv_apply, Finset.sum_eq_single a ];
      · rw [ Nat.add_sub_cancel_left ];
      · intro i hi hia
        by_cases hia' : i < a;
        · rw [ show g ( a + b - i ) = 0 from _ ] ; aesop;
          exact coeff_eq_zero_of_deg_lt <| hb.symm ▸ Nat.cast_lt.mpr ( by omega );
        · exact mul_eq_zero_of_left ( by exact coeff_eq_zero_of_deg_lt <| by rw [ ha ] ; exact WithBot.coe_lt_coe.mpr <| lt_of_le_of_ne ( le_of_not_gt hia' ) hia.symm ) _;
      · grind

/-! ### Exact additivity of extremal indices under convolution -/

/--
**Exact order law.** `ord (cconv f g) = ord f + ord g`.
-/
theorem ord_cconv (f g : ℕ →₀ ℚ) : ord (cconv f g) = ord f + ord g := by
  by_cases hf : f = 0 <;> by_cases hg : g = 0 <;> simp_all +decide [ Finsupp.ext_iff, ord ];
  · simp +decide [ show f = 0 from Finsupp.ext hf, show g = 0 from Finsupp.ext hg, cconv ];
    ext; simp [cconvFun];
  · simp_all +decide [ show f = 0 from Finsupp.ext hf ];
  · simp_all +decide [ show g = 0 from Finsupp.ext hg ];
  · convert ord_eq_of ?_ ?_ using 1;
    rotate_left;
    exact ( f.support.min.get! + g.support.min.get! );
    · obtain ⟨a, ha⟩ : ∃ a : ℕ, ord f = (a : WithTop ℕ) ∧ f a ≠ 0 := by
        exact exists_ord_eq ( by aesop )
      obtain ⟨b, hb⟩ : ∃ b : ℕ, ord g = (b : WithTop ℕ) ∧ g b ≠ 0 := by
        exact exists_ord_eq ( by aesop );
      convert mul_ne_zero ha.2 hb.2 using 1;
      convert cconv_apply_ord_add ha.1 hb.1 using 1;
      congr! 2;
      · unfold ord at ha; aesop;
      · unfold ord at hb; aesop;
    · intro m hm
      have hmin : ord f = (f.support.min.get! : WithTop ℕ) ∧ ord g = (g.support.min.get! : WithTop ℕ) := by
        exact ⟨ by cases h : Finset.min f.support <;> aesop, by cases h : Finset.min g.support <;> aesop ⟩
      generalize_proofs at *;
      exact cconv_eq_zero_below hmin.1 hmin.2 hm;
    · cases h : Finset.min f.support <;> cases h' : Finset.min g.support <;> aesop

/--
**Exact degree law.** `deg (cconv f g) = deg f + deg g`.
-/
theorem deg_cconv (f g : ℕ →₀ ℚ) : deg (cconv f g) = deg f + deg g := by
  by_cases hf : f = 0 <;> by_cases hg : g = 0;
  · aesop;
  · aesop;
  · aesop;
  · obtain ⟨a, ha⟩ := exists_deg_eq hf
    obtain ⟨b, hb⟩ := exists_deg_eq hg
    simp [ha, hb];
    convert deg_eq_of _ _;
    · erw [ cconv_apply_deg_add ha.1 hb.1 ] ; aesop;
    · exact fun m hm => cconv_eq_zero_above ha.1 hb.1 hm

/-! ### Tiny examples -/

example : ord (Finsupp.single 2 (3 : ℚ)) = (2 : WithTop ℕ) := by
  refine' ord_eq_of _ _ <;> simp +decide [ Finsupp.single_apply ]

example : deg (Finsupp.single 2 (3 : ℚ)) = (2 : WithBot ℕ) := by
  unfold deg;
  rw [ Finsupp.support_single_ne_zero ] <;> norm_num

example : ord (0 : ℕ →₀ ℚ) = ⊤ := ord_zero

example : deg (0 : ℕ →₀ ℚ) = ⊥ := deg_zero

/--
A nontrivial convolution example: `(X + 2X²) ⋆ (3X + X³)` has its bottom term at
index `2` with coefficient `3` and its top term at index `5`.
-/
example :
    cconv (Finsupp.single 1 (1 : ℚ) + Finsupp.single 2 (2 : ℚ))
          (Finsupp.single 1 (3 : ℚ) + Finsupp.single 3 (1 : ℚ)) 2 = 3 := by
            unfold cconv cconvFun; norm_num [ Finsupp.single_apply, Finset.sum_add_distrib ] ; ring_nf;
            norm_cast

/-! ### Downstream corollary: the species / EGF setting (binomial convolution)

The catalog file `Catalog/Applications/CombinatorialSpecies.lean` packages the
**binomial / exponential** convolution `binConv` of counting sequences, which is the
counting sequence of the Day-convolution product of species and the Cauchy product of
their exponential generating functions.  The extremal-profile phenomenon transfers
verbatim to that setting: the binomial weights `C(n, i)` are strictly positive, so they
never destroy the unique extremal contributing pair.  We record this transfer here without
introducing any new species abstractions. -/

/--
**Species/EGF corollary.** The extremal contributing-pair phenomenon transfers to the
binomial (exponential) convolution `binConv` of the underlying sequences: the bottom
coefficient sits exactly at `ord f + ord g` and is nonzero, and everything strictly below
vanishes.
-/
theorem binConv_extremal_profile {f g : ℕ →₀ ℚ} {a b : ℕ}
    (ha : ord f = (a : WithTop ℕ)) (hb : ord g = (b : WithTop ℕ)) :
    CombinatorialSpecies.binConv (f : ℕ → ℚ) (g : ℕ → ℚ) (a + b) ≠ 0 ∧
      ∀ n, n < a + b → CombinatorialSpecies.binConv (f : ℕ → ℚ) (g : ℕ → ℚ) n = 0 := by
  constructor;
  · unfold CombinatorialSpecies.binConv;
    rw [ Finset.sum_eq_single ( a, b ) ] <;> simp_all +decide [ Nat.choose_eq_zero_iff ];
    · exact ⟨ coeff_ne_zero_of_ord_eq ha, coeff_ne_zero_of_ord_eq hb ⟩;
    · intro x y hxy hne; cases lt_or_ge x a <;> cases lt_or_ge y b <;> try (left; left; linarith);
      · exact Or.inl <| Or.inr <| coeff_eq_zero_of_lt_ord <| by aesop;
      · exact Or.inr ( coeff_eq_zero_of_lt_ord <| by aesop );
      · grind;
  · intro n hn; unfold CombinatorialSpecies.binConv; simp +decide [ Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk ] ;
    refine Finset.sum_eq_zero fun i hi => ?_;
    by_cases hi' : i < a <;> simp_all +decide [ mul_assoc ];
    · exact Or.inr <| Or.inl <| coeff_eq_zero_of_lt_ord <| by aesop;
    · exact Or.inr <| Or.inr <| coeff_eq_zero_of_lt_ord <| by rw [ hb ] ; exact Nat.cast_lt.mpr <| by omega;

end SpeciesTropicalProfile