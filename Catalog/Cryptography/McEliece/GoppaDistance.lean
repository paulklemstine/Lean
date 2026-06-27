/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.McEliece.LinearCode

/-!
# McEliece Cryptosystem, Part II: Designed Distance of Goppa / Alternant Codes

The secret code in McEliece is a **Goppa code** `Γ(L, g)`, which is the subfield
subcode of a **generalized Reed–Solomon (GRS) code**.  Both families derive their
error-correcting power from the *designed-distance* phenomenon: a codeword is the
evaluation of a low-degree polynomial (GRS), and a polynomial of low degree has
few roots, hence few zero coordinates, hence large Hamming weight.  Dually, the
parity-check matrix has a Vandermonde structure, so a low-weight word cannot lie
in the kernel (the BCH bound).

This file proves both incarnations:

* `card_eval_zero_le_natDegree` — a nonzero polynomial has at most `deg f`
  zero coordinates among distinct evaluation points.

* `grs_min_distance` — **GRS / Reed–Solomon designed distance**: the evaluation
  vector of a nonzero polynomial of degree `< k` (at `n` distinct points) has
  Hamming weight at least `n - k + 1`.  This is the MDS (Singleton-optimal) bound
  of the parent code of every Goppa code.

* `grs_corrects_errors` — combining with the packing argument
  (`McEliece.unique_decoding`), a GRS code with `2τ + 1 ≤ n - k + 1` decodes any
  `τ`-error pattern uniquely.

* `bch_parity_min_weight` — **BCH / alternant bound (dual view)**: any nonzero
  word in the kernel of a `t × n` Vandermonde parity check (distinct columns) has
  Hamming weight strictly greater than `t`.  This is the structural reason a Goppa
  code with degree-`t` Goppa polynomial corrects `⌊t/2⌋` errors (and `t` errors in
  the binary separable case).

## References

* V. D. Goppa, *A new class of linear error-correcting codes* (1970).
* F. J. MacWilliams, N. J. A. Sloane, *The Theory of Error-Correcting Codes*,
  Ch. 12 (Alternant and Goppa codes).
-/

namespace McEliece

open Finset Polynomial

-- !-- Lab Notes -- !--
-- HYPOTHESIS (Hypothesizer): the error-correcting capacity of Goppa codes is a
--   shadow of the fundamental theorem of algebra — "few roots ⇒ many nonzeros".
--   Conjecture: weight of an evaluation codeword ≥ n - deg.
-- EXPERIMENT (Experimenter): the zero set injects into `f.roots` via the
--   injective evaluation map, bounded by `Polynomial.card_roots'`.  The dual
--   (Vandermonde) bound uses the classic BCH polynomial-multiplier trick.
-- ANALYSIS (Analyst): GRS gives the *generator* view (MDS distance n-k+1); the
--   Vandermonde kernel gives the *parity* view (BCH bound t+1).  They are the two
--   faces of the same Goppa code, related by duality.  Both feed the packing
--   lemma from `LinearCode.lean` to certify `τ`-error correction.
-- CRITIQUE (Critic): we must avoid the vacuous case `f = 0`; the hypotheses
--   `f ≠ 0` and `Function.Injective α` are essential and kept explicit.  The
--   distance is *attained* (e.g. by a product of `k-1` linear factors), so the
--   bound is tight and non-trivial.
-- SYNTHESIS (PI): the GRS generator bound and the BCH/alternant parity bound are
--   fed into the packing lemma `unique_decoding` from `LinearCode.lean` to yield
--   `grs_corrects_errors`, the concrete `t`-error-correction guarantee.
-- !-- -- !--

variable {n k : ℕ} {K : Type*} [Field K]

/-- The evaluation vector (codeword) of a polynomial `f` at points `α i`. -/
def evalVec (α : Fin n → K) (f : K[X]) : Fin n → K := fun i => f.eval (α i)

/-! ### Few roots ⇒ few zero coordinates -/

/-
A nonzero polynomial has at most `f.natDegree` zero coordinates among
distinct evaluation points.
-/
theorem card_eval_zero_le_natDegree [DecidableEq K] (α : Fin n → K)
    (hα : Function.Injective α) (f : K[X]) (hf : f ≠ 0) :
    (Finset.univ.filter (fun i => f.eval (α i) = 0)).card ≤ f.natDegree := by
  have h_evalVec_roots : Finset.card (Finset.image α (Finset.univ.filter (fun i => f.eval (α i) = 0))) ≤ f.roots.toFinset.card := by
    exact Finset.card_le_card fun x hx => by aesop;
  exact le_trans ( by rw [ Finset.card_image_of_injective _ hα ] ) ( h_evalVec_roots.trans ( le_trans ( Multiset.toFinset_card_le _ ) ( Polynomial.card_roots' _ ) ) )

/-! ### GRS / Reed–Solomon designed distance (MDS bound) -/

/-
**Generalized Reed–Solomon designed distance.**

For `n` distinct evaluation points and a nonzero polynomial `f` of degree `< k`
(with `k ≤ n`), the evaluation codeword has Hamming weight at least `n - k + 1`.
This is the minimum-distance / Singleton-optimal (MDS) bound of the parent code
of every Goppa code.
-/
theorem grs_min_distance [DecidableEq K] (α : Fin n → K)
    (hα : Function.Injective α) (hkn : k ≤ n)
    (f : K[X]) (hf : f ≠ 0) (hdeg : f.natDegree < k) :
    n - k + 1 ≤ hammingNorm (evalVec α f) := by
  convert Nat.le_sub_of_add_le' _ using 1;
  rotate_left;
  exact n;
  exact ( Finset.univ.filter fun i => f.eval ( α i ) = 0 ).card;
  · linarith [ card_eval_zero_le_natDegree α hα f hf, Nat.sub_add_cancel hkn ];
  · unfold hammingNorm evalVec; simp +decide [ Finset.filter_not, Finset.card_sdiff ] ;

/-! ### Distinct GRS codewords are far apart -/

/-
Two evaluation codewords coming from distinct polynomials of degree `< k`
differ in at least `n - k + 1` coordinates (the GRS code is linear with minimum
distance `n - k + 1`).
-/
theorem grs_dist_lower [DecidableEq K] (α : Fin n → K)
    (hα : Function.Injective α) (hkn : k ≤ n)
    (f g : K[X]) (hfg : evalVec α f ≠ evalVec α g)
    (hf : f.natDegree < k) (hg : g.natDegree < k) :
    n - k + 1 ≤ hammingDist (evalVec α f) (evalVec α g) := by
  convert grs_min_distance α hα hkn ( f - g ) _ _ using 1;
  · unfold hammingDist hammingNorm;
    simp +decide [ sub_eq_zero, evalVec ];
  · exact sub_ne_zero_of_ne ( by rintro rfl; exact hfg rfl );
  · exact lt_of_le_of_lt ( Polynomial.natDegree_sub_le _ _ ) ( max_lt hf hg )

/-! ### Unique decoding of GRS codes -/

/-
**GRS codes correct `τ` errors.**

If `2τ + 1 ≤ n - k + 1` (equivalently `τ ≤ ⌊(n-k)/2⌋`), then any received word is
within Hamming distance `τ` of at most one GRS codeword of degree `< k`.  This is
the error-correction guarantee that the McEliece decoder relies on.
-/
theorem grs_corrects_errors [DecidableEq K] (α : Fin n → K)
    (hα : Function.Injective α) (hkn : k ≤ n) (τ : ℕ)
    (hτ : 2 * τ + 1 ≤ n - k + 1)
    (r : Fin n → K) (f g : K[X])
    (hf : f.natDegree < k) (hg : g.natDegree < k)
    (hrf : hammingDist r (evalVec α f) ≤ τ)
    (hrg : hammingDist r (evalVec α g) ≤ τ) :
    evalVec α f = evalVec α g := by
  by_contra hfg;
  exact absurd ( grs_dist_lower α hα hkn f g hfg hf hg ) ( by linarith [ hammingDist_triangle ( evalVec α f ) r ( evalVec α g ), hammingDist_comm ( evalVec α f ) r, hammingDist_comm ( evalVec α g ) r ] )

/-! ### BCH / alternant bound (dual / parity-check view) -/

/-
**BCH / alternant minimum-weight bound.**

Let `α : Fin n → K` be distinct ("locators") and consider the `t × n`
Vandermonde parity check whose `j`-th syndrome of a word `c` is
`∑ i, (α i)^j · c i`.  If all `t` syndromes vanish and `c ≠ 0`, then the Hamming
weight of `c` is strictly greater than `t`.

This is the structural heart of Goppa decoding: a Goppa code with a degree-`t`
Goppa polynomial has such an (alternant) parity check, so every nonzero codeword
has weight `> t`, giving minimum distance `≥ t + 1`.
-/
theorem bch_parity_min_weight [DecidableEq K] (t : ℕ) (α : Fin n → K)
    (hα : Function.Injective α) (c : Fin n → K) (hc : c ≠ 0)
    (hsyn : ∀ j : Fin t, ∑ i, (α i) ^ (j : ℕ) * c i = 0) :
    t < hammingNorm c := by
  -- By contradiction, assume the Hamming weight of `c` is at most `t`.
  by_contra h_contra
  have h_card : (Finset.univ.filter (fun i => c i ≠ 0)).card ≤ t := by
    exact le_of_not_gt h_contra
  generalize_proofs at *; (
  -- Define the locator polynomial `p` as the product of `(X - C (α i))` for `i` in the support of `c`.
  set S := Finset.univ.filter (fun i => c i ≠ 0) with hS_def
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ ∈ S, True := by
    exact Function.ne_iff.mp hc |> Exists.imp fun i hi => by aesop;
  set p : Polynomial K := Finset.prod (S.erase i₀) (fun i => Polynomial.X - Polynomial.C (α i)) with hp_def
  have hp_deg : p.natDegree ≤ t - 1 := by
    rw [ Polynomial.natDegree_prod _ _ fun i hi => Polynomial.X_sub_C_ne_zero _ ] ; simp_all +decide [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] ; omega;
  generalize_proofs at *; (
  -- Let `T := ∑ i, c i * p.eval (α i)`. We compute `T` two ways and get `0 ≠ 0`.
  have hT_ne_zero : ∑ i, c i * p.eval (α i) ≠ 0 := by
    rw [ Finset.sum_eq_single i₀ ] <;> simp_all +decide [ Polynomial.eval_prod, Finset.prod_eq_zero_iff, sub_eq_zero, hα.eq_iff ];
    exact fun _ _ => em _
  generalize_proofs at *; (
  -- On the other hand, we can expand `p.eval (α i)` using the definition of `p`.
  have hT_expand : ∑ i, c i * p.eval (α i) = ∑ j ∈ Finset.range (p.natDegree + 1), p.coeff j * ∑ i, (α i) ^ j * c i := by
    simp +decide only [eval_eq_sum_range, Finset.mul_sum _ _ _];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring )
  generalize_proofs at *; (
  exact hT_ne_zero ( hT_expand.trans ( Finset.sum_eq_zero fun j hj => by rw [ hsyn ⟨ j, by linarith [ Finset.mem_range.mp hj, Nat.sub_add_cancel ( show 1 ≤ t from Nat.pos_of_ne_zero ( by aesop_cat ) ) ] ⟩ ] ; ring ) )))))

end McEliece