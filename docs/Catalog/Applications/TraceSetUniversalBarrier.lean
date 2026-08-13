/-
# The residue-filter family is closed: *no* exact local filter amplifies

`Catalog/Applications/TraceSetFilter.lean` and
`Catalog/Applications/TraceSetNoAmplification.lean` analysed one specific free
filter, the trace set `T_m(N) = {x + N/x}`.  The obvious objection is that some
*cleverer* residue filter might do better — in particular one that couples the
primes instead of testing them one at a time.  This file closes that door.

Call a filter **exact** if it never rejects the truth, i.e. it accepts the trace
`a + b` of every factorisation `a·b = N` visible at that modulus.  Exactness is
the minimal demand on a filter that is to be used inside a Fermat-style scan:
a filter that is not exact can discard the true trace.

* `TraceSetUniversalBarrier.two_le_card_of_exact` — every exact filter mod a
  prime `m ≥ 5` keeps at least two residues (`≥ (m−1)/2`, in fact).
* `TraceSetUniversalBarrier.independent_filters_no_amplification` — hence `ω`
  *arbitrary* exact filters, one per prime, still leave `≥ 2^ω` candidates in any
  window at least a primorial wide.
* `TraceSetUniversalBarrier.coupled_exact_filter_card_ge` — the strong form:
  even a single filter living on `ZMod M`, `M = ∏ mᵢ`, allowed to couple all the
  primes arbitrarily, must contain the whole composite trace set, hence has at
  least `∏ |T_{mᵢ}|` elements.
* `TraceSetUniversalBarrier.coupled_no_amplification` — consequently a coupled
  exact filter also leaves `≥ 2^ω` candidates per window, and
  `TraceSetUniversalBarrier.coupled_isolation_requires_primorial`: isolation of
  the hint forces the primorial to exceed the width of the hint window.

So the whole residue-filter family — per-prime or coupled, trace-based or not —
is sealed at one bit of pruning per prime.
-/
import Mathlib
import Applications.TraceSetFilter
import Applications.TraceSetNoAmplification

namespace TraceSetUniversalBarrier

open Finset TraceSetFilter TraceSetNoAmplification

variable {ι : Type*} [Fintype ι]

/-! ## Independent exact filters, one per prime -/

/-- Every exact filter modulo a prime `m ≥ 5` retains at least two residues. -/
theorem two_le_card_of_exact {m : ℕ} [Fact (Nat.Prime m)] (h5 : 5 ≤ m) {N : ZMod m}
    (hN : N ≠ 0) (S : Finset (ZMod m)) (hS : ∀ a b : ZMod m, a ≠ 0 → a * b = N → a + b ∈ S) :
    2 ≤ S.card := by
  have h := card_ge_of_exact_filter hN S hS
  have hcard : Fintype.card (ZMod m) = m := ZMod.card m
  rw [hcard] at h
  have : 2 ≤ (m - 1) / 2 := by omega
  omega

/-- In particular the trace filter itself keeps at least two residues. -/
theorem two_le_card_traceSet_of_ne_zero {m : ℕ} [Fact (Nat.Prime m)] (h5 : 5 ≤ m) {N : ZMod m}
    (hN : N ≠ 0) : 2 ≤ (traceSet N).card :=
  two_le_card_of_exact h5 hN (traceSet N) (fun a b ha hab => add_mem_traceSet N a b ha hab)

open scoped Function in
/-- **No per-prime filter amplifies.**  Whatever exact tests are used at the `ω`
primes — the trace filter, the factor filter, or anything else that never
rejects a genuine factorisation — a hint window at least a primorial wide still
contains at least `2^ω` surviving candidates. -/
theorem independent_filters_no_amplification (m : ι → ℕ) [∀ i, Fact (Nat.Prime (m i))]
    (h5 : ∀ i, 5 ≤ m i) (hinj : Function.Injective m)
    (Nres : ∀ i, ZMod (m i)) (hN : ∀ i, Nres i ≠ 0) (S : ∀ i, Finset (ZMod (m i)))
    (hS : ∀ i, ∀ a b : ZMod (m i), a ≠ 0 → a * b = Nres i → a + b ∈ S i)
    (a W : ℕ) (hW : ∏ i, m i ≤ W) :
    2 ^ Fintype.card ι ≤ (survivors m S a W).card :=
  le_card_survivors m (fun i => (Fact.out : Nat.Prime (m i)).pos) (pairwise_coprime hinj) S
    (fun i => two_le_card_of_exact (h5 i) (hN i) (S i) (hS i)) a W hW

/-! ## Coupled filters: a single filter modulo the primorial -/

open scoped Function in
/-- **Coupling does not help.**  A filter `S` living on `ZMod M`, `M = ∏ mᵢ`,
which accepts the trace of every unit factorisation of `N` mod `M`, necessarily
contains the whole composite trace set — and the composite trace set is, by
Chinese remaindering, the product of the local ones.  Hence `|S| ≥ ∏ |T_{mᵢ}|`
even though `S` may correlate the primes arbitrarily. -/
theorem coupled_exact_filter_card_ge (m : ι → ℕ) [NeZero (∏ i, m i)]
    [∀ i, Fact (Nat.Prime (m i))] (hcop : Pairwise (Nat.Coprime on m))
    (N : ZMod (∏ i, m i)) (S : Finset (ZMod (∏ i, m i)))
    (hS : ∀ a b : ZMod (∏ i, m i), IsUnit a → a * b = N → a + b ∈ S) :
    ∏ i, (traceSet
      (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) N)).card ≤ S.card := by
  classical
  let e := ZMod.prodEquivPi m hcop
  have hcomp : ∀ (i : ι) (s : ZMod (∏ i, m i)),
      (e s) i = ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) s := by
    intro i
    have h := RingHom.ext_zmod
      ((Pi.evalRingHom (fun i => ZMod (m i)) i).comp (e : ZMod (∏ i, m i) →+* _))
      (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)))
    intro s
    exact DFunLike.congr_fun h s
  have hcount := card_survivors_zmod m hcop (fun i =>
    traceSet (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) N))
  have hsub : (univ.filter (fun z : ZMod (∏ i, m i) => ∀ i,
      (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) z) ∈
        traceSet (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) N))) ⊆ S := by
    intro z hz
    have hz' := (mem_filter.1 hz).2
    choose x hx hxeq using fun i => mem_traceSet.1 (hz' i)
    have hxu : IsUnit ((fun i => x i) : ∀ i, ZMod (m i)) :=
      Pi.isUnit_iff.2 (fun i => isUnit_iff_ne_zero.2 (hx i))
    have hunit : IsUnit (e.symm ((fun i => x i) : ∀ i, ZMod (m i))) := hxu.map e.symm
    have hea : e (e.symm ((fun i => x i) : ∀ i, ZMod (m i))) = fun i => x i :=
      e.apply_symm_apply _
    have heb : e (e.symm ((fun i =>
        (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) N) / x i) :
          ∀ i, ZMod (m i)))
        = fun i => (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) N) / x i :=
      e.apply_symm_apply _
    have hab : e.symm ((fun i => x i) : ∀ i, ZMod (m i)) *
        e.symm ((fun i =>
          (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) N) / x i) :
            ∀ i, ZMod (m i)) = N := by
      apply e.injective
      rw [map_mul, hea, heb]
      funext i
      rw [hcomp i N]
      exact mul_div_cancel₀ _ (hx i)
    have hsum : e.symm ((fun i => x i) : ∀ i, ZMod (m i)) +
        e.symm ((fun i =>
          (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) N) / x i) :
            ∀ i, ZMod (m i)) = z := by
      apply e.injective
      rw [map_add, hea, heb]
      funext i
      rw [hcomp i z]
      exact hxeq i
    have hmem := hS _ _ hunit hab
    rwa [hsum] at hmem
  calc ∏ i, (traceSet
        (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) N)).card
      = _ := hcount.symm
    _ ≤ S.card := Finset.card_le_card hsub

open scoped Function in
/-- **No coupled filter amplifies either.**  With `ω` primes `≥ 5` not dividing
`N`, any exact filter mod `M = ∏ mᵢ` accepts at least `2^ω` of the candidates in
any window of width at least `M`. -/
theorem coupled_no_amplification (m : ι → ℕ) [NeZero (∏ i, m i)]
    [∀ i, Fact (Nat.Prime (m i))] (hcop : Pairwise (Nat.Coprime on m)) (h5 : ∀ i, 5 ≤ m i)
    (N : ZMod (∏ i, m i))
    (hN : ∀ i, (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) N) ≠ 0)
    (S : Finset (ZMod (∏ i, m i)))
    (hS : ∀ a b : ZMod (∏ i, m i), IsUnit a → a * b = N → a + b ∈ S)
    (a W : ℕ) (hW : ∏ i, m i ≤ W) :
    2 ^ Fintype.card ι
      ≤ ((Finset.Ico a (a + W)).filter (fun s : ℕ => ((s : ZMod (∏ i, m i)) ∈ S))).card := by
  classical
  have hMpos : 0 < ∏ i, m i := Finset.prod_pos (fun i _ => (Fact.out : Nat.Prime (m i)).pos)
  have hbase : 2 ^ Fintype.card ι ≤ S.card := by
    refine le_trans ?_ (coupled_exact_filter_card_ge m hcop N S hS)
    calc 2 ^ Fintype.card ι = ∏ _i : ι, 2 := by rw [Finset.prod_const, card_univ]
      _ ≤ ∏ i, (traceSet
            (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) N)).card :=
          Finset.prod_le_prod' (fun i _ =>
            two_le_card_traceSet_of_ne_zero (h5 i) (hN i))
  have hwin : ((Finset.Ico a (a + ∏ i, m i)).filter
      (fun s : ℕ => ((s : ZMod (∏ i, m i)) ∈ S))).card = S.card :=
    card_window_filter (∏ i, m i) hMpos S a
  have hmono : (Finset.Ico a (a + ∏ i, m i)).filter (fun s : ℕ => ((s : ZMod (∏ i, m i)) ∈ S))
      ⊆ (Finset.Ico a (a + W)).filter (fun s : ℕ => ((s : ZMod (∏ i, m i)) ∈ S)) := by
    intro s hs
    simp only [mem_filter, Finset.mem_Ico] at hs ⊢
    exact ⟨⟨hs.1.1, by omega⟩, hs.2⟩
  calc 2 ^ Fintype.card ι ≤ S.card := hbase
    _ = ((Finset.Ico a (a + ∏ i, m i)).filter
        (fun s : ℕ => ((s : ZMod (∏ i, m i)) ∈ S))).card := hwin.symm
    _ ≤ _ := Finset.card_le_card hmono

open scoped Function in
/-- **The seal, in its strongest form.**  If *any* exact residue filter modulo the
primorial isolates at most one candidate in a hint window of width `W`, then the
primorial already exceeds `W`: information about the trace can only come from
moduli whose product is as large as the search space itself. -/
theorem coupled_isolation_requires_primorial [Nonempty ι] (m : ι → ℕ) [NeZero (∏ i, m i)]
    [∀ i, Fact (Nat.Prime (m i))] (hcop : Pairwise (Nat.Coprime on m)) (h5 : ∀ i, 5 ≤ m i)
    (N : ZMod (∏ i, m i))
    (hN : ∀ i, (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) N) ≠ 0)
    (S : Finset (ZMod (∏ i, m i)))
    (hS : ∀ a b : ZMod (∏ i, m i), IsUnit a → a * b = N → a + b ∈ S) (a W : ℕ)
    (hiso : ((Finset.Ico a (a + W)).filter
      (fun s : ℕ => ((s : ZMod (∏ i, m i)) ∈ S))).card ≤ 1) :
    W < ∏ i, m i := by
  by_contra hcon
  push_neg at hcon
  have hcard := coupled_no_amplification m hcop h5 N hN S hS a W hcon
  have hpos : 0 < Fintype.card ι := Fintype.card_pos
  have h2 : 2 ≤ 2 ^ Fintype.card ι :=
    calc (2 : ℕ) = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ Fintype.card ι := Nat.pow_le_pow_right (by norm_num) hpos
  omega

end TraceSetUniversalBarrier