import Probability.PRNGLCGFingerprint

/-!
# Finite-state periodicity and the limits of a seed-compression router

Two structural results about the classifier that routes a file to
*seed-compressible* or *model-compressible*.

**Positive side (why seed compression works at all).**  Any deterministic
generator with a finite state space is eventually periodic with preperiod plus
period at most `|S|`.  Hence its output stream — however long the file — is
completely determined by its first `|S|` symbols: `PRNG.stream_eq_early`.  This
is the structural reason a recovered seed reproduces the file exactly.

**Negative side (why the router cannot be a universal compressor).**  Combining
the counting bounds of the LFSR and LCG files: the union of the two families
covers at most `|K|^{2L} + |K|³` files of length `n`, so as soon as `n` exceeds
`2L` and `3` by a little, most files are rejected by *both* detectors:
`exists_not_routed`.  A seed-compression front end therefore never beats the
pigeonhole bound; it only reallocates code space.

Main contents.

* `PRNG.exists_iterate_collision` — pigeonhole on the state trajectory.
* `PRNG.exists_eventually_periodic` — preperiod `i` and period `p` with
  `i + p ≤ |S|`.
* `PRNG.stream_add_period_mul`, `PRNG.stream_eq_mod` — reduction of any time
  index into the fundamental window.
* `PRNG.stream_eq_early` — the whole stream is determined by its first `|S|`
  symbols.
* `routerWords`, `card_routerWords_le`, `exists_not_routed` — the two-family
  classifier still covers an exponentially small fraction of files.
-/

namespace Catalog.Probability.SeedRec

variable {S : Type*} {α : Type*} [Fintype S]

/-- Pigeonhole on the trajectory: within `|S|` steps the state must repeat. -/
theorem PRNG.exists_iterate_collision (g : PRNG S α) (s : S) :
    ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card S ∧ g.step^[i] s = g.step^[j] s := by
  obtain ⟨x, y, hxy, hfxy⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun k : Fin (Fintype.card S + 1) => g.step^[k.val] s)
      (by simp)
  rcases lt_trichotomy x.val y.val with h | h | h
  · exact ⟨x.val, y.val, h, by have := y.isLt; omega, hfxy⟩
  · exact absurd (Fin.ext h) hxy
  · exact ⟨y.val, x.val, h, by have := x.isLt; omega, hfxy.symm⟩

/-- Every finite-state generator is eventually periodic, with preperiod plus
period bounded by the number of states. -/
theorem PRNG.exists_eventually_periodic (g : PRNG S α) (s : S) :
    ∃ i p : ℕ, 0 < p ∧ i + p ≤ Fintype.card S ∧
      ∀ t, g.stream s (i + p + t) = g.stream s (i + t) := by
  obtain ⟨i, j, hij, hj, hstate⟩ := g.exists_iterate_collision s
  refine ⟨i, j - i, by omega, by omega, fun t => ?_⟩
  have hji : i + (j - i) = j := by omega
  rw [hji, PRNG.stream_add, PRNG.stream_add, hstate]

variable (g : PRNG S α) (s : S)

omit [Fintype S] in
/-- Iterating the period: the stream is invariant under shifting by any multiple
of the period, past the preperiod. -/
theorem PRNG.stream_add_period_mul {i p : ℕ}
    (hper : ∀ t, g.stream s (i + p + t) = g.stream s (i + t)) (q r : ℕ) :
    g.stream s (i + (p * q + r)) = g.stream s (i + r) := by
  induction q with
  | zero => simp
  | succ q ih =>
      have : i + (p * (q + 1) + r) = i + p + (p * q + r) := by ring
      rw [this, hper (p * q + r), ih]

omit [Fintype S] in
/-- Any time index past the preperiod reduces, modulo the period, into the
window `[i, i + p)`. -/
theorem PRNG.stream_eq_mod {i p : ℕ}
    (hper : ∀ t, g.stream s (i + p + t) = g.stream s (i + t)) {t : ℕ} (ht : i ≤ t) :
    g.stream s t = g.stream s (i + (t - i) % p) := by
  have hdec : t - i = p * ((t - i) / p) + (t - i) % p := (Nat.div_add_mod (t - i) p).symm
  calc g.stream s t = g.stream s (i + (p * ((t - i) / p) + (t - i) % p)) := by
        rw [← hdec]; congr 1; omega
    _ = g.stream s (i + (t - i) % p) :=
        g.stream_add_period_mul s hper _ _

/-- **The whole stream is determined by its first `|S|` symbols.** Every output,
at arbitrarily large time, equals an output at a time `< |S|`.  This is the
structural reason a recovered seed can reproduce an arbitrarily long file. -/
theorem PRNG.stream_eq_early (t : ℕ) :
    ∃ k, k < Fintype.card S ∧ g.stream s t = g.stream s k := by
  obtain ⟨i, p, hp, hip, hper⟩ := g.exists_eventually_periodic s
  by_cases ht : t < i
  · exact ⟨t, by omega, rfl⟩
  · refine ⟨i + (t - i) % p, ?_, g.stream_eq_mod s hper (by omega)⟩
    have := Nat.mod_lt (t - i) hp
    omega

section Router

variable (K : Type*) [CommRing K] [Fintype K] [DecidableEq K] (L : ℕ)

/-- The files accepted by the two-family classifier: those explained by an
order-`L` LFSR or by a linear congruential generator. -/
def routerWords (n : ℕ) : Finset (Fin n → K) := lfsrWords K L n ∪ lcgWords K n

theorem card_routerWords_le (n : ℕ) :
    (routerWords K L n).card ≤ Fintype.card K ^ (2 * L) + Fintype.card K ^ 3 :=
  (Finset.card_union_le _ _).trans
    (Nat.add_le_add (card_lfsrWords_le K L n) (card_lcgWords_le K n))

/-- **No free lunch for the seed-compression router.** Once the file is a little
longer than the two model classes can describe, some file is rejected by *both*
detectors: seed compression cannot cover the file space. -/
theorem exists_not_routed (n : ℕ) (hK : 2 ≤ Fintype.card K)
    (hL : 2 * L + 2 ≤ n) (hn : 5 ≤ n) :
    ∃ x : Fin n → K, x ∉ lfsrWords K L n ∧ x ∉ lcgWords K n := by
  set q := Fintype.card K with hq
  have h1 : q ^ (2 * L) ≤ q ^ (n - 2) := Nat.pow_le_pow_right (by omega) (by omega)
  have h2 : q ^ 3 ≤ q ^ (n - 2) := Nat.pow_le_pow_right (by omega) (by omega)
  have h3 : 2 * q ^ (n - 2) ≤ q ^ (n - 1) := by
    have : q ^ (n - 1) = q * q ^ (n - 2) := by
      rw [← pow_succ']
      congr 1
      omega
    rw [this]
    exact Nat.mul_le_mul_right _ hK
  have h4 : q ^ (n - 1) < q ^ n := Nat.pow_lt_pow_right (by omega) (by omega)
  have hcov : q ^ (2 * L) + q ^ 3 < q ^ n := by omega
  by_contra hc
  push_neg at hc
  have hsub : (Finset.univ : Finset (Fin n → K)) ⊆ routerWords K L n := by
    intro x _
    rw [routerWords, Finset.mem_union]
    by_cases hx : x ∈ lfsrWords K L n
    · exact Or.inl hx
    · exact Or.inr (hc x hx)
  have hcard := Finset.card_le_card hsub
  rw [Finset.card_univ, Fintype.card_fun, Fintype.card_fin] at hcard
  have hle := hcard.trans (card_routerWords_le K L n)
  rw [← hq] at hle
  omega

end Router

end Catalog.Probability.SeedRec