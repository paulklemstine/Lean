/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression XIV: A Short-Key `T`-wise Independent Family

## Bridge: Vandermonde determinants (linear algebra) ↔ higher independence
##         (probability) ↔ list decoding (coding theory)

`AlmostLosslessTwiseIndependent` proves that `(T+1)`-wise independence turns the
linear list-decoding gain `δ + |l|/(T·M)` into the exponential
`δ + (|l|/M)^T`, but its only witness (`fullFamily_indepT`) uses **all**
functions, i.e. `M^{|α|}` keys — exponentially long advice.  Conjecture B of the
previous cycle asked for the same independence from a *short* key.

This file settles Conjecture B (and its sub-conjecture B1) for the degree-`T`
polynomial family over a prime field:

  `h_c(x) = c₀ + c₁x + ⋯ + c_T x^T  (mod p)`,  keyed by `c ∈ (ZMod p)^{T+1}`.

* `polyEval_injective_of_agree_on_points` (**B1**) — the interpolation lemma, in
  the counting form needed here: two coefficient vectors that agree at `T+1`
  distinct points are equal.  It is proved from `Matrix.det_vandermonde_ne_zero_iff`,
  so no polynomial-degree bookkeeping is needed.
* `card_poly_constrained_le` — hence at most `p` keys make the polynomial take
  the same value at `x` as at all `T` points of `s`: the constraint pins the key
  down to its common value.
* `polyHash_indepT` — **the deliverable**: `IndepT (polyHash p T) T` with only
  `K = p^{T+1}` keys, i.e. `(T+1)·log₂ p` bits of advice.
* `exists_poly_list_scheme_exponential` — the resulting compressor: list-`T`
  decoding of any codebook with failure probability `≤ δ + (|l|/p)^T`.
* `concrete_poly_list_scheme` — a fully numeric instance: source `ZMod 101`,
  a 10-element codebook, `T = 3`, key space `101⁴ ≈ 10⁸` (27 bits of advice
  instead of the `101¹⁰¹` keys of the full family), failure probability
  `≤ 1/100 + 1/1000`, list length `≤ 3`.
* `poly_key_exponentially_shorter` — the separation from `fullFamily`: for
  `T + 1 < p` the polynomial key space `p^{T+1}` is strictly smaller than the
  `p^p` keys of the full family, and the gap is exponential in `p`.

## Impact: short_key_twise_independence, vandermonde_derandomization
-/

import Mathlib
import Bridges.AlmostLosslessTwiseIndependent
import Bridges.AlmostLosslessLinearHash

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section PolyFamily

variable (p T : ℕ) [Fact p.Prime]

/-- Evaluation of the polynomial with coefficient vector `c` at `x`. -/
def polyEval (c : Fin (T + 1) → ZMod p) (x : ZMod p) : ZMod p :=
  ∑ i, c i * x ^ (i : ℕ)

/-- **Interpolation, counting form (sub-conjecture B1).**  Two coefficient
vectors of length `T+1` that agree at `T+1` distinct points are equal: the
evaluation map is injective because the Vandermonde determinant of distinct
nodes is nonzero. -/
theorem polyEval_injective_of_agree_on_points {n : ℕ} (pts : Fin n → ZMod p)
    (hinj : Function.Injective pts) (c c' : Fin n → ZMod p)
    (h : ∀ j, ∑ i, c i * pts j ^ (i : ℕ) = ∑ i, c' i * pts j ^ (i : ℕ)) :
    c = c' := by
  have hdet : (Matrix.vandermonde pts).det ≠ 0 :=
    Matrix.det_vandermonde_ne_zero_iff.mpr hinj
  have hmul : (Matrix.vandermonde pts).mulVec (c - c') = 0 := by
    funext j
    have hj := h j
    simp only [Matrix.mulVec, Matrix.vandermonde, dotProduct, Pi.sub_apply, Pi.zero_apply,
      Matrix.of_apply, mul_sub]
    rw [Finset.sum_sub_distrib]
    simp_rw [mul_comm]
    rw [hj, sub_self]
  exact sub_eq_zero.mp (Matrix.eq_zero_of_mulVec_eq_zero hdet hmul)

/-- **The key count.**  For `T` points `s` and a further point `x`, at most `p`
coefficient vectors make the polynomial take the same value on all of `s` as at
`x`: such a polynomial is determined by that common value. -/
theorem card_poly_constrained_le (x : ZMod p) (s : Finset (ZMod p))
    (hs : s.card = T) (hx : x ∉ s) :
    (Finset.univ.filter
        (fun c : Fin (T + 1) → ZMod p => ∀ y ∈ s, polyEval p T c y = polyEval p T c x)).card
      ≤ p := by
  classical
  -- enumerate the `T+1` distinct constraint points
  have hcard : (insert x s).card = T + 1 := by
    rw [Finset.card_insert_of_notMem hx, hs]
  set e : ↥(insert x s) ≃ Fin (T + 1) := Finset.equivFinOfCardEq hcard with he
  set pts : Fin (T + 1) → ZMod p := fun j => ((e.symm j : ↥(insert x s)) : ZMod p) with hpts
  have hptsinj : Function.Injective pts := by
    intro j₁ j₂ hj
    have : e.symm j₁ = e.symm j₂ := Subtype.ext hj
    exact e.symm.injective this
  have hptsmem : ∀ j, pts j ∈ insert x s := fun j => (e.symm j).2
  -- the map `c ↦ polyEval c x` is injective on the constrained set
  have hinj : Set.InjOn (fun c : Fin (T + 1) → ZMod p => polyEval p T c x)
      ↑(Finset.univ.filter
        (fun c : Fin (T + 1) → ZMod p => ∀ y ∈ s, polyEval p T c y = polyEval p T c x)) := by
    intro c hc c' hc' hval
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hc hc'
    have hvalx : polyEval p T c x = polyEval p T c' x := hval
    refine polyEval_injective_of_agree_on_points p pts hptsinj c c' ?_
    intro j
    rcases Finset.mem_insert.mp (hptsmem j) with hj | hj
    · rw [hj]; exact hvalx
    · have h1 : polyEval p T c (pts j) = polyEval p T c x := hc _ hj
      have h2 : polyEval p T c' (pts j) = polyEval p T c' x := hc' _ hj
      have : polyEval p T c (pts j) = polyEval p T c' (pts j) := by
        rw [h1, h2, hvalx]
      exact this
  have hmaps : ∀ c ∈ Finset.univ.filter
      (fun c : Fin (T + 1) → ZMod p => ∀ y ∈ s, polyEval p T c y = polyEval p T c x),
      polyEval p T c x ∈ (Finset.univ : Finset (ZMod p)) := fun c _ => Finset.mem_univ _
  have hle := Finset.card_le_card_of_injOn _ hmaps hinj
  rwa [Finset.card_univ, ZMod.card] at hle

/-- The key space `(ZMod p)^{T+1}` has exactly `p^{T+1}` elements. -/
theorem card_poly_keys : Fintype.card (Fin (T + 1) → ZMod p) = p ^ (T + 1) := by
  simp [ZMod.card]

/-- The indexing of coefficient vectors by `Fin (p^{T+1})`. -/
noncomputable def polyKey : Fin (p ^ (T + 1)) ≃ (Fin (T + 1) → ZMod p) :=
  (Fintype.equivFinOfCardEq (card_poly_keys p T)).symm

/-- The degree-`T` polynomial hash family over `ZMod p`, with `p^{T+1}` keys. -/
noncomputable def polyHash (k : Fin (p ^ (T + 1))) (x : ZMod p) : Fin p :=
  ⟨(polyEval p T (polyKey p T k) x).val, ZMod.val_lt _⟩

theorem polyHash_eq_iff {k : Fin (p ^ (T + 1))} {x y : ZMod p} :
    polyHash p T k x = polyHash p T k y ↔
      polyEval p T (polyKey p T k) x = polyEval p T (polyKey p T k) y := by
  unfold polyHash
  rw [Fin.mk.injEq]
  exact ⟨fun h => ZMod.val_injective p h, fun h => by rw [h]⟩

/-- **Short-key `(T+1)`-wise independence (settles Conjecture B).**  The
degree-`T` polynomial family over `ZMod p` satisfies `IndepT` at level `T` with
only `p^{T+1}` keys — advice `(T+1)·log₂ p` bits — instead of the `p^p` keys of
the full function family.  Hence the exponential list-decoding gain of
`exists_list_scheme_exponential` is available from a short key. -/
theorem polyHash_indepT : IndepT (polyHash p T) T := by
  classical
  intro x s hs hx
  set e := polyKey p T with he
  -- transport the count along the key indexing
  have hbij : (Finset.univ.filter
        (fun k => ∀ y ∈ s, polyHash p T k y = polyHash p T k x)).card
      = (Finset.univ.filter (fun c : Fin (T + 1) → ZMod p =>
          ∀ y ∈ s, polyEval p T c y = polyEval p T c x)).card := by
    refine Finset.card_bij (fun k _ => e k) ?_ ?_ ?_
    · intro k hk
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hk ⊢
      intro y hy
      exact (polyHash_eq_iff p T).mp (hk y hy)
    · intro k₁ _ k₂ _ h
      exact e.injective h
    · intro c hc
      refine ⟨e.symm c, ?_, by simp [he]⟩
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hc ⊢
      intro y hy
      rw [polyHash_eq_iff]
      simpa [he] using hc y hy
  rw [hbij]
  have hcount : ((Finset.univ.filter (fun c : Fin (T + 1) → ZMod p =>
      ∀ y ∈ s, polyEval p T c y = polyEval p T c x)).card : ℝ) ≤ (p : ℝ) := by
    exact_mod_cast card_poly_constrained_le p T x s hs hx
  have hppos : (0 : ℝ) ≤ (p : ℝ) ^ T := by positivity
  calc ((Finset.univ.filter (fun c : Fin (T + 1) → ZMod p =>
        ∀ y ∈ s, polyEval p T c y = polyEval p T c x)).card : ℝ) * (p : ℝ) ^ T
      ≤ (p : ℝ) * (p : ℝ) ^ T := mul_le_mul_of_nonneg_right hcount hppos
    _ = ((p ^ (T + 1) : ℕ) : ℝ) := by push_cast; ring

/-- **The compressor with a short key.**  Instantiating the factorial-moment
theorem with the polynomial family: for every source, every duplicate-free
codebook `l` carrying all but `δ` of the mass, some degree-`T` polynomial key
gives list-`T` decoding with failure probability at most `δ + (|l|/p)^T` and
list length at most `T`.  The advice is `(T+1)·log₂ p` bits. -/
theorem exists_poly_list_scheme_exponential (μ : FinProbDist (ZMod p))
    (l : List (ZMod p)) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ k : Fin (p ^ (T + 1)),
      setMass μ (Finset.univ.filter
          (fun x => ¬ (listHashScheme T l (polyHash p T k)).Succeeds x))
          ≤ δ + ((l.length : ℝ) / p) ^ T
      ∧ (∀ i : Fin p, ((listHashScheme T l (polyHash p T k)).dec i).length ≤ T) := by
  have hp : 0 < p := (Fact.out : p.Prime).pos
  have hK : 0 < p ^ (T + 1) := Nat.pow_pos hp
  exact exists_list_scheme_exponential μ (polyHash_indepT p T) hK hp l hnd δ hδ

/-- **Coherence at `T = 1`.**  The degree-1 family `c₀ + c₁x` is 2-universal, so
the polynomial construction strictly extends the inner-product family of
`AlmostLosslessLinearHash`, and all cycle-1 results apply to it. -/
theorem polyHash_universal2_one : Universal2 (polyHash p 1) :=
  universal2_of_indepT (polyHash_indepT p 1)

end PolyFamily

/-! ## A concrete instance with explicit figures -/

section ConcretePoly

/-- **A concrete short-key list-decoding compressor.**  Source: `ZMod 101`.
Codebook: a 10-element typical set carrying all but `1/100` of the mass.
Degree `T = 3`, so the key is one of `101⁴ ≈ 1.04·10⁸` coefficient vectors
(`27` bits of advice, against `101¹⁰¹` keys for the full function family).
Then some key gives

* failure probability `≤ 1/100 + (10/101)³ ≤ 1/100 + 1/1000`,
* a decoded list of at most `3` candidates,

so the collision term is a thousand times smaller than the source's own
atypicality term. -/
theorem concrete_poly_list_scheme (μ : FinProbDist (ZMod 101))
    (l : List (ZMod 101)) (hnd : l.Nodup) (hlen : l.length = 10)
    (hδ : setMass μ (l.toFinset)ᶜ ≤ 1 / 100) :
    ∃ k : Fin (101 ^ 4),
      setMass μ (Finset.univ.filter
          (fun x => ¬ (listHashScheme 3 l (polyHash 101 3 k)).Succeeds x))
          ≤ 1 / 100 + 1 / 1000
      ∧ (∀ i : Fin 101, ((listHashScheme 3 l (polyHash 101 3 k)).dec i).length ≤ 3) := by
  obtain ⟨k, hfail, hlist⟩ :=
    exists_poly_list_scheme_exponential 101 3 μ l hnd (1 / 100) hδ
  refine ⟨k, ?_, hlist⟩
  rw [hlen] at hfail
  norm_num at hfail ⊢
  linarith

end ConcretePoly

/-- **The key really is short.**  For `T + 1 < p` the polynomial family uses
`p^{T+1}` keys where the full function family — the only previously known
witness of `IndepT` at level `T` — uses `p^p`; the ratio is `p^{p-T-1}`. -/
theorem poly_key_exponentially_shorter {p T : ℕ} (hp : 2 ≤ p) (hT : T + 1 < p) :
    p ^ (T + 1) < p ^ p :=
  Nat.pow_lt_pow_right (by omega) hT

end AlmostLossless