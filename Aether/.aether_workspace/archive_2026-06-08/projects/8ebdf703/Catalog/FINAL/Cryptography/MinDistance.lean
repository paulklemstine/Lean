/-
  # Reed–Muller Minimum Distance — Exact Theorem

  This file proves the exact minimum distance theorem for Reed–Muller evaluation
  codes over finite fields:

  1. **Lower bound** (from Schwartz–Zippel): Every nonzero polynomial of total
     degree ≤ d over 𝔽_q has Hamming weight ≥ (q - d) · q^(n-1).

  2. **Witness construction**: The product ∏_{a ∈ s} (X₀ - a) for a d-element
     subset s ⊆ 𝔽_q has Hamming weight exactly (q - d) · q^(n-1).

  3. **PIT soundness**: A nonzero polynomial of degree ≤ d, evaluated at a
     uniformly random point of 𝔽_q^n, is zero with probability ≤ d/q.

  Together these establish the exact minimum distance of RM_q(n, d) as
  (q - d) · q^(n-1) for 0 ≤ d < q.
-/

import Mathlib
import Cryptography.ReedMuller.Defs
import Algebra.CircuitComplexity.SchwartzZippel

open MvPolynomial Finset BigOperators

namespace ReedMuller

variable {𝔽 : Type*} [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]

/-! ## Weight–Zero Count Duality -/

/-
The Hamming weight plus the zero count equals the total number of points.
-/
theorem hammingWeight_add_zeroCount {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) :
    hammingWeight f + zeroCount f = Fintype.card (Fin n → 𝔽) := by
  unfold hammingWeight zeroCount;
  rw [ Finset.card_filter, Finset.card_filter ];
  rw [← Finset.sum_add_distrib, Finset.sum_congr rfl fun _ _ => by aesop,
    Finset.sum_const, Finset.card_univ, smul_eq_mul, mul_one]

omit [Field 𝔽] [DecidableEq 𝔽] in
/-- The total number of points in 𝔽^n equals q^n. -/
theorem card_fin_arrow (n : ℕ) :
    Fintype.card (Fin n → 𝔽) = (Fintype.card 𝔽) ^ n := by
  simp [Fintype.card_fin]

/-! ## Schwartz–Zippel Lower Bound -/

/-
**Schwartz–Zippel zero count bound**: A nonzero polynomial of total degree d
    over 𝔽_q in n+1 variables has at most d · q^n zeros.
-/
theorem zeroCount_le {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) 𝔽) (hf : f ≠ 0) :
    zeroCount f ≤ f.totalDegree * (Fintype.card 𝔽) ^ n := by
  convert SchwartzZippel.schwartz_zippel_succ f hf using 1 ; simp +decide [ zeroCount ];
  rw [ Fintype.subtype_card ];
  convert rfl

/-
**Reed–Muller lower bound**: Every nonzero polynomial of total degree ≤ d
    has Hamming weight at least (q - d) · q^n.
-/
theorem hammingWeight_ge {n d : ℕ}
    (_hd : d < Fintype.card 𝔽)
    (f : MvPolynomial (Fin (n + 1)) 𝔽) (hf : f ≠ 0) (hdeg : f.totalDegree ≤ d) :
    (Fintype.card 𝔽 - d) * (Fintype.card 𝔽) ^ n ≤ hammingWeight f := by
  -- By the Schwartz–Zippel lemma, we know that the zero count of $f$ is at most $d \cdot q^n$.
  have h_zero_count : zeroCount f ≤ d * (Fintype.card 𝔽) ^ n := by
    exact le_trans ( zeroCount_le f hf ) ( Nat.mul_le_mul_right _ hdeg );
  have := hammingWeight_add_zeroCount f;
  rw [ tsub_mul ];
  exact Nat.sub_le_of_le_add <| by rw [ show Fintype.card ( Fin ( n + 1 ) → 𝔽 ) = Fintype.card 𝔽 * Fintype.card 𝔽 ^ n by rw [ Fintype.card_fun ] ; simp +decide [ pow_succ' ] ] at this; linarith;

/-! ## Existence of Finsets of Given Cardinality -/

/-
If d ≤ |𝔽|, there exists a subset of 𝔽 with exactly d elements.
-/
omit [Field 𝔽] in
theorem exists_finset_card (d : ℕ) (hd : d ≤ Fintype.card 𝔽) :
    ∃ s : Finset 𝔽, s.card = d := by
  by_contra h_contra;
  have := Fintype.truncEquivFinOfCardEq ( show Fintype.card 𝔽 = Fintype.card 𝔽 from rfl );
  obtain ⟨ e ⟩ := Trunc.exists_rep this;
  refine' h_contra ⟨ Finset.image ( fun i : Fin d => e.symm ⟨ i, by linarith [ Fin.is_lt i ] ⟩ ) Finset.univ, _ ⟩;
  rw [ Finset.card_image_of_injective _ fun i j hij => by simpa [ Fin.ext_iff ] using e.symm.injective hij, Finset.card_fin ]

/-! ## Witness Polynomial Properties -/

/-
The witness polynomial has total degree at most |s|.
-/
omit [Fintype 𝔽] [DecidableEq 𝔽] in
theorem totalDegree_witnessPoly {n : ℕ} (s : Finset 𝔽) :
    (witnessPoly (n := n) s).totalDegree ≤ s.card := by
  have h_total_degree : ∀ a ∈ s, (MvPolynomial.X 0 - MvPolynomial.C a : MvPolynomial (Fin (n + 1)) 𝔽).totalDegree ≤ 1 := by
    intro a ha
    have h_deg : (MvPolynomial.X 0 - MvPolynomial.C a : MvPolynomial (Fin (n + 1)) 𝔽).totalDegree ≤ 1 := by
      refine' le_trans ( MvPolynomial.totalDegree_sub _ _ ) _ ; simp +decide [ MvPolynomial.totalDegree_X ]
    exact h_deg;
  convert MvPolynomial.totalDegree_finset_prod _ _;
  rw [ Finset.sum_congr rfl fun x hx => le_antisymm ( h_total_degree x hx ) ( ?_ ) ];
  · rw [ Finset.sum_const, smul_eq_mul, mul_one ];
  · refine' le_trans _ ( Finset.le_sup <| show Finsupp.single 0 1 ∈ _ from _ ) <;> simp +decide;
    rw [ if_neg ( by exact ne_of_apply_ne ( fun f => f 0 ) ( by simp +decide ) ) ] ; simp +decide

/-
The witness polynomial is nonzero.
-/
omit [Fintype 𝔽] [DecidableEq 𝔽] in
theorem witnessPoly_ne_zero {n : ℕ} (s : Finset 𝔽) :
    witnessPoly (n := n) s ≠ (0 : MvPolynomial (Fin (n + 1)) 𝔽) := by
  exact Finset.prod_ne_zero_iff.mpr fun a ha => sub_ne_zero_of_ne <| ne_of_apply_ne ( MvPolynomial.eval <| fun _ => a + 1 ) <| by simp +decide ; ;

/-
The witness polynomial evaluates to zero at x iff x 0 ∈ s.
-/
omit [Fintype 𝔽] [DecidableEq 𝔽] in
theorem eval_witnessPoly_eq_zero_iff {n : ℕ} (s : Finset 𝔽) (x : Fin (n + 1) → 𝔽) :
    MvPolynomial.eval x (witnessPoly (n := n) s) = 0 ↔ x 0 ∈ s := by
  unfold witnessPoly; simp +decide;
  simp +decide [ Finset.prod_eq_zero_iff, sub_eq_zero ]

/-
The zero count of the witness polynomial is |s| · q^n.
-/
theorem zeroCount_witnessPoly {n : ℕ} (s : Finset 𝔽) :
    zeroCount (witnessPoly (n := n) s) = s.card * (Fintype.card 𝔽) ^ n := by
  -- The zero set of `witnessPoly s` is {x : Fin (n+1) → 𝔽 | x 0 ∈ s} by `eval_witnessPoly_eq_zero_iff`.
  have h_zero_set : (Finset.univ.filter (fun x : Fin (n + 1) → 𝔽 => x 0 ∈ s)).card = s.card * (Fintype.card 𝔽) ^ n := by
    -- We can count the number of functions $x : Fin (n + 1) → 𝔽$ such that $x 0 ∈ s$ by considering the first coordinate separately.
    have h_count : Finset.card (Finset.univ.filter (fun x : Fin (n + 1) → 𝔽 => x 0 ∈ s)) = Finset.sum s (fun a => Finset.card (Finset.univ.filter (fun x : Fin n → 𝔽 => True))) := by
      have h_count : Finset.card (Finset.univ.filter (fun x : Fin (n + 1) → 𝔽 => x 0 ∈ s)) = Finset.sum s (fun a => Finset.card (Finset.filter (fun x : Fin (n + 1) → 𝔽 => x 0 = a) Finset.univ)) := by
        simp +decide only [card_filter];
        rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop;
      convert h_count using 2;
      refine' Finset.card_bij ( fun x _ => Fin.cons ‹_› x ) _ _ _ <;> simp +decide;
      exact fun b hb => ⟨ fun i => b i.succ, by ext i; cases i using Fin.inductionOn <;> simp +decide [ hb ] ⟩;
    simp_all +decide [ Finset.card_univ ];
  convert h_zero_set using 2;
  exact congr_arg Finset.card ( Finset.filter_congr fun x hx => by rw [ eval_witnessPoly_eq_zero_iff ] )

/-
The Hamming weight of the witness polynomial is (q - |s|) · q^n.
-/
theorem hammingWeight_witnessPoly {n : ℕ} (s : Finset 𝔽)
    (hs : s.card ≤ Fintype.card 𝔽) :
    hammingWeight (witnessPoly (n := n) s) =
      (Fintype.card 𝔽 - s.card) * (Fintype.card 𝔽) ^ n := by
  have h_card : hammingWeight (witnessPoly (n := n) s) + zeroCount (witnessPoly (n := n) s) = (Fintype.card 𝔽) ^ (n + 1) := by
    grind +suggestions;
  rw [ tsub_mul, eq_tsub_iff_add_eq_of_le ];
  · rw [ zeroCount_witnessPoly ] at h_card ; ring_nf at * ; aesop;
  · exact Nat.mul_le_mul_right _ hs

/-! ## Main Theorems -/

/-- **Exact minimum distance theorem for Reed–Muller codes**:
    There exists a nonzero polynomial of total degree ≤ d with Hamming weight
    exactly (q - d) · q^n, achieving the Reed–Muller minimum distance bound. -/
theorem reedMuller_distance_attained
    (n d : ℕ) (hd : d < Fintype.card 𝔽) :
    ∃ f : MvPolynomial (Fin (n + 1)) 𝔽,
      f.totalDegree ≤ d ∧
      f ≠ 0 ∧
      hammingWeight f = (Fintype.card 𝔽 - d) * (Fintype.card 𝔽) ^ n := by
  obtain ⟨s, hs⟩ := exists_finset_card (𝔽 := 𝔽) d (le_of_lt hd)
  exact ⟨witnessPoly s,
    hs ▸ totalDegree_witnessPoly s,
    witnessPoly_ne_zero s,
    hs ▸ hammingWeight_witnessPoly s (hs ▸ le_of_lt hd)⟩

/-- **Reed–Muller minimum distance is exact**: For every nonzero polynomial
    of total degree ≤ d, the Hamming weight is at least (q-d)·q^n,
    and this bound is attained. -/
theorem reedMuller_minimum_distance_exact
    (n d : ℕ) (hd : d < Fintype.card 𝔽) :
    (∀ f : MvPolynomial (Fin (n + 1)) 𝔽, f ≠ 0 → f.totalDegree ≤ d →
      (Fintype.card 𝔽 - d) * (Fintype.card 𝔽) ^ n ≤ hammingWeight f) ∧
    (∃ f : MvPolynomial (Fin (n + 1)) 𝔽, f.totalDegree ≤ d ∧ f ≠ 0 ∧
      hammingWeight f = (Fintype.card 𝔽 - d) * (Fintype.card 𝔽) ^ n) :=
  ⟨fun f hf hdeg => hammingWeight_ge hd f hf hdeg,
   reedMuller_distance_attained n d hd⟩


/-! ## PIT Soundness -/

/-
**PIT Soundness Theorem**: The fraction of zeros of a nonzero polynomial
    of degree ≤ d over 𝔽_q^(n+1) is at most d/q.
-/
theorem pit_soundness
    (n d : ℕ) (_hd : d < Fintype.card 𝔽)
    (f : MvPolynomial (Fin (n + 1)) 𝔽) (hf : f ≠ 0) (hdeg : f.totalDegree ≤ d) :
    (zeroCount f : ℚ) / (Fintype.card 𝔽 : ℚ) ^ (n + 1) ≤
      (d : ℚ) / (Fintype.card 𝔽 : ℚ) := by
  rw [ div_le_div_iff₀ ] <;> norm_cast;
  · convert Nat.mul_le_mul_right ( Fintype.card 𝔽 ) ( zeroCount_le f hf ) |> le_trans <| Nat.mul_le_mul_right _ ( Nat.mul_le_mul_right _ hdeg ) using 1 ; ring;
  · exact pow_pos ( Fintype.card_pos ) _;
  · exact Fintype.card_pos

/-
**PIT detection probability**: A nonzero polynomial of degree ≤ d over 𝔽_q,
    evaluated at a uniformly random point, is nonzero with probability ≥ 1 - d/q.
-/
theorem pit_detection_probability
    (n d : ℕ) (_hd : d < Fintype.card 𝔽)
    (f : MvPolynomial (Fin (n + 1)) 𝔽) (hf : f ≠ 0) (hdeg : f.totalDegree ≤ d) :
    1 - (d : ℚ) / (Fintype.card 𝔽 : ℚ) ≤
      (hammingWeight f : ℚ) / (Fintype.card 𝔽 : ℚ) ^ (n + 1) := by
  convert sub_le_sub_left ( pit_soundness n d _hd f hf hdeg ) 1 using 1;
  rw [ one_sub_div ( by norm_cast; exact pow_ne_zero _ ( Fintype.card_ne_zero ) ) ];
  have := hammingWeight_add_zeroCount f; rw [ ← @Nat.cast_inj ℚ ] at *; simp_all +decide [ Nat.cast_add, Nat.cast_pow ] ;
  exact eq_sub_of_add_eq this

end ReedMuller