/-
# The trace-set filter cannot amplify an interval hint

`Catalog/Applications/TraceSetFilter.lean` proved the two *local* facts about the
free trace filter mod a prime `m`:

* it is **exact** — the true trace `p+q` of `N = p·q` always survives, and
* it is **exactly half-sized** — `m − 1 ≤ 2·|T_m| ≤ m + 1`.

This file multiplies the local densities together through the Chinese remainder
theorem and draws the negative conclusion measured experimentally: an external
hint `s ∈ [s₀ − E, s₀ + E]` is **not** amplified by the filter.

* `TraceSetNoAmplification.card_survivors_zmod` — CRT independence: modulo
  `M = ∏ mᵢ` the survivors are exactly the CRT-products, `∏ |Tᵢ|` of them.
* `TraceSetNoAmplification.card_survivors_interval` — the same count holds in
  *every* window of `M` consecutive integers (translation invariance): the
  filter is a union of residue classes and carries no positional information.
* `TraceSetNoAmplification.le_card_survivors` — hence `2^ω` survivors whenever
  the hint window is at least a primorial wide.
* `TraceSetNoAmplification.trace_filter_no_amplification` and
  `TraceSetNoAmplification.trace_filter_never_isolates` — for the actual trace
  sets: at least `2^ω` candidates survive, one of which is the true trace and at
  least `2^ω − 1` of which are spurious.  Isolation of `s` therefore *requires*
  the primorial `∏ mᵢ` to exceed the hint width — the exponential seal.
* `TraceSetNoAmplification.card_traceSurvivors_bounds` — the exact window count
  `∏ |Tᵢ| ∈ [∏ (mᵢ−1)/2, ∏ (mᵢ+1)/2]`, i.e. `≈ W·2^{-ω}`, matching the measured
  `(2E+1)·2^{-ω} + 1` law.
-/
import Mathlib
import Applications.TraceSetFilter

namespace TraceSetNoAmplification

open Finset TraceSetFilter

variable {ι : Type*} [Fintype ι]

/-! ## CRT independence of the residue filters -/

open scoped Function in
/-- **Chinese remainder independence.**  Modulo `M = ∏ mᵢ` (pairwise coprime),
the residues passing all the filters `Tᵢ` are exactly the CRT products; there
are `∏ |Tᵢ|` of them.  No filter can interfere with another. -/
theorem card_survivors_zmod (m : ι → ℕ) [NeZero (∏ i, m i)]
    (hcop : Pairwise (Nat.Coprime on m)) (T : ∀ i, Finset (ZMod (m i))) :
    (univ.filter (fun s : ZMod (∏ i, m i) =>
        ∀ i, (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) s) ∈ T i)).card
      = ∏ i, (T i).card := by
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
  rw [← Fintype.card_piFinset T]
  refine Finset.card_equiv e.toEquiv ?_
  intro s
  simp only [mem_filter, mem_univ, true_and, Fintype.mem_piFinset]
  constructor
  · intro h i; rw [show e.toEquiv s = e s from rfl, hcomp i s]; exact h i
  · intro h i; have := h i; rwa [show e.toEquiv s = e s from rfl, hcomp i s] at this

/-! ## Survivors inside a hint window -/

/-- The candidates of the window `[a, a+W)` that pass every residue filter. -/
def survivors (m : ι → ℕ) (T : ∀ i, Finset (ZMod (m i))) (a W : ℕ) : Finset ℕ :=
  (Finset.Ico a (a + W)).filter (fun s : ℕ => ∀ i, ((s : ZMod (m i)) ∈ T i))

theorem mem_survivors {m : ι → ℕ} {T : ∀ i, Finset (ZMod (m i))} {a W s : ℕ} :
    s ∈ survivors m T a W ↔ (a ≤ s ∧ s < a + W) ∧ ∀ i, ((s : ZMod (m i)) ∈ T i) := by
  simp [survivors, Finset.mem_Ico, and_assoc]

/-- **Every periodic filter is positionally blind.**  A filter given by a set `S`
of residues mod `M` accepts exactly `|S|` of any `M` consecutive integers,
wherever the window starts. -/
theorem card_window_filter (M : ℕ) (hM : 0 < M) (S : Finset (ZMod M)) (a : ℕ) :
    ((Finset.Ico a (a + M)).filter (fun s : ℕ => ((s : ZMod M) ∈ S))).card = S.card := by
  classical
  haveI : NeZero M := ⟨hM.ne'⟩
  refine Finset.card_bij (fun s _ => (s : ZMod M)) ?_ ?_ ?_
  · intro s hs
    exact (mem_filter.1 hs).2
  · intro s hs t ht hst
    simp only [mem_filter, Finset.mem_Ico] at hs ht
    have hmod : s ≡ t [MOD M] := (ZMod.natCast_eq_natCast_iff _ _ _).1 hst
    rcases le_total s t with h | h
    · have hd := (Nat.modEq_iff_dvd' h).1 hmod
      rcases Nat.eq_zero_or_pos (t - s) with h0 | h0
      · omega
      · have := Nat.le_of_dvd h0 hd; omega
    · have hd := (Nat.modEq_iff_dvd' h).1 hmod.symm
      rcases Nat.eq_zero_or_pos (s - t) with h0 | h0
      · omega
      · have := Nat.le_of_dvd h0 hd; omega
  · intro z hz
    have hlt : ((z - (a : ZMod M)).val) < M := ZMod.val_lt _
    have hcast : ((a + ((z - (a : ZMod M)).val) : ℕ) : ZMod M) = z := by
      push_cast
      rw [ZMod.natCast_val, ZMod.cast_id]
      ring
    refine ⟨a + ((z - (a : ZMod M)).val), ?_, hcast⟩
    simp only [mem_filter, Finset.mem_Ico]
    exact ⟨⟨by omega, by omega⟩, by rw [hcast]; exact hz⟩

open scoped Function in
/-- **Translation invariance / exact window count.**  Every window of `M = ∏ mᵢ`
consecutive integers contains exactly `∏ |Tᵢ|` survivors, independently of where
the window sits.  The filter therefore transports no information about the
location of the hint. -/
theorem card_survivors_interval (m : ι → ℕ) (hm : ∀ i, 0 < m i)
    (hcop : Pairwise (Nat.Coprime on m)) (T : ∀ i, Finset (ZMod (m i))) (a : ℕ) :
    (survivors m T a (∏ i, m i)).card = ∏ i, (T i).card := by
  classical
  set M := ∏ i, m i with hM
  have hMpos : 0 < M := Finset.prod_pos (fun i _ => hm i)
  haveI : NeZero M := ⟨hMpos.ne'⟩
  set S : Finset (ZMod M) :=
    univ.filter (fun z : ZMod M =>
      ∀ i, (ZMod.castHom (Finset.dvd_prod_of_mem m (mem_univ i)) (ZMod (m i)) z) ∈ T i) with hS
  have hpred : survivors m T a M
      = (Finset.Ico a (a + M)).filter (fun s : ℕ => ((s : ZMod M) ∈ S)) := by
    ext s
    simp only [survivors, mem_filter, hS, mem_univ, true_and]
    constructor
    · rintro ⟨hs, h⟩
      refine ⟨hs, ?_⟩
      intro i
      rw [map_natCast]
      exact h i
    · rintro ⟨hs, h⟩
      refine ⟨hs, ?_⟩
      intro i
      have := h i
      rwa [map_natCast] at this
  rw [hpred, card_window_filter M hMpos S a, hS, card_survivors_zmod m hcop T]

open scoped Function in
/-- **The census scales linearly with the hint width.**  A window of `k` full
periods contains exactly `k · ∏ |Tᵢ|` survivors.  Widening the hint by a factor
`k` multiplies the number of surviving candidates by `k`: the filter fixes the
*density* at `2^{-ω}` and can never convert width into resolution. -/
theorem card_survivors_periods (m : ι → ℕ) (hm : ∀ i, 0 < m i)
    (hcop : Pairwise (Nat.Coprime on m)) (T : ∀ i, Finset (ZMod (m i))) (a k : ℕ) :
    (survivors m T a (k * ∏ i, m i)).card = k * ∏ i, (T i).card := by
  classical
  induction k generalizing a with
  | zero => simp [survivors]
  | succ k ih =>
      have hsplit : survivors m T a ((k + 1) * ∏ i, m i)
          = survivors m T a (k * ∏ i, m i) ∪ survivors m T (a + k * ∏ i, m i) (∏ i, m i) := by
        unfold survivors
        rw [← Finset.filter_union]
        congr 1
        rw [Finset.Ico_union_Ico_eq_Ico (by omega) (by ring_nf; omega)]
        congr 1
        ring
      have hdisj : Disjoint (survivors m T a (k * ∏ i, m i))
          (survivors m T (a + k * ∏ i, m i) (∏ i, m i)) := by
        refine Finset.disjoint_left.2 ?_
        intro x hx hx'
        rw [mem_survivors] at hx hx'
        omega
      rw [hsplit, Finset.card_union_of_disjoint hdisj, ih,
        card_survivors_interval m hm hcop T (a + k * ∏ i, m i)]
      ring

/-- Widening the window only adds survivors. -/
theorem survivors_mono (m : ι → ℕ) (T : ∀ i, Finset (ZMod (m i))) (a : ℕ) {W W' : ℕ}
    (h : W ≤ W') : survivors m T a W ⊆ survivors m T a W' := by
  intro s hs
  rw [mem_survivors] at hs ⊢
  exact ⟨⟨hs.1.1, lt_of_lt_of_le hs.1.2 (by omega)⟩, hs.2⟩

open scoped Function in
/-- **No amplification.**  If every filter keeps at least two residues — which,
by `TraceSetFilter.card_traceSet_ge`, the trace filters always do — then any
window at least a primorial wide retains at least `2^ω` candidates.  Pruning by
`2^{-ω}` is exactly compensated by the size of the window. -/
theorem le_card_survivors (m : ι → ℕ) (hm : ∀ i, 0 < m i)
    (hcop : Pairwise (Nat.Coprime on m)) (T : ∀ i, Finset (ZMod (m i)))
    (hT : ∀ i, 2 ≤ (T i).card) (a W : ℕ) (hW : ∏ i, m i ≤ W) :
    2 ^ Fintype.card ι ≤ (survivors m T a W).card := by
  have hsub := survivors_mono m T a hW
  have hcount := card_survivors_interval m hm hcop T a
  have hprod : 2 ^ Fintype.card ι ≤ ∏ i, (T i).card := by
    calc 2 ^ Fintype.card ι = ∏ _i : ι, 2 := by
          rw [Finset.prod_const, card_univ]
      _ ≤ ∏ i, (T i).card := Finset.prod_le_prod' (fun i _ => hT i)
  calc 2 ^ Fintype.card ι ≤ ∏ i, (T i).card := hprod
    _ = (survivors m T a (∏ i, m i)).card := hcount.symm
    _ ≤ (survivors m T a W).card := Finset.card_le_card hsub

/-! ## The trace filters themselves -/

section Trace

variable (N : ℕ) (m : ι → ℕ) [∀ i, Fact (Nat.Prime (m i))]

/-- Candidates of the hint window surviving every *trace* filter. -/
def traceSurvivors (a W : ℕ) : Finset ℕ :=
  survivors m (fun i => traceSet ((N : ZMod (m i)))) a W

variable {N m}

omit [Fintype ι] in
/-- Distinct primes give pairwise coprime moduli. -/
theorem pairwise_coprime (hinj : Function.Injective m) :
    Pairwise (Function.onFun Nat.Coprime m) := by
  intro i j hij
  exact (Nat.coprime_primes (Fact.out) (Fact.out)).2 (fun h => hij (hinj h))

/-- **Exactness inside the window.**  For `N = p·q` with no modulus dividing `p`,
the true trace `p + q` survives every trace filter: the measured `400/400`. -/
theorem true_trace_mem_traceSurvivors {p q a W : ℕ} (hN : N = p * q)
    (hp : ∀ i, ¬ (m i : ℕ) ∣ p) (hmem : a ≤ p + q ∧ p + q < a + W) :
    p + q ∈ traceSurvivors N m a W := by
  rw [traceSurvivors, mem_survivors]
  refine ⟨hmem, fun i => ?_⟩
  have h := semiprime_trace_mem (m := m i) p q (hp i)
  have hcast : ((N : ℕ) : ZMod (m i)) = ((p * q : ℕ) : ZMod (m i)) := by rw [hN]
  rw [hcast]
  exact h

omit [Fintype ι] in
/-- Each trace filter keeps at least two residues once the modulus is `≥ 5`. -/
theorem two_le_card_traceSet_of_five_le {i : ι} (h5 : 5 ≤ m i)
    (hN : ¬ (m i : ℕ) ∣ N) : 2 ≤ (traceSet ((N : ZMod (m i)))).card := by
  have hne : ((N : ℕ) : ZMod (m i)) ≠ 0 := by
    simpa [ZMod.natCast_eq_zero_iff] using hN
  have hge := card_traceSet_ge hne
  have hcard : Fintype.card (ZMod (m i)) = m i := ZMod.card _
  rw [hcard] at hge
  have : 2 ≤ (m i - 1) / 2 := by omega
  omega

/-- **The trace filter does not amplify a hint.**  With `ω` odd prime moduli
`≥ 5` and a hint window at least `∏ mᵢ` wide, at least `2^ω` candidate traces
survive all filters.  The `2^{-ω}` pruning is exactly cancelled by the width of
the window that still has to be scanned. -/
theorem trace_filter_no_amplification (h5 : ∀ i, 5 ≤ m i) (hinj : Function.Injective m)
    (hN : ∀ i, ¬ (m i : ℕ) ∣ N) (a W : ℕ) (hW : ∏ i, m i ≤ W) :
    2 ^ Fintype.card ι ≤ (traceSurvivors N m a W).card :=
  le_card_survivors m (fun i => (Fact.out : Nat.Prime (m i)).pos) (pairwise_coprime hinj) _
    (fun i => two_le_card_traceSet_of_five_le (h5 i) (hN i)) a W hW

/-- **The filter never isolates the trace.**  If at least one modulus is used and
the window is at least a primorial wide, then besides the true trace `p+q` there
is always another surviving candidate: the certificate is consistent but
information-useless. -/
theorem trace_filter_never_isolates [Nonempty ι] (h5 : ∀ i, 5 ≤ m i)
    (hinj : Function.Injective m) (hN : ∀ i, ¬ (m i : ℕ) ∣ N) {p q a W : ℕ}
    (hfact : N = p * q) (hp : ∀ i, ¬ (m i : ℕ) ∣ p) (hmem : a ≤ p + q ∧ p + q < a + W)
    (hW : ∏ i, m i ≤ W) :
    (p + q) ∈ traceSurvivors N m a W ∧ ∃ s ∈ traceSurvivors N m a W, s ≠ p + q := by
  refine ⟨true_trace_mem_traceSurvivors hfact hp hmem, ?_⟩
  have hcard := trace_filter_no_amplification h5 hinj hN a W hW
  have hpos : 0 < Fintype.card ι := Fintype.card_pos
  have h2 : 2 ≤ 2 ^ Fintype.card ι := by
    calc (2 : ℕ) = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ Fintype.card ι := Nat.pow_le_pow_right (by norm_num) hpos
  have hlt : 1 < (traceSurvivors N m a W).card := by omega
  exact Finset.exists_mem_ne hlt _

/-- **The exact window census.**  In a window of `M = ∏ mᵢ` consecutive
candidates the number of survivors is exactly `∏ |Tᵢ|`, which is squeezed
between `∏ (mᵢ−1)/2` and `∏ (mᵢ+1)/2`: the pruning factor is `2^{-ω}` up to the
`1/mᵢ` corrections, and never better. -/
theorem card_traceSurvivors_bounds (hinj : Function.Injective m)
    (hN : ∀ i, ¬ (m i : ℕ) ∣ N) (a : ℕ) :
    (∏ i, (m i - 1)) ≤ 2 ^ Fintype.card ι * (traceSurvivors N m a (∏ i, m i)).card ∧
      2 ^ Fintype.card ι * (traceSurvivors N m a (∏ i, m i)).card ≤ ∏ i, (m i + 1) := by
  classical
  set T : ∀ i, Finset (ZMod (m i)) := fun i => traceSet ((N : ZMod (m i))) with hT
  have hcount : (traceSurvivors N m a (∏ i, m i)).card = ∏ i, (T i).card :=
    card_survivors_interval m (fun i => (Fact.out : Nat.Prime (m i)).pos)
      (pairwise_coprime hinj) T a
  have hlocal : ∀ i, m i - 1 ≤ 2 * (T i).card ∧ 2 * (T i).card ≤ m i + 1 := by
    intro i
    have hne : ((N : ℕ) : ZMod (m i)) ≠ 0 := by
      simpa [ZMod.natCast_eq_zero_iff] using hN i
    exact card_traceSet_zmod hne
  have key : 2 ^ Fintype.card ι * ∏ i, (T i).card = ∏ i, (2 * (T i).card) := by
    rw [Finset.prod_mul_distrib, Finset.prod_const, card_univ]
  rw [hcount, key]
  exact ⟨Finset.prod_le_prod' (fun i _ => (hlocal i).1),
    Finset.prod_le_prod' (fun i _ => (hlocal i).2)⟩

/-- **The exact global census.**  With `ω` distinct odd prime moduli, a window of
`M = ∏ mᵢ` consecutive candidates contains exactly `∏ (mᵢ + χᵢ(N)) / 2^ω`
survivors: the `2^{-ω}` law with its exact Legendre corrections. -/
theorem two_pow_mul_card_traceSurvivors (hinj : Function.Injective m)
    (hodd : ∀ i, m i ≠ 2) (hN : ∀ i, ¬ (m i : ℕ) ∣ N) (a : ℕ) :
    (2 : ℤ) ^ Fintype.card ι * ((traceSurvivors N m a (∏ i, m i)).card : ℤ)
      = ∏ i, ((m i : ℤ) + legendreSym (m i) (N : ℤ)) := by
  classical
  set T : ∀ i, Finset (ZMod (m i)) := fun i => traceSet ((N : ZMod (m i))) with hT
  have hcount : (traceSurvivors N m a (∏ i, m i)).card = ∏ i, (T i).card :=
    card_survivors_interval m (fun i => (Fact.out : Nat.Prime (m i)).pos)
      (pairwise_coprime hinj) T a
  have hlocal : ∀ i, 2 * ((T i).card : ℤ) = (m i : ℤ) + legendreSym (m i) (N : ℤ) := by
    intro i
    have hcast : (((N : ℤ)) : ZMod (m i)) = ((N : ℕ) : ZMod (m i)) := by push_cast; ring
    have hne : ((N : ℤ) : ZMod (m i)) ≠ 0 := by
      rw [hcast]
      simpa [ZMod.natCast_eq_zero_iff] using hN i
    have h := two_mul_card_traceSet_legendre (m := m i) (hodd i) (N : ℤ) hne
    rw [hcast] at h
    exact h
  calc (2 : ℤ) ^ Fintype.card ι * ((traceSurvivors N m a (∏ i, m i)).card : ℤ)
      = ∏ i, (2 * ((T i).card : ℤ)) := by
        rw [hcount, Finset.prod_mul_distrib, Finset.prod_const, card_univ]
        push_cast
        ring
    _ = ∏ i, ((m i : ℤ) + legendreSym (m i) (N : ℤ)) := Finset.prod_congr rfl (fun i _ => hlocal i)

/-- **The no-hint search is exponentially sealed.**  Over a search range of `k`
periods the trace filters leave at least `k · 2^ω` candidates.  Reducing a range
of size `R` to polynomially many candidates therefore needs `∏ mᵢ ≳ R`: with
distinct primes that product is a primorial, so the number of moduli — and the
work of building their filters — grows out of polynomial reach. -/
theorem trace_survivors_periods_ge (h5 : ∀ i, 5 ≤ m i) (hinj : Function.Injective m)
    (hN : ∀ i, ¬ (m i : ℕ) ∣ N) (a k : ℕ) :
    k * 2 ^ Fintype.card ι ≤ (traceSurvivors N m a (k * ∏ i, m i)).card := by
  have hcount : (traceSurvivors N m a (k * ∏ i, m i)).card
      = k * ∏ i, (traceSet ((N : ZMod (m i)))).card :=
    card_survivors_periods m (fun i => (Fact.out : Nat.Prime (m i)).pos) (pairwise_coprime hinj)
      _ a k
  have hprod : 2 ^ Fintype.card ι ≤ ∏ i, (traceSet ((N : ZMod (m i)))).card := by
    calc 2 ^ Fintype.card ι = ∏ _i : ι, 2 := by rw [Finset.prod_const, card_univ]
      _ ≤ _ := Finset.prod_le_prod' (fun i _ =>
          two_le_card_traceSet_of_five_le (h5 i) (hN i))
  rw [hcount]
  exact Nat.mul_le_mul_left k hprod

/-- **The exponential seal.**  If the trace filters isolate at most one candidate
in a hint window of width `W`, then the primorial of the moduli must already
exceed `W`.  Resolving a `k`-bit hint therefore costs a modulus product of size
`2^k`: the filter is `Ω(N)`-sealed and never amplifies. -/
theorem isolation_requires_primorial [Nonempty ι] (h5 : ∀ i, 5 ≤ m i)
    (hinj : Function.Injective m) (hN : ∀ i, ¬ (m i : ℕ) ∣ N) (a W : ℕ)
    (hiso : (traceSurvivors N m a W).card ≤ 1) : W < ∏ i, m i := by
  by_contra hcon
  push_neg at hcon
  have hcard := trace_filter_no_amplification h5 hinj hN a W hcon
  have hpos : 0 < Fintype.card ι := Fintype.card_pos
  have h2 : 2 ≤ 2 ^ Fintype.card ι :=
    calc (2 : ℕ) = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ Fintype.card ι := Nat.pow_le_pow_right (by norm_num) hpos
  omega

end Trace

/-! ## Lab notes: a kernel-verified window census

`N = 3233 = 61 · 53`, moduli `{3, 5, 7}`, so `M = 105`.  The trace sets have
sizes `1, 2, 3`, and the theory predicts exactly `1 · 2 · 3 = 6` survivors in
*every* window of `105` consecutive candidates.  Two different windows are
checked by the kernel below, together with the survival of the true trace
`61 + 53 = 114`.
-/

namespace Census

instance : Fact (Nat.Prime 3) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 5) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 7) := ⟨by norm_num⟩

/-- The three moduli of the census. -/
def mods : Fin 3 → ℕ := ![3, 5, 7]

instance factMods : ∀ i, Fact (Nat.Prime (mods i)) := by
  intro i
  fin_cases i <;> exact ⟨by norm_num [mods]⟩

theorem census_window_zero :
    (traceSurvivors 3233 mods 0 105).card = 6 := by decide

theorem census_window_shifted :
    (traceSurvivors 3233 mods 500 105).card = 6 := by decide

theorem census_true_trace : 114 ∈ traceSurvivors 3233 mods 100 105 := by decide

end Census

end TraceSetNoAmplification