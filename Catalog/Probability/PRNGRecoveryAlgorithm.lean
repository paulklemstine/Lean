import Probability.PRNGRouterCapacity

/-!
# A verified seed-recovery procedure, and the maximal-complexity obstruction

This file supplies the missing *algorithmic* half of the seed-compression
pipeline, together with a refutation of the length clause of conjecture **C2**
of `FUTURE_DIRECTIONS.md`.

## The impulse word

`impulseWord K n` is `0, 0, …, 0, 1`.  It is the extremal example for linear
complexity:

* `lfsr_pref_ne_impulseWord` / `impulseWord_not_mem_lfsrWords` — no LFSR of
  order `L < n` produces it, because the only seed compatible with its first
  `L` symbols is the zero seed, which produces the all-zero file
  (`lfsr_pref_zero`);
* `impulseWord_mem_lfsrWords_self` — order `n` does produce it, so its linear
  complexity is *exactly* `n`;
* `bm_half_length_bound_false` — hence the clause of C2 asking a
  Berlekamp–Massey routine to always return an order `L ≤ ⌈n/2⌉` *consistent
  with the observed window* is **false**: for `n ≥ 2` the impulse word is
  consistent with no such order.  The correct invariant is minimality of the
  returned order, not a bound of `⌈n/2⌉` (which holds only for windows that
  genuinely come from a short LFSR).

## The recovery procedure

* `observedSeed` — the candidate seed *is* the first `L` observed symbols
  (`lfsr_pref_eq_self`); nothing else has to be searched.
* `candidateTaps` — the finite set of tap vectors that reproduce the whole
  observed word from that seed; `lfsrDetect` is the corresponding Boolean test.
* `candidateTaps_sound` — **falsifiability gate**: an accepted tap vector
  reproduces the file symbol by symbol.
* `lfsrDetect_eq_true_iff` — **completeness**: the test accepts exactly the
  files of linear complexity `≤ L`, so the search over `|K|^L` tap vectors is
  exhaustive.
* `recovered_stream_unique` — **certified extrapolation**: once the window is at
  least `2L` long, *all* accepted candidates predict the same infinite stream,
  so the recovered generator is unambiguous beyond the observed data.
* `lfsrDetect_impulseWord` — the detector correctly rejects the maximal
  complexity word.
-/

namespace Catalog.Probability.SeedRec

variable {K : Type*} [CommRing K] {L n : ℕ}

/-! ## The impulse word has maximal linear complexity -/

/-- The impulse word `0, 0, …, 0, 1` of length `n`. -/
def impulseWord (K : Type*) [CommRing K] (n : ℕ) : Fin n → K :=
  fun i => if (i : ℕ) + 1 = n then 1 else 0

theorem impulseWord_apply_of_lt {n : ℕ} {i : Fin n} (h : (i : ℕ) + 1 < n) :
    impulseWord K n i = 0 := by
  simp [impulseWord, Nat.ne_of_lt h]

theorem impulseWord_last {n : ℕ} (hn : 0 < n) :
    impulseWord K n ⟨n - 1, by omega⟩ = 1 := by
  simp [impulseWord, Nat.sub_add_cancel hn]

/-- **No short LFSR produces the impulse word.**  Its first `L` symbols are all
zero, so the only candidate seed is the zero seed — which produces the all-zero
file, not the impulse. -/
theorem lfsr_pref_ne_impulseWord [Nontrivial K] (c σ : Fin L → K) (hL : L < n) :
    (lfsrPRNG c).pref n σ ≠ impulseWord K n := by
  intro h
  have hσ : σ = fun _ => (0 : K) := by
    funext j
    have hjn : (j : ℕ) < n := lt_trans j.isLt hL
    have h1 : (lfsrPRNG c).pref n σ ⟨(j : ℕ), hjn⟩ = impulseWord K n ⟨(j : ℕ), hjn⟩ :=
      congrFun h _
    have h2 : (lfsrPRNG c).pref n σ ⟨(j : ℕ), hjn⟩ = σ j := by
      have := lfsr_stream_lt c σ (j : ℕ) j.isLt
      simpa [PRNG.pref] using this
    have h3 : impulseWord K n ⟨(j : ℕ), hjn⟩ = 0 := by
      have hj := j.isLt
      exact impulseWord_apply_of_lt (show (j : ℕ) + 1 < n by omega)
    rw [h2, h3] at h1
    exact h1
  rw [hσ, lfsr_pref_zero K c n] at h
  have hn : 0 < n := by omega
  have := congrFun h ⟨n - 1, by omega⟩
  rw [impulseWord_last hn] at this
  exact zero_ne_one this

section Counting

variable [Fintype K] [DecidableEq K]

/-- The impulse word is not a file of linear complexity `< n`. -/
theorem impulseWord_not_mem_lfsrWords [Nontrivial K] (hL : L < n) :
    impulseWord K n ∉ lfsrWords K L n := by
  intro hmem
  obtain ⟨c, σ, hcσ⟩ := (mem_lfsrWords K L).mp hmem
  exact lfsr_pref_ne_impulseWord c σ hL hcσ

/-- Every word of length `n` — in particular the impulse word — *is* produced by
an order-`n` LFSR: the seed is the word itself.  So the linear complexity of the
impulse word is exactly `n`. -/
theorem impulseWord_mem_lfsrWords_self (n : ℕ) :
    impulseWord K n ∈ lfsrWords K n n :=
  (mem_lfsrWords K n).mpr ⟨fun _ => 0, impulseWord K n, lfsr_pref_eq_self _ _⟩

/-- **The `⌈n/2⌉` clause of conjecture C2 is false.**  For `n ≥ 2` the impulse
word of length `n` is consistent with *no* linear recurrence of order at most
`⌈n/2⌉`, while it is consistent with one of order `n`.  A Berlekamp–Massey
routine therefore cannot always return an order bounded by half the window. -/
theorem bm_half_length_bound_false [Nontrivial K] (n : ℕ) (hn : 2 ≤ n) :
    (∀ L ≤ (n + 1) / 2, impulseWord K n ∉ lfsrWords K L n) ∧
      impulseWord K n ∈ lfsrWords K n n := by
  refine ⟨fun L hL => impulseWord_not_mem_lfsrWords (by omega), impulseWord_mem_lfsrWords_self n⟩

end Counting

/-! ## The seed-recovery procedure -/

section Recovery

variable [Fintype K] [DecidableEq K]

/-- The seed a detector must try: by `lfsr_pref_eq_self` the first `L` symbols of
an LFSR output *are* its seed, so this is the only candidate. -/
def observedSeed (hL : L ≤ n) (x : Fin n → K) : Fin L → K :=
  fun i => x ⟨(i : ℕ), lt_of_lt_of_le i.isLt hL⟩

omit [Fintype K] [DecidableEq K] in
theorem observedSeed_pref (c σ : Fin L → K) (hL : L ≤ n) :
    observedSeed hL ((lfsrPRNG c).pref n σ) = σ := by
  funext i
  have := lfsr_stream_lt c σ (i : ℕ) i.isLt
  simpa [observedSeed, PRNG.pref] using this

/-- The set of tap vectors accepted by the detector: those that regenerate the
whole observed word from the observed seed. -/
def candidateTaps (hL : L ≤ n) (x : Fin n → K) : Finset (Fin L → K) :=
  Finset.univ.filter fun c => (lfsrPRNG c).pref n (observedSeed hL x) = x

theorem mem_candidateTaps {hL : L ≤ n} {x : Fin n → K} {c : Fin L → K} :
    c ∈ candidateTaps hL x ↔ (lfsrPRNG c).pref n (observedSeed hL x) = x := by
  simp [candidateTaps]

/-- The Boolean fingerprint test: does *some* order-`L` LFSR reproduce the file? -/
def lfsrDetect (hL : L ≤ n) (x : Fin n → K) : Bool :=
  decide (candidateTaps hL x).Nonempty

/-- **Falsifiability gate (soundness).**  An accepted tap vector reproduces the
observed file exactly, symbol by symbol, from the recovered seed. -/
theorem candidateTaps_sound {hL : L ≤ n} {x : Fin n → K} {c : Fin L → K}
    (hc : c ∈ candidateTaps hL x) (i : Fin n) :
    (lfsrPRNG c).stream (observedSeed hL x) (i : ℕ) = x i :=
  congrFun (mem_candidateTaps.mp hc) i

/-- **Completeness.**  The detector accepts exactly the files of linear
complexity `≤ L`: searching the observed seed alone loses nothing. -/
theorem lfsrDetect_eq_true_iff (hL : L ≤ n) (x : Fin n → K) :
    lfsrDetect hL x = true ↔ x ∈ lfsrWords K L n := by
  rw [lfsrDetect, decide_eq_true_iff]
  constructor
  · rintro ⟨c, hc⟩
    exact (mem_lfsrWords K L).mpr ⟨c, observedSeed hL x, mem_candidateTaps.mp hc⟩
  · intro hx
    obtain ⟨c, σ, hcσ⟩ := (mem_lfsrWords K L).mp hx
    refine ⟨c, mem_candidateTaps.mpr ?_⟩
    rw [← hcσ, observedSeed_pref c σ hL]

/-- **Certified extrapolation.**  If the observed window has length at least
`2L`, then all accepted candidates agree on the *entire* infinite stream: the
recovered generator predicts the unobserved data unambiguously. -/
theorem recovered_stream_unique [Nontrivial K] [NeZero L] {hL : L ≤ n} {x : Fin n → K}
    {c c' : Fin L → K} (hc : c ∈ candidateTaps hL x) (hc' : c' ∈ candidateTaps hL x)
    (hn : 2 * L ≤ n) (t : ℕ) :
    (lfsrPRNG c).stream (observedSeed hL x) t = (lfsrPRNG c').stream (observedSeed hL x) t := by
  refine lfsr_stream_determined_by_two_L c c' _ _ ?_ t
  intro s hs
  have hsn : s < n := by omega
  rw [candidateTaps_sound hc ⟨s, hsn⟩, candidateTaps_sound hc' ⟨s, hsn⟩]

/-- The detector rejects the maximal-complexity word at every order `L < n`. -/
theorem lfsrDetect_impulseWord [Nontrivial K] (hL : L < n) :
    lfsrDetect (le_of_lt hL) (impulseWord K n) = false := by
  by_contra h
  rw [Bool.not_eq_false, lfsrDetect_eq_true_iff] at h
  exact impulseWord_not_mem_lfsrWords hL h

end Recovery

end Catalog.Probability.SeedRec