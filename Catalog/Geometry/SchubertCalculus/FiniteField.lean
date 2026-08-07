/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.QBinomial

/-!
# Schubert calculus VIII: the point count of the Grassmannian over a finite field

This file settles the *global* half of Conjecture 1 of `FUTURE_DIRECTIONS.md`: over a finite
field `𝔽_q` the Grassmannian `Gr(k, n)` has exactly `poincare ℕ k n q = [n choose k]_q`
points, where `poincare` is the generating function of Schubert cell dimensions introduced in
`Geometry.SchubertCalculus.QBinomial`.

The proof has two independent halves.

* **Algebra.** For an arbitrary commutative ring and an arbitrary element `q`,
  `poincare R k n q * gaussProd q k k = gaussProd q n k`, where
  `gaussProd q m k = ∏_{i<k} (q^m - q^i)`.  This is proved by induction on `n` out of the
  `q`-Pascal recursion `poincare_succ` and the peeling identity `gaussProd_succ_left`; it is
  the closed product formula for the Gaussian binomial coefficient.  No hypothesis `k ≤ n` is
  needed: for `k > n` both sides vanish.

* **Geometry.** Counting linearly independent `k`-tuples of a finite `n`-dimensional space in
  two ways — Mathlib's `card_linearIndependent`, and fibrewise over the span — gives
  `#Gr(k, n) * gaussProd q k k = gaussProd q n k` in `ℕ`.  The fibration is realised by the
  explicit bijection `SchubertCalculus.spanFiberEquiv`.

Cancelling the (nonzero) factor `gaussProd q k k` yields the main theorem.

Main results:

* `SchubertCalculus.poincare_mul_gaussProd` : the closed product formula for the Gaussian
  binomial coefficient, over any commutative ring;
* `SchubertCalculus.spanFiberEquiv` : the fibre of the span map over a `k`-dimensional
  subspace `W` is the set of bases of `W`;
* `SchubertCalculus.card_grassmannian_mul_gaussProd` : the two-way count of independent
  tuples;
* `SchubertCalculus.card_grassmannian_eq_poincare` : **the point count**
  `#{W ≤ V | dim W = k} = poincare ℕ k n q` for every finite field `K` with `q` elements and
  every `n`-dimensional `K`-vector space `V`;
* `SchubertCalculus.card_grassmannian_eq_sum_pow` : the case `k = 1`, the number of lines
  `1 + q + ⋯ + q^{n-1}`;
* `SchubertCalculus.card_grassmannian_two_four_two` : `Gr(2, 𝔽₂⁴)` has `35` points.
-/

namespace SchubertCalculus

open Finset Module Submodule

/-! ### The Gaussian product `∏_{i<k} (q^m - q^i)` -/

/-- The `k`-fold product `∏_{i<k} (q^m - q^i)`.  For `q` the size of a finite field and
`m = dim V` this counts the linearly independent `k`-tuples of `V`. -/
def gaussProd {R : Type*} [CommRing R] (q : R) (m k : ℕ) : R := ∏ i ∈ range k, (q ^ m - q ^ i)

section Ring

variable {R : Type*} [CommRing R] (q : R)

@[simp] lemma gaussProd_zero (m : ℕ) : gaussProd q m 0 = 1 := by simp [gaussProd]

lemma gaussProd_succ (m k : ℕ) :
    gaussProd q m (k + 1) = gaussProd q m k * (q ^ m - q ^ k) := by
  simp [gaussProd, Finset.prod_range_succ]

/-- Peeling off the *first* factor of `gaussProd q (m+1) (k+1)` scales the remaining product
by `q^k`; this is the exact shape needed to match the `q`-Pascal recursion. -/
lemma gaussProd_succ_left (m k : ℕ) :
    gaussProd q (m + 1) (k + 1) = (q ^ (m + 1) - 1) * q ^ k * gaussProd q m k := by
  rw [gaussProd, Finset.prod_range_succ']
  simp only [pow_zero]
  have h : ∀ i ∈ range k, q ^ (m + 1) - q ^ (i + 1) = q * (q ^ m - q ^ i) := by
    intro i _; ring
  rw [Finset.prod_congr rfl h, Finset.prod_mul_distrib, Finset.prod_const, card_range, gaussProd]
  ring

lemma gaussProd_eq_zero_of_lt {k n : ℕ} (h : n < k) : gaussProd q n k = 0 :=
  Finset.prod_eq_zero (Finset.mem_range.mpr h) (by ring)

/-- **Closed product formula for the Gaussian binomial coefficient.**  The Poincaré polynomial
of `Gr(k, n)` satisfies `[n choose k]_q · ∏_{i<k}(q^k - q^i) = ∏_{i<k}(q^n - q^i)` in every
commutative ring.  Proved by induction on `n` from the `q`-Pascal recursion; for `k > n` both
sides are zero. -/
theorem poincare_mul_gaussProd (k n : ℕ) :
    poincare R k n q * gaussProd q k k = gaussProd q n k := by
  induction n generalizing k with
  | zero =>
      cases k with
      | zero => simp
      | succ j => rw [poincare_zero_right, gaussProd_eq_zero_of_lt q (Nat.succ_pos j), zero_mul]
  | succ n ih =>
      cases k with
      | zero => simp
      | succ j =>
        by_cases hjn : j ≤ n
        · have h1 := ih (j + 1)
          have h2 := ih j
          have hpow : q ^ (n - j) * q ^ j = q ^ n := by
            rw [← pow_add, Nat.sub_add_cancel hjn]
          rw [poincare_succ, add_mul, h1, gaussProd_succ_left q j j, gaussProd_succ_left q n j,
            gaussProd_succ q n j]
          calc gaussProd q n j * (q ^ n - q ^ j)
                + q ^ (n - j) * poincare R j n q * ((q ^ (j + 1) - 1) * q ^ j * gaussProd q j j)
              = gaussProd q n j * (q ^ n - q ^ j)
                + q ^ (n - j) * q ^ j * (q ^ (j + 1) - 1)
                  * (poincare R j n q * gaussProd q j j) := by ring
            _ = (q ^ (n + 1) - 1) * q ^ j * gaussProd q n j := by rw [hpow, h2]; ring
        · push_neg at hjn
          rw [poincare_eq_zero q (by omega : n + 1 < j + 1),
            gaussProd_eq_zero_of_lt q (by omega : n + 1 < j + 1), zero_mul]

end Ring

/-! ### Casting the natural-number products into `ℤ` -/

/-- The natural-number Gaussian product agrees with the integral one whenever no truncation
occurs, i.e. when `k ≤ m`. -/
lemma cast_prod_natGaussProd {q m k : ℕ} (hq : 1 ≤ q) (hk : k ≤ m) :
    ((∏ i ∈ range k, (q ^ m - q ^ i) : ℕ) : ℤ) = gaussProd (q : ℤ) m k := by
  rw [Nat.cast_prod, gaussProd]
  refine Finset.prod_congr rfl fun i hi => ?_
  have hi' : i ≤ m := le_trans (Nat.le_of_lt (Finset.mem_range.mp hi)) hk
  rw [Nat.cast_sub (Nat.pow_le_pow_right hq hi')]
  push_cast
  ring

lemma cast_poincare (k n q : ℕ) : ((poincare ℕ k n q : ℕ) : ℤ) = poincare ℤ k n (q : ℤ) := by
  rw [poincare, poincare, Nat.cast_sum]
  exact Finset.sum_congr rfl fun S _ => by push_cast; ring

/-- The Gaussian product of a field size is positive: `q^k > q^i` for `i < k` when `q ≥ 2`. -/
lemma natGaussProd_pos {q m k : ℕ} (hq : 2 ≤ q) (hk : k ≤ m) :
    0 < ∏ i ∈ range k, (q ^ m - q ^ i) := by
  refine Finset.prod_pos fun i hi => ?_
  have hi' : i < m := lt_of_lt_of_le (Finset.mem_range.mp hi) hk
  have : q ^ i < q ^ m := Nat.pow_lt_pow_right (by omega) hi'
  omega

/-! ### The two-way count of linearly independent tuples -/

section Geometry

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V] [FiniteDimensional K V]

/-- The span map from linearly independent `k`-tuples of `V` to `k`-dimensional subspaces. -/
noncomputable def spanIndep (k : ℕ) (s : {s : Fin k → V // LinearIndependent K s}) :
    {W : Submodule K V // finrank K W = k} :=
  ⟨Submodule.span K (Set.range s.1), by rw [finrank_span_eq_card s.2]; simp⟩

/-- **The Grassmannian fibration.**  The fibre of the span map over a `k`-dimensional subspace
`W` is exactly the set of bases of `W`. -/
def spanFiberEquiv (k : ℕ) (W : {W : Submodule K V // finrank K W = k}) :
    {s : {s : Fin k → V // LinearIndependent K s} // spanIndep k s = W} ≃
      {t : Fin k → W.1 // LinearIndependent K t} where
  toFun s := ⟨fun i => ⟨s.1.1 i, by
      have hW : Submodule.span K (Set.range s.1.1) = W.1 := congrArg Subtype.val s.2
      rw [← hW]; exact Submodule.subset_span ⟨i, rfl⟩⟩,
    LinearIndependent.of_comp (Submodule.subtype W.1) (by exact s.1.2)⟩
  invFun t := ⟨⟨fun i => (t.1 i : V), t.2.map' (Submodule.subtype W.1) (by simp)⟩, by
    apply Subtype.ext
    show Submodule.span K (Set.range fun i => (t.1 i : V)) = W.1
    have h1 : Submodule.span K (Set.range fun i => (t.1 i : V))
        = Submodule.map (Submodule.subtype W.1) (Submodule.span K (Set.range t.1)) := by
      rw [Submodule.map_span]
      congr 1
      rw [← Set.range_comp]
      rfl
    have h2 : Submodule.span K (Set.range t.1) = ⊤ := by
      apply Submodule.eq_top_of_finrank_eq
      rw [finrank_span_eq_card t.2]
      simp [W.2]
    rw [h1, h2]
    simp⟩
  left_inv s := by apply Subtype.ext; apply Subtype.ext; rfl
  right_inv t := by apply Subtype.ext; rfl

variable (K V)

/-- **Two-way count.**  Counting linearly independent `k`-tuples directly and fibrewise over
their span gives `#Gr(k, n) · ∏_{i<k}(q^k - q^i) = ∏_{i<k}(q^n - q^i)`. -/
theorem card_grassmannian_mul_gaussProd [Fintype K] {k : ℕ} (hk : k ≤ finrank K V) :
    Nat.card {W : Submodule K V // finrank K W = k} *
        ∏ i ∈ range k, (Fintype.card K ^ k - Fintype.card K ^ i)
      = ∏ i ∈ range k, (Fintype.card K ^ finrank K V - Fintype.card K ^ i) := by
  classical
  haveI : Finite V := Module.finite_of_finite K
  haveI : Fintype {W : Submodule K V // finrank K W = k} := Fintype.ofFinite _
  have hLHS : Nat.card {s : Fin k → V // LinearIndependent K s}
      = ∏ i ∈ range k, (Fintype.card K ^ finrank K V - Fintype.card K ^ i) := by
    rw [card_linearIndependent hk]
    exact Fin.prod_univ_eq_prod_range
      (fun i => Fintype.card K ^ finrank K V - Fintype.card K ^ i) k
  have hsig : Nat.card {s : Fin k → V // LinearIndependent K s}
      = ∑ W : {W : Submodule K V // finrank K W = k},
          Nat.card {s : {s : Fin k → V // LinearIndependent K s} // spanIndep k s = W} := by
    rw [← Nat.card_congr (Equiv.sigmaFiberEquiv (spanIndep (K := K) (V := V) k)), Nat.card_sigma]
  have hfib : ∀ W : {W : Submodule K V // finrank K W = k},
      Nat.card {s : {s : Fin k → V // LinearIndependent K s} // spanIndep k s = W}
        = ∏ i ∈ range k, (Fintype.card K ^ k - Fintype.card K ^ i) := by
    intro W
    haveI : Finite W.1 := Module.finite_of_finite K
    rw [Nat.card_congr (spanFiberEquiv k W), card_linearIndependent (K := K) (V := W.1)
      (by rw [W.2])]
    rw [Fin.prod_univ_eq_prod_range (fun i => Fintype.card K ^ finrank K W.1
      - Fintype.card K ^ i) k, W.2]
  rw [← hLHS, hsig, Finset.sum_congr rfl fun W _ => hfib W, Finset.sum_const,
    Nat.card_eq_fintype_card, smul_eq_mul, Finset.card_univ]

/-- **Point count of the Grassmannian over a finite field.**  For a finite field `K` with `q`
elements and an `n`-dimensional `K`-vector space `V`, the number of `k`-dimensional subspaces
of `V` equals the Gaussian binomial coefficient `[n choose k]_q`, i.e. the value at `q` of the
Poincaré polynomial assembled from the Schubert cell dimensions. -/
theorem card_grassmannian_eq_poincare [Fintype K] {k : ℕ} (hk : k ≤ finrank K V) :
    Nat.card {W : Submodule K V // finrank K W = k}
      = poincare ℕ k (finrank K V) (Fintype.card K) := by
  have hq : 2 ≤ Fintype.card K := Fintype.one_lt_card
  have hgeo := card_grassmannian_mul_gaussProd K V hk
  have halg := poincare_mul_gaussProd (R := ℤ) (Fintype.card K : ℤ) k (finrank K V)
  have hcast : ((Nat.card {W : Submodule K V // finrank K W = k} : ℕ) : ℤ)
      * gaussProd (Fintype.card K : ℤ) k k
      = (poincare ℕ k (finrank K V) (Fintype.card K) : ℤ) * gaussProd (Fintype.card K : ℤ) k k := by
    rw [cast_poincare, halg, ← cast_prod_natGaussProd (by omega) (le_refl k),
      ← cast_prod_natGaussProd (by omega) hk, ← Nat.cast_mul, hgeo]
  have hne : gaussProd (Fintype.card K : ℤ) k k ≠ 0 := by
    rw [← cast_prod_natGaussProd (q := Fintype.card K) (by omega) (le_refl k)]
    exact_mod_cast (natGaussProd_pos hq (le_refl k)).ne'
  exact_mod_cast mul_right_cancel₀ hne hcast

end Geometry

/-! ### Specialisations -/

/-- The Poincaré polynomial in degree `k = 1` is `1 + q + ⋯ + q^{n-1}`: the Schubert cells of
`Gr(1, n)` are indexed by the singletons `{a}`, `a < n`, and the cell of `{a}` has
dimension `a`. -/
theorem poincare_one_left {R : Type*} [CommSemiring R] (q : R) (n : ℕ) :
    poincare R 1 n q = ∑ a ∈ range n, q ^ a := by
  classical
  rw [poincare, Finset.powersetCard_one, Finset.sum_map]
  refine Finset.sum_congr rfl fun a ha => ?_
  congr 1
  show dimCell n {a} = a
  have hd : dimCell n {a} = ((range n \ {a}).filter fun b => b < a).card := by
    simp [dimCell]
  rw [hd]
  have hfil : ((range n \ {a}).filter fun b => b < a) = range a := by
    ext b
    simp only [Finset.mem_filter, Finset.mem_sdiff, Finset.mem_range, Finset.mem_singleton]
    have han : a < n := Finset.mem_range.mp ha
    constructor
    · rintro ⟨_, hba⟩; exact hba
    · intro hba; exact ⟨⟨by omega, by omega⟩, hba⟩
  rw [hfil, card_range]

/-- **The number of lines.**  A finite `n`-dimensional vector space over a field with `q`
elements has `1 + q + ⋯ + q^{n-1}` one-dimensional subspaces. -/
theorem card_grassmannian_eq_sum_pow (K V : Type*) [Field K] [Fintype K] [AddCommGroup V]
    [Module K V] [FiniteDimensional K V] (hn : 1 ≤ finrank K V) :
    Nat.card {W : Submodule K V // finrank K W = 1}
      = ∑ a ∈ range (finrank K V), Fintype.card K ^ a := by
  rw [card_grassmannian_eq_poincare K V hn, poincare_one_left]

/-- `Gr(2, 𝔽₂⁴)`, the space of planes in a four-dimensional space over the two element field,
has exactly `35` points — the classical Klein quadric count. -/
theorem card_grassmannian_two_four_two :
    Nat.card {W : Submodule (ZMod 2) (Fin 4 → ZMod 2) // finrank (ZMod 2) W = 2} = 35 := by
  have hrank : finrank (ZMod 2) (Fin 4 → ZMod 2) = 4 := by
    simp
  have h := card_grassmannian_eq_poincare (ZMod 2) (Fin 4 → ZMod 2)
    (k := 2) (by rw [hrank]; norm_num)
  rw [hrank] at h
  rw [h]
  have hc : Fintype.card (ZMod 2) = 2 := by simp
  rw [hc, poincare_two_four_two]

end SchubertCalculus