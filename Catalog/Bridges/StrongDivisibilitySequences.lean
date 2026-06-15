import Mathlib

/-! # Strong divisibility sequences: a unification of Fibonacci and Mersenne primitive-divisor theory

Domain: Bridges / Conceptual unification (number theory ↔ algebra).

A **strong divisibility sequence** is a sequence `a : ℕ → ℕ` with `a 0 = 0` and
`gcd (a m) (a n) = a (gcd m n)` for all `m n`.  This single axiom is the hidden
structure shared by

* the **Fibonacci** sequence `F` (`Nat.fib_gcd`),
* the **Mersenne / repunit** sequences `n ↦ b^n - 1` (`Nat.pow_sub_one_gcd_pow_sub_one`),
* and the trivial **identity** sequence `n ↦ n`.

The catalog already develops the *Fibonacci* entry-point and primitive-divisor theory
twice — `Catalog/Applications/FibonacciEntryPoints.lean` (`entryPoint`,
`dvd_fib_iff_entry_dvd`, `primitive_iff_entry_eq`) and
`Catalog/Applications/FibonacciPrimitiveDivisors.lean` (`IsPrimitive`,
`isPrimitive_unique`, `dvd_fib_iff_index_dvd_of_primitive`, `simultaneous_apparition`).
Here we show that **every one of those theorems holds for an arbitrary strong divisibility
sequence**, depending on nothing but the two structural axioms.  The Fibonacci results
become the `fibSDS` instance, and the *same theorems* immediately give the analogous
facts for `b^n - 1` (`mersenneSDS`) — a Zsygmondy-flavoured primitive-divisor theory for
Mersenne numbers, obtained for free.

Main results (all generic over `s : StrongDivSeq`):

* `StrongDivSeq.dvd_of_dvd`          — divisibility monotonicity `m ∣ n → s m ∣ s n`.
* `StrongDivSeq.dvd_gcd_iff`         — the meet law `d ∣ s (gcd m n) ↔ d ∣ s m ∧ d ∣ s n`.
* `StrongDivSeq.isPrimitive_unique`  — a value is primitive for at most one positive index.
* `StrongDivSeq.dvd_iff_index_dvd`   — a primitive divisor pins the divisibility set to multiples.
* `StrongDivSeq.simultaneous_apparition`        — the join law via `lcm`.
* `StrongDivSeq.simultaneous_apparition_finset` — the finite-family join law.
* `StrongDivSeq.entryPoint_isPrimitive`         — the entry point is itself a primitive index.
* `StrongDivSeq.dvd_iff_entryPoint_dvd`         — `p ∣ s n ↔ entryPoint p ∣ n`.
* `StrongDivSeq.primitive_iff_entryPoint_eq`    — primitivity ⇔ entry point equals the index.

Instances and cross-domain corollaries:

* `fibSDS`, `mersenneSDS`, `idSDS`.
* `mersenne_simultaneous_apparition` — the join law specialised to `b^n - 1` (new).
-/

/-
!-- Lab Notebook -- !--
!-- Hypothesis: The Fibonacci primitive-divisor theory in the catalog never uses anything
about Fibonacci numbers beyond `a 0 = 0` and the strong-divisibility identity
`gcd (a m) (a n) = a (gcd m n)`.  Therefore the entire theory should lift verbatim to an
abstract structure, unifying Fibonacci with the Mersenne sequences `b^n - 1`. -- !--
!-- Result: Confirmed.  Every catalog theorem (meet law, uniqueness, divisibility pinning,
join law, entry-point characterization) is reproved here generically and then instantiated.
The Mersenne join law `mersenne_simultaneous_apparition` is a genuinely new corollary. -- !--
!-- Insight: "Strong divisibility sequence" is the right Grothendieck-style object: it makes
the rank-of-apparition labelling a property of a single algebraic axiom, not of golden-ratio
arithmetic.  Fibonacci and Mersenne primitive-divisor theory are one theory. -- !--
!-- Failure analysis: the index-pinning lemma needs the `m = 0` boundary handled separately
(`s 0 = 0` is divisible by everything and `n ∣ 0` always holds); uniqueness needs both
indices positive (index `0` is vacuously primitive for every value). -- !--
!-- End Lab Notebook -- !--
-/

namespace StrongDivSeq

/-- A **strong divisibility sequence**: `a 0 = 0` and `gcd (a m) (a n) = a (gcd m n)`. -/
structure _root_.StrongDivSeq where
  /-- The underlying sequence. -/
  a : ℕ → ℕ
  /-- The sequence vanishes at `0`. -/
  map_zero : a 0 = 0
  /-- The strong divisibility identity. -/
  gcd_eq : ∀ m n, Nat.gcd (a m) (a n) = a (Nat.gcd m n)

variable (s : StrongDivSeq)

/-! ## §1. Structural consequences of the two axioms -/

/-
!-- `gcd m n = m` when `m ∣ n`, so `gcd (s m) (s n) = s m`, hence `s m ∣ s n`. -- !--
-/
theorem dvd_of_dvd {m n : ℕ} (h : m ∣ n) : s.a m ∣ s.a n := by
  have := s.gcd_eq m n;
  rw [ Nat.gcd_eq_left h ] at this;
  exact this ▸ Nat.gcd_dvd_right _ _

/-
!-- Rewrite `s (gcd m n)` to `gcd (s m) (s n)` by `gcd_eq`, then `Nat.dvd_gcd_iff`. -- !--
-/
theorem dvd_gcd_iff (d m n : ℕ) :
    d ∣ s.a (Nat.gcd m n) ↔ d ∣ s.a m ∧ d ∣ s.a n := by
  rw [ ← s.gcd_eq m n, Nat.dvd_gcd_iff ]

/-- `p` is a *primitive divisor* at index `n`: it divides `s n` but no earlier `s k`. -/
def IsPrimitive (p n : ℕ) : Prop :=
  p ∣ s.a n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ s.a k

/-! ## §2. Rigidity -/

/-
!-- At index `0` everything is primitive since `s 0 = 0`; the minimality clause is empty. -- !--
-/
theorem isPrimitive_zero (p : ℕ) : s.IsPrimitive p 0 := by
  exact ⟨ by rw [ s.map_zero ] ; norm_num, by intros; linarith ⟩

/-
!-- If `m < n`, primitivity at `n` forbids `p ∣ s m` while primitivity at `m` asserts it;
symmetrically for `n < m`.  Pure minimality clash, no structure needed. -- !--
-/
theorem isPrimitive_unique {p m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (hpm : s.IsPrimitive p m) (hpn : s.IsPrimitive p n) : m = n := by
  grind +locals

/-! ## §3. A primitive divisor pins down the divisibility set -/

/-
!-- (←) `n ∣ m → s n ∣ s m` (`dvd_of_dvd`) and `p ∣ s n`.  (→) `p ∣ s m, s n` give
`p ∣ s (gcd n m)` (`dvd_gcd_iff`); `gcd n m ≤ n` and minimality force `gcd n m = n`. -- !--
-/
theorem dvd_iff_index_dvd {p n : ℕ} (hn : 0 < n) (hp : s.IsPrimitive p n) (m : ℕ) :
    p ∣ s.a m ↔ n ∣ m := by
  constructor;
  · intro hm;
    have h_gcd : p ∣ s.a (Nat.gcd n m) := by
      exact s.dvd_gcd_iff p n m |>.2 ⟨ hp.1, hm ⟩;
    exact Classical.not_not.1 fun h => hp.2 ( Nat.gcd n m ) ( Nat.gcd_pos_of_pos_left _ hn ) ( lt_of_le_of_ne ( Nat.le_of_dvd hn ( Nat.gcd_dvd_left _ _ ) ) fun con => h <| con ▸ Nat.gcd_dvd_right _ _ ) h_gcd;
  · exact fun h => dvd_trans hp.1 ( s.dvd_of_dvd h )

/-! ## §4. The join law -/

/-
!-- Rewrite each conjunct by `dvd_iff_index_dvd` to `a ∣ n`, `b ∣ n`, then `Nat.lcm_dvd_iff`. -- !--
-/
theorem simultaneous_apparition {p q a b n : ℕ} (ha : 0 < a) (hb : 0 < b)
    (hp : s.IsPrimitive p a) (hq : s.IsPrimitive q b) :
    (p ∣ s.a n ∧ q ∣ s.a n) ↔ Nat.lcm a b ∣ n := by
  constructor <;> intro H;
  · exact Nat.lcm_dvd ( s.dvd_iff_index_dvd ha hp n |>.1 H.1 ) ( s.dvd_iff_index_dvd hb hq n |>.1 H.2 );
  · exact ⟨ dvd_trans ( s.dvd_iff_index_dvd ha hp a |>.2 ( dvd_refl a ) ) ( s.dvd_of_dvd ( dvd_trans ( Nat.dvd_lcm_left _ _ ) H ) ), dvd_trans ( s.dvd_iff_index_dvd hb hq b |>.2 ( dvd_refl b ) ) ( s.dvd_of_dvd ( dvd_trans ( Nat.dvd_lcm_right _ _ ) H ) ) ⟩

/-
!-- `Finset.induction`: empty case `Finset.lcm ∅ = 1`; insert step combines
`dvd_iff_index_dvd` with `Nat.lcm_dvd_iff`. -- !--
-/
theorem simultaneous_apparition_finset {ι : Type*} (t : Finset ι) (f g : ι → ℕ)
    (hpos : ∀ i ∈ t, 0 < g i) (hprim : ∀ i ∈ t, s.IsPrimitive (f i) (g i)) (n : ℕ) :
    (∀ i ∈ t, f i ∣ s.a n) ↔ (t.lcm g) ∣ n := by
  constructor <;> intro h;
  · refine' Finset.lcm_dvd fun i hi => _;
    exact s.dvd_iff_index_dvd ( hpos i hi ) ( hprim i hi ) n |>.1 ( h i hi );
  · intro i hi; exact dvd_trans ( hprim i hi |>.1 ) ( s.dvd_of_dvd ( by exact Nat.dvd_trans ( Finset.dvd_lcm hi ) h ) ) ;

/-! ## §5. Entry point (rank of apparition) -/

open Classical in
/-- The **entry point** of `p`: the least `k > 0` with `p ∣ s k`, or `0` if none exists. -/
noncomputable def entryPoint (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ s.a k then Nat.find h else 0

/-
!-- `Nat.find` of the existence witness is positive and satisfies `p ∣ s (entryPoint)`,
with the minimality clause from `Nat.find_min`; package as `IsPrimitive`. -- !--
-/
theorem entryPoint_isPrimitive {p : ℕ} (hex : ∃ k, 0 < k ∧ p ∣ s.a k) :
    s.IsPrimitive p (s.entryPoint p) := by
  unfold StrongDivSeq.IsPrimitive StrongDivSeq.entryPoint;
  grind +suggestions

/-
!-- (←) `entryPoint p ∣ n → s (entryPoint p) ∣ s n` and `p ∣ s (entryPoint p)`.
(→) gcd bridge + minimality, as in `dvd_iff_index_dvd`. -- !--
-/
theorem dvd_iff_entryPoint_dvd {p : ℕ} (hex : ∃ k, 0 < k ∧ p ∣ s.a k) (n : ℕ) :
    p ∣ s.a n ↔ s.entryPoint p ∣ n := by
  convert s.dvd_iff_index_dvd _ _ _ using 1;
  · unfold entryPoint; aesop;
  · exact s.entryPoint_isPrimitive hex

/-
!-- Combine `entryPoint_isPrimitive` with `isPrimitive_unique`. -- !--
-/
theorem primitive_iff_entryPoint_eq {p n : ℕ} (hn : 0 < n)
    (hex : ∃ k, 0 < k ∧ p ∣ s.a k) :
    s.IsPrimitive p n ↔ s.entryPoint p = n := by
  constructor <;> intro h;
  · have := @s.isPrimitive_unique p ( s.entryPoint p ) n ?_ ?_ ?_ h;
    · exact this;
    · unfold StrongDivSeq.entryPoint; aesop;
    · grind;
    · exact s.entryPoint_isPrimitive hex;
  · exact h ▸ entryPoint_isPrimitive s hex

end StrongDivSeq

/-! ## §6. Instances: Fibonacci, Mersenne, identity -/

/-- The Fibonacci sequence is a strong divisibility sequence (`Nat.fib_gcd`). -/
def fibSDS : StrongDivSeq where
  a := Nat.fib
  map_zero := Nat.fib_zero
  gcd_eq m n := (Nat.fib_gcd m n).symm

/-- The Mersenne / repunit sequence `n ↦ b^n - 1` is a strong divisibility sequence
(`Nat.pow_sub_one_gcd_pow_sub_one`). -/
def mersenneSDS (b : ℕ) : StrongDivSeq where
  a n := b ^ n - 1
  map_zero := by simp
  gcd_eq m n := Nat.pow_sub_one_gcd_pow_sub_one b m n

/-- The identity sequence `n ↦ n` is (trivially) a strong divisibility sequence. -/
def idSDS : StrongDivSeq where
  a := id
  map_zero := rfl
  gcd_eq _ _ := rfl

/-! ## §7. Cross-domain corollaries -/

/-- **Fibonacci join law**, recovered from the unified framework: two primitive Fibonacci
divisors `p` (of `F_a`) and `q` (of `F_b`) both divide `F_n` iff `lcm a b ∣ n`.
This reproves `FibonacciPrimitiveDivisors.simultaneous_apparition` as a special case of
`StrongDivSeq.simultaneous_apparition`. -/
theorem fib_simultaneous_apparition {p q a b n : ℕ} (ha : 0 < a) (hb : 0 < b)
    (hp : fibSDS.IsPrimitive p a) (hq : fibSDS.IsPrimitive q b) :
    (p ∣ Nat.fib n ∧ q ∣ Nat.fib n) ↔ Nat.lcm a b ∣ n :=
  fibSDS.simultaneous_apparition ha hb hp hq

/-- **Mersenne join law** (new): for the sequence `b^n - 1`, two primitive divisors
`p` (of `b^a - 1`) and `q` (of `b^b' - 1`) both divide `b^n - 1` iff `lcm a b' ∣ n`.
A Zsygmondy-flavoured statement obtained *for free* from the unified framework. -/
theorem mersenne_simultaneous_apparition (b : ℕ) {p q a b' n : ℕ} (ha : 0 < a) (hb : 0 < b')
    (hp : (mersenneSDS b).IsPrimitive p a) (hq : (mersenneSDS b).IsPrimitive q b') :
    (p ∣ b ^ n - 1 ∧ q ∣ b ^ n - 1) ↔ Nat.lcm a b' ∣ n :=
  (mersenneSDS b).simultaneous_apparition ha hb hp hq