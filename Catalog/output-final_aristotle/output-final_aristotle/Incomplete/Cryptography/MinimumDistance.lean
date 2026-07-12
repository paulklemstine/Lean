/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Logic.Defs
import Cryptography.ReedMuller.SchwartzZippel

/-!
# Exact Minimum Distance of Reed–Muller Codes

## Main results

This file contains the exact minimum distance theorem for Reed–Muller evaluation codes
over finite fields, together with the explicit extremal witness polynomial.

For a finite field `𝔽_q` with `q` elements, `n ≥ 1` variables, and degree bound
`0 ≤ d < q`, the minimum Hamming distance of the Reed–Muller code RM_q(n,d) is exactly
`(q - d) · q^(n-1)`.

The key results are:

1. **`totalDegree_witnessPolynomial`**: The witness polynomial `∏ a ∈ s, (X₀ - C a)`
   has total degree at most `|s|`.

2. **`witnessPolynomial_ne_zero`**: The witness polynomial is nonzero (since
   `MvPolynomial (Fin n) 𝔽` is an integral domain).

3. **`zeroCount_witnessPolynomial`**: The witness polynomial has exactly
   `|s| · q^(n-1)` zeros.

4. **`hammingWeight_witnessPolynomial`**: The Hamming weight of the witness is
   `(q - |s|) · q^(n-1)`.

5. **`schwartz_zippel_zeroCount_bound`**: Every nonzero polynomial of degree ≤ d
   has at most `d · q^(n-1)` zeros (the Schwartz–Zippel bound).

6. **`reedMuller_minimum_distance_exact`**: The minimum distance of RM_q(n,d)
   is exactly `(q - d) · q^(n-1)`.

7. **`reedMuller_distance_attained`**: There exists an explicit polynomial attaining
   this distance.

## References

* Schwartz, J.T. (1980). Fast probabilistic algorithms for verification of polynomial identities.
* Zippel, R. (1979). Probabilistic algorithms for sparse polynomials.
* Kasami, T., Lin, S., Peterson, W. (1968). New generalizations of the Reed-Muller codes.
-/

noncomputable section

open MvPolynomial Finset Fintype

variable {𝔽 : Type*} [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]

/-! ### Degree bound for the witness polynomial -/

/-
The total degree of the witness polynomial `∏ a ∈ s, (X₀ - C a)` is at most `|s|`.
-/
theorem totalDegree_witnessPolynomial {n : ℕ} (s : Finset 𝔽) :
    (witnessPolynomial (n := n) s).totalDegree ≤ s.card := by
  convert MvPolynomial.totalDegree_finset_prod ( s := s ) ( f := fun a => ( MvPolynomial.X 0 : MvPolynomial ( Fin ( n + 1 ) ) 𝔽 ) - MvPolynomial.C a ) using 1;
  refine' Finset.card_eq_sum_ones s ▸ Finset.sum_congr rfl fun x hx => _;
  refine' le_antisymm _ _ <;> norm_num [ MvPolynomial.totalDegree ];
  · refine' ⟨ Finsupp.single 0 1, _, _ ⟩ <;> simp +decide [ MvPolynomial.coeff_X' ];
    rw [ if_neg ( ne_of_apply_ne ( fun f => f 0 ) ( by simp +decide ) ) ] ; simp +decide;
  · intro b hb; contrapose! hb; simp_all +decide [ MvPolynomial.coeff_X' ] ;
    aesop

/-! ### Nonzeroness of the witness polynomial -/

/-
The witness polynomial is nonzero, since `MvPolynomial (Fin (n+1)) 𝔽` is a domain
and each factor `X₀ - C a` is nonzero.
-/
theorem witnessPolynomial_ne_zero {n : ℕ} (s : Finset 𝔽) :
    witnessPolynomial (n := n) s ≠ 0 := by
  exact Finset.prod_ne_zero_iff.mpr fun a _ => sub_ne_zero_of_ne <| ne_of_apply_ne ( MvPolynomial.eval <| fun _ => a + 1 ) <| by simp +decide ;

/-! ### Zero count of the witness polynomial -/

/-
The zero set of the witness polynomial `∏ a ∈ s, (X₀ - C a)` consists of exactly
those points `x : Fin (n+1) → 𝔽` with `x 0 ∈ s`. The polynomial vanishes at `x` iff
the first coordinate of `x` lies in `s`.
-/
theorem witnessPolynomial_eval_eq_zero_iff {n : ℕ} (s : Finset 𝔽)
    (x : Fin (n + 1) → 𝔽) :
    MvPolynomial.eval x (witnessPolynomial (n := n) s) = 0 ↔ x 0 ∈ s := by
  unfold witnessPolynomial;
  simp +decide [ Finset.prod_eq_zero_iff, sub_eq_zero ]

/-
The number of zeros of the witness polynomial in `𝔽^(n+1)` is `|s| · q^n`.
-/
theorem zeroCount_witnessPolynomial {n : ℕ} (s : Finset 𝔽) :
    zeroCount (witnessPolynomial (n := n) s) = s.card * (Fintype.card 𝔽) ^ n := by
  convert Set.ncard_eq_toFinset_card' ( { x : Fin ( n + 1 ) → 𝔽 | ( fun x => MvPolynomial.eval x ( witnessPolynomial s ) ) x = 0 } : Set ( Fin ( n + 1 ) → 𝔽 ) ) using 1;
  · rw [ Set.ncard_eq_toFinset_card _ ] ; aesop;
  · simp +decide [ witnessPolynomial_eval_eq_zero_iff ];
    rw [ show ( Finset.univ.filter fun x : Fin ( n + 1 ) → 𝔽 => x 0 ∈ s ) = Finset.biUnion s fun a => Finset.image ( fun x : Fin n → 𝔽 => Fin.cons a x ) Finset.univ from ?_, Finset.card_biUnion ];
    · rw [ Finset.sum_congr rfl fun _ _ => Finset.card_image_of_injective _ <| fun x y hxy => by simpa [ Fin.ext_iff ] using hxy ] ; simp +decide [ Finset.card_univ ];
    · intro a ha b hb hab; simp_all +decide [ Finset.disjoint_left ] ;
      exact Ne.symm hab;
    · ext x; simp [Fin.cons];
      exact ⟨ fun hx => ⟨ x 0, hx, fun i => x i.succ, by ext i; cases i using Fin.inductionOn <;> rfl ⟩, by rintro ⟨ a, ha, y, rfl ⟩ ; simpa using ha ⟩

/-
The Hamming weight of the witness polynomial is `(q - |s|) · q^n`.
-/
theorem hammingWeight_witnessPolynomial {n : ℕ} (s : Finset 𝔽)
    (hs : s.card ≤ Fintype.card 𝔽) :
    hammingWeight (witnessPolynomial (n := n) s) =
      (Fintype.card 𝔽 - s.card) * (Fintype.card 𝔽) ^ n := by
  rw [ hammingWeight_eq_card_sub_zeroCount, zeroCount_witnessPolynomial ];
  simp +decide [ tsub_mul, pow_succ' ]

/-! ### Schwartz–Zippel bound -/

/-
**Schwartz–Zippel Lemma (zero-count form)**: A nonzero multivariate polynomial
of total degree `d` over a finite field `𝔽_q` has at most `d · q^(n-1)` zeros.

This is proved by induction on the number of variables `n`.
-/
theorem schwartz_zippel_zeroCount_bound
    (n : ℕ) (hn : 1 ≤ n) (d : ℕ)
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0) (hd : f.totalDegree ≤ d) :
    zeroCount f ≤ d * (Fintype.card 𝔽) ^ (n - 1) := by
  convert schwartz_zippel_bound n hn d f hf hd using 1

/-
**Schwartz–Zippel lower bound on Hamming weight**: A nonzero polynomial of degree ≤ d
has Hamming weight at least `(q - d) · q^(n-1)`.
-/
theorem schwartz_zippel_hammingWeight_lower_bound
    (n : ℕ) (hn : 1 ≤ n) (d : ℕ) (hd : d < Fintype.card 𝔽)
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0) (hdeg : f.totalDegree ≤ d) :
    (Fintype.card 𝔽 - d) * (Fintype.card 𝔽) ^ (n - 1) ≤ hammingWeight f := by
  -- Use hammingWeight_eq_card_sub_zeroCount to write hammingWeight f = Fintype.card (Fin n → 𝔽) - zeroCount f.
  have hammingWeight_eq_card_sub_zeroCount_f : hammingWeight f = Fintype.card (Fin n → 𝔽) - zeroCount f := by
    exact hammingWeight_eq_card_sub_zeroCount f;
  -- By schwartz_zippel_zeroCount_bound, zeroCount f ≤ d * q^(n-1).
  have zeroCount_bound : zeroCount f ≤ d * (Fintype.card 𝔽) ^ (n - 1) := by
    exact?;
  cases n <;> simp_all +decide [ pow_succ, mul_assoc, mul_tsub, tsub_mul ];
  grind

/-! ### Existence of a finset of given cardinality -/

/-
If `d ≤ |𝔽|`, there exists a subset of `𝔽` with exactly `d` elements.
-/
theorem exists_finset_card_eq (d : ℕ) (hd : d ≤ Fintype.card 𝔽) :
    ∃ s : Finset 𝔽, s.card = d := by
  -- By definition of `Finset.exists_subset_card_eq`, we can find a subset of `Fintype.elems` with cardinality `d`.
  obtain ⟨s, hs⟩ : ∃ s : Finset 𝔽, s ⊆ Fintype.elems ∧ s.card = d := by
    exact?;
  exact ⟨ s, hs.2 ⟩

/-! ### Main theorems -/

/-
**Exact minimum distance of Reed–Muller codes.**
For a finite field `𝔽_q` with `n+1 ≥ 1` variables and degree bound `d < q`,
the minimum distance of RM_q(n+1, d) is exactly `(q - d) · q^n`.
-/
theorem reedMuller_minimum_distance_exact (n d : ℕ) (hd : d < Fintype.card 𝔽) :
    isMinimumDistance 𝔽 (n + 1) d ((Fintype.card 𝔽 - d) * (Fintype.card 𝔽) ^ n) := by
  constructor;
  · exact fun f hf hd' => schwartz_zippel_hammingWeight_lower_bound _ ( Nat.succ_pos _ ) _ hd _ hf hd';
  · obtain ⟨ s, hs ⟩ := exists_finset_card_eq d ( by linarith );
    refine' ⟨ witnessPolynomial s, _, _, _ ⟩;
    · exact?;
    · exact hs ▸ totalDegree_witnessPolynomial s;
    · rw [ ← hs, hammingWeight_witnessPolynomial ];
      exact Finset.card_le_univ _

/-
**Witness theorem**: There exists a polynomial of degree ≤ d that is nonzero and
whose Hamming weight is exactly `(q - d) · q^n`, thus attaining the minimum distance.
The witness is a product of linear factors in the first coordinate.
-/
theorem reedMuller_distance_attained (n d : ℕ) (hd : d < Fintype.card 𝔽) :
    ∃ f : MvPolynomial (Fin (n + 1)) 𝔽,
      f.totalDegree ≤ d ∧
      f ≠ 0 ∧
      hammingWeight f = (Fintype.card 𝔽 - d) * (Fintype.card 𝔽) ^ n := by
  -- Use `exists_finset_card_eq` to get a finset `s` with cardinality `d`.
  obtain ⟨s, hs⟩ : ∃ s : Finset 𝔽, s.card = d := exists_finset_card_eq d hd.le
  -- Define `f` as the product of `(X₀ - C a)` for all `a ∈ s`.
  use witnessPolynomial (n := n) s
  refine ⟨?_, ?_, ?_⟩
  · -- `f.totalDegree ≤ d` by `totalDegree_witnessPolynomial`.
    exact totalDegree_witnessPolynomial s |> le_trans <| by simp [hs]
  · -- `f ≠ 0` by `witnessPolynomial_ne_zero`.
    exact witnessPolynomial_ne_zero s
  · -- `hammingWeight f = (q - d)*q^n` by `hammingWeight_witnessPolynomial`.
    exact hammingWeight_witnessPolynomial s (by linarith [hs]) ▸ by simp [hs]

/-! ### PIT Soundness -/

/-
**PIT Soundness Theorem (zero-fraction form)**: For any nonzero multivariate polynomial
`f` of total degree ≤ d over `𝔽_q^n`, the fraction of inputs where `f` vanishes is at
most `d / q`. This is the counting version that underlies polynomial identity testing.
-/
theorem pit_soundness_zero_fraction
    (n : ℕ) (hn : 1 ≤ n) (d : ℕ) (hd : d < Fintype.card 𝔽)
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0) (hdeg : f.totalDegree ≤ d) :
    (zeroCount f : ℚ) / (Fintype.card 𝔽 : ℚ) ^ n ≤ (d : ℚ) / (Fintype.card 𝔽 : ℚ) := by
  have := schwartz_zippel_zeroCount_bound n hn d f hf hdeg;
  rw [ div_le_div_iff₀ ] <;> norm_cast <;> cases n <;> simp_all +decide [ pow_succ' ] ; nlinarith;
  · exact ⟨ Fintype.card_pos, pow_pos ( Fintype.card_pos ) _ ⟩;
  · grind

end