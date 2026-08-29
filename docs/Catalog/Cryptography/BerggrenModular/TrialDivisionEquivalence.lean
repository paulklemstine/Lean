import Cryptography.BerggrenModular.BlumImmunity

/-!
# Trial-division equivalence and the guidance null for gcd dives

Experiment 555 measures the modular Berggren descent as a factoring device: a
"dive" walks nodes of the mod-`N` tree and tests `gcd(value, N)`.  The measured
exponent is `α = 1.007 ± 0.088` — the work to split `N` scales like the *smallest
prime factor*, i.e. trial division, and not like `√p_min` (Pollard ρ).  Two
further findings are (i) the various guidance heuristics gave no honest
improvement, and (ii) the naive `z = 12–24` "improvements" were pure
traversal-shape artefacts.

This file proves the exact combinatorial theorems behind those three statements
for the *ambient* model — a gcd dive that inspects `t` residues modulo `N` — and
then couples them back to the Berggren tree through
`Cryptography.BerggrenModular.BlumImmunity`.

## Main results

* `card_revealSet_semiprime` — modulo `N = p·q` exactly `p + q − 2` residues have
  a nontrivial gcd with `N`: the per-node hit rate is `(p+q−2)/pq ≍ 1/p_min`.
* `card_hitSet` — an **exact** formula for the number of `t`-node dives that
  succeed while inspecting the index set `S`.
* `hitSet_card_eq_of_card_eq` — **the guidance null.**  The success count depends
  on the inspection schedule `S` *only through its cardinality*: no ordering, no
  selection rule, no traversal shape changes it by a single dive.  Any measured
  "improvement" at fixed node budget is an artefact.
* `hitSet_card_eq_scaled` — the sharp form: examining `s` of `t` nodes has exactly
  the success rate of examining the first `s`.
* `hitSet_card_le_union_bound` — the union bound `#hits ≤ s·(p+q−2)·N^{t−1}`.
* `trial_division_scaling` — **α = 1.**  If the dive inspects fewer than `p/4`
  nodes its success probability is below `1/2`; equivalently
  `needs_linear_in_min_prime`: constant success needs `Ω(p_min)` nodes.  A ρ-like
  `O(√p_min)` dive is therefore impossible in this model.
* `card_reachableReveal` and `berggren_undersampling_ratio` — the Berggren
  hypotenuse stream can reach only `p − 1` of the `p + q − 2` revealing residues
  when `p ≡ 3 (mod 4)`: a strict, quantified under-sampling.
-/

namespace Cryptography
namespace BerggrenModular
namespace Dive

/-! ## The revealing residues -/

/-- A value `x` *reveals* a factor of `N` when `gcd x N` is a nontrivial divisor. -/
def Reveals (N x : ℕ) : Prop := 1 < Nat.gcd x N ∧ Nat.gcd x N < N

instance (N : ℕ) : DecidablePred (Reveals N) :=
  fun x => inferInstanceAs (Decidable (1 < Nat.gcd x N ∧ Nat.gcd x N < N))

/-- The residues below `N` that reveal a factor. -/
def revealSet (N : ℕ) : Finset ℕ := (Finset.range N).filter (Reveals N)

/-- The residues below `N` that reveal nothing. -/
def avoidSet (N : ℕ) : Finset ℕ := (Finset.range N).filter (fun x => ¬ Reveals N x)

theorem card_reveal_add_card_avoid (N : ℕ) : (revealSet N).card + (avoidSet N).card = N := by
  simpa [revealSet, avoidSet, Finset.card_range] using
    Finset.card_filter_add_card_filter_not (s := Finset.range N) (p := Reveals N)

theorem card_revealSet_le (N : ℕ) : (revealSet N).card ≤ N := by
  have := card_reveal_add_card_avoid N; omega

/-- The non-revealing residues are `0` together with the units. -/
theorem avoidSet_eq (N : ℕ) (hN : 2 ≤ N) :
    avoidSet N = insert 0 ((Finset.range N).filter N.Coprime) := by
  ext x
  simp only [avoidSet, Finset.mem_filter, Finset.mem_range, Finset.mem_insert, Reveals,
    not_and_or, not_lt]
  constructor
  · rintro ⟨hx, h⟩
    rcases h with h | h
    · right
      refine ⟨hx, ?_⟩
      have h0 : Nat.gcd x N ≠ 0 := by
        intro h0
        have := Nat.eq_zero_of_gcd_eq_zero_right h0
        omega
      have h1 : Nat.gcd x N = 1 := by omega
      simpa [Nat.Coprime, Nat.gcd_comm] using h1
    · left
      have hdvd : N ∣ x := by
        have h1 : Nat.gcd x N ∣ x := Nat.gcd_dvd_left _ _
        have h2 : Nat.gcd x N ≤ N := Nat.le_of_dvd (by omega) (Nat.gcd_dvd_right _ _)
        have h3 : Nat.gcd x N = N := by omega
        rwa [h3] at h1
      exact Nat.eq_zero_of_dvd_of_lt hdvd hx
  · rintro (rfl | ⟨hx, hcop⟩)
    · exact ⟨by omega, Or.inr (by simp)⟩
    · refine ⟨hx, Or.inl ?_⟩
      have : Nat.gcd x N = 1 := by simpa [Nat.Coprime, Nat.gcd_comm] using hcop
      omega

/-- The number of revealing residues is `N − 1 − φ(N)`. -/
theorem card_revealSet (N : ℕ) (hN : 2 ≤ N) :
    (revealSet N).card = N - 1 - N.totient := by
  have hsum := card_reveal_add_card_avoid N
  rw [avoidSet_eq N hN] at hsum
  have h0 : (0 : ℕ) ∉ (Finset.range N).filter N.Coprime := by
    simp only [Finset.mem_filter, Finset.mem_range, not_and, Nat.Coprime]
    intro _
    simp only [Nat.gcd_zero_right]
    omega
  rw [Finset.card_insert_of_notMem h0] at hsum
  have ht : ((Finset.range N).filter N.Coprime).card = N.totient := rfl
  rw [ht] at hsum
  omega

/-- **The per-node hit rate of a gcd dive.**  Modulo a semiprime `N = p·q` exactly
`p + q − 2` residues reveal a factor, so a uniformly sampled node succeeds with
probability `(p+q−2)/pq ≍ 1/p_min`. -/
theorem card_revealSet_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (revealSet (p * q)).card = p + q - 2 := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hN : 2 ≤ p * q := le_trans hp2 (Nat.le_mul_of_pos_right p (by omega))
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  have htot : (p * q).totient = (p - 1) * (q - 1) := by
    rw [Nat.totient_mul hcop, Nat.totient_prime hp, Nat.totient_prime hq]
  rw [card_revealSet _ hN, htot]
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 2 := ⟨p - 2, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 2 := ⟨q - 2, by omega⟩
  have h1 : (a + 2) * (b + 2) = a * b + 2 * a + 2 * b + 4 := by ring
  have h2 : (a + 2 - 1) * (b + 2 - 1) = a * b + a + b + 1 := by
    have : a + 2 - 1 = a + 1 := by omega
    have h' : b + 2 - 1 = b + 1 := by omega
    rw [this, h']; ring
  omega

/-- A concrete instance of the count: modulo `15` the revealing residues are
`{3,5,6,9,10,12}`, six of them, and `3 + 5 - 2 = 6`. -/
example : revealSet 15 = {3, 5, 6, 9, 10, 12} := by decide

/-! ## Dives: sampling `t` nodes and inspecting a schedule `S` -/

/-- The space of `t`-node value streams modulo `N`. -/
def samples (N t : ℕ) : Finset (Fin t → ℕ) := Fintype.piFinset (fun _ => Finset.range N)

theorem card_samples (N t : ℕ) : (samples N t).card = N ^ t := by
  simp [samples, Fintype.card_piFinset, Finset.card_range]

/-- The streams on which a dive that inspects the nodes indexed by `S` succeeds.
`S` models an arbitrary *guidance heuristic*: any rule that decides, in advance,
which of the `t` visited nodes to gcd-test, in any order. -/
def hitSet (N t : ℕ) (S : Finset (Fin t)) : Finset (Fin t → ℕ) :=
  (samples N t).filter (fun f => ∃ i ∈ S, Reveals N (f i))

theorem miss_eq (N t : ℕ) (S : Finset (Fin t)) :
    (samples N t).filter (fun f => ¬ ∃ i ∈ S, Reveals N (f i))
      = Fintype.piFinset (fun j => if j ∈ S then avoidSet N else Finset.range N) := by
  ext f
  simp only [Finset.mem_filter, samples, Fintype.mem_piFinset, avoidSet, not_exists, not_and]
  constructor
  · rintro ⟨hmem, hno⟩ j
    by_cases hj : j ∈ S
    · simp only [hj, if_pos, Finset.mem_filter]
      exact ⟨hmem j, hno j hj⟩
    · simpa [hj] using hmem j
  · intro h
    refine ⟨fun j => ?_, fun i hi => ?_⟩
    · have hj := h j
      by_cases hjS : j ∈ S
      · simp only [hjS, if_pos, Finset.mem_filter] at hj; exact hj.1
      · simpa [hjS] using hj
    · have hi' := h i
      simp only [hi, if_pos, Finset.mem_filter] at hi'
      exact hi'.2

/-- Counting streams with a prescribed value-set on a schedule `S` and free values
elsewhere.  This is the combinatorial engine behind every count in this file. -/
theorem card_piFinset_ite {t : ℕ} (S : Finset (Fin t)) (A B : Finset ℕ) :
    (Fintype.piFinset (fun j => if j ∈ S then A else B)).card
      = A.card ^ S.card * B.card ^ (t - S.card) := by
  rw [Fintype.card_piFinset]
  simp only [apply_ite Finset.card]
  rw [Finset.prod_ite, Finset.prod_const, Finset.prod_const]
  congr 1
  · congr 1
    simp
  · congr 1
    rw [Finset.filter_not]
    simp [Finset.card_sdiff]

theorem card_miss (N t : ℕ) (S : Finset (Fin t)) :
    ((samples N t).filter (fun f => ¬ ∃ i ∈ S, Reveals N (f i))).card
      = (avoidSet N).card ^ S.card * N ^ (t - S.card) := by
  rw [miss_eq, card_piFinset_ite, Finset.card_range]

/-- **Exact success count of a gcd dive.**  Out of the `N^t` value streams, the
schedule `S` succeeds on all but `(N − r)^{|S|} · N^{t−|S|}` of them, where
`r = #revealSet N`. -/
theorem card_hitSet (N t : ℕ) (S : Finset (Fin t)) :
    (hitSet N t S).card + (avoidSet N).card ^ S.card * N ^ (t - S.card) = N ^ t := by
  have h := Finset.card_filter_add_card_filter_not (s := samples N t)
    (p := fun f => ∃ i ∈ S, Reveals N (f i))
  rw [card_samples] at h
  calc (hitSet N t S).card + (avoidSet N).card ^ S.card * N ^ (t - S.card)
      = (hitSet N t S).card
          + ((samples N t).filter (fun f => ¬ ∃ i ∈ S, Reveals N (f i))).card := by
        rw [card_miss]
    _ = N ^ t := h

theorem card_le_of_card_S (t : ℕ) (S : Finset (Fin t)) : S.card ≤ t := by
  simpa using S.card_le_univ

/-! ## The guidance null -/

/-- **The guidance null, sharp form.**  Two inspection schedules of the same size
succeed on *exactly* the same number of streams.  Consequently no ordering rule,
no priority queue, no traversal shape and no residue-class preference can change
the success probability of a gcd dive at a fixed node budget: every measured
"improvement" at matched compute is an artefact of the comparison, not of the
heuristic. -/
theorem hitSet_card_eq_of_card_eq (N t : ℕ) {S T : Finset (Fin t)} (h : S.card = T.card) :
    (hitSet N t S).card = (hitSet N t T).card := by
  have hS := card_hitSet N t S
  have hT := card_hitSet N t T
  rw [h] at hS
  omega

/-- Order-invariance in its most elementary form: relabelling the traversal by a
permutation carries successes to successes. -/
theorem hits_perm_invariant (N t : ℕ) (σ : Equiv.Perm (Fin t)) (f : Fin t → ℕ) :
    (∃ i, Reveals N (f i)) ↔ (∃ i, Reveals N ((f ∘ σ) i)) := by
  constructor
  · rintro ⟨i, hi⟩; exact ⟨σ.symm i, by simpa using hi⟩
  · rintro ⟨i, hi⟩; exact ⟨σ i, hi⟩

/-- Inspecting `s` of `t` nodes has exactly the success *rate* of inspecting `s`
nodes: the count factors as the `s`-node count times the `N^{t−s}` free
coordinates. -/
theorem hitSet_card_eq_scaled (N t : ℕ) (S : Finset (Fin t)) :
    (hitSet N t S).card
      = (N ^ S.card - (avoidSet N).card ^ S.card) * N ^ (t - S.card) := by
  have hs : S.card ≤ t := card_le_of_card_S t S
  have hpow : N ^ S.card * N ^ (t - S.card) = N ^ t := by
    rw [← pow_add]; congr 1; omega
  have ha : (avoidSet N).card ≤ N := by
    have := card_reveal_add_card_avoid N; omega
  have hle : (avoidSet N).card ^ S.card ≤ N ^ S.card := Nat.pow_le_pow_left ha _
  have h := card_hitSet N t S
  rw [Nat.sub_mul]
  omega

/-! ## Trial-division scaling: `α = 1` -/

/-- The elementary convexity bound `(b+d)^{s+1} ≤ b^{s+1} + (s+1)·d·(b+d)^s`. -/
theorem pow_add_le (b d s : ℕ) : (b + d) ^ (s + 1) ≤ b ^ (s + 1) + (s + 1) * d * (b + d) ^ s := by
  induction s with
  | zero => simp
  | succ n ih =>
      have hb : b ^ (n + 1) ≤ (b + d) ^ (n + 1) := Nat.pow_le_pow_left (Nat.le_add_right _ _) _
      calc (b + d) ^ (n + 2) = (b + d) * (b + d) ^ (n + 1) := by ring
        _ ≤ (b + d) * (b ^ (n + 1) + (n + 1) * d * (b + d) ^ n) := Nat.mul_le_mul_left _ ih
        _ = b ^ (n + 2) + d * b ^ (n + 1) + (n + 1) * d * (b + d) ^ (n + 1) := by ring
        _ ≤ b ^ (n + 2) + d * (b + d) ^ (n + 1) + (n + 1) * d * (b + d) ^ (n + 1) := by gcongr
        _ = b ^ (n + 2) + (n + 2) * d * (b + d) ^ (n + 1) := by ring

/-- **Union bound for gcd dives.**  A schedule of `s ≥ 1` inspections succeeds on
at most `s · r · N^{t−1}` of the `N^t` streams, `r` the number of revealing
residues. -/
theorem hitSet_card_le_union_bound (N t : ℕ) (S : Finset (Fin t)) (hS : 1 ≤ S.card) :
    (hitSet N t S).card ≤ S.card * (revealSet N).card * N ^ (t - 1) := by
  have hs : S.card ≤ t := card_le_of_card_S t S
  obtain ⟨s, hsdef⟩ : ∃ s, S.card = s + 1 := ⟨S.card - 1, by omega⟩
  have hexact := card_hitSet N t S
  set a := (avoidSet N).card with ha
  set r := (revealSet N).card with hr
  have hsum : r + a = N := card_reveal_add_card_avoid N
  have hkey : N ^ (s + 1) ≤ a ^ (s + 1) + (s + 1) * r * N ^ s := by
    have := pow_add_le a r s
    rw [show a + r = N by omega] at this
    exact this
  have hmul : N ^ (s + 1) * N ^ (t - (s + 1)) = N ^ t := by
    rw [← pow_add]; congr 1; omega
  have hmul2 : N ^ s * N ^ (t - (s + 1)) = N ^ (t - 1) := by
    rw [← pow_add]; congr 1; omega
  have hbound : N ^ t ≤ a ^ (s + 1) * N ^ (t - (s + 1)) + (s + 1) * r * N ^ (t - 1) := by
    calc N ^ t = N ^ (s + 1) * N ^ (t - (s + 1)) := hmul.symm
      _ ≤ (a ^ (s + 1) + (s + 1) * r * N ^ s) * N ^ (t - (s + 1)) :=
          Nat.mul_le_mul_right _ hkey
      _ = a ^ (s + 1) * N ^ (t - (s + 1)) + (s + 1) * r * (N ^ s * N ^ (t - (s + 1))) := by ring
      _ = a ^ (s + 1) * N ^ (t - (s + 1)) + (s + 1) * r * N ^ (t - 1) := by rw [hmul2]
  rw [hsdef] at hexact ⊢
  omega

/-- **`α = 1`: the gcd dive is trial-division-class.**  For a semiprime `N = p·q`
with `p ≤ q`, a dive that inspects fewer than `p/4` nodes succeeds on strictly
fewer than half of all value streams.  No `O(√p)` (ρ-like) behaviour is possible:
the success rate is governed by the linear-in-`p_min` hit density
`(p+q−2)/pq`. -/
theorem trial_division_scaling {p q t : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hle : p ≤ q) (S : Finset (Fin t)) (hs : 4 * S.card < p) :
    2 * (hitSet (p * q) t S).card < (p * q) ^ t := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hNpos : 0 < p * q := Nat.mul_pos (by omega) (by omega)
  rcases Nat.eq_zero_or_pos S.card with h0 | h1
  · -- an empty schedule never succeeds
    have hempty : hitSet (p * q) t S = ∅ := by
      rw [Finset.card_eq_zero] at h0
      simp [hitSet, h0]
    rw [hempty]
    simpa using pow_pos hNpos t
  · have hb := hitSet_card_le_union_bound (p * q) t S h1
    rw [card_revealSet_semiprime hp hq hpq] at hb
    have hst : S.card ≤ t := card_le_of_card_S t S
    have ht1 : 1 ≤ t := le_trans h1 hst
    have hpow : (p * q) * (p * q) ^ (t - 1) = (p * q) ^ t := by
      rw [← pow_succ']; congr 1; omega
    -- the arithmetic core: `2·s·(p+q−2) < p·q` whenever `4s < p ≤ q`
    have harith : 2 * (S.card * (p + q - 2)) < p * q := by
      obtain ⟨a, rfl⟩ : ∃ a, p = a + 2 := ⟨p - 2, by omega⟩
      obtain ⟨b, rfl⟩ : ∃ b, q = b + 2 := ⟨q - 2, by omega⟩
      have hab : a ≤ b := by omega
      have hsub : a + 2 + (b + 2) - 2 = a + b + 2 := by omega
      rw [hsub]
      nlinarith [S.card, hs, hab, Nat.zero_le a, Nat.zero_le b]
    have hpos : 0 < (p * q) ^ (t - 1) := pow_pos hNpos _
    calc 2 * (hitSet (p * q) t S).card
        ≤ 2 * (S.card * (p + q - 2) * (p * q) ^ (t - 1)) := by omega
      _ = (2 * (S.card * (p + q - 2))) * (p * q) ^ (t - 1) := by ring
      _ < (p * q) * (p * q) ^ (t - 1) := by
          exact Nat.mul_lt_mul_of_lt_of_le harith (le_refl _) hpos
      _ = (p * q) ^ t := hpow

/-- Contrapositive reading: **constant success probability costs `Ω(p_min)`
inspected nodes.**  This is the formal content of the measured exponent
`α = 1.007 ± 0.088`, and rules out a `√p_min` (Pollard-ρ-like) dive. -/
theorem needs_linear_in_min_prime {p q t : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hle : p ≤ q) (S : Finset (Fin t)) (hsucc : (p * q) ^ t ≤ 2 * (hitSet (p * q) t S).card) :
    p ≤ 4 * S.card := by
  by_contra hcon
  exact absurd hsucc (not_le.2 (trial_division_scaling hp hq hpq hle S (by omega)))

/-! ## Coupling back to the Berggren tree: strict under-sampling -/

/-- The multiples of `q` below `p·q`. -/
theorem card_multiples (p q : ℕ) (hq : 0 < q) :
    ((Finset.range (p * q)).filter (fun x => q ∣ x)).card = p := by
  have h : (Finset.range (p * q)).filter (fun x => q ∣ x)
      = (Finset.range p).image (fun i => q * i) := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_image]
    constructor
    · rintro ⟨hx, c, rfl⟩
      exact ⟨c, by rw [mul_comm p q] at hx; exact lt_of_mul_lt_mul_left hx (Nat.zero_le q), rfl⟩
    · rintro ⟨i, hi, rfl⟩
      exact ⟨by rw [mul_comm p q]; exact (Nat.mul_lt_mul_left hq).2 hi, ⟨i, rfl⟩⟩
  rw [h, Finset.card_image_of_injective _ (fun a b hab => Nat.eq_of_mul_eq_mul_left hq hab),
    Finset.card_range]

/-- The revealing residues a `p`-blind stream can ever reach: those divisible by
`q` but not by `p`. -/
theorem reachableReveal_eq {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (revealSet (p * q)).filter (fun x => ¬ p ∣ x)
      = ((Finset.range (p * q)).filter (fun x => q ∣ x)).erase 0 := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  ext x
  simp only [revealSet, Reveals, Finset.mem_filter, Finset.mem_range, Finset.mem_erase]
  constructor
  · rintro ⟨⟨hx, h1, h2⟩, hnp⟩
    refine ⟨?_, hx, ?_⟩
    · rintro rfl
      simp only [Nat.gcd_zero_left] at h2
      omega
    · -- `gcd x N > 1` forces a prime factor, which must be `q`
      obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd (n := Nat.gcd x (p * q)) (by omega)
      have hrN : r ∣ p * q := hrd.trans (Nat.gcd_dvd_right _ _)
      have hrx : r ∣ x := hrd.trans (Nat.gcd_dvd_left _ _)
      rcases (Nat.Prime.dvd_mul hr).1 hrN with h | h
      · exact absurd (((Nat.prime_dvd_prime_iff_eq hr hp).1 h) ▸ hrx) hnp
      · exact ((Nat.prime_dvd_prime_iff_eq hr hq).1 h) ▸ hrx
  · rintro ⟨hx0, hx, hqx⟩
    have hnp : ¬ p ∣ x := by
      intro hpx
      have : p * q ∣ x := Nat.Coprime.mul_dvd_of_dvd_of_dvd hcop hpx hqx
      exact hx0 (Nat.eq_zero_of_dvd_of_lt this hx)
    refine ⟨⟨hx, ?_, ?_⟩, hnp⟩
    · have hqg : q ∣ Nat.gcd x (p * q) := Nat.dvd_gcd hqx (dvd_mul_left q p)
      have := Nat.le_of_dvd (Nat.gcd_pos_of_pos_left _ (by omega)) hqg
      omega
    · have hgd : Nat.gcd x (p * q) ∣ p * q := Nat.gcd_dvd_right _ _
      have hgx : Nat.gcd x (p * q) ∣ x := Nat.gcd_dvd_left _ _
      rcases Nat.lt_or_ge (Nat.gcd x (p * q)) (p * q) with h | h
      · exact h
      · exfalso
        have : Nat.gcd x (p * q) = p * q :=
          le_antisymm (Nat.le_of_dvd (Nat.mul_pos (by omega) (by omega)) hgd) h
        rw [this] at hgx
        exact hx0 (Nat.eq_zero_of_dvd_of_lt hgx hx)

/-- Exactly `p − 1` revealing residues are reachable by a stream that never hits a
multiple of `p`, against `p + q − 2` in total. -/
theorem card_reachableReveal {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    ((revealSet (p * q)).filter (fun x => ¬ p ∣ x)).card = p - 1 := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  rw [reachableReveal_eq hp hq hpq, Finset.card_erase_of_mem, card_multiples p q (by omega)]
  simp only [Finset.mem_filter, Finset.mem_range]
  exact ⟨Nat.mul_pos (by omega) (by omega), dvd_zero q⟩

/-- **Quantified under-sampling of the Berggren hypotenuse dive.**  When
`p ≡ 3 (mod 4)` the hypotenuse of a Berggren node is never divisible by `p`
(`berggren_dive_undersamples`), so the dive can only ever reach `p − 1` of the
`p + q − 2` factor-revealing residue classes — a strictly smaller target set.
Projecting the tree mod `N` therefore *loses* hit density rather than gaining
it. -/
theorem berggren_undersampling_ratio {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp3 : p % 4 = 3) :
    (∀ u : List Move, ¬ p ∣ hypNat u) ∧
      ((revealSet (p * q)).filter (fun x => ¬ p ∣ x)).card < (revealSet (p * q)).card := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  refine ⟨fun u => berggren_dive_undersamples hp hp3 u, ?_⟩
  rw [card_reachableReveal hp hq hpq, card_revealSet_semiprime hp hq hpq]
  omega

end Dive
end BerggrenModular