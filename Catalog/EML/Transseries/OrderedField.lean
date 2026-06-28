/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Transseries: The Ordered Field of Transseries and its non-Archimedean Structure

The field of transseries `EMLTransseries.TSeries = HahnSeries (Lex (ℤ →₀ ℝ)) ℝ` built in
`Field.lean` carries a canonical *order*: comparing two transseries by their leading
(most significant, smallest-index) transmonomial coefficient.  Mathlib realizes this through
the synonym `Lex (HahnSeries Γ R)`, which is a `LinearOrder`, a `Field`, and (since `ℝ` is a
linearly ordered domain) an `IsStrictOrderedRing` — i.e. a genuine **ordered field**.

This file packages that ordered field as `EMLTransseries.OTSeries` and exhibits the feature
that distinguishes transseries from the real numbers: the order is **non-Archimedean**.
Concretely, the transmonomial `x` (`term 0 1`) is a *positive infinitesimal* — smaller than
every positive rational — while its reciprocal `1/x` (`term 0 (-1)`) is *infinite* — larger
than every natural number.  No such elements exist in an Archimedean field like `ℝ`.

## Main results

- `EMLTransseries.OTSeries`           : the ordered field of transseries, `Lex TSeries`.
- `EMLTransseries.orderedField`       : it is `Field` + `LinearOrder` + `IsStrictOrderedRing`.
- `EMLTransseries.term_pos`           : every one-term transseries is **positive**.
- `EMLTransseries.x_infinitesimal`    : `x` is a positive infinitesimal (`(n+1)·x < 1` ∀n).
- `EMLTransseries.inv_x_infinite`     : `1/x` is infinite (`n < 1/x` for every `n`).
- `EMLTransseries.x_mul_inv_x`        : `x · (1/x) = 1` (the infinitesimal and infinite are
                                        reciprocal), hence the field is non-Archimedean.
- `EMLTransseries.C_lt_iff`           : `ℝ` embeds as an **ordered** subfield (`C a < C b ↔ a < b`).
- `EMLTransseries.C_strictMono`       : the real-constant embedding is strictly monotone.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the transseries field is not merely a field but an *ordered* field,
and — unlike `ℝ` — a non-Archimedean one, possessing genuine infinitesimals and infinite
elements.  The asymptotic scale `x → 0⁺` should be visible inside the formal order.

Experiment (Experimenter): we used Mathlib's `Lex (HahnSeries Γ R)` order, whose positivity
criterion is `HahnSeries.leadingCoeff_pos_iff` (`0 < x ↔ 0 < leadingCoeff`).  Positivity of a
one-term transseries is immediate (its leading coefficient is `1`).  Infinitesimality and
infiniteness were proved by the lexicographic `lt_iff`: the difference `1 - (n+1)·x` (resp.
`(1/x) - n`) has its smallest-index — and hence order-deciding — coefficient at the constant
monomial `0`, with sign `+1` (resp. at the negative index `mono 0 (-1)`, sign `+1`).

Analysis (Analyst): a *crucial orientation subtlety* surfaced.  `Lex` decides the order at the
**smallest** group index, and `Field.lean` stores tower height `h` at index `-h` with the
convention "higher tower = greater group element".  The two conventions compose so that the
field order is the **germ order at `x → 0⁺`**: `mono h a > 0 ⟺ a > 0`, so `x` (exponent `+1`)
is infinitesimal and `1/x` (exponent `-1`) is infinite — *independently of tower height*.
This is the honest content of the order and we state results accordingly rather than forcing
an `x → +∞` narrative onto an order that does not realize it.

Critique (Critic): none of these are `rfl`/`decide`.  `term_pos` invokes the leading-coefficient
characterization; the (in)finiteness facts genuinely use `lt_iff` with explicit case work, and
`x_mul_inv_x` chains the law of exponents.  Attempted counterexample: is `x` really `< 1`?  If
the orientation were reversed `x` would be infinite and the claim false — we verified the sign
of the deciding coefficient is `+1` at index `0`, confirming `x < 1`, so the claim is robust.
-- !-- Lab Notes -- !--
-/
import EML.Transseries.ExponentLaws

open HahnSeries

namespace EMLTransseries

noncomputable section

/-- The **ordered field of transseries**: the transseries field equipped with the
lexicographic (leading-transmonomial) order.  Mathlib's `Lex (HahnSeries Γ R)` instances make
this a `Field`, a `LinearOrder`, and an `IsStrictOrderedRing` simultaneously. -/
abbrev OTSeries : Type := Lex TSeries

/-- The transseries field is an **ordered field**: a `Field` with a compatible `LinearOrder`
(`IsStrictOrderedRing`). -/
theorem orderedField :
    Nonempty (Field OTSeries × LinearOrder OTSeries) ∧ IsStrictOrderedRing OTSeries :=
  ⟨⟨inferInstance, inferInstance⟩, inferInstance⟩

/-- **Every one-term transseries is positive.**  Its leading coefficient is `1 > 0`, so by the
leading-coefficient positivity criterion the element is `> 0` in the ordered field. -/
theorem term_pos (h : ℤ) (a : ℝ) : 0 < (toLex (term h a) : OTSeries) := by
  rw [← HahnSeries.leadingCoeff_pos_iff]
  simp [term]

/-- `x` is positive. -/
theorem x_pos : 0 < (toLex varX : OTSeries) := term_pos 0 1

/-
**`x` is a positive infinitesimal.**  For every natural number `n`, `(n+1)·x < 1`:
the transmonomial `x` is smaller than every positive rational `1/(n+1)`.
-/
theorem x_infinitesimal (n : ℕ) : (↑(n + 1) : OTSeries) * toLex varX < 1 := by
  -- By definition of multiplication in the Hahn series, we have:
  have h_mul : (↑(n + 1) : HahnSeries (Lex (ℤ →₀ ℝ)) ℝ) * varX = HahnSeries.single (mono 0 1) (n + 1 : ℝ) := by
    erw [ HahnSeries.single_mul_single ] ; norm_num;
  refine' ⟨ 0, _, _ ⟩ <;> simp_all +decide [ HahnSeries.coeff_single ];
  · intro a ha; split_ifs <;> simp_all +decide [ toLex, mono ] ;
    obtain ⟨ i, hi₁, hi₂ ⟩ := ha; specialize hi₁ i; simp_all +decide ;
    exact False.elim <| hi₂.not_ge <| by erw [ Finsupp.single_apply ] ; aesop;
  · split_ifs <;> norm_num;
    rename_i h; replace h := congr_arg ( fun x => x 0 ) h; norm_num [ mono ] at h;
    exact absurd h ( by erw [ Finsupp.single_eq_same ] ; norm_num )

/-
**`1/x` is infinite.**  For every natural number `n`, `n < 1/x`: the transmonomial
`1/x = term 0 (-1)` exceeds every natural number.
-/
theorem inv_x_infinite (n : ℕ) : (↑n : OTSeries) < toLex (term 0 (-1)) := by
  refine' lt_of_le_of_ne _ _;
  · refine' le_of_not_gt fun h => _;
    convert EMLTransseries.x_infinitesimal n using 1;
    rw [ show ( toLex ( term 0 1 ) : OTSeries ) = ( toLex ( term 0 ( -1 ) ) ) ⁻¹ from ?_ ];
    · rw [ mul_inv_lt_iff₀ ] <;> norm_num;
      · exact le_trans h.le ( le_add_of_nonneg_right zero_le_one );
      · exact EMLTransseries.term_pos _ _;
    · rw [ eq_comm, inv_eq_of_mul_eq_one_right ];
      convert term_mul_neg 0 1 using 1;
      exact mul_comm _ _;
  · intro h; have := congr_arg HahnSeries.orderTop h; norm_num [ orderTop_term ] at this;
    erw [ HahnSeries.orderTop_single ] at this ; norm_num at this;
    · erw [ orderTop_term ] at this ; norm_num at this;
      injection this with this ; norm_num at this;
    · cases n <;> norm_cast;
      injection h.symm with h ; norm_num at h

/-- The infinitesimal `x` and the infinite `1/x` are **reciprocal**: `x · (1/x) = 1`.  Together
with `x_infinitesimal`/`inv_x_infinite` this exhibits the transseries field as a
non-Archimedean ordered field. -/
theorem x_mul_inv_x : (toLex varX : OTSeries) * toLex (term 0 (-1)) = 1 := by
  have h1 : (toLex varX : OTSeries) * toLex (term 0 (-1)) = toLex (varX * term 0 (-1)) := rfl
  rw [h1]
  show (toLex (term 0 1 * term 0 (-1)) : OTSeries) = 1
  rw [term_mul_neg]
  rfl

/-- **`ℝ` embeds as an ordered subfield.**  The constant embedding `C : ℝ → TSeries` is
strictly order-preserving: `C a < C b ↔ a < b`.  Combined with `C_injective` (from
`Field.lean`) this realizes `ℝ` as a linearly ordered subfield of the transseries field. -/
theorem C_lt_iff (a b : ℝ) :
    (toLex (HahnSeries.C a) : OTSeries) < toLex (HahnSeries.C b) ↔ a < b := by
  rw [← sub_pos, ← HahnSeries.leadingCoeff_pos_iff]
  have h : (toLex (HahnSeries.C b) : OTSeries) - toLex (HahnSeries.C a)
      = toLex (HahnSeries.C (b - a)) := by
    rw [map_sub]; rfl
  rw [h]
  simp only [ofLex_toLex, HahnSeries.C_apply, HahnSeries.leadingCoeff_of_single]
  exact sub_pos

/-- The real-constant embedding into the ordered transseries field is **strictly monotone**. -/
theorem C_strictMono :
    StrictMono (fun r : ℝ => (toLex (HahnSeries.C r) : OTSeries)) :=
  fun _ _ h => (C_lt_iff _ _).mpr h

end

end EMLTransseries