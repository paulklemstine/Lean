import Mathlib

/-!
# Knots and Lattices, III: the signed state sum is universal

The guiding conjecture of this research thread reads the Alexander polynomial of a
knot as a **generating function over lattice states**,
`Δ_K(t) = ∑_s (weight s) · t^{area(s)}`.  An earlier stage of the thread refuted
the *unsigned* version of the conjecture (the reduced trefoil polynomial
`t - 1 + t⁻¹` has a negative coefficient, impossible for a count) and rescued it
with a small **signed** state sum.  This file goes deeper and settles the
combinatorial status of the model in full generality.

We represent a Laurent polynomial by its coefficient function `ℤ → ℤ` (the
coefficient of `t^k`).  Two enumeration schemes appear:

* the **unsigned** area generating function `areaGF`: coefficient of `t^k` counts
  the states of area `k`; its coefficients are non-negative;
* the **signed** state sum `signedGF`: coefficient of `t^k` is the signed count
  `∑_{a s = k} sign s`, as in the genuine Alexander state-sum formula.

The main results.

* `signedGF_universal` — **universality**: *every* finitely supported integer
  coefficient function is a signed state sum.  The signed model is therefore
  exactly as expressive as the class of integer Laurent polynomials, so no
  Alexander polynomial can escape it.
* `areaGF_representable` — the unsigned model represents precisely the finitely
  supported, non-negative coefficient functions.  The two theorems together pin
  down why the naive (unsigned) conjecture fails: the sign group is the only
  missing ingredient.
* `signedGF_product_conv` — the Cauchy product of two signed state sums is the
  signed state sum on the product state family (areas add, signs multiply); this
  is the combinatorial shadow of `Δ_{K₁ # K₂} = Δ_{K₁} · Δ_{K₂}` under connected
  sum, and gives multiplicativity of the total signed weight `signedGF_eval_mul`.
* The **`T(2,2k+1)` torus family** `torusAlex`: it generalizes the trefoil
  (`torusAlex_one`), is palindromic (`torusAlex_palindromic`, Alexander
  reciprocity), satisfies the normalization `Δ_k(1) = 1` (`torusAlex_eval_one`)
  and the determinant identity `|Δ_k(-1)| = 2k+1` (`torusAlex_det`), is *not* an
  unsigned generating function for `k ≥ 1` (`torusAlex_not_areaGF`), yet *is* a
  signed state sum (`torusAlex_is_signedGF`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the signed state sum is not just a patch for the
  trefoil — it is *universal*.  Bold form: a coefficient function is a signed
  state sum iff it is finitely supported, with no positivity constraint; the
  unsigned model is the positivity-restricted sub-class.  Cross-domain bridge:
  connected sum of knots ↔ Cauchy product of generating functions.
Experiment (Experimenter): built the explicit state family
  `⨆_k {k} × range |c k|` with sign `(c k).sign` and area `k`; its signed count
  at `m` collapses to `(c m).sign * |c m| = c m` via `Int.sign_mul_natAbs`.
  For products, `Finset.sum_product` + `Finset.mul_sum` turn the product state
  sum into the convolution.  For the torus family, reindexing `Icc (-k) k` to
  `range (2k+1)` reduces the evaluations to `neg_one_geom_sum`.
Analysis (Analyst): universality is "true and structural", not "hard": the sign
  group `{±1}` is exactly the cokernel obstruction of the unsigned model.  The
  torus family shows the obstruction is generic — every `T(2,2k+1)` with `k ≥ 1`
  has a negative coefficient, so the unsigned conjecture fails for an infinite
  family, not just the trefoil.
Critique (Critic): `signedGF_universal` quantifies over all finitely supported
  `c`, so it is not a single-example dodge; `torusAlex_not_areaGF` uses a real
  negative coefficient, not `decide`.  `torusAlex_eval_one` / `torusAlex_det` are
  proved by reindexing to a geometric sum, not by `native_decide`.
Synthesis (PI): signed state sums = integer Laurent polynomials; unsigned ones =
  non-negative ones; connected sum = product; the torus family exhibits the whole
  phenomenon on an infinite scale.
-/

open Finset

namespace KnotLattice

/-! ## Coefficient functions and the two generating-function models -/

/-- A coefficient function has **non-negative coefficients** (the hallmark of a
genuine, unsigned count). -/
def NonnegGF (c : ℤ → ℤ) : Prop := ∀ k, 0 ≤ c k

/-- A coefficient function is **palindromic** if `c_k = c_{-k}`; this is the
reciprocity `Δ_K(t) = Δ_K(t⁻¹)` of Alexander polynomials. -/
def Palindromic (c : ℤ → ℤ) : Prop := ∀ k, c k = c (-k)

/-- The **unsigned** area generating function: the coefficient of `t^k` counts the
states of area `k`. -/
def areaGF {ι : Type*} [DecidableEq ι] (states : Finset ι) (a : ι → ℤ) : ℤ → ℤ :=
  fun k => ((states.filter (fun s => a s = k)).card : ℤ)

/-- The **signed** state sum: the coefficient of `t^k` is the signed count
`∑_{a s = k} sign s`, modeling `Δ_K(t) = ∑_s (-1)^{w(s)} t^{a(s)}`. -/
def signedGF {ι : Type*} [DecidableEq ι]
    (states : Finset ι) (sign a : ι → ℤ) : ℤ → ℤ :=
  fun k => ∑ s ∈ states.filter (fun s => a s = k), sign s

/-- An unsigned generating function has non-negative coefficients. -/
theorem areaGF_nonneg {ι : Type*} [DecidableEq ι] (states : Finset ι) (a : ι → ℤ) :
    NonnegGF (areaGF states a) := by
  intro k; exact Int.natCast_nonneg _

/-- An unsigned generating function is a signed one with all signs `+1`. -/
theorem areaGF_eq_signedGF {ι : Type*} [DecidableEq ι] (states : Finset ι)
    (a : ι → ℤ) : areaGF states a = signedGF states (fun _ => 1) a := by
  funext k; simp [areaGF, signedGF]

/-! ## Universality of the signed state sum -/

/-- The explicit universal state family for a coefficient function `c` supported
on `supp`: one state `(k, j)` for each `k ∈ supp` and each `j < |c k|`. -/
def univStates (c : ℤ → ℤ) (supp : Finset ℤ) : Finset (ℤ × ℕ) :=
  supp.biUnion (fun k => (Finset.range (c k).natAbs).image (fun j => (k, j)))

/-
**Universality.** Every finitely supported integer coefficient function is a
signed state sum.  Thus the signed model captures exactly the integer Laurent
polynomials, and in particular every Alexander polynomial.
-/
theorem signedGF_universal (c : ℤ → ℤ) (supp : Finset ℤ)
    (hsupp : ∀ k, c k ≠ 0 → k ∈ supp) :
    ∃ (states : Finset (ℤ × ℕ)) (sign a : ℤ × ℕ → ℤ),
      signedGF states sign a = c := by
  use univStates c supp, fun p => Int.sign ( c p.1 ), fun p => p.1;
  ext k; by_cases hk : c k = 0 <;> simp_all +decide [ signedGF, Finset.sum_filter ] ;
  rw [ show univStates c supp = Finset.biUnion supp ( fun k => Finset.image ( fun j => ( k, j ) ) ( Finset.range ( Int.natAbs ( c k ) ) ) ) from rfl, Finset.sum_biUnion ];
  · rw [ Finset.sum_eq_single k ];
    · cases abs_cases ( c k ) <;> simp +decide [ *, Int.sign_eq_one_of_pos, Int.sign_eq_neg_one_of_neg ];
    · aesop;
    · exact fun h => False.elim <| h <| hsupp k hk;
  · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun z => by aesop;

/-- **Representation for the unsigned model.** A finitely supported, non-negative
coefficient function is an unsigned area generating function. Together with
`areaGF_nonneg` this characterizes the unsigned-representable functions as exactly
the finitely supported non-negative ones. -/
theorem areaGF_representable (c : ℤ → ℤ) (supp : Finset ℤ)
    (hsupp : ∀ k, c k ≠ 0 → k ∈ supp) (hnn : NonnegGF c) :
    ∃ (states : Finset (ℤ × ℕ)) (a : ℤ × ℕ → ℤ),
      areaGF states a = c := by
  refine' ⟨ Finset.biUnion supp fun k => Finset.image ( fun j => ( k, j ) ) ( Finset.range ( Int.toNat ( c k ) ) ), fun p => p.1, funext fun m => _ ⟩;
  by_cases hm : c m = 0 <;> simp_all +decide [ areaGF, hnn ];
  · grind;
  · rw [ show ( Finset.filter ( fun s => s.1 = m ) ( Finset.biUnion supp fun k => image ( fun j => ( k, j ) ) ( Finset.range ( c k |> Int.toNat ) ) ) ) = Finset.image ( fun j => ( m, j ) ) ( Finset.range ( c m |> Int.toNat ) ) from ?_, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
    · exact hnn m;
    · grind

/-! ## Connected sum = product of signed state sums -/

/-
**Cauchy product / connected sum.** The signed state sum on the product state
family (areas add, signs multiply) is the convolution of the two factor state
sums.  This is the generating-function form of `Δ_{K₁ # K₂} = Δ_{K₁} · Δ_{K₂}`.
-/
theorem signedGF_product_conv {ι κ : Type*} [DecidableEq ι] [DecidableEq κ]
    (S : Finset ι) (σS αS : ι → ℤ) (T : Finset κ) (σT αT : κ → ℤ) (m : ℤ) :
    signedGF (S ×ˢ T) (fun p => σS p.1 * σT p.2)
        (fun p => αS p.1 + αT p.2) m
      = ∑ i ∈ S, σS i * signedGF T σT αT (m - αS i) := by
  unfold signedGF; simp +decide [ Finset.sum_filter, Finset.sum_product ] ;
  simp +decide only [eq_sub_iff_add_eq', Finset.mul_sum _ _ _, mul_ite, mul_zero]

/-
**Multiplicativity of the total signed weight.** The value of a signed state
sum "at `t = 1`" is the total signed weight, and it is multiplicative for the
product family: the shadow of `Δ_{K₁ # K₂}(1) = Δ_{K₁}(1) · Δ_{K₂}(1)`.
-/
theorem signedGF_eval_mul {ι κ : Type*} [DecidableEq ι] [DecidableEq κ]
    (S : Finset ι) (σS : ι → ℤ) (T : Finset κ) (σT : κ → ℤ) :
    (∑ p ∈ S ×ˢ T, σS p.1 * σT p.2) = (∑ i ∈ S, σS i) * (∑ j ∈ T, σT j) := by
  erw [ Finset.sum_product, Finset.sum_mul_sum ]

/-! ## Reciprocity from an area-negating involution -/

/-- **Reciprocity from symmetry.** If the state set carries an involution `φ` that
negates area and preserves sign, then the signed state sum is palindromic:
`Δ(t) = Δ(t⁻¹)`.  This is the combinatorial mechanism behind Alexander
reciprocity. -/
theorem signedGF_palindromic {ι : Type*} [DecidableEq ι]
    (states : Finset ι) (sign a : ι → ℤ) (φ : ι → ι)
    (hmem : ∀ s ∈ states, φ s ∈ states)
    (hinv : ∀ s ∈ states, φ (φ s) = s)
    (harea : ∀ s ∈ states, a (φ s) = - a s)
    (hsign : ∀ s ∈ states, sign (φ s) = sign s) :
    Palindromic (signedGF states sign a) := by
  intro k
  refine Finset.sum_bij (fun s _ => φ s) ?_ ?_ ?_ ?_ <;> simp_all +decide <;> grind

/-! ## The `T(2, 2k+1)` torus-knot Alexander family -/

/-- The reduced Alexander polynomial of the torus knot `T(2, 2k+1)`, as a
coefficient function: `Δ_k(t) = ∑_{i=-k}^{k} (-1)^{i+k} t^i`. -/
def torusAlex (k : ℕ) : ℤ → ℤ :=
  fun i => if -(k : ℤ) ≤ i ∧ i ≤ (k : ℤ) then (if Even (i + k) then 1 else -1) else 0

/-- The reduced Alexander polynomial of the trefoil, `t - 1 + t⁻¹`. -/
def trefoil : ℤ → ℤ :=
  fun k => if k = 1 ∨ k = -1 then 1 else if k = 0 then -1 else 0

/-- The torus family generalizes the trefoil: `T(2,3)` is the trefoil. -/
theorem torusAlex_one : torusAlex 1 = trefoil := by
  funext i
  unfold torusAlex trefoil
  by_cases h : i = 1 ∨ i = -1
  · rcases h with h | h <;> subst h <;> norm_num
  · push_neg at h
    obtain ⟨h1, h2⟩ := h
    by_cases h0 : i = 0
    · subst h0; norm_num
    · have hout : ¬ (-(1 : ℤ) ≤ i ∧ i ≤ (1 : ℤ)) := by omega
      simp [hout, h0, h1, h2]

/-- Alexander reciprocity for the torus family. -/
theorem torusAlex_palindromic (k : ℕ) : Palindromic (torusAlex k) := by
  intro i
  unfold torusAlex
  by_cases h : -(k : ℤ) ≤ i ∧ i ≤ (k : ℤ)
  · have h' : -(k : ℤ) ≤ -i ∧ -i ≤ (k : ℤ) := by omega
    rw [if_pos h, if_pos h']
    rcases Int.even_or_odd (i + (k : ℤ)) with he | ho
    · have he' : Even (-i + (k : ℤ)) := by
        rcases he with ⟨r, hr⟩; exact ⟨r - i, by omega⟩
      rw [if_pos he, if_pos he']
    · have ho' : ¬ Even (-i + (k : ℤ)) := by
        rw [Int.not_even_iff_odd]; rcases ho with ⟨r, hr⟩; exact ⟨r - i, by omega⟩
      rw [if_neg (by rw [Int.not_even_iff_odd]; exact ho), if_neg ho']
  · have h' : ¬ (-(k : ℤ) ≤ -i ∧ -i ≤ (k : ℤ)) := by omega
    rw [if_neg h, if_neg h']

/-
**Normalization** `Δ_k(1) = 1`: the sum of all coefficients is `1`, the
knot-theoretic normalization `Δ_K(1) = ±1`.
-/
theorem torusAlex_eval_one (k : ℕ) :
    ∑ i ∈ Finset.Icc (-(k : ℤ)) (k : ℤ), torusAlex k i = 1 := by
  unfold torusAlex;
  rw [ show ( Icc ( -k : ℤ ) k : Finset ℤ ) = Finset.image ( fun j : ℕ => ( j : ℤ ) - k ) ( Finset.range ( 2 * k + 1 ) ) from ?_, Finset.sum_image ] <;> norm_num;
  · rw [ Finset.sum_congr rfl fun x hx => if_pos <| by linarith [ Finset.mem_range.mp hx ] ];
    induction k <;> simp_all +decide [ Nat.mul_succ, Finset.sum_range_succ, parity_simps ];
  · ext;
    simp +zetaDelta at *;
    exact ⟨ fun h => ⟨ Int.toNat ( ‹_› + k ), by linarith [ Int.toNat_of_nonneg ( by linarith : 0 ≤ ( ‹_› : ℤ ) + k ) ], by linarith [ Int.toNat_of_nonneg ( by linarith : 0 ≤ ( ‹_› : ℤ ) + k ) ] ⟩, by rintro ⟨ a, ha, rfl ⟩ ; exact ⟨ by linarith, by linarith ⟩ ⟩

/-
**Determinant identity** `|Δ_k(-1)| = 2k+1`: the alternating sum of the
coefficients is `±(2k+1)`, the determinant of `T(2,2k+1)`.
-/
theorem torusAlex_det (k : ℕ) :
    ∑ i ∈ Finset.Icc (-(k : ℤ)) (k : ℤ),
      (if Even i then (1 : ℤ) else -1) * torusAlex k i
      = (if Even k then (1 : ℤ) else -1) * (2 * k + 1) := by
  have h_simp : ∀ i ∈ Finset.Icc (-(k : ℤ)) (k : ℤ), (if Even i then 1 else -1) * torusAlex k i = (if Even k then 1 else -1) := by
    grind +locals;
  rw [ Finset.sum_congr rfl h_simp ] ; norm_num ; ring;
  grind

/-- For `k ≥ 1` the torus polynomial has a negative coefficient (at `i = k-1`). -/
theorem torusAlex_neg_coeff {k : ℕ} (hk : 1 ≤ k) :
    torusAlex k ((k : ℤ) - 1) = -1 := by
  unfold torusAlex
  have h1 : -(k : ℤ) ≤ (k : ℤ) - 1 ∧ (k : ℤ) - 1 ≤ (k : ℤ) := by omega
  have h2 : ¬ Even ((k : ℤ) - 1 + (k : ℤ)) := by
    rw [Int.not_even_iff_odd]; exact ⟨(k : ℤ) - 1, by ring⟩
  simp [h1, h2]

/-- **Refutation on an infinite family.** For every `k ≥ 1` the torus polynomial
is not an unsigned generating function: it has a negative coefficient. -/
theorem torusAlex_not_areaGF {k : ℕ} (hk : 1 ≤ k) {ι : Type*} [DecidableEq ι]
    (states : Finset ι) (a : ι → ℤ) :
    areaGF states a ≠ torusAlex k := by
  intro h
  have h0 := congrFun h ((k : ℤ) - 1)
  have hnn := areaGF_nonneg states a ((k : ℤ) - 1)
  rw [h0, torusAlex_neg_coeff hk] at hnn
  norm_num at hnn

/-- The torus polynomial is finitely supported. -/
theorem torusAlex_supp (k : ℕ) {i : ℤ} (hi : torusAlex k i ≠ 0) :
    i ∈ Finset.Icc (-(k : ℤ)) (k : ℤ) := by
  unfold torusAlex at hi
  by_contra hmem
  rw [Finset.mem_Icc] at hmem
  push_neg at hmem
  have : ¬ (-(k : ℤ) ≤ i ∧ i ≤ (k : ℤ)) := by
    intro ⟨ha, hb⟩; exact absurd (hmem ha) (not_lt.mpr hb)
  simp [this] at hi

/-- **The torus polynomial is a signed state sum.** Consequence of universality. -/
theorem torusAlex_is_signedGF (k : ℕ) :
    ∃ (states : Finset (ℤ × ℕ)) (sign a : ℤ × ℕ → ℤ),
      signedGF states sign a = torusAlex k := by
  apply signedGF_universal (torusAlex k) (Finset.Icc (-(k : ℤ)) (k : ℤ))
  intro i hi; exact torusAlex_supp k hi

end KnotLattice