import Mathlib

/-!
# Jacobi Gauss sums: phase collapse for semiprime moduli

For an odd modulus `N` the *Jacobi Gauss sum* is
$$\tau(N) \;=\; \sum_{n=0}^{N-1} \left(\tfrac{n}{N}\right) e^{2\pi i n/N},$$
where `(n/N)` is the Jacobi symbol.  For `N = p*q` a product of two distinct odd primes the
Jacobi symbol is the quadratic Dirichlet character modulo `N`, and `|τ(N)| = √N`.

A priori the *phase* of `τ(N)` could remember the pair `(p mod 4, q mod 4)` separately, which
would make it a factor-revealing invariant.  The results in this file show that it does not:
the phase is a function of `N mod 4` alone.

Main results:

* `tau_eq_legendre_mul_gaussSum` (the CRT / twisted-multiplicativity mechanism):
  `τ(pq) = (q/p)(p/q) · g_p · g_q`, where `g_p` is the classical quadratic Gauss sum mod `p`.
* `gaussSumPrime_sq` : `g_p² = ±p` according to `p mod 4`.
* `tau_sq` (unconditional): `τ(pq)² = N` if `N ≡ 1 mod 4` and `-N` otherwise; equivalently
  the phase of `τ(pq)` is determined modulo `π` by `N mod 4`.
* `tau_eq_of_gaussSign` and `arg_tau_of_gaussSign`: given the classical sign determination of
  the *prime* quadratic Gauss sum (Gauss' theorem, not available in Mathlib), the phase is
  exactly `0` or `π/2` according to `N mod 4` — the (3,3) case's two factors `i·i = -1` are
  exactly cancelled by the reciprocity sign `(q/p)(p/q) = -1`.
* `tau_fifteen` : an unconditional instance, `τ(15) = i√15`, proved from scratch.

A second and third research cycle push the same phenomenon to arbitrary odd squarefree moduli:

* `jacobiChar` : the Jacobi symbol modulo `m` as a `MulChar (ZMod m) ℂ`.
* `tau_mul_coprime` : `τ(mn) = (n/m)(m/n) τ(m) τ(n)` for *any* coprime moduli (no primality).
* `tau_sq_squarefree` : unconditionally `τ(N)² = ±N` for every odd squarefree `N`.
* `tau_eq_of_gaussSign_squarefree`, `arg_tau_eq_of_mod_four` : given Gauss' sign theorem, the
  argument of `τ(N)` is a function of `N mod 4` alone, for every odd squarefree `N`.
* `norm_tau_squarefree` : unconditionally `|τ(N)| = √N`.
* `tau_sq_div_eq_of_mod_four` : unconditional form of the "one bit" statement.

A fourth cycle supplies the unconditional witness of the cancellation mechanism itself:

* `gaussSumPrime_seven` : `g_7 = i√7`, computed from scratch (real part cancels, the
  remaining sine bracket is positive by monotonicity of `sin` on `[0, π/2]`).
* `tau_twentyone` : `τ(21) = √21`, the `(3 mod 4, 3 mod 4)` case, where the two factors `i`
  and the reciprocity sign `-1` annihilate each other — unconditionally.

A fifth cycle delimits exactly what is conditional:

* `tau_eq_or_neg_squarefree` : unconditionally `τ(N) ∈ {±√N}` or `{±i√N}` according to
  `N mod 4`, so the residual dependence on the factorisation is at most one global sign, and
  Gauss' sign theorem is needed only to remove that sign.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the phase of `τ(N)` for `N = pq` might separate the four classes
`(p mod 4, q mod 4)`; if it did, one bit of factor information would be readable off a single
exponential sum.

Experiment (Experimenter): we computed `τ(N)` for the 13 test semiprimes
15, 21, 33, 35, 51, 65, 77, 85, 91, 115, 143, 187, 209 (see `ComputationalEvidence.md`).
In every case `τ(N)/√N ∈ {1, i}`, with value `1` exactly when `N ≡ 1 mod 4`, i.e. when
`p ≡ q mod 4`.  No dependence on the individual residues survived.

Analysis (Analyst): the collapse is forced by quadratic reciprocity.  CRT gives
`τ(pq) = (q/p)(p/q) g_p g_q`; the pair `(g_p, g_q)` does see `(p mod 4, q mod 4)` separately
(`g_p` is real for `p ≡ 1` and purely imaginary for `p ≡ 3`), but in the only case where the
two imaginary units multiply to `-1`, namely `p ≡ q ≡ 3 (4)`, reciprocity contributes exactly
`-1` as well.  The two sign sources are not independent — they are the same sign.

Critique (Critic): the unconditional part of the analysis (`tau_sq`) uses no sign information
at all and is therefore immune to the missing Gauss sign theorem; it already proves the phase
is determined mod `π` by `N mod 4`.  The exact phase statement genuinely needs Gauss' sign
theorem, which we carry as an explicit hypothesis rather than an axiom, and which we verify
unconditionally for `p = 3` and `p = 5` (hence the unconditional `τ(15) = i√15`).

Synthesis (PI): the "phase" channel of the Jacobi Gauss sum is exactly one bit, and that bit
is `N mod 4`, which is public information.  Structural orthogonality to factorisation.
-/

namespace JacobiGaussPhase

open Complex Finset

/-! ### Definitions -/

/-- The Jacobi Gauss sum `τ(N) = ∑_{n<N} (n/N) e^{2πin/N}`. -/
noncomputable def tau (N : ℕ) : ℂ :=
  ∑ n ∈ Finset.range N, (jacobiSym n N : ℂ) * Complex.exp (2 * Real.pi * I * n / N)

/-- The quadratic character mod a prime `p`, with values in `ℂ`. -/
noncomputable def chiC (p : ℕ) [Fact p.Prime] : MulChar (ZMod p) ℂ :=
  (quadraticChar (ZMod p)).ringHomComp (Int.castRingHom ℂ)

/-- The classical quadratic Gauss sum `g_p = ∑_{a mod p} (a/p) e^{2πia/p}`. -/
noncomputable def gaussSumPrime (p : ℕ) [Fact p.Prime] : ℂ :=
  gaussSum (chiC p) ZMod.stdAddChar

/-! ### Elementary rewriting lemmas -/

lemma exp_eq_stdAddChar (N : ℕ) [NeZero N] (a : ℕ) :
    Complex.exp (2 * Real.pi * I * a / N) = ZMod.stdAddChar ((a : ℕ) : ZMod N) := by
  rw [show ((a : ℕ) : ZMod N) = ((a : ℤ) : ZMod N) by push_cast; ring, ZMod.stdAddChar_coe]
  push_cast; ring_nf

lemma tau_eq_zmod_sum (N : ℕ) [NeZero N] :
    tau N = ∑ x : ZMod N, (jacobiSym (x.val : ℤ) N : ℂ) * ZMod.stdAddChar x := by
  rw [tau]
  refine Finset.sum_nbij' (fun n => ((n : ℕ) : ZMod N)) (fun x => x.val) ?_ ?_ ?_ ?_ ?_
  · intro a _; simp
  · intro a _; simp only [Finset.mem_range]; exact ZMod.val_lt a
  · intro a ha; simp only [Finset.mem_range] at ha; exact ZMod.val_cast_of_lt ha
  · intro a _; simp
  · intro a ha
    simp only [Finset.mem_range] at ha
    rw [ZMod.val_cast_of_lt ha]
    exact congrArg _ (exp_eq_stdAddChar N a)

lemma chiC_apply (p : ℕ) [Fact p.Prime] (a : ZMod p) :
    chiC p a = ((quadraticChar (ZMod p) a : ℤ) : ℂ) := rfl

lemma chiC_isQuadratic (p : ℕ) [Fact p.Prime] : (chiC p).IsQuadratic :=
  (quadraticChar_isQuadratic _).comp _

lemma chiC_ne_one (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) : chiC p ≠ 1 := by
  intro h
  refine quadraticChar_ne_one (F := ZMod p) (by rwa [ZMod.ringChar_zmod_n]) ?_
  ext a
  have h2 := congrArg (fun f : MulChar (ZMod p) ℂ => f a) h
  simp only [chiC, MulChar.ringHomComp_apply, MulChar.one_apply_coe] at h2
  simp only [MulChar.one_apply_coe]
  have h3 : ((quadraticChar (ZMod p) (a : ZMod p) : ℤ) : ℂ) = ((1 : ℤ) : ℂ) := by
    simpa using h2
  exact_mod_cast h3

lemma chiC_legendreSym (p : ℕ) [Fact p.Prime] (a : ℤ) :
    chiC p (a : ZMod p) = ((legendreSym p a : ℤ) : ℂ) := rfl

/-! ### The prime Gauss sum square -/

/-- `g_p² = χ₄(p) · p`; i.e. `p` for `p ≡ 1 mod 4` and `-p` for `p ≡ 3 mod 4`. -/
theorem gaussSumPrime_sq (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    gaussSumPrime p ^ 2 = if p % 4 = 1 then (p : ℂ) else -(p : ℂ) := by
  have hchar : ringChar (ZMod p) ≠ 2 := by rwa [ZMod.ringChar_zmod_n]
  have hodd : p % 2 = 1 := Nat.odd_iff.mp ((Fact.out : p.Prime).odd_of_ne_two hp)
  have h := gaussSum_sq (chiC_ne_one p hp) ((quadraticChar_isQuadratic (ZMod p)).comp _)
    (ZMod.isPrimitive_stdAddChar p)
  rw [gaussSumPrime, h, show ((chiC p) (-1)) = ((quadraticChar (ZMod p) (-1) : ℤ) : ℂ) from rfl,
    quadraticChar_neg_one hchar, ZMod.card, ZMod.χ₄_nat_eq_if_mod_four]
  rw [if_neg (by omega)]
  split <;> simp

/-! ### The CRT factorisation -/

variable {p q : ℕ}

/-- Splitting of the additive character `e^{2πi n/(pq)}` along a Bézout relation
`u q + v p = 1`. -/
lemma stdAddChar_split [NeZero p] [NeZero q] [NeZero (p * q)] {u v : ℤ}
    (huv : u * q + v * p = 1) (n : ℤ) :
    ZMod.stdAddChar ((n : ZMod (p * q)))
      = ZMod.stdAddChar (((u * n : ℤ) : ZMod p)) * ZMod.stdAddChar (((v * n : ℤ) : ZMod q)) := by
  rw [ZMod.stdAddChar_coe, ZMod.stdAddChar_coe, ZMod.stdAddChar_coe, ← Complex.exp_add]
  congr 1
  have hp0 : (p : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (NeZero.ne p)
  have hq0 : (q : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (NeZero.ne q)
  have huvC : (u : ℂ) * q + v * p = 1 := by exact_mod_cast congrArg (fun z : ℤ => (z : ℂ)) huv
  push_cast
  field_simp
  linear_combination (-(n : ℂ)) * huvC

/-- Multiplying the additive character by a unit twists the Gauss sum by a Legendre symbol. -/
lemma gaussSum_mulShift_legendre [Fact p.Prime] {u : ℤ}
    (hu : ((u : ZMod p)) * ((q : ℕ) : ZMod p) = 1) :
    (∑ a : ZMod p, chiC p a * (ZMod.stdAddChar.mulShift ((u : ZMod p))) a)
      = ((legendreSym p q : ℤ) : ℂ) * gaussSumPrime p := by
  have hU : IsUnit ((u : ZMod p)) := IsUnit.of_mul_eq_one _ hu
  have h1 := gaussSum_mulShift (chiC p) (ZMod.stdAddChar (N := p)) hU.unit
  rw [hU.unit_spec] at h1
  have h3 : chiC p (((q : ℕ) : ZMod p)) = ((legendreSym p q : ℤ) : ℂ) := by
    rw [show (((q : ℕ) : ZMod p)) = (((q : ℤ)) : ZMod p) by push_cast; ring, chiC_legendreSym]
  have hq0 : ((q : ℤ) : ZMod p) ≠ 0 := by
    intro h
    rw [show (((q : ℤ)) : ZMod p) = (((q : ℕ)) : ZMod p) by push_cast; ring] at h
    rw [h, mul_zero] at hu; exact zero_ne_one hu
  have h5 : ((legendreSym p q : ℤ) : ℂ) ^ 2 = 1 := by
    exact_mod_cast congrArg (fun z : ℤ => (z : ℂ)) (legendreSym.sq_one p hq0)
  have h2 : chiC p ((u : ZMod p)) * ((legendreSym p q : ℤ) : ℂ) = 1 := by
    rw [← h3, ← map_mul, hu, MulChar.map_one]
  have hL : chiC p ((u : ZMod p)) = ((legendreSym p q : ℤ) : ℂ) := by
    calc chiC p ((u : ZMod p)) = chiC p ((u : ZMod p)) * ((legendreSym p q : ℤ) : ℂ) ^ 2 := by
          rw [h5, mul_one]
      _ = (chiC p ((u : ZMod p)) * ((legendreSym p q : ℤ) : ℂ)) * ((legendreSym p q : ℤ) : ℂ) := by
          ring
      _ = ((legendreSym p q : ℤ) : ℂ) := by rw [h2, one_mul]
  rw [hL] at h1
  rw [show (∑ a : ZMod p, chiC p a * (ZMod.stdAddChar.mulShift ((u : ZMod p))) a)
      = gaussSum (chiC p) (ZMod.stdAddChar.mulShift ((u : ZMod p))) from rfl]
  calc gaussSum (chiC p) (ZMod.stdAddChar.mulShift ((u : ZMod p)))
      = ((legendreSym p q : ℤ) : ℂ) ^ 2
          * gaussSum (chiC p) (ZMod.stdAddChar.mulShift ((u : ZMod p))) := by rw [h5, one_mul]
    _ = ((legendreSym p q : ℤ) : ℂ) * gaussSumPrime p := by rw [gaussSumPrime, ← h1]; ring

lemma jacobiSym_val_eq_chiC (r M : ℕ) [Fact r.Prime] [NeZero M] (x : ZMod M) :
    (jacobiSym (x.val : ℤ) r : ℂ) = chiC r (ZMod.cast x) := by
  rw [← jacobiSym.legendreSym.to_jacobiSym]
  show ((legendreSym r (x.val : ℤ) : ℤ) : ℂ) = _
  rw [← chiC_legendreSym]
  congr 1
  push_cast [← ZMod.natCast_val x]
  ring

/-- **Twisted multiplicativity / CRT mechanism.**
`τ(pq) = (q/p)(p/q) · g_p · g_q`. -/
theorem tau_eq_legendre_mul_gaussSum [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q) :
    tau (p * q)
      = ((legendreSym p q : ℤ) : ℂ) * ((legendreSym q p : ℤ) : ℂ)
          * gaussSumPrime p * gaussSumPrime q := by
  have hp' : p.Prime := Fact.out
  have hq' : q.Prime := Fact.out
  haveI : NeZero p := ⟨hp'.pos.ne'⟩
  haveI : NeZero q := ⟨hq'.pos.ne'⟩
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp'.pos.ne' hq'.pos.ne'⟩
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp' hq').mpr hpq
  obtain ⟨v, u, huv0⟩ := Nat.isCoprime_iff_coprime.mpr hcop
  have huv : u * (q : ℤ) + v * (p : ℤ) = 1 := by linarith
  have hup : ((u : ℤ) : ZMod p) * ((q : ℕ) : ZMod p) = 1 := by
    have h := congrArg (fun z : ℤ => (z : ZMod p)) huv
    push_cast at h
    simpa [ZMod.natCast_self] using h
  have hvq : ((v : ℤ) : ZMod q) * ((p : ℕ) : ZMod q) = 1 := by
    have h := congrArg (fun z : ℤ => (z : ZMod q)) huv
    push_cast at h
    simpa [ZMod.natCast_self] using h
  have key : ∀ x : ZMod (p * q),
      (jacobiSym (x.val : ℤ) (p * q) : ℂ) * ZMod.stdAddChar x
        = (chiC p (ZMod.cast x) * (ZMod.stdAddChar.mulShift ((u : ZMod p))) (ZMod.cast x))
            * (chiC q (ZMod.cast x) * (ZMod.stdAddChar.mulShift ((v : ZMod q))) (ZMod.cast x)) := by
    intro x
    have hJ : (jacobiSym (x.val : ℤ) (p * q) : ℂ)
        = chiC p (ZMod.cast x) * chiC q (ZMod.cast x) := by
      rw [jacobiSym.mul_right]
      push_cast
      rw [jacobiSym_val_eq_chiC p _ x, jacobiSym_val_eq_chiC q _ x]
    have hx : (((x.val : ℤ)) : ZMod (p * q)) = x := by push_cast; exact ZMod.natCast_zmod_val x
    have hA := stdAddChar_split (p := p) (q := q) huv (x.val : ℤ)
    rw [hx] at hA
    have hu1 : ((u * (x.val : ℤ) : ℤ) : ZMod p) = (u : ZMod p) * ZMod.cast x := by
      push_cast [← ZMod.natCast_val x]; ring
    have hv1 : ((v * (x.val : ℤ) : ℤ) : ZMod q) = (v : ZMod q) * ZMod.cast x := by
      push_cast [← ZMod.natCast_val x]; ring
    rw [hu1, hv1] at hA
    rw [hJ, hA, AddChar.mulShift_apply, AddChar.mulShift_apply]
    ring
  have hprod : ∀ (F : ZMod p → ℂ) (G : ZMod q → ℂ),
      ∑ ab : ZMod p × ZMod q, F ab.1 * G ab.2 = (∑ a, F a) * (∑ b, G b) := by
    intro F G
    rw [Finset.sum_mul_sum, Fintype.sum_prod_type]
  have hbij : Function.Bijective
      (fun x : ZMod (p * q) => ((ZMod.cast x : ZMod p), (ZMod.cast x : ZMod q))) := by
    have h := (ZMod.chineseRemainder hcop).bijective
    convert h using 1
    funext x
    simp [ZMod.chineseRemainder, Prod.ext_iff, Prod.fst_zmod_cast, Prod.snd_zmod_cast]
  have hsum : ∑ x : ZMod (p * q),
      (chiC p (ZMod.cast x) * (ZMod.stdAddChar.mulShift ((u : ZMod p))) (ZMod.cast x))
        * (chiC q (ZMod.cast x) * (ZMod.stdAddChar.mulShift ((v : ZMod q))) (ZMod.cast x))
      = (∑ a : ZMod p, chiC p a * (ZMod.stdAddChar.mulShift ((u : ZMod p))) a)
        * (∑ b : ZMod q, chiC q b * (ZMod.stdAddChar.mulShift ((v : ZMod q))) b) := by
    rw [Fintype.sum_bijective _ hbij _
      (fun ab : ZMod p × ZMod q =>
        (chiC p ab.1 * (ZMod.stdAddChar.mulShift ((u : ZMod p))) ab.1)
          * (chiC q ab.2 * (ZMod.stdAddChar.mulShift ((v : ZMod q))) ab.2)) (fun x => rfl)]
    exact hprod (fun a => chiC p a * (ZMod.stdAddChar.mulShift ((u : ZMod p))) a)
      (fun b => chiC q b * (ZMod.stdAddChar.mulShift ((v : ZMod q))) b)
  rw [tau_eq_zmod_sum, Finset.sum_congr rfl (fun x _ => key x), hsum,
    gaussSum_mulShift_legendre (p := p) (q := q) hup,
    gaussSum_mulShift_legendre (p := q) (q := p) hvq]
  ring

/-! ### Unconditional phase collapse modulo `π` -/

/-- **Unconditional phase collapse.** For distinct odd primes `p, q` the square of the Jacobi
Gauss sum is `±N`, with the sign determined by `N mod 4` — hence the phase of `τ(N)` is
determined modulo `π` by `N mod 4` alone, and in particular cannot separate `p ≡ q ≡ 1 (4)`
from `p ≡ q ≡ 3 (4)`. -/
theorem tau_sq [Fact p.Prime] [Fact q.Prime] (hp : p ≠ 2) (hq : q ≠ 2) (hpq : p ≠ q) :
    tau (p * q) ^ 2 = if (p * q) % 4 = 1 then ((p * q : ℕ) : ℂ) else -((p * q : ℕ) : ℂ) := by
  have hL : ∀ (r s : ℕ), r.Prime → s.Prime → r ≠ s → ∀ [Fact r.Prime],
      ((legendreSym r s : ℤ) : ℂ) ^ 2 = 1 := by
    intro r s hr hs hrs _
    have h0 : ((s : ℤ) : ZMod r) ≠ 0 := by
      intro h
      rw [ZMod.intCast_zmod_eq_zero_iff_dvd] at h
      exact hrs ((Nat.prime_dvd_prime_iff_eq hr hs).mp (by exact_mod_cast h))
    exact_mod_cast congrArg (fun z : ℤ => (z : ℂ)) (legendreSym.sq_one r h0)
  have hsq : tau (p * q) ^ 2
      = ((legendreSym p q : ℤ) : ℂ) ^ 2 * ((legendreSym q p : ℤ) : ℂ) ^ 2
        * gaussSumPrime p ^ 2 * gaussSumPrime q ^ 2 := by
    rw [tau_eq_legendre_mul_gaussSum hpq]; ring
  rw [hsq, hL p q Fact.out Fact.out hpq, hL q p Fact.out Fact.out hpq.symm,
    gaussSumPrime_sq p hp, gaussSumPrime_sq q hq]
  have hpodd : p % 2 = 1 := Nat.odd_iff.mp ((Fact.out : p.Prime).odd_of_ne_two hp)
  have hqodd : q % 2 = 1 := Nat.odd_iff.mp ((Fact.out : q.Prime).odd_of_ne_two hq)
  have hp4 : p % 4 = 1 ∨ p % 4 = 3 := by omega
  have hq4 : q % 4 = 1 ∨ q % 4 = 3 := by omega
  have hmul : (p * q) % 4 = (p % 4) * (q % 4) % 4 := Nat.mul_mod p q 4
  rcases hp4 with h1 | h1 <;> rcases hq4 with h2 | h2 <;>
    rw [hmul, h1, h2] <;> norm_num [h1, h2]

/-- The `mod 4` bookkeeping behind the collapse: `N = pq ≡ 1 (4)` exactly when `p ≡ q (4)`. -/
theorem mul_mod_four_eq_one_iff (hp : p % 2 = 1) (hq : q % 2 = 1) :
    (p * q) % 4 = 1 ↔ p % 4 = q % 4 := by
  have hp4 : p % 4 = 1 ∨ p % 4 = 3 := by omega
  have hq4 : q % 4 = 1 ∨ q % 4 = 3 := by omega
  rw [Nat.mul_mod]
  rcases hp4 with h1 | h1 <;> rcases hq4 with h2 | h2 <;> rw [h1, h2] <;> norm_num

/-! ### Exact phase, given Gauss' sign theorem -/

/-- Gauss' sign determination of the prime quadratic Gauss sum (not in Mathlib), carried as an
explicit hypothesis. -/
def GaussSignTheorem : Prop :=
  ∀ (r : ℕ) [Fact r.Prime], r ≠ 2 →
    gaussSumPrime r = if r % 4 = 1 then (Real.sqrt r : ℂ) else I * (Real.sqrt r : ℂ)

/-- The reciprocity sign: `(q/p)(p/q) = -1` exactly in the `(3,3)` case. -/
theorem legendre_prod_eq [Fact p.Prime] [Fact q.Prime] (hp : p ≠ 2) (hq : q ≠ 2) (hpq : p ≠ q) :
    ((legendreSym p q : ℤ) : ℂ) * ((legendreSym q p : ℤ) : ℂ)
      = if p % 4 = 3 ∧ q % 4 = 3 then -1 else 1 := by
  have hrec := legendreSym.quadratic_reciprocity hp hq hpq
  have hpodd : p % 2 = 1 := Nat.odd_iff.mp ((Fact.out : p.Prime).odd_of_ne_two hp)
  have hqodd : q % 2 = 1 := Nat.odd_iff.mp ((Fact.out : q.Prime).odd_of_ne_two hq)
  have hE : ∀ n : ℕ, n % 4 = 1 → Even (n / 2) := by
    intro n h; rw [Nat.even_iff]; omega
  have hO : ∀ n : ℕ, n % 4 = 3 → Odd (n / 2) := by
    intro n h; rw [Nat.odd_iff]; omega
  have hcast : ((legendreSym p q : ℤ) : ℂ) * ((legendreSym q p : ℤ) : ℂ)
      = (((-1 : ℤ) ^ (p / 2 * (q / 2)) : ℤ) : ℂ) := by
    rw [← Int.cast_mul, mul_comm, hrec]
  have hp4 : p % 4 = 1 ∨ p % 4 = 3 := by omega
  have hq4 : q % 4 = 1 ∨ q % 4 = 3 := by omega
  rw [hcast]
  rcases hp4 with h1 | h1 <;> rcases hq4 with h2 | h2
  · rw [((hE p h1).mul_right _).neg_one_pow]; simp [h1, h2]
  · rw [((hE p h1).mul_right _).neg_one_pow]; simp [h1, h2]
  · rw [((hE q h2).mul_left _).neg_one_pow]; simp [h1, h2]
  · rw [((hO p h1).mul (hO q h2)).neg_one_pow]; simp [h1, h2]

/-- **Phase collapse (exact form).** Assuming Gauss' sign theorem for primes,
`τ(pq) = √N` when `p ≡ q (mod 4)` and `i√N` otherwise. -/
theorem tau_eq_of_gaussSign (hG : GaussSignTheorem) [Fact p.Prime] [Fact q.Prime]
    (hp : p ≠ 2) (hq : q ≠ 2) (hpq : p ≠ q) :
    tau (p * q) = if (p * q) % 4 = 1 then (Real.sqrt (p * q) : ℂ)
      else I * (Real.sqrt (p * q) : ℂ) := by
  have hpodd : p % 2 = 1 := Nat.odd_iff.mp ((Fact.out : p.Prime).odd_of_ne_two hp)
  have hqodd : q % 2 = 1 := Nat.odd_iff.mp ((Fact.out : q.Prime).odd_of_ne_two hq)
  have hsqrt : (Real.sqrt p : ℂ) * (Real.sqrt q : ℂ) = (Real.sqrt ((p : ℝ) * q) : ℂ) := by
    rw [Real.sqrt_mul (by positivity)]; push_cast; ring
  have hmul : (p * q) % 4 = (p % 4) * (q % 4) % 4 := Nat.mul_mod p q 4
  have hp4 : p % 4 = 1 ∨ p % 4 = 3 := by omega
  have hq4 : q % 4 = 1 ∨ q % 4 = 3 := by omega
  rw [tau_eq_legendre_mul_gaussSum hpq, mul_assoc, mul_assoc,
    show ((legendreSym p q : ℤ) : ℂ) * (((legendreSym q p : ℤ) : ℂ)
        * (gaussSumPrime p * gaussSumPrime q))
      = (((legendreSym p q : ℤ) : ℂ) * ((legendreSym q p : ℤ) : ℂ))
        * (gaussSumPrime p * gaussSumPrime q) by ring,
    legendre_prod_eq hp hq hpq, hG p hp, hG q hq]
  rcases hp4 with h1 | h1 <;> rcases hq4 with h2 | h2
  · rw [hmul, h1, h2]; norm_num [h1, h2]
  · rw [hmul, h1, h2]; norm_num [h1, h2]; ring
  · rw [hmul, h1, h2]; norm_num [h1, h2]; ring
  · rw [hmul, h1, h2]
    norm_num [h1, h2]
    ring_nf
    simp [Complex.I_sq]

/-- **Phase collapse, argument form.** `arg τ(N) = 0` if `N ≡ 1 (4)` and `π/2` otherwise. -/
theorem arg_tau_of_gaussSign (hG : GaussSignTheorem) [Fact p.Prime] [Fact q.Prime]
    (hp : p ≠ 2) (hq : q ≠ 2) (hpq : p ≠ q) :
    (tau (p * q)).arg = if (p * q) % 4 = 1 then 0 else Real.pi / 2 := by
  have hpos : (0 : ℝ) < (p : ℝ) * q := by
    have := (Fact.out : p.Prime).pos
    have := (Fact.out : q.Prime).pos
    positivity
  have hp0 : (0 : ℝ) < p := by exact_mod_cast (Fact.out : p.Prime).pos
  have hq0 : (0 : ℝ) < q := by exact_mod_cast (Fact.out : q.Prime).pos
  rw [tau_eq_of_gaussSign hG hp hq hpq]
  split
  · exact Complex.arg_ofReal_of_nonneg (Real.sqrt_nonneg _)
  · rw [Complex.arg_eq_pi_div_two_iff]
    refine ⟨by simp, ?_⟩
    simp only [Complex.mul_im, Complex.I_re, Complex.I_im, Complex.ofReal_re, Complex.ofReal_im,
      zero_mul, one_mul, zero_add, Real.sqrt_mul hp0.le]
    exact mul_pos (Real.sqrt_pos.mpr hp0) (Real.sqrt_pos.mpr hq0)

/-- **Structural orthogonality.** The `(1,1)` and `(3,3)` classes are indistinguishable by the
phase: both give argument `0`. -/
theorem arg_tau_collapse (hG : GaussSignTheorem) {p' q' : ℕ}
    [Fact p.Prime] [Fact q.Prime] [Fact p'.Prime] [Fact q'.Prime]
    (hp : p % 4 = 1) (hq : q % 4 = 1) (hp' : p' % 4 = 3) (hq' : q' % 4 = 3)
    (hpq : p ≠ q) (hpq' : p' ≠ q') :
    (tau (p * q)).arg = (tau (p' * q')).arg := by
  rw [arg_tau_of_gaussSign hG (by omega) (by omega) hpq,
    arg_tau_of_gaussSign hG (by omega) (by omega) hpq',
    if_pos (by rw [Nat.mul_mod, hp, hq]), if_pos (by rw [Nat.mul_mod, hp', hq'])]

/-! ### An unconditional instance: `τ(15) = i√15` -/

instance : Fact (Nat.Prime 5) := ⟨by norm_num⟩

/-- `e^{2πik/N}` in the form `exp (θ i)` with a real angle. -/
lemma stdAddChar_eq_exp_angle (N : ℕ) [NeZero N] (k : ℤ) :
    ZMod.stdAddChar ((k : ZMod N)) = Complex.exp (((2 * Real.pi * k / N : ℝ)) * I) := by
  rw [ZMod.stdAddChar_coe]
  congr 1
  push_cast
  ring

/-- The Gauss sum modulo `3`, computed from scratch: `g_3 = i√3`. -/
theorem gaussSumPrime_three : gaussSumPrime 3 = I * (Real.sqrt 3 : ℂ) := by
  have hsum : gaussSumPrime 3
      = ZMod.stdAddChar ((1 : ℤ) : ZMod 3) - ZMod.stdAddChar ((2 : ℤ) : ZMod 3) := by
    rw [gaussSumPrime, gaussSum, show (Finset.univ : Finset (ZMod 3)) = {0, 1, 2} from rfl,
      Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
    have h0 : chiC 3 (0 : ZMod 3) = 0 := MulChar.map_zero _
    have h1 : chiC 3 (1 : ZMod 3) = 1 := MulChar.map_one _
    have h2 : chiC 3 (2 : ZMod 3) = -1 := by
      rw [show (2 : ZMod 3) = ((2 : ℤ) : ZMod 3) by norm_num, chiC_legendreSym,
        jacobiSym.legendreSym.to_jacobiSym]
      norm_num
    rw [h0, h1, h2, show ((1 : ℤ) : ZMod 3) = (1 : ZMod 3) by norm_num,
      show ((2 : ℤ) : ZMod 3) = (2 : ZMod 3) by norm_num]
    ring
  rw [hsum, stdAddChar_eq_exp_angle, stdAddChar_eq_exp_angle,
    Complex.exp_mul_I, Complex.exp_mul_I]
  have c1 : Real.cos (2 * Real.pi * (1 : ℤ) / (3 : ℕ)) = -(1 / 2) := by
    push_cast
    rw [show 2 * Real.pi * 1 / 3 = Real.pi - Real.pi / 3 by ring, Real.cos_pi_sub,
      Real.cos_pi_div_three]
  have s1 : Real.sin (2 * Real.pi * (1 : ℤ) / (3 : ℕ)) = Real.sqrt 3 / 2 := by
    push_cast
    rw [show 2 * Real.pi * 1 / 3 = Real.pi - Real.pi / 3 by ring, Real.sin_pi_sub,
      Real.sin_pi_div_three]
  have c2 : Real.cos (2 * Real.pi * (2 : ℤ) / (3 : ℕ)) = -(1 / 2) := by
    push_cast
    rw [show 2 * Real.pi * 2 / 3 = Real.pi + Real.pi / 3 by ring]
    simp [Real.cos_add, Real.cos_pi_div_three, Real.sin_pi_div_three]
  have s2 : Real.sin (2 * Real.pi * (2 : ℤ) / (3 : ℕ)) = -(Real.sqrt 3 / 2) := by
    push_cast
    rw [show 2 * Real.pi * 2 / 3 = Real.pi + Real.pi / 3 by ring]
    simp [Real.sin_add, Real.cos_pi_div_three, Real.sin_pi_div_three]
  rw [← Complex.ofReal_cos, ← Complex.ofReal_sin, ← Complex.ofReal_cos, ← Complex.ofReal_sin,
    c1, s1, c2, s2]
  push_cast
  ring

/-- The Gauss sum modulo `5`, computed from scratch: `g_5 = √5`. -/
theorem gaussSumPrime_five : gaussSumPrime 5 = (Real.sqrt 5 : ℂ) := by
  have hsum : gaussSumPrime 5
      = ZMod.stdAddChar ((1 : ℤ) : ZMod 5) - ZMod.stdAddChar ((2 : ℤ) : ZMod 5)
        - ZMod.stdAddChar ((3 : ℤ) : ZMod 5) + ZMod.stdAddChar ((4 : ℤ) : ZMod 5) := by
    rw [gaussSumPrime, gaussSum, show (Finset.univ : Finset (ZMod 5)) = {0, 1, 2, 3, 4} from rfl,
      Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_insert (by decide),
      Finset.sum_insert (by decide), Finset.sum_singleton]
    have h0 : chiC 5 (0 : ZMod 5) = 0 := MulChar.map_zero _
    have h1 : chiC 5 (1 : ZMod 5) = 1 := MulChar.map_one _
    have h2 : chiC 5 (2 : ZMod 5) = -1 := by
      rw [show (2 : ZMod 5) = ((2 : ℤ) : ZMod 5) by norm_num, chiC_legendreSym,
        jacobiSym.legendreSym.to_jacobiSym]
      norm_num
    have h3 : chiC 5 (3 : ZMod 5) = -1 := by
      rw [show (3 : ZMod 5) = ((3 : ℤ) : ZMod 5) by norm_num, chiC_legendreSym,
        jacobiSym.legendreSym.to_jacobiSym]
      norm_num
    have h4 : chiC 5 (4 : ZMod 5) = 1 := by
      rw [show (4 : ZMod 5) = ((4 : ℤ) : ZMod 5) by norm_num, chiC_legendreSym,
        jacobiSym.legendreSym.to_jacobiSym]
      norm_num
    rw [h0, h1, h2, h3, h4, show ((1 : ℤ) : ZMod 5) = (1 : ZMod 5) by norm_num,
      show ((2 : ℤ) : ZMod 5) = (2 : ZMod 5) by norm_num,
      show ((3 : ℤ) : ZMod 5) = (3 : ZMod 5) by norm_num,
      show ((4 : ℤ) : ZMod 5) = (4 : ZMod 5) by norm_num]
    ring
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  have hc2 : Real.cos (2 * Real.pi / 5) = (Real.sqrt 5 - 1) / 4 := by
    rw [show 2 * Real.pi / 5 = 2 * (Real.pi / 5) by ring, Real.cos_two_mul, Real.cos_pi_div_five]
    nlinarith [h5]
  rw [hsum, stdAddChar_eq_exp_angle, stdAddChar_eq_exp_angle, stdAddChar_eq_exp_angle,
    stdAddChar_eq_exp_angle, Complex.exp_mul_I, Complex.exp_mul_I, Complex.exp_mul_I,
    Complex.exp_mul_I]
  have a1 : (2 * Real.pi * ((1 : ℤ) : ℝ) / ((5 : ℕ) : ℝ)) = 2 * Real.pi / 5 := by push_cast; ring
  have a2 : (2 * Real.pi * ((2 : ℤ) : ℝ) / ((5 : ℕ) : ℝ)) = Real.pi - Real.pi / 5 := by
    push_cast; ring
  have a3 : (2 * Real.pi * ((3 : ℤ) : ℝ) / ((5 : ℕ) : ℝ)) = Real.pi + Real.pi / 5 := by
    push_cast; ring
  have a4 : (2 * Real.pi * ((4 : ℤ) : ℝ) / ((5 : ℕ) : ℝ)) = 2 * Real.pi - 2 * Real.pi / 5 := by
    push_cast; ring
  rw [← Complex.ofReal_cos, ← Complex.ofReal_sin, ← Complex.ofReal_cos, ← Complex.ofReal_sin,
    ← Complex.ofReal_cos, ← Complex.ofReal_sin, ← Complex.ofReal_cos, ← Complex.ofReal_sin,
    a1, a2, a3, a4, Real.cos_pi_sub, Real.sin_pi_sub, Real.cos_two_pi_sub, Real.sin_two_pi_sub,
    Real.cos_add, Real.sin_add, Real.cos_pi, Real.sin_pi, hc2, Real.cos_pi_div_five]
  push_cast
  ring

/-- **Unconditional instance of the phase collapse.** `τ(15) = i√15`: here `p = 3`, `q = 5`
have different residues mod `4`, and indeed the phase is `π/2`. -/
theorem tau_fifteen : tau 15 = I * (Real.sqrt 15 : ℂ) := by
  have h : tau (3 * 5) = ((legendreSym 3 5 : ℤ) : ℂ) * ((legendreSym 5 3 : ℤ) : ℂ)
      * gaussSumPrime 3 * gaussSumPrime 5 := tau_eq_legendre_mul_gaussSum (by norm_num)
  have l1 : legendreSym 3 5 = -1 := by
    rw [jacobiSym.legendreSym.to_jacobiSym]; norm_num
  have l2 : legendreSym 5 3 = -1 := by
    rw [jacobiSym.legendreSym.to_jacobiSym]; norm_num
  have hs : (Real.sqrt 3 : ℝ) * Real.sqrt 5 = Real.sqrt 15 := by
    rw [← Real.sqrt_mul (by norm_num)]
    norm_num
  have hs' : ((Real.sqrt 3 : ℂ)) * (Real.sqrt 5 : ℂ) = (Real.sqrt 15 : ℂ) := by
    rw [← Complex.ofReal_mul, hs]
  have h15 : (15 : ℕ) = 3 * 5 := by norm_num
  rw [h15, h, l1, l2, gaussSumPrime_three, gaussSumPrime_five]
  push_cast
  linear_combination I * hs'

/-! ## Second cycle: arbitrary odd squarefree moduli

The semiprime statement above is a special case of a phenomenon that persists for every odd
squarefree modulus: the Jacobi symbol modulo `N` is a genuine quadratic character, its Gauss
sum is twisted-multiplicative, and the reciprocity twists always square away.  We build the
Jacobi character as a `MulChar`, prove twisted multiplicativity for arbitrary coprime moduli,
and deduce `τ(N)² = ±N` for all odd squarefree `N` by induction on the number of prime
factors.

-- !-- Lab Notes (cycle 2) -- !--
Hypothesis: the collapse is not special to two prime factors; for `N` with `k` prime factors
the phase should still be a function of `N mod 4` only, so the channel carries one bit no
matter how many factors `N` has.

Experiment: `tau_mul_coprime` (twisted multiplicativity for *arbitrary* coprime moduli, no
primality) plus induction on `N.minFac` gives `tau_sq_squarefree`.

Analysis: the reciprocity twists `J(n|m) J(m|n)` enter the square as `(±1)² = 1`, so the
unconditional square statement never needs reciprocity at all; reciprocity is only needed to
pin the *sign* of `τ` itself, i.e. to relate the twists to the `i`'s coming from the factors
that are `3 mod 4`.  The `k`-factor phase therefore still carries exactly one bit.
-/

/-- The Jacobi symbol only depends on the residue class of its numerator. -/
lemma jacobiSym_val_cast (m : ℕ) [NeZero m] (a : ℤ) :
    jacobiSym ((((a : ZMod m)).val : ℤ)) m = jacobiSym a m := by
  refine jacobiSym.mod_left' ?_
  rw [ZMod.val_intCast, Int.emod_emod_of_dvd _ dvd_rfl]

/-- The Jacobi symbol as a multiplicative character modulo `m`. -/
noncomputable def jacobiChar (m : ℕ) [NeZero m] : MulChar (ZMod m) ℂ where
  toFun x := (jacobiSym (x.val : ℤ) m : ℂ)
  map_one' := by
    have h1 : ((1 : ZMod m)) = (((1 : ℤ) : ZMod m)) := by push_cast; ring
    rw [h1, jacobiSym_val_cast, jacobiSym.one_left]
    norm_num
  map_mul' := by
    intro x y
    have h : (((x.val * y.val : ℤ) : ZMod m)) = x * y := by push_cast; simp
    rw [← h, jacobiSym_val_cast, jacobiSym.mul_left]
    push_cast
    ring
  map_nonunit' := by
    intro x hx
    have h0 : jacobiSym (x.val : ℤ) m = 0 := by
      rw [jacobiSym.eq_zero_iff_not_coprime]
      intro h
      exact hx (by
        rw [← ZMod.natCast_zmod_val x]
        exact (ZMod.isUnit_iff_coprime _ _).mpr (by exact_mod_cast h))
    rw [h0]
    norm_num

lemma jacobiChar_apply (m : ℕ) [NeZero m] (x : ZMod m) :
    jacobiChar m x = (jacobiSym (x.val : ℤ) m : ℂ) := rfl

lemma jacobiChar_intCast (m : ℕ) [NeZero m] (a : ℤ) :
    jacobiChar m (a : ZMod m) = (jacobiSym a m : ℂ) := by
  rw [jacobiChar_apply, jacobiSym_val_cast]

/-- `τ(m)` is the Gauss sum of the Jacobi character against the standard additive character. -/
lemma tau_eq_gaussSum (m : ℕ) [NeZero m] :
    tau m = gaussSum (jacobiChar m) ZMod.stdAddChar := by
  rw [tau_eq_zmod_sum, gaussSum]
  rfl

/-- Modulo a prime the Jacobi character is the quadratic character. -/
lemma jacobiChar_eq_chiC (r : ℕ) [Fact r.Prime] : jacobiChar r = chiC r := by
  have hpt : ∀ x : ZMod r, (jacobiSym (x.val : ℤ) r : ℂ) = chiC r x := by
    intro x
    have hx : (((x.val : ℤ)) : ZMod r) = x := by push_cast; exact ZMod.natCast_zmod_val x
    rw [← jacobiSym.legendreSym.to_jacobiSym, ← chiC_legendreSym, hx]
  ext a
  rw [jacobiChar_apply, hpt]

lemma tau_prime (r : ℕ) [Fact r.Prime] : tau r = gaussSumPrime r := by
  rw [tau_eq_gaussSum, jacobiChar_eq_chiC, gaussSumPrime]

/-- Twisting the additive character by a unit multiplies the Gauss sum by a Jacobi symbol. -/
lemma gaussSum_mulShift_jacobi (m n : ℕ) [NeZero m] {u : ℤ}
    (hu : ((u : ZMod m)) * ((n : ℕ) : ZMod m) = 1) :
    (∑ a : ZMod m, jacobiChar m a * (ZMod.stdAddChar.mulShift ((u : ZMod m))) a)
      = (jacobiSym n m : ℂ) * tau m := by
  have hU : IsUnit ((u : ZMod m)) := IsUnit.of_mul_eq_one _ hu
  have h1 := gaussSum_mulShift (jacobiChar m) (ZMod.stdAddChar (N := m)) hU.unit
  rw [hU.unit_spec] at h1
  have hun : jacobiSym (u * (n : ℤ)) m = 1 := by
    have hcast : (((u * (n : ℤ)) : ℤ) : ZMod m) = ((1 : ℤ) : ZMod m) := by push_cast at hu ⊢; simpa
    have := ZMod.intCast_eq_intCast_iff' (u * (n : ℤ)) 1 m |>.mp hcast
    rw [jacobiSym.mod_left' this, jacobiSym.one_left]
  have hgcd : Int.gcd (n : ℤ) (m : ℤ) = 1 := by
    have h2 : jacobiSym (u * (n : ℤ)) m = jacobiSym u m * jacobiSym n m :=
      jacobiSym.mul_left u n m
    by_contra hc
    have : jacobiSym (n : ℤ) m = 0 := jacobiSym.eq_zero_iff_not_coprime.mpr hc
    rw [this, mul_zero] at h2
    rw [hun] at h2
    exact one_ne_zero h2
  have h5 : ((jacobiSym n m : ℤ) : ℂ) ^ 2 = 1 := by
    exact_mod_cast congrArg (fun z : ℤ => (z : ℂ)) (jacobiSym.sq_one hgcd)
  have h2 : jacobiChar m ((u : ZMod m)) * ((jacobiSym n m : ℤ) : ℂ) = 1 := by
    rw [jacobiChar_intCast, ← Int.cast_mul, ← jacobiSym.mul_left, hun]
    norm_num
  have hL : jacobiChar m ((u : ZMod m)) = ((jacobiSym n m : ℤ) : ℂ) := by
    calc jacobiChar m ((u : ZMod m))
        = jacobiChar m ((u : ZMod m)) * ((jacobiSym n m : ℤ) : ℂ) ^ 2 := by rw [h5, mul_one]
      _ = (jacobiChar m ((u : ZMod m)) * ((jacobiSym n m : ℤ) : ℂ))
            * ((jacobiSym n m : ℤ) : ℂ) := by ring
      _ = ((jacobiSym n m : ℤ) : ℂ) := by rw [h2, one_mul]
  rw [hL] at h1
  rw [show (∑ a : ZMod m, jacobiChar m a * (ZMod.stdAddChar.mulShift ((u : ZMod m))) a)
      = gaussSum (jacobiChar m) (ZMod.stdAddChar.mulShift ((u : ZMod m))) from rfl]
  calc gaussSum (jacobiChar m) (ZMod.stdAddChar.mulShift ((u : ZMod m)))
      = ((jacobiSym n m : ℤ) : ℂ) ^ 2
          * gaussSum (jacobiChar m) (ZMod.stdAddChar.mulShift ((u : ZMod m))) := by
        rw [h5, one_mul]
    _ = ((jacobiSym n m : ℤ) : ℂ) * tau m := by rw [tau_eq_gaussSum, ← h1]; ring

/-- **Twisted multiplicativity of the Jacobi Gauss sum**, for arbitrary coprime moduli:
`τ(mn) = (n/m)(m/n) τ(m) τ(n)`.  No primality is needed. -/
theorem tau_mul_coprime (m n : ℕ) [NeZero m] [NeZero n] (hmn : Nat.Coprime m n) :
    tau (m * n) = (jacobiSym n m : ℂ) * (jacobiSym m n : ℂ) * tau m * tau n := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  obtain ⟨v, u, huv0⟩ := Nat.isCoprime_iff_coprime.mpr hmn
  have huv : u * (n : ℤ) + v * (m : ℤ) = 1 := by linarith
  have hup : ((u : ℤ) : ZMod m) * ((n : ℕ) : ZMod m) = 1 := by
    have h := congrArg (fun z : ℤ => (z : ZMod m)) huv
    push_cast at h
    simpa [ZMod.natCast_self] using h
  have hvq : ((v : ℤ) : ZMod n) * ((m : ℕ) : ZMod n) = 1 := by
    have h := congrArg (fun z : ℤ => (z : ZMod n)) huv
    push_cast at h
    simpa [ZMod.natCast_self] using h
  have hcast : ∀ (M : ℕ) [NeZero M] (x : ZMod (m * n)),
      jacobiSym (x.val : ℤ) M = jacobiSym (((ZMod.cast x : ZMod M)).val : ℤ) M := by
    intro M _ x
    rw [show (ZMod.cast x : ZMod M) = (((x.val : ℤ)) : ZMod M) by
        push_cast [← ZMod.natCast_val x]; ring, jacobiSym_val_cast]
  have key : ∀ x : ZMod (m * n),
      (jacobiSym (x.val : ℤ) (m * n) : ℂ) * ZMod.stdAddChar x
        = (jacobiChar m (ZMod.cast x) * (ZMod.stdAddChar.mulShift ((u : ZMod m))) (ZMod.cast x))
            * (jacobiChar n (ZMod.cast x)
                * (ZMod.stdAddChar.mulShift ((v : ZMod n))) (ZMod.cast x)) := by
    intro x
    have hJ : (jacobiSym (x.val : ℤ) (m * n) : ℂ)
        = jacobiChar m (ZMod.cast x) * jacobiChar n (ZMod.cast x) := by
      rw [jacobiSym.mul_right]
      push_cast
      rw [jacobiChar_apply, jacobiChar_apply, ← hcast m x, ← hcast n x]
    have hx : (((x.val : ℤ)) : ZMod (m * n)) = x := by push_cast; exact ZMod.natCast_zmod_val x
    have hA := stdAddChar_split (p := m) (q := n) huv (x.val : ℤ)
    rw [hx] at hA
    have hu1 : ((u * (x.val : ℤ) : ℤ) : ZMod m) = (u : ZMod m) * ZMod.cast x := by
      push_cast [← ZMod.natCast_val x]; ring
    have hv1 : ((v * (x.val : ℤ) : ℤ) : ZMod n) = (v : ZMod n) * ZMod.cast x := by
      push_cast [← ZMod.natCast_val x]; ring
    rw [hu1, hv1] at hA
    rw [hJ, hA, AddChar.mulShift_apply, AddChar.mulShift_apply]
    ring
  have hprod : ∀ (F : ZMod m → ℂ) (G : ZMod n → ℂ),
      ∑ ab : ZMod m × ZMod n, F ab.1 * G ab.2 = (∑ a, F a) * (∑ b, G b) := by
    intro F G
    rw [Finset.sum_mul_sum, Fintype.sum_prod_type]
  have hbij : Function.Bijective
      (fun x : ZMod (m * n) => ((ZMod.cast x : ZMod m), (ZMod.cast x : ZMod n))) := by
    have h := (ZMod.chineseRemainder hmn).bijective
    convert h using 1
    funext x
    simp [ZMod.chineseRemainder, Prod.ext_iff, Prod.fst_zmod_cast, Prod.snd_zmod_cast]
  have hsum : ∑ x : ZMod (m * n),
      (jacobiChar m (ZMod.cast x) * (ZMod.stdAddChar.mulShift ((u : ZMod m))) (ZMod.cast x))
        * (jacobiChar n (ZMod.cast x) * (ZMod.stdAddChar.mulShift ((v : ZMod n))) (ZMod.cast x))
      = (∑ a : ZMod m, jacobiChar m a * (ZMod.stdAddChar.mulShift ((u : ZMod m))) a)
        * (∑ b : ZMod n, jacobiChar n b * (ZMod.stdAddChar.mulShift ((v : ZMod n))) b) := by
    rw [Fintype.sum_bijective _ hbij _
      (fun ab : ZMod m × ZMod n =>
        (jacobiChar m ab.1 * (ZMod.stdAddChar.mulShift ((u : ZMod m))) ab.1)
          * (jacobiChar n ab.2 * (ZMod.stdAddChar.mulShift ((v : ZMod n))) ab.2)) (fun x => rfl)]
    exact hprod (fun a => jacobiChar m a * (ZMod.stdAddChar.mulShift ((u : ZMod m))) a)
      (fun b => jacobiChar n b * (ZMod.stdAddChar.mulShift ((v : ZMod n))) b)
  rw [tau_eq_zmod_sum, Finset.sum_congr rfl (fun x _ => key x), hsum,
    gaussSum_mulShift_jacobi m n hup, gaussSum_mulShift_jacobi n m hvq]
  ring

@[simp] lemma tau_one : tau 1 = 1 := by
  simp [tau]

/-- **Phase collapse for every odd squarefree modulus.** `τ(N)² = N` if `N ≡ 1 (mod 4)` and
`-N` otherwise: however many prime factors `N` has, the phase of `τ(N)` modulo `π` is a
function of `N mod 4` alone. -/
theorem tau_sq_squarefree : ∀ (N : ℕ), Odd N → Squarefree N →
    tau N ^ 2 = if N % 4 = 1 then (N : ℂ) else -(N : ℂ) := by
  intro N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    intro hodd hsq
    rcases eq_or_ne N 1 with rfl | hN1
    · norm_num
    have hNodd : N % 2 = 1 := Nat.odd_iff.mp hodd
    have hN0 : N ≠ 0 := by omega
    set p := N.minFac with hp
    have hpp : p.Prime := Nat.minFac_prime hN1
    haveI : Fact p.Prime := ⟨hpp⟩
    obtain ⟨m, hm⟩ : p ∣ N := Nat.minFac_dvd N
    have hm0 : m ≠ 0 := by rintro rfl; simp [hm] at hN0
    haveI : NeZero m := ⟨hm0⟩
    haveI : NeZero p := ⟨hpp.pos.ne'⟩
    have hmdvd : m ∣ N := ⟨p, by rw [hm]; ring⟩
    have hp2 : p ≠ 2 := by
      rintro h
      have h2 : 2 ∣ N := h ▸ Nat.minFac_dvd N
      obtain ⟨k, hk⟩ := h2
      omega
    have hpm : ¬ p ∣ m := by
      intro hdvd
      obtain ⟨t, ht⟩ := hdvd
      exact hpp.not_isUnit (hsq p (by rw [hm, ht]; exact ⟨t, by ring⟩))
    have hcop : Nat.Coprime p m := (Nat.Prime.coprime_iff_not_dvd hpp).mpr hpm
    have hmodd : Odd m := by
      rcases Nat.even_or_odd m with he | ho
      · exfalso
        obtain ⟨k, hk⟩ := he.two_dvd.trans hmdvd
        omega
      · exact ho
    have hmsq : Squarefree m := hsq.squarefree_of_dvd hmdvd
    have hmlt : m < N := by
      rw [hm]
      have h1 : 1 < p := hpp.one_lt
      have : 0 < m := Nat.pos_of_ne_zero hm0
      nlinarith
    have hJ1 : (jacobiSym m p : ℤ) ^ 2 = 1 :=
      jacobiSym.sq_one (by simpa [Int.gcd_natCast_natCast] using hcop.symm)
    have hJ2 : (jacobiSym p m : ℤ) ^ 2 = 1 :=
      jacobiSym.sq_one (by simpa [Int.gcd_natCast_natCast] using hcop)
    have hJ1' : ((jacobiSym m p : ℤ) : ℂ) ^ 2 = 1 := by exact_mod_cast congrArg (fun z : ℤ => (z : ℂ)) hJ1
    have hJ2' : ((jacobiSym p m : ℤ) : ℂ) ^ 2 = 1 := by exact_mod_cast congrArg (fun z : ℤ => (z : ℂ)) hJ2
    have hmul := tau_mul_coprime p m hcop
    have hsq2 : tau N ^ 2 = ((jacobiSym m p : ℤ) : ℂ) ^ 2 * ((jacobiSym p m : ℤ) : ℂ) ^ 2
        * tau p ^ 2 * tau m ^ 2 := by
      rw [hm, hmul]; ring
    rw [hsq2, hJ1', hJ2', tau_prime, gaussSumPrime_sq p hp2, ih m hmlt hmodd hmsq]
    have hpodd : p % 2 = 1 := Nat.odd_iff.mp (hpp.odd_of_ne_two hp2)
    have hmodd' : m % 2 = 1 := Nat.odd_iff.mp hmodd
    have hp4 : p % 4 = 1 ∨ p % 4 = 3 := by omega
    have hm4 : m % 4 = 1 ∨ m % 4 = 3 := by omega
    have hNmod : N % 4 = (p % 4) * (m % 4) % 4 := by rw [hm, Nat.mul_mod]
    have hNcast : (N : ℂ) = (p : ℂ) * (m : ℂ) := by rw [hm]; push_cast; ring
    rcases hp4 with h1 | h1 <;> rcases hm4 with h2 | h2 <;>
      rw [hNmod, h1, h2] <;> norm_num [hNcast]

/-! ## Third cycle: the exact phase for every odd squarefree modulus

Given Gauss' sign theorem for primes, the exact phase statement also survives an arbitrary
number of prime factors: `τ(N) ∈ {√N, i√N}` according to `N mod 4` for every odd squarefree
`N`.  The induction step is exactly the cancellation observed for semiprimes: each factor
`≡ 3 (mod 4)` contributes an `i`, and Jacobi reciprocity contributes a compensating `-1`
precisely when two such factors meet. -/

/-- **Exact phase collapse for all odd squarefree moduli** (given Gauss' sign theorem):
`τ(N) = √N` if `N ≡ 1 (mod 4)`, and `i√N` otherwise. -/
theorem tau_eq_of_gaussSign_squarefree (hG : GaussSignTheorem) :
    ∀ (N : ℕ), Odd N → Squarefree N →
      tau N = if N % 4 = 1 then (Real.sqrt N : ℂ) else I * (Real.sqrt N : ℂ) := by
  intro N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    intro hodd hsq
    rcases eq_or_ne N 1 with rfl | hN1
    · norm_num
    have hNodd : N % 2 = 1 := Nat.odd_iff.mp hodd
    have hN0 : N ≠ 0 := by omega
    set p := N.minFac with hp
    have hpp : p.Prime := Nat.minFac_prime hN1
    haveI : Fact p.Prime := ⟨hpp⟩
    obtain ⟨m, hm⟩ : p ∣ N := Nat.minFac_dvd N
    have hm0 : m ≠ 0 := by rintro rfl; simp [hm] at hN0
    haveI : NeZero m := ⟨hm0⟩
    haveI : NeZero p := ⟨hpp.pos.ne'⟩
    have hmdvd : m ∣ N := ⟨p, by rw [hm]; ring⟩
    have hp2 : p ≠ 2 := by
      rintro h
      obtain ⟨k, hk⟩ : 2 ∣ N := h ▸ Nat.minFac_dvd N
      omega
    have hpm : ¬ p ∣ m := by
      intro hdvd
      obtain ⟨t, ht⟩ := hdvd
      exact hpp.not_isUnit (hsq p (by rw [hm, ht]; exact ⟨t, by ring⟩))
    have hcop : Nat.Coprime p m := (Nat.Prime.coprime_iff_not_dvd hpp).mpr hpm
    have hmodd : Odd m := by
      rcases Nat.even_or_odd m with he | ho
      · exfalso
        obtain ⟨k, hk⟩ := he.two_dvd.trans hmdvd
        omega
      · exact ho
    have hmsq : Squarefree m := hsq.squarefree_of_dvd hmdvd
    have hmlt : m < N := by
      rw [hm]
      have h1 : 1 < p := hpp.one_lt
      have : 0 < m := Nat.pos_of_ne_zero hm0
      nlinarith
    have hpodd : p % 2 = 1 := Nat.odd_iff.mp (hpp.odd_of_ne_two hp2)
    have hmodd' : m % 2 = 1 := Nat.odd_iff.mp hmodd
    -- the reciprocity twist
    have hJ2 : (jacobiSym p m : ℤ) ^ 2 = 1 :=
      jacobiSym.sq_one (by simpa [Int.gcd_natCast_natCast] using hcop)
    have hrec : (jacobiSym m p : ℤ) * (jacobiSym p m : ℤ) = (-1) ^ (m / 2 * (p / 2)) := by
      rw [jacobiSym.quadratic_reciprocity hmodd (hpp.odd_of_ne_two hp2)]
      rw [mul_assoc, show (jacobiSym p m : ℤ) * (jacobiSym p m : ℤ) = (jacobiSym p m : ℤ) ^ 2 by
        ring, hJ2, mul_one]
    have hE : ∀ n : ℕ, n % 4 = 1 → Even (n / 2) := by
      intro n h; rw [Nat.even_iff]; omega
    have hO : ∀ n : ℕ, n % 4 = 3 → Odd (n / 2) := by
      intro n h; rw [Nat.odd_iff]; omega
    have hmul := tau_mul_coprime p m hcop
    have hprod : tau N = ((jacobiSym m p * jacobiSym p m : ℤ) : ℂ) * (tau p * tau m) := by
      rw [hm, hmul]; push_cast; ring
    have hp0 : (0 : ℝ) < p := by exact_mod_cast hpp.pos
    have hm0' : (0 : ℝ) < m := by exact_mod_cast Nat.pos_of_ne_zero hm0
    have hsqrt : (Real.sqrt p : ℂ) * (Real.sqrt m : ℂ) = (Real.sqrt ((p : ℝ) * m) : ℂ) := by
      rw [Real.sqrt_mul hp0.le]; push_cast; ring
    have hNcast : ((N : ℝ)) = (p : ℝ) * (m : ℝ) := by rw [hm]; push_cast; ring
    have hNmod : N % 4 = (p % 4) * (m % 4) % 4 := by rw [hm, Nat.mul_mod]
    have hp4 : p % 4 = 1 ∨ p % 4 = 3 := by omega
    have hm4 : m % 4 = 1 ∨ m % 4 = 3 := by omega
    rw [hprod, hrec, tau_prime p, hG p hp2, ih m hmlt hmodd hmsq, hNcast, ← hsqrt]
    rcases hp4 with h1 | h1 <;> rcases hm4 with h2 | h2
    · rw [((hE m h2).mul_right _).neg_one_pow, hNmod, h1, h2]
      norm_num [h1, h2]
    · rw [((hE p h1).mul_left _).neg_one_pow, hNmod, h1, h2]
      norm_num [h1, h2]
      ring
    · rw [((hE m h2).mul_right _).neg_one_pow, hNmod, h1, h2]
      norm_num [h1, h2]
      ring
    · rw [((hO m h2).mul (hO p h1)).neg_one_pow, hNmod, h1, h2]
      norm_num [h1, h2]
      ring_nf
      simp [Complex.I_sq]

/-- **The phase is a function of `N mod 4` alone** (given Gauss' sign theorem): two odd
squarefree moduli in the same class mod `4` have Jacobi Gauss sums with the same argument,
no matter how their prime factors are distributed mod `4`. -/
theorem arg_tau_eq_of_mod_four (hG : GaussSignTheorem) {N N' : ℕ}
    (hN : Odd N) (hNsq : Squarefree N) (hN' : Odd N') (hN'sq : Squarefree N')
    (h : N % 4 = N' % 4) :
    (tau N).arg = (tau N').arg := by
  have hpos : ∀ M : ℕ, Odd M → Squarefree M → (0 : ℝ) < M := by
    intro M hM _
    have : M % 2 = 1 := Nat.odd_iff.mp hM
    have : M ≠ 0 := by omega
    exact_mod_cast Nat.pos_of_ne_zero this
  have harg : ∀ M : ℕ, Odd M → Squarefree M →
      (tau M).arg = if M % 4 = 1 then 0 else Real.pi / 2 := by
    intro M hM hMsq
    rw [tau_eq_of_gaussSign_squarefree hG M hM hMsq]
    split
    · exact Complex.arg_ofReal_of_nonneg (Real.sqrt_nonneg _)
    · rw [Complex.arg_eq_pi_div_two_iff]
      refine ⟨by simp, ?_⟩
      simpa using Real.sqrt_pos.mpr (hpos M hM hMsq)
  rw [harg N hN hNsq, harg N' hN' hN'sq, h]

/-! ## Consequences: modulus and the one-bit channel -/

/-- **Unconditional modulus.** `|τ(N)| = √N` for every odd squarefree `N`.  Together with
`tau_sq_squarefree` this says the whole content of `τ(N)` beyond a sign is `N mod 4`. -/
theorem norm_tau_squarefree (N : ℕ) (hodd : Odd N) (hsq : Squarefree N) :
    ‖tau N‖ = Real.sqrt N := by
  have h2 : ‖tau N‖ ^ 2 = (N : ℝ) := by
    rw [← Complex.norm_pow, tau_sq_squarefree N hodd hsq]
    split <;> simp
  rw [← h2, Real.sqrt_sq (norm_nonneg _)]

/-- **The one-bit channel, unconditionally.** For odd squarefree moduli in the same class mod
`4`, the normalised squares agree: `τ(N)²/N = τ(N')²/N'`.  No information about the prime
factorisation survives in this invariant. -/
theorem tau_sq_div_eq_of_mod_four {N N' : ℕ} (hN : Odd N) (hNsq : Squarefree N)
    (hN' : Odd N') (hN'sq : Squarefree N') (h : N % 4 = N' % 4) :
    tau N ^ 2 / (N : ℂ) = tau N' ^ 2 / (N' : ℂ) := by
  have hN0 : (N : ℂ) ≠ 0 := by
    have : N % 2 = 1 := Nat.odd_iff.mp hN
    have hne : N ≠ 0 := by omega
    exact_mod_cast Nat.cast_ne_zero.mpr hne
  have hN'0 : (N' : ℂ) ≠ 0 := by
    have : N' % 2 = 1 := Nat.odd_iff.mp hN'
    have hne : N' ≠ 0 := by omega
    exact_mod_cast Nat.cast_ne_zero.mpr hne
  rw [tau_sq_squarefree N hN hNsq, tau_sq_squarefree N' hN' hN'sq, h]
  split
  · rw [div_self hN0, div_self hN'0]
  · rw [neg_div, neg_div, div_self hN0, div_self hN'0]

/-! ## Fourth cycle: the `(3,3)` case, unconditionally — `τ(21) = √21`

-- !-- Lab Notes (cycle 4) -- !--
Hypothesis: the striking half of the collapse is the `(3 mod 4, 3 mod 4)` case, where the two
prime Gauss sums each contribute a factor `i` (total `-1`) and the reciprocity twist
`(q|p)(p|q) = -1` cancels it exactly, leaving a real positive value.  The cycle-1 witness
`τ(15) = i√15` only tests the mixed case, so it never exercises this cancellation.

Experiment: the smallest `(3,3)` semiprime is `21 = 3 · 7`, so we compute `g_7` from scratch.
The six nontrivial `7`-th roots of unity pair up (`k ↔ 7 - k`) so that the real part of `g_7`
cancels identically, leaving
  `g_7 = i · 2 (sin 2π/7 + sin 4π/7 - sin 6π/7)`.
The bracket is positive: folding `sin 4π/7 = sin 3π/7` and `sin 6π/7 = sin π/7`, positivity
reduces to `sin π/7 < sin 3π/7`, i.e. to strict monotonicity of `sin` on `[0, π/2]`.  Its
square is `7` by `gaussSumPrime_sq`, hence `g_7 = i√7` with no appeal to Gauss' sign theorem.

Analysis: `(7|3)(3|7) = 1 · (-1) = -1` and `g_3 g_7 = (i√3)(i√7) = -√21`, so
`τ(21) = (-1)(-√21) = √21`, real and positive, exactly as the collapse predicts for
`21 ≡ 1 (mod 4)`.  This is an unconditional witness of the cancellation mechanism itself:
the two `i`'s and the reciprocity sign annihilate each other.
-/

instance : Fact (Nat.Prime 7) := ⟨by norm_num⟩

/-- The imaginary part of `g_7`, up to the factor `i`, is positive.  This is the only place
where an inequality (rather than an algebraic identity) is needed. -/
lemma sin_seven_bracket_pos :
    0 < 2 * (Real.sin (2 * Real.pi / 7) + Real.sin (4 * Real.pi / 7)
      - Real.sin (6 * Real.pi / 7)) := by
  have hpi := Real.pi_pos
  have h1 : 0 < Real.sin (2 * Real.pi / 7) :=
    Real.sin_pos_of_pos_of_lt_pi (by linarith) (by linarith)
  have h6 : Real.sin (6 * Real.pi / 7) = Real.sin (Real.pi / 7) := by
    rw [show 6 * Real.pi / 7 = Real.pi - Real.pi / 7 by ring, Real.sin_pi_sub]
  have h4 : Real.sin (4 * Real.pi / 7) = Real.sin (3 * Real.pi / 7) := by
    rw [show 4 * Real.pi / 7 = Real.pi - 3 * Real.pi / 7 by ring, Real.sin_pi_sub]
  have hlt : Real.sin (Real.pi / 7) < Real.sin (3 * Real.pi / 7) :=
    Real.sin_lt_sin_of_lt_of_le_pi_div_two (by linarith) (by linarith) (by linarith)
  rw [h6, h4]
  linarith

/-- The real part of the Gauss sum modulo `7` cancels: `g_7 = i · 2(sin 2π/7 + sin 4π/7 −
sin 6π/7)`. -/
lemma gaussSumPrime_seven_eq_I_mul :
    gaussSumPrime 7 = I * ((2 * (Real.sin (2 * Real.pi / 7) + Real.sin (4 * Real.pi / 7)
      - Real.sin (6 * Real.pi / 7)) : ℝ) : ℂ) := by
  have hsum : gaussSumPrime 7
      = ZMod.stdAddChar ((1 : ℤ) : ZMod 7) + ZMod.stdAddChar ((2 : ℤ) : ZMod 7)
        - ZMod.stdAddChar ((3 : ℤ) : ZMod 7) + ZMod.stdAddChar ((4 : ℤ) : ZMod 7)
        - ZMod.stdAddChar ((5 : ℤ) : ZMod 7) - ZMod.stdAddChar ((6 : ℤ) : ZMod 7) := by
    rw [gaussSumPrime, gaussSum,
      show (Finset.univ : Finset (ZMod 7)) = {0, 1, 2, 3, 4, 5, 6} from rfl,
      Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_insert (by decide),
      Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_insert (by decide),
      Finset.sum_singleton]
    have h0 : chiC 7 (0 : ZMod 7) = 0 := MulChar.map_zero _
    have h1 : chiC 7 (1 : ZMod 7) = 1 := MulChar.map_one _
    have h2 : chiC 7 (2 : ZMod 7) = 1 := by
      rw [show (2 : ZMod 7) = ((2 : ℤ) : ZMod 7) by norm_num, chiC_legendreSym,
        jacobiSym.legendreSym.to_jacobiSym]
      norm_num
    have h3 : chiC 7 (3 : ZMod 7) = -1 := by
      rw [show (3 : ZMod 7) = ((3 : ℤ) : ZMod 7) by norm_num, chiC_legendreSym,
        jacobiSym.legendreSym.to_jacobiSym]
      norm_num
    have h4 : chiC 7 (4 : ZMod 7) = 1 := by
      rw [show (4 : ZMod 7) = ((4 : ℤ) : ZMod 7) by norm_num, chiC_legendreSym,
        jacobiSym.legendreSym.to_jacobiSym]
      norm_num
    have h5 : chiC 7 (5 : ZMod 7) = -1 := by
      rw [show (5 : ZMod 7) = ((5 : ℤ) : ZMod 7) by norm_num, chiC_legendreSym,
        jacobiSym.legendreSym.to_jacobiSym]
      norm_num
    have h6 : chiC 7 (6 : ZMod 7) = -1 := by
      rw [show (6 : ZMod 7) = ((6 : ℤ) : ZMod 7) by norm_num, chiC_legendreSym,
        jacobiSym.legendreSym.to_jacobiSym]
      norm_num
    rw [h0, h1, h2, h3, h4, h5, h6,
      show ((1 : ℤ) : ZMod 7) = (1 : ZMod 7) by norm_num,
      show ((2 : ℤ) : ZMod 7) = (2 : ZMod 7) by norm_num,
      show ((3 : ℤ) : ZMod 7) = (3 : ZMod 7) by norm_num,
      show ((4 : ℤ) : ZMod 7) = (4 : ZMod 7) by norm_num,
      show ((5 : ℤ) : ZMod 7) = (5 : ZMod 7) by norm_num,
      show ((6 : ℤ) : ZMod 7) = (6 : ZMod 7) by norm_num]
    ring
  rw [hsum, stdAddChar_eq_exp_angle, stdAddChar_eq_exp_angle, stdAddChar_eq_exp_angle,
    stdAddChar_eq_exp_angle, stdAddChar_eq_exp_angle, stdAddChar_eq_exp_angle,
    Complex.exp_mul_I, Complex.exp_mul_I, Complex.exp_mul_I, Complex.exp_mul_I,
    Complex.exp_mul_I, Complex.exp_mul_I]
  have a1 : (2 * Real.pi * ((1 : ℤ) : ℝ) / ((7 : ℕ) : ℝ)) = 2 * Real.pi / 7 := by push_cast; ring
  have a2 : (2 * Real.pi * ((2 : ℤ) : ℝ) / ((7 : ℕ) : ℝ)) = 4 * Real.pi / 7 := by push_cast; ring
  have a3 : (2 * Real.pi * ((3 : ℤ) : ℝ) / ((7 : ℕ) : ℝ)) = 6 * Real.pi / 7 := by push_cast; ring
  have a4 : (2 * Real.pi * ((4 : ℤ) : ℝ) / ((7 : ℕ) : ℝ)) = 2 * Real.pi - 6 * Real.pi / 7 := by
    push_cast; ring
  have a5 : (2 * Real.pi * ((5 : ℤ) : ℝ) / ((7 : ℕ) : ℝ)) = 2 * Real.pi - 4 * Real.pi / 7 := by
    push_cast; ring
  have a6 : (2 * Real.pi * ((6 : ℤ) : ℝ) / ((7 : ℕ) : ℝ)) = 2 * Real.pi - 2 * Real.pi / 7 := by
    push_cast; ring
  rw [← Complex.ofReal_cos, ← Complex.ofReal_sin, ← Complex.ofReal_cos, ← Complex.ofReal_sin,
    ← Complex.ofReal_cos, ← Complex.ofReal_sin, ← Complex.ofReal_cos, ← Complex.ofReal_sin,
    ← Complex.ofReal_cos, ← Complex.ofReal_sin, ← Complex.ofReal_cos, ← Complex.ofReal_sin,
    a1, a2, a3, a4, a5, a6]
  simp only [Real.cos_two_pi_sub, Real.sin_two_pi_sub]
  push_cast
  ring

/-- The Gauss sum modulo `7`, computed from scratch: `g_7 = i√7`. -/
theorem gaussSumPrime_seven : gaussSumPrime 7 = I * (Real.sqrt 7 : ℂ) := by
  obtain ⟨S, hSpos, hg⟩ : ∃ S : ℝ, 0 < S ∧ gaussSumPrime 7 = I * (S : ℂ) :=
    ⟨_, sin_seven_bracket_pos, gaussSumPrime_seven_eq_I_mul⟩
  have hsq : gaussSumPrime 7 ^ 2 = -(7 : ℂ) := by
    rw [gaussSumPrime_sq 7 (by norm_num)]
    norm_num
  rw [hg] at hsq
  have hS2 : S ^ 2 = 7 := by
    have hc : ((S ^ 2 : ℝ) : ℂ) = ((7 : ℝ) : ℂ) := by
      push_cast
      linear_combination -hsq + (S : ℂ) ^ 2 * Complex.I_sq
    exact_mod_cast hc
  have hsqrt : Real.sqrt 7 = S := by
    rw [← hS2, Real.sqrt_sq hSpos.le]
  rw [hg, hsqrt]

/-- **The `(3,3)` case, unconditionally.** `τ(21) = √21`: both `3` and `7` are `3 mod 4`, each
prime Gauss sum contributes a factor `i`, and the quadratic-reciprocity twist `-1` cancels the
resulting `-1` exactly.  The phase is `0`, as predicted by `21 ≡ 1 (mod 4)`. -/
theorem tau_twentyone : tau 21 = (Real.sqrt 21 : ℂ) := by
  have h : tau (3 * 7) = ((legendreSym 3 7 : ℤ) : ℂ) * ((legendreSym 7 3 : ℤ) : ℂ)
      * gaussSumPrime 3 * gaussSumPrime 7 := tau_eq_legendre_mul_gaussSum (by norm_num)
  have l1 : legendreSym 3 7 = 1 := by
    rw [jacobiSym.legendreSym.to_jacobiSym]; norm_num
  have l2 : legendreSym 7 3 = -1 := by
    rw [jacobiSym.legendreSym.to_jacobiSym]; norm_num
  have hs : (Real.sqrt 3 : ℝ) * Real.sqrt 7 = Real.sqrt 21 := by
    rw [← Real.sqrt_mul (by norm_num)]
    norm_num
  have hs' : ((Real.sqrt 3 : ℂ)) * (Real.sqrt 7 : ℂ) = (Real.sqrt 21 : ℂ) := by
    rw [← Complex.ofReal_mul, hs]
  have h21 : (21 : ℕ) = 3 * 7 := by norm_num
  rw [h21, h, l1, l2, gaussSumPrime_three, gaussSumPrime_seven]
  push_cast
  linear_combination hs' - ((Real.sqrt 3 : ℂ) * (Real.sqrt 7 : ℂ)) * Complex.I_sq

/-! ## Fifth cycle: how much of the collapse is unconditional?

-- !-- Lab Notes (cycle 5) -- !--
Critique: `tau_eq_of_gaussSign_squarefree` gives the exact phase but drags along the
hypothesis `GaussSignTheorem`.  How much survives with the hypothesis deleted?

Experiment: factor `τ(N)² ∓ N` in `ℂ`.  From the unconditional `tau_sq_squarefree` alone one
gets a *dichotomy*: `τ(N) = ±√N` when `N ≡ 1 (mod 4)` and `τ(N) = ±i√N` when `N ≡ 3 (mod 4)`.

Analysis: so the entire dependence of the phase on the factorisation of `N` is, unconditionally,
at most a global sign; the *line* `ℝ·τ(N)` in `ℂ` is already a function of `N mod 4`.  Gauss'
sign theorem is needed only to remove the residual `±`, and that residual is itself independent
of the factorisation (it is `+` always).  This isolates exactly what is and is not conditional.
-/

/-- **Unconditional dichotomy.**  For every odd squarefree `N`, without any appeal to Gauss'
sign theorem, `τ(N)` is one of `±√N` (when `N ≡ 1 mod 4`) or one of `±i√N` (when
`N ≡ 3 mod 4`).  In particular the *line* `ℝ·τ(N) ⊆ ℂ` depends only on `N mod 4`, so no
information about the prime factorisation of `N` is visible in it. -/
theorem tau_eq_or_neg_squarefree (N : ℕ) (hodd : Odd N) (hsq : Squarefree N) :
    (N % 4 = 1 ∧ (tau N = (Real.sqrt N : ℂ) ∨ tau N = -(Real.sqrt N : ℂ)))
      ∨ (N % 4 = 3 ∧ (tau N = I * (Real.sqrt N : ℂ) ∨ tau N = -(I * (Real.sqrt N : ℂ)))) := by
  have hN2 : N % 2 = 1 := Nat.odd_iff.mp hodd
  have hc : ((Real.sqrt N : ℝ) : ℂ) ^ 2 = (N : ℂ) := by
    rw [← Complex.ofReal_pow, Real.sq_sqrt (Nat.cast_nonneg N)]
    simp
  have hts := tau_sq_squarefree N hodd hsq
  rcases (show N % 4 = 1 ∨ N % 4 = 3 by omega) with h1 | h3
  · rw [if_pos h1] at hts
    refine Or.inl ⟨h1, ?_⟩
    have hfac : (tau N - (Real.sqrt N : ℂ)) * (tau N + (Real.sqrt N : ℂ)) = 0 := by
      linear_combination hts - hc
    rcases mul_eq_zero.mp hfac with h | h
    · exact Or.inl (by linear_combination h)
    · exact Or.inr (by linear_combination h)
  · rw [if_neg (by omega)] at hts
    refine Or.inr ⟨h3, ?_⟩
    have hfac : (tau N - I * (Real.sqrt N : ℂ)) * (tau N + I * (Real.sqrt N : ℂ)) = 0 := by
      linear_combination hts + hc - ((Real.sqrt N : ℝ) : ℂ) ^ 2 * Complex.I_sq
    rcases mul_eq_zero.mp hfac with h | h
    · exact Or.inl (by linear_combination h)
    · exact Or.inr (by linear_combination h)

end JacobiGaussPhase