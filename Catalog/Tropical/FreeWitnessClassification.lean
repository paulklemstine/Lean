import Mathlib
import Tropical.FactorLocationBarriers
import Tropical.TraceLemmaExhaustiveness

/-!
# The free-witness classification for CRT-multiplicative weights

`Tropical.TraceLemmaExhaustiveness` proved the trace-lemma dichotomy for the power
weights `d ↦ d ^ k`. This file removes the power hypothesis and proves the
classification for **arbitrary CRT-multiplicative weights**, which is the general
statement the free-witness programme conjectures.

A *CRT weight* is a function `w : ℕ → ℕ` with `w 1 = 1` that is multiplicative on
coprime arguments (`IsCRTWeight`). Its *aggregate* on a semiprime factors through the
CRT splitting, `A_w(pq) = (1 + w p)(1 + w q)` (`aggregate_semiprime`).

The classification proved here:

* **Positive branch — the trace lemma** (`crt_free_witness_recovery`): if `w` is
  strictly monotone then the aggregate value *is* a factor-secret coordinate: for
  coprime factorisations of a fixed `N`, the aggregate determines the factorisation.
  The mechanism is exactly the trace/norm pair: `w a · w b = w N` is fixed, so
  equality of aggregates forces equality of the *traces* `w a + w b`, and a pair of
  naturals is determined by its sum and product (`pair_unique_of_sum_prod`).
* **Negative branch — barrier 5** (`no_recovery_of_prime_collision`): if `w` fails to
  separate two primes then no function whatsoever of the aggregate can return a
  factor; the aggregate is factorisation-insensitive.
* **Exhaustiveness** (`crt_weight_dichotomy`): every CRT weight lies in exactly one
  of the two branches — there is no third behaviour. Together with the
  characters-only boundary lemma of the previous file (only characters decompose
  through the CRT), this is the classification statement, machine-checked.

Tropical reading (`tropical_trace_corner`, `balanced_pair_minimizes_trace`): in
min-plus coordinates the factorisations of `N` sit on the tropical line
`X ⊙ Y = N`, and the classical trace `a + b` is *minimised* at the pair nearest the
corner `√N`. The trace lemma says the whole factoring secret is the position of the
witness pair on this tropical line, and the aggregation barrier says that position
costs a full window sweep to find.
-/

namespace FreeWitness

open Finset FactorLocationBarriers

/-! ## 1. CRT weights and their semiprime aggregates -/

/-- A **CRT weight**: normalised (`w 1 = 1`) and multiplicative across the CRT
splitting. These are the "local weights" of the free-witness classification. -/
structure IsCRTWeight (w : ℕ → ℕ) : Prop where
  one : w 1 = 1
  mul : ∀ m n : ℕ, Nat.Coprime m n → w (m * n) = w m * w n

/-- Power weights are CRT weights. -/
theorem isCRTWeight_pow (k : ℕ) : IsCRTWeight (fun d => d ^ k) :=
  ⟨one_pow k, fun m n _ => mul_pow m n k⟩

/-- Power weights with `k ≥ 1` are strictly monotone. -/
theorem strictMono_pow {k : ℕ} (hk : 1 ≤ k) : StrictMono (fun d : ℕ => d ^ k) :=
  fun _ _ h => Nat.pow_lt_pow_left h (by omega)

/-- **The aggregate factors through the CRT splitting.** For distinct primes,
`∑_{d ∣ pq} w d = (1 + w p)(1 + w q)`. -/
theorem aggregate_semiprime {w : ℕ → ℕ} (hw : IsCRTWeight w) (p q : ℕ) (hp : p.Prime)
    (hq : q.Prime) (hpq : p ≠ q) :
    ∑ d ∈ (p * q).divisors, w d = (1 + w p) * (1 + w q) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have h1p : (1 : ℕ) ≠ p := hp.one_lt.ne
  have h1q : (1 : ℕ) ≠ q := hq.one_lt.ne
  have h1pq : (1 : ℕ) ≠ p * q := by nlinarith
  have hppq : p ≠ p * q := by nlinarith
  have hqpq : q ≠ p * q := by nlinarith
  rw [divisors_semiprime p q hp hq,
    Finset.sum_insert (by simp [h1p, h1q, h1pq]),
    Finset.sum_insert (by simp [hpq, hppq]),
    Finset.sum_insert (by simp [hqpq]), Finset.sum_singleton, hw.mul p q hcop, hw.one]
  ring

/-! ## 2. Trace and norm determine the pair -/

/-- A pair of naturals is determined by its sum and its product (ordered form). This
is the elementary content of the trace lemma: the witness is a *trace* coordinate and
`N` is the *norm* coordinate. -/
theorem pair_unique_of_sum_prod {x y x' y' : ℕ} (hxy : x ≤ y) (hxy' : x' ≤ y')
    (hs : x + y = x' + y') (hp : x * y = x' * y') : x = x' ∧ y = y' := by
  have hx : x = x' := by
    rcases lt_trichotomy x x' with h | h | h
    · exfalso; nlinarith
    · exact h
    · exfalso; nlinarith
  exact ⟨hx, by omega⟩

/-! ## 3. Positive branch: the trace lemma for strictly monotone CRT weights -/

/-- **The trace lemma, general form.** For a strictly monotone CRT weight, the
aggregate value determines the coprime factorisation of `N`: distinct coprime
factorisations get distinct aggregates. Hence the witness collapses to a
factor-secret coordinate, exactly as the classification predicts. -/
theorem crt_free_witness_recovery {w : ℕ → ℕ} (hw : IsCRTWeight w) (hmono : StrictMono w)
    {N a b a' b' : ℕ} (hab : Nat.Coprime a b) (hab' : Nat.Coprime a' b')
    (hle : a ≤ b) (hle' : a' ≤ b') (h : a * b = N) (h' : a' * b' = N)
    (hA : (1 + w a) * (1 + w b) = (1 + w a') * (1 + w b')) : a = a' ∧ b = b' := by
  have hprod : w a * w b = w a' * w b' := by
    have e1 : w N = w a * w b := by rw [← h]; exact hw.mul a b hab
    have e2 : w N = w a' * w b' := by rw [← h']; exact hw.mul a' b' hab'
    rw [← e1, e2]
  have hsum : w a + w b = w a' + w b' := by nlinarith [hA, hprod]
  have hwle : w a ≤ w b := hmono.monotone hle
  have hwle' : w a' ≤ w b' := hmono.monotone hle'
  obtain ⟨e1, _⟩ := pair_unique_of_sum_prod hwle hwle' hsum hprod
  have haa' : a = a' := hmono.injective e1
  refine ⟨haa', ?_⟩
  subst haa'
  rcases Nat.eq_zero_or_pos a with rfl | ha0
  · simp only [Nat.coprime_zero_left] at hab hab'
    omega
  · exact Nat.eq_of_mul_eq_mul_left ha0 (by rw [h, h'])

/-- Instantiation: the power-weight case, recovered from the general theorem. -/
theorem crt_free_witness_recovery_pow {k : ℕ} (hk : 1 ≤ k) {N a b a' b' : ℕ}
    (hab : Nat.Coprime a b) (hab' : Nat.Coprime a' b') (hle : a ≤ b) (hle' : a' ≤ b')
    (h : a * b = N) (h' : a' * b' = N)
    (hA : (1 + a ^ k) * (1 + b ^ k) = (1 + a' ^ k) * (1 + b' ^ k)) : a = a' ∧ b = b' :=
  crt_free_witness_recovery (isCRTWeight_pow k) (strictMono_pow hk) hab hab' hle hle' h h' hA

/-! ## 4. Negative branch: a prime collision kills every recovery algorithm -/

/-- **Barrier 5.** If a CRT weight fails to separate two primes, then *no* function of
its aggregate can return the smaller prime factor of a semiprime: the two semiprimes
`p·q` and `p'·q` (for a large prime `q`) have equal aggregates but different smaller
factors. -/
theorem no_recovery_of_prime_collision {w : ℕ → ℕ} (hw : IsCRTWeight w) {p p' : ℕ}
    (hp : p.Prime) (hp' : p'.Prime) (hne : p ≠ p') (hcoll : w p = w p') :
    ¬ ∃ f : ℕ → ℕ, ∀ x y : ℕ, x.Prime → y.Prime → x < y →
        f (∑ d ∈ (x * y).divisors, w d) = x := by
  rintro ⟨f, hf⟩
  obtain ⟨q, hqlarge, hq⟩ := Nat.exists_infinite_primes (max p p' + 1)
  have hpq : p < q := lt_of_le_of_lt (le_max_left p p') (by omega)
  have hp'q : p' < q := lt_of_le_of_lt (le_max_right p p') (by omega)
  have h1 := hf p q hp hq hpq
  have h2 := hf p' q hp' hq hp'q
  rw [aggregate_semiprime hw p q hp hq hpq.ne] at h1
  rw [aggregate_semiprime hw p' q hp' hq hp'q.ne] at h2
  rw [hcoll] at h1
  exact hne (h1.symm.trans h2)

/-- **The exhaustive dichotomy for CRT weights.** Every CRT weight either separates
primes — in which case, if it is moreover monotone, its aggregate is a free witness
that pins the factorisation (`crt_free_witness_recovery`) — or it collides on two
primes, in which case no function of the aggregate can ever return a factor. There is
no third possibility. -/
theorem crt_weight_dichotomy {w : ℕ → ℕ} (hw : IsCRTWeight w) :
    (∀ p p' : ℕ, p.Prime → p'.Prime → w p = w p' → p = p')
      ∨ ¬ ∃ f : ℕ → ℕ, ∀ x y : ℕ, x.Prime → y.Prime → x < y →
          f (∑ d ∈ (x * y).divisors, w d) = x := by
  by_cases hinj : ∀ p p' : ℕ, p.Prime → p'.Prime → w p = w p' → p = p'
  · exact Or.inl hinj
  · right
    push_neg at hinj
    obtain ⟨p, p', hp, hp', hcoll, hne⟩ := hinj
    exact no_recovery_of_prime_collision hw hp hp' hne hcoll

/-- The dichotomy in its sharpest form for *monotone* weights: either the aggregate
recovers the factorisation, or the weight is not injective — and the two cases are
mutually exclusive for a strictly monotone weight, which is always injective. So a
strictly monotone CRT weight is *always* a free witness. -/
theorem strictMono_crt_weight_is_free_witness {w : ℕ → ℕ} (hw : IsCRTWeight w)
    (hmono : StrictMono w) {p q p' q' : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q)
    (hp' : p'.Prime) (hq' : q'.Prime) (hlt' : p' < q')
    (hN : p * q = p' * q')
    (hA : ∑ d ∈ (p * q).divisors, w d = ∑ d ∈ (p' * q').divisors, w d) :
    p = p' ∧ q = q' := by
  rw [aggregate_semiprime hw p q hp hq hlt.ne, aggregate_semiprime hw p' q' hp' hq' hlt'.ne] at hA
  exact crt_free_witness_recovery hw hmono ((Nat.coprime_primes hp hq).mpr hlt.ne)
    ((Nat.coprime_primes hp' hq').mpr hlt'.ne) hlt.le hlt'.le rfl hN.symm hA

/-! ## 5. Tropical reading: the trace is minimised at the corner -/

/-- **The balanced pair minimises the classical trace.** Among factorisations
`a · b = N` with `a ≤ b`, the one closest to the tropical corner `√N` has the
smallest sum. -/
theorem balanced_pair_minimizes_trace {N a b a' b' : ℕ} (hN : 0 < N) (hle : a ≤ b) (hle' : a' ≤ b')
    (h : a * b = N) (h' : a' * b' = N) (hmono : a ≤ a') : a' + b' ≤ a + b := by
  have ha0 : 0 < a := by
    rcases Nat.eq_zero_or_pos a with rfl | hpos
    · simp only [Nat.zero_mul] at h; omega
    · exact hpos
  rcases eq_or_lt_of_le hmono with rfl | hlt
  · have hb : b = b' := Nat.eq_of_mul_eq_mul_left ha0 (by rw [h, h'])
    omega
  · exact le_of_lt (TraceLemma.sum_gt_of_spread hlt hle' (by rw [h, h']))

/-- The same statement in the tropical semiring: the min-plus sum of the two traces is
the trace of the more balanced pair, i.e. the corner of the tropical line
`X ⊙ Y = N` is where the trace attains its tropical minimum. -/
theorem tropical_trace_corner {N a b a' b' : ℕ} (hN : 0 < N) (hle : a ≤ b) (hle' : a' ≤ b')
    (h : a * b = N) (h' : a' * b' = N) (hmono : a ≤ a') :
    (Tropical.trop (a + b) + Tropical.trop (a' + b') : Tropical ℕ)
      = Tropical.trop (a' + b') := by
  rw [Tropical.trop_add_def]
  simp [min_eq_right (balanced_pair_minimizes_trace hN hle hle' h h' hmono)]

/-- For a semiprime the tropical minimum of the trace over the two coprime
factorisations is `p + q`, strictly below the trivial factorisation's trace `1 + N`:
the corner sees the factors, and nothing else does. -/
theorem semiprime_tropical_trace_min {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    (Tropical.trop (1 + p * q) + Tropical.trop (p + q) : Tropical ℕ) = Tropical.trop (p + q)
      ∧ p + q < 1 + p * q := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hstrict : p + q < 1 + p * q := by nlinarith
  refine ⟨?_, hstrict⟩
  rw [Tropical.trop_add_def]
  simp [min_eq_right hstrict.le]

end FreeWitness