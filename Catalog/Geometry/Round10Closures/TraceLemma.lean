/-
Round-10 Closures — Part I: the trace lemma for free witnesses.

The "free witness" of exponent `k` attached to a semiprime `N = p * q` is the
number of `k`-th roots of unity in `(ZMod N)ˣ`.  The folklore formula

    R_k(N) = gcd(k, p-1) * gcd(k, q-1)

is the arithmetic content of the *trace lemma*: every numeric witness of this
family factors through the pair of gcd-residue coordinates
`(gcd(k,p-1), gcd(k,q-1))`, and through nothing else.

This file gives a complete, sorry-free proof of that formula, together with the
structural lemmas it rests on (root counting in cyclic groups, transport along
group isomorphisms, multiplicativity over direct products, CRT for `ZMod`).
-/
import Mathlib

namespace Round10

open scoped Classical

/-! ## Counting roots of unity -/

/-- `rootCount G k` is the number of solutions of `x ^ k = 1` in the group `G`. -/
noncomputable def rootCount (G : Type*) [Group G] (k : ℕ) : ℕ :=
  Nat.card {x : G // x ^ k = 1}

/-- The `k`-torsion of a commutative group is the kernel of the `k`-th power map. -/
theorem rootCount_eq_card_ker (G : Type*) [CommGroup G] (k : ℕ) :
    rootCount G k = Nat.card (powMonoidHom k : G →* G).ker :=
  Nat.card_congr (Equiv.subtypeEquivRight fun x => by simp [MonoidHom.mem_ker, powMonoidHom])

/-- **Cyclic root count.** In a finite cyclic group of order `n` there are exactly
`gcd(n, k)` solutions of `x ^ k = 1`. -/
theorem rootCount_of_isCyclic (G : Type*) [CommGroup G] [IsCyclic G] [Finite G] (k : ℕ) :
    rootCount G k = (Nat.card G).gcd k := by
  rw [rootCount_eq_card_ker, IsCyclic.card_powMonoidHom_ker]

/-- Root counts are invariant under group isomorphism. -/
theorem rootCount_congr {G H : Type*} [Group G] [Group H] (e : G ≃* H) (k : ℕ) :
    rootCount G k = rootCount H k := by
  refine Nat.card_congr ⟨fun x => ⟨e x, by rw [← map_pow, x.2, map_one]⟩,
    fun y => ⟨e.symm y, by rw [← map_pow, y.2, map_one]⟩, ?_, ?_⟩ <;> intro x <;> simp

/-- Root counts are multiplicative over direct products: the CRT-separability of the
witness family. -/
theorem rootCount_prod (G H : Type*) [Group G] [Group H] (k : ℕ) :
    rootCount (G × H) k = rootCount G k * rootCount H k := by
  rw [rootCount, rootCount, rootCount, ← Nat.card_prod]
  refine Nat.card_congr ⟨fun x => (⟨x.1.1, ?_⟩, ⟨x.1.2, ?_⟩),
    fun y => ⟨(y.1.1, y.2.1), ?_⟩, ?_, ?_⟩
  · have := x.2; rw [Prod.ext_iff] at this; exact this.1
  · have := x.2; rw [Prod.ext_iff] at this; exact this.2
  · rw [Prod.ext_iff]; exact ⟨y.1.2, y.2.2⟩
  · intro x; ext <;> rfl
  · intro y; ext <;> rfl

/-! ## The unit group of a semiprime modulus -/

/-- Chinese remainder theorem at the level of unit groups. -/
noncomputable def unitsMulEquivProd {m n : ℕ} (h : Nat.Coprime m n) :
    (ZMod (m * n))ˣ ≃* (ZMod m)ˣ × (ZMod n)ˣ :=
  (Units.mapEquiv (ZMod.chineseRemainder h).toMulEquiv).trans MulEquiv.prodUnits

theorem card_units_zmod_prime (p : ℕ) [Fact p.Prime] : Nat.card (ZMod p)ˣ = p - 1 := by
  simp [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient,
    Nat.totient_prime (Fact.out : p.Prime)]

/-! ## The free-witness family -/

/-- The free witness `R_k(N)` of a semiprime `N = p * q`, defined intrinsically as the
number of `k`-th roots of unity modulo `N`. -/
noncomputable def freeWitness (N k : ℕ) : ℕ := rootCount (ZMod N)ˣ k

/-- **The trace lemma.**  For a semiprime modulus `N = p * q` with `p`, `q` coprime primes,
the number of `k`-th roots of unity modulo `N` is `gcd(p-1, k) * gcd(q-1, k)`.

Every free witness of the family therefore factors through the two gcd-residue
coordinates; no exponent `k` sees anything else about the factorisation. -/
theorem freeWitness_eq (p q k : ℕ) [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q) :
    freeWitness (p * q) k = (p - 1).gcd k * (q - 1).gcd k := by
  have h1 : freeWitness (p * q) k = rootCount ((ZMod p)ˣ × (ZMod q)ˣ) k :=
    rootCount_congr (unitsMulEquivProd hpq) k
  rw [h1, rootCount_prod, rootCount_of_isCyclic, rootCount_of_isCyclic,
    card_units_zmod_prime, card_units_zmod_prime]

/-- The free-witness family is symmetric in the two prime factors: it can never
distinguish `p` from `q`. -/
theorem freeWitness_symm (p q k : ℕ) [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q) :
    freeWitness (p * q) k = freeWitness (q * p) k := by
  rw [freeWitness_eq p q k hpq, freeWitness_eq q p k hpq.symm, Nat.mul_comm]

/-- Every free witness divides `k ^ 2`: the witness carries at most `2 log k` bits,
independently of the size of `N`.  (Barrier-4 bookkeeping: a single exponent leaks a
bounded amount of information.) -/
theorem freeWitness_dvd_sq (p q k : ℕ) [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q) :
    freeWitness (p * q) k ∣ k ^ 2 := by
  rw [freeWitness_eq p q k hpq, sq]
  exact Nat.mul_dvd_mul (Nat.gcd_dvd_right _ _) (Nat.gcd_dvd_right _ _)

/-- For `k = 2` and distinct odd primes there are exactly four square roots of unity
modulo `N = p*q`: the seed of the order-finding factorisation channel. -/
theorem freeWitness_two (p q : ℕ) [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q)
    (hp : p ≠ 2) (hq : q ≠ 2) : freeWitness (p * q) 2 = 4 := by
  have key : ∀ r : ℕ, Fact r.Prime → r ≠ 2 → (r - 1).gcd 2 = 2 := by
    intro r hr hr2
    obtain ⟨m, hm⟩ := (hr.out).odd_of_ne_two hr2
    subst hm
    simp
  rw [freeWitness_eq p q 2 hpq, key p ‹_› hp, key q ‹_› hq]

end Round10