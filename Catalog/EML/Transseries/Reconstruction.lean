/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Transseries: Reconstruction from a Sequence of Leading Transmonomials

A transseries is determined by its asymptotic expansion: the (well-ordered) sequence of its
leading transmonomials together with their coefficients (the *valuations* attached to each
leading term).  This file builds a **computational pipeline** that turns such a sequence —
a finite list `[(g₀, c₀), (g₁, c₁), …]` of transmonomials `gᵢ : TransMono` with coefficients
`cᵢ : ℝ` — back into the transseries it describes, and proves the pipeline is correct:

* the produced transseries has exactly the prescribed leading terms, in order, and
* it is the *unique* transseries with that leading-term sequence.

Crucially the constructor `reconstruct` never refers to a "target" transseries: it is defined
purely from the input monomials and coefficients (`HahnSeries.single`), and its correctness is
established through **valuation properties** (`orderTop`) of the partial sums.  The driving
fact is that prepending a strictly more dominant monomial fixes the leading term and that
stripping a leading term strictly raises the valuation (`orderTop_strip_gt`), which is exactly
what makes the round-trip `extract ∘ reconstruct = id` terminate and hold.

## Main definitions

- `EMLTransseries.reconstruct`   : build a transseries from a list of leading terms.
- `EMLTransseries.WellFormed`    : the admissible inputs (nonzero coefficients, strictly
                                   decreasing dominance, i.e. strictly increasing monomials).
- `EMLTransseries.extract`       : the inverse pipeline — read off the leading-term sequence.

## Main results

- `EMLTransseries.reconstruct_orderTop` / `_order` / `_leadingCoeff` : the leading term of a
  reconstructed series is the head of the input list.
- `EMLTransseries.orderTop_strip_gt`  : stripping a leading term strictly raises the valuation.
- `EMLTransseries.extract_reconstruct`: the pipeline round-trips (correctness).
- `EMLTransseries.reconstruct_inj_iff`: **uniqueness** — distinct well-formed leading-term
  sequences give distinct transseries; equivalently a transseries is uniquely determined by
  its leading-term sequence.
-/
import EML.Transseries.Field
import EML.Transseries.AsymptoticComparison

open HahnSeries

namespace EMLTransseries

noncomputable section

/-! ### The reconstruction pipeline -/

/-- **Reconstruction.**  Build the transseries described by a finite list of leading terms
`[(g₀, c₀), (g₁, c₁), …]`: the formal sum `∑ᵢ cᵢ · gᵢ`.  This refers only to the input
monomials and coefficients, never to any "target" transseries. -/
noncomputable def reconstruct : List (TransMono × ℝ) → TSeries
  | [] => 0
  | p :: rest => single p.1 p.2 + reconstruct rest

@[simp] theorem reconstruct_nil : reconstruct [] = 0 := rfl

theorem reconstruct_cons (p : TransMono × ℝ) (rest : List (TransMono × ℝ)) :
    reconstruct (p :: rest) = single p.1 p.2 + reconstruct rest := rfl

/-- **Admissible inputs.**  A list of leading terms is *well-formed* when every coefficient is
nonzero and the monomials are strictly increasing in the transmonomial order (equivalently,
the terms are listed in strictly decreasing order of asymptotic dominance). -/
def WellFormed (L : List (TransMono × ℝ)) : Prop :=
  (∀ p ∈ L, p.2 ≠ 0) ∧ L.Pairwise (fun p q => p.1 < q.1)

theorem WellFormed.tail {p : TransMono × ℝ} {rest : List (TransMono × ℝ)}
    (hw : WellFormed (p :: rest)) : WellFormed rest := by
  obtain ⟨hc, hp⟩ := hw
  exact ⟨fun q hq => hc q (List.mem_cons_of_mem _ hq), (List.pairwise_cons.mp hp).2⟩

/-! ### The master valuation lemma -/

/-
Prepending a strictly more dominant transmonomial `g` (with nonzero coefficient `c`) to a
series `f` whose valuation is strictly larger fixes the valuation at `g`.
-/
theorem orderTop_single_add (g : TransMono) (c : ℝ) (hc : c ≠ 0) (f : TSeries)
    (hf : (g : WithTop TransMono) < f.orderTop) :
    (single g c + f).orderTop = (g : WithTop TransMono) := by
  rw [ HahnSeries.orderTop_add_eq_left ] <;> aesop

/-
Under the same hypotheses the order (leading monomial) is `g`.
-/
theorem order_single_add (g : TransMono) (c : ℝ) (hc : c ≠ 0) (f : TSeries)
    (hf : (g : WithTop TransMono) < f.orderTop) :
    (single g c + f).order = g := by
  have := @orderTop_single_add;
  specialize this g c hc f hf;
  exact WithTop.coe_inj.mp ( by rw [ ← this, HahnSeries.order_eq_orderTop_of_ne_zero ] ; aesop )

/-
Under the same hypotheses the leading coefficient (the valuation of the leading term) is
`c`: the added term `f` does not contribute at the level `g`.
-/
theorem leadingCoeff_single_add (g : TransMono) (c : ℝ) (hc : c ≠ 0) (f : TSeries)
    (hf : (g : WithTop TransMono) < f.orderTop) :
    (single g c + f).leadingCoeff = c := by
  rw [ HahnSeries.leadingCoeff_eq, order_single_add g c hc f hf ];
  by_cases h : f = 0 <;> simp_all +decide [ HahnSeries.coeff_eq_zero_of_lt_orderTop ]

/-
A reconstructed tail is dominated by any monomial strictly below all of its terms:
its valuation lies strictly above `g`.
-/
theorem lt_orderTop_reconstruct (g : TransMono) (rest : List (TransMono × ℝ))
    (hmono : ∀ q ∈ rest, g < q.1) (hcoeff : ∀ q ∈ rest, q.2 ≠ 0) :
    (g : WithTop TransMono) < (reconstruct rest).orderTop := by
  induction' rest with q rest ih;
  · aesop;
  · have h_orderTop_add : min (orderTop (single q.1 q.2)) (orderTop (reconstruct rest)) ≤ orderTop (single q.1 q.2 + reconstruct rest) := by
      grind +suggestions;
    simp_all +decide [ HahnSeries.orderTop_single ];
    cases h_orderTop_add <;> [ exact lt_of_lt_of_le ( WithTop.coe_lt_coe.mpr hmono.1 ) ‹_›; exact lt_of_lt_of_le ih ‹_› ]

/-! ### The leading term of a reconstructed series -/

/-
**Correctness of the leading valuation.**  The valuation of a reconstructed series is the
first monomial of the input list.
-/
theorem reconstruct_orderTop (p : TransMono × ℝ) (rest : List (TransMono × ℝ))
    (hw : WellFormed (p :: rest)) :
    (reconstruct (p :: rest)).orderTop = (p.1 : WithTop TransMono) := by
  convert orderTop_single_add p.1 p.2 _ _ _ using 1;
  · exact hw.1 p ( by simp +decide );
  · convert lt_orderTop_reconstruct p.1 rest _ _;
    · exact fun q hq => hw.2 |> fun h => List.pairwise_cons.mp h |>.1 q hq;
    · exact fun q hq => hw.1 q ( List.mem_cons_of_mem _ hq )

/-
The leading monomial of a reconstructed series is the first monomial of the input.
-/
theorem reconstruct_order (p : TransMono × ℝ) (rest : List (TransMono × ℝ))
    (hw : WellFormed (p :: rest)) :
    (reconstruct (p :: rest)).order = p.1 := by
  apply order_single_add;
  · exact hw.1 p ( by simp +decide );
  · apply lt_orderTop_reconstruct;
    · cases hw ; aesop;
    · exact fun q hq => hw.1 q ( List.mem_cons_of_mem _ hq )

/-
The leading coefficient of a reconstructed series is the first coefficient of the input.
-/
theorem reconstruct_leadingCoeff (p : TransMono × ℝ) (rest : List (TransMono × ℝ))
    (hw : WellFormed (p :: rest)) :
    (reconstruct (p :: rest)).leadingCoeff = p.2 := by
  convert leadingCoeff_single_add p.1 p.2 _ _ _ using 1;
  · exact hw.1 p ( by simp +decide );
  · convert lt_orderTop_reconstruct p.1 rest _ _;
    · cases hw ; aesop;
    · exact fun q hq => hw.1 q ( List.mem_cons_of_mem _ hq )

/-
A well-formed nonempty leading-term sequence reconstructs to a nonzero transseries.
-/
theorem reconstruct_ne_zero {L : List (TransMono × ℝ)} (hw : WellFormed L) (hL : L ≠ []) :
    reconstruct L ≠ 0 := by
  obtain ⟨p, rest, hL⟩ : ∃ p rest, L = p :: rest := by
    exact List.exists_cons_of_ne_nil hL;
  have := reconstruct_leadingCoeff p rest ( by simpa [ hL ] using hw ) ; simp_all +decide ;
  intro h; simp_all +decide [ WellFormed ] ;

/-
**Stripping a leading term = dropping the head.**  Subtracting the explicit leading term
recovers the reconstruction of the remaining list.
-/
theorem reconstruct_sub_leadTerm (p : TransMono × ℝ) (rest : List (TransMono × ℝ)) :
    reconstruct (p :: rest) - single p.1 p.2 = reconstruct rest := by
  convert sub_eq_iff_eq_add.mpr rfl using 1;
  rw [ reconstruct_cons ];
  rw [ add_sub_cancel_left, add_comm ];
  rw [ add_sub_cancel_left ];
  exact 0

/-
**The valuation strictly increases when a leading term is stripped.**  This is the
valuation property that makes the extraction pipeline terminate: removing the leading term of
a nonzero transseries produces a strictly less dominant remainder.
-/
theorem orderTop_strip_gt (f : TSeries) (hf : f ≠ 0) :
    f.orderTop < (f - single f.order f.leadingCoeff).orderTop := by
  by_cases h : f - single ( order f ) ( leadingCoeff f ) = 0 <;> simp_all +decide;
  have h_coeff_zero : ∀ i : TransMono, i ≤ order f → (f - single (order f) (leadingCoeff f)).coeff i = 0 := by
    intro i hi; by_cases hi' : i = order f <;> simp_all +decide [ sub_eq_add_neg ] ;
    · rw [ HahnSeries.leadingCoeff_eq, add_neg_cancel ];
    · exact HahnSeries.coeff_eq_zero_of_lt_order ( lt_of_le_of_ne hi hi' );
  have h_order_gt : order f < (f - single (order f) (leadingCoeff f)).orderTop := by
    contrapose! h_coeff_zero;
    exact ⟨ order ( f - ( single ( order f ) ) ( leadingCoeff f ) ), by
      exact WithTop.coe_le_coe.mp ( le_trans ( HahnSeries.order_eq_orderTop_of_ne_zero h ▸ le_rfl ) h_coeff_zero ), by
      grind +suggestions ⟩;
  rwa [ HahnSeries.order_eq_orderTop_of_ne_zero hf ] at h_order_gt

/-! ### The inverse pipeline and round-trip correctness -/

open Classical in
/-- **Extraction.**  Read off the leading-term sequence of a transseries, one valuation at a
time, using a fuel parameter to bound the (here finite) length.  Each step records the leading
monomial and its coefficient, then strips that leading term. -/
noncomputable def extract : ℕ → TSeries → List (TransMono × ℝ)
  | 0, _ => []
  | n + 1, f =>
      if f = 0 then []
      else (f.order, f.leadingCoeff) :: extract n (f - single f.order f.leadingCoeff)

/-
**Round-trip correctness.**  Extracting the leading-term sequence of a reconstructed
series returns the original input list: the pipeline is faithful.
-/
theorem extract_reconstruct (L : List (TransMono × ℝ)) (hw : WellFormed L) :
    extract L.length (reconstruct L) = L := by
  induction' L with p L ih;
  · rfl;
  · rw [ List.length_cons, extract ];
    rw [ if_neg ( reconstruct_ne_zero hw ( by simp +decide ) ) ];
    rw [ reconstruct_order p L hw, reconstruct_leadingCoeff p L hw, reconstruct_sub_leadTerm p L ];
    exact congr_arg₂ _ rfl ( ih <| WellFormed.tail hw )

/-! ### Uniqueness -/

/-
**Uniqueness.**  Two well-formed leading-term sequences reconstruct to the same transseries
iff they are equal.  Equivalently: a transseries is uniquely determined by its sequence of
leading transmonomials and valuations.
-/
theorem reconstruct_inj_iff {L₁ L₂ : List (TransMono × ℝ)}
    (hw₁ : WellFormed L₁) (hw₂ : WellFormed L₂) :
    reconstruct L₁ = reconstruct L₂ ↔ L₁ = L₂ := by
  induction' L₁ with p₁ r₁ ih generalizing L₂ <;> induction' L₂ with p₂ r₂ ih' <;> simp_all +decide [ reconstruct_cons ];
  · convert reconstruct_ne_zero hw₂ ( by simp +decide ) using 1;
    rw [ eq_comm, reconstruct_cons ];
  · exact reconstruct_ne_zero hw₁ ( by aesop );
  · constructor <;> intro h;
    · -- By comparing the leading terms, we get $p₁.1 = p₂.1$ and $p₁.2 = p₂.2$.
      have h_leading : p₁.1 = p₂.1 ∧ p₁.2 = p₂.2 := by
        have h_leading : (reconstruct (p₁ :: r₁)).order = (reconstruct (p₂ :: r₂)).order ∧ (reconstruct (p₁ :: r₁)).leadingCoeff = (reconstruct (p₂ :: r₂)).leadingCoeff := by
          simp_all +decide [ reconstruct_cons ];
        have := reconstruct_order p₁ r₁ hw₁; have := reconstruct_order p₂ r₂ hw₂; have := reconstruct_leadingCoeff p₁ r₁ hw₁; have := reconstruct_leadingCoeff p₂ r₂ hw₂; aesop;
      simp_all +decide [ WellFormed ];
      grind;
    · aesop

end

end EMLTransseries