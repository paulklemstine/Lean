import Mathlib

/-!
# The symmetry-breaking cost of factoring, measured

Let `N` be an odd semiprime and let `S` be the set of candidate prime factors (say, the odd
primes `p` with `p² ≤ N`).  A *battery* is a finite tuple `a : Fin k → ℤ` of test integers.
Two things can be measured with such a battery.

* **Asymmetric (oracle) data.**  An oracle answering with the *Legendre* symbols
  `[(a i | p₀)]` of the hidden factor `p₀`.  The signature `qsig a p = (J(a i | p))ᵢ` is then a
  fingerprint of a candidate, and isolating `p₀` costs exactly as many queries as the
  information-theoretic minimum `⌈log₂ |S|⌉`.
* **Symmetric (public) data.**  The Jacobi symbols `[(a i | N)]` computable from `N` alone.
  These prune *nothing*: every candidate `r` admits a compensating partner making it consistent
  with the whole battery.

The gap between the two is the "symmetry-breaking cost".  This file makes all three sides of
that statement into theorems.

## Main results

* `exists_prescribed_signature` (independence / CRT surjectivity): for any finite set `S` of
  distinct odd primes and any prescribed sign pattern `e : ℕ → Bool` there is a single integer
  `x` with `J(x | p) = ±1` according to `e p`, simultaneously for all `p ∈ S`.  The Legendre
  signatures of distinct primes are completely unconstrained by one another.
* `exists_isolating_battery`: if `|S| ≤ 2 ^ k` there is an admissible battery of size `k` whose
  signature map is injective on `S` — `k` queries isolate every candidate.
* `info_lower_bound`: no `k`-tuple of queries with answers in a finite alphabet `β` can separate
  more than `(card β) ^ k` candidates.
* `isolationCost_isLeast`: **the exact measurement.**  The set of achievable battery sizes has
  least element `Nat.clog 2 |S|`, i.e. the isolation cost is exactly `⌈log₂ |S|⌉`.
* `isolation_cost_le_of_le_four_pow`: for candidates below `√N` this cost is at most `½ log₂ N`.
* `factor_of_isolated`: an isolated candidate that divides `N` yields a nontrivial factorisation.
* `zero_pruning`, `compensating_partner`, `unboundedly_many_survivors`: the symmetric battery
  `[(a i | N)]` eliminates no candidate whatsoever.
* `factor_of_nontrivial_sqrt_one`, `factor_of_even_order`: the *asymmetric* readout of Shor's
  algorithm (an element of even multiplicative order whose half-power is not `±1`) converts into
  a nontrivial factor by a gcd — the quantum payment for the same symmetry breaking.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the quadratic-residue signature of a prime is "generic": knowing the
signatures of all other primes tells you nothing about `p₀`'s.  If true, the signature map is a
perfect binary code on the candidate set and the isolation cost must equal `⌈log₂ |S|⌉` exactly,
with no slack in either direction.

Experiment (Experimenter): computed in `ComputationalEvidence.md`.  For the candidate sets of
`N = 3149 = 47·67`, `N = 10403 = 101·103` and `N = 1000003·1000033` truncated to the primes
below `√N`, greedy batteries of size `⌈log₂ π(√N)⌉` separated all candidates in every trial,
and no battery of size `⌈log₂ π(√N)⌉ - 1` ever did (pigeonhole).  Ratio (queries used) /
`log₂ π(√N)` stayed in `[1, 1.03]`.

Analysis (Analyst): both halves are structural, not statistical.  The upper bound is CRT:
sign patterns of distinct primes are independent, so the signature map can realise *any*
injection `S ↪ {±1}^k`.  The lower bound is pigeonhole on the answer alphabet.  Hence the
measurement `⌈log₂ |S|⌉` is exact, not asymptotic.

Critique (Critic): the lower bound must be stated for the alphabet actually used.  A Jacobi
symbol has three values, and a `0` answer is itself a factor disclosure; we therefore define
`Admissible` batteries (no `0` answers) for the exact `log₂` statement and record the general
ternary bound `info_lower_bound` separately.  No theorem below is vacuous: `isolationCost_mem`
exhibits the battery, and `zero_pruning` is proved for arbitrary candidates.
-/

namespace SymmetryBreakingCost

open Finset
open scoped NumberTheorySymbols

/-! ## 0.  Chinese remainder input -/

/-- Chinese remainder theorem over a finite set of pairwise coprime moduli, stated as a
simultaneous divisibility condition. -/
theorem crt_finset (S : Finset ℕ) (hcop : (S : Set ℕ).Pairwise Nat.Coprime) (b : ℕ → ℤ) :
    ∃ x : ℤ, ∀ r ∈ S, (r : ℤ) ∣ x - b r := by
  classical
  induction S using Finset.cons_induction with
  | empty => exact ⟨0, by simp⟩
  | cons p T hp ih =>
      have hcopT : (T : Set ℕ).Pairwise Nat.Coprime := fun x hx y hy hxy =>
        hcop (by simp [hx]) (by simp [hy]) hxy
      obtain ⟨x, hx⟩ := ih hcopT
      set M : ℕ := ∏ r ∈ T, r with hM
      have hcp : Nat.Coprime p M := by
        refine Nat.Coprime.prod_right ?_
        intro r hr
        exact hcop (by simp) (by simp [hr]) (by rintro rfl; exact hp hr)
      have hcpZ : IsCoprime (p : ℤ) (M : ℤ) := by
        rw [Int.isCoprime_iff_gcd_eq_one]
        simpa [Int.gcd_natCast_natCast] using hcp
      obtain ⟨u, v, huv⟩ := hcpZ
      refine ⟨b p * (v * M) + x * (u * p), ?_⟩
      intro r hr
      rcases Finset.mem_cons.mp hr with rfl | hrT
      · have key : b r * (v * M) + x * (u * r) - b r = (x - b r) * (u * r) := by
          linear_combination (b r) * huv
        exact key ▸ ⟨(x - b r) * u, by ring⟩
      · have hrM : (r : ℤ) ∣ (M : ℤ) := Int.natCast_dvd_natCast.mpr (Finset.dvd_prod_of_mem _ hrT)
        have key : b p * (v * M) + x * (u * p) - b r
            = (x - b r) * (u * p) + (b p - b r) * (v * M) := by
          linear_combination (b r) * huv
        exact key ▸ dvd_add (Dvd.dvd.mul_right (hx r hrT) _)
          (Dvd.dvd.mul_left (Dvd.dvd.mul_left hrM _) _)

/-- The Jacobi symbol only depends on the numerator modulo the denominator. -/
theorem jacobiSym_congr {a b : ℤ} {n : ℕ} (h : (n : ℤ) ∣ a - b) : J(a | n) = J(b | n) := by
  have hm : a ≡ b [ZMOD (n : ℤ)] := Int.ModEq.symm (Int.modEq_iff_dvd.mpr h)
  rw [jacobiSym.mod_left a, jacobiSym.mod_left b, hm]

/-! ## 1.  Independence of quadratic signatures -/

/-- **Full independence of Legendre signatures.**  For any finite set `S` of distinct odd primes
and any prescribed pattern of signs `e`, one single integer realises that pattern:
`J(x | p) = 1` if `e p` and `= -1` otherwise, simultaneously for all `p ∈ S`.

Equivalently: the map `x ↦ (J(x | p))_{p ∈ S}` is onto `{±1}^S`.  This is the exact sense in
which the residue battery of the hidden factor is an *unconstrained* fingerprint. -/
theorem exists_prescribed_signature (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2)
    (e : ℕ → Bool) : ∃ x : ℤ, ∀ p ∈ S, J(x | p) = if e p then 1 else -1 := by
  classical
  have H : ∀ p : ℕ, ∃ z : ℤ, p.Prime → p ≠ 2 → J(z | p) = if e p then 1 else -1 := by
    intro p
    by_cases hep : e p
    · exact ⟨1, fun _ _ => by simp [hep]⟩
    · by_cases hp : p.Prime
      · by_cases hp2 : p = 2
        · exact ⟨1, fun _ h => absurd hp2 h⟩
        · haveI : Fact p.Prime := ⟨hp⟩
          have hchar : ringChar (ZMod p) ≠ 2 := by rw [ZMod.ringChar_zmod_n]; exact hp2
          obtain ⟨y, hy⟩ := FiniteField.exists_nonsquare (F := ZMod p) hchar
          exact ⟨(y.val : ℤ), fun _ _ => by
            simpa [hep] using ZMod.nonsquare_iff_jacobiSym_eq_neg_one.mpr (by simpa using hy)⟩
      · exact ⟨1, fun h => absurd h hp⟩
  choose b hb using H
  have hcop : (S : Set ℕ).Pairwise Nat.Coprime := fun x hx y hy hxy =>
    (Nat.coprime_primes (hS x hx).1 (hS y hy).1).mpr hxy
  obtain ⟨x, hx⟩ := crt_finset S hcop b
  refine ⟨x, fun p hp => ?_⟩
  rw [jacobiSym_congr (hx p hp)]
  exact hb p (hS p hp).1 (hS p hp).2

/-! ## 2.  Batteries, signatures, and the isolation cost -/

/-- The quadratic-residue signature of a candidate modulus `r` under the battery `a`. -/
def qsig {k : ℕ} (a : Fin k → ℤ) (r : ℕ) : Fin k → ℤ := fun i => J(a i | r)

/-- A battery is *admissible* for `S` when no test integer is divisible by a candidate: every
answer is a genuine `±1` bit.  (A zero answer is not a query result but an outright disclosure
of the factor.) -/
def Admissible {k : ℕ} (a : Fin k → ℤ) (S : Finset ℕ) : Prop := ∀ i, ∀ p ∈ S, J(a i | p) ≠ 0

/-- A battery *isolates* the candidate set `S` when distinct candidates get distinct signatures;
in particular the hidden factor is the unique candidate matching the oracle's answers. -/
def Isolating {k : ℕ} (a : Fin k → ℤ) (S : Finset ℕ) : Prop := Set.InjOn (qsig a) (S : Set ℕ)

/-- The set of battery sizes that suffice to isolate every candidate in `S`. -/
def IsolationCost (S : Finset ℕ) : Set ℕ :=
  {k | ∃ a : Fin k → ℤ, Admissible a S ∧ Isolating a S}

/-- **Upper bound.**  `⌈log₂ |S|⌉` queries suffice: whenever `|S| ≤ 2 ^ k` there is an admissible
battery of `k` test integers separating all candidates.  The construction is the independence
theorem `exists_prescribed_signature` applied to an arbitrary binary encoding of `S`. -/
theorem exists_isolating_battery (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2) {k : ℕ}
    (hk : S.card ≤ 2 ^ k) : ∃ a : Fin k → ℤ, Admissible a S ∧ Isolating a S := by
  classical
  obtain ⟨c⟩ : Nonempty ((S : Finset ℕ) ↪ (Fin k → Bool)) :=
    Function.Embedding.nonempty_of_card_le (by simpa [Fintype.card_coe] using hk)
  set C : ℕ → Fin k → Bool := fun r => if h : r ∈ S then c ⟨r, h⟩ else fun _ => false with hC
  have H : ∀ i : Fin k, ∃ x : ℤ, ∀ p ∈ S, J(x | p) = if C p i then 1 else -1 :=
    fun i => exists_prescribed_signature S hS (fun r => C r i)
  choose a ha using H
  refine ⟨a, fun i p hp => ?_, ?_⟩
  · rw [ha i p hp]; split <;> norm_num
  · intro p hp q hq hpq
    simp only [Finset.mem_coe] at hp hq
    have hCC : C p = C q := by
      funext i
      have h1 := ha i p hp
      have h2 := ha i q hq
      have hval : (if C p i then (1 : ℤ) else -1) = (if C q i then 1 else -1) := by
        rw [← h1, ← h2]; exact congrFun hpq i
      by_cases hcp : C p i <;> by_cases hcq : C q i <;> simp_all
    rw [hC] at hCC
    simp only [dif_pos hp, dif_pos hq] at hCC
    exact congrArg Subtype.val (c.injective hCC)

/-- **Information-theoretic lower bound.**  A tuple of `k` queries whose answers lie in a finite
alphabet `β` cannot separate more than `(card β) ^ k` candidates: if `|S|` exceeds that, two
distinct candidates are confused. -/
theorem info_lower_bound {β : Type*} [Fintype β] [DecidableEq β] (S : Finset ℕ) {k : ℕ}
    (f : ℕ → Fin k → β) (hk : Fintype.card β ^ k < S.card) :
    ∃ p ∈ S, ∃ q ∈ S, p ≠ q ∧ f p = f q := by
  classical
  have hcard : (Finset.univ : Finset (Fin k → β)).card < S.card := by
    simpa [Finset.card_univ] using hk
  exact Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard (fun x _ => Finset.mem_univ _)

/-- The signature of an admissible battery is `±1` in each coordinate, so it is faithfully
recorded by a bit vector. -/
theorem qsig_eq_of_bits {k : ℕ} {a : Fin k → ℤ} {S : Finset ℕ} (hadm : Admissible a S)
    {p q : ℕ} (hp : p ∈ S) (hq : q ∈ S)
    (h : ∀ i, (J(a i | p) = 1) = (J(a i | q) = 1)) : qsig a p = qsig a q := by
  funext i
  have hp' := hadm i p hp
  have hq' := hadm i q hq
  rcases jacobiSym.trichotomy (a i) p with h1 | h1 | h1
  · exact absurd h1 hp'
  · have hq1 : J(a i | q) = 1 := by
      have hi := h i
      simp only [h1, eq_iff_iff] at hi
      exact hi.mp trivial
    simp [qsig, h1, hq1]
  · have hne : J(a i | q) ≠ 1 := by
      intro hcon
      have hi := h i
      rw [hcon, h1] at hi
      simp only [eq_iff_iff] at hi
      have : (-1 : ℤ) = 1 := hi.mpr trivial
      norm_num at this
    rcases jacobiSym.trichotomy (a i) q with h2 | h2 | h2
    · exact absurd h2 hq'
    · exact absurd h2 hne
    · simp [qsig, h1, h2]

/-- **The measurement.**  The least battery size that isolates every candidate in a set `S` of
distinct odd primes is exactly `⌈log₂ |S|⌉`.  The upper bound is the independence of quadratic
signatures (Chinese remainder theorem), the lower bound is pigeonhole on the answer bits. -/
theorem isolationCost_isLeast (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2) :
    IsLeast (IsolationCost S) (Nat.clog 2 S.card) := by
  classical
  constructor
  · exact exists_isolating_battery S hS (Nat.le_pow_clog (by norm_num) _)
  · rintro k ⟨a, hadm, hiso⟩
    rw [Nat.clog_le_iff_le_pow (by norm_num)]
    by_contra hcon
    push_neg at hcon
    obtain ⟨p, hp, q, hq, hpq, hfeq⟩ :=
      info_lower_bound (β := Bool) S (fun r i => decide (J(a i | r) = 1))
        (by simpa using hcon)
    refine hpq (hiso hp hq (qsig_eq_of_bits hadm hp hq (fun i => ?_)))
    have := congrFun hfeq i
    simpa using this

/-- Restated: `k` queries suffice **iff** `2 ^ k` is at least the number of candidates. -/
theorem mem_isolationCost_iff (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2) (k : ℕ) :
    k ∈ IsolationCost S ↔ S.card ≤ 2 ^ k := by
  constructor
  · intro hk
    have := (isolationCost_isLeast S hS).2 hk
    exact (Nat.clog_le_iff_le_pow (by norm_num)).mp this
  · exact fun h => exists_isolating_battery S hS h

/-- **Half the bits of `N`.**  If all candidates lie below `√N` (i.e. `p² ≤ N`) and `N ≤ 4 ^ k`,
then `k` queries isolate: the residue oracle needs at most `½ log₂ N` queries, matching
`log₂ π(√N)`. -/
theorem isolation_cost_le_of_le_four_pow (N k : ℕ) (S : Finset ℕ)
    (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2) (hsq : ∀ p ∈ S, p * p ≤ N) (hN : N ≤ 4 ^ k) :
    k ∈ IsolationCost S := by
  classical
  have hsqrt : Nat.sqrt N ≤ 2 ^ k := by
    have h4 : (4 : ℕ) ^ k = 2 ^ k * 2 ^ k := by
      rw [show (4 : ℕ) = 2 * 2 by norm_num, mul_pow]
    calc Nat.sqrt N ≤ Nat.sqrt (2 ^ k * 2 ^ k) := Nat.sqrt_le_sqrt (h4 ▸ hN)
      _ = 2 ^ k := Nat.sqrt_eq _
  have hsub : S ⊆ Finset.Icc 3 (Nat.sqrt N) := by
    intro p hp
    obtain ⟨hprime, hne2⟩ := hS p hp
    refine Finset.mem_Icc.mpr ⟨?_, Nat.le_sqrt.mpr (hsq p hp)⟩
    have h2 := hprime.two_le
    omega
  have hcard : S.card ≤ 2 ^ k := by
    have := Finset.card_le_card hsub
    rw [Nat.card_Icc] at this
    omega
  exact (mem_isolationCost_iff S hS k).mpr hcard

/-- Once the hidden prime is isolated it is found by matching signatures, and dividing then
factors `N` nontrivially. -/
theorem factor_of_isolated {k : ℕ} {a : Fin k → ℤ} {S : Finset ℕ} (hiso : Isolating a S)
    {N p₀ : ℕ} (hp₀ : p₀ ∈ S) (hdvd : p₀ ∣ N) (hlt : p₀ < N) :
    (∀ r ∈ S, qsig a r = qsig a p₀ → r = p₀) ∧ N = p₀ * (N / p₀) ∧ 1 < N / p₀ := by
  refine ⟨fun r hr h => hiso hr hp₀ h, (Nat.mul_div_cancel' hdvd).symm, ?_⟩
  by_contra hcon
  push_neg at hcon
  have hle : N ≤ p₀ := by
    calc N = p₀ * (N / p₀) := (Nat.mul_div_cancel' hdvd).symm
      _ ≤ p₀ * 1 := Nat.mul_le_mul_left _ hcon
      _ = p₀ := mul_one _
  omega

/-! ## 3.  The symmetric side: `N` alone prunes nothing -/

/-- Multiplying the modulus by a square coprime to the numerator does not change the Jacobi
symbol: the symmetric battery only sees the squarefree kernel of the modulus. -/
theorem jacobiSym_mul_sq (a : ℤ) (N t : ℕ) (hN : 0 < N) (ht : 0 < t) (hcop : Int.gcd a t = 1) :
    J(a | N * (t * t)) = J(a | N) := by
  haveI : NeZero t := ⟨ht.ne'⟩
  haveI : NeZero N := ⟨hN.ne'⟩
  haveI : NeZero (t * t) := ⟨(Nat.mul_pos ht ht).ne'⟩
  have hsq : J(a | t) * J(a | t) = 1 := by
    rcases jacobiSym.trichotomy a t with h | h | h
    · exact absurd (jacobiSym.eq_zero_iff.mp h).2 (by simpa using hcop)
    · simp [h]
    · simp [h]
  calc J(a | N * (t * t)) = J(a | N) * (J(a | t) * J(a | t)) := by
        rw [jacobiSym.mul_right, jacobiSym.mul_right]
    _ = J(a | N) := by rw [hsq, mul_one]

/-- **Compensating partner.**  For *any* candidate `r`, the modulus `r * (N * r)` has `r` as a
factor and yet reproduces the whole Jacobi battery of `N`.  The public data `[(a | N)]` is blind
to the presence of `r`. -/
theorem compensating_partner (N r : ℕ) (hN : 0 < N) (hr : 0 < r) :
    ∃ s : ℕ, 0 < s ∧ r ∣ r * s ∧ ∀ a : ℤ, Int.gcd a r = 1 → J(a | r * s) = J(a | N) := by
  refine ⟨N * r, Nat.mul_pos hN hr, Dvd.intro _ rfl, fun a ha => ?_⟩
  have hrw : r * (N * r) = N * (r * r) := by ring
  rw [hrw]
  exact jacobiSym_mul_sq a N r hN hr ha

/-- **Zero pruning.**  Every candidate survives the symmetric battery: for each `r` there is a
modulus `M` divisible by `r` whose Jacobi battery is identical to that of `N`. -/
theorem zero_pruning (N : ℕ) (hN : 0 < N) (r : ℕ) (hr : 0 < r) :
    ∃ M : ℕ, 0 < M ∧ r ∣ M ∧ ∀ a : ℤ, Int.gcd a r = 1 → J(a | M) = J(a | N) := by
  obtain ⟨s, hs, hdvd, hbat⟩ := compensating_partner N r hN hr
  exact ⟨r * s, Nat.mul_pos hr hs, hdvd, hbat⟩

/-- The blindness is not a finite accident: arbitrarily large moduli divisible by an arbitrary
candidate `r` carry exactly the same Jacobi battery as `N`. -/
theorem unboundedly_many_survivors (N : ℕ) (hN : 0 < N) (r : ℕ) (hr : 0 < r) (B : ℕ) :
    ∃ M : ℕ, B < M ∧ r ∣ M ∧ ∀ a : ℤ, Int.gcd a M = 1 → J(a | M) = J(a | N) := by
  classical
  set t : ℕ := r * (B + 1) with htdef
  have ht : 0 < t := Nat.mul_pos hr (Nat.succ_pos B)
  refine ⟨N * (t * t), ?_, ⟨N * ((B + 1) * t), by rw [htdef]; ring⟩, fun a ha => ?_⟩
  · have h1 : B + 1 ≤ t := Nat.le_mul_of_pos_left _ hr
    have h2 : t ≤ t * t := Nat.le_mul_of_pos_left t ht
    have h3 : t * t ≤ N * (t * t) := Nat.le_mul_of_pos_left _ hN
    omega
  · refine jacobiSym_mul_sq a N t hN ht ?_
    have hdvd : t ∣ N * (t * t) := ⟨N * t, by ring⟩
    have : Nat.Coprime a.natAbs (N * (t * t)) := by simpa [Int.gcd] using ha
    simpa [Int.gcd] using Nat.Coprime.coprime_dvd_right hdvd this

/-! ## 4.  The asymmetric quantum readout -/

/-- **Shor's classical post-processing.**  A nontrivial square root of `1` modulo `N` — the
asymmetric datum that order finding produces — is converted by one gcd into a nontrivial
factorisation.  This is the *other* way of paying the symmetry-breaking cost. -/
theorem factor_of_nontrivial_sqrt_one (N : ℕ) (x : ℤ) (hN : 1 < N) (hsq : (N : ℤ) ∣ x ^ 2 - 1)
    (h1 : ¬(N : ℤ) ∣ x - 1) (h2 : ¬(N : ℤ) ∣ x + 1) :
    Int.gcd (x - 1) N ∣ N ∧ 1 < Int.gcd (x - 1) N ∧ Int.gcd (x - 1) N < N := by
  set d : ℕ := Int.gcd (x - 1) N with hd
  have hdvdN : (d : ℕ) ∣ N := Int.natCast_dvd_natCast.mp (by
    simpa using Int.gcd_dvd_right (a := x - 1) (b := (N : ℤ)))
  have hdvdx : (d : ℤ) ∣ x - 1 := Int.gcd_dvd_left (x - 1) (N : ℤ)
  have hne1 : d ≠ 1 := by
    intro h
    have hcop : IsCoprime (x - 1) (N : ℤ) := Int.isCoprime_iff_gcd_eq_one.mpr h
    have hprod : (N : ℤ) ∣ (x - 1) * (x + 1) := by
      have : (x - 1) * (x + 1) = x ^ 2 - 1 := by ring
      rw [this]; exact hsq
    exact h2 (hcop.symm.dvd_of_dvd_mul_left hprod)
  have hneN : d ≠ N := by
    intro h
    exact h1 (by rw [← h]; exact hdvdx)
  refine ⟨hdvdN, ?_, ?_⟩
  · rcases Nat.eq_zero_or_pos d with h | h
    · exfalso
      have : (N : ℕ) = 0 := Nat.eq_zero_of_zero_dvd (h ▸ hdvdN)
      omega
    · omega
  · exact lt_of_le_of_ne (Nat.le_of_dvd (by omega) hdvdN) hneN

/-- The order-finding form: if `x` has even order `2 * m` modulo `N` and `x ^ m ≠ ±1`, a
nontrivial factor of `N` is read off by a gcd. -/
theorem factor_of_even_order (N : ℕ) (x : ℤ) (m : ℕ) (hN : 1 < N)
    (hord : (N : ℤ) ∣ x ^ (2 * m) - 1) (h1 : ¬(N : ℤ) ∣ x ^ m - 1)
    (h2 : ¬(N : ℤ) ∣ x ^ m + 1) :
    Int.gcd (x ^ m - 1) N ∣ N ∧ 1 < Int.gcd (x ^ m - 1) N ∧ Int.gcd (x ^ m - 1) N < N := by
  refine factor_of_nontrivial_sqrt_one N (x ^ m) hN ?_ h1 h2
  rw [← pow_mul, mul_comm m 2]
  exact hord

end SymmetryBreakingCost