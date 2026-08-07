import Applications.AdjacentSumPolytopes.Growth

/-!
# Rotation action, Möbius recurrence, and a Gauss congruence

The cyclic adjacent-sum lattice points of length `n` carry an action of the cyclic group
of order `n` by rotation of coordinates.  When `n = p` is prime, the fixed-point formula
for `p`-groups yields a congruence between the cyclic count and the number of *constant*
points, i.e. the trace of the transfer matrix itself:

`#(cyclic points of length p) ≡ ⌊s/2⌋ + 1 = tr (adjMat s)  (mod p)`.

This is the first instance of the Gauss congruence `tr(Mⁿ) ≡ ∑_{d ∣ n} μ(n/d) tr(M^d) ≡ 0
(mod n)` for the transfer matrix, and it is exactly the statement that the *primitive*
(aperiodic) cyclic points of prime length come in orbits of size `p`.

We also set up the **Möbius recurrence** for the cyclic counts: the primitive counts
`primCyc s n = ∑_{(a,b) : ab = n} μ(a) · tr(M^b)` satisfy
`∑_{d ∣ n} primCyc s d = tr(Mⁿ)` for all `n > 0`, and `p ∣ primCyc s p` for `p` prime.

-- !-- Lab Notes -- !--
* **Hypothesis.** Rotation of a cyclic adjacent-sum point is again one; for prime length
  the only rotation-fixed points are the constant ones, which are exactly the "core"
  states `2a ≤ s`.  Hence the prime congruence.
* **Experiment.** `s = 2`, where `tr(adjMat 2) = ⌊2/2⌋ + 1 = 2`.  The cyclic counts for
  lengths `1..7` are `2, 6, 11, 26, 57, 129, 289`.  At the prime lengths:
  `tr(M²) = 6 ≡ 0 ≡ 2 (mod 2)`, `tr(M³) = 11 = 3·3 + 2 ≡ 2 (mod 3)`,
  `tr(M⁵) = 57 = 11·5 + 2 ≡ 2 (mod 5)`, `tr(M⁷) = 289 = 41·7 + 2 ≡ 2 (mod 7)` — all
  congruent to `tr(M) = 2`, as predicted.  Note the indexing: `cycCount s d` is the
  count for length `d + 1`.
* **Analysis.** The congruence survives; the primes are exactly where the fixed-point
  formula applies with no extra bookkeeping, and the general `n` case requires the full
  necklace/orbit decomposition, recorded as a conjecture.
* **Critique.** The proof is not vacuous: the fixed-point set is genuinely computed
  (`fixEquiv`), and it is nonempty (the origin is always a point), so the congruence has
  content on both sides.
-/

namespace AdjSum

open Finset Matrix

/-! ## The trace of the transfer matrix counts the core states -/

theorem trace_adjMat (s : ℕ) : Matrix.trace (adjMat s) = s / 2 + 1 := by
  rw [trace_eq_sum, ← card_coreStates]
  have key : ∀ a : Fin (s + 1), adjMat s a a = if a ∈ coreStates s then 1 else 0 := by
    intro a
    by_cases ha : a ∈ coreStates s
    · simp only [coreStates, Finset.mem_filter, Finset.mem_univ, true_and] at ha
      simp [adjMat, coreStates, ha, show (a : ℕ) + (a : ℕ) ≤ s from by omega]
    · simp only [coreStates, Finset.mem_filter, Finset.mem_univ, true_and] at ha
      simp [adjMat, coreStates, ha, show ¬((a : ℕ) + (a : ℕ) ≤ s) from by omega]
  simp_rw [key]
  rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, smul_eq_mul, mul_one]

/-! ## The rotation action on cyclic points -/

/-- The type of cyclic adjacent-sum lattice points of length `q + 1`. -/
abbrev CycPt (s q : ℕ) := {x : Fin (q + 1) → Fin (s + 1) // x ∈ cycSet s q}

/-- Rotation of the coordinates of a cyclic point. -/
def rot (s q : ℕ) : Function.End (CycPt s q) := fun x =>
  ⟨fun i => x.1 (i + 1), by
    rw [mem_cycSet]
    intro i
    exact (mem_cycSet.mp x.2) (i + 1)⟩

lemma rot_pow_apply (s q : ℕ) (k : ℕ) (x : CycPt s q) (i : Fin (q + 1)) :
    ((rot s q ^ k) x).1 i = x.1 ⟨(i.val + k) % (q + 1), Nat.mod_lt _ (Nat.succ_pos q)⟩ := by
  induction k generalizing x i with
  | zero =>
      simp only [pow_zero, Nat.add_zero]
      show x.1 i = _
      exact Fin.ext (by simp [Nat.mod_eq_of_lt i.isLt])
  | succ k ih =>
      rw [pow_succ]
      show ((rot s q ^ k) (rot s q x)).1 i = _
      rw [ih (rot s q x) i]
      show x.1 (⟨(i.val + k) % (q + 1), Nat.mod_lt _ (Nat.succ_pos q)⟩ + 1) = _
      have hidx : (⟨(i.val + k) % (q + 1), Nat.mod_lt _ (Nat.succ_pos q)⟩ : Fin (q + 1)) + 1
          = ⟨(i.val + (k + 1)) % (q + 1), Nat.mod_lt _ (Nat.succ_pos q)⟩ := by
        refine Fin.ext ?_
        show ((i.val + k) % (q + 1) + (1 : Fin (q + 1)).val) % (q + 1)
          = (i.val + (k + 1)) % (q + 1)
        rw [Fin.val_one', ← Nat.add_mod]
        congr 1
      rw [hidx]

/-- Rotating `q + 1` times is the identity. -/
lemma rot_pow_card (s q : ℕ) : (rot s q) ^ (q + 1) = 1 := by
  funext x
  refine Subtype.ext ?_
  funext i
  rw [rot_pow_apply]
  have hi : (⟨(i.val + (q + 1)) % (q + 1), Nat.mod_lt _ (Nat.succ_pos q)⟩ : Fin (q + 1)) = i := by
    refine Fin.ext ?_
    simp [Nat.add_mod_right, Nat.mod_eq_of_lt i.isLt]
  rw [hi]
  rfl

/-- A rotation-fixed cyclic point is constant. -/
lemma fixed_const (s q : ℕ) (x : CycPt s q) (hx : rot s q x = x) (i : Fin (q + 1)) :
    x.1 i = x.1 0 := by
  have hstep : ∀ j : Fin (q + 1), x.1 (j + 1) = x.1 j := fun j =>
    congrFun (congrArg Subtype.val hx) j
  have key : ∀ k : ℕ, ∀ hk : k < q + 1, x.1 ⟨k, hk⟩ = x.1 0 := by
    intro k
    induction k with
    | zero => intro _; rfl
    | succ k ih =>
        intro hk
        have hk' : k < q + 1 := by omega
        have hq : 1 < q + 1 := by omega
        have hidx : (⟨k, hk'⟩ : Fin (q + 1)) + 1 = ⟨k + 1, hk⟩ := by
          refine Fin.ext ?_
          show (k + (1 : Fin (q + 1)).val) % (q + 1) = k + 1
          rw [Fin.val_one', Nat.mod_eq_of_lt hq, Nat.mod_eq_of_lt hk]
        rw [← hidx, hstep ⟨k, hk'⟩]
        exact ih hk'
  exact key i.val i.isLt

/-- The rotation-fixed cyclic points are exactly the core states. -/
def fixEquiv (s q : ℕ) :
    Function.fixedPoints (rot s q) ≃ {a : Fin (s + 1) // 2 * (a : ℕ) ≤ s} where
  toFun := fun x => ⟨x.1.1 0, by
    have hc := fixed_const s q x.1 x.2
    have h := (mem_cycSet.mp x.1.2) 0
    rw [hc (0 + 1)] at h
    omega⟩
  invFun := fun a => ⟨⟨fun _ => a.1, by
      rw [mem_cycSet]
      intro i
      omega⟩, by
      show rot s q _ = _
      rfl⟩
  left_inv := by
    intro x
    refine Subtype.ext (Subtype.ext ?_)
    funext i
    exact (fixed_const s q x.1 x.2 i).symm
  right_inv := by
    intro a
    rfl

/-! ## The prime congruence -/

/-- **Prime Gauss congruence for the adjacent-sum model.**  For a prime length `p = q+1`,
the number of cyclic adjacent-sum lattice points is congruent, modulo `p`, to the number
of constant ones, i.e. to `tr (adjMat s) = ⌊s/2⌋ + 1`. -/
theorem cycCount_prime_congr (s q : ℕ) (hp : Nat.Prime (q + 1)) :
    cycCount s q ≡ s / 2 + 1 [MOD q + 1] := by
  haveI : Fact (Nat.Prime (q + 1)) := ⟨hp⟩
  have hpow : (rot s q) ^ (q + 1) ^ 1 = 1 := by rw [pow_one]; exact rot_pow_card s q
  have h := Equiv.Perm.card_fixedPoints_modEq (f := rot s q) (p := q + 1) (n := 1) hpow
  rw [Fintype.card_congr (fixEquiv s q)] at h
  have hc : Fintype.card (CycPt s q) = cycCount s q := by
    rw [cycCount]
    exact Fintype.card_coe _
  have hf : Fintype.card {a : Fin (s + 1) // 2 * (a : ℕ) ≤ s} = s / 2 + 1 := by
    rw [Fintype.card_subtype, ← card_coreStates]
    rfl
  rwa [hc, hf] at h

/-- Ring-theoretic form: `p ∣ tr(Mᵖ) − tr(M)` for prime `p`. -/
theorem prime_dvd_trace_sub (s q : ℕ) (hp : Nat.Prime (q + 1)) :
    ((q + 1 : ℕ) : ℤ) ∣ (Matrix.trace (adjMatZ s ^ (q + 1)) - Matrix.trace (adjMatZ s)) := by
  have h := cycCount_prime_congr s q hp
  have h1 : (cycCount s q : ℤ) = Matrix.trace (adjMatZ s ^ (q + 1)) := cycCount_eq s q
  have h2 : ((s / 2 + 1 : ℕ) : ℤ) = Matrix.trace (adjMatZ s) := by
    rw [show adjMatZ s = (adjMatZ s) ^ 1 from (pow_one _).symm, trace_adjMatZ_pow, pow_one,
      trace_adjMat]
  rw [← h1, ← h2]
  exact h.symm.dvd

/-! ## The Möbius recurrence -/

/-- The trace sequence of the integral transfer matrix. -/
def traceSeq (s n : ℕ) : ℤ := Matrix.trace (adjMatZ s ^ n)

/-- The *primitive* cyclic counts, defined by Möbius inversion of the trace sequence. -/
def primCyc (s n : ℕ) : ℤ :=
  ∑ x ∈ n.divisorsAntidiagonal, ArithmeticFunction.moebius x.1 • traceSeq s x.2

/-- **Möbius recurrence.**  The primitive counts sum over divisors to the cyclic counts. -/
theorem sum_divisors_primCyc (s n : ℕ) (hn : 0 < n) :
    ∑ d ∈ n.divisors, primCyc s d = traceSeq s n := by
  have h := (ArithmeticFunction.sum_eq_iff_sum_smul_moebius_eq
    (f := primCyc s) (g := traceSeq s)).mpr (fun m _ => rfl)
  exact h n hn

/-- For a prime length the primitive count is divisible by that prime. -/
theorem prime_dvd_primCyc (s q : ℕ) (hp : Nat.Prime (q + 1)) :
    ((q + 1 : ℕ) : ℤ) ∣ primCyc s (q + 1) := by
  have hval : primCyc s (q + 1) = traceSeq s (q + 1) - traceSeq s 1 := by
    rw [primCyc, Nat.sum_divisorsAntidiagonal
      (f := fun a b => ArithmeticFunction.moebius a • traceSeq s b)]
    rw [hp.divisors, Finset.sum_pair (Nat.ne_of_lt hp.one_lt)]
    simp [ArithmeticFunction.moebius_apply_prime hp, Nat.div_self hp.pos]
    ring
  rw [hval, traceSeq, traceSeq, pow_one]
  exact prime_dvd_trace_sub s q hp

end AdjSum