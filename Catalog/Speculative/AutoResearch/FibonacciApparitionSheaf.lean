import Mathlib

/-!
# Fibonacci Apparition as a Local-to-Global Sheaf

Domain: Number Theory / Shared (local-to-global, sheaf-theoretic framing).

The **rank of apparition** (Fibonacci entry point) of a modulus `m` is the least
positive index `k` with `m ∣ F k`.  The catalog already develops this object in several
parallel threads (`RankOfApparition`, `FibonacciEntryPoints`, `FibonacciApparitionLattice`,
`FibApparitionExistence`, `StrongDivisibilitySequences`), all turning on the *law of
apparition* `m ∣ F n ↔ rank m ∣ n`.

This file is **self-contained against Mathlib** (the catalog's import graph spans
non-default build targets) and contributes the *local-to-global / sheaf* layer that the
catalog threads were missing:

* `fib_dvd_iff_fibRank_dvd` — the law of apparition (foundational core, restated here so the
  file is dependency-free; cf. `FibonacciApparition.fib_dvd_iff_fibEntry_dvd`).
* `isPrimitive_iff_fibRank_eq` — **new bridge to Carmichael's primitive-divisor theorem**:
  a prime is a *primitive divisor* of `F n` *iff* its rank equals `n`.  This recasts the
  global object `Shared.CarmichaelProof.fib_carmichael_composite`
  (and `bridge_lemma`) as a purely *local* (stalk-level) statement about the rank.
* `fibRank_mul_coprime` — **CRT gluing of stalks**: over coprime moduli the rank is the
  `lcm` of the local ranks; this is the binary local-to-global gluing law.
* `fibRank_eq_factorization_lcm` — **the full local-to-global reconstruction**: the global
  rank of any modulus is the `lcm` of its prime-power *stalk* ranks.  This strictly
  generalizes the binary gluing law from two moduli to the whole prime-power decomposition,
  realizing the rank as the global section glued from local data at each prime.

-- !-- Lab Notebook -- !--
  Hypothesis: The Fibonacci entry point `m ↦ rank m` behaves like a sheaf over the
    divisibility site of moduli: divisibility data `{n | m ∣ F n}` is local at each prime,
    and global rank is glued (via `lcm`) from prime-power stalk ranks.
  Result: Confirmed.  All four results above proved with zero `sorry`.  The keystone is the
    law of apparition, proved from scratch via the *invertible Fibonacci shift permutation*
    `(a,b) ↦ (b, a+b)` on `(ZMod m)²`: as a permutation of a finite type it has finite
    order, forcing the orbit of `(0,1)` to return — i.e. some positive `F k ≡ 0`.
  Insight: Pure periodicity of `F mod m` is *not* an analytic fact but a consequence of the
    shift being a bijection (reversibility `F(k-1) = F(k+1) - F(k)`); group order does the
    rest.  Once the law of apparition holds, every global divisibility question collapses to
    divisibility of indices, where `lcm`/`gcd` lattice identities are elementary.  The
    primitive-divisor (Carmichael) condition is then *literally* the statement that the rank
    is maximal (`= n`), i.e. that the stalk first sees `m` exactly at index `n`.
  Failure analysis: An early attempt defined `fibRank` with `[NeZero m]`; this blocked the
    factorization reconstruction because `fun p => fibRank (p ^ e p)` must be total over `ℕ`.
    Switching to a `sInf`-based total definition (junk value `0` at `m = 0`) removed the
    instance clutter and unlocked the prime-power gluing.
-- !-- Lab Notebook -- !--
-/

namespace FibApparitionSheaf

open scoped Classical

/-! ## §1. Existence of the rank via the invertible Fibonacci shift -/

-- !-- The Fibonacci shift `(a,b) ↦ (b, a+b)` on `(ZMod m)²`, with inverse `(a,b) ↦ (b-a,a)`;
-- its reversibility is exactly why apparition (a return to `(0,1)`) must occur. -- !--
def fibStep (m : ℕ) : ZMod m × ZMod m ≃ ZMod m × ZMod m where
  toFun p := (p.2, p.1 + p.2)
  invFun p := (p.2 - p.1, p.1)
  left_inv := by intro p; simp
  right_inv := by intro p; simp [add_comm]

-- !-- Iterating the shift from `(0,1)` yields consecutive Fibonacci pairs `(F k, F (k+1))`;
-- induction on `k` using `F (k+2) = F k + F (k+1)`. -- !--
lemma fibStep_iterate (m : ℕ) (k : ℕ) :
    (fibStep m)^[k] (0, 1) = ((Nat.fib k : ZMod m), (Nat.fib (k + 1) : ZMod m)) := by
  induction k with
  | zero => simp [fibStep]
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih]
    simp only [fibStep, Equiv.coe_fn_mk]
    refine Prod.ext rfl ?_
    push_cast [Nat.fib_add_two]; ring

-- !-- The shift is a permutation of the finite type `(ZMod m)²`, so it has finite positive
-- order `p`; iterating `p` times returns `(0,1) ↦ (0,1)`, giving `m ∣ F p` with `p > 0`. -- !--
lemma exists_pos_dvd_fib (m : ℕ) (hm : 0 < m) : ∃ k, 0 < k ∧ m ∣ Nat.fib k := by
  haveI : NeZero m := ⟨hm.ne'⟩
  let e : Equiv.Perm (ZMod m × ZMod m) := fibStep m
  have hp : 0 < orderOf e := orderOf_pos e
  refine ⟨orderOf e, hp, ?_⟩
  have h1 : e ^ orderOf e = 1 := pow_orderOf_eq_one e
  have h2 : (e ^ orderOf e) (0, 1)
      = ((Nat.fib (orderOf e) : ZMod m), (Nat.fib (orderOf e + 1) : ZMod m)) := by
    rw [Equiv.Perm.coe_pow]; exact fibStep_iterate m (orderOf e)
  rw [h1] at h2
  simp only [Equiv.Perm.coe_one, id_eq] at h2
  have hz : ((Nat.fib (orderOf e) : ZMod m)) = 0 := by
    have := (Prod.ext_iff.mp h2.symm).1
    simpa using this
  exact (ZMod.natCast_eq_zero_iff _ _).mp hz

/-! ## §2. The rank of apparition and the law of apparition -/

/-- The **rank of apparition** of `m`: the least positive index `k` with `m ∣ F k`
(and `0` for the degenerate modulus `m = 0`, which never appears below). -/
noncomputable def fibRank (m : ℕ) : ℕ := sInf {k | 0 < k ∧ m ∣ Nat.fib k}

lemma fibRank_mem (m : ℕ) (hm : 0 < m) : 0 < fibRank m ∧ m ∣ Nat.fib (fibRank m) :=
  Nat.sInf_mem (exists_pos_dvd_fib m hm)

lemma fibRank_pos (m : ℕ) (hm : 0 < m) : 0 < fibRank m := (fibRank_mem m hm).1
lemma dvd_fib_fibRank (m : ℕ) (hm : 0 < m) : m ∣ Nat.fib (fibRank m) := (fibRank_mem m hm).2
lemma fibRank_le {m k : ℕ} (hk : 0 < k) (h : m ∣ Nat.fib k) : fibRank m ≤ k :=
  Nat.sInf_le ⟨hk, h⟩

-- !-- Law of apparition.  `(⇐)` strong divisibility `F (rank m) ∣ F n`.  `(⇒)` push `m` onto
-- `F (gcd (rank m) n) = gcd (F (rank m)) (F n)`; minimality of the rank forces
-- `gcd (rank m) n = rank m`, i.e. `rank m ∣ n`. -- !--
theorem fib_dvd_iff_fibRank_dvd (m : ℕ) (hm : 0 < m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n := by
  constructor
  · intro h
    rcases Nat.eq_zero_or_pos n with hn | hn
    · simp [hn]
    · set d := Nat.gcd (fibRank m) n with hd
      have hdvd : m ∣ Nat.fib d := by
        rw [hd, Nat.fib_gcd]; exact Nat.dvd_gcd (dvd_fib_fibRank m hm) h
      have hdpos : 0 < d := Nat.gcd_pos_of_pos_right _ hn
      have hdle : d ≤ fibRank m := Nat.le_of_dvd (fibRank_pos m hm) (Nat.gcd_dvd_left _ _)
      have hdge : fibRank m ≤ d := fibRank_le hdpos hdvd
      have hdeq : d = fibRank m := le_antisymm hdle hdge
      rw [← hdeq]; exact Nat.gcd_dvd_right _ _
  · intro h
    exact dvd_trans (dvd_fib_fibRank m hm) (Nat.fib_dvd _ _ h)

/-- Two naturals with the same divisibility predicate coincide (used to identify generators). -/
lemma eq_of_dvd_iff {d e : ℕ} (h : ∀ N, d ∣ N ↔ e ∣ N) : d = e :=
  Nat.dvd_antisymm ((h e).mpr dvd_rfl) ((h d).mp dvd_rfl)

/-! ## §3. The Carmichael bridge: primitivity is rank-maximality (stalk-level recast) -/

/-- A prime `p` is a *primitive divisor* of `F n`: it divides `F n` but no earlier
positive-index Fibonacci number. -/
def IsPrimitiveDivisor (p n : ℕ) : Prop :=
  p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k

-- !-- Primitivity ⇔ rank-maximality.  `p` is primitive at `n` iff `rank p = n`: the rank is
-- the *first* index where `p` appears, so "no earlier appearance" is exactly `rank p = n`. -- !--
theorem isPrimitive_iff_fibRank_eq (p n : ℕ) (hp : 0 < p) (hn : 0 < n) :
    IsPrimitiveDivisor p n ↔ fibRank p = n := by
  constructor
  · rintro ⟨hdvd, hmin⟩
    have hle : fibRank p ∣ n := (fib_dvd_iff_fibRank_dvd p hp n).mp hdvd
    have hrle : fibRank p ≤ n := Nat.le_of_dvd hn hle
    rcases lt_or_eq_of_le hrle with hlt | heq
    · exact absurd (dvd_fib_fibRank p hp) (hmin (fibRank p) (fibRank_pos p hp) hlt)
    · exact heq
  · intro h
    refine ⟨by rw [← h]; exact dvd_fib_fibRank p hp, ?_⟩
    intro k hk hkn hpk
    have : fibRank p ≤ k := fibRank_le hk hpk
    omega

/-! ## §4. Local-to-global gluing of stalks -/

-- !-- CRT gluing.  For coprime moduli, `(a*b) ∣ F N ↔ a ∣ F N ∧ b ∣ F N`; translating each
-- side by the law of apparition gives `rank (a*b) ∣ N ↔ lcm (rank a) (rank b) ∣ N` for all
-- `N`, so the two generators coincide. -- !--
theorem fibRank_mul_coprime (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (hab : Nat.Coprime a b) :
    fibRank (a * b) = Nat.lcm (fibRank a) (fibRank b) := by
  have hab0 : 0 < a * b := Nat.mul_pos ha hb
  apply eq_of_dvd_iff
  intro N
  rw [← fib_dvd_iff_fibRank_dvd (a * b) hab0 N]
  constructor
  · intro h
    refine Nat.lcm_dvd ?_ ?_
    · rw [← fib_dvd_iff_fibRank_dvd a ha N]; exact dvd_trans (Dvd.intro b rfl) h
    · rw [← fib_dvd_iff_fibRank_dvd b hb N]; exact dvd_trans (Dvd.intro_left a rfl) h
  · intro h
    have hA : a ∣ Nat.fib N :=
      (fib_dvd_iff_fibRank_dvd a ha N).mpr (dvd_trans (Nat.dvd_lcm_left _ _) h)
    have hB : b ∣ Nat.fib N :=
      (fib_dvd_iff_fibRank_dvd b hb N).mpr (dvd_trans (Nat.dvd_lcm_right _ _) h)
    exact hab.mul_dvd_of_dvd_of_dvd hA hB

-- !-- Local-to-global divisibility: a modulus divides `x` iff each of its prime-power parts
-- does; the "sheaf gluing" of the divisibility predicate over the prime stalks.  `(⇒)` via
-- `Nat.ordProj_dvd`; `(⇐)` compare `p`-adic valuations through `Nat.factorization_le_iff_dvd`. -- !--
lemma dvd_iff_primePow (n x : ℕ) (hn : 0 < n) (hx : 0 < x) :
    n ∣ x ↔ ∀ p ∈ n.factorization.support, p ^ n.factorization p ∣ x := by
  constructor;
  · exact fun h p hp => dvd_trans ( Nat.ordProj_dvd _ _ ) h;
  · intro h; rw [ ← Nat.factorization_le_iff_dvd hn.ne' hx.ne' ] ;
    intro p; by_cases hp : p.Prime <;> by_cases hp' : p ∣ n <;> simp_all +decide [ Nat.factorization_eq_zero_of_not_dvd ] ;
    have := h p hp hp' hn.ne'; rw [ ← Nat.factorization_le_iff_dvd ] at this <;> aesop;

-- !-- Full reconstruction.  Apply the law of apparition and `dvd_iff_primePow` to `x = F N`:
-- `rank n ∣ N ↔ n ∣ F N ↔ ∀ p ∈ supp, p^{e_p} ∣ F N ↔ ∀ p, rank (p^{e_p}) ∣ N ↔
-- (lcm over supp of rank (p^{e_p})) ∣ N`, identifying the two generators. -- !--
theorem fibRank_eq_factorization_lcm (n : ℕ) (hn : 0 < n) :
    fibRank n
      = (n.factorization.support).lcm (fun p => fibRank (p ^ n.factorization p)) := by
  apply eq_of_dvd_iff;
  intro N
  rw [← fib_dvd_iff_fibRank_dvd n hn N];
  by_cases hN : N = 0;
  · aesop;
  · convert dvd_iff_primePow n ( Nat.fib N ) hn ( Nat.fib_pos.mpr ( Nat.pos_of_ne_zero hN ) ) using 1;
    rw [ Finset.lcm_dvd_iff ];
    exact forall₂_congr fun p hp => by rw [ fib_dvd_iff_fibRank_dvd _ ( pow_pos ( Nat.pos_of_mem_primeFactors hp ) _ ) _ ] ;

end FibApparitionSheaf