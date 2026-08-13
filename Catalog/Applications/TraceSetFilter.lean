/-
# The trace-set filter: exact, but exactly half-sized

Let `N = p·q` be a semiprime and let `s = p + q` be its **trace**.  Fermat's
method scans candidate traces `s`; the *trace-set filter* (TRACEPROFILE) is the
free consistency test

  `s` is admissible mod `m`  ⟺  `s mod m ∈ T_m(N) := { x + N/x : x ∈ (ℤ/m)ˣ }`.

This file develops the exact theory of `T_m(N)` over an arbitrary finite field
(so in particular over `ZMod m` for a prime `m ∤ N`) and proves the facts that
the experimental round measured numerically:

* `TraceSetFilter.add_mem_traceSet` — **exactness / zero false negatives**: the
  true trace of *any* factorisation `a·b = N` lies in the trace set.  Hence the
  filter never rejects the truth (the measured `400/400` survival).
* `TraceSetFilter.mem_traceSet_iff_isSquare` — the filter is precisely the
  Fermat discriminant test: `t ∈ T` iff `t² − 4N` is a square.
* `TraceSetFilter.two_mul_card_traceSet` — **exact `2^{-1}` pruning per prime**:
  `2·|T| = (|K| − 1) + #{x : x² = N}`, hence `|K| − 1 ≤ 2|T| ≤ |K| + 1`.  A wrong
  candidate survives with probability `(1 ± 1/m)/2`: exactly the measured
  `0.1233 ≈ 2⁻³` and `0.0151 ≈ 2⁻⁶`.
* `TraceSetFilter.factorResidueSet_eq_nonzero` — the **`p`-filter is empty**: the
  set of admissible factor residues mod `m` is *all* of `(ℤ/m)ˣ`, so the filter
  only re-tests coprimality (measured survival `1.0000`).
* `TraceSetFilter.two_mul_card_traceSet_legendre` — the same count with its
  exact Legendre correction: `2·|T| = m + χ(N)`.
* `TraceSetFilter.card_ge_of_exact_filter` — **minimality**: the trace set is
  contained in every *exact* filter, so no residue-local consistency test can
  prune a wrong candidate by more than (essentially) one bit per prime.
* `TraceSetFilter.exists_factorisation_iff_isSquare_int` — **the `s`-scan is
  Fermat in disguise**: over `ℤ`, `s` is the trace of a factorisation of `N`
  iff `s² − 4N` is a perfect square.

Companion file: `Catalog/Applications/TraceSetNoAmplification.lean`, which
multiplies these local densities through the Chinese remainder theorem and shows
that the filter cannot amplify an interval hint.
-/
import Mathlib

namespace TraceSetFilter

open Finset

variable {K : Type*} [Field K] [Fintype K] [DecidableEq K]

/-! ## The trace set of `N` in a finite field -/

/-- The **trace set** of `N`: all values `x + N/x` for `x ≠ 0`.  Over `ZMod m`
this is the set of residues of `p + q` compatible with `N = p·q` mod `m`. -/
def traceSet (N : K) : Finset K := (univ.erase (0 : K)).image (fun x => x + N / x)

/-- The set of square roots of `N`: the branch points of the trace map. -/
def sqrtSet (N : K) : Finset K := univ.filter (fun x : K => x ^ 2 = N)

@[simp] theorem mem_traceSet {N t : K} : t ∈ traceSet N ↔ ∃ x : K, x ≠ 0 ∧ x + N / x = t := by
  simp [traceSet, and_comm]

@[simp] theorem mem_sqrtSet {N x : K} : x ∈ sqrtSet N ↔ x ^ 2 = N := by simp [sqrtSet]

/-! ## Exactness: no false negatives -/

/-- **The filter is exact.**  Every factorisation `a·b = N` with `a ≠ 0`
contributes its trace `a + b` to the trace set: the true trace always survives,
at every modulus.  (This is the measured `400/400` survival at every `ω ≤ 20`.) -/
theorem add_mem_traceSet (N a b : K) (ha : a ≠ 0) (hab : a * b = N) : a + b ∈ traceSet N := by
  have hb : b = N / a := by rw [eq_div_iff ha]; linear_combination hab
  exact mem_traceSet.2 ⟨a, ha, by rw [hb]⟩

/-- The **`p`-set filter is empty**: for `N ≠ 0` a residue `a` is the residue of
some factor of `N` exactly when it is invertible.  Since a prime candidate `p'`
coprime to the modulus always satisfies this, the factor-residue filter blocks
nothing — the measured coprime survival `1.0000`. -/
theorem factorResidueSet_eq_nonzero {N : K} (hN : N ≠ 0) :
    (univ.filter (fun a : K => ∃ b : K, a * b = N)) = univ.erase (0 : K) := by
  ext a
  simp only [mem_filter, mem_univ, true_and, mem_erase, and_true]
  constructor
  · rintro ⟨b, hb⟩ rfl
    exact hN (by simpa using hb.symm)
  · intro ha
    exact ⟨N / a, by field_simp⟩

/-! ## The fibres of the trace map -/

omit [Fintype K] [DecidableEq K] in
/-- Two nonzero elements have the same trace iff they are equal or *conjugate*
(`y = N/x`).  This 2-to-1 structure is what makes the filter exactly half-sized. -/
theorem traceMap_eq_iff {N x y : K} (hx : x ≠ 0) (hy : y ≠ 0) :
    x + N / x = y + N / y ↔ y = x ∨ y = N / x := by
  constructor
  · intro h
    have h0 : (x ^ 2 + N) * y = x * (y ^ 2 + N) := by field_simp at h; linear_combination h
    have h' : (y - x) * (x * y - N) = 0 := by linear_combination -h0
    rcases mul_eq_zero.1 h' with h1 | h1
    · exact Or.inl (sub_eq_zero.1 h1)
    · exact Or.inr (by rw [eq_div_iff hx]; linear_combination h1)
  · rintro (rfl | rfl)
    · rfl
    · have hN : N ≠ 0 := by intro h; rw [h] at hy; simp at hy
      field_simp
      ring

/-! ## The Fermat discriminant description -/

/-- **The trace filter is the Fermat discriminant test.**  In characteristic
`≠ 2`, a residue `t` is admissible iff `t² − 4N` is a square. -/
theorem mem_traceSet_iff_isSquare {N : K} (hN : N ≠ 0) (h2 : (2 : K) ≠ 0) (t : K) :
    t ∈ traceSet N ↔ ∃ y : K, y ^ 2 = t ^ 2 - 4 * N := by
  rw [mem_traceSet]
  constructor
  · rintro ⟨x, hx, rfl⟩
    exact ⟨x - N / x, by field_simp; ring⟩
  · rintro ⟨y, hy⟩
    have key : ((t + y) / 2) * ((t - y) / 2) = N := by field_simp; linear_combination -hy
    have hx : (t + y) / 2 ≠ 0 := by
      intro h
      rw [h, zero_mul] at key
      exact hN key.symm
    refine ⟨(t + y) / 2, hx, ?_⟩
    have hdiv : N / ((t + y) / 2) = (t - y) / 2 := by
      rw [div_eq_iff hx]; linear_combination -key
    rw [hdiv]
    field_simp
    ring

/-! ## The exact size of the filter -/

/-- **Exact `2^{-1}` pruning.**  The trace set is a two-to-one image of the
`|K| − 1` nonzero elements, branching exactly at the square roots of `N`:
`2·|T| = (|K| − 1) + #{x : x² = N}`. -/
theorem two_mul_card_traceSet {N : K} (hN : N ≠ 0) :
    2 * (traceSet N).card = (Fintype.card K - 1) + (sqrtSet N).card := by
  classical
  set S : Finset K := univ.erase (0 : K) with hS
  set R : Finset K := sqrtSet N with hR
  set T := traceSet N with hT
  have hSc : S.card = Fintype.card K - 1 := by
    rw [hS, card_erase_of_mem (mem_univ _), card_univ]
  have hmapS : ∀ x ∈ S, (fun x => x + N / x) x ∈ T := fun x hx => mem_image_of_mem _ hx
  have hRS : ∀ x ∈ R, x ∈ S := by
    intro x hx
    rw [hR, mem_sqrtSet] at hx
    simp only [hS, mem_erase, mem_univ, and_true]
    rintro rfl
    exact hN (by simpa using hx.symm)
  have hmapR : ∀ x ∈ R, (fun x => x + N / x) x ∈ T := fun x hx => hmapS x (hRS x hx)
  have e1 := Finset.card_eq_sum_card_fiberwise hmapS
  have e2 := Finset.card_eq_sum_card_fiberwise hmapR
  have key : ∀ t ∈ T, (S.filter (fun x => x + N / x = t)).card
      + (R.filter (fun x => x + N / x = t)).card = 2 := by
    intro t ht
    obtain ⟨x, hx, hfx⟩ := mem_traceSet.1 ht
    have hNx : N / x ≠ 0 := div_ne_zero hN hx
    have hfibS : S.filter (fun y => y + N / y = t) = ({x, N / x} : Finset K) := by
      ext y
      simp only [hS, mem_filter, mem_erase, mem_univ, and_true, mem_insert, mem_singleton]
      constructor
      · rintro ⟨hy0, hy⟩
        exact (traceMap_eq_iff hx hy0).1 (hfx.trans hy.symm)
      · rintro (rfl | rfl)
        · exact ⟨hx, hfx⟩
        · refine ⟨hNx, ?_⟩
          rw [← hfx]
          exact ((traceMap_eq_iff hx hNx).2 (Or.inr rfl)).symm
    by_cases hsq : x ^ 2 = N
    · have hxx : N / x = x := by rw [div_eq_iff hx]; linear_combination -hsq
      have hfibR : R.filter (fun y => y + N / y = t) = ({x} : Finset K) := by
        ext y
        simp only [hR, mem_filter, mem_sqrtSet, mem_singleton]
        constructor
        · rintro ⟨hy2, hy⟩
          have hy0 : y ≠ 0 := by rintro rfl; simp at hy2; exact hN hy2.symm
          rcases (traceMap_eq_iff hx hy0).1 (hfx.trans hy.symm) with h | h
          · exact h
          · rw [h, hxx]
        · rintro rfl; exact ⟨hsq, hfx⟩
      rw [hfibS, hfibR, hxx]
      simp
    · have hxx : N / x ≠ x := by
        intro h; exact hsq (by rw [div_eq_iff hx] at h; linear_combination -h)
      have hfibR : R.filter (fun y => y + N / y = t) = (∅ : Finset K) := by
        ext y
        simp only [hR, mem_filter, mem_sqrtSet, notMem_empty, iff_false, not_and]
        intro hy2 hy
        have hy0 : y ≠ 0 := by rintro rfl; simp at hy2; exact hN hy2.symm
        rcases (traceMap_eq_iff hx hy0).1 (hfx.trans hy.symm) with h | h
        · exact hsq (by rw [← h]; exact hy2)
        · have hxy : y * x = N := by rw [h]; field_simp
          have hz : y * (x - y) = 0 := by linear_combination hxy - hy2
          rcases mul_eq_zero.1 hz with h1 | h1
          · exact hy0 h1
          · exact hsq (by rw [sub_eq_zero.1 h1]; exact hy2)
      rw [hfibS, hfibR, card_pair (Ne.symm hxx)]
      simp
  calc 2 * T.card = ∑ _t ∈ T, 2 := by rw [sum_const, smul_eq_mul, mul_comm]
    _ = ∑ t ∈ T, ((S.filter (fun x => x + N / x = t)).card
          + (R.filter (fun x => x + N / x = t)).card) := (sum_congr rfl key).symm
    _ = S.card + R.card := by rw [sum_add_distrib, ← e1, ← e2]
    _ = (Fintype.card K - 1) + R.card := by rw [hSc]

/-- A quadratic has at most two roots: the branch correction is at most `2`. -/
theorem card_sqrtSet_le_two (N : K) : (sqrtSet N).card ≤ 2 := by
  classical
  by_cases h : ∃ r : K, r ^ 2 = N
  · obtain ⟨r, hr⟩ := h
    have : sqrtSet N ⊆ ({r, -r} : Finset K) := by
      intro x hx
      rw [mem_sqrtSet] at hx
      have : (x - r) * (x + r) = 0 := by linear_combination hx - hr
      rcases mul_eq_zero.1 this with h1 | h1
      · simp [sub_eq_zero.1 h1]
      · simp [eq_neg_of_add_eq_zero_left h1]
    exact le_trans (card_le_card this) (card_insert_le _ _ |>.trans (by simp))
  · have : sqrtSet N = ∅ := by
      ext x; simp only [mem_sqrtSet, notMem_empty, iff_false]
      intro hx; exact h ⟨x, hx⟩
    simp [this]

/-- **The filter removes exactly half, up to one element.**  In particular a
wrong candidate survives with probability `(1 ± 1/|K|)/2` — never better than
`1/2`, so `ω` primes prune by exactly `2^{-ω}` and no more. -/
theorem card_traceSet_bounds {N : K} (hN : N ≠ 0) :
    Fintype.card K - 1 ≤ 2 * (traceSet N).card ∧
      2 * (traceSet N).card ≤ Fintype.card K + 1 := by
  have h := two_mul_card_traceSet hN
  have h2 := card_sqrtSet_le_two (K := K) N
  have hpos : 0 < Fintype.card K := Fintype.card_pos_iff.2 ⟨(0 : K)⟩
  refine ⟨by rw [h]; exact Nat.le_add_right _ _, by omega⟩

/-- The filter never becomes trivial: at least `(|K| − 1)/2` residues survive. -/
theorem card_traceSet_ge {N : K} (hN : N ≠ 0) :
    (Fintype.card K - 1) / 2 ≤ (traceSet N).card := by
  have h := (card_traceSet_bounds hN).1
  calc (Fintype.card K - 1) / 2 ≤ (2 * (traceSet N).card) / 2 := Nat.div_le_div_right h
    _ = (traceSet N).card := by omega

/-! ## Minimality: no exact residue filter can do better -/

/-- **The trace set is the minimal exact filter.**  Any residue set `S` that is
exact — i.e. accepts the trace of every factorisation of `N` — contains the
whole trace set. -/
theorem traceSet_subset_of_exact {N : K} (S : Finset K)
    (hS : ∀ a b : K, a ≠ 0 → a * b = N → a + b ∈ S) : traceSet N ⊆ S := by
  intro t ht
  obtain ⟨x, hx, rfl⟩ := mem_traceSet.1 ht
  exact hS x (N / x) hx (by field_simp)

/-- **The residue-filter family is closed at one bit per prime.**  Every exact
filter retains at least `(|K| − 1)/2` residues, so *no* consistency test that
depends only on `N mod m` can prune a wrong candidate with probability better
than roughly `1/2`. -/
theorem card_ge_of_exact_filter {N : K} (hN : N ≠ 0) (S : Finset K)
    (hS : ∀ a b : K, a ≠ 0 → a * b = N → a + b ∈ S) :
    (Fintype.card K - 1) / 2 ≤ S.card :=
  le_trans (card_traceSet_ge hN) (card_le_card (traceSet_subset_of_exact S hS))

/-! ## Specialisation: prime moduli and semiprimes -/

section ZModCase

variable {m : ℕ} [Fact (Nat.Prime m)]

/-- Exactness for a genuine semiprime: if `m` divides neither `p` nor `q`, the
true trace `p + q` of `N = p·q` survives the trace filter mod `m`. -/
theorem semiprime_trace_mem (p q : ℕ) (hp : ¬ (m : ℕ) ∣ p) :
    ((p + q : ℕ) : ZMod m) ∈ traceSet ((p * q : ℕ) : ZMod m) := by
  have ha : ((p : ℕ) : ZMod m) ≠ 0 := by
    simpa [ZMod.natCast_eq_zero_iff] using hp
  have := add_mem_traceSet ((p * q : ℕ) : ZMod m) (p : ZMod m) (q : ZMod m) ha (by push_cast; ring)
  simpa using this

/-- Over `ZMod m` (`m` an odd prime, `m ∤ N`) the trace set has size
`(m ± 1)/2`: the exact `2^{-1}` pruning rate measured per prime. -/
theorem card_traceSet_zmod {N : ZMod m} (hN : N ≠ 0) :
    m - 1 ≤ 2 * (traceSet N).card ∧ 2 * (traceSet N).card ≤ m + 1 := by
  have := card_traceSet_bounds hN
  rwa [ZMod.card m] at this

/-- **The exact local survival rate.**  For an odd prime `m ∤ N`,
`2·|T| = m + χ(N)` where `χ` is the Legendre symbol: a wrong candidate survives
with probability exactly `(1 + χ(N)/m)/2`.  This is the measured `0.1233` versus
the idealised `0.125` at `ω = 3`, and `0.0151` versus `0.0156` at `ω = 6`. -/
theorem two_mul_card_traceSet_legendre (hm : m ≠ 2) (N : ℤ) (hN : ((N : ZMod m)) ≠ 0) :
    2 * ((traceSet ((N : ZMod m))).card : ℤ) = m + legendreSym m N := by
  have h := two_mul_card_traceSet hN
  have hcard : Fintype.card (ZMod m) = m := ZMod.card m
  have hroots : ((sqrtSet ((N : ZMod m))).card : ℤ) = legendreSym m N + 1 := by
    rw [← legendreSym.card_sqrts (p := m) hm N]
    congr 2
    ext x
    simp [sqrtSet]
  have hm1 : 1 ≤ m := (Fact.out : Nat.Prime m).one_lt.le.trans' (by norm_num)
  have := congrArg (fun k : ℕ => (k : ℤ)) h
  push_cast [hcard, Nat.cast_sub hm1] at this
  rw [this, hroots]
  ring

end ZModCase

/-! ## The `s`-scan is Fermat in disguise -/

/-- **Fermat equivalence over `ℤ`.**  An integer `s` is the trace of a
factorisation of `N` iff `s² − 4N` is a perfect square.  Hence scanning traces
`s` in a hinted interval *is* Fermat's difference-of-squares scan; no new
information is available to it. -/
theorem exists_factorisation_iff_isSquare_int (N s : ℤ) :
    (∃ a b : ℤ, a * b = N ∧ a + b = s) ↔ ∃ d : ℤ, d ^ 2 = s ^ 2 - 4 * N := by
  constructor
  · rintro ⟨a, b, hab, rfl⟩
    exact ⟨a - b, by linear_combination -4 * hab⟩
  · rintro ⟨d, hd⟩
    have h4 : (s - d) * (s + d) = 4 * N := by linear_combination -hd
    rcases Int.even_or_odd (s - d) with ⟨c, hc⟩ | ⟨c, hc⟩
    · refine ⟨c, s - c, ?_, by ring⟩
      have hd' : d = s - 2 * c := by omega
      subst hd'
      nlinarith [h4]
    · exfalso
      have hodd1 : ¬ (2 ∣ (s - d)) := by omega
      have hodd2 : ¬ (2 ∣ (s + d)) := by omega
      have h2 : (2 : ℤ) ∣ (s - d) * (s + d) := ⟨2 * N, by rw [h4]; ring⟩
      rcases Int.prime_two.2.2 _ _ h2 with h | h
      · exact hodd1 h
      · exact hodd2 h

/-- The concrete Fermat step: a square discriminant hands over the factorisation
explicitly. -/
theorem factor_of_disc_square {N s d : ℤ} (hd : d ^ 2 = s ^ 2 - 4 * N) :
    ((s - d) / 2) * ((s + d) / 2) = N ∧ (s - d) / 2 + (s + d) / 2 = s := by
  have h4 : (s - d) * (s + d) = 4 * N := by linear_combination -hd
  have hpar : (2 : ℤ) ∣ (s - d) := by
    rcases Int.even_or_odd (s - d) with ⟨c, hc⟩ | ⟨c, hc⟩
    · exact ⟨c, by omega⟩
    · exfalso
      have hodd1 : ¬ (2 ∣ (s - d)) := by omega
      have hodd2 : ¬ (2 ∣ (s + d)) := by omega
      have h2 : (2 : ℤ) ∣ (s - d) * (s + d) := ⟨2 * N, by rw [h4]; ring⟩
      rcases Int.prime_two.2.2 _ _ h2 with h | h
      · exact hodd1 h
      · exact hodd2 h
  obtain ⟨c, hc⟩ := hpar
  have hsd : s + d = 2 * (s - c) := by omega
  have hq1 : (s - d) / 2 = c := by omega
  have hq2 : (s + d) / 2 = s - c := by omega
  refine ⟨?_, by rw [hq1, hq2]; ring⟩
  rw [hq1, hq2]
  have hd' : d = s - 2 * c := by omega
  subst hd'
  nlinarith [h4]

/-! ## Lab notes: a kernel-verified census for `N = 3233 = 61 · 53`

The following three facts are checked by the kernel (`decide`) and match the
brute-force census recorded in `ComputationalEvidence.md`:

* `|T_13(3233)| = 7 = (13 + 1)/2` (here `χ(N) = +1`);
* `|T_17(3233)| = 8 = (17 − 1)/2` (here `χ(N) = −1`);
* the true trace `61 + 53 = 114` survives the filter mod `13`.
-/

instance : Fact (Nat.Prime 13) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 17) := ⟨by norm_num⟩

theorem card_traceSet_3233_mod_13 : (traceSet ((3233 : ZMod 13))).card = 7 := by decide

theorem card_traceSet_3233_mod_17 : (traceSet ((3233 : ZMod 17))).card = 8 := by decide

theorem true_trace_3233_mod_13 : ((61 + 53 : ℕ) : ZMod 13) ∈ traceSet ((3233 : ZMod 13)) := by
  decide

end TraceSetFilter