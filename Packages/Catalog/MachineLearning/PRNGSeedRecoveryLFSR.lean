/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Seed Recovery for Linear Feedback Shift Registers

This module formalises the mathematical core of *seed recovery* for the LFSR
family of pseudo-random generators, the first half of the "detect PRNG output
and replace the file by its seed" programme (see
`MachineLearning.PRNGCompressionBound` for the counting-side limits).

An LFSR of order `L` over a commutative ring `F` with tap vector
`c : Fin L → F` produces a stream `x : ℕ → F` obeying

  `x (n + L) = ∑ i < L, c i * x (n + i)`.

## Main results

* `lfsrRun` — the generator: run the register from an explicit seed.
* `lfsrRun_isLinRec`, `lfsrRun_of_lt` — the generator does what it claims.
* `IsLinRec.ext_of_agree` — **rigidity**: two streams with the same taps that
  agree on one window of length `L` agree forever.
* `IsLinRec.seed_recovery` — **the falsifiability gate**: any stream obeying the
  recurrence is *exactly* reproduced by re-running the register from its own
  first `L` symbols.  Nothing beyond the seed has to be stored.
* `linRec_taps_unique_of_span` — **Berlekamp–Massey uniqueness**: if the first
  `L` state windows span `F^L`, the tap vector is uniquely determined by the
  stream, so seed recovery has a unique answer.
* `hankel_span_of_taps_unique` — the converse over a field: tap uniqueness
  forces the windows to span.  Spanning is therefore *exactly* the right
  nondegeneracy condition.

## Application keywords

LFSR, linear recurrence, Berlekamp–Massey, seed recovery, PRNG fingerprinting,
stream compression
-/

import Mathlib

open Finset

namespace PRNGSeed

section Ring

variable {F : Type*} [CommRing F]

/-- `IsLinRec L c x` : the stream `x` obeys the order-`L` linear recurrence with
tap vector `c`, i.e. it is an output stream of the corresponding LFSR. -/
def IsLinRec (L : ℕ) (c : Fin L → F) (x : ℕ → F) : Prop :=
  ∀ n : ℕ, x (n + L) = ∑ i : Fin L, c i * x (n + i)

/-- Run the length-`L` shift register with taps `c` from the seed `init`. -/
def lfsrRun {L : ℕ} (c init : Fin L → F) : ℕ → F
  | n =>
    if h : n < L then init ⟨n, h⟩
    else ∑ i : Fin L, c i * lfsrRun c init (n - L + (i : ℕ))
  decreasing_by
    have hi := i.isLt
    omega

variable {L : ℕ} {c init : Fin L → F}

@[simp] lemma lfsrRun_of_lt {n : ℕ} (h : n < L) :
    lfsrRun c init n = init ⟨n, h⟩ := by
  rw [lfsrRun]; simp [h]

lemma lfsrRun_of_ge {n : ℕ} (h : L ≤ n) :
    lfsrRun c init n = ∑ i : Fin L, c i * lfsrRun c init (n - L + (i : ℕ)) := by
  rw [lfsrRun]; simp [Nat.not_lt.mpr h]

/-- The register really does generate a stream obeying its recurrence. -/
theorem lfsrRun_isLinRec (c init : Fin L → F) : IsLinRec L c (lfsrRun c init) := by
  intro n
  rw [lfsrRun_of_ge (Nat.le_add_left _ _)]
  simp

/-- A register launched from the zero seed emits the zero stream, whatever its
taps are.  This is the degeneracy that makes the naive `#taps × #seeds` count of
seed-compressible files strictly non-tight. -/
theorem lfsrRun_zero_seed (c : Fin L → F) (n : ℕ) :
    lfsrRun c (fun _ => (0 : F)) n = 0 := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    by_cases hn : n < L
    · rw [lfsrRun_of_lt hn]
    · rw [lfsrRun_of_ge (Nat.not_lt.mp hn)]
      refine Finset.sum_eq_zero fun i _ => ?_
      have hi := i.isLt
      rw [ih (n - L + (i : ℕ)) (by omega), mul_zero]

/-- **Rigidity.** Two streams driven by the same taps that agree on a single
window of `L` consecutive symbols agree everywhere. -/
theorem IsLinRec.ext_of_agree {x y : ℕ → F} (hx : IsLinRec L c x)
    (hy : IsLinRec L c y) (h : ∀ i : ℕ, i < L → x i = y i) : x = y := by
  funext n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    by_cases hn : n < L
    · exact h n hn
    · obtain ⟨m, rfl⟩ : ∃ m, n = m + L := ⟨n - L, by omega⟩
      rw [hx m, hy m]
      refine Finset.sum_congr rfl fun i _ => ?_
      have hi := i.isLt
      rw [ih (m + i) (by omega)]

/-- **The seed-recovery gate.** A stream obeying an order-`L` recurrence is
*bit-exactly* reproduced by rerunning the register from its own first `L`
symbols: the seed is a lossless compression of the whole stream. -/
theorem IsLinRec.seed_recovery {x : ℕ → F} (hx : IsLinRec L c x) :
    x = lfsrRun c (fun i : Fin L => x (i : ℕ)) := by
  refine hx.ext_of_agree (lfsrRun_isLinRec _ _) ?_
  intro i hi
  rw [lfsrRun_of_lt hi]

/-- Corollary: the whole stream is a function of `(taps, first L symbols)`. -/
theorem IsLinRec.eq_of_taps_and_window {x y : ℕ → F} (hx : IsLinRec L c x)
    (hy : IsLinRec L c y) (h : ∀ i : Fin L, x (i : ℕ) = y (i : ℕ)) : x = y := by
  refine hx.ext_of_agree hy ?_
  intro i hi
  exact h ⟨i, hi⟩

/-! ### Periodic data is seed-compressible -/

/-- The tap vector `(1, 0, …, 0)`: the register that simply repeats its seed. -/
def unitTap (p : ℕ) : Fin p → F := fun i => if (i : ℕ) = 0 then 1 else 0

lemma sum_unitTap (p : ℕ) (hp : 0 < p) (x : ℕ → F) (n : ℕ) :
    ∑ i : Fin p, (unitTap p : Fin p → F) i * x (n + (i : ℕ)) = x n := by
  rw [Finset.sum_eq_single (⟨0, hp⟩ : Fin p)]
  · simp [unitTap]
  · intro b _ hb
    have hb0 : (b : ℕ) ≠ 0 := by
      intro h; exact hb (Fin.ext (by simpa using h))
    simp [unitTap, hb0]
  · intro hmem; exact absurd (Finset.mem_univ _) hmem

/-- **Periodic data is register output.**  A stream of period `p` is exactly a
stream generated by the order-`p` register with taps `(1,0,…,0)`, so periodic
real-world data is caught by the LFSR detector with a `2p`-bit description. -/
theorem isLinRec_unitTap_iff {p : ℕ} (hp : 0 < p) (x : ℕ → F) :
    IsLinRec p (unitTap p) x ↔ ∀ n, x (n + p) = x n := by
  constructor
  · intro h n
    rw [h n, sum_unitTap p hp]
  · intro h n
    rw [sum_unitTap p hp, h n]

/-- The repeating register really repeats: its output at time `n` is the seed
symbol at index `n % p`. -/
theorem lfsrRun_unitTap (p : ℕ) (hp : 0 < p) (init : Fin p → F) (n : ℕ) :
    lfsrRun (unitTap p) init n = init ⟨n % p, Nat.mod_lt _ hp⟩ := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    by_cases hn : n < p
    · rw [lfsrRun_of_lt hn]
      congr 1
      exact Fin.ext (by simp [Nat.mod_eq_of_lt hn])
    · have hp' : p ≤ n := Nat.not_lt.mp hn
      rw [lfsrRun_of_ge hp', sum_unitTap p hp, ih (n - p) (by omega)]
      congr 1
      exact Fin.ext (Nat.mod_eq_sub_mod hp').symm

/-- The state window of the stream `x` starting at time `n`. -/
def window (x : ℕ → F) (L n : ℕ) : Fin L → F := fun i => x (n + (i : ℕ))

/-- Shifting an LFSR stream in time gives another stream with the same taps. -/
theorem IsLinRec.shift {x : ℕ → F} (hx : IsLinRec L c x) (k : ℕ) :
    IsLinRec L c (fun n => x (n + k)) := by
  intro n
  have := hx (n + k)
  simpa [add_right_comm, add_assoc, add_comm, add_left_comm] using this

end Ring

section Uniqueness

variable {F : Type*} [Field F] {L : ℕ} {x : ℕ → F}

/-- The subspace of `F^L` spanned by all state windows of the stream `x`. -/
def windowSpan (x : ℕ → F) (L : ℕ) : Submodule F (Fin L → F) :=
  Submodule.span F (Set.range fun n : ℕ => window x L n)

lemma window_mem_windowSpan (x : ℕ → F) (L n : ℕ) : window x L n ∈ windowSpan x L :=
  Submodule.subset_span ⟨n, rfl⟩

/-- The dot product functional attached to a coefficient vector. -/
def dotL (e : Fin L → F) : (Fin L → F) →ₗ[F] F where
  toFun v := ∑ i : Fin L, e i * v i
  map_add' v w := by simp [mul_add, Finset.sum_add_distrib]
  map_smul' a v := by
    simp [Finset.mul_sum, mul_left_comm]

@[simp] lemma dotL_apply (e v : Fin L → F) : dotL e v = ∑ i : Fin L, e i * v i := rfl

lemma dotL_eq_zero_iff {e : Fin L → F} : (∀ v : Fin L → F, dotL e v = 0) ↔ e = 0 := by
  constructor
  · intro h
    funext j
    have hj := h (Pi.single j 1)
    rw [dotL_apply, Finset.sum_eq_single j] at hj
    · simpa using hj
    · intro b _ hb; simp [hb]
    · intro hj'; exact absurd (Finset.mem_univ j) hj'
  · rintro rfl v; simp

/-- **Berlekamp–Massey uniqueness.** If the state windows of the stream span
`F^L`, then at most one tap vector can drive the stream: seed recovery has a
unique answer, so a fingerprinting routine that finds *some* consistent tap
vector has found *the* tap vector. -/
theorem linRec_taps_unique_of_span {c d : Fin L → F} (hspan : windowSpan x L = ⊤)
    (hc : IsLinRec L c x) (hd : IsLinRec L d x) : c = d := by
  set e : Fin L → F := fun i => c i - d i with he
  have hker : ∀ n : ℕ, dotL e (window x L n) = 0 := by
    intro n
    have h := (hc n).symm.trans (hd n)
    simp only [dotL_apply, window, he, sub_mul, Finset.sum_sub_distrib]
    rw [h, sub_self]
  have hzero : ∀ v : Fin L → F, dotL e v = 0 := by
    intro v
    have hv : v ∈ windowSpan x L := by rw [hspan]; trivial
    refine Submodule.span_induction ?_ ?_ ?_ ?_ hv
    · rintro w ⟨n, rfl⟩; exact hker n
    · simp
    · intro a b _ _ ha hb; simp only [map_add, ha, hb, add_zero]
    · intro a b _ hb; simp only [map_smul, hb, smul_zero]
  have : e = 0 := dotL_eq_zero_iff.mp hzero
  funext i
  have := congrFun this i
  simp only [he, Pi.zero_apply, sub_eq_zero] at this
  exact this

/-- Recovery from a finite observation window: if the first `L` state windows
already span `F^L`, the taps are determined. -/
theorem linRec_taps_unique_of_initial_span {c d : Fin L → F}
    (hspan : Submodule.span F (Set.range fun n : Fin L => window x L (n : ℕ)) = ⊤)
    (hc : IsLinRec L c x) (hd : IsLinRec L d x) : c = d := by
  refine linRec_taps_unique_of_span ?_ hc hd
  refine top_le_iff.mp ?_
  rw [← hspan]
  refine Submodule.span_le.mpr ?_
  rintro v ⟨n, rfl⟩
  exact window_mem_windowSpan x L (n : ℕ)

/-- **Converse: spanning is exactly the right nondegeneracy hypothesis.**  If
the windows fail to span, the tap vector of an LFSR stream is genuinely
ambiguous: some different tap vector generates the very same stream, so no
fingerprinting procedure can pin down the taps from the data. -/
theorem windowSpan_eq_top_of_taps_unique {c : Fin L → F} (hc : IsLinRec L c x)
    (huniq : ∀ d : Fin L → F, IsLinRec L d x → d = c) : windowSpan x L = ⊤ := by
  by_contra hne
  obtain ⟨φ, hφ0, hφ⟩ :=
    Submodule.exists_le_ker_of_lt_top (windowSpan x L) (lt_top_iff_ne_top.mpr hne)
  set e : Fin L → F := fun i => φ (Pi.single i 1) with he
  have hφe : ∀ v : Fin L → F, φ v = dotL e v := by
    intro v
    have hv : v = ∑ i : Fin L, v i • (Pi.single i (1 : F) : Fin L → F) := by
      funext j; simp [Finset.sum_apply, Pi.single_apply]
    conv_lhs => rw [hv]
    rw [map_sum, dotL_apply]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [map_smul]
    simp [he, mul_comm]
  have hene : e ≠ 0 := by
    intro h0
    refine hφ0 (LinearMap.ext fun v => ?_)
    rw [hφe v, dotL_apply, h0]
    simp
  have hker : ∀ n : ℕ, ∑ i : Fin L, e i * x (n + (i : ℕ)) = 0 := by
    intro n
    have hmem := window_mem_windowSpan x L n
    have := hφ hmem
    rw [LinearMap.mem_ker, hφe, dotL_apply] at this
    simpa [window] using this
  have hc' : IsLinRec L (fun i => c i + e i) x := by
    intro n
    simp only [add_mul, Finset.sum_add_distrib, hker n, add_zero]
    exact hc n
  have hde := huniq _ hc'
  have : e = 0 := by
    funext i
    have := congrFun hde i
    simpa using this
  exact hene this

/-- Packaging: over a field, tap uniqueness and window spanning are equivalent
for any LFSR stream. -/
theorem taps_unique_iff_windowSpan {c : Fin L → F} (hc : IsLinRec L c x) :
    (∀ d : Fin L → F, IsLinRec L d x → d = c) ↔ windowSpan x L = ⊤ :=
  ⟨fun h => windowSpan_eq_top_of_taps_unique hc h,
   fun h _ hd => linRec_taps_unique_of_span h hd hc⟩

end Uniqueness

end PRNGSeed